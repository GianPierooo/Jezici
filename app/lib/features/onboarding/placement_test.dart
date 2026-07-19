import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/speech/mic_messages.dart';
import '../../core/speech/speech_lang.dart';
import '../../core/speech/speech_recognizer.dart';
import '../../core/theme/app_colors.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../lesson/exercises/audio_play_button.dart';
import '../lesson/exercises/speaking_widgets.dart';
import 'onboarding_data.dart';
import 'widgets/onboarding_scaffold.dart';

/// Test de ubicación adaptativo, calificado en el SERVIDOR (placement_next).
/// El cliente es un RELAY: pide el siguiente ítem, lo muestra, envía la respuesta
/// y repite hasta que el servidor devuelve el nivel final. NO califica ni ve la
/// respuesta correcta (correct_answer sigue 42501).
///
/// 4 HABILIDADES (mig 135): además de reading/writing (opciones), renderiza
/// LISTENING (audio TTS + opciones "¿qué oíste?") y SPEAKING (read-aloud: muestra
/// la frase, reconoce la voz y envía la TRANSCRIPCIÓN como respuesta; el servidor
/// la califica con tolerancia typo). Si el micrófono no está disponible (o el
/// usuario lo salta), 'speaking' se EXCLUYE del examen (p_exclude_skills) y su
/// nivel cae al global — degradación honesta, nunca un fallo injusto.
class PlacementTest extends ConsumerStatefulWidget {
  const PlacementTest({
    super.key,
    required this.data,
    required this.step,
    required this.total,
    required this.onBack,
    required this.onDone,
    this.startLevel = 1,
    this.courseId,
    this.recognizer,
  });

  final OnboardingData data;
  final int step;
  final int total;
  final VoidCallback onBack;
  final VoidCallback onDone;

  /// Dificultad inicial (de la micro-pregunta): 0=A1 1=A2 2=B1 → hint CEFR.
  final int startLevel;

  /// Curso META a ubicar. null = curso activo más antiguo (es→en, onboarding).
  final String? courseId;

  /// Inyectable para tests; null = reconocedor real de la plataforma.
  final SpeechRecognizer? recognizer;

  @override
  ConsumerState<PlacementTest> createState() => _PlacementTestState();
}

class _PlacementTestState extends ConsumerState<PlacementTest> {
  static const _hintCefr = ['A1', 'A2', 'B1'];

  final List<Map<String, dynamic>> _history = [];
  final List<String> _excluded = [];
  late final SpeechRecognizer _rec = widget.recognizer ?? createSpeechRecognizer();

  Map<String, dynamic>? _item;
  int _asked = 0;
  int _max = 16;
  bool _loading = true;
  int _retries = 0;
  bool _listening = false;
  String _transcript = '';
  String? _micError; // código SpeechErrors → aviso honesto junto a "Saltar"

  String get _hint => _hintCefr[widget.startLevel.clamp(0, _hintCefr.length - 1)];

  @override
  void initState() {
    super.initState();
    _load(); // el examen arranca YA (la rotación sirve reading primero)
    _initSpeech(); // en paralelo: idioma del curso + mic
  }

  Future<void> _initSpeech() async {
    // Voz/reconocedor en el idioma del CURSO a ubicar (no en-US fijo).
    try {
      final target = await ref.read(activeCourseTargetProvider.future);
      SpeechLang.setFromCourseTarget(target);
    } catch (_) {}
    // Micrófono no disponible → speaking fuera del resto del examen (honesto).
    try {
      final ok = await _rec.init();
      if (!ok && !_excluded.contains('speaking')) _excluded.add('speaking');
    } catch (_) {
      if (!_excluded.contains('speaking')) _excluded.add('speaking');
    }
  }

