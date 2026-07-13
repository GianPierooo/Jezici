-- @HANDLE OBLIGATORIO DE ARRANQUE PARA TODOS (beta) — decisión de Gian.
-- 1) get_profile expone `handle` → el cliente puede gate-ar el arranque sin handle.
-- 2) claim_handle deja de exigir jz_social_access (18+): el @handle pasa a ser la
--    IDENTIDAD única obligatoria para ENTRAR (no solo lo social). Un menor necesita
--    su @usuario igual. La DESCUBRIBILIDAD y el PERFIL PÚBLICO siguen 18+
--    (search_users / get_public_profile / list_friends / request_friend sin cambios,
--    todos con su propio gate de adulto) → un menor con @handle NO queda expuesto
--    socialmente; el handle es inerte para él hasta ser adulto.
-- Se conservan TODAS las validaciones: formato (jz_valid_handle), reservados,
-- rate del cambio (1/30d, primer claim libre), unicidad case-insensitive.

-- 1) get_profile + handle
create or replace function public.get_profile()
returns jsonb
language plpgsql
security definer
set search_path to 'public'
as $function$
declare uid uuid := auth.uid(); v jsonb;
begin
  if uid is null then raise exception 'auth required'; end if;
  select jsonb_build_object(
    'name', coalesce(nullif(display_name, ''), nullif(name, '')),
    'email', email, 'country', country, 'bio', bio,
    'avatar_color', coalesce(avatar_color, '#6C5CE7'),
    'member_since', to_char(created_at, 'YYYY-MM-DD'),
    'needs_name', (coalesce(nullif(display_name, ''), nullif(name, '')) is null),
    'birthday_day', birthday_day, 'birthday_month', birthday_month,
    'birth_year', birth_year, 'age_tier', jz_age_tier(id),
    'is_adult', is_adult, 'timezone', timezone, 'gender', gender,
    'referral_source', referral_source, 'avatar_url', avatar_url,
    'handle', handle
  ) into v from users where id = uid;
  return coalesce(v, jsonb_build_object('needs_name', true, 'avatar_color', '#6C5CE7'));
end $function$;

-- 2) claim_handle sin el gate de adulto (identidad universal de arranque)
create or replace function public.claim_handle(p_handle text)
returns jsonb
language plpgsql
security definer
set search_path to 'public'
as $function$
declare uid uuid := auth.uid(); v text; v_cur text; v_at timestamptz;
begin
  if uid is null then raise exception 'auth required'; end if;
  -- (Se quitó el gate jz_social_access: el @handle es identidad de arranque
  --  para TODOS. La descubribilidad social sigue 18+ en sus propias RPCs.)
  v := lower(btrim(coalesce(p_handle, '')));
  v := ltrim(v, '@');
  if not jz_valid_handle(v) then raise exception 'invalid_handle'; end if;
  if v in ('admin','jezici','jezi','matix','support','help','root','moderator',
           'mod','system','staff','official','about','settings','api','null',
           'undefined','me','you','user','users','search','friends') then
    raise exception 'handle_reserved';
  end if;
  select handle, handle_set_at into v_cur, v_at from users where id = uid;
  if v_cur is not null and lower(v_cur) = v then
    return jsonb_build_object('handle', v_cur); -- no-op (mismo handle)
  end if;
  if v_cur is not null and v_at is not null and v_at > now() - interval '30 days' then
    raise exception 'handle_change_rate';
  end if;
  begin
    update users set handle = v, handle_set_at = now(), updated_at = now() where id = uid;
  exception when unique_violation then
    raise exception 'handle_taken';
  end;
  return jsonb_build_object('handle', v);
end $function$;
