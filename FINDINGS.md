# Jezici — Auditoría exhaustiva (solo lectura)

> **Fecha:** 2026-06-22 · **Alcance:** diagnóstico, CERO cambios de código.
> **Método:** lectura de repo + 56 migraciones, ejecución real de toolchain,
> y verificación contra la BD de producción con cliente REST (anon + JWT
> autenticado real, creado y borrado con `delete_account`). **No** se usó
> `service_role` para los chequeos de seguridad.
> **Foco:** (1) audio · (2) progresión · (3) ligas · (4) seguridad.

---

## 0. Veredicto honesto del producto

Jezici es un MVP **sorprendentemente completo y bien construido en su núcleo**:
el loop de lección, la economía (XP/oro/vidas), checkpoints, exámenes de nivel
con certificados, práctica con SRS, logros, ligas, racha, onboarding con
placement, notificaciones Matix, y **dos cursos** (es→en, es→pt). El toolchain
está **verde** (analyze 0 issues, 38 tests pasan, build web OK). La postura de
seguridad del *core* es genuinamente buena: scoring server-side, RLS por
usuario, y el vector crítico `correct_answer` **está cerrado de verdad**
(verificado: `permission denied`).

Pero el producto **no está listo para un público amplio** por dos motivos
materiales y verificados:

1. **El audio está incompleto al 69%.** es→en A1/A2 tienen el 100% del audio;
   **es→en B1, es→en B2 y TODO el curso es→pt (A1+A2) tienen 0 archivos de
   audio** (216 de 312 ítems de listening/speaking apuntan a `.mp3` que
   devuelven HTTP 400). Como *listening ya es un ejercicio calificable*, un
   alumno de B1/B2/pt se topa con preguntas de listening **sin audio**.
2. **Las ligas son una fachada parcial.** Acumulan XP y muestran ranking, pero
   **no existe job de cierre semanal ni ascensos/descensos**: la UI promete
   "los primeros 5 ascienden" y eso **nunca ocurre**.

La seguridad tiene 4 hallazgos abiertos reales pero de impacto acotado (todos
confirmados en vivo). Ninguno es crítico ahora que `correct_answer` está cerrado.

**Listo para:** seguir con beta cerrada de es→en A1–A2.
**No listo para:** promocionar B1/B2, lanzar es→pt, o prometer ligas competitivas.

---

## 1. Estado general — documentado vs construido

### Toolchain (números reales, ejecutados hoy)

| Comando | Resultado |
|---|---|
| `flutter analyze` | **exit 0** — sin issues |
| `flutter test` | **38/38 PASA** ("All tests passed!") — 8 archivos de test |
| `flutter build web --release` | **OK** en 53,5 s (build JS). Aviso: wasm dry-run falla por `ua_client_hints`→`dart:html` (no bloquea el build JS actual) |

Tests existentes: `estimation`, `grader`, `lesson_complete_celebration`,
`lesson_flow`, `speech_match`, `streak_meta`, `text_match`, `widget`. Cubren el
grader y el flujo de lección; **no hay** tests de ligas, checkpoint-gating,
mastery por skill, ni de audio.

### Construido y funcionando
- Loop de lección + 9 tipos de ejercicio (`multiple_choice` 265, `cloze` 133,
  `translation` 122, `listening` 122, `speaking_read_aloud` 122, `match` 107,
  `word_bank` 68, `reorder` 61). **1.228 content_items** en BD.
- Grading server-side (`grade_item`, mig 055) + vista `content_items_public` sin
  `correct_answer` (mig 056).
- Checkpoints con gating ≥80%, exámenes de nivel multinivel + certificados SVG.
- Práctica + SRS, logros, tienda/cofre, racha, ligas semanales, Matix.
- Multi-curso (es→en A1–B2, es→pt A1–A2) con curso activo por usuario.
- Onboarding: placement + test de personalidad + "tu plan".

### Documentado-pero-NO-construido (o parcial)
- **C1/C2:** referidos en `docs/LEVELS_DESIGN*.md`; **no sembrados** (BD solo
  llega a B2 en es→en).
- **Conversar / Simulacros:** pantallas existen pero **ocultas** (decisión GA6,
  ver `jezici-production-state`). `conversation_attempts: 0` en métricas.
