-- 20260711120146_conversar_p1_security.sql
-- CONVERSAR Fase 2 · P1 — CIMIENTOS DE SEGURIDAD (prerrequisito de TODA ola social).
-- NO abre ninguna función social. Solo la compuerta: age gate 18+, moderación base
-- (blocks/mutes/moderation_actions/reports), rate limits, cola de moderación admin,
-- y RLS estricta (escritura solo por RPC SECURITY DEFINER; bloqueos aplicados en RLS).
-- Decisiones de Gian: 18+ SOLO para social · sin tutores · sin IA · solo Supabase.
begin;

-- ─────────────────────────────────────────────────────────────────────────────
-- 1) AGE GATE (18+): edad real, no checkbox. Minimización: solo el AÑO.
-- ─────────────────────────────────────────────────────────────────────────────
alter table users add column if not exists birth_year smallint;

do $$ begin
  if not exists (select 1 from pg_type where typname='age_tier') then
    create type age_tier as enum ('child','teen','adult');
  end if;
end $$;

-- jz_age_tier: deriva el tier de birth_year (+ mes/día si existen, mig 137).
-- NULL birth_year -> NULL (fail-closed: se trata como NO adulto en el gate social).
create or replace function public.jz_age_tier(p_uid uuid)
returns age_tier language plpgsql stable security definer set search_path to 'public' as $fn$
declare y int; m int; d int; bd date; yrs int;
begin
  select birth_year, birthday_month, birthday_day into y, m, d from users where id = p_uid;
  if y is null then return null; end if;
  if m is not null and d is not null then
    begin bd := make_date(y, m, d); exception when others then bd := make_date(y, 1, 1); end;
    yrs := date_part('year', age(current_date, bd));
  else
    -- solo año conocido -> edad MÍNIMA posible (conservador, nunca sobrestima)
    yrs := (extract(year from current_date)::int - y) - 1;
  end if;
  return case when yrs >= 18 then 'adult' when yrs >= 13 then 'teen' else 'child' end::age_tier;
end $fn$;

-- jz_is_adult_user: la COMPUERTA social. fail-closed (sin fecha -> false).
create or replace function public.jz_is_adult_user(p_uid uuid)
returns boolean language sql stable security definer set search_path to 'public' as $fn$
  select coalesce(jz_age_tier(p_uid) = 'adult', false);
$fn$;

-- submit_age_gate: pantalla NEUTRAL (pide el año, no "¿eres adulto?"). Guarda el año,
-- recomputa is_adult REAL. A los menores NO se les expulsa de la app (18+ es solo
-- social); simplemente no serán adultos para features sociales futuras.
create or replace function public.submit_age_gate(p_birth_year int)
returns jsonb language plpgsql security definer set search_path to 'public' as $fn$
declare uid uuid := auth.uid(); v_tier age_tier;
begin
  if uid is null then raise exception 'auth required'; end if;
  if p_birth_year is null
     or p_birth_year < (extract(year from current_date)::int - 120)
     or p_birth_year > extract(year from current_date)::int then
    raise exception 'invalid birth year';
  end if;
  update users set birth_year = p_birth_year, updated_at = now() where id = uid;
  v_tier := jz_age_tier(uid);
  update users set is_adult = (v_tier = 'adult') where id = uid;
  return jsonb_build_object('age_tier', v_tier, 'is_adult', (v_tier = 'adult'));
end $fn$;

-- get_age_status: para el gate del cliente.
create or replace function public.get_age_status()
returns jsonb language plpgsql security definer set search_path to 'public' as $fn$
declare uid uuid := auth.uid();
begin
  if uid is null then raise exception 'auth required'; end if;
  return jsonb_build_object(
    'has_birthdate', exists (select 1 from users where id = uid and birth_year is not null),
    'age_tier', jz_age_tier(uid),
    'is_adult', jz_is_adult_user(uid));
end $fn$;

-- get_profile: exponer birth_year + age_tier (re-creación con los 2 campos nuevos).
create or replace function public.get_profile()
returns jsonb language plpgsql security definer set search_path to 'public' as $fn$
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
    'referral_source', referral_source, 'avatar_url', avatar_url
  ) into v from users where id = uid;
  return coalesce(v, jsonb_build_object('needs_name', true, 'avatar_color', '#6C5CE7'));
end $fn$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 2) MODERACIÓN — enums + tablas (base, server-side, sin IA)
-- ─────────────────────────────────────────────────────────────────────────────
do $$ begin
  if not exists (select 1 from pg_type where typname='moderation_action_kind') then
    create type moderation_action_kind as enum ('warn','suspend','ban_temp','ban_perm');
  end if;
  if not exists (select 1 from pg_type where typname='report_status') then
    create type report_status as enum ('open','reviewing','resolved','dismissed');
  end if;
  if not exists (select 1 from pg_type where typname='report_context') then
    create type report_context as enum ('profile','message','room','session','other');
  end if;
