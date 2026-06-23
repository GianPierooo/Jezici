# CLAUDE.md — Jezici (estado vivo)

> Contexto de arranque para cualquier sesión. **No** es copia de los 21 `.md` de
> diseño (eso es la carpeta raíz `Jezici_*.md` + `docs/`). Aquí va el ESTADO REAL,
> qué está verde, qué falta y cómo verificar. Mantener corto y al día.
> Última actualización: **2026-06-23**.

## Qué es
App de aprendizaje de idiomas (estilo Duolingo). **Flutter (web PWA)** + **Supabase**
(Postgres + RLS + RPCs SECURITY DEFINER) + **Vercel** (deploy del web). Repo
`github.com/GianPierooo/Jezici`, deploy `jezici.vercel.app`.
- 2 cursos: **es→en** (A1–B2) y **es→pt** (A1–A2). Curso activo por usuario.
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

## ⚠️ Deploy de Vercel
- **El "bloqueo" NO era billing: era una regresión de `vercel.json`.** El commit
  `25f49c9` (19-jun) añadió `--dart-define=JZ_BUILD=$VERCEL_GIT_COMMIT_SHA` al
  `buildCommand`; desde ahí TODOS los deploys daban **ERROR instantáneo pre-build,
  sin logs** (firma de buildCommand rechazado). **Reparado 2026-06-23**: el sello se
  auto-computa con `JZ_SHA=$(git rev-parse --short HEAD || echo dev)` (sin la variable
  de sistema problemática). Build local con el comando EXACTO de Vercel: OK; sello
  `JZ_BUILD` presente en el bundle. **Pendiente:** confirmar que el primer deploy tras
  el fix queda `READY` en Vercel.
- Hasta confirmar READY, **producción seguía fijada en `7e26824` (19-jun)**. Por las
  dudas al tocar DB: toda migración debe ser **compatible con el build live** (verificar
  con `git show 7e26824:<archivo>`). Migraciones (Supabase) tienen efecto YA; el frontend
  nuevo aterriza con el primer deploy exitoso.

## Estado por área
| Área | Estado |
|---|---|
| Loop lección + grading server-side | ✅ verde y live |
| Contenido es→en A1–B2, es→pt A1–A2 | ✅ sembrado y live |
| **Audio** (listening/speaking TTS) | ✅ **312/312** en Storage (live). Código de degradación/unlock iOS **deploy-pending** (commits c4a17af). Ver FINDINGS.md §2 |
| **Seguridad** (4 hallazgos) | ✅ **cerrados** en DB (mig 058, live). Botón export en Ajustes deploy-pending. Ver abajo |
| Ligas | ⚠️ acumulan XP + ranking semanal, pero **sin job de cierre ni ascensos/descensos** (UI los promete). Sin histórico mensual/anual. (prompt aparte) |
| C1/C2 | ❌ documentados, no sembrados (BD llega a B2 en es→en) |
| Conversar / Simulacros | ⏸️ pantallas existen, **ocultas** (decisión GA6) |

## Seguridad — 4 hallazgos (todos CERRADOS en DB, mig 058 · 2026-06-23)
1. ✅ `league_members`/`leagues` SELECT directo **revocado** (daba UUIDs de auth ajenos).
   El ranking se sirve SOLO por `get_league` (DEFINER, sin user_id). `get_metrics` etc. siguen.
2. ✅ Gate de admin en `get_metrics`/`get_engagement`/`get_onboarding_funnel`: tabla `admins`
   + `jz_is_admin()`. Dueño (Gian, `7b4a8e40-…`) sembrado. No-admin → `admin only`.
3. ✅ `log_event`: allowlist de 8 eventos (`app_open, client_error, conversar_attempt,
   lesson_complete, mission_started, onboarding_completed, onboarding_step, screen_view`),
   props truncadas (>2KB → `{_truncated}`), rate-limit 120/usuario/min. Evento desconocido = descarte silencioso.
4. ✅ `export_my_data()` (GDPR): RPC DEFINER acotada a `auth.uid()` (24 secciones). Botón
   "Exportar mis datos" en Ajustes (frontend **deploy-pending**).
- Previo: `correct_answer` ya estaba cerrado (mig 055), `jz_*` helpers revocados (mig 049).
- Admin allowlist NO se gestiona por SQL roles → es la tabla `admins` (agregar/quitar user_id).

## Comandos de verificación
```bash
# Toolchain (desde app/)
flutter analyze              # esperado: No issues found
flutter test                 # esperado: All tests passed (40/40)
flutter build web --release  # esperado: Built build/web (wasm dry-run warning de ua_client_hints es OK)

# Audio: cobertura real en Storage (HEAD a payload.audio_url) — esperado 312/312
#   query content_items_public?type=eq.listening|speaking_read_aloud, HEAD cada audio_url

# Cliente REAL (NUNCA service_role para chequeos de seguridad):
#   anon key + JWT autenticado real (signup vía /auth/v1/signup, limpiar con delete_account).
#   Ejemplos verificados (mig 058): league_members directo → 403; get_league → 200 sin user_id;
#   get_metrics no-admin → "admin only"; export_my_data → 200; log_event bogus → 0 filas.

# DB (introspección/seed admin): tools/content/apply_sql.py vía Management API (.env).
```
- **Verificación de cliente desplegado**: `git show 7e26824:app/lib/...` para ver qué consulta
  el build que usan los usuarios HOY (no asumir que `main` == producción).

## Memoria del proyecto
`~/.claude/projects/.../memory/` (cargada cada sesión vía MEMORY.md). Incluye: deploy mechanics,
método de verificación, pipeline de contenido, estado de producción, multi-curso, y la
auditoría 2026-06-22 (`jezici-audit-2026-06-22`). FINDINGS.md (raíz) = auditoría completa con estado.
```
