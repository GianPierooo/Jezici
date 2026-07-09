import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/audio/audio_engine.dart';
import 'core/config/supabase_config.dart';
import 'core/i18n/locale_controller.dart';
import 'core/monitoring/crash_reporter.dart';
import 'core/monitoring/sentry_config.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'data/providers.dart';
import 'l10n/app_localizations.dart';
import 'features/auth/auth_screen.dart';
import 'features/learn/widgets/parrot_mascot.dart';
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

  // Monitoreo de errores (GA6): captura crashes → analytics_events. Pure-Dart,
  // web-safe. Convive con Sentry (sinks distintos; sin doble-manejo).
  if (SupabaseConfig.isConfigured) installCrashReporting();

  // APM client-side: si hay SENTRY_DSN, corre la app dentro de Sentry (captura
  // Flutter + nativo + zona). Sin DSN → NO-OP: arranca igual.
  await runWithSentry(() => runApp(const ProviderScope(child: JeziciApp())));
}

class JeziciApp extends ConsumerWidget {
  const JeziciApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Idioma de la UI (chrome de la app): es/en/pt, persistido en el dispositivo.
    // NO es el idioma OBJETIVO del curso (es→en / es→pt viene de la DB).
    final lang = ref.watch(localeProvider);
    return MaterialApp(
      title: 'Jezici',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: Locale(lang),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // Desbloqueo de audio en el PRIMER gesto real, en CUALQUIER pantalla
      // (incluidas las rutas pusheadas como el lesson player). iOS Safari exige
      // que AudioContext.resume() se dispare síncronamente desde un gesto;
      // hacerlo aquí, sobre el Navigator, evita el "hay que tocar dos veces" y
      // los SFX mudos. El unlock de lesson_player_screen.dart (initState) se
      // mantiene como refuerzo.
      builder: (context, child) =>
          _AudioUnlockGate(child: child ?? const SizedBox.shrink()),
      home: const AppGate(),
    );
  }
}

/// Envuelve toda la app y desbloquea el AudioContext en el primer toque (un solo
/// disparo). Un `Listener` por encima del Navigator recibe el `onPointerDown`
/// aunque un widget hijo también lo maneje (los pointer events se propagan a
/// todos los listeners del hit-test).
class _AudioUnlockGate extends StatefulWidget {
  const _AudioUnlockGate({required this.child});
  final Widget child;

  @override
  State<_AudioUnlockGate> createState() => _AudioUnlockGateState();
}

class _AudioUnlockGateState extends State<_AudioUnlockGate> {
  bool _unlocked = false;

  void _onDown(PointerDownEvent _) {
    if (_unlocked) return;
    _unlocked = true;
    // Síncrono dentro del gesto: clave para iOS.
    AudioEngine.instance.unlock();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _onDown, // no-op tras el primer toque (guard `_unlocked`)
      child: widget.child,
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
      sentrySetUser(_lastUid);
      _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
        if (!mounted) return;
        final s = data.session;
        final uid = s?.user.id;
        final userChanged = uid != _lastUid;
        _lastUid = uid;
        // Id OPACO en Sentry (sin email/PII) para correlacionar errores.
        sentrySetUser(uid);
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
            const ParrotArt(size: 64),
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
