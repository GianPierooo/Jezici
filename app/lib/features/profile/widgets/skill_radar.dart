import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/skills.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/progress_models.dart';

/// Radar de las 4 habilidades (GA4 · B3, diferenciador). Eje por habilidad
/// (reading arriba, listening derecha, writing abajo, speaking izquierda),
/// anillos por nivel CEFR y el polígono del usuario. Hace VISIBLE el desbalance.
class SkillRadar extends StatelessWidget {
  const SkillRadar({super.key, required this.skills, this.goalLevel = 'B1', this.size = 240});

  final List<SkillLevel> skills;
  final String goalLevel;
  final double size;

  @override
  Widget build(BuildContext context) {
    final bySkill = {for (final s in skills) s.skill: s};
    final scores = [
      for (final k in kSkillOrder)
        skillScore(bySkill[k]?.cefrLevel ?? 'A1', bySkill[k]?.progressPoints ?? 0),
    ];
    final levels = [for (final k in kSkillOrder) bySkill[k]?.cefrLevel ?? 'A1'];
    final maxScale = math.max(
      (kCefrRank[goalLevel] ?? 2) + 1.0,
      (scores.isEmpty ? 1.0 : scores.reduce(math.max)) + 0.5,
    ).clamp(2.0, 6.0);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RadarPainter(scores: scores, levels: levels, maxScale: maxScale.toDouble()),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter({required this.scores, required this.levels, required this.maxScale});
  final List<double> scores;
  final List<String> levels;
  final double maxScale;

  // reading=arriba, listening=derecha, writing=abajo, speaking=izquierda.
  static const _angles = [-math.pi / 2, 0.0, math.pi / 2, math.pi];

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = math.min(size.width, size.height) / 2 - 42;

    final grid = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFFE2DEF8);

    // Anillos por nivel CEFR (1..maxScale).
    for (var lvl = 1; lvl <= maxScale.ceil(); lvl++) {
      final f = (lvl / maxScale).clamp(0.0, 1.0);
      final path = Path();
      for (var i = 0; i < 4; i++) {
        final p = c + Offset(math.cos(_angles[i]), math.sin(_angles[i])) * (r * f);
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      path.close();
      canvas.drawPath(path, grid);
    }

    // Ejes.
    for (var i = 0; i < 4; i++) {
      final p = c + Offset(math.cos(_angles[i]), math.sin(_angles[i])) * r;
      canvas.drawLine(c, p, grid);
    }

    // Polígono del usuario.
    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = AppColors.primary.withValues(alpha: 0.20);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = AppColors.primary;
    final dot = Paint()..color = AppColors.primary;
    final poly = Path();
    final pts = <Offset>[];
    for (var i = 0; i < 4; i++) {
      final f = (scores[i] / maxScale).clamp(0.0, 1.0);
      final p = c + Offset(math.cos(_angles[i]), math.sin(_angles[i])) * (r * f);
      pts.add(p);
      if (i == 0) {
        poly.moveTo(p.dx, p.dy);
      } else {
        poly.lineTo(p.dx, p.dy);
      }
    }
    poly.close();
    canvas.drawPath(poly, fill);
    canvas.drawPath(poly, stroke);
    for (final p in pts) {
      canvas.drawCircle(p, 4, dot);
    }

    // Etiquetas (habilidad + nivel) en cada eje.
    for (var i = 0; i < 4; i++) {
      final dir = Offset(math.cos(_angles[i]), math.sin(_angles[i]));
      final base = c + dir * (r + 4);
      final label = kSkillEs[kSkillOrder[i]] ?? kSkillOrder[i];
      _text(canvas, '$label\n${levels[i]}', base, dir);
    }
  }

  void _text(Canvas canvas, String s, Offset anchor, Offset dir) {
    final tp = TextPainter(
      text: TextSpan(
        text: s,
        style: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.text, height: 1.15),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 80);
    // Alinea el bloque según la dirección del eje.
    var dx = anchor.dx - tp.width / 2;
    var dy = anchor.dy - tp.height / 2;
    if (dir.dx > 0.5) dx = anchor.dx; // derecha
    if (dir.dx < -0.5) dx = anchor.dx - tp.width; // izquierda
    if (dir.dy > 0.5) dy = anchor.dy; // abajo
    if (dir.dy < -0.5) dy = anchor.dy - tp.height; // arriba
    tp.paint(canvas, Offset(dx, dy));
  }

  @override
  bool shouldRepaint(covariant _RadarPainter old) =>
      old.scores != scores || old.levels != levels || old.maxScale != maxScale;
}
