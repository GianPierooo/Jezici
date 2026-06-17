# Jezici — Go-Live (GA6: de demo a producción real)

Principio rector: **honestidad sobre apariencia**. Nada falso ni a medias frente
a usuarios reales. Lo que no está listo se OCULTA, no se simula.

## 1. Inventario REAL vs DUMMY vs NO-FUNCIONAL (estado actual)

| Apartado / Pantalla | Estado | Notas |
|---|---|---|
| Auth (crear cuenta / iniciar sesión, email) | ✅ REAL | Supabase Auth, autoconfirm. Login social Google/Apple **quitado** (no implementado). |
| Onboarding (9 pasos) + plan | ✅ REAL | Persiste plan/personalidad (create_plan), `onboarding_completed`. |
| Aprender (mapa, unidades, lecciones, gating) | ✅ REAL | 18 unidades (A1+A2 con contenido; B1 esqueleto oculto sin lecciones). |
| Lección (ejercicios, vidas, XP, 4 skills) | ✅ REAL | Calificación server-side (complete_lesson). |
| Checkpoint + gating de unidad | ✅ REAL | submit_checkpoint, desbloqueo por order_index. |
| Examen de nivel + certificado (A1→A2…) | ✅ REAL | Multinivel, certificado SVG con folio/código. |
| Practicar (rescate/SRS, debilidades, contrarreloj, por habilidad) | ✅ REAL | start/submit_practice, SRS SM-2 lite. |
| Perfil (4 skills + radar, plan, logros, certificados) | ✅ REAL | Datos reales del usuario. |
| Mi Plan (dashboard: adelante/atrás, proyección, palanca) | ✅ REAL | get_plan_tracking server-side. |
| Ligas | ✅ REAL (GA6) | **Bots eliminados.** Solo usuarios reales + estado "arrancando" con baja población. |
| Tienda (oro, cofre diario, vidas) | ✅ REAL | shop_status/open_daily_chest/buy_hearts. |
| Notificaciones / Matix (in-app + web push) | ✅ REAL | matix_fire, quiet_hours, techo; web push (VAPID). |
| Ajustes (coach, intensidad, meta, push, legal, logout, **borrar cuenta**) | ✅ REAL | Borrado de cuenta real (delete_account, cascada). |
| Legal (Privacidad + Términos) | ✅ REAL | Enlazados en auth (alta) y ajustes. |
| Métricas (panel interno) | ✅ REAL | get_metrics + embudo de onboarding + engagement (uso por sección, feedback, interés). |
| **Feedback in-app (GA7)** | ✅ REAL | Botón en toda la app (FAB en tabs + acción en Ajustes) → tabla `feedback` con contexto (pantalla, versión, plataforma). |
| **Conversar (GA7)** | ✅ PREVIEW SEGURO | Práctica en SOLITARIO/asíncrona (tema → escribe/habla → modelo + autoevaluación, guardada). Captura de interés + waitlist para la conversación EN VIVO. **Sin chat con desconocidos, sin IA.** Conversación en vivo + scoring IA = Fase 2 (con moderación + verificación de edad). |
| **Simulacros IELTS/Cambridge** | 🚫 OCULTO | Motor real no construido (Fase 1 solo estructura). Quitado de Practicar. |
| **Premium / pagos** | ⏸ PRÓXIMAMENTE | Sin pasarela (Stripe/RevenueCat pendientes). Pantalla "próximamente" honesta; no simula compra. |
| Email transaccional | ⏸ PENDIENTE | Sin proveedor aún (ver §4). No se simula ningún envío al usuario. |

## 2. Qué se hizo REAL / qué se OCULTÓ (GA6)
- **Oculto:** Conversar (fuera del bottom-nav, 5→4 pestañas), Simulacros (fuera de Practicar), login social.
- **De dummy a real:** Ligas sin bots (get_league solo reales + warming_up); avatares reales.
- **Nuevo real:** borrado de cuenta (obligación legal) con confirmación.

## 3. BD sin datos demo
Purgados los 33 usuarios de prueba/anónimos y TODA su data (cascada). La BD queda
solo con **contenido real del curso**: 1 course, 18 units, 61 lessons, 400
content_items, 504 lesson_items, 184 vocabulary, 14 exams. 0 usuarios, 0 progreso,
0 bots. Lista para usuarios reales.

