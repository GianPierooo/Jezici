import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/content_item_model.dart';
import '../../../l10n/app_localizations.dart';
import 'audio_play_button.dart';
import 'multiple_choice_exercise.dart';

/// Listening REAL: reproduce el audio (TTS) y el usuario elige la opción. Se
/// califica como un multiple_choice (ya no es stub).
class ListeningExercise extends StatelessWidget {
  const ListeningExercise({
    super.key,
    required this.item,
    required this.answer,
    required this.locked,
  });

  final ContentItemModel item;
  final ValueNotifier<Object?> answer;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final url = (item.payload['audio_url'] ?? '').toString();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 4),
        AudioPlayButton(url: url),
        const SizedBox(height: 8),
        Center(
          child: Text(l10n.listeningTapToListen,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
        ),
        const SizedBox(height: 18),
        MultipleChoiceExercise(item: item, answer: answer, locked: locked),
      ],
    );
  }
}
