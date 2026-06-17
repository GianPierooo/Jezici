import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Barra inferior SOLO ÍCONOS (Estructura_App §1):
/// Aprender · Practicar · Conversar · Ligas · Perfil. (GA7: Conversar vuelve como
/// práctica SEGURA en solitario — sin chat con desconocidos ni IA.)
class BottomNav extends StatelessWidget {
  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = <IconData>[
    Icons.explore_rounded, // Aprender (mapa/viaje)
    Icons.fitness_center_rounded, // Practicar
    Icons.forum_rounded, // Conversar (taste seguro)
    Icons.emoji_events_rounded, // Ligas
    Icons.person_rounded, // Perfil
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 16),
      height: 62,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF28326E).withValues(alpha: 0.18),
            offset: const Offset(0, 10),
            blurRadius: 26,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (var i = 0; i < _items.length; i++)
            _NavButton(
              icon: _items[i],
              active: i == currentIndex,
              onTap: () => onTap(i),
            ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 180),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: active ? AppColors.navActiveBg : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          size: 25,
          color: active ? AppColors.primary : AppColors.navInactive,
        ),
      ),
    );
  }
}
