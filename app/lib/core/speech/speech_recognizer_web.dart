import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import '../errors/error_reporter.dart';
import 'speech_recognizer_api.dart';
import 'text_match.dart' show collapseSpeechRepeats;

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

String _userAgent() {
  try {
    final nav = globalContext.getProperty('navigator'.toJS) as JSObject?;
    return ((nav?.getProperty('userAgent'.toJS) as JSString?)?.toDart ?? '').toLowerCase();
  } catch (_) {
    return '';
  }
}

int _maxTouchPoints() {
  try {
    final nav = globalContext.getProperty('navigator'.toJS) as JSObject?;
    return (nav?.getProperty('maxTouchPoints'.toJS) as JSNumber?)?.toDartInt ?? 0;
  } catch (_) {
    return 0;
  }
}

/// ¿Conviene el modo SEGMENTADO (continuous=false)? En WebKit/Safari (todo iOS +
/// Safari macOS) el modo `continuous` está roto: la sesión se detiene sola, los
/// parciales se DUPLICAN (el bucle "that weekend that weekend…") y `isFinal` a
/// veces no llega → el reconocimiento no termina. El patrón estable ahí es
/// single-shot (continuous=false): el motor reconoce el enunciado y termina. En
/// Chrome/Edge/Android continuous=true SÍ es mejor (no corta en la 1ª pausa).
bool _useSegmentedMode() {
  final ua = _userAgent();
  final isIos = ua.contains('iphone') || ua.contains('ipad') || ua.contains('ipod');
  // iPadOS 13+ se anuncia como "Macintosh"; distínguelo por el táctil.
  final iPadDesktop = ua.contains('macintosh') && _maxTouchPoints() > 1;
  final isChromium = ua.contains('chrome') ||
      ua.contains('crios') ||
      ua.contains('chromium') ||
      ua.contains('edg') ||
      ua.contains('android');
  final isSafari = ua.contains('safari') && !isChromium;
  return isIos || iPadDesktop || isSafari;
}

/// Detecta un WebView IN-APP (Instagram, Facebook, TikTok, Line, WebView de
/// Android). Ahí el micrófono suele estar bloqueado y NO hay candado ni ajustes
/// de sitio → el mensaje "actívalo en el candado" es engañoso; la UI muestra
/// "ábrelo en Chrome/Safari" (SpeechErrors.webview).
bool _isInAppWebView() {
  final ua = _userAgent();
  return ua.contains('instagram') ||
      ua.contains('fban') ||
      ua.contains('fbav') ||
      ua.contains('fb_iab') ||
      ua.contains('line/') ||
      ua.contains('tiktok') ||
      ua.contains('musical_ly') ||
      ua.contains('; wv)'); // Android System WebView
}

/// Estado del permiso de micrófono vía Permissions API, SIN abrir prompt.
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
/// suelta las pistas al instante (solo resolver el permiso ANTES de arrancar el
/// reconocimiento: si el prompt se resuelve con el reconocedor ya corriendo, en
/// Android el primer intento muere en 'no-speech'). Devuelve null si OK; un
/// código si falló; null también si la API no existe (que pida SpeechRecognition).
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
    return null; // NotReadable, etc.: que lo intente SpeechRecognition.
  }
}

class _WebSpeechRecognizer implements SpeechRecognizer {
  _SR? _sr;
  bool _available = false;
  String? _reason;
  bool _listening = false;
  bool _micGranted = false;
  Timer? _timeout;
  bool _cancelled = false; // stop() durante el preflight → no arrancar

