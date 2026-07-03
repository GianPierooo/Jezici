# -*- coding: utf-8 -*-
"""Genera la migración de TIPS post-lección para es→fr/it/de/nl A1 (6 tips/curso, uno
por unidad, punto gramatical clave). Aditiva (no toca los tips en de mig 057). Lee
tips_<code>.json (array de 6). content_tips es course-scoped → el get_lesson_tip vivo
(mig 069, matchea por topic O unit_order, WHERE course_id=jz_active_course()) sólo
devuelve el tip del curso activo: cada idioma ve el suyo, sin fuga multicurso. ids uuid5.

Uso: python gen_tips_multi.py   (lee tips_{fr,it,de,nl}.json → mig 20260703120102_seed_tips_a1.sql)
"""
import uuid, json, io, os
from gen_course import COURSES, NS, dollar

CODES = ['fr', 'it', 'de', 'nl']
STAMP = '20260703120102'
HERE = os.path.dirname(__file__)


def _id(code, unit):
    return str(uuid.uuid5(NS, 'tip:%s:u%d' % (code, unit)))


def build():
    L = ['-- %s_seed_tips_a1.sql' % STAMP,
         '-- Tips post-lección A1 es→fr/it/de/nl (6/curso, 1 por unidad). ADITIVA (no toca',
         '-- los tips en de mig 057). content_tips es course-scoped → get_lesson_tip (mig 069,',
         '-- WHERE course_id=jz_active_course()) devuelve sólo el del curso activo. Sin fuga.',
         'begin;']
    rows = []
    counts = {}
    for code in CODES:
        course_id = COURSES[code][0]
        tips = json.load(io.open(os.path.join(HERE, 'tips_%s.json' % code), encoding='utf-8'))
        assert isinstance(tips, list) and len(tips) == 6, '%s: se esperaban 6 tips' % code
        counts[code] = len(tips)
        for t in tips:
            tid = _id(code, int(t['unit']))
            rows.append(
                "('%s'::uuid,'%s'::uuid,%d,'A1',%s,%s,%s,%s,%s,%s)" % (
                    tid, course_id, int(t['unit']),
                    dollar(t['skill']), dollar(t['type']), dollar(t['topic']),
                    dollar(t['title']), dollar(t['body']), dollar(t.get('example') or '')))
    L.append('insert into content_tips (id, course_id, unit_order, cefr_level, skill, type, topic, title, body, example) values')
    L.append(',\n'.join(rows))
    L.append('on conflict (id) do update set skill=excluded.skill, type=excluded.type, '
             'topic=excluded.topic, title=excluded.title, body=excluded.body, example=excluded.example;')
    L.append('commit;')
    out = os.path.join(HERE, '..', '..', 'supabase', 'migrations', '%s_seed_tips_a1.sql' % STAMP)
    io.open(out, 'w', encoding='utf-8').write('\n'.join(L))
    print('escrito', out)
    print('tips por curso:', counts, ' total=', sum(counts.values()))


if __name__ == '__main__':
    build()
