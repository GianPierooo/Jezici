import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'onboarding_data.dart';
import 'widgets/onboarding_scaffold.dart';

/// Test de personalidad (Test_Personalidad.md): 4 preguntas de estilo (cada una
/// es una situación DISTINTA, sin variantes repetidas) + 1 de intensidad. Mapea
/// a un estilo de coach (mano_dura/positivo/rezago/suave) que gobierna el tono
/// de Matix en toda la app.
class PersonalityTest extends StatefulWidget {
  const PersonalityTest({
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
  State<PersonalityTest> createState() => _PersonalityTestState();
}

class _PQ {
  const _PQ(this.prompt, this.options, {this.isIntensity = false});
  final String prompt;
  final List<(String, String)> options; // (label, key)
  final bool isIntensity;
}

// 4 situaciones DISTINTAS (fallo · empujón · competencia · logro), cada opción
// mapea a un estilo. + 1 pregunta de intensidad (frecuencia, dimensión aparte).
List<_PQ> _buildQuestions(AppLocalizations l10n) => <_PQ>[
      _PQ(l10n.onbPersonalityQ1, [
        (l10n.onbPersonalityQ1Opt1, 'mano_dura'),
        (l10n.onbPersonalityQ1Opt2, 'positivo'),
        (l10n.onbPersonalityQ1Opt3, 'rezago'),
        (l10n.onbPersonalityQ1Opt4, 'suave'),
      ]),
      _PQ(l10n.onbPersonalityQ2, [
        (l10n.onbPersonalityQ2Opt1, 'mano_dura'),
        (l10n.onbPersonalityQ2Opt2, 'positivo'),
        (l10n.onbPersonalityQ2Opt3, 'rezago'),
        (l10n.onbPersonalityQ2Opt4, 'suave'),
      ]),
      _PQ(l10n.onbPersonalityQ3, [
        (l10n.onbPersonalityQ3Opt1, 'mano_dura'),
        (l10n.onbPersonalityQ3Opt2, 'positivo'),
        (l10n.onbPersonalityQ3Opt3, 'rezago'),
        (l10n.onbPersonalityQ3Opt4, 'suave'),
      ]),
      _PQ(l10n.onbPersonalityQ4, [
        (l10n.onbPersonalityQ4Opt1, 'mano_dura'),
        (l10n.onbPersonalityQ4Opt2, 'positivo'),
        (l10n.onbPersonalityQ4Opt3, 'rezago'),
        (l10n.onbPersonalityQ4Opt4, 'suave'),
      ]),
      _PQ(l10n.onbIntensityQ, [
        (l10n.onbIntensityOpt1, '3'),
        (l10n.onbIntensityOpt2, '2'),
        (l10n.onbIntensityOpt3, '1'),
      ], isIntensity: true),
    ];

class _PersonalityTestState extends State<PersonalityTest> {
  int _q = 0;
  final Map<String, int> _scores = {
    'mano_dura': 0,
    'positivo': 0,
    'rezago': 0,
    'suave': 0,
  };

  void _answer(String key) {
    final questions = _buildQuestions(AppLocalizations.of(context));
    final q = questions[_q];
    if (q.isIntensity) {
      widget.data.intensity = int.tryParse(key) ?? 2;
    } else {
      _scores[key] = (_scores[key] ?? 0) + 1;
    }
    if (_q + 1 >= questions.length) {
      // Estilo dominante; empate → preferir la P1.
      var best = 'suave';
      var bestN = -1;
      for (final s in ['mano_dura', 'positivo', 'rezago', 'suave']) {
        if ((_scores[s] ?? 0) > bestN) {
          bestN = _scores[s] ?? 0;
          best = s;
        }
      }
      widget.data.coachStyle = best;
      widget.onDone();
      return;
    }
    setState(() => _q++);
  }

  void _back() {
    if (_q == 0) {
      widget.onBack();
    } else {
      setState(() => _q--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final questions = _buildQuestions(l10n);
    final q = questions[_q];
    return OnboardingScaffold(
      step: widget.step,
      total: widget.total,
      onBack: _back,
      title: l10n.onbPersonalityTitle,
      subtitle: l10n.onbPersonalityStep(_q + 1, questions.length),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(q.prompt,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800, height: 1.3)),
          ),
          for (final (label, key) in q.options)
            OnboardingOption(label: label, selected: false, onTap: () => _answer(key)),
        ],
      ),
    );
  }
}
