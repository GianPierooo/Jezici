# -*- coding: utf-8 -*-
"""CAUSA RAÍZ DE RETENCIÓN (mig 177) — verifica con CLIENTE REAL (JWT) que:
  P0-A · los casos EXACTOS de las capturas ya se aceptan: "hello" para hola
         (tarjeta 'hi'), "thanks" para gracias ('thank you'), "sorry" para
         disculpa ('excuse me') → correct en submit_practice.
       · una respuesta realmente mal SIGUE siendo mal (no se regala todo).
       · las tarjetas de start_practice('srs') traen `accepted`.
  P1  · el repaso sirve SOLO palabras inscritas (de lecciones COMPLETADAS) →
        alineado al nivel que cursa por construcción (0 palabras F1/A2-B1
        para quien solo completó la lección 1 de A1).
  Economía intacta: un pago por sesión (xp<=20, oro 2).
uso: python verify_srs_synonyms.py
"""
import json
import verify_placement_serious as V
import _introspect as I


def main():
    ok = True

    def check(cond, label):
        nonlocal ok
        ok = ok and cond
        print(('  OK ' if cond else '  XX ') + label)

    # ids reales de las filas de las capturas (curso en)
    rows = I.run("""
      select v.id, v.word from vocabulary v
      join courses c on c.id=v.course_id join languages tl on tl.id=c.target_language_id
      where tl.code='en' and v.word in ('hi','thank you','excuse me');""")
    ids = {r['word']: r['id'] for r in rows}
    check(len(ids) == 3, 'filas hi/thank you/excuse me localizadas')

    tok, uid = V.mk_user('srssyn@test.jezici.dev')

    # ── P0-A · los 3 casos de las capturas + control negativo ──
    answers = [
        {'vocab_id': ids['hi'], 'rating': 3, 'answer': 'hello'},
        {'vocab_id': ids['thank you'], 'rating': 3, 'answer': 'thanks'},
        {'vocab_id': ids['excuse me'], 'rating': 3, 'answer': 'sorry'},
    ]
    r = V.rpc(tok, 'submit_practice', {'p_mode': 'srs', 'p_answers': answers})
    print('  [captura x3] ->', json.dumps({k: r[k] for k in ('graded', 'correct', 'accuracy', 'xp_earned', 'gold_earned')}))
    check(r['graded'] == 3 and r['correct'] == 3,
          'CAPTURAS: hello/thanks/sorry -> 3/3 CORRECTAS (antes: 0/3)')
    check(r['xp_earned'] <= 20 and r['gold_earned'] == 2,
          'economía intacta (un pago, tope 20 XP, oro 2)')

    tok2, _ = V.mk_user('srssyn2@test.jezici.dev')
    r2 = V.rpc(tok2, 'submit_practice', {'p_mode': 'srs', 'p_answers': [
        {'vocab_id': ids['hi'], 'rating': 4, 'answer': 'goodbye'},
    ]})
    check(r2['graded'] == 1 and r2['correct'] == 0,
          'control: "goodbye" para hola sigue siendo MAL (no se regala todo)')
    # (la regla rating-forzado-a-1 en fallo es cuerpo VERBATIM — la cubre verify_srs.py)

    # ── P1 + accepted en la tarjeta · usuario que completa la lección 1 ──
    tok3, uid3 = V.mk_user('srssyn3@test.jezici.dev')
    V.rpc(tok3, 'create_plan', {
        'p_coach_style': 'suave', 'p_intensity': 3, 'p_current_level': 'A1',
        'p_goal_level': 'B2', 'p_daily_minutes': 20, 'p_days_per_week': 5,
        'p_motive': 'viaje', 'p_deadline': None, 'p_estimated_hours': 300,
        'p_estimated_completion': None, 'p_skill_levels': None})
    # primera lección real del mapa
    first = I.run("""
      select l.id from lessons l join units u on u.id=l.unit_id
      join courses c on c.id=u.course_id join languages tl on tl.id=c.target_language_id
      where tl.code='en' and u.order_index=1 and l.type='lesson'
      order by l.order_index limit 1;""")[0]['id']
    items = I.run("select item_id from lesson_items where lesson_id='%s';" % first)
    V.rpc(tok3, 'complete_lesson', {
        'p_lesson_id': first,
        'p_answers': [{'item_id': it['item_id'], 'answer': 'x'} for it in items]})
    s = V.rpc(tok3, 'start_practice', {'p_mode': 'srs', 'p_skill': None, 'p_unit': None})
    cards = s.get('cards') or []
    check(len(cards) > 0, 'tras la lección 1 el SRS sirve tarjetas (%d)' % len(cards))
    check(all('accepted' in c for c in cards), 'todas las tarjetas traen `accepted`')
    # P1: TODAS las tarjetas son de palabras INSCRITAS (lecciones completadas) —
    # nada anclado más arriba (F1/A2-B1) se cuela antes de tiempo.
    enrolled = {r['vocab_id'] for r in I.run(
        "select vocab_id from user_vocab_srs where user_id='%s';" % uid3)}
    served = {c['vocab_id'] for c in cards}
    check(served <= enrolled,
          'P1: el repaso sirve SOLO palabras inscritas (de lo que YA cursó) — %d/%d' % (
              len(served & enrolled), len(served)))
    # P1 estricto: TODA palabra inscrita viene de una lección que el usuario
    # COMPLETÓ (nada anclado más arriba se cuela antes de tiempo). Nota: una
    # palabra puede estar vinculada además a lecciones superiores (p.ej. un
    # repaso A2) — lo que importa es que LLEGÓ por la lección completada.
    huerfanas = I.run("""
      select count(*) n from user_vocab_srs s
      where s.user_id='%s'
        and not exists (
          select 1 from lesson_vocab lv
          join user_lesson_progress ulp on ulp.lesson_id = lv.lesson_id
           and ulp.user_id = s.user_id and ulp.status = 'completed'
          where lv.vocab_id = s.vocab_id);""" % uid3)[0]['n']
    check(huerfanas == 0,
          'P1: toda palabra inscrita viene de una lección COMPLETADA (0 huérfanas)')

    for t in (tok, tok2, tok3):
        try:
            V.rpc(t, 'delete_account', {})
        except Exception:
            pass
    print('\n' + ('TODO VERDE' if ok else 'HAY FALLOS'))
    return 0 if ok else 1


if __name__ == '__main__':
    raise SystemExit(main())
