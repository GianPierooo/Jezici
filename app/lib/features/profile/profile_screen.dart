import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/skills.dart';
import '../../core/plan/estimation.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/achievement_models.dart';
import '../../data/models/level_exam_models.dart';
import '../../data/models/progress_models.dart';
import '../../data/providers.dart';
import '../../ui/daily_goal_bar.dart';
import '../../ui/progress_bar.dart';
import '../level_exam/certificate_screen.dart';
import '../level_exam/level_exam_intro_screen.dart';
import '../notifications/notification_center_screen.dart';
import '../plan/mi_plan_screen.dart';
import '../practice/practice_player_screen.dart';
import '../settings/settings_screen.dart';
import '../streak/streak_screen.dart';
import 'widgets/skill_radar.dart';

/// Inicia una práctica de refuerzo de debilidades y abre el reproductor.
Future<void> _practiceWeakness(BuildContext context, WidgetRef ref) async {
  try {
    final session =
        await ref.read(progressRepositoryProvider).startPractice('weakness');
    if (!context.mounted) return;
    if (session.items.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('¡Nada que reforzar ahora! Vas al día. 🎉')));
      return;
    }
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => PracticePlayerScreen(
          mode: 'weakness', title: 'Refuerzo de debilidades', items: session.items),
    ));
    ref.invalidate(practiceStatusProvider);
    ref.invalidate(skillsProvider);
    ref.invalidate(skillMasteryProvider);
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo iniciar la práctica.')));
    }
  }
}

