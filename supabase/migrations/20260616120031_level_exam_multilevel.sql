-- ============================================================================
-- Jezici · Migración 031 · Examen de nivel multi-nivel (A1 → A2 → …)
-- ----------------------------------------------------------------------------
-- La 025 fijaba el examen de nivel a 'A1'. Con A2 sembrado, el examen debe
-- avanzar: tras certificar A1, el usuario apunta al examen A2, etc. Se vuelven
-- LEVEL-AWARE con un parámetro opcional p_level; si es null, se autodetecta el
-- primer nivel "examinable" (con checkpoints) aún sin certificar (A1, luego A2).
-- El cliente sigue llamando sin argumentos (firmas con DEFAULT). El examen y el
-- certificado se derivan del nivel. Todo server-side. NO rompe el flujo A1.
-- ============================================================================

-- Limpiar las firmas viejas (sin parámetros) para evitar ambigüedad de overload.
drop function if exists level_exam_status();
drop function if exists start_level_exam();
drop function if exists submit_level_exam(jsonb, int);

-- ── Helper: estado de un nivel concreto ──────────────────────────────────────
create or replace function jz_level_status(p_uid uuid, p_course uuid, p_level text)
returns jsonb
language plpgsql
as $$
declare
  v_total int; v_done int; v_skills_ok boolean; v_has_cert boolean;
begin
  -- Sólo cuentan las unidades del nivel que tienen checkpoint (examinables).
  select count(*) into v_total
  from units u
  where u.course_id = p_course and u.cefr_level = p_level::cefr_level
    and exists (select 1 from lessons l where l.unit_id = u.id and l.type = 'checkpoint');

  select count(distinct u.id) into v_done
  from user_lesson_progress ulp
  join lessons l on l.id = ulp.lesson_id
  join units u on u.id = l.unit_id
  where ulp.user_id = p_uid and l.type = 'checkpoint' and ulp.status in ('completed','golden')
    and u.course_id = p_course and u.cefr_level = p_level::cefr_level;

  select (count(*) filter (
            where array_position(array['A1','A2','B1','B2','C1','C2']::text[], cefr_level::text)
                  >= array_position(array['A1','A2','B1','B2','C1','C2']::text[], p_level)) >= 4)
    into v_skills_ok
  from user_skill_levels where user_id = p_uid and course_id = p_course;

  select exists(select 1 from certificates where user_id = p_uid and cefr_level = p_level::cefr_level)
    into v_has_cert;

  return jsonb_build_object(
    'level', p_level,
    'units_total', v_total,
    'units_done', v_done,
    'skills_ok', coalesce(v_skills_ok, false),
    'unlocked', (v_total > 0 and v_done >= v_total and coalesce(v_skills_ok, false)),
    'has_certificate', v_has_cert);
end $$;

-- ── Helper: nivel objetivo (primer examinable sin certificar; si no, el más alto) ─
create or replace function jz_resolve_exam_level(p_uid uuid, p_course uuid)
returns text
language plpgsql
as $$
declare
  lv text;
  v_last text := 'A1';
begin
  foreach lv in array array['A1','A2','B1','B2','C1','C2'] loop
    if exists (select 1 from units u join lessons l on l.unit_id = u.id
               where u.course_id = p_course and u.cefr_level = lv::cefr_level and l.type = 'checkpoint') then
      v_last := lv;
      if not exists (select 1 from certificates where user_id = p_uid and cefr_level = lv::cefr_level) then
        return lv;
      end if;
    end if;
  end loop;
  return v_last; -- todos los examinables ya certificados → el más alto
end $$;

-- ── level_exam_status: ¿está desbloqueado? (autodetecta nivel si p_level es null) ─
create or replace function level_exam_status(p_level text default null)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  v_course uuid;
  v_level text;
begin
  if uid is null then raise exception 'auth required'; end if;
  select id into v_course from courses where is_active order by created_at limit 1;
  v_level := coalesce(p_level, jz_resolve_exam_level(uid, v_course));
  return jz_level_status(uid, v_course, v_level);
end $$;

-- ── start_level_exam: arma el examen del nivel objetivo (4 habilidades) ───────
create or replace function start_level_exam(p_level text default null)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  v_course uuid;
  v_level text;
  v_exam uuid;
  v_items jsonb;
begin
  if uid is null then raise exception 'auth required'; end if;
  select id into v_course from courses where is_active order by created_at limit 1;
  v_level := coalesce(p_level, jz_resolve_exam_level(uid, v_course));

  if not (jz_level_status(uid, v_course, v_level) ->> 'unlocked')::boolean then
    raise exception 'level exam locked';
  end if;

  -- Id de examen determinista por nivel: …0000<a1|a2|…> (compatible con la 025).
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
  ),
  picked as (
    select * from ranked
    where (skill = 'reading' and rn <= 6) or (skill = 'writing' and rn <= 6)
       or (skill = 'listening' and rn <= 4) or (skill = 'speaking' and rn <= 4)
    order by random()
  )
  select jsonb_agg(jsonb_build_object('id', id, 'type', type, 'skill', skill,
           'cefr_level', cefr_level, 'prompt', prompt, 'payload', payload))
    into v_items from picked;

  return jsonb_build_object('exam_id', v_exam, 'level', v_level, 'time_limit_sec', 600,
    'pass_threshold', 0.80, 'item_count', coalesce(jsonb_array_length(v_items), 0),
    'items', coalesce(v_items, '[]'::jsonb));
end $$;

-- ── submit_level_exam: califica, decide, certifica (por nivel) ────────────────
create or replace function submit_level_exam(p_answers jsonb, p_time_taken_sec int default null, p_level text default null)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  v_course uuid;
  v_level text;
  v_exam uuid;
  v_graded int; v_correct int; v_acc numeric; v_passed boolean;
  v_per_skill jsonb; v_weak jsonb;
  v_xp int := 0; v_gold int := 0;
  v_name text; v_folio text; v_code text; v_svg text; v_cert jsonb := null;
  v_existing certificates%rowtype;
begin
  if uid is null then raise exception 'auth required'; end if;
  select id into v_course from courses where is_active order by created_at limit 1;
  v_level := coalesce(p_level, jz_resolve_exam_level(uid, v_course));
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

    -- Certificado: uno por (usuario, nivel). Si ya existe, lo devolvemos.
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
    'graded', v_graded, 'correct', v_correct,
    'xp_earned', v_xp, 'gold_earned', v_gold,
    'per_skill', coalesce(v_per_skill, '[]'::jsonb), 'weaknesses', v_weak,
    'certificate', v_cert);
end $$;

grant execute on function level_exam_status(text) to authenticated;
grant execute on function start_level_exam(text) to authenticated;
grant execute on function submit_level_exam(jsonb, int, text) to authenticated;
