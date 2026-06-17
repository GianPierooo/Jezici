-- ============================================================================
-- Jezici · Migración 036 · Ligas REALES, sin bots (GA6 · honestidad > apariencia)
-- ----------------------------------------------------------------------------
-- Quita los rivales dummy (bots) de las ligas. get_league pasa a devolver SOLO
-- usuarios reales y un estado "warming_up" cuando aún no hay masa crítica, para
-- manejar con gracia la baja población inicial sin fabricar competidores.
-- ============================================================================
begin;

-- 1) Borrar TODOS los bots sembrados y las ligas que queden vacías.
delete from league_members where is_bot = true or user_id is null;
delete from leagues l where not exists (select 1 from league_members m where m.league_id = l.id);

-- 2) get_league: solo miembros reales + warming_up bajo umbral. SIN sembrar bots.
create or replace function get_league()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  v_league uuid;
  v_week date := date_trunc('week', current_date)::date;
  v_real int;
  v_members jsonb;
  v_my_rank int;
  c_min constant int := 5; -- masa crítica para "competir" de verdad
begin
  if uid is null then raise exception 'auth required'; end if;
  v_league := jz_ensure_league(uid);

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
    'division', 'bronce', 'week_start', v_week,
    'players', coalesce(v_real, 0), 'min_players', c_min,
    'warming_up', coalesce(v_real, 0) < c_min,
    'promote', 5, 'demote', 5,
    'my_rank', coalesce(v_my_rank, 1), 'members', coalesce(v_members, '[]'::jsonb));
end $$;

grant execute on function get_league() to authenticated;

commit;
