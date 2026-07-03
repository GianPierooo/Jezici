# CLAUDE.md — Jezici (estado vivo)

> Contexto de arranque para cualquier sesión. **No** es copia de los 21 `.md` de
> diseño (eso es la carpeta raíz `Jezici_*.md` + `docs/`). Aquí va el ESTADO REAL,
> qué está verde, qué falta y cómo verificar. Mantener corto y al día.
> Última actualización: **2026-07-02**.

## Qué es
App de aprendizaje de idiomas (estilo Duolingo). **Flutter (web PWA)** + **Supabase**
(Postgres + RLS + RPCs SECURITY DEFINER) + **Vercel** (deploy del web). Repo
`github.com/GianPierooo/Jezici`, deploy `jezici.vercel.app`.
- 4 cursos: **es→en** (A1–C1), **es→pt** (A1–B1), **es→fr** (A1–A2 piloto) y **es→it**
  (A1–A2 piloto). Curso activo por usuario (`jz_active_course`). Selector en Ajustes.
- Loop: lección → ejercicios (9 tipos) → grading **server-side** → XP/oro/vidas →
  checkpoints (≥80%) → exámenes de nivel + certificados. Práctica/SRS, logros, ligas
  semanales, racha, Matix (notificaciones), onboarding con placement.
- **Grading 100% server-side** (`grade_item`, mig 055): el cliente nunca recibe la
  respuesta antes de responder. `correct_answer` revocado (lectura directa → `42501`).

## Pilotos es→fr + es→it (A1 + A2) — ✅ LIVE (mig 094–098 · 2026-07-02)
- **2 cursos NUEVOS, A1 Y A2 sembrados y verdes:** **es→fr** (course `…0003`, lang `fr`/Français) y
  **es→it** (course `…0004`, lang `it`/Italiano), ambos `is_active`. **A1 (mig 094/095) + A2 (mig
  097/098) completos** con el molde validado es→pt: 6 unidades por nivel (A1 order 1-6, A2 order
  **7-12** → encadenan; `submit_checkpoint` desbloquea la unidad con order mayor del MISMO curso →
  **gating A1→A2 automático y course-scoped**), 4 lecciones + checkpoint fresco + examen por unidad.
  **115 ítems por nivel** (460 fr+it), 4 habilidades balanceadas (A1 fr R38/W36/L23/S18 L=62%/S=49%;
  A2 fr/it R36/W36/L25/S18 L=69%/S=50%). Temas A2: passé composé/passato prossimo (avoir/avere→être/
  essere+concordancia), futur/futuro, viaje, comer-fuera/comparativos, imparfait/imperfetto+pronombres
  COD/diretti, salud/consejos («avoir mal à»/«avere mal di»). Autorado por profesores nativos IA
  (fr/it, NO traducción mecánica) + **validación adversarial nativa por nivel**: A1 fr 1 error real
  (`midi et demie`→`midi et demi`), it 0; **A2 fr 0 errores + 2 pulidos, it 0 errores + 2 pulidos**
  (todos aplicados). **Audio TTS** (`gen_audio_missing.py` tl=fr/it): fr A1 41 + A2 43, it A1 43 +
  A2 43 = **170/170** en Storage, texto-emparejado. Generador reutilizable **PARAMETRIZADO POR NIVEL**
  `tools/content/gen_course.py <code> <a1|a2>` (lee `<code>_<level>_u*.json`, ordena por `unit.order`,
  ids uuid5 sin colisión entre niveles/cursos; corrigió también el título it A1 «Unité»→«Unità»).
  Selector de Ajustes los muestra (banderas 🇫🇷/🇮🇹; `label`/nombre desde DB).
