# -*- coding: utf-8 -*-
"""ESTUDIAR · E-2 — genera la migración de la teoría de sesión (inglés / portugués).

Lee `_study_en/_clean.json` (ya pasado por guard_study_en.py + revisión
adversarial) y:
  1. genera el AUDIO TTS de cada frase-ejemplo en inglés y lo sube a Storage
     (`audio/study/<uuid5>.mp3`), reusando el pipeline determinista de la casa
     (Google translate_tts, audio PREGENERADO — cero IA en runtime);
  2. emite la migración SQL: tabla `study_theory` + RPCs `get_study_theory`
     (sin exponer respuestas) y `submit_study_quiz` (califica con jz_grade, el
     grader tolerante de mig 177) + los INSERT idempotentes.

NO toca: motor FSRS, economía, gating, certificación, ni los otros 5 idiomas.
uso: python gen_study_en.py [--no-audio] [--batch2|--pt]
  --batch2 → lee _study_en2/_clean.json (B1+B2, unidades 13-24) y emite la mig
  179 SOLO-DATOS (la tabla y las RPCs ya viven desde mig 178; los upserts son
  idempotentes por (course_id, unit_order) → 0 riesgo para la tanda 1).
  --fr     → francés A1+A2 (mig 183), TTS tl=fr.
  --pt2    → igual que --pt pero emite la mig 181 (B1+B2, unidades 13-24).
  --pt     → lee _study_pt/_clean.json (A1+A2 de PORTUGUÉS, unidades 1-12), TTS
  con tl=pt y emite la mig 180 SOLO-DATOS. El inglés queda intacto (otro course_id).
"""
import json
import os
import sys
import urllib.error
import urllib.parse
import urllib.request
import uuid

from apply_sql import env, SUPABASE_URL

SERVICE = env('SUPABASE_SERVICE_ROLE_KEY') or env('SUPABASE_SERVICE_ROLE')
UA = 'Mozilla/5.0'
COURSE_EN = '20000000-0000-0000-0000-000000000001'
COURSE_PT = '20000000-0000-0000-0000-000000000002'
COURSE_FR = '20000000-0000-0000-0000-000000000003'
COURSE_DE = '20000000-0000-0000-0000-000000000005'
NS = uuid.UUID('7b6f2c40-0000-4000-8000-000000000e02')  # namespace E-2
HERE = os.path.dirname(os.path.abspath(__file__))
BATCH2 = '--batch2' in sys.argv
DE = '--de' in sys.argv or '--de2' in sys.argv
DE2 = '--de2' in sys.argv
FR = ('--fr' in sys.argv or '--fr2' in sys.argv) and not DE
FR2 = '--fr2' in sys.argv
PT = ('--pt' in sys.argv or '--pt2' in sys.argv) and not FR
PT2 = '--pt2' in sys.argv
LANG = 'de' if DE else 'fr' if FR else ('pt' if PT else 'en')            # clave del ejemplo + tl del TTS
COURSE = COURSE_DE if DE else COURSE_FR if FR else (COURSE_PT if PT else COURSE_EN)
DATA_ONLY = BATCH2 or PT or FR or DE               # la tabla y las RPCs viven desde mig 178
SRC = os.path.join(
    HERE, ('_study_de2' if DE2 else '_study_de') if DE else ('_study_fr2' if FR2 else '_study_fr') if FR else ('_study_pt' if PT else ('_study_en2' if BATCH2 else '_study_en')),
    '_clean.json')
MIG = ('20260721120186_study_theory_de_b1b2.sql' if DE2 else
       '20260721120185_study_theory_de.sql' if DE else
       '20260721120184_study_theory_fr_b1b2.sql' if FR2 else
       '20260721120183_study_theory_fr.sql' if FR else
       '20260721120181_study_theory_pt_b1b2.sql' if PT2 else
       '20260721120180_study_theory_pt.sql' if PT else
       '20260721120179_study_theory_en_b1b2.sql' if BATCH2 else
       '20260721120178_study_theory_en.sql')