end $$;

create table if not exists public.blocks (
  id uuid primary key default gen_random_uuid(),
  blocker_id uuid not null references users(id) on delete cascade,
  blocked_id uuid not null references users(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (blocker_id, blocked_id),
  check (blocker_id <> blocked_id)
);
create index if not exists blocks_blocker_idx on public.blocks(blocker_id);
create index if not exists blocks_blocked_idx on public.blocks(blocked_id);

create table if not exists public.mutes (
  id uuid primary key default gen_random_uuid(),
  muter_id uuid not null references users(id) on delete cascade,
  muted_id uuid not null references users(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (muter_id, muted_id),
  check (muter_id <> muted_id)
);
create index if not exists mutes_muter_idx on public.mutes(muter_id);

create table if not exists public.moderation_actions (
  id uuid primary key default gen_random_uuid(),
  target_user_id uuid not null references users(id) on delete cascade,
  kind moderation_action_kind not null,
  reason text,
  actor text not null default 'admin',           -- 'admin' | 'system'
  created_by uuid references users(id),
  expires_at timestamptz,                          -- null = permanente (ban_perm/warn)
  created_at timestamptz not null default now()
);
create index if not exists modact_target_idx on public.moderation_actions(target_user_id);

-- reports: completar (context/status/resolution/handled_by)
alter table public.reports add column if not exists context_type report_context not null default 'other';
alter table public.reports add column if not exists context_id uuid;
alter table public.reports add column if not exists status report_status not null default 'open';
alter table public.reports add column if not exists resolution text;
alter table public.reports add column if not exists handled_by uuid references users(id);
alter table public.reports add column if not exists handled_at timestamptz;

-- ─────────────────────────────────────────────────────────────────────────────
-- 3) HELPERS de seguridad (reutilizables por las futuras olas sociales)
-- ─────────────────────────────────────────────────────────────────────────────
-- Bloqueo EN CUALQUIER dirección corta el contacto (aplicado en RLS, no en cliente).
create or replace function public.jz_blocked_between(p_a uuid, p_b uuid)
returns boolean language sql stable security definer set search_path to 'public' as $fn$
  select exists (
    select 1 from blocks
    where (blocker_id = p_a and blocked_id = p_b)
       or (blocker_id = p_b and blocked_id = p_a));
$fn$;

-- Sanción activa (suspend/ban vigente). Bloquea acciones sociales del sancionado.
create or replace function public.jz_is_sanctioned(p_uid uuid)
returns boolean language sql stable security definer set search_path to 'public' as $fn$
  select exists (
    select 1 from moderation_actions
    where target_user_id = p_uid
      and kind in ('suspend','ban_temp','ban_perm')
      and (expires_at is null or expires_at > now()));
$fn$;

-- Guarda de rate limit reutilizable (lanza si se excede).
create or replace function public.jz_rate_guard(p_used int, p_max int, p_what text)
returns void language plpgsql immutable as $fn$
begin
  if p_used >= p_max then
    raise exception 'rate_limited: %', p_what using errcode = 'check_violation';
  end if;
end $fn$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 4) RPCs de moderación de USUARIO (auth.uid(), rate-limited, no-sancionado)
-- ─────────────────────────────────────────────────────────────────────────────
create or replace function public.block_user(p_target uuid)
returns jsonb language plpgsql security definer set search_path to 'public' as $fn$
declare uid uuid := auth.uid();
begin
  if uid is null then raise exception 'auth required'; end if;
  if p_target is null or p_target = uid then raise exception 'invalid target'; end if;
  if not exists (select 1 from users where id = p_target) then raise exception 'no such user'; end if;
  perform jz_rate_guard(
    (select count(*) from blocks where blocker_id = uid and created_at > now() - interval '1 day')::int,
    300, 'block_user/day');
  insert into blocks (blocker_id, blocked_id) values (uid, p_target)
    on conflict (blocker_id, blocked_id) do nothing;
  return jsonb_build_object('blocked', true, 'target', p_target);
end $fn$;

create or replace function public.unblock_user(p_target uuid)
returns jsonb language plpgsql security definer set search_path to 'public' as $fn$
declare uid uuid := auth.uid();
begin
  if uid is null then raise exception 'auth required'; end if;
  delete from blocks where blocker_id = uid and blocked_id = p_target;
  return jsonb_build_object('blocked', false, 'target', p_target);
