import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/data/models/checkpoint_models.dart';
import 'package:jezici/data/models/lesson_model.dart';
import 'package:jezici/data/models/level_exam_models.dart';
import 'package:jezici/features/checkpoint/checkpoint_result_screen.dart';
import 'package:jezici/features/level_exam/level_exam_result_screen.dart';
import 'package:jezici/l10n/app_localizations.dart';

/// Momentos de aprobar (Checkpoint.dc + Examen.dc): celebración, 4 skills vs
/// META, puntaje global, mini-mapa del desbloqueo y ramas reprobado — con datos
/// reales y localizados.
void main() {
  Widget wrap(Widget child) => ProviderScope(
        child: MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: child,
          ),
        ),
      );

  SkillScore sk(String s, int correct, int graded) => SkillScore(
      skill: s, total: graded, correct: correct, graded: graded, accuracy: correct / graded);

  testWidgets('Examen aprobado: badge + 4 skills vs META + puntaje global', (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1500));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final r = LevelExamResult.fromJson({
      'passed': true,
      'level': 'B1',
      'score_global': 0.87,
      'threshold': 0.8,
      'graded': 40,
      'correct': 35,
      'xp_earned': 200,
      'gold_earned': 100,
      'leveled_up': true,
      'raised_skills': ['reading', 'writing'],
      'per_skill': [
        {'skill': 'reading', 'total': 10, 'correct': 9, 'graded': 10, 'accuracy': 0.9},
        {'skill': 'writing', 'total': 10, 'correct': 8, 'graded': 10, 'accuracy': 0.8},
      ],
      'weaknesses': [],
    });
    await tester.pumpWidget(wrap(LevelExamResultScreen(result: r)));
    await tester.pump();

    expect(find.text('EXAMEN SUPERADO'), findsOneWidget);
    expect(find.text('Verificado por el examen Jezici'), findsOneWidget);
    expect(find.text('Las 4 habilidades en B1'), findsOneWidget);
    expect(find.text('Todas alcanzan la meta — por eso se certifica'), findsOneWidget);
    expect(find.text('Puntaje global'), findsOneWidget);
    expect(find.text('87'), findsOneWidget); // anillo N/100 real
    expect(find.text('Ver certificado'), findsOneWidget);
  });

  testWidgets('Examen reprobado: diagnóstico per-skill + Reforzar', (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1500));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final r = LevelExamResult.fromJson({
      'passed': false,
      'level': 'B1',
      'score_global': 0.64,
      'threshold': 0.8,
      'graded': 40,
      'correct': 26,
      'xp_earned': 0,
      'gold_earned': 0,
      'leveled_up': false,
      'raised_skills': [],
      'per_skill': [
        {'skill': 'reading', 'total': 10, 'correct': 9, 'graded': 10, 'accuracy': 0.9},
        {'skill': 'writing', 'total': 10, 'correct': 5, 'graded': 10, 'accuracy': 0.5},
      ],
      'weaknesses': ['writing'],
    });
    await tester.pumpWidget(wrap(LevelExamResultScreen(result: r)));
    await tester.pump();

    expect(find.textContaining('Aún no certificas B1'), findsOneWidget);
    expect(find.textContaining('Reforzar Escritura'), findsOneWidget);
    expect(find.text('REINTENTAR EXAMEN'), findsOneWidget);
  });

  testWidgets('Checkpoint reprobado: anillo de score + fallos por habilidad', (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1500));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final r = CheckpointResult(
      passed: false,
      scoreGlobal: 0.64,
      threshold: 0.8,
      attemptNumber: 1,
      graded: 20,
      correct: 13,
      xpEarned: 0,
      goldEarned: 0,
      perSkill: [sk('reading', 5, 8), sk('writing', 8, 12)],
      weaknesses: const ['reading'],
      nextUnlocked: false,
    );
    final lesson = LessonModel.fromJson(const {
      'id': 'l1', 'title': 'Checkpoint', 'type': 'checkpoint', 'order_index': 5,
    });
    await tester.pumpWidget(wrap(
        CheckpointResultScreen(result: r, lesson: lesson, unitTitle: 'En el trabajo')));
    await tester.pump();

    expect(find.text('64%'), findsOneWidget); // anillo real
    // Fallos REALES por habilidad (reading 3, writing 4), ordenados desc.
    expect(find.text('4 fallos'), findsOneWidget);
    expect(find.text('3 fallos'), findsOneWidget);
  });
}