OUT = os.path.normpath(os.path.join(HERE, '..', '..', 'supabase', 'migrations', MIG))


def tts(text):
    url = ('https://translate.google.com/translate_tts?ie=UTF-8&client=tw-ob&tl=%s&q='
           % LANG + urllib.parse.quote(text))
    req = urllib.request.Request(url)
    req.add_header('User-Agent', UA)
    req.add_header('Referer', 'https://translate.google.com/')
    with urllib.request.urlopen(req, timeout=60) as r:
        return r.read()


def upload(key, mp3):
    path = '/storage/v1/object/audio/study/%s.mp3' % key
    req = urllib.request.Request(SUPABASE_URL + path, data=mp3, method='POST')
    req.add_header('Authorization', 'Bearer ' + SERVICE)
    req.add_header('apikey', SERVICE)
    req.add_header('Content-Type', 'audio/mpeg')
    req.add_header('x-upsert', 'true')
    try:
        with urllib.request.urlopen(req, timeout=60) as r:
            return r.status
    except urllib.error.HTTPError as e:
        return '%s:%s' % (e.code, e.read().decode()[:120])


def q(s):
    return "'" + (s or '').replace("'", "''") + "'"


def jq(o):
    return "'" + json.dumps(o, ensure_ascii=False).replace("'", "''") + "'::jsonb"


