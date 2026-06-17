import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/progress_models.dart';
import 'coach_styles.dart';
import 'matix_service.dart';

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
    final sent = widget.res.sent;
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
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryLight, AppColors.primary],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('🦜', style: TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('Matix',
                            style: TextStyle(
                                fontSize: 13.5, fontWeight: FontWeight.w900, color: AppColors.text)),
                        const SizedBox(width: 6),
                        Text('· ${widget.style.emoji} ${widget.style.label}',
                            style: const TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary)),
                        const Spacer(),
                        const Text('ahora',
                            style: TextStyle(
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
