import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/ui/jz_transitions.dart';
import '../../core/ui/responsive_center.dart';
import '../../data/models/practice_models.dart';
import '../../data/models/progress_models.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/skill_names.dart';
import '../../ui/primary_button.dart';
import '../immersion/immersion_screen.dart';
import '../learn/widgets/parrot_mascot.dart';
import 'srs_review_screen.dart';
import '../reference/reference_screen.dart';
import 'practice_player_screen.dart';

/// Pestaña PRACTICAR (Practicar.dc): header violeta + HERO "Rescate de palabras"
/// (SRS) + filas compactas (punto débil, reforzar fallos) + grid 2×2 de modos +
/// banner de contrarreloj. Toda la copia va por localización (i18n es/en/pt).
/// La lógica de práctica/SRS/scoring es server-side y NO se toca: cada card sólo
/// dispara la sesión real existente (start_practice / pantallas de repaso).
class PracticeScreen extends ConsumerStatefulWidget {
  const PracticeScreen({super.key});

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  String? _loading; // modo en carga

  /// SRS: cola propia (vencidas + nuevas con límite del servidor) y pantalla de
  /// tarjeta escrita con 4 botones. No pasa por PracticePlayerScreen (que sirve
  /// ítems de contenido); el repaso es otro producto.
  Future<void> _startSrs() async {
    if (_loading != null) return;
    setState(() => _loading = 'srs');
    final l10n = AppLocalizations.of(context);
    try {
      final s = await ref.read(progressRepositoryProvider).startSrs();
      if (!mounted) return;
      if (s.cards.isEmpty) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.srsNothingDue)));
        return;
      }
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => SrsReviewScreen(session: s),
      ));
      ref.invalidate(practiceStatusProvider);
      ref.invalidate(srsStatusProvider);
      ref.invalidate(homeStatsProvider);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.practiceStartError)));
      }
    } finally {
      if (mounted) setState(() => _loading = null);
    }
  }

  Future<void> _start(String mode, {String? skill, int? timeLimit, required String title}) async {
    if (_loading != null) return;
    setState(() => _loading = mode + (skill ?? ''));
    final l10n = AppLocalizations.of(context);
    try {
      final session =
          await ref.read(progressRepositoryProvider).startPractice(mode, skill: skill);
      if (!mounted) return;
      if (session.items.isEmpty) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.practiceNothingToReview)));
        return;
      }
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => PracticePlayerScreen(
          mode: mode,
          title: title,
          items: session.items,
          timeLimitSec: timeLimit,
        ),
      ));
      ref.invalidate(practiceStatusProvider);
      ref.invalidate(skillsProvider);
      ref.invalidate(skillMasteryProvider);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.practiceStartError)));
      }
    } finally {
      if (mounted) setState(() => _loading = null);
    }
  }

  SkillLevel? _levelFor(List<SkillLevel> skills, String? key) {
    if (key == null) return null;
    for (final s in skills) {
      if (s.skill == key) return s;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = ref.watch(practiceStatusProvider).value ?? PracticeStatus.empty;
    final skills = ref.watch(skillsProvider).value ?? const <SkillLevel>[];
    final weak = status.weakestSkill;
    final weakLevel = _levelFor(skills, weak);

    return ListView(
      padding: const EdgeInsets.only(bottom: 110),
      children: [
        const _Header(),
        Transform.translate(
          offset: const Offset(0, -14),
          child: ResponsiveCenter(
            maxWidth: 480,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // NOVATO (sin progreso): en vez de secciones que devuelven
                  // "nada que reforzar", un estado de BIENVENIDA honesto + lo que
                  // SÍ sirve desde el día 0 (Repaso + Inmersión).
                  if (!status.hasProgress) ...[
                    _SrsWelcome(
                      onGo: () =>
                          ref.read(homeTabRequestProvider.notifier).request(0), // → mapa
                    ),
                    const SizedBox(height: 18),
                    Text(l10n.practiceMeanwhileExplore,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.text)),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 11,
                      crossAxisSpacing: 11,
                      childAspectRatio: 2.35,
                      children: [
                        _ModeTile(
                          icon: Icons.auto_stories_rounded,
                          iconBg: const Color(0xFFFFF4D6),
                          iconColor: AppColors.goldDark,
                          title: l10n.practiceRepasoTitle,
                          subtitle: l10n.practiceRepasoSubtitle,
                          onTap: () =>
                              Navigator.of(context).push(jzRoute(const ReferenceScreen())),
                        ),
                        _ModeTile(
                          icon: Icons.headphones_rounded,
                          iconBg: const Color(0xFFE7F9EF),
                          iconColor: AppColors.success,
                          title: l10n.practiceImmersionTitle,
                          subtitle: l10n.practiceImmersionSubtitle,
                          onTap: () =>
                              Navigator.of(context).push(jzRoute(const ImmersionScreen())),
                        ),
                      ],
                    ),
                  ] else ...[
                    // HERO · Rescate de palabras (SRS). El número viene del
                    // SERVIDOR (get_srs_status): vencidas + nuevas que caben hoy
                    // = lo que la sesión REALMENTE va a servir. Antes el cliente
                    // contaba por su cuenta y podía no cuadrar con la sesión.
                    // Mientras carga, cae al conteo local (no parpadea a 0).
                    _SrsHero(
                      dueWords: ref.watch(srsStatusProvider).maybeWhen(
                            data: (s) => s.sessionCount,
                            orElse: () => status.dueWords,
                          ),
                      loading: _loading == 'srs',
                      onTap: _startSrs,
                    ),
                    const SizedBox(height: 16),
                    // Refuerza tu punto débil (con CEFR + mini-barra reales).
                    _WeakRow(
                      weakSkill: weak,
                      cefr: weakLevel?.cefrLevel,
                      progress: weakLevel?.levelProgress ?? 0,
                      loading: _loading == 'weakness',
                      onTap: () => _start('weakness', title: l10n.practiceWeakTitle),
                    ),
                    const SizedBox(height: 12),
                    // Reforzar lo que fallé.
                    _CompactRow(
                      icon: Icons.build_rounded,
                      iconBg: const Color(0xFFEDEBFF),
                      iconColor: AppColors.primary,
                      title: l10n.practiceReinforceTitle,
                      subtitle: l10n.practiceReinforceSubtitle,
                      loading: _loading == 'reinforce_unit',
                      onTap: () => _start('reinforce_unit', title: l10n.practiceReinforceTitle),
                    ),
                    const SizedBox(height: 18),
                    // Grid 2×2 de modos (integra los extra: repaso, inmersión).
                    Text(l10n.practiceMoreTitle,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.text)),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 11,
                      crossAxisSpacing: 11,
                      childAspectRatio: 2.35,
                      children: [
                        _ModeTile(
                          icon: Icons.menu_book_rounded,
                          iconBg: const Color(0xFFEDEBFF),
                          iconColor: AppColors.primary,
                          title: skillName(l10n, 'reading'),
                          subtitle: l10n.practiceReadingHint,
                          loading: _loading == 'skillreading',
                          onTap: () => _start('skill',
                              skill: 'reading', title: skillName(l10n, 'reading')),
                        ),
                        _ModeTile(
                          icon: Icons.edit_rounded,
                          iconBg: const Color(0xFFFFEFEF),
                          iconColor: AppColors.coral,
                          title: skillName(l10n, 'writing'),
                          subtitle: l10n.practiceWritingHint,
                          loading: _loading == 'skillwriting',
                          onTap: () => _start('skill',
                              skill: 'writing', title: skillName(l10n, 'writing')),
                        ),
                        _ModeTile(
                          icon: Icons.auto_stories_rounded,
                          iconBg: const Color(0xFFFFF4D6),
                          iconColor: AppColors.goldDark,
                          title: l10n.practiceRepasoTitle,
                          subtitle: l10n.practiceRepasoSubtitle,
                          onTap: () =>
                              Navigator.of(context).push(jzRoute(const ReferenceScreen())),
                        ),
                        _ModeTile(
                          icon: Icons.headphones_rounded,
                          iconBg: const Color(0xFFE7F9EF),
                          iconColor: AppColors.success,
                          title: l10n.practiceImmersionTitle,
                          subtitle: l10n.practiceImmersionSubtitle,
                          onTap: () =>
                              Navigator.of(context).push(jzRoute(const ImmersionScreen())),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Banner · Contrarreloj (90 s, alineado al mockup).
                    _TimedBanner(
                      loading: _loading == 'timed',
                      onTap: () =>
                          _start('timed', timeLimit: 90, title: l10n.practiceTimedTitle),
                    ),
                  ],
                  const SizedBox(height: 14),
                  const _XpNote(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Header violeta ────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final topPad = MediaQuery.paddingOf(context).top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(0, topPad + 20, 0, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7A6BF0), AppColors.primary, Color(0xFF5B4ECF)],
        ),
      ),
      child: ResponsiveCenter(
        maxWidth: 480,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.practiceKicker,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.6,
                            color: Colors.white.withValues(alpha: 0.7))),
                    const SizedBox(height: 3),
                    Text(l10n.practiceTitle,
                        style: const TextStyle(
                            fontSize: 27, fontWeight: FontWeight.w900, color: Colors.white)),
                    const SizedBox(height: 7),
                    Text(l10n.practiceHeaderSubtitle,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            height: 1.3,
                            color: Colors.white.withValues(alpha: 0.85))),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const ParrotMascot(size: 54),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Bienvenida a Practicar (novato sin progreso) ─────────────────────────────
/// En vez del HERO con un número falso de "palabras por repasar" (P0), un
/// estado honesto: aún no hay nada que repasar; empieza tu primera lección.
class _SrsWelcome extends StatelessWidget {
  const _SrsWelcome({required this.onGo});
  final VoidCallback onGo;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 5), blurRadius: 0),
        ],
      ),
      child: Column(children: [
        const ParrotMascot(size: 84, mood: MascotMood.encourage),
        const SizedBox(height: 10),
        Text(l10n.practiceWelcomeTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.text)),
        const SizedBox(height: 6),
        Text(l10n.practiceWelcomeBody,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMuted, height: 1.4)),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: PrimaryButton(
              label: l10n.practiceGoToLesson,
              icon: Icons.arrow_forward_rounded,
              onPressed: onGo),
        ),
      ]),
    );
  }
}

