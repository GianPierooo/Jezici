# -*- coding: utf-8 -*-
"""Verifica el FIX del sistema de AMISTAD end-to-end (cliente REAL, JWT):
  - A agrega a B por CÓDIGO → pending; B ve incoming; B recibe NOTIFICACIÓN.
  - B acepta → amistad; A recibe NOTIFICACIÓN de aceptación.
  - Errores tipados legibles (already friends / self / bad code) — mapeables en cliente.
  - suggest_friends AMPLIADO: trae adultos descubribles aunque no compartan curso.
  - Bloqueo excluye de sugerencias/búsqueda en ambas direcciones; menor no aparece.
uso: python verify_friends.py
"""
import urllib.error, json
import verify_placement_serious as V
from apply_sql import run


def rpc_raw(tok, name, body):
    try:
        return 200, V.rpc(tok, name, body)
    except urllib.error.HTTPError as e:
        try:
            return e.code, json.loads(e.read().decode()).get('message', '')
        except Exception:
            return e.code, '?'


def q(sql):
    return json.loads(run(sql)[1])


def notifs(uid):
    return q(f"select trigger_type::text t, body from notifications where user_id='{uid}' "
             f"and status='sent' order by created_at desc")


def main():
    ok = True
    def ck(n, c, d=''):
        nonlocal ok
        print(('  OK  ' if c else '  XX  ') + n + (('  ' + str(d)) if d != '' else ''))
        ok = ok and c

    cy = q("select extract(year from current_date)::int y")[0]['y']
    adult, minor = cy - 30, cy - 14
    made = []

    def mk(email, year):
        tok, uid = V.mk_user(email)
        made.append(uid)
        V.rpc(tok, 'submit_age_gate', {'p_birth_year': year})
        return tok, uid

    try:
        tokA, uidA = mk('vf_a@test.jezici.dev', adult)
        tokB, uidB = mk('vf_b@test.jezici.dev', adult)
        tokM, uidM = mk('vf_minor@test.jezici.dev', minor)
        V.rpc(tokA, 'claim_handle', {'p_handle': 'alice_vf'})
        V.rpc(tokB, 'claim_handle', {'p_handle': 'bob_vf'})
        stB = V.rpc(tokB, 'get_social_status', {})
        codeB = stB['friend_code']

        # ---- 1) A -> send por código ----
        c, r = rpc_raw(tokA, 'send_friend_request', {'p_code': codeB})
        ck('A envía por código → pending', c == 200 and r.get('status') == 'pending', r)

        # ---- 2) B recibe NOTIFICACIÓN de solicitud ----
        nb = notifs(uidB)
        ck('B recibe notificación friend_request (in-app+push)',
           any(x['t'] == 'friend_request' for x in nb), nb)
        ck('la notificación nombra al remitente (@alice_vf)',
           any('alice_vf' in (x['body'] or '') for x in nb), nb[:1])
        # pushed_at NULL → la Edge Function la empujará
        pend = q(f"select count(*) n from notifications where user_id='{uidB}' "
                 f"and trigger_type='friend_request' and status='sent' and pushed_at is null")
        ck('la notif está lista para PUSH (pushed_at null)', pend[0]['n'] >= 1, pend)

        # ---- 3) B ve incoming y ACEPTA ----
        lf = V.rpc(tokB, 'list_friends', {})
        inc = lf.get('incoming') or []
        ck('B ve la solicitud entrante en list_friends.incoming', len(inc) == 1, inc)
        cid = inc[0]['connection_id']
        c, r = rpc_raw(tokB, 'respond_friend_request', {'p_connection_id': cid, 'p_accept': True})
        ck('B acepta → accepted', c == 200 and r.get('status') == 'accepted', r)

        # ---- 4) A recibe NOTIFICACIÓN de aceptación + son amigos ----
        na = notifs(uidA)
        ck('A recibe notificación friend_accepted',
           any(x['t'] == 'friend_accepted' for x in na), na)
        lfa = V.rpc(tokA, 'list_friends', {})
        ck('A y B son amigos', any(f['user_id'] == uidB for f in (lfa.get('friends') or [])), lfa.get('friends'))

        # ---- 5) errores tipados (legibles, no "revisa el código" para todo) ----
        c, m = rpc_raw(tokA, 'send_friend_request', {'p_code': codeB})
        ck('reintento entre amigos → "already friends" (no genérico)', 'already friends' in str(m), m)
        stA = V.rpc(tokA, 'get_social_status', {})
        c, m = rpc_raw(tokA, 'send_friend_request', {'p_code': stA['friend_code']})
        ck('código propio → "cannot add yourself"', 'cannot add yourself' in str(m), m)
        c, m = rpc_raw(tokA, 'send_friend_request', {'p_code': 'ZZZZZZZ'})
        ck('código inexistente → "code not found"', 'code not found' in str(m), m)

        # ---- 6) suggest_friends AMPLIADO (C sin mismo curso igual aparece) ----
        tokC, uidC = mk('vf_c@test.jezici.dev', adult)
        V.rpc(tokC, 'claim_handle', {'p_handle': 'carol_vf'})
        sg = V.rpc(tokC, 'suggest_friends', {})['suggestions']
        sids = {s['user_id'] for s in sg}
        ck('C (sin curso) recibe sugerencias de adultos descubribles', len(sg) >= 1, len(sg))
        ck('las sugerencias incluyen a A y/o B (adultos descubribles)',
           uidA in sids or uidB in sids, sids)
        ck('el MENOR nunca aparece en sugerencias', uidM not in sids, uidM in sids)

        # ---- 7) privacidad: no-descubrible desaparece ----
        V.rpc(tokA, 'set_discoverable', {'p_on': False})
        sg2 = {s['user_id'] for s in V.rpc(tokC, 'suggest_friends', {})['suggestions']}
        ck('A no-descubrible → fuera de sugerencias', uidA not in sg2, uidA in sg2)
        V.rpc(tokA, 'set_discoverable', {'p_on': True})

        # ---- 8) bloqueo excluye en ambas direcciones ----
        V.rpc(tokC, 'block_user', {'p_target': uidB})
        sgc = {s['user_id'] for s in V.rpc(tokC, 'suggest_friends', {})['suggestions']}
        ck('C bloqueó B → B fuera de sugerencias de C', uidB not in sgc, uidB in sgc)
        sgb = {s['user_id'] for s in V.rpc(tokB, 'suggest_friends', {})['suggestions']}
        ck('y C fuera de sugerencias de B (bloqueo bidireccional)', uidC not in sgb, uidC in sgb)

        print('\n' + ('TODO VERDE' if ok else 'HAY FALLOS'))
    finally:
        for uid in made:
            try:
                run(f"delete from connections where user_a_id='{uid}' or user_b_id='{uid}'")
                run(f"delete from notifications where user_id='{uid}'")
                run(f"delete from blocks where blocker_id='{uid}' or blocked_id='{uid}'")
                run(f"delete from auth.users where id='{uid}'")
            except Exception:
                pass
    return 0 if ok else 1


if __name__ == '__main__':
    import sys
    sys.exit(main())
