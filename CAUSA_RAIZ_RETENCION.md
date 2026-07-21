# Jezici — La causa raíz de la retención de 1 día (evidencia visual)

> **Qué es esto:** análisis del hallazgo más importante del proyecto. Las capturas de un usuario
> real repasando (2026-07-19) muestran, con evidencia visual, POR QUÉ la racha máxima es 1 día y
> por qué el feedback dice "muy difícil / no se aprende / se resuelve sin aprender". No es opinión:
> son cuatro pantallas de la app marcando MAL respuestas que están BIEN.
>
> **Este documento es de diagnóstico. El fix es urgente y es de EXPERIENCIA/lógica, no contenido nuevo.**

---

## 1. La evidencia (capturas reales de un repaso)

| Pregunta | Usuario escribió | App dijo | ¿Estaba bien la respuesta del usuario? |
|---|---|---|---|
| ¿Cómo se dice **hola**? | hello | ❌ "era: hi" | **SÍ. "hello" = hola.** |
| ¿Cómo se dice **gracias**? | thanks | ❌ "era: thank you" | **SÍ. "thanks" = gracias.** |
| ¿Cómo se dice **disculpa**? | sorry | ❌ "era: excuse me" | **SÍ. "sorry" = disculpa.** |

**Tres de tres respuestas correctas, marcadas como incorrectas.** Un principiante absoluto que
entra, sabe algo de inglés, escribe la respuesta correcta, y la app le dice MAL tres veces
seguidas. Nadie vuelve a una app que le dice que se equivoca cuando tiene razón. **Esto es,
con alta probabilidad, LA causa de la racha de 1 día.**

---

## 2. Los dos bugs de fondo (hipótesis a confirmar en el código)

### Bug A — El ejercicio acepta UNA sola traducción e ignora sinónimos válidos
El SRS/repaso guarda por palabra UNA respuesta "correcta" (hi, thank you, excuse me) y marca mal
todo lo demás. Pero el idioma no funciona así: hola=hi/hello, gracias=thanks/thank you,
disculpa=sorry/excuse me/pardon. El grader exige coincidencia con la única forma almacenada.
- **Consecuencia:** castiga respuestas correctas → frustración inmediata → abandono.
- **Esto contradice lo que el propio sistema decía tener** (matching leniente 0.6, homófonos) —
  ese leniency es para el *speaking* (voz), NO para el cloze/escritura del SRS. El SRS escrito
  parece exigir match exacto contra una sola forma.

### Bug B — Te examina vocabulario en dirección es→en que quizá nunca se enseñó así
La tarjeta pregunta "¿cómo se dice X?" (producción es→en: ver español, escribir inglés). Si la
palabra se introdujo solo en dirección en→es (reconocimiento), el usuario nunca practicó
producirla → "se resuelve sin aprender / muy difícil". Además, el análisis previo ya probó que
`complete_lesson` inscribía por substring y que muchas palabras entran al SRS sin haberse
enseñado bien en ambas direcciones.

---

## 3. Por qué esto explica TODO el feedback y los datos

- *"Está muy difícil"* → no es difícil, **te marca mal aunque aciertes.**
- *"No hay cómo aprender / se resuelve sin aprender"* → te pregunta producción de palabras que
  viste de pasada; adivinas, fallas, y no hay un momento de "ah, esto se dice así" ANTES de
  examinarte.
- *"Racha máxima = 1 día, 7/8 abandonan antes de la lección 3"* → la primera experiencia de
  práctica es una cadena de "MAL" inmerecidos. La emoción con la que se van es *injusticia*, no
  dificultad. Y de esa no se vuelve.

**El problema NUNCA fue la falta de un apartado "Estudiar". Fue que el ejercicio central castiga
al usuario.** Un apartado nuevo de teoría no arregla esto — el usuario seguiría entrando al
repaso y recibiendo "MAL" por respuestas correctas.

---

## 4. Lo que hay que arreglar (prioridad por impacto en retención)

### 🔴 P0 — Aceptar TODAS las respuestas válidas (el arreglo que más mueve la retención)
- Cada palabra/ítem debe aceptar un CONJUNTO de respuestas correctas (hi/hello; thanks/thank you;
  sorry/excuse me/pardon), no una sola. Normalización tolerante (mayúsculas, tildes, espacios,
  puntuación) — que ya existe para otros casos.
- Fuente de los sinónimos: derivar de lo que el contenido YA tiene (si la palabra aparece en
  varios ítems/lecciones con formas distintas, todas cuentan) + un set de aceptables por entrada.
  Donde no haya alternativas listadas, ser generoso con la normalización.
- **Regla de oro:** ante la duda, aceptar. Es infinitamente mejor dar por buena una respuesta
  aceptable que castigar una correcta. El costo de un falso "bien" es cero; el de un falso "mal"
  es un usuario que se va.

### 🔴 P0 — Enseñar antes de examinar en producción (Bug B)
- Antes de pedir producción (es→en, "¿cómo se dice X?"), asegurar que la palabra se PRESENTÓ
  (la tarjeta de concepto/presentación, que ya existe). Si una palabra nunca se enseñó en la
  dirección que se examina, o se presenta primero, o se examina en reconocimiento (en→es) hasta
  que se haya visto.
- Conectar con lo que ya se construyó: la tarjeta de presentación (get_lesson_intro) y el hecho
  de que el SRS ahora se teje en el fin de lección (E1-E5).

### 🟡 P1 — La alineación por nivel que pide Gian
- El feedback dice "las lecciones no están alineadas según el nivel". Verificar que el SRS y las
  prácticas sirven vocabulario del nivel que el usuario está cursando, no palabras de más arriba.
  (El léxico F1 ancló palabras nuevas en A2/B1 — confirmar que un usuario A1 no recibe esas en el
  repaso antes de tiempo.)

### 🟢 Lo que NO es la solución (aunque lo pidan)
- **Un apartado "Estudiar" nuevo NO arregla esto.** La teoría ya existe (192 tips, referencia,
  presentación). El usuario no se va por falta de teoría — se va porque el ejercicio lo castiga.
  Hacer la teoría más visible (E2, ya hecho) ayuda; construir un silo nuevo mientras el ejercicio
  central sigue roto sería pintar otra habitación mientras el suelo está en llamas.
- **Video** = factura enorme, no probada, no ahora.

---

## 5. El orden correcto (y por qué importa más que cualquier feature)

1. **Arreglar el grader (P0-A): aceptar sinónimos válidos.** Es el fix de MAYOR impacto en
   retención de todo el proyecto — más que el SRS entero, más que el léxico, más que la voz.
   Porque ataca la razón real por la que la gente se va.
2. **Enseñar-antes-de-examinar en producción (P0-B).**
3. **Alineación por nivel (P1).**
4. **Medir** (la analítica que se está instrumentando ahora) si la retención sube tras el fix.

> **La verdad incómoda y liberadora:** llevas ~40 tandas construyendo features sobre un ejercicio
> que, en su primer contacto con el usuario, le dice "MAL" cuando acierta. Ninguna feature podía
> compensar eso. Este es el arreglo que debía venir antes que todos los demás — y ahora, con la
> evidencia en la mano, es obvio. Arréglalo, y por primera vez la app dejará de expulsar a la
> gente que sí sabe algo.
