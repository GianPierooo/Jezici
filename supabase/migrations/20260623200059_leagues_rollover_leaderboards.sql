-- ============================================================================
-- Jezici · Migración 059 · Ligas: rollover real + leaderboards (L1/L2 audit)
-- ----------------------------------------------------------------------------
-- Cierra la "mentira" de ligas (FINDINGS.md §4 / L1): hoy acumulan XP y muestran
-- ranking pero NO hay cierre de semana ni ascensos/descensos (la UI los promete).
-- Añade:
--   1) División persistente por usuario (user_division) + jz_ensure_league que
--      coloca al usuario en SU división (no siempre bronce).
--   2) Snapshots históricos (league_snapshots) al cerrar cada semana.
--   3) Rollover IDEMPOTENTE + LAZY: jz_close_weeks() cierra semanas vencidas,
--      escribe snapshots y promueve top 7 / desciende fondo 5 entre divisiones
--      (Bronce↔Diamante). Se llama al leer (get_league/get_leaderboard) → no
--      depende de un cron garantizado. Marca de cierre = league_periods_closed.
--   4) get_leaderboard(metric, window, scope): ranking SECURITY DEFINER SIN
--      user_id (patrón get_league), derivado de las fuentes vivas (daily_goals,
--      user_lesson_progress, streaks, certificates) + snapshots para el histórico
--      de divisiones. Top-N + paginación.
--
-- PRIVACIDAD (mig 058): NUNCA exponer UUIDs de auth. league_members/leagues
-- siguen con SELECT revocado; todo ranking se sirve por RPC. Las tablas nuevas
-- tienen RLS sin policies de cliente (solo definer).
-- ============================================================================
begin;

-- ─── Tablas ─────────────────────────────────────────────────────────────────
create table if not exists user_division (
  user_id    uuid primary key references users(id) on delete cascade,
  division   league_division not null default 'bronce',
  updated_at timestamptz not null default now()
);

create table if not exists league_snapshots (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references users(id) on delete cascade,
  period_type  text not null,                 -- 'weekly' (mensual/anual se derivan en vivo)
  period_start date not null,
  division     league_division,
  metric       text not null default 'xp',
  final_rank   int,
  final_value  int,
  created_at   timestamptz not null default now(),
  unique (user_id, period_type, period_start, metric)
);
create index if not exists league_snapshots_period_idx on league_snapshots (period_type, period_start, division);

create table if not exists league_periods_closed (
  period_type  text not null,
  period_start date not null,
  closed_at    timestamptz not null default now(),
  primary key (period_type, period_start)
);

alter table user_division        enable row level security;
alter table league_snapshots     enable row level security;
alter table league_periods_closed enable row level security;
revoke all on user_division        from anon, authenticated;
revoke all on league_snapshots     from anon, authenticated;
revoke all on league_periods_closed from anon, authenticated;

-- ─── Helpers de división (subir/bajar, capado a los extremos) ────────────────
create or replace function jz_div_up(p_div league_division)
returns league_division language sql immutable as $$
  select (array['bronce','plata','oro','zafiro','rubi','diamante']::league_division[])
         [least(array_position(array['bronce','plata','oro','zafiro','rubi','diamante']::league_division[], p_div) + 1, 6)];
$$;
create or replace function jz_div_down(p_div league_division)
returns league_division language sql immutable as $$
  select (array['bronce','plata','oro','zafiro','rubi','diamante']::league_division[])
         [greatest(array_position(array['bronce','plata','oro','zafiro','rubi','diamante']::league_division[], p_div) - 1, 1)];
$$;
revoke execute on function jz_div_up(league_division)   from anon, authenticated;
revoke execute on function jz_div_down(league_division) from anon, authenticated;

-- ─── jz_ensure_league: ahora coloca al usuario en SU división ────────────────
create or replace function jz_ensure_league(p_uid uuid)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_week date := date_trunc('week', current_date)::date;
  v_div  league_division;
  v_league uuid;
