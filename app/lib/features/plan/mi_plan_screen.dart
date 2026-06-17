import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/progress_models.dart';
import '../../data/providers.dart';

/// "Mi Plan" — dashboard de seguimiento (GA4 · B2, diferenciador):
/// fecha de llegada recalculada con el ritmo real, "vas X días adelante/atrás",
/// progreso del plan y la palanca "llegar más rápido". Todo server-side.
class MiPlanScreen extends ConsumerWidget {
  const MiPlanScreen({super.key});

  static const _months = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
  ];
  static String fmtDate(DateTime d) => '${d.day} de ${_months[d.month - 1]} de ${d.year}';

  static const _motiveFocus = {
    'Trabajo': '💼 Enfoque laboral: reuniones, correos y entrevistas.',
    'Viajes': '✈️ Enfoque viajes: aeropuerto, hotel, direcciones y restaurantes.',
    'Examen': '🎓 Enfoque examen: simulacros y las 4 habilidades.',
    'Estudios': '📚 Enfoque estudios: comprensión, escritura y vocabulario.',
    'Mudanza': '🏠 Enfoque mudanza: trámites, vivienda y vida diaria.',
    'Placer': '🎬 Enfoque cultura: series, música y conversación.',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(planTrackingProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background, elevation: 0, foregroundColor: AppColors.text,
        title: const Text('Mi plan', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('No se pudo cargar tu plan.\n$e',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textMuted)),
          ),
        ),
        data: (t) => !t.ok
            ? const Center(child: Text('Aún no tienes un plan.'))
            : _body(context, ref, t),
      ),
    );
  }

  Widget _body(BuildContext context, WidgetRef ref, PlanTracking t) {
    final ahead = t.aheadBehind;
    final aheadColor = ahead >= 0 ? AppColors.success : AppColors.coral;
    final aheadText = ahead == 0
        ? 'Justo en tu plan'
        : (ahead > 0 ? 'Vas $ahead ${_d(ahead)} adelante 🎉' : 'Vas ${-ahead} ${_d(-ahead)} atrás');
    final proj = t.projectedCompletion;
    return ListView(
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
                  const Text('AVANCE DEL PLAN',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.4, color: Colors.white70)),
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
              Text('${(t.progress * 100).round()}% · ${t.goalMetDays}/${t.totalActiveDays} días de práctica',
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
                    Text('Cumpliste ${t.goalMetDays} de ${t.expectedDays} días esperados a hoy.',
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
            title: 'Llegada proyectada',
            value: fmtDate(proj),
            sub: t.estimatedCompletion != null && t.estimatedCompletion != proj
                ? 'Plan original: ${fmtDate(t.estimatedCompletion!)}'
                : 'Con tu ritmo actual',
          )
        else if (t.estimatedCompletion != null)
          _InfoCard(
            icon: Icons.event_available_rounded,
            title: 'Llegada estimada',
            value: fmtDate(t.estimatedCompletion!),
            sub: 'Practica unos días y ajustaremos la fecha a tu ritmo real.',
          )
        else
          _InfoCard(
            icon: Icons.hourglass_empty_rounded,
            title: 'Llegada proyectada',
            value: 'Calculando…',
            sub: 'Completa tus primeras sesiones para estimar tu fecha.',
          ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _Mini(icon: Icons.bolt_rounded, value: '${t.dailyMinutes} min', label: 'al día')),
            const SizedBox(width: 10),
            Expanded(child: _Mini(icon: Icons.calendar_today_rounded, value: '${t.daysPerWeek} días', label: 'por semana')),
          ],
        ),
        if (_motiveFocus[t.motive] != null) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: AppColors.navActiveBg, borderRadius: BorderRadius.circular(16)),
            child: Text(_motiveFocus[t.motive]!,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary)),
          ),
        ],
        const SizedBox(height: 18),
        // Palanca "llegar más rápido".
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: () => _faster(context, ref, t),
            icon: const Icon(Icons.rocket_launch_rounded),
            label: const Text('QUIERO LLEGAR MÁS RÁPIDO',
                style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.4)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold, foregroundColor: AppColors.text,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }

  String _d(int n) => n == 1 ? 'día' : 'días';

  Future<void> _faster(BuildContext context, WidgetRef ref, PlanTracking t) async {
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
              const Text('Sube tu ritmo diario',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.text)),
              const SizedBox(height: 4),
              const Text('Más minutos al día = llegas antes. Recalculamos tu fecha.',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
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
          ..showSnackBar(SnackBar(content: Text('¡Listo! Ahora $pick min/día. Fecha recalculada.')));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo actualizar el ritmo.')));
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
