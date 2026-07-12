// Jezici · matix-push — FAN-OUT de Web Push (VAPID, sin FCM).
//
// Recorre las notificaciones del motor Matix con status='sent' que aún no se
// han empujado (pushed_at IS NULL, últimas 24 h) y las envía por Web Push a
// TODAS las suscripciones del usuario (push_subscriptions). Marca pushed_at y
// elimina suscripciones muertas (404/410).
//
// Invocación (lazy-cron): cualquier cliente autenticado la invoca al arrancar
// (fire-and-forget) → un usuario activo empuja los pendientes de los OFFLINE.
// Para garantizar puntualidad sin depender de usuarios activos, Gian puede
// agendar un cron externo (cron-job.org) que la llame cada 15 min con el
// header Authorization: Bearer <anon key>.
//
// Secrets requeridos (Edge Function): VAPID_PUBLIC_KEY, VAPID_PRIVATE_KEY,
// VAPID_SUBJECT (mailto:). SUPABASE_URL/SERVICE_ROLE_KEY las inyecta Supabase.
import webpush from "npm:web-push@3.6.7";
import { createClient } from "npm:@supabase/supabase-js@2";

Deno.serve(async (_req) => {
  const url = Deno.env.get("SUPABASE_URL")!;
  const key = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const vapidPub = Deno.env.get("VAPID_PUBLIC_KEY");
  const vapidPriv = Deno.env.get("VAPID_PRIVATE_KEY");
  const subject = Deno.env.get("VAPID_SUBJECT") ?? "mailto:hola@jezici.app";
  if (!vapidPub || !vapidPriv) {
    return new Response(JSON.stringify({ ok: false, reason: "vapid_not_configured" }),
      { status: 200, headers: { "content-type": "application/json" } });
  }
  webpush.setVapidDetails(subject, vapidPub, vapidPriv);
  const db = createClient(url, key);

  // Pendientes: enviadas por el motor, no empujadas aún, recientes (24 h).
  const since = new Date(Date.now() - 24 * 3600 * 1000).toISOString();
  const { data: pending, error } = await db
    .from("notifications")
    .select("id, user_id, body")
    .eq("status", "sent")
    .is("pushed_at", null)
    .gte("sent_at", since)
    .limit(100);
  if (error) {
    return new Response(JSON.stringify({ ok: false, reason: error.message }),
      { status: 200, headers: { "content-type": "application/json" } });
  }
  let sent = 0, dead = 0;
  for (const n of pending ?? []) {
    const { data: subs } = await db
      .from("push_subscriptions")
      .select("id, endpoint, p256dh, auth")
      .eq("user_id", n.user_id);
    for (const s of subs ?? []) {
      try {
        await webpush.sendNotification(
          { endpoint: s.endpoint, keys: { p256dh: s.p256dh, auth: s.auth } },
          JSON.stringify({ title: "Jezi · Jezici", body: n.body, tag: "matix" }),
        );
        sent++;
      } catch (e) {
        const code = (e as { statusCode?: number }).statusCode ?? 0;
        if (code === 404 || code === 410) {
          await db.from("push_subscriptions").delete().eq("id", s.id);
          dead++;
        }
      }
    }
    await db.from("notifications").update({ pushed_at: new Date().toISOString() }).eq("id", n.id);
  }
  return new Response(JSON.stringify({ ok: true, processed: (pending ?? []).length, sent, dead }),
    { status: 200, headers: { "content-type": "application/json" } });
});
