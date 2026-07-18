# -*- coding: utf-8 -*-
"""LÉXICO Fase 0 — "cosechar lo sembrado" (LEXICO_PLAN §3).
Vincula a lecciones las palabras de `vocabulary` que YA tienen traducción revisada
(del seed autorado) pero NO se enseñan (sin lesson_vocab → inertes en el SRS).

CERO IA: solo reusa traducciones existentes + genera ítems `match` por PLANTILLA.
Determinista (uuid5). Guardas: excluye término==traducción, >4 palabras (frases/
oraciones/idioms = F3), y dentro de cada ítem exige traducciones (`es`) distintas
bajo normalización (así el grading de match no es ambiguo). Ancla las lecciones de
repaso ANTES del checkpoint de una unidad de nivel coherente (freq_rank/30) →
quedan en la RUTA de completado real; el checkpoint (y su tag unidadN) intactos.

uso: python gen_lexico_f0.py   → escribe la migración + _lex0/report.json
"""
import json, re, uuid, unicodedata, os, bisect

NS = uuid.uuid5(uuid.NAMESPACE_URL, 'jezici/lexico_f0')

CODES = ['en', 'pt', 'fr', 'it', 'de', 'nl']
CEFR_OF_UNIT = lambda u: ['A1', 'A2', 'B1', 'B2', 'C1'][min((u - 1) // 6, 4)]
MAX_PAIRS = 5           # pares por ítem match
MAX_WORDS_LESSON = 10   # palabras por lección de repaso


def norm(t):
    t = (t or '').lower()
    t = unicodedata.normalize('NFD', t)
    t = ''.join(c for c in t if unicodedata.category(c) != 'Mn')  # sin tildes/umlaut
    t = re.sub(r"[.!?¿¡,;:'\"’‘´`“”()]", '', t)
    t = re.sub(r'\s+', ' ', t).strip()
    return t


def lev(a, b):
    if a == b:
        return 0
    la, lb = len(a), len(b)
    if abs(la - lb) > 1:
        return 2
    prev = list(range(lb + 1))
    for i, ca in enumerate(a, 1):
        cur = [i]
        for j, cb in enumerate(b, 1):
            cur.append(min(prev[j] + 1, cur[-1] + 1, prev[j - 1] + (ca != cb)))
        prev = cur
    return prev[lb]


def es_collides(es, existing):
    """Dentro de un mismo ítem match: dos `es` iguales (o dist-1) romperían el
    grading (el usuario podría intercambiarlos). Se separan en ítems distintos."""
    ne = norm(es)
    for e in existing:
        n = norm(e)
        if n == ne or lev(n, ne) <= 1:
            return True
    return False


def q(sql):
    from apply_sql import run
    return json.loads(run(sql)[1])


def sq(s):
    return "'" + s.replace("'", "''") + "'"


def main():
    rows = json.load(open('_lex0/unlinked.json', encoding='utf-8'))
    linked = json.load(open('_lex0/linked_freq_unit.json', encoding='utf-8'))
    by = {}
    for r in rows:
        by.setdefault(r['code'], []).append(r)

    excluded = {}   # code -> [(word, translation, motivo)]
    report = {}     # code -> {kept, lessons, units, sample}
    items_sql, lessons_meta = [], {}  # lessons_meta: code -> {unit: [ (lesson_id,title,[item_ids]) ]}

    for code in CODES:
        ws = sorted(by.get(code, []), key=lambda w: w['frequency_rank'])
        kept, exc = [], []
        for w in ws:
            word, tr = w['word'].strip(), (w['translation'] or '').strip()
            if not tr:
                exc.append((word, tr, 'sin_traduccion')); continue
            if norm(word) == norm(tr):
                exc.append((word, tr, 'termino==traduccion (cognado trivial)')); continue
            if len(word.split()) > 4:
                exc.append((word, tr, 'frase/oracion >4 palabras (F3)')); continue
            kept.append(w)
        excluded[code] = exc

        # unidad destino: la de la palabra YA VINCULADA de frecuencia MÁS CERCANA
        # (nearest-neighbor sobre el mapa real freq→unidad; mejor fundado que un
        # divisor fijo, robusto a las escalas de freq_rank distintas por curso).
        anchor = sorted((a[0], a[1]) for a in linked.get(code, []))
        afr = [a[0] for a in anchor]

        def nearest_unit(fr):
            if not anchor:
                return max(2, min(30, round(fr / 30)))
            i = bisect.bisect_left(afr, fr)
            cands = []
            if i < len(anchor):
                cands.append(anchor[i])
            if i > 0:
                cands.append(anchor[i - 1])
            best = min(cands, key=lambda a: abs(a[0] - fr))
            return max(2, min(30, best[1]))

        for w in kept:
            w['_unit'] = nearest_unit(w['frequency_rank'])
        # agrupar por unidad, dentro chunk en lecciones de <=10
        byunit = {}
        for w in kept:
            byunit.setdefault(w['_unit'], []).append(w)

        lessons_meta[code] = {}
        for unit in sorted(byunit):
            uw = sorted(byunit[unit], key=lambda w: w['frequency_rank'])
            nles = max(1, -(-len(uw) // MAX_WORDS_LESSON))
            # reparto equilibrado
            size = -(-len(uw) // nles)
            chunks = [uw[i:i + size] for i in range(0, len(uw), size)]
            lst = []
            for li, chunk in enumerate(chunks):
                lesson_id = str(uuid.uuid5(NS, f'{code}:u{unit}:les{li}'))
                # partir el chunk en ítems match con guarda de colisión de `es`
                items, cur = [], []
                cur_es = []
                for w in chunk:
                    if len(cur) >= MAX_PAIRS or es_collides(w['translation'], cur_es):
                        if cur:
                            items.append(cur)
                        cur, cur_es = [], []
                    cur.append(w); cur_es.append(w['translation'])
                if cur:
                    items.append(cur)
                item_ids = []
                cefr = CEFR_OF_UNIT(unit)
                for ii, pairs in enumerate(items):
                    if len(pairs) < 2:
                        # un match de 1 par no tiene sentido → convertir a translation
                        w = pairs[0]
                        iid = str(uuid.uuid5(NS, f'{code}:u{unit}:l{li}:tr{ii}'))
                        payload = json.dumps({'source': w['translation']}, ensure_ascii=False)
                        correct = json.dumps({'value': w['word']}, ensure_ascii=False)
                        items_sql.append(
                            f"insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) "
                            f"select {sq(iid)}, c.id, {sq(cefr)}, 'reading', 'translation', "
                            f"'Traduce al idioma que aprendes.', {sq(payload)}::jsonb, {sq(correct)}::jsonb, 0.2, "
                            f"array['repaso_vocab','reading'] "
                            f"from courses c join languages l on l.id=c.target_language_id where l.code={sq(code)} "
                            f"on conflict (id) do nothing;")
                        item_ids.append(iid)
                        continue
                    iid = str(uuid.uuid5(NS, f'{code}:u{unit}:l{li}:m{ii}'))
                    pj = [{'en': w['word'], 'es': w['translation']} for w in pairs]
                    cj = [[w['word'], w['translation']] for w in pairs]
                    payload = json.dumps({'pairs': pj}, ensure_ascii=False)
                    correct = json.dumps({'pairs': cj}, ensure_ascii=False)
                    items_sql.append(
                        f"insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) "
                        f"select {sq(iid)}, c.id, {sq(cefr)}, 'reading', 'match', "
                        f"'Empareja cada palabra con su traducción.', {sq(payload)}::jsonb, {sq(correct)}::jsonb, 0.15, "
                        f"array['repaso_vocab','reading'] "
                        f"from courses c join languages l on l.id=c.target_language_id where l.code={sq(code)} "
                        f"on conflict (id) do nothing;")
                    item_ids.append(iid)
                title = 'Repaso de vocabulario' + (f' {li + 1}' if len(chunks) > 1 else '')
                lst.append((lesson_id, title, item_ids, [w['id'] for w in chunk]))
            lessons_meta[code][unit] = lst

        report[code] = {
            'sueltas': len(ws), 'excluidas': len(exc), 'rescatadas': len(kept),
            'lecciones': sum(len(v) for v in lessons_meta[code].values()),
            'unidades_tocadas': sorted(byunit),
        }

    # ── construir la migración ──
    out = []
    out.append("-- LÉXICO Fase 0 — cosechar lo sembrado (LEXICO_PLAN §3). CERO IA.")
    out.append("-- Vincula a lecciones de repaso las palabras del seed con traducción revisada")
    out.append("-- que no se enseñaban (sin lesson_vocab). Ítems `match` por plantilla, tag")
    out.append("-- 'repaso_vocab' (NO unidadN → checkpoints/exámenes/placement intactos). Las")
    out.append("-- lecciones se anclan ANTES del checkpoint de una unidad de nivel coherente")
    out.append("-- (freq_rank/30). Idempotente (uuid5 + on conflict do nothing).")
    out.append("")
    out.append("-- 1) content_items")
    out += items_sql
    out.append("")
    out.append("-- 2) lecciones de repaso + lesson_items (DO-block por unidad: desplaza el")
    out.append("--    checkpoint para insertar la lección en la ruta; el desbloqueo del")
    out.append("--    checkpoint es por type+unit, no por order_index → gating intacto).")
    for code in CODES:
        for unit, lst in sorted(lessons_meta[code].items()):
            k = len(lst)
            first_lid = lst[0][0]
            blk = [f"do $$", f"declare v_unit uuid; v_c int;", "begin",
                   f"  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.",
                   f"  if exists (select 1 from lessons where id={sq(first_lid)}) then return; end if;",
                   f"  select u.id into v_unit from units u join courses c on c.id=u.course_id",
                   f"    join languages l on l.id=c.target_language_id",
                   f"    where l.code={sq(code)} and u.order_index={unit};",
                   f"  if v_unit is null then return; end if;",
                   f"  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';",
                   f"  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;",
                   f"  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;"]
            for j, (lid, title, item_ids, _) in enumerate(lst):
                blk.append(
                    f"  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) "
                    f"values ({sq(lid)}, v_unit, v_c+{j}, {sq(title)}, "
                    f"'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;")
                for oi, iid in enumerate(item_ids):
                    blk.append(
                        f"  insert into lesson_items(lesson_id,item_id,order_index) "
                        f"values ({sq(lid)}, {sq(iid)}, {oi}) on conflict do nothing;")
            blk.append(f"  update lessons set order_index=order_index-1000+{k} where unit_id=v_unit and order_index>=1000;")
            blk.append("end $$;")
            out += blk
            out.append("")

    # 3) re-derivar lesson_vocab (lógica mig 166, idempotente) → vincula las palabras
    out.append("-- 3) re-derivar lesson_vocab (idempotente, lógica mig 165/166) → las palabras")
    out.append("--    de los match nuevos quedan VINCULADAS → dejan de ser inertes.")
    out.append(open('_lex0/derive_lesson_vocab.sql', encoding='utf-8').read())

    os.makedirs('../../supabase/migrations', exist_ok=True)
    mig = '../../supabase/migrations/20260718120168_lexico_f0_cosecha.sql'
    open(mig, 'w', encoding='utf-8').write('\n'.join(out))

    # reporte + muestra 5% por idioma para revisión de Gian
    sample = {}
    for code in CODES:
        pairs = []
        for unit, lst in lessons_meta[code].items():
            for lid, title, item_ids, wids in lst:
                pass
        # muestra: primeras palabras rescatadas de cada unidad
        flat = [(w['word'], w['translation'], w['_unit'])
                for w in sorted(by.get(code, []), key=lambda w: w['frequency_rank'])
                if '_unit' in w]
        n = max(3, round(len(flat) * 0.05))
        step = max(1, len(flat) // n)
        sample[code] = flat[::step][:n]
    json.dump({'report': report, 'excluded': excluded, 'sample_5pct': sample},
              open('_lex0/report.json', 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
    print('MIGRACIÓN:', mig)
    for code in CODES:
        print(code, report[code])


if __name__ == '__main__':
    main()