/// Perfil: cabecera + panel de las 4 habilidades (el diferenciador) leyendo
/// user_skill_levels, y estadísticas reales (paso E).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const _order = ['reading', 'listening', 'writing', 'speaking'];
  // Etiquetas en español, alineadas con el resto de la app (kSkillEs).
  static const _labels = kSkillEs;
  static const _icons = {
    'reading': Icons.menu_book_rounded,
    'listening': Icons.headphones_rounded,
    'writing': Icons.edit_rounded,
    'speaking': Icons.mic_rounded,
  };
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(homeStatsProvider).value ?? HomeStats.empty;
    final skillsList = ref.watch(skillsProvider).value ?? const <SkillLevel>[];
    final mastery = ref.watch(skillMasteryProvider).value;
    final masteryBySkill = {
      for (final m in (mastery?.skills ?? const <SkillMastery>[])) m.skill: m
    };
    final plan = ref.watch(userPlanProvider).value;
    final achievements = ref.watch(achievementsProvider).value ?? const <Achievement>[];
    final certs = ref.watch(certificatesProvider).value ?? const <Certificate>[];
    final exam = ref.watch(levelExamStatusProvider).value ?? LevelExamStatus.empty;
    final bySkill = {for (final s in skillsList) s.skill: s};
    final skills = [
      for (final k in _order)
        bySkill[k] ?? SkillLevel(skill: k, cefrLevel: 'A1', progressPoints: 0),
    ];

    // Habilidad más débil / más fuerte. En el modelo de dominio las 4 comparten
    // cefr_level (suben juntas por examen), así que el diferenciador REAL es el
    // dominio / refuerzo: débil = mayor reinforce_score; fuerte = mayor dominio.
    String? weakest;
    SkillLevel? weakSkill;
    if (mastery != null && mastery.skills.isNotEmpty) {
      final byScore = [...mastery.skills]
        ..sort((a, b) => b.reinforceScore.compareTo(a.reinforceScore));
      weakest = byScore.first.skill;
      weakSkill = bySkill[byScore.first.skill];
    } else if (skills.isNotEmpty) {
      weakSkill = skills.first;
      weakest = weakSkill.skill;
    }
    final tracking = ref.watch(planTrackingProvider).value;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera.
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryLight, AppColors.primary],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Text('🦜', style: TextStyle(fontSize: 30)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Aprendiz',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppColors.text)),
                      const SizedBox(height: 2),
                      Text('Nivel de jugador ${stats.playerLevel} · ${stats.xpTotal} XP',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textMuted)),
                    ],
                  ),
                ),
                _HeaderIcon(
                  icon: Icons.notifications_rounded,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const NotificationCenterScreen())),
                ),
                const SizedBox(width: 8),
                _HeaderIcon(
                  icon: Icons.settings_rounded,
                  onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsScreen())),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Meta de hoy (Estructura_App §8).
            DailyGoalBar(earned: stats.dailyXpEarned, goal: stats.dailyGoalXp),
            const SizedBox(height: 22),

            // Para ti (GA4 · B1): recomendación por motivo + debilidad.
            _ForYouCard(
              motive: plan?.motive,
              weak: weakSkill,
              onPracticeWeak: () => _practiceWeakness(context, ref),
            ),
            const SizedBox(height: 22),

            // Panel de 4 habilidades.
            const Text('Tus 4 habilidades',
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.text)),
            const SizedBox(height: 4),
            const Text(
              'Las lecciones suben tu DOMINIO; el nivel sube al aprobar el examen.',
              style: TextStyle(
                  fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textMuted),
            ),
            if (mastery != null) ...[
              const SizedBox(height: 10),
              _MasteryGate(mastery: mastery),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 5), blurRadius: 0),
                ],
              ),
              child: Column(
                children: [
                  // Radar visible: hace evidente el desbalance entre habilidades.
                  Center(
                    child: SkillRadar(
                      skills: skills,
                      goalLevel: plan?.goalLevel ?? 'B1',
                      size: 230,
                      masteryPct: mastery == null
                          ? null
                          : {for (final m in mastery.skills) m.skill: m.masteryPct},
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (var i = 0; i < skills.length; i++) ...[
                    _SkillRow(
                      skill: skills[i],
                      weakest: skills[i].skill == weakest,
                      mastery: masteryBySkill[skills[i].skill],
                    ),
                    if (i < skills.length - 1) const SizedBox(height: 16),
                  ],
                  // Aviso de desbalance por DOMINIO (no por nivel: las 4 comparten nivel).
                  if (mastery != null) ...[
                    Builder(builder: (_) {
                      final ms = mastery.skills;
                      if (ms.length < 2) return const SizedBox.shrink();
                      final strong = ms.reduce((a, b) => a.masteryPct >= b.masteryPct ? a : b);
                      final weak = ms.reduce((a, b) => a.masteryPct <= b.masteryPct ? a : b);
                      // Mostrar sólo si hay un hueco real de dominio.
                      if (strong.skill == weak.skill || (strong.masteryPct - weak.masteryPct) < 0.25) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: Container(
                          padding: const EdgeInsets.all(13),
                          decoration: BoxDecoration(
                            color: AppColors.coral.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.balance_rounded, color: AppColors.coral, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Tu ${kSkillEs[strong.skill]} va al ${(strong.masteryPct * 100).round()}% pero tu '
                                  '${kSkillEs[weak.skill]} al ${(weak.masteryPct * 100).round()}% → refuerza ${kSkillEs[weak.skill]}.',
                                  style: const TextStyle(
                                      fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.text),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Estadísticas.
            Row(
              children: [
                _StatCard(
                    icon: Icons.local_fire_department_rounded,
                    value: '${stats.currentStreak}',
                    label: 'RACHA',
                    color: AppColors.streak,
                    onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const StreakScreen()))),
                const SizedBox(width: 12),
                _StatCard(
                    icon: Icons.bolt_rounded,
                    value: '${stats.xpTotal}',
                    label: 'XP TOTAL',
                    color: AppColors.primary),
                const SizedBox(width: 12),
                _StatCard(
                    icon: Icons.monetization_on_rounded,
                    value: '${stats.gold}',
                    label: 'ORO',
                    color: AppColors.goldDark),
              ],
            ),
            const SizedBox(height: 18),

            // Mi plan (real) → abre el dashboard de seguimiento (GA4 · B2).
            if (plan != null)
              GestureDetector(
                onTap: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const MiPlanScreen())),
                child: _PlanCard(plan: plan, tracking: tracking),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.navActiveBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.flag_rounded, color: AppColors.primary, size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text('Crea tu cuenta en el onboarding para ver tu plan.',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary)),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 22),

            // Examen de nivel (gran diferenciador) — solo si aún no certificó.
            if (!exam.hasCertificate) _LevelExamCard(exam: exam),
            if (!exam.hasCertificate) const SizedBox(height: 22),

            // Certificados de nivel (paso Examen de nivel).
            if (certs.isNotEmpty) ...[
              const Text('Certificados',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.text)),
              const SizedBox(height: 10),
              for (final c in certs) _CertCard(cert: c),
              const SizedBox(height: 22),
            ],

            // Logros / badges.
            Row(
              children: [
                const Text('Logros',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.text)),
                const Spacer(),
                Text('${achievements.where((a) => a.unlocked).length}/${achievements.length}',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 10),
            if (achievements.isEmpty)
              const _EmptyHint(text: 'Completa lecciones para ganar logros.')
            else
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.78,
                children: [for (final a in achievements) _BadgeTile(a: a)],
              ),
          ],
        ),
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.a});
  final Achievement a;

  @override
  Widget build(BuildContext context) {
    final on = a.unlocked;
    return GestureDetector(
      onTap: () => showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: Row(children: [
            Text(a.icon, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 10),
            Expanded(child: Text(a.name, style: const TextStyle(fontWeight: FontWeight.w900))),
          ]),
          content: Text(on ? a.description : '🔒 ${a.hint}'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: on ? AppColors.navActiveBg : const Color(0xFFF0F1F8),
              borderRadius: BorderRadius.circular(16),
              border: on ? Border.all(color: AppColors.primary, width: 2) : null,
            ),
            child: Opacity(
              opacity: on ? 1 : 0.35,
              child: Text(a.icon, style: const TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            a.name,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                height: 1.1,
                color: on ? AppColors.text : AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _LevelExamCard extends StatelessWidget {
  const _LevelExamCard({required this.exam});
  final LevelExamStatus exam;

  @override
  Widget build(BuildContext context) {
    final unlocked = exam.unlocked;
    return GestureDetector(
      onTap: unlocked
          ? () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LevelExamIntroScreen()))
          : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: unlocked
              ? const LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [Color(0xFF7A6BF0), AppColors.primary])
              : null,
          color: unlocked ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 5), blurRadius: 0)],
        ),
        child: Row(
          children: [
            Text(unlocked ? '🎓' : '🔒', style: const TextStyle(fontSize: 30)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(unlocked ? 'Examen de nivel ${exam.level}' : 'Examen de nivel ${exam.level} (bloqueado)',
                      style: TextStyle(
                          fontSize: 15.5, fontWeight: FontWeight.w900,
                          color: unlocked ? Colors.white : AppColors.text)),
                  const SizedBox(height: 2),
                  Text(
                    unlocked
                        ? '¡Listo para certificar! Toca para empezar.'
                        : (exam.unitsDone < exam.unitsTotal
                            ? 'Completa las unidades: ${exam.unitsDone}/${exam.unitsTotal} checkpoints'
                            : 'Sube tu dominio: ${(exam.masteryAvg * 100).round()}% (necesitas 50%)'),
                    style: TextStyle(
                        fontSize: 12.5, fontWeight: FontWeight.w700,
                        color: unlocked ? Colors.white.withValues(alpha: 0.92) : AppColors.textMuted),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: unlocked ? Colors.white : AppColors.locked),
          ],
        ),
      ),
    );
  }
}

