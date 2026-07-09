-- ============================================================================
-- Jezici · Migración 134 · PLACEMENT: largo correcto + calidad de ítems
-- ----------------------------------------------------------------------------
-- Feedback real (Gian): el examen de ubicación se sentía interminable (esperaba
-- ~12 y salieron 22). Además, auditoría de integridad del banco (349 ítems,
-- server-side) halló 7 ítems en el curso EN cuyo DISTRACTOR caía dentro de la
-- tolerancia typo (jz_near_match) del correcto — p.ej. cloze «I have ___ apple.»
-- corr «an», distractor «a»: marcar «a» PUNTUABA correcto (dist-1 perdonada),
-- matando justo el punto gramatical evaluado. El banco EN es anterior a la
-- guarda anti-colisión de gen_placement_multi.py.
--
-- FIX 1 · CALIDAD (sistémico, no parche por ítem): en el placement TODOS los
--   ítems se presentan como OPCIÓN MÚLTIPLE (llevan options; ese fue el hallazgo
--   raíz del anti-azar, mig 131) → su tipo REAL es multiple_choice. Se convierte
--   type cloze/translation → multiple_choice en los ítems `placement`: jz_grade
--   pasa a EXACTO (sin near-match) → ningún distractor puede volver a puntuar,
--   ni hoy ni con ítems futuros. Mismo shape (correct_answer->>'value', options
--   en payload) → cero cambio de cliente. `accepted` era inalcanzable en MC.
--
-- FIX 2 · LARGO (tuneado OFFLINE con sim_placement_tune.py, 4000 trials/caso):
--   min 12/max 22 con rev>=6|pin>=4 casi nunca convergía antes del tope (Gian
--   llegó a 22) y el examen LARGO castigaba al B1 real: sus fallos arriba de su
--   nivel arrastraban la precisión total hacia el piso anti-azar 0.6 → tope A2
--   (B1 real acertaba B1 solo 22%). NUEVO: **min 10 / max 16, rev>=4 o pin>=3**.
--   Sim (mismo estimador guess-aware intacto):
--     RANDOM (1/3): A1 88-91%, B2+C1 <=3% (anti-azar CONSERVADO)  n~10
--     PERSONAS: A1 90% · A2 72% · B1 66% (antes 22%!) · B2 79% · C1 85%
--   Rango final: típico ~10 ítems, tope duro 16. El estimador (mig 131:
--   asked>=3 & corr>=ceil(0.72·asked) & corr>=3 + piso global 0.6 + arranque
--   clampeado A2) NO cambia.
-- Aplica a los 6 cursos (course-agnóstico). 42501 intacto. Determinista.
-- ============================================================================
begin;

-- ── FIX 0 · Estimador: piso CONDICIONAL para B2+ con evidencia raspada ────────
-- Acreditar B2/C1 con la evidencia MÍNIMA (asked<=3 en ese nivel) exige además
-- precisión total >=0.7: el azar que acredita alto lo hace con ventana raspada
-- (3/3 ó 3/4) y acc total ~0.33-0.6 → capado a B1; una persona B2/C1 real
-- acumula 4+ ítems en su nivel (pin/rebotes) y/o acc total alta → exenta.
-- Sim (20k trials): azar B2+C1 pt 0.71% / en 1.10%; personas B1 70% · B2 76-90%
-- · C1 85%. La cola restante es IRREDUCIBLE con MC de 3 opciones (~1%).
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
  for r in 0 .. 4 loop
    if asked[r + 1] >= 3
       and corr[r + 1] >= ceil(0.72 * asked[r + 1])
       and corr[r + 1] >= 3 then
      v_best := r;
    end if;
  end loop;
  if v_best < 0 then v_best := 0; end if;
  -- Piso anti-azar global (mig 131): acc total <=0.5 → tope A2.
  if v_ta > 0 and v_tc * 2 < v_ta then
    v_best := least(v_best, 1);
  end if;
  -- Piso CONDICIONAL nuevo: B2+ con evidencia mínima exige acc total >=0.7.
  if v_best >= 3 and asked[v_best + 1] <= 3 and v_tc::numeric < 0.7 * v_ta then
    v_best := 2;
  end if;
  return v_best;
end $$;

-- ── FIX 1 · Ítems de placement = multiple_choice (grading exacto, sin perdón) ──
update content_items
set type = 'multiple_choice'
where 'placement' = any(tags)
  and type in ('cloze', 'translation');

-- ── FIX 2 · placement_next: min 10 / max 16, parada rev>=4 o pin>=3 ───────────
create or replace function placement_next(
  p_course uuid default null, p_start_level text default null, p_history jsonb default '[]'::jsonb)
returns jsonb language plpgsql security definer set search_path = public as $$
declare
  uid uuid := auth.uid(); v_course uuid;
  v_band int; v_new int; v_dir int; v_prevdir int := 0; v_rev int := 0; v_n int := 0;
  v_pin int := 0;
  v_max_items int := 16; v_min_items int := 10; v_stop boolean;
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

  -- Arranque CLAMPEADO a A2 máx (anti-azar, mig 131 — sin cambios).
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

  -- Parada: tope 16, o con >=10 ítems si convergió (rebotó >=4) o saturó (>=3
  -- clavado en un extremo). Tuneado con sim (4000 trials): anti-azar intacto y
  -- el B1 real ya no muere en el piso global por un examen eterno.
  v_stop := (v_n >= v_max_items)
         or (v_n >= v_min_items and (v_rev >= 4 or v_pin >= 3));

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

  -- 4 habilidades = nivel global (per-skill REAL llega con el banco L/S; ver Cola).
  return jsonb_build_object(
    'done', true, 'asked', v_n, 'level', jz_cefr(v_overall),
    'skill_levels', jsonb_build_object(
      'reading', jz_cefr(v_overall), 'writing', jz_cefr(v_overall),
      'listening', jz_cefr(v_overall), 'speaking', jz_cefr(v_overall)));
end $$;

grant execute on function placement_next(uuid, text, jsonb) to authenticated;

commit;
