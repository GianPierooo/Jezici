import 'package:flutter/foundation.dart' show Uint8List;

import 'voice_recorder_io.dart'
    if (dart.library.js_interop) 'voice_recorder_web.dart';

/// Resultado de una grabación de nota de voz.
class VoiceRecording {
  const VoiceRecording({required this.bytes, required this.ext, required this.seconds});
  final Uint8List bytes;
  final String ext; // webm | ogg | mp4 | wav
  final int seconds;
}

/// Grabador de audio corto (notas de voz de Conversar). Web usa MediaRecorder;
/// fuera de web es un stub no-soportado (degradación honesta).
abstract class VoiceRecorder {
  factory VoiceRecorder() => createVoiceRecorderImpl();

  /// Pide permiso + arranca. Devuelve null si OK, o un código de error
  /// ('unsupported' | 'denied' | 'no-mic').
  Future<String?> start();

  /// Detiene y devuelve la grabación (null si nada/error).
  Future<VoiceRecording?> stop();

  /// Cancela y libera sin devolver nada.
  void cancel();

  bool get isRecording;
}
