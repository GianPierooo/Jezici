import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/i18n/learn_lang_names.dart';
import '../../core/plan/estimation.dart';
import '../../core/theme/app_colors.dart';
import '../../core/ui/responsive_center.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/division_names.dart';
import '../../l10n/skill_names.dart';
import '../../core/constants/skills.dart';
import '../../data/models/achievement_models.dart';
import '../../data/models/course_models.dart';
import '../../data/models/level_exam_models.dart';
import '../../data/models/profile_models.dart';
import '../../data/models/progress_models.dart';
import '../../data/providers.dart';
import '../../ui/app_avatar.dart';
import '../../ui/daily_goal_bar.dart';
import '../../ui/edit_profile_sheet.dart';
import '../../ui/progress_bar.dart';
import '../learn/widgets/parrot_mascot.dart';
import '../level_exam/certificate_screen.dart';
import '../level_exam/level_exam_intro_screen.dart';
import '../notebook/notebook_screen.dart';
import '../notifications/notification_center_screen.dart';
import '../plan/mi_plan_screen.dart';
import '../practice/practice_player_screen.dart';
import '../settings/settings_screen.dart';
import '../streak/streak_screen.dart';
import 'traveler_level.dart';
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

/// Perfil (Perfil.dc): banner "pasaporte" full-bleed (avatar con anillo de XP +
/// nivel de viajero + chip del idioma ACTIVO course-aware) + panel de las 4
/// habilidades (radar con META + alerta con mascota + filas coloreadas) +
/// certificados (medalla / bloqueado con requisitos) + plan + estadísticas
/// (calendario de racha + tiles). Todos los datos son reales; NO cambia lógica.
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
    final courses = ref.watch(coursesProvider).value ?? const <CourseInfo>[];
    final bySkill = {for (final s in skillsList) s.skill: s};
    final skills = [
      for (final k in _order)
        bySkill[k] ?? SkillLevel(skill: k, cefrLevel: 'A1', progressPoints: 0),
    ];
    final goalLevel = plan?.goalLevel ?? 'B1';

    // Curso ACTIVO (course-aware, no "Inglés" hardcodeado).
    CourseInfo? active;
    for (final c in courses) {
      if (c.active) active = c;
    }

    // Habilidad más débil: en el modelo de dominio el diferenciador real es el
    // refuerzo (mayor reinforce_score = más floja).
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

    return ListView(
      padding: const EdgeInsets.only(bottom: 110),
      children: [
        _ProfileBanner(
          profile: profile,
          xp: stats.xpTotal,
          course: active,
          goalLevel: goalLevel,
          onEdit: () => showEditProfileSheet(context, ref, profile),
        ),
        Transform.translate(
          offset: const Offset(0, -12),
          child: ResponsiveCenter(
            maxWidth: 640,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DailyGoalBar(earned: stats.dailyXpEarned, goal: stats.dailyGoalXp),
                  const SizedBox(height: 16),
                  _ForYouCard(
                    motive: plan?.motive,
                    weak: weakSkill,
                    onPracticeWeak: () => _practiceWeakness(context, ref),
                  ),
                  const SizedBox(height: 12),
                  _NotebookEntry(
                    onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const NotebookScreen())),
                  ),
                  const SizedBox(height: 18),

                  // ── Panel de las 4 habilidades (hero) ──
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 6), blurRadius: 0),
                        BoxShadow(color: Color(0x1A3C3778), offset: Offset(0, 16), blurRadius: 30),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l10n.profileSkillsTitle,
                                      style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.text)),
                                  const SizedBox(height: 2),
                                  Text(l10n.profileSkillsDescription,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textMuted)),
                                ],
                              ),
                            ),
                            if (mastery != null && mastery.skills.isNotEmpty)
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                    color: AppColors.navActiveBg,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Text(
                                  l10n.profileSkillsReadyChip(
                                      mastery.skills.where((s) => s.examReady).length,
                                      mastery.workingLevel),
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primary),
                                ),
                              ),
                          ],
                        ),
                        if (mastery != null) ...[
                          const SizedBox(height: 10),
                          _MasteryGate(mastery: mastery),
                        ],
                        // Radar con anillo de META + tag + vértices por estado.
                        Center(
                          child: SkillRadar(
                            skills: skills,
                            goalLevel: goalLevel,
                            size: 250,
                            masteryPct: mastery == null
                                ? null
                                : {for (final m in mastery.skills) m.skill: m.masteryPct},
                            labels: [for (final k in kSkillOrder) skillName(l10n, k)],
                            goalTag: l10n.profileRadarGoalTag(goalLevel),
                          ),
                        ),
                        // Alerta de punto débil con mascota + CTA coral.
                        if (weakest != null)
                          _WeakAlert(
                            skill: skillName(l10n, weakest),
                            goalLevel: goalLevel,
                            onPractice: () => _practiceWeakness(context, ref),
                          ),
                        const SizedBox(height: 13),
                        for (var i = 0; i < skills.length; i++) ...[
                          _SkillRow(
                            skill: skills[i],
                            goalLevel: goalLevel,
                            weakest: skills[i].skill == weakest,
                            mastery: masteryBySkill[skills[i].skill],
                          ),
                          if (i < skills.length - 1) const SizedBox(height: 12),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Certificados: medalla obtenida + bloqueado con requisitos ──
                  _CertsPanel(certs: certs, mastery: mastery, exam: exam, course: active),
                  const SizedBox(height: 16),

                  // ── Mi plan ──
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
                  const SizedBox(height: 16),

                  // ── Estadísticas: calendario de racha + tiles ──
                  _StatsPanel(stats: stats, achievements: achievements),
                  const SizedBox(height: 18),

                  // ── Logros ──
                  Row(
                    children: [
                      Text(l10n.profileAchievementsTitle,
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.text)),
                      const Spacer(),
                      Text(
                          '${achievements.where((a) => a.unlocked).length}/${achievements.length}',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary)),
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
        ),
      ],
    );
  }
}