// ── HERO · Rescate de palabras (SRS) ─────────────────────────────────────────
class _SrsHero extends StatelessWidget {
  const _SrsHero({required this.dueWords, required this.onTap, required this.loading});
  final int dueWords;
  final VoidCallback onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final reduce = MediaQuery.of(context).disableAnimations;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 7), blurRadius: 0),
          BoxShadow(color: Color(0x1A3C3778), offset: Offset(0, 18), blurRadius: 32),
        ],
      ),
      child: Column(
        children: [
          // Cabecera durazno.
          Container(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFE9D6), Color(0xFFFFE0E0)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pill "REPASO ESPACIADO".
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.history_rounded, color: Color(0xFFE8650A), size: 13),
                      const SizedBox(width: 5),
                      Text(l10n.practiceSrsBadge,
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.6,
                              color: Color(0xFFE8650A))),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Contador grande con glow.
                    _GlowCounter(value: dueWords, reduce: reduce),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.practiceSrsWords,
                              style: const TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w900,
                                  height: 1.1,
                                  color: AppColors.text)),
                          const SizedBox(height: 2),
                          Text(
                            dueWords > 0 ? l10n.practiceSrsSubtitle : l10n.practiceSrsUpToDate,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFC9683E)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // CTA "Rescatar ahora".
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            child: _JuicyButton(
              label: l10n.practiceSrsCta,
              color: AppColors.coral,
              depth: AppColors.coralDark,
              height: 54,
              loading: loading,
              onTap: onTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowCounter extends StatelessWidget {
  const _GlowCounter({required this.value, required this.reduce});
  final int value;
  final bool reduce;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58,
      height: 58,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          if (!reduce)
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: RadialGradient(colors: [
                  AppColors.coral.withValues(alpha: 0.45),
                  AppColors.coral.withValues(alpha: 0.0),
                ]),
              ),
            ),
          Container(
            width: 58,
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFF8C8C), Color(0xFFFF5C5C)],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [BoxShadow(color: Color(0xFFDC4545), offset: Offset(0, 5), blurRadius: 0)],
            ),
            child: Text('$value',
                style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── Fila: refuerza tu punto débil (CEFR + mini-barra reales) ──────────────────
class _WeakRow extends StatelessWidget {
  const _WeakRow({
    required this.weakSkill,
    required this.cefr,
    required this.progress,
    required this.onTap,
    required this.loading,
  });
  final String? weakSkill;
  final String? cefr;
  final double progress;
  final VoidCallback onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _RowShell(
      icon: Icons.fitness_center_rounded,
      iconBg: const Color(0xFFE7F9EF),
      iconColor: AppColors.success,
      loading: loading,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.practiceWeakTitle,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.text)),
          const SizedBox(height: 5),
          if (weakSkill != null)
            Row(
              children: [
                Flexible(
                  child: Text(skillName(l10n, weakSkill!),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
                ),
                const SizedBox(width: 8),
                // Mini-barra de dominio (dato real: levelProgress).
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 78),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor: const Color(0xFFF0F1F8),
                        valueColor: const AlwaysStoppedAnimation(AppColors.coral),
                      ),
                    ),
                  ),
                ),
                if (cefr != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                    decoration: BoxDecoration(color: AppColors.coral, borderRadius: BorderRadius.circular(7)),
                    child: Text(cefr!,
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white)),
                  ),
                ],
              ],
            )
          else
            Text(l10n.practiceWeakGeneric,
                style: const TextStyle(
                    fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

// ── Fila compacta genérica ────────────────────────────────────────────────────
class _CompactRow extends StatelessWidget {
  const _CompactRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.loading,
  });
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return _RowShell(
      icon: icon,
      iconBg: iconBg,
      iconColor: iconColor,
      loading: loading,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.text)),
          const SizedBox(height: 3),
          Text(subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

/// Chasis común de una fila compacta: icon-tile + contenido + botón "Practicar".
class _RowShell extends StatelessWidget {
  const _RowShell({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.child,
    required this.onTap,
    required this.loading,
  });
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final Widget child;
  final VoidCallback onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 5), blurRadius: 0),
          BoxShadow(color: Color(0x123C3778), offset: Offset(0, 12), blurRadius: 22),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 13),
          Expanded(child: child),
          const SizedBox(width: 10),
          _MiniButton(label: l10n.practicePracticeBtn, loading: loading, onTap: onTap),
        ],
      ),
    );
  }
}

