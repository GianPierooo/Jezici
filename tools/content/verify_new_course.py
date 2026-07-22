# -*- coding: utf-8 -*-
"""Verifica un curso A1 NUEVO (es→fr / es→it) con cliente REAL (JWT):
  1) DETERMINISTA: cada ítem calificable → correcto=true; una respuesta errónea → false
     (grade_item; correct_answer 42501 nunca leído por el cliente).
  2) AISLAMIENTO MULTICURSO (el objetivo #1): con el curso activo puesto al nuevo,
     create_plan/start_course/start_practice sirven SOLO contenido de ese curso; un
     usuario sin cambiar de curso (default en) solo ve en; y NINGÚN lesson_item cruza
     cursos (content.course_id == unit.course_id en toda la DB, los 4 cursos).
  3) CADENA: el usuario completa su 1ª lección y un checkpoint del curso nuevo.
  4) AUDIO: HEAD 200 a los listening/speaking del curso nuevo (o reporta faltantes).
Uso: python verify_new_course.py fr
Los correctos se leen por ADMIN (scaffolding de test), nunca por el JWT."""
import urllib.request, urllib.error, json, sys
from apply_sql import env, SUPABASE_URL, run
from verify_chain import admin

AK = env('SUPABASE_ANON_KEY')
COURSE = {'en': '20000000-0000-0000-0000-000000000001', 'pt': '20000000-0000-0000-0000-000000000002',
          'fr': '20000000-0000-0000-0000-000000000003', 'it': '20000000-0000-0000-0000-000000000004',
          'de': '20000000-0000-0000-0000-000000000005', 'nl': '20000000-0000-0000-0000-000000000006',
          'ro': '20000000-0000-0000-0000-000000000007'}

def rpc(tok, name, body):
    r = urllib.request.Request(SUPABASE_URL + '/rest/v1/rpc/' + name,
                               data=json.dumps(body).encode(), method='POST')
    r.add_header('apikey', AK); r.add_header('Authorization', 'Bearer ' + tok); r.add_header('Content-Type', 'application/json')
    try:
        with urllib.request.urlopen(r, timeout=60) as x:
            return x.status, json.loads(x.read().decode())
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode()

def head(url):
    try:
        req = urllib.request.Request(url, method='HEAD')
        req.add_header('User-Agent', 'Mozilla/5.0')
        with urllib.request.urlopen(req, timeout=30) as r:
            return r.status
    except urllib.error.HTTPError as e:
        return e.code
    except Exception:
        return 0

def mk_user(email):
    admin('POST', '/auth/v1/admin/users', {'email': email, 'password': 'Test12345!', 'email_confirm': True})
    r = urllib.request.Request(SUPABASE_URL + '/auth/v1/token?grant_type=password',
                               data=json.dumps({'email': email, 'password': 'Test12345!'}).encode(), method='POST')
    r.add_header('apikey', AK); r.add_header('Content-Type', 'application/json')
    tok = json.loads(urllib.request.urlopen(r).read())['access_token']
    uid = json.loads(run(f"select id from auth.users where email='{email}';")[1])[0]['id']
    run(f"insert into public.users(id,email) values ('{uid}','{email}') on conflict do nothing;")
    return tok, uid

def build_answer(t, ca):
    if t == 'match':
        return {str(k): p[1] for k, p in enumerate(ca.get('pairs', []))}
    if t == 'speaking_read_aloud':
        return ca.get('expected', 'ok')
    if t in ('word_bank', 'reorder'):
        return ca.get('value', '')
    return ca.get('value', '')

def wrong_answer(t, ca, payload):
    if t == 'multiple_choice' or t == 'listening':
        opts = (payload or {}).get('options', [])
        for o in opts:
            if o != ca.get('value'):
                return o
        return 'zzz'
    if t == 'match':
        # invierte un par → incorrecto
        pairs = ca.get('pairs', [])
        d = {str(k): p[1] for k, p in enumerate(pairs)}
        if len(d) >= 2:
            d['0'], d['1'] = d['1'], d['0']
        return d
    return 'xxxxx'  # texto claramente incorrecto para cloze/translation/word_bank/reorder

