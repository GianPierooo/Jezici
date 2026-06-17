import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/checkpoint_models.dart';
import '../../data/providers.dart';
import '../lesson/exercises/exercise_registry.dart';
import 'level_exam_result_screen.dart';

/// Reproductor del EXAMEN DE NIVEL: cronómetro, set aleatorizado de las 6
/// unidades, sin pistas, auto-envía al expirar. Submit y certificación server-side.
class LevelExamPlayerScreen extends ConsumerStatefulWidget {
  const LevelExamPlayerScreen({super.key, required this.data});
  final CheckpointStartData data;

  @override
  ConsumerState<LevelExamPlayerScreen> createState() => _State();
}

class _State extends ConsumerState<LevelExamPlayerScreen> {
  final ValueNotifier<Object?> _answer = ValueNotifier<Object?>(null);
  final List<Map<String, dynamic>> _answers = [];
  Timer? _timer;
  late int _remaining;
  int _index = 0;
  bool _submitting = false;

  List get _items => widget.data.items;

  @override
  void initState() {
    super.initState();
    _remaining = widget.data.timeLimitSec;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _remaining = (_remaining - 1).clamp(0, 99999));
      if (_remaining <= 0) { _timer?.cancel(); _submit(); }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _answer.dispose();
    super.dispose();
  }

  Object? _json(Object? v) => v is Map ? v.map((k, val) => MapEntry(k.toString(), val)) : v;

  void _next() {
    _answers.add({'item_id': _items[_index].id, 'answer': _json(_answer.value)});
    if (_index + 1 >= _items.length) { _timer?.cancel(); _submit(); return; }
    setState(() { _index++; _answer.value = null; });
  }

  Future<void> _submit() async {
    if (_submitting) return;
    _submitting = true;
    final taken = widget.data.timeLimitSec - _remaining;
    showDialog<void>(
      context: context, barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );
    try {
      final result = await ref.read(progressRepositoryProvider).submitLevelExam(_answers, taken);
      ref.invalidate(homeStatsProvider);
      ref.invalidate(skillsProvider);
      ref.invalidate(levelExamStatusProvider);
      ref.invalidate(certificatesProvider);
      ref.invalidate(achievementsProvider);
      if (!mounted) return;
      Navigator.pop(context);
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => LevelExamResultScreen(result: result)));
    } catch (_) {
      if (!mounted) return;
      Navigator.pop(context);
      _submitting = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo enviar el examen. Intenta de nuevo.')));
    }
  }

  void _confirmExit() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Salir del examen?'),
        content: const Text('Perderás el progreso de este intento.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Seguir')),
          FilledButton(
            onPressed: () { Navigator.pop(ctx); Navigator.of(context).popUntil((r) => r.isFirst); },
            child: const Text('Salir')),
        ],
      ),
    );
  }

  String get _t {
    final m = (_remaining ~/ 60).toString().padLeft(2, '0');
    final s = (_remaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) return const Scaffold(body: Center(child: Text('Examen sin ítems.')));
    final item = _items[_index];
    final total = _items.length;
    final low = _remaining <= 60;
    final isLast = _index + 1 >= total;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _confirmExit,
                    child: Container(
                      width: 34, height: 34,
                      decoration: BoxDecoration(color: const Color(0xFFEBEDF5), borderRadius: BorderRadius.circular(11)),
                      child: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 18)),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: low ? const Color(0xFFFFE9ED) : AppColors.navActiveBg,
                      borderRadius: BorderRadius.circular(12)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.timer_outlined, size: 17, color: low ? AppColors.hearts : AppColors.primary),
                      const SizedBox(width: 5),
                      Text(_t, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: low ? AppColors.hearts : AppColors.primary)),
                    ]),
                  ),
                  const Spacer(),
                  Text('${_index + 1} / $total', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textMuted)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(children: [
                  Container(height: 8, color: const Color(0xFFE5E7F1)),
                  AnimatedFractionallySizedBox(
                    duration: const Duration(milliseconds: 250),
                    widthFactor: (_index / total).clamp(0.0, 1.0),
                    child: Container(height: 8, decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [AppColors.primaryLight, AppColors.primary]))),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.navActiveBg, borderRadius: BorderRadius.circular(10)),
                  child: Text(item.skill.toUpperCase(),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.primary)),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if ((item.prompt ?? '').isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: Text(item.prompt!,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.text)),
                      ),
                    KeyedSubtree(key: ValueKey(item.id), child: buildExerciseWidget(context, item, _answer, false)),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 22),
              child: GestureDetector(
                onTap: _next,
                child: Container(
                  height: 56, alignment: Alignment.center,
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
                  child: Text(isLast ? 'TERMINAR' : 'SIGUIENTE',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
