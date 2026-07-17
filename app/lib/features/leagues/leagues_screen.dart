import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/ui/jz_skeleton.dart';
import '../../core/ui/responsive_center.dart';
import '../../data/models/league_models.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/division_names.dart';
import '../conversar/friends.dart' show PublicProfileScreen;
import '../learn/widgets/parrot_mascot.dart';
import 'division_theme.dart';

/// Pestaña LIGAS. Dos vistas vía segmento superior:
///  • "Mi liga": ranking semanal por XP en TU división, con zonas de ascenso
///    (top 7) y descenso (fondo 5) — el cierre/rollover ya es real (mig 059).
///  • "Tablas": leaderboards por Métrica × Ventana × Alcance (get_leaderboard,
///    SIN UUIDs). Estética medida: limpia, dinámica, legible.
/// GA6: solo jugadores reales; con baja población, estado "arrancando".
class LeaguesScreen extends StatefulWidget {
  const LeaguesScreen({super.key});

  @override
  State<LeaguesScreen> createState() => _LeaguesScreenState();
}

class _LeaguesScreenState extends State<LeaguesScreen> {
  int _tab = 0; // 0 = Mi liga · 1 = Tablas

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      bottom: false,
      child: ResponsiveCenter(
        maxWidth: 640,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
              child: _Segmented(
                options: [l10n.leagueTabMyLeague, l10n.leagueTabTables],
                selected: _tab,
                onChanged: (i) => setState(() => _tab = i),
              ),
            ),
            Expanded(child: _tab == 0 ? const _MyLeagueView() : const _LeaderboardView()),
          ],
        ),
      ),
    );
  }
}

// ─── Mi liga (ranking semanal por división, get_league) ──────────────────────
class _MyLeagueView extends ConsumerWidget {
  const _MyLeagueView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(leagueProvider);
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(leagueProvider),
      child: async.when(
        loading: () => ListView(children: const [JzListSkeleton()]),
        error: (e, _) => _ErrorBox(
            onRetry: () => ref.invalidate(leagueProvider),
            label: AppLocalizations.of(context).leagueLoadError),
        data: (lg) => _Board(lg: lg),
      ),
    );
  }
}

class _Center extends StatelessWidget {
  const _Center({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => ListView(
        children: [SizedBox(height: 320, child: Center(child: child))],
      );
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.onRetry, required this.label});
  final VoidCallback onRetry;
  final String label;
  @override
  Widget build(BuildContext context) => _Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.cloud_off_rounded, color: AppColors.textMuted, size: 40),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textMuted)),
          TextButton(onPressed: onRetry, child: Text(AppLocalizations.of(context).commonRetry)),
        ]),
      );
}

class _Board extends StatelessWidget {
  const _Board({required this.lg});
  final LeagueStanding lg;

