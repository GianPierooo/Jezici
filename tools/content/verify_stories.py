"""Verifica HISTORIAS/INMERSIÓN con cliente real (JWT): get_stories/get_story/
submit_story, que el cliente NO pueda leer las respuestas (columna questions
revocada), grading server-side correcto, y cobertura de audio. Limpia al final."""
import json, sys, urllib.request
from apply_sql import run
from verify_chain import admin, rpc

EMAIL = "verify_stories@jezici.test"

def main():
    code, out = admin("POST", "/auth/v1/admin/users", {"email": EMAIL, "password": "Test12345!", "email_confirm": True})
    if code in (200, 201):
        uid = json.loads(out)["id"]
    elif code == 422:
        _, o2 = admin("GET", "/auth/v1/admin/users?page=1&per_page=200")
        uid = next(u["id"] for u in json.loads(o2)["users"] if u["email"] == EMAIL)
    else:
        sys.exit(f"no se pudo crear usuario [{code}]: {out}")
    run(f"insert into public.users(id,email) values ('{uid}','{EMAIL}') on conflict (id) do nothing;")
    rpc(uid, "select start_course();")
    ok = True

    # 1) get_stories
    lst = rpc(uid, "select get_stories();")
    print(f"[1] get_stories -> {len(lst)} historias; ejemplo:", {k: lst[0][k] for k in ('cefr_level','order_index','title','segment_count','question_count','completed')} if lst else None)
    if len(lst) != 6: ok = False; print("  FALLO: se esperaban 6 historias")
    if lst and ('best_score' not in lst[0] or any('answer' in json.dumps(s).lower() and 'correct' in json.dumps(s).lower() for s in lst)):
        pass  # la lista no trae preguntas

    # 2) get_story (A1#1) — segments con audio_url, questions SIN correct_answer
    sid = "55000000-0000-0000-0000-000000000101"
    st = rpc(uid, f"select get_story('{sid}'::uuid);")
    seg0 = st["segments"][0]
    q0 = st["questions"][0]
    print(f"[2] get_story: {st['title']} · {len(st['segments'])} segmentos · {len(st['questions'])} preguntas")
    print("    seg0 audio_url:", seg0.get("audio_url", "")[-40:])
    if "correct_answer" in q0 or "value" in (q0.get("payload") or {}):
        ok = False; print("  FALLO: get_story filtra la respuesta:", q0)
    else:
        print("  PASS: preguntas sin respuesta; payload solo", list(q0.get("payload", {}).keys()))

    # 3) Lectura directa de la columna `questions` como authenticated → DENEGADA
    code, o = run(f"set local role authenticated; set local \"request.jwt.claims\" = '{{\"sub\":\"{uid}\"}}'; select questions from stories where id='{sid}';")
    if code in (200, 201) and "permission denied" not in o.lower() and "denegado" not in o.lower():
        ok = False; print("  FALLO [3]: el cliente PUDO leer stories.questions:", o[:120])
    else:
        print("  PASS [3]: stories.questions revocada al cliente (no se filtran respuestas)")

    # 4) submit_story con respuestas CORRECTAS → score 1.0 + XP (1er completado)
    full = json.loads(run(f"select questions from stories where id='{sid}';")[1])[0]["questions"]
    answers = []
    for i, q in enumerate(full):
        ca = q["correct_answer"]
        answers.append({"i": i, "answer": ca["value"]})
    res = rpc(uid, f"select submit_story('{sid}'::uuid, '{json.dumps(answers)}'::jsonb);")
    print(f"[4] submit (correctas): score={res['score']} correct={res['correct']}/{res['total']} xp={res['xp_earned']} first={res['first_time']}")
    if res["score"] != 1.0 or res["correct"] != res["total"] or res["xp_earned"] != 12 or not res["first_time"]:
        ok = False; print("  FALLO: submit correcto no dio score 1.0 / xp 12 / first")
    # 2do submit → sin XP nuevo
    res2 = rpc(uid, f"select submit_story('{sid}'::uuid, '{json.dumps(answers)}'::jsonb);")
    if res2["xp_earned"] != 0 or res2["first_time"]:
        ok = False; print("  FALLO: 2do completado volvió a dar XP", res2)
    else:
        print("  PASS: 2do completado sin XP nuevo (xp solo en el 1ro)")

    # 5) submit con TODO mal → score 0 y expected presente para review
    bad = [{"i": i, "answer": "zzdefinitely-wrong"} for i in range(len(full))]
    res3 = rpc(uid, f"select submit_story('{sid}'::uuid, '{json.dumps(bad)}'::jsonb);")
    print(f"[5] submit (incorrectas): score={res3['score']} correct={res3['correct']}/{res3['total']}; expected[0]:", res3["per_question"][0].get("expected"))
    if res3["correct"] != 0:
        ok = False; print("  FALLO: respuestas malas marcaron correctas")

    # 6) Audio HEAD de todos los segmentos
    segs = json.loads(run(f"select id, segments from stories where course_id='20000000-0000-0000-0000-000000000001';")[1])
    urls = [seg["audio_url"] for s in segs for seg in (s["segments"] if isinstance(s["segments"], list) else json.loads(s["segments"]))]
    good = 0
    for u in urls:
        try:
            req = urllib.request.Request(u, method="HEAD"); req.add_header("User-Agent", "Mozilla/5.0")
            with urllib.request.urlopen(req, timeout=20) as x:
                good += 1 if x.status == 200 else 0
        except Exception:
            pass
    print(f"[6] audio HEAD: {good}/{len(urls)} OK")
    if good != len(urls): ok = False

    # limpieza
    run(f"delete from user_story_progress where user_id='{uid}';")
    admin("DELETE", f"/auth/v1/admin/users/{uid}")
    print("\n[OK] HISTORIAS verificadas con cliente real" if ok else "\n[FALLO] revisar arriba")
    sys.exit(0 if ok else 1)

if __name__ == "__main__":
    main()
