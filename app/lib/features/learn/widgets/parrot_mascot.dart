import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Mascota: guacamayo escarlata (Sistema_Diseno §1), compañero de viaje que
/// reacciona. En el paso C se representa con emoji + globo de ánimo y un
/// movimiento de "bob"; se puede reemplazar por una ilustración/Rive luego.
class ParrotMascot extends StatefulWidget {
  const ParrotMascot({super.key, this.message, this.size = 56});

  final String? message;
  final double size;

  @override
  State<ParrotMascot> createState() => _ParrotMascotState();
}

class _ParrotMascotState extends State<ParrotMascot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.message != null)
          Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.text,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  offset: const Offset(0, 6),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Text(
              widget.message!,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ),
        AnimatedBuilder(
          animation: _c,
          builder: (context, child) {
            final t = _c.value; // 0..1
            return Transform.translate(
              offset: Offset(0, -9 * math.sin(t * math.pi)),
              child: Transform.rotate(angle: (t - 0.5) * 0.10, child: child),
            );
          },
          child: Text('🦜', style: TextStyle(fontSize: widget.size)),
        ),
      ],
    );
  }
}
