import 'package:flutter/material.dart';

import '../../../core/speech/word_tts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';

/// Frase META a leer en voz alta — TOCAR para OÍRLA (TTS en el idioma del curso,
/// `WordTts.speak` → `SpeechLang.tts`). Pronunciar la frase que el usuario debe
/// leer es correcto: es el modelo, no revela ninguna respuesta. Reemplaza al
/// antiguo botón "oír el modelo". Affordance sutil (altavoz + "toca para oír").
class SpeakablePhrase extends StatelessWidget {
  const SpeakablePhrase({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: text,
      child: InkWell(
        onTap: () => WordTts.speak(text),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
              color: AppColors.navActiveBg, borderRadius: BorderRadius.circular(18)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Text('“$text”',
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                        height: 1.3)),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.volume_up_rounded, color: AppColors.primary, size: 24),
            ]),
            const SizedBox(height: 6),
            Text(l10n.speakingTapToHear,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
          ]),
        ),
      ),
    );
  }
}

/// Botón de micrófono que ALTERNA: tocar para empezar; mientras escucha, tocar
/// para DETENER (finalizar y calificar) — necesario con continuous=true, que no
/// corta en la primera pausa. Estado "escuchando" claro por color coral + icono
/// stop + etiqueta "Detener" (+ la transcripción en vivo debajo).
class SpeakMicButton extends StatelessWidget {
  const SpeakMicButton({super.key, required this.listening, required this.onTap});
  final bool listening;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        decoration: BoxDecoration(
            color: listening ? AppColors.coral : AppColors.primary,
            borderRadius: BorderRadius.circular(16)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(listening ? Icons.stop_rounded : Icons.mic_none_rounded, color: Colors.white),
          const SizedBox(width: 8),
          Text(listening ? l10n.speakingStop : l10n.speakingTalk,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
        ]),
      ),
    );
  }
}

/// Transcripción EN VIVO: lo que el reconocedor va entendiendo aparece aquí
/// mientras el usuario habla (para que vea que se le escucha). En Android los
/// parciales son escasos → muestra lo que haya; si aún nada, un "escuchando…".
class LiveTranscript extends StatelessWidget {
  const LiveTranscript({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = text.trim();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.coral.withValues(alpha: 0.5), width: 2),
      ),
      child: Text(
        t.isEmpty ? '${l10n.speakingListening}…' : t,
        style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            height: 1.3,
            color: t.isEmpty ? AppColors.textMuted : AppColors.text),
      ),
    );
  }
}
