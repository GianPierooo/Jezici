-- ============================================================================
-- Jezici · Migración 074 · Conectar errores de lección con el SRS (TASK 1)
-- ----------------------------------------------------------------------------
-- Al terminar una lección, el cliente envía los ítems FALLADOS. Esta RPC mapea
-- cada fallo → el vocabulario del curso que aparece (palabra completa) en su
-- respuesta correcta, y lo mete/baja en user_vocab_srs con PRIORIDAD (strength=0,
-- due_at=now) → el error se repasa en días (rescate de palabras), no solo se
-- corrige hoy. Heurística honesta: si un fallo no contiene vocab del curso (ítem
-- de gramática), no agrega nada (el repaso visual en pantalla igual lo cubre).
-- DEFINER acotada a auth.uid(). No toca complete_lesson (loop intacto).
-- ============================================================================
begin;

create or replace function srs_prioritize_failed(p_item_ids uuid[])
returns int language plpgsql security definer set search_path = public as $fn$
declare uid uuid := auth.uid(); v_course uuid; v_n int := 0;
begin
  if uid is null then raise exception 'auth required'; end if;
  if p_item_ids is null or array_length(p_item_ids, 1) is null then return 0; end if;
  v_course := jz_active_course();

  with failed as (
    select unnest(p_item_ids) as item_id
  ), texts as (
    -- Texto a escanear: el value de la respuesta correcta del content_item
    -- (o el propio word si el id resultara ser de vocabulary).
    select coalesce(ci.correct_answer ->> 'value', vv.word) as txt
    from failed f
    left join content_items ci on ci.id = f.item_id
    left join vocabulary vv on vv.id = f.item_id
    where coalesce(ci.correct_answer ->> 'value', vv.word) is not null
  ), matched as (
    select distinct v.id as vocab_id
    from vocabulary v
    join texts t
      on (' ' || jz_normalize(t.txt) || ' ') like ('%' || ' ' || jz_normalize(v.word) || ' ' || '%')
    where v.course_id = v_course and length(jz_normalize(v.word)) >= 2
  )
  insert into user_vocab_srs (user_id, vocab_id, strength, interval_days, due_at, last_reviewed_at)
  select uid, vocab_id, 0, 1, now(), now() from matched
  on conflict (user_id, vocab_id) do update
    set strength = 0, interval_days = 1, due_at = now(), updated_at = now();

  get diagnostics v_n = row_count;
  return v_n;
end $fn$;
grant execute on function srs_prioritize_failed(uuid[]) to authenticated;

commit;
