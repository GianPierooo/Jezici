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

  // Música de fondo (loop) — reproductor dedicado; ducking por volumen.
  AudioPlayer? _music;
  String? _musicUrl;
  double _musicVolume = 0.16;
  Timer? _unduckTimer;

  @override
  void unlock() {}

  @override
  Future<bool> isUrlAvailable(String url) async => true; // nativo: optimista

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
    _duckMusic(650);
    final p = _pool[_next];
    _next = (_next + 1) % _pool.length;
    try {
      await p.stop();
      await p.play(AssetSource(assetKey), volume: volume);
    } catch (_) {}
  }

  @override
  Future<void> playUrl(String url,
      {double volume = 1.0, void Function()? onComplete, void Function(String reason)? onError}) async {
    try {
      final p = _url ??= AudioPlayer();
      // Cancela la suscripción previa antes de re-suscribir (evita fuga/disparos viejos).
      await _completeSub?.cancel();
      _completeSub = null;
      _duckMusic(15000); // fallback; el onComplete desduckea antes
      if (onComplete != null) {
        _completeSub = p.onPlayerComplete.listen((_) {
          _unduckMusic();
          onComplete();
        });
      }
      await p.stop();
      await p.play(UrlSource(url), volume: volume);
    } catch (_) {
      _unduckMusic();
      onError?.call('play');
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _completeSub?.cancel();
      _completeSub = null;
      await _url?.stop();
    } catch (_) {}
  }

  @override
  Future<void> startLoop(String url, {double volume = 0.16}) async {
    _musicVolume = volume;
    if (_musicUrl == url && _music != null) return; // ya sonando esa URL
    try {
      final m = _music ??= AudioPlayer();
      await m.setReleaseMode(ReleaseMode.loop); // loop nativo
      await m.stop();
      await m.play(UrlSource(url), volume: volume);
      _musicUrl = url;
    } catch (_) {}
  }

  @override
  Future<void> stopLoop() async {
    _unduckTimer?.cancel();
    _unduckTimer = null;
    _musicUrl = null;
    try {
      await _music?.stop();
    } catch (_) {}
  }

  void _duckMusic(int ms) {
    if (_music == null || _musicUrl == null) return;
    try {
      _music!.setVolume(_musicVolume * 0.16);
    } catch (_) {}
    _unduckTimer?.cancel();
    _unduckTimer = Timer(Duration(milliseconds: ms), _unduckMusic);
  }

  void _unduckMusic() {
    _unduckTimer?.cancel();
    _unduckTimer = null;
    if (_music == null || _musicUrl == null) return;
    try {
      _music!.setVolume(_musicVolume);
    } catch (_) {}
  }
}
