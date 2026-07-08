-- ============================================================================
-- Jezici · Migración 132 · Sembrar el NOMBRE al crear la cuenta (OAuth de Google)
-- ----------------------------------------------------------------------------
-- Bug real: "Continuar con Google" (mig auth 2026-07-07) crea la cuenta sin pasar
-- por el formulario de email → nunca se llamaba set_profile(name) → el perfil
-- quedaba en "Coloque seu nome" (needs_name=true). El alta por email SÍ pedía y
-- guardaba el nombre; los usuarios de Google, no.
--
-- Fix belt (server): handle_new_user copia el nombre que Google entrega en
-- raw_user_meta_data (full_name / name) a users.name/display_name al INSERT. El
-- alta por email no trae esos campos → queda null (lo pide el onboarding, fix
-- suspenders del cliente). SOLO afecta a inserts NUEVOS (on conflict do nothing):
-- 0 impacto en usuarios existentes. Idempotente (create or replace).
-- ============================================================================
begin;

create or replace function handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_name text;
begin
  -- Google/OAuth entregan el nombre en raw_user_meta_data; el alta por email no.
  v_name := nullif(btrim(coalesce(
    new.raw_user_meta_data->>'full_name',
    new.raw_user_meta_data->>'name'
  )), '');
  if v_name is not null then v_name := left(v_name, 40); end if;

  insert into public.users (id, email, name, display_name)
  values (new.id, new.email, v_name, v_name)
  on conflict (id) do nothing;

  insert into public.user_stats (user_id)
  values (new.id)
  on conflict (user_id) do nothing;

  insert into public.streaks (user_id)
  values (new.id)
  on conflict (user_id) do nothing;

  return new;
end;
$$;

commit;
