-- 20260711120147_conversar_ola1_social.sql
-- CONVERSAR Fase 2 · OLA 1 — social ASÍNCRONO CERRADO (amigos por código + chat
-- texto + corrección + racha con amigos). SIN desconocidos, SIN audio en vivo,
-- SIN IA, solo Supabase. Respeta P1 (mig 146): TODO 18+ (jz_social_access), por
-- RPC SECURITY DEFINER, blocks/mutes en RLS, rate limits (jz_rate_guard).
-- CERRADO al público: gate por allowlist `social_beta` (o admin). La APERTURA
-- espera a los TÉRMINOS legales de UGC (bloqueo de Gian, no código).
begin;

-- ─────────────────────────────────────────────────────────────────────────────
-- 0) COMPUERTA CERRADA: 18+ Y (admin O en la allowlist de beta)
-- ─────────────────────────────────────────────────────────────────────────────
create table if not exists public.social_beta (
  user_id uuid primary key references users(id) on delete cascade,
  added_at timestamptz not null default now()
);
alter table public.social_beta enable row level security;
drop policy if exists socialbeta_select on public.social_beta;
create policy socialbeta_select on public.social_beta for select to authenticated
  using (user_id = auth.uid() or exists (select 1 from admins a where a.user_id = auth.uid()));
revoke insert, update, delete, truncate on public.social_beta from authenticated, anon;

-- jz_social_access: la puerta de TODO lo social. Cerrada al público.
create or replace function public.jz_social_access(p_uid uuid)
returns boolean language sql stable security definer set search_path to 'public' as $fn$
  select jz_is_adult_user(p_uid)
     and (exists (select 1 from admins where user_id = p_uid)
          or exists (select 1 from social_beta where user_id = p_uid));
$fn$;
grant execute on function public.jz_social_access(uuid) to authenticated;  -- se usa en RLS

-- ─────────────────────────────────────────────────────────────────────────────
-- 1) AMIGOS POR CÓDIGO — friend_code + connections (request/accept/reject) + block
-- ─────────────────────────────────────────────────────────────────────────────
alter table public.users add column if not exists friend_code text unique;
alter table public.connections add column if not exists requested_by uuid references users(id);
alter table public.connections add column if not exists accepted_at timestamptz;
-- par canónico (menor,mayor) para no duplicar (a,b)/(b,a)
create unique index if not exists connections_pair_uniq on public.connections(user_a_id, user_b_id);

-- Código legible sin caracteres ambiguos (0/O/1/I fuera).
create or replace function public.jz_gen_friend_code()
returns text language plpgsql volatile as $fn$
declare alpha text := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; c text; i int;
begin
  c := '';
  for i in 1..7 loop
    c := c || substr(alpha, 1 + floor(random() * length(alpha))::int, 1);
  end loop;
  return c;
end $fn$;

create or replace function public.get_social_status()
returns jsonb language plpgsql security definer set search_path to 'public' as $fn$
declare uid uuid := auth.uid(); v_code text; v_access boolean;
begin
  if uid is null then raise exception 'auth required'; end if;
  v_access := jz_social_access(uid);
  if v_access then
    select friend_code into v_code from users where id = uid;
    if v_code is null then
      loop
        begin
          v_code := jz_gen_friend_code();
          update users set friend_code = v_code where id = uid;
          exit;
        exception when unique_violation then end;  -- colisión rara → reintenta
      end loop;
    end if;
  end if;
  return jsonb_build_object('access', v_access, 'is_adult', jz_is_adult_user(uid), 'friend_code', v_code);
end $fn$;

-- Enviar solicitud por CÓDIGO (no hay buscador de desconocidos).
create or replace function public.send_friend_request(p_code text)
returns jsonb language plpgsql security definer set search_path to 'public' as $fn$
declare uid uuid := auth.uid(); v_target uuid; a uuid; b uuid; v_existing connections%rowtype; v_id uuid;
begin
  if uid is null then raise exception 'auth required'; end if;
  if not jz_social_access(uid) then raise exception 'social unavailable'; end if;
  if jz_is_sanctioned(uid) then raise exception 'account restricted'; end if;
  select id into v_target from users where friend_code = upper(btrim(coalesce(p_code, '')));
  if v_target is null then raise exception 'code not found'; end if;
  if v_target = uid then raise exception 'cannot add yourself'; end if;
  if not jz_is_adult_user(v_target) then raise exception 'code not found'; end if; -- no revelar minoría
  if jz_blocked_between(uid, v_target) then raise exception 'unavailable'; end if;
  perform jz_rate_guard(
    (select count(*) from connections where requested_by = uid and created_at > now() - interval '1 day')::int,
    50, 'friend_request/day');
  a := least(uid, v_target); b := greatest(uid, v_target);
  select * into v_existing from connections where user_a_id = a and user_b_id = b;
  if v_existing.id is not null then
    if v_existing.status = 'accepted' then raise exception 'already friends'; end if;
    if v_existing.status = 'blocked' then raise exception 'unavailable'; end if;
    -- pending: si la mandó el OTRO, esto la acepta (mutuo); si la mandé yo, no-op
    if v_existing.requested_by <> uid then
      update connections set status = 'accepted', accepted_at = now(), updated_at = now()
        where id = v_existing.id;
      return jsonb_build_object('status', 'accepted', 'connection_id', v_existing.id);
    end if;
    return jsonb_build_object('status', 'pending', 'connection_id', v_existing.id);
  end if;
  insert into connections (user_a_id, user_b_id, status, requested_by)
  values (a, b, 'pending', uid) returning id into v_id;
  return jsonb_build_object('status', 'pending', 'connection_id', v_id);
