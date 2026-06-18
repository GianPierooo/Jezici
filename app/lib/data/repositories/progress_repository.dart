import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/achievement_models.dart';
import '../models/checkpoint_models.dart';
import '../models/course_models.dart';
import '../models/league_models.dart';
import '../models/level_exam_models.dart';
import '../models/profile_models.dart';
import '../models/practice_models.dart';
import '../models/shop_models.dart';
import '../models/progress_models.dart';

/// Acceso a los datos de progreso del usuario y a las RPC server-side.
/// La economía (XP/oro/skills) la decide el servidor (Arquitectura §4/§7).
class ProgressRepository {
  ProgressRepository(this._client);

  final SupabaseClient _client;

  String? get _uid => _client.auth.currentUser?.id;
  bool get isSignedIn => _client.auth.currentSession != null;

  // ── Perfil (nombre real, país, avatar, bio) ───────────────────────────────

  /// Perfil propio para el hero (RPC get_profile).
  Future<ProfileInfo> fetchProfile() async {
    final res = await _client.rpc('get_profile');
    return ProfileInfo.fromJson(Map<String, dynamic>.from(res as Map));
  }

  /// Actualiza el perfil propio (RPC set_profile). Campos null = sin cambio.
  Future<ProfileInfo> setProfile({
    String? name,
    String? country,
    String? bio,
    String? avatarColor,
  }) async {
    final res = await _client.rpc('set_profile', params: {
      'p_name': name,
      'p_country': country,
      'p_bio': bio,
      'p_avatar_color': avatarColor,
    });
    return ProfileInfo.fromJson(Map<String, dynamic>.from(res as Map));
  }

  // ── Multi-curso (es→en / es→pt) ────────────────────────────────────────────

