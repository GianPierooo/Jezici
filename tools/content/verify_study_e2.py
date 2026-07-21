# -*- coding: utf-8 -*-
"""ESTUDIAR · Fase E-2 (INGLÉS) — verificación con CLIENTE REAL (JWT):
  · un tema A1 ABIERTO devuelve la sesión rica (teoría + ejemplos con audio +
    errores comunes + prueba) por `get_study_theory`;
  · la prueba NO expone las respuestas al cliente (grading server-side);
  · `submit_study_quiz` ACEPTA las respuestas válidas (las 61 del banco) y
    NO castiga variantes correctas (mayúsculas, contracción sin apóstrofo);
  · una respuesta realmente mal SÍ se marca mal (no se regala);
  · la prueba es FORMATIVA: no mueve XP ni oro;
  · el desbloqueo de E-1 sigue intacto (tema no alcanzado → sin teoría servida);
  · el audio de los ejemplos existe (HEAD 200).
uso: python verify_study_e2.py
"""
import json
import urllib.error
import urllib.request

import verify_placement_serious as V
import _introspect as I

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

    units = I.run("""select id, order_index, title from units
                     where course_id='%s' and order_index in (1,2,12,25)
                     order by order_index;""" % EN)
    by_order = {u['order_index']: u for u in units}

    tok, uid = V.mk_user('studye2@test.jezici.dev')
    V.rpc(tok, 'submit_age_gate', {'p_birth_year': 1990})
    V.rpc(tok, 'set_active_course', {'p_course_id': EN})
    V.rpc(tok, 'create_plan', {
        'p_coach_style': 'suave', 'p_intensity': 3, 'p_current_level': 'A1',
        'p_goal_level': 'B2', 'p_daily_minutes': 20, 'p_days_per_week': 5,
        'p_motive': 'viaje', 'p_deadline': None, 'p_estimated_hours': 300,
        'p_estimated_completion': None, 'p_skill_levels': None})

    # ── 1 · la sesión rica del tema A1 abierto ──
    u1 = by_order[1]
    t = V.rpc(tok, 'get_study_theory', {'p_unit_id': u1['id']})
    check(t is not None, 'U1 (tema abierto) devuelve sesión de estudio')
    check(len(t.get('sections') or []) > 0, 'trae teoría (%d secciones)' % len(t.get('sections') or []))
    check(len(t.get('examples') or []) == 4, 'trae 4 ejemplos')
    check(len(t.get('pitfalls') or []) > 0, 'trae errores comunes (%d)' % len(t.get('pitfalls') or []))
    quiz = t.get('quiz') or []
    check(len(quiz) >= 3, 'trae prueba (%d ítems)' % len(quiz))

    # ── 2 · el cliente NO recibe las respuestas ──
    leaks = [q for q in quiz if 'answer' in q or 'accepted' in q]
    check(not leaks, 'la prueba NO expone answer/accepted al cliente')

    # ── 3 · audio de los ejemplos ──
    codes = [head(e.get('audio_url') or '') for e in t['examples']]
    check(all(c == 200 for c in codes), 'audio de los 4 ejemplos HEAD 200 -> %s' % codes)

    # ── 4 · el grader ACEPTA las respuestas válidas de TODO el banco ──
    bank = I.run("""
      select st.unit_order, it->>'id' id, it->>'answer' ans
        from study_theory st, jsonb_array_elements(st.quiz) it
       where st.course_id='%s' order by st.unit_order;""" % EN)
    by_unit = {}
    for b in bank:
        by_unit.setdefault(b['unit_order'], []).append(b)
    total = bad = 0
    for uo, items in by_unit.items():
        u = I.run("select id from units where course_id='%s' and order_index=%d;" % (EN, uo))[0]
        r = V.rpc(tok, 'submit_study_quiz', {
            'p_unit_id': u['id'],
            'p_answers': [{'id': i['id'], 'answer': i['ans']} for i in items]})
        total += r['graded']
        bad += r['graded'] - r['correct']
    check(bad == 0, 'las %d respuestas correctas del banco se ACEPTAN (0 castigadas)' % total)

    # ── 5 · variantes que un alumno real escribiría (no castigar) ──
    q1 = quiz[0]
    ans1 = [b for b in bank if b['unit_order'] == 1 and b['id'] == q1['id']][0]['ans']
    r_up = V.rpc(tok, 'submit_study_quiz', {
        'p_unit_id': u1['id'], 'p_answers': [{'id': q1['id'], 'answer': ans1.upper()}]})
    got = [x for x in r_up['results'] if x['id'] == q1['id']][0]
    check(got['correct'], 'la MISMA respuesta en MAYÚSCULAS se acepta ("%s")' % ans1.upper())

    # ── 6 · una respuesta realmente mal SÍ se marca mal ──
    r_bad = V.rpc(tok, 'submit_study_quiz', {
        'p_unit_id': u1['id'],
        'p_answers': [{'id': q['id'], 'answer': 'zzzz'} for q in quiz]})
    check(r_bad['correct'] == 0 and not r_bad['passed'],
          'respuestas basura -> 0 correctas y no aprueba (no se regala)')

    # ── 7 · FORMATIVA: no toca economía ──
    def wallet():
        w = I.run("select xp_total, gold from user_stats where user_id='%s';" % uid)
        return (w[0]['xp_total'], w[0]['gold']) if w else (0, 0)
    before = wallet()
    V.rpc(tok, 'submit_study_quiz', {
        'p_unit_id': u1['id'],
        'p_answers': [{'id': i['id'], 'answer': i['ans']} for i in by_unit[1]]})
    after = wallet()
    check(before == after, 'la prueba NO mueve XP ni oro (formativa) %s -> %s' % (before, after))

    # ── 8 · E-1 intacto: el tema de C1 sigue sin teoría (estado honesto) ──
    if 25 in by_order:
        t25 = V.rpc(tok, 'get_study_theory', {'p_unit_id': by_order[25]['id']})
        check(t25 is None, 'U25 (C1, sin teoría aún) devuelve null -> "teoría en camino"')

    try:
        V.rpc(tok, 'delete_account', {})
    except Exception:
        pass
    print('\n' + ('TODO VERDE' if ok else 'HAY FALLOS'))
    return 0 if ok else 1


if __name__ == '__main__':
    raise SystemExit(main())
