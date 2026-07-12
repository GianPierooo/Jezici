-- ═══════════════════════════════════════════════════════════════════════════
-- CONVERSAR · T3 — social fácil: @handle único + buscar + perfil público +
-- sugerencias de amigos.  (mig 149, 2026-07-12)
--
-- Sobre P1 (mig 146: age gate 18+, blocks/mutes/rate/filtro) + Ola 1 (mig 147/148:
-- amigos por código + chat + notas de voz + co-op). Decisiones de Gian (firmes):
--   · social 18+ SOLO   · @handle OBLIGATORIO de elegir para usar lo social
--   · nombre visible sigue LIBRE (el certificado NO se toca; usa display_name/name)
--
-- SEGURIDAD (innegociable): todo por RPC SECURITY DEFINER; blocks aplicados en la
-- lógica en AMBAS direcciones (jz_blocked_between); 18+ innegociable; NADA
-- using(true); el aislamiento airtight de users (RLS users_select_own) NO se
-- toca — el perfil público expone SOLO una vista acotada vía RPC DEFINER.
-- ═══════════════════════════════════════════════════════════════════════════

-- ─────────────────────────────────────────────────────────────────────────────
-- 1) @HANDLE ÚNICO + privacidad "aparecer en búsqueda"
-- ─────────────────────────────────────────────────────────────────────────────
alter table public.users add column if not exists handle text;
alter table public.users add column if not exists handle_set_at timestamptz;
-- privacidad: aparecer en búsqueda/sugerencias. Adulto opta a lo social → default true.
alter table public.users add column if not exists discoverable boolean not null default true;

-- Unicidad CASE-INSENSITIVE (dos usuarios no pueden compartir handle; el NOMBRE sí
-- puede repetirse — no tocamos name/display_name).
create unique index if not exists users_handle_lower_uk
  on public.users (lower(handle)) where handle is not null;

-- Formato sano: 3–20 chars de a-z 0-9 _ , al menos una letra (evita @123 tipo-id).
create or replace function public.jz_valid_handle(p text)
returns boolean language sql immutable as $$
  select p is not null and p ~ '^[a-z0-9_]{3,20}$' and p ~ '[a-z]';
$$;

-- claim_handle: elige/actualiza el handle. auth + adulto. Colisión → error claro.
-- Editable con rate (1 cambio / 30 días) para no romper menciones/estabilidad.
create or replace function public.claim_handle(p_handle text)
returns jsonb language plpgsql security definer set search_path to 'public' as $$
declare uid uuid := auth.uid(); v text; v_cur text; v_at timestamptz;
begin
  if uid is null then raise exception 'auth required'; end if;
  if not jz_social_access(uid) then raise exception 'social unavailable'; end if;
  -- normaliza: minúsculas, sin @ ni espacios
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
  -- rate del CAMBIO (el primer claim es libre)
  if v_cur is not null and v_at is not null and v_at > now() - interval '30 days' then
    raise exception 'handle_change_rate';
  end if;
  begin
    update users set handle = v, handle_set_at = now(), updated_at = now() where id = uid;
  exception when unique_violation then
    raise exception 'handle_taken';
  end;
  return jsonb_build_object('handle', v);
end $$;

-- privacidad: aparecer o no en búsqueda/sugerencias.
create or replace function public.set_discoverable(p_on boolean)
returns jsonb language plpgsql security definer set search_path to 'public' as $$
declare uid uuid := auth.uid();
begin
  if uid is null then raise exception 'auth required'; end if;
  update users set discoverable = coalesce(p_on, true), updated_at = now() where id = uid;
  return jsonb_build_object('discoverable', coalesce(p_on, true));
end $$;

-- get_social_status extendido: + handle, needs_handle (gate del cliente), discoverable.
create or replace function public.get_social_status()
returns jsonb language plpgsql security definer set search_path to 'public' as $$
declare uid uuid := auth.uid(); v_code text; v_access boolean; v_handle text; v_disc boolean;
begin
  if uid is null then raise exception 'auth required'; end if;
  v_access := jz_social_access(uid);
  if v_access then
    select friend_code, handle, discoverable into v_code, v_handle, v_disc from users where id = uid;
    if v_code is null then
      loop
        begin
          v_code := jz_gen_friend_code();
          update users set friend_code = v_code where id = uid;
          exit;
        exception when unique_violation then end;
      end loop;
    end if;
  end if;
  return jsonb_build_object(
    'access', v_access, 'is_adult', jz_is_adult_user(uid),
    'friend_code', v_code, 'handle', v_handle,
    'needs_handle', (v_access and v_handle is null),
    'discoverable', coalesce(v_disc, true));
