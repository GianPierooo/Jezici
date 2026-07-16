import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/speech/speakable_text.dart';
import '../../core/theme/app_colors.dart';
import '../../core/ui/responsive_center.dart';
import '../../data/models/practice_models.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/primary_button.dart';
import '../learn/widgets/parrot_mascot.dart';
import '../lesson/grading/grader.dart' show normalize, nearMatch;

/// REPASO SRS (motor FSRS server-side, F0+F1).
///
/// Recuerdo ACTIVO: el usuario ESCRIBE la respuesta antes de verla (nunca opción
/// múltiple — es el anti-feature del spec §4). Al revelar, califica con 4 botones
/// que modulan el INTERVALO (no el pago).
///
/// Reglas honestas que refleja esta UI (todas decididas en el servidor):
///  · Si lo escrito está MAL, el servidor fuerza rating=1 → aquí solo se ofrece
///    "Otra vez". Ofrecer "Fácil" sobre un fallo sería mentir.
///  · Las falladas VUELVEN al final de la cola de esta sesión.
///  · Se envía TODO junto al terminar: una sola llamada = un solo pago.
class SrsReviewScreen extends ConsumerStatefulWidget {
  const SrsReviewScreen({super.key, required this.session});
  final SrsSession session;

  @override
  ConsumerState<SrsReviewScreen> createState() => _SrsReviewScreenState();
}

class _SrsReviewScreenState extends ConsumerState<SrsReviewScreen> {
  late final List<SrsCard> _queue = List.of(widget.session.cards);
  final _ctrl = TextEditingController();
  final _focus = FocusNode();

  /// Respuestas de la sesión, en orden. El servidor usa la PRIMERA de cada
  /// tarjeta para el pago (anti-duplicado) y todas para reprogramar.
  final List<Map<String, dynamic>> _answers = [];

  int _done = 0; // tarjetas resueltas (para la barra de progreso)
  bool _revealed = false;
  bool _ok = false;
  bool _sending = false;
  PracticeSummary? _summary;

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  SrsCard get _card => _queue.first;

  /// Espejo EXACTO del servidor (jz_grade = exacto o near-match). Solo para el
  /// feedback inmediato; la autoridad sigue siendo el servidor al enviar.
  void _check() {
    if (_revealed || _ctrl.text.trim().isEmpty) return;
    final user = _ctrl.text.trim();
    final ok = normalize(user) == normalize(_card.word) || nearMatch([_card.word], user);
    setState(() {
      _revealed = true;
      _ok = ok;
    });
  }

  void _rate(int rating) {
    final card = _card;
    _answers.add({
      'vocab_id': card.vocabId,
      'rating': rating,
      'answer': _ctrl.text.trim(),
    });
    setState(() {
      _queue.removeAt(0);
      // Fallada → vuelve al final de ESTA sesión (spec §2.1).
      if (rating == 1) {
        _queue.add(card);
      } else {
        _done++;
      }
      _revealed = false;
      _ok = false;
      _ctrl.clear();
    });
    if (_queue.isEmpty) {
      _finish();
    } else {
      _focus.requestFocus();
    }
  }

