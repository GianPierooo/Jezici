# -*- coding: utf-8 -*-
"""Auditoría de INTEGRIDAD del banco de placement (los 349 ítems, server-side).
Chequea por SQL (Management API, lectura):
  1. COLISIÓN: algún distractor == correcto bajo jz_normalize (MC = exacto) o
     perdonable por jz_near_match (cloze/translation) → el distractor puntuaría.
  2. DUPLICADOS: prompts normalizados repetidos dentro del mismo curso.
  3. SANIDAD: el correcto está entre las options; nº de options >= 3.
python audit_placement_bank.py"""
import json
import apply_sql as api

def q(sql):
    return api.run(sql)

print("== 1) COLISIONES distractor vs correcto ==")
r = q("""
with p as (
  select ci.id, ci.course_id, ci.cefr_level, ci.skill, ci.type, ci.prompt,
         coalesce(ci.correct_answer->>'value', ci.correct_answer->>'text') corr,
         opt.value as opt
  from content_items ci,
       lateral jsonb_array_elements_text(coalesce(ci.payload->'options','[]'::jsonb)) opt(value)
  where 'placement' = any(ci.tags)
)
select course_id, cefr_level, skill, type, left(prompt, 60) prompt, corr, opt
from p
where jz_normalize(opt) <> jz_normalize(corr)  -- es un distractor de verdad
  and (
    jz_normalize(opt) = jz_normalize(corr)     -- (imposible aquí, guard)
    or (type::text not in ('multiple_choice','listening') and jz_near_match(opt, corr))
  )
order by course_id, cefr_level;
""")
print(json.dumps(r, ensure_ascii=False, indent=1)[:3000])

print("\n== 1b) Distractor IGUAL al correcto bajo normalize (cualquier tipo) ==")
r = q("""
with p as (
  select ci.id, ci.course_id, ci.cefr_level, ci.type, left(ci.prompt,60) prompt,
         coalesce(ci.correct_answer->>'value', ci.correct_answer->>'text') corr,
         opt.value as opt, opt.ordinality as ord
  from content_items ci,
       lateral jsonb_array_elements_text(coalesce(ci.payload->'options','[]'::jsonb))
         with ordinality opt(value, ordinality)
  where 'placement' = any(ci.tags)
)
select course_id, cefr_level, type, prompt, corr, opt
from p
where jz_normalize(opt) = jz_normalize(corr)
group by course_id, cefr_level, type, prompt, corr, opt
having count(*) > 1;  -- el correcto aparece >1 vez == duplicado/colisión real
""")
print(json.dumps(r, ensure_ascii=False, indent=1)[:2000])

print("\n== 2) PROMPTS duplicados por curso ==")
# Exentos: listening/speaking (mig 135) — su prompt es una INSTRUCCIÓN genérica
# ("Escucha el audio…"/"Lee esta frase…"); el estímulo real es el audio/texto.
r = q("""
select course_id, jz_normalize(prompt) np, count(*) n, array_agg(left(prompt,50)) ejemplos
from content_items where 'placement' = any(tags)
  and skill::text not in ('listening','speaking')
group by course_id, jz_normalize(prompt) having count(*) > 1;
""")
print(json.dumps(r, ensure_ascii=False, indent=1)[:2000])

print("\n== 3) SANIDAD: correcto no está en options / options < 3 ==")
# Exentos: ítems de SPEAKING del placement (mig 135) = read-aloud SIN opciones
# (type=translation, la respuesta es la transcripción del micrófono).
r = q("""
select ci.course_id, ci.cefr_level, ci.type, left(ci.prompt,60) prompt,
       coalesce(ci.correct_answer->>'value', ci.correct_answer->>'text') corr,
       jsonb_array_length(coalesce(ci.payload->'options','[]'::jsonb)) nopts,
       exists (
         select 1 from jsonb_array_elements_text(coalesce(ci.payload->'options','[]'::jsonb)) o(v)
         where jz_normalize(o.v) = jz_normalize(coalesce(ci.correct_answer->>'value', ci.correct_answer->>'text'))
       ) corr_in_opts
from content_items ci
where 'placement' = any(ci.tags)
  and ci.skill::text <> 'speaking'
  and (
    jsonb_array_length(coalesce(ci.payload->'options','[]'::jsonb)) < 3
    or not exists (
      select 1 from jsonb_array_elements_text(coalesce(ci.payload->'options','[]'::jsonb)) o(v)
      where jz_normalize(o.v) = jz_normalize(coalesce(ci.correct_answer->>'value', ci.correct_answer->>'text'))
    )
  );
""")
print(json.dumps(r, ensure_ascii=False, indent=1)[:3000])
