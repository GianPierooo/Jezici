-- ============================================================================
-- Jezici · Migración 041 · Niveles v2: DOMINIO rico + examen PER-SKILL + refuerzo
--                          por ítem + rehacer decreciente  (docs/LEVELS_DESIGN_V2.md)
-- ----------------------------------------------------------------------------
-- Sucede a la 040. Cambios (validados por panel adversarial, §8 del diseño):
--  · DOMINIO = cobertura × precisión ponderada por dificultad, on-demand desde
--    user_item_attempts ⋈ content_items, con PISO grandfather (user_skill_mastery
--    de 040 queda como piso de solo-lectura → no regresa barras de los 3 usuarios).
--  · Examen PER-SKILL (Fase 1 single-level = nivel mínimo en curso): se desbloquea
--    cuando ≥1 skill a ese nivel tiene dominio ≥ 0.80; al aprobar la SECCIÓN de una
--    skill, SOLO esa skill sube de nivel. Certificado N cuando las 4 cruzan N.
--  · Refuerzo por ítem (jz_item_reinforce) + por skill (lee cefr POR skill).
--  · Rehacer: XP decreciente 0.5^veces (piso 0.1). Modo Reforzar por mayor necesidad.
--  · Speaking (sin ítems calificables) = participación; su sección pasa por responder.
--  · Backward-compat: conserva TODAS las claves JSON que consume la app-040.
--  · Crédito por ítem anti-spam/retroceso; guardas de NULL; tope C2; UNIQUE en certs.
-- Aplicar BD PRIMERO; la app v2 se despliega DESPUÉS. Rollback = re-aplicar 040.
-- ============================================================================

-- ── 0. Invariante de esquema: un certificado por (usuario, nivel) ────────────
do $$ begin
  if not exists (select 1 from pg_constraint where conname = 'certificates_user_level_uniq') then
    -- sólo si no hay duplicados previos
    if not exists (select user_id, cefr_level from certificates group by user_id, cefr_level having count(*) > 1) then
      alter table certificates add constraint certificates_user_level_uniq unique (user_id, cefr_level);
    end if;
  end if;
end $$;

-- ── 1. Helpers de dominio ────────────────────────────────────────────────────

-- Crédito por ítem (0..1): exige acierto en el último intento; resiste el spam
-- (fuerza bruta hasta acertar → piso 0.4) y el retroceso (último fallo → 0).
create or replace function jz_item_credit(p_cc int, p_att int, p_last boolean)
returns numeric language sql immutable as $$
  select case when coalesce(p_last, false)
              then greatest(0.4, coalesce(p_cc, 0)::numeric / greatest(1, coalesce(p_att, 0)))
              else 0 end
$$;

-- DOMINIO por (usuario, skill, nivel) = cobertura × precisión ponderada por
-- dificultad. Speaking (sin calificables) = participación. PISO grandfather.
create or replace function jz_skill_mastery(p_uid uuid, p_course uuid, p_skill skill, p_level cefr_level)
returns numeric language plpgsql stable security definer set search_path = public as $$
declare
  v_total_g int; v_total_all int; v_attempted int;
  v_num numeric; v_den numeric; v_wacc numeric; v_cov numeric; v_computed numeric; v_floor numeric;
