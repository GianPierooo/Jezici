-- ============================================================================
-- Jezici · Migración 017 · create_plan (paso G — onboarding + "Tu plan")
-- ----------------------------------------------------------------------------
-- Al crear la cuenta persiste TODO lo del onboarding: personalidad (Matix),
-- plan (meta/ritmo/fecha estimada), progreso de curso y los 4 niveles de
-- habilidad de la ubicación. Reemplaza el start_course anónimo del paso E.
-- El contenido arranca en A1 (lo sembrado); el nivel de la ubicación se guarda
-- en user_plans + user_skill_levels aunque sea mayor (no rompe el árbol).
-- ============================================================================

create or replace function create_plan(
  p_coach_style text,
  p_intensity int,
  p_current_level text,
  p_goal_level text,
  p_daily_minutes int,
  p_days_per_week int,
  p_motive text,
  p_deadline date,
  p_estimated_hours int,
  p_estimated_completion date,
  p_skill_levels jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  v_course uuid;
  v_unit uuid;
  v_first_lesson uuid;
  s text;
  v_lvl text;
begin
  if uid is null then raise exception 'auth required'; end if;

  select id into v_course from courses where is_active order by created_at limit 1;
  if v_course is null then raise exception 'no active course'; end if;
  select id into v_unit from units where course_id = v_course order by order_index limit 1;
  select id into v_first_lesson from lessons where unit_id = v_unit and type = 'lesson'
   order by order_index limit 1;

  -- Personalidad (Matix).
  insert into user_personality (user_id, coach_style, intensity)
  values (uid, coalesce(p_coach_style, 'suave')::coach_style, coalesce(p_intensity, 2))
  on conflict (user_id) do update
    set coach_style = excluded.coach_style, intensity = excluded.intensity, updated_at = now();

  -- Progreso de curso: el contenido arranca en lo disponible (A1, 1ª lección).
  insert into user_course_progress (user_id, course_id, current_unit_id, current_lesson_id, xp_total)
  values (uid, v_course, v_unit, v_first_lesson, 0)
  on conflict (user_id, course_id) do update
    set current_unit_id = excluded.current_unit_id, updated_at = now();

  -- Las 4 habilidades al nivel de la ubicación (por skill si viene, si no el global).
  foreach s in array array['reading', 'listening', 'writing', 'speaking'] loop
    v_lvl := coalesce(p_skill_levels ->> s, p_current_level, 'A1');
    insert into user_skill_levels (user_id, course_id, skill, cefr_level, progress_points)
    values (uid, v_course, s::skill, v_lvl::cefr_level, 0)
    on conflict (user_id, course_id, skill) do update
      set cefr_level = excluded.cefr_level, updated_at = now();
  end loop;

  -- El plan con fecha estimada.
  insert into user_plans (user_id, course_id, current_level, goal_level, daily_minutes,
                          days_per_week, motive, deadline, estimated_hours, estimated_completion_date)
  values (uid, v_course, coalesce(p_current_level, 'A1')::cefr_level,
          coalesce(p_goal_level, 'B1')::cefr_level, p_daily_minutes, p_days_per_week,
          p_motive, p_deadline, p_estimated_hours, p_estimated_completion)
  on conflict (user_id, course_id) do update set
    current_level = excluded.current_level, goal_level = excluded.goal_level,
    daily_minutes = excluded.daily_minutes, days_per_week = excluded.days_per_week,
    motive = excluded.motive, deadline = excluded.deadline,
    estimated_hours = excluded.estimated_hours,
    estimated_completion_date = excluded.estimated_completion_date, updated_at = now();

  -- Primera lección disponible.
  if v_first_lesson is not null then
    insert into user_lesson_progress (user_id, lesson_id, status)
    values (uid, v_first_lesson, 'available')
    on conflict (user_id, lesson_id) do update
      set status = case when user_lesson_progress.status in ('completed', 'golden')
                        then user_lesson_progress.status else 'available' end;
  end if;

  return jsonb_build_object('ok', true, 'course_id', v_course,
                            'first_lesson_id', v_first_lesson, 'current_level', p_current_level);
end $$;

grant execute on function create_plan(text, int, text, text, int, int, text, date, int, date, jsonb)
  to authenticated;
