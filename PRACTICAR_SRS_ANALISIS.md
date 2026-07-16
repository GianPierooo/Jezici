# PRACTICAR_SRS_ANALISIS.md

> Análisis técnico para llevar un **motor SRS serio** (estilo Anki) al apartado **Practicar**, en los 6
> idiomas. Responde la §5 de `PRACTICAR_SRS_SPEC.md` **contra la BD real**. **Solo lectura — cero código.**
> Ground truth: introspección de la BD de producción (definiciones de RPC + censo de contenido con SQL),
> no los docs. Fecha: **2026-07-16**.

---

## 0. El titular (léelo aunque no leas el resto)

**La premisa central del spec es falsa, y eso cambia todo el presupuesto.**

El spec dice (§2.2): *"Reusar la infraestructura `cloze` de `content_items` que ya existe"*, y de ahí deduce
que el trabajo es *"(a) reemplazar el algoritmo, (b) cambiar el modo de repaso, (c) asegurar cobertura"*.

Medido contra la BD: **los cloze que existen enseñan GRAMÁTICA, no vocabulario.** Sus respuestas son `am`,
`Thank`, `the`… Cruzando las ~480 palabras de cada curso contra los cloze existentes, **las tarjetas
cloze-de-vocabulario listas para usar HOY son**:

| idioma | tarjetas cloze listas | vocabulario total | % |
|---|---:|---:|---:|
| **en** | **58** | 468 | 12.4% |
| **pt** | **54** | 479 | 11.3% |
| **nl** | **39** | 480 | 8.1% |
| **de** | **28** | 481 | 5.8% |
| **it** | **17** | 480 | 3.5% |
| **fr** | **8** | 480 | **1.7%** |

> **El contenido del P0 del spec no existe.** Para francés hay **8 tarjetas**. Construir el motor FSRS más
> elegante del mundo sobre 8 tarjetas no es un producto.

**Consecuencia:** el trabajo NO se reparte como sugiere el spec. El motor son ~3 días; el **contenido son
~15-20 días** (≈2.880 oraciones nativas + su audio). La pregunta real no es *"FSRS o SM-2"* — es **"¿estás
dispuesto a financiar 2.880 oraciones de calidad nativa?"**.

**Mi recomendación es evitar esa factura por ahora** desacoplando motor y contenido (§6): un P0 que sirve
**recuerdo activo escrito** con lo que YA existe (palabra↔traducción), en los 6 idiomas, en ~1 semana — y
que **mejora sola a cloze-en-oración** a medida que llegue el banco de oraciones, idioma por idioma.

---

## 1. PASO 0 — Respuestas a la §5 del spec (contra la BD real)

### 1.1 ¿Qué algoritmo usa HOY y cómo se llena `user_vocab_srs`?

**El motor (en `submit_practice(p_mode='srs')`):**

- **Escalera fija por `strength`**, no un SRS adaptativo:
  `strength` 0→**1 día**, 1→**2**, 2→**4**, 3→**8**, 4→**16**, 5→**30**.
- **Calificación binaria**: acierto → `strength+1` (tope 5); fallo → **`strength = 0`** (vuelve al día 1).
- **La columna `ease` (default 2.5) NUNCA se escribe.** Es forma de SM-2 vestigial: la tabla *parece* SM-2
  pero el código no usa `ease` jamás. Igual `interval_days` se recalcula de la escalera, no se acumula.

**El modo de repaso (en `start_practice(p_mode='srs')`) — aquí está el problema de producto:**

- Sirve **`multiple_choice`**: *"¿Cómo se dice «gato»?"* + 4 opciones (la correcta + 3 palabras al azar del
  curso). **Es reconocimiento pasivo, exactamente el anti-feature que el spec prohíbe** (§4).
