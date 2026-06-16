-- ============================================================================
-- Jezici · Migración 011 · Social / Conversar (estructura base, Fase 2)
-- ----------------------------------------------------------------------------
-- Fuente: Modelo_Datos.md §11. Se crea la estructura desde ya; la lógica
-- humano-a-humano (emparejamiento, moderación, realtime) es Fase 2.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- social_profiles — para encontrar compañeros (1:1 con usuario)
-- ---------------------------------------------------------------------------
create table social_profiles (
  user_id       uuid primary key references users(id) on delete cascade,
  interests     text[] not null default '{}',
  is_verified   boolean not null default false,
  online_status online_status not null default 'offline',
  last_seen_at  timestamptz,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- connections — compañeros de idioma / amigos
-- ---------------------------------------------------------------------------
create table connections (
  id         uuid primary key default gen_random_uuid(),
  user_a_id  uuid not null references users(id) on delete cascade,
  user_b_id  uuid not null references users(id) on delete cascade,
  status     connection_status not null default 'pending',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check  (user_a_id <> user_b_id),
  unique (user_a_id, user_b_id)
);
create index connections_a_idx on connections (user_a_id);
create index connections_b_idx on connections (user_b_id);

-- ---------------------------------------------------------------------------
-- conversation_rooms / room_participants — salas de audio en vivo
-- ---------------------------------------------------------------------------
create table conversation_rooms (
  id           uuid primary key default gen_random_uuid(),
  topic        text,
  cefr_level   cefr_level,
  host_user_id uuid references users(id) on delete set null,
  status       room_status not null default 'open',
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

create table room_participants (
  id        uuid primary key default gen_random_uuid(),
  room_id   uuid not null references conversation_rooms(id) on delete cascade,
  user_id   uuid not null references users(id)              on delete cascade,
  joined_at timestamptz not null default now(),
  left_at   timestamptz,
  created_at timestamptz not null default now(),
  unique (room_id, user_id)
);
create index room_participants_room_idx on room_participants (room_id);

-- ---------------------------------------------------------------------------
-- coop_challenges — retos en pareja (meta compartida)
-- ---------------------------------------------------------------------------
create table coop_challenges (
  id         uuid primary key default gen_random_uuid(),
  user_a_id  uuid not null references users(id) on delete cascade,
  user_b_id  uuid not null references users(id) on delete cascade,
  goal       jsonb not null default '{}'::jsonb,
  progress   numeric not null default 0,
  status     coop_status not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (user_a_id <> user_b_id)
);
create index coop_a_idx on coop_challenges (user_a_id);
create index coop_b_idx on coop_challenges (user_b_id);

-- ---------------------------------------------------------------------------
-- conversation_challenges — reto de conversación del día
--   (Fase 1: se guarda la grabación aunque no se evalúe; gancho IA Fase 2.)
-- ---------------------------------------------------------------------------
create table conversation_challenges (
  id                uuid primary key default gen_random_uuid(),
  user_id           uuid not null references users(id) on delete cascade,
  topic             text,
  prompt            text,
  status            conv_challenge_status not null default 'assigned',
  recording_url     text,
  transcript        text,
  score             numeric,
  creativity_points int,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);
create index conv_challenges_user_idx on conversation_challenges (user_id);

-- ---------------------------------------------------------------------------
-- reports — seguridad / moderación
-- ---------------------------------------------------------------------------
create table reports (
  id          uuid primary key default gen_random_uuid(),
  reporter_id uuid not null references users(id) on delete cascade,
  reported_id uuid not null references users(id) on delete cascade,
  reason      text,
  created_at  timestamptz not null default now(),
  check (reporter_id <> reported_id)
);
create index reports_reported_idx on reports (reported_id);
