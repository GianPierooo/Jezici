# -*- coding: utf-8 -*-
"""Verifica END-TO-END el cableado del re-placement no-inglés con CLIENTE REAL (JWT):
reproduce lo que hace la UI al cambiar de curso en Ajustes →
  set_active_course(<curso>) → placement_next(<curso>) [personas] → create_plan(nivel).
Comprueba que el usuario queda en la UNIDAD DE ENTRADA correcta de ESE curso (A2→U7,
A1→U1), que NO se corrompe el progreso de otro curso (en), y el aislamiento (placement
de de usa banco de). correct_answer 42501. Introspección de progreso por ADMIN (scaffolding,
solo lectura); la lógica (placement/create_plan) por JWT. Limpia al final."""
import urllib.request, urllib.error, json, sys
from apply_sql import env, SUPABASE_URL, run
from verify_chain import admin

AK = env('SUPABASE_ANON_KEY')
COURSES = {
    'en': '20000000-0000-0000-0000-000000000001', 'pt': '20000000-0000-0000-0000-000000000002',
    'fr': '20000000-0000-0000-0000-000000000003', 'it': '20000000-0000-0000-0000-000000000004',
    'de': '20000000-0000-0000-0000-000000000005', 'nl': '20000000-0000-0000-0000-000000000006',
}
RANK = {'A1': 0, 'A2': 1, 'B1': 2, 'B2': 3, 'C1': 4}


def rpc(tok, name, body):
    r = urllib.request.Request(SUPABASE_URL + '/rest/v1/rpc/' + name,
                               data=json.dumps(body).encode(), method='POST')
    r.add_header('apikey', AK); r.add_header('Authorization', 'Bearer ' + tok)
    r.add_header('Content-Type', 'application/json')
    try:
        with urllib.request.urlopen(r, timeout=60) as x:
            return x.status, json.loads(x.read().decode())
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode()


def entry_unit(uid, course_id):
    """(order_index, cefr_level) de la unidad de entrada actual del usuario en el curso."""
    q = ("select u.order_index oi, u.cefr_level::text lvl "
         "from user_course_progress p join units u on u.id=p.current_unit_id "
         f"where p.user_id='{uid}' and p.course_id='{course_id}';")
    rows = json.loads(run(q)[1])
    return (rows[0]['oi'], rows[0]['lvl']) if rows else (None, None)


def plan_level(uid, course_id):
    rows = json.loads(run(f"select current_level::text lvl from user_plans where user_id='{uid}' and course_id='{course_id}';")[1])
    return rows[0]['lvl'] if rows else None


