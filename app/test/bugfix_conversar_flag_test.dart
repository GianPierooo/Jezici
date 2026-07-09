import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/data/models/course_models.dart';
import 'package:jezici/data/providers.dart';
import 'package:jezici/features/conversar/conversar_screen.dart';
import 'package:jezici/features/learn/widgets/learn_top_bar.dart';
import 'package:jezici/l10n/app_localizations.dart';

/// BUG 1: Conversar debe seguir el idioma de la APP (chrome i18n), no salir en
/// español con la app en pt/en. BUG 2: la bandera del top bar refleja el CURSO
/// ACTIVO real (no 🇬🇧 fijo).
MaterialApp _app(Widget child, Locale locale) => MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('BUG1: Conversar en PT no tiene español (chrome i18n)', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(ProviderScope(
      overrides: [activeCourseTargetProvider.overrideWith((ref) async => 'pt')],
      child: _app(const ConversarScreen(), const Locale('pt')),
    ));
    await tester.pump();

    // Chrome en portugués…
    expect(find.text('Pratique conversas reais. No seu ritmo, sem pressão.'), findsOneWidget);
    // …y NADA del español que salía antes.
    expect(find.text('Practica conversaciones reales. A tu ritmo, sin presión.'), findsNothing);
    // Situación localizada: "Pedir um café" (pt), no "Pedir un café" (es).
    expect(find.text('Pedir um café'), findsOneWidget);
    expect(find.text('Pedir un café'), findsNothing);
  });

  testWidgets('BUG2: la bandera del top bar refleja el curso activo (no 🇬🇧 fijo)',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(ProviderScope(
      overrides: [
        coursesProvider.overrideWith((ref) async => [
              CourseInfo(id: 'c-en', source: 'es', target: 'en', targetName: 'Inglés', active: false),
              CourseInfo(id: 'c-pt', source: 'es', target: 'pt', targetName: 'Português', active: true),
            ]),
      ],
      child: _app(const LearnTopBar(), const Locale('es')),
    ));
    await tester.pump(); // resuelve coursesProvider

    expect(find.text('🇧🇷'), findsOneWidget); // curso activo = pt
    expect(find.text('🇬🇧'), findsNothing); // ya no hardcodeado
  });
}
