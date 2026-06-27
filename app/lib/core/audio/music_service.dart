import 'audio_engine.dart';

/// Música ambiente del MAPA (viaje hacia la fluidez). Loop SUTIL vía AudioEngine —
/// en web va por el MISMO AudioContext que SFX/TTS → SIN reproductor en la pantalla
/// de bloqueo (no reactiva MediaSession). Reglas de producto:
///  · SOLO en el mapa (nunca en lecciones/checkpoints/exámenes).
///  · Default APAGADA (opt-in): muchos usan su propio audio; pisarlo = desinstalan.
///  · Ducking automático (lo hace el AudioEngine en playAsset/playUrl).
///  · Pausa al salir del mapa y al backgroundear.
/// La música suena solo si: enabled && en el mapa && app en foreground.
class MusicService {
  MusicService._();
  static final MusicService instance = MusicService._();

  static const _loopUrl =
      'https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/ambient/map_loop.wav';
  static const _volume = 0.16; // sutil; el ducking baja aún más

  bool enabled = false; // ⬅ default APAGADA
  bool _onMap = false;
  bool _resumed = true;
  bool _suppressed = false; // true durante lección/checkpoint/examen (sobre el mapa)

  void setOnMap(bool v) {
    if (_onMap == v) return;
    _onMap = v;
    _apply();
  }

  void setResumed(bool v) {
    if (_resumed == v) return;
    _resumed = v;
    _apply();
  }

  void setEnabled(bool v) {
    if (enabled == v) return;
    enabled = v;
    _apply();
  }

  /// Las pantallas de EJERCICIO (lección/checkpoint/examen) se montan SOBRE el mapa
  /// (Navigator.push), por lo que el shell sigue "en el mapa". Estas suprimen la
  /// música mientras están activas (regla: nunca durante el ejercicio).
  void setSuppressed(bool v) {
    if (_suppressed == v) return;
    _suppressed = v;
    _apply();
  }

  void _apply() {
    if (enabled && _onMap && _resumed && !_suppressed) {
      AudioEngine.instance.unlock(); // por si el contexto está suspendido
      AudioEngine.instance.startLoop(_loopUrl, volume: _volume);
    } else {
      AudioEngine.instance.stopLoop();
    }
  }
}
