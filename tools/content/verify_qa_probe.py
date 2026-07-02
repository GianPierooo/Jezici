"""Sonda QA en vivo (cliente real, JWT): recorre gamificación/progresión/ligas/perfil con
un usuario nuevo. Solo lectura de comportamiento (no cambia el código). Imprime los campos
clave para el reporte QA. Limpia al final."""
import urllib.request, urllib.error, json, sys
from apply_sql import env, SUPABASE_URL, run
from verify_chain import admin, build_answers

AK = env('SUPABASE_ANON_KEY')
EN = '20000000-0000-0000-0000-000000000001'

def req(path, tok, method='GET', body=None):
    data = json.dumps(body).encode() if body is not None else None
    r = urllib.request.Request(SUPABASE_URL + path, data=data, method=method)
    r.add_header('apikey', AK); r.add_header('Authorization', 'Bearer ' + tok)
    if body is not None: r.add_header('Content-Type', 'application/json')
    try:
        with urllib.request.urlopen(r, timeout=40) as x:
            return x.status, x.read().decode()
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode()

def rpc(tok, name, body):
    c, o = req('/rest/v1/rpc/' + name, tok, 'POST', body)
    try:
        return c, json.loads(o)
    except Exception:
        return c, o

def show(label, c, data):
    s = json.dumps(data, ensure_ascii=False)
    print(f'  [{c}] {label}: {s[:220]}')

def main():
    em = 'qa_probe@jezici.test'
    admin('POST', '/auth/v1/admin/users', {'email': em, 'password': 'Test12345!', 'email_confirm': True})
    r = urllib.request.Request(SUPABASE_URL + '/auth/v1/token?grant_type=password',
                               data=json.dumps({'email': em, 'password': 'Test12345!'}).encode(), method='POST')
    r.add_header('apikey', AK); r.add_header('Content-Type', 'application/json')
    tok = json.loads(urllib.request.urlopen(r).read())['access_token']
    uid = json.loads(run(f"select id from auth.users where email='{em}';")[1])[0]['id']
    run(f"insert into public.users(id,email) values ('{uid}','{em}') on conflict do nothing;")
    rpc(tok, 'start_course', {})

    print('== COMPLETE_LESSON (XP/oro/racha, A1 U1 L1) ==')
    lid = json.loads(run("select le.id from lessons le join units u on u.id=le.unit_id "
                         f"where u.course_id='{EN}' and u.order_index=1 and le.type='lesson' order by le.order_index limit 1;")[1])[0]['id']
    items = json.loads(run(f"select li.item_id from lesson_items li where li.lesson_id='{lid}' order by li.order_index;")[1])
    ids = [x['item_id'] for x in items]
    ans = build_answers(ids)
    c, o = rpc(tok, 'complete_lesson', {'p_lesson_id': lid, 'p_answers': ans})
    if isinstance(o, dict):
        print('  XP=%s oro=%s status=%s racha=%s combo_max=%s next=%s' % (
            o.get('xp_earned'), o.get('gold_earned'), o.get('status'), o.get('streak'),
            o.get('max_combo'), (o.get('next_lesson_id') or '')[:8]))
    else:
        show('complete_lesson', c, o)

    print('\n== PERFIL / DOMINIO / CERTIFICADOS ==')
    for name in ['get_profile', 'get_skill_mastery', 'get_certificates']:
        c, o = rpc(tok, name, {})
        show(name, c, o)

    print('\n== LIGAS / LEADERBOARDS (privacidad: sin user_id) ==')
    c, o = rpc(tok, 'get_league', {})
    show('get_league', c, o)
    leak = 'user_id' in json.dumps(o)
    print('  get_league expone user_id?:', leak)
    for win in ['weekly', 'monthly', 'yearly', 'all_time']:
        c, o = rpc(tok, 'get_leaderboard', {'p_metric': 'xp', 'p_window': win, 'p_scope': 'global', 'p_limit': 5, 'p_offset': 0})
        n = len(o.get('entries', [])) if isinstance(o, dict) else '?'
        lk = 'user_id' in json.dumps(o)
        print(f'  get_leaderboard xp/{win}: [{c}] entries={n} user_id_leak={lk}')

    print('\n== GAMIFICACIÓN (logros / tienda / cofre / freeze / vidas) ==')
    for name, body in [('get_achievements', {}), ('shop_status', {}), ('open_daily_chest', {}),
                       ('use_streak_freeze', {}), ('buy_hearts', {})]:
        c, o = rpc(tok, name, body)
        show(name, c, o)

    print('\n== PRÁCTICA (modos) ==')
    for mode in ['srs', 'weakness', 'reinforce', 'timed']:
        c, o = rpc(tok, 'start_practice', {'p_mode': mode})
        n = o.get('item_count') if isinstance(o, dict) else '?'
        print(f'  start_practice({mode}): [{c}] item_count={n} due={o.get("due_count") if isinstance(o,dict) else "?"}')

    print('\n== INMERSIÓN / TIPS ==')
    c, o = rpc(tok, 'get_stories', {})
    print('  get_stories:', c, ('historias=' + str(len(o)) if isinstance(o, list) else str(o)[:80]))
    c, o = rpc(tok, 'get_lesson_tip', {'p_lesson_id': lid})
    show('get_lesson_tip', c, o)

    # limpieza
    run(f"delete from user_item_attempts where user_id='{uid}'; delete from user_lesson_progress where user_id='{uid}'; "
        f"delete from gold_transactions where user_id='{uid}'; delete from public.users where id='{uid}';")
    admin('DELETE', f'/auth/v1/admin/users/{uid}')
    print('\n[fin sonda QA]')

if __name__ == '__main__':
    main()