  @override
  void dispose() {
    _rec.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _transcript = '';
      _listening = false;
      _micError = null;
    });
    try {
      final res = await ref.read(progressRepositoryProvider).placementNext(
          startLevel: _hint,
          history: _history,
          courseId: widget.courseId,
          excludeSkills: _excluded);
      if (!mounted) return;
      if (res['done'] == true) {
        _finish(res);
        return;
      }
      setState(() {
        _item = Map<String, dynamic>.from(res['item'] as Map);
        _asked = (res['asked'] as int? ?? _history.length) + 1;
        _max = res['max'] as int? ?? _max;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      if (_retries < 1) {
        _retries++;
        _load();
        return;
      }
      _finishFallback();
    }
  }

  void _answer(String value) {
    final it = _item;
    if (it == null) return;
    _history.add({'item_id': it['id'], 'answer': value});
    _load();
  }

  /// Saltar speaking: NO se añade a la historia (el ítem queda sin responder, no
  /// se puntúa en contra) y se excluye la skill del resto del examen.
  void _skipSpeaking() {
    if (!_excluded.contains('speaking')) _excluded.add('speaking');
    _load();
  }

  void _listen() {
    if (_listening) {
      _rec.stop(); // continuous=true no corta solo → el usuario termina al tocar
      return;
    }
    setState(() {
      _listening = true;
      _micError = null;
    });
    _rec.listen(
      localeId: SpeechLang.stt,
      listenFor: const Duration(seconds: 15),
      onResult: (t, isFinal) {
        if (!mounted) return;
        setState(() {
          _transcript = t.trim();
          if (isFinal) _listening = false;
        });
      },
      onError: (e) {
        if (!mounted) return;
        setState(() {
          _listening = false;
          // Causa REAL visible (permiso/mic/soporte/red) junto al botón de
          // saltar — nunca un mic que "no hace nada" sin explicación.
          if (micErrorIsFatal(e) || e == SpeechErrors.network) _micError = e;
        });
      },
      onDone: () {
        if (mounted) setState(() => _listening = false);
      },
    );
  }

  void _finish(Map<String, dynamic> res) {
    final level = (res['level'] as String?) ?? _hint;
    final sk = res['skill_levels'] as Map?;
    widget.data.placementLevel = level;
    widget.data.skillLevels = {
      'reading': (sk?['reading'] as String?) ?? level,
      'listening': (sk?['listening'] as String?) ?? level,
      'writing': (sk?['writing'] as String?) ?? level,
      'speaking': (sk?['speaking'] as String?) ?? level,
    };
    widget.onDone();
  }

  void _finishFallback() {
    widget.data.placementLevel = _hint;
    widget.data.skillLevels = {
      'reading': _hint,
      'listening': _hint,
      'writing': _hint,
      'speaking': _hint,
    };
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final it = _item;
    final payload = (it?['payload'] as Map?) ?? const {};
    final skill = (it?['skill'] ?? '').toString();
    final options =
        (payload['options'] as List?)?.map((e) => e.toString()).toList() ?? const <String>[];
    final audioUrl = (payload['audio_url'] ?? '').toString();
    final speakText = (payload['text'] ?? '').toString();
    final isSpeaking = skill == 'speaking';

    return OnboardingScaffold(
      step: widget.step,
      total: widget.total,
      onBack: widget.onBack,
      title: l10n.placementTitle,
      subtitle: l10n.placementSubtitle(_asked, _max),
      child: _loading || it == null
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 4), blurRadius: 0),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text((it['prompt'] ?? '').toString(),
                          style: const TextStyle(
                              fontSize: 19, fontWeight: FontWeight.w800, height: 1.3)),
                      // LISTENING: audio del ítem (mismo player del loop).
                      if (audioUrl.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Center(child: AudioPlayButton(url: audioUrl, surface: 'placement')),
                      ],
                      // SPEAKING: frase a leer en voz alta — TOCAR para oírla (TTS del curso).
                      if (isSpeaking && speakText.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        SpeakablePhrase(text: speakText),
                      ],
                    ],
                  ),
                ),
                if (!isSpeaking)
                  for (final opt in options)
                    OnboardingOption(label: opt, selected: false, onTap: () => _answer(opt))
                else ...[
                  // Micrófono (tap start / tap detener) + transcripción EN VIVO + enviar/saltar.
                  Center(child: SpeakMicButton(listening: _listening, onTap: _listen)),
                  if (_micError != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: const Color(0xFFFFF1E9),
                          borderRadius: BorderRadius.circular(12)),
                      child: Text(micMessageFor(l10n, _micError),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.coral)),
                    ),
                  ],
                  if (_listening || _transcript.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    LiveTranscript(text: _transcript),
                  ],
                  if (_transcript.isNotEmpty && !_listening) ...[
                    const SizedBox(height: 10),
                    OnboardingOption(
                      label: l10n.placementSendAnswer,
                      selected: false,
                      onTap: () => _answer(_transcript),
                    ),
                  ],
                  const SizedBox(height: 6),
                  // FALLBACK HONESTO: saltar hablar (excluye la skill, no puntúa en contra).
                  Center(
                    child: TextButton(
                      onPressed: _skipSpeaking,
                      child: Text(l10n.placementSkipSpeaking,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, color: AppColors.textMuted)),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
