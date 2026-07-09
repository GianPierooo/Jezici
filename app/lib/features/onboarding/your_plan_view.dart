import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/plan/estimation.dart';
import '../../core/theme/app_colors.dart';
import '../../core/ui/jz_glow_pulse.dart';
import '../../core/ui/responsive_center.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/duration_format.dart';
import '../../ui/primary_button.dart';
import '../learn/widgets/parrot_mascot.dart';
import 'onboarding_data.dart';

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

/// "Tu plan" (el momento mágico, Onboarding.dc FRAME B): header de CELEBRACIÓN
/// (confeti + halo + guacamayo festejando) + MAPA DE VIAJE (nivel actual → meta,
/// camino punteado que asciende) + tarjeta de fecha viva + PALANCA de ritmo
/// reversible que recalcula en vivo + CTA "Empezar mi viaje". Respeta
/// reducir-movimiento (a11y). No toca la lógica de create_plan (widget.onFinish).
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

class _YourPlanViewState extends State<YourPlanView>
    with SingleTickerProviderStateMixin {
  late int _baseMin; // ritmo elegido en el compromiso (el "lento")
  late int _dailyMin; // ritmo efectivo (cambia con la palanca)
  bool _fast = false;
  bool _loading = false;
  late final AnimationController _anim;
  bool _reduceMotion = false;

  /// Ritmo "rápido": el primer tier que ~duplica el elegido (tope 45). Si ya se
  /// eligió el máximo, no hay palanca (nota de "ritmo máximo").
  int get _fastMin {
    final target = _baseMin * 2;
    for (final t in _tiers) {
      if (t >= target) return t;
    }
    return _tiers.last;
  }

  bool get _hasLever => _baseMin < _tiers.last;

  @override
  void initState() {
    super.initState();
    _baseMin = widget.data.dailyMinutes;
    _dailyMin = _baseMin;
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.of(context).disableAnimations;
    if (_reduceMotion) {
      if (_anim.isAnimating) _anim.stop();
    } else if (!_anim.isAnimating) {
      _anim.repeat();
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
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
        maxLevel: widget.data.targetMaxLevel,
      );

  void _toggleFast() {
    setState(() {
      _fast = !_fast;
      _dailyMin = _fast ? _fastMin : _baseMin;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final est = _est;
    final dateStr = MaterialLocalizations.of(context).formatMediumDate(est.completionDate);
    final entry = entryUnitFor(widget.data.currentLevel);
    final focus = _focusText(l10n, widget.data.motive);
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _CelebrationHeader(
            anim: _anim,
            reduceMotion: _reduceMotion,
            onBack: widget.onBack,
            kicker: l10n.planReadyKicker,
            title: l10n.planReadyTitle,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: ResponsiveCenter(
                maxWidth: 480,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Mapa de viaje: nivel actual → meta.
                    _JourneyMap(
                      anim: _anim,
                      reduceMotion: _reduceMotion,
                      currentLevel: widget.data.currentLevel,
                      goalLevel: est.goalLevel,
                      hereLabel: l10n.planJourneyHere,
                      goalLabel: l10n.planJourneyGoal,
                    ),
                    const SizedBox(height: 14),
                    // Tarjeta de fecha (hero) con badge de "la mitad de tiempo".
                    _DataCard(
                      paceLine: l10n.planPaceLine(_dailyMin, est.goalLevel),
                      dateStr: dateStr,
                      completionDate: est.completionDate,
                      duration: formatPlanDuration(l10n, est.weeks),
                      hoursMeta:
                          '${l10n.planStatsHours(est.hoursNeeded)} · ${l10n.onbDaysShort(widget.data.daysPerWeek)}',
                      showHalf: _fast,
                      halfLabel: l10n.planHalfTime,
                    ),
                    const SizedBox(height: 14),
                    // Palanca de ritmo REVERSIBLE (recalcula la fecha en vivo).
                    if (_hasLever)
                      _LeverCard(
                        fast: _fast,
                        title: _fast ? l10n.planLeverTitleOn : l10n.planLeverTitleOff,
                        text: _fast
                            ? l10n.planLeverTextOn(_dailyMin)
                            : l10n.planLeverTextOff(_fastMin),
                        onToggle: _toggleFast,
                      )
                    else
                      _MaxPaceCard(text: l10n.planMaxPace),
                    if (focus != null) ...[
                      const SizedBox(height: 14),
                      _FocusCard(
                        emoji: _motiveEmoji[widget.data.motive] ?? '🎯',
                        text: focus,
                      ),
                    ],
                    const SizedBox(height: 14),
                    // Primer tramo del árbol.
                    _FirstUnitCard(
                      text: l10n.planStartUnit(entry.$1, entry.$2, widget.data.currentLevel),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
          // CTA coral "Empezar mi viaje".
          Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + bottomPad),
            child: ResponsiveCenter(
              maxWidth: 480,
              child: JzGlowPulse(
                color: AppColors.coral,
                child: PrimaryButton(
                  label: _loading ? l10n.planPreparing : l10n.planStartJourney,
                  icon: _loading ? null : Icons.arrow_forward_rounded,
                  color: AppColors.coral,
                  depthColor: AppColors.coralDark,
                  expand: true,
                  onPressed: _loading ? null : _finish,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header de celebración: gradiente violeta + confeti + halo + guacamayo ─────
class _CelebrationHeader extends StatelessWidget {
  const _CelebrationHeader({
    required this.anim,
    required this.reduceMotion,
    required this.onBack,
    required this.kicker,
    required this.title,
  });

  final AnimationController anim;
  final bool reduceMotion;
  final VoidCallback onBack;
  final String kicker;
  final String title;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;
    return Container(
      height: 214 + topPad,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7A6BF0), AppColors.primary, Color(0xFF5B4ECF)],
        ),
      ),
      child: Stack(
        children: [
          // Confeti que cae (loop).
          if (!reduceMotion)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: anim,
                builder: (_, _) => CustomPaint(painter: _ConfettiPainter(anim.value)),
              ),
            ),
          // Halo pulsante detrás del guacamayo.
          Align(
            alignment: const Alignment(0, -0.15),
            child: AnimatedBuilder(
              animation: anim,
              builder: (_, _) {
                final t = reduceMotion ? 0.5 : (math.sin(anim.value * math.pi * 2) * 0.5 + 0.5);
                return Container(
                  width: 150 + 20 * t,
                  height: 150 + 20 * t,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      AppColors.gold.withValues(alpha: 0.15 + 0.30 * t),
                      AppColors.gold.withValues(alpha: 0),
                    ]),
                  ),
                );
              },
            ),
          ),
          // Guacamayo festejando.
          Align(
            alignment: const Alignment(0, -0.25),
            child: Padding(
              padding: EdgeInsets.only(top: topPad),
              child: const ParrotMascot(size: 82, mood: MascotMood.celebrate),
            ),
          ),
          // Botón atrás.
          Positioned(
            left: 12,
            top: topPad + 6,
            child: GestureDetector(
              onTap: onBack,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
          // Kicker + título.
          Positioned(
            left: 0,
            right: 0,
            bottom: 18,
            child: Column(
              children: [
                Text(
                  kicker,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.2,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 23, fontWeight: FontWeight.w900, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.t);
  final double t; // 0..1
  static const _colors = [
    AppColors.gold,
    AppColors.coral,
    AppColors.success,
    Color(0xFFFFD86B),
    Colors.white,
  ];
  // (xFrac, delay, isCircle, colorIdx)
  static const _bits = [
    (0.10, 0.0, false, 0),
    (0.30, 0.3, false, 1),
    (0.52, 0.6, true, 2),
    (0.72, 0.15, false, 3),
    (0.85, 0.45, true, 0),
    (0.18, 0.75, true, 4),
    (0.62, 0.9, false, 2),
    (0.42, 0.55, false, 3),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (final (xf, delay, circle, ci) in _bits) {
      final phase = (t + delay) % 1.0;
      final y = -14 + phase * (size.height + 28);
      final x = xf * size.width + math.sin(phase * math.pi * 3) * 8;
      final p = Paint()..color = _colors[ci].withValues(alpha: phase < 0.12 ? phase / 0.12 : 0.9);
      if (circle) {
        canvas.drawCircle(Offset(x, y), 4.5, p);
      } else {
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(phase * math.pi * 4);
        canvas.drawRect(const Rect.fromLTWH(-4, -5, 8, 10), p);
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => old.t != t;
}

// ── Mapa de viaje: colinas + camino punteado ascendente + pins ───────────────
class _JourneyMap extends StatelessWidget {
  const _JourneyMap({
    required this.anim,
    required this.reduceMotion,
    required this.currentLevel,
    required this.goalLevel,
    required this.hereLabel,
    required this.goalLabel,
  });

  final AnimationController anim;
  final bool reduceMotion;
  final String currentLevel;
  final String goalLevel;
  final String hereLabel;
  final String goalLabel;

  @override
  Widget build(BuildContext context) {
    final sr = CefrTable.rank(currentLevel);
    final gr = CefrTable.rank(goalLevel);
    final mid = (gr - sr) >= 2 ? CefrTable.order[sr + 1] : null;
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFEFF4FF), Colors.white],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 5), blurRadius: 0),
          BoxShadow(color: Color(0x11312E78), offset: Offset(0, 12), blurRadius: 22),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: SizedBox(
        height: 116,
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: anim,
                builder: (_, _) => CustomPaint(
                  painter: _JourneyPainter(reduceMotion ? 0 : anim.value),
                ),
              ),
            ),
            // Pin "estás aquí" (abajo-izquierda).
            Align(
              alignment: const Alignment(-1, 1),
              child: _MapPin(
                label: currentLevel,
                caption: hereLabel,
                colors: const [AppColors.primaryLight, AppColors.primary],
                depth: AppColors.primaryDark,
                captionColor: AppColors.primary,
                size: 42,
              ),
            ),
            // Milestone intermedio (si el salto es ≥2 niveles).
            if (mid != null)
              Align(
                alignment: const Alignment(0.05, -0.25),
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFC7BEF0), width: 2.5),
                  ),
                  alignment: Alignment.center,
                  child: Text(mid,
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textMuted)),
                ),
              ),
            // Meta (arriba-derecha) con banderita.
            Align(
              alignment: const Alignment(1, -1),
              child: _MapPin(
                label: goalLevel,
                caption: goalLabel,
                colors: const [Color(0xFFFFDD7A), AppColors.gold],
                depth: AppColors.goldDark,
                captionColor: AppColors.goldDark,
                size: 46,
                flag: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin({
    required this.label,
    required this.caption,
    required this.colors,
    required this.depth,
    required this.captionColor,
    required this.size,
    this.flag = false,
  });

  final String label;
  final String caption;
  final List<Color> colors;
  final Color depth;
  final Color captionColor;
  final double size;
  final bool flag;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (flag) const Icon(Icons.flag_rounded, color: AppColors.coral, size: 16),
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [BoxShadow(color: depth, offset: const Offset(0, 3), blurRadius: 0)],
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white)),
        ),
        const SizedBox(height: 3),
        Text(caption,
            style: TextStyle(
                fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.4, color: captionColor)),
      ],
    );
  }
}