end $fn$;

-- Aceptar / rechazar una solicitud entrante.
create or replace function public.respond_friend_request(p_connection_id uuid, p_accept boolean)
returns jsonb language plpgsql security definer set search_path to 'public' as $fn$
declare uid uuid := auth.uid(); v_row connections%rowtype;
begin
  if uid is null then raise exception 'auth required'; end if;
  if not jz_social_access(uid) then raise exception 'social unavailable'; end if;
  select * into v_row from connections where id = p_connection_id;
  if v_row.id is null then raise exception 'not found'; end if;
  if uid not in (v_row.user_a_id, v_row.user_b_id) then raise exception 'not a member'; end if;
  if v_row.requested_by = uid then raise exception 'cannot respond to your own request'; end if;
  if v_row.status <> 'pending' then raise exception 'not pending'; end if;
  if p_accept then
    update connections set status = 'accepted', accepted_at = now(), updated_at = now() where id = p_connection_id;
    return jsonb_build_object('status', 'accepted');
  else
    delete from connections where id = p_connection_id;
    return jsonb_build_object('status', 'rejected');
  end if;
end $fn$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 2) CHAT DE TEXTO 1:1 — messages + filtro de contacto + rate limit + Realtime
-- ─────────────────────────────────────────────────────────────────────────────
create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  connection_id uuid not null references connections(id) on delete cascade,
  sender_id uuid not null references users(id) on delete cascade,
  kind text not null default 'text',        -- text | voice | system
  body text,
  audio_url text,                            -- reservado para A3 (notas de voz)
  reply_to uuid references messages(id),
  created_at timestamptz not null default now(),
  deleted_at timestamptz
);
create index if not exists messages_conn_idx on public.messages(connection_id, created_at);

-- Filtro de datos de contacto (que no saquen la conversación de la plataforma).
create or replace function public.jz_strip_contact(p text)
returns text language sql immutable as $fn$
  select regexp_replace(regexp_replace(regexp_replace(regexp_replace(
      coalesce(p, ''),
      '[[:alnum:]._%+-]+@[[:alnum:].-]+\.[[:alpha:]]{2,}', '⟨•⟩', 'g'),          -- email
      '(https?://|www\.)[^[:space:]]+', '⟨•⟩', 'gi'),                            -- url
      '[+]?[[:digit:]][[:digit:][:space:]().-]{6,}[[:digit:]]', '⟨•⟩', 'g'),     -- teléfono
      '@[[:alnum:]_]{2,}', '⟨•⟩', 'g');                                          -- @handle
$fn$;

create or replace function public.send_message(p_connection_id uuid, p_body text)
returns jsonb language plpgsql security definer set search_path to 'public' as $fn$
declare uid uuid := auth.uid(); v_row connections%rowtype; v_id uuid; v_clean text;
begin
  if uid is null then raise exception 'auth required'; end if;
  if not jz_social_access(uid) then raise exception 'social unavailable'; end if;
  if jz_is_sanctioned(uid) then raise exception 'account restricted'; end if;
  select * into v_row from connections where id = p_connection_id;
  if v_row.id is null or uid not in (v_row.user_a_id, v_row.user_b_id) then raise exception 'not a member'; end if;
  if v_row.status <> 'accepted' then raise exception 'not friends'; end if;
  if jz_blocked_between(v_row.user_a_id, v_row.user_b_id) then raise exception 'unavailable'; end if;
  if btrim(coalesce(p_body, '')) = '' then raise exception 'empty'; end if;
  perform jz_rate_guard(
    (select count(*) from messages where sender_id = uid and created_at > now() - interval '1 minute')::int,
    30, 'message/min');
  v_clean := jz_strip_contact(left(p_body, 2000));   -- FILTRO aplicado al guardar
  insert into messages (connection_id, sender_id, kind, body)
  values (p_connection_id, uid, 'text', v_clean) returning id into v_id;
  update connections set updated_at = now() where id = p_connection_id;
  return jsonb_build_object('id', v_id, 'body', v_clean, 'created_at', now());
