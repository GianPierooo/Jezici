import 'package:flutter/material.dart';

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
const _questions = <_PQ>[
  _PQ('Si fallas tu meta del día, ¿qué prefieres oír?', [
    ('“Sin excusas. Retómalo ya.”', 'mano_dura'),
    ('“¡Mañana lo das todo, tú puedes! 💪”', 'positivo'),
    ('“Vas quedando atrás de tu plan, recupéralo.”', 'rezago'),
    ('“Tranqui, cuando puedas seguimos 🙂”', 'suave'),
  ]),
  _PQ('¿Cómo te gusta que te motivemos a practicar?', [
    ('Firme y directo', 'mano_dura'),
    ('Con energía y celebración', 'positivo'),
    ('Recordándome mis metas y mi avance', 'rezago'),
    ('Suave, sin presión', 'suave'),
  ]),
  _PQ('En la liga alguien te supera. ¿Qué te activa?', [
    ('Que me reten a recuperarme', 'mano_dura'),
    ('Ánimo para subir posiciones', 'positivo'),
    ('Ver cuánto me falta para alcanzarlo', 'rezago'),
    ('Nada, voy a mi ritmo', 'suave'),
  ]),
  _PQ('Cuando logras algo, ¿qué mensaje disfrutas más?', [
    ('“Bien. Ahora el siguiente reto.”', 'mano_dura'),
    ('“¡Increíble, eres imparable! 🎉”', 'positivo'),
    ('“Vas adelantado a tu plan.”', 'rezago'),
    ('“Qué bien, sigue a tu ritmo 🙂”', 'suave'),
  ]),
  _PQ('¿Qué tan seguido quieres que te recordemos?', [
    ('Mucho, no me dejes aflojar', '3'),
    ('Lo justo', '2'),
    ('Poco', '1'),
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
    final q = _questions[_q];
    if (q.isIntensity) {
      widget.data.intensity = int.tryParse(key) ?? 2;
    } else {
      _scores[key] = (_scores[key] ?? 0) + 1;
    }
    if (_q + 1 >= _questions.length) {
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
    final q = _questions[_q];
    return OnboardingScaffold(
      step: widget.step,
      total: widget.total,
      onBack: _back,
      title: 'Tu coach ideal',
      subtitle: 'Pregunta ${_q + 1} de ${_questions.length}',
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
