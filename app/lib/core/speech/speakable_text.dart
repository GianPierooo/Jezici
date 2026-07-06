import 'package:flutter/material.dart';

import '../feedback/feedback_fx.dart';
import '../theme/app_colors.dart';
import 'word_tts.dart';

/// Texto en el idioma META que se PRONUNCIA al tocarlo (Web Speech, `WordTts` →
/// `SpeechLang` del curso activo). Afordancia con un ícono de altavoz para señalar
/// que es tocable. Disparado por el TAP (gesto real → sin problema de desbloqueo de
/// audio iOS); corto, interrumpible, no bloquea la interacción; degradación con
/// gracia (en plataformas sin síntesis `WordTts` es no-op → el tap no hace nada
/// audible, sin crash). NO usar para texto en la lengua de la UI (español).
class SpeakableText extends StatelessWidget {
  const SpeakableText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.showIcon = true,
    this.iconSize = 15,
    this.align = MainAxisAlignment.start,
  });

  final String text;
  final TextStyle? style;
  final int? maxLines;
  final bool showIcon;
  final double iconSize;
  final MainAxisAlignment align;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FeedbackFx.tap();
        WordTts.speak(text);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: align,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Text(
              text,
              style: style,
              maxLines: maxLines,
              overflow: maxLines == null ? null : TextOverflow.ellipsis,
            ),
          ),
          if (showIcon) ...[
            const SizedBox(width: 6),
            Padding(
              padding: const EdgeInsets.only(top: 1.5),
              child: Icon(Icons.volume_up_rounded,
                  size: iconSize, color: AppColors.primary.withValues(alpha: 0.6)),
            ),
          ],
        ],
      ),
    );
  }
}
