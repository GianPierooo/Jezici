-- ============================================================================
-- Jezici · Migración 040 · Lógica de niveles: DOMINIO + examen-gated + refuerzo
--                          + rehacer  (diseño docs/LEVELS_DESIGN.md, D6–D9)
-- ----------------------------------------------------------------------------
-- Reemplaza el modelo "100 puntos → jz_next_cefr (auto-nivel)" por dos capas:
--   CAPA 1 · DOMINIO  : las lecciones suben `user_skill_mastery` por (skill,nivel).
--   CAPA 2 · EXAMEN   : el dominio alto DESBLOQUEA el examen; el cefr_level SÓLO
--                       cambia al APROBAR el examen (único punto de subida).
-- Sin deadlock: la compuerta del examen mira DOMINIO (no el nivel) — ver §⚠ del
-- diseño. Refuerzo (D8) recomienda, no bloquea. Rehacer (D9) re-evalúa débiles y
-- da XP reducido. Migra a los usuarios del modelo viejo sin regresión (abajo).
-- Todo server-side (Arquitectura §4/§7): el cliente nunca decide nivel/XP/oro.
-- ============================================================================

-- ── 1. Tablas ────────────────────────────────────────────────────────────────

-- Dominio agregado por (usuario, curso, habilidad, nivel). Base de las barras.
create table if not exists user_skill_mastery (
  user_id       uuid not null references users(id)   on delete cascade,
  course_id     uuid not null references courses(id) on delete cascade,
  skill         skill not null,
  cefr_level    cefr_level not null,
  items_seen    int not null default 0,
  items_correct int not null default 0,
  lessons_done  int not null default 0,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  primary key (user_id, course_id, skill, cefr_level)
);

-- Intentos por ítem: alimenta el modo "Reforzar" (re-evaluar sólo los fallados).
create table if not exists user_item_attempts (
  user_id       uuid not null references users(id)         on delete cascade,
  item_id       uuid not null references content_items(id) on delete cascade,
  attempts      int not null default 0,
  correct_count int not null default 0,
  last_correct  boolean not null default false,
  last_seen_at  timestamptz not null default now(),
  primary key (user_id, item_id)
);
create index if not exists user_item_attempts_weak_idx
  on user_item_attempts (user_id, last_correct);

alter table user_skill_mastery enable row level security;
alter table user_item_attempts enable row level security;

drop policy if exists "usm_select_own" on user_skill_mastery;
create policy "usm_select_own" on user_skill_mastery for select to authenticated
  using (auth.uid() = user_id);
drop policy if exists "uia_select_own" on user_item_attempts;
create policy "uia_select_own" on user_item_attempts for select to authenticated
  using (auth.uid() = user_id);

-- ── 2. Helpers ───────────────────────────────────────────────────────────────

-- % de dominio de un nivel: 16 aciertos ≈ dominado (least(1, correct/16)).
create or replace function jz_mastery_pct(p_correct int)
returns numeric language sql immutable as $$
  select round(least(1.0, greatest(0, coalesce(p_correct, 0)) / 16.0), 4)
$$;

-- Upsert/incremento de dominio para (usuario, skill, nivel).
create or replace function jz_record_mastery(
  p_uid uuid, p_course uuid, p_skill skill, p_level cefr_level,
  p_seen int, p_correct int, p_lessons int default 0)
returns void language plpgsql security definer set search_path = public as $$
begin
  insert into user_skill_mastery (user_id, course_id, skill, cefr_level,
                                  items_seen, items_correct, lessons_done)
  values (p_uid, p_course, p_skill, p_level,
          greatest(0, coalesce(p_seen, 0)), greatest(0, coalesce(p_correct, 0)),
          greatest(0, coalesce(p_lessons, 0)))
  on conflict (user_id, course_id, skill, cefr_level) do update set
    items_seen    = user_skill_mastery.items_seen    + excluded.items_seen,
    items_correct = user_skill_mastery.items_correct + excluded.items_correct,
    lessons_done  = user_skill_mastery.lessons_done  + excluded.lessons_done,
    updated_at    = now();
end $$;

-- Registra un intento por ítem (para el modo Reforzar).
create or replace function jz_record_item(p_uid uuid, p_item uuid, p_ok boolean)
returns void language plpgsql security definer set search_path = public as $$
begin
  insert into user_item_attempts (user_id, item_id, attempts, correct_count,
                                  last_correct, last_seen_at)
  values (p_uid, p_item, 1, case when p_ok then 1 else 0 end, coalesce(p_ok, false), now())
  on conflict (user_id, item_id) do update set
    attempts      = user_item_attempts.attempts + 1,
    correct_count = user_item_attempts.correct_count + case when p_ok then 1 else 0 end,
    last_correct  = coalesce(p_ok, false),
    last_seen_at  = now();
end $$;

