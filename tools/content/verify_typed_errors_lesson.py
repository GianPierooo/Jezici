# -*- coding: utf-8 -*-
"""4ª PASADA de errores tipados — verifica con CLIENTE REAL (anon + JWT) que las RPC
de PLAN y LECCIÓN migradas (mig 189: create_plan/complete_lesson/grade_item/
buy_hearts/revive_streak) levantan el SQLSTATE CUSTOM 'JZxxx' CONSERVANDO el
mensaje de siempre (compatibilidad: el fallback por texto del cliente sigue
válido), y que la LÓGICA no cambió (los casos válidos siguen 200 y la economía
se mueve igual).
uso: python verify_typed_errors_lesson.py
"""
import json
import urllib.error

import verify_placement_serious as V
import _introspect as I

EN = '20000000-0000-0000-0000-000000000001'


def err(tok, name, body):
    """Devuelve (http, code, message) del error, o (200, None, payload) si fue bien."""
    try:
        return 200, None, V.rpc(tok, name, body)
    except urllib.error.HTTPError as e:
        raw = e.read().decode()
        try:
            j = json.loads(raw)
            return e.code, j.get('code'), j.get('message')
        except Exception:
            return e.code, None, raw


def main():
    ok = True

    def check(cond, label):
        nonlocal ok
        ok = ok and cond
        print(('  OK ' if cond else '  XX ') + label)

    # ── 1 · SIN SESIÓN (anon): las 5 RPC deben dar JZ401 + 'auth required' ──
    anon = V.AK   # sin sesion: la anon key es el "token" -> auth.uid() es null
    for fn, body in (('grade_item', {'p_item_id': '00000000-0000-0000-0000-000000000000',
                                     'p_answer': {'value': 'x'}}),
                     ('buy_hearts', {}),
                     ('revive_streak', {}),
                     ('complete_lesson', {'p_lesson_id': '00000000-0000-0000-0000-000000000000',
                                          'p_answers': []}),
                     ('create_plan', {'p_coach_style': 'suave', 'p_intensity': 3,
                                      'p_current_level': 'A1', 'p_goal_level': 'B2',
                                      'p_daily_minutes': 20, 'p_days_per_week': 5,
                                      'p_motive': 'viaje', 'p_deadline': None,
                                      'p_estimated_hours': 300,
                                      'p_estimated_completion': None,
                                      'p_skill_levels': None})):
        http, code, msg = err(anon, fn, body)
        check(code == 'JZ401' and msg == 'auth required',
              '%s sin sesión -> JZ401 + "auth required" (code=%s msg=%r)' % (fn, code, msg))

    # ── 2 · usuario real: la LÓGICA sigue igual ──
    tok, uid = V.mk_user('terr4@test.jezici.dev')
    V.rpc(tok, 'submit_age_gate', {'p_birth_year': 1990})
    V.rpc(tok, 'set_active_course', {'p_course_id': EN})

    http, code, r = err(tok, 'create_plan', {
        'p_coach_style': 'suave', 'p_intensity': 3, 'p_current_level': 'A1',
        'p_goal_level': 'B2', 'p_daily_minutes': 20, 'p_days_per_week': 5,
        'p_motive': 'viaje', 'p_deadline': None, 'p_estimated_hours': 300,
        'p_estimated_completion': None, 'p_skill_levels': None})
    check(http == 200, 'create_plan válido -> 200 (lógica intacta)')

    # complete_lesson con una lección INEXISTENTE -> JZ404 + 'lesson not found'
    http, code, msg = err(tok, 'complete_lesson', {
        'p_lesson_id': '00000000-0000-0000-0000-000000000000', 'p_answers': []})
    check(code == 'JZ404' and msg == 'lesson not found',
          'complete_lesson con lección inexistente -> JZ404 + "lesson not found" (code=%s)' % code)

    # complete_lesson REAL: sigue pagando y devolviendo el mapa
    les = I.run("""select l.id from lessons l join units u on u.id=l.unit_id
                    where u.course_id='%s' and u.order_index=1
                      and l.type='lesson' order by l.order_index limit 1;""" % EN)[0]['id']
    # SOLO los itemes cuyo correct_answer.value es escalar: en word_bank/reorder es
    # un ARRAY y `->>'value'` daria null (el verificador enviaria respuestas vacias).
    items = I.run("""select li.item_id id, ci.correct_answer->>'value' v
                       from lesson_items li join content_items ci on ci.id=li.item_id
                      where li.lesson_id='%s'
                        and jsonb_typeof(ci.correct_answer->'value')='string'
                      order by li.order_index;""" % les)
    http, code, r = err(tok, 'complete_lesson', {
        'p_lesson_id': les,
        'p_answers': [{'item_id': i['id'], 'answer': i['v']} for i in items]})
    check(http == 200 and (r or {}).get('gold_earned', 0) > 0
          and (r or {}).get('xp_earned', 0) > 0,
          'complete_lesson REAL -> 200 y mueve la economia (xp=%s oro=%s)'
          % ((r or {}).get('xp_earned'), (r or {}).get('gold_earned')))

    # grade_item real -> 200 (califica server-side)
    # `p_answer` es el VALOR pelado (no {'value': ...}); `p_answers` usa item_id.
    http, code, g = err(tok, 'grade_item',
                        {'p_item_id': items[0]['id'], 'p_answer': items[0]['v']})
    check(http == 200 and (g or {}).get('correct') is True,
          'grade_item con la respuesta correcta -> 200 y correct=true')

    # buy_hearts sin oro suficiente: sigue devolviendo el MOTIVO EN JSON, no excepción
    w = I.run("select gold from user_stats where user_id='%s';" % uid)
    gold = w[0]['gold'] if w else 0
    http, code, b = err(tok, 'buy_hearts', {})
    check(http == 200,
          'buy_hearts con sesión -> 200; el motivo viaja en el JSON, no como excepción (%s, oro=%s)'
          % (json.dumps(b, ensure_ascii=False)[:60], gold))

    # revive_streak: idem (no hay racha perdida que rescatar)
    http, code, s = err(tok, 'revive_streak', {})
    check(http == 200 and (s or {}).get('ok') is False,
          'revive_streak sin racha perdida -> 200 con ok=false (motivo en JSON): %s'
          % json.dumps(s, ensure_ascii=False)[:60])

    print('\n' + ('TODO VERDE' if ok else 'HAY FALLOS'))
    return 0 if ok else 1


if __name__ == '__main__':
    raise SystemExit(main())
