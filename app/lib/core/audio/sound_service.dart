import 'package:audioplayers/audioplayers.dart';

/// Microinteracciones de audio (Sistema_Diseno · GA8). Pool de reproductores
/// para no cortar sonidos encadenados. Silenciable (enabled). En web el audio
/// se desbloquea con el primer gesto del usuario (se reproduce desde taps).
enum Sfx { correct, wrong, combo, lessonComplete, levelUp, celebrate, streak }

class SoundService {
  SoundService._();
  static final SoundService instance = SoundService._();

  bool enabled = true;
  static const _files = {
    Sfx.correct: 'sfx/correct.wav',
    Sfx.wrong: 'sfx/wrong.wav',
    Sfx.combo: 'sfx/combo.wav',
    Sfx.lessonComplete: 'sfx/lesson_complete.wav',
    Sfx.levelUp: 'sfx/level_up.wav',
    Sfx.celebrate: 'sfx/celebrate.wav',
    Sfx.streak: 'sfx/streak.wav',
  };

  final List<AudioPlayer> _pool = List.generate(4, (_) => AudioPlayer());
  int _next = 0;
  bool _warm = false;

  /// Llamar una vez tras el primer gesto (desbloquea AudioContext en web).
  void warmUp() {
    if (_warm) return;
    _warm = true;
    for (final p in _pool) {
      try {
        p.setReleaseMode(ReleaseMode.stop);
        p.setVolume(0.7);
      } catch (_) {}
    }
  }

  Future<void> play(Sfx s) async {
    if (!enabled) return;
    warmUp();
    final p = _pool[_next];
    _next = (_next + 1) % _pool.length;
    try {
      await p.stop();
      await p.play(AssetSource(_files[s]!), volume: 0.7);
    } catch (_) {}
  }
}