class _JourneyPainter extends CustomPainter {
  _JourneyPainter(this.dash);
  final double dash; // 0..1 fase del punteado

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    // Colinas (2 capas).
    final hill1 = Path()
      ..moveTo(0, h * 0.78)
      ..quadraticBezierTo(w * 0.25, h * 0.55, w * 0.5, h * 0.72)
      ..quadraticBezierTo(w * 0.72, h * 0.9, w, h * 0.5)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(hill1, Paint()..color = const Color(0xFFD9F0E2));
    final hill2 = Path()
      ..moveTo(0, h * 0.92)
      ..quadraticBezierTo(w * 0.3, h * 0.78, w * 0.56, h * 0.9)
      ..quadraticBezierTo(w * 0.8, h * 0.98, w, h * 0.82)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(hill2, Paint()..color = const Color(0xFFBFE7CD));
    // Camino punteado que asciende (de la esquina inferior-izq a la superior-der).
    final path = Path()
      ..moveTo(w * 0.14, h * 0.72)
      ..cubicTo(w * 0.32, h * 0.72, w * 0.30, h * 0.42, w * 0.48, h * 0.40)
      ..cubicTo(w * 0.66, h * 0.38, w * 0.62, h * 0.20, w * 0.86, h * 0.14);
    final dot = Paint()..color = const Color(0xFFC7BEF0);
    const gap = 13.0;
    for (final m in path.computeMetrics()) {
      var d = (dash * gap) % gap;
      while (d < m.length) {
        final tan = m.getTangentForOffset(d);
        if (tan != null) canvas.drawCircle(tan.position, 2.6, dot);
        d += gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _JourneyPainter old) => old.dash != dash;
}

// ── Tarjeta de fecha (hero) ──────────────────────────────────────────────────
class _DataCard extends StatelessWidget {
  const _DataCard({
    required this.paceLine,
    required this.dateStr,
    required this.completionDate,
    required this.duration,
    required this.hoursMeta,
    required this.showHalf,
    required this.halfLabel,
  });

