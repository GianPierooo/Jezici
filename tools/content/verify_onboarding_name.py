# -*- coding: utf-8 -*-
"""Verificación REAL (cliente/JWT) de la captura de nombre del onboarding (mig 132 +
paso de nombre del cliente):
  1) OAUTH (Google): crear cuenta con user_metadata.full_name → handle_new_user
     siembra users.name/display_name al INSERT → get_profile devuelve el nombre y
     needs_name=false (el bug "Coloque seu nome" para usuarios de Google).
  2) EMAIL (sin metadata): la cuenta nace SIN nombre (needs_name=true) → el paso de
     nombre del onboarding llama set_profile('...') → get_profile lo devuelve y
     needs_name pasa a false. Prueba la persistencia que hace _continueName/_finish.
Usa el helper rpc() (set local role authenticated + claim sub) para las RPC como el
usuario. Limpia al final. Uso: python verify_onboarding_name.py"""
import json, sys
from apply_sql import run
from verify_chain import admin, rpc


def mk_user(email, meta=None):
    body = {'email': email, 'password': 'Test12345!', 'email_confirm': True}
    if meta is not None:
        body['user_metadata'] = meta
    code, out = admin('POST', '/auth/v1/admin/users', body)
    if code not in (200, 201):
        sys.exit(f'crear usuario falló [{code}]: {out[:300]}')
    uid = json.loads(run(f"select id from auth.users where email='{email}';")[1])[0]['id']
    return uid


def main():
    passed = True

    def ck(name, cond, detail=''):
        nonlocal passed
        print(('  OK  ' if cond else '  XX  ') + name + ('  ' + detail if detail else ''))
        passed = passed and cond

    # ── 1) Ruta Google (OAuth): metadata full_name → sembrado por el trigger ──
    uid_g = mk_user('vname_google@jezici.test', meta={'full_name': 'Zoë Marín'})
    row = json.loads(run(f"select name, display_name from users where id='{uid_g}';")[1])[0]
    ck('OAuth: users.name sembrado desde metadata', row['name'] == 'Zoë Marín',
       f"name={row['name']!r} display_name={row['display_name']!r}")
    prof_g = rpc(uid_g, 'select get_profile();')
    ck('OAuth: get_profile devuelve el nombre y needs_name=false',
       prof_g.get('name') == 'Zoë Marín' and prof_g.get('needs_name') is False,
       f"name={prof_g.get('name')!r} needs_name={prof_g.get('needs_name')}")

    # ── 2) Ruta email (sin metadata): nace sin nombre → onboarding lo fija ──
    uid_e = mk_user('vname_email@jezici.test')
    prof_e0 = rpc(uid_e, 'select get_profile();')
    ck('Email: nace SIN nombre (needs_name=true)',
       (prof_e0.get('name') in (None, '')) and prof_e0.get('needs_name') is True,
       f"name={prof_e0.get('name')!r} needs_name={prof_e0.get('needs_name')}")
    # El paso de nombre del onboarding: set_profile('Ana Placement').
    rpc(uid_e, "select set_profile('Ana Placement');")
    prof_e1 = rpc(uid_e, 'select get_profile();')
    ck('Email: set_profile del onboarding persiste el nombre',
       prof_e1.get('name') == 'Ana Placement' and prof_e1.get('needs_name') is False,
       f"name={prof_e1.get('name')!r} needs_name={prof_e1.get('needs_name')}")

    # limpieza
    for uid in (uid_g, uid_e):
        admin('DELETE', f'/auth/v1/admin/users/{uid}')

    print('\n' + ('TODO VERDE' if passed else 'HAY FALLOS'))
    sys.exit(0 if passed else 1)


if __name__ == '__main__':
    main()
