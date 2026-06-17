import 'content_item_model.dart';

/// Sesión de práctica devuelta por start_practice (ítems CON respuesta para dar
/// feedback inmediato; la apuesta es baja y el servidor recalifica al enviar).
class PracticeSession {
  const PracticeSession({
    required this.mode,
    required this.items,
    this.dueCount = 0,
    this.weakestSkill,
  });

  final String mode; // srs | weakness | skill | timed
  final List<ContentItemModel> items;
  final int dueCount;
  final String? weakestSkill;

  factory PracticeSession.fromJson(Map<String, dynamic> j) => PracticeSession(
        mode: j['mode'] as String? ?? '',
        dueCount: (j['due_count'] as num?)?.toInt() ?? 0,
        weakestSkill: j['weakest_skill'] as String?,
        items: ((j['items'] as List?) ?? const [])
            .map((e) => ContentItemModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}

/// Resumen devuelto por submit_practice (server-side).
class PracticeSummary {
  const PracticeSummary({
    required this.mode,
    required this.graded,
    required this.correct,
    required this.accuracy,
    required this.xpEarned,
    required this.goldEarned,
    required this.streak,
    required this.streakAdvanced,
    required this.goalMet,
  });

  final String mode;
  final int graded;
  final int correct;
  final double accuracy;
  final int xpEarned;
  final int goldEarned;
  final int streak;
  final bool streakAdvanced;
  final bool goalMet;

  int get accuracyPct => (accuracy * 100).round();

  factory PracticeSummary.fromJson(Map<String, dynamic> j) => PracticeSummary(
        mode: j['mode'] as String? ?? '',
        graded: (j['graded'] as num?)?.toInt() ?? 0,
        correct: (j['correct'] as num?)?.toInt() ?? 0,
        accuracy: (j['accuracy'] as num?)?.toDouble() ?? 0,
        xpEarned: (j['xp_earned'] as num?)?.toInt() ?? 0,
        goldEarned: (j['gold_earned'] as num?)?.toInt() ?? 0,
        streak: (j['streak'] as num?)?.toInt() ?? 0,
        streakAdvanced: j['streak_advanced'] as bool? ?? false,
        goalMet: j['goal_met'] as bool? ?? false,
      );
}

/// Estado para las tarjetas de Practicar (palabras por repasar + skill débil).
class PracticeStatus {
  const PracticeStatus({required this.dueWords, this.weakestSkill});
  final int dueWords;
  final String? weakestSkill;
  static const empty = PracticeStatus(dueWords: 0);
}
