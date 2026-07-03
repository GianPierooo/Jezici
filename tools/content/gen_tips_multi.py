# -*- coding: utf-8 -*-
"""Genera migraciones de TIPS post-lección multi-curso (aditivas; no tocan los tips en
de mig 057). Lee tips_<archivo>.json (array de {unit,topic,skill,type,title,body,example}).
content_tips es course-scoped → el get_lesson_tip vivo (mig 069, matchea por topic O
unit_order, WHERE course_id=jz_active_course()) sólo devuelve el tip del curso activo:
cada idioma ve el suyo, sin fuga multicurso. ids uuid5 keyed por (code, unit) — únicos
entre lotes porque cada unidad de un curso tiene a lo sumo un tip. cefr_level se deriva
del unit_order (1-6=A1, 7-12=A2).

Uso: python gen_tips_multi.py <batch>
  batch a1   → tips_{fr,it,de,nl}.json          → mig 20260703120102_seed_tips_a1.sql
  batch pt_a2→ tips_pt.json + tips_{fr,it}_a2.json → mig 20260703120103_seed_tips_pt_a2.sql
"""
import uuid, json, io, os, sys
from gen_course import COURSES as _FRITDENL, NS, dollar

HERE = os.path.dirname(__file__)

# code -> course_id (todos los cursos, para tips).
COURSE_IDS = {code: cfg[0] for code, cfg in _FRITDENL.items()}
COURSE_IDS['en'] = '20000000-0000-0000-0000-000000000001'
COURSE_IDS['pt'] = '20000000-0000-0000-0000-000000000002'

# batch -> (stamp, sufijo, [(code, archivo_json), ...])
BATCHES = {
    'a1': ('20260703120102', 'seed_tips_a1',
           [('fr', 'tips_fr.json'), ('it', 'tips_it.json'),
            ('de', 'tips_de.json'), ('nl', 'tips_nl.json')]),
    'pt_a2': ('20260703120103', 'seed_tips_pt_a2',
              [('pt', 'tips_pt.json'), ('fr', 'tips_fr_a2.json'), ('it', 'tips_it_a2.json')]),
}


def _id(code, unit):
    return str(uuid.uuid5(NS, 'tip:%s:u%d' % (code, unit)))


def build(batch):
    stamp, suffix, files = BATCHES[batch]
    L = ['-- %s_%s.sql' % (stamp, suffix),
         '-- Tips post-lección multi-curso (lote %s). ADITIVA (no toca los tips en de mig' % batch,
         '-- 057). content_tips es course-scoped → get_lesson_tip (mig 069, WHERE course_id=',
         '-- jz_active_course()) devuelve sólo el del curso activo. Sin fuga multicurso.',
         'begin;']
    rows = []
    counts = {}
    for code, fname in files:
        course_id = COURSE_IDS[code]
        tips = json.load(io.open(os.path.join(HERE, fname), encoding='utf-8'))
        assert isinstance(tips, list) and len(tips) == 6, '%s: se esperaban 6 tips' % fname
        counts['%s(%s)' % (code, fname)] = len(tips)
        for t in tips:
            unit = int(t['unit'])
            cefr = 'A1' if unit <= 6 else 'A2'
            rows.append(
                "('%s'::uuid,'%s'::uuid,%d,'%s',%s,%s,%s,%s,%s,%s)" % (
                    _id(code, unit), course_id, unit, cefr,
                    dollar(t['skill']), dollar(t['type']), dollar(t['topic']),
                    dollar(t['title']), dollar(t['body']), dollar(t.get('example') or '')))
    L.append('insert into content_tips (id, course_id, unit_order, cefr_level, skill, type, topic, title, body, example) values')
    L.append(',\n'.join(rows))
    L.append('on conflict (id) do update set skill=excluded.skill, type=excluded.type, '
             'topic=excluded.topic, title=excluded.title, body=excluded.body, example=excluded.example;')
    L.append('commit;')
    out = os.path.join(HERE, '..', '..', 'supabase', 'migrations', '%s_%s.sql' % (stamp, suffix))
    io.open(out, 'w', encoding='utf-8').write('\n'.join(L))
    print('escrito', out)
    print('tips:', counts, ' total=', sum(counts.values()))


if __name__ == '__main__':
    build(sys.argv[1] if len(sys.argv) > 1 else 'a1')
