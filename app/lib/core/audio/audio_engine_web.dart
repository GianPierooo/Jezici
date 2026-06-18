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
  external set onended(JSFunction f);
}

extension type _Gain._(JSObject o) implements JSObject {
  external _Param get gain;
  external void connect(JSObject node);
}

extension type _Param._(JSObject o) implements JSObject {
  external set value(double v);
}

@JS('fetch')
external JSPromise<_Resp> _fetch(String url);

extension type _Resp._(JSObject o) implements JSObject {
  external JSPromise<JSArrayBuffer> arrayBuffer();
}

/// Reproductor de audio vía Web Audio API. NO crea elementos <audio>, así que
/// iOS Safari NO muestra el "now-playing" en la pantalla de bloqueo.
class _WebAudioEngine implements AudioEngine {
  _Ctx? _ctx;
  final Map<String, _Buf> _cache = {};
  _Src? _urlSrc;
  bool _clearedSession = false;

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
      src.onended = (() => onComplete?.call()).toJS;
      _urlSrc = src;
      src.start();
    } catch (_) {}
  }

  @override
  Future<void> stop() async {
    try {
      _urlSrc?.stop();
    } catch (_) {}
    _urlSrc = null;
  }
}
