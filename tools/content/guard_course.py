# -*- coding: utf-8 -*-
"""GUARDA DETERMINISTA para las unidades de un curso NUEVO (formato gen_course.py).

Hace dos cosas, y por eso es el paso obligatorio entre "los autores entregan" y
"se genera la migración":

  1. NORMALIZA al formato que espera `gen_course.py` (translation → `source`,
     word_bank/reorder → `tiles`), para que el brief de los autores pueda ser
     legible y el generador no cambie.
  2. VALIDA el contrato del corrector y el molde de contenido. Todo lo que
     bloquea es un fallo REAL; lo que solo empeora la medición es un AVISO.

Contrato de `jz_grade` que se modela aquí (verificado contra la BD, no supuesto):
  · minúsculas + **una guarda añade la forma SIN DIACRÍTICOS** → cualquier
    contraste que se juegue SOLO en ă/â/î/ș/ț (o en tildes) es INEVALUABLE;
  · perdona **añadir o quitar UNA letra** en respuesta de una palabra
    (sustituir sí discrimina), y **una sustitución** si hay varias palabras.
  → REGLA DE ORO: si el error típico está a un diacrítico o a una letra de la
    respuesta, el ítem tiene que ser de PULSAR (multiple_choice/listening).

uso: python guard_course.py <code> <a1|a2|b1|b2|c1>
"""
import glob
import io
import json
import os
import sys
import unicodedata

HERE = os.path.dirname(os.path.abspath(__file__))

# El molde de los 6 cursos vivos: 20 ítems por unidad con este reparto exacto.
MOLDE = {('reading', 'multiple_choice'): 4, ('reading', 'match'): 2,
         ('listening', 'listening'): 5,
         ('writing', 'cloze'): 2, ('writing', 'translation'): 2,
         ('writing', 'word_bank'): 1, ('writing', 'reorder'): 1,
         ('speaking', 'speaking_read_aloud'): 3}


def norm(s):
    """Modela jz_normalize: minúsculas, sin puntuación, espacios colapsados."""
    s = (s or '').lower().replace('’', "'").replace("'", '')
    for c in '.!?¿¡,;:«»"()':
        s = s.replace(c, ' ')
    return ' '.join(s.split())


def sinacc(s):
    """La forma sin diacríticos que la guarda de accepted añade sola."""
    d = unicodedata.normalize('NFD', s)
    return unicodedata.normalize('NFC', ''.join(c for c in d
                                                if unicodedata.category(c) != 'Mn'))


def dist1(a, b):
    """¿Están a UNA edición? Distingue indel (siempre perdonado) de sustitución
    (perdonada solo en respuestas multi-palabra)."""
    if a == b:
        return None
    if len(a) == len(b):
        dif = sum(1 for x, y in zip(a, b) if x != y)
        return 'sust' if dif == 1 else None
    if abs(len(a) - len(b)) != 1:
        return None
    corto, largo = (a, b) if len(a) < len(b) else (b, a)
    for i in range(len(largo)):
        if largo[:i] + largo[i + 1:] == corto:
            return 'indel'
    return None


