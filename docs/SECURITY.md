# Jezici — Auditoría de seguridad / privacidad (pre-lanzamiento)

> Auditoría adversarial multi-agente sobre 44 migraciones + cliente Flutter.
> Estado: **fortalezas confirmadas**, 1 bloqueante CRÍTICO de integridad por
> resolver antes del lanzamiento público, varios medios documentados.

## Fortalezas confirmadas ✅
- **Scoring/economía 100% server-side** (XP/oro/aprobado/cert en RPC SECURITY DEFINER).
- **RLS en TODAS las tablas de usuario** con políticas self-scoping a `auth.uid()`.
- **Toda RPC pública** verifica `auth.uid()` y usa la identidad del servidor — nunca
  confía en un `user_id` del cliente.
- **Ningún `grant ... to anon`** en RPCs; **ningún secreto/service_role en el cliente**
  ni en git (solo la anon key pública por diseño; `.env` gitignored).
- **`submit_level_exam` re-valida la compuerta** de desbloqueo al enviar (no se salta
  el dominio con un atajo REST).
- **`delete_account()`** borra solo al llamante (`auth.uid()`) con cascada. Conforme.

## Hallazgos y estado

### 🔴 CRÍTICO — Clave de respuestas legible por el cliente (POR RESOLVER)
`content_items.correct_answer` (jsonb) es legible vía PostgREST con la anon key
(RLS `using(true)` en `content_read_content_items`, mig 005). Como el cliente conoce
los `item_id`, puede leer **todas** las respuestas, responder perfecto y
**farmear certificados, XP, oro y posición de liga**. El examen de nivel ya NO
devuelve `correct_answer` en su payload (`start_level_exam`), pero la fuga es el
**acceso directo a la tabla**.
- **Impacto:** integridad de certificados (Fase 1: explícitamente NO oficiales, lo
  que mitiga el daño reputacional) y **equidad de ligas reales** (vector más tangible).
- **Por qué no se arregló en esta sesión:** la app califica **client-side** en
  lección/práctica/checkpoint (`lib/features/lesson/grading/grader.dart` + widgets de
  ejercicio usan `correctAnswer` para el feedback inmediato ✓/✗). Revocar la columna
  rompe el feedback inmediato del loop principal. Hacerlo bien = mover la calificación
  por ítem al servidor — refactor del loop central, demasiado riesgoso de apurar en
  vivo con usuarios reales.
- **Plan de remediación (siguiente misión, dedicada):**
  1. RPC `grade_items(p_answers jsonb) returns jsonb` (SECURITY DEFINER) que devuelve
     `{item_id: {correct: bool, expected?: ...}}` — el `expected` solo se revela
     **después** de responder (feedback), nunca antes.
  2. Refactor de `grader.dart` + widgets para calificar vía esa RPC (o usar el
     resultado de `complete_lesson`/`submit_practice`, que ya califican server-side).
  3. **Revocar SELECT de la columna** `correct_answer` a anon/authenticated
     (grant por columnas, como `users`), o servir el contenido por una vista sin la
     columna. `start_*`/`fetch*` dejan de exponerla.
  4. Verificar: el loop de lección/checkpoint/examen sigue jugable; un GET directo a
     `content_items?select=correct_answer` devuelve permiso denegado.

### 🟠 MEDIO — Helpers `jz_*` invocables con `p_uid` ajeno (RESUELTO ✅, mig 049)
Los helpers internos (`jz_register_activity`, `jz_record_item`, `jz_record_mastery`,
`jz_add_league_xp`, `jz_item_reinforce`, …) tenían EXECUTE para authenticated/PUBLIC y
aceptan `p_uid` arbitrario → inyección de XP/actividad/dominio/liga en cuentas ajenas.
**Resuelto:** mig 049 revoca EXECUTE de todos los `jz_*` a authenticated/anon/public.
La app nunca los llama directamente; las RPC públicas los invocan como definer.
Verificado: verify_chain es-en + verify_pt_chain + e2e_audit siguen PASS.

### 🟠 MEDIO — Métricas de negocio expuestas a cualquier usuario (POR RESOLVER)
`get_metrics()` y `get_engagement()` (paneles internos) tienen grant a `authenticated`
sin gate de admin → cualquier cuenta lee agregados de toda la base (usuarios totales,
retención, % certificados, feedback). **Plan:** añadir allowlist de UID admin (o tabla
`admins`) al inicio de ambas, o moverlas a `service_role` + panel interno. Bajo riesgo
inmediato (beta de 3 usuarios), pero cerrar antes del público.

### 🟠 MEDIO — Sin rate limiting en RPCs abusables (POR RESOLVER)
`submit_level_exam` (re-otorga 200 XP/100 oro por subida; combinar con el CRÍTICO =
farm), `submit_practice`/`complete_lesson` (XP topado por llamada pero en bucle escala
ligas/racha), `log_event` (spam de filas / envenenar métricas). **Plan:** ventana de
intentos por usuario (tabla de rate-limit o columna `last_*_at` + `count`); validar
`p_event` contra allowlist y truncar props; no re-otorgar XP/oro si no hay subida real.

### 🟡 BAJO — Sin exportación de datos (GDPR portabilidad)
No existe `export_my_data()`. Para el derecho de portabilidad conviene añadir una RPC
que devuelva el JSON del propio `auth.uid()`. **Plan:** `export_my_data()` SECURITY
DEFINER + botón en Ajustes junto a "Borrar mi cuenta".

### 🟡 BAJO — `league_members` SELECT abierto
Política `using(true)` expone `weekly_xp`/nombre de todos los miembros. Es dato de
leaderboard (por diseño) pero conviene servirlo solo por `get_league` y cerrar el
SELECT de tabla. Post-launch.

## Prioridad antes del público
1. 🔴 **correct_answer** (misión dedicada: grading server-side + revoke de columna).
2. 🟠 gate de admin en `get_metrics`/`get_engagement`.
3. 🟠 rate limiting en `submit_level_exam` / `log_event`.
4. 🟡 `export_my_data()` + cerrar `league_members`.
