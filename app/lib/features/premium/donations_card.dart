import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/config/donations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/ui/open_url.dart';
import '../../l10n/app_localizations.dart';
import '../learn/widgets/parrot_mascot.dart';

/// T6 · Bloque "Aporta un grano de arena" — donación VOLUNTARIA de apoyo (NO
/// una compra que desbloquee nada dentro del juego; framing honesto). Va DEBAJO
/// del paywall "próximamente". Yape/Plin = número + QR (copiar número);
/// PayPal/Stripe = enlace (deshabilitado "Pronto" si su URL no está configurada).
/// Todo lo que Gian debe rellenar vive en `core/config/donations.dart`.
class DonationsCard extends StatelessWidget {
  const DonationsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 5), blurRadius: 0),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const ParrotMascot(size: 48),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l10n.donateTitle,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.text)),
              const SizedBox(height: 2),
              Text(l10n.donateSubtitle,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted, height: 1.35)),
            ]),
          ),
        ]),
        const SizedBox(height: 16),
        // Yape + Plin (número + QR).
        _WalletMethod(
          name: 'Yape',
          accent: const Color(0xFF742284),
          number: Donations.yapeNumber,
          qrAsset: Donations.yapeQrAsset,
          note: null,
        ),
        const SizedBox(height: 12),
        _WalletMethod(
          name: 'Plin',
          accent: const Color(0xFF00A499),
          number: Donations.plinNumber,
          qrAsset: Donations.plinQrAsset,
          note: Donations.plinSameAsYape ? l10n.donatePlinSameNumber : null,
        ),
        const SizedBox(height: 12),
        // PayPal + Stripe (enlace o "Pronto").
        _LinkMethod(
          name: 'PayPal',
          icon: Icons.account_balance_wallet_rounded,
          accent: const Color(0xFF0070BA),
          url: Donations.paypalUrl,
        ),
        const SizedBox(height: 10),
        _LinkMethod(
          name: l10n.donateStripe,
          icon: Icons.credit_card_rounded,
          accent: const Color(0xFF635BFF),
          url: Donations.stripeUrl,
        ),
        const SizedBox(height: 12),
        Text(l10n.donateVoluntaryNote,
            style: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFA7ABC3), height: 1.35)),
      ]),
    );
  }
}

/// Yape/Plin: fila con nombre + número (copiar) + miniatura de QR (tap = ampliar).
class _WalletMethod extends StatefulWidget {
  const _WalletMethod({
    required this.name,
    required this.accent,
    required this.number,
    required this.qrAsset,
    required this.note,
  });
  final String name, number, qrAsset;
  final String? note;
  final Color accent;
  @override
  State<_WalletMethod> createState() => _WalletMethodState();
}

class _WalletMethodState extends State<_WalletMethod> {
  bool _copied = false;

  void _copy() {
    Clipboard.setData(ClipboardData(text: widget.number));
    setState(() => _copied = true);
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating, content: Text(l10n.donateCopied)));
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  void _showQr() {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('${widget.name} · ${widget.number}',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
            const SizedBox(height: 14),
            _Qr(asset: widget.qrAsset, size: 240, name: widget.name),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.accent.withValues(alpha: 0.18), width: 1.5),
      ),
      child: Row(children: [
        GestureDetector(
          onTap: _showQr,
          child: _Qr(asset: widget.qrAsset, size: 72, name: widget.name),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(widget.name,
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w900, color: widget.accent)),
              if (widget.note != null) ...[
                const SizedBox(width: 6),
                Flexible(
                  child: Text('· ${widget.note}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                ),
              ],
            ]),
            const SizedBox(height: 2),
            Text(l10n.donateScanQr,
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
            const SizedBox(height: 7),
            // Número + copiar.
            GestureDetector(
              onTap: _copy,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(10)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(widget.number,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 1, color: AppColors.text)),
                  const SizedBox(width: 8),
                  Icon(_copied ? Icons.check_rounded : Icons.copy_rounded,
                      size: 16, color: _copied ? AppColors.success : widget.accent),
                ]),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

/// Miniatura/vista del QR. Si el asset falla (Gian aún no lo pegó) → placeholder
/// claro con la ruta a reemplazar.
class _Qr extends StatelessWidget {
  const _Qr({required this.asset, required this.size, required this.name});
  final String asset;
  final double size;
  final String name;
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        asset,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          color: const Color(0xFFF0F1F7),
          child: Icon(Icons.qr_code_2_rounded, size: size * 0.5, color: const Color(0xFFB9BDD0)),
        ),
      ),
    );
  }
}

/// PayPal/Stripe: enlace de pago; si la URL no está configurada → "Pronto".
class _LinkMethod extends StatelessWidget {
  const _LinkMethod(
      {required this.name, required this.icon, required this.accent, required this.url});
  final String name, url;
  final IconData icon;
  final Color accent;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final live = Donations.isLive(url);
    return Opacity(
      opacity: live ? 1 : 0.55,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: live ? () => openExternalUrl(url) : null,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7F1), width: 1.5),
            ),
            child: Row(children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: accent, size: 19),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(live ? l10n.donatePayWith(name) : name,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.text)),
              ),
              if (live)
                Icon(Icons.open_in_new_rounded, size: 18, color: accent)
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                      color: const Color(0xFFEEF0F6), borderRadius: BorderRadius.circular(9)),
                  child: Text(l10n.donateSoon,
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textMuted)),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}
