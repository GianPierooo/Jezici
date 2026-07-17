-- get_lesson_intro: payload de PRESENTACIÓN de una lección (enseñar antes de examinar,
-- P1 #4 de PRINCIPIANTE_ANALISIS). DERIVA de contenido que YA existe, no inventa:
--   · concepto  = el tip de la lección (reusa get_lesson_tip: title/body/example).
--   · vocab     = los pares de los ítems `match` de la lección (término meta bajo la
--                 clave 'en' — convención del banco en los 6 cursos — + traducción 'es'),
--                 con imagen de `vocab_images` cuando el término coincide (Twemoji; hoy
--                 solo para inglés → degrada con gracia a texto+audio en el resto).
-- READ-ONLY salvo el marcado de "tip visto" que ya hacía get_lesson_tip (no toca
-- economía/scoring/progresión). El AUDIO lo pone el cliente por TTS (SpeechLang del curso).
create or replace function public.get_lesson_intro(p_lesson_id uuid)
returns jsonb
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  uid uuid := auth.uid();
  v_tip jsonb;
  v_vocab jsonb;
begin
  if uid is null then raise exception 'auth required'; end if;

  -- Concepto: reutiliza EXACTAMENTE el tip de la lección (misma fuente que el final).
  v_tip := get_lesson_tip(p_lesson_id);

  -- Vocabulario: pares de los `match` de la lección (uno por término, orden estable),
  -- con imagen si `vocab_images` tiene el concepto (join por término en minúsculas).
  with raw as (
    select p->>'en' as term, p->>'es' as translation
    from lesson_items li
    join content_items ci on ci.id = li.item_id
    cross join lateral jsonb_array_elements(ci.payload->'pairs') p
    where li.lesson_id = p_lesson_id
      and ci.type = 'match'
      and coalesce(p->>'en','') <> ''
      and coalesce(p->>'es','') <> ''
  ), dedup as (
    select distinct on (lower(term)) term, translation
    from raw
    order by lower(term)
  ), capped as (
    select term, translation from dedup order by lower(term) limit 8
  )
  select coalesce(
    jsonb_agg(
      jsonb_build_object('term', c.term, 'translation', c.translation, 'image_url', vi.image_url)
      order by lower(c.term)
    ), '[]'::jsonb)
  into v_vocab
  from capped c
  left join vocab_images vi on lower(vi.concept) = lower(c.term);

  -- Nada que presentar → null (el cliente entra directo a los ejercicios).
  if v_tip is null and (v_vocab is null or jsonb_array_length(v_vocab) = 0) then
    return null;
  end if;

  return jsonb_build_object('tip', v_tip, 'vocab', coalesce(v_vocab, '[]'::jsonb));
end
$function$;

revoke all on function public.get_lesson_intro(uuid) from anon;
grant execute on function public.get_lesson_intro(uuid) to authenticated;