// ── Tile del grid ─────────────────────────────────────────────────────────────
class _ModeTile extends StatelessWidget {
  const _ModeTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.loading = false,
  });
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 4), blurRadius: 0),
            BoxShadow(color: Color(0x0F3C3778), offset: Offset(0, 10), blurRadius: 18),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(13)),
              child: loading
                  ? const Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(strokeWidth: 2.2))
                  : Icon(icon, color: iconColor, size: 21),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13.5, fontWeight: FontWeight.w900, color: AppColors.text)),
                  const SizedBox(height: 1),
                  Text(subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF9A9FB8))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Banner · Contrarreloj ─────────────────────────────────────────────────────
class _TimedBanner extends StatelessWidget {
  const _TimedBanner({required this.onTap, required this.loading});
  final VoidCallback onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, Color(0xFF5B4ECF)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: AppColors.primaryDark, offset: Offset(0, 6), blurRadius: 0),
          BoxShadow(color: Color(0x4D6C5CE7), offset: Offset(0, 14), blurRadius: 26),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFFDD7A), AppColors.gold]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Color(0xFFD69400), offset: Offset(0, 4), blurRadius: 0)],
                ),
                child: const Icon(Icons.timer_rounded, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(l10n.practiceTimedTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
                        ),
                        const SizedBox(width: 7),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                              color: AppColors.gold, borderRadius: BorderRadius.circular(7)),
                          child: Text(l10n.practiceTimedBadge,
                              style: const TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.text)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(l10n.practiceTimedSubtitle,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.white.withValues(alpha: 0.85))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          _JuicyButton(
            label: l10n.practiceTimedCta,
            color: Colors.white,
            depth: const Color(0x2E000000),
            textColor: AppColors.primary,
            height: 50,
            loading: loading,
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}

