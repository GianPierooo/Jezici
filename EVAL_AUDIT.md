# EVAL_AUDIT.md — Auditoría del sistema de evaluación (SOLO LECTURA)

> **Fecha:** 2026-07-10 · **Método:** introspección del **código real** (RPC/painters/Dart) y de la
> **BD real** (Management API, cliente JWT). Cero cambios de código. Todos los números salen de queries
> y de correr el flujo real 2–3 veces. Reemplaza suposiciones por evidencia.

## TL;DR (lo esencial, con evidencia)

1. **La evaluación es 100% server-side, determinista y honesta en su núcleo** (`grade_item`/`jz_grade`
   con `correct_answer` revocado = 42501). No hay IA. Bien.
2. **Aleatorización REAL sí existe** en la SELECCIÓN de ítems: placement solapa **50%** entre intentos,
   checkpoint **40%** — cada intento saca ítems distintos. **PERO el ORDEN de las opciones NO se baraja**
   (fijo en BD): 0 de N ítems compartidos cambian el orden entre corridas → un repetidor puede memorizar
   "la posición 2". (P1)
3. **Dos nociones de "nivel" que pueden DIVERGIR:** (a) `user_skill_levels.cefr_level` = **contador de
   puntos** (12/acierto, 4/stub; 100 pts = +1 CEFR) que sube con el GRIND sin importar el nivel del
   contenido → **el radar del Perfil se infla**; (b) `jz_skill_mastery(nivel)` = cobertura×precisión del
   nivel, **rigurosa**, la que gatea el certificado. El certificado es serio; el radar no. (P0 de honestidad)
4. **El certificado (el diferenciador) es EN-ONLY y tope B2.** Solo `en` tiene exámenes tipo `level`
   (4: A1–B2). `jz_resolve_exam_level` **capa en B2** ("C1/C2 no examinables Fase 1"). pt/fr/it/de/nl
   **no pueden certificar ningún nivel** (solo checkpoints). Máximo certificado del producto hoy = **B2 en
   inglés**. (P0 de producto)
5. **Hueco de cobertura crítico: checkpoints C1 (en) están casi vacíos por skill.** en C1 `unidad25` =
   **reading 1 · writing 1 · listening 4 · speaking 2** ítems taggeados → el checkpoint (pide 3R/3W/2L/2S)
   sirve ~6 de 10, con **1 solo ítem de reading y 1 de writing, SIEMPRE el mismo** (cero aleatorización).
   47 de 299 ítems C1 están taggeados `unidadN`; los otros 252 solo son alcanzables por lecciones. (P0)
6. **Speaking no mide habla real** (por diseño Fase 1): read-aloud + STT con tolerancia typo; en el examen
   de nivel **solo cuenta la PARTICIPACIÓN** (respuesta no vacía), no la corrección. Límite honesto pero
   hay que comunicarlo. (P1 honestidad)

---

## 0) Ground truth — cómo funciona hoy (código real)

### Calificación (`jz_grade` = `jz_grade_exact` OR `jz_near_match`)
- **MC / listening / match:** SOLO exacto (near-match NO aplica). El distractor no colisiona bajo
  `jz_normalize` (guarda del banco).
- **cloze / translation:** exacto + **near-match tolerante**: artículos faltantes/sobrantes (a/an/the) y
  **1 edición** (inserción/borrado, o sustitución solo en multi-palabra). Homógrafos peligrosos NO se
  perdonan. Los ítems de placement se convirtieron a `multiple_choice` (mig 134) → exacto siempre.
- `correct_answer` revocado al cliente (lectura directa → 42501); el cliente es un relay.

