import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/progress_models.dart';
import '../../../data/providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../lesson/widgets/no_hearts_sheet.dart' show kHeartRefillCost, formatCountdown;
import '../../shop/tienda_screen.dart';

/// Paneles de la BARRA SUPERIOR (bottom-sheets): cada stat es tappable y abre un
/// panel con info REAL + acción real. Reutilizan la economía existente (buy_hearts,
/// tienda) — cero lógica nueva de servidor. Lenguaje visual del mockup + motion sutil.

Future<void> showHeartsPanel(BuildContext context) => _show(context, const _HeartsPanel());
Future<void> showGoldPanel(BuildContext context) => _show(context, const _GoldPanel());
Future<void> showDailyGoalPanel(BuildContext context) => _show(context, const _DailyGoalPanel());

Future<void> _show(BuildContext context, Widget child) => showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => child,
    );

/// Chrome común: hoja blanca r30, asa, entrada del icono con leve escala.
class _PanelShell extends StatelessWidget {
  const _PanelShell({required this.icon, required this.iconColor, required this.children});
  final IconData icon;
  final Color iconColor;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.of(context).disableAnimations;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: EdgeInsets.fromLTRB(24, 14, 24, 26 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 5,
            decoration: BoxDecoration(
                color: const Color(0xFFE4E6EE), borderRadius: BorderRadius.circular(3)),
          ),
          const SizedBox(height: 18),
          TweenAnimationBuilder<double>(
            duration: reduce ? Duration.zero : const Duration(milliseconds: 320),
            curve: Curves.easeOutBack,
            tween: Tween(begin: reduce ? 1 : 0.6, end: 1),
            builder: (_, s, child) => Transform.scale(scale: s, child: child),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 30),
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _PanelTitle extends StatelessWidget {
  const _PanelTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: AppColors.text));
}

class _PanelBody extends StatelessWidget {
  const _PanelBody(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(text,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textMuted, height: 1.4)),
      );
}

