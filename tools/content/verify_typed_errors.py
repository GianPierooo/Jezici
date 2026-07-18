# -*- coding: utf-8 -*-
"""2ª PASADA de errores tipados — verifica (cliente REAL, JWT) que claim_handle
levanta el SQLSTATE CUSTOM 'JZxxx' (mig 167) y que el MENSAJE sigue siendo el
token de siempre (fallback del cliente intacto). NO cambia lógica: mismos guardas.
uso: python verify_typed_errors.py
"""
import urllib.error, json
import verify_placement_serious as V


def rpc_raw(tok, name, body):
    try:
        return 200, V.rpc(tok, name, body)
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode()


def main():
    import datetime
    cy = datetime.date.today().year
    ok = True

    def check(cond, label):
        nonlocal ok
        ok = ok and cond
        print(('  OK ' if cond else '  XX ') + label)

    tokA, uidA = V.mk_user('terr_a@test.jezici.dev')
    tokB, uidB = V.mk_user('terr_b@test.jezici.dev')
    V.rpc(tokA, 'submit_age_gate', {'p_birth_year': cy - 30})
    V.rpc(tokB, 'submit_age_gate', {'p_birth_year': cy - 30})

    # A reclama un handle válido (200)
    c, r = rpc_raw(tokA, 'claim_handle', {'p_handle': 'TypedErrA'})
    check(c == 200 and isinstance(r, dict) and r.get('handle') == 'typederra',
          'claim válido -> 200 (lógica intacta)')

    # B intenta el MISMO -> conflicto: code JZ409 + message token 'handle_taken'
    c, r = rpc_raw(tokB, 'claim_handle', {'p_handle': 'typederra'})
    s = r if isinstance(r, str) else json.dumps(r)
    print('[taken] ->', c, s)
    check('JZ409' in s, 'handle tomado -> SQLSTATE CUSTOM JZ409 (conflict)')
    check('handle_taken' in s, 'handle tomado -> mensaje = token (fallback de texto intacto)')

    # formato inválido -> JZ422 (validation) + token
    c, r = rpc_raw(tokB, 'claim_handle', {'p_handle': 'ab'})
    s = r if isinstance(r, str) else json.dumps(r)
    print('[invalid] ->', c, s)
    check('JZ422' in s and 'invalid_handle' in s, 'formato inválido -> JZ422 + invalid_handle')

    # reservado -> JZ409 (conflict) + token
    c, r = rpc_raw(tokB, 'claim_handle', {'p_handle': 'admin'})
    s = r if isinstance(r, str) else json.dumps(r)
    print('[reserved] ->', c, s)
    check('JZ409' in s and 'handle_reserved' in s, 'reservado -> JZ409 + handle_reserved')

    # B reclama uno válido (200) y re-reclamarlo pronto -> JZ429 (rate) + token
    rpc_raw(tokB, 'claim_handle', {'p_handle': 'TypedErrB'})
    c, r = rpc_raw(tokB, 'claim_handle', {'p_handle': 'TypedErrB2'})
    s = r if isinstance(r, str) else json.dumps(r)
    print('[rate] ->', c, s)
    check('JZ429' in s and 'handle_change_rate' in s, 'cambio <30d -> JZ429 + handle_change_rate')

    # limpieza
    for tok in (tokA, tokB):
        try:
            V.rpc(tok, 'delete_account', {})
        except Exception:
            pass

    print('\n' + ('TODO VERDE' if ok else 'HAY FALLOS'))
    return 0 if ok else 1


if __name__ == '__main__':
    raise SystemExit(main())