-- D8 · Puntaje de necesidad de refuerzo por habilidad (0..1; mayor = más urgente).
-- Combina: (1−precisión del nivel en curso) + rezago vs la habilidad más fuerte
-- + presión global de SRS vencido. RECOMIENDA, no bloquea.
create or replace function jz_reinforce_score(p_uid uuid, p_course uuid, p_skill skill)
returns numeric language plpgsql stable security definer set search_path = public as $$
declare
  v_level text;
  v_seen int; v_correct int;
  v_low_acc numeric; v_mp numeric; v_max_mp numeric; v_lag numeric;
  v_due int; v_srs numeric;
begin
  v_level := jz_resolve_exam_level(p_uid, p_course);

  select items_seen, items_correct into v_seen, v_correct
  from user_skill_mastery
  where user_id = p_uid and course_id = p_course and skill = p_skill
    and cefr_level = v_level::cefr_level;

  v_low_acc := case when coalesce(v_seen, 0) > 0
                    then 1 - (v_correct::numeric / v_seen) else 0.5 end;
  v_mp := jz_mastery_pct(v_correct);

  select max(jz_mastery_pct(items_correct)) into v_max_mp
  from user_skill_mastery
  where user_id = p_uid and course_id = p_course and cefr_level = v_level::cefr_level;
  v_lag := greatest(0, coalesce(v_max_mp, 0) - v_mp);

  select count(*) into v_due
  from user_vocab_srs s join vocabulary v on v.id = s.vocab_id
  where s.user_id = p_uid and v.course_id = p_course
    and s.due_at is not null and s.due_at <= now();
  v_srs := least(1.0, coalesce(v_due, 0) / 12.0);

  return round(least(1.0, 0.5 * v_low_acc + 0.35 * v_lag + 0.15 * v_srs), 4);
end $$;

-- ── 3. complete_lesson (re-emitida): DOMINIO en vez de auto-nivel + rehacer ───
create or replace function complete_lesson(p_lesson_id uuid, p_answers jsonb)
returns jsonb language plpgsql security definer set search_path = public as $$
declare
  uid uuid := auth.uid();
  v_course uuid; v_unit uuid; v_order int; v_xp_reward int;
  v_graded int := 0; v_correct int := 0;
  v_combo int := 0; v_max_combo int := 0; v_combo_bonus int := 0;
  v_acc numeric := 0; v_xp int := 0; v_gold int := 5;
  v_status lesson_progress_status; v_next uuid; v_activity jsonb;
  v_prev_completed int := 0; v_is_redo boolean := false;
  rec record; v_skills jsonb := '[]'::jsonb;
begin
  if uid is null then raise exception 'auth required'; end if;

  select u.course_id, l.unit_id, l.order_index, l.xp_reward
    into v_course, v_unit, v_order, v_xp_reward
  from lessons l join units u on u.id = l.unit_id where l.id = p_lesson_id;
  if v_course is null then raise exception 'lesson not found'; end if;

  -- Rehacer (D9): si ya estaba completada antes, el XP se reduce a 30%.
  select coalesce(times_completed, 0) into v_prev_completed
  from user_lesson_progress where user_id = uid and lesson_id = p_lesson_id;
  v_is_redo := coalesce(v_prev_completed, 0) > 0;

  insert into user_course_progress (user_id, course_id, current_unit_id, current_lesson_id)
  values (uid, v_course, v_unit, p_lesson_id) on conflict (user_id, course_id) do nothing;
  insert into user_skill_levels (user_id, course_id, skill, cefr_level, progress_points)
  select uid, v_course, s::skill, 'A1', 0
  from unnest(array['reading','listening','writing','speaking']) s
  on conflict (user_id, course_id, skill) do nothing;

  create temp table _g on commit drop as
  select ci.id as item_id, ci.skill, ci.cefr_level,
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
      v_correct := v_correct + 1; v_combo := v_combo + 1;
      if v_combo > v_max_combo then v_max_combo := v_combo; end if;
      if v_combo >= 3 then v_combo_bonus := v_combo_bonus + 2; end if;
    else
      v_combo := 0;
    end if;
  end loop;

  v_acc := case when v_graded > 0 then v_correct::numeric / v_graded else 0 end;
  v_xp := case when v_graded > 0 then round(v_xp_reward * v_acc)::int + v_combo_bonus
               else v_combo_bonus end;
  if v_is_redo then v_xp := round(v_xp * 0.3)::int; end if;   -- D9: XP reducido al rehacer
  v_gold := case when v_is_redo then 2
                 when v_graded > 0 and v_acc >= 0.8 then 10 else 5 end;
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

  v_activity := jz_register_activity(uid, v_course, v_xp);

  -- CAPA 1 · DOMINIO: por (skill, nivel DEL ÍTEM) sube user_skill_mastery.
  for rec in
    select skill, cefr_level,
           count(*) filter (where not is_stub)::int as seen,
           count(*) filter (where correct)::int as correct_cnt
    from _g group by skill, cefr_level
  loop
    perform jz_record_mastery(uid, v_course, rec.skill, rec.cefr_level,
                              rec.seen, rec.correct_cnt, 1);
  end loop;

  -- Intentos por ítem (para Reforzar): marca aciertos/fallos de los calificables.
  for rec in select item_id, correct from _g where not is_stub loop
    perform jz_record_item(uid, rec.item_id, coalesce(rec.correct, false));
  end loop;

  -- Resumen de habilidades que avanzaron (para la UI): skill + % de dominio al día.
  select coalesce(jsonb_agg(jsonb_build_object(
           'skill', g.skill, 'cefr_level', g.cefr_level,
           'mastery_pct', jz_mastery_pct(m.items_correct)) order by g.skill), '[]'::jsonb)
    into v_skills
  from (select distinct skill, cefr_level from _g where not is_stub) g
  join user_skill_mastery m on m.user_id = uid and m.course_id = v_course
       and m.skill = g.skill and m.cefr_level = g.cefr_level;

  select id into v_next from lessons
   where unit_id = v_unit and order_index > v_order order by order_index limit 1;
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
    'lesson_id', p_lesson_id, 'status', v_status, 'graded', v_graded, 'correct', v_correct,
    'accuracy', v_acc, 'xp_earned', v_xp, 'gold_earned', v_gold, 'is_redo', v_is_redo,
    'combo_bonus', v_combo_bonus, 'max_combo', v_max_combo,
    'xp_total', (select xp_total from user_stats where user_id = uid),
    'gold_total', (select gold from user_stats where user_id = uid),
    'streak', (v_activity ->> 'streak')::int,
    'streak_advanced', (v_activity ->> 'streak_advanced')::boolean,
    'goal_met', (v_activity ->> 'goal_met')::boolean,
    'daily_goal_xp', (v_activity ->> 'goal_xp')::int,
    'daily_xp_earned', (v_activity ->> 'xp_earned_today')::int,
    'milestone', (v_activity ->> 'milestone')::int,
    'next_lesson_id', v_next, 'skills', v_skills);
