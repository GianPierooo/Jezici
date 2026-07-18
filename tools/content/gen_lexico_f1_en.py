# -*- coding: utf-8 -*-
"""LÉXICO Fase 1 · INGLÉS — autoría de vocabulario NUEVO (LEXICO_PLAN §3/§4).
232 palabras de alta frecuencia (10 temas) autoradas por agentes nativos + doble
revisión adversarial + guardas deterministas. Cada palabra: traducción revisada +
oración-ejemplo → ítem CLOZE en contexto (con audio TTS, paga F3) + ítem MATCH de
reconocimiento. Lecciones "Vocabulario: <tema>" ancladas ANTES del checkpoint de
una unidad de nivel coherente (A2/B1), tag `vocab_f1` (NO unidadN → checkpoints/
exámenes/placement intactos). lesson_vocab (F2) las vincula → entran al SRS.

uso: python gen_lexico_f1_en.py  → escribe la migración + _lex1/audio_targets.json
"""
import json, re, uuid, unicodedata, os

NS = uuid.uuid5(uuid.NAMESPACE_URL, 'jezici/lexico_f1/en')
CID = '20000000-0000-0000-0000-000000000001'
AUDIO_BASE = 'https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/'
MAX_PAIRS = 5
WORDS_PER_LESSON = 12
# tema → unidad de anclaje (A2=7-12, B1=13-16). Nivel coherente con vocab A2–B2.
THEME_UNIT = {'city': 7, 'home': 8, 'food': 9, 'travel': 10, 'shopping': 11,
              'time': 12, 'health': 13, 'work': 14, 'nature': 15, 'emotions': 16}
CEFR_OF_UNIT = lambda u: 'A2' if u <= 12 else 'B1'


def norm(t):
    t = (t or '').lower()
    t = unicodedata.normalize('NFD', t)
    t = ''.join(c for c in t if unicodedata.category(c) != 'Mn')
    t = re.sub(r"[.!?¿¡,;:'\"’‘´`“”()]", '', t)
    return re.sub(r'\s+', ' ', t).strip()


def has_exact(word, sent):
    return re.search(r'(?<![A-Za-z])' + re.escape(word) + r'(?![A-Za-z])', sent, re.I) is not None


def sq(s):
    return "'" + s.replace("'", "''") + "'"


