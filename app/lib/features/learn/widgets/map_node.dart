import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/lesson_model.dart';

/// Estado de un nodo del mapa (deriva de user_lesson_progress en el paso E).
enum NodeState { available, locked, completed, mastered }

/// Nodo del mapa (Sistema_Diseno §5): hito con 4 estados + variantes por tipo
/// (lección / checkpoint / misión). Estilo "jugoso" con labio 3D inferior.
class MapNode extends StatefulWidget {
  const MapNode({
    super.key,
    required this.type,
    required this.state,
    this.onTap,
    this.size = 72,
    this.progress = 0,
  });

  final LessonType type;
  final NodeState state;
  final VoidCallback? onTap;
  final double size;

  /// Avance de la unidad (0..1) para el ANILLO del nodo disponible (Aprender.dc).
  final double progress;

  @override
  State<MapNode> createState() => _MapNodeState();
}

class _MapNodeState extends State<MapNode> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  bool _pressed = false;
  bool _reduceMotion = false;

  bool get _isAvailable => widget.state == NodeState.available;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Respeta "reducir movimiento": sin pulso; mostramos un aro fijo en su lugar.
    _reduceMotion = MediaQuery.of(context).disableAnimations;
    _reconcile();
  }

  void _reconcile() {
    if (_isAvailable && !_reduceMotion && !_pulse.isAnimating) {
      _pulse.repeat();
    } else if ((!_isAvailable || _reduceMotion) && _pulse.isAnimating) {
      _pulse.stop();
    }
  }

  @override
  void didUpdateWidget(covariant MapNode oldWidget) {
    super.didUpdateWidget(oldWidget);
    _reconcile();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  _NodeStyle get _style {
    final s = widget.state;
    if (s == NodeState.locked) {
      return const _NodeStyle(
        top: AppColors.locked,
        bottom: AppColors.lockedDark,
        depth: AppColors.lockedDark,
        icon: Icons.lock_rounded,
      );
    }
    if (s == NodeState.completed) {
      return const _NodeStyle(
        top: Color(0xFF3FD97E),
        bottom: AppColors.successDark,
        depth: AppColors.successDark,
        icon: Icons.check_rounded,
      );
    }
    if (s == NodeState.mastered) {
      return const _NodeStyle(
        top: Color(0xFFFFDD7A),
        bottom: Color(0xFFFFC02E),
        depth: AppColors.goldDark,
        icon: Icons.star_rounded,
      );
    }
    // available → estilo por tipo
    switch (widget.type) {
      case LessonType.checkpoint:
        return const _NodeStyle(
          top: AppColors.primaryLight,
          bottom: AppColors.primary,
          depth: AppColors.primaryDark,
          icon: Icons.sports_score_rounded,
        );
      case LessonType.mission:
        return const _NodeStyle(
          top: Color(0xFFFF8C8C),
          bottom: AppColors.coral,
          depth: AppColors.coralDark,
          // Distinto de "dominado" (estrella): la misión es el arranque del viaje.
          icon: Icons.rocket_launch_rounded,
        );
      case LessonType.lesson:
      case LessonType.unknown:
        return const _NodeStyle(
          top: AppColors.primaryLight,
          bottom: AppColors.primary,
          depth: AppColors.primaryDark,
          icon: Icons.play_arrow_rounded,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _style;
    final size = widget.size;
    final isMission = widget.type == LessonType.mission;
    final radius = isMission ? 22.0 : size / 2;
    final depth = _pressed ? 2.0 : 6.0;

    final body = AnimatedContainer(
      duration: const Duration(milliseconds: 70),
      transform: Matrix4.translationValues(0, _pressed ? 4 : 0, 0),
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [style.top, style.bottom],
        ),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(color: style.depth, offset: Offset(0, depth), blurRadius: 0),
          BoxShadow(
            color: style.bottom.withValues(alpha: 0.45),
            offset: const Offset(0, 12),
            blurRadius: 20,
          ),
        ],
      ),
      child: Icon(style.icon, color: Colors.white, size: size * 0.46),
    );

    return SizedBox(
      width: size * 1.5,
      height: size * 1.5,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Resplandor dorado de "boss" para el checkpoint (meta de región).
          if (widget.type == LessonType.checkpoint && widget.state != NodeState.locked)
            Container(
              width: size * 1.45,
              height: size * 1.45,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.gold.withValues(alpha: 0.6),
                  AppColors.gold.withValues(alpha: 0.0),
                ]),
              ),
            ),
          if (_isAvailable && _reduceMotion)
            // Aro fijo: marca el nodo disponible sin animación.
            Container(
              width: size * 1.22,
              height: size * 1.22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.coral.withValues(alpha: 0.55), width: 3),
              ),
            )
          else if (_isAvailable)
            AnimatedBuilder(
              animation: _pulse,
              builder: (context, _) {
                final t = _pulse.value;
                return Transform.scale(
                  scale: 0.85 + t * 0.7,
                  child: Opacity(
                    opacity: (1 - t) * 0.55,
                    child: Container(
                      width: size,
                      height: size,
                      decoration: const BoxDecoration(
                        color: AppColors.coral,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              },
            ),
          // Anillo de progreso de la unidad alrededor del nodo disponible.
          if (_isAvailable && widget.progress > 0)
            CustomPaint(
              size: Size(size * 1.16, size * 1.16),
              painter: _ProgressRing(widget.progress),
            ),
          GestureDetector(
            onTapDown: widget.onTap != null
                ? (_) => setState(() => _pressed = true)
                : null,
            onTapUp: widget.onTap != null
                ? (_) => setState(() => _pressed = false)
                : null,
            onTapCancel: () => setState(() => _pressed = false),
            onTap: widget.onTap,
            child: body,
          ),
          if (widget.state == NodeState.locked &&
              widget.type != LessonType.lesson)
            Positioned(
              right: size * 0.18,
              bottom: size * 0.18,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: AppColors.lockedDark,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_rounded, color: Colors.white, size: 13),
              ),
            ),
        ],
      ),
    );
  }
}

/// Anillo de progreso (pista blanca + arco coral) alrededor del nodo disponible.
class _ProgressRing extends CustomPainter {
  _ProgressRing(this.progress);
  final double progress; // 0..1

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 3;
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.7);
    canvas.drawCircle(c, r, track);
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..color = AppColors.coral;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -math.pi / 2,
      2 * math.pi * progress.clamp(0.0, 1.0),
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRing old) => old.progress != progress;
}

class _NodeStyle {
  const _NodeStyle({
    required this.top,
    required this.bottom,
    required this.depth,
    required this.icon,
  });
  final Color top;
  final Color bottom;
  final Color depth;
  final IconData icon;
}
