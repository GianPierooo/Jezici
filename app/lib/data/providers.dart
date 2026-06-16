import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/content_item_model.dart';
import 'models/unit_model.dart';
import 'repositories/content_repository.dart';

/// Cliente Supabase global (inicializado en main()).
final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

/// Repositorio de contenido.
final contentRepositoryProvider = Provider<ContentRepository>(
  (ref) => ContentRepository(ref.watch(supabaseClientProvider)),
);

/// Unidades del curso (con lecciones). Alimenta el mapa de "Aprender".
final mapUnitsProvider = FutureProvider<List<UnitModel>>(
  (ref) => ref.watch(contentRepositoryProvider).fetchUnits(),
);

/// Ejercicios de una lección (vía lesson_items, en orden). Alimenta el loop.
final lessonItemsProvider =
    FutureProvider.family<List<ContentItemModel>, String>(
  (ref, lessonId) =>
      ref.watch(contentRepositoryProvider).fetchLessonItems(lessonId),
);
