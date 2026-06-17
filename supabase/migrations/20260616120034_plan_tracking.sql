-- ============================================================================
-- Jezici · Migración 034 · Seguimiento del plan (GA4 · B2, diferenciador)
-- ----------------------------------------------------------------------------
-- Dashboard del plan, TODO server-side y determinista:
--   · días transcurridos desde el inicio del plan
--   · días-activos cumplidos (metas diarias logradas) vs esperados → adelante/atrás
--   · progreso del plan (días cumplidos / días-activos totales del plan)
--   · proyección de fecha recalculada con el ritmo REAL del usuario
-- Y update_plan_pace: la palanca "llegar más rápido" (sube min/día y recalcula).
-- ============================================================================

-- Horas guía por nivel CEFR (espejo de estimation.dart).
create or replace function jz_cefr_hours(p_level text)
returns int language sql immutable as $$
  select case p_level
    when 'A1' then 95 when 'A2' then 190 when 'B1' then 375
    when 'B2' then 550 when 'C1' then 750 when 'C2' then 1100 else 95 end
$$;

create or replace function get_plan_tracking()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
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
  select id into v_course from courses where is_active order by created_at limit 1;

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
end $$;

-- Palanca "llegar más rápido": sube min/día, recalcula la fecha estimada y la
-- meta diaria de XP. Server-side (el cliente no decide la economía).
create or replace function update_plan_pace(p_daily_minutes int)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
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
  select id into v_course from courses where is_active order by created_at limit 1;

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
end $$;

grant execute on function get_plan_tracking() to authenticated;
grant execute on function update_plan_pace(int) to authenticated;
