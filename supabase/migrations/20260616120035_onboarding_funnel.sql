-- ============================================================================
-- Jezici · Migración 035 · Embudo de onboarding (GA4 · B7)
-- ----------------------------------------------------------------------------
-- Ahora que el onboarding es OBLIGATORIO y PRIMERO, medimos completitud y
-- drop-off por paso a partir de los eventos 'onboarding_step' (con props.step)
-- y 'onboarding_completed' que registra la app. Sin proveedor externo.
-- ============================================================================

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

grant execute on function get_onboarding_funnel() to authenticated;
