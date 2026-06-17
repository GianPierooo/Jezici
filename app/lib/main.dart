import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'features/shell/home_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar .env (dev local). Si no existe, seguimos con --dart-define.
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // .env opcional: la config puede venir por --dart-define.
  }

  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.clientKey,
    );

    // Auth mínima TEMPORAL (el onboarding real es el paso G): sesión anónima
    // para tener auth.users (trigger crea perfil + stats + racha) y arranque
    // del curso (progreso + 4 habilidades). El contenido es público, así que
    // si esto falla la app igual abre el mapa en modo lectura.
    try {
      final client = Supabase.instance.client;
      if (client.auth.currentSession == null) {
        await client.auth.signInAnonymously();
      }
      await client.rpc('start_course');
    } catch (_) {}
  }

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
      home: const HomeShell(),
    );
  }
}
