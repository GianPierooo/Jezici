# -*- coding: utf-8 -*-
"""Verifica los 3 bugs sociales de uso real con CLIENTE REAL (JWT), 2 cuentas:
  BUG1 · Mi liga (get_league) == Tablas (get_leaderboard): misma XP y orden.
  BUG2 · bloquear -> list_blocks lo ve -> unblock -> lista vacía -> vuelven a verse.
  BUG3 · get_public_profile gateado (18+, bloqueo, sin datos privados).
uso: python verify_social_bugs.py
"""
import json, urllib.error
import verify_placement_serious as V
from apply_sql import run


def q(sql):
    c, o = run(sql)
    return json.loads(o) if o.strip().startswith('[') else o


def rpc_raw(tok, name, body):
    try:
        return 200, V.rpc(tok, name, body)
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode()


def main():
    ok = True

    def check(cond, label):
        nonlocal ok
        ok = ok and cond
        print(('  OK ' if cond else '  XX ') + label)

    EN = q("select c.id from courses c join languages l on l.id=c.target_language_id where l.code='en';")[0]['id']

    # ── BUG 1 · Mi liga == Tablas ───────────────────────────────────────────
    print('=== BUG 1 · Mi liga (get_league) vs Tablas (get_leaderboard) ===')
    tok, uid = V.mk_user('socialbug@test.jezici.dev')
    V.rpc(tok, 'submit_age_gate', {'p_birth_year': 2000})
    V.rpc(tok, 'set_active_course', {'p_course_id': EN})
    # se une a la liga de un usuario real para verla poblada + XP viva propia
    gian = q("select id from public.users where handle='gian';")
    if gian:
        league = q("select league_id from league_members where user_id='%s';" % gian[0]['id'])
        if league:
            run("insert into league_members(league_id,user_id,weekly_xp) values ('%s','%s',0) on conflict do nothing;"
                % (league[0]['league_id'], uid))
    run("insert into daily_goals(user_id,goal_date,goal_xp,xp_earned) values ('%s',date_trunc('week',current_date)::date,15,33) "
        "on conflict (user_id,goal_date) do update set xp_earned=33;" % uid)

    ml = V.rpc(tok, 'get_league', {})
    lb = V.rpc(tok, 'get_leaderboard',
               {'p_metric': 'xp', 'p_window': 'weekly', 'p_scope': 'global', 'p_offset': 0, 'p_limit': 20})
    ml_pairs = [(m['name'], m['weekly_xp']) for m in ml['members']]
    lb_rows = lb.get('rows', lb.get('entries', []))
    lb_pairs = [(m.get('name'), m.get('value', m.get('weekly_xp'))) for m in lb_rows]
    # comparar por (nombre, xp) el subconjunto que aparece en ambos
    common = [p for p in ml_pairs if p[1] > 0]
    lb_map = dict(lb_pairs)
    same = all(lb_map.get(n) == xp for n, xp in common)
    check(any(x[1] > 0 for x in ml_pairs), 'Mi liga ya NO muestra 0 XP para todos')
    check(same, 'Mi liga y Tablas coinciden en XP por jugador')
    # mismo orden (por los que tienen XP)
    ml_order = [n for n, xp in ml_pairs if xp > 0]
    lb_order = [n for n, xp in lb_pairs if (xp or 0) > 0 and n in dict(ml_pairs)]
    check(ml_order == lb_order[:len(ml_order)], 'mismo ORDEN en ambas pantallas')
    check(any(m.get('user_id') for m in ml['members'] if not m['is_me']),
          'los miembros traen user_id (para tocar -> perfil); "yo" no')

    # ── BUG 2 · bloquear -> listar -> desbloquear ───────────────────────────
    print('\n=== BUG 2 · bloquear / listar / desbloquear ===')
    tokA, uidA = V.mk_user('sbugblka@test.jezici.dev'); V.rpc(tokA, 'submit_age_gate', {'p_birth_year': 2000})
    tokB, uidB = V.mk_user('sbugblkb@test.jezici.dev'); V.rpc(tokB, 'submit_age_gate', {'p_birth_year': 2000})
    V.rpc(tokA, 'claim_handle', {'p_handle': 'sbugusera'}); V.rpc(tokB, 'claim_handle', {'p_handle': 'sbuguserb'})
    check(rpc_raw(tokA, 'block_user', {'p_target': uidB})[0] == 200, 'A bloquea a B')
    bl = V.rpc(tokA, 'list_blocks', {})['blocked']
    check(len(bl) == 1 and bl[0]['user_id'] == uidB and bl[0]['handle'] == 'sbuguserb',
          'list_blocks muestra a B (para poder desbloquear)')
    c, r = rpc_raw(tokA, 'get_public_profile', {'p_user_id': uidB})
    check(c >= 400 and 'not found' in json.dumps(r), 'con el bloqueo, A NO ve el perfil de B (ambas direcciones)')
    check(rpc_raw(tokA, 'unblock_user', {'p_target': uidB})[0] == 200, 'A desbloquea a B')
    check(V.rpc(tokA, 'list_blocks', {})['blocked'] == [], 'tras desbloquear, la lista queda vacía')
    c, r = rpc_raw(tokA, 'get_public_profile', {'p_user_id': uidB})
    check(c == 200, 'A y B vuelven a interactuar (perfil visible)')

    # ── BUG 3 · perfil público gateado ──────────────────────────────────────
    print('\n=== BUG 3 · get_public_profile gateado ===')
    prof = V.rpc(tokA, 'get_public_profile', {'p_user_id': uidB})
    keys = set(prof.keys())
    check('name' in keys and 'handle' in keys, 'expone nombre/@handle (públicos)')
    check(not (keys & {'email', 'birth_year', 'birthday_day', 'age_tier', 'bio', 'gender'}),
          'NO expone email/edad/datos privados')
    # menor: no visible
    tokM, uidM = V.mk_user('sbugminor@test.jezici.dev'); V.rpc(tokM, 'submit_age_gate', {'p_birth_year': 2014})
    c, r = rpc_raw(tokA, 'get_public_profile', {'p_user_id': uidM})
    check(c >= 400 and 'not found' in json.dumps(r), 'un MENOR no aparece (18+)')
    # un menor viewer tampoco accede a lo social
    c, r = rpc_raw(tokM, 'get_public_profile', {'p_user_id': uidA})
    check(c >= 400, 'un MENOR viewer no accede al perfil de un adulto (social 18+)')

    # limpieza
    run("delete from auth.users where email like 'socialbug@%' or email like 'sbug%@test.jezici.dev';")
    reales = q("select count(*) n from auth.users where email not like '%@test.jezici.dev';")[0]['n']
    print('\n[limpieza] usuarios REALES intactos:', reales)

    print('\n' + ('TODO VERDE' if ok else 'FALLO ALGO'))
    return 0 if ok else 1


if __name__ == '__main__':
    raise SystemExit(main())
