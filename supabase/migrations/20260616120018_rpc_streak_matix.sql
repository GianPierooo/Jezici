-- ============================================================================
-- Jezici · Migración 018 · Racha + meta diaria + motor Matix (paso H)
-- ----------------------------------------------------------------------------
-- Cierra el slice: la racha avanza al CUMPLIR la meta diaria (no por actividad
-- suelta), con hitos 7/30/100/365 que premian oro. El motor Matix selecciona
-- el copy correcto por estilo×trigger×escalón respetando el techo (1/evento/día)
-- y las quiet_hours, y lo registra en `notifications`. Toda la lógica vive en
-- el SERVIDOR (Arquitectura §4/§7): el cliente nunca decide XP, oro ni racha.
-- ============================================================================

-- El centro de notificaciones in-app lee el copy resuelto desde aquí.
alter table notifications add column if not exists body text;

-- ── jz_register_activity: meta diaria + racha gateada + hitos ────────────────
-- La meta de XP del día sale de los minutos/día elegidos en el onboarding
-- (user_plans.daily_minutes), con default 30. La racha solo avanza el día en
-- que la meta se cumple, y una sola vez por día.
create or replace function jz_register_activity(p_uid uuid, p_course uuid, p_xp int)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_min int;
  v_goal int;
  v_earned int;
  v_met boolean;
  v_streak int; v_longest int; v_last date;
  v_adv boolean := false;
  v_milestone int := 0;
  v_bonus int := 0;
begin
  select daily_minutes into v_min
  from user_plans where user_id = p_uid and course_id = p_course;
  v_goal := greatest(10, coalesce(v_min, 30));

  insert into daily_goals (user_id, goal_date, goal_xp, xp_earned)
  values (p_uid, current_date, v_goal, p_xp)
  on conflict (user_id, goal_date) do update
    set xp_earned = daily_goals.xp_earned + excluded.xp_earned, updated_at = now()
  returning xp_earned, goal_xp into v_earned, v_goal;

  v_met := v_earned >= v_goal;

  select current_streak, longest_streak, last_active_date
    into v_streak, v_longest, v_last
  from streaks where user_id = p_uid for update;

  -- La racha avanza solo si la meta se cumple y no se contó ya hoy.
  if v_met and (v_last is null or v_last < current_date) then
    if v_last = current_date - 1 then
      v_streak := coalesce(v_streak, 0) + 1;
    else
      v_streak := 1;       -- primer día o tras un hueco
    end if;
    v_longest := greatest(coalesce(v_longest, 0), v_streak);
    update streaks set current_streak = v_streak, longest_streak = v_longest,
                       last_active_date = current_date, updated_at = now()
     where user_id = p_uid;
    v_adv := true;

    -- Hitos con recompensa de oro.
    if v_streak in (7, 30, 100, 365) then
      v_milestone := v_streak;
      v_bonus := case v_streak when 7 then 50 when 30 then 100
                               when 100 then 250 else 500 end;
      update user_stats set gold = gold + v_bonus, updated_at = now()
       where user_id = p_uid;
      insert into gold_transactions (user_id, amount, reason)
      values (p_uid, v_bonus, 'challenge');
    end if;
  end if;

  return jsonb_build_object(
    'goal_xp', v_goal,
    'xp_earned_today', v_earned,
    'goal_met', v_met,
    'streak', coalesce(v_streak, 0),
    'longest_streak', coalesce(v_longest, 0),
    'streak_advanced', v_adv,
    'milestone', v_milestone,
    'milestone_bonus', v_bonus);
end $$;

-- ── complete_lesson (re-emitida): usa el helper para meta + racha ────────────
create or replace function complete_lesson(p_lesson_id uuid, p_answers jsonb)
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
  v_leveled boolean;
