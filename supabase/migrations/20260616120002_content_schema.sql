-- ============================================================================
-- Jezici · Migración 002 · Contenido del curso (compartido, estático/cacheado)
-- ----------------------------------------------------------------------------
-- Fuente: Jezici_Modelo_Datos.md §2 (Idiomas y contenido del curso).
-- Patrón Duolingo: el contenido es estático y compartido entre usuarios; lo del
-- usuario se calcula por request (ver migración 003).
--
-- Nota de convención: el documento usa una columna `order` en units/lessons/
-- lesson_items. `ORDER` es palabra reservada en SQL, así que la nombramos
-- `order_index` (mismo significado). Se documenta aquí el mapeo 1:1.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- languages — catálogo de idiomas (en, es, pt, ...)
-- ---------------------------------------------------------------------------
create table languages (
  id         uuid primary key default gen_random_uuid(),
  code       text not null unique,          -- ISO 639-1: 'en', 'es', 'pt'
  name       text not null,                 -- nombre legible
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- courses — un par idioma-nativo -> idioma-objetivo (lanzamiento: es -> en)
-- ---------------------------------------------------------------------------
create table courses (
  id                 uuid primary key default gen_random_uuid(),
  source_language_id uuid not null references languages(id) on delete restrict,
  target_language_id uuid not null references languages(id) on delete restrict,
  is_active          boolean not null default true,
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now(),
  unique (source_language_id, target_language_id),
  check  (source_language_id <> target_language_id)
);

-- ---------------------------------------------------------------------------
-- units — regiones temáticas del mapa, por nivel CEFR
-- ---------------------------------------------------------------------------
create table units (
  id          uuid primary key default gen_random_uuid(),
  course_id   uuid not null references courses(id) on delete cascade,
  cefr_level  cefr_level not null,
  order_index int not null,                 -- doc: `order`
  title       text not null,
  theme_color text,                          -- token de color de la región (Sistema_Diseno)
  icon        text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  unique (course_id, order_index)
);
create index units_course_idx on units (course_id);

-- ---------------------------------------------------------------------------
-- lessons — nodos del mapa (lección | checkpoint | misión)
-- ---------------------------------------------------------------------------
create table lessons (
  id          uuid primary key default gen_random_uuid(),
  unit_id     uuid not null references units(id) on delete cascade,
  order_index int not null,                 -- doc: `order`
  title       text not null,
  description text,
  type        lesson_type not null default 'lesson',
  xp_reward   int not null default 0,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  unique (unit_id, order_index)
);
create index lessons_unit_idx on lessons (unit_id);

-- ---------------------------------------------------------------------------
-- content_items — banco ÚNICO de ejercicios/preguntas (sirve a lecciones y exámenes)
--   payload / correct_answer son jsonb para soportar todos los tipos de ejercicio.
--   tags[] (Banco_Items §1) alimenta el diagnóstico de debilidades.
-- ---------------------------------------------------------------------------
create table content_items (
  id             uuid primary key default gen_random_uuid(),
  course_id      uuid not null references courses(id) on delete cascade,
  cefr_level     cefr_level not null,
  skill          skill not null,
  type           content_item_type not null,
  prompt         text,
  payload        jsonb not null default '{}'::jsonb,  -- opciones, audio_url, tiles, distractores
  correct_answer jsonb,                                -- respuesta(s) esperada(s)
  difficulty     numeric,                              -- 0..1 (o usar irt_*)
  irt_a          numeric,                              -- discriminación (opcional, adaptatividad)
  irt_b          numeric,                              -- dificultad IRT (opcional)
  tags           text[] not null default '{}',         -- tema/unidad/función gramatical
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);

-- Índice clave (Modelo_Datos §"Decisiones"): armar exámenes por nivel/skill/dificultad.
create index content_items_selection_idx
  on content_items (course_id, cefr_level, skill, difficulty);

-- ---------------------------------------------------------------------------
-- lesson_items — qué ítems componen cada lección, y en qué orden
--   Tabla de unión: PK compuesta evita duplicar un ítem en la misma lección;
--   unique(lesson_id, order_index) evita dos ítems en la misma posición.
-- ---------------------------------------------------------------------------
create table lesson_items (
  lesson_id   uuid not null references lessons(id) on delete cascade,
  item_id     uuid not null references content_items(id) on delete cascade,
  order_index int not null,                 -- doc: `order`
  created_at  timestamptz not null default now(),
  primary key (lesson_id, item_id),
  unique (lesson_id, order_index)
);
create index lesson_items_item_idx on lesson_items (item_id);
