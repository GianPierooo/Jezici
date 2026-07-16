-- SRS F0+F1 · CABLEADO: cola honesta + escritura + inscripción + rating 1-4.
-- Fuente: PRACTICAR_SRS_ANALISIS.md §6 (desacoplar motor/contenido) y §7 (F0/F1).
--
-- Lo que cambia (medido en el PASO 0 y confirmado contra la BD):
--  1. start_practice('srs') dejaba de ser un SRS: trataba las ~480 palabras del
--     curso como "vencidas" (s.vocab_id is null) y servía OPCIÓN MÚLTIPLE.
--     Ahora: solo palabras INSCRITAS + límite de nuevas/día (jz_config), y sirve
--     ESCRITURA (recuerdo activo).
--  2. DEGRADACIÓN CON GRACIA: si la palabra tiene una oración cloze usable →
--     tarjeta 'cloze' (con audio si existiera); si no → 'word' (traducción →
--     escribir la palabra). Medido hoy: solo 204/2868 (7.1%) tienen oración
--     (en 58 · pt 54 · nl 39 · de 28 · it 17 · fr 8) y NINGUNA tiene audio →
--     el banco de oraciones y su TTS son F3, no esta misión.
--  3. complete_lesson INSCRIBE en el SRS (best-effort, al final): hasta hoy el
--     SRS solo contenía lo que FALLABAS.
--  4. submit_practice acepta rating 1-4 (FSRS) y paga UNA vez por sesión.

-- ── 1. Inscripción compartida (la mecánica probada de srs_prioritize_failed) ──
-- Escanea el texto de los ítems y matchea palabras del vocabulario del curso.
-- Impreciso a propósito (no lematiza): inscribe DE MENOS, nunca basura.
--   p_failed=false → palabra VISTA  → state='new', due_at=NULL
--                    (el límite de nuevas/día controla cuándo se introduce)
--   p_failed=true  → palabra FALLADA → due_at=now (prioridad, entra ya)
create or replace function public.jz_srs_enroll(
  p_uid uuid, p_course uuid, p_item_ids uuid[], p_failed boolean
) returns int
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
    -- Texto a escanear: la respuesta correcta del ítem + su enunciado/oración.
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
    -- Una palabra ya inscrita solo se toca si FALLÓ (pasa a prioridad). Si ya
    -- estaba agendada y la VISTE en una lección, NO se adelanta su repaso:
    -- adelantarlo rompería el espaciado (el corazón del SRS).
    due_at  = case when p_failed then now() else user_vocab_srs.due_at end,
    state   = case when p_failed and user_vocab_srs.state = 'new' then 'learning'
                   else user_vocab_srs.state end,
    updated_at = now()
  where p_failed;

  get diagnostics v_n = row_count;
  return v_n;
end $function$;

revoke all on function public.jz_srs_enroll(uuid, uuid, uuid[], boolean) from anon, authenticated;

-- srs_prioritize_failed pasa a delegar en el helper (misma semántica pública).
create or replace function public.srs_prioritize_failed(p_item_ids uuid[])
returns integer
language plpgsql
security definer
set search_path to 'public'
as $function$
declare uid uuid := auth.uid();
begin
  if uid is null then raise exception 'auth required'; end if;
  return jz_srs_enroll(uid, jz_active_course(), p_item_ids, true);
end $function$;

-- ── 2. start_practice: rama 'srs' honesta + escritura ────────────────────────
create or replace function public.start_practice(
  p_mode text, p_skill text default null::text, p_unit uuid default null::uuid
) returns jsonb
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  uid uuid := auth.uid(); v_course uuid; v_weak skill; v_items jsonb; v_due int := 0;
  v_cards jsonb; v_new_left int; v_new_today int; v_max int; v_new_cap int;
