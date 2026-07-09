# -*- coding: utf-8 -*-
"""Verificación REAL (cliente/JWT) de los 3 P0 de producto (MOCKUP_GAP.md):
  F1 · Certificado imprime el NOMBRE del titular (mig 133): al emitir/insertar un
       certificado, el trigger congela holder_name desde users; get_certificates lo
       devuelve. Un usuario con nombre lo ve en su certificado.
  F2 · Ligas usa la DIVISIÓN REAL: get_league devuelve la división del usuario
       (user_division). Se prueba con 2 divisiones distintas (oro y diamante) → el
       cliente pinta el emblema/gradiente por división (DivisionTheme), no bronce fijo.
  F3 · SinVidas cobra oro de VERDAD (buy_hearts, server-side): con oro suficiente
       descuenta 50 y recarga a 5; sin oro NO recarga (insufficient_gold) y el oro no cambia.
Usa run() (service_role, setup) y rpc(uid, ...) (como el usuario). Limpia al final.
Uso: python verify_p0_product.py"""
import json, sys
from apply_sql import run
from verify_chain import admin, rpc

EN = '20000000-0000-0000-0000-000000000001'


def mk_user(email):
    admin('POST', '/auth/v1/admin/users',
          {'email': email, 'password': 'Test12345!', 'email_confirm': True})
    uid = json.loads(run(f"select id from auth.users where email='{email}';")[1])[0]['id']
    return uid


def main():
    passed = True

    def ck(name, cond, detail=''):
        nonlocal passed
        print(('  OK  ' if cond else '  XX  ') + name + ('  ' + detail if detail else ''))
        passed = passed and cond

    uid = mk_user('vp0_product@jezici.test')

    # ── F1 · Certificado con NOMBRE ──────────────────────────────────────────
    rpc(uid, "select set_profile('María Certif');")
    # Emite un certificado A1 (como lo haría submit_level_exam) → el trigger
    # jz_cert_set_holder congela holder_name desde users.
    run(f"""insert into certificates (user_id, course_id, cefr_level, folio, verification_code, pdf_url)
            values ('{uid}', '{EN}', 'A1', 'JZC-A1-TEST-{uid[:5]}', 'VERIFYCODE0', '<svg/>')
            on conflict (user_id, cefr_level) do nothing;""")
    hn = json.loads(run(f"select holder_name from certificates where user_id='{uid}' and cefr_level='A1';")[1])
    ck('F1: trigger congela holder_name desde users', hn and hn[0]['holder_name'] == 'María Certif',
       f"holder_name={hn[0]['holder_name'] if hn else None!r}")
    certs = rpc(uid, 'select get_certificates();')
    got = next((c for c in certs if c.get('cefr_level') == 'A1'), None)
    ck('F1: get_certificates devuelve holder_name al cliente',
       got is not None and got.get('holder_name') == 'María Certif',
       f"holder_name={got.get('holder_name') if got else None!r}")
    # Cambiar el nombre NO altera el certificado ya emitido (congelado).
    rpc(uid, "select set_profile('Otro Nombre');")
    certs2 = rpc(uid, 'select get_certificates();')
    got2 = next((c for c in certs2 if c.get('cefr_level') == 'A1'), None)
    ck('F1: el nombre del certificado queda CONGELADO al emitir',
       got2 is not None and got2.get('holder_name') == 'María Certif',
       f"holder_name={got2.get('holder_name') if got2 else None!r}")

    # ── F2 · División REAL (2 divisiones) ────────────────────────────────────
    for div in ('oro', 'diamante'):
        run(f"""insert into user_division (user_id, division) values ('{uid}', '{div}')
                on conflict (user_id) do update set division='{div}';""")
        # jz_ensure_league reingresa según user_division sólo si no hay membresía
        # vigente; en la app la división la mueve el rollover, aquí la forzamos.
        run(f"delete from league_members where user_id='{uid}';")
        lg = rpc(uid, 'select get_league();')
        ck(f'F2: get_league refleja la división real ({div})', lg.get('division') == div,
           f"division={lg.get('division')!r}")

    # ── F3 · buy_hearts cobra oro de verdad ──────────────────────────────────
    run(f"insert into user_stats (user_id) values ('{uid}') on conflict (user_id) do nothing;")
    run(f"update user_stats set gold=100, hearts=0 where user_id='{uid}';")
    r_ok = rpc(uid, 'select buy_hearts();')
    g_after = json.loads(run(f"select gold, hearts from user_stats where user_id='{uid}';")[1])[0]
    ck('F3: con oro suficiente → recarga y descuenta 50',
       r_ok.get('ok') is True and g_after['gold'] == 50 and g_after['hearts'] == 5,
       f"resp={r_ok} db={g_after}")
    # Sin oro suficiente.
    run(f"update user_stats set gold=10 where user_id='{uid}';")
    r_no = rpc(uid, 'select buy_hearts();')
    g_no = json.loads(run(f"select gold from user_stats where user_id='{uid}';")[1])[0]['gold']
    ck('F3: sin oro suficiente → NO recarga y el oro no cambia',
       r_no.get('ok') is False and r_no.get('reason') == 'insufficient_gold' and g_no == 10,
       f"resp={r_no} gold={g_no}")

    # limpieza
    for t in ('certificates', 'user_division', 'league_members', 'user_stats', 'gold_transactions'):
        run(f"delete from {t} where user_id='{uid}';")
    admin('DELETE', f'/auth/v1/admin/users/{uid}')

    print('\n' + ('TODO VERDE' if passed else 'HAY FALLOS'))
    sys.exit(0 if passed else 1)


if __name__ == '__main__':
    main()