- **La palabra va SUELTA, sin oración.** No hay contexto, no hay audio.
- La cola: `where s.vocab_id is null or s.due_at is null or s.due_at <= now()` ordenada por
  `(s.vocab_id is not null), due_at, frequency_rank` limit 12. **Ojo:** `s.vocab_id is null` significa
  **"toda palabra del curso que el usuario nunca ha visto cuenta como vencida"** → la cola nunca está vacía
  porque incluye las ~480 del curso. (Es la raíz del bug de "Practicar miente a cero" que ya se corrigió en
  el cliente, pero **el servidor sigue igual**.)
- Detalle útil: `submit_practice` **ya califica por texto normalizado** contra `word`
  (`jz_normalize(ans) = jz_normalize(word)`). **El servidor ya acepta escritura**; solo el ítem servido es MC.
  Cambiar a escritura es más barato de lo que parece.

**RPCs que lo operan:** `start_practice` (sirve), `submit_practice` (califica + reprograma + paga),
`srs_prioritize_failed` (inscribe). Tocan la tabla además `jz_reinforce_score`, `evaluate_achievements`,
`export_my_data`.

**Veredicto:** de "SRS" solo tiene la tabla. Es un **quiz de opción múltiple con escalera fija**. El spec
tiene razón en que hay que reemplazarlo.

### 1.2 ¿`complete_lesson` alimenta el SRS? — **NO. Confirmado.**

`complete_lesson` (167 líneas) **no menciona `user_vocab_srs` ni `vocabulary`** ni una sola vez. Escribe
`user_lesson_progress`, `user_stats`, `user_skill_levels`, `user_course_progress` — nada de SRS.

**El único camino de inscripción es `srs_prioritize_failed`**, que se llama tras una lección **solo con los
ítems FALLADOS**, y funciona así: toma el texto de `correct_answer->>'value'` del ítem fallado y **busca por
substring** qué palabras del `vocabulary` del curso aparecen dentro; las inserta con `due_at = now()`.

> **La consecuencia es fuerte: hoy el SRS solo contiene palabras que FALLASTE.** Si haces una lección
> perfecta, tu agenda de repaso no crece ni una palabra. Es lo contrario de un SRS.

**Y aquí está el hallazgo estructural que el spec no anticipa:**

> **`vocabulary` es una ISLA.** La única tabla que la referencia es `user_vocab_srs`. **No existe ningún
> vínculo entre vocabulario y lecciones/unidades/`content_items`**: no hay `lesson_vocab`, ni
> `vocabulary.unit_id`, ni `vocabulary.cefr_level`. Solo `word`, `translation`, `frequency_rank`,
> `part_of_speech`, `course_id`.

**Por tanto "conectar `complete_lesson` → SRS" no es añadir una línea: es que no existe el dato de qué
palabras enseña una lección.** Hay dos caminos (§4):

- **(a) Barato — reusar el hack de substring** que ya usa `srs_prioritize_failed`, pero sobre **todos** los
  ítems de la lección (no solo los fallados). Cero contenido nuevo, se puede hacer ya. Impreciso pero real.
- **(b) Correcto — construir el vínculo que falta** (`lesson_vocab`), derivándolo por substring y
  **revisándolo con nativo**. Es la base sólida, y de paso da el orden de introducción por unidad.

### 1.3 COBERTURA DE CONTENIDO (la pregunta que define el costo)

**Vocabulario — la buena noticia: los 6 idiomas están equilibrados y ordenados.**

| idioma | palabras | con `frequency_rank` |
|---|---:|---:|
| de | 481 | 481 (100%) |
| fr / it / nl | 480 | 480 (100%) |
| pt | 479 | 479 (100%) |
| en | 468 | 468 (100%) |
| **total** | **2.868** | **100%** |

El requisito del spec de *"introducir por `frequency_rank`"* **está soportado hoy, en los 6, sin trabajo**.

**Oraciones — la mala noticia.** `vocabulary` **no tiene columna de oración-ejemplo**. Las oraciones tendrían
que venir de `content_items`. Censo:

**(A) Cloze cuya respuesta ES la palabra de vocabulario = tarjetas listas para usar HOY:**

| en | pt | nl | de | it | fr |
|---:|---:|---:|---:|---:|---:|
| **58** | **54** | **39** | **28** | **17** | **8** |

