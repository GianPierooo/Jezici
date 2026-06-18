"""Verifica la cadena completa A1 → examen A1 → certificado → A2 → examen A2
ejercitando las RPC reales (level_exam_status / start_level_exam /
submit_level_exam) con un usuario de prueba (jwt claims). Limpia al final."""
import json, urllib.request, urllib.error, sys
from apply_sql import run, SERVICE, SUPABASE_URL  # secretos desde .env/entorno

def admin(method, path, body=None):
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(SUPABASE_URL + path, data=data, method=method)
    req.add_header("apikey", SERVICE)
    req.add_header("Authorization", "Bearer " + SERVICE)
    req.add_header("Content-Type", "application/json")
    try:
        with urllib.request.urlopen(req, timeout=60) as r:
            return r.status, r.read().decode()
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode()

def sql_str(s):
    return "'" + s.replace("'", "''") + "'"

def rpc(uid, call):
    # set local + claim + la llamada, todo en una transacción (Management API).
    q = (f"set local role authenticated; "
         f"set local \"request.jwt.claims\" = '{{\"sub\":\"{uid}\"}}'; {call}")
    code, out = run(q)
    if code not in (200, 201):
        sys.exit(f"RPC FALLÓ [{code}]: {out[:400]}\nQUERY: {call}")
    try:
        data = json.loads(out)
    except Exception:
        return out
    # El endpoint devuelve [{<funcname>: <valor>}] → desempaquetar el valor.
    if isinstance(data, list) and data and isinstance(data[0], dict) and len(data[0]) == 1:
        return next(iter(data[0].values()))
    return data

def jq(obj):
    return sql_str(json.dumps(obj)) + "::jsonb"

def build_answers(item_ids):
    """Construye respuestas correctas leyendo content_items.correct_answer."""
    inlist = ",".join("'" + i + "'" for i in item_ids)
    code, out = run(f"select id, type, correct_answer from content_items where id in ({inlist});")
    rows = json.loads(out)
    by_id = {r["id"]: r for r in rows}
    answers = []
    for iid in item_ids:
        r = by_id.get(iid)
        if not r:
            continue
        t, c = r["type"], r["correct_answer"] or {}
        if t == "match":
            pairs = c.get("pairs", [])
            ans = {str(k): p[1] for k, p in enumerate(pairs)}
        elif t == "speaking_read_aloud":
            ans = c.get("expected", "ok")
        else:  # mc, tf, listening, cloze, translation, word_bank, reorder
            ans = c.get("value", "")
        answers.append({"item_id": iid, "answer": ans})
    return answers

