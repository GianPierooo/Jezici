import 'dart:js_interop';
import 'dart:js_interop_unsafe';

/// Sello de build en runtime (WEB): lee `window.JZ_BUILD`, que el deploy de Vercel
/// inyecta en index.html vía scripts/stamp_build.sh (deploy-safe: el SHA se obtiene
/// dentro del script desde $VERCEL_GIT_COMMIT_SHA, NUNCA en el buildCommand). index.html
/// se sirve no-store (sw v4), así que el sello refleja el bundle realmente cargado.
/// Devuelve null si no está (local / CI / build sin sello) → cae al compile-time.
String? runtimeBuildStamp() {
  if (globalContext.has('JZ_BUILD')) {
    final v = globalContext.getProperty('JZ_BUILD'.toJS);
    if (v != null) {
      final s = (v as JSString).toDart;
      if (s.isNotEmpty && s != 'dev') return s;
    }
  }
  return null;
}