// ── Banner "pasaporte" (full-bleed) ──────────────────────────────────────────
class _ProfileBanner extends StatelessWidget {
  const _ProfileBanner({
    required this.profile,
    required this.xp,
    required this.course,
    required this.goalLevel,
    required this.onEdit,
  });
  final ProfileInfo profile;
  final int xp;
  final CourseInfo? course;
  final String goalLevel;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final topPad = MediaQuery.paddingOf(context).top;
    final hasName = !profile.needsName && (profile.name?.isNotEmpty ?? false);
    final lvl = travelerLevel(xp);
    final nextXp = xpForTravelerLevel(lvl + 1);
    final prog = travelerProgress(xp);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(0, topPad + 14, 0, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7A6BF0), AppColors.primary, Color(0xFF5B4ECF)],
        ),
      ),
      child: ResponsiveCenter(
        maxWidth: 640,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // MI PERFIL + campana + ajustes.
              Row(
                children: [
                  Text(l10n.profileHeaderKicker,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.6,
                          color: Colors.white.withValues(alpha: 0.78))),
                  const Spacer(),
                  _BannerIcon(
                    icon: Icons.notifications_rounded,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const NotificationCenterScreen())),
                  ),
                  const SizedBox(width: 8),
                  _BannerIcon(
                    icon: Icons.settings_rounded,
                    onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SettingsScreen())),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Avatar con anillo de XP + badge de nivel + identidad.
              Row(
                children: [
                  GestureDetector(
                    onTap: onEdit,
                    child: SizedBox(
                      width: 82,
                      height: 84,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 78,
                            height: 78,
                            child: CircularProgressIndicator(
                              value: prog.clamp(0.02, 1.0),
                              strokeWidth: 5,
                              strokeCap: StrokeCap.round,
                              backgroundColor: Colors.white.withValues(alpha: 0.25),
                              valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                            ),
                          ),
                          AppAvatar(
                              initial: profile.initial,
                              colorHex: profile.avatarColor,
                              size: 62),
                          // Badge de nivel de viajero.
                          Positioned(
                            bottom: -4,
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 9, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.gold,
                                borderRadius: BorderRadius.circular(9),
                                border: Border.all(color: AppColors.primary, width: 2),
                              ),
                              child: Text('$lvl',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.text)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: onEdit,
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  hasName ? profile.name! : l10n.profileNamePlaceholder,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(hasName ? Icons.edit_rounded : Icons.add_circle_rounded,
                                  color: Colors.white.withValues(alpha: 0.8), size: 16),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        // Chip nivel de viajero.
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.navigation_rounded,
                                  color: AppColors.gold, size: 13),
                              const SizedBox(width: 5),
                              Text(l10n.profileTravelerChip(lvl),
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 9),
                        // Barra de XP al siguiente nivel.
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('$xp XP',
                                style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white.withValues(alpha: 0.85))),
                            Text(l10n.profileTravelerNext(lvl + 1, nextXp),
                                style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white.withValues(alpha: 0.85))),
                          ],
                        ),
                        const SizedBox(height: 3),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: LinearProgressIndicator(
                            value: prog,
                            minHeight: 7,
                            backgroundColor: Colors.white.withValues(alpha: 0.22),
                            valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Chip del IDIOMA ACTIVO (course-aware) → Ajustes (selector real).
              GestureDetector(
                onTap: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
                  ),
                  child: Row(
                    children: [
                      Text(course?.flag ?? '🌍', style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.profileActiveLangLabel,
                                style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                    color: Colors.white.withValues(alpha: 0.65))),
                            Text(
                              l10n.profileActiveLangValue(
                                  course != null
                                      ? learnLangName(l10n, course!.target)
                                      : '—',
                                  goalLevel),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      Text('${l10n.profileActiveLangChange} ›',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: Colors.white.withValues(alpha: 0.8))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BannerIcon extends StatelessWidget {
  const _BannerIcon({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

// ── Alerta de punto débil con mascota + CTA coral (Perfil.dc) ────────────────
class _WeakAlert extends StatelessWidget {
  const _WeakAlert({required this.skill, required this.goalLevel, required this.onPractice});
  final String skill;
  final String goalLevel;
  final VoidCallback onPractice;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFFF1F1), Color(0xFFFFF6EC)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD9D9), width: 1.5),
      ),
      child: Row(
        children: [
          const ParrotMascot(size: 34),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    text: '${l10n.profileWeakAlertTitle} ',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.text),
                    children: [
                      TextSpan(
                          text: skill,
                          style: const TextStyle(color: Color(0xFFFF5C5C))),
                    ],
                  ),
                ),
                const SizedBox(height: 1),
                Text(l10n.profileWeakAlertBody(goalLevel),
                    style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onPractice,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                color: AppColors.coral,
                borderRadius: BorderRadius.circular(13),
                boxShadow: const [
                  BoxShadow(color: AppColors.coralDark, offset: Offset(0, 4), blurRadius: 0)
                ],
              ),
              child: Text(l10n.practicePracticeBtn,
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Fila de habilidad coloreada por estado (débil/bajo meta = coral) ─────────
class _SkillRow extends StatelessWidget {
  const _SkillRow({
    required this.skill,
    required this.goalLevel,
    required this.weakest,
    this.mastery,
  });
  final SkillLevel skill;
  final String goalLevel;
  final bool weakest;
  final SkillMastery? mastery;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = skillName(l10n, skill.skill);
    final barValue = mastery?.masteryPct ?? 0.0;
    final pct = (barValue * 100).round();
    final icon = ProfileScreen._icons[skill.skill] ?? Icons.star_rounded;
    final below =
        (kCefrRank[skill.cefrLevel] ?? 0) < (kCefrRank[goalLevel] ?? 2);
    final accent = (below || weakest) ? AppColors.coral : AppColors.primary;
    final tileBg = (below || weakest) ? const Color(0xFFFFEFEF) : AppColors.navActiveBg;
    final next = CefrTable.next(skill.cefrLevel);
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(color: tileBg, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: accent, size: 19),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.text)),
                  if (weakest) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.coral.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(l10n.profileSkillWeakestBadge,
                          style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: AppColors.coral)),
                    ),
                  ],
                  if (mastery?.examReady ?? false) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(l10n.profileSkillExamReadyBadge,
                          style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: AppColors.successDark)),
                    ),
                  ],
                  const Spacer(),
                  Text('${skill.cefrLevel} → $next · $pct%',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: (below || weakest)
                              ? const Color(0xFFFF5C5C)
                              : AppColors.textMuted)),
                ],
              ),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: LinearProgressIndicator(
                  value: barValue.clamp(0.0, 1.0),
                  minHeight: 7,
                  backgroundColor: const Color(0xFFF0F1F8),
                  valueColor: AlwaysStoppedAnimation(accent),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
          decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(9)),
          child: Text(skill.cefrLevel,
              style: const TextStyle(
                  fontSize: 11.5, fontWeight: FontWeight.w900, color: Colors.white)),
        ),
      ],
    );
  }
}

