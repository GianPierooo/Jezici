import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../learn/widgets/parrot_mascot.dart';
import '../../premium/premium_screen.dart';

/// Resultado de la hoja "sin vidas".
enum NoHeartsChoice { refill, quit }

/// Costo de recargar las 5 vidas — MISMA economía que la tienda (buy_hearts,
/// mig 026). El servidor es la autoridad: cobra y bloquea si no hay oro.
const int kHeartRefillCost = 50;

/// Hoja "te quedaste sin vidas" (SinVidas.dc). La recarga **cobra oro de verdad**
/// (RPC buy_hearts, server-side): descuenta [kHeartRefillCost], y si no hay oro
/// suficiente NO recarga (aviso inline). Devuelve `refill` SOLO si la compra tuvo
/// éxito.
///
/// HONESTIDAD (paso 0, verificado en BD/código): NO existe regeneración de vidas
/// por tiempo — `hearts_updated_at` nunca se lee para sumar vidas, no hay cron, y
/// en la lección las vidas son LOCALES (empiezan en 5 cada lección). Por eso NO se
/// muestra un contador "próxima vida gratis en MM:SS" (sería una promesa falsa,
/// prohibido): en su lugar se dice la verdad — las vidas vuelven GRATIS en la
/// próxima lección. La recarga de pago sirve para seguir ESTA lección ahora.
Future<NoHeartsChoice?> showNoHeartsSheet(BuildContext context) {
  return showModalBottomSheet<NoHeartsChoice>(
    context: context,
    isDismissible: false,
    enableDrag: false,
    // Permite que el contenido (loro + tarjeta + opciones) use la altura que
    // necesite y SCROLLee en pantallas cortas, sin overflow.
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    // Backdrop tintado violeta (SinVidas.dc), no el negro por defecto.
    barrierColor: const Color(0x99191141),
    builder: (context) => const _NoHeartsSheet(),
  );
}

class _NoHeartsSheet extends ConsumerStatefulWidget {
  const _NoHeartsSheet();

  @override
  ConsumerState<_NoHeartsSheet> createState() => _NoHeartsSheetState();
}

class _NoHeartsSheetState extends ConsumerState<_NoHeartsSheet> {
  bool _busy = false;
  String? _error;

  Future<void> _refill() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final l10n = AppLocalizations.of(context);
    try {
      final res = await ref.read(progressRepositoryProvider).buyHearts();
      if (!mounted) return;
      if (res['ok'] == true) {
        ref.invalidate(homeStatsProvider);
        Navigator.of(context).pop(NoHeartsChoice.refill);
      } else {
        setState(() {
          _busy = false;
          _error = l10n.noHeartsInsufficientGold;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = l10n.noHeartsInsufficientGold;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // El loro asoma SOBRE la hoja (SinVidas.dc): Column transparente con el
    // guacamayo y, debajo, la tarjeta blanca que sube un poco bajo él. Scrollable
    // para que nunca desborde en pantallas cortas.
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ParrotMascot(size: 82, mood: MascotMood.idle),
          Transform.translate(
            offset: const Offset(0, -6),
            child: _card(context, l10n),
          ),
        ],
      ),
    );
  }

