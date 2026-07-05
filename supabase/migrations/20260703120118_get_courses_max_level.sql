-- 20260703120118_get_courses_max_level.sql
-- get_courses ahora expone max_level = nivel CEFR más alto CON CONTENIDO del curso (derivado de
-- units → auto-actualiza al sembrar niveles). Lo usa el onboarding para CAPAR la meta a lo que el
-- curso realmente ofrece (no prometer C1 en un curso que topa en B1). max(cefr_level::text) da el
-- nivel más alto porque A1<A2<B1<B2<C1<C2 en orden alfabético = orden CEFR.
create or replace function public.get_courses()
returns jsonb language sql stable security definer set search_path to 'public' as $function$
  select coalesce(jsonb_agg(jsonb_build_object(
    'id', c.id, 'source', sl.code, 'target', tl.code, 'target_name', tl.name,
    'active', c.id = jz_active_course(),
    'max_level', (select max(u.cefr_level::text) from units u where u.course_id = c.id)
  ) order by c.created_at), '[]'::jsonb)
  from courses c
  join languages sl on sl.id = c.source_language_id
  join languages tl on tl.id = c.target_language_id
  where c.is_active;
$function$;
