# -*- coding: utf-8 -*-
"""Verifica la CERTIFICACION por curso (course-agnostica, mig 144) con cliente real
(Management API + jwt claims, nunca service_role para la logica). Por curso <code>:
  - CADENA A1->A2->B1->B2: dominar las 4 skills al nivel N -> examen -> certificado
    JZC-<N>- con course_id del curso; sube las 4 skills; techo B2 (C1 no certifica).
  - FALLO: si una skill no domina (mastery<0.80) -> NO certifica y esa skill no sube.
  - AISLAMIENTO multicurso: un usuario certifica A1 en INGLES y A1 en <code> -> AMBAS
    certs coexisten (course_id distinto); certificar en un curso no toca el otro.
uso: python verify_cert_chain.py <en|pt|fr|it|de|nl>
"""
import json, sys
from apply_sql import run
import verify_chain as VC  # admin(), rpc(), build_answers(), jq()

LEVELS = ['A1', 'A2', 'B1', 'B2']
RANK = {'A1': 0, 'A2': 1, 'B1': 2, 'B2': 3, 'C1': 4, 'C2': 5}


def course_map():
    rows = json.loads(run("select c.id, l.code from courses c join languages l on l.id=c.target_language_id;")[1])
    return {r['code']: r['id'] for r in rows}


def mk_user(email):
    code, out = VC.admin("POST", "/auth/v1/admin/users",
                         {"email": email, "password": "Test12345!", "email_confirm": True})
    if code in (200, 201):
        uid = json.loads(out)["id"]
    elif code == 422:
        us = json.loads(VC.admin("GET", "/auth/v1/admin/users?page=1&per_page=200")[1])["users"]
        uid = next(u["id"] for u in us if u["email"] == email)
    else:
        sys.exit(f"no user [{code}]: {out}")
    run(f"insert into public.users(id,email) values ('{uid}','{email}') on conflict (id) do nothing;")
    run(f"delete from certificates where user_id='{uid}'; delete from exam_attempts where user_id='{uid}'; "
        f"delete from user_lesson_progress where user_id='{uid}'; delete from user_skill_mastery where user_id='{uid}'; "
        f"delete from user_skill_levels where user_id='{uid}';")
    return uid


def seed_level(uid, course, level, skills_correct):
    """skills_correct: dict skill->items_correct (16 domina, <13 no)."""
    for s in ('reading', 'listening', 'writing', 'speaking'):
        run(f"insert into user_skill_levels(user_id,course_id,skill,cefr_level,progress_points) "
            f"values('{uid}','{course}','{s}','{level}',0) on conflict (user_id,course_id,skill) "
            f"do update set cefr_level='{level}';")
        cc = skills_correct.get(s, 16)
        run(f"insert into user_skill_mastery(user_id,course_id,skill,cefr_level,items_seen,items_correct,lessons_done) "
            f"values('{uid}','{course}','{s}','{level}',16,{cc},1) on conflict (user_id,course_id,skill,cefr_level) "
            f"do update set items_seen=16, items_correct={cc};")
    run(f"insert into user_lesson_progress(user_id,lesson_id,status,best_accuracy,times_completed,completed_at) "
        f"select '{uid}', l.id,'completed',0.9,1,now() from lessons l join units u on u.id=l.unit_id "
        f"where u.course_id='{course}' and u.cefr_level='{level}' and l.type='checkpoint' "
        f"on conflict (user_id,lesson_id) do update set status='completed';")


def certify(uid, course, level, only_skill=None):
    ex = VC.rpc(uid, f"select start_level_exam('{level}');")
    ids = [it['id'] for it in ex['items'] if only_skill is None or it['skill'] == only_skill]
    ans = VC.build_answers(ids)
    lvl_arg = f", '{level}'" if True else ""
    res = VC.rpc(uid, f"select submit_level_exam({VC.jq(ans)}, 120, '{level}');")
    return ex, res


