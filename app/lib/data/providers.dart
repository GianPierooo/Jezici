import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/achievement_models.dart';
import 'models/content_item_model.dart';
import 'models/course_models.dart';
import 'models/immersion_models.dart';
import 'models/profile_models.dart';
import 'models/tip_models.dart';
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

/// Perfil del usuario (nombre real, país, avatar, bio, ingreso).
final profileProvider = FutureProvider<ProfileInfo>(
  (ref) => ref.watch(progressRepositoryProvider).fetchProfile(),
);

/// Referencia navegable (capa "enseña"): conceptos del curso activo + skill floja.
final referenceProvider = FutureProvider<ReferenceData>(
  (ref) => ref.watch(progressRepositoryProvider).fetchReference(),
);

/// Cuaderno de datos: tips pedagógicos vistos por el usuario (capa "enseña").
final notebookProvider = FutureProvider<List<TipModel>>(
  (ref) => ref.watch(progressRepositoryProvider).getNotebook(),
);

/// Historias / Inmersión del curso activo (input comprensible).
final storiesProvider = FutureProvider<List<StorySummary>>(
  (ref) => ref.watch(progressRepositoryProvider).fetchStories(),
);

/// Cursos disponibles (es→en, es→pt) + cuál es el activo del usuario.
final coursesProvider = FutureProvider<List<CourseInfo>>(
  (ref) => ref.watch(progressRepositoryProvider).fetchCourses(),
);

/// Id del curso activo del usuario (multi-curso). Fallback al primero / es→en.
const _defaultCourseId = '20000000-0000-0000-0000-000000000001';
final activeCourseIdProvider = FutureProvider<String>((ref) async {
  final courses = await ref.watch(coursesProvider.future);
  if (courses.isEmpty) return _defaultCourseId;
  return courses.firstWhere((c) => c.active, orElse: () => courses.first).id;
});

/// Unidades del curso ACTIVO (con lecciones). Alimenta el mapa de "Aprender".
final mapUnitsProvider = FutureProvider<List<UnitModel>>((ref) async {
  final courseId = await ref.watch(activeCourseIdProvider.future);
  return ref.watch(contentRepositoryProvider).fetchUnits(courseId);
});

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

/// Dominio + refuerzo por habilidad (modelo D6/D8): barras de dominio del nivel
/// en curso + estado del examen. Reemplaza la barra "por puntos".
final skillMasteryProvider = FutureProvider<SkillMasteryStatus>(
  (ref) => ref.watch(progressRepositoryProvider).fetchSkillMastery(),
);

/// El plan del usuario (meta, ritmo, fecha estimada).
final userPlanProvider = FutureProvider<UserPlan?>(
  (ref) => ref.watch(progressRepositoryProvider).fetchPlan(),
);

/// ¿El usuario terminó el onboarding? Decide la ruta de entrada (GA4 auth-first):
/// con sesión pero sin onboarding → onboarding obligatorio; si no → mapa.
final onboardingCompleteProvider = FutureProvider<bool>(
  (ref) => ref.watch(progressRepositoryProvider).isOnboardingComplete(),
);

/// Seguimiento del plan (dashboard diferenciador): progreso, adelante/atrás,
/// proyección de fecha recalculada con el ritmo real.
final planTrackingProvider = FutureProvider<PlanTracking>(
  (ref) => ref.watch(progressRepositoryProvider).fetchPlanTracking(),
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

/// Leaderboards: clave (metric, window, scope). Los records dan igualdad
/// estructural → Riverpod cachea por combinación.
typedef LeaderboardKey = ({String metric, String window, String scope});
final leaderboardProvider =
    FutureProvider.family<LeaderboardResult, LeaderboardKey>(
  (ref, k) => ref.watch(progressRepositoryProvider).fetchLeaderboard(
        metric: k.metric,
        window: k.window,
        scope: k.scope,
      ),
);

/// Estado del examen de nivel (desbloqueo + requisitos).
final levelExamStatusProvider = FutureProvider<LevelExamStatus>(
  (ref) => ref.watch(progressRepositoryProvider).fetchLevelExamStatus(),
);

/// Estado de la Tienda (oro, vidas, congeladores, cofre).
final shopStatusProvider = FutureProvider<ShopStatus>(
  (ref) => ref.watch(progressRepositoryProvider).fetchShopStatus(),
);

/// Métricas agregadas §13 (panel interno).
final metricsProvider = FutureProvider<Map<String, dynamic>>(
  (ref) => ref.watch(progressRepositoryProvider).fetchMetrics(),
);

/// Embudo de onboarding (completitud + drop-off por paso) — GA4 B7.
final onboardingFunnelProvider = FutureProvider<Map<String, dynamic>>(
  (ref) => ref.watch(progressRepositoryProvider).fetchOnboardingFunnel(),
);

/// Engagement (uso por sección, feedback, interés Conversar) — GA7.
final engagementProvider = FutureProvider<Map<String, dynamic>>(
  (ref) => ref.watch(progressRepositoryProvider).fetchEngagement(),
);
