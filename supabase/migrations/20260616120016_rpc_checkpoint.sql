-- ============================================================================
-- Jezici · Migración 016 · Checkpoint de unidad con gating (paso F)
-- ----------------------------------------------------------------------------
-- Banco_Items §4/§6 + Estructura_App §7.3: examen de unidad cronometrado,
-- set ALEATORIZADO que cubre las 4 habilidades, scoring por habilidad, umbral
-- 80%. Calificación 100% server-side (reusa jz_normalize/jz_grade de la 015).
-- Listening/speaking son stubs en Fase 1 → no puntúan (participación).
-- ============================================================================

-- ── start_checkpoint: arma el examen (server-side, anti-trampa) ──────────────
-- Devuelve un set aleatorizado de ítems de la unidad SIN correct_answer.
create or replace function start_checkpoint(p_lesson_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  v_course uuid;
  v_unit uuid;
  v_cefr cefr_level;
  v_exam uuid;
  v_items jsonb;
begin
  if uid is null then raise exception 'auth required'; end if;

  select u.course_id, l.unit_id, u.cefr_level
    into v_course, v_unit, v_cefr
  from lessons l join units u on u.id = l.unit_id
  where l.id = p_lesson_id;
  if v_course is null then raise exception 'lesson not found'; end if;

  -- Examen de la unidad (existe del seed; si no, lo creamos).
  select id into v_exam from exams
   where course_id = v_course and type = 'checkpoint' and unit_id = v_unit limit 1;
  if v_exam is null then
    insert into exams (course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections)
    values (v_course, 'checkpoint', v_cefr, v_unit, 300, 0.80, '{}'::jsonb)
    returning id into v_exam;
  end if;

  -- Set aleatorizado cubriendo las 4 habilidades (cupos por skill).
  with ranked as (
    select id, type, skill, cefr_level, prompt, payload,
           row_number() over (partition by skill order by random()) as rn
    from content_items
    where course_id = v_course and cefr_level = v_cefr and 'unidad1' = any(tags)
  ),
  picked as (
    select * from ranked
    where (skill = 'reading'   and rn <= 3)
       or (skill = 'writing'   and rn <= 3)
       or (skill = 'listening' and rn <= 2)
       or (skill = 'speaking'  and rn <= 2)
    order by random()
  )
  select jsonb_agg(jsonb_build_object(
           'id', id, 'type', type, 'skill', skill,
           'cefr_level', cefr_level, 'prompt', prompt, 'payload', payload))
    into v_items
  from picked;

  return jsonb_build_object(
    'exam_id', v_exam,
    'time_limit_sec', 300,
    'pass_threshold', 0.80,
    'item_count', coalesce(jsonb_array_length(v_items), 0),
    'items', coalesce(v_items, '[]'::jsonb)
  );
end $$;

-- ── submit_checkpoint: califica, decide aprobado y aplica el gating ──────────
create or replace function submit_checkpoint(
  p_lesson_id uuid, p_answers jsonb, p_time_taken_sec int default null)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  v_course uuid;
  v_unit uuid;
  v_order int;
  v_cefr cefr_level;
  v_xp_reward int;
  v_graded int := 0;
  v_correct int := 0;
  v_acc numeric := 0;
  v_passed boolean := false;
  v_exam uuid;
  v_attempt_no int;
  v_xp int := 0;
  v_gold int := 0;
  v_status lesson_progress_status;
  v_next uuid;
  v_per_skill jsonb;
  v_weak jsonb;
  v_streak int; v_longest int; v_last date;
  rec record;
  v_new_points numeric; v_new_cefr cefr_level;
begin
  if uid is null then raise exception 'auth required'; end if;

  select u.course_id, l.unit_id, l.order_index, u.cefr_level, l.xp_reward
    into v_course, v_unit, v_order, v_cefr, v_xp_reward
  from lessons l join units u on u.id = l.unit_id
  where l.id = p_lesson_id;
  if v_course is null then raise exception 'lesson not found'; end if;

  insert into user_course_progress (user_id, course_id, current_unit_id, current_lesson_id)
  values (uid, v_course, v_unit, p_lesson_id) on conflict (user_id, course_id) do nothing;
  insert into user_skill_levels (user_id, course_id, skill, cefr_level, progress_points)
  select uid, v_course, s::skill, 'A1', 0 from unnest(array['reading','listening','writing','speaking']) s
  on conflict (user_id, course_id, skill) do nothing;

  -- Calificar server-side.
  create temp table _g on commit drop as
  select ci.skill,
         jz_is_stub(ci.type) as is_stub,
         case when jz_is_stub(ci.type) then null
              else jz_grade(ci.type, ci.correct_answer, a.elem -> 'answer') end as correct
  from jsonb_array_elements(p_answers) as a(elem)
  join content_items ci on ci.id = (a.elem ->> 'item_id')::uuid;

  select count(*) filter (where not is_stub),
         count(*) filter (where correct)
    into v_graded, v_correct from _g;
  v_acc := case when v_graded > 0 then v_correct::numeric / v_graded else 0 end;
  v_passed := v_graded > 0 and v_acc >= 0.80;

  -- Desglose por las 4 habilidades.
  select jsonb_agg(jsonb_build_object(
           'skill', skill, 'total', total, 'correct', correct_cnt, 'graded', graded_cnt,
           'accuracy', case when graded_cnt > 0 then round(correct_cnt::numeric / graded_cnt, 2) else null end)
         order by skill)
    into v_per_skill
  from (
    select skill, count(*) total,
           count(*) filter (where not is_stub) graded_cnt,
           count(*) filter (where correct) correct_cnt
    from _g group by skill
  ) s;

  select coalesce(jsonb_agg(skill), '[]'::jsonb) into v_weak
  from (
    select skill, count(*) filter (where not is_stub) g, count(*) filter (where correct) c
    from _g group by skill
  ) s where g > 0 and c::numeric / g < 0.80;

  -- Examen + registro del intento.
  select id into v_exam from exams
   where course_id = v_course and type = 'checkpoint' and unit_id = v_unit limit 1;
  if v_exam is null then
    insert into exams (course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold)
    values (v_course, 'checkpoint', v_cefr, v_unit, 300, 0.80) returning id into v_exam;
  end if;

  insert into exam_attempts (user_id, exam_id, started_at, finished_at,
                             score_global, per_skill_results, passed)
  values (uid, v_exam, now() - (coalesce(p_time_taken_sec, 0) || ' seconds')::interval,
          now(), v_acc, v_per_skill, v_passed);

  select count(*) into v_attempt_no from exam_attempts where user_id = uid and exam_id = v_exam;

  if v_passed then
    v_xp := v_xp_reward;        -- recompensa del checkpoint (lesson.xp_reward, p.ej. 40)
    v_gold := 30;
    v_status := case when v_acc >= 1 then 'golden' else 'completed' end::lesson_progress_status;

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
    insert into gold_transactions (user_id, amount, reason) values (uid, v_gold, 'challenge');

    -- Racha + meta diaria.
    select current_streak, longest_streak, last_active_date into v_streak, v_longest, v_last
    from streaks where user_id = uid for update;
    if v_last is null then v_streak := 1;
    elsif v_last = current_date then v_streak := greatest(v_streak, 1);
    elsif v_last = current_date - 1 then v_streak := v_streak + 1;
    else v_streak := 1; end if;
    v_longest := greatest(coalesce(v_longest, 0), v_streak);
    update streaks set current_streak = v_streak, longest_streak = v_longest,
                       last_active_date = current_date, updated_at = now() where user_id = uid;
    insert into daily_goals (user_id, goal_date, goal_xp, xp_earned)
    values (uid, current_date, 30, v_xp)
    on conflict (user_id, goal_date) do update
      set xp_earned = daily_goals.xp_earned + excluded.xp_earned, updated_at = now();

    -- Skills (correcto +12, stub +4) con subida de nivel a los 100 pts.
    for rec in
      select skill, sum(case when correct then 12 when is_stub then 4 else 0 end)::numeric pts
      from _g group by skill having sum(case when correct then 12 when is_stub then 4 else 0 end) > 0
    loop
      select progress_points + rec.pts, cefr_level into v_new_points, v_new_cefr
      from user_skill_levels where user_id = uid and course_id = v_course and skill = rec.skill;
      if v_new_points >= 100 then
        v_new_cefr := jz_next_cefr(v_new_cefr); v_new_points := v_new_points - 100;
      end if;
      update user_skill_levels set progress_points = v_new_points, cefr_level = v_new_cefr, updated_at = now()
       where user_id = uid and course_id = v_course and skill = rec.skill;
    end loop;

    -- GATING: desbloquear el primer nodo de la siguiente unidad (si existe).
    select l.id into v_next from lessons l join units u on u.id = l.unit_id
     where u.course_id = v_course and u.order_index > (select order_index from units where id = v_unit)
     order by u.order_index, l.order_index limit 1;
    if v_next is not null then
      insert into user_lesson_progress (user_id, lesson_id, status)
      values (uid, v_next, 'available')
      on conflict (user_id, lesson_id) do update
        set status = case when user_lesson_progress.status in ('completed', 'golden')
                          then user_lesson_progress.status else 'available' end;
      update user_course_progress set current_lesson_id = v_next
       where user_id = uid and course_id = v_course;
    end if;
  end if;

  return jsonb_build_object(
    'passed', v_passed,
    'score_global', v_acc,
    'threshold', 0.80,
    'attempt_number', v_attempt_no,
    'graded', v_graded,
    'correct', v_correct,
    'xp_earned', v_xp,
    'gold_earned', v_gold,
    'per_skill', coalesce(v_per_skill, '[]'::jsonb),
    'weaknesses', v_weak,
    'next_unlocked', v_next is not null,
    'unit_id', v_unit
  );
end $$;

grant execute on function start_checkpoint(uuid) to authenticated;
grant execute on function submit_checkpoint(uuid, jsonb, int) to authenticated;
