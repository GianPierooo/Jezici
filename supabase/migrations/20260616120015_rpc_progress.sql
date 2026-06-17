-- ============================================================================
-- Jezici · Migración 015 · Persistencia de progreso + 4 habilidades (paso E)
-- ----------------------------------------------------------------------------
-- Lógica sensible del lado SERVIDOR (Arquitectura §4/§7): el cliente nunca
-- decide XP ni oro. complete_lesson RE-CALIFICA las respuestas server-side y
-- persiste todo. SECURITY DEFINER (corre como owner, ignora RLS) + auth.uid().
--
-- Economía (valores por defecto, ajustables):
--   · XP lección = round(xp_reward * precisión) + bonus de combo
--   · oro = 10 si precisión ≥ 80%, si no 5
--   · puntos de habilidad: +12 por ítem correcto · +4 por stub (participación)
--   · subir de nivel CEFR de una skill al acumular 100 puntos
-- ============================================================================

-- ── Helpers de calificación (espejo del grader del cliente) ─────────────────

-- Normaliza: minúsculas, espacios colapsados, sin puntuación final.
create or replace function jz_normalize(t text)
returns text language sql immutable as $$
  select lower(btrim(regexp_replace(
           regexp_replace(coalesce(t, ''), '[.!?¿¡,;:]', '', 'g'),
           '\s+', ' ', 'g')))
$$;

-- ¿Tipo no calificable en Fase 1 (sin audio / STT)?
create or replace function jz_is_stub(p_type content_item_type)
returns boolean language sql immutable as $$
  select p_type in ('listening', 'speaking_read_aloud', 'dictation', 'guided_writing')
$$;

-- Siguiente nivel CEFR.
create or replace function jz_next_cefr(c cefr_level)
returns cefr_level language sql immutable as $$
  select (case c
    when 'A1' then 'A2' when 'A2' then 'B1' when 'B1' then 'B2'
    when 'B2' then 'C1' when 'C1' then 'C2' else 'C2' end)::cefr_level
$$;

-- Califica una respuesta contra correct_answer (determinista, por tipo).
create or replace function jz_grade(p_type content_item_type, p_correct jsonb, p_answer jsonb)
returns boolean language plpgsql immutable as $$
declare
  v_user text;
  v_exp  text;
