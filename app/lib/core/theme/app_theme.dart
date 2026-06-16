import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

/// Tema de la app a partir de Sistema_Diseno.md: tipografía redondeada (Nunito),
/// esquinas generosas, fondo claro, color de marca violeta.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    final textTheme = GoogleFonts.nunitoTextTheme(base.textTheme).apply(
      bodyColor: AppColors.text,
      displayColor: AppColors.text,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.surface,
      ),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.text,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      splashFactory: InkRipple.splashFactory,
    );
  }

  // Estilos de texto reutilizables (peso fuerte en números/títulos de recompensa).
  static TextStyle display(Color color) =>
      GoogleFonts.nunito(fontSize: 30, fontWeight: FontWeight.w900, color: color);
  static TextStyle h1(Color color) =>
      GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w800, color: color);
  static TextStyle h2(Color color) =>
      GoogleFonts.nunito(fontSize: 17, fontWeight: FontWeight.w700, color: color);
  static TextStyle label(Color color) =>
      GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w900, color: color, letterSpacing: 0.8);
}
