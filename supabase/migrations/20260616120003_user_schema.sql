-- ============================================================================
-- Jezici · Migración 003 · Datos del usuario (por request, con auth)
-- ----------------------------------------------------------------------------
-- Fuente: Modelo_Datos.md §1 (users), §4 (progreso), §5 (4 habilidades),
-- §9 (gamificación: user_stats, streaks).
--
-- Integración con Supabase Auth: la autenticación la gestiona Supabase
-- (tabla auth.users). public.users es el PERFIL de aplicación, 1:1 con la
-- cuenta de auth (id compartido). Al borrar la cuenta de auth, cascada limpia
-- el perfil y todo lo dependiente.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- users — perfil de aplicación (1:1 con auth.users)
-- ---------------------------------------------------------------------------
create table users (
  id                 uuid primary key references auth.users(id) on delete cascade,
  email              text unique,
  auth_provider      text,                  -- email | google | apple
  name               text,
  display_name       text,
  avatar_url         text,
  native_language_id uuid references languages(id) on delete set null,
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- user_course_progress — posición del usuario en un curso
-- ---------------------------------------------------------------------------
create table user_course_progress (
  id                uuid primary key default gen_random_uuid(),
  user_id           uuid not null references users(id) on delete cascade,
  course_id         uuid not null references courses(id) on delete cascade,
  current_unit_id   uuid references units(id)   on delete set null,
  current_lesson_id uuid references lessons(id) on delete set null,
  xp_total          int not null default 0,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  unique (user_id, course_id)
);
create index user_course_progress_user_idx on user_course_progress (user_id);

-- ---------------------------------------------------------------------------
-- user_lesson_progress — estado de cada nodo del mapa para el usuario
--   Los estados visuales del mapa derivan de aquí (+ dependencias entre nodos).
-- ---------------------------------------------------------------------------
create table user_lesson_progress (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid not null references users(id)   on delete cascade,
  lesson_id       uuid not null references lessons(id) on delete cascade,
  status          lesson_progress_status not null default 'locked',
  best_accuracy   numeric,
  times_completed int not null default 0,
  completed_at    timestamptz,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  unique (user_id, lesson_id)
);
-- Índice clave (Modelo_Datos §"Decisiones"): derivar el mapa por estado.
create index user_lesson_progress_status_idx on user_lesson_progress (user_id, status);

-- ---------------------------------------------------------------------------
-- user_skill_levels — 4 filas por (usuario, curso): una por habilidad
--   Regla de certificación: se certifica el nivel N solo si LAS 4 filas
--   tienen cefr_level >= N (lógica de aplicación; el esquema garantiza las 4).
-- ---------------------------------------------------------------------------
create table user_skill_levels (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid not null references users(id)   on delete cascade,
  course_id       uuid not null references courses(id) on delete cascade,
  skill           skill not null,
  cefr_level      cefr_level not null default 'A1',
  progress_points numeric not null default 0,           -- avance al siguiente nivel
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  unique (user_id, course_id, skill)
);

-- ---------------------------------------------------------------------------
-- user_stats — gamificación (singleton 1:1 con el usuario)
-- ---------------------------------------------------------------------------
create table user_stats (
  user_id           uuid primary key references users(id) on delete cascade,
  xp_total          int not null default 0,
  gold              int not null default 0,
  hearts            int not null default 5,               -- 5 vidas por defecto
  hearts_updated_at timestamptz not null default now(),   -- para regenerar vidas por tiempo
  player_level      int not null default 1,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- streaks — racha (singleton 1:1 con el usuario)
-- ---------------------------------------------------------------------------
create table streaks (
  user_id           uuid primary key references users(id) on delete cascade,
  current_streak    int not null default 0,
  longest_streak    int not null default 0,
  last_active_date  date,
  freezes_available int not null default 0,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);