  Widget _card(BuildContext context, AppLocalizations l10n) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [BoxShadow(color: Color(0x4D000000), offset: Offset(0, -8), blurRadius: 32)],
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 26),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                    color: const Color(0xFFE4E6EE), borderRadius: BorderRadius.circular(3)),
              ),
              const SizedBox(height: 16),
              // Corazones vacíos.
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (_) => const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3.5),
                    child: Icon(Icons.favorite_border_rounded, color: Color(0xFFE2E5F0), size: 26),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(l10n.noHeartsTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.text)),
              const SizedBox(height: 6),
              Text(l10n.noHeartsMsg,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMuted, height: 1.4)),

              // Tarjeta HONESTA "cómo vuelven las vidas" (reemplaza el contador
              // falso): corazón pulsante + copy verdadera (vidas gratis cada lección).
              const SizedBox(height: 16),
              _FreeHeartsCard(l10n: l10n),

              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                      color: AppColors.coral.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.info_outline_rounded, color: AppColors.coral, size: 18),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(_error!,
                            style: const TextStyle(
                                fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.coral)),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 14),
              // OPCIONES.
              // 1) Ver anuncio: Fase 2 (sin infra de ads) → estado "Pronto" honesto,
              //    NO botón muerto (deshabilitado y etiquetado claramente).
              _OptionCard(
                iconBg: const Color(0xFFEEF0F6),
                icon: Icons.play_arrow_rounded,
                iconColor: const Color(0xFF9AA0BC),
                title: l10n.noHeartsWatchAd,
                subtitle: l10n.noHeartsWatchAdSub,
                trailing: _tag(l10n.noHeartsSoon, const Color(0xFF9AA0BC), const Color(0xFFEEF0F6)),
                muted: true,
                onTap: null,
              ),
              const SizedBox(height: 11),
              // 2) Recargar todas con ORO (cobro REAL 50, como el P0).
              _OptionCard(
                iconBg: const Color(0xFFFFF4D6),
                icon: Icons.monetization_on_rounded,
                iconColor: AppColors.goldDark,
                title: l10n.noHeartsRefillAll,
                subtitle: l10n.noHeartsRefillAllSub,
                busy: _busy,
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.monetization_on_rounded, color: AppColors.gold, size: 16),
                  const SizedBox(width: 3),
                  Text('$kHeartRefillCost',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFFC98A12))),
                ]),
                onTap: _busy ? null : _refill,
              ),
              const SizedBox(height: 11),
              // 3) Premium (vidas ilimitadas) → enlaza a la pantalla Premium real.
              _PremiumOption(
                title: l10n.noHeartsUnlimited,
                subtitle: l10n.noHeartsUnlimitedSub,
                onTap: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const PremiumScreen())),
              ),

              const SizedBox(height: 14),
              TextButton(
                onPressed: _busy ? null : () => Navigator.of(context).pop(NoHeartsChoice.quit),
                child: Text(l10n.noHeartsQuit,
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, color: AppColors.textMuted, fontSize: 14)),
              ),
            ],
          ),
        ),
      );

  Widget _tag(String text, Color fg, Color bg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(9)),
        child: Text(text,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: fg)),
      );
}

/// Tarjeta honesta: corazón pulsante + "las vidas vuelven gratis en la próxima
/// lección" (la verdad; NO un contador de regeneración que no existe).
class _FreeHeartsCard extends StatelessWidget {
  const _FreeHeartsCard({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7FB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const _PulsingHeart(),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.noHeartsFreeNext,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.text)),
                const SizedBox(height: 2),
                Text(l10n.noHeartsFreeNextSub,
                    style: const TextStyle(
                        fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF9A9FB8))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Corazón coral que late en un anillo suave (SinVidas.dc), reduce-motion-aware.
class _PulsingHeart extends StatefulWidget {
  const _PulsingHeart();
  @override
  State<_PulsingHeart> createState() => _PulsingHeartState();
}

class _PulsingHeartState extends State<_PulsingHeart> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));
  bool _reduce = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduce = MediaQuery.of(context).disableAnimations;
    if (_reduce) {
      if (_c.isAnimating) _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final heart = const Icon(Icons.favorite_rounded, color: AppColors.hearts, size: 20);
    return Container(
      width: 46,
      height: 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.hearts.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.hearts.withValues(alpha: 0.25), width: 2),
      ),
      child: _reduce
          ? heart
          : ScaleTransition(
              scale: Tween<double>(begin: 1.0, end: 1.14)
                  .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)),
              child: heart,
            ),
    );
  }
}

/// Fila-opción del mockup (icon-tile + título/subtítulo + trailing). Con labio 3D
/// sutil y hundido; `muted` = estado no disponible (Pronto), no tappable.
class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.iconBg,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
    this.muted = false,
    this.busy = false,
  });
  final Color iconBg;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;
  final bool muted;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: muted ? 0.6 : 1,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 4), blurRadius: 0),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
                  child: busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2.2, color: AppColors.goldDark))
                      : Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 14.5, fontWeight: FontWeight.w900, color: AppColors.text)),
                      const SizedBox(height: 1),
                      Text(subtitle,
                          style: const TextStyle(
                              fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF9A9FB8))),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Opción Premium: card violeta con labio 3D (SinVidas.dc) → enlaza a Premium.
class _PremiumOption extends StatelessWidget {
  const _PremiumOption({required this.title, required this.subtitle, required this.onTap});
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Color(0xFF6C5CE7), Color(0xFF5B4ECF)]),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(color: AppColors.primaryDark, offset: Offset(0, 5), blurRadius: 0),
              BoxShadow(color: Color(0x4D6C5CE7), offset: Offset(0, 12), blurRadius: 22),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFFDD7A), Color(0xFFF4B400)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.favorite_rounded, color: Color(0xFF5B3A00), size: 20),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 14.5, fontWeight: FontWeight.w900, color: Colors.white)),
                    const SizedBox(height: 1),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 11.5, fontWeight: FontWeight.w800, color: Colors.white.withValues(alpha: 0.8))),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFFDD7A), Color(0xFFF4B400)]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('PREMIUM',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF5B3A00))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
