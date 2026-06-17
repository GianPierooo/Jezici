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
    this.masteryAvg = 0,
  });
  final String level;
  final int unitsDone;
  final int unitsTotal;
  final bool skillsOk;
  final bool unlocked;
  final bool hasCertificate;
  final double masteryAvg; // promedio de dominio de las 4 habilidades al nivel (0..1)

  factory LevelExamStatus.fromJson(Map<String, dynamic> j) => LevelExamStatus(
        level: j['level'] as String? ?? 'A1',
        unitsDone: (j['units_done'] as num?)?.toInt() ?? 0,
        unitsTotal: (j['units_total'] as num?)?.toInt() ?? 0,
        skillsOk: j['skills_ok'] as bool? ?? false,
        unlocked: j['unlocked'] as bool? ?? false,
        hasCertificate: j['has_certificate'] as bool? ?? false,
        masteryAvg: (j['mastery_avg'] as num?)?.toDouble() ?? 0,
      );

  static const empty = LevelExamStatus(
      level: 'A1', unitsDone: 0, unitsTotal: 6, skillsOk: false, unlocked: false, hasCertificate: false);
}

/// Resultado del examen de nivel (de submit_level_exam), con certificado si aprobó.
class LevelExamResult {
  const LevelExamResult({
    required this.passed,
    required this.level,
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
    this.leveledUp = false,
    this.newLevel,
  });
  final bool passed;
  final String level;
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
  final bool leveledUp;     // el examen SUBIÓ el nivel de las 4 habilidades (modelo D7)
  final String? newLevel;   // nivel al que subió (si leveledUp)

  int get scorePct => (scoreGlobal * 100).round();
  int get thresholdPct => (threshold * 100).round();

  factory LevelExamResult.fromJson(Map<String, dynamic> j) {
    final cert = j['certificate'];
    return LevelExamResult(
      passed: j['passed'] as bool? ?? false,
      level: j['level'] as String? ?? 'A1',
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
      leveledUp: j['leveled_up'] as bool? ?? false,
      newLevel: j['new_level'] as String?,
    );
  }
}

/// Dominio + refuerzo por habilidad (de get_skill_mastery, modelo D6/D8).
class SkillMastery {
  const SkillMastery({
    required this.skill,
    required this.certifiedLevel,
    required this.workingLevel,
    required this.masteryPct,
    required this.reinforceScore,
  });
  final String skill;
  final String certifiedLevel; // nivel certificado (sube sólo por examen)
  final String workingLevel;   // nivel en curso (donde se acumula dominio)
  final double masteryPct;     // 0..1 dominio del nivel en curso
  final double reinforceScore; // 0..1 necesidad de refuerzo (mayor = más urgente)

  factory SkillMastery.fromJson(Map<String, dynamic> j) => SkillMastery(
        skill: j['skill'] as String? ?? '',
        certifiedLevel: j['certified_level'] as String? ?? 'A1',
        workingLevel: j['working_level'] as String? ?? 'A1',
        masteryPct: (j['mastery_pct'] as num?)?.toDouble() ?? 0,
        reinforceScore: (j['reinforce_score'] as num?)?.toDouble() ?? 0,
      );
}

/// Estado de dominio del usuario (de get_skill_mastery): barras de las 4
/// habilidades + estado del examen del nivel en curso.
class SkillMasteryStatus {
  const SkillMasteryStatus({
    required this.workingLevel,
    required this.examUnlocked,
    required this.examHasCertificate,
    required this.masteryAvg,
    required this.skills,
  });
  final String workingLevel;
  final bool examUnlocked;
  final bool examHasCertificate;
  final double masteryAvg;
  final List<SkillMastery> skills;

  SkillMastery? bySkill(String s) {
    for (final m in skills) {
      if (m.skill == s) return m;
    }
    return null;
  }

  factory SkillMasteryStatus.fromJson(Map<String, dynamic> j) {
    final exam = (j['exam'] as Map?) ?? const {};
    return SkillMasteryStatus(
      workingLevel: j['working_level'] as String? ?? 'A1',
      examUnlocked: exam['unlocked'] as bool? ?? false,
      examHasCertificate: exam['has_certificate'] as bool? ?? false,
      masteryAvg: (exam['mastery_avg'] as num?)?.toDouble() ?? 0,
      skills: ((j['skills'] as List?) ?? const [])
          .map((e) => SkillMastery.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }

  static const empty = SkillMasteryStatus(
      workingLevel: 'A1', examUnlocked: false, examHasCertificate: false, masteryAvg: 0, skills: []);
}
