import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/skills.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/progress_models.dart';

/// Radar de las 4 habilidades (GA4 · B3, diferenciador; Perfil.dc). Eje por
/// habilidad (reading arriba, listening derecha, writing abajo, speaking
/// izquierda), anillos por nivel CEFR, **anillo de META punteado + tag
/// "META X"**, polígono del usuario y **vértices coloreados** (coral = por
/// debajo de la meta, violeta = en meta o superior). Hace VISIBLE el desbalance.
class SkillRadar extends StatelessWidget {
  const SkillRadar({
    super.key,
    required this.skills,
    this.goalLevel = 'B1',
    this.size = 240,
    this.masteryPct,
    this.labels,
    this.goalTag,
  });

  final List<SkillLevel> skills;
  final String goalLevel;
  final double size;

  /// Dominio 0..1 por habilidad (modelo D6). Si se provee, el polígono usa
  /// rango_CEFR + dominio (en vez de los puntos del modelo viejo).
  final Map<String, double>? masteryPct;

  /// Nombres LOCALIZADOS de las habilidades en orden [kSkillOrder]
  /// (fix i18n: antes salían siempre en español vía kSkillEs).
  final List<String>? labels;

  /// Texto del tag de meta (p. ej. "META B1", localizado). null = sin tag.
  final String? goalTag;

  @override
  Widget build(BuildContext context) {
    final bySkill = {for (final s in skills) s.skill: s};
    final scores = [
      for (final k in kSkillOrder)
        if (masteryPct != null)
          (kCefrRank[bySkill[k]?.cefrLevel ?? 'A1'] ?? 0) + (masteryPct![k] ?? 0).clamp(0.0, 1.0)
        else
          skillScore(bySkill[k]?.cefrLevel ?? 'A1', bySkill[k]?.progressPoints ?? 0),
    ];
    final levels = [for (final k in kSkillOrder) bySkill[k]?.cefrLevel ?? 'A1'];
    final goalRank = kCefrRank[goalLevel] ?? 2;
    // Vértice coral cuando la habilidad está por DEBAJO de la meta.
    final vertexBelow = [
      for (final k in kSkillOrder) (kCefrRank[bySkill[k]?.cefrLevel ?? 'A1'] ?? 0) < goalRank,
    ];
    final maxScale = math.max(
      goalRank + 1.0,
      (scores.isEmpty ? 1.0 : scores.reduce(math.max)) + 0.5,
    ).clamp(2.0, 6.0);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RadarPainter(
          scores: scores,
          levels: levels,
          maxScale: maxScale.toDouble(),
          goalRank: goalRank.toDouble(),
          vertexBelow: vertexBelow,
          labels: labels ?? [for (final k in kSkillOrder) kSkillEs[k] ?? k],
          goalTag: goalTag,
        ),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter({
    required this.scores,
    required this.levels,
    required this.maxScale,
    required this.goalRank,
    required this.vertexBelow,
    required this.labels,
    required this.goalTag,
  });
  final List<double> scores;
  final List<String> levels;
  final double maxScale;
  final double goalRank;
  final List<bool> vertexBelow;
  final List<String> labels;
  final String? goalTag;

  // reading=arriba, listening=derecha, writing=abajo, speaking=izquierda.
  static const _angles = [-math.pi / 2, 0.0, math.pi / 2, math.pi];

  Path _ringPath(Offset c, double r, double f) {
    final path = Path();
    for (var i = 0; i < 4; i++) {
      final p = c + Offset(math.cos(_angles[i]), math.sin(_angles[i])) * (r * f);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    return path..close();
  }

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
      canvas.drawPath(_ringPath(c, r, f), grid);
    }

    // Ejes.
    for (var i = 0; i < 4; i++) {
      final p = c + Offset(math.cos(_angles[i]), math.sin(_angles[i])) * r;
      canvas.drawLine(c, p, grid);
    }

    // Anillo de META punteado (Perfil.dc): nivel meta alcanzado = certificas.
    final goalF = ((goalRank + 1) / maxScale).clamp(0.0, 1.0);
    final goalPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = AppColors.primary.withValues(alpha: 0.75);
    final goalPath = _ringPath(c, r, goalF);
    // Punteado manual (dash 5/5) sobre el path.
    for (final metric in goalPath.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        final seg = metric.extractPath(d, math.min(d + 5, metric.length));
        canvas.drawPath(seg, goalPaint);
        d += 10;
      }
    }

