-- ============================================================================
-- Jezici · Migración 012 · Suscripción
-- ----------------------------------------------------------------------------
-- Fuente: Modelo_Datos.md §12 + Modelo_Negocio.md. Una suscripción por usuario.
-- ============================================================================

create table subscriptions (
  user_id    uuid primary key references users(id) on delete cascade,
  plan       subscription_plan   not null default 'free',
  status     subscription_status not null default 'active',
  started_at timestamptz,
  renews_at  timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
