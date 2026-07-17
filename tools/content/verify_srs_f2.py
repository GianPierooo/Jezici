# -*- coding: utf-8 -*-
"""SRS F2 · verifica con CLIENTE REAL (JWT) que completar una lección inscribe en el
SRS EXACTAMENTE las palabras que enseña (según lesson_vocab), no aproximadas por
substring; que incluye las palabras del `match` (que el substring no veía); que las
falladas quedan con prioridad; y que economía/mapa siguen intactos.
uso: python verify_srs_f2.py
"""
import json
import verify_placement_serious as V
from apply_sql import run


def q(s):
    c, o = run(s); return json.loads(o)


def first_match_lesson(course_id):
    # primera lección (por orden) que tiene un ítem `match` y mapeo lesson_vocab
    return q(
        "select l.id from lessons l join units u on u.id=l.unit_id "
        "join lesson_items li on li.lesson_id=l.id join content_items ci on ci.id=li.item_id "
        "join lesson_vocab lv on lv.lesson_id=l.id "
        "where u.course_id='"+course_id+"' and ci.type='match' and l.type='lesson' "
        "order by u.order_index, l.order_index limit 1;")[0]['id']


def main():
    ok = True
    def check(c, label):
        nonlocal ok; ok = ok and c
        print(('  OK ' if c else '  XX ') + label)

    langs = {r['code']: r['id'] for r in
             q("select c.id, l.code from courses c join languages l on l.id=c.target_language_id;")}

    for name, code in [('pt (romance)', 'pt'), ('de (germánico)', 'de')]:
        cid = langs[code]
        print('===', name, '===')
        tok, uid = V.mk_user('srsf2%s@test.jezici.dev' % code)
        V.rpc(tok, 'submit_age_gate', {'p_birth_year': 2000})
        V.rpc(tok, 'set_active_course', {'p_course_id': cid})

        lid = first_match_lesson(cid)
        # lo que lesson_vocab dice que enseña esta lección
        lv = set(r['vocab_id'] for r in
                 q("select vocab_id from lesson_vocab where lesson_id='"+lid+"';"))
        # palabras que enseña vía MATCH (para probar que el substring las perdía)
        match_terms = q(
            "select distinct jz_normalize(p->>'en') w from lesson_items li "
            "join content_items ci on ci.id=li.item_id "
            "cross join lateral jsonb_array_elements(ci.payload->'pairs') p "
            "where li.lesson_id='"+lid+"' and ci.type='match';")
        match_vocab = set(r['vocab_id'] for r in q(
            "select v.id vocab_id from vocabulary v where v.course_id='"+cid+"' and jz_normalize(v.word) in ("
            + ",".join("'"+t['w'].replace("'", "''")+"'" for t in match_terms) + ");")) if match_terms else set()

        # items de la lección para armar answers (respuestas vacías → grading normal)
        items = q("select li.item_id from lesson_items li where li.lesson_id='"+lid+"' order by li.order_index;")
        answers = [{'item_id': it['item_id'], 'answer': {}} for it in items]

        gold0 = q("select coalesce(gold,0) g, coalesce(xp_total,0) x from user_stats where user_id='"+uid+"';")
        res = V.rpc(tok, 'complete_lesson', {'p_lesson_id': lid, 'p_answers': answers})

        enrolled = set(r['vocab_id'] for r in
                       q("select vocab_id from user_vocab_srs where user_id='"+uid+"';"))

        check(enrolled == lv and len(lv) > 0,
              'inscritas == lesson_vocab EXACTO (%d palabras, no substring aprox.)' % len(lv))
        check(len(match_vocab) > 0 and match_vocab.issubset(enrolled),
              'incluye las palabras del MATCH (%d) que el substring NO veía' % len(match_vocab))
        # falladas con prioridad due<=now (respuestas vacías → varias falladas)
        due_now = q("select count(*) n from user_vocab_srs where user_id='"+uid+"' and due_at is not null and due_at<=now();")[0]['n']
        check(due_now >= 1, 'hay palabras FALLADAS con prioridad (due<=now): %d' % due_now)
        # economía / mapa intactos
        gold1 = q("select coalesce(gold,0) g, coalesce(xp_total,0) x from user_stats where user_id='"+uid+"';")
        check(res.get('xp_earned') is not None and res.get('gold_earned') is not None
              and gold1[0]['g'] >= gold0[0]['g'] and gold1[0]['x'] >= gold0[0]['x'],
              'economía intacta (xp/oro otorgados: xp=%s oro=%s)' % (res.get('xp_earned'), res.get('gold_earned')))
        check('next_lesson_id' in res, 'progresión del mapa intacta (next_lesson_id presente)')

        run("delete from auth.users where email='srsf2%s@test.jezici.dev';" % code)

    reales = q("select count(*) n from auth.users where email not like '%@test.jezici.dev';")[0]['n']
    print('\n[limpieza] usuarios REALES intactos:', reales)
    print('\n' + ('TODO VERDE' if ok else 'FALLO ALGO'))
    return 0 if ok else 1


if __name__ == '__main__':
    raise SystemExit(main())
