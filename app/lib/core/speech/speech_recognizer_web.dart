import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'speech_recognizer_api.dart';

SpeechRecognizer createSpeechRecognizerImpl() => _WebSpeechRecognizer();

// ── Bindings mínimos de la Web Speech API ────────────────────────────────────
extension type _SR._(JSObject o) implements JSObject {
  external set lang(String v);
  external set continuous(bool v);
  external set interimResults(bool v);
  external set maxAlternatives(int v);
  external void start();
  external void stop();
  external void abort();
  external set onresult(JSFunction f);
  external set onerror(JSFunction f);
  external set onend(JSFunction f);
}

extension type _SREvent._(JSObject o) implements JSObject {
  external int get resultIndex;
  external _SRResultList get results;
}

extension type _SRResultList._(JSObject o) implements JSObject {
  external int get length;
  external _SRResult item(int index);
}

extension type _SRResult._(JSObject o) implements JSObject {
  external bool get isFinal;
  external _SRAlt item(int index);
}

extension type _SRAlt._(JSObject o) implements JSObject {
  external String get transcript;
}

extension type _SRErrEvent._(JSObject o) implements JSObject {
  external String get error;
}

JSFunction? _recognitionCtor() {
  if (globalContext.has('SpeechRecognition')) {
    return globalContext.getProperty('SpeechRecognition'.toJS);
  }
  if (globalContext.has('webkitSpeechRecognition')) {
    return globalContext.getProperty('webkitSpeechRecognition'.toJS);
  }
  return null;
}

class _WebSpeechRecognizer implements SpeechRecognizer {
  _SR? _sr;
  bool _available = false;
  bool _listening = false;
  Timer? _timeout;

  String _finalTranscript = '';
  SpeechResultCallback? _onResult;
  SpeechErrorCallback? _onError;
  void Function()? _onDone;
  bool _emittedFinal = false;

  @override
  bool get available => _available;
  @override
  bool get listening => _listening;

  @override
  Future<bool> init() async {
    try {
      _available = _recognitionCtor() != null;
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
    if (_listening) return;
    final ctor = _recognitionCtor();
    if (ctor == null) {
      _available = false;
      onError?.call('unsupported');
      onDone?.call();
      return;
    }
    _onResult = onResult;
    _onError = onError;
    _onDone = onDone;
    _finalTranscript = '';
    _emittedFinal = false;

    final sr = _SR._(ctor.callAsConstructor<JSObject>());
    _sr = sr;
    sr.lang = localeId.replaceAll('_', '-');
    sr.continuous = false;
    sr.interimResults = true;
    sr.maxAlternatives = 1;

    sr.onresult = ((JSObject ev) => _handleResult(_SREvent._(ev))).toJS;
    sr.onerror = ((JSObject ev) => _handleError(_SRErrEvent._(ev))).toJS;
    sr.onend = ((JSObject _) => _handleEnd()).toJS;

    try {
      sr.start();
      _listening = true;
      _timeout = Timer(listenFor, stop);
    } catch (_) {
      _listening = false;
      onError?.call('start-failed');
      onDone?.call();
    }
  }

  // Correcto: itera DESDE resultIndex; los finales se anexan UNA vez; los
  // interinos se reconstruyen en cada evento (sin acumular duplicados).
  void _handleResult(_SREvent e) {
    var interim = '';
    final results = e.results;
    for (var i = e.resultIndex; i < results.length; i++) {
      final res = results.item(i);
      final txt = res.item(0).transcript;
      if (res.isFinal) {
        _finalTranscript = (_finalTranscript.isEmpty ? txt : '$_finalTranscript $txt').trim();
      } else {
        interim = interim.isEmpty ? txt : '$interim $txt';
      }
    }
    final live = (_finalTranscript.isEmpty ? interim : '$_finalTranscript $interim').trim();
    _onResult?.call(live, false);
  }

  void _handleError(_SRErrEvent e) {
    final err = e.error;
    if (err == 'not-allowed' || err == 'service-not-allowed') _available = false;
    // 'no-speech' / 'aborted' / 'audio-capture' → terminamos sin texto.
    _onError?.call(err);
  }

  void _handleEnd() {
    _timeout?.cancel();
    _listening = false;
    if (!_emittedFinal) {
      _emittedFinal = true;
      _onResult?.call(_finalTranscript.trim(), true);
    }
    _onDone?.call();
    _sr = null;
  }

  @override
  void stop() {
    _timeout?.cancel();
    try {
      _sr?.stop();
    } catch (_) {}
  }

  @override
  void dispose() {
    _timeout?.cancel();
    try {
      _sr?.abort();
    } catch (_) {}
    _sr = null;
    _onResult = null;
    _onError = null;
    _onDone = null;
  }
}
