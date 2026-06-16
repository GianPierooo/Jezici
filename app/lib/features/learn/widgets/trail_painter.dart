import 'package:flutter/material.dart';

/// Dibuja el sendero serpenteante que conecta los nodos (estilo "camino/viaje",
/// NO una lista vertical plana). Recibe los centros de nodo ordenados de abajo
/// hacia arriba y traza curvas S suaves entre ellos, con relieve de carretera.
class TrailPainter extends CustomPainter {
  TrailPainter(this.points);

  final List<Offset> points;

  Path _buildPath() {
    final path = Path();
    if (points.isEmpty) return path;
    path.moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final p0 = points[i - 1];
      final p1 = points[i];
      final midY = (p0.dy + p1.dy) / 2;
      // Manijas de control verticales -> curva S horizontal entre nodos alternos.
      path.cubicTo(p0.dx, midY, p1.dx, midY, p1.dx, p1.dy);
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final path = _buildPath();

    final road = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = const Color(0xFFE4C79A)
      ..strokeWidth = 34;
    final inner = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = const Color(0xFFFFF3DE)
      ..strokeWidth = 24;

    canvas.drawPath(path, road);
    canvas.drawPath(path, inner);

    // Línea punteada central (sensación de ruta).
    final dash = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFD9B483)
      ..strokeWidth = 4;
    for (final metric in path.computeMetrics()) {
      double dist = 0;
      const dashLen = 2.0;
      const gap = 16.0;
      while (dist < metric.length) {
        final seg = metric.extractPath(dist, dist + dashLen);
        canvas.drawPath(seg, dash);
        dist += dashLen + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant TrailPainter oldDelegate) =>
      oldDelegate.points != points;
}
