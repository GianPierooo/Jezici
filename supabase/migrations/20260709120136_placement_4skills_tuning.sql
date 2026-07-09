-- 20260709120136_placement_4skills_tuning.sql
-- TUNING del placement de 4 habilidades (mig 135), verificado con flujo real:
-- 1) MÍNIMO por skill: con 4 skills el examen paraba en 10 → listening/speaking
--    recibían solo 2-3 ítems (evidencia insuficiente para diferenciar el perfil).
--    Ahora v_min_items = greatest(10, 3*skills_disponibles) → 12 con 4 skills,
--    10 con R/W (cursos sin banco L/S). SIGUE dentro del largo v2 (10-16).
-- 2) Umbral de DEMOTE por skill: <= 0.5 (antes <= 0.4). Con n=3-4 ítems por
--    skill, 0.4 solo se disparaba con <=1/3 pero nunca con 2/4; 0.5 captura al
--    que falla la mitad o más. Sigue DEMOTE-only (jamás promueve → el azar no
--    puede inflar ninguna skill; anti-azar v2 intacto).
begin;

create or replace function placement_next(
  p_course uuid default null, p_start_level text default null,
  p_history jsonb default '[]'::jsonb, p_exclude_skills text[] default null)
returns jsonb language plpgsql security definer set search_path = public as $$
declare
  uid uuid := auth.uid(); v_course uuid;
  v_band int; v_new int; v_dir int; v_prevdir int := 0; v_rev int := 0; v_n int := 0;
  v_pin int := 0;
  v_max_items int := 16; v_min_items int := 10; v_stop boolean;
  v_skill text; v_item jsonb;
  v_ranks int[]; v_correct boolean[]; v_overall int;
  v_avail text[];
  v_sk text; v_sk_n int; v_sk_c int; v_lvls jsonb := '{}'::jsonb;
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

  -- Skills DISPONIBLES (banco del curso, no stub, no excluidas por el cliente).
  select array_agg(s order by pos) into v_avail
  from (
    select x.s, x.pos from (values ('reading',1),('listening',2),('writing',3),('speaking',4)) x(s,pos)
    where exists (select 1 from content_items ci where ci.course_id = v_course
                    and 'placement' = any(ci.tags) and ci.skill::text = x.s
                    and not jz_is_stub(ci.type))
      and (p_exclude_skills is null or x.s <> all(p_exclude_skills))
  ) q;
  if v_avail is null or array_length(v_avail, 1) is null then
    v_avail := array['reading','writing'];
  end if;
  -- Evidencia mínima POR skill: ~3 ítems de cada una antes de poder parar.
  v_min_items := greatest(v_min_items, 3 * array_length(v_avail, 1));

  -- Arranque CLAMPEADO a A2 máx (anti-azar, mig 131/134 — sin cambios).
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

  v_stop := (v_n >= v_max_items)
         or (v_n >= v_min_items and (v_rev >= 4 or v_pin >= 3));

  if not v_stop then
    -- Rotación R→L→W→S sobre las skills disponibles.
    v_skill := v_avail[(v_n % array_length(v_avail, 1)) + 1];

    select jsonb_build_object('id', x.id, 'type', x.type, 'skill', x.skill,
             'cefr_level', x.cefr_level, 'prompt', x.prompt, 'payload', x.payload)
      into v_item
    from (
      select ci.id, ci.type, ci.skill, ci.cefr_level, ci.prompt, ci.payload,
             abs(jz_rank(ci.cefr_level::text) - v_band) bdist,
             case when ci.skill::text = v_skill then 0 else 1 end sdist
      from content_items ci
      where ci.course_id = v_course and 'placement' = any(ci.tags) and not jz_is_stub(ci.type)
        and (p_exclude_skills is null or ci.skill::text <> all(p_exclude_skills))
        and ci.id not in (select item_id from _h)
      order by bdist asc, sdist asc, random()
      limit 1) x;
    if v_item is not null then
      return jsonb_build_object('done', false, 'asked', v_n, 'max', v_max_items, 'item', v_item);
    end if;
  end if;

  select array_agg(rnk order by ord), array_agg(correct order by ord) into v_ranks, v_correct from _h;
  v_overall := jz_placement_level(v_ranks, v_correct);

  -- POR HABILIDAD, con el rigor anti-azar del v2: el GLOBAL (guess-aware, pisos)
  -- es el ancla; una skill solo se DIFERENCIA hacia ABAJO con evidencia sostenida
  -- (>=3 ítems calificados de esa skill y precisión <=0.5 → global-1). NUNCA se
  -- promueve por skill (el azar no puede inflar ninguna). Sin evidencia (p.ej.
  -- speaking excluido, o curso sin banco L/S) → global (honesto, como hoy).
  for v_sk in select unnest(array['reading','listening','writing','speaking']) loop
    select count(*), count(*) filter (where correct) into v_sk_n, v_sk_c
    from _h where skill::text = v_sk;
    if v_sk_n >= 3 and v_sk_c::numeric / v_sk_n <= 0.5 then
      v_lvls := v_lvls || jsonb_build_object(v_sk, jz_cefr(greatest(v_overall - 1, 0)));
    else
      v_lvls := v_lvls || jsonb_build_object(v_sk, jz_cefr(v_overall));
    end if;
  end loop;

  return jsonb_build_object(
    'done', true, 'asked', v_n, 'level', jz_cefr(v_overall), 'skill_levels', v_lvls);
end $$;

grant execute on function placement_next(uuid, text, jsonb, text[]) to authenticated;

commit;
