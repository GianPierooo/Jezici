-- 20260710120141_unify_level_domain.sql
-- UNIFICA nivel MOSTRADO con nivel CERTIFICABLE (P0 de EVAL_AUDIT.md).
-- Antes: user_skill_levels.cefr_level subia por GRIND (12/acierto,4/stub,100=+1)
-- sin mirar el nivel del contenido -> radar inflable, divergia de jz_skill_mastery.
-- Ademas el pipeline de dominio estaba MUERTO (complete_lesson/checkpoint/examen
-- dejaron de llamar jz_record_item ~2026-06-30 -> mastery ~0 -> certificacion IMPOSIBLE).
-- Fix: (1) revivir el registro por item; (2) el NIVEL sube SOLO por DOMINIO
-- (jz_displayed_level = nivel mas alto con jz_skill_mastery>=0.80), nunca por grind,
-- con el placement como piso; los puntos quedan como BARRA de practica.
begin;

-- Nivel MOSTRADO por DOMINIO: el nivel CEFR mas alto (con contenido en el curso)
-- cuyo dominio real jz_skill_mastery >= 0.80. Piso A1. Es la MISMA metrica que
-- gatea la certificacion -> radar y certificable dejan de divergir.
create or replace function jz_displayed_level(p_uid uuid, p_course uuid, p_skill skill)
returns cefr_level language plpgsql stable security definer set search_path = public as $$
declare v_ranks text[] := array['A1','A2','B1','B2','C1','C2']; v_best text := 'A1'; lvl text;
begin
  for lvl in
    select distinct cefr_level::text l from content_items
    where course_id = p_course and skill = p_skill and not ('placement' = any(tags))
    order by 1
  loop
    if jz_skill_mastery(p_uid, p_course, p_skill, lvl::cefr_level) >= 0.80
       and array_position(v_ranks, lvl) > array_position(v_ranks, v_best) then
      v_best := lvl;
    end if;
  end loop;
  return v_best::cefr_level;
end $$;
grant execute on function jz_displayed_level(uuid, uuid, skill) to authenticated;

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
end $function$;

CREATE OR REPLACE FUNCTION public.submit_checkpoint(p_lesson_id uuid, p_answers jsonb, p_time_taken_sec integer DEFAULT NULL::integer)
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
  select ci.id as item_id, ci.cefr_level,
         ci.skill,
         jz_is_stub(ci.type) as is_stub,
         case when jz_is_stub(ci.type) then null
              else jz_grade(ci.type, ci.correct_answer, a.elem -> 'answer') end as correct
  from jsonb_array_elements(p_answers) as a(elem)
  join content_items ci on ci.id = (a.elem ->> 'item_id')::uuid;

  -- Registro POR ITEM (dominio, mig 141) — incondicional (los intentos cuentan
  -- aunque no se apruebe el checkpoint).
  for rec in select item_id, is_stub, correct from _g loop
    perform jz_record_item(uid, rec.item_id,
      case when rec.is_stub then true else coalesce(rec.correct, false) end);
  end loop;

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
      select progress_points, cefr_level into v_new_points, v_new_cefr
      from user_skill_levels where user_id = uid and course_id = v_course and skill = rec.skill;
      v_new_points := v_new_points + rec.pts;
      if v_new_points >= 100 then v_new_points := v_new_points - 100; end if;  -- barra
      -- NIVEL por dominio (jz_displayed_level, mig 141); no baja.
      v_new_cefr := greatest(v_new_cefr, jz_displayed_level(uid, v_course, rec.skill));
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
    'streak_freeze_used', coalesce((v_activity ->> 'freeze_used')::int, 0),
    'goal_met', coalesce((v_activity ->> 'goal_met')::boolean, false),
    'milestone', coalesce((v_activity ->> 'milestone')::int, 0)
  );
end $function$;

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
  select ci.id as item_id, ci.cefr_level, ci.skill, jz_is_stub(ci.type) as is_stub,
         (a.elem -> 'answer') as ans,
         case when jz_is_stub(ci.type) then null
              else jz_grade(ci.type, ci.correct_answer, a.elem -> 'answer') end as correct
  from jsonb_array_elements(p_answers) as a(elem)
  join content_items ci on ci.id = (a.elem ->> 'item_id')::uuid;

  -- Registro POR ITEM (dominio, mig 141): el examen es evidencia FUERTE del nivel.
  for rec in select item_id, is_stub, correct from _le loop
    perform jz_record_item(uid, rec.item_id,
      case when rec.is_stub then true else coalesce(rec.correct, false) end);
  end loop;

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
end $function$;

-- ===== MIGRACION de usuarios existentes =====
-- 1) Reconstruye el DOMINIO (user_skill_mastery.items_correct = piso de
--    jz_skill_mastery) desde el historial REAL de lecciones completadas. Acotado
--    por leccion (no inflable por repeticion): credita ~acc*items por (skill,nivel).
insert into user_skill_mastery (user_id, course_id, skill, cefr_level, items_seen, items_correct, lessons_done)
select ulp.user_id, u.course_id, ci.skill, u.cefr_level,
       count(*)::int, round(sum(coalesce(ulp.best_accuracy, 0)))::int, 0
from user_lesson_progress ulp
join lessons l on l.id = ulp.lesson_id
join units u on u.id = l.unit_id
join lesson_items li on li.lesson_id = l.id
join content_items ci on ci.id = li.item_id and not jz_is_stub(ci.type)
where ulp.status in ('completed','golden')
group by ulp.user_id, u.course_id, ci.skill, u.cefr_level
on conflict (user_id, course_id, skill, cefr_level) do update set
  items_seen = greatest(user_skill_mastery.items_seen, excluded.items_seen),
  items_correct = greatest(user_skill_mastery.items_correct, excluded.items_correct),
  updated_at = now();

-- 2) Recomputa el nivel MOSTRADO = greatest(nivel de entrada del placement, dominio real).
--    Un-infla a quienes subieron por grind; respeta el placement como piso. XP/oro/racha/
--    lecciones INTACTOS (solo se toca cefr_level).
update user_skill_levels usl set
  cefr_level = greatest(
    coalesce((select up.current_level::cefr_level from user_plans up
              where up.user_id = usl.user_id and up.course_id = usl.course_id limit 1), 'A1'::cefr_level),
    jz_displayed_level(usl.user_id, usl.course_id, usl.skill)),
  updated_at = now();

commit;
