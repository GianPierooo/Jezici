// Modelos de los datos de progreso del usuario (paso E).

/// Stats agregados para la top bar y el perfil.
class HomeStats {
  const HomeStats({
    required this.xpTotal,
    required this.gold,
    required this.hearts,
    required this.playerLevel,
    required this.currentStreak,
    required this.longestStreak,
    required this.freezes,
    required this.dailyGoalXp,
    required this.dailyXpEarned,
  });

  final int xpTotal;
  final int gold;
  final int hearts;
  final int playerLevel;
  final int currentStreak;
  final int longestStreak;
  final int freezes;
  final int dailyGoalXp;
  final int dailyXpEarned;

  double get dailyProgress =>
      dailyGoalXp <= 0 ? 0 : (dailyXpEarned / dailyGoalXp).clamp(0.0, 1.0);

  bool get dailyGoalMet => dailyXpEarned >= dailyGoalXp && dailyGoalXp > 0;

  static const empty = HomeStats(
    xpTotal: 0,
    gold: 0,
    hearts: 5,
    playerLevel: 1,
    currentStreak: 0,
    longestStreak: 0,
    freezes: 0,
    dailyGoalXp: 30,
    dailyXpEarned: 0,
  );
}

/// Personalidad/ajustes de Matix (user_personality) para la pantalla de Ajustes.
class UserSettings {
  const UserSettings({
    required this.coachStyle,
    required this.intensity,
    this.quietStart,
    this.quietEnd,
    required this.pushEnabled,
  });

  final String coachStyle; // mano_dura | positivo | rezago | suave
  final int intensity; // 1 | 2 | 3
  final String? quietStart; // "HH:MM"
  final String? quietEnd;
  final bool pushEnabled;

  UserSettings copyWith({
    String? coachStyle,
    int? intensity,
    String? quietStart,
    String? quietEnd,
    bool? pushEnabled,
    bool clearQuiet = false,
  }) =>
      UserSettings(
        coachStyle: coachStyle ?? this.coachStyle,
        intensity: intensity ?? this.intensity,
        quietStart: clearQuiet ? null : (quietStart ?? this.quietStart),
        quietEnd: clearQuiet ? null : (quietEnd ?? this.quietEnd),
        pushEnabled: pushEnabled ?? this.pushEnabled,
      );

  static String _hhmm(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final parts = raw.split(':');
    return parts.length >= 2 ? '${parts[0]}:${parts[1]}' : raw;
  }

  factory UserSettings.fromJson(Map<String, dynamic> j) => UserSettings(
        coachStyle: j['coach_style'] as String? ?? 'suave',
        intensity: (j['intensity'] as num?)?.toInt() ?? 2,
        quietStart: (j['quiet_hours_start'] == null)
            ? null
            : _hhmm(j['quiet_hours_start'].toString()),
        quietEnd: (j['quiet_hours_end'] == null)
            ? null
            : _hhmm(j['quiet_hours_end'].toString()),
        pushEnabled: j['push_enabled'] as bool? ?? true,
      );

  static const fallback = UserSettings(
    coachStyle: 'suave',
    intensity: 2,
    pushEnabled: true,
  );
}

/// Una notificación de Matix registrada en `notifications` (centro in-app).
class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.trigger,
    required this.body,
    required this.escalationStep,
    required this.status,
    this.sentAt,
  });

  final String id;
  final String trigger; // notification_trigger
  final String body; // copy resuelto
  final int escalationStep;
  final String status; // sent | suppressed
  final DateTime? sentAt;

  factory NotificationItem.fromJson(Map<String, dynamic> j) => NotificationItem(
        id: j['id'].toString(),
        trigger: j['trigger_type'] as String? ?? '',
        body: j['body'] as String? ?? '',
        escalationStep: (j['escalation_step'] as num?)?.toInt() ?? 1,
        status: j['status'] as String? ?? 'sent',
        sentAt: DateTime.tryParse(
            (j['sent_at'] ?? j['created_at'])?.toString() ?? ''),
      );
}

