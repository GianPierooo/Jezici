# -*- coding: utf-8 -*-
"""Banco LISTENING + SPEAKING del placement (Fase 1: en + pt; fr/it/de/nl en Cola)
y RPC placement_next v3 (4 habilidades + per-skill). Emite la migración
20260709120135_placement_4skills.sql (uuid5, idempotente).

Diseño (## Cola retome + placement v2):
- LISTENING: type='listening' (se califica EXACTO como MC — mig 027; near_match NO
  aplica) con payload.say + audio_url (mismo pipeline TTS del resto) + 3 options.
  GUARDA: options normalize-distintas (ningún distractor == correcto normalizado).
- SPEAKING: read-aloud verificado → type='translation' (calificable server-side con
  tolerancia typo, DESEABLE para transcripciones STT). SIN options → sin riesgo de
  colisión de distractores. El cliente muestra payload.text, reconoce voz y envía
  la transcripción como answer.
python gen_placement_ls.py"""
import json
import re
import unicodedata
import uuid

NS = uuid.UUID('20000000-0000-0000-0000-0000000000aa')  # mismo namespace del banco
COURSES = {
    'en': '20000000-0000-0000-0000-000000000001',
    'pt': '20000000-0000-0000-0000-000000000002',
}
DIFF = {'A1': 0.15, 'A2': 0.35, 'B1': 0.55, 'B2': 0.72, 'C1': 0.84}
AUDIO_BASE = 'https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items'

# Instrucción (chrome) SIEMPRE en español, como el resto del banco.
L_PROMPT = 'Escucha el audio y elige exactamente lo que oíste.'
S_PROMPT = 'Lee esta frase EN VOZ ALTA con tu micrófono:'

# (say, [correcto, distractor1, distractor2]) — el correcto va primero aquí y se
# baraja determinista al emitir. (say == correcto siempre.)
LISTENING = {
    'en': {
        'A1': [
            ("She has two brothers.", ["She has two sisters.", "He has two brothers."]),
            ("The book is on the table.", ["The book is under the table.", "The cup is on the table."]),
            ("I get up at seven o'clock.", ["I get up at eleven o'clock.", "I go out at seven o'clock."]),
        ],
        'A2': [
            ("Yesterday I went to the beach.", ["Yesterday I want to the beach.", "Yesterday I went to the bridge."]),
            ("She is taller than her brother.", ["She is older than her brother.", "She is taller than her mother."]),
            ("We didn't have time to eat.", ["We didn't have time to sleep.", "We don't have time to eat."]),
        ],
        'B1': [
            ("I have never seen that movie.", ["I have never seen that mountain.", "I had never seen that movie."]),
            ("If it rains, we will stay at home.", ["If it rained, we would stay at home.", "If it rains, we will stay at work."]),
            ("She has been living here since March.", ["She has been living here since May.", "She had been living here since March."]),
        ],
        'B2': [
            ("The results will be announced tomorrow.", ["The results were announced yesterday.", "The results will be announced on Monday."]),
            ("He said he had already finished the report.", ["He said he would finish the report soon.", "He says he has already finished the report."]),
            ("Had I known, I would have called you.", ["Had I gone, I would have called you.", "If I know, I will call you."]),
        ],
        'C1': [
            ("Seldom have I encountered such a compelling argument.", ["Rarely have I encountered such a compelling argument.", "Seldom had I encountered such a compelling argument."]),
            ("The proposal was met with considerable skepticism.", ["The proposal was met with considerable enthusiasm.", "The proposal was made with considerable skepticism."]),
            ("Notwithstanding the delays, the project succeeded.", ["Notwithstanding the delays, the project collapsed.", "Despite the delays, the project succeeded."]),
        ],
    },
    'pt': {
        'A1': [
            ("Eu tenho dois irmãos.", ["Eu tenho duas irmãs.", "Ele tem dois irmãos."]),
            ("O livro está na mesa.", ["O livro está na mala.", "O copo está na mesa."]),
            ("Eu acordo às sete horas.", ["Eu acordo às seis horas.", "Eu janto às sete horas."]),
        ],
        'A2': [
            ("Ontem eu fui à praia.", ["Ontem eu vou à praia.", "Ontem eu fui à prova."]),
            ("Ela é mais alta que o irmão.", ["Ela é mais velha que o irmão.", "Ela é mais alta que a irmã."]),
            ("Nós não tivemos tempo de comer.", ["Nós não temos tempo de comer.", "Nós não tivemos tempo de correr."]),
        ],
        'B1': [
            ("Eu nunca vi esse filme.", ["Eu nunca vejo esse filme.", "Eu nunca vi esse prédio."]),
            ("Se chover, vamos ficar em casa.", ["Se chovesse, ficaríamos em casa.", "Se chover, vamos ficar na rua."]),
            ("Ela mora aqui desde março.", ["Ela mora aqui desde maio.", "Ela morava aqui desde março."]),
        ],
        'B2': [
            ("Os resultados serão anunciados amanhã.", ["Os resultados foram anunciados ontem.", "Os resultados serão anunciados na segunda."]),
            ("Ele disse que já tinha terminado o relatório.", ["Ele disse que ainda ia terminar o relatório.", "Ele diz que já terminou o relatório."]),
            ("Quando eu tiver tempo, farei o curso.", ["Quando eu tinha tempo, fazia o curso.", "Quando eu tiver tempo, faria o curso."]),
        ],
    },
}

