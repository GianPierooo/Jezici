# -*- coding: utf-8 -*-
"""ESTUDIAR · E-2 (INGLÉS) — genera la migración de la teoría de sesión.

Lee `_study_en/_clean.json` (ya pasado por guard_study_en.py + revisión
adversarial) y:
  1. genera el AUDIO TTS de cada frase-ejemplo en inglés y lo sube a Storage
     (`audio/study/<uuid5>.mp3`), reusando el pipeline determinista de la casa
     (Google translate_tts, audio PREGENERADO — cero IA en runtime);
  2. emite la migración SQL: tabla `study_theory` + RPCs `get_study_theory`
     (sin exponer respuestas) y `submit_study_quiz` (califica con jz_grade, el
     grader tolerante de mig 177) + los INSERT idempotentes.

NO toca: motor FSRS, economía, gating, certificación, ni los otros 5 idiomas.
uso: python gen_study_en.py [--no-audio]
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
NS = uuid.UUID('7b6f2c40-0000-4000-8000-000000000e02')  # namespace E-2
HERE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(HERE, '_study_en', '_clean.json')
OUT = os.path.normpath(os.path.join(
    HERE, '..', '..', 'supabase', 'migrations', '20260721120178_study_theory_en.sql'))


def tts(text):
    url = ('https://translate.google.com/translate_tts?ie=UTF-8&client=tw-ob&tl=en&q='
           + urllib.parse.quote(text))
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
            key = str(uuid.uuid5(NS, 'en:%d:%d' % (t['unit_order'], i)))
            ex['audio_url'] = ('%s/storage/v1/object/public/audio/study/%s.mp3'
                               % (SUPABASE_URL, key))
            if not do_audio:
                continue
            try:
                st = upload(key, tts(ex['en']))
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
            % (COURSE_EN, t['unit_order'], q(t['cefr_level']), q(t['title']), q(t['summary']),
               jq(t['sections']), jq(t['examples']), jq(t['pitfalls']), jq(t['quiz'])))

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