end $$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 2) Relación entre dos usuarios (para search/perfil/sugerencias) — INTERNO
-- ─────────────────────────────────────────────────────────────────────────────
create or replace function public.jz_relationship(p_uid uuid, p_other uuid)
returns text language sql stable security definer set search_path to 'public' as $$
  select case
    when p_uid = p_other then 'self'
    when exists (select 1 from blocks where blocker_id = p_uid and blocked_id = p_other) then 'blocked_out'
    when exists (select 1 from blocks where blocker_id = p_other and blocked_id = p_uid) then 'blocked_in'
    else coalesce((
      select case
        when c.status = 'accepted' then 'friends'
        when c.status = 'pending' and c.requested_by = p_uid then 'pending_out'
        when c.status = 'pending' then 'pending_in'
        when c.status = 'blocked' then 'blocked'
        else 'none' end
      from connections c
      where c.user_a_id = least(p_uid, p_other)
        and c.user_b_id = greatest(p_uid, p_other)), 'none')
  end;
$$;

-- Niveles de idioma "públicos" (nivel más alto por curso con progreso) — INTERNO.
create or replace function public.jz_public_levels(p_uid uuid)
returns jsonb language sql stable security definer set search_path to 'public' as $$
  select coalesce(jsonb_agg(jsonb_build_object(
           'lang', lt.code, 'lang_name', lt.name, 'level', jz_cefr(s.mx))
           order by s.mx desc, lt.code), '[]'::jsonb)
  from (
    select course_id, max(jz_rank(cefr_level::text)) mx
    from user_skill_levels where user_id = p_uid group by course_id
  ) s
  join courses c on c.id = s.course_id
  join languages lt on lt.id = c.target_language_id;
$$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 3) Solicitud de amistad — helper compartido (código Y por user_id)
-- ─────────────────────────────────────────────────────────────────────────────
-- Fuente ÚNICA de la lógica: adulto-adulto, no-self, no-bloqueo, rate 50/día,
-- par canónico, auto-acepta si el otro ya pidió. INTERNO (no ejecutable directo).
create or replace function public.jz_do_friend_request(p_uid uuid, p_target uuid)
returns jsonb language plpgsql security definer set search_path to 'public' as $$
declare a uuid; b uuid; v_existing connections%rowtype; v_id uuid;
begin
  if p_target is null then raise exception 'not found'; end if;
  if p_target = p_uid then raise exception 'cannot add yourself'; end if;
  if not jz_is_adult_user(p_target) then raise exception 'not found'; end if; -- no revelar minoría
  if jz_blocked_between(p_uid, p_target) then raise exception 'unavailable'; end if;
  perform jz_rate_guard(
    (select count(*) from connections where requested_by = p_uid
       and created_at > now() - interval '1 day')::int, 50, 'friend_request/day');
  a := least(p_uid, p_target); b := greatest(p_uid, p_target);
  select * into v_existing from connections where user_a_id = a and user_b_id = b;
  if v_existing.id is not null then
    if v_existing.status = 'accepted' then raise exception 'already friends'; end if;
    if v_existing.status = 'blocked' then raise exception 'unavailable'; end if;
    if v_existing.requested_by <> p_uid then
      update connections set status = 'accepted', accepted_at = now(), updated_at = now()
        where id = v_existing.id;
      return jsonb_build_object('status', 'accepted', 'connection_id', v_existing.id);
    end if;
    return jsonb_build_object('status', 'pending', 'connection_id', v_existing.id);
  end if;
  insert into connections (user_a_id, user_b_id, status, requested_by)
  values (a, b, 'pending', p_uid) returning id into v_id;
  return jsonb_build_object('status', 'pending', 'connection_id', v_id);
end $$;

-- send_friend_request(code) reescrito para usar el helper (misma firma/salida).
create or replace function public.send_friend_request(p_code text)
returns jsonb language plpgsql security definer set search_path to 'public' as $$
declare uid uuid := auth.uid(); v_target uuid;
begin
  if uid is null then raise exception 'auth required'; end if;
  if not jz_social_access(uid) then raise exception 'social unavailable'; end if;
  if jz_is_sanctioned(uid) then raise exception 'account restricted'; end if;
  select id into v_target from users where friend_code = upper(btrim(coalesce(p_code, '')));
  if v_target is null then raise exception 'code not found'; end if;
  return jz_do_friend_request(uid, v_target);
end $$;

-- request_friend(user_id): solicitar desde búsqueda/perfil/sugerencias.
create or replace function public.request_friend(p_user_id uuid)
returns jsonb language plpgsql security definer set search_path to 'public' as $$
declare uid uuid := auth.uid();
begin
  if uid is null then raise exception 'auth required'; end if;
  if not jz_social_access(uid) then raise exception 'social unavailable'; end if;
  if jz_is_sanctioned(uid) then raise exception 'account restricted'; end if;
  return jz_do_friend_request(uid, p_user_id);
