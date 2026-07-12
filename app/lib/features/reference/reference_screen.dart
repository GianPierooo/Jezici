import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/skills.dart';
import '../../core/speech/speakable_text.dart';
import '../../core/ui/responsive_center.dart';
import '../../core/theme/app_colors.dart';
import '../../core/ui/jz_skeleton.dart';
import '../../core/ui/jz_transitions.dart';
import '../../data/models/level_exam_models.dart';
import '../../data/models/tip_models.dart';
import '../../data/providers.dart';
import '../practice/practice_player_screen.dart';

/// Referencia / "Repaso" (capa enseña, estilo Busuu Grammar Review): navega los
/// conceptos curados por habilidad, muestra tu DOMINIO por skill, resalta tu
/// punto flojo y ofrece "practicar esto" (→ refuerzo). Determinista, sin IA.
class ReferenceScreen extends ConsumerStatefulWidget {
  const ReferenceScreen({super.key});

  @override
  ConsumerState<ReferenceScreen> createState() => _ReferenceScreenState();
}

class _ReferenceScreenState extends ConsumerState<ReferenceScreen> {
  static const _order = ['reading', 'listening', 'writing', 'speaking'];
  static const _gradable = {'reading', 'writing'};
  String? _loading;

  IconData _skillIcon(String s) => switch (s) {
        'reading' => Icons.menu_book_rounded,
        'listening' => Icons.headphones_rounded,
        'writing' => Icons.edit_rounded,
        'speaking' => Icons.record_voice_over_rounded,
        _ => Icons.school_rounded,
      };

  Future<void> _practice(String mode, {String? skill, required String title}) async {
    if (_loading != null) return;
    setState(() => _loading = mode + (skill ?? ''));
    try {
      final s = await ref.read(progressRepositoryProvider).startPractice(mode, skill: skill);
      if (!mounted) return;
      if (s.items.isEmpty) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('¡Nada que reforzar ahora! Vas al día. 🎉')));
        return;
      }
      await Navigator.of(context).push(jzRoute(
          PracticePlayerScreen(mode: mode, title: title, items: s.items)));
      ref.invalidate(skillMasteryProvider);
      ref.invalidate(referenceProvider);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('No se pudo iniciar la práctica.')));
      }
    } finally {
      if (mounted) setState(() => _loading = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final refAsync = ref.watch(referenceProvider);
    final mastery = ref.watch(skillMasteryProvider).value;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Repaso',
            style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.text)),
      ),
      body: refAsync.when(
        loading: () => ListView(children: const [JzListSkeleton()]),
        error: (e, _) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.cloud_off_rounded, color: AppColors.textMuted, size: 40),
            const SizedBox(height: 10),
            const Text('No se pudo cargar el repaso.',
                style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textMuted)),
            TextButton(onPressed: () => ref.invalidate(referenceProvider), child: const Text('Reintentar')),
          ]),
        ),
        data: (data) => _body(context, data, mastery),
      ),
    );
  }

  Widget _body(BuildContext context, ReferenceData data, SkillMasteryStatus? mastery) {
    if (data.tips.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => ref.invalidate(referenceProvider),
        child: ResponsiveCenter(
          maxWidth: 560,
          child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 60),
            Center(
              child: Column(children: [
                const Icon(Icons.auto_stories_rounded, color: AppColors.textMuted, size: 44),
                const SizedBox(height: 12),
                const Text('Aún no hay conceptos para este curso.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textMuted)),
              ]),
            ),
          ],
        ),
        ),
      );
    }
    final grouped = data.bySkill;
    final weak = data.weakest;
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(referenceProvider),
      child: ResponsiveCenter(
        maxWidth: 560,
        child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 110),
        children: [
          const Text('Tus conceptos clave, por habilidad. Repasa y practica lo flojo.',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
          const SizedBox(height: 14),
          if (weak != null) _WeakBanner(
            skill: weak,
            loading: _loading == 'weakness',
            onPractice: () => _practice('weakness', title: 'Refuerzo de debilidades'),
          ),
          for (final skill in _order)
            if ((grouped[skill] ?? const []).isNotEmpty) ...[
              const SizedBox(height: 18),
              _SkillHeader(
                skill: skill,
                icon: _skillIcon(skill),
                mastery: mastery?.bySkill(skill),
                isWeak: skill == weak,
                canPractice: _gradable.contains(skill),
                loading: _loading == 'skill$skill',
                onPractice: () => _practice('skill', skill: skill, title: 'Práctica de ${kSkillEs[skill] ?? skill}'),
              ),
              const SizedBox(height: 8),
              for (final tip in grouped[skill]!) _TipTile(tip: tip),
            ],
        ],
      ),
      ),
    );
  }
}