end $fn$;

create or replace function public.mute_user(p_target uuid)
returns jsonb language plpgsql security definer set search_path to 'public' as $fn$
declare uid uuid := auth.uid();
begin
  if uid is null then raise exception 'auth required'; end if;
  if p_target is null or p_target = uid then raise exception 'invalid target'; end if;
  insert into mutes (muter_id, muted_id) values (uid, p_target)
    on conflict (muter_id, muted_id) do nothing;
  return jsonb_build_object('muted', true, 'target', p_target);
end $fn$;

create or replace function public.unmute_user(p_target uuid)
returns jsonb language plpgsql security definer set search_path to 'public' as $fn$
declare uid uuid := auth.uid();
begin
  if uid is null then raise exception 'auth required'; end if;
  delete from mutes where muter_id = uid and muted_id = p_target;
  return jsonb_build_object('muted', false, 'target', p_target);
end $fn$;

create or replace function public.report_user(
  p_target uuid, p_reason text, p_context_type report_context default 'other', p_context_id uuid default null)
returns jsonb language plpgsql security definer set search_path to 'public' as $fn$
declare uid uuid := auth.uid(); v_id uuid;
begin
  if uid is null then raise exception 'auth required'; end if;
  if p_target is null or p_target = uid then raise exception 'invalid target'; end if;
  if jz_is_sanctioned(uid) then raise exception 'account restricted'; end if;
  perform jz_rate_guard(
    (select count(*) from reports where reporter_id = uid and created_at > now() - interval '1 hour')::int,
    20, 'report_user/hour');
  insert into reports (reporter_id, reported_id, reason, context_type, context_id)
  values (uid, p_target, left(coalesce(p_reason, ''), 500), p_context_type, p_context_id)
  returning id into v_id;
  return jsonb_build_object('reported', true, 'report_id', v_id);
end $fn$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 5) COLA DE MODERACIÓN admin (am_i_admin, como get_feedback)
-- ─────────────────────────────────────────────────────────────────────────────
create or replace function public.get_reports(p_status text default null, p_limit int default 50)
returns jsonb language plpgsql security definer set search_path to 'public' as $fn$
declare uid uuid := auth.uid();
begin
  if uid is null then raise exception 'auth required'; end if;
  if not exists (select 1 from admins where user_id = uid) then raise exception 'admin only'; end if;
  return coalesce((
    select jsonb_agg(jsonb_build_object(
      'id', r.id,
      'reporter', left(r.reporter_id::text, 8),
      'reported', r.reported_id,                 -- completo: el admin necesita accionar
      'reason', r.reason, 'context_type', r.context_type, 'context_id', r.context_id,
      'status', r.status, 'resolution', r.resolution, 'created_at', r.created_at,
      'reported_sanctioned', jz_is_sanctioned(r.reported_id))
      order by (r.status = 'open') desc, r.created_at desc)
    from reports r
    where p_status is null or r.status::text = p_status
    limit greatest(1, least(coalesce(p_limit, 50), 200))
  ), '[]'::jsonb);
end $fn$;

create or replace function public.mod_apply(
  p_target uuid, p_kind moderation_action_kind, p_reason text default null, p_expires timestamptz default null)
returns jsonb language plpgsql security definer set search_path to 'public' as $fn$
declare uid uuid := auth.uid(); v_id uuid;
begin
  if uid is null then raise exception 'auth required'; end if;
  if not exists (select 1 from admins where user_id = uid) then raise exception 'admin only'; end if;
  if p_target is null then raise exception 'invalid target'; end if;
  insert into moderation_actions (target_user_id, kind, reason, actor, created_by, expires_at)
  values (p_target, p_kind, left(coalesce(p_reason, ''), 500), 'admin', uid, p_expires)
  returning id into v_id;
  return jsonb_build_object('action_id', v_id, 'target', p_target, 'kind', p_kind);
end $fn$;

create or replace function public.resolve_report(
  p_report_id uuid, p_status report_status, p_resolution text default null)
returns jsonb language plpgsql security definer set search_path to 'public' as $fn$
declare uid uuid := auth.uid();
begin
  if uid is null then raise exception 'auth required'; end if;
  if not exists (select 1 from admins where user_id = uid) then raise exception 'admin only'; end if;
  update reports set status = p_status, resolution = left(coalesce(p_resolution, ''), 500),
    handled_by = uid, handled_at = now()
  where id = p_report_id;
  return jsonb_build_object('resolved', true, 'report_id', p_report_id, 'status', p_status);
