"""Verifica el TECHO DETERMINISTA C1 con cliente real (RPC + jwt.claims):
un usuario PLENAMENTE elegible para C1 (4 skills en C1, dominio C1 sembrado, los 6
checkpoints C1 completados) AÚN así NO puede formar/aprobar examen C1 ni obtener
JZC-C1. Lo único que lo bloquea es el tope (mig 064). Limpia al final."""
import json, sys
from apply_sql import run
from verify_chain import admin, rpc, build_answers

EMAIL = "verify_c1_cap@jezici.test"

def main():
    code, out = admin("POST", "/auth/v1/admin/users", {"email": EMAIL, "password": "Test12345!", "email_confirm": True})
    if code in (200, 201):
        uid = json.loads(out)["id"]
    elif code == 422:
        _, o2 = admin("GET", "/auth/v1/admin/users?page=1&per_page=200")
        uid = next(u["id"] for u in json.loads(o2)["users"] if u["email"] == EMAIL)
    else:
        sys.exit(f"no se pudo crear usuario [{code}]: {out}")
    print("uid:", uid)
    run(f"insert into public.users(id,email) values ('{uid}','{EMAIL}') on conflict (id) do nothing;")
    course = json.loads(run("select id from courses where is_active order by created_at limit 1;")[1])[0]["id"]
    rpc(uid, "select start_course();")

    # ── Hacerlo PLENAMENTE elegible para C1 (todo lo que el gate normal exige) ──
    run(f"update user_skill_levels set cefr_level='C1', progress_points=0 where user_id='{uid}';")
    for s in ("reading", "listening", "writing", "speaking"):
        run(f"""insert into user_skill_mastery(user_id,course_id,skill,cefr_level,items_seen,items_correct,lessons_done)
                values ('{uid}','{course}','{s}','C1',20,20,1)
                on conflict (user_id,course_id,skill,cefr_level) do update set items_seen=20, items_correct=20;""")
    run(f"""insert into user_lesson_progress(user_id, lesson_id, status, best_accuracy, times_completed, completed_at)
            select '{uid}', l.id, 'completed', 0.95, 1, now()
            from lessons l join units u on u.id=l.unit_id
            where u.course_id='{course}' and u.cefr_level='C1' and l.type='checkpoint'
            on conflict (user_id, lesson_id) do update set status='completed';""")

    ok = True
    # 1) resolve TOPE: el nivel objetivo del examen es B2, NO C1.
    st = rpc(uid, "select level_exam_status();")
    print("\n[1] level_exam_status() ->", {k: st[k] for k in ('level', 'unlocked', 'has_certificate')})
    if st["level"] != "B2":
        ok = False; print("  FALLO: el nivel objetivo debería topar en B2, es", st["level"])
    else:
        print("  PASS: nivel objetivo topado en B2")

    # 2) status C1: unlocked=false pese a elegibilidad total.
    c1 = rpc(uid, "select level_exam_status('C1');")
    print("\n[2] level_exam_status('C1') ->", {k: c1[k] for k in ('level', 'units_total', 'units_done', 'skills_ready', 'unlocked')})
    if c1["unlocked"] is not False:
        ok = False; print("  FALLO: C1 NO debe desbloquear; unlocked=", c1["unlocked"])
    else:
        print("  PASS: C1 unlocked=false aun con 6/6 checkpoints y 4 skills listos")

    # 3) start_level_exam('C1') → 'level exam locked'.
    code, o = run(f"set local role authenticated; set local \"request.jwt.claims\" = '{{\"sub\":\"{uid}\"}}'; select start_level_exam('C1');")
    print("\n[3] start_level_exam('C1') -> code", code)
    if code in (200, 201) or "locked" not in o.lower():
        ok = False; print("  FALLO: start C1 NO fue rechazado:", o[:160])
    else:
        print("  PASS: start C1 rechazado (level exam locked)")

    # 4) submit_level_exam(respuestas CORRECTAS de ítems C1, 'C1') → 'locked', SIN cert.
    items = json.loads(run(f"""select id from content_items
        where course_id='{course}' and cefr_level='C1' and skill in ('reading','writing')
          and type in ('multiple_choice','cloze','translation','reorder') limit 6;""")[1])
    ids = [r["id"] for r in items]
    answers = build_answers(ids)
    code, o = run(f"set local role authenticated; set local \"request.jwt.claims\" = '{{\"sub\":\"{uid}\"}}'; "
                  f"select submit_level_exam('{json.dumps(answers)}'::jsonb, 30, 'C1');")
    print("\n[4] submit_level_exam(correctas, 'C1') -> code", code)
    if code in (200, 201) or "locked" not in o.lower():
        ok = False; print("  FALLO: submit C1 NO fue rechazado:", o[:160])
    else:
        print("  PASS: submit C1 rechazado (level exam locked)")
    cert = json.loads(run(f"select count(*) c from certificates where user_id='{uid}' and cefr_level='C1';")[1])[0]["c"]
    print("  certs C1 del usuario:", cert)
    if cert != 0:
        ok = False; print("  FALLO: se acuñó un cert C1")

    # limpieza
    run(f"delete from certificates where user_id='{uid}'; delete from exam_attempts where user_id='{uid}'; "
        f"delete from user_lesson_progress where user_id='{uid}'; delete from user_skill_mastery where user_id='{uid}';")
    admin("DELETE", f"/auth/v1/admin/users/{uid}")
    print("\n[OK] TECHO C1 verificado con cliente real" if ok else "\n[FALLO] revisar arriba")
    sys.exit(0 if ok else 1)

if __name__ == "__main__":
    main()