def main():
    do_audio = '--no-audio' not in sys.argv
    topics = json.load(open(SRC, encoding='utf-8'))
    print('temas: %d' % len(topics))

    ok_audio = fail_audio = 0
    for t in topics:
        for i, ex in enumerate(t['examples']):
            key = str(uuid.uuid5(NS, '%s:%d:%d' % (LANG, t['unit_order'], i)))
            ex['text'] = ex[LANG]   # clave CANÓNICA del idioma meta (course-agnóstica)
            ex['audio_url'] = ('%s/storage/v1/object/public/audio/study/%s.mp3'
                               % (SUPABASE_URL, key))
            if not do_audio:
                continue
            try:
                st = upload(key, tts(ex[LANG]))
                if st == 200:
                    ok_audio += 1
                else:
                    fail_audio += 1
                    print('  audio FALLÓ u%d/%d -> %s' % (t['unit_order'], i, st))
            except Exception as e:
                fail_audio += 1
                print('  audio ERROR u%d/%d -> %s' % (t['unit_order'], i, e))
        # ids estables por ítem de quiz + forma canónica del grader
        for i, item in enumerate(t['quiz']):
            item['id'] = 'u%dq%d' % (t['unit_order'], i + 1)
    if do_audio:
        print('audio: %d subidos, %d fallos' % (ok_audio, fail_audio))

    if DE:
        sql = ["""-- ESTUDIAR · Fase E-2 (ALEMÁN) — A1+A2 (unidades 1-12), SOLO DATOS.
-- La tabla study_theory y las RPCs de mig 178 son course-agnósticas por
-- construcción (derivan el curso de la unidad) → en/pt/fr intactos.
-- Los ejemplos traen la clave canónica `text` (idioma meta). NO toca motor FSRS,
-- economía, gating, certificación ni los otros idiomas. Prueba FORMATIVA.
"""]
    elif FR:
        sql = ["""-- ESTUDIAR · Fase E-2 (FRANCÉS) — A1+A2 (unidades 1-12), SOLO DATOS.
-- La tabla study_theory y las RPCs de mig 178 son course-agnósticas por
-- construcción (derivan el curso de la unidad) → inglés y portugués intactos.
-- Los ejemplos traen la clave canónica `text` (idioma meta). NO toca motor FSRS,
-- economía, gating, certificación ni los otros idiomas. Prueba FORMATIVA.
"""]
    elif PT:
        sql = ["""-- ESTUDIAR · Fase E-2 (PORTUGUÉS) — A1+A2 (unidades 1-12), SOLO DATOS.
-- La tabla study_theory y las RPCs get_study_theory/submit_study_quiz ya viven
-- desde la mig 178 y son course-agnósticas POR CONSTRUCCIÓN: derivan el curso de
-- la propia unidad (v_unit.course_id), no de un idioma fijo. Aquí
-- solo se insertan los 12 temas de pt (upsert idempotente por (course_id,
-- unit_order) → el INGLÉS queda intacto, es otro course_id).
-- NO toca motor FSRS, economía, gating, certificación ni los otros 5 idiomas.
-- El quiz sigue siendo FORMATIVO (jz_grade, sin XP/oro).
"""]
    elif BATCH2:
        sql = ["""-- ESTUDIAR · Fase E-2 (INGLÉS) — tanda 2: B1+B2 (unidades 13-24), SOLO DATOS.
-- La tabla study_theory y las RPCs get_study_theory/submit_study_quiz ya viven
-- desde la mig 178 (tanda 1, A1+A2). Aquí solo se insertan los 12 temas B1+B2
-- (upsert idempotente por (course_id, unit_order) → la tanda 1 queda intacta).
-- SOLO inglés. NO toca motor FSRS, economía, gating, certificación ni los otros
-- 5 idiomas. El quiz sigue siendo FORMATIVO (jz_grade, sin XP/oro).
"""]
    else:
        sql = ["""-- ESTUDIAR · Fase E-2 (INGLÉS) — teoría de sesión + ejemplos con audio + prueba.
-- Llena el hueco que dejó E-1 en la estructura tab→nivel→tema→teoría. Contenido
-- autorado por profesores nativos + guardas deterministas + revisión adversarial.
-- SOLO inglés (course en). NO toca motor FSRS, economía, gating, certificación
-- ni los otros 5 idiomas. El quiz es FORMATIVO: califica con el grader tolerante
-- (jz_grade, mig 177) y NO paga XP/oro ni escribe user_item_attempts.

create table if not exists public.study_theory (
  id uuid primary key default gen_random_uuid(),
  course_id uuid not null references public.courses(id) on delete cascade,
  unit_order int not null,
  cefr_level text not null,
  title text not null,
  summary text not null,
  sections jsonb not null default '[]'::jsonb,
  examples jsonb not null default '[]'::jsonb,
  pitfalls jsonb not null default '[]'::jsonb,
  quiz jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (course_id, unit_order)
);

-- RLS ON sin política: el quiz lleva las respuestas → SOLO lo leen las funciones
-- SECURITY DEFINER de abajo (mismo patrón que lesson_vocab/stories.questions).
alter table public.study_theory enable row level security;
revoke all on public.study_theory from anon, authenticated;
"""]

    sql.append('\n-- ── Datos (idempotente por (course_id, unit_order)) ────────────────────────')
    for t in topics:
        sql.append(
            "insert into public.study_theory (course_id, unit_order, cefr_level, title, summary, sections, examples, pitfalls, quiz)\n"
            "values ('%s', %d, %s, %s, %s, %s, %s, %s, %s)\n"
            "on conflict (course_id, unit_order) do update set\n"
            "  cefr_level = excluded.cefr_level, title = excluded.title,\n"
            "  summary = excluded.summary, sections = excluded.sections,\n"
            "  examples = excluded.examples, pitfalls = excluded.pitfalls,\n"
            "  quiz = excluded.quiz, updated_at = now();"
            % (COURSE, t['unit_order'], q(t['cefr_level']), q(t['title']), q(t['summary']),
               jq(t['sections']), jq(t['examples']), jq(t['pitfalls']), jq(t['quiz'])))

    if not DATA_ONLY:
        sql.append(r"""
-- ── get_study_theory: la sesión de estudio de un tema, SIN las respuestas ────
create or replace function public.get_study_theory(p_unit_id uuid)
returns jsonb
language plpgsql
security definer
set search_path to 'public'
as $function$
declare uid uuid := auth.uid(); v_unit units%rowtype; v_row study_theory%rowtype;
begin
  if uid is null then raise exception 'auth required'; end if;
  select * into v_unit from units where id = p_unit_id;
  if v_unit.id is null then return null; end if;
  select * into v_row from study_theory
   where course_id = v_unit.course_id and unit_order = v_unit.order_index;
  if v_row.id is null then return null; end if;   -- aún sin teoría rica: E-1 decide
  return jsonb_build_object(
    'unit_order', v_row.unit_order,
    'cefr_level', v_row.cefr_level,
    'title', v_row.title,
    'summary', v_row.summary,
    'sections', v_row.sections,
    'examples', v_row.examples,
    'pitfalls', v_row.pitfalls,
    -- El quiz viaja SIN answer/accepted (el grading es server-side, como todo el
    -- resto del contenido: el cliente nunca ve la respuesta antes de responder).
    'quiz', coalesce((
      select jsonb_agg(jsonb_build_object(
               'id', it ->> 'id', 'type', it ->> 'type',
               'prompt', it ->> 'prompt', 'text', it ->> 'text',
               'options', it -> 'options') order by ord)
      from jsonb_array_elements(v_row.quiz) with ordinality as t(it, ord)), '[]'::jsonb));
end $function$;

-- ── submit_study_quiz: prueba FORMATIVA (sin economía ni dominio) ────────────
-- Califica con jz_grade — el MISMO grader tolerante del resto de la app, que
-- desde mig 177 acepta el conjunto `accepted` (sinónimos/variantes válidas).
-- NO da XP/oro, NO toca user_item_attempts → no altera economía ni certificación.
create or replace function public.submit_study_quiz(p_unit_id uuid, p_answers jsonb)
returns jsonb
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  uid uuid := auth.uid(); v_unit units%rowtype; v_row study_theory%rowtype;
  v_graded int := 0; v_correct int := 0; v_results jsonb := '[]'::jsonb;
  rec record; v_ok boolean; v_type content_item_type; v_corr jsonb;
begin
  if uid is null then raise exception 'auth required'; end if;
  select * into v_unit from units where id = p_unit_id;
  if v_unit.id is null then raise exception 'not found'; end if;
  select * into v_row from study_theory
   where course_id = v_unit.course_id and unit_order = v_unit.order_index;
  if v_row.id is null then raise exception 'not found'; end if;

  for rec in
    select it ->> 'id' as qid, it ->> 'type' as qtype,
           it ->> 'answer' as qans, coalesce(it -> 'accepted', '[]'::jsonb) as qacc,
           (select a -> 'answer' from jsonb_array_elements(p_answers) a
             where a ->> 'id' = it ->> 'id' limit 1) as given
      from jsonb_array_elements(v_row.quiz) it
  loop
    v_graded := v_graded + 1;
    v_type := rec.qtype::content_item_type;
    v_corr := jsonb_build_object('value', rec.qans, 'accepted', rec.qacc);
    v_ok := rec.given is not null and jz_grade(v_type, v_corr, rec.given);
    if v_ok then v_correct := v_correct + 1; end if;
    v_results := v_results || jsonb_build_object(
      'id', rec.qid, 'correct', coalesce(v_ok, false), 'expected', rec.qans);
  end loop;

  return jsonb_build_object(
    'graded', v_graded, 'correct', v_correct,
    'accuracy', case when v_graded > 0
                     then round(v_correct::numeric / v_graded, 2) else 0 end,
    'passed', v_graded > 0 and v_correct::numeric / v_graded >= 0.6,
    'results', v_results);
end $function$;
""")

    with open(OUT, 'w', encoding='utf-8') as f:
        f.write('\n'.join(sql) + '\n')
    print('migración escrita: %s' % OUT)
    print('ejemplos con audio: %d · ítems de quiz: %d'
          % (sum(len(t['examples']) for t in topics), sum(len(t['quiz']) for t in topics)))
    return 0


if __name__ == '__main__':
    sys.exit(main())
