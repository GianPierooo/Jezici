import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/data/models/course_models.dart';
import 'package:jezici/data/providers.dart';
import 'package:jezici/data/repositories/progress_repository.dart';
import 'package:jezici/features/onboarding/onboarding_screen.dart';
import 'package:jezici/l10n/app_localizations.dart';

/// Fake que registra set_active_course (lo que hace _pickTarget al elegir idioma META).
class _FakeRepo implements ProgressRepository {
  final List<String> activeCalls = [];
  @override
  Future<void> setActiveCourse(String courseId) async => activeCalls.add(courseId);
  @override
  Future<void> logEvent(String name, {Map<String, dynamic>? props}) async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('Onboarding: el paso de idioma META fija el curso y lo activa', (tester) async {
    final fake = _FakeRepo();
    final courses = [
      CourseInfo(id: 'c-en', source: 'es', target: 'en', targetName: 'English', active: true),
      CourseInfo(id: 'c-de', source: 'es', target: 'de', targetName: 'Deutsch', active: false),
    ];

    await tester.pumpWidget(ProviderScope(
      overrides: [
        progressRepositoryProvider.overrideWithValue(fake),
        coursesProvider.overrideWith((ref) async => courses),
      ],
      child: MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: OnboardingScreen(onComplete: () {}),
      ),
    ));
    await tester.pump();

    // Paso 0 (bienvenida) → EMPEZAR.
    await tester.tap(find.text('EMPEZAR'));
    await tester.pumpAndSettle();
    // Paso 1 (idioma de la app) → CONTINUAR.
    await tester.tap(find.text('CONTINUAR').first);
    await tester.pump();
    await tester.pump();

    // Paso 2: idioma META. Aparecen los cursos con el nombre en el idioma de la app.
    expect(find.text('¿Qué idioma quieres aprender?'), findsOneWidget);
    expect(find.textContaining('alemán'), findsOneWidget); // learnLangName(es, 'de')
    expect(find.textContaining('inglés'), findsOneWidget);

    // Elegir alemán → set_active_course(alemán) + habilita continuar.
    await tester.tap(find.textContaining('alemán'));
    await tester.pump();
    expect(fake.activeCalls, contains('c-de'));
  });
}