  /// Cursos disponibles + cuál es el activo del usuario (RPC get_courses).
  Future<List<CourseInfo>> fetchCourses() async {
    final res = await _client.rpc('get_courses');
    return (res as List)
        .map((e) => CourseInfo.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Cambia el curso activo del usuario (y asegura inscripción, server-side).
  Future<void> setActiveCourse(String courseId) async {
    await _client.rpc('set_active_course', params: {'p_course_id': courseId});
  }

  /// Sesión anónima temporal (el onboarding real es el paso G).
  Future<void> ensureSignedIn() async {
    if (_client.auth.currentSession == null) {
      await _client.auth.signInAnonymously();
    }
  }

  /// Crea la cuenta con email/contraseña (autoconfirm → sesión inmediata).
  Future<void> signUpEmail(String email, String password) async {
    await _client.auth.signUp(email: email, password: password);
  }

  /// Inicia sesión con email/contraseña (flujo auth-first, GA4).
  Future<void> signInEmail(String email, String password) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  /// ¿El usuario ya terminó el onboarding? (user_plans.onboarding_completed).
  /// Sin fila de plan → false (debe pasar el onboarding sí o sí).
  Future<bool> isOnboardingComplete() async {
    final uid = _uid;
    if (uid == null) return false;
    final res = await _client
        .from('user_plans')
        .select('onboarding_completed')
        .eq('user_id', uid)
        .maybeSingle();
    return (res?['onboarding_completed'] as bool?) ?? false;
  }

  /// Persiste el plan del onboarding (personalidad, plan, nivel, 4 skills).
  Future<void> createPlan({
    required String coachStyle,
    required int intensity,
    required String currentLevel,
    required String goalLevel,
    required int dailyMinutes,
    required int daysPerWeek,
    required String motive,
    String? deadline,
    required int estimatedHours,
    required String estimatedCompletion,
    required Map<String, String> skillLevels,
  }) async {
    await _client.rpc('create_plan', params: {
      'p_coach_style': coachStyle,
      'p_intensity': intensity,
      'p_current_level': currentLevel,
      'p_goal_level': goalLevel,
      'p_daily_minutes': dailyMinutes,
      'p_days_per_week': daysPerWeek,
      'p_motive': motive,
      'p_deadline': deadline,
      'p_estimated_hours': estimatedHours,
      'p_estimated_completion': estimatedCompletion,
      'p_skill_levels': skillLevels,
    });
  }

  /// Seguimiento del plan (dashboard): adelante/atrás, proyección, progreso.
  Future<PlanTracking> fetchPlanTracking() async {
    if (_uid == null) return PlanTracking.empty;
    final res = await _client.rpc('get_plan_tracking');
    return PlanTracking.fromJson(Map<String, dynamic>.from(res as Map));
  }

  /// Palanca "llegar más rápido": sube min/día y recalcula la fecha (server-side).
  Future<Map<String, dynamic>> updatePlanPace(int dailyMinutes) async {
    final res = await _client.rpc('update_plan_pace', params: {'p_daily_minutes': dailyMinutes});
    return Map<String, dynamic>.from(res as Map);
  }

  /// El plan del usuario (para la tarjeta "Mi plan").
  Future<UserPlan?> fetchPlan() async {
    final uid = _uid;
    if (uid == null) return null;
    final res = await _client
        .from('user_plans')
        .select(
          'current_level, goal_level, daily_minutes, days_per_week, motive, '
          'deadline, estimated_hours, estimated_completion_date, onboarding_completed',
        )
        .eq('user_id', uid)
        .maybeSingle();
    return res == null ? null : UserPlan.fromJson(res);
  }

  /// Arranca el curso: crea progreso + las 4 habilidades (idempotente).
  Future<void> startCourse() async {
    await _client.rpc('start_course');
  }

  /// Cierra una lección server-side y devuelve el resumen.
  Future<LessonSummary> completeLesson(
    String lessonId,
    List<Map<String, dynamic>> answers,
  ) async {
    final res = await _client.rpc('complete_lesson', params: {
      'p_lesson_id': lessonId,
      'p_answers': answers,
    });
    return LessonSummary.fromJson(Map<String, dynamic>.from(res as Map));
  }

  /// "Empezar el viaje": completa el nodo misión y desbloquea el siguiente.
  Future<void> completeMission(String lessonId) async {
    await _client.rpc('complete_mission', params: {'p_lesson_id': lessonId});
  }

  /// Arma el examen del checkpoint (set aleatorizado, server-side).
  Future<CheckpointStartData> startCheckpoint(String lessonId) async {
    final res = await _client.rpc('start_checkpoint', params: {'p_lesson_id': lessonId});
    return CheckpointStartData.fromJson(Map<String, dynamic>.from(res as Map));
  }

  /// Envía el checkpoint; el servidor califica, decide aprobado y aplica gating.
  Future<CheckpointResult> submitCheckpoint(
    String lessonId,
    List<Map<String, dynamic>> answers,
    int timeTakenSec,
  ) async {
    final res = await _client.rpc('submit_checkpoint', params: {
      'p_lesson_id': lessonId,
      'p_answers': answers,
      'p_time_taken_sec': timeTakenSec,
    });
    return CheckpointResult.fromJson(Map<String, dynamic>.from(res as Map));
  }

  /// Estado de cada nodo del mapa (lesson_id -> status).
  Future<Map<String, String>> fetchLessonProgress() async {
    final uid = _uid;
    if (uid == null) return {};
    final res = await _client
        .from('user_lesson_progress')
        .select('lesson_id, status')
        .eq('user_id', uid);
    return {
      for (final r in (res as List))
        (r as Map)['lesson_id'] as String: r['status'] as String,
    };
  }

  /// Stats para la top bar / perfil (stats + racha + meta de hoy).
  Future<HomeStats> fetchHomeStats() async {
    final uid = _uid;
    if (uid == null) return HomeStats.empty;

    final stats = await _client
        .from('user_stats')
        .select('xp_total, gold, hearts, player_level')
        .eq('user_id', uid)
        .maybeSingle();
    if (stats == null) return HomeStats.empty;

    final streak = await _client
        .from('streaks')
        .select('current_streak, longest_streak, freezes_available')
        .eq('user_id', uid)
        .maybeSingle();

    // Meta diaria más reciente. (El día lo decide el servidor en UTC; filtrar
    // por la fecha local del navegador desincroniza, así que tomamos la última.)
    final daily = await _client
        .from('daily_goals')
        .select('goal_xp, xp_earned')
        .eq('user_id', uid)
        .order('goal_date', ascending: false)
        .limit(1)
        .maybeSingle();

    return HomeStats(
      xpTotal: (stats['xp_total'] as num?)?.toInt() ?? 0,
      gold: (stats['gold'] as num?)?.toInt() ?? 0,
      hearts: (stats['hearts'] as num?)?.toInt() ?? 5,
      playerLevel: (stats['player_level'] as num?)?.toInt() ?? 1,
      currentStreak: (streak?['current_streak'] as num?)?.toInt() ?? 0,
      longestStreak: (streak?['longest_streak'] as num?)?.toInt() ?? 0,
      freezes: (streak?['freezes_available'] as num?)?.toInt() ?? 0,
      dailyGoalXp: (daily?['goal_xp'] as num?)?.toInt() ?? 30,
      dailyXpEarned: (daily?['xp_earned'] as num?)?.toInt() ?? 0,
    );
  }

  // ── Racha, ajustes y motor Matix (paso H) ─────────────────────────────────

  /// Compra un congelador de racha (cuesta oro; el servidor decide).
  Future<Map<String, dynamic>> useStreakFreeze() async {
    final res = await _client.rpc('use_streak_freeze');
    return Map<String, dynamic>.from(res as Map);
  }

  /// Tienda: estado (oro, vidas, congeladores, cofre disponible).
  Future<ShopStatus> fetchShopStatus() async {
    if (_uid == null) return ShopStatus.empty;
    final res = await _client.rpc('shop_status');
    return ShopStatus.fromJson(Map<String, dynamic>.from(res as Map));
  }

  /// Abre el cofre diario (recompensa variable de oro, 1/día).
  Future<Map<String, dynamic>> openDailyChest() async {
    final res = await _client.rpc('open_daily_chest');
    return Map<String, dynamic>.from(res as Map);
  }

  /// Recarga vidas a 5 (cuesta oro).
  Future<Map<String, dynamic>> buyHearts() async {
    final res = await _client.rpc('buy_hearts');
    return Map<String, dynamic>.from(res as Map);
  }

  /// Cierra la sesión (logout).
  Future<void> signOut() => _client.auth.signOut();

  /// Borra la cuenta del usuario y TODOS sus datos (derecho de supresión).
  /// El servidor borra auth.users → cascada limpia todo. Luego cierra sesión.
  Future<void> deleteAccount() async {
    await _client.rpc('delete_account');
    await _client.auth.signOut();
  }

  // ── Analítica (Especificacion §13) ────────────────────────────────────────

  /// Registra un evento (fire-and-forget; nunca rompe el flujo del usuario).
  Future<void> logEvent(String event, {Map<String, dynamic>? props}) async {
    try {
      await _client.rpc('log_event', params: {'p_event': event, 'p_props': props ?? {}});
    } catch (_) {}
  }

  /// Métricas agregadas §13 (panel mínimo interno).
  Future<Map<String, dynamic>> fetchMetrics() async {
    final res = await _client.rpc('get_metrics');
    return Map<String, dynamic>.from(res as Map);
  }

  /// Embudo de onboarding (completitud + drop-off por paso) — GA4 B7.
  Future<Map<String, dynamic>> fetchOnboardingFunnel() async {
    final res = await _client.rpc('get_onboarding_funnel');
    return Map<String, dynamic>.from(res as Map);
  }

  /// Engagement (uso por sección, feedback, interés Conversar) — GA7.
  Future<Map<String, dynamic>> fetchEngagement() async {
    final res = await _client.rpc('get_engagement');
    return Map<String, dynamic>.from(res as Map);
  }

  // ── Feedback in-app + Conversar (taste seguro) — GA7 ──────────────────────

  /// Envía feedback/bug desde cualquier pantalla, con contexto.
  Future<void> submitFeedback({
    required String screen,
    required String kind,
    required String message,
    String? appVersion,
    String? platform,
  }) async {
    await _client.rpc('submit_feedback', params: {
      'p_screen': screen,
      'p_kind': kind,
      'p_message': message,
      'p_app_version': appVersion,
      'p_platform': platform,
    });
  }

  /// Guarda un intento de conversación en solitario (gancho Fase 2).
  Future<void> saveConversationAttempt({
    required String topic,
    required String mode,
    String? content,
    int? selfScore,
  }) async {
    await _client.rpc('save_conversation_attempt', params: {
      'p_topic': topic,
      'p_mode': mode,
      'p_content': content,
      'p_self_score': selfScore,
    });
  }

  /// Señal de interés en conversación EN VIVO (Fase 2). Devuelve true si se
  /// registró bien; false si falló (la UI distingue éxito real de fallo).
  Future<bool> logConversarInterest(bool wouldUse, String? topics) async {
    try {
      await _client.rpc('log_conversar_interest',
          params: {'p_would_use': wouldUse, 'p_topics': topics});
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Ajustes de Matix del usuario (user_personality).
  Future<UserSettings> fetchSettings() async {
    final uid = _uid;
    if (uid == null) return UserSettings.fallback;
    final res = await _client
        .from('user_personality')
        .select('coach_style, intensity, quiet_hours_start, quiet_hours_end, push_enabled')
        .eq('user_id', uid)
        .maybeSingle();
    return res == null ? UserSettings.fallback : UserSettings.fromJson(res);
  }

  /// Recalibra estilo/intensidad de Matix, ventana horaria y meta diaria.
  Future<void> updateSettings({
    required String coachStyle,
    required int intensity,
    String? quietStart, // "HH:MM" o null
    String? quietEnd,
    int? dailyMinutes,
    required bool pushEnabled,
  }) async {
    await _client.rpc('update_settings', params: {
      'p_coach_style': coachStyle,
      'p_intensity': intensity,
      'p_quiet_start': quietStart,
      'p_quiet_end': quietEnd,
      'p_daily_minutes': dailyMinutes,
      'p_push_enabled': pushEnabled,
    });
  }

  /// El MOTOR Matix: dado un trigger, elige el copy del estilo del usuario,
  /// respeta techo + quiet_hours y lo registra. Devuelve el copy + estado.
  Future<MatixResult> matixFire(String trigger) async {
    final res = await _client.rpc('matix_fire', params: {'p_trigger': trigger});
    return MatixResult.fromJson(Map<String, dynamic>.from(res as Map));
  }

  // ── Practicar (paso Fase 1) ───────────────────────────────────────────────

  /// Arma una sesión de práctica (srs | weakness | skill | timed | reinforce_unit).
  /// [unit] sólo aplica a 'reinforce_unit' (re-evalúa ítems débiles de la unidad).
  Future<PracticeSession> startPractice(String mode, {String? skill, String? unit}) async {
    final res = await _client.rpc('start_practice', params: {
      'p_mode': mode,
      'p_skill': skill,
      'p_unit': unit,
    });
    return PracticeSession.fromJson(Map<String, dynamic>.from(res as Map));
  }

  /// Envía la práctica; el servidor recalifica, da XP (tope 20) y agenda SRS.
  Future<PracticeSummary> submitPractice(
    String mode,
    List<Map<String, dynamic>> answers,
  ) async {
    final res = await _client.rpc('submit_practice', params: {
      'p_mode': mode,
      'p_answers': answers,
    });
    return PracticeSummary.fromJson(Map<String, dynamic>.from(res as Map));
  }

  // ── Logros + certificados (paso Perfil) ───────────────────────────────────

  /// Catálogo de logros con el estado del usuario (evalúa y desbloquea al vuelo).
  Future<List<Achievement>> fetchAchievements() async {
    if (_uid == null) return const [];
    final res = await _client.rpc('get_achievements');
    return (res as List)
        .map((e) => Achievement.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  // ── Examen de nivel + certificación ───────────────────────────────────────

  Future<LevelExamStatus> fetchLevelExamStatus() async {
    if (_uid == null) return LevelExamStatus.empty;
    final res = await _client.rpc('level_exam_status');
    return LevelExamStatus.fromJson(Map<String, dynamic>.from(res as Map));
  }

  /// Dominio + refuerzo por habilidad (modelo D6/D8): barras de las 4 habilidades.
  Future<SkillMasteryStatus> fetchSkillMastery() async {
    if (_uid == null) return SkillMasteryStatus.empty;
    final res = await _client.rpc('get_skill_mastery');
    return SkillMasteryStatus.fromJson(Map<String, dynamic>.from(res as Map));
  }

  Future<CheckpointStartData> startLevelExam() async {
    final res = await _client.rpc('start_level_exam');
    return CheckpointStartData.fromJson(Map<String, dynamic>.from(res as Map));
  }

  Future<LevelExamResult> submitLevelExam(
    List<Map<String, dynamic>> answers,
    int timeTakenSec,
  ) async {
    final res = await _client.rpc('submit_level_exam', params: {
      'p_answers': answers,
      'p_time_taken_sec': timeTakenSec,
    });
    return LevelExamResult.fromJson(Map<String, dynamic>.from(res as Map));
  }

  /// Liga semanal del usuario (standings; siembra bots si faltan rivales).
  Future<LeagueStanding> fetchLeague() async {
    final res = await _client.rpc('get_league');
    return LeagueStanding.fromJson(Map<String, dynamic>.from(res as Map));
  }

  /// Certificados de nivel emitidos del usuario.
  Future<List<Certificate>> fetchCertificates() async {
    if (_uid == null) return const [];
    final res = await _client.rpc('get_certificates');
    return (res as List)
        .map((e) => Certificate.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Estado para las tarjetas de Practicar: palabras por repasar + skill débil.
  Future<PracticeStatus> fetchPracticeStatus() async {
    final uid = _uid;
    if (uid == null) return PracticeStatus.empty;
    final vocab = await _client.from('vocabulary').select('id');
    final srs = await _client
        .from('user_vocab_srs')
        .select('due_at')
        .eq('user_id', uid);
    final now = DateTime.now();
    final scheduled = (srs as List).where((r) {
      final d = DateTime.tryParse((r as Map)['due_at']?.toString() ?? '');
      return d != null && d.isAfter(now);
    }).length;
    final due = ((vocab as List).length - scheduled).clamp(0, 9999);

    // Habilidad más débil por reinforce_score (modelo D8), NO por puntos: en el
    // modelo de dominio progress_points está congelado y daría siempre 'reading'.
    String? weakest;
    try {
      final gm = await _client.rpc('get_skill_mastery');
      final list = ((gm as Map)['skills'] as List?) ?? const [];
      double best = -1;
      for (final s in list) {
        final m = s as Map;
        final score = (m['reinforce_score'] as num?)?.toDouble() ?? 0;
        if (score > best) {
          best = score;
          weakest = m['skill'] as String?;
        }
      }
    } catch (_) {/* sin dominio aún → sin débil destacada */}
    return PracticeStatus(dueWords: due, weakestSkill: weakest);
  }

  /// Historial de notificaciones del usuario (centro in-app).
  Future<List<NotificationItem>> fetchNotifications() async {
    final uid = _uid;
    if (uid == null) return const [];
    final res = await _client
        .from('notifications')
        .select('id, trigger_type, body, escalation_step, status, sent_at, created_at')
        .eq('user_id', uid)
        .eq('status', 'sent')
        .order('created_at', ascending: false)
        .limit(30);
    return (res as List)
        .map((e) => NotificationItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Las 4 habilidades (reading/listening/writing/speaking).
  Future<List<SkillLevel>> fetchSkills() async {
    final uid = _uid;
    if (uid == null) return const [];
    final res = await _client
        .from('user_skill_levels')
        .select('skill, cefr_level, progress_points')
        .eq('user_id', uid);
    return (res as List)
        .map((e) => SkillLevel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
