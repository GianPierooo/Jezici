import 'speech_lang.dart';
import 'word_tts_io.dart' if (dart.library.js_interop) 'word_tts_web.dart' as impl;

/// Pronuncia una palabra al tocar una tile (TASK 3). Usa Web Speech API en web
/// (cero archivos, cero peso); no-op en plataformas sin síntesis. Disparado por el
/// TAP (gesto real) → sin el problema de desbloqueo de audio de iOS. Interrumpible
/// y con degradación con gracia (nunca crashea, nunca bloquea el armado).
/// Pronuncia en el idioma del CURSO activo (`SpeechLang.tts`), no en inglés fijo.
class WordTts {
  static void speak(String word) {
    final w = word.trim();
    if (w.isEmpty) return;
    impl.speakWord(w, SpeechLang.tts);
  }
}
