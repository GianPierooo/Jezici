# -*- coding: utf-8 -*-
"""Verificación de los bancos de PLACEMENT fr/it/de/nl (mig 110) con cliente REAL (JWT):
  1) Determinista por curso: cada correcto → correct=true; un distractor → false
     (grade_item, correct_answer 42501 nunca se lee desde el cliente).
  2) Personas A1/A2/avanzado por idioma: placement_next(<curso>) ubica en el nivel
     correcto DENTRO de los niveles sembrados (A1-A2). avanzado → A2 (techo honesto,
     el curso no tiene B1+), no promueve por azar.
  3) Multicurso (riesgo #1): TODO ítem que placement_next(fr) devuelve es del curso fr;
     nunca cruza con it/de/nl/en/pt. placement_next(en) nunca devuelve un ítem fr/it/de/nl.
Los correctos/distractores se leen por ADMIN (scaffolding), nunca por el JWT."""
import urllib.request, urllib.error, json, sys
from apply_sql import env, SUPABASE_URL, run
from verify_chain import admin

AK = env('SUPABASE_ANON_KEY')
COURSES = {
    'en': '20000000-0000-0000-0000-000000000001', 'pt': '20000000-0000-0000-0000-000000000002',
    'fr': '20000000-0000-0000-0000-000000000003', 'it': '20000000-0000-0000-0000-000000000004',
    'de': '20000000-0000-0000-0000-000000000005', 'nl': '20000000-0000-0000-0000-000000000006',
}
NEW = ['fr', 'it', 'de', 'nl']
RANK = {'A1': 0, 'A2': 1, 'B1': 2, 'B2': 3, 'C1': 4}


def rpc(tok, name, body):
    r = urllib.request.Request(SUPABASE_URL + '/rest/v1/rpc/' + name,
                               data=json.dumps(body).encode(), method='POST')
    r.add_header('apikey', AK); r.add_header('Authorization', 'Bearer ' + tok)
    r.add_header('Content-Type', 'application/json')
    try:
        with urllib.request.urlopen(r, timeout=60) as x:
            return x.status, json.loads(x.read().decode())
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode()