  /// Countdown "Xd Yh" hasta el cierre (weekStart UTC + 7 días, jz_close_weeks).
  String? _endsIn() {
    final ws = lg.weekStart;
    if (ws == null) return null;
    final end = DateTime.utc(ws.year, ws.month, ws.day).add(const Duration(days: 7));
    final left = end.difference(DateTime.now().toUtc());
    if (left.isNegative) return null;
    if (left.inDays > 0) return '${left.inDays}d ${left.inHours % 24}h';
    if (left.inHours > 0) return '${left.inHours}h ${left.inMinutes % 60}m';
    return '${left.inMinutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final members = lg.members.where((m) => !m.isBot).toList();
    final n = members.length;
    final endsIn = _endsIn();
    return Stack(
      children: [
        ListView(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 110),
      children: [
        // ── Banner de división (Ligas.dc): emblema + carrusel + countdown ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF7A6BF0), AppColors.primary, Color(0xFF5B4ECF)],
            ),
          ),
          child: ResponsiveCenter(
            maxWidth: 480,
            child: Column(
              children: [
                Text(l10n.leagueCurrentDivision,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.2,
                        color: Colors.white.withValues(alpha: 0.7))),
                const SizedBox(height: 6),
                _DivisionEmblem(division: lg.division),
                const SizedBox(height: 2),
                Text(l10n.leagueTitle(divisionLabel(l10n, lg.division)),
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(height: 3),
                Text(
                    lg.warmingUp
                        ? l10n.leagueWarmingUpSubtitle(lg.players)
                        : lg.movementActive
                            ? l10n.leagueRankActive(lg.myRank, lg.promote)
                            : l10n.leagueRankInactive(lg.myRank),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.92))),
                const SizedBox(height: 14),
                // Carrusel de las 6 divisiones (actual destacada, futuras atenuadas).
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final d in DivisionTheme.ladder)
                      Expanded(
                        flex: d == lg.division ? 13 : 10,
                        child: _DivisionDot(division: d, current: lg.division),
                      ),
                  ],
                ),
                if (endsIn != null) ...[
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer_rounded, color: AppColors.gold, size: 15),
                        const SizedBox(width: 7),
                        Text.rich(
                          TextSpan(
                            text: '${l10n.leagueEndsIn} ',
                            style: const TextStyle(
                                fontSize: 12.5, fontWeight: FontWeight.w900, color: Colors.white),
                            children: [
                              TextSpan(
                                  text: endsIn,
                                  style: const TextStyle(color: AppColors.gold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        ResponsiveCenter(
          maxWidth: 640,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (lg.warmingUp) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: AppColors.navActiveBg, borderRadius: BorderRadius.circular(18)),
                    child: Row(
                      children: [
                        const Icon(Icons.eco_rounded, color: AppColors.success, size: 26),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.leagueWarmingUpTitle,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.text)),
                              const SizedBox(height: 2),
                              Text(l10n.leagueWarmingUpMessage(lg.minPlayers),
                                  style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                // Beta: hay jugadores pero aún no la masa (13) para ascensos/descensos.
                if (!lg.warmingUp && !lg.movementActive) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: AppColors.navActiveBg, borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        const Icon(Icons.trending_up_rounded, color: AppColors.primary, size: 22),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Text(l10n.leagueNoMovementNote,
                              style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.text)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(l10n.leagueWeeklyRankingTitle,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.text)),
                    ),
                    Text(l10n.leagueXpThisWeek,
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF9A9FB8))),
                  ],
                ),
                const SizedBox(height: 4),
                Text(l10n.leagueWeeklyRankingHint,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 5), blurRadius: 0),
                      BoxShadow(color: Color(0x123C3778), offset: Offset(0, 14), blurRadius: 26),
                    ],
                  ),
                  child: Column(
                    children: [
                      for (var i = 0; i < n; i++) ...[
                        if (lg.movementActive && i == lg.promote)
                          _ZoneDivider(
                            label: l10n.leaguePromoteTo(
                                divisionLabel(l10n, DivisionTheme.up(lg.division))
                                    .toUpperCase()),
                            icon: Icons.arrow_upward_rounded,
                            color: AppColors.success,
                          ),
                        if (lg.movementActive && i == n - lg.demote)
                          _ZoneDivider(
                            label: l10n.leagueDemoteTo(
                                divisionLabel(l10n, DivisionTheme.down(lg.division))
                                    .toUpperCase()),
                            icon: Icons.arrow_downward_rounded,
                            color: AppColors.coral,
                          ),
                        _RankRow(
                          rank: members[i].rank,
                          name: members[i].name,
                          xp: members[i].weeklyXp,
                          isMe: members[i].isMe,
                          promote: lg.movementActive && i < lg.promote,
                          demote: lg.movementActive && i >= n - lg.demote,
                          // Tocar un jugador (no yo, con user_id) abre su perfil
                          // público. get_public_profile gatea 18+/bloqueo y devuelve
                          // "not found" para menores → degrada con gracia.
                          onTap: (members[i].isMe || members[i].userId == null)
                              ? null
                              : () => Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) =>
                                        PublicProfileScreen(userId: members[i].userId!),
                                  )),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
        // Mascota animadora (Ligas.dc), sobre el ranking.
        Positioned(
          right: 12,
          bottom: 96,
          child: IgnorePointer(
            child: ParrotMascot(size: 52, message: l10n.leagueMascotCheer),
          ),
        ),
      ],
    );
  }
}