- **Ligas — ascensos/descensos + cierre semanal:** prometidos en la UI,
  **sin implementación** (§3).
- **Rankings mensual/anual/histórico:** **ausentes por completo** (§3).
- **`export_my_data()` (GDPR portabilidad):** en el plan de `SECURITY.md`,
  **no existe** (verificado: `PGRST202 function not found`) (§4).

### Construido-pero-poco-documentado
- Blindaje de grading (mig 055/056) y capa "enseña" / tips+cuaderno (mig 057):
  recientes, aún sin doc dedicado más allá del changelog de commits.

---

## 2. AUDIO (máxima prioridad)

### Mapa de superficies

| Superficie | API / motor | Archivo |
|---|---|---|
| **SFX** (correct/wrong/combo/…) | Web Audio API (web) · `audioplayers` (nativo) vía `AudioEngine` | `core/audio/sound_service.dart`, `core/audio/audio_engine_web.dart` |
| **Listening** (reproducción TTS) | `AudioEngine.playUrl` → `fetch` + `decodeAudioData` + `BufferSource` | `features/lesson/exercises/audio_play_button.dart`, `listening_exercise.dart` |
| **Speaking / micrófono (STT)** | `speech_to_text` (nativo) · Web Speech API crudo (web) | `core/speech/speech_recognizer_*.dart`, `features/lesson/exercises/speaking_exercise.dart` |

Decisión de diseño deliberada y **correcta**: en web NO se usan elementos
`<audio>` ni `MediaSession`, precisamente para que iOS Safari **no** muestre el
reproductor "now-playing" en la pantalla de bloqueo (`audio_engine.dart:3-6`,
`_clearMediaSession()` en `audio_engine_web.dart:76-89`). 7 SFX `.wav` reales
bundleados en `assets/sfx/`.

> **ACTUALIZACIÓN 2026-06-22 (misión audio P0+P1) — RESUELTO ✅**
> - **A1 (216 audios faltantes subidos):** se generó y subió el TTS de los 216
>   ítems (es→en B1/B2 + es→pt A1/A2) con `tools/content/gen_audio_missing.py`
>   (mismo pipeline Google translate_tts; `tl=en`/`tl=pt`). **Cobertura
>   96/312 → 312/312 (100%)**, verificado con HEAD (0 faltantes).
> - **A2 (degradación con gracia):** si el audio de un listening no resuelve, el
>   loop lo **salta sin penalización** (no pide respuesta a ciegas, no resta
>   vidas, se omite de `complete_lesson`) y `AudioPlayButton` muestra "Audio no
>   disponible" en vez de colgarse 12 s. Red de seguridad permanente.
> - **Desbloqueo iOS:** `Listener(onPointerDown)` global en `main.dart` (sobre el
>   Navigator) desbloquea el AudioContext en el primer gesto real, en cualquier
>   pantalla. analyze 0 · test 40/40 (+1 de skip) · build web OK.
>
> **DEPLOY DE VERCEL — RESUELTO ✅ (2026-06-23, fix `68266d3`):** NO era billing ni
> bloqueo de cuenta. Era una **regresión de `vercel.json`**: `25f49c9` (19-jun) añadió
> `--dart-define=JZ_BUILD=$VERCEL_GIT_COMMIT_SHA` al `buildCommand` → desde ahí TODOS
> los deploys daban **ERROR instantáneo pre-build, sin logs** (`buildingAt==ready`).
> **Confirmado por aislamiento (vía Vercel API):** revertir el `buildCommand` a la
> config **byte-idéntica a 7e26824** (sin ese flag) → deploy **READY en ~152 s** y
> aliased a `jezici.vercel.app`. Toda variante con el flag JZ_BUILD (incl. mi intento
> con `$(git rev-parse …)`, `1b5b818`) fue rechazada pre-build → **no reintroducir el
> sello en el buildCommand**. **Producción de nuevo LIVE** con TODO el código acumulado
> desde 7e26824 (audio P0/P1 + seguridad mig 058 frontend). Sello `JZ_BUILD` queda en
> `dev` (pendiente; recuperarlo necesita otro método, no `--dart-define` inline).
> El detalle original del hallazgo se conserva abajo.

### Hallazgos

