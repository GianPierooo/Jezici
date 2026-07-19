/// Comparación TOLERANTE de texto para speaking (GA8 + fix audio/medios). El
/// reconocimiento es imperfecto: una lectura razonable debe APROBAR. Normaliza
/// ambos textos (incluye NÚMEROS dígitos↔palabras y homófonos/contracciones
/// comunes) y combina solapamiento de palabras + ratio de Levenshtein.
library;

// ── Normalización de números (dígitos ↔ palabras) ───────────────────────────
// El reconocedor a veces devuelve "12345" / "1 2 3" / "1,2,3" donde se esperan
// palabras ("one two three four five"), y viceversa. Canonizamos AMBOS lados a
// dígitos antes de comparar (0–100 + cientos/miles comunes).
const Map<String, int> _ones = {
  'zero': 0, 'oh': 0, 'one': 1, 'two': 2, 'three': 3, 'four': 4, 'five': 5,
  'six': 6, 'seven': 7, 'eight': 8, 'nine': 9, 'ten': 10, 'eleven': 11,
  'twelve': 12, 'thirteen': 13, 'fourteen': 14, 'fifteen': 15, 'sixteen': 16,
  'seventeen': 17, 'eighteen': 18, 'nineteen': 19,
};
const Map<String, int> _tens = {
  'twenty': 20, 'thirty': 30, 'forty': 40, 'fifty': 50, 'sixty': 60,
  'seventy': 70, 'eighty': 80, 'ninety': 90,
};

/// Convierte palabras-número a dígitos en un texto ya en minúsculas y separado
/// por espacios. Maneja compuestos de dos palabras ("twenty one"→21,
/// "one hundred"→100) y "a hundred". No toca el resto del texto.
String wordsToDigits(String s) {
  final tokens = s.split(' ').where((t) => t.isNotEmpty).toList();
  final out = <String>[];
  var i = 0;
  while (i < tokens.length) {
    final t = tokens[i];
    final next = i + 1 < tokens.length ? tokens[i + 1] : '';
    // decenas + unidad: "twenty one" → 21
    if (_tens.containsKey(t) && _ones.containsKey(next) && (_ones[next] ?? 0) < 10) {
      out.add('${_tens[t]! + _ones[next]!}');
      i += 2;
      continue;
    }
    // N hundred → N*100  ("one hundred", "a hundred")
    if ((_ones.containsKey(t) || t == 'a') && next == 'hundred') {
      final base = t == 'a' ? 1 : _ones[t]!;
      out.add('${base * 100}');
      i += 2;
      continue;
    }
    if (t == 'hundred') { out.add('100'); i += 1; continue; }
    if (t == 'thousand') { out.add('1000'); i += 1; continue; }
    if (_tens.containsKey(t)) { out.add('${_tens[t]}'); i += 1; continue; }
    if (_ones.containsKey(t)) { out.add('${_ones[t]}'); i += 1; continue; }
    out.add(t);
    i += 1;
  }
  return out.join(' ');
}

// Homófonos/variantes comunes que el reconocedor confunde — se canonizan a una
// sola forma para no penalizar una lectura correcta.
const Map<String, String> _homophones = {
  'u': 'you', 'ur': 'your', 'r': 'are', 'thru': 'through', 'wanna': 'want to',
  'gonna': 'going to', 'gotta': 'got to', 'cause': 'because', 'till': 'until',
  'ok': 'okay', 'pls': 'please', 'thx': 'thanks',
};

String normalizeSpeech(String s) {
  var t = s
      .toLowerCase()
      .replaceAll(RegExp(r"[''´`]"), "'") // unifica apóstrofes tipográficos
      .replaceAll("'", '') // contracciones: don't→dont, it's→its (el grader ignora apóstrofes)
      .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ') // quita puntuación/símbolos
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  if (t.isEmpty) return t;
  // homófonos token a token
  t = t.split(' ').map((w) => _homophones[w] ?? w).join(' ');
  // números a dígitos en ambos lados
  t = wordsToDigits(t);
  return t.replaceAll(RegExp(r'\s+'), ' ').trim();
}

/// Sólo los dígitos del texto, concatenados ("one two three"→"123",
/// "12345"→"12345", "1 2 3"→"123"). Sirve para casar secuencias numéricas
/// aunque el reconocedor las pegue o separe.
String _digitString(String normalized) =>
    normalized.replaceAll(RegExp(r'[^0-9]'), '');

