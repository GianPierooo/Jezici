import 'package:flutter/material.dart';

/// Paleta y emblema por DIVISIÓN de liga (Ligas.dc). Antes el header pintaba un
/// gradiente bronce fijo sea cual sea la división real → ahora refleja la división
/// del usuario. Claves técnicas: bronce/plata/oro/zafiro/rubi/diamante.
class DivisionTheme {
  const DivisionTheme(this.start, this.end, this.shadow, this.icon);

  /// Gradiente del banner (topLeft → bottomRight).
  final Color start;
  final Color end;

  /// Color base de la sombra del banner.
  final Color shadow;

  /// Icono/emblema de la división.
  final IconData icon;

  static const _map = <String, DivisionTheme>{
    // Colores tomados de mockups/Ligas.dc (carrusel de divisiones).
    'bronce': DivisionTheme(Color(0xFFCD9B6A), Color(0xFFB07B45), Color(0xFFB07B45), Icons.emoji_events_rounded),
    'plata': DivisionTheme(Color(0xFFC7CEDA), Color(0xFF9AA4B6), Color(0xFF9AA4B6), Icons.emoji_events_rounded),
    'oro': DivisionTheme(Color(0xFFFFDD7A), Color(0xFFF4B400), Color(0xFFE89A12), Icons.emoji_events_rounded),
    'zafiro': DivisionTheme(Color(0xFF6FA8FF), Color(0xFF4A8CFF), Color(0xFF2F6FE0), Icons.workspace_premium_rounded),
    'rubi': DivisionTheme(Color(0xFFFF6B86), Color(0xFFFF4D6D), Color(0xFFE0556E), Icons.workspace_premium_rounded),
    'diamante': DivisionTheme(Color(0xFF8CE9E6), Color(0xFF3FC8D6), Color(0xFF2AAAB8), Icons.diamond_rounded),
  };

  static DivisionTheme of(String division) => _map[division] ?? _map['bronce']!;

  /// Escalera de divisiones en orden ascendente (espejo de jz_div_up/down).
  static const ladder = ['bronce', 'plata', 'oro', 'zafiro', 'rubi', 'diamante'];

  /// División a la que se ASCIENDE desde [division] (tope: diamante).
  static String up(String division) {
    final i = ladder.indexOf(division);
    return i < 0 ? division : ladder[(i + 1).clamp(0, ladder.length - 1)];
  }

  /// División a la que se DESCIENDE desde [division] (piso: bronce).
  static String down(String division) {
    final i = ladder.indexOf(division);
    return i < 0 ? division : ladder[(i - 1).clamp(0, ladder.length - 1)];
  }
}
