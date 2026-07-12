-- T4 (1/2): nuevos triggers del motor Matix — el enum se amplía en su propia
-- migración (Postgres no permite USAR un valor de enum nuevo en la misma
-- transacción que lo añade).
alter type public.notification_trigger add value if not exists 'goal_met';
alter type public.notification_trigger add value if not exists 'hearts_out';
