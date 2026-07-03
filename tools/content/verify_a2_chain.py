# -*- coding: utf-8 -*-
"""Verifica el nivel A2 NUEVO de un curso (es→fr / es→it) con cliente REAL (JWT):
  1) DETERMINISTA (A2): cada ítem A2 calificable → correcto=true; distractor → false
     (grade_item; correct_answer 42501 nunca leído por el JWT).
  2) AISLAMIENTO: 0 lesson_items cruzan los 4 cursos; un usuario default(en) NO recibe
     ítems A2 del curso nuevo (start_practice).
  3) CADENA A1→A2 COMPLETA: el usuario CAMINA las 12 unidades EN ORDEN con cliente real
     (complete_lesson por lección + submit_checkpoint por checkpoint). Prueba que tras el
     checkpoint de U6 (última A1) se DESBLOQUEA U7 (primera A2) y que A2 (U7–U12) es
     alcanzable y calificable. Gating A1→A2 de punta a punta, course-scoped.
  4) AUDIO A2: HEAD 200 a los listening/speaking A2 del curso.
Uso: python verify_a2_chain.py fr
Los correctos los lee el ADMIN (scaffolding), nunca el JWT."""
import urllib.request, urllib.error, json, sys
from apply_sql import SUPABASE_URL, run, env
from verify_chain import admin

AK = env('SUPABASE_ANON_KEY')
COURSE = {'en': '20000000-0000-0000-0000-000000000001', 'pt': '20000000-0000-0000-0000-000000000002',
          'fr': '20000000-0000-0000-0000-000000000003', 'it': '20000000-0000-0000-0000-000000000004',
          'de': '20000000-0000-0000-0000-000000000005', 'nl': '20000000-0000-0000-0000-000000000006'}


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
        req = urllib.request.Request(url, method='HEAD'); req.add_header('User-Agent', 'Mozilla/5.0')
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
    return ca.get('value', '')


def wrong_answer(t, ca, payload):
    if t in ('multiple_choice', 'listening'):
        for o in (payload or {}).get('options', []):
            if o != ca.get('value'):
                return o
        return 'zzz'
    if t == 'match':
        pairs = ca.get('pairs', []); d = {str(k): p[1] for k, p in enumerate(pairs)}
        if len(d) >= 2:
            d['0'], d['1'] = d['1'], d['0']
        return d
    return 'xxxxx'


def lesson_answers(lesson_id):
    its = json.loads(run(f"select li.item_id, ci.type, ci.correct_answer from lesson_items li "
                         f"join content_items ci on ci.id=li.item_id where li.lesson_id='{lesson_id}' "
                         f"order by li.order_index;")[1])
    return [{'item_id': r['item_id'], 'answer': build_answer(r['type'], r['correct_answer'] or {})} for r in its]