begin
  select count(*) filter (where not jz_is_stub(type)), count(*)
    into v_total_g, v_total_all
  from content_items
  where course_id = p_course and skill = p_skill and cefr_level = p_level and not ('placement' = any(tags));

  if coalesce(v_total_g, 0) = 0 then
    -- Participación pura (speaking). Sin contenido del nivel → 0 (no auto-1).
    if coalesce(v_total_all, 0) = 0 then
      v_computed := 0;
    else
      select count(distinct ua.item_id) into v_attempted
      from user_item_attempts ua join content_items ci on ci.id = ua.item_id
      where ua.user_id = p_uid and ci.skill = p_skill and ci.cefr_level = p_level;
      v_computed := round(least(1.0, coalesce(v_attempted, 0)::numeric / greatest(1, ceil(v_total_all * 0.6))), 4);
    end if;
  else
    select count(distinct ua.item_id),
           sum(jz_item_credit(ua.correct_count, ua.attempts, ua.last_correct) * (0.5 + coalesce(ci.difficulty, 0.3))),
           sum(0.5 + coalesce(ci.difficulty, 0.3))
      into v_attempted, v_num, v_den
    from user_item_attempts ua join content_items ci on ci.id = ua.item_id
    where ua.user_id = p_uid and ci.skill = p_skill and ci.cefr_level = p_level and not jz_is_stub(ci.type);
    -- Guarda NULL/0÷0 (conjunto intentado vacío): wacc=0, no NULL.
    v_wacc := case when coalesce(v_den, 0) > 0 then v_num / v_den else 0 end;
    v_cov := least(1.0, coalesce(v_attempted, 0)::numeric / greatest(1, ceil(v_total_g * 0.6)));
    v_computed := round(v_cov * coalesce(v_wacc, 0), 4);
  end if;

  -- Piso grandfather: la 040 sembró user_skill_mastery (items_correct/16); se lee
  -- como PISO de solo-lectura para no regresar barras de usuarios migrados.
  select round(least(1.0, coalesce(items_correct, 0) / 16.0), 4) into v_floor
  from user_skill_mastery
  where user_id = p_uid and course_id = p_course and skill = p_skill and cefr_level = p_level;

  return greatest(coalesce(v_computed, 0), coalesce(v_floor, 0));
end $$;

-- Necesidad de refuerzo por ÍTEM (0..1): falta de crédito + antigüedad. Quien
-- llame debe excluir stubs (no se pueden re-calificar).
create or replace function jz_item_reinforce(p_uid uuid, p_item uuid)
returns numeric language sql stable security definer set search_path = public as $$
  select round(least(1.0,
           (1 - jz_item_credit(ua.correct_count, ua.attempts, ua.last_correct)) * 0.8
           + least(1.0, extract(epoch from (now() - ua.last_seen_at)) / (14 * 86400.0)) * 0.2), 4)
  from user_item_attempts ua where ua.user_id = p_uid and ua.item_id = p_item
$$;

-- Necesidad de refuerzo por SKILL (0..1): lee el cefr_level POR skill.
create or replace function jz_reinforce_score(p_uid uuid, p_course uuid, p_skill skill)
returns numeric language plpgsql stable security definer set search_path = public as $$
declare v_level cefr_level; v_mp numeric; v_max numeric; v_lag numeric; v_due int; v_srs numeric;
begin
  select cefr_level into v_level from user_skill_levels
   where user_id = p_uid and course_id = p_course and skill = p_skill;
  v_level := coalesce(v_level, 'A1');
  v_mp := jz_skill_mastery(p_uid, p_course, p_skill, v_level);
  select max(jz_skill_mastery(p_uid, p_course, s.skill::skill,
             coalesce((select cefr_level from user_skill_levels
                       where user_id = p_uid and course_id = p_course and skill = s.skill::skill), 'A1')))
    into v_max from unnest(array['reading','listening','writing','speaking']) s(skill);
  v_lag := greatest(0, coalesce(v_max, 0) - v_mp);
  select count(*) into v_due from user_vocab_srs s join vocabulary v on v.id = s.vocab_id
   where s.user_id = p_uid and v.course_id = p_course and s.due_at is not null and s.due_at <= now();
  v_srs := least(1.0, coalesce(v_due, 0) / 12.0);
  return round(least(1.0, 0.5 * (1 - v_mp) + 0.35 * v_lag + 0.15 * v_srs), 4);
end $$;

-- ── 2. Nivel del examen = nivel MÍNIMO en curso (laggard cohort) ─────────────
create or replace function jz_resolve_exam_level(p_uid uuid, p_course uuid)
returns text language plpgsql stable as $$
declare v_min text;
begin
  select cefr_level::text into v_min from user_skill_levels
   where user_id = p_uid and course_id = p_course
   order by array_position(array['A1','A2','B1','B2','C1','C2']::text[], cefr_level::text)
   limit 1;
  return coalesce(v_min, 'A1');
end $$;

