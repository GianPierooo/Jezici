# -*- coding: utf-8 -*-
"""REPRODUCE el bug REAL del placement: un humano marcando AL AZAR.
Replica EXACTO el flujo del cliente (placement_test.dart): cada item de placement
—reading MC y writing cloze— se presenta con payload.options; el usuario toca UNA
opcion. Aqui elegimos una opcion AL AZAR (no la correcta, no un distractor fijo:
azar puro 1/3). Corre el flujo del onboarding real: set_active_course + loop
placement_next(p_course, p_start_level, history). N trials -> distribucion de niveles.
Uso: python repro_placement_random.py <code> <startHint A1|A2|B1> <N>"""
import urllib.request, urllib.error, json, sys, random
from collections import Counter
from apply_sql import env, SUPABASE_URL, run
from verify_chain import admin

AK = env('SUPABASE_ANON_KEY')
COURSES = {'en': '20000000-0000-0000-0000-000000000001', 'pt': '20000000-0000-0000-0000-000000000002',
           'fr': '20000000-0000-0000-0000-000000000003', 'it': '20000000-0000-0000-0000-000000000004',
           'de': '20000000-0000-0000-0000-000000000005', 'nl': '20000000-0000-0000-0000-000000000006'}


def rpc(tok, name, body):
    r = urllib.request.Request(SUPABASE_URL + '/rest/v1/rpc/' + name,
                               data=json.dumps(body).encode(), method='POST')
    r.add_header('apikey', AK); r.add_header('Authorization', 'Bearer ' + tok)
    r.add_header('Content-Type', 'application/json')
    with urllib.request.urlopen(r, timeout=60) as x:
        return json.loads(x.read().decode())


def mk_user(email):
    admin('POST', '/auth/v1/admin/users', {'email': email, 'password': 'Test12345!', 'email_confirm': True})
    r = urllib.request.Request(SUPABASE_URL + '/auth/v1/token?grant_type=password',
                               data=json.dumps({'email': email, 'password': 'Test12345!'}).encode(), method='POST')
    r.add_header('apikey', AK); r.add_header('Content-Type', 'application/json')
    tok = json.loads(urllib.request.urlopen(r).read())['access_token']
    uid = json.loads(run(f"select id from auth.users where email='{email}';")[1])[0]['id']
    return tok, uid


def one_trial(tok, course_id, start_hint, rng):
    """Un placement completo respondiendo AL AZAR. Devuelve (level, asked, skills)."""
    hist = []
    for _ in range(30):
        o = rpc(tok, 'placement_next', {'p_course': course_id, 'p_start_level': start_hint, 'p_history': hist})
        if not isinstance(o, dict):
            return ('ERR', len(hist), None)
        if o.get('done'):
            return (o.get('level'), o.get('asked'), o.get('skill_levels'))
        it = o['item']
        opts = ((it.get('payload') or {}).get('options')) or []
        ans = rng.choice(opts) if opts else 'x'   # AZAR puro (lo que hace un humano)
        hist.append({'item_id': it['id'], 'answer': ans})
    return ('MAXLOOP', len(hist), None)


def main():
    code = sys.argv[1] if len(sys.argv) > 1 else 'pt'
    hint = sys.argv[2] if len(sys.argv) > 2 else 'A2'
    N = int(sys.argv[3]) if len(sys.argv) > 3 else 40
    C = COURSES[code]
    rng = random.Random(1234)  # semilla fija -> reproducible

    em = f'repro_plc_{code}@jezici.test'
    tok, uid = mk_user(em)
    rpc(tok, 'set_active_course', {'p_course_id': C})

    levels = Counter(); askeds = []
    high = 0
    for _ in range(N):
        lvl, asked, _ = one_trial(tok, C, hint, rng)
        levels[lvl] += 1
        if isinstance(asked, int):
            askeds.append(asked)
        if lvl in ('B2', 'C1'):
            high += 1

    print(f"\n=== {code.upper()} · start={hint} · {N} usuarios AL AZAR (1/3 por item) ===")
    for lvl in ['A1', 'A2', 'B1', 'B2', 'C1', 'ERR', 'MAXLOOP']:
        if levels.get(lvl):
            print(f"  {lvl}: {levels[lvl]:>3}  ({100*levels[lvl]//N}%)")
    if askeds:
        print(f"  items preguntados: min {min(askeds)} / max {max(askeds)} / prom {sum(askeds)//len(askeds)}")
    print(f"  >>> AZAR termino en B2/C1 (INFLADO): {high}/{N} ({100*high//N}%)")

    # limpieza
    run(f"delete from user_item_attempts where user_id='{uid}';")
    run(f"delete from user_active_course where user_id='{uid}';")
    admin('DELETE', f'/auth/v1/admin/users/{uid}')


if __name__ == '__main__':
    main()
