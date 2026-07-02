# -*- coding: utf-8 -*-
"""Generador de la migración de un curso A1 NUEVO (es->fr, es->it) desde JSON por
unidad. Espeja el molde es->pt (mig 047+048): registra language+course y siembra
units/lessons(+checkpoint)/exams/content_items/lesson_items/vocabulary scopeados al
course_id (→ aislamiento multicurso por jz_active_course). ids por uuid5 (estables,
idempotentes, sin colisión entre cursos). audio_url apunta a Storage.

Uso: python gen_course_a1.py fr    (lee fr_a1_u1..u6.json → mig 20260703..._seed_fr_a1.sql)
"""
import uuid, json, io, os, sys

STORAGE = "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public"
NS = uuid.UUID('20000000-0000-0000-0000-0000000000fa')

# code -> (course_id, lang_id, lang_code, lang_name, target_es_name, mig_stamp)
COURSES = {
    'fr': ('20000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000004',
           'fr', 'Français', 'francés', '20260703120094'),
    'it': ('20000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000005',
           'it', 'Italiano', 'italiano', '20260703120095'),
}
ES_LANG = '10000000-0000-0000-0000-000000000001'
DIFF = 0.16


def _id(course, kind, *parts):
    return str(uuid.uuid5(NS, course + ':' + kind + ':' + ':'.join(str(p) for p in parts)))


def dollar(s):
    # $p$...$p$ literal (evita escapes); asume que el texto no contiene el token $p$.
    assert '$p$' not in s, s
    return '$p$' + s + '$p$'


def jdollar(obj):
    s = json.dumps(obj, ensure_ascii=False)
    assert '$j$' not in s, s
    return '$j$' + s + '$j$'


def item_sql(course_id, iid, level, skill, it):
    """Mapea un ítem JSON a (payload, correct_answer) según su tipo (molde pt)."""
    typ = it['type']
    if typ == 'match':
        pairs = it['pairs']  # [[fr, es], ...]
        payload = {'pairs': [{'en': a, 'es': b} for a, b in pairs]}
        correct = {'pairs': [[a, b] for a, b in pairs]}
    elif typ in ('multiple_choice',):
        payload = {'options': it['options']}
        correct = {'value': it['value']}
    elif typ == 'cloze':
        payload = {'text': it['text']}
        correct = {'value': it['value']}
        if it.get('accepted'):
            correct['accepted'] = it['accepted']
    elif typ == 'translation':
        payload = {'source': it['source']}
        correct = {'value': it['value']}
        if it.get('accepted'):
            correct['accepted'] = it['accepted']
    elif typ == 'word_bank':
        payload = {'tiles': it['tiles']}
        correct = {'value': ' '.join(it['sequence']), 'sequence': it['sequence']}
    elif typ == 'reorder':
        payload = {'tiles': it['tiles']}
        correct = {'value': ' '.join(it['sequence'])}
    elif typ == 'listening':
        payload = {'options': it['options'], 'say': it['say'],
                   'audio_url': f"{STORAGE}/audio/items/{iid}.mp3"}
        correct = {'value': it['value']}
    elif typ == 'speaking_read_aloud':
        payload = {'text': it['read'], 'audio_url': f"{STORAGE}/audio/items/{iid}.mp3"}
        correct = {'expected': it['read']}
    else:
        raise ValueError('tipo desconocido: ' + typ)
    tags = ['unidad%d' % it['_unit'], it['topic'], skill]
    tags_sql = 'ARRAY[' + ', '.join(dollar(t) for t in tags) + ']'
    return (f"('{iid}'::uuid,'{course_id}'::uuid,'{level}','{skill}','{typ}',"
            f"{dollar(it['prompt'])},{jdollar(payload)}::jsonb,{jdollar(correct)}::jsonb,"
            f"{DIFF},{tags_sql})")


