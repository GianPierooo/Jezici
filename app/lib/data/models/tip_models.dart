/// Tip pedagógico (capa "enseña"): micro-enseñanza curada ligada a una unidad.
class TipModel {
  TipModel({
    required this.id,
    required this.type,
    required this.skill,
    required this.cefrLevel,
    required this.title,
    required this.body,
    this.example,
    this.weakSkill,
    this.unitOrder,
    this.seenAt,
    this.seen = false,
  });

  final String id;
  final String type; // tip_idioma|nota_cultural|error_comun|pronunciacion|mnemotecnia
  final String skill;
  final String cefrLevel;
  final String title;
  final String body;
  final String? example;
  final String? weakSkill; // skill más débil del usuario (personalización)
  final int? unitOrder;
  final String? seenAt;
  final bool seen; // en la Referencia: si ya lo viste (cuaderno)

  /// Etiqueta legible del tipo (para el chip).
  String get typeLabel => switch (type) {
        'tip_idioma' => 'Tip de idioma',
        'nota_cultural' => '¿Sabías que…?',
        'error_comun' => 'Error común',
        'pronunciacion' => 'Pronunciación',
        'mnemotecnia' => 'Truco para recordar',
        _ => 'Tip',
      };

  factory TipModel.fromJson(Map<String, dynamic> j) => TipModel(
        id: j['id'] as String,
        type: j['type'] as String? ?? 'tip_idioma',
        skill: j['skill'] as String? ?? 'reading',
        cefrLevel: j['cefr_level'] as String? ?? 'A1',
        title: j['title'] as String? ?? '',
        body: j['body'] as String? ?? '',
        example: j['example'] as String?,
        weakSkill: j['weak_skill'] as String?,
        unitOrder: (j['unit_order'] as num?)?.toInt(),
        seenAt: j['seen_at'] as String?,
        seen: j['seen'] as bool? ?? false,
      );
}

/// Referencia navegable (get_reference): conceptos curados del curso activo +
/// la habilidad más floja sugerida. Estilo Busuu "Grammar Review".
class ReferenceData {
  const ReferenceData({required this.weakest, required this.tips});
  final String? weakest;
  final List<TipModel> tips;

  /// Tips agrupados por habilidad, en orden reading→listening→writing→speaking.
  Map<String, List<TipModel>> get bySkill {
    const order = ['reading', 'listening', 'writing', 'speaking'];
    final m = <String, List<TipModel>>{for (final s in order) s: []};
    for (final t in tips) {
      (m[t.skill] ??= []).add(t);
    }
    return m;
  }

  factory ReferenceData.fromJson(Map<String, dynamic> j) => ReferenceData(
        weakest: j['weakest'] as String?,
        tips: ((j['tips'] as List?) ?? const [])
            .map((e) => TipModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}
