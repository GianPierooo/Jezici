import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/data/models/content_item_model.dart';
import 'package:jezici/data/models/lesson_model.dart';
import 'package:jezici/data/models/tip_models.dart';
import 'package:jezici/data/models/unit_model.dart';
import 'package:jezici/data/providers.dart';
import 'package:jezici/features/lesson/lesson_preview_screen.dart';
import 'package:jezici/l10n/app_localizations.dart';

/// ENLACE INVERSO mapa→Estudiar (lo que E-1 dejó diferido): desde la preview de
/// una lección se llega a la TEORÍA de su tema. El enlace SOLO existe si ese
/// tema ya está abierto en Estudiar → nunca es un botón muerto.
///
/// El punto de entrada es la PREVIEW, no el nodo del mapa: el tap del nodo y el
/// gating se quedan intactos (esta pantalla ya era un destino aparte).
void main() {
  LessonModel les(String id, String unitId, int i) => LessonModel(
      id: id, unitId: unitId, orderIndex: i, title: 'Saludos', type: LessonType.lesson);

  final u1 = UnitModel(
    id: 'u1', courseId: 'c', cefrLevel: 'A1', orderIndex: 1, title: 'Saludos',
    lessons: [les('l1', 'u1', 1)],
  );
  final u2 = UnitModel(
    id: 'u2', courseId: 'c', cefrLevel: 'A1', orderIndex: 2, title: 'Números',
    lessons: [les('l2', 'u2', 1)],
  );

  final tip = TipModel(
      id: 't1', type: 'tip_idioma', skill: 'reading', cefrLevel: 'A1',
      title: 'Concepto', body: 'Explicación', example: 'Ejemplo', unitOrder: 1);

  final item = ContentItemModel(
      id: 'i1', type: ContentItemType.multipleChoice, skill: 'reading', prompt: '¿Cuál?',
      payload: const {'options': ['a', 'b']}, difficulty: 1, cefrLevel: 'A1');

  Widget app(LessonModel lesson, {required Map<String, String> progress}) => ProviderScope(
        overrides: [
          mapUnitsProvider.overrideWith((ref) async => [u1, u2]),
          lessonProgressProvider.overrideWith((ref) async => progress),
          referenceProvider.overrideWith(
              (ref) async => ReferenceData(weakest: 'reading', tips: [tip])),
          lessonItemsProvider.overrideWith((ref, id) async => [item]),
        ],
        child: MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: LessonPreviewScreen(lesson: lesson),
          ),
        ),
      );

  testWidgets('la lección de una unidad ALCANZADA ofrece ir a su teoría',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(app(les('l1', 'u1', 1), progress: {'l1': 'available'}));
    await tester.pump();
    await tester.pump();

    expect(find.text('Estudia la teoría de esto'), findsOneWidget);
    // El CTA de siempre sigue ahí: el enlace es SECUNDARIO, no lo reemplaza.
    expect(find.text('EMPEZAR'), findsOneWidget);
  });

  testWidgets('si el tema aún NO está abierto, no se pinta enlace muerto',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    // u2 no se ha alcanzado (solo hay progreso en l1) → su tema sigue cerrado.
    await tester.pumpWidget(app(les('l2', 'u2', 1), progress: {'l1': 'available'}));
    await tester.pump();
    await tester.pump();

    expect(find.text('Estudia la teoría de esto'), findsNothing);
  });
}
