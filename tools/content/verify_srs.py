# -*- coding: utf-8 -*-
"""Verifica el SRS F0+F1 con CLIENTE REAL (JWT) en 2 idiomas (romance + germánico),
según el criterio de cierre de PRACTICAR_SRS_ANALISIS.md §7:

  cola con vencidas + nuevas (con límite) · ESCRITURA (no MC) · 4 botones ·
  reprogramación FSRS · XP/oro UNA vez por sesión (no por tarjeta) · racha ·
  retención · sin romper lecciones/economía.

uso: python verify_srs.py            (default: pt = romance, de = germánico)
     python verify_srs.py fr nl
"""
import sys, json, urllib.error
import verify_placement_serious as V
from apply_sql import run

COURSE_BY_CODE = {}


def q(sql):
    c, o = run(sql)
    if not o.strip().startswith('['):
        raise SystemExit('SQL fallo: %s' % o[:300])
    return json.loads(o)


def rpc_raw(tok, name, body):
    try:
        return 200, V.rpc(tok, name, body)
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode()


def course_of(code):
    if code not in COURSE_BY_CODE:
        r = q("select c.id from courses c join languages l on l.id=c.target_language_id "
              "where l.code='%s';" % code)
        COURSE_BY_CODE[code] = r[0]['id']
    return COURSE_BY_CODE[code]


