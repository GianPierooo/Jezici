import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/ui/responsive_center.dart';
import '../../../l10n/app_localizations.dart';
import '../../learn/widgets/parrot_mascot.dart';

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
                  // Progreso SEGMENTADO (Onboarding.dc): un tramo por paso.
                  Expanded(
                    child: Row(
                      children: [
                        for (int i = 0; i < total; i++) ...[
                          if (i > 0) const SizedBox(width: 4),
                          Expanded(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 260),
                              height: 7,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: i < step ? AppColors.primary : const Color(0xFFE2E5F0),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('$step/$total',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF9A9FB8))),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                child: ResponsiveCenter(
                  maxWidth: 480,
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (showMascot)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const ParrotMascot(size: 46),
                            const SizedBox(width: 10),
                            Flexible(child: _CoachBubble(AppLocalizations.of(context).onbCoachBubble)),
                          ],
                        ),
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
            ),
            if (footer != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                child: ResponsiveCenter(maxWidth: 480, child: footer!),
              ),
          ],
        ),
      ),
    );
  }
}

/// Globo de diálogo blanco del guacamayo (Onboarding.dc FRAME A).
class _CoachBubble extends StatelessWidget {
  const _CoachBubble(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
          bottomLeft: Radius.circular(4),
        ),
        boxShadow: [
          BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 4), blurRadius: 0),
          BoxShadow(color: Color(0x14312E78), offset: Offset(0, 8), blurRadius: 16),
        ],
      ),
      child: Text(text,
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.text)),
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
