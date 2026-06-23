-- ============================================================================
-- Jezici · Migración 058 · Endurecimiento de seguridad (4 hallazgos abiertos)
-- ----------------------------------------------------------------------------
-- Cierra los hallazgos de la auditoría 2026-06-22 (ver FINDINGS.md §5):
--   1) league_members SELECT abierto (filtra UUIDs de auth) → solo get_league.
--   2) get_metrics/get_engagement/get_onboarding_funnel sin gate de admin.
--   3) log_event sin allowlist / truncado / rate-limit.
--   4) export_my_data() (GDPR portabilidad) inexistente.
--
-- COMPAT con el build LIVE (7e26824, lo que usan los usuarios HOY): verificado
-- que la pantalla de ligas usa SOLO la RPC get_league (no lee league_members
-- directo) y que log_event solo recibe los 8 eventos del allowlist. Todas las
-- escrituras de ligas pasan por funciones SECURITY DEFINER (ignoran RLS), así
-- que cerrar el SELECT del cliente no rompe nada.
-- ============================================================================
begin;

-- ─── Mecanismo de admin mínimo ──────────────────────────────────────────────
create table if not exists admins (
  user_id    uuid primary key references users(id) on delete cascade,
  created_at timestamptz not null default now()
);
alter table admins enable row level security;
-- Sin policies → ningún rol de cliente la lee. Solo el owner (definer).
revoke all on admins from anon, authenticated;

-- Semilla: la cuenta del dueño (Gian). Insert vía SELECT para no fallar si el
-- id no existiera en public.users.
insert into admins (user_id)
select id from users where id = '7b4a8e40-adf0-4e42-bd1e-1f0bf21e305c'
on conflict (user_id) do nothing;

create or replace function jz_is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (select 1 from admins where user_id = auth.uid());
$$;
revoke execute on function jz_is_admin() from anon, authenticated;

-- ─── (2) Gate de admin en los paneles internos ──────────────────────────────
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
  if not jz_is_admin() then raise exception 'admin only'; end if;
  select count(*) into v_total from users;
  select count(*) into v_new7 from users where created_at >= now() - interval '7 days';

  select count(distinct user_id) into v_dau from daily_goals where goal_date = current_date;
  select count(distinct user_id) into v_wau from daily_goals where goal_date >= current_date - 6;
  select count(distinct user_id) into v_mau from daily_goals where goal_date >= current_date - 29;

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

  select coalesce(round(
    (select count(*) from user_lesson_progress where status in ('completed','golden'))::numeric
    / nullif((select count(*) from daily_goals), 0), 2), 0) into v_lpd;

  select coalesce(round(avg((passed)::int)::numeric, 3), 0) into v_ck
  from exam_attempts a join exams e on e.id = a.exam_id where e.type = 'checkpoint';
  select coalesce(round(avg((passed)::int)::numeric, 3), 0) into v_lvl
  from exam_attempts a join exams e on e.id = a.exam_id where e.type = 'level';

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

create or replace function get_engagement()
returns jsonb language plpgsql security definer set search_path = public as $$
declare v_sections jsonb; v_fb jsonb; v_interest jsonb;
begin
  if not jz_is_admin() then raise exception 'admin only'; end if;
  select coalesce(jsonb_object_agg(section, c), '{}'::jsonb) into v_sections
  from (select props ->> 'section' as section, count(*) c
        from analytics_events
        where event = 'screen_view' and created_at >= now() - interval '7 days'
          and props ->> 'section' is not null
        group by props ->> 'section') s;

  select coalesce(jsonb_object_agg(kind, c), '{}'::jsonb) into v_fb
  from (select kind, count(*) c from feedback group by kind) f;

  select jsonb_build_object(
           'responses', count(*),
           'would_use_yes', count(*) filter (where (props ->> 'would_use')::boolean))
    into v_interest
  from analytics_events where event = 'conversar_interest';

  return jsonb_build_object(
    'section_usage_7d', v_sections,
    'feedback_by_kind', v_fb,
    'conversar_interest', v_interest,
    'conversation_attempts', (select count(*) from conversation_attempts),
    'feedback_total', (select count(*) from feedback));
end $$;

create or replace function get_onboarding_funnel()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_steps jsonb;
  v_started int;
  v_completed int;
begin
  if not jz_is_admin() then raise exception 'admin only'; end if;
  select jsonb_agg(jsonb_build_object('step', s, 'users', coalesce(x.u, 0)) order by s)
    into v_steps
  from generate_series(0, 8) s
  left join lateral (
    select count(distinct user_id) u
    from analytics_events
    where event = 'onboarding_step' and (props ->> 'step')::int = s
  ) x on true;

  select count(distinct user_id) into v_started
  from analytics_events where event = 'onboarding_step' and (props ->> 'step')::int = 0;

  select count(distinct user_id) into v_completed
  from analytics_events where event = 'onboarding_completed';

  return jsonb_build_object(
    'steps', coalesce(v_steps, '[]'::jsonb),
    'started', v_started,
    'completed', v_completed,
    'completion_rate', case when v_started > 0 then round(v_completed::numeric / v_started, 3) else 0 end);
end $$;