-- ── 3. jz_level_status (per-skill, single-level Fase 1, backward-compat) ──────
create or replace function jz_level_status(p_uid uuid, p_course uuid, p_level text)
returns jsonb language plpgsql stable security definer set search_path = public as $$
declare v_total int; v_done int; v_ready int; v_mavg numeric; v_has_cert boolean;
begin
  select count(*) into v_total
  from units u where u.course_id = p_course and u.cefr_level = p_level::cefr_level
    and exists (select 1 from lessons l where l.unit_id = u.id and l.type = 'checkpoint');

  select count(distinct u.id) into v_done
  from user_lesson_progress ulp join lessons l on l.id = ulp.lesson_id join units u on u.id = l.unit_id
  where ulp.user_id = p_uid and l.type = 'checkpoint' and ulp.status in ('completed','golden')
    and u.course_id = p_course and u.cefr_level = p_level::cefr_level;

  -- skills exam-ready = las que están EN este nivel con dominio ≥ 0.80.
  select count(*) into v_ready
  from user_skill_levels usl
  where usl.user_id = p_uid and usl.course_id = p_course and usl.cefr_level = p_level::cefr_level
    and jz_skill_mastery(p_uid, p_course, usl.skill, p_level::cefr_level) >= 0.80;

  -- mastery_avg (display): promedio de las 4 al nivel del examen.
  select coalesce(avg(jz_skill_mastery(p_uid, p_course, s.skill::skill, p_level::cefr_level)), 0) into v_mavg
  from unnest(array['reading','listening','writing','speaking']) s(skill);

  select exists(select 1 from certificates where user_id = p_uid and cefr_level = p_level::cefr_level) into v_has_cert;

  return jsonb_build_object(
    'level', p_level, 'units_total', v_total, 'units_done', v_done,
    'skills_ok', (v_ready >= 1), 'skills_ready', v_ready, 'mastery_avg', round(v_mavg, 3),
    'unlocked', (v_total > 0 and v_done >= v_total and v_ready >= 1),
    'has_certificate', v_has_cert);
end $$;

-- ── 4. get_skill_mastery (per-skill levels + floor; claves compat + aditivas) ─
create or replace function get_skill_mastery()
returns jsonb language plpgsql security definer set search_path = public as $$
declare uid uuid := auth.uid(); v_course uuid; v_level text; v_skills jsonb;
begin
  if uid is null then raise exception 'auth required'; end if;
  select id into v_course from courses where is_active order by created_at limit 1;
  insert into user_skill_levels (user_id, course_id, skill, cefr_level, progress_points)
  select uid, v_course, s::skill, 'A1', 0 from unnest(array['reading','listening','writing','speaking']) s
  on conflict (user_id, course_id, skill) do nothing;
  v_level := jz_resolve_exam_level(uid, v_course);

  select jsonb_agg(jsonb_build_object(
           'skill', usl.skill,
           'certified_level', usl.cefr_level,    -- nivel mostrado (compat)
           'working_level', usl.cefr_level,       -- el dominio se mide a SU nivel
           'mastery_pct', jz_skill_mastery(uid, v_course, usl.skill, usl.cefr_level),
           'reinforce_score', jz_reinforce_score(uid, v_course, usl.skill),
           'exam_ready', (jz_skill_mastery(uid, v_course, usl.skill, usl.cefr_level) >= 0.80))
         order by array_position(array['reading','listening','writing','speaking'], usl.skill::text))
    into v_skills
  from user_skill_levels usl where usl.user_id = uid and usl.course_id = v_course;

  return jsonb_build_object(
    'working_level', v_level,
    'exam', jz_level_status(uid, v_course, v_level),
    'skills', coalesce(v_skills, '[]'::jsonb));
end $$;

-- ── 5. level_exam_status (compat, sin args) ──────────────────────────────────
create or replace function level_exam_status(p_level text default null)
returns jsonb language plpgsql security definer set search_path = public as $$
declare uid uuid := auth.uid(); v_course uuid; v_level text;
begin
  if uid is null then raise exception 'auth required'; end if;
  select id into v_course from courses where is_active order by created_at limit 1;
  insert into user_skill_levels (user_id, course_id, skill, cefr_level, progress_points)
  select uid, v_course, s::skill, 'A1', 0 from unnest(array['reading','listening','writing','speaking']) s
  on conflict (user_id, course_id, skill) do nothing;
  v_level := coalesce(p_level, jz_resolve_exam_level(uid, v_course));
  return jz_level_status(uid, v_course, v_level);
