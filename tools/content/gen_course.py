# -*- coding: utf-8 -*-
"""Generador PARAMETRIZADO POR NIVEL de la migración de un curso (es->fr, es->it)
desde JSON por unidad. Generaliza gen_course_a1.py a cualquier nivel CEFR (A1, A2, …):
lee `<code>_<level>_u1..u6.json` y espeja el molde es->pt (units/lessons(+checkpoint)/
exams/content_items/lesson_items/vocabulary) scopeado al course_id → aislamiento
multicurso por jz_active_course. ids uuid5 estables (keyed en unit order → A2 usa
order 7-12, sin colisión con A1 1-6). El order_index de las unidades (7-12 para A2)
ENCADENA con A1 (submit_checkpoint desbloquea la unidad con order_index mayor del MISMO
curso → gating A1→A2 automático y course-scoped).

Uso: python gen_course.py it a2   (lee it_a2_u1..u6.json → mig 20260703..._seed_it_a2.sql)
"""
import uuid, json, io, os, sys, glob

STORAGE = "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public"
NS = uuid.UUID('20000000-0000-0000-0000-0000000000fa')

# code -> (course_id, lang_id, lang_code, lang_name, target_es_name)
COURSES = {
    'pt': ('20000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000003',
           'pt', 'Português', 'portugués'),
    'fr': ('20000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000004',
           'fr', 'Français', 'francés'),
    'it': ('20000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000005',
           'it', 'Italiano', 'italiano'),
    'de': ('20000000-0000-0000-0000-000000000005', '10000000-0000-0000-0000-000000000006',
           'de', 'Deutsch', 'alemán'),
    'nl': ('20000000-0000-0000-0000-000000000006', '10000000-0000-0000-0000-000000000007',
           'nl', 'Nederlands', 'neerlandés'),
}
# (code, level) -> stamp de la migración
STAMPS = {
    ('fr', 'a1'): '20260703120094', ('it', 'a1'): '20260703120095',
    ('fr', 'a2'): '20260703120097', ('it', 'a2'): '20260703120098',
    ('de', 'a1'): '20260703120100', ('nl', 'a1'): '20260703120101',
    ('de', 'a2'): '20260703120104', ('nl', 'a2'): '20260703120105',
    ('de', 'b1'): '20260703120111', ('nl', 'b1'): '20260703120112',
    ('fr', 'b1'): '20260703120113', ('it', 'b1'): '20260703120114',
    ('de', 'b2'): '20260703120115', ('nl', 'b2'): '20260703120116',
    ('fr', 'b2'): '20260705120119', ('it', 'b2'): '20260705120120',
    ('pt', 'b2'): '20260705120121',
    ('fr', 'c1'): '20260705120126', ('it', 'c1'): '20260705120127',
    ('de', 'c1'): '20260705120128', ('nl', 'c1'): '20260705120129',
    ('pt', 'c1'): '20260705120130',
}
# palabra "Unidad" en el idioma meta (para el título del checkpoint)
UNIT_WORD = {'fr': 'Unité', 'it': 'Unità', 'de': 'Einheit', 'nl': 'Eenheid', 'pt': 'Unidade'}
DIFF = {'a1': 0.16, 'a2': 0.34, 'b1': 0.52, 'b2': 0.68, 'c1': 0.84}
ES_LANG = '10000000-0000-0000-0000-000000000001'


def _id(course, kind, *parts):
    return str(uuid.uuid5(NS, course + ':' + kind + ':' + ':'.join(str(p) for p in parts)))


def dollar(s):
    assert '$p$' not in s, s
    return '$p$' + s + '$p$'


def jdollar(obj):
    s = json.dumps(obj, ensure_ascii=False)
    assert '$j$' not in s, s
    return '$j$' + s + '$j$'


