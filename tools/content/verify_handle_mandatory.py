# -*- coding: utf-8 -*-
"""Verifica (cliente REAL, JWT) el @handle OBLIGATORIO universal tras el reseteo:
  1. Un MENOR (sin adulto) PUEDE reclamar @handle (ya no exige jz_social_access).
  2. get_profile devuelve el handle (el cliente puede gate-ar el arranque).
  3. Un handle ya tomado → handle_taken (case-insensitive).
  4. Formato inválido → invalid_handle; reservado → handle_reserved.
  5. SEGURIDAD: el MENOR con handle NO aparece en search_users (sigue 18+).
Limpia los usuarios de prueba al final (la BD vuelve a 0 usuarios reales).
uso: python verify_handle_mandatory.py
"""
import urllib.error, json
import verify_placement_serious as V
from apply_sql import run


def rpc_raw(tok, name, body):
    try:
        return 200, V.rpc(tok, name, body)
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode()


def q(sql):
    return json.loads(run(sql)[1])


def main():
    cy = q("select extract(year from current_date)::int y")[0]['y']
    ok = True

    def check(cond, label):
        nonlocal ok
        ok = ok and cond
        print(('  OK ' if cond else '  XX ') + label)

    # --- MENOR (no adulto) ---
    tokM, uidM = V.mk_user('hverify_minor@test.jezici.dev')
    V.rpc(tokM, 'submit_age_gate', {'p_birth_year': cy - 12})  # 12 años
    tier = V.rpc(tokM, 'get_age_status', {})
    print('[menor] age_status =', json.dumps(tier))
    check(tier.get('age_tier') != 'adult', 'el usuario de prueba es MENOR (no adulto)')

    # 1) el menor reclama handle
    c, r = rpc_raw(tokM, 'claim_handle', {'p_handle': 'KidNova'})
    print('[menor] claim_handle(KidNova) ->', c, json.dumps(r) if isinstance(r, dict) else r)
    check(c == 200 and isinstance(r, dict) and r.get('handle') == 'kidnova',
          'MENOR PUEDE reclamar @handle (sin exigir adulto)')

    # 2) get_profile devuelve handle
    prof = V.rpc(tokM, 'get_profile', {})
    check(prof.get('handle') == 'kidnova', 'get_profile devuelve handle')

    # --- ADULTO ---
    tokA, uidA = V.mk_user('hverify_adult@test.jezici.dev')
    V.rpc(tokA, 'submit_age_gate', {'p_birth_year': cy - 30})

    # 3) tomado (case-insensitive)
    c, r = rpc_raw(tokA, 'claim_handle', {'p_handle': 'kidnova'})
    print('[adulto] claim_handle(kidnova, tomado) ->', c, r if not isinstance(r, dict) else json.dumps(r))
    check(c >= 400 and 'handle_taken' in json.dumps(r), 'handle tomado (case-insensitive) -> handle_taken')

    # 4) inválido + reservado
    c, r = rpc_raw(tokA, 'claim_handle', {'p_handle': 'ab'})
    check(c >= 400 and 'invalid_handle' in json.dumps(r), 'formato inválido -> invalid_handle')
    c, r = rpc_raw(tokA, 'claim_handle', {'p_handle': 'admin'})
    check(c >= 400 and 'handle_reserved' in json.dumps(r), 'reservado -> handle_reserved')

    # adulto reclama uno válido
    c, r = rpc_raw(tokA, 'claim_handle', {'p_handle': 'novadulto'})
    check(c == 200 and r.get('handle') == 'novadulto', 'adulto reclama @handle válido')

    # 5) SEGURIDAD: el menor con handle NO aparece en búsqueda (sigue 18+)
    c, res = rpc_raw(tokA, 'search_users', {'p_q': 'kidnova'})
    found = isinstance(res, list) and any(
        (u.get('handle') == 'kidnova') for u in res)
    print('[seguridad] search_users(kidnova) por adulto ->', c,
          json.dumps(res, default=str)[:200])
    check(not found, 'MENOR con handle NO aparece en search_users (sigue 18+)')

    # --- limpieza: borrar los usuarios de prueba -> BD vuelve a 0 ---
    run("delete from auth.users where email like 'hverify_%@test.jezici.dev';")
    left = q("select count(*)::int n from auth.users;")[0]['n']
    print('\n[limpieza] auth.users tras borrar test =', left)
    check(left == 0, 'usuarios de prueba borrados (auth.users = 0)')

    print('\n' + ('TODO VERDE' if ok else 'FALLÓ ALGO'))
    return 0 if ok else 1


if __name__ == '__main__':
    raise SystemExit(main())