// ── Nota de XP ────────────────────────────────────────────────────────────────
class _XpNote extends StatelessWidget {
  const _XpNote();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, size: 15, color: Color(0xFFA7ABC3)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(l10n.practiceXpNote,
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700, height: 1.45, color: Color(0xFF9097AE))),
          ),
        ],
      ),
    );
  }
}

// ── Botones ───────────────────────────────────────────────────────────────────
class _MiniButton extends StatelessWidget {
  const _MiniButton({required this.label, required this.onTap, required this.loading});
  final String label;
  final VoidCallback onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(13),
          boxShadow: const [BoxShadow(color: AppColors.primaryDark, offset: Offset(0, 4), blurRadius: 0)],
        ),
        child: loading
            ? const SizedBox(
                width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white))
            : Text(label,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white)),
      ),
    );
  }
}

class _JuicyButton extends StatefulWidget {
  const _JuicyButton({
    required this.label,
    required this.color,
    required this.depth,
    required this.onTap,
    this.textColor = Colors.white,
    this.height = 54,
    this.loading = false,
  });
  final String label;
  final Color color;
  final Color depth;
  final VoidCallback onTap;
  final Color textColor;
  final double height;
  final bool loading;

  @override
  State<_JuicyButton> createState() => _JuicyButtonState();
}

class _JuicyButtonState extends State<_JuicyButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.of(context).disableAnimations;
    final enabled = !widget.loading;
    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: () => setState(() => _pressed = false),
      onTap: enabled ? widget.onTap : null,
      child: AnimatedContainer(
        duration: reduce ? Duration.zero : const Duration(milliseconds: 70),
        transform: Matrix4.translationValues(0, _pressed ? 4 : 0, 0),
        height: widget.height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: widget.depth, offset: Offset(0, _pressed ? 2 : 6), blurRadius: 0),
          ],
        ),
        child: widget.loading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.6, color: widget.textColor))
            : Text(widget.label,
                style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                    color: widget.textColor)),
      ),
    );
  }
}
