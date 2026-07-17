-- SRS F2 · lesson_vocab: el VÍNCULO que faltaba entre lecciones y vocabulario
-- (PRACTICAR_SRS_ANALISIS §4 paso 2 · §1.2 "vocabulary es una ISLA"). Hoy la
-- inscripción del SRS es por substring sobre correct_answer/payload.text/say —
-- IMPRECISA: no lematiza y **no ve los pares de los `match`** (¡las palabras que la
-- lección realmente enseña!). F2 precomputa qué palabras enseña cada lección y
-- cambia la inscripción de "vistas" a usar ese mapa (fallback substring si falta).
-- Cero contenido nuevo: TODO derivado del contenido existente. Cero IA.

-- ── 1. Tabla (metadato de contenido, sin datos de usuario) ────────────────────
create table if not exists public.lesson_vocab (
  lesson_id uuid not null references public.lessons(id) on delete cascade,
  vocab_id  uuid not null references public.vocabulary(id) on delete cascade,
  position  int  not null default 0,   -- orden de introducción en la lección
  primary key (lesson_id, vocab_id)
);
create index if not exists lesson_vocab_lesson_idx on public.lesson_vocab(lesson_id);
create index if not exists lesson_vocab_vocab_idx  on public.lesson_vocab(vocab_id);
-- Solo lo leen funciones SECURITY DEFINER (la inscripción del SRS). RLS ON sin
-- política = acceso directo denegado (como vocab_images).
alter table public.lesson_vocab enable row level security;
revoke all on public.lesson_vocab from anon, authenticated;

-- ── 2. POBLARLA derivando del contenido (best-effort, token-exacto + pares) ────
-- Precomputa jz_normalize(word) UNA vez por palabra (vn). Une por:
--   (a) token exacto: cada palabra normalizada del texto del ítem == palabra;
--   (b) par de `match`: el término meta (clave 'en', frase completa) == palabra;
--   (c) multi-palabra en oración: substring whole-word (solo vocab con espacio).
insert into public.lesson_vocab (lesson_id, vocab_id, position)
with vn as (
  select id, course_id, jz_normalize(word) as nw,
         position(' ' in jz_normalize(word)) > 0 as is_multi
  from public.vocabulary
), item_text as (
  select li.lesson_id, u.course_id, li.order_index,
         translate(jz_normalize(t.txt), ',.;:!?¿¡"()[]{}', '               ') as ntxt
  from public.lesson_items li
  join public.content_items ci on ci.id = li.item_id
  join public.lessons l on l.id = li.lesson_id
  join public.units u on u.id = l.unit_id
  cross join lateral (values
    (ci.correct_answer ->> 'value'),
    (ci.payload ->> 'text'),
    (ci.payload ->> 'say'),
    (ci.prompt)
  ) as t(txt)
  where coalesce(t.txt, '') <> ''
), tok as (
  select it.lesson_id, it.course_id, it.order_index, w
  from item_text it
  cross join lateral regexp_split_to_table(it.ntxt, '\s+') as w
  where length(w) >= 2
), pair as (
  select li.lesson_id, u.course_id, li.order_index, jz_normalize(p ->> 'en') as w
  from public.lesson_items li
  join public.content_items ci on ci.id = li.item_id
  join public.lessons l on l.id = li.lesson_id
  join public.units u on u.id = l.unit_id
  cross join lateral jsonb_array_elements(ci.payload -> 'pairs') as p
  where ci.type = 'match' and coalesce(p ->> 'en', '') <> ''
), exact_m as (
  select c.lesson_id, v.id as vocab_id, c.order_index
  from (select lesson_id, course_id, order_index, w from tok
        union all
        select lesson_id, course_id, order_index, w from pair) c
  join vn v on v.course_id = c.course_id and v.nw = c.w
), multi_m as (
  select it.lesson_id, v.id as vocab_id, it.order_index
  from item_text it
  join vn v on v.course_id = it.course_id and v.is_multi
   and (' ' || it.ntxt || ' ') like ('%' || ' ' || v.nw || ' ' || '%')
), allm as (
  select * from exact_m union all select * from multi_m
)
select lesson_id, vocab_id, min(order_index) as position
from allm
group by lesson_id, vocab_id
on conflict (lesson_id, vocab_id) do nothing;

