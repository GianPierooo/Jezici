# -*- coding: utf-8 -*-
"""Frente 2 - La mision de bienvenida CUENTA para la meta diaria y la racha.

Antes: complete_mission pagaba 25 XP + 25 oro pero NO llamaba a jz_register_activity
-> el usuario nuevo veia XP que no le movia nada (Gian: 25 XP y 0 filas en daily_goals).
Cliente REAL (anon + JWT del propio usuario), nunca service_role.
"""
import json, os, sys, time, urllib.request, urllib.error
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _introspect import run as sql  # solo lectura, para hallar la leccion de mision

BASE = 'https://wiauinufpbkmjlbqlkxo.supabase.co'
ANON = None
for ln in open(os.path.join(os.path.dirname(__file__), '..', '..', '.env'), encoding='utf-8'):
    if ln.startswith('SUPABASE_ANON_KEY='):
        ANON = ln.split('=', 1)[1].strip()
assert ANON


def call(path, body=None, jwt=None, method='POST'):
    d = json.dumps(body).encode() if body is not None else None
    r = urllib.request.Request(BASE + path, data=d, method=method)
    r.add_header('apikey', ANON)
    r.add_header('Content-Type', 'application/json')
    r.add_header('Authorization', 'Bearer ' + (jwt or ANON))
    try:
        with urllib.request.urlopen(r) as f:
            t = f.read().decode()
            return json.loads(t) if t.strip() else None
    except urllib.error.HTTPError as e:
        return {'_err': e.code, '_body': e.read().decode()[:300]}


ok = True


def chk(label, cond, extra=''):
    global ok
    ok = ok and bool(cond)
    print(('  OK   ' if cond else '  FALLA') + ' ' + label + (('  ' + str(extra)) if extra else ''))


email = 'wm%d@jezici-test.dev' % int(time.time())
u = call('/auth/v1/signup', {'email': email, 'password': 'Test1234!x'})
jwt = u.get('access_token')
assert jwt, u
print('usuario de prueba:', email)

call('/rest/v1/rpc/set_profile', {'p_name': 'Mision Test'}, jwt)
courses = call('/rest/v1/rpc/get_courses', {}, jwt)
en = [c for c in courses if c['target'] == 'en'][0]
call('/rest/v1/rpc/set_active_course', {'p_course_id': en['id']}, jwt)
# 45 min/dia = el caso REAL de @eugenio (meta con rampa = 15 el dia 1)
call('/rest/v1/rpc/create_plan', {'p_motive': 'travel', 'p_target_level': 'B1',
                                  'p_daily_minutes': 45, 'p_current_level': 'A1',
                                  'p_style': 'positivo', 'p_intensity': 3}, jwt)

mission = sql("select l.id from lessons l join units u on u.id=l.unit_id "
              "join courses c on c.id=u.course_id join languages lg on lg.id=c.target_language_id "
              "where lg.code='en' and l.type='mission' order by u.order_index limit 1;")[0]['id']


def estado():
    """Lectura por REST con el JWT del PROPIO usuario (RLS dueno) - cliente real."""
    g = call('/rest/v1/daily_goals?select=goal_date,goal_xp,xp_earned', None, jwt, 'GET') or []
    s_ = call('/rest/v1/streaks?select=current_streak,longest_streak', None, jwt, 'GET') or []
    u_ = call('/rest/v1/user_stats?select=xp_total,gold', None, jwt, 'GET') or []
    return {'dias': g, 'racha': (s_[0]['current_streak'] if s_ else 0),
            'xp_total': (u_[0]['xp_total'] if u_ else 0), 'gold': (u_[0]['gold'] if u_ else 0)}


st0 = estado()
print()
print('--- ANTES de la mision ---')
print('  ', st0)
chk('el usuario nuevo NO tiene ningun dia de actividad', st0['dias'] == [], st0['dias'])
chk('el usuario nuevo empieza con racha 0', st0['racha'] == 0, st0['racha'])

r1 = call('/rest/v1/rpc/complete_mission', {'p_lesson_id': mission}, jwt)
print()
print('--- complete_mission (1a vez) ---')
print('  ', json.dumps({k: v for k, v in (r1 or {}).items() if k != 'activity'}, ensure_ascii=False))
act = (r1 or {}).get('activity') or {}
print('   activity:', json.dumps(act, ensure_ascii=False))
chk('paga los 25 XP de bienvenida', r1.get('xp_earned') == 25, r1.get('xp_earned'))
chk('paga los 25 de oro', r1.get('gold_earned') == 25, r1.get('gold_earned'))
chk('DEVUELVE actividad (antes: nada)', bool(act))
chk('el XP de la mision ENTRA en la meta del dia', act.get('xp_earned_today') == 25,
    act.get('xp_earned_today'))
chk('la RACHA arranca en 1 (antes: 0)', act.get('streak') == 1, act.get('streak'))
chk('la meta del dia es la de la rampa (15), no los 45 min', act.get('goal_xp') == 15,
    act.get('goal_xp'))
chk('con 25 >= 15 la meta del dia queda CUMPLIDA', act.get('goal_met') is True, act.get('goal_met'))

st1 = estado()
print('   estado real:', st1)
chk('AHORA existe la fila del dia (antes: NINGUNA)', len(st1['dias']) == 1, st1['dias'])
chk('esa fila registra los 25 XP', bool(st1['dias']) and st1['dias'][0]['xp_earned'] == 25)
chk('la racha persiste en 1', st1['racha'] == 1, st1['racha'])

r2 = call('/rest/v1/rpc/complete_mission', {'p_lesson_id': mission}, jwt)
st2 = estado()
print()
print('--- complete_mission (2a vez: NO puede pagar ni contar de nuevo) ---')
print('   estado real:', st2)
chk('no vuelve a pagar XP', r2.get('xp_earned') == 0, r2.get('xp_earned'))
chk('no vuelve a pagar oro', r2.get('gold_earned') == 0, r2.get('gold_earned'))
chk('first_time = false', r2.get('first_time') is False, r2.get('first_time'))
chk('el XP total NO se duplica', st2['xp_total'] == st1['xp_total'] == 25,
    '%s vs %s' % (st1['xp_total'], st2['xp_total']))
chk('el oro NO se duplica', st2['gold'] == st1['gold'] == 25,
    '%s vs %s' % (st1['gold'], st2['gold']))
chk('la meta del dia NO cuenta dos veces', st2['dias'][0]['xp_earned'] == 25,
    st2['dias'][0]['xp_earned'])
chk('la racha sigue en 1 (no se infla)', st2['racha'] == 1, st2['racha'])

call('/rest/v1/rpc/delete_account', {}, jwt)
print()
print('TODO VERDE' if ok else 'HAY FALLAS')
sys.exit(0 if ok else 1)
