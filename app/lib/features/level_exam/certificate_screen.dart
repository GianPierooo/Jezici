import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/achievement_models.dart';

/// Pantalla de CERTIFICADO (el gran diferenciador): celebración + el certificado
/// con folio y código de verificación emitidos server-side. Compartible.
class CertificateScreen extends StatefulWidget {
  const CertificateScreen({super.key, required this.cert, this.celebrate = true});
  final Certificate cert;
  final bool celebrate;

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  late final ConfettiController _confetti;

  static const _months = [
    'enero','febrero','marzo','abril','mayo','junio','julio','agosto','septiembre','octubre','noviembre','diciembre'
  ];

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
    if (widget.celebrate) _confetti.play();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  String _fmt(DateTime? d) =>
      d == null ? '' : '${d.day} de ${_months[d.month - 1]} de ${d.year}';

  void _share() {
    final c = widget.cert;
    Clipboard.setData(ClipboardData(
        text:
            'Certificado Jezici · Inglés ${c.cefrLevel}\nFolio: ${c.folio}\nVerificación: ${c.verificationCode}'));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Certificado copiado para compartir ✓'),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.cert;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.text,
        title: const Text('Tu certificado', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              // El certificado.
              AspectRatio(
                aspectRatio: 1000 / 700,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                        colors: [Color(0xFFF7F5FF), Color(0xFFFFFDF5)]),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.primary, width: 3),
                    boxShadow: [
                      BoxShadow(color: AppColors.gold.withValues(alpha: 0.3), offset: const Offset(0, 10), blurRadius: 24),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.gold, width: 1.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('JEZICI · CERTIFICADO',
                              style: TextStyle(
                                  fontSize: 11, letterSpacing: 4, fontWeight: FontWeight.w900, color: AppColors.textMuted)),
                          const SizedBox(height: 6),
                          const Text('🦜', style: TextStyle(fontSize: 38)),
                          const SizedBox(height: 4),
                          const Text('Certificado de Inglés',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.text)),
                          const SizedBox(height: 2),
                          const Text('por alcanzar el nivel',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                          const SizedBox(height: 2),
                          Text(c.cefrLevel,
                              style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w900, color: AppColors.goldDark, height: 1)),
                          const Text('Marco Común Europeo (MCER)',
                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _Row(label: 'Folio', value: c.folio),
              _Row(label: 'Código de verificación', value: c.verificationCode),
              if (c.issuedAt != null) _Row(label: 'Emitido el', value: _fmt(c.issuedAt)),
              const SizedBox(height: 18),
              SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _share,
                  icon: const Icon(Icons.ios_share_rounded),
                  label: const Text('COMPARTIR',
                      style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text('Tu código verifica la autenticidad del certificado.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
            ],
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
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.text, fontFamily: 'monospace')),
          ),
        ],
      ),
    );
  }
}
