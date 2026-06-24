-- ============================================================================
-- Jezici · Migración 072 · FIX multicurso de exámenes de nivel (regresión mig 064)
-- mig 064 restauró start/submit_level_exam a la versión mono-curso (courses where
-- is_active) → exámenes de pt daban 'level exam locked'. Restaura jz_active_course()
-- en ambas, preservando per-skill + tope C1 (jz_level_status/jz_resolve intactas).
-- ============================================================================
begin;
CREATE OR REPLACE FUNCTION public.start_level_exam(p_level text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare uid uuid := auth.uid(); v_course uuid; v_level text; v_exam uuid; v_items jsonb;
begin
  if uid is null then raise exception 'auth required'; end if;
  select jz_active_course() into v_course;
  v_level := coalesce(p_level, jz_resolve_exam_level(uid, v_course));
  if not (jz_level_status(uid, v_course, v_level) ->> 'unlocked')::boolean then
    raise exception 'level exam locked';
  end if;
  v_exam := ('50000000-0000-0000-0000-0000000000' || lower(v_level))::uuid;
  insert into exams (id, course_id, type, cefr_level, time_limit_sec, pass_threshold, sections)
  values (v_exam, v_course, 'level', v_level::cefr_level, 600, 0.80,
          '{"skills":["reading","listening","writing","speaking"],"item_count":20}'::jsonb)
  on conflict (id) do nothing;

  with ranked as (
    select id, type, skill, cefr_level, prompt, payload,
           row_number() over (partition by skill order by random()) rn
    from content_items
    where course_id = v_course and cefr_level = v_level::cefr_level and not ('placement' = any(tags))
      and exists (select 1 from unnest(tags) t where t like 'unidad%')
  ), picked as (
    select * from ranked
    where (skill = 'reading' and rn <= 6) or (skill = 'writing' and rn <= 6)
       or (skill = 'listening' and rn <= 4) or (skill = 'speaking' and rn <= 4)
    order by random()
  )
  select jsonb_agg(jsonb_build_object('id', id, 'type', type, 'skill', skill,
           'cefr_level', cefr_level, 'prompt', prompt, 'payload', payload)) into v_items from picked;

  return jsonb_build_object('exam_id', v_exam, 'level', v_level, 'time_limit_sec', 600,
    'pass_threshold', 0.80, 'item_count', coalesce(jsonb_array_length(v_items), 0),
    'items', coalesce(v_items, '[]'::jsonb));
end $function$
;

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
  select ci.id as item_id, ci.skill, jz_is_stub(ci.type) as is_stub,
         (a.elem -> 'answer') as ans,
         case when jz_is_stub(ci.type) then null
              else jz_grade(ci.type, ci.correct_answer, a.elem -> 'answer') end as correct
  from jsonb_array_elements(p_answers) as a(elem)
  join content_items ci on ci.id = (a.elem ->> 'item_id')::uuid;

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
end $function$
;

grant execute on function start_level_exam(text) to authenticated;
grant execute on function submit_level_exam(jsonb, int, text) to authenticated;
commit;
