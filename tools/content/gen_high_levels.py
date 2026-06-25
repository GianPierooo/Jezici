"""Genera la migracion de un nivel desde el JSON validado del workflow (_lvl_raw.json
-> result.units + result.verdict): items L/S de rebalanceo + items de relleno de huecos.
Soporta ambos cursos (en/pt). correct_answer OCULTO (42501). UUID5 deterministas.
Cableado a lecciones 1-4 + tag unidadN (pool del examen, scope por course_id). ADITIVO.

Uso: python gen_high_levels.py <en|pt> <A1|A2|B1|B2|C1> <mig>
  ej: python gen_high_levels.py pt A1 083
"""
import json, re, sys, uuid

COURSES = {'en': '20000000-0000-0000-0000-000000000001', 'pt': '20000000-0000-0000-0000-000000000002'}
PUB = 'https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/'
NS = uuid.UUID('15ba1a4c-0000-4000-8000-000000000000')
DIFF = {'A1': 0.2, 'A2': 0.4, 'B1': 0.55, 'B2': 0.72, 'C1': 0.88}
L_LESSON = [1, 2, 3, 4]
S_LESSON = [1, 3]

def sq(s): return (s or '').replace("'", "''")
def slug(s): return re.sub(r'[^a-z0-9]+', '_', (s or '').lower()).strip('_')[:24] or 'tema'

def main():
    course, lvl, mig = sys.argv[1], sys.argv[2], sys.argv[3]
    cid = COURSES[course]
    tag_l = 'lsbal' if course == 'en' else 'lsbalpt'
    tag_g = 'eficgap' if course == 'en' else 'eficgappt'
    nspref = 'lsbal' if course == 'en' else 'lsbalpt'   # namespace por curso (uuids distintos)
    d = json.loads(open('_lvl_raw.json', encoding='utf-8').read())
    units = d['result']['units']
    cnt = {'l': 0, 's': 0, 'g': 0}
    oi = {}
    def next_oi(u, le):
        k = (u, le); oi[k] = oi.get(k, 100) + 1; return oi[k]

    rows_ci, rows_li = [], []
    for ud in units:
        unit = ud['unit']; utag = 'unidad%d' % unit
        for i, it in enumerate(ud.get('listening', [])):
            iid = uuid.uuid5(NS, '%s-%d-listening-%d' % (nspref, unit, i))
            pl = {'options': it['options'], 'say': it['say'], 'audio_url': PUB + str(iid) + '.mp3'}
            rows_ci.append(_ci(iid, cid, lvl, 'listening', 'listening', it['prompt'], pl, {'value': it['answer']},
                              DIFF[lvl], [utag, slug(it.get('topic')), 'listening', tag_l]))
            le = L_LESSON[i % len(L_LESSON)]
            rows_li.append(_li(iid, cid, unit, le, next_oi(unit, le))); cnt['l'] += 1
        for i, it in enumerate(ud.get('speaking', [])):
            iid = uuid.uuid5(NS, '%s-%d-speaking-%d' % (nspref, unit, i))
            pl = {'text': it['text'], 'audio_url': PUB + str(iid) + '.mp3'}
            rows_ci.append(_ci(iid, cid, lvl, 'speaking', 'speaking_read_aloud', 'Lee en voz alta:', pl,
                              {'expected': it['text']}, DIFF[lvl], [utag, slug(it.get('topic')), 'speaking', tag_l]))
            le = S_LESSON[i % len(S_LESSON)]
            rows_li.append(_li(iid, cid, unit, le, next_oi(unit, le))); cnt['s'] += 1
        for i, it in enumerate(ud.get('gaps', [])):
            typ = it['type']; skill = it.get('skill', 'reading')
            iid = uuid.uuid5(NS, '%s-gap-%d-%d' % (nspref, unit, i))
            pl = {'options': it['options']} if typ == 'multiple_choice' else {'text': it['prompt'], 'options': it['options']}
            rows_ci.append(_ci(iid, cid, lvl, skill, typ, it['prompt'], pl, {'value': it['answer']},
                              DIFF[lvl], [utag, slug(it.get('topic')), skill, tag_g]))
            le = (i % 4) + 1
            rows_li.append(_li(iid, cid, unit, le, next_oi(unit, le))); cnt['g'] += 1

    sql = """-- ============================================================================
-- Jezici . Migracion {mig} . Eficacia + balance L/S es->{course} {lvl}
-- ----------------------------------------------------------------------------
-- Rebalanceo L/S (listening +4/unidad gradable con audio tl={course}; speaking +2/unidad
-- stub) + relleno de huecos CEFR-{lvl} de alto impacto (mc/cloze, tag '{tg}'). Cableado a
-- lecciones 1-4 + tag unidadN (pool examen, scope por course_id). correct_answer 42501.
-- Audio L/S: gen_audio_ls.py {course} {lvl}. {l} listening + {s} speaking + {g} huecos.
-- ============================================================================
begin;

insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
{ci}
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload,
  correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();

{li}

commit;
""".format(mig=mig, course=course, lvl=lvl, tg=tag_g, l=cnt['l'], s=cnt['s'], g=cnt['g'],
           ci=',\n'.join(rows_ci), li='\n'.join(rows_li))
    out = '../../supabase/migrations/20260625120{mig}_efic_ls_{course}{lvl}.sql'.format(mig=mig, course=course, lvl=lvl.lower())
    open(out, 'w', encoding='utf-8').write(sql)
    print('escrito', out, '·', cnt)
    print('VEREDICTO:', json.dumps(d['result'].get('verdict', {}), ensure_ascii=False)[:500])

def _ci(iid, cid, lvl, skill, typ, prompt, payload, ca, diff, tags):
    return ("  ('{id}'::uuid, '{c}'::uuid, '{lvl}'::cefr_level, '{skill}'::skill, '{typ}'::content_item_type, "
            "'{p}', '{pl}'::jsonb, '{ca}'::jsonb, {d}, ARRAY[{tags}])").format(
        id=iid, c=cid, lvl=lvl, skill=skill, typ=typ, p=sq(prompt),
        pl=sq(json.dumps(payload, ensure_ascii=False)), ca=sq(json.dumps(ca, ensure_ascii=False)),
        d=diff, tags=', '.join("'%s'" % t for t in tags))

def _li(iid, cid, unit, lesson, order):
    return ("insert into lesson_items (lesson_id, item_id, order_index) "
            "select le.id, '{id}'::uuid, {o} from lessons le join units u on u.id=le.unit_id "
            "where u.course_id='{c}' and u.order_index={unit} and le.order_index={lesson} "
            "on conflict (lesson_id, item_id) do nothing;").format(id=iid, o=order, c=cid, unit=unit, lesson=lesson)

if __name__ == '__main__':
    main()