begin
  if uid is null then raise exception 'auth required'; end if;
  select jz_active_course() into v_course;

  if p_mode = 'srs' then
    v_max     := jz_cfg('srs_max_per_session', 20);
    v_new_cap := jz_cfg('srs_new_per_day', 10);

    -- Nuevas ya introducidas HOY = reviews de hoy cuya tarjeta estaba en 'new'.
    select count(*) into v_new_today from srs_review_log
     where user_id = uid and state = 'new' and reviewed_at >= date_trunc('day', now());
    v_new_left := greatest(0, v_new_cap - v_new_today);

    -- VENCIDAS: solo palabras INSCRITAS con due_at vencido (ya no "las 480 del curso").
    select count(*) into v_due
      from user_vocab_srs s join vocabulary v on v.id = s.vocab_id
     where s.user_id = uid and v.course_id = v_course
       and s.state <> 'new' and s.due_at is not null and s.due_at <= now();

    with pool as (
      -- (a) vencidas, por antigüedad
      (select s.vocab_id, v.word, v.translation, v.frequency_rank, s.state, 0 as bucket
         from user_vocab_srs s join vocabulary v on v.id = s.vocab_id
        where s.user_id = uid and v.course_id = v_course
          and s.state <> 'new' and s.due_at is not null and s.due_at <= now()
        order by s.due_at limit v_max)
      union all
      -- (b) nuevas, por frecuencia (alta primero), con el límite diario
      (select s.vocab_id, v.word, v.translation, v.frequency_rank, s.state, 1 as bucket
         from user_vocab_srs s join vocabulary v on v.id = s.vocab_id
        where s.user_id = uid and v.course_id = v_course and s.state = 'new'
        order by v.frequency_rank nulls last limit greatest(v_new_left, 0))
    ), capped as (
      select * from pool order by bucket, frequency_rank nulls last limit v_max
    ), carded as (
      select c.*,
        -- DEGRADACIÓN CON GRACIA: ¿hay una oración cloze cuya respuesta es ESTA
        -- palabra? Si sí → tarjeta con contexto; si no → recuerdo escrito pelado.
        (select jsonb_build_object(
                  'sentence', ci.payload ->> 'text',
                  'audio_url', ci.payload ->> 'audio_url')
           from content_items ci
          where ci.course_id = v_course and ci.type = 'cloze'
            and ci.payload ->> 'text' is not null
            and jz_normalize(ci.correct_answer ->> 'value') = jz_normalize(c.word)
          limit 1) as ctx
      from capped c
    )
    select jsonb_agg(jsonb_build_object(
             'vocab_id', vocab_id,
             'word', word,
             'translation', translation,
             -- 'cloze' = escribir la palabra que falta en la oración
             -- 'word'  = escribir la palabra a partir de su traducción
             'kind', case when ctx is null then 'word' else 'cloze' end,
             'sentence', ctx ->> 'sentence',
             'audio_url', ctx ->> 'audio_url',
             'state', state,
             'is_new', (state = 'new')
           ) order by bucket, frequency_rank nulls last) into v_cards
      from carded;

    -- `items` queda VACÍO en modo srs (la tarjeta SRS tiene UI propia); un cliente
    -- viejo ve una sesión vacía, no un crash (degradación con gracia).
    return jsonb_build_object(
      'mode', p_mode, 'weakest_skill', null, 'due_count', v_due,
      'item_count', 0, 'items', '[]'::jsonb,
      'cards', coalesce(v_cards, '[]'::jsonb),
      'new_left', v_new_left,
      'card_count', coalesce(jsonb_array_length(v_cards), 0));

  elsif p_mode in ('reinforce', 'reinforce_unit') then
    select jsonb_agg(jsonb_build_object('id', x.id, 'type', x.type, 'skill', x.skill,
             'cefr_level', x.cefr_level, 'prompt', x.prompt, 'payload', x.payload)) into v_items
    from (
      select ci.id, ci.type, ci.skill, ci.cefr_level, ci.prompt, ci.payload, ci.correct_answer,
             jz_item_reinforce(uid, ci.id) score
      from content_items ci join user_item_attempts ua on ua.item_id = ci.id and ua.user_id = uid
      where ci.course_id = v_course and not jz_is_stub(ci.type)
        and (p_skill is null or ci.skill = p_skill::skill)
        and (p_unit is null or exists (select 1 from lesson_items li join lessons l on l.id = li.lesson_id
                                       where li.item_id = ci.id and l.unit_id = p_unit))
      order by jz_item_reinforce(uid, ci.id) desc nulls last, random() limit 12) x;

  else
    if p_mode = 'weakness' then
      select s.skill::skill into v_weak from unnest(array['reading','listening','writing','speaking']) s(skill)
      order by jz_reinforce_score(uid, v_course, s.skill::skill) desc,
               array_position(array['reading','listening','writing','speaking'], s.skill) limit 1;
    end if;
    select jsonb_agg(jsonb_build_object('id', id, 'type', type, 'skill', skill, 'cefr_level', cefr_level,
             'prompt', prompt, 'payload', payload)) into v_items
    from (select id, type, skill, cefr_level, prompt, payload, correct_answer from content_items
          where course_id = v_course and not ('placement' = any(tags))
            and case when p_mode = 'weakness' then skill = v_weak
                     when p_mode = 'skill' then skill = p_skill::skill
                     when p_mode = 'timed' then type not in ('listening','speaking_read_aloud','dictation','guided_writing')
                     else true end
          order by random() limit case when p_mode = 'timed' then 20 else 10 end) x;
  end if;

  return jsonb_build_object('mode', p_mode, 'weakest_skill', v_weak, 'due_count', v_due,
    'item_count', coalesce(jsonb_array_length(v_items), 0), 'items', coalesce(v_items, '[]'::jsonb));
