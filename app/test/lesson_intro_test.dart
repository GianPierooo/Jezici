import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/data/models/tip_models.dart';
import 'package:jezici/features/lesson/lesson_intro_view.dart';
import 'package:jezici/l10n/app_localizations.dart';

/// "Enseñar antes de examinar" (P1 #4): la presentación muestra el concepto (tip)
/// y el vocabulario (término meta + traducción, imagen si hay) ANTES del primer
/// ejercicio, y es SALTABLE. El contenido viene de get_lesson_intro (derivado de
/// lo que la lección ya tiene). Aquí probamos el render + los dos callbacks.
void main() {
  final intro = LessonIntro(
    tip: TipModel(
      id: 't1',
      type: 'tip_idioma',
      skill: 'reading',
      cefrLevel: 'A1',
      title: 'A / An según el sonido',
      body: 'Usa "an" antes de sonido vocálico.',
      example: 'a book · an apple',
    ),
    vocab: const [
      IntroWord(term: 'father', translation: 'padre', imageUrl: 'https://x/father.png'),
      IntroWord(term: 'hello', translation: 'hola'), // sin imagen → degrada
    ],
  );

  Widget harness(String locale,
          {required VoidCallback onStart, required VoidCallback onSkip}) =>
      MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: LessonIntroView(
            intro: intro,
            title: 'Saludos básicos',
            onStart: onStart,
            onSkip: onSkip,
          ),
        ),
      );

  testWidgets('ES: muestra concepto + vocabulario y CTA de empezar', (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var started = false;
    await tester.pumpWidget(harness('es', onStart: () => started = true, onSkip: () {}));
    await tester.pump();

    // Concepto (del tip) presente.
    expect(find.text('A / An según el sonido'), findsOneWidget);
    expect(find.text('a book · an apple'), findsOneWidget);
    // Vocabulario: términos meta + traducciones.
    expect(find.text('father'), findsOneWidget);
    expect(find.text('padre'), findsOneWidget);
    expect(find.text('hello'), findsOneWidget);
    expect(find.text('hola'), findsOneWidget);
    // CTA para empezar los ejercicios.
    expect(find.text('EMPEZAR EJERCICIOS'), findsOneWidget);
    await tester.tap(find.text('EMPEZAR EJERCICIOS'));
    await tester.pump();
    expect(started, isTrue);
  });

  testWidgets('PT: saltable + sin español', (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var skipped = false;
    await tester.pumpWidget(harness('pt', onStart: () {}, onSkip: () => skipped = true));
    await tester.pump();

    // "Pular" (saltar en pt) y NO "Saltar"/"Skip".
    expect(find.text('Pular'), findsOneWidget);
    expect(find.text('Saltar'), findsNothing);
    expect(find.text('COMEÇAR EXERCÍCIOS'), findsOneWidget);
    await tester.tap(find.text('Pular'));
    await tester.pump();
    expect(skipped, isTrue);
  });
}
