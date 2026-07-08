import 'legal_open_io.dart' if (dart.library.js_interop) 'legal_open_web.dart' as impl;

/// Versión del contenido legal (Privacidad+Términos). Súbela cuando el texto
/// cambie (p. ej. tras la revisión de abogado) → permite detectar y disparar
/// re-consentimiento (ver `accept_legal`/`my_legal_version`, mig 062).
const kLegalVersion = '2026-07-draft';

/// Rutas PÚBLICAS de las páginas legales, servidas por el deploy SIN login
/// (Vercel sirve `web/privacy.html`/`web/terms.html`; los rewrites de `vercel.json`
/// mapean `/privacy`→`/privacy.html` y `/terms`→`/terms.html`). URL estable para
/// Google OAuth / Search Console: `https://jezici.vercel.app/privacy` y `/terms`.
/// Una sola fuente de verdad: el HTML público (la app enlaza, no duplica el texto).
const kPrivacyPath = '/privacy';
const kTermsPath = '/terms';

/// Abre la página legal pública en una pestaña nueva (web). Construye la URL
/// absoluta a partir del origen actual → prod jezici.vercel.app, previews su URL.
/// No-op fuera de web; nunca crashea (BORRADOR beta, pendiente de revisión legal).
void openLegalPage(String path) {
  try {
    impl.openUrl('${Uri.base.origin}$path');
  } catch (_) {}
}
