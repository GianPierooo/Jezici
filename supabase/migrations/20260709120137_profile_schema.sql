-- 20260709120137_profile_schema.sql
-- PERFIL DE USUARIO: esquema AMPLIO (a prueba de futuro), formulario mínimo.
-- Todo NULLABLE → 0 impacto en usuarios existentes. RLS de users intacta
-- (select/update own; el cliente usa las RPC DEFINER get/set_profile).
-- MINIMIZACIÓN DE DATOS deliberada: cumpleaños = SOLO día/mes (sin año → no se
-- puede calcular edad, evita almacenar edad exacta de menores); la mayoría de
-- edad es una CONFIRMACIÓN booleana (is_adult), no una fecha.
begin;

alter table users add column if not exists birthday_day     smallint;  -- 1..31
alter table users add column if not exists birthday_month   smallint;  -- 1..12
alter table users add column if not exists is_adult         boolean;   -- confirmación "soy mayor de edad"
alter table users add column if not exists timezone         text;      -- p.ej. 'UTC-5' / IANA
alter table users add column if not exists gender           text;      -- male|female|other|prefer_not_to_say
alter table users add column if not exists referral_source  text;      -- cómo nos conoció (futuro)
-- Ya existen: name, display_name, avatar_url, country, bio, avatar_color,
-- native_language_id, email.

-- set_profile EXTENDIDO (firma única con defaults → los clientes viejos que
-- llaman con 4 args nombrados siguen funcionando; drop primero para no dejar
-- una sobrecarga ambigua en PostgREST).
drop function if exists set_profile(text, text, text, text);

create or replace function set_profile(
  p_name text default null,
  p_country text default null,
  p_bio text default null,
  p_avatar_color text default null,
  p_birthday_day int default null,
  p_birthday_month int default null,
  p_is_adult boolean default null,
  p_timezone text default null,
  p_gender text default null,
  p_referral_source text default null,
  p_avatar_url text default null)
returns jsonb language plpgsql security definer set search_path = public as $$
declare uid uuid := auth.uid(); v_name text; v_gender text;
begin
  if uid is null then raise exception 'auth required'; end if;
  insert into users (id) values (uid) on conflict (id) do nothing;
  v_name := nullif(btrim(coalesce(p_name, '')), '');
  if v_name is not null then v_name := left(v_name, 40); end if;
  -- gender: whitelist; valor fuera de la lista se IGNORA (no rompe el guardado).
  v_gender := nullif(btrim(coalesce(p_gender, '')), '');
  if v_gender is not null
     and v_gender not in ('male','female','other','prefer_not_to_say') then
    v_gender := null;
  end if;
  update users set
    name = coalesce(v_name, name),
    display_name = coalesce(v_name, display_name),
    country = coalesce(nullif(btrim(coalesce(p_country, '')), ''), country),
    bio = case when p_bio is null then bio else left(btrim(p_bio), 160) end,
    avatar_color = coalesce(nullif(btrim(coalesce(p_avatar_color, '')), ''), avatar_color),
    -- Cumpleaños SOLO día/mes; valores fuera de rango se ignoran.
    birthday_day = coalesce(
      case when p_birthday_day between 1 and 31 then p_birthday_day end, birthday_day),
    birthday_month = coalesce(
      case when p_birthday_month between 1 and 12 then p_birthday_month end, birthday_month),
    is_adult = coalesce(p_is_adult, is_adult),
    timezone = coalesce(nullif(btrim(coalesce(p_timezone, '')), ''), timezone),
    gender = coalesce(v_gender, gender),
    referral_source = coalesce(nullif(btrim(coalesce(p_referral_source, '')), ''), referral_source),
    avatar_url = coalesce(nullif(btrim(coalesce(p_avatar_url, '')), ''), avatar_url),
    updated_at = now()
  where id = uid;
  return get_profile();
end $$;

grant execute on function set_profile(text, text, text, text, int, int, boolean, text, text, text, text) to authenticated;

-- get_profile devuelve el perfil completo (claves nuevas: los clientes viejos
-- las ignoran — compatible).
create or replace function get_profile()
returns jsonb language plpgsql security definer set search_path = public as $$
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
    'needs_name', (coalesce(nullif(display_name, ''), nullif(name, '')) is null),
    'birthday_day', birthday_day,
    'birthday_month', birthday_month,
    'is_adult', is_adult,
    'timezone', timezone,
    'gender', gender,
    'referral_source', referral_source,
    'avatar_url', avatar_url
  ) into v from users where id = uid;
  return coalesce(v, jsonb_build_object('needs_name', true, 'avatar_color', '#6C5CE7'));
end $$;

grant execute on function get_profile() to authenticated;

commit;
