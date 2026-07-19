import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

/// Pronuncia texto con la Web Speech API (`window.speechSynthesis`) en el idioma
/// [lang] (BCP-47, p.ej. 'en-US' / 'fr-FR' / 'pt-BR' / 'es-ES'). ÚNICO punto de
/// selección de voz TTS EN VIVO de la app: `WordTts.speak`/`speakSource` (tiles,
/// SpeakableText, SpeakablePhrase, glosario, tips, SRS…) pasan todos por aquí, así
/// que la lógica de voz vive en un solo sitio y suena IGUAL en todas las pantallas.
///
/// El audio de LISTENING/historias es distinto: son clips MP3 pregrabados (Google
/// TTS nativo) servidos por `AudioEngine`. Regla: si el ítem trae audio pregrabado
/// se usa ése; el TTS en vivo es solo para lo que NO tiene clip. No se mezclan dos
/// voces del MISMO origen.
///
/// BUG REAL (dos voces / acento incorrecto) — causas y arreglo:
///  1. TIMING: `getVoices()` llega VACÍO en el primer tick tras cargar la página y
///     se puebla async por el evento `voiceschanged`. La versión previa, si la lista
///     estaba vacía, hablaba igual → el navegador usaba su voz POR DEFECTO (en un
///     equipo en español, una voz ESPAÑOLA) → leía inglés con acento español, y solo
///     los toques POSTERIORES (ya con voces cargadas) sonaban nativos → "a veces una,
///     a veces otra". FIX: si las voces aún no cargaron, se DIFIERE la locución hasta
///     `voiceschanged` (con un fallback temporizado para no quedar en silencio) → la
///     PRIMERA locución ya sale con la voz nativa.
///  2. VOZ genérica: antes se elegía la primera coincidencia de idioma base. FIX:
///     ranking por calidad (exacta de región + voz de red tipo Google/Natural/Neural
///     + `localService`), voz elegida CACHEADA por idioma → misma voz cada vez.
///  3. Precarga: `primeVoices()` se llama al arrancar la app para que la caché ya
///     esté caliente antes del primer toque.
/// Degrada honesto: si el dispositivo no tiene voz del idioma pedido, se deja solo
/// `lang` (NUNCA se fuerza una voz de OTRO idioma).

JSArray<JSObject>? _voicesCache;
bool _voicesListenerSet = false;
final Map<String, JSObject?> _chosen = {}; // lang(lower) -> voz elegida (estable)

// Locución pendiente mientras las voces cargan (TTS es "cancel + speak": solo
// interesa la ÚLTIMA pedida).
String? _pendingWord;
String? _pendingLang;
Timer? _pendingFallback;

JSObject? _synth() {
  if (!globalContext.has('speechSynthesis') || !globalContext.has('SpeechSynthesisUtterance')) {
    return null;
  }
  return globalContext.getProperty('speechSynthesis'.toJS) as JSObject?;
}

/// Precarga las voces lo antes posible (llamar al arrancar la app en web). Idempotente.
void primeVoices() {
  final synth = _synth();
  if (synth != null) _ensureVoices(synth);
}

/// ¿Ya cargaron las voces del navegador? (getVoices() llega vacío al arrancar y
/// se puebla async). Sirve para NO avisar "sin voz" antes de tiempo.
bool ttsVoicesReady() {
  final synth = _synth();
  if (synth == null) return false;
  _ensureVoices(synth);
  return _voicesCache != null && _voicesCache!.length > 0;
}

/// ¿El dispositivo tiene ALGUNA voz para el idioma base de [lang] (p.ej. 'fr' de
/// 'fr-FR')? Si no, el TTS EN VIVO (tiles/SRS/glosario) sale mudo (el audio de
/// lecciones, que es MP3, no se afecta). null si las voces aún no cargaron.
bool? ttsHasVoice(String lang) {
  final synth = _synth();
  if (synth == null) return false; // sin síntesis: nunca habrá voz
  _ensureVoices(synth);
  final voices = _voicesCache;
  if (voices == null || voices.length == 0) return null; // aún cargando
  final base = lang.toLowerCase().split('-').first;
  for (var i = 0; i < voices.length; i++) {
    final vl = ((voices[i].getProperty('lang'.toJS) as JSString?)?.toDart ?? '')
        .toLowerCase()
        .replaceAll('_', '-');
    if (vl.isNotEmpty && vl.split('-').first == base) return true;
  }
  return false;
}