def main():
    code = sys.argv[1] if len(sys.argv) > 1 else 'ro'
    level = (sys.argv[2] if len(sys.argv) > 2 else 'a1').lower()
    paths = sorted(glob.glob(os.path.join(HERE, '%s_%s_u*.json' % (code, level))),
                   key=lambda p: int(''.join(ch for ch in os.path.basename(p) if ch.isdigit())[-1:]))
    assert paths, 'no hay %s_%s_u*.json' % (code, level)

    problemas, avisos, arreglos = [], [], []
    for p in paths:
        d = json.load(io.open(p, encoding='utf-8'))
        uo = d['unit']['order']
        items = d['items']
        tocado = False

        # ── 1 · NORMALIZAR al formato del generador ──
        for it in items:
            t = it['type']
            if t == 'translation' and 'source' not in it:
                it['source'] = it.get('text') or it.get('prompt_source') or ''
                tocado = True
                arreglos.append('U%d translation: text -> source' % uo)
            # (a) NADIE tiene teclado del idioma meta: cada respuesta TECLEADA
            # acepta tambien su forma SIN DIACRITICOS. Solo cloze/translation:
            # en word_bank/reorder el usuario PULSA fichas que ya los traen (y
            # ademas jz_grade ignora `accepted` en esos dos tipos — verificado).
            if t in ('cloze', 'translation'):
                acc = list(it.get('accepted') or [it['value']])
                nuevas = [sinacc(a) for a in acc if sinacc(a) != a and sinacc(a) not in acc]
                if nuevas:
                    it['accepted'] = acc + sorted(set(nuevas))
                    tocado = True
                    arreglos.append('U%d %s: +forma sin diacríticos en accepted' % (uo, t))
            if t in ('word_bank', 'reorder') and 'tiles' not in it:
                # tiles = las fichas que se muestran (secuencia + distractores),
                # en orden ESTABLE pero distinto del correcto (si no, se regala).
                seq = list(it['sequence'])
                extra = list(it.get('distractors') or [])
                it['tiles'] = sorted(seq + extra, key=lambda w: (norm(w), w))
                tocado = True
                arreglos.append('U%d %s: sequence(+distractors) -> tiles' % (uo, t))

        # ── 2 · VALIDAR el molde ──
        reparto = {}
        for it in items:
            reparto[(it['skill'], it['type'])] = reparto.get((it['skill'], it['type']), 0) + 1
        if reparto != MOLDE:
            problemas.append('U%d: reparto %s != molde' % (uo, sorted(reparto.items())))
        if len(items) != 20:
            problemas.append('U%d: %d ítems (deben ser 20)' % (uo, len(items)))
        if len(d.get('lessons') or []) != 4:
            problemas.append('U%d: %d lecciones (deben ser 4)' % (uo, len(d.get('lessons') or [])))

        # ── 3 · VALIDAR el contrato del corrector ──
        for k, it in enumerate(items):
            t = it['type']
            ops = it.get('options') or []
            if t in ('multiple_choice', 'listening'):
                if it['value'] not in ops:
                    problemas.append('U%d ítem %d: value fuera de options' % (uo, k))
                # ningún distractor puede colisionar con el correcto al normalizar
                # (minúsculas Y sin diacríticos: la guarda añade esa forma)
                vistos = {}
                for o in ops:
                    key = norm(sinacc(o))
                    if key in vistos:
                        problemas.append('U%d ítem %d: COLISIÓN %r ≡ %r al normalizar'
                                         % (uo, k, o, vistos[key]))
                    vistos[key] = o
            if t in ('cloze', 'translation'):
                v = it['value']
                acc = [v] + list(it.get('accepted') or [])
                # la respuesta no puede jugarse solo en un diacrítico
                if norm(sinacc(v)) != norm(v):
                    avisos.append('U%d ítem %d: la respuesta %r lleva diacríticos → se acepta '
                                  '%r; el ítem no puede medir la ortografía'
                                  % (uo, k, v, sinacc(v)))
                # (b) el enunciado no puede contener la respuesta
                enun = norm(sinacc(it.get('prompt', '') + ' ' + (it.get('source') or '')))
                if len(norm(v)) > 2 and (' %s ' % norm(sinacc(v))) in (' %s ' % enun):
                    problemas.append('U%d ítem %d: el ENUNCIADO contiene la respuesta %r'
                                     % (uo, k, v))
                # (c) accepted debe contener el propio value
                if it.get('accepted') and v not in it['accepted']:
                    problemas.append('U%d ítem %d: accepted no incluye el value %r' % (uo, k, v))
                del acc
        if tocado:
            json.dump(d, io.open(p, 'w', encoding='utf-8'), ensure_ascii=False, indent=1)

    print('=== GUARDA %s %s · %d unidades ===' % (code, level.upper(), len(paths)))
    for a in sorted(set(arreglos)):
        print('  ~ normalizado:', a)
    if avisos:
        print('AVISOS (%d) — el ítem se queda corto, pero NUNCA castiga:' % len(avisos))
        for a in avisos:
            print('  ~', a)
    if problemas:
        print('PROBLEMAS (%d):' % len(problemas))
        for x in problemas:
            print('  -', x)
        return 1
    print('unidades OK: %d/%d · ítems %d' % (len(paths), len(paths), 20 * len(paths)))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
