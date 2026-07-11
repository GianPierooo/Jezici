-- 20260711120148_conversar_ola1_complete.sql
-- CONVERSAR · OLA 1 COMPLETA + APERTURA AL PÚBLICO.
-- Gian confirma: el ABOGADO APROBÓ los términos UGC/social → se abre lo async.
-- (B) jz_social_access pasa a SOLO "adulto 18+" (ya no exige admin/allowlist).
-- (A3) NOTAS DE VOZ: bucket privado `voice-notes` con RLS de Storage por
--      membresía de la conexión + send_voice_message (kind='voice').
-- (A6) CO-OP: coop_challenges completado (crear/aceptar; progreso DERIVADO de
--      daily_goals de AMBOS -> anti-trampa; recompensa lazy al completar).
-- Seguridad P1 intacta: RPC DEFINER, blocks/mutes en RLS, jz_rate_guard,
-- filtro de contacto, 18+. Retención de audio para abuso: los archivos NO se
-- pueden borrar por el usuario (solo service_role); purga programada = diferido.
begin;

-- ─────────────────────────────────────────────────────────────────────────────
-- (B) APERTURA: social = SOLO adulto 18+ (legal UGC aprobado por abogado)
-- ─────────────────────────────────────────────────────────────────────────────
create or replace function public.jz_social_access(p_uid uuid)
returns boolean language sql stable security definer set search_path to 'public' as $fn$
  select jz_is_adult_user(p_uid);
$fn$;
-- (social_beta queda como tabla inerte; ya no gatea nada.)

-- ─────────────────────────────────────────────────────────────────────────────
-- (A6) CO-OP — retos en pareja sobre coop_challenges
-- ─────────────────────────────────────────────────────────────────────────────
alter table public.coop_challenges add column if not exists created_by uuid references users(id);
alter table public.coop_challenges add column if not exists accepted_at timestamptz;
alter table public.coop_challenges add column if not exists expires_at timestamptz;
alter table public.coop_challenges add column if not exists completed_at timestamptz;
alter table public.coop_challenges add column if not exists reward_gold int not null default 50;

-- Progreso DERIVADO (anti-trampa): XP sumado por AMBOS (daily_goals) desde la
-- aceptación hasta el vencimiento. Nadie "avanza" a mano.
create or replace function public.jz_coop_progress(p_id uuid)
returns numeric language sql stable security definer set search_path to 'public' as $fn$
  select coalesce((
    select sum(dg.xp_earned)::numeric
    from coop_challenges cc
    join daily_goals dg on dg.user_id in (cc.user_a_id, cc.user_b_id)
      and dg.goal_date >= cc.accepted_at::date
      and dg.goal_date <= coalesce(cc.expires_at, now())::date
    where cc.id = p_id and cc.accepted_at is not null
  ), 0);
$fn$;

create or replace function public.create_coop(p_friend uuid, p_target_xp int)
returns jsonb language plpgsql security definer set search_path to 'public' as $fn$
declare uid uuid := auth.uid(); a uuid; b uuid; v_id uuid;
begin
  if uid is null then raise exception 'auth required'; end if;
  if not jz_social_access(uid) then raise exception 'social unavailable'; end if;
  if jz_is_sanctioned(uid) then raise exception 'account restricted'; end if;
  if p_friend is null or p_friend = uid then raise exception 'invalid target'; end if;
  if p_target_xp is null or p_target_xp < 50 or p_target_xp > 2000 then raise exception 'invalid target xp'; end if;
  a := least(uid, p_friend); b := greatest(uid, p_friend);
  if not exists (select 1 from connections c where c.user_a_id = a and c.user_b_id = b and c.status = 'accepted') then
    raise exception 'not friends';
  end if;
  if jz_blocked_between(uid, p_friend) then raise exception 'unavailable'; end if;
  if exists (select 1 from coop_challenges where user_a_id = a and user_b_id = b and status = 'active') then
    raise exception 'coop already active';
  end if;
  perform jz_rate_guard(
    (select count(*) from coop_challenges where created_by = uid and created_at > now() - interval '1 day')::int,
    10, 'create_coop/day');
  insert into coop_challenges (user_a_id, user_b_id, goal, progress, status, created_by)
  values (a, b, jsonb_build_object('type', 'xp', 'target', p_target_xp), 0, 'active', uid)
  returning id into v_id;
  return jsonb_build_object('coop_id', v_id, 'status', 'invited');
