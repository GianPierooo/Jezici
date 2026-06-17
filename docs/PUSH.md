# Jezici · Web Push (Matix remoto)

Estado: **fundación lista**. Lo que falta para enviar push reales está abajo.

## Hecho
- **PWA instalable** (manifest + íconos de marca + `web/sw.js` update-safe).
- `sw.js` maneja los eventos `push` y `notificationclick` (muestra la notificación con el copy de Matix y abre la app).
- Tabla `push_subscriptions` + RPC `save_push_subscription(endpoint,p256dh,auth)` (RLS por usuario).
- **VAPID** generadas (en `.env`, gitignored). Clave **pública** (segura, va al cliente):
  ```
  BLPjF2QFK_QBLCevZ6SmmX0IymJUshKouQ1H_9ovGhvBZzmv7zxofgKhIxWAZ6GOKCtQNQmIloXiu-h673pk6Ao
  ```
- Edge Function `supabase/functions/send-push/index.ts` (transporte web-push con VAPID), lista para deploy.

## Falta para producción (necesito que confirmes/configures)
1. **Deploy de la función** (con la CLI de Supabase, que requiere login interactivo que no tengo aquí):
   ```
   supabase functions deploy send-push --no-verify-jwt
   supabase secrets set VAPID_PUBLIC_KEY=BLPjF2QFK_QBLCevZ6SmmX0IymJUshKouQ1H_9ovGhvBZzmv7zxofgKhIxWAZ6GOKCtQNQmIloXiu-h673pk6Ao      VAPID_PRIVATE_KEY=<la privada de .env> VAPID_SUBJECT=mailto:shadowgames.devteam@gmail.com      SUPABASE_URL=<url> SUPABASE_SERVICE_ROLE_KEY=<service_role>
   ```
2. **UI cliente de suscripción**: un botón en Ajustes que, en web, pida permiso y haga
   `PushManager.subscribe({ applicationServerKey: <VAPID pública> })` y llame a `save_push_subscription`.
   (Requiere un navegador real para conceder permiso; no es verificable headless.)
3. **Disparo desde Matix**: un cron (pg_cron + pg_net, o un job externo) que evalúe los triggers
   (racha en riesgo, meta sin cumplir, win-back, cuenta atrás de examen), llame a `matix_fire` para
   registrar+elegir el copy respetando techo y quiet_hours, y luego invoque `send-push` con ese copy.

Mientras tanto, Matix ya entrega en el dispositivo vía `flutter_local_notifications` + el centro
in-app (se ve el tono del estilo de coach), que es lo verificable sin un navegador con permiso real.
