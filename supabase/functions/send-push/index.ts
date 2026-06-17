// Jezici · Edge Function send-push
// ----------------------------------------------------------------------------
// Envía un Web Push (VAPID) a TODAS las suscripciones de un usuario. Pensada
// para que el motor Matix dispare notificaciones remotas reales (racha en
// riesgo, meta sin cumplir, win-back, cuenta atrás de examen) con el copy del
// estilo de coach. El copy/estado lo decide matix_fire (server-side); esta
// función solo es el transporte.
//
// Deploy:
//   supabase functions deploy send-push --no-verify-jwt
//   supabase secrets set VAPID_PUBLIC_KEY=... VAPID_PRIVATE_KEY=... \
//     VAPID_SUBJECT=mailto:tu@correo SUPABASE_URL=... SUPABASE_SERVICE_ROLE_KEY=...
//
// Invocación (desde un cron/servidor de confianza, NO desde el cliente):
//   POST /functions/v1/send-push   { "user_id": "...", "title": "...", "body": "...", "url": "/" }
//
// Para conectarla a Matix en producción: un cron (pg_cron + pg_net, o un job
// externo) evalúa los disparadores, llama a matix_fire para registrar+elegir el
// copy, y luego invoca esta función con el copy resultante.

import webpush from "npm:web-push@3.6.7";
import { createClient } from "npm:@supabase/supabase-js@2";

const VAPID_PUBLIC = Deno.env.get("VAPID_PUBLIC_KEY")!;
const VAPID_PRIVATE = Deno.env.get("VAPID_PRIVATE_KEY")!;
const VAPID_SUBJECT = Deno.env.get("VAPID_SUBJECT") ?? "mailto:admin@jezici.app";
const SB_URL = Deno.env.get("SUPABASE_URL")!;
const SB_SERVICE = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

webpush.setVapidDetails(VAPID_SUBJECT, VAPID_PUBLIC, VAPID_PRIVATE);
const admin = createClient(SB_URL, SB_SERVICE);

Deno.serve(async (req) => {
  try {
    const { user_id, title, body, url } = await req.json();
    if (!user_id) return new Response("user_id required", { status: 400 });

    const { data: subs } = await admin
      .from("push_subscriptions")
      .select("endpoint, p256dh, auth")
      .eq("user_id", user_id);

    const payload = JSON.stringify({ title, body, url: url ?? "/" });
    let sent = 0;
    for (const s of subs ?? []) {
      try {
        await webpush.sendNotification(
          { endpoint: s.endpoint, keys: { p256dh: s.p256dh, auth: s.auth } },
          payload,
        );
        sent++;
      } catch (err) {
        // 404/410 = suscripción expirada → limpiarla.
        const code = (err as { statusCode?: number })?.statusCode;
        if (code === 404 || code === 410) {
          await admin.from("push_subscriptions").delete().eq("endpoint", s.endpoint);
        }
      }
    }
    return Response.json({ ok: true, sent, total: (subs ?? []).length });
  } catch (e) {
    return new Response(`error: ${e}`, { status: 500 });
  }
});
