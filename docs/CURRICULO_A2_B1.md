# Jezici — Currículo es→en (A2 · B1 · B2 sembrados)

> Generado en GRAN AVANCE 3 · Item 1. Mismo formato exacto que A1 (Unidades 1–6).
> Fuente de verdad: `tools/content/a2_units.mjs` → `tools/content/gen_a2.mjs`
> (valida contra el grader determinista) → migración `030_seed_a2.sql`.
> El examen de nivel ahora es multi-nivel (`031`): A1 → certificado → A2 → …

## Metodología (igual que A1)
Alta frecuencia → frases → oraciones, en contexto, con las **4 habilidades**
(reading / listening / writing / speaking). Cada unidad: **4 lecciones × 8 ítems**
(3 reading + 3 writing + 1 listening + 1 speaking) + **checkpoint** cronometrado
(toma 3R + 3W + 2L + 2S, umbral 80%). Listening con audio TTS fijo en Storage;
speaking verificado con Web Speech (comparación determinista). Scoring 100%
server-side.

## A2 — sembrado (Unidades 7–12 · 192 ítems · 84 palabras de vocabulario)

| # | Unidad | Escenario | Gramática | Lecciones |
|---|--------|-----------|-----------|-----------|
| 7  | El pasado: lo que hice | Contar lo de ayer / el finde | was/were, pasado regular (-ed), irregulares (went/had/saw), did/didn't | Ayer · Regulares · Irregulares · Preguntas y negativos |
| 8  | Planes y futuro | Quedar, planear, predecir | going to, will, Let's / Why don't we, expresiones de tiempo | Going to · Will · Invitar · Cuándo |
| 9  | De viaje | Aeropuerto, transporte, hotel, direcciones | preposiciones de lugar, imperativos (direcciones), can/could (pedidos) | Transporte · Direcciones · Hotel/aeropuerto · Pedir ayuda |
| 10 | Comer fuera y comprar | Restaurante, compras, dinero | would like, some/any, much/many, comparativos | Restaurante · Cantidades · Comprar · Comparar |
| 11 | Personas y descripciones | Describir gente y lugares | presente continuo (ahora), adjetivos, superlativos | Apariencia · Personalidad · Presente continuo · Superlativos |
| 12 | Salud, experiencias y consejos | En el médico, dar consejos, experiencias | should/shouldn't, present perfect (ever/never/already), ago | El cuerpo · Consejos · Experiencias · Contar una historia |

**Cadena verificada end-to-end** (RPC reales, usuario de prueba):
A1 (6 checkpoints + 4 skills) → examen A1 (20 ítems) → certificado **JZC-A1-…** →
el examen de nivel avanza solo a **A2** → A2 (6 checkpoints + 4 skills) →
examen A2 (20 ítems A2) → certificado **JZC-A2-…**. (`tools/content/verify_chain.py`).

## B1 — SEMBRADO COMPLETO (Unidades 13–18 · 192 ítems)

> **✅ Sembrado** en `043_seed_b1.sql` (+ fixes de QA en `044`). Autorado + QA
> adversarial multi-agente (`b1_units.json` → `gen_b1.mjs` → valida contra el
> grader). 4 lecciones × 8 ítems + checkpoint por unidad; cefr 'B1', order 13–18.
> Cadena verificada A1 → A2 → **B1** (examen + cert **JZC-B1-…**, modelo per-skill).
> Export humano en `docs/CONTENT_EXPORT.md`.

