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

/// Estado del permiso de micrófono vía Permissions API, SIN abrir prompt.
/// 'granted' | 'denied' | 'prompt' | null (API no disponible — Safari/Firefox
/// viejos lanzan con name:'microphone'; se trata como desconocido).
Future<String?> _micPermissionState() async {
  try {
    final nav = globalContext.getProperty('navigator'.toJS) as JSObject?;
    final perms = nav?.getProperty('permissions'.toJS) as JSObject?;
    if (perms == null || !perms.has('query')) return null;
    final desc = JSObject()..setProperty('name'.toJS, 'microphone'.toJS);
    final status =
        await (perms.callMethod('query'.toJS, desc) as JSPromise<JSObject>).toDart;
    return (status.getProperty('state'.toJS) as JSString?)?.toDart;
  } catch (_) {
    return null;
  }
}

/// Pide el micrófono EXPLÍCITAMENTE (getUserMedia) bajo el gesto del usuario y
/// suelta las pistas al instante (solo queremos resolver el permiso ANTES de
/// arrancar el reconocimiento — si el prompt se resuelve con el reconocedor ya
/// corriendo, en Android el primer intento muere en 'no-speech').
/// Devuelve null si OK; 'denied' | 'no-mic' si falló; null también si la API
/// no existe (se deja que la propia SpeechRecognition pida y reporte).
Future<String?> _requestMic() async {
  JSObject? md;
  try {
    final nav = globalContext.getProperty('navigator'.toJS) as JSObject?;
    md = nav?.getProperty('mediaDevices'.toJS) as JSObject?;
    if (md == null || !md.has('getUserMedia')) return null;
  } catch (_) {
    return null;
  }
  try {
    final constraints = JSObject()..setProperty('audio'.toJS, true.toJS);
    final stream = await (md.callMethod('getUserMedia'.toJS, constraints)
            as JSPromise<JSObject>)
        .toDart;
    // Solo era para el permiso: apagar las pistas ya (el reconocedor abre las suyas).
    try {
      final tracks = (stream.callMethod('getTracks'.toJS) as JSArray).toDart;
      for (final t in tracks) {
        (t as JSObject).callMethod('stop'.toJS);
      }
    } catch (_) {}
    return null;
  } catch (e) {
    final name = e.toString();
    if (name.contains('NotFound') ||
        name.contains('DevicesNotFound') ||
        name.contains('Overconstrained')) {
      return SpeechErrors.noMic;
    }
    if (name.contains('NotAllowed') ||
        name.contains('Permission') ||
        name.contains('Security')) {
      return SpeechErrors.denied;
    }
    // Error raro (p.ej. NotReadable por otro app usando el mic): que lo intente
    // la propia SpeechRecognition y reporte su error concreto.
    return null;
  }
}

class _WebSpeechRecognizer implements SpeechRecognizer {
  _SR? _sr;
  bool _available = false;
  String? _reason;
  bool _listening = false;
  bool _micGranted = false;
  Timer? _timeout;

  String _finalTranscript = '';
  String _lastInterim = ''; // último parcial (rescate: Android a veces termina sin 'final')
  SpeechResultCallback? _onResult;
  SpeechErrorCallback? _onError;
  void Function()? _onDone;
  bool _emittedFinal = false;
  bool _fatalErrored = false;

  @override
  bool get available => _available;
  @override
  String? get unavailableReason => _available ? null : _reason;
  @override
  bool get listening => _listening;

  @override
  Future<bool> init() async {
    try {
      _available = _recognitionCtor() != null;
    } catch (_) {
      _available = false;
    }
    if (!_available) {
      _reason = SpeechErrors.unsupported; // Firefox y afines: no existe la API
      return false;
    }
    // Permiso YA denegado (recordado por el navegador) → cada start moriría en
    // silencio. Detectarlo SIN prompt para no ofrecer un mic muerto.
    final st = await _micPermissionState();
    if (st == 'denied') {
      _available = false;
      _reason = SpeechErrors.denied;
      return false;
    }
    if (st == 'granted') _micGranted = true;
    return true;
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
    _listening = true; // reserva ya (el preflight de permiso es async)
    unawaited(_listenImpl(
        onResult: onResult,
        onError: onError,
        onDone: onDone,
        localeId: localeId,
        listenFor: listenFor));
  }

