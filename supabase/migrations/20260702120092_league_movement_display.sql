-- 20260702120092_league_movement_display.sql
-- ─────────────────────────────────────────────────────────────────────────────
-- FIX P2-9 (QA_AUDIT.md): zonas de ascenso/descenso mal escaladas en ligas de beta.
--   get_league devolvía promote:7/demote:5 FIJOS, pero el rollover (jz_close_weeks)
--   solo mueve cuando la liga tiene masa suficiente (grp >= 13). En una liga beta de
--   6–12 jugadores la UI dibujaba una "zona de descenso" que cubría casi toda la tabla
--   → mentira de display (nadie desciende realmente por debajo de 13).
--
-- Fix (fuente única = el gate del rollover): get_league ahora devuelve promote/demote
-- = 0 mientras la liga no alcance el umbral de movimiento (13). Así el cliente no pinta
-- zonas engañosas y muestra una nota honesta de beta. Cuando la liga llegue a 13+,
-- vuelven 7/5 y las zonas aparecen — coherente con jz_close_weeks.
--
-- Copia VERBATIM de get_league (mig 059) salvo promote/demote condicionales +
-- 'movement_min'. Se preserva EXACTO el no-leak de user_id (is_me/'Tú', sin uuid).
-- ─────────────────────────────────────────────────────────────────────────────

create or replace function get_league()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
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
    select m.weekly_xp, m.created_at,
           coalesce(nullif(u.display_name, ''), nullif(u.name, ''), 'Aprendiz') as name,
           row_number() over (order by m.weekly_xp desc, m.created_at) as rnk,
           (m.user_id = uid) as is_me
    from league_members m
    join users u on u.id = m.user_id
    where m.league_id = v_league and m.user_id is not null
  )
  select jsonb_agg(jsonb_build_object(
           'rank', rnk, 'name', case when is_me then 'Tú' else name end,
           'weekly_xp', weekly_xp, 'is_me', is_me, 'is_bot', false) order by rnk),
         max(case when is_me then rnk end),
         count(*)
    into v_members, v_my_rank, v_real
  from ranked;

  return jsonb_build_object(
    'division', v_div, 'week_start', v_week,
    'players', coalesce(v_real, 0), 'min_players', c_min,
    'warming_up', coalesce(v_real, 0) < c_min,
    -- Solo hay ascensos/descensos con masa suficiente (== gate del rollover).
    'promote', case when coalesce(v_real, 0) >= c_move then 7 else 0 end,
    'demote',  case when coalesce(v_real, 0) >= c_move then 5 else 0 end,
    'movement_min', c_move,
    'my_rank', coalesce(v_my_rank, 1), 'members', coalesce(v_members, '[]'::jsonb));
end $$;
grant execute on function get_league() to authenticated;