end $$;

-- ── 6. start_level_exam (single-level = min en curso; gate por OR de skills) ──
create or replace function start_level_exam(p_level text default null)
returns jsonb language plpgsql security definer set search_path = public as $$
declare uid uuid := auth.uid(); v_course uuid; v_level text; v_exam uuid; v_items jsonb;
begin
  if uid is null then raise exception 'auth required'; end if;
  select id into v_course from courses where is_active order by created_at limit 1;
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
end $$;

-- ── 7. submit_level_exam (PER-SKILL: sube SOLO la skill cuya sección aprueba) ─
create or replace function submit_level_exam(p_answers jsonb, p_time_taken_sec int default null, p_level text default null)
returns jsonb language plpgsql security definer set search_path = public as $$
declare
  uid uuid := auth.uid(); v_course uuid; v_level text; v_exam uuid;
  v_graded int; v_correct int; v_acc numeric; v_per_skill jsonb; v_weak jsonb;
  v_xp int := 0; v_gold int := 0; v_levels_rank text[] := array['A1','A2','B1','B2','C1','C2'];
  v_raised jsonb := '[]'::jsonb; v_any boolean := false; rec record;
  v_spk_total int; v_spk_ok int; v_pass boolean; v_min_after int; v_target_rank int;
  v_name text; v_folio text; v_code text; v_svg text; v_cert jsonb := null; v_existing certificates%rowtype;
begin
  if uid is null then raise exception 'auth required'; end if;
  select id into v_course from courses where is_active order by created_at limit 1;
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
end $$;

-- ── 8. complete_lesson (re-emitida): registra TODOS los ítems (stubs = participación),
--      sin escribir user_skill_mastery; rehacer con XP decreciente 0.5^veces ────
create or replace function complete_lesson(p_lesson_id uuid, p_answers jsonb)
returns jsonb language plpgsql security definer set search_path = public as $$
declare
  uid uuid := auth.uid(); v_course uuid; v_unit uuid; v_order int; v_xp_reward int;
  v_graded int := 0; v_correct int := 0; v_combo int := 0; v_max_combo int := 0; v_combo_bonus int := 0;
  v_acc numeric := 0; v_xp int := 0; v_gold int := 5; v_status lesson_progress_status; v_next uuid;
  v_activity jsonb; v_prev int := 0; v_factor numeric := 1; rec record; v_skills jsonb := '[]'::jsonb;
