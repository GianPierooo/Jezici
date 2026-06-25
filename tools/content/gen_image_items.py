"""Genera mig 087: items multiple_choice "imagen -> palabra" (es->en A1/A2). La IMAGEN
es el estimulo (payload.image_url, Twemoji CC-BY); el enunciado es generico ("¿Que es
esto?") => NO revela la respuesta por texto. Opciones = palabra inglesa correcta + 2
distractores de la MISMA categoria. correct_answer OCULTO (42501). Cableado a la leccion
de su unidad + tag unidadN (pool examen). UUID5 deterministas. ADITIVO.
"""
import json, uuid
from apply_sql import run

EN = '20000000-0000-0000-0000-000000000001'
NS = uuid.UUID('1a6e1ab1-0000-4000-8000-000000000000')

CAT_UNIT = {'food': 4, 'family': 3, 'time': 5, 'place': 6, 'travel': 9, 'shop': 10}
UNIT_LEVEL = {3: 'A1', 4: 'A1', 5: 'A1', 6: 'A1', 9: 'A2', 10: 'A2'}
DIFF = {'A1': 0.15, 'A2': 0.35}
# conceptos cuya IMAGEN es inequivoca -> sirven de respuesta-con-imagen
ITEM_CONCEPTS = {
    'food': ['coffee', 'bread', 'apple', 'milk'],
    'family': ['family', 'dog', 'cat'],
    'time': ['clock', 'sun', 'moon'],
    'place': ['house', 'school', 'car', 'hospital'],
    'travel': ['bus', 'train', 'plane', 'hotel'],
    'shop': ['money', 'shirt', 'shoes'],
}
LESSON_CYCLE = [1, 2, 3, 4]

def main():
    imgs = {r['concept']: (r['category'], r['image_url'])
            for r in json.loads(run("select concept, category, image_url from vocab_images;")[1])}
    # pool de distractores por categoria (todas las palabras de esa categoria)
    pool = {}
    for c, (cat, _) in imgs.items():
        pool.setdefault(cat, []).append(c)
    for cat in pool:
        pool[cat].sort()

    rows_ci, rows_li = [], []
    oi = {}
    def next_oi(u, le):
        k = (u, le); oi[k] = oi.get(k, 200) + 1; return oi[k]

    n = 0
    for cat, concepts in ITEM_CONCEPTS.items():
        unit = CAT_UNIT[cat]; lvl = UNIT_LEVEL[unit]
        for idx, concept in enumerate(concepts):
            if concept not in imgs:
                print('SIN IMAGEN, omito:', concept); continue
            url = imgs[concept][1]
            # 2 distractores de la misma categoria (deterministas, != concept)
            others = [c for c in pool[cat] if c != concept]
            distractors = (others * 3)[idx:idx + 2] if len(others) >= 2 else others[:2]
            options = [concept] + distractors
            # orden determinista (alfabetico) para no sesgar posicion
            options = sorted(options)
            iid = uuid.uuid5(NS, f'imgvocab-{concept}')
            payload = {'options': options, 'image_url': url}
            ca = {'value': concept}
            tags = [f'unidad{unit}', cat, 'reading', 'imgvocab']
            rows_ci.append(_ci(iid, lvl, 'reading', 'multiple_choice',
                               '¿Qué es esto? Elige la palabra en inglés.', payload, ca, DIFF[lvl], tags))
            le = LESSON_CYCLE[idx % len(LESSON_CYCLE)]
            rows_li.append(_li(iid, unit, le, next_oi(unit, le)))
            n += 1

    sql = """-- ============================================================================
-- Jezici . Migracion 087 . Items imagen->palabra (vocab concreto es->en A1/A2)
-- ----------------------------------------------------------------------------
-- multiple_choice con payload.image_url (Twemoji CC-BY, registrado en vocab_images,
-- alojado en Storage). La imagen es el estimulo; enunciado generico => no revela la
-- respuesta por texto. Opciones = palabra correcta + 2 distractores de la misma
-- categoria. correct_answer OCULTO (42501). Cableado a leccion de su unidad + unidadN
-- (pool examen). Degradacion: si la imagen no carga, el ejercicio sigue (texto). {n} items.
-- ============================================================================
begin;

insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
{ci}
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload,
  correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();

{li}

commit;
""".format(n=n, ci=',\n'.join(rows_ci), li='\n'.join(rows_li))
    open('../../supabase/migrations/20260625120087_image_vocab_items.sql', 'w', encoding='utf-8').write(sql)
    print('escrito mig 087 ·', n, 'items imagen->palabra')

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
