"""Verificación del rebalanceo L/S es->pt con CLIENTE REAL (JWT) + MULTICURSO:
  · set_active_course(pt) por JWT real → el curso activo del usuario es pt.
  · Tras resolver listening/speaking pt nuevos vía complete_lesson, get_skill_mastery
    (multicurso: jz_active_course=pt) muestra que SUBE el dominio de esas skills EN EL
    CURSO PT (listening por precisión, speaking por participación).
  · RUTEO: todos los intentos quedan bajo el curso pt (cero fuga al curso en).
  · HEAD audio pt = 200; correct_answer pt OCULTO (42501).
Uso: python verify_pt_ls.py <A1|A2|B1>
"""
import urllib.request, urllib.error, json, sys
from apply_sql import env, SUPABASE_URL, run
from verify_chain import admin

AK = env('SUPABASE_ANON_KEY')
PT = '20000000-0000-0000-0000-000000000002'
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
        with urllib.request.urlopen(urllib.request.Request(url, method='HEAD'), timeout=20) as x:
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
    for s in json.loads(o).get('skills', []):
        if s.get('skill') == skill:
            return float(s.get('mastery_pct') or 0)
    return None

def main():
    LVL = next((a for a in sys.argv[1:] if a in ('A1', 'A2', 'B1')), 'A1')
    print(f'== es->pt L/S ({LVL}) — multicurso, cliente real ==')

    # audio pt: HEAD 200
    rows = json.loads(run("select id, payload->>'audio_url' u from content_items where 'lsbalpt'=any(tags) order by id;")[1])
    bad = [r['id'] for r in rows if head(r['u']) != 200]
    check(f'audio pt HEAD 200 ({len(rows)-len(bad)}/{len(rows)})', not bad, f'faltan {bad[:4]}')

    # correct_answer pt oculto
    pid = json.loads(run("select id from content_items where 'lsbalpt'=any(tags) and skill='listening' limit 1;")[1])[0]['id']
    c, o = req(f"/rest/v1/content_items?id=eq.{pid}&select=correct_answer", AK)
    check('correct_answer pt (anon) bloqueado', c != 200 or 'correct_answer' not in o or '42501' in o, f'{c} {o[:80]}')

    # usuario real
    em = f'ptls_{LVL.lower()}@jezici.test'
    admin('POST', '/auth/v1/admin/users', {'email': em, 'password': 'Test12345!', 'email_confirm': True})
    r = urllib.request.Request(SUPABASE_URL + '/auth/v1/token?grant_type=password',
                               data=json.dumps({'email': em, 'password': 'Test12345!'}).encode(), method='POST')
    r.add_header('apikey', AK); r.add_header('Content-Type', 'application/json')
    tok = json.loads(urllib.request.urlopen(r).read())['access_token']
    uid = json.loads(run(f"select id from auth.users where email='{em}';")[1])[0]['id']
    run(f"insert into public.users(id,email) values ('{uid}','{em}') on conflict do nothing;")

    # set_active_course(pt) por JWT real + confirmar ruteo
    c, o = req('/rest/v1/rpc/set_active_course', tok, 'POST', {'p_course_id': PT})
    check('set_active_course(pt) 200', c == 200, f'{c} {o[:120]}')
    ac = json.loads(run(f"select course_id from user_active_course where user_id='{uid}';")[1])
    check('curso activo = pt', ac and ac[0]['course_id'] == PT, str(ac))
    # nivelar skills pt al nivel a probar (working_level = LVL)
    run(f"update user_skill_levels set cefr_level='{LVL}' where user_id='{uid}' and course_id='{PT}';")

    base_l = mastery(tok, 'listening'); base_s = mastery(tok, 'speaking')
    check('baseline mastery pt legible', base_l is not None and base_s is not None, f'l={base_l} s={base_s}')

    lis = json.loads(run("select id, correct_answer->>'value' v from content_items "
                         f"where 'lsbalpt'=any(tags) and skill='listening' and cefr_level='{LVL}' order by id limit 8;")[1])
    spk = json.loads(run("select id, correct_answer->>'expected' v from content_items "
                         f"where 'lsbalpt'=any(tags) and skill='speaking' and cefr_level='{LVL}' order by id limit 6;")[1])
    answers = [{'item_id': x['id'], 'answer': x['v']} for x in lis] + [{'item_id': x['id'], 'answer': x['v']} for x in spk]
    pt_lesson = json.loads(run("select le.id from lessons le join units u on u.id=le.unit_id "
                               f"where u.course_id='{PT}' and u.cefr_level='{LVL}' and le.type='lesson' "
                               "order by u.order_index, le.order_index limit 1;")[1])[0]['id']
    c, o = req('/rest/v1/rpc/complete_lesson', tok, 'POST', {'p_lesson_id': pt_lesson, 'p_answers': answers})
    j = json.loads(o) if c == 200 else {}
    check('complete_lesson pt 200', c == 200, f'{c} {o[:140]}')
    check('calificó listening pt (graded>0)', (j.get('graded') or 0) >= 1, f'graded={j.get("graded")}')

    aft_l = mastery(tok, 'listening'); aft_s = mastery(tok, 'speaking')
    check(f'dominio LISTENING pt sube ({base_l}→{aft_l})', aft_l is not None and aft_l > (base_l or 0), f'{base_l}->{aft_l}')
    check(f'dominio SPEAKING pt sube ({base_s}→{aft_s})', aft_s is not None and aft_s > (base_s or 0), f'{base_s}->{aft_s}')

    # RUTEO: cero intentos fuera del curso pt
    leak = json.loads(run("select count(*) n from user_item_attempts ua join content_items ci on ci.id=ua.item_id "
                          f"where ua.user_id='{uid}' and ci.course_id<>'{PT}';")[1])[0]['n']
    check('ruteo multicurso: 0 fuga al curso en', leak == 0, f'fuga={leak}')

    run(f"delete from user_item_attempts where user_id='{uid}';")
    run(f"delete from user_lesson_progress where user_id='{uid}';")
    run(f"delete from user_active_course where user_id='{uid}';")
    run(f"delete from public.users where id='{uid}';")
    admin('DELETE', f'/auth/v1/admin/users/{uid}')

    print('\n' + ('[FAIL] ' + ', '.join(fails) if fails else f'[OK] verify_pt_ls {LVL}: TODO PASA'))
    sys.exit(1 if fails else 0)

if __name__ == '__main__':
    main()
