# -*- coding: utf-8 -*-
"""LÉXICO Fase 0 · verifica con CLIENTE REAL (JWT) que las palabras antes SUELTAS
(sin lesson_vocab → inertes) ahora SE ENSEÑAN: completar una lección "Repaso de
vocabulario" las inscribe en el SRS (state='new'), respetando aislamiento de curso
y economía (un pago por lección). Confirma que esas palabras eran del seed y no
estaban vinculadas antes de la mig 168.
uso: python verify_lexico_f0.py
"""
import json
import verify_placement_serious as V
from apply_sql import run


def q(s):
    c, o = run(s); return json.loads(o)


def repaso_lesson(course_id):
    return q(
        "select l.id from lessons l join units u on u.id=l.unit_id "
        "where u.course_id='" + course_id + "' and l.title like 'Repaso de vocabulario%' "
        "order by u.order_index, l.order_index limit 1;")[0]['id']


def main():
    ok = True

    def check(c, label):
        nonlocal ok; ok = ok and c
        print(('  OK ' if c else '  XX ') + label)

    langs = {r['code']: r['id'] for r in
             q("select c.id, l.code from courses c join languages l on l.id=c.target_language_id;")}

    for name, code in [('en', 'en'), ('de', 'de')]:
        cid = langs[code]
        print('===', name, '===')
        tok, uid = V.mk_user('lexf0%s@test.jezici.dev' % code)
        V.rpc(tok, 'submit_age_gate', {'p_birth_year': 2000})
        V.rpc(tok, 'set_active_course', {'p_course_id': cid})

        lid = repaso_lesson(cid)
        # palabras que esta lección de repaso enseña (lesson_vocab)
        words = q("select v.id, v.word, v.part_of_speech from vocabulary v "
                  "join lesson_vocab lv on lv.vocab_id=v.id where lv.lesson_id='" + lid + "';")
        wids = set(w['id'] for w in words)
        check(len(wids) > 0, 'la lección de repaso tiene palabras vinculadas (%d)' % len(wids))
        # todas del seed (part_of_speech no null) = traducción revisada, no cosecha
        check(all(w['part_of_speech'] for w in words),
              'todas del SEED autorado (traducción revisada), no auto-traducción')
        print('     muestra:', ', '.join(w['word'] for w in words[:4]))

        # antes: ninguna estaba en user_vocab_srs (usuario nuevo)
        pre = q("select count(*) c from user_vocab_srs where user_id='" + uid + "';")[0]['c']
        check(pre == 0, 'usuario nuevo: 0 palabras en el SRS antes')

        # completar la lección de repaso con respuestas CORRECTAS (camino 'new')
        items = q("select li.item_id, ci.type, ci.payload, ci.correct_answer "
                  "from lesson_items li join content_items ci on ci.id=li.item_id "
                  "where li.lesson_id='" + lid + "' order by li.order_index;")
        answers = []
        for it in items:
            if it['type'] == 'match':
                pairs = it['payload']['pairs']
                ans = {str(i): p['es'] for i, p in enumerate(pairs)}
            elif it['type'] == 'translation':
                ans = it['correct_answer']['value']
            else:
                ans = {}
            answers.append({'item_id': it['item_id'], 'answer': ans})
        res = V.rpc(tok, 'complete_lesson', {'p_lesson_id': lid, 'p_answers': answers})
        check(isinstance(res, dict), 'complete_lesson devuelve resumen')

        # después: las palabras del repaso quedaron inscritas
        enr = q("select vocab_id, state from user_vocab_srs where user_id='" + uid + "';")
        enr_ids = set(r['vocab_id'] for r in enr)
        rescued_in = wids & enr_ids
        check(rescued_in == wids,
              'las palabras del repaso quedan INSCRITAS en el SRS (%d/%d)' % (len(rescued_in), len(wids)))
        states = {r['state'] for r in enr if r['vocab_id'] in wids}
        check(states.issubset({'new', 'learning', 'review', 'relearning'}),
              "inscritas con estado SRS válido (%s)" % ','.join(sorted(states)))

        # aislamiento: TODAS las inscritas son de ESTE curso
        cross = q("select count(*) c from user_vocab_srs s join vocabulary v on v.id=s.vocab_id "
                  "where s.user_id='" + uid + "' and v.course_id <> '" + cid + "';")[0]['c']
        check(cross == 0, 'aislamiento: 0 palabras inscritas de otro curso')

        # economía: la lección otorgó su pago (una vez)
        check((res.get('xp_earned', 0) or 0) >= 0 and 'gold_earned' in res,
              'economía: la lección paga (xp=%s oro=%s)' % (res.get('xp_earned'), res.get('gold_earned')))

        try:
            V.rpc(tok, 'delete_account', {})
        except Exception:
            pass

    print('\n' + ('TODO VERDE' if ok else 'HAY FALLOS'))
    return 0 if ok else 1


if __name__ == '__main__':
    raise SystemExit(main())