end $fn$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 6) RLS ESTRICTA — escritura solo por RPC; bloqueos aplicados en RLS; sin using(true)
-- ─────────────────────────────────────────────────────────────────────────────
-- Nuevas tablas: RLS ON, SELECT del dueño + admin; SIN políticas de escritura
-- (INSERT/UPDATE/DELETE los hacen los RPC SECURITY DEFINER).
alter table public.blocks enable row level security;
alter table public.mutes enable row level security;
alter table public.moderation_actions enable row level security;

drop policy if exists blocks_select_own on public.blocks;
create policy blocks_select_own on public.blocks for select to authenticated
  using (auth.uid() = blocker_id or auth.uid() = blocked_id or exists (select 1 from admins a where a.user_id = auth.uid()));

drop policy if exists mutes_select_own on public.mutes;
create policy mutes_select_own on public.mutes for select to authenticated
  using (auth.uid() = muter_id or exists (select 1 from admins a where a.user_id = auth.uid()));

drop policy if exists modact_select on public.moderation_actions;
create policy modact_select on public.moderation_actions for select to authenticated
  using (auth.uid() = target_user_id or exists (select 1 from admins a where a.user_id = auth.uid()));

-- reports: el reportante ve lo suyo (ya) + el admin ve todo.
drop policy if exists reports_admin_select on public.reports;
create policy reports_admin_select on public.reports for select to authenticated
  using (exists (select 1 from admins a where a.user_id = auth.uid()));

-- social_profiles: superficie social existente → 18+ Y sin bloqueo entre ambos.
-- (Da un punto REAL donde el gate de edad y el bloqueo cortan el acceso en RLS.)
drop policy if exists social_select_own on public.social_profiles;
drop policy if exists social_select_gated on public.social_profiles;
create policy social_select_gated on public.social_profiles for select to authenticated
  using (
    auth.uid() = user_id
    or (jz_is_adult_user(auth.uid()) and jz_is_adult_user(user_id)
        and not jz_blocked_between(auth.uid(), user_id))
  );

-- ESCRITURA SOLO POR RPC: revocar write directo de las tablas sociales
-- (RLS ya lo negaba por falta de política; esto es defensa en profundidad).
revoke insert, update, delete, truncate on public.social_profiles from authenticated, anon;
revoke insert, update, delete, truncate on public.connections from authenticated, anon;
revoke insert, update, delete, truncate on public.coop_challenges from authenticated, anon;
revoke insert, update, delete, truncate on public.conversation_rooms from authenticated, anon;
revoke insert, update, delete, truncate on public.room_participants from authenticated, anon;
revoke insert, update, delete, truncate on public.conversation_challenges from authenticated, anon;
revoke insert, update, delete, truncate on public.reports from authenticated, anon;
revoke insert, update, delete, truncate on public.blocks from authenticated, anon;
revoke insert, update, delete, truncate on public.mutes from authenticated, anon;
revoke insert, update, delete, truncate on public.moderation_actions from authenticated, anon;

-- ─────────────────────────────────────────────────────────────────────────────
-- 7) GRANTS de ejecución + revocar helpers internos
-- ─────────────────────────────────────────────────────────────────────────────
grant execute on function public.submit_age_gate(int) to authenticated;
grant execute on function public.get_age_status() to authenticated;
grant execute on function public.block_user(uuid) to authenticated;
grant execute on function public.unblock_user(uuid) to authenticated;
grant execute on function public.mute_user(uuid) to authenticated;
grant execute on function public.unmute_user(uuid) to authenticated;
grant execute on function public.report_user(uuid, text, report_context, uuid) to authenticated;
grant execute on function public.get_reports(text, int) to authenticated;      -- gate interno am_i_admin
grant execute on function public.mod_apply(uuid, moderation_action_kind, text, timestamptz) to authenticated;
grant execute on function public.resolve_report(uuid, report_status, text) to authenticated;
-- helpers internos SOLO llamados dentro de RPCs SECURITY DEFINER → revocables.
revoke all on function public.jz_age_tier(uuid) from public, authenticated, anon;
revoke all on function public.jz_is_sanctioned(uuid) from public, authenticated, anon;
-- jz_is_adult_user y jz_blocked_between se usan DENTRO de la política RLS de
-- social_profiles (se evalúan como el rol INVOCADOR) → deben quedar ejecutables
-- por authenticated, o la política rompería. Son SECURITY DEFINER y solo devuelven
-- un booleano sobre el uid dado (fuga mínima, aceptable frente a romper la RLS).
grant execute on function public.jz_is_adult_user(uuid) to authenticated;
grant execute on function public.jz_blocked_between(uuid, uuid) to authenticated;

commit;
