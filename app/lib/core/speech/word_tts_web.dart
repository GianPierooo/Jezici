import 'dart:js_interop';
import 'dart:js_interop_unsafe';

/// Pronuncia una palabra con Web Speech API (window.speechSynthesis). Interrumpible
/// (cancela lo anterior), ritmo levemente lento, en el idioma [lang] (BCP-47) del
/// curso activo. Degradación con gracia: si el dispositivo no soporta síntesis o algo
/// falla, no hace nada (no crashea). Si no hay voz instalada para [lang], el navegador
/// usa la mejor disponible; nunca bloquea.
void speakWord(String word, String lang) {
  try {
    if (!globalContext.has('speechSynthesis') || !globalContext.has('SpeechSynthesisUtterance')) {
      return;
    }
    final synth = globalContext.getProperty('speechSynthesis'.toJS) as JSObject?;
    final ctor = globalContext.getProperty('SpeechSynthesisUtterance'.toJS);
    if (synth == null || ctor == null) return;
    synth.callMethod('cancel'.toJS); // corto + interrumpible: no encola
    final u = (ctor as JSFunction).callAsConstructor<JSObject>(word.toJS);
    u.setProperty('lang'.toJS, lang.toJS);
    u.setProperty('rate'.toJS, (0.9).toJS);
    synth.callMethod('speak'.toJS, u);
  } catch (_) {/* sin síntesis → nada (no estorba el armado) */}
}
