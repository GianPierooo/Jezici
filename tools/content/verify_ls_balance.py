"""Verificación del rebalanceo L/S (es->en A1/A2) con CLIENTE REAL:
  · HEAD 200 a TODAS las URLs de audio nuevas (96).
  · correct_answer de un listening nuevo OCULTO (anon, 42501).
  · MECÁNICA (task 5): tras resolver listening (correcto) + speaking (participación)
    nuevos vía complete_lesson, get_skill_mastery muestra que SUBE el dominio de esas
    skills (listening por precisión, speaking por participación).
Introspección (service_role) solo para leer la respuesta correcta (simular que el
usuario la sabe) y limpiar. Nunca para calificar.
"""
import urllib.request, urllib.error, json, sys
from apply_sql import env, SUPABASE_URL, run
from verify_chain import admin

AK = env('SUPABASE_ANON_KEY')
EN = '20000000-0000-0000-0000-000000000001'
fails = []

def req(path, token, method='GET', body=None):
    data = json.dumps(body).encode() if body is not None else None
    r = urllib.request.Request(SUPABASE_URL + path, data=data, method=method)
    r.add_header('apikey', AK); r.add_header('Authorization', 'Bearer ' + token)
    if body is not None: r.add_header('Content-Type', 'application/json')
    try:
        with urllib.request.urlopen(r, timeout=30) as resp:
            return resp.status, resp.read().decode()
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode()

def head(url):
    try:
        rq = urllib.request.Request(url, method='HEAD')
        with urllib.request.urlopen(rq, timeout=20) as x:
            return x.status
    except urllib.error.HTTPError as e:
        return e.code
    except Exception:
        return 0

def check(label, cond, detail=''):
    print(('  OK   ' if cond else '  FAIL ') + label + ('' if cond else f'  -> {detail}'))
    if not cond: fails.append(label)

def mastery(tok, skill):
    c, o = req('/rest/v1/rpc/get_skill_mastery', tok, 'POST', {})
    if c != 200: return None
    sk = json.loads(o).get('skills', [])
    for s in sk:
        if s.get('skill') == skill:
            return float(s.get('mastery_pct') or 0)
    return None

def main():
    # ── 1) Audio nuevo: HEAD 200 a las 96 URLs ────────────────────────────────
    print('== Audio nuevo (lsbal): HEAD 200 ==')
    rows = json.loads(run("select id, payload->>'audio_url' u from content_items "
                          "where 'lsbal'=any(tags) order by id;")[1])
    bad = [r['id'] for r in rows if head(r['u']) != 200]
    check(f'audio HEAD 200 ({len(rows)-len(bad)}/{len(rows)})', not bad, f'faltan: {bad[:5]}')

    # ── 2) correct_answer de listening nuevo OCULTO (anon) ────────────────────
    print('\n== correct_answer OCULTO (anon, 42501) ==')
    lid = json.loads(run("select id from content_items where 'lsbal'=any(tags) "
                         "and skill='listening' limit 1;")[1])[0]['id']
    c, o = req(f"/rest/v1/content_items?id=eq.{lid}&select=correct_answer", AK)
    check('select correct_answer (anon) bloqueado', c != 200 or 'correct_answer' not in o or '42501' in o, f'{c} {o[:100]}')

    # ── 3) MECÁNICA: L/S resueltos suben su skill (cliente real) ──────────────
    print('\n== Mecánica: listening/speaking nuevos MUEVEN user_skill_levels (dominio) ==')
    em = 'ls_mech@jezici.test'
    admin('POST', '/auth/v1/admin/users', {'email': em, 'password': 'Test12345!', 'email_confirm': True})
    r = urllib.request.Request(SUPABASE_URL + '/auth/v1/token?grant_type=password',
                               data=json.dumps({'email': em, 'password': 'Test12345!'}).encode(), method='POST')
    r.add_header('apikey', AK); r.add_header('Content-Type', 'application/json')
    tok = json.loads(urllib.request.urlopen(r).read())['access_token']
    uid = json.loads(run(f"select id from auth.users where email='{em}';")[1])[0]['id']
    run(f"insert into public.users(id,email) values ('{uid}','{em}') on conflict do nothing;")

    base_l = mastery(tok, 'listening'); base_s = mastery(tok, 'speaking')
    check('baseline mastery legible', base_l is not None and base_s is not None, f'l={base_l} s={base_s}')

    # ítems nuevos A1: 8 listening (con su value correcto) + 6 speaking
    lis = json.loads(run("select id, correct_answer->>'value' v from content_items "
                         "where 'lsbal'=any(tags) and skill='listening' and cefr_level='A1' order by id limit 8;")[1])
    spk = json.loads(run("select id, correct_answer->>'expected' v from content_items "
                         "where 'lsbal'=any(tags) and skill='speaking' and cefr_level='A1' order by id limit 6;")[1])
    answers = [{'item_id': x['id'], 'answer': x['v']} for x in lis] + \
              [{'item_id': x['id'], 'answer': x['v']} for x in spk]
    a1_lesson = json.loads(run("select le.id from lessons le join units u on u.id=le.unit_id "
                               f"where u.course_id='{EN}' and u.cefr_level='A1' and le.type='lesson' "
                               "order by u.order_index, le.order_index limit 1;")[1])[0]['id']
    c, o = req('/rest/v1/rpc/complete_lesson', tok, 'POST', {'p_lesson_id': a1_lesson, 'p_answers': answers})
    j = json.loads(o) if c == 200 else {}
    check('complete_lesson con L/S nuevos 200', c == 200, f'{c} {o[:160]}')
    check('calificó los listening (graded>0)', (j.get('graded') or 0) >= 1, f'graded={j.get("graded")}')

    aft_l = mastery(tok, 'listening'); aft_s = mastery(tok, 'speaking')
    check(f'dominio LISTENING sube ({base_l}→{aft_l})', aft_l is not None and aft_l > (base_l or 0), f'{base_l}->{aft_l}')
    check(f'dominio SPEAKING sube ({base_s}→{aft_s})', aft_s is not None and aft_s > (base_s or 0), f'{base_s}->{aft_s}')

    run(f"delete from user_item_attempts where user_id='{uid}';")
    run(f"delete from user_lesson_progress where user_id='{uid}';")
    run(f"delete from public.users where id='{uid}';")
    admin('DELETE', f'/auth/v1/admin/users/{uid}')

    print('\n' + ('[FAIL] ' + ', '.join(fails) if fails else '[OK] verify_ls_balance: TODO PASA'))
    sys.exit(1 if fails else 0)

if __name__ == '__main__':
    main()
