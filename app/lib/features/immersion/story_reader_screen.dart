import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/speech/speakable_text.dart';
import '../../core/ui/responsive_center.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/immersion_models.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/primary_button.dart';
import '../learn/widgets/parrot_mascot.dart';
import '../lesson/exercises/audio_play_button.dart';

/// Lector de historia: lee/escucha los segmentos (input comprensible) → responde
/// preguntas de comprensión → resultado calificado SERVER-SIDE (submit_story).
class StoryReaderScreen extends ConsumerStatefulWidget {
  const StoryReaderScreen({super.key, required this.storyId});
  final String storyId;

  @override
  ConsumerState<StoryReaderScreen> createState() => _StoryReaderScreenState();
}

enum _Phase { reading, questions, result }

class _StoryReaderScreenState extends ConsumerState<StoryReaderScreen> {
  StoryDetail? _story;
  bool _loading = true;
  _Phase _phase = _Phase.reading;
  int _qIndex = 0;
  final Map<int, String> _answers = {};
  final _clozeCtrl = TextEditingController();
  bool _submitting = false;
  StoryResult? _result;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _clozeCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final s = await ref.read(progressRepositoryProvider).fetchStory(widget.storyId);
      if (!mounted) return;
      setState(() {
        _story = s;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _startQuestions() => setState(() {
        _phase = _Phase.questions;
        _qIndex = 0;
        _clozeCtrl.text = '';
      });

  Future<void> _next() async {
    final q = _story!.questions[_qIndex];
    if (q.isCloze) _answers[q.i] = _clozeCtrl.text.trim();
    if (_qIndex < _story!.questions.length - 1) {
      setState(() {
        _qIndex++;
        _clozeCtrl.text = _answers[_story!.questions[_qIndex].i] ?? '';
      });
    } else {
      await _submit();
    }
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final answers = _story!.questions
        .map((q) => {'i': q.i, 'answer': _answers[q.i] ?? ''})
        .toList();
    try {
      final res = await ref.read(progressRepositoryProvider).submitStory(widget.storyId, answers);
      if (!mounted) return;
      setState(() {
        _result = res;
        _phase = _Phase.result;
        _submitting = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).immSubmitError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.text),
        title: Text(_story?.title ?? l10n.immStoryTitle,
            style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.text)),
      ),
      body: ResponsiveCenter(
        maxWidth: 640,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _story == null
                ? Center(child: Text(l10n.immStoryLoadError))
                : switch (_phase) {
                    _Phase.reading => _reading(),
                    _Phase.questions => _questions(),
                    _Phase.result => _resultView(),
                  },
      ),
    );
  }

