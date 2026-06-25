import 'dart:js_interop';
import 'dart:js_interop_unsafe';

/// Pronuncia una palabra con Web Speech API (window.speechSynthesis). Interrumpible
/// (cancela lo anterior), inglés, ritmo levemente lento. Degradación con gracia: si
/// el dispositivo no soporta síntesis o algo falla, no hace nada (no crashea).
void speakWord(String word) {
  try {
    if (!globalContext.has('speechSynthesis') || !globalContext.has('SpeechSynthesisUtterance')) {
      return;
    }
    final synth = globalContext.getProperty('speechSynthesis'.toJS) as JSObject?;
    final ctor = globalContext.getProperty('SpeechSynthesisUtterance'.toJS);
    if (synth == null || ctor == null) return;
    synth.callMethod('cancel'.toJS); // corto + interrumpible: no encola
    final u = (ctor as JSFunction).callAsConstructor<JSObject>(word.toJS);
    u.setProperty('lang'.toJS, 'en-US'.toJS);
    u.setProperty('rate'.toJS, (0.9).toJS);
    synth.callMethod('speak'.toJS, u);
  } catch (_) {/* sin síntesis → nada (no estorba el armado) */}
}