end $$;

-- ── 4. submit_checkpoint (re-emitida): DOMINIO en vez de auto-nivel ───────────
create or replace function submit_checkpoint(
  p_lesson_id uuid, p_answers jsonb, p_time_taken_sec int default null)
returns jsonb language plpgsql security definer set search_path = public as $$
declare
  uid uuid := auth.uid();
  v_course uuid; v_unit uuid; v_order int; v_cefr cefr_level; v_xp_reward int;
  v_graded int := 0; v_correct int := 0; v_acc numeric := 0; v_passed boolean := false;
  v_exam uuid; v_attempt_no int; v_xp int := 0; v_gold int := 0;
  v_status lesson_progress_status; v_next uuid; v_per_skill jsonb; v_weak jsonb;
  v_activity jsonb; rec record;
begin
  if uid is null then raise exception 'auth required'; end if;

  select u.course_id, l.unit_id, l.order_index, u.cefr_level, l.xp_reward
    into v_course, v_unit, v_order, v_cefr, v_xp_reward
  from lessons l join units u on u.id = l.unit_id where l.id = p_lesson_id;
  if v_course is null then raise exception 'lesson not found'; end if;

  insert into user_course_progress (user_id, course_id, current_unit_id, current_lesson_id)
  values (uid, v_course, v_unit, p_lesson_id) on conflict (user_id, course_id) do nothing;
  insert into user_skill_levels (user_id, course_id, skill, cefr_level, progress_points)
  select uid, v_course, s::skill, 'A1', 0 from unnest(array['reading','listening','writing','speaking']) s
  on conflict (user_id, course_id, skill) do nothing;

  create temp table _g on commit drop as
  select ci.id as item_id, ci.skill, ci.cefr_level,
         jz_is_stub(ci.type) as is_stub,
         case when jz_is_stub(ci.type) then null
              else jz_grade(ci.type, ci.correct_answer, a.elem -> 'answer') end as correct
  from jsonb_array_elements(p_answers) as a(elem)
  join content_items ci on ci.id = (a.elem ->> 'item_id')::uuid;

  select count(*) filter (where not is_stub), count(*) filter (where correct)
    into v_graded, v_correct from _g;
  v_acc := case when v_graded > 0 then v_correct::numeric / v_graded else 0 end;
  v_passed := v_graded > 0 and v_acc >= 0.80;

  select jsonb_agg(jsonb_build_object(
           'skill', skill, 'total', total, 'correct', correct_cnt, 'graded', graded_cnt,
           'accuracy', case when graded_cnt > 0 then round(correct_cnt::numeric / graded_cnt, 2) else null end)
         order by skill) into v_per_skill
  from (select skill, count(*) total, count(*) filter (where not is_stub) graded_cnt,
               count(*) filter (where correct) correct_cnt
        from _g group by skill) s;

  select coalesce(jsonb_agg(skill), '[]'::jsonb) into v_weak
  from (select skill, count(*) filter (where not is_stub) g, count(*) filter (where correct) c
        from _g group by skill) s where g > 0 and c::numeric / g < 0.80;

  select id into v_exam from exams
   where course_id = v_course and type = 'checkpoint' and unit_id = v_unit limit 1;
  if v_exam is null then
    insert into exams (course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold)
    values (v_course, 'checkpoint', v_cefr, v_unit, 300, 0.80) returning id into v_exam;
  end if;

  insert into exam_attempts (user_id, exam_id, started_at, finished_at, score_global, per_skill_results, passed)
  values (uid, v_exam, now() - (coalesce(p_time_taken_sec, 0) || ' seconds')::interval,
          now(), v_acc, v_per_skill, v_passed);
  select count(*) into v_attempt_no from exam_attempts where user_id = uid and exam_id = v_exam;

  -- DOMINIO + intentos por ítem: se registran SIEMPRE (aprobado o no): refleja
  -- lo demostrado en el checkpoint y alimenta refuerzo.
  for rec in
    select skill, cefr_level, count(*) filter (where not is_stub)::int seen, count(*) filter (where correct)::int ok
    from _g group by skill, cefr_level
  loop
    perform jz_record_mastery(uid, v_course, rec.skill, rec.cefr_level, rec.seen, rec.ok, 0);
  end loop;
  for rec in select item_id, correct from _g where not is_stub loop
    perform jz_record_item(uid, rec.item_id, coalesce(rec.correct, false));
  end loop;

  if v_passed then
    v_xp := v_xp_reward; v_gold := 30;
    v_status := case when v_acc >= 1 then 'golden' else 'completed' end::lesson_progress_status;

    insert into user_lesson_progress (user_id, lesson_id, status, best_accuracy, times_completed, completed_at)
    values (uid, p_lesson_id, v_status, v_acc, 1, now())
    on conflict (user_id, lesson_id) do update set
      status = case when user_lesson_progress.status = 'golden' then 'golden' else excluded.status end,
      best_accuracy = greatest(coalesce(user_lesson_progress.best_accuracy, 0), excluded.best_accuracy),
      times_completed = user_lesson_progress.times_completed + 1, completed_at = now();

    update user_course_progress set xp_total = xp_total + v_xp, updated_at = now()
     where user_id = uid and course_id = v_course;
    update user_stats set xp_total = xp_total + v_xp, gold = gold + v_gold, updated_at = now()
     where user_id = uid;
    insert into gold_transactions (user_id, amount, reason) values (uid, v_gold, 'challenge');
    v_activity := jz_register_activity(uid, v_course, v_xp);

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
    'passed', v_passed, 'score_global', v_acc, 'threshold', 0.80, 'attempt_number', v_attempt_no,
    'graded', v_graded, 'correct', v_correct, 'xp_earned', v_xp, 'gold_earned', v_gold,
    'per_skill', coalesce(v_per_skill, '[]'::jsonb), 'weaknesses', v_weak,
    'next_unlocked', v_next is not null, 'unit_id', v_unit,
    'streak', coalesce((v_activity ->> 'streak')::int, 0),
    'streak_advanced', coalesce((v_activity ->> 'streak_advanced')::boolean, false),
    'goal_met', coalesce((v_activity ->> 'goal_met')::boolean, false),
    'milestone', coalesce((v_activity ->> 'milestone')::int, 0));
