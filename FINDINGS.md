# Jezici — Auditoría exhaustiva (solo lectura)

> **Fecha:** 2026-06-22 · **Alcance:** diagnóstico, CERO cambios de código.
> **Método:** lectura de repo + 56 migraciones, ejecución real de toolchain,
> y verificación contra la BD de producción con cliente REST (anon + JWT
> autenticado real, creado y borrado con `delete_account`). **No** se usó
> `service_role` para los chequeos de seguridad.
> **Foco:** (1) audio · (2) progresión · (3) ligas · (4) seguridad.

---

## SMOKE POST-DEPLOY — producción `b34b568` LIVE · 2026-06-23 ✅ TODO VERDE
> Verificación de solo lectura del build vivo (cliente real anon + JWT; usuario de
> prueba creado y borrado con `delete_account`; sin `service_role` en los chequeos
> de cliente). Tras desbloquear el deploy aterrizó de golpe: audio P0/P1, seguridad
> mig 058, PWA v4, tips mig 057, ligas/leaderboards mig 059.

| Superficie | Estado | Evidencia (cliente real) |
|---|---|---|
| **Loop core** | 🟢 | `content_items.correct_answer` base → **403/42501**; vista pública → col inexistente (400/42703); lección real = 8 ítems sin `correct_answer`; `grade_item` → 200 `{correct,graded,expected}` |
| **Seguridad (mig 058)** | 🟢 | `league_members`/`leagues` → **403**; `log_event` válido **204**, bogus descartado; `export_my_data` → **200 (24 secc.)**; `get_metrics` no-admin → **admin only**, admin (JWT real) → **200** (`total_users=10`) |
| **Ligas / Leaderboards (mig 059)** | 🟢 | `get_league` sin `user_id`; **32 combinaciones** Métrica×Ventana×Alcance → **0 errores, 0 UUID_LEAK**; paginación ranks `[1,2]`/`[3,4]`; `jz_close_weeks()` idempotente (2× → 0, snapshots 6=6) |
| **Audio** | 🟢 | HEAD a las **312 URLs → 312/312 = 200** (1 timeout transitorio confirmado 200 al reintentar); bundle vivo contiene "Audio no disponible" (degradación) |
| **PWA cache-busting (P0.5)** | 🟢 | `sw.js` = `jezici-v4` + `no-store` en el shell; `index.html` con `updatefound`/"Recargar"; `Last-Modified` de hoy, `Age` bajo. Sello **`JZ_BUILD` sigue en `dev`** (regresión conocida del fix de deploy; NO se toca aquí) |
| **Suites** | 🟢 | `flutter analyze` **0** · `flutter test` **42/42** · `verify_chain` es→en (certs A1→B2) · `verify_pt_chain` (A1→A2) · `e2e_audit` **todas PASS** |

> Nota: `iOS unlock` por gesto (`_AudioUnlockGate`) es lógica (sin string greppable);
> está en el commit desplegado `b34b568` y el bundle vivo trae las cadenas de
> degradación/export/leaderboards. La conducta real en dispositivo va en el checklist
> manual de abajo (§Checklist).

---

## LEGAL IN-APP — publicado 2026-06-23 (mig 062) · ⚠️ BORRADOR
Privacidad + Términos (ya redactados en `legal_screen.dart`) ahora **visibles** (Ajustes +
registro, con banner de beta + versión `2026-06-draft`) y **aceptados**: checkbox requerido
en el alta → `accept_legal` persiste `legal_consents` (versión + timestamp; RLS self, escritura
solo por RPC; cascada en delete_account). `my_legal_version` permite re-consentir al cambiar el
texto. Verificado con JWT real. **Es BORRADOR** (revisión de abogado pendiente; sin acreditación
oficial). Diferido: gate de re-consentimiento para usuarios existentes (infra lista).

