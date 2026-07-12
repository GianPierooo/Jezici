import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/i18n/learn_lang_names.dart';
import '../../core/ui/responsive_center.dart';
import '../../core/theme/app_colors.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/primary_button.dart';
import '../learn/widgets/parrot_mascot.dart';

/// Paywall de Jezici Premium (Paywall.dc). Fase 1: SIN pagos reales (decisión
/// beta) → el selector de planes/precios del mockup NO se muestra (sería un
/// botón muerto); CTA honesto "próximamente". Lo fiel al mockup: header con
/// guacamayo coronado, beneficios con chip de color POR ítem + CHECK verde
/// (semántica "incluido", no candado), CTA dorado 3D. Copy course-aware
/// (idioma real del curso activo, no "inglés" fijo). i18n es/en/pt.
class PremiumScreen extends ConsumerWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lang = ref.watch(activeCourseTargetProvider).maybeWhen(data: (v) => v, orElse: () => 'en');
    final features = <(IconData, Color, String, String)>[
      (Icons.school_rounded, const Color(0xFFFF6B6B), l10n.premiumFeatMocksTitle, l10n.premiumFeatMocksDesc),
      (Icons.favorite_rounded, AppColors.hearts, l10n.premiumFeatHeartsTitle, l10n.premiumFeatHeartsDesc),
      (Icons.replay_rounded, AppColors.primary, l10n.premiumFeatRetriesTitle, l10n.premiumFeatRetriesDesc),
      (Icons.block_rounded, AppColors.streak, l10n.premiumFeatNoAdsTitle, l10n.premiumFeatNoAdsDesc),
      (Icons.insights_rounded, AppColors.success, l10n.premiumFeatReportsTitle, l10n.premiumFeatReportsDesc),
    ];
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background, elevation: 0, foregroundColor: AppColors.text,
        title: const Text('Jezici Premium', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: ResponsiveCenter(
        maxWidth: 480,
        child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Color(0xFF7A6BF0), AppColors.primary, Color(0xFF5B4ECF)]),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(children: [
              // Guacamayo CORONADO del mockup (corona sobre el SVG propio).
              const SizedBox(
                width: 84,
                height: 96,
                child: Stack(alignment: Alignment.bottomCenter, children: [
                  ParrotArt(size: 76),
                  Positioned(top: 0, child: Text('👑', style: TextStyle(fontSize: 26))),
                ]),
              ),
              const SizedBox(height: 8),
              Text(l10n.premiumHeroTitle(learnLangName(l10n, lang)),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
              const SizedBox(height: 4),
              Text(l10n.premiumHeroSubtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFE8E5FF))),
            ]),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 5), blurRadius: 0)]),
            child: Column(children: [
              for (final f in features) Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(children: [
                  // Chip de color POR beneficio (Paywall.dc).
                  Container(
                    width: 40, height: 40, alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: f.$2.withValues(alpha: 0.13),
                        borderRadius: BorderRadius.circular(12)),
                    child: Icon(f.$1, color: f.$2, size: 20)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(f.$3, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.text)),
                    Text(f.$4, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                  ])),
                  // CHECK verde "incluido" (semántica del mockup, no candado).
                  const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 18),
          // CTA dorado 3D (tokens goldCta*), coherente con el resto de dorados.
          PrimaryButton(
            label: l10n.premiumCtaSoon,
            expand: true,
            color: AppColors.gold,
            depthColor: AppColors.goldDark,
            foreground: const Color(0xFF5B3A00),
            onPressed: () => ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text(l10n.premiumCtaSnack))),
          ),
          const SizedBox(height: 8),
          Text(l10n.premiumFreeNote,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
        ],
      ),
      ),
    );
  }
}
