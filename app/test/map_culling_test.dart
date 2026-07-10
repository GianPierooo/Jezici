import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/features/learn/widgets/scenery_painter.dart';
import 'package:jezici/features/learn/widgets/trail_painter.dart';

/// VIEWPORT CULLING del mapa (fix de lag): en mapas MUY altos (27.000px), pintar
/// solo el tramo visible reduce drásticamente el costo por frame. Verifica que
/// (a) los painters pintan sin excepción a gran altura con y sin culling, y
/// (b) con culling el trabajo de trazado es mucho menor que pintándolo todo.
void main() {
  const w = 400.0, h = 27000.0, viewH = 820.0, nodes = 180;
  final points = <Offset>[
    for (var i = 0; i < nodes; i++) Offset(w * (i.isEven ? 0.3 : 0.7), h - 200 - i * 150.0),
    const Offset(w * 0.5, 140),
  ];

  double timePaint(void Function(Canvas) draw) {
    for (var i = 0; i < 2; i++) {
      final r = ui.PictureRecorder();
      draw(Canvas(r));
      r.endRecording();
    }
    final sw = Stopwatch()..start();
    for (var i = 0; i < 20; i++) {
      final r = ui.PictureRecorder();
      draw(Canvas(r));
      r.endRecording();
    }
    sw.stop();
    return sw.elapsedMicroseconds / 20 / 1000.0;
  }

  test('scenery+trail pintan sin excepción a 27000px (con y sin culling)', () {
    expect(() => SceneryPainter().paint(Canvas(ui.PictureRecorder()), const Size(w, h)),
        returnsNormally);
    expect(
        () => SceneryPainter(viewH: viewH, debugScrollTop: h / 2)
            .paint(Canvas(ui.PictureRecorder()), const Size(w, h)),
        returnsNormally);
    expect(() => TrailPainter(points).paint(Canvas(ui.PictureRecorder()), const Size(w, h)),
        returnsNormally);
    expect(
        () => TrailPainter(points, viewH: viewH, debugScrollTop: h / 2)
            .paint(Canvas(ui.PictureRecorder()), const Size(w, h)),
        returnsNormally);
  });

  test('el culling reduce el costo de trazado del sendero >50%', () {
    final full = timePaint((c) => TrailPainter(points).paint(c, const Size(w, h)));
    final culled = timePaint(
        (c) => TrailPainter(points, viewH: viewH, debugScrollTop: h / 2).paint(c, const Size(w, h)));
    expect(culled, lessThan(full * 0.5),
        reason: 'culled=$culled ms vs full=$full ms (esperado <50%)');
  });
}
