# Jezici — Diseño del currículo C1 (es→en) · DISEÑO-PRIMERO

> C1 = dominio operativo eficaz. El salto B2→C1 NO es "más gramática" sino **matiz,
> registro, inferencia, colocación, idiom y argumentación**. Ítems no triviales.
> Construido con la misma metodología que A1–B2 (autor-profesor → revisión → verificación
> adversarial → validador determinista). Curso es→en (course …001), unidades 25–30,
> ids `c5NNNNNN` / vocab `b5bNNNNN`, dificultad 0.62–0.92.

## ⚠️ Techo determinista y decisión de certificado (HONESTO)
- **Reading / Listening / Vocabulario / Gramática a C1 se autocalifican bien** (opción única
  correcta, cloze con `accepted` exhaustivo, inferencia con distractor inequívoco).
- **Writing / Speaking a C1 NO se evalúan rigurosamente sin IA.** Usamos los proxies de Fase 1
  (escritura guiada = traducción con tolerancia estricta; speaking = leer en voz alta), que
  **NO sostienen un certificado C1 de 4 habilidades**.
- **DECISIÓN:** se siembra C1 como **contenido aprendible** (lecciones + checkpoints, 4
  habilidades) pero **NO se habilita examen de nivel ni certificado C1**. Defensa en
  profundidad (DB, todo live):
  1. Los ítems de lección C1 se taguean `c1_unidadN` (no `unidad%`) y los checkpoints
     `cp_unidadN` → quedan **fuera del pool del examen de nivel** (`start_level_exam` filtra
     `tags like 'unidad%'`). El pool C1 sale **vacío**.
  2. **mig 064** tope el motor de examen en B2: `jz_resolve_exam_level` nunca apunta a C1/C2
     (si el nivel mínimo de skills es C1/C2 → devuelve B2), y `jz_level_status` retorna
     `unlocked=false` para C1/C2. Como `start_level_exam` **y** `submit_level_exam` compuertan
     con `->>'unlocked'`, **ambos rechazan C1 con `level exam locked`** — aun para un usuario
     plenamente elegible (6/6 checkpoints C1, 4 skills al tope). Ni el flujo normal ni un atajo
     RPC crafteado pueden acuñar JZC-C1 (verificado: `verify_c1_cap.py`).
  La progresión intra-C1 la gatean los **checkpoints** de unidad (≥80%, autocalificados).
  C1 queda **"en progreso"**.
- **Para Gian (Fase 2):** cuando haya evaluación real de writing/speaking (IA/humano), habilitar
  el examen + cert C1: retaguear ítems a `unidad%`, ampliar el rango de `jz_resolve_exam_level`
  y `jz_level_status` a C1, y crear el exam id `…0000c1`.

## Tipos de ejercicio (apropiados a C1, todos AUTO-calificables)
- **Inferencia lectora** (multiple_choice): el `prompt` trae un texto corto; la pregunta exige
  leer entre líneas / deducir actitud, implicación o significado en contexto.
- **Cloze inferencial / colocación** (cloze): hueco que exige la colocación o el conector exacto
  (no cualquier sinónimo); `accepted` solo lo correcto.
- **Matiz léxico** (multiple_choice): elegir el near-synonym con la connotación/registro correctos.
- **Reordenar argumento** (reorder): ordenar una oración compleja o una secuencia de cláusulas de
  un argumento (concesión → tesis → evidencia).
- **Escritura guiada** (translation): traducir es→en con estructura C1 (inversión, nominalización,
  hedging); `accepted` exhaustivo de variantes válidas.
- **Registro / idiom** (match, word_bank): emparejar idiom↔significado, formal↔coloquial; armar
  expresión fija.
- **Listening** (listening): frases auténticas más largas con matiz; elegir lo oído.
- **Speaking** (speaking_read_aloud): leer en voz alta enunciados C1 (proxy de participación).

## Unidades (25–30)
| # | Unidad | Foco C1 (función + lengua) |
|---|---|---|
| 25 | **Precisión y matiz** | near-synonyms y connotación, colocaciones fuertes, hedging/atenuación (rather, somewhat, arguably), registro formal vs coloquial |
| 26 | **Argumentar y persuadir** | conectores de argumentación (nevertheless, furthermore, granted, albeit, notwithstanding, hence), concesión y refutación, estructurar una postura |
| 27 | **Lo no dicho: énfasis e inferencia** | inversión enfática (Not only…, Rarely…, Hardly…), cleft (It was X that…, What I need is…), inferencia de actitud/implicación |
| 28 | **Idiom y registro** | phrasal verbs avanzados, idioms y expresiones fijas, understatement/ironía, formal↔coloquial, eufemismo |
| 29 | **Hipótesis y modalidad avanzada** | condicionales con inversión (Had I known…, Were I to…), condicionales mixtos, matiz modal (might well, could have, may as well, would rather, needn't have) |
| 30 | **Lenguaje académico y profesional** | nominalización, voz pasiva formal, reporting verbs (assert, contend, acknowledge, concede), cohesión y qualificación |

Cada unidad: **4 lecciones × 8 ítems** (cobertura 4 habilidades: reading≥10, writing≥10,
listening=4, speaking=4) + **checkpoint FRESCO de 10 ítems** (≥2 por habilidad, tag `cp_unidadN`,
fuera del examen) + 16 palabras de vocabulario C1. Dificultad 0.62–0.92.

## Placement C1
El test de ubicación corta hoy en B2. Se añaden ítems C1 (tag `placement`, cefr C1) de
reading/grammar para discriminar usuarios avanzados. (Si el motor de placement no los toma
automáticamente, se reporta el ajuste exacto.)

## Verificación (todo ejecutado, 2026-06-23)
- Validador determinista (`content_qa.py c1`) = **0 hallazgos** en es→en C1.
- `verify_chain.py` es→en sigue **A1→B2 PASS** (certs topan en B2; C1 sin examen por diseño).
- Cliente real (`verify_c1_cap.py`): un usuario **plenamente elegible** para C1 (6/6 checkpoints,
  4 skills listos) **NO** puede formar/aprobar examen C1 ni obtener JZC-C1; `level_exam_status()`
  topa en B2; `start`/`submit` con `p_level='C1'` → `level exam locked`; 0 certs C1.
- C1 jugable: `grade_item` califica ítems C1 server-side (correcto/incorrecto). B2 (u.19–24) → C1 (u.25–30).
- **Audio TTS C1 67/67** subido a Storage (HEAD 200) — mismo pipeline (`gen_audio_missing.py en-c1`).
- **Sembrado:** 192 ítems de lección + 60 de checkpoint fresco = **252** (mig 063). Tope: **mig 064**.
- **Placement C1:** 4 ítems C1 añadidos al test (frontend `placement_test.dart`, clamp 0..4) →
  **deploy-pending** (Vercel bloqueado). El resto (contenido, examen-tope, audio) ya está LIVE.