#### 🟢 P0 — Audio de listening/speaking faltante (RESUELTO ✅ — 312/312)
- **Síntoma (original):** en es→en B1/B2 y en todo es→pt, el botón "Escuchar" no
  reproducía nada; el alumno respondía un *listening* (calificable) **sin oír**.
- **Repro (verificado en vivo, pre-fix):** HEAD a las 312 URLs de `payload.audio_url`:

  | Curso | Nivel | Con audio (200) | Sin audio (400) |
  |---|---|---:|---:|
  | es→en (…001) | A1 | 48 | 0 |
  | es→en (…001) | A2 | 48 | 0 |
  | es→en (…001) | **B1** | **0** | **48** |
  | es→en (…001) | **B2** | **0** | **48** |
  | es→pt (…002) | **A1** | **0** | **48** |
  | es→pt (…002) | **A2** | **0** | **72** |

  **Total: 96 reales / 216 faltantes (31% de cobertura).** Los que existen son
  `.mp3` reales (~9–14 KB, HTTP 200); los faltantes dan `400 Bad Request`
  (objeto inexistente en el bucket `audio/items/`).
- **Causa probable:** la generación/subida de TTS a Supabase Storage solo se
  corrió para es→en A1–A2. Los seeds B1 (mig 043), B2 (mig 045) y pt (mig 048,
  052) escribieron `audio_url` apuntando a `…/audio/items/<id>.mp3` pero **los
  archivos nunca se subieron**.
- **Ubicación:** datos en `content_items.payload.audio_url`; pipeline de subida
  en `tools/content/` (fuera del runtime). El cliente solo consume la URL en
  `audio_play_button.dart:39`.
- **Fix aplicado:** (a) `gen_audio_missing.py` regeneró y subió los 216 al bucket
  → **312/312**; (b) degradación con gracia permanente (skip sin penalización +
  `AudioPlayButton` "Audio no disponible") como red de seguridad ante futuros
  faltantes. `AudioEngine.isUrlAvailable` (HEAD en web) detecta el 400.

#### 🟢 P1 — Desbloqueo del AudioContext fuera de gesto (RESUELTO ✅)
- **Síntoma:** en iOS Safari/PWA, el primer SFX (p. ej. el "correcto" tras
  responder) puede salir mudo, y/o el primer listening requiere un segundo tap.
- **Causa probable:** `AudioEngine.instance.unlock()` se llama en
  `lesson_player_screen.dart:56` dentro de **`initState()`**, que corre tras la
  navegación, **no dentro de un gesto de usuario**. iOS exige que
  `AudioContext.resume()` se dispare **síncronamente** desde un gesto; llamarlo
  en `initState` es no-op en iOS. **No existe** un `Listener`/`onPointerDown`
  global en `main.dart` que desbloquee el contexto en el primer toque de la app
  (verificado: 0 coincidencias). Los SFX programáticos (tras un `await` del RPC
  de grading) caen fuera de la ventana del gesto → iOS los suprime hasta que un
  tap real reanude el contexto.
- **Ubicación:** `audio_engine_web.dart:100-107` (`unlock`),
  `sound_service.dart:27-31` (`warmUp` solo se llama al reproducir un SFX),
  `lesson_player_screen.dart:56`.
- **Fix aplicado:** `_AudioUnlockGate` en `main.dart` (vía `MaterialApp.builder`,
  sobre el Navigator → cubre rutas pusheadas) con `Listener(onPointerDown)` de un
  solo disparo que llama `AudioEngine.instance.unlock()` síncronamente en el
  primer gesto real. Se mantiene el `unlock()` de `initState` como refuerzo.

#### 🟢 OK — Listening ya es calificable; SFX sin solapamiento; TTS sin solapar
- `jz_is_stub` fue redefinido (mig 027): listening **dejó de ser stub**, hoy se
  califica como multiple-choice (`listening_exercise.dart`, `grader_test.dart`).
  Solo `speaking_read_aloud`, `dictation`, `guided_writing` siguen siendo stubs.
- `playUrl` corta el TTS previo antes de iniciar otro (`audio_engine_web.dart:
  163-176`) → no se solapan voces. SFX se cachean por buffer (sin recorte mutuo).
- Speaking degrada con gracia ("Ya lo leí ✓") si no hay micrófono/permiso
  (`speaking_exercise.dart:106-121`).

