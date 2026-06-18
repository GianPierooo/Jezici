"""QA de contenido (A1 u3-6 + A2): lee el contenido VIVO de la BD, lo exporta a
docs/CONTENT_EXPORT.md (legible) y corre el validador estructural EXTENDIDO con las
comprobaciones deterministas de la rúbrica (duplicados, tolerancia, distractores,
marcadores CEFR, calibración de dificultad, idioma). También emite un JSON
(_content_dump.json) para la pasada pedagógica multi-agente.

Uso: python content_qa.py            # export + validate + dump
     python content_qa.py validate   # solo validate (imprime hallazgos)
"""
import json, re, sys, os
from apply_sql import run

COURSE = '20000000-0000-0000-0000-000000000001'      # es→en
COURSE_PT = '20000000-0000-0000-0000-000000000002'   # es→pt

def q(sql):
    c, o = run(sql)
    if c not in (200, 201):
        sys.exit(f"query falló [{c}]: {o[:400]}")
    return json.loads(o) if o and o.strip().startswith('[') else []

def norm(t):
    t = (t or '')
    t = re.sub(r'[.!?¿¡,;:"\']', '', t.lower())
    return re.sub(r'\s+', ' ', t).strip()

# ── Carga del contenido vivo (unidades en alcance) ──────────────────────────
def load(course_id=COURSE, scope=None, lang='en'):
    # scope: fragmento WHERE sobre las unidades en alcance (por defecto el de es→en).
    scope = scope or "((u.cefr_level='A1' and u.order_index between 3 and 6) or u.cefr_level in ('A2','B1','B2'))"
    units = q(f"""select u.id, u.order_index as unum, u.cefr_level, u.title
                  from units u
                  where u.course_id='{course_id}' and {scope}
                  order by u.order_index;""")
    for u in units:
        u['lang'] = lang
        u['lessons'] = q(f"""select l.id, l.order_index, l.title, l.type
                             from lessons l where l.unit_id='{u['id']}' order by l.order_index;""")
        for les in u['lessons']:
            les['items'] = q(f"""select ci.id, ci.skill, ci.type, ci.prompt, ci.payload, ci.correct_answer, ci.difficulty, ci.tags, li.order_index ord
                                 from lesson_items li join content_items ci on ci.id=li.item_id
                                 where li.lesson_id='{les['id']}' order by li.order_index;""")
        # vocab por nivel: es→en A2:300 B1:500 B2:900 · es→pt A1:100 (todo +U*20)
        base = {'A1': 100, 'A2': 300, 'B1': 500, 'B2': 900}.get(u['cefr_level'], 500)
        want_vocab = (lang == 'pt') or (u['cefr_level'] in ('A2', 'B1', 'B2'))
        u['vocab'] = q(f"""select v.word, v.translation, v.frequency_rank, v.part_of_speech
                           from vocabulary v where v.course_id='{course_id}'
                           and v.frequency_rank between {base + u['unum']*20} and {base + u['unum']*20 + 19}
                           order by v.frequency_rank;""") if want_vocab else []
    return units

# ── Export legible a Markdown ───────────────────────────────────────────────
def export_md(units, path, title='A1 unidades 3–6 + A2 + B1 + B2'):
    out = [f'# Jezici — Export de contenido ({title})\n',
           '> Generado por `tools/content/content_qa.py` desde la BD viva, para revisión humana.',
           '> Cada ítem: skill · tipo · prompt (es) · contenido (en) · respuesta correcta.\n']
    for u in units:
        out.append(f"\n## Unidad {u['unum']} ({u['cefr_level']}) — {u['title']}\n")
        for les in u['lessons']:
            tag = '🏁 ' if les['type'] == 'checkpoint' else ''
            out.append(f"\n### {tag}L{les['order_index']} · {les['title']}  _(items: {len(les['items'])})_\n")
            for it in les['items']:
                p = it['payload'] or {}
                c = it['correct_answer'] or {}
                line = f"- **[{it['skill']}/{it['type']}]** {it['prompt'] or '_(sin prompt)_'}"
                # contenido en inglés según tipo
                detail = []
                if it['type'] in ('multiple_choice', 'true_false', 'listening'):
                    detail.append(f"opciones: {p.get('options')}")
                    detail.append(f"✓ `{c.get('value')}`")
                    if it['type'] == 'listening' and p.get('say'): detail.append(f"audio dice: «{p.get('say')}»")
                elif it['type'] == 'match':
                    detail.append(f"pares: {c.get('pairs')}")
                elif it['type'] == 'cloze':
                    detail.append(f"texto: «{p.get('text')}»  ✓ `{c.get('value')}`")
                    if c.get('accepted'): detail.append(f"acepta: {c.get('accepted')}")
                elif it['type'] == 'translation':
                    detail.append(f"es: «{p.get('source')}»  ✓ en: `{c.get('value')}`")
                    if c.get('accepted'): detail.append(f"acepta: {c.get('accepted')}")
                elif it['type'] == 'word_bank':
                    detail.append(f"fichas: {p.get('tiles')}  ✓ `{' '.join(c.get('sequence') or [])}`")
                elif it['type'] == 'reorder':
                    detail.append(f"fichas: {p.get('tiles')}  ✓ `{c.get('value')}`")
                elif it['type'] == 'speaking_read_aloud':
                    detail.append(f"lee: «{p.get('text')}»  esperado: `{c.get('expected')}`")
                line += "  — " + " · ".join(str(d) for d in detail) + f"  _(dif {it['difficulty']})_"
                out.append(line)
        if u['vocab']:
            out.append(f"\n**Vocabulario (frecuencia):** " + ", ".join(f"{v['word']}={v['translation']}" for v in u['vocab']))
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w', encoding='utf-8') as f:
        f.write("\n".join(out) + "\n")
    return path