**(B) Límite superior optimista** — la palabra **aparece** dentro de *alguna* oración en idioma meta
(`payload.text` / `payload.say`) de *cualquier* tipo de ítem:

| idioma | vocab en alguna oración | total | % |
|---|---:|---:|---:|
| en | 257 | 468 | **54.9%** |
| pt | 189 | 479 | **39.5%** |
| nl | 134 | 480 | **27.9%** |
| de | 122 | 481 | **25.4%** |
| it | 110 | 480 | **22.9%** |
| fr | 86 | 480 | **17.9%** |

**Cómo leer (B) con honestidad:** ese 17.9–54.9% es un **techo teórico, no contenido usable**. Esas oraciones
se escribieron para enseñar **otro** punto (una unidad de *Konjunktiv II*, un listening de A2). Convertirlas
en cloze de vocabulario significaría **borrar una palabra cualquiera de una oración diseñada para otra cosa**
— a menudo pedagógicamente absurdo (blanquear *"the"* de una frase que enseña *present perfect*). En la
práctica, **el contenido usable real está mucho más cerca de (A) que de (B)**.

**Total cloze existentes** (para contexto): en 162, pt 153, it 80, nl 75, fr 74, de 72 = **616**. Es decir:
la mayoría de los 616 cloze **no** son de vocabulario.

**Conclusión de cobertura — el número que importa:**

> Para dar el P0 del spec (cloze-en-oración sobre el vocabulario que enseña cada curso) en los 6 idiomas
> hacen falta **~2.880 oraciones nuevas de calidad nativa** (480 × 6), **menos las ~204 que ya existen**
> → **~2.660 oraciones por autorar** + su audio. **Ningún idioma tiene cobertura suficiente. Francés es
> crítico (8 tarjetas).**

### 1.4 ¿El TTS cubre esas oraciones en los 6 idiomas?

**El pipeline sí; el contenido no.**

- Hay **1.776 audios** en Storage (en 478, pt 392, it 236, de 224, nl 224, fr 222), pero **todos cuelgan de
  `content_items` de listening**. **`vocabulary` no tiene columna de audio** — cero audio de vocabulario.
- El pipeline `gen_audio_missing.py` está **probado en los 6 idiomas** con el `tl` correcto y verificación
  HEAD 200 (histórico: 476 + 170 + 172 clips generados sin incidentes).

**Traducción:** el TTS **no es un riesgo, es una línea de costo conocida**. Si se autoran ~2.660 oraciones,
se generan ~2.660 clips con el pipeline existente (≈1 día por idioma, mecánico). **Pero no hay atajo: audio
nuevo requiere oración nueva.** El audio no puede ir por delante del contenido.

### 1.5 ¿Cómo integrar los 4 botones con XP/oro/racha sin romper nada?

**Buena noticia: la integración YA existe y ya respeta el principio del spec.** `submit_practice` hoy:

- `v_xp := least(v_correct * 3, 20)` · `v_gold := case when v_correct > 0 then 2 else 0 end`
- Escribe `user_stats` + `user_course_progress`, registra `gold_transactions(reason='challenge')`
- Llama **`jz_register_activity(uid, course, xp)`** → que alimenta `daily_goals` (meta diaria) y `streaks`
  (racha, hitos 7/30/100/365 con bonus).

Comparado con `complete_lesson`: `round(xp_reward * accuracy) + combo_bonus`, oro **5** (o **10** si
accuracy ≥ 0.8). **Es decir: la práctica ya paga menos que una lección** (XP tope 20 y oro 2 vs oro 5-10).
El principio de diseño que el spec pide (§2.5) **ya está implementado**.

**Cómo encajan los 4 botones sin duplicar:**

1. **Separar calificación de recompensa.** El botón (`Otra vez/Difícil/Bien/Fácil`) alimenta **solo al
   scheduler**. El pago sigue saliendo de **una sola llamada por sesión** a `submit_practice` — que ya es el
   único sitio que paga. **Si se paga por tarjeta, se rompe la economía** (una sesión de 30 tarjetas pagaría
   15× una lección).
