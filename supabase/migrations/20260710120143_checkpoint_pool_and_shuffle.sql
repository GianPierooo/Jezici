-- 20260710120143_checkpoint_pool_and_shuffle.sql
-- EVAL_AUDIT: (P0) checkpoint C1 con banco insuficiente por TAGGING +
-- (P1) opciones no barajadas al servir. Cero contenido nuevo.
begin;

-- jz_shuffle_options: baraja el array payload.options en ORDEN aleatorio al
-- SERVIR (VOLATILE -> random() se re-evalua por fila y por request). Solo toca
-- 'options' (MC / listening / true_false); word_bank(tiles)/reorder/match(pairs)/
-- cloze NO tienen 'options' -> intactos. El grading es por VALOR (jz_grade compara
-- jz_normalize(answer)=jz_normalize(correct->>'value')), no por indice -> barajar
-- el orden mostrado NO afecta la correccion.
create or replace function public.jz_shuffle_options(p jsonb)
returns jsonb language sql volatile as $fn$
  select case
    when jsonb_typeof(p -> 'options') = 'array'
         and jsonb_array_length(p -> 'options') > 1
    then jsonb_set(p, '{options}',
           (select jsonb_agg(x order by random())
              from jsonb_array_elements(p -> 'options') x))
    else p
  end
$fn$;
revoke all on function public.jz_shuffle_options(jsonb) from public;
grant execute on function public.jz_shuffle_options(jsonb) to authenticated, anon, service_role;

CREATE OR REPLACE FUNCTION public.start_checkpoint(p_lesson_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
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
           'cefr_level', cefr_level, 'prompt', prompt, 'payload', jz_shuffle_options(payload)))
    into v_items
  from picked;

  return jsonb_build_object(
    'exam_id', v_exam,
    'time_limit_sec', 300,
    'pass_threshold', 0.80,
    'item_count', coalesce(jsonb_array_length(v_items), 0),
    'items', coalesce(v_items, '[]'::jsonb)
  );
end $function$;

CREATE OR REPLACE FUNCTION public.start_level_exam(p_level text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare uid uuid := auth.uid(); v_course uuid; v_level text; v_exam uuid; v_items jsonb;
begin
  if uid is null then raise exception 'auth required'; end if;
  select jz_active_course() into v_course;
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
           'cefr_level', cefr_level, 'prompt', prompt, 'payload', jz_shuffle_options(payload))) into v_items from picked;

  return jsonb_build_object('exam_id', v_exam, 'level', v_level, 'time_limit_sec', 600,
    'pass_threshold', 0.80, 'item_count', coalesce(jsonb_array_length(v_items), 0),
    'items', coalesce(v_items, '[]'::jsonb));
end $function$;

-- F1: RE-TAG de los items C1 (en) a su 'unidadN' (derivada de lesson_items ->
-- units.order_index). El checkpoint (start_checkpoint) filtra por tag 'unidadN';
-- solo ~1R/1W por unidad C1 estaban taggeados -> reading/writing servian SIEMPRE
-- el mismo item (cero aleatorizacion). El contenido YA existe (R12-16, W17-21,
-- L9-10, S7-8 alcanzables por leccion/unidad); esto lo hace visible al checkpoint.
-- 0 items ambiguos (cada item cableado a 1 sola unidad). Idempotente.
with item_unit as (
  select distinct on (li.item_id) li.item_id, u.order_index uo
  from lesson_items li
  join lessons l on l.id = li.lesson_id
  join units u on u.id = l.unit_id
  join content_items ci on ci.id = li.item_id
  where ci.course_id = '20000000-0000-0000-0000-000000000001'
    and ci.cefr_level = 'C1'
  order by li.item_id, u.order_index
)
update content_items ci
set tags = ci.tags || array['unidad' || iu.uo::text]
from item_unit iu
where ci.id = iu.item_id
  and not (('unidad' || iu.uo::text) = any(ci.tags));

commit;
