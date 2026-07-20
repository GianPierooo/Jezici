# -*- coding: utf-8 -*-
"""Perfil público RICO (mig 176) — verifica (cliente REAL, 2 JWT) que
get_public_profile devuelve los STATS DE JUEGO no sensibles nuevos (xp_total,
lessons_completed, longest_streak, achievements_count) y que NO expone NADA
privado (email, birth_year, cumpleaños, género, bio). Guardarraíles de
privacidad/seguridad intactos (bloqueo → not found).
uso: python verify_public_profile.py
"""
import urllib.error, json, datetime
import verify_placement_serious as V

PRIVATE = ['email', 'birth_year', 'birthday_day', 'birthday_month', 'gender', 'bio', 'age_tier']
NEW = ['xp_total', 'lessons_completed', 'longest_streak', 'achievements_count']


def err(tok, name, body):
    try:
        V.rpc(tok, name, body)
        return None
    except urllib.error.HTTPError as e:
        return e.read().decode()


def main():
    cy = datetime.date.today().year
    ok = True

    def check(cond, label):
        nonlocal ok
        ok = ok and cond
        print(('  OK ' if cond else '  XX ') + label)

    tokA, uidA = V.mk_user('pubprof_a@test.jezici.dev')
    tokB, uidB = V.mk_user('pubprof_b@test.jezici.dev')
    for t in (tokA, tokB):
        V.rpc(t, 'submit_age_gate', {'p_birth_year': cy - 30})
    V.rpc(tokA, 'claim_handle', {'p_handle': 'pubprofa'})
    V.rpc(tokB, 'claim_handle', {'p_handle': 'pubprofb'})

    # A ve el perfil público de B.
    prof = V.rpc(tokA, 'get_public_profile', {'p_user_id': uidB})
    print('  [perfil B visto por A]', json.dumps(prof, ensure_ascii=False)[:300])

    # 1 · los stats NUEVOS están presentes (aunque valgan 0 para un novato).
    for k in NEW:
        check(k in prof, 'expone stat no sensible: %s' % k)

    # 2 · NINGÚN campo privado se filtra.
    for k in PRIVATE:
        check(k not in prof, 'NO expone campo privado: %s' % k)

    # 3 · los campos públicos de siempre siguen.
    for k in ('user_id', 'handle', 'name', 'avatar_color', 'member_since',
              'relationship', 'streak', 'levels', 'badges'):
        check(k in prof, 'campo público presente: %s' % k)

    # 4 · tipos correctos (numéricos, no null).
    check(isinstance(prof.get('xp_total'), int) and prof['xp_total'] >= 0, 'xp_total numérico >= 0')
    check(isinstance(prof.get('lessons_completed'), int), 'lessons_completed numérico')
    check(isinstance(prof.get('longest_streak'), int), 'longest_streak numérico')

    # 5 · GUARDARRAÍL: A bloquea a B → get_public_profile(B) da not found (ambas dir).
    V.rpc(tokA, 'block_user', {'p_target': uidB})
    e = err(tokA, 'get_public_profile', {'p_user_id': uidB})
    check(e is not None and 'not found' in e, 'bloqueado A->B: A no ve el perfil de B (not found)')
    e2 = err(tokB, 'get_public_profile', {'p_user_id': uidA})
    check(e2 is not None and 'not found' in e2, 'bloqueado: B tampoco ve a A (corta ambas direcciones)')

    for t in (tokA, tokB):
        try:
            V.rpc(t, 'delete_account', {})
        except Exception:
            pass
    print('\n' + ('TODO VERDE' if ok else 'HAY FALLOS'))
    return 0 if ok else 1


if __name__ == '__main__':
    raise SystemExit(main())
