-- ─────────────────────────────────────────────────────────────────────────────
-- FIX SISTEMA DE AMISTAD · parte 2/2 — notificar solicitudes + ampliar descubrimiento
-- ─────────────────────────────────────────────────────────────────────────────
-- Diagnóstico (cliente real, dos JWT): el SERVIDOR de amistad funciona (enviar por
-- código crea pending, list_friends.incoming la devuelve, aceptar la vuelve amistad).
-- Los fallos reales eran:
--   1) El cliente tragaba el error real con "revisa el código" (arreglo en Dart).
--   2) NADIE avisaba al receptor de la solicitud → esta migración crea la señal.
--   3) suggest_friends exigía MISMO curso → en beta chica devolvía [] (se amplía).
-- Nada aquí cambia la seguridad P1/T3: 18+, blocks en ambas direcciones, rate limits,
-- no-descubribles/sancionados excluidos, todo por RPC SECURITY DEFINER.

-- 1) HELPER: notifica a un usuario (in-app + push) sobre amistad. La notificación
--    viaja por la tabla `notifications` (status='sent' → la ve el centro y la empuja
--    la Edge Function matix-push a sus suscripciones). Una notificación fallida JAMÁS
--    debe tumbar la solicitud (se traga el error).
create or replace function public.jz_notify_friend(p_target uuid, p_from uuid, p_kind text)
returns void language plpgsql security definer set search_path to 'public' as $$
declare v_name text; v_body text;
begin
  if p_target is null or p_from is null then return; end if;
  select coalesce('@' || nullif(handle, ''), nullif(display_name, ''), nullif(name, ''), 'Alguien')
    into v_name from users where id = p_from;
  if p_kind = 'request' then
    v_body := v_name || ' te envió una solicitud de amistad';
  else
    v_body := v_name || ' aceptó tu solicitud de amistad. ¡Ya pueden chatear!';
  end if;
  insert into notifications (user_id, channel, trigger_type, escalation_step,
                             scheduled_at, sent_at, status, body)
  values (p_target, 'push',
          (case when p_kind = 'request' then 'friend_request' else 'friend_accepted' end)::notification_trigger,
          0, now(), now(), 'sent', v_body);
exception when others then
  null;  -- la solicitud es lo importante; el aviso es best-effort
end $$;

-- 2) jz_do_friend_request: idéntico a mig 149 + AVISA al receptor (nueva pending) y
--    al requester si el envío auto-acepta una solicitud mutua.
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
end $$;

-- 3) respond_friend_request: idéntico a mig 147 + AVISA al requester al ACEPTAR.
create or replace function public.respond_friend_request(p_connection_id uuid, p_accept boolean)
returns jsonb language plpgsql security definer set search_path to 'public' as $$
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
    perform jz_notify_friend(v_row.requested_by, uid, 'accepted');  -- avísale a quien pidió
    return jsonb_build_object('status', 'accepted');
  else
    delete from connections where id = p_connection_id;
    return jsonb_build_object('status', 'rejected');
  end if;
end $$;

-- 4) suggest_friends AMPLIADO: antes exigía MISMO curso activo → en una beta chica
--    (o con usuarios en cursos distintos) devolvía []. Ahora sugiere a CUALQUIER
--    adulto DESCUBRIBLE (no yo, no ya conectado/pendiente, no bloqueado, no
--    sancionado), priorizando quienes comparten mi curso y nivel cercano, y luego
--    los más activos (racha) / recientes. Señal honesta, sin inventar presencia.
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
    select jsonb_agg(x.card order by x.same_course desc, x.dist asc, x.streak desc, x.mx desc)
    from (
      select jsonb_build_object(
               'user_id', u.id, 'handle', u.handle,
               'name', coalesce(nullif(u.display_name, ''), nullif(u.name, ''), 'Aprendiz'),
               'avatar_color', coalesce(u.avatar_color, '#6C5CE7'),
               'avatar_url', u.avatar_url, 'country', u.country,
               'level', jz_cefr(coalesce(lv.mx, 0)),
               'streak', coalesce(s.current_streak, 0)) card,
             (case when ua.course_id = v_course and v_course is not null then 1 else 0 end) same_course,
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

revoke execute on function public.jz_notify_friend(uuid, uuid, text) from public, anon, authenticated;
grant execute on function public.respond_friend_request(uuid, boolean) to authenticated;
grant execute on function public.suggest_friends() to authenticated;
