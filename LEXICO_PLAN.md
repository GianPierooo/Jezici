# LEXICO_PLAN.md — Ampliar el léxico de ~480 a un B2 real (~4.000-5.000)

> Análisis y plan (2026-07-17). **Solo lectura: cero contenido generado en esta pasada.**
> Fuentes: BD real (queries de este análisis), PRACTICAR_SRS_ANALISIS.md §5, reporte mig 166,
> investigación de fuentes externas (enlaces al final). Decide Gian.

## 0 · Ground truth (BD real, 2026-07-17)

| curso | `vocabulary` | **vinculadas** (`lesson_vocab` = enseñadas, no inertes) | sueltas (≈inertes) | de mig 166 | unidades | lecciones | ítems | **palabras nuevas / lección** |
|---|---|---|---|---|---|---|---|---|
| en | 486 | **424** | 62 | 18 | 30 | 151 | 1.324 | **2,8** |
| pt | 542 | **417** | 125 | 63 | 30 | 150 | 1.066 | **2,8** |
| nl | 489 | **344** | 145 | 9 | 30 | 150 | 572 | 2,3 |
| fr | 514 | **342** | 172 | 34 | 30 | 150 | 572 | 2,3 |
| it | 501 | **335** | 166 | 21 | 30 | 150 | 572 | 2,2 |
| de | 490 | **322** | 168 | 9 | 30 | 150 | 572 | **2,1** |

(La media "8-18 palabras por lección" que da la BD incluye REPETICIONES entre lecciones; el dato
que importa es **distintas nuevas por lección = vinculadas ÷ lecciones ≈ 2,1-2,8**.)

**El dato clave, respondido: el cuello de botella es el CONTENIDO, no el vocabulario.**
- `vocabulary` ya tiene ~486-542 filas/curso con traducciones REVISADAS (seed autorado con los
  cursos + la cosecha verificada de mig 166) — pero solo se ENSEÑAN las vinculadas (322-424).
- La derivación de `lesson_vocab` (mig 165/166) ya exprimió el contenido existente: **no queda
  jugo que extraer sin escribir ítems nuevos**. Las 62-172 sueltas/curso tienen traducción
  confiable pero NINGÚN ítem las enseña → inertes por definición del SRS lesson-driven.
- El techo real HOY no es "480 palabras": es **322-424 palabras enseñadas por curso**.

## 1 · La tensión central, cuantificada

El SRS es **lesson-driven por diseño** (correcto: jamás enseñar una tarjeta que el curso no
enseñó). Por tanto "ampliar léxico" == "ampliar CONTENIDO que enseñe palabras". Con el formato
actual (lecciones de gramática que introducen ~2,1-2,8 palabras nuevas), llegar lejos es
imposible: **a 2,5/lección, 4.000 palabras = 1.600 lecciones/idioma** (10× el curso entero).

La palanca es la **DENSIDAD**: una lección DE VOCABULARIO dedicada (match de traducción + cloze
+ word_bank + word, el formato que ya existe y que `get_lesson_intro`/F2 ya explotan solos)
enseña honestamente **~8-12 palabras nuevas** con ~8-10 ítems.

**Factura de contenido por objetivo (por idioma, partiendo de ~370 enseñadas de media):**

| objetivo | palabras nuevas | lecciones vocab (10/lección) | ítems (~9/lección) | + audio TTS |
|---|---|---|---|---|
| **700** (cerrar A2 sólido) | ~330 | ~33 (≈7 unidades) | ~300 | ~100 clips |
| **1.500** (B1 honesto) | ~1.130 | ~110-140 (≈22-28 unidades) | ~1.000-1.250 | ~350 clips |
| **4.000** (B2 real) | ~3.630 | ~360-450 (≈72-90 unidades) | ~3.200-4.000 | ~1.100 clips |

×6 idiomas: 1.500 ⇒ **~6.500-7.500 ítems nuevos**; 4.000 ⇒ **~20.000-24.000 ítems** — esto
último es **~4× TODO el contenido construido hasta hoy** (5.182 ítems en 3 meses). No hay
atajo aritmético: un B2 real es una factura de contenido enorme, se haga como se haga.

