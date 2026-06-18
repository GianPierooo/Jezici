import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/content_item_model.dart';
import '../models/unit_model.dart';

/// Lee el contenido del curso (estático/compartido) desde Supabase.
/// El contenido es de lectura pública por RLS → no requiere login.
class ContentRepository {
  ContentRepository(this._client);

  final SupabaseClient _client;

  /// Trae las unidades con sus lecciones embebidas (una sola consulta),
  /// SOLO del curso indicado (multi-curso: es→en / es→pt). Filtrar por
  /// course_id evita que las unidades de un curso aparezcan en el mapa de otro.
  Future<List<UnitModel>> fetchUnits(String courseId) async {
    final res = await _client
        .from('units')
        .select(
          'id, course_id, cefr_level, order_index, title, theme_color, icon, '
          'lessons ( id, unit_id, order_index, title, description, type, xp_reward )',
        )
        .eq('course_id', courseId)
        .order('order_index', ascending: true);

    return (res as List)
        .map((e) => UnitModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Trae los ejercicios de una lección (vía lesson_items, en orden).
  Future<List<ContentItemModel>> fetchLessonItems(String lessonId) async {
    final res = await _client
        .from('lesson_items')
        .select(
          'order_index, '
          'item:content_items ( id, type, skill, cefr_level, prompt, '
          'payload, correct_answer, difficulty, tags )',
        )
        .eq('lesson_id', lessonId)
        .order('order_index', ascending: true);

    return (res as List)
        .map((row) => (row as Map<String, dynamic>)['item'] as Map<String, dynamic>)
        .map(ContentItemModel.fromJson)
        .toList();
  }
}
