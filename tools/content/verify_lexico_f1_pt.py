# -*- coding: utf-8 -*-
"""LÉXICO Fase 1 (inglés) · verifica con CLIENTE REAL (JWT) que las palabras NUEVAS
se enseñan, entran al SRS al completar su lección de "Vocabulario", y que el SRS las
sirve como tarjeta CLOZE EN CONTEXTO con AUDIO (paga F3). Economía = un pago/lección.
uso: python verify_lexico_f1_en.py
"""
import json, urllib.request
import verify_placement_serious as V


def q(s):
    c, o = run(s); return json.loads(o)


from apply_sql import run


def main():
    ok = True

    def check(c, label):
        nonlocal ok; ok = ok and c
        print(('  OK ' if c else '  XX ') + label)

    cid = q("select c.id from courses c join languages l on l.id=c.target_language_id where l.code='pt'")[0]['id']
    tok, uid = V.mk_user('lexf1pt@test.jezici.dev')
    V.rpc(tok, 'submit_age_gate', {'p_birth_year': 2000})
    V.rpc(tok, 'set_active_course', {'p_course_id': cid})

    # una lección de "Vocabulario:" nueva (F1)
    lid = q("select l.id from lessons l join units u on u.id=l.unit_id "
            "where u.course_id='" + cid + "' and l.title like 'Vocabulario:%' "
            "order by u.order_index, l.order_index limit 1;")[0]['id']
    words = q("select v.id, v.word, v.translation, v.part_of_speech from vocabulary v "
              "join lesson_vocab lv on lv.vocab_id=v.id where lv.lesson_id='" + lid + "';")
    wids = set(w['id'] for w in words)
    check(len(wids) >= 8, 'la lección Vocabulario tiene palabras vinculadas (%d)' % len(wids))
    print('     muestra:', ', '.join('%s=%s' % (w['word'], w['translation']) for w in words[:4]))

    # completar con respuestas CORRECTAS
    items = q("select li.item_id, ci.type, ci.payload, ci.correct_answer "
              "from lesson_items li join content_items ci on ci.id=li.item_id "
              "where li.lesson_id='" + lid + "' order by li.order_index;")
    answers = []
    for it in items:
        if it['type'] == 'match':
            answers.append({'item_id': it['item_id'],
                            'answer': {str(i): p['es'] for i, p in enumerate(it['payload']['pairs'])}})
        elif it['type'] == 'cloze':
            answers.append({'item_id': it['item_id'], 'answer': it['correct_answer']['value']})
        else:
            answers.append({'item_id': it['item_id'], 'answer': {}})
    res = V.rpc(tok, 'complete_lesson', {'p_lesson_id': lid, 'p_answers': answers})
    check(isinstance(res, dict), 'complete_lesson devuelve resumen')

    enr = q("select vocab_id, state from user_vocab_srs where user_id='" + uid + "';")
    enr_ids = set(r['vocab_id'] for r in enr)
    check(wids <= enr_ids, 'las palabras nuevas quedan INSCRITAS en el SRS (%d/%d)' % (len(wids & enr_ids), len(wids)))

    # el SRS las sirve como CLOZE con AUDIO (F3)
    sess = V.rpc(tok, 'start_practice', {'p_mode': 'srs'})
    cards = sess.get('cards', []) if isinstance(sess, dict) else []
    cloze = [c for c in cards if c.get('kind') == 'cloze']
    withaudio = [c for c in cloze if c.get('audio_url')]
    check(len(cloze) > 0, 'el SRS sirve tarjetas CLOZE en contexto (%d)' % len(cloze))
    check(len(withaudio) > 0, 'las tarjetas cloze traen AUDIO (paga F3): %d con audio_url' % len(withaudio))
    if withaudio:
        au = withaudio[0]['audio_url']
        try:
            rq = urllib.request.Request(au, method='HEAD'); rq.add_header('User-Agent', 'Mozilla/5.0')
            code = urllib.request.urlopen(rq, timeout=20).status
        except Exception as e:
            code = str(e)
        check(code == 200, 'el audio de la tarjeta cloze existe (HEAD %s)' % code)
        print('     cloze ej:', withaudio[0].get('sentence'))

    # aislamiento: todas las inscritas son de en
    cross = q("select count(*) c from user_vocab_srs s join vocabulary v on v.id=s.vocab_id "
              "where s.user_id='" + uid + "' and v.course_id <> '" + cid + "';")[0]['c']
    check(cross == 0, 'aislamiento: 0 palabras inscritas de otro curso')
    check('gold_earned' in res, 'economía: la lección paga (xp=%s oro=%s)' % (res.get('xp_earned'), res.get('gold_earned')))

    try:
        V.rpc(tok, 'delete_account', {})
    except Exception:
        pass
    print('\n' + ('TODO VERDE' if ok else 'HAY FALLOS'))
    return 0 if ok else 1


if __name__ == '__main__':
    raise SystemExit(main())