void speakWord(String word, String lang) {
  try {
    final synth = _synth();
    if (synth == null) return;
    final ctor = globalContext.getProperty('SpeechSynthesisUtterance'.toJS);
    if (ctor == null) return;

    _ensureVoices(synth);

    // Voces aún sin cargar → NO hables con la voz por defecto (suele ser española).
    // Difiere hasta `voiceschanged`; un fallback temporizado evita el silencio si el
    // evento nunca llega (p.ej. navegadores que pueblan getVoices de forma síncrona
    // pero por otro motivo devolvieron vacío).
    if (_voicesCache == null || _voicesCache!.length == 0) {
      _pendingWord = word;
      _pendingLang = lang;
      _pendingFallback?.cancel();
      _pendingFallback = Timer(const Duration(milliseconds: 350), () {
        final w = _pendingWord, l = _pendingLang;
        _pendingWord = null;
        _pendingLang = null;
        if (w != null && l != null) {
          final s = _synth();
          final c = globalContext.getProperty('SpeechSynthesisUtterance'.toJS);
          if (s != null && c != null) _emit(s, c, w, l);
        }
      });
      return;
    }

    _emit(synth, ctor, word, lang);
  } catch (_) {/* sin síntesis -> nada (no estorba el armado) */}
}

void _emit(JSObject synth, JSAny ctor, String word, String lang) {
  try {
    synth.callMethod('cancel'.toJS); // corto + interrumpible: no encola
    final u = (ctor as JSFunction).callAsConstructor<JSObject>(word.toJS);
    u.setProperty('lang'.toJS, lang.toJS);
    u.setProperty('rate'.toJS, (0.9).toJS);
    final voice = _pickVoice(lang);
    if (voice != null) u.setProperty('voice'.toJS, voice);
    synth.callMethod('speak'.toJS, u);
  } catch (_) {}
}

/// Cachea las voces y se suscribe a `voiceschanged` (las voces cargan async; en el
/// primer render getVoices() suele venir vacío). Al llegar las voces, purga la caché
/// de voz elegida y LANZA cualquier locución pendiente (arregla la primera vez).
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
            if (v2 != null && v2.length > 0) {
              _voicesCache = v2;
              _chosen.clear(); // la lista cambió → recalcular la voz elegida
            }
            // Lanza la locución que quedó pendiente por voces sin cargar.
            final w = _pendingWord, l = _pendingLang;
            if (w != null && l != null && _voicesCache != null && _voicesCache!.length > 0) {
              _pendingWord = null;
              _pendingLang = null;
              _pendingFallback?.cancel();
              final c = globalContext.getProperty('SpeechSynthesisUtterance'.toJS);
              if (c != null) _emit(synth, c, w, l);
            }
          } catch (_) {}
        }).toJS,
      );
    }
  } catch (_) {}
}

/// Elige (y cachea) la MEJOR voz para [lang], por puntuación:
///  +100 región exacta (en-US == en-US)  ·  +20 voz de alta calidad por nombre
///  (Google/Natural/Neural/Microsoft/Premium/Enhanced)  ·  +5 `localService`.
/// Solo entre voces del MISMO idioma base (en-* para 'en-US'); jamás otro idioma.
/// Sin coincidencia → null (el navegador usa `lang`, mejor que forzar la default).
JSObject? _pickVoice(String lang) {
  final want = lang.toLowerCase();
  if (_chosen.containsKey(want)) return _chosen[want];

  final voices = _voicesCache;
  if (voices == null || voices.length == 0) return null;
  final base = want.split('-').first; // 'en'

  JSObject? best;
  int bestScore = -1;
  for (var i = 0; i < voices.length; i++) {
    final voice = voices[i];
    final vl = ((voice.getProperty('lang'.toJS) as JSString?)?.toDart ?? '').toLowerCase();
    if (vl.isEmpty) continue;
    final vlNorm = vl.replaceAll('_', '-');
    if (vlNorm.split('-').first != base) continue; // otro idioma: nunca

    final name = ((voice.getProperty('name'.toJS) as JSString?)?.toDart ?? '').toLowerCase();
    final local = (voice.getProperty('localService'.toJS) as JSBoolean?)?.toDart ?? false;

    var score = 0;
    if (vlNorm == want) score += 100;
    if (name.contains('google') ||
        name.contains('natural') ||
        name.contains('neural') ||
        name.contains('microsoft') ||
        name.contains('premium') ||
        name.contains('enhanced')) {
      score += 20;
    }
    if (local) score += 5;

    if (score > bestScore) {
      bestScore = score;
      best = voice;
    }
  }
  _chosen[want] = best; // cachea (incluye null: no hay voz de ese idioma)
  return best;
}