end $$;

-- ── 5. submit_practice (re-emitida): sin auto-nivel; suma dominio + ítems ──────
create or replace function submit_practice(p_mode text, p_answers jsonb)
returns jsonb language plpgsql security definer set search_path = public as $$
declare
  uid uuid := auth.uid();
  v_course uuid; v_graded int := 0; v_correct int := 0; v_xp int := 0; v_gold int := 0;
  v_activity jsonb; rec record; v_word text; v_ok boolean; v_strength numeric; v_interval int;
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
      select coalesce(strength, 0) into v_strength from user_vocab_srs
        where user_id = uid and vocab_id = rec.vid;
      if v_ok then v_strength := least(coalesce(v_strength, 0) + 1, 5); else v_strength := 0; end if;
      v_interval := case v_strength::int when 0 then 1 when 1 then 2 when 2 then 4
                                         when 3 then 8 when 4 then 16 else 30 end;
      insert into user_vocab_srs (user_id, vocab_id, strength, interval_days, due_at, last_reviewed_at)
      values (uid, rec.vid, v_strength, v_interval, now() + (v_interval || ' days')::interval, now())
      on conflict (user_id, vocab_id) do update set
        strength = excluded.strength, interval_days = excluded.interval_days,
        due_at = excluded.due_at, last_reviewed_at = now(), updated_at = now();
    end loop;

  else
    -- Modos de banco: re-califica, registra DOMINIO + intentos por ítem (sin auto-nivel).
    create temp table _pg on commit drop as
    select ci.id as item_id, ci.skill, ci.cefr_level,
           jz_is_stub(ci.type) as is_stub,
           case when jz_is_stub(ci.type) then null
                else jz_grade(ci.type, ci.correct_answer, e.elem -> 'answer') end as correct
    from jsonb_array_elements(p_answers) as e(elem)
    join content_items ci on ci.id = (e.elem ->> 'item_id')::uuid;

    select count(*) filter (where not is_stub), count(*) filter (where correct)
      into v_graded, v_correct from _pg;

    for rec in
      select skill, cefr_level, count(*) filter (where not is_stub)::int seen, count(*) filter (where correct)::int ok
      from _pg group by skill, cefr_level
    loop
      perform jz_record_mastery(uid, v_course, rec.skill, rec.cefr_level, rec.seen, rec.ok, 0);
    end loop;
    for rec in select item_id, correct from _pg where not is_stub loop
      perform jz_record_item(uid, rec.item_id, coalesce(rec.correct, false));
    end loop;
  end if;

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
    'mode', p_mode, 'graded', v_graded, 'correct', v_correct,
    'accuracy', case when v_graded > 0 then round(v_correct::numeric / v_graded, 2) else 0 end,
    'xp_earned', v_xp, 'gold_earned', v_gold,
    'streak', (v_activity ->> 'streak')::int,
    'streak_advanced', (v_activity ->> 'streak_advanced')::boolean,
    'goal_met', (v_activity ->> 'goal_met')::boolean);
