import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jezici/core/speech/speech_recognizer_api.dart';
import 'package:jezici/data/models/content_item_model.dart';
import 'package:jezici/features/lesson/exercises/speaking_exercise.dart';
import 'package:jezici/l10n/app_localizations.dart';

/// Fake del reconocedor: guiona init/available/errores para probar que la UI
/// muestra la CAUSA REAL (no "sube el volumen") y nunca deja el mic muerto
/// sin explicación ni salida ("Ya lo leí").
class _FakeRec implements SpeechRecognizer {
  _FakeRec({this.initOk = true, this.reason, this.errorOnListen});
  final bool initOk;
  final String? reason;
  final String? errorOnListen;
  bool _listening = false;

  @override
  Future<bool> init() async => initOk;
  @override
  bool get available => initOk;
  @override
  String? get unavailableReason => initOk ? null : reason;
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
    if (errorOnListen != null) {
      // Como el reconocedor web real ante un error FATAL: reporta el código y
      // termina SIN emitir un final '' engañoso.
      onError?.call(errorOnListen!);
      onDone?.call();
      return;
    }
    _listening = true;
    onResult('hello world', true);
    _listening = false;
    onDone?.call();
  }

  @override
  void stop() {}
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

Future<void> _pump(WidgetTester tester, SpeechRecognizer rec) async {
  await tester.pumpWidget(MaterialApp(
    locale: const Locale('es'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: SingleChildScrollView(child: SpeakingExercise(item: _item, recognizer: rec))),
  ));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 30));
}

void main() {
  testWidgets('Navegador SIN soporte → mensaje claro (usa Chrome) + "Ya lo leí"', (tester) async {
    await _pump(tester, _FakeRec(initOk: false, reason: SpeechErrors.unsupported));
    expect(find.textContaining('no soporta reconocimiento de voz'), findsOneWidget);
    expect(find.textContaining('Chrome'), findsOneWidget);
    expect(find.text('Ya lo leí ✓'), findsOneWidget);
    expect(find.text('Hablar'), findsNothing); // no se ofrece lo que no funciona
  });

  testWidgets('Permiso YA denegado (detectado en init) → mensaje de permiso + "Ya lo leí"',
      (tester) async {
    await _pump(tester, _FakeRec(initOk: false, reason: SpeechErrors.denied));
    expect(find.textContaining('permiso del micrófono está bloqueado'), findsOneWidget);
    expect(find.text('Ya lo leí ✓'), findsOneWidget);
    expect(find.text('Hablar'), findsNothing);
  });

  testWidgets('Permiso denegado AL HABLAR → causa real (no "sube el volumen") + "Ya lo leí"',
      (tester) async {
    await _pump(tester, _FakeRec(errorOnListen: SpeechErrors.denied));
    expect(find.text('Hablar'), findsOneWidget); // init OK: se ofrece el mic
    await tester.tap(find.text('Hablar'));
    await tester.pump();
    // El mic se apaga con la CAUSA visible; nada de "no te escuché".
    expect(find.textContaining('permiso del micrófono está bloqueado'), findsOneWidget);
    expect(find.text('Hablar'), findsNothing);
    expect(find.text('Ya lo leí ✓'), findsOneWidget);
    expect(find.textContaining('volumen'), findsNothing);
  });

  testWidgets('Sin micrófono (audio-capture) al hablar → mensaje de dispositivo', (tester) async {
    await _pump(tester, _FakeRec(errorOnListen: SpeechErrors.noMic));
    await tester.tap(find.text('Hablar'));
    await tester.pump();
    expect(find.textContaining('No se detectó ningún micrófono'), findsOneWidget);
    expect(find.text('Ya lo leí ✓'), findsOneWidget);
  });

  testWidgets('Error de red → aviso transitorio y el mic QUEDA para reintentar', (tester) async {
    await _pump(tester, _FakeRec(errorOnListen: SpeechErrors.network));
    await tester.tap(find.text('Hablar'));
    await tester.pump();
    expect(find.textContaining('servicio de voz no respondió'), findsOneWidget);
    expect(find.text('Hablar'), findsOneWidget); // reintentable
  });
}
