import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/data/models/lesson_model.dart';
import 'package:jezici/features/learn/widgets/checkpoint_portal.dart';
import 'package:jezici/features/learn/widgets/map_node.dart';
import 'package:jezici/features/learn/widgets/scenery_painter.dart';

/// Aprender.dc: el checkpoint es un PORTAL, el nodo disponible tiene ANILLO de
/// progreso, y la escenografía pinta las regiones. Bloquea que rindan sin error.
void main() {
  Widget wrap(Widget child, {bool reduce = true}) => MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: reduce),
          child: Scaffold(body: Center(child: child)),
        ),
      );

  testWidgets('Portal de examen rinde en disponible y bloqueado', (tester) async {
    await tester.pumpWidget(wrap(Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        CheckpointPortal(state: NodeState.available),
        CheckpointPortal(state: NodeState.locked),
      ],
    )));
    await tester.pump();
    // Los dos portales pintan (CustomPaint del arco).
    expect(find.byType(CheckpointPortal), findsNWidgets(2));
    expect(find.byType(CustomPaint), findsWidgets);
    // El bloqueado muestra candado.
    expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
  });

  testWidgets('Nodo disponible dibuja anillo de progreso', (tester) async {
    await tester.pumpWidget(wrap(const MapNode(
      type: LessonType.lesson,
      state: NodeState.available,
      progress: 0.5,
    )));
    await tester.pump();
    expect(find.byType(MapNode), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets); // incluye el _ProgressRing
  });

  testWidgets('SceneryPainter pinta sin excepción', (tester) async {
    await tester.pumpWidget(wrap(
      CustomPaint(size: const Size(368, 1860), painter: SceneryPainter()),
    ));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
