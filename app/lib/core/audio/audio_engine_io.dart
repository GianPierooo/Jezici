import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

import 'audio_engine.dart';

AudioEngine makeAudioEngine() => _IoAudioEngine();

/// Nativo (Android/iOS app): usa audioplayers. (El bug del reproductor en la
/// pantalla de bloqueo es específico de <audio> en web; en nativo el SO maneja
/// la sesión de audio aparte.)
class _IoAudioEngine implements AudioEngine {
  final List<AudioPlayer> _pool = List.generate(4, (_) => AudioPlayer());
  int _next = 0;
  AudioPlayer? _url;
  StreamSubscription? _completeSub;

  @override
  void unlock() {}

  @override
  Future<void> prefetch(String url) async {
    // Nativo: audioplayers carga desde el caché del SO; pre-cargamos best-effort
    // fijando la fuente en el reproductor de URL para acelerar el primer play.
    try {
      await (_url ??= AudioPlayer()).setSourceUrl(url);
    } catch (_) {}
  }

  @override
  Future<void> playAsset(String assetKey, {double volume = 0.7}) async {
    final p = _pool[_next];
    _next = (_next + 1) % _pool.length;
    try {
      await p.stop();
      await p.play(AssetSource(assetKey), volume: volume);
    } catch (_) {}
  }

  @override
  Future<void> playUrl(String url, {double volume = 1.0, void Function()? onComplete}) async {
    try {
      final p = _url ??= AudioPlayer();
      // Cancela la suscripción previa antes de re-suscribir (evita fuga/disparos viejos).
      await _completeSub?.cancel();
      _completeSub = null;
      if (onComplete != null) {
        _completeSub = p.onPlayerComplete.listen((_) => onComplete());
      }
      await p.stop();
      await p.play(UrlSource(url), volume: volume);
    } catch (_) {}
  }

  @override
  Future<void> stop() async {
    try {
      await _completeSub?.cancel();
      _completeSub = null;
      await _url?.stop();
    } catch (_) {}
  }
}
