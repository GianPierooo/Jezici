import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/audio/audio_engine.dart';
import '../../core/feedback/feedback_fx.dart';
import '../../core/speech/speech_recognizer.dart';
import '../../core/theme/app_colors.dart';
import '../../core/ui/jz_transitions.dart';
import '../../data/models/content_item_model.dart';
import '../../data/models/lesson_model.dart';
import '../../data/providers.dart';
import 'exercises/exercise_registry.dart';
import 'grading/grader.dart';
import 'lesson_complete_screen.dart';
import 'widgets/no_hearts_sheet.dart';

enum _Phase { answering, feedback }

/// El loop de la lección: recorre los ejercicios, da feedback inmediato (con
/// calificación local), gestiona vidas y combo, y al terminar llama a la RPC
/// complete_lesson (el SERVIDOR decide XP/oro/skills — Arquitectura §4/§7).
class LessonPlayerScreen extends ConsumerStatefulWidget {
  const LessonPlayerScreen({
    super.key,
    required this.lesson,
    required this.items,
    this.audioProbe,
  });

  final LessonModel lesson;
  final List<ContentItemModel> items;

  /// Comprueba si el audio de una URL existe. Inyectable para tests; por defecto
  /// usa el motor de audio (HEAD en web). Ver Task 2 (degradación con gracia).
  final Future<bool> Function(String url)? audioProbe;

