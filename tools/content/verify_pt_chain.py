"""Verifica la cadena es→pt (A1) end-to-end: set_active_course(pt) → completar
checkpoints A1 (curso pt) + dominio → examen de nivel A1 → certificado JZC-A1
(curso pt) → las 4 habilidades pasan a A2. Usa las RPC reales con un usuario de
prueba fresco (sin colisión de cert con el curso es→en). Limpia al final.

Demuestra que el multi-curso funciona: jz_active_course() resuelve el curso pt, el
examen de nivel selecciona ítems pt (cefr A1), y la certificación opera por curso."""
import json, urllib.request, urllib.error, sys
from apply_sql import run, SERVICE, SUPABASE_URL

PT_COURSE = '20000000-0000-0000-0000-000000000002'

def admin(method, path, body=None):
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(SUPABASE_URL + path, data=data, method=method)
    req.add_header("apikey", SERVICE); req.add_header("Authorization", "Bearer " + SERVICE)
    req.add_header("Content-Type", "application/json")
    try:
        with urllib.request.urlopen(req, timeout=60) as r:
            return r.status, r.read().decode()
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode()

def rpc(uid, call):
    q = (f"set local role authenticated; "
         f"set local \"request.jwt.claims\" = '{{\"sub\":\"{uid}\"}}'; {call}")
    code, out = run(q)
    if code not in (200, 201):
        sys.exit(f"RPC FALLÓ [{code}]: {out[:400]}\nQUERY: {call}")
    try:
        data = json.loads(out)
    except Exception:
        return out
    if isinstance(data, list) and data and isinstance(data[0], dict) and len(data[0]) == 1:
        return next(iter(data[0].values()))
    return data

def jq(obj):
    return "'" + json.dumps(obj).replace("'", "''") + "'::jsonb"

def build_answers(item_ids):
    inlist = ",".join("'" + i + "'" for i in item_ids)
    code, out = run(f"select id, type, correct_answer from content_items where id in ({inlist});")
    by_id = {r["id"]: r for r in json.loads(out)}
    answers = []
    for iid in item_ids:
        r = by_id.get(iid)
        if not r: continue
        t, c = r["type"], r["correct_answer"] or {}
        if t == "match":
            ans = {str(k): p[1] for k, p in enumerate(c.get("pairs", []))}
        elif t == "speaking_read_aloud":
            ans = c.get("expected", "ok")
        else:
            ans = c.get("value", "")
        answers.append({"item_id": iid, "answer": ans})
    return answers

def main():
    print("== usuario de prueba (pt) ==")
    code, out = admin("POST", "/auth/v1/admin/users",
                      {"email": "verify_pt_chain@jezici.test", "password": "Test12345!", "email_confirm": True})
    if code in (200, 201):
        uid = json.loads(out)["id"]
    elif code == 422:
        code2, out2 = admin("GET", "/auth/v1/admin/users?page=1&per_page=200")
        uid = next(u["id"] for u in json.loads(out2).get("users", []) if u["email"] == "verify_pt_chain@jezici.test")
    else:
        sys.exit(f"no se pudo crear usuario [{code}]: {out}")
    print("uid:", uid)
    run(f"insert into public.users(id,email) values ('{uid}','verify_pt_chain@jezici.test') on conflict (id) do nothing;")
    run(f"delete from certificates where user_id='{uid}'; delete from exam_attempts where user_id='{uid}'; "
        f"delete from user_lesson_progress where user_id='{uid}'; delete from user_skill_mastery where user_id='{uid}'; "
        f"delete from user_skill_levels where user_id='{uid}'; delete from user_active_course where user_id='{uid}';")

    print("\n== set_active_course(pt) ==")
    print(rpc(uid, f"select set_active_course('{PT_COURSE}');"))
    # confirmar que el curso activo es pt
    ac = rpc(uid, "select jz_active_course();")
    assert ac == PT_COURSE, f"el curso activo debería ser pt: {ac}"
    print("  curso activo:", ac)

    # Completar A1 (pt): 6 checkpoints + dominio A1.
    run(f"""insert into user_lesson_progress(user_id, lesson_id, status, best_accuracy, times_completed, completed_at)
            select '{uid}', l.id, 'completed', 0.9, 1, now()
            from lessons l join units u on u.id=l.unit_id
            where u.course_id='{PT_COURSE}' and u.cefr_level='A1' and l.type='checkpoint'
            on conflict (user_id, lesson_id) do update set status='completed';""")
    for s in ("reading", "listening", "writing", "speaking"):
        run(f"""insert into user_skill_mastery(user_id,course_id,skill,cefr_level,items_seen,items_correct,lessons_done)
                values ('{uid}','{PT_COURSE}','{s}','A1',16,16,1)
                on conflict (user_id,course_id,skill,cefr_level) do update set items_seen=16, items_correct=16;""")

    print("\n== A1 (pt): level_exam_status ==")
    st = rpc(uid, "select level_exam_status();")
    print(st)
    assert st["level"] == "A1" and st["unlocked"] is True, "A1 (pt) debería estar desbloqueado"

    print("\n== A1 (pt): start_level_exam ==")
    ex = rpc(uid, "select start_level_exam();")
    print({k: ex[k] for k in ("exam_id", "level", "item_count")})
    assert ex["level"] == "A1" and ex["item_count"] >= 18
    ids = [it["id"] for it in ex["items"]]
    # Los ítems del examen pt deben pertenecer al curso pt (ids del namespace d1…).
    assert all(i.startswith("d1") for i in ids), f"los ítems del examen pt deben ser del curso pt: {ids[:3]}"

    print("\n== A1 (pt): submit_level_exam (correctas) ==")
    res = rpc(uid, f"select submit_level_exam({jq(build_answers(ids))}, 120);")
    print({k: res.get(k) for k in ("passed", "level", "leveled_up", "raised_skills")})
    print("certificado:", (res.get("certificate") or {}).get("folio"))
    assert res["passed"] is True and res["level"] == "A1"
    assert res.get("leveled_up") is True and set(res.get("raised_skills") or []) == {"reading", "listening", "writing", "speaking"}
    assert (res.get("certificate") or {}).get("folio", "").startswith("JZC-A1-"), "debió emitir cert A1 (pt)"
    rows = json.loads(run(f"select skill, cefr_level from user_skill_levels where user_id='{uid}' and course_id='{PT_COURSE}' order by skill;")[1])
    assert all(r["cefr_level"] == "A2" for r in rows) and len(rows) == 4, f"las 4 (pt) deben pasar a A2: {rows}"
    print("  OK: A1 (pt) certificado, las 4 habilidades en A2")

    print("\n== limpieza ==")
    admin("DELETE", f"/auth/v1/admin/users/{uid}")
    print("\n[OK] CADENA es-pt A1 (examen + cert + per-skill) VERIFICADA (multi-curso)")

if __name__ == "__main__":
    main()
