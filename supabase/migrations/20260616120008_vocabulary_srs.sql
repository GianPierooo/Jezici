-- ============================================================================
-- Jezici · Migración 008 · Vocabulario y repaso espaciado (SRS)
-- ----------------------------------------------------------------------------
-- Fuente: Modelo_Datos.md §6. Alimenta "Rescate de palabras" (Estructura §5).
-- ============================================================================

-- ---------------------------------------------------------------------------
-- vocabulary — banco de palabras (100/300/1000) por frecuencia (compartido)
-- ---------------------------------------------------------------------------
create table vocabulary (
  id             uuid primary key default gen_random_uuid(),
  course_id      uuid not null references courses(id) on delete cascade,
  word           text not null,
  translation    text not null,
  frequency_rank int,
  part_of_speech text,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);
create index vocabulary_course_freq_idx on vocabulary (course_id, frequency_rank);

-- ---------------------------------------------------------------------------
-- user_vocab_srs — agenda de repaso por palabra (por usuario)
-- ---------------------------------------------------------------------------
create table user_vocab_srs (
  id               uuid primary key default gen_random_uuid(),
  user_id          uuid not null references users(id)      on delete cascade,
  vocab_id         uuid not null references vocabulary(id) on delete cascade,
  strength         numeric not null default 0,
  ease             numeric not null default 2.5,
  interval_days    int not null default 0,
  due_at           timestamptz,
  last_reviewed_at timestamptz,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now(),
  unique (user_id, vocab_id)
);
-- Índice clave (Modelo_Datos §"Decisiones"): traer "lo que está por olvidar".
create index user_vocab_srs_due_idx on user_vocab_srs (user_id, due_at);
