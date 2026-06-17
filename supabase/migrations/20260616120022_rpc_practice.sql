-- ============================================================================
-- Jezici · Migración 022 · Practicar (SRS + debilidades + cronometrada + skill)
-- ----------------------------------------------------------------------------
-- Estructura_App §"Practicar" + Diseno_Gamificacion. Todo server-side: el
-- cliente nunca decide XP/oro. La práctica da MENOS XP que una lección nueva
-- (tope 20) y alimenta meta diaria + racha vía jz_register_activity.
-- Modos:
--   srs     · "rescate de palabras": repaso espaciado sobre vocabulary.
--   weakness· refuerzo de la habilidad más débil (user_skill_levels).
--   skill   · práctica de una habilidad concreta.
--   timed   · práctica cronometrada (mezcla calificable, sin stubs).
-- ============================================================================

-- ── start_practice: arma la sesión (ítems con respuesta, baja apuesta) ───────
create or replace function start_practice(p_mode text, p_skill text default null)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  v_course uuid;
  v_weak skill;
  v_items jsonb;
  v_due int := 0;
begin
  if uid is null then raise exception 'auth required'; end if;
  select id into v_course from courses where is_active order by created_at limit 1;

  if p_mode = 'srs' then
    -- Palabras a rescatar: vencidas o nuevas (aún sin agenda), por frecuencia.
    with due as (
      select v.id, v.word, v.translation,
             (s.vocab_id is null) as isnew, s.due_at
      from vocabulary v
      left join user_vocab_srs s on s.vocab_id = v.id and s.user_id = uid
      where v.course_id = v_course
        and (s.vocab_id is null or s.due_at is null or s.due_at <= now())
      order by (s.vocab_id is not null), coalesce(s.due_at, to_timestamp(0)), v.frequency_rank
      limit 12
    )
    select jsonb_agg(jsonb_build_object(
             'id', d.id, 'type', 'multiple_choice', 'skill', 'reading', 'cefr_level', 'A1',
             'prompt', '¿Cómo se dice «' || d.translation || '»?',
             'payload', jsonb_build_object('options', o.options),
             'correct_answer', jsonb_build_object('value', d.word)))
      into v_items
    from due d
    cross join lateral (
      select jsonb_agg(w order by random()) as options
      from (
        (select d.word as w)
        union all
        (select v2.word from vocabulary v2
          where v2.course_id = v_course and v2.word <> d.word
          order by random() limit 3)
      ) q
    ) o;
    select count(*) into v_due from vocabulary v
      left join user_vocab_srs s on s.vocab_id = v.id and s.user_id = uid
      where v.course_id = v_course and (s.vocab_id is null or s.due_at is null or s.due_at <= now());

  else
    -- Modos basados en el banco de ejercicios reales.
    if p_mode = 'weakness' then
      select skill into v_weak from user_skill_levels
        where user_id = uid and course_id = v_course
        order by array_position(array['A1','A2','B1','B2','C1','C2']::text[], cefr_level::text),
                 progress_points
        limit 1;
    end if;

    select jsonb_agg(jsonb_build_object(
             'id', id, 'type', type, 'skill', skill, 'cefr_level', cefr_level,
             'prompt', prompt, 'payload', payload, 'correct_answer', correct_answer))
      into v_items
    from (
      select id, type, skill, cefr_level, prompt, payload, correct_answer
      from content_items
      where course_id = v_course
        and not ('placement' = any(tags))
        and case
              when p_mode = 'weakness' then skill = v_weak
              when p_mode = 'skill' then skill = p_skill::skill
              when p_mode = 'timed' then type not in ('listening','speaking_read_aloud','dictation','guided_writing')
              else true
            end
      order by random()
      limit case when p_mode = 'timed' then 20 else 10 end
    ) x;
  end if;

  return jsonb_build_object(
    'mode', p_mode,
    'weakest_skill', v_weak,
    'due_count', v_due,
    'item_count', coalesce(jsonb_array_length(v_items), 0),
    'items', coalesce(v_items, '[]'::jsonb));
end $$;