**Sinergia obligatoria con F3:** cada palabra nueva debería entrar con su oración-ejemplo (cloze)
y su audio — así la factura F3 (~2.664 oraciones para el léxico ACTUAL) no se duplica después
para el léxico nuevo. Léxico nuevo sin oración = repetir la deuda que hoy limita las tarjetas
cloze al 7%.

## 2 · Las opciones reales, con su factura honesta

### (a) Fuente de léxico bilingüe de alta frecuencia ya revisada por humanos — **NO EXISTE usable**
Investigado (no asumido):
- **KELLY** (el mejor candidato académico: 9.000 palabras/idioma con CEFR + pares bilingües,
  CC-BY-SA): sus 9 idiomas son árabe, chino, inglés, italiano, griego, noruego, polaco, ruso y
  sueco — **NO incluye español** ni fr/de/nl/pt. De nuestros 6 solo toca en/it, y SIN pares con
  español. Descartada como fuente directa.
- **Diccionarios de frecuencia Routledge / Oxford 3000-5000 / listas Goethe-Zertifikat**:
  exactamente lo que haría falta (frecuencia + CEFR + revisión editorial), pero **©
  propietario sin licencia** de redistribución. Usarlos sería infracción. Descartados.
- **Wikdict / FreeDict / Wiktionary** (CC-BY-SA, 17M+ traducciones): licencia usable, PERO
  calidad comunitaria variable, sin CEFR, con ambigüedad de acepciones (el fallo
  'Brazil'='Brazilian' a escala). Sirven como **INSUMO para curación palabra-por-palabra**,
  jamás como volcado directo — y curar 3.600 palabras × 6 idiomas a mano ES la factura (b).
- **Tatoeba** (CC-BY, oraciones HUMANAS con traducción; 276 pares con >10k oraciones; es↔en
  enorme, es↔de/nl/fr/it/pt bien servidos): la **mejor materia prima cero-IA que existe** —
  pero es un banco de ORACIONES, no una lista curada de palabras con CEFR. Su papel natural es
  **F3** (oraciones-ejemplo + contexto), filtrando por dueño nativo identificado + curación.

**Veredicto (a): no existe una lista bilingüe es↔{en,pt,fr,it,de,nl} de alta frecuencia, con
traducciones revisadas por humanos Y licencia usable.** Lo más cercano (Wikdict/Tatoeba)
requiere curación humana o con agentes → colapsa en las opciones (b)/(c).

### (b) Autoría con el workflow de la casa — **el camino probado; nómbrese con honestidad**
El "workflow de nativos + revisor que ya se usó" 15 veces (los 6 cursos A1→C1) **ES autoría por
agentes IA** (6 profesores nativos-IA + 2 revisores adversariales nativos-IA) + guardas
deterministas (anti-colisión, near-match) + **verificación con cliente real**. Ese pipeline
produjo los 5.182 ítems en producción y su calidad está validada por los fixes reales que la
revisión adversarial cazó en cada tanda. El "cero IA" del producto siempre significó *runtime*
y *volcados sin verificar* — no este pipeline.
- **Velocity histórica medida:** ~1 nivel (6 unidades, ~114 ítems + audio + verify) por día de
  sesión. → **1.500/idioma ≈ 3,5-5 días/idioma ≈ 21-30 días los 6.** 4.000/idioma ≈ +8-11
  días/idioma más ≈ **50-65 días los 6** (a tiempo completo del agente, con Gian revisando por
  muestreo).
- **Riesgo de enseñar mal: bajo-medio y acotado** — mitigado por doble revisión adversarial +
  guardas + verify por función; el precedente 'Brazil'='Brazilian' define el tipo de fallo a
  vigilar (ambigüedad de acepción/registro). Se añade una guarda nueva: todo lote de palabras
  pasa un **muestreo humano de Gian (≥5%)** antes del apply.
- **Escala a los 6 idiomas:** sí (ya lo hizo).

