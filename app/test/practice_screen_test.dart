import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/data/models/practice_models.dart';
import 'package:jezici/data/models/progress_models.dart';
import 'package:jezici/data/providers.dart';
import 'package:jezici/features/practice/practice_screen.dart';
import 'package:jezici/l10n/app_localizations.dart';

/// Practicar.dc: hub con jerarquía (HERO SRS + fila punto débil + grid + banner)
/// y TODO por localización (antes salía en español con la app en pt/en).
void main() {
  Widget harness(String locale) => ProviderScope(
        overrides: [
          practiceStatusProvider
              .overrideWith((ref) async => const PracticeStatus(dueWords: 24, weakestSkill: 'speaking')),
          skillsProvider.overrideWith((ref) async => const [
                SkillLevel(skill: 'speaking', cefrLevel: 'A2', progressPoints: 40),
              ]),
        ],
        child: MaterialApp(
          locale: Locale(locale),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: const Scaffold(body: PracticeScreen()),
          ),
        ),
      );

  testWidgets('ES: HERO SRS con contador real + banner contrarreloj', (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(harness('es'));
    await tester.pump(); // resuelve providers
    await tester.pump();

    expect(find.text('24'), findsOneWidget); // dueWords real
    expect(find.text('palabras por repasar'), findsOneWidget);
    expect(find.text('Refuerza tu punto débil'), findsOneWidget);
    expect(find.text('A2'), findsOneWidget); // badge CEFR real del punto débil
    expect(find.text('Más práctica'), findsOneWidget);
    expect(find.text('Contrarreloj'), findsOneWidget);
    // 90 s alineado al mockup (no 60).
    expect(find.textContaining('90 s'), findsOneWidget);
  });

  testWidgets('PT: todo localizado, sin español filtrado', (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(harness('pt'));
    await tester.pump();
    await tester.pump();

    expect(find.text('palavras para revisar'), findsOneWidget);
    expect(find.text('Contra o relógio'), findsOneWidget);
    expect(find.text('Mais prática'), findsOneWidget);
    // No debe quedar copy en español.
    expect(find.text('palabras por repasar'), findsNothing);
    expect(find.text('Contrarreloj'), findsNothing);
    expect(find.text('Más práctica'), findsNothing);
  });
}