2. **El tope `least(..., 20)` es el cortafuegos** y debe quedarse: acota el farmeo aunque la cola sea larga.
3. **Regla anti-duplicado:** una tarjeta **relapsada** que reaparece en la misma sesión (el spec §2.1 pide que
   las falladas vuelvan) **no debe volver a contar** para `v_correct`. Si no, fallar-y-acertar paga más que
   acertar a la primera — un incentivo perverso.
4. **Mapeo honesto de los 4 botones a "correcto":** `Otra vez` = fallo; `Difícil/Bien/Fácil` = acierto. El
   botón modula el **intervalo**, no el pago.
5. **La racha/meta no se tocan**: `jz_register_activity` ya recibe el XP y hace el resto. Cero cambios.

**Riesgo real de romper algo: BAJO.** Es el único frente del spec que casi no tiene deuda.

---

## 2. Diagnóstico: qué sirve y qué hay que cambiar

| Pieza | Estado | Acción |
|---|---|---|
| Tabla `user_vocab_srs` | Forma SM-2 a medias; `ease` vestigial, sin `stability`/`difficulty`/`lapses`/`state` | **Ampliar** (no recrear) |
| Escalera fija de intervalos | Funciona, pero no es adaptativa ni recuerda dificultad | **Reemplazar** por FSRS |
| Calificación binaria | Pierde la señal del esfuerzo | **Reemplazar** por 4 botones |
| Modo MC "¿cómo se dice X?" | **Anti-feature** (reconocimiento) | **Reemplazar** por escritura |
| Cola incluye palabras nunca vistas | Bug conceptual: "nuevas" = las 480 del curso | **Arreglar**: solo lo inscrito + límite de nuevas/día |
| `submit_practice` grading por `jz_normalize` | **Ya sirve para escritura** | **Conservar** |
| Economía (XP/oro/racha/meta) | **Ya integrada y ya paga menos que una lección** | **No tocar** |
| `frequency_rank` en los 6 | **Completo (100%)** | **No tocar** |
| Pipeline TTS 6 idiomas | **Probado** | **Reusar** |
| `vocabulary` ↔ lecciones | **NO EXISTE** | **Construir** (§4) |
| Banco de oraciones | **1.7%–12.4%** | **Autorar** (§5) |
| Todo server-side por RPC | Ya es la norma de la casa | **Conservar** |

---

## 3. FSRS vs SM-2 para ESTE stack (Postgres + Dart)

**Recomendación: FSRS con parámetros por defecto, implementado en plpgsql server-side. Sin optimizador.**

**Por qué FSRS y no SM-2:**

1. **En SQL, el coste de código es casi el mismo.** El *scheduler* de FSRS (modelo DSR: estabilidad,
   dificultad, recuperabilidad + curva de olvido potencial) son ~30-40 líneas de aritmética. SM-2 son ~15.
   La diferencia es trivial comparada con el resto de la misión.
2. **SM-2 tiene un defecto conocido y documentado ("ease hell")**: fallar hunde el `ease` y la tarjeta queda
   atrapada en intervalos cortos para siempre. **El motor actual ya sufre una versión peor** (fallo →
   `strength = 0` → vuelta al día 1, tirando todo el historial). Migrar a SM-2 es cambiar un mal esquema
   por uno menos malo.
3. **Portabilidad**: FSRS es aritmética pura (potencias y sumas). **No necesita nada que Postgres no tenga.**
   No hay dependencia externa, no hay extensión, no hay servicio.
4. **Es el estándar de facto** (lo adoptó Anki). Alinea con "estilo Anki" del spec sin inventar nada.

**Por qué NO el optimizador de FSRS (y esto es lo importante):**

El poder de FSRS viene de **ajustar sus ~17-21 parámetros al historial real** de cada usuario — y eso **sí**
requiere una tubería de ML (no cabe en plpgsql). **Pero:**

