# LAUNCH_AUDIT.md — ¿está todo listo para abrir al público? (2026-07-11)

> Auditoría **solo lectura** (cero cambios de código) previa al lanzamiento público (dominio propio +
> LinkedIn). Introspección REAL: repo + BD (RLS/policies/grants por SQL) + **cliente real JWT** (aislamiento,
> admin gating, apertura social) + navegador (consola/red en `jezici.vercel.app`) + 2 agentes de código
> (flujo de usuario nuevo, i18n/placeholders). Severidades: **P0** bloquea lanzar · **P1** arréglalo pronto ·
> **P2** después.

---

> **ACTUALIZACIÓN 2026-07-11 — los 4 P1 de CÓDIGO están CERRADOS** (ver CLAUDE.md §"P1 de código del
> LAUNCH_AUDIT cerrados"): ✅ age gate unificado (año en el onboarding → no se pregunta dos veces),
> ✅ dev-tool "Probar a Jezi" oculto tras `isAdminProvider`, ✅ consentimiento legal registrado siempre
> (accept_legal en `_finish`), ✅ copy del certificado (COPIAR DATOS + nota suavizada). Verificado cliente
> real. **Quedan pendientes solo las tareas de CUENTA de Gian** (Google OAuth, confirm-email, Sentry) y los
> **i18n P0** (solo bloquean mercados pt/en). El resto de este documento refleja el estado ANTES de estos
> arreglos (histórico).

## 🚦 BLOQUEA LANZAR (lo corto y claro)
**Nada de SEGURIDAD bloquea** — la parte más crítica al abrir a desconocidos está sólida (ver §4).
**No hay bloqueantes duros para un lanzamiento a público HISPANOHABLANTE con la app en español.**

Antes de un lanzamiento **amplio o a mercados pt/en**, o para que se vea 100% terminado, resolver:
1. **i18n P0** — 4 pantallas de recorrido normal están 100% en español y NO cambian a pt/en (Mi Plan,
   Cuaderno, Examen de nivel, Notificaciones). Un usuario con la app en English/Português las ve en español.
2. **Dev-tool expuesto (P1)** — el bloque "Probar a Jezi" (MatixTestButtons) se muestra a TODOS (tab
   Notificaciones + Ajustes→Avanzado) sin gate → parece herramienta interna sin terminar.
3. **Google OAuth (P0 de cuenta, fuera de código)** — el botón "Continuar con Google" no funciona hasta que
   Gian configure Google Cloud + Supabase (ver §8). El registro por **email sí funciona** sin eso.

Todo lo demás es P1/P2 de pulido, no bloqueante.

---

## 1) Flujo del usuario nuevo (registro → age gate → onboarding → placement → 1ª lección → plan)
**Veredicto: sólido y sin dead-ends. 2 fricciones P1.**
- ✅ Gates de arranque en orden correcto (`main.dart`): sesión → onboarding → (needsName || edad) → HomeShell.
  Errores fail-open sanos (perfil en error → HomeShell; onboarding en error → splash con reintento). Sin loops.
- ✅ "Empezar desde cero" salta placement → A1 correctamente. Placement maneja **sin micrófono** (excluye
  speaking, "saltar" no puntúa en contra, muestra la causa real del mic). Primera lección jugable y plan visible.
- ✅ Registro email funciona; Google **solo web** (`kIsWeb`), con degradación honesta si el proveedor falla.
- **[P1] Age gate REDUNDANTE:** el onboarding pide nombre + checkbox "soy mayor de edad" pero **nunca el AÑO**
  de nacimiento → tras el onboarding, `birthYear==null` → `CompleteProfileScreen` aparece para **todo registro
  nuevo**, preguntando la edad por segunda vez justo tras la celebración "Empezar mi viaje". No atasca (verificado
  sin loop), pero es fricción y contradice el diseño documentado. Arreglo: pedir el año en el onboarding **o**
  quitar el checkbox duplicado. (`onboarding_screen.dart:405-491` + `main.dart:193-204`)
- **[P1] Consentimiento legal no persistido si "confirm email" ON:** en registro por email sin sesión inmediata,
  `auth_screen.dart:104` retorna **antes** de `acceptLegal(kLegalVersion)` (:107) → el consentimiento marcado se
  pierde. Condicional al ajuste de Supabase; con confirm-email **OFF** (recomendado en beta) sí se registra.
  Riesgo de cumplimiento: registrar `acceptLegal` también al confirmar/primer login.

## 2) Responsive (móvil / tablet / desktop)
**Veredicto: ✅ CUBIERTO (fix del 2026-07-11, ver RESPONSIVE_AUDIT.md).** Las ~17 pantallas que se estiraban
ya usan `ResponsiveCenter` (patrón único). Verificado golden desktop 1400px (Conversar hub = header full-bleed
+ contenido centrado). Mapa full-bleed con columna de nodos centrada. Nada estirado/roto pendiente. Overflow
móvil arreglado (lección-preview Row→Wrap, métricas `_row`→Expanded). Teclado no tapa inputs (TextFields en
scrollables). analyze 0 · test 149/149 · build web OK.

## 3) Errores / crashes / botones muertos / placeholders
- ✅ **Carga limpia:** `jezici.vercel.app` → HTTP 200, **0 errores de consola**, **0 assets 404** (verificado en
  navegador). index/legal/app todos 200.
- ✅ **Sin botones muertos** en el flujo público. Entradas sociales ocultas (`SizedBox.shrink`) si no hay acceso
  → un usuario nuevo nunca ve una tarjeta social muerta. "Ver anuncio" deshabilitado + etiqueta "Pronto" (no
  botón muerto engañoso).
- ✅ **Sin texto de relleno visible** (0 TODO/lorem/placeholder en `Text()`). `PlaceholderScreen` ("Próximamente")
  es **dead code** (nunca instanciado). `web/` limpio.
- **[P1] Dev-tool "Probar a Jezi" (MatixTestButtons)** visible a TODOS sin gate (tab Notificaciones + Ajustes→
  Avanzado). Dispara notificaciones de prueba → parece interno. Recomendado: ocultar tras `isAdminProvider`/
  `kDebugMode` (como ya se hace con "Ver métricas"). (`notification_center_screen.dart:44-66`, `settings_screen.dart:336`)
- ⚠️ `catch(_){}` abundan pero **todos degradan con UI/fallback** (reintento, snackbar). El único con consecuencia
  real es el consentimiento legal (P1 §1).

## 4) SEGURIDAD para público real ✅ (lo más importante — VERIFICADO con cliente real)
- ✅ **0 tablas sin RLS.** Las 8 con RLS-sin-policy (admins, ligas, snapshots, user_division, vocab_images,
  notification_templates) son del patrón "solo por RPC SECURITY DEFINER" (deny-por-defecto). Correcto.
- ✅ **Tablas sociales (mig 146-148) con RLS + policies self/member-scoped:** connections/coop_challenges SELECT
  solo miembros; messages SELECT solo conexión aceptada y **no bloqueada**; social_profiles gateada 18+ y sin
  bloqueo; corrections/blocks/mutes/moderation/reports RLS ON. Escritura solo por RPC.
- ✅ **Aislamiento entre usuarios AIRTIGHT (cliente real):** el usuario B ve **0 filas** del usuario A en
  `users, user_stats, daily_goals, user_skill_levels, user_plans, certificates, notifications, messages,
  connections`. Ningún dato de un usuario es visible a otro.
- ✅ **RPCs admin gateados (cliente real):** un usuario normal es **RECHAZADO (400/404)** de `get_metrics /
  get_feedback / get_reports / get_engagement / mod_apply`; `am_i_admin=false`. La UI de métricas además se
  oculta a no-admin.
- ✅ **Conversar 18+ / moderación intactos:** apertura verificada (adulto sin allowlist → acceso; menor
  excluido); bloqueo corta RLS en ambas direcciones; rate-limit; filtro de contacto (tel/email/URL/@→⟨•⟩);
  notas de voz con RLS de Storage por conexión (intruso denegado). (verify_conversar_ola1.py 34 checks VERDE)
- ✅ **Grading server-side:** `correct_answer` revocado (42501); el cliente nunca recibe la respuesta.
- **[P2 cosmético]** `users` tiene grants directos de INSERT/UPDATE/DELETE a `anon`/`authenticated`, pero la RLS
  los niega (sin policy de INSERT/DELETE = deny-por-defecto; UPDATE solo `auth.uid()=id`). Inofensivo pero feo;
  conviene revocar los grants directos.

## 5) i18n (¿español colado en pt/en?)
**Veredicto: la mayoría del chrome está bien localizado, PERO un grupo de pantallas quedó 100% en español.**
- **[P0] Recorrido normal, en español fijo (no cambian a pt/en):** **Mi Plan** (`mi_plan_screen.dart`),
  **Cuaderno** (`notebook_screen.dart`), **Examen de nivel** intro/player (`level_exam_*`), **Notificaciones**
  (`notification_center_screen.dart`).
- **[P1] Secundarias/diálogos en español:** Referencia, Inmersión, Story reader, Simulacros, diálogos de Ajustes
  (borrar cuenta / cerrar sesión), copys de notificaciones Matix (`matix_service.dart`, `coach_styles.dart`).
- **[P2]** Métricas (español, pero **admin-gated** → no lo ve el público). Snackbars de error puntuales.
- ✅ Los "próximamente/coming soon" (conversar en vivo, pagos, ejercicios stub) SÍ están en las 3 traducciones.
- **Nota:** si el lanzamiento inicial es a público **hispanohablante** (la app arranca en español), esto NO
  bloquea; pero para pt/en son P0.

## 6) Contenido (6 cursos)
**Veredicto: ✅ sólido.** Los **6 cursos activos** (en/pt/fr/it/de/nl), **30 unidades** cada uno, niveles
**A1–C1**. U1 con 5-6 lecciones + 30-50 ítems. Certificación **A1–B2** en los 6 (C1 = techo honesto, sin
examen de nivel = Fase 2, documentado). Sin huecos visibles al usuario en el arranque.

## 7) Honestidad (¿promete lo que no hace?)
**Veredicto: ✅ notablemente honesto.** Ninguna feature engaña sin avisar:
- Premium/pagos: CTA "PRÓXIMAMENTE", no cobra (snackbar honesto), nota "Gratis: todo A1".
- Conversar en vivo: banner "próximamente" (Ola 3), captura de interés reporta el fallo real (no falso "gracias").
- Ads en SinVidas: botón deshabilitado + "Pronto"; recarga con oro cobra de verdad.
- **[P2] Certificado:** botón "Compartir" (icono share) **solo copia** folio+código al portapapeles (snackbar lo
  aclara) — mismatch menor icono/acción. `certVerifyNote` dice "tu código verifica la autenticidad" + sello
  "VERIFICADO" pero **no existe URL pública de verificación** (Fase 2) → leve sobrepromesa. Ajustar el copy.

## 8) Lo que Gian debe hacer FUERA del código (cuentas/dashboards)
- **[P0] Google OAuth** — el botón "Continuar con Google" NO funciona hasta configurar: Google Cloud (OAuth
  consent + Web client ID/secret + publicar la app) y Supabase (Providers→Google + URL config). Pasos exactos
  en CLAUDE.md §"Frente 3". **El registro por email funciona sin esto.**
- **[P1] "Confirm email" en Supabase** — con ON hay fricción (revisa tu correo) **y** se pierde el consentimiento
  legal (§1). Recomendado **OFF** para beta (alta inmediata, 0 SMTP).
- **[P1] Sentry** — sin DSN → monitoreo de errores es NO-OP. Para público conviene activarlo (pegar DSN como
  `--dart-define` literal en el Build Command del dashboard de Vercel; pasos en CLAUDE.md). Sin él, no te enteras
  de crashes reales de usuarios.
- **[P2] Cron de ligas** — el rollover es lazy-on-read (se cierra al abrir Ligas). En beta (<13 jugadores) no hay
  movimiento por diseño; automatizar (pg_cron/edge) cuando crezca.
- **[P2] Sello JZ_BUILD** — muestra `dev` en Ajustes (no se puede inyectar en `vercel.json`; requiere el Build
  Command del dashboard). Cosmético.

---

## VEREDICTO HONESTO
**¿Se puede abrir al público HOY?** — **Sí, a una audiencia hispanohablante con la app en español**, con
confianza en lo que más importa al recibir desconocidos: **la seguridad está sólida y verificada con cliente
real** (RLS airtight, aislamiento total entre usuarios, admin gateado, Conversar 18+/moderación intactos),
el flujo de usuario nuevo funciona sin dead-ends, la app carga sin errores, el contenido de los 6 cursos
arranca bien, es responsive, y es honesto (no engaña con features falsas).

**Antes de abrir (orden recomendado):**
1. **Configura Google OAuth** o confirma que el registro por **email con confirm-OFF** es tu vía de alta (P0 de cuenta).
2. **Oculta el dev-tool "Probar a Jezi"** — es lo único que se ve "sin terminar" para un público (P1, rápido).
3. **Arregla la doble pregunta de edad** en el onboarding (fricción en el momento clave) (P1).
4. **Persiste el consentimiento legal** en el camino confirm-email, o pon confirm-email OFF (P1, cumplimiento).
5. **Activa Sentry** para ver crashes reales (P1 de cuenta).

**Antes de un lanzamiento a mercados pt/en:** traducir las 4 pantallas P0 de i18n (Mi Plan, Cuaderno, Examen
de nivel, Notificaciones) + las P1. Con la app en español, esto no bloquea.

Pulido posterior (P2): copy del certificado (share=copiar, verificación), revocar grants directos en `users`,
cron de ligas, sello JZ_BUILD.