end $$;

-- ── 6. jz_level_status (re-emitida): compuerta por DOMINIO (sin deadlock) ──────
create or replace function jz_level_status(p_uid uuid, p_course uuid, p_level text)
returns jsonb language plpgsql as $$
declare
  v_total int; v_done int; v_skills_ok boolean; v_has_cert boolean; v_mastery numeric;
begin
  select count(*) into v_total
  from units u where u.course_id = p_course and u.cefr_level = p_level::cefr_level
    and exists (select 1 from lessons l where l.unit_id = u.id and l.type = 'checkpoint');

  select count(distinct u.id) into v_done
  from user_lesson_progress ulp
  join lessons l on l.id = ulp.lesson_id join units u on u.id = l.unit_id
  where ulp.user_id = p_uid and l.type = 'checkpoint' and ulp.status in ('completed','golden')
    and u.course_id = p_course and u.cefr_level = p_level::cefr_level;

  -- skills_ok = promedio de mastery_pct de las 4 habilidades al nivel objetivo >= 0.5.
  select coalesce(avg(jz_mastery_pct(coalesce(m.items_correct, 0))), 0) into v_mastery
  from unnest(array['reading','listening','writing','speaking']) s(skill)
  left join user_skill_mastery m
    on m.user_id = p_uid and m.course_id = p_course
   and m.skill = s.skill::skill and m.cefr_level = p_level::cefr_level;
  v_skills_ok := v_mastery >= 0.5;

  select exists(select 1 from certificates where user_id = p_uid and cefr_level = p_level::cefr_level)
    into v_has_cert;

  return jsonb_build_object(
    'level', p_level, 'units_total', v_total, 'units_done', v_done,
    'skills_ok', coalesce(v_skills_ok, false), 'mastery_avg', round(v_mastery, 3),
    'unlocked', (v_total > 0 and v_done >= v_total and coalesce(v_skills_ok, false)),
    'has_certificate', v_has_cert);
end $$;

-- ── 7. submit_level_exam (re-emitida): al APROBAR sube cefr_level (único punto) ─
create or replace function submit_level_exam(p_answers jsonb, p_time_taken_sec int default null, p_level text default null)
returns jsonb language plpgsql security definer set search_path = public as $$
declare
  uid uuid := auth.uid();
  v_course uuid; v_level text; v_exam uuid;
  v_graded int; v_correct int; v_acc numeric; v_passed boolean;
  v_per_skill jsonb; v_weak jsonb; v_xp int := 0; v_gold int := 0;
  v_name text; v_folio text; v_code text; v_svg text; v_cert jsonb := null;
  v_existing certificates%rowtype; v_leveled boolean := false; v_raised int := 0;