begin
  -- ¿ya está en una liga esta semana?
  select l.id into v_league
  from league_members m join leagues l on l.id = m.league_id
  where m.user_id = p_uid and l.week_start = v_week
  limit 1;
  if v_league is not null then return v_league; end if;

  -- división persistente del usuario (default bronce para cuentas nuevas).
  select division into v_div from user_division where user_id = p_uid;
  if v_div is null then
    v_div := 'bronce';
    insert into user_division (user_id, division) values (p_uid, 'bronce')
    on conflict (user_id) do nothing;
  end if;

  -- liga de (semana, división) con cupo (< 30); si no hay, se crea.
  select l.id into v_league
  from leagues l
  where l.week_start = v_week and l.division = v_div
    and (select count(*) from league_members m where m.league_id = l.id) < 30
  order by l.created_at
  limit 1;
  if v_league is null then
    insert into leagues (division, week_start) values (v_div, v_week) returning id into v_league;
  end if;

  insert into league_members (league_id, user_id, weekly_xp, is_bot)
  values (v_league, p_uid, 0, false)
  on conflict (league_id, user_id) do nothing;
  return v_league;
end $$;

-- ─── Rollover: cierra semanas vencidas, snapshots + ascensos/descensos ──────
-- Idempotente (marca en league_periods_closed) y lazy-safe (se llama al leer).
-- Movimiento solo si la liga tiene masa suficiente (>= 13): top 7 suben, fondo 5
-- bajan, sin solape; en ligas pequeñas (beta) nadie se mueve (honesto).
create or replace function jz_close_weeks()
returns int
language plpgsql
security definer
set search_path = public
as $$
declare
  v_week date;
  v_cur  date := date_trunc('week', current_date)::date;
  v_n    int := 0;
  c_promote constant int := 7;
  c_demote  constant int := 5;
  c_minsize constant int := 13; -- >= promote+demote+1 (zonas sin solape)
begin
  for v_week in
    select distinct l.week_start
    from leagues l
    where l.week_start < v_cur
      and not exists (select 1 from league_periods_closed c
                      where c.period_type = 'weekly' and c.period_start = l.week_start)
    order by l.week_start
  loop
    -- Ranking final por liga de esa semana.
    with ranked as (
      select m.user_id, l.division,
             row_number() over (partition by l.id order by m.weekly_xp desc, m.created_at) as rnk,
             count(*)    over (partition by l.id) as grp,
             m.weekly_xp
      from league_members m
      join leagues l on l.id = m.league_id
      where l.week_start = v_week and m.user_id is not null
    )
    insert into league_snapshots (user_id, period_type, period_start, division, metric, final_rank, final_value)
    select user_id, 'weekly', v_week, division, 'xp', rnk, weekly_xp from ranked
    on conflict (user_id, period_type, period_start, metric) do nothing;

    -- Ascensos/descensos → nueva división persistente del usuario.
    with ranked as (
      select m.user_id, l.division,
             row_number() over (partition by l.id order by m.weekly_xp desc, m.created_at) as rnk,
             count(*)    over (partition by l.id) as grp
      from league_members m
      join leagues l on l.id = m.league_id
      where l.week_start = v_week and m.user_id is not null
    ),
    moves as (
      select user_id,
             case
               when grp >= c_minsize and rnk <= c_promote        then jz_div_up(division)
               when grp >= c_minsize and rnk >  grp - c_demote   then jz_div_down(division)
               else division
             end as new_div
      from ranked
    )
    insert into user_division (user_id, division, updated_at)
    select user_id, new_div, now() from moves
    on conflict (user_id) do update set division = excluded.division, updated_at = now();

    insert into league_periods_closed (period_type, period_start)
    values ('weekly', v_week) on conflict do nothing;
    v_n := v_n + 1;
  end loop;
  return v_n;
end $$;
revoke execute on function jz_close_weeks() from anon, authenticated;

-- ─── get_league: división real + cierre lazy + zonas reales (7/5) ───────────
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
    'promote', 7, 'demote', 5,
    'my_rank', coalesce(v_my_rank, 1), 'members', coalesce(v_members, '[]'::jsonb));
end $$;

