-- ============================================================================
-- Jezici · Migración 010 · Matix (test de personalidad + notificaciones)
-- ----------------------------------------------------------------------------
-- Fuente: Modelo_Datos.md §10 + Motor_Matix.md + Test_Personalidad.md.
-- (doc: columna `trigger` -> `trigger_type`, porque `trigger` es reservada.)
-- ============================================================================

-- ---------------------------------------------------------------------------
-- user_personality — estilo de coach + intensidad + horarios (1:1 con usuario)
-- ---------------------------------------------------------------------------
create table user_personality (
  user_id           uuid primary key references users(id) on delete cascade,
  coach_style       coach_style not null default 'suave',
  intensity         int not null default 2,        -- 1 baja · 2 media · 3 alta
  quiet_hours_start time,
  quiet_hours_end   time,
  push_enabled      boolean not null default true,
  email_enabled     boolean not null default true,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- notification_templates — banco de copys por estilo×trigger×escalón×canal
-- ---------------------------------------------------------------------------
create table notification_templates (
  id              uuid primary key default gen_random_uuid(),
  coach_style     coach_style not null,
  trigger_type    notification_trigger not null,
  escalation_step int not null default 1,
  channel         notification_channel not null,
  copy            text not null,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  unique (coach_style, trigger_type, escalation_step, channel)
);

-- ---------------------------------------------------------------------------
-- notifications — cola/registro de envíos
-- ---------------------------------------------------------------------------
create table notifications (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid not null references users(id) on delete cascade,
  channel         notification_channel not null,
  trigger_type    notification_trigger not null,
  template_id     uuid references notification_templates(id) on delete set null,
  escalation_step int,
  scheduled_at    timestamptz,
  sent_at         timestamptz,
  status          notification_status not null default 'scheduled',
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);
create index notifications_user_idx on notifications (user_id, scheduled_at);
