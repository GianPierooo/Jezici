import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/features/onboarding/onboarding_data.dart';
import 'package:jezici/features/onboarding/your_plan_view.dart';
import 'package:jezici/l10n/app_localizations.dart';

/// "Tu plan" (Onboarding.dc FRAME B): celebración + mapa de viaje + palanca
/// reversible. Verifica que renderiza los elementos del mockup y que la palanca
/// alterna en ambos sentidos recalculando (badge "la mitad de tiempo").
void main() {
  Widget wrap(OnboardingData data) => MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        // reduce-motion: evita el ticker infinito del confeti en el test.
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: YourPlanView(
              data: data, step: 12, total: 12, onBack: () {}, onFinish: () async {}),
        ),
      );

  testWidgets('Tu plan: celebración + mapa de viaje + CTA coral', (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final data = OnboardingData()
      ..placementLevel = 'A2'
      ..goalLevel = 'B2'
      ..dailyMinutes = 15
      ..daysPerWeek = 7
      ..targetMaxLevel = 'C1'
      ..motive = 'Trabajo';

    await tester.pumpWidget(wrap(data));
    await tester.pump();

    // Header de celebración + mapa de viaje (nivel actual → meta).
    expect(find.text('PERSONALIZADO PARA TI'), findsOneWidget);
    expect(find.text('ESTÁS AQUÍ'), findsOneWidget);
    expect(find.text('TU META'), findsOneWidget);
    expect(find.text('A2'), findsOneWidget); // pin actual
    expect(find.text('B2'), findsOneWidget); // meta
    // CTA coral del mockup.
    expect(find.text('Empezar mi viaje'), findsOneWidget);
  });

  testWidgets('Tu plan: la palanca de ritmo es reversible', (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final data = OnboardingData()
      ..placementLevel = 'A2'
      ..goalLevel = 'B2'
      ..dailyMinutes = 15
      ..daysPerWeek = 7
      ..targetMaxLevel = 'C1'
      ..motive = 'Trabajo';

    await tester.pumpWidget(wrap(data));
    await tester.pump();

    // Apagada: invita a acelerar, sin badge de "mitad de tiempo".
    expect(find.text('¿Quieres llegar más rápido?'), findsOneWidget);
    expect(find.text('⚡ ¡La mitad de tiempo!'), findsNothing);

    // Encender la palanca (tap en el toggle real).
    await tester.tap(find.byKey(const Key('planPaceToggle')));
    await tester.pump();

    // Encendida: muta el texto y aparece el badge.
    expect(find.text('🚀 ¡Vas a toda máquina!'), findsOneWidget);
    expect(find.text('⚡ ¡La mitad de tiempo!'), findsOneWidget);

    // Reversible: apagarla vuelve al estado inicial (sin badge).
    await tester.tap(find.byKey(const Key('planPaceToggle')));
    await tester.pump();
    expect(find.text('¿Quieres llegar más rápido?'), findsOneWidget);
    expect(find.text('⚡ ¡La mitad de tiempo!'), findsNothing);
  });
}