class _CertCard extends StatelessWidget {
  const _CertCard({required this.cert});
  final Certificate cert;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => CertificateScreen(cert: cert, celebrate: false))),
      child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFFF8E6), Colors.white]),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.workspace_premium_rounded, color: AppColors.gold, size: 34),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Certificado ${cert.cefrLevel}',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.text)),
                Text('Folio ${cert.folio} · cód. ${cert.verificationCode}',
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.goldDark),
        ],
      ),
    ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Text(text,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
    );
  }
}

/// "Para ti" (GA4 · B1): recomendación por motivo + práctica de la debilidad.
class _ForYouCard extends StatelessWidget {
  const _ForYouCard({required this.motive, required this.weak, required this.onPracticeWeak});
  final String? motive;
  final SkillLevel? weak;
  final VoidCallback onPracticeWeak;

  static const _focus = {
    'Trabajo': '💼 Inglés para el trabajo: reuniones, correos y entrevistas.',
    'Viajes': '✈️ Inglés para viajar: aeropuerto, hotel, direcciones y restaurantes.',
    'Examen': '🎓 Rumbo a tu examen: simulacros y las 4 habilidades.',
    'Estudios': '📚 Inglés para estudiar: comprensión, escritura y vocabulario.',
    'Mudanza': '🏠 Inglés para tu mudanza: trámites, vivienda y vida diaria.',
    'Placer': '🎬 Inglés para disfrutar: series, música y conversación.',
  };

