-- ============================================================================
-- Jezici · Migración 020 · start_checkpoint multi-unidad
-- ----------------------------------------------------------------------------
-- La 016 fijaba el filtro del banco a 'unidad1' (válido cuando solo existía la
-- Unidad 1). Con la Unidad 2 sembrada, el set del checkpoint debe salir del
-- banco de SU unidad. Derivamos el tag dinámicamente: 'unidad' || order_index.
-- ============================================================================

create or replace function start_checkpoint(p_lesson_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  v_course uuid;
  v_unit uuid;
  v_cefr cefr_level;
  v_unit_order int;
  v_tag text;
  v_exam uuid;
  v_items jsonb;
begin
  if uid is null then raise exception 'auth required'; end if;

  select u.course_id, l.unit_id, u.cefr_level, u.order_index
    into v_course, v_unit, v_cefr, v_unit_order
  from lessons l join units u on u.id = l.unit_id
  where l.id = p_lesson_id;
  if v_course is null then raise exception 'lesson not found'; end if;

  v_tag := 'unidad' || v_unit_order::text;

  -- Examen de la unidad (existe del seed; si no, lo creamos).
  select id into v_exam from exams
   where course_id = v_course and type = 'checkpoint' and unit_id = v_unit limit 1;
  if v_exam is null then
    insert into exams (course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections)
    values (v_course, 'checkpoint', v_cefr, v_unit, 300, 0.80, '{}'::jsonb)
    returning id into v_exam;
  end if;

  -- Set aleatorizado cubriendo las 4 habilidades (cupos por skill), del banco
  -- de ESTA unidad (tag dinámico).
  with ranked as (
    select id, type, skill, cefr_level, prompt, payload,
           row_number() over (partition by skill order by random()) as rn
    from content_items
    where course_id = v_course and cefr_level = v_cefr and v_tag = any(tags)
  ),
  picked as (
    select * from ranked
    where (skill = 'reading'   and rn <= 3)
       or (skill = 'writing'   and rn <= 3)
       or (skill = 'listening' and rn <= 2)
       or (skill = 'speaking'  and rn <= 2)
    order by random()
  )
  select jsonb_agg(jsonb_build_object(
           'id', id, 'type', type, 'skill', skill,
           'cefr_level', cefr_level, 'prompt', prompt, 'payload', payload))
    into v_items
  from picked;

  return jsonb_build_object(
    'exam_id', v_exam,
    'time_limit_sec', 300,
    'pass_threshold', 0.80,
    'item_count', coalesce(jsonb_array_length(v_items), 0),
    'items', coalesce(v_items, '[]'::jsonb)
  );
end $$;

grant execute on function start_checkpoint(uuid) to authenticated;
