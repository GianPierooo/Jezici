-- CAUSA RAÍZ DE RETENCIÓN (CAUSA_RAIZ_RETENCION.md P0-A): el SRS escrito marcaba
-- MAL respuestas CORRECTAS ("hello" para hola → "era: hi"; "thanks" para gracias;
-- "sorry" para disculpa) porque submit_practice calificaba contra UNA sola forma
-- (jsonb_build_object('value', vocabulary.word)) aunque jz_grade_exact YA soporta
-- un array `accepted` para cloze/translation.
--
-- FIX (regla de oro: ante la duda, ACEPTAR — un falso "bien" no cuesta nada; un
-- falso "mal" expulsa usuarios):
--  1. vocabulary.accepted (jsonb array) — el CONJUNTO de respuestas válidas.
--  2. Poblado DETERMINISTA (cero autoría masiva, 3 fuentes):
--     (a) HERMANOS: palabras del MISMO curso con la MISMA traducción normalizada
--         se aceptan mutuamente (hola→hi Y hello; coworker↔colleague; meal↔food).
--     (b) VARIANTES DERIVADAS: palabra sin su artículo/marcador según el idioma
--         meta (en: a/an/the/to · fr: le/la/l'/les/un/une/des · it: il/lo/la/l'/
--         i/gli/le/un/uno/una · de: der/die/das/ein/eine · nl: de/het/een/'t ·
--         pt: o/a/os/as/um/uma) → "la borsa" acepta "borsa", "to realize" acepta
--         "realize".
--     (c) MAPA CURADO de cortesía/saludos de alta frecuencia por idioma meta
--         (donde más duele: hola/gracias/disculpa/adiós/lo siento…).
--  3. submit_practice y start_practice (cuerpos VERBATIM, solo el cambio de
--     accepted) — el cliente recibe `accepted` en la tarjeta para que el feedback
--     inmediato coincida con el servidor.
--
-- GUARDARRAÍL: NO toca el motor FSRS (scheduling), la economía (un pago/sesión,
-- tope 20 XP), el rating forzado a 1 en fallo, ni el grading de content_items
-- (lecciones/checkpoints/exámenes siguen igual). Solo cambia QUÉ cuenta como
-- correcto en el SRS escrito. Idempotente.

-- ── 1 · columna ──────────────────────────────────────────────────────────────
alter table public.vocabulary add column if not exists accepted jsonb;

-- ── 2 · poblado determinista ─────────────────────────────────────────────────
with base as (
  select v.id, v.word, v.translation, v.course_id, tl.code as lang
    from vocabulary v
    join courses c on c.id = v.course_id
    join languages tl on tl.id = c.target_language_id
),
syn(lang, tnorm, alts) as (values
  -- inglés (los casos EXACTOS de las capturas + cortesía básica)
  ('en','hola','["hi","hello","hey"]'::jsonb),
  ('en','gracias','["thanks","thank you","thanks a lot","thank you very much"]'::jsonb),
  ('en','disculpa','["sorry","excuse me","pardon","pardon me"]'::jsonb),
  ('en','perdon','["sorry","excuse me","pardon","pardon me"]'::jsonb),
  ('en','lo siento','["sorry","i am sorry","im sorry"]'::jsonb),
  ('en','adios','["bye","goodbye","bye bye","see you"]'::jsonb),
  ('en','hasta luego','["see you later","see you","bye"]'::jsonb),
  ('en','de nada','["you are welcome","youre welcome","no problem"]'::jsonb),
  ('en','buenos dias','["good morning"]'::jsonb),
  ('en','buenas noches','["good night","good evening"]'::jsonb),
  ('en','mucho gusto','["nice to meet you","pleased to meet you"]'::jsonb),
  ('en','de acuerdo','["okay","ok","all right","alright","agreed"]'::jsonb),
  ('en','vale','["okay","ok","all right","alright"]'::jsonb),
  -- francés
  ('fr','hola','["salut","bonjour","coucou"]'::jsonb),
  ('fr','gracias','["merci","merci beaucoup"]'::jsonb),
  ('fr','disculpa','["pardon","excusez-moi","excuse-moi","desole","désolé"]'::jsonb),
  ('fr','perdon','["pardon","excusez-moi","excuse-moi","desole","désolé"]'::jsonb),
  ('fr','lo siento','["désolé","je suis désolé","pardon"]'::jsonb),
  ('fr','adios','["au revoir","salut"]'::jsonb),
  -- italiano
  ('it','hola','["ciao","salve"]'::jsonb),
  ('it','gracias','["grazie","grazie mille"]'::jsonb),
  ('it','disculpa','["scusa","scusi","mi scusi","scusami"]'::jsonb),
  ('it','perdon','["scusa","scusi","mi scusi","scusami"]'::jsonb),
  ('it','lo siento','["mi dispiace","scusa"]'::jsonb),
  ('it','adios','["ciao","arrivederci"]'::jsonb),
  -- alemán
  ('de','hola','["hallo","hi"]'::jsonb),
  ('de','gracias','["danke","danke schön","vielen dank"]'::jsonb),
  ('de','disculpa','["entschuldigung","entschuldige","tut mir leid"]'::jsonb),
  ('de','perdon','["entschuldigung","entschuldige","tut mir leid"]'::jsonb),
  ('de','lo siento','["tut mir leid","entschuldigung"]'::jsonb),
  ('de','adios','["tschüss","auf wiedersehen"]'::jsonb),
  -- neerlandés
  ('nl','hola','["hallo","hoi","hai"]'::jsonb),
  ('nl','gracias','["dank je","dank je wel","bedankt","dank u","dank u wel"]'::jsonb),
  ('nl','disculpa','["sorry","pardon","excuseer"]'::jsonb),
  ('nl','perdon','["sorry","pardon","excuseer"]'::jsonb),
  ('nl','lo siento','["sorry","het spijt me"]'::jsonb),
  ('nl','adios','["doei","dag","tot ziens"]'::jsonb),
  -- portugués (obrigado/obrigada: AMBOS géneros son válidos)
  ('pt','hola','["oi","olá","ola"]'::jsonb),
  ('pt','gracias','["obrigado","obrigada"]'::jsonb),
  ('pt','disculpa','["desculpa","desculpe","com licença","com licenca"]'::jsonb),
  ('pt','perdon','["desculpa","desculpe","perdão","perdao"]'::jsonb),
  ('pt','lo siento','["desculpa","desculpe","sinto muito"]'::jsonb),
  ('pt','adios','["tchau","adeus","até logo","ate logo"]'::jsonb)
),
cand as (
  -- (a) hermanos: misma traducción normalizada, mismo curso, palabra distinta
  select b.id, v2.word as alt
    from base b
    join vocabulary v2
      on v2.course_id = b.course_id
     and jz_normalize(v2.translation) = jz_normalize(b.translation)
     and jz_normalize(v2.word) <> jz_normalize(b.word)
  union
  -- (b) variante sin artículo/marcador del idioma meta
  select b.id,
         trim(regexp_replace(b.word,
           case b.lang
             when 'en' then '^(a|an|the|to)\s+'
             when 'fr' then '^(le|la|les|un|une|des)\s+|^l'''
             when 'it' then '^(il|lo|la|i|gli|le|un|uno|una)\s+|^l'''
             when 'de' then '^(der|die|das|ein|eine)\s+'
             when 'nl' then '^(de|het|een)\s+|^''t\s+'
             when 'pt' then '^(o|a|os|as|um|uma)\s+'
             else '^\Zx' end,
           '', 'i')) as alt
    from base b
  union
  -- (c) mapa curado de cortesía/saludos
  select b.id, a.alt
    from base b
    join syn s on s.lang = b.lang and s.tnorm = jz_normalize(b.translation)
    cross join lateral jsonb_array_elements_text(s.alts) as a(alt)
),
agg as (
  select c.id, jsonb_agg(distinct c.alt) as acc
    from cand c
    join vocabulary vv on vv.id = c.id
   where c.alt is not null
     and length(trim(c.alt)) > 0
     and jz_normalize(c.alt) <> jz_normalize(vv.word)  -- no duplicar la propia forma
   group by c.id
)
update vocabulary v
   set accepted = agg.acc, updated_at = now()
  from agg
 where v.id = agg.id;

