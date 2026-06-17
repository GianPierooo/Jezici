import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/supabase_config.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'data/providers.dart';
import 'features/auth/auth_screen.dart';
import 'features/notifications/matix_service.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/shell/home_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar .env (dev local). Si no existe, seguimos con --dart-define.
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {}

  if (SupabaseConfig.isConfigured) {
    // El param se llama publishableKey en supabase_flutter 2.15 (anonKey quedó
    // deprecado), pero el VALOR que pasamos es la ANON key (clientKey). Se usa
    // como apikey y respeta RLS. La service_role / secret key nunca va aquí.
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.clientKey,
    );
  }

  // Notificaciones locales del sistema (no-op en web; real en móvil).
  await LocalNotifier.instance.init();

  // Analítica: registra la apertura (fire-and-forget, nunca bloquea).
  if (SupabaseConfig.isConfigured) {
    try {
      Supabase.instance.client.rpc('log_event', params: {'p_event': 'app_open'});
    } catch (_) {}
  }

  // Crash reporting / monitoreo (GA6). Se activa SOLO si hay DSN (Vercel env
  // SENTRY_DSN → dart-define). Sin DSN es un no-op total: no envía nada.
  const dsn = String.fromEnvironment('SENTRY_DSN');
  if (dsn.isEmpty) {
    runApp(const ProviderScope(child: JeziciApp()));
  } else {
    await SentryFlutter.init(
      (o) {
        o.dsn = dsn;
        o.tracesSampleRate = 0.2;
        o.environment = const String.fromEnvironment('APP_ENV', defaultValue: 'production');
        o.sendDefaultPii = false; // sin datos personales
      },
      appRunner: () => runApp(const ProviderScope(child: JeziciApp())),
    );
  }
}

class JeziciApp extends StatelessWidget {
  const JeziciApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jezici',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AppGate(),
    );
  }
}

/// Puerta de entrada (GA4 auth-first). Tres estados:
///   1) sin sesión            → AuthScreen (crear cuenta / iniciar sesión)
///   2) sesión sin onboarding → OnboardingScreen (obligatorio para todos)
///   3) sesión + onboarding   → HomeShell (mapa)
/// Reacciona a login/logout vía onAuthStateChange y refresca los datos del
/// usuario al cambiar de cuenta.
class AppGate extends ConsumerStatefulWidget {
  const AppGate({super.key});

  @override
  ConsumerState<AppGate> createState() => _AppGateState();
}

class _AppGateState extends ConsumerState<AppGate> {
  Session? _session;
  String? _lastUid;
  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
    try {
      _session = Supabase.instance.client.auth.currentSession;
      _lastUid = _session?.user.id;
      _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
        if (!mounted) return;
        final s = data.session;
        final uid = s?.user.id;
        final userChanged = uid != _lastUid;
        _lastUid = uid;
        setState(() => _session = s);
        if (userChanged) {
          // Nuevo usuario o logout → refrescar datos derivados.
          ref.invalidate(onboardingCompleteProvider);
          ref.invalidate(userPlanProvider);
          ref.invalidate(homeStatsProvider);
          ref.invalidate(skillsProvider);
          ref.invalidate(lessonProgressProvider);
        }
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_session == null) return const AuthScreen();
    final onb = ref.watch(onboardingCompleteProvider);
    return onb.when(
      loading: () => const _Splash(),
      error: (_, _) => _Splash(onRetry: () => ref.invalidate(onboardingCompleteProvider)),
      data: (done) => done
          ? const HomeShell()
          : OnboardingScreen(onComplete: () => ref.invalidate(onboardingCompleteProvider)),
    );
  }
}

/// Splash mínimo de marca mientras se resuelve el estado de onboarding.
class _Splash extends StatelessWidget {
  const _Splash({this.onRetry});
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🦜', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 18),
            if (onRetry == null)
              const CircularProgressIndicator(color: AppColors.primary)
            else ...[
              const Text('No se pudo cargar tu sesión.',
                  style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textMuted)),
              const SizedBox(height: 12),
              TextButton(onPressed: onRetry, child: const Text('Reintentar')),
            ],
          ],
        ),
      ),
    );
  }
}
