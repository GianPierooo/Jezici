-- ============================================================================
-- Jezici · Migración 027 · Audio real + listening calificable (paso Audio)
-- ----------------------------------------------------------------------------
-- 1) Apunta audio_url de cada ítem de listening/speaking al MP3 público en
--    Supabase Storage (bucket 'audio', generado con TTS fijo — no es IA).
-- 2) listening pasa a ser CALIFICABLE (deja de ser stub): se puntúa como un
--    multiple_choice con audio. Speaking sigue como participación, pero su
--    ejercicio ahora es real (Web Speech API en el cliente, comparación
--    determinista contra el texto esperado). Así las 4 habilidades cuentan.
-- ============================================================================

-- 1) URLs de audio públicas (deterministas: <base>/items/<item_id>.mp3).
update content_items
set payload = jsonb_set(
      payload, '{audio_url}',
      to_jsonb('https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/' || id::text || '.mp3'),
      true),
    updated_at = now()
where type in ('listening', 'speaking_read_aloud');

-- 2a) listening ya NO es stub (se califica). speaking sí (participación).
create or replace function jz_is_stub(p_type content_item_type)
returns boolean language sql immutable as $$
  select p_type in ('speaking_read_aloud', 'dictation', 'guided_writing')
$$;

-- 2b) jz_grade: listening se califica igual que multiple_choice (value ∈ options).
create or replace function jz_grade(p_type content_item_type, p_correct jsonb, p_answer jsonb)
returns boolean language plpgsql immutable as $$
declare
  v_user text;
  v_exp  text;
begin
  if p_answer is null or jz_is_stub(p_type) then
    return false;
  end if;

  if p_type in ('multiple_choice', 'true_false', 'listening') then
    return jz_normalize(p_answer #>> '{}') = jz_normalize(p_correct ->> 'value');

  elsif p_type in ('cloze', 'translation') then
    v_user := p_answer #>> '{}';
    if jz_normalize(v_user) = jz_normalize(p_correct ->> 'value') then
      return true;
    end if;
    if jsonb_typeof(p_correct -> 'accepted') = 'array' then
      return exists (
        select 1 from jsonb_array_elements_text(p_correct -> 'accepted') a
        where jz_normalize(a) = jz_normalize(v_user));
    end if;
    return false;

  elsif p_type in ('word_bank', 'reorder') then
    if jsonb_typeof(p_correct -> 'sequence') = 'array' then
      select string_agg(x, ' ') into v_exp
      from jsonb_array_elements_text(p_correct -> 'sequence') x;
    else
      v_exp := p_correct ->> 'value';
    end if;
    if jsonb_typeof(p_answer) = 'array' then
      select string_agg(x, ' ') into v_user
      from jsonb_array_elements_text(p_answer) x;
    else
      v_user := p_answer #>> '{}';
    end if;
    return jz_normalize(v_user) = jz_normalize(v_exp);

  elsif p_type = 'match' then
    if jsonb_typeof(p_correct -> 'pairs') <> 'array'
       or jsonb_typeof(p_answer) <> 'object' then
      return false;
    end if;
    if (select count(*) from jsonb_array_elements(p_correct -> 'pairs'))
       <> (select count(*) from jsonb_object_keys(p_answer)) then
      return false;
    end if;
    return not exists (
      select 1
      from jsonb_array_elements(p_correct -> 'pairs') with ordinality as t(pair, idx)
      where jz_normalize(p_answer ->> ((idx - 1)::int)::text)
            is distinct from jz_normalize(pair ->> 1));
  end if;

  return false;
end $$;
