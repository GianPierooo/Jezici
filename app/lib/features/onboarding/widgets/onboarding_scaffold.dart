import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Shell común de los pasos del onboarding: barra de progreso, mascota, título
/// y un footer fijo (botón continuar).
class OnboardingScaffold extends StatelessWidget {
  const OnboardingScaffold({
    super.key,
    required this.step,
    required this.total,
    required this.title,
    required this.child,
    this.subtitle,
    this.footer,
    this.onBack,
    this.showMascot = true,
  });

  final int step; // 1-based
  final int total;
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? footer;
  final VoidCallback? onBack;
  final bool showMascot;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 34,
                    child: onBack == null
                        ? null
                        : GestureDetector(
                            onTap: onBack,
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEBEDF5),
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: const Icon(Icons.arrow_back_rounded,
                                  color: AppColors.textMuted, size: 18),
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(children: [
                        Container(height: 10, color: const Color(0xFFE5E7F1)),
                        AnimatedFractionallySizedBox(
                          duration: const Duration(milliseconds: 280),
                          widthFactor: (step / total).clamp(0.0, 1.0),
                          child: Container(
                            height: 10,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [AppColors.primaryLight, AppColors.primary]),
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const SizedBox(width: 34),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (showMascot)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text('🦜', style: TextStyle(fontSize: 44)),
                      ),
                    Text(
                      title,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.text),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textMuted),
                      ),
                    ],
                    const SizedBox(height: 22),
                    child,
                  ],
                ),
              ),
            ),
            if (footer != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                child: footer!,
              ),
          ],
        ),
      ),
    );
  }
}

/// Opción seleccionable del onboarding.
class OnboardingOption extends StatelessWidget {
  const OnboardingOption({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.trailing,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? AppColors.navActiveBg : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : const Color(0xFFE5E7F1),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: selected ? AppColors.primary : AppColors.textMuted, size: 22),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: selected ? AppColors.primary : AppColors.text,
                ),
              ),
            ),
            if (trailing != null)
              Text(trailing!,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textMuted)),
            if (selected)
              const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 22),
          ],
        ),
      ),
    );
  }
}