-- ── 3 · submit_practice: califica contra value + accepted (cuerpo VERBATIM) ──
CREATE OR REPLACE FUNCTION public.submit_practice(p_mode text, p_answers jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  uid uuid := auth.uid(); v_course uuid; v_graded int := 0; v_correct int := 0;
  v_xp int := 0; v_gold int := 0; v_activity jsonb; rec record;
  v_word text; v_acc jsonb; v_ok boolean; v_ret numeric; v_row user_vocab_srs%rowtype;
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
      -- ACEPTABLES (mig 177): se califica contra la forma canónica + el conjunto
      -- `accepted` (sinónimos/variantes válidas) — regla de oro: ante la duda, aceptar.
      select jz_grade('translation'::content_item_type,
                      (select jsonb_build_object('value', word,
                                                 'accepted', coalesce(accepted, '[]'::jsonb))
                         from vocabulary where id = q.vid),
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
      select word, accepted into v_word, v_acc from vocabulary where id = rec.vid;
      if v_word is null then continue; end if;

      -- El servidor CALIFICA lo escrito (nunca se fía del cliente). Regla honesta:
      -- si la respuesta escrita es INCORRECTA, el rating se fuerza a 1 (Otra vez)
      -- aunque el usuario pulse "Fácil" → no se puede inflar el intervalo ni el XP.
      -- Si es correcta, el botón (2/3/4) modula el INTERVALO, no el pago.
      -- ACEPTABLES (mig 177): value + accepted (sinónimos válidos cuentan como bien).
      v_ok := jz_grade('translation'::content_item_type,
                       jsonb_build_object('value', v_word,
                                          'accepted', coalesce(v_acc, '[]'::jsonb)),
                       rec.ans);
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

-- ── 4 · start_practice: la tarjeta lleva `accepted` (cuerpo VERBATIM) ────────
CREATE OR REPLACE FUNCTION public.start_practice(p_mode text, p_skill text DEFAULT NULL::text, p_unit uuid DEFAULT NULL::uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
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
      (select s.vocab_id, v.word, v.translation, v.accepted, v.frequency_rank, s.state, 0 as bucket
         from user_vocab_srs s join vocabulary v on v.id = s.vocab_id
        where s.user_id = uid and v.course_id = v_course
          and s.state <> 'new' and s.due_at is not null and s.due_at <= now()
        order by s.due_at limit v_max)
      union all
      -- (b) nuevas, por frecuencia (alta primero), con el límite diario
      (select s.vocab_id, v.word, v.translation, v.accepted, v.frequency_rank, s.state, 1 as bucket
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
             -- ACEPTABLES (mig 177): el cliente refleja el mismo criterio del server.
             'accepted', coalesce(accepted, '[]'::jsonb),
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