end $fn$;

create or replace function public.respond_coop(p_coop_id uuid, p_accept boolean)
returns jsonb language plpgsql security definer set search_path to 'public' as $fn$
declare uid uuid := auth.uid(); v coop_challenges%rowtype;
begin
  if uid is null then raise exception 'auth required'; end if;
  if not jz_social_access(uid) then raise exception 'social unavailable'; end if;
  select * into v from coop_challenges where id = p_coop_id;
  if v.id is null then raise exception 'not found'; end if;
  if uid not in (v.user_a_id, v.user_b_id) then raise exception 'not a member'; end if;
  if v.created_by = uid then raise exception 'cannot respond to your own invite'; end if;
  if v.accepted_at is not null then raise exception 'already accepted'; end if;
  if p_accept then
    update coop_challenges set accepted_at = now(), expires_at = now() + interval '7 days', updated_at = now()
      where id = p_coop_id;
    return jsonb_build_object('status', 'accepted');
  else
    delete from coop_challenges where id = p_coop_id;
    return jsonb_build_object('status', 'rejected');
  end if;
end $fn$;

-- Lista + LAZY settle (completa/expira y premia UNA vez, como el rollover de ligas).
create or replace function public.list_coops()
returns jsonb language plpgsql security definer set search_path to 'public' as $fn$
declare uid uuid := auth.uid(); rec record; v_prog numeric; v_target numeric;
begin
  if uid is null then raise exception 'auth required'; end if;
  if not jz_social_access(uid) then raise exception 'social unavailable'; end if;
  -- settle: activos aceptados de este usuario
  for rec in
    select * from coop_challenges
    where status = 'active' and accepted_at is not null and uid in (user_a_id, user_b_id)
  loop
    v_target := coalesce((rec.goal ->> 'target')::numeric, 0);
    v_prog := jz_coop_progress(rec.id);
    if v_target > 0 and v_prog >= v_target then
      update coop_challenges set status = 'completed', completed_at = now(), progress = v_prog, updated_at = now()
        where id = rec.id and status = 'active';
      if found then  -- premia UNA vez (el update es el candado)
        update user_stats set gold = gold + rec.reward_gold, updated_at = now()
          where user_id in (rec.user_a_id, rec.user_b_id);
        insert into gold_transactions (user_id, amount, reason)
        values (rec.user_a_id, rec.reward_gold, 'challenge'), (rec.user_b_id, rec.reward_gold, 'challenge');
      end if;
    elsif rec.expires_at is not null and now() > rec.expires_at then
      update coop_challenges set status = 'expired', progress = v_prog, updated_at = now()
        where id = rec.id and status = 'active';
    else
      update coop_challenges set progress = v_prog, updated_at = now() where id = rec.id;
    end if;
  end loop;
  return coalesce((
    select jsonb_agg(jsonb_build_object(
      'coop_id', cc.id,
      'partner_id', o.id,
      'partner_name', coalesce(nullif(o.display_name, ''), nullif(o.name, ''), 'Aprendiz'),
      'partner_color', coalesce(o.avatar_color, '#6C5CE7'),
      'target', (cc.goal ->> 'target')::int,
      'progress', coalesce(jz_coop_progress(cc.id), 0),
      'status', case when cc.accepted_at is null then 'invited' else cc.status::text end,
      'i_created', (cc.created_by = uid),
      'reward_gold', cc.reward_gold,
      'expires_at', cc.expires_at,
      'completed_at', cc.completed_at)
      order by (cc.status = 'active') desc, cc.created_at desc)
    from coop_challenges cc
    join users o on o.id = case when cc.user_a_id = uid then cc.user_b_id else cc.user_a_id end
    where uid in (cc.user_a_id, cc.user_b_id)
      and not jz_blocked_between(cc.user_a_id, cc.user_b_id)
      and (cc.status = 'active' or cc.updated_at > now() - interval '14 days')
  ), '[]'::jsonb);
