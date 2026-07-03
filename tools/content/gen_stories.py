# -*- coding: utf-8 -*-
"""Genera la migración de HISTORIAS (inmersión) multi-idioma desde story_<code>_<n>.json.
Aditiva (no toca las historias en). Cada historia: stories(course_id, cefr_level,
order_index, title, subtitle, emoji, intro, est_seconds, segments, glossary, questions).
segments[i].audio_url apunta a audio/stories/<story_id>_<i>.mp3 (lo genera gen_story_audio).
get_stories/get_story/submit_story ya son course-scoped (jz_active_course) → cada curso ve
las suyas, sin fuga. questions se califican server-side (submit_story→jz_grade, correct_answer
oculto, 42501). ids uuid5 idempotentes.

Uso: python gen_stories.py <stamp> story_fr_1.json story_it_1.json ...
"""
import uuid, json, io, os, sys
from gen_course import NS, jdollar, dollar

STORAGE = "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public"
HERE = os.path.dirname(__file__)
COURSE_IDS = {
    'en': '20000000-0000-0000-0000-000000000001', 'pt': '20000000-0000-0000-0000-000000000002',
    'fr': '20000000-0000-0000-0000-000000000003', 'it': '20000000-0000-0000-0000-000000000004',
    'de': '20000000-0000-0000-0000-000000000005', 'nl': '20000000-0000-0000-0000-000000000006',
}


def story_id(code, order):
    return str(uuid.uuid5(NS, 'story:%s:%d' % (code, order)))


def build(stamp, files):
    L = ['-- %s_seed_stories.sql' % stamp,
         '-- Historias (inmersión) multi-idioma. ADITIVA (no toca las historias en).',
         '-- stories es course-scoped (get_stories/get_story/submit_story por jz_active_course)',
         '-- → cada curso ve las suyas. questions calificadas server-side (submit_story→jz_grade,',
         '-- correct_answer oculto 42501). ids uuid5. audio_url → audio/stories/<id>_<i>.mp3.',
         'begin;']
    rows = []
    summary = []
    for fname in files:
        code = fname.split('_')[1]  # story_<code>_<n>.json
        course_id = COURSE_IDS[code]
        s = json.load(io.open(os.path.join(HERE, fname), encoding='utf-8'))
        oi = int(s['order_index'])
        sid = story_id(code, oi)
        # audio_url por segmento
        segs = []
        for i, seg in enumerate(s['segments']):
            segs.append({'en': seg['en'], 'es': seg['es'],
                         'audio_url': '%s/audio/stories/%s-%d.mp3' % (STORAGE, sid, i)})
        est = int(s.get('est_seconds') or len(segs) * 8)
        rows.append(
            "('%s'::uuid,'%s'::uuid,'%s',%d,%s,%s,%s,%s,%d,%s::jsonb,%s::jsonb,%s::jsonb)" % (
                sid, course_id, s['cefr_level'], oi,
                dollar(s['title']), dollar(s['subtitle']), dollar(s['emoji']), dollar(s['intro']),
                est, jdollar(segs), jdollar(s['glossary']), jdollar(s['questions'])))
        summary.append('%s#%d "%s" (%d seg, %d gloss, %d preg)' % (
            code, oi, s['title'], len(segs), len(s['glossary']), len(s['questions'])))
    L.append('insert into stories (id, course_id, cefr_level, order_index, title, subtitle, emoji, intro, est_seconds, segments, glossary, questions) values')
    L.append(',\n'.join(rows))
    L.append('on conflict (id) do update set title=excluded.title, subtitle=excluded.subtitle, '
             'emoji=excluded.emoji, intro=excluded.intro, est_seconds=excluded.est_seconds, '
             'segments=excluded.segments, glossary=excluded.glossary, questions=excluded.questions;')
    L.append('commit;')
    out = os.path.join(HERE, '..', '..', 'supabase', 'migrations', '%s_seed_stories.sql' % stamp)
    io.open(out, 'w', encoding='utf-8').write('\n'.join(L))
    print('escrito', out)
    for x in summary:
        print(' ', x)


if __name__ == '__main__':
    build(sys.argv[1], sys.argv[2:])
