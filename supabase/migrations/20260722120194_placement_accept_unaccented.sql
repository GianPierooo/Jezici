-- 20260722120194_placement_accept_unaccented.sql
-- DEFECTO VIVO EN PRODUCCION, destapado al sembrar el rumano: los cloze del banco
-- de PLACEMENT castigan a quien teclea SIN ACENTOS. `jz_normalize` no toca los
-- diacriticos (verificado; es la misma causa raiz que mig 177 y mig 182), asi que
-- responder «es» por «és» o «esti» por «ești» se marcaba MAL — en el test que
-- decide el nivel del usuario. Afecta a fr(5) it(2) pt(3) de(1) ro(1) = 12 items.
--
-- ARREGLO DETERMINISTA (cero autoria): a cada cloze/translation de placement con
-- diacriticos se le anade a `accepted` su forma SIN ELLOS. Solo AMPLIA lo que se
-- acepta, nunca restringe. Verificado ANTES de aplicar: 0 distractores del propio
-- item pasan a ser aceptados (la forma pelada no colisiona con ninguno).
-- No toca el estimador, ni el largo del test, ni el contenido de las lecciones.
begin;
with t as (
  select ci.id,
         ci.correct_answer->>'value' as v,
         translate(ci.correct_answer->>'value',
           'áàâãäéèêëíìîïóòôõöúùûüçñýăâîșțÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇÑĂÂÎȘȚ',
           'aaaaaeeeeiiiiooooouuuucnyaaistAAAAAEEEEIIIIOOOOOUUUUCNAAIST') as pelada,
         coalesce(ci.correct_answer->'accepted', jsonb_build_array(ci.correct_answer->>'value')) as acc
    from public.content_items ci
   where ci.tags @> array['placement']
     and ci.type in ('cloze','translation')
)
update public.content_items ci
   set correct_answer = ci.correct_answer || jsonb_build_object('accepted', t.acc || to_jsonb(t.pelada))
  from t
 where ci.id = t.id
   and t.v <> t.pelada
   and not (t.acc @> to_jsonb(t.pelada));
commit;
