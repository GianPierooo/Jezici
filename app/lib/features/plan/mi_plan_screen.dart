import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ui/responsive_center.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/progress_models.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/primary_button.dart';

/// "Mi Plan" — dashboard de seguimiento (GA4 · B2, diferenciador):
/// fecha de llegada recalculada con el ritmo real, "vas X días adelante/atrás",
/// progreso del plan y la palanca "llegar más rápido". Todo server-side.
class MiPlanScreen extends ConsumerWidget {
  const MiPlanScreen({super.key});

  /// Fecha en el formato del idioma de la app (no hardcodeado en español).
  static String fmtDate(BuildContext context, DateTime d) =>
      MaterialLocalizations.of(context).formatMediumDate(d);

  /// Texto de enfoque por MOTIVO del plan, localizado (reusa las claves planFocus*
  /// del onboarding/perfil). La clave (t.motive) es un valor del servidor en español;
  /// solo el TEXTO mostrado se traduce. null si no hay motivo reconocido.
  static String? focusText(AppLocalizations l10n, String? motive) {
    switch (motive) {
      case 'Trabajo':
        return '💼 ${l10n.planFocusWork}';
      case 'Viajes':
        return '✈️ ${l10n.planFocusTravel}';
      case 'Examen':
        return '🎓 ${l10n.planFocusExam}';
      case 'Estudios':
        return '📚 ${l10n.planFocusStudies}';
      case 'Mudanza':
        return '🏠 ${l10n.planFocusRelocation}';
      case 'Placer':
        return '🎬 ${l10n.planFocusCulture}';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(planTrackingProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background, elevation: 0, foregroundColor: AppColors.text,
        title: Text(l10n.miplanTitle, style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('${l10n.miplanLoadError}\n$e',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textMuted)),
          ),
        ),
        data: (t) => !t.ok
            ? Center(child: Text(l10n.miplanNoPlan))
            : _body(context, ref, t),
      ),
    );
  }

  Widget _body(BuildContext context, WidgetRef ref, PlanTracking t) {
    final l10n = AppLocalizations.of(context);
    final ahead = t.aheadBehind;
    final aheadColor = ahead >= 0 ? AppColors.success : AppColors.coral;
    final aheadText = ahead == 0
        ? l10n.miplanOnTrack
        : (ahead > 0 ? l10n.miplanAhead(ahead) : l10n.miplanBehind(-ahead));
    final proj = t.projectedCompletion;
    return ResponsiveCenter(
      maxWidth: 480,
      child: ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        // Niveles + progreso.
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [AppColors.primaryLight, AppColors.primary]),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.32), offset: const Offset(0, 8), blurRadius: 20)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(l10n.miplanProgressLabel,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.4, color: Colors.white70)),
                  const Spacer(),
                  Text('${t.currentLevel} → ${t.goalLevel}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: t.progress.clamp(0.0, 1.0),
                  minHeight: 12,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
              ),
              const SizedBox(height: 8),
              Text(l10n.miplanPracticeDays('${(t.progress * 100).round()}', '${t.goalMetDays}', '${t.totalActiveDays}'),
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.white70)),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // Adelante / atrás.
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: aheadColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: aheadColor.withValues(alpha: 0.5), width: 1.5),
          ),
          child: Row(
            children: [
              Icon(ahead >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded, color: aheadColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(aheadText, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: aheadColor)),
                    Text(l10n.miplanMetDays('${t.goalMetDays}', '${t.expectedDays}'),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // Fecha proyectada. Si aún no hay proyección (sin ritmo suficiente),
        // mostramos la fecha del plan original o un estado de cálculo.
        if (proj != null)
          _InfoCard(
            icon: Icons.event_available_rounded,
            title: l10n.miplanProjectedArrival,
            value: fmtDate(context, proj),
            sub: t.estimatedCompletion != null && t.estimatedCompletion != proj
                ? l10n.miplanOriginalPlan(fmtDate(context, t.estimatedCompletion!))
                : l10n.miplanCurrentPace,
          )
        else if (t.estimatedCompletion != null)
          _InfoCard(
            icon: Icons.event_available_rounded,
            title: l10n.miplanEstimatedArrival,
            value: fmtDate(context, t.estimatedCompletion!),
            sub: l10n.miplanEstimateHint,
          )
        else
          _InfoCard(
            icon: Icons.hourglass_empty_rounded,
            title: l10n.miplanProjectedArrival,
            value: l10n.miplanCalculating,
            sub: l10n.miplanCalcHint,
          ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _Mini(icon: Icons.bolt_rounded, value: '${t.dailyMinutes} min', label: l10n.miplanPerDay)),
            const SizedBox(width: 10),
            Expanded(child: _Mini(icon: Icons.calendar_today_rounded, value: l10n.miplanDaysCount('${t.daysPerWeek}'), label: l10n.miplanPerWeek)),
          ],
        ),
        if (focusText(l10n, t.motive) != null) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: AppColors.navActiveBg, borderRadius: BorderRadius.circular(16)),
            child: Text(focusText(l10n, t.motive)!,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary)),
          ),
        ],
        const SizedBox(height: 18),
        // Palanca "llegar más rápido" (botón dorado 3D de la casa).
        PrimaryButton(
          label: l10n.miplanFasterCta,
          icon: Icons.rocket_launch_rounded,
          expand: true,
          color: AppColors.gold,
          depthColor: AppColors.goldDark,
          foreground: const Color(0xFF5B3A00),
          onPressed: () => _faster(context, ref, t),
        ),
      ],
    ),
    );
  }

  Future<void> _faster(BuildContext context, WidgetRef ref, PlanTracking t) async {
    final l10n = AppLocalizations.of(context);
    const tiers = [10, 15, 20, 30, 45, 60];
    final pick = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.miplanPaceSheetTitle,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.text)),
              const SizedBox(height: 4),
              Text(l10n.miplanPaceSheetSub,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10, runSpacing: 10,
                children: [
                  for (final m in tiers)
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx, m),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        decoration: BoxDecoration(
                          color: m == t.dailyMinutes ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(
                              color: m == t.dailyMinutes ? AppColors.primary : const Color(0xFFE5E7F1), width: 2),
                        ),
                        child: Text('$m min',
                            style: TextStyle(
                                fontSize: 14.5, fontWeight: FontWeight.w900,
                                color: m == t.dailyMinutes ? Colors.white : AppColors.text)),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (pick == null || pick == t.dailyMinutes) return;
    try {
      await ref.read(progressRepositoryProvider).updatePlanPace(pick);
      ref.invalidate(planTrackingProvider);
      ref.invalidate(userPlanProvider);
      ref.invalidate(homeStatsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.miplanPaceUpdated('$pick'))));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.miplanPaceError)));
      }
    }
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.icon, required this.title, required this.value, required this.sub});
  final IconData icon;
  final String title;
  final String value;
  final String sub;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 5), blurRadius: 0)]),
      child: Row(
        children: [
          Container(
            width: 44, height: 44, alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.navActiveBg, borderRadius: BorderRadius.circular(13)),
            child: Icon(icon, color: AppColors.primary)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
                Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.text)),
                Text(sub, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Mini extends StatelessWidget {
  const _Mini({required this.icon, required this.value, required this.label});
  final IconData icon;
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 4), blurRadius: 0)]),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.text)),
              Text(label, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}
