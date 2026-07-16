# Jezici — Practicar: motor de repaso estilo Anki (SRS serio) para los 6 idiomas

> **Qué es esto:** especificación para llevar las buenas prácticas de aprendizaje de Anki
> (repetición espaciada real, recuerdo activo, cloze en oración, audio) al apartado
> **Practicar** que YA existe en Jezici, para los **6 idiomas** (en/pt/fr/it/de/nl).
> No es una app nueva ni un reemplazo de nada: es subir de nivel el "Rescate de palabras"
> actual, que hoy usa un SRS básico, a un motor riguroso y una experiencia dinámica.
>
> **Regla de oro del documento:** todo lo que aquí se propone debe ser *producto general*
> (sirve a cualquier usuario de cualquiera de los 6 idiomas). Lo que sea específico de una
> preparación personal (ej. IELTS, mazo NGSL solo-inglés) queda EXPLÍCITAMENTE fuera del
> producto y marcado como tal.

---

## 0. Punto de partida real (lo que YA existe — no partimos de cero)

Jezici ya tiene la base del SRS; esto es una mejora, no una invención:

- **Tabla `user_vocab_srs`**: `user_id`, `vocab_id`, `strength`, `ease`, `interval_days`,
  `due_at`, `last_reviewed_at`. Ya modela una agenda de repaso por palabra.
- **Tabla `vocabulary`**: `word`, `translation`, `frequency_rank`, `part_of_speech`, por curso.
- **Sección "Rescate de palabras"** en Practicar (hoy con lógica de intervalo simple).
- **Ejercicios `cloze`** ya existen en `content_items` (se usan en lecciones/exámenes).
- **TTS por idioma** funcionando (se arregló el `.voice` por idioma en una tanda previa).
- **Economía** (XP, oro, vidas, racha) y su gamificación ya integradas.

> **Implicación:** el trabajo no es construir un SRS desde cero, sino (a) reemplazar el
> algoritmo simple por uno serio, (b) cambiar el modo de repaso a recuerdo activo con cloze
> escrito + audio, y (c) asegurar cobertura de contenido en los 6 idiomas. El PASO 0 del
> primer prompt debe CENSAR esto contra la BD real antes de estimar nada.

---

## 1. La ciencia que debe implementar (el "por qué" de cada decisión)

1. **Repetición espaciada (spacing effect):** repasar justo antes de olvidar multiplica la
   retención frente al repaso masivo. Es el corazón; sin esto Practicar es un repaso plano.
2. **Recuerdo activo (retrieval practice):** el usuario debe PRODUCIR la respuesta (escribir)
   antes de verla. Nunca "mostrar y preguntar ¿la sabías?" sin esfuerzo real previo.
3. **Frecuencia primero (cobertura):** priorizar el vocabulario de mayor frecuencia da el
   mayor retorno. Jezici ya ordena por `frequency_rank`; el SRS debe respetar ese orden al
   introducir palabras nuevas.
4. **Chunks / contexto:** la palabra se repasa DENTRO de una oración, nunca aislada. Encaja
   con la metodología ya existente de Jezici (enseñar frases hechas).
5. **Acoplar forma escrita y sonora:** audio en cada tarjeta ataca el problema del
   hispanohablante ("sé la palabra pero no la reconozco al oírla").

---

## 2. Alcance — qué SÍ entra al producto (los 6 idiomas)

### P0 — El motor y la experiencia base (sin esto no hay mejora real)

**2.1 Motor SRS serio (reemplaza el intervalo simple actual)**
- Implementar **FSRS** (Free Spaced Repetition Scheduler; algoritmo abierto moderno, el que
  adoptó Anki) o, como mínimo viable, **SM-2**. Decidir en el prompt según lo que sea
  razonable de portar a Postgres/Dart; FSRS es el objetivo de calidad.
- **4 botones de calificación:** `Otra vez / Difícil / Bien / Fácil`.
- **Cola diaria:** primero tarjetas vencidas (`due_at <= now`), luego nuevas. Límite
  configurable de nuevas/día (default sugerido: **15**, en `jz_config`, no hardcodeado).
- Tarjetas falladas reaparecen en la misma sesión hasta acertarse.
- Toda la lógica de scheduling **server-side** (RPC), nunca en el cliente (consistente con
  la regla de Jezici de no decidir estado sensible en el cliente).
- **Agnóstico al idioma:** el mismo motor sirve a los 6 cursos sin cambios.

**2.2 Recuerdo activo: cloze en oración con ESCRITURA (el modo principal)**
- Anverso: oración con hueco en el idioma meta → `I can't ______ living in a noisy city.`
- El usuario **escribe** la respuesta (no opción múltiple). Detecta ortografía, fuerza el
  recuerdo real. Normalización tolerante (mayúsculas/tildes) como ya hace el grading.
- Reverso al revelar: respuesta + oración completa + traducción ES colapsada por defecto.
- Reusar la infraestructura `cloze` de `content_items` que ya existe.

**2.3 Audio TTS en cada tarjeta**
- Al revelar, reproducir la oración completa en el idioma del curso (TTS ya funciona por
  idioma). Tocar el texto para volver a oír (patrón ya usado en el speaking).

**2.4 Fuente de vocabulario = lo que cada curso ya enseña**
- El SRS se alimenta del vocabulario que el usuario YA vio en lecciones (entra a
  `user_vocab_srs` al completar la lección que lo introduce). **Ojo (deuda conocida):** una
  tanda previa detectó que `complete_lesson` NO alimenta el SRS hoy — hay que CONECTARLO para
  que las palabras vistas entren a la agenda de repaso. Este es probablemente el trabajo
  central de contenido/lógica.