# Speaking read-aloud: frase calibrada por nivel. value SIN puntuación final (las
# transcripciones STT no la traen); el cliente muestra `text` (con puntuación).
SPEAKING = {
    'en': {
        'A1': ["I have two cats", "The coffee is very good"],
        'A2': ["Last weekend I visited my grandmother", "I am going to travel next month"],
        'B1': ["I have been studying English for two years", "If I had more time, I would read more books"],
        'B2': ["The meeting had already started when I arrived", "This document must be signed by the manager"],
        'C1': ["Had it not been for her advice, I would have failed", "The findings ought to be interpreted with caution"],
    },
    'pt': {
        'A1': ["Eu moro em uma casa pequena", "O café está muito bom"],
        'A2': ["No fim de semana passado eu visitei minha avó", "Eu vou viajar no mês que vem"],
        'B1': ["Estou estudando português há dois anos", "Se eu tivesse mais tempo, leria mais livros"],
        'B2': ["A reunião já tinha começado quando eu cheguei", "Este documento deve ser assinado pelo gerente"],
    },
}


def norm(s):
    """Réplica de jz_normalize: minúsculas, sin tildes, sin puntuación, espacios 1."""
    s = unicodedata.normalize('NFD', s.lower())
    s = ''.join(c for c in s if unicodedata.category(c) != 'Mn')
    s = re.sub(r"[^a-z0-9\s']", ' ', s)
    s = re.sub(r'\s+', ' ', s).strip()
    return s


def sql_str(s):
    return "'" + s.replace("'", "''") + "'"


