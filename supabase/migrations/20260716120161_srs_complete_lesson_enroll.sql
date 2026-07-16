-- SRS F0 · complete_lesson INSCRIBE en el SRS (best-effort, al final).
-- Recreada 1:1 desde la definición viva + SOLO el bloque de inscripción antes del
-- return. Nada más cambia: XP/oro/racha/skills/dominio/gating intactos.
-- Guardarraíl: verify_chain.py (en) + verify_pt_chain.py DEBEN seguir verdes.

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


  -- ── SRS (F0) · INSCRIPCIÓN — PRACTICAR_SRS_ANALISIS.md §4 ──────────────────
  -- Hasta hoy el SRS solo contenía lo que FALLABAS: complete_lesson no lo tocaba
  -- (0 menciones). Ahora las palabras VISTAS entran a la agenda de repaso.
  -- BEST-EFFORT y AL FINAL: complete_lesson es el corazón del loop; un fallo del
  -- SRS jamás debe tumbar el fin de lección (mismo criterio que el resto).
  -- Impreciso a propósito (substring, no lematiza) → inscribe de menos, no basura.
  begin
    -- (a) VISTAS → state='new' (el límite de nuevas/día decide cuándo salen).
    --     Re-ver una palabra ya agendada NO adelanta su repaso (rompería el espaciado).
    perform jz_srs_enroll(uid, v_course, array(select item_id from _g), false);
    -- (b) FALLADAS → due=now (prioridad), como ya hacía srs_prioritize_failed.
    perform jz_srs_enroll(uid, v_course,
      array(select item_id from _g where correct is false), true);
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
