-- ============================================================================
-- Jezici · Migración 025 · Examen de nivel A1 + certificación (gran diferenciador)
-- ----------------------------------------------------------------------------
-- Se desbloquea al completar TODAS las unidades del nivel Y tener las 4
-- habilidades en el nivel. Examen cronometrado, banco aleatorizado de las 6
-- unidades, cubriendo las 4 habilidades. Al aprobar (≥80%): emite el
-- CERTIFICADO server-side (folio + código de verificación + SVG) y celebra.
-- Todo server-side (el cliente nunca decide aprobado/XP).
-- ============================================================================

-- ── jz_cert_svg: documento del certificado (SVG generado en el servidor) ─────
create or replace function jz_cert_svg(p_name text, p_level text, p_folio text, p_code text, p_date text)
returns text
language sql
immutable
as $$
  select format($svg$<svg xmlns="http://www.w3.org/2000/svg" width="1000" height="700" viewBox="0 0 1000 700">
  <defs><linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">
    <stop offset="0" stop-color="#F7F5FF"/><stop offset="1" stop-color="#FFFDF5"/></linearGradient></defs>
  <rect width="1000" height="700" fill="url(#bg)"/>
  <rect x="24" y="24" width="952" height="652" rx="22" fill="none" stroke="#6C5CE7" stroke-width="4"/>
  <rect x="40" y="40" width="920" height="620" rx="16" fill="none" stroke="#FFC93C" stroke-width="2"/>
  <text x="500" y="120" text-anchor="middle" font-family="Georgia,serif" font-size="30" fill="#7A809B" letter-spacing="6">JEZICI · CERTIFICADO</text>
  <text x="500" y="180" text-anchor="middle" font-size="64">🦜</text>
  <text x="500" y="280" text-anchor="middle" font-family="Georgia,serif" font-size="34" fill="#1A1A2E">Certificado de Inglés</text>
  <text x="500" y="330" text-anchor="middle" font-family="Georgia,serif" font-size="22" fill="#7A809B">Se otorga a</text>
  <text x="500" y="400" text-anchor="middle" font-family="Georgia,serif" font-weight="bold" font-size="48" fill="#4B3FC9">%s</text>
  <text x="500" y="470" text-anchor="middle" font-family="Georgia,serif" font-size="24" fill="#1A1A2E">por alcanzar el nivel</text>
  <text x="500" y="545" text-anchor="middle" font-family="Georgia,serif" font-weight="bold" font-size="80" fill="#E0980C">%s</text>
  <text x="500" y="590" text-anchor="middle" font-family="Georgia,serif" font-size="18" fill="#7A809B">Marco Común Europeo de Referencia (MCER)</text>
  <text x="80" y="640" font-family="monospace" font-size="16" fill="#7A809B">Folio: %s</text>
  <text x="920" y="640" text-anchor="end" font-family="monospace" font-size="16" fill="#7A809B">Verificación: %s</text>
  <text x="500" y="665" text-anchor="middle" font-family="Georgia,serif" font-size="15" fill="#7A809B">Emitido el %s</text>
</svg>$svg$, p_name, p_level, p_folio, p_code, p_date)
$$;

-- ── level_exam_status: ¿está desbloqueado el examen de nivel? ─────────────────
create or replace function level_exam_status()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  v_course uuid;
  v_level text := 'A1';
  v_units_total int; v_units_done int; v_skills_ok boolean; v_has_cert boolean;
begin
  if uid is null then raise exception 'auth required'; end if;
  select id into v_course from courses where is_active order by created_at limit 1;

  select count(*) into v_units_total from units where course_id = v_course and cefr_level = v_level::cefr_level;
  select count(distinct u.id) into v_units_done
  from user_lesson_progress ulp
  join lessons l on l.id = ulp.lesson_id
  join units u on u.id = l.unit_id
  where ulp.user_id = uid and l.type = 'checkpoint' and ulp.status in ('completed','golden')
    and u.course_id = v_course and u.cefr_level = v_level::cefr_level;

  select (count(*) filter (where array_position(array['A1','A2','B1','B2','C1','C2']::text[], cefr_level::text)
            >= array_position(array['A1','A2','B1','B2','C1','C2']::text[], v_level)) >= 4)
    into v_skills_ok
  from user_skill_levels where user_id = uid and course_id = v_course;

  select exists(select 1 from certificates where user_id = uid and cefr_level = v_level::cefr_level) into v_has_cert;

  return jsonb_build_object(
    'level', v_level,
    'units_total', v_units_total,
    'units_done', v_units_done,
    'skills_ok', coalesce(v_skills_ok, false),
    'unlocked', (v_units_done >= v_units_total and coalesce(v_skills_ok, false)),
    'has_certificate', v_has_cert);
