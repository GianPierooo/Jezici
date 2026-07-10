import 'package:flutter/material.dart';

/// Escenografía del mapa (Aprender v2.dc). El mockup es UNA escena de altura FIJA
/// (368×1860): cima arriba → cielo → costa → colinas → base. Los mapas reales son
/// MUCHO más altos (5.000–23.000px: `_flatten` = todas las lecciones), así que
/// estirar ese diseño dejaba un enorme MEDIO casi plano que —con las transiciones
/// del degradado— se leía como losas/bandas rotas y chocantes ("las franjas").
///
/// FIX (limpio y robusto a cualquier altura, fiel al mockup):
///  • VISTA DE CIMA arriba (sol, cordilleras, costa con velero) — el DESTINO del
///    viaje. Su base se FUNDE al cielo (sin borde duro).
///  • PRIMER PLANO verde abajo (colinas suaves + pinos) — donde ESTÁS. Su cresta
///    se FUNDE al cielo.
///  • El MEDIO es CIELO: solo el degradado del fondo + NUBES suaves traslúcidas
///    distribuidas por TODA la altura (densidad ∝ alto). Óvalos translúcidos →
///    imposible que se lean como bandas. El sendero queda limpio encima.
/// Full-bleed en X (llena el ancho en desktop); la columna de nodos se centra
/// aparte (dx0). Estático (sin coste de animación · reduce-motion seguro).
class SceneryPainter extends CustomPainter {
  SceneryPainter();

  static const double _mockW = 368;

  // Alturas de las dos "escenas" ancladas (px del mockup).
  static const double _topSceneH = 900; // cima + montañas + costa (arriba)
  static const double _foreH = 720; // colinas + pinos (abajo)

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final sx = w / _mockW; // escala horizontal (proporción del mockup)
    double x(double mx) => mx * sx;

    // MEDIO primero (queda detrás): cielo con nubes suaves por toda la altura.
    _skyClouds(canvas, w, h);

    // VISTA DE CIMA (arriba, absoluta) — el destino.
    _summit(canvas, x);
    _mountains(canvas, x);
    _coast(canvas, x);
    // La costa flota sobre el cielo (borde duro en y=880): se DISUELVE hacia abajo
    // con SU PROPIO color (correcto sea cual sea el degradado detrás).
    _dissolveDown(canvas, w, 858, 1010, const Color(0xFF6FC4DD));

    // PRIMER PLANO (abajo, absoluto) — donde estás. Las colinas se encuentran con
    // el cielo directamente, como en el mockup (contraste bajo → sin borde duro).
    double fg(double my) => h - _foreH + my; // Y anclada al pie (0.._foreH)
    _hills(canvas, x, fg);
    _pines(canvas, x, fg);

