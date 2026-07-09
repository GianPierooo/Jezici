import 'package:flutter/material.dart';

/// Brillo/"sheen" del mockup (jzSheen): un destello diagonal que barre de vez en
/// cuando un elemento DORADO/premio (sello del certificado, badge "EXAMEN
/// SUPERADO", CTA dorado, emblema de liga, badge premium). Sutil y RÁPIDO: barrido
/// de ~700ms y luego pausa larga → llama la atención sin marear ni entorpecer.
/// Barato (un gradiente translúcido con Transform, clipado al hijo). Respeta
/// reduce-motion (sin barrido; pinta el hijo tal cual).
class JzSheen extends StatefulWidget {
  const JzSheen({
    super.key,
    required this.child,
    this.borderRadius = BorderRadius.zero,
    this.period = const Duration(milliseconds: 3200),
    this.intensity = 0.45,
  });

  final Widget child;
  final BorderRadius borderRadius;

  /// Ciclo completo (barrido + pausa). El barrido ocupa ~22% del ciclo.
  final Duration period;

  /// Opacidad máxima del destello blanco (0..1).
  final double intensity;

  @override
  State<JzSheen> createState() => _JzSheenState();
}

class _JzSheenState extends State<JzSheen> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.period);
  bool _reduce = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduce = MediaQuery.of(context).disableAnimations;
    if (_reduce) {
      if (_c.isAnimating) _c.stop();
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
    if (_reduce) {
      return ClipRRect(borderRadius: widget.borderRadius, child: widget.child);
    }
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: Stack(
        children: [
          widget.child,
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _c,
                builder: (_, _) {
                  // Barrido solo en el primer ~22% del ciclo; el resto, fuera.
                  final p = (_c.value / 0.22).clamp(0.0, 1.0);
                  return FractionalTranslation(
                    translation: Offset(-1.15 + p * 2.3, 0),
                    child: Transform.rotate(
                      angle: -0.32,
                      child: Transform.scale(
                        scaleY: 1.6,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.white.withValues(alpha: 0),
                                Colors.white.withValues(alpha: 0),
                                Colors.white.withValues(alpha: widget.intensity),
                                Colors.white.withValues(alpha: 0),
                                Colors.white.withValues(alpha: 0),
                              ],
                              stops: const [0.0, 0.40, 0.5, 0.60, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