def main():
    lines = [
        '-- ============================================================================',
        '-- Jezici · Migración 135 · PLACEMENT 4 HABILIDADES (Fase 1: banco L/S en+pt)',
        '-- ----------------------------------------------------------------------------',
        '-- El placement solo medía reading/writing y copiaba el global ×4 → perfil de',
        '-- skills FALSO. Ahora: banco LISTENING (type=listening: MC exacto + audio TTS)',
        '-- y SPEAKING (read-aloud verificado: type=translation, transcripción STT con',
        '-- tolerancia typo, SIN options=sin colisión) para en+pt (cursos de verificación;',
        '-- fr/it/de/nl en ## Cola con este mismo generador gen_placement_ls.py).',
        '-- RPC v3: intercala las skills DISPONIBLES del banco (R→L→W→S), acepta',
        '-- p_exclude_skills (mic no disponible → speaking fuera, honesto), y estima',
        '-- nivel POR HABILIDAD con rigor anti-azar: global v2 intacto como ancla +',
        '-- DEMOTE-only por skill (una skill con >=3 ítems y acc<=0.4 baja 1 nivel;',
        '-- NUNCA se promueve por skill → el azar no puede inflar ninguna habilidad).',
        '-- Cursos sin banco L/S: rotación sirve R/W y L/S caen al global (igual que hoy).',
        '-- Mantiene min10/max16, rev>=4|pin>=3, clamp A2, estimador mig 134. 42501 OK.',
        '-- ============================================================================',
        'begin;',
        '',
        'insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values',
    ]
    rows = []
    errors = []
    for lang, levels in LISTENING.items():
        cid = COURSES[lang]
        for lvl, items in levels.items():
            for i, (say, distractors) in enumerate(items):
                # GUARDA: distractores normalize-distintos del correcto y entre sí.
                seen = {norm(say)}
                for d in distractors:
                    if norm(d) in seen:
                        errors.append(f'COLISIÓN listening {lang} {lvl} #{i}: {d!r} == correcto normalizado')
                    seen.add(norm(d))
                iid = str(uuid.uuid5(NS, f'{lang}-plc-{lvl}-listening-{i}'))
                # Orden determinista pero no siempre-primero: rota por índice.
                opts = [say] + list(distractors)
                opts = opts[i % 3:] + opts[:i % 3]
                payload = {'say': say, 'options': opts, 'audio_url': f'{AUDIO_BASE}/{iid}.mp3'}
                ca = {'value': say}
                tags = ['placement', lvl.lower(), 'listening']
                rows.append(
                    f"({sql_str(iid)}, {sql_str(cid)}, {sql_str(lvl)}, 'listening', 'listening', "
                    f"{sql_str(L_PROMPT)}, {sql_str(json.dumps(payload, ensure_ascii=False))}::jsonb, "
                    f"{sql_str(json.dumps(ca, ensure_ascii=False))}::jsonb, {DIFF[lvl]}, "
                    "ARRAY[" + ', '.join(sql_str(t) for t in tags) + '])'
                )
    for lang, levels in SPEAKING.items():
        cid = COURSES[lang]
        for lvl, items in levels.items():
            for i, sent in enumerate(items):
                iid = str(uuid.uuid5(NS, f'{lang}-plc-{lvl}-speaking-{i}'))
                payload = {'text': sent + '.', 'speaking': True}
                ca = {'value': sent}
                tags = ['placement', lvl.lower(), 'speaking']
                rows.append(
                    f"({sql_str(iid)}, {sql_str(cid)}, {sql_str(lvl)}, 'speaking', 'translation', "
                    f"{sql_str(S_PROMPT)}, {sql_str(json.dumps(payload, ensure_ascii=False))}::jsonb, "
                    f"{sql_str(json.dumps(ca, ensure_ascii=False))}::jsonb, {DIFF[lvl]}, "
                    "ARRAY[" + ', '.join(sql_str(t) for t in tags) + '])'
                )
    if errors:
        raise SystemExit('\n'.join(errors))
    lines.append(',\n'.join(rows))
    lines.append('on conflict (id) do nothing;')
    lines.append('')
    lines.append(RPC_SQL)
    lines.append('commit;')
    out = '../../supabase/migrations/20260709120135_placement_4skills.sql'
    with open(out, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines) + '\n')
    print(f'OK {out} · listening={sum(len(v) for l in LISTENING.values() for v in l.values())} '
          f'speaking={sum(len(v) for l in SPEAKING.values() for v in l.values())}')


