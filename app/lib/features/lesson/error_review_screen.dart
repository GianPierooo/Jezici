import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/ui/jz_transitions.dart';
import '../../data/models/content_item_model.dart';
import '../../data/models/lesson_model.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/primary_button.dart';
import 'lesson_player_screen.dart';

/// "Repasa lo que fallaste" (TASK 1): se muestra al terminar la lección, ANTES de
/// la recompensa, SOLO si hubo fallos. Lista cada ejercicio errado + la respuesta
/// correcta + un porqué corto (voz del coach). La corrección se muestra SIEMPRE;
/// "practicar los fallados" es OPCIONAL (no obligatorio, para no frustrar).
class ErrorReviewScreen extends StatelessWidget {
  const ErrorReviewScreen({
    super.key,
    required this.failed,
    required this.lesson,
    required this.onContinue,
  });

  final List<({ContentItemModel item, String correct})> failed;
  final LessonModel lesson;
  final void Function(BuildContext ctx) onContinue;

  /// Porqué corto, por tipo de ejercicio (voz del coach, breve).
  String _why(AppLocalizations l10n, ContentItemType t) {
    switch (t) {
      case ContentItemType.translation:
        return l10n.errorReviewWhyTranslation;
      case ContentItemType.cloze:
        return l10n.errorReviewWhyCloze;
      case ContentItemType.wordBank:
      case ContentItemType.reorder:
        return l10n.errorReviewWhyWordOrder;
      case ContentItemType.match:
        return l10n.errorReviewWhyMatch;
      case ContentItemType.listening:
        return l10n.errorReviewWhyListening;
      default:
        return l10n.errorReviewWhyDefault;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(20, 18, 20, 12 + MediaQuery.paddingOf(context).bottom),
                children: [
                  const Text('🦜', style: TextStyle(fontSize: 44)),
                  const SizedBox(height: 6),
                  Text(l10n.errorReviewTitle,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.text)),
                  const SizedBox(height: 4),
                  Text(
                    l10n.errorReviewSubtitle(failed.length),
                    style: const TextStyle(
                        fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 18),
                  for (final f in failed) _FailedCard(item: f.item, correct: f.correct, why: _why(l10n, f.item.type)),
                ],
              ),
            ),
            // Acciones: corrección SIEMPRE; reintentar OPCIONAL.
            Container(
              padding: EdgeInsets.fromLTRB(20, 10, 20, 16 + MediaQuery.paddingOf(context).bottom),
              decoration: const BoxDecoration(
                color: AppColors.background,
                border: Border(top: BorderSide(color: Color(0xFFE7E8F2))),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PrimaryButton(
                    label: l10n.commonContinue,
                    expand: true,
                    onPressed: () => onContinue(context),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(jzRoute(LessonPlayerScreen(
                      lesson: lesson,
                      items: failed.map((f) => f.item).toList(),
                      reviewMode: true,
                    ))),
                    child: Text(l10n.errorReviewPracticeCta,
                        style: const TextStyle(
                            fontSize: 13.5, fontWeight: FontWeight.w900, color: AppColors.primary)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FailedCard extends StatelessWidget {
  const _FailedCard({required this.item, required this.correct, required this.why});
  final ContentItemModel item;
  final String correct;
  final String why;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 5), blurRadius: 0)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ((item.prompt ?? '').isNotEmpty) ...[
            Text(item.prompt!,
                style: const TextStyle(
                    fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.text, height: 1.3)),
            const SizedBox(height: 10),
          ],
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFE5F8EE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(correct,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.successDark)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(why,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted, height: 1.35)),
        ],
      ),
    );
  }
}