def main():
    # Scaffolding admin (NO cliente): id → (level, correct, options, course).
    rows = json.loads(run(
        "select id, cefr_level, correct_answer->>'value' as correct, "
        "payload->'options' as options, course_id "
        "from content_items where 'placement'=any(tags);")[1])
    meta = {r['id']: r for r in rows}
    ids_by_course = {code: {r['id'] for r in rows if r['course_id'] == cid} for code, cid in COURSES.items()}

    em = 'plc_multi_probe@jezici.test'
    admin('POST', '/auth/v1/admin/users', {'email': em, 'password': 'Test12345!', 'email_confirm': True})
    r = urllib.request.Request(SUPABASE_URL + '/auth/v1/token?grant_type=password',
                               data=json.dumps({'email': em, 'password': 'Test12345!'}).encode(), method='POST')
    r.add_header('apikey', AK); r.add_header('Content-Type', 'application/json')
    tok = json.loads(urllib.request.urlopen(r).read())['access_token']
    uid = json.loads(run(f"select id from auth.users where email='{em}';")[1])[0]['id']
    run(f"insert into public.users(id,email) values ('{uid}','{em}') on conflict do nothing;")

    passed = True
    def ck(name, cond, detail=''):
        nonlocal passed
        print(('  OK  ' if cond else '  XX  ') + name + ('  ' + detail if detail else '')); passed = passed and cond

    def run_persona(course_id, persona_rank, start='A2'):
        hist = []; seen = set()
        for _ in range(20):
            c, o = rpc(tok, 'placement_next', {'p_course': course_id, 'p_start_level': start, 'p_history': hist})
            if not isinstance(o, dict):
                return None, seen
            if o.get('done'):
                return o, seen
            it = o['item']; iid = it['id']; m = meta.get(iid)
            seen.add(m['course_id'] if m else '?')
            lvl = m['cefr_level']
            ans = (m['correct'] if RANK[lvl] <= persona_rank or not m.get('options')
                   else next(op for op in m['options'] if op != m['correct']))
            hist.append({'item_id': iid, 'answer': ans})
        return None, seen

    for code in NEW:
        cid = COURSES[code]
        cids = ids_by_course[code]
        print(f"\n===== {code.upper()} =====")
        # 1) Determinista
        det_ok = det_bad = 0
        for iid in cids:
            m = meta[iid]
            # Los ítems de SPEAKING del placement (mig 135/139) son `translation`
            # SIN `options` (read-aloud): no tienen distractor que rechazar, así
            # que el chequeo determinista de distractores no aplica. Sin este
            # filtro el verificador reventaba — bit-rot desde mig 135, no un
            # fallo del banco.
            if not m.get('options'):
                continue
            _, good = rpc(tok, 'grade_item', {'p_item_id': iid, 'p_answer': m['correct']})
            wrong = next(o for o in m['options'] if o != m['correct'])
            _, bad = rpc(tok, 'grade_item', {'p_item_id': iid, 'p_answer': wrong})
            if isinstance(good, dict) and good.get('correct') is True: det_ok += 1
            if isinstance(bad, dict) and bad.get('correct') is False: det_bad += 1
        n_mc = sum(1 for i in cids if meta[i].get('options'))
        ck(f'{code} determinista: correctos aceptados', det_ok == n_mc, f"{det_ok}/{n_mc}")
        ck(f'{code} determinista: distractores rechazados (sin near-match)', det_bad == n_mc, f"{det_bad}/{n_mc}")
        # 2) Personas (techo B2: los cursos fr/it/de/nl ya llegan a B2)
        for name, prank in [('A1', 0), ('A2', 1), ('B1', 2), ('B2', 3), ('avanzado', 4)]:
            res, seen = run_persona(cid, prank)
            lvl = res.get('level') if isinstance(res, dict) else None
            expect = {'A1': 'A1', 'A2': 'A2', 'B1': 'B1', 'B2': 'B2', 'avanzado': 'B2'}[name]
            only = seen <= {cid}
            ck(f'{code} persona {name} → {expect}', lvl == expect and only,
               f"ubicó={lvl} solo_curso={only} skills={res.get('skill_levels') if isinstance(res,dict) else None}")
        # 3) Aislamiento: placement_next(code) solo devuelve ítems de code
        _, seenc = run_persona(cid, 4)
        ck(f'{code} aislamiento: placement_next solo sirve {code}', seenc <= {cid}, f"cursos={seenc}")

    # 4) placement_next(en) nunca devuelve un ítem fr/it/de/nl
    new_ids = set().union(*[ids_by_course[c] for c in NEW])
    hist = []; leaked = False; en_courses = set()
    for _ in range(14):
        c, o = rpc(tok, 'placement_next', {'p_course': COURSES['en'], 'p_start_level': 'A2', 'p_history': hist})
        if not isinstance(o, dict) or o.get('done'): break
        it = o['item']; iid = it['id']
        if iid in new_ids: leaked = True
        m = meta.get(iid); en_courses.add(m['course_id'] if m else COURSES['en'])
        ans = m['correct'] if m else it['payload'].get('options', ['x'])[0]
        hist.append({'item_id': iid, 'answer': ans})
    ck('multicurso: placement_next(en) sin ítems fr/it/de/nl', not leaked and en_courses <= {COURSES['en']}, f"leak={leaked} courses={en_courses}")

    run(f"delete from user_item_attempts where user_id='{uid}'; delete from public.users where id='{uid}';")
    admin('DELETE', f'/auth/v1/admin/users/{uid}')
    print('\n' + ('TODO VERDE' if passed else 'HAY FALLOS'))
    sys.exit(0 if passed else 1)


if __name__ == '__main__':
    main()
