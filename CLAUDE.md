# CLAUDE.md — Jezici (estado vivo)

> Contexto de arranque para cualquier sesión. **No** es copia de los 21 `.md` de
> diseño (eso es la carpeta raíz `Jezici_*.md` + `docs/`). Aquí va el ESTADO REAL,
> qué está verde, qué falta y cómo verificar. Mantener corto y al día.
> Última actualización: **2026-06-25**.

## Qué es
App de aprendizaje de idiomas (estilo Duolingo). **Flutter (web PWA)** + **Supabase**
(Postgres + RLS + RPCs SECURITY DEFINER) + **Vercel** (deploy del web). Repo
`github.com/GianPierooo/Jezici`, deploy `jezici.vercel.app`.
- 2 cursos: **es→en** (A1–B2) y **es→pt** (A1–B1). Curso activo por usuario.
- Loop: lección → ejercicios (9 tipos) → grading **server-side** → XP/oro/vidas →
  checkpoints (≥80%) → exámenes de nivel + certificados. Práctica/SRS, logros, ligas
  semanales, racha, Matix (notificaciones), onboarding con placement.
- **Grading 100% server-side** (`grade_item`, mig 055): el cliente nunca recibe la
  respuesta antes de responder. `correct_answer` revocado (lectura directa → `42501`).

## Stack / mecánica clave
- **Contenido es DB-driven**: los seeds/fixes son migraciones → quedan LIVE al aplicar,
  sin deploy de la app. Audio en Supabase Storage (`audio/items/<id>.mp3`), independiente de Vercel.
- **Migraciones**: `tools/content/apply_sql.py <archivo.sql>` (Management API, registra en
  `schema_migrations`). Secretos desde `../../.env` (gitignored) — **nunca** hardcodear
  `service_role`/`sbp_` (push protection de GitHub rechaza).
- **Deploy**: push a `main` → Vercel reconstruye (clona Flutter, `flutter build web`).
  Config en `vercel.json` (dart-defines SUPABASE_URL/ANON_KEY + JZ_BUILD=commit sha).

## Deploy de Vercel — RESUELTO ✅ (2026-06-23, fix `68266d3`)
- **El "bloqueo" NO era billing: era una regresión de `vercel.json`.** El commit
  `25f49c9` (19-jun) añadió `--dart-define=JZ_BUILD=$VERCEL_GIT_COMMIT_SHA` al
  `buildCommand`. Desde ahí TODOS los deploys daban **ERROR instantáneo pre-build, sin
  logs** (`buildingAt==ready`). **Confirmado por aislamiento:** revertir el
  `buildCommand` a la config **byte-idéntica a 7e26824** (sin ese `--dart-define`) →
  deploy **READY en ~152 s**. Cualquier variante con el flag JZ_BUILD (incluida
  `$(git rev-parse …)`) era rechazada pre-build → **no reintroducir el sello en el
  buildCommand**. Producción de nuevo LIVE con TODO el código nuevo (audio + seguridad).
- **Sello `JZ_BUILD` — lado-app LISTO, inyección BLOQUEADA en vercel.json (sigue `dev`).**
  ⚠️ **Re-confirmado 2026-06-24:** **CUALQUIER** edición del `buildCommand` de vercel.json (incluso
  añadir `&& bash ../scripts/stamp_build.sh`, SIN `$`) → deploy **ERROR instantáneo pre-build, 0 logs**
  (commit 0389b1a). El buildCommand debe quedar **byte-idéntico** al string vivo. No basta con evitar
  `$VAR`/`$()`: NO TOCAR el buildCommand, punto.
  - **Lo que SÍ está hecho y es CI-verde (commit 0389b1a):** `core/app_info.dart` `appBuild()` lee
    `window.JZ_BUILD` en runtime (`app_info_stamp_web.dart`, js_interop; stub `_io`), lo muestra en
    el pie de Ajustes y Sentry lo usa de `release`. `scripts/stamp_build.sh` inyecta
    `<script>window.JZ_BUILD="<sha7>"</script>` en `build/web/index.html` (idempotente; sin SHA cae a
    `dev`). index.html va no-store (sw v4) → reflejaría el bundle real. Falla con gracia: sin inyector,
    `appBuild()`='dev' (sin regresión).
  - **Para ACTIVARLO (única vía deploy-safe, requiere a Gian):** añadir el paso post-build en el
    **Build Command del DASHBOARD de Vercel** (Project Settings → Build & Development), NO en vercel.json:
    `… --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY && bash ../scripts/stamp_build.sh`. Si el
    dashboard también lo rechaza, el sello queda diferido (limitación de plataforma de este proyecto).
