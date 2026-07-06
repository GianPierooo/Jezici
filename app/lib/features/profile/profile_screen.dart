import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/plan/estimation.dart';
import '../../core/theme/app_colors.dart';
import '../../core/ui/responsive_center.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/skill_names.dart';
import '../../data/models/achievement_models.dart';
import '../../data/models/level_exam_models.dart';
import '../../data/models/profile_models.dart';
import '../../data/models/progress_models.dart';
import '../../data/providers.dart';
import '../../ui/app_avatar.dart';
import '../../ui/daily_goal_bar.dart';
import '../../ui/edit_profile_sheet.dart';
import '../../ui/progress_bar.dart';
import '../level_exam/certificate_screen.dart';
import '../level_exam/level_exam_intro_screen.dart';
import '../notebook/notebook_screen.dart';
import '../notifications/notification_center_screen.dart';
import '../plan/mi_plan_screen.dart';
import '../practice/practice_player_screen.dart';
import '../settings/settings_screen.dart';
import '../streak/streak_screen.dart';
import 'widgets/skill_radar.dart';

/// Inicia una práctica de refuerzo de debilidades y abre el reproductor.
Future<void> _practiceWeakness(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  try {
    final session =
        await ref.read(progressRepositoryProvider).startPractice('weakness');
    if (!context.mounted) return;
    if (session.items.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.profilePracticeNoWeaknessToday)));
      return;
    }
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => PracticePlayerScreen(
          mode: 'weakness', title: l10n.profilePracticeWeaknessTitle, items: session.items),
    ));
    ref.invalidate(practiceStatusProvider);
    ref.invalidate(skillsProvider);
    ref.invalidate(skillMasteryProvider);
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.profilePracticeStartError)));
    }
  }
}

