-- ============================================================================
-- Jezici · Migración 124 · PLACEMENT: parada ÁGIL por saturación (subir/bajar rápido)
-- ----------------------------------------------------------------------------
-- PROBLEMA (feedback real): el test "pide demasiados ítems" para los extremos. La
-- parada temprana de mig 089 era `n>=8 AND reversals>=4`. Pero un usuario FUERTE
-- (acierta todo) o DÉBIL (falla todo) NUNCA genera reversals: la escalera sube y se
-- CLAVA en C1 (banda 4) o baja y se clava en A1 (banda 0) sin rebotar → nunca para
-- antes del máximo (14 ítems). Solo los intermedios (que rebotan) paraban en 8.
--
-- FIX (agilidad simétrica, NO reescritura): añade una 2ª condición de parada por
-- SATURACIÓN. Cuando la banda queda CLAVADA en un extremo (0 o 4) varios ítems
-- seguidos, ya no hay información nueva que ganar → para (con el mínimo de evidencia
-- ya cubierto). `v_pin` cuenta ítems consecutivos donde la banda no se movió
-- (v_new==v_band); eso solo ocurre en un extremo (acierto en 4 se queda en 4; fallo
-- en 0 se queda en 0). Parada: n>=min AND (reversals>=4 OR pin>=3).
--   · C1 real: A2→B1→B2→C1 (3 subidas) + 3 clavadas en 4 = ~8 ítems (antes 14).
--   · A1 real: clava en 0 rápido → ~8 ítems (antes 14).
--   · Intermedios: siguen parando por reversals>=4 (sin cambio).
-- El estimador jz_placement_level (mig 089, "techo con evidencia": asked>=2 &
-- correct>=2 & acc>=2/3) NO se toca → mínimos de evidencia intactos, cero
-- sobreestimación. Determinista. Aditivo. correct_answer sigue oculto (42501).
-- ============================================================================
begin;

create or replace function placement_next(
  p_course uuid default null, p_start_level text default null, p_history jsonb default '[]'::jsonb)
returns jsonb language plpgsql security definer set search_path = public as $$
declare
  uid uuid := auth.uid(); v_course uuid;
  v_band int; v_new int; v_dir int; v_prevdir int := 0; v_rev int := 0; v_n int := 0;
  v_pin int := 0;  -- ítems consecutivos con la banda clavada en un extremo (0 o 4)
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
    -- Saturación: la banda no se movió → clavada en un extremo (0 o 4).
    if v_new = v_band then v_pin := v_pin + 1; else v_pin := 0; end if;
    v_band := v_new;
  end loop;

  -- Para al máximo, o con evidencia mínima si CONVERGIÓ (rebotó) o SATURÓ (extremo).
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
