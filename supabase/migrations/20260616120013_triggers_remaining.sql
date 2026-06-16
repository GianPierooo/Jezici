-- ============================================================================
-- Jezici · Migración 013 · Triggers updated_at de los dominios nuevos
-- ----------------------------------------------------------------------------
-- Reutiliza set_updated_at() (migración 004). Solo tablas con columna updated_at.
-- ============================================================================

create trigger trg_user_plans_updated_at              before update on user_plans              for each row execute function set_updated_at();
create trigger trg_exams_updated_at                   before update on exams                   for each row execute function set_updated_at();
create trigger trg_exam_attempts_updated_at           before update on exam_attempts           for each row execute function set_updated_at();
create trigger trg_certificates_updated_at            before update on certificates            for each row execute function set_updated_at();
create trigger trg_vocabulary_updated_at              before update on vocabulary              for each row execute function set_updated_at();
create trigger trg_user_vocab_srs_updated_at          before update on user_vocab_srs          for each row execute function set_updated_at();
create trigger trg_daily_goals_updated_at             before update on daily_goals             for each row execute function set_updated_at();
create trigger trg_leagues_updated_at                 before update on leagues                 for each row execute function set_updated_at();
create trigger trg_league_members_updated_at          before update on league_members          for each row execute function set_updated_at();
create trigger trg_achievements_updated_at            before update on achievements            for each row execute function set_updated_at();
create trigger trg_wagers_updated_at                  before update on wagers                  for each row execute function set_updated_at();
create trigger trg_user_personality_updated_at        before update on user_personality        for each row execute function set_updated_at();
create trigger trg_notification_templates_updated_at  before update on notification_templates  for each row execute function set_updated_at();
create trigger trg_notifications_updated_at           before update on notifications           for each row execute function set_updated_at();
create trigger trg_social_profiles_updated_at         before update on social_profiles         for each row execute function set_updated_at();
create trigger trg_connections_updated_at             before update on connections             for each row execute function set_updated_at();
create trigger trg_conversation_rooms_updated_at      before update on conversation_rooms      for each row execute function set_updated_at();
create trigger trg_coop_challenges_updated_at         before update on coop_challenges         for each row execute function set_updated_at();
create trigger trg_conversation_challenges_updated_at before update on conversation_challenges for each row execute function set_updated_at();
create trigger trg_subscriptions_updated_at           before update on subscriptions           for each row execute function set_updated_at();
