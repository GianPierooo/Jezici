import '../../features/legal/legal_open_io.dart'
    if (dart.library.js_interop) '../../features/legal/legal_open_web.dart' as impl;

/// Abre una URL externa (completa) en una pestaña nueva del navegador. Reusa el
/// mismo `openUrl` del módulo legal (web: window.open; no-op fuera de web).
/// Degrada con gracia; nunca lanza.
void openExternalUrl(String url) {
  try {
    impl.openUrl(url);
  } catch (_) {}
}
