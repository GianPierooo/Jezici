import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/supabase_config.dart';
import 'core/theme/app_theme.dart';
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

  runApp(const ProviderScope(child: JeziciApp()));
}

class JeziciApp extends StatelessWidget {
  const JeziciApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jezici',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AppRoot(),
    );
  }
}

/// Decide la pantalla inicial: si hay sesión → mapa; si no → onboarding.
/// El paso G reemplazó el sign-in anónimo automático del paso E.
class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  late bool _showHome;
  StreamSubscription<dynamic>? _authSub;

  @override
  void initState() {
    super.initState();
    var hasSession = false;
    try {
      hasSession = Supabase.instance.client.auth.currentSession != null;
      // Reaccionar a login/logout (p. ej. "cerrar sesión" vuelve al onboarding).
      _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
        if (!mounted) return;
        final has = data.session != null;
        if (has != _showHome) setState(() => _showHome = has);
      });
    } catch (_) {}
    _showHome = hasSession;
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _showHome
        ? const HomeShell()
        : OnboardingScreen(onComplete: () => setState(() => _showHome = true));
  }
}
