# Jezici — Auditoría de EFICACIA del contenido (EFICACIA_CONTENIDO.md)

> ¿El contenido de cada nivel **construye la competencia CEFR** de ese nivel (no solo
> "ítems sin error")? Auditoría profesor + diseñador de currículo, por nivel como un todo:
> cobertura CEFR, progresión, retención, balance de 4 habilidades, evaluación. 2026-06-24.
> Prioridad: es→en A1/A2 a fondo (lo que los testers usan hoy). B1–C1 y es→pt: perfil
> estructural + diferido (ver "Pendiente").

## B1 es→fr (escalera A2→B1) (2026-07-03)
- **B1 francés completo (mig 113):** 6 unidades (order 13-18), 114 ítems, balance **L=67% S=50%**. Currículo
  B1 CEFR-real (no traducción del inglés): subjonctif présent, futur/conditionnel, pronoms relatifs
  (qui/que/dont/où), accord du participe passé, discours indirect, pronoms compléments — progresión desde A2.
  6 profesores nativos IA + rebalanceo/revisión adversarial nativa (0 errores tras la pasada; fixes de
  élision, accepted, distractores audibles). Francés pasa de "A1+A2" a **A1→B1** (verify_b1_chain fr PASS).
  **Diferido: B1 it/nl** (andamiaje listo; retome exacto en FINDINGS.md). B2+ no existe aún.

## B1 es→de (escalera A2→B1) (2026-07-03)
- **B1 alemán completo (mig 111):** 6 unidades (order 13-18), 114 ítems, balance **L=67% S=50%** (objetivo
  cumplido, no 1:1). Currículo B1 CEFR-real (no traducción del inglés): Konjunktiv II, Nebensätze/Konnektoren,
  Relativsätze, Passiv, Verben+Präposition/Genitiv, Konjunktiv II der Vergangenheit — progresión desde A2.
  Autoría por profesores nativos IA + rebalanceo/revisión adversarial nativa (0 errores lingüísticos tras la
  pasada). Sube alemán de "A1+A2" a **A1→B1** con cadena verificada (verify_b1_chain de). **Diferido: B1 nl**
  (andamiaje listo; retome exacto en FINDINGS.md). B2+ de/nl no existe aún.

## Inmersión completa 6/6 + tips pt A2/B1 (2026-07-03)
- **Historias A1 pt/de/nl (mig 109):** 1ª historia por idioma para pt/de/nl → **los 6 cursos con input
  comprensible / inmersión** (antes solo es→en + fr/it). Cada una A1, 7 segmentos con audio del idioma +
  preguntas de comprensión autocalificables, culturalmente relevantes (padaria carioca, Bäckerei berlinesa,
  café en bici de Ámsterdam). Validación adversarial nativa (0 errores reales). Course-scoped verificado.
- **Tips es→pt A2/B1 (mig 108):** cierran la capa de tips de pt hasta B1 (18 tips A1+A2+B1); refuerzan
  los puntos gramaticales clave por unidad (pretérito perfeito, futuro «vou», ser/estar, imperfeito,
  subjuntivo, relativos, comparativos). Sube la dimensión de **andamiaje explícito** de pt A2/B1.
- **Diferido:** 2ª historia por idioma + historias B1+; B1 de/nl (hoy A1+A2).

## Capa "enseña" — tips A2 de/nl + historias fr/it (2026-07-03)
- **Tips A2 de/nl (mig 106):** completan la capa de tips A1+A2 en los 4 pilotos. **Historias/inmersión
  (mig 107):** 1ª historia por idioma para fr/it (input comprensible A1, 7 segmentos con audio del idioma
  + preguntas de comprensión autocalificables). Sube la dimensión de **input comprensible / inmersión**
  (clave en la Metodología) de fr/it — antes cero fuera de es→en. Course-scoped verificado.

