import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/services.dart' show rootBundle;

import 'audio_engine.dart';

AudioEngine makeAudioEngine() => _WebAudioEngine();

// ── Bindings mínimos de Web Audio API + fetch ────────────────────────────────
extension type _Ctx._(JSObject o) implements JSObject {
  external JSPromise<_Buf> decodeAudioData(JSArrayBuffer data);
  external _Src createBufferSource();
  external _Gain createGain();
  external JSObject get destination;
  external String get state;
  external double get currentTime;
  external JSPromise<JSAny?> resume();
}

extension type _Buf._(JSObject o) implements JSObject {
  external double get duration;
}

extension type _Src._(JSObject o) implements JSObject {
  external set buffer(_Buf b);
  external void connect(JSObject node);
  external void start();
  external void stop();
  external set loop(bool b);
  external set onended(JSFunction f);
}

extension type _Gain._(JSObject o) implements JSObject {
  external _Param get gain;
  external void connect(JSObject node);
}

extension type _Param._(JSObject o) implements JSObject {
  external set value(double v);
  external void setTargetAtTime(double target, double startTime, double timeConstant);
  external void cancelScheduledValues(double t);
}

@JS('fetch')
external JSPromise<_Resp> _fetch(String url);

@JS('fetch')
external JSPromise<_Resp> _fetchOpt(String url, JSObject init);

extension type _Resp._(JSObject o) implements JSObject {
  external JSPromise<JSArrayBuffer> arrayBuffer();
  external bool get ok;
  external int get status;
}

/// Reproductor de audio vía Web Audio API. NO crea elementos <audio>, así que
/// iOS Safari NO muestra el "now-playing" en la pantalla de bloqueo.
class _WebAudioEngine implements AudioEngine {
  _Ctx? _ctx;
  final Map<String, _Buf> _cache = {};
  _Src? _urlSrc;
  bool _clearedSession = false;

  // ── Música de fondo (loop) con GainNode propio → permite DUCKING sin tocar
  //    SFX/TTS, y vive en el MISMO AudioContext → no crea MediaSession. ──
  _Gain? _musicGain;
  _Src? _musicSrc;
  String? _musicUrl;
  double _musicVolume = 0.16;
  Timer? _unduckTimer;

  _Ctx? _ensure() {
    if (_ctx != null) return _ctx;
    JSFunction? ctor;
    if (globalContext.has('AudioContext')) {
      ctor = globalContext.getProperty('AudioContext'.toJS);
    } else if (globalContext.has('webkitAudioContext')) {
      ctor = globalContext.getProperty('webkitAudioContext'.toJS);
    }
    if (ctor == null) return null;
    try {
      _ctx = _Ctx._(ctor.callAsConstructor<JSObject>());
    } catch (_) {
      return null;
    }
    _clearMediaSession();
    return _ctx;
  }

  /// Defensa extra: deja vacía la MediaSession para que ningún reproductor
  /// fantasma quede registrado en el centro de control / pantalla de bloqueo.
  void _clearMediaSession() {
    if (_clearedSession) return;
    _clearedSession = true;
    try {
      final nav = globalContext.getProperty('navigator'.toJS) as JSObject?;
      final ms = nav?.getProperty('mediaSession'.toJS) as JSObject?;
      if (ms != null) {
        ms.setProperty('metadata'.toJS, null);
        try {
          ms.setProperty('playbackState'.toJS, 'none'.toJS);
        } catch (_) {}
      }
    } catch (_) {}
  }

  Future<void> _resumeIfNeeded(_Ctx c) async {
    if (c.state == 'suspended') {
      try {
        await c.resume().toDart;
      } catch (_) {}
    }
  }

  @override
  void unlock() {
    final c = _ensure();
    if (c != null && c.state == 'suspended') {
      try {
        c.resume();
      } catch (_) {}
    }
  }

  Future<_Buf?> _buffer(_Ctx c, String key, Future<JSArrayBuffer?> Function() bytes) async {
    final cached = _cache[key];
    if (cached != null) return cached;
    try {
      final ab = await bytes();
      if (ab == null) return null;
      final buf = await c.decodeAudioData(ab).toDart;
      _cache[key] = buf;
      return buf;
    } catch (_) {
      return null;
    }
  }

  void _play(_Ctx c, _Buf buf, double volume, {void Function()? onEnded}) {
    try {
      _duckMusic(650); // SFX: baja la música y la recupera tras ~0.65 s
      final src = c.createBufferSource();
      src.buffer = buf;
      final gain = c.createGain();
      gain.gain.value = volume;
      src.connect(gain as JSObject);
      gain.connect(c.destination);
      if (onEnded != null) src.onended = (() => onEnded()).toJS;
      src.start();
    } catch (_) {}
  }

  @override
  Future<void> playAsset(String assetKey, {double volume = 0.7}) async {
    final c = _ensure();
    if (c == null) return;
    await _resumeIfNeeded(c);
    final buf = await _buffer(c, 'a:$assetKey', () async {
      final data = await rootBundle.load('assets/$assetKey');
      return data.buffer.toJS;
    });
    if (buf != null) _play(c, buf, volume);
  }