# ── Validador estructural EXTENDIDO (rúbrica determinista) ──────────────────
PAST_MARKERS = re.compile(r"\b(was|were|did|didn't|had|went|saw|ate|bought|came|made|took|got|said|"
                          r"\w+ed)\b", re.I)
FUTURE_MARKERS = re.compile(r"\b(will|going to|won't)\b", re.I)

_ES = (r"\b(el|la|los|las|tu|tú|qué|cómo|en|con|una|un|y|a|de|del|al|por|para|escribe|elige|"
       r"completa|ordena|traduce|empareja|di|escucha|lee|significa|responde|opción|correcta|"
       r"pregunta|frase|palabra|dice|verdadero|falso|según|cuál|quién|dónde|cuándo|forma|"
       r"hueco|espacio|oración|vacío|usa|pronuncia|repite|selecciona|marca|relaciona|"
       r"compara|comparativo|superlativo|mejor|peor|más|menos|significan|traducción)\b")
def looks_spanish(s):
    s = s or ''
    return bool(re.search(r"[áéíóúñ¿¡]", s)) or bool(re.search(_ES, s.lower()))

def validate(units):
    F = []  # (severity, code, where, detail)
    seen_answers = {}   # norm(answer) -> location (dup detection global)
    seen_prompts = {}
    processed = set()   # ids ya validados (el checkpoint REUSA ítems de L1-L4: no son duplicados)
    for u in units:
        lvl = u['cefr_level']
        for les in u['lessons']:
            for it in les['items']:
                if it['id'] in processed:
                    continue  # mismo ítem reusado en el checkpoint → validar una sola vez
                processed.add(it['id'])
                at = f"U{u['unum']}/L{les['order_index']}/{it['id'][:8]} ({it['skill']}/{it['type']})"
                p = it['payload'] or {}
                c = it['correct_answer'] or {}
                t = it['type']
                # idioma del prompt (instrucción en español)
                if it['prompt'] and not looks_spanish(it['prompt']) and t != 'speaking_read_aloud':
                    F.append(('FUNCIONAL', 'PROMPT_EN', at, f"prompt no parece español: «{it['prompt']}»"))
                # distractores mc/listening
                if t in ('multiple_choice', 'true_false', 'listening'):
                    opts = p.get('options') or []
                    val = c.get('value')
                    nopts = [norm(o) for o in opts]
                    if val is not None and nopts.count(norm(val)) != 1:
                        F.append(('CRITICO', 'CORRECT_DUP_OPT', at, f"correct '{val}' aparece {nopts.count(norm(val))} veces en opciones {opts}"))
                    if len(set(nopts)) != len(nopts):
                        F.append(('FUNCIONAL', 'OPT_DUP', at, f"opciones duplicadas: {opts}"))
                    if len(opts) < 3 and t == 'multiple_choice':
                        F.append(('PULIDO', 'FEW_OPTS', at, f"solo {len(opts)} opciones"))
                # tolerancia: translation/cloze sin alternativas aceptadas
                if t in ('translation', 'cloze'):
                    acc = c.get('accepted')
                    if not acc:
                        F.append(('FUNCIONAL', 'NO_ACCEPTED', at, f"sin `accepted` (intolerante a variantes): ✓«{c.get('value')}»"))
                # CEFR: A1 no debería usar pasado/futuro complejo
                blob = ' '.join(str(x) for x in [it['prompt'], p.get('text'), p.get('source'), c.get('value'),
                                                 p.get('say'), p.get('text'), ' '.join(p.get('options') or [])])
                en_blob = ' '.join(str(x) for x in [c.get('value'), p.get('text'), p.get('say'),
                                                    p.get('expected'), ' '.join(p.get('options') or []),
                                                    ' '.join(p.get('tiles') or [])])
                if lvl == 'A1' and u['unum'] != 0 and u.get('lang') == 'en':
                    m = PAST_MARKERS.search(en_blob or '')
                    if m and m.group(0).lower() not in ('red', 'bed', 'need', 'feed', 'seed', 'speed', 'used', 'bored'):
                        F.append(('FUNCIONAL', 'A1_PAST', at, f"posible pasado en A1: «{m.group(0)}» en «{en_blob.strip()[:80]}»"))
                # dificultad fuera de rango por nivel
                d = float(it['difficulty'] or 0)
                if lvl == 'A1' and not (0.05 <= d <= 0.35):
                    F.append(('PULIDO', 'DIFF_RANGE', at, f"dificultad {d} fuera de A1 [0.05,0.35]"))
                if lvl == 'A2' and not (0.18 <= d <= 0.60):
                    F.append(('PULIDO', 'DIFF_RANGE', at, f"dificultad {d} fuera de A2 [0.18,0.60]"))
                if lvl == 'B2' and not (0.40 <= d <= 0.85):
                    F.append(('PULIDO', 'DIFF_RANGE', at, f"dificultad {d} fuera de B2 [0.40,0.85]"))
                # Ítem DUPLICADO de verdad = MISMO prompt Y MISMA respuesta (no solo
                # la instrucción genérica, que SÍ debe repetirse). El reuso de una
                # palabra de alta frecuencia en otra unidad NO es duplicado.
                key_ans = norm(str(c.get('value') or c.get('expected') or ' '.join(c.get('sequence') or []) or c.get('pairs') or ''))
                key = (norm(it['prompt'] or ''), key_ans)
                if key_ans and key[0]:
                    if key in seen_answers:
                        F.append(('PULIDO', 'DUP_ITEM', at, f"ítem casi-duplicado de {seen_answers[key]}: prompt+respuesta iguales («{it['prompt']}» → «{key_ans}»)"))
                    else:
                        seen_answers[key] = at
            # cobertura por unidad: ¿se desbalancea?
    # Distribución de habilidades por unidad
    for u in units:
        cnt = {'reading':0,'listening':0,'writing':0,'speaking':0}
        for les in u['lessons']:
            if les['type']=='checkpoint': continue
            for it in les['items']:
                cnt[it['skill']] = cnt.get(it['skill'],0)+1
        tot = sum(cnt.values()) or 1
        if cnt['reading']/tot > 0.5:
            F.append(('FUNCIONAL','SKILL_IMBALANCE',f"U{u['unum']}",f"reading {cnt['reading']}/{tot} > 50% {cnt}"))
        if cnt['listening']+cnt['speaking'] < 0.20*tot:
            F.append(('PULIDO','LOW_AUDIO',f"U{u['unum']}",f"listening+speaking {cnt['listening']+cnt['speaking']}/{tot} < 20% {cnt}"))
    return F

