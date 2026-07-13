/// ─────────────────────────────────────────────────────────────────────────────
/// CONFIG de DONACIONES — "Aporta un grano de arena" (T6).
///
/// Donación VOLUNTARIA de apoyo — NO es una compra que desbloquee nada dentro
/// del juego (para no chocar con reglas de tiendas ni sobreprometer). Todo lo
/// que Gian debe rellenar para ACTIVAR cada método vive AQUÍ (una sola fuente):
///
///   1) Yape   ✅ LIVE — número 906517394 + QR real (`assets/donations/yape_qr.png`).
///   2) Plin   ⏳ número 906517394 (mismo que Yape) LISTO; falta subir el QR en
///             `app/assets/donations/plin_qr.png` (PNG cuadrado). Sin él, la fila
///             muestra un icono neutro "sin QR" pero el NÚMERO ya funciona.
///   3) PayPal ✅ LIVE — enlace de donación en [paypalUrl].
///   4) Stripe ⏳ pega tu Payment Link (dashboard Stripe → Payment links) en
///             [stripeUrl]; vacío = "Pronto" (deshabilitado, sin botón muerto).
///
/// Reglas de la UI (honestas): Yape/Plin se muestran como NÚMERO + QR (no botón
/// web). PayPal/Stripe como ENLACE — si su URL sigue vacía (placeholder), el
/// método aparece deshabilitado con "Pronto" (no un botón muerto).
/// ─────────────────────────────────────────────────────────────────────────────
library;

class Donations {
  Donations._();

  /// Yape (Perú) — número de destino. QR en assets/donations/yape_qr.png.
  static const String yapeNumber = '906517394';
  static const String yapeQrAsset = 'assets/donations/yape_qr.png';

  /// Plin — mismo número por defecto (cámbialo si Gian usa otro).
  static const String plinNumber = '906517394';
  static const String plinQrAsset = 'assets/donations/plin_qr.png';
  static const bool plinSameAsYape = true; // muestra la nota "mismo número que Yape"

  /// PayPal — enlace de donación (botón "Donate" hospedado). LIVE.
  static const String paypalUrl =
      'https://www.paypal.com/donate/?hosted_button_id=7PDSNNUTYRXUG';

  /// Stripe — PEGA tu Payment Link (dashboard → Payment links). Vacío = "Pronto".
  static const String stripeUrl = '';

  /// ¿El enlace está configurado (no es placeholder)?
  static bool isLive(String url) => url.trim().startsWith('http');
}
