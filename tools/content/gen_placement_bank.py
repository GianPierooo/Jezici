"""Genera la migración 075 (banco de placement es->en) desde el JSON validado
del workflow. UUIDs deterministas (uuid5), answer OCULTO (correct_answer → 42501),
difficulty por nivel. ADITIVO (on conflict do nothing) — no borra los 16 previos.
"""
import json, uuid

COURSE = '20000000-0000-0000-0000-000000000001'  # es->en
NS = uuid.UUID('5f1cc0de-0000-4000-8000-000000000000')  # namespace estable de placement
DIFF = {'A1': 0.12, 'A2': 0.32, 'B1': 0.52, 'B2': 0.72, 'C1': 0.9}

def sq(s):  # escapa para SQL ' -> ''
    return s.replace("'", "''")

def main():
    d = json.loads(open('_placement_raw.json', encoding='utf-8').read())
    items = d['result']['items']
    rows = []
    seq = {}
    for it in items:
        lvl, skill, typ = it['level'], it['skill'], it['type']
        k = (lvl, skill)
        seq[k] = seq.get(k, 0) + 1
        iid = uuid.uuid5(NS, f'placement-{lvl}-{skill}-{seq[k]}')
        opts = it['options']
        prompt = it['prompt']
        if typ == 'cloze':
            payload = {'text': prompt, 'options': opts}
        else:
            payload = {'options': opts}
        ca = {'value': it['answer']}
        tags = ['placement', lvl.lower(), skill, 'use_of_english']
        rows.append(
            "  ('{id}'::uuid, '{course}'::uuid, '{lvl}'::cefr_level, '{skill}'::skill, "
            "'{typ}'::content_item_type, '{prompt}', '{payload}'::jsonb, '{ca}'::jsonb, "
            "{diff}, ARRAY[{tags}])".format(
                id=iid, course=COURSE, lvl=lvl, skill=skill, typ=typ,
                prompt=sq(prompt), payload=sq(json.dumps(payload, ensure_ascii=False)),
                ca=sq(json.dumps(ca, ensure_ascii=False)), diff=DIFF[lvl],
                tags=', '.join("'%s'" % t for t in tags)))

    sql = """-- ============================================================================
-- Jezici . Migracion 075 . Banco de TEST DE UBICACION es->en (A1->C1, reading+writing)
-- ----------------------------------------------------------------------------
-- {n} items calibrados CEFR (autorados por panel de examinadores IA + validacion
-- ADVERSARIAL por nivel, descartando los dudosos). 5+5 por nivel (C1: 5R+3W).
-- multiple_choice (reading: vocab/comprension/uso) + cloze (writing: gramatica).
-- correct_answer queda OCULTO (content_items -> revocado mig 055, lectura=42501);
-- la calificacion la hace placement_next (mig 076) en el servidor. Tag 'placement'
-- => excluido de los pools de practica/examen (guardas ya existentes). ADITIVO:
-- on conflict do nothing (no toca los 16 previos ni nada mas).
-- ============================================================================
begin;

insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
{rows}
on conflict (id) do nothing;

commit;
""".format(n=len(rows), rows=',\n'.join(rows))

    out = '../../supabase/migrations/20260625120075_placement_bank.sql'
    open(out, 'w', encoding='utf-8').write(sql)
    print('escrito', out, 'con', len(rows), 'items')

if __name__ == '__main__':
    main()
