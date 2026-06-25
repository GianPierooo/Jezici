"""Genera las migraciones 078 (A1) y 079 (A2) de ítems NUEVOS de listening/speaking
(rebalanceo L/S) desde el JSON validado del workflow (_ls_raw.json → result.units).

- content_items: listening (payload.say + options + audio_url determinista; correct
  _answer.value) y speaking_read_aloud (payload.text + audio_url; correct_answer.
  expected). correct_answer queda OCULTO (42501). UUID5 deterministas. tag 'lsbal'
  + 'unidadN' (entra al pool del examen) + topic + skill.
- lesson_items: cablea cada ítem a una lección (order 1-4) de su unidad por subquery
  (sin UUIDs de lección hardcodeados). order_index alto (100+) → al final de la lección.
ADITIVO: on conflict do nothing/update. Audio se genera aparte (gen_audio_ls.py).
"""
import json, re, uuid

EN = '20000000-0000-0000-0000-000000000001'
PUB = 'https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/'
NS = uuid.UUID('15ba1a4c-0000-4000-8000-000000000000')  # namespace estable L/S balance
DIFF = {'A1': 0.2, 'A2': 0.4}
# distribución a lecciones (order_index de lección dentro de la unidad)
L_LESSON = [1, 2, 3, 4, 4]   # 5 listening
S_LESSON = [1, 2, 3]         # 3 speaking

def sq(s):
    return s.replace("'", "''")

def slug(s):
    return re.sub(r'[^a-z0-9]+', '_', (s or '').lower()).strip('_')[:24] or 'tema'

def main():
    d = json.loads(open('_ls_raw.json', encoding='utf-8').read())
    units = d['result']['units']
    files = {'A1': [], 'A2': []}
    counts = {'A1': {'l': 0, 's': 0}, 'A2': {'l': 0, 's': 0}}
    # contador de order_index por (unidad, lección)
    oi = {}

    def next_oi(unit, lesson):
        k = (unit, lesson)
        oi[k] = oi.get(k, 100) + 1
        return oi[k]

    for ud in units:
        unit, lvl = ud['unit'], ud['lvl']
        utag = f'unidad{unit}'
        rows_ci, rows_li = [], []
        # listening
        for i, it in enumerate(ud['listening']):
            iid = uuid.uuid5(NS, f'lsbal-{unit}-listening-{i}')
            audio = PUB + str(iid) + '.mp3'
            payload = {'options': it['options'], 'say': it['say'], 'audio_url': audio}
            ca = {'value': it['answer']}
            tags = [utag, slug(it.get('topic')), 'listening', 'lsbal']
            rows_ci.append(_ci(iid, lvl, 'listening', 'listening', it['prompt'], payload, ca, DIFF[lvl], tags))
            lesson = L_LESSON[i] if i < len(L_LESSON) else 4
            rows_li.append(_li(iid, unit, lesson, next_oi(unit, lesson)))
            counts[lvl]['l'] += 1
        # speaking
        for i, it in enumerate(ud['speaking']):
            iid = uuid.uuid5(NS, f'lsbal-{unit}-speaking-{i}')
            audio = PUB + str(iid) + '.mp3'
            payload = {'text': it['text'], 'audio_url': audio}
            ca = {'expected': it['text']}
            tags = [utag, slug(it.get('topic')), 'speaking', 'lsbal']
            rows_ci.append(_ci(iid, lvl, 'speaking', 'speaking_read_aloud', 'Lee en voz alta:', payload, ca, DIFF[lvl], tags))
            lesson = S_LESSON[i] if i < len(S_LESSON) else 3
            rows_li.append(_li(iid, unit, lesson, next_oi(unit, lesson)))
            counts[lvl]['s'] += 1
        files[lvl].append((unit, rows_ci, rows_li))

    _write('A1', '078', files['A1'], counts['A1'])
    _write('A2', '079', files['A2'], counts['A2'])
    print('listo:', counts)

def _ci(iid, lvl, skill, typ, prompt, payload, ca, diff, tags):
    return ("  ('{id}'::uuid, '{c}'::uuid, '{lvl}'::cefr_level, '{skill}'::skill, '{typ}'::content_item_type, "
            "'{p}', '{pl}'::jsonb, '{ca}'::jsonb, {d}, ARRAY[{tags}])").format(
        id=iid, c=EN, lvl=lvl, skill=skill, typ=typ, p=sq(prompt),
        pl=sq(json.dumps(payload, ensure_ascii=False)), ca=sq(json.dumps(ca, ensure_ascii=False)),
        d=diff, tags=', '.join("'%s'" % t for t in tags))

def _li(iid, unit, lesson, order):
    # cablea por subquery (unidad order_index, lección order_index) — sin UUID hardcodeado
    return ("insert into lesson_items (lesson_id, item_id, order_index) "
            "select le.id, '{id}'::uuid, {o} from lessons le join units u on u.id=le.unit_id "
            "where u.course_id='{c}' and u.order_index={unit} and le.order_index={lesson} "
            "on conflict (lesson_id, item_id) do nothing;").format(id=iid, o=order, c=EN, unit=unit, lesson=lesson)

def _write(lvl, mig, unit_rows, cnt):
    all_ci = [r for (_, ci, _) in unit_rows for r in ci]
    all_li = [r for (_, _, li) in unit_rows for r in li]
    sql = """-- ============================================================================
-- Jezici . Migracion {mig} . Rebalanceo L/S es->en {lvl}: +listening +speaking
-- ----------------------------------------------------------------------------
-- Sube comprension auditiva (+5/unidad) y lectura en voz alta (+3/unidad) para que
-- las 4 habilidades nivelen proporcionalmente (audit EFICACIA: sesgo ~3:1 R/W vs L/S).
-- listening = gradable (jz_grade como MC; mueve dominio listening por precision).
-- speaking_read_aloud = stub/participacion (mueve dominio speaking por cobertura).
-- payload.say/text guardado => audio REGENERABLE y text-matched (gen_audio_ls.py).
-- correct_answer OCULTO (42501). Cableado a lecciones 1-4 + tag unidadN (pool examen).
-- {nl} listening + {ns} speaking ({lvl}). Audio: gen_audio_ls.py {lvl}.
-- ============================================================================
begin;

insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
{ci}
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload,
  correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();

{li}

commit;
""".format(mig=mig, lvl=lvl, nl=cnt['l'], ns=cnt['s'],
           ci=',\n'.join(all_ci), li='\n'.join(all_li))
    out = '../../supabase/migrations/20260625120{mig}_ls_balance_{lvl}.sql'.format(mig=mig, lvl=lvl.lower())
    open(out, 'w', encoding='utf-8').write(sql)
    print('escrito', out, '·', cnt)

if __name__ == '__main__':
    main()
