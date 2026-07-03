# -*- coding: utf-8 -*-
"""Verifica el ONBOARDING con IDIOMA META (usuario NUEVO) con CLIENTE REAL (JWT):
reproduce el flujo que dispara el onboarding cuando un usuario nuevo ELIGE su curso:
  set_active_course(<meta>) [_pickTarget] → placement_next(<meta>) [personas] → create_plan.
Comprueba que un usuario cuya PRIMERA elección es alemán aterriza en ALEMÁN en su nivel
real (A2→U7, no inglés, no A1), que NO se le crea progreso en inglés (no eligió en), y el
aislamiento (placement de de usa banco de). correct_answer 42501. Limpia al final."""
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
    q = ("select u.order_index oi, u.cefr_level::text lvl "
         "from user_course_progress p join units u on u.id=p.current_unit_id "
         f"where p.user_id='{uid}' and p.course_id='{course_id}';")
    rows = json.loads(run(q)[1])
    return (rows[0]['oi'], rows[0]['lvl']) if rows else (None, None)


def active_course(uid):
    rows = json.loads(run(f"select course_id from user_active_course where user_id='{uid}';")[1])
    return rows[0]['course_id'] if rows else None


def fresh_user(email):
    admin('POST', '/auth/v1/admin/users', {'email': email, 'password': 'Test12345!', 'email_confirm': True})
    r = urllib.request.Request(SUPABASE_URL + '/auth/v1/token?grant_type=password',
                               data=json.dumps({'email': email, 'password': 'Test12345!'}).encode(), method='POST')
    r.add_header('apikey', AK); r.add_header('Content-Type', 'application/json')
    tok = json.loads(urllib.request.urlopen(r).read())['access_token']
    uid = json.loads(run(f"select id from auth.users where email='{email}';")[1])[0]['id']
    run(f"insert into public.users(id,email) values ('{uid}','{email}') on conflict do nothing;")
    return tok, uid


def cleanup(uid):
    for t in ('user_lesson_progress', 'user_course_progress', 'user_skill_levels', 'user_plans',
              'user_personality', 'user_active_course', 'user_item_attempts'):
        run(f"delete from {t} where user_id='{uid}';")
    run(f"delete from public.users where id='{uid}';")


def main():
    meta = {r['id']: r for r in json.loads(run(
        "select id, cefr_level, correct_answer->>'value' as correct, payload->'options' as options, course_id "
        "from content_items where 'placement'=any(tags);")[1])}
    passed = True
    def ck(name, cond, detail=''):
        nonlocal passed
        print(('  OK  ' if cond else '  XX  ') + name + ('  ' + detail if detail else '')); passed = passed and cond

    def onboard(tok, uid, code, persona_rank):
        """Simula el onboarding: elige curso (set_active_course) → placement(curso) → create_plan."""
        cid = COURSES[code]
        rpc(tok, 'set_active_course', {'p_course_id': cid})  # _pickTarget
        hist = []; seen = set(); lvl = None; sk = {}
        for _ in range(20):
            c, o = rpc(tok, 'placement_next', {'p_course': cid, 'p_start_level': 'A2', 'p_history': hist})
            if not isinstance(o, dict):
                break
            if o.get('done'):
                lvl = o.get('level'); sk = o.get('skill_levels') or {}; break
            it = o['item']; m = meta.get(it['id']); seen.add(m['course_id'] if m else '?')
            ans = m['correct'] if RANK[m['cefr_level']] <= persona_rank else next(x for x in m['options'] if x != m['correct'])
            hist.append({'item_id': it['id'], 'answer': ans})
        rpc(tok, 'create_plan', {
            'p_coach_style': 'suave', 'p_intensity': 2, 'p_current_level': lvl,
            'p_goal_level': 'B1', 'p_daily_minutes': 15, 'p_days_per_week': 5, 'p_motive': 'Placer',
            'p_deadline': None, 'p_estimated_hours': 100, 'p_estimated_completion': '2027-01-01',
            'p_skill_levels': sk})
        return lvl, seen

    # 1) Usuario NUEVO cuya PRIMERA elección es ALEMÁN, responde como A2.
    tok, uid = fresh_user('onb_de_a2@jezici.test')
    lvl, seen = onboard(tok, uid, 'de', 1)
    oi, clvl = entry_unit(uid, COURSES['de'])
    en_oi, _ = entry_unit(uid, COURSES['en'])
    ck('nuevo→alemán A2: ubica A2 + entra en U7 alemán', lvl == 'A2' and clvl == 'A2' and oi == 7)
    ck('nuevo→alemán: curso activo = alemán', active_course(uid) == COURSES['de'])
    ck('nuevo→alemán: NO se crea progreso en inglés (no eligió en)', en_oi is None, f"en_entry={en_oi}")
    ck('nuevo→alemán: placement usó SOLO banco alemán', seen <= {COURSES['de']}, f"seen={seen}")
    cleanup(uid)

    # 2) Usuario NUEVO principiante que elige NEERLANDÉS → A1/U1.
    tok, uid = fresh_user('onb_nl_a1@jezici.test')
    lvl, _ = onboard(tok, uid, 'nl', 0)
    oi, clvl = entry_unit(uid, COURSES['nl'])
    ck('nuevo→neerlandés principiante: A1 + U1', lvl == 'A1' and clvl == 'A1' and oi == 1 and active_course(uid) == COURSES['nl'])
    cleanup(uid)

    # 3) Usuario NUEVO que elige INGLÉS (default) B1 → inglés como siempre.
    tok, uid = fresh_user('onb_en_b1@jezici.test')
    lvl, seen = onboard(tok, uid, 'en', 2)
    oi, clvl = entry_unit(uid, COURSES['en'])
    ck('nuevo→inglés B1: A2/B1 en inglés (sin cambio de comportamiento)',
       lvl == 'B1' and clvl == 'B1' and oi == 13 and active_course(uid) == COURSES['en'] and seen <= {COURSES['en']})
    cleanup(uid)

    # 4) 42501 sobre un ítem de placement fr (spot check).
    tok, uid = fresh_user('onb_42501@jezici.test')
    fr_item = next(iid for iid, m in meta.items() if m['course_id'] == COURSES['fr'])
    m = meta[fr_item]
    _, good = rpc(tok, 'grade_item', {'p_item_id': fr_item, 'p_answer': m['correct']})
    wrong = next(x for x in m['options'] if x != m['correct'])
    _, bad = rpc(tok, 'grade_item', {'p_item_id': fr_item, 'p_answer': wrong})
    ck('42501: grade_item correcto=true / distractor=false', isinstance(good, dict) and good.get('correct') is True and isinstance(bad, dict) and bad.get('correct') is False)
    cleanup(uid)

    for em in ('onb_de_a2@jezici.test', 'onb_nl_a1@jezici.test', 'onb_en_b1@jezici.test', 'onb_42501@jezici.test'):
        try:
            u = json.loads(run(f"select id from auth.users where email='{em}';")[1])
            if u:
                admin('DELETE', f"/auth/v1/admin/users/{u[0]['id']}")
        except Exception:
            pass
    print('\n' + ('TODO VERDE' if passed else 'HAY FALLOS'))
    sys.exit(0 if passed else 1)


if __name__ == '__main__':
    main()