def main():
    langs = sys.argv[1:3] or ['pt', 'de']
    ok_all = True
    cy = q("select extract(year from current_date)::int y")[0]['y']

    for code in langs:
        print('\n' + '=' * 62)
        print('IDIOMA: %s' % code.upper())
        print('=' * 62)
        ok = True

        def check(cond, label):
            nonlocal ok, ok_all
            ok = ok and cond
            ok_all = ok_all and cond
            print(('  OK ' if cond else '  XX ') + label)

        tok, uid = V.mk_user('srsverify_%s@test.jezici.dev' % code)
        V.rpc(tok, 'submit_age_gate', {'p_birth_year': cy - 30})
        V.rpc(tok, 'set_active_course', {'p_course_id': course_of(code)})

        # ── 1. Cola VACÍA al inicio: ya no sirve las ~480 del curso ──────────
        s = V.rpc(tok, 'start_practice', {'p_mode': 'srs', 'p_skill': None, 'p_unit': None})
        st = V.rpc(tok, 'get_srs_status', {})
        check(len(s.get('cards', [])) == 0,
              'usuario nuevo: cola VACIA (antes servia las ~480 del curso)')
        check(s.get('due_count') == 0, 'due_count = 0 (no inventa vencidas)')
        check(st['total_cards'] == 0, 'get_srs_status: 0 tarjetas inscritas')
        check(st['retention_pct'] is None, 'retencion = null sin datos (no inventa %)')

        # ── 2. Inscripción: simular que vio vocabulario (via jz_srs_enroll) ──
        # (En la app real lo hace complete_lesson; aquí inscribimos directo para
        #  aislar el motor. La cadena real se prueba con verify_chain/pt_chain.)
        vocab = q("select id, word, translation from vocabulary where course_id='%s' "
                  "order by frequency_rank limit 25;" % course_of(code))
        ids = ','.join("'%s'::uuid" % v['id'] for v in vocab)
        q("select jz_srs_enroll('%s'::uuid, '%s'::uuid, array[%s], false);"
          % (uid, course_of(code), ids))
        st = V.rpc(tok, 'get_srs_status', {})
        # >= 25 y no == 25: las entradas MULTI-PALABRA arrastran legítimamente sus
        # sub-palabras ("até logo" contiene "logo") → inscribe de más por diseño del
        # substring. Es correcto: si viste "até logo", viste "logo".
        check(st['total_cards'] >= 25,
              'inscritas >=25 palabras (state=new, sin due) [total=%d]' % st['total_cards'])
        check(st['due'] == 0, 'las nuevas NO cuentan como vencidas')

        # ── 3. LÍMITE de nuevas/día desde jz_config ─────────────────────────
        cap = q("select value_int v from jz_config where key='srs_new_per_day';")[0]['v']
        s = V.rpc(tok, 'start_practice', {'p_mode': 'srs', 'p_skill': None, 'p_unit': None})
        cards = s['cards']
        check(len(cards) == cap,
              'la cola respeta el limite de nuevas/dia (%d de jz_config)' % cap)

        # ── 4. ESCRITURA + degradación con gracia ───────────────────────────
        kinds = {c['kind'] for c in cards}
        check(kinds.issubset({'cloze', 'word'}), 'tipos de tarjeta: solo cloze|word')
        check('multiple_choice' not in json.dumps(cards),
              'NO hay opcion multiple (anti-feature eliminado)')
        check(all(c.get('translation') for c in cards), 'cada tarjeta trae su traduccion')
        cl = [c for c in cards if c['kind'] == 'cloze']
        check(all(c.get('sentence') for c in cl), 'las cloze traen oracion (o no son cloze)')
        print('     degradacion: %d cloze / %d escritura-sin-oracion' % (len(cl), len(cards) - len(cl)))

        # ── 5. Sesión: escribir bien 3, mal 1 → FSRS reprograma ─────────────
        picked = cards[:4]
        answers = []
        for i, c in enumerate(picked):
            good = i < 3
            answers.append({
                'vocab_id': c['vocab_id'],
                'rating': 3 if good else 1,
                'answer': c['word'] if good else 'zzzz_respuesta_incorrecta',
            })
        r = V.rpc(tok, 'submit_practice', {'p_mode': 'srs', 'p_answers': answers})
        check(r['graded'] == 4 and r['correct'] == 3,
              'califica lo ESCRITO server-side: 3/4 (graded=%s correct=%s)' % (r['graded'], r['correct']))
        check(r['xp_earned'] == min(3 * 3, 20), 'XP = least(correct*3, 20) = %s' % r['xp_earned'])
        check(r['gold_earned'] == 2, 'oro = 2 (menos que una leccion: 5-10)')
        # La racha NO avanza por repasar: avanza al CUMPLIR LA META DIARIA (regla
        # pre-existente de jz_register_activity: `if v_met and ...`). Lo que el SRS
        # debe garantizar es que su XP ALIMENTA la meta, igual que una lección.
        dg = q("select goal_xp, xp_earned from daily_goals where user_id='%s' "
               "and goal_date=current_date;" % uid)[0]
        check(dg['xp_earned'] == r['xp_earned'],
              'el XP del repaso alimenta daily_goals (%s/%s)' % (dg['xp_earned'], dg['goal_xp']))

        rows = q("select v.word, s.state, s.stability, s.difficulty, s.interval_days, s.lapses, "
                 "s.due_at <= now() as due_now from user_vocab_srs s join vocabulary v on v.id=s.vocab_id "
                 "where s.user_id='%s' and s.last_reviewed_at is not null order by s.state;" % uid)
        good_rows = [x for x in rows if x['state'] == 'review']
        bad_rows = [x for x in rows if x['state'] in ('learning', 'relearning')]
        check(len(good_rows) == 3, 'las 3 acertadas -> state=review')
        check(all(float(x['stability']) > 0 and x['interval_days'] >= 1 for x in good_rows),
              'FSRS asigno stability>0 e intervalo>=1d a las acertadas')
        check(len(bad_rows) == 1 and bad_rows[0]['due_now'],
              'la fallada -> learning/relearning y VUELVE en la sesion (due=now)')

        # ── 6. Bitácora + retención ─────────────────────────────────────────
        n_log = q("select count(*) n from srs_review_log where user_id='%s';" % uid)[0]['n']
        check(n_log == 4, 'srs_review_log guardo las 4 reviews (base de retencion)')

        # ── 7. ANTI-DUPLICADO: la relapsada reaparece y NO paga 2 veces ──────
        before = q("select xp_total, gold from user_stats where user_id='%s';" % uid)[0]
        bad = picked[3]
        again = [
            {'vocab_id': bad['vocab_id'], 'rating': 1, 'answer': 'mal_otra_vez'},
            {'vocab_id': bad['vocab_id'], 'rating': 3, 'answer': bad['word']},
        ]
        r2 = V.rpc(tok, 'submit_practice', {'p_mode': 'srs', 'p_answers': again})
        after = q("select xp_total, gold from user_stats where user_id='%s';" % uid)[0]
        check(r2['graded'] == 1,
              'la tarjeta repetida cuenta UNA vez (graded=%s, no 2)' % r2['graded'])
        check(r2['correct'] == 0,
              'cuenta su PRIMERA respuesta (fallo) -> correct=0: fallar-y-acertar no paga')
        check(r2['xp_earned'] == 0 and after['gold'] == before['gold'],
              'sin XP ni oro por la relapsada (anti-farmeo)')

        # ── 8. El rating NO puede inflar: escribir mal + pulsar "Facil" ──────
        c = cards[5]
        V.rpc(tok, 'submit_practice', {'p_mode': 'srs', 'p_answers': [
            {'vocab_id': c['vocab_id'], 'rating': 4, 'answer': 'respuesta_basura'}]})
        row = q("select state, last_rating from user_vocab_srs where user_id='%s' and vocab_id='%s';"
                % (uid, c['vocab_id']))[0]
        check(row['last_rating'] == 1 and row['state'] in ('learning', 'relearning'),
              'escribir MAL + pulsar "Facil" -> el servidor fuerza rating=1 (no se puede inflar)')

        # ── 9. Vencidas: una tarjeta con due pasado vuelve a la cola ─────────
        q("update user_vocab_srs set due_at = now() - interval '1 day', state='review' "
          "where user_id='%s' and vocab_id='%s';" % (uid, good_rows and picked[0]['vocab_id']))
        st = V.rpc(tok, 'get_srs_status', {})
        s3 = V.rpc(tok, 'start_practice', {'p_mode': 'srs', 'p_skill': None, 'p_unit': None})
        check(st['due'] >= 1, 'get_srs_status ve la vencida')
        check(any(x['vocab_id'] == picked[0]['vocab_id'] for x in s3['cards']),
              'la vencida vuelve a la cola')

        # ── 9b. RACHA: al cumplir la META DIARIA repasando (regla existente) ──
        # Se fuerzan las tarjetas a vencidas y se repasa hasta superar la meta.
        met = False
        for _ in range(4):
            q("update user_vocab_srs set due_at = now() - interval '1 h', state='review' "
              "where user_id='%s' and last_reviewed_at is not null;" % uid)
            s5 = V.rpc(tok, 'start_practice', {'p_mode': 'srs', 'p_skill': None, 'p_unit': None})
            if not s5['cards']:
                break
            ans = [{'vocab_id': x['vocab_id'], 'rating': 3, 'answer': x['word']} for x in s5['cards']]
            rr = V.rpc(tok, 'submit_practice', {'p_mode': 'srs', 'p_answers': ans})
            if rr['goal_met']:
                met = True
                check(rr['streak'] >= 1,
                      'al CUMPLIR la meta diaria repasando -> la racha avanza (streak=%s)' % rr['streak'])
                break
        check(met, 'el repaso puede cumplir la meta diaria (alimenta racha como una leccion)')

        # ── 10. Aislamiento: el SRS es del curso activo ──────────────────────
        other = 'en' if code != 'en' else 'pt'
        V.rpc(tok, 'set_active_course', {'p_course_id': course_of(other)})
        s4 = V.rpc(tok, 'start_practice', {'p_mode': 'srs', 'p_skill': None, 'p_unit': None})
        check(len(s4['cards']) == 0,
              'cambiar de curso -> cola vacia (aislamiento multicurso del SRS)')
        V.rpc(tok, 'set_active_course', {'p_course_id': course_of(code)})

        print('  --> %s: %s' % (code.upper(), 'VERDE' if ok else 'FALLO'))

    # ── limpieza: SOLO los usuarios de prueba. NUNCA los reales ──────────────
    # (auth.users ya NO está vacío: Gian y sus testers se registraron con Google
    #  tras el reseteo. Borrarlos sería destruir datos de producción.)
    run("delete from auth.users where email like 'srsverify%@test.jezici.dev';")
    left = q("select count(*) n from auth.users where email like 'srsverify%';")[0]['n']
    reales = q("select count(*) n from auth.users where email not like '%@test.jezici.dev';")[0]['n']
    print('\n[limpieza] usuarios de prueba restantes = %d · usuarios REALES intactos = %d'
          % (left, reales))
    ok_all = ok_all and left == 0

    print('\n' + ('TODO VERDE' if ok_all else 'FALLO ALGO'))
    return 0 if ok_all else 1


if __name__ == '__main__':
    raise SystemExit(main())
