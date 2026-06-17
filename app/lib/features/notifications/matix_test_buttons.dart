import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import 'matix_banner.dart';
import 'matix_service.dart';

/// Botones para SIMULAR un trigger de Matix (Fase 1: el scheduler real —
/// cron de meta sin cumplir / racha en riesgo — llega en la siguiente
/// iteración). Disparan el motor server-side y muestran el copy elegido.
class MatixTestButtons extends ConsumerStatefulWidget {
  const MatixTestButtons({super.key});

  @override
  ConsumerState<MatixTestButtons> createState() => _MatixTestButtonsState();
}

class _MatixTestButtonsState extends ConsumerState<MatixTestButtons> {
  String? _busy;

  static const _triggers = <_Trig>[
    _Trig('goal_unmet', 'Meta sin cumplir', Icons.flag_rounded),
    _Trig('streak_risk', 'Racha en riesgo', Icons.local_fire_department_rounded),
    _Trig('achievement', 'Logro desbloqueado', Icons.emoji_events_rounded),
  ];

  Future<void> _fire(String trigger) async {
    setState(() => _busy = trigger);
    try {
      final res = await ref.read(matixServiceProvider).fire(trigger);
      if (mounted) showMatixBanner(context, res);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('No se pudo disparar la notificación.'),
          ));
      }
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final t in _triggers) ...[
          _TriggerButton(
            label: t.label,
            icon: t.icon,
            busy: _busy == t.key,
            onTap: _busy == null ? () => _fire(t.key) : null,
          ),
          if (t != _triggers.last) const SizedBox(height: 9),
        ],
      ],
    );
  }
}

class _Trig {
  const _Trig(this.key, this.label, this.icon);
  final String key;
  final String label;
  final IconData icon;
}

class _TriggerButton extends StatelessWidget {
  const _TriggerButton({required this.label, required this.icon, required this.busy, this.onTap});
  final String label;
  final IconData icon;
  final bool busy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.navActiveBg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 11),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 13.5, fontWeight: FontWeight.w900, color: AppColors.primary)),
            ),
            if (busy)
              const SizedBox(
                  width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
            else
              const Icon(Icons.notifications_active_rounded, color: AppColors.primary, size: 18),
          ],
        ),
      ),
    );
  }
}
