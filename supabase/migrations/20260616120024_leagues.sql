-- ============================================================================
-- Jezici · Migración 024 · Ligas semanales (Diseno_Gamificacion §ligas)
-- ----------------------------------------------------------------------------
-- Liga semanal por XP. Divisiones Bronce→Diamante, ~30 por grupo, ranking por
-- XP de la semana, con zonas de ascenso (top 5) y descenso (bottom 5). El XP
-- semanal lo acumula el servidor (jz_register_activity). Si faltan rivales,
-- sembramos BOTS (user_id nulo + display_name) para que el mecanismo se vea y
-- funcione sin fabricar cuentas de auth.
-- ============================================================================

alter table league_members add column if not exists display_name text;
alter table league_members add column if not exists is_bot boolean not null default false;
alter table league_members alter column user_id drop not null;

-- Lectura propia de la liga la dan las RPC (DEFINER); habilitamos RLS por si.
alter table leagues enable row level security;
alter table league_members enable row level security;
drop policy if exists "leagues_read" on leagues;
create policy "leagues_read" on leagues for select to authenticated using (true);
drop policy if exists "lmembers_read" on league_members;
create policy "lmembers_read" on league_members for select to authenticated using (true);

-- ── jz_ensure_league: asegura la membresía del usuario en la semana actual ───
create or replace function jz_ensure_league(p_uid uuid)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_week date := date_trunc('week', current_date)::date;
  v_league uuid;
begin
  -- ¿ya está en una liga esta semana?
  select l.id into v_league
  from league_members m join leagues l on l.id = m.league_id
  where m.user_id = p_uid and l.week_start = v_week
  limit 1;
  if v_league is not null then return v_league; end if;

  -- liga Bronce de la semana con cupo (< 30); si no hay, se crea.
  select l.id into v_league
  from leagues l
  where l.week_start = v_week and l.division = 'bronce'
    and (select count(*) from league_members m where m.league_id = l.id) < 30
  order by l.created_at
  limit 1;
  if v_league is null then
    insert into leagues (division, week_start) values ('bronce', v_week) returning id into v_league;
  end if;

  insert into league_members (league_id, user_id, weekly_xp, is_bot)
  values (v_league, p_uid, 0, false)
  on conflict (league_id, user_id) do nothing;
  return v_league;
end $$;

-- ── jz_add_league_xp: suma XP de la semana (lo llama jz_register_activity) ────
create or replace function jz_add_league_xp(p_uid uuid, p_xp int)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare v_league uuid;
begin
  if coalesce(p_xp, 0) <= 0 then return; end if;
  v_league := jz_ensure_league(p_uid);
  update league_members set weekly_xp = weekly_xp + p_xp, updated_at = now()
   where league_id = v_league and user_id = p_uid;
end $$;

-- Enganchar el XP semanal a la actividad (re-emite jz_register_activity con el
-- mismo cuerpo + la línea de liga al final).
create or replace function jz_register_activity(p_uid uuid, p_course uuid, p_xp int)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_min int; v_goal int; v_earned int; v_met boolean;
  v_streak int; v_longest int; v_last date;
  v_adv boolean := false; v_milestone int := 0; v_bonus int := 0;
begin
  select daily_minutes into v_min from user_plans where user_id = p_uid and course_id = p_course;
  v_goal := greatest(10, coalesce(v_min, 30));

  insert into daily_goals (user_id, goal_date, goal_xp, xp_earned)
  values (p_uid, current_date, v_goal, p_xp)
  on conflict (user_id, goal_date) do update
    set xp_earned = daily_goals.xp_earned + excluded.xp_earned, updated_at = now()
  returning xp_earned, goal_xp into v_earned, v_goal;

  v_met := v_earned >= v_goal;
  select current_streak, longest_streak, last_active_date into v_streak, v_longest, v_last
  from streaks where user_id = p_uid for update;

  if v_met and (v_last is null or v_last < current_date) then
    if v_last = current_date - 1 then v_streak := coalesce(v_streak, 0) + 1; else v_streak := 1; end if;
    v_longest := greatest(coalesce(v_longest, 0), v_streak);
    update streaks set current_streak = v_streak, longest_streak = v_longest,
                       last_active_date = current_date, updated_at = now() where user_id = p_uid;
    v_adv := true;
    if v_streak in (7, 30, 100, 365) then
      v_milestone := v_streak;
      v_bonus := case v_streak when 7 then 50 when 30 then 100 when 100 then 250 else 500 end;
      update user_stats set gold = gold + v_bonus, updated_at = now() where user_id = p_uid;
      insert into gold_transactions (user_id, amount, reason) values (p_uid, v_bonus, 'challenge');
    end if;
  end if;

  -- Liga: acumular XP de la semana.
  perform jz_add_league_xp(p_uid, p_xp);

  return jsonb_build_object(
    'goal_xp', v_goal, 'xp_earned_today', v_earned, 'goal_met', v_met,
    'streak', coalesce(v_streak, 0), 'longest_streak', coalesce(v_longest, 0),
    'streak_advanced', v_adv, 'milestone', v_milestone, 'milestone_bonus', v_bonus);
end $$;

-- ── get_league: standings de la semana (siembra bots si faltan rivales) ──────
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
  v_count int;
  v_names text[] := array['Mateo','Sofía','Lucas','Valentina','Diego','Camila','Mar','Emma','Hugo','Lía',
                          'Bruno','Aria','Theo','Noa','Iván','Yuki','Kenji','Marco','Elsa','Nina',
                          'Pablo','Rosa','Tom','Ana','Leo','Mía','Sami','Vera','Otto','Cleo'];
  v_members jsonb;
  v_my_rank int;
begin
  if uid is null then raise exception 'auth required'; end if;
  v_league := jz_ensure_league(uid);

  -- Sembrar bots hasta 30 miembros (una sola vez por liga).
  select count(*) into v_count from league_members where league_id = v_league;
  if v_count < 30 then
    insert into league_members (league_id, user_id, weekly_xp, is_bot, display_name)
    select v_league, null,
           (40 + (random() * 320))::int,
           true,
           v_names[1 + ((g - 1) % array_length(v_names, 1))]
    from generate_series(1, 30 - v_count) g;
  end if;

  -- Standings ordenados por XP semanal.
  with ranked as (
    select m.id, m.user_id, m.is_bot, m.weekly_xp,
           coalesce(m.display_name, u.display_name, u.name, 'Aprendiz') as name,
           row_number() over (order by m.weekly_xp desc, m.created_at) as rnk,
           (m.user_id = uid) as is_me
    from league_members m
    left join users u on u.id = m.user_id
    where m.league_id = v_league
  )
  select jsonb_agg(jsonb_build_object(
           'rank', rnk, 'name', case when is_me then 'Tú' else name end,
           'weekly_xp', weekly_xp, 'is_me', is_me, 'is_bot', is_bot) order by rnk),
         max(case when is_me then rnk end)
    into v_members, v_my_rank
  from ranked;

  return jsonb_build_object(
    'division', 'bronce', 'week_start', v_week,
    'total', 30, 'promote', 5, 'demote', 5,
    'my_rank', v_my_rank, 'members', coalesce(v_members, '[]'::jsonb));
end $$;

grant execute on function jz_ensure_league(uuid) to authenticated;
grant execute on function get_league() to authenticated;