int _levenshtein(String a, String b) {
  if (a == b) return 0;
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;
  final prev = List<int>.generate(b.length + 1, (i) => i);
  final curr = List<int>.filled(b.length + 1, 0);
  for (var i = 0; i < a.length; i++) {
    curr[0] = i + 1;
    for (var j = 0; j < b.length; j++) {
      final cost = a.codeUnitAt(i) == b.codeUnitAt(j) ? 0 : 1;
      curr[j + 1] = [curr[j] + 1, prev[j + 1] + 1, prev[j] + cost].reduce((x, y) => x < y ? x : y);
    }
    for (var k = 0; k <= b.length; k++) {
      prev[k] = curr[k];
    }
  }
  return prev[b.length];
}

/// 0..1: qué tan cerca está lo oído del texto esperado (más alto = mejor).
double speechMatchRatio(String heard, String expected) {
  final h = normalizeSpeech(heard);
  final e = normalizeSpeech(expected);
  if (e.isEmpty || h.isEmpty) return 0;
  if (h == e) return 1;

  // 0) Secuencia numérica: "one two three" ↔ "123" ↔ "1 2 3". Si la esperada es
  //    esencialmente numérica y los dígitos coinciden, es un acierto pleno.
  final ed = _digitString(e);
  final hd = _digitString(h);
  if (ed.isNotEmpty && ed == hd) {
    // la esperada es mayormente números (p.ej. "one two three four five")
    final eDigitsShare = ed.length / e.replaceAll(' ', '').length;
    if (eDigitsShare >= 0.6) return 1;
  }

  // 1) Solapamiento de palabras (cuántas palabras esperadas aparecen).
  final hw = h.split(' ').where((w) => w.isNotEmpty).toList();
  final ew = e.split(' ').where((w) => w.isNotEmpty).toList();
  final hwSet = hw.toSet();
  final hit = ew.where(hwSet.contains).length;
  final wordOverlap = ew.isEmpty ? 0.0 : hit / ew.length;

  // 2) Ratio de Levenshtein a nivel de carácter.
  final dist = _levenshtein(h, e);
  final maxLen = h.length > e.length ? h.length : e.length;
  final charRatio = maxLen == 0 ? 0.0 : 1 - dist / maxLen;

  // El mejor de ambos (lenient): una buena lectura pasa aunque falte una palabra.
  return wordOverlap > charRatio ? wordOverlap : charRatio;
}

/// ¿Aprueba? Umbral indulgente por defecto (reconocimiento imperfecto).
bool speechPasses(String heard, String expected, {double threshold = 0.6}) =>
    speechMatchRatio(heard, expected) >= threshold;

/// Colapsa REPETICIONES CONSECUTIVAS de la transcripción en vivo. Bug real de
/// WebKit/Safari (y visto en Brave/Android): con `interimResults`, el reconocedor
/// re-emite el mismo parcial que crece → la UI mostraba texto EN BUCLE, p.ej.
/// «that that weekend that weekend that weekend Blade that weekend Blade with my
/// friends». Este colapso deja «that weekend Blade with my friends».
///
/// Conservador y determinista: solo quita repeticiones INMEDIATAS (adyacentes)
/// de 1–4 palabras (elimina la 2ª copia): «that that»→«that», «good morning good
/// morning»→«good morning», «the the the»→«the». NO toca repeticiones separadas
/// por otro texto («the dog and the cat» se preserva). Compara en minúsculas y
/// preserva mayúsculas/acentos del original.
String collapseSpeechRepeats(String s) {
  final words = s.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  if (words.length < 2) return words.join(' ');
  var changed = true;
  var guard = 0;
  while (changed && guard++ < 500) {
    changed = false;
    // Frases de 4→1 palabras repetidas inmediatamente. El orden (grande→pequeño)
    // colapsa antes los bigramas/trigramas y luego cualquier palabra doblada.
    for (var n = 4; n >= 1 && !changed; n--) {
      for (var i = 0; i + 2 * n <= words.length; i++) {
        var dup = true;
        for (var k = 0; k < n; k++) {
          if (words[i + k].toLowerCase() != words[i + n + k].toLowerCase()) {
            dup = false;
            break;
          }
        }
        if (dup) {
          words.removeRange(i + n, i + 2 * n);
          changed = true;
          break;
        }
      }
    }
  }
  return words.join(' ');
}