end $$;

-- ── start_level_exam: arma el examen (4 habilidades, banco de las 6 unidades) ─
create or replace function start_level_exam()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  v_course uuid;
  v_exam uuid := '50000000-0000-0000-0000-0000000000a1';
  v_items jsonb;
begin
  if uid is null then raise exception 'auth required'; end if;
  -- Solo si el examen está desbloqueado (todas las unidades + 4 skills al nivel).
  if not (level_exam_status() ->> 'unlocked')::boolean then
    raise exception 'level exam locked';
  end if;
  select id into v_course from courses where is_active order by created_at limit 1;

  insert into exams (id, course_id, type, cefr_level, time_limit_sec, pass_threshold, sections)
  values (v_exam, v_course, 'level', 'A1', 600, 0.80,
          '{"skills":["reading","listening","writing","speaking"],"item_count":20}'::jsonb)
  on conflict (id) do nothing;

  with ranked as (
    select id, type, skill, cefr_level, prompt, payload,
           row_number() over (partition by skill order by random()) rn
    from content_items
    where course_id = v_course and cefr_level = 'A1' and not ('placement' = any(tags))
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

  return jsonb_build_object('exam_id', v_exam, 'time_limit_sec', 600, 'pass_threshold', 0.80,
    'item_count', coalesce(jsonb_array_length(v_items), 0), 'items', coalesce(v_items, '[]'::jsonb));
end $$;

-- ── submit_level_exam: califica, decide, certifica (server-side) ──────────────
create or replace function submit_level_exam(p_answers jsonb, p_time_taken_sec int default null)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  v_course uuid;
  v_exam uuid := '50000000-0000-0000-0000-0000000000a1';
  v_graded int; v_correct int; v_acc numeric; v_passed boolean;
  v_per_skill jsonb; v_weak jsonb;
  v_xp int := 0; v_gold int := 0;
  v_name text; v_folio text; v_code text; v_svg text; v_cert jsonb := null;
  v_existing certificates%rowtype;
begin
  if uid is null then raise exception 'auth required'; end if;
  select id into v_course from courses where is_active order by created_at limit 1;

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
    select * into v_existing from certificates where user_id = uid and cefr_level = 'A1' limit 1;
    if v_existing.id is null then
      select coalesce(nullif(display_name, ''), nullif(name, ''), 'Aprendiz') into v_name from users where id = uid;
      v_name := coalesce(v_name, 'Aprendiz');
      v_folio := 'JZC-A1-' || to_char(now(), 'YYYYMMDD') || '-' || upper(left(md5(uid::text || now()::text), 5));
      v_code := upper(left(md5(uid::text || 'verify' || now()::text), 10));
      v_svg := jz_cert_svg(v_name, 'A1', v_folio, v_code, to_char(now(), 'DD/MM/YYYY'));
      insert into certificates (user_id, course_id, cefr_level, folio, verification_code, pdf_url)
      values (uid, v_course, 'A1', v_folio, v_code, v_svg)
      returning * into v_existing;
    end if;
    v_cert := jsonb_build_object('cefr_level', v_existing.cefr_level, 'folio', v_existing.folio,
      'verification_code', v_existing.verification_code, 'issued_at', v_existing.issued_at, 'svg', v_existing.pdf_url);
  end if;

  return jsonb_build_object(
    'passed', v_passed, 'score_global', v_acc, 'threshold', 0.80,
    'graded', v_graded, 'correct', v_correct,
    'xp_earned', v_xp, 'gold_earned', v_gold,
    'per_skill', coalesce(v_per_skill, '[]'::jsonb), 'weaknesses', v_weak,
    'certificate', v_cert);
end $$;

grant execute on function level_exam_status() to authenticated;
grant execute on function start_level_exam() to authenticated;
grant execute on function submit_level_exam(jsonb, int) to authenticated;
