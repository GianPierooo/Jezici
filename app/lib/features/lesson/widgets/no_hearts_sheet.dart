import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/providers.dart';
import '../../../l10n/app_localizations.dart';

/// Resultado de la hoja "sin vidas".
enum NoHeartsChoice { refill, quit }

/// Costo de recargar las 5 vidas — MISMA economía que la tienda (buy_hearts,
/// mig 026). El servidor es la autoridad: cobra y bloquea si no hay oro.
const int kHeartRefillCost = 50;

/// Hoja "te quedaste sin vidas" (mockup SinVidas). La recarga **cobra oro de
/// verdad** (RPC buy_hearts, server-side): descuenta [kHeartRefillCost], y si no
/// hay oro suficiente NO recarga (aviso inline). Devuelve `refill` SOLO si la
/// compra tuvo éxito.
Future<NoHeartsChoice?> showNoHeartsSheet(BuildContext context) {
  return showModalBottomSheet<NoHeartsChoice>(
    context: context,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    builder: (context) => const _NoHeartsSheet(),
  );
}

class _NoHeartsSheet extends ConsumerStatefulWidget {
  const _NoHeartsSheet();

  @override
  ConsumerState<_NoHeartsSheet> createState() => _NoHeartsSheetState();
}

class _NoHeartsSheetState extends ConsumerState<_NoHeartsSheet> {
  bool _busy = false;
  String? _error;

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
        // El oro cambió → refresca el top bar.
        ref.invalidate(homeStatsProvider);
        Navigator.of(context).pop(NoHeartsChoice.refill);
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
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFE4E6EE),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 16),
          // Corazones vacíos.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (_) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 3),
                child: Icon(Icons.favorite_border_rounded,
                    color: Color(0xFFE2E5F0), size: 26),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            l10n.noHeartsTitle,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.text),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.noHeartsMsg,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
              height: 1.4,
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Container(
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
                    child: Text(_error!,
                        style: const TextStyle(
                            fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.coral)),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: _SheetButton(
              icon: Icons.favorite_rounded,
              // Precio REAL (cobra oro server-side); coherente con lo que hace.
              label: l10n.noHeartsRefillPriced(kHeartRefillCost),
              color: AppColors.primary,
              busy: _busy,
              onTap: _refill,
            ),
          ),
          const SizedBox(height: 11),
          TextButton(
            onPressed: _busy ? null : () => Navigator.of(context).pop(NoHeartsChoice.quit),
            child: Text(
              l10n.noHeartsQuit,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: AppColors.textMuted,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  const _SheetButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.busy = false,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: busy ? null : onTap,
      child: Opacity(
        opacity: busy ? 0.6 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(color: AppColors.primaryDark, offset: Offset(0, 5), blurRadius: 0),
            ],
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
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
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
