import '../../../data/models/content_item_model.dart';

/// Resultado de calificar un ejercicio (determinista, 100% local).
class GradeResult {
  const GradeResult({
    required this.correct,
    required this.graded,
    required this.correctDisplay,
  });

  /// ¿La respuesta del usuario coincide con la esperada?
  final bool correct;

  /// ¿El ítem se califica? Los stubs (listening/speaking sin audio/STT) no.
  final bool graded;

  /// Texto de la respuesta correcta para el feedback.
  final String correctDisplay;

  static const stub = GradeResult(correct: true, graded: false, correctDisplay: '');
}

/// Normaliza para comparar: minúsculas, espacios colapsados, sin puntuación final.
String normalize(String s) => s
    .toLowerCase()
    .trim()
    .replaceAll(RegExp(r'\s+'), ' ')
    .replaceAll(RegExp(r'[.!?¿¡,;:]'), '')
    .trim();

/// Coerción defensiva: un campo jsonb mal formado (escalar donde se espera
/// lista) no debe crashear el loop; se degrada a lista vacía.
List _asList(dynamic v) => v is List ? v : const [];

/// Tipos que NO se califican en Fase 1. Listening YA se califica (audio real +
/// opción correcta). Speaking es participación: el ejercicio es real (Web Speech
/// da feedback de pronunciación), pero no penaliza el puntaje.
bool isStubType(ContentItemType type) =>
    type == ContentItemType.speakingReadAloud ||
    type == ContentItemType.dictation ||
    type == ContentItemType.guidedWriting ||
    type == ContentItemType.unknown;

/// Construye el GradeResult a partir del resultado del SERVIDOR (grade_item,
/// mig 055). `expected` es el correct_answer canónico, revelado tras responder.
GradeResult gradeResultFromServer({
  required ContentItemType type,
  required bool correct,
  required bool graded,
  required Map<String, dynamic> expected,
}) {
  if (!graded) return GradeResult.stub;
  return GradeResult(
      correct: correct, graded: true, correctDisplay: correctDisplayFor(type, expected));
}

/// Texto de la respuesta correcta para el feedback, a partir de `expected`.
String correctDisplayFor(ContentItemType type, Map<String, dynamic> ca) {
  switch (type) {
    case ContentItemType.wordBank:
    case ContentItemType.reorder:
      final seq = _asList(ca['sequence']);
      return seq.isNotEmpty
          ? seq.map((e) => e.toString()).join(' ')
          : (ca['value'] ?? '').toString();
    case ContentItemType.match:
      return _asList(ca['pairs'])
          .whereType<List>()
          .where((p) => p.length >= 2)
          .map((p) => '${p[0]} = ${p[1]}')
          .join(' · ');
    default:
      return (ca['value'] ?? '').toString();
  }
}

/// Califica la respuesta del usuario contra `correct_answer` del ítem.
/// `answer` viene del widget del ejercicio (`String`, `List<String>` o `Map`).
/// (Local; usado SOLO para stubs/speaking — el resto califica en el servidor.)
GradeResult gradeItem(ContentItemModel item, Object? answer) {
  if (isStubType(item.type)) return GradeResult.stub;

  final ca = item.correctAnswer;

  switch (item.type) {
    case ContentItemType.multipleChoice:
    case ContentItemType.trueFalse:
    case ContentItemType.listening:
      final expected = (ca['value'] ?? '').toString();
      final ok = answer is String && normalize(answer) == normalize(expected);
      return GradeResult(correct: ok, graded: true, correctDisplay: expected);

    case ContentItemType.cloze:
    case ContentItemType.translation:
      final value = (ca['value'] ?? '').toString();
      final accepted = <String>[
        value,
        ..._asList(ca['accepted']).map((e) => e.toString()),
      ];
      final user = answer is String ? answer : '';
      final ok = user.trim().isNotEmpty &&
          accepted.any((a) => normalize(a) == normalize(user));
      return GradeResult(correct: ok, graded: true, correctDisplay: value);

    case ContentItemType.wordBank:
    case ContentItemType.reorder:
      final seqList = _asList(ca['sequence']);
      final value = (ca['value'] ?? '').toString();
      final expected =
          seqList.isNotEmpty ? seqList.map((e) => e.toString()).join(' ') : value;
      final user = answer is List ? answer.map((e) => e.toString()).join(' ') : '';
      final ok = user.trim().isNotEmpty && normalize(user) == normalize(expected);
      return GradeResult(correct: ok, graded: true, correctDisplay: expected);

    case ContentItemType.match:
      // El widget reporta la respuesta keyeada por ÍNDICE de la columna izquierda
      // (Map<int,String>), robusto a tokens repetidos. Comparamos por índice
      // contra correct_answer.pairs (orden [en, es]) con normalización.
      final pairs = _asList(ca['pairs']);
      final user = answer is Map ? answer : const {};
      final ok = pairs.isNotEmpty &&
          user.length == pairs.length &&
          pairs.asMap().entries.every((e) {
            final p = e.value;
            if (p is! List || p.length < 2) return false;
            final chosen = (user[e.key] ?? '').toString();
            return normalize(chosen) == normalize(p[1].toString());
          });
      final display = pairs
          .whereType<List>()
          .where((p) => p.length >= 2)
          .map((p) => '${p[0]} = ${p[1]}')
          .join(' · ');
      return GradeResult(correct: ok, graded: true, correctDisplay: display);

    default:
      return GradeResult.stub;
  }
}
