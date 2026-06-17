import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jezici/data/models/progress_models.dart';
import 'package:jezici/features/lesson/lesson_complete_screen.dart';

void main() {
  // La pantalla usa confeti (animación infinita) → pump con duración, sin settle.
  Future<void> pump(WidgetTester tester, LessonSummary s) async {
    tester.view.physicalSize = const Size(440, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(home: LessonCompleteScreen(summary: s)));
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('celebra meta cumplida + racha +1 + hito', (tester) async {
    await pump(
      tester,
      const LessonSummary(
        xpEarned: 20, goldEarned: 10, accuracy: 1.0, graded: 6,
        comboBonus: 8, maxCombo: 6, status: 'golden',
        streak: 7, streakAdvanced: true, goalMet: true,
        dailyGoalXp: 15, dailyXpEarned: 20, milestone: 7,
        skillsUp: ['reading'],
      ),
    );

    expect(find.textContaining('Hito de 7 días'), findsOneWidget); // hito
    expect(find.text('+1'), findsOneWidget); // la racha subió
    expect(find.textContaining('Meta de hoy'), findsOneWidget); // barra de meta
    expect(find.textContaining('7 días de racha'), findsOneWidget);
  });

  testWidgets('sin hito ni avance: mensaje neutro de meta', (tester) async {
    await pump(
      tester,
      const LessonSummary(
        xpEarned: 8, goldEarned: 5, accuracy: 0.5, graded: 6,
        comboBonus: 0, maxCombo: 1, status: 'completed',
        streak: 3, streakAdvanced: false, goalMet: false,
        dailyGoalXp: 15, dailyXpEarned: 8, milestone: 0,
        skillsUp: [],
      ),
    );

    expect(find.textContaining('Hito de'), findsNothing);
    expect(find.text('+1'), findsNothing);
    expect(find.textContaining('días de racha'), findsOneWidget);
  });
}
