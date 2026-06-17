import 'package:flutter/material.dart';

import 'onboarding_data.dart';
import 'widgets/onboarding_scaffold.dart';

/// Test de personalidad (Test_Personalidad.md): 6 preguntas de estilo + 1 de
/// intensidad. Mapea a un estilo de coach (mano_dura/positivo/rezago/suave).
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

const _questions = <_PQ>[
  _PQ('Cuando no cumples una meta, ¿qué te funciona más?', [
    ('Que me lo digan sin rodeos', 'mano_dura'),
    ('Que me animen a retomar con energía', 'positivo'),
    ('Que me recuerden lo que me estoy perdiendo', 'rezago'),
    ('Que me lo tomen con calma', 'suave'),
  ]),
  _PQ('Tu racha está en riesgo. ¿Qué mensaje prefieres?', [
    ('“Eso no va. Vuelve ya.”', 'mano_dura'),
    ('“¡No rompas la magia, tú puedes! 💪”', 'positivo'),
    ('“Vas quedando atrás de tu plan.”', 'rezago'),
    ('“Cuando puedas, una lección rápida 🙂”', 'suave'),
  ]),
  _PQ('Cuando alguien de tu liga te pasa, sientes…', [
    ('Ganas de que me exijan más', 'mano_dura'),
    ('Motivación para subir', 'positivo'),
    ('Que tengo que recuperar terreno ya', 'rezago'),
    ('Nada, voy a mi ritmo', 'suave'),
  ]),
  _PQ('¿Qué frase te mueve más?', [
    ('“No hay excusas.”', 'mano_dura'),
    ('“¡Vas increíble, sigue!”', 'positivo'),
    ('“Estás quedando atrás.”', 'rezago'),
    ('“Paso a paso se llega.”', 'suave'),
  ]),
  _PQ('¿Cómo prefieres que te empujemos a estudiar?', [
    ('Firme y directo', 'mano_dura'),
    ('Con energía y celebración', 'positivo'),
    ('Recordándome mis metas y mi avance', 'rezago'),
    ('Suave, sin presión', 'suave'),
  ]),
  _PQ('Si fallas varios días seguidos, ¿qué prefieres?', [
    ('Un llamado de atención claro', 'mano_dura'),
    ('Un mensaje que me reanime', 'positivo'),
    ('Ver cuánto me alejé de mi meta', 'rezago'),
    ('Una invitación amable a volver', 'suave'),
  ]),
  _PQ('¿Qué tan seguido quieres que te insistamos?', [
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