/// Separador de zona con la DIVISIÓN DESTINO ("SUBEN A ZAFIRO") — Ligas.dc.
class _ZoneDivider extends StatelessWidget {
  const _ZoneDivider({required this.label, required this.icon, required this.color});
  final String label;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      child: Row(children: [
        Expanded(
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: LinearGradient(
                  colors: [color.withValues(alpha: 0), color.withValues(alpha: 0.5)]),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.4, color: color)),
          ]),
        ),
        Expanded(
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: LinearGradient(
                  colors: [color.withValues(alpha: 0.5), color.withValues(alpha: 0)]),
            ),
          ),
        ),
      ]),
    );
  }
}

/// Emblema-medalla de la división (Ligas.dc): halo pulsante + medalla con
/// gradiente de la división + estrella + cintas. Reduce-motion-aware.
class _DivisionEmblem extends StatefulWidget {
  const _DivisionEmblem({required this.division});
  final String division;

  @override
  State<_DivisionEmblem> createState() => _DivisionEmblemState();
}

class _DivisionEmblemState extends State<_DivisionEmblem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glow;
  bool _reduce = false;

  @override
  void initState() {
    super.initState();
    _glow = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduce = MediaQuery.of(context).disableAnimations;
    if (_reduce) {
      if (_glow.isAnimating) _glow.stop();
    } else if (!_glow.isAnimating) {
      _glow.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = DivisionTheme.of(widget.division);
    return SizedBox(
      width: 112,
      height: 112,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _glow,
            builder: (_, _) {
              final t = _reduce ? 0.5 : _glow.value;
              return Container(
                width: 100 + 14 * t,
                height: 100 + 14 * t,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    theme.end.withValues(alpha: 0.35 + 0.25 * t),
                    theme.end.withValues(alpha: 0),
                  ]),
                ),
              );
            },
          ),
          CustomPaint(size: const Size(112, 112), painter: _MedalPainter(theme)),
        ],
      ),
    );
  }
}

class _MedalPainter extends CustomPainter {
  _MedalPainter(this.theme);
  final DivisionTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final c = Offset(w / 2, h * 0.44);
    // Cintas.
    final ribbonL = Path()
      ..moveTo(w * 0.36, h * 0.68)
      ..lineTo(w * 0.28, h * 0.97)
      ..lineTo(w * 0.44, h * 0.86)
      ..lineTo(w * 0.48, h * 0.72)
      ..close();
    final ribbonR = Path()
      ..moveTo(w * 0.64, h * 0.68)
      ..lineTo(w * 0.72, h * 0.97)
      ..lineTo(w * 0.56, h * 0.86)
      ..lineTo(w * 0.52, h * 0.72)
      ..close();
    canvas.drawPath(ribbonL, Paint()..color = AppColors.coral);
    canvas.drawPath(ribbonR, Paint()..color = const Color(0xFFE0556E));
    // Laureles (arcos con hojas).
    final laurel = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..color = theme.end.withValues(alpha: 0.85);
    canvas.drawArc(
        Rect.fromCircle(center: c, radius: w * 0.42), math.pi * 0.62, math.pi * 0.5, false, laurel);
    canvas.drawArc(
        Rect.fromCircle(center: c, radius: w * 0.42), math.pi * -0.12, math.pi * 0.5, false, laurel);
    final leaf = Paint()..color = theme.start;
    for (var i = 0; i < 4; i++) {
      final a = math.pi * (0.65 + 0.13 * i);
      final p = c + Offset(math.cos(a), math.sin(a)) * w * 0.42;
      canvas.drawOval(Rect.fromCenter(center: p, width: 11, height: 6), leaf);
      final a2 = math.pi * (0.35 - 0.13 * i);
      final p2 = c + Offset(math.cos(a2), math.sin(a2)) * w * 0.42;
      canvas.drawOval(Rect.fromCenter(center: p2, width: 11, height: 6), leaf);
    }
    // Medalla.
    canvas.drawCircle(c, w * 0.31, Paint()..color = theme.shadow);
    canvas.drawCircle(
      c,
      w * 0.28,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [theme.start, theme.end],
        ).createShader(Rect.fromCircle(center: c, radius: w * 0.28)),
    );
    canvas.drawCircle(
        c,
        w * 0.22,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Colors.white.withValues(alpha: 0.7));
    // Estrella central.
    final star = Path();
    const points = 5;
    for (var i = 0; i < points * 2; i++) {
      final r = i.isEven ? w * 0.15 : w * 0.063;
      final a = -math.pi / 2 + i * math.pi / points;
      final p = Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a));
      i == 0 ? star.moveTo(p.dx, p.dy) : star.lineTo(p.dx, p.dy);
    }
    star.close();
    canvas.drawPath(star, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _MedalPainter old) => old.theme != theme;
}