def main():
    print("== creando usuario de prueba ==")
    code, out = admin("POST", "/auth/v1/admin/users",
                      {"email": "verify_a2_chain@jezici.test", "password": "Test12345!", "email_confirm": True})
    if code in (200, 201):
        uid = json.loads(out)["id"]
    elif code == 422:  # ya existe → buscarlo
        code2, out2 = admin("GET", "/auth/v1/admin/users?page=1&per_page=200")
        users = json.loads(out2).get("users", [])
        uid = next(u["id"] for u in users if u["email"] == "verify_a2_chain@jezici.test")
    else:
        sys.exit(f"no se pudo crear usuario [{code}]: {out}")
    print("uid:", uid)
    run(f"insert into public.users(id,email) values ('{uid}','verify_a2_chain@jezici.test') on conflict (id) do nothing;")
    # estado limpio para reintentos (incluye el dominio del modelo nuevo, mig 040).
    run(f"delete from certificates where user_id='{uid}'; delete from exam_attempts where user_id='{uid}'; "
        f"delete from user_lesson_progress where user_id='{uid}'; "
        f"delete from user_skill_mastery where user_id='{uid}'; "
        f"update user_skill_levels set cefr_level='A1', progress_points=0 where user_id='{uid}';")

    course = run("select id from courses where is_active order by created_at limit 1;")
    course = json.loads(course[1])[0]["id"]

    def seed_mastery(level, correct=16):
        """Modelo nuevo (mig 040): el examen se desbloquea por DOMINIO, no por nivel.
        Sembramos dominio >= gate (avg mastery_pct >= 0.5) para las 4 habilidades."""
        for s in ("reading", "listening", "writing", "speaking"):
            run(f"""insert into user_skill_mastery(user_id,course_id,skill,cefr_level,items_seen,items_correct,lessons_done)
                    values ('{uid}','{course}','{s}','{level}',{correct},{correct},1)
                    on conflict (user_id,course_id,skill,cefr_level)
                    do update set items_seen={correct}, items_correct={correct};""")

    print("\n== start_course ==")
    print(rpc(uid, "select start_course();"))

    # SEGURIDAD: sin dominio ni checkpoints, un atajo RPC a submit_level_exam NO
    # debe poder certificar (la compuerta server-side se revalida al enviar).
    print("\n== seguridad: submit_level_exam sin compuerta debe RECHAZAR ==")
    code, out = run(
        "set local role authenticated; "
        f"set local \"request.jwt.claims\" = '{{\"sub\":\"{uid}\"}}'; "
        "select submit_level_exam('[]'::jsonb, 10);")
    assert code not in (200, 201) and "locked" in out.lower(), \
        f"submit_level_exam debió rechazar (level exam locked); code={code} out={out[:200]}"
    print("  PASS: rechazado ->", out[out.lower().find("level exam locked"):][:40] if "locked" in out.lower() else out[:80])

    # Marcar los 6 checkpoints A1 como completados (simula terminar A1).
    run(f"""insert into user_lesson_progress(user_id, lesson_id, status, best_accuracy, times_completed, completed_at)
            select '{uid}', l.id, 'completed', 0.9, 1, now()
            from lessons l join units u on u.id=l.unit_id
            where u.cefr_level='A1' and l.type='checkpoint'
            on conflict (user_id, lesson_id) do update set status='completed';""")
    seed_mastery("A1")  # dominio A1 alto → desbloquea el examen A1 (no por nivel).

    print("\n== A1: level_exam_status (gate por DOMINIO) ==")
    st = rpc(uid, "select level_exam_status();")
    print(st)
    assert st["level"] == "A1" and st["unlocked"] is True, "A1 debería estar desbloqueado (dominio)"
    assert st.get("mastery_avg", 0) >= 0.5, f"mastery_avg debería >= 0.5: {st.get('mastery_avg')}"

    print("\n== A1: start_level_exam ==")
    ex = rpc(uid, "select start_level_exam();")
    print({k: ex[k] for k in ("exam_id", "level", "item_count")})
    assert ex["level"] == "A1" and ex["item_count"] >= 18
    ids = [it["id"] for it in ex["items"]]
    answers = build_answers(ids)
    print("\n== A1: submit_level_exam (respuestas correctas) ==")
    res = rpc(uid, f"select submit_level_exam({jq(answers)}, 120);")
    print({k: res.get(k) for k in ("passed", "level", "leveled_up", "new_level", "raised_skills")})
    print("certificado:", (res.get("certificate") or {}).get("folio"))
    assert res["passed"] is True and res["level"] == "A1", "A1 debió aprobar"
    # v2 PER-SKILL: aprobar TODAS las secciones del examen A1 sube las 4 skills A1→A2.
    assert res.get("leveled_up") is True, f"el examen A1 debió subir alguna skill: {res.get('leveled_up')}"
    assert set(res.get("raised_skills") or []) == {"reading", "listening", "writing", "speaking"}, \
        f"deben subir las 4 secciones: {res.get('raised_skills')}"
    rows_a1 = json.loads(run(f"select skill, cefr_level from user_skill_levels where user_id='{uid}' order by skill;")[1])
    assert all(r["cefr_level"] == "A2" for r in rows_a1), f"las 4 deben pasar a A2 tras examen A1: {rows_a1}"
    # Certificado A1 cuando las 4 cruzan A1 (= todas en A2).
    assert (res.get("certificate") or {}).get("folio", "").startswith("JZC-A1-"), "debió emitir cert A1"

    print("\n== tras examen A1: level_exam_status (apunta a A2, aún bloqueado) ==")
    st2 = rpc(uid, "select level_exam_status();")
    print(st2)
    assert st2["level"] == "A2", "el nivel del examen ahora es A2 (mínimo en curso)"
    assert st2["unlocked"] is False, "A2 aún no listo (faltan checkpoints + dominio A2)"

    # Completar A2: 6 checkpoints + DOMINIO A2 (piso) para desbloquear el examen A2.
    run(f"""insert into user_lesson_progress(user_id, lesson_id, status, best_accuracy, times_completed, completed_at)
            select '{uid}', l.id, 'completed', 0.9, 1, now()
            from lessons l join units u on u.id=l.unit_id
            where u.cefr_level='A2' and l.type='checkpoint'
            on conflict (user_id, lesson_id) do update set status='completed';""")
    seed_mastery("A2")  # dominio A2 ≥ 0.80 → desbloquea el examen A2.

    print("\n== A2: level_exam_status ==")
    st3 = rpc(uid, "select level_exam_status();")
    print(st3)
    assert st3["level"] == "A2" and st3["unlocked"] is True, "A2 debería estar desbloqueado (dominio)"

    print("\n== A2: start_level_exam ==")
    ex2 = rpc(uid, "select start_level_exam();")
    print({k: ex2[k] for k in ("exam_id", "level", "item_count")})
    assert ex2["level"] == "A2" and ex2["item_count"] >= 18
    lv = set(it["cefr_level"] for it in ex2["items"])
    print("niveles de ítems:", lv)
    assert lv == {"A2"}
    ids2 = [it["id"] for it in ex2["items"]]
    answers2 = build_answers(ids2)
    print("\n== A2: submit_level_exam (respuestas correctas) ==")
    res2 = rpc(uid, f"select submit_level_exam({jq(answers2)}, 120);")
    print({k: res2.get(k) for k in ("passed", "level", "leveled_up", "new_level", "raised_skills")})
    print("certificado:", (res2.get("certificate") or {}).get("folio"))
    assert res2["passed"] is True and res2["level"] == "A2"
    assert (res2.get("certificate") or {}).get("folio", "").startswith("JZC-A2-")
    # Aprobar el examen A2 sube las 4 secciones A2→B1.
    assert res2.get("leveled_up") is True and res2.get("new_level") == "A2", \
        f"el examen A2 debió subir nivel: {res2.get('leveled_up')}/{res2.get('new_level')}"
    rows = json.loads(run(f"select skill, cefr_level from user_skill_levels where user_id='{uid}' order by skill;")[1])
    print("niveles tras examen A2:", rows)
    assert all(r["cefr_level"] == "B1" for r in rows) and len(rows) == 4, \
        f"las 4 habilidades deben estar en B1 tras examen A2: {rows}"

    # ── B1 (Unidades 13–18 sembradas): la cadena llega hasta certificar B1 ──────
    print("\n== B1: completar checkpoints + DOMINIO B1 ==")
    run(f"""insert into user_lesson_progress(user_id, lesson_id, status, best_accuracy, times_completed, completed_at)
            select '{uid}', l.id, 'completed', 0.9, 1, now()
            from lessons l join units u on u.id=l.unit_id
            where u.cefr_level='B1' and l.type='checkpoint'
            on conflict (user_id, lesson_id) do update set status='completed';""")
    seed_mastery("B1")
    stB1 = rpc(uid, "select level_exam_status();")
    print(stB1)
    assert stB1["level"] == "B1" and stB1["unlocked"] is True, "B1 debería estar desbloqueado (dominio)"
    exB1 = rpc(uid, "select start_level_exam();")
    print({k: exB1[k] for k in ("exam_id", "level", "item_count")})
    assert exB1["level"] == "B1" and exB1["item_count"] >= 18
    lvB1 = set(it["cefr_level"] for it in exB1["items"])
    assert lvB1 == {"B1"}, f"los ítems del examen B1 deben ser B1: {lvB1}"
    resB1 = rpc(uid, f"select submit_level_exam({jq(build_answers([it['id'] for it in exB1['items']]))}, 120);")
    print({k: resB1.get(k) for k in ("passed", "level", "leveled_up", "raised_skills")})
    print("certificado:", (resB1.get("certificate") or {}).get("folio"))
    assert resB1["passed"] is True and resB1["level"] == "B1"
    assert resB1.get("leveled_up") is True and set(resB1.get("raised_skills") or []) == {"reading", "listening", "writing", "speaking"}
    assert (resB1.get("certificate") or {}).get("folio", "").startswith("JZC-B1-"), "debió emitir cert B1"
    rowsB1 = json.loads(run(f"select skill, cefr_level from user_skill_levels where user_id='{uid}' order by skill;")[1])
    assert all(r["cefr_level"] == "B2" for r in rowsB1), f"las 4 deben pasar a B2 tras examen B1: {rowsB1}"
    print("  OK: B1 certificado, las 4 habilidades en B2")

    # ── B2 (Unidades 19–24 sembradas): la cadena cierra certificando B2 ─────────
    print("\n== B2: completar checkpoints + DOMINIO B2 ==")
    run(f"""insert into user_lesson_progress(user_id, lesson_id, status, best_accuracy, times_completed, completed_at)
            select '{uid}', l.id, 'completed', 0.9, 1, now()
            from lessons l join units u on u.id=l.unit_id
            where u.cefr_level='B2' and l.type='checkpoint'
            on conflict (user_id, lesson_id) do update set status='completed';""")
    seed_mastery("B2")
    stB2 = rpc(uid, "select level_exam_status();")
    print(stB2)
    assert stB2["level"] == "B2" and stB2["unlocked"] is True, "B2 debería estar desbloqueado (dominio)"
    exB2 = rpc(uid, "select start_level_exam();")
    print({k: exB2[k] for k in ("exam_id", "level", "item_count")})
    assert exB2["level"] == "B2" and exB2["item_count"] >= 18
    lvB2 = set(it["cefr_level"] for it in exB2["items"])
    assert lvB2 == {"B2"}, f"los ítems del examen B2 deben ser B2: {lvB2}"
    resB2 = rpc(uid, f"select submit_level_exam({jq(build_answers([it['id'] for it in exB2['items']]))}, 120);")
    print({k: resB2.get(k) for k in ("passed", "level", "leveled_up", "raised_skills")})
    print("certificado:", (resB2.get("certificate") or {}).get("folio"))
    assert resB2["passed"] is True and resB2["level"] == "B2"
    assert resB2.get("leveled_up") is True and set(resB2.get("raised_skills") or []) == {"reading", "listening", "writing", "speaking"}
    assert (resB2.get("certificate") or {}).get("folio", "").startswith("JZC-B2-"), "debió emitir cert B2"
    rowsB2 = json.loads(run(f"select skill, cefr_level from user_skill_levels where user_id='{uid}' order by skill;")[1])
    assert all(r["cefr_level"] == "C1" for r in rowsB2), f"las 4 deben pasar a C1 tras examen B2: {rowsB2}"
    print("  OK: B2 certificado, las 4 habilidades en C1 (tope de la escalera sembrada)")

    print("\n== DIVERGENCIA per-skill: solo la sección que aprueba sube ==")
    # Reset a A2 (las 4); dominio A2 alto SOLO para reading; checkpoints A2 ya hechos.
    run(f"update user_skill_levels set cefr_level='A2' where user_id='{uid}';")
    run(f"delete from user_skill_mastery where user_id='{uid}';")
    run(f"""insert into user_skill_mastery(user_id,course_id,skill,cefr_level,items_seen,items_correct,lessons_done)
            values ('{uid}','{course}','reading','A2',16,16,1)
            on conflict (user_id,course_id,skill,cefr_level) do update set items_correct=16;""")
    exd = rpc(uid, "select start_level_exam('A2');")
    rd_ids = [it["id"] for it in exd["items"] if it["skill"] == "reading"]
    resd = rpc(uid, f"select submit_level_exam({jq(build_answers(rd_ids))}, 120, 'A2');")  # SOLO reading, correctas
    print("  raised_skills:", resd.get("raised_skills"))
    assert set(resd.get("raised_skills") or []) == {"reading"}, \
        f"solo reading debe subir (su sección aprueba; las demás sin responder): {resd.get('raised_skills')}"
    bysk = {r["skill"]: r["cefr_level"] for r in
            json.loads(run(f"select skill,cefr_level from user_skill_levels where user_id='{uid}' order by skill;")[1])}
    assert bysk["reading"] == "B1" and bysk["listening"] == "A2" and bysk["writing"] == "A2" and bysk["speaking"] == "A2", \
        f"divergencia esperada (reading B1, resto A2): {bysk}"
    print("  OK divergencia:", bysk)

    print("\n== get_skill_mastery (estado de dominio para la app) ==")
    gm = rpc(uid, "select get_skill_mastery();")
    print({"working_level": gm.get("working_level"),
           "exam_unlocked": (gm.get("exam") or {}).get("unlocked"),
           "skills": [(s["skill"], s["certified_level"], s["mastery_pct"], s["reinforce_score"]) for s in gm.get("skills", [])]})
    assert len(gm.get("skills", [])) == 4, "get_skill_mastery debe devolver las 4 habilidades"
    assert all("reinforce_score" in s and "mastery_pct" in s for s in gm["skills"]), "faltan campos de dominio/refuerzo"

    print("\n== certificados del usuario ==")
    code, out = run(f"select cefr_level, folio from certificates where user_id='{uid}' order by cefr_level;")
    print(out)

    print("\n== limpieza (borra el usuario de prueba en cascada) ==")
    admin("DELETE", f"/auth/v1/admin/users/{uid}")
    print("\n[OK] CADENA A1 -> A2 -> B1 -> B2 (examenes + certs + per-skill) VERIFICADA (modelo de dominio)")

if __name__ == "__main__":
    main()
