import 'package:flutter/material.dart';

import '../../core/plan/estimation.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/duration_format.dart';
import '../../ui/primary_button.dart';
import 'onboarding_data.dart';
import 'widgets/onboarding_scaffold.dart';

const _tiers = [5, 10, 15, 20, 30, 45];

/// Emoji del enfoque del plan según el MOTIVO (server value → emoji). El texto
/// del enfoque lo pone i18n (ver _focusText). Personalización real (GA4 A2/B1).
const _motiveEmoji = {
  'Trabajo': '💼',
  'Viajes': '✈️',
  'Examen': '🎓',
  'Estudios': '📚',
  'Mudanza': '🏠',
  'Placer': '🎬',
};

String? _focusText(AppLocalizations l10n, String motive) => switch (motive) {
      'Trabajo' => l10n.planFocusWork,
      'Viajes' => l10n.planFocusTravel,
      'Examen' => l10n.planFocusExam,
      'Estudios' => l10n.planFocusStudies,
      'Mudanza' => l10n.planFocusRelocation,
      'Placer' => l10n.planFocusCulture,
      _ => null,
    };

/// "Tu plan" (momento mágico): nivel actual → meta, fecha estimada, horas y
/// ritmo, con la palanca "Quiero llegar más rápido" que recalcula EN VIVO.
class YourPlanView extends StatefulWidget {
  const YourPlanView({
    super.key,
    required this.data,
    required this.step,
    required this.total,
    required this.onBack,
    required this.onFinish,
  });

  final OnboardingData data;
  final int step;
  final int total;
  final VoidCallback onBack;

  /// Persiste el plan (la cuenta ya existe en el flujo auth-first) y entra al mapa.
  final Future<void> Function() onFinish;

  @override
  State<YourPlanView> createState() => _YourPlanViewState();
}

class _YourPlanViewState extends State<YourPlanView> {
  late int _dailyMin;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _dailyMin = widget.data.dailyMinutes;
  }

  Future<void> _finish() async {
    widget.data.dailyMinutes = _dailyMin; // conserva la palanca
    setState(() => _loading = true);
    try {
      await widget.onFinish();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  PlanEstimate get _est => estimatePlan(
        currentLevel: widget.data.currentLevel,
        goalLevel: widget.data.goalLevel,
        dailyMinutes: _dailyMin,
        daysPerWeek: widget.data.daysPerWeek,
      );

  void _faster() {
    final i = _tiers.indexOf(_dailyMin);
    final next = i >= 0 && i < _tiers.length - 1 ? _tiers[i + 1] : _tiers.last;
    setState(() => _dailyMin = next);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final est = _est;
    final atMax = _dailyMin >= _tiers.last;
    final dateStr = MaterialLocalizations.of(context).formatMediumDate(est.completionDate);
    final entry = entryUnitFor(widget.data.currentLevel);
    final focus = _focusText(l10n, widget.data.motive);
    return OnboardingScaffold(
      step: widget.step,
      total: widget.total,
      onBack: widget.onBack,
      showMascot: false,
      title: l10n.planReadyTitle,
      subtitle: l10n.planReadySubtitle,
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PrimaryButton(
            label: _loading ? l10n.planPreparing : l10n.planStartMyPlan,
            expand: true,
            onPressed: _loading ? null : _finish,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Nivel actual -> meta.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LevelBadge(label: widget.data.currentLevel, muted: true),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.arrow_forward_rounded, color: AppColors.textMuted),
              ),
              _LevelBadge(label: est.goalLevel, muted: false),
            ],
          ),
          const SizedBox(height: 20),
          // Fecha estimada (hero).
          Container(
            padding: const EdgeInsets.all(20),
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
                Text(l10n.planCompletionLabel,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: Colors.white70)),
                const SizedBox(height: 6),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    dateStr,
                    key: ValueKey(est.completionDate),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 4),
                Text(formatPlanDuration(l10n, est.weeks),
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Stats.
          Row(
            children: [
              _Stat(
                  icon: Icons.schedule_rounded,
                  value: l10n.planStatsHours(est.hoursNeeded),
                  label: l10n.planStatsTotalLabel),
              const SizedBox(width: 12),
              _Stat(
                  icon: Icons.bolt_rounded,
                  value: l10n.onbMinutesShort(_dailyMin),
                  label: l10n.planStatsFrequency(widget.data.daysPerWeek)),
            ],
          ),
          const SizedBox(height: 14),
          // Palanca.
          GestureDetector(
            onTap: atMax ? null : _faster,
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: atMax ? const Color(0xFFF0F1F8) : const Color(0xFFFFF4D6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: atMax ? const Color(0xFFE5E7F1) : AppColors.gold, width: 1.5),
              ),
              child: Row(
                children: [
                  Icon(Icons.rocket_launch_rounded,
                      color: atMax ? AppColors.textMuted : AppColors.goldDark, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      atMax
                          ? l10n.planMaxPace
                          : l10n.planFasterCta(_tiers[_tiers.indexOf(_dailyMin) + 1]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          color: atMax ? AppColors.textMuted : const Color(0xFF9A7A1E)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (focus != null) ...[
            const SizedBox(height: 14),
            // Personalización por motivo (GA4).
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AppColors.navActiveBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Text(_motiveEmoji[widget.data.motive] ?? '🎯',
                      style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      focus,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          // Primer tramo del árbol.
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 4), blurRadius: 0),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [AppColors.primaryLight, AppColors.primary]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.waving_hand_rounded, color: Colors.white, size: 19),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.planStartUnit(entry.$1, entry.$2, widget.data.currentLevel),
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  const _LevelBadge({required this.label, required this.muted});
  final String label;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: muted ? const Color(0xFFF0F1F8) : AppColors.primary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(muted ? l10n.planBadgeNow : l10n.planBadgeGoal,
              style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  color: muted ? AppColors.textMuted : Colors.white70)),
          Text(label,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: muted ? AppColors.text : Colors.white)),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.value, required this.label});
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 4), blurRadius: 0),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.text)),
                Text(label,
                    style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
