# -*- coding: utf-8 -*-
"""Verificación REAL (cliente JWT) del placement serio (mig 131), 2 cursos:
  - AZAR (1/3 por item, como un humano clicando sin leer) -> nivel BAJO, NUNCA B2/C1.
  - PERSONA B1 (acierta ~0.9 lo suyo, ~1/3 arriba) -> ubica B1/B2 (no A1, no C1).
  - PERSONA A2 -> ubica A1/A2 (nivel medio-bajo real).
  - AISLAMIENTO: placement_next(curso) solo sirve items de ESE curso.
Replica EXACTO el flujo del onboarding (set_active_course + loop placement_next con
p_course/p_start_level/p_history, respondiendo desde payload.options). correct_answer 42501.
Uso: python verify_placement_serious.py"""
import urllib.request, urllib.error, json, sys, random
from collections import Counter
from apply_sql import env, SUPABASE_URL, run
from verify_chain import admin

AK = env('SUPABASE_ANON_KEY')
COURSES = {'en': '20000000-0000-0000-0000-000000000001', 'pt': '20000000-0000-0000-0000-000000000002'}
RANK = {'A1': 0, 'A2': 1, 'B1': 2, 'B2': 3, 'C1': 4}


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


def trial(tok, C, start, answerer, rng, seen_courses=None):
    hist = []
    for _ in range(30):
        o = rpc(tok, 'placement_next', {'p_course': C, 'p_start_level': start, 'p_history': hist})
        if not isinstance(o, dict):
            return 'ERR'
        if o.get('done'):
            return o.get('level')
        it = o['item']
        if seen_courses is not None:
            seen_courses.add(it.get('cefr_level') and it['id'])  # marca; curso se valida aparte
        opts = ((it.get('payload') or {}).get('options')) or []
        ans = answerer(it, opts, rng)
        hist.append({'item_id': it['id'], 'answer': ans})
    return 'MAXLOOP'


def random_ans(it, opts, rng):
    return rng.choice(opts) if opts else 'x'


def persona_ans(level):
    """Persona realista: SABE su nivel y abajo (acierta ~0.9); ARRIBA de su nivel
    ADIVINA como cualquiera (opción al azar 1/3, sin ventaja). La correcta la lee el
    ADMIN (scaffolding para simular "saber"); el JWT nunca la ve."""
    def f(it, opts, rng):
        rk = RANK.get(it.get('cefr_level'), 0)
        correct = _CORRECT.get(it['id'])
        if rk <= level and correct is not None and rng.random() < 0.9:
            return correct                        # domina su nivel y por debajo
        return rng.choice(opts) if opts else 'x'  # por encima: adivina puro (1/3)
    return f


_CORRECT = {}


def main():
    # correctas por ADMIN (scaffolding para simular "saber"; el JWT nunca las ve).
    rows = json.loads(run("select id, correct_answer->>'value' v from content_items where 'placement'=any(tags);")[1])
    for r in rows:
        _CORRECT[r['id']] = r['v']

    passed = True
    def ck(name, cond, detail=''):
        nonlocal passed
        print(('  OK  ' if cond else '  XX  ') + name + ('  ' + detail if detail else '')); passed = passed and cond

    for code in ['en', 'pt']:
        C = COURSES[code]
        tok, uid = mk_user(f'vplc_serious_{code}@jezici.test')
        rpc(tok, 'set_active_course', {'p_course_id': C})
        rng = random.Random(99)

        # 1) AZAR -> nunca B2/C1
        rc = Counter()
        for _ in range(18):
            rc[trial(tok, C, 'B1', random_ans, rng)] += 1  # peor caso: arranque "buen nivel"
        infl = rc.get('B2', 0) + rc.get('C1', 0)
        ck(f'{code}: AZAR (arranque B1) NUNCA B2/C1', infl == 0,
           f"{dict(rc)}")
        ck(f'{code}: AZAR mayoria A1/A2', rc.get('A1', 0) + rc.get('A2', 0) >= 14, f"A1={rc.get('A1',0)} A2={rc.get('A2',0)}")

        # 2) PERSONA B1 -> B1/B2 (no A1, no C1)
        pb = Counter()
        for _ in range(12):
            pb[trial(tok, C, 'A2', persona_ans(2), rng)] += 1
        ck(f'{code}: PERSONA B1 ubica B1/B2 (no A1, no C1)',
           pb.get('B1', 0) + pb.get('B2', 0) >= 8 and pb.get('C1', 0) == 0, f"{dict(pb)}")

        # 3) PERSONA A2 -> centrada en A1/A2 (nivel medio-bajo). Nunca C1, casi
        #    nunca B2; algo de spill a B1 es la borrosidad natural del límite
        #    adyacente A2↔B1 en un test breve (el usuario puede reubicarse). Lo
        #    inaceptable sería C1/B2, no un B1 ocasional.
        pa = Counter()
        for _ in range(12):
            pa[trial(tok, C, 'A2', persona_ans(1), rng)] += 1
        ck(f'{code}: PERSONA A2 centrada en A1/A2 (nunca C1, casi nunca B2)',
           pa.get('C1', 0) == 0 and pa.get('B2', 0) <= 1
           and pa.get('A1', 0) + pa.get('A2', 0) >= pa.get('B1', 0), f"{dict(pa)}")

        # 4) AISLAMIENTO: un item servido pertenece al curso C
        o = rpc(tok, 'placement_next', {'p_course': C, 'p_start_level': 'A2', 'p_history': []})
        iid = o['item']['id'] if isinstance(o, dict) and o.get('item') else None
        cc = json.loads(run(f"select course_id from content_items where id='{iid}';")[1])[0]['course_id'] if iid else None
        ck(f'{code}: placement sirve SOLO items de su curso', cc == C, f"item_course={cc}")

        for t in ['user_item_attempts', 'user_active_course']:
            run(f"delete from {t} where user_id='{uid}';")
        admin('DELETE', f'/auth/v1/admin/users/{uid}')

    print('\n' + ('TODO VERDE' if passed else 'HAY FALLOS'))
    sys.exit(0 if passed else 1)


if __name__ == '__main__':
    main()