    _topHaze(canvas, w); // velo que funde la cima en el cielo
  }

  // ── Cielo: nubes suaves distribuidas por TODA la altura (traslúcidas) ────────
  void _skyClouds(Canvas canvas, double w, double h) {
    // Banda de cielo "climbable" entre la vista de cima y el primer plano.
    final top = _topSceneH - 120;
    final bot = h - _foreH + 60;
    if (bot <= top) return;
    // Densidad proporcional a la altura del cielo (una nube cada ~460px).
    final band = bot - top;
    final count = (band / 460).clamp(2, 40).round();
    for (var i = 0; i < count; i++) {
      // Distribución determinista (sin Math.random): dispersa en X e Y.
      final t = (i + 0.5) / count;
      final cy = top + t * band;
      final jitter = ((i * 37) % 100) / 100.0; // 0..1 pseudo-disperso estable
      final cx = w * (0.12 + 0.76 * jitter);
      final s = 0.8 + ((i * 53) % 40) / 100.0; // 0.8..1.2
      final alpha = 0.34 + ((i * 29) % 22) / 100.0; // 0.34..0.56
      _softCloud(canvas, cx, cy, s * (w / _mockW) * 1.0, alpha);
    }
  }

  void _softCloud(Canvas canvas, double cx, double cy, double s, double alpha) {
    final c = Paint()..color = Colors.white.withValues(alpha: alpha);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: 96 * s, height: 30 * s), c);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(cx + 26 * s, cy - 9 * s), width: 56 * s, height: 32 * s), c);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(cx - 24 * s, cy - 5 * s), width: 46 * s, height: 26 * s), c);
  }

  // ── Cima: halo de sol + pico nevado (px absolutos desde arriba) ─────────────
  void _summit(Canvas canvas, double Function(double) x) {
    final sun = Offset(x(184), 250);
    canvas.drawCircle(
      sun,
      x(150),
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFFFFE9A8).withValues(alpha: 0.55),
          const Color(0xFFFFE9A8).withValues(alpha: 0.0),
        ]).createShader(Rect.fromCircle(center: sun, radius: x(150))),
    );
    canvas.drawCircle(sun, x(92), Paint()..color = const Color(0xFFFFF3CC).withValues(alpha: 0.7));

    // Pico central (detrás del certificado de la cima).
    canvas.drawPath(
      Path()
        ..moveTo(x(104), 470)
        ..lineTo(x(184), 250)
        ..lineTo(x(264), 470)
        ..close(),
      Paint()..color = const Color(0xFF8676D2),
    );
    canvas.drawPath(
      Path()
        ..moveTo(x(104), 470)
        ..lineTo(x(184), 250)
        ..lineTo(x(184), 470)
        ..close(),
      Paint()..color = const Color(0xFF9486DE).withValues(alpha: 0.7),
    );
    canvas.drawPath(
      Path()
        ..moveTo(x(184), 250)
        ..lineTo(x(214), 332)
        ..lineTo(x(154), 332)
        ..close(),
      Paint()..color = Colors.white,
    );
    canvas.drawPath(
      Path()
        ..moveTo(x(184), 250)
        ..lineTo(x(184), 332)
        ..lineTo(x(154), 332)
        ..close(),
      Paint()..color = const Color(0xFFE7EDFF),
    );
  }

  // ── Cordilleras lejanas con cumbres nevadas ─────────────────────────────────
  void _mountains(Canvas canvas, double Function(double) x) {
    canvas.drawPath(
      Path()
        ..moveTo(x(0), 470)
        ..lineTo(x(46), 330)
        ..lineTo(x(96), 400)
        ..lineTo(x(150), 290)
        ..lineTo(x(210), 390)
        ..lineTo(x(262), 300)
        ..lineTo(x(312), 392)
        ..lineTo(x(368), 320)
        ..lineTo(x(368), 480)
        ..close(),
      Paint()..color = const Color(0xFF9D8FE0),
    );
    final snow = Paint()..color = Colors.white.withValues(alpha: 0.85);
    for (final p in [
      [150.0, 290.0],
      [262.0, 300.0],
    ]) {
      canvas.drawPath(
        Path()
          ..moveTo(x(p[0]), p[1])
          ..lineTo(x(p[0] + 18), p[1] + 28)
          ..lineTo(x(p[0] - 18), p[1] + 28)
          ..close(),
        snow,
      );
    }
    canvas.drawPath(
      Path()
        ..moveTo(x(0), 500)
        ..lineTo(x(60), 380)
        ..lineTo(x(120), 450)
        ..lineTo(x(180), 360)
        ..lineTo(x(250), 450)
        ..lineTo(x(300), 380)
        ..lineTo(x(368), 460)
        ..lineTo(x(368), 520)
        ..close(),
      Paint()..color = const Color(0xFFB4A8EA),
    );
  }

  // ── Región costera: mar (2 tonos) + playa + velero (arriba) ─────────────────
  void _coast(Canvas canvas, double Function(double) x) {
    canvas.drawPath(
      Path()
        ..moveTo(x(0), 700)
        ..quadraticBezierTo(x(184), 662, x(368), 700)
        ..lineTo(x(368), 880)
        ..lineTo(x(0), 880)
        ..close(),
      Paint()..color = const Color(0xFF8AD3E6),
    );
    canvas.drawPath(
      Path()
        ..moveTo(x(0), 760)
        ..quadraticBezierTo(x(120), 740, x(220), 766)
        ..quadraticBezierTo(x(300), 786, x(368), 760)
        ..lineTo(x(368), 880)
        ..lineTo(x(0), 880)
        ..close(),
      Paint()..color = const Color(0xFF6FC4DD),
    );
    canvas.drawPath(
      Path()
        ..moveTo(x(0), 700)
        ..quadraticBezierTo(x(184), 662, x(368), 700)
        ..lineTo(x(368), 724)
        ..quadraticBezierTo(x(184), 690, x(0), 724)
        ..close(),
      Paint()..color = const Color(0xFFFBE6BC),
    );
    final bx = x(250), by = 718.0;
    canvas.drawPath(
      Path()
        ..moveTo(bx, by + 14)
        ..lineTo(bx + x(26), by + 14)
        ..lineTo(bx + x(21), by + 22)
        ..lineTo(bx + x(5), by + 22)
        ..close(),
      Paint()..color = const Color(0xFFFF6B6B),
    );
    canvas.drawPath(
      Path()
        ..moveTo(bx + x(13), by + 14)
        ..lineTo(bx + x(13), by - 8)
        ..lineTo(bx + x(28), by + 12)
        ..close(),
      Paint()..color = Colors.white,
    );
  }

  // ── Primer plano: colinas suaves contiguas + pinos (ancladas al PIE) ────────
  // Coordenadas locales 0.._foreH (720) → la más alta (cresta) se funde al cielo.
  void _hills(Canvas canvas, double Function(double) x, double Function(double) fg) {
    void hill(double crest, double q1, double mid, double q2, double end, Color color) {
      canvas.drawPath(
        Path()
          ..moveTo(x(0), fg(crest))
          ..quadraticBezierTo(x(92), fg(q1), x(200), fg(mid))
          ..quadraticBezierTo(x(300), fg(q2), x(368), fg(end))
          ..lineTo(x(368), fg(_foreH))
          ..lineTo(x(0), fg(_foreH))
          ..close(),
        Paint()..color = color,
      );
    }

    // Ramp de verdes de pasos SUAVES (contraste bajo → colinas que se funden).
    hill(150, 90, 140, 200, 120, const Color(0xFFAEE6C2));
    hill(280, 210, 270, 330, 250, const Color(0xFF93DDAE));
    hill(420, 350, 410, 470, 400, const Color(0xFF77D19A));
    hill(560, 500, 560, 610, 560, const Color(0xFF5DC386));
  }

  void _pines(Canvas canvas, double Function(double) x, double Function(double) fg) {
    _pine(canvas, Offset(x(40), fg(300)), x(16));
    _pine(canvas, Offset(x(322), fg(268)), x(15));
    _pine(canvas, Offset(x(70), fg(440)), x(19));
    _pine(canvas, Offset(x(300), fg(410)), x(18));
    _pine(canvas, Offset(x(160), fg(500)), x(17));
    _pine(canvas, Offset(x(36), fg(560)), x(21));
    _pine(canvas, Offset(x(330), fg(580)), x(20));
    _pine(canvas, Offset(x(210), fg(620)), x(19));
  }

  void _pine(Canvas canvas, Offset base, double s) {
    canvas.drawRect(
      Rect.fromLTWH(base.dx - 2, base.dy, 4, s * 0.6),
      Paint()..color = const Color(0xFF7A4B28),
    );
    canvas.drawPath(
      Path()
        ..moveTo(base.dx, base.dy - s)
        ..lineTo(base.dx + s, base.dy + s * 0.5)
        ..lineTo(base.dx - s, base.dy + s * 0.5)
        ..close(),
      Paint()..color = const Color(0xFF1F9457),
    );
    canvas.drawPath(
      Path()
        ..moveTo(base.dx, base.dy - s * 0.55)
        ..lineTo(base.dx + s * 0.85, base.dy + s * 0.7)
        ..lineTo(base.dx - s * 0.85, base.dy + s * 0.7)
        ..close(),
      Paint()..color = const Color(0xFF2BA866),
    );
  }

  // ── Disuelve el borde de una escena hacia ABAJO con su propio color ─────────
  // (opaco arriba → transparente abajo). Independiente del fondo: nunca ensucia.
  void _dissolveDown(Canvas canvas, double w, double top, double bottom, Color color) {
    final rect = Rect.fromLTWH(0, top, w, bottom - top);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.7), color.withValues(alpha: 0.0)],
        ).createShader(rect),
    );
  }

  // ── Velo superior: funde la cima/montañas en el cielo (mockup: fadeUp) ──────
  void _topHaze(Canvas canvas, double w) {
    final rect = Rect.fromLTWH(0, 0, w, 560);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x59DCE1F5), Color(0x00DCE1F5)],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant SceneryPainter oldDelegate) => false;
}
