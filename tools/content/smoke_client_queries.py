"""Regression test (P0): ejecuta las queries EXACTAS del cliente Flutter como los
roles REALES (anon y authenticated) vía PostgREST/REST — NO RPCs con service_role.
Verifica que TODAS las superficies cargan y que correct_answer NO se expone por
ninguna vía (vista ni tabla base). Reproduce/cubre la regresión 42501 de mig 055.

Uso: python smoke_client_queries.py
"""
import urllib.request, urllib.parse, urllib.error, json, sys
from apply_sql import env, SUPABASE_URL, run
from verify_chain import admin

AK = env('SUPABASE_ANON_KEY')
EM = 'smoke_client@jezici.test'
fails = []

def req(path, token, method='GET', body=None):
    data = json.dumps(body).encode() if body is not None else None
    r = urllib.request.Request(SUPABASE_URL + path, data=data, method=method)
    r.add_header('apikey', AK)
    r.add_header('Authorization', 'Bearer ' + token)
    if body is not None:
        r.add_header('Content-Type', 'application/json')
    try:
        with urllib.request.urlopen(r, timeout=30) as resp:
            return resp.status, resp.read().decode()
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode()

def check(label, cond, detail=''):
    print(('  OK   ' if cond else '  FAIL ') + label + ('' if cond else f'  -> {detail}'))
    if not cond:
        fails.append(label)

def main():
    # token authenticated real
    admin('POST', '/auth/v1/admin/users', {'email': EM, 'password': 'Test12345!', 'email_confirm': True})
    r = urllib.request.Request(SUPABASE_URL + '/auth/v1/token?grant_type=password',
                               data=json.dumps({'email': EM, 'password': 'Test12345!'}).encode(), method='POST')
    r.add_header('apikey', AK); r.add_header('Content-Type', 'application/json')
    tok = json.loads(urllib.request.urlopen(r).read())['access_token']
    uid = json.loads(run(f"select id from auth.users where email='{EM}';")[1])[0]['id']
    run(f"insert into public.users(id,email) values ('{uid}','{EM}') on conflict do nothing;")
    lid = json.loads(run("select li.lesson_id from lesson_items li join lessons l on l.id=li.lesson_id "
                         "join units u on u.id=l.unit_id where u.cefr_level='A1' limit 1;")[1])[0]['lesson_id']

    print("== Lección (fetchLessonItems: embed de la VISTA) — anon y authenticated ==")
    sel = urllib.parse.quote('order_index,item:content_items_public(id,type,skill,cefr_level,prompt,payload,difficulty,tags)')
    for role, t in [('anon', AK), ('authenticated', tok)]:
        c, o = req(f'/rest/v1/lesson_items?select={sel}&lesson_id=eq.{lid}&order=order_index', t)
        items = json.loads(o) if c == 200 else []
        check(f'lección carga [{role}]', c == 200 and len(items) > 0, f'{c} {o[:120]}')

    print("\n== correct_answer NO expuesto por ninguna vía (anon) ==")
    c, o = req('/rest/v1/content_items_public?select=id,correct_answer&limit=1', AK)
    check('vista: correct_answer oculto', c >= 400 and '42703' in o, f'{c} {o[:100]}')
    c, o = req('/rest/v1/content_items?select=id,correct_answer&limit=1', AK)
    check('tabla base: correct_answer denegado', c >= 400 and ('42501' in o or 'permission' in o.lower()), f'{c} {o[:100]}')
    # lectura legítima de la tabla base (columnas permitidas) NO debe romper
    c, o = req('/rest/v1/content_items?select=id,prompt&limit=1', AK)
    check('tabla base: columnas permitidas OK', c == 200, f'{c} {o[:100]}')

    print("\n== Puntos de entrada (RPC) como authenticated ==")
    req('/rest/v1/rpc/start_course', tok, 'POST', {})
    for fn, body in [('start_practice', {'p_mode': 'srs'}), ('start_practice', {'p_mode': 'weakness'}),
                     ('start_practice', {'p_mode': 'timed'}), ('start_practice', {'p_mode': 'reinforce'}),
                     ('level_exam_status', {}), ('get_skill_mastery', {}), ('get_profile', {}),
                     ('get_courses', {})]:
        c, o = req(f'/rest/v1/rpc/{fn}', tok, 'POST', body)
        check(f"{fn}({body.get('p_mode','')})", c in (200, 201), f'{c} {o[:120]}')
    # grading server-side tolerante (un translation con accepted)
    row = json.loads(run("select id, correct_answer from content_items where type='translation' "
                         "and jsonb_array_length(correct_answer->'accepted')>1 limit 1;")[1])[0]
    variant = [a for a in row['correct_answer']['accepted'] if a != row['correct_answer']['value']][0]
    c, o = req('/rest/v1/rpc/grade_item', tok, 'POST', {'p_item_id': row['id'], 'p_answer': variant})
    check('grade_item tolerante (variante accepted)', c == 200 and json.loads(o).get('correct') is True, f'{c} {o[:120]}')

    admin('DELETE', f'/auth/v1/admin/users/{uid}')
    print()
    if fails:
        sys.exit(f"[FAIL] {len(fails)} fallos: {fails}")
    print("[OK] SMOKE de queries reales del cliente (anon+authenticated): TODO PASA")

if __name__ == '__main__':
    main()
