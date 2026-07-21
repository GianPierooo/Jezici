import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/data/models/lesson_model.dart';
import 'package:jezici/data/models/tip_models.dart';
import 'package:jezici/data/models/unit_model.dart';
import 'package:jezici/data/providers.dart';
import 'package:jezici/features/study/study_level_screen.dart';
import 'package:jezici/features/study/study_model.dart';
import 'package:jezici/features/study/study_theory_model.dart';
import 'package:jezici/features/study/study_screen.dart';
import 'package:jezici/l10n/app_localizations.dart';

/// ESTUDIAR · Fase E-1: estructura navegable (nivel → tema → teoría) con el
/// desbloqueo DERIVADO del progreso real del mapa. Sin contenido nuevo.
void main() {
  LessonModel les(String id, int i) => LessonModel(
      id: id, unitId: 'u', orderIndex: i, title: 'L$i', type: LessonType.lesson);

  final u1 = UnitModel(
    id: 'u1', courseId: 'c', cefrLevel: 'A1', orderIndex: 1, title: 'Saludos',
    lessons: [les('l1', 1), les('l2', 2)],
  );
  final u2 = UnitModel(
    id: 'u2', courseId: 'c', cefrLevel: 'A1', orderIndex: 2, title: 'Números',
    lessons: [les('l3', 1)],
  );
  final u7 = UnitModel(
    id: 'u7', courseId: 'c', cefrLevel: 'A2', orderIndex: 7, title: 'El pasado',
    lessons: [les('l7', 1)],
  );

  TipModel tip(String id, int unitOrder, String level) => TipModel(
      id: id, type: 'tip_idioma', skill: 'reading', cefrLevel: level,
      title: 'Concepto $id', body: 'Explicación $id', example: 'Ejemplo $id',
      unitOrder: unitOrder);

  group('buildStudyPlan · desbloqueo derivado del progreso REAL', () {
    test('agrupa por nivel en orden CEFR y casa la teoría por unidad', () {
      final plan = buildStudyPlan(
        units: [u7, u1, u2], // desordenadas a propósito
        progress: const {'l1': 'completed', 'l2': 'available'},
        tips: [tip('t1', 1, 'A1'), tip('t2', 1, 'A1'), tip('t7', 7, 'A2')],
      );
      expect(plan.map((l) => l.cefr).toList(), ['A1', 'A2']); // orden pedagógico
      expect(plan[0].topics.length, 2);
      expect(plan[0].topics.first.unit.orderIndex, 1); // temas ordenados
      // La teoría se ata a su unidad (content_tips.unit_order == order_index).
      expect(plan[0].topics.first.tips.length, 2);
      expect(plan[1].topics.first.tips.length, 1);
    });

    test('unidad ALCANZADA en el mapa → tema ABIERTO', () {
      final plan = buildStudyPlan(
        units: [u1], progress: const {'l1': 'available'}, tips: const []);
      expect(plan.first.topics.first.unlocked, isTrue);
      expect(plan.first.topics.first.practiceLessonId, 'l1');
    });

    test('unidad NO alcanzada (sin progreso) → tema BLOQUEADO, sin practicar', () {
      final plan = buildStudyPlan(
        units: [u1, u2],
        progress: const {'l1': 'completed', 'l2': 'completed'}, // u2 sin tocar
        tips: const []);
      final t2 = plan.first.topics[1];
      expect(t2.unlocked, isFalse);
      expect(t2.practiceLessonId, isNull);
      // El candado dice qué unidad completar (la anterior).
      expect(t2.requiredUnitOrder, 1);
    });

    test('progreso vacío (usuario nuevo) → nada abierto, no revienta', () {
      final plan = buildStudyPlan(units: [u1, u2], progress: const {}, tips: const []);
      expect(plan.first.unlockedCount, 0);
      expect(plan.first.topics.every((t) => !t.unlocked), isTrue);
    });

    test('sin teoría para la unidad → hasTheory=false (estado honesto)', () {
      final plan = buildStudyPlan(
        units: [u1], progress: const {'l1': 'available'}, tips: const []);
      expect(plan.first.topics.first.hasTheory, isFalse);
    });

    test('avance de la unidad = lecciones completadas reales', () {
      final plan = buildStudyPlan(
        units: [u1],
        progress: const {'l1': 'completed', 'l2': 'available'},
        tips: const []);
      final t = plan.first.topics.first;
      expect(t.lessonsDone, 1);
      expect(t.lessonsTotal, 2);
    });
  });

  // ── UI: el tab y la lista de temas ────────────────────────────────────────
  Widget app(Widget child, {required Map<String, String> progress}) => ProviderScope(
        overrides: [
          mapUnitsProvider.overrideWith((ref) async => [u1, u2, u7]),
          lessonProgressProvider.overrideWith((ref) async => progress),
          referenceProvider.overrideWith((ref) async =>
              ReferenceData(weakest: 'reading', tips: [tip('t1', 1, 'A1')])),
        ],
        child: MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Scaffold(body: child),
          ),
        ),
      );

  testWidgets('tab Estudiar: lista los NIVELES con cuántos temas hay abiertos',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(app(const StudyScreen(), progress: {'l1': 'available'}));
    await tester.pump();
    await tester.pump();

    expect(find.text('Estudiar'), findsOneWidget);
    expect(find.text('A1'), findsOneWidget);
    expect(find.text('A2'), findsOneWidget);
    expect(find.text('2 temas'), findsOneWidget); // A1 tiene 2 unidades
    expect(find.text('1 de 2 abiertos'), findsOneWidget); // solo u1 alcanzada
  });

  testWidgets('nivel: el tema NO alcanzado sale con CANDADO y dice qué falta',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
        app(const StudyLevelScreen(cefr: 'A1'), progress: {'l1': 'available'}));
    await tester.pump();
    await tester.pump();

    expect(find.text('Saludos'), findsOneWidget); // abierto
    expect(find.text('Números'), findsOneWidget); // bloqueado, pero visible
    expect(find.text('Completa la unidad 1 para desbloquear'), findsOneWidget);
    expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
    // El tema abierto muestra su teoría existente (1 concepto).
    expect(find.text('1 concepto'), findsOneWidget);
  });

  _e2();
}

