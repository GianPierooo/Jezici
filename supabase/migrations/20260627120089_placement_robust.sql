-- ============================================================================
-- Jezici · Migración 089 · PLACEMENT robusto: estimador con EVIDENCIA + más banco C1
-- ----------------------------------------------------------------------------
-- PROBLEMA (feedback real): el placement SOBREESTIMA (coloca por encima del nivel real).
-- Causa (mig 076): jz_placement_level "superaba" un nivel con acc≥0.5 (cerca del azar con
-- 3 opciones) Y `corr>=1` → UN SOLO ACIERTO suelto en un nivel alto lo promovía; sin
-- evidencia mínima ni umbral de consistencia.
--
-- FIX (estimador v2, "techo con evidencia + consistencia"): un nivel cuenta como DOMINADO
-- solo si asked≥2 AND correct≥2 AND acc≥2/3 (consistente, no un acierto suelto, no azar).
-- Se ubica en el nivel MÁS ALTO dominado (la escalera 1-up/1-down garantiza haber pasado
-- por los inferiores). Fallback laxo (acc≥0.5 con evidencia) solo si nada "domina";
-- si no, A1 (conservador). Determinista y testeable. + placement_next junta MÁS evidencia
-- (min 8 / max 14 ítems, reversals≥4) y +5 ítems C1 (banco C1 era delgado: 5R+3W → 7R+6W).
-- correct_answer sigue OCULTO (42501). Aditivo.
-- ============================================================================
begin;

-- ── +5 ítems C1 de placement (use of English avanzado: inversión, subjuntivo, léxico) ──
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
 ('4f0c1001-0000-4000-8000-000000000001','20000000-0000-0000-0000-000000000001','C1','writing','cloze',
  'Not only ___ the deadline, but he also exceeded every target.',
  '{"text":"Not only ___ the deadline, but he also exceeded every target.","options":["did he meet","he met","he did meet"]}'::jsonb,
  '{"value":"did he meet"}'::jsonb, 0.9, ARRAY['placement','c1','writing','use_of_english']),
 ('4f0c1002-0000-4000-8000-000000000002','20000000-0000-0000-0000-000000000001','C1','writing','cloze',
  'It is imperative that every applicant ___ present at the interview.',
  '{"text":"It is imperative that every applicant ___ present at the interview.","options":["be","is","was"]}'::jsonb,
  '{"value":"be"}'::jsonb, 0.9, ARRAY['placement','c1','writing','use_of_english']),
 ('4f0c1003-0000-4000-8000-000000000003','20000000-0000-0000-0000-000000000001','C1','writing','cloze',
  '___ I known the risks beforehand, I would have acted differently.',
  '{"text":"___ I known the risks beforehand, I would have acted differently.","options":["Had","If","Have"]}'::jsonb,
  '{"value":"Had"}'::jsonb, 0.9, ARRAY['placement','c1','writing','use_of_english']),
 ('4f0c1004-0000-4000-8000-000000000004','20000000-0000-0000-0000-000000000001','C1','reading','multiple_choice',
  'His argument, ___ compelling, rested on a flawed premise.',
  '{"options":["albeit","despite","whereas"]}'::jsonb,
  '{"value":"albeit"}'::jsonb, 0.9, ARRAY['placement','c1','reading','use_of_english']),
 ('4f0c1005-0000-4000-8000-000000000005','20000000-0000-0000-0000-000000000001','C1','reading','multiple_choice',
  'The committee gave the proposal a ___ examination before approving it.',
  '{"options":["meticulous","meticulously","meticulousness"]}'::jsonb,
  '{"value":"meticulous"}'::jsonb, 0.9, ARRAY['placement','c1','reading','use_of_english'])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload,
  correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();

-- ── Estimador v2: TECHO con evidencia + consistencia (no promueve por acierto suelto) ──
create or replace function jz_placement_level(p_ranks int[], p_correct boolean[])
returns int language plpgsql immutable as $$
declare
  asked int[] := array[0,0,0,0,0]; corr int[] := array[0,0,0,0,0];
  i int; r int; v_best int := -1; v_fallback int := -1;
begin
  if p_ranks is null or array_length(p_ranks, 1) is null then return 0; end if;
  for i in 1 .. array_length(p_ranks, 1) loop
    r := greatest(0, least(4, coalesce(p_ranks[i], 0)));
    asked[r + 1] := asked[r + 1] + 1;
    if coalesce(p_correct[i], false) then corr[r + 1] := corr[r + 1] + 1; end if;
  end loop;
  -- Nivel MÁS ALTO "dominado": ≥2 ítems, ≥2 aciertos y acc≥2/3 (consistente). La escalera
  -- garantiza pasar por los inferiores; exigir ≥2 aciertos mata la promoción por azar/suelto.
  for r in 0 .. 4 loop
    if asked[r + 1] >= 2 and corr[r + 1] >= 2 and corr[r + 1] * 3 >= asked[r + 1] * 2 then
      v_best := r;
    end if;
    if asked[r + 1] >= 2 and corr[r + 1] * 2 >= asked[r + 1] then  -- fallback laxo (acc≥0.5)
      v_fallback := r;
    end if;
  end loop;
  if v_best >= 0 then return v_best; end if;
  if v_fallback >= 0 then return v_fallback; end if;
  return 0; -- sin evidencia suficiente → A1 (conservador, nunca sobreestima)
