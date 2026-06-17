// Modelos de los datos de progreso del usuario (paso E).

/// Stats agregados para la top bar y el perfil.
class HomeStats {
  const HomeStats({
    required this.xpTotal,
    required this.gold,
    required this.hearts,
    required this.playerLevel,
    required this.currentStreak,
    required this.dailyGoalXp,
    required this.dailyXpEarned,
  });

  final int xpTotal;
  final int gold;
  final int hearts;
  final int playerLevel;
  final int currentStreak;
  final int dailyGoalXp;
  final int dailyXpEarned;

  double get dailyProgress =>
      dailyGoalXp <= 0 ? 0 : (dailyXpEarned / dailyGoalXp).clamp(0.0, 1.0);

  static const empty = HomeStats(
    xpTotal: 0,
    gold: 0,
    hearts: 5,
    playerLevel: 1,
    currentStreak: 0,
    dailyGoalXp: 30,
    dailyXpEarned: 0,
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
        nextLessonId: j['next_lesson_id'] as String?,
        skillsUp: ((j['skills'] as List?) ?? const [])
            .map((e) => (e as Map)['skill'].toString())
            .toList(),
      );
}