  String _finalTranscript = '';
  String _lastInterim = ''; // último parcial (rescate: a veces termina sin 'final')
  SpeechResultCallback? _onResult;
  SpeechErrorCallback? _onError;
  void Function()? _onDone;
  bool _emittedFinal = false;
  bool _emittedDone = false;
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
      // Firefox y WebViews sin API. Si es un WebView in-app, mensaje específico.
      _reason = _isInAppWebView() ? SpeechErrors.webview : SpeechErrors.unsupported;
      return false;
    }
    final st = await _micPermissionState();
    if (st == 'denied') {
      _available = false;
      // En un WebView in-app "denied" suele ser el navegador bloqueando el mic
      // sin candado que activar → dirígelo a Chrome/Safari.
      _reason = _isInAppWebView() ? SpeechErrors.webview : SpeechErrors.denied;
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
    _cancelled = false;
    // Guarda los callbacks ANTES del preflight → stop() durante el preflight
    // puede cerrar la sesión (onDone) sin dejar el botón en "Detener".
    _onResult = onResult;
    _onError = onError;
    _onDone = onDone;
    _finalTranscript = '';
    _lastInterim = '';
    _emittedFinal = false;
    _emittedDone = false;
    _fatalErrored = false;
    unawaited(_listenImpl(localeId: localeId, listenFor: listenFor));
  }

  Future<void> _listenImpl({
    required String localeId,
    required Duration listenFor,
  }) async {
    final ctor = _recognitionCtor();
    if (ctor == null) {
      _fail(SpeechErrors.unsupported, available: false);
      return;
    }
    // Permiso EXPLÍCITO bajo el gesto, ANTES de arrancar. Con WATCHDOG: si
    // getUserMedia cuelga (WebView, mic ocupado) no dejamos el botón atascado.
    if (!_micGranted) {
      String? err;
      try {
        err = await _requestMic().timeout(
          const Duration(seconds: 4),
          onTimeout: () => SpeechErrors.noMic,
        );
      } catch (_) {
        err = null;
      }
      if (_cancelled) {
        // stop() ya cerró la sesión durante el preflight.
        _listening = false;
        return;
      }
      if (err != null) {
        _fail(err, available: false);
        return;
      }
      _micGranted = true;
    }
    if (_cancelled) {
      _listening = false;
      return;
    }

    final _SR sr;
    try {
      sr = _SR._(ctor.callAsConstructor<JSObject>());
    } catch (_) {
      _fail('start-failed', available: true);
      return;
    }
    _sr = sr;
    sr.lang = localeId.replaceAll('_', '-');
    // WebKit/Safari (iOS): SEGMENTADO (continuous=false) — su continuous produce
    // el bucle de parciales y sesiones que no terminan. Chrome/Android: continuous
    // (no corta en la 1ª pausa). El dedup de _handleResult protege en AMBOS.
    sr.continuous = !_useSegmentedMode();
    sr.interimResults = true;
    sr.maxAlternatives = 1;

    sr.onresult = ((JSObject ev) => _handleResult(_SREvent._(ev))).toJS;
    sr.onerror = ((JSObject ev) => _handleError(_SRErrEvent._(ev))).toJS;
    sr.onend = ((JSObject _) => _handleEnd()).toJS;

    try {
      sr.start();
      _timeout = Timer(listenFor, stop);
    } catch (_) {
      _sr = null;
      _fail('start-failed', available: true);
    }
  }

  /// Cierra la sesión por un fallo (emite onError una vez + onDone una vez).
  void _fail(String code, {required bool available}) {
    _listening = false;
    if (!available) {
      _available = false;
      _reason = code;
    }
    _reportMic(code);
    _onError?.call(code);
    _emitDone();
  }

  void _emitDone() {
    if (_emittedDone) return;
    _emittedDone = true;
    _onDone?.call();
  }

  // Reconstruye la transcripción DESDE 0 (results es acumulativo) en cada evento
  // y usa SOLO el último parcial → nunca "acumula" prefijos crecientes (el origen
  // del bucle). Dedup de finales idénticos + collapse de repeticiones (WebKit).
  void _handleResult(_SREvent e) {
    final results = e.results;
    final finals = <String>[];
    var lastInterim = '';
    for (var i = 0; i < results.length; i++) {
      final res = results.item(i);
      final txt = res.item(0).transcript.trim();
      if (txt.isEmpty) continue;
      if (res.isFinal) {
        // WebKit re-emite el mismo 'final' → no anexar un duplicado consecutivo.
        if (finals.isEmpty || finals.last.toLowerCase() != txt.toLowerCase()) {
          finals.add(txt);
        }
      } else {
        lastInterim = txt; // varios parciales solapados → quédate con el último
      }
    }
    _finalTranscript = collapseSpeechRepeats(finals.join(' '));
    _lastInterim = collapseSpeechRepeats(lastInterim);
    final live = _finalTranscript.isEmpty
        ? _lastInterim
        : (_lastInterim.isEmpty ? _finalTranscript : '$_finalTranscript $_lastInterim');
    _onResult?.call(collapseSpeechRepeats(live), false);
  }

  void _handleError(_SRErrEvent e) {
    final raw = e.error;
    String mapped;
    switch (raw) {
      case 'not-allowed':
      case 'service-not-allowed':
        // Brave/WebView: la API existe pero el servicio/permiso no. En un WebView
        // in-app no hay candado → mensaje "ábrelo en Chrome/Safari".
        mapped = _isInAppWebView() ? SpeechErrors.webview : SpeechErrors.denied;
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
        _fatalErrored = true; // pero suprime el final '' engañoso
        break;
      default:
        mapped = raw; // 'no-speech' / 'aborted' / …
    }
    _reportMic(mapped);
    _onError?.call(mapped);
  }

  void _handleEnd() {
    _timeout?.cancel();
    _listening = false;
    if (!_emittedFinal && !_fatalErrored) {
      _emittedFinal = true;
      final text = _finalTranscript.trim().isNotEmpty
          ? _finalTranscript.trim()
          : _lastInterim.trim();
      _onResult?.call(text, true);
    }
    _emitDone();
    _sr = null;
  }

  @override
  void stop() {
    _cancelled = true; // por si estamos en el preflight
    _timeout?.cancel();
    final sr = _sr;
    if (sr != null) {
      try {
        sr.stop(); // dispara onend → emite final + onDone
      } catch (_) {}
    } else if (_listening) {
      // Estábamos en el preflight (no hay reconocedor que parar): cierra a mano.
      _listening = false;
      _emitDone();
    }
  }

  @override
  void dispose() {
    _cancelled = true;
    _timeout?.cancel();
    try {
      _sr?.abort();
    } catch (_) {}
    _sr = null;
    _onResult = null;
    _onError = null;
    _onDone = null;
  }

  /// Telemetría de fallos del mic INESPERADOS (para diagnosticar "el speaking
  /// falla" en dispositivos reales). NO reporta los esperados/benignos: denied
  /// (el usuario/Brave), unsupported/webview (Firefox/WebView conocidos),
  /// no-speech/aborted (constantes y normales). Sin PII.
  void _reportMic(String code) {
    const skip = {
      SpeechErrors.denied,
      SpeechErrors.unsupported,
      SpeechErrors.webview,
      'no-speech',
      'aborted',
    };
    if (skip.contains(code)) return;
    reportError(Exception('mic_$code'),
        rpc: 'jz_mic', context: 'code=$code;seg=${_useSegmentedMode()}');
  }
}