| #  | Unidad | Gramática B1 (en contexto) |
|----|--------|----------------------------|
| 13 | Rutinas, hábitos y experiencias | present perfect (ever/never, just/already/yet, for/since), pasado simple vs present perfect, used to |
| 14 | Trabajo, estudios y planes | primer condicional, present perfect continuous, be going to vs will |
| 15 | Opiniones y acuerdos | so/neither do I, estilo indirecto (intro), verbos de opinión |
| 16 | Historias y viajes | pasado continuo vs pasado simple (while/when), cláusulas relativas (who/which/that) |
| 17 | Problemas y soluciones | condicional 0 y 1, modales de obligación (must/have to/should/can't) |
| 18 | Cultura, medios y futuro | voz pasiva (intro), segundo condicional (intro), comparativos avanzados (as…as) |

### Historial: B1 antes era esqueleto (`032_b1_skeleton.sql`, sólo `units.description`).

| #  | Unidad | Objetivo / alcance (B1) |
|----|--------|--------------------------|
| 13 | Rutinas, hábitos y experiencias | present perfect (for/since, just/already/yet), pasado simple vs present perfect, used to |
| 14 | Trabajo, estudios y planes | primer condicional, present perfect continuous (intro), be going to vs will |
| 15 | Opiniones y acuerdos | so/neither do I, estilo indirecto (intro), verbos de opinión |
| 16 | Historias y viajes | pasado continuo vs pasado simple (while/when), cláusulas relativas (who/which/that) |
| 17 | Problemas y soluciones | condicional 0 y 1, modales de obligación (must/have to/should/can't) |
| 18 | Cultura, medios y futuro | voz pasiva (intro), segundo condicional (intro), comparativos avanzados (as…as) |

## B2 — SEMBRADO COMPLETO (Unidades 19–24 · 192 ítems) · cierra la escalera es→en

> **✅ Sembrado** en `045_seed_b2.sql`. Autorado + QA pedagógica + verificación
> adversarial multi-agente (workflow `b2-author-content`: 6 autores + 6 revisores
> pedagógicos + 6 escépticos adversariales → `b2_units.json` → `gen_b2.mjs` →
> valida contra el grader). 4 lecciones × 8 ítems (12 reading / 12 writing /
> 4 listening / 4 speaking) + checkpoint por unidad; cefr 'B2', order 19–24,
> dificultad 0.50–0.75. **57 correcciones pedagógicas + 38 fixes adversariales**
> aplicados antes de sembrar.
> Cadena verificada A1 → A2 → B1 → **B2** (examen + cert **JZC-B2-…**, las 4
> habilidades pasan a C1, tope de la escalera sembrada). Export en
> `docs/CONTENT_EXPORT.md`.

| #  | Unidad | Gramática B2 (en contexto) |
|----|--------|----------------------------|
| 19 | Logros y trayectoria | present perfect continuous (How long…?, for/since), past perfect, past perfect vs pasado simple |
| 20 | Lo que dijeron | estilo indirecto: say/tell, backshift, preguntas indirectas, órdenes y peticiones, cambios de tiempo/lugar |
| 21 | Cómo se hace y las noticias | voz pasiva (presente y pasado), agente con by, procesos/noticias, have something done |
| 22 | Hipótesis y arrepentimientos | tercer condicional, condicionales mixtos, I wish / if only + past perfect |
| 23 | Personas, lugares y definiciones | relativas especificativas y explicativas (who/which/that/whose/where), omisión del relativo objeto |
| 24 | Deducciones y debate | modales de deducción sobre el pasado (must/might/can't have), should/needn't have, phrasal verbs/colocaciones, argumentación |

**Cadena completa verificada end-to-end** (`tools/content/verify_chain.py`, RPC
reales): A1 → cert **JZC-A1** → A2 → cert **JZC-A2** → B1 → cert **JZC-B1** →
B2 → cert **JZC-B2** (las 4 habilidades a C1). Examen de nivel B2 dinámico
(`start_level_exam`/`submit_level_exam` ya soportan B2 sin cambios de esquema:
seleccionan ítems `cefr_level='B2'`, tope C2). Modelo per-skill intacto
(test de divergencia PASS). Validador determinista: **0 hallazgos** (A1 u3-6 +
A2 + B1 + B2).

### Histórico: cómo se desarrollaron B1 y B2
1. Contenido autorado en `tools/content/b{1,2}_units.json` (workflow multi-agente).
2. `node tools/content/gen_b{1,2}.mjs` (`cefr_level`, `order_index`, ids con
   prefijo propio, dificultad por nivel) → valida contra el grader y emite SQL.
3. Aplicar (`tools/content/apply_sql.py`), extender `content_qa.py` y
   `verify_chain.py`, y subir audio TTS (`gen_audio.py`, filtro por nivel).