- Mecánica normal restaurada: push a `main` → Vercel reconstruye → deploy. Migraciones
  (Supabase) siguen teniendo efecto YA, independientes del deploy.
- **2 bugs de Android PWA arreglados (2026-06-24):** (1) **pantalla negra al volver de
  background** — no había manejo de resume; fix en `app/web/index.html` (visibilitychange/
  pageshow → `resize` sintético + webglcontextlost/restored), deploy-safe, NO toca buildCommand.
  (2) **checkpoint "se corta"** — safe-area inferior faltante; `MediaQuery.paddingOf().bottom` en
  checkpoint_intro/result + certificate. Verificación manual del dueño en FINDINGS.md.
- **Smoke post-deploy 2026-06-23 (prod `b34b568`) ✅ TODO VERDE** (cliente real, sin
  service_role): loop core (`correct_answer` 403/sin col, `grade_item` OK), seguridad
  mig 058 (ligas 403, gate admin, export 24 secc.), ligas/leaderboards mig 059 (32
  combinaciones sin UUID_LEAK, paginación, rollover idempotente), **audio 312/312**,
  PWA `sw v4`+no-store+aviso de update (sello `JZ_BUILD`=`dev`, conocido). Suites:
  analyze 0 · test 42/42 · verify_chain es→en · verify_pt_chain · e2e_audit PASS.
  Detalle + **checklist manual para Gian (iPhone/Android)** en FINDINGS.md.

