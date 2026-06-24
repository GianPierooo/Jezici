import 'package:flutter/foundation.dart';

import 'app_info_stamp_io.dart' if (dart.library.js_interop) 'app_info_stamp_web.dart';

/// Versión visible de la app (espejo de pubspec version). Actualizar al subir.
const kAppVersion = '1.0.0';

/// Sello de build compile-time. En el deploy de Vercel NO se inyecta por
/// --dart-define (eso rompía el deploy: cualquier $VAR/$() del SHA en el
/// buildCommand → ERROR pre-build). Se inyecta en RUNTIME (ver [appBuild]).
/// 'dev' en local/CI.
const kAppBuild = String.fromEnvironment('JZ_BUILD', defaultValue: 'dev');

/// Sello EFECTIVO del build: prioriza el inyectado en runtime (window.JZ_BUILD,
/// puesto en index.html por el post-build de Vercel) y cae al compile-time
/// ('dev' en local/CI). Sirve para saber exactamente qué bundle corre un tester
/// (diagnóstico de la beta / confirmar que no es caché vieja).
String appBuild() => runtimeBuildStamp() ?? kAppBuild;

/// Sello corto para mostrar discretamente (p.ej. "1.0.0 · a1b2c3d").
String buildLabel() {
  final b0 = appBuild();
  final b = b0.length > 7 ? b0.substring(0, 7) : b0;
  return '$kAppVersion · $b';
}

/// Plataforma para contexto de feedback/analítica.
String platformName() {
  if (kIsWeb) return 'web';
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return 'android';
    case TargetPlatform.iOS:
      return 'ios';
    default:
      return defaultTargetPlatform.name;
  }
}
