import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/pwa/pwa_bridge.dart' as pwa;
import '../../core/theme/app_colors.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/primary_button.dart';

/// T4 · Tarjeta "Activar avisos push" — el permiso se pide EXPLÍCITAMENTE al
/// tocar (nunca automático al cargar). Estados honestos:
///  - ready       → CTA "Activar notificaciones" (pide permiso + suscribe + guarda).
///  - subscribed  → check verde "activadas" (desaparece tras un momento… se
///                  muestra compacta para confirmar).
///  - denied      → cómo desbloquear en el navegador.
///  - unsupported → en iOS Safari: instala la app primero (iOS 16.4+); en otros,
///                  navegador sin soporte. No se muestra en no-web.
class PushOptInCard extends ConsumerStatefulWidget {
  const PushOptInCard({super.key});
  @override
  ConsumerState<PushOptInCard> createState() => _PushOptInCardState();
}

class _PushOptInCardState extends ConsumerState<PushOptInCard> {
  pwa.PushState? _state;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final s = await pwa.pushState();
    if (mounted) setState(() => _state = s);
  }

  Future<void> _enable() async {
    if (_busy) return;
    setState(() => _busy = true);
    final sub = await pwa.pushSubscribe(); // prompt del navegador BAJO el gesto
    if (sub != null) {
      try {
        await ref
            .read(progressRepositoryProvider)
            .savePushSubscription(sub.endpoint, sub.p256dh, sub.auth);
      } catch (_) {}
    }
    if (!mounted) return;
    setState(() => _busy = false);
    await _check();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final s = _state;
    if (s == null) return const SizedBox.shrink(); // aún comprobando
    // Suscrito → confirmación compacta.
    if (s == pwa.PushState.subscribed) {
      return _shell(
        icon: Icons.notifications_active_rounded,
        iconColor: AppColors.success,
        iconBg: const Color(0xFFE7F8EE),
        title: l10n.pushEnabledTitle,
        body: l10n.pushEnabledBody,
      );
    }
    if (s == pwa.PushState.denied) {
      return _shell(
        icon: Icons.notifications_off_rounded,
        iconColor: const Color(0xFF9AA0BC),
        iconBg: const Color(0xFFEEF0F6),
        title: l10n.pushDeniedTitle,
        body: l10n.pushDeniedBody,
      );
    }
    if (s == pwa.PushState.unsupported) {
      // iOS Safari sin instalar → el push llega SOLO con la PWA instalada (16.4+).
      if (pwa.isIosSafari && !pwa.isStandalone) {
        return _shell(
          icon: Icons.ios_share_rounded,
          iconColor: AppColors.primary,
          iconBg: AppColors.navActiveBg,
          title: l10n.pushIosInstallTitle,
          body: l10n.pushIosInstallBody,
        );
      }
      return const SizedBox.shrink(); // navegador sin soporte: no molestar
    }
    // ready → invitación con CTA explícito.
    return _shell(
      icon: Icons.notifications_rounded,
      iconColor: AppColors.primary,
      iconBg: AppColors.navActiveBg,
      title: l10n.pushOptInTitle,
      body: l10n.pushOptInBody,
      cta: PrimaryButton(
        label: l10n.pushOptInCta,
        onPressed: _busy ? null : _enable,
      ),
    );
  }

  Widget _shell({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String body,
    Widget? cta,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 5), blurRadius: 0),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration:
                  BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: iconColor, size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14.5, fontWeight: FontWeight.w900, color: AppColors.text)),
                const SizedBox(height: 2),
                Text(body,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                        height: 1.35)),
              ]),
            ),
          ]),
          if (cta != null) ...[
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: cta),
          ],
        ]),
      ),
    );
  }
}

/// T4 · Tarjeta "Instalar Jezici": Chrome/Edge (Android+desktop) → prompt
/// nativo capturado de beforeinstallprompt; iOS/Safari → instrucciones
/// (Compartir → Añadir a pantalla de inicio). Ya instalada → no se muestra.
class InstallAppCard extends StatefulWidget {
  const InstallAppCard({super.key});
  @override
  State<InstallAppCard> createState() => _InstallAppCardState();
}

class _InstallAppCardState extends State<InstallAppCard> {
  bool _gone = false;

  Future<void> _install() async {
    final l10n = AppLocalizations.of(context);
    if (pwa.canInstall) {
      final r = await pwa.showInstallPrompt();
      if (r == 'accepted' && mounted) setState(() => _gone = true);
      return;
    }
    // iOS (o navegador sin prompt): instrucciones claras.
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 42,
            height: 5,
            decoration: BoxDecoration(
                color: const Color(0xFFE4E6EE), borderRadius: BorderRadius.circular(3)),
          ),
          const SizedBox(height: 16),
          Text(l10n.installIosTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.text)),
          const SizedBox(height: 14),
          _step(1, Icons.ios_share_rounded, l10n.installIosStep1),
          const SizedBox(height: 10),
          _step(2, Icons.add_box_outlined, l10n.installIosStep2),
          const SizedBox(height: 10),
          _step(3, Icons.check_circle_outline_rounded, l10n.installIosStep3),
        ]),
      ),
    );
  }

  Widget _step(int n, IconData icon, String text) => Row(children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: AppColors.navActiveBg, shape: BoxShape.circle),
          child: Text('$n',
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.primary)),
        ),
        const SizedBox(width: 10),
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: const TextStyle(
                  fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.text)),
        ),
      ]);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Ya instalada (standalone) o descartada → nada. En navegador sin prompt y
    // sin ser iOS tampoco insistimos (no hay camino de instalación limpio).
    if (_gone || pwa.isStandalone) return const SizedBox.shrink();
    if (!pwa.canInstall && !pwa.isIosSafari) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: _install,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6C5CE7), Color(0xFF5B4ECF)]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: AppColors.primaryDark, offset: Offset(0, 5), blurRadius: 0),
              ],
            ),
            child: Row(children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.install_mobile_rounded, color: Colors.white, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l10n.installTitle,
                      style: const TextStyle(
                          fontSize: 14.5, fontWeight: FontWeight.w900, color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(l10n.installBody,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.85))),
                ]),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 22),
            ]),
          ),
        ),
      ),
    );
  }
}
