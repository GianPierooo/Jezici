import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ui/responsive_center.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/lesson_model.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../learn/widgets/parrot_mascot.dart';
import 'checkpoint_player_screen.dart';

/// Intro del checkpoint (mockup Checkpoint, Frame A): escena nocturna con
/// estrellas + portal + loro con burbuja, chips "QUÉ ENTRA" (las lecciones
/// REALES de la unidad) y condiciones del examen. Los valores 5 min / 80% / 10
/// son las CONSTANTES reales de `start_checkpoint` (300s, 0.80, 3R+3W+2L+2S).
class CheckpointIntroScreen extends ConsumerWidget {
  const CheckpointIntroScreen({super.key, required this.lesson, required this.unitTitle});

  final LessonModel lesson;
  final String unitTitle;

  Future<void> _start(BuildContext context, WidgetRef ref) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
    );
    try {
      final data = await ref.read(progressRepositoryProvider).startCheckpoint(lesson.id);
      if (!context.mounted) return;
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CheckpointPlayerScreen(lesson: lesson, unitTitle: unitTitle, data: data),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).checkpointStartError)),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    // QUÉ ENTRA: los títulos REALES de las lecciones de esta unidad (dato que ya
    // existe en mapUnitsProvider). Sin datos → la sección se omite (honesto).
    final unitLessons = ref.watch(mapUnitsProvider).maybeWhen(
        data: (units) {
          for (final u in units) {
            if (u.id == lesson.unitId) {
              return [
                for (final le in u.lessons)
                  if (le.type != LessonType.checkpoint) le.title
              ];
            }
          }
          return const <String>[];
        },
        orElse: () => const <String>[]);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Escena del portal (noche estrellada del mockup).
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF5B4ECF), AppColors.primary, Color(0xFF8273E8)],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Stack(children: [
                  const Positioned.fill(child: _Stars()),
                  Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            unitTitle.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                              color: Colors.white.withValues(alpha: 0.75),
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(width: 36),
                        ],
                      ),
                    ),
                    // Centro ESCALABLE: en pantallas cortas el portal/título se
                    // encogen (FittedBox) en vez de desbordar.
                    Expanded(
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                    // Portal.
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(colors: [
                              AppColors.gold.withValues(alpha: 0.5),
                              AppColors.gold.withValues(alpha: 0.0),
                            ]),
                          ),
                        ),
                        Container(
                          width: 120,
                          height: 138,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFF8474F0), Color(0xFF5E51C9)],
                            ),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(60),
                              bottom: Radius.circular(14),
                            ),
                            boxShadow: const [
                              BoxShadow(color: Color(0xFF4B3FA8), offset: Offset(0, 6), blurRadius: 0),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFFFFE9A8), AppColors.gold],
                              ),
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(44),
                                bottom: Radius.circular(8),
                              ),
                            ),
                            child: const Icon(Icons.star_rounded, color: Colors.white, size: 40),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('⚑ CHECKPOINT',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                              color: Color(0xFF5B3A00))),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.checkpointPortalTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      unitTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.white.withValues(alpha: 0.8)),
                    ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Loro con BURBUJA de diálogo (mockup), no texto plano suelto.
                    Padding(
                      padding: const EdgeInsets.only(bottom: 30, right: 16),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: ParrotMascot(
                            size: 52,
                            mood: MascotMood.encourage,
                            message: l10n.checkpointCoachMsg),
                      ),
                    ),
                  ],
                  ),
                ]),
              ),
            ),
          ),
          // Hoja de info (scrollable con tope: en pantallas cortas no desborda —
          // la escena de arriba conserva al menos ~1/3 del alto).
          ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.62),
            child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            transform: Matrix4.translationValues(0, -22, 0),
            // + inset inferior: en Android (PWA) la barra de navegación del sistema
            // tapaba el botón/última línea ("se corta levemente"). 0 en pantallas sin inset.
            padding: EdgeInsets.fromLTRB(20, 20, 20, 28 + MediaQuery.paddingOf(context).bottom),
            child: SingleChildScrollView(
            child: ResponsiveCenter(
              maxWidth: 480,
              child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.checkpointIntroMsg,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textMuted),
                ),
                // QUÉ ENTRA: chips con las lecciones reales de la unidad.
                if (unitLessons.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(l10n.checkpointWhatsIn,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: AppColors.textMuted)),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: [
                        // Máx 4 chips + "+N" (como el mockup; la hoja no crece sin tope).
                        for (final t in unitLessons.take(4))
                          _chip(t),
                        if (unitLessons.length > 4)
                          _chip('+${unitLessons.length - 4}'),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    _StatCard(icon: Icons.timer_outlined, value: '5 min', label: l10n.checkpointStatTimed),
                    const SizedBox(width: 10),
                    _StatCard(icon: Icons.adjust_rounded, value: '80%', label: l10n.checkpointStatPass),
                    const SizedBox(width: 10),
                    _StatCard(icon: Icons.help_outline_rounded, value: '10', label: l10n.checkpointStatQuestions),
                  ],
                ),
                const SizedBox(height: 18),
                GestureDetector(
                  onTap: () => _start(context, ref),
                  child: Container(
                    width: double.infinity,
                    height: 58,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFFFDD7A), AppColors.gold]),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(color: Color(0xFFD69400), offset: Offset(0, 6), blurRadius: 0),
                      ],
                    ),
                    child: Text(l10n.checkpointStartCta,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.text)),
                  ),
                ),
                const SizedBox(height: 11),
                Text(l10n.checkpointNoCost,
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
              ],
            ),
            ),
            ),
          ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.navActiveBg,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(t,
            style: const TextStyle(
                fontSize: 11.5, fontWeight: FontWeight.w900, color: AppColors.primary)),
      );
}

