import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/data/models/progress_models.dart';
import 'package:jezici/data/models/tip_models.dart';
import 'package:jezici/data/providers.dart';
import 'package:jezici/data/repositories/progress_repository.dart';
import 'package:jezici/features/lesson/lesson_complete_screen.dart';
import 'package:jezici/l10n/app_localizations.dart';

/// Leccion.dc Frame B (F3): la tarjeta de skills del fin muestra, por skill que
/// subió, BARRA DE PROGRESO + CHIP DE NIVEL CEFR reales + pie motivacional con el
/// siguiente nivel real. Datos de user_skill_levels (no inventados).
class _FakeRepo implements ProgressRepository {
  @override
  Future<TipModel?> getLessonTip(String lessonId) async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  const summary = LessonSummary(
    xpEarned: 15,
    goldEarned: 20,
    accuracy: 1.0,
    graded: 6,
    comboBonus: 0,
    maxCombo: 3,
    status: 'completed',
    streak: 13,
    skillsUp: ['speaking'],
  );

  Widget wrap(ProgressRepository repo) => ProviderScope(
        overrides: [
          progressRepositoryProvider.overrideWithValue(repo),
          skillsProvider.overrideWith((ref) async => const [
                SkillLevel(skill: 'speaking', cefrLevel: 'A2', progressPoints: 48),
              ]),
        ],
        child: MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: LessonCompleteScreen(summary: summary, lessonId: 'L1'),
          ),
        ),
      );

  testWidgets('Fin de lección: skill con barra de progreso + chip CEFR + pie a B1',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(wrap(_FakeRepo()));
    await tester.pump(); // resuelve skillsProvider
    await tester.pump();

    // Chip de nivel CEFR real de la skill.
    expect(find.text('A2'), findsOneWidget);
    // Barra de progreso real (avance dentro del nivel).
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    // Pie motivacional con el SIGUIENTE nivel real (A2 → B1).
    expect(find.textContaining('B1'), findsOneWidget);
  });
}