/// Perfil: cabecera + panel de las 4 habilidades (el diferenciador) leyendo
/// user_skill_levels, y estadísticas reales (paso E).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const _order = ['reading', 'listening', 'writing', 'speaking'];
  static const _icons = {
    'reading': Icons.menu_book_rounded,
    'listening': Icons.headphones_rounded,
    'writing': Icons.edit_rounded,
    'speaking': Icons.mic_rounded,
  };
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final stats = ref.watch(homeStatsProvider).value ?? HomeStats.empty;
    final profile = ref.watch(profileProvider).value ?? ProfileInfo.empty;
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
        child: ResponsiveCenter(
          maxWidth: 640,
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera: acciones (notificaciones, ajustes).
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
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
            const SizedBox(height: 10),

            // Hero del perfil (elevado): avatar + nombre real + nivel + país.
            _ProfileHero(
              profile: profile,
              cefr: skills.isNotEmpty ? skills.first.cefrLevel : 'A1',
              xp: stats.xpTotal,
              onEdit: () => showEditProfileSheet(context, ref, profile),
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
            const SizedBox(height: 12),
            // Cuaderno de datos (capa "enseña"): tips aprendidos, navegables.
            _NotebookEntry(
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NotebookScreen())),
            ),
            const SizedBox(height: 22),

            // Panel de 4 habilidades.
            Text(l10n.profileSkillsTitle,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.text)),
            const SizedBox(height: 4),
            Text(
              l10n.profileSkillsDescription,
              style: const TextStyle(
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
                                  l10n.profileSkillImbalanceWarning(
                                    skillName(l10n, strong.skill),
                                    (strong.masteryPct * 100).round(),
                                    skillName(l10n, weak.skill),
                                    (weak.masteryPct * 100).round(),
                                  ),
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
                    label: l10n.profileStatStreak,
                    color: AppColors.streak,
                    onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const StreakScreen()))),
                const SizedBox(width: 12),
                _StatCard(
                    icon: Icons.bolt_rounded,
                    value: '${stats.xpTotal}',
                    label: l10n.profileStatXp,
                    color: AppColors.primary),
                const SizedBox(width: 12),
                _StatCard(
                    icon: Icons.monetization_on_rounded,
                    value: '${stats.gold}',
                    label: l10n.profileStatGold,
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
                child: Row(
                  children: [
                    const Icon(Icons.flag_rounded, color: AppColors.primary, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(l10n.profileNoPlan,
                          style: const TextStyle(
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
              Text(l10n.profileCertificatesTitle,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.text)),
              const SizedBox(height: 10),
              for (final c in certs) _CertCard(cert: c),
              const SizedBox(height: 22),
            ],

            // Logros / badges.
            Row(
              children: [
                Text(l10n.profileAchievementsTitle,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.text)),
                const Spacer(),
                Text('${achievements.where((a) => a.unlocked).length}/${achievements.length}',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 10),
            if (achievements.isEmpty)
              _EmptyHint(text: l10n.profileNoAchievements)
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
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.a});
  final Achievement a;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonClose)),
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
    final l10n = AppLocalizations.of(context);
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
                  Text(unlocked ? l10n.profileExamCardTitle(exam.level) : l10n.profileExamCardTitleLocked(exam.level),
                      style: TextStyle(
                          fontSize: 15.5, fontWeight: FontWeight.w900,
                          color: unlocked ? Colors.white : AppColors.text)),
                  const SizedBox(height: 2),
                  Text(
                    unlocked
                        ? l10n.profileExamReady
                        : (exam.unitsDone < exam.unitsTotal
                            ? l10n.profileExamUnitsRequired(exam.unitsDone, exam.unitsTotal)
                            : l10n.profileExamMasteryRequired),
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
    final l10n = AppLocalizations.of(context);
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
                Text(l10n.profileCertificateCardTitle(cert.cefrLevel),
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.text)),
                Text(l10n.profileCertificateInfo(cert.folio, cert.verificationCode),
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

  String? _focusText(AppLocalizations l10n, String? motive) => switch (motive) {
        'Trabajo' => l10n.planFocusWork,
        'Viajes' => l10n.planFocusTravel,
        'Examen' => l10n.planFocusExam,
        'Estudios' => l10n.planFocusStudies,
        'Mudanza' => l10n.planFocusRelocation,
        'Placer' => l10n.planFocusCulture,
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final focus = _focusText(l10n, motive);
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
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(l10n.profileForYouTitle,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.text)),
            ],
          ),
          if (focus != null) ...[
            const SizedBox(height: 10),
            Text(focus,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.text)),
          ],
          if (weak != null) ...[
            const SizedBox(height: 12),
            Text(l10n.profileWeakestSkill(skillName(l10n, weak!.skill), weak!.cefrLevel),
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
                child: Text(l10n.profilePracticeWeaknessButton(skillName(l10n, weak!.skill).toUpperCase()),
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
    final l10n = AppLocalizations.of(context);
    final label = skillName(l10n, skill.skill);
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
                      child: Text(l10n.profileSkillWeakestBadge,
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: AppColors.coral)),
                    ),
                  ],
                  if (mastery?.examReady ?? false) ...[
                    const SizedBox(width: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(l10n.profileSkillExamReadyBadge,
                          style: const TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.successDark)),
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

/// Compuerta de dominio → examen (modelo v2 per-skill): la sección de una
/// habilidad se abre cuando SU dominio llega al 80%. Mostramos la habilidad más
/// cercana a abrir su examen.
class _MasteryGate extends StatelessWidget {
  const _MasteryGate({required this.mastery});
  final SkillMasteryStatus mastery;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final unlocked = mastery.examUnlocked;
    final certified = mastery.examHasCertificate;
    // v2: el desbloqueo es por habilidad ≥80% (no promedio). Mostramos avance de
    // la habilidad más cercana hacia ese 80%.
    final maxPct = mastery.skills.isEmpty
        ? 0.0
        : mastery.skills.map((s) => s.masteryPct).reduce((a, b) => a > b ? a : b).clamp(0.0, 1.0);
    final ready = mastery.skills.where((s) => s.examReady).length;
    final toGate = (maxPct / 0.8).clamp(0.0, 1.0);
    final color = certified
        ? AppColors.success
        : (unlocked ? AppColors.success : AppColors.primary);
    final label = certified
        ? l10n.profileMasteryGateCertified(mastery.workingLevel)
        : (unlocked
            ? l10n.profileMasteryGateUnlocked(mastery.workingLevel, ready)
            : l10n.profileMasteryGateLocked(mastery.workingLevel, (maxPct * 100).round()));
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
              Text(l10n.profilePlanTitle,
                  style: const TextStyle(
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
                  ? l10n.profilePlanOnTrack
                  : (a > 0 ? l10n.profilePlanAhead(a)
                           : l10n.profilePlanBehind(-a));
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
              Text(l10n.profilePlanProgress(plan.goalLevel),
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
                text: l10n.profilePlanEstimatedCompletion(
                    MaterialLocalizations.of(context).formatMediumDate(plan.estimatedCompletion!))),
          if (plan.dailyMinutes != null && plan.daysPerWeek != null) ...[
            const SizedBox(height: 6),
            _PlanRow(
                icon: Icons.bolt_rounded,
                text: l10n.profilePlanIntensity(plan.dailyMinutes!, plan.daysPerWeek!)),
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

/// Hero del perfil: avatar generado + nombre real + nivel + país + ingreso.
/// Tappable → editar perfil. Si falta el nombre, invita a ponerlo.
class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.profile,
    required this.cefr,
    required this.xp,
    required this.onEdit,
  });

  final ProfileInfo profile;
  final String cefr;
  final int xp;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final flag = countryFlag(profile.country);
    final since = profile.memberSince;
    final sinceDate = since == null ? null : DateTime.tryParse(since);
    final hasName = !profile.needsName && (profile.name?.isNotEmpty ?? false);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, (1 - t) * 12), child: child),
      ),
      child: GestureDetector(
        onTap: onEdit,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(color: Color(0x336C5CE7), offset: Offset(0, 10), blurRadius: 24),
            ],
          ),
          child: Row(
            children: [
              AppAvatar(initial: profile.initial, colorHex: profile.avatarColor, size: 64),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasName ? profile.name! : l10n.profileNamePlaceholder,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _Pill(text: l10n.profileLevelPill(cefr)),
                        const SizedBox(width: 6),
                        _Pill(text: '$xp XP'),
                        if (flag != null) ...[
                          const SizedBox(width: 6),
                          Text(flag, style: const TextStyle(fontSize: 16)),
                        ],
                      ],
                    ),
                    if (sinceDate != null) ...[
                      const SizedBox(height: 6),
                      Text(
                          l10n.profileMemberSince(
                              MaterialLocalizations.of(context).formatMonthYear(sinceDate)),
                          style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withValues(alpha: 0.85))),
                    ],
                  ],
                ),
              ),
              Icon(hasName ? Icons.edit_rounded : Icons.add_circle_rounded,
                  color: Colors.white.withValues(alpha: 0.9), size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text,
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white)),
    );
  }
}

class _NotebookEntry extends StatelessWidget {
  const _NotebookEntry({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 4), blurRadius: 0),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: AppColors.navActiveBg, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.auto_stories_rounded, color: AppColors.primary, size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.profileNotebookTitle,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.text)),
                  Text(l10n.profileNotebookSubtitle,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
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
