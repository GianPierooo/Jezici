import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Config de Supabase. Prioridad: --dart-define (build/CI) → .env (dev local)
/// → fallback PÚBLICO embebido (último recurso, para que el deploy NUNCA quede
/// sin configurar).
///
/// Sobre el fallback embebido: la URL y la ANON key son PÚBLICAS por diseño —
/// viajan en el bundle del cliente y se exponen al navegador; la seguridad la
/// da RLS, no el secreto de la anon key (es lo que documenta Supabase). Por eso
/// es seguro commitearlas como red de seguridad. Las llaves SECRETAS
/// (service_role / secret key) NUNCA van en el cliente ni en el repo.
///
/// En Vercel basta con definir las env vars SUPABASE_URL y SUPABASE_ANON_KEY
/// (las inyecta el buildCommand por --dart-define); si están, ganan sobre el
/// fallback.
class SupabaseConfig {
  SupabaseConfig._();

  static const String _defineUrl = String.fromEnvironment('SUPABASE_URL');
  static const String _defineAnon = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const String _definePub =
      String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  // Fallback público (proyecto Jezici). Solo se usa si no hay dart-define ni .env.
  static const String _fallbackUrl = 'https://wiauinufpbkmjlbqlkxo.supabase.co';
  static const String _fallbackAnon =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndpYXVpbnVmcGJrbWpsYnFsa3hvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE2NDEwMTUsImV4cCI6MjA5NzIxNzAxNX0.Nj3J81G-ZLHENKWxlcT0xjJ3zgccQDM2k247cJO2mfE';

  /// Lee de .env de forma segura: si dotenv no se inicializó (p. ej. el asset
  /// no estaba), devuelve null en vez de lanzar NotInitializedError.
  static String? _fromEnv(String key) {
    try {
      if (dotenv.isInitialized) {
        final v = dotenv.maybeGet(key);
        if (v != null && v.isNotEmpty) return v;
      }
    } catch (_) {}
    return null;
  }

  static String get url {
    if (_defineUrl.isNotEmpty) return _defineUrl;
    return _fromEnv('SUPABASE_URL') ?? _fallbackUrl;
  }

  static String get _anonKey {
    if (_defineAnon.isNotEmpty) return _defineAnon;
    return _fromEnv('SUPABASE_ANON_KEY') ?? _fallbackAnon;
  }

  static String get _publishableKey {
    if (_definePub.isNotEmpty) return _definePub;
    return _fromEnv('SUPABASE_PUBLISHABLE_KEY') ?? '';
  }

  /// Clave PÚBLICA del cliente. Preferimos la ANON key (la que inyecta Vercel
  /// por --dart-define=SUPABASE_ANON_KEY y la del fallback embebido); si no
  /// está, caemos a la publishable. Ambas son públicas y respetan RLS. La
  /// service_role / secret key NUNCA va en el cliente.
  static String get clientKey =>
      _anonKey.isNotEmpty ? _anonKey : _publishableKey;

  /// Con el fallback embebido esto es siempre true, pero lo mantenemos por
  /// robustez (si algún día se quita el fallback).
  static bool get isConfigured => url.isNotEmpty && clientKey.isNotEmpty;
}
