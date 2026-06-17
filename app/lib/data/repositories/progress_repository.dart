import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/checkpoint_models.dart';
import '../models/progress_models.dart';

/// Acceso a los datos de progreso del usuario y a las RPC server-side.
/// La economía (XP/oro/skills) la decide el servidor (Arquitectura §4/§7).
class ProgressRepository {
  ProgressRepository(this._client);

  final SupabaseClient _client;

  String? get _uid => _client.auth.currentUser?.id;
  bool get isSignedIn => _client.auth.currentSession != null;

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

  /// El plan del usuario (para la tarjeta "Mi plan").
  Future<UserPlan?> fetchPlan() async {
    final uid = _uid;
    if (uid == null) return null;
    final res = await _client
        .from('user_plans')
        .select(
          'current_level, goal_level, daily_minutes, days_per_week, motive, '
          'deadline, estimated_hours, estimated_completion_date',
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
        .select('current_streak')
        .eq('user_id', uid)
        .maybeSingle();

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
      dailyGoalXp: (daily?['goal_xp'] as num?)?.toInt() ?? 30,
      dailyXpEarned: (daily?['xp_earned'] as num?)?.toInt() ?? 0,
    );
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