// ── E-2: la sesión de estudio rica sustituye a los tips, y cae con gracia ────
void _e2() {
  test('StudyTheory.fromJson parsea la sesión completa', () {
    final t = StudyTheory.fromJson({
      'unit_order': 1, 'cefr_level': 'A1', 'title': 'Saludos', 'summary': 'Resumen',
      'sections': [
        {'heading': 'La regla', 'body': 'Explicación', 'bullets': ['uno', 'dos']}
      ],
      'examples': [
        {'en': 'I am Ana.', 'es': 'Soy Ana.', 'audio_url': 'https://x/y.mp3'}
      ],
      'pitfalls': [{'title': 'Ojo', 'body': 'No digas...'}],
      'quiz': [
        {'id': 'u1q1', 'type': 'cloze', 'prompt': 'Completa', 'text': 'I ___ Ana.'},
        {'id': 'u1q2', 'type': 'multiple_choice', 'prompt': 'Elige',
         'options': ['a', 'b', 'c']},
      ],
    });
    expect(t.sections.first.bullets.length, 2);
    expect(t.examples.first.audioUrl, 'https://x/y.mp3');
    // clave histórica 'en' (tanda inglés) y clave canónica 'text' (pt y lo nuevo)
    expect(t.examples.first.target, 'I am Ana.');
    expect(
        StudyExample.fromJson({'text': 'Eu sou a Ana.', 'es': 'Soy Ana.'}).target,
        'Eu sou a Ana.');
    expect(t.pitfalls.length, 1);
    expect(t.hasQuiz, isTrue);
    expect(t.quiz.first.isCloze, isTrue);
    expect(t.quiz[1].options.length, 3);
    // El quiz NUNCA trae la respuesta al cliente (grading server-side).
    expect(t.quiz.first.text, contains('___'));
  });

  test('el resultado de la prueba indexa por id (repaso honesto)', () {
    final r = StudyQuizResult.fromJson({
      'graded': 2, 'correct': 1, 'accuracy': 0.5, 'passed': false,
      'results': [
        {'id': 'u1q1', 'correct': true, 'expected': 'am'},
        {'id': 'u1q2', 'correct': false, 'expected': 'b'},
      ],
    });
    expect(r.accuracyPct, 50);
    expect(r.passed, isFalse);
    expect(r.results['u1q2']!['expected'], 'b');
  });
}