end $$;

-- ── placement_next: junta MÁS evidencia antes de cerrar (min 8 / max 14, reversals≥4) ──
create or replace function placement_next(
  p_course uuid default null, p_start_level text default null, p_history jsonb default '[]'::jsonb)
returns jsonb language plpgsql security definer set search_path = public as $$
declare
  uid uuid := auth.uid(); v_course uuid;
  v_band int; v_new int; v_dir int; v_prevdir int := 0; v_rev int := 0; v_n int := 0;
  v_max_items int := 14; v_min_items int := 8; v_stop boolean;
  v_skill text; v_item jsonb;
  v_ranks int[]; v_correct boolean[]; v_overall int; v_read int; v_write int;
  v_rr int[]; v_rc boolean[]; v_wr int[]; v_wc boolean[];
  rec record;
begin
  if uid is null then raise exception 'auth required'; end if;
  v_course := coalesce(p_course, (select id from courses where is_active order by created_at limit 1));
  if v_course is null then raise exception 'no active course'; end if;

  create temp table _h on commit drop as
  select (e.elem ->> 'item_id')::uuid as item_id, ci.cefr_level, ci.skill,
         jz_rank(ci.cefr_level::text) as rnk,
         jz_grade(ci.type, ci.correct_answer, e.elem -> 'answer') as correct, e.ord
  from jsonb_array_elements(coalesce(p_history, '[]'::jsonb)) with ordinality e(elem, ord)
  join content_items ci on ci.id = (e.elem ->> 'item_id')::uuid
   and ci.course_id = v_course and 'placement' = any(ci.tags);

  v_band := greatest(0, least(4, jz_rank(coalesce(p_start_level, 'A2'))));
  for rec in select correct from _h order by ord loop
    v_n := v_n + 1;
    v_new := case when rec.correct then least(v_band + 1, 4) else greatest(v_band - 1, 0) end;
    v_dir := sign(v_new - v_band);
    if v_dir <> 0 and v_prevdir <> 0 and v_dir <> v_prevdir then v_rev := v_rev + 1; end if;
    if v_dir <> 0 then v_prevdir := v_dir; end if;
    v_band := v_new;
  end loop;

  v_stop := (v_n >= v_max_items) or (v_n >= v_min_items and v_rev >= 4);

  if not v_stop then
    v_skill := case when v_n % 2 = 0 then 'reading' else 'writing' end;
    select jsonb_build_object('id', x.id, 'type', x.type, 'skill', x.skill,
             'cefr_level', x.cefr_level, 'prompt', x.prompt, 'payload', x.payload)
      into v_item
    from (
      select ci.id, ci.type, ci.skill, ci.cefr_level, ci.prompt, ci.payload,
             abs(jz_rank(ci.cefr_level::text) - v_band) bdist,
             case when ci.skill::text = v_skill then 0 else 1 end sdist
      from content_items ci
      where ci.course_id = v_course and 'placement' = any(ci.tags) and not jz_is_stub(ci.type)
        and ci.id not in (select item_id from _h)
      order by bdist asc, sdist asc, random()
      limit 1) x;
    if v_item is not null then
      return jsonb_build_object('done', false, 'asked', v_n, 'max', v_max_items, 'item', v_item);
    end if;
  end if;

  select array_agg(rnk order by ord), array_agg(correct order by ord) into v_ranks, v_correct from _h;
  v_overall := jz_placement_level(v_ranks, v_correct);
  select array_agg(rnk order by ord), array_agg(correct order by ord) into v_rr, v_rc
    from _h where skill = 'reading';
  select array_agg(rnk order by ord), array_agg(correct order by ord) into v_wr, v_wc
    from _h where skill = 'writing';
  v_read  := case when coalesce(array_length(v_rr, 1), 0) >= 2 then jz_placement_level(v_rr, v_rc) else v_overall end;
  v_write := case when coalesce(array_length(v_wr, 1), 0) >= 2 then jz_placement_level(v_wr, v_wc) else v_overall end;

  return jsonb_build_object(
    'done', true, 'asked', v_n, 'level', jz_cefr(v_overall),
    'skill_levels', jsonb_build_object(
      'reading', jz_cefr(v_read), 'writing', jz_cefr(v_write),
      'listening', jz_cefr(v_overall), 'speaking', jz_cefr(v_overall)));
end $$;

grant execute on function placement_next(uuid, text, jsonb) to authenticated;

commit;