    // Polígono del usuario.
    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = AppColors.primary.withValues(alpha: 0.16);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = AppColors.primary;
    final poly = Path();
    final pts = <Offset>[];
    for (var i = 0; i < 4; i++) {
      final f = (scores[i] / maxScale).clamp(0.0, 1.0);
      final p = c + Offset(math.cos(_angles[i]), math.sin(_angles[i])) * (r * f);
      pts.add(p);
      i == 0 ? poly.moveTo(p.dx, p.dy) : poly.lineTo(p.dx, p.dy);
    }
    poly.close();
    canvas.drawPath(poly, fill);
    canvas.drawPath(poly, stroke);
    // Vértices con halo blanco, coloreados por estado (débil=coral).
    for (var i = 0; i < 4; i++) {
      final color = vertexBelow[i] ? AppColors.coral : AppColors.primary;
      canvas.drawCircle(pts[i], 5.5, Paint()..color = Colors.white);
      canvas.drawCircle(pts[i], 4, Paint()..color = color);
    }

    // Tag "META X" junto al anillo de meta (arriba-derecha).
    if (goalTag != null) {
      final tagPos = c + Offset(r * goalF * 0.42, -r * goalF * 0.86);
      final tp = TextPainter(
        text: TextSpan(
          text: goalTag,
          style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: Colors.white),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: tagPos, width: tp.width + 14, height: tp.height + 6),
        const Radius.circular(8),
      );
      canvas.drawRRect(rect, Paint()..color = AppColors.primary);
      tp.paint(canvas, Offset(rect.left + 7, rect.top + 3));
    }

    // Etiquetas (habilidad + nivel) en cada eje, con badge de nivel coloreado.
    for (var i = 0; i < 4; i++) {
      final dir = Offset(math.cos(_angles[i]), math.sin(_angles[i]));
      final base = c + dir * (r + 5);
      _label(canvas, labels[i], levels[i],
          vertexBelow[i] ? AppColors.coral : AppColors.primary, base, dir);
    }
  }

  void _label(Canvas canvas, String name, String level, Color badge, Offset anchor, Offset dir) {
    final nameTp = TextPainter(
      text: TextSpan(
        text: name,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.text),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 84);
    final lvlTp = TextPainter(
      text: TextSpan(
        text: level,
        style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: Colors.white),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final blockW = math.max(nameTp.width, lvlTp.width + 14);
    final blockH = nameTp.height + lvlTp.height + 8;

    var dx = anchor.dx - blockW / 2;
    var dy = anchor.dy - blockH / 2;
    if (dir.dx > 0.5) dx = anchor.dx; // derecha
    if (dir.dx < -0.5) dx = anchor.dx - blockW; // izquierda
    if (dir.dy > 0.5) dy = anchor.dy; // abajo
    if (dir.dy < -0.5) dy = anchor.dy - blockH; // arriba

    nameTp.paint(canvas, Offset(dx + (blockW - nameTp.width) / 2, dy));
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(dx + (blockW - lvlTp.width - 14) / 2, dy + nameTp.height + 3,
          lvlTp.width + 14, lvlTp.height + 4),
      const Radius.circular(7),
    );
    canvas.drawRRect(rect, Paint()..color = badge);
    lvlTp.paint(canvas, Offset(rect.left + 7, rect.top + 2));
  }

  @override
  bool shouldRepaint(covariant _RadarPainter old) =>
      old.scores != scores ||
      old.levels != levels ||
      old.maxScale != maxScale ||
      old.goalTag != goalTag ||
      old.labels != labels;
}
