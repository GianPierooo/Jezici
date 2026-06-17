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
    # estado limpio para reintentos
    run(f"delete from certificates where user_id='{uid}'; delete from exam_attempts where user_id='{uid}'; "
        f"delete from user_lesson_progress where user_id='{uid}';")

    print("\n== start_course ==")
    print(rpc(uid, "select start_course();"))

    # Marcar los 6 checkpoints A1 como completados (simula terminar A1).
    run(f"""insert into user_lesson_progress(user_id, lesson_id, status, best_accuracy, times_completed, completed_at)
            select '{uid}', l.id, 'completed', 0.9, 1, now()
            from lessons l join units u on u.id=l.unit_id
            where u.cefr_level='A1' and l.type='checkpoint'
            on conflict (user_id, lesson_id) do update set status='completed';""")

    print("\n== A1: level_exam_status ==")
    st = rpc(uid, "select level_exam_status();")
    print(st)
    assert st["level"] == "A1" and st["unlocked"] is True, "A1 debería estar desbloqueado"

    print("\n== A1: start_level_exam ==")
    ex = rpc(uid, "select start_level_exam();")
    print({k: ex[k] for k in ("exam_id", "level", "item_count")})
    assert ex["level"] == "A1" and ex["item_count"] >= 18
    ids = [it["id"] for it in ex["items"]]
    answers = build_answers(ids)
    print("\n== A1: submit_level_exam (respuestas correctas) ==")
    res = rpc(uid, f"select submit_level_exam({jq(answers)}, 120);")
    print({k: res.get(k) for k in ("passed", "level", "score_global", "graded", "correct")})
    print("certificado:", (res.get("certificate") or {}).get("folio"))
    assert res["passed"] is True and res["level"] == "A1", "A1 debió aprobar"
    assert (res.get("certificate") or {}).get("folio", "").startswith("JZC-A1-")

    print("\n== tras certificar A1: level_exam_status (debe apuntar a A2) ==")
    st2 = rpc(uid, "select level_exam_status();")
    print(st2)
    assert st2["level"] == "A2", "debería avanzar a A2"
    assert st2["unlocked"] is False, "A2 aún no listo (faltan checkpoints/skills)"

    # Simular completar A2: 6 checkpoints + 4 skills a A2.
    run(f"""insert into user_lesson_progress(user_id, lesson_id, status, best_accuracy, times_completed, completed_at)
            select '{uid}', l.id, 'completed', 0.9, 1, now()
            from lessons l join units u on u.id=l.unit_id
            where u.cefr_level='A2' and l.type='checkpoint'
            on conflict (user_id, lesson_id) do update set status='completed';""")
    run(f"update user_skill_levels set cefr_level='A2' where user_id='{uid}';")

    print("\n== A2: level_exam_status ==")
    st3 = rpc(uid, "select level_exam_status();")
    print(st3)
    assert st3["level"] == "A2" and st3["unlocked"] is True, "A2 debería estar desbloqueado"

    print("\n== A2: start_level_exam ==")
    ex2 = rpc(uid, "select start_level_exam();")
    print({k: ex2[k] for k in ("exam_id", "level", "item_count")})
    assert ex2["level"] == "A2" and ex2["item_count"] >= 18
    # confirmar que los ítems son A2
    lv = set(it["cefr_level"] for it in ex2["items"])
    print("niveles de ítems:", lv)
    assert lv == {"A2"}
    ids2 = [it["id"] for it in ex2["items"]]
    answers2 = build_answers(ids2)
    print("\n== A2: submit_level_exam (respuestas correctas) ==")
    res2 = rpc(uid, f"select submit_level_exam({jq(answers2)}, 120);")
    print({k: res2.get(k) for k in ("passed", "level", "score_global", "graded", "correct")})
    print("certificado:", (res2.get("certificate") or {}).get("folio"))
    assert res2["passed"] is True and res2["level"] == "A2"
    assert (res2.get("certificate") or {}).get("folio", "").startswith("JZC-A2-")

    print("\n== certificados del usuario ==")
    code, out = run(f"select cefr_level, folio from certificates where user_id='{uid}' order by cefr_level;")
    print(out)

    print("\n== limpieza (borra el usuario de prueba en cascada) ==")
    admin("DELETE", f"/auth/v1/admin/users/{uid}")
    print("\n✅ CADENA A1 → examen A1 → cert → A2 → examen A2 VERIFICADA")

if __name__ == "__main__":
    main()
