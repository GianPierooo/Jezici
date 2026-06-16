-- ============================================================================
-- Jezici · Migración 007 · Plan del usuario, exámenes y certificados
-- ----------------------------------------------------------------------------
-- Fuente: Modelo_Datos.md §3 (user_plans), §7 (exams, exam_attempts), §8 (certificates).
-- ============================================================================

-- ---------------------------------------------------------------------------
-- user_plans — el plan con fecha estimada (motor determinista, Estructura §2)
-- ---------------------------------------------------------------------------
create table user_plans (
  id                        uuid primary key default gen_random_uuid(),
  user_id                   uuid not null references users(id)   on delete cascade,
  course_id                 uuid not null references courses(id) on delete cascade,
  current_level             cefr_level not null,
  goal_level                cefr_level not null,
  daily_minutes             int,
  days_per_week             int,
  motive                    text,
  deadline                  date,
  estimated_hours           int,
  estimated_completion_date date,
  created_at                timestamptz not null default now(),
  updated_at                timestamptz not null default now(),
  unique (user_id, course_id)
);
create index user_plans_user_idx on user_plans (user_id);

-- ---------------------------------------------------------------------------
-- exams — definiciones de examen (contenido). cefr_level nullable para placement;
--         unit_id para checkpoint de unidad.
-- ---------------------------------------------------------------------------
create table exams (
  id             uuid primary key default gen_random_uuid(),
  course_id      uuid not null references courses(id) on delete cascade,
  type           exam_type not null,
  cefr_level     cefr_level,
  unit_id        uuid references units(id) on delete cascade,
  time_limit_sec int,
  pass_threshold numeric,
  sections       jsonb not null default '{}'::jsonb,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);
create index exams_course_type_idx on exams (course_id, type);

-- ---------------------------------------------------------------------------
-- exam_attempts — intentos y resultados (scoring por sección y por habilidad)
-- ---------------------------------------------------------------------------
create table exam_attempts (
  id                 uuid primary key default gen_random_uuid(),
  user_id            uuid not null references users(id) on delete cascade,
  exam_id            uuid not null references exams(id) on delete cascade,
  started_at         timestamptz not null default now(),
  finished_at        timestamptz,
  score_global       numeric,
  per_section_scores jsonb,
  per_skill_results  jsonb,   -- nivel logrado por skill (regla de 4 skills)
  passed             boolean,
  band_report        jsonb,   -- para simulacros IELTS/Cambridge
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now()
);
create index exam_attempts_user_idx on exam_attempts (user_id, exam_id);

-- ---------------------------------------------------------------------------
-- certificates — credencial emitida al pasar un examen de nivel
-- ---------------------------------------------------------------------------
create table certificates (
  id                uuid primary key default gen_random_uuid(),
  user_id           uuid not null references users(id)   on delete cascade,
  course_id         uuid not null references courses(id) on delete cascade,
  cefr_level        cefr_level not null,
  issued_at         timestamptz not null default now(),
  folio             text not null unique,
  verification_code text not null unique,
  pdf_url           text,
  exam_attempt_id   uuid references exam_attempts(id) on delete set null,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);
create index certificates_user_idx on certificates (user_id);
