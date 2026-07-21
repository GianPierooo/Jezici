/// ESTUDIAR · Fase E-2 — la "sesión de estudio" rica de un tema: la teoría
/// explicada paso a paso + ejemplos con audio + errores comunes + una prueba
/// corta. Llena el hueco que E-1 dejó preparado.
///
/// El quiz llega SIN las respuestas (el grading es server-side, como todo el
/// contenido de la app): `submit_study_quiz` califica con el grader tolerante.
class StudySection {
  const StudySection({required this.heading, required this.body, this.bullets = const []});
  final String heading;
  final String body;
  final List<String> bullets;

  factory StudySection.fromJson(Map<String, dynamic> j) => StudySection(
        heading: (j['heading'] ?? '').toString(),
        body: (j['body'] ?? '').toString(),
        bullets: ((j['bullets'] as List?) ?? const []).map((e) => e.toString()).toList(),
      );
}

class StudyExample {
  const StudyExample({required this.en, required this.es, this.audioUrl});
  final String en;
  final String es;
  final String? audioUrl;

  factory StudyExample.fromJson(Map<String, dynamic> j) => StudyExample(
        en: (j['en'] ?? '').toString(),
        es: (j['es'] ?? '').toString(),
        audioUrl: j['audio_url'] as String?,
      );
}

class StudyPitfall {
  const StudyPitfall({required this.title, required this.body});
  final String title;
  final String body;

  factory StudyPitfall.fromJson(Map<String, dynamic> j) => StudyPitfall(
        title: (j['title'] ?? '').toString(),
        body: (j['body'] ?? '').toString(),
      );
}

/// Un ítem de la prueba. Mismos formatos que el motor de ejercicios de la app
/// (cloze / multiple_choice) y calificado por el MISMO grader (jz_grade).
class StudyQuizItem {
  const StudyQuizItem({
    required this.id,
    required this.type,
    required this.prompt,
    this.text,
    this.options = const [],
  });
  final String id;
  final String type; // 'cloze' | 'multiple_choice'
  final String prompt;
  final String? text; // solo cloze (lleva el hueco ___)
  final List<String> options; // solo multiple_choice

  bool get isCloze => type == 'cloze';

  factory StudyQuizItem.fromJson(Map<String, dynamic> j) => StudyQuizItem(
        id: (j['id'] ?? '').toString(),
        type: (j['type'] ?? 'cloze').toString(),
        prompt: (j['prompt'] ?? '').toString(),
        text: j['text'] as String?,
        options: ((j['options'] as List?) ?? const []).map((e) => e.toString()).toList(),
      );
}

class StudyTheory {
  const StudyTheory({
    required this.unitOrder,
    required this.cefrLevel,
    required this.title,
    required this.summary,
    required this.sections,
    required this.examples,
    required this.pitfalls,
    required this.quiz,
  });

  final int unitOrder;
  final String cefrLevel;
  final String title;
  final String summary;
  final List<StudySection> sections;
  final List<StudyExample> examples;
  final List<StudyPitfall> pitfalls;
  final List<StudyQuizItem> quiz;

  bool get hasQuiz => quiz.isNotEmpty;

  factory StudyTheory.fromJson(Map<String, dynamic> j) => StudyTheory(
        unitOrder: (j['unit_order'] as num?)?.toInt() ?? 0,
        cefrLevel: (j['cefr_level'] ?? '').toString(),
        title: (j['title'] ?? '').toString(),
        summary: (j['summary'] ?? '').toString(),
        sections: ((j['sections'] as List?) ?? const [])
            .map((e) => StudySection.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        examples: ((j['examples'] as List?) ?? const [])
            .map((e) => StudyExample.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        pitfalls: ((j['pitfalls'] as List?) ?? const [])
            .map((e) => StudyPitfall.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        quiz: ((j['quiz'] as List?) ?? const [])
            .map((e) => StudyQuizItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}

/// Resultado de la prueba (server-side). FORMATIVO: sin XP/oro ni dominio.
class StudyQuizResult {
  const StudyQuizResult({
    required this.graded,
    required this.correct,
    required this.accuracy,
    required this.passed,
    required this.results,
  });
  final int graded;
  final int correct;
  final double accuracy;
  final bool passed;

  /// id → {correct, expected} (para el repaso al final de la prueba).
  final Map<String, Map<String, dynamic>> results;

  int get accuracyPct => (accuracy * 100).round();

  factory StudyQuizResult.fromJson(Map<String, dynamic> j) => StudyQuizResult(
        graded: (j['graded'] as num?)?.toInt() ?? 0,
        correct: (j['correct'] as num?)?.toInt() ?? 0,
        accuracy: (j['accuracy'] as num?)?.toDouble() ?? 0,
        passed: j['passed'] as bool? ?? false,
        results: {
          for (final r in ((j['results'] as List?) ?? const []))
            (r as Map)['id'].toString(): Map<String, dynamic>.from(r),
        },
      );
}
