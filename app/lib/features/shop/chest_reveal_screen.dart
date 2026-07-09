import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/feedback/feedback_fx.dart';
import '../../core/theme/app_colors.dart';
import '../../core/ui/responsive_center.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../learn/widgets/parrot_mascot.dart';

/// Pantalla DEDICADA de revelación del cofre (Cofre.dc): fondo violeta, cofre que
/// hace wiggle → tap/CTA lo abre (recompensa REAL del servidor, `open_daily_chest`)
/// → se revela con haz de luz + monedas + premio (jzPop) + confeti, y el CTA
/// dorado 3D muta a verde "¡Reclamar!". Estados: cerrado / abierto / mañana.
/// Reduce-motion-aware. NO cambia la economía: solo la escena sobre el resultado.
enum _ChestPhase { closed, opening, opened, tomorrow }

class ChestRevealScreen extends ConsumerStatefulWidget {
  const ChestRevealScreen({super.key, required this.available});

  /// Si el cofre está disponible hoy (del shop_status). Si no, abre en "mañana".
  final bool available;

  @override
  ConsumerState<ChestRevealScreen> createState() => _ChestRevealScreenState();
}

class _ChestRevealScreenState extends ConsumerState<ChestRevealScreen>
    with TickerProviderStateMixin {
  late final AnimationController _ambient; // wiggle/glow/rays/sparkles (loop)
  late final AnimationController _reveal; // pop/beam/lid (una vez)
  final ConfettiController _confetti =
      ConfettiController(duration: const Duration(seconds: 2));

  late _ChestPhase _phase;
  int _reward = 0;
  bool _reduce = false;

  @override
  void initState() {
    super.initState();
    _ambient = AnimationController(vsync: this, duration: const Duration(seconds: 14))
      ..repeat();
    _reveal = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
    _phase = widget.available ? _ChestPhase.closed : _ChestPhase.tomorrow;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduce = MediaQuery.of(context).disableAnimations;
    if (_reduce && _ambient.isAnimating) _ambient.stop();
    if (!_reduce && !_ambient.isAnimating) _ambient.repeat();
  }

  @override
  void dispose() {
    _ambient.dispose();
    _reveal.dispose();
    _confetti.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    if (_phase != _ChestPhase.closed) return;
    setState(() => _phase = _ChestPhase.opening);
    final l10n = AppLocalizations.of(context);
    try {
      final r = await ref.read(progressRepositoryProvider).openDailyChest();
      if (!mounted) return;
      if (r['ok'] == true) {
        _reward = (r['reward'] as num?)?.toInt() ?? 0;
        setState(() => _phase = _ChestPhase.opened);
        FeedbackFx.celebrate();
        if (_reduce) {
          _reveal.value = 1;
        } else {
          _reveal.forward(from: 0);
          _confetti.play();
        }
        // El oro cambió → refresca lo que dependa del saldo.
        ref.invalidate(shopStatusProvider);
        ref.invalidate(homeStatsProvider);
      } else {
        setState(() => _phase = _ChestPhase.tomorrow);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _phase = _ChestPhase.closed);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.authErrorGeneral)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final opened = _phase == _ChestPhase.opened;
    final tomorrow = _phase == _ChestPhase.tomorrow;
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    final (title, sub) = switch (_phase) {
      _ChestPhase.opened => (l10n.chestTitleOpened(_reward), l10n.chestSubOpened),
      _ChestPhase.tomorrow => (l10n.chestTitleTomorrow, l10n.chestSubTomorrow),
      _ => (l10n.chestTitleClosed, l10n.chestSubClosed),
    };

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF5B4ECF), AppColors.primary, Color(0xFF8273E8)],
          ),
        ),
        child: SafeArea(
          child: ResponsiveCenter(
            maxWidth: 440,
            child: Stack(
              children: [
                // Chispas de ambiente.
                if (!_reduce)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedBuilder(
                        animation: _ambient,
                        builder: (_, _) => CustomPaint(painter: _SparklesPainter(_ambient.value)),
                      ),
                    ),
                  ),

                // Cerrar.
                Positioned(
                  top: 6,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(opened ? _reward : null),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ),

                // Confeti (solo al abrir).
                if (opened)
                  Align(
                    alignment: Alignment.topCenter,
                    child: ConfettiWidget(
                      confettiController: _confetti,
                      blastDirectionality: BlastDirectionality.explosive,
                      numberOfParticles: 16,
                      gravity: 0.28,
                      colors: const [
                        AppColors.gold,
                        AppColors.coral,
                        AppColors.success,
                        Colors.white,
                        AppColors.primaryLight
                      ],
                    ),
                  ),

                // Contenido central.
                Column(
                  children: [
                    const SizedBox(height: 18),
                    // Guacamayo festejando.
                    ParrotMascot(
                        size: 84,
                        mood: opened ? MascotMood.celebrate : MascotMood.idle),
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        children: [
                          Text(title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(color: Color(0x33000000), offset: Offset(0, 2), blurRadius: 10)
                                  ])),
                          const SizedBox(height: 6),
                          Text(sub,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white.withValues(alpha: 0.82))),
                        ],
                      ),
                    ),
                    // Escena del cofre.
                    Expanded(
                      child: Center(
                        child: tomorrow
                            ? _ChestScene(
                                phase: _phase,
                                ambient: _ambient,
                                reveal: _reveal,
                                reduce: _reduce,
                                reward: _reward,
                                onTapChest: null)
                            : _ChestScene(
                                phase: _phase,
                                ambient: _ambient,
                                reveal: _reveal,
                                reduce: _reduce,
                                reward: _reward,
                                onTapChest: _phase == _ChestPhase.closed ? _open : null),
                      ),
                    ),

                    // CTA + nota.
                    Padding(
                      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottomPad),
                      child: Column(
                        children: [
                          _CtaButton(
                            label: switch (_phase) {
                              _ChestPhase.opened => l10n.chestClaimCta,
                              _ChestPhase.tomorrow => l10n.chestCloseCta,
                              _ => l10n.chestOpenCta,
                            },
                            green: opened,
                            busy: _phase == _ChestPhase.opening,
                            onTap: switch (_phase) {
                              _ChestPhase.closed => _open,
                              _ChestPhase.opened => () =>
                                  Navigator.of(context).pop(_reward),
                              _ChestPhase.tomorrow => () =>
                                  Navigator.of(context).pop(null),
                              _ => null,
                            },
                          ),
                          if (opened) ...[
                            const SizedBox(height: 12),
                            Text(l10n.chestComeBack,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white.withValues(alpha: 0.75))),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Escena del cofre: rayos + glow + cofre (cerrado/abierto) + premio ─────────
class _ChestScene extends StatelessWidget {
  const _ChestScene({
    required this.phase,
    required this.ambient,
    required this.reveal,
    required this.reduce,
    required this.reward,
    required this.onTapChest,
  });
  final _ChestPhase phase;
  final AnimationController ambient;
  final AnimationController reveal;
  final bool reduce;
  final int reward;
  final VoidCallback? onTapChest;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final opened = phase == _ChestPhase.opened;
    final tomorrow = phase == _ChestPhase.tomorrow;
    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Rayos giratorios (no en "mañana").
          if (!tomorrow)
            AnimatedBuilder(
              animation: ambient,
              builder: (_, _) => Transform.rotate(
                angle: reduce ? 0 : ambient.value * 2 * math.pi,
                child: CustomPaint(size: const Size(300, 300), painter: _RaysPainter()),
              ),
            ),
          // Glow radial pulsante.
          if (!tomorrow)
            AnimatedBuilder(
              animation: ambient,
              builder: (_, _) {
                final t = reduce ? 0.6 : (math.sin(ambient.value * 2 * math.pi) * 0.5 + 0.5);
                return Container(
                  width: 200 + 26 * t,
                  height: 200 + 26 * t,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      AppColors.gold.withValues(alpha: 0.3 + 0.25 * t),
                      AppColors.gold.withValues(alpha: 0),
                    ]),
                  ),
                );
              },
            ),

          // Haz de luz + premio (abierto).
          if (opened) ...[
            Positioned(
              top: 34,
              child: AnimatedBuilder(
                animation: reveal,
                builder: (_, _) => Opacity(
                  opacity: (reveal.value).clamp(0.0, 1.0),
                  child: CustomPaint(size: const Size(150, 150), painter: _BeamPainter()),
                ),
              ),
            ),
            Positioned(
              top: 26,
              child: ScaleTransition(
                scale: CurvedAnimation(parent: reveal, curve: Curves.easeOutBack),
                child: Column(
                  children: [
                    CustomPaint(size: const Size(84, 84), painter: _MedalPainter()),
                    const SizedBox(height: 6),
                    Text('+$reward',
                        style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            height: 1,
                            color: Colors.white,
                            shadows: [
                              Shadow(color: Color(0x40000000), offset: Offset(0, 3), blurRadius: 10)
                            ])),
                    Text(l10n.chestGoldLabel,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            color: Color(0xFFFFE08A))),
                  ],
                ),
              ),
            ),
          ],

          // El cofre.
          Positioned(
            bottom: 24,
            child: GestureDetector(
              onTap: onTapChest,
              child: opened
                  ? CustomPaint(size: const Size(176, 120), painter: _OpenChestPainter())
                  : AnimatedBuilder(
                      animation: ambient,
                      builder: (_, child) {
                        final wiggle = (reduce || tomorrow)
                            ? 0.0
                            : math.sin(ambient.value * 2 * math.pi * 10) * 0.05;
                        return Transform.rotate(
                            alignment: Alignment.bottomCenter, angle: wiggle, child: child);
                      },
                      child: Opacity(
                        opacity: tomorrow ? 0.55 : 1,
                        child: CustomPaint(
                            size: const Size(176, 150),
                            painter: _ClosedChestPainter(locked: tomorrow)),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── CTA dorado 3D → verde "¡Reclamar!" ───────────────────────────────────────
class _CtaButton extends StatefulWidget {
  const _CtaButton({
    required this.label,
    required this.green,
    required this.busy,
    required this.onTap,
  });
  final String label;
  final bool green;
  final bool busy;
  final VoidCallback? onTap;

  @override
  State<_CtaButton> createState() => _CtaButtonState();
}

class _CtaButtonState extends State<_CtaButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.of(context).disableAnimations;
    final enabled = widget.onTap != null && !widget.busy;
    final depth = widget.green ? AppColors.successDark : AppColors.goldCtaDepth;
    return Opacity(
      opacity: enabled ? 1 : 0.7,
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: () => setState(() => _pressed = false),
        onTap: enabled ? widget.onTap : null,
        child: AnimatedContainer(
          duration: reduce ? Duration.zero : const Duration(milliseconds: 70),
          transform: Matrix4.translationValues(0, _pressed ? 4 : 0, 0),
          width: double.infinity,
          height: 62,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.green
                  ? const [Color(0xFF3FD97E), AppColors.success]
                  : const [AppColors.goldCtaTop, AppColors.goldCtaBottom],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(color: depth, offset: Offset(0, _pressed ? 2 : 6), blurRadius: 0),
              BoxShadow(
                  color: (widget.green ? AppColors.success : AppColors.goldCtaBottom)
                      .withValues(alpha: 0.42),
                  offset: const Offset(0, 14),
                  blurRadius: 24),
            ],
          ),
          child: widget.busy
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.6, color: Colors.white))
              : Text(widget.label,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: widget.green ? Colors.white : const Color(0xFF5B3A00))),
        ),
      ),
    );
  }
}