end $function$;

-- ── 3. submit_practice: rating 1-4 + FSRS + pago 1×/sesión ───────────────────
create or replace function public.submit_practice(p_mode text, p_answers jsonb)
returns jsonb
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  uid uuid := auth.uid(); v_course uuid; v_graded int := 0; v_correct int := 0;
  v_xp int := 0; v_gold int := 0; v_activity jsonb; rec record;
  v_word text; v_ok boolean; v_ret numeric; v_row user_vocab_srs%rowtype;
  v_rating int; v_elapsed numeric; v_next jsonb; v_state text; v_due timestamptz;
begin
  if uid is null then raise exception 'auth required'; end if;
  select jz_active_course() into v_course;

  if p_mode = 'srs' then
    v_ret := jz_cfg('srs_target_retention_pct', 90)::numeric / 100.0;

    -- ANTI-DUPLICADO (PRACTICAR_SRS_ANALISIS.md §1.5): una tarjeta fallada
    -- reaparece en la MISMA sesión; solo su PRIMERA respuesta cuenta para el pago.
    -- Sin esto, fallar-y-acertar pagaría más que acertar a la primera.
    create temp table _pay on commit drop as
    select distinct on (vid) vid, ok from (
      select coalesce((e ->> 'vocab_id')::uuid, (e ->> 'item_id')::uuid) as vid,
             ord,
             coalesce((e ->> 'rating')::int, 0) as rating,
             e -> 'answer' as ans
        from jsonb_array_elements(p_answers) with ordinality as t(e, ord)
    ) q
    cross join lateral (
      select jz_grade('translation'::content_item_type,
                      jsonb_build_object('value', (select word from vocabulary where id = q.vid)),
                      q.ans) as ok
    ) g
    where q.vid is not null
    order by vid, ord;   -- distinct on → se queda la PRIMERA (menor ord)

    for rec in
      select coalesce((e ->> 'vocab_id')::uuid, (e ->> 'item_id')::uuid) as vid,
             coalesce((e ->> 'rating')::int, 3) as rating,
             e -> 'answer' as ans, ord
        from jsonb_array_elements(p_answers) with ordinality as t(e, ord)
       order by ord
    loop
      select word into v_word from vocabulary where id = rec.vid;
      if v_word is null then continue; end if;

      -- El servidor CALIFICA lo escrito (nunca se fía del cliente). Regla honesta:
      -- si la respuesta escrita es INCORRECTA, el rating se fuerza a 1 (Otra vez)
      -- aunque el usuario pulse "Fácil" → no se puede inflar el intervalo ni el XP.
      -- Si es correcta, el botón (2/3/4) modula el INTERVALO, no el pago.
      v_ok := jz_grade('translation'::content_item_type,
                       jsonb_build_object('value', v_word), rec.ans);
      v_rating := case when not v_ok then 1
                       else greatest(2, least(4, coalesce(rec.rating, 3))) end;

      select * into v_row from user_vocab_srs where user_id = uid and vocab_id = rec.vid;
      v_state := coalesce(v_row.state, 'new');
      v_elapsed := case
        when v_row.last_reviewed_at is null then 0
        else greatest(0, extract(epoch from (now() - v_row.last_reviewed_at)) / 86400.0)
      end;

      v_next := jz_fsrs_next(v_state, v_row.stability, v_row.difficulty,
                             v_elapsed, v_rating, v_ret);
      v_due := case when (v_next ->> 'interval_days')::int = 0
                    then now()   -- vuelve en esta sesión
                    else now() + ((v_next ->> 'interval_days') || ' days')::interval end;

      insert into user_vocab_srs (user_id, vocab_id, stability, difficulty, state,
                                  reps, lapses, last_rating, scheduled_days,
                                  interval_days, due_at, last_reviewed_at)
      values (uid, rec.vid, (v_next ->> 'stability')::numeric, (v_next ->> 'difficulty')::numeric,
              v_next ->> 'state', 1, case when (v_next ->> 'lapse')::boolean then 1 else 0 end,
              v_rating, (v_next ->> 'interval_days')::int,
              (v_next ->> 'interval_days')::int, v_due, now())
      on conflict (user_id, vocab_id) do update set
        stability = excluded.stability, difficulty = excluded.difficulty,
        state = excluded.state, reps = user_vocab_srs.reps + 1,
        lapses = user_vocab_srs.lapses + case when (v_next ->> 'lapse')::boolean then 1 else 0 end,
        last_rating = excluded.last_rating, scheduled_days = excluded.scheduled_days,
        interval_days = excluded.interval_days, due_at = excluded.due_at,
        last_reviewed_at = now(), updated_at = now();

      -- Bitácora: métrica de retención + (futuro) optimizador FSRS.
      insert into srs_review_log (user_id, vocab_id, rating, state, elapsed_days,
                                  scheduled_days, stability, difficulty)
      values (uid, rec.vid, v_rating, v_state, round(v_elapsed)::int,
              (v_next ->> 'interval_days')::int,
              (v_next ->> 'stability')::numeric, (v_next ->> 'difficulty')::numeric);
    end loop;

    select count(*), count(*) filter (where ok) into v_graded, v_correct from _pay;

  else
    create temp table _pg on commit drop as
    select ci.id as item_id, jz_is_stub(ci.type) as is_stub,
           case when jz_is_stub(ci.type) then null else jz_grade(ci.type, ci.correct_answer, e.elem -> 'answer') end as correct
    from jsonb_array_elements(p_answers) as e(elem) join content_items ci on ci.id = (e.elem ->> 'item_id')::uuid;
    select count(*) filter (where not is_stub), count(*) filter (where correct) into v_graded, v_correct from _pg;
    for rec in select item_id, is_stub, correct from _pg loop
      perform jz_record_item(uid, rec.item_id, case when rec.is_stub then true else coalesce(rec.correct, false) end);
    end loop;
  end if;

  -- ECONOMÍA: SIN CAMBIOS. Un solo pago por sesión, tope 20 XP (cortafuegos
  -- anti-farmeo) y oro 2 → sigue pagando MENOS que una lección (oro 5-10).
  v_xp := least(v_correct * 3, 20); v_gold := case when v_correct > 0 then 2 else 0 end;
  insert into user_stats (user_id) values (uid) on conflict (user_id) do nothing;
  update user_stats set xp_total = xp_total + v_xp, gold = gold + v_gold, updated_at = now() where user_id = uid;
  update user_course_progress set xp_total = xp_total + v_xp, updated_at = now() where user_id = uid and course_id = v_course;
  if v_gold > 0 then insert into gold_transactions (user_id, amount, reason) values (uid, v_gold, 'challenge'); end if;
  v_activity := jz_register_activity(uid, v_course, v_xp);

  return jsonb_build_object('mode', p_mode, 'graded', v_graded, 'correct', v_correct,
    'accuracy', case when v_graded > 0 then round(v_correct::numeric / v_graded, 2) else 0 end,
    'xp_earned', v_xp, 'gold_earned', v_gold, 'streak', (v_activity ->> 'streak')::int,
    'streak_advanced', (v_activity ->> 'streak_advanced')::boolean, 'goal_met', (v_activity ->> 'goal_met')::boolean);
