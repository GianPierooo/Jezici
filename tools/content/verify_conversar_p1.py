# -*- coding: utf-8 -*-
"""Verifica los CIMIENTOS DE SEGURIDAD de Conversar (P1, mig 146) con cliente REAL
(JWT, nunca service_role para la lógica). Prueba:
  1. AGE GATE 18+: submit_age_gate calcula is_adult REAL (adulto vs menor);
     get_age_status / get_profile lo reflejan; año inválido rechazado.
  2. MODERACIÓN: block/unblock/mute/report (auth.uid, no self-target, rate limit).
  3. BLOQUEO CORTA EN RLS: A adulto ve el social_profile de B; B bloquea a A ->
     A ya NO lo ve (RLS). Un MENOR no ve ningún social_profile (gate de edad).
  4. COLA ADMIN: get_reports rechaza no-admin ("admin only"); admin lo ve;
     mod_apply sanciona (jz_is_sanctioned) y resolve_report cierra.
  5. ESCRITURA DIRECTA DENEGADA: INSERT directo a blocks/social_profiles falla (RLS).
uso: python verify_conversar_p1.py
"""
import urllib.request, urllib.error, json, sys
import verify_placement_serious as V
from apply_sql import run, SUPABASE_URL
AK = V.AK


def sel(tok, path):
    """SELECT autenticado bajo RLS (PostgREST GET con el JWT del usuario)."""
    r = urllib.request.Request(SUPABASE_URL + '/rest/v1/' + path, method='GET')
    r.add_header('apikey', AK); r.add_header('Authorization', 'Bearer ' + tok)
    with urllib.request.urlopen(r, timeout=60) as x:
        return json.loads(x.read().decode())


def rpc_raw(tok, name, body):
    try:
        return 200, V.rpc(tok, name, body)
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode()


def post_raw(tok, path, body):
    r = urllib.request.Request(SUPABASE_URL + '/rest/v1/' + path,
                               data=json.dumps(body).encode(), method='POST')
    r.add_header('apikey', AK); r.add_header('Authorization', 'Bearer ' + tok)
    r.add_header('Content-Type', 'application/json')
    try:
        with urllib.request.urlopen(r, timeout=60) as x:
            return x.status, x.read().decode()
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode()


def q(sql):
    return json.loads(run(sql)[1])


