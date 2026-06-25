"""Verificación de las imágenes referenciales (vocab concreto es->en) con CLIENTE REAL:
  · Las imágenes cargan por su superficie: HEAD 200 a cada payload.image_url (anon).
  · image_url LLEGA al cliente vía content_items_public.payload; correct_answer NO (42501).
  · Los image-MC se califican server-side (grade_item): palabra correcta=true, otra=false.
  · La tabla de registro vocab_images NO se filtra al cliente (RLS sin policy).
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
    except urllib.error.HTTPError as e:
        return e.code
    except Exception:
        return 0

def check(label, cond, detail=''):
    print(('  OK   ' if cond else '  FAIL ') + label + ('' if cond else f'  -> {detail}'))
    if not cond: fails.append(label)

def main():
    print('== Imágenes referenciales (imgvocab) — cliente real ==')
    items = json.loads(run("select id, payload->>'image_url' u, correct_answer->>'value' v, "
                           "payload->'options' opts from content_items where 'imgvocab'=any(tags) order by id;")[1])
    check(f'items imgvocab sembrados ({len(items)})', len(items) >= 18, str(len(items)))

    # 1) HEAD 200 a todas las imágenes
    bad = [it['id'] for it in items if head(it['u']) != 200]
    check(f'imágenes HEAD 200 ({len(items)-len(bad)}/{len(items)})', not bad, f'faltan {bad[:4]}')

    one = items[0]; iid = one['id']
    # 2) content_items_public expone image_url (anon) y NO correct_answer
    c, o = req(f"/rest/v1/content_items_public?id=eq.{iid}&select=payload", AK)
    check('vista pública: payload con image_url (anon)', c == 200 and 'image_url' in o, f'{c} {o[:100]}')
    c2, o2 = req(f"/rest/v1/content_items?id=eq.{iid}&select=correct_answer", AK)
    check('correct_answer del image-MC bloqueado (42501)', c2 != 200 or 'correct_answer' not in o2 or '42501' in o2, f'{c2} {o2[:80]}')

    # 3) grading server-side (authenticated): palabra correcta=true, otra=false
    em = 'imgvocab@jezici.test'
    admin('POST', '/auth/v1/admin/users', {'email': em, 'password': 'Test12345!', 'email_confirm': True})
    r = urllib.request.Request(SUPABASE_URL + '/auth/v1/token?grant_type=password',
                               data=json.dumps({'email': em, 'password': 'Test12345!'}).encode(), method='POST')
    r.add_header('apikey', AK); r.add_header('Content-Type', 'application/json')
    tok = json.loads(urllib.request.urlopen(r).read())['access_token']
    uid = json.loads(run(f"select id from auth.users where email='{em}';")[1])[0]['id']
    run(f"insert into public.users(id,email) values ('{uid}','{em}') on conflict do nothing;")

    correct_word = one['v']
    wrong_word = next((x for x in one['opts'] if x != correct_word), 'zzz')
    c, o = req('/rest/v1/rpc/grade_item', tok, 'POST', {'p_item_id': iid, 'p_answer': correct_word})
    check('grade_item palabra correcta → correct=true', c == 200 and json.loads(o).get('correct') is True, f'{o[:120]}')
    c, o = req('/rest/v1/rpc/grade_item', tok, 'POST', {'p_item_id': iid, 'p_answer': wrong_word})
    check('grade_item otra palabra → correct=false', c == 200 and json.loads(o).get('correct') is False, f'{o[:120]}')

    # 4) tabla vocab_images NO se filtra (RLS sin policy): anon no obtiene conceptos
    c, o = req('/rest/v1/vocab_images?select=concept,image_url', AK)
    leaked = (c == 200 and o.strip() not in ('[]', '') and 'concept' in o)
    check('vocab_images NO expuesta al cliente (RLS)', not leaked, f'{c} {o[:100]}')

    run(f"delete from public.users where id='{uid}';")
    admin('DELETE', f'/auth/v1/admin/users/{uid}')

    print('\n' + ('[FAIL] ' + ', '.join(fails) if fails else '[OK] verify_image_vocab: TODO PASA'))
    sys.exit(1 if fails else 0)

if __name__ == '__main__':
    main()
