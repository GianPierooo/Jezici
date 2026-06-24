-- ============================================================================
-- Jezici · Migración 065 · Historias / Inmersión (input comprensible)
-- ----------------------------------------------------------------------------
-- "Sesión de inmersión" de Metodologia.md: diálogos/narrativas cortas curadas,
-- calibradas al CEFR, con audio por segmento (TTS en Storage) y preguntas de
-- comprensión auto-calificables. Viven en Practicar.
--
-- DISEÑO (aísla de loop core y respeta el grading seguro):
--  · Las preguntas NO son content_items → así NO se cuelan en los pools de
--    Practicar (start_practice selecciona cualquier content_item del curso/skill).
--    Viven embebidas en stories.questions, que se REVOCA al cliente (como
--    correct_answer en mig 055): el cliente nunca ve la respuesta. La calificación
--    es 100% server-side (submit_story → jz_grade), igual que grade_item.
--  · El cliente lee narrativa/segmentos por columnas públicas o por get_story; las
--    respuestas solo las toca el RPC DEFINER.
-- No toca loop core / seguridad mig 058 / ligas. Contenido DB-driven (live al aplicar).
-- ============================================================================
begin;

-- ── Tabla de historias ──────────────────────────────────────────────────────
create table if not exists stories (
  id           uuid primary key,
  course_id    uuid not null references courses(id) on delete cascade,
  cefr_level   cefr_level not null,
  order_index  int not null,
  title        text not null,
  subtitle     text,
  emoji        text,
  intro        text,
  est_seconds  int,
  segments     jsonb not null default '[]'::jsonb,   -- [{en, es, audio_url}]
  glossary     jsonb not null default '[]'::jsonb,   -- [{word, translation}]
  questions    jsonb not null default '[]'::jsonb,   -- [{type,skill,prompt,payload,correct_answer,difficulty}] (REVOCADO al cliente)
  created_at   timestamptz not null default now(),
  unique (course_id, cefr_level, order_index)
);
create index if not exists stories_course_idx on stories (course_id, cefr_level, order_index);

alter table stories enable row level security;
do $$ begin
  create policy stories_read on stories for select to anon, authenticated using (true);
exception when duplicate_object then null; end $$;

-- Igual que content_items (mig 055): se revoca TODO y se conceden solo las columnas
-- públicas — `questions` (con respuestas) queda fuera → el cliente no la puede leer.
revoke select on stories from anon, authenticated;
grant select (id, course_id, cefr_level, order_index, title, subtitle, emoji, intro,
              est_seconds, segments, glossary, created_at) on stories to anon, authenticated;

-- ── Progreso por usuario ────────────────────────────────────────────────────
create table if not exists user_story_progress (
  user_id      uuid not null references auth.users(id) on delete cascade,
  story_id     uuid not null references stories(id) on delete cascade,
  best_score   numeric not null default 0,
  times        int not null default 0,
  completed_at timestamptz,
  primary key (user_id, story_id)
);
alter table user_story_progress enable row level security;
do $$ begin
  create policy usp_self on user_story_progress for select to authenticated using (user_id = auth.uid());
exception when duplicate_object then null; end $$;
grant select on user_story_progress to authenticated;  -- escritura solo por RPC DEFINER

-- ── get_stories(): lista del curso activo (sin respuestas) ──────────────────
create or replace function get_stories()
returns jsonb language plpgsql security definer set search_path = public as $fn$
declare uid uuid := auth.uid(); v_course uuid;
begin
  if uid is null then raise exception 'auth required'; end if;
  v_course := jz_active_course();
  return coalesce((
    select jsonb_agg(jsonb_build_object(
        'id', s.id, 'cefr_level', s.cefr_level, 'order_index', s.order_index,
        'title', s.title, 'subtitle', s.subtitle, 'emoji', s.emoji,
        'est_seconds', s.est_seconds,
        'segment_count', jsonb_array_length(s.segments),
        'question_count', jsonb_array_length(s.questions),
        'completed', (p.completed_at is not null),
        'best_score', coalesce(p.best_score, 0))
      order by array_position(array['A1','A2','B1','B2','C1','C2']::text[], s.cefr_level::text), s.order_index)
    from stories s
    left join user_story_progress p on p.story_id = s.id and p.user_id = uid
    where s.course_id = v_course), '[]'::jsonb);
end $fn$;
grant execute on function get_stories() to authenticated;