// ── Certificados: medallas obtenidas + próximo bloqueado con requisitos ──────
class _CertsPanel extends StatelessWidget {
  const _CertsPanel({
    required this.certs,
    required this.mastery,
    required this.exam,
    required this.course,
  });
  final List<Certificate> certs;
  final SkillMasteryStatus? mastery;
  final LevelExamStatus exam;
  final CourseInfo? course;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final langName = course != null ? learnLangName(l10n, course!.target) : '';
    // Próximo nivel a certificar: el nivel de trabajo del dominio (real).
    final nextLevel = mastery?.workingLevel ?? exam.level;
    final alreadyCertified =
        certs.any((c) => c.cefrLevel == nextLevel) || (mastery?.examHasCertificate ?? false);
    final readyCount = mastery == null
        ? 0
        : mastery!.skills.where((s) => s.examReady).length;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 6), blurRadius: 0),
          BoxShadow(color: Color(0x1A3C3778), offset: Offset(0, 16), blurRadius: 30),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star_rounded, color: AppColors.gold, size: 20),
              const SizedBox(width: 8),
              Text(l10n.profileCertificatesTitle,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.text)),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Medallas obtenidas (si hay).
              for (final c in certs.take(2)) ...[
                Expanded(child: _CertMedal(cert: c, langName: langName)),
                const SizedBox(width: 12),
              ],
              // Próximo nivel bloqueado con requisitos (si aún no certificado).
              if (!alreadyCertified && nextLevel.isNotEmpty)
                Expanded(
                  child: _CertLocked(
                    level: nextLevel,
                    langName: langName,
                    readyCount: readyCount,
                    readyFlags: mastery == null
                        ? const []
                        : [for (final s in mastery!.skills) s.examReady],
                    unlocked: exam.unlocked,
                  ),
                ),
              if (certs.isEmpty && (alreadyCertified || nextLevel.isEmpty))
                Expanded(child: _EmptyHint(text: l10n.profileNoAchievements)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CertMedal extends StatelessWidget {
  const _CertMedal({required this.cert, required this.langName});
  final Certificate cert;
  final String langName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => CertificateScreen(cert: cert, celebrate: false))),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFFAED), Color(0xFFFFF1CF)]),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFF4DCA0), width: 1.5),
        ),
        child: Column(
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFFFDD7A), AppColors.gold]),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Color(0xFFD69400), offset: Offset(0, 5), blurRadius: 0),
                      ],
                    ),
                    child: Text(cert.cefrLevel,
                        style: const TextStyle(
                            fontSize: 21, fontWeight: FontWeight.w900, color: Colors.white)),
                  ),
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                      ),
                      child: const Icon(Icons.check_rounded, color: Colors.white, size: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 9),
            Text('$langName ${cert.cefrLevel}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.text)),
            const SizedBox(height: 1),
            Text(l10n.profileCertVerifiedLine,
                style: const TextStyle(
                    fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFFC98A12))),
            if (cert.issuedAt != null)
              Text(MaterialLocalizations.of(context).formatMediumDate(cert.issuedAt!),
                  style: const TextStyle(
                      fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFFB0A48A))),
          ],
        ),
      ),
    );
  }
}

