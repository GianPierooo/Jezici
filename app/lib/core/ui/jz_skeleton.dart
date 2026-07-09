import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Placeholder gris redondeado (un "hueso" del skeleton).
class JzSkeletonBox extends StatelessWidget {
  const JzSkeletonBox({super.key, this.width, this.height = 14, this.radius = 8, this.shape = BoxShape.rectangle});
  final double? width;
  final double height;
  final double radius;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: shape == BoxShape.circle ? height : width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE6E8F2),
        shape: shape,
        borderRadius: shape == BoxShape.rectangle ? BorderRadius.circular(radius) : null,
      ),
    );
  }
}

/// Envuelve un layout de [JzSkeletonBox] y le pasa una banda de luz en bucle.
/// Una sola animación para todo el subárbol (barato). Respeta reduce-motion
/// (muestra los huesos sin brillo). Da sensación de "cargando rápido" en vez de
/// un spinner pelado (mejora de PERCEPCIÓN, ver PERF_AUDIT P1-6).
class JzShimmer extends StatefulWidget {
  const JzShimmer({super.key, required this.child});
  final Widget child;

  @override
  State<JzShimmer> createState() => _JzShimmerState();
}

class _JzShimmerState extends State<JzShimmer> with SingleTickerProviderStateMixin {
  // Inicializado en initState (no `late final` perezoso): con reduce-motion el
  // build no lo toca y dispose lo inicializaba tarde → ancestor lookup en un
  // widget desactivado (assert en debug).
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduce) return widget.child;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final dx = bounds.width * (_c.value * 2 - 1);
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [Color(0x00FFFFFF), Color(0x66FFFFFF), Color(0x00FFFFFF)],
              stops: const [0.35, 0.5, 0.65],
              transform: _SlideGradient(dx),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlideGradient extends GradientTransform {
  const _SlideGradient(this.dx);
  final double dx;
  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) => Matrix4.translationValues(dx, 0, 0);
}

/// Skeleton de una lista (filas con avatar + barra). Para Ligas/Tablas/listas.
class JzListSkeleton extends StatelessWidget {
  const JzListSkeleton({super.key, this.rows = 6, this.padding = const EdgeInsets.fromLTRB(20, 8, 20, 20)});
  final int rows;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    // Column (no ListView) para poder anidarse dentro de otro scrollable sin
    // "unbounded height". Quien necesite scroll/refresh lo envuelve en ListView.
    return JzShimmer(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const JzSkeletonBox(height: 86, radius: 22),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18)),
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  for (var i = 0; i < rows; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      child: Row(
                        children: [
                          const JzSkeletonBox(height: 34, shape: BoxShape.circle),
                          const SizedBox(width: 12),
                          Expanded(child: JzSkeletonBox(height: 13, width: (i.isEven ? 160 : 120).toDouble())),
                          const SizedBox(width: 12),
                          const JzSkeletonBox(height: 13, width: 44),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
