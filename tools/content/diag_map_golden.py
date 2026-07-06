# -*- coding: utf-8 -*-
"""DIAGNOSTICO Frente 4 (nodos completados en dorado/verde vs candado).
Reproduce EXACTO lo que ve el cliente: crea usuario real, lo ubica en B1 (create_plan),
y como el USUARIO (anon+JWT, con RLS) lee user_lesson_progress + units/lessons del curso en,
y computa el NodeState de cada leccion como learn_map_screen._stateFor. Reporta cuantas
lecciones de U1-U12 salen 'completed' vs faltantes/locked. Limpia al final."""
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
        with urllib.request.urlopen(r, timeout=60) as x:
            return x.status, json.loads(x.read().decode())
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode()


def get(tok, path):
    """GET REST como el USUARIO (RLS aplica), igual que el cliente Flutter."""
    r = urllib.request.Request(SUPABASE_URL + '/rest/v1/' + path, method='GET')
    r.add_header('apikey', AK); r.add_header('Authorization', 'Bearer ' + tok)
    with urllib.request.urlopen(r, timeout=60) as x:
        return json.loads(x.read().decode())


RANK = {'A1': 0, 'A2': 1, 'B1': 2, 'B2': 3, 'C1': 4, 'C2': 5}


def node_state(status, unit_lvl, entry_lvl):
    """Espejo de learn_map_screen._stateFor + _belowEntry (progress no vacio).
    Regla nueva: 'completed' bajo el nivel de entrada -> mastered (dorado)."""
    if status is None:
        return 'locked'  # progress no vacio + sin fila -> locked
    if status == 'completed':
        return 'mastered' if RANK.get(unit_lvl, 0) < RANK.get(entry_lvl, 0) else 'completed'
    return {'golden': 'mastered', 'available': 'available',
            'in_progress': 'available'}.get(status, 'locked')


def main():
    em = 'diag_golden_probe@jezici.test'
    admin('POST', '/auth/v1/admin/users', {'email': em, 'password': 'Test12345!', 'email_confirm': True})
    r = urllib.request.Request(SUPABASE_URL + '/auth/v1/token?grant_type=password',
                               data=json.dumps({'email': em, 'password': 'Test12345!'}).encode(), method='POST')
    r.add_header('apikey', AK); r.add_header('Content-Type', 'application/json')
    tok = json.loads(urllib.request.urlopen(r).read())['access_token']
    uid = json.loads(run(f"select id from auth.users where email='{em}';")[1])[0]['id']
    run(f"insert into public.users(id,email) values ('{uid}','{em}') on conflict do nothing;")

    passed = True
    def ck(name, cond, detail=''):
        nonlocal passed
        print(('  OK  ' if cond else '  XX  ') + name + ('  ' + detail if detail else '')); passed = passed and cond

    # Ubica en B1 directamente (simula placement=B1).
    rpc(tok, 'set_active_course', {'p_course_id': EN})
    st, res = rpc(tok, 'create_plan', {
        'p_coach_style': 'suave', 'p_intensity': 2, 'p_current_level': 'B1',
        'p_goal_level': 'C1', 'p_daily_minutes': 15, 'p_days_per_week': 5, 'p_motive': 'Placer',
        'p_deadline': None, 'p_estimated_hours': 100, 'p_estimated_completion': '2027-01-01',
        'p_skill_levels': {'reading': 'B1', 'listening': 'B1', 'writing': 'B1', 'speaking': 'B1'}})
    print('create_plan ->', st, res)

    # Como el CLIENTE: units+lessons del curso en (fetchUnits) + progreso (fetchLessonProgress).
    units = get(tok, f"units?course_id=eq.{EN}&select=id,order_index,cefr_level,title,lessons(id,order_index,title,type)&order=order_index")
    prog_rows = get(tok, f"user_lesson_progress?user_id=eq.{uid}&select=lesson_id,status")
    prog = {r['lesson_id']: r['status'] for r in prog_rows}
    print(f"\nunits={len(units)}  progreso_filas={len(prog_rows)}")

    # Computa NodeState por leccion, agrupado por unidad.
    below_total = below_gold = 0
    entry_avail = 0
    entry_lvl = 'B1'  # nivel de entrada del plan (placement)
    print("\n unit(oi,cefr)  lessons -> estados")
    for u in units:
        oi = u['order_index']; lvl = u['cefr_level']
        lessons = sorted(u['lessons'], key=lambda l: l['order_index'])
        states = [node_state(prog.get(l['id']), lvl, entry_lvl) for l in lessons]
        tag = 'ENTRADA' if lvl == 'B1' and oi == 13 else ('<entrada' if oi < 13 else '')
        print(f"  U{oi:<2}({lvl})  {tag:<8} {states}")
        if oi < 13:  # por debajo de la entrada -> deberia salir DORADO (mastered)
            below_total += len(states)
            below_gold += sum(1 for s in states if s == 'mastered')
        if oi == 13:
            entry_avail = sum(1 for s in states if s == 'available')

    ck('U1-U12 (bajo entrada B1): TODAS salen DORADO/mastered (no verde, no candado)',
       below_total > 0 and below_gold == below_total, f"{below_gold}/{below_total}")
    ck('U13 (entrada B1): tiene >=1 nodo available', entry_avail >= 1, f"available={entry_avail}")

    # limpieza
    for t in ['user_lesson_progress', 'user_course_progress', 'user_skill_levels',
              'user_plans', 'user_personality', 'user_active_course', 'user_item_attempts']:
        run(f"delete from {t} where user_id='{uid}';")
    run(f"delete from public.users where id='{uid}';")
    admin('DELETE', f'/auth/v1/admin/users/{uid}')
    print('\n' + ('TODO VERDE' if passed else 'HAY FALLOS'))
    sys.exit(0 if passed else 1)


if __name__ == '__main__':
    main()