/// Resultado de matix_fire (motor): el copy elegido y el estado de envío.
class MatixResult {
  const MatixResult({
    required this.status,
    required this.reason,
    required this.copy,
    required this.coachStyle,
    required this.escalationStep,
    required this.trigger,
  });

  final String status; // sent | suppressed
  final String reason; // ok | capped | quiet_hours | push_off
  final String copy;
  final String coachStyle;
  final int escalationStep;
  final String trigger;

  bool get sent => status == 'sent';

  factory MatixResult.fromJson(Map<String, dynamic> j) => MatixResult(
        status: j['status'] as String? ?? 'suppressed',
        reason: j['reason'] as String? ?? '',
        copy: j['copy'] as String? ?? '',
        coachStyle: j['coach_style'] as String? ?? 'suave',
        escalationStep: (j['escalation_step'] as num?)?.toInt() ?? 1,
        trigger: j['trigger'] as String? ?? '',
      );
}

/// Nivel de una de las 4 habilidades.
class SkillLevel {
  const SkillLevel({
    required this.skill,
    required this.cefrLevel,
    required this.progressPoints,
  });

  final String skill; // reading | listening | writing | speaking
  final String cefrLevel;
  final double progressPoints;

  /// Avance al siguiente nivel (umbral 100 puntos en el RPC).
  double get levelProgress => (progressPoints / 100).clamp(0.0, 1.0);

  factory SkillLevel.fromJson(Map<String, dynamic> j) => SkillLevel(
        skill: j['skill'] as String,
        cefrLevel: j['cefr_level'] as String? ?? 'A1',
        progressPoints: (j['progress_points'] as num?)?.toDouble() ?? 0,
      );
}

/// Plan del usuario (user_plans).
class UserPlan {
  const UserPlan({
    required this.currentLevel,
    required this.goalLevel,
    this.dailyMinutes,
    this.daysPerWeek,
    this.motive,
    this.deadline,
    this.estimatedHours,
    this.estimatedCompletion,
    this.onboardingCompleted = true,
  });

  final String currentLevel;
  final String goalLevel;
  final int? dailyMinutes;
  final int? daysPerWeek;
  final String? motive;
  final DateTime? deadline;
  final int? estimatedHours;
  final DateTime? estimatedCompletion;
  final bool onboardingCompleted;

  factory UserPlan.fromJson(Map<String, dynamic> j) => UserPlan(
        currentLevel: j['current_level'] as String? ?? 'A1',
        goalLevel: j['goal_level'] as String? ?? 'B1',
        dailyMinutes: (j['daily_minutes'] as num?)?.toInt(),
        daysPerWeek: (j['days_per_week'] as num?)?.toInt(),
        motive: j['motive'] as String?,
        deadline: DateTime.tryParse(j['deadline']?.toString() ?? ''),
        estimatedHours: (j['estimated_hours'] as num?)?.toInt(),
        estimatedCompletion:
            DateTime.tryParse(j['estimated_completion_date']?.toString() ?? ''),
        onboardingCompleted: j['onboarding_completed'] as bool? ?? false,
      );
}

/// Seguimiento del plan (get_plan_tracking) — dashboard del diferenciador.
class PlanTracking {
  const PlanTracking({
    required this.ok,
    required this.currentLevel,
    required this.goalLevel,
    required this.motive,
    required this.dailyMinutes,
    required this.daysPerWeek,
    required this.daysElapsed,
    required this.goalMetDays,
    required this.expectedDays,
    required this.aheadBehind,
    required this.totalActiveDays,
    required this.progress,
    required this.onTrack,
    this.estimatedCompletion,
    this.projectedCompletion,
  });

  final bool ok;
  final String currentLevel;
  final String goalLevel;
  final String? motive;
  final int dailyMinutes;
  final int daysPerWeek;
  final int daysElapsed;
  final int goalMetDays;
  final int expectedDays;
  final int aheadBehind; // >0 adelante, <0 atrás
  final int totalActiveDays;
  final double progress; // 0..1
  final bool onTrack;
  final DateTime? estimatedCompletion;
  final DateTime? projectedCompletion;