/// Punto del carrusel de divisiones: actual destacada (anillo blanco + grande),
/// superiores atenuadas (aún no alcanzadas).
class _DivisionDot extends StatelessWidget {
  const _DivisionDot({required this.division, required this.current});
  final String division;
  final String current;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = DivisionTheme.of(division);
    final isCurrent = division == current;
    final idx = DivisionTheme.ladder.indexOf(division);
    final curIdx = DivisionTheme.ladder.indexOf(current);
    final future = idx > curIdx;
    final size = isCurrent ? 46.0 : 32.0;
    return Opacity(
      opacity: isCurrent ? 1 : (future ? 0.5 : 0.92),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [theme.start, theme.end]),
              shape: BoxShape.circle,
              border: isCurrent ? Border.all(color: Colors.white, width: 2.5) : null,
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                          color: theme.end.withValues(alpha: 0.55),
                          offset: const Offset(0, 4),
                          blurRadius: 10)
                    ]
                  : null,
            ),
            child: Icon(theme.icon, color: Colors.white, size: isCurrent ? 20 : 14),
          ),
          const SizedBox(height: 4),
          Text(
            divisionLabel(l10n, division).toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w900,
              color: isCurrent ? AppColors.gold : Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tablas (leaderboards: get_leaderboard) ──────────────────────────────────
class _LeaderboardView extends ConsumerStatefulWidget {
  const _LeaderboardView();
  @override
  ConsumerState<_LeaderboardView> createState() => _LeaderboardViewState();
}

// Métrica de leaderboard: clave técnica + si admite ventana (racha no). El label
// y el sufijo (unit) se resuelven por i18n en tiempo de build.
const _metricKeys = <(String, bool)>[
  ('xp', true),
  ('lessons', true),
  ('streak', false),
  ('certificates', true),
];
const _windowKeys = ['weekly', 'monthly', 'yearly', 'alltime'];

String _metricLabel(AppLocalizations l10n, String k) => switch (k) {
      'xp' => l10n.leaderboardMetricXp,
      'lessons' => l10n.leaderboardMetricLessons,
      'streak' => l10n.leaderboardMetricStreak,
      'certificates' => l10n.leaderboardMetricCertificates,
      _ => k,
    };
String _metricUnit(AppLocalizations l10n, String k) => switch (k) {
      'xp' => l10n.leaderboardMetricXp,
      'lessons' => l10n.leaderboardUnitLessons,
      'streak' => l10n.leaderboardUnitDays,
      'certificates' => l10n.leaderboardUnitCertificates,
      _ => '',
    };
String _windowLabel(AppLocalizations l10n, String k) => switch (k) {
      'weekly' => l10n.leaderboardWindowWeekly,
      'monthly' => l10n.leaderboardWindowMonthly,
      'yearly' => l10n.leaderboardWindowYearly,
      'alltime' => l10n.leaderboardWindowAlltime,
      _ => k,
    };

class _LeaderboardViewState extends ConsumerState<_LeaderboardView> {
  int _metric = 0;
  int _window = 0;
  int _scope = 0; // 0 global · 1 división

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final metricKey = _metricKeys[_metric].$1;
    final windowed = _metricKeys[_metric].$2;
    // La racha más larga no es por ventana: se fija a histórico.
    final windowKey = windowed ? _windowKeys[_window] : 'alltime';
    final scopeKey = _scope == 0 ? 'global' : 'division';
    final key = (metric: metricKey, window: windowKey, scope: scopeKey);
    final async = ref.watch(leaderboardProvider(key));

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(leaderboardProvider(key)),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 110),
        children: [
          _Segmented(
            options: [for (final m in _metricKeys) _metricLabel(l10n, m.$1)],
            selected: _metric,
            onChanged: (i) => setState(() => _metric = i),
          ),
          const SizedBox(height: 8),
          if (windowed)
            _Segmented(
              options: [for (final w in _windowKeys) _windowLabel(l10n, w)],
              selected: _window,
              onChanged: (i) => setState(() => _window = i),
              small: true,
            )
          else
            _Hint(l10n.leaderboardStreakHint),
          const SizedBox(height: 8),
          _Segmented(
            options: [l10n.leaderboardScopeGlobal, l10n.leaderboardScopeDivision],
            selected: _scope,
            onChanged: (i) => setState(() => _scope = i),
            small: true,
          ),
          const SizedBox(height: 14),
          async.when(
            loading: () => const JzListSkeleton(rows: 6, padding: EdgeInsets.symmetric(vertical: 4)),
            error: (e, _) => SizedBox(
              height: 220,
              child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.cloud_off_rounded, color: AppColors.textMuted, size: 36),
                  const SizedBox(height: 8),
                  Text(l10n.leaderboardLoadError,
                      style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textMuted)),
                  TextButton(onPressed: () => ref.invalidate(leaderboardProvider(key)), child: Text(l10n.commonRetry)),
                ]),
              ),
            ),
            data: (lb) => _LeaderboardBody(lb: lb, unit: _metricUnit(l10n, metricKey)),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardBody extends StatelessWidget {
  const _LeaderboardBody({required this.lb, required this.unit});
  final LeaderboardResult lb;
  final String unit;

  String _val(int v) => unit.isEmpty ? '$v' : '$v $unit';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (lb.entries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: AppColors.navActiveBg, borderRadius: BorderRadius.circular(18)),
        child: Text(l10n.leaderboardEmpty,
            style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textMuted)),
      );
    }
    return Column(
      children: [
        // Tu posición.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.primaryLight, AppColors.primary]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.person_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                    lb.myRank != null ? l10n.leaderboardMyPosition(lb.myRank!, lb.total) : l10n.leaderboardNotRanked,
                    style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 14)),
              ),
              Text(_val(lb.myValue),
                  style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 14)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 5), blurRadius: 0)],
          ),
          child: Column(
            children: [
              for (final e in lb.entries)
                _LbRow(rank: e.rank, name: e.name, valueLabel: _val(e.value), isMe: e.isMe),
            ],
          ),
        ),
        if (lb.total > lb.entries.length) ...[
          const SizedBox(height: 10),
          Text(l10n.leaderboardShowingTop(lb.entries.length, lb.total),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
        ],
      ],
    );
  }
}

