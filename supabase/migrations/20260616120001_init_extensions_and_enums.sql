-- ============================================================================
-- Jezici · Migración 001 · Extensiones y tipos enum
-- ----------------------------------------------------------------------------
-- Fuente: Jezici_Modelo_Datos.md (convenciones: snake_case, PK uuid,
-- created_at/updated_at, jsonb para payloads flexibles, "enums como tipos
-- Postgres o CHECK").
--
-- Decisión: usamos tipos ENUM nativos de Postgres para los dominios ESTABLES
-- y compartidos entre muchas tablas (CEFR, las 4 habilidades, etc.). Dan
-- seguridad a nivel de tipo, evitan repetir CHECKs y generan tipos limpios
-- para el cliente Flutter. Para añadir un valor en el futuro:
--   ALTER TYPE <tipo> ADD VALUE 'nuevo';
-- ============================================================================

-- gen_random_uuid() es nativo en Postgres 13+ (Supabase corre 15+).
-- pgcrypto se crea por seguridad/compatibilidad; no es estrictamente necesario.
create extension if not exists pgcrypto;

-- Niveles CEFR. Usado por: units, lessons (vía unit), content_items,
-- user_skill_levels, y más adelante exams/certificates.
create type cefr_level as enum ('A1', 'A2', 'B1', 'B2', 'C1', 'C2');

-- Las 4 habilidades (el diferenciador). Usado por: content_items, user_skill_levels.
create type skill as enum ('reading', 'listening', 'writing', 'speaking');

-- Tipo de nodo del mapa. Usado por: lessons.
create type lesson_type as enum ('lesson', 'checkpoint', 'mission');

-- Tipos de ejercicio del banco único. Usado por: content_items.
-- Lista de Modelo_Datos §2 + 'true_false' (Banco_Items §1 lo añade).
create type content_item_type as enum (
  'multiple_choice',
  'cloze',
  'word_bank',
  'reorder',
  'match',
  'translation',
  'listening',
  'dictation',
  'speaking_read_aloud',
  'guided_writing',
  'true_false'
);

-- Estado de cada nodo del mapa para un usuario. Usado por: user_lesson_progress.
-- Los estados visuales del mapa (bloqueado/disponible/completado/dorado) derivan de aquí.
create type lesson_progress_status as enum (
  'locked',
  'available',
  'in_progress',
  'completed',
  'golden'
);
