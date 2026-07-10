# -*- coding: utf-8 -*-
"""Verifica la UNIFICACIÓN nivel-mostrado == nivel-certificable (mig 141), cliente
REAL (JWT). Prueba:
  A) GRIND de ítems A1 fáciles NO infla el radar más allá de A1.
  B) DOMINAR ítems de un nivel SÍ sube el nivel mostrado a ESE nivel.
  C) radar (user_skill_levels.cefr_level) == nivel derivado de jz_skill_mastery
     (exam_ready coherente): ya no divergen.
python verify_level_unification.py"""
import json
import verify_placement_serious as V

C_EN = V.COURSES['en']
RANK = {'A1': 0, 'A2': 1, 'B1': 2, 'B2': 3, 'C1': 4}


def run_sql(sql):
    return json.loads(V.run(sql)[1])


def read_levels(uid):
    """Lee user_skill_levels directo (lo que ve el radar del cliente)."""
    rows = run_sql(f"""
      select skill, cefr_level, progress_points from user_skill_levels
      where user_id='{uid}' and course_id='{C_EN}' order by skill;""")
    return {r['skill']: r['cefr_level'] for r in rows}


def complete_lesson_with(tok, lesson_id, answers):
    return V.rpc(tok, 'complete_lesson', {'p_lesson_id': lesson_id, 'p_answers': answers})


def items_of_lesson(lesson_id, only_skill=None):
    extra = f"and ci.skill='{only_skill}'" if only_skill else ""
    return run_sql(f"""
      select ci.id, ci.skill, ci.correct_answer ca, ci.type
      from lesson_items li join content_items ci on ci.id=li.item_id
      where li.lesson_id='{lesson_id}' and not jz_is_stub(ci.type) {extra}
      order by li.order_index;""")


def answer_for(it):
    """Construye la RESPUESTA CORRECTA con la forma que jz_grade espera por tipo
    (para simular un usuario que DOMINA el ítem, sea cual sea el tipo)."""
    ca, t = it['ca'], it['type']
    if t == 'match':
        return {str(i): p[1] for i, p in enumerate(ca.get('pairs', []))}
    if t in ('word_bank', 'reorder') and isinstance(ca.get('sequence'), list):
        return ca['sequence']
    return ca.get('value')


def main():
    ok = True
    def ck(n, c, d=''):
        nonlocal ok
        print(('  OK  ' if c else '  XX  ') + n + ('  ' + str(d) if d else ''))
        ok = ok and c

    # Lecciones reales en+A1 y en+B1 (para grind vs dominio)
    a1_lessons = run_sql(f"""
      select l.id from lessons l join units u on u.id=l.unit_id
      where u.course_id='{C_EN}' and u.cefr_level='A1' and l.type='lesson'
      order by u.order_index, l.order_index;""")
    b1_lessons = run_sql(f"""
      select l.id from lessons l join units u on u.id=l.unit_id
      where u.course_id='{C_EN}' and u.cefr_level='B1' and l.type='lesson'
      order by u.order_index, l.order_index;""")
    a1_ids = [r['id'] for r in a1_lessons]
    b1_ids = [r['id'] for r in b1_lessons]

    # ---------- A) GRIND A1: acertar mucho A1 NO debe pasar de A1 ----------
    tok, uid = V.mk_user('unifgrind0710@test.jezici.dev')
    try:
        V.rpc(tok, 'set_active_course', {'p_course_id': C_EN})
        # Sin plan → entry A1. Grind: completa MUCHAS lecciones A1 al 100%.
        for lid in a1_ids[:12]:
            its = items_of_lesson(lid)
            ans = [{'item_id': it['id'], 'answer': answer_for(it)} for it in its]
            complete_lesson_with(tok, lid, ans)
        lv = read_levels(uid)
        maxlv = max((RANK.get(v, 0) for v in lv.values()), default=0)
        ck('A) grind de A1 (12 lecciones al 100%) NO pasa de A1',
           maxlv <= RANK['A1'], lv)
        # jz_skill_mastery A1 debería ser alto (dominó A1)
        m = run_sql(f"select jz_skill_mastery('{uid}','{C_EN}','reading','A1') m")[0]['m']
        ck('   reading A1 mastery alto (dominó A1)', float(m) >= 0.60, f'mastery={m}')
        # radar == certificable: displayed reading vs jz_displayed_level
        disp = run_sql(f"select jz_displayed_level('{uid}','{C_EN}','reading')::text d")[0]['d']
        ck('   radar reading == jz_displayed_level', lv['reading'] == disp, f"radar={lv['reading']} disp={disp}")
    finally:
        V.admin('DELETE', f'/auth/v1/admin/users/{uid}', None)

    # ---------- B) DOMINIO B1: dominar B1 SÍ muestra B1 ----------
    tok, uid = V.mk_user('unifdom0710@test.jezici.dev')
    try:
        V.rpc(tok, 'set_active_course', {'p_course_id': C_EN})
        # Entra con placement B1 (create_plan siembra entry B1).
        V.rpc(tok, 'create_plan', {'p_coach_style': 'suave', 'p_intensity': 3,
            'p_current_level': 'B1', 'p_goal_level': 'C1', 'p_daily_minutes': 10,
            'p_days_per_week': 5, 'p_motive': '', 'p_deadline': None,
            'p_estimated_hours': 400, 'p_estimated_completion': '2027-07-01',
            'p_skill_levels': {'reading': 'B1', 'listening': 'B1', 'writing': 'B1', 'speaking': 'B1'}})
        lv0 = read_levels(uid)
        ck('B) entry del placement respetado (radar reading = B1)', lv0.get('reading') == 'B1', lv0)
        # Domina reading B1: completa muchas lecciones B1 acertando reading.
        for lid in b1_ids:
            its = items_of_lesson(lid)
            ans = [{'item_id': it['id'], 'answer': answer_for(it)} for it in its]
            complete_lesson_with(tok, lid, ans)
        lv = read_levels(uid)
        rmast = run_sql(f"select jz_skill_mastery('{uid}','{C_EN}','reading','B1') m")[0]['m']
        ck('   reading B1 mastery >=0.80 tras dominar B1', float(rmast) >= 0.80, f'mastery={rmast}')
        disp = run_sql(f"select jz_displayed_level('{uid}','{C_EN}','reading')::text d")[0]['d']
        ck('   radar reading == jz_displayed_level (no divergen)', lv['reading'] == disp,
           f"radar={lv['reading']} disp={disp}")
        # exam_ready coherente: mastery>=0.80 en el nivel mostrado
        ready = run_sql(f"select (jz_skill_mastery('{uid}','{C_EN}','reading','{lv['reading']}')>=0.80) r")[0]['r']
        ck('   radar reading es exam-ready (certificable == mostrado)', ready is True, ready)
    finally:
        V.admin('DELETE', f'/auth/v1/admin/users/{uid}', None)

    print('\n' + ('TODO VERDE' if ok else 'HAY FALLOS'))
    raise SystemExit(0 if ok else 1)


if __name__ == '__main__':
    main()
