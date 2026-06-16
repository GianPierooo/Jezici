import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/unit_model.dart';

/// Lee el contenido del curso (estático/compartido) desde Supabase.
/// El contenido es de lectura pública por RLS → no requiere login.
class ContentRepository {
  ContentRepository(this._client);

  final SupabaseClient _client;

  /// Trae las unidades con sus lecciones embebidas (una sola consulta).
  Future<List<UnitModel>> fetchUnits() async {
    final res = await _client
        .from('units')
        .select(
          'id, course_id, cefr_level, order_index, title, theme_color, icon, '
          'lessons ( id, unit_id, order_index, title, description, type, xp_reward )',
        )
        .order('order_index', ascending: true);

    return (res as List)
        .map((e) => UnitModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
