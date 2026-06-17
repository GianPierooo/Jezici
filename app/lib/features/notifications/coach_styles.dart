/// Metadatos de los 4 estilos de coach de Matix (Test_Personalidad.md).
/// El estilo decide el TONO de cada notificación.
class CoachStyle {
  const CoachStyle(this.key, this.emoji, this.label, this.description, this.sample);
  final String key;
  final String emoji;
  final String label;
  final String description;
  final String sample;

  static const all = <CoachStyle>[
    CoachStyle('mano_dura', '💪', 'Mano dura',
        'Directo y exigente. Sin rodeos.', '«Sin excusas. Entra ya.»'),
    CoachStyle('positivo', '🎉', 'Positivo',
        'Ánimo y celebración constante.', '«¡Casi! Te falta poquito 💪»'),
    CoachStyle('rezago', '⏰', 'Sin rezago',
        'Te avisa con datos y urgencia.', '«Vas 10/15 XP. No te quedes corto.»'),
    CoachStyle('suave', '🙂', 'Suave',
        'Recordatorios amables, sin presión.', '«Cuando puedas, una lección corta 🙂»'),
  ];

  static CoachStyle of(String key) =>
      all.firstWhere((s) => s.key == key, orElse: () => all.last);
}
