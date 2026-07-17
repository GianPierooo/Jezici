-- 3 BUGS SOCIALES de USO REAL (4 jugadores reales en la liga). Cero IA.
--
-- BUG 1 · "Mi liga" mostraba 0 XP y otro orden que "Tablas".
--   Causa RAÍZ: get_league leía league_members.weekly_xp, columna que SOLO se
--   escribe en el cierre semanal (jz_close_weeks) — jz_register_activity (el hot
--   path de XP) NO la toca. Mid-semana => 0 para todos. En cambio get_leaderboard
--   (Tablas) suma en VIVO daily_goals.xp_earned de la semana. Divergían por diseño.
--   FIX: get_league calcula la MISMA XP viva (daily_goals de la semana actual) y
--   ordena por ella -> Mi liga == Tablas, misma XP y mismo orden. weekly_xp queda
--   como está (la usa el rollover/histórico; no se toca la economía ni el cierre).
--   + se expone user_id por miembro (para abrir el perfil público al tocarlo;
--   mismo dato que search_users ya devuelve — get_public_profile sigue gateando).
--
-- BUG 2 · Bloquear sin poder desbloquear. unblock_user(p_target) YA existe, pero
--   no había forma de VER a quién bloqueaste. Se añade list_blocks().

-- ── get_league: XP semanal EN VIVO + user_id ────────────────────────────────
create or replace function public.get_league()
returns jsonb
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  uid uuid := auth.uid();
  v_league uuid;
  v_div league_division;
  v_week date := date_trunc('week', current_date)::date;
  v_real int;
  v_members jsonb;
  v_my_rank int;
  c_min constant int := 5;
  c_move constant int := 13;   -- umbral de MOVIMIENTO real (== jz_close_weeks c_minsize)
begin
  if uid is null then raise exception 'auth required'; end if;
  perform jz_close_weeks();             -- cierra semanas vencidas antes de servir
  v_league := jz_ensure_league(uid);
  select division into v_div from leagues where id = v_league;

  with ranked as (
    select m.user_id, m.created_at,
           -- XP semanal EN VIVO (misma fuente y ventana que get_leaderboard/Tablas):
           -- suma de daily_goals de la semana actual. Antes se leía m.weekly_xp
           -- (rancio hasta el cierre) -> 0 para todos mid-semana.
           coalesce((select sum(d.xp_earned)::int from daily_goals d
                       where d.user_id = m.user_id and d.goal_date >= v_week), 0) as wk_xp,
           coalesce(nullif(u.display_name, ''), nullif(u.name, ''), 'Aprendiz') as name,
           (m.user_id = uid) as is_me
    from league_members m
    join users u on u.id = m.user_id
    where m.league_id = v_league and m.user_id is not null
  ), rk as (
    select *, row_number() over (order by wk_xp desc, created_at) as rnk from ranked
  )
  select jsonb_agg(jsonb_build_object(
           'rank', rnk,
           'name', case when is_me then 'Tú' else name end,
           'weekly_xp', wk_xp,
           'is_me', is_me, 'is_bot', false,
           -- user_id para abrir el perfil público al tocar (no el propio).
           'user_id', case when is_me then null else user_id end) order by rnk),
         max(case when is_me then rnk end),
         count(*)
    into v_members, v_my_rank, v_real
  from rk;

  return jsonb_build_object(
    'division', v_div, 'week_start', v_week,
    'players', coalesce(v_real, 0), 'min_players', c_min,
    'warming_up', coalesce(v_real, 0) < c_min,
    'promote', case when coalesce(v_real, 0) >= c_move then 7 else 0 end,
    'demote',  case when coalesce(v_real, 0) >= c_move then 5 else 0 end,
    'movement_min', c_move,
    'my_rank', coalesce(v_my_rank, 1), 'members', coalesce(v_members, '[]'::jsonb));
end $function$;

-- ── list_blocks: a quién he bloqueado (para poder DESBLOQUEAR) ───────────────
-- Solo campos mínimos para reconocerlos (los YO bloqueé -> puedo verlos). El
-- desbloqueo real lo hace unblock_user(p_target), que ya existe.
create or replace function public.list_blocks()
returns jsonb
language plpgsql
security definer
set search_path to 'public'
as $function$
declare uid uuid := auth.uid(); v jsonb;
begin
  if uid is null then raise exception 'auth required'; end if;
  select coalesce(jsonb_agg(jsonb_build_object(
           'user_id', u.id,
           'name', coalesce(nullif(u.display_name, ''), nullif(u.name, ''), 'Aprendiz'),
           'handle', u.handle,
           'avatar_color', coalesce(u.avatar_color, '#6C5CE7'),
           'blocked_at', b.created_at) order by b.created_at desc), '[]'::jsonb)
    into v
  from blocks b join users u on u.id = b.blocked_id
  where b.blocker_id = uid;
  return jsonb_build_object('blocked', v);
end $function$;

revoke all on function public.list_blocks() from anon;
grant execute on function public.list_blocks() to authenticated;
