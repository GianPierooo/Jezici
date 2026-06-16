import 'package:flutter/material.dart';

/// Escenografía del mapa (cielo→cima): resplandor del sol arriba, pico de la
/// cima, y colinas verdes ascendentes hacia abajo. Evoca el "viaje a la cima"
/// sin recargar (versión simplificada del mockup Aprender).
class SceneryPainter extends CustomPainter {
  SceneryPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Resplandor del sol (cerca de la cima).
    final sunCenter = Offset(w * 0.5, h * 0.10);
    final sunGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFE9A8).withValues(alpha: 0.65),
          const Color(0xFFFFE9A8).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: sunCenter, radius: w * 0.55));
    canvas.drawCircle(sunCenter, w * 0.55, sunGlow);
    canvas.drawCircle(
      sunCenter,
      w * 0.18,
      Paint()..color = const Color(0xFFFFF3CC).withValues(alpha: 0.75),
    );

    // Pico de la cima.
    final peak = Path()
      ..moveTo(w * 0.5, h * 0.06)
      ..lineTo(w * 0.78, h * 0.20)
      ..lineTo(w * 0.22, h * 0.20)
      ..close();
    canvas.drawPath(peak, Paint()..color = const Color(0xFF8676D2));
    final snow = Path()
      ..moveTo(w * 0.5, h * 0.06)
      ..lineTo(w * 0.58, h * 0.105)
      ..lineTo(w * 0.42, h * 0.105)
      ..close();
    canvas.drawPath(snow, Paint()..color = Colors.white);

    // Colinas verdes ascendentes (de abajo hacia el medio).
    _hill(canvas, w, h, 0.62, const Color(0xFF86DBA3));
    _hill(canvas, w, h, 0.72, const Color(0xFF56CC88));
    _hill(canvas, w, h, 0.83, const Color(0xFF37BB70));
    _hill(canvas, w, h, 0.93, const Color(0xFF27A45F));

    // Un par de pinos.
    _pine(canvas, Offset(w * 0.12, h * 0.74), 16);
    _pine(canvas, Offset(w * 0.86, h * 0.80), 14);
    _pine(canvas, Offset(w * 0.18, h * 0.88), 18);
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

  void _pine(Canvas canvas, Offset base, double s) {
    canvas.drawRect(
      Rect.fromLTWH(base.dx - 2, base.dy, 4, s * 0.6),
      Paint()..color = const Color(0xFF7A4B28),
    );
    final tree = Path()
      ..moveTo(base.dx, base.dy - s)
      ..lineTo(base.dx + s, base.dy + s * 0.5)
      ..lineTo(base.dx - s, base.dy + s * 0.5)
      ..close();
    canvas.drawPath(tree, Paint()..color = const Color(0xFF2BA866));
  }

  @override
  bool shouldRepaint(covariant SceneryPainter oldDelegate) => false;
}
