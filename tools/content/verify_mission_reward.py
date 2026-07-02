"""Verifica el bono de bienvenida de la misión (mig 091) con cliente REAL (JWT):
1ª vez otorga 25 XP + 25 oro; 2ª vez (idempotente) otorga 0. Limpia al final."""
import urllib.request, urllib.error, json, sys
from apply_sql import env, SUPABASE_URL, run
from verify_chain import admin

AK = env('SUPABASE_ANON_KEY')
EN = '20000000-0000-0000-0000-000000000001'

def rpc(tok, name, body):
    r = urllib.request.Request(SUPABASE_URL + '/rest/v1/rpc/' + name,
                               data=json.dumps(body).encode(), method='POST')
    r.add_header('apikey', AK); r.add_header('Authorization', 'Bearer ' + tok)
    r.add_header('Content-Type', 'application/json')
    try:
        with urllib.request.urlopen(r, timeout=40) as x:
            return x.status, json.loads(x.read().decode())
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode()

def main():
    em = 'mission_probe@jezici.test'
    admin('POST', '/auth/v1/admin/users', {'email': em, 'password': 'Test12345!', 'email_confirm': True})
    r = urllib.request.Request(SUPABASE_URL + '/auth/v1/token?grant_type=password',
                               data=json.dumps({'email': em, 'password': 'Test12345!'}).encode(), method='POST')
    r.add_header('apikey', AK); r.add_header('Content-Type', 'application/json')
    tok = json.loads(urllib.request.urlopen(r).read())['access_token']
    uid = json.loads(run(f"select id from auth.users where email='{em}';")[1])[0]['id']
    run(f"insert into public.users(id,email) values ('{uid}','{em}') on conflict do nothing;")
    rpc(tok, 'start_course', {})

    mid = json.loads(run("select le.id from lessons le join units u on u.id=le.unit_id "
                         f"where u.course_id='{EN}' and le.type='mission' order by u.order_index, le.order_index limit 1;")[1])[0]['id']
    gold0 = json.loads(run(f"select gold from user_stats where user_id='{uid}';")[1])[0]['gold']

    c1, o1 = rpc(tok, 'complete_mission', {'p_lesson_id': mid})
    c2, o2 = rpc(tok, 'complete_mission', {'p_lesson_id': mid})
    goldF = json.loads(run(f"select gold from user_stats where user_id='{uid}';")[1])[0]['gold']

    passed = True
    def ck(name, cond, detail):
        nonlocal passed
        print(('  OK  ' if cond else '  XX  ') + name + '  ' + detail); passed = passed and cond

    ck('1ª vez: +25 XP +25 oro + first_time', isinstance(o1, dict) and o1.get('first_time') and o1.get('xp_earned') == 25 and o1.get('gold_earned') == 25,
       f"{json.dumps(o1)[:140]}")
    ck('2ª vez: idempotente (0/0, first_time false)', isinstance(o2, dict) and o2.get('first_time') is False and o2.get('xp_earned') == 0 and o2.get('gold_earned') == 0,
       f"{json.dumps(o2)[:140]}")
    ck('oro real subió exactamente 25', goldF - gold0 == 25, f"gold {gold0}->{goldF}")
    ck('desbloquea siguiente nodo', isinstance(o1, dict) and o1.get('next_lesson_id'), str(o1.get('next_lesson_id'))[:8] if isinstance(o1, dict) else '?')

    run(f"delete from user_item_attempts where user_id='{uid}'; delete from user_lesson_progress where user_id='{uid}'; "
        f"delete from gold_transactions where user_id='{uid}'; delete from public.users where id='{uid}';")
    admin('DELETE', f'/auth/v1/admin/users/{uid}')
    print('OK' if passed else 'FALLOS')
    sys.exit(0 if passed else 1)

if __name__ == '__main__':
    main()
