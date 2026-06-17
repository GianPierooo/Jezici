import 'package:flutter/foundation.dart';

/// Versión visible de la app (espejo de pubspec version). Actualizar al subir.
const kAppVersion = '1.0.0';

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