  @override
  ConsumerState<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends ConsumerState<LessonPlayerScreen> {
  final ValueNotifier<Object?> _answer = ValueNotifier<Object?>(null);

  /// Respuestas del usuario por ítem, para que el servidor re-califique.
  final List<Map<String, dynamic>> _answers = [];

  int _index = 0;
  int _hearts = 5; // solo para el feedback/“sin vidas”; el XP lo decide el servidor
  int _comboCorrect = 0; // aciertos seguidos (sonido de combo)
  _Phase _phase = _Phase.answering;
  GradeResult? _result;
  // Respuesta canónica revelada por el servidor SOLO tras responder (mig 055).
  Map<String, dynamic> _expected = const {};
  bool _checking = false;

  /// El audio del ítem de listening actual no resuelve (archivo inexistente) →
  /// se trata como salto SIN penalización: no se pide respuesta a ciegas, no
  /// resta vidas y se OMITE del envío a complete_lesson (no cuenta como fallo).
  bool _audioUnavailable = false;
  bool _finished = false; // llegó al final (para distinguir salida de abandono)

  ContentItemModel get _item => widget.items[_index];
  bool get _isStub => isStubType(_item.type);

  /// Tratamiento "saltar/continuar" sin calificación: stubs (speaking) o un
  /// listening cuyo audio no existe.
  bool get _skippable => _isStub || _audioUnavailable;

  SpeechRecognizer? _speechWarm;

  @override
  void initState() {
    super.initState();
    // Calienta el AudioContext tras el gesto de entrada y precarga el audio del
    // ítem actual y el siguiente (minimiza el time-to-first-audio en listening).
    AudioEngine.instance.unlock();
    _prefetchAround();
    _checkCurrentAudio();
    // Analítica (beta): inicio de lección → embudo dentro de la lección.
    ref.read(progressRepositoryProvider).logEvent('lesson_start',
        props: {'lesson_id': widget.lesson.id, 'items': widget.items.length});
    // Pre-calienta el reconocimiento de voz (permiso de micrófono / motor) si la
    // lección tiene speaking, para que ese ítem no espere al primer uso.
    if (widget.items.any((it) => it.type == ContentItemType.speakingReadAloud)) {
      _speechWarm = createSpeechRecognizer();
      _speechWarm!.init(); // fire-and-forget; init() nunca lanza
    }
  }

  /// Para un ítem de listening, verifica (best-effort) que su audio exista. Si no
  /// resuelve, marca el ítem como saltable sin penalización. Solo aplica al
  /// listening (donde el audio ES la pregunta); el resto no depende del audio.
  void _checkCurrentAudio() {
    if (_item.type != ContentItemType.listening) return;
    final url = (_item.payload['audio_url'] ?? '').toString();
    if (url.isEmpty) return;
    final probe = widget.audioProbe ?? AudioEngine.instance.isUrlAvailable;
    final itemId = _item.id;
    probe(url).then((ok) {
      if (!mounted || ok) return;
      // Solo afectar si seguimos en el mismo ítem (la sonda es asíncrona).
      if (_item.id == itemId) setState(() => _audioUnavailable = true);
    });
  }

  /// Precarga el audio (listening/speaking) del ítem actual y del siguiente.
  void _prefetchAround() {
    for (final i in [_index, _index + 1]) {
      if (i < 0 || i >= widget.items.length) continue;
      final url = widget.items[i].payload['audio_url'];
      if (url is String && url.isNotEmpty) AudioEngine.instance.prefetch(url);
    }
  }

  @override
  void dispose() {
    _speechWarm?.dispose();
    _answer.dispose();
    super.dispose();
  }

  Future<void> _onCheck() async {
    if (_checking) return;
    // Stubs (speaking): no llaman al servidor; el ejercicio ya dio su feedback.
    if (_isStub) {
      setState(() {
        _phase = _Phase.feedback;
        _result = GradeResult.stub;
        _expected = const {};
      });
      return;
    }
    setState(() => _checking = true);
    GradeResult res;
    Map<String, dynamic> expected = const {};
    try {
      // Calificación SERVER-SIDE (mig 055): el cliente nunca tuvo la respuesta.
      final g = await ref
          .read(progressRepositoryProvider)
          .gradeItem(_item.id, _jsonAnswer(_answer.value));
      expected = g.expected;
      res = gradeResultFromServer(
          type: _item.type, correct: g.correct, graded: g.graded, expected: expected);
    } catch (_) {
      res = GradeResult.stub; // fallo de red: no penalizar, avanzar
    }
    if (!mounted) return;
    setState(() {
      _checking = false;
      _phase = _Phase.feedback;
      _result = res;
      _expected = expected;
      if (res.graded) {
        if (res.correct) {
          _comboCorrect++;
          if (_comboCorrect >= 3) {
            FeedbackFx.combo();
          } else {
            FeedbackFx.correct();
          }
        } else {
          _comboCorrect = 0;
          _hearts = (_hearts - 1).clamp(0, 5); // resta vida; la economía es server-side
          FeedbackFx.wrong();
        }
      }
    });
  }

  Future<void> _onContinue() async {
    // Si era el último ítem, la lección ya está completa: no forzar "sin vidas"
    // (evita perder un intento terminado o pedir recarga inútil).
    if (_index + 1 >= widget.items.length) {
      _advance();
      return;
    }
    if (_hearts <= 0) {
      // Punto de fricción: se quedó sin vidas (analítica beta).
      ref.read(progressRepositoryProvider).logEvent('no_hearts',
          props: {'lesson_id': widget.lesson.id, 'at_index': _index});
      final choice = await showNoHeartsSheet(context);
      if (!mounted) return;
      if (choice == NoHeartsChoice.refill) {
        setState(() => _hearts = 5);
        _advance();
      } else {
        _finished = true; // ya logueamos no_hearts; evita doble conteo en _exit
        ref.read(progressRepositoryProvider).logEvent('lesson_quit',
            props: {'lesson_id': widget.lesson.id, 'at_index': _index, 'reason': 'no_hearts'});
        Navigator.of(context).popUntil((r) => r.isFirst);
      }
      return;
    }
    _advance();
  }

  void _advance() {
    // Registrar la respuesta del ítem actual (para la calificación server-side),
    // EXCEPTO si el listening se saltó por audio inexistente: omitirlo evita que
    // el servidor lo califique como fallo (no penaliza la precisión ni vidas).
    if (!_audioUnavailable) {
      _answers.add({'item_id': _item.id, 'answer': _jsonAnswer(_answer.value)});
    }
    if (_index + 1 >= widget.items.length) {
      _finish();
      return;
    }
    setState(() {
      _index++;
      _answer.value = null;
      _result = null;
      _expected = const {};
      _phase = _Phase.answering;
      _audioUnavailable = false;
    });
    _prefetchAround(); // precarga el audio del nuevo ítem actual + el siguiente
    _checkCurrentAudio();
  }

  /// Convierte la respuesta a algo JSON-serializable (match: claves a String).
  Object? _jsonAnswer(Object? v) {
    if (v is Map) return v.map((k, val) => MapEntry(k.toString(), val));
    return v; // String, List<String> o null
  }

  Future<void> _finish() async {
    _finished = true; // terminó todos los ítems → no contar como abandono
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
    try {
      final summary = await ref
          .read(progressRepositoryProvider)
          .completeLesson(widget.lesson.id, _answers);
      // Analítica (fire-and-forget).
      ref.read(progressRepositoryProvider).logEvent('lesson_complete',
          props: {'lesson_id': widget.lesson.id, 'status': summary.status});
      // Refrescar mapa, top bar y skills con los datos nuevos.
      ref.invalidate(lessonProgressProvider);
      ref.invalidate(homeStatsProvider);
      ref.invalidate(skillsProvider);
      ref.invalidate(skillMasteryProvider);
      ref.invalidate(levelExamStatusProvider);
      if (!mounted) return;
      Navigator.of(context).pop(); // cerrar loading
      Navigator.of(context).pushReplacement(
        jzRoute(LessonCompleteScreen(summary: summary, lessonId: widget.lesson.id)),
      );
    } catch (_) {
      if (!mounted) return;
      Navigator.of(context).pop(); // cerrar loading
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('No se pudo guardar tu progreso'),
          content: const Text('Revisa tu conexión e inténtalo de nuevo.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.of(context).popUntil((r) => r.isFirst);
              },
              child: const Text('Salir'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                _finish();
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }
  }

  void _exit() {
    // Salida ANTES de terminar = abandono dentro de la lección (analítica beta).
    if (!_finished) {
      ref.read(progressRepositoryProvider).logEvent('lesson_quit',
          props: {'lesson_id': widget.lesson.id, 'at_index': _index, 'total': widget.items.length});
    }
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.items.length;
    final locked = _phase == _Phase.feedback;

    if (total == 0) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Esta lección aún no tiene ejercicios.',
                    style: TextStyle(
                        color: AppColors.textMuted, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                TextButton(onPressed: _exit, child: const Text('Volver')),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              // Avanza al dar feedback para que el último ítem llegue a 100%.
              progress: (_index + (locked ? 1 : 0)) / total,
              hearts: _hearts,
              onClose: _exit,
            ),
            _ExerciseHeader(skill: _item.skill, index: _index, total: total),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if ((_item.prompt ?? '').isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: Text(
                          _item.prompt!,
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                            color: AppColors.text,
                            height: 1.3,
                          ),
                        ),
                      ),
                    KeyedSubtree(
                      key: ValueKey(_item.id),
                      // En feedback, inyecta la respuesta canónica del servidor
                      // (mig 055) para resaltar lo correcto sin haberla tenido antes.
                      child: _audioUnavailable
                          ? const _AudioUnavailableNotice()
                          : buildExerciseWidget(
                              context,
                              locked ? _item.copyWith(correctAnswer: _expected) : _item,
                              _answer,
                              locked),
                    ),
                  ],
                ),
              ),
            ),
            _BottomArea(
              isStub: _skippable,
              phase: _phase,
              result: _result,
              answer: _answer,
              onCheck: () => _onCheck(),
              onContinue: _onContinue,
              onStubContinue: _advance,
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.progress, required this.hearts, required this.onClose});
  final double progress;
  final int hearts;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: onClose,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFEBEDF5),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 18),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  Container(height: 14, color: const Color(0xFFE5E7F1)),
                  AnimatedFractionallySizedBox(
                    duration: const Duration(milliseconds: 300),
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      height: 14,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primaryLight, AppColors.primary],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 13),
          Icon(Icons.favorite_rounded, color: AppColors.hearts, size: 20),
          const SizedBox(width: 4),
          Text(
            '$hearts',
            style: const TextStyle(
              color: Color(0xFFE03457),
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseHeader extends StatelessWidget {
  const _ExerciseHeader({required this.skill, required this.index, required this.total});
  final String skill;
  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.navActiveBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              skill.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.4,
                color: AppColors.primary,
              ),
            ),
          ),
          Text(
            '${index + 1} / $total',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomArea extends StatelessWidget {
  const _BottomArea({
    required this.isStub,
    required this.phase,
    required this.result,
    required this.answer,
    required this.onCheck,
    required this.onContinue,
    required this.onStubContinue,
  });

  final bool isStub;
  final _Phase phase;
  final GradeResult? result;
  final ValueNotifier<Object?> answer;
  final VoidCallback onCheck;
  final VoidCallback onContinue;
  final VoidCallback onStubContinue;

  @override
  Widget build(BuildContext context) {
    if (phase == _Phase.feedback && result != null) {
      return _FeedbackBar(result: result!, onContinue: onContinue);
    }
    if (isStub) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 22),
        child: _BigButton(
          label: 'CONTINUAR',
          color: AppColors.primary,
          onTap: onStubContinue,
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 22),
      child: ValueListenableBuilder<Object?>(
        valueListenable: answer,
        builder: (context, value, _) {
          final enabled = value != null;
          return _BigButton(
            label: 'COMPROBAR',
            color: enabled ? AppColors.primary : const Color(0xFFC9CDDD),
            onTap: enabled ? onCheck : null,
          );
        },
      ),
    );
  }
}

