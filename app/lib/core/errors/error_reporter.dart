import 'package:sentry_flutter/sentry_flutter.dart';

import '../monitoring/sentry_config.dart';
import 'jz_error.dart';

/// Reporta un error a Sentry con contexto útil (kind, reason, rpc) y SIN PII.
/// Convierte a `JzError` una vez, ignora el ruido de red (benigno), y no hace
/// nada si Sentry está apagado (sin DSN) → seguro de llamar desde cualquier catch.
///
/// Es el reemplazo honesto del `catch (_) {}` mudo: donde antes un fallo se
/// tragaba sin dejar rastro, ahora Sentry LO VE (con los 5 usuarios reales, un
/// fallo dejaba de ser invisible). Devuelve el `JzError` tipado para que quien
/// llama decida qué mensaje mostrar.
JzError reportError(Object? error, {StackTrace? stackTrace, String? rpc, String? context}) {
  final jz = JzError.from(error, rpc: rpc);
  if (!sentryEnabled || !jz.shouldReport) return jz;
  try {
    Sentry.captureException(
      jz.cause ?? jz,
      stackTrace: stackTrace,
      withScope: (scope) {
        scope.setTag('jz_kind', jz.kind.name);
        if (jz.reason != null) scope.setTag('jz_reason', jz.reason!);
        if (jz.rpc != null) scope.setTag('jz_rpc', jz.rpc!);
        if (context != null) scope.setTag('jz_context', context);
      },
    );
  } catch (_) {
    // Nunca dejar que el propio reporte de error rompa el flujo del usuario.
  }
  return jz;
}
