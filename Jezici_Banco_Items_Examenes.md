# Jezici — Banco de Ítems y Diseño de Exámenes (v0.1 borrador)

> Cómo se construyen y califican todos los exámenes, **100% determinista (sin IA)**. Operacionaliza los 6 tipos de evaluación (Especificacion §4) y la regla de **4 habilidades para certificar** (Estructura_App §8). Se apoya en `content_items` y `exam_attempts` del Modelo de Datos.

---

## 0. Principio

Un examen "se siente real" cuando hay: **banco amplio calibrado**, **aleatorización** (cada intento es distinto), **cronómetro**, **adaptatividad** y **economía de reintentos**. Todo se corrige comparando respuesta esperada vs respuesta del usuario; las únicas excepciones (speaking/writing libre) usan proxies en Fase 1 (§7).

---

## 1. Anatomía de un ítem (el banco)

Cada ítem es un `content_items` reutilizable en lecciones y exámenes:

- `skill`: reading | listening | writing | speaking
- `cefr_level`: A1…C2 (nivel objetivo del ítem)
- `type`: multiple_choice · cloze · word_bank · reorder · match · translation · listening · dictation · speaking_read_aloud · guided_writing · true_false
- `difficulty`: 0–1 (o parámetros IRT `irt_a` discriminación, `irt_b` dificultad)
- `prompt`, `payload` (jsonb: opciones, audio_url, tiles, distractores), `correct_answer` (jsonb)
- `tags`: tema/unidad, función gramatical (para diagnóstico de debilidades)

> Un buen banco inicial: **decenas de ítems por (nivel × skill)** para que la aleatorización tenga de dónde elegir.

---

## 2. Calibración

- **Por nivel:** cada ítem se etiqueta al nivel CEFR que evalúa.
- **Por dificultad:** dentro del nivel, 3 bandas (fácil/medio/difícil) o un valor continuo. Empezar a ojo y **recalibrar con datos reales** (% de acierto por ítem) — los ítems que casi todos aciertan bajan de dificultad y viceversa.
- **IRT (ideal, opcional):** `irt_b` (dificultad) e `irt_a` (discriminación) permiten estimar la habilidad del usuario con pocos ítems; es el método de los exámenes profesionales. Se puede empezar sin IRT (reglas simples) y migrar.

---

## 3. Tipos de ítem y cómo se corrigen (determinista)

| Tipo | Corrección |
|---|---|
| Opción múltiple / V-F | índice correcto |
| Cloze | texto esperado + lista de aceptados (normalizando mayúsculas/espacios) |
| Banco de palabras / Reordenar | secuencia exacta (o variantes válidas listadas) |
| Emparejar | todos los pares correctos |
| Traducción | comparación contra respuesta(s) aceptada(s) normalizada(s) |
| Comprensión auditiva | igual que opción múltiple/cloze (sobre un audio) |
| Dictado | transcripción del usuario vs texto esperado (normalizado) |
| **Speaking (leer en voz alta)** | STT → transcripción vs texto esperado, con tolerancia (ver §7) |
| **Escritura guiada** | match de patrón/estructura y palabras clave esperadas |

---

## 4. Composición de cada examen

**Test de ubicación (placement):** 12–20 ítems, **adaptativo**, mezcla de skills. Salida: nivel CEFR + estimación inicial por habilidad.

**Checkpoint de unidad (gating):** 8–12 ítems de la unidad, cronometrado, umbral **80%**. Mezcla de skills de la unidad.

**Examen de nivel (certificación):** por **secciones = habilidades**. Ej. por skill 8–12 ítems al nivel objetivo (y algunos por encima/debajo). Cronometrado, aleatorizado. **Scoring por habilidad** (§6).

**Simulacro IELTS/Cambridge (premium):** 4 secciones completas (Listening, Reading, Writing, Speaking), cronometradas, formato oficial. Listening/Reading autocorrigen; Writing/Speaking → respuesta modelo + rúbrica (Fase 1). Reporte de **banda** por sección.

