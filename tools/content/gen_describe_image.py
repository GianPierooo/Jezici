"""Genera mig 088: ejercicio "DESCRIBE LA IMAGEN" en forma DETERMINISTA (autocalificable).
Reusa word_bank (skill=writing, produccion guiada): el usuario ARMA con fichas la frase que
describe la imagen ("This is a house") -> secuencia verificable (jz_grade word_bank). La imagen
(Twemoji CC-BY, ya sembrada en vocab_images) es el estimulo via payload.image_url. NO es texto
libre: la descripcion ABIERTA evaluada por IA es Fase 2 (techo determinista).

Degradacion: cada frase tiene UN solo sustantivo -> resoluble desde las fichas aunque la imagen
no cargue. correct_answer OCULTO (42501). Cableado a la leccion de su unidad + tag unidadN.
"""
import json, uuid
from apply_sql import run

EN = '20000000-0000-0000-0000-000000000001'
NS = uuid.UUID('de5c41be-0000-4000-8000-000000000000')
UNIT_LEVEL = {3: 'A1', 4: 'A1', 5: 'A1', 6: 'A1', 9: 'A2', 10: 'A2'}
DIFF = {'A1': 0.18, 'A2': 0.38}

# (concepto, secuencia correcta, [distractores de ficha], unidad). El distractor ENSENA
# el punto: a/an/the/sin-articulo (incontables), this/there. Frases ancladas a lo que el
# emoji muestra (objeto unico) -> A1 "This is a/an/the X"; A2 "There is a X" / "I can see a X".
DESCRIBE = [
    ('house',  ['This', 'is', 'a', 'house'],        ['the'], 6),
    ('dog',    ['This', 'is', 'a', 'dog'],           ['the'], 3),
    ('cat',    ['This', 'is', 'a', 'cat'],           ['an'],  3),
    ('apple',  ['This', 'is', 'an', 'apple'],        ['a'],   4),
    ('coffee', ['This', 'is', 'coffee'],             ['a'],   4),
    ('bread',  ['This', 'is', 'bread'],              ['a'],   4),
    ('car',    ['This', 'is', 'a', 'car'],           ['the'], 6),
    ('school', ['This', 'is', 'a', 'school'],        ['the'], 6),
    ('sun',    ['This', 'is', 'the', 'sun'],         ['a'],   5),
    ('family', ['This', 'is', 'a', 'family'],        ['the'], 3),
    ('bus',    ['There', 'is', 'a', 'bus'],          ['the'], 9),
    ('train',  ['There', 'is', 'a', 'train'],        ['an'],  9),
    ('plane',  ['I', 'can', 'see', 'a', 'plane'],    ['the'], 9),
    ('hotel',  ['There', 'is', 'a', 'hotel'],        ['an'],  9),
    ('money',  ['This', 'is', 'money'],              ['a'],   10),
    ('shirt',  ['There', 'is', 'a', 'shirt'],        ['the'], 10),
]
LESSON_CYCLE = [1, 2, 3, 4]

def main():
    imgs = {r['concept']: r['image_url'] for r in json.loads(run("select concept, image_url from vocab_images;")[1])}
    rows_ci, rows_li = [], []
    oi = {}
    def next_oi(u, le):
        k = (u, le); oi[k] = oi.get(k, 300) + 1; return oi[k]

    n = 0
    for idx, (concept, seq, distractors, unit) in enumerate(DESCRIBE):
        if concept not in imgs:
            print('SIN IMAGEN, omito:', concept); continue
        lvl = UNIT_LEVEL[unit]
        tiles = sorted(seq + distractors)  # scramble determinista (no es el orden-respuesta)
        sentence = ' '.join(seq)
        payload = {'tiles': tiles, 'image_url': imgs[concept]}
        ca = {'value': sentence, 'sequence': seq}
        iid = uuid.uuid5(NS, f'imgdescribe-{concept}')
        tags = [f'unidad{unit}', 'describe', 'writing', 'imgdescribe']
        rows_ci.append(_ci(iid, lvl, 'writing', 'word_bank',
                           'Describe la imagen: arma la frase en inglés.', payload, ca, DIFF[lvl], tags))
        le = LESSON_CYCLE[idx % len(LESSON_CYCLE)]
        rows_li.append(_li(iid, unit, le, next_oi(unit, le)))
        n += 1

    sql = """-- ============================================================================
-- Jezici . Migracion 088 . Ejercicio "DESCRIBE LA IMAGEN" determinista (es->en A1/A2)
-- ----------------------------------------------------------------------------
-- Reusa word_bank (skill=writing, PRODUCCION guiada): el usuario arma con fichas la frase
-- que describe la imagen (Twemoji CC-BY via payload.image_url). Secuencia verificable
-- (jz_grade word_bank) => 100% server-side, correct_answer OCULTO (42501). El distractor
-- de ficha ensena el articulo (a/an/the/incontable). Degradacion: 1 solo sustantivo por
-- frase => resoluble desde las fichas aunque la imagen no cargue. La descripcion ABIERTA
-- evaluada (fluidez/coherencia) es FASE 2 (techo determinista, sin IA no se autocalifica).
-- Cableado a la leccion de su unidad + tag unidadN (pool examen). {n} items (writing).
-- ============================================================================
begin;

insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
{ci}
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload,
  correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();

{li}

commit;
""".format(n=n, ci=',\n'.join(rows_ci), li='\n'.join(rows_li))
    open('../../supabase/migrations/20260625120088_describe_image.sql', 'w', encoding='utf-8').write(sql)
    print('escrito mig 088 ·', n, 'items describe-la-imagen (word_bank/writing)')

def _ci(iid, lvl, skill, typ, prompt, payload, ca, diff, tags):
    sq = lambda s: s.replace("'", "''")
    return ("  ('{id}'::uuid, '{c}'::uuid, '{lvl}'::cefr_level, '{skill}'::skill, '{typ}'::content_item_type, "
            "'{p}', '{pl}'::jsonb, '{ca}'::jsonb, {d}, ARRAY[{tags}])").format(
        id=iid, c=EN, lvl=lvl, skill=skill, typ=typ, p=sq(prompt),
        pl=sq(json.dumps(payload, ensure_ascii=False)), ca=sq(json.dumps(ca, ensure_ascii=False)),
        d=diff, tags=', '.join("'%s'" % t for t in tags))

def _li(iid, unit, lesson, order):
    return ("insert into lesson_items (lesson_id, item_id, order_index) "
            "select le.id, '{id}'::uuid, {o} from lessons le join units u on u.id=le.unit_id "
            "where u.course_id='{c}' and u.order_index={unit} and le.order_index={lesson} "
            "on conflict (lesson_id, item_id) do nothing;").format(id=iid, o=order, c=EN, unit=unit, lesson=lesson)

if __name__ == '__main__':
    main()
