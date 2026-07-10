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
    this.holderName,
    this.issuedAt,
    this.pdfUrl,
    this.lang = 'en',
  });

  final String cefrLevel;
  final String folio;
  final String verificationCode;

  /// Idioma META del curso del certificado ('en'|'pt'|...; mig 138).
  final String lang;

  /// Nombre del titular congelado al emitir (get_certificates, mig 133). null en
  /// el certificado recién emitido por submit_level_exam (la pantalla cae a get_profile).
  final String? holderName;
  final DateTime? issuedAt;
  final String? pdfUrl;

  factory Certificate.fromJson(Map<String, dynamic> j) => Certificate(
        cefrLevel: j['cefr_level'] as String? ?? '',
        folio: j['folio'] as String? ?? '',
        verificationCode: j['verification_code'] as String? ?? '',
        holderName: (j['holder_name'] as String?)?.trim().isEmpty ?? true
            ? null
            : (j['holder_name'] as String).trim(),
        issuedAt: DateTime.tryParse(j['issued_at']?.toString() ?? ''),
        pdfUrl: j['pdf_url'] as String?,
        lang: j['lang'] as String? ?? 'en',
      );
}