- Orden de introducción por `frequency_rank` (alta frecuencia primero).

**2.5 Integración con la gamificación existente (punto de diseño, no trivial)**
- El repaso SRS da XP/oro y cuenta para la racha/meta diaria, SIN romper la economía actual
  ni duplicar recompensas. Definir cuánto da un repaso vs. una lección nueva (la práctica
  debe dar algo menos que una lección nueva — principio ya establecido en el diseño de
  gamificación de Jezici).

**2.6 Métricas mínimas visibles**
- **Retención** (% de aciertos en tarjetas maduras) — objetivo de referencia >85%.
- **Vencidas hoy** y racha diaria.
- Total de palabras en repaso / dominadas.

### P1 — Ventaja y dinamismo (después de que P0 funcione en los 6 idiomas)

- **Modo audio-primero (mini-dictado):** suena la oración ANTES de mostrar texto; el usuario
  escribe lo que oye. Entrena comprensión auditiva + ortografía a la vez. Aplica a los 6.
- **Repaso de la habilidad/tema más flojo:** conectar el SRS con el diagnóstico de 4
  habilidades que ya existe ("tu listening va flojo → repaso con más audio").
- **"Palabras problema":** las N tarjetas con más fallos, siempre visibles, para repaso
  dirigido.
- **Etiquetas por tema** (viajes, trabajo, etc.) filtrables, si el contenido lo permite.
- **Dinamismo visual:** animaciones de la tarjeta (voltear, acierto/fallo), Jezi reaccionando,
  barra de progreso de la sesión, celebración al terminar la cola — coherente con el lenguaje
  visual del sistema (tokens, Nunito, labio 3D, reduce-motion-aware).

### P2 — Solo si aporta y hay demanda real

- **Captura rápida / tarjetas propias:** el usuario crea sus propias tarjetas (pego oración,
  marco palabra, Enter). Potente, pero es contenido generado por usuario → scope grande
  (validación, posible moderación). Diferir hasta que P0/P1 estén sólidos y haya usuarios
  pidiéndolo.

---

## 3. Lo que queda FUERA del producto (honestidad de alcance)

Estas ideas venían del spec original de Anki pero son de una **preparación personal de inglés
(IELTS)**, no del producto multi-idioma. NO construir en Jezici como feature general:

- ❌ **Mazo NGSL top-1000 solo-inglés / enfoque IELTS.** El producto es 6 idiomas; el
  equivalente sano es "alimentar el SRS con el vocabulario de alta frecuencia que CADA curso
  ya enseña", no importar una lista específica de inglés.
- ❌ **Mazos temáticos IELTS (education, environment...)** como feature del producto.
- ❌ Cualquier cosa atada a una banda/examen específico de un solo idioma.

> Si Gian quiere una herramienta personal de IELTS, esa es una decisión aparte y NO debe
> mezclarse con el producto Jezici (confunde el alcance y añade contenido que 5/6 de los
> idiomas no usan).

---

## 4. Anti-features (trampas a evitar)

- ❌ Listas de palabras sin oración ni SRS.
- ❌ Juegos de matching/reconocimiento pasivo como sustituto del recuerdo activo.
- ❌ Rediseño visual antes de que el motor P0 funcione.
- ❌ Traducir la tarjeta entera como modo principal (la traducción es apoyo colapsado).
- ❌ Romper la economía/gamificación existente por encajar el SRS.

---

## 5. Preguntas que el PASO 0 del primer prompt debe responder (contra la BD real)

Sin estas respuestas, cualquier estimación es a ciegas:

1. ¿Qué algoritmo usa HOY el "Rescate de palabras" y cómo llena `user_vocab_srs`?
2. ¿`complete_lesson` alimenta el SRS o no? (deuda conocida: parece que NO). ¿Cómo conectarlo?
3. ¿Cuánto vocabulario con **oración-ejemplo tipo cloze** existe por idioma? ¿Los 6 tienen
   cobertura, o hay idiomas sin oraciones y habría que generarlas? (Esto define el costo real.)
4. ¿El TTS cubre las oraciones de repaso en los 6 idiomas?
5. ¿Cómo se integra la calificación SRS con XP/oro/racha sin duplicar ni romper?

---

## 6. Criterio de aceptación (cuándo está "bien hecho")

Un usuario de **cualquiera de los 6 idiomas** puede, dentro de Practicar:
- Hacer una sesión de repaso que trae sus tarjetas vencidas + nuevas (con límite),
- **escribiendo** la respuesta en una oración con hueco,
- oyendo la oración con audio del idioma correcto,
- calificando con los 4 botones y viendo cómo se reprograma la palabra,
- ganando XP/oro y manteniendo su racha,
- y viendo su retención — todo **persistido** y **sin romper** lecciones, economía ni las 4
  habilidades. Verificado con cliente real en al menos 2 de los 6 idiomas (uno romance, uno
  germánico) antes de dar por cerrado P0.

---

## 7. Orden de trabajo sugerido

1. **Análisis técnico (solo lectura)** contra la BD real → responde la sección 5, mide la
   cobertura de contenido por idioma, propone FSRS vs SM-2 con criterio, y estima el esfuerzo
   real. *(Este es el primer prompt.)*
2. **P0 motor + modo cloze escrito + audio + conexión SRS** en 1-2 idiomas, verificado.
3. **Extender P0 a los 6** (aquí pesa la cobertura de contenido).
4. **P1 dinamismo + audio-primero + palabras problema.**
5. **P2 (captura propia) solo si hay demanda.**

> Profundidad > amplitud: cerrar impecable un par de idiomas antes de esparcirse a los 6.
