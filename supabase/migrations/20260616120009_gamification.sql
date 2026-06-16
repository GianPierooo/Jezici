-- ============================================================================
-- Jezici · Migración 009 · Gamificación completa
-- ----------------------------------------------------------------------------
-- Fuente: Modelo_Datos.md §9 + Diseno_Gamificacion.md.
-- (user_stats y streaks ya existen desde la migración 003.)
-- ============================================================================

-- ---------------------------------------------------------------------------
-- gold_transactions — libro mayor del oro (auditable). Toda variación pasa aquí.
-- ---------------------------------------------------------------------------
create table gold_transactions (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references users(id) on delete cascade,
  amount     int not null,                 -- +/-
  reason     gold_reason not null,
  created_at timestamptz not null default now()
);
create index gold_transactions_user_idx on gold_transactions (user_id, created_at);

-- ---------------------------------------------------------------------------
-- daily_goals — meta diaria de XP. (doc: columna `date` -> `goal_date`.)
-- ---------------------------------------------------------------------------
create table daily_goals (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references users(id) on delete cascade,
  goal_date  date not null,
  goal_xp    int not null default 0,
  xp_earned  int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, goal_date)
);
create index daily_goals_user_date_idx on daily_goals (user_id, goal_date);

-- ---------------------------------------------------------------------------
-- leagues / league_members — competencia semanal por XP
-- ---------------------------------------------------------------------------
create table leagues (
  id         uuid primary key default gen_random_uuid(),
  division   league_division not null,
  week_start date not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index leagues_week_idx on leagues (week_start, division);

create table league_members (
  id         uuid primary key default gen_random_uuid(),
  league_id  uuid not null references leagues(id) on delete cascade,
  user_id    uuid not null references users(id)   on delete cascade,
  weekly_xp  int not null default 0,
  rank       int,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (league_id, user_id)
);
-- Índice clave (Modelo_Datos §"Decisiones"): rankear la liga por XP semanal.
create index league_members_standings_idx on league_members (league_id, weekly_xp);

-- ---------------------------------------------------------------------------
-- achievements / user_achievements — logros y badges
-- ---------------------------------------------------------------------------
create table achievements (
  id          uuid primary key default gen_random_uuid(),
  code        text not null unique,
  name        text not null,
  description text,
  criteria    jsonb not null default '{}'::jsonb,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create table user_achievements (
  id             uuid primary key default gen_random_uuid(),
  user_id        uuid not null references users(id)        on delete cascade,
  achievement_id uuid not null references achievements(id) on delete cascade,
  unlocked_at    timestamptz not null default now(),
  created_at     timestamptz not null default now(),
  unique (user_id, achievement_id)
);
create index user_achievements_user_idx on user_achievements (user_id);

-- ---------------------------------------------------------------------------
-- chest_openings — recompensa variable (cofres)
-- ---------------------------------------------------------------------------
create table chest_openings (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null references users(id) on delete cascade,
  reward_type   text not null,                -- gold | booster | freeze | ...
  reward_amount int,
  opened_at     timestamptz not null default now(),
  created_at    timestamptz not null default now()
);
create index chest_openings_user_idx on chest_openings (user_id);

-- ---------------------------------------------------------------------------
-- wagers — "apostar oro" (opcional/suave)
-- ---------------------------------------------------------------------------
create table wagers (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references users(id) on delete cascade,
  type        wager_type not null,
  stake_gold  int not null,
  reward_gold int not null,
  start_date  date,
  end_date    date,
  status      wager_status not null default 'active',
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);
create index wagers_user_idx on wagers (user_id, status);
