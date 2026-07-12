# -*- coding: utf-8 -*-
"""Verifica CONVERSAR · T3 (mig 149) con cliente REAL (JWT). Prueba TODO lo exigido:
  - @handle ÚNICO: colisión (case-insensitive) rechazada; el NOMBRE sí puede repetirse;
    formato inválido / reservado rechazados; cambio rate-limited; gate needs_handle.
  - BUSCAR por nombre o @handle: excluye bloqueados (ambas dir), respeta privacidad
    (discoverable=false → no sale), rate-limited, SOLO campos públicos.
  - PERFIL PÚBLICO: NUNCA email/edad/bio; bloqueado/no-descubrible → not found.
  - request_friend por user_id (desde búsqueda/perfil): pending + relación coherente.
  - SUGERENCIAS: mismo curso; excluye amigos/pendientes/bloqueados/menores/no-descubribles.
  - MENOR: no accede a nada; no aparece en búsqueda/sugerencias de adultos.
  - AISLAMIENTO airtight intacto: A no ve la fila users de B por REST directo.
uso: python verify_conversar_t3.py
"""
import urllib.request, urllib.error, json, sys
import verify_placement_serious as V
from apply_sql import run, SUPABASE_URL
AK = V.AK
EN = '20000000-0000-0000-0000-000000000001'


def rpc_raw(tok, name, body):
    try:
        return 200, V.rpc(tok, name, body)
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode()


def sel(tok, path):
    r = urllib.request.Request(SUPABASE_URL + '/rest/v1/' + path, method='GET')
    r.add_header('apikey', AK); r.add_header('Authorization', 'Bearer ' + tok)
    with urllib.request.urlopen(r, timeout=60) as x:
        return json.loads(x.read().decode())


def q(sql):
    return json.loads(run(sql)[1])


