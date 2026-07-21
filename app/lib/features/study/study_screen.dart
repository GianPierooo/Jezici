import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/ui/jz_transitions.dart';
import '../../core/ui/responsive_center.dart';
import '../../l10n/app_localizations.dart';
import '../learn/widgets/parrot_mascot.dart';
import 'study_level_screen.dart';
import 'study_model.dart';

/// ESTUDIAR (tab) · Fase E-1 — la guía de teoría del curso, nivel por nivel.
///
/// Reusa TODO lo que ya existe: el currículo (unidades), la teoría curada
/// (`content_tips` vía `get_reference`) y el PROGRESO REAL del mapa para el
/// desbloqueo. No genera contenido (eso es E-2) ni video (E-3).
class StudyScreen extends ConsumerWidget {
  const StudyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final levels = ref.watch(studyPlanProvider);

    return ListView(
      padding: const EdgeInsets.only(bottom: 110),
      children: [
        const _Header(),
        Transform.translate(
          offset: const Offset(0, -14),
          child: ResponsiveCenter(
            maxWidth: 480,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: levels.isEmpty
                  ? const _Loading()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final lv in levels) ...[
                          _LevelCard(
                            level: lv,
                            onTap: () => Navigator.of(context)
                                .push(jzRoute(StudyLevelScreen(cefr: lv.cefr))),
                          ),
                          const SizedBox(height: 12),
                        ],
                        const SizedBox(height: 4),
                        _FooterNote(text: l10n.studyFooterNote),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final topPad = MediaQuery.paddingOf(context).top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(0, topPad + 20, 0, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7A6BF0), AppColors.primary, Color(0xFF5B4ECF)],
        ),
      ),
      child: ResponsiveCenter(
        maxWidth: 480,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.studyKicker,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.6,
                            color: Colors.white.withValues(alpha: 0.7))),
                    const SizedBox(height: 3),
                    Text(l10n.studyTitle,
                        style: const TextStyle(
                            fontSize: 27, fontWeight: FontWeight.w900, color: Colors.white)),
                    const SizedBox(height: 7),
                    Text(l10n.studySubtitle,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            height: 1.3,
                            color: Colors.white.withValues(alpha: 0.85))),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const ParrotMascot(size: 54),
            ],
          ),
        ),
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.only(top: 60),
        child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
}

/// Tarjeta de NIVEL: badge CEFR + nº de temas + cuántos están abiertos + barra.
class _LevelCard extends StatelessWidget {
  const _LevelCard({required this.level, required this.onTap});
  final StudyLevel level;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final reduce = MediaQuery.of(context).disableAnimations;
    final total = level.topics.length;
    final open = level.unlockedCount;
    final ratio = total == 0 ? 0.0 : open / total;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 5), blurRadius: 0),
            BoxShadow(color: Color(0x123C3778), offset: Offset(0, 12), blurRadius: 22),
          ],
        ),
        child: Row(
          children: [
            // Badge del nivel (apagado si aún no hay nada abierto: honesto).
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: level.anyUnlocked
                    ? const LinearGradient(colors: [Color(0xFF8C7DF2), AppColors.primary])
                    : null,
                color: level.anyUnlocked ? null : const Color(0xFFEFF1F8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(level.cefr,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: level.anyUnlocked ? Colors.white : AppColors.textMuted)),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.studyTopics(total),
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.text)),
                  const SizedBox(height: 3),
                  Text(l10n.studyOpen(open, total),
                      style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMuted)),
                  const SizedBox(height: 7),
                  TweenAnimationBuilder<double>(
                    tween: Tween(end: ratio),
                    duration: reduce ? Duration.zero : const Duration(milliseconds: 420),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, _) => ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: LinearProgressIndicator(
                        value: v,
                        minHeight: 7,
                        backgroundColor: const Color(0xFFF0F1F8),
                        valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _FooterNote extends StatelessWidget {
  const _FooterNote({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline_rounded, size: 15, color: Color(0xFFA7ABC3)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      height: 1.45,
                      color: Color(0xFF9097AE))),
            ),
          ],
        ),
      );
}