end $function$;

-- ── 4. Estado del SRS: vencidas + nuevas + retención (spec §2.6) ─────────────
create or replace function public.get_srs_status()
returns jsonb
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  uid uuid := auth.uid(); v_course uuid; v_mature int; v_new_today int; v_cap int;
begin
  if uid is null then raise exception 'auth required'; end if;
  v_course := jz_active_course();
  v_mature := jz_cfg('srs_mature_days', 21);
  v_cap := jz_cfg('srs_new_per_day', 10);
  select count(*) into v_new_today from srs_review_log
   where user_id = uid and state = 'new' and reviewed_at >= date_trunc('day', now());

  return jsonb_build_object(
    'due', (select count(*) from user_vocab_srs s join vocabulary v on v.id = s.vocab_id
             where s.user_id = uid and v.course_id = v_course
               and s.state <> 'new' and s.due_at is not null and s.due_at <= now()),
    'new_left', greatest(0, v_cap - v_new_today),
    'new_available', (select count(*) from user_vocab_srs s join vocabulary v on v.id = s.vocab_id
                       where s.user_id = uid and v.course_id = v_course and s.state = 'new'),
    'total_cards', (select count(*) from user_vocab_srs s join vocabulary v on v.id = s.vocab_id
                     where s.user_id = uid and v.course_id = v_course),
    'mature_cards', (select count(*) from user_vocab_srs s join vocabulary v on v.id = s.vocab_id
                      where s.user_id = uid and v.course_id = v_course
                        and s.interval_days >= v_mature),
    -- RETENCIÓN = % de aciertos sobre tarjetas MADURAS (convención Anki).
    -- null si aún no hay reviews maduras (honesto: no se inventa un número).
    'retention_pct', (
      select case when count(*) = 0 then null
                  else round(100.0 * count(*) filter (where rating >= 2) / count(*)) end
        from srs_review_log l join vocabulary v on v.id = l.vocab_id
       where l.user_id = uid and v.course_id = v_course
         and l.state = 'review' and l.elapsed_days >= v_mature),
    'reviews_total', (select count(*) from srs_review_log l join vocabulary v on v.id = l.vocab_id
                       where l.user_id = uid and v.course_id = v_course)
  );
end $function$;