---

## 3. PROGRESIÓN

> Investigado a fondo; varias afirmaciones iniciales fueron **descartadas** al
> contrastarlas con el contenido real y la redefinición de `jz_is_stub`.

### Cómo funciona (verificado)
- **Persistencia** (`complete_lesson`, mig 015 / 040 / 041): escribe en
  `user_lesson_progress` → `status` (`completed`/`golden`), `best_accuracy`,
  `times_completed`, `completed_at`. Precisión = `correctos / calificables`.
- **Desbloqueo de lección:** al **completar** una lección (cualquier accuracy)
  se inserta la siguiente como `available` (mig 015:290-308 / mig 041:429-440).
- **Gating de checkpoint (≥80%):** server-side en `submit_checkpoint`
  (mig 016:130-131, `v_passed := v_graded>0 and v_acc>=0.80`). Solo entonces
  desbloquea la **primera lección de la siguiente unidad** (mig 016:215-227).
  El cliente NO valida el 80% — confía en el servidor (correcto).
- **Examen de nivel:** compuerta por **mastery por skill ≥0.80** revalidada al
  enviar (`submit_level_exam`, mig 041) — no se salta por atajo REST.
- **Derivación de nodo** (`learn_map_screen.dart:181-200`): `status` BD →
  `NodeState`. Fallback heurístico mientras carga el provider (`:196-199`).

### Hallazgos

#### 🟠 P1 — Listening sin audio degrada la jugabilidad (no bloquea el avance, pero baja accuracy)
- **Síntoma:** en B1/B2/pt, los ítems de *listening* (calificables) no tienen
  audio → el alumno responde a ciegas, falla, pierde vidas. La lección **igual
  se completa y desbloquea** la siguiente (el desbloqueo no depende de accuracy),
  pero la precisión baja y puede agotar vidas / frustrar.
- **Causa:** consecuencia directa del P0 de audio × listening-calificable.
- **Fix:** mismo que el P0 de audio (subir audio o degradar el ítem).

#### 🟡 P2 — Caso "lección/checkpoint solo-stub" es TEÓRICO (no ocurre en el contenido actual)
- Un análisis estático sugería que un checkpoint compuesto **solo** de stubs
  daría `v_graded=0` → `v_passed=false` → unidad siguiente nunca desbloquea.
- **Verificado contra la BD:** de 181 lessons (144 lesson, 36 checkpoint, 1
  mission), **0 tienen items 100% stub** (recordar: listening ya NO es stub).
  El riesgo es real a nivel de motor pero **no se materializa** con el seed
  actual. Conviene un guard defensivo (`if v_graded=0 then pasar/saltar`) por si
  contenido futuro introduce un checkpoint solo-speaking.

#### 🟡 P2 — Ramas muertas / inconsistencias menores de estado
- `learn_map_screen.dart:190` maneja `case 'in_progress'`, pero ese status
  **nunca se persiste** (rama muerta).
- Lección 100% stub (p. ej. solo speaking) se marca `completed` con
  `best_accuracy=0` → barra de progreso semánticamente rara (no bloquea).

#### ⚪ Sin evidencia — "race condition al invalidar antes del commit"
- Se planteó que `invalidate(lessonProgressProvider)` tras cerrar la lección
  podría leer antes de que el servidor escriba y revertir el nodo a `locked`.
  Es **plausible pero no reproducido**; `complete_lesson` es una transacción y
  el `invalidate` ocurre tras `await` del RPC. Lo dejo como hipótesis a vigilar,
  no como hallazgo confirmado.

**Condiciones exactas en que "no se avanza" (honesto):** no encontré un bloqueo
*duro* de avance en el contenido sembrado. Lo que el usuario percibe como "no
avanza bien" se explica mejor por: (a) **listening sin audio** en B1/B2/pt
bajando accuracy y agotando vidas (P1), y (b) la **compuerta de mastery por
skill ≥0.80** para el examen de nivel — que es *por diseño* pero puede sentirse
como un muro si una skill (p. ej. speaking, que es participación) no acumula
dominio como el alumno espera. Recomiendo instrumentar `log_event` con el
`item_id`/`lesson_id` en fallos para confirmar el caso real con datos.

---

## 4. LIGAS

### Estado real por componente