-- ── get_story(id): narrativa + preguntas SIN respuesta ──────────────────────
create or replace function get_story(p_story_id uuid)
returns jsonb language plpgsql security definer set search_path = public as $fn$
declare uid uuid := auth.uid(); v_course uuid; s stories%rowtype; v_prog user_story_progress%rowtype;
begin
  if uid is null then raise exception 'auth required'; end if;
  v_course := jz_active_course();
  select * into s from stories where id = p_story_id and course_id = v_course;
  if not found then raise exception 'story not found'; end if;
  select * into v_prog from user_story_progress where user_id = uid and story_id = p_story_id;
  return jsonb_build_object(
    'id', s.id, 'cefr_level', s.cefr_level, 'order_index', s.order_index,
    'title', s.title, 'subtitle', s.subtitle, 'emoji', s.emoji, 'intro', s.intro,
    'est_seconds', s.est_seconds, 'segments', s.segments, 'glossary', s.glossary,
    'completed', (v_prog.completed_at is not null), 'best_score', coalesce(v_prog.best_score, 0),
    -- Preguntas SIN correct_answer (mismo principio que mig 055).
    'questions', coalesce((
      select jsonb_agg(jsonb_build_object(
          'i', (q.idx - 1), 'type', q.val->>'type', 'skill', q.val->>'skill',
          'prompt', q.val->>'prompt', 'payload', q.val->'payload',
          'difficulty', q.val->'difficulty')
        order by q.idx)
      from jsonb_array_elements(s.questions) with ordinality q(val, idx)), '[]'::jsonb));
end $fn$;
grant execute on function get_story(uuid) to authenticated;

-- ── submit_story(id, answers): califica server-side, XP en 1er completado ───
-- p_answers = [{"i": <indice 0-based>, "answer": <jsonb>}, ...]
create or replace function submit_story(p_story_id uuid, p_answers jsonb)
returns jsonb language plpgsql security definer set search_path = public as $fn$
declare
  uid uuid := auth.uid(); v_course uuid; s stories%rowtype;
  v_total int; v_correct int := 0; v_score numeric;
  v_per jsonb := '[]'::jsonb; v_first boolean := false; v_xp int := 0; v_gold int := 0;
  q record; v_ans jsonb; v_ok boolean; v_qtype content_item_type; v_qcorrect jsonb;
begin
  if uid is null then raise exception 'auth required'; end if;
  v_course := jz_active_course();
  select * into s from stories where id = p_story_id and course_id = v_course;
  if not found then raise exception 'story not found'; end if;
  v_total := jsonb_array_length(s.questions);

  for q in select (idx - 1) as i, val from jsonb_array_elements(s.questions) with ordinality x(val, idx) loop
    v_ans := null;
    select (a->'answer') into v_ans from jsonb_array_elements(p_answers) a where (a->>'i')::int = q.i limit 1;
    v_qtype := (q.val->>'type')::content_item_type;
    v_qcorrect := q.val->'correct_answer';
    v_ok := (v_ans is not null) and jz_grade(v_qtype, v_qcorrect, v_ans);
    if v_ok then v_correct := v_correct + 1; end if;
    v_per := v_per || jsonb_build_object('i', q.i, 'correct', v_ok, 'expected', v_qcorrect);
  end loop;

  v_score := case when v_total > 0 then round(v_correct::numeric / v_total, 2) else 0 end;

  -- Primer completado (times pasa de 0→1): premia con XP modesto (< que una lección).
  select (coalesce(times, 0) = 0) into v_first from user_story_progress where user_id = uid and story_id = p_story_id;
  v_first := coalesce(v_first, true);
  insert into user_story_progress (user_id, story_id, best_score, times, completed_at)
  values (uid, p_story_id, v_score, 1, now())
  on conflict (user_id, story_id) do update
    set best_score = greatest(user_story_progress.best_score, excluded.best_score),
        times = user_story_progress.times + 1, completed_at = now();

  if v_first then
    v_xp := 12; v_gold := 6;
    insert into user_stats (user_id) values (uid) on conflict (user_id) do nothing;
    update user_stats set xp_total = xp_total + v_xp, gold = gold + v_gold, updated_at = now() where user_id = uid;
    update user_course_progress set xp_total = xp_total + v_xp, updated_at = now() where user_id = uid and course_id = v_course;
    perform jz_register_activity(uid, v_course, v_xp);
  end if;

  return jsonb_build_object('score', v_score, 'correct', v_correct, 'total', v_total,
    'first_time', v_first, 'xp_earned', v_xp, 'gold_earned', v_gold, 'per_question', v_per);
end $fn$;
grant execute on function submit_story(uuid, jsonb) to authenticated;

commit;