begin
  if uid is null then raise exception 'auth required'; end if;
  select id into v_course from courses where is_active order by created_at limit 1;
  v_level := coalesce(p_level, jz_resolve_exam_level(uid, v_course));

  -- Compuerta server-side TAMBIÉN al enviar (no sólo en start_level_exam): como
  -- submit es ahora el ÚNICO punto que sube el nivel, un atajo de cliente que
  -- llame directo NO debe poder certificar saltándose el dominio. Si ya está
  -- certificado, lo dejamos pasar (idempotente: devuelve el cert existente).
  if not (jz_level_status(uid, v_course, v_level) ->> 'unlocked')::boolean
     and not exists (select 1 from certificates where user_id = uid and cefr_level = v_level::cefr_level)
  then
    raise exception 'level exam locked';
  end if;

  v_exam := ('50000000-0000-0000-0000-0000000000' || lower(v_level))::uuid;

  insert into exams (id, course_id, type, cefr_level, time_limit_sec, pass_threshold, sections)
  values (v_exam, v_course, 'level', v_level::cefr_level, 600, 0.80,
          '{"skills":["reading","listening","writing","speaking"],"item_count":20}'::jsonb)
  on conflict (id) do nothing;

  create temp table _le on commit drop as
  select ci.skill, jz_is_stub(ci.type) as is_stub,
         case when jz_is_stub(ci.type) then null
              else jz_grade(ci.type, ci.correct_answer, a.elem -> 'answer') end as correct
  from jsonb_array_elements(p_answers) as a(elem)
  join content_items ci on ci.id = (a.elem ->> 'item_id')::uuid;

  select count(*) filter (where not is_stub), count(*) filter (where correct)
    into v_graded, v_correct from _le;
  v_acc := case when v_graded > 0 then v_correct::numeric / v_graded else 0 end;
  v_passed := v_graded > 0 and v_acc >= 0.80;

  select jsonb_agg(jsonb_build_object('skill', skill, 'total', total, 'graded', g, 'correct', c,
           'accuracy', case when g > 0 then round(c::numeric / g, 2) else null end) order by skill)
    into v_per_skill
  from (select skill, count(*) total, count(*) filter (where not is_stub) g, count(*) filter (where correct) c
        from _le group by skill) s;

  select coalesce(jsonb_agg(skill), '[]'::jsonb) into v_weak
  from (select skill, count(*) filter (where not is_stub) g, count(*) filter (where correct) c
        from _le group by skill) s where g > 0 and c::numeric / g < 0.80;

  insert into exam_attempts (user_id, exam_id, started_at, finished_at, score_global, per_skill_results, passed)
  values (uid, v_exam, now() - (coalesce(p_time_taken_sec, 0) || ' seconds')::interval, now(), v_acc, v_per_skill, v_passed);

  if v_passed then
    v_xp := 200; v_gold := 100;
    insert into user_stats (user_id) values (uid) on conflict (user_id) do nothing;
    update user_stats set xp_total = xp_total + v_xp, gold = gold + v_gold, updated_at = now() where user_id = uid;
    update user_course_progress set xp_total = xp_total + v_xp, updated_at = now() where user_id = uid and course_id = v_course;
    insert into gold_transactions (user_id, amount, reason) values (uid, v_gold, 'challenge');
    perform jz_register_activity(uid, v_course, v_xp);

    -- ÚNICO punto donde sube el nivel: las 4 habilidades pasan a N (sólo si suben).
    update user_skill_levels set cefr_level = v_level::cefr_level, progress_points = 0, updated_at = now()
     where user_id = uid and course_id = v_course
       and array_position(array['A1','A2','B1','B2','C1','C2']::text[], cefr_level::text)
           < array_position(array['A1','A2','B1','B2','C1','C2']::text[], v_level);
    get diagnostics v_raised = row_count;
    v_leveled := v_raised > 0;

    -- Certificado: uno por (usuario, nivel).
    select * into v_existing from certificates where user_id = uid and cefr_level = v_level::cefr_level limit 1;
    if v_existing.id is null then
      select coalesce(nullif(display_name, ''), nullif(name, ''), 'Aprendiz') into v_name from users where id = uid;
      v_name := coalesce(v_name, 'Aprendiz');
      v_folio := 'JZC-' || v_level || '-' || to_char(now(), 'YYYYMMDD') || '-' || upper(left(md5(uid::text || now()::text), 5));
      v_code := upper(left(md5(uid::text || 'verify' || now()::text), 10));
      v_svg := jz_cert_svg(v_name, v_level, v_folio, v_code, to_char(now(), 'DD/MM/YYYY'));
      insert into certificates (user_id, course_id, cefr_level, folio, verification_code, pdf_url)
      values (uid, v_course, v_level::cefr_level, v_folio, v_code, v_svg)
      returning * into v_existing;
    end if;
    v_cert := jsonb_build_object('cefr_level', v_existing.cefr_level, 'folio', v_existing.folio,
      'verification_code', v_existing.verification_code, 'issued_at', v_existing.issued_at, 'svg', v_existing.pdf_url);
  end if;

  return jsonb_build_object(
    'passed', v_passed, 'level', v_level, 'score_global', v_acc, 'threshold', 0.80,
    'graded', v_graded, 'correct', v_correct, 'xp_earned', v_xp, 'gold_earned', v_gold,
    'leveled_up', v_leveled, 'new_level', case when v_leveled then v_level else null end,
    'per_skill', coalesce(v_per_skill, '[]'::jsonb), 'weaknesses', v_weak, 'certificate', v_cert);