begin
  if uid is null then raise exception 'auth required'; end if;

  select u.course_id, l.unit_id, l.order_index, l.xp_reward
    into v_course, v_unit, v_order, v_xp_reward
  from lessons l join units u on u.id = l.unit_id
  where l.id = p_lesson_id;
  if v_course is null then raise exception 'lesson not found'; end if;

  insert into user_course_progress (user_id, course_id, current_unit_id, current_lesson_id)
  values (uid, v_course, v_unit, p_lesson_id)
  on conflict (user_id, course_id) do nothing;
  insert into user_skill_levels (user_id, course_id, skill, cefr_level, progress_points)
  select uid, v_course, s::skill, 'A1', 0
  from unnest(array['reading', 'listening', 'writing', 'speaking']) s
  on conflict (user_id, course_id, skill) do nothing;

  create temp table _g on commit drop as
  select ci.skill,
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

  for rec in
    select skill,
           sum(case when correct then 12 when is_stub then 4 else 0 end)::numeric as pts
    from _g group by skill
    having sum(case when correct then 12 when is_stub then 4 else 0 end) > 0
  loop
    select progress_points + rec.pts into v_new_points
    from user_skill_levels
    where user_id = uid and course_id = v_course and skill = rec.skill;

    v_leveled := false;
    select cefr_level into v_new_cefr
    from user_skill_levels
    where user_id = uid and course_id = v_course and skill = rec.skill;
    if v_new_points >= 100 then
      v_new_cefr := jz_next_cefr(v_new_cefr);
      v_new_points := v_new_points - 100;
      v_leveled := true;
    end if;

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
    'goal_met', (v_activity ->> 'goal_met')::boolean,
    'daily_goal_xp', (v_activity ->> 'goal_xp')::int,
    'daily_xp_earned', (v_activity ->> 'xp_earned_today')::int,
    'milestone', (v_activity ->> 'milestone')::int,
    'next_lesson_id', v_next,
    'skills', v_skills
  );
end $$;

-- ── submit_checkpoint (re-emitida): usa el helper en el ramo "aprobado" ──────
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
  v_activity jsonb;
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
    v_xp := v_xp_reward;
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

    -- Meta diaria + racha (gateada) + hitos.
    v_activity := jz_register_activity(uid, v_course, v_xp);

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
    'unit_id', v_unit,
    'streak', coalesce((v_activity ->> 'streak')::int, 0),
    'streak_advanced', coalesce((v_activity ->> 'streak_advanced')::boolean, false),
    'goal_met', coalesce((v_activity ->> 'goal_met')::boolean, false),
    'milestone', coalesce((v_activity ->> 'milestone')::int, 0)
  );
end $$;

-- ── use_streak_freeze: comprar un congelador de racha (cuesta 50 oro) ─────────
create or replace function use_streak_freeze()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  v_gold int; v_freezes int; v_cost int := 50;
begin
  if uid is null then raise exception 'auth required'; end if;
  select gold into v_gold from user_stats where user_id = uid for update;
  if coalesce(v_gold, 0) < v_cost then
    return jsonb_build_object('ok', false, 'reason', 'insufficient_gold',
                              'gold', coalesce(v_gold, 0), 'cost', v_cost);
  end if;
  update user_stats set gold = gold - v_cost, updated_at = now()
   where user_id = uid returning gold into v_gold;
  insert into gold_transactions (user_id, amount, reason) values (uid, -v_cost, 'freeze');
  update streaks set freezes_available = freezes_available + 1, updated_at = now()
   where user_id = uid returning freezes_available into v_freezes;
  return jsonb_build_object('ok', true, 'gold', v_gold,
                            'freezes_available', coalesce(v_freezes, 0));
end $$;

-- ── update_settings: recalibrar Matix + ventana horaria + meta diaria ────────
create or replace function update_settings(
  p_coach_style text default null,
  p_intensity int default null,
  p_quiet_start time default null,
  p_quiet_end time default null,
  p_daily_minutes int default null,
  p_push_enabled boolean default null)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
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
    select id into v_course from courses where is_active order by created_at limit 1;
    update user_plans set daily_minutes = p_daily_minutes, updated_at = now()
     where user_id = uid and course_id = v_course;
  end if;

  return jsonb_build_object('ok', true);
end $$;

