import 'package:flutter/material.dart';

/// Transición de pantalla "jugosa pero rápida" (Sistema_Diseno §6 · dinamismo):
/// fade + un leve escalado, ~260ms. Reemplaza el slide genérico de
/// MaterialPageRoute en el loop principal. Respeta reduce-motion (fade simple).
Route<T> jzRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 260),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (_, _, _) => page,
    transitionsBuilder: (context, animation, _, child) {
      final reduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      if (reduce) return FadeTransition(opacity: curved, child: child);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.97, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}
