# APRENDIZAJE_ANALISIS.md — cómo se aprende en Jezici (Practicar + la pregunta "Estudiar")

> Análisis para mejorar **cómo aprende el usuario**: el apartado **Practicar** y la posibilidad de un
> apartado **"Estudiar"** (teoría/clases estructuradas). **Solo lectura, cero código, cero IA.**
> Ground truth = repo + **BD de producción real** (censo de uso con SQL, `_gt_aprendizaje.py`) + mapa de
> estructura del cliente con file:line. Fecha: **2026-07-20**.
>
> Objetivo (pedido de Gian): que el usuario aprenda bien, con buena secuencia. Este doc traza qué existe
> HOY, **cuánto se usa realmente**, y decide con criterio pedagógico — sin construir nada.

---

## 0. El titular (léelo aunque no leas el resto)

**El cuello de botella NO es el diseño de Practicar, ni la falta de un apartado "Estudiar". Es la
activación y la retención.** Los datos de producción son inequívocos (§1.B):

- **8 usuarios reales.** Lecciones completadas: **leo 31, juanflores 3, lucifreckles 2, eugenio 2, gian 1,
  y tres usuarios en 0.** Mediana ≈ **1–2 lecciones**. (A1 de inglés tiene 33 lecciones → solo **1 de 8**
  recorrió A1.)
- **La racha más larga jamás alcanzada por CUALQUIER usuario = 1 día.** Nadie ha vuelto un 2º día
  consecutivo cumpliendo su meta.
- **Practicar / el SRS tiene CERO uso.** Hay **86 palabras inscritas** en el SRS entre 5 usuarios, pero
  `srs_review_log` = **0 filas**; `revisadas = 0`; `reps = 0`. **El motor FSRS que se construyó (F0–F4,
  mig 159–161) nunca ha sido ejercido por un usuario real, ni una vez.**
- La **teoría ya existe** (192 `content_tips` de buena calidad + `get_reference` + la tarjeta
  `get_lesson_intro`), pero está **enterrada** y es **saltable**.

**Tres conclusiones que este doc defiende con datos:**

1. **La pregunta "¿hace falta un apartado Estudiar?" tiene una respuesta pedagógica clara: NO como
   apartado nuevo.** La teoría debe vivir **mejor integrada y mejor secuenciada** en el flujo que ya
   existe (tarjeta de presentación + Referencia). Un apartado nuevo **fragmenta** una app en la que 7 de 8
   usuarios abandonan antes de la 3ª lección — sería añadir superficie que nadie alcanza.
2. **VIDEO: no ahora.** Su factura (producción × 6 idiomas × niveles + re-grabación en cada cambio de
   currículo + hosting/CDN de vídeo pesado) es enorme, y su necesidad **no está probada** — nadie ha
   llegado siquiera a la teoría en texto+audio+imagen que ya se puede servir casi gratis. Se dimensiona en
   §4, no se descarta ni se vende.
3. **Lo de mayor ROI para "aprender bien" ahora mismo es barato y de EXPERIENCIA:** sacar la teoría que ya
   existe de donde está escondida, y **tejer el repaso dentro del loop** (que tras la lección el siguiente
   paso pueda ser "repasar", no solo "siguiente lección"). Lo caro (curso de gramática, banco de oraciones
   del SRS, vídeo) debe esperar a que el embudo demuestre que la gente **llega** a esas superficies.

> **La honestidad que el brief exige:** recomendar rediseñar Practicar o construir "Estudiar" sería
> **optimizar una superficie que casi nadie pisa.** El problema real está aguas arriba: llevar al usuario
> de la lección 1 a la lección 2, y del día 1 al día 2. Este análisis lo dice, y ordena las propuestas
> en consecuencia.

---

## 1. PASO 0 — los dos ground truths

### 1.A · ESTRUCTURA actual (qué ofrece hoy el aprendizaje)

