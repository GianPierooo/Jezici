import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/progress_models.dart';
import '../../../data/providers.dart';
import '../../../ui/stat_chip.dart';
import '../../notifications/notification_center_screen.dart';
import '../../plan/mi_plan_screen.dart';
import '../../shop/tienda_screen.dart';
import '../../streak/streak_screen.dart';

/// Top bar minimal de "Aprender" (Estructura_App §1, §3): idioma activo · racha ·
/// oro · vidas · mini anillo de meta diaria. Lee datos REALES (paso E).
class LearnTopBar extends ConsumerWidget {
  const LearnTopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(homeStatsProvider).value ?? HomeStats.empty;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF28326E).withValues(alpha: 0.14),
            offset: const Offset(0, 6),
            blurRadius: 18,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F5FB),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🇬🇧', style: TextStyle(fontSize: 16)),
                SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down_rounded,
                    size: 16, color: AppColors.navInactive),
              ],
            ),
          ),
          Row(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const StreakScreen())),
                child: StreakIndicator(days: stats.currentStreak),
              ),
              const SizedBox(width: 13),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TiendaScreen())),
                child: GoldCounter(amount: stats.gold),
              ),
              const SizedBox(width: 13),
              HeartsIndicator(hearts: stats.hearts),
              const SizedBox(width: 10),
              Semantics(
                button: true,
                label: 'Meta diaria',
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const StreakScreen())),
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: Center(child: _DailyGoalRing(value: stats.dailyProgress)),
                  ),
                ),
              ),
              _BellButton(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const NotificationCenterScreen())),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Barra de PROGRESO DEL PLAN persistente (GA9·C): "Plan A1→B2 · X% · llegas el…".
/// Sensación de avance siempre visible. Toca para abrir el dashboard.
class PlanProgressStrip extends ConsumerWidget {
  const PlanProgressStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tAsync = ref.watch(planTrackingProvider);
    final t = tAsync.value;
    // Durante la carga inicial mostramos un placeholder de la MISMA altura para
    // evitar el salto de layout cuando la barra aparece. Si ya cargó y no hay
    // plan válido, la ocultamos del todo.
    if (t == null) {
      return tAsync.isLoading ? const _PlanStripPlaceholder() : const SizedBox.shrink();
    }
    if (!t.ok) return const SizedBox.shrink();
    final pct = (t.progress * 100).round();
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const MiPlanScreen())),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 7, 12, 0),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.86),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF28326E).withValues(alpha: 0.12),
                offset: const Offset(0, 5), blurRadius: 14),
          ],
        ),
        child: Row(
          children: [
            Icon(t.aheadBehind >= 0 ? Icons.flag_rounded : Icons.flag_outlined,
                size: 16, color: AppColors.primary),
            const SizedBox(width: 7),
            Text('${t.currentLevel}→${t.goalLevel}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.primary)),
            const SizedBox(width: 9),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: t.progress.clamp(0.0, 1.0),
                  minHeight: 7,
                  backgroundColor: const Color(0xFFE2DEF8),
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
            ),
            const SizedBox(width: 9),
            Text('$pct%',
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: AppColors.text)),
            const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _BellButton extends StatelessWidget {
  const _BellButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Área táctil 44×44 (a11y) con la caja visible compacta centrada.
    return Semantics(
      button: true,
      label: 'Notificaciones',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: const SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: _BellGlyph(),
          ),
        ),
      ),
    );
  }
}

class _BellGlyph extends StatelessWidget {
  const _BellGlyph();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5FB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.notifications_rounded, size: 18, color: AppColors.primary),
    );
  }
}

class _DailyGoalRing extends StatelessWidget {
  const _DailyGoalRing({required this.value});
  final double value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              value: value.clamp(0.0, 1.0),
              strokeWidth: 4,
              backgroundColor: const Color(0xFFE2DEF8),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const Icon(Icons.bolt_rounded, size: 14, color: AppColors.primary),
        ],
      ),
    );
  }
}

/// Placeholder de la barra de plan mientras carga: misma altura/forma para que
/// no haya salto de layout cuando aparezcan los datos reales.
class _PlanStripPlaceholder extends StatelessWidget {
  const _PlanStripPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 7, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16, height: 16),
          const SizedBox(width: 7),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: const LinearProgressIndicator(
                minHeight: 7,
                backgroundColor: Color(0xFFE9E7F6),
                valueColor: AlwaysStoppedAnimation(Color(0xFFE2DEF8)),
                value: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
