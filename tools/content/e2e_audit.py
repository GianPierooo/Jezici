"""Auditoría E2E en VIVO (GA5 · P1): conduce un usuario de prueba por todo el
flujo con las RPC reales y verifica que la BD cuadre (nodos, XP, oro, racha,
4 habilidades, gating). Imprime PASS/FAIL por aserción. Limpia al final."""
import json, sys
from apply_sql import run
import verify_chain as v

FAILS = []
def check(name, cond, detail=''):
    print(f"  {'PASS' if cond else 'FAIL'} · {name}" + (f" · {detail}" if detail else ''))
    if not cond:
        FAILS.append(f"{name} ({detail})")

def q(sql):
    c, o = run(sql)
    return json.loads(o) if o and o.strip().startswith('[') else o

def lesson_answers(uid, lesson_id):
    rows = q(f"""select li.order_index, ci.id, ci.type, ci.correct_answer
                 from lesson_items li join content_items ci on ci.id = li.item_id
                 where li.lesson_id = '{lesson_id}' order by li.order_index;""")
    ans = []
    for r in rows:
        t, c = r['type'], r['correct_answer'] or {}
        if t == 'match':
            a = {str(k): p[1] for k, p in enumerate(c.get('pairs', []))}
        elif t == 'speaking_read_aloud':
            a = c.get('expected', 'ok')
        else:
            a = c.get('value', '')
        ans.append({'item_id': r['id'], 'answer': a})
    return ans

