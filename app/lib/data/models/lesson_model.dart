/// Tipo de nodo del mapa (lessons.type en la BD).
enum LessonType { lesson, checkpoint, mission, unknown }

LessonType lessonTypeFromString(String? value) {
  switch (value) {
    case 'lesson':
      return LessonType.lesson;
    case 'checkpoint':
      return LessonType.checkpoint;
    case 'mission':
      return LessonType.mission;
    default:
      return LessonType.unknown;
  }
}

/// Un nodo del mapa (fila de `lessons`).
class LessonModel {
  const LessonModel({
    required this.id,
    required this.unitId,
    required this.orderIndex,
    required this.title,
    required this.type,
    this.description,
    this.xpReward = 0,
  });

  final String id;
  final String unitId;
  final int orderIndex;
  final String title;
  final String? description;
  final LessonType type;
  final int xpReward;

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] as String,
      unitId: json['unit_id'] as String? ?? '',
      orderIndex: (json['order_index'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      type: lessonTypeFromString(json['type'] as String?),
      xpReward: (json['xp_reward'] as num?)?.toInt() ?? 0,
    );
  }
}
