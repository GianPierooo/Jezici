// Modelos del checkpoint de unidad (paso F).
import 'content_item_model.dart';

/// Datos del examen devueltos por start_checkpoint (sin correct_answer).
class CheckpointStartData {
  const CheckpointStartData({
    required this.examId,
    required this.timeLimitSec,
    required this.passThreshold,
    required this.itemCount,
    required this.items,
  });

  final String examId;
  final int timeLimitSec;
  final double passThreshold;
  final int itemCount;
  final List<ContentItemModel> items;

  factory CheckpointStartData.fromJson(Map<String, dynamic> j) => CheckpointStartData(
        examId: j['exam_id'] as String? ?? '',
        timeLimitSec: (j['time_limit_sec'] as num?)?.toInt() ?? 300,
        passThreshold: (j['pass_threshold'] as num?)?.toDouble() ?? 0.8,
        itemCount: (j['item_count'] as num?)?.toInt() ?? 0,
        items: ((j['items'] as List?) ?? const [])
            .map((e) => ContentItemModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}

/// Puntaje de una habilidad en el checkpoint.
class SkillScore {
  const SkillScore({
    required this.skill,
    required this.total,
    required this.correct,
    required this.graded,
    required this.accuracy,
  });

  final String skill;
  final int total;
  final int correct;
  final int graded; // ítems calificables (listening/speaking = 0 en Fase 1)
  final double? accuracy; // null si no se calificó (stub)

  bool get isGraded => graded > 0;
  int get accuracyPct => ((accuracy ?? 0) * 100).round();

  factory SkillScore.fromJson(Map<String, dynamic> j) => SkillScore(
        skill: j['skill'] as String,
        total: (j['total'] as num?)?.toInt() ?? 0,
        correct: (j['correct'] as num?)?.toInt() ?? 0,
        graded: (j['graded'] as num?)?.toInt() ?? 0,
        accuracy: (j['accuracy'] as num?)?.toDouble(),
      );
}

/// Resultado de submit_checkpoint.
class CheckpointResult {
  const CheckpointResult({
    required this.passed,
    required this.scoreGlobal,
    required this.threshold,
    required this.attemptNumber,
    required this.graded,
    required this.correct,
    required this.xpEarned,
    required this.goldEarned,
    required this.perSkill,
    required this.weaknesses,
    required this.nextUnlocked,
  });

  final bool passed;
  final double scoreGlobal;
  final double threshold;
  final int attemptNumber;
  final int graded;
  final int correct;
  final int xpEarned;
  final int goldEarned;
  final List<SkillScore> perSkill;
  final List<String> weaknesses;
  final bool nextUnlocked;

  int get scorePct => (scoreGlobal * 100).round();
  int get thresholdPct => (threshold * 100).round();

  factory CheckpointResult.fromJson(Map<String, dynamic> j) => CheckpointResult(
        passed: j['passed'] as bool? ?? false,
        scoreGlobal: (j['score_global'] as num?)?.toDouble() ?? 0,
        threshold: (j['threshold'] as num?)?.toDouble() ?? 0.8,
        attemptNumber: (j['attempt_number'] as num?)?.toInt() ?? 1,
        graded: (j['graded'] as num?)?.toInt() ?? 0,
        correct: (j['correct'] as num?)?.toInt() ?? 0,
        xpEarned: (j['xp_earned'] as num?)?.toInt() ?? 0,
        goldEarned: (j['gold_earned'] as num?)?.toInt() ?? 0,
        perSkill: ((j['per_skill'] as List?) ?? const [])
            .map((e) => SkillScore.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        weaknesses:
            ((j['weaknesses'] as List?) ?? const []).map((e) => e.toString()).toList(),
        nextUnlocked: j['next_unlocked'] as bool? ?? false,
      );
}
