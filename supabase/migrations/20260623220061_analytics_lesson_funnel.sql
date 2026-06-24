-- ============================================================================
-- Jezici · Migración 061 · Analítica para la beta: embudo dentro de la lección
-- ----------------------------------------------------------------------------
-- Tapa el único KPI sin cubrir: ABANDONO DENTRO de una lección. Añade 3 eventos
-- (lesson_start, lesson_quit, no_hearts) al allowlist de log_event (mig 058) — si
-- no se agregan, log_event los descarta en silencio — y expone un `lesson_funnel`
-- en get_engagement (admin-gated). Sin PII (solo conteos + lesson_id opaco).
-- get_metrics NO se toca; el stickiness (CURR) se computa client-side desde dau/mau.
-- ============================================================================
begin;

-- ─── log_event: allowlist + 3 eventos del loop de lección ───────────────────
create or replace function log_event(p_event text, p_props jsonb default '{}'::jsonb)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_allow constant text[] := array[
    'app_open','client_error','conversar_attempt','lesson_complete',
    'mission_started','onboarding_completed','onboarding_step','screen_view',
    -- mig 061: embudo dentro de la lección
    'lesson_start','lesson_quit','no_hearts'];
  v_uid uuid := auth.uid();
  v_props jsonb := coalesce(p_props, '{}'::jsonb);
begin
  if v_uid is null then return; end if;
  if p_event is null or not (p_event = any (v_allow)) then return; end if;
  if octet_length(v_props::text) > 2000 then
    v_props := jsonb_build_object('_truncated', true);
  end if;
  if (select count(*) from analytics_events
        where user_id = v_uid and created_at > now() - interval '1 minute') >= 120 then
    return;
  end if;
  insert into analytics_events (user_id, event, props) values (v_uid, p_event, v_props);
end $$;

-- ─── get_engagement: + lesson_funnel (últimos 30 días) ──────────────────────
create or replace function get_engagement()
returns jsonb language plpgsql security definer set search_path = public as $$
declare v_sections jsonb; v_fb jsonb; v_interest jsonb; v_lesson jsonb;
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

  -- Embudo dentro de la lección: dónde abandonan (salida / sin vidas).
  select jsonb_build_object(
           'started',   count(*) filter (where event = 'lesson_start'),
           'completed', count(*) filter (where event = 'lesson_complete'),
           'quit',      count(*) filter (where event = 'lesson_quit'),
           'no_hearts', count(*) filter (where event = 'no_hearts'),
           'completion_rate',
             case when count(*) filter (where event = 'lesson_start') > 0
               then round(count(*) filter (where event = 'lesson_complete')::numeric
                          / count(*) filter (where event = 'lesson_start'), 3)
               else 0 end)
    into v_lesson
  from analytics_events
  where event in ('lesson_start','lesson_complete','lesson_quit','no_hearts')
    and created_at >= now() - interval '30 days';

  return jsonb_build_object(
    'section_usage_7d', v_sections,
    'feedback_by_kind', v_fb,
    'conversar_interest', v_interest,
    'conversation_attempts', (select count(*) from conversation_attempts),
    'feedback_total', (select count(*) from feedback),
    'lesson_funnel', v_lesson);
end $$;

commit;
