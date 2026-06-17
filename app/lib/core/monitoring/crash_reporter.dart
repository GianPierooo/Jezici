import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Monitoreo de errores (GA6) — captura crashes de Flutter y de la zona y los
/// registra en analytics_events (evento 'client_error') para saber qué falla en
/// producción. Pure-Dart (web-safe, sin dependencias nativas). Para un APM
/// completo (Sentry), basta envolver runApp con SentryFlutter.init usando un DSN
/// (ver docs/GO_LIVE.md); esto cubre la captura básica sin gastar build.
void installCrashReporting() {
  final original = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    original?.call(details);
    _report(details.exceptionAsString(), details.library ?? 'flutter');
  };
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    _report(error.toString(), 'platform');
    return false; // que el framework siga manejándolo
  };
}

void _report(String message, String where) {
  // Fire-and-forget; jamás rompe el flujo del usuario. Requiere sesión
  // (log_event es SECURITY DEFINER para authenticated); si no hay, se ignora.
  try {
    final msg = message.length > 600 ? message.substring(0, 600) : message;
    Supabase.instance.client.rpc('log_event', params: {
      'p_event': 'client_error',
      'p_props': {'message': msg, 'where': where},
    });
  } catch (_) {}
}
