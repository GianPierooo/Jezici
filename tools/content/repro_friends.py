# -*- coding: utf-8 -*-
"""REPRO del sistema de AMISTAD roto (cliente REAL, JWT). Traza el flujo COMPLETO
y captura el ERROR REAL del servidor (el cliente lo traga con catch(_)).

Síntomas a reproducir:
  1. Agregar por CÓDIGO falla ("code not found"?) aun con código correcto.
  2. El receptor NO ve la solicitud entrante (list_friends.incoming vacío?).
  3. suggest_friends no trae a nadie.

uso: python repro_friends.py
"""
import urllib.error, json
import verify_placement_serious as V
from apply_sql import run

EN = '20000000-0000-0000-0000-000000000001'


def rpc_raw(tok, name, body):
    try:
        return 200, V.rpc(tok, name, body)
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode()


def q(sql):
    return json.loads(run(sql)[1])


def main():
    cy = q("select extract(year from current_date)::int y")[0]['y']
    adult = cy - 30

    def mk(email, year):
        tok, uid = V.mk_user(email)
        V.rpc(tok, 'submit_age_gate', {'p_birth_year': year})
        return tok, uid

    tokA, uidA = mk('repro_fa@test.jezici.dev', adult)
    tokB, uidB = mk('repro_fb@test.jezici.dev', adult)
    print('A =', uidA)
    print('B =', uidB)

    # --- estado social de cada uno ---
    stA = V.rpc(tokA, 'get_social_status', {})
    stB = V.rpc(tokB, 'get_social_status', {})
    print('\n[get_social_status A]', json.dumps(stA))
    print('[get_social_status B]', json.dumps(stB))
    codeB = stB.get('friend_code')
    print('\ncodeB =', codeB)

    # --- SÍNTOMA 1: A agrega a B por CÓDIGO ---
    print('\n=== A -> send_friend_request(codeB) ===')
    c, r = rpc_raw(tokA, 'send_friend_request', {'p_code': codeB})
    print('  HTTP', c, '·', json.dumps(r) if isinstance(r, dict) else r)

    # --- fila real en connections ---
    conns = q(f"select id,user_a_id,user_b_id,status,requested_by from connections "
              f"where user_a_id in ('{uidA}','{uidB}') or user_b_id in ('{uidA}','{uidB}')")
    print('\n[connections tras el request]', json.dumps(conns, default=str))

    # --- SÍNTOMA 2: B lista y busca la solicitud entrante ---
    print('\n=== B -> list_friends ===')
    c, lf = rpc_raw(tokB, 'list_friends', {})
    print('  HTTP', c, '·', json.dumps(lf, default=str) if isinstance(lf, dict) else lf)
    if isinstance(lf, dict):
        print('  incoming:', lf.get('incoming'))

    # --- B acepta ---
    if isinstance(lf, dict) and lf.get('incoming'):
        cid = lf['incoming'][0]['connection_id']
        print('\n=== B -> respond_friend_request(accept) ===')
        c, r = rpc_raw(tokB, 'respond_friend_request', {'p_connection_id': cid, 'p_accept': True})
        print('  HTTP', c, '·', json.dumps(r) if isinstance(r, dict) else r)
        c, lfa = rpc_raw(tokA, 'list_friends', {})
        print('  A.friends:', lfa.get('friends') if isinstance(lfa, dict) else lfa)

    # --- SÍNTOMA 3: sugerencias ---
    print('\n=== suggest_friends (A y B) ===')
    for nm, tk in (('A', tokA), ('B', tokB)):
        c, sg = rpc_raw(tk, 'suggest_friends', {})
        print(f'  {nm} HTTP', c, '·', json.dumps(sg, default=str) if isinstance(sg, dict) else sg)

    # --- limpieza ---
    for uid in (uidA, uidB):
        try:
            run(f"delete from auth.users where id='{uid}'")
        except Exception:
            pass


if __name__ == '__main__':
    main()
