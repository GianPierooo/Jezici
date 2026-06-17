import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/speech/speech_recognizer.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/content_item_model.dart';
import 'audio_play_button.dart';

/// Speaking REAL (Fase 1): el usuario escucha el modelo y lee en voz alta.
/// GA8: usa el reconocedor de voz correcto (Web Speech cruda en web, sin
/// duplicados) + comparación TOLERANTE (una lectura razonable APRUEBA) +
/// degradación con gracia si no hay micrófono/permiso ("Ya lo leí").
class SpeakingExercise extends StatefulWidget {
  const SpeakingExercise({super.key, required this.item});
  final ContentItemModel item;

  @override
  State<SpeakingExercise> createState() => _SpeakingExerciseState();
}

class _SpeakingExerciseState extends State<SpeakingExercise> {
  final SpeechRecognizer _rec = createSpeechRecognizer();
  bool _ready = false;
  bool _available = false;
  bool _listening = false;
  String? _heard; // limpio
  double? _score; // 0..1 (sólo tras resultado final)
  bool _doneManually = false;

  String get _expected =>
      (widget.item.payload['text'] ?? widget.item.correctAnswer['expected'] ?? '').toString();
  String get _audioUrl => (widget.item.payload['audio_url'] ?? '').toString();

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

  void _listen() {
    if (!_available || _listening) return;
    setState(() {
      _listening = true;
      _heard = null;
      _score = null;
    });
    HapticFeedback.selectionClick();
    _rec.listen(
      localeId: 'en_US',
      listenFor: const Duration(seconds: 8),
      onResult: (transcript, isFinal) {
        if (!mounted) return;
        setState(() {
          _heard = transcript;
          if (isFinal) {
            _score = speechMatchRatio(transcript, _expected);
            _listening = false;
            HapticFeedback.lightImpact();
          }
        });
      },
      onError: (_) {
        if (mounted) setState(() => _listening = false);
      },
      onDone: () {
        if (mounted) setState(() => _listening = false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final passed = _score != null && speechPasses(_heard ?? '', _expected);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: AppColors.navActiveBg, borderRadius: BorderRadius.circular(18)),
          child: Text('“$_expected”',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primary, height: 1.3)),
        ),
        const SizedBox(height: 14),
        if (_audioUrl.isNotEmpty) Center(child: AudioPlayButton(url: _audioUrl, label: 'Oír el modelo', big: false)),
        const SizedBox(height: 18),
        if (!_ready)
          const Center(
              child: Text('Preparando micrófono…',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMuted)))
        else if (!_available) ...[
          const Text('Tu navegador o dispositivo no permite el micrófono.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
          const SizedBox(height: 12),
          Center(child: _readItButton()),
        ] else ...[
          Center(child: _micButton()),
          const SizedBox(height: 10),
          Center(
            child: TextButton(
              onPressed: () => setState(() => _doneManually = true),
              child: const Text('Ya lo leí ✓',
                  style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textMuted)),
            ),
          ),
        ],
        if (_heard != null && _score != null) ...[
          const SizedBox(height: 8),
          _Feedback(heard: _heard!, passed: passed, onRetry: _listen),
        ],
        if (_doneManually) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFFE5F8EE), borderRadius: BorderRadius.circular(14)),
            child: const Row(children: [
              Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
              SizedBox(width: 8),
              Expanded(child: Text('¡Bien! Sigue practicando en voz alta. 🦜',
                  style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.success))),
            ]),
          ),
        ],
      ],
    );
  }

  Widget _micButton() {
    return GestureDetector(
      onTap: _listen,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        decoration: BoxDecoration(
            color: _listening ? AppColors.coral : AppColors.primary, borderRadius: BorderRadius.circular(16)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(_listening ? Icons.mic_rounded : Icons.mic_none_rounded, color: Colors.white),
          const SizedBox(width: 8),
          Text(_listening ? 'Escuchando…' : 'Hablar',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
        ]),
      ),
    );
  }

  Widget _readItButton() {
    return GestureDetector(
      onTap: () => setState(() => _doneManually = true),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
        child: const Text('Ya lo leí ✓',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
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
    final color = passed ? AppColors.success : AppColors.coral;
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
          Expanded(
            child: Text(passed ? '¡Bien pronunciado! 🦜' : 'Casi — inténtalo otra vez',
                style: TextStyle(fontWeight: FontWeight.w900, color: color)),
          ),
          if (!passed)
            TextButton(onPressed: onRetry, child: const Text('Reintentar')),
        ]),
        const SizedBox(height: 6),
        Text(heard.isEmpty ? 'No te escuché bien. Acércate al micrófono.' : 'Escuché: “$heard”',
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
      ]),
    );
  }
}
