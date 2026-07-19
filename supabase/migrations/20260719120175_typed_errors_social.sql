-- ERRORES TIPADOS 3a pasada (mig 175): RPC sociales + set_profile_required
-- migradas a SQLSTATE custom via jz_err(reason, kind) — cuerpo VERBATIM de la
-- definicion viva; SOLO los `raise exception '<texto>'` cambian a jz_err. El
-- MENSAJE pasa a ser el TOKEN estable exacto (el cliente mapea kind por CODIGO
-- JZxxx y reason por mensaje; el fallback por texto del cliente viejo sigue
-- funcionando via la tabla de tokens). Patron de la mig 167 (claim_handle).

-- jz_do_friend_request: 6 raise(s) -> jz_err
CREATE OR REPLACE FUNCTION public.jz_do_friend_request(p_uid uuid, p_target uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare a uuid; b uuid; v_existing connections%rowtype; v_id uuid;
begin
  if p_target is null then perform jz_err('not_found','not_found'); end if;
  if p_target = p_uid then perform jz_err('cannot_add_yourself','validation'); end if;
  if not jz_is_adult_user(p_target) then perform jz_err('not_found','not_found'); end if; -- no revelar minoría
  if jz_blocked_between(p_uid, p_target) then perform jz_err('unavailable','denied'); end if;
  perform jz_rate_guard(
    (select count(*) from connections where requested_by = p_uid
       and created_at > now() - interval '1 day')::int, 50, 'friend_request/day');
  a := least(p_uid, p_target); b := greatest(p_uid, p_target);
  select * into v_existing from connections where user_a_id = a and user_b_id = b;
  if v_existing.id is not null then
    if v_existing.status = 'accepted' then perform jz_err('already_friends','conflict'); end if;
    if v_existing.status = 'blocked' then perform jz_err('unavailable','denied'); end if;
    if v_existing.requested_by <> p_uid then
      -- el OTRO ya me había enviado: esto la acepta (mutuo) → avísale que se aceptó
      update connections set status = 'accepted', accepted_at = now(), updated_at = now()
        where id = v_existing.id;
      perform jz_notify_friend(p_target, p_uid, 'accepted');
      return jsonb_build_object('status', 'accepted', 'connection_id', v_existing.id);
    end if;
    return jsonb_build_object('status', 'pending', 'connection_id', v_existing.id);
  end if;
  insert into connections (user_a_id, user_b_id, status, requested_by)
  values (a, b, 'pending', p_uid) returning id into v_id;
  perform jz_notify_friend(p_target, p_uid, 'request');  -- ← la señal que faltaba
  return jsonb_build_object('status', 'pending', 'connection_id', v_id);
end $function$
;

-- block_user: 3 raise(s) -> jz_err
CREATE OR REPLACE FUNCTION public.block_user(p_target uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare uid uuid := auth.uid();
begin
  if uid is null then perform jz_err('auth_required','auth'); end if;
  if p_target is null or p_target = uid then perform jz_err('invalid_target','validation'); end if;
  if not exists (select 1 from users where id = p_target) then perform jz_err('no_such_user','not_found'); end if;
  perform jz_rate_guard(
    (select count(*) from blocks where blocker_id = uid and created_at > now() - interval '1 day')::int,
    300, 'block_user/day');
  insert into blocks (blocker_id, blocked_id) values (uid, p_target)
    on conflict (blocker_id, blocked_id) do nothing;
  return jsonb_build_object('blocked', true, 'target', p_target);
end $function$
;

-- report_user: 3 raise(s) -> jz_err
CREATE OR REPLACE FUNCTION public.report_user(p_target uuid, p_reason text, p_context_type report_context DEFAULT 'other'::report_context, p_context_id uuid DEFAULT NULL::uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare uid uuid := auth.uid(); v_id uuid;
begin
  if uid is null then perform jz_err('auth_required','auth'); end if;
  if p_target is null or p_target = uid then perform jz_err('invalid_target','validation'); end if;
  if jz_is_sanctioned(uid) then perform jz_err('account_restricted','denied'); end if;
  perform jz_rate_guard(
    (select count(*) from reports where reporter_id = uid and created_at > now() - interval '1 hour')::int,
    20, 'report_user/hour');
  insert into reports (reporter_id, reported_id, reason, context_type, context_id)
  values (uid, p_target, left(coalesce(p_reason, ''), 500), p_context_type, p_context_id)
  returning id into v_id;
  return jsonb_build_object('reported', true, 'report_id', v_id);
end $function$
;

-- set_profile_required: 4 raise(s) -> jz_err
CREATE OR REPLACE FUNCTION public.set_profile_required(p_name text, p_gender text, p_birthday_day integer, p_birthday_month integer, p_country text DEFAULT NULL::text, p_bio text DEFAULT NULL::text, p_avatar_color text DEFAULT NULL::text, p_timezone text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare uid uuid := auth.uid(); v_name text; v_color text;
begin
  if uid is null then perform jz_err('auth_required','auth'); end if;
  insert into users (id) values (uid) on conflict (id) do nothing;

  v_name := nullif(btrim(coalesce(p_name, '')), '');
  if v_name is null then perform jz_err('name_required','validation'); end if;
  v_name := left(v_name, 40);

  if coalesce(p_gender, '') not in ('male','female','other','prefer_not_to_say') then
    perform jz_err('gender_required','validation');
  end if;

  if p_birthday_day is null or p_birthday_month is null
     or p_birthday_day not between 1 and 31
     or p_birthday_month not between 1 and 12 then
    perform jz_err('birthday_required','validation');
  end if;

  -- avatar_color: hex #RRGGBB; inválido → se conserva el actual (no rompe).
  v_color := case when p_avatar_color ~* '^#?[0-9a-f]{6}$'
                  then '#' || upper(right(replace(p_avatar_color, '#', ''), 6))
                  else null end;

  update users set
    name = v_name,
    display_name = v_name,
    country = case when p_country is null then country
                   else nullif(btrim(p_country), '') end,
    bio = case when p_bio is null then bio else left(btrim(p_bio), 160) end,
    avatar_color = coalesce(v_color, avatar_color),
    birthday_day = p_birthday_day,
    birthday_month = p_birthday_month,
    gender = p_gender,
    timezone = coalesce(nullif(btrim(coalesce(p_timezone, '')), ''), timezone),
    updated_at = now()
  where id = uid;

  return get_profile();
end $function$
;
