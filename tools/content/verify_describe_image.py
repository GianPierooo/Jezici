"""Verificación del ejercicio "DESCRIBE LA IMAGEN" (word_bank sobre imagen, es->en) con
CLIENTE REAL: calificación 100% server-side; validador determinista (cada ítem califica su
propia secuencia como correcta y una errónea como incorrecta); resolverlo mueve la skill
WRITING; correct_answer 42501; imágenes cargan (HEAD 200).
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
        with urllib.request.urlopen(urllib.request.Request(url, method='HEAD'), timeout=20) as x:
            return x.status
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
    print('== "Describe la imagen" (word_bank/writing) — cliente real ==')
    items = json.loads(run("select id, cefr_level, correct_answer->'sequence' seq, "
                           "correct_answer->>'value' val, payload->>'image_url' u "
                           "from content_items where 'imgdescribe'=any(tags) order by id;")[1])
    check(f'items sembrados ({len(items)})', len(items) >= 14, str(len(items)))

    # imágenes cargan
    bad = [it['id'] for it in items if head(it['u']) != 200]
    check(f'imágenes HEAD 200 ({len(items)-len(bad)}/{len(items)})', not bad, f'faltan {bad[:4]}')

    # correct_answer oculto (anon)
    iid0 = items[0]['id']
    c, o = req(f"/rest/v1/content_items?id=eq.{iid0}&select=correct_answer", AK)
    check('correct_answer del word_bank bloqueado (42501)', c != 200 or 'correct_answer' not in o or '42501' in o, f'{c} {o[:80]}')

    # usuario real (curso en por defecto)
    em = 'describe_img@jezici.test'
    admin('POST', '/auth/v1/admin/users', {'email': em, 'password': 'Test12345!', 'email_confirm': True})
    r = urllib.request.Request(SUPABASE_URL + '/auth/v1/token?grant_type=password',
                               data=json.dumps({'email': em, 'password': 'Test12345!'}).encode(), method='POST')
    r.add_header('apikey', AK); r.add_header('Content-Type', 'application/json')
    tok = json.loads(urllib.request.urlopen(r).read())['access_token']
    uid = json.loads(run(f"select id from auth.users where email='{em}';")[1])[0]['id']
    run(f"insert into public.users(id,email) values ('{uid}','{em}') on conflict do nothing;")

    # VALIDADOR DETERMINISTA: cada ítem califica su propia secuencia como correcta;
    # una secuencia barajada distinta como incorrecta.
    nbad = 0
    for it in items:
        seq = it['seq']
        c, o = req('/rest/v1/rpc/grade_item', tok, 'POST', {'p_item_id': it['id'], 'p_answer': seq})
        if not (c == 200 and json.loads(o).get('correct') is True):
            nbad += 1; print('   secuencia correcta NO aceptada:', it['val'], o[:90])
        if len(seq) >= 2:
            wrong = list(reversed(seq))
            if wrong != seq:
                c2, o2 = req('/rest/v1/rpc/grade_item', tok, 'POST', {'p_item_id': it['id'], 'p_answer': wrong})
                if json.loads(o2).get('correct') is not False:
                    nbad += 1; print('   secuencia errónea aceptada:', it['val'])
    check('validador determinista 0 (todas califican bien)', nbad == 0, f'fallos={nbad}')

    # MUEVE WRITING: baseline → completar lección con describe-items A1 → sube writing
    base_w = mastery(tok, 'writing')
    a1 = [it for it in items if it['cefr_level'] == 'A1'][:8]
    answers = [{'item_id': it['id'], 'answer': it['seq']} for it in a1]
    a1_lesson = json.loads(run("select le.id from lessons le join units u on u.id=le.unit_id "
                               f"where u.course_id='{EN}' and u.cefr_level='A1' and le.type='lesson' "
                               "order by u.order_index, le.order_index limit 1;")[1])[0]['id']
    c, o = req('/rest/v1/rpc/complete_lesson', tok, 'POST', {'p_lesson_id': a1_lesson, 'p_answers': answers})
    j = json.loads(o) if c == 200 else {}
    check('complete_lesson 200 + calificó (graded>0)', c == 200 and (j.get('graded') or 0) >= 1, f'{c} {o[:120]}')
    aft_w = mastery(tok, 'writing')
    check(f'dominio WRITING sube ({base_w}→{aft_w})', aft_w is not None and aft_w > (base_w or 0), f'{base_w}->{aft_w}')

    run(f"delete from user_item_attempts where user_id='{uid}';")
    run(f"delete from user_lesson_progress where user_id='{uid}';")
    run(f"delete from public.users where id='{uid}';")
    admin('DELETE', f'/auth/v1/admin/users/{uid}')

    print('\n' + ('[FAIL] ' + ', '.join(fails) if fails else '[OK] verify_describe_image: TODO PASA'))
    sys.exit(1 if fails else 0)

if __name__ == '__main__':
    main()
