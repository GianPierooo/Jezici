-- T4 (fix): gold_transactions.reason es un ENUM (gold_reason) y no conocía el
-- rescate de racha. Valor nuevo en su propia migración (regla de enums).
alter type public.gold_reason add value if not exists 'streak_revive';
