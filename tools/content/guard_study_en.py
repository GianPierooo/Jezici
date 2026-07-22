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
TGT = _ARGS[3] if len(_ARGS) > 3 else 'en'  # clave del idioma meta en examples
OUT = os.path.join(DIR, '_clean.json')


def sin_diacriticos(s):
    """Las formas que teclea quien no tiene el teclado del idioma. Devuelve
    TODAS las plausibles: la vocal pelada (ö→o) y, para el alemán, la
    transliteración estándar (ö→oe, ß→ss), que es lo que se escribe de verdad."""
    if not s:
        return []
    d = unicodedata.normalize('NFD', s)
    pelada = unicodedata.normalize(
        'NFC', ''.join(c for c in d if unicodedata.category(c) != 'Mn'))
    pelada = (pelada.replace('œ', 'oe').replace('Œ', 'Oe')
                    .replace('æ', 'ae').replace('Æ', 'Ae')
                    .replace('ß', 'ss'))
    trans = s
    for a, b in (('ä', 'ae'), ('ö', 'oe'), ('ü', 'ue'), ('ß', 'ss'),
                 ('Ä', 'Ae'), ('Ö', 'Oe'), ('Ü', 'Ue'),
                 ('œ', 'oe'), ('æ', 'ae')):
        trans = trans.replace(a, b)
    trans = unicodedata.normalize(
        'NFC', ''.join(c for c in unicodedata.normalize('NFD', trans)
                       if unicodedata.category(c) != 'Mn'))
    return [x for x in dict.fromkeys([pelada, trans]) if x != s]


def norm(s):
    """Réplica FIEL de jz_normalize (verificado contra la BD): minúsculas,
    apóstrofos fuera, puntuación fuera. **NO toca los acentos** — por eso
    «mangé» y «mange» son DISTINTAS para el corrector."""
    v = (s or '').lower()
    for ch in '’‘´`':
        v = v.replace(ch, "'")
    for ch in '“”"':
        v = v.replace(ch, '')
    v = re.sub(r"'+", "'", v)
    v = re.sub(r'[.!?¿¡,;:]', '', v)
    v = v.replace("'", '')
    return re.sub(r'\s+', ' ', v).strip()


def indel1(a, b):
    """¿'b' se obtiene de 'a' quitando o añadiendo UNA letra?
    Es lo ÚNICO que el grader perdona en una respuesta de una sola palabra
    (verificado: «aux» acepta «au», pero «du» NO acepta «de» — sustituir no se
    perdona). Por eso solo cuenta inserción/borrado."""
    if a == b or abs(len(a) - len(b)) != 1:
        return False
    lo, hi = (a, b) if len(a) < len(b) else (b, a)
    i = 0
    while i < len(lo) and lo[i] == hi[i]:
        i += 1
    return lo[i:] == hi[i + 1:]


# Signos que se pegan a un token citado («piove») y no forman parte de la palabra.
CITAS = '«»"\'()[]¿?¡!.,;:'


def unit_vocab(d):
    """Formas del IDIOMA META que el tema enseña. Solo de sitios donde el texto
    es del idioma meta: los ejemplos, las opciones de las preguntas y lo que la
    teoría cita entre comillas (la prosa explicativa va en español y no cuenta)."""
    src = []
    for ex in d.get('examples') or []:
        src.append(ex.get(TGT, ''))
    for q in d.get('quiz') or []:
        src += (q.get('options') or [])
        src.append(q.get('text') or '')
    citado = []
    for sec in d.get('sections') or []:
        citado += [sec.get('body', '')] + (sec.get('bullets') or [])
    for pf in d.get('pitfalls') or []:
        citado += [pf.get('title', ''), pf.get('body', '')]
    # El ENUNCIADO del propio ítem también enseña formas del idioma meta
    # («arbeiten = trabajar»): si la respuesta está a una edición de eso, el
    # alumno copia lo que ve y acierta sin saber conjugar.
    for q in d.get('quiz') or []:
        citado.append(q.get('prompt', ''))
    for t in citado:
        src += re.findall(r'«([^»]{1,60})»', t or '')
        src += re.findall(r'"([^"]{1,60})"', t or '')
        src += re.findall(r'\(([^)]{1,40})\)', t or '')
    out = set()
    for t in src:
        # los signos de cita pegados al token («piove») no forman parte de la
        # palabra que el tema enseña: se despegan antes de comparar
        for w in norm(t).split():
            w = w.strip(CITAS).strip()
            if w:
                out.add(w)
    return out


def words(s):
    return len((s or '').split())


def main():
    problems, warns, clean = [], [], []
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
            if not e.get(TGT) or not e.get('es'):
                errs.append('ejemplo %d incompleto' % i)
            elif norm(e[TGT]) == norm(e['es']):
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
                # REGLA DE ORO (verificada contra el grader): el corrector NO
                # ignora los acentos → quien teclea sin ellos acertaría y sería
                # castigado. Se añade la forma sin acento de cada aceptable.
                for a in list(acc):
                    for sa in sin_diacriticos(a):
                        if not any(norm(sa) == norm(x) for x in acc):
                            acc.append(sa)
                # El grader PERDONA un typo de distancia 1 (verificado: «aux»
                # acepta «au», «parties» acepta «partis»). Si el propio tema
                # enseña una forma a 1 edición de la respuesta, el cloze NO
                # puede discriminar: ese contraste va en multiple_choice.
                na = norm(ans)
                if ' ' not in na:
                    vecinos = sorted(w for w in unit_vocab(d)
                                     if indel1(na, w) and not any(norm(a) == w for a in acc))
                    if vecinos:
                        warns.append(
                            'U%d quiz %d: poco discriminante — el tema enseña %s, que el '
                            'grader perdona como typo de "%s" (falso ACIERTO, nunca un falso fallo)'
                            % (n, i, '/'.join(vecinos[:3]), ans))
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
    if warns:
        print('AVISOS (%d) — el ítem se queda corto, pero NUNCA castiga:' % len(warns))
        for w in warns:
            print('  ~ ' + w)
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
