import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/ui/jz_transitions.dart';
import '../../core/ui/responsive_center.dart';
import '../../data/models/immersion_models.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import 'story_reader_screen.dart';

/// INMERSIÓN (Metodologia · "Sesión de inmersión"): historias/diálogos cortos
/// con audio y preguntas de comprensión. Input comprensible, calibrado al CEFR.
class ImmersionScreen extends ConsumerWidget {
  const ImmersionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(storiesProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(l10n.immTitle,
            style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.text)),
        iconTheme: const IconThemeData(color: AppColors.text),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Text(l10n.immLoadError,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textMuted)),
          ),
        ),
        data: (stories) {
          if (stories.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Text(l10n.immEmpty,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textMuted)),
              ),
            );
          }
          final byLevel = <String, List<StorySummary>>{};
          for (final s in stories) {
            byLevel.putIfAbsent(s.level, () => []).add(s);
          }
          return ResponsiveCenter(
            maxWidth: 640,
            child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              Text(l10n.immSubtitle,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
              const SizedBox(height: 16),
              for (final level in byLevel.keys) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 2, bottom: 8, top: 4),
                  child: Text(l10n.immLevel(level),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.text)),
                ),
                for (final s in byLevel[level]!) _StoryCard(story: s),
                const SizedBox(height: 10),
              ],
            ],
          ),
          );
        },
      ),
    );
  }
}

class _StoryCard extends ConsumerWidget {
  const _StoryCard({required this.story});
  final StorySummary story;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () async {
          await Navigator.of(context).push(jzRoute(StoryReaderScreen(storyId: story.id)));
          ref.invalidate(storiesProvider);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 5), blurRadius: 0)],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(15)),
                child: Text(story.emoji, style: const TextStyle(fontSize: 26)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(story.title,
                        style: const TextStyle(
                            fontSize: 15.5, fontWeight: FontWeight.w900, color: AppColors.text)),
                    const SizedBox(height: 2),
                    Text(story.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                    const SizedBox(height: 6),
                    Row(children: [
                      _chip('📖 ${story.segmentCount}'),
                      const SizedBox(width: 6),
                      _chip('❓ ${story.questionCount}'),
                      const SizedBox(width: 6),
                      _chip('~${(story.estSeconds / 60).ceil()} min'),
                    ]),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (story.completed)
                const Icon(Icons.check_circle_rounded, color: AppColors.success)
              else
                const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
            color: const Color(0xFFF1F2FA), borderRadius: BorderRadius.circular(8)),
        child: Text(label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
      );
}
