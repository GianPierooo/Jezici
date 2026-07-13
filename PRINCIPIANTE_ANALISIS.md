# PRINCIPIANTE_ANALISIS.md — el recorrido del principiante absoluto

> Análisis del recorrido de un usuario que llega **sin saber NADA** del idioma que quiere aprender.
> **Solo lectura, cero código.** Ground truth = repo + BD real + recorrido con 2 agentes de exploración
> (código) + consulta directa a la BD del contenido de la Unidad 1. Fecha: **2026-07-13**.
>
> Objetivo (pedido de Gian): mejorar la experiencia del que **empieza de cero**. Este doc traza qué vive
> HOY, marca dónde se pierde/frustra, y propone soluciones **priorizadas** (dinámicas y sencillas) para
> decidir — sin construir nada.

---

## 0. Resumen ejecutivo (veredicto)

El motor es sólido, pero **el recorrido del principiante absoluto tiene tres golpes duros, dos de ellos
casi gratis de arreglar**:

1. **[P0 · BUG] El 2º apartado (Practicar) MIENTE desde el minuto 1.** A un usuario recién registrado le
   muestra el HERO "**N palabras por repasar · Antes de que se te olviden**" con un número enorme (el
   vocabulario **entero** del curso), y al tocarlo salta "**¡Nada que reforzar! Vas al día 🎉**" — una
   contradicción directa. Causa: `dueWords` cuenta TODO el vocabulario menos lo agendado (=0 para un
   novato). Barato de arreglar, altísimo impacto de confusión.
2. **[P0 · UX] El onboarding empuja al principiante a un examen de nivel A2 que no entiende.** El paso
   "¿Cuánto sabes ya?" trae como **DEFAULT** "**Sé lo básico**", que arranca el test de ubicación en **A2**
   (no A1). Solo la opción "**Desde cero**" salta el examen. Un principiante que no lee con cuidado y pulsa
   Continuar cae en 16 preguntas de opción múltiple, audio y **hablar por micrófono en un idioma que no
   conoce**, sin botón para saltar el examen. Es un muro en el primer minuto.
3. **[P1 · pedagógico] No hay "enseñar antes de examinar".** La lección entra directo al primer ejercicio
   (un `match`) de palabras que **nunca se presentaron**; no hay tarjeta de concepto ni tip previo (el tip
   sale **al final**). Desde el ítem 1 ya se puede perder una vida. Y muy pronto (ítem ~6) se pide
   **escribir de memoria** una traducción y **leer en voz alta con micrófono**.

Gaps de contenido menores: **0 material de alfabeto/sonidos/pronunciación** en toda la app (relevante
sobre todo para de/nl/fr, menos para en/pt/it que comparten alfabeto).