  @override
  Future<void> playUrl(String url, {double volume = 1.0, void Function()? onComplete}) async {
    final c = _ensure();
    if (c == null) return;
    await _resumeIfNeeded(c);
    final buf = await _buffer(c, 'u:$url', () async {
      try {
        final resp = await _fetch(url).toDart;
        return await resp.arrayBuffer().toDart;
      } catch (_) {
        return null;
      }
    });
    if (buf == null) return;
    // Sustituye cualquier TTS previo (sin solaparse).
    try {
      _urlSrc?.stop();
    } catch (_) {}
    try {
      final src = c.createBufferSource();
      src.buffer = buf;
      final gain = c.createGain();
      gain.gain.value = volume;
      src.connect(gain as JSObject);
      gain.connect(c.destination);
      // TTS/listening: ducking durante la reproducción; recupera al terminar.
      src.onended = (() {
        _unduckMusic();
        onComplete?.call();
      }).toJS;
      _urlSrc = src;
      _duckMusic(15000); // fallback largo por si onended no dispara
      src.start();
    } catch (_) {}
  }

  @override
  Future<void> prefetch(String url) async {
    final c = _ensure();
    if (c == null || _cache.containsKey('u:$url')) return;
    // Descarga + decodifica al caché sin reproducir (no requiere gesto).
    await _buffer(c, 'u:$url', () async {
      try {
        final resp = await _fetch(url).toDart;
        return await resp.arrayBuffer().toDart;
      } catch (_) {
        return null;
      }
    });
  }

  @override
  Future<bool> isUrlAvailable(String url) async {
    // Si ya está decodificado en caché, existe.
    if (_cache.containsKey('u:$url')) return true;
    try {
      final init = JSObject();
      init.setProperty('method'.toJS, 'HEAD'.toJS);
      final resp = await _fetchOpt(url, init).toDart;
      return resp.ok; // 200 → true; 400 (objeto inexistente en Storage) → false
    } catch (_) {
      // Red ambigua / CORS: no marcar como faltante para no saltar de más.
      return true;
    }
  }

  @override
  Future<void> stop() async {
    try {
      _urlSrc?.stop();
    } catch (_) {}
    _urlSrc = null;
  }

  @override
  Future<void> startLoop(String url, {double volume = 0.16}) async {
    final c = _ensure();
    if (c == null) return;
    _musicVolume = volume;
    if (_musicUrl == url && _musicSrc != null) {
      await _resumeIfNeeded(c); // ya suena esa URL: solo reasegura el contexto
      return;
    }
    await _resumeIfNeeded(c);
    final buf = await _buffer(c, 'm:$url', () async {
      try {
        final resp = await _fetch(url).toDart;
        return await resp.arrayBuffer().toDart;
      } catch (_) {
        return null;
      }
    });
    if (buf == null) return;
    try {
      _musicSrc?.stop();
    } catch (_) {}
    try {
      final g = _musicGain ??= c.createGain();
      final now = c.currentTime;
      g.gain.cancelScheduledValues(now);
      g.gain.value = 0.0001; // arranca casi en silencio → fade-in (sin pop)
      g.gain.setTargetAtTime(_musicVolume, now, 0.3);
      g.connect(c.destination);
      final src = c.createBufferSource();
      src.buffer = buf;
      src.loop = true; // loop sample-exacto (WAV sin padding → sin clic)
      src.connect(g as JSObject);
      _musicSrc = src;
      _musicUrl = url;
      src.start();
    } catch (_) {}
  }

  @override
  Future<void> stopLoop() async {
    _unduckTimer?.cancel();
    _unduckTimer = null;
    final c = _ctx;
    final g = _musicGain;
    final src = _musicSrc;
    _musicSrc = null;
    _musicUrl = null;
    if (c != null && g != null) {
      try {
        final now = c.currentTime;
        g.gain.cancelScheduledValues(now);
        g.gain.setTargetAtTime(0.0001, now, 0.08); // fade-out corto
      } catch (_) {}
    }
    Timer(const Duration(milliseconds: 360), () {
      try {
        src?.stop();
      } catch (_) {}
    });
  }

  /// Baja la música (DUCKING) y programa su recuperación tras [ms]. No-op si no
  /// hay música sonando. Cada llamada reprograma el unduck (audios solapados).
  void _duckMusic(int ms) {
    final c = _ctx;
    final g = _musicGain;
    if (c == null || g == null || _musicSrc == null) return;
    try {
      final now = c.currentTime;
      g.gain.cancelScheduledValues(now);
      g.gain.setTargetAtTime(_musicVolume * 0.16, now, 0.05); // baja rápido (~0.15 s)
    } catch (_) {}
    _unduckTimer?.cancel();
    _unduckTimer = Timer(Duration(milliseconds: ms), _unduckMusic);
  }

  void _unduckMusic() {
    _unduckTimer?.cancel();
    _unduckTimer = null;
    final c = _ctx;
    final g = _musicGain;
    if (c == null || g == null || _musicSrc == null) return;
    try {
      final now = c.currentTime;
      g.gain.cancelScheduledValues(now);
      g.gain.setTargetAtTime(_musicVolume, now, 0.25); // recupera suave (~0.75 s)
    } catch (_) {}
  }
}
