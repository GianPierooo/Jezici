import 'achievement_models.dart';
import 'checkpoint_models.dart';

/// Estado del examen de nivel (de level_exam_status).
class LevelExamStatus {
  const LevelExamStatus({
    required this.level,
    required this.unitsDone,
    required this.unitsTotal,
    required this.skillsOk,
    required this.unlocked,
    required this.hasCertificate,
  });
  final String level;
  final int unitsDone;
  final int unitsTotal;
  final bool skillsOk;
  final bool unlocked;
  final bool hasCertificate;

  factory LevelExamStatus.fromJson(Map<String, dynamic> j) => LevelExamStatus(
        level: j['level'] as String? ?? 'A1',
        unitsDone: (j['units_done'] as num?)?.toInt() ?? 0,
        unitsTotal: (j['units_total'] as num?)?.toInt() ?? 0,
        skillsOk: j['skills_ok'] as bool? ?? false,
        unlocked: j['unlocked'] as bool? ?? false,
        hasCertificate: j['has_certificate'] as bool? ?? false,
      );

  static const empty = LevelExamStatus(
      level: 'A1', unitsDone: 0, unitsTotal: 6, skillsOk: false, unlocked: false, hasCertificate: false);
}

/// Resultado del examen de nivel (de submit_level_exam), con certificado si aprobó.
class LevelExamResult {
  const LevelExamResult({
    required this.passed,
    required this.scoreGlobal,
    required this.threshold,
    required this.graded,
    required this.correct,
    required this.xpEarned,
    required this.goldEarned,
    required this.perSkill,
    required this.weaknesses,
    this.certificate,
    this.certificateSvg,
  });
  final bool passed;
  final double scoreGlobal;
  final double threshold;
  final int graded;
  final int correct;
  final int xpEarned;
  final int goldEarned;
  final List<SkillScore> perSkill;
  final List<String> weaknesses;
  final Certificate? certificate;
  final String? certificateSvg;

  int get scorePct => (scoreGlobal * 100).round();
  int get thresholdPct => (threshold * 100).round();

  factory LevelExamResult.fromJson(Map<String, dynamic> j) {
    final cert = j['certificate'];
    return LevelExamResult(
      passed: j['passed'] as bool? ?? false,
      scoreGlobal: (j['score_global'] as num?)?.toDouble() ?? 0,
      threshold: (j['threshold'] as num?)?.toDouble() ?? 0.8,
      graded: (j['graded'] as num?)?.toInt() ?? 0,
      correct: (j['correct'] as num?)?.toInt() ?? 0,
      xpEarned: (j['xp_earned'] as num?)?.toInt() ?? 0,
      goldEarned: (j['gold_earned'] as num?)?.toInt() ?? 0,
      perSkill: ((j['per_skill'] as List?) ?? const [])
          .map((e) => SkillScore.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      weaknesses: ((j['weaknesses'] as List?) ?? const []).map((e) => e.toString()).toList(),
      certificate: cert == null ? null : Certificate.fromJson(Map<String, dynamic>.from(cert as Map)),
      certificateSvg: cert == null ? null : (cert as Map)['svg'] as String?,
    );
  }
}
