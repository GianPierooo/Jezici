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

  // Tarjeta de REPASO (no nueva): entra directo a la cara de escritura. Las
  // NUEVAS pasan primero por la cara de PRESENTACIÓN (P0-B, tests abajo).
  const wordCard = SrsCard(
    vocabId: 'v1', word: 'gato', translation: 'cat', kind: 'word',
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
    await tester.binding.setSurfaceSize(const Size(500, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(app(const SrsSession(cards: [wordCard, clozeCard])));
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'gato');
    await tester.pump();
    await tester.tap(find.text('COMPROBAR'));
    await tester.pump();

    expect(find.text('¡Correcto!'), findsOneWidget);
    // El CTA principal es continuar (= "Bien"); ajustar es opcional.
    expect(find.text('Bien'), findsOneWidget);
    expect(find.text('Difícil'), findsOneWidget);
    expect(find.text('Fácil'), findsOneWidget);
    // "Otra vez" NO se ofrece en un acierto.
    expect(find.text('Otra vez'), findsNothing);
    // Y AVANZA SOLO: no hay que elegir nada tras cada tarjeta.
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('¡Correcto!'), findsNothing);
  });

  testWidgets('acierto: si el usuario no toca nada, FSRS recibe "Bien" (3)',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    // Con una sola tarjeta, al auto-avanzar la sesión termina y se envía.
    // Sin backend el envío falla y la pantalla se cierra: lo que se comprueba
    // aquí es que el auto-avance OCURRE sin intervención del usuario.
    await tester.pumpWidget(app(const SrsSession(cards: [wordCard, clozeCard])));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'gato');
    await tester.pump();
    await tester.tap(find.text('COMPROBAR'));
    await tester.pump();
    expect(find.text('2 restantes'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump(const Duration(milliseconds: 400));
    // La tarjeta se dio por buena y quedó UNA: el rating viajó sin pedir nada.
    expect(find.text('1 restante'), findsOneWidget);
    expect(find.text('COMPLETA LA FRASE'), findsOneWidget);
  });

  testWidgets('acierto: ajustar es OPCIONAL y secundario (chips, no 3 botones)',
      (tester) async {
    await tester.pumpWidget(app(const SrsSession(cards: [wordCard, clozeCard])));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'gato');
    await tester.pump();
    await tester.tap(find.text('COMPROBAR'));
    await tester.pump(const Duration(milliseconds: 600));

    // El CTA principal es el grande ("Bien" = lo que se envía solo);
    // "Difícil" y "Fácil" existen pero como chips pequeños.
    final bien = tester.widget<Text>(find.text('Bien'));
    final facil = tester.widget<Text>(find.text('Fácil'));
    expect(facil.style!.fontSize, 12); // chip discreto
    expect(bien.style?.fontSize ?? 16, greaterThan(facil.style!.fontSize!));
  });

  testWidgets('el auto-avance salta UNA vez: no arrastra la tarjeta siguiente',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(app(const SrsSession(cards: [wordCard, clozeCard])));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'gato');
    await tester.pump();
    await tester.tap(find.text('COMPROBAR'));
    await tester.pump();
    expect(find.text('2 restantes'), findsOneWidget);

    // Salta el auto-avance de la PRIMERA tarjeta.
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('1 restante'), findsOneWidget);

    // La SEGUNDA aun no se ha respondido: dejar pasar otro plazo entero no
    // puede calificarla sola (si el timer no se cancelara al calificar, esta
    // tarjeta se saltaria sin que el usuario la conteste).
    await tester.pump(const Duration(milliseconds: 2500));
    expect(find.text('1 restante'), findsOneWidget);
    expect(find.text('COMPLETA LA FRASE'), findsOneWidget);
  });

  testWidgets('salir antes del auto-avance no califica ni revienta', (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(app(const SrsSession(cards: [wordCard, clozeCard])));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'gato');
    await tester.pump();
    await tester.tap(find.text('COMPROBAR'));
    await tester.pump();

    // El usuario abandona la pantalla con el temporizador en marcha.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 2000));
    expect(tester.takeException(), isNull);
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

  testWidgets('F4: progreso legible ("N restantes", no numero suelto)', (tester) async {
    await tester.pumpWidget(app(const SrsSession(cards: [wordCard, clozeCard])));
    await tester.pump();
    expect(find.text('2 restantes'), findsOneWidget);
  });

  testWidgets('F4: el revelado trae icono en los botones de rating', (tester) async {
    await tester.pumpWidget(app(const SrsSession(cards: [wordCard])));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'gato');
    await tester.pump();
    await tester.tap(find.text('COMPROBAR'));
    await tester.pump();
    // Micro-lectura de un vistazo: cada boton lleva su icono.
    expect(find.byIcon(Icons.hourglass_bottom_rounded), findsOneWidget); // Dificil
    expect(find.byIcon(Icons.check_rounded), findsOneWidget); // Bien
    expect(find.byIcon(Icons.bolt_rounded), findsOneWidget); // Facil
  });

  testWidgets('i18n PT: la tarjeta no deja espanol', (tester) async {
    await tester.pumpWidget(app(const SrsSession(cards: [wordCard]), locale: 'pt'));
    await tester.pump();
    expect(find.text('VERIFICAR'), findsOneWidget);
    expect(find.text('COMPROBAR'), findsNothing);
    expect(find.text('Revisão'), findsOneWidget);
  });

  // ── CAUSA_RAIZ_RETENCION P0-A: sinonimos validos ACEPTADOS (mig 177) ──────
  // Los casos EXACTOS de las capturas: hola→hello (la tarjeta guarda "hi"),
  // gracias→thanks ("thank you"), disculpa→sorry ("excuse me").
  const holaCard = SrsCard(
    vocabId: 'h1', word: 'hi', translation: 'hola', kind: 'word',
    accepted: ['hello', 'hey'],
  );
  const graciasCard = SrsCard(
    vocabId: 'g1', word: 'thank you', translation: 'gracias', kind: 'word',
    accepted: ['thanks', 'thanks a lot'],
  );
  const disculpaCard = SrsCard(
    vocabId: 'd1', word: 'excuse me', translation: 'disculpa', kind: 'word',
    accepted: ['sorry', 'pardon'],
  );

  Future<void> expectAccepted(WidgetTester tester, SrsCard card, String answer) async {
    await tester.pumpWidget(app(SrsSession(cards: [card])));
    await tester.pump();
    await tester.enterText(find.byType(TextField), answer);
    await tester.pump();
    await tester.tap(find.text('COMPROBAR'));
    await tester.pump();
    expect(find.text('¡Correcto!'), findsOneWidget,
        reason: '"$answer" debe aceptarse para "${card.translation}"');
    expect(find.text('Otra vez'), findsNothing);
  }

  testWidgets('CAPTURA 1: "hello" para hola (tarjeta "hi") -> CORRECTO', (tester) async {
    await expectAccepted(tester, holaCard, 'hello');
  });

  testWidgets('CAPTURA 2: "thanks" para gracias (tarjeta "thank you") -> CORRECTO',
      (tester) async {
    await expectAccepted(tester, graciasCard, 'thanks');
  });

  testWidgets('CAPTURA 3: "sorry" para disculpa (tarjeta "excuse me") -> CORRECTO',
      (tester) async {
    await expectAccepted(tester, disculpaCard, 'sorry');
  });

  testWidgets('una respuesta REALMENTE mal sigue siendo mal (no se regala todo)',
      (tester) async {
    await tester.pumpWidget(app(const SrsSession(cards: [holaCard])));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'goodbye');
    await tester.pump();
    await tester.tap(find.text('COMPROBAR'));
    await tester.pump();
    expect(find.text('La respuesta era:'), findsOneWidget);
    expect(find.text('Otra vez'), findsOneWidget);
  });

  // ── P0-B: enseñar antes de examinar en produccion ─────────────────────────
  testWidgets('palabra NUEVA: se PRESENTA primero (verla+oirla), luego se escribe',
      (tester) async {
    const newCard = SrsCard(
      vocabId: 'n1', word: 'gato', translation: 'cat', kind: 'word', isNew: true,
    );
    await tester.pumpWidget(app(const SrsSession(cards: [newCard])));
    await tester.pump();

    // Cara de PRESENTACIÓN: la palabra SE MUESTRA (no se examina a ciegas).
    expect(find.text('gato'), findsOneWidget);
    expect(find.text('¡AHORA ESCRÍBELA!'), findsOneWidget);
    expect(find.byType(TextField), findsNothing); // aún no se pide escribir

    await tester.tap(find.text('¡AHORA ESCRÍBELA!'));
    await tester.pump();

    // Ahora sí: cara de escritura (recuerdo inmediato de lo recién visto).
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('COMPROBAR'), findsOneWidget);
  });

  testWidgets('tarjeta de REPASO (no nueva): NO hay presentacion, directo a escribir',
      (tester) async {
    await tester.pumpWidget(app(const SrsSession(cards: [wordCard])));
    await tester.pump();
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('¡AHORA ESCRÍBELA!'), findsNothing);
  });
}