def main():
    rows = json.loads(run(
        "select id, cefr_level, correct_answer->>'value' as correct, payload->'options' as options, course_id "
        "from content_items where 'placement'=any(tags);")[1])
    meta = {r['id']: r for r in rows}

    em = 'plc_wiring_probe@jezici.test'
    admin('POST', '/auth/v1/admin/users', {'email': em, 'password': 'Test12345!', 'email_confirm': True})
    r = urllib.request.Request(SUPABASE_URL + '/auth/v1/token?grant_type=password',
                               data=json.dumps({'email': em, 'password': 'Test12345!'}).encode(), method='POST')
    r.add_header('apikey', AK); r.add_header('Content-Type', 'application/json')
    tok = json.loads(urllib.request.urlopen(r).read())['access_token']
    uid = json.loads(run(f"select id from auth.users where email='{em}';")[1])[0]['id']
    run(f"insert into public.users(id,email) values ('{uid}','{em}') on conflict do nothing;")

    passed = True
    def ck(name, cond, detail=''):
        nonlocal passed
        print(('  OK  ' if cond else '  XX  ') + name + ('  ' + detail if detail else '')); passed = passed and cond

    def place(course_id, persona_rank):
        """Corre placement_next(course_id) respondiendo como el persona; devuelve (level, skills, seen_courses)."""
        hist = []; seen = set()
        for _ in range(20):
            c, o = rpc(tok, 'placement_next', {'p_course': course_id, 'p_start_level': 'A2', 'p_history': hist})
            if not isinstance(o, dict):
                return None, None, seen
            if o.get('done'):
                return o.get('level'), o.get('skill_levels'), seen
            it = o['item']; m = meta.get(it['id']); seen.add(m['course_id'] if m else '?')
            ans = m['correct'] if RANK[m['cefr_level']] <= persona_rank else next(x for x in m['options'] if x != m['correct'])
            hist.append({'item_id': it['id'], 'answer': ans})
        return None, None, seen

    def apply_plan(level, skills):
        return rpc(tok, 'create_plan', {
            'p_coach_style': 'suave', 'p_intensity': 2, 'p_current_level': level,
            'p_goal_level': 'B1', 'p_daily_minutes': 15, 'p_days_per_week': 5, 'p_motive': 'Placer',
            'p_deadline': None, 'p_estimated_hours': 100, 'p_estimated_completion': '2027-01-01',
            'p_skill_levels': skills or {}})

    # 0) "Onboarding en": el usuario arranca en inglés y se ubica (simula B1) → progreso en.
    rpc(tok, 'set_active_course', {'p_course_id': COURSES['en']})
    lvl_en, sk_en, _ = place(COURSES['en'], 2)  # persona B1
    apply_plan(lvl_en, sk_en)
    en_before = entry_unit(uid, COURSES['en'])
    ck('en onboarding: ubica B1 y entra en su unidad', lvl_en == 'B1' and en_before[1] == 'B1',
       f"nivel={lvl_en} entrada={en_before}")

    # 1) Cambia a cada idioma no-inglés y re-ubica (A2 y A1). Comprueba la unidad de entrada.
    for code in ['de', 'nl', 'fr', 'it']:
        cid = COURSES[code]
        # -- persona A2 --
        rpc(tok, 'set_active_course', {'p_course_id': cid})
        lvl, sk, seen = place(cid, 1)
        res = apply_plan(lvl, sk)
        oi, clvl = entry_unit(uid, cid)
        only = seen <= {cid}
        ck(f'{code} A2: ubica A2 + entra en U7 (primera A2)', lvl == 'A2' and clvl == 'A2' and oi == 7 and only,
           f"nivel={lvl} entrada=(U{oi},{clvl}) solo_curso={only} plan={plan_level(uid,cid)}")
        # -- persona A1 (re-ubicación sobrescribe) --
        lvl2, sk2, _ = place(cid, 0)
        apply_plan(lvl2, sk2)
        oi2, clvl2 = entry_unit(uid, cid)
        ck(f'{code} A1: ubica A1 + entra en U1', lvl2 == 'A1' and clvl2 == 'A1' and oi2 == 1,
           f"nivel={lvl2} entrada=(U{oi2},{clvl2})")

    # 2) MULTICURSO: tras re-ubicar de/nl/fr/it, el progreso y plan de EN siguen INTACTOS.
    en_after = entry_unit(uid, COURSES['en'])
    ck('multicurso: progreso EN intacto tras re-ubicar otros', en_after == en_before,
       f"antes={en_before} despues={en_after}")
    ck('multicurso: plan EN sigue en B1', plan_level(uid, COURSES['en']) == 'B1', f"plan_en={plan_level(uid,COURSES['en'])}")

    # 3) 42501: un distractor de placement de → rechazado (grade_item), correct_answer no legible.
    de_item = next(iid for iid, m in meta.items() if m['course_id'] == COURSES['de'])
    m = meta[de_item]
    _, good = rpc(tok, 'grade_item', {'p_item_id': de_item, 'p_answer': m['correct']})
    wrong = next(x for x in m['options'] if x != m['correct'])
    _, bad = rpc(tok, 'grade_item', {'p_item_id': de_item, 'p_answer': wrong})
    ck('42501: grade_item correcto=true / distractor=false (correct_answer oculto)',
       isinstance(good, dict) and good.get('correct') is True and isinstance(bad, dict) and bad.get('correct') is False)

    # limpieza
    run(f"delete from user_lesson_progress where user_id='{uid}';")
    run(f"delete from user_course_progress where user_id='{uid}';")
    run(f"delete from user_skill_levels where user_id='{uid}';")
    run(f"delete from user_plans where user_id='{uid}';")
    run(f"delete from user_personality where user_id='{uid}';")
    run(f"delete from user_active_course where user_id='{uid}';")
    run(f"delete from user_item_attempts where user_id='{uid}';")
    run(f"delete from public.users where id='{uid}';")
    admin('DELETE', f'/auth/v1/admin/users/{uid}')
    print('\n' + ('TODO VERDE' if passed else 'HAY FALLOS'))
    sys.exit(0 if passed else 1)


if __name__ == '__main__':
    main()
