import 'lesson_model.dart';

/// Una unidad (región del mapa) con sus lecciones, ordenadas por order_index.
class UnitModel {
  const UnitModel({
    required this.id,
    required this.courseId,
    required this.cefrLevel,
    required this.orderIndex,
    required this.title,
    required this.lessons,
    this.themeColor,
    this.icon,
  });

  final String id;
  final String courseId;
  final String cefrLevel;
  final int orderIndex;
  final String title;
  final String? themeColor;
  final String? icon;
  final List<LessonModel> lessons;

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    final rawLessons = (json['lessons'] as List?) ?? const [];
    final lessons = rawLessons
        .map((e) => LessonModel.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    return UnitModel(
      id: json['id'] as String,
      courseId: json['course_id'] as String? ?? '',
      cefrLevel: json['cefr_level'] as String? ?? '',
      orderIndex: (json['order_index'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      themeColor: json['theme_color'] as String?,
      icon: json['icon'] as String?,
      lessons: lessons,
    );
  }
}