---

## 5. Lógica adaptativa (placement y nivel)

**Placement (regla simple, sin IRT):**
1. Empezar en dificultad media (~A2).
2. Presentar un ítem cerca de la dificultad actual. **Acierto → sube** un escalón; **error → baja**.
3. Repetir ~12–20 ítems cubriendo las 4 skills.
4. **Converger:** el nivel donde el usuario acierta de forma consistente ≈ su nivel CEFR. Guardar también una estimación por skill.

**Con IRT (ideal):** mantener una estimación de habilidad θ; elegir el siguiente ítem que **maximiza la información** en θ; parar cuando el error estándar es bajo. Más preciso con menos ítems.

**Examen de nivel:** estructura fija por skill, con ítems al nivel objetivo ± una banda, para medir cada habilidad por separado.

---

## 6. Scoring, aprobación y la regla de 4 skills

- **Cada habilidad se puntúa por separado** (porcentaje de aciertos ponderado por dificultad en su sección).
- Una habilidad "alcanza el nivel N" si su puntaje ≥ umbral (ej. **75–80%**) en ítems de nivel N.
- **Certificación (clave):** se emite el certificado de nivel N **solo si las 4 habilidades alcanzan N**. Si falta una (ej. Speaking en A2), **no se certifica** y se devuelve "sube tu Speaking", con un refuerzo dirigido.
- El examen de nivel **actualiza `user_skill_levels`** por habilidad (no solo aprueba/reprueba en bloque).

> Esto es lo que hace el certificado creíble: mide competencia **equilibrada**, no un promedio que esconde una habilidad floja.

---

## 7. Speaking y Writing sin IA (Fase 1)

- **Speaking (leer en voz alta):** STT compara la transcripción contra el texto esperado, con **tolerancia** (normalizar, permitir variaciones menores). Evalúa "¿dijo lo correcto?", no creatividad ni fluidez. *Nota: el STT es ML, no IA generativa; si el "cero IA" es estricto, se hace vía API dedicada.*
- **Escritura guiada:** estructurada y verificable (completar, reordenar, patrones con palabras clave). Nada de ensayo libre con feedback de calidad en Fase 1.
- **Simulacros:** Writing/Speaking se entregan con **respuesta modelo + rúbrica de autoevaluación**.
- **Gancho IA (Fase 2):** se **guarda la grabación/el texto** desde Fase 1 para evaluar Speaking/Writing abierto con IA después, sin rehacer nada.

---

## 8. Aleatorización, anti-trampa y reintentos

- **Aleatorización:** cada intento extrae ítems distintos del banco (por nivel/skill/dificultad) y baraja opciones → rejugable y anti-copia.
- **Condiciones de examen:** cronómetro; en algunas secciones, sin volver atrás ni pistas.
- **Economía de reintentos:** reintentos gratis limitados; luego **espera** o **premium**. Crea tensión real y valor del aprobado.

---

## 9. Diagnóstico de debilidades → alimenta el plan

- Cada resultado actualiza un **perfil de debilidades** por skill y por función gramatical (`tags`).
- El plan y "Practicar" usan ese perfil para **recomendar la habilidad/tema más flojo** ("flojo en pasado simple", "Speaking atrás").
- Conecta con la dinámica **Equilibrar tus 4 skills**.

---

## 10. Notas de implementación

- El **motor de exámenes** es un servicio que: selecciona ítems (criterios + aleatorización/adaptatividad), corre el cronómetro, corrige determinísticamente, calcula scoring por skill, aplica la regla de certificación y dispara el certificado.
- Empezar **simple** (reglas de dificultad) y migrar a **IRT** cuando haya datos.
- Recalibrar dificultad con `% de acierto` real por ítem (analítica desde el día uno).
- Banco amplio = clave para que no se repitan preguntas; priorizar volumen de ítems por (nivel × skill).
