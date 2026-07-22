-- ERRORES TIPADOS · 4a PASADA — las RPC de PLAN y LECCION emiten SQLSTATE custom.
-- Patron de mig 167 (claim_handle) y 175 (sociales): cuerpo VERBATIM de la
-- definicion viva; el UNICO cambio es `raise exception '<texto>'` -> `perform
-- jz_err('<texto>', '<kind>')`.
-- COMPATIBILIDAD TOTAL: el MENSAJE sigue siendo el MISMO texto de siempre
-- ('auth required', 'lesson not found', 'no active course'), asi que el fallback
-- por texto del cliente sigue valido; lo que se gana es el CODIGO (JZ401/JZ404),
-- que el cliente ya mapea a kind y que resiste una reescritura del texto.
-- NO toca la logica, la economia, el scoring, el gating ni la certificacion.

-- grade_item: 1 raise -> jz_err
CREATE OR REPLACE FUNCTION public.grade_item(p_item_id uuid, p_answer jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare uid uuid := auth.uid(); v_type content_item_type; v_correct jsonb; v_word text; v_exact boolean; v_near boolean;
begin
  if uid is null then perform jz_err('auth required', 'auth'); end if;
  select type, correct_answer into v_type, v_correct from content_items where id = p_item_id;
  if found then
    v_exact := jz_grade_exact(v_type, v_correct, p_answer);
    v_near := (not v_exact) and jz_near_match(v_type, v_correct, p_answer);
    return jsonb_build_object('correct', v_exact or v_near, 'near', v_near,
      'graded', not jz_is_stub(v_type), 'expected', v_correct);
  end if;
  -- Fallback: ítem sintético de SRS (el id es de vocabulary).
  select word into v_word from vocabulary where id = p_item_id;
  if found then
    return jsonb_build_object('correct', jz_normalize(p_answer #>> '{}') = jz_normalize(v_word),
      'near', false, 'graded', true, 'expected', jsonb_build_object('value', v_word));
  end if;
  return jsonb_build_object('correct', false, 'near', false, 'graded', false, 'expected', null);
end $function$
;

-- buy_hearts: 1 raise -> jz_err
CREATE OR REPLACE FUNCTION public.buy_hearts()
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare uid uuid := auth.uid(); v_gold int; v_cost int; v_max int;
begin
  if uid is null then perform jz_err('auth required', 'auth'); end if;
  v_cost := jz_cfg('heart_refill_cost', 50);
  v_max := jz_cfg('hearts_max', 5);
  select gold into v_gold from user_stats where user_id = uid for update;
  if coalesce(v_gold,0) < v_cost then
    return jsonb_build_object('ok', false, 'reason', 'insufficient_gold', 'gold', coalesce(v_gold,0));
  end if;
  update user_stats set gold = gold - v_cost, hearts = v_max, hearts_updated_at = now(), updated_at = now()
   where user_id = uid returning gold into v_gold;
  insert into gold_transactions (user_id, amount, reason) values (uid, -v_cost, 'heart_refill');
  return jsonb_build_object('ok', true, 'gold', v_gold, 'hearts', v_max);
end $function$
;

-- revive_streak: 1 raise -> jz_err
CREATE OR REPLACE FUNCTION public.revive_streak()
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare uid uuid := auth.uid(); v streaks%rowtype; v_cost int; v_win int; v_cap int; v_min int;
        v_gold int; v_new int;
begin
  if uid is null then perform jz_err('auth required', 'auth'); end if;
  v_cost := jz_cfg('revive_cost', 300);
  v_win := jz_cfg('revive_window_days', 7);
  v_cap := jz_cfg('revive_cap_days', 30);
  v_min := jz_cfg('revive_min_streak', 3);
  select * into v from streaks where user_id = uid for update;
  if coalesce(v.lost_streak, 0) < v_min or v.lost_at is null then
    return jsonb_build_object('ok', false, 'reason', 'nothing_to_revive');
  end if;
  if v.lost_at <= now() - (v_win || ' days')::interval then
    return jsonb_build_object('ok', false, 'reason', 'expired');
  end if;
  if exists (select 1 from gold_transactions
             where user_id = uid and reason = 'streak_revive'
               and created_at > now() - (v_cap || ' days')::interval) then
    return jsonb_build_object('ok', false, 'reason', 'limit_reached');
  end if;
  select gold into v_gold from user_stats where user_id = uid for update;
  if coalesce(v_gold, 0) < v_cost then
    return jsonb_build_object('ok', false, 'reason', 'insufficient_gold',
                              'gold', coalesce(v_gold, 0), 'cost', v_cost);
  end if;
  update user_stats set gold = gold - v_cost, updated_at = now()
   where user_id = uid returning gold into v_gold;
  insert into gold_transactions (user_id, amount, reason) values (uid, -v_cost, 'streak_revive');
  -- La racha revivida SE SUMA a la racha actual (los días de la nueva corrida
  -- tras la pérdida cuentan) y se limpia el registro de pérdida.
  v_new := coalesce(v.current_streak, 0) + v.lost_streak;
  update streaks set current_streak = v_new,
                     longest_streak = greatest(coalesce(longest_streak, 0), v_new),
                     lost_streak = null, lost_at = null, updated_at = now()
   where user_id = uid;
  return jsonb_build_object('ok', true, 'streak', v_new, 'gold', v_gold, 'cost', v_cost);
end $function$
;

-- create_plan: 2 raise -> jz_err
CREATE OR REPLACE FUNCTION public.create_plan(p_coach_style text, p_intensity integer, p_current_level text, p_goal_level text, p_daily_minutes integer, p_days_per_week integer, p_motive text, p_deadline date, p_estimated_hours integer, p_estimated_completion date, p_skill_levels jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  uid uuid := auth.uid();
  v_course uuid; v_unit uuid; v_unit_oi int; v_first uuid; s text; v_lvl text;
  v_level text; v_ranks text[] := array['A1','A2','B1','B2','C1','C2'];
  v_below int := 0;
begin
  if uid is null then perform jz_err('auth required', 'auth'); end if;
  insert into users (id, email) values (uid, (select email from auth.users where id = uid))
  on conflict (id) do nothing;

  -- Curso ACTIVO del usuario (con fallback al más antiguo activo = es→en). Antes se
  -- ignoraba el curso activo → se sembraba siempre en es→en (bug multicurso).
  select jz_active_course() into v_course;
  if v_course is null then perform jz_err('no active course', 'not_found'); end if;

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
end $function$
;

-- complete_lesson: 2 raise -> jz_err
CREATE OR REPLACE FUNCTION public.complete_lesson(p_lesson_id uuid, p_answers jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  uid uuid := auth.uid();
  v_course uuid;
  v_unit uuid;
  v_order int;
  v_xp_reward int;
  v_graded int := 0;
  v_correct int := 0;
  v_combo int := 0;
  v_max_combo int := 0;
  v_combo_bonus int := 0;
  v_acc numeric := 0;
  v_xp int := 0;
  v_gold int := 5;
  v_status lesson_progress_status;
  v_next uuid;
  v_activity jsonb;
  rec record;
  v_skills jsonb := '[]'::jsonb;
  v_new_points numeric;
  v_new_cefr cefr_level;
  v_old_cefr cefr_level;
  v_leveled boolean;
begin
  if uid is null then perform jz_err('auth required', 'auth'); end if;

  select u.course_id, l.unit_id, l.order_index, l.xp_reward
    into v_course, v_unit, v_order, v_xp_reward
  from lessons l join units u on u.id = l.unit_id
  where l.id = p_lesson_id;
  if v_course is null then perform jz_err('lesson not found', 'not_found'); end if;

  insert into user_course_progress (user_id, course_id, current_unit_id, current_lesson_id)
  values (uid, v_course, v_unit, p_lesson_id)
  on conflict (user_id, course_id) do nothing;
  insert into user_skill_levels (user_id, course_id, skill, cefr_level, progress_points)
  select uid, v_course, s::skill, 'A1', 0
  from unnest(array['reading', 'listening', 'writing', 'speaking']) s
  on conflict (user_id, course_id, skill) do nothing;

  create temp table _g on commit drop as
  select ci.id as item_id, ci.cefr_level,
         ci.skill,
         jz_is_stub(ci.type) as is_stub,
         case when jz_is_stub(ci.type) then null
              else jz_grade(ci.type, ci.correct_answer, a.elem -> 'answer') end as correct,
         a.ord
  from jsonb_array_elements(p_answers) with ordinality as a(elem, ord)
  join content_items ci on ci.id = (a.elem ->> 'item_id')::uuid;

  for rec in select correct, is_stub from _g order by ord loop
    if rec.is_stub then continue; end if;
    v_graded := v_graded + 1;
    if rec.correct then
      v_correct := v_correct + 1;
      v_combo := v_combo + 1;
      if v_combo > v_max_combo then v_max_combo := v_combo; end if;
      if v_combo >= 3 then v_combo_bonus := v_combo_bonus + 2; end if;
    else
      v_combo := 0;
    end if;
  end loop;

  v_acc := case when v_graded > 0 then v_correct::numeric / v_graded else 0 end;
  v_xp := case when v_graded > 0 then round(v_xp_reward * v_acc)::int + v_combo_bonus
               else v_combo_bonus end;
  v_gold := case when v_graded > 0 and v_acc >= 0.8 then 10 else 5 end;
  v_status := case when v_graded > 0 and v_acc >= 1 then 'golden'
                   else 'completed' end::lesson_progress_status;

  insert into user_lesson_progress (user_id, lesson_id, status, best_accuracy, times_completed, completed_at)
  values (uid, p_lesson_id, v_status, v_acc, 1, now())
  on conflict (user_id, lesson_id) do update set
    status = case when user_lesson_progress.status = 'golden' then 'golden' else excluded.status end,
    best_accuracy = greatest(coalesce(user_lesson_progress.best_accuracy, 0), excluded.best_accuracy),
    times_completed = user_lesson_progress.times_completed + 1,
    completed_at = now();

  update user_course_progress set xp_total = xp_total + v_xp, updated_at = now()
   where user_id = uid and course_id = v_course;
  update user_stats set xp_total = xp_total + v_xp, gold = gold + v_gold, updated_at = now()
   where user_id = uid;
  insert into gold_transactions (user_id, amount, reason) values (uid, v_gold, 'lesson');

  -- Meta diaria + racha (gateada por la meta) + hitos.
  v_activity := jz_register_activity(uid, v_course, v_xp);

  -- Registro POR ITEM: revive el pipeline de DOMINIO (jz_skill_mastery, mig 141).
  -- speaking stub = participacion (true). Es lo que hace el NIVEL nivel-consciente.
  for rec in select item_id, is_stub, correct from _g loop
    perform jz_record_item(uid, rec.item_id,
      case when rec.is_stub then true else coalesce(rec.correct, false) end);
  end loop;

  -- Puntos de practica = BARRA (se reinicia al llenar), YA NO cambian el nivel CEFR
  -- (era grind inflable). El NIVEL sube SOLO por dominio (jz_displayed_level) y no baja.
  for rec in
    select skill,
           sum(case when correct then 12 when is_stub then 4 else 0 end)::numeric as pts
    from _g group by skill
    having sum(case when correct then 12 when is_stub then 4 else 0 end) > 0
  loop
    select progress_points, cefr_level into v_new_points, v_old_cefr
    from user_skill_levels
    where user_id = uid and course_id = v_course and skill = rec.skill;
    v_new_points := v_new_points + rec.pts;
    if v_new_points >= 100 then v_new_points := v_new_points - 100; end if;
    v_new_cefr := greatest(v_old_cefr, jz_displayed_level(uid, v_course, rec.skill));
    v_leveled := v_new_cefr <> v_old_cefr;

    update user_skill_levels
      set progress_points = v_new_points, cefr_level = v_new_cefr, updated_at = now()
     where user_id = uid and course_id = v_course and skill = rec.skill;

    v_skills := v_skills || jsonb_build_object(
      'skill', rec.skill, 'points_added', rec.pts,
      'cefr_level', v_new_cefr, 'leveled_up', v_leveled);
  end loop;

  select id into v_next from lessons
   where unit_id = v_unit and order_index > v_order
   order by order_index limit 1;
  if v_next is null then
    select l.id into v_next from lessons l join units u on u.id = l.unit_id
     where u.course_id = v_course
       and u.order_index > (select order_index from units where id = v_unit)
     order by u.order_index, l.order_index limit 1;
  end if;
  if v_next is not null then
    insert into user_lesson_progress (user_id, lesson_id, status)
    values (uid, v_next, 'available')
    on conflict (user_id, lesson_id) do update
      set status = case when user_lesson_progress.status in ('completed', 'golden')
                        then user_lesson_progress.status else 'available' end;
  end if;
  update user_course_progress set current_lesson_id = coalesce(v_next, p_lesson_id)
   where user_id = uid and course_id = v_course;


  -- ── SRS (F0→F2) · INSCRIPCIÓN ────────────────────────────────────────────────
  -- F2: inscribe las palabras que la lección ENSEÑA según lesson_vocab (mapa
  -- PRECISO — incluye los pares de `match`, que el substring no veía). Fallback al
  -- substring si la lección no tiene mapeo (0 regresión). BEST-EFFORT y AL FINAL:
  -- un fallo del SRS jamás debe tumbar el fin de lección (corazón del loop).
  begin
    perform jz_srs_enroll_lesson(uid, v_course, p_lesson_id,
      array(select item_id from _g),                          -- vistas (todos)
      array(select item_id from _g where correct is false));  -- falladas (prioridad)
  exception when others then null;
  end;

  return jsonb_build_object(
    'lesson_id', p_lesson_id,
    'status', v_status,
    'graded', v_graded,
    'correct', v_correct,
    'accuracy', v_acc,
    'xp_earned', v_xp,
    'gold_earned', v_gold,
    'combo_bonus', v_combo_bonus,
    'max_combo', v_max_combo,
    'xp_total', (select xp_total from user_stats where user_id = uid),
    'gold_total', (select gold from user_stats where user_id = uid),
    'streak', (v_activity ->> 'streak')::int,
    'streak_advanced', (v_activity ->> 'streak_advanced')::boolean,
    'streak_freeze_used', coalesce((v_activity ->> 'freeze_used')::int, 0),
    'goal_met', (v_activity ->> 'goal_met')::boolean,
    'daily_goal_xp', (v_activity ->> 'goal_xp')::int,
    'daily_xp_earned', (v_activity ->> 'xp_earned_today')::int,
    'milestone', (v_activity ->> 'milestone')::int,
    'next_lesson_id', v_next,
    'skills', v_skills
  );
end $function$
;
