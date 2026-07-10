-- 20260710120142_mastery_coverage_reachable.sql
-- Fix de cobertura de jz_skill_mastery (dependencia de la unificacion mig 141):
-- el denominador de cobertura = items ALCANZABLES por lecciones del nivel, no todo
-- el banco -> dominar las lecciones del nivel SI alcanza mastery>=0.80 (antes
-- imposible: certificacion inalcanzable). El examen y las secciones >=0.80 siguen
-- siendo el rigor. Sin cambio de firma.
begin;

CREATE OR REPLACE FUNCTION public.jz_skill_mastery(p_uid uuid, p_course uuid, p_skill skill, p_level cefr_level)
 RETURNS numeric
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_total_g int; v_total_all int; v_attempted int;
  v_num numeric; v_den numeric; v_wacc numeric; v_cov numeric; v_computed numeric; v_floor numeric;
begin
  -- COBERTURA (mig 142): el denominador son los items ALCANZABLES por lecciones
  -- del nivel (los cableados en lesson_items), NO todo el banco. Antes usaba el
  -- banco completo (p.ej. B1 reading=78) mientras las lecciones solo exponen ~33
  -- -> completar TODAS las lecciones capaba el dominio <0.80 -> certificacion
  -- IMPOSIBLE. Ahora dominar las lecciones del nivel SI demuestra el nivel.
  select count(*) filter (where not jz_is_stub(ci.type)), count(*)
    into v_total_g, v_total_all
  from content_items ci
  where ci.course_id = p_course and ci.skill = p_skill and ci.cefr_level = p_level
    and not ('placement' = any(ci.tags))
    and exists (
      select 1 from lesson_items li join lessons l on l.id = li.lesson_id
      join units u on u.id = l.unit_id
      where li.item_id = ci.id and u.course_id = p_course);

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
end $function$;

commit;
