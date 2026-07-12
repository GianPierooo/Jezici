import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/core/speech/speech_recognizer_api.dart';
import 'package:jezici/core/speech/text_match.dart';
import 'package:jezici/data/models/content_item_model.dart';
import 'package:jezici/features/lesson/exercises/speaking_exercise.dart';
import 'package:jezici/l10n/app_localizations.dart';

/// Reconocedor de prueba que reproduce el patrón de Android: llegan PARCIALES
/// (isFinal=false) y el motor termina SIN emitir un resultado 'final'. El
/// reconocedor web REAL rescata el último parcial en _handleEnd; aquí simulamos
/// que la superficie recibe ese texto como final (lo que produce el web tras el fix).
class _AndroidLikeRec implements SpeechRecognizer {
  _AndroidLikeRec(this.finalText);
  final String finalText;
  bool _listening = false;
  SpeechResultCallback? _cb;
  void Function()? _done;

  @override
  Future<bool> init() async => true;
  @override
  bool get available => true;
  @override
  String? get unavailableReason => null;
  @override
  bool get listening => _listening;

  @override
  void listen({
    required SpeechResultCallback onResult,
    SpeechErrorCallback? onError,
    void Function()? onDone,
    String localeId = 'en_US',
    Duration listenFor = const Duration(seconds: 8),
  }) {
    _listening = true;
    _cb = onResult;
    _done = onDone;
    // Solo parciales (como Android): nunca isFinal en onresult.
    onResult('I like', false);
    onResult(finalText, false);
  }

  // El usuario toca "Detener": como el web real, _handleEnd emite el rescate
  // (último parcial) como final.
  @override
  void stop() {
    _listening = false;
    _cb?.call(finalText, true);
    _done?.call();
  }

  @override
  void dispose() {}
}

const _item = ContentItemModel(
  id: 'S1',
  type: ContentItemType.translation,
  skill: 'speaking',
  cefrLevel: 'A1',
  payload: {'text': 'I like coffee.', 'speaking': true},
);

void main() {
  test('grading: lectura correcta con acentos/contracciones/nombre APRUEBA', () {
    // Recognizer típico vs esperado — todo lo que un usuario lee bien debe pasar.
    expect(speechPasses('hi i am Ana', "Hi, I'm Ana."), isTrue);
    expect(speechPasses('I do not like tea', "I don't like tea."), isTrue);
    expect(speechPasses('il ragazzo che vive qui e il mio vicino',
        'Il ragazzo che vive qui è il mio vicino.'), isTrue);
    expect(speechPasses('eu queria uma agua sem gas e a conta por favor',
        'Eu queria uma água sem gás e a conta, por favor.'), isTrue);
    // Y hablar MAL de verdad NO aprueba.
    expect(speechPasses('good morning', 'I like coffee.'), isFalse);
  });

  testWidgets('captura: solo parciales + tocar Detener → califica el último parcial (no vacío)',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
          body: SingleChildScrollView(
              child: SpeakingExercise(item: _item, recognizer: _AndroidLikeRec('I like coffee')))),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 30));

    // Empezar a escuchar.
    await tester.tap(find.text('Hablar'));
    await tester.pump();
    // Transcripción EN VIVO visible (parcial), y el botón ahora es "Detener".
    expect(find.text('Detener'), findsOneWidget);
    expect(find.textContaining('I like coffee'), findsWidgets);

    // Tocar Detener → el reconocedor emite el último parcial como final → aprueba.
    await tester.tap(find.text('Detener'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 30));
    expect(find.text('¡Bien pronunciado! 🦜'), findsOneWidget); // speakingGood (no "no te escuché")
  });
}
