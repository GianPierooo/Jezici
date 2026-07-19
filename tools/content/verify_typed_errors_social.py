# -*- coding: utf-8 -*-
"""3ª PASADA de errores tipados — verifica (cliente REAL, JWT) que las RPC sociales
migradas (mig 175: jz_do_friend_request/block_user/report_user/set_profile_required)
levantan el SQLSTATE CUSTOM 'JZxxx' con el TOKEN estable como mensaje, y que la
LÓGICA no cambió (los casos válidos siguen 200).
uso: python verify_typed_errors_social.py
"""
import urllib.error, json, datetime
import verify_placement_serious as V


def rpc_raw(tok, name, body):
    try:
        return 200, V.rpc(tok, name, body)
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode()


def main():
    cy = datetime.date.today().year
    ok = True

    def check(cond, label):
        nonlocal ok
        ok = ok and cond
        print(('  OK ' if cond else '  XX ') + label)

    tokA, uidA = V.mk_user('terr3_a@test.jezici.dev')
    tokB, uidB = V.mk_user('terr3_b@test.jezici.dev')
    V.rpc(tokA, 'submit_age_gate', {'p_birth_year': cy - 30})
    V.rpc(tokB, 'submit_age_gate', {'p_birth_year': cy - 30})
    V.rpc(tokA, 'claim_handle', {'p_handle': 'terr3a'})
    V.rpc(tokB, 'claim_handle', {'p_handle': 'terr3b'})

    # ── set_profile_required ──
    # válido → 200 (lógica intacta)
    c, r = rpc_raw(tokA, 'set_profile_required',
                   {'p_name': 'Terr A', 'p_gender': 'other',
                    'p_birthday_day': 5, 'p_birthday_month': 6})
    check(c == 200, 'set_profile_required válido -> 200 (lógica intacta)')
    # sin género → JZ422 + token
    c, r = rpc_raw(tokA, 'set_profile_required',
                   {'p_name': 'Terr A', 'p_gender': None,
                    'p_birthday_day': 5, 'p_birthday_month': 6})
    s = r if isinstance(r, str) else json.dumps(r)
    print('[gender] ->', c, s[:120])
    check('JZ422' in s and 'gender_required' in s,
          'sin género -> JZ422 + gender_required (token intacto)')
    # sin cumpleaños → JZ422 + token
    c, r = rpc_raw(tokA, 'set_profile_required',
                   {'p_name': 'Terr A', 'p_gender': 'other',
                    'p_birthday_day': None, 'p_birthday_month': 6})
    s = r if isinstance(r, str) else json.dumps(r)
    check('JZ422' in s and 'birthday_required' in s, 'sin cumpleaños -> JZ422 + birthday_required')

    # ── jz_do_friend_request (vía request_friend) ──
    # a sí mismo → JZ422 + cannot_add_yourself
    c, r = rpc_raw(tokA, 'request_friend', {'p_user_id': uidA})
    s = r if isinstance(r, str) else json.dumps(r)
    print('[self] ->', c, s[:120])
    check('JZ422' in s and 'cannot_add_yourself' in s, 'agregarse a sí mismo -> JZ422 + cannot_add_yourself')
    # A→B y B→A (auto-acepta) → luego repetir → JZ409 + already_friends
    c, _ = rpc_raw(tokA, 'request_friend', {'p_user_id': uidB})
    check(c == 200, 'solicitud A->B -> 200 (lógica intacta)')
    c, _ = rpc_raw(tokB, 'request_friend', {'p_user_id': uidA})
    check(c == 200, 'solicitud mutua B->A -> 200 (auto-acepta)')
    c, r = rpc_raw(tokA, 'request_friend', {'p_user_id': uidB})
    s = r if isinstance(r, str) else json.dumps(r)
    print('[already] ->', c, s[:120])
    check('JZ409' in s and 'already_friends' in s, 'ya amigos -> JZ409 + already_friends')

    # ── block_user ──
    c, r = rpc_raw(tokA, 'block_user', {'p_target': uidA})
    s = r if isinstance(r, str) else json.dumps(r)
    check('JZ422' in s and 'invalid_target' in s, 'bloquearse a sí mismo -> JZ422 + invalid_target')
    c, r = rpc_raw(tokA, 'block_user', {'p_target': '00000000-0000-0000-0000-00000000dead'})
    s = r if isinstance(r, str) else json.dumps(r)
    check('JZ404' in s and 'no_such_user' in s, 'target inexistente -> JZ404 + no_such_user')
    # bloqueo real A→B → la solicitud de B a A muere con JZ403 + unavailable
    c, _ = rpc_raw(tokA, 'block_user', {'p_target': uidB})
    check(c == 200, 'block A->B -> 200 (lógica intacta)')
    c, r = rpc_raw(tokB, 'request_friend', {'p_user_id': uidA})
    s = r if isinstance(r, str) else json.dumps(r)
    print('[blocked] ->', c, s[:120])
    check('JZ403' in s and 'unavailable' in s, 'bloqueado -> JZ403 + unavailable')

    # ── report_user ──
    c, r = rpc_raw(tokA, 'report_user', {'p_target': uidA, 'p_reason': 'spam'})
    s = r if isinstance(r, str) else json.dumps(r)
    check('JZ422' in s and 'invalid_target' in s, 'reportarse a sí mismo -> JZ422 + invalid_target')
    c, _ = rpc_raw(tokA, 'report_user', {'p_target': uidB, 'p_reason': 'spam'})
    check(c == 200, 'reporte válido -> 200 (lógica intacta)')

    for tok in (tokA, tokB):
        try:
            V.rpc(tok, 'delete_account', {})
        except Exception:
            pass
    print('\n' + ('TODO VERDE' if ok else 'HAY FALLOS'))
    return 0 if ok else 1


if __name__ == '__main__':
    raise SystemExit(main())
