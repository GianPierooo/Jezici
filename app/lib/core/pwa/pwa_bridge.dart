/// T4 · Puente PWA: instalar la app + Web Push (VAPID, sin FCM).
/// El trabajo pesado vive en JS global (index.html, funciones `jz*`); aquí solo
/// se invocan por js_interop. En no-web, todo degrada a no-op honesto.
library;

import 'pwa_bridge_io.dart' if (dart.library.js_interop) 'pwa_bridge_web.dart';

/// Clave PÚBLICA VAPID (no es secreta: identifica al emisor ante el push
/// service del navegador; la privada vive como secret de la Edge Function).
const String kVapidPublicKey =
    'BIHoFPfJ0nO9ErHfIPoQhvdzTLltEHJl2A4hclZcWcSYs_O7NXwKRDfionbBjJ5wjsHBlw7zvfjfGtMkSPwKwAk';

/// Estado del push en este dispositivo.
enum PushState { unsupported, denied, ready, subscribed }

/// Datos de la suscripción push recién creada.
class PushSub {
  const PushSub(this.endpoint, this.p256dh, this.auth);
  final String endpoint, p256dh, auth;
}

/// ¿La app ya corre instalada (standalone)?
bool get isStandalone => isStandaloneImpl();

/// ¿Hay prompt de instalación capturado (Chrome/Edge Android+desktop)?
bool get canInstall => canInstallImpl();

/// ¿Safari en iOS/iPadOS? (sin beforeinstallprompt → instrucciones manuales).
bool get isIosSafari => isIosSafariImpl();

/// Muestra el prompt nativo de instalación. → 'accepted' | 'dismissed' | 'unavailable'.
Future<String> showInstallPrompt() => showInstallPromptImpl();

/// Estado actual del push (sin pedir permiso).
Future<PushState> pushState() => pushStateImpl();

/// Pide permiso (bajo gesto del usuario) y suscribe. null si lo negó/falló.
Future<PushSub?> pushSubscribe() => pushSubscribeImpl(kVapidPublicKey);
