"""Verificación en vivo del FIX del congelador de racha (mig 090), cliente REAL (JWT).
El admin fija el estado de `streaks` para simular un hueco; el usuario autenticado
llama complete_lesson y comprobamos que el freeze se consume y la racha se preserva.
Nunca usa service_role para actuar como el usuario: solo para preparar el escenario."""
import urllib.request, urllib.error, json, sys
from apply_sql import env, SUPABASE_URL, run
from verify_chain import admin, build_answers

AK = env('SUPABASE_ANON_KEY')
EN = '20000000-0000-0000-0000-000000000001'

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

def set_streak(uid, streak, last_offset_days, freezes):
    """last_offset_days: cuántos días atrás fue el último día activo (2 = ayer perdido)."""
    run(f"update streaks set current_streak={streak}, longest_streak=greatest(longest_streak,{streak}), "
        f"last_active_date = current_date - {last_offset_days}, freezes_available={freezes}, updated_at=now() "
        f"where user_id='{uid}';")

def read_streak(uid):
    o = json.loads(run(f"select current_streak, freezes_available, "
                       f"(current_date - last_active_date) as gap from streaks where user_id='{uid}';")[1])
    return o[0]

def main():
    em = 'freeze_probe@jezici.test'
    admin('POST', '/auth/v1/admin/users', {'email': em, 'password': 'Test12345!', 'email_confirm': True})
    r = urllib.request.Request(SUPABASE_URL + '/auth/v1/token?grant_type=password',
                               data=json.dumps({'email': em, 'password': 'Test12345!'}).encode(), method='POST')
    r.add_header('apikey', AK); r.add_header('Content-Type', 'application/json')
    tok = json.loads(urllib.request.urlopen(r).read())['access_token']
    uid = json.loads(run(f"select id from auth.users where email='{em}';")[1])[0]['id']
    run(f"insert into public.users(id,email) values ('{uid}','{em}') on conflict do nothing;")
    rpc(tok, 'start_course', {})
    # meta diaria pequeña + acumular XP para garantizar goal_met en TODAS las llamadas
    run(f"insert into user_plans(user_id,course_id,daily_minutes) values('{uid}','{EN}',5) "
        f"on conflict (user_id,course_id) do update set daily_minutes=5;")

    lid = json.loads(run("select le.id from lessons le join units u on u.id=le.unit_id "
                         f"where u.course_id='{EN}' and u.order_index=1 and le.type='lesson' "
                         "order by le.order_index limit 1;")[1])[0]['id']
    ids = [x['item_id'] for x in json.loads(run(
        f"select li.item_id from lesson_items li where li.lesson_id='{lid}' order by li.order_index;")[1])]
    ans = build_answers(ids)

    def do_lesson():
        return rpc(tok, 'complete_lesson', {'p_lesson_id': lid, 'p_answers': ans})[1]

    # calentamiento: acumular XP diario por encima de cualquier meta
    for _ in range(3):
        do_lesson()
    print('goal_met tras calentamiento:', do_lesson().get('goal_met'))

    passed = True
    def check(name, cond, detail):
        nonlocal passed
        print(('  OK  ' if cond else '  XX  ') + name + '  ' + detail)
        passed = passed and cond

    print('\n== ESCENARIOS ==')
    # A) hueco de 1 día CON freeze → racha continúa (10→11), freeze consumido
    set_streak(uid, 10, 2, 1)
    o = do_lesson(); s = read_streak(uid)
    check('A hueco=1 con freeze: racha preservada+continúa',
          o.get('streak') == 11 and o.get('streak_freeze_used') == 1 and s['freezes_available'] == 0,
          f"streak={o.get('streak')} freeze_used={o.get('streak_freeze_used')} freezes_after={s['freezes_available']}")

    # B) hueco de 1 día SIN freeze → resetea a 1
    set_streak(uid, 10, 2, 0)
    o = do_lesson(); s = read_streak(uid)
    check('B hueco=1 sin freeze: resetea a 1',
          o.get('streak') == 1 and o.get('streak_freeze_used') == 0,
          f"streak={o.get('streak')} freeze_used={o.get('streak_freeze_used')}")

    # C) hueco de 2 días con SOLO 1 freeze (insuficiente) → resetea, NO malgasta
    set_streak(uid, 10, 3, 1)
    o = do_lesson(); s = read_streak(uid)
    check('C hueco=2 con 1 freeze (insuf.): resetea sin consumir',
          o.get('streak') == 1 and o.get('streak_freeze_used') == 0 and s['freezes_available'] == 1,
          f"streak={o.get('streak')} freeze_used={o.get('streak_freeze_used')} freezes_after={s['freezes_available']}")

    # C2) hueco de 2 días con 2 freezes (suficiente) → continúa, consume 2
    set_streak(uid, 10, 3, 2)
    o = do_lesson(); s = read_streak(uid)
    check('C2 hueco=2 con 2 freezes: continúa, consume 2',
          o.get('streak') == 11 and o.get('streak_freeze_used') == 2 and s['freezes_available'] == 0,
          f"streak={o.get('streak')} freeze_used={o.get('streak_freeze_used')} freezes_after={s['freezes_available']}")

    # D) día consecutivo con freeze disponible → NO se consume
    set_streak(uid, 10, 1, 1)
    o = do_lesson(); s = read_streak(uid)
    check('D consecutivo con freeze: incrementa sin consumir',
          o.get('streak') == 11 and o.get('streak_freeze_used') == 0 and s['freezes_available'] == 1,
          f"streak={o.get('streak')} freeze_used={o.get('streak_freeze_used')} freezes_after={s['freezes_available']}")

    # E) idempotencia: 2ª lección el MISMO día no vuelve a consumir ni cambia racha
    set_streak(uid, 10, 2, 1)
    o1 = do_lesson(); s1 = read_streak(uid)   # consume el freeze, racha 11, last=hoy
    o2 = do_lesson(); s2 = read_streak(uid)   # mismo día: no toca nada
    check('E idempotente mismo día: no re-consume',
          o1.get('streak_freeze_used') == 1 and o2.get('streak_freeze_used') == 0
          and s1['freezes_available'] == 0 and s2['freezes_available'] == 0
          and o2.get('streak') == 11,
          f"1ª freeze={o1.get('streak_freeze_used')} 2ª freeze={o2.get('streak_freeze_used')} streak2={o2.get('streak')}")

    # F) use_streak_freeze aún cobra oro y suma un freeze (economía intacta)
    run(f"update user_stats set gold=100 where user_id='{uid}';")
    set_streak(uid, 5, 1, 0)
    fr = rpc(tok, 'use_streak_freeze', {})[1]
    s = read_streak(uid)
    check('F use_streak_freeze compra: -50 oro, +1 freeze',
          fr.get('ok') is True and fr.get('gold') == 50 and s['freezes_available'] == 1,
          f"ok={fr.get('ok')} gold={fr.get('gold')} freezes={s['freezes_available']}")

    # limpieza
    run(f"delete from user_item_attempts where user_id='{uid}'; delete from user_lesson_progress where user_id='{uid}'; "
        f"delete from gold_transactions where user_id='{uid}'; delete from daily_goals where user_id='{uid}'; "
        f"delete from user_plans where user_id='{uid}'; delete from public.users where id='{uid}';")
    admin('DELETE', f'/auth/v1/admin/users/{uid}')
    print('\n' + ('TODOS VERDE ✅' if passed else 'HAY FALLOS ❌'))
    sys.exit(0 if passed else 1)

if __name__ == '__main__':
    main()
