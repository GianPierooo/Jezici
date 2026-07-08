import 'dart:js_interop';
import 'dart:js_interop_unsafe';

/// Abre [url] en una pestaña nueva del navegador (window.open). Degradación con
/// gracia: si algo falla, no hace nada (no crashea).
void openUrl(String url) {
  try {
    globalContext.callMethod('open'.toJS, url.toJS, '_blank'.toJS);
  } catch (_) {/* sin window.open → nada */}
}
