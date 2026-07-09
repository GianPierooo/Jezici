import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/features/learn/widgets/scenery_painter.dart';

/// El fondo del mapa (Aprender v2.dc) se ancla en px absolutos (cima arriba /
/// colinas+ciudad abajo) y debe pintar sin excepción a CUALQUIER altura — corto,
/// típico y muy largo — sin franjas flotantes (fix del "fondo en franjas").
void main() {
  test('SceneryPainter pinta sin excepción a distintas alturas', () {
    for (final h in [800.0, 1500.0, 2600.0, 5200.0]) {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      SceneryPainter().paint(canvas, Size(390, h));
      recorder.endRecording().dispose();
    }
  });
}
