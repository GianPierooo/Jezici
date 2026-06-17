import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/content_item_model.dart';
import '../grading/grader.dart';
import 'audio_play_button.dart';

/// Speaking REAL (Fase 1): el usuario escucha el modelo y lee en voz alta. La
/// Web Speech API (speech_to_text) transcribe y comparamos de forma DETERMINISTA
/// contra el texto esperado, con feedback. Es participación (no penaliza el
/// puntaje), pero da práctica de pronunciación de verdad.
class SpeakingExercise extends StatefulWidget {
  const SpeakingExercise({super.key, required this.item});
  final ContentItemModel item;

  @override
  State<SpeakingExercise> createState() => _SpeakingExerciseState();
}

class _SpeakingExerciseState extends State<SpeakingExercise> {
  final SpeechToText _stt = SpeechToText();
  bool _available = false;
  bool _ready = false;
  bool _listening = false;
  String? _heard;
  double? _score; // 0..1 similitud

  String get _expected => (widget.item.payload['text'] ??
          widget.item.correctAnswer['expected'] ??
          '')
      .toString();
  String get _audioUrl => (widget.item.payload['audio_url'] ?? '').toString();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      _available = await _stt.initialize(onError: (_) {}, onStatus: (s) {
        if (s == 'done' || s == 'notListening') {
          if (mounted) setState(() => _listening = false);
        }
      });
    } catch (_) {
      _available = false;
    }
    if (mounted) setState(() => _ready = true);
  }

  @override
  void dispose() {
    _stt.cancel();
    super.dispose();
  }

  double _similarity(String a, String b) {
    final wa = normalize(a).split(' ').where((w) => w.isNotEmpty).toList();
    final wb = normalize(b).split(' ').where((w) => w.isNotEmpty).toSet();
    if (wa.isEmpty || wb.isEmpty) return 0;
    final hits = wa.where(wb.contains).length;
    return hits / (wa.length > wb.length ? wa.length : wb.length);
  }

  Future<void> _listen() async {
    if (!_available || _listening) return;
    setState(() {
      _listening = true;
      _heard = null;
      _score = null;
    });
    await _stt.listen(
      onResult: (r) {
        if (!mounted) return;
        if (r.finalResult) {
          final sim = _similarity(r.recognizedWords, _expected);
          setState(() {
            _heard = r.recognizedWords;
            _score = sim;
            _listening = false;
          });
        }
      },
      listenOptions: SpeechListenOptions(
          localeId: 'en_US', listenFor: const Duration(seconds: 6)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.navActiveBg,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text('“$_expected”',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primary, height: 1.3)),
        ),
        const SizedBox(height: 14),
        if (_audioUrl.isNotEmpty) Center(child: AudioPlayButton(url: _audioUrl, label: 'Oír el modelo', big: false)),
        const SizedBox(height: 18),
        if (!_ready)
          const Center(
            child: Text('Preparando micrófono…',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
          )
        else if (!_available)
          const Text('Tu navegador no permite el micrófono. Léelo en voz alta para practicar 🙂',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMuted))
        else
          Center(
            child: GestureDetector(
              onTap: _listen,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                decoration: BoxDecoration(
                  color: _listening ? AppColors.coral : AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(_listening ? Icons.mic_rounded : Icons.mic_none_rounded, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(_listening ? 'Escuchando…' : 'Hablar',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                ]),
              ),
            ),
          ),
        if (_heard != null) ...[
          const SizedBox(height: 16),
          _Feedback(heard: _heard!, score: _score ?? 0),
        ],
      ],
    );
  }
}

class _Feedback extends StatelessWidget {
  const _Feedback({required this.heard, required this.score});
  final String heard;
  final double score;

  @override
  Widget build(BuildContext context) {
    final good = score >= 0.6;
    final color = good ? AppColors.success : AppColors.coral;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: good ? const Color(0xFFE5F8EE) : const Color(0xFFFFF1E9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(good ? Icons.verified_rounded : Icons.refresh_rounded, color: color, size: 20),
          const SizedBox(width: 8),
          Text(good ? '¡Bien pronunciado! 🦜' : 'Casi — vuelve a intentarlo',
              style: TextStyle(fontWeight: FontWeight.w900, color: color)),
        ]),
        const SizedBox(height: 6),
        Text('Escuché: “$heard”',
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
      ]),
    );
  }
}
