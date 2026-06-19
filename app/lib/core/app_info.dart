import 'package:flutter/foundation.dart';

/// Versión visible de la app (espejo de pubspec version). Actualizar al subir.
const kAppVersion = '1.0.0';

/// Sello de build (P0.5): el SHA del commit desplegado, inyectado por Vercel
/// (--dart-define=JZ_BUILD=$VERCEL_GIT_COMMIT_SHA). 'dev' en local. Sirve para
/// confirmar a simple vista qué bundle está corriendo (cache-busting/diagnóstico).
const kAppBuild = String.fromEnvironment('JZ_BUILD', defaultValue: 'dev');

/// Sello corto para mostrar discretamente (p.ej. "1.0.0 · a1b2c3d").
String buildLabel() {
  final b = kAppBuild.length > 7 ? kAppBuild.substring(0, 7) : kAppBuild;
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
