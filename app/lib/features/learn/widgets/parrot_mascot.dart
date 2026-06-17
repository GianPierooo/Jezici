import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Estados de ánimo del guacamayo (GA8): reacciona al contexto.
enum MascotMood { idle, celebrate, encourage }

/// Mascota: guacamayo escarlata (Sistema_Diseno §1), compañero que REACCIONA.
/// idle = bob suave (vivo); celebrate = brinco enérgico + escala; encourage =
/// asentimiento de ánimo. Representado con emoji animado (sin assets externos).
class ParrotMascot extends StatefulWidget {
  const ParrotMascot({super.key, this.message, this.size = 56, this.mood = MascotMood.idle});

  final String? message;
  final double size;
  final MascotMood mood;

  @override
  State<ParrotMascot> createState() => _ParrotMascotState();
}

class _ParrotMascotState extends State<ParrotMascot> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  bool _reduceMotion = false;

  Duration get _dur => switch (widget.mood) {
        MascotMood.celebrate => const Duration(milliseconds: 650),
        MascotMood.encourage => const Duration(milliseconds: 900),
        MascotMood.idle => const Duration(milliseconds: 3100),
      };

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: _dur);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Respeta "reducir movimiento" del sistema (a11y): sin bob ni brincos.
    _reduceMotion = MediaQuery.of(context).disableAnimations;
    _reconcile();
  }

  void _reconcile() {
    if (_reduceMotion) {
      if (_c.isAnimating) _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant ParrotMascot old) {
    super.didUpdateWidget(old);
    if (old.mood != widget.mood) {
      _c.duration = _dur;
      _c.reset();
      _reconcile();
    }
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
                BoxShadow(color: Colors.black.withValues(alpha: 0.22), offset: const Offset(0, 6), blurRadius: 12),
              ],
            ),
            child: Text(widget.message!,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11)),
          ),
        if (_reduceMotion)
          Text('🦜', style: TextStyle(fontSize: widget.size))
        else
        AnimatedBuilder(
          animation: _c,
          builder: (context, child) {
            final t = _c.value; // 0..1
            switch (widget.mood) {
              case MascotMood.celebrate:
                final s = math.sin(t * math.pi);
                return Transform.translate(
                  offset: Offset(0, -18 * s),
                  child: Transform.rotate(
                    angle: (t - 0.5) * 0.5,
                    child: Transform.scale(scale: 1 + 0.18 * s, child: child),
                  ),
                );
              case MascotMood.encourage:
                return Transform.translate(
                  offset: Offset(0, -5 * math.sin(t * math.pi)),
                  child: Transform.rotate(angle: (t - 0.5) * 0.22, child: child),
                );
              case MascotMood.idle:
                return Transform.translate(
                  offset: Offset(0, -9 * math.sin(t * math.pi)),
                  child: Transform.rotate(angle: (t - 0.5) * 0.10, child: child),
                );
            }
          },
          child: Text('🦜', style: TextStyle(fontSize: widget.size)),
        ),
      ],
    );
  }
}