begin
  if uid is null then raise exception 'auth required'; end if;
  select u.course_id, l.unit_id, l.order_index, l.xp_reward into v_course, v_unit, v_order, v_xp_reward
  from lessons l join units u on u.id = l.unit_id where l.id = p_lesson_id;
  if v_course is null then raise exception 'lesson not found'; end if;

  select coalesce(times_completed, 0) into v_prev from user_lesson_progress where user_id = uid and lesson_id = p_lesson_id;
  v_factor := greatest(0.1, power(0.5, coalesce(v_prev, 0)));  -- D9: XP decreciente por repetición

  insert into user_course_progress (user_id, course_id, current_unit_id, current_lesson_id)
  values (uid, v_course, v_unit, p_lesson_id) on conflict (user_id, course_id) do nothing;
  insert into user_skill_levels (user_id, course_id, skill, cefr_level, progress_points)
  select uid, v_course, s::skill, 'A1', 0 from unnest(array['reading','listening','writing','speaking']) s
  on conflict (user_id, course_id, skill) do nothing;

  create temp table _g on commit drop as
  select ci.id as item_id, ci.skill, ci.cefr_level, jz_is_stub(ci.type) as is_stub,
         case when jz_is_stub(ci.type) then null else jz_grade(ci.type, ci.correct_answer, a.elem -> 'answer') end as correct,
         a.ord
  from jsonb_array_elements(p_answers) with ordinality as a(elem, ord)
  join content_items ci on ci.id = (a.elem ->> 'item_id')::uuid;

  for rec in select correct, is_stub from _g order by ord loop
    if rec.is_stub then continue; end if;
    v_graded := v_graded + 1;
    if rec.correct then v_correct := v_correct + 1; v_combo := v_combo + 1;
      if v_combo > v_max_combo then v_max_combo := v_combo; end if;
      if v_combo >= 3 then v_combo_bonus := v_combo_bonus + 2; end if;
    else v_combo := 0; end if;
  end loop;

  v_acc := case when v_graded > 0 then v_correct::numeric / v_graded else 0 end;
  v_xp := round((case when v_graded > 0 then round(v_xp_reward * v_acc)::int + v_combo_bonus else v_combo_bonus end) * v_factor)::int;
  v_gold := case when v_prev > 0 then 2 when v_graded > 0 and v_acc >= 0.8 then 10 else 5 end;
  v_status := case when v_graded > 0 and v_acc >= 1 then 'golden' else 'completed' end::lesson_progress_status;

  insert into user_lesson_progress (user_id, lesson_id, status, best_accuracy, times_completed, completed_at)
  values (uid, p_lesson_id, v_status, v_acc, 1, now())
  on conflict (user_id, lesson_id) do update set
    status = case when user_lesson_progress.status = 'golden' then 'golden' else excluded.status end,
    best_accuracy = greatest(coalesce(user_lesson_progress.best_accuracy, 0), excluded.best_accuracy),
    times_completed = user_lesson_progress.times_completed + 1, completed_at = now();

  update user_course_progress set xp_total = xp_total + v_xp, updated_at = now() where user_id = uid and course_id = v_course;
  update user_stats set xp_total = xp_total + v_xp, gold = gold + v_gold, updated_at = now() where user_id = uid;
  insert into gold_transactions (user_id, amount, reason) values (uid, v_gold, 'lesson');
  v_activity := jz_register_activity(uid, v_course, v_xp);

  -- Intentos por ítem: TODOS (stubs de speaking = participación, ok=true). NO escribimos user_skill_mastery (es piso de 040).
  for rec in select item_id, is_stub, correct from _g loop
    perform jz_record_item(uid, rec.item_id, case when rec.is_stub then true else coalesce(rec.correct, false) end);
  end loop;

  -- Resumen de skills que avanzaron dominio (para la UI), a SU nivel en curso.
  select coalesce(jsonb_agg(jsonb_build_object('skill', x.skill,
           'mastery_pct', jz_skill_mastery(uid, v_course, x.skill, x.lvl)) order by x.skill), '[]'::jsonb) into v_skills
  from (select distinct g.skill, usl.cefr_level lvl from _g g
        join user_skill_levels usl on usl.user_id = uid and usl.course_id = v_course and usl.skill = g.skill) x;

  select id into v_next from lessons where unit_id = v_unit and order_index > v_order order by order_index limit 1;
  if v_next is null then
    select l.id into v_next from lessons l join units u on u.id = l.unit_id
     where u.course_id = v_course and u.order_index > (select order_index from units where id = v_unit)
     order by u.order_index, l.order_index limit 1;
  end if;
  if v_next is not null then
    insert into user_lesson_progress (user_id, lesson_id, status) values (uid, v_next, 'available')
    on conflict (user_id, lesson_id) do update set status = case when user_lesson_progress.status in ('completed','golden')
      then user_lesson_progress.status else 'available' end;
  end if;
  update user_course_progress set current_lesson_id = coalesce(v_next, p_lesson_id) where user_id = uid and course_id = v_course;

  return jsonb_build_object('lesson_id', p_lesson_id, 'status', v_status, 'graded', v_graded, 'correct', v_correct,
    'accuracy', v_acc, 'xp_earned', v_xp, 'gold_earned', v_gold, 'is_redo', (v_prev > 0),
    'combo_bonus', v_combo_bonus, 'max_combo', v_max_combo,
    'xp_total', (select xp_total from user_stats where user_id = uid),
    'gold_total', (select gold from user_stats where user_id = uid),
    'streak', (v_activity ->> 'streak')::int, 'streak_advanced', (v_activity ->> 'streak_advanced')::boolean,
    'goal_met', (v_activity ->> 'goal_met')::boolean, 'daily_goal_xp', (v_activity ->> 'goal_xp')::int,
    'daily_xp_earned', (v_activity ->> 'xp_earned_today')::int, 'milestone', (v_activity ->> 'milestone')::int,
    'next_lesson_id', v_next, 'skills', v_skills);