class _WeakBanner extends StatelessWidget {
  const _WeakBanner({required this.skill, required this.onPractice, required this.loading});
  final String skill;
  final VoidCallback onPractice;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primaryLight, AppColors.primary]),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.center_focus_strong_rounded, color: Colors.white, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tu punto flojo: ${kSkillEs[skill] ?? skill}',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(height: 2),
                const Text('Practica para subir tu dominio.',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: loading ? null : onPractice,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: loading
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2.2, color: AppColors.primary))
                  : const Text('Practicar',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.primary)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillHeader extends StatelessWidget {
  const _SkillHeader({
    required this.skill,
    required this.icon,
    required this.mastery,
    required this.isWeak,
    required this.canPractice,
    required this.loading,
    required this.onPractice,
  });
  final String skill;
  final IconData icon;
  final SkillMastery? mastery;
  final bool isWeak;
  final bool canPractice;
  final bool loading;
  final VoidCallback onPractice;

  @override
  Widget build(BuildContext context) {
    final pct = ((mastery?.masteryPct ?? 0) * 100).round();
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: AppColors.navActiveBg, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(kSkillEs[skill] ?? skill,
                    style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w900, color: AppColors.text)),
                const SizedBox(width: 8),
                Text('$pct% dominio',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
              ]),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: (mastery?.masteryPct ?? 0).clamp(0, 1),
                  minHeight: 6,
                  backgroundColor: const Color(0xFFE6E8F2),
                  valueColor: AlwaysStoppedAnimation(isWeak ? AppColors.coral : AppColors.success),
                ),
              ),
            ],
          ),
        ),
        if (canPractice) ...[
          const SizedBox(width: 10),
          GestureDetector(
            onTap: loading ? null : onPractice,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.navActiveBg, borderRadius: BorderRadius.circular(10)),
              child: loading
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2.2))
                  : const Icon(Icons.fitness_center_rounded, size: 18, color: AppColors.primary),
            ),
          ),
        ],
      ],
    );
  }
}

/// Tarjeta de concepto: colapsada muestra tipo + título (+ check si visto);
/// expandible al body + ejemplo. Mínimo texto a la vista (estilo Busuu).
class _TipTile extends StatelessWidget {
  const _TipTile({required this.tip});
  final TipModel tip;

  IconData get _icon => switch (tip.type) {
        'pronunciacion' => Icons.record_voice_over_rounded,
        'nota_cultural' => Icons.public_rounded,
        'error_comun' => Icons.report_problem_rounded,
        'mnemotecnia' => Icons.lightbulb_rounded,
        _ => Icons.school_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 4), blurRadius: 0)],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          shape: const Border(),
          leading: Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.navActiveBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(_icon, size: 17, color: AppColors.primary),
          ),
          title: Text(tip.title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.text)),
          subtitle: Row(children: [
            Text(tip.typeLabel,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
            if (tip.seen) ...[
              const SizedBox(width: 7),
              const Icon(Icons.check_circle_rounded, size: 13, color: AppColors.success),
              const SizedBox(width: 2),
              const Text('visto',
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.success)),
            ],
          ]),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(tip.body,
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.text, height: 1.4)),
            ),
            if (tip.example != null && tip.example!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
                // Ejemplo en el idioma META: tócalo para oírlo (Web Speech).
                child: SpeakableText(tip.example!,
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.text, height: 1.35)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
