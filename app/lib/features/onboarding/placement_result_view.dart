import 'package:flutter/material.dart';

import '../../core/plan/estimation.dart';
import '../../core/theme/app_colors.dart';
import '../../ui/primary_button.dart';
import 'onboarding_data.dart';
import 'widgets/onboarding_scaffold.dart';

const _months = [
  'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
  'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
];
String _fmtDate(DateTime d) => '${d.day} de ${_months[d.month - 1]} de ${d.year}';

// Nombre + icono por habilidad (orden de presentación).
const _skills = <(String, String, IconData)>[
  ('reading', 'Lectura', Icons.menu_book_rounded),
  ('writing', 'Escritura', Icons.edit_rounded),
  ('listening', 'Comprensión auditiva', Icons.headphones_rounded),
  ('speaking', 'Expresión oral', Icons.record_voice_over_rounded),
];

/// RESULTADO del test de ubicación (momento motivacional "¡saliste en B1!"). NO es
/// aprobar/reprobar: es UBICACIÓN → "tu nivel es X". Muestra el nivel, el desglose por
/// las 4 habilidades, a qué unidad entrará y la fecha realista (estimación honesta).
class PlacementResultView extends StatelessWidget {
  const PlacementResultView({
    super.key,
    required this.data,
    required this.step,
    required this.total,
    required this.onBack,
    required this.onContinue,
  });

  final OnboardingData data;
  final int step;
  final int total;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final level = data.placementLevel;
    final entry = entryUnitFor(level);
    final est = estimatePlan(
      currentLevel: level,
      goalLevel: data.goalLevel,
      dailyMinutes: data.dailyMinutes,
      daysPerWeek: data.daysPerWeek,
    );

    return OnboardingScaffold(
      step: step,
      total: total,
      onBack: onBack,
      showMascot: false,
      title: 'Tu nivel: $level',
      subtitle: 'Esto no es un examen que se aprueba o se reprueba: es tu punto de partida.',
      footer: PrimaryButton(label: 'VER MI PLAN', expand: true, onPressed: onContinue),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero del nivel.
          Container(
            padding: const EdgeInsets.symmetric(vertical: 22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryLight, AppColors.primary],
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    offset: const Offset(0, 8),
                    blurRadius: 20),
              ],
            ),
            child: Column(
              children: [
                const Text('TE UBICAMOS EN',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.6,
                        color: Colors.white70)),
                const SizedBox(height: 4),
                Text(level,
                    style: const TextStyle(
                        fontSize: 52, fontWeight: FontWeight.w900, color: Colors.white, height: 1.0)),
              ],
            ),
          ),
          const SizedBox(height: 18),
          // Desglose por habilidad.
          const Text('Por habilidad',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.text)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 4), blurRadius: 0)],
            ),
            child: Column(
              children: [
                for (final s in _skills)
                  _SkillRow(
                    icon: s.$3,
                    name: s.$2,
                    level: data.skillLevels[s.$1] ?? level,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // A qué unidad entra.
          _InfoCard(
            icon: Icons.flag_rounded,
            text: 'Empezarás en la Unidad ${entry.$1} — ${entry.$2} ($level). '
                'Lo anterior queda accesible para repasar.',
          ),
          const SizedBox(height: 10),
          // Fecha realista (honesta).
          _InfoCard(
            icon: Icons.event_available_rounded,
            text: est.bumpedGoal
                ? 'Ya alcanzas tu meta. Si sigues hasta ${est.goalLevel}: ${est.humanDuration} '
                    '(aprox. ${_fmtDate(est.completionDate)}).'
                : 'Si cumples tu plan, llegas a ${est.goalLevel} ${est.humanDuration} '
                    '(aprox. ${_fmtDate(est.completionDate)}).',
          ),
        ],
      ),
    );
  }
}

class _SkillRow extends StatelessWidget {
  const _SkillRow({required this.icon, required this.name, required this.level});
  final IconData icon;
  final String name;
  final String level;

  @override
  Widget build(BuildContext context) {
    // Barra proporcional al rango CEFR (A1..C2 → 1/6..6/6).
    final frac = ((CefrTable.rank(level) + 1) / 6).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.text)),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: frac,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFEFF0F7),
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.navActiveBg,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(level,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 4), blurRadius: 0)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 11),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.text, height: 1.35)),
          ),
        ],
      ),
    );
  }
}
