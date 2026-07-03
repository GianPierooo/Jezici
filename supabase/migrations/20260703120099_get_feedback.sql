-- 20260703120099_get_feedback.sql
-- LEER el feedback de usuarios (lo que Gian pidió: "¿dónde lo veo?").
--
-- Contexto: `submit_feedback` (mig 038) captura feedback in-app (tabla `feedback`:
-- screen/kind/message/platform/app_version) y funciona (hay filas reales). PERO la
-- tabla tiene RLS con SOLO policy de INSERT (self) → SELECT bloqueado para el cliente,
-- y `get_engagement` únicamente devuelve el CONTEO por tipo (`feedback_by_kind`), no el
-- TEXTO. Resultado: el feedback se recogía pero NADIE podía leerlo.
--
-- Fix: RPC admin `get_feedback(limit)` (SECURITY DEFINER + `jz_is_admin()`, como el resto
-- del panel interno) que devuelve los MENSAJES reales (texto, pantalla, tipo, plataforma,
-- versión, fecha) ordenados por fecha desc. SIN PII: el user_id se recorta a 8 chars
-- opacos (identifica repeticiones del mismo usuario sin exponer email/uuid completo).
-- No-admin (o anon) → excepción 'admin only'.
begin;

create or replace function public.get_feedback(p_limit int default 100)
 returns jsonb
 language plpgsql
 security definer
 set search_path to 'public'
as $function$
declare v jsonb;
begin
  if not jz_is_admin() then raise exception 'admin only'; end if;
  select coalesce(jsonb_agg(to_jsonb(x) order by x.created_at desc), '[]'::jsonb) into v
  from (
    select left(f.message, 2000) as message, f.screen, f.kind,
           f.platform, f.app_version, f.created_at,
           left(f.user_id::text, 8) as user_short
    from feedback f
    order by f.created_at desc
    limit greatest(1, least(coalesce(p_limit, 100), 500))
  ) x;
  return v;
end $function$;

revoke execute on function public.get_feedback(int) from anon;
grant execute on function public.get_feedback(int) to authenticated;

commit;
