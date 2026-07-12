import 'package:flutter/material.dart';

/// Dibuja el sendero serpenteante que conecta los nodos (estilo "camino/viaje",
/// NO una lista vertical plana). Recibe los centros de nodo ordenados de abajo
/// hacia arriba y traza curvas S suaves entre ellos, con relieve de carretera.
///
/// RENDIMIENTO (viewport culling): los mapas son MUY altos (5.000–23.000px). El
/// bucle de guiones (`computeMetrics` + `extractPath`) recorría TODO el sendero
/// en cada frame → ~1500 segmentos a 27.000px, re-ejecutado cada frame de scroll
/// y cada frame de animación (mascota/pulso comparten capa). Ahora se pinta SOLO
/// el tramo VISIBLE (offset del scroll ± margen): el path se construye solo con
/// los nodos de la ventana + 1 vecino a cada lado, y los guiones se limitan a esa
/// banda. Se repinta cuando el scroll cambia (`repaint: scroll`), no cuando la
/// mascota anima. Visualmente IDÉNTICO (mismos trazos, mismo camino).
class TrailPainter extends CustomPainter {
  TrailPainter(this.points,
      {this.scroll, this.viewH = 0, this.debugScrollTop, this.topCutY})
      : super(repaint: scroll);

  final List<Offset> points;
  final ScrollController? scroll;
  final double viewH;

  /// Solo tests (medir la ruta con culling sin un ScrollController real).
  final double? debugScrollTop;

  /// Nubes (fog-of-war): el sendero NO se dibuja por encima de esta y — lo
  /// tapado por nubes ni se construye ni se rasteriza (perf + intriga).
  final double? topCutY;

  double get _scrollTop =>
      debugScrollTop ?? ((scroll?.hasClients ?? false) ? scroll!.offset : 0);

  /// Construye el path solo entre los índices [lo..hi] (inclusive), con las
  /// mismas curvas S que el original (curva desde el nodo anterior).
  Path _buildPath(int lo, int hi) {
    final path = Path();
    path.moveTo(points[lo].dx, points[lo].dy);
    for (var i = lo + 1; i <= hi; i++) {
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

    // Banda visible en coordenadas de contenido (con margen para el borde).
    // El corte de NUBES (topCutY) recorta la banda por arriba: el sendero
    // tapado por nubes ni se construye.
    const margin = 500.0;
    double bandTop = viewH > 0 ? _scrollTop - margin : 0;
    final double bandBot = viewH > 0 ? _scrollTop + viewH + margin : size.height;
    if (topCutY != null && topCutY! > bandTop) bandTop = topCutY!;
    if (bandTop >= bandBot) return; // todo tapado por nubes en esta ventana

    // Índices de nodos dentro de la banda (+1 vecino a cada lado para continuidad
    // de la curva). Los puntos vienen ordenados de ABAJO (dy grande) hacia ARRIBA
    // (dy pequeño), así que buscamos por rango de dy sin asumir dirección.
    var lo = points.length, hi = -1;
    for (var i = 0; i < points.length; i++) {
      final y = points[i].dy;
      if (y >= bandTop && y <= bandBot) {
        if (i < lo) lo = i;
        if (i > hi) hi = i;
      }
    }
    if (hi < 0) return; // nada del sendero en la ventana → no pinta
    lo = (lo - 1).clamp(0, points.length - 1);
    hi = (hi + 1).clamp(0, points.length - 1);
    if (hi - lo < 1) return;
    final path = _buildPath(lo, hi);

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
      oldDelegate.points != points ||
      oldDelegate.viewH != viewH ||
      oldDelegate.scroll != scroll ||
      oldDelegate.topCutY != topCutY;
}
