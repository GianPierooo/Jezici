# -*- coding: utf-8 -*-
"""Verificación REAL (cliente/JWT) de la BARRA SUPERIOR funcional:
  🔔 NOTIFICACIONES · el centro es REAL: `matix_fire(trigger)` (el mismo RPC que
     los botones del centro) INSERTA una notificación 'sent', y el usuario la LEE
     bajo RLS (notif_select_own) → el badge/centro reflejan datos reales (no botón muerto).
  ❤️ VIDAS · el panel recarga con buy_hearts (economía real) — cubierto por
     verify_p0_product.py (con/sin oro). Aquí re-confirmamos que buy_hearts es
     callable por el usuario y su efecto es server-side.
Uso: python verify_topbar.py"""
import json, sys
from apply_sql import run
from verify_chain import admin, rpc


def main():
    passed = True

    def ck(name, cond, detail=''):
        nonlocal passed
        print(('  OK  ' if cond else '  XX  ') + name + ('  ' + detail if detail else ''))
        passed = passed and cond

    admin('POST', '/auth/v1/admin/users',
          {'email': 'vtopbar@jezici.test', 'password': 'Test12345!', 'email_confirm': True})
    uid = json.loads(run("select id from auth.users where email='vtopbar@jezici.test';")[1])[0]['id']

    # 🔔 Antes: sin notificaciones (estado vacío decente en el centro).
    before = rpc(uid, "select coalesce(jsonb_agg(status), '[]'::jsonb) from notifications where status='sent';")
    ck('campana: parte de un estado sin notificaciones', isinstance(before, list) and len(before) == 0,
       f"n={len(before) if isinstance(before, list) else '?'}")

    # Disparar el MISMO RPC que el centro (matix_fire) → inserta una notificación.
    rpc(uid, "select matix_fire('streak_risk');")

    # El usuario la LEE bajo RLS (lo que hace fetchNotifications: status='sent').
    after = rpc(uid, """select coalesce(jsonb_agg(jsonb_build_object('status', status, 'trigger', trigger_type)), '[]'::jsonb)
                        from notifications where status='sent';""")
    ck('campana: matix_fire crea una notificación real y el usuario la lee (RLS)',
       isinstance(after, list) and len(after) >= 1 and after[0].get('status') == 'sent',
       f"after={after}")

    # ❤️ buy_hearts callable + efecto server-side (economía real).
    run(f"insert into user_stats (user_id) values ('{uid}') on conflict (user_id) do nothing;")
    run(f"update user_stats set gold=80, hearts=0 where user_id='{uid}';")
    r = rpc(uid, 'select buy_hearts();')
    g = json.loads(run(f"select gold, hearts from user_stats where user_id='{uid}';")[1])[0]
    ck('vidas: buy_hearts cobra y recarga server-side',
       r.get('ok') is True and g['gold'] == 30 and g['hearts'] == 5, f"resp={r} db={g}")

    for t in ('notifications', 'user_stats', 'gold_transactions'):
        run(f"delete from {t} where user_id='{uid}';")
    admin('DELETE', f'/auth/v1/admin/users/{uid}')

    print('\n' + ('TODO VERDE' if passed else 'HAY FALLOS'))
    sys.exit(0 if passed else 1)


if __name__ == '__main__':
    main()
