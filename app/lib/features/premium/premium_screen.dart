import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Paywall de Jezici Premium (Modelo_Negocio). Fase 1: solo estructura/UI, sin
/// pagos reales. Lista los beneficios premium y marca el plan gratis vs premium.
class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  static const _features = <(IconData, String, String)>[
    (Icons.school_rounded, 'Simulacros IELTS y Cambridge', 'Exámenes de práctica con formato real'),
    (Icons.favorite_rounded, 'Vidas infinitas', 'Practica sin esperar a que regeneren'),
    (Icons.replay_rounded, 'Reintentos ilimitados', 'Repite checkpoints y exámenes sin límite'),
    (Icons.block_rounded, 'Sin anuncios', 'Aprende sin interrupciones'),
    (Icons.insights_rounded, 'Informes avanzados', 'Análisis profundo de tus 4 habilidades'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background, elevation: 0, foregroundColor: AppColors.text,
        title: const Text('Jezici Premium', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Color(0xFF7A6BF0), AppColors.primary, Color(0xFF5B4ECF)]),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(children: const [
              Text('👑', style: TextStyle(fontSize: 44)),
              SizedBox(height: 8),
              Text('Lleva tu inglés más lejos',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
              SizedBox(height: 4),
              Text('Todo lo del plan gratis, y más para certificarte antes.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFE8E5FF))),
            ]),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 5), blurRadius: 0)]),
            child: Column(children: [
              for (final f in _features) Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(children: [
                  Container(
                    width: 40, height: 40, alignment: Alignment.center,
                    decoration: BoxDecoration(color: AppColors.navActiveBg, borderRadius: BorderRadius.circular(12)),
                    child: Icon(f.$1, color: AppColors.primary, size: 20)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(f.$2, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.text)),
                    Text(f.$3, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                  ])),
                  const Icon(Icons.lock_rounded, color: AppColors.gold, size: 18),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: () => ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(const SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text('Los pagos llegan pronto. ¡Gracias por tu interés! 💜'))),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold, foregroundColor: AppColors.text,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: const Text('HAZTE PREMIUM · PRÓXIMAMENTE',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.5)),
            ),
          ),
          const SizedBox(height: 8),
          const Text('Estás en el plan Gratis. Todo el contenido A1 es gratuito.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
