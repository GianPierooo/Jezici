/// Perfil del usuario (nombre real, país, avatar, bio, ingreso).
class ProfileInfo {
  ProfileInfo({
    this.name,
    this.email,
    this.country,
    this.bio,
    this.avatarColor = '#6C5CE7',
    this.memberSince,
    this.needsName = false,
    this.birthdayDay,
    this.birthdayMonth,
    this.isAdult,
    this.timezone,
    this.gender,
    this.birthYear,
    this.ageTier,
  });

  final String? name;
  final String? email;
  final String? country; // ISO-2 (BR, ES, MX…)
  final String? bio;
  final String avatarColor; // hex
  final String? memberSince; // YYYY-MM-DD
  final bool needsName;

  /// Cumpleaños SOLO día/mes (sin año, deliberado: minimización de datos).
  final int? birthdayDay;
  final int? birthdayMonth;

  /// Confirmación "soy mayor de edad". null = nunca respondió.
  final bool? isAdult;
  final String? timezone;
  final String? gender; // male|female|other|prefer_not_to_say

  /// Age gate (Conversar P1): AÑO de nacimiento (minimización: solo el año) y el
  /// tier derivado en el servidor (child/teen/adult). null birthYear = falta el
  /// gate → se pide una vez. 18+ es requisito SOLO de lo social (futuro), NO del
  /// loop de aprendizaje: un menor usa la app, solo no accede a lo social.
  final int? birthYear;
  final String? ageTier; // child | teen | adult (derivado en el servidor)

  /// Inicial para el avatar generado.
  String get initial {
    final n = (name ?? '').trim();
    if (n.isNotEmpty) return n.substring(0, 1).toUpperCase();
    final e = (email ?? '').trim();
    return e.isNotEmpty ? e.substring(0, 1).toUpperCase() : '🦜';
  }

  factory ProfileInfo.fromJson(Map<String, dynamic> j) => ProfileInfo(
        name: j['name'] as String?,
        email: j['email'] as String?,
        country: j['country'] as String?,
        bio: j['bio'] as String?,
        avatarColor: (j['avatar_color'] as String?) ?? '#6C5CE7',
        memberSince: j['member_since'] as String?,
        needsName: j['needs_name'] as bool? ?? false,
        birthdayDay: (j['birthday_day'] as num?)?.toInt(),
        birthdayMonth: (j['birthday_month'] as num?)?.toInt(),
        isAdult: j['is_adult'] as bool?,
        timezone: j['timezone'] as String?,
        gender: j['gender'] as String?,
        birthYear: (j['birth_year'] as num?)?.toInt(),
        ageTier: j['age_tier'] as String?,
      );

  static final empty = ProfileInfo();
}

/// Países frecuentes (es→en/pt): ISO-2 → (bandera emoji, nombre).
const Map<String, ({String flag, String name})> kCountries = {
  'MX': (flag: '🇲🇽', name: 'México'),
  'CO': (flag: '🇨🇴', name: 'Colombia'),
  'AR': (flag: '🇦🇷', name: 'Argentina'),
  'ES': (flag: '🇪🇸', name: 'España'),
  'PE': (flag: '🇵🇪', name: 'Perú'),
  'CL': (flag: '🇨🇱', name: 'Chile'),
  'VE': (flag: '🇻🇪', name: 'Venezuela'),
  'EC': (flag: '🇪🇨', name: 'Ecuador'),
  'GT': (flag: '🇬🇹', name: 'Guatemala'),
  'BO': (flag: '🇧🇴', name: 'Bolivia'),
  'DO': (flag: '🇩🇴', name: 'R. Dominicana'),
  'HN': (flag: '🇭🇳', name: 'Honduras'),
  'PY': (flag: '🇵🇾', name: 'Paraguay'),
  'SV': (flag: '🇸🇻', name: 'El Salvador'),
  'NI': (flag: '🇳🇮', name: 'Nicaragua'),
  'CR': (flag: '🇨🇷', name: 'Costa Rica'),
  'PA': (flag: '🇵🇦', name: 'Panamá'),
  'UY': (flag: '🇺🇾', name: 'Uruguay'),
  'US': (flag: '🇺🇸', name: 'Estados Unidos'),
  'BR': (flag: '🇧🇷', name: 'Brasil'),
};

String? countryFlag(String? iso) => iso == null ? null : kCountries[iso]?.flag;
String? countryName(String? iso) => iso == null ? null : kCountries[iso]?.name;

/// Paleta de colores de avatar elegibles (cohesiva con la marca).
const List<String> kAvatarColors = [
  '#6C5CE7', // violeta (marca)
  '#FF6B6B', // coral
  '#FFC93C', // dorado
  '#2ECC71', // verde
  '#3FA7D6', // azul
  '#E07A5F', // terracota
  '#8E44AD', // púrpura
  '#16A085', // teal
];
