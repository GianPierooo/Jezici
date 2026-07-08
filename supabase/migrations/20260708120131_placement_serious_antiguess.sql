-- ============================================================================
-- Jezici · Migración 131 · PLACEMENT serio: robusto al AZAR (anti-guessing)
-- ----------------------------------------------------------------------------
-- BUG REAL (reproducido, no sintético): un usuario NUEVO marcando AL AZAR salía
-- B1/B2/C1. Causa raíz que los 3 "fixes" previos NO tocaron:
--   1) TODOS los ítems de placement (incluidas las cloze) llevan `options` → la UI
--      los presenta como opción múltiple → azar = 1/3 de acierto en CADA ítem. Las
--      verificaciones previas respondían 100%/0%/persona-determinista, NUNCA azar
--      uniforme 1/3 → nunca vieron la inflación.
--   2) El estimador (mig 089) era débil contra 1/3: fallback `acc>=0.5` (una moneda
--      al aire promovía un nivel) + dominación con solo 2 ítems/nivel.
--   3) El arranque "buen nivel" sembraba la escalera en B1 → el azar rebotaba alto.
-- Evidencia (repro_placement_random.py, cliente real, 60 usuarios AL AZAR):
--   ANTES en/start=B1: C1 5% · B2 10% (15% inflado); pt/start=B1: B2 5%.
--
-- FIX (examen SERIO, consciente del azar 1/3; validado por sim_placement_tune.py
-- con 4000 trials/caso → azar→A1 ~90%, C1 0%, personas 78-91% a su nivel):
--   A) jz_placement_level GUESS-AWARE: un nivel se ACREDITA solo con evidencia
--      SOSTENIDA — asked>=3 AND corr>=ceil(0.72*asked) AND corr>=3 (muy por encima
--      del piso de azar 1/3). Se toma el nivel MÁS ALTO acreditado. Se ELIMINA el
--      fallback laxo `acc>=0.5`. PISO anti-azar global: si la precisión total no
--      supera 0.5 (azar ronda 0.33) → tope A2 (imposible B1+).
--   B) placement_next: examen MÁS LARGO (min 12 / max 22 ítems, reversals>=6 o
--      saturación pin>=4) para juntar evidencia; ARRANQUE CLAMPEADO a A2 máx
--      (least(1, rank(hint))) → el hint "buen nivel" ya no siembra alto. skill_levels
--      = nivel global en las 4 (el split R/W sobre ~6 ítems era ruido y subcreditaba).
-- Determinista. Aplica a los 6 cursos (la lógica es course-agnóstica). 42501 intacto.
-- ============================================================================
begin;

-- ── A) Estimador guess-aware + piso anti-azar ──────────────────────────────
create or replace function jz_placement_level(p_ranks int[], p_correct boolean[])
returns int language plpgsql immutable as $$
declare
  asked int[] := array[0,0,0,0,0]; corr int[] := array[0,0,0,0,0];
  i int; r int; v_best int := -1; v_ta int := 0; v_tc int := 0;
begin
  if p_ranks is null or array_length(p_ranks, 1) is null then return 0; end if;
  for i in 1 .. array_length(p_ranks, 1) loop
    r := greatest(0, least(4, coalesce(p_ranks[i], 0)));
    asked[r + 1] := asked[r + 1] + 1;
    v_ta := v_ta + 1;
    if coalesce(p_correct[i], false) then
      corr[r + 1] := corr[r + 1] + 1;
      v_tc := v_tc + 1;
    end if;
  end loop;
  -- Nivel ACREDITADO = el más alto con evidencia SOSTENIDA (no azar): >=3 ítems,
  -- >=ceil(0.72*asked) aciertos y >=3 aciertos. Con azar 1/3 esto casi nunca se
  -- cumple → A1. Sin fallback laxo.
  for r in 0 .. 4 loop
    if asked[r + 1] >= 3
       and corr[r + 1] >= ceil(0.72 * asked[r + 1])
       and corr[r + 1] >= 3 then
      v_best := r;
    end if;
  end loop;
  if v_best < 0 then v_best := 0; end if;
  -- PISO anti-azar global: si la precisión total no supera 0.5 (el azar ~0.33),
  -- no se puede acreditar B1+ → tope A2. Un B1+ real acierta lo suyo → acc alta.
  if v_ta > 0 and v_tc * 2 < v_ta then
    v_best := least(v_best, 1);
  end if;
  return v_best;
end $$;

-- ── B) placement_next: examen largo + arranque clampeado a A2 ───────────────
create or replace function placement_next(
  p_course uuid default null, p_start_level text default null, p_history jsonb default '[]'::jsonb)
returns jsonb language plpgsql security definer set search_path = public as $$
declare
  uid uuid := auth.uid(); v_course uuid;
  v_band int; v_new int; v_dir int; v_prevdir int := 0; v_rev int := 0; v_n int := 0;
  v_pin int := 0;
  v_max_items int := 22; v_min_items int := 12; v_stop boolean;
  v_skill text; v_item jsonb;
  v_ranks int[]; v_correct boolean[]; v_overall int;
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

  -- Arranque CLAMPEADO a A2 máx: el hint "buen nivel" (B1) ya no siembra alto,
  -- de modo que el azar no puede rebotar hacia C1 desde una base inflada.
  v_band := greatest(0, least(1, jz_rank(coalesce(p_start_level, 'A2'))));
  for rec in select correct from _h order by ord loop
    v_n := v_n + 1;
    v_new := case when rec.correct then least(v_band + 1, 4) else greatest(v_band - 1, 0) end;
    v_dir := sign(v_new - v_band);
    if v_dir <> 0 and v_prevdir <> 0 and v_dir <> v_prevdir then v_rev := v_rev + 1; end if;
    if v_dir <> 0 then v_prevdir := v_dir; end if;
    if v_new = v_band then v_pin := v_pin + 1; else v_pin := 0; end if;
    v_band := v_new;
  end loop;

  -- Examen largo: junta evidencia. Para al máximo, o con >=12 ítems si convergió
  -- (rebotó >=6) o saturó (>=4 clavado en un extremo).
  v_stop := (v_n >= v_max_items)
         or (v_n >= v_min_items and (v_rev >= 6 or v_pin >= 4));

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

  -- 4 habilidades = nivel global (el split R/W sobre ~6 ítems era ruido y subcreditaba;
  -- Fase 1 ubica por competencia global, honesto y consistente con la unidad de entrada).
  return jsonb_build_object(
    'done', true, 'asked', v_n, 'level', jz_cefr(v_overall),
    'skill_levels', jsonb_build_object(
      'reading', jz_cefr(v_overall), 'writing', jz_cefr(v_overall),
      'listening', jz_cefr(v_overall), 'speaking', jz_cefr(v_overall)));
end $$;

grant execute on function placement_next(uuid, text, jsonb) to authenticated;

commit;