-- ─── get_leaderboard: ranking multi-métrica/ventana/alcance, SIN user_id ────
create or replace function get_leaderboard(
  p_metric text default 'xp',
  p_window text default 'weekly',
  p_scope  text default 'global',
  p_limit  int  default 50,
  p_offset int  default 0
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  v_metric text := lower(coalesce(p_metric, 'xp'));
  v_window text := lower(coalesce(p_window, 'weekly'));
  v_scope  text := lower(coalesce(p_scope, 'global'));
  v_limit  int  := least(greatest(coalesce(p_limit, 50), 1), 100);
  v_offset int  := greatest(coalesce(p_offset, 0), 0);
  v_lo date;
  v_league uuid;
  v_entries jsonb;
  v_total int;
  v_my_rank int;
  v_my_value int;
begin
  if uid is null then raise exception 'auth required'; end if;
  perform jz_close_weeks();

  if v_metric not in ('xp','lessons','streak','certificates') then v_metric := 'xp'; end if;
  if v_window not in ('weekly','monthly','yearly','alltime') then v_window := 'weekly'; end if;
  if v_scope  not in ('global','division') then v_scope := 'global'; end if;
  -- Racha más larga no es por ventana: se trata como histórico.
  if v_metric = 'streak' then v_window := 'alltime'; end if;

  v_lo := case v_window
            when 'weekly'  then date_trunc('week',  current_date)::date
            when 'monthly' then date_trunc('month', current_date)::date
            when 'yearly'  then date_trunc('year',  current_date)::date
            else null end;

  -- Conjunto (user_id, value) según métrica/ventana.
  create temp table _lb (user_id uuid primary key, value int) on commit drop;

  if v_metric = 'xp' and v_window = 'alltime' then
    insert into _lb select user_id, xp_total from user_stats where coalesce(xp_total,0) > 0;
  elsif v_metric = 'xp' then
    insert into _lb select user_id, sum(xp_earned)::int from daily_goals
      where goal_date >= v_lo group by user_id having sum(xp_earned) > 0;
  elsif v_metric = 'lessons' then
    insert into _lb select user_id, count(*)::int from user_lesson_progress
      where status in ('completed','golden')
        and (v_lo is null or completed_at >= v_lo::timestamptz)
      group by user_id;
  elsif v_metric = 'streak' then
    insert into _lb select user_id, longest_streak from streaks where coalesce(longest_streak,0) > 0;
  elsif v_metric = 'certificates' then
    insert into _lb select user_id, count(*)::int from certificates
      where (v_lo is null or issued_at >= v_lo::timestamptz)
      group by user_id;
  end if;

  -- Alcance: división = miembros de la liga actual del usuario.
  if v_scope = 'division' then
    v_league := jz_ensure_league(uid);
    delete from _lb where user_id not in (
      select user_id from league_members where league_id = v_league and user_id is not null);
  end if;

  -- Garantiza la fila propia (aunque su valor sea 0) para poder situar "Tú".
  insert into _lb (user_id, value) select uid, 0
    where not exists (select 1 from _lb where user_id = uid);

  with ranked as (
    select b.user_id, b.value,
           row_number() over (order by b.value desc, u.created_at, b.user_id) as rnk,
           count(*) over () as total,
           coalesce(nullif(u.display_name,''), nullif(u.name,''), 'Aprendiz') as name,
           (b.user_id = uid) as is_me
    from _lb b join users u on u.id = b.user_id
  )
  select
    coalesce(jsonb_agg(jsonb_build_object(
      'rank', rnk, 'name', case when is_me then 'Tú' else name end,
      'value', value, 'is_me', is_me)
      order by rnk) filter (where rnk > v_offset and rnk <= v_offset + v_limit), '[]'::jsonb),
    max(total),
    max(case when is_me then rnk end),
    max(case when is_me then value end)
  into v_entries, v_total, v_my_rank, v_my_value
  from ranked;

  return jsonb_build_object(
    'metric', v_metric, 'window', v_window, 'scope', v_scope,
    'limit', v_limit, 'offset', v_offset,
    'total', coalesce(v_total, 0),
    'my_rank', v_my_rank, 'my_value', coalesce(v_my_value, 0),
    'entries', v_entries);
end $$;
grant execute on function get_leaderboard(text, text, text, int, int) to authenticated;

commit;
