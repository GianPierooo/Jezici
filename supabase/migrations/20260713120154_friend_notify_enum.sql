-- ─────────────────────────────────────────────────────────────────────────────
-- FIX SISTEMA DE AMISTAD · parte 1/2 — valores de enum para notificar solicitudes
-- ─────────────────────────────────────────────────────────────────────────────
-- Síntoma 2 (el central): cuando A envía una solicitud a B, la fila pending SÍ se
-- crea y B la ve en list_friends.incoming — PERO no se dispara NINGUNA señal
-- (in-app ni push), así que B nunca se entera de que debe abrir Amigos a aceptar.
-- Solución: notificar al receptor (in-app + push) al llegar la solicitud y al
-- requester cuando se acepta. La notificación viaja por la MISMA tabla
-- `notifications` (status='sent' → la ve el centro + la empuja la Edge Function
-- matix-push). Para eso el enum notification_trigger necesita dos valores nuevos.
--
-- Va en una migración PROPIA (separada de la lógica) porque Postgres NO permite
-- USAR un valor de enum recién añadido en la MISMA transacción que lo agrega.
-- ─────────────────────────────────────────────────────────────────────────────
alter type public.notification_trigger add value if not exists 'friend_request';
alter type public.notification_trigger add value if not exists 'friend_accepted';
