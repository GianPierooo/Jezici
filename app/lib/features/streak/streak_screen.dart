import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ui/responsive_center.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/progress_models.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';

/// Pantalla de la RACHA (Estructura_App §8 + Diseno_Gamificacion §5):
/// contador grande, récord, hitos con recompensa y congelador de racha.
class StreakScreen extends ConsumerWidget {
  const StreakScreen({super.key});

  // Hito -> recompensa en oro (alineado con jz_register_activity en la BD).
  static const _milestones = <int, int>{7: 50, 30: 100, 100: 250, 365: 500};
  static const _freezeCost = 50;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final stats = ref.watch(homeStatsProvider).value ?? HomeStats.empty;

    // Próximo hito no alcanzado (según el récord).
    final next = _milestones.keys.firstWhere(
      (m) => stats.longestStreak < m,
      orElse: () => 365,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.text,
        title: Text(l10n.streakTitle,
            style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.text)),
      ),
      body: ResponsiveCenter(
        maxWidth: 560,
        child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero de la racha.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 26),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFB05A), AppColors.streak, Color(0xFFE8650A)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.streak.withValues(alpha: 0.4),
                    offset: const Offset(0, 10),
                    blurRadius: 22,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 56)),
                  Text('${stats.currentStreak}',
                      style: const TextStyle(
                          fontSize: 60, fontWeight: FontWeight.w900, color: Colors.white, height: 1)),
                  Text(l10n.streakDaysCount(stats.currentStreak),
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white.withValues(alpha: 0.92))),
                  const SizedBox(height: 6),
                  Text(l10n.streakRecord(stats.longestStreak),
                      style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.85))),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // T4 · RESCATE EXCEPCIONAL: revivir una racha recién perdida — CARO
            // y LIMITADO (server: precio config, 1 vez/30 días, ventana 7 días).
            // Solo aparece si HAY una racha revivible; perderla debe seguir doliendo.
            const _ReviveCard(),

            Text(l10n.streakMilestonesTitle,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.text)),
            const SizedBox(height: 4),
            Text(l10n.streakMilestonesSubtitle,
                style: const TextStyle(
                    fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 5), blurRadius: 0),
                ],
              ),
              child: Column(
                children: [
                  for (final m in _milestones.entries)
                    _MilestoneRow(
                      days: m.key,
                      reward: m.value,
                      reached: stats.longestStreak >= m.key,
                      isNext: m.key == next && stats.longestStreak < m.key,
                      current: stats.currentStreak,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Congelador de racha.
            Text(l10n.shopFreezeCardTitle,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.text)),
            const SizedBox(height: 4),
            Text(l10n.streakFreezeSubtitle,
                style: const TextStyle(
                    fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 5), blurRadius: 0),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F4FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text('🧊', style: TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.streakFreezeCount(stats.freezes),
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.text)),
                        Text(l10n.streakFreezePrice(_freezeCost),
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  _FreezeButton(canAfford: stats.gold >= _freezeCost),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _MilestoneRow extends StatelessWidget {
  const _MilestoneRow({
    required this.days,
    required this.reward,
    required this.reached,
    required this.isNext,
    required this.current,
  });
  final int days;
  final int reward;
  final bool reached;
  final bool isNext;
  final int current;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = reached ? AppColors.streak : (isNext ? AppColors.primary : AppColors.locked);
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: reached
            ? const Color(0xFFFFF3E6)
            : (isNext ? AppColors.navActiveBg : const Color(0xFFF7F8FC)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
            child: Icon(
              reached ? Icons.local_fire_department_rounded : Icons.lock_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.onbDaysShort(days),
                    style: const TextStyle(
                        fontSize: 14.5, fontWeight: FontWeight.w900, color: AppColors.text)),
                Text(
                  reached
                      ? l10n.streakMilestoneReached
                      : (isNext ? l10n.streakMilestoneNext(current, days) : l10n.streakMilestoneLocked),
                  style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: reached ? AppColors.successDark : AppColors.textMuted),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4D6),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on_rounded, color: AppColors.goldDark, size: 15),
                const SizedBox(width: 3),
                Text('+$reward',
                    style: const TextStyle(
                        fontSize: 12.5, fontWeight: FontWeight.w900, color: AppColors.goldDark)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FreezeButton extends ConsumerStatefulWidget {
  const _FreezeButton({required this.canAfford});
  final bool canAfford;

  @override
  ConsumerState<_FreezeButton> createState() => _FreezeButtonState();
}

class _FreezeButtonState extends ConsumerState<_FreezeButton> {
  bool _busy = false;

  Future<void> _buy() async {
    if (_busy) return;
    setState(() => _busy = true);
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final res = await ref.read(progressRepositoryProvider).useStreakFreeze();
      ref.invalidate(homeStatsProvider);
      final ok = res['ok'] == true;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: ok ? AppColors.success : AppColors.coral,
          content: Text(ok
              ? l10n.shopFreezeBought((res['gold'] as num?)?.toInt() ?? 0)
              : l10n.shopNotEnoughGold(50)),
        ));
    } catch (_) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(l10n.authErrorGeneral),
        ));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ElevatedButton(
      onPressed: (_busy || !widget.canAfford) ? null : _buy,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        disabledBackgroundColor: AppColors.locked,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      ),
      child: _busy
          ? const SizedBox(
              width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : Text(l10n.streakFreezeBuy, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
    );
  }
}