end $$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 4) BUSCAR por nombre o @handle (rate-limited; solo campos públicos)
-- ─────────────────────────────────────────────────────────────────────────────
-- log mínimo solo para rate-limit de búsqueda (RLS: dueño; inserta solo el DEFINER).
create table if not exists public.social_search_log (
  id bigint generated by default as identity primary key,
  user_id uuid not null,
  created_at timestamptz not null default now()
);
alter table public.social_search_log enable row level security;
drop policy if exists ssl_select_own on public.social_search_log;
create policy ssl_select_own on public.social_search_log
  for select to authenticated using (auth.uid() = user_id);
create index if not exists ssl_user_time on public.social_search_log (user_id, created_at desc);
revoke all on public.social_search_log from anon, authenticated;

create or replace function public.search_users(p_q text)
returns jsonb language plpgsql security definer set search_path to 'public' as $$
declare uid uuid := auth.uid(); v_q text; v_esc text; v_used int;
begin
  if uid is null then raise exception 'auth required'; end if;
  if not jz_social_access(uid) then raise exception 'social unavailable'; end if;
  v_q := lower(btrim(coalesce(p_q, '')));
  v_q := ltrim(v_q, '@');
  if length(v_q) < 2 then return jsonb_build_object('results', '[]'::jsonb); end if;
  -- rate: 30 búsquedas / minuto
  select count(*) into v_used from social_search_log
    where user_id = uid and created_at > now() - interval '1 minute';
  perform jz_rate_guard(v_used, 30, 'search/min');
  insert into social_search_log (user_id) values (uid);
  -- escapa comodines LIKE del término del usuario
  v_esc := replace(replace(replace(v_q, '\', '\\'), '%', '\%'), '_', '\_');
  return jsonb_build_object('results', coalesce((
    select jsonb_agg(jsonb_build_object(
      'user_id', u.id, 'handle', u.handle,
      'name', coalesce(nullif(u.display_name, ''), nullif(u.name, ''), 'Aprendiz'),
      'avatar_color', coalesce(u.avatar_color, '#6C5CE7'),
      'avatar_url', u.avatar_url, 'country', u.country,
      'relationship', jz_relationship(uid, u.id))
      order by (lower(u.handle) = v_q) desc,          -- match exacto de handle primero
               (u.handle ilike v_esc || '%') desc,     -- luego prefijo de handle
               u.display_name)
    from users u
    where u.id <> uid
      and jz_is_adult_user(u.id)                       -- 18+ innegociable
      and coalesce(u.discoverable, true)               -- privacidad: aparecer en búsqueda
      and not jz_is_sanctioned(u.id)
      and not jz_blocked_between(uid, u.id)            -- bloqueo en AMBAS direcciones
      and (
        u.handle ilike v_esc || '%' escape '\'
        or u.display_name ilike '%' || v_esc || '%' escape '\'
        or u.name ilike '%' || v_esc || '%' escape '\'
      )
    limit 20), '[]'::jsonb));
end $$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 5) PERFIL PÚBLICO (superficie acotada y DELIBERADA — SOLO campos públicos)
-- ─────────────────────────────────────────────────────────────────────────────
-- Expone SOLO: display_name, handle, avatar, país, racha, logros, niveles de
-- idioma + relación. NUNCA email, birth_year/edad, bio ni progreso interno.
-- Si el objetivo no es adulto, o está bloqueado, o no es descubrible y no es
-- amigo/pendiente → 'not found' (no se revela su existencia).
create or replace function public.get_public_profile(p_user_id uuid)
returns jsonb language plpgsql security definer set search_path to 'public' as $$
declare uid uuid := auth.uid(); u users%rowtype; v_rel text; v_disc boolean;
begin
  if uid is null then raise exception 'auth required'; end if;
  if not jz_social_access(uid) then raise exception 'social unavailable'; end if;
  if p_user_id is null then raise exception 'not found'; end if;
  select * into u from users where id = p_user_id;
  if u.id is null then raise exception 'not found'; end if;
  if not jz_is_adult_user(u.id) then raise exception 'not found'; end if;
  if jz_blocked_between(uid, u.id) then raise exception 'not found'; end if;
  v_rel := jz_relationship(uid, u.id);
  v_disc := coalesce(u.discoverable, true);
  -- privado (no descubrible) y sin vínculo → no se revela
  if uid <> u.id and not v_disc
     and v_rel not in ('friends', 'pending_out', 'pending_in') then
    raise exception 'not found';
  end if;
  return jsonb_build_object(
    'user_id', u.id,
    'handle', u.handle,
    'name', coalesce(nullif(u.display_name, ''), nullif(u.name, ''), 'Aprendiz'),
    'avatar_color', coalesce(u.avatar_color, '#6C5CE7'),
    'avatar_url', u.avatar_url,
    'country', u.country,
    'member_since', to_char(u.created_at, 'YYYY'),
    'relationship', v_rel,
    -- id de la conexión entre ambos (si existe) → aceptar/chatear desde el perfil.
    -- Es la fila que el propio RLS conn_select_member ya permite a un miembro.
    'connection_id', (select c.id from connections c
      where c.user_a_id = least(uid, u.id) and c.user_b_id = greatest(uid, u.id)),
    'streak', coalesce((select current_streak from streaks where user_id = u.id), 0),
    'levels', jz_public_levels(u.id),
    'badges', coalesce((
      select jsonb_agg(jsonb_build_object('code', a.code, 'name', a.name)
             order by ua.unlocked_at desc)
      from user_achievements ua join achievements a on a.id = ua.achievement_id
      where ua.user_id = u.id limit 12), '[]'::jsonb)
  );
end $$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 6) SUGERENCIAS de amigos (señal INOCUA: mismo curso + nivel cercano)
-- ─────────────────────────────────────────────────────────────────────────────
-- Excluye: yo, amigos, solicitudes pendientes, bloqueados (ambas dir), menores,
-- no-descubribles, sancionados. NADA de ubicación ni datos sensibles.
create or replace function public.suggest_friends()
returns jsonb language plpgsql security definer set search_path to 'public' as $$
declare uid uuid := auth.uid(); v_course uuid; v_rank int;
begin
  if uid is null then raise exception 'auth required'; end if;
  if not jz_social_access(uid) then raise exception 'social unavailable'; end if;
  select course_id into v_course from user_active_course where user_id = uid;
  if v_course is null then return jsonb_build_object('suggestions', '[]'::jsonb); end if;
  -- mi nivel en ese curso (más alto entre skills), para ordenar por cercanía
  select coalesce(max(jz_rank(cefr_level::text)), 0) into v_rank
    from user_skill_levels where user_id = uid and course_id = v_course;
  return jsonb_build_object('suggestions', coalesce((
    select jsonb_agg(x.card order by x.dist, x.mx desc)
    from (
      select jsonb_build_object(
               'user_id', u.id, 'handle', u.handle,
               'name', coalesce(nullif(u.display_name, ''), nullif(u.name, ''), 'Aprendiz'),
               'avatar_color', coalesce(u.avatar_color, '#6C5CE7'),
               'avatar_url', u.avatar_url, 'country', u.country,
               'level', jz_cefr(coalesce(lv.mx, 0)),
               'streak', coalesce(s.current_streak, 0)) card,
             abs(coalesce(lv.mx, 0) - v_rank) dist,
             coalesce(lv.mx, 0) mx
      from user_active_course ua
      join users u on u.id = ua.user_id
      left join (
        select user_id, max(jz_rank(cefr_level::text)) mx
        from user_skill_levels where course_id = v_course group by user_id
      ) lv on lv.user_id = u.id
      left join streaks s on s.user_id = u.id
      where ua.course_id = v_course
        and u.id <> uid
        and jz_is_adult_user(u.id)
        and coalesce(u.discoverable, true)
        and not jz_is_sanctioned(u.id)
        and not jz_blocked_between(uid, u.id)
        and not exists (
          select 1 from connections c
          where c.user_a_id = least(uid, u.id) and c.user_b_id = greatest(uid, u.id))
      limit 10
    ) x), '[]'::jsonb));
end $$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 7) GRANTS — escritura SOLO por RPC; internos revocados
-- ─────────────────────────────────────────────────────────────────────────────
revoke execute on function public.jz_do_friend_request(uuid, uuid) from public, anon, authenticated;
revoke execute on function public.jz_relationship(uuid, uuid) from public, anon, authenticated;
revoke execute on function public.jz_public_levels(uuid) from public, anon, authenticated;
revoke execute on function public.jz_valid_handle(text) from anon;

grant execute on function public.claim_handle(text) to authenticated;
grant execute on function public.set_discoverable(boolean) to authenticated;
grant execute on function public.request_friend(uuid) to authenticated;
grant execute on function public.search_users(text) to authenticated;
grant execute on function public.get_public_profile(uuid) to authenticated;
grant execute on function public.suggest_friends() to authenticated;
grant execute on function public.get_social_status() to authenticated;
grant execute on function public.send_friend_request(text) to authenticated;
