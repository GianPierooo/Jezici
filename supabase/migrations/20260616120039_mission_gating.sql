-- ============================================================================
-- Jezici · Migración 039 · Gating del nodo MISIÓN (GA9·A2)
-- ----------------------------------------------------------------------------
-- Bug: "Misión: 100 esenciales" (order_index 0, type mission, 0 ítems) salía
-- BLOQUEADA al fondo del mapa porque create_plan/start_course sólo marcaban
-- disponible el primer type='lesson' (order_index 1), saltándose la misión.
-- Fix: marcar disponible el PRIMER nodo por order_index (la misión). + RPC
-- complete_mission para "empezar el viaje" (marca completado + desbloquea el
-- siguiente nodo, sin XP/racha).
-- ============================================================================
begin;

-- ── create_plan: primer NODO (cualquier tipo) disponible ─────────────────────
create or replace function create_plan(
  p_coach_style text, p_intensity int, p_current_level text, p_goal_level text,
  p_daily_minutes int, p_days_per_week int, p_motive text, p_deadline date,
  p_estimated_hours int, p_estimated_completion date, p_skill_levels jsonb)
returns jsonb language plpgsql security definer set search_path = public as $$
declare
  uid uuid := auth.uid();
  v_course uuid; v_unit uuid; v_first uuid; s text; v_lvl text;
begin
  if uid is null then raise exception 'auth required'; end if;
  insert into users (id, email) values (uid, (select email from auth.users where id = uid))
  on conflict (id) do nothing;

  select id into v_course from courses where is_active order by created_at limit 1;
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
end $$;
grant execute on function create_plan(text, int, text, text, int, int, text, date, int, date, jsonb) to authenticated;

-- ── start_course: idem (primer NODO por orden disponible) ────────────────────
create or replace function start_course()
returns jsonb language plpgsql security definer set search_path = public as $$
declare
  uid uuid := auth.uid(); v_course uuid; v_unit uuid; v_first uuid;
begin
  if uid is null then raise exception 'auth required'; end if;
  select id into v_course from courses where is_active order by created_at limit 1;
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
end $$;
grant execute on function start_course() to authenticated;

-- ── complete_mission: "empezar el viaje" → completa el nodo + desbloquea sig. ─
create or replace function complete_mission(p_lesson_id uuid)
returns jsonb language plpgsql security definer set search_path = public as $$
declare
  uid uuid := auth.uid(); v_course uuid; v_unit uuid; v_order int; v_next uuid;
begin
  if uid is null then raise exception 'auth required'; end if;
  select u.course_id, l.unit_id, l.order_index into v_course, v_unit, v_order
  from lessons l join units u on u.id = l.unit_id where l.id = p_lesson_id;
  if v_course is null then raise exception 'lesson not found'; end if;

  insert into user_lesson_progress (user_id, lesson_id, status, completed_at)
  values (uid, p_lesson_id, 'completed', now())
  on conflict (user_id, lesson_id) do update
    set status = case when user_lesson_progress.status in ('completed', 'golden') then user_lesson_progress.status else 'completed' end,
        completed_at = now();

  select id into v_next from lessons where unit_id = v_unit and order_index > v_order order by order_index limit 1;
  if v_next is null then
    select l.id into v_next from lessons l join units u on u.id = l.unit_id
     where u.course_id = v_course and u.order_index > (select order_index from units where id = v_unit)
     order by u.order_index, l.order_index limit 1;
  end if;
  if v_next is not null then
    insert into user_lesson_progress (user_id, lesson_id, status) values (uid, v_next, 'available')
    on conflict (user_id, lesson_id) do update
      set status = case when user_lesson_progress.status in ('completed', 'golden') then user_lesson_progress.status else 'available' end;
    update user_course_progress set current_lesson_id = v_next where user_id = uid and course_id = v_course;
  end if;
  return jsonb_build_object('ok', true, 'next_lesson_id', v_next);
end $$;
grant execute on function complete_mission(uuid) to authenticated;

commit;
