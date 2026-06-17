import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Config de Supabase. Prioridad: --dart-define (build/CI) → .env (dev local).
/// La anon/publishable key es pública por diseño; el contenido es de lectura
/// pública por RLS, así que el mapa carga sin login. Las llaves SECRETAS nunca
/// van en el cliente.
class SupabaseConfig {
  SupabaseConfig._();

  static const String _defineUrl = String.fromEnvironment('SUPABASE_URL');
  static const String _defineAnon = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const String _definePub =
      String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  /// Lee de .env de forma segura: si dotenv no se inicializó (p. ej. el asset
  /// no estaba), devuelve null en vez de lanzar NotInitializedError.
  static String? _fromEnv(String key) {
    try {
      if (dotenv.isInitialized) return dotenv.maybeGet(key);
    } catch (_) {}
    return null;
  }

  static String get url =>
      _defineUrl.isNotEmpty ? _defineUrl : (_fromEnv('SUPABASE_URL') ?? '');

  static String get _anonKey =>
      _defineAnon.isNotEmpty ? _defineAnon : (_fromEnv('SUPABASE_ANON_KEY') ?? '');

  static String get _publishableKey => _definePub.isNotEmpty
      ? _definePub
      : (_fromEnv('SUPABASE_PUBLISHABLE_KEY') ?? '');

  /// Clave PÚBLICA del cliente. Preferimos la ANON key: es la que inyecta Vercel
  /// por --dart-define (SUPABASE_ANON_KEY) y la que pide el deploy. Si no está
  /// (algún entorno local sin anon), caemos a la publishable. Ambas son públicas
  /// y respetan RLS. La service_role / secret key NUNCA va en el cliente.
  static String get clientKey =>
      _anonKey.isNotEmpty ? _anonKey : _publishableKey;

  static bool get isConfigured => url.isNotEmpty && clientKey.isNotEmpty;
}