- **Jezici tiene 0 usuarios ahora mismo** (reseteo total de esta semana). **No hay historial que optimizar.**
- El propio Anki **envía parámetros por defecto** y recomienda optimizar solo **tras ~1.000 reviews**.

> **Conclusión honesta: implementar FSRS con los parámetros por defecto da ~90% del beneficio con ~10% del
> trabajo.** El optimizador es una decisión para dentro de un año, cuando exista historial. Diseñar el
> esquema *para poder* optimizar luego (guardar `review_log`) es barato **hoy** y caro de retrofitear después.

**Lo que el esquema necesita:**

- `user_vocab_srs` += `stability` (numeric), `difficulty` (numeric), `state` (new/learning/review/relearning),
  `reps`, `lapses`, `last_rating`, `scheduled_days`. Las columnas `ease`/`strength` quedan **vestigiales**
  (no borrarlas en la misma migración: primero dejar de escribirlas, borrar después).
- **`srs_review_log` (nueva)**: `user_id, vocab_id, rating, state, elapsed_days, scheduled_days, reviewed_at`.
  Es **el requisito para (a) la métrica de retención que pide el spec §2.6 y (b) el optimizador futuro**. Sin
  ella, la retención no se puede calcular. **Es la pieza que más cara sale de añadir tarde.**
- Parámetros en **`jz_config`** — que es `key + value_int`, **encaja directo** para `srs_new_per_day = 15`,
  `srs_max_reviews_per_day`, `srs_target_retention_pct = 90`. (Los 17 pesos de FSRS **no** caben en
  `value_int`; van como constantes en la función o requieren una tabla propia — decisión menor.)

**Lo que va en Dart: NADA de scheduling.** El cliente pinta la tarjeta, manda el rating y muestra lo que el
servidor devuelve. Coherente con la regla de la casa (nada sensible en el cliente).

---

## 4. El plan para conectar `complete_lesson` → SRS

Recordatorio del hallazgo: **no existe el dato "qué palabras enseña esta lección"**.

**Paso 1 (barato, desbloquea ya): inscripción por substring, extendida.**
Reusar exactamente la mecánica **ya probada** de `srs_prioritize_failed`, pero disparada desde
`complete_lesson` sobre **todos** los ítems de la lección:
- Palabra **acertada/vista** → se inscribe como **nueva** (`state='new'`, entra a la cola según límite/día).
- Palabra **fallada** → mantiene el comportamiento actual (`due = now`, prioridad).
- **Best-effort** (como hoy): si falla, no tumba el fin de lección.

*Ventajas:* cero contenido nuevo, 6 idiomas de golpe, patrón ya validado en producción.
*Límite honesto:* el substring es impreciso (no lematiza: *"gatos"* no casa con *"gato"*; conjugaciones y
compuestos alemanes fallan). **Inscribirá de menos, nunca de más** — es un error seguro (falta cobertura, no
inscribe basura).

**Paso 2 (correcto, cuando haya presupuesto): la tabla `lesson_vocab` que falta.**
- Generarla **derivándola** por substring de los ítems de cada lección → **revisión nativa** (el mismo
  workflow de 6 autores + revisor adversarial que ya se usó 15 veces).
- Da además: orden de introducción por unidad, y la posibilidad de "esta unidad te enseñó estas 12 palabras".
- **Es el prerrequisito natural del banco de oraciones** (§5): quien escribe la oración de una palabra ya
  sabe en qué unidad vive.

**Guardarraíl:** `complete_lesson` es el corazón del loop y su regresión es cara. La inscripción debe ir
**después** de todo lo que ya hace y **envuelta en best-effort**, nunca antes. Verificación obligatoria:
`verify_chain.py` (en) + `verify_pt_chain.py` — la cadena A1→B2 debe seguir verde.

---

## 5. Cobertura: qué idiomas necesitan generación (con números)

**Todos.** Para cerrar el P0 tal como lo pide el spec:

