/// Un miembro de la liga (usuario o bot) en el ranking semanal.
class LeagueMember {
  const LeagueMember({
    required this.rank,
    required this.name,
    required this.weeklyXp,
    required this.isMe,
    required this.isBot,
  });
  final int rank;
  final String name;
  final int weeklyXp;
  final bool isMe;
  final bool isBot;

  factory LeagueMember.fromJson(Map<String, dynamic> j) => LeagueMember(
        rank: (j['rank'] as num?)?.toInt() ?? 0,
        name: j['name'] as String? ?? 'Aprendiz',
        weeklyXp: (j['weekly_xp'] as num?)?.toInt() ?? 0,
        isMe: j['is_me'] as bool? ?? false,
        isBot: j['is_bot'] as bool? ?? false,
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
  });
  final String division; // bronce | plata | ...
  final int myRank;
  final int promote; // top N asciende
  final int demote; // bottom N desciende
  final List<LeagueMember> members;
  final int players; // jugadores REALES en la liga
  final int minPlayers; // masa crítica para competir
  final bool warmingUp; // aún sin masa crítica

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
        members: ((j['members'] as List?) ?? const [])
            .map((e) => LeagueMember.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}