// ─── Widgets compartidos ─────────────────────────────────────────────────────
class _Segmented extends StatelessWidget {
  const _Segmented({
    required this.options,
    required this.selected,
    required this.onChanged,
    this.small = false,
  });
  final List<String> options;
  final int selected;
  final ValueChanged<int> onChanged;
  final bool small;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: const Color(0xFFEDEFF7), borderRadius: BorderRadius.circular(13)),
      child: Row(
        children: [
          for (var i = 0; i < options.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: EdgeInsets.symmetric(vertical: small ? 7 : 9),
                  decoration: BoxDecoration(
                    color: i == selected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: i == selected
                        ? const [BoxShadow(color: Color(0x14000000), offset: Offset(0, 2), blurRadius: 5)]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    options[i],
                    style: TextStyle(
                      fontSize: small ? 12 : 13.5,
                      fontWeight: FontWeight.w900,
                      color: i == selected ? AppColors.primary : AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
      );
}

/// Fila simple de los leaderboards (tab Tablas): posición + nombre + métrica.
class _LbRow extends StatelessWidget {
  const _LbRow({
    required this.rank,
    required this.name,
    required this.valueLabel,
    required this.isMe,
  });
  final int rank;
  final String name;
  final String valueLabel;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final medal = rank == 1 ? '🥇' : rank == 2 ? '🥈' : rank == 3 ? '🥉' : null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: isMe ? AppColors.navActiveBg : Colors.transparent,
        border: const Border(bottom: BorderSide(color: Color(0xFFF0F1F8))),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: medal != null
                ? Text(medal, style: const TextStyle(fontSize: 18))
                : Text('$rank',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.textMuted)),
          ),
          const SizedBox(width: 12),
          Container(
            width: 34, height: 34, alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isMe ? AppColors.primary : const Color(0xFFEDEFF7),
              shape: BoxShape.circle,
            ),
            child: isMe
                ? const Icon(Icons.person_rounded, size: 18, color: Colors.white)
                : Text(name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textMuted)),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(name,
                style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: isMe ? FontWeight.w900 : FontWeight.w700,
                    color: isMe ? AppColors.primary : AppColors.text)),
          ),
          Text(valueLabel,
              style: const TextStyle(
                  fontSize: 13.5, fontWeight: FontWeight.w900, color: AppColors.text)),
        ],
      ),
    );
  }
}

