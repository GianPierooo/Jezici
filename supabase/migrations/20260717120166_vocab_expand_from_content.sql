-- AMPLIAR EL LÉXICO (PRACTICAR_SRS_ANALISIS §5: 480 palabras/curso es una SEMILLA).
-- Fuente 100% VERIFICADA, cero IA: los pares de los ítems `match` DE TRADUCCIÓN
-- (prompt "…con su traducción" / "portugués y español") — autorados por profesores
-- nativos + revisión adversarial, YA en producción — que enseñan una palabra META +
-- su traducción ESPAÑOLA pero que aún NO están en `vocabulary`.
--
-- GUARDARRAÍL aplicado (un intento previo metió 'Brazil'='Brazilian' de un match de
-- país↔nacionalidad): SOLO prompts de TRADUCCIÓN (los de "matiz"/"colocación"/
-- "nacionalidad"/"significado figurado" NO llevan español en la 2ª columna) + término
-- ≠ traducción + ≤4 palabras (fuera oraciones/gramática, dentro palabras y frases
-- cortas). part_of_speech se deja null (marca de cosecha; el seed nunca es null).
--
-- frequency_rank = order_index de la UNIDAD × 30 + desempate → orden de introducción
-- COHERENTE con el currículo. Idempotente (NOT EXISTS por jz_normalize).
insert into public.vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech)
with pares as (
  select u.course_id, u.order_index as uo,
         jz_normalize(p ->> 'en') as nw, (p ->> 'en') as term, (p ->> 'es') as trad
  from public.lesson_items li
  join public.content_items ci on ci.id = li.item_id
  join public.lessons l on l.id = li.lesson_id
  join public.units u on u.id = l.unit_id
  cross join lateral jsonb_array_elements(ci.payload -> 'pairs') as p
  where ci.type = 'match'
    and coalesce(p ->> 'en', '') <> ''
    and coalesce(p ->> 'es', '') <> ''
    and length(jz_normalize(p ->> 'en')) >= 2
    and jz_normalize(p ->> 'en') <> jz_normalize(p ->> 'es')
    and (ci.prompt ilike '%traducc%' or ci.prompt ilike '%portugu%espa%')
    and array_length(regexp_split_to_array(btrim(p ->> 'en'), '\s+'), 1) <= 4
), cand as (
  select distinct on (course_id, nw) course_id, nw, term, trad, uo
  from pares
  order by course_id, nw, uo
), nuevos as (
  select c.* from cand c
  where not exists (
    select 1 from public.vocabulary v
    where v.course_id = c.course_id and jz_normalize(v.word) = c.nw
  )
), ranked as (
  select course_id, term, trad,
         (uo * 30 + row_number() over (partition by course_id, uo order by nw))::int as fr
  from nuevos
)
select gen_random_uuid(), course_id, term, trad, fr, null
from ranked;

-- Re-derivar lesson_vocab (misma lógica de mig 165, idempotente) para que las
-- palabras recién añadidas queden VINCULADAS a las lecciones que las enseñan → las
-- inscribe el SRS al completar esa lección (NO quedan inertes).
insert into public.lesson_vocab (lesson_id, vocab_id, position)
with vn as (
  select id, course_id, jz_normalize(word) as nw,
         position(' ' in jz_normalize(word)) > 0 as is_multi
  from public.vocabulary
), item_text as (
  select li.lesson_id, u.course_id, li.order_index,
         translate(jz_normalize(t.txt), ',.;:!?¿¡"()[]{}', '               ') as ntxt
  from public.lesson_items li
  join public.content_items ci on ci.id = li.item_id
  join public.lessons l on l.id = li.lesson_id
  join public.units u on u.id = l.unit_id
  cross join lateral (values
    (ci.correct_answer ->> 'value'), (ci.payload ->> 'text'),
    (ci.payload ->> 'say'), (ci.prompt)
  ) as t(txt)
  where coalesce(t.txt, '') <> ''
), tok as (
  select it.lesson_id, it.course_id, it.order_index, w
  from item_text it
  cross join lateral regexp_split_to_table(it.ntxt, '\s+') as w
  where length(w) >= 2
), pair as (
  select li.lesson_id, u.course_id, li.order_index, jz_normalize(p ->> 'en') as w
  from public.lesson_items li
  join public.content_items ci on ci.id = li.item_id
  join public.lessons l on l.id = li.lesson_id
  join public.units u on u.id = l.unit_id
  cross join lateral jsonb_array_elements(ci.payload -> 'pairs') as p
  where ci.type = 'match' and coalesce(p ->> 'en', '') <> ''
), exact_m as (
  select c.lesson_id, v.id as vocab_id, c.order_index
  from (select lesson_id, course_id, order_index, w from tok
        union all
        select lesson_id, course_id, order_index, w from pair) c
  join vn v on v.course_id = c.course_id and v.nw = c.w
), multi_m as (
  select it.lesson_id, v.id as vocab_id, it.order_index
  from item_text it
  join vn v on v.course_id = it.course_id and v.is_multi
   and (' ' || it.ntxt || ' ') like ('%' || ' ' || v.nw || ' ' || '%')
), allm as (
  select * from exact_m union all select * from multi_m
)
select lesson_id, vocab_id, min(order_index) as position
from allm
group by lesson_id, vocab_id
on conflict (lesson_id, vocab_id) do nothing;
