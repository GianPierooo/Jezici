import 'package:flutter/material.dart';

/// Paleta de Jezici (Sistema_Diseno.md §2). Semántica consistente:
/// violeta = marca/acción · coral = acento · dorado = oro/XP · verde = acierto
/// naranja = racha · rojo = vidas.
class AppColors {
  AppColors._();

  // Marca
  static const Color primary = Color(0xFF6C5CE7); // violeta eléctrico
  static const Color primaryDark = Color(0xFF4B3FC9); // "labio" 3D del botón
  static const Color primaryLight = Color(0xFF8A7BF6);

  // Acentos / semántica
  static const Color coral = Color(0xFFFF6B6B);
  static const Color coralDark = Color(0xFFD94545);
  static const Color gold = Color(0xFFFFC93C);
  static const Color goldDark = Color(0xFFE0980C);
  static const Color success = Color(0xFF2ECC71);
  static const Color successDark = Color(0xFF1E9B52);
  static const Color streak = Color(0xFFFF7A00); // fuego/racha
  static const Color hearts = Color(0xFFFF4D6D);

  // Superficies / texto
  static const Color background = Color(0xFFF5F6FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color text = Color(0xFF1A1A2E);
  static const Color textMuted = Color(0xFF7A809B);

  // Estados de nodo bloqueado
  static const Color locked = Color(0xFFC8CEDE);
  static const Color lockedDark = Color(0xFF98A0B8);

  // Navegación
  static const Color navInactive = Color(0xFFAEB3CC);
  static const Color navActiveBg = Color(0xFFEDEBFF);
}
