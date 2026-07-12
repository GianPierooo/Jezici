import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/data/models/lesson_model.dart';
import 'package:jezici/data/models/unit_model.dart';
import 'package:jezici/data/providers.dart';
import 'package:jezici/features/learn/learn_map_screen.dart';
import 'package:jezici/features/learn/widgets/cloud_cover_painter.dart';
import 'package:jezici/features/learn/widgets/map_node.dart';
import 'package:jezici/l10n/app_localizations.dart';

/// PERF 2ª pasada del mapa: (a) VENTANA de widgets — solo se CONSTRUYEN los
/// nodos visibles (no ~500 Positioned/185 capas para todo el curso: 19,5→5,1
/// ms/frame medido); (b) NUBES fog-of-war sobre lo no alcanzado (lo tapado ni
/// se construye); (c) botón flotante "ir a donde me quedé".
List<UnitModel> _units(int count) => [
      for (var u = 0; u < count; u++)
        UnitModel(
          id: 'u$u',
          courseId: 'c',
          cefrLevel: ['A1', 'A2', 'B1', 'B2', 'C1'][(u ~/ 6).clamp(0, 4)],
          orderIndex: u + 1,
          title: 'Unidad ${u + 1}',
          themeColor: null,
          icon: null,
          lessons: [
            for (var l = 0; l < 6; l++)
              LessonModel(
                id: 'u${u}l$l',
                unitId: 'u$u',
                orderIndex: l,
                title: 'Lección $l',
                type: l == 5 ? LessonType.checkpoint : LessonType.lesson,
              ),
          ],
        ),
    ];

Future<void> _pumpMap(WidgetTester tester,
    {required int units, required Map<String, String> progress}) async {
  await tester.binding.setSurfaceSize(const Size(460, 820));
  await tester.pumpWidget(ProviderScope(
    overrides: [
      mapUnitsProvider.overrideWith((ref) async => _units(units)),
      lessonProgressProvider.overrideWith((ref) async => progress),
      userPlanProvider.overrideWith((ref) async => null),
    ],
    child: MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: LearnMapScreen()),
    ),
  ));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 60));
}

void main() {
  final progress = <String, String>{
    for (var l = 0; l < 6; l++) 'u0l$l': 'completed',
    'u1l0': 'available',
  };

  testWidgets('VENTANA: en un curso de 30 unidades solo se construye un puñado de nodos',
      (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await _pumpMap(tester, units: 30, progress: progress);
    final nodes = find.byType(MapNode).evaluate().length;
    // 30 unidades = 150 nodos circulares; la ventana construye ~5-20.
    expect(nodes, lessThan(25), reason: 'ventana rota: $nodes nodos construidos');
    expect(nodes, greaterThan(0));
  });

  testWidgets('NUBES: hay manto sobre lo no alcanzado y desaparece al dominar el curso',
      (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    // Progreso bajo → nubes activas.
    await _pumpMap(tester, units: 12, progress: progress);
    bool hasClouds() => find
        .byWidgetPredicate(
            (w) => w is CustomPaint && w.painter is CloudCoverPainter)
        .evaluate()
        .isNotEmpty;
    expect(hasClouds(), isTrue, reason: 'sin nubes con la mayoría bloqueado');

    // Curso (casi) completo → sin nubes. (Árbol nuevo: los overrides de un
    // ProviderScope montado no pueden cambiar.)
    await tester.pumpWidget(const SizedBox());
    final full = <String, String>{
      for (var u = 0; u < 12; u++)
        for (var l = 0; l < 6; l++) 'u${u}l$l': 'completed',
    };
    await _pumpMap(tester, units: 12, progress: full);
    expect(hasClouds(), isFalse, reason: 'nubes no se despejan con todo completado');
  });

  testWidgets('SALTO: lejos del nodo actual aparece "Ir a mi lección" y al tocar vuelve',
      (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await _pumpMap(tester, units: 30, progress: progress);

    final scrollable = find.byType(Scrollable).first;
    final state = tester.state<ScrollableState>(scrollable);
    final start = state.position.pixels;

    // Cerca del objetivo: el botón no está (opacity 0 + IgnorePointer).
    expect(find.text('Ir a mi lección').hitTestable(), findsNothing);

    // Aléjate mucho (hacia la cima).
    state.position.jumpTo((start - 6000).clamp(0.0, double.infinity));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Ir a mi lección').hitTestable(), findsOneWidget);

    // Tocar → vuelve al objetivo (offset ≈ inicial). La animación de scroll se
    // avanza por pasos (frames) hasta completar los 650ms.
    await tester.tap(find.text('Ir a mi lección'));
    for (var i = 0; i < 16; i++) {
      await tester.pump(const Duration(milliseconds: 60));
    }
    expect((state.position.pixels - start).abs(), lessThan(60),
        reason: 'no volvió al nodo actual (${state.position.pixels} vs $start)');
  });
}