- **AISLAMIENTO multicurso (el riesgo #1, ya roto una vez con pt mig 064→072) — VERIFICADO con
  cliente real** (`verify_new_course.py fr|it`, JWT real, nunca service_role): **0 `lesson_items`
  cruzan los 4 cursos**; determinista fr 97/97 + it 97/97 correctos aceptados y 97/97 distractores
  rechazados (`correct_answer` 42501); `set_active_course`→`create_plan`/`start_practice` sirven
  SOLO el curso activo; usuario default(en) NO recibe fr/it; cadena lección(100%)+checkpoint(≥80%)
  por curso; audio HEAD 200. **A2 (`verify_a2_chain.py fr|it`): CAMINA las 12 unidades EN ORDEN con
  cliente real** (complete_lesson×lección + submit_checkpoint×checkpoint) → prueba el gating A1→A2
  end-to-end (U6 desbloquea U7), 30/30 lecciones A2 completadas, determinista A2 97/97, audio A2 43/43.
  **Cursos existentes INTACTOS:** `verify_chain` (es→en A1→B2) y `verify_pt_chain` (es→pt A1→B1
  multicurso) verdes tras cada tanda. analyze 0 · test 89/89.
- **Fix de fondo `create_plan` (mig 096):** `create_plan` **hardcodeaba** el curso más-antiguo-activo
  (`courses where is_active order by created_at limit 1` = es→en) IGNORANDO el curso activo → con
  >1 curso sembraba el plan/progreso/unidad-de-entrada en el curso EQUIVOCADO. Ahora usa
  `jz_active_course()`. **Cero regresión en es→en** (usuario nuevo sin fila `user_active_course` →
  fallback al mismo más-antiguo-activo=en). El onboarding actual NO llama `set_active_course` (elige
  curso en Ajustes vía `start_course`), así que no afloraba en la app, pero el fix es correcto y
  future-proof. `placement_next` ya era course-aware (recibe `p_course`); para fr/it sin banco de
  placement → `done` inmediato = nivel A1 (arranque de principiante, correcto para el piloto).
- **Diferido (retome del piloto):** B1+ de fr/it (hoy **A1+A2**); banco de **placement** fr/it
  (hoy usa el default → A1); cablear onboarding fr/it-específico (el onboarding sigue en-first,
  el curso se cambia en Ajustes); tips/historias/imágenes para fr/it; examen de nivel + certificado
  fr/it (hoy la progresión intra/inter-nivel A1→A2 es por checkpoints ≥80%, sin cert de nivel aún).

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
| **i18n (idioma de la UI es/en/pt)** | ✅ **REAL y live (commits `c1654d0`+`3f8f7f8`).** Antes el selector era **cosmético** (no había infra l10n; nada consumía `localeProvider` → elegir English/Português no cambiaba nada = el "idioma raro" del feedback). Ahora: `flutter_localizations`+`intl`+**gen-l10n** (ARB `es`/`en`/`pt` en `app/lib/l10n`, salida a fuente, `l10n.yaml`); `MaterialApp` consume `Locale` de `localeProvider` (persistido) → cambiar idioma re-renderiza la UI **al instante**. Selector NUEVO en **Ajustes** ("Idioma de la app") + cambio en vivo en el paso de idioma del onboarding. **Traducido 100%** (es/en/pt, ~260 claves): **onboarding + auth** (superficie del feedback; copy "idioma de la app vs objetivo" aclarado) y **loop de lección completo** (player, complete, preview, checkpoint intro/player/result, no_hearts, error_review, 6 ejercicios). Fecha del plan localizada (`MaterialLocalizations.formatMediumDate`), duración (`duration_format.dart`) y nombres de habilidad (`skill_names.dart`) por idioma. **Distinción clave:** i18n = chrome de la UI; el **CURSO** (es→en/es→pt = lo que se aprende) es contenido de la DB, NO se toca. Test `i18n_test.dart` (el locale cambia el texto; plurales/placeholders). **Cobertura extendida (2026-07-02, ~200 claves más):** **home/mapa** (learn_map, top bar a11y, misión), **ligas + leaderboards** (segmentos, zonas, métricas/ventanas/alcance, división localizada vía `division_names.dart`), **tienda + racha** (tarjetas, hitos, congelador), **perfil** (4 habilidades, plan, stats, certificados, examen/gate de dominio, "Para ti", editar perfil) — fechas por `MaterialLocalizations.formatMediumDate/formatMonthYear`, plurales (racha/jugadores/días/habilidades), reutilización de `skillName()`/`planFocus*`. **Diferido (en español, punto de retome):** Ajustes (cuerpo), práctica (SRS/débil/timed), notificaciones/Matix, inmersión/historias, level_exam, premium, legal (texto sustantivo), reference, notebook. |
| **Test de ubicación + arranque** | ✅ **preciso y live (server-driven, mig 075/076/077).** Antes: test 100% cliente con 20 ítems hardcoded en Dart + nivel = **MEDIA** de las preguntas (subestimaba → un B2 salía A1/B1) **y** `create_plan` **ignoraba** el nivel (siempre Unidad 1). Ahora: **`placement_next`** (RPC stateless, **calificado en servidor** con `jz_grade`, `correct_answer` 42501) con selección **escalera 1-up/1-down** + estimador **TECHO** (ubica en el nivel más alto manejado consistentemente) + per-skill reading/writing. Banco real **48 ítems A1→C1** (5+5/nivel, validados adversarialmente), tag `placement` (excluido de pools). **Puente**: `create_plan` mapea `current_level`→**unidad de entrada** (A1=1·A2=7·B1=13·B2=19·C1=25), marca lo inferior `completed` (accesible, sin XP), entrada `available`. Avance del mapa es por cadena → seguro (examen/cert siguen gateados por dominio). **Verificado cliente real:** personas A1/A2/B1/B2/C1 → su nivel EXACTO (B2 incluso con hint malo); B2→arranca en U19, A1→U1. Cliente = **relay** (sin banco ni estimador local). **Robustez + resultado (mig 089):** el techo ingenuo SOBREESTIMABA (un acierto suelto en alto promovía); ahora **"techo con evidencia"** — un nivel se domina solo con `asked≥2 & correct≥2 & acc≥2/3`; el más alto dominado (no promueve por azar/suelto). +5 ítems C1 (banco C1 7R+6W), `placement_next` junta más evidencia (min 8/max 14, reversals≥4). **Fecha realista (estimation.dart):** el "2 semanas a C1" venía de la sobreestimación + `needed` negativo; ahora la **meta efectiva siempre > nivel actual** (si placement ≥ meta, apunta al siguiente nivel) y la duración se muestra humana (semanas/meses/**años**, no "789 semanas"); horas-guía reales (C1≈750h). **Pantalla de RESULTADO** (`PlacementResultView`, paso nuevo del onboarding): "Tu nivel: X" + desglose 4 habilidades + unidad de entrada + fecha realista (ubicación, no aprobar/reprobar). Verificado: `verify_estimator.py` 7/7 (incl. acierto-suelto NO salta), personas A1–C1 exacto, +6 tests Dart. **Banco es→pt ✅ (mig 093, 2026-07-02):** 42 ítems (A1/A2/B1 × 7R+7W) pt-BR, curso `…0002`, tag `placement`; validación adversarial (profesor pt-BR: 39/42 impecables, 1 fix de regência "assistir a", 2 distractores endurecidos) + guardas anti-colisión (cloze sin distractor a distancia-1 del correcto, ya que `jz_near_match` perdona insert/borrado; MC = exacto). **Verificado cliente real** (`verify_placement_pt.py`): determinista 42/42 (correctos aceptados, distractores rechazados sin near-match), personas A1→A1/A2→A2/B1→B1/avanzado→B1 (techo honesto: pt tope B1), **multicurso: todo curso pt, `placement_next(en)` sin fuga**. **Diferido:** cablear el placement pt a un onboarding/re-placement pt (hoy el onboarding es en-only Fase 1; `create_plan` usa el curso activo más antiguo = en) + L/S en placement (audio, ambos cursos). |
| Loop lección + grading server-side | ✅ verde y live. **Grading apóstrofes/contracciones (mig 067):** `jz_normalize` equipara I'm↔I am, don't↔do not, '↔'↔'' y limpió 15 ítems con `''` corrupto del seed. **word_bank/reorder no revelan la respuesta (mig 068, 20 ítems):** enunciado en español. **Typo-tolerance "casi correcto" (mig 073):** `grade_item` perdona typo menor (distancia 1: inserción/borrado, o sustitución SOLO en multi-palabra) y artículo a/an/the faltante/sobrante → `correct=true` + **`near=true`** (no resta vida, muestra "La forma correcta es…"). Guard de homógrafos: live/life, house/horse, cat/cut, this/these NUNCA se perdonan. `jz_grade = jz_grade_exact OR jz_near_match` (loop, summary y examen coherentes). Espejo cliente en `grader.dart` (`nearMatch`) + tests (`grader_typo_tolerance_test.dart`, 17). **Repaso de errores (mig 074 + `ErrorReviewScreen`):** al terminar, si hubo fallos → pantalla "Repasa lo que fallaste" (cada errado + respuesta correcta + porqué) ANTES de la recompensa; "Practicar los fallados" opcional. Los fallados entran al SRS con prioridad (`srs_prioritize_failed` → `user_vocab_srs` due=now). **TTS de tile (Web Speech):** tocar una ficha en word_bank/reorder pronuncia la palabra (cero archivos, interrumpible, degradación con gracia; disparado por TAP → sin desbloqueo iOS). `correct_answer` sigue revocado (42501). |
| **Música ambiente del mapa** | ✅ **es→en/pt (live).** Loop ambient **original (obra propia → CC0**, sin terceros, `gen_music_loop.py` síntesis procedural; ciclos enteros → sin clic; 12s/384KB en Storage `audio/ambient/map_loop.wav`, carga diferida → bundle +5.6KB solo código). **Default APAGADA (opt-in)** — pisar el audio del usuario = desinstalan. Toggle en **Ajustes** + **toggle rápido** en la top bar del mapa (persistido, `MusicController`/`music_enabled`). **Solo en el mapa**: `HomeShell` coordina por tab (==0) + lifecycle (pausa al backgroundear) + `setSuppressed` en lección/checkpoint/examen (nunca durante el ejercicio). **Ducking automático** en el `AudioEngine` (la música baja sola con cualquier SFX/TTS vía rampa de GainNode, se recupera después). **MediaSession NO reactivada**: el loop vive en el MISMO AudioContext (Web Audio API, sin `<audio>`) → sin reproductor en pantalla de bloqueo (riesgo conocido, mantenido a raya). Pendiente: variar/alargar el loop, presets de volumen. |
| Dinamismo/UX (loop) | ✅ 1ª tanda LIVE (deploy-pending): recompensa con contadores+entrada escalonada, feedback ✅/❌ animado, transiciones `jzRoute`, skeletons en Ligas. Pendiente: tokens de espaciado, mascota en más pantallas, radar animado. Ver UX_AUDIT.md |
| Capa "enseña" (tips/cuaderno/referencia/**inmersión**) | ✅ tip post-lección **relevante al tema real de la lección** (mig 069: `content_tips.topic` + match contra los tags de la lección; ya no sale el tip de EDAD en una lección de PAÍSES) + anti-repetición (no visto > menos reciente) + personalización por skill flojo + cuaderno + **Referencia/Repaso** (mig 060) + **Inmersión/Historias** (mig 065/066: 6 historias es→en A1/A2, audio 46/46). 72 tips **solo es→en** (66 con topic, 6 generales). Pendiente: historias B1/B2 y es→pt, tips para **es→pt**, topics para B1/B2 (hoy caen a unidad/general). |
| Contenido es→en A1–B2, **es→pt A1–B1** | ✅ sembrado y live (pt B1 = mig 053, 192 ítems + 60 checkpoints frescos; cadena A1→B1 + certs verificada). Pendiente: es→pt B2 |
| **Audio** (listening/speaking TTS) | ✅ es→en + es→pt A1/A2 (312) + **es→pt B1 (68)** = 380 + **rebalanceo L/S es→en A1/A2 (96, mig 078/079)** en Storage = **476/476** + degradación/unlock iOS LIVE. Ver FINDINGS.md §2 |
| **Balance de 4 habilidades (L/S)** | ✅ **es→en A1–C1 rebalanceado (mig 078–082, live).** Audit EFICACIA halló sesgo **~3:1** (R/W vs L/S). Subido con criterio (NO 1:1): **listening ~65% de R/W**, **speaking ~50%** (proxy read-aloud, participación, no evalúa fluidez). **A1/A2** (mig 078/079): +5L/+3S por unidad (96 ítems). **B1/B2/C1** (mig 080/081/082): +4L/+2S por unidad → resultante B1 L/R=62% S/R=50%, B2 61%/49%, C1 69%/51% + **34 huecos** de cobertura de alto impacto rellenados (auditoría confirmó cobertura gramatical SÓLIDA en los 3; sin huecos estructurales). **+204 ítems** L/S totales (todos con audio TTS regenerable, `payload.say`/`text` guardado), autorados por panel IA + validación adversarial por unidad, cableados a lecciones 1–4 + tag `unidadN` (pool del examen → menos sesgo R/W). **es→pt A1/A2/B1** (mig 083/084/085): +4L/+2S por unidad → pt A1 L/R=61% S/R=49%, A2 62%/50%, B1 72%/57% + 34 huecos; audio **tl=pt** (108/108). **Verificado cliente real** por nivel (en+pt): L/S resueltos suben su dominio (listening precisión, speaking participación); verify_chain A1→B2 PASS; **verify_pt_chain A1→B1 PASS (multicurso: contenido pt→curso pt, 0 fuga)**. **Techo C1 honesto:** receptivas sí a C1; producción libre (W/S) requiere Fase 2 → sin cert C1 por diseño. **Sesgo L/S 3:1 resuelto en AMBOS cursos.** Pendiente: es→pt B2/C1 no existen aún (curso pt llega a B1). |
| **Imágenes referenciales (doble codificación)** | ✅ **es→en A1/A2 (mig 086/087, live).** Fuente **Twemoji (CC-BY 4.0)** alojado en Storage (`audio/vocab/<concept>.png`), carga **diferida** (`Image.network`, cero deps/assets nuevos → bundle igual). **39 iconos** de vocab concreto (comida, familia, lugares, tiempo, viaje, compras) + registro de **proveniencia/licencia** en `vocab_images` (RLS sin policy → no se filtra al cliente). **21 ítems** `multiple_choice` "¿Qué es esto?" (imagen=estímulo → NO revela por texto; opciones=palabras de la misma categoría; `correct_answer` 42501). UI: `ConceptImage` en `buildExerciseWidget` → se ve en las 4 superficies (lección/checkpoint/examen/práctica), altura fija (sin jank), **degradación con gracia** (si no carga, colapsa y el ejercicio sigue con texto). Verificado cliente real: HEAD 21/21, grading server-side, image_url por `content_items_public`. **"Describe la imagen" determinista (mig 088):** 16 ítems **word_bank/writing** que reusan las imágenes — el usuario ARMA con fichas la frase ("This is a house") → secuencia verificable (jz_grade word_bank), produce lenguaje (mueve **writing**), distractor de ficha enseña el artículo (a/an/the/incontable). Cero UI nueva (reusa ConceptImage+TileArrange). Degradación: 1 solo sustantivo/frase → resoluble desde fichas aunque la imagen no cargue. **Descripción ABIERTA evaluada = Fase 2** (techo determinista). **Carga (2026-06-27):** barrido HEAD de TODO (audio 759/759, imágenes 37+39, historias 46, música) = **0 recursos 404** (`sweep_resources.py`); el "no cargan bien" era lentitud percibida → **precarga de imágenes** en el lesson_player (como el audio) + failsafe en `ConceptImage` (colapsa a los 10s, no spinner eterno). **Copy onboarding** aclarado (idioma de la APP vs lo que aprende; sin anglicismos). Pendiente: match imagen↔palabra, es→pt, B1+. |
| **Seguridad** (4 hallazgos) | ✅ **cerrados** en DB (mig 058) + botón export en Ajustes **LIVE** (deploy 68266d3). Ver abajo |
| Ligas + Leaderboards | ✅ rollover real (mig 059): cierre semanal idempotente/lazy + ascensos (top 7)/descensos (fondo 5) Bronce↔Diamante + snapshots. `get_leaderboard` (XP/Racha/Lecciones/Certificados × Semanal/Mensual/Anual/Histórico × Global/División, SIN user_id). UI con segmentos (Mi liga / Tablas) **LIVE** (deploy-pending hasta push). Falta: **cron** que dispare el cierre (hoy es lazy-on-read; ver abajo) |
| **C1 es→en** | ✅ **sembrado y live** (mig 063): 6 unidades (25–30), **252 ítems** (192 lección + 60 checkpoint fresco), 4 habilidades, audio **67/67**. **Sin examen/cert C1** por diseño (techo determinista — writing/speaking a C1 no son evaluables sin IA; mig 064 tope el examen en B2 + blinda C1). Progresión intra-C1 por checkpoints (≥80%). Placement C1 ahora con banco real (8 ítems) + arranque en U25 (mig 075/076/077). Ver `docs/LEVELS_C1_DESIGN.md` y fila **Test de ubicación** |
| C2 | ❌ documentado, no sembrado (otra pasada) |
| Conversar | ✅ **VISIBLE** (pestaña 2 del nav, GA7): práctica en solitario/asíncrona (tema → escribe/habla → respuesta modelo + autoevaluación) + captura de interés para la conversación EN VIVO (Fase 2). ⚠️ **Contenido hardcodeado en INGLÉS** (`conversar_screen.dart`, `topics`) → un usuario pt/fr/it ve respuestas modelo en inglés. Multicurso pendiente. (Los docs viejos decían "oculto GA6" — FALSO, se reactivó en GA7.) |

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
- **FEEDBACK DE USUARIOS — dónde lo ve Gian (mig 099, 2026-07-02):** el feedback in-app
  (`FeedbackFab` app-wide → `submit_feedback` → tabla `feedback`) se capturaba pero era
  **ILEGIBLE** (la tabla tiene RLS solo-INSERT y `get_engagement` daba solo el CONTEO por tipo,
  no el texto). Nuevo **`get_feedback(limit)`** (admin-gated, SIN PII: user_id recortado a 8
  chars) devuelve los MENSAJES reales; **MetricsScreen los muestra en la sección "Mensajes de
  usuarios"** (texto + tipo + pantalla + fecha). Gian: Ajustes → Ver métricas → baja a "Mensajes
  de usuarios". **Query directa (admin):** `select created_at, kind, screen, message from feedback
  order by created_at desc;`. Verificado cliente real (no-admin → "admin only"; admin → mensajes).
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
flutter test                 # esperado: All tests passed (89/89)
flutter build web --release  # esperado: Built build/web (wasm dry-run warning de ua_client_hints es OK)

# Audio: cobertura real en Storage (HEAD a payload.audio_url) — es→en/pt = 692/692 (incl. 312 L/S mig 078–085)
#   + es→fr A1 41 + A2 43 + es→it A1 43 + A2 43 = 170/170 (pilotos A1+A2, mig 094/095/097/098, tl=fr/it)
#   query content_items_public?type=eq.listening|speaking_read_aloud, HEAD cada audio_url
# Curso nuevo A1 (fr/it): tools/content/verify_new_course.py <code> — determinista + aislamiento (4 cursos) + cadena + audio
# Nivel A2 (fr/it): tools/content/verify_a2_chain.py <code> — determinista A2 + aislamiento + CAMINATA 12 unidades (gating A1→A2) + audio

# Cliente REAL (NUNCA service_role para chequeos de seguridad):
#   anon key + JWT autenticado real (signup vía /auth/v1/signup, limpiar con delete_account).
#   Ejemplos verificados (mig 058): league_members directo → 403; get_league → 200 sin user_id;
#   get_metrics no-admin → "admin only"; export_my_data → 200; log_event bogus → 0 filas.

# DB (introspección/seed admin): tools/content/apply_sql.py vía Management API (.env).
```
- **Verificación de cliente desplegado**: `git show 7e26824:app/lib/...` para ver qué consulta
  el build que usan los usuarios HOY (no asumir que `main` == producción).

## Reportes de diagnóstico (raíz)
- **QA_AUDIT.md** (2026-06-27, solo lectura) — QA exhaustivo end-to-end + veredicto de flujo (cliente real).
  **P0 ✅ ARREGLADO (mig 090, 2026-07-02):** el congelador de racha ahora SÍ protege — `jz_register_activity`
  consume `freezes_available` al haber un hueco y preserva la racha (verify_streak_freeze.py 7/7, cliente real);
  antes solo se incrementaba. **P1 (idioma) ✅ ARREGLADO:** i18n real es/en/pt (ver fila **i18n**); el selector ya
  cambia la UI. **P1-3 misión ✅ ARREGLADO (mig 091):** bono de bienvenida one-time (25 XP+25 oro) + diálogo de
  confirmación. **P2 retención/sensación ✅ (2026-07-02):** meta diaria "X/Y XP" visible en el mapa (pastilla con
  número), combo "🔥 x{n}" en vivo en la lección, feedback de oro enriquecido (ganaste/gastaste, te quedan Y),
  race del cofre (guard), zonas de liga en beta (mig 092: promote/demote=0 hasta 13 jugadores == gate del
  rollover; UI con `movementActive` + nota beta). **Ver §0.1 de QA_AUDIT.md** para el estado ítem por ítem.
  **Diferido:** a11y amplia (device), precios hardcodeados, colores, infra bots, deuda leaderboards. **Verificado
  en vivo TODO lo core** (grading 42501, leaderboards sin fuga de user_id, placement/fecha, loop, 0 recursos 404,
  analyze 0/test 88/build OK).
- **EFICACIA_CONTENIDO.md** (2026-06-24) — auditoría de EFICACIA de currículo por nivel (¿lleva a CEFR-X?).
  Veredicto es→en A1/A2: "sí con reservas"; huecos de cobertura rellenados (mig 071, 29 ítems sin audio:
  presente continuo, 3ª persona -s, plurales, these/those, conectores, present perfect 'yet', adverbios -ly).
  **Hallazgo sistémico:** L/S subservidos ~3:1 vs R/W en TODOS los niveles + techo determinista de producción
  (speaking proxy). Destapó y arregló una **regresión P0** (mig 072): exámenes de pt rotos por mig 064 (mono-curso).
  **L/S YA equilibrado en AMBOS cursos**: es→en A1–C1 (mig 078–082) + es→pt A1–B1 (mig 083–085) = +312 ítems L/S +
  68 huecos + audio. **Auditoría de eficacia HECHA**: es→en A1–C1 y **es→pt A1–B1** (cobertura sólida; verify_pt_chain
  multicurso PASS). Pendiente: es→pt B2/C1 (no sembrados; el curso pt llega a B1).
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
