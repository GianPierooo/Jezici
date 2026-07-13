import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_colors.dart';
import '../../core/ui/tour_keys.dart';
import '../../l10n/app_localizations.dart';
import '../learn/widgets/parrot_mascot.dart';

/// ¿El usuario ya vio el tour de bienvenida? (flag LOCAL, por dispositivo). Se
/// asume "visto" hasta que la preferencia carga → NO parpadea el tour a quien ya
/// lo vio; si la clave no existe (usuario nuevo) → se muestra UNA vez.
class WelcomeTourSeen extends Notifier<bool> {
  static const _key = 'welcome_tour_seen';

  @override
  bool build() {
    _load();
    return true; // hasta cargar, tratar como visto (no mostrar)
  }

  Future<void> _load() async {
    try {
      final p = await SharedPreferences.getInstance();
      state = p.getBool(_key) ?? false; // null/false → NO visto → se mostrará
    } catch (_) {/* sin prefs → deja "visto", no molesta */}
  }

  Future<void> markSeen() async {
    state = true;
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(_key, true);
    } catch (_) {}
  }
}

final welcomeTourSeenProvider =
    NotifierProvider<WelcomeTourSeen, bool>(WelcomeTourSeen.new);

/// Un paso del tour: título + cuerpo + (opcional) la clave del elemento REAL a
/// resaltar. Sin clave → tarjeta centrada (bienvenida / cierre).
class _TourStep {
  const _TourStep(this.title, this.body, [this.target]);
  final String title, body;
  final GlobalKey? target;
}

/// Tour guiado de bienvenida con Jezi. Overlay a pantalla completa: fondo
/// oscurecido con un "hueco" sobre el elemento resaltado + burbuja de Jezi con
/// 1-2 frases. Saltar en cualquier momento, atrás/siguiente, progreso. Si un
/// elemento no está montado, ese paso se muestra centrado (degradación con
/// gracia). Reduce-motion-aware.
class WelcomeTour extends StatefulWidget {
  const WelcomeTour({super.key, required this.onFinish});
  final VoidCallback onFinish;
  @override
  State<WelcomeTour> createState() => _WelcomeTourState();
}

class _WelcomeTourState extends State<WelcomeTour> {
  int _i = 0;

  @override
  void initState() {
    super.initState();
    // Re-mide tras el primer layout (por si los targets aún no tenían rect).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  List<_TourStep> _steps(AppLocalizations l) => [
        _TourStep(l.tourWelcomeTitle, l.tourWelcomeBody),
        _TourStep(l.tourMapTitle, l.tourMapBody, TourKeys.topBar),
        _TourStep(l.tourTopbarTitle, l.tourTopbarBody, TourKeys.topBar),
        _TourStep(l.tourPracticeTitle, l.tourPracticeBody, TourKeys.nav[1]),
        _TourStep(l.tourConversarTitle, l.tourConversarBody, TourKeys.nav[2]),
        _TourStep(l.tourLeaguesTitle, l.tourLeaguesBody, TourKeys.nav[3]),
        _TourStep(l.tourProfileTitle, l.tourProfileBody, TourKeys.nav[4]),
        _TourStep(l.tourDoneTitle, l.tourDoneBody),
      ];

  Rect? _rectOf(GlobalKey? key) {
    final ctx = key?.currentContext;
    if (ctx == null) return null;
    final box = ctx.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    final o = box.localToGlobal(Offset.zero);
    return o & box.size;
  }

  void _next(int total) {
    if (_i >= total - 1) {
      widget.onFinish();
    } else {
      setState(() => _i++);
    }
  }