// ── Painters ─────────────────────────────────────────────────────────────────
class _SparklesPainter extends CustomPainter {
  _SparklesPainter(this.t);
  final double t;
  static const _stars = [
    (0.13, 0.16, 0.0),
    (0.82, 0.20, 0.5),
    (0.16, 0.40, 0.9),
    (0.85, 0.44, 0.3),
    (0.5, 0.10, 0.7),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (final (fx, fy, ph) in _stars) {
      final tw = (math.sin((t + ph) * 2 * math.pi) * 0.5 + 0.5);
      final p = Paint()..color = const Color(0xFFFFD86B).withValues(alpha: 0.2 + 0.8 * tw);
      _star(canvas, Offset(fx * size.width, fy * size.height), 4 + 3 * tw, p);
    }
  }

  void _star(Canvas canvas, Offset c, double r, Paint paint) {
    final path = Path();
    for (var i = 0; i < 8; i++) {
      final rr = i.isEven ? r : r * 0.4;
      final a = -math.pi / 2 + i * math.pi / 4;
      final p = Offset(c.dx + rr * math.cos(a), c.dy + rr * math.sin(a));
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path..close(), paint);
  }

  @override
  bool shouldRepaint(covariant _SparklesPainter old) => old.t != t;
}

class _RaysPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final paint = Paint()..color = const Color(0xFFFFDD7A).withValues(alpha: 0.22);
    const n = 12;
    for (var i = 0; i < n; i++) {
      final a = i * 2 * math.pi / n;
      final path = Path()
        ..moveTo(c.dx, c.dy)
        ..lineTo(c.dx + size.width * math.cos(a - 0.12), c.dy + size.width * math.sin(a - 0.12))
        ..lineTo(c.dx + size.width * math.cos(a + 0.12), c.dy + size.width * math.sin(a + 0.12))
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RaysPainter old) => false;
}

