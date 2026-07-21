# Jezici — Apartado "ESTUDIAR": análisis de diseño

> **Qué es esto:** el plan de diseño del nuevo tab "Estudiar" que Gian quiere — un curso de teoría
> estructurado (teoría + ejemplos + video de profesor + pruebas) que se desbloquea según el avance
> en los niveles del home, como una línea pedagógica coherente hasta el nivel más alto.
>
> **Este es un PROYECTO, no una tanda.** El objetivo del análisis es diseñar bien la estructura y —
> crítico — dimensionar con honestidad el costo (sobre todo el video), para que Gian decida el
> alcance con los números delante, no a ciegas. La construcción vendrá por fases.

---

## 1. La visión (lo que pidió Gian)

Un **tab nuevo "Estudiar"** en la barra inferior (junto a Aprender / Practicar / Conversar / Ligas /
Perfil), con:
- **Teoría** estructurada (conceptos de gramática y vocabulario).
- **Ejemplos**.
- **Video de un profesor** enseñando una sesión.
- **Pruebas** (evaluar lo estudiado).
- **Una línea pedagógica** clara que lleve del nivel más bajo al más alto.
- **Desbloqueo por progreso:** cierta teoría se abre según cómo avanza el usuario en los niveles del
  home → Estudiar y Aprender están **conectados**, no son silos independientes.

---

## 2. La decisión que define TODO el proyecto: el VIDEO

El video de profesor es, de lejos, la pieza más cara y más riesgosa. Hay que ser brutalmente honesto
antes de comprometerse, porque decide si esto es un proyecto de 2 semanas o de 6 meses.

**La factura real del video de profesor (por sesión, ×6 idiomas):**
- **Producción:** guion + profesor nativo frente a cámara + grabación + edición, POR cada sesión de
  teoría, POR cada uno de los 6 idiomas. Un curso A1–B2 tiene decenas de temas → decenas de videos ×6.
- **Talento:** profesores nativos filmables de inglés, portugués, francés, italiano, alemán y
  neerlandés. Conseguir y coordinar 6 profesores en cámara es logística real, no un prompt.
- **Hosting/CDN:** video pesa; servirlo fluido a usuarios en móvil requiere un CDN de video (no el
  Storage actual de Supabase para MP3 pequeños) → costo mensual recurrente que escala con usuarios.
- **Mantenimiento:** si cambias el currículo, re-grabas. El video es el contenido más rígido que existe.
- **Alternativa generativa:** video con avatar/voz IA (tipo HeyGen/Synthesia) — más barato que filmar,
  pero (a) cruza el "cero IA en runtime"/contenido, (b) calidad de "profesor real" discutible, (c)
  costo de licencia por minuto ×6 idiomas igualmente relevante.

> **Recomendación honesta sobre el video:** NO empezar por el video. Es la pieza de mayor costo, mayor
> riesgo y menor certeza de retorno — y además la app NO tiene aún la retención que justifique esa
> inversión (dato conocido). El resto de "Estudiar" (teoría + ejemplos + audio + pruebas) se puede
> construir SIN video y entrega el 80% del valor. El video se añade como capa POSTERIOR, por idioma,
> solo si el módulo demuestra uso. Diseñar el módulo para que el video sea un "hueco" opcional por
> tema (si existe video → se muestra; si no → teoría + audio), no un requisito.

---

## 3. Arquitectura pedagógica propuesta (la "línea" hasta el nivel alto)

La estructura que da coherencia de A1 al nivel más alto:

```
ESTUDIAR (tab)
└── Nivel (A1 → A2 → B1 → B2 → …)   [desbloqueo por progreso del home]
     └── Unidad / Tema
          └── Lección de estudio
               ├── TEORÍA (el concepto explicado: gramática o vocabulario)
               ├── EJEMPLOS (frases modelo con traducción + audio)
               ├── VIDEO (opcional, si existe para ese tema/idioma)
               └── PRUEBA (mini-quiz que valida la comprensión → conecta a Practicar)
```

