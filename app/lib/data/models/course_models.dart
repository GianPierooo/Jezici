/// Curso (par de idiomas) disponible y si es el activo del usuario.
class CourseInfo {
  CourseInfo({
    required this.id,
    required this.source,
    required this.target,
    required this.targetName,
    required this.active,
  });

  final String id;
  final String source; // código ISO del idioma de origen (es)
  final String target; // código ISO del idioma meta (en, pt)
  final String targetName; // nombre legible (English, Português)
  final bool active; // ¿es el curso activo del usuario?

  /// Etiqueta para la UI, p.ej. "Español → Português".
  String get label => 'Español → $targetName';

  /// Bandera/emoji aproximado por idioma meta (sin assets extra).
  String get flag => switch (target) {
        'en' => '🇬🇧',
        'pt' => '🇧🇷',
        'fr' => '🇫🇷',
        'it' => '🇮🇹',
        _ => '🌐',
      };

  factory CourseInfo.fromJson(Map<String, dynamic> j) => CourseInfo(
        id: j['id'] as String,
        source: j['source'] as String? ?? 'es',
        target: j['target'] as String? ?? '',
        targetName: j['target_name'] as String? ?? '',
        active: j['active'] as bool? ?? false,
      );
}
