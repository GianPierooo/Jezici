import 'package:flutter/material.dart';

/// Escenografía del mapa (Aprender v2.dc), portada 1:1 del SVG del mockup.
///
/// CLAVE (fix del "fondo en franjas"): el mockup pinta la escena sobre un lienzo
/// de altura FIJA (368×1860) con set-pieces en píxeles absolutos. La versión vieja
/// los posicionaba por FRACCIÓN de la altura del contenido (variable: 2500–5000px
/// en mapas largos), así que las bandas (mar, montañas) se separaban con enormes
/// huecos de degradado plano → parecían franjas sueltas y chocantes.
///
/// Ahora: la escenografía LEJANA (sol, montañas, nubes, costa) se ancla ARRIBA en
/// px absolutos (el horizonte/destino, siempre en la cima del viaje) y el PRIMER
/// PLANO (colinas, pinos, ciudad) se ancla ABAJO en px absolutos (donde estás). El
/// MEDIO es puro degradado (cielo) → mapa cohesivo a cualquier altura, sin franjas.
/// Full-bleed: escala en X por la proporción del mockup (llena el ancho en desktop);
/// la columna de nodos se centra aparte (dx0). Estático (sin coste de animación).
class SceneryPainter extends CustomPainter {
  SceneryPainter();

  static const double _mockW = 368;
  static const double _mockH = 1860;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final sx = w / _mockW; // escala horizontal (proporción del mockup)
    double x(double mx) => mx * sx; // X del mockup → X real
    double bottom(double my) => h - _mockH + my; // Y anclada al PIE

    _summit(canvas, x); // sol + pico (arriba, absoluto)
    _mountains(canvas, x); // cordilleras lejanas (arriba)
    _clouds(canvas, x, w, h); // nubes (arriba + algunas en el cielo medio)
    _coast(canvas, x); // mar + playa + velero (arriba, bajo las montañas)
    _hills(canvas, x, bottom, w); // colinas (abajo, contiguas hasta el pie)
    _pines(canvas, x, bottom); // pinos sobre las colinas (paisaje limpio en el pie)
    // NOTA: la "ciudad" (edificios verticales) se ELIMINÓ — en el pie de un mapa
    // alto se veía como FRANJAS VERTICALES moradas/coral sobre el verde (no un
    // paisaje). Un paisaje de colinas + pinos + degradado es limpio y cohesivo a
    // cualquier altura (guía de la misión: "mejor limpio y bonito que roto").
    _topHaze(canvas, w, h); // velo suave que funde la cima en el cielo
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
    // Lado sombreado.
    canvas.drawPath(
      Path()
        ..moveTo(x(104), 470)
        ..lineTo(x(184), 250)
        ..lineTo(x(184), 470)
        ..close(),
      Paint()..color = const Color(0xFF9486DE).withValues(alpha: 0.7),
    );
    // Nieve de la cumbre.
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
    // Fondo.
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
    // Cumbres nevadas.
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
    // Cordillera frontal, más clara.
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

  // ── Nubes: las del mockup (arriba) + un par en el cielo medio (mapas largos) ─
  void _clouds(Canvas canvas, double Function(double) x, double w, double h) {
    final c = Paint()..color = Colors.white.withValues(alpha: 0.88);
    void cloud(double cx, double cy, double s) {
      canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: 80 * s, height: 30 * s), c);
      canvas.drawOval(Rect.fromCenter(center: Offset(cx + 24 * s, cy - 8 * s), width: 50 * s, height: 32 * s), c);
    }

    cloud(x(80), 424, 1.0);
    cloud(x(288), 388, 0.95);
    cloud(x(186), 540, 0.8);
    // Nubes suaves en el cielo intermedio para que un viaje largo no quede vacío
    // (semitransparentes → nunca se leen como franjas duras).
    final soft = Paint()..color = Colors.white.withValues(alpha: 0.5);
    void softCloud(double cx, double cy, double s) {
      canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: 90 * s, height: 30 * s), soft);
      canvas.drawOval(Rect.fromCenter(center: Offset(cx + 26 * s, cy - 8 * s), width: 54 * s, height: 30 * s), soft);
    }

    // Solo si hay cielo medio de sobra (mapa alto) para no ensuciar mapas cortos.
    if (h > 2200) {
      softCloud(w * 0.24, h * 0.42, 1.0);
      softCloud(w * 0.74, h * 0.52, 0.9);
      softCloud(w * 0.40, h * 0.62, 0.85);
    }
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
    // Playa (borde superior del mar).
    canvas.drawPath(
      Path()
        ..moveTo(x(0), 700)
        ..quadraticBezierTo(x(184), 662, x(368), 700)
        ..lineTo(x(368), 724)
        ..quadraticBezierTo(x(184), 690, x(0), 724)
        ..close(),
      Paint()..color = const Color(0xFFFBE6BC),
    );
    // Velero.
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

  // ── Colinas: 5 capas contiguas que suben desde el PIE (anti-hueco) ──────────
  void _hills(Canvas canvas, double Function(double) x, double Function(double) bottom, double w) {
    void hill(double my, double q1y, double m2y, double q2y, double m3y, Color color) {
      // Réplica de las curvas del mockup: cresta ondulada que baja al pie.
      final top = bottom(my);
      canvas.drawPath(
        Path()
          ..moveTo(x(0), top)
          ..quadraticBezierTo(x(92), bottom(q1y), x(200), bottom(m2y))
          ..quadraticBezierTo(x(300), bottom(q2y), x(368), bottom(m3y))
          ..lineTo(x(368), bottom(1860))
          ..lineTo(x(0), bottom(1860))
          ..close(),
        Paint()..color = color,
      );
    }

    // Ramp verde de pasos SUAVES (contraste bajo entre capas → colinas que se
    // funden, sin bandas duras). Capa clara arriba para mezclar con el cielo.
    hill(870, 800, 858, 906, 840, const Color(0xFFAEE6C2));
    hill(1010, 928, 990, 1044, 968, const Color(0xFF93DDAE));
    hill(1150, 1078, 1140, 1184, 1120, const Color(0xFF77D19A));
    hill(1310, 1244, 1310, 1356, 1300, const Color(0xFF5DC386));
    hill(1500, 1448, 1512, 1548, 1500, const Color(0xFF48B474));
  }

  void _pines(Canvas canvas, double Function(double) x, double Function(double) bottom) {
    _pine(canvas, Offset(x(40), bottom(1108)), x(15));
    _pine(canvas, Offset(x(322), bottom(1066)), x(14));
    _pine(canvas, Offset(x(64), bottom(1268)), x(18));
    _pine(canvas, Offset(x(310), bottom(1238)), x(17));
    _pine(canvas, Offset(x(36), bottom(1420)), x(19));
    // Bosque más denso hacia el PIE (donde antes iban los edificios) → base viva.
    _pine(canvas, Offset(x(300), bottom(1470)), x(20));
    _pine(canvas, Offset(x(70), bottom(1620)), x(22));
    _pine(canvas, Offset(x(200), bottom(1560)), x(18));
    _pine(canvas, Offset(x(330), bottom(1660)), x(21));
    _pine(canvas, Offset(x(150), bottom(1720)), x(19));
    _pine(canvas, Offset(x(28), bottom(1770)), x(23));
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

  // ── Velo superior: funde la cima/montañas en el cielo (mockup: fadeUp) ──────
  void _topHaze(Canvas canvas, double w, double h) {
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
