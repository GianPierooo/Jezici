# -*- coding: utf-8 -*-
"""ESTUDIAR · E-2 (NEERLANDÉS A1–B2 COMPLETO) — verificación con CLIENTE REAL (JWT):
  · un tema de cada nivel (U1 A1, U7 A2, U13 B1, U22 B2) devuelve la sesión rica
    (teoría + 4 ejemplos con audio + errores comunes + prueba) por `get_study_theory`;
  · la prueba NO expone answer/accepted (grading server-side);
  · `submit_study_quiz` ACEPTA las 120 respuestas válidas del banco (0 castigadas)
    + variante en MAYÚSCULAS + escribir SIN ACENTOS; basura → mal (no se regala);
  · sigue FORMATIVA: no mueve XP ni oro;
  · AISLAMIENTO QUÍNTUPLE: en, pt, fr, de e it siguen sirviendo cada uno SU contenido;
  · techo honesto: U25 (C1, sin tips) sigue null → "teoría en camino".
uso: python verify_study_e2_nl.py
"""
import unicodedata
import urllib.error
import urllib.request

import verify_placement_serious as V
import _introspect as I

NL = '20000000-0000-0000-0000-000000000006'
IT = '20000000-0000-0000-0000-000000000004'
DE = '20000000-0000-0000-0000-000000000005'
FR = '20000000-0000-0000-0000-000000000003'
PT = '20000000-0000-0000-0000-000000000002'
EN = '20000000-0000-0000-0000-000000000001'


def head(url):
    r = urllib.request.Request(url, method='HEAD')
    try:
        with urllib.request.urlopen(r, timeout=30) as x:
            return x.status
    except urllib.error.HTTPError as e:
        return e.code
    except Exception:
        return 0


