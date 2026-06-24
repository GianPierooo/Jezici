// Modelos de Historias / Inmersión (input comprensible). El servidor (mig 065)
// nunca envía la respuesta correcta en get_story; la calificación es server-side
// (submit_story). Aquí solo viven proyecciones de lectura.

class StorySummary {
  StorySummary({
    required this.id,
    required this.level,
    required this.order,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.estSeconds,
    required this.segmentCount,
    required this.questionCount,
    required this.completed,
    required this.bestScore,
  });

  final String id;
  final String level;
  final int order;
  final String title;
  final String subtitle;
  final String emoji;
  final int estSeconds;
  final int segmentCount;
  final int questionCount;
  final bool completed;
  final double bestScore;

  factory StorySummary.fromJson(Map<String, dynamic> j) => StorySummary(
        id: j['id'] as String,
        level: (j['cefr_level'] ?? '') as String,
        order: (j['order_index'] ?? 0) as int,
        title: (j['title'] ?? '') as String,
        subtitle: (j['subtitle'] ?? '') as String,
        emoji: (j['emoji'] ?? '📖') as String,
        estSeconds: (j['est_seconds'] ?? 60) as int,
        segmentCount: (j['segment_count'] ?? 0) as int,
        questionCount: (j['question_count'] ?? 0) as int,
        completed: (j['completed'] ?? false) as bool,
        bestScore: ((j['best_score'] ?? 0) as num).toDouble(),
      );
}

class StorySegment {
  StorySegment({required this.en, required this.es, required this.audioUrl});
  final String en;
  final String es;
  final String audioUrl;

  factory StorySegment.fromJson(Map<String, dynamic> j) => StorySegment(
        en: (j['en'] ?? '') as String,
        es: (j['es'] ?? '') as String,
        audioUrl: (j['audio_url'] ?? '') as String,
      );
}

class StoryQuestion {
  StoryQuestion({
    required this.i,
    required this.type,
    required this.prompt,
    required this.options,
    required this.text,
  });

  final int i;
  final String type; // multiple_choice | cloze
  final String prompt;
  final List<String> options; // mc
  final String text; // cloze (con ___)

  bool get isCloze => type == 'cloze';

  factory StoryQuestion.fromJson(Map<String, dynamic> j) {
    final payload = Map<String, dynamic>.from((j['payload'] ?? const {}) as Map);
    return StoryQuestion(
      i: (j['i'] ?? 0) as int,
      type: (j['type'] ?? 'multiple_choice') as String,
      prompt: (j['prompt'] ?? '') as String,
      options: ((payload['options'] ?? const []) as List).map((e) => e.toString()).toList(),
      text: (payload['text'] ?? '') as String,
    );
  }
}

class StoryDetail {
  StoryDetail({
    required this.id,
    required this.level,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.intro,
    required this.estSeconds,
    required this.segments,
    required this.glossary,
    required this.questions,
    required this.completed,
    required this.bestScore,
  });

  final String id;
  final String level;
  final String title;
  final String subtitle;
  final String emoji;
  final String intro;
  final int estSeconds;
  final List<StorySegment> segments;
  final List<({String word, String translation})> glossary;
  final List<StoryQuestion> questions;
  final bool completed;
  final double bestScore;

  factory StoryDetail.fromJson(Map<String, dynamic> j) => StoryDetail(
        id: j['id'] as String,
        level: (j['cefr_level'] ?? '') as String,
        title: (j['title'] ?? '') as String,
        subtitle: (j['subtitle'] ?? '') as String,
        emoji: (j['emoji'] ?? '📖') as String,
        intro: (j['intro'] ?? '') as String,
        estSeconds: (j['est_seconds'] ?? 60) as int,
        segments: ((j['segments'] ?? const []) as List)
            .map((e) => StorySegment.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        glossary: ((j['glossary'] ?? const []) as List)
            .map((e) {
              final m = Map<String, dynamic>.from(e as Map);
              return (word: (m['word'] ?? '').toString(), translation: (m['translation'] ?? '').toString());
            })
            .toList(),
        questions: ((j['questions'] ?? const []) as List)
            .map((e) => StoryQuestion.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        completed: (j['completed'] ?? false) as bool,
        bestScore: ((j['best_score'] ?? 0) as num).toDouble(),
      );
}

class StoryResult {
  StoryResult({
    required this.score,
    required this.correct,
    required this.total,
    required this.firstTime,
    required this.xpEarned,
    required this.perQuestion,
  });

  final double score;
  final int correct;
  final int total;
  final bool firstTime;
  final int xpEarned;
  final List<({int i, bool correct, String expected})> perQuestion;

  factory StoryResult.fromJson(Map<String, dynamic> j) => StoryResult(
        score: ((j['score'] ?? 0) as num).toDouble(),
        correct: (j['correct'] ?? 0) as int,
        total: (j['total'] ?? 0) as int,
        firstTime: (j['first_time'] ?? false) as bool,
        xpEarned: (j['xp_earned'] ?? 0) as int,
        perQuestion: ((j['per_question'] ?? const []) as List).map((e) {
          final m = Map<String, dynamic>.from(e as Map);
          final exp = m['expected'];
          final expStr = exp is Map ? (exp['value'] ?? '').toString() : (exp ?? '').toString();
          return (i: (m['i'] ?? 0) as int, correct: (m['correct'] ?? false) as bool, expected: expStr);
        }).toList(),
      );
}
