import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../premium/premium_screen.dart';

/// Simulacros de examen oficial (IELTS / Cambridge) — Modelo_Negocio (premium).
/// Estructura Fase 1: Listening + Reading autocorregibles 100%; Writing +
/// Speaking con respuestas modelo + rúbrica de autoevaluación; reporte de banda
/// por sección. Gating premium (los pagos llegan después).
class SimulacrosScreen extends StatelessWidget {
  const SimulacrosScreen({super.key});

  static const _mocks = <(String, String, String)>[
    ('IELTS Academic', '🎓', '4 secciones · banda 0–9 · ~2 h 45 min'),
    ('IELTS General', '✈️', 'Migración y trabajo · banda 0–9'),
    ('Cambridge B1 Preliminary', '📜', 'Reading, Writing, Listening, Speaking'),
    ('Cambridge B2 First', '🏅', 'Nivel intermedio-alto · 4 destrezas'),
  ];

  void _paywall(BuildContext c) => Navigator.of(c).push(
      MaterialPageRoute(builder: (_) => const PremiumScreen()));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background, elevation: 0, foregroundColor: AppColors.text,
        title: const Text('Simulacros', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          const Text('Practica el examen real',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.text)),
          const SizedBox(height: 4),
          const Text('Simulacros con formato oficial y reporte de banda por sección.',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
          const SizedBox(height: 16),
          // Cómo funcionan las 4 secciones.
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 5), blurRadius: 0)]),
            child: Column(children: const [
              _How(icon: Icons.menu_book_rounded, title: 'Reading · Listening', desc: 'Autocorregibles al 100% — puntaje inmediato.'),
              _How(icon: Icons.edit_rounded, title: 'Writing', desc: 'Escribe y compara con una respuesta modelo + rúbrica.'),
              _How(icon: Icons.mic_rounded, title: 'Speaking', desc: 'Responde en voz alta con el modelo y una autoevaluación guiada.'),
              _How(icon: Icons.assessment_rounded, title: 'Reporte de banda', desc: 'Banda estimada por sección y global.', last: true),
            ]),
          ),
          const SizedBox(height: 18),
          const Text('Disponibles',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.text)),
          const SizedBox(height: 10),
          for (final m in _mocks) _MockCard(emoji: m.$2, title: m.$1, sub: m.$3, onTap: () => _paywall(context)),
          const SizedBox(height: 8),
          Center(
            child: Text('Incluidos en Jezici Premium',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.goldDark)),
          ),
        ],
      ),
    );
  }
}

class _How extends StatelessWidget {
  const _How({required this.icon, required this.title, required this.desc, this.last = false});
  final IconData icon;
  final String title;
  final String desc;
  final bool last;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 14),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 40, height: 40, alignment: Alignment.center,
          decoration: BoxDecoration(color: AppColors.navActiveBg, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: AppColors.primary, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.text)),
          Text(desc, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
        ])),
      ]),
    );
  }
}

class _MockCard extends StatelessWidget {
  const _MockCard({required this.emoji, required this.title, required this.sub, required this.onTap});
  final String emoji;
  final String title;
  final String sub;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 5), blurRadius: 0)]),
          child: Row(children: [
            Container(
              width: 50, height: 50, alignment: Alignment.center,
              decoration: BoxDecoration(color: AppColors.navActiveBg, borderRadius: BorderRadius.circular(15)),
              child: Text(emoji, style: const TextStyle(fontSize: 24))),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w900, color: AppColors.text)),
              const SizedBox(height: 2),
              Text(sub, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
            ])),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(color: const Color(0xFFFFF4D6), borderRadius: BorderRadius.circular(11)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.lock_rounded, color: AppColors.goldDark, size: 14),
                SizedBox(width: 3),
                Text('Premium', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: AppColors.goldDark)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
