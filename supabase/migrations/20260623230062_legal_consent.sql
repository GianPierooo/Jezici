-- ============================================================================
-- Jezici · Migración 062 · Registro de consentimiento legal (Privacidad+Términos)
-- ----------------------------------------------------------------------------
-- Persiste la aceptación con VERSIÓN del documento + timestamp (GDPR + base para
-- re-consentir cuando el texto cambie). Additivo, no toca el alta actual. Sin PII
-- (solo user_id + versión + fecha). Escrituras solo por RPC DEFINER.
-- ============================================================================
begin;

create table if not exists legal_consents (
  user_id     uuid not null references users(id) on delete cascade,
  doc_version text not null,
  accepted_at timestamptz not null default now(),
  primary key (user_id, doc_version)
);
alter table legal_consents enable row level security;
do $p$ begin
  create policy lc_self on legal_consents for select to authenticated using (user_id = auth.uid());
exception when duplicate_object then null; end $p$;
-- Escrituras NO directas (solo vía accept_legal, definer).
revoke insert, update, delete on legal_consents from anon, authenticated;

-- Registra (o refresca) el consentimiento del usuario para una versión.
create or replace function accept_legal(p_version text)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then raise exception 'auth required'; end if;
  if p_version is null or length(p_version) > 64 then return; end if;
  insert into legal_consents (user_id, doc_version) values (auth.uid(), p_version)
  on conflict (user_id, doc_version) do update set accepted_at = now();
end $$;
grant execute on function accept_legal(text) to authenticated;

-- Última versión aceptada por el usuario (para detectar re-consentimiento).
create or replace function my_legal_version()
returns text
language sql
stable
security definer
set search_path = public
as $$
  select doc_version from legal_consents
  where user_id = auth.uid()
  order by accepted_at desc limit 1;
$$;
grant execute on function my_legal_version() to authenticated;

commit;
