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

/// Una tarjeta del SRS (motor FSRS, server-side). El cliente NUNCA agenda: pinta
/// la tarjeta, manda lo escrito + el rating, y el servidor decide.
///
/// DEGRADACIÓN CON GRACIA (PRACTICAR_SRS_ANALISIS.md §6): si la palabra tiene una
/// oración-ejemplo → `kind='cloze'` (escribe la palabra que falta EN CONTEXTO);
/// si no → `kind='word'` (traducción → escribe la palabra). Nunca opción múltiple.
class SrsCard {
  const SrsCard({
    required this.vocabId,
    required this.word,
    required this.translation,
    required this.kind,
    this.sentence,
    this.audioUrl,
    this.isNew = false,
  });

  final String vocabId;
  final String word; // respuesta (idioma meta)
  final String translation; // pista (español)
  final String kind; // 'cloze' | 'word'
  final String? sentence; // solo kind='cloze'
  final String? audioUrl; // hoy null: el audio de vocab es F3
  final bool isNew;

  bool get isCloze => kind == 'cloze' && (sentence?.isNotEmpty ?? false);

  factory SrsCard.fromJson(Map<String, dynamic> j) => SrsCard(
        vocabId: j['vocab_id'] as String,
        word: (j['word'] as String?) ?? '',
        translation: (j['translation'] as String?) ?? '',
        kind: (j['kind'] as String?) ?? 'word',
        sentence: j['sentence'] as String?,
        audioUrl: j['audio_url'] as String?,
        isNew: j['is_new'] as bool? ?? false,
      );
}

/// Sesión de repaso SRS: vencidas + nuevas (con el límite diario del servidor).
class SrsSession {
  const SrsSession({required this.cards, this.dueCount = 0, this.newLeft = 0});
  final List<SrsCard> cards;
  final int dueCount;
  final int newLeft;

  factory SrsSession.fromJson(Map<String, dynamic> j) => SrsSession(
        dueCount: (j['due_count'] as num?)?.toInt() ?? 0,
        newLeft: (j['new_left'] as num?)?.toInt() ?? 0,
        cards: ((j['cards'] as List?) ?? const [])
            .map((e) => SrsCard.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}

/// Estado del SRS (spec §2.6): vencidas, nuevas restantes hoy, y RETENCIÓN.
/// `retentionPct` es null mientras no haya reviews maduras — el servidor no
/// inventa un número (honesto).
class SrsStatus {
  const SrsStatus({
    this.due = 0,
    this.newLeft = 0,
    this.newAvailable = 0,
    this.totalCards = 0,
    this.matureCards = 0,
    this.retentionPct,
    this.reviewsTotal = 0,
  });

  final int due;
  final int newLeft;
  final int newAvailable;
  final int totalCards;
  final int matureCards;
  final int? retentionPct;
  final int reviewsTotal;

  /// ¿Hay algo que hacer ahora? (vencidas o nuevas por introducir hoy)
  int get sessionCount => due + (newAvailable < newLeft ? newAvailable : newLeft);

  factory SrsStatus.fromJson(Map<String, dynamic> j) => SrsStatus(
        due: (j['due'] as num?)?.toInt() ?? 0,
        newLeft: (j['new_left'] as num?)?.toInt() ?? 0,
        newAvailable: (j['new_available'] as num?)?.toInt() ?? 0,
        totalCards: (j['total_cards'] as num?)?.toInt() ?? 0,
        matureCards: (j['mature_cards'] as num?)?.toInt() ?? 0,
        retentionPct: (j['retention_pct'] as num?)?.toInt(),
        reviewsTotal: (j['reviews_total'] as num?)?.toInt() ?? 0,
      );

  static const empty = SrsStatus();
}

/// Estado para las tarjetas de Practicar (palabras por repasar + skill débil).
class PracticeStatus {
  const PracticeStatus({required this.dueWords, this.weakestSkill, this.hasProgress = true});
  final int dueWords;
  final String? weakestSkill;

  /// ¿El usuario ya empezó (tiene progreso de lecciones)? Un NOVATO de cero
  /// (false) ve un estado de bienvenida en lugar de secciones vacías. Default
  /// true para no parpadear a los usuarios existentes durante la carga.
  final bool hasProgress;

  static const empty = PracticeStatus(dueWords: 0);
}