### (c) Humanos nativos (freelance/profesores reales) — máxima garantía, factura inviable hoy
Un redactor profesional de ítems produce ~50-100 ítems buenos/día. 1.000-1.250 ítems/idioma =
**10-25 días-persona/idioma** + reclutar/gestionar 6 nativos + dinero real (a tarifas típicas
de item-writing, miles de USD por idioma). Para un proyecto de un dev sin presupuesto, **no
escala**. Queda como opción para AUDITORÍA por muestreo (contratar 1 nativo/idioma unas horas
para revisar el 5-10% de cada lote) — el mejor uso de dinero humano por unidad de riesgo.

## 3 · Recomendación por fases (realista)

**FASE 0 — "cosechar lo sembrado" (cero IA, días, sin factura grande):**
vincular las **~840 palabras sueltas** (62-172/curso) que YA tienen traducción revisada del
seed: generar por SQL/plantilla ítems `match` de traducción (4-5 pares/ítem) + 1 lección de
vocabulario nueva por unidad existente que los cuelgue (la derivación F2 los vincula sola).
Sube el techo a **~486-542 enseñadas/curso (+15-40%)**. Es la mig 166 llevada a su límite:
después de esto, el contenido actual está EXPRIMIDO del todo. ~2-3 días los 6 idiomas.

**FASE 1 — objetivo intermedio honesto: ~1.000-1.500 enseñadas/idioma (workflow (b)):**
unidades DE VOCABULARIO temáticas (comida, trabajo, salud, viaje…) con el pipeline probado,
**cada palabra con su oración-ejemplo + audio** (paga F3 de paso para el léxico nuevo).
Por tandas de 1 idioma×1 tema, con verify real por tanda y muestreo humano ≥5%.
**~3,5-5 días/idioma.** Orden: **en → pt → fr → de → it → nl** (en = par principal y usuarios
reales hoy; pt = 2º con más tracción de contenido; fr/de demanda típica; it/nl al final).
Hito de control: medir retención/uso real del SRS con los primeros usuarios ANTES de pasar
del primer idioma al resto.

**FASE 2 — B2 real (~4.000): solo si la Fase 1 demuestra uso.**
+8-11 días/idioma más del mismo pipeline (**50-65 días los 6**), o meses y miles de USD con
humanos. **No empezarla antes de tener usuarios reteniendo**: sería construir un almacén para
una tienda sin clientes.

**La verdad incómoda, con números:** no hay vía a un B2 real que no sea (i) el pipeline de
agentes con revisión adversarial + verificación (semanas de trabajo del agente) o (ii) meses
de autoría humana con dinero. La opción "encontrar una lista lista para usar" **no existe**
para estos 6 pares con licencia legal. La Fase 0 es lo único casi-gratis que queda, y da +15-40%,
no ×10.

## 4 · Notas de integración (para cuando se ejecute)
- Las lecciones de vocabulario nuevas se cuelgan de unidades EXISTENTES (no rompen la cadena de
  gating; los checkpoints siguen sacando de su tag `unidadN`) o de unidades nuevas apendizadas
  por nivel — decidir al diseñar la Fase 1, con verify de cadena (verify_chain/pt_chain).
- `frequency_rank` de lo nuevo: continuar la convención de mig 166 (orden de introducción ×30).
- Guardas obligatorias por lote: anti-colisión near-match, término≠traducción, prompt de
  traducción explícito, muestreo humano ≥5%, `verify_srs_f2` + cadena verde.

## Fuentes
- [KELLY — proyecto y listas](https://spraakbanken.gu.se/en/projects/kelly) · [descripción/9 idiomas](https://ssharoff.github.io/kelly/) · [paper](https://link.springer.com/article/10.1007/s10579-013-9251-2)
- [Tatoeba — descargas y licencia CC-BY](https://tatoeba.org/en/downloads) · [Wikipedia](https://en.wikipedia.org/wiki/Tatoeba) · [pares bilingües](https://www.manythings.org/anki/)
- [WikDict — about/licencia](https://www.wikdict.com/page/about) · [generador](https://github.com/karlb/wikdict-gen) · [FreeDict](https://freedict.org/)
