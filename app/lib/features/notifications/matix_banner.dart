import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/progress_models.dart';
import '../../l10n/app_localizations.dart';
import '../learn/widgets/parrot_mascot.dart';
import 'coach_styles.dart';
import 'matix_service.dart';

/// Acento por TONO del coach (CoachTonos.dc): el banner se COLOREA según el
/// estilo real del usuario — dot/tag/avatar/borde. Tokens que ya existían:
/// mano_dura=hearts (Firme), positivo=primary (Animado), rezago=streak
/// (Competitivo), suave=success (Tranquilo).
({Color accent, String tag}) coachAccent(AppLocalizations l10n, String key) =>
    switch (key) {
      'mano_dura' => (accent: AppColors.hearts, tag: l10n.coachTagFirm),
      'positivo' => (accent: AppColors.primary, tag: l10n.coachTagUpbeat),
      'rezago' => (accent: AppColors.streak, tag: l10n.coachTagCompetitive),
      _ => (accent: AppColors.success, tag: l10n.coachTagCalm),
    };

/// Muestra una notificación estilo "push" del sistema en la parte superior
/// (la prueba visible en web de que Matix eligió el copy del estilo correcto).
/// Si el motor suprimió el envío, muestra el motivo (techo / quiet_hours).
void showMatixBanner(BuildContext context, MatixResult res) {
  final overlay = Overlay.of(context);
  final style = CoachStyle.of(res.coachStyle);
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (ctx) => Positioned(
      top: MediaQuery.of(ctx).padding.top + 8,
      left: 12,
      right: 12,
      child: Material(
        color: Colors.transparent,
        child: _MatixBannerCard(res: res, style: style, onClose: () => entry.remove()),
      ),
    ),
  );

  overlay.insert(entry);
  Future.delayed(const Duration(seconds: 5), () {
    if (entry.mounted) entry.remove();
  });
}

class _MatixBannerCard extends StatefulWidget {
  const _MatixBannerCard({required this.res, required this.style, required this.onClose});
  final MatixResult res;
  final CoachStyle style;
  final VoidCallback onClose;

  @override
  State<_MatixBannerCard> createState() => _MatixBannerCardState();
}

class _MatixBannerCardState extends State<_MatixBannerCard> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 280))..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sent = widget.res.sent;
    final tone = coachAccent(l10n, widget.style.key);
    return SlideTransition(
      position: Tween(begin: const Offset(0, -0.4), end: Offset.zero)
          .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutBack)),
      child: FadeTransition(
        opacity: _c,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            // Barra de acento por tono (borde izquierdo del mockup).
            border: Border(left: BorderSide(color: tone.accent, width: 4)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF28326E).withValues(alpha: 0.22),
                offset: const Offset(0, 8),
                blurRadius: 24,
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [tone.accent.withValues(alpha: 0.75), tone.accent],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const ParrotArt(size: 26),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('Jezi',
                            style: TextStyle(
                                fontSize: 13.5, fontWeight: FontWeight.w900, color: AppColors.text)),
                        const SizedBox(width: 6),
                        // Tag del TONO (Firme/Animado/Competitivo/Tranquilo) con
                        // dot + chip del acento, como en CoachTonos.dc.
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: tone.accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                    color: tone.accent, shape: BoxShape.circle)),
                            const SizedBox(width: 5),
                            Text(tone.tag,
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: tone.accent)),
                          ]),
                        ),
                        const Spacer(),
                        Text(l10n.matixNow,
                            style: const TextStyle(
                                fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      sent ? widget.res.copy : suppressReason(widget.res.reason),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: sent ? AppColors.text : AppColors.textMuted,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: widget.onClose,
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
