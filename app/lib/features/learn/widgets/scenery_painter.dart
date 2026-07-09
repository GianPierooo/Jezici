import 'package:flutter/material.dart';

/// Escenografía del mapa (Aprender.dc): el "viaje" de abajo (la CIUDAD/trabajo,
/// donde estás) hacia arriba (la COSTA, las COLINAS con pinos y la CIMA con
/// montañas nevadas y nubes). Full-bleed: pinta todo el ancho; la columna de
/// nodos se centra aparte (ResponsiveCenter/dx0). Posiciona los set-pieces por
/// FRACCIÓN de la altura total, así el mapa "evoluciona" al desplazarse sin
/// importar cuántas unidades tenga. Estático (sin coste de animación).
class SceneryPainter extends CustomPainter {
  SceneryPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    _summit(canvas, w, h);
    _mountains(canvas, w, h);
    _clouds(canvas, w, h);
    _coast(canvas, w, h);
    _hills(canvas, w, h);
    _pines(canvas, w, h);
    _city(canvas, w, h); // al final: en primer plano sobre las colinas de la base
  }

  // ── Cima: sol + pico nevado ────────────────────────────────────────────────
  void _summit(Canvas canvas, double w, double h) {
    final sunCenter = Offset(w * 0.5, h * 0.085);
    canvas.drawCircle(
      sunCenter,
      w * 0.55,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFFFFE9A8).withValues(alpha: 0.6),
          const Color(0xFFFFE9A8).withValues(alpha: 0.0),
        ]).createShader(Rect.fromCircle(center: sunCenter, radius: w * 0.55)),
    );
    canvas.drawCircle(sunCenter, w * 0.17, Paint()..color = const Color(0xFFFFF3CC).withValues(alpha: 0.7));

    // Pico central de la cima (detrás del certificado).
    final peakTop = h * 0.055;
    final peakBase = h * 0.155;
    final peak = Path()
      ..moveTo(w * 0.5, peakTop)
      ..lineTo(w * 0.72, peakBase)
      ..lineTo(w * 0.28, peakBase)
      ..close();
    canvas.drawPath(peak, Paint()..color = const Color(0xFF8676D2));
    final snow = Path()
      ..moveTo(w * 0.5, peakTop)
      ..lineTo(w * 0.565, peakTop + (peakBase - peakTop) * 0.42)
      ..lineTo(w * 0.435, peakTop + (peakBase - peakTop) * 0.42)
      ..close();
    canvas.drawPath(snow, Paint()..color = Colors.white);
  }

  // ── Montañas lejanas (bajo la cima) con cumbres nevadas ────────────────────
  void _mountains(Canvas canvas, double w, double h) {
    final t = h * 0.17; // línea base de la cordillera
    final back = Path()
      ..moveTo(0, t)
      ..lineTo(w * 0.13, t - 42)
      ..lineTo(w * 0.26, t - 6)
      ..lineTo(w * 0.41, t - 52)
      ..lineTo(w * 0.57, t - 8)
      ..lineTo(w * 0.71, t - 48)
      ..lineTo(w * 0.85, t - 6)
      ..lineTo(w, t - 40)
      ..lineTo(w, t + 40)
      ..lineTo(0, t + 40)
      ..close();
    canvas.drawPath(back, Paint()..color = const Color(0xFF9D8FE0));
    // Cumbres nevadas.
    final snow = Paint()..color = Colors.white.withValues(alpha: 0.85);
    for (final peak in [
      [w * 0.41, t - 52],
      [w * 0.71, t - 48],
    ]) {
      final p = Path()
        ..moveTo(peak[0], peak[1])
        ..lineTo(peak[0] + 11, peak[1] + 17)
        ..lineTo(peak[0] - 11, peak[1] + 17)
        ..close();
      canvas.drawPath(p, snow);
    }
    // Segunda cordillera, más clara.
    final t2 = h * 0.195;
    final front = Path()
      ..moveTo(0, t2)
      ..lineTo(w * 0.16, t2 - 34)
      ..lineTo(w * 0.33, t2 + 2)
      ..lineTo(w * 0.49, t2 - 30)
      ..lineTo(w * 0.68, t2 + 2)
      ..lineTo(w * 0.82, t2 - 28)
      ..lineTo(w, t2 - 6)
      ..lineTo(w, t2 + 40)
      ..lineTo(0, t2 + 40)
      ..close();
    canvas.drawPath(front, Paint()..color = const Color(0xFFB4A8EA));
  }

  void _clouds(Canvas canvas, double w, double h) {
    final c = Paint()..color = Colors.white.withValues(alpha: 0.88);
    void cloud(double x, double y, double s) {
      canvas.drawOval(Rect.fromCenter(center: Offset(x, y), width: 80 * s, height: 30 * s), c);
      canvas.drawOval(Rect.fromCenter(center: Offset(x + 26 * s, y - 8 * s), width: 52 * s, height: 32 * s), c);
    }

    cloud(w * 0.20, h * 0.145, 1.0);
    cloud(w * 0.80, h * 0.125, 0.9);
    cloud(w * 0.50, h * 0.235, 0.85);
  }

  // ── Región costera: mar, playa y velero ────────────────────────────────────
  void _coast(Canvas canvas, double w, double h) {
    final top = h * 0.34;
    final bot = h * 0.44;
    // Mar (2 tonos).
    final sea = Path()
      ..moveTo(0, top)
      ..quadraticBezierTo(w * 0.5, top - 22, w, top)
      ..lineTo(w, bot)
      ..lineTo(0, bot)
      ..close();
    canvas.drawPath(sea, Paint()..color = const Color(0xFF8AD3E6));
    final sea2 = Path()
      ..moveTo(0, top + 34)
      ..quadraticBezierTo(w * 0.33, top + 22, w * 0.6, top + 40)
      ..quadraticBezierTo(w * 0.82, top + 52, w, top + 34)
      ..lineTo(w, bot)
      ..lineTo(0, bot)
      ..close();
    canvas.drawPath(sea2, Paint()..color = const Color(0xFF6FC4DD));
    // Franja de playa (arriba del mar).
    final beach = Path()
      ..moveTo(0, top)
      ..quadraticBezierTo(w * 0.5, top - 22, w, top)
      ..lineTo(w, top + 14)
      ..quadraticBezierTo(w * 0.5, top - 8, 0, top + 14)
      ..close();
    canvas.drawPath(beach, Paint()..color = const Color(0xFFFBE6BC));
    // Velero.
    final bx = w * 0.66, by = top + 12;
    canvas.drawPath(
      Path()
        ..moveTo(bx, by + 14)
        ..lineTo(bx + 26, by + 14)
        ..lineTo(bx + 21, by + 22)
        ..lineTo(bx + 5, by + 22)
        ..close(),
      Paint()..color = const Color(0xFFFF6B6B),
    );
    canvas.drawPath(
      Path()
        ..moveTo(bx + 13, by + 14)
        ..lineTo(bx + 13, by - 8)
        ..lineTo(bx + 28, by + 12)
        ..close(),
      Paint()..color = Colors.white,
    );
  }

  // ── Colinas verdes (varias capas, media→base) ──────────────────────────────
  void _hills(Canvas canvas, double w, double h) {
    _hill(canvas, w, h, 0.52, const Color(0xFFA6E4BC));
    _hill(canvas, w, h, 0.62, const Color(0xFF86DBA3));
    _hill(canvas, w, h, 0.72, const Color(0xFF56CC88));
    _hill(canvas, w, h, 0.82, const Color(0xFF37BB70));
    _hill(canvas, w, h, 0.92, const Color(0xFF27A45F));
  }

  void _hill(Canvas canvas, double w, double h, double topFrac, Color color) {
    final top = h * topFrac;
    final path = Path()
      ..moveTo(0, top + 36)
      ..quadraticBezierTo(w * 0.30, top - 28, w * 0.55, top + 8)
      ..quadraticBezierTo(w * 0.80, top + 40, w, top - 8)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _pines(Canvas canvas, double w, double h) {
    _pine(canvas, Offset(w * 0.11, h * 0.60), 15);
    _pine(canvas, Offset(w * 0.87, h * 0.585), 14);
    _pine(canvas, Offset(w * 0.17, h * 0.70), 18);
    _pine(canvas, Offset(w * 0.84, h * 0.71), 17);
    _pine(canvas, Offset(w * 0.10, h * 0.80), 19);
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

  // ── Ciudad / distrito laboral (la base: donde empieza el viaje) ─────────────
  void _city(Canvas canvas, double w, double h) {
    final base = h; // los edificios asientan en el borde inferior
    void building(double x, double topFrac, double bw, Color color) {
      final top = h * topFrac;
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTRB(x, top, x + bw, base), const Radius.circular(6)),
        Paint()..color = color,
      );
    }

    // Torres (fracciones desde arriba; el borde inferior = base).
    building(w * 0.015, 0.955, w * 0.14, const Color(0xFF7E6FE6));
    building(w * 0.16, 0.94, w * 0.12, const Color(0xFF6C5CE7));
    building(w * 0.70, 0.945, w * 0.15, const Color(0xFF7E6FE6));
    building(w * 0.62, 0.96, w * 0.11, const Color(0xFF6155C9));
    building(w * 0.80, 0.965, w * 0.10, const Color(0xFFFF8585));

    // Ventanas iluminadas.
    final win = Paint()..color = const Color(0xFFFFE08A);
    void windows(double x0, double topFrac, int cols, int rows) {
      final top = h * topFrac;
      for (var r = 0; r < rows; r++) {
        for (var col = 0; col < cols; col++) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(x0 + col * 16, top + r * 22, 9, 11),
              const Radius.circular(2),
            ),
            win,
          );
        }
      }
    }

    windows(w * 0.04, 0.962, 2, 3);
    windows(w * 0.185, 0.95, 2, 3);
    windows(w * 0.73, 0.955, 2, 3);
  }

  @override
  bool shouldRepaint(covariant SceneryPainter oldDelegate) => false;
}
