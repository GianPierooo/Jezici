-- ============================================================================
-- Jezici · Migración 049 · Endurecer helpers internos (seguridad pre-lanzamiento)
-- ----------------------------------------------------------------------------
-- Hallazgo de auditoría: los helpers jz_* (SECURITY DEFINER) tenían EXECUTE para
-- authenticated/PUBLIC y aceptan p_uid arbitrario → un autenticado podía llamarlos
-- directamente vía PostgREST e inyectar XP/actividad/dominio/liga en CUALQUIER
-- cuenta (jz_register_activity, jz_record_item, jz_record_mastery, jz_add_league_xp,
-- jz_item_reinforce, etc.). La app NUNCA llama jz_* directamente (solo RPCs públicas).
-- Las RPCs públicas son SECURITY DEFINER y los invocan internamente con privilegio
-- del owner, así que revocar el EXECUTE al rol del cliente NO rompe nada.
-- Revocamos EXECUTE de TODOS los jz_* a authenticated/anon/public.
-- ============================================================================
begin;

do $$
declare r record;
begin
  for r in
    select p.oid::regprocedure as sig
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname like 'jz\_%'
  loop
    execute format('revoke execute on function %s from authenticated, anon, public;', r.sig);
  end loop;
end $$;

commit;