def main():
    ok = True
    def ck(n, c, d=''):
        nonlocal ok
        print(('  OK  ' if c else '  XX  ') + n + ('  ' + str(d) if d else ''))
        ok = ok and c

    cy = q("select extract(year from current_date)::int y")[0]['y']
    adult_year = cy - 30
    minor_year = cy - 14  # ~13-14 -> teen
    users = []

    def mk(email):
        tok, uid = V.mk_user(email)
        users.append(uid)
        return tok, uid

    try:
        # ---------- 1) AGE GATE ----------
        tokA, uidA = mk('convp1_a@test.jezici.dev')
        rA = V.rpc(tokA, 'submit_age_gate', {'p_birth_year': adult_year})
        ck('1 age gate: adulto -> is_adult true', rA.get('is_adult') is True and rA.get('age_tier') == 'adult', rA)
        st = V.rpc(tokA, 'get_age_status', {})
        ck('1 get_age_status refleja adulto', st.get('is_adult') is True and st.get('has_birthdate') is True, st)
        prof = V.rpc(tokA, 'get_profile', {})
        ck('1 get_profile devuelve birth_year+age_tier', prof.get('birth_year') == adult_year and prof.get('age_tier') == 'adult', {'y': prof.get('birth_year'), 't': prof.get('age_tier')})

        tokC, uidC = mk('convp1_c@test.jezici.dev')  # MENOR
        rC = V.rpc(tokC, 'submit_age_gate', {'p_birth_year': minor_year})
        ck('1 age gate: menor -> is_adult false (teen)', rC.get('is_adult') is False and rC.get('age_tier') == 'teen', rC)
        code, _ = rpc_raw(tokA, 'submit_age_gate', {'p_birth_year': cy + 5})
        ck('1 año inválido (futuro) rechazado', code >= 400, code)

        # ---------- 2) MODERACIÓN ----------
        tokB, uidB = mk('convp1_b@test.jezici.dev')
        V.rpc(tokB, 'submit_age_gate', {'p_birth_year': adult_year})
        code, _ = rpc_raw(tokA, 'block_user', {'p_target': uidA})
        ck('2 no self-block', code >= 400, code)
        V.rpc(tokA, 'block_user', {'p_target': uidB})
        ck('2 block persistido', q(f"select count(*) n from blocks where blocker_id='{uidA}' and blocked_id='{uidB}'")[0]['n'] == 1)
        V.rpc(tokA, 'mute_user', {'p_target': uidB})
        ck('2 mute persistido', q(f"select count(*) n from mutes where muter_id='{uidA}' and muted_id='{uidB}'")[0]['n'] == 1)
        rr = V.rpc(tokA, 'report_user', {'p_target': uidB, 'p_reason': 'spam de prueba', 'p_context_type': 'profile'})
        ck('2 report creado', rr.get('reported') is True and rr.get('report_id'), rr)
        # rate limit de report (20/hora): disparar 21 -> el 21 debe fallar
        rl_hit = False
        for i in range(22):
            c, _ = rpc_raw(tokA, 'report_user', {'p_target': uidB, 'p_reason': f'r{i}', 'p_context_type': 'other'})
            if c >= 400:
                rl_hit = True; break
        ck('2 rate limit de report activo', rl_hit)

        # ---------- 3) BLOQUEO CORTA EN RLS (social_profiles) ----------
        # sembramos social_profiles (service_role) para A y B (ambos adultos)
        run(f"insert into social_profiles(user_id) values ('{uidA}'),('{uidB}') on conflict do nothing;")
        # A bloqueó a B en el paso 2 -> A NO debe ver el perfil de B
        seenAB = sel(tokA, f'social_profiles?user_id=eq.{uidB}&select=user_id')
        ck('3 A (que bloqueó a B) NO ve el social_profile de B (RLS)', seenAB == [], seenAB)
        # B (adulto, no bloqueado por su lado... el bloqueo es mutuo en RLS) tampoco ve a A
        seenBA = sel(tokB, f'social_profiles?user_id=eq.{uidA}&select=user_id')
        ck('3 el bloqueo corta en AMBAS direcciones (B tampoco ve a A)', seenBA == [], seenBA)
        # un tercero adulto SÍ ve a B (no hay bloqueo)
        tokD, uidD = mk('convp1_d@test.jezici.dev')
        V.rpc(tokD, 'submit_age_gate', {'p_birth_year': adult_year})
        seenDB = sel(tokD, f'social_profiles?user_id=eq.{uidB}&select=user_id')
        ck('3 adulto sin bloqueo SÍ ve el social_profile', len(seenDB) == 1, seenDB)
        # el MENOR C no ve ningún social_profile (gate de edad en RLS)
        seenCB = sel(tokC, f'social_profiles?user_id=eq.{uidB}&select=user_id')
        ck('3 MENOR no ve social_profiles (gate 18+ en RLS)', seenCB == [], seenCB)

        # ---------- 4) COLA DE MODERACIÓN admin ----------
        code, body = rpc_raw(tokD, 'get_reports', {})
        ck('4 no-admin -> get_reports "admin only"', code >= 400 and 'admin only' in body.lower(), body[:60])
        # convertir a D en admin (service_role) para probar el camino admin
        run(f"insert into admins(user_id) values ('{uidD}') on conflict do nothing;")
        reps = V.rpc(tokD, 'get_reports', {})
        ck('4 admin ve reportes con contexto/estado', isinstance(reps, list) and len(reps) >= 1 and reps[0].get('status') == 'open', {'n': len(reps) if isinstance(reps, list) else reps})
        # sancionar a B (suspend) y comprobar jz_is_sanctioned
        V.rpc(tokD, 'mod_apply', {'p_target': uidB, 'p_kind': 'suspend', 'p_reason': 'test', 'p_expires': None})
        ck('4 mod_apply -> sancionado', q(f"select jz_is_sanctioned('{uidB}') s")[0]['s'] is True)
        # un sancionado no puede reportar
        code, _ = rpc_raw(tokB, 'report_user', {'p_target': uidA, 'p_reason': 'x', 'p_context_type': 'other'})
        ck('4 sancionado no puede reportar', code >= 400, code)
        # resolver un reporte
        rid = reps[0]['id']
        V.rpc(tokD, 'resolve_report', {'p_report_id': rid, 'p_status': 'resolved', 'p_resolution': 'ok'})
        ck('4 resolve_report cierra', q(f"select status from reports where id='{rid}'")[0]['status'] == 'resolved')
        run(f"delete from admins where user_id='{uidD}';")

        # ---------- 5) ESCRITURA DIRECTA DENEGADA ----------
        c1, _ = post_raw(tokA, 'blocks', {'blocker_id': uidA, 'blocked_id': uidD})
        ck('5 INSERT directo a blocks DENEGADO (solo por RPC)', c1 >= 400, c1)
        c2, _ = post_raw(tokA, 'social_profiles', {'user_id': uidA, 'interests': ['x']})
        ck('5 INSERT directo a social_profiles DENEGADO', c2 >= 400, c2)

    finally:
        for uid in users:
            V.admin('DELETE', f'/auth/v1/admin/users/{uid}', None)

    print('\n' + ('TODO VERDE' if ok else 'HAY FALLOS'))
    sys.exit(0 if ok else 1)


if __name__ == '__main__':
    main()
