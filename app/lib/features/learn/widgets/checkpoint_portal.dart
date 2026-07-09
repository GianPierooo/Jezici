import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'map_node.dart' show NodeState;

/// Nodo de EXAMEN de nivel como PORTAL/arco (Aprender.dc): pilares violeta, arco,
/// interior dorado brillante y estrella-llave — distinto de una lección normal.
/// Respeta el ESTADO (bloqueado hasta ≥80% de dominio, igual que ya funciona):
/// locked = gris apagado + candado; disponible/dominado = violeta + oro con halo
/// pulsante (reduce-motion-aware). No cambia ninguna lógica: solo dispara onTap.
class CheckpointPortal extends StatefulWidget {
  const CheckpointPortal({
    super.key,
    required this.state,
    this.onTap,
    this.width = 104,
  });

  final NodeState state;
  final VoidCallback? onTap;
  final double width;

  @override
  State<CheckpointPortal> createState() => _CheckpointPortalState();
}

class _CheckpointPortalState extends State<CheckpointPortal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glow;
  bool _pressed = false;
  bool _reduceMotion = false;

  bool get _locked => widget.state == NodeState.locked;

  @override
  void initState() {
    super.initState();
    _glow = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.of(context).disableAnimations;
    _reconcile();
  }

  void _reconcile() {
    if (!_locked && !_reduceMotion && !_glow.isAnimating) {
      _glow.repeat(reverse: true);
    } else if ((_locked || _reduceMotion) && _glow.isAnimating) {
      _glow.stop();
    }
  }

  @override
  void didUpdateWidget(covariant CheckpointPortal old) {
    super.didUpdateWidget(old);
    _reconcile();
  }

  @override
  void dispose() {
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.width;
    final h = w * 118 / 128; // proporción del viewBox del mockup
    final box = w * 1.5;

    return SizedBox(
      width: box,
      height: box,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Halo dorado/violeta pulsante detrás del portal.
          if (!_locked)
            AnimatedBuilder(
              animation: _glow,
              builder: (_, _) {
                final t = _reduceMotion ? 0.5 : _glow.value;
                return Container(
                  width: box * (0.78 + 0.06 * t),
                  height: box * (0.78 + 0.06 * t),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      AppColors.gold.withValues(alpha: 0.28 + 0.30 * t),
                      AppColors.gold.withValues(alpha: 0.0),
                    ]),
                  ),
                );
              },
            ),
          GestureDetector(
            onTapDown: widget.onTap != null ? (_) => setState(() => _pressed = true) : null,
            onTapUp: widget.onTap != null ? (_) => setState(() => _pressed = false) : null,
            onTapCancel: () => setState(() => _pressed = false),
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 70),
              transform: Matrix4.translationValues(0, _pressed ? 3 : 0, 0),
              width: w,
              height: h,
              child: CustomPaint(painter: _PortalPainter(locked: _locked)),
            ),
          ),
          // Candado sobre el portal bloqueado.
          if (_locked)
            Positioned(
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppColors.lockedDark,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.lock_rounded, color: Colors.white, size: 18),
              ),
            ),
        ],
      ),
    );
  }
}

class _PortalPainter extends CustomPainter {
  _PortalPainter({required this.locked});
  final bool locked;

  // Paleta (mockup): violeta activo vs gris bloqueado.
  Color get _pillar => locked ? const Color(0xFFAEB5CB) : AppColors.primary;
  Color get _pillarHi => locked ? const Color(0xFFC8CEDE) : const Color(0xFF8979F0);
  Color get _baseDark => locked ? const Color(0xFF98A0B8) : const Color(0xFF5E51B8);
  Color get _baseTop => locked ? const Color(0xFFB4BBCE) : const Color(0xFF7A6BE0);

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 128.0; // escala desde el viewBox 128×118
    double x(double v) => v * k;
    double y(double v) => v * k;
    RRect rr(double l, double t, double r, double b, double rad) =>
        RRect.fromRectAndRadius(Rect.fromLTRB(x(l), y(t), x(r), y(b)), Radius.circular(rad * k));

    // Base.
    canvas.drawRRect(rr(14, 100, 114, 114, 5), Paint()..color = _baseDark);
    canvas.drawRRect(rr(10, 96, 118, 108, 5), Paint()..color = _baseTop);

    // Interior del portal (dorado brillante activo; gris apagado si bloqueado).
    final door = Path()
      ..moveTo(x(40), y(100))
      ..lineTo(x(40), y(56))
      ..quadraticBezierTo(x(64), y(30), x(88), y(56))
      ..lineTo(x(88), y(100))
      ..close();
    if (locked) {
      canvas.drawPath(door, Paint()..color = const Color(0xFFD3D8E6));
    } else {
      canvas.drawPath(
        door,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFE9A8), Color(0xFFFFC93C)],
          ).createShader(Rect.fromLTWH(x(40), y(30), x(48), y(70))),
      );
      // Brillo interior.
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x(64), y(74)), width: x(26), height: y(30)),
        Paint()..color = const Color(0xFFFFF3CC).withValues(alpha: 0.9),
      );
    }

    // Pilares + reflejo.
    canvas.drawRRect(rr(18, 34, 40, 102, 7), Paint()..color = _pillar);
    canvas.drawRRect(rr(88, 34, 110, 102, 7), Paint()..color = _pillar);
    canvas.drawRRect(rr(18, 34, 27, 102, 5), Paint()..color = _pillarHi);
    canvas.drawRRect(rr(88, 34, 97, 102, 5), Paint()..color = _pillarHi);

    // Arco superior (banda curva que une los pilares).
    final arch = Path()
      ..moveTo(x(18), y(44))
      ..quadraticBezierTo(x(64), y(4), x(110), y(44))
      ..lineTo(x(110), y(30))
      ..quadraticBezierTo(x(64), y(-6), x(18), y(30))
      ..close();
    canvas.drawPath(arch, Paint()..color = _pillar);
    final archHi = Path()
      ..moveTo(x(18), y(40))
      ..quadraticBezierTo(x(64), y(2), x(110), y(40))
      ..lineTo(x(110), y(33))
      ..quadraticBezierTo(x(64), y(-4), x(18), y(33))
      ..close();
    canvas.drawPath(archHi, Paint()..color = _pillarHi);

    // Estrella-llave sobre el arco.
    canvas.drawPath(
      _star(Offset(x(64), y(30)), x(11), x(4.6), 5),
      Paint()..color = locked ? const Color(0xFFC8CEDE) : const Color(0xFFFFD86B),
    );
  }

  Path _star(Offset c, double outer, double inner, int points) {
    final path = Path();
    for (var i = 0; i < points * 2; i++) {
      final r = i.isEven ? outer : inner;
      final a = -math.pi / 2 + i * math.pi / points;
      final p = Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a));
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    return path..close();
  }

  @override
  bool shouldRepaint(covariant _PortalPainter old) => old.locked != locked;
}
