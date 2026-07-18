import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/audio/audio_engine.dart';
import '../../core/audio/music_service.dart';
import '../../core/errors/error_reporter.dart';
import '../../core/feedback/feedback_fx.dart';
import '../../core/speech/speech_recognizer.dart';
import '../../core/speech/word_tts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/ui/jz_transitions.dart';
import '../../core/ui/responsive_center.dart';
import '../../data/models/content_item_model.dart';
import '../../data/models/lesson_model.dart';
import '../../data/models/tip_models.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import 'error_review_screen.dart';
import 'exercises/exercise_registry.dart';
import 'grading/grader.dart';
import 'lesson_complete_screen.dart';
import 'lesson_intro_view.dart';
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
    this.reviewMode = false,
  });

  final LessonModel lesson;
  final List<ContentItemModel> items;

  /// Modo "practicar los fallados" (TASK 1): re-juega un subconjunto SIN llamar a
  /// complete_lesson (no re-otorga XP ni re-cuenta); al terminar vuelve atrás.
  final bool reviewMode;

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

  /// Ítems FALLADOS en la lección (graded && !correct) → repaso final + SRS (TASK 1).
  final List<({ContentItemModel item, String correct})> _failed = [];

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

  /// Fase de PRESENTACIÓN ("enseñar antes de examinar"): se muestra ANTES del primer
  /// ejercicio. No aplica en reviewMode (repaso de fallos). Si no hay nada que
  /// presentar (RPC null) o falla/tarda, se entra directo a los ejercicios.
  bool _presenting = false;
  LessonIntro? _intro;
  Timer? _introTimer;

  ContentItemModel get _item => widget.items[_index];
  bool get _isStub => isStubType(_item.type);

  /// Tratamiento "saltar/continuar" sin calificación: stubs (speaking) o un
  /// listening cuyo audio no existe.
  bool get _skippable => _isStub || _audioUnavailable;

  SpeechRecognizer? _speechWarm;

  @override
  void initState() {
    super.initState();
    MusicService.instance.setSuppressed(true); // sin música del mapa durante el ejercicio
    // Calienta el AudioContext tras el gesto de entrada y precarga el audio del
    // ítem actual y el siguiente (minimiza el time-to-first-audio en listening).
    AudioEngine.instance.unlock();
    _prefetchAround();
    _checkCurrentAudio();
    // Analítica (beta): inicio de lección → embudo dentro de la lección.
    ref.read(progressRepositoryProvider).logEvent('lesson_start',
        props: {'lesson_id': widget.lesson.id, 'items': widget.items.length});
    // T4 (mig 151): las vidas ya son un recurso REAL entre lecciones con
    // regeneración (1 cada 30 min). La lección arranca con las vidas del
    // servidor (best-effort: si no llega, se queda el 5 local de siempre).
    ref.read(progressRepositoryProvider).getHearts().then((h) {
      if (!mounted || _finished) return;
      final v = (h['hearts'] as num?)?.toInt();
      if (v != null && v < _hearts) setState(() => _hearts = v.clamp(0, 5));
    }).catchError((_) {});
    // Pre-calienta el reconocimiento de voz (permiso de micrófono / motor) si la
    // lección tiene speaking, para que ese ítem no espere al primer uso.
    if (widget.items.any((it) => it.type == ContentItemType.speakingReadAloud)) {
      _speechWarm = createSpeechRecognizer();
      _speechWarm!.init(); // fire-and-forget; init() nunca lanza
    }
    // Presentación (enseñar antes de examinar): solo en modo normal, no en repaso.
    if (!widget.reviewMode) _loadIntro();
  }

  /// Carga el payload de presentación (concepto + vocabulario). Si hay algo que
  /// mostrar, entra en fase presenting; si es null/error/tarda >3 s, entra directo
  /// a los ejercicios (nunca bloquea el loop). No toca economía/scoring.
  void _loadIntro() {
    _presenting = true; // muestra el loader de presentación mientras carga
    var settled = false;
    void toExercises() {
      if (settled || !mounted) return;
      settled = true;
      _introTimer?.cancel();
      if (_presenting) setState(() => _presenting = false);
    }

    // Guardarraíl de tiempo: si el RPC tarda, no dejamos al usuario esperando.
    // Timer cancelable (no deja un timer colgado en tests ni al salir).
    _introTimer = Timer(const Duration(seconds: 3), toExercises);
    ref.read(progressRepositoryProvider).getLessonIntro(widget.lesson.id).then((intro) {
      if (settled || !mounted) return;
      if (intro == null || intro.isEmpty) {
        toExercises();
      } else {
        settled = true;
        _introTimer?.cancel();
        setState(() => _intro = intro);
      }
    }).catchError((_) {
      toExercises();
    });
  }

  /// Termina la presentación → primer ejercicio (fase answering, ya inicializada).
  void _startExercises() {
    if (!mounted) return;
    setState(() => _presenting = false);
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
      final p = widget.items[i].payload;
      final audio = p['audio_url'];
      if (audio is String && audio.isNotEmpty) AudioEngine.instance.prefetch(audio);
      // Precarga la imagen del ítem (Twemoji) para que aparezca instantánea (sin
      // spinner) cuando llegue su turno. Post-frame (context listo) + best-effort.
      final img = p['image_url'];
      if (img is String && img.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          precacheImage(ResizeImage(NetworkImage(img), width: 176), context).catchError((_) {});
        });
      }
    }
  }

  @override
  void dispose() {
    MusicService.instance.setSuppressed(false); // restaura la música al volver al mapa
    _introTimer?.cancel();
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
          type: _item.type, correct: g.correct, graded: g.graded, expected: expected, near: g.near);
    } catch (e, st) {
      // Fallo al calificar (red/servidor): NO penalizar al usuario, avanzar. Pero
      // ya no es un no-evento: se REPORTA a Sentry (los de red se filtran solos)
      // para que un grade_item roto deje de ser invisible.
      reportError(e, stackTrace: st, rpc: 'grade_item');
      res = GradeResult.stub;
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
          _hearts = (_hearts - 1).clamp(0, 5); // resta vida (UX local inmediata)
          // T4: persiste la pérdida server-side (regen 1/30min la recupera).
          // Best-effort: las vidas solo gatean la UX; XP/dominio ya son server.
          ref.read(progressRepositoryProvider).loseHeart().catchError((_) => const <String, dynamic>{});
          FeedbackFx.wrong();
          // Rastrea el fallo para el repaso final + refuerzo en SRS (TASK 1).
          _failed.add((item: _item, correct: res.correctDisplay));
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
    // Modo "practicar los fallados": no recompensa ni complete_lesson; vuelve atrás.
    if (widget.reviewMode) {
      if (mounted) Navigator.of(context).pop();
      return;
    }
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
      // Refuerzo en SRS de los ítems fallados (TASK 1): su vocabulario entra con
      // prioridad (due=now) → el error se repasa en días, no solo se corrige hoy.
      if (_failed.isNotEmpty) {
        ref.read(progressRepositoryProvider)
            .prioritizeFailedSrs(_failed.map((f) => f.item.id).toList());
      }
      // Refrescar mapa, top bar y skills con los datos nuevos.
      ref.invalidate(lessonProgressProvider);
      ref.invalidate(homeStatsProvider);
      ref.invalidate(skillsProvider);
      ref.invalidate(skillMasteryProvider);
      ref.invalidate(levelExamStatusProvider);
      if (!mounted) return;
      Navigator.of(context).pop(); // cerrar loading
      // Si hubo fallos: pantalla "Repasa lo que fallaste" ANTES de la recompensa.
      if (_failed.isNotEmpty) {
        Navigator.of(context).pushReplacement(jzRoute(ErrorReviewScreen(
          failed: List.of(_failed),
          lesson: widget.lesson,
          onContinue: (ctx) => Navigator.of(ctx).pushReplacement(
              jzRoute(LessonCompleteScreen(summary: summary, lessonId: widget.lesson.id))),
        )));
      } else {
        Navigator.of(context).pushReplacement(
          jzRoute(LessonCompleteScreen(summary: summary, lessonId: widget.lesson.id)),
        );
      }
    } catch (e, st) {
      // El fin de lección (complete_lesson) es el CORAZÓN del loop: si falla, el
      // usuario ya ve el diálogo de reintento — y ahora Sentry TAMBIÉN lo ve.
      reportError(e, stackTrace: st, rpc: 'complete_lesson');
      if (!mounted) return;
      Navigator.of(context).pop(); // cerrar loading
      final l10n = AppLocalizations.of(context);
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.lessonSaveErrorTitle),
          content: Text(l10n.lessonSaveErrorMsg),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.of(context).popUntil((r) => r.isFirst);
              },
              child: Text(l10n.commonExit),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                _finish();
              },
              child: Text(l10n.commonRetry),
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
    final l10n = AppLocalizations.of(context);
    final total = widget.items.length;
    final locked = _phase == _Phase.feedback;

    // Fase de PRESENTACIÓN (enseñar antes de examinar), antes del primer ejercicio.
    if (_presenting) {
      if (_intro == null) {
        // Cargando el payload (breve); el guardarraíl de 3 s garantiza avanzar.
        return const Scaffold(
          backgroundColor: AppColors.background,
          body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
        );
      }
      return LessonIntroView(
        intro: _intro!,
        title: widget.lesson.title,
        onStart: _startExercises,
        onSkip: _startExercises,
      );
    }

    if (total == 0) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.lessonNoExercises,
                    style: const TextStyle(
                        color: AppColors.textMuted, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                TextButton(onPressed: _exit, child: Text(l10n.commonBack)),
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
              combo: _comboCorrect,
              onClose: _exit,
            ),
            _ExerciseHeader(skill: _item.skill, index: _index, total: total),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: ResponsiveCenter(
                  maxWidth: 560,
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if ((_item.prompt ?? '').isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: _PromptText(item: _item),
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
  const _TopBar(
      {required this.progress,
      required this.hearts,
      required this.combo,
      required this.onClose});
  final double progress;
  final int hearts;
  final int combo; // aciertos seguidos; se muestra el chip desde 3
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
          // Combo en vivo: aparece con "pop" desde 3 aciertos seguidos.
          if (combo >= 3) ...[
            TweenAnimationBuilder<double>(
              key: ValueKey(combo),
              duration: const Duration(milliseconds: 300),
              curve: Curves.elasticOut,
              tween: Tween(begin: 0.6, end: 1),
              builder: (_, s, child) => Transform.scale(scale: s, child: child),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0DB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 13)),
                    const SizedBox(width: 3),
                    Text(AppLocalizations.of(context).comboLabel(combo),
                        style: const TextStyle(
                            color: Color(0xFFE8650A), fontWeight: FontWeight.w900, fontSize: 13)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
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
    final l10n = AppLocalizations.of(context);
    if (phase == _Phase.feedback && result != null) {
      return _FeedbackBar(result: result!, onContinue: onContinue);
    }
    if (isStub) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 22),
        child: ResponsiveCenter(
          maxWidth: 560,
          child: _BigButton(
            label: l10n.commonContinue,
            color: AppColors.primary,
            depthColor: AppColors.primaryDark,
            onTap: onStubContinue,
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 22),
      child: ResponsiveCenter(
        maxWidth: 560,
        child: ValueListenableBuilder<Object?>(
          valueListenable: answer,
          builder: (context, value, _) {
            final enabled = value != null;
            return _BigButton(
              label: l10n.commonCheck,
              color: enabled ? AppColors.primary : const Color(0xFFC9CDDD),
              depthColor: enabled ? AppColors.primaryDark : const Color(0xFFB3B8CC),
              onTap: enabled ? onCheck : null,
            );
          },
        ),
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
    final l10n = AppLocalizations.of(context);
    final ok = result.correct;
    final near = result.near; // "casi" (typo-tolerance, mig 073): aceptado pero no exacto
    final bg = near
        ? const Color(0xFFFFF6E0)
        : (ok ? const Color(0xFFE5F8EE) : const Color(0xFFFFE9ED));
    final accent = near ? AppColors.gold : (ok ? AppColors.success : AppColors.hearts);
    final accentDark = near ? AppColors.goldDark : (ok ? AppColors.successDark : const Color(0xFFD6294B));

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
      child: ResponsiveCenter(
        maxWidth: 560,
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
                  child: Icon(near ? Icons.spellcheck_rounded : (ok ? Icons.check_rounded : Icons.close_rounded),
                      color: Colors.white, size: 22),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      near ? l10n.lessonFeedbackNear : (ok ? l10n.lessonFeedbackCorrect : l10n.lessonFeedbackWrong),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: accentDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      near
                          ? l10n.lessonFeedbackCorrectForm(result.correctDisplay)
                          : (ok ? l10n.lessonFeedbackWellDone : l10n.lessonFeedbackRightAnswer(result.correctDisplay)),
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: near ? AppColors.goldDark : (ok ? const Color(0xFF3CA86A) : const Color(0xFFE0556E)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _BigButton(label: l10n.commonContinue, color: accent, depthColor: accentDark, onTap: onContinue),
        ],
      ),
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
    final l10n = AppLocalizations.of(context);
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
          Text(
            l10n.lessonAudioUnavailableTitle,
            style: const TextStyle(
                fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.text),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.lessonAudioUnavailableMsg,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

/// Enunciado del ejercicio. En word_bank/reorder (Leccion.dc Frame A), la frase
/// ORIGEN entrecomillada lleva un BOTÓN ALTAVOZ a la izquierda que la pronuncia
/// (voz española, `WordTts.speakSource`, disparado por tap → sin unlock iOS,
/// interrumpible, degrada con gracia). Si no hay frase entrecomillada (p.ej. un
/// `reorder` con enunciado genérico), NO se pinta el altavoz — nada que leer.
/// Frase ORIGEN entrecomillada del enunciado de un word_bank/reorder (« », " ",
/// " ", ' '). null si el tipo no aplica o no hay comillas → el altavoz no se pinta.
/// Público para poder verificarlo en tests.
String? promptSourcePhrase(ContentItemModel item) {
  if (item.type != ContentItemType.wordBank && item.type != ContentItemType.reorder) {
    return null;
  }
  final p = item.prompt ?? '';
  final m = RegExp('[«"“‹‘]([^»"”›’]+)'
          '[»"”›’]')
      .firstMatch(p);
  final phrase = m?.group(1)?.trim();
  return (phrase != null && phrase.isNotEmpty) ? phrase : null;
}

class _PromptText extends StatelessWidget {
  const _PromptText({required this.item});
  final ContentItemModel item;

  static const _style = TextStyle(
      fontSize: 21, fontWeight: FontWeight.w900, color: AppColors.text, height: 1.3);

  @override
  Widget build(BuildContext context) {
    final prompt = item.prompt ?? '';
    final source = promptSourcePhrase(item);
    if (source == null) return Text(prompt, style: _style);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SpeakerButton(onTap: () {
          FeedbackFx.tap();
          WordTts.speakSource(source);
        }),
        const SizedBox(width: 12),
        Expanded(child: Text(prompt, style: _style)),
      ],
    );
  }
}

/// Botón altavoz del enunciado (Leccion.dc): tile 40×40 violeta claro con icono.
class _SpeakerButton extends StatelessWidget {
  const _SpeakerButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.navActiveBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.volume_up_rounded, color: AppColors.primary, size: 20),
      ),
    );
  }
}