| Componente | Estado | Ubicación |
|---|---|---|
| Esquema `leagues` / `league_members` | ✅ | mig 009:38-58 |
| Acumulación `weekly_xp` (`jz_add_league_xp`) | ✅ | mig 024:58-71; enganchado en complete_lesson/checkpoint/practice/exam (mig 040:206/356/448/556) |
| Alta automática a liga (`jz_ensure_league`) | ✅ crea ligas Bronce dinámicas (cupo <30) | mig 024:24-56 |
| Ranking en vivo + modo "warming_up" (<5) | ✅ `get_league` | mig 036:15-56; `leagues_screen.dart` |
| **Ascensos / descensos** | ❌ **no implementado** | UI promete "top 5 ascienden" (`leagues_screen.dart:~87,142`) — falso |
| **Job de cierre semanal / rollover** | ❌ **ausente** (sin pg_cron, sin Edge Function, sin trigger) | — |
| **Reset de `weekly_xp`** | ⚠️ no hay reset; cada semana es una **nueva** `league_id` (`date_trunc('week', current_date)`, lunes UTC) → filas viejas quedan huérfanas | mig 024:24-40 |
| **Histórico / mensual / anual** | ❌ **ausente** — los datos semanales se descartan | — |

- Verificado en vivo: hay ligas reales (`bronce`, `week_start` 2026-06-15 y
  2026-06-22) con miembros y `weekly_xp` reales (25, 260, 364…). Sin bots.
- La columna `league_members.rank` existe pero **nunca se rellena** (el ranking
  se calcula con `row_number()` en `get_league`).

### Gap para rankings mensual/anual/histórico (lo que pide el dueño)
**Hoy no hay nada que lo soporte.** Faltaría:
1. **Snapshots semanales** — tabla `league_snapshots(user_id, week_start,
   division, final_rank, final_xp)` poblada por un job de cierre.
2. **Job/cron de fin de semana** — Supabase no trae cron en plan estándar:
   Edge Function con disparador HTTP programado, o RPC `close_week()` invocada
   por un scheduler externo (o `pg_cron` en Pro).
3. **Vistas/RPC agregadas** — `user_monthly_stats`, `get_monthly_leaderboard`,
   etc., derivadas de los snapshots.
4. **Lógica de ascenso/descenso** — sin esto, ni el ranking semanal "compite".

> **P1 de producto (no de seguridad):** la UI promete ascensos que no existen.
> Antes del público, o se implementa el rollover, o se ajusta el copy para no
> prometer algo que no ocurre.

---

## 5. SEGURIDAD (contraste con `SECURITY.md`, verificado en vivo)

> Método: cliente REST con **JWT autenticado real** (usuario creado y luego
> borrado con `delete_account`, que respondió 204). Sin `service_role`.

### ✅ Confirmado CERRADO
- **`correct_answer` (el CRÍTICO):** `GET content_items?select=correct_answer`
  → **`42501 permission denied`** (anon y authenticated). La vista
  `content_items_public` no expone la columna. **Cierre real.**
- **Helpers `jz_*` (mig 049):** revocados a authenticated/anon/public (no
  reprobado en vivo por no tocar datos, pero la revocación está en el SQL).

### Estado de los 4 hallazgos — TODOS CERRADOS ✅ (mig 058 · 2026-06-23)

Aplicada `20260623100058_security_hardening.sql` (efecto YA en DB). Verificado con
**JWT autenticado real** (usuario creado y borrado con `delete_account`; sin `service_role`).

| # | Hallazgo | Estado | Evidencia (JWT real) |
|---|---|---|---|
| 1 | **`league_members`/`leagues` SELECT abierto** (filtraba UUIDs de auth) | ✅ **CERRADO** | SELECT directo → **HTTP 403** (revoke + drop policy). `get_league` (DEFINER) sigue **200** y sus `members` ya NO traen `user_id` (solo `name/rank/weekly_xp/is_me`). Build live 7e26824 usa solo `get_league` → intacto. |
| 2 | **Gate de admin en `get_metrics`/`get_engagement`/`get_onboarding_funnel`** | ✅ **CERRADO** | No-admin → **`admin only`** (P0001) en los 3. Admin (test uid añadido a `admins`, JWT real) → **200** (`total_users=8`). Dueño Gian (`7b4a8e40-…`) sembrado en `admins` → su panel sigue OK en el build live. |
| 3 | **`log_event` sin allowlist/truncado/rate-limit** | ✅ **CERRADO** | Evento válido `screen_view` → insertado; **`AUDIT_BOGUS_EVENT` → 0 filas** (descarte silencioso, 204); props de 5KB en evento válido → fila con `{"_truncated":true}`. Rate-limit 120/usuario/min. Los 8 eventos del cliente live siguen entrando. |
| 4 | **`export_my_data()` (GDPR)** | ✅ **CERRADO** | RPC DEFINER acotada a `auth.uid()` → **200** con 24 secciones (stats, progreso, skills, certs, …). Botón "Exportar mis datos" en Ajustes (frontend **deploy-pending**). |

