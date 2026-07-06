# -*- coding: utf-8 -*-
"""DIAGNOSTICO Frente 5: agilidad del placement (parada por saturacion, mig 124).
Con CLIENTE REAL (JWT) corre placement_next sobre el banco en respondiendo como
distintas personas y cuenta cuantos items pide + el nivel final. Verifica que los
EXTREMOS (todo correcto / todo mal) ya paran antes del maximo (14), no solo los
intermedios, y que el nivel resultante sigue siendo correcto (evidencia intacta)."""
import urllib.request, urllib.error, json, sys
from apply_sql import env, SUPABASE_URL, run
from verify_chain import admin

AK = env('SUPABASE_ANON_KEY')
EN = '20000000-0000-0000-0000-000000000001'
RANK = {'A1': 0, 'A2': 1, 'B1': 2, 'B2': 3, 'C1': 4}


def rpc(tok, name, body):
    r = urllib.request.Request(SUPABASE_URL + '/rest/v1/rpc/' + name,
                               data=json.dumps(body).encode(), method='POST')
    r.add_header('apikey', AK); r.add_header('Authorization', 'Bearer ' + tok)
    r.add_header('Content-Type', 'application/json')
    with urllib.request.urlopen(r, timeout=60) as x:
        return json.loads(x.read().decode())


def main():
    rows = json.loads(run(
        "select id, cefr_level, correct_answer->>'value' as correct, payload->'options' as options "
        "from content_items where 'placement'=any(tags) and course_id='" + EN + "';")[1])
    meta = {r['id']: r for r in rows}

    em = 'plc_agile_probe@jezici.test'
    admin('POST', '/auth/v1/admin/users', {'email': em, 'password': 'Test12345!', 'email_confirm': True})
    r = urllib.request.Request(SUPABASE_URL + '/auth/v1/token?grant_type=password',
                               data=json.dumps({'email': em, 'password': 'Test12345!'}).encode(), method='POST')
    r.add_header('apikey', AK); r.add_header('Content-Type', 'application/json')
    tok = json.loads(urllib.request.urlopen(r).read())['access_token']
    uid = json.loads(run(f"select id from auth.users where email='{em}';")[1])[0]['id']

    passed = True
    def ck(name, cond, detail=''):
        nonlocal passed
        print(('  OK  ' if cond else '  XX  ') + name + ('  ' + detail if detail else '')); passed = passed and cond

    def place(mode):
        """mode: 'strong' todo correcto, 'weak' todo mal, 'mid' correcto si nivel<=B1."""
        hist = []
        for _ in range(20):
            o = rpc(tok, 'placement_next', {'p_course': EN, 'p_start_level': 'A2', 'p_history': hist})
            if o.get('done'):
                return o.get('level'), len(hist)
            it = o['item']; m = meta[it['id']]
            correct = m['correct']
            wrong = next(x for x in m['options'] if x != m['correct'])
            if mode == 'strong':
                ans = correct
            elif mode == 'weak':
                ans = wrong
            else:  # mid
                ans = correct if RANK[m['cefr_level']] <= 2 else wrong
            hist.append({'item_id': it['id'], 'answer': ans})
        return None, len(hist)

    lvl_s, n_s = place('strong')
    ck('FUERTE (todo correcto): para agil (<14) y sale alto', n_s < 14 and lvl_s in ('B2', 'C1'),
       f"nivel={lvl_s} items={n_s}")
    lvl_w, n_w = place('weak')
    ck('DEBIL (todo mal): para agil (<14) y sale A1', n_w < 14 and lvl_w == 'A1',
       f"nivel={lvl_w} items={n_w}")
    lvl_m, n_m = place('mid')
    ck('INTERMEDIO (B1): ubica B1, evidencia intacta', lvl_m == 'B1',
       f"nivel={lvl_m} items={n_m}")

    # limpieza
    for t in ['user_item_attempts']:
        run(f"delete from {t} where user_id='{uid}';")
    admin('DELETE', f'/auth/v1/admin/users/{uid}')
    print('\n' + ('TODO VERDE' if passed else 'HAY FALLOS'))
    sys.exit(0 if passed else 1)


if __name__ == '__main__':
    main()