/// CTA del loop (COMPROBAR / CONTINUAR): el botón más pulsado de la app.
/// Lleva el "labio" 3D (sombra dura `0 6px 0 <depthColor>`) + hundido al presionar,
/// idéntico a `PrimaryButton` (Sistema_Diseno §5) y al mockup Leccion.dc (COMPROBAR
/// `0 6px 0 #4B3FC9`, CONTINUAR verde `0 5px 0 #1E9B52`). Reduce-motion-aware.
class _BigButton extends StatefulWidget {
  const _BigButton({required this.label, required this.color, this.depthColor, this.onTap});
  final String label;
  final Color color;
  final Color? depthColor;
  final VoidCallback? onTap;

  @override
  State<_BigButton> createState() => _BigButtonState();
}

class _BigButtonState extends State<_BigButton> {
  bool _pressed = false;
  bool get _enabled => widget.onTap != null;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final depthColor = widget.depthColor ?? AppColors.primaryDark;
    final double depth = _pressed ? 2 : 6;
    return GestureDetector(
      onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: _enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: _enabled ? () => setState(() => _pressed = false) : null,
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 70),
        transform: Matrix4.translationValues(0, _pressed ? 4 : 0, 0),
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: depthColor, offset: Offset(0, depth), blurRadius: 0),
            if (_enabled)
              BoxShadow(
                color: widget.color.withValues(alpha: 0.4),
                offset: const Offset(0, 12),
                blurRadius: 20,
              ),
          ],
        ),
        child: Text(
          widget.label,
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
