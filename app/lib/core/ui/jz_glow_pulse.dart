import 'package:flutter/material.dart';

/// Halo que "respira" detrás de un CTA de PREMIO para guiar la atención hacia la
/// acción principal (jzGlow del mockup) SIN entorpecer: pulso lento y suave.
/// Barato (un BoxShadow animado por opacidad/tamaño). Respeta reduce-motion
/// (halo fijo tenue). Envuelve el botón; no cambia su tamaño ni su tap.
class JzGlowPulse extends StatefulWidget {
  const JzGlowPulse({
    super.key,
    required this.child,
    this.color,
    this.borderRadius = const BorderRadius.all(Radius.circular(18)),
  });

  final Widget child;
  final Color? color;
  final BorderRadius borderRadius;

  @override
  State<JzGlowPulse> createState() => _JzGlowPulseState();
}

class _JzGlowPulseState extends State<JzGlowPulse> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1800));
  bool _reduce = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduce = MediaQuery.of(context).disableAnimations;
    if (_reduce) {
      if (_c.isAnimating) _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;
    if (_reduce) {
      return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius,
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.28), blurRadius: 20, spreadRadius: 1),
          ],
        ),
        child: widget.child,
      );
    }
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) {
        final t = _c.value; // 0..1
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.22 + 0.26 * t),
                blurRadius: 16 + 14 * t,
                spreadRadius: 1 + 2 * t,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