## ANALÍTICA DE LA BETA — completa 2026-06-23 (mig 061)
KPIs medibles sin SQL desde la pantalla interna (Ajustes → Ver métricas, admin-only):
retención D1/D7/D30, **stickiness DAU/MAU (CURR)**, embudo de onboarding, lecciones/día,
% aprueba checkpoint/examen, % certifica, y **embudo dentro de la lección** (iniciadas/
completadas/abandonadas/sin-vidas + tasa de finalización). Tapado el único hueco (abandono
intra-lección) con 3 eventos nuevos (`lesson_start`/`lesson_quit`/`no_hearts`, añadidos al
allowlist). Sin PII. Verificado con JWT real (eventos entran/bogus descartado, gate admin,
league_members 403). Diferido: cohorte semanal visual, abandono por ítem, analítica de práctica.

## MONITOREO (Sentry) — cableado 2026-06-23, pendiente DSN
Sentry client-side integrado (`runWithSentry` envuelve `runApp`: Flutter + nativo + zona;
web errores JS). Sin DSN = NO-OP (app intacta, deploy intacto — buildCommand NO tocado para
evitar el gotcha de `$VAR`). Para activarlo, Gian pega el DSN como `--dart-define` **literal**
en `vercel.json` (ver CLAUDE.md §Monitoreo). Diferido: source maps + Sentry server-side.

---

## CONTENIDO C1 (es→en) — sembrado 2026-06-23 (mig 063 + 064) · ✅ LIVE, sin cert por diseño
**Qué se construyó.** 6 unidades C1 (25–30) con foco real de C1 (no "más gramática"):
matiz/colocación/hedging (U25), argumentación/concesión (U26), inversión enfática + cleft +
inferencia (U27), idiom/phrasal/registro/eufemismo (U28), condicionales con inversión + modalidad
avanzada (U29), lenguaje académico: nominalización/pasiva formal/reporting verbs (U30). **252 ítems**
(192 de lección + **60 de checkpoint FRESCO**), 4 habilidades, dificultad 0.62–0.92. Autorado por
profesor-IA (1 agente/unidad) → validado contra el grader (gen_c1.mjs, 0 problemas) → validador
determinista (`content_qa.py c1`) **0 hallazgos**. Audio TTS **67/67** en Storage (HEAD 200).

**Techo determinista (la tensión, resuelta honestamente).** reading/listening/vocab/gramática a C1
se autocalifican bien; **writing/speaking a C1 NO** sin IA (solo proxies: traducción tolerante +
leer en voz alta). Decisión: C1 se siembra como **contenido aprendible** pero **sin examen ni
certificado C1** hasta Fase 2. Cierre en DB (defensa en profundidad, todo live):
- Ítems de lección tag `c1_unidadN` / checkpoint `cp_unidadN` → **fuera del pool** del examen de nivel.
- **mig 064**: `jz_resolve_exam_level` topa en B2 (nunca apunta a C1/C2); `jz_level_status` →
  `unlocked=false` para C1/C2 → `start_level_exam` y `submit_level_exam` rechazan C1 con
  `level exam locked`. Verificado con cliente real (`verify_c1_cap.py`): un usuario **plenamente
  elegible** (6/6 checkpoints C1, 4 skills al tope) NO puede acuñar JZC-C1; ni flujo normal ni
  atajo RPC crafteado con respuestas correctas. La progresión intra-C1 la gatean los checkpoints (≥80%).
- ⚠️ **Para Gian (decisión Fase 2):** C1 hoy es **"en progreso sin certificado"**. Cuando exista
  evaluación real de writing/speaking (IA/humano), habilitar examen+cert C1 (retaguear a `unidad%`,
  ampliar el rango de las 2 RPC a C1, crear exam id `…0000c1`). Detalle: `docs/LEVELS_C1_DESIGN.md`.

**Verificación.** `content_qa.py c1` = 0 · `verify_chain.py` A1→B2 PASS (certs topan en B2) ·
`verify_c1_cap.py` PASS · `grade_item` califica C1 server-side · B2 (u.19–24)→C1 (u.25–30) ·
analyze 0 · test 43/43 · build web OK.

