import 'package:flutter/material.dart';

import '../../core/plan/estimation.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/duration_format.dart';
import '../../ui/primary_button.dart';
import 'onboarding_data.dart';
import 'widgets/onboarding_scaffold.dart';

// Clave + icono por habilidad (orden de presentación). El nombre lo pone i18n.
const _skills = <(String, IconData)>[
  ('reading', Icons.menu_book_rounded),
  ('writing', Icons.edit_rounded),
  ('listening', Icons.headphones_rounded),
  ('speaking', Icons.record_voice_over_rounded),
];

String _skillName(AppLocalizations l10n, String key) => switch (key) {
      'reading' => l10n.skillReading,
      'writing' => l10n.skillWriting,
      'listening' => l10n.skillListening,
      'speaking' => l10n.skillSpeaking,
      _ => key,
    };

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
    final l10n = AppLocalizations.of(context);
    final level = data.placementLevel;
    final entry = entryUnitFor(level);
    final est = estimatePlan(
      currentLevel: level,
      goalLevel: data.goalLevel,
      dailyMinutes: data.dailyMinutes,
      daysPerWeek: data.daysPerWeek,
      maxLevel: data.targetMaxLevel,
    );
    // Fecha localizada (compacta) sin depender de intl date-init: la aporta
    // flutter_localizations vía MaterialLocalizations.
    final dateStr = MaterialLocalizations.of(context).formatMediumDate(est.completionDate);
    final durationStr = formatPlanDuration(l10n, est.weeks);

    return OnboardingScaffold(
      step: step,
      total: total,
      onBack: onBack,
      showMascot: false,
      title: l10n.placementResultTitle(level),
      subtitle: l10n.placementResultSubtitle,
      footer: PrimaryButton(label: l10n.placementResultViewPlan, expand: true, onPressed: onContinue),
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
                Text(l10n.placementResultHero,
                    style: const TextStyle(
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
          Text(l10n.placementResultSkillsTitle,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.text)),
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
                    icon: s.$2,
                    name: _skillName(l10n, s.$1),
                    level: data.skillLevels[s.$1] ?? level,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // A qué unidad entra.
          _InfoCard(
            icon: Icons.flag_rounded,
            text: l10n.placementResultEntryUnit(entry.$1, entry.$2, level),
          ),
          const SizedBox(height: 10),
          // Fecha realista (honesta).
          _InfoCard(
            icon: Icons.event_available_rounded,
            text: est.bumpedGoal
                ? l10n.placementResultEstimateReached(est.goalLevel, durationStr, dateStr)
                : l10n.placementResultEstimateGoal(est.goalLevel, durationStr, dateStr),
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