def main():
    taught = set(json.load(open('_lex1/taught_en.json', encoding='utf-8')))
    words = json.load(open('_lex1/final.json', encoding='utf-8'))

    # normaliza forma verbal para que el cloze pueda borrar la palabra en la oración
    for w in words:
        wd = w['word'].strip()
        w['cloze'] = None
        if has_exact(wd, w['sentence']):
            w['cloze'] = wd
        elif wd.lower().startswith('to '):
            bare = wd[3:].strip()
            if has_exact(bare, w['sentence']) and norm(bare) not in taught:
                w['word'] = bare  # "to cross" -> "cross" (natural en la oración)
                w['cloze'] = bare
        w['nw'] = norm(w['word'])

    items_sql, audio_targets = [], []
    lessons_meta = {}   # unit -> [(lesson_id, title, [item_ids], [vocab_ids])]

    # agrupar por tema; cada tema en su unidad; 2 lecciones de <=12
    bytheme = {}
    for w in words:
        bytheme.setdefault(w['theme'], []).append(w)

    vocab_sql = []
    for theme, unit in THEME_UNIT.items():
        tw = bytheme.get(theme, [])
        cefr = CEFR_OF_UNIT(unit)
        nles = max(1, -(-len(tw) // WORDS_PER_LESSON))
        size = -(-len(tw) // nles)
        chunks = [tw[i:i + size] for i in range(0, len(tw), size)]
        lst = []
        for li, chunk in enumerate(chunks):
            lesson_id = str(uuid.uuid5(NS, f'les:{theme}:{li}'))
            item_ids, vocab_ids = [], []
            # vocab rows + cloze items (con audio) por palabra
            for wi, w in enumerate(chunk):
                vid = str(uuid.uuid5(NS, 'vocab:' + w['nw']))
                vocab_ids.append(vid)
                fr = unit * 30 + wi
                vocab_sql.append(
                    f"insert into vocabulary(id,course_id,word,translation,frequency_rank,part_of_speech) "
                    f"values ({sq(vid)}, {sq(CID)}, {sq(w['word'])}, {sq(w['es'])}, {fr}, {sq(w['pos'])}) "
                    f"on conflict (id) do nothing;")
                if w['cloze']:
                    iid = str(uuid.uuid5(NS, 'cloze:' + w['nw']))
                    au = AUDIO_BASE + iid + '.mp3'
                    payload = json.dumps({'text': w['sentence'], 'audio_url': au}, ensure_ascii=False)
                    correct = json.dumps({'value': w['cloze'], 'accepted': [w['cloze']]}, ensure_ascii=False)
                    items_sql.append(
                        f"insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) "
                        f"values ({sq(iid)}, {sq(CID)}, {sq(cefr)}, 'writing', 'cloze', "
                        f"'Completa la frase con la palabra que falta.', {sq(payload)}::jsonb, {sq(correct)}::jsonb, 0.35, "
                        f"array['vocab_f1','writing']) on conflict (id) do nothing;")
                    item_ids.append(iid)
                    audio_targets.append({'id': iid, 'text': w['sentence']})
            # match items de reconocimiento (guarda de colisión de `es`)
            mi = 0
            cur = []
            def flush(cur, mi):
                if len(cur) < 2:
                    return mi
                iid = str(uuid.uuid5(NS, f'match:{theme}:{li}:{mi}'))
                pj = [{'en': w['word'], 'es': w['es']} for w in cur]
                cj = [[w['word'], w['es']] for w in cur]
                items_sql.append(
                    f"insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) "
                    f"values ({sq(iid)}, {sq(CID)}, {sq(cefr)}, 'reading', 'match', "
                    f"'Empareja cada palabra con su traducción.', {sq(json.dumps({'pairs': pj}, ensure_ascii=False))}::jsonb, "
                    f"{sq(json.dumps({'pairs': cj}, ensure_ascii=False))}::jsonb, 0.15, array['vocab_f1','reading']) "
                    f"on conflict (id) do nothing;")
                item_ids.insert(0, iid)  # el match va primero (reconocer antes de producir)
                return mi + 1
            cur_es = []
            for w in chunk:
                ne = norm(w['es'])
                if len(cur) >= MAX_PAIRS or ne in cur_es:
                    mi = flush(cur, mi); cur, cur_es = [], []
                cur.append(w); cur_es.append(ne)
            mi = flush(cur, mi)
            title = 'Vocabulario: ' + {
                'city': 'la ciudad', 'home': 'el hogar', 'food': 'la comida', 'travel': 'viajar',
                'shopping': 'las compras', 'time': 'el tiempo', 'health': 'la salud',
                'work': 'el trabajo', 'nature': 'la naturaleza', 'emotions': 'las emociones'}[theme] + \
                (f' {li + 1}' if len(chunks) > 1 else '')
            lst.append((lesson_id, title, item_ids, vocab_ids))
        lessons_meta[unit] = lst

    # ── migración ──
    out = ["-- LÉXICO Fase 1 · INGLÉS — vocabulario NUEVO (LEXICO_PLAN §3/§4).",
           "-- 232 palabras de alta frecuencia (10 temas) autoradas por agentes nativos +",
           "-- doble revisión adversarial + guardas deterministas. Cada palabra: traducción",
           "-- revisada + oración-ejemplo → CLOZE en contexto (con audio TTS, paga F3) +",
           "-- MATCH de reconocimiento. Tag 'vocab_f1' (NO unidadN → checkpoints/exámenes/",
           "-- placement intactos). Lecciones ancladas ANTES del checkpoint (DO-block). Idempotente.",
           "", "-- 1) vocabulary (palabras nuevas)"]
    out += vocab_sql
    out.append("")
    out.append("-- 2) content_items (cloze con audio + match)")
    out += items_sql
    out.append("")
    out.append("-- 3) lecciones de vocabulario + lesson_items (antes del checkpoint)")
    for unit, lst in sorted(lessons_meta.items()):
        k = len(lst)
        first_lid = lst[0][0]
        blk = ["do $$", "declare v_unit uuid; v_c int;", "begin",
               f"  if exists (select 1 from lessons where id={sq(first_lid)}) then return; end if;",
               f"  select id into v_unit from units where course_id={sq(CID)} and order_index={unit};",
               "  if v_unit is null then return; end if;",
               "  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';",
               "  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;",
               "  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;"]
        for j, (lid, title, item_ids, _) in enumerate(lst):
            blk.append(
                f"  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) "
                f"values ({sq(lid)}, v_unit, v_c+{j}, {sq(title)}, "
                f"'Aprende palabras nuevas de alta frecuencia con ejemplos y audio.', 'lesson', 15) "
                f"on conflict (id) do nothing;")
            for oi, iid in enumerate(item_ids):
                blk.append(
                    f"  insert into lesson_items(lesson_id,item_id,order_index) "
                    f"values ({sq(lid)}, {sq(iid)}, {oi}) on conflict do nothing;")
        blk.append(f"  update lessons set order_index=order_index-1000+{k} where unit_id=v_unit and order_index>=1000;")
        blk.append("end $$;")
        out += blk + [""]

    out.append("-- 4) re-derivar lesson_vocab (idempotente, lógica mig 165/166) → vincula las nuevas")
    out.append(open('_lex0/derive_lesson_vocab.sql', encoding='utf-8').read())

    mig = '../../supabase/migrations/20260718120169_lexico_f1_en.sql'
    open(mig, 'w', encoding='utf-8').write('\n'.join(out))
    json.dump(audio_targets, open('_lex1/audio_targets.json', 'w', encoding='utf-8'), ensure_ascii=False)

    n_cloze = sum(1 for w in words if w['cloze'])
    print('MIGRACIÓN:', mig)
    print(f'palabras: {len(words)} · cloze+audio: {n_cloze} · solo match+word: {len(words)-n_cloze}')
    print(f'content_items: {len(items_sql)} · lecciones: {sum(len(v) for v in lessons_meta.values())} · audio targets: {len(audio_targets)}')


if __name__ == '__main__':
    main()