-- ─── (3) log_event: allowlist + truncado + rate-limit ───────────────────────
-- Allowlist = los 8 eventos que el cliente REAL (incl. build live 7e26824) emite
-- por esta RPC. 'conversar_interest', feedback y conversation_attempts NO pasan
-- por aquí (tienen RPC dedicada), por eso no están en la lista.
create or replace function log_event(p_event text, p_props jsonb default '{}'::jsonb)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_allow constant text[] := array[
    'app_open','client_error','conversar_attempt','lesson_complete',
    'mission_started','onboarding_completed','onboarding_step','screen_view'];
  v_uid uuid := auth.uid();
  v_props jsonb := coalesce(p_props, '{}'::jsonb);
begin
  if v_uid is null then return; end if;
  -- Allowlist: un evento desconocido se descarta en silencio (no rompe al cliente,
  -- no envenena las métricas).
  if p_event is null or not (p_event = any (v_allow)) then return; end if;
  -- props gigantes → se truncan (acota el tamaño de fila / spam de payload).
  if octet_length(v_props::text) > 2000 then
    v_props := jsonb_build_object('_truncated', true);
  end if;
  -- Rate-limit básico: máx 120 eventos/usuario/minuto (uso real muy por debajo;
  -- usa el índice analytics_events_user_idx).
  if (select count(*) from analytics_events
        where user_id = v_uid and created_at > now() - interval '1 minute') >= 120 then
    return;
  end if;
  insert into analytics_events (user_id, event, props) values (v_uid, p_event, v_props);
end $$;

-- ─── (1) Cerrar league_members / leagues al cliente (solo get_league) ───────
drop policy if exists "lmembers_read"     on league_members;
drop policy if exists "lmember_select_own" on league_members;
revoke select on league_members from anon, authenticated;

drop policy if exists "leagues_read"         on leagues;
drop policy if exists "content_read_leagues" on leagues;
revoke select on leagues from anon, authenticated;

-- ─── (4) export_my_data() — portabilidad GDPR del propio usuario ────────────
create or replace function export_my_data()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare uid uuid := auth.uid(); v jsonb;
begin
  if uid is null then raise exception 'auth required'; end if;
  select jsonb_build_object(
    'exported_at', now(),
    'user', (select to_jsonb(t) from (
        select id, email, name, display_name, country, bio, avatar_color, created_at
        from users where id = uid) t),
    'stats', (select to_jsonb(s) from user_stats s where s.user_id = uid),
    'streak', (select to_jsonb(s) from streaks s where s.user_id = uid),
    'personality', (select to_jsonb(p) from user_personality p where p.user_id = uid),
    'plan', (select to_jsonb(p) from user_plans p where p.user_id = uid),
    'active_course', (select to_jsonb(c) from user_active_course c where c.user_id = uid),
    'course_progress', (select coalesce(jsonb_agg(to_jsonb(c)), '[]'::jsonb) from user_course_progress c where c.user_id = uid),
    'lesson_progress', (select coalesce(jsonb_agg(to_jsonb(l)), '[]'::jsonb) from user_lesson_progress l where l.user_id = uid),
    'skill_levels', (select coalesce(jsonb_agg(to_jsonb(s)), '[]'::jsonb) from user_skill_levels s where s.user_id = uid),
    'skill_mastery', (select coalesce(jsonb_agg(to_jsonb(s)), '[]'::jsonb) from user_skill_mastery s where s.user_id = uid),
    'item_attempts', (select coalesce(jsonb_agg(to_jsonb(a)), '[]'::jsonb) from user_item_attempts a where a.user_id = uid),
    'vocab_srs', (select coalesce(jsonb_agg(to_jsonb(s)), '[]'::jsonb) from user_vocab_srs s where s.user_id = uid),
    'tip_progress', (select coalesce(jsonb_agg(to_jsonb(t)), '[]'::jsonb) from user_tip_progress t where t.user_id = uid),
    'achievements', (select coalesce(jsonb_agg(to_jsonb(a)), '[]'::jsonb) from user_achievements a where a.user_id = uid),
    'certificates', (select coalesce(jsonb_agg(to_jsonb(c)), '[]'::jsonb) from certificates c where c.user_id = uid),
    'exam_attempts', (select coalesce(jsonb_agg(to_jsonb(e)), '[]'::jsonb) from exam_attempts e where e.user_id = uid),
    'daily_goals', (select coalesce(jsonb_agg(to_jsonb(d)), '[]'::jsonb) from daily_goals d where d.user_id = uid),
    'gold_transactions', (select coalesce(jsonb_agg(to_jsonb(g)), '[]'::jsonb) from gold_transactions g where g.user_id = uid),
    'chest_openings', (select coalesce(jsonb_agg(to_jsonb(c)), '[]'::jsonb) from chest_openings c where c.user_id = uid),
    'league_memberships', (select coalesce(jsonb_agg(to_jsonb(m)), '[]'::jsonb) from league_members m where m.user_id = uid),
    'subscriptions', (select coalesce(jsonb_agg(to_jsonb(s)), '[]'::jsonb) from subscriptions s where s.user_id = uid),
    'feedback', (select coalesce(jsonb_agg(to_jsonb(f)), '[]'::jsonb) from feedback f where f.user_id = uid),
    'conversation_attempts', (select coalesce(jsonb_agg(to_jsonb(c)), '[]'::jsonb) from conversation_attempts c where c.user_id = uid)
  ) into v;
  return v;
end $$;
grant execute on function export_my_data() to authenticated;

commit;
