import 'audio_engine_io.dart' if (dart.library.js_interop) 'audio_engine_web.dart';

/// Motor de audio que NO usa elementos <audio> en web (la causa de que iOS
/// Safari muestre el reproductor "now-playing" en la pantalla de bloqueo). En
/// web reproduce vía Web Audio API (AudioContext → BufferSource), que no crea
/// MediaSession. En nativo usa audioplayers (separado del bundle web).
abstract class AudioEngine {
  static final AudioEngine instance = makeAudioEngine();

  /// SFX desde un asset bundleado (clave relativa a assets/, p.ej. 'sfx/correct.wav').
  /// Decodifica una vez y cachea el buffer.
  Future<void> playAsset(String assetKey, {double volume = 0.7});

  /// TTS / listening desde una URL de red. Cachea el buffer decodificado por URL.
  Future<void> playUrl(String url, {double volume = 1.0, void Function()? onComplete});

  /// Pre-descarga + decodifica el audio de una URL al caché SIN reproducir, para
  /// que el siguiente `playUrl` sea instantáneo (time-to-first-audio mínimo).
  /// Best-effort: silencioso si falla o no hay motor.
  Future<void> prefetch(String url);

  /// Reanuda el AudioContext tras el primer gesto (desbloqueo en web/iOS).
  void unlock();

  /// Detiene cualquier reproducción de URL en curso (para no solapar TTS).
  Future<void> stop();
}