def build(code):
    course_id, lang_id, lcode, lname, es_name, stamp = COURSES[code]
    here = os.path.dirname(__file__)
    units = []
    for n in range(1, 7):
        p = os.path.join(here, f"{code}_a1_u{n}.json")
        if not os.path.exists(p):
            break
        units.append(json.load(io.open(p, encoding='utf-8')))
    assert units, f"no hay JSON {code}_a1_u*.json"

    L = []
    L.append(f"-- {stamp}_seed_{code}_a1.sql")
    L.append(f"-- Alta del curso es→{code} + currículo A1 ({len(units)} unidades). Molde es→pt")
    L.append(f"-- (mig 047+048). Contenido scopeado a course_id={course_id} → aislamiento")
    L.append(f"-- multicurso por jz_active_course (RPCs ya course-aware). ids uuid5 idempotentes.")
    L.append("begin;")
    L.append("insert into languages (id, code, name) values")
    L.append(f"  ('{lang_id}','{lcode}',{dollar(lname)}) on conflict (id) do nothing;")
    L.append("insert into courses (id, source_language_id, target_language_id, is_active) values")
    L.append(f"  ('{course_id}','{ES_LANG}','{lang_id}',true) on conflict (id) do nothing;")
    L.append("")

    counts = {'reading': 0, 'writing': 0, 'listening': 0, 'speaking': 0}
    audio_ids = []
    for u in units:
        uo = u['unit']['order']
        uid = _id(code, 'unit', uo)
        L.append(f"-- ── Unidad {uo} (A1·{code}): {u['unit']['title_es']} ──")
        L.append("insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values")
        L.append(f" ('{uid}','{course_id}','A1',{uo},{dollar(u['unit']['title_es'])},"
                 f"'{u['unit']['color']}','{u['unit']['icon']}')")
        L.append("on conflict (course_id, order_index) do update set title=excluded.title, theme_color=excluded.theme_color, icon=excluded.icon;")

        # Lecciones (4 de tipo lesson) + 1 checkpoint.
        lids = {}
        rows = []
        for les in u['lessons']:
            lo = les['order']
            lid = _id(code, 'lesson', uo, lo)
            lids[lo] = lid
            rows.append(f" ('{lid}','{uid}',{lo},{dollar(les['title_es'])},{dollar(les['title_es'])},'lesson',15)")
        cpid = _id(code, 'lesson', uo, 99)
        lids['cp'] = cpid
        cp_desc = u.get('checkpoint_desc', f"Checkpoint de la Unidad {uo}: repasa lo aprendido en las 4 habilidades.")
        rows.append(f" ('{cpid}','{uid}',5,{dollar('🏁 Checkpoint Unité %d' % uo)},{dollar(cp_desc)},'checkpoint',40)")
        L.append("insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values")
        L.append(",\n".join(rows))
        L.append("on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;")

        exid = _id(code, 'exam', uo)
        L.append("insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values")
        L.append(f" ('{exid}','{course_id}','checkpoint','A1','{uid}',300,0.80,"
                 + jdollar({"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": True})
                 + "::jsonb) on conflict (id) do nothing;")

        # content_items
        item_rows = []
        item_ids = []
        for idx, it in enumerate(u['items'], 1):
            it['_unit'] = uo
            iid = _id(code, 'item', uo, idx)
            item_ids.append((iid, it))
            counts[it['skill']] += 1
            if it['type'] in ('listening', 'speaking_read_aloud'):
                audio_ids.append(iid)
            item_rows.append(item_sql(course_id, iid, 'A1', it['skill'], it))
        L.append("insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values")
        L.append(",\n".join(item_rows))
        L.append("on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();")

        # lesson_items: cada ítem a su lección (por 'lesson'), en orden de aparición.
        li_rows = []
        per_lesson = {}
        for iid, it in item_ids:
            lo = it['lesson']
            per_lesson.setdefault(lo, []).append(iid)
        for lo, ids in sorted(per_lesson.items()):
            for k, iid in enumerate(ids, 1):
                li_rows.append(f" ('{lids[lo]}','{iid}',{k})")
        # checkpoint: subconjunto curado ~10 ítems cubriendo 4 skills.
        cp_pick = []
        by_skill = {'reading': [], 'writing': [], 'listening': [], 'speaking': []}
        for iid, it in item_ids:
            by_skill[it['skill']].append(iid)
        for sk, want in [('reading', 3), ('writing', 3), ('listening', 2), ('speaking', 2)]:
            cp_pick += by_skill[sk][:want]
        for k, iid in enumerate(cp_pick, 1):
            li_rows.append(f" ('{cpid}','{iid}',{k})")
        L.append("insert into lesson_items (lesson_id, item_id, order_index) values")
        L.append(",\n".join(li_rows))
        L.append("on conflict (lesson_id, item_id) do nothing;")

        # vocabulary
        vocab = u.get('vocab', [])
        if vocab:
            vrows = []
            for k, entry in enumerate(vocab, 1):
                w, tr, pos = entry
                vid = _id(code, 'vocab', uo, k)
                rank = 100 + uo * 20 + k
                vrows.append(f" ('{vid}','{course_id}',{dollar(w)},{dollar(tr)},{rank},'{pos}')")
            L.append("insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values")
            L.append(",\n".join(vrows))
            L.append("on conflict (id) do nothing;")
        L.append("")

    L.append("commit;")
    out = os.path.join(here, '..', '..', 'supabase', 'migrations', f"{stamp}_seed_{code}_a1.sql")
    io.open(out, 'w', encoding='utf-8').write("\n".join(L))
    print(f"escrito {out}")
    print(f"unidades={len(units)}  items por skill={counts}  total={sum(counts.values())}  audios={len(audio_ids)}")
    rw = (counts['reading'] + counts['writing']) / 2 or 1
    print(f"balance: L/(R+W)/2={counts['listening']/rw:.0%}  S/(R+W)/2={counts['speaking']/rw:.0%}")


if __name__ == '__main__':
    build(sys.argv[1] if len(sys.argv) > 1 else 'fr')