/// Fila del ranking (Ligas.dc): tinte por zona, medallas top-3, avatar
/// coloreado por persona y tag de estado ("Sube"/"En riesgo"/"¡Mantente arriba!").
class _RankRow extends StatelessWidget {
  const _RankRow({
    required this.rank,
    required this.name,
    required this.xp,
    required this.isMe,
    this.promote = false,
    this.demote = false,
    this.onTap,
  });
  final int rank;
  final String name;
  final int xp;
  final bool isMe;
  final bool promote;
  final bool demote;

  /// Abre el perfil público al tocar (null = no tappable: soy yo / sin user_id).
  final VoidCallback? onTap;

  static const _avatarColors = [
    AppColors.primary,
    AppColors.coral,
    AppColors.success,
    AppColors.gold,
    Color(0xFF4A8CFF),
    AppColors.streak,
    Color(0xFF8C7DF2),
    Color(0xFF1ABC9C),
    Color(0xFFE0556E),
    Color(0xFF3FB0E0),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final medal = rank == 1
        ? const Color(0xFFFFC93C)
        : rank == 2
            ? const Color(0xFFC2CAD6)
            : rank == 3
                ? const Color(0xFFE0915A)
                : null;
    final avatarColor = _avatarColors[name.hashCode.abs() % _avatarColors.length];
    final tag = isMe
        ? l10n.leagueTagYou
        : promote
            ? l10n.leagueTagUp
            : demote
                ? l10n.leagueTagRisk
                : null;
    final tagColor =
        isMe ? AppColors.primary : (promote ? const Color(0xFF3CA86A) : const Color(0xFFE0556E));
    final row = Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: isMe
            ? AppColors.navActiveBg
            : promote
                ? const Color(0xFFF1FBF5)
                : demote
                    ? const Color(0xFFFFF5F6)
                    : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: isMe ? Border.all(color: AppColors.primary, width: 2) : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 26,
            child: medal != null
                ? Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: medal,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(color: Color(0x1F000000), offset: Offset(0, 2), blurRadius: 0)
                      ],
                    ),
                    child: Text('$rank',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white)),
                  )
                : Text('$rank',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: isMe
                            ? AppColors.primary
                            : promote
                                ? const Color(0xFF3CA86A)
                                : demote
                                    ? const Color(0xFFE0556E)
                                    : const Color(0xFF9AA0BC))),
          ),
          const SizedBox(width: 11),
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isMe ? AppColors.primary : avatarColor,
              borderRadius: BorderRadius.circular(13),
              boxShadow: const [
                BoxShadow(color: Color(0x1F000000), offset: Offset(0, 3), blurRadius: 0)
              ],
            ),
            child: isMe
                ? const Icon(Icons.person_rounded, size: 19, color: Colors.white)
                : Text(name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: isMe ? AppColors.primary : AppColors.text)),
                if (tag != null)
                  Text(tag,
                      style: TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w900, color: tagColor)),
              ],
            ),
          ),
          Text.rich(
            TextSpan(
              text: '$xp',
              style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w900,
                  color: isMe ? AppColors.primary : AppColors.text),
              children: const [
                TextSpan(
                    text: ' XP',
                    style: TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFFB0B4C8))),
              ],
            ),
          ),
          if (onTap != null && !isMe) ...[
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFFC2C7D6)),
          ],
        ],
      ),
    );
    if (onTap == null) return row;
    // Tocar la fila abre el perfil público (gateado 18+/bloqueo en el servidor).
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: row,
    );
  }
}