class _BeamPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final path = Path()
      ..moveTo(w * 0.1, 0)
      ..lineTo(w * 0.9, 0)
      ..lineTo(w * 0.62, h)
      ..lineTo(w * 0.38, h)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xD9FFF3C8), Color(0x00FFC93C)],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );
  }

  @override
  bool shouldRepaint(covariant _BeamPainter old) => false;
}

class _MedalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    canvas.drawCircle(c, r * 0.84, Paint()..color = AppColors.goldDark);
    canvas.drawCircle(
      c,
      r * 0.73,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFDD7A), AppColors.goldCtaBottom],
        ).createShader(Rect.fromCircle(center: c, radius: r * 0.73)),
    );
    canvas.drawCircle(c, r * 0.56, Paint()..color = const Color(0xFFFFE08A));
    // Estrella.
    final star = Path();
    for (var i = 0; i < 10; i++) {
      final rr = i.isEven ? r * 0.42 : r * 0.17;
      final a = -math.pi / 2 + i * math.pi / 5;
      final p = Offset(c.dx + rr * math.cos(a), c.dy + rr * math.sin(a));
      i == 0 ? star.moveTo(p.dx, p.dy) : star.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(star..close(), Paint()..color = AppColors.goldDark);
  }

  @override
  bool shouldRepaint(covariant _MedalPainter old) => false;
}

