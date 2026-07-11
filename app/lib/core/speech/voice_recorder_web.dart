import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/foundation.dart' show Uint8List;

import 'voice_recorder.dart';

VoiceRecorder createVoiceRecorderImpl() => _WebVoiceRecorder();

/// Graba notas de voz cortas en la web con MediaRecorder (getUserMedia). Reusa
/// el mismo enfoque robusto de permiso que el reconocedor de voz: pide el mic
/// explícitamente bajo el gesto y reporta la causa (denied/no-mic/unsupported).
class _WebVoiceRecorder implements VoiceRecorder {
  JSObject? _stream;
  JSObject? _recorder;
  final List<JSAny> _chunks = [];
  String _ext = 'webm';
  String _mime = 'audio/webm';
  int _startedMs = 0;
  bool _recording = false;
  Completer<VoiceRecording?>? _done;

  @override
  bool get isRecording => _recording;

  String _pickMime() {
    try {
      final mr = globalContext.getProperty('MediaRecorder'.toJS) as JSObject?;
      if (mr != null && mr.has('isTypeSupported')) {
        for (final entry in const [
          ['audio/webm;codecs=opus', 'webm'],
          ['audio/webm', 'webm'],
          ['audio/ogg;codecs=opus', 'ogg'],
          ['audio/mp4', 'mp4'],
        ]) {
          final ok = mr.callMethod('isTypeSupported'.toJS, entry[0].toJS) as JSBoolean?;
          if (ok != null && ok.toDart) {
            _ext = entry[1];
            return entry[0];
          }
        }
      }
    } catch (_) {}
    _ext = 'webm';
    return 'audio/webm';
  }

  @override
  Future<String?> start() async {
    if (_recording) return null;
    JSObject? md;
    try {
      final nav = globalContext.getProperty('navigator'.toJS) as JSObject?;
      md = nav?.getProperty('mediaDevices'.toJS) as JSObject?;
      final hasMr = globalContext.getProperty('MediaRecorder'.toJS) != null;
      if (md == null || !md.has('getUserMedia') || !hasMr) return 'unsupported';
    } catch (_) {
      return 'unsupported';
    }
    try {
      final constraints = JSObject()..setProperty('audio'.toJS, true.toJS);
      _stream = await (md.callMethod('getUserMedia'.toJS, constraints)
              as JSPromise<JSObject>)
          .toDart;
    } catch (e) {
      final n = e.toString();
      if (n.contains('NotFound') || n.contains('DevicesNotFound') || n.contains('Overconstrained')) {
        return 'no-mic';
      }
      return 'denied';
    }
    try {
      _mime = _pickMime();
      final opts = JSObject()..setProperty('mimeType'.toJS, _mime.toJS);
      final ctor = globalContext.getProperty('MediaRecorder'.toJS) as JSFunction;
      _recorder = ctor.callAsConstructor<JSObject>(_stream!, opts);
      _chunks.clear();
      // ondataavailable: acumula los blobs
      _recorder!.setProperty(
        'ondataavailable'.toJS,
        ((JSObject ev) {
          final data = ev.getProperty('data'.toJS) as JSObject?;
          if (data != null) {
            final size = (data.getProperty('size'.toJS) as JSNumber?)?.toDartDouble ?? 0;
            if (size > 0) _chunks.add(data as JSAny);
          }
        }).toJS,
      );
      _recorder!.callMethod('start'.toJS);
      _recording = true;
      _startedMs = _nowMs();
      return null;
    } catch (_) {
      _cleanup();
      return 'unsupported';
    }
  }

  @override
  Future<VoiceRecording?> stop() async {
    if (!_recording || _recorder == null) {
      _cleanup();
      return null;
    }
    final seconds = ((_nowMs() - _startedMs) / 1000).round();
    final completer = Completer<VoiceRecording?>();
    _done = completer;
    void onStop() {
      // fire-and-forget: la conversión a JS exige una función que devuelva void
      () async {
        try {
          final bytes = await _chunksToBytes();
          _cleanup();
          if (bytes == null || bytes.isEmpty) {
            if (!completer.isCompleted) completer.complete(null);
            return;
          }
          if (!completer.isCompleted) {
            completer.complete(VoiceRecording(
                bytes: bytes, ext: _ext, seconds: seconds < 1 ? 1 : seconds));
          }
        } catch (_) {
          _cleanup();
          if (!completer.isCompleted) completer.complete(null);
        }
      }();
    }

    _recorder!.setProperty('onstop'.toJS, onStop.toJS);
    _recording = false;
    try {
      _recorder!.callMethod('stop'.toJS);
    } catch (_) {
      _cleanup();
      if (!completer.isCompleted) completer.complete(null);
    }
    return completer.future;
  }

  @override
  void cancel() {
    _recording = false;
    try {
      if (_recorder != null) {
        _recorder!.setProperty('onstop'.toJS, (() {}).toJS);
        _recorder!.callMethod('stop'.toJS);
      }
    } catch (_) {}
    _cleanup();
    if (_done != null && !_done!.isCompleted) _done!.complete(null);
  }

  Future<Uint8List?> _chunksToBytes() async {
    if (_chunks.isEmpty) return null;
    // new Blob(chunks, {type}) → arrayBuffer() → Uint8List
    final blobCtor = globalContext.getProperty('Blob'.toJS) as JSFunction;
    final arr = JSArray();
    for (var i = 0; i < _chunks.length; i++) {
      arr.setProperty(i.toJS, _chunks[i]);
    }
    final opts = JSObject()..setProperty('type'.toJS, _mime.toJS);
    final blob = blobCtor.callAsConstructor<JSObject>(arr, opts);
    final buf = await (blob.callMethod('arrayBuffer'.toJS) as JSPromise<JSArrayBuffer>).toDart;
    return buf.toDart.asUint8List();
  }

  int _nowMs() {
    try {
      final perf = globalContext.getProperty('performance'.toJS) as JSObject?;
      final n = perf?.callMethod('now'.toJS) as JSNumber?;
      if (n != null) return n.toDartDouble.round();
    } catch (_) {}
    return 0;
  }

  void _cleanup() {
    try {
      if (_stream != null) {
        final tracks = (_stream!.callMethod('getTracks'.toJS) as JSArray).toDart;
        for (final t in tracks) {
          (t as JSObject).callMethod('stop'.toJS);
        }
      }
    } catch (_) {}
    _stream = null;
    _recorder = null;
    _chunks.clear();
  }
}