**Conexión con el home (lo que Gian pidió — que esté conectado):**
- El desbloqueo de un tema de Estudiar se ata al progreso del mapa (Aprender): completar la unidad N
  del home abre el tema N de Estudiar (o al revés — definir la dirección). Reusa el gating que YA
  existe (checkpoints/unidades), no inventa un sistema paralelo.
- Idealmente: en el home, al llegar a un nivel/unidad, un enlace "Estudia la teoría de esto" lleva al
  tema correspondiente en Estudiar; y en Estudiar, "Practícalo" lleva a la lección/práctica. Loop
  cerrado estudiar → practicar → repasar.

---

## 4. De dónde sale el contenido (Gian dijo: contenido nuevo, trabajo grande)

Honestidad sobre el costo de cada capa, de más barata a más cara:

| Capa | Fuente | Costo | ¿Ahora? |
|---|---|---|---|
| Estructura/temario (índice A1→B2 por unidad) | Derivable del currículo que YA existe (unidades, tips, lesson_vocab) | Bajo | ✅ Sí |
| Teoría escrita por tema | Parcial: 192 tips ya existen; ampliarlos a "teoría de sesión" completa = contenido nuevo ×6 idiomas (pipeline de agentes, como el léxico) | Medio-alto | Por fases |
| Ejemplos + audio | Reusa TTS + patrón del léxico F1 (oración+audio) | Medio | ✅ Sí |
| Pruebas/quiz por tema | Reusa el motor de ejercicios que ya existe (cloze, match, etc.) | Bajo-medio | ✅ Sí |
| **Video de profesor** | **Nuevo, producción humana o IA, ×6 idiomas** | **Muy alto** | **NO — capa posterior, opcional** |

> El contenido de teoría escrita + ejemplos + pruebas se puede generar con el MISMO pipeline de agentes
> nativos + revisión adversarial que produjo el léxico y las lecciones (los 5.182 ítems, el léxico F1).
> Es trabajo grande pero conocido y verificable. El video NO encaja en ese pipeline — es otra bestia.

---

## 5. Plan por fases (para no meterse a un proyecto de meses de golpe)

**Fase E-1 — Esqueleto + estructura (sin contenido nuevo masivo, ~1 tanda):**
Tab "Estudiar" + navegación por nivel/unidad + desbloqueo atado al progreso del home + mostrar la
teoría que YA existe (los 192 tips + referencia) dentro de la nueva estructura. Esto ya da un apartado
de estudio navegable y conectado, reusando todo. **Es el MVP del módulo, verificable, bajo riesgo.**

**Fase E-2 — Teoría rica + ejemplos + pruebas (contenido nuevo, por idioma, pipeline de agentes):**
Ampliar la teoría de cada tema a "sesión de estudio" completa (explicación + ejemplos + audio) + una
prueba por tema. Empezar por INGLÉS (como el léxico), verificar, luego escalar. Trabajo grande pero
por fases medibles.

**Fase E-3 — Video (opcional, solo si E-1/E-2 demuestran uso):**
Decidir producción humana vs IA, empezar por 1 idioma, hueco opcional por tema. NO antes de tener
señal de que el módulo se usa.

---

## 6. La pregunta honesta que Gian debe responder antes de construir

Este módulo es el proyecto más grande propuesto en todo Jezici — un tab nuevo + un curso de teoría en
6 idiomas + potencialmente video. Antes de la Fase E-1, dos verdades que conviene tener presentes:

1. **El video casi con certeza no debe entrar ahora** (costo/riesgo altísimo, retención no probada).
   Diseñar el módulo para que el video sea opcional y posterior protege el proyecto.
2. **Empezar por el esqueleto (E-1) que reusa lo existente** da un tab "Estudiar" real y navegable en
   una tanda, sin comprometerse aún a la factura de contenido nuevo ×6 idiomas. Permite ver si el
   apartado se usa ANTES de financiar la teoría rica y el video.

> **Recomendación final:** construir la Fase E-1 (esqueleto + estructura + desbloqueo + teoría
> existente) primero. Es lo que hace realidad la visión de Gian de forma tangible y de bajo riesgo, y
> deja las facturas grandes (teoría nueva ×6, video) para cuando el módulo demuestre que la gente lo
> usa. Diseñar hoy la estructura completa para que las fases siguientes encajen sin rehacer.
