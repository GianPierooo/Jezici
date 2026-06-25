-- ============================================================================
-- Jezici · Migración 077 · PUENTE nivel→arranque (create_plan)
-- ----------------------------------------------------------------------------
-- PROBLEMA (falla B): aunque el placement diera B2, create_plan SIEMPRE colocaba al
-- usuario en la PRIMERA unidad / primer nodo (order_index), ignorando p_current_level.
-- El nivel se guardaba en user_plans/user_skill_levels pero NO se usaba para el
-- arranque del mapa → un B2 terminaba rehaciendo "buenos días" (A1, Unidad 1).
--
-- FIX: create_plan traduce p_current_level → UNIDAD DE ENTRADA (primera unidad de
-- ese nivel CEFR). El contenido por DEBAJO del nivel queda 'completed' (accesible y
-- rejugable, NO obliga a rehacerlo, sin XP falso) y el primer nodo de la unidad de
-- entrada queda 'available'. Punteros (current_unit/lesson) apuntan a la entrada.
--
-- SEGURO (verificado contra el modelo de avance): el mapa avanza por CADENA en
-- user_lesson_progress (complete_lesson desbloquea el siguiente por orden); el examen
-- de nivel es INDEPENDIENTE y se gatea por DOMINIO (jz_skill_mastery ≥0.80) sobre
-- user_item_attempts. Marcar lo inferior 'completed' NO regala dominio ni certificado
-- (no hay intentos) y el examen ofrecido = jz_resolve_exam_level = min skill level =
-- el nivel del placement. Idempotente. Backward-compatible: A1 ⇒ unidad de entrada =
-- primera unidad ⇒ comportamiento idéntico al actual (nada por debajo que completar).
-- Aditivo: no toca grading/seguridad/ligas.
-- ============================================================================
begin;

create or replace function create_plan(
  p_coach_style text, p_intensity int, p_current_level text, p_goal_level text,
  p_daily_minutes int, p_days_per_week int, p_motive text, p_deadline date,
  p_estimated_hours int, p_estimated_completion date, p_skill_levels jsonb)
returns jsonb language plpgsql security definer set search_path = public as $$
declare
  uid uuid := auth.uid();
  v_course uuid; v_unit uuid; v_unit_oi int; v_first uuid; s text; v_lvl text;
  v_level text; v_ranks text[] := array['A1','A2','B1','B2','C1','C2'];
  v_below int := 0;
begin
  if uid is null then raise exception 'auth required'; end if;
  insert into users (id, email) values (uid, (select email from auth.users where id = uid))
  on conflict (id) do nothing;

  select id into v_course from courses where is_active order by created_at limit 1;
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
end $$;
grant execute on function create_plan(text, int, text, text, int, int, text, date, int, date, jsonb) to authenticated;

commit;
