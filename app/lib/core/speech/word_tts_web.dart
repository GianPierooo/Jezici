import 'dart:js_interop';
import 'dart:js_interop_unsafe';

/// Pronuncia una palabra con Web Speech API (window.speechSynthesis) en el idioma
/// [lang] (BCP-47, p.ej. 'en-US' / 'fr-FR' / 'pt-BR').
///
/// BUG REAL corregido: antes solo se ponía `utterance.lang` PERO NO `.voice`. Con
/// una voz por defecto española (frecuente en dispositivos en español), muchos
/// navegadores IGNORAN el `lang` y leen las palabras inglesas con acento español
/// -> pronunciación incorrecta (gravísimo en una app de idiomas). Ahora se ELIGE
/// explícitamente una voz cuyo `lang` empiece por el idioma pedido y se fija en el
/// utterance. Degrada honesto: si el dispositivo no tiene voz de ese idioma, usa
/// la mejor coincidencia parcial o -en último caso- deja solo `lang` (nunca fuerza
/// la voz española sobre otro idioma). `getVoices()` es asíncrono: se resuelve con
/// el evento `voiceschanged` y se cachea.
JSArray<JSObject>? _voicesCache;
bool _voicesListenerSet = false;

void speakWord(String word, String lang) {
  try {
    if (!globalContext.has('speechSynthesis') || !globalContext.has('SpeechSynthesisUtterance')) {
      return;
    }
    final synth = globalContext.getProperty('speechSynthesis'.toJS) as JSObject?;
    final ctor = globalContext.getProperty('SpeechSynthesisUtterance'.toJS);
    if (synth == null || ctor == null) return;

    _ensureVoices(synth);

    synth.callMethod('cancel'.toJS); // corto + interrumpible: no encola
    final u = (ctor as JSFunction).callAsConstructor<JSObject>(word.toJS);
    u.setProperty('lang'.toJS, lang.toJS);
    u.setProperty('rate'.toJS, (0.9).toJS);

    final voice = _pickVoice(lang);
    if (voice != null) u.setProperty('voice'.toJS, voice);

    synth.callMethod('speak'.toJS, u);
  } catch (_) {/* sin síntesis -> nada (no estorba el armado) */}
}

/// Cachea las voces y se re-suscribe a `voiceschanged` (las voces cargan async;
/// en el primer render getVoices() suele venir vacío).
void _ensureVoices(JSObject synth) {
  try {
    final v = synth.callMethod('getVoices'.toJS) as JSArray<JSObject>?;
    if (v != null && v.length > 0) _voicesCache = v;
    if (!_voicesListenerSet) {
      _voicesListenerSet = true;
      synth.setProperty(
        'onvoiceschanged'.toJS,
        (() {
          try {
            final v2 = synth.callMethod('getVoices'.toJS) as JSArray<JSObject>?;
            if (v2 != null && v2.length > 0) _voicesCache = v2;
          } catch (_) {}
        }).toJS,
      );
    }
  } catch (_) {}
}

/// Elige la mejor voz para [lang]:
///  1) coincidencia EXACTA de BCP-47 (en-US == en-US);
///  2) mismo idioma base (en-* para 'en-US'), prefiriendo voz `localService`;
///  3) null -> el navegador usa `lang` (mejor que forzar la voz por defecto).
JSObject? _pickVoice(String lang) {
  final voices = _voicesCache;
  if (voices == null || voices.length == 0) return null;
  final want = lang.toLowerCase();
  final base = want.split('-').first; // 'en'

  JSObject? exact;
  JSObject? sameLangLocal;
  JSObject? sameLang;
  for (var i = 0; i < voices.length; i++) {
    final voice = voices[i];
    final vl = ((voice.getProperty('lang'.toJS) as JSString?)?.toDart ?? '').toLowerCase();
    if (vl.isEmpty) continue;
    final vlNorm = vl.replaceAll('_', '-');
    if (vlNorm == want) {
      exact = voice;
      break;
    }
    if (vlNorm.split('-').first == base) {
      final local = (voice.getProperty('localService'.toJS) as JSBoolean?)?.toDart ?? false;
      if (local && sameLangLocal == null) sameLangLocal = voice;
      sameLang ??= voice;
    }
  }
  return exact ?? sameLangLocal ?? sameLang;
}