**Arquitectura:** el cliente es una cáscara fina; scoring/scheduling/economía son server-side (RPC de
Supabase). El cliente elige un modo, renderiza y reenvía respuestas.

**Practicar** (`features/practice/practice_screen.dart`, tab 1) tiene **dos estados excluyentes** según
`status.hasProgress` (`:135`):

- **Estado NOVATO** (0 lecciones con progreso, `!hasProgress`): NO muestra el HERO del SRS (evitaría el
  número falso — bug P0 ya arreglado el 2026-07-13). Muestra `_SrsWelcome` (card honesta "aún no tienes
  palabras, empieza tu 1ª lección" → salta al mapa) + una rejilla "mientras tanto explora" con **Repaso** e
  **Inmersión** (lo único útil desde el día 0).
- **Estado CON PROGRESO** (`else`, `:173`): despliega las 8 secciones:

| # | Sección | Acción / RPC | Condición |
|---|---------|--------------|-----------|
| 1 | **HERO "Rescate de palabras" (SRS)** | `start_practice('srs')` → `SrsReviewScreen` (recuerdo activo **escrito**, no opción múltiple) | siempre |
| 2 | **Punto débil** | `start_practice('weakness')` | siempre; barra CEFR solo si `weak != null` |
| 3 | **Reforzar lo que fallé** | `start_practice('reinforce_unit')` | siempre |
| 4 | **Lectura** | `start_practice('skill', skill:'reading')` | rejilla 2×2 |
| 5 | **Escritura** | `start_practice('skill', skill:'writing')` | rejilla 2×2 |
| 6 | **Repaso/Referencia** | navega a `ReferenceScreen` (sin RPC) | rejilla 2×2 |
| 7 | **Inmersión/Historias** | navega a `ImmersionScreen` (sin RPC) | rejilla 2×2 |
| 8 | **Contrarreloj (90 s)** | `start_practice('timed')` | siempre |

**El SRS (cliente):** tarjeta de **recuerdo activo escrito** (`srs_review_screen.dart`) — se escribe la
respuesta antes de revelar; `cloze` en contexto si hay oración, `word` (traducción→palabra) si no. Rating
1–4 modula el intervalo (fallo fuerza rating=1). `get_srs_status` → due/nuevas/`retentionPct` (null si no
hay maduras — no inventa número). El HERO muestra el conteo de vencidas. **El SRS solo vive en la pestaña
Practicar**; el mapa (Aprender) no expone ningún conteo de repaso.

**Referencia/Repaso** (`reference_screen.dart`) — **es la capa de "teoría" que ya existe** (el propio
comentario la llama "estilo Busuu Grammar Review"): banner de punto débil + por habilidad una **barra de
% de dominio** + **tarjetas de concepto** (`_TipTile`: título → cuerpo + ejemplo con TTS). Fuente:
`get_reference`. **No tiene entrada de navegación propia** — solo se alcanza como 1 de 4 tiles dentro de
Practicar.

**Inmersión/Historias** (`immersion_screen.dart`, `story_reader_screen.dart`): historias por nivel CEFR
(input comprensible con audio) + glosario + preguntas calificadas server-side.

**Tarjeta de presentación** (`lesson_intro_view.dart`, mig 164) — el "enseñar antes de examinar": ANTES
del primer ejercicio de una lección normal, muestra **CONCEPTO** (`intro.tip`) + **VOCABULARIO** (pares del
`match`, con imagen si hay). Se carga con `get_lesson_intro`, **es saltable** y tiene un **watchdog de 3 s**
que entra directo a los ejercicios si tarda/es null/falla. **No se muestra en modo repaso.**

**Dónde vive la teoría HOY (todas las superficies de enseñanza explícita):**

| Superficie | Disparo / descubribilidad | RPC |
|---|---|---|
| Tarjeta de presentación (concepto + vocab) | En flujo, antes del 1er ejercicio; **auto pero saltable + 3 s** | `get_lesson_intro` |
| Tip post-lección (voz del coach, al punto débil) | Fin de lección; solo si el RPC devuelve algo | `get_lesson_tip` |
| **Referencia/Repaso** (conceptos + % dominio) | **Solo desde tiles de Practicar; sin entrada de nav** | `get_reference` |
| Glosario de historia | Dentro de una historia, ExpansionTile colapsado | `get_story` |
| Cuaderno (tips ya vistos) | **Solo desde el tab Perfil** — aún más enterrado | `get_notebook` |

> **Diagnóstico de descubribilidad:** la única teoría que el usuario encuentra **automáticamente** es la
> tarjeta de presentación — y es **saltable y auto-avanza a los 3 s**. La teoría "de estudio" (Referencia,
> Cuaderno) está a dos-tres toques de profundidad, sin ninguna entrada de primer nivel. **La teoría no
> falta; está escondida.**

### 1.B · USO REAL (el ground truth obligatorio — DATOS, no suposiciones)

Censo de la BD de producción, 2026-07-20 (`tools/content/_gt_aprendizaje.py`, read-only):

**Retención — la historia en una tabla:**

| usuario | alta | lecciones completadas | días con meta | racha máx | palabras SRS | **reviews SRS** |
|---|---|---:|---:|---:|---:|---:|
| leo | 07-17 | **31** | 1 | 1 | 10 | **0** |
| eugenio | 07-14 | 2 | 3 | 1 | 25 | **0** |
| juanflores | 07-17 | 3 | 1 | 1 | 20 | **0** |
| lucifreckles | 07-17 | 2 | 1 | 1 | 12 | **0** |
| aleramosa | 07-17 | 0 | 1 | 1 | 19 | **0** |
| gian | 07-13 | 1 | 1 | 1 | 0 | **0** |
| ana | 07-17 | 0 | — | 0 | 0 | **0** |
| (sin handle) | 07-17 | 0 | — | 0 | 0 | **0** |

- **8 usuarios** (7 curso inglés, 1 italiano; los 8 completaron el onboarding).
- **Distribución de lecciones completadas:** 0→3 usuarios · 1→1 · 2→2 · 3→1 · **31→1**. Es decir: **un
  único usuario (leo) aprendió de verdad;** el resto abandonó en la 1ª–3ª lección. A1 tiene 33 lecciones.
- **Racha más larga histórica = 1**, en los 8 usuarios. **Nadie ha vuelto un segundo día consecutivo.**
  (eugenio tiene 3 "días con meta" pero no consecutivos — 07-15 y 07-19 — por eso su racha sigue en 1.)
- **SRS = 0 uso absoluto.** 86 palabras inscritas (se inscriben solas al completar lección), **5 usuarios
  con palabras esperando** — y **0 sesiones de repaso en toda la historia de la app** (`srs_review_log`
  vacío, todas las palabras en estado `new`/`learning`, ninguna en `review`). **Ni siquiera leo** (31
  lecciones) ni eugenio (25 palabras esperando y 3 visitas) abrieron un repaso jamás.
- **0 intentos de checkpoint/examen** (`exam_attempts` vacío) — nadie llegó al final de una unidad.
- **0 feedback** enviado.

**Nota metodológica honesta:** `analytics_events.screen_view` **no registra el nombre de la pantalla**
(las 157 filas tienen `screen = null`), así que **no puedo medir directamente cuántos abrieron Practicar o
Referencia.** Pero el proxy es definitivo y no necesita el nombre de pantalla: **0 reviews de SRS y racha
máxima de 1** dicen que, se abriera o no la pestaña, **nadie completó una sesión de práctica ni volvió un
segundo día.** (Sub-hallazgo re-encolable, no de este análisis: instrumentar el nombre de pantalla en
`screen_view` para poder medir navegación real.)

> **Lectura honesta:** son ~8 testers explorando, no una cohorte de aprendices. Pero el patrón es
> nítido y suficiente para decidir: **el contenido de aprendizaje y el motor de repaso funcionan y están
> construidos; el problema es que la gente no llega a usarlos.** Cualquier recomendación que ignore esto
> estaría rediseñando una habitación que nadie visita.

---

## 2. La secuencia de aprendizaje de punta a punta — ¿es pedagógicamente sólida?

**El recorrido diseñado:** onboarding (12 pasos) → mapa → lección (**presentación → ejercicios →
calificación → fin+tip**) → el repaso se inscribe **en silencio** server-side → Practicar (cuando el
usuario lo descubra).

**Lo que está BIEN (no romper):**
- El **loop de lección** sigue el modelo correcto **present → practice**: desde mig 164 hay tarjeta de
  presentación antes de examinar (concepto + vocab), como Busuu.
- El **SRS es de recuerdo activo escrito** (no opción múltiple) — pedagógicamente lo correcto, y honesto
  (fuerza rating=1 si se escribe mal).
- Hay **input comprensible** (Historias) y una **capa de referencia** navegable con % de dominio.

**Dónde se ROMPE o confunde la secuencia (con file:line del §1.A):**

1. **La presentación es demasiado fácil de saltar.** Es saltable *y* auto-avanza a los 3 s
   (`lesson_player_screen.dart:141`). El "present" del present→practice se evapora si el usuario no lee
   rápido — y un principiante absoluto es justo quien más lo necesita (ver `PRINCIPIANTE_ANALISIS.md` P1
   #3). **Además no aparece en modo repaso** → rehacer una lección no da refresco de concepto.
2. **La inscripción en el SRS es INVISIBLE.** No hay un momento "te hemos añadido estas palabras a tu
   repaso". Las palabras entran en silencio; el HERO del SRS solo aparece cuando `hasProgress` cambia, en
   **otra pestaña** que el usuario quizá nunca abra. El aprendiz no tiene ningún hilo que lo lleve del "acabé
   la lección" al "ahora consolido". **Esto explica en parte los 0 reviews:** el repaso no se pide, se
   esconde y se espera a que lo encuentren.
3. **El repaso COMPITE con el avance, en vez de tejerse.** El CTA de fin de lección
   (`lesson_complete_screen.dart:357`) empuja a **"siguiente lección"** y nunca hacia el SRS/Practicar. El
   loop premia avanzar-avanzar; consolidar es un desvío que el usuario debe buscar por su cuenta.
4. **La teoría de estudio (Referencia) está aguas abajo de la práctica.** Solo se llega desde dentro de
   Practicar. Un usuario que siga el camino natural (onboarding → lecciones → mapa) **nunca es apuntado a
   ella.**

**Comparación con los referentes:**

- **Busuu — present → practice → review, en UN flujo.** La fortaleza de Busuu no es tener una pestaña de
  gramática, es que la teoría (Grammar tip) aparece **dentro** de la lección, justo antes de practicarla, y
  el review se ofrece como **el siguiente paso natural**. Jezici ya tiene las piezas (presentación +
  Referencia + SRS) pero **desacopladas** en superficies distintas. La lección de Busuu es: la secuencia
  importa más que las piezas.
- **Duolingo — un loop apretadísimo con un solo "siguiente".** Duolingo casi nunca te da a elegir: hay un
  botón grande de "continuar" y el sistema decide si toca lección nueva o repaso. Jezici, en cambio, reparte
  la decisión entre pestañas (Aprender vs Practicar) y dentro de Practicar entre 8 secciones — **más carga
  cognitiva de la que un principiante puede gestionar**, y ninguna guía de "qué hacer ahora".

**Veredicto pedagógico:** la secuencia tiene las piezas correctas pero **las presenta desacopladas y sin
guía**. No hace falta contenido nuevo para arreglar la secuencia — hace falta **coser** lo que ya existe:
hacer la presentación menos evanescente, hacer visible la inscripción al repaso, y **ofrecer el repaso como
el siguiente paso del loop, no como una pestaña que hay que descubrir.**

---

## 3. La pregunta central de Gian: ¿un apartado "ESTUDIAR" separado, o teoría integrada?

**Veredicto: integrar, NO fragmentar.** Un apartado "Estudiar" nuevo (teoría/conceptos/clases
estructuradas como silo separado) es la decisión equivocada **para el momento actual**, por tres razones
pedagógicas y una de datos:

1. **La teoría no falta — está escondida (§1.A).** Ya hay 192 tips de calidad, una pantalla de Referencia
   "estilo Busuu Grammar Review", el glosario de historias y la tarjeta de presentación. El problema no es
   "no hay teoría"; es "la teoría no se encuentra y se salta". Construir un silo nuevo **duplica** lo que ya
   existe y no resuelve la descubribilidad.
2. **Un apartado separado fragmenta el aprendizaje.** La investigación sobre carga cognitiva y el propio
   modelo Busuu dicen lo contrario de "aparta la teoría": la teoría aprende mejor **contigua a su práctica**
   (present→practice en un flujo), no en una sección aparte que el usuario visita en frío. Sacar la teoría a
   su propia pestaña la desconecta del momento en que es útil.
3. **El dato manda: 7 de 8 usuarios abandonan antes de la lección 3, y el SRS tiene 0 uso.** Añadir una
   5ª superficie de aprendizaje (una 5ª pestaña o un gran módulo) **reparte aún más una atención que ya no
   alcanza** para las superficies existentes. No se construye una biblioteca nueva cuando nadie ha entrado a
   la que ya está abierta.

**Lo que SÍ hay que hacer con la teoría (integración, no silo):**
- **Darle a Referencia/Repaso una entrada de primer nivel** — hoy está enterrada como 1 de 4 tiles dentro
  de Practicar. Reusa `get_reference` (0 contenido nuevo). Esto es "el apartado de estudio" que Gian
  intuye, pero **construido sobre lo que ya existe**, no como silo nuevo.
- **Hacer la presentación de la lección menos saltable** (quitar el auto-avance de 3 s; que se muestre
  también en repaso). El "estudiar" ocurre ahí, en el momento correcto.
- **Apuntar a la teoría desde el loop** (tras fallar algo, "repasa el concepto" → abre el tip/Referencia).

**El matiz honesto — cuándo "Estudiar" SÍ tendría sentido:** si algún día los datos muestran que la gente
**llega** a la teoría y pide más (concepto explicado a fondo, no solo un tip de 3 líneas), la evolución
natural **no es un silo nuevo** sino **enriquecer Referencia** (que ya agrupa por habilidad y muestra %
de dominio) hacia un "Guía del idioma" navegable — reusando la misma infraestructura. Eso es barato y
pedagógicamente sano. Un apartado "Estudiar" con clases estructuradas nuevas es **contenido caro** (§6) que
hoy no está justificado por ningún dato de uso.

---

## 4. VIDEO — dimensionar la factura honestamente

Gian lo mencionó. Ni se descarta ni se vende — se dimensiona.

**Lo que costaría de verdad:**
- **Producción:** guion + grabación + edición + subtitulado por concepto. La gramática de un idioma a B2
  son **decenas de conceptos**. Y hay que hacerlo **×6 idiomas** (o al menos explicando 6 idiomas meta).
- **Mantenimiento:** cada ajuste de currículo (y este proyecto los hace a menudo) obliga a **re-grabar**,
  no a editar una fila de BD. La teoría en texto+audio+imagen de hoy se corrige con una migración; un vídeo
  se vuelve a producir.
- **Hosting/entrega:** el vídeo es **pesado** frente al modelo actual (texto + audio TTS de ~pocos KB +
  imágenes Twemoji), que se sirve casi gratis desde Storage. Vídeo = ancho de banda/CDN real, y choca con la
  CSP/PWA (nada de hosts externos en artefactos; habría que alojarlo y servirlo bien).

**Contra qué compite:** la teoría en **texto + audio + imagen** que **ya se puede producir hoy** con el
pipeline de la casa (autores nativos IA + audio TTS + Twemoji), a coste marginal casi nulo y corregible con
una migración. Para el 95 % de los conceptos A1–B2, texto+audio+imagen **enseña igual de bien** y es
infinitamente más barato de mantener.

**Veredicto:** **no ahora.** El vídeo es la factura más grande con la necesidad **menos probada** — nadie
ha llegado siquiera a la teoría en texto que ya existe. **Si algún día** se justifica, la forma sensata es
**unos pocos vídeos "evergreen" de introducción** ("cómo funciona este idioma", 2–3 minutos, en español —
el idioma origen — explicando el meta), alojados de forma barata, y **solo después** de que la retención
demuestre que la gente llega a la teoría. No un catálogo de clases en vídeo por concepto × 6 idiomas.

---

## 5. Qué haría Practicar más DINÁMICO y con mejor secuencia (sin romper SRS/economía)

Todo esto es capa de **experiencia** — no toca el motor FSRS, el grading ni la economía (un pago por
sesión, tope XP). Reordena y guía lo que ya existe.

1. **"Qué hacer ahora" — una recomendación única arriba de Practicar.** Hoy el usuario aterriza en 8
   secciones sin jerarquía y sin guía. Una tarjeta de **siguiente-paso** que el propio estado ya permite
   calcular: si hay palabras vencidas → "Repasa N palabras"; si no y hay punto débil → "Refuerza tu
   \<skill\>"; si no → "Sigue tu lección". Reduce la carga de decisión (el modelo Duolingo de "un solo
   botón").
2. **Priorizar/ocultar secciones por lo que es ACCIONABLE, no solo por `hasProgress`.** Si `dueWords==0` y
   no hay nuevas para hoy, **degradar** el HERO del SRS (que no domine la pantalla con "0"); si `weak==null`
   ocultar Punto débil (ya se hace parcialmente); si la habilidad no es gradable no ofrecer su botón (ya se
   respeta). El objetivo: que Practicar nunca ofrezca algo que dará "nada que reforzar".
3. **Adaptar por NIVEL.** Un A1 con 1 lección no necesita Contrarreloj ni Escritura avanzada; un B1 sí.
   Ordenar/mostrar las secciones según el nivel del plan (dato que ya existe en `user_plans.current_level`).
4. **Sacar la teoría del fondo de Practicar** (ver §3): Referencia con entrada de primer nivel, no como 1
   de 4 tiles.
5. **El lever de secuencia más importante — tejer el repaso en el LOOP** (esto vive en el fin de lección,
   no en Practicar, pero es lo que haría que el SRS deje de tener 0 uso): tras completar una lección, si hay
   palabras vencidas, ofrecer **"Repasar N palabras"** como una opción visible junto a "siguiente lección".
   Hoy el CTA solo empuja a avanzar; por eso nadie descubre el repaso.

---

## 6. Propuestas priorizadas — EXPERIENCIA (barato) vs CONTENIDO (caro)

### A · EXPERIENCIA — barato, solo cliente / server ligero, alto ROI

| id | Propuesta | Qué toca | Coste |
|---|---|---|---|
| **E1** | **Tejer el repaso en el fin de lección** (CTA "Repasar N" junto a "siguiente lección" cuando hay vencidas) | `lesson_complete_screen` + `get_srs_status` (ya existe) | bajo |
| **E2** | **Entrada de primer nivel a Referencia/Repaso** (la "teoría de estudio" que ya existe, hoy enterrada) | nav + `get_reference` (ya existe) | bajo |
| **E3** | **Presentación menos evanescente** (quitar auto-avance de 3 s; mostrarla también en repaso) | `lesson_player_screen`/`lesson_intro_view` | bajo |
| **E4** | **"Qué hacer ahora" en Practicar** (recomendación única) + priorizar/ocultar por accionabilidad y nivel | `practice_screen` (estado ya disponible) | bajo-medio |
| **E5** | **Momento explícito de inscripción al SRS** ("añadimos estas palabras a tu repaso") al fin de lección | `lesson_complete_screen` (dato ya server-side) | bajo |

> E1–E5 ayudan **a los pocos que llegan** y cuestan poco. Pero ninguna resuelve por sí sola el problema de
> fondo (§7): la gente no vuelve el día 2. Son correctas y baratas; hacerlas, sí — pero sin ilusión de que
> "arreglan Practicar", porque Practicar no está roto: está **vacío de visitas**.

### B · CONTENIDO — caro, requiere autoría/producción; **NO justificado por los datos hoy**

| id | Propuesta | Factura | Veredicto |
|---|---|---|---|
| **C1** | Curso/módulo de gramática dedicado (Busuu-style), lecciones de concepto nuevas × 6 idiomas | autores nativos × 6, semanas | **esperar** — la teoría actual ni se alcanza |
| **C2** | Banco de oraciones nativas + audio para el SRS (~2.664 oraciones, la factura de `PRACTICAR_SRS_ANALISIS`) | ~15–20 días de contenido | **esperar** — el SRS tiene **0 uso**; no financiar oraciones para una función que nadie abre |
| **C3** | Vídeo (§4) | la factura más grande | **no ahora** — necesidad no probada |

---

## 7. Honestidad final — el problema real

**El problema no es el diseño de Practicar ni la ausencia de "Estudiar". Es la activación y la retención.**
Los números lo cierran: **racha máxima histórica = 1 día** (los 8 usuarios), **7 de 8 abandonan antes de la
lección 3**, **0 sesiones de repaso jamás**. Cualquier trabajo grande sobre Practicar o un apartado
"Estudiar" nuevo estaría **puliendo una superficie que casi nadie pisa.**

**Lo que esto implica para "que el usuario aprenda bien":**
- El aprendizaje mejor-secuenciado que Gian quiere **se logra cosiendo lo que ya existe** (E1–E5:
  presentación firme, teoría descubrible, repaso tejido en el loop) — barato, y ayuda a los que llegan.
- Pero el **techo real** de "aprender bien" hoy no lo pone el diseño de las lecciones (que es sólido): lo
  pone que **la gente no llega a la lección 2 ni al día 2.** Ese es un problema de **activación/retención y
  onboarding/hábito**, no de contenido de aprendizaje. Ya hay piezas construidas para atacarlo (rampa de
  meta día-1, notificaciones push, siguiente-paso tras la lección) y **aún así la racha máxima es 1** — lo
  cual dice que el siguiente análisis con mayor ROI **no es sobre Practicar**, es sobre **por qué nadie
  vuelve el segundo día** (un `RETENCION_ANALISIS` sobre el minuto-4-al-día-2, con estos mismos usuarios
  reales).
- **No construir** el curso de gramática, el banco de oraciones del SRS ni el vídeo hasta que el embudo
  demuestre que la gente **alcanza** esas superficies. Financiar contenido para funciones con 0 uso es
  gastar donde el dato dice que no hay retorno.

**Si Gian solo hace 3 cosas de este análisis:** (1) tejer "Repasar N" en el fin de lección (E1) para que el
SRS deje de tener 0 uso; (2) dar entrada de primer nivel a la Referencia que ya existe (E2) — ese es el
"apartado de estudio" sin construir un silo; (3) abrir el frente real —**por qué la racha máxima es 1**— en
vez de rediseñar Practicar. Lo demás (Estudiar como silo, vídeo, banco de oraciones) es prematuro hasta que
el embudo respire.

---

### Anexo — método
Ground truth de uso: `tools/content/_gt_aprendizaje.py` (SQL read-only vía Management API, sin
service_role para nada sensible). Mapa de estructura: exploración del cliente con file:line. Cero código de
producción tocado. Referencias cruzadas: `PRACTICAR_SRS_ANALISIS.md` (motor SRS, 2026-07-16),
`PRINCIPIANTE_ANALISIS.md` (recorrido del principiante, 2026-07-13), `EVAL_AUDIT.md`.