## Estado por área
| Área | Estado |
|---|---|
| **Test de ubicación + arranque** | ✅ **preciso y live (server-driven, mig 075/076/077).** Antes: test 100% cliente con 20 ítems hardcoded en Dart + nivel = **MEDIA** de las preguntas (subestimaba → un B2 salía A1/B1) **y** `create_plan` **ignoraba** el nivel (siempre Unidad 1). Ahora: **`placement_next`** (RPC stateless, **calificado en servidor** con `jz_grade`, `correct_answer` 42501) con selección **escalera 1-up/1-down** + estimador **TECHO** (ubica en el nivel más alto manejado consistentemente) + per-skill reading/writing. Banco real **48 ítems A1→C1** (5+5/nivel, validados adversarialmente), tag `placement` (excluido de pools). **Puente**: `create_plan` mapea `current_level`→**unidad de entrada** (A1=1·A2=7·B1=13·B2=19·C1=25), marca lo inferior `completed` (accesible, sin XP), entrada `available`. Avance del mapa es por cadena → seguro (examen/cert siguen gateados por dominio). **Verificado cliente real:** personas A1/A2/B1/B2/C1 → su nivel EXACTO (B2 incluso con hint malo); B2→arranca en U19, A1→U1. Cliente = **relay** (sin banco ni estimador local). Pendiente: listening/speaking en placement (audio, diferido), banco es→pt. |
| Loop lección + grading server-side | ✅ verde y live. **Grading apóstrofes/contracciones (mig 067):** `jz_normalize` equipara I'm↔I am, don't↔do not, '↔'↔'' y limpió 15 ítems con `''` corrupto del seed. **word_bank/reorder no revelan la respuesta (mig 068, 20 ítems):** enunciado en español. **Typo-tolerance "casi correcto" (mig 073):** `grade_item` perdona typo menor (distancia 1: inserción/borrado, o sustitución SOLO en multi-palabra) y artículo a/an/the faltante/sobrante → `correct=true` + **`near=true`** (no resta vida, muestra "La forma correcta es…"). Guard de homógrafos: live/life, house/horse, cat/cut, this/these NUNCA se perdonan. `jz_grade = jz_grade_exact OR jz_near_match` (loop, summary y examen coherentes). Espejo cliente en `grader.dart` (`nearMatch`) + tests (`grader_typo_tolerance_test.dart`, 17). **Repaso de errores (mig 074 + `ErrorReviewScreen`):** al terminar, si hubo fallos → pantalla "Repasa lo que fallaste" (cada errado + respuesta correcta + porqué) ANTES de la recompensa; "Practicar los fallados" opcional. Los fallados entran al SRS con prioridad (`srs_prioritize_failed` → `user_vocab_srs` due=now). **TTS de tile (Web Speech):** tocar una ficha en word_bank/reorder pronuncia la palabra (cero archivos, interrumpible, degradación con gracia; disparado por TAP → sin desbloqueo iOS). `correct_answer` sigue revocado (42501). |
| Dinamismo/UX (loop) | ✅ 1ª tanda LIVE (deploy-pending): recompensa con contadores+entrada escalonada, feedback ✅/❌ animado, transiciones `jzRoute`, skeletons en Ligas. Pendiente: tokens de espaciado, mascota en más pantallas, radar animado. Ver UX_AUDIT.md |
| Capa "enseña" (tips/cuaderno/referencia/**inmersión**) | ✅ tip post-lección **relevante al tema real de la lección** (mig 069: `content_tips.topic` + match contra los tags de la lección; ya no sale el tip de EDAD en una lección de PAÍSES) + anti-repetición (no visto > menos reciente) + personalización por skill flojo + cuaderno + **Referencia/Repaso** (mig 060) + **Inmersión/Historias** (mig 065/066: 6 historias es→en A1/A2, audio 46/46). 72 tips **solo es→en** (66 con topic, 6 generales). Pendiente: historias B1/B2 y es→pt, tips para **es→pt**, topics para B1/B2 (hoy caen a unidad/general). |
| Contenido es→en A1–B2, **es→pt A1–B1** | ✅ sembrado y live (pt B1 = mig 053, 192 ítems + 60 checkpoints frescos; cadena A1→B1 + certs verificada). Pendiente: es→pt B2 |
| **Audio** (listening/speaking TTS) | ✅ es→en + es→pt A1/A2 (312) + **es→pt B1 (68)** = 380 + **rebalanceo L/S es→en A1/A2 (96, mig 078/079)** en Storage = **476/476** + degradación/unlock iOS LIVE. Ver FINDINGS.md §2 |
| **Balance de 4 habilidades (L/S)** | ✅ **es→en A1–C1 rebalanceado (mig 078–082, live).** Audit EFICACIA halló sesgo **~3:1** (R/W vs L/S). Subido con criterio (NO 1:1): **listening ~65% de R/W**, **speaking ~50%** (proxy read-aloud, participación, no evalúa fluidez). **A1/A2** (mig 078/079): +5L/+3S por unidad (96 ítems). **B1/B2/C1** (mig 080/081/082): +4L/+2S por unidad → resultante B1 L/R=62% S/R=50%, B2 61%/49%, C1 69%/51% + **34 huecos** de cobertura de alto impacto rellenados (auditoría confirmó cobertura gramatical SÓLIDA en los 3; sin huecos estructurales). **+204 ítems** L/S totales (todos con audio TTS regenerable, `payload.say`/`text` guardado), autorados por panel IA + validación adversarial por unidad, cableados a lecciones 1–4 + tag `unidadN` (pool del examen → menos sesgo R/W). **Verificado cliente real** por nivel: L/S resueltos suben su dominio (listening por precisión, speaking por participación); verify_chain A1→B2 PASS. **Techo C1 honesto:** receptivas (R/L/vocab/gram) sí a C1; producción libre (W/S) requiere Fase 2 → sin cert C1 por diseño. Pendiente: es→pt. |
| **Seguridad** (4 hallazgos) | ✅ **cerrados** en DB (mig 058) + botón export en Ajustes **LIVE** (deploy 68266d3). Ver abajo |
| Ligas + Leaderboards | ✅ rollover real (mig 059): cierre semanal idempotente/lazy + ascensos (top 7)/descensos (fondo 5) Bronce↔Diamante + snapshots. `get_leaderboard` (XP/Racha/Lecciones/Certificados × Semanal/Mensual/Anual/Histórico × Global/División, SIN user_id). UI con segmentos (Mi liga / Tablas) **LIVE** (deploy-pending hasta push). Falta: **cron** que dispare el cierre (hoy es lazy-on-read; ver abajo) |
| **C1 es→en** | ✅ **sembrado y live** (mig 063): 6 unidades (25–30), **252 ítems** (192 lección + 60 checkpoint fresco), 4 habilidades, audio **67/67**. **Sin examen/cert C1** por diseño (techo determinista — writing/speaking a C1 no son evaluables sin IA; mig 064 tope el examen en B2 + blinda C1). Progresión intra-C1 por checkpoints (≥80%). Placement C1 ahora con banco real (8 ítems) + arranque en U25 (mig 075/076/077). Ver `docs/LEVELS_C1_DESIGN.md` y fila **Test de ubicación** |
| C2 | ❌ documentado, no sembrado (otra pasada) |
| Conversar / Simulacros | ⏸️ pantallas existen, **ocultas** (decisión GA6) |

### Ligas — automatización del cierre (pendiente del dueño)
El rollover (`jz_close_weeks()`) es **idempotente + lazy**: se ejecuta al leer
(`get_league`/`get_leaderboard`), así que las semanas vencidas se cierran solas
cuando alguien abre Ligas — no se pierde nada aunque no haya cron. Para garantizar
el cierre puntual (lunes 00:00 UTC) aunque nadie entre, automatizar con UNA opción:
**(a)** `pg_cron` (Supabase Pro): `select cron.schedule('jz-rollover','5 0 * * 1','select jz_close_weeks();')`;
**(b)** Edge Function + cron externo (GitHub Actions/cron-job.org) que llame a un RPC.
Movimiento real solo en ligas ≥13 (top 7 suben / fondo 5 bajan); en beta (<13) nadie
se mueve, por diseño.

## Seguridad — 4 hallazgos (todos CERRADOS en DB, mig 058 · 2026-06-23)
1. ✅ `league_members`/`leagues` SELECT directo **revocado** (daba UUIDs de auth ajenos).
   El ranking se sirve SOLO por `get_league` (DEFINER, sin user_id). `get_metrics` etc. siguen.
2. ✅ Gate de admin en `get_metrics`/`get_engagement`/`get_onboarding_funnel`: tabla `admins`
   + `jz_is_admin()`. Dueño (Gian, `7b4a8e40-…`) sembrado. No-admin → `admin only`.
3. ✅ `log_event`: allowlist de 8 eventos (`app_open, client_error, conversar_attempt,
   lesson_complete, mission_started, onboarding_completed, onboarding_step, screen_view`),
   props truncadas (>2KB → `{_truncated}`), rate-limit 120/usuario/min. Evento desconocido = descarte silencioso.
4. ✅ `export_my_data()` (GDPR): RPC DEFINER acotada a `auth.uid()` (24 secciones). Botón
   "Exportar mis datos" en Ajustes (**LIVE** desde deploy 68266d3).
- Previo: `correct_answer` ya estaba cerrado (mig 055), `jz_*` helpers revocados (mig 049).
- Admin allowlist NO se gestiona por SQL roles → es la tabla `admins` (agregar/quitar user_id).

## Legal in-app (Privacidad + Términos) — mig 062 · ⚠️ BORRADOR (falta abogado)
- **Contenido:** `features/legal/legal_screen.dart` (Privacidad + Términos en español, ya
  redactados) con **banner de beta** (borrador + certificado interno no oficial + pagos
  inactivos) y la **versión** `kLegalVersion = '2026-06-draft'`. Alcanzable desde **Ajustes**
  (ambos links) **y el registro** (links + checkbox).
- **Aceptación (mig 062):** en "Crear cuenta", checkbox **requerido** "He leído y acepto
  Términos + Privacidad" (botón deshabilitado sin marcar). Tras el alta → `accept_legal(version)`
  persiste `legal_consents(user_id, doc_version, accepted_at)` (RLS self; escritura solo por RPC).
  `my_legal_version()` devuelve la última versión aceptada (base para re-consentir).
- **Versionar/re-consentir:** subir `kLegalVersion` cuando el texto cambie (revisión de abogado).
  La detección está lista (comparar `my_legal_version()` vs `kLegalVersion`); el **gate de
  re-consentimiento para usuarios existentes está DIFERIDO** (se añade al llegar la versión revisada).
- ⚠️ **Es un BORRADOR**: NO está revisado por abogado. No afirmar acreditación oficial.

## Analítica de la beta (KPIs sin SQL) — mig 061
- **Cómo lo ve Gian:** Ajustes → "Ver métricas (interno)" (admin-only; Gian ya en `admins`).
  Pantalla `MetricsScreen` lee `get_metrics`/`get_engagement`/`get_onboarding_funnel` (todas
  admin-gated). KPIs: usuarios, DAU/WAU/MAU + **stickiness DAU/MAU (CURR)**, retención
  D1/D7/D30, lecciones/día, % aprueba checkpoint/examen, % certifica, **embudo de onboarding**
  (paso a paso + dónde abandonan) y **embudo de lección 30d** (iniciadas/completadas/
  abandonadas/sin-vidas + tasa de finalización).
- **Eventos (allowlist `log_event`, mig 058+061):** `app_open, client_error, conversar_attempt,
  lesson_complete, mission_started, onboarding_completed, onboarding_step, screen_view` +
  **`lesson_start, lesson_quit, no_hearts`** (mig 061). ⚠️ Evento fuera del allowlist = descarte
  silencioso → si agregas uno, AGRÉGALO al allowlist o nunca entra. Sin PII (solo conteos + ids opacos).
- Nota: `lesson_funnel.completion_rate` solo es fiable para sesiones DESPUÉS de este deploy
  (antes había `lesson_complete` sin `lesson_start`). Diferido: retención por cohorte semanal
  visual, abandono por ítem específico, analítica de práctica.

## Monitoreo de errores (Sentry) — cableado, falta el DSN
- **Client-side LIVE-ready** (`core/monitoring/sentry_config.dart`): `runWithSentry`
  envuelve `runApp` (captura Flutter + nativo iOS/Android + zona; en web errores JS de la
  app). Sin DSN → **NO-OP** (la app arranca igual, sin coste). Config beta: env `beta`,
  release `jezici@<JZ_BUILD>` (fallback `dev`), `tracesSampleRate 0.1`, `sendDefaultPii=false`
  (GDPR), `beforeSend` filtra ruido (timeouts/cancelaciones), uid OPACO sin PII. Convive con
  `installCrashReporting` (analytics_events), sinks distintos.
- **Cómo lo activa Gian (el DSN NO es secreto):** pega el DSN como `--dart-define` con
  **VALOR LITERAL** (NO `$VAR` ni `$(...)` → eso rompe el deploy pre-build).
  - **Prod (Vercel):** en `vercel.json`, al final del `buildCommand`, añade literal:
    `... --dart-define=SENTRY_DSN=https://<key>@<org>.ingest.sentry.io/<project>` (y opcional
    `--dart-define=SENTRY_ENV=production`). Push → deploy. **Tras el push, confirmar deploy READY** (no instant-ERROR).
  - **Local:** `flutter run --dart-define=SENTRY_DSN=https://…`
- **Prueba de captura (con DSN):** temporal `Sentry.captureMessage('jezici test')` o un throw,
  ver que llega al dashboard, y quitarlo.
- **Diferido:** source maps/símbolos (stack traces legibles en web/nativo) y Sentry server-side
  (Edge Functions) — fuera de alcance de esta tanda.

## CI (GitHub Actions) — VERDE ✅ desde 2026-06-24 (run #57, commit 151062f)
- Pipeline completo en verde por primera vez: `Prepare .env` → analyze → **test 43/43** →
  **build web** (antes test/build quedaban *skipped* porque analyze abortaba). Deploy de Vercel
  de ese commit = **READY** (prod). Las rojas históricas #47–#56 son inmutables (corrieron con el
  workflow roto; re-correrlas reusaría ese workflow). Detalle del fix abajo.

## CI (GitHub Actions) = FUENTE DE VERDAD — no el local
- **El verde del CI manda, no `flutter analyze` local.** Workflow `.github/workflows/ci.yml`
  (job `flutter`: analyze → test → build web, Flutter **pinneado 3.44.3**). Verde real =
  `gh run list`/API muestran SUCCESS. Un verde local que el CI no refleje **no cuenta**.
- **Por qué el local daba falso verde (lección 2026-06-24, runs #47–#56 todas rojas):** `.env`
  es un asset DECLARADO en `pubspec.yaml` pero **gitignored**. En local existe → analyze pasa.
  En CI no existe → `flutter analyze` falla con `asset_does_not_exist` y aborta el job (test/build
  quedan *skipped*). El step de build creaba `.env` con `touch`, pero **corre DESPUÉS de analyze**.
  Fix de raíz: step **`Prepare .env`** (touch) **antes** de analyze + versión pinneada. El `.env`
  vacío basta (Supabase usa fallback público embebido en `supabase_config.dart`).
- **Reproducir el CI en local:** `mv app/.env app/.env.bak && cd app && flutter analyze` → debe dar
  el mismo `asset_does_not_exist`. Restaurar después. (Antes de declarar "verde", correr el comando
  EXACTO del workflow, no asumir.)

## Comandos de verificación
```bash
# Toolchain (desde app/) — el CI corre estos MISMOS con .env presente (touch) y Flutter 3.44.3
flutter analyze              # esperado: No issues found
flutter test                 # esperado: All tests passed (43/43)
flutter build web --release  # esperado: Built build/web (wasm dry-run warning de ua_client_hints es OK)

# Audio: cobertura real en Storage (HEAD a payload.audio_url) — es→en/pt = 584/584 (incl. 204 L/S mig 078–082)
#   query content_items_public?type=eq.listening|speaking_read_aloud, HEAD cada audio_url

# Cliente REAL (NUNCA service_role para chequeos de seguridad):
#   anon key + JWT autenticado real (signup vía /auth/v1/signup, limpiar con delete_account).
#   Ejemplos verificados (mig 058): league_members directo → 403; get_league → 200 sin user_id;
#   get_metrics no-admin → "admin only"; export_my_data → 200; log_event bogus → 0 filas.

# DB (introspección/seed admin): tools/content/apply_sql.py vía Management API (.env).
```
- **Verificación de cliente desplegado**: `git show 7e26824:app/lib/...` para ver qué consulta
  el build que usan los usuarios HOY (no asumir que `main` == producción).

## Reportes de diagnóstico (raíz)
- **EFICACIA_CONTENIDO.md** (2026-06-24) — auditoría de EFICACIA de currículo por nivel (¿lleva a CEFR-X?).
  Veredicto es→en A1/A2: "sí con reservas"; huecos de cobertura rellenados (mig 071, 29 ítems sin audio:
  presente continuo, 3ª persona -s, plurales, these/those, conectores, present perfect 'yet', adverbios -ly).
  **Hallazgo sistémico:** L/S subservidos ~3:1 vs R/W en TODOS los niveles + techo determinista de producción
  (speaking proxy). Destapó y arregló una **regresión P0** (mig 072): exámenes de pt rotos por mig 064 (mono-curso).
  **L/S es→en A1–C1 YA equilibrado** (mig 078–082: +204 ítems L/S + 34 huecos + audio; ver fila "Balance de 4
  habilidades"). **Auditoría de eficacia es→en B1/B2/C1 HECHA** (cobertura sólida; C1 con techo honesto de
  producción). Pendiente: eficacia + L/S de **es→pt**.
- **CONTENT_QA.md** (2026-06-24) — auditoría pedagógica profesor-IA de **es→en A1/A2 (384 ítems)**:
  **0 P0**, clase sistémica = tolerancia insuficiente (corregida en mig 070, +20 ítems con variantes
  naturales en `accepted` + 2 pulidos). Rechazos/diferidos documentados. Pendiente: B1/B2/C1 + es→pt.
- **FINDINGS.md** — auditoría funcional/seguridad completa (audio, progresión, ligas, seguridad)
  + smoke post-deploy + checklist manual para Gian.
- **PERF_AUDIT.md** (2026-06-23, solo lectura) — rendimiento priorizado: renderer CanvasKit,
  caché de contenido estático, invalidaciones en cascada, rebuilds/cómputo en `build()`, jank del
  mapa, skeletons. Con método de perfilado en vivo (DevTools).
- **UX_AUDIT.md** (2026-06-23, solo lectura) — UX/estética/**dinamismo** por pantalla: deriva del
  sistema de diseño (212 colores hardcodeados, AppSpacing/Radius casi sin usar), motion faltante
  (feedback ✅/❌, háptica, transiciones, contadores de recompensa), + top-10 cambios por impacto.

## Memoria del proyecto
`~/.claude/projects/.../memory/` (cargada cada sesión vía MEMORY.md). Incluye: deploy mechanics,
método de verificación, pipeline de contenido, estado de producción, multi-curso, y la
auditoría 2026-06-22 (`jezici-audit-2026-06-22`).
```