**Placement C1 — LIVE.** 4 ítems C1 (inversión/cleft/concesión) añadidos a `placement_test.dart`
con clamp 0..4 → ubica usuarios avanzados en C1. (Nota 2026-06-24: los deploys de Vercel vienen
READY desde el fix 68266d3 — el commit 151062f que incluye esta placement desplegó READY, así que
ya NO es "deploy-pending".) El contenido, tope de examen y audio están LIVE vía migraciones/Storage.

---

## SELLO DE BUILD JZ_BUILD — 2026-06-24 · ⚠️ lado-app LISTO, inyección BLOQUEADA (sigue `dev`)
**Objetivo:** mostrar el SHA real del build en el pie de Ajustes (diagnóstico de la beta).

**Hallazgo duro (re-confirmado empíricamente):** **CUALQUIER edición del `buildCommand` de
vercel.json rompe el deploy** — no solo `$VAR`/`$()` del SHA. Probé añadir un paso post-build
deploy-safe: `&& bash ../scripts/stamp_build.sh` (sin `$` del SHA en la cadena; el SHA se lee dentro
del script desde `$VERCEL_GIT_COMMIT_SHA`). Resultado: deploy **ERROR instantáneo, 0 logs de build**
(commit 0389b1a, dpl_318NmLN…). Producción NO se cayó (el alias se quedó en el deploy READY previo
bcb844a). **Revertí vercel.json a su string byte-idéntico vivo** → deploy se recupera.
→ La única superficie de inyección build-time es el buildCommand, y es intocable. Sin inyección
build-time, el runtime (hosting estático) no puede conocer el SHA. Conclusión: **no hay vía
deploy-safe vía vercel.json**; el sello queda **diferido**.

**Lo construido y CI-verde (se mantiene, inofensivo — cae a `dev`, sin regresión; commit 0389b1a):**
- `core/app_info.dart` `appBuild()`: lee `window.JZ_BUILD` en runtime (`dart:js_interop`,
  `app_info_stamp_web.dart`; stub `_io` para móvil/VM/tests). Pie de Ajustes y Sentry `release` lo usan.
- `scripts/stamp_build.sh`: inyecta `<script>window.JZ_BUILD="<sha7>"</script>` en
  `build/web/index.html` (idempotente; sin `$VERCEL_GIT_COMMIT_SHA` no inyecta → `dev`). Probado local:
  inyección + idempotencia + fallback OK. index.html va no-store (sw v4) → reflejaría el bundle real.

**Activación (requiere a Gian, dashboard):** añadir `… && bash ../scripts/stamp_build.sh` al **Build
Command del DASHBOARD de Vercel** (Project Settings → Build & Development), NO en vercel.json. Es la
única vía no probada que podría aceptarse (el rechazo parece específico de editar el buildCommand de
vercel.json). Si el dashboard también lo rechaza → limitación de plataforma; el sello queda en `dev`.

**Estado:** analyze 0 · test 52/52 · CI SUCCESS (0389b1a) · prod READY (alias en build previo);
buildCommand restaurado. El aviso de "nueva versión" del sw intacto.

---

