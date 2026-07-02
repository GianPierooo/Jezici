# -*- coding: utf-8 -*-
"""Verificación del banco de PLACEMENT es->pt (mig 093) con cliente REAL (JWT):
  1) Determinista: cada correcto → correct=true; un distractor → correct=false
     (grade_item, correct_answer 42501 nunca se lee desde el cliente).
  2) Personas A1/A2/B1 + "avanzado": placement_next(pt) ubica en el nivel correcto.
  3) Multicurso: TODO ítem que placement_next(pt) devuelve es del curso pt (...0002);
     placement_next(en) nunca devuelve un ítem pt (sin cruce).
Los correctos/distractores se leen por ADMIN (scaffolding de test), nunca por el JWT."""
import urllib.request, urllib.error, json, sys
from apply_sql import env, SUPABASE_URL, run
from verify_chain import admin

AK = env('SUPABASE_ANON_KEY')
EN = '20000000-0000-0000-0000-000000000001'
PT = '20000000-0000-0000-0000-000000000002'
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
    # Mapa admin (scaffolding): id → (level, correct, options, course). NO es cliente.
    rows = json.loads(run(
        "select id, cefr_level, correct_answer->>'value' as correct, "
        "payload->'options' as options, course_id "
        "from content_items where 'placement'=any(tags) and course_id in "
        f"('{PT}','{EN}');")[1])
    meta = {r['id']: r for r in rows}
    pt_ids = {r['id'] for r in rows if r['course_id'] == PT}

    em = 'plc_pt_probe@jezici.test'
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

    # 1) Determinista sobre TODOS los ítems pt: correcto→true, distractor→false.
    det_ok = det_bad = 0
    for iid in pt_ids:
        m = meta[iid]
        _, good = rpc(tok, 'grade_item', {'p_item_id': iid, 'p_answer': m['correct']})
        wrong_opt = next(o for o in m['options'] if o != m['correct'])
        _, bad = rpc(tok, 'grade_item', {'p_item_id': iid, 'p_answer': wrong_opt})
        if isinstance(good, dict) and good.get('correct') is True: det_ok += 1
        if isinstance(bad, dict) and bad.get('correct') is False: det_bad += 1
    ck('determinista pt: correctos aceptados', det_ok == len(pt_ids), f"{det_ok}/{len(pt_ids)}")
    ck('determinista pt: distractores rechazados (sin near-match)', det_bad == len(pt_ids), f"{det_bad}/{len(pt_ids)}")

    # 2) Personas: driver del placement_next(pt). El persona domina hasta su nivel.
    def run_persona(persona_rank, start='A2'):
        hist = []; seen_courses = set(); asked_lvls = []
        for _ in range(20):
            c, o = rpc(tok, 'placement_next', {'p_course': PT, 'p_start_level': start, 'p_history': hist})
            if not isinstance(o, dict):
                return None, seen_courses, asked_lvls
            if o.get('done'):
                return o, seen_courses, asked_lvls
            it = o['item']; iid = it['id']; m = meta.get(iid)
            seen_courses.add(m['course_id'] if m else '?')
            lvl = m['cefr_level']; asked_lvls.append(lvl)
            if RANK[lvl] <= persona_rank:
                ans = m['correct']
            else:
                ans = next(op for op in m['options'] if op != m['correct'])
            hist.append({'item_id': iid, 'answer': ans})
        return None, seen_courses, asked_lvls

    for name, prank in [('A1', 0), ('A2', 1), ('B1', 2), ('avanzado', 4)]:
        res, courses, asked = run_persona(prank)
        lvl = res.get('level') if isinstance(res, dict) else None
        # avanzado: el curso pt tope es B1 → debe ubicar en B1 (techo honesto).
        expect = {'A1': 'A1', 'A2': 'A2', 'B1': 'B1', 'avanzado': 'B1'}[name]
        onlypt = courses <= {PT}
        ck(f'persona {name} → {expect}', lvl == expect and onlypt,
           f"ubicó={lvl} skills={res.get('skill_levels') if isinstance(res,dict) else res} asked={asked} solo_pt={onlypt}")

    # 3) Multicurso: placement_next(en) nunca devuelve un ítem pt.
    hist = []; en_courses = set(); leaked = False
    for _ in range(14):
        c, o = rpc(tok, 'placement_next', {'p_course': EN, 'p_start_level': 'A2', 'p_history': hist})
        if not isinstance(o, dict) or o.get('done'): break
        it = o['item']; iid = it['id']
        if iid in pt_ids: leaked = True
        m = meta.get(iid); en_courses.add(m['course_id'] if m else EN)
        # responde correcto para avanzar
        ans = m['correct'] if m else (it['payload'].get('options', ['x'])[0])
        hist.append({'item_id': iid, 'answer': ans})
    ck('multicurso: placement_next(en) sin ítems pt', not leaked and en_courses <= {EN}, f"courses={en_courses} leak={leaked}")

    # limpieza
    run(f"delete from user_item_attempts where user_id='{uid}'; delete from public.users where id='{uid}';")
    admin('DELETE', f'/auth/v1/admin/users/{uid}')
    print('\n' + ('TODO VERDE' if passed else 'HAY FALLOS'))
    sys.exit(0 if passed else 1)

if __name__ == '__main__':
    main()
