import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/features/premium/donations_card.dart';
import 'package:jezici/l10n/app_localizations.dart';

/// T6 · bloque de donaciones "Aporta un grano de arena": Yape/Plin con número +
/// copiar; PayPal/Stripe en "Pronto" mientras su URL no esté configurada
/// (framing honesto — nada de botón muerto). Los placeholders viven en
/// core/config/donations.dart.
void main() {
  Widget app(Locale locale) => MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
            body: SingleChildScrollView(child: DonationsCard())),
      );

  testWidgets('muestra Yape/Plin con número 906517394 y métodos', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(app(const Locale('es')));
    await tester.pump();

    expect(find.text('Aporta un grano de arena'), findsOneWidget);
    expect(find.text('Yape'), findsOneWidget);
    expect(find.text('Plin'), findsOneWidget);
    expect(find.text('Tarjeta (Stripe)'), findsOneWidget);
    // El número de Yape/Plin (mismo) aparece dos veces (una por método).
    expect(find.text('906517394'), findsNWidgets(2));
    // PayPal LIVE → tappable con la etiqueta "Donar con PayPal" (ya no "Pronto").
    expect(find.text('Donar con PayPal'), findsOneWidget);
    // Solo Stripe sigue sin URL → "Pronto" (no botón muerto).
    expect(find.text('Pronto'), findsOneWidget);
  });

  testWidgets('copiar número pone 906517394 en el portapapeles', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        copied = (call.arguments as Map)['text'] as String?;
      }
      return null;
    });
    await tester.pumpWidget(app(const Locale('es')));
    await tester.pump();

    await tester.tap(find.text('906517394').first);
    await tester.pump();
    expect(copied, '906517394');
    // Vacía los Timers pendientes (revertir el check 1.6s + auto-dismiss del
    // snackbar 4s) sin pumpAndSettle: la mascota Jezi anima en loop y nunca
    // "settlea". Un pump de 6s adelanta el reloj y dispara ambos.
    await tester.pump(const Duration(seconds: 6));
  });

  testWidgets('PT: chrome traducido (sin español)', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(app(const Locale('pt')));
    await tester.pump();
    expect(find.text('Contribua com um grão de areia'), findsOneWidget);
    expect(find.text('Aporta un grano de arena'), findsNothing);
    // PayPal LIVE en PT; solo Stripe sigue "Em breve".
    expect(find.text('Doar com PayPal'), findsOneWidget);
    expect(find.text('Em breve'), findsOneWidget);
  });
}
