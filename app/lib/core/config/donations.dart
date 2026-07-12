/// ─────────────────────────────────────────────────────────────────────────────
/// CONFIG de DONACIONES — "Aporta un grano de arena" (T6).
///
/// Donación VOLUNTARIA de apoyo — NO es una compra que desbloquee nada dentro
/// del juego (para no chocar con reglas de tiendas ni sobreprometer). Todo lo
/// que Gian debe rellenar para ACTIVAR cada método vive AQUÍ (una sola fuente):
///
///   1) Yape  → número ya puesto (906517394). Reemplaza el QR:
///              `app/assets/donations/yape_qr.png`  (mismo nombre, PNG cuadrado).
///   2) Plin  → usa el MISMO número por defecto (906517394). Si es otro, cámbialo
///              en [plinNumber]. Reemplaza el QR: `app/assets/donations/plin_qr.png`.
///   3) PayPal→ pega tu enlace (paypal.me/tuusuario o botón) en [paypalUrl].
///   4) Stripe→ pega tu Payment Link (dashboard Stripe → Payment links) en [stripeUrl].
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

  /// PayPal — PEGA tu enlace (paypal.me/... o botón). Vacío = "Pronto".
  static const String paypalUrl = '';

  /// Stripe — PEGA tu Payment Link (dashboard → Payment links). Vacío = "Pronto".
  static const String stripeUrl = '';

  /// ¿El enlace está configurado (no es placeholder)?
  static bool isLive(String url) => url.trim().startsWith('http');
}