class _ClosedChestPainter extends CustomPainter {
  _ClosedChestPainter({this.locked = false});
  final bool locked;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final body = locked ? const Color(0xFF8A90A8) : AppColors.primary;
    final lid = locked ? const Color(0xFFAAB1C6) : const Color(0xFF8273E8);
    final strap = locked ? const Color(0xFFD6DAE7) : AppColors.gold;
    // Sombra.
    canvas.drawOval(
        Rect.fromCenter(center: Offset(w / 2, 142), width: 124, height: 18),
        Paint()..color = Colors.black.withValues(alpha: 0.18));
    // Cuerpo.
    canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(28, 70, 120, 64), const Radius.circular(12)),
        Paint()..color = body);
    canvas.drawRect(const Rect.fromLTWH(28, 70, 120, 20),
        Paint()..color = locked ? const Color(0xFF7A8098) : const Color(0xFF5E51C9));
    // Tapa (arco).
    final lidPath = Path()
      ..moveTo(28, 72)
      ..quadraticBezierTo(28, 34, 88, 34)
      ..quadraticBezierTo(148, 34, 148, 72)
      ..lineTo(148, 78)
      ..lineTo(28, 78)
      ..close();
    canvas.drawPath(lidPath, Paint()..color = lid);
    canvas.drawPath(
      Path()
        ..moveTo(28, 72)
        ..quadraticBezierTo(28, 34, 88, 34)
        ..quadraticBezierTo(148, 34, 148, 72),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..color = strap,
    );
    // Correas.
    canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(40, 40, 11, 94), const Radius.circular(3)),
        Paint()..color = strap);
    canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(125, 40, 11, 94), const Radius.circular(3)),
        Paint()..color = strap);
    canvas.drawRect(const Rect.fromLTWH(28, 86, 120, 9), Paint()..color = strap);
    // Candado.
    canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(76, 82, 24, 26), const Radius.circular(6)),
        Paint()..color = const Color(0xFFFFD86B));
    // Gema.
    final gem = Path()
      ..moveTo(88, 44)
      ..lineTo(94, 50)
      ..lineTo(88, 57)
      ..lineTo(82, 50)
      ..close();
    canvas.drawPath(gem, Paint()..color = locked ? const Color(0xFF9AA0BC) : AppColors.coral);
  }

  @override
  bool shouldRepaint(covariant _ClosedChestPainter old) => old.locked != locked;
}