class _CertLocked extends StatelessWidget {
  const _CertLocked({
    required this.level,
    required this.langName,
    required this.readyCount,
    required this.readyFlags,
    required this.unlocked,
  });
  final String level;
  final String langName;
  final int readyCount;
  final List<bool> readyFlags;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: unlocked
          ? () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LevelExamIntroScreen()))
          : null,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F7FB),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE7E9F2), width: 1.5),
        ),
        child: Column(
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: unlocked
                          ? const LinearGradient(
                              colors: [AppColors.primaryLight, AppColors.primary])
                          : const LinearGradient(
                              colors: [Color(0xFFD6DAE7), Color(0xFFBFC5D8)]),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: unlocked ? AppColors.primaryDark : const Color(0xFFAAB1C6),
                            offset: const Offset(0, 5),
                            blurRadius: 0),
                      ],
                    ),
                    child: Text(level,
                        style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                            color: Colors.white.withValues(alpha: 0.9))),
                  ),
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: unlocked ? AppColors.success : const Color(0xFF8A90A8),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                      ),
                      child: Icon(unlocked ? Icons.lock_open_rounded : Icons.lock_rounded,
                          color: Colors.white, size: 11),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 9),
            Text('$langName $level',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF6B7188))),
            const SizedBox(height: 2),
            Text(l10n.profileCertLockedNeed(level),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                    color: Color(0xFF9097AE))),
            if (readyFlags.isNotEmpty) ...[
              const SizedBox(height: 7),
              // 4 mini-barras: verde = habilidad lista para su examen.
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final ready in readyFlags)
                    Container(
                      width: 14,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: ready ? AppColors.success : AppColors.coral,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(l10n.profileCertReadyCount(readyCount),
                  style: const TextStyle(
                      fontSize: 9.5, fontWeight: FontWeight.w900, color: Color(0xFF9097AE))),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Estadísticas: calendario de racha + tiles Liga/Logros ────────────────────
class _StatsPanel extends ConsumerWidget {
  const _StatsPanel({required this.stats, required this.achievements});
  final HomeStats stats;
  final List<Achievement> achievements;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final league = ref.watch(leagueProvider).value;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 6), blurRadius: 0),
          BoxShadow(color: Color(0x1A3C3778), offset: Offset(0, 16), blurRadius: 30),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(l10n.profileStatsTitle,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.text)),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const StreakScreen())),
            child: _StreakCalendar(stats: stats),
          ),
          const SizedBox(height: 11),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.6,
            children: [
              _StatTile(
                  iconBg: AppColors.navActiveBg,
                  icon: const Icon(Icons.bolt_rounded, color: AppColors.primary, size: 19),
                  value: '${stats.xpTotal}',
                  label: l10n.profileStatXp),
              _StatTile(
                  iconBg: const Color(0xFFFFF4D6),
                  icon: const Icon(Icons.monetization_on_rounded,
                      color: AppColors.goldDark, size: 19),
                  value: '${stats.gold}',
                  label: l10n.profileStatGold),
              _StatTile(
                  iconBg: const Color(0xFFFFF4D6),
                  icon: const Icon(Icons.emoji_events_rounded,
                      color: AppColors.goldDark, size: 19),
                  value: league != null
                      ? l10n.leagueTitle(divisionLabel(l10n, league.division))
                      : '—',
                  label: league != null && league.myRank > 0
                      ? l10n.profileLeagueRank(league.myRank)
                      : l10n.leagueTabMyLeague),
              _StatTile(
                  iconBg: const Color(0xFFFFEFEF),
                  icon: const Icon(Icons.star_rounded, color: AppColors.coral, size: 19),
                  value: '${achievements.where((a) => a.unlocked).length}',
                  label: l10n.profileAchievementsTitle),
            ],
          ),
        ],
      ),
    );
  }
}

