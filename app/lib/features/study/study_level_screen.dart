import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/ui/jz_transitions.dart';
import '../../core/ui/responsive_center.dart';
import '../../l10n/app_localizations.dart';
import 'study_model.dart';
import 'study_topic_screen.dart';

/// ESTUDIAR · nivel → lista de TEMAS (las unidades de ese nivel).
/// Un tema BLOQUEADO (unidad aún no alcanzada en el mapa) sale con candado y
/// dice qué falta — el estado viene del progreso REAL, no de un gating propio.
class StudyLevelScreen extends ConsumerWidget {
  const StudyLevelScreen({super.key, required this.cefr});
  final String cefr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final levels = ref.watch(studyPlanProvider);
    final level = levels.where((l) => l.cefr == cefr).firstOrNull;
    final topics = level?.topics ?? const <StudyTopic>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: Text('${l10n.studyTitle} · $cefr',
            style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.text)),
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 560,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
            children: [
              for (final t in topics) ...[
                _TopicRow(
                  topic: t,
                  onTap: t.unlocked
                      ? () => Navigator.of(context)
                          .push(jzRoute(StudyTopicScreen(unitId: t.unit.id)))
                      : null,
                ),
                const SizedBox(height: 11),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TopicRow extends StatelessWidget {
  const _TopicRow({required this.topic, this.onTap});
  final StudyTopic topic;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locked = !topic.unlocked;
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: locked ? 0.72 : 1,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 5), blurRadius: 0),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: locked ? const Color(0xFFEFF1F8) : AppColors.navActiveBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  locked ? Icons.lock_rounded : Icons.menu_book_rounded,
                  size: 21,
                  color: locked ? AppColors.textMuted : AppColors.primary,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(topic.unit.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 14.5, fontWeight: FontWeight.w900, color: AppColors.text)),
                    const SizedBox(height: 3),
                    Text(
                      locked
                          ? l10n.studyLocked(topic.requiredUnitOrder)
                          : (topic.hasTheory
                              ? l10n.studyConcepts(topic.tips.length)
                              : l10n.studyNoTheoryTitle),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: locked ? AppColors.coral : AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              if (!locked) ...[
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