class _OpenChestPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    // Sombra.
    canvas.drawOval(
        Rect.fromCenter(center: Offset(w / 2, 112), width: 124, height: 18),
        Paint()..color = Colors.black.withValues(alpha: 0.18));
    // Tapa abierta (inclinada atrás).
    canvas.save();
    canvas.translate(88, 34);
    canvas.rotate(-0.21);
    canvas.translate(-88, -34);
    final lidPath = Path()
      ..moveTo(30, 34)
      ..quadraticBezierTo(30, -2, 88, -2)
      ..quadraticBezierTo(146, -2, 146, 34)
      ..lineTo(146, 40)
      ..lineTo(30, 40)
      ..close();
    canvas.drawPath(lidPath, Paint()..color = const Color(0xFF8273E8));
    canvas.drawPath(
      Path()
        ..moveTo(30, 34)
        ..quadraticBezierTo(30, -2, 88, -2)
        ..quadraticBezierTo(146, -2, 146, 34),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..color = AppColors.gold,
    );
    canvas.restore();
    // Borde trasero + brillo interior.
    canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(28, 40, 120, 20), const Radius.circular(6)),
        Paint()..color = const Color(0xFF5E51C9));
    canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(34, 44, 108, 16), const Radius.circular(4)),
        Paint()..color = const Color(0xFFFFE08A));
    // Cuerpo frontal.
    canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(28, 56, 120, 58), const Radius.circular(12)),
        Paint()..color = AppColors.primary);
    canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(40, 56, 11, 58), const Radius.circular(3)),
        Paint()..color = AppColors.gold);
    canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(125, 56, 11, 58), const Radius.circular(3)),
        Paint()..color = AppColors.gold);
    canvas.drawRect(const Rect.fromLTWH(28, 78, 120, 9), Paint()..color = AppColors.gold);
    canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(76, 74, 24, 22), const Radius.circular(6)),
        Paint()..color = const Color(0xFFFFD86B));
    // Monedas.
    void coin(double cx, double cy, double r) {
      canvas.drawCircle(Offset(cx, cy), r, Paint()..color = const Color(0xFFFFE08A));
      canvas.drawCircle(
          Offset(cx, cy),
          r,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = AppColors.goldDark);
    }

    coin(66, 54, 8);
    coin(88, 50, 9);
    coin(110, 54, 8);
  }

  @override
  bool shouldRepaint(covariant _OpenChestPainter old) => false;
}
