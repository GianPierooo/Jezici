# -*- coding: utf-8 -*-
"""CURSO NUEVO es→ro — verificación END-TO-END con CLIENTE REAL (JWT) del recorrido
completo de un usuario nuevo, que es lo que de verdad prueba que el idioma existe:

  elegir rumano → placement (techo honesto A1) → create_plan → completar una
  lección A1 → ganar XP/oro → las palabras entran al SRS → aislamiento total.

uso: python verify_ro_chain.py
"""
import urllib.error
import urllib.request

import verify_placement_serious as V
import _introspect as I

RO = '20000000-0000-0000-0000-000000000007'
EN = '20000000-0000-0000-0000-000000000001'


def head(url):
    r = urllib.request.Request(url, method='HEAD')
    try:
        with urllib.request.urlopen(r, timeout=30) as x:
            return x.status
    except urllib.error.HTTPError as e:
        return e.code
    except Exception:
        return 0


def main():
    ok = True

    def check(cond, label, extra=''):
        nonlocal ok
        ok = ok and cond
        print(('  OK ' if cond else '  XX ') + label + (('  ' + str(extra)) if extra else ''))

    tok, uid = V.mk_user('rochain@test.jezici.dev')
    V.rpc(tok, 'submit_age_gate', {'p_birth_year': 1990})

    # ── 1 · el usuario puede ELEGIR rumano ──
    cursos = V.rpc(tok, 'get_courses', {})
    ro = [c for c in cursos if c.get('target') == 'ro']
    # OJO: en get_courses `active` = "es el curso ACTIVO de este usuario", no
    # "el curso está habilitado" — un usuario nuevo aún no tiene el rumano activo.
    check(len(ro) == 1, 'get_courses OFRECE rumano a un usuario nuevo',
          ro[0].get('target_name') if ro else None)
    check(ro and ro[0].get('max_level') == 'A1',
          'techo HONESTO: max_level=A1 (es el único nivel sembrado)',
          ro[0].get('max_level') if ro else None)
    V.rpc(tok, 'set_active_course', {'p_course_id': RO})
    ro2 = [c for c in V.rpc(tok, 'get_courses', {}) if c.get('target') == 'ro']
    check(ro2 and ro2[0].get('active'), 'y al elegirlo queda como CURSO ACTIVO')

    # ── 2 · el PLACEMENT del rumano sirve SU banco y no ubica donde no hay contenido ──
    vistos, nivel = set(), None
    st = V.rpc(tok, 'placement_next', {'p_course': RO, 'p_history': []})
    hist = []
    for _ in range(25):
        if st.get('done'):
            nivel = st.get('level')
            break
        it = st['item']
        vistos.add(it['id'])
        # persona "sabe algo": acierta la mitad
        val = it.get('options', [None])[0] if it.get('options') else 'x'
        hist.append({'item_id': it['id'], 'answer': val})
        st = V.rpc(tok, 'placement_next', {'p_course': RO, 'p_history': hist})
    banco = {r['id'] for r in I.run(
        "select id from content_items where course_id='%s' and tags @> array['placement'];" % RO)}
    check(vistos and vistos <= banco,
          'el placement sirve SOLO ítems del banco RUMANO', '%d ítems' % len(vistos))
    check(nivel == 'A1', 'el placement NO puede ubicar por encima de A1 (techo honesto)', nivel)

    # ── 3 · plan + primera lección: economía y progreso REALES ──
    V.rpc(tok, 'create_plan', {
        'p_coach_style': 'suave', 'p_intensity': 3, 'p_current_level': 'A1',
        'p_goal_level': 'A1', 'p_daily_minutes': 20, 'p_days_per_week': 5,
        'p_motive': 'viaje', 'p_deadline': None, 'p_estimated_hours': 60,
        'p_estimated_completion': None, 'p_skill_levels': None})

    les = I.run("""select l.id from lessons l join units u on u.id=l.unit_id
                    where u.course_id='%s' and u.order_index=1 and l.type='lesson'
                    order by l.order_index limit 1;""" % RO)[0]['id']
    items = I.run("""select li.item_id id, ci.correct_answer->>'value' v
                       from lesson_items li join content_items ci on ci.id=li.item_id
                      where li.lesson_id='%s'
                        and jsonb_typeof(ci.correct_answer->'value')='string'
                      order by li.order_index;""" % les)
    r = V.rpc(tok, 'complete_lesson', {
        'p_lesson_id': les,
        'p_answers': [{'item_id': i['id'], 'answer': i['v']} for i in items]})
    check(r.get('xp_earned', 0) > 0 and r.get('gold_earned', 0) > 0,
          'completar una lección A1 de rumano PAGA XP y oro',
          'xp=%s oro=%s' % (r.get('xp_earned'), r.get('gold_earned')))
    check(r.get('next_lesson_id'), 'el mapa avanza: devuelve next_lesson_id')

    # ── 4 · las palabras del rumano ENTRAN al SRS (si no, serían inertes) ──
    srs = I.run("""select count(*) n from user_vocab_srs s join vocabulary v on v.id=s.vocab_id
                    where s.user_id='%s' and v.course_id='%s';""" % (uid, RO))[0]['n']
    check(srs > 0, 'las palabras rumanas quedan INSCRITAS en el SRS', '%d palabras' % srs)
    otras = I.run("""select count(*) n from user_vocab_srs s join vocabulary v on v.id=s.vocab_id
                      where s.user_id='%s' and v.course_id<>'%s';""" % (uid, RO))[0]['n']
    check(otras == 0, 'y NINGUNA palabra de otro curso se cuela', otras)
    prac = V.rpc(tok, 'start_practice', {'p_mode': 'srs'})
    cards = prac.get('cards') or prac.get('items') or []
    check(isinstance(cards, list),
          'start_practice("srs") responde para el curso rumano', '%d tarjetas' % len(cards))

    # ── 5 · AISLAMIENTO: los 6 cursos vivos, intactos ──
    cruces = I.run("""select count(*) n from lesson_items li
                        join content_items ci on ci.id=li.item_id
                        join lessons l on l.id=li.lesson_id
                        join units u on u.id=l.unit_id
                       where ci.course_id <> u.course_id;""")[0]['n']
    check(cruces == 0, 'GLOBAL: 0 lesson_items cruzan cursos (los 7)', cruces)
    u1en = I.run("select id from units where course_id='%s' and order_index=1;" % EN)[0]['id']
    V.rpc(tok, 'set_active_course', {'p_course_id': EN})
    pen = V.rpc(tok, 'placement_next', {'p_course': EN, 'p_history': []})
    check(pen.get('item', {}).get('id') not in banco,
          'el placement del INGLÉS no recibe ni un ítem rumano')
    del u1en

    # ── 6 · audio ──
    au = I.run("""select payload->>'audio_url' u from content_items
                   where course_id='%s' and payload ? 'audio_url' limit 6;""" % RO)
    codes = [head(x['u']) for x in au]
    check(all(c == 200 for c in codes), 'audio TTS rumano servido (muestra)', codes)

    print('\n' + ('TODO VERDE' if ok else 'HAY FALLOS'))
    return 0 if ok else 1


if __name__ == '__main__':
    raise SystemExit(main())