begin
  if p_answer is null or jz_is_stub(p_type) then
    return false;
  end if;

  if p_type in ('multiple_choice', 'true_false') then
    return jz_normalize(p_answer #>> '{}') = jz_normalize(p_correct ->> 'value');

  elsif p_type in ('cloze', 'translation') then
    v_user := p_answer #>> '{}';
    if jz_normalize(v_user) = jz_normalize(p_correct ->> 'value') then
      return true;
    end if;
    if jsonb_typeof(p_correct -> 'accepted') = 'array' then
      return exists (
        select 1 from jsonb_array_elements_text(p_correct -> 'accepted') a
        where jz_normalize(a) = jz_normalize(v_user));
    end if;
    return false;

  elsif p_type in ('word_bank', 'reorder') then
    if jsonb_typeof(p_correct -> 'sequence') = 'array' then
      select string_agg(x, ' ') into v_exp
      from jsonb_array_elements_text(p_correct -> 'sequence') x;
    else
      v_exp := p_correct ->> 'value';
    end if;
    if jsonb_typeof(p_answer) = 'array' then
      select string_agg(x, ' ') into v_user
      from jsonb_array_elements_text(p_answer) x;
    else
      v_user := p_answer #>> '{}';
    end if;
    return jz_normalize(v_user) = jz_normalize(v_exp);

  elsif p_type = 'match' then
    if jsonb_typeof(p_correct -> 'pairs') <> 'array'
       or jsonb_typeof(p_answer) <> 'object' then
      return false;
    end if;
    if (select count(*) from jsonb_array_elements(p_correct -> 'pairs'))
       <> (select count(*) from jsonb_object_keys(p_answer)) then
      return false;
    end if;
    return not exists (
      select 1
      from jsonb_array_elements(p_correct -> 'pairs') with ordinality as t(pair, idx)
      where jz_normalize(p_answer ->> ((idx - 1)::int)::text)
            is distinct from jz_normalize(pair ->> 1));
  end if;

  return false;
end $$;

-- ── start_course: arranque del curso para el usuario ────────────────────────
create or replace function start_course()
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
begin
  if uid is null then raise exception 'auth required'; end if;

  select id into v_course from courses where is_active order by created_at limit 1;
  if v_course is null then raise exception 'no active course'; end if;

  select id into v_unit from units where course_id = v_course order by order_index limit 1;
  select id into v_first_lesson
  from lessons where unit_id = v_unit and type = 'lesson'
  order by order_index limit 1;

  insert into user_course_progress (user_id, course_id, current_unit_id, current_lesson_id, xp_total)
  values (uid, v_course, v_unit, v_first_lesson, 0)
  on conflict (user_id, course_id) do nothing;

  insert into user_skill_levels (user_id, course_id, skill, cefr_level, progress_points)
  select uid, v_course, s::skill, 'A1', 0
  from unnest(array['reading', 'listening', 'writing', 'speaking']) s
  on conflict (user_id, course_id, skill) do nothing;

  if v_first_lesson is not null then
    insert into user_lesson_progress (user_id, lesson_id, status)
    values (uid, v_first_lesson, 'available')
    on conflict (user_id, lesson_id) do update
      set status = case when user_lesson_progress.status in ('completed', 'golden')
                        then user_lesson_progress.status else 'available' end;
  end if;

  return jsonb_build_object('course_id', v_course, 'first_lesson_id', v_first_lesson);
end $$;

-- ── complete_lesson: cierra una lección y persiste TODO (server-side) ────────
-- p_answers: jsonb array de { "item_id": uuid, "answer": <valor> }
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
  v_streak int;
  v_longest int;
  v_last date;
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

  -- Asegurar fila de curso + 4 skills (idempotente).
  insert into user_course_progress (user_id, course_id, current_unit_id, current_lesson_id)
  values (uid, v_course, v_unit, p_lesson_id)
  on conflict (user_id, course_id) do nothing;
  insert into user_skill_levels (user_id, course_id, skill, cefr_level, progress_points)
  select uid, v_course, s::skill, 'A1', 0
  from unnest(array['reading', 'listening', 'writing', 'speaking']) s
  on conflict (user_id, course_id, skill) do nothing;

  -- Calificar cada respuesta server-side (en orden, para el combo).
  create temp table _g on commit drop as
  select ci.skill,
         jz_is_stub(ci.type) as is_stub,
         case when jz_is_stub(ci.type) then null
              else jz_grade(ci.type, ci.correct_answer, a.elem -> 'answer') end as correct,
         a.ord
  from jsonb_array_elements(p_answers) with ordinality as a(elem, ord)
  join content_items ci on ci.id = (a.elem ->> 'item_id')::uuid;

  for rec in select correct, is_stub from _g order by ord loop
    if rec.is_stub then
      continue; -- los stubs no rompen el combo ni cuentan
    end if;
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

  -- Estado del nodo.
  insert into user_lesson_progress (user_id, lesson_id, status, best_accuracy, times_completed, completed_at)
  values (uid, p_lesson_id, v_status, v_acc, 1, now())
  on conflict (user_id, lesson_id) do update set
    status = case when user_lesson_progress.status = 'golden' then 'golden' else excluded.status end,
    best_accuracy = greatest(coalesce(user_lesson_progress.best_accuracy, 0), excluded.best_accuracy),
    times_completed = user_lesson_progress.times_completed + 1,
    completed_at = now();

  -- XP en progreso de curso + stats; oro al ledger.
  update user_course_progress set xp_total = xp_total + v_xp, updated_at = now()
   where user_id = uid and course_id = v_course;
  update user_stats set xp_total = xp_total + v_xp, gold = gold + v_gold, updated_at = now()
   where user_id = uid;
  insert into gold_transactions (user_id, amount, reason) values (uid, v_gold, 'lesson');

  -- Racha.
  select current_streak, longest_streak, last_active_date
    into v_streak, v_longest, v_last
  from streaks where user_id = uid for update;
  if v_last is null then v_streak := 1;
  elsif v_last = current_date then v_streak := greatest(v_streak, 1);
  elsif v_last = current_date - 1 then v_streak := v_streak + 1;
  else v_streak := 1;
  end if;
  v_longest := greatest(coalesce(v_longest, 0), v_streak);
  update streaks set current_streak = v_streak, longest_streak = v_longest,
                     last_active_date = current_date, updated_at = now()
   where user_id = uid;

  -- Meta diaria.
  insert into daily_goals (user_id, goal_date, goal_xp, xp_earned)
  values (uid, current_date, 30, v_xp)
  on conflict (user_id, goal_date) do update
    set xp_earned = daily_goals.xp_earned + excluded.xp_earned, updated_at = now();

  -- 4 habilidades: puntos por skill cubierta (correcto +12, stub +4).
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

  -- Desbloquear el siguiente nodo (mismo unit por orden; si no, primer nodo del siguiente unit).
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
    'streak', v_streak,
    'next_lesson_id', v_next,
    'skills', v_skills
  );
end $$;

-- Permisos: solo usuarios autenticados pueden invocarlas.
grant execute on function start_course() to authenticated;
grant execute on function complete_lesson(uuid, jsonb) to authenticated;
