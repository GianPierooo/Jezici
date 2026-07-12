import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/feedback/feedback_fx.dart';
import '../../core/i18n/learn_lang_names.dart';
import '../../core/ui/responsive_center.dart';
import '../../core/theme/app_colors.dart';
import '../../core/ui/jz_sheen.dart';
import '../../data/models/achievement_models.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/primary_button.dart';
import '../learn/widgets/parrot_mascot.dart';

/// CERTIFICADO (Examen.dc, frame ceremonial): ambiente OSCURO `#1C1B2E`, papel
/// crema con doble marco DORADO ornamental, serif ceremonial (Playfair Display),
/// guacamayo como marca de agua, sello "VERIFICADO" y título course-aware
/// ("Certificado de \<idioma\>" real del cert, mig 138). Folio + código de
/// verificación + NOMBRE DEL TITULAR emitidos server-side. Compartible.
/// Degradación honesta: sin "Descargar PDF"/LinkedIn (no hay generador de PDF ni
/// URL pública de verificación — Fase 2); compartir copia folio+código.
class CertificateScreen extends ConsumerStatefulWidget {
  const CertificateScreen({super.key, required this.cert, this.celebrate = true});
  final Certificate cert;
  final bool celebrate;

  @override
  ConsumerState<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends ConsumerState<CertificateScreen> {
  late final ConfettiController _confetti;

  static const _bg = Color(0xFF1C1B2E); // ambiente oscuro del mockup

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
    if (widget.celebrate) {
      _confetti.play();
      FeedbackFx.celebrate();
    }
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  String _fmt(BuildContext context, DateTime? d) =>
      d == null ? '' : MaterialLocalizations.of(context).formatMediumDate(d);

  /// Nombre del titular: el congelado al emitir (mig 133); si el objeto no lo trae
  /// (certificado recién emitido por submit_level_exam), cae a get_profile — la
  /// MISMA fuente (users.display_name/name).
  String _holder() {
    final frozen = widget.cert.holderName?.trim();
    if (frozen != null && frozen.isNotEmpty) return frozen;
    final p = ref.read(profileProvider).asData?.value.name?.trim();
    return (p != null && p.isNotEmpty) ? p : 'Aprendiz';
  }

  void _share() {
    final l10n = AppLocalizations.of(context);
    final c = widget.cert;
    final langName = learnLangName(l10n, c.lang);
    Clipboard.setData(ClipboardData(
        text: 'Jezici · ${l10n.certTitleOf(langName)} · ${_holder()} · ${c.cefrLevel}\n'
            '${l10n.certRowFolio}: ${c.folio}\n'
            '${l10n.certRowVerification}: ${c.verificationCode}'));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(l10n.certShareCopied),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = widget.cert;
    ref.watch(profileProvider); // carga el nombre para el fallback (certs recién emitidos)
    final serif = GoogleFonts.playfairDisplay();
    final langName = learnLangName(l10n, c.lang);
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(l10n.certScreenTitle,
            style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: Stack(
        children: [
          ResponsiveCenter(
            maxWidth: 520,
            child: ListView(
            // + inset inferior (barra de navegación Android); 0 donde no aplica.
            padding: EdgeInsets.fromLTRB(20, 8, 20, 28 + MediaQuery.paddingOf(context).bottom),
            children: [
              // El certificado: papel crema sobre el ambiente oscuro, con sheen
              // lento ("documento que atrapa la luz"). El halo dorado va en un
              // DecoratedBox externo para que el clip del sheen no lo recorte.
              AspectRatio(
                aspectRatio: 1000 / 760,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.gold.withValues(alpha: 0.35),
                          offset: const Offset(0, 10),
                          blurRadius: 30),
                    ],
                  ),
                  child: JzSheen(
                    borderRadius: BorderRadius.circular(18),
                    period: const Duration(milliseconds: 4600),
                    intensity: 0.3,
                    child: Container(
                      decoration: BoxDecoration(
                        // Papel crema del mockup.
                        gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFFFFDF6), Color(0xFFFBF4E4)]),
                        borderRadius: BorderRadius.circular(18),
                        // Marco EXTERIOR dorado (ornamental, no violeta).
                        border: Border.all(color: const Color(0xFFC9A040), width: 3),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Container(
                          decoration: BoxDecoration(
                            // Marco interior fino (doble marco del mockup).
                            border: Border.all(color: const Color(0xFFE8C76A), width: 1.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Marca de agua: guacamayo tenue detrás del texto.
                              Opacity(opacity: 0.07, child: ParrotArt(size: 150)),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('JEZICI',
                                      style: TextStyle(
                                          fontSize: 11,
                                          letterSpacing: 5,
                                          fontWeight: FontWeight.w900,
                                          color: const Color(0xFF8A8068))),
                                  const SizedBox(height: 8),
                                  // Título ceremonial serif, course-aware (mig 138).
                                  Text(l10n.certTitleOf(langName),
                                      textAlign: TextAlign.center,
                                      style: serif.copyWith(
                                          fontSize: 23,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF1A1A2E),
                                          height: 1.05)),
                                  const SizedBox(height: 3),
                                  Text(l10n.certLevelReached,
                                      style: serif.copyWith(
                                          fontStyle: FontStyle.italic,
                                          fontSize: 12,
                                          color: const Color(0xFF7A6F58))),
                                  Text(c.cefrLevel,
                                      style: serif.copyWith(
                                          fontSize: 52,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.goldDark,
                                          height: 1.1)),
                                  Text(l10n.certMcer,
                                      style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF9A8F78))),
                                  const SizedBox(height: 10),
                                  // Titular (Examen.dc "Se certifica que <NOMBRE>").
                                  Text(l10n.certHolderIntro,
                                      style: const TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF8A8068))),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(_holder(),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: serif.copyWith(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF1A1A2E),
                                            height: 1.15)),
                                  ),
                                ],
                              ),
                              // Sello VERIFICADO (esquina inferior derecha).
                              Positioned(
                                right: 12,
                                bottom: 10,
                                child: _Seal(label: l10n.certSealVerified),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _Row(label: l10n.certRowFolio, value: c.folio),
              _Row(label: l10n.certRowVerification, value: c.verificationCode),
              if (c.issuedAt != null)
                _Row(label: l10n.certRowIssued, value: _fmt(context, c.issuedAt)),
              const SizedBox(height: 18),
              // Botón 3D de la casa (labio + hundido).
              PrimaryButton(
                label: l10n.certShare,
                icon: Icons.ios_share_rounded,
                expand: true,
                onPressed: _share,
              ),
              const SizedBox(height: 8),
              Text(l10n.certVerifyNote,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.65))),
            ],
          ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 18,
              maxBlastForce: 22,
              gravity: 0.25,
              colors: const [AppColors.gold, AppColors.coral, AppColors.success, AppColors.primary, Colors.white],
            ),
          ),
        ],
      ),
    );
  }
}

/// Sello circular dorado "VERIFICADO" del mockup (gradiente + estrella).
class _Seal extends StatelessWidget {
  const _Seal({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFE8C76A), Color(0xFFC9A040)]),
            border: Border.all(color: const Color(0xFFFFF3CC), width: 2),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFFC9A040).withValues(alpha: 0.5),
                  offset: const Offset(0, 3),
                  blurRadius: 8),
            ],
          ),
          child: const Icon(Icons.star_rounded, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 3),
        Text(label,
            style: const TextStyle(
                fontSize: 7.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                color: Color(0xFF8A8068))),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.65))),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    fontFamily: 'monospace')),
          ),
        ],
      ),
    );
  }
}