/// Estrellas de la escena nocturna (jzTwinkle del mockup): puntitos que
/// parpadean suave. Con reduce-motion quedan FIJAS semitransparentes.
class _Stars extends StatefulWidget {
  const _Stars();
  @override
  State<_Stars> createState() => _StarsState();
}

class _StarsState extends State<_Stars> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2600));
  bool _reduce = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduce = MediaQuery.disableAnimationsOf(context);
    if (_reduce) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, _) =>
            CustomPaint(painter: _StarsPainter(_reduce ? 0.5 : _c.value)),
      ),
    );
  }
}

class _StarsPainter extends CustomPainter {
  _StarsPainter(this.t);
  final double t; // fase 0..1

  // Posiciones del mockup (fracciones de 368×~400 de la escena) + extras.
  static const _stars = <(double, double, double, double, bool)>[
    // (fx, fy, radio, desfase, dorada)
    (0.11, 0.16, 2.5, 0.0, false),
    (0.82, 0.20, 2.0, 0.35, false),
    (0.68, 0.13, 3.0, 0.60, true),
    (0.22, 0.26, 2.0, 0.20, false),
    (0.92, 0.34, 2.2, 0.80, false),
    (0.05, 0.42, 1.8, 0.55, false),
    (0.45, 0.10, 2.0, 0.45, true),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (final (fx, fy, r, phase, gold) in _stars) {
      // Parpadeo suave 0.3..1.0 (jzTwinkle) con desfase por estrella.
      final wave = (0.5 - (((t + phase) % 1.0) - 0.5).abs()) * 2; // 0..1
      final alpha = 0.3 + 0.7 * wave;
      canvas.drawCircle(
        Offset(size.width * fx, size.height * fy),
        r,
        Paint()
          ..color = (gold ? const Color(0xFFFFD86B) : Colors.white)
              .withValues(alpha: alpha),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StarsPainter old) => old.t != t;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.icon, required this.value, required this.label});
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 4), blurRadius: 0),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.text)),
            Text(label,
                style: const TextStyle(
                    fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