def main():
    code = sys.argv[1] if len(sys.argv) > 1 else 'fr'
    C = COURSE[code]
    passed = True
    def ck(name, cond, detail=''):
        nonlocal passed
        print(('  OK  ' if cond else '  XX  ') + name + ('  ' + detail if detail else '')); passed = passed and cond

    # ── 0) Global: ningún lesson_item cruza cursos. ──────────────────────────
    cross = json.loads(run("select count(*) c from lesson_items li join content_items ci on ci.id=li.item_id "
                           "join lessons le on le.id=li.lesson_id join units u on u.id=le.unit_id "
                           "where ci.course_id <> u.course_id;")[1])[0]['c']
    ck('global: 0 lesson_items cruzan cursos (todos)', int(cross) == 0, f"cruces={cross}")

    # A2 sembrado.
    a2 = json.loads(run("select id,type,skill,correct_answer,payload from content_items "
                        f"where course_id='{C}' and cefr_level='A2' and not (type in ('dictation','guided_writing'));")[1])
    ck(f'{code}: hay contenido A2 sembrado', len(a2) >= 60, f"items A2={len(a2)}")

    tok, uid = mk_user(f'verify_{code}a2_probe@jezici.test')

    # ── 1) Determinista A2 (JWT). ────────────────────────────────────────────
    ok = bad = tested = 0
    for it in a2:
        if it['type'] == 'speaking_read_aloud':
            continue
        ca = it['correct_answer'] or {}
        _, rg = rpc(tok, 'grade_item', {'p_item_id': it['id'], 'p_answer': build_answer(it['type'], ca)})
        _, rb = rpc(tok, 'grade_item', {'p_item_id': it['id'], 'p_answer': wrong_answer(it['type'], ca, it['payload'])})
        tested += 1
        if isinstance(rg, dict) and rg.get('correct') is True: ok += 1
        else: print('   correcto NO aceptado:', it['id'], it['type'], json.dumps(build_answer(it['type'], ca), ensure_ascii=False)[:60])
        if isinstance(rb, dict) and rb.get('correct') is False: bad += 1
    ck(f'{code}: determinista A2 correctos aceptados', ok == tested, f"{ok}/{tested}")
    ck(f'{code}: determinista A2 distractores rechazados', bad == tested, f"{bad}/{tested}")

    # ── 2) Aislamiento: default(en) NO recibe A2 del curso nuevo. ────────────
    tok2, uid2 = mk_user(f'verify_{code}a2_ctrl@jezici.test')
    rpc(tok2, 'start_course', {})
    _, pr2 = rpc(tok2, 'start_practice', {'p_mode': 'timed'})
    ids2 = [x['id'] for x in pr2.get('items', [])] if isinstance(pr2, dict) else []
    leak = False
    if ids2:
        inl = ",".join("'" + i + "'" for i in ids2)
        cs = set(r['course_id'] for r in json.loads(run(f"select distinct course_id from content_items where id in ({inl});")[1]))
        leak = C in cs
    ck(f'{code}: usuario default(en) NO recibe A2 del curso nuevo', not leak)

    # ── 3) CADENA A1→A2: camina las 12 unidades EN ORDEN (cliente real). ─────
    rpc(tok, 'set_active_course', {'p_course_id': C})
    rpc(tok, 'create_plan', {'p_coach_style': 'suave', 'p_intensity': 2, 'p_current_level': 'A1',
        'p_goal_level': 'A2', 'p_daily_minutes': 10, 'p_days_per_week': 5, 'p_motive': 'Viajes',
        'p_deadline': None, 'p_estimated_hours': 100, 'p_estimated_completion': None, 'p_skill_levels': None})
    # Unidades del curso en orden.
    units = json.loads(run("select u.id, u.order_index, u.cefr_level from units u "
                           f"where u.course_id='{C}' order by u.order_index;")[1])
    walk_ok = True; u7_unlocked_after_u6 = None; reached = []
    for u in units:
        oi = u['order_index']
        lessons = json.loads(run("select id, order_index, type from lessons "
                                 f"where unit_id='{u['id']}' order by order_index;")[1])
        for le in lessons:
            ans = lesson_answers(le['id'])
            if le['type'] == 'checkpoint':
                st, res = rpc(tok, 'submit_checkpoint', {'p_lesson_id': le['id'], 'p_answers': ans, 'p_time_taken_sec': 60})
                good = isinstance(res, dict) and res.get('passed') is True
                if oi == 6:
                    u7_unlocked_after_u6 = isinstance(res, dict) and bool(res.get('next_unlocked'))
            else:
                st, res = rpc(tok, 'complete_lesson', {'p_lesson_id': le['id'], 'p_answers': ans})
                good = isinstance(res, dict) and float(res.get('accuracy', 0) or 0) >= 0.99
            if not good:
                walk_ok = False
                print(f'   fallo en unidad {oi} lección {le["order_index"]} ({le["type"]}):', str(res)[:100])
                break
        reached.append(oi)
        if not walk_ok:
            break
    ck(f'{code}: camina A1→A2 completo (12 unidades, cliente real)', walk_ok and reached[-1] == 12, f"llegó a U{reached[-1] if reached else '-'}")
    ck(f'{code}: checkpoint U6 (última A1) DESBLOQUEA U7 (primera A2)', u7_unlocked_after_u6 is True)
    # progreso final: todas las lecciones A2 (U7-U12) quedaron completadas por el JWT.
    # (current_unit_id no se actualiza en el loop -on conflict do nothing-; la prueba real
    #  es que las lecciones A2 estén completed/golden tras la caminata con cliente real.)
    done_a2 = json.loads(run("select count(*) c from user_lesson_progress ulp "
                             "join lessons le on le.id=ulp.lesson_id join units u on u.id=le.unit_id "
                             f"where ulp.user_id='{uid}' and u.course_id='{C}' and u.cefr_level='A2' "
                             "and ulp.status in ('completed','golden');")[1])[0]['c']
    total_a2 = json.loads(run("select count(*) c from lessons le join units u on u.id=le.unit_id "
                              f"where u.course_id='{C}' and u.cefr_level='A2';")[1])[0]['c']
    ck(f'{code}: TODAS las lecciones A2 completadas (cliente real)', int(done_a2) == int(total_a2) and int(total_a2) >= 30, f"{done_a2}/{total_a2}")

    # ── 4) Audio A2 HEAD 200. ────────────────────────────────────────────────
    au = json.loads(run("select payload->>'audio_url' u from content_items "
                        f"where course_id='{C}' and cefr_level='A2' and type in ('listening','speaking_read_aloud') and payload ? 'audio_url';")[1])
    urls = [r['u'] for r in au if r['u']]
    ok200 = sum(1 for u in urls if head(u) == 200)
    ck(f'{code}: audio A2 HEAD 200', ok200 == len(urls), f"{ok200}/{len(urls)}")

    # limpieza
    for u in (uid, uid2):
        run(f"delete from user_item_attempts where user_id='{u}'; delete from user_lesson_progress where user_id='{u}'; "
            f"delete from user_skill_levels where user_id='{u}'; delete from user_course_progress where user_id='{u}'; "
            f"delete from user_active_course where user_id='{u}'; delete from user_plans where user_id='{u}'; "
            f"delete from user_personality where user_id='{u}'; delete from gold_transactions where user_id='{u}'; "
            f"delete from exam_attempts where user_id='{u}'; delete from public.users where id='{u}';")
    admin('DELETE', f'/auth/v1/admin/users/{uid}')
    admin('DELETE', f'/auth/v1/admin/users/{uid2}')
    print('\n' + ('TODO VERDE ✅' if passed else 'HAY FALLOS ❌'))
    sys.exit(0 if passed else 1)


if __name__ == '__main__':
    main()