/// Botón "jugoso" con labio 3D (mockup) para el CTA de los paneles.
class _PanelButton extends StatelessWidget {
  const _PanelButton({
    required this.label,
    required this.color,
    required this.depth,
    required this.onTap,
    this.icon,
    this.busy = false,
  });
  final String label;
  final Color color;
  final Color depth;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null && !busy;
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: depth, offset: const Offset(0, 5), blurRadius: 0)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (busy)
                const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
              else ...[
                if (icon != null) ...[Icon(icon, color: Colors.white, size: 20), const SizedBox(width: 8)],
                Text(label,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── ❤️ VIDAS ─────────────────────────────────────────────────────────────────
class _HeartsPanel extends ConsumerStatefulWidget {
  const _HeartsPanel();
  @override
  ConsumerState<_HeartsPanel> createState() => _HeartsPanelState();
}

class _HeartsPanelState extends ConsumerState<_HeartsPanel> {
  bool _busy = false;
  String? _error;
  int? _hearts; // estado REAL del server (con regen lazy, mig 151)
  int? _secondsToNext;
  int _cost = kHeartRefillCost;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _loadHearts();
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  Future<void> _loadHearts() async {
    try {
      final h = await ref.read(progressRepositoryProvider).getHearts();
      if (!mounted) return;
      setState(() {
        _hearts = (h['hearts'] as num?)?.toInt();
        _secondsToNext = (h['seconds_to_next'] as num?)?.toInt();
        _cost = (h['refill_cost'] as num?)?.toInt() ?? kHeartRefillCost;
      });
      ref.invalidate(homeStatsProvider); // el tick pudo regenerar vidas
      _tick?.cancel();
      if (_secondsToNext != null) {
        _tick = Timer.periodic(const Duration(seconds: 1), (_) {
          if (!mounted) return;
          final s = _secondsToNext;
          if (s == null || s <= 1) {
            _loadHearts();
          } else {
            setState(() => _secondsToNext = s - 1);
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _refill() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final l10n = AppLocalizations.of(context);
    try {
      final res = await ref.read(progressRepositoryProvider).buyHearts();
      if (!mounted) return;
      if (res['ok'] == true) {
        ref.invalidate(homeStatsProvider);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
              behavior: SnackBarBehavior.floating, content: Text(l10n.noHeartsRefilled)));
      } else {
        setState(() {
          _busy = false;
          _error = l10n.noHeartsInsufficientGold;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = l10n.noHeartsInsufficientGold;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final stats = ref.watch(homeStatsProvider).value ?? HomeStats.empty;
    final hearts = (_hearts ?? stats.hearts).clamp(0, 5);
    final full = hearts >= 5;
    final s = _secondsToNext;
    return _PanelShell(
      icon: Icons.favorite_rounded,
      iconColor: AppColors.hearts,
      children: [
        _PanelTitle(l10n.heartsPanelTitle),
        const SizedBox(height: 10),
        // Fila de 5 corazones (llenos = vidas actuales, con regen del server).
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            5,
            (i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Icon(i < hearts ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: i < hearts ? AppColors.hearts : const Color(0xFFE2E5F0), size: 28),
            ),
          ),
        ),
        const SizedBox(height: 14),
        // Countdown REAL de la próxima vida (regen server-side, mig 151).
        if (!full && s != null)
          _PanelBody(l10n.heartsPanelNextIn(formatCountdown(s)))
        else
          _PanelBody(full ? l10n.heartsPanelFull : l10n.heartsPanelRegen),
        if (_error != null) ...[
          const SizedBox(height: 12),
          _ErrorPill(_error!),
        ],
        const SizedBox(height: 18),
        if (!full)
          _PanelButton(
            label: l10n.noHeartsRefillPriced(_cost),
            icon: Icons.favorite_rounded,
            color: AppColors.primary,
            depth: AppColors.primaryDark,
            busy: _busy,
            onTap: _refill,
          ),
      ],
    );
  }
}

// ── 🪙 ORO ───────────────────────────────────────────────────────────────────
class _GoldPanel extends ConsumerWidget {
  const _GoldPanel();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final stats = ref.watch(homeStatsProvider).value ?? HomeStats.empty;
    return _PanelShell(
      icon: Icons.monetization_on_rounded,
      iconColor: AppColors.goldDark,
      children: [
        _PanelTitle(l10n.goldPanelTitle),
        const SizedBox(height: 6),
        Text('🪙 ${stats.gold}',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.goldDark)),
        const SizedBox(height: 12),
        _PanelBody(l10n.goldPanelWhat),
        const SizedBox(height: 18),
        _PanelButton(
          label: l10n.goldPanelOpenShop,
          icon: Icons.storefront_rounded,
          color: AppColors.primary,
          depth: AppColors.primaryDark,
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const TiendaScreen()));
          },
        ),
      ],
    );
  }
}

// ── ⚡ META DIARIA ────────────────────────────────────────────────────────────
class _DailyGoalPanel extends ConsumerWidget {
  const _DailyGoalPanel();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final stats = ref.watch(homeStatsProvider).value ?? HomeStats.empty;
    final met = stats.dailyGoalMet;
    final color = met ? AppColors.success : AppColors.primary;
    return _PanelShell(
      icon: met ? Icons.check_rounded : Icons.bolt_rounded,
      iconColor: color,
      children: [
        _PanelTitle(l10n.dailyPanelTitle),
        const SizedBox(height: 10),
        // Anillo grande de progreso + X/Y.
        SizedBox(
          width: 96,
          height: 96,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 96,
                height: 96,
                child: CircularProgressIndicator(
                  value: stats.dailyProgress.clamp(0.0, 1.0),
                  strokeWidth: 8,
                  backgroundColor: const Color(0xFFE2DEF8),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${stats.dailyXpEarned}/${stats.dailyGoalXp}',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
                  const Text('XP',
                      style: TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textMuted)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _PanelBody(met ? l10n.dailyPanelDone : l10n.dailyPanelWhat),
        const SizedBox(height: 18),
        _PanelButton(
          label: l10n.dailyPanelClose,
          color: color,
          depth: met ? AppColors.successDark : AppColors.primaryDark,
          onTap: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

class _ErrorPill extends StatelessWidget {
  const _ErrorPill(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.coral.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.coral, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.coral)),
          ),
        ],
      ),
    );
  }
}
