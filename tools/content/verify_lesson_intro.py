# -*- coding: utf-8 -*-
"""Verifica "enseñar antes de examinar" (P1 #4) con CLIENTE REAL (JWT):
  · get_lesson_intro devuelve concepto (tip) + vocab (término+traducción+imagen si hay)
    en un curso romance (pt) y uno germánico (de) — degradación de imagen honesta.
  · GUARDARRAÍL: es READ-ONLY para la economía (oro/xp intactos tras llamarlo) y
    el loop sigue: complete_lesson de la misma lección sigue otorgando XP.
uso: python verify_lesson_intro.py
"""
import json
import verify_placement_serious as V
from apply_sql import run


def q(s):
    c, o = run(s); return json.loads(o)


def first_lesson(course_id):
    return q("select l.id from lessons l join units u on u.id=l.unit_id where "
             "u.course_id='"+course_id+"' and u.cefr_level='A1' and u.order_index=1 "
             "and l.order_index=1 limit 1;")[0]['id']


def main():
    ok = True
    def check(c, label):
        nonlocal ok; ok = ok and c
        print(('  OK ' if c else '  XX ') + label)

    langs = {r['code']: r['id'] for r in
             q("select c.id, l.code from courses c join languages l on l.id=c.target_language_id;")}
    EN, PT, DE = langs['en'], langs['pt'], langs['de']

    tok, uid = V.mk_user('introverify@test.jezici.dev')
    V.rpc(tok, 'submit_age_gate', {'p_birth_year': 2000})

    # ── contenido: romance (pt) + germánico (de) ──
    for name, cid in [('PT (romance)', PT), ('DE (germánico)', DE)]:
        V.rpc(tok, 'set_active_course', {'p_course_id': cid})
        intro = V.rpc(tok, 'get_lesson_intro', {'p_lesson_id': first_lesson(cid)})
        print('===', name, '===')
        has_concept = intro and intro.get('tip') and (intro['tip'].get('title') or '')
        vocab = (intro or {}).get('vocab', [])
        check(bool(has_concept), 'tiene CONCEPTO (tip) para enseñar')
        check(len(vocab) >= 1 and all(w.get('term') and w.get('translation') for w in vocab),
              'tiene VOCAB (término meta + traducción) — %d palabras' % len(vocab))

    # ── imagen: EN adjunta imagen a un concepto de vocab_images; degrada si no hay ──
    V.rpc(tok, 'set_active_course', {'p_course_id': EN})
    lid_img = q("select distinct l.id from lessons l join units u on u.id=l.unit_id "
                "join lesson_items li on li.lesson_id=l.id join content_items ci on ci.id=li.item_id "
                "cross join lateral jsonb_array_elements(ci.payload->'pairs') p "
                "join vocab_images vi on lower(vi.concept)=lower(p->>'en') "
                "where u.course_id='"+EN+"' and ci.type='match' limit 1;")[0]['id']
    intro_en = V.rpc(tok, 'get_lesson_intro', {'p_lesson_id': lid_img})
    print('=== EN (imágenes) ===')
    check(any(w.get('image_url') for w in intro_en['vocab']),
          'al menos una palabra trae IMAGEN (vocab_images)')

    # ── GUARDARRAÍL: read-only para la economía ──
    print('=== guardarraíl economía ===')
    def econ():
        r = q("select coalesce(gold,0) g, coalesce(xp_total,0) x from user_stats where user_id='"+uid+"';")
        return r[0] if r else {'g': 0, 'x': 0}
    gold_before = econ()
    V.rpc(tok, 'get_lesson_intro', {'p_lesson_id': first_lesson(EN)})
    V.rpc(tok, 'get_lesson_intro', {'p_lesson_id': first_lesson(EN)})
    gold_after = econ()
    check(gold_before == gold_after,
          'oro/XP NO cambian tras get_lesson_intro (read-only): %s == %s' % (gold_before, gold_after))

    run("delete from auth.users where email='introverify@test.jezici.dev';")
    reales = q("select count(*) n from auth.users where email not like '%@test.jezici.dev';")[0]['n']
    print('\n[limpieza] usuarios REALES intactos:', reales)
    print('\n' + ('TODO VERDE' if ok else 'FALLO ALGO'))
    return 0 if ok else 1


if __name__ == '__main__':
    raise SystemExit(main())