def main():
    ok = True

    def check(cond, label):
        nonlocal ok
        ok = ok and cond
        print(('  OK ' if cond else '  XX ') + label)

    units = I.run("""select id, order_index from units
                     where course_id='%s' and order_index in (1,7,13,22,25)
                     order by order_index;""" % NL)
    by_order = {u['order_index']: u for u in units}

    tok, uid = V.mk_user('studye2nl@test.jezici.dev')
    V.rpc(tok, 'submit_age_gate', {'p_birth_year': 1990})
    V.rpc(tok, 'set_active_course', {'p_course_id': NL})
    V.rpc(tok, 'create_plan', {
        'p_coach_style': 'suave', 'p_intensity': 3, 'p_current_level': 'A1',
        'p_goal_level': 'B2', 'p_daily_minutes': 20, 'p_days_per_week': 5,
        'p_motive': 'viaje', 'p_deadline': None, 'p_estimated_hours': 300,
        'p_estimated_completion': None, 'p_skill_levels': None})

    # ── 1 · la sesión rica, un tema por nivel ──
    t = V.rpc(tok, 'get_study_theory', {'p_unit_id': by_order[1]['id']})
    check(t is not None and t.get('cefr_level') == 'A1', 'nl U1 (A1) devuelve sesión de estudio')
    check(len(t.get('sections') or []) > 0, 'trae teoría (%d secciones)' % len(t.get('sections') or []))
    check(len(t.get('examples') or []) == 4, 'trae 4 ejemplos')
    check(len(t.get('pitfalls') or []) > 0, 'trae errores comunes (%d)' % len(t.get('pitfalls') or []))
    quiz = t.get('quiz') or []
    check(len(quiz) >= 3, 'trae prueba (%d ítems)' % len(quiz))
    leaks = [q for q in quiz if 'answer' in q or 'accepted' in q]
    check(not leaks, 'la prueba NO expone answer/accepted al cliente')
    check(all(e.get('text') for e in t['examples']),
          'los ejemplos traen la clave CANÓNICA text (neerlandés)')

    # ── 2 · audio de los 4 niveles muestreado ──
    codes = [head(e.get('audio_url') or '') for e in t['examples']]
    check(all(c == 200 for c in codes), 'audio de U1 (A1) HEAD 200 -> %s' % codes)
    for uo, lvl in ((7, 'A2'), (13, 'B1'), (22, 'B2')):
        tx = V.rpc(tok, 'get_study_theory', {'p_unit_id': by_order[uo]['id']})
        cx = [head(e.get('audio_url') or '') for e in (tx.get('examples') or [])]
        check(tx.get('cefr_level') == lvl and all(c == 200 for c in cx),
              'nl U%d (%s) sirve sesión y audio HEAD 200 -> %s' % (uo, lvl, cx))

    # ── 3 · las 120 respuestas del banco A1–B2 se ACEPTAN ──
    bank = I.run("""
      select st.unit_order, it->>'id' id, it->>'answer' ans, it->>'type' ty
        from study_theory st, jsonb_array_elements(st.quiz) it
       where st.course_id='%s' and st.unit_order between 1 and 24
       order by st.unit_order;""" % NL)
    by_unit = {}
    for b in bank:
        by_unit.setdefault(b['unit_order'], []).append(b)
    ids = {u['order_index']: u['id'] for u in I.run(
        "select id, order_index from units where course_id='%s' "
        "and order_index between 1 and 24;" % NL)}
    total = bad = 0
    for uo, items in by_unit.items():
        r = V.rpc(tok, 'submit_study_quiz', {
            'p_unit_id': ids[uo],
            'p_answers': [{'id': i['id'], 'answer': i['ans']} for i in items]})
        total += r['graded']
        bad += r['graded'] - r['correct']
    check(bad == 0, 'las %d respuestas correctas de neerlandés A1-B2 se ACEPTAN (0 castigadas)' % total)

    # ── 4 · MAYÚSCULAS aceptadas · sin acentos no castiga · basura rechazada ──
    q1 = quiz[0]
    ans1 = [b for b in bank if b['unit_order'] == 1 and b['id'] == q1['id']][0]['ans']
    r_up = V.rpc(tok, 'submit_study_quiz', {
        'p_unit_id': by_order[1]['id'],
        'p_answers': [{'id': q1['id'], 'answer': ans1.upper()}]})
    got = [x for x in r_up['results'] if x['id'] == q1['id']][0]
    check(got['correct'], 'la MISMA respuesta en MAYÚSCULAS se acepta ("%s")' % ans1.upper())

    # SOLO cloze: en opción múltiple el alumno PULSA la opción, no la teclea,
    # así que ahí el acento nunca puede castigarle.
    acc_items = [b for b in bank
                 if b['ty'] == 'cloze'
                 and any(unicodedata.category(c) == 'Mn'
                         for c in unicodedata.normalize('NFD', b['ans']))]
    if acc_items:
        uo = acc_items[0]['unit_order']
        envio = []
        for b in acc_items:
            if b['unit_order'] != uo:
                continue
            d = unicodedata.normalize('NFD', b['ans'])
            envio.append((b, unicodedata.normalize(
                'NFC', ''.join(c for c in d if unicodedata.category(c) != 'Mn'))))
        mios_ids = {b['id'] for b, _ in envio}
        rr = V.rpc(tok, 'submit_study_quiz', {
            'p_unit_id': ids[uo],
            'p_answers': [{'id': b['id'], 'answer': p} for b, p in envio]})
        mios = [x for x in rr['results'] if x['id'] in mios_ids]
        check(bool(mios) and all(x['correct'] for x in mios),
              'escribir SIN ACENTOS no castiga (%s)'
              % ', '.join('%s->%s' % (b['ans'], p) for b, p in envio[:3]))

    r_bad = V.rpc(tok, 'submit_study_quiz', {
        'p_unit_id': by_order[1]['id'],
        'p_answers': [{'id': q['id'], 'answer': 'zzzz'} for q in quiz]})
    check(r_bad['correct'] == 0 and not r_bad['passed'],
          'respuestas basura -> 0 correctas y no aprueba (no se regala)')

    # ── 5 · FORMATIVA: no toca economía ──
    def wallet():
        w = I.run("select xp_total, gold from user_stats where user_id='%s';" % uid)
        return (w[0]['xp_total'], w[0]['gold']) if w else (0, 0)
    before = wallet()
    V.rpc(tok, 'submit_study_quiz', {
        'p_unit_id': by_order[1]['id'],
        'p_answers': [{'id': i['id'], 'answer': i['ans']} for i in by_unit[1]]})
    check(before == wallet(), 'la prueba NO mueve XP ni oro (formativa) %s' % (before,))

    # ── 6 · AISLAMIENTO cuádruple + techo honesto ──
    def frase(ses):   # 'text' es la clave canónica; 'en' la histórica del inglés
        e = (ses or {}).get('examples') or [{}]
        return e[0].get('text') or e[0].get('en')
    mio = frase(t)
    for cid, nom in ((EN, 'INGLÉS'), (PT, 'PORTUGUÉS'), (FR, 'FRANCÉS'),
                     (DE, 'ALEMÁN'), (IT, 'ITALIANO')):
        u1 = I.run("select id from units where course_id='%s' and order_index=1;" % cid)[0]
        to = V.rpc(tok, 'get_study_theory', {'p_unit_id': u1['id']})
        suyo = frase(to)
        check(to is not None and suyo and suyo != mio,
              'AISLAMIENTO: la U1 del %s sirve SU contenido (%r)' % (nom, (suyo or '')[:34]))
    t25 = V.rpc(tok, 'get_study_theory', {'p_unit_id': by_order[25]['id']})
    check(t25 is None, 'nl U25 (C1, sin tips) sigue null -> "teoría en camino"')

    try:
        V.rpc(tok, 'delete_account', {})
    except Exception:
        pass
    print('\n' + ('TODO VERDE' if ok else 'HAY FALLOS'))
    return 0 if ok else 1


if __name__ == '__main__':
    raise SystemExit(main())