/// Calendario semanal de racha (Perfil.dc): días activos derivados de la racha
/// REAL — si la racha es N y hoy hubo actividad, los últimos N días fueron
/// activos (semántica exacta de la racha). Futuro = pálido.
class _StreakCalendar extends StatelessWidget {
  const _StreakCalendar({required this.stats});
  final HomeStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ml = MaterialLocalizations.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monday = today.subtract(Duration(days: today.weekday - 1));
    final todayActive = stats.dailyXpEarned > 0;
    // Ventana activa real: [inicio de racha, último día activo].
    final lastActive = todayActive ? today : today.subtract(const Duration(days: 1));
    final firstActive = stats.currentStreak <= 0
        ? null
        : lastActive.subtract(Duration(days: stats.currentStreak - 1));
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFFF3E6), Color(0xFFFFEFE0)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.local_fire_department_rounded,
                  color: AppColors.streak, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(l10n.profileStreakLine(stats.currentStreak),
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFFE8650A))),
              ),
              Text(l10n.profileStreakBest(stats.longestStreak),
                  style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFFC9893E))),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < 7; i++)
                Builder(builder: (_) {
                  final day = monday.add(Duration(days: i));
                  final isToday = day == today;
                  final done = firstActive != null &&
                      !day.isBefore(firstActive) &&
                      !day.isAfter(lastActive) &&
                      !(isToday && !todayActive);
                  final future = day.isAfter(today);
                  return Column(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isToday
                              ? AppColors.gold
                              : done
                                  ? AppColors.streak
                                  : const Color(0xFFFCE3CB),
                          borderRadius: BorderRadius.circular(10),
                          border: isToday
                              ? Border.all(color: AppColors.streak, width: 2.5)
                              : null,
                          boxShadow: done && !isToday
                              ? const [
                                  BoxShadow(
                                      color: Color(0xFFD96400),
                                      offset: Offset(0, 3),
                                      blurRadius: 0)
                                ]
                              : null,
                        ),
                        child: isToday
                            ? Text(todayActive ? '🔥' : '·',
                                style: const TextStyle(fontSize: 12))
                            : done
                                ? const Icon(Icons.check_rounded,
                                    color: Colors.white, size: 15)
                                : null,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isToday
                            ? l10n.profileStreakToday
                            : ml.narrowWeekdays[day.weekday % 7].toUpperCase(),
                        style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                            color: isToday
                                ? const Color(0xFFE8650A)
                                : future
                                    ? const Color(0xFFC9A98A)
                                    : const Color(0xFFC9893E)),
                      ),
                    ],
                  );
                }),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.iconBg,
    required this.icon,
    required this.value,
    required this.label,
  });
  final Color iconBg;
  final Widget icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7FB),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(11)),
            child: icon,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.text)),
                Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Secciones conservadas (Para ti, cuaderno, gate, plan, logros) ────────────
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

/// Compuerta de dominio → examen (modelo v2 per-skill).
class _MasteryGate extends StatelessWidget {
  const _MasteryGate({required this.mastery});
  final SkillMasteryStatus mastery;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final unlocked = mastery.examUnlocked;
    final certified = mastery.examHasCertificate;
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