### Subida de nivel por habilidad — DOS mecanismos
- **Uso normal (lecciones + checkpoints):** por cada skill, `sum(12 si acierto, 4 si stub)` → suma a
  `user_skill_levels.progress_points`; **≥100 → `jz_next_cefr(cefr)` y −100**. **No mira el nivel del
  contenido:** grindeando A1 se puede subir el `cefr_level` de reading a B1/C1 sin ver ese contenido.
  Esto alimenta el **radar/nivel mostrado en Perfil**. (≈9 aciertos = +1 CEFR de una skill; speaking solo
  suma 4/stub → ≈25 read-alouds = +1 CEFR.)
- **Certificación (examen de nivel):** por skill sube 1 nivel **solo si** la sección de esa skill acierta
  **≥0.80** *y* `jz_skill_mastery(uid, curso, skill, nivel) ≥ 0.80`. `jz_skill_mastery` = `cobertura ×
  precisión_ponderada`, con cobertura = distinct ítems intentados / (60% de los ítems del nivel) y
  precisión ponderada por dificultad. **Rigurosa y nivel-consciente.** El **certificado N** se emite
  cuando las 4 skills cruzan N.

### Selección de ítems (aleatorización)
- **placement_next** (adaptativo): `order by |rank−banda| asc, skill_match asc, random()`. Rota R→L→W→S
  sobre skills disponibles; min 10 / máx 16, para con rev≥4 o pin≥3.
- **start_checkpoint:** `row_number() over (partition by skill order by random())` → **3R+3W+2L+2S=10**
  del banco de la unidad (tag `unidadN` del nivel de la unidad).
- **start_level_exam:** igual patrón, **6R+6W+4L+4S=20** del pool `unidad%` del nivel; umbral 0.80.
- **Opciones:** el array `payload.options` viene **fijo de la BD** (baraja determinista al sembrar). **No
  se re-baraja al servir.**

---

## 1) COBERTURA del banco (números reales)

### Contenido (excluye placement) — ítems por curso × nivel × skill
```
en  A1 R97 L54 W85 S42 | A2 R85 L54 W87 S42 | B1 R78 L48 W77 S36 | B2 R80 L48 W76 S36 | C1 R86 L59 W110 S44
pt  A1 R80 L48 W76 S36 | A2 R96 L60 W95 S48 | B1 R81 L58 W114 S46 | B2 R36 L24 W36 S18 | C1 R36 L24 W36 S18
fr/it/de/nl (cada uno)  A1..C1 ≈ R36 L24-25 W36 S18   (densidad base, 6 unidades/nivel)
```
- **Suficiente para lecciones y práctica** en todos. La densidad "rica" (en A1–C1, pt A1–B1) viene del
  rebalanceo L/S (mig 078–085); fr/it/de/nl y pt B2/C1 están en densidad base (≈114 ítems/nivel).

### Tipos por skill (todo el contenido)
- **reading:** multiple_choice 1005 · match 455 · cloze 17 → recognición + comprensión mixta.
- **listening:** `listening` 963 · **audio 963/963 (100%)** → "escucha y elige lo que oíste" (MC con audio).
- **writing:** cloze 599 · translation 461 · word_bank 263 · reorder 188 → **GUIADO** (rellenar/armar/
  ordenar), **cero producción libre**.
- **speaking:** speaking_read_aloud 726 → **solo leer en voz alta**.

### Placement (tag `placement`) — pool por curso
```
en  R{A1:8,A2:6,B1:7,B2:7,C1:7} L{3×5} W{6,8,7,7,6} S{2×5}   (5 niveles A1–C1)
pt/fr/it/de/nl  R{7×4} L{3×4} W{7×4} S{2×4}                  (4 niveles A1–B2)
```
- **Reading/Writing:** 6–8/nivel → suficiente para un CAT breve (pide ~2–4/skill).
- **Listening 3/nivel, Speaking 2/nivel:** **justo al mínimo** (el RPC exige ≥3/skill antes de parar). Con
  min-3 el pool de listening se agota en un intento largo → poca variedad y poca evidencia por skill.
  **Hueco:** L/S de placement son delgados (P1).

