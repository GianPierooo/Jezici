-- 20260710120140_am_i_admin.sql
-- RPC público (solo lectura) para que el CLIENTE sepa si el usuario actual es
-- admin y así OCULTAR la entrada "Ver métricas (interno)". No expone datos: solo
-- un booleano sobre auth.uid(). `jz_is_admin()` está revocado al cliente (mig 049);
-- esto es un wrapper mínimo con grant a authenticated. La SEGURIDAD real sigue
-- siendo server-side: get_metrics/get_feedback/get_engagement/get_onboarding_funnel
-- rechazan a no-admin con "admin only" (mig 058) aunque llamen al RPC a mano.
begin;

create or replace function am_i_admin()
returns boolean language sql stable security definer set search_path = public as $$
  select exists (select 1 from admins where user_id = auth.uid());
$$;

grant execute on function am_i_admin() to authenticated;

commit;