**Mecanismo de admin nuevo:** tabla `admins(user_id)` + `jz_is_admin()` (no se gestiona
por roles SQL; agregar/quitar = `insert/delete` en `admins`). Dueño ya sembrado.

> Nota: `submit_level_exam` **no** se tocó (no es vector de farm ahora que 055 cerró
> `correct_answer`: solo re-otorga XP `if v_any`/subida real). Riesgo agregado de
> seguridad: **bajo** tras esta migración.

### Compatibilidad con el build LIVE (7e26824) — confirmado ✅
- Ligas: el cliente live llama **solo** `get_league` (verificado con `git grep` en 7e26824;
  0 lecturas directas a `leagues`/`league_members`) → cerrar el SELECT **no lo rompe**.
- Analytics: los 8 eventos que emite el cliente live están en la allowlist → siguen entrando.
- Métricas: el panel interno (live) llama `get_metrics`/`engagement`/`funnel` solo desde
  `MetricsScreen` (nav manual). Gian (admin) sigue viéndolas; un no-admin verá `admin only`
  en ese panel interno (aceptable; es interno).

---

## 6. Tabla maestra de hallazgos priorizados

| ID | Área | Prio | Hallazgo | Verificado |
|---|---|---|---|---|
| A1 | Audio | 🟢 P0 ✅ | 216 audios faltantes generados+subidos → **312/312 (100%)** | Sí (HEAD post-fix) |
| A2 | Audio | 🟢 P1 ✅ | Desbloqueo iOS por gesto global + degradación con gracia (skip sin penalizar) | Sí (test 40/40) |
| P1 | Progresión | 🟢 P1 ✅ | Listening sin audio ya no penaliza (se salta) y además el audio existe | Sí (deriva de A1/A2) |
| P2 | Progresión | 🟡 P2 | Guard faltante para checkpoint solo-stub (teórico; 0 casos en seed) | Sí (BD: 0 casos) |
| P3 | Progresión | 🟡 P2 | Rama muerta `in_progress`; accuracy=0 en lección solo-stub | Sí |
| L1 | Ligas | 🟠 P1 | UI promete ascensos/descensos inexistentes; sin job de cierre | Sí |
| L2 | Ligas | 🟡 P2 | Sin snapshots/histórico → mensual/anual imposible sin nueva infra | Sí |
| S1 | Seguridad | 🟢 P1 ✅ | `league_members`/`leagues` SELECT cerrado (403); `get_league` sin UUIDs (mig 058) | Sí (JWT real) |
| S2 | Seguridad | 🟢 P1 ✅ | Gate admin en get_metrics/engagement/funnel (`admins`+`jz_is_admin`); Gian sembrado | Sí (JWT real) |
| S3 | Seguridad | 🟢 P2 ✅ | `log_event` allowlist(8)+truncado(>2KB)+rate-limit(120/min) | Sí (bogus→0 filas) |
| S4 | Seguridad | 🟢 P2 ✅ | `export_my_data()` (24 secciones) + botón Ajustes (frontend deploy-pending) | Sí (200, 24 claves) |
| G1 | General | 🟡 P2 | C1/C2 y monthly leagues documentados, no construidos; Conversar/Simulacros ocultos | Sí |

---

*Auditoría sin cambios de código. Usuario de prueba creado para los chequeos
autenticados y eliminado con `delete_account` (HTTP 204). Los eventos
`AUDIT_PROBE_*` insertados en `analytics_events` (6) están ligados a ese usuario
borrado.*