  final String paceLine;
  final String dateStr;
  final DateTime completionDate;
  final String duration;
  final String hoursMeta;
  final bool showHalf;
  final String halfLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 5), blurRadius: 0),
          BoxShadow(color: Color(0x11312E78), offset: Offset(0, 12), blurRadius: 22),
        ],
      ),
      child: Column(
        children: [
          Text(paceLine,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
          const SizedBox(height: 6),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              dateStr,
              key: ValueKey(completionDate),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.primary),
            ),
          ),
          if (showHalf) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE5F8EE),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(halfLabel,
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.successDark)),
            ),
          ],
          const SizedBox(height: 8),
          Text('$duration · $hoursMeta',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFFB0B4C8))),
        ],
      ),
    );
  }
}

// ── Palanca de ritmo (reversible) ────────────────────────────────────────────
class _LeverCard extends StatelessWidget {
  const _LeverCard({
    required this.fast,
    required this.title,
    required this.text,
    required this.onToggle,
  });

  final bool fast;
  final String title;
  final String text;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: fast
              ? const [Color(0xFFE5F8EE), Color(0xFFEDFBF2)]
              : const [Color(0xFFFFF1F1), Color(0xFFFFF6EC)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: fast ? const Color(0xFFBCEBCF) : const Color(0xFFFFD9D9), width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.text)),
                const SizedBox(height: 2),
                Text(text,
                    style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMuted,
                        height: 1.3)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _Toggle(key: const Key('planPaceToggle'), on: fast, onTap: onToggle),
        ],
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({super.key, required this.on, required this.onTap});
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 54,
        height: 31,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: on ? AppColors.success : const Color(0xFFD0D5E2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 180),
          alignment: on ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 25,
            height: 25,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Color(0x40000000), offset: Offset(0, 2), blurRadius: 5)],
            ),
          ),
        ),
      ),
    );
  }
}

class _MaxPaceCard extends StatelessWidget {
  const _MaxPaceCard({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7F1), width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.rocket_launch_rounded, color: AppColors.textMuted, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 13.5, fontWeight: FontWeight.w900, color: AppColors.textMuted)),
          ),
        ],
      ),
    );
  }
}

class _FocusCard extends StatelessWidget {
  const _FocusCard({required this.emoji, required this.text});
  final String emoji;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.navActiveBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

class _FirstUnitCard extends StatelessWidget {
  const _FirstUnitCard({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
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
              gradient: const LinearGradient(colors: [AppColors.primaryLight, AppColors.primary]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.waving_hand_rounded, color: Colors.white, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.text)),
          ),
        ],
      ),
    );
  }
}
