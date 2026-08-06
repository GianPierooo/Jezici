import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/data/models/course_models.dart';
import 'package:jezici/data/models/progress_models.dart';
import 'package:jezici/data/models/tip_models.dart';
import 'package:jezici/data/providers.dart';
import 'package:jezici/data/repositories/progress_repository.dart';
import 'package:jezici/features/onboarding/course_switcher.dart';
import 'package:jezici/l10n/app_localizations.dart';

/// BUG (misión "Estudiar sirve la teoría de otro idioma"): al cambiar de curso
/// activo, `referenceProvider` (que alimenta el tab Estudiar vía
/// `studyPlanProvider` + la pantalla Referencia) se quedaba con el
/// `AsyncValue` del curso VIEJO — `_invalidateCourseScope` refrescaba
/// `mapUnitsProvider`/`lessonProgressProvider` pero no `referenceProvider`
/// (ni `notebookProvider`/`storiesProvider`, mismo patrón course-scoped).
/// Resultado: las unidades FRESCAS del curso nuevo se combinaban con teoría
/// STALE del curso anterior (emparejadas solo por `unit_order`, que coincide
/// entre cursos) → Estudiar mostraba la teoría de otro idioma.
///
/// Este test ejercita el camino REAL (`switchCourseFlow`), no una
/// reimplementación: prueba que tras cambiar de curso, `referenceProvider`
/// vuelve a pedir datos al repositorio (y ya no arrastra los del curso viejo).
class _FakeRepo implements ProgressRepository {
  String active = 'c-en';
  int referenceCalls = 0;

  @override
  Future<void> setActiveCourse(String courseId) async {
    active = courseId;
  }

  @override
  Future<UserPlan?> fetchPlan({String? courseId}) async =>
      const UserPlan(currentLevel: 'A1', goalLevel: 'B1', dailyMinutes: 15);

  @override
  Future<ReferenceData> fetchReference() async {
    referenceCalls++;
    // Simula el server real: get_reference() deriva SIEMPRE del curso activo
    // (jz_active_course()) — el fake devuelve teoría distinta según `active`.
    return ReferenceData(weakest: 'reading', tips: [
      TipModel(
        id: 't-$active',
        type: 'tip_idioma',
        skill: 'reading',
        cefrLevel: 'A1',
        title: active == 'c-en' ? 'Present simple' : 'Presente do indicativo',
        body: '...',
        unitOrder: 1,
      ),
    ]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets(
      'cambiar de curso RE-FRESCA referenceProvider (Estudiar deja de arrastrar la teoría del curso anterior)',
      (tester) async {
    final repo = _FakeRepo();
    final pt = CourseInfo(
        id: 'c-pt', source: 'es', target: 'pt', targetName: 'Português', active: false);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        progressRepositoryProvider.overrideWithValue(repo),
        coursesProvider.overrideWith((ref) async => [
              CourseInfo(id: 'c-en', source: 'es', target: 'en', targetName: 'Inglés', active: true),
              pt,
            ]),
      ],
      child: MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Consumer(builder: (context, ref, _) {
          final tips = ref.watch(referenceProvider).value?.tips ?? const <TipModel>[];
          return Scaffold(
            body: Column(children: [
              Text(tips.isEmpty ? '…' : tips.first.title),
              ElevatedButton(
                onPressed: () => switchCourseFlow(context, ref, pt),
                child: const Text('cambiar'),
              ),
            ]),
          );
        }),
      ),
    ));
    await tester.pump();
    await tester.pump();

    // Curso activo = inglés → Estudiar/Referencia ven la teoría del inglés.
    expect(find.text('Present simple'), findsOneWidget);
    expect(repo.referenceCalls, 1);

    await tester.tap(find.text('cambiar'));
    await tester.pumpAndSettle();

    // Tras el cambio, referenceProvider se REFETCHEÓ (no quedó pegado al
    // AsyncValue viejo) y Estudiar/Referencia ahora ven la teoría de PT.
    expect(repo.referenceCalls, greaterThan(1));
    expect(find.text('Presente do indicativo'), findsOneWidget);
    expect(find.text('Present simple'), findsNothing);
  });
}
