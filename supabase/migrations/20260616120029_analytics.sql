-- ============================================================================
-- Jezici · Migración 029 · Analítica (Especificacion §13 métricas)
-- ----------------------------------------------------------------------------
-- Tabla genérica de eventos (instrumentación extensible) + get_metrics() que
-- calcula las métricas clave a partir de los datos ya existentes
-- (daily_goals = días activos, users.created_at = cohorte, exam_attempts,
-- certificates). Sin proveedor externo; si luego se usa PostHog, log_event
-- puede reenviar.
-- ============================================================================

create table if not exists analytics_events (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid references users(id) on delete set null,
  event      text not null,
  props      jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);
create index if not exists analytics_events_idx on analytics_events (event, created_at);
create index if not exists analytics_events_user_idx on analytics_events (user_id, created_at);

alter table analytics_events enable row level security;
drop policy if exists "ae_insert_own" on analytics_events;
create policy "ae_insert_own" on analytics_events for insert to authenticated
  with check (user_id is null or auth.uid() = user_id);

-- Instrumentación: registra un evento del usuario actual.
create or replace function log_event(p_event text, p_props jsonb default '{}'::jsonb)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into analytics_events (user_id, event, props) values (auth.uid(), p_event, coalesce(p_props, '{}'::jsonb));
end $$;

-- Métricas §13. Retención D-N = usuarios (de cohorte con ≥N días de antigüedad)
-- activos exactamente N días tras registrarse (daily_goals como señal de
-- actividad diaria). DAU/WAU/MAU por días activos. % aprueba / % certifica.
create or replace function get_metrics()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_total int; v_new7 int;
  v_dau int; v_wau int; v_mau int;
  v_d1 numeric; v_d7 numeric; v_d30 numeric;
  v_streak numeric; v_lpd numeric;
  v_ck numeric; v_lvl numeric; v_cert numeric; v_conv numeric;
begin
  select count(*) into v_total from users;
  select count(*) into v_new7 from users where created_at >= now() - interval '7 days';

  select count(distinct user_id) into v_dau from daily_goals where goal_date = current_date;
  select count(distinct user_id) into v_wau from daily_goals where goal_date >= current_date - 6;
  select count(distinct user_id) into v_mau from daily_goals where goal_date >= current_date - 29;

  -- Retención exact-day por cohorte.
  for v_d1, v_d7, v_d30 in
    select
      (select case when c1 > 0 then round(r1::numeric / c1, 3) else 0 end),
      (select case when c7 > 0 then round(r7::numeric / c7, 3) else 0 end),
      (select case when c30 > 0 then round(r30::numeric / c30, 3) else 0 end)
    from (
      select
        count(*) filter (where created_at::date <= current_date - 1) c1,
        count(*) filter (where created_at::date <= current_date - 1
          and exists (select 1 from daily_goals d where d.user_id = u.id and d.goal_date = u.created_at::date + 1)) r1,
        count(*) filter (where created_at::date <= current_date - 7) c7,
        count(*) filter (where created_at::date <= current_date - 7
          and exists (select 1 from daily_goals d where d.user_id = u.id and d.goal_date = u.created_at::date + 7)) r7,
        count(*) filter (where created_at::date <= current_date - 30) c30,
        count(*) filter (where created_at::date <= current_date - 30
          and exists (select 1 from daily_goals d where d.user_id = u.id and d.goal_date = u.created_at::date + 30)) r30
      from users u
    ) x
  loop end loop;

  select coalesce(round(avg(current_streak), 2), 0) into v_streak from streaks;

  -- lecciones por día activo.
  select coalesce(round(
    (select count(*) from user_lesson_progress where status in ('completed','golden'))::numeric
    / nullif((select count(*) from daily_goals), 0), 2), 0) into v_lpd;

  -- % de intentos de checkpoint / examen de nivel aprobados.
  select coalesce(round(avg((passed)::int)::numeric, 3), 0) into v_ck
  from exam_attempts a join exams e on e.id = a.exam_id where e.type = 'checkpoint';
  select coalesce(round(avg((passed)::int)::numeric, 3), 0) into v_lvl
  from exam_attempts a join exams e on e.id = a.exam_id where e.type = 'level';

  -- % de usuarios certificados; conversión premium (aún 0, sin pagos).
  select case when v_total > 0 then round((select count(distinct user_id) from certificates)::numeric / v_total, 3) else 0 end into v_cert;
  v_conv := 0;

  return jsonb_build_object(
    'total_users', v_total, 'new_users_7d', v_new7,
    'dau', v_dau, 'wau', v_wau, 'mau', v_mau,
    'retention_d1', v_d1, 'retention_d7', v_d7, 'retention_d30', v_d30,
    'avg_streak', v_streak, 'lessons_per_active_day', v_lpd,
    'pct_pass_checkpoint', v_ck, 'pct_pass_level_exam', v_lvl,
    'pct_certified', v_cert, 'conversion_premium', v_conv,
    'generated_at', now());
end $$;

grant execute on function log_event(text, jsonb) to authenticated;
grant execute on function get_metrics() to authenticated;