end $$;

-- ── 9. submit_checkpoint (re-emitida): registra TODOS los ítems; sin user_skill_mastery ─
create or replace function submit_checkpoint(p_lesson_id uuid, p_answers jsonb, p_time_taken_sec int default null)
returns jsonb language plpgsql security definer set search_path = public as $$
declare
  uid uuid := auth.uid(); v_course uuid; v_unit uuid; v_order int; v_cefr cefr_level; v_xp_reward int;
  v_graded int := 0; v_correct int := 0; v_acc numeric := 0; v_passed boolean := false;
  v_exam uuid; v_attempt_no int; v_xp int := 0; v_gold int := 0; v_status lesson_progress_status;
  v_next uuid; v_per_skill jsonb; v_weak jsonb; v_activity jsonb; rec record;
begin
  if uid is null then raise exception 'auth required'; end if;
  select u.course_id, l.unit_id, l.order_index, u.cefr_level, l.xp_reward into v_course, v_unit, v_order, v_cefr, v_xp_reward
  from lessons l join units u on u.id = l.unit_id where l.id = p_lesson_id;
  if v_course is null then raise exception 'lesson not found'; end if;

  insert into user_course_progress (user_id, course_id, current_unit_id, current_lesson_id)
  values (uid, v_course, v_unit, p_lesson_id) on conflict (user_id, course_id) do nothing;
  insert into user_skill_levels (user_id, course_id, skill, cefr_level, progress_points)
  select uid, v_course, s::skill, 'A1', 0 from unnest(array['reading','listening','writing','speaking']) s
  on conflict (user_id, course_id, skill) do nothing;

  create temp table _g on commit drop as
  select ci.id as item_id, ci.skill, jz_is_stub(ci.type) as is_stub,
         case when jz_is_stub(ci.type) then null else jz_grade(ci.type, ci.correct_answer, a.elem -> 'answer') end as correct
  from jsonb_array_elements(p_answers) as a(elem)
  join content_items ci on ci.id = (a.elem ->> 'item_id')::uuid;

  select count(*) filter (where not is_stub), count(*) filter (where correct) into v_graded, v_correct from _g;
  v_acc := case when v_graded > 0 then v_correct::numeric / v_graded else 0 end;
  v_passed := v_graded > 0 and v_acc >= 0.80;

  select jsonb_agg(jsonb_build_object('skill', skill, 'total', total, 'correct', correct_cnt, 'graded', graded_cnt,
           'accuracy', case when graded_cnt > 0 then round(correct_cnt::numeric / graded_cnt, 2) else null end) order by skill)
    into v_per_skill from (select skill, count(*) total, count(*) filter (where not is_stub) graded_cnt,
           count(*) filter (where correct) correct_cnt from _g group by skill) s;
  select coalesce(jsonb_agg(skill), '[]'::jsonb) into v_weak
  from (select skill, count(*) filter (where not is_stub) g, count(*) filter (where correct) c from _g group by skill) s
  where g > 0 and c::numeric / g < 0.80;

  select id into v_exam from exams where course_id = v_course and type = 'checkpoint' and unit_id = v_unit limit 1;
  if v_exam is null then
    insert into exams (course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold)
    values (v_course, 'checkpoint', v_cefr, v_unit, 300, 0.80) returning id into v_exam;
  end if;
  insert into exam_attempts (user_id, exam_id, started_at, finished_at, score_global, per_skill_results, passed)
  values (uid, v_exam, now() - (coalesce(p_time_taken_sec, 0) || ' seconds')::interval, now(), v_acc, v_per_skill, v_passed);
  select count(*) into v_attempt_no from exam_attempts where user_id = uid and exam_id = v_exam;

  for rec in select item_id, is_stub, correct from _g loop
    perform jz_record_item(uid, rec.item_id, case when rec.is_stub then true else coalesce(rec.correct, false) end);
  end loop;

  if v_passed then
    v_xp := v_xp_reward; v_gold := 30;
    v_status := case when v_acc >= 1 then 'golden' else 'completed' end::lesson_progress_status;
    insert into user_lesson_progress (user_id, lesson_id, status, best_accuracy, times_completed, completed_at)
    values (uid, p_lesson_id, v_status, v_acc, 1, now())
    on conflict (user_id, lesson_id) do update set status = case when user_lesson_progress.status = 'golden' then 'golden' else excluded.status end,
      best_accuracy = greatest(coalesce(user_lesson_progress.best_accuracy, 0), excluded.best_accuracy),
      times_completed = user_lesson_progress.times_completed + 1, completed_at = now();
    update user_course_progress set xp_total = xp_total + v_xp, updated_at = now() where user_id = uid and course_id = v_course;
    update user_stats set xp_total = xp_total + v_xp, gold = gold + v_gold, updated_at = now() where user_id = uid;
    insert into gold_transactions (user_id, amount, reason) values (uid, v_gold, 'challenge');
    v_activity := jz_register_activity(uid, v_course, v_xp);
    select l.id into v_next from lessons l join units u on u.id = l.unit_id
     where u.course_id = v_course and u.order_index > (select order_index from units where id = v_unit)
     order by u.order_index, l.order_index limit 1;
    if v_next is not null then
      insert into user_lesson_progress (user_id, lesson_id, status) values (uid, v_next, 'available')
      on conflict (user_id, lesson_id) do update set status = case when user_lesson_progress.status in ('completed','golden')
        then user_lesson_progress.status else 'available' end;
      update user_course_progress set current_lesson_id = v_next where user_id = uid and course_id = v_course;
    end if;
  end if;

  return jsonb_build_object('passed', v_passed, 'score_global', v_acc, 'threshold', 0.80, 'attempt_number', v_attempt_no,
    'graded', v_graded, 'correct', v_correct, 'xp_earned', v_xp, 'gold_earned', v_gold,
    'per_skill', coalesce(v_per_skill, '[]'::jsonb), 'weaknesses', v_weak, 'next_unlocked', v_next is not null, 'unit_id', v_unit,
    'streak', coalesce((v_activity ->> 'streak')::int, 0), 'streak_advanced', coalesce((v_activity ->> 'streak_advanced')::boolean, false),
    'goal_met', coalesce((v_activity ->> 'goal_met')::boolean, false), 'milestone', coalesce((v_activity ->> 'milestone')::int, 0));