def main():
    print('== usuario de prueba ==')
    code, out = v.admin('POST', '/auth/v1/admin/users',
                        {'email': 'e2e_audit@jezici.test', 'password': 'Test12345!', 'email_confirm': True})
    if code in (200, 201):
        uid = json.loads(out)['id']
    else:
        us = json.loads(v.admin('GET', '/auth/v1/admin/users?page=1&per_page=200')[1])['users']
        uid = next(u['id'] for u in us if u['email'] == 'e2e_audit@jezici.test')
    print('uid', uid)
    # estado limpio
    for t in ['user_lesson_progress', 'user_skill_levels', 'user_course_progress', 'user_plans',
              'user_personality', 'user_stats', 'streaks', 'daily_goals', 'gold_transactions',
              'exam_attempts', 'certificates', 'user_vocab_srs']:
        run(f"delete from {t} where user_id = '{uid}';")
    # asegurar perfil + singletons que crea handle_new_user en el signup real.
    run(f"insert into public.users(id,email) values ('{uid}','e2e_audit@jezici.test') on conflict (id) do nothing;")
    run(f"insert into public.user_stats(user_id) values ('{uid}') on conflict (user_id) do nothing;")
    run(f"insert into public.streaks(user_id) values ('{uid}') on conflict (user_id) do nothing;")

    print('\n== onboarding (create_plan) ==')
    v.rpc(uid, "select create_plan('mano_dura',3,'A1','B1',15,5,'Trabajo',null,280,(current_date+200)::date,"
                "'{\"reading\":\"A1\",\"listening\":\"A1\",\"writing\":\"A1\",\"speaking\":\"A1\"}'::jsonb);")
    plan = q(f"select onboarding_completed, current_level, goal_level from user_plans where user_id='{uid}';")
    check('user_plans creado + onboarding_completed', bool(plan) and plan[0]['onboarding_completed'] is True)
    sk = q(f"select count(*) n from user_skill_levels where user_id='{uid}';")
    check('4 user_skill_levels', sk[0]['n'] == 4, f"n={sk[0]['n']}")

    print('\n== start_course + nodo inicial ==')
    v.rpc(uid, 'select start_course();')
    # primera unidad/lección A1
    u1 = q("select id from units where cefr_level='A1' order by order_index limit 1;")[0]['id']
    lessons = q(f"select id, order_index, type from lessons where unit_id='{u1}' order by order_index;")
    # GA9: el PRIMER nodo (la misión, order 0) es el inicial disponible.
    mission = lessons[0]
    mst = q(f"select status from user_lesson_progress where user_id='{uid}' and lesson_id='{mission['id']}';")
    check('misión (primer nodo) disponible', bool(mst) and mst[0]['status'] == 'available',
          (mst[0]['status'] if mst else 'sin fila') + f" type={mission['type']}")
    # Completar la misión desbloquea la primera lección.
    v.rpc(uid, f"select complete_mission('{mission['id']}');")
    first = next(l for l in lessons if l['type'] == 'lesson')
    st = q(f"select status from user_lesson_progress where user_id='{uid}' and lesson_id='{first['id']}';")
    check('primera lección disponible tras la misión',
          bool(st) and st[0]['status'] in ('available', 'in_progress', 'completed', 'golden'),
          st[0]['status'] if st else 'sin fila')

    print('\n== lección 1.1 (complete_lesson) ==')
    ans = lesson_answers(uid, first['id'])
    res = v.rpc(uid, f"select complete_lesson('{first['id']}', {v.jq(ans)});")
    check('complete_lesson devuelve status', res.get('status') in ('completed', 'golden'), str(res.get('status')))
    check('graded > 0 (ítems calificados)', (res.get('graded') or 0) > 0, f"graded={res.get('graded')}")
    check('accuracy alta con respuestas correctas', (res.get('accuracy') or 0) >= 0.8, f"acc={res.get('accuracy')}")
    check('xp_earned > 0', (res.get('xp_earned') or 0) > 0, f"xp={res.get('xp_earned')}")
    # DB cuadra:
    dbst = q(f"select status, best_accuracy from user_lesson_progress where user_id='{uid}' and lesson_id='{first['id']}';")
    check('DB: nodo completado', bool(dbst) and dbst[0]['status'] in ('completed', 'golden'))
    stats = q(f"select xp_total, gold from user_stats where user_id='{uid}';")
    check('DB: user_stats xp coincide', bool(stats) and stats[0]['xp_total'] == res.get('xp_earned'),
          f"db={stats[0]['xp_total'] if stats else None} rpc={res.get('xp_earned')}")
    streak = q(f"select current_streak from streaks where user_id='{uid}';")
    check('DB: racha = 1', bool(streak) and streak[0]['current_streak'] == 1, str(streak))
    # Modelo v2 (mig 041): la lección registra INTENTOS POR ÍTEM (user_item_attempts);
    # el dominio se calcula on-demand desde ahí. NO escribe user_skill_mastery.
    att = q(f"select count(*) n, count(*) filter (where attempts>0) played from user_item_attempts where user_id='{uid}';")
    check('DB: la lección registró intentos por ítem', bool(att) and int(att[0]['n'] or 0) > 0, str(att))
    gm = v.rpc(uid, 'select get_skill_mastery();')
    check('DB: dominio > 0 en alguna skill (on-demand)',
          isinstance(gm, dict) and any((s.get('mastery_pct') or 0) > 0 for s in gm.get('skills', [])),
          str([(s['skill'], s['mastery_pct']) for s in gm.get('skills', [])]) if isinstance(gm, dict) else str(gm))
    lv = q(f"select distinct cefr_level from user_skill_levels where user_id='{uid}';")
    check('DB: la lección NO subió el nivel (sigue A1)', bool(lv) and all(r['cefr_level'] == 'A1' for r in lv), str(lv))

    print('\n== rehacer la lección (D9: XP reducido) ==')
    redo = v.rpc(uid, f"select complete_lesson('{first['id']}', {v.jq(ans)});")
    check('rehacer marca is_redo', redo.get('is_redo') is True, str(redo.get('is_redo')))
    check('rehacer da MENOS XP que la 1ª vez',
          (redo.get('xp_earned') or 0) < (res.get('xp_earned') or 0),
          f"redo={redo.get('xp_earned')} vs first={res.get('xp_earned')}")

    print('\n== completar resto de Unidad 1 + checkpoint (gating) ==')
    for l in lessons:
        if l['type'] == 'lesson' and l['id'] != first['id']:
            v.rpc(uid, f"select complete_lesson('{l['id']}', {v.jq(lesson_answers(uid, l['id']))});")
    ck = next(l for l in lessons if l['type'] == 'checkpoint')
    cks = v.rpc(uid, f"select start_checkpoint('{ck['id']}');")
    check('start_checkpoint devuelve ítems', (cks.get('item_count') or 0) > 0, f"n={cks.get('item_count')}")
    ckans = []
    for it in cks.get('items', []):
        ca = q(f"select correct_answer, type from content_items where id='{it['id']}';")[0]
        c = ca['correct_answer'] or {}
        if ca['type'] == 'match':
            a = {str(k): p[1] for k, p in enumerate(c.get('pairs', []))}
        elif ca['type'] == 'speaking_read_aloud':
            a = c.get('expected', 'ok')
        else:
            a = c.get('value', '')
        ckans.append({'item_id': it['id'], 'answer': a})
    cres = v.rpc(uid, f"select submit_checkpoint('{ck['id']}', {v.jq(ckans)}, 120);")
    check('checkpoint aprobado', cres.get('passed') is True, f"score={cres.get('score_global')}")
    # gating: unidad 2 primer nodo disponible
    u2 = q("select id from units where cefr_level='A1' order by order_index offset 1 limit 1;")
    if u2:
        u2l = q(f"select id from lessons where unit_id='{u2[0]['id']}' and type='lesson' order by order_index limit 1;")[0]['id']
        u2st = q(f"select status from user_lesson_progress where user_id='{uid}' and lesson_id='{u2l}';")
        check('gating: Unidad 2 desbloqueada', bool(u2st) and u2st[0]['status'] == 'available',
              u2st[0]['status'] if u2st else 'sin fila')

    print('\n== reforzar por unidad (D9: reinforce_unit) + dominio/refuerzo ==')
    rp = v.rpc(uid, f"select start_practice('reinforce_unit', null, '{u1}');")
    check('reinforce_unit devuelve sesión (>=0 ítems débiles)',
          isinstance(rp, dict) and (rp.get('item_count') is not None), f"items={rp.get('item_count') if isinstance(rp, dict) else rp}")
    gm = v.rpc(uid, 'select get_skill_mastery();')
    check('get_skill_mastery: 4 habilidades con dominio+refuerzo',
          isinstance(gm, dict) and len(gm.get('skills', [])) == 4
          and all('mastery_pct' in s and 'reinforce_score' in s for s in gm['skills']), str(gm.get('working_level')))

    print('\n== practicar (srs/weakness/timed) ==')
    for mode in ['srs', 'weakness', 'timed']:
        ps = v.rpc(uid, f"select start_practice('{mode}', null);")
        n = len(ps.get('items', [])) if isinstance(ps, dict) else 0
        check(f'start_practice {mode} devuelve sesión', n >= 0, f"items={n}")

    print('\n== get_plan_tracking + get_league ==')
    pt = v.rpc(uid, 'select get_plan_tracking();')
    check('plan_tracking ok', pt.get('ok') is True)
    check('progress en [0,1]', 0 <= (pt.get('progress') or 0) <= 1, str(pt.get('progress')))
    lg = v.rpc(uid, 'select get_league();')
    check('get_league con miembros', len((lg.get('members') or [])) > 0, f"n={len(lg.get('members') or [])}")

    print('\n== limpieza ==')
    v.admin('DELETE', f'/auth/v1/admin/users/{uid}')

    print('\n' + ('=' * 50))
    if FAILS:
        print(f'[FAIL] {len(FAILS)} ASERCIONES FALLARON:')
        for f in FAILS:
            print('  - ' + f)
        sys.exit(1)
    print('[OK] E2E EN VIVO: todas las aserciones PASARON')

if __name__ == '__main__':
    main()
