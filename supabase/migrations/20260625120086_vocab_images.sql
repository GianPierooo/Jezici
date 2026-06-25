-- ============================================================================
-- Jezici . Migracion 086 . Registro de imagenes referenciales de vocabulario
-- ----------------------------------------------------------------------------
-- Doble codificacion (imagen + palabra) para vocab CONCRETO (A1/A2). Tabla =
-- registro reutilizable + PROVENIENCIA de licencia (innegociable: solo fuentes con
-- licencia clara). Fuente: Twemoji (CC-BY 4.0), alojado en Storage (bucket audio,
-- path vocab/<concept>.png), cargado diferido por el cliente. El cliente NO consulta
-- esta tabla: el URL viaja en content_items.payload.image_url (via content_items_public).
-- RLS habilitado SIN policy => sin acceso de cliente (solo service_role); es solo
-- registro interno de proveniencia/licencia. Aditivo: no toca nada existente.
-- ============================================================================
begin;

create table if not exists vocab_images (
  concept     text primary key,
  category    text,
  codepoint   text,
  image_url   text not null,
  source      text not null,            -- p.ej. 'Twemoji 15.1 (jdecked)'
  license     text not null,            -- p.ej. 'CC-BY 4.0'
  attribution text not null,            -- credito requerido por la licencia
  created_at  timestamptz not null default now()
);

alter table vocab_images enable row level security;  -- sin policy => cliente no lee la tabla

commit;