RPC_SQL = r'''
-- ── RPC v3: 4 habilidades intercaladas + nivel POR HABILIDAD (demote-only) ────
-- La firma cambia (nuevo p_exclude_skills) → DROP para no dejar overload ambiguo
-- en PostgREST. Llamadas viejas (3 args con nombre) siguen resolviendo (default).
drop function if exists placement_next(uuid, text, jsonb);

create or replace function placement_next(
  p_course uuid default null, p_start_level text default null,
  p_history jsonb default '[]'::jsonb, p_exclude_skills text[] default null)
returns jsonb language plpgsql security definer set search_path = public as $$
declare
  uid uuid := auth.uid(); v_course uuid;
  v_band int; v_new int; v_dir int; v_prevdir int := 0; v_rev int := 0; v_n int := 0;
  v_pin int := 0;
  v_max_items int := 16; v_min_items int := 10; v_stop boolean;
  v_skill text; v_item jsonb;
  v_ranks int[]; v_correct boolean[]; v_overall int;
  v_avail text[];
  v_sk text; v_sk_n int; v_sk_c int; v_lvls jsonb := '{}'::jsonb;
  rec record;
begin
  if uid is null then raise exception 'auth required'; end if;
  v_course := coalesce(p_course, (select id from courses where is_active order by created_at limit 1));
  if v_course is null then raise exception 'no active course'; end if;

  create temp table _h on commit drop as
  select (e.elem ->> 'item_id')::uuid as item_id, ci.cefr_level, ci.skill,
         jz_rank(ci.cefr_level::text) as rnk,
         jz_grade(ci.type, ci.correct_answer, e.elem -> 'answer') as correct, e.ord
  from jsonb_array_elements(coalesce(p_history, '[]'::jsonb)) with ordinality e(elem, ord)
  join content_items ci on ci.id = (e.elem ->> 'item_id')::uuid
   and ci.course_id = v_course and 'placement' = any(ci.tags);

  -- Skills DISPONIBLES (banco del curso, no stub, no excluidas por el cliente).
  select array_agg(s order by pos) into v_avail
  from (
    select x.s, x.pos from (values ('reading',1),('listening',2),('writing',3),('speaking',4)) x(s,pos)
    where exists (select 1 from content_items ci where ci.course_id = v_course
                    and 'placement' = any(ci.tags) and ci.skill::text = x.s
                    and not jz_is_stub(ci.type))
      and (p_exclude_skills is null or x.s <> all(p_exclude_skills))
  ) q;
  if v_avail is null or array_length(v_avail, 1) is null then
    v_avail := array['reading','writing'];
  end if;
  -- Evidencia mínima POR skill: ~3 ítems de cada una antes de poder parar.
  v_min_items := greatest(v_min_items, 3 * array_length(v_avail, 1));

  -- Arranque CLAMPEADO a A2 máx (anti-azar, mig 131/134 — sin cambios).
  v_band := greatest(0, least(1, jz_rank(coalesce(p_start_level, 'A2'))));
  for rec in select correct from _h order by ord loop
    v_n := v_n + 1;
    v_new := case when rec.correct then least(v_band + 1, 4) else greatest(v_band - 1, 0) end;
    v_dir := sign(v_new - v_band);
    if v_dir <> 0 and v_prevdir <> 0 and v_dir <> v_prevdir then v_rev := v_rev + 1; end if;
    if v_dir <> 0 then v_prevdir := v_dir; end if;
    if v_new = v_band then v_pin := v_pin + 1; else v_pin := 0; end if;
    v_band := v_new;
  end loop;

  v_stop := (v_n >= v_max_items)
         or (v_n >= v_min_items and (v_rev >= 4 or v_pin >= 3));

  if not v_stop then
    -- Rotación R→L→W→S sobre las skills disponibles.
    v_skill := v_avail[(v_n % array_length(v_avail, 1)) + 1];

    select jsonb_build_object('id', x.id, 'type', x.type, 'skill', x.skill,
             'cefr_level', x.cefr_level, 'prompt', x.prompt, 'payload', x.payload)
      into v_item
    from (
      select ci.id, ci.type, ci.skill, ci.cefr_level, ci.prompt, ci.payload,
             abs(jz_rank(ci.cefr_level::text) - v_band) bdist,
             case when ci.skill::text = v_skill then 0 else 1 end sdist
      from content_items ci
      where ci.course_id = v_course and 'placement' = any(ci.tags) and not jz_is_stub(ci.type)
        and (p_exclude_skills is null or ci.skill::text <> all(p_exclude_skills))
        and ci.id not in (select item_id from _h)
      order by bdist asc, sdist asc, random()
      limit 1) x;
    if v_item is not null then
      return jsonb_build_object('done', false, 'asked', v_n, 'max', v_max_items, 'item', v_item);
    end if;
  end if;

  select array_agg(rnk order by ord), array_agg(correct order by ord) into v_ranks, v_correct from _h;
  v_overall := jz_placement_level(v_ranks, v_correct);

  -- POR HABILIDAD, con el rigor anti-azar del v2: el GLOBAL (guess-aware, pisos)
  -- es el ancla; una skill solo se DIFERENCIA hacia ABAJO con evidencia sostenida
  -- (>=3 ítems calificados de esa skill y precisión <=0.5 → global-1). NUNCA se
  -- promueve por skill (el azar no puede inflar ninguna). Sin evidencia (p.ej.
  -- speaking excluido, o curso sin banco L/S) → global (honesto, como hoy).
  for v_sk in select unnest(array['reading','listening','writing','speaking']) loop
    select count(*), count(*) filter (where correct) into v_sk_n, v_sk_c
    from _h where skill::text = v_sk;
    if v_sk_n >= 3 and v_sk_c::numeric / v_sk_n <= 0.5 then
      v_lvls := v_lvls || jsonb_build_object(v_sk, jz_cefr(greatest(v_overall - 1, 0)));
    else
      v_lvls := v_lvls || jsonb_build_object(v_sk, jz_cefr(v_overall));
    end if;
  end loop;

  return jsonb_build_object(
    'done', true, 'asked', v_n, 'level', jz_cefr(v_overall), 'skill_levels', v_lvls);
end $$;

grant execute on function placement_next(uuid, text, jsonb, text[]) to authenticated;
'''

if __name__ == '__main__':
    main()
