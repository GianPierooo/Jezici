import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/achievement_models.dart';
import 'models/content_item_model.dart';
import 'models/league_models.dart';
import 'models/level_exam_models.dart';
import 'models/practice_models.dart';
import 'models/progress_models.dart';
import 'models/shop_models.dart';
import 'models/unit_model.dart';
import 'repositories/content_repository.dart';
import 'repositories/progress_repository.dart';

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

// ── Progreso del usuario (paso E) ───────────────────────────────────────────

final progressRepositoryProvider = Provider<ProgressRepository>(
  (ref) => ProgressRepository(ref.watch(supabaseClientProvider)),
);

/// Estado real de cada nodo del mapa (lesson_id -> status).
final lessonProgressProvider = FutureProvider<Map<String, String>>(
  (ref) => ref.watch(progressRepositoryProvider).fetchLessonProgress(),
);

/// Stats reales (XP, oro, vidas, racha, meta diaria).
final homeStatsProvider = FutureProvider<HomeStats>(
  (ref) => ref.watch(progressRepositoryProvider).fetchHomeStats(),
);

/// Las 4 habilidades del usuario.
final skillsProvider = FutureProvider<List<SkillLevel>>(
  (ref) => ref.watch(progressRepositoryProvider).fetchSkills(),
);

/// El plan del usuario (meta, ritmo, fecha estimada).
final userPlanProvider = FutureProvider<UserPlan?>(
  (ref) => ref.watch(progressRepositoryProvider).fetchPlan(),
);

/// Ajustes de Matix (estilo de coach, intensidad, quiet_hours).
final settingsProvider = FutureProvider<UserSettings>(
  (ref) => ref.watch(progressRepositoryProvider).fetchSettings(),
);

/// Centro de notificaciones in-app (notificaciones enviadas por Matix).
final notificationsProvider = FutureProvider<List<NotificationItem>>(
  (ref) => ref.watch(progressRepositoryProvider).fetchNotifications(),
);

/// Estado de Practicar: palabras por repasar (SRS) + habilidad más débil.
final practiceStatusProvider = FutureProvider<PracticeStatus>(
  (ref) => ref.watch(progressRepositoryProvider).fetchPracticeStatus(),
);

/// Logros/badges (catálogo + estado del usuario).
final achievementsProvider = FutureProvider<List<Achievement>>(
  (ref) => ref.watch(progressRepositoryProvider).fetchAchievements(),
);

/// Certificados de nivel obtenidos.
final certificatesProvider = FutureProvider<List<Certificate>>(
  (ref) => ref.watch(progressRepositoryProvider).fetchCertificates(),
);

/// Liga semanal del usuario (ranking por XP de la semana).
final leagueProvider = FutureProvider<LeagueStanding>(
  (ref) => ref.watch(progressRepositoryProvider).fetchLeague(),
);

/// Estado del examen de nivel (desbloqueo + requisitos).
final levelExamStatusProvider = FutureProvider<LevelExamStatus>(
  (ref) => ref.watch(progressRepositoryProvider).fetchLevelExamStatus(),
);

/// Estado de la Tienda (oro, vidas, congeladores, cofre).
final shopStatusProvider = FutureProvider<ShopStatus>(
  (ref) => ref.watch(progressRepositoryProvider).fetchShopStatus(),
);