  static const empty = PlanTracking(
      ok: false, currentLevel: 'A1', goalLevel: 'B1', motive: null,
      dailyMinutes: 10, daysPerWeek: 5, daysElapsed: 0, goalMetDays: 0,
      expectedDays: 0, aheadBehind: 0, totalActiveDays: 1, progress: 0, onTrack: true);

  factory PlanTracking.fromJson(Map<String, dynamic> j) => PlanTracking(
        ok: j['ok'] as bool? ?? false,
        currentLevel: j['current_level'] as String? ?? 'A1',
        goalLevel: j['goal_level'] as String? ?? 'B1',
        motive: j['motive'] as String?,
        dailyMinutes: (j['daily_minutes'] as num?)?.toInt() ?? 10,
        daysPerWeek: (j['days_per_week'] as num?)?.toInt() ?? 5,
        daysElapsed: (j['days_elapsed'] as num?)?.toInt() ?? 0,
        goalMetDays: (j['goal_met_days'] as num?)?.toInt() ?? 0,
        expectedDays: (j['expected_days'] as num?)?.toInt() ?? 0,
        aheadBehind: (j['ahead_behind'] as num?)?.toInt() ?? 0,
        totalActiveDays: (j['total_active_days'] as num?)?.toInt() ?? 1,
        progress: (j['progress'] as num?)?.toDouble() ?? 0,
        onTrack: j['on_track'] as bool? ?? true,
        estimatedCompletion: DateTime.tryParse(j['estimated_completion']?.toString() ?? ''),
        projectedCompletion: DateTime.tryParse(j['projected_completion']?.toString() ?? ''),
      );
}

/// Resumen devuelto por complete_lesson (server-side).
class LessonSummary {
  const LessonSummary({
    required this.xpEarned,
    required this.goldEarned,
    required this.accuracy,
    required this.graded,
    required this.comboBonus,
    required this.maxCombo,
    required this.status,
    required this.streak,
    required this.skillsUp,
    this.streakAdvanced = false,
    this.goalMet = false,
    this.dailyGoalXp = 0,
    this.dailyXpEarned = 0,
    this.milestone = 0,
    this.nextLessonId,
  });

  final int xpEarned;
  final int goldEarned;
  final double accuracy;
  final int graded;
  final int comboBonus;
  final int maxCombo;
  final String status; // completed | golden
  final int streak;
  final bool streakAdvanced; // la racha subió con esta lección
  final bool goalMet; // se cumplió la meta diaria
  final int dailyGoalXp;
  final int dailyXpEarned;
  final int milestone; // 7/30/100/365 si se alcanzó un hito
  final List<String> skillsUp; // skills que ganaron puntos
  final String? nextLessonId;

  int get accuracyPct => (accuracy * 100).round();

  factory LessonSummary.fromJson(Map<String, dynamic> j) => LessonSummary(
        xpEarned: (j['xp_earned'] as num?)?.toInt() ?? 0,
        goldEarned: (j['gold_earned'] as num?)?.toInt() ?? 0,
        accuracy: (j['accuracy'] as num?)?.toDouble() ?? 0,
        graded: (j['graded'] as num?)?.toInt() ?? 0,
        comboBonus: (j['combo_bonus'] as num?)?.toInt() ?? 0,
        maxCombo: (j['max_combo'] as num?)?.toInt() ?? 0,
        status: j['status'] as String? ?? 'completed',
        streak: (j['streak'] as num?)?.toInt() ?? 0,
        streakAdvanced: j['streak_advanced'] as bool? ?? false,
        goalMet: j['goal_met'] as bool? ?? false,
        dailyGoalXp: (j['daily_goal_xp'] as num?)?.toInt() ?? 0,
        dailyXpEarned: (j['daily_xp_earned'] as num?)?.toInt() ?? 0,
        milestone: (j['milestone'] as num?)?.toInt() ?? 0,
        nextLessonId: j['next_lesson_id'] as String?,
        skillsUp: ((j['skills'] as List?) ?? const [])
            .map((e) => (e as Map)['skill'].toString())
            .toList(),
      );
}
