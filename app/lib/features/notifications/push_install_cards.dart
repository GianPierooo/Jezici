import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final accepted = await showInstallFlow(context);
    if (accepted && mounted) setState(() => _gone = true);
  }

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

/// Ejecuta el flujo de instalación (compartido por la tarjeta, la fila de Ajustes
/// y la oferta en momento de valor). Chrome/Edge → prompt NATIVO capturado; iOS/
/// Safari → sheet de 3 pasos manual (Compartir → Añadir a pantalla de inicio).
/// Devuelve true SOLO si el usuario ACEPTÓ el prompt nativo (en iOS no hay señal
/// de aceptación, se asume que siguió los pasos).
Future<bool> showInstallFlow(BuildContext context) async {
  if (pwa.canInstall) {
    final r = await pwa.showInstallPrompt();
    return r == 'accepted';
  }
  if (!context.mounted) return false;
  final l10n = AppLocalizations.of(context);
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
        _installStep(1, Icons.ios_share_rounded, l10n.installIosStep1),
        const SizedBox(height: 10),
        _installStep(2, Icons.add_box_outlined, l10n.installIosStep2),
        const SizedBox(height: 10),
        _installStep(3, Icons.check_circle_outline_rounded, l10n.installIosStep3),
      ]),
    ),
  );
  return false;
}

Widget _installStep(int n, IconData icon, String text) => Row(children: [
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

/// Bandera de sesión: solo se ofrece la instalación en momento de valor UNA vez
/// por sesión (no repetir tras cada lección).
bool _valueMomentShownThisSession = false;

/// OFERTA EN MOMENTO DE VALOR (fin de la 1ª lección / celebración): tarjeta
/// "Lleva Jezici a tu pantalla de inicio". Respeta el rechazo: si el usuario la
/// cierra (✕), no se vuelve a ofrecer AUTOMÁTICAMENTE por [_cooldownDays] días
/// (pref local). El botón de Ajustes queda siempre como acceso pasivo. Máximo
/// UNA por sesión. No se muestra en standalone / sin camino de instalación.
class InstallValueMomentCard extends StatefulWidget {
  const InstallValueMomentCard({super.key});
  @override
  State<InstallValueMomentCard> createState() => _InstallValueMomentCardState();
}

class _InstallValueMomentCardState extends State<InstallValueMomentCard> {
  static const _cooldownDays = 14;
  static const _prefKey = 'install_offer_dismissed_at';
  bool? _show; // null = comprobando
  bool _gone = false;

  @override
  void initState() {
    super.initState();
    _decide();
  }

  Future<void> _decide() async {
    // Sin camino de instalación o ya mostrada esta sesión → no ofrecer.
    if (!pwa.canOfferInstall || _valueMomentShownThisSession) {
      if (mounted) setState(() => _show = false);
      return;
    }
    var ok = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final ts = prefs.getInt(_prefKey);
      if (ts != null) {
        final days =
            (DateTime.now().millisecondsSinceEpoch - ts) / (1000 * 60 * 60 * 24);
        if (days < _cooldownDays) ok = false; // en cooldown tras un rechazo
      }
    } catch (_) {}
    if (!mounted) return;
    setState(() => _show = ok);
    if (ok) _valueMomentShownThisSession = true;
  }

  Future<void> _dismiss() async {
    setState(() => _gone = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefKey, DateTime.now().millisecondsSinceEpoch);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_show != true || _gone) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Container(
        padding: const EdgeInsets.fromLTRB(15, 13, 10, 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE7E4FB)),
          boxShadow: const [
            BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 5), blurRadius: 0),
          ],
        ),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration:
                BoxDecoration(color: AppColors.navActiveBg, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.install_mobile_rounded, color: AppColors.primary, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l10n.installValueTitle,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.text)),
              const SizedBox(height: 2),
              Text(l10n.installValueBody,
                  style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                      height: 1.3)),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => showInstallFlow(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                      color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                  child: Text(l10n.installValueCta,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
                ),
              ),
            ]),
          ),
          IconButton(
            onPressed: _dismiss,
            icon: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 20),
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
          ),
        ]),
      ),
    );
  }
}