end $fn$;

create or replace function public.list_messages(p_connection_id uuid, p_limit int default 50)
returns jsonb language plpgsql security definer set search_path to 'public' as $fn$
declare uid uuid := auth.uid();
begin
  if uid is null then raise exception 'auth required'; end if;
  if not jz_social_access(uid) then raise exception 'social unavailable'; end if;
  -- la RLS de messages ya restringe; validamos membresía para el 403 claro
  if not exists (select 1 from connections c where c.id = p_connection_id
      and c.status = 'accepted' and uid in (c.user_a_id, c.user_b_id)
      and not jz_blocked_between(c.user_a_id, c.user_b_id)) then
    raise exception 'not available';
  end if;
  return coalesce((
    select jsonb_agg(x order by x.created_at)
    from (
      select m.id, m.sender_id, m.kind, m.body, m.audio_url, m.created_at,
             (m.sender_id = uid) as mine,
             (select jsonb_build_object('corrected', cr.corrected, 'note', cr.note, 'by', cr.corrector_id)
                from corrections cr where cr.message_id = m.id order by cr.created_at desc limit 1) as correction
      from messages m
      where m.connection_id = p_connection_id and m.deleted_at is null
      order by m.created_at desc limit greatest(1, least(coalesce(p_limit, 50), 200))
    ) x
  ), '[]'::jsonb);
end $fn$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 3) CORRECCIÓN ENTRE AMIGOS — corrections (corriges el mensaje del OTRO)
-- ─────────────────────────────────────────────────────────────────────────────
create table if not exists public.corrections (
  id uuid primary key default gen_random_uuid(),
  message_id uuid not null references messages(id) on delete cascade,
  corrector_id uuid not null references users(id) on delete cascade,
  corrected text not null,
  note text,
  created_at timestamptz not null default now()
);
create index if not exists corrections_msg_idx on public.corrections(message_id);

create or replace function public.add_correction(p_message_id uuid, p_corrected text, p_note text default null)
returns jsonb language plpgsql security definer set search_path to 'public' as $fn$
declare uid uuid := auth.uid(); v_msg messages%rowtype; v_conn connections%rowtype; v_id uuid;
begin
  if uid is null then raise exception 'auth required'; end if;
  if not jz_social_access(uid) then raise exception 'social unavailable'; end if;
  select * into v_msg from messages where id = p_message_id;
  if v_msg.id is null then raise exception 'not found'; end if;
  if v_msg.sender_id = uid then raise exception 'cannot correct your own message'; end if;
  select * into v_conn from connections where id = v_msg.connection_id;
  if v_conn.status <> 'accepted' or uid not in (v_conn.user_a_id, v_conn.user_b_id) then raise exception 'not a member'; end if;
  if jz_blocked_between(v_conn.user_a_id, v_conn.user_b_id) then raise exception 'unavailable'; end if;
  insert into corrections (message_id, corrector_id, corrected, note)
  values (p_message_id, uid, left(p_corrected, 2000), left(coalesce(p_note, ''), 500)) returning id into v_id;
  return jsonb_build_object('id', v_id);
end $fn$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 4) RACHA CON AMIGOS — derivada de daily_goals (ambos cumplieron la meta)
-- ─────────────────────────────────────────────────────────────────────────────
-- Días consecutivos (hoy o ayer hacia atrás) en que AMBOS cumplieron su meta.
create or replace function public.jz_friend_streak(p_a uuid, p_b uuid)
returns int language plpgsql stable security definer set search_path to 'public' as $fn$
declare v_day date; v_count int := 0;
begin
  -- ambos cumplieron HOY? si no, ¿ayer? (gracia de 1 día); si ninguno, 0
  if exists (select 1 from daily_goals where user_id = p_a and goal_date = current_date and xp_earned >= goal_xp)
     and exists (select 1 from daily_goals where user_id = p_b and goal_date = current_date and xp_earned >= goal_xp) then
    v_day := current_date;
  elsif exists (select 1 from daily_goals where user_id = p_a and goal_date = current_date - 1 and xp_earned >= goal_xp)
     and exists (select 1 from daily_goals where user_id = p_b and goal_date = current_date - 1 and xp_earned >= goal_xp) then
    v_day := current_date - 1;
  else
    return 0;
  end if;
  loop
    exit when not (
      exists (select 1 from daily_goals where user_id = p_a and goal_date = v_day and xp_earned >= goal_xp)
      and exists (select 1 from daily_goals where user_id = p_b and goal_date = v_day and xp_earned >= goal_xp));
    v_count := v_count + 1;
    v_day := v_day - 1;
  end loop;
  return v_count;
