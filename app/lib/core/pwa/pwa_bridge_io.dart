import 'pwa_bridge.dart';

// Stub no-web: la instalación PWA y el Web Push son superficies del navegador.
bool isStandaloneImpl() => true; // app nativa = ya "instalada"
bool canInstallImpl() => false;
bool isIosSafariImpl() => false;
Future<String> showInstallPromptImpl() async => 'unavailable';
Future<PushState> pushStateImpl() async => PushState.unsupported;
Future<PushSub?> pushSubscribeImpl(String vapidPublicKey) async => null;
