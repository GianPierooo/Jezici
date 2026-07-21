# -*- coding: utf-8 -*-
"""GUARDAS DETERMINISTAS de la teoría de estudio (E-2, inglés).
Nada entra a la BD sin pasar por aquí. Filosofía de la casa: si un ítem no es
verificablemente correcto, se EXCLUYE (no se "arregla" a ojo).

Comprueba, por tema:
  · esquema completo (summary/sections/examples/pitfalls/quiz)
  · NO ABRUMAR: <=3 secciones, body <=55 palabras, bullets <=14 palabras
  · examples: 4, con en+es no vacíos y distintos
  · quiz: 4-5 ítems, solo multiple_choice|cloze
      - MC: 3 opciones, answer entre ellas, y NINGÚN distractor colisiona con el
        correcto bajo jz_normalize (minúsculas/acentos/puntuación) → nunca se
        puede marcar mal una opción que "es" la correcta escrita distinto
      - cloze: hueco ___ presente, answer no vacío, `accepted` SIEMPRE incluye
        la propia answer (se añade si falta) → el grader tolerante (mig 177) la
        acepta. Regla de oro: ante la duda, aceptar.
uso: python guard_study_en.py
"""
import json
import os
import re
import sys
import unicodedata

# Parametrizable: python guard_study_en.py [dir] [desde] [hasta]
_ARGS = sys.argv[1:]
DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                   _ARGS[0] if _ARGS else '_study_en')
FROM = int(_ARGS[1]) if len(_ARGS) > 1 else 1
TO = int(_ARGS[2]) if len(_ARGS) > 2 else 12
OUT = os.path.join(DIR, '_clean.json')


def norm(s):
    """Réplica de jz_normalize: minúsculas, sin acentos, sin puntuación."""
    s = unicodedata.normalize('NFD', (s or '').lower())
    s = ''.join(c for c in s if unicodedata.category(c) != 'Mn')
    s = s.replace('’', "'").replace('‘', "'").replace("'", '')
    s = re.sub(r'[^a-z0-9 ]', ' ', s)
    return re.sub(r'\s+', ' ', s).strip()


def words(s):
    return len((s or '').split())


def main():
    problems, clean = [], []
    for n in range(FROM, TO + 1):
        fn = os.path.join(DIR, 'unit_%d.json' % n)
        if not os.path.exists(fn):
            problems.append('U%d: FALTA el archivo' % n)
            continue
        try:
            d = json.load(open(fn, encoding='utf-8'))
        except Exception as e:
            problems.append('U%d: JSON inválido (%s)' % (n, e))
            continue

        errs = []
        for k in ('unit_order', 'cefr_level', 'title', 'summary', 'sections', 'examples', 'quiz'):
            if not d.get(k):
                errs.append('falta %s' % k)
        if errs:
            problems.append('U%d: %s' % (n, '; '.join(errs)))
            continue
        if d['unit_order'] != n:
            errs.append('unit_order %s != %d' % (d['unit_order'], n))

        # No abrumar
        secs = d['sections']
        if len(secs) > 3:
            errs.append('%d secciones (>3)' % len(secs))
        for i, s in enumerate(secs):
            if not s.get('heading') or not s.get('body'):
                errs.append('sección %d incompleta' % i)
                continue
            if words(s['body']) > 55:
                errs.append('sección %d: body %d palabras (>55)' % (i, words(s['body'])))
            for b in (s.get('bullets') or []):
                if words(b) > 14:
                    errs.append('sección %d: bullet %d palabras (>14)' % (i, words(b)))

        # Ejemplos
        exs = d['examples']
        if len(exs) != 4:
            errs.append('%d ejemplos (se esperaban 4)' % len(exs))
        for i, e in enumerate(exs):
            if not e.get('en') or not e.get('es'):
                errs.append('ejemplo %d incompleto' % i)
            elif norm(e['en']) == norm(e['es']):
                errs.append('ejemplo %d: en == es' % i)

        # Quiz
        qs = d['quiz']
        if not (3 <= len(qs) <= 6):
            errs.append('%d ítems de quiz (se esperaban 3-6)' % len(qs))
        for i, q in enumerate(qs):
            t = q.get('type')
            if t not in ('multiple_choice', 'cloze'):
                errs.append('quiz %d: tipo %r no permitido' % (i, t))
                continue
            if not q.get('prompt'):
                errs.append('quiz %d: sin prompt' % i)
            ans = (q.get('answer') or '').strip()
            if not ans:
                errs.append('quiz %d: sin answer' % i)
                continue
            if t == 'multiple_choice':
                opts = q.get('options') or []
                if len(opts) != 3:
                    errs.append('quiz %d: %d opciones (se esperaban 3)' % (i, len(opts)))
                if ans not in opts:
                    errs.append('quiz %d: answer no está entre las opciones' % i)
                ns = [norm(o) for o in opts]
                if len(set(ns)) != len(ns):
                    errs.append('quiz %d: COLISIÓN entre opciones bajo normalize' % i)
            else:
                if '___' not in (q.get('text') or ''):
                    errs.append('quiz %d: cloze sin hueco ___' % i)
                acc = [a for a in (q.get('accepted') or []) if (a or '').strip()]
                if not any(norm(a) == norm(ans) for a in acc):
                    acc.append(ans)  # la propia respuesta SIEMPRE se acepta
                # dedup preservando orden
                seen, ded = set(), []
                for a in acc:
                    if norm(a) not in seen:
                        seen.add(norm(a))
                        ded.append(a)
                q['accepted'] = ded

        if errs:
            problems.append('U%d (%s): %s' % (n, d.get('title'), '; '.join(errs)))
        else:
            clean.append(d)

    print('=== GUARDAS ===')
    print('temas OK: %d/%d' % (len(clean), TO - FROM + 1))
    if problems:
        print('PROBLEMAS:')
        for p in problems:
            print('  - ' + p)
    json.dump(clean, open(OUT, 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
    print('escrito %s (%d temas)' % (OUT, len(clean)))
    tot_q = sum(len(d['quiz']) for d in clean)
    tot_e = sum(len(d['examples']) for d in clean)
    print('ejemplos: %d · ítems de quiz: %d' % (tot_e, tot_q))
    return 0 if not problems else 1


if __name__ == '__main__':
    sys.exit(main())