| idioma | listas hoy | a autorar (~480) | audio nuevo | prioridad |
|---|---:|---:|---:|---|
| en | 58 | **~410** | ~410 | media (mejor punto de partida) |
| pt | 54 | **~425** | ~425 | media |
| nl | 39 | ~441 | ~441 | baja |
| de | 28 | ~453 | ~453 | baja |
| it | 17 | ~463 | ~463 | baja |
| **fr** | **8** | **~472** | ~472 | **crítica** |
| **total** | **204** | **~2.664** | **~2.664** | |

**Coste realista** (con el pipeline probado del proyecto: 6 profesores nativos IA + revisor adversarial):
la referencia histórica es **114 ítems por nivel/idioma ≈ 1 sesión larga**. **~480 oraciones por idioma
≈ 2-3 días** por idioma → **12-18 días para los 6**, + **~1 día/idioma de TTS**.

> **Ese es el verdadero presupuesto del spec: ~15-20 días de contenido frente a ~3 días de motor.**

**Y un techo que hay que nombrar:** **480 palabras por curso es poco para un SRS serio.** A los 15 nuevos/día
que propone el spec, **el mazo se agota en ~32 días**. Un SRS es un producto de *años*; un B2 real necesita
~4.000-5.000 palabras y un C1 ~8.000. **El `vocabulary` actual es una semilla, no un léxico.** Si Practicar
va a ser un pilar del producto, en algún momento hay que decidir si se amplía el léxico — otra factura, mayor
que ésta. No es bloqueante para el P0, pero condiciona la promesa.

---

## 6. Recomendación estratégica: **desacoplar motor y contenido**

Aquí es donde discrepo del orden del spec (§7), y es mi recomendación principal.

El spec propone: *"P0 motor + cloze escrito + audio + conexión SRS en 1-2 idiomas → extender a los 6"*.
El problema: **atar el P0 al cloze-en-oración hace que el P0 dependa de las ~2.664 oraciones**. Con eso, no
hay mejora visible hasta dentro de ~3 semanas, y **francés no llega hasta el final**.

**Propuesta: que el tipo de tarjeta DEGRADE CON GRACIA según la cobertura.**

```
¿La palabra tiene oración-ejemplo?
  SÍ  → cloze en oración + audio  (el ideal del spec)
  NO  → recuerdo activo ESCRITO: "gato" → [escribe la palabra en el idioma meta]
        (sin oración, pero con recuerdo activo REAL — no MC)
```

Lo que gana:
- **El motor se envía a los 6 idiomas en ~1 semana**, sin esperar contenido.
- **Ya es una mejora enorme** frente a hoy: sustituye reconocimiento MC por **producción escrita**, con FSRS
  real y una cola honesta. Eso solo es la mayor parte del beneficio pedagógico.
- **El contenido mejora el producto de forma incremental y visible**: cada tanda de oraciones convierte
  tarjetas de "palabra" en "cloze+audio", idioma por idioma, **sin tocar el motor**.
- **Empieza por en/pt** (la mejor cobertura y donde están los `verify_*.py` más rodados), y **fr** se beneficia
  del motor desde el día 1 aunque su banco llegue el último.

Honestidad sobre el trade-off: la tarjeta "traducción → escribir palabra" **no tiene contexto**, y el spec
tiene razón en que el contexto importa (§1.4). **No es el destino, es el escalón**: es *recuerdo activo* (lo
que el spec exige) aunque no sea *en chunk* (lo que el spec prefiere). Es honesto llamarlo por su nombre y no
venderlo como cloze.

---

## 7. Plan incremental con esfuerzo

