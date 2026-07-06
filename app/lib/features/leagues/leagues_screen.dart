import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/ui/jz_skeleton.dart';
import '../../core/ui/responsive_center.dart';
import '../../data/models/league_models.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/division_names.dart';

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final members = lg.members.where((m) => !m.isBot).toList();
    final n = members.length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFFCD9B6A), Color(0xFFB07B45)],
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [BoxShadow(color: const Color(0xFFB07B45).withValues(alpha: 0.4), offset: const Offset(0, 8), blurRadius: 18)],
          ),
          child: Row(
            children: [
              const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 38),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.leagueTitle(divisionLabel(l10n, lg.division)),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
                    const SizedBox(height: 2),
                    Text(
                        lg.warmingUp
                            ? l10n.leagueWarmingUpSubtitle(lg.players)
                            : lg.movementActive
                                ? l10n.leagueRankActive(lg.myRank, lg.promote)
                                : l10n.leagueRankInactive(lg.myRank),
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.92))),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (lg.warmingUp) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.navActiveBg, borderRadius: BorderRadius.circular(18)),
            child: Row(
              children: [
                const Icon(Icons.eco_rounded, color: AppColors.success, size: 26),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.leagueWarmingUpTitle,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.text)),
                      const SizedBox(height: 2),
                      Text(
                          l10n.leagueWarmingUpMessage(lg.minPlayers),
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
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
            decoration: BoxDecoration(color: AppColors.navActiveBg, borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                const Icon(Icons.trending_up_rounded, color: AppColors.primary, size: 22),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(AppLocalizations.of(context).leagueNoMovementNote,
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.text)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        Text(l10n.leagueWeeklyRankingTitle,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.text)),
        const SizedBox(height: 4),
        Text(l10n.leagueWeeklyRankingHint,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 5), blurRadius: 0)],
          ),
          child: Column(
            children: [
              for (var i = 0; i < n; i++) ...[
                if (lg.movementActive && i == lg.promote)
                  _ZoneDivider(label: l10n.leaguePromotionZone, icon: Icons.arrow_upward_rounded, color: AppColors.success),
                if (lg.movementActive && i == n - lg.demote)
                  _ZoneDivider(label: l10n.leagueDemotionZone, icon: Icons.arrow_downward_rounded, color: AppColors.coral),
                _Row(
                  rank: members[i].rank,
                  name: members[i].name,
                  valueLabel: '${members[i].weeklyXp} XP',
                  isMe: members[i].isMe,
                  promote: lg.movementActive && i < lg.promote,
                  demote: lg.movementActive && i >= n - lg.demote,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ZoneDivider extends StatelessWidget {
  const _ZoneDivider({required this.label, required this.icon, required this.color});
  final String label;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      color: color.withValues(alpha: 0.10),
      child: Row(children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.6, color: color)),
      ]),
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
                _Row(rank: e.rank, name: e.name, valueLabel: _val(e.value), isMe: e.isMe),
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

class _Row extends StatelessWidget {
  const _Row({
    required this.rank,
    required this.name,
    required this.valueLabel,
    required this.isMe,
    this.promote = false,
    this.demote = false,
  });
  final int rank;
  final String name;
  final String valueLabel;
  final bool isMe;
  final bool promote;
  final bool demote;

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
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: promote ? AppColors.successDark : (demote ? AppColors.coralDark : AppColors.textMuted))),
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
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textMuted)),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(name,
                style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: isMe ? FontWeight.w900 : FontWeight.w700,
                    color: isMe ? AppColors.primary : AppColors.text)),
          ),
          Text(valueLabel, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: AppColors.text)),
        ],
      ),
    );
  }
}
