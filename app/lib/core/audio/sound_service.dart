import 'audio_engine.dart';

/// Microinteracciones de audio (Sistema_Diseno · GA8 + fix medios). Suena vía
/// AudioEngine (Web Audio API en web → SIN reproductor en la pantalla de
/// bloqueo). Silenciable (enabled). El AudioContext se desbloquea con el primer
/// gesto del usuario (warmUp desde un tap).
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

  bool _warm = false;

  /// Llamar una vez tras el primer gesto (desbloquea AudioContext en web/iOS).
  void warmUp() {
    if (_warm) return;
    _warm = true;
    AudioEngine.instance.unlock();
  }

  Future<void> play(Sfx s) async {
    if (!enabled) return;
    warmUp();
    await AudioEngine.instance.playAsset(_files[s]!, volume: 0.7);
  }
}
