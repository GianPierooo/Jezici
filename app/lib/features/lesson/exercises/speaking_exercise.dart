import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/speech/mic_messages.dart';
import '../../../core/speech/speech_lang.dart';
import '../../../core/speech/speech_recognizer.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/content_item_model.dart';
import '../../../l10n/app_localizations.dart';
import 'speaking_widgets.dart';

/// Speaking REAL (Fase 1): el usuario escucha el modelo y lee en voz alta.
/// GA8: usa el reconocedor de voz correcto (Web Speech cruda en web, sin
/// duplicados) + comparación TOLERANTE (una lectura razonable APRUEBA) +
/// degradación HONESTA si no hay soporte/permiso/mic: mensaje con la CAUSA
/// real (micMessageFor) + "Ya lo leí" para no bloquear la sesión.
class SpeakingExercise extends StatefulWidget {
  const SpeakingExercise({super.key, required this.item, this.recognizer});
  final ContentItemModel item;

  /// Inyectable para tests; null = reconocedor real de la plataforma.
  final SpeechRecognizer? recognizer;

  @override
  State<SpeakingExercise> createState() => _SpeakingExerciseState();
}

class _SpeakingExerciseState extends State<SpeakingExercise> {
  late final SpeechRecognizer _rec = widget.recognizer ?? createSpeechRecognizer();
  bool _ready = false;
  bool _available = false;
  bool _listening = false;
  String? _micError; // código SpeechErrors → mensaje honesto en la UI
  String? _heard; // limpio
  double? _score; // 0..1 (sólo tras resultado final)
  bool _doneManually = false;

  String get _expected =>
      (widget.item.payload['text'] ?? widget.item.correctAnswer['expected'] ?? '').toString();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final ok = await _rec.init();
    if (mounted) {
      setState(() {
        _available = ok;
        _ready = true;
      });
    }
  }

  @override
  void dispose() {
    _rec.dispose();
    super.dispose();
  }

  /// Alterna: si ya escucha, DETIENE (finaliza + califica); si no, empieza.
  void _toggleListen() {
    if (!_available) return;
    if (_listening) {
      _rec.stop(); // continuous=true no corta solo → el usuario termina al tocar
      return;
    }
    setState(() {
      _listening = true;
      _micError = null;
      _heard = null;
      _score = null;
    });
    HapticFeedback.selectionClick();
    _rec.listen(
      localeId: SpeechLang.stt, // idioma del curso activo (en/pt/fr/it), no inglés fijo
      listenFor: const Duration(seconds: 15),
      onResult: (transcript, isFinal) {
        if (!mounted) return;
        setState(() {
          _heard = transcript; // transcripción EN VIVO (parciales + acumulado)
          if (isFinal) {
            _score = speechMatchRatio(transcript, _expected);
            _listening = false;
            HapticFeedback.lightImpact();
          }
        });
      },
      onError: (e) {
        if (!mounted) return;
        setState(() {
          _listening = false;
          if (micErrorIsFatal(e)) {
            // Permiso bloqueado / sin mic / sin soporte: el mic se apaga para
            // el resto del ejercicio y se explica la CAUSA + "Ya lo leí".
            _available = false;
            _micError = e;
          } else if (e == SpeechErrors.network) {
            _micError = e; // transitorio: aviso + el mic queda para reintentar
          }
        });
      },
      onDone: () {
        if (mounted) setState(() => _listening = false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final passed = _score != null && speechPasses(_heard ?? '', _expected);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Frase META: TOCAR para oírla (TTS del curso). Fuera el botón separado.
        SpeakablePhrase(text: _expected),
        const SizedBox(height: 18),
        if (!_ready)
          Center(
              child: Text(l10n.speakingPreparingMic,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMuted)))
        else if (!_available) ...[
          // FALLBACK HONESTO (mic no disponible): la CAUSA real + "Ya lo leí" para
          // que un usuario de Firefox/Brave/sin-permiso NO quede atascado.
          Text(micMessageFor(l10n, _micError ?? _rec.unavailableReason),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
          const SizedBox(height: 12),
          Center(child: _readItButton()),
        ] else ...[
          Center(child: SpeakMicButton(listening: _listening, onTap: _toggleListen)),
          // Transcripción EN VIVO mientras habla (o el resultado tras finalizar).
          if (_listening || (_heard != null && (_heard!.trim().isNotEmpty))) ...[
            const SizedBox(height: 12),
            LiveTranscript(text: _heard ?? ''),
          ],
          if (_micError == SpeechErrors.network) ...[
            const SizedBox(height: 8),
            Text(micMessageFor(l10n, _micError),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.coral)),
          ],
        ],
        if (_heard != null && _score != null) ...[
          const SizedBox(height: 8),
          _Feedback(heard: _heard!, passed: passed, onRetry: _toggleListen),
        ],
        if (_doneManually) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFFE5F8EE), borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(l10n.speakingManualDone,
                  style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.success))),
            ]),
          ),
        ],
      ],
    );
  }

  Widget _readItButton() {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () => setState(() => _doneManually = true),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
        child: Text(l10n.speakingIReadIt,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
      ),
    );
  }
}

class _Feedback extends StatelessWidget {
  const _Feedback({required this.heard, required this.passed, required this.onRetry});
  final String heard;
  final bool passed;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = passed ? AppColors.success : AppColors.coral;
    final empty = heard.trim().isEmpty;
    final title = passed
        ? l10n.speakingGood
        : (empty ? l10n.speakingNoSound : l10n.speakingOk);
    final detail = passed
        ? l10n.speakingHeard(heard)
        : (empty
            ? l10n.speakingVolumeHint
            : l10n.speakingRetryHint(heard));
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: passed ? const Color(0xFFE5F8EE) : const Color(0xFFFFF1E9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(passed ? Icons.verified_rounded : Icons.refresh_rounded, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.w900, color: color))),
          if (!passed) TextButton(onPressed: onRetry, child: Text(l10n.commonRetry)),
        ]),
        const SizedBox(height: 6),
        Text(detail,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
      ]),
    );
  }
}
