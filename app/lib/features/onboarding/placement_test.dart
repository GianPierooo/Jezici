import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/plan/estimation.dart';
import 'onboarding_data.dart';
import 'widgets/onboarding_scaffold.dart';

/// Test de ubicación adaptativo (Test_Ubicacion_Items.md): arranca en dificultad
/// media (~A2); acierto → sube un escalón, error → baja; converge al nivel CEFR.
class PlacementTest extends StatefulWidget {
  const PlacementTest({
    super.key,
    required this.data,
    required this.step,
    required this.total,
    required this.onBack,
    required this.onDone,
  });

  final OnboardingData data;
  final int step;
  final int total;
  final VoidCallback onBack;
  final VoidCallback onDone;

  @override
  State<PlacementTest> createState() => _PlacementTestState();
}

class _PItem {
  const _PItem(this.level, this.prompt, this.options, this.correct);
  final int level; // 0=A1 1=A2 2=B1 3=B2
  final String prompt;
  final List<String> options;
  final int correct;
}

const _items = <_PItem>[
  // A1
  _PItem(0, '“Hello” significa…', ['hola', 'gracias', 'adiós'], 0),
  _PItem(0, 'I ___ a student.', ['am', 'is', 'are'], 0),
  _PItem(0, 'Lo contrario de “yes” es…', ['no', 'please', 'hi'], 0),
  _PItem(0, '“Thank you” significa…', ['perdón', 'gracias', 'hola'], 1),
  // A2
  _PItem(1, 'She ___ to school every day.', ['go', 'goes', 'going'], 1),
  _PItem(1, "I'm from Peru. I ___ in Lima.", ['live', 'lives', 'living'], 0),
  _PItem(1, 'Yesterday I ___ pizza.', ['eat', 'ate', 'eaten'], 1),
  _PItem(1, 'There ___ two books on the table.', ['is', 'are', 'be'], 1),
  // B1
  _PItem(2, 'If it rains, I ___ at home.', ['stay', 'will stay', 'stayed'], 1),
  _PItem(2, 'She has worked here ___ 2020.', ['since', 'for', 'from'], 0),
  _PItem(2, 'I have ___ been to Japan.', ['never', 'ever', 'already'], 0),
  _PItem(2, "I'm used to ___ up early.", ['get', 'getting', 'got'], 1),
  // B2
  _PItem(3, 'I wish I ___ more time.', ['have', 'had', 'will have'], 1),
  _PItem(3, 'He was ___ to finish on time.', ['able', 'can', 'capable of'], 0),
  _PItem(3, 'If I ___ known, I would have told you.', ['have', 'had', 'did'], 1),
  _PItem(3, 'She said she ___ tired.', ['is', 'was', 'be'], 1),
];

const int _maxQuestions = 12;

class _PlacementTestState extends State<PlacementTest> {
  final _rng = math.Random();
  int _level = 1; // arranca en ~A2
  int _count = 0;
  final Set<int> _asked = {};
  final List<int> _askedLevels = [];
  late _PItem _current;
  late int _currentIdx;

  @override
  void initState() {
    super.initState();
    _pickNext();
  }

  void _pickNext() {
    final lvl = _level.clamp(0, 3);
    var pool = <int>[];
    for (var i = 0; i < _items.length; i++) {
      if (!_asked.contains(i) && _items[i].level == lvl) pool.add(i);
    }
    if (pool.isEmpty) {
      for (var i = 0; i < _items.length; i++) {
        if (!_asked.contains(i)) pool.add(i);
      }
    }
    _currentIdx = pool[_rng.nextInt(pool.length)];
    _current = _items[_currentIdx];
    _asked.add(_currentIdx);
    _askedLevels.add(_current.level);
  }

  void _answer(int optionIdx) {
    final correct = optionIdx == _current.correct;
    _count++;
    if (correct) {
      _level = (_level + 1).clamp(0, 3);
    } else {
      _level = (_level - 1).clamp(0, 3);
    }

    if (_count >= _maxQuestions || _asked.length >= _items.length) {
      _finish();
      return;
    }
    setState(_pickNext);
  }

  void _finish() {
    final mean = _askedLevels.reduce((a, b) => a + b) / _askedLevels.length;
    final idx = mean.round().clamp(0, 3);
    final level = CefrTable.order[idx]; // A1..B2
    widget.data.placementLevel = level;
    widget.data.skillLevels = {
      'reading': level,
      'listening': level,
      'writing': level,
      'speaking': level,
    };
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      step: widget.step,
      total: widget.total,
      onBack: widget.onBack,
      title: 'Test de ubicación',
      subtitle: 'Sin pistas · pregunta ${_count + 1} de $_maxQuestions',
      child: Column(
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
            child: Text(_current.prompt,
                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, height: 1.3)),
          ),
          for (var i = 0; i < _current.options.length; i++)
            OnboardingOption(
              label: _current.options[i],
              selected: false,
              onTap: () => _answer(i),
            ),
        ],
      ),
    );
  }
}
