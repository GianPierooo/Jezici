import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/providers.dart';
import 'onboarding_data.dart';
import 'widgets/onboarding_scaffold.dart';

/// Test de ubicación adaptativo, calificado en el SERVIDOR (placement_next, mig 076).
/// El cliente es un RELAY: pide el siguiente ítem, muestra las opciones, envía la
/// elegida y repite hasta que el servidor devuelve el nivel final. NO califica ni ve
/// la respuesta correcta (correct_answer sigue 42501). El motor adaptativo (escalera
/// + estimador "techo") vive en el servidor → ubica al usuario en su nivel REAL.
class PlacementTest extends ConsumerStatefulWidget {
  const PlacementTest({
    super.key,
    required this.data,
    required this.step,
    required this.total,
    required this.onBack,
    required this.onDone,
    this.startLevel = 1,
  });

  final OnboardingData data;
  final int step;
  final int total;
  final VoidCallback onBack;
  final VoidCallback onDone;

  /// Dificultad inicial (de la micro-pregunta): 0=A1 1=A2 2=B1 → hint CEFR.
  final int startLevel;

  @override
  ConsumerState<PlacementTest> createState() => _PlacementTestState();
}

class _PlacementTestState extends ConsumerState<PlacementTest> {
  static const _hintCefr = ['A1', 'A2', 'B1'];

  final List<Map<String, dynamic>> _history = [];
  Map<String, dynamic>? _item; // ítem actual (id, type, skill, cefr_level, prompt, payload)
  int _asked = 0;
  int _max = 12;
  bool _loading = true;
  int _retries = 0;

  String get _hint => _hintCefr[widget.startLevel.clamp(0, _hintCefr.length - 1)];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ref
          .read(progressRepositoryProvider)
          .placementNext(startLevel: _hint, history: _history);
      if (!mounted) return;
      if (res['done'] == true) {
        _finish(res);
        return;
      }
      setState(() {
        _item = Map<String, dynamic>.from(res['item'] as Map);
        _asked = (res['asked'] as int? ?? _history.length) + 1;
        _max = res['max'] as int? ?? _max;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      // Reintento suave; si persiste, no dejamos el onboarding sin salida: ubicamos
      // por el hint del usuario (su autoevaluación) y seguimos.
      if (_retries < 1) {
        _retries++;
        _load();
        return;
      }
      _finishFallback();
    }
  }

  void _answer(String value) {
    final it = _item;
    if (it == null) return;
    _history.add({'item_id': it['id'], 'answer': value});
    _load();
  }

  void _finish(Map<String, dynamic> res) {
    final level = (res['level'] as String?) ?? _hint;
    final sk = res['skill_levels'] as Map?;
    widget.data.placementLevel = level;
    widget.data.skillLevels = {
      'reading': (sk?['reading'] as String?) ?? level,
      'listening': (sk?['listening'] as String?) ?? level,
      'writing': (sk?['writing'] as String?) ?? level,
      'speaking': (sk?['speaking'] as String?) ?? level,
    };
    widget.onDone();
  }

  void _finishFallback() {
    widget.data.placementLevel = _hint;
    widget.data.skillLevels = {
      'reading': _hint,
      'listening': _hint,
      'writing': _hint,
      'speaking': _hint,
    };
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final it = _item;
    final options =
        ((it?['payload'] as Map?)?['options'] as List?)?.map((e) => e.toString()).toList() ??
            const <String>[];
    return OnboardingScaffold(
      step: widget.step,
      total: widget.total,
      onBack: widget.onBack,
      title: 'Test de ubicación',
      subtitle: 'Sin pistas · pregunta $_asked de $_max',
      child: _loading || it == null
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(color: Color(0xFFECEDF6), offset: Offset(0, 4), blurRadius: 0),
                    ],
                  ),
                  child: Text((it['prompt'] ?? '').toString(),
                      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, height: 1.3)),
                ),
                for (final opt in options)
                  OnboardingOption(
                    label: opt,
                    selected: false,
                    onTap: () => _answer(opt),
                  ),
              ],
            ),
    );
  }
}