### Pool del EXAMEN DE NIVEL (tag `unidad%`) — solo importa para `en` (único con exámenes `level`)
```
en  A1 R97 L54 W85 S42 | A2 R85 L54 W87 S42 | B1 R78 L48 W77 S36 | B2 R80 L48 W76 S36   → SANO (pick 6/6/4/4)
en  C1 R7 L24 W4 S12  → NO se usa (C1 sin examen de nivel; tope B2)
```
- **A1–B2 sanos** (10–20× el pick → buena no-repetición). **C1 no aplica** (tope B2).

### Pool de CHECKPOINT por unidad (tag `unidadN`)
- **en A1 unidad1:** R14 L9 W10 S7 → **sano** (pick 3/3/2/2, pool 2–4×).
- **en C1 unidad25:** **R1 L4 W1 S2** → **ROTO**: reading/writing = 1 ítem fijo, siempre el mismo; el
  checkpoint sirve ~6 de 10. (P0 — ver §4.) 252/299 ítems C1 no están taggeados `unidadN` (invisibles al
  checkpoint).

---

## 2) Cómo se evalúa cada habilidad (qué mide bien / qué NO)

| Skill | Qué mide HOY | Mide bien | NO mide (límite honesto) |
|---|---|---|---|
| **Reading** | MC de comprensión + match de vocab + cloze | reconocimiento léxico/gramatical y comprensión de frase | inferencia, textos largos, lectura entre líneas |
| **Listening** | "escucha y elige lo que oíste" (MC + audio TTS, 100% con audio) | discriminación auditiva de frase, comprensión literal | comprensión inferencial, audio natural (es TTS), acentos, velocidad real |
| **Writing** | cloze/word_bank/reorder/translation (GUIADO) | ortografía, orden de palabras, gramática puntual | **producción libre**, coherencia, registro, composición (Fase 2 = IA) |
| **Speaking** | read-aloud + STT (tolerante a typo) | que el usuario **articule** la frase objetivo (participación) | **fluidez, pronunciación real, producción espontánea, contenido** — en el examen de nivel solo cuenta que la respuesta **no esté vacía** |

- **Reading/Listening SÍ miden comprensión de frase** (no solo vocab suelto): las opciones son frases
  alternativas plausibles (distractor cambia una palabra de contenido o el tiempo verbal). Listening tiene
  audio para el 100%.
- **Writing es más "reading aplicado" que writing:** el usuario reconoce/ordena, no redacta. Honesto para
  Fase 1; el radar lo llama "writing" pero es producción guiada.
- **Speaking es el más débil:** en el examen de nivel la sección speaking **aprueba con solo responder no
  vacío** (`v_spk_ok = v_spk_total`), sin evaluar corrección de la lectura. Un usuario que diga cualquier
  cosa (STT capta algo) "aprueba" speaking. (P1 — el certificado se apoya en participación, no destreza.)

---

## 3) ALEATORIZACIÓN (evidencia de correr el flujo)

| Prueba | Resultado | Veredicto |
|---|---|---|
| Placement ×2 (mismo usuario) | 12 vs 12 ítems, **solapamiento 50%** | ✅ saca ítems distintos cada intento |
| Checkpoint en-U1 ×2 | 10 vs 10, **solapamiento 40%** | ✅ no repite el examen |
| Orden de opciones (placement + checkpoint) | **0 ítems compartidos** cambian el orden | ❌ **no se baraja** al servir |
| Un usuario que repite el examen | ve **ítems distintos** pero **mismo orden de opciones** en los repetidos | parcial |

- **Bueno:** ningún intento repite todos los ítems; el pool por unidad (A1–B2) da 2–4× margen.
- **Malo (P1):** las opciones salen en orden fijo de BD. Como el grading es server-side no revela la
  respuesta, pero un repetidor memoriza posiciones. Barajar `options` al servir (server o cliente) lo cierra.
- **Malo (P0):** donde el pool = pick (en C1 checkpoint reading/writing=1), **el mismo ítem sale siempre**.

