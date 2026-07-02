-- 20260703120096_create_plan_active_course.sql
-- FIX multicurso: create_plan RESPETA el curso activo del usuario.
--
-- Antes: `select id into v_course from courses where is_active order by created_at
-- limit 1` → SIEMPRE elegía el curso más antiguo activo (es→en), IGNORANDO el curso
-- activo del usuario. En el flujo actual no afloraba (el onboarding corre create_plan
-- con curso=en por defecto y el cambio de curso usa start_course), pero con >1 curso
-- (pt/fr/it) create_plan sembraba el plan/progreso/entrada en el curso EQUIVOCADO.
--
-- Fix: resolver el curso con jz_active_course() (curso activo del usuario, con
-- fallback al más antiguo activo). Para un usuario NUEVO sin fila en
-- user_active_course, jz_active_course() = mismo curso más-antiguo-activo (es→en) →
-- CERO cambio de comportamiento en onboarding es→en. Para pt/fr/it activos, ahora
-- create_plan rutea correctamente al curso activo. Resto del cuerpo intacto (ya usa
-- v_course en todos lados). Verificado por verify_new_course.py (aislamiento 4 cursos).
begin;

create or replace function public.create_plan(p_coach_style text, p_intensity integer, p_current_level text, p_goal_level text, p_daily_minutes integer, p_days_per_week integer, p_motive text, p_deadline date, p_estimated_hours integer, p_estimated_completion date, p_skill_levels jsonb)
 returns jsonb
 language plpgsql
 security definer
 set search_path to 'public'
as $function$
declare
  uid uuid := auth.uid();
  v_course uuid; v_unit uuid; v_unit_oi int; v_first uuid; s text; v_lvl text;
  v_level text; v_ranks text[] := array['A1','A2','B1','B2','C1','C2'];
  v_below int := 0;
begin
  if uid is null then raise exception 'auth required'; end if;
  insert into users (id, email) values (uid, (select email from auth.users where id = uid))
  on conflict (id) do nothing;

  -- Curso ACTIVO del usuario (con fallback al más antiguo activo = es→en). Antes se
  -- ignoraba el curso activo → se sembraba siempre en es→en (bug multicurso).
  select jz_active_course() into v_course;
  if v_course is null then raise exception 'no active course'; end if;

  v_level := coalesce(p_current_level, 'A1');

  -- Unidad de ENTRADA = primera unidad (por orden) de ese nivel CEFR.
  select id, order_index into v_unit, v_unit_oi
  from units where course_id = v_course and cefr_level = v_level::cefr_level
  order by order_index limit 1;

  -- Si el curso no tiene ese nivel (p.ej. C1 en es→pt): mayor nivel disponible ≤ pedido.
  if v_unit is null then
    select id, order_index into v_unit, v_unit_oi
    from units where course_id = v_course
      and array_position(v_ranks, cefr_level::text) <= array_position(v_ranks, v_level)
    order by array_position(v_ranks, cefr_level::text) desc, order_index desc limit 1;
  end if;
  -- Último recurso: primera unidad del curso.
  if v_unit is null then
    select id, order_index into v_unit, v_unit_oi from units where course_id = v_course order by order_index limit 1;
  end if;

  -- Primer nodo (cualquier tipo) de la unidad de entrada.
  select id into v_first from lessons where unit_id = v_unit order by order_index limit 1;

  insert into user_personality (user_id, coach_style, intensity)
  values (uid, coalesce(p_coach_style, 'suave')::coach_style, coalesce(p_intensity, 2))
  on conflict (user_id) do update set coach_style = excluded.coach_style, intensity = excluded.intensity, updated_at = now();

  insert into user_course_progress (user_id, course_id, current_unit_id, current_lesson_id, xp_total)
  values (uid, v_course, v_unit, v_first, 0)
  on conflict (user_id, course_id) do update set
    current_unit_id = excluded.current_unit_id, current_lesson_id = excluded.current_lesson_id, updated_at = now();

  foreach s in array array['reading', 'listening', 'writing', 'speaking'] loop
    v_lvl := coalesce(p_skill_levels ->> s, p_current_level, 'A1');
    insert into user_skill_levels (user_id, course_id, skill, cefr_level, progress_points)
    values (uid, v_course, s::skill, v_lvl::cefr_level, 0)
    on conflict (user_id, course_id, skill) do update set cefr_level = excluded.cefr_level, updated_at = now();
  end loop;

  insert into user_plans (user_id, course_id, current_level, goal_level, daily_minutes,
                          days_per_week, motive, deadline, estimated_hours,
                          estimated_completion_date, onboarding_completed)
  values (uid, v_course, v_level::cefr_level, coalesce(p_goal_level, 'B1')::cefr_level,
          p_daily_minutes, p_days_per_week, p_motive, p_deadline, p_estimated_hours, p_estimated_completion, true)
  on conflict (user_id, course_id) do update set
    current_level = excluded.current_level, goal_level = excluded.goal_level,
    daily_minutes = excluded.daily_minutes, days_per_week = excluded.days_per_week,
    motive = excluded.motive, deadline = excluded.deadline, estimated_hours = excluded.estimated_hours,
    estimated_completion_date = excluded.estimated_completion_date, onboarding_completed = true, updated_at = now();

  -- PUENTE: marca COMPLETADAS las lecciones de unidades por DEBAJO de la entrada
  -- (accesibles/rejugables, sin XP). Nada por debajo si el nivel = A1 (entrada = U1).
  insert into user_lesson_progress (user_id, lesson_id, status, completed_at)
  select uid, l.id, 'completed'::lesson_progress_status, now()
  from lessons l join units u on u.id = l.unit_id
  where u.course_id = v_course and u.order_index < v_unit_oi
  on conflict (user_id, lesson_id) do update
    set status = case when user_lesson_progress.status in ('completed', 'golden')
                      then user_lesson_progress.status else 'completed' end;
  get diagnostics v_below = row_count;

  -- Nodo de ENTRADA disponible (sin degradar si ya estaba completado/golden).
  if v_first is not null then
    insert into user_lesson_progress (user_id, lesson_id, status) values (uid, v_first, 'available')
    on conflict (user_id, lesson_id) do update
      set status = case when user_lesson_progress.status in ('completed', 'golden') then user_lesson_progress.status else 'available' end;
  end if;

  return jsonb_build_object('ok', true, 'course_id', v_course, 'first_lesson_id', v_first,
    'current_level', v_level, 'entry_unit_order', v_unit_oi, 'lessons_skipped', v_below);
end $function$;

commit;
