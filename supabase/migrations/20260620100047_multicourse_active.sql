-- ============================================================================
-- Jezici · Migración 047 · Multi-curso (curso activo por usuario) — backward-compat
-- ----------------------------------------------------------------------------
-- Añade es→pt como curso paralelo sin romper es→en. jz_active_course() resuelve el
-- curso del usuario con FALLBACK al primer curso is_active (es→en). Convierte las
-- RPCs que resolvían el "único curso activo" para que respeten el curso del usuario.
-- Re-emisión automática de cuerpos vivos (pg_get_functiondef) con la línea resolver
-- intercambiada (ver tools/content/gen_multicourse_mig.py).
-- ============================================================================
begin;

-- Curso es → pt (português do Brasil). is_active=true; el fallback ordena por
-- created_at, así es→en (creado antes) sigue siendo el predeterminado.
insert into courses (id, source_language_id, target_language_id, is_active) values
  ('20000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000003', true)
on conflict (id) do nothing;

-- Curso activo por usuario (multi-curso).
create table if not exists user_active_course (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  course_id  uuid not null references courses(id) on delete cascade,
  updated_at timestamptz not null default now()
);
alter table user_active_course enable row level security;
do $pol$ begin
  create policy uac_self on user_active_course for all
    using (user_id = auth.uid()) with check (user_id = auth.uid());
exception when duplicate_object then null; end $pol$;

-- Resolver del curso activo: elección del usuario, o fallback al curso por defecto.
create or replace function jz_active_course() returns uuid
language sql stable security definer set search_path = public as $fn$
  select coalesce(
    (select course_id from user_active_course where user_id = auth.uid()),
    (select id from courses where is_active order by created_at limit 1)
  );
$fn$;
grant execute on function jz_active_course() to authenticated;

-- Cambia (y asegura inscripción en) el curso activo del usuario.
create or replace function set_active_course(p_course_id uuid) returns jsonb
language plpgsql security definer set search_path = public as $fn$
declare uid uuid := auth.uid();
begin
  if uid is null then raise exception 'auth required'; end if;
  if not exists (select 1 from courses where id = p_course_id and is_active) then
    raise exception 'course not found or inactive';
  end if;
  insert into user_active_course(user_id, course_id) values (uid, p_course_id)
    on conflict (user_id) do update set course_id = excluded.course_id, updated_at = now();
  perform start_course();  -- idempotente; usa jz_active_course() = p_course_id
  return jsonb_build_object('course_id', p_course_id);
end $fn$;
grant execute on function set_active_course(uuid) to authenticated;

-- Lista de cursos disponibles + cuál es el activo del usuario (para el selector).
create or replace function get_courses() returns jsonb
language sql stable security definer set search_path = public as $fn$
  select coalesce(jsonb_agg(jsonb_build_object(
    'id', c.id, 'source', sl.code, 'target', tl.code, 'target_name', tl.name,
    'active', c.id = jz_active_course()) order by c.created_at), '[]'::jsonb)
  from courses c
  join languages sl on sl.id = c.source_language_id
  join languages tl on tl.id = c.target_language_id
  where c.is_active;
$fn$;
grant execute on function get_courses() to authenticated;