## Capa "enseña" — tips A1 fr/it/de/nl (2026-07-03)
- El tip post-lección (refuerza el "enseña, no solo evalúa") existía solo es→en. Sembrados **24 tips
  A1** (6/curso × fr/it/de/nl, mig 102): uno por unidad con el punto gramatical clave del idioma
  (edad ser/tener, partitivo/acusativo, hora + falsos amigos, contracciones, de/het). Course-scoped
  (get_lesson_tip por jz_active_course) → verificado cliente real que cada curso ve el suyo. Sube la
  dimensión "explícita/metacognitiva" de fr/it/de/nl a la par de en. Diferido: pt (topics del pipeline
  L/S), A2 fr/it, historias.

## Pilotos es→de + es→nl A2 (2026-07-03) — continúa la escalera, mismo balance
- **de A2 y nl A2:** R36 · W36 · **L25 · S18** → L=69%, S=50% (idéntico al A1). 115 ítems/idioma, 6
  unidades (order 7-12) encadenadas con A1 (gating verificado con caminata de 12 unidades cliente real).
  Currículo A2 CEFR real: Perfekt/Perfectum (haben/hebben→sein/zijn con concordancia), futuro, comparativo
  (als/dan, Umlaut), Präteritum/imperfectum, cuerpo+salud (wehtun dativo / hoofdpijn compuesto, consejos).
  Revisión adversarial nativa: de 0 errores (1 pulido), nl 0 errores. Techo determinista de producción
  idéntico (speaking proxy; writing tolerante) → sin cert de nivel aún. **Diferido:** B1+ de/nl.

## Pilotos es→de + es→nl A1 (2026-07-03) — 4 habilidades balanceadas desde el arranque
- **de A1 y nl A1:** R36 · W36 · **L25 · S18** → L=69%, S=50% de (R+W)/2 (idéntico al molde fr/it).
  115 ítems/curso, 6 unidades A1 con progresión temática (saludos→ciudad). Gramática CEFR-A1 real por
  idioma: alemán (género der/die/das, **edad con sein**, mayúsculas de sustantivos, acusativo ein/einen,
  ß/ä/ö/ü) y neerlandés (**de/het**, **edad con zijn**, diminutivos -je, orden V2). Autorado por workflow
  ultracode (profesores nativos IA) + validación adversarial nativa (de 2 fixes menores, nl 3 reales, todos
  aplicados). **Techo determinista de producción idéntico** (speaking=proxy read-aloud; writing tolerante) →
  sin cert de nivel aún (Fase 2). **Diferido:** A2+ de/nl.

## Pilotos es→fr + es→it A2 (2026-07-02) — continúa la escalera, mismo balance
- **fr A2 y it A2:** R36 · W36 · **L25 · S18** → L=69%, S=50% de (R+W)/2 (idéntico al A1). 115 ítems/idioma,
  6 unidades (order 7-12) que ENCADENAN con A1 (gating por checkpoints, verificado con caminata de 12
  unidades cliente real). Currículo A2 CEFR real: passé composé/passato prossimo (avoir/avere→être/essere
  con concordancia), futur/futuro, comparativos, imparfait/imperfetto, pronombres objeto (COD/diretti),
  «avoir mal à»/«avere mal di», consejos (il faut/bisogna, devrais/dovresti). Validación nativa: 0 errores
  reales en A2 (fr e it). **Techo determinista de producción idéntico** (speaking=proxy; writing tolerante)
  → sin cert de nivel A2 aún (Fase 2). **Diferido:** B1+ fr/it.

