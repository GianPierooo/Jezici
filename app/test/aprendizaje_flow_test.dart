import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/data/models/lesson_model.dart';
import 'package:jezici/data/models/practice_models.dart';
import 'package:jezici/data/models/progress_models.dart';
import 'package:jezici/data/models/unit_model.dart';
import 'package:jezici/data/providers.dart';
import 'package:jezici/features/lesson/lesson_complete_screen.dart';
import 'package:jezici/features/practice/practice_screen.dart';
import 'package:jezici/l10n/app_localizations.dart';

/// APRENDIZAJE_ANALISIS.md E1/E4/E5: tejer el repaso en el loop + guiar el
/// "qué hacer ahora" + priorizar Practicar por accionabilidad. Capa de
/// experiencia (navegación); no toca motor/economía.
void main() {
  // ── Practicar (E5): prioriza por accionabilidad ──────────────────────────
  Widget practice(String locale,
          {required PracticeStatus status, required SrsStatus srs}) =>
      ProviderScope(
        overrides: [
          practiceStatusProvider.overrideWith((ref) async => status),
          srsStatusProvider.overrideWith((ref) async => srs),
          skillsProvider.overrideWith((ref) async => const [
                SkillLevel(skill: 'speaking', cefrLevel: 'A2', progressPoints: 40),
              ]),
        ],
        child: MaterialApp(
          locale: Locale(locale),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: Scaffold(body: PracticeScreen()),
          ),
        ),
      );

  testWidgets('E5 · SRS con vencidas: HERO arriba (accionable), sin tarjeta "al día"',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(practice('es',
        status: const PracticeStatus(dueWords: 5, weakestSkill: 'speaking'),
        srs: const SrsStatus(due: 5)));
    await tester.pump();
    await tester.pump();

    expect(find.text('5'), findsOneWidget); // contador del HERO
    expect(find.text('Rescatar ahora 🪝'), findsOneWidget); // CTA vivo del HERO
    expect(find.text('Repaso al día'), findsNothing); // no la tarjeta compacta
  });

  testWidgets('E5 · SRS a cero: sube el punto débil, HERO degrada a "Repaso al día" (no botón muerto)',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(practice('es',
        status: const PracticeStatus(dueWords: 0, weakestSkill: 'speaking'),
        srs: const SrsStatus()));
    await tester.pump();
    await tester.pump();

    // Nada vencido → tarjeta compacta honesta, NO el HERO con "Rescatar 0".
    expect(find.text('Repaso al día'), findsOneWidget);
    expect(find.text('Rescatar ahora 🪝'), findsNothing);
    // Lo accionable sigue arriba/visible.
    expect(find.text('Refuerza tu punto débil'), findsOneWidget);
    expect(find.text('Contrarreloj'), findsOneWidget);
  });

  // ── Fin de lección (E1/E4): "qué hacer ahora" jerarquizado ───────────────
  const nextLesson = LessonModel(
    id: 'L2', unitId: 'U1', orderIndex: 2, title: 'Saludos 2',
    type: LessonType.lesson, xpReward: 15,
  );
  const unit = UnitModel(
    id: 'U1', courseId: 'C1', cefrLevel: 'A1', orderIndex: 1,
    title: 'Unidad 1', lessons: [nextLesson],
  );
  LessonSummary summary({String? nextId}) => LessonSummary(
        xpEarned: 17, goldEarned: 5, accuracy: 0.75, graded: 8,
        comboBonus: 0, maxCombo: 4, status: 'completed', streak: 1,
        skillsUp: const [], nextLessonId: nextId,
      );

  Widget complete(LessonSummary s,
          {List<UnitModel> units = const [unit], required SrsStatus srs}) =>
      ProviderScope(
        overrides: [
          mapUnitsProvider.overrideWith((ref) async => units),
          srsStatusProvider.overrideWith((ref) async => srs),
        ],
        child: MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LessonCompleteScreen(summary: s, lessonId: 'L1'),
        ),
      );

  testWidgets('E1/E4 · con siguiente lección + repaso pendiente: PRIMARIO seguir + "Repasar N"',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(complete(summary(nextId: 'L2'), srs: const SrsStatus(due: 8)));
    await tester.pump();
    await tester.pump();

    expect(find.text('¿Qué quieres hacer ahora?'), findsOneWidget); // guía
    expect(find.text('SIGUIENTE LECCIÓN'), findsOneWidget); // primario (momentum)
    expect(find.text('Repasar 8 palabras'), findsOneWidget); // repaso tejido en el loop
    expect(find.text('Volver al mapa'), findsOneWidget);
  });

  testWidgets('E1/E4 · fin de unidad + repaso pendiente: "Repasar N" pasa a PRIMARIO',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(complete(summary(nextId: null), srs: const SrsStatus(due: 3)));
    await tester.pump();
    await tester.pump();

    expect(find.text('Repasar 3 palabras'), findsOneWidget);
    // Sin lección nueva y con repaso → ya no es el "CONTINUAR" ciego.
    expect(find.text('CONTINUAR'), findsNothing);
    expect(find.text('SIGUIENTE LECCIÓN'), findsNothing);
    expect(find.text('Volver al mapa'), findsOneWidget);
  });

  testWidgets('E4 · fin de unidad sin repaso: degrada a CONTINUAR (sin guía superflua)',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(complete(summary(nextId: null), srs: const SrsStatus()));
    await tester.pump();
    await tester.pump();

    expect(find.text('CONTINUAR'), findsOneWidget);
    expect(find.text('¿Qué quieres hacer ahora?'), findsNothing);
  });
}