  Future<void> _finish() async {
    setState(() => _sending = true);
    try {
      final s = await ref.read(progressRepositoryProvider).submitSrs(_answers);
      if (!mounted) return;
      setState(() => _summary = s);
    } catch (_) {
      if (!mounted) return;
      // El repaso ya está hecho; si el envío falla lo decimos, no lo ocultamos.
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.srsSendError)));
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_summary != null) return _Done(summary: _summary!);

    final total = _done + _queue.length;
    final progress = total == 0 ? 0.0 : _done / total;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: Text(l10n.srsTitle,
            style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.text)),
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 560,
          child: Column(children: [
            // Progreso de la sesión.
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: const Color(0xFFE9EBF3),
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                child: _sending
                    ? const Padding(
                        padding: EdgeInsets.only(top: 80),
                        child: Center(child: CircularProgressIndicator()))
                    : _cardView(l10n),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _cardView(AppLocalizations l10n) {
    final c = _card;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        if (c.isNew)
          _Chip(label: l10n.srsNewWord, bg: AppColors.navActiveBg, fg: AppColors.primary),
        const Spacer(),
        Text('${_queue.length}', style: const TextStyle(
            fontWeight: FontWeight.w900, color: AppColors.textMuted)),
      ]),
      const SizedBox(height: 14),

      // ── ANVERSO ──
      Container(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 5), blurRadius: 0),
          ],
        ),
        child: Column(children: [
          Text(c.isCloze ? l10n.srsFillBlank : l10n.srsHowDoYouSay,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w900,
                  letterSpacing: 0.8, color: AppColors.textMuted)),
          const SizedBox(height: 12),
          if (c.isCloze)
            // Oración con hueco (contexto real).
            Text(_blank(c.sentence!, c.word),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 21, fontWeight: FontWeight.w800, height: 1.4,
                    color: AppColors.text))
          else
            Text(c.translation,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.text)),
          if (c.isCloze) ...[
            const SizedBox(height: 8),
            Text(c.translation,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
          ],
        ]),
      ),
      const SizedBox(height: 16),

      // ── ESCRITURA (recuerdo activo) ──
      TextField(
        controller: _ctrl,
        focusNode: _focus,
        autofocus: true,
        enabled: !_revealed,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _check(),
        autocorrect: false,
        enableSuggestions: false,
        textCapitalization: TextCapitalization.none,
        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
        decoration: InputDecoration(
          hintText: l10n.srsTypeHint,
          hintStyle: const TextStyle(color: Color(0xFFAAB0C6), fontWeight: FontWeight.w700),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE9EBF3), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
                color: _ok ? AppColors.success : AppColors.hearts, width: 2),
          ),
        ),
      ),
      const SizedBox(height: 14),

      if (!_revealed)
        // El estado del CTA depende de lo que se escribe: escuchar el controller
        // (escribir no dispara rebuild del State) o el botón nacería muerto.
        // Solo se reconstruye el botón, no la tarjeta.
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _ctrl,
          builder: (_, v, _) => PrimaryButton(
            label: l10n.srsCheck,
            expand: true,
            onPressed: v.text.trim().isEmpty ? null : _check,
          ),
        )
      else
        _reveal(l10n, c),
    ]);
  }

  // ── REVERSO: respuesta + oración completa + 4 botones ──
  Widget _reveal(AppLocalizations l10n, SrsCard c) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _ok ? const Color(0xFFE9F9EF) : const Color(0xFFFFE9ED),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(children: [
          Row(children: [
            Icon(_ok ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: _ok ? AppColors.success : AppColors.hearts, size: 20),
            const SizedBox(width: 8),
            Text(_ok ? l10n.srsCorrect : l10n.srsIncorrect,
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: _ok ? AppColors.success : AppColors.hearts)),
          ]),
          const SizedBox(height: 10),
          // Tocar la palabra/oración para OÍRLA (TTS del idioma del curso).
          SpeakableText(
            c.isCloze ? c.sentence! : c.word,
            align: MainAxisAlignment.center,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.text),
          ),
          if (c.isCloze) ...[
            const SizedBox(height: 6),
            Text(c.word,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primary)),
          ],
          const SizedBox(height: 6),
          Text(c.translation,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
        ]),
      ),
      const SizedBox(height: 14),
      Text(_ok ? l10n.srsHowWasIt : l10n.srsWillRepeat,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
      const SizedBox(height: 10),
      // Si lo escrito está MAL el servidor fuerza rating=1 → solo "Otra vez".
      if (!_ok)
        _RateButton(
          label: l10n.srsAgain,
          color: AppColors.hearts,
          onTap: () => _rate(1),
          expand: true,
        )
      else
        Row(children: [
          Expanded(child: _RateButton(
              label: l10n.srsHard, color: const Color(0xFFE8A33D), onTap: () => _rate(2))),
          const SizedBox(width: 8),
          Expanded(child: _RateButton(
              label: l10n.srsGood, color: AppColors.success, onTap: () => _rate(3))),
          const SizedBox(width: 8),
          Expanded(child: _RateButton(
              label: l10n.srsEasy, color: AppColors.primary, onTap: () => _rate(4))),
        ]),
    ]);
  }

  /// Sustituye la palabra por un hueco. Si la oración ya trae "___" (los cloze
  /// del banco), se deja tal cual.
  String _blank(String sentence, String word) {
    if (sentence.contains('___')) return sentence;
    final re = RegExp(r'\b' + RegExp.escape(word) + r'\b', caseSensitive: false);
    return sentence.replaceFirst(re, '_____');
  }
}

// ── Resumen final ────────────────────────────────────────────────────────────
class _Done extends StatelessWidget {
  const _Done({required this.summary});
  final PracticeSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 480,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const ParrotMascot(size: 96, mood: MascotMood.celebrate),
              const SizedBox(height: 18),
              Text(l10n.srsDoneTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.text)),
              const SizedBox(height: 8),
              Text(l10n.srsDoneSubtitle(summary.correct, summary.graded),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
              const SizedBox(height: 22),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _Chip(label: '+${summary.xpEarned} XP',
                    bg: AppColors.navActiveBg, fg: AppColors.primary),
                const SizedBox(width: 8),
                _Chip(label: '+${summary.goldEarned} 🪙',
                    bg: const Color(0xFFFFF4DA), fg: const Color(0xFF9A6B00)),
                if (summary.streak > 0) ...[
                  const SizedBox(width: 8),
                  _Chip(label: '🔥 ${summary.streak}',
                      bg: const Color(0xFFFFEDE6), fg: const Color(0xFFD85B2B)),
                ],
              ]),
              const SizedBox(height: 28),
              PrimaryButton(
                label: l10n.srsDoneCta,
                expand: true,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ── Piezas ───────────────────────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.bg, required this.fg});
  final String label;
  final Color bg, fg;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Text(label,
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: fg)),
      );
}

/// Botón de calificación con el labio 3D de la casa (hundido al presionar).
class _RateButton extends StatefulWidget {
  const _RateButton({
    required this.label,
    required this.color,
    required this.onTap,
    this.expand = false,
  });
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool expand;
  @override
  State<_RateButton> createState() => _RateButtonState();
}

class _RateButtonState extends State<_RateButton> {
  bool _down = false;
  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.of(context).disableAnimations;
    final depth = Color.lerp(widget.color, Colors.black, 0.28)!;
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      child: AnimatedContainer(
        duration: reduce ? Duration.zero : const Duration(milliseconds: 90),
        transform: Matrix4.translationValues(0, _down ? 3 : 0, 0),
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: _down ? null : [BoxShadow(color: depth, offset: const Offset(0, 4))],
        ),
        child: Text(widget.label,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white)),
      ),
    );
  }
}
