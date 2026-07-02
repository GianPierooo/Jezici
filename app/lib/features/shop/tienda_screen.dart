import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/shop_models.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';

/// Tienda: gasto de oro (recargar vidas, congelar racha) + cofre diario de
/// recompensa variable. Todo el saldo lo mueve el servidor.
class TiendaScreen extends ConsumerStatefulWidget {
  const TiendaScreen({super.key});
  @override
  ConsumerState<TiendaScreen> createState() => _TiendaScreenState();
}

class _TiendaScreenState extends ConsumerState<TiendaScreen> {
  final ConfettiController _confetti = ConfettiController(duration: const Duration(seconds: 2));
  String? _busy;

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  void _refresh() {
    ref.invalidate(shopStatusProvider);
    ref.invalidate(homeStatsProvider);
  }

  void _toast(String msg, {bool ok = true}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ok ? AppColors.success : AppColors.coral,
        content: Text(msg),
      ));
  }

  Future<void> _chest() async {
    if (_busy != null) return; // guard anti doble-tap (race del cofre)
    setState(() => _busy = 'chest');
    final l10n = AppLocalizations.of(context);
    try {
      final r = await ref.read(progressRepositoryProvider).openDailyChest();
      if (r['ok'] == true) {
        _confetti.play();
        final reward = (r['reward'] as num?)?.toInt() ?? 0;
        final total = (r['gold'] as num?)?.toInt() ?? 0;
        _toast(l10n.shopChestWon(reward, total));
      } else {
        _toast(l10n.shopChestAlready, ok: false);
      }
      _refresh();
    } catch (_) {
      _toast(l10n.authErrorGeneral, ok: false);
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  Future<void> _hearts() async {
    if (_busy != null) return;
    setState(() => _busy = 'hearts');
    final l10n = AppLocalizations.of(context);
    try {
      final r = await ref.read(progressRepositoryProvider).buyHearts();
      if (r['ok'] == true) {
        _toast(l10n.shopHeartsRefilled((r['gold'] as num?)?.toInt() ?? 0));
      } else {
        _toast(l10n.shopNotEnoughGold(50), ok: false);
      }
      _refresh();
    } catch (_) {
      _toast(l10n.authErrorGeneral, ok: false);
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  Future<void> _freeze() async {
    if (_busy != null) return;
    setState(() => _busy = 'freeze');
    final l10n = AppLocalizations.of(context);
    try {
      final r = await ref.read(progressRepositoryProvider).useStreakFreeze();
      if (r['ok'] == true) {
        _toast(l10n.shopFreezeBought((r['gold'] as num?)?.toInt() ?? 0));
      } else {
        _toast(l10n.shopNotEnoughGold(50), ok: false);
      }
      _refresh();
    } catch (_) {
      _toast(l10n.authErrorGeneral, ok: false);
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(shopStatusProvider).value ?? ShopStatus.empty;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.text,
        title: const Text('Tienda', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 14),
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFFFFF4D6), borderRadius: BorderRadius.circular(12)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.monetization_on_rounded, color: AppColors.goldDark, size: 18),
                const SizedBox(width: 4),
                Text('${s.gold}', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.goldDark)),
              ]),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              _ShopCard(
                emoji: '🎁',
                title: 'Cofre diario',
                subtitle: s.chestAvailable ? 'Ábrelo para una recompensa sorpresa' : 'Ya lo abriste hoy · vuelve mañana',
                actionLabel: s.chestAvailable ? 'ABRIR' : 'MAÑANA',
                enabled: s.chestAvailable,
                busy: _busy == 'chest',
                color: AppColors.gold,
                onTap: _chest,
              ),
              _ShopCard(
                emoji: '❤️',
                title: 'Recargar vidas',
                subtitle: 'Vuelve a 5 corazones · tienes ${s.hearts}',
                actionLabel: '50',
                enabled: s.hearts < 5 && s.gold >= 50,
                busy: _busy == 'hearts',
                color: AppColors.hearts,
                onTap: _hearts,
              ),
              _ShopCard(
                emoji: '🧊',
                title: 'Congelador de racha',
                subtitle: 'Protege tu racha un día · tienes ${s.freezes}',
                actionLabel: '50',
                enabled: s.gold >= 50,
                busy: _busy == 'freeze',
                color: AppColors.primary,
                onTap: _freeze,
              ),
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 14,
              gravity: 0.3,
              colors: const [AppColors.gold, AppColors.coral, AppColors.success, AppColors.primary],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShopCard extends StatelessWidget {
  const _ShopCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.enabled,
    required this.busy,
    required this.color,
    required this.onTap,
  });
  final String emoji;
  final String title;
  final String subtitle;
  final String actionLabel;
  final bool enabled;
  final bool busy;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final coin = actionLabel == '50';
    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 5), blurRadius: 0)],
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50, alignment: Alignment.center,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(15)),
            child: Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w900, color: AppColors.text)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
            ]),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: (enabled && !busy) ? onTap : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: color, disabledBackgroundColor: AppColors.locked, foregroundColor: Colors.white,
              elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
            ),
            child: busy
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Row(mainAxisSize: MainAxisSize.min, children: [
                    if (coin) const Icon(Icons.monetization_on_rounded, size: 15, color: Colors.white),
                    if (coin) const SizedBox(width: 3),
                    Text(actionLabel, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                  ]),
          ),
        ],
      ),
    );
  }
}
