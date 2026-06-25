-- ============================================================================
-- Jezici · Migración 076 · TEST DE UBICACIÓN adaptativo server-side y preciso
-- ----------------------------------------------------------------------------
-- PROBLEMA (reportado): un usuario respondió bien preguntas de nivel alto y la app
-- lo ubicó en A1. Causa raíz del PLACEMENT (falla A):
--   1) El test era 100% cliente con 20 ítems hardcoded en Dart (el banco de la BD
--      ni se usaba) → banco insuficiente, no convergía.
--   2) El nivel final = MEDIA de los niveles de las preguntas presentadas
--      (placement_test.dart) → subestima sistemáticamente (un B2 sale B1/A2).
--   3) Calificación en cliente (respuesta en el bundle).
--
-- SOLUCIÓN (server-driven, data-driven, verificable con cliente real):
--   · placement_next(course, start_level, history): RPC stateless. Califica TODO el
--     historial con jz_grade (server-authoritative; correct_answer NUNCA se expone),
--     y o bien devuelve el SIGUIENTE ítem (sin respuesta) o el RESULTADO final.
--   · Selección ADAPTATIVA tipo escalera 1-up/1-down (acierto→+1 nivel, error→−1):
--     concentra las preguntas alrededor del nivel real del usuario (psicofísica
--     clásica). Arranca en el hint del onboarding.
--   · Estimador "TECHO" (ceiling): ubica en el nivel MÁS ALTO que el usuario maneja
--     consistentemente (≥50% en ese nivel, contiguo desde abajo). Corrige el sesgo
--     de la media: un B2 que acierta B2 → B2 (no el promedio hacia el centro).
--   · Estima por skill (reading/writing del banco); listening/speaking = global
--     (placement con audio = diferido; speaking no es auto-calificable por diseño).
--   · Pasos hacia IRT: usa cefr_level + difficulty del ítem y un estimador de
--     habilidad con convergencia; determinista y testeable (no caja negra).
-- Aditivo: NO toca grade_item/complete_lesson/seguridad/ligas. La app v2 (cliente
-- relay) se despliega después; el banco se siembra en mig 075.
-- ============================================================================
begin;

-- ── Helpers de rango CEFR (0=A1 … 4=C1, 5=C2) ────────────────────────────────
create or replace function jz_rank(p_level text)
returns int language sql immutable as $$
  select coalesce(array_position(array['A1','A2','B1','B2','C1','C2']::text[], p_level), 1) - 1
$$;

create or replace function jz_cefr(p_rank int)
returns text language sql immutable as $$
  select (array['A1','A2','B1','B2','C1','C2']::text[])[greatest(0, least(5, coalesce(p_rank,0))) + 1]
$$;

-- ── Estimador TECHO (ceiling): nivel más alto manejado consistentemente ──────
-- Recibe (rango, acierto) por ítem. Cuenta por nivel; sube mientras el nivel esté
-- "superado" (≥50% acierto, con ≥2 ítems o ≥1 acierto), contiguo desde el más bajo
-- preguntado. Salta niveles inferiores NO preguntados (el usuario arrancó arriba y
-- los superó). Si ni el más bajo se supera → A1. Determinista y unit-testeable.
create or replace function jz_placement_level(p_ranks int[], p_correct boolean[])
returns int language plpgsql immutable as $$
declare
  asked int[] := array[0,0,0,0,0]; corr int[] := array[0,0,0,0,0];
  i int; r int; v_max int := -1; v_ceil int := -1; v_cleared boolean;
begin
  if p_ranks is null or array_length(p_ranks, 1) is null then return 0; end if;
  for i in 1 .. array_length(p_ranks, 1) loop
    r := greatest(0, least(4, coalesce(p_ranks[i], 0)));
    asked[r + 1] := asked[r + 1] + 1;
    if coalesce(p_correct[i], false) then corr[r + 1] := corr[r + 1] + 1; end if;
  end loop;
  for r in 0 .. 4 loop if asked[r + 1] > 0 then v_max := r; end if; end loop;
  if v_max < 0 then return 0; end if;
  for r in 0 .. v_max loop
    if asked[r + 1] = 0 then continue; end if;            -- nivel no preguntado: saltar
    v_cleared := (corr[r + 1] * 2 >= asked[r + 1]) and (asked[r + 1] >= 2 or corr[r + 1] >= 1);
    if v_cleared then v_ceil := r; else exit; end if;     -- primer nivel no superado: parar
  end loop;
  return greatest(v_ceil, 0);
end $$;

-- ── placement_next: motor adaptativo (1 RPC, stateless, server-graded) ───────
-- p_history = jsonb array [{item_id, answer}, …] (respuestas dadas hasta ahora).
-- Devuelve {done:false, item:{…sin respuesta…}} o {done:true, level, skill_levels}.
create or replace function placement_next(
  p_course uuid default null, p_start_level text default null, p_history jsonb default '[]'::jsonb)
returns jsonb language plpgsql security definer set search_path = public as $$
declare
  uid uuid := auth.uid(); v_course uuid;
  v_band int; v_new int; v_dir int; v_prevdir int := 0; v_rev int := 0; v_n int := 0;
  v_max_items int := 12; v_min_items int := 6; v_stop boolean;
  v_skill text; v_item jsonb;
  v_ranks int[]; v_correct boolean[]; v_overall int; v_read int; v_write int;
  v_rr int[]; v_rc boolean[]; v_wr int[]; v_wc boolean[];
  rec record;
begin
  if uid is null then raise exception 'auth required'; end if;
  v_course := coalesce(p_course, (select id from courses where is_active order by created_at limit 1));
  if v_course is null then raise exception 'no active course'; end if;

  -- Califica TODO el historial en el servidor (jz_grade). correct_answer no sale.
  create temp table _h on commit drop as
  select (e.elem ->> 'item_id')::uuid as item_id, ci.cefr_level, ci.skill,
         jz_rank(ci.cefr_level::text) as rnk,
         jz_grade(ci.type, ci.correct_answer, e.elem -> 'answer') as correct, e.ord
  from jsonb_array_elements(coalesce(p_history, '[]'::jsonb)) with ordinality e(elem, ord)
  join content_items ci on ci.id = (e.elem ->> 'item_id')::uuid
   and ci.course_id = v_course and 'placement' = any(ci.tags);

  -- Escalera 1-up/1-down: reconstruye la banda actual + cuenta reversiones.
  v_band := greatest(0, least(4, jz_rank(coalesce(p_start_level, 'A2'))));
  for rec in select correct from _h order by ord loop
    v_n := v_n + 1;
    v_new := case when rec.correct then least(v_band + 1, 4) else greatest(v_band - 1, 0) end;
    v_dir := sign(v_new - v_band);
    if v_dir <> 0 and v_prevdir <> 0 and v_dir <> v_prevdir then v_rev := v_rev + 1; end if;
    if v_dir <> 0 then v_prevdir := v_dir; end if;
    v_band := v_new;
  end loop;

  v_stop := (v_n >= v_max_items) or (v_n >= v_min_items and v_rev >= 3);

  -- Si no paramos, elige el siguiente ítem: más cercano a la banda; alterna skill.
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
    -- sin ítems nuevos → forzamos cierre con lo que haya.
  end if;

  -- Cierre: estima global + per-skill con el estimador TECHO.
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

revoke all on function jz_rank(text) from public;
revoke all on function jz_cefr(int) from public;
revoke all on function jz_placement_level(int[], boolean[]) from public;
grant execute on function placement_next(uuid, text, jsonb) to authenticated;

commit;
