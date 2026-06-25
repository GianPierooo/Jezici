-- ============================================================================
-- Jezici · Migración 073 · Tolerancia "casi correcto" (typo-tolerance) — server
-- ----------------------------------------------------------------------------
-- En translation/cloze: si la respuesta NO es exacta/aceptada pero está MUY cerca
-- (typo menor o artículo a/an/the de más/de menos), se da por CORRECTA y se marca
-- `near` para que el cliente muestre "Casi: la forma es …" (sin restar vida).
--
-- REGLAS (máximo cuidado; el mismo terreno del bug de contracciones). Perdona solo
-- cuando NO cambia el significado:
--   A) Artículos: igual tras quitar a/an/the de ambos lados.
--   B) Distancia de edición == 1 contra alguna forma aceptada, PERO:
--      - inserción/borrado de 1 char (longitudes distintas) → SÍ (un typo no genera
--        un homógrafo intencional: "hous"→"house", "perru"→"peru").
--      - sustitución de 1 char (misma longitud) → SOLO si es multi-palabra (el
--        contexto descarta homógrafos). En palabra SUELTA queda BLOQUEADO →
--        live/life, house/horse, cat/cut, this/these NO se perdonan.
-- Aplica solo a cloze/translation (free-text). word_bank/reorder se arman con tiles
-- fijas → no hay typos. mc/listening son selección. correct_answer sigue revocado.
-- `jz_grade` pasa a ser exact OR near (uniforme → loop y summary/examen consistentes).
-- ============================================================================
begin;

create extension if not exists fuzzystrmatch;  -- levenshtein()

-- Quita los artículos a/an/the (palabras sueltas) y colapsa espacios.
create or replace function jz_strip_articles(t text)
returns text language sql immutable as $$
  select btrim(regexp_replace(regexp_replace(coalesce(t, ''), '\m(a|an|the)\M', '', 'g'), '\s+', ' ', 'g'));
$$;

-- Matcher ESTRICTO (= jz_grade previo): normalización + lista accepted, sin typos.
create or replace function jz_grade_exact(p_type content_item_type, p_correct jsonb, p_answer jsonb)
returns boolean language plpgsql immutable as $fn$
declare v_user text; v_exp text;
begin
  if p_answer is null or jz_is_stub(p_type) then return false; end if;
  if p_type in ('multiple_choice', 'true_false', 'listening') then
    return jz_normalize(p_answer #>> '{}') = jz_normalize(p_correct ->> 'value');
  elsif p_type in ('cloze', 'translation') then
    v_user := p_answer #>> '{}';
    if jz_normalize(v_user) = jz_normalize(p_correct ->> 'value') then return true; end if;
    if jsonb_typeof(p_correct -> 'accepted') = 'array' then
      return exists (select 1 from jsonb_array_elements_text(p_correct -> 'accepted') a
        where jz_normalize(a) = jz_normalize(v_user));
    end if;
    return false;
  elsif p_type in ('word_bank', 'reorder') then
    if jsonb_typeof(p_correct -> 'sequence') = 'array' then
      select string_agg(x, ' ') into v_exp from jsonb_array_elements_text(p_correct -> 'sequence') x;
    else v_exp := p_correct ->> 'value'; end if;
    if jsonb_typeof(p_answer) = 'array' then
      select string_agg(x, ' ') into v_user from jsonb_array_elements_text(p_answer) x;
    else v_user := p_answer #>> '{}'; end if;
    return jz_normalize(v_user) = jz_normalize(v_exp);
  elsif p_type = 'match' then
    if jsonb_typeof(p_correct -> 'pairs') <> 'array' or jsonb_typeof(p_answer) <> 'object' then return false; end if;
    if (select count(*) from jsonb_array_elements(p_correct -> 'pairs'))
       <> (select count(*) from jsonb_object_keys(p_answer)) then return false; end if;
    return not exists (select 1 from jsonb_array_elements(p_correct -> 'pairs') with ordinality as t(pair, idx)
      where jz_normalize(p_answer ->> ((idx - 1)::int)::text) is distinct from jz_normalize(pair ->> 1));
  end if;
  return false;
end $fn$;

-- "Casi correcto" (typo-tolerance) — solo cloze/translation; reglas A y B de arriba.
create or replace function jz_near_match(p_type content_item_type, p_correct jsonb, p_answer jsonb)
returns boolean language plpgsql immutable as $fn$
declare nu text; na text; cand text; d int;
begin
  if p_answer is null or p_type not in ('cloze', 'translation') then return false; end if;
  nu := jz_normalize(p_answer #>> '{}');
  if nu = '' then return false; end if;
  for cand in
    select p_correct ->> 'value'
    union all
    select a from jsonb_array_elements_text(case when jsonb_typeof(p_correct -> 'accepted') = 'array'
                                                 then p_correct -> 'accepted' else '[]'::jsonb end) a
  loop
    na := jz_normalize(cand);
    if na = '' or na = nu then continue; end if;  -- exacto ya lo cubre jz_grade_exact
    -- A) artículos
    if jz_strip_articles(nu) = jz_strip_articles(na) and jz_strip_articles(na) <> '' then
      return true;
    end if;
    -- B) 1 edición, guardada
    d := levenshtein(nu, na);
    if d = 1 then
      if length(nu) <> length(na) then
        return true;                          -- inserción/borrado de 1 char
      elsif position(' ' in na) > 0 then
        return true;                          -- sustitución solo en multi-palabra
      end if;
    end if;
  end loop;
  return false;
end $fn$;

-- jz_grade = exacto O casi (uniforme: loop, práctica, checkpoints y examen).
create or replace function jz_grade(p_type content_item_type, p_correct jsonb, p_answer jsonb)
returns boolean language plpgsql immutable as $fn$
begin
  return jz_grade_exact(p_type, p_correct, p_answer) or jz_near_match(p_type, p_correct, p_answer);
end $fn$;

-- grade_item: añade `near` (true cuando NO fue exacto pero sí casi → "Casi: …").
create or replace function grade_item(p_item_id uuid, p_answer jsonb)
returns jsonb language plpgsql security definer set search_path = public as $fn$
declare uid uuid := auth.uid(); v_type content_item_type; v_correct jsonb; v_word text; v_exact boolean; v_near boolean;
begin
  if uid is null then raise exception 'auth required'; end if;
  select type, correct_answer into v_type, v_correct from content_items where id = p_item_id;
  if found then
    v_exact := jz_grade_exact(v_type, v_correct, p_answer);
    v_near := (not v_exact) and jz_near_match(v_type, v_correct, p_answer);
    return jsonb_build_object('correct', v_exact or v_near, 'near', v_near,
      'graded', not jz_is_stub(v_type), 'expected', v_correct);
  end if;
  -- Fallback: ítem sintético de SRS (el id es de vocabulary).
  select word into v_word from vocabulary where id = p_item_id;
  if found then
    return jsonb_build_object('correct', jz_normalize(p_answer #>> '{}') = jz_normalize(v_word),
      'near', false, 'graded', true, 'expected', jsonb_build_object('value', v_word));
  end if;
  return jsonb_build_object('correct', false, 'near', false, 'graded', false, 'expected', null);
end $fn$;
grant execute on function grade_item(uuid, jsonb) to authenticated;

commit;