  Future<void> _listenImpl({
    required SpeechResultCallback onResult,
    SpeechErrorCallback? onError,
    void Function()? onDone,
    required String localeId,
    required Duration listenFor,
  }) async {
    final ctor = _recognitionCtor();
    if (ctor == null) {
      _listening = false;
      _available = false;
      _reason = SpeechErrors.unsupported;
      onError?.call(SpeechErrors.unsupported);
      onDone?.call();
      return;
    }
    // Permiso EXPLÍCITO bajo el gesto, ANTES de arrancar el reconocimiento.
    if (!_micGranted) {
      final err = await _requestMic();
      if (err != null) {
        _listening = false;
        _available = false;
        _reason = err;
        onError?.call(err);
        onDone?.call();
        return;
      }
      _micGranted = true;
    }

    _onResult = onResult;
    _onError = onError;
    _onDone = onDone;
    _finalTranscript = '';
    _lastInterim = '';
    _emittedFinal = false;
    _fatalErrored = false;

    final sr = _SR._(ctor.callAsConstructor<JSObject>());
    _sr = sr;
    sr.lang = localeId.replaceAll('_', '-');
    // continuous=TRUE: NO cortar en la primera pausa. Los ítems de lectura son
    // frases completas; con continuous=false el reconocedor finalizaba el primer
    // fragmento en la pausa natural a media frase y solo se calificaba ese trozo
    // ("no procesa"). Con continuous=true acumula todas las cláusulas y termina
    // en el silencio REAL (usuario terminó) o al tocar detener / al tope de tiempo.
    sr.continuous = true;
    sr.interimResults = true;
    sr.maxAlternatives = 1;

    sr.onresult = ((JSObject ev) => _handleResult(_SREvent._(ev))).toJS;
    sr.onerror = ((JSObject ev) => _handleError(_SRErrEvent._(ev))).toJS;
    sr.onend = ((JSObject _) => _handleEnd()).toJS;

    try {
      sr.start();
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
    _lastInterim = interim; // guarda el último parcial para el rescate en _handleEnd
    final live = (_finalTranscript.isEmpty ? interim : '$_finalTranscript $interim').trim();
    _onResult?.call(live, false);
  }

  void _handleError(_SRErrEvent e) {
    // Códigos crudos de la Web Speech API → códigos estandarizados (SpeechErrors)
    // para que la UI pueda explicar la CAUSA REAL (antes se tragaban y el usuario
    // veía "no te escuché, sube el volumen" con el permiso denegado).
    final raw = e.error;
    String mapped;
    switch (raw) {
      case 'not-allowed':
      case 'service-not-allowed': // Brave/política: la API existe, el servicio no
        mapped = SpeechErrors.denied;
        _available = false;
        _reason = mapped;
        _fatalErrored = true;
        break;
      case 'audio-capture':
        mapped = SpeechErrors.noMic;
        _available = false;
        _reason = mapped;
        _fatalErrored = true;
        break;
      case 'network':
        mapped = SpeechErrors.network; // transitorio: no mata la disponibilidad
        _fatalErrored = true; // pero SÍ suprime el final '' engañoso
        break;
      default:
        mapped = raw; // 'no-speech' / 'aborted' / …
    }
    _onError?.call(mapped);
  }

  void _handleEnd() {
    _timeout?.cancel();
    _listening = false;
    // Con error FATAL (permiso/mic/red) NO se emite el final '' — emitirlo hacía
    // que la UI dijera "no te escuché" cuando la causa real era otra.
    if (!_emittedFinal && !_fatalErrored) {
      _emittedFinal = true;
      // RESCATE Android: si el motor terminó sin marcar ningún resultado 'final'
      // pero SÍ hubo parciales (interim), usa el último parcial como transcripción
      // final en vez de emitir '' (que daba un falso "no te escuché").
      final text = _finalTranscript.trim().isNotEmpty
          ? _finalTranscript.trim()
          : _lastInterim.trim();
      _onResult?.call(text, true);
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
