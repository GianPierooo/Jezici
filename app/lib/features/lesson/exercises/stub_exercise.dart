import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/content_item_model.dart';
import '../../../l10n/app_localizations.dart';

/// Stub elegante para tipos que aún no son jugables en Fase 1:
/// listening (faltan audios), speaking_read_aloud (falta reconocimiento de voz),
/// dictation y guided_writing. Muestra el ítem y se avanza con CONTINUAR
/// (no se califica, no resta vida). Copy e icono según el tipo.
class StubExercise extends StatelessWidget {
  const StubExercise({super.key, required this.item});

  final ContentItemModel item;

  ({IconData icon, String tag, String note}) _styleFor(AppLocalizations l10n) {
    switch (item.type) {
      case ContentItemType.speakingReadAloud:
        return (
          icon: Icons.mic_rounded,
          tag: l10n.stubTagPronunciation,
          note: l10n.stubNotePronunciation
        );
      case ContentItemType.listening:
        return (
          icon: Icons.volume_up_rounded,
          tag: l10n.stubTagListening,
          note: l10n.stubNoteListening
        );
      case ContentItemType.dictation:
        return (
          icon: Icons.hearing_rounded,
          tag: l10n.stubTagDictation,
          note: l10n.stubNoteDictation
        );
      case ContentItemType.guidedWriting:
        return (
          icon: Icons.edit_note_rounded,
          tag: l10n.stubTagGuidedWriting,
          note: l10n.stubNoteGuidedWriting
        );
      default:
        return (
          icon: Icons.hourglass_top_rounded,
          tag: l10n.stubTagComingSoon,
          note: l10n.stubNoteComingSoon
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final s = _styleFor(l10n);
    final text = (item.payload['text'] ?? '').toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 5), blurRadius: 0),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.navActiveBg,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(s.icon, color: AppColors.primary, size: 30),
              ),
              const SizedBox(height: 14),
              Text(
                s.tag,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: AppColors.primary,
                ),
              ),
              if (text.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  '“$text”',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF4D6),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(Icons.construction_rounded, color: AppColors.goldDark, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  s.note,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF9A7A1E),
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
