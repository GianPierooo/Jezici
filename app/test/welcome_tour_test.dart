import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/features/onboarding/welcome_tour.dart';
import 'package:jezici/l10n/app_localizations.dart';

/// Tour de bienvenida con Jezi: se navega (siguiente/atrás), se puede SALTAR en
/// cualquier momento, y termina en el paso final. Sin los elementos reales
/// montados (no hay mapa en el test), cada paso se muestra centrado (degradación
/// con gracia) — exactamente el fallback que debe funcionar.
void main() {
  Widget app(String locale, VoidCallback onFinish) => MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: WelcomeTour(onFinish: onFinish)),
      );

  testWidgets('arranca en la bienvenida y avanza con Siguiente', (tester) async {
    await tester.pumpWidget(app('es', () {}));
    await tester.pump();

    expect(find.text('¡Hola! Soy Jezi 🦜'), findsOneWidget);
    expect(find.text('Saltar'), findsOneWidget);
    // Avanza al 2º paso.
    await tester.tap(find.text('Siguiente'));
    await tester.pump();
    expect(find.text('Tu camino'), findsOneWidget);
    // Atrás vuelve a la bienvenida.
    await tester.tap(find.text('Atrás'));
    await tester.pump();
    expect(find.text('¡Hola! Soy Jezi 🦜'), findsOneWidget);
  });

  testWidgets('Saltar termina el tour de inmediato', (tester) async {
    var finished = false;
    await tester.pumpWidget(app('es', () => finished = true));
    await tester.pump();
    await tester.tap(find.text('Saltar'));
    await tester.pump();
    expect(finished, isTrue);
  });

  testWidgets('el último paso muestra el CTA de empezar (i18n PT)', (tester) async {
    var finished = false;
    await tester.pumpWidget(app('pt', () => finished = true));
    await tester.pump();
    // 9 pasos (E-1 añadió "Estudiar") → 8 toques de "Próximo" para el último.
    for (var i = 0; i < 8; i++) {
      await tester.tap(find.text('Próximo'));
      await tester.pump();
    }
    expect(find.text('Tudo pronto!'), findsOneWidget);
    expect(find.text('Vamos!'), findsOneWidget); // CTA final (sin español)
    await tester.tap(find.text('Vamos!'));
    await tester.pump();
    expect(finished, isTrue);
  });
}