def main():
    code = (sys.argv[1] if len(sys.argv) > 1 else 'pt').lower()
    CM = course_map()
    assert code in CM, f"curso desconocido: {code}"
    course, en = CM[code], CM['en']
    ok = True

    def ck(n, c, d=''):
        nonlocal ok
        print(('  OK  ' if c else '  XX  ') + n + ('  ' + str(d) if d else ''))
        ok = ok and c

    print(f"=== CERTIFICACION curso '{code}' ({course[:8]}) ===")
    # ---------- CADENA A1->B2 ----------
    uid = mk_user(f"cert_{code}_chain@jezici.test")
    try:
        VC.rpc(uid, f"select set_active_course('{course}');")
        for level in LEVELS:
            seed_level(uid, course, level, {})  # domina las 4
            st = VC.rpc(uid, "select level_exam_status();")
            ck(f"{level}: examen desbloqueado (dominio 4 skills)", st.get('level') == level and st.get('unlocked') is True, st.get('unlocked'))
            ex, res = certify(uid, course, level)
            ck(f"{level}: examen sirve 20 items del nivel", ex.get('item_count', 0) >= 18 and set(it['cefr_level'] for it in ex['items']) == {level}, {'n': ex.get('item_count')})
            cert = res.get('certificate') or {}
            ck(f"{level}: certificado emitido JZC-{level}-", (cert.get('folio') or '').startswith(f'JZC-{level}-'), cert.get('folio'))
            ck(f"{level}: sube las 4 skills (raised)", set(res.get('raised_skills') or []) == {'reading', 'listening', 'writing', 'speaking'}, res.get('raised_skills'))
        # cert rows todas del curso correcto
        cc = json.loads(run(f"select cefr_level, course_id, folio from certificates where user_id='{uid}' order by cefr_level;")[1])
        ck("las 4 certs (A1-B2) son del curso correcto", len(cc) == 4 and all(r['course_id'] == course for r in cc), [(r['cefr_level'], r['course_id'][:8]) for r in cc])
        # techo B2: jz_resolve capa B2 -> no hay examen C1
        run(f"update user_skill_levels set cefr_level='C1' where user_id='{uid}';")
        stc = VC.rpc(uid, "select level_exam_status();")
        ck("techo honesto: resuelve a B2 (C1 no certifica)", stc.get('level') == 'B2', stc.get('level'))
    finally:
        VC.admin("DELETE", f"/auth/v1/admin/users/{uid}")

    # ---------- FALLO: falta una skill ----------
    uid = mk_user(f"cert_{code}_fail@jezici.test")
    try:
        VC.rpc(uid, f"select set_active_course('{course}');")
        seed_level(uid, course, 'A1', {'speaking': 8})  # speaking mastery 0.5 < 0.80
        # ANTES del examen: el perfil ya muestra qué skill falta (speaking no exam-ready)
        gm = VC.rpc(uid, "select get_skill_mastery();")
        ready = {s['skill']: s['exam_ready'] for s in gm.get('skills', [])}
        ck("FALLO: se ve qué skill falta (speaking exam_ready=false, resto true)",
           ready.get('speaking') is False and all(ready.get(k) is True for k in ('reading', 'listening', 'writing')), ready)
        ex, res = certify(uid, course, 'A1')
        ck("FALLO: sin dominar speaking NO certifica", (res.get('certificate') or {}).get('folio') is None, res.get('certificate'))
        ck("FALLO: speaking NO sube (queda A1)", 'speaking' not in (res.get('raised_skills') or []), res.get('raised_skills'))
        ncerts = json.loads(run(f"select count(*) n from certificates where user_id='{uid}';")[1])[0]['n']
        ck("FALLO: 0 certificados emitidos", ncerts == 0, ncerts)
    finally:
        VC.admin("DELETE", f"/auth/v1/admin/users/{uid}")

    # ---------- AISLAMIENTO multicurso (poliglota) ----------
    if code != 'en':
        uid = mk_user(f"cert_{code}_iso@jezici.test")
        try:
            # certifica A1 en INGLES
            VC.rpc(uid, f"select set_active_course('{en}');")
            seed_level(uid, en, 'A1', {})
            _, res_en = certify(uid, en, 'A1')
            en_ok = (res_en.get('certificate') or {}).get('folio', '').startswith('JZC-A1-')
            # certifica A1 en <code>
            VC.rpc(uid, f"select set_active_course('{course}');")
            seed_level(uid, course, 'A1', {})
            _, res_c = certify(uid, course, 'A1')
            c_ok = (res_c.get('certificate') or {}).get('folio', '').startswith('JZC-A1-')
            ck("AISLAMIENTO: poliglota certifica A1 en EN y en " + code, en_ok and c_ok, {'en': en_ok, code: c_ok})
            rows = json.loads(run(f"select cefr_level, course_id from certificates where user_id='{uid}' and cefr_level='A1' order by course_id;")[1])
            courses_with_a1 = set(r['course_id'] for r in rows)
            ck("AISLAMIENTO: 2 certs A1 coexisten (en + " + code + ")", {en, course} <= courses_with_a1 and len(rows) == 2, [r['course_id'][:8] for r in rows])
            # el nivel de skills de EN no cambia al certificar <code> (cada curso su fila)
            en_lv = json.loads(run(f"select skill, cefr_level from user_skill_levels where user_id='{uid}' and course_id='{en}' order by skill;")[1])
            ck("AISLAMIENTO: skills EN quedan en A2 (subieron por su propio examen, no por " + code + ")", all(r['cefr_level'] == 'A2' for r in en_lv), [(r['skill'], r['cefr_level']) for r in en_lv])
        finally:
            VC.admin("DELETE", f"/auth/v1/admin/users/{uid}")

    print('\n' + ('TODO VERDE' if ok else 'HAY FALLOS'))
    sys.exit(0 if ok else 1)


if __name__ == '__main__':
    main()