## Pilotos es→fr + es→it A1 (2026-07-02) — 4 habilidades balanceadas DESDE el arranque
- **fr A1:** R38 · W36 · **L23 · S18** → L=62%, S=49% de (R+W)/2. **it A1:** R36 · W36 · **L25 · S18** →
  L=69%, S=50%. Es decir: **NO nacen con el sesgo 3:1** — el balance L/S de es→en/pt se aplicó desde el
  diseño (criterio: listening ~65% de R/W, speaking ~50% como proxy). 115 ítems/curso, 6 unidades A1 con
  progresión temática (saludos→ciudad), gramática real por idioma (fr: género/contracciones/être-avoir;
  it: articoli/partitivo/preposizioni articolate/avere-per-l'età). Audio TTS completo (fr 41, it 43).
- **Eficacia A1:** cobertura de funciones comunicativas A1 (presentarse, edad/origen, familia, pedir en
  un café, hora/rutina, orientarse) + las 4 habilidades entrenadas. Validación adversarial nativa: fr 1
  error corregido, it 0 errores. **Techo determinista de producción idéntico** al resto (speaking=proxy,
  writing=translation/cloze tolerantes) → sin cert A1 fr/it aún (Fase 2). **Diferido:** A2+ fr/it,
  reaparición de léxico entre unidades, banco de placement fr/it.

## Hallazgo estructural sistémico (TODOS los niveles, ambos cursos)
- **Balance de habilidades sesgado ~3:1.** Por nivel: Reading ~74 · Writing ~74 · **Listening 24 ·
  Speaking 24** (4/unidad). Lectura/escritura reciben ~3× la práctica de escucha/habla. Para
  *subir de verdad* las 4 habilidades, L/S están **subservidos** — es el hueco clásico.
- **Techo determinista de producción (honesto).** Speaking es un **proxy** (read-aloud, no califica
  producción oral). Writing se evalúa con translation/cloze tolerantes (no redacción libre). Así, la
  competencia **productiva real** (hablar/redactar) de CADA nivel depende de **Fase 2** (evaluación
  por IA/humano). El contenido entrena reconocimiento y producción guiada; no certifica producción libre.
- **Retención:** ~78 palabras/nivel + SRS (rescate de palabras) recicla vocabulario vencido. Adecuado
  pero modesto; conviene más reaparición explícita de léxico entre unidades (diferido).

## es→en A1 — veredicto: **SÍ con reservas**
Sí con reservas. El A1 cubre el núcleo comunicativo del MCER (saludos, presentarse, edad/origen, familia, comida/café, hora/días/rutina, lugares/direcciones) con las funciones esenciales y un loop de 4 habilidades por unidad. Lleva a un usuario que puede interactuar de forma básica. Las reservas son gramaticales y sistémicas, no de contenido suelto: faltan piezas que el MCER A1 da por enseñadas (a/an según sonido, plurales regulares como sistema, presente continuo, present simple 3ª persona con -s en afirmativa, this/that/these/those completo, números >20 / decenas) y la evaluación está sesgad

**Huecos de cobertura:**
  - **[P1] Presente continuo (am/is/are + -ing) NO se enseña en absoluto** — El MCER A1 espera que el alumno describa lo que está pasando ahora ('I am eating', 'She is reading'). No hay ni un solo ítem ni topic con -ing en todo el nivel.
  - **[P1] Present simple 3ª persona del singular con -s en AFIRMATIVA (he works, she likes, it costs) no se practica como sistema** — El present simple aparece solo en 1ª persona ('I get up', 'I work', 'I like', 'I study') y en negativa de gustos ('I don't like'). El alumno nunca produce 'he w
  - **[P1] Plurales regulares (-s/-es) no se enseñan como punto explícito; artículo a/an según sonido vocálico tampoco** — Los plurales aparecen incidentalmente ('cats', 'books', 'apples', 'dollars', 'friends', 'days') pero nunca hay un ítem que enseñe la regla singular→plural ni qu
  - **[P2] this/that incompleto: faltan los plurales these/those, y números altos (treinta, cuarenta… cien) y orden de decenas** — La unidad 3 enseña this/that pero nunca these/those, que el MCER A1 incluye como sistema demostrativo completo. En números, se enseñan 1-12, 15, 20 sueltos, per
  - **[P2] Evaluación sesgada al reconocimiento; checkpoints no exigen producción libre real** — La mayoría de checkpoints son multiple_choice, match o cloze de una sola palabra (alta tasa de acierto por adivinación / pistas). La producción escrita real (tr

**Progresión:** El orden de las 6 unidades es pedagógicamente correcto y construye en escalera: U1 to be (I am/you are) y saludos → U2 reintroduce to be en preguntas (Are you…?, respuestas cortas) + números/origen → U3 amplía a he/she/they is/are + have + 
**Evaluación:** Cada unidad incluye checkpoints en las 4 habilidades (reading, writing, listening, speaking aparecen marcados con ltype='checkpoint'), lo cual es estructuralmente correcto para certificar A1. Limitaciones reales: (a) listening y speaking es

**Arreglado (mig 071, sin audio):** 14 ítems nuevos que rellenan los huecos P1 — presente continuo
básico (am/is/are+-ing), 3ª persona -s como sistema (he works/she likes), plurales y a/an, these/those,
números altos — cableados a la lección de su (unidad, tema). Entran al loop y al pool del examen.

## es→en A2 — veredicto: **SÍ con reservas**
sí con reservas

**Huecos de cobertura:**
  - **[P1] Conectores de causa/consecuencia y secuencia (because, so, then, but) prácticamente ausentes como ítem enseñado** — El CEFR A2 exige enlazar oraciones con 'and, but, because, so' (descriptor: 'can link groups of words with simple connectors'). En el nivel solo aparece 'and' d
  - **[P1] Present perfect: 'yet' nunca aparece y 'just' solo figura como alternativa aceptada, nunca como objetivo evaluado** — El topic 'present_perfect_intro' (U12) promete 'ever/never/just/already/yet' pero solo entrena activamente ever/never/already/been. 'yet' (negativas/preguntas: 
  - **[P2] 'a lot of / lots of' y la distinción much/many no contable–contable no se consolidan como objetivo; 'a lot' solo es distractor** — El topic 'quantities' (U10) cubre some/any/much/many/a little, pero 'a lot of' —explícitamente listado como esperado A2 y el cuantificador afirmativo más frecue
  - **[P2] Adverbios de modo (-ly: slowly, quickly, carefully, well/badly) no se enseñan como punto** — El prompt lista 'adverbios' como contenido A2 y el CEFR A2 incluye adverbios de modo regulares (adjetivo+ly) y la diferencia good/well. En el nivel 'slowly' apa
  - **[P2] Past continuous básico ausente (sin 'was/were + -ing', sin contraste con past simple via 'when/while')** — El prompt lo nombra como 'past continuous básico' esperado en A2. No existe ningún ítem 'was/were + verb-ing'. Es defendible omitirlo (muchos sílabos lo sitúan 

**Progresión:** Sólida y bien escalonada sobre A1. Las 6 unidades (7–12) construyen de forma coherente: U7 pasado (to be → regular → irregular → preguntas/negativas con did), U8 futuro (going to → will → invitaciones/expresiones de tiempo), U9 viajes (tran
**Evaluación:** Los checkpoints (ltype='checkpoint') miden A2 razonablemente, pero de forma DESIGUAL entre unidades y con un sesgo de habilidades. Patrón observado: el checkpoint de cada unidad reutiliza ítems del primer topic de la unidad (ej. U7 = solo p

**Arreglado (mig 071, sin audio):** 15 ítems nuevos — conectores because/so/but, present perfect
'yet', a lot of / much-many, adverbios -ly (slowly) — cableados a su lección. Entran al loop y al examen.

## es→en B1 / B2 / C1 — auditoría HECHA (2026-06-25, panel CEFR por unidad) ✅
Mig 080/081/082. Detalle + evidencia en FINDINGS.md.
- **B1 — SÍ con reservas.** Cobertura gramatical/funcional B1 sólida y bien secuenciada (present perfect +
  for/since + used to, going to/will, opinión + reported speech, relativos + past continuous, condicionales +
  modales, pasiva + 2º condicional). Sin huecos estructurales; **11 huecos** de alto impacto rellenados.
- **B2 — SÍ con reservas** (receptiva + producción guiada). Sílabo B2 íntegro (PPC/past perfect, reported
  speech a fondo, causativo/pasivas, condicionales mixtos/3º/wish, relativas defining/non-defining, deducción
  must/might have + phrasal verbs). **12 huecos** rellenados.
- **C1 — andamiaje C1 sólido para lo RECEPTIVO; NO C1 productivo pleno (honesto).** Temario C1 genuino
  (near-synonyms/connotación, hedging, cleft/inversión, modismos/registro, modalidad avanzada, académico).
  **11 huecos** rellenados. **Techo:** R/L/vocab/gramática se autocalifican a C1; writing/speaking LIBRES
  requieren Fase 2 (IA/humano) → sin cert C1 de 4 skills (por diseño). El read-aloud entrena pronunciación,
  no certifica fluidez.
- **Balance L/S** subido a objetivo (listening ~62–69% de R/W, speaking ~50%): +4L/+2S por unidad, +108 ítems
  con audio TTS, verificados (mueven dominio L/S; cliente real). Mismo sesgo 3:1 → **resuelto** en A1–C1.

## es→pt A1 / A2 / B1 — auditoría HECHA (2026-06-25, panel CEFR-pt por unidad) ✅
Mig 083/084/085. Detalle + evidencia en FINDINGS.md. (Antes: la verificación había destapado y arreglado
una regresión P0 de examen multicurso — mig 064→**072** restauró `jz_active_course()`.)
- **pt A1 — SÍ con reservas.** Temario/gramática A1 suficientes y bien secuenciados para A1 funcional en
  portugués de Brasil (ser/ter/posesivos/regulares/querer/poder/ficar). 12 huecos rellenados.
- **pt A2 — sí con reservas.** Sílabo A2 sólido (pretérito perfeito reg./irreg., ir+infinitivo, viaje,
  restaurante/comparativos, salud/present perfect). 11 huecos.
- **pt B1 — sí con reservas** (receptiva + producción guiada). Espinazo B1 correcto (imperfeito vs
  perfeito, cortesía gostaria/poderia, **presente do subjuntivo**, relativos, se-passive, voz pasiva,
  discurso indirecto). 11 huecos.
- **Balance L/S** subido a objetivo (listening 61–72% de R/W, speaking 49–57%): +4L/+2S por unidad,
  +108 ítems con audio **tl=pt**, verificados con cliente real **multicurso** (mueven dominio L/S en el
  curso pt; 0 fuga al curso en). **Sesgo 3:1 resuelto en es→pt.** Pendiente: es→pt B2/C1 (no sembrados).

## Qué difiero y por qué (punto de retome exacto)
1. **Equilibrar L/S** — ✅ **HECHO en AMBOS cursos** (2026-06-25): es→en A1–C1 (mig 078–082) + es→pt A1–B1
   (mig 083–085) = +312 ítems L/S + 312/312 audio TTS, validados adversarialmente, verificados con cliente
   real (mueven dominio L/S; pt multicurso). Pendiente: es→pt B2/C1 (no sembrados).
2. **Auditoría de eficacia es→en B1/B2/C1** — ✅ **HECHA** (mig 080–082): cobertura sólida; 34 huecos; C1 techo honesto.
3. **Auditoría de eficacia es→pt A1/A2/B1** — ✅ **HECHA** (2026-06-25, mig 083–085; ver arriba + FINDINGS.md):
   cobertura sólida en los 3; 34 huecos; multicurso verificado (contenido pt→curso pt).
4. **Retención:** más reaparición explícita de léxico entre unidades.
5. **Evaluación:** checkpoints menos sesgados a reconocimiento (más producción guiada).
6. **Placement es→pt** — ✅ **HECHO** (2026-07-02, mig 093): antes el placement PRECISO era solo
   es→en (banco 48 ítems). Ahora es→pt tiene banco propio de ubicación (42 ítems A1/A2/B1 ×
   7R+7W, pt-BR, curso `…0002`, tag `placement`), validado adversarialmente (profesor pt-BR:
   39/42 impecables; fix de regência "assistir **a**"; distractores endurecidos) y con guardas
   anti-colisión de `jz_near_match` (cloze sin distractor a distancia-1). `placement_next(p_course=pt)`
   ubica A1/A2/B1 correctamente + techo honesto en B1 (el curso pt tope B1). Determinista 42/42,
   multicurso sin fuga (`verify_placement_pt.py`, cliente real). **Diferido:** cablearlo a un
   onboarding/re-placement pt (onboarding es en-only Fase 1) + L/S en placement (audio).

## Verificación
- Ítems nuevos: 29/29 válidos contra el grader; grade_item acepta lo correcto y rechaza lo erróneo
  (cliente real); en lecciones (29/29) y pool de examen (29/29). correct_answer 42501.
- Validador determinista **0** (es→en). verify_chain es→en PASS. verify_pt_chain PASS (tras mig 072).
- analyze 0 · tests verdes · gh run list SUCCESS · deploy READY · loop/seguridad/ligas intactos.