def item_sql(course_id, iid, level_cefr, diff, skill, it):
    """Mapea un ítem JSON a (payload, correct_answer) según su tipo (molde pt)."""
    typ = it['type']
    if typ == 'match':
        pairs = it['pairs']  # [[it, es], ...]
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
    topic = it.get('topic') or ('unidad%d_l%s' % (it['_unit'], it.get('lesson', 'x')))
    tags = ['unidad%d' % it['_unit'], topic, skill]
    _PROMPT_DEF = {'match': 'Une cada elemento con su significado.',
                   'speaking_read_aloud': 'Lee en voz alta:',
                   'listening': 'Escucha y elige la frase que oíste.',
                   'multiple_choice': 'Elige la opción correcta.', 'cloze': 'Completa la frase.',
                   'translation': 'Traduce la frase.', 'word_bank': 'Construye la frase.',
                   'reorder': 'Ordena las palabras.'}
    it['prompt'] = it.get('prompt') or _PROMPT_DEF.get(typ, 'Completa la actividad.')
    tags_sql = 'ARRAY[' + ', '.join(dollar(t) for t in tags) + ']'
    return (f"('{iid}'::uuid,'{course_id}'::uuid,'{level_cefr}','{skill}','{typ}',"
            f"{dollar(it['prompt'])},{jdollar(payload)}::jsonb,{jdollar(correct)}::jsonb,"
            f"{diff},{tags_sql})")


def build(code, level):
    level = level.lower()
    cefr = level.upper()
    course_id, lang_id, lcode, lname, es_name = COURSES[code]
    stamp = STAMPS[(code, level)]
    diff = DIFF[level]
    uword = UNIT_WORD[code]
    here = os.path.dirname(__file__)
    # Lee TODOS los JSON del nivel (A1=u1..u6/order 1-6; A2=u7..u12/order 7-12) y
    # ordena por el campo unit.order de dentro (el nombre del archivo es indistinto).
    paths = glob.glob(os.path.join(here, f"{code}_{level}_u*.json"))
    units = [json.load(io.open(p, encoding='utf-8')) for p in paths]
    units.sort(key=lambda u: u['unit']['order'])
    assert units, f"no hay JSON {code}_{level}_u*.json"
    orders = [u['unit']['order'] for u in units]
    assert len(set(orders)) == len(orders), f"order_index duplicados: {orders}"

    L = []
    L.append(f"-- {stamp}_seed_{code}_{level}.sql")
    L.append(f"-- Currículo {cefr} del curso es→{code} ({len(units)} unidades). Molde es→pt.")
    L.append(f"-- Contenido scopeado a course_id={course_id} → aislamiento multicurso por")
    L.append(f"-- jz_active_course. Unidades order_index continúan la cadena → gating al nivel previo.")
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
        L.append(f"-- ── Unidad {uo} ({cefr}·{code}): {u['unit']['title_es']} ──")
        L.append("insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values")
        L.append(f" ('{uid}','{course_id}','{cefr}',{uo},{dollar(u['unit']['title_es'])},"
                 f"'{u['unit']['color']}','{u['unit']['icon']}')")
        L.append("on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;")

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
        rows.append(f" ('{cpid}','{uid}',5,{dollar('🏁 Checkpoint %s %d' % (uword, uo))},{dollar(cp_desc)},'checkpoint',40)")
        L.append("insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values")
        L.append(",\n".join(rows))
        L.append("on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;")

        exid = _id(code, 'exam', uo)
        L.append("insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values")
        L.append(f" ('{exid}','{course_id}','checkpoint','{cefr}','{uid}',300,0.80,"
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
            item_rows.append(item_sql(course_id, iid, cefr, diff, it['skill'], it))
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
    out = os.path.join(here, '..', '..', 'supabase', 'migrations', f"{stamp}_seed_{code}_{level}.sql")
    io.open(out, 'w', encoding='utf-8').write("\n".join(L))
    print(f"escrito {out}")
    print(f"nivel={cefr}  unidades={len(units)}  items por skill={counts}  total={sum(counts.values())}  audios={len(audio_ids)}")
    rw = (counts['reading'] + counts['writing']) / 2 or 1
    print(f"balance: L/(R+W)/2={counts['listening']/rw:.0%}  S/(R+W)/2={counts['speaking']/rw:.0%}")


if __name__ == '__main__':
    build(sys.argv[1] if len(sys.argv) > 1 else 'fr', sys.argv[2] if len(sys.argv) > 2 else 'a2')
