import 'package:flutter/material.dart';

/// Avatar generado (sin assets): cuadro redondeado con gradiente del color
/// elegido + inicial del nombre. Cohesivo con la marca (relieve suave).
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.initial,
    required this.colorHex,
    this.size = 60,
    this.selected = false,
  });

  final String initial;
  final String colorHex;
  final double size;
  final bool selected;

  static Color parseHex(String hex) {
    var h = hex.replaceAll('#', '').trim();
    if (h.length == 6) h = 'FF$h';
    return Color(int.tryParse(h, radix: 16) ?? 0xFF6C5CE7);
  }

  static Color _lighten(Color c, [double amt = 0.18]) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness + amt).clamp(0.0, 1.0)).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final base = parseHex(colorHex);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_lighten(base), base],
        ),
        borderRadius: BorderRadius.circular(size * 0.3),
        border: selected ? Border.all(color: Colors.white, width: 3) : null,
        boxShadow: [
          BoxShadow(
            color: base.withValues(alpha: 0.35),
            offset: const Offset(0, 6),
            blurRadius: 14,
          ),
        ],
      ),
      child: Text(
        initial,
        style: TextStyle(
          fontSize: size * 0.42,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          height: 1,
        ),
      ),
    );
  }
}