def main():
    code = sys.argv[1] if len(sys.argv) > 1 else 'fr'
    C = COURSE[code]
    passed = True
    def ck(name, cond, detail=''):
        nonlocal passed
        print(('  OK  ' if cond else '  XX  ') + name + ('  ' + detail if detail else '')); passed = passed and cond

    # ── 0) Global: ningún lesson_item cruza cursos (los 4). ──────────────────
    cross = json.loads(run(
        "select count(*) c from lesson_items li "
        "join content_items ci on ci.id=li.item_id "
        "join lessons le on le.id=li.lesson_id join units u on u.id=le.unit_id "
        "where ci.course_id <> u.course_id;")[1])[0]['c']
    ck('global: 0 lesson_items cruzan cursos (todos)', int(cross) == 0, f"cruces={cross}")

    # Metadatos admin del curso nuevo (para determinista y respuestas).
    items = json.loads(run(
        "select id, type, skill, correct_answer, payload, cefr_level from content_items "
        f"where course_id='{C}' and cefr_level='A1' and not (type in ('dictation','guided_writing'));")[1])
    ck(f'{code}: hay contenido A1 sembrado', len(items) >= 60, f"items={len(items)}")

    tok, uid = mk_user(f'verify_{code}_probe@jezici.test')

    # ── 1) Determinista (JWT): correcto→true, distractor→false. ──────────────
    det_ok = det_bad = tested = 0
    for it in items:
        if it['type'] in ('speaking_read_aloud',):  # participación, no se califica exacto
            continue
        ca = it['correct_answer'] or {}
        good = build_answer(it['type'], ca)
        _, rg = rpc(tok, 'grade_item', {'p_item_id': it['id'], 'p_answer': good})
        bad = wrong_answer(it['type'], ca, it['payload'])
        _, rb = rpc(tok, 'grade_item', {'p_item_id': it['id'], 'p_answer': bad})
        tested += 1
        if isinstance(rg, dict) and rg.get('correct') is True: det_ok += 1
        else: print('   correcto NO aceptado:', it['id'], it['type'], json.dumps(good, ensure_ascii=False)[:60])
        if isinstance(rb, dict) and rb.get('correct') is False: det_bad += 1
    ck(f'{code}: determinista correctos aceptados', det_ok == tested, f"{det_ok}/{tested}")
    ck(f'{code}: determinista distractores rechazados', det_bad == tested, f"{det_bad}/{tested}")

    # ── 2) Aislamiento multicurso vía RPCs reales (JWT). ─────────────────────
    rpc(tok, 'set_active_course', {'p_course_id': C})
    ac = json.loads(run(f"select course_id from user_active_course where user_id='{uid}';")[1])[0]['course_id']
    ck(f'{code}: set_active_course fija el curso', ac == C, ac)
    _, plan = rpc(tok, 'create_plan', {'p_coach_style': 'suave', 'p_intensity': 2, 'p_current_level': 'A1',
        'p_goal_level': 'B1', 'p_daily_minutes': 10, 'p_days_per_week': 5, 'p_motive': 'Viajes',
        'p_deadline': None, 'p_estimated_hours': 100, 'p_estimated_completion': None, 'p_skill_levels': None})
    ck(f'{code}: create_plan rutea al curso activo', isinstance(plan, dict) and plan.get('course_id') == C, str(plan)[:80])
    ucp = json.loads(run(f"select course_id from user_course_progress where user_id='{uid}';")[1])
    ck(f'{code}: user_course_progress SOLO curso nuevo', all(r['course_id'] == C for r in ucp) and len(ucp) >= 1, str(ucp))
    # start_practice(timed): todos los ítems del curso nuevo.
    _, pr = rpc(tok, 'start_practice', {'p_mode': 'timed'})
    prids = [x['id'] for x in pr.get('items', [])] if isinstance(pr, dict) else []
    if prids:
        inlist = ",".join("'" + i + "'" for i in prids)
        courses = set(r['course_id'] for r in json.loads(run(f"select distinct course_id from content_items where id in ({inlist});")[1]))
        ck(f'{code}: start_practice sirve SOLO curso nuevo', courses == {C}, str(courses))

    # Control: un usuario SIN cambiar de curso (default en) NO ve fr/it.
    tok2, uid2 = mk_user(f'verify_{code}_ctrl@jezici.test')
    rpc(tok2, 'start_course', {})
    _, pr2 = rpc(tok2, 'start_practice', {'p_mode': 'timed'})
    prids2 = [x['id'] for x in pr2.get('items', [])] if isinstance(pr2, dict) else []
    leak = False
    if prids2:
        inlist2 = ",".join("'" + i + "'" for i in prids2)
        courses2 = set(r['course_id'] for r in json.loads(run(f"select distinct course_id from content_items where id in ({inlist2});")[1]))
        leak = C in courses2
    ck(f'{code}: usuario default(en) NO recibe ítems del curso nuevo', not leak)

    # ── 3) Cadena: completa la 1ª lección + un checkpoint (JWT). ─────────────
    first = plan.get('first_lesson_id') if isinstance(plan, dict) else None
    # La 1ª lección puede ser la misión (0 ítems). Toma la 1ª lección tipo 'lesson' de la U1.
    les = json.loads(run("select le.id from lessons le join units u on u.id=le.unit_id "
                         f"where u.course_id='{C}' and u.order_index=1 and le.type='lesson' order by le.order_index limit 1;")[1])
    chain_ok = False
    if les:
        lid = les[0]['id']
        its = json.loads(run(f"select li.item_id, ci.type, ci.correct_answer from lesson_items li join content_items ci on ci.id=li.item_id where li.lesson_id='{lid}' order by li.order_index;")[1])
        ans = [{'item_id': r['item_id'], 'answer': build_answer(r['type'], r['correct_answer'] or {})} for r in its]
        _, comp = rpc(tok, 'complete_lesson', {'p_lesson_id': lid, 'p_answers': ans})
        chain_ok = isinstance(comp, dict) and comp.get('accuracy', 0) and float(comp.get('accuracy', 0)) >= 0.99
    ck(f'{code}: completa 1ª lección al 100% (grading server-side)', chain_ok)
    # checkpoint U1
    cp = json.loads(run("select le.id from lessons le join units u on u.id=le.unit_id "
                        f"where u.course_id='{C}' and u.order_index=1 and le.type='checkpoint' limit 1;")[1])
    cp_ok = False
    if cp:
        cpid = cp[0]['id']
        its = json.loads(run(f"select li.item_id, ci.type, ci.correct_answer from lesson_items li join content_items ci on ci.id=li.item_id where li.lesson_id='{cpid}' order by li.order_index;")[1])
        ans = [{'item_id': r['item_id'], 'answer': build_answer(r['type'], r['correct_answer'] or {})} for r in its]
        _, sc = rpc(tok, 'submit_checkpoint', {'p_lesson_id': cpid, 'p_answers': ans, 'p_time_taken_sec': 60})
        cp_ok = isinstance(sc, dict) and sc.get('passed') is True
    ck(f'{code}: checkpoint U1 aprueba (≥80%)', cp_ok)

    # ── 4) Audio HEAD 200 (listening/speaking del curso nuevo). ──────────────
    au = json.loads(run("select payload->>'audio_url' u from content_items "
                        f"where course_id='{C}' and cefr_level='A1' and type in ('listening','speaking_read_aloud') and payload ? 'audio_url';")[1])
    urls = [r['u'] for r in au if r['u']]
    ok200 = sum(1 for u in urls if head(u) == 200)
    ck(f'{code}: audio HEAD 200', ok200 == len(urls), f"{ok200}/{len(urls)}")

    # limpieza
    for u in (uid, uid2):
        run(f"delete from user_item_attempts where user_id='{u}'; delete from user_lesson_progress where user_id='{u}'; "
            f"delete from user_skill_levels where user_id='{u}'; delete from user_course_progress where user_id='{u}'; "
            f"delete from user_active_course where user_id='{u}'; delete from user_plans where user_id='{u}'; "
            f"delete from gold_transactions where user_id='{u}'; delete from exam_attempts where user_id='{u}'; "
            f"delete from public.users where id='{u}';")
    admin('DELETE', f'/auth/v1/admin/users/{uid}')
    admin('DELETE', f'/auth/v1/admin/users/{uid2}')
    print('\n' + ('TODO VERDE ✅' if passed else 'HAY FALLOS ❌'))
    sys.exit(0 if passed else 1)

if __name__ == '__main__':
    main()
