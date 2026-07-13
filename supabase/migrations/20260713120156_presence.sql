-- ─────────────────────────────────────────────────────────────────────────────
-- AMIGOS VIVOS · PRESENCIA honesta (last_seen) — rediseño de la sección Amigos
-- ─────────────────────────────────────────────────────────────────────────────
-- Muestra "en línea ahora" / "activo hace X" SIN inventar presencia: el cliente
-- late un heartbeat ligero (al abrir la app / al volver del background / cada ~90s
-- en primer plano) que sella users.last_seen = now(). list_friends y
-- suggest_friends devuelven ese last_seen (respetando show_presence, 18+, blocks,
-- descubribilidad) para que el cliente derive el estado. Nada de datos privados.
-- Privacidad: show_presence permite ocultar el "en línea" a los demás (el usuario
-- sigue viendo el de otros; simétrico si ellos también lo ocultan).

alter table public.users add column if not exists last_seen timestamptz;
alter table public.users add column if not exists show_presence boolean not null default true;

-- Heartbeat: sella mi last_seen. Barato (un UPDATE por id, indexado por PK).
create or replace function public.heartbeat()
returns void language plpgsql security definer set search_path to 'public' as $$
begin
  if auth.uid() is null then return; end if;
  update users set last_seen = now() where id = auth.uid();
end $$;

-- Toggle de visibilidad de presencia (privacidad). Si off, los demás me ven
-- siempre "desconectado" aunque esté activo.
create or replace function public.set_presence(p_on boolean)
returns void language plpgsql security definer set search_path to 'public' as $$
begin
  if auth.uid() is null then raise exception 'auth required'; end if;
  update users set show_presence = coalesce(p_on, true) where id = auth.uid();
end $$;

-- get_social_status expone show_presence (para el toggle del cliente).
create or replace function public.get_social_status()
returns jsonb language plpgsql security definer set search_path to 'public' as $fn$
declare uid uuid := auth.uid(); v_code text; v_handle text; v_disc boolean; v_pres boolean; v_access boolean;
begin
  if uid is null then raise exception 'auth required'; end if;
  v_access := jz_social_access(uid);
  if v_access then
    select friend_code, handle, discoverable, show_presence
      into v_code, v_handle, v_disc, v_pres from users where id = uid;
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
    'discoverable', coalesce(v_disc, true),
    'show_presence', coalesce(v_pres, true));
end $fn$;

-- list_friends: + handle + last_seen (respeta show_presence) + ORDEN por actividad
-- (en línea primero). incoming/outgoing sin cambios de forma.
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
        'handle', o.handle,
        'avatar_color', coalesce(o.avatar_color, '#6C5CE7'),
        'streak', jz_friend_streak(uid, o.id),
        'last_seen', case when o.show_presence then o.last_seen else null end)
        order by (case when o.show_presence then o.last_seen else null end) desc nulls last,
                 jz_friend_streak(uid, o.id) desc)
      from connections c
      join users o on o.id = case when c.user_a_id = uid then c.user_b_id else c.user_a_id end
      where c.status = 'accepted' and uid in (c.user_a_id, c.user_b_id)
        and not jz_blocked_between(c.user_a_id, c.user_b_id)
    ), '[]'::jsonb),
    'incoming', coalesce((
      select jsonb_agg(jsonb_build_object('connection_id', c.id, 'user_id', o.id,
        'name', coalesce(nullif(o.display_name,''), nullif(o.name,''), 'Aprendiz'),
        'handle', o.handle,
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

-- suggest_friends: + last_seen (respeta show_presence). Resto idéntico a mig 155
-- (adultos descubribles, mismo curso primero, no bloqueados/sancionados/menores).
create or replace function public.suggest_friends()
returns jsonb language plpgsql security definer set search_path to 'public' as $$
declare uid uuid := auth.uid(); v_course uuid; v_rank int;
begin
  if uid is null then raise exception 'auth required'; end if;
  if not jz_social_access(uid) then raise exception 'social unavailable'; end if;
  select course_id into v_course from user_active_course where user_id = uid;
  select coalesce(max(jz_rank(cefr_level::text)), 0) into v_rank
    from user_skill_levels where user_id = uid and course_id = v_course;
  return jsonb_build_object('suggestions', coalesce((
    select jsonb_agg(x.card order by x.same_course desc, x.online desc, x.dist asc, x.streak desc, x.mx desc)
    from (
      select jsonb_build_object(
               'user_id', u.id, 'handle', u.handle,
               'name', coalesce(nullif(u.display_name, ''), nullif(u.name, ''), 'Aprendiz'),
               'avatar_color', coalesce(u.avatar_color, '#6C5CE7'),
               'avatar_url', u.avatar_url, 'country', u.country,
               'level', jz_cefr(coalesce(lv.mx, 0)),
               'streak', coalesce(s.current_streak, 0),
               'last_seen', case when u.show_presence then u.last_seen else null end) card,
             (case when ua.course_id = v_course and v_course is not null then 1 else 0 end) same_course,
             (case when u.show_presence and u.last_seen > now() - interval '3 minutes' then 1 else 0 end) online,
             abs(coalesce(lv.mx, 0) - v_rank) dist,
             coalesce(lv.mx, 0) mx,
             coalesce(s.current_streak, 0) streak
      from users u
      left join user_active_course ua on ua.user_id = u.id
      left join (
        select user_id, max(jz_rank(cefr_level::text)) mx
        from user_skill_levels group by user_id
      ) lv on lv.user_id = u.id
      left join streaks s on s.user_id = u.id
      where u.id <> uid
        and jz_is_adult_user(u.id)
        and coalesce(u.discoverable, true)
        and not jz_is_sanctioned(u.id)
        and not jz_blocked_between(uid, u.id)
        and not exists (
          select 1 from connections c
          where c.user_a_id = least(uid, u.id) and c.user_b_id = greatest(uid, u.id))
      limit 12
    ) x), '[]'::jsonb));
end $$;

grant execute on function public.heartbeat() to authenticated;
grant execute on function public.set_presence(boolean) to authenticated;
grant execute on function public.get_social_status() to authenticated;
grant execute on function public.list_friends() to authenticated;
grant execute on function public.suggest_friends() to authenticated;