def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else 'all'
    if mode == 'pt':  # curso es→pt (escalera completa A1–B2)
        units = load(COURSE_PT, "u.cefr_level in ('A1','A2','B1','B2')", 'pt')
        export_md(units, 'C:/Users/gianp/Desktop/Jezici/docs/CONTENT_EXPORT_PT.md', 'Portugués es→pt · A1–B2')
        print('[OK] export pt -> docs/CONTENT_EXPORT_PT.md')
        F = validate(units)
        print(f"\n=== VALIDADOR DETERMINISTA (es-pt A1): {len(F)} hallazgos ===")
        from collections import Counter
        by_sev = {}
        for sev, code, where, detail in F:
            by_sev.setdefault(sev, []).append((code, where, detail))
        for sev in ('CRITICO', 'FUNCIONAL', 'PULIDO'):
            its = by_sev.get(sev, [])
            print(f"[{sev}] {len(its)}")
            for code, n in Counter(c for c, _, _ in its).most_common():
                print(f"   {code}: {n}")
        for sev, code, where, detail in F:
            print(f"   - [{sev}] {code} {where}: {detail}")
        return
    units = load()
    if mode in ('all', 'export'):
        path = export_md(units, 'C:/Users/gianp/Desktop/Jezici/docs/CONTENT_EXPORT.md')
        print(f"[OK] export -> {path}")
        with open('_content_dump.json', 'w', encoding='utf-8') as f:
            json.dump(units, f, ensure_ascii=False)
        print("[OK] dump -> _content_dump.json")
    if mode in ('all', 'validate'):
        F = validate(units)
        by_sev = {}
        for sev, code, where, detail in F:
            by_sev.setdefault(sev, []).append((code, where, detail))
        print(f"\n=== VALIDADOR DETERMINISTA: {len(F)} hallazgos ===")
        for sev in ('CRITICO', 'FUNCIONAL', 'PULIDO'):
            items = by_sev.get(sev, [])
            print(f"\n[{sev}] {len(items)}")
            from collections import Counter
            codes = Counter(c for c, _, _ in items)
            for code, n in codes.most_common():
                print(f"   {code}: {n}")
        with open('_content_findings.json', 'w', encoding='utf-8') as f:
            json.dump([{'severity': s, 'code': c, 'where': w, 'detail': d} for s, c, w, d in F], f, ensure_ascii=False, indent=1)
        print("\n[OK] hallazgos -> _content_findings.json")

if __name__ == '__main__':
    main()
