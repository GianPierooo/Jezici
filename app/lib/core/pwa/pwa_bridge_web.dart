import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'pwa_bridge.dart';

@JS('window')
external JSObject get _window;

@JS('navigator.userAgent')
external String get _userAgent;

bool _callBool(String name) {
  try {
    final r = _window.callMethod(name.toJS);
    return (r as JSBoolean?)?.toDart ?? false;
  } catch (_) {
    return false;
  }
}

Future<String?> _callStringAsync(String name, [String? arg]) async {
  try {
    final r = arg == null
        ? _window.callMethod(name.toJS)
        : _window.callMethod(name.toJS, arg.toJS);
    final v = await (r as JSPromise).toDart;
    return (v as JSString?)?.toDart;
  } catch (_) {
    return null;
  }
}

bool isStandaloneImpl() => _callBool('jzIsStandalone');
bool canInstallImpl() => _callBool('jzCanInstall');

bool isIosSafariImpl() {
  final ua = _userAgent;
  return ua.contains('iPhone') || ua.contains('iPad');
}

Future<String> showInstallPromptImpl() async =>
    await _callStringAsync('jzShowInstall') ?? 'unavailable';

Future<PushState> pushStateImpl() async {
  final s = await _callStringAsync('jzPushState');
  switch (s) {
    case 'subscribed':
      return PushState.subscribed;
    case 'ready':
      return PushState.ready;
    case 'denied':
      return PushState.denied;
    default:
      return PushState.unsupported;
  }
}

Future<PushSub?> pushSubscribeImpl(String vapidPublicKey) async {
  final raw = await _callStringAsync('jzPushSubscribe', vapidPublicKey);
  if (raw == null) return null;
  try {
    final m = Map<String, dynamic>.from(json.decode(raw) as Map);
    final endpoint = m['endpoint'] as String?;
    final p256dh = m['p256dh'] as String?;
    final auth = m['auth'] as String?;
    if (endpoint == null || p256dh == null || auth == null) return null;
    return PushSub(endpoint, p256dh, auth);
  } catch (_) {
    return null;
  }
}
