/// Comparación TOLERANTE de texto para speaking (GA8). El reconocimiento es
/// imperfecto: una lectura razonable debe APROBAR. Normaliza ambos textos y
/// combina solapamiento de palabras + ratio de Levenshtein a nivel de carácter.
library;

String normalizeSpeech(String s) => s
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ') // quita puntuación/símbolos/apóstrofes
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

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
  if (e.isEmpty) return 0;
  if (h.isEmpty) return 0;

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
