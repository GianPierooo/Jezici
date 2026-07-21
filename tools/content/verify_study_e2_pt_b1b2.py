# -*- coding: utf-8 -*-
"""ESTUDIAR · E-2 (PORTUGUÉS B1+B2) — verificación con CLIENTE REAL (JWT):
  · un tema B1 (U13) devuelve la sesión rica (teoría + 4 ejemplos con audio +
    errores comunes + prueba) por `get_study_theory`;
  · la prueba NO expone answer/accepted (grading server-side);
  · `submit_study_quiz` ACEPTA las 60 respuestas válidas del banco B1/B2
    (0 castigadas) + variante en MAYÚSCULAS; basura → mal (no se regala);
  · sigue FORMATIVA: no mueve XP ni oro;
  · REGRESIÓN tanda 1: U1 (A1) sigue sirviendo su sesión; U25 (C1) sigue null.
uso: python verify_study_e2_b1b2.py
"""
import urllib.error
import urllib.request

import verify_placement_serious as V
import _introspect as I

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
                     where course_id='%s' and order_index in (1,13,22,25)
                     order by order_index;""" % PT)
    by_order = {u['order_index']: u for u in units}

    tok, uid = V.mk_user('studye2ptb@test.jezici.dev')
    V.rpc(tok, 'submit_age_gate', {'p_birth_year': 1990})
    V.rpc(tok, 'set_active_course', {'p_course_id': PT})
    V.rpc(tok, 'create_plan', {
        'p_coach_style': 'suave', 'p_intensity': 3, 'p_current_level': 'B1',
        'p_goal_level': 'B2', 'p_daily_minutes': 20, 'p_days_per_week': 5,
        'p_motive': 'viaje', 'p_deadline': None, 'p_estimated_hours': 300,
        'p_estimated_completion': None, 'p_skill_levels': None})

    # ── 1 · la sesión rica del tema B1 (U13) ──
    t = V.rpc(tok, 'get_study_theory', {'p_unit_id': by_order[13]['id']})
    check(t is not None and t.get('cefr_level') == 'B1', 'pt U13 (B1) devuelve sesión de estudio')
    check(len(t.get('sections') or []) > 0, 'trae teoría (%d secciones)' % len(t.get('sections') or []))
    check(len(t.get('examples') or []) == 4, 'trae 4 ejemplos')
    check(len(t.get('pitfalls') or []) > 0, 'trae errores comunes (%d)' % len(t.get('pitfalls') or []))
    quiz = t.get('quiz') or []
    check(len(quiz) >= 3, 'trae prueba (%d ítems)' % len(quiz))
    leaks = [q for q in quiz if 'answer' in q or 'accepted' in q]
    check(not leaks, 'la prueba NO expone answer/accepted al cliente')

    # ── 2 · audio de los ejemplos B1 + B2 muestreado ──
    check(all(e.get('text') for e in t['examples']),
          'los ejemplos traen la clave CANÓNICA text (portugués)')
    codes = [head(e.get('audio_url') or '') for e in t['examples']]
    check(all(c == 200 for c in codes), 'audio pt U13 HEAD 200 -> %s' % codes)
    t22 = V.rpc(tok, 'get_study_theory', {'p_unit_id': by_order[22]['id']})
    codes22 = [head(e.get('audio_url') or '') for e in (t22.get('examples') or [])]
    check(t22.get('cefr_level') == 'B2' and all(c == 200 for c in codes22),
          'pt U22 (B2) sirve sesión y audio HEAD 200 -> %s' % codes22)

    # ── 3 · las 60 respuestas del banco B1/B2 se ACEPTAN ──
    bank = I.run("""
      select st.unit_order, it->>'id' id, it->>'answer' ans
        from study_theory st, jsonb_array_elements(st.quiz) it
       where st.course_id='%s' and st.unit_order between 13 and 24
       order by st.unit_order;""" % PT)
    by_unit = {}
    for b in bank:
        by_unit.setdefault(b['unit_order'], []).append(b)
    total = bad = 0
    for uo, items in by_unit.items():
        u = I.run("select id from units where course_id='%s' and order_index=%d;" % (PT, uo))[0]
        r = V.rpc(tok, 'submit_study_quiz', {
            'p_unit_id': u['id'],
            'p_answers': [{'id': i['id'], 'answer': i['ans']} for i in items]})
        total += r['graded']
        bad += r['graded'] - r['correct']
    check(bad == 0, 'las %d respuestas correctas de pt B1/B2 se ACEPTAN (0 castigadas)' % total)

    # ── 4 · MAYÚSCULAS aceptadas · basura rechazada ──
    q1 = quiz[0]
    ans1 = [b for b in bank if b['unit_order'] == 13 and b['id'] == q1['id']][0]['ans']
    r_up = V.rpc(tok, 'submit_study_quiz', {
        'p_unit_id': by_order[13]['id'],
        'p_answers': [{'id': q1['id'], 'answer': ans1.upper()}]})
    got = [x for x in r_up['results'] if x['id'] == q1['id']][0]
    check(got['correct'], 'la MISMA respuesta en MAYÚSCULAS se acepta ("%s")' % ans1.upper())
    r_bad = V.rpc(tok, 'submit_study_quiz', {
        'p_unit_id': by_order[13]['id'],
        'p_answers': [{'id': q['id'], 'answer': 'zzzz'} for q in quiz]})
    check(r_bad['correct'] == 0 and not r_bad['passed'],
          'respuestas basura -> 0 correctas y no aprueba (no se regala)')

    # ── 5 · FORMATIVA: no toca economía ──
    def wallet():
        w = I.run("select xp_total, gold from user_stats where user_id='%s';" % uid)
        return (w[0]['xp_total'], w[0]['gold']) if w else (0, 0)
    before = wallet()
    V.rpc(tok, 'submit_study_quiz', {
        'p_unit_id': by_order[13]['id'],
        'p_answers': [{'id': i['id'], 'answer': i['ans']} for i in by_unit[13]]})
    check(before == wallet(), 'la prueba NO mueve XP ni oro (formativa) %s' % (before,))

    # ── 6 · REGRESIÓN tanda 1 + techo honesto ──
    pt1 = V.rpc(tok, 'get_study_theory', {'p_unit_id': by_order[1]['id']})
    check(pt1 is not None and pt1.get('cefr_level') == 'A1',
          'REGRESIÓN: pt U1 (tanda A1+A2) sigue sirviendo su sesión')
    en1 = I.run("select id from units where course_id='%s' and order_index=1;" % EN)[0]
    ten = V.rpc(tok, 'get_study_theory', {'p_unit_id': en1['id']})
    check(ten is not None and ten.get('title') != t.get('title'),
          'AISLAMIENTO: la U1 del INGLÉS sigue sirviendo SU sesión (%r)' % (ten or {}).get('title'))
    t25 = V.rpc(tok, 'get_study_theory', {'p_unit_id': by_order[25]['id']})
    check(t25 is None, 'pt U25 (C1, sin tips) sigue null -> "teoría en camino"')

    try:
        V.rpc(tok, 'delete_account', {})
    except Exception:
        pass
    print('\n' + ('TODO VERDE' if ok else 'HAY FALLOS'))
    return 0 if ok else 1


if __name__ == '__main__':
    raise SystemExit(main())
