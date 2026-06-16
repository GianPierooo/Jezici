-- ============================================================================
-- Jezici · Migración 006 · Tipos enum de los dominios restantes
-- ----------------------------------------------------------------------------
-- Fuente: Jezici_Modelo_Datos.md §3, §7–§12. Mismo criterio que 001:
-- enums nativos para dominios estables.
-- ============================================================================

-- §7 Exámenes
create type exam_type as enum ('placement', 'checkpoint', 'level', 'mock_ielts');

-- §9 Gamificación
create type gold_reason as enum (
  'lesson', 'challenge', 'freeze', 'heart_refill', 'retry', 'wager_win', 'wager_loss'
);
create type league_division as enum ('bronce', 'plata', 'oro', 'zafiro', 'rubi', 'diamante');
create type wager_type   as enum ('streak', 'weekly_goal');
create type wager_status as enum ('active', 'won', 'lost');

-- §10 Matix
create type coach_style as enum ('mano_dura', 'positivo', 'rezago', 'suave');
create type notification_trigger as enum (
  'streak_risk', 'goal_unmet', 'behind_plan', 'exam_countdown', 'winback', 'achievement', 'league'
);
create type notification_channel as enum ('push', 'email');
create type notification_status  as enum ('scheduled', 'sent', 'suppressed');

-- §12 Suscripción
create type subscription_plan   as enum ('free', 'premium_monthly', 'premium_annual', 'family');
create type subscription_status as enum ('active', 'canceled', 'past_due');

-- §11 Social / Conversar (estructura base, Fase 2)
create type online_status         as enum ('online', 'offline');
create type connection_status     as enum ('pending', 'accepted', 'blocked');
create type room_status           as enum ('open', 'live', 'closed');
create type coop_status           as enum ('active', 'completed', 'expired');
create type conv_challenge_status as enum ('assigned', 'recorded', 'scored');
