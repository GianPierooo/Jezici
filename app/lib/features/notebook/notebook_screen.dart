import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/speech/speakable_text.dart';
import '../../core/theme/app_colors.dart';
import '../learn/widgets/parrot_mascot.dart';
import '../../data/models/tip_models.dart';
import '../../data/providers.dart';

/// Cuaderno de datos (capa "enseña"): los tips que el usuario ha visto, navegables.
class NotebookScreen extends ConsumerWidget {
  const NotebookScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tipsAsync = ref.watch(notebookProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Cuaderno de datos',
            style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.text)),
        iconTheme: const IconThemeData(color: AppColors.text),
      ),
      body: tipsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (_, _) => const _Empty(),
        data: (tips) => tips.isEmpty
            ? const _Empty()
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                itemCount: tips.length + 1,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  if (i == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '${tips.length} ${tips.length == 1 ? 'dato aprendido' : 'datos aprendidos'} 🦜',
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textMuted),
                      ),
                    );
                  }
                  return _NotebookTip(tip: tips[i - 1]);
                },
              ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ParrotArt(size: 56),
            SizedBox(height: 14),
            Text('Tu cuaderno está vacío… por ahora',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.text)),
            SizedBox(height: 6),
            Text('Completa lecciones y Jezi te enseñará datos, trucos y errores comunes que se guardarán aquí.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _NotebookTip extends StatelessWidget {
  const _NotebookTip({required this.tip});
  final TipModel tip;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 4), blurRadius: 0),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                    color: AppColors.navActiveBg, borderRadius: BorderRadius.circular(8)),
                child: Text(tip.typeLabel,
                    style: const TextStyle(
                        fontSize: 10.5, fontWeight: FontWeight.w900, color: AppColors.primary)),
              ),
              const Spacer(),
              Text('${tip.cefrLevel} · U${tip.unitOrder ?? ''}',
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 9),
          Text(tip.title,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.text)),
          const SizedBox(height: 4),
          Text(tip.body,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text, height: 1.4)),
          if (tip.example != null && tip.example!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
              decoration: BoxDecoration(
                  color: AppColors.background, borderRadius: BorderRadius.circular(10)),
              // Ejemplo en el idioma META: tócalo para oírlo (Web Speech).
              child: SpeakableText(tip.example!,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.text, height: 1.3)),
            ),
          ],
        ],
      ),
    );
  }
}
