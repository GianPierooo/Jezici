import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/data/models/practice_models.dart';
import 'package:jezici/features/practice/srs_review_screen.dart';
import 'package:jezici/l10n/app_localizations.dart';

/// SRS F0+F1: la tarjeta es de ESCRITURA (recuerdo activo), nunca opción
/// múltiple, y los 4 botones solo aparecen tras revelar.
void main() {
  Widget app(SrsSession s, {String locale = 'es'}) => ProviderScope(
        child: MaterialApp(
          locale: Locale(locale),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SrsReviewScreen(session: s),
        ),
      );

  const wordCard = SrsCard(
    vocabId: 'v1', word: 'gato', translation: 'cat', kind: 'word', isNew: true,
  );
  const clozeCard = SrsCard(
    vocabId: 'v2', word: 'livro', translation: 'libro', kind: 'cloze',
    sentence: 'Eu leio um livro.',
  );

  test('SrsCard: isCloze exige oracion (degradacion con gracia)', () {
    expect(wordCard.isCloze, isFalse);
    expect(clozeCard.isCloze, isTrue);
    // kind='cloze' sin oracion NO es cloze -> cae a escritura pelada.
    expect(const SrsCard(vocabId: 'x', word: 'a', translation: 'b', kind: 'cloze').isCloze,
        isFalse);
  });

  test('SrsStatus: retencion null mientras no hay maduras (no inventa %)', () {
    expect(SrsStatus.fromJson({'due': 3}).retentionPct, isNull);
    expect(SrsStatus.fromJson({'retention_pct': 88}).retentionPct, 88);
  });

  testWidgets('tarjeta de palabra: pide ESCRIBIR, sin opcion multiple',
      (tester) async {
    await tester.pumpWidget(app(const SrsSession(cards: [wordCard])));
    await tester.pump();

    // Muestra la traducción como pista + campo de texto (recuerdo activo).
    expect(find.text('cat'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('COMPROBAR'), findsOneWidget);
    // La respuesta NO está en pantalla antes de responder (nada de MC).
    expect(find.text('gato'), findsNothing);
    // Los botones de calificación aún no existen.
    expect(find.text('Bien'), findsNothing);
  });

  testWidgets('acierto -> revela + 3 botones (Dificil/Bien/Facil)', (tester) async {
    await tester.pumpWidget(app(const SrsSession(cards: [wordCard])));
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'gato');
    await tester.pump();
    await tester.tap(find.text('COMPROBAR'));
    await tester.pump();

    expect(find.text('¡Correcto!'), findsOneWidget);
    expect(find.text('Difícil'), findsOneWidget);
    expect(find.text('Bien'), findsOneWidget);
    expect(find.text('Fácil'), findsOneWidget);
    // "Otra vez" NO se ofrece en un acierto.
    expect(find.text('Otra vez'), findsNothing);
  });

  testWidgets('fallo -> solo "Otra vez" (el servidor forzaria rating=1)',
      (tester) async {
    await tester.pumpWidget(app(const SrsSession(cards: [wordCard])));
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'perro');
    await tester.pump();
    await tester.tap(find.text('COMPROBAR'));
    await tester.pump();

    expect(find.text('La respuesta era:'), findsOneWidget);
    expect(find.text('Otra vez'), findsOneWidget);
    // Ofrecer "Fácil" sobre un fallo seria mentir: el servidor lo fuerza a 1.
    expect(find.text('Fácil'), findsNothing);
    expect(find.text('Bien'), findsNothing);
  });

  testWidgets('cloze: muestra la oracion con hueco, no la palabra', (tester) async {
    await tester.pumpWidget(app(const SrsSession(cards: [clozeCard])));
    await tester.pump();

    expect(find.text('COMPLETA LA FRASE'), findsOneWidget);
    expect(find.text('Eu leio um _____.'), findsOneWidget);
    // La palabra no se regala.
    expect(find.text('Eu leio um livro.'), findsNothing);
  });

  testWidgets('i18n PT: la tarjeta no deja espanol', (tester) async {
    await tester.pumpWidget(app(const SrsSession(cards: [wordCard]), locale: 'pt'));
    await tester.pump();
    expect(find.text('VERIFICAR'), findsOneWidget);
    expect(find.text('COMPROBAR'), findsNothing);
    expect(find.text('Revisão'), findsOneWidget);
  });
}
