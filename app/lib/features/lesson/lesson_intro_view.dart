import 'package:flutter/material.dart';

import '../../core/speech/speakable_text.dart';
import '../../core/theme/app_colors.dart';
import '../../core/ui/jz_glow_pulse.dart';
import '../../core/ui/responsive_center.dart';
import '../../data/models/tip_models.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/primary_button.dart';
import '../learn/widgets/parrot_mascot.dart';
import 'exercises/concept_image.dart';

/// Fase de PRESENTACIÓN de la lección ("enseñar antes de examinar", P1 #4). Se
/// muestra ANTES del primer ejercicio: el CONCEPTO (teoría + ejemplo del tip) y el
/// VOCABULARIO nuevo (término meta + traducción + audio al tocar + imagen si hay).
/// Todo DERIVADO de contenido que la lección ya tiene (get_lesson_intro). No toca
/// economía/scoring: es solo lectura. Siempre SALTABLE.
class LessonIntroView extends StatelessWidget {
  const LessonIntroView({
    super.key,
    required this.intro,
    required this.title,
    required this.onStart,
    required this.onSkip,
  });

  final LessonIntro intro;
  final String title;
  final VoidCallback onStart; // → primer ejercicio
  final VoidCallback onSkip; // saltar la teoría

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tip = intro.tip;
    final vocab = intro.vocab;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Barra: cerrar-saltar a la derecha (nunca forzamos la teoría).
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  const Spacer(),
                  TextButton(
                    onPressed: onSkip,
                    style: TextButton.styleFrom(foregroundColor: AppColors.textMuted),
                    child: Text(l10n.introSkip,
                        style: const TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                child: ResponsiveCenter(
                  maxWidth: 560,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Jezi presenta el tema.
                      Center(
                        child: ParrotMascot(
                          size: 76,
                          mood: MascotMood.encourage,
                          message: l10n.introMascot,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(l10n.introKicker,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              color: AppColors.primary)),
                      const SizedBox(height: 4),
                      Text(title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.text)),
                      const SizedBox(height: 20),

                      // CONCEPTO (teoría): del tip de la lección.
                      if (tip != null) _ConceptCard(tip: tip),
                      if (tip != null && vocab.isNotEmpty) const SizedBox(height: 22),

                      // VOCABULARIO nuevo.
                      if (vocab.isNotEmpty) ...[
                        Text(l10n.introVocabTitle,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textMuted,
                                letterSpacing: 0.4)),
                        const SizedBox(height: 12),
                        for (final w in vocab) ...[
                          _VocabCard(word: w),
                          const SizedBox(height: 12),
                        ],
                      ],
                      const SizedBox(height: 4),
                      Text(l10n.introTapHint,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
              child: ResponsiveCenter(
                maxWidth: 560,
                child: JzGlowPulse(
                  child: PrimaryButton(
                    label: l10n.introStart,
                    expand: true,
                    onPressed: onStart,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tarjeta de concepto: el punto que enseña la lección (title + body + ejemplo
/// tocable para oírlo). Reusa el tip que ya existe.
class _ConceptCard extends StatelessWidget {
  const _ConceptCard({required this.tip});
  final TipModel tip;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 5), blurRadius: 0),
          BoxShadow(color: Color(0x14000000), offset: Offset(0, 8), blurRadius: 20),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.navActiveBg.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.lightbulb_rounded, size: 14, color: AppColors.primary),
              const SizedBox(width: 5),
              Text(l10n.introConceptChip,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                      color: AppColors.primary)),
            ]),
          ),
          const SizedBox(height: 12),
          Text(tip.title,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.text)),
          const SizedBox(height: 8),
          Text(tip.body,
              style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                  color: AppColors.text)),
          if ((tip.example ?? '').isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F7FB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SpeakableText(
                tip.example!,
                style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    height: 1.4,
                    color: AppColors.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Tarjeta de una palabra: imagen (si hay) + término meta tocable (audio) + traducción.
/// Sin imagen → degrada con gracia a texto+audio (ConceptImage colapsa solo).
class _VocabCard extends StatelessWidget {
  const _VocabCard({required this.word});
  final IntroWord word;

  @override
  Widget build(BuildContext context) {
    final hasImg = (word.imageUrl ?? '').isNotEmpty;
    return Container(
      padding: EdgeInsets.fromLTRB(16, hasImg ? 14 : 16, 16, hasImg ? 14 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 5), blurRadius: 0),
        ],
      ),
      child: Row(
        children: [
          if (hasImg)
            // ConceptImage trae su propio marco/tamaño; lo encogemos a la fila.
            SizedBox(
              width: 72,
              height: 72,
              child: FittedBox(fit: BoxFit.contain, child: ConceptImage(url: word.imageUrl!)),
            ),
          if (hasImg) const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Término META: tocar para oírlo (TTS del idioma del curso).
                SpeakableText(
                  word.term,
                  iconSize: 18,
                  style: const TextStyle(
                      fontSize: 19, fontWeight: FontWeight.w900, color: AppColors.text),
                ),
                const SizedBox(height: 3),
                Text(word.translation,
                    style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