  @override
  Widget build(BuildContext context) {
    final focus = _focus[motive];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFFF3F0FF), Colors.white]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text('Para ti',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.text)),
            ],
          ),
          if (focus != null) ...[
            const SizedBox(height: 10),
            Text(focus,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.text)),
          ],
          if (weak != null) ...[
            const SizedBox(height: 12),
            Text('Tu punto débil ahora: ${kSkillEs[weak!.skill] ?? weak!.skill} (${weak!.cefrLevel}). '
                'Unos minutos lo equilibran.',
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: onPracticeWeak,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                ),
                child: Text('PRACTICAR ${(kSkillEs[weak!.skill] ?? weak!.skill).toUpperCase()}',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5, letterSpacing: 0.4)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SkillRow extends StatelessWidget {
  const _SkillRow({required this.skill, required this.weakest, this.mastery});
  final SkillLevel skill;
  final bool weakest;
  final SkillMastery? mastery;

  @override
  Widget build(BuildContext context) {
    final label = ProfileScreen._labels[skill.skill] ?? skill.skill;
    // Barra = DOMINIO del nivel en curso (modelo D6); si aún no hay dato, 0.
    final barValue = mastery?.masteryPct ?? 0.0;
    final pct = (barValue * 100).round();
    final icon = ProfileScreen._icons[skill.skill] ?? Icons.star_rounded;
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F1F8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppColors.text)),
                  if (weakest) ...[
                    const SizedBox(width: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.coral.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('más débil',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: AppColors.coral)),
                    ),
                  ],
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(skill.cefrLevel,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(child: JzProgressBar(value: barValue, height: 8)),
                  const SizedBox(width: 8),
                  Text('$pct%',
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textMuted)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Compuerta de dominio → examen (modelo D7): muestra cuánto falta para que el
/// examen del nivel en curso se desbloquee (promedio de dominio >= 50%).
class _MasteryGate extends StatelessWidget {
  const _MasteryGate({required this.mastery});
  final SkillMasteryStatus mastery;

  @override
  Widget build(BuildContext context) {
    final unlocked = mastery.examUnlocked;
    final certified = mastery.examHasCertificate;
    final avg = mastery.masteryAvg.clamp(0.0, 1.0);
    // El examen abre con dominio promedio >= 0.5; mostramos avance hacia esa meta.
    final toGate = (avg / 0.5).clamp(0.0, 1.0);
    final color = certified
        ? AppColors.success
        : (unlocked ? AppColors.success : AppColors.primary);
    final label = certified
        ? 'Ya certificaste ${mastery.workingLevel} 🎓'
        : (unlocked
            ? 'Examen ${mastery.workingLevel} desbloqueado 🔓'
            : 'Dominio ${mastery.workingLevel}: ${(avg * 100).round()}% — al 50% abre el examen');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.2),
      ),
      child: Row(
        children: [
          Icon(
              certified
                  ? Icons.workspace_premium_rounded
                  : (unlocked ? Icons.lock_open_rounded : Icons.insights_rounded),
              color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 12.5, fontWeight: FontWeight.w900, color: color)),
                if (!unlocked && !certified) ...[
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: toGate,
                      minHeight: 6,
                      backgroundColor: const Color(0xFFE2DEF8),
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan, this.tracking});
  final UserPlan plan;
  final PlanTracking? tracking;

  static const _months = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
  ];
  String _fmt(DateTime d) => '${d.day} de ${_months[d.month - 1]} de ${d.year}';

  @override
  Widget build(BuildContext context) {
    final pct =
        (planProgress(currentLevel: plan.currentLevel, goalLevel: plan.goalLevel) * 100)
            .round();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 5), blurRadius: 0),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flag_rounded, color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              const Text('Mi plan',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.text)),
              const Spacer(),
              Text('${plan.currentLevel} → ${plan.goalLevel}',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.primary)),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded, color: AppColors.primary, size: 20),
            ],
          ),
          if (tracking != null && tracking!.ok) ...[
            const SizedBox(height: 10),
            Builder(builder: (_) {
              final a = tracking!.aheadBehind;
              final c = a >= 0 ? AppColors.success : AppColors.coral;
              final txt = a == 0
                  ? 'Justo en tu plan'
                  : (a > 0 ? 'Vas $a ${a == 1 ? 'día' : 'días'} adelante 🎉'
                           : 'Vas ${-a} ${-a == 1 ? 'día' : 'días'} atrás');
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                    color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(9)),
                child: Text(txt,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: c)),
              );
            }),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Avance a ${plan.goalLevel}',
                  style: const TextStyle(
                      fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
              Text('$pct%',
                  style: const TextStyle(
                      fontSize: 12.5, fontWeight: FontWeight.w900, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 6),
          JzProgressBar(value: pct / 100, height: 9),
          const SizedBox(height: 12),
          if (plan.estimatedCompletion != null)
            _PlanRow(
                icon: Icons.event_rounded,
                text: 'Llegas aprox. el ${_fmt(plan.estimatedCompletion!)}'),
          if (plan.dailyMinutes != null && plan.daysPerWeek != null) ...[
            const SizedBox(height: 6),
            _PlanRow(
                icon: Icons.bolt_rounded,
                text: '${plan.dailyMinutes} min/día · ${plan.daysPerWeek} días/semana'),
          ],
        ],
      ),
    );
  }
}

class _PlanRow extends StatelessWidget {
  const _PlanRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: const TextStyle(
                  fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.text)),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.onTap,
  });
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 4), blurRadius: 0),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 6),
              Text(value,
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: color)),
              Text(label,
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.3,
                      color: AppColors.textMuted)),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          boxShadow: const [
            BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 4), blurRadius: 0),
          ],
        ),
        child: Icon(icon, color: AppColors.primary, size: 21),
      ),
    );
  }
}