end $$;

-- ── 8. get_skill_mastery: estado de dominio por habilidad para la app ─────────
create or replace function get_skill_mastery()
returns jsonb language plpgsql security definer set search_path = public as $$
declare
  uid uuid := auth.uid();
  v_course uuid; v_level text; v_skills jsonb;
begin
  if uid is null then raise exception 'auth required'; end if;
  select id into v_course from courses where is_active order by created_at limit 1;
  v_level := jz_resolve_exam_level(uid, v_course);

  insert into user_skill_levels (user_id, course_id, skill, cefr_level, progress_points)
  select uid, v_course, s::skill, 'A1', 0 from unnest(array['reading','listening','writing','speaking']) s
  on conflict (user_id, course_id, skill) do nothing;

  select jsonb_agg(jsonb_build_object(
           'skill', s.skill,
           'certified_level', usl.cefr_level,
           'working_level', v_level,
           'mastery_pct', jz_mastery_pct(coalesce(m.items_correct, 0)),
           'reinforce_score', jz_reinforce_score(uid, v_course, s.skill::skill))
         order by array_position(array['reading','listening','writing','speaking'], s.skill))
    into v_skills
  from unnest(array['reading','listening','writing','speaking']) s(skill)
  left join user_skill_levels usl
    on usl.user_id = uid and usl.course_id = v_course and usl.skill = s.skill::skill
  left join user_skill_mastery m
    on m.user_id = uid and m.course_id = v_course and m.skill = s.skill::skill
   and m.cefr_level = v_level::cefr_level;

  return jsonb_build_object(
    'working_level', v_level,
    'exam', jz_level_status(uid, v_course, v_level),
    'skills', coalesce(v_skills, '[]'::jsonb));
end $$;

-- ── 9. start_practice (re-emitida): + modo reinforce_unit; weakness por score ──
drop function if exists start_practice(text, text);
create or replace function start_practice(p_mode text, p_skill text default null, p_unit uuid default null)
returns jsonb language plpgsql security definer set search_path = public as $$
declare
  uid uuid := auth.uid();
  v_course uuid; v_weak skill; v_items jsonb; v_due int := 0;
begin
  if uid is null then raise exception 'auth required'; end if;
  select id into v_course from courses where is_active order by created_at limit 1;

  if p_mode = 'srs' then
    with due as (
      select v.id, v.word, v.translation, (s.vocab_id is null) as isnew, s.due_at
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
      from ((select d.word as w)
            union all
            (select v2.word from vocabulary v2
              where v2.course_id = v_course and v2.word <> d.word order by random() limit 3)) q
    ) o;
    select count(*) into v_due from vocabulary v
      left join user_vocab_srs s on s.vocab_id = v.id and s.user_id = uid
      where v.course_id = v_course and (s.vocab_id is null or s.due_at is null or s.due_at <= now());

  elsif p_mode = 'reinforce_unit' then
    -- D9: re-evalúa SÓLO los ítems calificables fallados (último intento) de una
    -- unidad. Si p_unit es null, toma los débiles del curso entero.
    select jsonb_agg(jsonb_build_object(
             'id', x.id, 'type', x.type, 'skill', x.skill, 'cefr_level', x.cefr_level,
             'prompt', x.prompt, 'payload', x.payload, 'correct_answer', x.correct_answer))
      into v_items
    from (
      -- ua es 1:1 con el ítem (PK user_id,item_id) y la unidad va por EXISTS:
      -- sin multiplicación de filas, así que no hace falta DISTINCT (que choca
      -- con ORDER BY random()).
      select ci.id, ci.type, ci.skill, ci.cefr_level, ci.prompt, ci.payload, ci.correct_answer
      from content_items ci
      join user_item_attempts ua on ua.item_id = ci.id and ua.user_id = uid and ua.last_correct = false
      where not jz_is_stub(ci.type)
        and ci.course_id = v_course
        -- Acota al curso activo (y a la unidad si se pidió): user_item_attempts no
        -- guarda course_id, así evitamos mezclar cursos cuando haya más de uno.
        and (p_unit is null or exists (
              select 1 from lesson_items li join lessons l on l.id = li.lesson_id
              where li.item_id = ci.id and l.unit_id = p_unit))
      order by random() limit 12
    ) x;

  else
    if p_mode = 'weakness' then
      -- D8: la habilidad de MAYOR puntaje de refuerzo (no sólo el nivel más bajo).
      select s.skill::skill into v_weak
      from unnest(array['reading','listening','writing','speaking']) s(skill)
      order by jz_reinforce_score(uid, v_course, s.skill::skill) desc,
               array_position(array['reading','listening','writing','speaking'], s.skill)
      limit 1;
    end if;

    select jsonb_agg(jsonb_build_object(
             'id', id, 'type', type, 'skill', skill, 'cefr_level', cefr_level,
             'prompt', prompt, 'payload', payload, 'correct_answer', correct_answer))
      into v_items
    from (
      select id, type, skill, cefr_level, prompt, payload, correct_answer
      from content_items
      where course_id = v_course and not ('placement' = any(tags))
        and case when p_mode = 'weakness' then skill = v_weak
                 when p_mode = 'skill' then skill = p_skill::skill
                 when p_mode = 'timed' then type not in ('listening','speaking_read_aloud','dictation','guided_writing')
                 else true end
      order by random()
      limit case when p_mode = 'timed' then 20 else 10 end
    ) x;
  end if;

  return jsonb_build_object(
    'mode', p_mode, 'weakest_skill', v_weak, 'due_count', v_due,
    'item_count', coalesce(jsonb_array_length(v_items), 0),
    'items', coalesce(v_items, '[]'::jsonb));
