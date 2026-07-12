# -*- coding: utf-8 -*-
"""Verifica T5 (mig 153) con cliente REAL (JWT):
  - set_profile_required: guarda avatar_color + país + género + cumpleaños;
    RECHAZA server-side si falta género o cumpleaños (día/mes) o nombre; el AÑO
    del age gate queda intacto.
  - get_courses.started: refleja qué cursos tiene el usuario (con plan).
  - AÑADIR IDIOMA: set_active_course(nuevo) + create_plan siembra ese curso SIN
    tocar el progreso del anterior (aislamiento multicurso).
uso: python verify_t5.py
"""
import urllib.request, urllib.error, json, sys
import verify_placement_serious as V
from apply_sql import run
EN = '20000000-0000-0000-0000-000000000001'
PT = '20000000-0000-0000-0000-000000000002'


def rpc_raw(tok, name, body):
    try:
        return 200, V.rpc(tok, name, body)
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode()


def q(sql):
    return json.loads(run(sql)[1])


def main():
    ok = True
    def ck(n, c, d=''):
        nonlocal ok
        print(('  OK  ' if c else '  XX  ') + n + (('  ' + str(d)) if d != '' else ''))
        ok = ok and c

    users = []
    try:
        tok, uid = V.mk_user('t5_a@test.jezici.dev'); users.append(uid)
        V.rpc(tok, 'submit_age_gate', {'p_birth_year': 1994})  # AÑO del age gate

        # ---------- 1) set_profile_required: obligatorios ----------
        # Falta género → rechazo
        cc, body = rpc_raw(tok, 'set_profile_required', {
            'p_name': 'Ana', 'p_gender': '', 'p_birthday_day': 9, 'p_birthday_month': 3})
        ck('género vacío → rechazado (gender_required)', cc >= 400 and 'gender_required' in str(body), cc)
        # Falta cumpleaños → rechazo
        cc, body = rpc_raw(tok, 'set_profile_required', {
            'p_name': 'Ana', 'p_gender': 'female', 'p_birthday_day': None, 'p_birthday_month': 3})
        ck('cumpleaños incompleto → rechazado (birthday_required)', cc >= 400 and 'birthday_required' in str(body), cc)
        # Falta nombre → rechazo
        cc, body = rpc_raw(tok, 'set_profile_required', {
            'p_name': '   ', 'p_gender': 'female', 'p_birthday_day': 9, 'p_birthday_month': 3})
        ck('nombre vacío → rechazado (name_required)', cc >= 400 and 'name_required' in str(body), cc)
        # Completo → guarda
        r = V.rpc(tok, 'set_profile_required', {
            'p_name': 'Ana', 'p_gender': 'female', 'p_birthday_day': 9, 'p_birthday_month': 3,
            'p_country': 'MX', 'p_avatar_color': '#FF6B6B'})
        ck('perfil completo → guarda', r.get('name') == 'Ana' and r.get('gender') == 'female', r)
        ck('avatar_color persiste normalizado', r.get('avatar_color') == '#FF6B6B', r.get('avatar_color'))
        ck('país persiste', r.get('country') == 'MX', r.get('country'))
        ck('cumpleaños día/mes persisten', r.get('birthday_day') == 9 and r.get('birthday_month') == 3, r)
        ck('el AÑO del age gate queda INTACTO', r.get('birth_year') == 1994, r.get('birth_year'))
        # género inválido → rechazo (no se cuela basura)
        cc, _ = rpc_raw(tok, 'set_profile_required', {
            'p_name': 'Ana', 'p_gender': 'xyz', 'p_birthday_day': 9, 'p_birthday_month': 3})
        ck('género fuera de whitelist → rechazado', cc >= 400, cc)

        # ---------- 2) get_courses.started ----------
        V.rpc(tok, 'set_active_course', {'p_course_id': EN})
        # sembramos plan del curso activo (EN) como haría el onboarding
        def make_plan():
            return V.rpc(tok, 'create_plan', {
                'p_coach_style': 'suave', 'p_intensity': 3, 'p_current_level': 'A1',
                'p_goal_level': 'B1', 'p_daily_minutes': 15, 'p_days_per_week': 5,
                'p_motive': '', 'p_deadline': None, 'p_estimated_hours': 100,
                'p_estimated_completion': '2027-01-01',
                'p_skill_levels': {'reading': 'A1', 'listening': 'A1', 'writing': 'A1', 'speaking': 'A1'}})
        make_plan()
        courses = V.rpc(tok, 'get_courses', {})
        en = next(c for c in courses if c['target'] == 'en')
        pt = next(c for c in courses if c['target'] == 'pt')
        ck('get_courses: EN started=true (tiene plan)', en.get('started') is True, en.get('started'))
        ck('get_courses: PT started=false (aún no)', pt.get('started') is False, pt.get('started'))
        started = [c['target'] for c in courses if c.get('started')]
        ck('solo 1 idioma iniciado hasta ahora', started == ['en'], started)

        # progreso en EN para probar aislamiento (completar una lección)
        run(f"""insert into user_skill_levels(user_id,course_id,skill,cefr_level,progress_points)
                values('{uid}','{EN}','reading','A2',40) on conflict do nothing;""")
        en_before = q(f"select cefr_level, progress_points from user_skill_levels where user_id='{uid}' and course_id='{EN}' and skill='reading'")[0]

        # ---------- 3) AÑADIR IDIOMA (pt) sin tocar EN ----------
        V.rpc(tok, 'set_active_course', {'p_course_id': PT})
        make_plan()  # crea plan de PT (curso activo)
        courses = V.rpc(tok, 'get_courses', {})
        started = sorted(c['target'] for c in courses if c.get('started'))
        ck('tras añadir PT: 2 idiomas iniciados (en+pt)', started == ['en', 'pt'], started)
        ck('PT ahora es el activo', next(c for c in courses if c['target'] == 'pt')['active'] is True)
        # aislamiento: EN intacto
        en_after = q(f"select cefr_level, progress_points from user_skill_levels where user_id='{uid}' and course_id='{EN}' and skill='reading'")[0]
        ck('AISLAMIENTO: el progreso de EN NO se tocó al añadir PT',
           en_after == en_before, {'before': en_before, 'after': en_after})
        # los planes de ambos cursos coexisten
        plans = q(f"select course_id from user_plans where user_id='{uid}'")
        ck('coexisten los planes de EN y PT', len({p['course_id'] for p in plans}) == 2, len(plans))
        # volver a EN = resume (sin resetear); su plan sigue
        V.rpc(tok, 'set_active_course', {'p_course_id': EN})
        en_resume = q(f"select cefr_level, progress_points from user_skill_levels where user_id='{uid}' and course_id='{EN}' and skill='reading'")[0]
        ck('volver a EN preserva su progreso', en_resume == en_before, en_resume)

        print('\nRESULTADO:', 'VERDE ✅' if ok else 'ROJO ❌')
    finally:
        for u in users:
            run(f"delete from auth.users where id='{u}';")

    sys.exit(0 if ok else 1)


if __name__ == '__main__':
    main()
