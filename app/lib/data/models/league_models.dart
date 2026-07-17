/// Un miembro de la liga (usuario o bot) en el ranking semanal.
class LeagueMember {
  const LeagueMember({
    required this.rank,
    required this.name,
    required this.weeklyXp,
    required this.isMe,
    required this.isBot,
    this.userId,
  });
  final int rank;
  final String name;
  final int weeklyXp;
  final bool isMe;
  final bool isBot;

  /// user_id del miembro (para abrir su perfil público al tocarlo). null para
  /// "yo" y para bots. get_public_profile sigue gateando (18+, bloqueo).
  final String? userId;

  factory LeagueMember.fromJson(Map<String, dynamic> j) => LeagueMember(
        rank: (j['rank'] as num?)?.toInt() ?? 0,
        name: j['name'] as String? ?? 'Aprendiz',
        weeklyXp: (j['weekly_xp'] as num?)?.toInt() ?? 0,
        isMe: j['is_me'] as bool? ?? false,
        isBot: j['is_bot'] as bool? ?? false,
        userId: j['user_id'] as String?,
      );
}

/// Una fila de un leaderboard (de get_leaderboard). SIN user_id por diseño.
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.value,
    required this.isMe,
  });
  final int rank;
  final String name;
  final int value;
  final bool isMe;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> j) => LeaderboardEntry(
        rank: (j['rank'] as num?)?.toInt() ?? 0,
        name: j['name'] as String? ?? 'Aprendiz',
        value: (j['value'] as num?)?.toInt() ?? 0,
        isMe: j['is_me'] as bool? ?? false,
      );
}

/// Resultado de get_leaderboard(metric, window, scope).
class LeaderboardResult {
  const LeaderboardResult({
    required this.metric,
    required this.window,
    required this.scope,
    required this.total,
    required this.myRank,
    required this.myValue,
    required this.entries,
  });
  final String metric;
  final String window;
  final String scope;
  final int total;
  final int? myRank;
  final int myValue;
  final List<LeaderboardEntry> entries;

  factory LeaderboardResult.fromJson(Map<String, dynamic> j) => LeaderboardResult(
        metric: j['metric'] as String? ?? 'xp',
        window: j['window'] as String? ?? 'weekly',
        scope: j['scope'] as String? ?? 'global',
        total: (j['total'] as num?)?.toInt() ?? 0,
        myRank: (j['my_rank'] as num?)?.toInt(),
        myValue: (j['my_value'] as num?)?.toInt() ?? 0,
        entries: ((j['entries'] as List?) ?? const [])
            .map((e) => LeaderboardEntry.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}

/// La liga semanal del usuario (de get_league).
class LeagueStanding {
  const LeagueStanding({
    required this.division,
    required this.myRank,
    required this.promote,
    required this.demote,
    required this.members,
    this.players = 0,
    this.minPlayers = 5,
    this.warmingUp = false,
    this.weekStart,
  });
  final String division; // bronce | plata | ...

  /// Lunes (UTC) de la semana de liga; el cierre real es weekStart + 7 días
  /// (jz_close_weeks). Alimenta el countdown "Termina en Xd Yh" (Ligas.dc).
  final DateTime? weekStart;
  final int myRank;
  final int promote; // top N asciende
  final int demote; // bottom N desciende
  final List<LeagueMember> members;
  final int players; // jugadores REALES en la liga
  final int minPlayers; // masa crítica para competir
  final bool warmingUp; // aún sin masa crítica

  /// Hay ascensos/descensos reales esta semana. El servidor devuelve promote/
  /// demote = 0 mientras la liga no alcance el umbral de movimiento (13, == gate
  /// del rollover) → evita pintar zonas engañosas en ligas pequeñas de beta.
  bool get movementActive => promote > 0 && demote > 0;

  String get divisionLabel {
    switch (division) {
      case 'bronce': return 'Bronce';
      case 'plata': return 'Plata';
      case 'oro': return 'Oro';
      case 'zafiro': return 'Zafiro';
      case 'rubi': return 'Rubí';
      case 'diamante': return 'Diamante';
      default: return division;
    }
  }

  factory LeagueStanding.fromJson(Map<String, dynamic> j) => LeagueStanding(
        division: j['division'] as String? ?? 'bronce',
        myRank: (j['my_rank'] as num?)?.toInt() ?? 0,
        promote: (j['promote'] as num?)?.toInt() ?? 5,
        demote: (j['demote'] as num?)?.toInt() ?? 5,
        players: (j['players'] as num?)?.toInt() ?? 0,
        minPlayers: (j['min_players'] as num?)?.toInt() ?? 5,
        warmingUp: j['warming_up'] as bool? ?? false,
        weekStart: DateTime.tryParse(j['week_start']?.toString() ?? ''),
        members: ((j['members'] as List?) ?? const [])
            .map((e) => LeagueMember.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}
