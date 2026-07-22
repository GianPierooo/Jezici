-- 20260722120197_lesson_vocab_ro_a2.sql
-- Deriva `lesson_vocab` para el curso NUEVO es->ro (...0007) con la MISMA logica
-- de mig 165 (idempotente, on conflict do nothing), acotada a ese course_id para
-- no tocar los 6 cursos existentes. Sin este vinculo las palabras del rumano
-- serian INERTES: complete_lesson no las inscribiria en el SRS.
begin;
insert into public.lesson_vocab (lesson_id, vocab_id, position)
with vn as (
  select id, course_id, jz_normalize(word) as nw,
         position(' ' in jz_normalize(word)) > 0 as is_multi
  from public.vocabulary
  where course_id = '20000000-0000-0000-0000-000000000007'
), item_text as (
  select li.lesson_id, u.course_id, li.order_index,
         translate(jz_normalize(t.txt), ',.;:!?', '      ') as ntxt
  from public.lesson_items li
  join public.content_items ci on ci.id = li.item_id
  join public.lessons l on l.id = li.lesson_id
  join public.units u on u.id = l.unit_id
  cross join lateral (values
    (ci.correct_answer ->> 'value'),
    (ci.payload ->> 'text'),
    (ci.payload ->> 'say'),
    (ci.prompt)
  ) as t(txt)
  where coalesce(t.txt, '') <> ''
    and u.course_id = '20000000-0000-0000-0000-000000000007'
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
    and u.course_id = '20000000-0000-0000-0000-000000000007'
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
commit;
