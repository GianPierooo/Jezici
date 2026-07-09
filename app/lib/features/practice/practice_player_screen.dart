import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/feedback/feedback_fx.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/content_item_model.dart';
import '../learn/widgets/parrot_mascot.dart';
import '../../data/providers.dart';
import '../lesson/exercises/exercise_registry.dart';
import '../lesson/grading/grader.dart';
import 'practice_summary_screen.dart';

enum _Phase { answering, feedback }

/// Reproductor de una sesión de PRÁCTICA. Reusa los mismos ejercicios y grader
/// del loop de la lección, pero sin vidas (baja apuesta) y con temporizador
/// opcional (modo cronometrado). Al terminar llama submit_practice (el SERVIDOR
/// decide XP/oro/SRS).
class PracticePlayerScreen extends ConsumerStatefulWidget {
  const PracticePlayerScreen({
    super.key,
    required this.mode,
    required this.title,
    required this.items,
    this.timeLimitSec,
  });

  final String mode;
  final String title;
  final List<ContentItemModel> items;
  final int? timeLimitSec;

  @override
  ConsumerState<PracticePlayerScreen> createState() => _PracticePlayerScreenState();
}

class _PracticePlayerScreenState extends ConsumerState<PracticePlayerScreen> {
  final ValueNotifier<Object?> _answer = ValueNotifier<Object?>(null);
  final List<Map<String, dynamic>> _answers = [];
  int _index = 0;
  _Phase _phase = _Phase.answering;
  GradeResult? _result;
  Map<String, dynamic> _expected = const {}; // respuesta canónica del servidor (mig 055)
  bool _checking = false;
  Timer? _timer;
  int _remaining = 0;
  bool _finishing = false;

  ContentItemModel get _item => widget.items[_index];
  bool get _isStub => isStubType(_item.type);

  @override
  void initState() {
    super.initState();
    if (widget.timeLimitSec != null) {
      _remaining = widget.timeLimitSec!;
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) return;
        setState(() => _remaining--);
        if (_remaining <= 0) {
          t.cancel();
          _finish();
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _answer.dispose();
    super.dispose();
  }

  Future<void> _onCheck() async {
    if (_checking) return;
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
      // Calificación SERVER-SIDE (mig 055): incluye ítems reales y SRS (vocab).
      final g = await ref
          .read(progressRepositoryProvider)
          .gradeItem(_item.id, _jsonAnswer(_answer.value));
      expected = g.expected;
      res = gradeResultFromServer(
          type: _item.type, correct: g.correct, graded: g.graded, expected: expected);
    } catch (_) {
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
          FeedbackFx.correct();
        } else {
          FeedbackFx.wrong();
        }
      }
    });
  }

  void _advance() {
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

  Object? _jsonAnswer(Object? v) {
    if (v is Map) return v.map((k, val) => MapEntry(k.toString(), val));
    return v;
  }

  Future<void> _finish() async {
    if (_finishing) return;
    _finishing = true;
    _timer?.cancel();
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );
    try {
      final summary =
          await ref.read(progressRepositoryProvider).submitPractice(widget.mode, _answers);
      ref.invalidate(homeStatsProvider);
      ref.invalidate(skillsProvider);
      ref.invalidate(skillMasteryProvider);
      ref.invalidate(practiceStatusProvider);
      if (!mounted) return;
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => PracticeSummaryScreen(summary: summary)),
      );
    } catch (_) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('No se pudo guardar la práctica.')));
      Navigator.of(context).popUntil((r) => r.isFirst);
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
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ParrotArt(size: 44),
                  const SizedBox(height: 8),
                  const Text('Nada que practicar por ahora.',
                      style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.text)),
                  const SizedBox(height: 4),
                  const Text('Completa lecciones para sumar palabras a tu repaso.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  TextButton(onPressed: _exit, child: const Text('Volver')),
                ],
              ),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _exit,
                    child: Container(
                      width: 34, height: 34,
                      decoration: BoxDecoration(
                          color: const Color(0xFFEBEDF5), borderRadius: BorderRadius.circular(11)),
                      child: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 18),
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(children: [
                        Container(height: 14, color: const Color(0xFFE5E7F1)),
                        AnimatedFractionallySizedBox(
                          duration: const Duration(milliseconds: 300),
                          widthFactor: ((_index + (locked ? 1 : 0)) / total).clamp(0.0, 1.0),
                          child: Container(
                            height: 14,
                            decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                    colors: [AppColors.primaryLight, AppColors.primary])),
                          ),
                        ),
                      ]),
                    ),
                  ),
                  if (widget.timeLimitSec != null) ...[
                    const SizedBox(width: 12),
                    Icon(Icons.timer_rounded,
                        size: 18, color: _remaining <= 10 ? AppColors.coral : AppColors.textMuted),
                    const SizedBox(width: 3),
                    Text('$_remaining',
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            color: _remaining <= 10 ? AppColors.coral : AppColors.text)),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: AppColors.navActiveBg, borderRadius: BorderRadius.circular(10)),
                    child: Text(_item.skill.toUpperCase(),
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.primary)),
                  ),
                  Text('${_index + 1} / $total',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textMuted)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if ((_item.prompt ?? '').isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: Text(_item.prompt!,
                            style: const TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w900,
                                color: AppColors.text,
                                height: 1.3)),
                      ),
                    KeyedSubtree(
                      key: ValueKey(_item.id),
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
            _Bottom(
              isStub: _isStub,
              feedback: _phase == _Phase.feedback ? _result : null,
              answer: _answer,
              onCheck: () => _onCheck(),
              onContinue: _advance,
            ),
          ],
        ),
      ),
    );
  }
}

class _Bottom extends StatelessWidget {
  const _Bottom({
    required this.isStub,
    required this.feedback,
    required this.answer,
    required this.onCheck,
    required this.onContinue,
  });
  final bool isStub;
  final GradeResult? feedback;
  final ValueNotifier<Object?> answer;
  final VoidCallback onCheck;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    if (feedback != null) {
      final ok = feedback!.correct;
      final accent = ok ? AppColors.success : AppColors.hearts;
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: ok ? const Color(0xFFE5F8EE) : const Color(0xFFFFE9ED),
          border: Border(top: BorderSide(color: accent.withValues(alpha: 0.4), width: 2)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              feedback!.graded
                  ? (ok ? '¡Correcto! 🦜' : 'Casi… 🦜  ${feedback!.correctDisplay}')
                  : 'Sigue 🦜',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: ok ? AppColors.successDark : const Color(0xFFD6294B)),
            ),
            const SizedBox(height: 12),
            _Btn(label: 'CONTINUAR', color: accent, onTap: onContinue),
          ],
        ),
      );
    }
    if (isStub) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 22),
        child: _Btn(label: 'CONTINUAR', color: AppColors.primary, onTap: onContinue),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 22),
      child: ValueListenableBuilder<Object?>(
        valueListenable: answer,
        builder: (context, value, _) => _Btn(
          label: 'COMPROBAR',
          color: value != null ? AppColors.primary : const Color(0xFFC9CDDD),
          onTap: value != null ? onCheck : null,
        ),
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  const _Btn({required this.label, required this.color, this.onTap});
  final String label;
  final Color color;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
        child: Text(label,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1)),
      ),
    );
  }
}
