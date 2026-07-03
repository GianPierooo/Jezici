# -*- coding: utf-8 -*-
"""Genera el bloque Dart `static const topics = <ConvTopic>[ ... ]` de Conversar con
model+tips por idioma (en/pt/fr/it). Títulos/escenarios en español (compartidos); los
model+tips en inglés están embebidos aquí (los existentes), y pt/fr/it se leen de
conv_pt.json / conv_fr.json / conv_it.json (arrays de 6 {model, tips[3]} en orden).
Emite Dart con comillas dobles y escape correcto (acentos van tal cual en UTF-8).
Salida: imprime el bloque para pegar en conversar_screen.dart.
"""
import json, io, os, sys

HERE = os.path.dirname(__file__)

# (title_es, emoji, scenario_es)
HEADERS = [
    ('Pedir un café', '☕', 'Estás en una cafetería. Pide un café y algo de comer, y pregunta el precio.'),
    ('Presentarte', '👋', 'Conoces a alguien nuevo. Preséntate: nombre, de dónde eres y qué haces.'),
    ('En el aeropuerto', '✈️', 'Estás en el aeropuerto. Pregunta por tu puerta y la hora del vuelo.'),
    ('Tu fin de semana', '🌤️', 'Cuenta qué hiciste el fin de semana pasado (pasado simple).'),
    ('Una entrevista breve', '💼', 'Te preguntan por qué quieres el trabajo. Responde con 2 razones.'),
    ('Pedir indicaciones', '🧭', 'Pregunta cómo llegar a la estación de tren y si está lejos.'),
]

# Inglés (los modelos existentes) — 6 en orden.
EN = [
    {"model": "Hi! Can I have a coffee and a piece of cake, please? How much is it?",
     "tips": ["Can I have…?", "How much is it?", "please / thank you"]},
    {"model": "Hi, I'm Ana. Nice to meet you! I'm from Peru and I work as a teacher.",
     "tips": ["I'm…", "Nice to meet you", "I'm from… / I work as…"]},
    {"model": "Excuse me, where is gate 12? What time does the flight to Madrid leave?",
     "tips": ["Excuse me…", "Where is…?", "What time does… leave?"]},
    {"model": "Last weekend I went to the park with my friends and we had lunch together.",
     "tips": ["Last weekend I…", "went / had / saw", "with my friends"]},
    {"model": "I'm interested in this job because I like working with people and I want to learn.",
     "tips": ["I'm interested because…", "I like…", "I want to…"]},
    {"model": "Excuse me, how do I get to the train station? Is it far from here?",
     "tips": ["How do I get to…?", "Is it far?", "turn left / right"]},
]


def dstr(s):
    """Literal Dart de comillas dobles con escape mínimo."""
    return '"' + s.replace('\\', '\\\\').replace('"', '\\"').replace('$', '\\$') + '"'


def load(code):
    p = os.path.join(HERE, f'conv_{code}.json')
    data = json.load(io.open(p, encoding='utf-8'))
    assert isinstance(data, list) and len(data) == 6, f'{p}: se esperaban 6 objetos'
    for d in data:
        assert 'model' in d and isinstance(d.get('tips'), list) and len(d['tips']) == 3, f'{p}: formato'
    return data


def model_dart(m):
    tips = ', '.join(dstr(t) for t in m['tips'])
    return f"ConvModel({dstr(m['model'])}, [{tips}])"


def main():
    langs = {'en': EN, 'pt': load('pt'), 'fr': load('fr'), 'it': load('it')}
    L = ['  static const topics = <ConvTopic>[']
    for i, (title, emoji, scen) in enumerate(HEADERS):
        L.append(f'    ConvTopic({dstr(title)}, {dstr(emoji)}, {dstr(scen)}, {{')
        for code in ('en', 'pt', 'fr', 'it'):
            L.append(f"      '{code}': {model_dart(langs[code][i])},")
        L.append('    }),')
    L.append('  ];')
    out = '\n'.join(L)
    dest = os.path.join(HERE, 'conversar_topics_block.dart.txt')
    io.open(dest, 'w', encoding='utf-8').write(out)
    print('escrito', dest)
    print('topics=%d  idiomas=%s' % (len(HEADERS), list(langs.keys())))


if __name__ == '__main__':
    main()
