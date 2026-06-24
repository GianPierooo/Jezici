import 'dart:async';

import 'package:sentry_flutter/sentry_flutter.dart';

import '../app_info.dart';

/// DSN de Sentry (NO es secreto: está diseñado para ir en clientes). Se inyecta
/// por --dart-define con VALOR LITERAL (ver más abajo), NO por $VAR en el
/// buildCommand de Vercel (eso rompió el deploy una vez). Sin DSN → NO-OP.
const _dsn = String.fromEnvironment('SENTRY_DSN', defaultValue: '');
const _env = String.fromEnvironment('SENTRY_ENV', defaultValue: 'beta');

/// ¿Sentry activo? (hay DSN). Lo usan los puntos que setean usuario/captura.
bool get sentryEnabled => _dsn.isNotEmpty;

/// Corre la app dentro de Sentry para capturar errores de Flutter + nativos
/// (iOS/Android) + de la zona, sin doble-manejo. Si NO hay DSN, ejecuta el
/// appRunner directo: la app arranca igual, sin init, sin coste. Init liviano
/// (sin profiling, traces bajo) para no tocar el arranque ya optimizado.
Future<void> runWithSentry(FutureOr<void> Function() appRunner) async {
  if (_dsn.isEmpty) {
    await appRunner();
    return;
  }
  await SentryFlutter.init(
    (o) {
      o.dsn = _dsn;
      o.environment = _env;
      // release atado al SELLO EFECTIVO (appBuild: window.JZ_BUILD del deploy en
      // runtime, o 'dev'). Sin tocar el buildCommand → no rompe el deploy.
      o.release = 'jezici@${appBuild()}';
      o.tracesSampleRate = 0.1; // beta chica: muestreo bajo de performance
      o.sendDefaultPii = false; // postura GDPR: sin email/IP por defecto
      o.beforeSend = _beforeSend;
    },
    appRunner: appRunner,
  );
}

/// Filtra ruido benigno (timeouts de red, cancelaciones) para no ahogar el
/// dashboard de una beta chica.
FutureOr<SentryEvent?> _beforeSend(SentryEvent event, Hint hint) {
  final s = (event.throwable?.toString() ?? event.message?.formatted ?? '')
      .toLowerCase();
  const benign = [
    'socketexception',
    'timeoutexception',
    'timeout',
    'connection closed',
    'connection reset',
    'failed host lookup',
    'clientexception',
    'network is unreachable',
    'operation was cancelled',
    'cancelado',
    'cancelled',
  ];
  if (benign.any(s.contains)) return null;
  return event;
}

/// Asocia un id OPACO (auth.uid) al scope para correlacionar errores, sin PII
/// (sin email/nombre). No-op si Sentry está apagado.
void sentrySetUser(String? uid) {
  if (_dsn.isEmpty) return;
  Sentry.configureScope((scope) {
    scope.setUser(uid == null ? null : SentryUser(id: uid));
  });
}