class _FeedbackBar extends StatelessWidget {
  const _FeedbackBar({required this.result, required this.onContinue});
  final GradeResult result;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final ok = result.correct;
    final bg = ok ? const Color(0xFFE5F8EE) : const Color(0xFFFFE9ED);
    final accent = ok ? AppColors.success : AppColors.hearts;
    final accentDark = ok ? AppColors.successDark : const Color(0xFFD6294B);

    return TweenAnimationBuilder<double>(
      // Entrada de la barra de feedback: sube + aparece (no bloqueante).
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0, end: 1),
      builder: (_, t, child) =>
          Transform.translate(offset: Offset(0, (1 - t) * 26), child: Opacity(opacity: t.clamp(0, 1), child: child)),
      child: Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: bg,
        border: Border(top: BorderSide(color: accent.withValues(alpha: 0.4), width: 2)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 420),
                curve: Curves.elasticOut,
                tween: Tween(begin: 0.4, end: 1),
                builder: (_, s, child) => Transform.scale(scale: s, child: child),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: accentDark, offset: const Offset(0, 4), blurRadius: 0)],
                  ),
                  child: Icon(ok ? Icons.check_rounded : Icons.close_rounded,
                      color: Colors.white, size: 22),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ok ? '¡Correcto! 🦜' : 'Casi… 🦜',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: accentDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ok
                          ? '¡Bien hecho, sigue así!'
                          : 'Respuesta correcta: ${result.correctDisplay}',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: ok ? const Color(0xFF3CA86A) : const Color(0xFFE0556E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _BigButton(label: 'CONTINUAR', color: accent, onTap: onContinue),
        ],
      ),
      ),
    );
  }
}

/// Aviso cuando el audio de un listening no existe: en vez de pedir una
/// respuesta a ciegas, se informa y se permite continuar sin perder vidas.
class _AudioUnavailableNotice extends StatelessWidget {
  const _AudioUnavailableNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F1FB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          const Icon(Icons.volume_off_rounded, color: AppColors.primary, size: 40),
          const SizedBox(height: 12),
          const Text(
            'Audio no disponible',
            style: TextStyle(
                fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.text),
          ),
          const SizedBox(height: 6),
          const Text(
            'Este ejercicio aún no tiene su audio. Lo saltamos: no afecta tus vidas ni tu puntaje.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _BigButton extends StatelessWidget {
  const _BigButton({required this.label, required this.color, this.onTap});
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
