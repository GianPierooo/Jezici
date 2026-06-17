-- ============================================================================
-- Jezici · Migración 038 · Feedback in-app + Conversar (taste seguro) — GA7
-- ----------------------------------------------------------------------------
-- 1) feedback: reporte de bug/idea desde CUALQUIER pantalla, con contexto.
-- 2) conversation_attempts: práctica de conversación EN SOLITARIO/asíncrona
--    (tema → texto/voz → modelo + autoevaluación). Guarda el intento (gancho
--    Fase 2). Sin otros humanos, sin IA.
-- 3) log_conversar_interest: señal de interés en conversación EN VIVO (Fase 2).
-- 4) get_engagement: panel interno (uso por sección, feedback, interés).
-- ============================================================================
begin;

-- ── 1) Feedback ──────────────────────────────────────────────────────────────
create table if not exists feedback (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid references users(id) on delete set null,
  screen      text,                                   -- pantalla/sección
  kind        text not null default 'idea',           -- bug | idea | other
  message     text not null,
  app_version text,
  platform    text,                                   -- web | android | ios
  created_at  timestamptz not null default now()
);
create index if not exists feedback_idx on feedback (created_at desc);
alter table feedback enable row level security;
drop policy if exists feedback_insert_own on feedback;
create policy feedback_insert_own on feedback for insert to authenticated
  with check (user_id is null or auth.uid() = user_id);

create or replace function submit_feedback(p_screen text, p_kind text, p_message text,
  p_app_version text default null, p_platform text default null)
returns void language plpgsql security definer set search_path = public as $$
begin
  if auth.uid() is null then raise exception 'auth required'; end if;
  if coalesce(btrim(p_message), '') = '' then raise exception 'empty message'; end if;
  insert into feedback (user_id, screen, kind, message, app_version, platform)
  values (auth.uid(), p_screen, coalesce(nullif(p_kind, ''), 'idea'),
          left(p_message, 2000), p_app_version, p_platform);
end $$;
grant execute on function submit_feedback(text, text, text, text, text) to authenticated;

-- ── 2) Conversar (taste solo/async) ──────────────────────────────────────────
create table if not exists conversation_attempts (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references users(id) on delete cascade,
  topic      text not null,
  mode       text not null default 'text',            -- text | voice
  content    text,                                     -- texto o transcripción
  self_score int,                                      -- autoevaluación 1..5
  created_at timestamptz not null default now()
);
create index if not exists conv_attempts_user_idx on conversation_attempts (user_id, created_at desc);
alter table conversation_attempts enable row level security;
drop policy if exists conv_attempts_own on conversation_attempts;
create policy conv_attempts_own on conversation_attempts for all to authenticated
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

create or replace function save_conversation_attempt(p_topic text, p_mode text,
  p_content text, p_self_score int default null)
returns void language plpgsql security definer set search_path = public as $$
begin
  if auth.uid() is null then raise exception 'auth required'; end if;
  insert into conversation_attempts (user_id, topic, mode, content, self_score)
  values (auth.uid(), left(coalesce(p_topic, ''), 200), coalesce(nullif(p_mode, ''), 'text'),
          left(coalesce(p_content, ''), 4000),
          case when p_self_score between 1 and 5 then p_self_score else null end);
end $$;
grant execute on function save_conversation_attempt(text, text, text, int) to authenticated;

-- ── 3) Interés en conversación EN VIVO (Fase 2 · waitlist) ───────────────────
create or replace function log_conversar_interest(p_would_use boolean, p_topics text default null)
returns void language plpgsql security definer set search_path = public as $$
begin
  if auth.uid() is null then raise exception 'auth required'; end if;
  insert into analytics_events (user_id, event, props)
  values (auth.uid(), 'conversar_interest',
          jsonb_build_object('would_use', coalesce(p_would_use, false),
                             'topics', left(coalesce(p_topics, ''), 500)));
end $$;
grant execute on function log_conversar_interest(boolean, text) to authenticated;

-- ── 4) Panel interno: engagement (uso por sección + feedback + interés) ──────
create or replace function get_engagement()
returns jsonb language plpgsql security definer set search_path = public as $$
declare v_sections jsonb; v_fb jsonb; v_interest jsonb;
begin
  -- Uso por sección (screen_view de los últimos 7 días).
  select coalesce(jsonb_object_agg(section, c), '{}'::jsonb) into v_sections
  from (select props ->> 'section' as section, count(*) c
        from analytics_events
        where event = 'screen_view' and created_at >= now() - interval '7 days'
          and props ->> 'section' is not null
        group by props ->> 'section') s;

  -- Feedback por tipo.
  select coalesce(jsonb_object_agg(kind, c), '{}'::jsonb) into v_fb
  from (select kind, count(*) c from feedback group by kind) f;

  -- Interés en conversación en vivo.
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
grant execute on function get_engagement() to authenticated;

commit;
