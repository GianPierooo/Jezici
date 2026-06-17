import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/league_models.dart';
import '../../data/providers.dart';

/// Pestaña LIGAS (Diseno_Gamificacion §ligas): liga semanal por XP, divisiones
/// Bronce→Diamante, con zona de ascenso (top 5) y descenso (bottom 5). El XP
/// semanal lo acumula el servidor. GA6: SOLO jugadores reales — sin bots; con
/// baja población muestra un estado "arrancando" en vez de fabricar rivales.
class LeaguesScreen extends ConsumerWidget {
  const LeaguesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(leagueProvider);
    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () async => ref.invalidate(leagueProvider),
        child: async.when(
          loading: () => const _Center(child: CircularProgressIndicator(color: AppColors.primary)),
          error: (e, _) => _Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.cloud_off_rounded, color: AppColors.textMuted, size: 40),
              const SizedBox(height: 10),
              const Text('No se pudo cargar la liga.',
                  style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textMuted)),
              TextButton(onPressed: () => ref.invalidate(leagueProvider), child: const Text('Reintentar')),
            ]),
          ),
          data: (lg) => _Board(lg: lg),
        ),
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

class _Board extends StatelessWidget {
  const _Board({required this.lg});
  final LeagueStanding lg;

  @override
  Widget build(BuildContext context) {
    final n = lg.members.length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
      children: [
        // Cabecera de división.
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
              const Text('🏆', style: TextStyle(fontSize: 40)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Liga ${lg.divisionLabel}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
                    const SizedBox(height: 2),
                    Text(
                        lg.warmingUp
                            ? '${lg.players} ${lg.players == 1 ? 'jugador' : 'jugadores'} · arrancando'
                            : 'Vas #${lg.myRank} esta semana · top ${lg.promote} ascienden',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.92))),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (lg.warmingUp) ...[
          // Baja población: estado honesto "arrancando" (sin bots).
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.navActiveBg,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Text('🌱', style: TextStyle(fontSize: 30)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tu liga está arrancando',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.text)),
                      const SizedBox(height: 2),
                      Text(
                          'Cuando haya al menos ${lg.minPlayers} jugadores activos, competiréis por ascender. '
                          'Mientras, suma XP: tu progreso ya cuenta.',
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        const Text('Clasificación de la semana',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.text)),
        const SizedBox(height: 4),
        const Text('Suma XP (lecciones y práctica) para subir. Reset cada lunes.',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
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
                if (!lg.warmingUp && i == lg.promote)
                  const _ZoneDivider(label: 'ZONA DE ASCENSO ↑', color: AppColors.success),
                if (!lg.warmingUp && i == n - lg.demote)
                  const _ZoneDivider(label: 'ZONA DE DESCENSO ↓', color: AppColors.coral),
                _Row(
                  m: lg.members[i],
                  promote: !lg.warmingUp && lg.members[i].rank <= lg.promote,
                  demote: !lg.warmingUp && lg.members[i].rank > n - lg.demote,
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
  const _ZoneDivider({required this.label, required this.color});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      color: color.withValues(alpha: 0.10),
      child: Text(label,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.6, color: color)),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.m, required this.promote, required this.demote});
  final LeagueMember m;
  final bool promote;
  final bool demote;

  @override
  Widget build(BuildContext context) {
    final medal = m.rank == 1 ? '🥇' : m.rank == 2 ? '🥈' : m.rank == 3 ? '🥉' : null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: m.isMe ? AppColors.navActiveBg : Colors.transparent,
        border: const Border(bottom: BorderSide(color: Color(0xFFF0F1F8))),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: medal != null
                ? Text(medal, style: const TextStyle(fontSize: 18))
                : Text('${m.rank}',
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
              color: m.isMe ? AppColors.primary : const Color(0xFFEDEFF7),
              shape: BoxShape.circle,
            ),
            child: m.isMe
                ? const Text('🦜', style: TextStyle(fontSize: 16))
                : Text(
                    m.name.isNotEmpty ? m.name.substring(0, 1).toUpperCase() : '?',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textMuted)),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(m.name,
                style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: m.isMe ? FontWeight.w900 : FontWeight.w700,
                    color: m.isMe ? AppColors.primary : AppColors.text)),
          ),
          Text('${m.weeklyXp} XP',
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: AppColors.text)),
        ],
      ),
    );
  }
}
