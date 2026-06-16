/// Tipo de ejercicio (content_items.type en la BD).
enum ContentItemType {
  multipleChoice,
  cloze,
  wordBank,
  reorder,
  match,
  translation,
  listening,
  dictation,
  speakingReadAloud,
  guidedWriting,
  trueFalse,
  unknown,
}

ContentItemType contentItemTypeFromString(String? value) {
  switch (value) {
    case 'multiple_choice':
      return ContentItemType.multipleChoice;
    case 'cloze':
      return ContentItemType.cloze;
    case 'word_bank':
      return ContentItemType.wordBank;
    case 'reorder':
      return ContentItemType.reorder;
    case 'match':
      return ContentItemType.match;
    case 'translation':
      return ContentItemType.translation;
    case 'listening':
      return ContentItemType.listening;
    case 'dictation':
      return ContentItemType.dictation;
    case 'speaking_read_aloud':
      return ContentItemType.speakingReadAloud;
    case 'guided_writing':
      return ContentItemType.guidedWriting;
    case 'true_false':
      return ContentItemType.trueFalse;
    default:
      return ContentItemType.unknown;
  }
}

/// Un ejercicio del banco (fila de `content_items`).
/// payload / correctAnswer son mapas flexibles (jsonb).
class ContentItemModel {
  const ContentItemModel({
    required this.id,
    required this.type,
    required this.skill,
    required this.cefrLevel,
    this.prompt,
    this.payload = const {},
    this.correctAnswer = const {},
    this.difficulty,
    this.tags = const [],
  });

  final String id;
  final ContentItemType type;
  final String skill; // reading | listening | writing | speaking
  final String cefrLevel;
  final String? prompt;
  final Map<String, dynamic> payload;
  final Map<String, dynamic> correctAnswer;
  final double? difficulty;
  final List<String> tags;

  factory ContentItemModel.fromJson(Map<String, dynamic> json) {
    return ContentItemModel(
      id: json['id'] as String,
      type: contentItemTypeFromString(json['type'] as String?),
      skill: json['skill'] as String? ?? 'reading',
      cefrLevel: json['cefr_level'] as String? ?? 'A1',
      prompt: json['prompt'] as String?,
      payload: _asMap(json['payload']),
      correctAnswer: _asMap(json['correct_answer']),
      difficulty: (json['difficulty'] as num?)?.toDouble(),
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }

  static Map<String, dynamic> _asMap(dynamic v) =>
      v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};
}
