-- ============================================================================
-- Jezici · Migración 037 · Borrado de cuenta (GA6 · obligación legal)
-- ----------------------------------------------------------------------------
-- Usuarios reales = derecho de supresión (GDPR/CCPA). delete_account borra la
-- cuenta de auth del usuario actual; la cascada (public.users → todas las tablas
-- user_*) elimina TODOS sus datos. SECURITY DEFINER (owner=postgres) puede tocar
-- auth.users. Solo borra al propio usuario (auth.uid()).
-- ============================================================================

create or replace function delete_account()
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
begin
  if uid is null then raise exception 'auth required'; end if;
  -- Borra eventos de analítica que quedan con user_id nulo (set null) para no
  -- dejar rastro del usuario.
  delete from analytics_events where user_id = uid;
  -- Cascada: al borrar de auth.users se borra public.users y toda la data user_*.
  delete from auth.users where id = uid;
end $$;

grant execute on function delete_account() to authenticated;