  // ── Lectura/escucha de segmentos ──────────────────────────────────────────
  Widget _reading() {
    final s = _story!;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            children: [
              if (s.intro.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(14)),
                  child: Text(s.intro,
                      style: const TextStyle(
                          fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.primaryDark, height: 1.35)),
                ),
              for (final seg in s.segments) _segment(seg),
              if (s.glossary.isNotEmpty) _glossary(s),
            ],
          ),
        ),
        _bottomBar(PrimaryButton(
          label: AppLocalizations.of(context).immAnswerQuestions,
          expand: true,
          onPressed: _startQuestions,
        )),
      ],
    );
  }

  Widget _segment(StorySegment seg) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 4), blurRadius: 0)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (seg.audioUrl.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2, right: 12),
              child: AudioPlayButton(url: seg.audioUrl, label: AppLocalizations.of(context).immListen, big: false, surface: 'story'),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(seg.en,
                    style: const TextStyle(
                        fontSize: 16.5, fontWeight: FontWeight.w800, color: AppColors.text, height: 1.3)),
                if (seg.es.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(seg.es,
                      style: const TextStyle(
                          fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textMuted, height: 1.3)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _glossary(StoryDetail s) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        leading: const Text('📒', style: TextStyle(fontSize: 20)),
        title: Text(AppLocalizations.of(context).immGlossary,
            style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900, color: AppColors.text)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: [
          for (final g in s.glossary)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Palabra META: tócala para oírla (Web Speech, idioma del curso).
                  Expanded(
                    child: SpeakableText(g.word,
                        style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.text)),
                  ),
                  Expanded(
                    child: Text(g.translation,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ── Preguntas de comprensión ──────────────────────────────────────────────
  Widget _questions() {
    final l10n = AppLocalizations.of(context);
    final q = _story!.questions[_qIndex];
    final total = _story!.questions.length;
    final answered = q.isCloze ? _clozeCtrl.text.trim().isNotEmpty : _answers[q.i] != null;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (_qIndex + 1) / total,
                  minHeight: 8,
                  backgroundColor: const Color(0xFFE7E8F2),
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
              const SizedBox(height: 6),
              Text(l10n.immQuestionOf(_qIndex + 1, total),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            children: [
              Text(q.prompt,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.text, height: 1.3)),
              const SizedBox(height: 16),
              if (q.isCloze) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: Colors.white, borderRadius: BorderRadius.circular(14)),
                  child: Text(q.text,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.text, height: 1.4)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _clozeCtrl,
                  onChanged: (_) => setState(() {}),
                  textInputAction: TextInputAction.done,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  decoration: InputDecoration(
                    hintText: l10n.immWriteWord,
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE5E7F1), width: 2)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                  ),
                ),
              ] else
                for (final opt in q.options) _option(q, opt),
            ],
          ),
        ),
        _bottomBar(PrimaryButton(
          label: _qIndex < total - 1 ? l10n.immNext : (_submitting ? l10n.immSending : l10n.immFinish),
          expand: true,
          onPressed: (!answered || _submitting) ? null : _next,
        )),
      ],
    );
  }

  Widget _option(StoryQuestion q, String opt) {
    final selected = _answers[q.i] == opt;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() => _answers[q.i] = opt),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary.withValues(alpha: 0.12) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: selected ? AppColors.primary : const Color(0xFFE5E7F1), width: 2),
          ),
          child: Row(
            children: [
              Icon(selected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
                  color: selected ? AppColors.primary : AppColors.textMuted, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(opt,
                    style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: selected ? AppColors.primaryDark : AppColors.text)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Resultado (calificado server-side) ────────────────────────────────────
  Widget _resultView() {
    final l10n = AppLocalizations.of(context);
    final r = _result!;
    final pct = (r.score * 100).round();
    final good = r.correct == r.total;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            children: [
              // Mascota celebrando/animando (antes un emoji suelto).
              Center(
                child: ParrotMascot(
                    size: 64, mood: good ? MascotMood.celebrate : MascotMood.encourage),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(good ? l10n.immPerfect : l10n.immGoodReading,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.text)),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(l10n.immScoreLine(pct, r.correct, r.total),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
              ),
              if (r.xpEarned > 0) ...[
                const SizedBox(height: 10),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(12)),
                    child: Text('+${r.xpEarned} XP',
                        style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.goldDark)),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              for (int k = 0; k < _story!.questions.length; k++) _reviewRow(k),
            ],
          ),
        ),
        _bottomBar(PrimaryButton(
          label: l10n.immDone,
          expand: true,
          onPressed: () => Navigator.of(context).pop(),
        )),
      ],
    );
  }

  Widget _reviewRow(int k) {
    final q = _story!.questions[k];
    final pq = _result!.perQuestion.firstWhere((e) => e.i == q.i,
        orElse: () => (i: q.i, correct: false, expected: ''));
    return Container(
      padding: const EdgeInsets.all(13),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(pq.correct ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: pq.correct ? AppColors.success : AppColors.hearts, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(q.prompt,
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.text)),
                if (!pq.correct && pq.expected.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(AppLocalizations.of(context).immAnswerLabel(pq.expected),
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.success)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomBar(Widget child) => Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: Color(0xFFE7E8F2))),
        ),
        child: SafeArea(top: false, child: child),
      );
}
