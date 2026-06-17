/// Un logro/badge (catálogo + estado del usuario), de get_achievements().
class Achievement {
  const Achievement({
    required this.code,
    required this.name,
    required this.description,
    required this.icon,
    required this.hint,
    required this.unlocked,
    this.unlockedAt,
  });

  final String code;
  final String name;
  final String description;
  final String icon; // emoji
  final String hint;
  final bool unlocked;
  final DateTime? unlockedAt;

  factory Achievement.fromJson(Map<String, dynamic> j) => Achievement(
        code: j['code'] as String? ?? '',
        name: j['name'] as String? ?? '',
        description: j['description'] as String? ?? '',
        icon: j['icon'] as String? ?? '🏅',
        hint: j['hint'] as String? ?? '',
        unlocked: j['unlocked'] as bool? ?? false,
        unlockedAt: DateTime.tryParse(j['unlocked_at']?.toString() ?? ''),
      );
}

/// Un certificado de nivel emitido (de get_certificates()).
class Certificate {
  const Certificate({
    required this.cefrLevel,
    required this.folio,
    required this.verificationCode,
    this.issuedAt,
    this.pdfUrl,
  });

  final String cefrLevel;
  final String folio;
  final String verificationCode;
  final DateTime? issuedAt;
  final String? pdfUrl;

  factory Certificate.fromJson(Map<String, dynamic> j) => Certificate(
        cefrLevel: j['cefr_level'] as String? ?? '',
        folio: j['folio'] as String? ?? '',
        verificationCode: j['verification_code'] as String? ?? '',
        issuedAt: DateTime.tryParse(j['issued_at']?.toString() ?? ''),
        pdfUrl: j['pdf_url'] as String?,
      );
}