end $$;

-- ── 10. submit_practice (re-emitida): registra ítems calificables; sin user_skill_mastery ─
create or replace function submit_practice(p_mode text, p_answers jsonb)
returns jsonb language plpgsql security definer set search_path = public as $$
declare
  uid uuid := auth.uid(); v_course uuid; v_graded int := 0; v_correct int := 0; v_xp int := 0; v_gold int := 0;
  v_activity jsonb; rec record; v_word text; v_ok boolean; v_strength numeric; v_interval int;
begin
  if uid is null then raise exception 'auth required'; end if;
  select id into v_course from courses where is_active order by created_at limit 1;
  if p_mode = 'srs' then
    for rec in select (e ->> 'item_id')::uuid as vid, e -> 'answer' as ans from jsonb_array_elements(p_answers) e loop
      select word into v_word from vocabulary where id = rec.vid;
      if v_word is null then continue; end if;
      v_graded := v_graded + 1; v_ok := jz_normalize(rec.ans #>> '{}') = jz_normalize(v_word);
      if v_ok then v_correct := v_correct + 1; end if;
      select coalesce(strength, 0) into v_strength from user_vocab_srs where user_id = uid and vocab_id = rec.vid;
      if v_ok then v_strength := least(coalesce(v_strength, 0) + 1, 5); else v_strength := 0; end if;
      v_interval := case v_strength::int when 0 then 1 when 1 then 2 when 2 then 4 when 3 then 8 when 4 then 16 else 30 end;
      insert into user_vocab_srs (user_id, vocab_id, strength, interval_days, due_at, last_reviewed_at)
      values (uid, rec.vid, v_strength, v_interval, now() + (v_interval || ' days')::interval, now())
      on conflict (user_id, vocab_id) do update set strength = excluded.strength, interval_days = excluded.interval_days,
        due_at = excluded.due_at, last_reviewed_at = now(), updated_at = now();
    end loop;
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
end $$;

-- ── 11. start_practice (re-emitida): modo 'reinforce'/'reinforce_unit' por mayor
--       necesidad de refuerzo (jz_item_reinforce), excluyendo stubs; weakness por score ─
drop function if exists start_practice(text, text);
drop function if exists start_practice(text, text, uuid);
create or replace function start_practice(p_mode text, p_skill text default null, p_unit uuid default null)
returns jsonb language plpgsql security definer set search_path = public as $$
declare uid uuid := auth.uid(); v_course uuid; v_weak skill; v_items jsonb; v_due int := 0;
begin
  if uid is null then raise exception 'auth required'; end if;
  select id into v_course from courses where is_active order by created_at limit 1;

  if p_mode = 'srs' then
    with due as (
      select v.id, v.word, v.translation, (s.vocab_id is null) as isnew, s.due_at
      from vocabulary v left join user_vocab_srs s on s.vocab_id = v.id and s.user_id = uid
      where v.course_id = v_course and (s.vocab_id is null or s.due_at is null or s.due_at <= now())
      order by (s.vocab_id is not null), coalesce(s.due_at, to_timestamp(0)), v.frequency_rank limit 12)
    select jsonb_agg(jsonb_build_object('id', d.id, 'type', 'multiple_choice', 'skill', 'reading', 'cefr_level', 'A1',
             'prompt', '¿Cómo se dice «' || d.translation || '»?', 'payload', jsonb_build_object('options', o.options),
             'correct_answer', jsonb_build_object('value', d.word))) into v_items
    from due d cross join lateral (select jsonb_agg(w order by random()) as options from
      ((select d.word as w) union all (select v2.word from vocabulary v2 where v2.course_id = v_course and v2.word <> d.word order by random() limit 3)) q) o;
    select count(*) into v_due from vocabulary v left join user_vocab_srs s on s.vocab_id = v.id and s.user_id = uid
      where v.course_id = v_course and (s.vocab_id is null or s.due_at is null or s.due_at <= now());

  elsif p_mode in ('reinforce', 'reinforce_unit') then
    -- Ítems calificables de MAYOR necesidad de refuerzo (intentados, no stub), del
    -- curso (y unidad/skill si se piden). Re-evalúa lo que más lo necesita.
    select jsonb_agg(jsonb_build_object('id', x.id, 'type', x.type, 'skill', x.skill, 'cefr_level', x.cefr_level,
             'prompt', x.prompt, 'payload', x.payload, 'correct_answer', x.correct_answer)) into v_items
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
             'prompt', prompt, 'payload', payload, 'correct_answer', correct_answer)) into v_items
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
end $$;

grant execute on function jz_item_credit(int, int, boolean) to authenticated;
grant execute on function jz_skill_mastery(uuid, uuid, skill, cefr_level) to authenticated;
grant execute on function jz_item_reinforce(uuid, uuid) to authenticated;
grant execute on function jz_reinforce_score(uuid, uuid, skill) to authenticated;
grant execute on function get_skill_mastery() to authenticated;
grant execute on function level_exam_status(text) to authenticated;
grant execute on function start_level_exam(text) to authenticated;
grant execute on function submit_level_exam(jsonb, int, text) to authenticated;
grant execute on function complete_lesson(uuid, jsonb) to authenticated;
grant execute on function submit_checkpoint(uuid, jsonb, int) to authenticated;
grant execute on function submit_practice(text, jsonb) to authenticated;
grant execute on function start_practice(text, text, uuid) to authenticated;