/// T4 · Tarjeta de RESCATE de racha (revive_streak, mig 151): aparece SOLO si
/// hay una racha revivible (perdida hace poco, dentro de la ventana y sin usar
/// el rescate del periodo). Caro y limitado a propósito — es una excepción,
/// no una rutina; el CONGELADOR preventivo sigue siendo el camino barato.
class _ReviveCard extends ConsumerStatefulWidget {
  const _ReviveCard();
  @override
  ConsumerState<_ReviveCard> createState() => _ReviveCardState();
}

class _ReviveCardState extends ConsumerState<_ReviveCard> {
  Map<String, dynamic>? _status;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final s = await ref.read(progressRepositoryProvider).streakReviveStatus();
      if (mounted) setState(() => _status = s);
    } catch (_) {}
  }

  Future<void> _revive() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final l10n = AppLocalizations.of(context);
    try {
      final r = await ref.read(progressRepositoryProvider).reviveStreak();
      if (!mounted) return;
      if (r['ok'] == true) {
        ref.invalidate(homeStatsProvider);
        setState(() {
          _status = null; // la tarjeta desaparece: rescate consumido
          _busy = false;
        });
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(l10n.streakRevived((r['streak'] as num?)?.toInt() ?? 0))));
      } else {
        setState(() {
          _busy = false;
          _error = r['reason'] == 'insufficient_gold'
              ? l10n.noHeartsInsufficientGold
              : l10n.streakReviveUnavailable;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = l10n.streakReviveUnavailable;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final s = _status;
    if (s == null || s['available'] != true) return const SizedBox.shrink();
    final lost = (s['lost_streak'] as num?)?.toInt() ?? 0;
    final cost = (s['cost'] as num?)?.toInt() ?? 300;
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2D2A4A), Color(0xFF1C1B2E)]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Color(0x66191141), offset: Offset(0, 8), blurRadius: 20),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Text('🕯️', style: TextStyle(fontSize: 26)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l10n.streakReviveTitle(lost),
                      style: const TextStyle(
                          fontSize: 15.5, fontWeight: FontWeight.w900, color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(l10n.streakReviveSubtitle,
                      style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.75))),
                ]),
              ),
            ]),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFFF8585))),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _busy ? null : _revive,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFF4B400),
                  foregroundColor: const Color(0xFF5B3A00),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2.2, color: Color(0xFF5B3A00)))
                    : Text('${l10n.streakReviveCta}  ·  🪙 $cost',
                        style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900)),
              ),
            ),
            const SizedBox(height: 6),
            Text(l10n.streakReviveLimit,
                style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.55))),
          ],
        ),
      ),
    );
  }
}