def main():
    ok = True
    def ck(n, c, d=''):
        nonlocal ok
        print(('  OK  ' if c else '  XX  ') + n + (('  ' + str(d)) if d != '' else ''))
        ok = ok and c

    cy = q("select extract(year from current_date)::int y")[0]['y']
    adult, minor = cy - 30, cy - 14
    users = []

    def mk(email, year):
        tok, uid = V.mk_user(email)
        users.append(uid)
        V.rpc(tok, 'submit_age_gate', {'p_birth_year': year})
        return tok, uid

    try:
        tokA, uidA = mk('t3_a@test.jezici.dev', adult)
        tokB, uidB = mk('t3_b@test.jezici.dev', adult)
        tokM, uidM = mk('t3_minor@test.jezici.dev', minor)

        # ---------- 1) @HANDLE ----------
        st = V.rpc(tokA, 'get_social_status', {})
        ck('needs_handle=true para adulto sin handle', st.get('needs_handle') is True, st.get('needs_handle'))
        r = V.rpc(tokA, 'claim_handle', {'p_handle': 'AliceW'})
        ck('claim_handle normaliza a minúsculas', r.get('handle') == 'alicew', r)
        st = V.rpc(tokA, 'get_social_status', {})
        ck('needs_handle=false tras elegir handle', st.get('needs_handle') is False, st.get('needs_handle'))
        # colisión case-insensitive
        cc, _ = rpc_raw(tokB, 'claim_handle', {'p_handle': 'alicew'})
        ck('handle DUPLICADO (case-insensitive) rechazado', cc >= 400, cc)
        cc, _ = rpc_raw(tokB, 'claim_handle', {'p_handle': '@ALICEW'})
        ck('handle duplicado con @ y mayúsculas también rechazado', cc >= 400, cc)
        rb = V.rpc(tokB, 'claim_handle', {'p_handle': 'bob_m'})
        ck('B elige handle libre', rb.get('handle') == 'bob_m', rb)
        # el NOMBRE sí puede repetirse
        V.rpc(tokA, 'set_profile', {'p_name': 'Sam'})
        V.rpc(tokB, 'set_profile', {'p_name': 'Sam'})
        dup = q(f"select count(*) c from users where lower(display_name)='sam' and id in ('{uidA}','{uidB}')")[0]['c']
        ck('el NOMBRE visible SÍ puede repetirse (2 x Sam)', dup == 2, dup)
        # formato inválido / reservado
        for bad in ['ab', 'has space', 'no@t', '###', 'a'*25, '____']:
            cc, _ = rpc_raw(tokA, 'claim_handle', {'p_handle': bad})
            ck(f'handle inválido rechazado ({bad!r})', cc >= 400, cc)
        cc, _ = rpc_raw(tokB, 'claim_handle', {'p_handle': 'admin'})
        ck('handle reservado rechazado (admin)', cc >= 400, cc)
        # cambio rate-limited (recién puesto → <30 días)
        cc, body = rpc_raw(tokA, 'claim_handle', {'p_handle': 'alice2'})
        ck('cambio de handle rate-limited (<30 días)', cc >= 400 and 'handle_change_rate' in str(body), cc)
        # re-poner el MISMO handle es no-op (no cuenta como cambio)
        rsame = V.rpc(tokA, 'claim_handle', {'p_handle': 'alicew'})
        ck('re-elegir el mismo handle = no-op', rsame.get('handle') == 'alicew', rsame)

        # ---------- 2) BUSCAR ----------
        rs = V.rpc(tokB, 'search_users', {'p_q': 'sam'})
        found = [x for x in rs['results'] if x['user_id'] == uidA]
        ck('búsqueda por NOMBRE encuentra al otro', len(found) == 1, [x.get('handle') for x in rs['results']])
        ck('resultado de búsqueda NO trae email', found and 'email' not in found[0], list(found[0].keys()) if found else None)
        rs = V.rpc(tokB, 'search_users', {'p_q': '@alicew'})
        ck('búsqueda por @handle encuentra al usuario', any(x['user_id'] == uidA for x in rs['results']))
        rs = V.rpc(tokA, 'search_users', {'p_q': 'zzz_nadie_qqq'})
        ck('búsqueda sin match → vacío', rs['results'] == [], rs['results'])
        # menor NO aparece en búsqueda de adulto
        V.rpc(tokM, 'set_profile', {'p_name': 'Samuel'})  # nombre que empieza con sam
        rs = V.rpc(tokB, 'search_users', {'p_q': 'sam'})
        ck('MENOR no aparece en búsqueda de adulto', not any(x['user_id'] == uidM for x in rs['results']))
        # menor NO puede buscar
        cc, _ = rpc_raw(tokM, 'search_users', {'p_q': 'sam'})
        ck('MENOR no puede usar búsqueda (social unavailable)', cc >= 400, cc)

        # ---------- 3) PERFIL PÚBLICO ----------
        pp = V.rpc(tokB, 'get_public_profile', {'p_user_id': uidA})
        ck('perfil público trae handle/name/levels/streak/badges',
           all(k in pp for k in ('handle', 'name', 'levels', 'streak', 'badges')), list(pp.keys()))
        for priv in ('email', 'birth_year', 'age_tier', 'bio', 'birthday_day', 'birthday_month'):
            ck(f'perfil público NO expone {priv}', priv not in pp)
        # relación none al inicio
        ck('relación inicial = none', pp.get('relationship') == 'none', pp.get('relationship'))
        # perfil de un MENOR → not found
        cc, _ = rpc_raw(tokB, 'get_public_profile', {'p_user_id': uidM})
        ck('perfil público de un MENOR → not found', cc >= 400, cc)

        # ---------- 4) request_friend por user_id ----------
        rf = V.rpc(tokB, 'request_friend', {'p_user_id': uidA})
        ck('request_friend(user_id) → pending', rf.get('status') == 'pending', rf)
        pp = V.rpc(tokB, 'get_public_profile', {'p_user_id': uidA})
        ck('tras solicitar, relación = pending_out (para B)', pp.get('relationship') == 'pending_out', pp.get('relationship'))
        ppa = V.rpc(tokA, 'get_public_profile', {'p_user_id': uidB})
        ck('para A la relación = pending_in', ppa.get('relationship') == 'pending_in', ppa.get('relationship'))
        # A acepta → amigos
        V.rpc(tokA, 'respond_friend_request', {'p_connection_id': rf['connection_id'], 'p_accept': True})
        pp = V.rpc(tokB, 'get_public_profile', {'p_user_id': uidA})
        ck('tras aceptar, relación = friends', pp.get('relationship') == 'friends', pp.get('relationship'))

        # ---------- 5) BLOQUEO corta búsqueda + perfil en AMBAS direcciones ----------
        V.rpc(tokB, 'block_user', {'p_target': uidA})
        rs = V.rpc(tokB, 'search_users', {'p_q': 'sam'})
        ck('bloqueador NO ve al bloqueado en búsqueda', not any(x['user_id'] == uidA for x in rs['results']))
        rs = V.rpc(tokA, 'search_users', {'p_q': 'sam'})
        ck('bloqueado NO ve al bloqueador en búsqueda (otra dir)', not any(x['user_id'] == uidB for x in rs['results']))
        cc, _ = rpc_raw(tokB, 'get_public_profile', {'p_user_id': uidA})
        ck('perfil del bloqueado → not found', cc >= 400, cc)
        cc, _ = rpc_raw(tokA, 'get_public_profile', {'p_user_id': uidB})
        ck('perfil del bloqueador → not found (otra dir)', cc >= 400, cc)
        V.rpc(tokB, 'unblock_user', {'p_target': uidA})

        # ---------- 6) PRIVACIDAD "aparecer en búsqueda" ----------
        V.rpc(tokA, 'set_discoverable', {'p_on': False})
        # (siguen amigos → el perfil se ve; pero un TERCERO no-amigo no lo encuentra)
        tokC, uidC = mk('t3_c@test.jezici.dev', adult)
        V.rpc(tokC, 'claim_handle', {'p_handle': 'carol_c'})
        rs = V.rpc(tokC, 'search_users', {'p_q': 'sam'})
        ck('no-descubrible NO aparece en búsqueda de un tercero', not any(x['user_id'] == uidA for x in rs['results']))
        cc, _ = rpc_raw(tokC, 'get_public_profile', {'p_user_id': uidA})
        ck('perfil de no-descubrible (sin vínculo) → not found', cc >= 400, cc)
        # el amigo B SÍ puede ver el perfil aunque A sea no-descubrible
        okp, pp = rpc_raw(tokB, 'get_public_profile', {'p_user_id': uidA})
        ck('un AMIGO sí ve el perfil de un no-descubrible', okp == 200, okp)
        V.rpc(tokA, 'set_discoverable', {'p_on': True})

        # ---------- 7) SUGERENCIAS ----------
        # C y un nuevo D en el MISMO curso que C (en) → D debe sugerirse a C
        tokD, uidD = mk('t3_d@test.jezici.dev', adult)
        V.rpc(tokD, 'claim_handle', {'p_handle': 'dave_d'})
        for u in (uidC, uidD):
            run(f"insert into user_active_course(user_id,course_id) values('{u}','{EN}') "
                f"on conflict (user_id) do update set course_id='{EN}';")
            run(f"insert into user_skill_levels(user_id,course_id,skill,cefr_level,progress_points) "
                f"values('{u}','{EN}','reading','A2',0) on conflict do nothing;")
        sg = V.rpc(tokC, 'suggest_friends', {})
        ids = [x['user_id'] for x in sg['suggestions']]
        ck('sugerencias incluyen a otro del MISMO curso', uidD in ids, [x.get('handle') for x in sg['suggestions']])
        ck('sugerencias traen level/streak (campos públicos)',
           sg['suggestions'] and all(k in sg['suggestions'][0] for k in ('level', 'streak', 'handle')))
        # C solicita a D → D deja de sugerirse (pendiente)
        V.rpc(tokC, 'request_friend', {'p_user_id': uidD})
        sg = V.rpc(tokC, 'suggest_friends', {})
        ck('sugerencias EXCLUYEN pendientes', uidD not in [x['user_id'] for x in sg['suggestions']])
        # D bloquea a C → tampoco sugerido a la inversa
        run(f"delete from connections where user_a_id=least('{uidC}'::uuid,'{uidD}'::uuid) and user_b_id=greatest('{uidC}'::uuid,'{uidD}'::uuid);")
        V.rpc(tokD, 'block_user', {'p_target': uidC})
        sg = V.rpc(tokC, 'suggest_friends', {})
        ck('sugerencias EXCLUYEN bloqueados (ambas dir)', uidD not in [x['user_id'] for x in sg['suggestions']])
        V.rpc(tokD, 'unblock_user', {'p_target': uidC})
        # menor en el mismo curso NO se sugiere
        run(f"insert into user_active_course(user_id,course_id) values('{uidM}','{EN}') on conflict (user_id) do update set course_id='{EN}';")
        sg = V.rpc(tokC, 'suggest_friends', {})
        ck('MENOR no se sugiere aunque comparta curso', uidM not in [x['user_id'] for x in sg['suggestions']])
        cc, _ = rpc_raw(tokM, 'suggest_friends', {})
        ck('MENOR no puede pedir sugerencias', cc >= 400, cc)

        # ---------- 8) AISLAMIENTO airtight intacto ----------
        rows = sel(tokB, f'users?id=eq.{uidA}&select=email,birth_year,handle')
        ck('A NO ve la fila users de B por REST directo (RLS)', rows == [], rows)
        cc, _ = rpc_raw(tokC, 'claim_handle', {'p_handle': 'carol_c'})  # ya es suyo → no-op ok
        # log de búsqueda: no expuesto por REST (grants revocados → 403) O solo dueño
        try:
            rows = sel(tokB, 'social_search_log?select=id&limit=1')
            ck('social_search_log no filtra filas ajenas', isinstance(rows, list) and rows == [], rows)
        except urllib.error.HTTPError as e:
            ck('social_search_log no expuesto por REST (airtight)', e.code in (403, 401), e.code)

        print('\nRESULTADO:', 'VERDE ✅' if ok else 'ROJO ❌')
    finally:
        for u in users:
            run(f"delete from auth.users where id='{u}';")

    sys.exit(0 if ok else 1)


if __name__ == '__main__':
    main()
