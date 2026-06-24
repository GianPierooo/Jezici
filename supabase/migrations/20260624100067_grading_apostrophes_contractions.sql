-- ============================================================================
-- Jezici · Migración 067 · Grading: apóstrofes + contracciones (P0 feedback real)
-- ----------------------------------------------------------------------------
-- BUG (reportado por usuario es→en A1): "Traduce: Soy de Perú." → escribe
-- "I'm from Peru" y sale ROJO; ve "I''m from" (apóstrofe DOBLE) en el feedback.
-- CAUSA RAÍZ (doble):
--   (a) DATA: 15 ítems es→en A1 (unidad1/2) se sembraron con el apóstrofe
--       PRE-escapado ('' dentro de un literal dollar-quoted $j$…$j$ → no se
--       desescapó) → quedó "I''m" en payload y correct_answer.
--   (b) NORMALIZACIÓN: jz_normalize quitaba .!?¿¡,;: y minusculizaba, pero NO
--       tocaba apóstrofes (recto/tipográfico/doble) ni equiparaba contracciones
--       (I'm ↔ I am) → "i'm from peru" ≠ "i am from peru" ≠ "i''m from peru".
-- FIX (raíz, sin aflojar de más; grading sigue 100% server-side, correct_answer
-- sigue revocado/42501):
--   1. jz_normalize: normaliza apóstrofes (tipográficos→recto, colapsa ''→'),
--      EXPANDE contracciones a su forma completa (bidireccional, vía canónica) y
--      quita apóstrofes residuales (posesivos). Se aplica IGUAL a ambos lados →
--      solo AÑADE equivalencias naturales, no acepta respuestas erróneas.
--   2. Limpia la DATA: colapsa ''→' en payload y correct_answer de los ítems
--      afectados (cualquier curso). Las opciones/feedback ya no muestran "I''m".
-- ============================================================================
begin;

-- ── 1. jz_normalize con apóstrofes + contracciones ──────────────────────────
create or replace function jz_normalize(t text)
returns text language plpgsql immutable as $fn$
declare
  v text;
  ap text := chr(39);   -- apóstrofe recto
  cs text[];
begin
  v := lower(coalesce(t, ''));
  -- apóstrofes tipográficos (’ ‘ ´ `) → recto; comillas dobles (“ ” ") → fuera
  v := translate(v, chr(8217) || chr(8216) || chr(180) || chr(96), ap || ap || ap || ap);
  v := translate(v, chr(8220) || chr(8221) || '"', '');
  -- colapsa apóstrofes repetidos ('' corrupto del seed → ')
  v := regexp_replace(v, ap || '+', ap, 'g');
  -- padea para límites de palabra simples (espacios)
  v := ' ' || regexp_replace(v, '\s+', ' ', 'g') || ' ';
  -- expande contracciones (con apóstrofe) a forma completa canónica
  foreach cs slice 1 in array array[
    array[' i' || ap || 'm ', ' i am '],
    array[' i' || ap || 've ', ' i have '],
    array[' i' || ap || 'll ', ' i will '],
    array[' i' || ap || 'd ', ' i would '],
    array[' you' || ap || 're ', ' you are '],
    array[' you' || ap || 've ', ' you have '],
    array[' you' || ap || 'll ', ' you will '],
    array[' you' || ap || 'd ', ' you would '],
    array[' he' || ap || 's ', ' he is '],
    array[' he' || ap || 'll ', ' he will '],
    array[' he' || ap || 'd ', ' he would '],
    array[' she' || ap || 's ', ' she is '],
    array[' she' || ap || 'll ', ' she will '],
    array[' she' || ap || 'd ', ' she would '],
    array[' it' || ap || 's ', ' it is '],
    array[' it' || ap || 'll ', ' it will '],
    array[' it' || ap || 'd ', ' it would '],
    array[' we' || ap || 're ', ' we are '],
    array[' we' || ap || 've ', ' we have '],
    array[' we' || ap || 'll ', ' we will '],
    array[' we' || ap || 'd ', ' we would '],
    array[' they' || ap || 're ', ' they are '],
    array[' they' || ap || 've ', ' they have '],
    array[' they' || ap || 'll ', ' they will '],
    array[' they' || ap || 'd ', ' they would '],
    array[' that' || ap || 's ', ' that is '],
    array[' that' || ap || 'll ', ' that will '],
    array[' who' || ap || 's ', ' who is '],
    array[' what' || ap || 's ', ' what is '],
    array[' where' || ap || 's ', ' where is '],
    array[' when' || ap || 's ', ' when is '],
    array[' why' || ap || 's ', ' why is '],
    array[' how' || ap || 's ', ' how is '],
    array[' there' || ap || 's ', ' there is '],
    array[' there' || ap || 'll ', ' there will '],
    array[' here' || ap || 's ', ' here is '],
    array[' let' || ap || 's ', ' let us '],
    array[' isn' || ap || 't ', ' is not '],
    array[' aren' || ap || 't ', ' are not '],
    array[' wasn' || ap || 't ', ' was not '],
    array[' weren' || ap || 't ', ' were not '],
    array[' don' || ap || 't ', ' do not '],
    array[' doesn' || ap || 't ', ' does not '],
    array[' didn' || ap || 't ', ' did not '],
    array[' can' || ap || 't ', ' can not '],
    array[' couldn' || ap || 't ', ' could not '],
    array[' won' || ap || 't ', ' will not '],
    array[' wouldn' || ap || 't ', ' would not '],
    array[' shouldn' || ap || 't ', ' should not '],
    array[' mustn' || ap || 't ', ' must not '],
    array[' mightn' || ap || 't ', ' might not '],
    array[' needn' || ap || 't ', ' need not '],
    array[' haven' || ap || 't ', ' have not '],
    array[' hasn' || ap || 't ', ' has not '],
    array[' hadn' || ap || 't ', ' had not '],
    array[' shan' || ap || 't ', ' shall not ']
  ] loop
    v := replace(v, cs[1], cs[2]);
  end loop;
  -- "cannot" (palabra) → "can not" para unificar con can't
  v := replace(v, ' cannot ', ' can not ');
  -- quita puntuación y apóstrofes residuales (posesivos: couple's → couples)
  v := regexp_replace(v, '[.!?¿¡,;:]', '', 'g');
  v := replace(v, ap, '');
  v := btrim(regexp_replace(v, '\s+', ' ', 'g'));
  return v;
end $fn$;

-- ── 2. Limpia la DATA corrupta ('' → ') en payload y correct_answer ─────────
update content_items
set payload = regexp_replace(payload::text, chr(39) || '+', chr(39), 'g')::jsonb,
    correct_answer = regexp_replace(correct_answer::text, chr(39) || '+', chr(39), 'g')::jsonb,
    updated_at = now()
where payload::text like '%' || chr(39) || chr(39) || '%'
   or correct_answer::text like '%' || chr(39) || chr(39) || '%';

commit;