## 4. Producción / monitoreo / legal
- **RLS:** reverificado — TODAS las tablas public tienen RLS habilitado + políticas. La lógica sensible (XP/oro/aprobado/cert) vive en RPC SECURITY DEFINER (server-side). Sin backdoors de test.
- **Secretos:** ninguno en el repo; los scripts leen de `.env` (gitignored). Anon key pública por diseño (RLS).
- **Push:** real (VAPID + Edge Function send-push).
- **Monitoreo de errores:** captura de crashes (FlutterError + zona) → `analytics_events` (evento `client_error`), pure-Dart y **ya activo** en producción (queryable). Sentry/APM completo es **opcional**: se añade con un DSN (ver "Necesito de ti"). Se evitó `sentry_flutter` por ahora porque sus build-hooks nativos rompían el build web en Vercel; la captura básica cubre "saber qué falla".
- **Borrado de cuenta + legal:** delete_account (RPC, cascada) + Privacidad/Términos enlazados.
- **Email transaccional:** pendiente de proveedor (ver abajo).
- **Backups:** Supabase hace backups diarios; PITR requiere plan Pro (acción tuya en el dashboard).

## 5. Checklist GO-LIVE — lo que necesito de ti
| # | Qué | Por qué | Cómo |
|---|---|---|---|
| 1 | **Sentry (opcional)**: proyecto Flutter/web + **DSN** | APM completo (los errores ya se capturan a analytics_events sin esto) | Si lo quieres, pásame el DSN y re-añado el SDK web-safe + lo cableo. |
| 2 | **Cuenta Apple Developer** ($99/año) + Mac/Xcode | Build y publicación iOS / TestFlight | Necesaria para firmar y subir el `.ipa`. |
| 3 | **Cuenta Google Play Developer** ($25 único) + **keystore** | Publicación Android / internal testing | Genera el keystore (o autorízame) para firmar el AAB. |
| 4 | **Proveedor de email** (Resend/Postmark) + API key | Bienvenida, certificado, win-back | Pega la key; integro la Edge Function de envío. |
| 5 | **Pagos** (Stripe + RevenueCat) cuando quieras monetizar | Premium real | Sin esto, Premium queda "próximamente" (honesto). |
| 6 | **Supabase Pro** (opcional) | PITR / backups por punto en el tiempo | Activar en el dashboard. |

## 6. Listo para invitar beta (con email + cuentas dev)
- Web (PWA) en https://jezici.vercel.app — **ya usable por usuarios reales** (auth, onboarding, curso A1+A2, exámenes, certificados, práctica, ligas reales, perfil).
- Móvil: requiere #2/#3 para empaquetar y subir a TestFlight / Play internal testing.

## 7. Beta-readiness (GA7) — cada apartado usable y seguro
| Apartado | ¿Usable en beta? | Seguridad |
|---|---|---|
| Aprender / Lección / Checkpoint | ✅ sí, real | scoring server-side |
| Examen de nivel + certificado | ✅ sí, real | server-side, multinivel |
| Practicar (SRS/debilidades/contrarreloj/skill) | ✅ sí, real | — |
| Perfil (4 skills, plan, logros, certs) | ✅ sí, real | datos propios (RLS) |
| Ligas | ✅ sí, real (sin bots) | sólo usuarios reales; "arrancando" con baja población |
| Conversar | ✅ sí, taste solo/async + waitlist | **sin desconocidos, sin IA** — seguro para beta |
| Feedback in-app | ✅ sí, en toda la app | inserta sólo lo propio (RLS) |
| Premium | ⏸ "próximamente" (no simula compra) | — |
| Borrar cuenta | ✅ sí | derecho de supresión |

**Instrumentado para aprender:** `screen_view` por sección, embudo de onboarding
(drop-off por paso), `conversar_interest` (señal de demanda de conversación en
vivo), `conversar_attempt`, feedback cualitativo. Todo en el panel de Métricas
(get_metrics + get_onboarding_funnel + get_engagement).

**Para invitar a la beta web HOY:** nada más de tu lado — comparte el link
https://jezici.vercel.app. Para beta MÓVIL e emails transaccionales, ver §5
(#2 Apple, #3 Google, #4 email).