| Fase | Qué | Días | Idiomas | Riesgo |
|---|---|---:|---|---|
| **F0** | **Cola honesta + conexión + escritura** | **2-3** | **6** | **Bajo** |
| | `start_practice(srs)`: dejar de tratar las 480 del curso como "vencidas"; servir solo inscritas + límite `srs_new_per_day` (`jz_config`); **cambiar MC → escritura** (el grading ya lo soporta); `complete_lesson` inscribe por substring (best-effort) | | | |
| **F1** | **Motor FSRS server-side** | **3** | **6** | **Bajo-medio** |
| | Ampliar `user_vocab_srs` (stability/difficulty/state/lapses); **`srs_review_log` nueva**; `submit_practice` acepta `rating` 1-4; relapsadas vuelven en la sesión sin re-pagar; métrica de retención | | | |
| **F2** | **`lesson_vocab`** (el vínculo que falta) | **2-3** | 6 | Medio |
| | Derivar + revisión nativa. Mejora la precisión de F0 y habilita F3 | | | |
| **F3** | **Banco de oraciones + audio** | **2-3 /idioma** (**12-18** total) | 1 idioma por tanda | **Medio-alto** ← *el grueso* |
| | ~480 oraciones nativas/idioma + TTS. Empezar **en** o **pt**; **fr** el que más necesita | | | |
| **F4** | **P1 del spec** (audio-primero, palabras problema, dinamismo) | 3-4 | 6 | Bajo |

**Total: ~5-6 días para un SRS real en los 6 idiomas (F0+F1)** + **12-18 días de contenido (F3)** para
alcanzar el ideal del spec.

**Lo más riesgoso, por orden:**
1. **F3 — la calidad nativa de ~2.664 oraciones.** No es riesgo técnico: es volumen y control de calidad. Una
   oración mala enseña mal a un usuario real. Mitigación: el workflow probado (6 nativos + revisor
   adversarial) y **cerrar idioma por idioma** (profundidad > amplitud, regla de la casa).
2. **F0/F2 — tocar `complete_lesson`.** Es el corazón del loop. Mitigación: best-effort al final, y
   `verify_chain.py`/`verify_pt_chain.py` verdes como condición de cierre.
3. **F1 — migrar el esquema con usuarios activos.** Hoy hay **0 usuarios**: **es literalmente el mejor momento
   de la historia del proyecto para cambiar el esquema del SRS.** Si se hace después, hará falta backfill.

**Criterio de cierre de F0+F1** (adaptado del §6 del spec): un usuario de **2 idiomas** (uno romance, uno
germánico) hace una sesión con tarjetas vencidas + nuevas (con límite), **escribe** la respuesta, califica con
4 botones, ve la reprogramación, gana XP/oro, mantiene la racha, y su retención se calcula — todo verificado
con **cliente real (JWT)**, sin romper lecciones/economía/4 habilidades.

---

## 8. Honestidad: lo que del spec no compraría

1. **"Reusar la infraestructura cloze que ya existe" — no es viable como está.** Es la corrección más
   importante de este análisis: entre 8 y 58 tarjetas por idioma. Los cloze son de gramática.
2. **Atar el P0 al cloze-en-oración.** Retrasa ~3 semanas cualquier mejora y castiga a fr/it/de/nl. Ver §6.
3. **El límite de 15 nuevas/día sobre 480 palabras agota el mazo en ~32 días.** El número está bien copiado de
   Anki, pero Anki asume mazos de miles. Con el léxico actual, **el parámetro honesto es más bajo** (¿8-10?) o
   hay que asumir que el mazo es finito y decirlo en la UI.
4. **El optimizador de FSRS: no, todavía.** 0 usuarios, 0 historial. Guardar `review_log` sí; optimizar no.
5. **Lo que sí compro entero:** la crítica al MC (§4) es exacta y el motor actual es culpable; la integración
   con la economía (§2.5) es la parte más sana y casi no requiere trabajo; y dejar fuera NGSL/IELTS (§3) es
   la decisión correcta — **el equivalente sano ("alimentar el SRS con el vocabulario que cada curso ya
   enseña") es exactamente lo que la BD soporta**, con `frequency_rank` al 100% en los 6.

**Una última observación de producto, no técnica.** Hoy Practicar promete un SRS y entrega un quiz de opción
múltiple sobre palabras que el usuario nunca vio. **F0 (2-3 días) convierte esa mentira en un producto
honesto en los 6 idiomas.** Antes de gastar 18 días en oraciones, yo enviaría F0+F1 y miraría si la gente
repasa. Si nadie vuelve a Practicar con un SRS real, el banco de oraciones no lo va a arreglar.
