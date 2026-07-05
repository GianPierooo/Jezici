"""Verifica HISTORIAS multicurso con CLIENTE REAL (JWT, nunca service_role para la
lógica): aislamiento de los 6 cursos (cada curso ve SOLO sus historias, 0 cruces),
get_story sin fuga de respuesta, submit_story calificado server-side (correctas 1.0,
erróneas 0.0), y audio HEAD 200 de los segmentos pt/de/nl. Limpia al final."""
import json, sys, urllib.request
from apply_sql import run
from verify_chain import admin, rpc

EMAIL = "verify_stories_multi@jezici.test"

COURSES = {  # code -> (course_id, esperado get_stories count)
    'en': ('20000000-0000-0000-0000-000000000001', 6),
    'pt': ('20000000-0000-0000-0000-000000000002', 2),
    'fr': ('20000000-0000-0000-0000-000000000003', 2),
    'it': ('20000000-0000-0000-0000-000000000004', 2),
    'de': ('20000000-0000-0000-0000-000000000005', 2),
    'nl': ('20000000-0000-0000-0000-000000000006', 2),
}
NEW = {  # historias B1 (order_index=2) sembradas en esta tanda (uuid5 'story:<code>:2')
    'fr': 'a6cf8f45-3193-501f-a12e-97d7aeaccc16',
    'it': '4e7df89e-e299-5a32-aab1-81fb611fe1f6',
    'de': '00bc3e04-edf4-53e6-b7d9-f884778c1334',
    'nl': '9cd1913e-c943-5c7b-a3cd-c398da346a37',
    'pt': '53e8afb8-17da-588a-a818-7ab8debcbaeb',
}


def sid_of(story):
    for k in ('id', 'story_id', 'story'):
        if k in story:
            return story[k]
    return None


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
    ok = True

    # 1) AISLAMIENTO: por cada curso, set_active_course + get_stories → SOLO las suyas
    seen = {}  # code -> set(story_ids)
    for code_, (cid, expected) in COURSES.items():
        rpc(uid, f"select set_active_course('{cid}'::uuid);")
        lst = rpc(uid, "select get_stories();")
        ids = {sid_of(s) for s in lst}
        seen[code_] = ids
        titles = [s.get('title') for s in lst]
        print(f"[1:{code_}] get_stories -> {len(lst)} (esperado {expected}); titulos={titles}")
        if len(lst) != expected:
            ok = False; print(f"  FALLO: {code_} devolvió {len(lst)}, esperado {expected}")

    # 2) CRUCES: cada historia nueva SOLO en su curso
    for code_, sid in NEW.items():
        for other, ids in seen.items():
            if other == code_:
                if sid not in ids:
                    ok = False; print(f"  FALLO: {code_} NO ve su propia historia {sid[:8]}")
            elif sid in ids:
                ok = False; print(f"  FALLO CRUCE: historia {code_} {sid[:8]} aparece en curso {other}")
    if ok:
        print("[2] aislamiento OK: 0 cruces de historias entre los 6 cursos")

    # 3) Por cada curso nuevo: get_story sin fuga + submit correcto/erróneo (server-side)
    for code_, sid in NEW.items():
        cid = COURSES[code_][0]
        rpc(uid, f"select set_active_course('{cid}'::uuid);")
        st = rpc(uid, f"select get_story('{sid}'::uuid);")
        q0 = st["questions"][0]
        leak = ("correct_answer" in q0) or ("value" in (q0.get("payload") or {}))
        print(f"[3:{code_}] get_story '{st['title']}' · {len(st['segments'])} seg · {len(st['questions'])} preg · leak_respuesta={leak}")
        if leak:
            ok = False; print(f"  FALLO: get_story {code_} filtra la respuesta")
        # respuestas correctas (bare value, como el cliente) desde la columna server-side
        full = json.loads(run(f"select questions from stories where id='{sid}';")[1])[0]["questions"]
        good = [{"i": i, "answer": q["correct_answer"]["value"]} for i, q in enumerate(full)]
        res = rpc(uid, f"select submit_story('{sid}'::uuid, '{json.dumps(good)}'::jsonb);")
        bad = [{"i": i, "answer": "zzdefinitely-wrong"} for i in range(len(full))]
        resb = rpc(uid, f"select submit_story('{sid}'::uuid, '{json.dumps(bad)}'::jsonb);")
        print(f"    submit correctas: score={res['score']} {res['correct']}/{res['total']} | erróneas: score={resb['score']} {resb['correct']}/{resb['total']}")
        if res["score"] != 1.0 or res["correct"] != res["total"]:
            ok = False; print(f"  FALLO: {code_} correctas no dio 1.0")
        if resb["correct"] != 0:
            ok = False; print(f"  FALLO: {code_} erróneas marcaron correcto")

    # 4) Lectura directa de stories.questions como authenticated → DENEGADA (no fuga)
    sid = NEW['pt']
    code, o = run(f"set local role authenticated; set local \"request.jwt.claims\" = '{{\"sub\":\"{uid}\"}}'; select questions from stories where id='{sid}';")
    if code in (200, 201) and "permission denied" not in o.lower() and "denegado" not in o.lower():
        ok = False; print("  FALLO [4]: el cliente PUDO leer stories.questions:", o[:100])
    else:
        print("[4] PASS: stories.questions revocada al cliente")

    # 5) Audio HEAD de los segmentos pt/de/nl
    urls = []
    for code_, sid in NEW.items():
        segs = json.loads(run(f"select segments from stories where id='{sid}';")[1])[0]["segments"]
        urls += [seg["audio_url"] for seg in segs]
    goodn = 0
    for u in urls:
        try:
            req = urllib.request.Request(u, method="HEAD"); req.add_header("User-Agent", "Mozilla/5.0")
            with urllib.request.urlopen(req, timeout=20) as x:
                goodn += 1 if x.status == 200 else 0
        except Exception:
            pass
    print(f"[5] audio HEAD pt/de/nl: {goodn}/{len(urls)} OK")
    if goodn != len(urls):
        ok = False

    # limpieza
    run(f"delete from user_story_progress where user_id='{uid}';")
    run(f"delete from user_active_course where user_id='{uid}';")
    admin("DELETE", f"/auth/v1/admin/users/{uid}")
    print("\n[OK] HISTORIAS multicurso verificadas con cliente real" if ok else "\n[FALLO] revisar arriba")
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
