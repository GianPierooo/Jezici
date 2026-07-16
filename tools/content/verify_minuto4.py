# -*- coding: utf-8 -*-
"""Verifica el "MINUTO 4" con CLIENTE REAL (JWT), reproduciendo el caso de
@eugenio (primer usuario real que no es Gian):

  usuario nuevo -> onboarding (45 min/dia, como el) -> 1 LECCION REAL
  => gana su PRIMERA RACHA el dia 1 (antes: meta 45, gano 17, racha 0)
  => tiene un SIGUIENTE PASO (next_lesson_id)
  => Practicar YA le muestra palabras (no un vacio)

uso: python verify_minuto4.py
"""
import json
import verify_placement_serious as V
from apply_sql import run


def q(sql):
    c, o = run(sql)
    if not o.strip().startswith('['):
        raise SystemExit('SQL fallo: %s' % o[:300])
    return json.loads(o)


def main():
    ok = True

    def check(cond, label):
        nonlocal ok
        ok = ok and cond
        print(('  OK ' if cond else '  XX ') + label)

    cy = q('select extract(year from current_date)::int y')[0]['y']
    EN = q("select c.id from courses c join languages l on l.id=c.target_language_id "
           "where l.code='en';")[0]['id']

    tok, uid = V.mk_user('minuto4@test.jezici.dev')
    V.rpc(tok, 'submit_age_gate', {'p_birth_year': cy - 30})
    V.rpc(tok, 'set_active_course', {'p_course_id': EN})
    # EXACTAMENTE su configuracion: 45 min/dia.
    V.rpc(tok, 'create_plan', {
        'p_coach_style': 'suave', 'p_intensity': 3, 'p_current_level': 'A1',
        'p_goal_level': 'B2', 'p_daily_minutes': 45, 'p_days_per_week': 5,
        'p_motive': 'viaje', 'p_deadline': None, 'p_estimated_hours': 300,
        'p_estimated_completion': None, 'p_skill_levels': None})

    # ── Estado ANTES: Practicar vacio, sin racha ────────────────────────────
    st0 = V.rpc(tok, 'get_srs_status', {})
    check(st0['total_cards'] == 0, 'antes de la leccion: 0 palabras en el SRS')
    check(q("select coalesce(current_streak,0) s from streaks where user_id='%s';" % uid)
          [0]['s'] == 0 if q("select count(*) n from streaks where user_id='%s';" % uid)[0]['n']
          else True, 'antes de la leccion: sin racha')

    # ── 1 LECCION REAL (la 1a del mapa, respondida BIEN) ────────────────────
    lesson = q("""select l.id from lessons l join units u on u.id=l.unit_id
                  where u.course_id='%s' and u.order_index=1 and l.type='lesson'
                  order by l.order_index limit 1;""" % EN)[0]['id']
    items = q("""select ci.id, ci.type::text t, ci.correct_answer ca
                 from lesson_items li join content_items ci on ci.id=li.item_id
                 where li.lesson_id='%s' order by li.order_index;""" % lesson)
    answers = [{'item_id': it['id'],
                'answer': (it['ca'] or {}).get('value')} for it in items]
    r = V.rpc(tok, 'complete_lesson', {'p_lesson_id': lesson, 'p_answers': answers})
    print('\n  [leccion real] xp=%s oro=%s acc=%s' % (r['xp_earned'], r['gold_earned'], r['accuracy']))

    # ── 1. RACHA ALCANZABLE EL DIA 1 ────────────────────────────────────────
    print('\n=== 1. RACHA EL DIA 1 (el fallo de @eugenio) ===')
    print('  meta del dia: %s (su meta comprometida: 45)' % r['daily_goal_xp'])
    check(r['daily_goal_xp'] == 15,
          'la meta del dia 1 es la RAMPA (15), no los 45 comprometidos')
    check(r['goal_met'] is True, 'UNA leccion CUMPLE la meta del dia 1')
    check(r['streak'] >= 1, 'gana su PRIMERA RACHA con 1 leccion (streak=%s) <- antes: 0'
          % r['streak'])
    check(q("select daily_minutes m from user_plans where user_id='%s';" % uid)[0]['m'] == 45,
          'su meta comprometida NO se toco (daily_minutes=45 -> plan/fecha intactos)')

    # ── 2. SIGUIENTE PASO ───────────────────────────────────────────────────
    print('\n=== 2. SIGUIENTE PASO tras la leccion ===')
    check(r.get('next_lesson_id') is not None,
          'el servidor da next_lesson_id -> el CTA "Siguiente leccion" tiene a donde ir')
    if r.get('next_lesson_id'):
        nxt = q("select l.type::text t, l.order_index o from lessons l where l.id='%s';"
                % r['next_lesson_id'])[0]
        print('     -> siguiente: %s #%s' % (nxt['t'], nxt['o']))

    # ── 3. PRACTICAR YA NO ES UN VACIO ──────────────────────────────────────
    print('\n=== 3. PRACTICAR tras 1 leccion (volvio 4 veces y no habia nada) ===')
    st = V.rpc(tok, 'get_srs_status', {})
    print('  inscritas=%s  nuevas_disponibles=%s  vencidas=%s  sesion=%s'
          % (st['total_cards'], st['new_available'], st['due'],
             st['due'] + min(st['new_available'], st['new_left'])))
    check(st['total_cards'] > 0,
          'la leccion INSCRIBIO palabras (%s) <- antes: 0' % st['total_cards'])
    s = V.rpc(tok, 'start_practice', {'p_mode': 'srs', 'p_skill': None, 'p_unit': None})
    check(len(s['cards']) > 0,
          'Practicar le SIRVE %d tarjetas reales (antes: "nada que repasar")' % len(s['cards']))
    check(all(c['kind'] in ('word', 'cloze') for c in s['cards']),
          'y son de ESCRITURA (word|cloze), no opcion multiple')

    # ── limpieza (NUNCA usuarios reales) ────────────────────────────────────
    run("delete from auth.users where email='minuto4@test.jezici.dev';")
    reales = q("select count(*) n from auth.users where email not like '%@test.jezici.dev';")[0]['n']
    print('\n[limpieza] usuarios REALES intactos: %d' % reales)

    print('\n' + ('TODO VERDE' if ok else 'FALLO ALGO'))
    return 0 if ok else 1


if __name__ == '__main__':
    raise SystemExit(main())
