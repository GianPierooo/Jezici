import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/data/models/lesson_model.dart';
import 'package:jezici/data/models/progress_models.dart';
import 'package:jezici/data/models/unit_model.dart';
import 'package:jezici/data/providers.dart';
import 'package:jezici/features/lesson/lesson_complete_screen.dart';
import 'package:jezici/l10n/app_localizations.dart';

/// "MINUTO 4": tras la 1ª lección tiene que haber un SIGUIENTE PASO.
/// Viene de uso real: @eugenio acabó su lección y el CTA lo soltaba en el mapa
/// (el servidor ya devolvía next_lesson_id y se tiraba).
void main() {
  const next = LessonModel(
    id: 'L2', unitId: 'U1', orderIndex: 2, title: 'Saludos 2',
    type: LessonType.lesson, xpReward: 15,
  );
  const unit = UnitModel(
    id: 'U1', courseId: 'C1', cefrLevel: 'A1', orderIndex: 1,
    title: 'Unidad 1', lessons: [next],
  );

  // Los mismos números que @eugenio en producción: 8 ítems, 75%, 17 XP.
  LessonSummary summary({String? nextId}) => LessonSummary(
        xpEarned: 17, goldEarned: 5, accuracy: 0.75, graded: 8,
        comboBonus: 6, maxCombo: 4, status: 'completed', streak: 1,
        skillsUp: const [], dailyGoalXp: 15, dailyXpEarned: 17,
        nextLessonId: nextId,
      );

  Widget app(LessonSummary s, {List<UnitModel> units = const [unit]}) => ProviderScope(
        overrides: [
          mapUnitsProvider.overrideWith((ref) async => units),
        ],
        child: MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LessonCompleteScreen(summary: s, lessonId: 'L1'),
        ),
      );

  testWidgets('con siguiente lección: CTA "SIGUIENTE LECCIÓN" + volver al mapa',
      (tester) async {
    await tester.pumpWidget(app(summary(nextId: 'L2')));
    await tester.pump(); // deja resolver mapUnitsProvider

    expect(find.text('SIGUIENTE LECCIÓN'), findsOneWidget);
    expect(find.text('Volver al mapa'), findsOneWidget);
    // Ya no es el CONTINUAR ciego que soltaba en el mapa.
    expect(find.text('CONTINUAR'), findsNothing);
  });

  testWidgets('sin siguiente (fin de unidad): degrada a CONTINUAR', (tester) async {
    await tester.pumpWidget(app(summary(nextId: null)));
    await tester.pump();

    expect(find.text('CONTINUAR'), findsOneWidget);
    expect(find.text('SIGUIENTE LECCIÓN'), findsNothing);
  });

  testWidgets('next_lesson_id que no está en el mapa: degrada con gracia',
      (tester) async {
    // El servidor apunta a L9 pero el mapa cargado no la tiene → no se rompe.
    await tester.pumpWidget(app(summary(nextId: 'L9')));
    await tester.pump();

    expect(find.text('CONTINUAR'), findsOneWidget);
    expect(find.text('SIGUIENTE LECCIÓN'), findsNothing);
  });
}