-- ── matix_fire: el motor — selecciona el copy y lo registra ──────────────────
-- Dado un TRIGGER, el estilo de coach del usuario y el escalón (nº de envíos
-- previos de ese trigger), elige el copy de notification_templates respetando
-- el techo (máx 1/evento/día) y las quiet_hours. Devuelve el copy resuelto y
-- el estado; el cliente dispara la notificación local si status = 'sent'.
create or replace function matix_fire(p_trigger notification_trigger)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  v_style coach_style;
  v_push boolean;
  v_qs time; v_qe time;
  v_max int; v_total int; v_today int; v_step int;
  v_tid uuid; v_copy text;
  v_status notification_status;
  v_reason text;
  v_streak int := 0; v_earned int := 0; v_goal int := 0; v_now time;
begin
  if uid is null then raise exception 'auth required'; end if;

  select coach_style, push_enabled, quiet_hours_start, quiet_hours_end
    into v_style, v_push, v_qs, v_qe
  from user_personality where user_id = uid;
  if v_style is null then v_style := 'suave'; v_push := true; end if;

  -- Escalón = nº histórico de envíos de este trigger + 1, tope al máx disponible.
  select coalesce(max(escalation_step), 1) into v_max
  from notification_templates
  where coach_style = v_style and trigger_type = p_trigger and channel = 'push';
  select count(*) into v_total
  from notifications where user_id = uid and trigger_type = p_trigger;
  select count(*) into v_today
  from notifications
  where user_id = uid and trigger_type = p_trigger and created_at::date = current_date;
  v_step := least(v_total + 1, greatest(v_max, 1));

  select id, copy into v_tid, v_copy
  from notification_templates
  where coach_style = v_style and trigger_type = p_trigger
        and escalation_step = v_step and channel = 'push'
  limit 1;
  if v_copy is null then
    select id, copy, escalation_step into v_tid, v_copy, v_step
    from notification_templates
    where coach_style = v_style and trigger_type = p_trigger and channel = 'push'
    order by escalation_step limit 1;
  end if;

  -- Sustitución de variables del copy.
  select current_streak into v_streak from streaks where user_id = uid;
  select xp_earned, goal_xp into v_earned, v_goal
  from daily_goals where user_id = uid and goal_date = current_date;
  if v_copy is not null then
    v_copy := replace(v_copy, '{dias}', coalesce(v_streak, 0)::text);
    v_copy := replace(v_copy, '{x}', coalesce(v_earned, 0)::text);
    v_copy := replace(v_copy, '{meta}', coalesce(v_goal, 0)::text);
    v_copy := replace(v_copy, '{logro}', 'un logro');
  end if;

  -- Decisión de envío: push activo, techo 1/evento/día, quiet_hours.
  v_now := current_time::time;
  if not coalesce(v_push, true) then
    v_status := 'suppressed'; v_reason := 'push_off';
  elsif v_today >= 1 then
    v_status := 'suppressed'; v_reason := 'capped';   -- techo del motor
  elsif v_qs is not null and v_qe is not null and
        ((v_qs <= v_qe and v_now >= v_qs and v_now < v_qe) or
         (v_qs >  v_qe and (v_now >= v_qs or v_now < v_qe))) then
    v_status := 'suppressed'; v_reason := 'quiet_hours';
  else
    v_status := 'sent'; v_reason := 'ok';
  end if;

  insert into notifications (user_id, channel, trigger_type, template_id, escalation_step,
                             scheduled_at, sent_at, status, body)
  values (uid, 'push', p_trigger, v_tid, v_step, now(),
          case when v_status = 'sent' then now() else null end, v_status, v_copy);

  return jsonb_build_object(
    'status', v_status,
    'reason', v_reason,
    'copy', v_copy,
    'coach_style', v_style,
    'escalation_step', v_step,
    'trigger', p_trigger,
    'channel', 'push');
end $$;

grant execute on function jz_register_activity(uuid, uuid, int) to authenticated;
grant execute on function complete_lesson(uuid, jsonb) to authenticated;
grant execute on function submit_checkpoint(uuid, jsonb, int) to authenticated;
grant execute on function use_streak_freeze() to authenticated;
grant execute on function update_settings(text, int, time, time, int, boolean) to authenticated;
grant execute on function matix_fire(notification_trigger) to authenticated;