**Si Gian solo hace 2 cosas:** arreglar el HERO de Práctica a cero (#1) y cambiar el default/flujo del
paso de nivel para que un principiante NO caiga en el placement (#2). Son baratos y quitan las dos peores
fricciones.

---

## 1. Recorrido actual, paso a paso (lo que se encontró)

### 1.1 Onboarding (12 pasos)
`app/lib/features/onboarding/onboarding_screen.dart` (orquestador, `_total = 12`).

| Paso | Pantalla | Qué ve |
|---|---|---|
| 0 | Bienvenida | Loro + "Construyamos tu plan · Unas preguntas rápidas y un test de nivel… ~2 minutos." |
| 1 | Idioma de la **app** | ES / EN / PT |
| 2 | Nombre + **año de nacimiento** (age gate) | "¿Cómo te llamas?" |
| 3 | Idioma **META** | "¿Qué idioma quieres aprender?" (los 6 cursos con bandera) |
| 4 | Motivo | Trabajo/Viajes/Examen/Estudios/Mudanza/Placer |
| 5 | Meta + plazo | metas capadas al tope del curso |
| 6 | Compromiso min/día + días/semana | — |
| 7 | Test de personalidad | → estilo de coach |
| **8** | **Nivel de arranque** | "¿Cuánto {idioma} sabes ya?" · **3 opciones** |
| 9 | Placement | "Test de ubicación · Sin pistas · pregunta X de 16" |
| 10 | Resultado | "Tu nivel: X" |
| 11 | Tu plan | mapa de viaje + "¡EMPEZAR MI VIAJE! 🚀" |

**El paso 8 es el punto crítico.** Las 3 opciones son:
- **"Desde cero"** (valor 0) → **SALTA el placement**: fija A1/Unidad 1 y va directo al plan. ✅ lo correcto para un principiante absoluto.
- **"Sé lo básico"** (valor 1) → **DEFAULT** → placement arranca en **A2**.
- **"Tengo buen nivel"** (valor 2) → placement arranca en **B1**.

El paso permite continuar **sin seleccionar nada** (`allowDefault: true`) usando el default = "Sé lo
básico". Es decir: **el camino de menor esfuerzo (pulsar Continuar) lleva a un principiante al examen A2**,
no a "Desde cero". El default está invertido respecto a quién más lo necesita.

### 1.2 Placement, si el principiante NO eligió "Desde cero"
`placement_test.dart`. Test adaptativo **calificado en el servidor** (anti-azar, robusto — ver EVAL_AUDIT).
- Arranca en **A2** (hint 1) o **B1** (hint 2), no A1.
- Ítems **en el idioma meta desconocido**: opción múltiple (reading/writing), **listening** (audio + "¿qué
  oíste?") y **speaking** (leer una frase en voz alta, transcrita por micrófono).
- **16 ítems** (máx), subtítulo "**Sin pistas** · pregunta X de 16" → se lee como examen largo y con presión.
- **No hay botón para saltar el examen completo** ni "no sé nada". Solo se puede saltar *speaking* individualmente
  ("Saltar los ejercicios de hablar"). La única salida es la flecha atrás → vuelve al paso 8.
- Anti-azar sólido: responder al azar da A1 (bien), pero **el daño ya está hecho en experiencia**: el
  principiante pasó por un muro de preguntas incomprensibles antes de que el sistema concluya "A1".

### 1.3 Resultado (si hizo placement)
`placement_result_view.dart`. Encuadre sano y no-ansioso: "Tu nivel: X · Esto no es un examen que se
aprueba o se reprueba: es tu punto de partida." + desglose de 4 habilidades + unidad de entrada + fecha
estimada. Ofrece "**Prefiero empezar desde el inicio**" **solo si el nivel ≠ A1** (a quien salió A1 no se
le ofrece, lo cual es correcto). ✅ Esta pantalla está bien.

### 1.4 "Tu plan" → mapa → primer nodo
- "Tu plan" es celebratorio (mapa de viaje, confeti). ✅
- El **primer nodo** del mapa es la **Misión "100 palabras esenciales"** (`mission_screen.dart`): lista 7
  categorías con emojis + da un bono de bienvenida (+XP/+oro). **No enseña vocabulario** — es un marco
  motivacional. (Nota menor: su copy `missionMainDescription` dice "del **inglés**" hardcodeado; ya está
  en la Cola de i18n.)

### 1.5 La primera lección
- `LessonPreviewScreen`: solo **metadatos** (nº de ejercicios, XP, skills) + "Empezar". No enseña nada.
- `LessonPlayerScreen`: entra **directo al ejercicio 0**, fase "answering". **No hay tarjeta de enseñanza
  ni tip previo.** El único tip sale en `lesson_complete_screen` (**al final**). → **te examinan primero,
  te enseñan después.**
- **Contenido real de la Unidad 1, Lección 1 "Saludos básicos" (es→en), en orden:**
  1. `match` — emparejar hello/hola, goodbye/adiós, good morning/… (aprender-haciendo, el más deducible)
  2. `multiple_choice` — "¿Cómo se dice 'hola'?"
  3. `multiple_choice` — "'Good morning' significa…"
  4. `listening` — "Escucha y elige"
  5. `word_bank` — "Arma la frase: 'Buenos días'"
  6. `translation` — "**Traduce: 'Adiós'**" → **escribir de memoria "Goodbye"** en el 6º ítem
  - (En toda la Unidad 1: 12 MC, 10 listening, **8 speaking read-aloud (micrófono)**, 6 cloze, 4
    translation, 4 match, 4 word_bank, 2 reorder — 46 ítems.)
- **Fricciones para el cero absoluto:** el `match` inicial pide emparejar palabras **nunca presentadas**
  (resoluble por adivinanza, pero es "examen desde el ítem 1"); sin imagen de apoyo en los primeros ítems
  (el sistema de imágenes existe pero esos ítems no la traen); muy pronto exige **producción** (escribir,
  hablar); y **se pierde una vida real al primer fallo**.

### 1.6 El 2º apartado (Practicar) para un usuario a cero
`practice_screen.dart`. De ~7 acciones, **solo 2 funcionan a cero**:

| Sección | Estado a cero | Detalle |
|---|---|---|
| **HERO "Rescate de palabras" (SRS)** | ❌ **ENGAÑOSO (bug)** | Muestra "N palabras por repasar · Antes de que se te olviden" con N = **todo el vocabulario del curso** (el novato tiene 0 agendado). CTA → "¡Nada que reforzar! Vas al día 🎉" (contradicción). |
| **"Refuerza tu punto débil"** | ⚠️ vacío/genérico | Sin dominio, muestra texto genérico o un skill con barra vacía; `start_practice('weakness')` → "Nada que reforzar". |
| **"Reforzar lo que fallé"** | ❌ inútil | El novato no ha fallado nada → "Nada que reforzar". |
| **Grid: Lectura / Redacción** | ❌ probablemente vacío | `start_practice('skill')` sin nada visto → "Nada que reforzar". |
| **Grid: Repaso (Referencia)** | ✅ funciona | Material de referencia, navegación directa. |
| **Grid: Inmersión (Historias)** | ✅ funciona | Historias con audio, navegación directa. |
| **Contrarreloj** | ❌ probablemente vacío | Pool vacío a cero → "Nada que reforzar". |

**Veredicto de Práctica a cero:** la pantalla le **grita** al principiante que tiene cientos de palabras
urgentes por rescatar cuando no ha aprendido ninguna, y casi todo lo que toca responde "nada que hacer".
Es la peor primera impresión del 2º tab.

---

## 2. Gaps priorizados

Clasificados por las 4 categorías que pidió Gian: **(a)** contenido introductorio inexistente,
**(b)** modo "desde cero" acompañado, **(c)** placement asustando, **(d)** 2º apartado sin sentido.

| # | Cat. | Gap (qué es) | Evidencia | Ayuda | Costo | Prioridad |
|---|---|---|---|---|---|---|
| 1 | (d) | **HERO de Práctica miente a cero** (dueWords = todo el vocab; CTA contradictorio) | `progress_repository.dart:932-964` + snackbar "Nada que reforzar" | 🔥 Alto | 🟢 Bajo | **P0** |
| 2 | (b)(c) | **Default del paso de nivel = "Sé lo básico" → placement A2**; el camino fácil NO es "Desde cero" | `onboarding_data.dart:28` + `placement_test.dart:59` | 🔥 Alto | 🟢 Bajo | **P0** |
| 3 | (c) | **Sin salida clara dentro del placement** ("no sé nada / empezar desde el inicio") | placement sin footer/skip global | 🔶 Medio | 🟢 Bajo | **P1** |
| 4 | (a)(b) | **No se enseña antes de examinar** (sin tarjeta de concepto/tip previo; producción muy temprana) | `lesson_player_screen.dart` (tip solo en complete) | 🔥 Alto | 🟡 Medio | **P1** |
| 5 | (d) | **Secciones de Práctica que no aplican a cero no se ocultan** (4 de 7 → "nada que reforzar") | `practice_screen.dart` | 🔶 Medio | 🟢 Bajo | **P1** |
| 6 | (a) | **0 contenido de sonidos/pronunciación/alfabeto** (crítico en de/nl/fr) | BD: 0 ítems con tag/prompt de pronunciación | 🔶 Medio | 🔴 Alto | **P2** |
| 7 | (b) | **Se pierde vida real desde el primer fallo** de la primera lección | `lesson_player_screen.dart:61,196-199` | 🟢 Bajo-Medio | 🟢 Bajo | **P2** |

---

## 3. Propuestas concretas (dinámicas y sencillas, sin construir)

### P0 · #1 — Arreglar el HERO de Práctica a cero
**Qué:** que `dueWords` cuente **solo palabras ya vistas** (agendadas en `user_vocab_srs`), no el
vocabulario entero. Para un usuario sin nada aprendido, el SRS debe estar en el estado honesto que YA
existe (`practiceSrsUpToDate` "¡Vas al día!") **o** mostrarse un **estado de bienvenida** en su lugar:
"Aún no tienes palabras por repasar. Completa tu primera lección y aquí aparecerán para no olvidarlas."
con CTA "**Ir a mi lección**" (al mapa).
**Cómo de dinámico:** un solo estado nuevo de la tarjeta (novato) + corregir el conteo. Sin contenido nuevo.
**Ayuda/Costo:** alto / bajo. **Es medio bug, medio UX — el arreglo más rentable del documento.**

### P0 · #2 — Que el principiante NO caiga en el placement por accidente
Dos opciones (elegir una; la **A** es la más limpia):
- **A) Invertir el flujo:** en el paso de nivel, **preguntar primero "¿Es tu primer contacto con
  {idioma}?"** (Sí/No). Si **Sí** → directo al plan A1 (salta placement), sin default peligroso. Si **No**
  → mostrar "Sé lo básico / Tengo buen nivel" y correr el placement. Es el patrón de Duolingo
  ("I'm new to X" vs "I know some X").
- **B) Mínimo cambio:** hacer que el **DEFAULT** del paso sea "**Desde cero**" (no "Sé lo básico") y
  reforzar el copy ("Elige 'Desde cero' si es tu primer contacto"). Así, pulsar Continuar sin pensar te
  deja en A1, no en un examen A2.
**Ayuda/Costo:** alto / bajo. Quita el muro del primer minuto.

### P1 · #3 — Salida clara dentro del placement
**Qué:** añadir en el pie del examen un botón secundario "**No sé nada — empezar desde el inicio**" que
fije A1/Unidad 1 y salga (el mismo mecanismo que ya usa `PlacementResultView` para "empezar desde el
inicio", pero disponible **durante** el examen, no solo al final). Red de seguridad para quien ya entró y
se está estrellando.
**Ayuda/Costo:** medio / bajo.

### P1 · #4 — "Enseñar antes de examinar" (present → practice)
**Qué:** una **tarjeta de presentación** breve al inicio de cada lección (sobre todo las primeras): mostrar
3–5 palabras/frases nuevas con **texto meta + traducción + audio (tocar para oír) + imagen** (el sistema
`ConceptImage` y el TTS **ya existen**), ANTES del primer ejercicio. Es el modelo de Busuu (presenta
vocabulario en tarjetas, luego practica). Alternativa **más barata**: mover/duplicar el **tip al INICIO**
de la lección (hoy solo sale al final) como mini-introducción del tema.
**Cómo de dinámico:** reusar mascota + audio + imágenes existentes; marcar en el contenido qué ítems son
"de presentación" o derivar la tarjeta de las primeras palabras de la lección.
**Ayuda/Costo:** alto (pedagógico) / medio. El de mayor impacto de aprendizaje real.

### P1 · #5 — Ocultar en Práctica lo que no aplica a cero
**Qué:** con 0 progreso, **colapsar** las secciones que devolverán "nada que reforzar" (SRS vacío, punto
débil, reforzar fallos, Lectura/Redacción) y dejar arriba lo que SÍ sirve a un novato: **Inmersión
(historias)**, **Repaso (referencia)** y un CTA claro "**Empieza tu primera lección**". Que la pantalla
sea útil desde el día 0 en vez de un campo de snackbars.
**Ayuda/Costo:** medio / bajo. (Se combina de forma natural con #1.)

### P2 · #6 — Módulo introductorio de sonidos/pronunciación
**Qué:** una mini-unidad 0 opcional de **sonidos y pronunciación** por idioma (letras/dígrafos que suenan
distinto: en "th", fr nasales/acentos, de "ch/ö/ü/ß", nl "g/ui/ij", it "gli/gn/ce-ci"). Con audio TTS
(pipeline ya existe) + "escucha y repite". **Priorizar de/nl/fr** (donde el sonido diverge más del
español); en/it/pt comparten alfabeto y es menos urgente.
**Ayuda/Costo:** medio / alto (autoría + audio + verificación por idioma). Dejar para después de los P0/P1.

### P2 · #7 — Gracia de vidas en las primeras lecciones
**Qué:** no penalizar con pérdida de vida los fallos de la **Unidad 1** (o de las 2–3 primeras lecciones),
como hace Duolingo al inicio. El principiante está descubriendo cómo funciona; castigarlo desde el primer
match adivinado desalienta. (Ojo: toca la economía de vidas — decisión de Gian.)
**Ayuda/Costo:** bajo-medio / bajo.

---

## 4. Qué hacen los referentes (y qué vale la pena)

- **Duolingo** — optimiza **enganche y hábito**: al principiante le pregunta explícito "**¿Eres nuevo en
  X?**" (nuevo → arranca en lo más fácil, **sin examen**; "sé algo" → placement **saltable**). Primeras
  lecciones **muy fáciles**, tap/emparejar con **imágenes y audio**, **poco/ningún typing temprano**, y
  **no castiga** tan duro los primeros fallos. → **Vale la pena copiar:** la pregunta "¿eres nuevo?"
  (nuestro #2), el apoyo visual+audio antes de producir (#4), y la mano suave con las vidas al inicio (#7).
- **Busuu** — optimiza **estructura CEFR y base sólida**: **presenta el vocabulario en tarjetas** (con
  audio y ejemplos) **antes** de practicar, ruta clara de principiante absoluto → C1, placement solo para
  quien vuelve. → **Vale la pena copiar:** el **"present → practice"** (nuestro #4), que es justo lo que
  hoy falta (examinamos antes de enseñar).

Ambos coinciden en lo esencial para el cero absoluto: **no meterlo a un examen**, **enseñar antes de
pedir**, y **empezar facilísimo con apoyo visual/auditivo**. Jezici ya tiene las piezas (audio TTS,
imágenes `ConceptImage`, mascota, historias, referencia); el trabajo es **de flujo y encuadre**, no de
motor.

Sources: [testprepinsight](https://testprepinsight.com/comparisons/busuu-vs-duolingo/) · [icanlearn](https://www.icanlearn.com/duolingo-vs-busuu/) · [ling-app](https://ling-app.com/blog/busuu-vs-duolingo/)

---

## 5. Recomendación (orden sugerido para decidir)

1. **#1 (HERO Práctica) + #5 (ocultar secciones a cero)** — juntos, un solo frente barato que arregla el
   2º tab desde el día 0. **Empezar por aquí.**
2. **#2 (¿eres nuevo? / default "Desde cero")** — quita el muro del placement en el primer minuto. Barato.
3. **#4 (enseñar antes de examinar)** — el salto pedagógico real; reusa audio+imágenes que ya existen.
4. **#3 (salida dentro del placement)** y **#7 (gracia de vidas)** — pulidos de seguridad, baratos.
5. **#6 (sonidos/pronunciación)** — contenido nuevo por idioma; el más caro, dejarlo al final y priorizar de/nl/fr.

> **Nada de esto es código todavía.** Es material para que Gian decida qué frentes abrir y en qué orden.
> Los P0 son casi gratis y quitan las dos peores fricciones del principiante absoluto.