end $fn$;

-- Lista de amigos + solicitudes (entrantes/salientes) + racha compartida.
create or replace function public.list_friends()
returns jsonb language plpgsql security definer set search_path to 'public' as $fn$
declare uid uuid := auth.uid();
begin
  if uid is null then raise exception 'auth required'; end if;
  if not jz_social_access(uid) then raise exception 'social unavailable'; end if;
  return jsonb_build_object(
    'friends', coalesce((
      select jsonb_agg(jsonb_build_object(
        'connection_id', c.id, 'user_id', o.id,
        'name', coalesce(nullif(o.display_name,''), nullif(o.name,''), 'Aprendiz'),
        'avatar_color', coalesce(o.avatar_color, '#6C5CE7'),
        'streak', jz_friend_streak(uid, o.id))
        order by jz_friend_streak(uid, o.id) desc)
      from connections c
      join users o on o.id = case when c.user_a_id = uid then c.user_b_id else c.user_a_id end
      where c.status = 'accepted' and uid in (c.user_a_id, c.user_b_id)
        and not jz_blocked_between(c.user_a_id, c.user_b_id)
    ), '[]'::jsonb),
    'incoming', coalesce((
      select jsonb_agg(jsonb_build_object('connection_id', c.id, 'user_id', o.id,
        'name', coalesce(nullif(o.display_name,''), nullif(o.name,''), 'Aprendiz'),
        'avatar_color', coalesce(o.avatar_color, '#6C5CE7')))
      from connections c
      join users o on o.id = c.requested_by
      where c.status = 'pending' and c.requested_by <> uid and uid in (c.user_a_id, c.user_b_id)
        and not jz_blocked_between(c.user_a_id, c.user_b_id)
    ), '[]'::jsonb),
    'outgoing', coalesce((
      select jsonb_agg(jsonb_build_object('connection_id', c.id))
      from connections c
      where c.status = 'pending' and c.requested_by = uid
    ), '[]'::jsonb));
end $fn$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 5) RLS de messages/corrections (miembros aceptados, no bloqueados) + Realtime
-- ─────────────────────────────────────────────────────────────────────────────
alter table public.messages enable row level security;
alter table public.corrections enable row level security;

drop policy if exists messages_select on public.messages;
create policy messages_select on public.messages for select to authenticated using (
  exists (select 1 from connections c
    where c.id = connection_id and c.status = 'accepted'
      and auth.uid() in (c.user_a_id, c.user_b_id)
      and not jz_blocked_between(c.user_a_id, c.user_b_id)));

drop policy if exists corrections_select on public.corrections;
create policy corrections_select on public.corrections for select to authenticated using (
  exists (select 1 from messages m join connections c on c.id = m.connection_id
    where m.id = message_id and c.status = 'accepted'
      and auth.uid() in (c.user_a_id, c.user_b_id)
      and not jz_blocked_between(c.user_a_id, c.user_b_id)));

-- escritura solo por RPC (sin política de INSERT + revocar grants)
revoke insert, update, delete, truncate on public.messages from authenticated, anon;
revoke insert, update, delete, truncate on public.corrections from authenticated, anon;

-- Realtime: recibir mensajes en vivo (la RLS aplica también al canal Realtime).
do $$ begin
  begin alter publication supabase_realtime add table public.messages; exception when duplicate_object then end;
end $$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 6) GRANTS de ejecución (todos gatean internamente por jz_social_access)
-- ─────────────────────────────────────────────────────────────────────────────
grant execute on function public.get_social_status() to authenticated;
grant execute on function public.send_friend_request(text) to authenticated;
grant execute on function public.respond_friend_request(uuid, boolean) to authenticated;
grant execute on function public.list_friends() to authenticated;
grant execute on function public.send_message(uuid, text) to authenticated;
grant execute on function public.list_messages(uuid, int) to authenticated;
grant execute on function public.add_correction(uuid, text, text) to authenticated;
revoke all on function public.jz_gen_friend_code() from public, authenticated, anon;
revoke all on function public.jz_strip_contact(text) from public, authenticated, anon;
-- jz_friend_streak se usa dentro de list_friends (DEFINER) → no exponer directo
revoke all on function public.jz_friend_streak(uuid, uuid) from public, authenticated, anon;

commit;
