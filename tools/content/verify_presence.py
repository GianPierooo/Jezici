# -*- coding: utf-8 -*-
"""Verifica PRESENCIA honesta (mig 156) con cliente REAL (JWT):
  - heartbeat() sella last_seen; list_friends lo devuelve (amigo "en línea").
  - set_presence(false) OCULTA el last_seen a los demás (privacidad).
  - suggest_friends expone last_seen (respeta show_presence).
uso: python verify_presence.py
"""
import json
import urllib.request
import verify_placement_serious as V
from apply_sql import run, SUPABASE_URL


def q(s):
    return json.loads(run(s)[1])


def vrpc(tok, name, body):
    """RPC que puede devolver VOID (cuerpo vacío) — no intenta parsear JSON."""
    r = urllib.request.Request(SUPABASE_URL + '/rest/v1/rpc/' + name,
                               data=json.dumps(body).encode(), method='POST')
    r.add_header('apikey', V.AK)
    r.add_header('Authorization', 'Bearer ' + tok)
    r.add_header('Content-Type', 'application/json')
    with urllib.request.urlopen(r, timeout=60) as x:
        x.read()


def main():
    ok = True
    def ck(n, c, d=''):
        nonlocal ok
        print(('  OK  ' if c else '  XX  ') + n + (('  ' + str(d)) if d != '' else ''))
        ok = ok and c

    cy = q("select extract(year from current_date)::int y")[0]['y']
    made = []

    def mk(email):
        tok, uid = V.mk_user(email)
        made.append(uid)
        V.rpc(tok, 'submit_age_gate', {'p_birth_year': cy - 30})
        return tok, uid

    try:
        tokA, uidA = mk('pres_a@test.jezici.dev')
        tokB, uidB = mk('pres_b@test.jezici.dev')
        V.rpc(tokA, 'claim_handle', {'p_handle': 'pres_alice'})
        V.rpc(tokB, 'claim_handle', {'p_handle': 'pres_bob'})
        # amigos
        stB = V.rpc(tokB, 'get_social_status', {})
        V.rpc(tokA, 'send_friend_request', {'p_code': stB['friend_code']})
        cid = V.rpc(tokB, 'list_friends', {})['incoming'][0]['connection_id']
        V.rpc(tokB, 'respond_friend_request', {'p_connection_id': cid, 'p_accept': True})

        # A late → last_seen reciente
        vrpc(tokA, 'heartbeat', {})
        a = q(f"select last_seen, last_seen > now() - interval '1 min' fresco from users where id='{uidA}'")[0]
        ck('heartbeat sella last_seen reciente', a['fresco'] is True, a['last_seen'])

        # B ve a A con last_seen (en línea)
        fr = V.rpc(tokB, 'list_friends', {})['friends']
        af = [f for f in fr if f['user_id'] == uidA][0]
        ck('list_friends devuelve last_seen del amigo', af.get('last_seen') is not None, af.get('last_seen'))
        ck('list_friends incluye handle del amigo', af.get('handle') == 'pres_alice', af.get('handle'))

        # get_social_status expone show_presence
        st = V.rpc(tokA, 'get_social_status', {})
        ck('get_social_status expone show_presence', st.get('show_presence') is True, st.get('show_presence'))

        # A oculta presencia → B ya no ve last_seen de A
        vrpc(tokA, 'set_presence', {'p_on': False})
        vrpc(tokA, 'heartbeat', {})  # aunque late, está oculto
        fr2 = V.rpc(tokB, 'list_friends', {})['friends']
        af2 = [f for f in fr2 if f['user_id'] == uidA][0]
        ck('set_presence(false) OCULTA last_seen a los demás', af2.get('last_seen') is None, af2.get('last_seen'))
        st2 = V.rpc(tokA, 'get_social_status', {})
        ck('show_presence=false reflejado', st2.get('show_presence') is False, st2.get('show_presence'))

        # re-activa
        vrpc(tokA, 'set_presence', {'p_on': True})
        fr3 = V.rpc(tokB, 'list_friends', {})['friends']
        af3 = [f for f in fr3 if f['user_id'] == uidA][0]
        ck('set_presence(true) vuelve a mostrar last_seen', af3.get('last_seen') is not None, af3.get('last_seen'))

        # sugerencias exponen last_seen (C ve a A/B)
        tokC, uidC = mk('pres_c@test.jezici.dev')
        V.rpc(tokC, 'claim_handle', {'p_handle': 'pres_carol'})
        sg = V.rpc(tokC, 'suggest_friends', {})['suggestions']
        has_ls = any('last_seen' in s for s in sg)
        ck('suggest_friends incluye el campo last_seen', has_ls, len(sg))

        print('\n' + ('TODO VERDE' if ok else 'HAY FALLOS'))
    finally:
        for uid in made:
            try:
                run(f"delete from connections where user_a_id='{uid}' or user_b_id='{uid}'")
                run(f"delete from auth.users where id='{uid}'")
            except Exception:
                pass
    return 0 if ok else 1


if __name__ == '__main__':
    import sys
    sys.exit(main())