-- ── 3. jz_srs_enroll: ahora TAMBIÉN escanea los pares de `match` ──────────────
-- (antes solo correct_answer/payload.text/say/word → los match no inscribían nada).
-- Se usa para el camino FALLADO (item-level, prioridad) y como fallback de vistas.
create or replace function public.jz_srs_enroll(p_uid uuid, p_course uuid, p_item_ids uuid[], p_failed boolean)
 returns integer
 language plpgsql
 security definer
 set search_path to 'public'
as $function$
declare v_n int := 0;
begin
  if p_item_ids is null or array_length(p_item_ids, 1) is null then return 0; end if;

  with src as (
    select unnest(p_item_ids) as item_id
  ), texts as (
    -- Respuesta correcta + enunciado/oración del ítem…
    select t.txt from src s
    left join content_items ci on ci.id = s.item_id
    left join vocabulary vv on vv.id = s.item_id
    cross join lateral (values
      (ci.correct_answer ->> 'value'),
      (ci.payload ->> 'text'),
      (ci.payload ->> 'say'),
      (vv.word)
    ) as t(txt)
    where t.txt is not null
    union all
    -- …+ los términos meta de los pares de `match` (lo que faltaba).
    select p ->> 'en'
    from src s
    join content_items ci on ci.id = s.item_id
    cross join lateral jsonb_array_elements(ci.payload -> 'pairs') as p
    where ci.type = 'match' and coalesce(p ->> 'en', '') <> ''
  ), matched as (
    select distinct v.id as vocab_id
    from vocabulary v join texts t
      on (' ' || jz_normalize(t.txt) || ' ') like ('%' || ' ' || jz_normalize(v.word) || ' ' || '%')
    where v.course_id = p_course and length(jz_normalize(v.word)) >= 2
  )
  insert into user_vocab_srs (user_id, vocab_id, state, due_at, interval_days)
  select p_uid, vocab_id,
         case when p_failed then 'learning' else 'new' end,
         case when p_failed then now() else null end,
         0
  from matched
  on conflict (user_id, vocab_id) do update set
    due_at  = case when p_failed then now() else user_vocab_srs.due_at end,
    state   = case when p_failed and user_vocab_srs.state = 'new' then 'learning'
                   else user_vocab_srs.state end,
    updated_at = now()
  where p_failed;

  get diagnostics v_n = row_count;
  return v_n;
end $function$;

-- ── 4. jz_srs_enroll_lesson: inscripción PRECISA por lesson_vocab + fallback ──
-- VISTAS: las palabras que lesson_vocab dice que la lección enseña → state='new'
--   (no adelanta las ya agendadas). Si la lección NO tiene mapeo → fallback al
--   substring sobre los ítems (0 regresión). FALLADAS: item-level (prioridad now()),
--   ahora incluye los pares de match.
create or replace function public.jz_srs_enroll_lesson(
  p_uid uuid, p_course uuid, p_lesson uuid, p_seen_items uuid[], p_failed_items uuid[])
 returns integer
 language plpgsql
 security definer
 set search_path to 'public'
as $function$
declare v_mapped int := 0; v_n int := 0;
begin
  select count(*) into v_mapped from lesson_vocab where lesson_id = p_lesson;

  if v_mapped > 0 then
    -- VISTAS precisas desde el mapa (incluye lo que enseña el match).
    insert into user_vocab_srs (user_id, vocab_id, state, due_at, interval_days)
    select p_uid, lv.vocab_id, 'new', null, 0
    from lesson_vocab lv where lv.lesson_id = p_lesson
    on conflict (user_id, vocab_id) do nothing; -- no adelanta el repaso de las ya agendadas
    get diagnostics v_n = row_count;
  else
    -- Fallback: la lección no tiene mapeo → substring sobre los ítems vistos.
    v_n := jz_srs_enroll(p_uid, p_course, p_seen_items, false);
  end if;

  -- FALLADAS: prioridad due=now (item-level), best-effort.
  perform jz_srs_enroll(p_uid, p_course, p_failed_items, true);
  return v_n;
end $function$;

revoke all on function public.jz_srs_enroll_lesson(uuid, uuid, uuid, uuid[], uuid[]) from anon, authenticated;

-- ── 5. complete_lesson: usa la inscripción PRECISA (resto BYTE-idéntico) ──────
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
end $function$;
