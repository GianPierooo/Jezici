import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/feedback/feedback_fx.dart';
import '../../core/theme/app_colors.dart';
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
  const LessonPlayerScreen({super.key, required this.lesson, required this.items});

  final LessonModel lesson;
  final List<ContentItemModel> items;

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

  ContentItemModel get _item => widget.items[_index];
  bool get _isStub => isStubType(_item.type);

  @override
  void dispose() {
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
      final choice = await showNoHeartsSheet(context);
      if (!mounted) return;
      if (choice == NoHeartsChoice.refill) {
        setState(() => _hearts = 5);
        _advance();
      } else {
        Navigator.of(context).popUntil((r) => r.isFirst);
      }
      return;
    }
    _advance();
  }

  void _advance() {
    // Registrar la respuesta del ítem actual (para la calificación server-side).
    _answers.add({'item_id': _item.id, 'answer': _jsonAnswer(_answer.value)});
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
    });
  }

  /// Convierte la respuesta a algo JSON-serializable (match: claves a String).
  Object? _jsonAnswer(Object? v) {
    if (v is Map) return v.map((k, val) => MapEntry(k.toString(), val));
    return v; // String, List<String> o null
  }

  Future<void> _finish() async {
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
        MaterialPageRoute(builder: (_) => LessonCompleteScreen(summary: summary)),
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

  void _exit() => Navigator.of(context).popUntil((r) => r.isFirst);

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
                      child: buildExerciseWidget(
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
              isStub: _isStub,
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

    return Container(
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
              Container(
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