-- convertida: create_plan (1x)
CREATE OR REPLACE FUNCTION public.create_plan(p_coach_style text, p_intensity integer, p_current_level text, p_goal_level text, p_daily_minutes integer, p_days_per_week integer, p_motive text, p_deadline date, p_estimated_hours integer, p_estimated_completion date, p_skill_levels jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  uid uuid := auth.uid();
  v_course uuid; v_unit uuid; v_first uuid; s text; v_lvl text;
begin
  if uid is null then raise exception 'auth required'; end if;
  insert into users (id, email) values (uid, (select email from auth.users where id = uid))
  on conflict (id) do nothing;

  select jz_active_course() into v_course;
  if v_course is null then raise exception 'no active course'; end if;
  select id into v_unit from units where course_id = v_course order by order_index limit 1;
  -- PRIMER nodo por orden (la misión), no el primer 'lesson'.
  select id into v_first from lessons where unit_id = v_unit order by order_index limit 1;

  insert into user_personality (user_id, coach_style, intensity)
  values (uid, coalesce(p_coach_style, 'suave')::coach_style, coalesce(p_intensity, 2))
  on conflict (user_id) do update set coach_style = excluded.coach_style, intensity = excluded.intensity, updated_at = now();

  insert into user_course_progress (user_id, course_id, current_unit_id, current_lesson_id, xp_total)
  values (uid, v_course, v_unit, v_first, 0)
  on conflict (user_id, course_id) do update set current_unit_id = excluded.current_unit_id, updated_at = now();

  foreach s in array array['reading', 'listening', 'writing', 'speaking'] loop
    v_lvl := coalesce(p_skill_levels ->> s, p_current_level, 'A1');
    insert into user_skill_levels (user_id, course_id, skill, cefr_level, progress_points)
    values (uid, v_course, s::skill, v_lvl::cefr_level, 0)
    on conflict (user_id, course_id, skill) do update set cefr_level = excluded.cefr_level, updated_at = now();
  end loop;

  insert into user_plans (user_id, course_id, current_level, goal_level, daily_minutes,
                          days_per_week, motive, deadline, estimated_hours,
                          estimated_completion_date, onboarding_completed)
  values (uid, v_course, coalesce(p_current_level, 'A1')::cefr_level, coalesce(p_goal_level, 'B1')::cefr_level,
          p_daily_minutes, p_days_per_week, p_motive, p_deadline, p_estimated_hours, p_estimated_completion, true)
  on conflict (user_id, course_id) do update set
    current_level = excluded.current_level, goal_level = excluded.goal_level,
    daily_minutes = excluded.daily_minutes, days_per_week = excluded.days_per_week,
    motive = excluded.motive, deadline = excluded.deadline, estimated_hours = excluded.estimated_hours,
    estimated_completion_date = excluded.estimated_completion_date, onboarding_completed = true, updated_at = now();

  if v_first is not null then
    insert into user_lesson_progress (user_id, lesson_id, status) values (uid, v_first, 'available')
    on conflict (user_id, lesson_id) do update
      set status = case when user_lesson_progress.status in ('completed', 'golden') then user_lesson_progress.status else 'available' end;
  end if;

  return jsonb_build_object('ok', true, 'course_id', v_course, 'first_lesson_id', v_first, 'current_level', p_current_level);
end $function$
;

-- convertida: evaluate_achievements (1x)
CREATE OR REPLACE FUNCTION public.evaluate_achievements()
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  uid uuid := auth.uid();
  v_course uuid;
  v_completed int; v_golden int; v_streak int; v_xp int;
  v_units int[]; v_four_a2 boolean; v_srs int; v_cert_a1 boolean;
  v_new jsonb;
begin
  if uid is null then raise exception 'auth required'; end if;
  select jz_active_course() into v_course;

  select count(*) filter (where status in ('completed','golden')),
         count(*) filter (where status = 'golden')
    into v_completed, v_golden
  from user_lesson_progress where user_id = uid;

  select coalesce(longest_streak, 0) into v_streak from streaks where user_id = uid;
  select coalesce(xp_total, 0) into v_xp from user_stats where user_id = uid;

  select coalesce(array_agg(u.order_index), '{}') into v_units
  from user_lesson_progress ulp
  join lessons l on l.id = ulp.lesson_id
  join units u on u.id = l.unit_id
  where ulp.user_id = uid and l.type = 'checkpoint' and ulp.status in ('completed','golden');

  select (count(*) filter (where array_position(array['A1','A2','B1','B2','C1','C2']::text[], cefr_level::text) >= 2) >= 4)
    into v_four_a2
  from user_skill_levels where user_id = uid and course_id = v_course;

  select count(*) into v_srs from user_vocab_srs where user_id = uid and strength >= 2;
  select exists(select 1 from certificates where user_id = uid and cefr_level = 'A1') into v_cert_a1;

  create temp table _ach on commit drop as
  select * from (values
    ('primeros_pasos', v_completed >= 1),
    ('impecable',      v_golden >= 1),
    ('constante',      v_streak >= 7),
    ('imparable',      v_streak >= 30),
    ('centurion',      v_xp >= 100),
    ('maratonista',    v_xp >= 500),
    ('fundamentos',    1 = any(v_units)),
    ('medio_camino',   3 = any(v_units)),
    ('a1_completo',    6 = any(v_units)),
    ('equilibrado',    coalesce(v_four_a2, false)),
    ('vocabulista',    v_srs >= 20),
    ('certificado_a1', coalesce(v_cert_a1, false))
  ) as t(code, met);

  with ins as (
    insert into user_achievements (user_id, achievement_id)
    select uid, a.id from _ach x join achievements a on a.code = x.code
    where x.met
    on conflict (user_id, achievement_id) do nothing
    returning achievement_id
  )
  select coalesce(jsonb_agg(jsonb_build_object('code', a.code, 'name', a.name, 'icon', a.criteria->>'icon')), '[]'::jsonb)
    into v_new
  from ins join achievements a on a.id = ins.achievement_id;

  return jsonb_build_object('newly_unlocked', v_new);
end $function$
;

-- convertida: get_plan_tracking (1x)
CREATE OR REPLACE FUNCTION public.get_plan_tracking()
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  uid uuid := auth.uid();
  v_course uuid;
  p record;
  v_start date;
  v_elapsed int;
  v_goal_met int;
  v_studied int;
  v_hours_needed numeric;
  v_hours_week numeric;
  v_weeks_total int;
  v_total_active int;
  v_expected_to_date int;
  v_ahead int;
  v_progress numeric;
  v_pace numeric;
  v_remaining int;
  v_projected date;
begin
  if uid is null then raise exception 'auth required'; end if;
  select jz_active_course() into v_course;

  select current_level, goal_level, daily_minutes, days_per_week, motive,
         deadline, estimated_completion_date, created_at::date as start_date
    into p
  from user_plans where user_id = uid and course_id = v_course;
  if p is null then return jsonb_build_object('ok', false); end if;

  v_start := p.start_date;
  v_elapsed := greatest(0, current_date - v_start);

  select count(*) filter (where xp_earned >= goal_xp), count(*)
    into v_goal_met, v_studied
  from daily_goals where user_id = uid;

  v_hours_needed := greatest(1, jz_cefr_hours(p.goal_level::text) - jz_cefr_hours(p.current_level::text));
  v_hours_week := greatest(0.1, (coalesce(p.daily_minutes, 10) * coalesce(p.days_per_week, 5)) / 60.0);
  v_weeks_total := ceil(v_hours_needed / v_hours_week);
  v_total_active := greatest(1, v_weeks_total * coalesce(p.days_per_week, 5));
  v_expected_to_date := round(v_elapsed * coalesce(p.days_per_week, 5) / 7.0);
  v_ahead := v_goal_met - v_expected_to_date;
  v_progress := least(1.0, v_goal_met::numeric / v_total_active);

  -- Proyección con el ritmo real (días-activos por día calendario).
  v_pace := case when v_elapsed > 0 then v_goal_met::numeric / v_elapsed else null end;
  v_remaining := greatest(0, v_total_active - v_goal_met);
  v_projected := case
    when v_remaining = 0 then current_date
    when v_pace is not null and v_pace > 0 then current_date + ceil(v_remaining / v_pace)::int
    else p.estimated_completion_date end;

  return jsonb_build_object(
    'ok', true,
    'current_level', p.current_level,
    'goal_level', p.goal_level,
    'motive', p.motive,
    'daily_minutes', p.daily_minutes,
    'days_per_week', p.days_per_week,
    'deadline', p.deadline,
    'plan_start', v_start,
    'days_elapsed', v_elapsed,
    'goal_met_days', v_goal_met,
    'studied_days', v_studied,
    'expected_days', v_expected_to_date,
    'ahead_behind', v_ahead,
    'total_active_days', v_total_active,
    'weeks_total', v_weeks_total,
    'progress', round(v_progress, 3),
    'estimated_completion', p.estimated_completion_date,
    'projected_completion', v_projected,
    'on_track', (v_ahead >= 0));
end $function$
;

-- convertida: get_skill_mastery (1x)
CREATE OR REPLACE FUNCTION public.get_skill_mastery()
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare uid uuid := auth.uid(); v_course uuid; v_level text; v_skills jsonb;
begin
  if uid is null then raise exception 'auth required'; end if;
  select jz_active_course() into v_course;
  insert into user_skill_levels (user_id, course_id, skill, cefr_level, progress_points)
  select uid, v_course, s::skill, 'A1', 0 from unnest(array['reading','listening','writing','speaking']) s
  on conflict (user_id, course_id, skill) do nothing;
  v_level := jz_resolve_exam_level(uid, v_course);

  select jsonb_agg(jsonb_build_object(
           'skill', usl.skill,
           'certified_level', usl.cefr_level,    -- nivel mostrado (compat)
           'working_level', usl.cefr_level,       -- el dominio se mide a SU nivel
           'mastery_pct', jz_skill_mastery(uid, v_course, usl.skill, usl.cefr_level),
           'reinforce_score', jz_reinforce_score(uid, v_course, usl.skill),
           'exam_ready', (jz_skill_mastery(uid, v_course, usl.skill, usl.cefr_level) >= 0.80))
         order by array_position(array['reading','listening','writing','speaking'], usl.skill::text))
    into v_skills
  from user_skill_levels usl where usl.user_id = uid and usl.course_id = v_course;

  return jsonb_build_object(
    'working_level', v_level,
    'exam', jz_level_status(uid, v_course, v_level),
    'skills', coalesce(v_skills, '[]'::jsonb));
end $function$
;

-- convertida: level_exam_status (1x)
CREATE OR REPLACE FUNCTION public.level_exam_status(p_level text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare uid uuid := auth.uid(); v_course uuid; v_level text;
begin
  if uid is null then raise exception 'auth required'; end if;
  select jz_active_course() into v_course;
  insert into user_skill_levels (user_id, course_id, skill, cefr_level, progress_points)
  select uid, v_course, s::skill, 'A1', 0 from unnest(array['reading','listening','writing','speaking']) s
  on conflict (user_id, course_id, skill) do nothing;
  v_level := coalesce(p_level, jz_resolve_exam_level(uid, v_course));
  return jz_level_status(uid, v_course, v_level);
end $function$
;

-- convertida: start_course (1x)
CREATE OR REPLACE FUNCTION public.start_course()
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  uid uuid := auth.uid(); v_course uuid; v_unit uuid; v_first uuid;
begin
  if uid is null then raise exception 'auth required'; end if;
  select jz_active_course() into v_course;
  if v_course is null then raise exception 'no active course'; end if;
  select id into v_unit from units where course_id = v_course order by order_index limit 1;
  select id into v_first from lessons where unit_id = v_unit order by order_index limit 1;

  insert into user_course_progress (user_id, course_id, current_unit_id, current_lesson_id, xp_total)
  values (uid, v_course, v_unit, v_first, 0) on conflict (user_id, course_id) do nothing;

  insert into user_skill_levels (user_id, course_id, skill, cefr_level, progress_points)
  select uid, v_course, s::skill, 'A1', 0 from unnest(array['reading', 'listening', 'writing', 'speaking']) s
  on conflict (user_id, course_id, skill) do nothing;

  if v_first is not null then
    insert into user_lesson_progress (user_id, lesson_id, status) values (uid, v_first, 'available')
    on conflict (user_id, lesson_id) do update
      set status = case when user_lesson_progress.status in ('completed', 'golden') then user_lesson_progress.status else 'available' end;
  end if;
  return jsonb_build_object('course_id', v_course, 'first_lesson_id', v_first);
end $function$
;

-- convertida: start_level_exam (1x)
CREATE OR REPLACE FUNCTION public.start_level_exam(p_level text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare uid uuid := auth.uid(); v_course uuid; v_level text; v_exam uuid; v_items jsonb;
begin
  if uid is null then raise exception 'auth required'; end if;
  select jz_active_course() into v_course;
  v_level := coalesce(p_level, jz_resolve_exam_level(uid, v_course));
  if not (jz_level_status(uid, v_course, v_level) ->> 'unlocked')::boolean then
    raise exception 'level exam locked';
  end if;
  v_exam := ('50000000-0000-0000-0000-0000000000' || lower(v_level))::uuid;
  insert into exams (id, course_id, type, cefr_level, time_limit_sec, pass_threshold, sections)
  values (v_exam, v_course, 'level', v_level::cefr_level, 600, 0.80,
          '{"skills":["reading","listening","writing","speaking"],"item_count":20}'::jsonb)
  on conflict (id) do nothing;

  with ranked as (
    select id, type, skill, cefr_level, prompt, payload,
           row_number() over (partition by skill order by random()) rn
    from content_items
    where course_id = v_course and cefr_level = v_level::cefr_level and not ('placement' = any(tags))
      and exists (select 1 from unnest(tags) t where t like 'unidad%')
  ), picked as (
    select * from ranked
    where (skill = 'reading' and rn <= 6) or (skill = 'writing' and rn <= 6)
       or (skill = 'listening' and rn <= 4) or (skill = 'speaking' and rn <= 4)
    order by random()
  )
  select jsonb_agg(jsonb_build_object('id', id, 'type', type, 'skill', skill,
           'cefr_level', cefr_level, 'prompt', prompt, 'payload', payload)) into v_items from picked;

  return jsonb_build_object('exam_id', v_exam, 'level', v_level, 'time_limit_sec', 600,
    'pass_threshold', 0.80, 'item_count', coalesce(jsonb_array_length(v_items), 0),
    'items', coalesce(v_items, '[]'::jsonb));
end $function$
;

-- convertida: start_practice (1x)
CREATE OR REPLACE FUNCTION public.start_practice(p_mode text, p_skill text DEFAULT NULL::text, p_unit uuid DEFAULT NULL::uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare uid uuid := auth.uid(); v_course uuid; v_weak skill; v_items jsonb; v_due int := 0;
begin
  if uid is null then raise exception 'auth required'; end if;
  select jz_active_course() into v_course;

  if p_mode = 'srs' then
    with due as (
      select v.id, v.word, v.translation, (s.vocab_id is null) as isnew, s.due_at
      from vocabulary v left join user_vocab_srs s on s.vocab_id = v.id and s.user_id = uid
      where v.course_id = v_course and (s.vocab_id is null or s.due_at is null or s.due_at <= now())
      order by (s.vocab_id is not null), coalesce(s.due_at, to_timestamp(0)), v.frequency_rank limit 12)
    select jsonb_agg(jsonb_build_object('id', d.id, 'type', 'multiple_choice', 'skill', 'reading', 'cefr_level', 'A1',
             'prompt', '¿Cómo se dice «' || d.translation || '»?', 'payload', jsonb_build_object('options', o.options),
             'correct_answer', jsonb_build_object('value', d.word))) into v_items
    from due d cross join lateral (select jsonb_agg(w order by random()) as options from
      ((select d.word as w) union all (select v2.word from vocabulary v2 where v2.course_id = v_course and v2.word <> d.word order by random() limit 3)) q) o;
    select count(*) into v_due from vocabulary v left join user_vocab_srs s on s.vocab_id = v.id and s.user_id = uid
      where v.course_id = v_course and (s.vocab_id is null or s.due_at is null or s.due_at <= now());

  elsif p_mode in ('reinforce', 'reinforce_unit') then
    -- Ítems calificables de MAYOR necesidad de refuerzo (intentados, no stub), del
    -- curso (y unidad/skill si se piden). Re-evalúa lo que más lo necesita.
    select jsonb_agg(jsonb_build_object('id', x.id, 'type', x.type, 'skill', x.skill, 'cefr_level', x.cefr_level,
             'prompt', x.prompt, 'payload', x.payload, 'correct_answer', x.correct_answer)) into v_items
    from (
      select ci.id, ci.type, ci.skill, ci.cefr_level, ci.prompt, ci.payload, ci.correct_answer,
             jz_item_reinforce(uid, ci.id) score
      from content_items ci join user_item_attempts ua on ua.item_id = ci.id and ua.user_id = uid
      where ci.course_id = v_course and not jz_is_stub(ci.type)
        and (p_skill is null or ci.skill = p_skill::skill)
        and (p_unit is null or exists (select 1 from lesson_items li join lessons l on l.id = li.lesson_id
                                       where li.item_id = ci.id and l.unit_id = p_unit))
      order by jz_item_reinforce(uid, ci.id) desc nulls last, random() limit 12) x;

  else
    if p_mode = 'weakness' then
      select s.skill::skill into v_weak from unnest(array['reading','listening','writing','speaking']) s(skill)
      order by jz_reinforce_score(uid, v_course, s.skill::skill) desc,
               array_position(array['reading','listening','writing','speaking'], s.skill) limit 1;
    end if;
    select jsonb_agg(jsonb_build_object('id', id, 'type', type, 'skill', skill, 'cefr_level', cefr_level,
             'prompt', prompt, 'payload', payload, 'correct_answer', correct_answer)) into v_items
    from (select id, type, skill, cefr_level, prompt, payload, correct_answer from content_items
          where course_id = v_course and not ('placement' = any(tags))
            and case when p_mode = 'weakness' then skill = v_weak
                     when p_mode = 'skill' then skill = p_skill::skill
                     when p_mode = 'timed' then type not in ('listening','speaking_read_aloud','dictation','guided_writing')
                     else true end
          order by random() limit case when p_mode = 'timed' then 20 else 10 end) x;
  end if;

  return jsonb_build_object('mode', p_mode, 'weakest_skill', v_weak, 'due_count', v_due,
    'item_count', coalesce(jsonb_array_length(v_items), 0), 'items', coalesce(v_items, '[]'::jsonb));
end $function$
;

-- convertida: submit_level_exam (1x)
CREATE OR REPLACE FUNCTION public.submit_level_exam(p_answers jsonb, p_time_taken_sec integer DEFAULT NULL::integer, p_level text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  uid uuid := auth.uid(); v_course uuid; v_level text; v_exam uuid;
  v_graded int; v_correct int; v_acc numeric; v_per_skill jsonb; v_weak jsonb;
  v_xp int := 0; v_gold int := 0; v_levels_rank text[] := array['A1','A2','B1','B2','C1','C2'];
  v_raised jsonb := '[]'::jsonb; v_any boolean := false; rec record;
  v_spk_total int; v_spk_ok int; v_pass boolean; v_min_after int; v_target_rank int;
  v_name text; v_folio text; v_code text; v_svg text; v_cert jsonb := null; v_existing certificates%rowtype;
begin
  if uid is null then raise exception 'auth required'; end if;
  select jz_active_course() into v_course;
  v_level := coalesce(p_level, jz_resolve_exam_level(uid, v_course));
  -- Compuerta server-side al enviar (no sólo en start): atajo RPC no puede saltarse el dominio.
  if not (jz_level_status(uid, v_course, v_level) ->> 'unlocked')::boolean
     and not exists (select 1 from certificates where user_id = uid and cefr_level = v_level::cefr_level) then
    raise exception 'level exam locked';
  end if;
  v_exam := ('50000000-0000-0000-0000-0000000000' || lower(v_level))::uuid;
  v_target_rank := array_position(v_levels_rank, v_level);

  insert into exams (id, course_id, type, cefr_level, time_limit_sec, pass_threshold, sections)
  values (v_exam, v_course, 'level', v_level::cefr_level, 600, 0.80,
          '{"skills":["reading","listening","writing","speaking"],"item_count":20}'::jsonb)
  on conflict (id) do nothing;

  create temp table _le on commit drop as
  select ci.id as item_id, ci.skill, jz_is_stub(ci.type) as is_stub,
         (a.elem -> 'answer') as ans,
         case when jz_is_stub(ci.type) then null
              else jz_grade(ci.type, ci.correct_answer, a.elem -> 'answer') end as correct
  from jsonb_array_elements(p_answers) as a(elem)
  join content_items ci on ci.id = (a.elem ->> 'item_id')::uuid;

  select count(*) filter (where not is_stub), count(*) filter (where correct) into v_graded, v_correct from _le;
  v_acc := case when v_graded > 0 then v_correct::numeric / v_graded else 0 end;

  select jsonb_agg(jsonb_build_object('skill', skill, 'total', total, 'graded', g, 'correct', c,
           'accuracy', case when g > 0 then round(c::numeric / g, 2) else null end) order by skill) into v_per_skill
  from (select skill, count(*) total, count(*) filter (where not is_stub) g, count(*) filter (where correct) c
        from _le group by skill) s;
  select coalesce(jsonb_agg(skill), '[]'::jsonb) into v_weak
  from (select skill, count(*) filter (where not is_stub) g, count(*) filter (where correct) c
        from _le group by skill) s where g > 0 and c::numeric / g < 0.80;

  -- Participación de speaking (verificable): ítems de speaking con answer no vacío.
  select count(*) filter (where skill='speaking'),
         count(*) filter (where skill='speaking' and ans is not null and length(btrim(coalesce(ans #>> '{}',''))) > 0)
    into v_spk_total, v_spk_ok from _le;

  insert into exam_attempts (user_id, exam_id, started_at, finished_at, score_global, per_skill_results, passed)
  values (uid, v_exam, now() - (coalesce(p_time_taken_sec, 0) || ' seconds')::interval, now(), v_acc, v_per_skill,
          v_correct::numeric >= 0); -- 'passed' a nivel agregado se mantiene informativo

  -- SUBIDA PER-SKILL: sólo skills EN este nivel, exam-ready (≥0.80) y cuya sección aprueba.
  for rec in
    select usl.skill, usl.cefr_level::text lvl from user_skill_levels usl
    where usl.user_id = uid and usl.course_id = v_course and usl.cefr_level = v_level::cefr_level
  loop
    if jz_skill_mastery(uid, v_course, rec.skill::skill, v_level::cefr_level) < 0.80 then continue; end if;
    if rec.skill = 'speaking' then
      v_pass := (v_spk_total > 0 and v_spk_ok = v_spk_total);  -- todos los de speaking respondidos no-vacío
    else
      select (count(*) filter (where not is_stub) > 0
              and count(*) filter (where correct)::numeric / nullif(count(*) filter (where not is_stub),0) >= 0.80)
        into v_pass from _le where skill = rec.skill::skill;
    end if;
    if coalesce(v_pass, false) then
      if v_target_rank < 6 then  -- tope C2: no incrementar más allá del enum
        update user_skill_levels set cefr_level = (v_levels_rank[v_target_rank + 1])::cefr_level, updated_at = now()
         where user_id = uid and course_id = v_course and skill = rec.skill::skill;
      end if;
      v_raised := v_raised || to_jsonb(rec.skill);
      v_any := true;
    end if;
  end loop;

  if v_any then
    v_xp := 200; v_gold := 100;
    insert into user_stats (user_id) values (uid) on conflict (user_id) do nothing;
    update user_stats set xp_total = xp_total + v_xp, gold = gold + v_gold, updated_at = now() where user_id = uid;
    update user_course_progress set xp_total = xp_total + v_xp, updated_at = now() where user_id = uid and course_id = v_course;
    insert into gold_transactions (user_id, amount, reason) values (uid, v_gold, 'challenge');
    perform jz_register_activity(uid, v_course, v_xp);
  end if;

  -- Certificado N cuando las 4 skills cruzan N (min cefr > N == todas pasaron N).
  select min(array_position(v_levels_rank, cefr_level::text)) into v_min_after
  from user_skill_levels where user_id = uid and course_id = v_course;
  if v_min_after > v_target_rank then  -- todas superaron v_level
    select * into v_existing from certificates where user_id = uid and cefr_level = v_level::cefr_level limit 1;
    if v_existing.id is null then
      select coalesce(nullif(display_name, ''), nullif(name, ''), 'Aprendiz') into v_name from users where id = uid;
      v_name := coalesce(v_name, 'Aprendiz');
      v_folio := 'JZC-' || v_level || '-' || to_char(now(), 'YYYYMMDD') || '-' || upper(left(md5(uid::text || now()::text), 5));
      v_code := upper(left(md5(uid::text || 'verify' || now()::text), 10));
      v_svg := jz_cert_svg(v_name, v_level, v_folio, v_code, to_char(now(), 'DD/MM/YYYY'));
      insert into certificates (user_id, course_id, cefr_level, folio, verification_code, pdf_url)
      values (uid, v_course, v_level::cefr_level, v_folio, v_code, v_svg)
      on conflict (user_id, cefr_level) do nothing
      returning * into v_existing;
      if v_existing.id is null then
        select * into v_existing from certificates where user_id = uid and cefr_level = v_level::cefr_level limit 1;
      end if;
    end if;
    if v_existing.id is not null then
      v_cert := jsonb_build_object('cefr_level', v_existing.cefr_level, 'folio', v_existing.folio,
        'verification_code', v_existing.verification_code, 'issued_at', v_existing.issued_at, 'svg', v_existing.pdf_url);
    end if;
  end if;

  return jsonb_build_object(
    'passed', v_any, 'level', v_level, 'score_global', v_acc, 'threshold', 0.80,
    'graded', v_graded, 'correct', v_correct, 'xp_earned', v_xp, 'gold_earned', v_gold,
    'leveled_up', v_any, 'new_level', case when v_any then v_level else null end,
    'raised_skills', v_raised,
    'per_skill', coalesce(v_per_skill, '[]'::jsonb), 'weaknesses', v_weak, 'certificate', v_cert);
end $function$
;

-- convertida: submit_practice (1x)
CREATE OR REPLACE FUNCTION public.submit_practice(p_mode text, p_answers jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  uid uuid := auth.uid(); v_course uuid; v_graded int := 0; v_correct int := 0; v_xp int := 0; v_gold int := 0;
  v_activity jsonb; rec record; v_word text; v_ok boolean; v_strength numeric; v_interval int;
begin
  if uid is null then raise exception 'auth required'; end if;
  select jz_active_course() into v_course;
  if p_mode = 'srs' then
    for rec in select (e ->> 'item_id')::uuid as vid, e -> 'answer' as ans from jsonb_array_elements(p_answers) e loop
      select word into v_word from vocabulary where id = rec.vid;
      if v_word is null then continue; end if;
      v_graded := v_graded + 1; v_ok := jz_normalize(rec.ans #>> '{}') = jz_normalize(v_word);
      if v_ok then v_correct := v_correct + 1; end if;
      select coalesce(strength, 0) into v_strength from user_vocab_srs where user_id = uid and vocab_id = rec.vid;
      if v_ok then v_strength := least(coalesce(v_strength, 0) + 1, 5); else v_strength := 0; end if;
      v_interval := case v_strength::int when 0 then 1 when 1 then 2 when 2 then 4 when 3 then 8 when 4 then 16 else 30 end;
      insert into user_vocab_srs (user_id, vocab_id, strength, interval_days, due_at, last_reviewed_at)
      values (uid, rec.vid, v_strength, v_interval, now() + (v_interval || ' days')::interval, now())
      on conflict (user_id, vocab_id) do update set strength = excluded.strength, interval_days = excluded.interval_days,
        due_at = excluded.due_at, last_reviewed_at = now(), updated_at = now();
    end loop;
  else
    create temp table _pg on commit drop as
    select ci.id as item_id, jz_is_stub(ci.type) as is_stub,
           case when jz_is_stub(ci.type) then null else jz_grade(ci.type, ci.correct_answer, e.elem -> 'answer') end as correct
    from jsonb_array_elements(p_answers) as e(elem) join content_items ci on ci.id = (e.elem ->> 'item_id')::uuid;
    select count(*) filter (where not is_stub), count(*) filter (where correct) into v_graded, v_correct from _pg;
    for rec in select item_id, is_stub, correct from _pg loop
      perform jz_record_item(uid, rec.item_id, case when rec.is_stub then true else coalesce(rec.correct, false) end);
    end loop;
  end if;
  v_xp := least(v_correct * 3, 20); v_gold := case when v_correct > 0 then 2 else 0 end;
  insert into user_stats (user_id) values (uid) on conflict (user_id) do nothing;
  update user_stats set xp_total = xp_total + v_xp, gold = gold + v_gold, updated_at = now() where user_id = uid;
  update user_course_progress set xp_total = xp_total + v_xp, updated_at = now() where user_id = uid and course_id = v_course;
  if v_gold > 0 then insert into gold_transactions (user_id, amount, reason) values (uid, v_gold, 'challenge'); end if;
  v_activity := jz_register_activity(uid, v_course, v_xp);
  return jsonb_build_object('mode', p_mode, 'graded', v_graded, 'correct', v_correct,
    'accuracy', case when v_graded > 0 then round(v_correct::numeric / v_graded, 2) else 0 end,
    'xp_earned', v_xp, 'gold_earned', v_gold, 'streak', (v_activity ->> 'streak')::int,
    'streak_advanced', (v_activity ->> 'streak_advanced')::boolean, 'goal_met', (v_activity ->> 'goal_met')::boolean);
end $function$
;

-- convertida: update_plan_pace (1x)
CREATE OR REPLACE FUNCTION public.update_plan_pace(p_daily_minutes integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  uid uuid := auth.uid();
  v_course uuid;
  p record;
  v_hours_needed numeric;
  v_weeks int;
  v_new_date date;
  v_goal_xp int;
begin
  if uid is null then raise exception 'auth required'; end if;
  if p_daily_minutes is null or p_daily_minutes < 5 then raise exception 'invalid minutes'; end if;
  select jz_active_course() into v_course;

  select current_level, goal_level, days_per_week into p
  from user_plans where user_id = uid and course_id = v_course;
  if p is null then raise exception 'no plan'; end if;

  v_hours_needed := greatest(1, jz_cefr_hours(p.goal_level::text) - jz_cefr_hours(p.current_level::text));
  v_weeks := ceil(v_hours_needed / greatest(0.1, (p_daily_minutes * coalesce(p.days_per_week, 5)) / 60.0));
  v_new_date := current_date + (v_weeks * 7);

  update user_plans
    set daily_minutes = p_daily_minutes,
        estimated_completion_date = v_new_date,
        estimated_hours = round(v_hours_needed),
        updated_at = now()
  where user_id = uid and course_id = v_course;

  -- Meta diaria de XP escala con los minutos (≈ 2 XP/min, mínimo 20).
  v_goal_xp := greatest(20, p_daily_minutes * 2);
  insert into daily_goals (user_id, goal_date, goal_xp, xp_earned)
  values (uid, current_date, v_goal_xp, 0)
  on conflict (user_id, goal_date) do update set goal_xp = excluded.goal_xp, updated_at = now();

  return jsonb_build_object('ok', true, 'daily_minutes', p_daily_minutes,
    'estimated_completion', v_new_date, 'weeks', v_weeks, 'goal_xp', v_goal_xp);
end $function$
;

-- convertida: update_settings (1x)
CREATE OR REPLACE FUNCTION public.update_settings(p_coach_style text DEFAULT NULL::text, p_intensity integer DEFAULT NULL::integer, p_quiet_start time without time zone DEFAULT NULL::time without time zone, p_quiet_end time without time zone DEFAULT NULL::time without time zone, p_daily_minutes integer DEFAULT NULL::integer, p_push_enabled boolean DEFAULT NULL::boolean)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  uid uuid := auth.uid();
  v_course uuid;
begin
  if uid is null then raise exception 'auth required'; end if;

  insert into user_personality (user_id, coach_style, intensity,
                                quiet_hours_start, quiet_hours_end, push_enabled)
  values (uid, coalesce(p_coach_style, 'suave')::coach_style, coalesce(p_intensity, 2),
          p_quiet_start, p_quiet_end, coalesce(p_push_enabled, true))
  on conflict (user_id) do update set
    coach_style       = coalesce(p_coach_style::coach_style, user_personality.coach_style),
    intensity         = coalesce(p_intensity, user_personality.intensity),
    quiet_hours_start = p_quiet_start,
    quiet_hours_end   = p_quiet_end,
    push_enabled      = coalesce(p_push_enabled, user_personality.push_enabled),
    updated_at        = now();

  if p_daily_minutes is not null then
    select jz_active_course() into v_course;
    update user_plans set daily_minutes = p_daily_minutes, updated_at = now()
     where user_id = uid and course_id = v_course;
  end if;

  return jsonb_build_object('ok', true);
end $function$
;

commit;