## AUDITORÍA DE EFICACIA DEL CONTENIDO — 2026-06-24 (mig 071/072) · es→en A1/A2 + regresión pt
**Pregunta:** ¿el contenido de cada nivel *construye la competencia CEFR* de ese nivel? (no solo "sin
errores"). Auditoría por nivel: cobertura, progresión, retención, balance de 4 habilidades, evaluación.
Detalle en **EFICACIA_CONTENIDO.md**.

**Hallazgo sistémico (todos los niveles, ambos cursos):** balance de habilidades **~3:1** — R~74/W~74 vs
**L24/S24** por nivel (4/unidad). Listening/Speaking **subservidos**. Además **techo determinista de
producción**: speaking es proxy read-aloud (no califica producción oral) y writing se evalúa con
translation/cloze tolerantes (no redacción libre) → la competencia productiva real de cada nivel depende
de **Fase 2** (IA/humano). Honesto: el contenido entrena reconocimiento + producción guiada, no certifica
producción libre.

**es→en A1 y A2 — veredicto "SÍ con reservas".** Cubren el núcleo CEFR con progresión sólida, pero faltaban
puntos. **Arreglado (mig 071, 29 ítems nuevos SIN audio, cableados a la lección de su tema → loop + examen):**
A1 presente continuo básico (am/is/are+-ing), 3ª persona -s como sistema (he works), plurales y a/an,
these/those, números altos; A2 conectores because/so/but, present perfect 'yet', a lot of / much-many,
adverbios -ly. 29/29 válidos contra el grader; grade_item acepta lo correcto y rechaza lo erróneo.

**Regresión P0 destapada y ARREGLADA (mig 072):** los exámenes de nivel de **pt** daban 'level exam locked'
— mig 064 (misión C1) había restaurado start/submit_level_exam a la versión **mono-curso** (`courses where
is_active`), perdiendo el multicurso de mig 047. mig 072 restaura `jz_active_course()` en ambas (desde la
def viva, solo esa línea), preservando per-skill + el tope C1 (jz_level_status/jz_resolve intactas).
**verify_pt_chain vuelve a PASS** (y verify_chain es→en sigue PASS).

**Diferido (con punto de retome):** equilibrar L/S en todos los niveles (requiere autorar L/S + **audio
TTS** → tanda dedicada); auditoría de eficacia es→en B1/B2/C1 y es→pt A1/A2/B1; más reciclaje de léxico;
checkpoints menos sesgados a reconocimiento.

**Verificación:** validador determinista **0** (es→en) · verify_chain es→en + verify_pt_chain **PASS** ·
analyze 0 · test 55/55 (+3 del grader) · correct_answer 42501 · loop/seguridad/ligas intactos.

---

## AUDITORÍA PEDAGÓGICA DEL CONTENIDO — 2026-06-24 (mig 070) · ✅ es→en A1/A2
**Alcance:** 12 profesores-IA en paralelo (1/unidad) auditaron los **384 ítems es→en A1/A2** (lección
+ checkpoint) por correctitud, tolerancia, distractores, revelación, naturalidad, CEFR, claridad,
redundancia y skill. Detalle completo en **CONTENT_QA.md**.

**Resultado: 0 P0** (ninguna respuesta marcada es incorrecta — el banco A1/A2 está sano). 23 P1 + 5 P2.
**Clase sistémica:** `tolerancia_insuficiente` (22) — translation/cloze sin alguna variante natural que
un aprendiz LATAM produce y es correcta (sinónimos film/baggage/dad, have got, please, o'clock, get/grab,
artículo/número, "It's Monday", dígito "2", "never", "must"…).

**Arreglado (mig 070, additivo — no acepta lo erróneo):** 20 ítems con variantes añadidas a `accepted`
+ 2 pulidos (cloze `(cook)` ahora pide la forma -ing; match de partes del día evening/tarde-noche →
morning/mañana, sin solape). El grader ya normaliza apóstrofes/contracciones/puntuación, así que las
variantes nuevas son las de léxico/estructura.

**Rechazado (con criterio):** no se quita train/bus de "I need a ___ to Madrid" (son inglés natural →
quitarlos reduciría tolerancia válida); no se recategoriza un cloze writing→reading (cloze = producción
escrita). **Diferido:** 1 MC metalingüístico sobre superlativos (impreciso, no incorrecto); formato de
los 24 listening "elige el significado" no guarda el inglés oído en `payload.say` (audio funciona,
HEAD 200; no regenerable desde DB) — nota de arquitectura, no error.

**Blindaje (CI):** +3 tests de grader (sinónimos vía `accepted`, have got↔have, dígito en cloze).
**Verificación:** validador determinista **0** en ambos cursos; cliente real acepta las variantes y
rechaza lo erróneo; `correct_answer` 42501; analyze 0 · test 52/52 · build OK; loop/seguridad/ligas intactos.
**Pendiente:** auditar es→en B1/B2/C1 y es→pt (siguiente pasada; prioricé A1/A2 = lo que los testers usan hoy).

---

## GRADING + TIPS + WORD_BANK (feedback real) — 2026-06-24 (mig 067/068/069) · ✅ LIVE
**P0 — grading marcaba CORRECTO como incorrecto** ("Soy de Perú." → "I'm from Peru" salía ROJO;
el usuario veía "I''m"). **Causa raíz DOBLE:** (a) DATA: 15 ítems es→en A1 sembrados con apóstrofe
PRE-escapado dentro de un literal dollar-quoted `$j$` → quedó `I''m` (doble) en payload y
correct_answer; (b) NORMALIZACIÓN: `jz_normalize` no tocaba apóstrofes ni equiparaba contracciones.
**Fix (mig 067, raíz, sin aflojar):** `jz_normalize` ahora normaliza apóstrofes (tipográfico→recto,
`''`→`'`), EXPANDE ~58 contracciones a forma completa bidireccional (I'm↔I am, don't↔do not, what's
↔what is, it's↔it is, can't↔cannot…) y quita apóstrofes residuales; + limpió los 15 ítems (`''`→`'`)
y regeneró 4 audios cuyo texto hablado estaba corrupto. Espejo client-side en `grader.dart` (mismos
casos) + **5 tests nuevos** que el CI blinda. Verificado cliente real: `grade_item` acepta "I'm from
Peru" Y "I am from Peru", rechaza "I am from Brazil"; `correct_answer` sigue 42501; feedback limpio.

**P1 — word_bank/reorder REGALAN la respuesta** (enunciado mostraba el target en inglés → copiar,
no aprender). **Fix (mig 068, 20 ítems):** el enunciado da el SIGNIFICADO en español; las tiles
siguen en inglés (producción real). Grading sin cambios. Barrido: es→pt word_bank ya estaba limpio.

**P1 — tip descontextualizado y repetido** (tip de EDAD en lección de PAÍSES; mismos tips repetidos).
**Causa:** `get_lesson_tip` filtraba por `unit_order`, pero los tips estaban mal alineados con dónde
vive el concepto en el contenido, y el desempate era random. **Fix (mig 069):** nueva columna
`content_tips.topic` (66/72 tips mapeados al vocabulario de tags del contenido). `get_lesson_tip`
ahora calcula los conceptos REALES de la lección (tags de sus content_items) y prioriza: relevancia
exacta > tip general del nivel > misma unidad > skill flojo > **no visto > menos reciente** (anti-
repetición). Un tip con topic SOLO aparece en lecciones que cubren ese concepto. Verificado cliente
real: edad→"Tu edad", numeros→plural, posesivos→posesivo, rutina→adverbios; países ya NO da "Tu
edad" (da un tip general); 6 lecciones seguidas rotan por 4 tips distintos sin repetir consecutivo.

**Barrido de calidad (profesor):** 0 match ambiguos (parejas con misma respuesta) en ambos cursos;
0 colisiones de opciones mc/listening bajo la nueva normalización; los 12 translations es→en con
contracción en el value quedan auto-cubiertos por `jz_normalize`. analyze 0 · test 49/49 · build OK ·
loop/seguridad mig 058/ligas intactos.

---

## HISTORIAS / INMERSIÓN — construido 2026-06-24 (mig 065 + 066) · ✅ LIVE
**Qué existía:** nada. La capa "enseña" previa era tips/cuaderno (mig 057) + Referencia (mig 060);
no había historias. La "Sesión de inmersión" de Metodologia.md estaba sin construir.

**Qué construí:** input comprensible real en **Practicar → Inmersión**. **6 historias es→en** (3 A1 +
3 A2), narrativas/diálogos cortos curados con relevancia LATAM (mañana en casa, mercado, amigo
nuevo; fin de semana, viaje en micro, cumpleaños), calibradas i+1, con **audio por segmento**
(TTS, **46/46** en Storage) y **30 preguntas de comprensión** (mc/cloze) auto-calificables.

**Diseño (aísla del loop y respeta el grading seguro):** las preguntas NO son `content_items`
(si lo fueran, los pools de `start_practice` las servirían sin contexto) → viven embebidas en
`stories.questions`, columna **REVOCADA al cliente** (como `correct_answer` en mig 055). Calificación
100% server-side (`submit_story` → `jz_grade`). RPCs: `get_stories`/`get_story` (sin respuestas) +
`submit_story` (XP modesto +12 solo en 1er completado, alimenta racha). Audio en `audio/stories/`
(Storage, no toca assets de Flutter → sin riesgo del gotcha de CI).

**Verificación (cliente real, `verify_stories.py`):** get_stories=6 · get_story sin respuestas ·
lectura directa de `stories.questions` → **denegada** · submit correctas → score 1.0 + XP 12 (1ra vez),
2do sin XP · submit incorrectas → score 0 + `expected` para review · **audio HEAD 46/46**. UI: widget
test "Inmersión lista historias" + analyze 0 · test 44/44 · build web OK. Loop/seguridad mig 058/
ligas intactos (`verify_chain` A1→B2 PASS; migraciones aditivas).

**Diferido:** historias B1/B2 y es→pt (empezar por los niveles que tocan los primeros usuarios);
preguntas de listening dedicadas (hoy la comprensión es lectura, el audio es el input); analítica
de inmersión (eventos no añadidos al allowlist de `log_event` → se difiere para no tocar mig 058).

---

## CI (GitHub Actions) — RESUELTO ✅ 2026-06-24 · regla: CI = fuente de verdad, no el local
**Síntoma:** todas las corridas del workflow "CI" (#47–#56) en ROJO, incluso commits triviales —
mientras el **deploy de Vercel de esos mismos commits estaba READY** (prod live). → el fallo NO era
build/deploy sino un step de Actions común a todos.

**Causa raíz (1 línea):** el step **Analyze** falla con
`warning • The asset file '.env' doesn't exist • pubspec.yaml:80:7 • asset_does_not_exist` →
`flutter analyze` sale con código ≠0 y **aborta el job** (Tests y Build quedan *skipped*). `.env`
es un asset DECLARADO en `pubspec.yaml` pero **gitignored** (sin secretos en repo). El step de Build
sí creaba `.env` con `touch`, pero **corre DESPUÉS de Analyze**.

**Por qué el local daba FALSO VERDE:** en la máquina de Gian `.env` existe (lo usan las tools, 353 B)
→ analyze local pasa. En CI el checkout no lo tiene → analyze rojo. Reproducido en local:
`mv app/.env app/.env.bak && flutter analyze` → mismo `asset_does_not_exist`.

**Fix de raíz (sin trampa — no se tocó ningún test/check):** en `ci.yml`, step **`Prepare .env`**
(`touch .env`) **antes** de Analyze (no solo en Build) + Flutter **pinneado a 3.44.3** (CI usaba
`stable` flotante = 3.44.3; local 3.44.1 → deriva). El `.env` vacío basta: `supabase_config.dart`
usa fallback público embebido y lee `.env` de forma segura (`dotenv.isInitialized`).

**Regla operativa (nueva):** el verde del **CI de GitHub Actions es la fuente de verdad, no el
`flutter analyze` local**. Antes de declarar verde, correr el comando EXACTO del workflow en las
mismas condiciones (sin `.env`, versión pinneada). Detalle en CLAUDE.md §CI.

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

> **ACTUALIZACIÓN 2026-06-23 (misión ligas+leaderboards) — L1/L2 RESUELTOS ✅ (mig 059):**
> - **Rollover real:** `jz_close_weeks()` cierra cada semana vencida — **idempotente**
>   (marca `league_periods_closed`; 2ª pasada → 0) y **lazy** (se llama dentro de
>   `get_league`/`get_leaderboard`, no depende de cron). Escribe **snapshots**
>   (`league_snapshots`) y aplica **ascensos (top 7) / descensos (fondo 5)** entre
>   Bronce↔Diamante vía `user_division` + `jz_ensure_league` divisional. Movimiento solo
>   en ligas ≥13 (sin solape); en beta (<13) nadie se mueve, por diseño.
>   Verificado en vivo: semana 2026-06-15 cerrada, 6 snapshots, idempotente; lógica
>   probada en escenario sintético de 15 (1-7 suben, 8-10 quedan, 11-15 bajan; extremos capados).
> - **Leaderboards:** `get_leaderboard(metric, window, scope, limit, offset)` SECURITY
>   DEFINER, **SIN user_id** (rank/name/value/is_me). Métricas XP/Lecciones/Racha/Certificados ×
>   ventanas Semanal/Mensual/Anual/Histórico × alcance Global/División, derivadas de las
>   fuentes vivas (daily_goals, user_lesson_progress, streaks, certificates). Top-N + paginación.
>   Verificado: league_members/leagues siguen **403**; ninguna combinación filtra UUIDs.
> - **UI:** pestaña Ligas con segmento **Mi liga | Tablas**; Tablas con selectores
>   Métrica × Ventana × Alcance. Conserva el board semanal por división (zonas reales).
> - **Cron pendiente del dueño** (no bloqueante; el lazy-close cubre): `pg_cron` (Pro) o
>   Edge Function + cron externo llamando a `jz_close_weeks()`. Detalle en CLAUDE.md.
> - analyze 0 · test 42/42 (+ parse de LeaderboardResult + render de Tablas) · build web OK.
> El detalle original (pre-fix) se conserva abajo.

### Estado real por componente (pre-fix)

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
| L1 | Ligas | 🟢 P1 ✅ | Rollover real (mig 059): cierre idempotente/lazy + ascensos/descensos; UI ya no miente | Sí (live + sintético) |
| L2 | Ligas | 🟢 P2 ✅ | Snapshots + get_leaderboard (mensual/anual/histórico, global/división, sin UUIDs) | Sí (JWT real) |
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

---

## Checklist de verificación MANUAL para Gian (en dispositivo real)
> Lo de arriba se verificó con el cliente REST real. Esto requiere ojos+oídos en un
> teléfono real (audio, gestos, PWA). Marca cada uno. Si algo falla, anota modelo +
> navegador.

### iPhone (Safari → "Añadir a pantalla de inicio" → abrir como PWA)
- [ ] **1er tap desbloquea el audio:** abre la app, toca cualquier parte una vez;
      a partir de ahí los sonidos funcionan (no hace falta tocar dos veces).
- [ ] **SFX "correcto" suena tras calificar:** en una lección, responde bien y
      comprueba que suena el efecto al marcar correcto (no mudo el primero).
- [ ] **Listening con audio en B1/B2 y portugués:** entra a una lección de B1 o B2
      (es→en) y a una de es→pt; en un ejercicio de escucha, el botón reproduce voz.
- [ ] **Degradación con gracia:** (si algún audio faltara) el ejercicio muestra
      "Audio no disponible" y deja continuar **sin** restar vidas — no pide adivinar.
- [ ] **NO aparece reproductor en la pantalla de bloqueo** al sonar audio (Web Audio).
- [ ] **Ligas → "Mi liga":** carga tu división y tu posición de la semana.
- [ ] **Ligas → "Tablas":** cambia Métrica (XP/Lecciones/Racha/Certificados),
      Ventana (Semanal/Mensual/Anual/Histórico) y Alcance (Global/Mi división);
      la lista cambia y **"Tu posición: #N"** coincide contigo.
- [ ] **Ajustes → "Exportar mis datos":** abre el JSON y "Copiar" funciona.
- [ ] **Aviso de nueva versión:** tras un próximo deploy, con la PWA abierta aparece
      "Hay una versión nueva — Recargar" (no auto-recarga).

### Android (Chrome, e instalada como PWA)
- [ ] **1er tap desbloquea el audio** (igual que iOS).
- [ ] **SFX "correcto" suena tras calificar.**
- [ ] **Listening B1/B2/pt suena**; micrófono del speaking pide permiso y "Ya lo leí ✓"
      aparece si se deniega.
- [ ] **Ligas "Mi liga" y "Tablas" cargan**; "Tu posición" correcta.
- [ ] **Exportar mis datos** funciona.
- [ ] **Aviso de nueva versión** tras un deploy.

> Sello de build: en Ajustes se ve "Jezici 1.0.0 · **dev**" — es esperado (el sello
> `JZ_BUILD` quedó pendiente tras el fix de deploy; no afecta funcionalidad).
