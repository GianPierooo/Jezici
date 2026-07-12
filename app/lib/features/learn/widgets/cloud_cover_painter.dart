import 'dart:math' as math;

import 'package:flutter/material.dart';

/// NUBES de progreso (fog-of-war, decisión de Gian): cubren la región del mapa
/// que el usuario AÚN NO alcanzó — desde justo encima de la frontera de avance
/// hasta debajo de la cima (el certificado queda visible como meta aspiracional).
/// Doble beneficio: intriga ("se despeja al avanzar") y RENDIMIENTO (los nodos y
/// el sendero tapados NO se construyen/pintan — ver learn_map_screen/TrailPainter).
///
/// Estilo coherente con la escenografía: masas blancas suaves con tinte lavanda,
/// borde inferior de "pompones" deterministas y desvanecido suave en ambos bordes.
/// Culling propio (scroll-driven), como los demás painters del mapa.
class CloudCoverPainter extends CustomPainter {
  CloudCoverPainter({
    required this.topY,
    required this.bottomY,
    this.scroll,
    this.viewH = 0,
    this.debugScrollTop,
  }) : super(repaint: scroll);

  /// Banda cubierta [topY, bottomY] en coordenadas de contenido.
  final double topY;
  final double bottomY;
  final ScrollController? scroll;
  final double viewH;
  final double? debugScrollTop;

  double get _scrollTop =>
      debugScrollTop ?? ((scroll?.hasClients ?? false) ? scroll!.offset : 0);

  @override
  void paint(Canvas canvas, Size size) {
    if (bottomY <= topY) return; // sin nubes (curso casi completo)
    // Culling: solo si la banda de nubes intersecta el viewport.
    const margin = 300.0;
    final double vTop = viewH > 0 ? _scrollTop - margin : 0;
    final double vBot = viewH > 0 ? _scrollTop + viewH + margin : size.height;
    if (bottomY < vTop || topY > vBot) return;

    final w = size.width;
    // Recorta el trabajo a la intersección banda∩viewport.
    final paintTop = math.max(topY, vTop);
    final paintBot = math.min(bottomY, vBot);

    // 1) Manto base: gradiente blanco→lavanda muy suave, casi opaco (lo que hay
    //    debajo no se ve — y de hecho no se pinta).
    final base = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xF2FFFFFF), Color(0xF5F4F1FE), Color(0xF2FFFFFF)],
      ).createShader(Rect.fromLTRB(0, topY, w, bottomY));
    canvas.drawRect(Rect.fromLTRB(0, paintTop, w, paintBot), base);

    // 2) Textura interior: óvalos suaves deterministas (profundidad), solo los
    //    que caen en la ventana visible.
    final puffIn = Paint()..color = const Color(0x59E4DEF7);
    final bandH = bottomY - topY;
    final rows = (bandH / 260).ceil().clamp(1, 200);
    for (var r = 0; r < rows; r++) {
      final y = topY + 120 + r * 260.0;
      if (y < paintTop - 160 || y > paintBot + 160) continue;
      final seed = r * 37 % 100;
      final cx = w * (0.15 + (seed % 7) * 0.11);
      canvas.drawOval(
          Rect.fromCenter(center: Offset(cx, y), width: w * 0.62, height: 96), puffIn);
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(w - cx, y + 130), width: w * 0.5, height: 80),
          Paint()..color = const Color(0x40E9E4FA));
    }

    // 3) Borde INFERIOR: pompones blancos que muerden hacia abajo + fade suave —
    //    la frontera "se despeja" aquí cuando avanzas.
    if (bottomY >= vTop - 160 && bottomY <= vBot + 160) {
      final pom = Paint()..color = const Color(0xF7FFFFFF);
      final pomSoft = Paint()..color = const Color(0x66FFFFFF);
      var x = 0.0;
      var k = 0;
      while (x < w + 60) {
        final rr = 34.0 + (k * 29 % 23); // radios deterministas 34..56
        final dy = (k * 17 % 3) * 10.0 - 8;
        canvas.drawCircle(Offset(x, bottomY + dy), rr, pom);
        canvas.drawCircle(Offset(x + rr * 0.5, bottomY + dy + rr * 0.55), rr * 0.66, pomSoft);
        x += rr * 1.15;
        k++;
      }
      // Velo que se disuelve hacia el mapa visible (sin borde duro).
      final fade = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xAAFFFFFF), Color(0x00FFFFFF)],
        ).createShader(Rect.fromLTRB(0, bottomY + 20, w, bottomY + 110));
      canvas.drawRect(Rect.fromLTRB(0, bottomY + 20, w, bottomY + 110), fade);
    }

    // 4) Borde SUPERIOR: disolución hacia la cima (el certificado respira arriba).
    if (topY >= vTop - 140 && topY <= vBot + 140) {
      final fadeUp = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x00FFFFFF), Color(0xF2FFFFFF)],
        ).createShader(Rect.fromLTRB(0, topY - 90, w, topY + 30));
      canvas.drawRect(Rect.fromLTRB(0, topY - 90, w, topY + 30), fadeUp);
      // borra el manto por encima del fade (deja ver la cima)
    }
  }

  @override
  bool shouldRepaint(covariant CloudCoverPainter old) =>
      old.topY != topY ||
      old.bottomY != bottomY ||
      old.viewH != viewH ||
      old.scroll != scroll;
}
