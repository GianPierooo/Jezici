import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/ui/jz_glow_pulse.dart';
import '../../core/ui/responsive_center.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/primary_button.dart';
import '../learn/widgets/parrot_mascot.dart';
import 'study_model.dart';
import 'study_theory_model.dart';

/// ESTUDIAR · E-2 — la PRUEBA del tema: 3-6 ítems cortos que validan que
/// entendiste el concepto. Reusa los formatos del motor de ejercicios
/// (cloze / multiple_choice) y el MISMO grader tolerante del resto de la app
/// (`jz_grade`, que desde mig 177 acepta el conjunto de respuestas válidas).
///
/// Es FORMATIVA: el servidor califica pero NO paga XP/oro ni toca el dominio —
/// no altera economía ni certificación. Su premio es cerrar el loop: al
/// terminar, te invita a practicarlo.
class StudyQuizScreen extends ConsumerStatefulWidget {
  const StudyQuizScreen({super.key, required this.unitId, required this.title});
  final String unitId;
  final String title;

  @override
  ConsumerState<StudyQuizScreen> createState() => _StudyQuizScreenState();
}

class _StudyQuizScreenState extends ConsumerState<StudyQuizScreen> {
  final Map<String, String> _answers = {};
  final Map<String, TextEditingController> _ctrls = {};
  bool _sending = false;
  StudyQuizResult? _result;

  @override
  void dispose() {
    for (final c in _ctrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _ctrlFor(String id) =>
      _ctrls.putIfAbsent(id, TextEditingController.new);

  Future<void> _submit(List<StudyQuizItem> quiz) async {
    if (_sending) return;
    setState(() => _sending = true);
    final l10n = AppLocalizations.of(context);
    try {
      for (final q in quiz) {
        if (q.isCloze) _answers[q.id] = _ctrlFor(q.id).text.trim();
      }
      final raw = await ref.read(progressRepositoryProvider).submitStudyQuiz(
            widget.unitId,
            [for (final q in quiz) {'id': q.id, 'answer': _answers[q.id] ?? ''}],
          );
      if (!mounted) return;
      setState(() => _result = StudyQuizResult.fromJson(raw));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.studyQuizError)));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  bool _allAnswered(List<StudyQuizItem> quiz) {
    for (final q in quiz) {
      if (q.isCloze) {
        if (_ctrlFor(q.id).text.trim().isEmpty) return false;
      } else if ((_answers[q.id] ?? '').isEmpty) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theory = ref.watch(studyTheoryProvider(widget.unitId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: Text(l10n.studyQuizTitle,
            style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.text)),
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 560,
          child: theory.maybeWhen(
            data: (t) => (t == null || !t.hasQuiz)
                ? Center(child: Text(l10n.studyQuizError))
                : (_result != null ? _done(l10n, t) : _form(l10n, t)),
            orElse: () =>
                const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          ),
        ),
      ),
    );
  }

  Widget _form(AppLocalizations l10n, StudyTheory t) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      children: [
        Text(widget.title,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
        const SizedBox(height: 14),
        for (var i = 0; i < t.quiz.length; i++) ...[
          _QuestionCard(
            index: i + 1,
            total: t.quiz.length,
            item: t.quiz[i],
            selected: _answers[t.quiz[i].id],
            controller: t.quiz[i].isCloze ? _ctrlFor(t.quiz[i].id) : null,
            onSelect: (v) => setState(() => _answers[t.quiz[i].id] = v),
            onTyped: () => setState(() {}),
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 6),
        JzGlowPulse(
          child: PrimaryButton(
            label: l10n.studyQuizSubmit,
            expand: true,
            onPressed:
                (_sending || !_allAnswered(t.quiz)) ? null : () => _submit(t.quiz),
          ),
        ),
      ],
    );
  }

  Widget _done(AppLocalizations l10n, StudyTheory t) {
    final r = _result!;
    final reduce = MediaQuery.of(context).disableAnimations;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
      children: [
        Center(
          child: ParrotMascot(
            size: 92,
            mood: r.passed ? MascotMood.celebrate : MascotMood.encourage,
          ),
        ),
        const SizedBox(height: 12),
        Text(r.passed ? l10n.studyQuizPassed : l10n.studyQuizRetry,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 21, fontWeight: FontWeight.w900, color: AppColors.text)),
        const SizedBox(height: 6),
        Text(l10n.studyQuizScore(r.correct, r.graded),
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
        const SizedBox(height: 16),
        TweenAnimationBuilder<double>(
          tween: Tween(end: r.graded == 0 ? 0.0 : r.correct / r.graded),
          duration: reduce ? Duration.zero : const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          builder: (_, v, _) => ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: v,
              minHeight: 10,
              backgroundColor: const Color(0xFFE9EBF3),
              valueColor: AlwaysStoppedAnimation(
                  r.passed ? AppColors.success : AppColors.coral),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Repaso honesto: qué fallaste y cuál era la respuesta.
        for (var i = 0; i < t.quiz.length; i++)
          _ReviewRow(
            index: i + 1,
            item: t.quiz[i],
            correct: (r.results[t.quiz[i].id]?['correct'] as bool?) ?? false,
            expected: (r.results[t.quiz[i].id]?['expected'] ?? '').toString(),
          ),
        const SizedBox(height: 18),
        PrimaryButton(
          label: l10n.commonContinue,
          expand: true,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.index,
    required this.total,
    required this.item,
    required this.onSelect,
    required this.onTyped,
    this.selected,
    this.controller,
  });
  final int index;
  final int total;
  final StudyQuizItem item;
  final String? selected;
  final TextEditingController? controller;
  final ValueChanged<String> onSelect;
  final VoidCallback onTyped;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 5), blurRadius: 0),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$index/$total',
              style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textMuted)),
          const SizedBox(height: 6),
          Text(item.prompt,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w800, height: 1.35, color: AppColors.text)),
          const SizedBox(height: 12),
          if (item.isCloze) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: const Color(0xFFF6F7FB), borderRadius: BorderRadius.circular(12)),
              child: Text(item.text ?? '',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.primary)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              onChanged: (_) => onTyped(),
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: l10n.studyQuizHint,
                filled: true,
                fillColor: const Color(0xFFF6F7FB),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ] else
            for (final o in item.options)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () => onSelect(o),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: selected == o ? AppColors.navActiveBg : const Color(0xFFF6F7FB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected == o ? AppColors.primary : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Text(o,
                        style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: selected == o ? AppColors.primary : AppColors.text)),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({
    required this.index,
    required this.item,
    required this.correct,
    required this.expected,
  });
  final int index;
  final StudyQuizItem item;
  final bool correct;
  final String expected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(correct ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 20, color: correct ? AppColors.success : AppColors.coral),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$index. ${item.prompt}',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.text)),
              if (!correct) ...[
                const SizedBox(height: 3),
                Text(l10n.studyQuizExpected(expected),
                    style: const TextStyle(
                        fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.coral)),
              ],
            ],
          ),
        ),
      ]),
    );
  }
}