---

## 4) PRECISIÓN del nivel (¿distingue A1/A2/B1…?)

- **Placement (evidencia previa, `verify_placement_serious`/`4skills`, cliente real):** azar→A1 (0% B2/C1),
  persona B1 real→B1 en 66–71% (piso condicional anti-azar), persona A2→centro A1/A2. **La banda A2↔B1 es
  borrosa** (inherente a un CAT breve de 10–16 ítems con 3 opciones; el usuario tiene override "empezar
  desde cero"). Estimador `jz_placement_level` = "techo con evidencia" (nivel acreditado solo con `asked≥3
  & corr≥⌈0.72·asked⌉ & corr≥3`) + pisos anti-azar. **Sólido para lo que es** (ubicación, no certificación).
- **Per-skill del placement:** DEMOTE-only anclado al global (una skill baja 1 con ≥3 ítems y acc≤0.5;
  nunca promueve). Con **listening 3/nivel y speaking 2/nivel** hay **poca evidencia por skill** → el perfil
  por-habilidad es de baja resolución (bien para "flojo en listening", no para graduar finamente).
- **Examen de nivel (en A1–B2):** 20 ítems (6R/6W/4L/4S), umbral 0.80 por sección + `jz_skill_mastery≥0.80`.
  **Pool sano (A1–B2) → distingue bien** y la doble condición (sección + mastery) evita aprobar por suerte.
  **Riesgo:** solo 4 ítems por sección L/S → una sección de 4 con 0.80 = 4/4 o 3/4; poca granularidad, pero
  respaldada por el mastery acumulado. **Aceptable.**
- **Riesgo estructural (P0):** el **nivel mostrado** (`user_skill_levels.cefr_level`) NO es el que mide el
  examen — sube por puntos de grind. Un usuario puede ver "B2 reading" en el radar con `jz_skill_mastery`
  B2 ≈ 0. **El número que ve el usuario y el que certifica no son el mismo.**

---

## 5) SUBIDA de nivel por habilidad con el uso normal

- **Mecánica:** lecciones y checkpoints suman 12/acierto + 4/stub a `progress_points` por skill; 100 →
  +1 CEFR. **Independiente del nivel del contenido** → inflable con repetición de lecciones fáciles.
- **Coherencia con la regla de certificación:** **NO del todo.** El certificado exige las 4 skills al
  nivel N vía examen (mastery real); el `cefr_level` del radar puede ir muy por delante. Convendría que el
  nivel MOSTRADO refleje `jz_skill_mastery` (o al menos capar el `cefr_level` por el nivel de contenido
  realmente practicado), para que "tu radar" y "lo que puedes certificar" cuenten la misma historia.
- **Speaking sube lentísimo** (solo 4/stub) → coherente con que es participación, pero desincentiva.

---

## Lista priorizada de mejoras (P0/P1/P2)

### P0 — corregir antes de "mejorar la evaluación"
1. **Checkpoints C1 (en) casi vacíos por skill** (unidad25: R1/W1). **Taggear `unidadN` los ítems C1 ya
   existentes** (252/299 sin tag) o sembrar el pool de checkpoint C1 a ≥3R/3W/2L/2S ×2. Sin esto, el
   checkpoint C1 no mide reading/writing y repite el mismo ítem. **Esfuerzo: M** (re-tag por SQL si el
   contenido ya existe; verificar cadena C1).
2. ✅ **RESUELTO (mig 141/142, 2026-07-10) — Nivel mostrado == nivel certificable.** El `cefr_level`
   mostrado ya NO sube por GRIND: `complete_lesson`/`submit_checkpoint` fijan
   `cefr_level = greatest(cefr_level, jz_displayed_level(uid,curso,skill))`, y `jz_displayed_level` = el
   nivel MÁS ALTO con `jz_skill_mastery ≥ 0.80` (misma barra que el certificado) → para MOSTRAR B1 hay que
   DOMINAR ítems B1. Los `progress_points` (0–100) siguen para el progreso VISUAL dentro del nivel (la
   subida por lecciones sigue gratificante); el CEFR viene del dominio. Además se **revivió el pipeline
   muerto** (`jz_record_item` no se llamaba desde ningún RPC del loop → 0 evidencia real): ahora
   complete_lesson/checkpoint/examen registran cada ítem en `user_item_attempts`. **Cobertura corregida
   (mig 142):** el denominador de `jz_skill_mastery` = ítems ALCANZABLES por lecciones del nivel (antes todo
   el banco → dominar todas las lecciones capaba <0.80, certificación imposible). **Migración de existentes:**
   `cefr_level = greatest(nivel del plan/placement, jz_displayed_level)` — el grind inflado baja al dominio
   real, el placement (test adaptativo = señal de dominio) y los exámenes/certs se preservan; **108/108 filas
   coherentes, 0 rompen progreso/XP**. Verificado cliente real (`verify_level_unification.py`): grind de A1 →
   radar A1 (no infla); dominar B1 → radar B1 == certificable; radar y jz_skill_mastery ya no divergen.
3. **Certificación solo en inglés, tope B2.** Decisión de producto explícita: pt/fr/it/de/nl **no certifican
   nada** hoy. Si el certificado es "el diferenciador", falta el examen de nivel (tabla `exams` tipo `level`
   + pool `unidad%`) para los otros 5 cursos y elevar el tope. **Esfuerzo: L** (por curso; C1/C2 requieren
   evaluación de producción = Fase 2 IA — mantener tope honesto).

### P1 — precisión / anti-trampa / honestidad
4. **Barajar `options` al servir** (checkpoint/examen/placement) — server-side (`order by random()` sobre
   el array) o cliente. Cierra la memorización de posiciones del repetidor. **Esfuerzo: S.**
5. **Placement L/S delgado** (listening 3/nivel, speaking 2/nivel): subir a ≥5L/≥3S por nivel×curso para
   más evidencia y variedad → per-skill del placement con mejor resolución. **Esfuerzo: M** (autor nativo +
   audio, pipeline ya existe: `gen_placement_ls.py`).
6. **Speaking del examen solo mide participación.** Al menos calificar la lectura por `speechMatchRatio`
   (ya existe en cliente) server-side, o comunicar honesto que speaking = "leíste en voz alta", no destreza.
   **Esfuerzo: M** (cliente ya transcribe; falta puntuar la transcripción en el examen, no solo no-vacío).

### P2 — pulido / cobertura
7. **Comprensión más profunda en reading/listening** (inferencia, textos/audios más largos) — hoy es
   comprensión de frase. **Esfuerzo: L** (autoría).
8. **Listening con audio natural** (hoy TTS) para acentos/velocidad reales — mejora validez del listening.
   **Esfuerzo: L** (locución/licencia).
9. **Densificar fr/it/de/nl y pt B2/C1** (densidad base 114/nivel) para que sus checkpoints tengan el mismo
   margen de no-repetición que en A1–B2. **Esfuerzo: L.**
10. **Writing con producción libre** (evaluada) = Fase 2 (IA). Documentado como techo honesto.

---

## Punteros
- RPC clave: `jz_placement_level`, `placement_next`, `start_checkpoint`/`submit_checkpoint`,
  `start_level_exam`/`submit_level_exam`, `complete_lesson`, `jz_grade`/`jz_near_match`,
  `jz_skill_mastery`, `jz_resolve_exam_level`.
- Verificadores existentes: `tools/content/verify_placement_serious.py`, `verify_placement_4skills.py`,
  `verify_estimator.py`, `audit_placement_bank.py`.
- Contexto: CLAUDE.md (secciones PLACEMENT, C1 techo honesto), EFICACIA_CONTENIDO.md, FINDINGS.md.
