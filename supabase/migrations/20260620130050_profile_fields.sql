-- ============================================================================
-- Jezici · Migración 050 · Campos de perfil (nombre real, país, avatar, bio)
-- ----------------------------------------------------------------------------
-- Elevación de diseño (Parte A): captura y muestra el NOMBRE real del usuario
-- (hoy "Aprendiz"), + parámetros de perfil con valor: país (bandera), color de
-- avatar elegible, bio corta. La fecha de ingreso = users.created_at (ya existe).
-- UPDATE directo a users está revocado → set_profile() (SECURITY DEFINER).
-- ============================================================================
begin;

alter table users add column if not exists country text;       -- código ISO-2 (BR, ES, MX…)
alter table users add column if not exists bio text;            -- bio/meta corta (≤160)
alter table users add column if not exists avatar_color text;   -- clave de color del avatar

-- get_profile: perfil propio para el hero del Perfil.
create or replace function get_profile()
returns jsonb
language plpgsql security definer set search_path = public as $$
declare uid uuid := auth.uid(); v jsonb;
begin
  if uid is null then raise exception 'auth required'; end if;
  select jsonb_build_object(
    'name', coalesce(nullif(display_name, ''), nullif(name, '')),
    'email', email,
    'country', country,
    'bio', bio,
    'avatar_color', coalesce(avatar_color, '#6C5CE7'),
    'member_since', to_char(created_at, 'YYYY-MM-DD'),
    'needs_name', (coalesce(nullif(display_name, ''), nullif(name, '')) is null)
  ) into v from users where id = uid;
  return coalesce(v, jsonb_build_object('needs_name', true, 'avatar_color', '#6C5CE7'));
end $$;
grant execute on function get_profile() to authenticated;

-- set_profile: actualiza el perfil propio (saneando). name vacío = no-op del nombre.
create or replace function set_profile(
  p_name text default null, p_country text default null,
  p_bio text default null, p_avatar_color text default null)
returns jsonb
language plpgsql security definer set search_path = public as $$
declare uid uuid := auth.uid(); v_name text;
begin
  if uid is null then raise exception 'auth required'; end if;
  insert into users (id) values (uid) on conflict (id) do nothing;
  v_name := nullif(btrim(coalesce(p_name, '')), '');
  if v_name is not null then v_name := left(v_name, 40); end if;
  update users set
    name = coalesce(v_name, name),
    display_name = coalesce(v_name, display_name),
    country = coalesce(nullif(btrim(coalesce(p_country, '')), ''), country),
    bio = case when p_bio is null then bio else left(btrim(p_bio), 160) end,
    avatar_color = coalesce(nullif(btrim(coalesce(p_avatar_color, '')), ''), avatar_color),
    updated_at = now()
  where id = uid;
  return get_profile();
end $$;
grant execute on function set_profile(text, text, text, text) to authenticated;

commit;