end $$;

-- ── 10. Backfill de datos: migra usuarios del modelo de puntos al de dominio ───
-- Sin regresión: conserva su cefr_level; siembra dominio proporcional a sus
-- puntos en el nivel en curso; y honra los niveles ya superados con certificado
-- (en el modelo nuevo el nivel se certifica por examen — los puntos viejos
-- equivalían a "haber pasado"). Idempotente (guardas not-exists).
do $$
declare
  v_course uuid; r record; lv text; v_name text; v_folio text; v_code text; v_svg text;
begin
  select id into v_course from courses where is_active order by created_at limit 1;
  if v_course is null then return; end if;

  -- (a) Sembrar dominio proporcional a progress_points (sólo si no hay dominio aún).
  insert into user_skill_mastery (user_id, course_id, skill, cefr_level, items_seen, items_correct, lessons_done)
  select usl.user_id, usl.course_id, usl.skill, usl.cefr_level,
         round((least(usl.progress_points, 100) / 100.0) * 16)::int,
         round((least(usl.progress_points, 100) / 100.0) * 16)::int, 0
  from user_skill_levels usl
  where usl.course_id = v_course and usl.progress_points > 0
    and not exists (select 1 from user_skill_mastery m
                    where m.user_id = usl.user_id and m.course_id = usl.course_id
                      and m.skill = usl.skill and m.cefr_level = usl.cefr_level);

  -- (b) Certificar los niveles EXAMINABLES por debajo del cefr_level actual de cada
  --     usuario (los superó bajo el modelo viejo). Un cert por (usuario, nivel).
  for r in
    select distinct usl.user_id,
           min(array_position(array['A1','A2','B1','B2','C1','C2']::text[], usl.cefr_level::text)) as lvl_rank
    from user_skill_levels usl where usl.course_id = v_course
    group by usl.user_id
  loop
    foreach lv in array array['A1','A2','B1','B2','C1','C2'] loop
      exit when array_position(array['A1','A2','B1','B2','C1','C2']::text[], lv) >= r.lvl_rank;
      -- sólo niveles examinables (con unidades de checkpoint) y sin cert previo
      if exists (select 1 from units u join lessons l on l.unit_id = u.id
                 where u.course_id = v_course and u.cefr_level = lv::cefr_level and l.type = 'checkpoint')
         and not exists (select 1 from certificates c where c.user_id = r.user_id and c.cefr_level = lv::cefr_level)
      then
        select coalesce(nullif(display_name, ''), nullif(name, ''), 'Aprendiz') into v_name from users where id = r.user_id;
        v_name := coalesce(v_name, 'Aprendiz');
        v_folio := 'JZC-' || lv || '-MIG-' || upper(left(md5(r.user_id::text || lv), 6));
        v_code := upper(left(md5(r.user_id::text || 'verifymig' || lv), 10));
        v_svg := jz_cert_svg(v_name, lv, v_folio, v_code, to_char(now(), 'DD/MM/YYYY'));
        insert into certificates (user_id, course_id, cefr_level, folio, verification_code, pdf_url)
        values (r.user_id, v_course, lv::cefr_level, v_folio, v_code, v_svg)
        on conflict (folio) do nothing;
      end if;
    end loop;
  end loop;
end $$;

grant execute on function jz_mastery_pct(int) to authenticated;
grant execute on function jz_record_mastery(uuid, uuid, skill, cefr_level, int, int, int) to authenticated;
grant execute on function jz_record_item(uuid, uuid, boolean) to authenticated;
grant execute on function jz_reinforce_score(uuid, uuid, skill) to authenticated;
grant execute on function complete_lesson(uuid, jsonb) to authenticated;
grant execute on function submit_checkpoint(uuid, jsonb, int) to authenticated;
grant execute on function submit_practice(text, jsonb) to authenticated;
grant execute on function submit_level_exam(jsonb, int, text) to authenticated;
grant execute on function get_skill_mastery() to authenticated;
grant execute on function start_practice(text, text, uuid) to authenticated;
