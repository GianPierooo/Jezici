import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Estados de ánimo del guacamayo (GA8): reacciona al contexto.
enum MascotMood { idle, celebrate, encourage }

/// Matix, el guacamayo escarlata de Jezici (Sistema_Diseno §1) — el diferenciador
/// de marca. Dibujado como VECTOR propio (`ParrotArt`, CustomPaint) replicando el
/// SVG de los mockups (Aprender/Leccion/Perfil/Onboarding): cuerpo/cabeza escarlata,
/// ala y cola dorado-naranja, cresta, cara crema, pico dorado. Sin assets externos
/// ni paquetes (CSP-safe, cero peso de red). Aquí va la versión ANIMADA con globo:
/// idle = bob suave; celebrate = brinco + escala; encourage = asentimiento.
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
    final art = ParrotArt(size: widget.size);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.message != null) _SpeechBubble(message: widget.message!),
        if (_reduceMotion)
          art
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
            child: art,
          ),
      ],
    );
  }
}

/// Globo de diálogo blanco (estilo mockup): texto oscuro, sombra suave, cola.
class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      constraints: const BoxConstraints(maxWidth: 240),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFECEDF6), width: 1.4),
        boxShadow: const [
          BoxShadow(color: Color(0x143C3778), offset: Offset(0, 6), blurRadius: 14),
        ],
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
            color: AppColors.text, fontWeight: FontWeight.w800, fontSize: 12, height: 1.25),
      ),
    );
  }
}

/// El guacamayo escarlata como VECTOR estático (sin animación ni controller) —
/// reutilizable en superficies pequeñas/inline (banners, listas, estados vacíos)
/// y como cuerpo de `ParrotMascot`. Replica el SVG de los mockups (viewBox 84×90).
class ParrotArt extends StatelessWidget {
  const ParrotArt({super.key, this.size = 56});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 84 / 90,
      height: size,
      child: CustomPaint(painter: _ParrotPainter()),
    );
  }
}

/// Pinta el guacamayo escarlata portando 1:1 los paths del SVG de los mockups
/// (Ajustes/Leccion, viewBox 0 0 84 90). Orden de atrás→adelante.
class _ParrotPainter extends CustomPainter {
  // Paleta del mockup (guacamayo escarlata).
  static const _tailOrange = Color(0xFFFF7A00);
  static const _tailYellow = Color(0xFFFFC93C);
  static const _bodyRed = Color(0xFFFF4D6D);
  static const _belly = Color(0xFFFFE3E8);
  static const _wing = Color(0xFFFFC93C);
  static const _headRed = Color(0xFFFF6B6B);
  static const _face = Color(0xFFFFF4E8);
  static const _crest1 = Color(0xFFFF6B6B);
  static const _crest2 = Color(0xFFFF8585);
  static const _pupil = Color(0xFF1A1A2E);
  static const _beak = Color(0xFFFFC93C);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 84);
    final p = Paint()..isAntiAlias = true;

    void fill(Color c, void Function(Path) build) {
      final path = Path();
      build(path);
      canvas.drawPath(path, p..color = c);
    }

    // Cola (dos plumas): naranja + dorada.
    fill(_tailOrange, (pt) {
      pt.moveTo(28, 58);
      pt.relativeQuadraticBezierTo(-7, 18, -3, 26);
      pt.relativeQuadraticBezierTo(7, -5, 12, -18);
      pt.close();
    });
    fill(_tailYellow, (pt) {
      pt.moveTo(40, 60);
      pt.relativeQuadraticBezierTo(-1, 19, 4, 26);
      pt.relativeQuadraticBezierTo(7, -7, 7, -20);
      pt.close();
    });

    // Cuerpo + vientre.
    canvas.drawOval(
        Rect.fromCenter(center: const Offset(46, 52), width: 46, height: 50), p..color = _bodyRed);
    canvas.drawOval(
        Rect.fromCenter(center: const Offset(50, 56), width: 26, height: 34), p..color = _belly);

    // Ala.
    fill(_wing, (pt) {
      pt.moveTo(30, 46);
      pt.relativeQuadraticBezierTo(-9, 8, -5, 24);
      pt.relativeQuadraticBezierTo(13, 3, 18, -10);
      pt.relativeQuadraticBezierTo(-4, -12, -13, -14);
      pt.close();
    });

    // Cabeza + cara.
    canvas.drawCircle(const Offset(40, 28), 20, p..color = _headRed);
    canvas.drawOval(
        Rect.fromCenter(center: const Offset(45, 30), width: 26, height: 24), p..color = _face);

    // Cresta (dos plumas).
    fill(_crest1, (pt) {
      pt.moveTo(33, 11);
      pt.relativeQuadraticBezierTo(-3, -9, 4, -9);
      pt.relativeQuadraticBezierTo(3, 4, 1, 9);
      pt.close();
    });
    fill(_crest2, (pt) {
      pt.moveTo(41, 8);
      pt.relativeQuadraticBezierTo(1, -8, 7, -6);
      pt.relativeQuadraticBezierTo(0, 5, -3, 9);
      pt.close();
    });

    // Ojo (blanco + pupila + brillo).
    canvas.drawCircle(const Offset(43, 27), 6.2, p..color = Colors.white);
    canvas.drawCircle(const Offset(44.5, 28), 3.3, p..color = _pupil);
    canvas.drawCircle(const Offset(46, 26.6), 1.1, p..color = Colors.white);

    // Pico.
    fill(_beak, (pt) {
      pt.moveTo(57, 30);
      pt.relativeQuadraticBezierTo(11, 1, 10, 8);
      pt.relativeQuadraticBezierTo(-6, 4, -11, -1);
      pt.close();
    });

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ParrotPainter oldDelegate) => false;
}

/// Painter del guacamayo expuesto para generar los íconos de la PWA
/// (test/_gen_icons_test.dart → render a PNG). No se usa en runtime.
CustomPainter parrotPainterForIcons() => _ParrotPainter();
