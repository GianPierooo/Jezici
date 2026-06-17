import 'package:speech_to_text/speech_to_text.dart';

import 'speech_recognizer_api.dart';

SpeechRecognizer createSpeechRecognizerImpl() => _IoSpeechRecognizer();

/// Móvil/desktop: speech_to_text nativo (la transcripción nativa es correcta;
/// el bug de duplicados era exclusivo de la capa web del plugin).
class _IoSpeechRecognizer implements SpeechRecognizer {
  final SpeechToText _stt = SpeechToText();
  bool _available = false;
  bool _listening = false;
  bool _emittedFinal = false;
  String _last = '';
  SpeechResultCallback? _onResult;
  void Function()? _onDone;

  @override
  bool get available => _available;
  @override
  bool get listening => _listening;

  @override
  Future<bool> init() async {
    try {
      _available = await _stt.initialize(
        onError: (_) {},
        onStatus: (s) {
          if (s == 'done' || s == 'notListening') _finish();
        },
      );
    } catch (_) {
      _available = false;
    }
    return _available;
  }

  @override
  void listen({
    required SpeechResultCallback onResult,
    SpeechErrorCallback? onError,
    void Function()? onDone,
    String localeId = 'en_US',
    Duration listenFor = const Duration(seconds: 8),
  }) {
    if (!_available || _listening) return;
    _onResult = onResult;
    _onDone = onDone;
    _emittedFinal = false;
    _last = '';
    _listening = true;
    _stt.listen(
      onResult: (r) {
        _last = r.recognizedWords;
        _onResult?.call(r.recognizedWords, false);
        if (r.finalResult) _finish();
      },
      listenOptions: SpeechListenOptions(localeId: localeId, listenFor: listenFor),
    );
  }

  void _finish() {
    if (!_listening) return;
    _listening = false;
    if (!_emittedFinal) {
      _emittedFinal = true;
      _onResult?.call(_last.trim(), true);
    }
    _onDone?.call();
  }

  @override
  void stop() {
    try {
      _stt.stop();
    } catch (_) {}
    _finish();
  }

  @override
  void dispose() {
    try {
      _stt.cancel();
    } catch (_) {}
  }
}