end $fn$;

-- ─────────────────────────────────────────────────────────────────────────────
-- (A3) NOTAS DE VOZ — bucket privado + RLS de Storage + mensaje kind='voice'
-- ─────────────────────────────────────────────────────────────────────────────
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('voice-notes', 'voice-notes', false, 2097152,
        array['audio/webm', 'audio/ogg', 'audio/mp4', 'audio/mpeg', 'audio/wav'])
on conflict (id) do nothing;

-- Subir: SOLO un miembro adulto de la conexión ACEPTADA y no bloqueada, y el
-- archivo DEBE ir en la carpeta de esa conexión (voice-notes/<connection_id>/...).
drop policy if exists voice_notes_insert on storage.objects;
create policy voice_notes_insert on storage.objects for insert to authenticated
  with check (
    bucket_id = 'voice-notes'
    and jz_social_access(auth.uid())
    and exists (
      select 1 from public.connections c
      where c.id::text = (storage.foldername(name))[1]
        and c.status = 'accepted'
        and auth.uid() in (c.user_a_id, c.user_b_id)
        and not public.jz_blocked_between(c.user_a_id, c.user_b_id)));

-- Leer (y firmar URLs): solo miembros de la conexión (el bloqueo corta).
drop policy if exists voice_notes_select on storage.objects;
create policy voice_notes_select on storage.objects for select to authenticated
  using (
    bucket_id = 'voice-notes'
    and exists (
      select 1 from public.connections c
      where c.id::text = (storage.foldername(name))[1]
        and auth.uid() in (c.user_a_id, c.user_b_id)
        and not public.jz_blocked_between(c.user_a_id, c.user_b_id)));

-- SIN update/delete para usuarios: RETENCIÓN para investigación de reportes
-- (borrado solo service_role; purga programada = diferido, sin cron hoy).

create or replace function public.send_voice_message(p_connection_id uuid, p_path text)
returns jsonb language plpgsql security definer set search_path to 'public' as $fn$
declare uid uuid := auth.uid(); v_row connections%rowtype; v_id uuid;
begin
  if uid is null then raise exception 'auth required'; end if;
  if not jz_social_access(uid) then raise exception 'social unavailable'; end if;
  if jz_is_sanctioned(uid) then raise exception 'account restricted'; end if;
  select * into v_row from connections where id = p_connection_id;
  if v_row.id is null or uid not in (v_row.user_a_id, v_row.user_b_id) then raise exception 'not a member'; end if;
  if v_row.status <> 'accepted' then raise exception 'not friends'; end if;
  if jz_blocked_between(v_row.user_a_id, v_row.user_b_id) then raise exception 'unavailable'; end if;
  -- el path DEBE ser de la carpeta de esta conexión y existir en el bucket
  if p_path is null or p_path not like (p_connection_id::text || '/%') then raise exception 'invalid path'; end if;
  if not exists (select 1 from storage.objects where bucket_id = 'voice-notes' and name = p_path) then
    raise exception 'audio not uploaded';
  end if;
  perform jz_rate_guard(
    (select count(*) from messages where sender_id = uid and kind = 'voice'
       and created_at > now() - interval '1 minute')::int,
    10, 'voice_message/min');
  insert into messages (connection_id, sender_id, kind, audio_url)
  values (p_connection_id, uid, 'voice', p_path) returning id into v_id;
  update connections set updated_at = now() where id = p_connection_id;
  return jsonb_build_object('id', v_id, 'audio_url', p_path, 'created_at', now());
end $fn$;

-- ─────────────────────────────────────────────────────────────────────────────
-- GRANTS
-- ─────────────────────────────────────────────────────────────────────────────
grant execute on function public.create_coop(uuid, int) to authenticated;
grant execute on function public.respond_coop(uuid, boolean) to authenticated;
grant execute on function public.list_coops() to authenticated;
grant execute on function public.send_voice_message(uuid, text) to authenticated;
revoke all on function public.jz_coop_progress(uuid) from public, authenticated, anon;

commit;