-- ── submit_practice: califica server-side, da XP (tope 20) y actualiza SRS ────
create or replace function submit_practice(p_mode text, p_answers jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  v_course uuid;
  v_graded int := 0;
  v_correct int := 0;
  v_xp int := 0;
  v_gold int := 0;
  v_activity jsonb;
  rec record;
  v_word text;
  v_ok boolean;
  v_strength numeric;
  v_interval int;
  v_new_points numeric; v_new_cefr cefr_level;
begin
  if uid is null then raise exception 'auth required'; end if;
  select id into v_course from courses where is_active order by created_at limit 1;

  if p_mode = 'srs' then
    for rec in select (e ->> 'item_id')::uuid as vid, e -> 'answer' as ans
               from jsonb_array_elements(p_answers) e loop
      select word into v_word from vocabulary where id = rec.vid;
      if v_word is null then continue; end if;
      v_graded := v_graded + 1;
      v_ok := jz_normalize(rec.ans #>> '{}') = jz_normalize(v_word);
      if v_ok then v_correct := v_correct + 1; end if;

      -- Agenda SM-2 lite.
      select coalesce(strength, 0) into v_strength from user_vocab_srs
        where user_id = uid and vocab_id = rec.vid;
      if v_ok then
        v_strength := least(coalesce(v_strength, 0) + 1, 5);
      else
        v_strength := 0;
      end if;
      v_interval := case v_strength::int when 0 then 1 when 1 then 2 when 2 then 4
                                         when 3 then 8 when 4 then 16 else 30 end;
      insert into user_vocab_srs (user_id, vocab_id, strength, interval_days, due_at, last_reviewed_at)
      values (uid, rec.vid, v_strength, v_interval, now() + (v_interval || ' days')::interval, now())
      on conflict (user_id, vocab_id) do update set
        strength = excluded.strength, interval_days = excluded.interval_days,
        due_at = excluded.due_at, last_reviewed_at = now(), updated_at = now();
    end loop;

  else
    -- Modos de banco: re-calificar con jz_grade y sumar puntos a la skill.
    create temp table _pg on commit drop as
    select ci.skill,
           jz_is_stub(ci.type) as is_stub,
           case when jz_is_stub(ci.type) then null
                else jz_grade(ci.type, ci.correct_answer, e.elem -> 'answer') end as correct
    from jsonb_array_elements(p_answers) as e(elem)
    join content_items ci on ci.id = (e.elem ->> 'item_id')::uuid;

    select count(*) filter (where not is_stub), count(*) filter (where correct)
      into v_graded, v_correct from _pg;

    -- Puntos por skill (práctica: +6 por acierto; nivela a los 100).
    for rec in
      select skill, sum(case when correct then 6 else 0 end)::numeric pts
      from _pg group by skill having sum(case when correct then 6 else 0 end) > 0
    loop
      insert into user_skill_levels (user_id, course_id, skill, cefr_level, progress_points)
      values (uid, v_course, rec.skill, 'A1', 0)
      on conflict (user_id, course_id, skill) do nothing;
      select progress_points + rec.pts, cefr_level into v_new_points, v_new_cefr
        from user_skill_levels where user_id = uid and course_id = v_course and skill = rec.skill;
      if v_new_points >= 100 then
        v_new_cefr := jz_next_cefr(v_new_cefr); v_new_points := v_new_points - 100;
      end if;
      update user_skill_levels set progress_points = v_new_points, cefr_level = v_new_cefr, updated_at = now()
        where user_id = uid and course_id = v_course and skill = rec.skill;
    end loop;
  end if;

  -- Economía (tope 20 XP, menos que una lección).
  v_xp := least(v_correct * 3, 20);
  v_gold := case when v_correct > 0 then 2 else 0 end;

  insert into user_stats (user_id) values (uid) on conflict (user_id) do nothing;
  update user_stats set xp_total = xp_total + v_xp, gold = gold + v_gold, updated_at = now()
    where user_id = uid;
  update user_course_progress set xp_total = xp_total + v_xp, updated_at = now()
    where user_id = uid and course_id = v_course;
  if v_gold > 0 then
    insert into gold_transactions (user_id, amount, reason) values (uid, v_gold, 'challenge');
  end if;

  v_activity := jz_register_activity(uid, v_course, v_xp);

  return jsonb_build_object(
    'mode', p_mode,
    'graded', v_graded,
    'correct', v_correct,
    'accuracy', case when v_graded > 0 then round(v_correct::numeric / v_graded, 2) else 0 end,
    'xp_earned', v_xp,
    'gold_earned', v_gold,
    'streak', (v_activity ->> 'streak')::int,
    'streak_advanced', (v_activity ->> 'streak_advanced')::boolean,
    'goal_met', (v_activity ->> 'goal_met')::boolean);
end $$;

grant execute on function start_practice(text, text) to authenticated;
grant execute on function submit_practice(text, jsonb) to authenticated;