  void _back() {
    if (_i > 0) setState(() => _i--);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final steps = _steps(l);
    final step = steps[_i];
    final reduce = MediaQuery.of(context).disableAnimations;
    final size = MediaQuery.of(context).size;
    final pad = MediaQuery.of(context).padding;

    // Rect del elemento resaltado (global == coords del overlay a pantalla completa).
    final raw = _rectOf(step.target);
    final target = raw?.inflate(6);
    final hole = target == null
        ? null
        : RRect.fromRectAndRadius(target, const Radius.circular(16));

    // Coloca la tarjeta lejos del elemento: debajo si está arriba, encima si abajo.
    final below = target == null || target.center.dy < size.height / 2;

    final card = _TourCard(
      step: step,
      index: _i,
      total: steps.length,
      onSkip: widget.onFinish,
      onBack: _i > 0 ? _back : null,
      onNext: () => _next(steps.length),
      isLast: _i == steps.length - 1,
      reduce: reduce,
    );

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // Fondo oscurecido con el hueco (spotlight). Absorbe taps fuera de la
          // tarjeta para que el usuario no toque la UI por error durante el tour.
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {}, // no-op: solo los botones navegan
              child: CustomPaint(
                painter: _SpotlightPainter(hole),
                size: size,
              ),
            ),
          ),
          // Anillo de realce sobre el elemento.
          if (target != null)
            Positioned(
              left: target.left,
              top: target.top,
              width: target.width,
              height: target.height,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.55),
                          blurRadius: 14,
                          spreadRadius: 1),
                    ],
                  ),
                ),
              ),
            ),
          // Tarjeta de Jezi: centrada (sin target) o pegada al elemento.
          if (target == null)
            Center(child: Padding(padding: const EdgeInsets.all(24), child: card))
          else if (below)
            Positioned(
              left: 20,
              right: 20,
              top: (target.bottom + 14).clamp(pad.top + 8, size.height - 260),
              child: card,
            )
          else
            Positioned(
              left: 20,
              right: 20,
              bottom: (size.height - target.top + 14)
                  .clamp(pad.bottom + 8, size.height - 200),
              child: card,
            ),
        ],
      ),
    );
  }
}

/// La tarjeta blanca con Jezi + texto + progreso + botones (lenguaje de la casa).
class _TourCard extends StatelessWidget {
  const _TourCard({
    required this.step,
    required this.index,
    required this.total,
    required this.onSkip,
    required this.onBack,
    required this.onNext,
    required this.isLast,
    required this.reduce,
  });
  final _TourStep step;
  final int index, total;
  final VoidCallback onSkip, onNext;
  final VoidCallback? onBack;
  final bool isLast, reduce;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final card = Container(
      constraints: const BoxConstraints(maxWidth: 460),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: Color(0x33000000), offset: Offset(0, 8), blurRadius: 24),
        ],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ParrotMascot(size: 52, mood: isLast ? MascotMood.celebrate : MascotMood.encourage),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(step.title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.text)),
              const SizedBox(height: 3),
              Text(step.body,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                      color: AppColors.textMuted)),
            ]),
          ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          // Puntos de progreso.
          Row(
            children: List.generate(total, (i) {
              final on = i == index;
              return Container(
                margin: const EdgeInsets.only(right: 5),
                width: on ? 16 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: on ? AppColors.primary : const Color(0xFFD8DAE8),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
          const Spacer(),
          if (onBack != null)
            TextButton(
              onPressed: onBack,
              child: Text(l.tourBack,
                  style: const TextStyle(
                      fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
            ),
          const SizedBox(width: 4),
          _Cta(label: isLast ? l.tourStart : l.tourNext, onTap: onNext),
        ]),
      ]),
    );

    return Column(mainAxisSize: MainAxisSize.min, children: [
      Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: onSkip,
          style: TextButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6)),
          child: Text(l.tourSkip,
              style: const TextStyle(
                  fontSize: 12.5, fontWeight: FontWeight.w900, color: AppColors.text)),
        ),
      ),
      const SizedBox(height: 8),
      card,
    ]);
  }
}

/// CTA con labio 3D (lenguaje de la casa), hundido al presionar.
class _Cta extends StatefulWidget {
  const _Cta({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  State<_Cta> createState() => _CtaState();
}

class _CtaState extends State<_Cta> {
  bool _down = false;
  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.of(context).disableAnimations;
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: reduce ? Duration.zero : const Duration(milliseconds: 90),
        transform: Matrix4.translationValues(0, _down ? 3 : 0, 0),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(14),
          boxShadow: _down
              ? null
              : const [BoxShadow(color: Color(0xFF4B3FC9), offset: Offset(0, 4))],
        ),
        child: Text(widget.label,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white)),
      ),
    );
  }
}

/// Pinta el fondo oscuro con un hueco redondeado sobre el elemento resaltado.
class _SpotlightPainter extends CustomPainter {
  _SpotlightPainter(this.hole);
  final RRect? hole;
  @override
  void paint(Canvas canvas, Size size) {
    final full = Offset.zero & size;
    final paint = Paint()..color = const Color(0xB3121327); // ~70% oscuro
    if (hole == null) {
      canvas.drawRect(full, paint);
      return;
    }
    final path = Path.combine(
      PathOperation.difference,
      Path()..addRect(full),
      Path()..addRRect(hole!),
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SpotlightPainter old) => old.hole != hole;
}
