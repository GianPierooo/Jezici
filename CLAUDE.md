# CLAUDE.md — Jezici (estado vivo)

> Contexto de arranque para cualquier sesión. **No** es copia de los 21 `.md` de
> diseño (eso es la carpeta raíz `Jezici_*.md` + `docs/`). Aquí va el ESTADO REAL,
> qué está verde, qué falta y cómo verificar. Mantener corto y al día.
> Última actualización: **2026-07-18**.

## LÉXICO Fase 1 · COMPLETA en los 6 idiomas — resumen (2026-07-18)
La Fase 1 de LEXICO_PLAN (autoría de vocabulario NUEVO con oración + audio) está **cerrada en los 6 cursos**
(mig 169-174). Pipeline idéntico por idioma: **10 agentes profesores nativos** (10 temas: comida, trabajo,
salud, viaje, ciudad, tiempo, compras, hogar, naturaleza, emociones) + **guardas deterministas** (dedup vs lo
enseñado, término≠traducción, oración-contiene-palabra, dedup entre temas, exclusión de cognados) + **5
revisores adversariales nativos** (género/artículo + falsos amigos + ortografía + acepción + CEFR) + mi
auditoría personal + **verify de cliente real + cadena verde**. Cada palabra = fila `vocabulary` + `cloze`
en contexto con **audio TTS** (paga F3) + `match`. Tag `vocab_f1` (NO unidadN → checkpoints/exámenes/placement
intactos). **Techo de léxico ENSEÑADO (lesson_vocab) por curso, antes→después de F0+F1:**

| curso | antes F0 | tras F0 | **tras F1 (HOY)** | Δ F1 | mig F1 |
|---|---|---|---|---|---|
| **fr** | 342 | 509 | **744** | +235 | 171 |
| **it** | 335 | 490 | **732** | +242 | 173 |
| **pt** | 417 | 535 | **726** | +191 | 170 |
| **en** | 424 | 484 | **716** | +232 | 169 |
| **de** | 322 | 489 | **714** | +225 | 172 |
| **nl** | 344 | 488 | **742** | +254 | 174 |

**Total enseñado F1: +1.379 palabras nuevas** (con oración + audio), sobre las +811 de F0. Los 6 cursos pasan
de ~322-424 enseñadas a **714-744**. Audio: **1.377/1.377 cloze con TTS HEAD 200** (en 232 · pt 191 · fr 235 ·
de 198 · it 240 · nl 252 — de tiene 29 y en/pt algunos como match+word por diseño). **Techo honesto:** para ir
hacia B2 real (~4.000) hace falta la Fase 2 de LEXICO_PLAN (50-65 días los 6, ~4× el contenido actual). **F1 es
la mejora grande y segura que quedaba; el léxico del seed queda EXPRIMIDO y ampliado.** Re-encolado: F2 (B2 real)
solo si la retención con usuarios reales lo justifica.

## LÉXICO Fase 1 · NEERLANDÉS — +254 palabras NUEVAS con oración + audio (autoría) ✅ LIVE (mig 174 · 2026-07-18)
La **ÚLTIMA** de la Fase 1. Réplica de en/pt/fr/de/it (mig 169-173) para **neerlandés SOLO**. Mismo pipeline: **10
agentes profesores NATIVOS de nl** (260, 10 temas) + **5 revisores adversariales** (artículo de/het + falsos
amigos + ortografía ij/ui/oe/ee/aa + acepción) + guardas + verify real. **NO toca scheduler/economía/placement/
certificación/otros 5 idiomas.**
- **PASO 0:** nl enseñaba **488** (max freq 716, 30 unidades A1–C1). Objetivo: +~225 de alta frecuencia por 10 temas.
- **FOCO nl — artículo de/het (de-woorden vs het-woorden):** cada sustantivo con su artículo correcto (parte de
  aprender la palabra). Verificado por los 5 revisores y mi auditoría: **de/het correcto en los 254** (het vlees,
  de ui, het gerecht, de baan, het salaris, de wang, het ziekenhuis, het gordijn, de kast, het weer…). Falsos
  amigos resueltos: de baan=empleo · de baas=jefe · passen=probarse · de room=nata · het gerecht=plato preparado ·
  de sollicitatie=solicitud de empleo · de rugzak=mochila · de vertraging=retraso · huren=alquilar.
- **Autoría + revisión:** 260 → guardas (dedup vs 435, término≠traducción, oración contiene palabra, dedup entre
  temas; **0 cognados** — nl comparte pocos con es) → **254** → 5 revisores adversariales: **5 fixes** (naturalidad:
  avondeten pleonasmo · aardappel plural · inpakken infinitivo partido · "naar bed gaan" sin artículo · "van zand"
  sin artículo), **0 drops**. Auditoría personal: 0 errores de género, 0 mistraducciones.
- **Contenido:** 312 content_items (252 cloze con audio TTS de **252/252** HEAD 200 + 60 match). Tag `vocab_f1`.
  28 lecciones "Vocabulario: <tema>" antes del checkpoint (A2/B1). lesson_vocab vincula. 2 palabras como match+word
  (de werknemer→plural, onderweg→mayúscula inicial en la oración).
- **Resultado:** enseñadas nl **488 → 742 (+254, +52%)**. `vocabulary` 489→743. **Nuevo techo del nl: 742.**
- **Verificado (`verify_lexico_f1_nl.py`, cliente real) TODO VERDE:** completar "Vocabulario" inscribe las nuevas
  (27/27), SRS las sirve como **cloze con audio** (HEAD 200), aislamiento 0 otro curso, economía un pago/lección
  (xp 41 oro 10). **`verify_c1_chain.py nl` (A1→C1, 30 unidades + audio) VERDE**, gating 30/30, 37/37 lecciones C1.
  analyze 0 · test 198/198 · build web OK. en/pt/fr/de/it intactos.
- **Muestra 5% (de/het + ortografía) en el reporte.** **Fase 1 COMPLETA en los 6 idiomas.**

## LÉXICO Fase 1 · ITALIANO — +242 palabras NUEVAS con oración + audio (autoría) ✅ LIVE (mig 173 · 2026-07-18)
Réplica de en/pt/fr/de (mig 169-172) para **italiano SOLO**. Mismo pipeline: **10 agentes profesores NATIVOS de
it** (260, 10 temas) + **5 revisores adversariales** (falsos amigos es↔it + género il/la/lo + acepción) + guardas
+ verify real. **NO toca scheduler/economía/placement/certificación/otros 5 idiomas.**
- **PASO 0:** it enseñaba **490** (max freq 716, 30 unidades A1–C1). Objetivo: +~225 de alta frecuencia por 10 temas.
- **es↔it es EL par MÁS cercano** → campo minado de falsos amigos. Resueltos correctos: il burro=mantequilla (NO
  burro) · il negozio=tienda (NO negocio) · la ditta=empresa · il capo=jefe · lo stipendio=sueldo · licenziare=
  despedir · la tappa=etapa · provare=probarse · il resto=cambio/vuelto · la borsa=bolso · la tenda=cortina ·
  imbarazzato=avergonzado (NO embarazada) · la gamba=pierna · salire=subir · il fegato=hígado · la ricetta=receta ·
  la meta=destino · l'affare=ganga · la gelosia=celos · il palazzo=edificio. **Género il/la/lo/l' verificado.**
- **Autoría + revisión:** 260 → guardas (dedup vs 462, término≠traducción, oración contiene palabra, dedup entre
  temas, **excluye cognados casi-idénticos edit-dist≤1** — farina/sangue/respirare/neve/ramo/geloso… 11) → **242**
  → 5 revisores adversariales: **3 fixes** (reformular oración de reflexivos ammalarsi/vergognarsi + l'aglio
  antinatural), **0 drops**. Auditoría personal: géneros 242/242 correctos, 0 mistraducciones.
- **Contenido:** 297 content_items (240 cloze con audio TTS de **240/240** HEAD 200 + 57 match). Tag `vocab_f1`.
  25 lecciones "Vocabulario: <tema>" antes del checkpoint (A2/B1). lesson_vocab vincula. 2 palabras quedan como
  **match+word (sin cloze)**: la oración usa la palabra en plural/como frase (a volte, il cuscino→cuscini).
- **Resultado:** enseñadas it **490 → 732 (+242, +49%)**. `vocabulary` 501→743. **Nuevo techo del it: 732.**
- **Verificado (`verify_lexico_f1_it.py`, cliente real) TODO VERDE:** completar "Vocabulario" inscribe las nuevas
  (21/21), SRS las sirve como **cloze con audio** (HEAD 200), aislamiento 0 otro curso, economía un pago/lección
  (xp 41 oro 10). **`verify_c1_chain.py it` (A1→C1, 30 unidades + audio) VERDE**, gating 30/30. analyze 0 · test
  198/198 · build web OK. en/pt/fr/de/nl intactos.
- **Muestra 5% (falsos amigos + género) en el reporte.** **nl ✅ cerrado (mig 174) → Fase 1 COMPLETA en los 6.**

## LÉXICO Fase 1 · ALEMÁN — +227 palabras NUEVAS con oración + audio (autoría) ✅ LIVE (mig 172 · 2026-07-18)
Réplica de en/pt/fr (mig 169-171) para **alemán SOLO**. Mismo pipeline: **10 agentes profesores NATIVOS de
de** (240, 10 temas) + **5 revisores adversariales** (género der/die/das + mayúscula + falsos amigos) + guardas
+ verify real. **NO toca scheduler/economía/placement/certificación/otros 5 idiomas.**
- **PASO 0:** de enseñaba **489** (max freq 726). Objetivo: +~225 de alta frecuencia por los 10 temas.
- **FOCO alemán:** cada sustantivo con su **artículo der/die/das** (género obligatorio) + **mayúscula**. Falsos
  amigos es↔de resueltos: der Chef=jefe · das Gehalt=sueldo (**neutro**, no "der Gehalt"=contenido) · die
  Aufgabe=tarea · das Rathaus=ayuntamiento · die Ampel=semáforo · der Gehweg=acera · die Kreuzung=cruce ·
  die Quittung=recibo · das Kleingeld=suelto · der Besen=escoba · der Mülleimer=cubo · der Zoll=aduana ·
  verpassen=perder · schüchtern=tímido · eifersüchtig=celoso · großzügig=generoso · stur=terco · höflich=cortés.
- **Autoría + revisión:** 240 → guardas (dedup vs 454, término≠traducción, oración contiene palabra, dedup entre
  temas, excluye cognados idénticos Tomate/Sofa) → **229** → 5 revisores adversariales: **31 fixes** (añadir el
  artículo de género que faltaba a sustantivos + `das Gehalt` neutro + gramática Dativ de "kündigen"), 0 drops.
- **Género preservado con criterio:** los sustantivos cuya oración usa la forma SIN artículo (p.ej. "frisches
  Gemüse") **conservan der/die/das** en la palabra y quedan como **match+word (sin cloze/audio)** — no se pierde
  el género. Los que la oración trae con artículo → **cloze+audio**. Resultado: **198 cloze+audio + 29 match+word**.
- **Contenido:** 246 content_items (198 cloze con audio TTS de **198/198** HEAD 200 + 48 match). Tag `vocab_f1`.
  20 lecciones "Vocabulario: <tema>" antes del checkpoint (A2/B1). lesson_vocab vincula.
- **Resultado:** enseñadas de **489 → 714 (+225, +46%)**. `vocabulary` 490→717. **Nuevo techo del de: 714.**
- **Verificado (`verify_lexico_f1_de.py`, cliente real) TODO VERDE:** completar "Vocabulario" inscribe las
  nuevas (22/22), SRS las sirve como **cloze con audio** (HEAD 200), aislamiento 0 otro curso, economía un pago/
  lección. **`verify_c1_chain.py de` (A1→C1, 30 unidades + audio) VERDE**, gating 180/180. analyze 0 · test
  198/198 · build web OK. en/pt/fr/it/nl intactos.
- **Muestra 5% (género + mayúscula) en el reporte.** **Pendiente:** nl (misma tanda), re-encolado.

## LÉXICO Fase 1 · FRANCÉS — +235 palabras NUEVAS con oración + audio (autoría) ✅ LIVE (mig 171 · 2026-07-18)
Réplica de las tandas en (mig 169) y pt (mig 170) para **francés SOLO**. Mismo pipeline: **10 agentes
profesores NATIVOS de fr** (240, 10 temas) + **5 revisores adversariales** (falsos amigos es↔fr + GÉNERO) +
guardas + verify real. **NO toca scheduler/economía/placement/certificación/otros 5 idiomas.**
- **PASO 0:** fr enseñaba **509** (max freq 812). Objetivo: +~230 de alta frecuencia por los 10 temas.
- **Falsos amigos es↔fr resueltos correctos:** le bureau=oficina · le trottoir=acera · la mairie=ayuntamiento ·
  le carrefour=cruce · le feu=semáforo · la monnaie=cambio **vs** la pièce=moneda (distinguidos) · le tonnerre/
  l'éclair/la foudre=trueno/relámpago/rayo (3 distintos) · gêné=avergonzado · poli=cortés · fâché=enfadado ·
  méchant=malo · déçu=decepcionado · le tiroir=cajón · la couverture=manta · le balai=escoba · le placard=
  armario · le stage=pasantía · constipé=estreñido · la boue=barro. **Género** (le/la) verificado por revisores.
- **Autoría + revisión:** 240 → guardas (dedup vs 458 ya en fr, término≠traducción, oración contiene la palabra,
  dedup entre temas, **excluye cognados de raíz idéntica** sensible/triste) → **235** → 5 revisores adversariales:
  **15 fixes** (añadir artículo de género a sustantivos de comida sin él), 0 drops. 0 traducciones duplicadas.
- **Contenido:** cada palabra → `vocabulary` + `cloze` con audio TTS fr (**235/235** subidos, HEAD 200) + `match`.
  Tag `vocab_f1`. 290 content_items, 20 lecciones "Vocabulario: <tema>" antes del checkpoint (A2/B1). lesson_vocab vincula.
- **Resultado:** enseñadas fr **509 → 744 (+235, +46%)**. `vocabulary` 514→749. **Nuevo techo del fr: 744.** F3 encendido en fr.
- **Verificado (`verify_lexico_f1_fr.py`, cliente real) TODO VERDE:** completar "Vocabulario" inscribe las
  nuevas (22/22), SRS las sirve como **cloze con audio** (6/6 con audio_url, HEAD 200), aislamiento 0 otro curso,
  economía un pago/lección. **`verify_c1_chain.py fr` (A1→C1, 30 unidades + audio) VERDE**, gating 180/180.
  (Nota: `verify_b2_chain fr` "falla" por asertar 24 unidades — fr tiene 30 por C1; es el verificador equivocado
  para un curso C1, quirk documentado, no regresión.) analyze 0 · test 198/198 · build web OK. en/pt/de/it/nl intactos.
- **Muestra 5% (falsos amigos + género) en el reporte.** **Pendiente:** de/it/nl (misma tanda), re-encolado.

## LÉXICO Fase 1 · PORTUGUÉS — +191 palabras NUEVAS con oración + audio (autoría) ✅ LIVE (mig 170 · 2026-07-18)
Réplica de la tanda de inglés (mig 169) para **portugués SOLO**. Mismo pipeline: **10 agentes profesores
NATIVOS de pt** (240 palabras, 10 temas) + **5 revisores adversariales** + guardas + verify real. **NO toca
scheduler/economía/placement/certificación/otros 5 idiomas.**
- **PASO 0:** pt enseñaba **535** palabras (max freq 875). Objetivo: +~200 de alta frecuencia por los mismos 10
  temas, con oración-ejemplo + audio.
- **es↔pt es EL par de los FALSOS AMIGOS** (donde el contenido enseña mal). Instruí a autores y revisores con
  foco extremo. **Resueltos correctos:** escritório=oficina (NO "escritorio") · esquisito=raro (NO exquisito) ·
  embaraçado=avergonzado (NO embarazada) · chateado=molesto · bravo=enojado · educado=cortés · grosseiro=grosero ·
  sensível=sensible · presunto=jamón · copo=vaso · taça=copa · gorjeta=propina · vassoura=escoba · gaveta=cajón ·
  cobertor=manta · poltrona=butaca · alfândega=aduana · troco=cambio · prédio=edificio.
- **Autoría + revisión:** 240 → guardas deterministas (dedup vs 501 ya en pt, término≠traducción, oración
  contiene la palabra, dedup entre temas) → **227** → 5 revisores adversariales (falsos amigos): 0 fixes, 0
  drops → **mi auditoría personal** cazó un residuo: **34 cognados de raíz IDÉNTICA** (esquina, biblioteca,
  mochila, arroz…) que un hispanohablante ya sabe (bajo valor + rompen el match) → excluidos + 2 dups → **191**.
  0 traducciones `es` inútiles.
- **Contenido:** cada palabra → `vocabulary` + `cloze` con audio TTS pt (**191/191** subidos, HEAD 200) + `match`.
  Tag `vocab_f1`. 232 content_items, 20 lecciones "Vocabulario: <tema>" antes del checkpoint (A2/B1). lesson_vocab vincula.
- **Resultado:** enseñadas pt **535 → 726 (+191, +36%)**. `vocabulary` 542→733. **Nuevo techo del pt: 726.**
  F3 encendido también en pt (cloze con audio).
- **Verificado (`verify_lexico_f1_pt.py`, cliente real) TODO VERDE:** completar "Vocabulario" inscribe las
  nuevas (24/24), el SRS las sirve como **cloze con audio** (HEAD 200), aislamiento 0 otro curso, economía un
  pago/lección. **`verify_pt_chain` (multicurso A1→B2 + certs) VERDE**, gating 180/180. analyze 0 · test
  198/198 · build web OK. Solo pt: en/fr/de/it/nl intactos.
- **Muestra 5% (falsos amigos) en el reporte.** **Pendiente:** fr/de/it/nl (misma tanda), re-encolado.

## LÉXICO Fase 1 · INGLÉS — +232 palabras NUEVAS enseñadas con oración + audio (autoría) ✅ LIVE (mig 169 · 2026-07-18)
De LEXICO_PLAN §3 Fase 1 (§4 integración). **Inglés SOLO** en esta tanda (profundidad>amplitud; los otros 5
después si demuestra calidad). Pipeline de la casa: **10 agentes profesores nativos** (240 palabras, 10 temas) +
**5 revisores adversariales** + guardas deterministas + verify real. **NO toca scheduler/economía/placement/
certificación/otros 5 idiomas.**
- **PASO 0:** el inglés enseñaba **484** palabras (max freq 1715). Objetivo acotado y verificable: **+~220-240**
  de alta frecuencia por temas útiles (comida, trabajo, salud, viaje, ciudad, tiempo, compras, hogar, naturaleza,
  emociones), cada una con **oración-ejemplo + audio** (paga F3 de paso, no nace con la deuda).
- **Autoría + revisión:** 10 temas × 24 = 240 → guardas deterministas (dedup vs 446 ya en `vocabulary`,
  término≠traducción, oración contiene la palabra, dedup entre temas) dejan **232**; **5 revisores adversariales**
  (falsos amigos, acepción, registro, CEFR) → 1 fix, 0 drops; **mi propia auditoría** de las 232 (confident=seguro,
  upset=molesto, sensitive=sensible, thunder/lightning separados — falsos amigos bien resueltos). 0 traducciones
  `es` duplicadas.
- **Contenido:** cada palabra → fila `vocabulary` + **ítem `cloze` en contexto** (`payload.text`=oración +
  `audio_url`; `correct_answer.value`=palabra) **con audio TTS** (232/232 subidos a Storage, HEAD 200) + **ítem
  `match`** de reconocimiento. Tag **`vocab_f1`** (NO unidadN → checkpoints/exámenes/placement intactos). 286
  content_items, 20 lecciones "Vocabulario: <tema>" ancladas ANTES del checkpoint (DO-block idempotente) en
  unidades A2/B1 (7-16). `lesson_vocab` (F2) las vincula.
- **Resultado:** enseñadas en **484 → 716 (+232, +48%)**. `vocabulary` 486→718. **Nuevo techo del inglés: 716.**
- **F3 ENCENDIDO (primer curso):** las tarjetas SRS de estas palabras son **cloze-en-contexto con AUDIO** (antes
  el camino existía pero 0 cloze tenía audio). Verificado cliente real.
- **Verificado (`verify_lexico_f1_en.py`, cliente real) TODO VERDE:** completar una lección "Vocabulario"
  inscribe las nuevas en el SRS (27/27), el **SRS las sirve como cloze con audio** (HEAD 200), aislamiento 0
  otro curso, economía un pago/lección. **`verify_chain` (en A1→B2 + certs A1-B2) VERDE** (gating 180/180 con
  checkpoint como nodo final). analyze 0 · test 198/198 · build web OK. Solo-inglés: pt/fr/de/it/nl intactos.
- **Muestra 5% para Gian** (ver reporte); **excluidas:** 8 duplicados entre temas + guardas. **Pendiente:** los
  otros 5 idiomas (misma tanda temática), y seguir el inglés hacia ~1.000-1.500 (más temas) — re-encolado.

## LÉXICO Fase 0 — "cosechar lo sembrado": +811 palabras ENSEÑADAS (antes inertes) ✅ LIVE (mig 168 · 2026-07-18)
De LEXICO_PLAN §3 Fase 0. **Cero IA** (reusa traducciones YA revisadas del seed + ítems `match` por PLANTILLA
determinista, uuid5). Los 6 idiomas. **NO toca scheduler FSRS / economía / gating / certificación.**
- **PASO 0 (BD real):** 838 palabras en `vocabulary` con traducción revisada del **seed autorado**
  (`part_of_speech` no nulo; la cosecha de mig 166 ya estaba vinculada) pero SIN `lesson_vocab` → **inertes**
  (ningún ítem las enseñaba → nunca entran al SRS). El techo real no era "480" sino **322-424 ENSEÑADAS/curso**.
- **Guardas (precedente Brazil=Brazilian):** excluidas **27** — término==traducción (cognados triviales:
  gordo, la pasta, afirmar…) y **>4 palabras** (oraciones/idiomas figurados: "Se avessi studiato…",
  "prendere due piccioni con una fava"=F3). Dentro de cada `match`, `es` normalize-distintos (grading no
  ambiguo) — **0 colisiones**. Solo traducciones ya revisadas; nada inventado.
- **Ítems + lecciones:** 248 ítems `match`/`translation` tag **`repaso_vocab`** (NO `unidadN` → checkpoints/
  exámenes/placement **intactos**, 0 fuga verificada). 174 lecciones "Repaso de vocabulario" ancladas a
  unidades existentes por **nearest-neighbor** sobre el mapa real freq→unidad (bye→u2, "to imply"→u27),
  insertadas **ANTES del checkpoint** (DO-block idempotente que desplaza el checkpoint +k; el desbloqueo es
  por type+unit, no por order → **gating intacto**: 180/180 unidades con 1 checkpoint como nodo final).
- **Resultado (vinculadas antes→después):** **de 322→489 (+167,+52%) · fr 342→509 (+167,+49%) · it 335→490
  (+155,+46%) · nl 344→488 (+144,+42%) · pt 417→535 (+118,+28%) · en 424→484 (+60,+14%)** = **+811 palabras
  enseñadas**. Sueltas restantes = exactamente las 27 excluidas. La re-derivación `lesson_vocab` (lógica mig
  166) las vincula → dejan de ser inertes.
- **Verificado cliente REAL (`verify_lexico_f0.py` en+de) TODO VERDE:** completar un "Repaso de vocabulario"
  inscribe las palabras antes sueltas como **`new`** en el SRS (2/2, 8/8), **aislamiento** 0 de otro curso,
  economía = un pago por lección (xp 15 oro 10). **Cadenas VERDES:** `verify_chain` (en A1→B2 + certs A1-B2),
  `verify_pt_chain` (multicurso A1→B2 + certs), `verify_srs_f2` (pt+de). analyze 0 (CI-exact) · test 198/198 ·
  build web OK. 8 usuarios reales intactos.
- **Techo tras F0 (honesto):** el contenido del seed queda **EXPRIMIDO** (0 palabras revisadas sin explotar).
  Subir de aquí (hacia 1.000-1.500/idioma) exige la **Fase 1** de LEXICO_PLAN (autoría de lecciones de
  vocabulario nuevas + oración + audio). Re-encolado. Nota: las 174 lecciones nuevas engrosan el mapa ~15%
  (una por unidad tocada); es contenido real, no relleno.

## LEXICO_PLAN.md — análisis y plan para ampliar el léxico a un B2 real ✅ (2026-07-17 · solo lectura, cero contenido)
Responde "¿cómo pasar de ~480 a 4.000-5.000 palabras sin enseñar mal ni tarjetas inertes?" con BD real +
investigación de fuentes. **TITULAR: el cuello de botella es el CONTENIDO, no el vocabulario** — se enseñan
solo las vinculadas (`lesson_vocab`): en 424 · pt 417 · nl 344 · fr 342 · it 335 · de 322 (de ~486-542 en
`vocabulary`); el contenido actual introduce **~2,1-2,8 palabras nuevas/lección** → a ese ritmo 4.000 = 1.600
lecciones (10× el curso). La palanca = lecciones DE VOCABULARIO densas (~10 nuevas/lección). **Facturas:**
1.500/idioma ≈ 110-140 lecciones ≈ ~1.000-1.250 ítems (×6 ≈ 6.500-7.500); 4.000 ≈ **~4× todo lo construido en
3 meses**. **Opción (a) NO EXISTE** (investigado): KELLY no incluye español ni 4 de nuestros 6; Routledge/
Oxford/Goethe = © sin licencia; Wikdict/Wiktionary = licencia OK pero calidad comunitaria (el fallo
Brazil/Brazilian a escala); **Tatoeba (CC-BY, humano) = la mejor materia prima… para F3 (oraciones)**, no lista
curada. **Recomendación:** FASE 0 "cosechar lo sembrado" (cero IA, ~2-3 días: ítems match para las **~840
sueltas** ya revisadas → +15-40%, techo ~486-542/curso — y el contenido queda EXPRIMIDO); FASE 1 objetivo
honesto **1.000-1.500/idioma** con el workflow probado de la casa (agentes nativos-IA + doble revisión
adversarial + verify real + **muestreo humano ≥5%** — nombrado con honestidad: ese pipeline ES IA y es el que
construyó los 5.182 ítems live), ~3,5-5 días/idioma, orden en→pt→fr→de→it→nl, **cada palabra con oración+audio**
(paga F3 de paso); FASE 2 (B2, 50-65 días los 6) **solo si la Fase 1 demuestra retención con usuarios reales**.
Verdad incómoda: no hay lista lista-para-usar legal; es pipeline de agentes (semanas) o humanos (meses+dinero).

## SRS F4 — Practicar pulido y DINÁMICO (capa de experiencia sobre el motor FSRS) ✅ LIVE (2026-07-17 · solo cliente)
De PRACTICAR_SRS_ANALISIS §7 F4. Cero IA, cero servidor: **NO se tocó scheduler/inscripción/economía/grading**
(guardarraíl verificado con `verify_srs.py` pt+de TODO VERDE post-cambio). Para los 6 idiomas (la pantalla es
course-agnóstica).
- **PASO 0 (recorrido real de la sesión) — 9 puntos flojos:** (1) cambio de tarjeta brusco (setState pelado);
  (2) revelado sin animación, sin háptica/SFX ni reacción de Jezi; (3) contador suelto `N` sin etiqueta;
  (4) barra de progreso que SALTA y no dice cuántas quedan; (5) botones de rating solo-texto; (6) envío final =
  spinner mudo; (7) **cierre soso** (sin confeti, sin precisión, sin retención, sin racha/meta — datos que el
  summary YA traía y se tiraban); (8) **retención (F1) invisible** — `retentionPct` existía y NO se mostraba en
  ningún lado (las claves i18n `srsRetention*` estaban huérfanas); (9) estados vacíos ya OK (bienvenida con Jezi
  + CTA; verificados).
- **Pulido (todo reduce-motion-aware — `Duration.zero` + confeti apagado):** transición entre tarjetas
  (AnimatedSwitcher slide+fade 240ms, clave `_seq`); revelado con **AnimatedSize + fade/rise** + **háptica/SFX
  del loop** (`FeedbackFx.correct/wrong` — mismo lenguaje que la lección) + **Jezi reacciona** (celebrate/
  encourage 40px en la caja de resultado); chip **"N restantes"** (plural ICU); **barra animada** (Tween 380ms);
  botones de rating con **icono** (↻ Otra vez · ⏳ Difícil · ✓ Bien · ⚡ Fácil) + labio 3D existente; envío con
  "Guardando tu repaso…".
- **Cierre celebrado (\_Done reescrito):** confeti sutil (14 partículas, nunca con reduce-motion) + Jezi +
  **anillo de PRECISIÓN animado** (color por tramo) + chips XP/oro/racha + **"⚡ Meta del día cumplida"**
  (`goalMet`) + **"¡Tu racha avanzó!"** (`streakAdvanced`) + **tarjeta de RETENCIÓN** (🧠 % + barra + explicación
  honesta) con dato FRESCO (submitSrs invalida `srsStatusProvider`) — **null → no se pinta** (no se inventa) +
  CTA con `JzGlowPulse` + entrada fade+rise.
- **Retención en el HUB:** `_SrsHero` gana fila 🧠 Retención (barra + %, color por tramo ≥90 verde / ≥75 ámbar /
  rojo) solo con `matureCards > 0` (honesto).
- **Verificado:** analyze 0 (CI-exact) · test **198/198** (+2 F4: "N restantes" + iconos de rating; los 4 srs
  previos intactos) · **`verify_srs.py` (cliente real pt+de) TODO VERDE** (economía un-pago-por-sesión, FSRS,
  racha, aislamiento — 0 regresión; usuarios reales 8/8 intactos) · build web OK. i18n es/en/pt (+6 claves).

## ERRORES TIPADOS · 2ª PASADA — frontera de RPC + catches auditados + SQLSTATE custom ✅ LIVE (mig 167 · 2026-07-17)
Cierra lo que la 1ª pasada (JzError) dejó pendiente. Cero IA. Transversal, **sin tocar lógica/economía/
seguridad**; los mensajes que YA funcionaban (amistad, handle) siguen igual — ahora por CÓDIGO, no substring.
- **1 · FRONTERA DE RPC (`_rpc`):** las **84 llamadas `_client.rpc(...)` del repo** pasan por un único helper
  que las TIPA (`JzError.from`, por diseño no caso-por-caso) y REPORTA a Sentry EN EL BORDE (server/unknown/
  auth) — antes un RPC caído se volvía un `AsyncError` de Riverpod **invisible**. Los errores ESPERADOS
  (rls/validación/conflicto/rate) se tipan pero NO se reportan (no son ruido). `heartbeat`/`log_event`
  (muy frecuentes) pasan `report:false`. Los sitios que muestran mensaje usan `JzError.from(e)` (idempotente)
  → mismo mensaje, sin doble reporte.
- **2 · AUDITORÍA DE LOS 79 `catch(_){}` (PASO 0):** clasificados. **Infra best-effort legítima** (audio
  unlock 22, TTS/voz/speech 12, prefs/locale/sound/music 10, main/config/crash 5) → se dejan (su dominio es
  autoevidente). **Flujos de negocio** documentados o CERRADOS: repo (4, ahora reportan en `_rpc` antes de
  degradar), friends (privacidad/presencia/merge = best-effort comentados; **block/report ya NO se traga en
  silencio** → muestra el error tipado, es moderación), course_switcher (3 defensivos comentados + el
  top-level ahora **reporta** `switch_course`), onboarding (6 best-effort idempotentes comentados: el
  CompleteProfileScreen recupera), auth_screen (2 catches genéricos ahora **reportan** `auth_submit`/
  `sign_in_google`).
- **3 · SQLSTATE CUSTOM (mig 167):** helper server `jz_err(reason, kind)` levanta la clase **`JZ`**
  (JZ401 auth · JZ403 denied · JZ404 not_found · **JZ409 conflict** · **JZ429 rate** · **JZ422 validation**);
  **`claim_handle` migrado** (cuerpo VERBATIM de la mig 158, solo los `raise` → `jz_err`) → el cliente mapea
  el KIND por **CÓDIGO** (robusto ante reescrituras) y el reason por el **MENSAJE = token EXACTO** (no
  substring). **Compatibilidad total:** el mensaje sigue siendo el token de siempre (`handle_taken`, …) →
  el fallback por texto del cliente sigue válido; las RPC **no migradas** siguen con P0001+texto (doble red).
  `JzError.from` extendido para leer `JZxxx`.
- **4 · auth_screen:** el `_friendly` migra "ya registrado" a reason TIPADO (`JzError.from`); credenciales/
  contraseña siguen por texto (son de Supabase Auth, no de negocio) documentado.
- **Verificado cliente REAL (`verify_typed_errors.py`, 2 JWT) TODO VERDE:** claim válido→200 (lógica intacta);
  tomado→**`{"code":"JZ409","message":"handle_taken"}`**; inválido→JZ422+invalid_handle; reservado→JZ409+
  handle_reserved; cambio<30d→JZ429+handle_change_rate. **`verify_handle_mandatory.py` funcional VERDE** (el
  texto sigue en el mensaje → 0 regresión). analyze 0 (CI-exact) · test **196/196** (+1 JZ-code; friend_error_
  mapping intacto) · build web OK.
- **Pendiente (3ª pasada, reportado):** migrar a `jz_err` las RPC sociales grandes (`jz_do_friend_request`/
  `block_user`/`report_user`/`set_profile_required`) y de plan/lección (más superficie, más riesgo — se hace
  con verify real por función). Los ~49 catches de infra best-effort quedan tal cual (correctos por dominio).

## AMPLIAR EL LÉXICO — +154 palabras VERIFICADAS y NO INERTES (del contenido, no IA) ✅ LIVE (mig 166 · 2026-07-17)
De la ## Cola / PRACTICAR_SRS_ANALISIS §5 ("480 palabras/curso es una SEMILLA; a 10/día se agota en ~48 d").
Cero IA, server-only.
- **PASO 0 (BD real):** `vocabulary` ~480/curso (de 481 · fr/it/nl 480 · pt 479 · en 468 = **2.868**),
  `frequency_rank` 100% en los 6. **TENSIÓN CRÍTICA reportada ANTES de tocar:** el SRS es **lesson-driven**
  (`complete_lesson`→`jz_srs_enroll_lesson` inscribe solo lo que `lesson_vocab` dice que la lección enseña) →
  **añadir palabras a `vocabulary` SIN lección que las enseñe = tarjetas INERTES: nunca entran al SRS.**
- **Fuente VERIFICADA y NO INERTE (cero IA):** los pares de los ítems `match` **DE TRADUCCIÓN** (prompt
  "…con su traducción" / "portugués y español"; autorados por nativos + revisión adversarial, YA en
  producción) que enseñan palabra META + traducción española pero que **aún no estaban en `vocabulary`**.
  Como el contenido YA las enseña → entran al SRS por F2; no inertes. **GUARDARRAÍL aplicado tras cazar un
  fallo:** un 1er intento metió `'Brazil'='Brazilian'` de un `match` de **país↔nacionalidad** (la clave `es`
  ahí NO es español) → se REVIRTIÓ y se restringió a: **solo prompts de traducción** (fuera matiz/colocación/
  nacionalidad/significado-figurado) + término≠traducción + **≤4 palabras** (fuera oraciones/gramática).
- **Resultado (mig 166): +154 palabras** — **pt +63 · fr +34 · it +21 · en +18 · de +9 · nl +9** → `vocabulary`
  **2.868 → 3.022**. `frequency_rank` = order_index de la unidad × 30 (orden de introducción COHERENTE con el
  currículo); `part_of_speech` null (marca de cosecha; el seed nunca es null). La migración **re-deriva
  `lesson_vocab`** (lógica de mig 165, idempotente) para que las nuevas queden vinculadas a sus lecciones.
- **Verificado cliente REAL:** **0 inertes** (todas con `lesson_vocab`); traducciones correctas (afternoon=
  tarde · Friday=viernes · night=noche · espanhol=español · eu sou=yo soy · das Ende des Films=el final de la
  película). **`verify_srs_f2.py` TODO VERDE** (pt+de: inscripción==lesson_vocab, falladas con prioridad,
  economía y mapa intactos). analyze 0 · test 195/195 · build web OK.
- **TRADE-OFF / techo honesto (lo importante):** el contenido solo contenía **~154** palabras verificadas
  no-inertes sin explotar — un +5% real y seguro, **NO** los miles que pide un B2 (~4.000-5.000). Ampliar de
  verdad requiere **una de dos facturas grandes**: (a) un **léxico bilingüe de alta frecuencia con traducciones
  revisadas por idioma** (NO existe fuente fiable sin IA que yo pueda garantizar para los 6 → no se inventó
  nada), o (b) **autorar lecciones nuevas** que enseñen esas palabras (la factura de contenido del análisis).
  Volcar una lista de frecuencia con auto-traducciones violaría el guardarraíl ("no enseñar mal") → NO se hizo.
  Re-encolado en ## Cola.

## i18n — pantallas que quedaban en español duro, traducidas (es/en/pt) ✅ LIVE (2026-07-17 · solo cliente)
Del análisis del principiante/auditorías: varias pantallas tenían texto HARDCODEADO en español → salían en
español con la app en en/pt. Cero IA. Mismo sistema i18n existente (gen-l10n · `app_es/en/pt.arb` ·
`AppLocalizations.of(context)`).
- **PASO 0 (censo real, grep de literales españoles):** ~**90 strings** en **11 archivos**: mi_plan 23,
  metrics 24 (admin), reference 8, simulacros 7, story_reader 6, level_exam intro 5 + player 4, immersion 5,
  notification_center 3, notebook 2 (+contador plural), matix_test 3. Mecanismo confirmado.
- **Migrado (TODAS las pantallas de usuario) — +84 claves i18n (es/en/pt):** **Mi Plan** (fechas por
  `MaterialLocalizations`, "adelante/atrás" con **plural ICU**, motivo→enfoque reusando `planFocus*`),
  **Notificaciones** (centro + "hace X min/h/d"), **Examen de nivel** (intro + player: bullets, diálogo de
  salir, errores), **Inmersión + Historias** (chrome: títulos, "Oír"/"Glosario"/"Pregunta X de Y", resultado),
  **Simulacros** (headline, 4 descripciones, mocks), **Repaso/Referencia** (encabezados, "% dominio",
  reforzar), **Cuaderno** (título + contador plural + estado vacío), **matix_test** (labels admin). Traducciones
  naturales en/pt (no calcos), terminología consistente (streak/gold/level), placeholders/plurales respetados.
- **GUARDARRAÍL:** solo cambió el ORIGEN del texto (literal → clave), cero cambios de lógica/layout/
  comportamiento. El **contenido del servidor NO se traduce en cliente** (títulos de historias, tips, cuerpo de
  notificaciones, respuesta modelo — vienen por idioma del CURSO). Las pantallas ya traducidas, intactas.
- **Verificado:** censo post-migración = **0 español suelto** en las 11 pantallas de usuario (el único match
  restante en mi_plan es un `case 'Examen'` = valor del servidor, no texto mostrado); las 84 claves existen en
  **es/en/pt** (generadas). analyze 0 (CI-exact) · test **195/195** · build web OK.
- **PENDIENTE (2ª pasada, honesto):** **`metrics_screen.dart` (24 strings) — ADMIN-ONLY** (solo Gian lo ve;
  requiere `am_i_admin`), por eso se difirió: es la pantalla menos user-facing. Es la única que queda con
  español duro. Se migra igual (mismo patrón, prefijo `metrics*`) cuando toque.

## ERRORES TIPADOS — Sentry y las pantallas VEN los fallos reales ✅ LIVE (2026-07-17 · solo cliente)
Deuda #2 de ARQUITECTURA_ANALISIS ("los errores nunca se diseñaron"), el fix de mayor ROI. Con 5 usuarios
reales, un fallo hoy era invisible. Cero IA, sin migración.
- **PASO 0 (censo real):** **78 `catch (_) {}` vacíos** · 156 `catch (_)` totales · i18n de errores **por
  substring del texto de Postgres** en 4 sitios (friends ×2, auth_screen, edit_profile) · **1 solo
  `on AuthException`, CERO `on PostgrestException`** → las ~75 RPC lanzan crudo. Consecuencia: clases enteras
  de fallo (RPC caído, RLS 42501, rate limit) **sin NINGÚN síntoma** — ni UI ni Sentry. Los errores de negocio
  del servidor son `raise exception '<texto>'` = **SQLSTATE P0001 genérico** → su TEXTO es el contrato.
- **Tipo de dominio `core/errors/jz_error.dart`:** `JzErrorKind` (network·auth·denied·rateLimited·conflict·
  notFound·validation·server·unknown) + `JzError{kind, reason, cause, rpc}` + **`JzError.from(e)` — el mapeo
  CENTRAL, un solo lugar.** Robusto: usa el **SQLSTATE** donde existe (42501→denied, 23505→conflict, PGRST30x→
  auth) y una **tabla ORDENADA de tokens** para los P0001 (already_friends, rate_limited, handle_taken,
  social_unavailable, gender_required…) → `reason` tipado. `shouldReport` = solo los **inesperados** (server/
  unknown/auth) llegan a Sentry; los esperados del usuario (validación/conflicto/rate/denegado) se muestran
  pero NO ahogan el dashboard.
- **`error_reporter.dart` `reportError(e, {rpc})`:** `JzError.from` + **`Sentry.captureException`** con tags
  (jz_kind/jz_reason/jz_rpc, SIN PII); no-op si Sentry apagado; nunca rompe el flujo. Es el reemplazo honesto
  del `catch (_) {}` mudo. **`jz_error_message.dart`:** la i18n de errores pasa a basarse en el TIPO (es/en/pt:
  errNetwork/errAuth/errDenied/errRateLimited/errConflict/errNotFound/errValidation/errServer/errUnknown), no
  en el texto crudo.
- **Migrado (los puntos donde un fallo real era invisible):** `friendErrorMessage` y el mapeo de @handle
  (friends.dart) + edit_profile → ahora enrutan por `JzError.reason` (adiós al `contains()` suelto; el
  `friend_error_mapping_test` sigue verde por el tipo). **Reporte a Sentry cableado** en los 5 fallos de mayor
  valor: **grade_item** (calificar), **complete_lesson** (fin de lección — el corazón del loop), **get_skill_
  mastery** (antes un fallo era indistinguible de "novato sin datos"), **claim_handle**, **set_profile**. El
  comportamiento visible NO cambia salvo que ahora los errores se VEN.
- **Guardarraíl:** cero cambios de lógica/scoring/economía/seguridad; los `catch (_) {}` **best-effort legítimos**
  (heartbeat, logEvent, prefetch, unlock de audio, SRS best-effort) **se conservan** (el propio análisis dice
  que están bien). analyze 0 (CI-exact) · test **195/195** (+9 `jz_error_test`: SQLSTATE, tokens, shouldReport,
  idempotencia, i18n es/en/pt; friend_error_mapping intacto) · build web OK.
- **Cómo Gian ve un error de prueba en Sentry:** Ajustes → **Ver métricas** → tarjeta "Monitoreo de errores
  (Sentry)" → **"Enviar evento de prueba"** (ya existía; captura una excepción y devuelve su id). Y ahora,
  **automático:** cualquier fallo real de servidor en grade_item/complete_lesson/get_skill_mastery/claim_handle/
  set_profile llega a Sentry etiquetado `jz_rpc=<rpc>` `jz_kind=<tipo>` (los de red se filtran solos).
- **2ª pasada (re-encolado en ## Cola):** auditar los ~74 `catch (_) {}` restantes uno por uno (benigno-
  documentado vs reportar); migrar el substring de `auth_screen` (hoy `AuthException`-tipado, baja fragilidad);
  envolver los ~75 `rpc()` del repositorio en un helper que tipe en la frontera; y (SERVIDOR) hacer que los
  `raise exception` emitan un **SQLSTATE custom** para mapear 100% por código, no por token de texto.

## SRS F2 — `lesson_vocab`: el vínculo que faltaba (inscripción PRECISA, no substring) ✅ LIVE (mig 165 · 2026-07-17)
De la ## Cola / PRACTICAR_SRS_ANALISIS §4 paso 2 + §1.2 ("`vocabulary` es una ISLA"). Cero IA, server-only, 6 idiomas.
- **PASO 0 (BD real):** `complete_lesson` → `jz_srs_enroll(uid,curso,item_ids,failed)` que escanea por **substring
  whole-word** `correct_answer->>'value'` + `payload.text/say` + `vocabulary.word` — **NO escaneaba los `pairs`
  del `match`** → **las palabras que la lección enseña por match NO se inscribían**; y no lematiza ("gatos"≠"gato",
  compuestos DE fallan). `vocabulary` (2.868 palabras, `frequency_rank` 100% en los 6) sin `lesson_vocab` ni
  `unit_id` = isla. Confirmado: el mapa "qué palabras enseña cada lección" NO existía.
- **`lesson_vocab(lesson_id, vocab_id, position)` (mig 165):** el mapa que faltaba. **Poblado DERIVANDO** del
  contenido (cero autoría): tokens normalizados de los textos del ítem (`jz_normalize` + puntuación→espacio) unidos
  **exacto** a la palabra, **+ los `pairs` del match** (término meta bajo la clave `'en'` — convención del banco en
  los 6 — casado exacto, arregla el gran hueco), **+ substring whole-word** para vocab multi-palabra en oraciones.
  `position` = orden de introducción (mín. order_index del ítem que la introdujo). RLS ON sin política (solo lo
  leen funciones DEFINER). **Cobertura de la derivación:** en **406/468 (87%)** · pt **354/479 (74%)** · nl
  **335/480 (70%)** · it **314/480 (65%)** · de **313/481 (65%)** · fr **308/480 (64%)**; **899/900 lecciones con
  ítems tienen mapeo** (la 1 sin mapeo = misión de bienvenida → fallback).
- **Inscripción PRECISA:** nuevo `jz_srs_enroll_lesson(uid,curso,lección,vistas[],falladas[])` — **VISTAS** =
  las palabras de `lesson_vocab` de la lección → `state='new'` (no adelanta las ya agendadas); si la lección no
  tiene mapeo → **FALLBACK** al substring sobre los ítems (0 regresión). **FALLADAS** = item-level `due=now`
  (prioridad), y `jz_srs_enroll` ahora **también escanea los pares de match** → los match fallados sí inscriben.
  `complete_lesson` cambia SOLO su bloque SRS (resto byte-idéntico) para llamar a la vía precisa; **best-effort y
  al final** (un fallo del SRS jamás tumba el fin de lección). **NO se borró el camino substring** (queda de fallback).
- **Verificado cliente REAL (`verify_srs_f2.py`, pt romance + de germánico) TODO VERDE:** completar una lección
  inscribe **EXACTAMENTE** las palabras de `lesson_vocab` (pt 10, de 6 — no aproximado por substring); **incluye
  las palabras del `match`** (3 c/u) que el substring NO veía; las falladas quedan con **prioridad due≤now**;
  **economía intacta** (xp/oro otorgados) y **mapa intacto** (`next_lesson_id`). **GUARDARRAÍLES VERDES:**
  `verify_chain` (en A1→B2 + 4 certs) y `verify_pt_chain` (multicurso A1→B2 + 4 certs). analyze 0 (CI-exact) ·
  test **186/186** · build web OK.
- **Beneficio extra (barato, sin riesgo):** `lesson_vocab.position` da el **orden de introducción por unidad** y
  "esta lección/unidad te enseñó estas N palabras" (dato ya consultable). Re-encolado (## Cola): lematización real
  (hoy exacto/substring — inscribe de menos, nunca basura); exponer "N palabras de la unidad" en la UI de fin/mapa.

## ENSEÑAR ANTES DE EXAMINAR — tarjeta de presentación al INICIO de la lección ✅ LIVE (mig 164 · 2026-07-17)
Pedido de uso REAL (@eugenio: "que diga conceptos, teoría + imágenes, estructura de temas") + P1 #4 de
PRINCIPIANTE_ANALISIS ("se examina antes de enseñar"). Modelo Busuu **present → practice**. Para los 6 idiomas.
- **PASO 0 (traza real):** `LessonPlayerScreen` entraba **directo al ejercicio 0** (fase answering); el tip
  solo salía al FINAL (`lesson_complete`). Piezas reutilizables confirmadas: `get_lesson_tip` (concepto real
  de la lección, ya existía), `ConceptImage` (imágenes lazy + degradación), el TTS por idioma (recién
  centralizado), `ParrotMascot`. Hallazgo clave: los ítems `match` traen `payload.pairs` = **término meta bajo
  la clave `"en"`** (convención del banco en LOS 6 cursos) + traducción `es`; y `vocab_images` (39 conceptos EN)
  mapea palabra→Twemoji.
- **`get_lesson_intro(p_lesson_id)` (mig 164, READ-ONLY):** deriva la presentación de lo que la lección YA
  tiene — **concepto** = el tip (`get_lesson_tip`: title/body/example) · **vocab** = pares de los `match`
  (término + traducción), con **imagen** de `vocab_images` cuando el concepto coincide (hoy solo inglés →
  degrada con gracia a texto+audio en el resto). null si no hay nada que presentar. No inventa contenido.
- **Cliente (fase `presenting` ANTES de answering, no en reviewMode):** `LessonIntroView` — Jezi presenta +
  **tarjeta de CONCEPTO** (teoría + ejemplo tocable para oírlo) + **tarjetas de VOCAB** (término meta grande
  tocable→TTS del curso, traducción, imagen si hay via `ConceptImage`) + CTA **"EMPEZAR EJERCICIOS"** (glow) +
  **"Saltar"** (siempre saltable; no fuerza la teoría). AUDIO por TTS centralizado (`SpeechLang.tts`). El
  player la carga en `initState` (best-effort): si es null/error/**tarda >3 s** (timer cancelable) → entra
  directo a los ejercicios. **GUARDARRAÍL:** la fase de presentación NO toca economía/scoring/progresión — el
  loop de ejercicios, `complete_lesson`, XP/oro y el mapa quedan intactos.
- **Verificado cliente REAL (`verify_lesson_intro.py`) TODO VERDE:** concepto+vocab en **pt (romance)** y **de
  (germánico)**; **imagen** adjunta en EN (father→father.png), degrada sin imagen en el resto; **oro/XP NO
  cambian** tras llamar `get_lesson_intro` (read-only). + widget test `lesson_intro_test` (render ES concepto+
  vocab+CTA; PT saltable sin español). `lesson_flow_test` intacto (fake repo devuelve intro null → loop igual).
  analyze 0 (CI-exact) · test **186/186** (+2) · build web OK.
- **Cobertura honesta:** imágenes hoy solo para conceptos EN de `vocab_images` (39); el resto = texto+audio
  (degradación con gracia, sin hueco). El vocab sale de los `match` → lecciones sin `match` muestran solo el
  concepto (o nada → entra directo). Re-encolado: banco de imágenes multi-idioma; tarjetas paginadas "Siguiente".

## VOZ TTS EN VIVO — fin de las "dos voces" (la robótica del primer toque) ✅ LIVE (2026-07-17 · solo cliente)
Feedback: en una sesión se oían DOS voces, una que NO suena a inglés real (robótica/acento español) y otra
que sí. **PASO 0 — traza real de TODO el audio de una sesión (no asumir):** conviven **dos motores**:
- **Pregrabado (MP3 en Storage) → `AudioEngine`** — generado con **Google Translate TTS** (`translate_tts`),
  NATIVO por idioma. Lo usan: **listening**, **historias**, y el modelo de **speaking del placement**. Es la
  voz "buena".
- **TTS EN VIVO (Web Speech `speechSynthesis`) → `word_tts_web.dart`** — lo usan: tiles de **word_bank/reorder**,
  **match**, **SpeakablePhrase** (speaking), **SpeakableText** (repaso SRS, glosario, tips). Es la voz que a
  veces sonaba mal.
- **CAUSA RAÍZ (reproducida en navegador real, `speechSynthesis.getVoices()` en jezici.space):** (1) **TIMING** —
  `getVoices()` devuelve **VACÍO (0)** en el primer tick tras cargar la página y se puebla async por
  `voiceschanged`. El código previo, con la lista vacía, **hablaba igual** → el navegador usaba su voz **POR
  DEFECTO** (en un equipo en español, una voz ESPAÑOLA) → leía inglés con acento español; solo los toques
  POSTERIORES (ya con voces) sonaban nativos → **"a veces una, a veces otra"**. (2) **DEVICE sin voz nativa** —
  fijar solo `lang='en-US'` NO garantiza inglés: si el equipo no tiene voz inglesa instalada, el navegador cae a
  su voz por defecto (verificado: este entorno headless tiene **solo 3 voces, todas es-ES** → en-US caía a
  Microsoft Helena español).
- **FIX (centralizado en el ÚNICO helper `word_tts_web.dart`, por donde pasan TODOS los `WordTts.speak/
  speakSource`):** (1) si las voces aún no cargaron, **DIFIERE** la locución hasta `voiceschanged` (con fallback
  temporizado de 350 ms para no quedar en silencio) → **la 1ª locución ya sale con la voz nativa**, no la
  española; (2) **precarga** al arrancar (`WordTts.warmUp()` en `main`) → caché caliente antes del primer toque;
  (3) **ranking por calidad estable + caché por idioma** (región exacta +100 · voz Google/Natural/Neural/
  Microsoft/Premium/Enhanced +20 · `localService` +5; solo del MISMO idioma base, jamás otro) → **misma voz cada
  vez**; (4) **degradación honesta**: sin voz del idioma → solo `lang` (NUNCA fuerza una voz de otro idioma).
- **REGLA pregrabado↔TTS** (ya de facto, ahora documentada): si el ítem trae MP3 pregrabado se usa ése; el TTS en
  vivo es solo para lo que NO tiene clip → **no se mezclan dos voces del mismo origen** en un mismo ítem. El audio
  de listening/historias (native Google) **no se toca** (guardarraíl: pregrabado + reconocimiento de speaking
  intactos).
- **Verificado (Chromium del navegador in-app, jezici.space):** `getVoices()`=0 en el 1er tick (timing bug real);
  tras `voiceschanged`, el ranking elige la mejor voz disponible (es-ES → Microsoft Helena, score 125) y devuelve
  `null` (solo `lang`) para idiomas sin voz instalada. **Honesto:** este entorno **no tiene voces en/fr/it/de/nl**
  → el inglés nativo solo se puede oír en un Chrome de escritorio/Android real (el entorno del usuario) con la voz
  del idioma instalada; el TTS **depende del navegador** (Chrome/Edge traen buenas voces; Firefox casi ninguna).
  analyze 0 (CI-exact) · test **184/184** · build web OK.

## 3 BUGS SOCIALES de USO REAL (4 jugadores en la liga) — cerrados ✅ LIVE (mig 163 · 2026-07-17)
Vienen de producción (ya hay reales: gian, eugenio, leo, juanflores, ana). Cero IA. Diagnóstico con
evidencia (cliente real), no parches.
- **BUG 1 · "Mi liga" mostraba 0 XP mientras "Tablas" mostraba la real.** PASO 0 (BD real): las **dos
  pantallas leían fuentes DISTINTAS** — `get_leaderboard` (Tablas) suma **`daily_goals` EN VIVO** de la
  semana; `get_league` (Mi liga) leía **`league_members.weekly_xp`**, columna que **`jz_register_activity`
  NUNCA escribe** (solo la toca `jz_close_weeks` al cerrar la semana) → **0 para todos** y hasta orden
  distinto. **FIX (mig 163):** `get_league` ahora usa la **MISMA fuente viva** (`sum(daily_goals.xp_earned)`
  de la semana `date_trunc('week')`) y **ordena por ella** → misma XP y mismo orden que Tablas. Read-only,
  no toca economía/racha/rollover. Verificado en vivo: Mi liga == Tablas (eugenio 71, juanflores 36, …).
- **BUG 2 · bloquear sin desbloquear (trampa, @eugenio).** `unblock_user` **ya existía** pero no había
  forma de **VER** a quién bloqueaste. **FIX:** nuevo RPC **`list_blocks`** (DEFINER, dueño; devuelve
  name/handle/avatar/blocked_at de los bloqueados) + pantalla **"Usuarios bloqueados"** en **Ajustes**
  (`BlockedUsersScreen`) con **desbloquear por fila** (optimista, invalida amigos/sugerencias). El bloqueo
  se revierte en **ambas direcciones RLS** (ya lo hacía `unblock_user`). i18n es/en/pt.
- **BUG 3 · ver el perfil público de cualquiera (liga + amigos).** `get_public_profile` (T3) **ya existía**
  y está **gateado 18+ / bloqueo / sin datos privados**. **FIX (mínimo):** `get_league` ahora expone
  **`user_id`** (null para "yo") y la **fila de la liga es tappable** → abre `PublicProfileScreen`. En
  Amigos ya se abría desde búsqueda/sugerencias (`_openProfile`); la fila de un amigo aceptado **sigue
  abriendo el chat** por diseño (no se tocó).
- **Verificado cliente REAL (`verify_social_bugs.py`, 2 cuentas) TODO VERDE:** liga==tablas (XP **y**
  orden; miembros traen user_id, "yo" no); block→`list_blocks` lo ve→con bloqueo el perfil da `not found`
  (ambas direcciones)→unblock→lista vacía→vuelven a verse; perfil público expone name/@handle y **NO**
  email/edad/bio/gender; **MENOR no aparece** (18+) y un **menor viewer no accede**. **Liga real intacta**
  (0 miembros de prueba; 5 reales). analyze 0 (CI-exact) · test **184/184** · build web OK.

## EL "MINUTO 4" — los 2 puntos de fuga de @eugenio, cerrados ✅ LIVE (mig 162 · 2026-07-16)
Vienen de **uso real** (ver el retrato abajo), no de una cola: @eugenio acabó su 1ª lección y (a) su racha
era imposible, (b) no había a dónde ir. Cero IA.
- **PASO 0 (medido):** `jz_register_activity` hacía `goal_xp = greatest(10, daily_minutes)` — **usa los
  minutos como si fueran XP**. Una lección da `xp_reward=15 × accuracy + combo(+2/acierto en racha ≥3)` =
  **~10 (mala) a ~31 (perfecta)**; la suya al 75% dio **17**. Con 45 min/día → meta 45 → **~3 lecciones
  seguidas el día 1**. Y `lesson_complete_screen` **recibía `next_lesson_id` del servidor y lo TIRABA**
  (el CTA hacía `popUntil(isFirst)` = te suelta en el mapa a buscar el nodo).
- **1 · RACHA ALCANZABLE EL DÍA 1 (mig 162 · rampa).** La meta **comprometida NO se toca** (sigue siendo la
  suya); solo se **escalona el arranque**: `día 1 = goal_ramp_first_xp` (**15** = exactamente el `xp_reward`
  de UNA lección → una lección decente ya gana la racha), **+`goal_ramp_step_xp` (10) por día activo**, hasta
  su meta real, durante `goal_ramp_days` (**3**). Todo en **`jz_config`**, no hardcodeado. Ej. 45 min/día:
  **15 → 25 → 35 → 45**; 20 min/día: 15 → 20 → 20. **`user_plans.daily_minutes` intacto → `estimation.dart`
  y la fecha del plan NO cambian** (verificado). Recreada 1:1 desde la definición viva: XP/oro, congelador,
  hitos y el resto de la racha sin tocar.
- **2 · "A DÓNDE IR" tras la lección.** El CTA usa el **`next_lesson_id` que el servidor ya daba**: **"SIGUIENTE
  LECCIÓN"** entra directo a la siguiente + "Volver al mapa" como secundario. **Degrada con gracia**: fin de
  unidad o lección no encontrada → el "CONTINUAR" de siempre. Y **Practicar deja de ser un vacío**: el HERO usa
  el conteo **del servidor** (`get_srs_status` = vencidas + nuevas que caben hoy) = lo que la sesión REALMENTE
  sirve (antes el cliente contaba por su cuenta y no cuadraba).
- **Verificado cliente REAL (`verify_minuto4.py`) TODO VERDE — reproduce su caso exacto (45 min/día):**
  1 lección real → **meta del día 15 (no 45) · meta CUMPLIDA · racha 1** (antes 0) · `daily_minutes` sigue 45 ·
  **next_lesson_id → lesson #2** · **12 palabras inscritas** y Practicar **sirve 10 tarjetas** de ESCRITURA
  (antes: "nada que repasar"). **GUARDARRAÍL `verify_chain` VERDE** (A1→B2 + certs; toqué `jz_register_activity`,
  que usa `complete_lesson`). analyze 0 · test **184/184** (+3 minuto4) · build web OK.
- **2 bugs reales cazados por los tests** (no fallos de test): (a) `_nextLesson()` usaba **`ref.read`** → si el
  mapa no estaba cacheado el CTA **degradaba para siempre** sin recuperarse → `ref.watch`; (b) el del SRS
  (`ValueListenableBuilder`) de la tanda anterior.
- **Pendiente honesto (no tocado):** la **misión de bienvenida** (+25 XP/oro) sigue **sin pasar por
  `jz_register_activity`** → no cuenta para meta/racha. Inocuo, pero es XP que el usuario ve y no le suma.

## ADMIN RECUPERADO + RETRATO DE LOS 2 PRIMEROS USUARIOS REALES ✅ (2026-07-16 · solo lectura + 1 insert)
- **ADMIN ✅ RECUPERADO** (la única escritura): `insert into public.admins(user_id) values
  ('afcaca89-06c8-4b8b-88fa-3434b5bfdfc7')` → **Gian (@gian) es admin**; verificado con el predicado exacto
  de `am_i_admin()`/`jz_is_admin()` (`exists(select 1 from admins where user_id=…)`) → **true**; control:
  @eugenio → **false**. **Solo 1 fila en `admins`.** Ya ve métricas/moderación/feedback/Sentry test.
- **CENSO: 2 usuarios reales.** `@gian` (alta 07-13 17:32) y `@eugenio` (alta 07-14 17:20). **Ambos
  completaron el onboarding ENTERO** (nombre + @handle + age gate + plan A1→B2 + consentimiento legal) y
  ambos eligieron **inglés** → **el flujo nuevo (solo-Google + @handle obligatorio) funciona end-to-end en
  producción, con usuarios reales.** Ambos **volvieron** (last_seen 32-59 h tras el alta).
- **@eugenio (el primer usuario que no es Gian) — línea de tiempo real:**
  · **07-14 17:20 — rebote #1:** entra al onboarding, pasos 0→2, **retrocede al paso 1 y abandona a los 3
  segundos**. No vuelve en ~30 h.
  · **07-15 23:23 — 2º intento:** recorre los pasos 0→11 en 1,5 min → **se queda 15 min parado en el paso 11**
  → el onboarding **vuelve a empezar desde 0** (23:41) → esta vez corre 0→8 en 21 s y **salta 9/10**
  (= saltó el placement: "primer contacto") → **onboarding_completed 23:41:42**.
  · **3 minutos de uso real:** misión de bienvenida (+25 XP/oro) → **1 lección, 52 s, 75 %** (+17 XP, +5 oro)
  → **nunca empezó la 2ª lección**.
  · **Luego solo navegó pestañas**: Ligas ×4, Perfil ×4, **Practicar ×4**, Conversar ×1. **07-16 01:15: abre
  la app, ve el mapa y se va.**
- **LO MÁS ACCIONABLE (2 hallazgos con dato):**
  1. **Volvió a Practicar 4 veces y no había nada que hacer.** Su lección NO le inscribió vocabulario porque
     `complete_lesson` no alimentaba el SRS → veía "Aún no tienes palabras por repasar". **Arreglado HOY**
     (mig 161): a partir de ahora la 1ª lección ya deja palabras en la agenda.
  2. **La racha era inalcanzable el día 1.** Eligió **45 min/día** → `jz_register_activity` fija
     `goal_xp = daily_minutes` = **45 XP**; su lección le dio **17 XP** → necesitaba ~3 lecciones para la
     racha. Hizo 1. **Racha 0, meta nunca cumplida.** (@gian eligió 20 min → meta 20 XP.)
- **Detalle menor observado:** la **misión de bienvenida** (+25 XP/oro, `reason='challenge'`) **no pasa por
  `jz_register_activity`** → no cuenta para la meta diaria ni la racha (@gian tiene 25 XP y **0 filas** en
  `daily_goals`). Inconsistente pero inocuo; no se tocó.
- **Salud:** **0 `client_error`** registrados, **0 feedback** enviado, **0 flujos a medias** (nadie sin plan,
  sin handle ni sin consentimiento). Nada roto: es un problema de **enganche**, no de bugs.
- **Lectura honesta:** son 2 **testers explorando**, no aprendices. Entre los dos: **3 lecciones completadas
  en total** (@gian **0**, @eugenio 1 + la misión) y **0 rachas**. El punto de fuga no es el registro (que
  funciona) sino **el minuto 4**: acabas tu primera lección y no hay un siguiente paso obvio ni recompensa de
  racha alcanzable. **Nadie ha visto todavía el SRS nuevo** (0 inscritas, 0 reviews: se desplegó hoy).

## SRS F0+F1 — Practicar deja de ser un quiz de opción múltiple: motor FSRS real ✅ LIVE (mig 159/160/161 · 2026-07-16)
Fuente de verdad: `PRACTICAR_SRS_ANALISIS.md` (§6 desacoplar motor/contenido · §7 F0/F1 · §3 FSRS sin
optimizador). Cero IA. **PASO 0 re-confirmado contra la BD** (todo cierto): escalera fija 1/2/4/8/16/30d ·
`ease` NUNCA se escribía (vestigial) · la cola trataba **las ~480 palabras del curso como vencidas**
(`s.vocab_id is null`) · servía **opción múltiple** · `complete_lesson` **no tocaba el SRS** (0 menciones).
- **F0 · Cola honesta + inscripción + ESCRITURA (los 6 idiomas).** `start_practice('srs')` sirve **solo
  palabras INSCRITAS** + límite de nuevas/día desde `jz_config` (**`srs_new_per_day=10`**, no 15: con un
  léxico de ~480 el mazo dura ~48 días en vez de ~32 — decisión del análisis §8.3, es config no código).
  **Adiós al MC**: la tarjeta es de **recuerdo activo escrito**. **DEGRADACIÓN CON GRACIA**: si la palabra
  tiene oración cloze usable → tarjeta `cloze` (escribe la palabra que falta EN CONTEXTO); si no → `word`
  (traducción → escribe la palabra). **`complete_lesson` INSCRIBE** (mig 161) por substring sobre TODOS los
  ítems, **best-effort y al FINAL** (un fallo del SRS jamás tumba el fin de lección); vista→`state='new'`,
  fallada→`due=now`. Re-ver una palabra ya agendada **NO adelanta** su repaso (rompería el espaciado).
- **F1 · Motor FSRS-4.5 server-side (mig 159).** `user_vocab_srs` **AMPLIADA** (no recreada): +stability,
  +difficulty, +state(new/learning/review/relearning), +reps, +lapses, +last_rating, +scheduled_days.
  `ease`/`strength` quedan **vestigiales** (se dejan de escribir; se borrarán en otra migración). **Tabla
  nueva `srs_review_log`** (RLS dueño, writes solo por RPC) = requisito de la métrica de retención y del
  optimizador futuro. **Pesos por defecto de Anki, SIN optimizador** (0 historial que optimizar; Anki mismo
  optimiza tras ~1.000 reviews) en `jz_fsrs_w()`. **Motor verificado contra sus propiedades conocidas**:
  S0 Bien=3.71→4d · Fácil=13.82→14d · **R(30,30)=0.9000 exacto** · intervalo≈estabilidad a R_d=0.9 · lapso
  acotado (S 30→4.35) + `relearning` + vuelve en la sesión. `get_srs_status` → vencidas/nuevas/**retención**
  (null si no hay maduras: no inventa un número).
- **DECISIÓN DE DISEÑO (síntesis honesta Anki↔Jezici):** el servidor **califica lo ESCRITO**; si está mal
  **fuerza rating=1 aunque el usuario pulse "Fácil"** → el botón modula el **intervalo**, nunca el pago ni
  el XP. La UI lo refleja: en un fallo **solo se ofrece "Otra vez"** (ofrecer "Fácil" sería mentir).
- **ECONOMÍA intacta:** UN solo pago por sesión (`least(correct*3,20)` + oro 2 = **menos que una lección**,
  5-10). **Anti-duplicado**: la relapsada que vuelve en la sesión cuenta **una vez** y con su **PRIMERA**
  respuesta → fallar-y-acertar **no paga**. La racha **no se tocó**: `jz_register_activity` ya la avanza al
  **CUMPLIR la meta diaria** (regla pre-existente) — el repaso alimenta `daily_goals` igual que una lección.
- **Verificado cliente REAL (`verify_srs.py` pt+de, 29 checks c/u) TODO VERDE:** cola vacía para el novato ·
  límite de 10/día · solo cloze|word (**0 opción múltiple**) · califica lo escrito 3/4 · XP 9 + oro 2 ·
  alimenta daily_goals · FSRS reprograma (review + stability>0) · fallada vuelve en sesión · review_log 4/4 ·
  repetida cuenta 1 y **no paga** · escribir mal + "Fácil" → **rating forzado a 1** · vencida vuelve · al
  cumplir la meta **la racha avanza** · **aislamiento multicurso**. **GUARDARRAÍLES VERDES**: `verify_chain`
  (en, A1→B2 + 4 certs) y `verify_pt_chain` (multicurso, 4 certs). analyze 0 · test **181/181** (+7
  srs_review) · build web OK.
- **Bug real cazado por el test** (no era del test): el CTA "COMPROBAR" se calculaba en `build()` y escribir
  no dispara rebuild → **habría nacido muerto**; arreglado con `ValueListenableBuilder` sobre el controller.
- **Test obsoleto arreglado (pre-existente, NO regresión mía):** `verify_pt_chain` fallaba desde **mig 130**
  (pt C1) porque leía los niveles de `units` y asertaba examen para C1 — **pero C1 no tiene examen POR
  DISEÑO** (techo honesto: `jz_resolve_exam_level` capa en B2; los 6 cursos tienen examen A1–B2 y ninguno
  C1). Ahora pregunta por los exámenes que EXISTEN. (Probado que no era mío: ese test **nunca llama a
  `complete_lesson`**.)
- **DEGRADACIÓN CON GRACIA — cobertura REAL hoy** (por eso F3 es otra misión): cloze **204/2868 (7.1%)** ·
  escritura-sin-oración **2664**. Por idioma: en 58 · pt 54 · nl 39 · de 28 · it 17 · **fr 8**. **Y NINGUNO
  tiene audio** (los 1.776 clips cuelgan de listening; `vocabulary` no tiene columna de audio) → el camino de
  audio está construido (`audio_url` en la tarjeta) pero **hoy no se enciende**: llegará con F3.
- **Re-encolado (## Cola):** **F2** `lesson_vocab` (el vínculo que falta: hoy la inscripción es por substring,
  no lematiza → inscribe de menos, nunca basura) · **F3** banco de ~2.664 oraciones nativas + TTS (~15-20
  días, el grueso; empezar por en/pt, fr es el más crítico) · **F4** P1 del spec (audio-primero, palabras
  problema, dinamismo). **Techo nombrado:** 480 palabras/curso se agotan en ~48 días a 10/día — el léxico es
  una semilla, no un léxico de B2/C1.

## LINK PREVIEW (Open Graph + Twitter Card) para compartir en LinkedIn/etc ✅ LIVE (2026-07-15 · solo cliente)
Al compartir `jezici.space` salía una tarjeta pelada (solo `<title>`). Ahora sale una tarjeta con marca.
Cero IA, no toca el arranque/PWA/manifest.
- **Meta tags en `web/index.html`** (`<head>`): Open Graph (`og:type=website`, `og:site_name`, `og:title`
  "Jezici — Aprende idiomas con un plan real", `og:description`, `og:url=https://jezici.space`,
  `og:image=https://jezici.space/og-image.png` **URL absoluta** + `og:image:secure_url`/`type`/`width 1200`/
  `height 630`/`alt`, `og:locale=es_ES`) + Twitter Card (`summary_large_image` + title/description/image/alt).
  De paso el `<title>` y `<meta description>` pasaron de "aprende inglés" → "aprende idiomas … 6 idiomas".
- **Imagen `web/og-image.png` (1200×630)**: gradiente violeta de marca + el **guacamayo escarlata Jezi**
  (portado 1:1 de `ParrotArt`/`_ParrotPainter`, entero con halo) + wordmark "Jezici" + tagline + chips
  (6 idiomas · 4 habilidades · Certificación real) + `jezici.space`. Generador reproducible
  `tools/content/gen_og_image.py` (Pillow, render 2x→LANCZOS, dibuja los paths bezier del loro; fuente
  Segoe UI). Se sirve en la raíz del dominio (`/og-image.png`, como favicon/icons); Vercel sirve el archivo
  estático antes del rewrite SPA.
- **Verificado**: build web copia `og-image.png` a `build/web/` y los 8 meta OG/Twitter quedan en el HTML
  servido; imagen 200 en `https://jezici.space/og-image.png` (tras deploy). analyze 0 · build web OK.
- **Cómo validar la preview (Gian):** LinkedIn **Post Inspector** (`linkedin.com/post-inspector/`) pegando
  `https://jezici.space` (fuerza re-scrape y muestra la tarjeta) · `opengraph.xyz` · para WhatsApp/Telegram,
  pegar el link en un chat. LinkedIn **cachea** la preview: si cambia la imagen, re-inspeccionar para refrescar.

## 🌐 DOMINIO OFICIAL: **jezici.space** (conectado y LIVE · 2026-07-14)
El dominio propio de Gian **ya está conectado y sirviendo** (verificado: 200 en `/`, `/privacy`, `/terms`).
`jezici.vercel.app` sigue respondiendo pero es **legado** — usa `jezici.space` en todo lo nuevo.
- **URLs canónicas:** app `https://jezici.space` · privacidad `https://jezici.space/privacy` · términos
  `https://jezici.space/terms` (son las que van en el consentimiento de Google, Search Console, LinkedIn).
- **El CÓDIGO no requiere cambios** (verificado): el OAuth usa `Uri.base.origin` (deploy-agnóstico) y las
  páginas legales se abren relativas al origen → funcionan solas en el dominio nuevo. Solo quedaban
  comentarios citando el dominio viejo.
- **⚠️ DEPENDE DE GIAN (dashboards) — si no, "Continuar con Google" FALLA en jezici.space:**
  (a) **Supabase → Auth → URL Configuration**: Site URL = `https://jezici.space` y Redirect URLs debe incluir
  `https://jezici.space/**`; (b) **Google Cloud → Credentials → OAuth client**: *Authorized JavaScript origins*
  debe incluir `https://jezici.space` (el redirect URI sigue siendo el de Supabase
  `https://wiauinufpbkmjlbqlkxo.supabase.co/auth/v1/callback`, no cambia); (c) en la **OAuth consent screen**,
  actualizar los enlaces de privacidad/términos a los de `jezici.space`.

## RESET TOTAL DE USUARIOS + REGISTRO SOLO-GOOGLE + @HANDLE OBLIGATORIO ✅ LIVE (mig 157/158 · 2026-07-13)
Misión destructiva + cambios de auth (Gian coordinó el reseteo con sus testers). Cero IA. **PASO 0 (censo
real con `reset_census.py` + `reset_probe*` + dry-run con ROLLBACK antes de borrar):** 20 usuarios en
auth.users/public.users, 2782 filas de datos de usuario en 45 tablas. Mecánica verificada: `public.users.id →
auth.users` es CASCADE y `public.users` cascada a las 44 tablas de datos de usuario (todas CASCADE) +
auth.identities/sessions/oauth/etc.
- **1 · RESETEO (mig 157, irreversible):** `delete from auth.users` (cascada a TODO) + borrado explícito de las
  4 tablas que NO cascadan (`analytics_events`/`feedback`/`conversation_rooms` = user_id SET NULL,
  `social_search_log` = sin FK). **Dry-run con ROLLBACK** probó 0 filas de usuario y courses(6)/content(5182)
  intactos ANTES de comprometer. **Censo post = TODO 0** (auth.users 0, public.users 0, las 45 tablas 0, incl.
  sociales connections/messages/coop y auth.identities/sessions). **Contenido/config PRESERVADO** (courses 6,
  units 180, lessons 901, content_items 5182, languages 7, jz_config 8, tips 192, stories 16). Sin políticas ni
  funciones rotas (am_i_admin/claim_handle intactas). Evidencia en `_reset_census_pre/post.json` (gitignored).
- **2 · REGISTRO SOLO GOOGLE (beta):** flag `core/config/auth_config.dart` `kAuthEmailEnabled=false` (reactivable
  → email vuelve en el lanzamiento oficial, NO se borró el código). `auth_screen` oculta email/contraseña/toggle
  tras el flag y muestra **solo "Continuar con Google"** + nota beta + consentimiento informativo (Términos/
  Privacidad; el registro legal formal se persiste en el onboarding). Fallback: fuera de web (native, no
  desplegado) el email sigue disponible para no dejar la pantalla muerta. Error de Google ya no dice "usa tu
  email" cuando el email está oculto (`authGoogleRetry`). Los datos que Google no da (año/age gate, género…) se
  siguen pidiendo en el onboarding/CompleteProfile.
- **3 · @HANDLE ÚNICO OBLIGATORIO EN EL ARRANQUE (mig 158):** el @usuario pasa a ser **identidad de entrada para
  TODOS** (no solo lo social). `claim_handle` deja de exigir `jz_social_access` (18+) — un menor también necesita
  su @usuario para entrar; **la descubribilidad/perfil público SIGUEN 18+** (`search_users`/`get_public_profile`/
  `list_friends`/`request_friend` sin cambios) → un menor con handle **NO** queda expuesto socialmente. `get_profile`
  ahora devuelve `handle`; el **AppGate** (`main.dart`) antepone el gate `HandleGateScreen(startup:true)` tras el
  onboarding/age-gate y ANTES del HomeShell si `profile.handle==null` (ineludible, sin "atrás", copy universal
  `handleSetupSubtitle`). UNIQUE case-insensitive `users_handle_lower_uk` (T3) confirmado; tomado→`handle_taken`,
  inválido→`invalid_handle`, reservado→`handle_reserved`. i18n es/en/pt (+4 claves).
- **Verificado cliente REAL (`verify_handle_mandatory.py`, JWT) TODO VERDE:** MENOR (12 años) reclama @handle sin
  ser adulto; get_profile lo devuelve; tomado case-insensitive→handle_taken; inválido/reservado tipados; adulto
  reclama válido; **el menor con handle NO aparece en `search_users`** (sigue 18+). Usuarios de prueba borrados
  (auth.users vuelve a 0). analyze 0 (CI-exact) · test **174/174** (+3 auth_reset) · build web OK.
- **⚠️ RECUPERACIÓN DE ADMIN (crítico, para Gian):** tras el reseteo **NADIE es admin** (la fila de `admins` se
  borró). Cuando Gian se registre de nuevo con Google, obtener su nuevo uid y volverlo admin:
  1. Gian entra a jezici.vercel.app → **Continuar con Google** → onboarding → elige su @usuario.
  2. Obtener su uid (SQL vía Management API / apply_sql):
     `select id, email from auth.users where email='gianpierodaniel@gmail.com';`
  3. Volverlo admin: `insert into public.admins(user_id) values ('<ese_uid>') on conflict do nothing;`
  4. Verificar: en la app, Ajustes → "Ver métricas (interno)" debe aparecer; `am_i_admin()` → true. Recupera
     métricas, moderación (`get_reports`/`mod_apply`), Sentry test, feedback (`get_feedback`).
  (La tabla `admins` = `(user_id uuid, created_at default now())`. El anterior uid de Gian era
  `7b4a8e40-adf0-4e42-bd1e-1f0bf21e305c` — ya no existe; el nuevo será distinto.)
- **Google OAuth:** ya configurado (Supabase + Google Cloud, sesión previa). Si tras el reseteo el botón fallara,
  revisar Supabase → Auth → Providers → Google (Client ID/Secret) y URL Configuration (Site/Redirect) — pasos de
  Gian, no de código (ver sección "Registro sin fricción" abajo).

## TOUR DE BIENVENIDA con Jezi (coach marks) ✅ LIVE (2026-07-13 · solo cliente, flag LOCAL)
Feedback de Gian. La PRIMERA vez que el usuario llega al mapa, Jezi lo guía por la app con cuadros pequeños
que resaltan el elemento REAL. Cero IA, sin migración.
- **Disparo/persistencia:** flag LOCAL `welcome_tour_seen` (`SharedPreferences`, patrón `NotifierProvider`
  `welcomeTourSeenProvider`): se asume "visto" hasta que la preferencia carga (**no parpadea** a quien ya lo
  vio) y solo se muestra si la clave no existe → **una vez, nunca más**. Se muestra sobre el mapa (tab 0);
  al saltar/terminar → `markSeen()`.
- **Formato:** 8 pasos cortos con Jezi — bienvenida · mapa ("empieza abajo") · barra superior (vidas/oro/racha)
  · Practicar · Conversar · Ligas · Perfil · cierre con CTA "¡Empezar!". Cada paso **resalta el elemento REAL**
  (spotlight = fondo oscuro con hueco redondeado + anillo) apuntando a la **barra superior del mapa** y a los
  **botones del nav inferior** vía `GlobalKeys` (`core/ui/tour_keys.dart`, adjuntadas a `BottomNav.itemKeys` +
  `LearnTopBar`). Bienvenida/cierre centrados.
- **UX:** overlay que oscurece el fondo y **absorbe taps** (no toca la UI por error); **Saltar** en cualquier
  momento, **Atrás/Siguiente**, puntos de progreso, CTA con labio 3D. **Nunca bloquea** (siempre saltable); si
  un elemento no está montado, el paso se **centra** (degradación con gracia). La tarjeta se coloca debajo/encima
  del elemento según su posición → apunta bien en **móvil y desktop**. **Reduce-motion-aware**. Lenguaje simple.
- i18n es/en/pt (24 claves). +`welcome_tour_test` (navega, salta, CTA final PT sin español). analyze 0 (CI-exact)
  · test **171/171** · build web OK · CI SUCCESS · deploy READY.
- **Cómo re-verlo (probar como usuario nuevo):** borrar la clave local — en la consola del navegador
  `localStorage` no aplica (Flutter usa IndexedDB para shared_preferences en web); lo simple es **Ajustes del
  navegador → borrar datos del sitio** (o una ventana incógnita / otro dispositivo), o **borrar la app** en móvil.
  Cualquier alta NUEVA lo ve una vez.

## PRINCIPIANTE — 2 P0 cerrados: Practicar honesto a cero + onboarding "¿eres nuevo?" ✅ LIVE (2026-07-13 · solo cliente)
Cierra las 2 peores fricciones del que empieza de cero (PRINCIPIANTE_ANALISIS P0 #1/#5 y #2). Cero IA, sin
migración. NO toca placement (anti-azar) / certificación / economía.
- **P0 #1+#5 · el 2º tab "Practicar" ya NO miente a un novato:** el BUG era `dueWords = vocab_total −
  agendado` → un novato con 0 agendado veía el vocabulario ENTERO como "N palabras por repasar", y al tocar
  salía "¡Nada que reforzar!" (contradicción). Ahora `dueWords` cuenta **SOLO filas de `user_vocab_srs`
  VENCIDAS** (due_at ≤ ahora) = palabras que YA VIO (se quitó la query a `vocabulary`). **Estado de
  BIENVENIDA** para el novato (`hasProgress` = ¿tiene alguna lección con progreso?): "Aún no tienes palabras
  por repasar. Completa tu primera lección…" + CTA **"Ir a mi lección"** (→ pestaña del mapa vía
  `homeTabRequestProvider`, un `NotifierProvider` que el HomeShell escucha). Con 0 progreso se **OCULTAN** las
  secciones que darían "nada que reforzar" (SRS/punto débil/reforzar/Lectura/Redacción/Contrarreloj) y se dejan
  **Inmersión + Repaso** (útiles desde el día 0). `complete_lesson` NO alimenta el SRS (solo la práctica SRS y
  los fallos) → por eso la señal de novato es "sin progreso de lecciones", no "SRS vacío".
- **P0 #2 · el onboarding ya NO empuja al novato a un examen A2:** el paso de nivel usa el **patrón Duolingo
  "¿Es tu primer contacto con {idioma}?"** SIN default peligroso (antes el default "Sé lo básico" → placement
  en A2). **"Sí"** → fija A1 y **SALTA** el placement; **"No"** → sub-vista "Sé lo básico / Tengo buen nivel" +
  corre el placement. Atrás vuelve del sub-paso a la pregunta. El mecanismo "desde cero → A1/Unidad 1"
  (create_plan) ya existía, intacto.
- i18n es/en/pt · responsive · reduce-motion-aware. Riverpod 3 (StateProvider removido → NotifierProvider).
  +practice_screen_test (novato: bienvenida, sin número falso, secciones vacías ocultas). analyze 0 (CI-exact)
  · test **168/168** · build web OK · CI SUCCESS · deploy READY. **Quedan P1/P2 del análisis** (enseñar antes
  de examinar; sonidos/pronunciación) en PRINCIPIANTE_ANALISIS.md.

## AMIGOS VIVOS — presencia honesta + lista dinámica + inmediatez ✅ LIVE (mig 156 · 2026-07-13)
Rediseño de Amigos tras el fix de bugs (capa visual + presencia; la lógica social arreglada NO se toca).
Presencia HONESTA: nada inventado (sin señal → "activo hace X"/desconectado, jamás "en línea" falso).
- **1 · PRESENCIA (mig 156):** `users.last_seen` + `show_presence` + `heartbeat()` (un UPDATE por PK,
  barato). El **HomeShell late** al abrir, al volver del background y **cada 90s en primer plano**, y **se
  PAUSA en background** (sin gasto de batería/red). `list_friends` y `suggest_friends` devuelven `last_seen`
  (respetando `show_presence`, 18+, blocks, descubribilidad). El cliente deriva **"En línea"** (heartbeat
  <3 min) / **"Activo hace X min/h/d"** / **"Desconectado"**. Toggle de privacidad `set_presence(on)` para
  ocultar el "en línea" (get_social_status lo expone).
- **2 · LISTA dinámica:** `_StatusAvatar` con **punto verde que respira** (reduce-motion-aware) + etiqueta de
  estado en vivo (verde "En línea" / gris "Activo hace X") en lugar de "toca para chatear"; racha 🔥 pulsante;
  **orden por actividad (en línea primero, server-side)**; entrada directa al chat.
- **3 · SUGERENCIAS "Personas para ti":** carrusel con presencia (chip verde **"En línea ahora"**), nivel CEFR
  si offline, orden en-línea-primero (server), botón claro de agregar. Vacío con Jezi.
- **4 · INMEDIATEZ (optimismo):** al enviar solicitud el botón pasa a **"Enviada ✓" al instante** (revierte si
  falla); al **aceptar**, la solicitud **desaparece de inmediato**; **`skipLoadingOnRefresh`** conserva la data
  al refrescar → **sin parpadeos ni spinner**.
- **Seguridad P1/T3 intacta** (18+, blocks bidireccionales, DEFINER, no expone datos privados). i18n es/en/pt,
  responsive, reduce-motion-aware. **Verificado cliente REAL (`verify_presence.py` TODO VERDE):** heartbeat
  sella last_seen; list_friends lo devuelve + handle; `set_presence(false)` lo **OCULTA** a los demás y `(true)`
  lo vuelve a mostrar; suggest_friends expone last_seen. + `friends_ui_test` (estado en línea/offline). analyze
  0 (CI-exact) · test **167/167** · build web OK.

## AMISTAD+CHAT — bugs de uso real: código fuera, orden del chat, lag, gate ✅ LIVE (2026-07-13 · solo cliente)
Pasada SOLO de corrección (el rediseño visual va aparte). Decisión de Gian: **el @handle es la ÚNICA vía de
agregar**. PASO 0 con 2 usuarios JWT reales: el **servidor de amistad ya funcionaba** (agregar por @handle
crea pending + notifica a B; `list_messages` devuelve orden cronológico) — los 4 bugs eran de **CLIENTE**.
Cero migración.
- **1 · CÓDIGO fuera de la UI:** se quitó el bloque "TU CÓDIGO" + input "agregar por código" (`_codeSection`/
  `_CodeHero`/`_addByCode`/`_copyCode`/`_code`). Agregar = **solo buscar por @usuario/nombre** → solicitud. La
  columna `friend_code` **NO se toca en BD** (queda como dato interno no expuesto). Empty-state y copy sin
  referencias a "código" (i18n es/en/pt). **Amistades existentes intactas.**
- **2 · GATE DE HANDLE no-muerto (síntoma "la solicitud no llega"):** causa real = el receptor con `@handle=NULL`
  (p.ej. Gian) topaba con el gate T3 que bloquea Amigos. El servidor SÍ crea la pending + notifica (verificado).
  Ahora el gate, si el usuario **YA tiene solicitudes entrantes**, las anuncia claro ("Tienes solicitudes
  esperando. Elige tu @usuario para verlas y aceptarlas" — `list_friends` funciona sin handle, solo exige
  adulto); tras elegir @usuario, las pendientes aparecen. La notificación además llega por la **campana** (no
  gateada por handle).
- **3 · ORDEN DEL CHAT:** el stream Realtime (`.order('created_at')`) viene **DESCENDENTE** → con `reverse:true`
  los mensajes nuevos salían **ARRIBA**. Fix: se ordena **ASCENDENTE explícito** en el builder (created_at ISO =
  lexicográfico = cronológico) → el más reciente **ABAJO** y `reverse:true` ancla la vista al último (autoscroll
  natural al abrir/enviar/recibir).
- **4 · LAG del chat (causa perfilada):** (a) el stream Realtime se creaba **DENTRO de `build()`** → cada rebuild
  (incluida **cada tecla**) **RE-SUSCRIBÍA** el canal Realtime = el lag. Ahora se fija **UNA vez en `initState`**.
  (b) el padre hacía `setState` en **cada tecla** (para el toggle 🎤↔➤) → reconstruía TODA la lista de mensajes;
  ahora **solo el botón del composer** se reconstruye (`ValueListenableBuilder` sobre el controller) → escribir
  ya no toca la lista.
- **Seguridad P1/T3 intacta** (18+, blocks bidireccionales, rate limits, DEFINER; certificación/aislamiento sin
  tocar). Verificado servidor `verify_friends.py` TODO VERDE (agregar por @handle + notif + orden `list_messages`)
  + `friends_ui_test` actualizado (sin código en la UI). analyze 0 (CI-exact) · test **167/167** · build web OK.

## AMISTAD ROTA — diagnóstico con evidencia + fix END-TO-END ✅ LIVE (mig 154/155 · 2026-07-13)
Feedback real (Gian + tester 18+): (1) agregar por código falla con código correcto; (2) la solicitud
"no le llega" al otro; (3) sin sugerencias. **PASO 0 con cliente REAL (dos JWT, `repro_friends.py`):** el
**SERVIDOR de amistad FUNCIONA** — enviar por código crea `pending`, `list_friends.incoming` la devuelve,
aceptar la vuelve amistad (reproducido 100% con adultos frescos, y enviando al código REAL de leopoldo).
Datos de prod: **solo 3 de 18 usuarios son adultos** (15 sin `birth_year` → sin acceso social, por age gate);
los 3 adultos = **Gian (handle NULL)**, leopoldo (V5KP8VL), leo — y **leo↔leopoldo YA son amigos**. Causas RAÍZ:
- **Síntoma 1 (código "falla"):** el cliente **tragaba el error real** con `catch(_)` → mostraba "Revisa el
  código" para TODO. En prod: reintentar el código de leopoldo daba `already friends` (ya eran amigos)
  enmascarado como "revisa el código"; igual `cannot add yourself`, `social unavailable` (no adulto),
  `rate_limited`. **FIX:** `friendErrorMessage()` traduce el motivo REAL a mensaje claro (i18n es/en/pt) en los
  **3 puntos de agregar** (código, búsqueda, perfil público); `sentFriendMessage()` distingue enviado vs
  **mutuo-aceptado** ("¡Ya son amigos!").
- **Síntoma 2 (no le llega):** `incoming` SÍ trae la solicitud (probado) — pero **NADA avisaba al receptor**
  → no tenía señal para abrir Amigos. **FIX (mig 154 enum + 155 lógica):** `jz_notify_friend` inserta una
  **notificación (in-app + push)** al receptor en cada solicitud y al requester al aceptarse; viaja por la
  tabla `notifications` (`status='sent'` → centro de notificaciones + Edge Function `matix-push`). Best-effort
  (un fallo de aviso jamás tumba la solicitud). Enum +`friend_request`/`friend_accepted`. La campana no está
  tras el gate de @handle, así que Gian (handle NULL) VE el aviso aunque su pantalla de Amigos siga pidiéndole
  elegir @usuario primero.
- **Síntoma 3 (sin sugerencias):** `suggest_friends` exigía **MISMO curso activo** → en beta chica devolvía `[]`.
  **FIX:** ahora sugiere a **cualquier ADULTO descubrible** (no yo, no ya conectado, no bloqueado, no sancionado,
  18+), priorizando mismo curso + nivel cercano + racha. Sin inventar presencia.
- **Seguridad P1/T3 intacta:** 18+, blocks bidireccionales, rate limits, no-descubribles/menores/sancionados
  excluidos, todo por RPC SECURITY DEFINER.
- **Verificado cliente REAL (`verify_friends.py`, TODO VERDE):** código→pending→**notif al receptor (push-ready,
  pushed_at null)**→incoming→aceptar→**notif al requester**→amigos; `already friends`/`self`/`bad code` tipados;
  C sin mismo curso recibe sugerencias de adultos reales; **menor** y **no-descubrible** fuera; **bloqueo excluye
  en AMBAS direcciones**. analyze 0 (CI-exact) · test **167/167** (+friend_error_mapping) · build web OK.
- **⚠️ Para Gian (no es bug de código):** solo 3/18 testers pusieron su año → los otros 15 no ven lo social (age
  gate innegociable). Y **tu cuenta tiene @handle NULL** → elige tu @usuario en Amigos para enviar/ver
  solicitudes en la app (el aviso te llega igual por la campana). Verificación con 2 cuentas más abajo.

## DONACIONES — métodos de pago ACTIVADOS (PayPal + QR real de Yape) ✅ LIVE (2026-07-12 · commit `2522108`)
Cero IA, cero cambios de lógica (framing de apoyo voluntario intacto; nada desbloquea contenido). Rellenados los
placeholders que dejó T6 en `core/config/donations.dart` con los datos reales de Gian:
- **PayPal ✅ LIVE:** `paypalUrl` = `https://www.paypal.com/donate/?hosted_button_id=7PDSNNUTYRXUG` (botón de
  donación hospedado). El método deja de estar "Pronto" → **tappable**, abre la URL (label "Donar con PayPal"/
  "Doar com PayPal"). PayPal es ENLACE, no QR.
- **Yape ✅ LIVE:** número **906517394** (ya estaba) + **QR REAL** (`app/assets/donations/yape_qr.png`, 659×629,
  reemplaza el placeholder generado).
- **Plin ⏳ número LISTO, falta QR:** número 906517394 (mismo que Yape) funcional. Se **BORRÓ** el `plin_qr.png`
  placeholder (era un QR **FALSO** con aspecto escaneable → engañoso); sin archivo, la fila muestra un icono
  neutro "sin QR" (`errorBuilder`) + el número copiable sigue operativo. **Gian debe subir su QR real como
  `app/assets/donations/plin_qr.png`** (PNG cuadrado) para completar.
- **Stripe ⏳ "Pronto":** `stripeUrl` sigue vacío (Gian aún no generó el Payment Link) → deshabilitado, sin botón
  muerto. Al pegar el link en `donations.dart` se activa.
- **Limpieza de assets:** el `yaper_qr.jpg` con typo ya no existe; el pubspec declara el **directorio**
  `assets/donations/` (un archivo ausente NO rompe el build, degrada a placeholder). ⚠️ Quedó un
  `app/assets/donations/paypal_qr.png` (128×128) **sin trackear** y **no usado** (PayPal va por URL) — no se
  commiteó; Gian puede borrarlo (no afecta a producción, no está en git). Test `donations_card` actualizado al
  comportamiento nuevo (PayPal live, solo 1 "Pronto"/"Em breve" = Stripe). i18n es/en/pt intacto. analyze 0 ·
  test 165/165 · build web OK (yape_qr real bundleado) · CI SUCCESS · deploy READY.
- **⚠️ PARA COMPLETAR (Gian):** (a) subir `app/assets/donations/plin_qr.png` (su QR de Plin; PNG cuadrado);
  (b) pegar el Payment Link de Stripe en `stripeUrl` de `app/lib/core/config/donations.dart`. Nada más — PayPal
  y Yape ya están live.

## SENTRY — monitoreo de errores en producción, integrado a mano ✅ (2026-07-12 · solo cliente)
Cero IA. PASO 0: Sentry YA estaba cableado limpio de una sesión previa (`sentry_flutter: ^8.9.0`;
`core/monitoring/sentry_config.dart` con `runWithSentry` que envuelve `runApp` capturando Flutter+nativo+
zona; lee `SENTRY_DSN` de `--dart-define`, **DSN vacío → NO-OP** y la app arranca igual; `release=jezici@
${appBuild()}` = sello JZ_BUILD/commit; `sendDefaultPii=false`; `beforeSend` filtra ruido de red; `sentrySetUser`
solo id opaco, sin email/PII). **NO se usó el wizard automático.** Ajustes de esta sesión:
- **Config afinada:** `environment` default `beta`→**`production`**; `tracesSampleRate` `0.1`→**`0.2`** (cuida
  cuota). El DSN **NO se hardcodea** (sigue viniendo de `--dart-define=SENTRY_DSN`).
- **Modo de PRUEBA admin-gated:** `sentryTestEvent()` (captura una excepción, **no crashea**, devuelve el id) +
  tarjeta **"Monitoreo de errores (Sentry)"** en `MetricsScreen` (que ya es **admin-only** vía isAdmin) con
  estado (Activo/Apagado) y botón "Enviar evento de prueba". **NO hay botón de error visible al público.**
- **Verificado:** compila **con y sin** `SENTRY_DSN` (sin él → Sentry off, arranca igual; con él → el DSN se
  inyecta en el bundle, build OK). **El proyecto Sentry de Gian RECIBE eventos**: POST directo a la API de
  ingesta (`.../api/4511724301058048/store/`) con el DSN → **HTTP 200** (event_id `5a6f85…`). analyze 0 · test
  **165/165** · build web OK.
- **⚠️ ACTIVACIÓN vía `build.sh` (2026-07-12 · commit `c9234f4`) — el Build Command de Vercel topó los 256
  chars.** El comando histórico (clone flutter + `--dart-define` de SUPABASE) ya estaba al límite → NO cabía
  añadir `--dart-define=SENTRY_DSN`. **Solución:** se movió TODO el build a **`build.sh`** (raíz del repo), que
  replica el buildCommand **1:1** + añade `--dart-define=SENTRY_DSN="${SENTRY_DSN:-}"` leyendo la env var del
  sistema. Así el Build Command del **dashboard** queda en **`bash build.sh`** (13 chars) → caben todos los
  `--dart-define` sin límite. **`vercel.json` NO se tocó** (su buildCommand sigue byte-idéntico; el override del
  dashboard tiene precedencia → `build.sh` convive sin romper el deploy viejo, verificado: el deploy de `c9234f4`
  quedó **READY** aún con el comando antiguo). `SENTRY_DSN` vacío/no seteada → flag vacío → **Sentry NO-OP** y el
  build NO falla (respeta `String.fromEnvironment('SENTRY_DSN', defaultValue: '')`). `.gitattributes` fuerza
  `*.sh eol=lf` (un `.sh` con CRLF rompería en Linux/Vercel). Verificado: build web real con los 3 `--dart-define`
  (SENTRY_DSN seteada) → `Built build/web`; expansión del env OK con y sin la var; analyze 0 · test 165/165 ·
  CI SUCCESS · deploy READY.
- **⚠️ PASOS EXACTOS para Gian (dashboard, en ORDEN — transición segura sin deploy roto):**
  1. **Crear la env var** en **Vercel → Project Settings → Environment Variables**: nombre **`SENTRY_DSN`**,
     valor (LITERAL) `https://6d5f60c2afe2f7429f1ca6159c52f2fc@o4511724290703360.ingest.us.sentry.io/4511724301058048`,
     scope **Production** (marca también Preview si quieres Sentry en previews). Save. *(El DSN NO es secreto —
     va en clientes.)* Opcional: `SENTRY_ENV=production` (ya es el default en código, no hace falta).
  2. **Cambiar el Build Command** en **Vercel → Project Settings → Build & Development → Build Command**
     (override del dashboard): pon exactamente **`bash build.sh`** y **Save**. El **Output Directory** sigue
     **`app/build/web`** (no cambia). **NO tocar `vercel.json`.**
  3. **Redeploy** (Deployments → último → ⋯ → Redeploy, o un push a `main`) → **confirmar deploy READY** (no
     ERROR instantáneo pre-build). Como el script clona Flutter y corre el mismo `flutter build web`, tarda ~2 min.
  4. **Probar:** Ajustes → Ver métricas → tarjeta "Monitoreo de errores (Sentry)" (debe decir **Activo**) →
     "Enviar evento de prueba" → el issue aparece en el dashboard de Sentry en segundos.
  - **Orden importa:** crea la env var (paso 1) **antes** de cambiar el Build Command (paso 2); si cambias el
    comando sin la var, el build igual funciona (SENTRY_DSN vacío → Sentry off), así que no hay riesgo de deploy
    roto en ningún orden — pero con este orden el primer deploy nuevo ya trae Sentry activo.

## T6 — legal (correo/logo) + bloque de DONACIONES "Aporta un grano de arena" ✅ LIVE (2026-07-12 · solo cliente)
Cero IA. Cero migración. NO se tocaron cláusulas legales, ni premium/pagos reales (siguen "próximamente"),
ni economía. Decisiones de Gian: donaciones con Yape (906517394 + QR), Plin, PayPal, Stripe (cuentas suyas).
- **1 · LEGAL (cosmético):** en `web/privacy.html` (3 refs) + `web/terms.html` (1 ref) el correo
  `shadowgames.devteam@gmail.com` → **`gianpierodaniel@gmail.com`**; el logo del encabezado (era emoji 🦜) →
  **guacamayo de marca** (`<img src="/brand/jezici_icon.svg">`, ya existía en `web/brand/`; Flutter lo copia a
  `build/web/`). **NO se tocó el texto de las cláusulas.** El correo NO aparece en Dart (solo en el HTML).
- **2 · DONACIONES — "Aporta un grano de arena"** (`donations_card.dart`), en **Premium DEBAJO del paywall
  "próximamente"**. Framing HONESTO: apoyo voluntario, **NO compra que desbloquee nada** (nota explícita).
  Métodos: **Yape** (número 906517394 + QR + "copiar número"), **Plin** (mismo patrón; nota "mismo número que
  Yape"), **PayPal** y **Stripe** como ENLACE — si su URL no está configurada aparecen deshabilitados con
  "Pronto" (no botón muerto). Lenguaje de la casa (tarjeta blanca + Jezi + acentos por método). i18n es/en/pt,
  responsive, reduce-motion-aware.
- **CONFIG única `core/config/donations.dart`** (lo que Gian rellena para ACTIVAR, sin tocar código complejo):
  `paypalUrl`/`stripeUrl` (pega el enlace → el método se vuelve tappable) y reemplazar los PNG placeholder
  `assets/donations/yape_qr.png` + `plin_qr.png` (mismo nombre) por sus QR reales. `yapeNumber`/`plinNumber`
  ya puestos (906517394). Los QR placeholder se generaron con aspecto de QR (finder patterns) para que se vea
  dónde va el asset.
- **⚠️ PLACEHOLDERS que Gian debe rellenar** (todo en `app/lib/core/config/donations.dart` salvo los QR):
  (a) `assets/donations/yape_qr.png` ← su QR de Yape; (b) `assets/donations/plin_qr.png` ← su QR de Plin
  (o el mismo si Yape/Plin comparten); (c) `paypalUrl` = su `paypal.me/...` o botón; (d) `stripeUrl` = su
  Payment Link del dashboard Stripe. Sin (c)/(d) esos métodos muestran "Pronto".
- Verde: analyze 0 (CI-exact) · test **165/165** (+3 donations_card: números 906517394 + copiar + PT sin
  español) · build web OK (correo/logo/QR confirmados en `build/web`). Golden del bloque revisado.

## T5 — editar perfil dinámico (género + cumpleaños OBLIGATORIOS) + MULTI-IDIOMA ✅ LIVE (mig 153 · 2026-07-12)
Decisiones de Gian (firmes): **género OBLIGATORIO sin omitir · cumpleaños día Y mes OBLIGATORIOS (el AÑO
ya lo captura el age gate; NO se re-pide) · avatar = selector de COLORES.** PASO 0 honesto: `set_profile`
es LENIENTE (género fuera de whitelist se IGNORA; día/mes opcionales) — correcto para el paso de NOMBRE del
onboarding y CompleteProfileScreen (solo envían nombre) → NO se endurece (rompería esos flujos); se añade
una RPC ESTRICTA para el formulario. `get_courses` NO distinguía qué cursos EMPEZÓ el usuario (solo el
activo) → el switch del home mostraba los 6.
- **1 · AVATAR — selector de COLORES:** el `edit_profile_sheet` ahora muestra 8 **muestras circulares** con
  gradiente; la elegida lleva anillo blanco + check + rebote sutil (`AnimatedScale` easeOutBack,
  reduce-motion-aware); el **preview grande se tiñe EN VIVO**. Persistido (avatar_color, validado hex server-side).
- **2 · PAÍS — buscador con BANDERA:** campo que abre un **sheet con buscador** (`normalizeSearch`, sin acentos)
  sobre **~55 países** (hispanoamérica + donde se hablan los idiomas meta + comunes), cada fila con bandera emoji
  + nombre; persiste ISO-2. Se muestra en el perfil público (T3).
- **3 · GÉNERO — OBLIGATORIO:** chips (femenino/masculino/otro/prefiero-no-decir); tocar SELECCIONA (ya NO
  deselecciona); guardar sin género → error. Validado también server-side (→ `gender_required`).
- **4 · CUMPLEAÑOS — día Y mes OBLIGATORIOS:** dropdowns sin opción `—`; guardar sin ambos → error. El **AÑO
  NO se re-pide** (viene del age gate; `set_profile_required` no lo toca). Validado server-side (→ `birthday_required`).
- **RPC estricta `set_profile_required`** (name+gender+bday obligatorios; hex normalizado; nombre visible sigue
  LIBRE, no toca certificados). El cliente valida rápido pero **el servidor es la autoridad** (motivos tipados).
- **5 · MULTI-IDIOMA:** `get_courses` ganó **`started`** (¿tiene `user_plans` en ese curso?). **El switch del
  home (bandera) muestra SOLO los idiomas que YA aprende** (started) + una fila **"Añadir idioma"**; cambiar entre
  ellos es instantáneo (`switchCourseFlow` existente). **En Ajustes: "Añadir idioma de aprendizaje"** → lista de
  los idiomas AÚN NO estudiados → al elegir arranca ese curso (placement o "desde cero" → create_plan) y lo suma
  a sus activos. **Aislamiento multicurso verificado:** añadir un idioma crea SU plan (course-scoped, UNIQUE
  user_id+course_id) SIN tocar el progreso de otro.
- **Verificado cliente REAL (`verify_t5.py`, 18 checks TODO VERDE):** género/cumpleaños/nombre vacío → rechazo
  server-side; perfil completo guarda (avatar/país/día-mes persisten; **AÑO del age gate intacto**); género basura
  rechazado; `started` en/pt correcto; **añadir PT no toca el progreso de EN**; los planes coexisten; volver a EN
  preserva su progreso. Verde: analyze 0 (CI-exact) · test **162/162** (+3 edit_profile_t5: género/cumpleaños
  obligatorios bloquean, completo guarda) · build web OK · golden del sheet revisado (8 swatches + país con
  bandera + asteriscos de obligatorio).
- **Re-encolado:** (a) el buscador de país podría ampliarse a lista mundial completa (hoy ~55 acotada); (b)
  "editar el @handle" desde el chip (T3 diferido, no de T5).

## T4 — NOTIFICACIONES completas + PUSH WEB real + INSTALAR APP + ORO con más usos ✅ LIVE (mig 150/151/152 · 2026-07-12)
Decisiones de Gian (firmes): **CONGELADOR preventivo SE QUEDA + se AÑADE REVIVIR RACHA caro y limitado.**
PASO 0 honesto: `matix_fire` (server) ya tenía escalado+techo+quiet_hours pero **solo se disparaba desde
botones admin**; `push_subscriptions`+`save_push_subscription`+handler push en sw.js YA existían (faltaba
suscripción cliente + VAPID + sender); **las vidas NO se regeneraban** (hearts_updated_at nunca se leía;
vidas locales por lección) → el "timer" pedido exigía CONSTRUIR la regeneración de verdad, no un contador falso.
- **1 · TRIGGERS automáticos** (`matix_auto.dart`; el server aplica techo 1/evento/día + quiet_hours +
  estilo de coach + push_enabled): `goal_met` (al cumplir la meta con una lección) · `goal_unmet`/`
  streak_risk` (≥18 h con meta sin cumplir; racha activa → risk con la escalera existente) · `behind_plan`
  (≥3 días detrás del plan, copy **ligado al MOTIVO del onboarding** — `{motivo}`: "llegas a tiempo para tu
  examen") · `hearts_out` (al quedarte sin vidas). **matix_fire ganó `p_locale`**: plantillas ahora con
  columna `locale` y el banco push COMPLETO en **es/en/pt** (~124 plantillas; +goal_met/hearts_out ×4 estilos
  ×3 idiomas; fix "Tu inglés"→"Tu idioma" multi-curso). Enum +goal_met/hearts_out (mig 150).
- **2 · PUSH WEB real (sin FCM, GRATIS):** claves **VAPID generadas** (P-256 puro Python); pública en el
  cliente (`pwa_bridge.dart`), **privada como secret de Edge Function** (Management API, jamás al repo).
  **Edge Function `matix-push` DESPLEGADA y ACTIVA** (vía Management API): fan-out de notificaciones 'sent'
  sin `pushed_at` (24 h) → web-push a todas las suscripciones del user, marca pushed_at, borra endpoints
  muertos (404/410) — **verificada en vivo** ({ok:true, processed:3}). Cliente: tarjeta **"Activar avisos"
  con permiso EXPLÍCITO** (nunca automático) en el centro de notificaciones → `Notification.requestPermission`
  + `pushManager.subscribe(VAPID)` + `save_push_subscription` (RLS: cada quien la suya, verificado).
  **Lazy-cron:** cada arranque/envío invoca el fan-out (un cliente activo empuja los pendientes de los
  OFFLINE). ⚠️ Honesto: en iPhone el push web SOLO funciona con la PWA **instalada** (iOS 16.4+) — la tarjeta
  lo dice y enlaza a instalar.
- **3 · INSTALAR APP:** `beforeinstallprompt` capturado en index.html (`jz*` bridges) → tarjeta violeta
  "Instalar Jezici" (Chrome/Edge Android+desktop = **prompt nativo**); **iOS/Safari** sin ese evento →
  sheet con instrucciones (Compartir → Añadir a pantalla de inicio); **standalone → no se muestra** nada.
- **4 · TIMER de vidas = REGENERACIÓN REAL construida** (no visible-de-mentira): `get_hearts`/`lose_heart`
  (tick lazy server-side: **1 vida cada 30 min hasta 5**, ancla exacta por intervalos); la lección arranca
  con las vidas del server y reporta pérdidas best-effort (las vidas gatean solo UX; XP/dominio siguen 100%
  server); **countdown en vivo** en SinVidas y en el panel de vidas de la barra (Timer 1s + re-consulta al
  llegar a 0). buy_hearts/use_streak_freeze ahora leen **CONFIG** (`jz_config`: precios/parámetros en una
  sola fuente; defaults idénticos 50/50 → 0 cambio de precio).
- **5 · ORO:** (a) comprar vidas YA existía (50, ahora vía config; integrado con precio real del server en
  sheet+panel); (b) **REVIVIR RACHA** (`revive_streak`): **300 oro** (6× una recarga), **tope 1/30 días**,
  **ventana 7 días** desde la pérdida, mínimo 3 días de racha — la pérdida se registra en
  `streaks.lost_streak/lost_at` al resetear (jz_register_activity; **congelador intacto**, verificado);
  revivida = se SUMA a la racha actual; movimiento auditable `gold_transactions('streak_revive')`. Tarjeta
  oscura "🕯️ Revive tu racha de N días" en StreakScreen (solo si hay rescate disponible; framing excepcional).
- **Verificado cliente REAL (`verify_t4.py`, 21 checks TODO VERDE):** goal_met sent+fila in-app; techo capped;
  hearts_out en INGLÉS usa plantilla en; behind_plan dice "tu examen" (motivo real); suscripción push guardada
  + **RLS ajena=0** + Edge Function procesa; vidas 5→4 con countdown 1800s → **+31 min = regen a 5** → compra
  recarga y cobra 50; revive cobra 300 (450→150) y suma 1+12=13 + tx auditable + **2º intento limit_reached** +
  pérdida vieja **expired** + sin oro insufficient_gold + congelador sigue cobrando 50. Verde: analyze 0
  (CI-exact) · test **159/159** (+t4: formatCountdown + countdown en SinVidas; no_hearts/lesson_flow
  actualizados a la regen real) · build web OK.
- **Re-encolado:** triggers `achievement` (complete_lesson no expone QUÉ logro se desbloqueó) y
  `exam_countdown` (no hay fecha de examen agendada) — necesitan señal server; **evaluación para usuarios
  OFFLINE** (streak_risk de quien no abre la app) — requiere modo 'evaluate' en la Edge Function + cron.
- **⚠️ BLOQUEADO en Gian (opcional, mejora puntualidad):** agendar un cron externo GRATIS (cron-job.org)
  que llame cada 15 min `POST https://wiauinufpbkmjlbqlkxo.supabase.co/functions/v1/matix-push` con header
  `Authorization: Bearer <anon key>` → los push salen puntuales aunque nadie tenga la app abierta. (VAPID,
  secrets y deploy de la función: YA hechos vía API, no requieren nada de Gian.)

## CONVERSAR · T3 — social FÁCIL: @handle + buscar + perfil público + sugerencias ✅ LIVE (mig 149 · 2026-07-12)
Sobre P1 (mig 146) + Ola 1 (mig 147/148). Decisiones de Gian: **social 18+ · @handle OBLIGATORIO para usar
lo social · nombre visible LIBRE (el certificado NO se toca).** PASO 0 (BD real): `users` SIN columna handle;
RLS `users_select_own` = auth.uid()=id (**aislamiento airtight** → search DEBE ser DEFINER); `jz_social_access`
= solo adulto 18+; connections par canónico; helpers `jz_blocked_between`/`jz_is_sanctioned`/`jz_rate_guard`.
- **@HANDLE ÚNICO:** `users.handle` + índice UNIQUE **case-insensitive** (`lower(handle)`), `handle_set_at`,
  `discoverable` (default true). `jz_valid_handle` (3–20 de a-z0-9_, con ≥1 letra). **`claim_handle`** (adulto;
  normaliza/`@`-strip; colisión→`handle_taken`; formato→`invalid_handle`; reservados→`handle_reserved`; cambio
  **rate-limited 1/30d**→`handle_change_rate`; re-poner el mismo = no-op). El **nombre visible sigue LIBRE e
  independiente** (dos usuarios "Sam" coexisten; el handle no). `get_social_status` extendido: `handle`,
  `needs_handle` (access ∧ handle==null), `discoverable`.
- **BUSCAR (`search_users`):** por nombre o @handle; **SOLO campos públicos**; excluye en la propia lógica
  a quien te bloqueó/bloqueaste (ambas dir), menores (18+), no-descubribles (privacidad "aparecer en búsqueda"),
  sancionados; **rate 30/min** (`social_search_log`, RLS dueño, revocado a REST); comodines LIKE escapados;
  devuelve `relationship` (none/pending_out/pending_in/friends) para el CTA correcto.
- **PERFIL PÚBLICO (`get_public_profile`) — superficie RLS nueva y DELIBERADA:** expone SOLO display_name,
  @handle, avatar, país, año de alta, racha, logros, niveles de idioma (máx CEFR por curso) + relación +
  `connection_id` (para aceptar/chatear). **NUNCA email/birth_year/edad/bio/progreso**. Bloqueado o
  no-descubrible-sin-vínculo → `not found` (no revela existencia).
- **SUGERENCIAS (`suggest_friends`):** señal INOCUA = **mismo curso activo + nivel cercano** (NO ubicación/
  datos sensibles); excluye amigos, pendientes, bloqueados (ambas dir), menores, no-descubribles, sancionados;
  sin curso → `[]` (honesto).
- **`request_friend(user_id)`** + `send_friend_request(code)` refactorizados sobre un helper único
  `jz_do_friend_request` (adulto-adulto, no-self, no-bloqueo, rate 50/día, auto-acepta si el otro ya pidió).
  `set_discoverable(on)`. Todo por RPC SECURITY DEFINER; helpers internos revocados; **NADA using(true)**.
- **CLIENTE (`friends.dart`):** GATE de @usuario (pantalla dedicada con Jezi, no se puede saltar) al entrar
  a Amigos sin handle; **buscador** prominente con resultados en vivo (debounce) + CTA agregar/pendiente/amigos;
  **carrusel de sugerencias**; **PublicProfileScreen** (banner + niveles + logros + racha + CTA por relación +
  reportar/bloquear); toggle de privacidad "Aparecer en búsqueda"; chip "Tu @usuario"; el **código sigue** como
  opción secundaria. i18n es/en/pt (+40 claves), responsive (RC 480/560), reduce-motion. Agregar amigo mucho
  más fácil que solo-por-código.
- **Verificado cliente REAL (`verify_conversar_t3.py`, JWT) TODO VERDE (~45 checks):** handle único (colisión
  case-insensitive rechazada; nombre SÍ repite; inválido/reservado/rate rechazados; needs_handle gate); búsqueda
  por nombre/@handle **sin email**, MENOR no aparece ni busca; perfil público **NO expone email/birth_year/
  age_tier/bio/birthday** (probado explícito), MENOR→not found; `request_friend` pending→pending_in/out→friends;
  **BLOQUEO corta búsqueda + perfil en AMBAS direcciones**; privacidad off → no aparece ni perfil (pero amigo sí
  lo ve); sugerencias mismo curso, excluyen pendientes/bloqueados/menores; **aislamiento airtight intacto** (A no
  ve users de B por REST; `social_search_log` 403 por REST). Verde: analyze 0 (CI-exact) · test **157/157**
  (+3 social_discovery: gate, buscador, perfil sin campos privados) · build web OK.

## MAPA · PERF 2ª pasada (VENTANA de widgets) + NUBES fog-of-war + botón de salto ✅ (2026-07-12 · solo cliente)
Gian seguía sintiendo lag pese al −93% de painters (culling+RepaintBoundary). **Se MIDIÓ antes de tocar**
(benchmark headless, curso 30 unidades ≈ 27.000px): la causa restante NO eran los painters sino la
**explosión de WIDGETS/CAPAS** — el Stack construía TODOS los `Positioned` del curso entero: **180 nodos
(150 círculos + 30 portales) + 30 banners + 185 RepaintBoundary** (cada uno = capa REAL del compositor) =
**6.451 elementos vivos** → layout+composición **19,50 ms/frame** en scroll (el culling de painters no
ayuda si el árbol entero existe igual).
- **F1 · VENTANA de widgets (windowing):** solo se CONSTRUYEN los nodos/banners de la banda visible
  (scroll ± 700px de margen); listener de scroll recalcula los índices de ventana y hace `setState` SOLO
  cuando cambian (el margen hace de histéresis → setState esporádico, no por frame). Geometría idéntica
  (mismas y_i), lógica de progresión intacta (los estados se calculan igual; lo no construido simplemente
  no se pinta). **Medido (mismo benchmark): 19,50 → 5,14 ms/frame (−74%); nodos 180→8; RepaintBoundaries
  185→15; elementos 6.451→761.** Acumulado de las 2 pasadas: painters −93% Y árbol −88%.
- **F2 · NUBES de progreso (fog-of-war, decisión de Gian):** `CloudCoverPainter` (nuevo, scroll-culled
  como los demás) cubre desde encima de la **frontera** (nodo no-locked más alto **+ 2 nodos teaser**
  grises que asoman) hasta bajo la cima (el certificado queda visible como meta). Manto blanco-lavanda
  casi opaco + óvalos interiores deterministas + **borde inferior de pompones** + disolución suave en
  ambos bordes. **Doble beneficio real:** intriga (se despeja al desbloquear, `TweenAnimationBuilder`
  950ms easeInOutCubic sobre el borde; reduce-motion → sin animación) y RENDIMIENTO (lo tapado **ni se
  construye**: nodos con `i > visMax` se saltan y `TrailPainter` ganó `topCutY` → el sendero bajo nubes
  ni se traza). Verificado visual con golden temporal: borde de pompones fundiéndose al mapa, sendero
  cortado bajo las nubes, teasers grises asomando. No rompe el culling previo (se combinan).
- **F3 · Botón de SALTO "Ir a mi lección":** pill flotante blanca (labio suave, flecha ↑/↓ según
  dirección) abajo-derecha (bottom 108 → no tapa el nav), envuelta en `IgnorePointer`+`AnimatedOpacity`
  → **solo aparece lejos** del nodo actual (|offset − target| > 1,2 viewports). Tap → `animateTo` 650ms
  easeInOutCubic al `_targetScroll()` existente (reduce-motion → `jumpTo`). i18n es/en/pt
  (`mapJumpToCurrent`). El "acceso rápido para repasar unidades pasadas" NO se metió (no había diseño
  limpio sin ensuciar el mapa) → encolado en ## Cola.
- **NO se tocó lógica** de desbloqueo/gating/progresión (capa build/paint/scroll). Nota: el mission pedía
  leer/marcar "JEZICI_Checklist_Maestro (T2)" — ese archivo NO existe en el repo (verificado con ls/grep);
  T2 queda registrado aquí. Verde: analyze 0 (CI-exact) · test **154/154** (+3 `map_window_test`: ventana
  construye <25 nodos de 150, nubes presentes con progreso bajo y ausentes con curso dominado, botón
  aparece lejos y el tap vuelve al nodo actual) · build web OK.

## CONVERSAR · tarjetas de SITUACIÓN = catálogo a color ✅ (2026-07-11 · solo cliente)
Feedback: las 6 situaciones de práctica en solitario ("Pedir un café", "Presentarte"…) se veían como
**filas blancas planas idénticas** (icon-tile + título + subtítulo + chevron gris) — leen como lista
genérica frente a Amigos/Chat ya rediseñado. **NO hay mockup directo** (Conversar.dc es hub social en vivo),
así que apliqué el lenguaje de la casa. **Cero IA, cero cambios de lógica** (práctica/contenido por curso/
TTS/banner "en vivo próximamente" intactos):
- **Encabezado con estilo:** barra de acento + kicker "PRÁCTICA EN SOLITARIO" + título + subtítulo.
- **Catálogo en GRID responsive** (`_ScenarioTile`, `LayoutBuilder`+`Wrap`: **2 columnas móvil / 3 desktop**)
  en vez de 6 filas iguales — cada tile con: **fondo tintado suave** por situación (el `_topicTint` que ya
  existía), **badge de emoji en GRADIENTE** del color del tema (46px r14 + sombra de color), **flecha en chip
  blanco**, título, escenario (2 líneas), y **CTA "Practicar" con el acento del tema** (icono `graphic_eq`).
  **Profundidad de labio TINTADA** con el acento (no gris plano) + **motion de presión** (se hunde 3px,
  reduce-motion-aware). Resulta un catálogo vivo y distinto por tema, no una lista básica.
- **Pantalla de práctica** de cada situación: el escenario pasó de caja lila plana a **tarjeta tintada con el
  color del tema** (gradiente suave) + **emoji en badge de gradiente 52px** + kicker "TU SITUACIÓN" → coherente
  con el catálogo. El resto (toggle escribir/hablar, mic honesto, respuesta modelo, autoevaluación, PrimaryButton
  3D) ya estaba en el lenguaje de la casa; intacto.
- i18n es/en/pt (+3 claves: convPracticeKicker/convPracticeCta/convYourSituation; pt/en sin español).
  Responsive (grid recol­umna) + reduce-motion-aware. Verificado con **goldens temporales** (lista = catálogo a
  color; práctica = escenario tintado; borrados). Verde: analyze 0 (CI-exact) · test 149/149 · build web OK.

## SPEAKING a fondo — la CAPTURA cortaba en la 1ª pausa (fix real) + UX ✅ (2026-07-12 · solo cliente)
El audio "no procesaba" y persistía tras el fix robusto anterior (4b27d36 = permiso/errores tipados).
**DIAGNÓSTICO con evidencia (no adivinar):**
- **El GRADING NO era el bug.** Porté `speechMatchRatio`/`speechPasses` (text_match.dart) a Python y probé
  lecturas CORRECTAS reales (contracciones "I'm"→"I am", nombres "Ana"→"Anna", acentos pt/it/de, "è"→"e"):
  **todas PASAN** (word-overlap ∨ char-ratio, umbral 0.6). Hablar MAL sí reprueba. → grading robusto.
- **La CAUSA REAL era la CAPTURA** (`speech_recognizer_web.dart`): (1) **`continuous = false`** → el
  reconocedor FINALIZABA en la PRIMERA pausa; los ítems `speaking_read_aloud` son **frases completas largas**
  ("Quando tivermos todos os dados e virmos os resultados, tomaremos uma decisão.") → una pausa natural a media
  frase cortaba la sesión y solo se calificaba el primer fragmento → "no procesa". (2) En **Android** `onend`
  a veces llega **sin ningún resultado `final`** → `_finalTranscript` vacío → se emitía `('', true)` → score 0
  → falso "no te escuché" aunque SÍ habló (los parciales interim se descartaban). El idioma del reconocedor
  (`SpeechLang.stt`) SÍ estaba bien cableado (home_shell + placement) → no era eso.
- **FIX (captura):** `continuous = TRUE` (acumula todas las cláusulas; termina en el silencio REAL, al tocar
  Detener, o al tope de 15s) + **rescate del último parcial** en `_handleEnd` (si terminó sin `final`, usa
  `_lastInterim` en vez de '').
- **REDISEÑO UX (pedido de Gian):** (1) **transcripción EN VIVO** — lo que se entiende aparece en pantalla
  mientras habla (`LiveTranscript`); en Android muestra lo que haya. (2) **TAP la frase para OÍRLA** con TTS del
  curso (`SpeakablePhrase` → `WordTts.speak`/`SpeechLang.tts`); fuera el botón separado "oír el modelo" y el
  "Ya lo leí" del flujo NORMAL. (3) El **micrófono ALTERNA** (tocar para empezar / tocar **Detener** para
  finalizar) — necesario con continuous=true. (4) **FALLBACK HONESTO conservado:** si el mic no está
  (unsupported/denied/no-mic), sigue la salida clara con la causa real + "Ya lo leí" (lección) / "Saltar los
  ejercicios de hablar" (placement) / modo Escribir (Conversar). Widgets compartidos `speaking_widgets.dart`
  aplicados coherentes en **lección + placement + Conversar**. i18n es/en/pt (+speakingStop/speakingTapToHear).
  Reduce-motion-aware. NO se tocó la exclusión de speaking del placement ni el TTS origen/meta.
- Verde: analyze 0 (CI-exact) · test **151/151** (+speaking_capture: grading aprueba lecturas correctas + el
  rescate del parcial da "¡Bien!" no "no te escuché"; mic_robustness/placement_flow actualizados) · build web OK.

## P1 DE CÓDIGO del LAUNCH_AUDIT cerrados (pre-lanzamiento) ✅ (2026-07-11 · solo cliente)
Los 4 arreglos de código del LAUNCH_AUDIT.md antes de abrir al público. Cero IA, cero cambios de
seguridad/RLS/placement/economía.
- **AGE GATE unificado (P1):** el onboarding pedía nombre + checkbox "soy mayor de edad" pero **nunca el
  AÑO** → `birthYear==null` → `CompleteProfileScreen` reaparecía tras "Empezar mi viaje" (doble pregunta).
  Ahora el paso de nombre pide el **AÑO de nacimiento** (dropdown, reusa `ageGateYearHint`/`ageGateSubtitle`)
  y `_continueName`+`_finish` llaman `submit_age_gate(año)` (idempotente) → el servidor recomputa is_adult
  REAL → **CompleteProfileScreen ya no aparece** para altas nuevas. Verificado cliente real: `submit_age_gate(1990)`
  → birth_year=1990, age_tier=adult; menor(2014) → age_tier≠adult (age gate intacto).
- **DEV-TOOL oculto (P1):** el banco "Probar a Jezi" (`MatixTestButtons`) se mostraba a TODOS (tab
  Notificaciones + Ajustes→Avanzado). Ahora gateado por `isAdminProvider` (como "Ver métricas") → el público
  no lo ve; `am_i_admin=false` para usuario normal.
- **CONSENTIMIENTO legal siempre registrado (P1):** con confirm-email ON el alta no tenía sesión y
  `auth_screen` retornaba antes de `accept_legal` → se perdía. Ahora `_finish` del onboarding llama
  `acceptLegal(kLegalVersion)` SIEMPRE (con sesión activa). Verificado cliente real: `accept_legal` → 204 +
  fila en `legal_consents`.
- **COPY del certificado (P2):** el botón "COMPARTIR" (icono share) solo copiaba → ahora **"COPIAR DATOS"**
  con icono `copy`; `certVerifyNote` suavizado ("Guarda tu folio y código de verificación" — sin prometer
  URL de verificación pública inexistente). i18n es/en/pt.
- Verde: analyze 0 (CI-exact) · test 149/149 (onboarding_target actualizado al dropdown de año) · build web OK.

## RESPONSIVE en TODAS las pantallas (pre-lanzamiento público) ✅ (2026-07-11 · solo cliente)
Gian va a lanzar público (dominio propio + LinkedIn) → entra gente de móvil/tablet/desktop ancho.
**PASO 0 (auditoría real con 4 agentes en paralelo, mirando el código):** ~17 pantallas se **estiraban
de borde a borde** en desktop (no usaban `ResponsiveCenter`); las buenas ya lo usaban. **Un solo patrón**
en toda la app: `ResponsiveCenter` (Align topCenter + ConstrainedBox maxWidth) — en móvil (ancho ≤ maxWidth)
**no hace nada** (layout móvil pixel-idéntico), en anchos grandes **centra y limita**. **Cero cambios de
lógica.** Anchos por tipo: **480** formulario/celebración · **520** certificado · **560** listas/hubs/
players · **640** lectura/contenido ancho.
- **Envueltas (antes se estiraban):** misión, lección(preview/fin/repaso), conversar(hub + práctica de
  situación), checkpoint(intro/resultado), examen(intro/player), certificado, notificaciones, cuaderno,
  referencia, mi plan, story reader, premium, simulacros, racha, métricas, sheet SinVidas. Los **headers de
  gradiente full-bleed** (lección fin, checkpoint, conversar) **se conservan a ancho completo**; solo el
  contenido bajo ellos se centra (patrón: `ResponsiveCenter` con `padding`). El **mapa** sigue full-bleed
  con la columna de nodos centrada (verificado intacto).
- **Overflow móvil (390px) arreglado:** lección-preview (Row de chips → **Wrap**) y métricas (`_row` sin
  `Expanded` → **Expanded**). El resto ya usaba Expanded/Wrap/Flexible.
- **Teclado móvil:** todos los TextField viven en scrollables → no se tapan (chat, respuesta de práctica,
  login, cloze de historia, agregar amigo).
- **Verificado:** analyze 0 (CI-exact) · test 149/149 · build web OK · **golden desktop 1400px** (Conversar
  hub = header full-bleed + contenido centrado ~560 grid 2col; práctica centrada) revisado y borrado.
  Matriz completa pantalla×ancho en **RESPONSIVE_AUDIT.md**.

## REDISEÑO UI de CONVERSAR + AMIGOS/CHAT/CO-OP ✅ (2026-07-11 · solo cliente)
Feedback real de testers: "está raro y feo" — rompía la estética. **Causa concreta (PASO 0):** la sección
social usaba **Material por defecto** (ListTile, FilledButton, AppBar plano, cajas blancas con borde gris
2px) sin el lenguaje de la casa; y el hub apilaba DOS bloques violeta idénticos (Amigos + banner) arriba.
Rehecho `friends.dart` (capa VISUAL + UX; **cero cambios de lógica social/RLS/moderación**):
- **Lenguaje de la casa en todo:** `_LipCard` (labio duro `0 5px 0 #ECEDF6` + sombra suave + hundido 3px al
  tocar), avatares **cuadrado-redondeados con gradiente** (54px r18 del mockup), chips, CTA 3D, Nunito, Jezi.
- **HUB:** entrada de Amigos con **pila de avatares REALES** (hasta 3) + badge rojo de solicitudes pendientes;
  **tarjeta CO-OP del mockup 1:1** (gradiente #EDEBFF→#F3F0FF, "Tú"+pareja solapados con corazón dorado) —
  el "reto en pareja" del mockup ya es funcionalidad REAL (mig 148). Jerarquía: primero lo accionable; el
  banner "en vivo · próximamente" (Ola 3) se movió AL FINAL.
- **AMIGOS fácil:** **código HERO** (gradiente violeta + Jezi + código en pill + botón copiar que **muta a ✓
  verde** 1.8s), agregar por código en una fila obvia (icono persona+, submit con Enter), solicitudes con
  **acciones circulares ✓/✕ con labio**, lista con racha 🔥 pulsante en chip naranja + "Toca para chatear",
  vacío con Jezi + CTA "Copiar mi código", error con reintentar.
- **CHAT moderno:** app bar con avatar+nombre+racha, **burbujas con cola y hora** (mía = gradiente violeta),
  **corrección INLINE** (tarjeta verde con lápiz dentro de la burbuja — ANTES las correcciones NO se veían en
  el chat: el stream Realtime es solo `messages`; ahora se fusiona con `list_messages` al abrir/corregir/llegar
  mensajes), **nota de voz con waveform** determinista que respira al sonar, **composer pill** con 🎤↔➤
  animado (AnimatedSwitcher) y barra de grabación con punto rojo pulsante + contador de segundos, entrada de
  mensajes con fade+slide sutil. Reportar/bloquear en menú ⋮ con iconos.
- **CO-OP:** tarjetas con pareja+corazón, barra de progreso **animada** al valor real, banner dorado
  **JzSheen + 🎉 +N 🪙** al completar; sheets de crear (amigo → meta XP) con estilo de la casa.
- Reduce-motion-aware TODO; i18n es/en/pt (+5 claves: convTapToChat/convCopyMyCode/convCorrectionLabel/
  convCoopYou + copy de grabación); responsive (ResponsiveCenter 560/640). Verificado con **goldens temporales**
  (hub/amigos/co-op/chat renderizan el lenguaje correcto; borrados). Verde: analyze 0 (CI-exact) · test
  **149/149** (+3 friends_ui: hero+vacío con Jezi, racha 🔥, pt sin español) · build web OK.

## CONVERSAR · OLA 1 COMPLETA + ABIERTA AL PÚBLICO ✅ LIVE (mig 148 · 2026-07-11)
Gian: **el abogado APROBÓ los términos UGC/social** → se ABRE lo asíncrono. Decisiones: **18+ solo ·
sin tutores · SIN IA · solo Supabase.** Sobre los cimientos P1 (mig 146) + Ola 1 cerrada (mig 147):
- **(B) APERTURA:** `jz_social_access(uid)` pasó de `adulto AND (admin OR social_beta)` a **SOLO
  `jz_is_adult_user(uid)`** → **todo adulto verificado (18+) accede a Conversar social**; los menores
  siguen EXCLUIDOS (age gate innegociable). `social_beta` queda como tabla inerte (ya no gatea).
- **(A6) CO-OP (retos en pareja):** `create_coop`/`respond_coop`/`list_coops` sobre `coop_challenges`.
  **Progreso DERIVADO de `daily_goals` de AMBOS** (anti-trampa: nadie "avanza" a mano; se suma el XP real
  de los dos desde la aceptación) → al llegar a la meta, `list_coops` hace **settle LAZY** e insertaba oro a
  los dos **UNA sola vez** (el `update ... where status='active'` es el candado → idempotente). Solo entre
  amigos aceptados no bloqueados; rate-limit 10 creados/día; vence a 7 días.
- **(A3) NOTAS DE VOZ:** bucket **privado `voice-notes`** (2MB, mime audio) con **RLS de Storage**: subir/leer
  solo miembros de la conexión (carpeta = `<connection_id>/...`), el bloqueo corta ambas direcciones; SIN
  update/delete de usuario (**retención** para investigar reportes). `send_voice_message(conn, path)` valida
  membresía+aceptada+no-bloqueo+path-de-la-conexión+archivo-existe+rate-limit → mensaje `kind='voice'`.
  **Cliente web:** grabador `voice_recorder_web.dart` (MediaRecorder + getUserMedia, mismo permiso robusto que
  el reconocedor; io stub 'unsupported') → sube al Storage → reproduce con **URL firmada** (bucket privado).
- **(F5/F7 postales/apuesta) RE-ENCOLADAS** (## Cola): incrementos sobre A3/economía; no se enviaron a medias.
- **(C) UI dinámica:** hub `friends.dart` reescrito — tarjetas con **gradiente violeta + icon-tile**, entrada a
  co-op, **racha con 🔥 pulsante**, chat con **notas de voz** (mic↔enviar en el composer, punto de grabación
  animado, burbuja de voz que firma+reproduce), **corrección** long-press, **reportar/bloquear** en el menú,
  estados vacío/carga/error con guacamayo, **co-op** con barra de progreso + celebración al completar. Todo
  **reduce-motion-aware**, responsive, i18n **es/en/pt** (40+ claves nuevas convVoice*/convCoop*). El banner
  "en vivo · próximamente" se conserva SOLO para el audio en vivo/salas (**Ola 3**); lo asíncrono ya es live.
- **Verificado cliente REAL (`verify_conversar_ola1.py`, JWT) TODO VERDE (34 checks):** apertura (adulto sin
  allowlist → acceso; menor excluido siempre), amigos por código, no-amigos no chatean, filtro de contacto
  (tel/email/URL/@→⟨•⟩), corrección, racha, rate-limit, **bloqueo corta RLS ambas direcciones**, insert directo
  denegado (403); **co-op** crear→aceptar→completa(progreso derivado 160≥100)→premia oro→**no paga doble**;
  **notas de voz** miembro sube a su carpeta / **intruso RLS-denegado (400)** / mensaje kind=voice / path fuera
  de conexión rechazado / la pareja lo ve. Verde: analyze 0 (CI-exact) · test 146/146 · build web OK.


## CONVERSAR OLA 1 — social ASÍNCRONO CERRADO (amigos + chat) 🔶 LIVE-CERRADO (mig 147 · 2026-07-11)
Primera ola social sobre los cimientos P1 (mig 146). Decisiones de Gian: **18+ solo · sin tutores · sin
IA · solo Supabase**. **CERRADO al público** por allowlist `social_beta` + `jz_social_access` (adulto Y
(admin O beta)) → un usuario público NO ve ni accede a nada; la UI solo muestra "Amigos" si hay acceso.
- **A1 · Amigos por CÓDIGO** — `users.friend_code` (7 chars sin ambigüedad) por `get_social_status`;
  `send_friend_request(code)` (no buscador de desconocidos, no-self, no-bloqueado, rate ≤50/día, auto-
  acepta si es mutuo) / `respond_friend_request(accept)` / `list_friends`. `connections` +requested_by
  +accepted_at, par canónico único.
- **A2 · Chat texto 1:1** — `messages` + `send_message` (rate ≤30/min, **filtro de contacto**
  `jz_strip_contact`: teléfono/email/URL/@ → `⟨•⟩` al GUARDAR, para que no saquen la charla de la
  plataforma) + `list_messages`; **Realtime** (`messages` en la publicación; la RLS aplica al canal).
- **A4 · Corrección entre amigos** — `corrections` + `add_correction` (corriges el mensaje del OTRO, no
  el tuyo); aparece inline en el chat.
- **A5 · Racha con amigos** — `jz_friend_streak` derivada de `daily_goals` (días consecutivos en que AMBOS
  cumplieron su meta), en `list_friends`.
- **report/block en el chat** (reusa P1). **RLS estricta:** messages/corrections solo miembros ACEPTADOS y
  **no bloqueados** (el bloqueo corta en ambas direcciones); escritura solo por RPC (grants revocados).
- **Cliente:** sección "Amigos" en Conversar (gate por `socialStatusProvider.access`), `FriendsScreen`
  (tu código + agregar + solicitudes + lista con racha 🔥) y `ChatScreen` (burbujas Realtime + enviar +
  reportar/bloquear + long-press→corregir). i18n es/en/pt (21 claves). Lenguaje del sistema (tokens, Jezi).
- **Verificado cliente REAL (`verify_conversar_ola1.py`, JWT) TODO VERDE:** gate cerrado (adulto sin beta →
  sin acceso), **no-adulto excluido aunque esté en beta**, amigos por código (solicitar→aceptar), no-amigos
  no chatean, **filtro de contacto actúa** (`⟨•⟩`), rate limit, corrección, racha ≥1, **BLOQUEO corta el
  chat en la RLS** (send + list + SELECT directo + desaparece de amigos), INSERT directo a messages 403.
  Verde: analyze 0 (CI-exact) · test 146/146 · build web OK.
- **Re-encolado (## Cola):** A3 notas de voz (recorder web + Storage RLS + retención), A6 co-op (crear/
  aceptar/avanzar sobre `coop_challenges`), F5 postales de voz, F7 apuesta con amigo.
- ⚠️ **BLOQUEO de Gian (legal, no código):** la APERTURA al público sigue **bloqueada hasta TÉRMINOS/
  PRIVACIDAD revisados por abogado** (UGC/social/menores). Hoy solo `social_beta` (verificación privada).

## CONVERSAR P1 — CIMIENTOS DE SEGURIDAD (age gate 18+ + moderación) ✅ LIVE (mig 146 · 2026-07-11)
Prerrequisito de TODA ola social (ver CONVERSAR_FASE2.md). **NO abre ninguna función social**; solo la
compuerta. Decisiones de Gian: **18+ SOLO para lo social · sin tutores · sin IA · solo Supabase**.
PASO 0 (BD real): las 8 tablas sociales eran stubs vacíos (RLS ON, solo SELECT, sin RPCs de escritura) +
grants de write a authenticated/anon (RLS los negaba, pero feos); edad = solo `is_adult` checkbox + día/mes
sin año.
- **AGE GATE 18+ REAL:** `users.birth_year` (minimización: solo el año) + `jz_age_tier` (child/teen/adult
  desde año+mes/día, conservador) + **`jz_is_adult_user` fail-closed** (sin fecha → no adulto). RPCs
  `submit_age_gate`/`get_age_status`; `get_profile` expone `birth_year`+`age_tier`. **Pantalla NEUTRAL**
  (pide el AÑO, no "¿eres adulto?") + red de seguridad en `CompleteProfileScreen` (se pide UNA vez a los
  existentes; el gate del arranque pasó a `birthYear==null`). **Un MENOR sigue usando la app** (18+ es solo
  social, aún no abierto). i18n es/en/pt.
- **MODERACIÓN base (server-side, sin IA):** tablas `blocks`/`mutes`/`moderation_actions` + `reports`
  completado (context_type/context_id/status/resolution/handled_by). RPCs de usuario `block_user`/
  `unblock`/`mute`/`unmute`/`report_user` (auth.uid, no-self, **rate-limited** con `jz_rate_guard`,
  no-sancionado). Helper **`jz_blocked_between`** (bloqueo en CUALQUIER dirección) + `jz_is_sanctioned`.
- **COLA DE MODERACIÓN admin** (patrón `get_feedback`, `am_i_admin`): `get_reports` (con contexto/estado),
  `mod_apply` (warn/suspend/ban), `resolve_report`.
- **RLS ESTRICTA:** `blocks`/`mutes`/`moderation_actions` RLS ON + SELECT dueño/admin; `reports` +policy
  admin; **`social_profiles` gateada 18+ Y sin bloqueo** (`jz_is_adult_user` + `jz_blocked_between` en la
  política → punto REAL donde edad y bloqueo cortan el acceso). **Revocados los write-grants directos** de
  las 10 tablas sociales (escritura solo por RPC SECURITY DEFINER). Helpers internos revocados; los 2
  usados en RLS (adult/blocked) quedan ejecutables (o rompería la política).
- **Verificado cliente REAL (`verify_conversar_p1.py`, JWT) TODO VERDE:** adulto→is_adult, menor→teen,
  año inválido rechazado; block/mute/report + rate limit + no-self; **bloqueo corta la RLS de
  social_profiles en AMBAS direcciones**; MENOR no ve social_profiles (gate en RLS); no-admin→`get_reports`
  "admin only", admin ve reportes, `mod_apply` sanciona, sancionado no reporta; **INSERT directo a
  blocks/social_profiles DENEGADO (403)**. Verde: analyze 0 (CI-exact) · test 146/146 (+age gate) · build OK.
- ⚠️ **BLOQUEO de Gian (legal, no código):** la **Ola 1** (chat/amigos) NO debe ABRIRSE al público hasta
  tener **TÉRMINOS/PRIVACIDAD revisados por abogado** para UGC/social/menores. P1 es solo la compuerta.

## COMPRENSIÓN más profunda — it A1 (P2 EVAL_AUDIT) ✅ LIVE (mig 145 · 2026-07-10)
Primer frente del P2 "comprensión reading/listening". **PASO 0 (censo preciso):** el vocab-suelto
("¿qué significa/cómo se dice X?") se concentra en **A1** (de 35% · en 33% · **it 29%** · nl 29% · fr A2 26%);
B1+ ya es ~0% (comprensión de frase = norma). Densidad: fr/it/de/nl ≈36R/24L por nivel (6–12× el pick del
checkpoint → aleatoriza bien, pero fino vs en 78–97R). **Profundidad > amplitud → cerré it A1 IMPECABLE:**
- **+30 ítems de comprensión REAL** (18 reading inferencia + 12 listening **diálogo→pregunta**, NO "¿cuál
  oíste?"): mini-contexto/situación → inferencia. Ej. reading: «Marco ha 8 anni. Suo nonno ha 80 anni. ¿Quién
  es mayor?» → *Il nonno*; listening (audio it) «Prende un caffè? No grazie, vorrei un tè.» + pregunta "¿Qué
  quiere tomar?" → *Un tè* (hay que PARSEAR la negación, no repetir lo oído).
- **Autoría NATIVA italiana + revisión adversarial madrelingua** (agente revisor CEFR): 3 fixes reales
  aplicados (2 listening "echo puro" → inferencia de nacionalidad / día siguiente; 1 reading vocab-suelto +
  clave imprecisa "il nonno = padre de padre" → comparación de edad). Re-revisión: **OK impeccabili**.
- **Ítems de POOL** (tags `unidadN`+`comprension`, NO cableados a lecciones) → densifican checkpoints/exámenes
  SIN tocar lecciones ni el denominador de `jz_skill_mastery` (mig 142) → **0 regresión** a usuarios en curso.
  El prompt (pregunta) SÍ se muestra en checkpoint/examen (los players renderizan `item.prompt` sobre el
  ejercicio → verificado en código) → la pregunta de comprensión es visible; sin cambio de cliente.
- **Censo antes→después:** it A1 reading 36→**54**, listening 25→**37**; vocab-suelto MC reading **29%→17%**.
  Audio TTS **12/12** (HEAD 200), **0 colisiones**, 0 duplicados, aislamiento (0 `comprension` en otros cursos).
  Grading por VALOR verificado (correcto→correct, incorrecto→incorrect). **Cadena cert it A1→B2 VERDE**
  (`verify_cert_chain.py it`, pool ampliado sigue certificando + aislamiento políglota). Verde: analyze 0
  (CI-exact) · test 146/146 · build web OK. **Re-encolado (## Cola):** it A2 + fr/de/nl A1-A2 + pt A1 con el
  mismo patrón `gen_it_a1_comprehension.py` + revisor adversarial nativo.

## CERTIFICACIÓN en los 6 CURSOS (A1–B2) — course-agnóstica + aislamiento multicurso ✅ LIVE (mig 144 · 2026-07-10)
El P0 de EVAL_AUDIT.md. **PASO 0 (BD + cliente real) reveló que la certificación YA era course-agnóstica**
(`submit_level_exam`/`jz_level_status`/`jz_resolve_exam_level` todo scopeado a `jz_active_course`, cert con
`course_id`) — **pt certificaba A1 HOY**; el banco `unidad%` cubre A1–B2 en los 6 cursos (≥36R/36W/24L/18S por
nivel, censado). El bloqueo real NO era "faltan exámenes de nivel" sino **aislamiento multicurso**:
- **(A) `certificates UNIQUE (user_id, cefr_level)`** sin `course_id` → un **políglota no podía tener "A1
  inglés" Y "A1 portugués"** (el 2º insert chocaba → sin cert; peor: el lookup devolvía la cert de OTRO curso).
  Fix: constraint **`(user_id, course_id, cefr_level)`** + TODAS las consultas de cert en `submit_level_exam`
  scopeadas por `course_id` + `has_certificate` de `jz_level_status` por curso. (0 duplicados cross-curso hoy
  → migración segura.)
- **(B) id de examen de nivel HARDCODEADO/compartido** (`50000000-…-<lvl>`, una fila por nivel con
  `course_id=en`) → `exam_attempts` de todos los cursos colisionaban. Fix: **fila de examen POR CURSO**
  (lookup-or-create como `start_checkpoint`); **en conserva su fila histórica** (la encuentra) → 0 regresión.
- **Techo honesto:** `jz_resolve_exam_level` sigue capando **B2**. C1/C2 no certifican (requieren evaluación
  de producción libre = Fase 2 IA). Cada curso llega a **B2** (el banco lo respalda en los 6).
- **Sin cambio de cliente:** el flujo de examen/certificado ya es course-agnóstico (lee `get_skill_mastery`/
  `level_exam_status` del curso activo; el certificado ya es course-aware por idioma, mig 133/138).
- **Verificado cliente REAL (`verify_cert_chain.py` en los 6 cursos) TODO VERDE:** cadena **A1→B2** (dominar
  las 4 skills al nivel N → examen → **cert `JZC-<N>-` con `course_id` del curso** → suben las 4 skills); techo
  B2; **FALLO** (sin dominar 1 skill → NO certifica, `get_skill_mastery` muestra qué skill falta); **AISLAMIENTO
  políglota** (mismo usuario certifica A1 en EN y en el otro curso → **ambas certs coexisten**, y las skills de
  EN no se tocan al certificar el otro). **en sin regresión** (`verify_chain` A1→B2 VERDE). Verde: analyze 0
  (CI-exact) · test 146/146 · build web OK.

## CHECKPOINT C1 con banco suficiente + OPCIONES barajadas al servir ✅ LIVE (mig 143 · 2026-07-10)
Dos hallazgos de EVAL_AUDIT.md (§1 P0 + §3 P1). **Cero contenido nuevo, cero IA.**
- **F1 (P0) · Checkpoint C1 aleatoriza de verdad.** PASO 0 (BD real): el checkpoint (`start_checkpoint`)
  filtra el pool por tag `unidadN` y saca 3R/3W/2L/2S al azar; pero en **C1 solo ~1R/1W por unidad** tenían
  el tag (47 de 317 ítems C1 taggeados) → reading/writing servían **SIEMPRE el mismo ítem fijo**. El
  contenido YA existía (alcanzable por lecciones: R12–16 · W17–21 · L9–10 · S7–8 por unidad) — era un hueco
  de **TAGGING**, no de banco. Fix (mig 143): **re-tag por SQL** derivando la unidad de `lesson_items →
  units.order_index` (0 ítems ambiguos, guardado idempotente). Ahora cada unidad C1 expone 4–6× el pick,
  como A1–B2. **Escaneo de los 6 cursos × niveles: solo en C1 estaba flaco** (los otros 180 (curso,unidad)
  ya sanos). Re-tag seguro: el tag `unidadN` solo lo usa `start_checkpoint` y `start_level_exam` (y en C1
  no hay examen de nivel, tope B2); `start_practice`/`create_plan` solo lo mencionan en comentarios,
  `get_lesson_tip` lo EXCLUYE. Verificado cliente real: checkpoint C1 sirve 3R/3W/2L/2S, dos intentos
  difieren, **reading/writing ya varían**.
- **F2 (P1) · Opciones barajadas al SERVIR.** El audit: la selección de ítems aleatoriza, pero el orden de
  las **opciones** salía fijo de BD (0 cambian) → un repetidor memoriza posiciones. **Grading confirmado por
  VALOR** (`jz_grade`/`grade_item` comparan `jz_normalize(answer)=jz_normalize(correct->>'value')`, no por
  índice) → barajar el orden mostrado NO rompe la corrección. Fix en 2 capas coherentes: **server-side**
  `jz_shuffle_options(payload)` (VOLATILE, `order by random()` sobre `payload.options`) en `start_checkpoint`
  + `start_level_exam` (real-client verificable, resiste inspección de API); **cliente** `multiple_choice_exercise`
  baraja una vez por ítem al montar → cubre la superficie de LECCIÓN (select directo, sin RPC) y listening
  (reusa ese widget). Solo toca `options` (MC/listening/true_false); word_bank/reorder/match/cloze intactos.
  Verificado cliente real: mismo ítem MC servido 2× → **opciones en orden distinto (mismo conjunto)**, y
  grading por valor correcto (valor correcto→correcto, incorrecto→incorrecto). +3 widget tests (permutación,
  no-fijo, tap envía el valor).
- **No rota nada:** cadena de certificación A1→B2 (con `start_level_exam` barajado) VERDE, certs A1/A2/B1/B2
  emitidos; aislamiento multicurso intacto (re-tag es en-C1 only). Verde: analyze 0 (CI-exact) · test 146/146
  (+3 shuffle) · build web OK.

## NIVEL MOSTRADO == NIVEL CERTIFICABLE — fin de la inflación por grind ✅ LIVE (mig 141/142 · 2026-07-10)
El P0 estructural de EVAL_AUDIT.md. **Antes (divergencia real, reproducida):** el `cefr_level` del radar
subía por GRIND — `complete_lesson`/`submit_checkpoint` sumaban **puntos** (12/acierto, 4/stub; 100 = +1
CEFR) SIN mirar el nivel del contenido → grindeando ítems A1 fáciles el radar llegaba a B1/B2 **sin ver ese
contenido**, mientras el certificado usa `jz_skill_mastery` (cobertura×precisión ≥0.80, rigurosa) → radar
decía "Reading B2" y el examen "no calificas". **Además el pipeline de dominio estaba MUERTO:** `jz_record_item`
no se llamaba desde NINGÚN RPC del loop → `user_item_attempts` vacío → `jz_skill_mastery` real ≈ 0 →
certificación de facto imposible.
- **Diseño (una sola verdad):** el `cefr_level` mostrado se fija a
  `greatest(cefr_level, jz_displayed_level(uid,curso,skill))` en complete_lesson/submit_checkpoint;
  **`jz_displayed_level`** (nuevo) = el nivel MÁS ALTO con `jz_skill_mastery ≥ 0.80` (la MISMA barra del
  certificado, piso A1) → **para MOSTRAR B1 hay que DOMINAR ítems B1**. Los `progress_points` (0–100)
  **siguen** para el progreso VISUAL dentro del nivel (la subida por lecciones sigue gratificante); el CEFR
  ahora viene del dominio, no del grind. Nunca BAJA en caliente (greatest).
- **Pipeline revivido (mig 141):** complete_lesson/submit_checkpoint/submit_level_exam ahora `jz_record_item`
  cada ítem calificado (stub → participación) en `user_item_attempts` → `jz_skill_mastery` mide dominio REAL.
- **Cobertura corregida (mig 142):** el denominador de `jz_skill_mastery` = ítems ALCANZABLES por lecciones del
  nivel (join `lesson_items`), NO todo el banco (antes B1 reading=78 pero las lecciones exponían el mismo set →
  dominar TODAS las lecciones capaba <0.80 → certificación imposible). Ahora dominar las lecciones del nivel SÍ
  demuestra el nivel.
- **Migración de existentes:** `cefr_level = greatest(nivel del plan/placement, jz_displayed_level)` + backfill
  de `user_skill_mastery` desde `user_lesson_progress`. El grind inflado BAJA al dominio real; el **placement**
  (test adaptativo = señal de dominio legítima) y los **exámenes/certs** se preservan (nunca se pierde progreso
  ni XP). **108/108 filas coherentes** (disp == greatest(plan,dominio)), 0 incoherentes.
- **Verificado cliente REAL (`verify_level_unification.py`, JWT) TODO VERDE:** (A) grind de A1 (12 lecciones al
  100%) → radar **A1** (no infla; mastery A1 0.80, disp A1); (B) dominar B1 (todas las lecciones) → mastery B1
  **1.0** → radar **B1** == `jz_displayed_level` == exam-ready. **Radar y jz_skill_mastery ya no divergen.**
  Regresiones VERDES: `verify_placement_serious en/pt` · `verify_estimator` 8/8 · `verify_placement_4skills en`
  · **`verify_chain` (cadena A1→B2 + certs A1/A2/B1/B2 emitidos)** — el examen sigue siendo el rigor y certifica.
  El cliente NO cambió (lee `cefr_level` y `jz_skill_mastery` por interfaces intactas). Verde: analyze 0
  (CI-exact) · test 143/143 · build web OK.

## LAG DEL MAPA — viewport culling + RepaintBoundary ✅ (2026-07-10 · solo cliente)
Feedback real (lag en el mapa y al moverse entre niveles, aun en equipos potentes). **Se DIAGNOSTICÓ
antes de tocar** (benchmark headless de `paint()` a la altura de un curso largo: inglés A1→C1 ≈ 180
nodos → contentHeight ≈ **27.000px**).
- **Causa REAL (3 factores, con números):** (1) **sin `RepaintBoundary`**, la mascota (bob continuo) y el
  pulso del nodo disponible **comparten capa** con la escenografía+sendero → marcan sucia la capa GIGANTE
  ~60 veces/s → re-pintan toda la escena de 27.000px **aunque estés quieto** (lag continuo) y en cada frame
  de scroll (la capa gigante se re-reproduce). (2) `TrailPainter` recorría **TODO** el sendero
  (`computeMetrics`+`extractPath`, ~1500 guiones a 27.000px) en cada paint → **3.76 ms/paint** medido, y
  escala con la altura. (3) `TrailPainter.shouldRepaint` comparaba `!=` sobre una lista NUEVA cada build →
  siempre `true`. Total painters: **4.17 ms/paint** de solo grabar draw-ops en CPU de escritorio (en web
  CanvasKit, rasterizar la capa de 27.000px es mucho peor).
- **Fix (capa de RENDIMIENTO, visual IDÉNTICO):** **VIEWPORT CULLING** en `SceneryPainter`/`TrailPainter` —
  toman el `ScrollController` (`repaint: scroll`) y pintan SOLO la banda visible (offset ± 500px de margen):
  `clipRect` a la ventana + saltar escenas/nubes fuera de banda; el sendero construye el path solo con los
  nodos de la ventana (+1 vecino) → guiones acotados. **`RepaintBoundary`** alrededor de nodos/portal/mascota
  → sus animaciones se aíslan en su propia capa y **ya NO invalidan la escenografía**. `shouldRepaint`
  corregido. `isComplex+willChange` como hints al compositor.
- **Medido (benchmark headless, mismo 27.000px):** painters **4.17 ms → 0.28 ms/paint (−93%)**; y con los
  RepaintBoundary esos paints ya **no ocurren por frame de animación** (solo en scroll, y acotados a la
  ventana). El mapa se ve **idéntico** (golden completo con culling-off = diseño actual: sol, montañas
  nevadas, costa, colinas, pinos; culling solo cambia QUÉ se dibuja al hacer scroll, no el diseño).
  Reduce-motion intacto. **NO** se aplicó la idea de "ocultar lo no desbloqueado" (se perdería el viaje).
  Verde: analyze 0 (CI-exact) · test 143/143 (+map_culling: pinta sin excepción a 27.000px + culling −>50%
  del costo del sendero) · build web OK.

## TANDA 1 — 4 fixes de correctitud/seguridad (mig 140 · 2026-07-10)
Feedback real de Gian + auditoría. Cero IA.
- **F1 · P0 SEGURIDAD — métricas admin-only.** "Ver métricas (interno)" en Ajustes se mostraba a TODOS.
  PASO 0 (cliente real): el SERVER ya estaba blindado (mig 058) — `get_metrics/get_engagement/
  get_onboarding_funnel/get_feedback` devuelven **"admin only" (P0001, 400)** a un usuario normal aunque
  llame el RPC a mano (verificado). Era solo UI. Fix: **`am_i_admin()`** (mig 140, RPC público que devuelve
  SOLO un bool sobre `auth.uid()`; wrapper de `jz_is_admin` que está revocado) → `isAdminProvider` → la
  entrada de métricas se **oculta** si no eres admin (fail-closed ante error). La seguridad real sigue
  server-side; esto solo evita mostrar una puerta cerrada. Verificado: usuario normal `am_i_admin=false`.
- **F2 · P0 PRODUCTO — voz TTS por idioma.** Las palabras del idioma meta sonaban con **voz española**
  (pronunciación incorrecta). PASO 0: `word_tts_web.dart` seteaba `utterance.lang` PERO NO `.voice` → con
  voz por defecto es-ES el navegador ignora el `lang` y lee inglés con acento español. Fix: **selección
  explícita de voz** — `getVoices()` cacheado + `onvoiceschanged` (cargan async); elige voz por BCP-47
  exacto → mismo idioma base (prefiriendo `localService`) → si no hay, deja solo `lang` (NUNCA fuerza es
  sobre otro idioma). El TTS de la frase ORIGEN sigue es-ES (correcto por diseño; ahora también elige voz es).
- **F3 · P1 — íconos PWA rebrandeados.** El manifest/favicon/apple-touch/splash seguían con el logo viejo.
  Regenerados los 6 PNG (192/512/maskable-192/512/apple-touch-180/favicon-96) con el **guacamayo** (`ParrotArt`
  → render a PNG sobre violeta de marca; maskable con safe-zone) + `manifest.json`/`index.html` con `?v=5` +
  **SW bump v4→v5** (refresca la caché de iconos/manifest). Descripción del manifest ya no dice "inglés".
- **F4 · P1 — la mascota se llama "Jezi".** "Matix" era nombre interno reusado. Barridos TODOS los strings
  VISIBLES → "Jezi": i18n (`settingsTestMatix`/`settingsCoachInsist`/`tipCardHeader` es/en/pt), label del
  banner push, "Probar a Jezi"/copys del centro de notificaciones, cuaderno. **0 "Matix" visible** (dart +
  valores arb + `notifications.body` server). El código interno (matix_banner.dart/matix_fire/MatixService)
  conserva el nombre.
Verde: analyze 0 (CI-exact) · test 141/141 (+amIAdmin en fakes) · build web OK (confirma el web TTS).

## PLACEMENT 4 HABILIDADES en LOS 6 CURSOS ✅ LIVE (mig 139 · 2026-07-10)
Retome de ## Cola ítem 5 CERRADO: fr/it/de/nl quedan al nivel de en+pt — el examen de ubicación mide
**reading + LISTENING + writing + SPEAKING con perfil por habilidad REAL en los 6 cursos**.
- **Banco L/S (mig 139, SOLO ítems — el RPC v3 de mig 135/136 ya era live y course-agnóstico, NO se
  tocó):** por curso (fr/it/de/nl, A1–B2 como pt): **12 listening** (MC "¿qué oíste?", 3 opciones
  rotadas, guarda anti-colisión) + **8 speaking** (read-aloud `type=translation` sin opciones). Total
  **80 ítems** autorados con calidad NATIVA (criterio: un distractor cambia una PALABRA de contenido
  audible, el otro el TIEMPO/persona; jamás pares mínimos de diacríticos ß/ss·ä/a) + revisión
  adversarial por idioma (fr subjonctif «Bien qu'il soit», de Konjunktiv I «er habe», it congiuntivo
  «Benché sia», nl «werkt ze door»/pluperfecto). **Audio TTS 48/48** en Storage (tl real vía join
  `languages`, text-matched, HEAD 200 48/48).
- **`gen_placement_ls.py` fase 2:** dicts LISTENING/SPEAKING extendidos a los 6 idiomas; `main()` emite
  la mig 139 items-only para `PHASE2` (la mig 135 histórica no se regenera).
- **Auditoría de INTEGRIDAD del banco COMPLETO** (`audit_placement_bank.py`): 0 colisiones norm-exactas,
  0 duplicados, 0 sanidad — y de paso se ARREGLÓ el check 1 del audit, que estaba roto de origen
  (llamaba `jz_near_match(text,text)`; la firma real es `(type, jsonb, jsonb)` → 400 silencioso): ahora
  el chequeo near-match de cloze/translation corre DE VERDAD → 0 distractores perdonables en todo el banco.
- **Verificado REAL (cliente JWT, `verify_placement_4skills.py`, LOS 6 CURSOS) TODO VERDE:** 4 skills
  servidas · largo 12 (∈10–16) · **persona fuerte-R/floja-L → reading>listening 4/4 en CADA curso**
  (B2/B1, 0 invertidas) · azar → 0 skills B2/C1 (8 corridas ×4 skills/curso) · aislamiento (ítems solo
  del curso activo). La aserción de persona se volvió **DETERMINISTA** (lectora perfecta/sorda al audio:
  global B2 + demote de listening es matemática, no suerte — la 0.9-aleatoria era flaky y en un run cayó
  2/4 por fase de rotación, no por el banco). Regresiones: `verify_placement_serious` (en+pt) TODO VERDE ·
  `verify_estimator` 8/8 · analyze 0 (CI-exact) · test 141/141 (cliente sin cambios: ya renderizaba L/S
  course-agnóstico y `SpeechLang` ya mapea fr/it/de/nl).

## BARRIDO DE FIDELIDAD UI — 4 pantallas cerradas (mig 138 · 2026-07-10)
PASO 0 releyó MOCKUP_GAP + código: la mayoría de pantallas YA estaban cerradas (la tabla del gap estaba
desactualizada; el "SinVidas timer" sugerido ya se resolvió honesto el 07-09). Se cerraron las 4 con P1
REALES restantes, impecables y con test (`ui_fidelity_sweep_test`, 3 widgets):
- **Checkpoint INTRO (Checkpoint.dc):** escena nocturna con **estrellas jzTwinkle** (CustomPaint
  determinista; fijas con reduce-motion) + **loro con BURBUJA** (`ParrotMascot` encourage, ya no texto
  plano) + **chips "QUÉ ENTRA" con las lecciones REALES de la unidad** (`mapUnitsProvider`, máx 4 + "+N",
  sin datos se omite) + centro ESCALABLE (FittedBox) y hoja scrollable con tope → no desborda en pantallas
  cortas. **Stats verificadas contra el servidor:** 5 min/80%/10 son las CONSTANTES reales de
  `start_checkpoint` (300s, 0.80, 3R+3W+2L+2S) — no eran datos falsos; leerlas por RPC crearía un intento.
- **CERTIFICADO ceremonial (Examen.dc):** ambiente oscuro `#1C1B2E` + papel crema con **doble marco
  DORADO** + **serif Playfair Display** + **sello "VERIFICADO"** + marca de agua de guacamayo + título
  **course-aware** — **mig 138**: `get_certificates` expone `lang` (dato que YA existía vía
  certificates.course_id→languages; verificado con certs reales) → "Certificado de \<idioma\>" real, no
  "Inglés" fijo. Pantalla 100% i18n (antes hardcodeada es). ⛔ Honesto: sin PDF/LinkedIn/URL pública (no
  existe esa infra — Fase 2); compartir copia folio+código.
- **MATIX banner (CoachTonos.dc):** acento por TONO real — barra izq. 4px + avatar en gradiente del acento
  + **tag con dot** (Firme/Animado/Competitivo/Tranquilo, i18n) con los tokens que ya existían (mano_dura=
  hearts, positivo=primary, rezago=streak, suave=success). ⛔ Honesto: el bloque de progreso ("Racha de 11
  días · 88%") y el CTA por tono requieren datos/acciones que `MatixResult` no transporta → diferidos.
- **PAYWALL (Paywall.dc):** beneficios con **chip de color POR ítem** + **CHECK verde "incluido"**
  (semántica del mockup; fuera el candado) + **copy hero course-aware** ("Lleva tu \<idioma real\> más
  lejos") + **guacamayo coronado** + 100% i18n (antes hardcodeada es). Planes/precios = pagos inactivos
  (beta, decisión, no gap).
Verde: analyze 0 (CI-exact) · test **141/141** (+3 sweep) · build web OK. **Re-encolado** (## Cola): ver
ítem 0 actualizado (Simulacro hub = requiere motor; mini-3D compactos; i18n secundarias restantes; sombras).

## CONVERSAR pulido al lenguaje de Conversar.dc (sin features sociales) ✅ (2026-07-10 · solo cliente)
La pantalla eran **rectángulos planos**; se subió al lenguaje visual del mockup **sin construir el hub social
en vivo** (salas/"320 en línea"/compañeros/crear sala = Fase 2 por diseño, no se toca). Capa visual + un dato
real; NO agrega lógica ni features sociales.
- **Header de COMUNIDAD full-bleed** (`_Header`): gradiente violeta 150° (#7A6BF0→#6C5CE7→#5B4ECF) con esquinas
  inferiores redondeadas + kicker **"COMUNIDAD JEZICI"** + título "Conversar" + subtítulo + **guacamayo SVG**
  (`ParrotArt`) + **pill "Tu Speaking: X — súbelo hablando aquí" con el nivel REAL** (de `skillsProvider`,
  skill speaking; si aún no cargó, la pill se OMITE — honesto, no inventa nivel).
- **Tarjetas de situación RICAS** (`_TopicCard` → StatefulWidget): **icon-tile coloreado distinto por situación**
  (mapa `_topicTint`: café durazno, intro violeta, aeropuerto cian, finde coral, entrevista verde, direcciones
  violeta) + chevron en chip del mismo tinte + doble sombra (labio duro + sombra suave) + **motion de presión**
  (se hunde 3px al tocar, reduce-motion-aware). Ya no 6 rectángulos idénticos.
- **Banner "en vivo · próximamente"** (`_LiveBanner`): estilo del mockup (gradiente + punto verde live + sombra)
  **SIN contador falso de gente en línea**. El texto honesto (Fase 2) se conserva.
- **"Reto de conversación · HOY" NO se construyó** — el mockup promete "gana oro por tu creatividad" y **no
  existe infra de reto ni de recompensa** → fingirlo sería deshonesto (degradación honesta, documentada).
- **i18n intacto** (regla): chrome por idioma de la APP (es/en/pt, +2 claves `convKicker`/`convSpeakingPill`),
  contenido (respuesta modelo/tips) por idioma del CURSO vía `modelFor(lang)`. La pantalla de práctica de cada
  situación (responder + modelo + autoevaluación + mic honesto) intacta. Verde: analyze 0 (CI-exact) · test
  138/138 (Conversar pt sin español ✓, bandera=curso activo ✓) · build web OK.

## FONDO DEL MAPA v3 — "cielo con nubes" (fin real de las franjas) ✅ (2026-07-09 · solo cliente)
Gian seguía viendo el fondo "roto" tras v1/v2. **Causa de RAÍZ (no un set-piece suelto): el mockup es UNA
escena de altura FIJA (368×1860); estirarla sobre mapas de 5.000–23.000px** (`_flatten` = todas las
lecciones) rompe el MEDIO — la vista de cima anclada arriba y las colinas ancladas al pie dejaban **miles de
px de degradado estirado en medio**, que con las transiciones se leía como losas/bandas chocantes. Los fixes
v1 (anclaje absoluto) y v2 (quitar edificios) atacaron síntomas, no la geometría. **Fix v3 (fiel al mockup +
robusto a CUALQUIER altura, guía "mejor limpio que roto"):** `scenery_painter.dart` reescrito a **DOS escenas
ancladas + cielo en el medio**:
- **Vista de cima arriba** (sol + cordillera nevada + costa con velero) = el DESTINO. La **costa se DISUELVE
  hacia abajo con su PROPIO color** (`_dissolveDown`, opaco→transparente) → sin borde duro flotando sobre el cielo.
- **Primer plano verde abajo** (4 colinas de verdes suaves + pinos) = donde ESTÁS, anclado al pie; se encuentra
  con el cielo directamente como en el mockup (contraste bajo, sin borde).
- **El MEDIO es CIELO**: solo el degradado de 8 paradas del mockup + **nubes suaves traslúcidas distribuidas por
  TODA la altura** (`_skyClouds`, densidad ∝ alto, posiciones deterministas). Óvalos translúcidos → **imposible
  que se lean como bandas**; el sendero queda limpio encima.
Estático (sin coste de animación, reduce-motion seguro), full-bleed en X (llena el ancho en desktop; la columna
de nodos se centra aparte con dx0). El globo "EXAMEN · UNIDAD N" sigue en el hueco bajo el portal (c.dy+62, no
tapa el nodo de arriba). **NO toca lógica de nodos/progresión/gating.** Verificado con **golden a 3 alturas**
(corto 390×1200 · alto 390×6000 · desktop 900×6000): paisaje integrado y bonito, cero franjas, costa fundida.
Verde: analyze 0 (CI-exact) · test 138/138 (map_visuals pinta sin excepción) · build web OK.

## PERFIL COMPLETO + 2 BUGS (nombre en registro · dashboard vacío) ✅ LIVE (mig 137 · 2026-07-09)
Principio: **esquema amplio, formulario mínimo** (el registro pide SOLO nombre + mayoría de edad; el resto
es opcional en Perfil). PASO 0 en BD/código encontró las causas reales de ambos bugs.
- **F1 · Esquema (mig 137, todo NULLABLE, 0 impacto):** `users` += `birthday_day`/`birthday_month`
  (**SOLO día/mes, sin año** — minimización de datos, no se puede calcular edad), `is_adult`, `timezone`,
  `gender` (whitelist con `prefer_not_to_say`), `referral_source` (schema listo, sin UI aún). `set_profile`
  extendido a 11 args con defaults (compatible con clientes viejos de 4 args — verificado) + validación
  server-side (día 1-31/mes 1-12/gender whitelist: inválidos se IGNORAN); `get_profile` devuelve todo.
- **F2 · Registro pide lo MÍNIMO (bug a):** el paso de nombre del onboarding YA existía (case 2, mig 132)
  y funciona — la CAUSA real del "no pide nombre" son cuentas que completaron onboarding ANTES de mig 132
  (o PWA cacheada vieja): quedan `needs_name=true` para siempre sin camino que lo pida. Fix en 2 capas:
  (1) el paso de nombre del onboarding ahora incluye **checkbox requerido "Confirmo que soy mayor de edad"**
  (persiste `is_adult=true` con el nombre); (2) **`CompleteProfileScreen` = red de seguridad en main.dart**:
  tras el onboarding, si el perfil quedó sin nombre O sin confirmar mayoría → pantalla única (nombre
  pre-rellenado + checkbox) ANTES del HomeShell. Cubre Google OAuth, email y cuentas viejas. El arranque no
  se bloquea (el perfil carga en paralelo; si llega incompleto se antepone).
- **F3 · Perfil opcional:** hoja "Editar perfil" += **cumpleaños (día/mes, dropdowns con mes localizado,
  deseleccionable)** + **género opcional** (4 chips + deseleccionar) + **timezone silenciosa** (offset del
  dispositivo, best-effort). País/avatar/bio ya existían. Nada obligatorio.
- **F4 · Dashboard vacío (bug b) — CAUSA REAL:** "dashboard" = **Mi Plan** (`get_plan_tracking` course-aware).
  Cambiar de curso con **"empezar desde cero" NUNCA llamaba create_plan** (bug heredado del _switchCourse de
  Ajustes) y abandonar el test a mitad tampoco → curso activo SIN `user_plans` → `ok:false` → "Aún no tienes
  un plan" + mapa sin entrada. **Reproducido server-side** (sin plan → ok:false; con plan → datos reales).
  Fix (`switchCourseFlow` con INVARIANTE "curso activo siempre con plan"): curso destino con plan previo →
  se activa SIN diálogo y sin resetear; "desde cero" → **create_plan A1 real** (meta B1 capada al tope del
  curso, respeta el estilo de coach actual vía fetchSettings); test abandonado → **REVIERTE al curso
  anterior** (nada queda a medias).
- **Verificado REAL (cliente JWT):** email nuevo → needs_name=true → set_profile guarda nombre+adult+
  cumpleaños+país+tz+gender; inválidos (día 40/mes 13/gender basura) ignorados; firma vieja compatible;
  "Google" (alta con `full_name` en metadata) → `users.name` sembrado por el trigger (needs_name=false);
  get_plan_tracking sin plan ok:false / con plan ok:true+datos. i18n es/en/pt (11 claves). Verde: analyze 0
  (CI-exact) · test 138/138 (+complete_profile gate; onboarding exige el checkbox; fakes actualizados) ·
  build web OK.

## MICRÓFONO ROBUSTO Y HONESTO (feedback real: "no capta en PC / cuesta en celular") ✅ (2026-07-09 · solo cliente)
**Causas REALES (confirmadas en código):** (1) los errores del reconocedor se TRAGABAN en las 3 superficies
(lección/placement/Conversar: `onError: (_)`) y encima `_handleEnd` emitía un final `''` → con permiso denegado,
sin mic, Brave (service-not-allowed) o red caída el usuario veía **"No te escuché — sube el volumen"** (mensaje
FALSO) o un mic que "no hace nada"; (2) `init()` web solo comprobaba que existiera el constructor de
SpeechRecognition — NO miraba permiso denegado ni hardware → se ofrecía un mic muerto; (3) el permiso nunca se
pedía explícitamente: `start()` disparaba el prompt del navegador con el reconocimiento YA corriendo → en
Android el 1er intento moría en 'no-speech' mientras el prompt estaba abierto, y si el usuario negó una vez,
TODOS los starts fallaban en silencio para siempre; (4) 8s de tope cortaba frases largas en móvil.
**Fix (`speech_recognizer_web.dart` reescrito + API):**
- **init():** sin soporte → `unavailableReason='unsupported'`; **Permissions API** (sin prompt) detecta permiso
  YA denegado → `'denied'` y no se ofrece el mic (placement lo excluye desde el arranque con `p_exclude_skills`).
- **listen():** **getUserMedia explícito bajo el gesto** (1ª vez) ANTES de arrancar el reconocimiento (pistas
  liberadas al instante) → el prompt se resuelve limpio (arregla el 1er intento en Android) y denied/no-mic se
  detectan con su causa; luego arranca la SpeechRecognition.
- **Errores TIPADOS** (`SpeechErrors`): not-allowed/service-not-allowed→`denied`, audio-capture→`no-mic`,
  `network` (transitorio); con error FATAL **NO se emite el final `''` engañoso**. `listenFor` 8→12s.
- **UI en las 3 superficies** (`mic_messages.dart` compartido): mensaje con la **CAUSA real** — "Tu navegador no
  soporta reconocimiento de voz. Prueba con Chrome o Edge." / "El permiso del micrófono está bloqueado. Actívalo
  en el candado 🔒…" / "No se detectó ningún micrófono" / red→aviso y el mic queda para reintentar. Salidas que NO
  bloquean: lección "Ya lo leí ✓", placement "Saltar los ejercicios de hablar" (exclude, sin puntuar en contra),
  Conversar modo ESCRIBIR. i18n es/en/pt (4 claves). Reconocedor **inyectable** en lección/placement (tests).
**Matriz de soporte** (documentada en FINDINGS): Chrome/Edge desktop+Android ✅ (Edge vía Azure); Safari macOS/iOS
14.5+ ⚠️ parcial (webkit, vía Siri) — si falla degrada con mensaje; **Firefox ❌ sin API** → mensaje "usa Chrome" +
saltar/escribir; Brave ❌ servicio deshabilitado → detectado como `denied` con mensaje. Verde: analyze 0 (CI-exact) ·
test 137/137 (+6: mic_robustness — sin soporte/denegado en init/denegado al hablar/sin mic/red reintentable; placement
excluye speaking con mic muerto) · build web OK. **Prueba manual de Gian:** ver pasos en FINDINGS §Micrófono.

## PLACEMENT de 4 HABILIDADES REALES ✅ LIVE (mig 135/136 · 2026-07-09)
El test de ubicación ahora evalúa **reading + LISTENING + writing + SPEAKING** (antes solo R/W) y devuelve
`skill_levels` **por habilidad REAL** (antes global ×4). Todo el v2 anti-azar (mig 131/134) intacto.
- **Banco L/S (mig 135) para en+pt** (los cursos de verificación): **27 listening** (en 15 A1–C1, pt 12 A1–B2;
  MC "¿qué oíste?" con 3 opciones, guarda anti-colisión norm-exacta, opciones rotadas) + **18 speaking**
  (en 10, pt 8; **read-aloud** = `type=translation` sin opciones — gradable con tolerancia typo, ideal para STT;
  `speaking_read_aloud` es stub y el RPC lo filtra) + **audio TTS 27/27** en Storage (text-matched, tl correcto).
- **RPC v3 (firma 4-arg + `p_exclude_skills`):** rotación **R→L→W→S** sobre las skills DISPONIBLES en el banco
  del curso (fr/it/de/nl sin banco L/S → sigue R/W, cero regresión); **mínimo 3 ítems por skill** antes de poder
  parar (mig 136: min = max(10, 3×skills) → 12 con 4 skills, DENTRO del largo v2 10–16); estimación por skill
  **DEMOTE-only anclada al global** (una skill solo se diferencia hacia ABAJO con ≥3 ítems y acc≤0.5 → global−1;
  JAMÁS promueve → el azar no puede inflar ninguna). Sin evidencia (skill excluida/sin banco) → global (honesto).
- **Cliente:** `placement_test.dart` renderiza **listening** (AudioPlayButton del loop + opciones) y **speaking**
  (frase destacada + botón mic con transcripción en vivo + "Enviar mi respuesta"; `SpeechLang` = idioma del curso).
  **Mic no disponible o "Saltar los ejercicios de hablar"** → `p_exclude_skills=['speaking']` y el ítem saltado
  NO se puntúa (no se añade a history). El examen arranca YA y el mic se inicializa en paralelo. i18n es/en/pt (4 claves).
- **Verificado REAL (cliente JWT, `verify_placement_4skills.py`, en+pt) TODO VERDE:** sirve las 4 skills; largo
  12 (∈10–16); persona fuerte-R/floja-L → **reading>listening en 3/4 corridas** (perfil DIFERENCIADO, p.ej. A2/A1);
  **azar → 0 skills B2/C1 en 8 corridas ×4 skills**; aislamiento por curso. Regresiones: `verify_placement_serious`
  TODO VERDE (las personas ya enfrentan L/S) + `verify_estimator` 8/8. `audit_placement_bank` eximido para speaking
  (sin opciones) y prompts-instrucción L/S. Verde: analyze 0 (CI-exact) · test 131/131 (+placement_flow: listening
  rinde audio, speaking rinde mic y saltar excluye) · build web OK.
- **fr/it/de/nl ✅ igualados (mig 139, 2026-07-10):** banco L/S + audio + verificación 6/6 — ver sección PLACEMENT 4 HABILIDADES en LOS 6 CURSOS.

## SINVIDAS fiel a SinVidas.dc (con honestidad) ✅ (2026-07-09 · solo cliente)
Capa visual; **NO toca la economía de vidas/oro ni la recarga** (buy_hearts 50 oro = P0, intacto).
`no_hearts_sheet.dart` reescrita fiel al mockup:
- **Guacamayo asomado** sobre la hoja (`ParrotMascot` bob) + **backdrop violeta** (`barrierColor` tintado).
- **3 opciones** como tarjetas del mockup (icon-tile + título/subtítulo + trailing): **"Ver un anuncio · Pronto"**
  (ads = Fase 2 sin infra → deshabilitada y etiquetada honestamente, NO botón muerto); **"Recargar todas · 🪙50"**
  (cobro REAL `buy_hearts`, el P0); **"Vidas ilimitadas · PREMIUM"** (card violeta labio 3D → `PremiumScreen`).
- **TIMER — decisión HONESTA (paso 0 verificado en BD/código):** NO existe regen de vidas por tiempo
  (`hearts_updated_at` nunca se lee para sumar; sin cron; en la lección las vidas son LOCALES, empiezan en 5
  cada lección). Un contador "próxima vida gratis en MM:SS" sería una **promesa falsa** → se sustituye por una
  tarjeta con **corazón coral pulsante** (jzPulseHeart, en anillo) + la verdad: **"Vidas gratis en tu próxima
  lección · cada lección empieza con 5 ❤️"**. La recarga de pago sirve para seguir ESTA lección ahora. Se
  corrigió el copy `noHeartsMsg` (antes "se regeneran con el tiempo", falso).
- Motion (jzBob del loro, jzPulseHeart) reduce-motion-aware; sheet **scrollable** (no desborda en pantallas
  cortas). i18n es/en/pt (10 claves). Verificado visualmente con golden temporal (loro + backdrop + tarjeta
  honesta + opciones). **Diferido:** timer real de countdown (requiere regen server-side = tocar economía);
  infra de ads; FRENTE 2 (pose de celebración alterna del loro, Frame B) — encolado. Verde: analyze 0
  (CI-exact) · test 130/130 (+no_hearts_sheet) · build web OK.

## MOTION/CELEBRACIÓN transversal — cierra el último gap sistémico ✅ (2026-07-09 · solo cliente)
Los mockups animan con intención (jzSheen/jzGlow/jzBob…); la app ya tenía bastante (pulso del nodo,
confetti en 5 pantallas, contadores, `ParrotMascot` bob/cheer, halo del portal/emblema, wiggle del cofre,
entrada del feedback bar + combo). Faltaba el **brillo de los dorados** y el **realce del CTA de premio**.
Añadido **con criterio** (motion sirve para feedback/premio/guía, NO para decorar; rápido y sutil;
reduce-motion-aware; barato en FPS). **NO toca lógica** (grading/loop/economía) — capa de animación pura.
- **`JzSheen`** (`core/ui/jz_sheen.dart`): el destello diagonal del mockup (jzSheen) — barrido de ~700ms
  y pausa larga, clipado al hijo, translúcido. Aplicado a los **elementos DORADOS/premio**: badge
  "EXAMEN SUPERADO", CTA dorado "Ver certificado", **tarjeta del certificado** (sheen lento, "documento
  que atrapa la luz"; el halo dorado va en un `DecoratedBox` externo para no recortarlo), badge
  "Plan gratis · Mejorar" de Ajustes.
- **`JzGlowPulse`** (`core/ui/jz_glow_pulse.dart`): halo que **respira** detrás de un CTA de PREMIO para
  guiar la atención (jzGlow). Aplicado a **CONTINUAR del fin de lección**, **"Continúa" del checkpoint
  aprobado**, y **"Empezar mi viaje" de Tu plan**.
- **Ambos calman con reduce-motion** (sheen desaparece; glow queda fijo tenue). No se sobre-animó: ligas,
  cofre y el loop de feedback ya tenían su motion propio y se dejaron intactos.
Smoke test (`jz_motion_test`: sheen+glow pintan el hijo con y sin reduce-motion). Sheen verificado
visualmente con golden temporal (barrido diagonal sobre dorado, borrado por flaky en CI). Verde: analyze 0
(CI-exact) · test 129/129 · build web OK.

## PLACEMENT serio v2: largo + calidad + sin intensidad ✅ LIVE (mig 134 · 2026-07-09)
Rediseño del test de ubicación (feedback real: se sentía interminable, 22 ítems). 3 de los 4 frentes
CERRADOS con verificación real; el 4º (L/S en placement) **✅ HECHO en en+pt (mig 135/136, ver sección arriba)**.
- **PASO 0 (ground truth):** banco = 349 ítems, SOLO reading(MC)+writing(cloze) — 0 listening/speaking;
  en A1–C1 (~14/nivel), pt/fr/it/de/nl A1–B2 (14/nivel). RPC min12/max22, para rev≥6|pin≥4 (casi nunca
  antes del tope → los 22 de Gian). skill_levels = global copiado ×4.
- **1 · LARGO (tuneado offline, sim 4000-20000 trials + flujo real):** **min 10 / máx 16, para con
  rev≥4 o pin≥3**. El examen LARGO castigaba al B1 real (sus fallos arriba arrastraban la precisión
  total al piso 0.6 → B1 real acertaba B1 solo 22%). Nuevo: azar→A1 88–91% (B2+C1 ~1%, cola IRREDUCIBLE
  con MC de 3 opciones), personas A1 90 · A2 72 · **B1 66–71 (3× mejor)** · B2 76–90 · C1 85. **Flujo
  real medido (en+pt): n=10–16, típico 10–12.** Estimador mig 131 intacto + **piso condicional nuevo**:
  acreditar B2+ con evidencia raspada (asked≤3 en ese nivel) exige acc total ≥0.7 (el azar acredita
  raspado; el B2/C1 real acumula 4+ o acc alta → exento). `verify_estimator.py` 8/8. La aserción del
  verify se corrigió a la spec estadísticamente sana (≤1 B2/C1 en 18; "==0" era flaky 7–17%/run y
  pasaba de suerte). `verify_placement_serious.py` (en+pt) **TODO VERDE**.
- **2 · INTENSIDAD eliminada de la app:** el onboarding ya no la preguntaba (mig 124, intensity=3);
  ahora también se quitó el selector Suave/Media/Alta de **Ajustes** (card del coach) y `_save()` fija
  **intensity=3 SIEMPRE** (coach "muy intenso" por defecto). El ESTILO de coach (4 radios) se conserva;
  Matix/personalidad intactos (updateSettings misma firma). Test: sin "Alta"; guardar → intensity=3.
- **3 · CALIDAD ítem-por-ítem (auditoría de INTEGRIDAD server-side de los 349):** colisiones distractor↔
  correcto (normalize + near-match), duplicados, sanidad (correcto∈options, ≥3 options). **Hallazgo real:
  7 ítems del banco EN** (anterior a la guarda anti-colisión) con distractor PERDONABLE por typo-tolerance
  — p.ej. «I have ___ apple.» corr `an`, distractor `a` → marcar `a` PUNTUABA (dist-1 perdonada), matando
  el punto gramatical (también books/book/bookes, live/lives, never/ever, used to/use to, had/has been
  working). **Fix SISTÉMICO:** los ítems de placement se presentan como MC (raíz del anti-azar) → su tipo
  real ES multiple_choice: **349/349 convertidos a `multiple_choice`** (grading EXACTO, near-match no
  aplica) — ni estos 7 ni ningún ítem futuro puede volver a puntuar con distractor. Verificado en vivo:
  **0 distractores puntúan**; caso an/a: `a`=false, `an`=true. (El re-read pedagógico NATIVO completo de
  los 349 = workflow encolado.)
- **4 · 4 HABILIDADES en el placement: ENCOLADO** (no se envía a medias: tocaría el flujo del usuario
  nuevo sin banco L/S ni UI). Retome exacto en ## Cola.
Verde: analyze 0 (CI-exact) · test 130/130 (settings sin intensidad) · verify_estimator 8/8 ·
verify_placement_serious en+pt TODO VERDE · flujo real n=10–16.

## AUDITORÍA UI GENERAL + pulido (foco INICIO) ✅ (2026-07-09 · solo cliente)
Pasada FRESCA contra mockups (goldens del inicio + barrido de consistencia con agente por las 15+
pantallas). **NO toca lógica.** Qué se mejoró por pantalla:
- **Splash (main.dart) — REBRANDEADO:** era fondo gris + loro 64px + spinner genérico + **español
  hardcodeado** ("No se pudo cargar tu sesión."/"Reintentar" fugaba en pt/en pese a EXISTIR las claves).
  Ahora: **gradiente violeta de la casa + guacamayo 92px con halo + wordmark "Jezici"** + spinner blanco;
  error usa `splashLoadError`/`commonRetry` (i18n). La primera impresión ES de marca.
- **Onboarding · bienvenida:** mismo lenguaje de APERTURA que el auth — halo radial violeta de fondo,
  mascota 104px con halo, **CTA EMPEZAR con `JzGlowPulse`** + `ResponsiveCenter` 480. Ya no es una
  pantalla gris suelta.
- **Consistencia del botón 3D (el hallazgo transversal #1 del barrido):** `PrimaryButton` casi no se usaba
  — cada pantalla rodaba su propio `ElevatedButton` PLANO. Convertidos a `PrimaryButton` (labio + hundido)
  los CTA full-width más vistos: **misión inicial** (inicio), **EMPEZAR EXAMEN** (intro), **reintentar
  examen** (resultado), **volver al mapa** (checkpoint player error), **LISTO** (fin de práctica),
  **COMPARTIR** (certificado), **HAZTE PREMIUM** (dorado 3D), **QUIERO LLEGAR MÁS RÁPIDO** (Mi plan,
  dorado 3D), **ENVIAR/GUARDAR** (Conversar). `PrimaryButton` ganó `foreground` opcional (texto oscuro
  `#5B3A00` en dorados, contraste del mockup).
- **Historias · resultado del quiz:** emoji 🎉/📖 → **`ParrotMascot` celebrate/encourage** (coherencia de
  mascota en TODAS las celebraciones).
**ENCOLADO (retome exacto, ## Cola):** (a) botones COMPACTOS inline aún planos (tienda comprar,
congelador de racha) → variante mini-3D; (b) **i18n de pantallas secundarias** con títulos/cuerpos en
español hardcodeado (Inmersión/Historia/Glosario, Cuaderno, Métricas, Mi plan, Certificado, Simulacros,
Premium, Repaso, Notificaciones, intro examen, diálogos de Ajustes export/delete/logout, player examen)
— lista completa con file:line en el barrido; (c) armonizar sombras suaves (blur 16-32) que conviven con
la sombra dura de la casa en perfil/práctica/ligas/your_plan. Verde: analyze 0 (CI-exact) · test 130/130
· build web OK.

## FONDO DEL MAPA v2 — quitados los EDIFICIOS (las "franjas verticales") ✅ (2026-07-09 · solo cliente)
Gian SEGUÍA viendo "franjas verticales moradas/verdes/coral" tras el fix de anclaje (v1). **Causa real
encontrada renderizando el PIE de un mapa alto** (los mapas son MUY altos: `_flatten` = TODAS las lecciones
de todas las unidades → contentHeight 5.000–23.000px): al inicio del viaje se veía la **CIUDAD = edificios
VERTICALES morados/coral** (`#7E6FE6/#6C5CE7/#FF8585`) plantados sobre el verde de las colinas → eso ERA las
"franjas verticales moradas/coral" (y el verde de las colinas). No parecía un paisaje: barras verticales
sobre césped. **Fix:** se **ELIMINÓ `_city`** (los edificios) por completo — el mockup lista velero/pinos/
nubes/montañas como la escenografía buena, NO la ciudad. En su lugar, **bosque de pinos más denso** hacia el
pie + **ramp de verdes de pasos suaves** (contraste bajo entre capas → colinas que se funden, sin bandas
duras). Resultado (verificado con golden del pie y del full): paisaje **limpio y cohesivo** — cima con
montañas/sol, costa con velero, cielo en degradado, y **colinas verdes con pinos** en el pie; **cero barras
verticales**, sendero limpio. Se conserva todo lo que se veía bien (velero, pinos, nubes, montañas). El globo
"EXAMEN · UNIDAD N" ya estaba bajado al hueco del portal (c.dy+62). Verde: analyze 0 (CI-exact) · test
130/130 · build web OK.

## FONDO DEL MAPA rehecho — fin de las "franjas" ✅ (2026-07-09 · solo cliente)
Feedback Android de Gian: el fondo del mapa se veía como **franjas de color planas sueltas** (moradas/
verdes/coral) desalineadas que cortaban el sendero. **Causa raíz:** `scenery_painter.dart` posicionaba los
set-pieces por **FRACCIÓN de la altura del contenido** — que es variable (2500–5200px en mapas largos, vs los
1860px fijos del mockup) → las bandas (mar, montañas) se separaban con enormes huecos de degradado plano y
parecían franjas flotantes. **Fix (capa visual, NO toca nodos/progresión/gating):** se PORTA 1:1 el SVG de
Aprender v2.dc con **anclaje ABSOLUTO en px** — la escenografía LEJANA (sol, montañas nevadas, nubes, costa con
velero) se ancla ARRIBA; el PRIMER PLANO (5 colinas contiguas + pinos + ciudad con ventanas) se ancla ABAJO; el
MEDIO es puro **degradado vertical de 8 paradas** del mockup (morado-ciudad abajo → azul/cian-cielo → crema-cima)
que es lo que da la transición suave entre regiones. Resultado: **paisaje cohesivo a cualquier altura, sin
franjas**, sendero limpio encima. Extras: nubes suaves semitransparentes rellenan el cielo medio en mapas altos;
**velo superior** (fadeUp) funde la cima; full-bleed (llena el ancho en desktop, columna de nodos centrada dx0).
El globo **"EXAMEN · UNIDAD N"** se bajó al hueco bajo el portal (ya no se monta sobre el arco). Verificado
visualmente con un golden temporal (paisaje integrado; borrado por flaky en CI Linux). Verde: analyze 0
(CI-exact) · test 125/125 (+scenery_painter: pinta sin excepción a 4 alturas) · build web OK.

## 2 BUGS de uso real (feedback Android de Gian) ✅ (2026-07-09 · solo cliente)
- **BUG 1 · Conversar salía 100% en ESPAÑOL con la app en otro idioma.** `conversar_screen.dart` tenía
  título/subtítulos/banner/rótulos y las situaciones ("Pedir un café", "Estás en una cafetería…")
  HARDCODEADOS en español (mismo bug que ya arreglamos en Práctica; Conversar quedó fuera del barrido).
  **Fix:** todo el CHROME va por i18n es/en/pt (44 claves nuevas): título, subtítulo, banner "en vivo",
  cabeceras, tarjeta de interés, pantalla de práctica (modos escribir/hablar, hints, "VER RESPUESTA MODELO",
  "Respuesta modelo"/"Frases clave", autoevaluación, guardar, estados del micrófono). Los **topics** ahora
  tienen un **slug estable** (`id`: cafe/intro/airport/weekend/interview/directions) → título+escenario por
  i18n de la APP; la **respuesta modelo + tips siguen siendo CONTENIDO por idioma del curso** (`ConvModel`
  multi-idioma en/pt/fr/it/de/nl vía `modelFor(lang)` con `activeCourseTargetProvider`). El intento se guarda
  con `topic.id` (analítica coherente, no varía por idioma). Verificado con test: la app en **pt** no deja
  español ("Pratique conversas reais…", "Pedir um café"; 0 strings es).
- **BUG 2 · La bandera ▼ del top bar del mapa no hacía NADA + estaba 🇬🇧 fija.** PASO 0: era un
  `const Container` con `🇬🇧` + flecha, **sin `onTap`** (widget muerto) y sin leer el curso. **Decisión fija:**
  representa el idioma del CURSO (lo que aprendes). **Fix:** la bandera refleja el **curso activo real**
  (`coursesProvider` → `active.flag`) y al tocarla abre el **cambio de curso** entre los 6. La lógica de
  cambio+re-placement se **EXTRAJO** de Ajustes a un módulo compartido (`features/onboarding/course_switcher.dart`:
  `switchCourseFlow` + `showCoursePickerSheet`) — **NO duplicada**; Ajustes ahora la delega (`_switchCourse` =
  one-liner). El **idioma de la APP se sigue cambiando SOLO en Ajustes** (no se tocó). El error de cambio de
  curso pasó a i18n (`courseSwitchFailed`).
- **Aislamiento multicurso INTACTO** (la bandera reusa el MISMO `set_active_course` → `jz_active_course` rutea):
  `verify_placement_wiring.py` (cliente real, JWT) **TODO VERDE** — cada curso sirve SOLO lo suyo (`solo_curso=True`),
  el progreso EN queda intacto tras re-ubicar otros, grading server-side (42501). NO toca loop/seguridad/ligas.
  Verde: analyze 0 (CI-exact) · test 124/124 (+bugfix: Conversar pt sin español, bandera = curso activo) · build web OK.

## MASCOTA SVG ÚNICA — Matix guacamayo escarlata (gap sistémico #3) ✅ (2026-07-09 · solo cliente)
El diferenciador de marca: el emoji 🦜 estático → **guacamayo escarlata VECTOR propio**, sin assets ni
paquetes (CSP-safe, cero peso de red). En `features/learn/widgets/parrot_mascot.dart`:
- **`ParrotArt`** (StatelessWidget · CustomPaint): porta **1:1 el SVG de los mockups** (Ajustes/Leccion,
  viewBox 84×90) → cuerpo/cabeza escarlata (`#FF4D6D`/`#FF6B6B`), vientre rosa, ala y cola dorado-naranja
  (`#FFC93C`/`#FF7A00`), **cresta** de 2 plumas, cara crema, ojo con pupila+brillo, pico dorado. Estático,
  reutilizable en superficies pequeñas/inline (banners, listas, estados vacíos, splash). Verificado
  visualmente (golden temporal → se ve el guacamayo, borrado por flaky en Linux CI).
- **`ParrotMascot`** (animado): usa `ParrotArt` como cuerpo + los estados idle/celebrate/encourage
  (bob/brinco/asentimiento, reduce-motion-aware) + **globo de diálogo BLANCO** estilo mockup (antes era
  oscuro). Sus 14 usos (mapa, lección, perfil, ligas, ajustes/Matix, checkpoint/examen, onboarding…) pasan
  a SVG automáticamente.
- **Reemplazado el emoji standalone** en 10 superficies más: onboarding (hero 96), práctica (header +
  summary celebración), error-review, translation-exercise, certificado, cuaderno (vacío), Matix banner,
  centro de notificaciones (vacío + avatar de fila), splash (main.dart). **Se conserva** el 🦜 decorativo
  dentro de la COPIA i18n ("¡Correcto! 🦜") — es puntuación, no el personaje. Los avatares de usuario
  (fallback) tampoco se tocan (no son Matix).
- Cierra el gap sistémico #3 de MOCKUP_GAP y los "diferidos de mascota" de Aprender/Onboarding/Lección.
i18n intacto (globos ya localizados). Verde: analyze 0 (CI-exact) · test 122/122 (+parrot_mascot: vector
sin emoji + globo) · build web OK.

## LECCIÓN: pulido fiel a Leccion.dc ✅ (2026-07-09 · solo cliente)
Capa visual + TTS (determinista, cero IA). **NO toca grading/loop/scoring.**
- **F1 · Labio 3D en el CTA del loop (`_BigButton` COMPROBAR/CONTINUAR):** era un `Container` plano
  (radius 16, sin labio ni hundido) → ahora StatefulWidget con **sombra dura `0 6px 0 <depthColor>` +
  hundido al presionar** (translateY 4, 6→2px), idéntico a `PrimaryButton` y al mockup (COMPROBAR
  `0 6px 0 #4B3FC9`, CONTINUAR verde `#1E9B52`, coral `#D6294B`, deshabilitado gris `#B3B8CC`).
  Reduce-motion-aware. Los 3 call-sites pasan `depthColor` real (el feedback ya calculaba `accentDark`).
- **F2 · Altavoz TTS en la frase origen (word_bank/reorder):** el enunciado con frase ENTRECOMILLADA
  lleva un **botón altavoz** (tile 40 violeta claro, icono violeta) a la izquierda (`_PromptText` +
  `promptSourcePhrase` extrae « »/" "/" "). **Decisión honesta (discrepancia doc↔BD):** el prompt de
  estos ítems es SIEMPRE la frase ORIGEN en **español** (es→X; mig 068 la puso en español para no
  revelar). Leerla con voz meta la destrozaría, y leer la traducción META **revelaría la respuesta**
  (el reto es el orden) → el altavoz usa **voz española** (`WordTts.speakSource`, fijo `es-ES`). El TTS
  de tile sigue pronunciando las palabras META al tocarlas (pronunciación meta cubierta). Si el
  enunciado no tiene comillas (reorder genérico), NO se pinta el altavoz. Tap → sin unlock iOS,
  interrumpible, degrada con gracia.
- **F3 · Tarjeta de skills del fin enriquecida (dato real):** por cada skill que subió, fila con icono +
  nombre + badge "▲" + **barra de progreso real** (`levelProgress` de `user_skill_levels`) + **chip CEFR
  real** + **pie motivacional** ("Sigue así para alcanzar \<siguiente CEFR real\>…", `CefrTable.next` de
  la skill de nivel más bajo). Se **invalida `skillsProvider`** al entrar → datos POST-lección frescos.
  **Degrada** a chip simple si el nivel aún no cargó (no inventa progreso/nivel).
- Diferido honesto (P2): guacamayo SVG + globo en la fila del enunciado (el asset es emoji, no SVG →
  no se fuerza); confeti ráfaga vs loop; gradiente del CONTINUAR final.
i18n es/en/pt (3 claves). Verde: analyze 0 (CI-exact) · test 120/120 (+F3 skills card, +F2 extracción
frase) · build web OK.

## AJUSTES fiel a Ajustes.dc ✅ (2026-07-09 · solo cliente)
Capa visual + estructura; **NO toca la lógica de settings/personalidad/economía** (updateSettings/
create_plan/setActiveCourse intactos). `settings_screen.dart` era una lista plana de cards con
`SwitchListTile` Material violetas + botón "GUARDAR AJUSTES" → reescrita fiel al mockup.
- **5 secciones con micro-headers MAYÚSCULOS** (IDIOMA/NOTIFICACIONES/META Y RECORDATORIOS/CUENTA/OTROS)
  + AVANZADO (interno/GDPR), cada fila con **icon-tile 36×36 coloreado + divisores** (`_Group`/`_tile`).
- **Loro Matix animado** (`ParrotMascot` idle, reduce-motion-aware) **+ burbuja de preview del tono** elegido
  (`#F4F2FF`, texto violeta, con cola) + **4 radios** de coach + segmento de intensidad Suave/Media/Alta.
- **Toggle verde custom `#2ECC71`** (`_GreenToggle`, pista 48×28 + perilla animada) reemplaza los Material;
  **guardado IMPLÍCITO** (cada cambio server-backed llama `_save()` en silencio; sin botón "GUARDAR").
- **Toggles "Recordatorio diario" + "Aviso de racha en peligro"** — persistidos localmente
  (`core/prefs/notify_prefs.dart`, patrón `SoundController`), **NO muertos**: el maestro real `push_enabled`
  se **DERIVA** de ambos al guardar (apagar los dos → Matix deja de empujar). Scheduler push = Fase 2
  (nota honesta bajo la card). **Vibración** real: `vibrationEnabledProvider` sincroniza
  `FeedbackFx.hapticsEnabled` → apagarlo silencia TODO el háptico.
- **Fila "Aprendes / \<curso real\> · Objetivo \<meta\> · Cambiar"** course-aware (reusa `_switchCourse` →
  placement/desde-cero) + **badge "Plan gratis · Mejorar"** → `PremiumScreen`. Sheets para meta diaria,
  quiet hours, idioma de app, curso y legal (privacidad/términos).
- Se conserva: quiet hours, idiomas es/en/pt, cerrar sesión, sello de versión, export/borrado, métricas,
  Probar a Matix. i18n es/en/pt (56 claves) + `ResponsiveCenter` 480.
Verde: analyze 0 (CI-exact, .env vacío) · test 115/115 (+settings_screen: secciones/Aprendes/badge/preview +
intensidad guarda) · build web OK.

## COFRE: pantalla de revelación dedicada fiel a Cofre.dc ✅ (2026-07-09 · solo cliente)
Antes el cofre era una fila de la tienda que daba la recompensa con un **SnackBar**. Ahora es una **pantalla
dedicada de revelación** (`shop/chest_reveal_screen.dart`, Cofre.dc): fondo violeta (5B4ECF→6C5CE7→8273E8),
**guacamayo festejando** (`ParrotMascot`), **sparkles** de ambiente, **cofre que hace wiggle** (CustomPaint:
cuerpo violeta + correas/candado dorados + gema) → tap/CTA lo abre → **reveal** con **rayos giratorios + halo
pulsante + haz de luz + medalla + "+N ORO"** (pop `easeOutBack`) + **confeti** + cofre abierto con monedas
derramando. **CTA dorado 3D 62px** (token nuevo `AppColors.goldCtaTop/Bottom/Depth` = FFDD7A/F4B400/D69400,
"el token que faltaba") que **muta a verde "¡Reclamar!"**. **La recompensa es la REAL del servidor**
(`open_daily_chest`): la pantalla llama al RPC al abrir y muestra `reward`; **NO cambia la economía**. Estados
**cerrado / abierto / mañana** (cofre gris + candado, sin RPC). **Reduce-motion-aware** (sin animación revela
directo, legible). Responsive (`ResponsiveCenter` 440). i18n es/en/pt (13 claves). La tienda: el card del
cofre **navega** a la pantalla (`fullscreenDialog`) y refresca el saldo al volver — se quitó el confeti/SnackBar
inline (el guard anti-doble-tap se mantiene). Verde: analyze 0 · test 113/113 (+chest_reveal: cerrado→abrir→
premio real+¡Reclamar!; mañana sin RPC) · build web OK.

## MOMENTOS DE APROBAR: Checkpoint + Examen fieles a sus mockups ✅ (2026-07-09 · solo cliente)
Capa visual + datos reales; **NO cambia scoring/gating/certificación**.
**F1 · Checkpoint resultado (Checkpoint.dc):** header con **guacamayo animado** (celebrate/encourage) + halo
dorado; tarjeta "NUEVA REGIÓN DESBLOQUEADA" con **mini-mapa SVG del desbloqueo** (portal superado ✓ → camino
punteado violeta→verde → siguiente región con glow) — el "momento wow". **Reprobado:** anillo de score real
("64%") + "te faltaron N puntos" + filas de refuerzo **con conteo de fallos REALES** ("N fallos"). Degradación
honesta: el RPC no expone fallos por TEMA → fallos reales POR HABILIDAD (`perSkill.graded − correct`).
**F2 · Examen resultado (Examen.dc, reescrito — antes fondo plano con 🎓 y TODO hardcodeado en español):**
header de celebración (gradiente + confeti + guacamayo + badge dorado **"EXAMEN SUPERADO"** / apagado "AÚN NO");
"¡Felicidades! Alcanzaste el nivel X" + **"✓ Verificado por el examen Jezici"**; card **"Las 4 habilidades en
X"** (barras = accuracy real por skill vs **línea de META punteada al umbral real** + tag "META X" + chip
"N/4 ✓" + "Todas alcanzan la meta — por eso se certifica" — la regla REAL per-skill ≥80%); card **"Puntaje
global"** (anillo N/100 = `score_global` real + chips Fortaleza/Pulir + grid de skills; el percentil "top 12%"
NO existe → se omite, honesto); botones "Ver certificado" dorado + **compartir** (copia folio+verificación) +
banner de recompensas. **Reprobado:** diagnóstico per-skill (barra de la más floja + "sube tu \<skill\>" +
**"Reforzar \<skill\>"** → `startPractice` skill/debilidad real) + reintentar + volver. i18n es/en/pt (22 claves).
Verde: analyze 0 · test 111/111 (+results_screens: aprobado examen, reprobado examen con Reforzar, reprobado
checkpoint con anillo+fallos) · build web OK.

## PERFIL + LIGAS fieles a sus mockups ✅ (2026-07-09 · solo cliente)
Capa visual + datos que ya existen; **NO cambia lógica de skills/ligas/scoring/economía**.
**F1 · Perfil (Perfil.dc):** banner "pasaporte" full-bleed ("MI PERFIL" + campana/ajustes) con **avatar con
anillo de XP + badge de nivel de viajero + barra al siguiente** — el sistema no existía (`users.player_level`
nunca se actualiza) → derivado honesto de `xp_total` (`traveler_level.dart`, T(n)=50·(n−1)·n, determinista, con
test) — y **chip "IDIOMA ACTIVO · \<curso real\> · Objetivo \<meta\> · Cambiar"** course-aware (tap → Ajustes).
Radar con **anillo de META punteado + tag "META X" + vértices coloreados** (coral = bajo meta) + **labels
localizados** (fix i18n: salían en español vía kSkillEs). **Alerta de punto débil con mascota + CTA coral**;
filas de skill **coloreadas por estado** ("X → Y · %"). **Certificados**: medalla con check (obtenidos) + **card
BLOQUEADA con requisitos** ("Necesitas X en las 4" + 4 mini-barras por `examReady` real + "N de 4 listas"; tap →
examen si desbloqueado; absorbe la _LevelExamCard). **Stats**: **calendario semanal de racha** (días activos
derivados de la racha REAL: si racha=N y hoy hubo XP, los últimos N días fueron activos; "Mejor: N"; HOY 🔥) +
tiles XP/Oro/**Liga (división+puesto reales)**/Logros. Se conserva: DailyGoalBar, Para ti, cuaderno, MasteryGate,
plan, logros, editar perfil.
**F2 · Ligas (Ligas.dc):** banner violeta con **emblema-medalla por división REAL** (CustomPaint: gradiente de
`DivisionTheme` + estrella + cintas + laureles + halo pulsante reduce-motion-aware) + **carrusel de las 6
divisiones** (actual destacada, futuras 50%) + **countdown "Termina en Xd Yh"** (`week_start` real del RPC —
parseado nuevo en `LeagueStanding` — + 7 días). Ranking: separadores **con división destino** ("SUBEN A
ZAFIRO"/"BAJAN A PLATA", `DivisionTheme.up/down` espejo de jz_div_up/down), filas con **tinte por zona + tags**
("Sube"/"En riesgo"/"¡Mantente arriba!"), **top-3 círculos-medalla**, **avatares coloreados**, rótulo "XP esta
semana", **mascota animadora** ("¡Sigue subiendo! 💪"). Estados conservados: skeleton/error/beta<13. El tab
Tablas mantiene su fila simple (`_LbRow`).
**Fix latente de paso:** `JzShimmer` inicializaba su AnimationController perezosamente en `dispose` con
reduce-motion (ancestor lookup en widget desactivado, assert en debug) → init movido a `initState`.
i18n es/en/pt (27 claves nuevas). Verde: analyze 0 · test 108/108 (+traveler_level determinista, up/down con
topes, widget Ligas es: división real + countdown + destinos + tags) · build web OK.

## PRÁCTICA fiel a Practicar.dc + i18n arreglado ✅ (2026-07-09 · solo cliente)
Ingeniería pura (cero IA). `practice_screen.dart` era una **lista de 7 cards idénticas** con **toda la copia
hardcodeada en español** (salía en español con la app en pt/en — bug real). Reescrita con la **jerarquía del
mockup** y 100% localizada. **La lógica de práctica/SRS/scoring es server-side y NO se toca** (cada card solo
dispara la sesión real existente: `start_practice` / ReferenceScreen / ImmersionScreen).
- **Header violeta** (gradiente `#7A6BF0→#6C5CE7→#5B4ECF`): kicker "ENTRENAMIENTO" + título + subtítulo +
  guacamayo (`ParrotMascot`). Full-bleed; contenido en `ResponsiveCenter` 480.
- **HERO "Rescate de palabras" (SRS):** cabecera durazno + pill "REPASO ESPACIADO" + **contador coral con glow
  = `status.dueWords` REAL** + CTA coral "Rescatar ahora 🪝". **Degradación HONESTA:** la barra "Memoria media"
  y los chips de palabras del mockup **NO se pintan** — el provider no expone ni el % ni la lista (no se inventa).
- **Fila punto débil:** icon-tile + nombre de la skill + **mini-barra + badge CEFR reales** (`SkillLevel`
  de `skillsProvider`) + botón "Practicar". **Fila "Reforzar lo que fallé".**
- **Grid 2×2 "Más práctica":** Lectura, Escritura (skills gradables Fase 1), **Repaso** (ReferenceScreen),
  **Inmersión** (ImmersionScreen) — los modos EXTRA integrados con criterio, no se pierde ninguno.
- **Banner contrarreloj:** gradiente violeta + reloj dorado + badge "+XP EXTRA" + **90 s** (alineado al mockup;
  antes 60) + CTA blanca. + nota de XP.
- Motion sutil (glow del contador, botones 3D con hundido, guacamayo idle) reduce-motion-aware.
**i18n es/en/pt** (29 claves nuevas + nombres de skill vía `skillName`): en pt/en ya **no queda español**.
Verde: analyze 0 · test 105/105 (+practice_screen: ES rinde HERO/contador/CEFR/90s; **PT sin español filtrado**)
· build web OK. Overflows horizontales corregidos (título largo del banner en pt, fila del punto débil).

## HOME/MAPA fiel a Aprender.dc — portal + escenografía + anillo ✅ (2026-07-08 · solo cliente)
Ingeniería pura (cero IA), **capa visual + composición: NO toca la lógica de progresión/desbloqueo/gating**
(intacta). La base del mapa ya era fiel (nodos, pulso, sendero, colinas); se añadieron los elementos de
"viaje" que faltaban (MOCKUP_GAP §1):
- **Portal de examen** (`checkpoint_portal.dart`): el nodo de checkpoint es ahora un **arco/portal** (CustomPaint:
  base, pilares violeta con reflejo, arco superior, interior dorado con gradiente `#FFE9A8→#FFC93C`, estrella-
  llave, **halo pulsante** `jzGlow` reduce-motion-aware) + pill **"EXAMEN · UNIDAD N"**. Estado **bloqueado** =
  gris apagado + candado (respeta el gating ≥80% dominio sin cambiar nada). Reemplaza el círculo con
  `Icons.sports_score`. Cableado en `learn_map_screen` (branch por `LessonType.checkpoint`).
- **Escenografía por región** (`scenery_painter.dart`, full-bleed): de la base a la cima — **ciudad/distrito
  laboral con ventanas iluminadas** (donde empiezas), **costa con mar/playa/velero**, 5 capas de colinas + 5
  pinos de 2 capas, **cordillera lejana con cumbres nevadas + nubes** bajo la cima. Posicionada por FRACCIÓN de
  la altura total → el mapa "evoluciona" al desplazarse sea cual sea el nº de unidades. La columna de nodos
  sigue centrada (dx0/ResponsiveCenter) → móvil pixel-fiel, desktop centrado sin franjas.
- **Anillo de progreso** en el nodo disponible (`MapNode.progress`): pista blanca + arco **coral** = avance de la
  unidad (lecciones completadas/total), como en Aprender.dc.
- Motion reduce-motion-aware (halo del portal se congela; el pulso del nodo y el aro fijo ya existían).
i18n es/en/pt (1 clave nueva `mapExamUnit`). **La barra superior (ya funcional) queda integrada arriba** sin
cambios. Verde: analyze 0 · test 100/100 (+map_visuals: portal disponible/bloqueado, anillo, escenografía sin
excepción) · build web OK. **Diferido (P1/P2 estético):** mascota SVG vs emoji, sheen/banderín del dorado,
chispa+tarjeta de misión, velo de zona bloqueada, flotación del globo "EMPIEZA".

## Barra superior FUNCIONAL — cada stat hace algo real ✅ (2026-07-08 · solo cliente)
Ingeniería pura (cero IA), reutilizando la economía existente. Antes en `learn_top_bar.dart`: ❤️ vidas
**sin onTap** (muerta), ⚡ meta abría StreakScreen (destino incorrecto), 🪙 oro→Tienda directo (sin explicar),
🔥 racha→StreakScreen ✓, 🔔 campana→NotificationCenterScreen ✓ pero sin señal de vida. Ahora cada ítem es
tappable con acción real (`widgets/top_bar_panels.dart`, bottom-sheets con el lenguaje visual del mockup +
motion sutil de entrada, reduce-motion-aware):
- **❤️ VIDAS → panel:** 5 corazones (llenos = vidas reales de HomeStats), «se regeneran solas / pierdes una
  por fallo», y **Recargar · 🪙50** que llama el RPC real `buy_hearts()` (mig 026, misma economía que la tienda
  y que SinVidas); sin oro → aviso inline, no recarga. Oculta el botón si están llenas.
- **🪙 ORO → panel:** saldo real + «para qué sirve» (ganar/gastar) + **Abrir tienda** → `TiendaScreen`.
- **⚡ META DIARIA → panel:** anillo grande X/Y XP hoy (dato real) + qué cuenta (lecciones+práctica) + tie-in de
  racha; «¡Meta cumplida!» al llegar. (Antes abría por error la pantalla de racha.)
- **🔥 RACHA → `StreakScreen`** (ya real: contador, récord, hitos, **congelador** a 50 oro) — sin cambios.
- **🔔 NOTIFICACIONES → `NotificationCenterScreen`** (ya real: tabla `notifications`/Matix con RLS + estado
  vacío decente) + **badge de conteo** en la campana (lee `notificationsProvider`, muestra n/9+). NO es botón
  muerto: `matix_fire` (el mismo RPC del centro) inserta y el usuario la lee bajo RLS.
- **🇬🇧 bandera + 🎵 música:** sin cambios (fuera de alcance).
i18n es/en/pt (10 claves nuevas). **Verificado cliente real (`verify_topbar.py`):** matix_fire crea notificación
'sent' y el usuario la lee bajo RLS (parte de estado vacío→1); buy_hearts cobra y recarga server-side (80→30,
hearts 5). Widget test (`top_bar_panels_test`): los 3 paneles rinden vidas/oro/meta reales + sus acciones.
Verde: analyze 0 · test 100/100 (+3) · build web OK. NO toca loop/economía/seguridad (buy_hearts/tienda/
StreakScreen/centro ya existían).

## 3 P0 de producto del MOCKUP_GAP ✅ (mig 133 · 2026-07-08)
Tres bugs (no estética) de MOCKUP_GAP.md, arreglados y verificados con cliente real (`verify_p0_product.py`).
- **F1 · El certificado imprime el NOMBRE del titular (Examen.dc).** Antes no decía de quién era. El nombre
  YA se calculaba al emitir (embebido en el SVG) pero no se guardaba en columna ni lo devolvía la API. Fix
  (mig 133, SIN reescribir el gran `submit_level_exam`): columna `certificates.holder_name` **congelada al
  emitir** por trigger `jz_cert_set_holder` (fuente = `users.display_name/name`, la misma que get_profile) +
  **backfill** de los ya emitidos + `get_certificates` la devuelve. `Certificate.holderName` + `CertificateScreen`
  muestra «Se certifica que <NOMBRE>» (fallback a get_profile para el cert recién emitido). i18n es/en/pt.
  Verificado: trigger congela «María Certif», get_certificates lo devuelve, y **cambiar el nombre después NO
  altera el certificado** (congelado).
- **F2 · Ligas usa la DIVISIÓN REAL (no bronce hardcodeado).** El header pintaba un gradiente bronce fijo +
  `Icons.emoji_events` sea cual fuera la división. Nuevo `division_theme.dart` (`DivisionTheme.of(division)`:
  gradiente + sombra + emblema por bronce/plata/oro/zafiro/rubi/diamante, colores de Ligas.dc); el header de
  `_Board` usa `lg.division`. Verificado cliente real 2 divisiones (`get_league` oro→oro, diamante→diamante) +
  test unitario (`division_theme_test`). (P1 diferido: emblema-medalla 128px con laureles/halo — estético.)
- **F3 · SinVidas: coherencia de oro.** El copy prometía cobrar oro pero la recarga era `_hearts=5` local y
  GRATIS. **Decisión:** cobrar de verdad, alineado a la economía EXISTENTE (no inventar el 350 del mockup, que
  nada enforce) → la recarga usa el RPC real `buy_hearts()` (mig 026, **50 oro** = costo de la tienda), muestra
  el precio real, descuenta server-side y **si no hay oro suficiente NO recarga** (aviso inline; el sheet
  devuelve `refill` solo si la compra tuvo éxito). i18n es/en/pt. Verificado cliente real: con oro→recarga+
  descuenta 50 y hearts=5; sin oro→`insufficient_gold`, oro intacto. **No rompe** economía/loop/seguridad
  (buy_hearts ya existía y se usa en la tienda). Verde: analyze 0 · test 97/97 (+division_theme) · build web OK.

## Onboarding — NOMBRE + fidelidad al mockup ✅ (mig 132 · 2026-07-08)
Dos frentes de Onboarding.dc (fuente de diseño), sin tocar placement/create_plan.
**F1 · Correctitud: se PIDE el nombre (antes nunca).** Bug real: "Continuar con Google" (OAuth) crea
la cuenta saltándose el formulario de email → nunca se llamaba `set_profile(name)` → el perfil quedaba
en "Coloque seu nome" (`needs_name=true`). Fix en 2 capas: **(belt, mig 132)** `handle_new_user` siembra
`users.name/display_name` desde `raw_user_meta_data` (`full_name`/`name` que Google entrega) al INSERT —
solo afecta a altas NUEVAS (`on conflict do nothing`), 0 impacto en existentes. **(suspenders, cliente)**
paso de **nombre nuevo en el onboarding** (case 2, ANTES del examen), pre-rellenado desde el metadata de
OAuth (`ProgressRepository.authMetadataName`) y desde `get_profile` (alta por email ya lo fijó), persistido
con `set_profile` al continuar y de nuevo en `_finish` (idempotente, degrada offline). i18n es/en/pt.
**Verificado cliente real** (`verify_onboarding_name.py`): OAuth con `full_name` → `users.name` sembrado +
`get_profile` needs_name=false; email sin metadata → nace needs_name=true → `set_profile` del onboarding lo
persiste. **F2 · "Tu plan" fiel al mockup (FRAME B):** `your_plan_view` rehecho — **header de CELEBRACIÓN**
(gradiente violeta + confeti `jzFall` + halo `jzGlow` + guacamayo festejando `ParrotMascot.celebrate` +
kicker "PERSONALIZADO PARA TI"), **MAPA DE VIAJE** (colinas + camino punteado que asciende, `CustomPaint`
animado; pin "ESTÁS AQUÍ" = nivel actual → bandera "TU META" = meta efectiva, con milestone intermedio si
el salto ≥2 niveles), tarjeta de fecha viva (`AnimatedSwitcher`) con badge "⚡ ¡La mitad de tiempo!",
**palanca REVERSIBLE** (toggle base↔rápido que recalcula en vivo; antes solo subía por tiers), CTA coral
"Empezar mi viaje". **F2b · pasos de pregunta (FRAME A):** progreso **segmentado** + contador "n/total",
guacamayo animado con **globo blanco** ("¡Hagamos un plan a tu medida!"). Todo **reduce-motion aware**
(`MediaQuery.disableAnimations`) y responsive (`ResponsiveCenter` 480). **NO se tocó** placement anti-azar,
"empezar desde cero"→A1, elegir idioma meta, ni create_plan. Verde: **analyze 0 · test 96/96** (+widget test
"Tu plan" celebración + palanca reversible; onboarding_target camina el nuevo paso de nombre) · build web OK ·
`verify_placement_serious` re-verificado (azar→0% B2/C1, intacto). Commit `990e3c9`. La **mig 132 ya está LIVE**
(aplicada por Management API, deploy-independiente → los usuarios NUEVOS de Google ya reciben su nombre HOY).
**Deploy ✅ desbloqueado (repo volvió a PÚBLICO):** mientras el repo estuvo privado el deploy de `990e3c9`
quedó BLOCKED; al volver a público un push nuevo compila y despliega normal → los cambios de cliente (paso de
nombre + "Tu plan" nuevo) ya se sirven en producción. Verificación manual de Gian: usuario nuevo Google/email
→ pide y guarda el nombre; "Tu plan" se ve como el mockup.

## Placement SERIO — anti-azar (bug real ARREGLADO) ✅ LIVE (mig 131 · 2026-07-08)
**Bug reproducido (no sintético):** un usuario NUEVO marcando AL AZAR salía B1/B2/**C1**. Los 3 "fixes"
previos pasaron con sims deterministas pero NO tocaron el camino real. **Causa raíz (3 factores):**
(1) **todos** los ítems de placement (incluidas las cloze) llevan `options` → la UI los presenta como
opción múltiple → **azar = 1/3 de acierto en CADA ítem**; las verificaciones previas respondían
100%/0%/persona-determinista, **nunca azar uniforme 1/3**. (2) Estimador débil: **fallback `acc≥0.5`**
(una moneda al aire promovía un nivel) + dominación con solo ~2 ítems/nivel. (3) El arranque "buen nivel"
sembraba la escalera en B1 → el azar rebotaba alto. **Evidencia ANTES** (`repro_placement_random.py`,
cliente real, 60 al azar): en/B1 **C1 5% · B2 10%** (15% inflado); pt/B1 B2 5%.
**Fix (mig 131, tuneado con `sim_placement_tune.py`, 4000 trials/caso):** (A) `jz_placement_level`
**guess-aware** — un nivel se acredita solo con evidencia SOSTENIDA (`asked≥3 & corr≥⌈0.72·asked⌉ &
corr≥3`), se toma el más alto, **se elimina el fallback laxo**, y **piso global** (acc total <0.5 → tope
A2, imposible B1+). (B) `placement_next` examen **más largo** (min 12 / max 22, reversals≥6 o pin≥4) +
**arranque CLAMPEADO a A2 máx** + skill_levels = nivel global (el split R/W sobre ~6 ítems era ruido y
subcreditaba). **Aplica a los 6 cursos** (lógica course-agnóstica). **Verificado DESPUÉS (cliente real,
`verify_placement_serious.py`, en+pt):** azar (peor caso B1) → **0% B2/C1** (en 16 A1/2 B1; pt 18 A1);
persona B1 real → B1 (10/12, 9/12); persona A2 → centro A1/A2 (nunca C1); aislamiento OK. Estimador
`verify_estimator.py` 8/8 (incl. casos anti-azar). analyze 0 · test 94/94. "Desde cero" declarado sigue
saltando el examen → A1 (`_skipPlacement`, cliente, sin cambios). El límite adyacente A2↔B1 tiene algo de
borrosidad (inherente a un CAT breve; el usuario tiene override "empezar desde el inicio").

## UI del login/auth MODERNIZADA ✅ (2026-07-08 · solo capa visual, sin tocar lógica)
`auth_screen.dart` no tenía mockup (una de las 13 sin mockup, ver MOCKUP_GAP.md) → rediseñada con el
LENGUAJE VISUAL de los mockups: **tarjeta de auth centrada** (`ResponsiveCenter` maxWidth 460 → móvil
llena, desktop centrada, no estirada) con **hero de gradiente violeta** (`#7A6BF0→#6C5CE7→#5B4ECF`) +
**guacamayo animado** (`ParrotMascot` idle bob, halo suave, respeta reduce-motion) + título/subtítulo
blancos, y **cuerpo blanco** con Google (sombra suave) + divisor «o» + toggle + campos con fill claro
(`#F6F7FB`) + **pills de error/aviso** (rojo suave / violeta, con icono) + `PrimaryButton` 3D. Fondo con
halo radial violeta. **Motion sutil:** entrada fade+sube (jzRise, 560ms, reduce-motion-aware). Fuente
Nunito + tokens de `AppColors`. **NO se tocó la lógica** (`signInWithGoogle`/`signUpEmail`/flujo OAuth
intactos); solo `build`+widgets. i18n es/en/pt (0 strings nuevos). Verificado: analyze 0, test 94/94,
build web OK, smoke visual (render limpio, 0 errores de consola). **Verificación manual pendiente de Gian:**
Android (teclado no tapa campos) + desktop (tarjeta centrada) + login Google/email de punta a punta.

## Registro sin fricción — Google Sign-In + email (beta) ✅ código LIVE (2026-07-07 · solo cliente)
Ingeniería pura, sin migración. Auth-first (GA4). **Frente 1 · "Continuar con Google" (PWA):**
`ProgressRepository.signInWithGoogle()` → `signInWithOAuth(OAuthProvider.google, redirectTo: Uri.base.origin)`
(deploy-agnóstico: prod jezici.vercel.app, previews su URL). PKCE + `detectSessionInUrl` (default) → la
sesión llega al volver y `onAuthStateChange` (main.dart) enruta. Botón en `auth_screen` **solo web** (`kIsWeb`)
+ divisor «o» + formulario email. **Degrada con gracia:** si el proveedor no está configurado, el retorno trae
`?error=`/`#error=` → `initState` lo detecta y muestra `authGoogleError` («No se pudo continuar con Google.
Intenta con tu email.»), formulario email 100% usable; `try/catch` en el tap. i18n es/en/pt. **Frente 2 · email
fluido:** `signUpEmail` ahora devuelve `bool hasSession` — con **confirm-email OFF** hay sesión inmediata
(autoconfirm, ya funcionaba); con confirm-email ON (sin sesión) muestra `authCheckEmail` («revisa tu correo»)
y NO intenta setProfile/acceptLegal (evita fallo RLS). Magic-link NO añadido (requiere SMTP; confirm-OFF ya da
alta trivial). Verificado: analyze 0, test 94/94, build web OK, **smoke visual** (botón renderiza; retorno
`?error=` muestra el aviso amable sin romper). **Sin CSP externa:** la «G» se dibuja con tipografía (sin imagen
de host externo). **NO toca el resto del onboarding.**

### ⚠️ Frente 3 · Pasos MANUALES para Gian (dashboards — solo él puede) para ACTIVAR Google:
El código ya está LIVE; el botón funciona en cuanto se complete esto (cero redeploy). Callback de Supabase =
`https://wiauinufpbkmjlbqlkxo.supabase.co/auth/v1/callback`.
1. **Google Cloud Console** (console.cloud.google.com): crea/elige un proyecto → **APIs & Services → OAuth
   consent screen**: User type **External**; app name «Jezici», support email, developer email; **scopes**
   básicos `openid`, `.../auth/userinfo.email`, `.../auth/userinfo.profile`; en **App privacy policy** pega
   `https://jezici.vercel.app/privacy` y en **Terms of service** `https://jezici.vercel.app/terms` (ya LIVE,
   públicas); **PUBLICA la app** (botón «Publish app» → estado «In production») para NO whitelistear 50 testers.
2. **Google Cloud → Credentials → Create credentials → OAuth client ID → Web application**: en **Authorized
   JavaScript origins** añade `https://jezici.vercel.app` (y `http://localhost` si pruebas local); en
   **Authorized redirect URIs** añade EXACTAMENTE `https://wiauinufpbkmjlbqlkxo.supabase.co/auth/v1/callback`.
   Copia el **Client ID** y **Client secret**.
3. **Supabase → Authentication → Providers → Google**: **Enable**, pega Client ID + Client secret, **Save**.
4. **Supabase → Authentication → URL Configuration**: **Site URL** = `https://jezici.vercel.app`; en **Redirect
   URLs** añade `https://jezici.vercel.app/**` (y la URL de preview si usas previews).
5. **Beta sin fricción de email** — **Supabase → Authentication → Providers → Email**: desactiva **«Confirm
   email»** (OFF) para que el alta por email dé sesión inmediata (o, si prefieres verificación, déjalo ON: el
   código ya muestra «revisa tu correo»). Con confirm OFF necesitas 0 SMTP.
6. Prueba: abre jezici.vercel.app → «Continuar con Google» → elige cuenta → vuelve logeado al onboarding.

## UX: TTS global + responsive ✅ (2026-07-06 · solo cliente, sin migración)
Ingeniería pura (cero IA), determinista. 2 frentes:
- **F1 · Voz al tocar cualquier palabra META.** Antes el TTS de tile (Web Speech) solo estaba en
  word_bank/reorder (`tile_arrange_exercise`). Nuevo widget reutilizable `SpeakableText`
  (`core/speech/speakable_text.dart`): tap → `WordTts.speak` (usa `SpeechLang.tts` = idioma del curso
  activo) + ícono de altavoz, disparado por TAP (sin problema de unlock iOS), interrumpible, degrada con
  gracia (no-op sin síntesis). Cableado en: **match** (columna META, speak-on-tap sin ícono), **historias**
  (glosario `story_reader`), **tips** (ejemplo en reference + lesson_complete + notebook). Excluido a
  propósito: listening/MC (no delatar la respuesta). Verificado: analyze 0, test 94/94.
- **F2 · Responsive real (móvil→desktop).** Nuevo `core/ui/responsive_center.dart` (`ResponsiveCenter`:
  `Align`+`ConstrainedBox(maxWidth)` → **no-op en móvil** cuando ancho ≤ maxWidth, así el target principal
  queda PIXEL-idéntico; solo centra/capa en ancho). Aplicado: **mapa** (fondo cielo+escenografía full-bleed
  + columna de nodos centrada vía `dx0` → sin franjas vacías; en móvil `dx0≈0` = idéntico), **loop de
  lección** (scroll + botones + feedback bar, 560), **checkpoint** (560), **onboarding/placement/resultado**
  (`OnboardingScaffold`, 480), **ligas/perfil/tienda/historias** (640). Barras/appbars/fondos siguen
  full-width; solo se centra el CONTENIDO. Verificado: analyze 0, test 94/94, build web OK, smoke visual
  móvil (auth 280px sin romper). Diferido: screenshot de viewport ancho (el preview local topa en 280px).

## Onboarding + mapa — CORRECTITUD (feedback real) ✅ (mig 124 · 2026-07-06)
5 frentes, causa real diagnosticada con cliente real antes de tocar:
- **F1 · Fuera la pregunta de intensidad.** El onboarding ya NO pregunta frecuencia/intensidad;
  se fija `intensity=3` (ALTA) por defecto para todos en `create_plan`→`user_personality`
  (`onboarding_data.dart`), la 5ª pregunta se quitó de `personality_test.dart` (quedan las 4 de
  estilo de coach). Ajustable luego en Ajustes (el control sigue ahí). NO se hace backfill de filas
  existentes (no pisar preferencias reales). Sin romper usuarios.
- **F2 · "Empezar desde cero" salta el examen.** Si en el paso de nivel de arranque elige "desde
  cero" (`startLevelHint==0`), el onboarding SALTA ubicación+resultado → plan directo A1/U1
  (`_skipPlacement` en `onboarding_screen.dart`, back coherente). El test solo corre si elige
  "sé algo"/"buen nivel"/default.
- **F3 · Override en el resultado.** `PlacementResultView` ofrece "Prefiero empezar desde el inicio"
  (botón secundario, i18n es/en/pt, con diálogo de confirmación) → fija A1 y continúa. La elección
  del usuario manda sobre el algoritmo. Solo se muestra si el resultado no fue A1.
- **F4 · Nodos bajo el nivel de entrada en DORADO.** DIAGNÓSTICO (cliente real, `diag_map_golden.py`):
  el puente de `create_plan` YA marca `completed` las 61 lecciones de U1–U12 al ubicar en B1 (61/61,
  llegan por RLS) → el mapa las pintaba **verde-completado accesible, NO candado**; el "candado" era
  de cuentas pre-puente (antes de mig 077) o del primer paint sin progreso. El intent "verse DORADO"
  se resuelve en el CLIENTE: `learn_map_screen._stateFor` sube `completed`→`mastered` (dorado) para
  unidades con nivel CEFR < nivel de entrada del plan. **NO se marca `golden` en BD**: dispararía el
  logro "impecable" (`achievements`, v_golden≥1) sin haberlo ganado (deshonesto). Verificado: U1–U12
  dorado 61/61, U13 available, resto locked.
- **F5 · Placement ágil (subir/bajar rápido).** `placement_next` (mig 124) añade parada por
  SATURACIÓN: los extremos (todo correcto/todo mal) no generan reversals y llegaban al máximo (14
  ítems); ahora paran cuando la banda se clava en un extremo (`pin≥3`) con evidencia mínima (n≥8).
  Verificado cliente real (`diag_placement_agile.py`): fuerte→C1/8, débil→A1/8, intermedio→B1/8
  (antes 14). Estimador `jz_placement_level` intacto (verify_estimator 7/7, sin sobreestimación).
- **Verde:** analyze 0 · test 94/94 · build web OK; verify_placement_wiring/multi/pt VERDES con la
  nueva RPC. Pendiente (## Cola): **TTS-global + responsive** (prompt aparte).

## C1 COMPLETO en los 6 cursos ✅ LIVE (es→de/nl mig 128/129 · es→pt mig 130 · 2026-07-06)
**es→pt C1 (mig 130) cierra el último idioma → en/pt/fr/it/de/nl TODOS A1→C1.** pt-BR norma culta:
regência culta (assistir a, preferir X a Y), conectivos (não obstante/conquanto+subj/porquanto/
outrossim/todavia≠«todavía»), clivagem+denotativas + **colocação pronominal (próclise/ênclise/
MESÓCLISE: far-se-á, dir-lhe-ia, conceder-se-á)**, idiomatismos/registro, **futuro do subjuntivo**
+ período hipotético (3 tipos) + modalização (estaria de rumor), nominalização/voz passiva
(vendem-se)/orações reduzidas/preposições cultas (mediante/perante)/e-mail formal. 6 autores nativos
pt-BR + 2 revisores adversariales C1 (fixes reales: U29 «Antes que perdermos»→«percamos» [antes que
exige subj. presente]; U27 prompt de cloze revelaba «me deram»→reformulado). Verificado cliente real
(`verify_c1_chain.py pt`): 96/96 + 96/96 distractores, camina A1→C1 30 U, U24→U25, 30/30 lecciones C1,
audio 42/42, techo honesto (6 checkpoint, 0 exam level). **NO queda ningún curso sin C1.**

## C1 es→de + es→nl ✅ LIVE (mig 128/129 · 2026-07-06)
Cerrados 2 idiomas C1 con el pipeline probado (fr/it): 6 unidades c/u (order 25-30, encadenan B2→C1;
U24 desbloquea U25), **114 ítems (R36/W36/L24/S18 → L=67% S=50%)**, audio TTS 42/42 (tl=de/nl). Currículo
C1 REAL de cada idioma: **de** — präzise Wortwahl/Kollokationen/Register, Konnektoren (dennoch/gleichwohl/
zumal/ungeachtet+Gen/mithin), Modal-/Fokuspartikeln + Spaltsatz + Vorfeld, Redewendungen, Konjunktiv II/
Vermutungsmodalverben/Konjunktiv I, Nominalstil/Passiv/**erweiterte Partizipialattribute**/formelle E-Mail;
**nl** — het juiste woord, connectoren (niettemin/nochtans/niettegenstaande+2e nv/derhalve), modale/focus-
partikels + cleft (die/dat) + vooropplaatsing, idioom/register, conditionalis/vermoeden/**aanvoegende wijs
(moge/ware)**/alsof, nominalisatie/lijdende vorm/**beknopte bijzin (gezien/gelet op)**/formele e-mail.
6 profesores nativos IA + 2 revisores adversariales nativos por idioma (fixes reales: de U26 «somit…dennoch»
incoherente→«gleichwohl», U28 «Gang» ambiguo→«Fuß»; nl U30 «aanmerking» ambiguo→«gebruik», U29 «moge» orden
verbo-final). Guard de colisión (MC/listening exacto — `jz_near_match` no aplica a MC/listening, solo cloze/
translation). **TECHO HONESTO** (igual que en/fr/it): C1 receptivo/guiado se autocalifica, writing/speaking =
proxies deterministas, **0 examen/cert de nivel C1** (solo 6 checkpoint/idioma, verificado). **Verificado
cliente real (`verify_c1_chain.py de|nl`):** determinista 96/96 + distractores 96/96 (42501); CAMINA A1→C1
las 30 unidades (U24→U25, 30/30 lecciones C1); 0 cruces entre los 6 cursos; default(en) sin fuga; audio 42/42.
CI de C1 SUCCESS. **alemán y neerlandés: es→de/nl A1→C1 completo.** Diferido (## Cola): **es→pt C1** (pt topa
en B2; andamiaje idéntico listo: STAMP `('pt','c1')=…130`, grupo audio `pt-c1`, `verify_c1_chain.py pt`).

## Reglas del agente (siempre)
- Fuente de verdad = repo + BD + cliente real, NO los docs. Paso 0 de toda misión:
  ground truth (git log + introspección de BD) y corrige discrepancias en docs.
- "Verde" = gh run list SUCCESS en GitHub Actions real (reproduce el CI en local con
  .env vacío antes de declarar). Prohibido falso verde.
- NUNCA edites el buildCommand de vercel.json (cualquier edición rompe el deploy pre-build).
- Cliente REAL (anon Y authenticated, JWT real, nunca service_role). correct_answer = 42501.
- Aislamiento multicurso (en/pt/fr/it/de/nl): toda inserción confirma con cliente real que
  cada curso recibe lo suyo, 0 cruces; jz_active_course rutea.
- MC/listening: ningún distractor puede colisionar con el correcto bajo jz_normalize
  (minúsculas/tildes/umlaut) ni jz_near_match (dist-1). Guard obligatorio.
- Profundidad > amplitud: 1 frente impecable > varios a medias. Al tope de sesión, para,
  deja lo hecho perfecto, y escribe el retome EXACTO en la sección "## Cola" de CLAUDE.md.
- Contenido nuevo: calidad de profesor nativo, 4 habilidades (listening ~65% de R/W,
  speaking ~50%), audio tl correcto text-matched, instrucciones en español, checkpoints
  frescos, gate adversarial nativo.
- Al terminar: actualiza CLAUDE.md (estado + "## Cola"), FINDINGS.md, EFICACIA_CONTENIDO.md.
  Cierre: analyze 0, tests verdes, gh run list SUCCESS, deploy READY. Reporta en 1 línea.

## Cola (retome exacto — orden sugerido)
-3. **CONVERSAR · T3 ✅ social FÁCIL (mig 149, 2026-07-12).** @handle único + buscar + perfil público +
   sugerencias — todo 18+, server-side, aislamiento airtight intacto. **Diferido/re-encolado:** (a) **QR del
   @handle/código** (requiere paquete o pintar el QR a mano; el buscador + código copiable ya cubren el alta);
   (b) **abrir el CHAT directo desde el perfil público** cuando `relationship=friends` (el `connection_id` ya
   viaja en `get_public_profile`; hoy el perfil muestra "Ya son amigos" y se chatea desde la lista de Amigos —
   falta el botón "Chatear" que empuje `ChatScreen` con ese connection_id + name/color); (c) **exponer el toggle
   "Aparecer en búsqueda" también en Ajustes** (hoy vive en la pantalla de Amigos); (d) **editar el @handle**
   desde el chip "Tu @usuario" (RPC `claim_handle` ya soporta el cambio con rate 1/30d; falta el botón→gate en
   modo edición); (e) **purga programada de `social_search_log`** (crece sin cron; borrar filas > N días =
   diferido, sin cron hoy). NADA a medias: lo enviado está verificado con cliente real.
-2. **CONVERSAR · OLA 1 ✅ COMPLETA + ABIERTA (mig 148, 2026-07-11).** A3 notas de voz + A6 co-op HECHOS;
   `jz_social_access` = solo adulto 18+ (allowlist retirada, legal aprobado). **RE-ENCOLADO de la Ola 1:**
   (a) **F5 postales de voz** — nota de voz sobre un prompt diario a un amigo (sobre A3: reusar el grabador
   `voice_recorder_web.dart` + `send_voice_message`; añadir `daily_prompts` + tabla de postal); (b) **F7
   apuesta con amigo** — stake de oro sobre racha compartida (reusar `coop_challenges` + `gold_transactions`,
   escrow al crear, pago al ganador; guard anti-doble). **OLA 2 (retos/comunidad async ampliada)** y **OLA 3
   (audio EN VIVO/salas = LiveKit — banner "próximamente" ya puesto)** siguen pendientes; ver CONVERSAR_FASE2.md.
   Nota UI: **QR del código** de amigo no se añadió (requiere paquete/asset; el código copiable ya funciona) —
   opcional a futuro. Purga programada del bucket `voice-notes` (retención → borrado tras N días) = diferido
   (sin cron hoy; borrado solo service_role).
-1. **PLACEMENT · 4 HABILIDADES (retome exacto, misión propia — NO enviar a medias):** añadir LISTENING
   y SPEAKING al examen de ubicación en los 6 cursos. Pasos: (a) AUTORAR banco L/S por curso×nivel —
   listening = MC "escucha y elige" con `payload.say` (frase corta calibrada al CEFR) + 3 opciones
   guardadas anti-colisión (patrón `gen_placement_multi.py`), speaking = `speaking_read_aloud` con frase
   calibrada; mínimo 3 L + 2 S por nivel×curso (en 5 niveles, resto 4) ≈ 130 ítems, tag `placement`;
   (b) AUDIO TTS de los listening con `gen_audio_missing.py` (grupo por curso, tl correcto, text-matched);
   (c) CLIENTE: `course_placement_screen`/`placement_test.dart` hoy solo renderiza MC → añadir botón de
   audio (reusar `AudioPlayButton`) para listening y reconocedor (`SpeechRecognizer` + `SpeechLang.stt`)
   para speaking, degradación honesta si el mic no está (saltar speaking, no fallarlo); (d) RPC
   `placement_next`: intercalar las 4 skills (ciclo R→L→W→S) + salida `skill_levels` POR HABILIDAD real
   (por-skill con evidencia ≥3 ítems, fallback al global si no llega — honesto, no global copiado);
   (e) VERIFICAR: `verify_placement_serious.py` + probe de cobertura (las 4 skills aparecen) en ≥2
   cursos, azar→bajo, personas→su nivel, aislamiento. (f) El RE-READ pedagógico NATIVO de los 349 ítems
   existentes (workflow 6 profesores + 2 adversariales, como los cursos) también pendiente aquí.
0b. **Mapa · acceso rápido para REPASAR unidades pasadas (encolado 2026-07-12):** el botón de salto
   "Ir a mi lección" ya existe; falta un acceso limpio para saltar a unidades YA completadas (p.ej.
   long-press en el botón de salto → sheet con lista de unidades completadas → animateTo a esa unidad,
   o chips por nivel CEFR). Solo scroll/UI, cero lógica. No se metió a medias en la misión del mapa.
0. **Pulido UI restante (tras el BARRIDO DE FIDELIDAD 2026-07-10 — Certificado y Premium ya i18n/fieles):**
   (a) variante MINI-3D para botones compactos inline (tienda `tienda_screen.dart:202`, congelador
   `streak_screen.dart:296`); (b) **i18n de pantallas secundarias** — títulos/cuerpos en español
   hardcodeado: Inmersión (`immersion_screen.dart:24`), Historia/Glosario (`story_reader_screen.dart:107/202`),
   Cuaderno (`notebook_screen.dart:22`), Métricas, Mi plan (`mi_plan_screen.dart:36+`), Simulacros, Repaso
   (`reference_screen.dart:73+`), Notificaciones, intro/player de examen (`level_exam_intro_screen.dart:42+`),
   diálogos de Ajustes (export/delete/logout `settings_screen.dart:842+`); (c) armonizar sombras SUAVES
   (blur 16–32) que conviven con la dura de la casa (perfil `profile_screen.dart:162+`, práctica, ligas,
   your_plan); (d) **Simulacro hub visual (Simulacro.dc)**: header navy + 4 section-cards + contador "0 de 4"
   — REQUIERE el motor de simulacros para no ser botones muertos (Fase 2, no solo visual); (e) P2 finos
   restantes de Aprender (certificado de cima labio 3D/subtítulo, sheen del mastered, etiquetas de nodos) y
   Lección (líneas-guía, copy combo en franja); (f) Matix: bloque de progreso + CTA por tono cuando el motor
   exponga los datos.
> Estado de niveles hoy (verificado en BD): **en/pt/fr/it/de/nl TODOS A1–C1** (los 6 cursos a C1;
> C2 no sembrado en ninguno). Andamiaje probado 15× (…de C1, nl C1, pt C1): generador
> `gen_course.py <code> <a1|a2|b1|b2|c1>` (soporta pt/fr/it/de/nl; DIFF c1=0.84), audio `gen_audio_missing.py <code>-<lvl>`
> (grupos `<code>-c1` listos), verificadores `verify_b1_chain.py`/`verify_b2_chain.py`/**`verify_c1_chain.py`** `<code>`. STAMPS c1 en `gen_course.py`.
1. **C1 en los 6 cursos ✅ COMPLETADO (mig 126/127 fr/it · 128/129 de/nl · 130 pt).** Ya NO queda ningún
   idioma sin C1. Pipeline (por si se reusa para C2): 6 autores nativos por idioma + 2 revisores adversariales →
   `gen_course.py <code> c1` → apply → `gen_audio_missing.py <code>-c1` → `verify_c1_chain.py <code>`.
   **TECHO HONESTO (NO violar):** C1 = R/L/gramática/vocab se autocalifican; writing/speaking = proxies
   deterministas. **NO examen ni certificado de nivel C1** (Fase 2). Los cursos escalera no tienen exams `level`
   → el techo es automático (verificado los 6: solo 6 checkpoint C1, 0 exam level). Siguiente techo real = **C2**
   (no sembrado en ninguno; requeriría evaluación de producción libre = Fase 2 con IA).
5. **Pulidos onboarding/placement** (código): cap de la meta al tope real del curso ✅ (mig 118). **Placement a nivel
   REAL ✅ (mig 122/123, 2026-07-05):** bancos fr/it/de/nl ampliados a B1+B2 y pt a B2 (7R MC + 7W cloze/nivel);
   `placement_next` (course-scoped) ya sube el techo → un B1/B2 sale B1/B2 (no A2). Verificado cliente real
   (`verify_placement_multi.py`/`verify_placement_pt.py`): personas A1→A1…B2→B2, avanzado→B2, aislamiento, 56/56
   determinista. **Placement SERIO anti-azar ✅ (mig 131, 2026-07-08):** el azar (1/3 por MC) ya NO infla —
   estimador guess-aware + arranque clampeado a A2 + examen más largo; azar→A1 (0% B2/C1), persona→su nivel.
   Verificado con el FLUJO REAL (`verify_placement_serious.py`/`repro_placement_random.py`, cliente JWT).
   **4 HABILIDADES en placement ✅ para en+pt (mig 135/136, 2026-07-09):** banco L/S en+pt (27 listening MC con
   audio + 18 speaking read-aloud sin opciones), RPC v3 rotación R→L→W→S + `p_exclude_skills` + skill_levels
   por habilidad demote-only; cliente renderiza audio y mic (saltable). Verificado `verify_placement_4skills.py`
   TODO VERDE. **Banco L/S fr/it/de/nl ✅ (mig 139, 2026-07-10):** los 6 cursos miden las 4 habilidades
   con perfil por-skill real; `verify_placement_4skills.py` corre los 6 (persona determinista B2/B1
   diferenciada 4/4, azar 0 altas, aislamiento). Pendiente además:
   nombre real de la unidad de entrada por curso en `PlacementResultView` (hoy rótulo es→en).
   **Barrido de colisiones MC/listening ✅ (mig 117).**
7. **COMPRENSIÓN reading/listening (P2 EVAL_AUDIT §7) — retome exacto:** it A1 ✅ CERRADO (mig 145, +30
   ítems comprensión POOL). Repetir el MISMO patrón para los otros focos de vocab-suelto A1/A2 (censo:
   **de A1 35% · fr A2 26% · nl A1 29% · fr A1 19% · it A2 · pt A1 13%**): copiar `gen_it_a1_comprehension.py`
   → cambiar COURSE + autorar 3 reading-inferencia + 2 listening-diálogo→pregunta por unidad (6 unidades/nivel),
   revisor adversarial NATIVO por idioma (agente CEFR), tags `unidadN`+`comprension`+skill (POOL, no cablear a
   lecciones), `gen_audio_missing.py <code>-<lvl>` para el audio, verificar con `verify_cert_chain.py <code>` +
   censo antes/después + HEAD audio + 0 colisiones. **Umbral sano definido:** el pool ya aleatoriza (≥6× el pick);
   el objetivo NO es densidad sino BAJAR el vocab-suelto <20% y meter comprensión/inferencia real. Densificar
   pt B2/C1 (36R/24L) es secundario (aleatoriza, solo fino vs en). NADA a medias: cerrar por curso×nivel.
6. **Diferidos menores:** historias B2 por idioma (B1 ✅ mig 125); imágenes referenciales
   fr/it/de/nl (hoy solo es→en A1/A2); copy en-first fuera del onboarding (`missionMainDescription` «100 palabras del
   inglés», `errorReviewWhy*`); **cert de nivel por curso ✅ (mig 144: los 6 cursos certifican A1–B2; C1/C2 =
   techo honesto Fase 2 IA)**; cron de cierre de ligas; Sentry DSN + sello JZ_BUILD (requieren a Gian, ver
   secciones abajo).

## Qué es
App de aprendizaje de idiomas (estilo Duolingo). **Flutter (web PWA)** + **Supabase**
(Postgres + RLS + RPCs SECURITY DEFINER) + **Vercel** (deploy del web). Repo
`github.com/GianPierooo/Jezici`, deploy `jezici.vercel.app`.
- 6 cursos: **es→en** (A1–C1), **es→pt** (A1–B2), **es→fr** (A1–C1), **es→it** (A1–C1),
  **es→de** (A1–B2) y **es→nl** (A1–B2). Curso activo por usuario
  (`jz_active_course`). Selector en Ajustes.
- Loop: lección → ejercicios (9 tipos) → grading **server-side** → XP/oro/vidas →
  checkpoints (≥80%) → exámenes de nivel + certificados. Práctica/SRS, logros, ligas
  semanales, racha, Matix (notificaciones), onboarding con placement.
- **Grading 100% server-side** (`grade_item`, mig 055): el cliente nunca recibe la
  respuesta antes de responder. `correct_answer` revocado (lectura directa → `42501`).

## Pilotos es→fr + es→it (A1 + A2) — ✅ LIVE (mig 094–098 · 2026-07-02)
- **2 cursos NUEVOS, A1 Y A2 sembrados y verdes:** **es→fr** (course `…0003`, lang `fr`/Français) y
  **es→it** (course `…0004`, lang `it`/Italiano), ambos `is_active`. **A1 (mig 094/095) + A2 (mig
  097/098) completos** con el molde validado es→pt: 6 unidades por nivel (A1 order 1-6, A2 order
  **7-12** → encadenan; `submit_checkpoint` desbloquea la unidad con order mayor del MISMO curso →
  **gating A1→A2 automático y course-scoped**), 4 lecciones + checkpoint fresco + examen por unidad.
  **115 ítems por nivel** (460 fr+it), 4 habilidades balanceadas (A1 fr R38/W36/L23/S18 L=62%/S=49%;
  A2 fr/it R36/W36/L25/S18 L=69%/S=50%). Temas A2: passé composé/passato prossimo (avoir/avere→être/
  essere+concordancia), futur/futuro, viaje, comer-fuera/comparativos, imparfait/imperfetto+pronombres
  COD/diretti, salud/consejos («avoir mal à»/«avere mal di»). Autorado por profesores nativos IA
  (fr/it, NO traducción mecánica) + **validación adversarial nativa por nivel**: A1 fr 1 error real
  (`midi et demie`→`midi et demi`), it 0; **A2 fr 0 errores + 2 pulidos, it 0 errores + 2 pulidos**
  (todos aplicados). **Audio TTS** (`gen_audio_missing.py` tl=fr/it): fr A1 41 + A2 43, it A1 43 +
  A2 43 = **170/170** en Storage, texto-emparejado. Generador reutilizable **PARAMETRIZADO POR NIVEL**
  `tools/content/gen_course.py <code> <a1|a2>` (lee `<code>_<level>_u*.json`, ordena por `unit.order`,
  ids uuid5 sin colisión entre niveles/cursos; corrigió también el título it A1 «Unité»→«Unità»).
  Selector de Ajustes los muestra (banderas 🇫🇷/🇮🇹; `label`/nombre desde DB).
- **AISLAMIENTO multicurso (el riesgo #1, ya roto una vez con pt mig 064→072) — VERIFICADO con
  cliente real** (`verify_new_course.py fr|it`, JWT real, nunca service_role): **0 `lesson_items`
  cruzan los 4 cursos**; determinista fr 97/97 + it 97/97 correctos aceptados y 97/97 distractores
  rechazados (`correct_answer` 42501); `set_active_course`→`create_plan`/`start_practice` sirven
  SOLO el curso activo; usuario default(en) NO recibe fr/it; cadena lección(100%)+checkpoint(≥80%)
  por curso; audio HEAD 200. **A2 (`verify_a2_chain.py fr|it`): CAMINA las 12 unidades EN ORDEN con
  cliente real** (complete_lesson×lección + submit_checkpoint×checkpoint) → prueba el gating A1→A2
  end-to-end (U6 desbloquea U7), 30/30 lecciones A2 completadas, determinista A2 97/97, audio A2 43/43.
  **Cursos existentes INTACTOS:** `verify_chain` (es→en A1→B2) y `verify_pt_chain` (es→pt A1→B1
  multicurso) verdes tras cada tanda. analyze 0 · test 89/89.
- **Fix de fondo `create_plan` (mig 096):** `create_plan` **hardcodeaba** el curso más-antiguo-activo
  (`courses where is_active order by created_at limit 1` = es→en) IGNORANDO el curso activo → con
  >1 curso sembraba el plan/progreso/unidad-de-entrada en el curso EQUIVOCADO. Ahora usa
  `jz_active_course()`. **Cero regresión en es→en** (usuario nuevo sin fila `user_active_course` →
  fallback al mismo más-antiguo-activo=en). El onboarding actual NO llama `set_active_course` (elige
  curso en Ajustes vía `start_course`), así que no afloraba en la app, pero el fix es correcto y
  future-proof. `placement_next` ya era course-aware (recibe `p_course`); **banco de placement
  fr/it/de/nl ✅ (mig 110, 2026-07-03)** → ya ubica en su nivel real (ver fila **Test de ubicación**).
- **B1 es→fr ✅ LIVE (mig 113, 2026-07-03):** 6 unidades (order 13-18, encadenan A2→B1; U12 desbloquea
  U13), **114 ítems (R36/W36/L24/S18 → L=67% S=50%)**, audio TTS tl=fr **42/42**. Currículo B1 REAL:
  **subjonctif présent** (Il faut que/bien que…), **futur & conditionnel** (-ai vs -ais, si+imparfait),
  **pronoms relatifs** (qui/que/dont/où), **accord du participe passé** (être/avoir+COD antepuesto/
  pronominales), **discours indirect** (que/si/ce que + concordancia de tiempos), **pronoms compléments**
  (le/lui/y/en + doble pronombre). 6 profesores nativos IA + **rebalanceo/revisión adversarial nativa**
  (fixes reales: «pour qu'elle» élision, `accepted` que aceptaba «ou» por «où» removido, «s'il»,
  distractores audibles prise/mise para accord, «si j'aurais» como distractor correcto). **Verificado
  cliente real (`verify_b1_chain.py fr`):** determinista 96/96 + 96/96 distractores (42501); **CAMINA
  A1→B1 las 18 unidades** (U12→U13, 30/30 lecciones B1); **0 lesson_items cruzan los 6 cursos**;
  default(en) sin fuga; audio 42/42. **es→de B1 ✅ (mig 111).**
- **B1 es→it ✅ LIVE (mig 114, 2026-07-05):** 6 unidades (order 13-18, encadenan A2→B1; U12 desbloquea
  U13), **114 ítems (R36/W36/L24/S18 → L=67% S=50%)**, audio TTS tl=it **42/42**. Currículo B1 REAL:
  **congiuntivo presente** (parli/prenda/finisca + irregulares sia/abbia/faccia/vada/venga; Penso/È importante/
  benché/a meno che, contraste indicativo/congiuntivo), **futuro semplice + condizionale + periodo ipotetico I**
  (parlerò/sarò/vorrei/dovresti; Se piove resto), **pronomi relativi** (che/cui + prep. a-di-in-con-per/il quale/
  il cui/chi/dove), **concordanza del participio** (essere→sujeto è andata/sono uscite; avere+lo/la/li/le antepuesto
  l'ho vista/li ho comprati), **discorso indiretto** (dice/ha detto che + concordanza imperfetto/trapassato/
  condizionale composto; chiedere se; dire di+inf; deícticos), **pronomi combinati, ci e ne** (ci/ne partitivo;
  me lo/te lo/ce lo/glielo/gliene; ce n'è). 6 profesores nativos IA + **revisión adversarial nativa** (fixes reales:
  U13 listening casi-homófono finisca/finisce reescrito, U17 «tornare il giorno prima»→«il giorno dopo», U18
  «me lo presto»→«te lo presto» lógico + near-homófonos me lo/te lo/ce lo y reorder ambiguo rehechos). **Verificado
  cliente real (`verify_b1_chain.py it`):** determinista 96/96 + 96/96 distractores (42501); **CAMINA A1→B1 las 18
  unidades** (U12→U13, 30/30 lecciones B1); **0 lesson_items cruzan los 6 cursos**; default(en) sin fuga; audio 42/42.
- **B2 es→fr ✅ LIVE (mig 20260705120119, 2026-07-05):** 6 unidades (order 19-24, encadenan B1→B2; U18 desbloquea
  U19), **114 ítems (R36/W36/L24/S18 → L=67% S=50%)**, audio TTS tl=fr **42/42**. Currículo B2 REAL: **subjonctif passé**
  (que j'aie fini/qu'elle soit venue; regret/antériorité), **conditionnel passé + irréel du passé** (j'aurais dû;
  Si+plus-que-parfait→conditionnel passé) **& concordance des temps**, **discours indirect au passé avancé**
  (présent→imparfait, passé→plus-que-parfait, futur→conditionnel; ce que/ce qui/si; impératif→de+inf; la veille/le
  lendemain), **participe présent, gérondif & adjectif verbal** (parlant invariable vs fatigant/fatiguant; en+ant),
  **connecteurs B2** (bien que/pour que/à condition que+subj vs alors que/tandis que+ind; cependant/par conséquent/
  en revanche), **voix passive avancée + mise en relief** (on/se faire/pronominale de sens passif; c'est…qui/ce que…
  c'est). 6 profesores nativos IA + **revisión adversarial nativa** (fixes reales: subjonctif con sujeto idéntico→
  infinitivo «d'avoir fini», élision «ce qu'» ante je removida, 2 word_bank/reorder triviales barajados). **Verificado
  cliente real (`verify_b2_chain.py fr`):** determinista 96/96 + 96/96 distractores (42501); **CAMINA A1→B2 las 24
  unidades** (U18→U19, 30/30 lecciones B2); **0 lesson_items cruzan los 6 cursos**; default(en) sin fuga; audio 42/42.
- **B2 es→it ✅ LIVE (mig 20260705120120, 2026-07-05):** 6 unidades (order 19-24, encadenan B1→B2; U18 desbloquea
  U19), **114 ítems (R36/W36/L24/S18 → L=67% S=50%)**, audio TTS tl=it **42/42**. Currículo B2 REAL: **congiuntivo
  imperfetto/trapassato** (fossi/avessi/facessi; avesse+participio; concordanza «Pensavo che fosse»), **periodo
  ipotetico II/III + condizionale passato** (Se avessi tempo verrei; Se avessi studiato avrei superato; regret/
  futuro nel passato/notizia non confermata), **forma passiva** (essere+participio+accord/venire tiempos simples/
  andare=dovere essere/si passivante), **discorso indiretto avanzado** (concordanza completa presente→imperfetto,
  passato→trapassato, futuro→condizionale composto; domande indirette+congiuntivo; di+inf; deícticos), **connettivi
  B2** (benché/sebbene/purché/a meno che+congiuntivo vs anche se/mentre/siccome+indicativo; tuttavia/quindi/di
  conseguenza/inoltre), **nominalizzazione + relativi avanzati + frasi scisse** (infinito sostantivato, -zione/-mento;
  il quale/i cui/ciò che/chi; È…che/È…a; registro cortés). 6 profesores nativos IA + **revisión adversarial nativa**
  (fixes reales: reorder run-on «di conseguenza» reescrito con punto y coma, colisión cloze «i cui»/«il cui» dist-1
  → convertido a word_bank, 2 accepted femeninos «ricca»/«partita», 1 trivial reorder barajado). **Verificado cliente
  real (`verify_b2_chain.py it`):** determinista 96/96 + 96/96 distractores (42501); **CAMINA A1→B2 las 24 unidades**
  (U18→U19, 30/30 lecciones B2); **0 lesson_items cruzan los 6 cursos**; default(en) sin fuga; audio 42/42.
  **italiano es→it: A1→B2 completo.**
- **C1 es→fr ✅ LIVE (mig 126) + C1 es→it ✅ LIVE (mig 127), 2026-07-05:** 6 unidades c/u (order 25-30, encadenan
  B2→C1; U24 desbloquea U25), **114 ítems (R36/W36/L24/S18 → L=67% S=50%)**, audio TTS 42/42. Currículo C1 REAL:
  precisión y matiz léxico (le mot juste / il termine esatto, registros, colocaciones), argumentar y persuadir
  (connecteurs: néanmoins/quand bien même/dans la mesure où · nondimeno/per quanto+cong/dal momento che), énfasis y
  mise en relief (c'est…que/ce dont…c'est · frasi scisse è…che/è…a, inversion/anteposizione, litote), modismos y
  registro (tomber dans les pommes/tirer son épingle du jeu · in bocca al lupo/tirare a campare; soutenu/familier),
  hipótesis y modalidad avanzada (à supposer que/pour peu que+subj, conditionnel journalistique · qualora/purché+cong,
  condizionale giornalistico, congiuntivo in relative), lengua académica/profesional (nominalisation, il convient de/
  il ressort de · si ritiene che/va rilevato che, voz pasiva, conectores académicos, email formal). 6 profesores nativos IA
  + 2 revisores adversariales por idioma (fixes reales: fr accepted «a»/«qu'» agramaticales + rebalanceo U29 + hueco cloze U30;
  it mezcla de idiomas U25 + congiuntivo `dobbiamo`→`debba` U29). **Verificado cliente real (`verify_c1_chain.py fr|it`):**
  determinista 96/96 + 96/96 distractores (42501); **CAMINA A1→C1 las 30 unidades** (U24→U25, 30/30 lecciones C1);
  0 cruces entre los 6 cursos; default(en) sin fuga; audio 42/42. **TECHO HONESTO** (igual que en): C1 receptivo/guiado
  se autocalifica (writing/speaking = proxies deterministas), **sin examen ni certificado de nivel C1** (Fase 2) →
  verificado: fr/it C1 solo 6 checkpoint, 0 exam `level`, 0 certificates. **fr y it: es→fr/it A1→C1 completo.**
- **Diferido (retome del piloto):** C1 es→de/nl/pt (andamiaje listo; ver "## Cola" ítem 1); cablear onboarding fr/it-específico (el onboarding ya deja elegir curso META,
  el placement corre por curso); imágenes fr/it; cert de nivel; C1 fr/it.

## Pilotos es→de + es→nl (A1 + A2) — ✅ LIVE (mig 100/101/104/105 · 2026-07-03)
- **2 cursos NUEVOS (5º y 6º), A1 Y A2 completos:** **es→de** (course `…0005`, lang `de`/Deutsch) y
  **es→nl** (course `…0006`, lang `nl`/Nederlands), ambos `is_active`. Molde validado es→fr/it:
  6 unidades por nivel (A1 order 1-6, A2 order 7-12 → encadenan; gating A1→A2 automático), 4
  lecciones + checkpoint fresco + examen por unidad. **115 ítems por nivel** (460 de+nl · R36/W36/L25/S18 →
  L=69% S=50%). Autorados por **workflow ultracode** (profesores nativos IA + revisores adversariales
  nativos por nivel). **Audio TTS** tl=de/nl: A1 43 + A2 43 = **86/86 cada idioma** en Storage.
  Temas A2 (mig 104/105): Perfekt/Perfectum (haben/hebben→sein/zijn+concordancia), futuro (Präsens+werden /
  gaan+zullen), viaje, comer fuera/comparativo (als/dan, größer/groter), Präteritum/imperfectum
  (war-hatte / was-had)+descripción, cuerpo+salud (wehtun dativo / hoofdpijn compuesto, consejos sollen/moeten).
  **Revisión adversarial A2: de 0 ❌ + 1 pulido (variante de orden TeKaMoLo en accepted); nl 0 ❌ + 0 ⚠️.**
- **Gramática real por idioma:** de — género der/die/das, **edad con SEIN** («Ich bin 20 Jahre
  alt», NO haben), sustantivos con mayúscula, acusativo ein→einen, du/Sie, ß/ä/ö/ü (tolerancia
  ss/ae/oe/ue en `accepted`); nl — **de/het** (het water/brood/station…), **edad con ZIJN** («Ik
  ben 20 jaar oud»), diminutivos -je, orden V2. Revisión adversarial: de 2 ❌ menores (distractores
  de word_bank), nl 3 reales (calco «Ik ben goed»→«Het gaat goed»; «Ik hou van…» no enseñado;
  distractor ambiguo) — **todos corregidos**.
- **AISLAMIENTO de los 6 cursos (el riesgo #1) — VERIFICADO cliente real** (`verify_new_course.py
  de|nl` A1 + `verify_a2_chain.py de|nl` A2, JWT): **0 `lesson_items` cruzan los 6 cursos**
  (en/pt/fr/it/de/nl); determinista A1 y A2 de/nl 97/97 correctos + 97/97 distractores (42501);
  `set_active_course`→`create_plan`/`start_practice` sirven SOLO el curso activo; default(en) NO
  recibe de/nl; **A2: CAMINA las 12 unidades en orden (U6 desbloquea U7, 30/30 lecciones A2), gating
  A1→A2 end-to-end**; audio HEAD 200. **Cursos existentes INTACTOS** (verify_chain en · verify_pt_chain pt).
  Banderas 🇩🇪/🇳🇱 + `SpeechLang` de-DE/nl-NL (TTS/reconocedor). analyze 0 · test 91/91.
- **B1 es→de ✅ LIVE (mig 111, 2026-07-03):** 6 unidades (order 13-18, encadenan A2→B1; U12 desbloquea
  U13), **114 ítems (R36/W36/L24/S18 → L=67% S=50%)**, audio TTS tl=de **42/42**. Currículo B1 REAL:
  **Konjunktiv II** (würde/hätte/wäre, cortesía/deseos/consejos), **Nebensätze & Konnektoren**
  (weil/dass/obwohl + deshalb/trotzdem, orden verbo-final), **Relativsätze** (der/die/das/den/dem),
  **Passiv** (werden + Partizip II, wurde), **Verben mit Präposition + Genitiv** (warten auf, Angst vor,
  des Buches), **Konjunktiv II der Vergangenheit** (hätte/wäre + Partizip, condicional irreal). Autorado
  por 6 profesores nativos IA + **rebalanceo/revisión adversarial nativa** (distractores de par-mínimo,
  tolerancia ss↔ß/ae-oe-ue↔umlaut, haben/sein en Konjunktiv II, Genitiv -s). `gen_course.py de b1`
  (STAMPS/DIFF b1) + robustez `topic` faltante. **Verificado cliente real (`verify_b1_chain.py de`):**
  determinista 96/96 correctos + 96/96 distractores (42501); **CAMINA A1→B1 las 18 unidades** (U12→U13,
  30/30 lecciones B1); **0 lesson_items cruzan los 6 cursos**; default(en) sin fuga; audio HEAD 42/42.
- **B2 es→de ✅ LIVE (mig 115, 2026-07-03):** 6 unidades (order 19-24, encadenan B1→B2; U18 desbloquea
  U19), **114 ítems (R36/W36/L24/S18 → L=67% S=50%)**, audio TTS tl=de **42/42**. Currículo B2 REAL:
  **Konjunktiv I** (indirekte Rede formal: er habe/sei/werde), **Passiv erweitert** (mit Modalverben,
  Zustandspassiv, sich lassen/sein+zu+Inf), **Partizip als Adjektiv** (Partizip I/II attributiv +
  declinación), **Konnektoren B2** (je…desto, sowohl…als auch, weder…noch, nicht nur…sondern auch),
  **Nominalisierung + Funktionsverbgefüge** (das Lesen; Entscheidung treffen, in Frage stellen),
  **Genitiv-Präpositionen + Präpositionaladverbien** (wegen/trotz/während + darauf/worüber). 6 profesores
  nativos IA + **rebalanceo/revisión adversarial nativa** (Konjunktiv I audible, «Ein reparierter Auto»→
  «repariertes» [neutro] en accepted, FVG treffen≠machen, Genitiv -s, distractores audibles). **Verificado
  cliente real (`verify_b2_chain.py de`):** determinista 96/96 + 96/96 distractores (42501); **CAMINA A1→B2
  las 24 unidades** (U18→U19, 30/30 lecciones B2); **0 lesson_items cruzan los 6 cursos**; default(en) sin
  fuga; audio HEAD 42/42. **Fix de colisión:** MC «Das Lesen»/«Das lesen» difería solo en mayúscula y
  `jz_grade` pasa a minúsculas (near-match NO aplica a MC, sí el lowercase) → aceptaba el distractor;
  corregido (Lesen/Lesung/Leser) + guard norm-exacto en TODOS los B2 (0 colisiones, 92/92 distractores
  rechazados) + `gen_course.py` robusto ante `prompt` faltante. **alemán es→de: A1→B2 completo.**
- **B1 es→nl ✅ LIVE (mig 112, 2026-07-03):** 6 unidades (order 13-18, encadenan A2→B1; U12 desbloquea
  U13), **114 ítems (R36/W36/L24/S18 → L=67% S=50%)**, audio TTS tl=nl **42/42**. Currículo B1 REAL:
  **conditionalis** (zou + inf: cortesía/deseos/hipótesis), **bijzinnen & voegwoorden** (omdat/dat/hoewel/
  als + daarom/dus, werkwoord achteraan), **relatieve bijzinnen** (die/dat/wie/waar), **lijdende vorm**
  (worden/werd + voltooid deelwoord, door), **vaste voorzetsels + «om…te»** (wachten op, denken aan,
  houden van), **voltooid verleden + conditionalis verleden** (had/was + deelwoord; zou hebben/zijn +
  deelwoord). 6 profesores nativos IA + **rebalanceo/revisión adversarial nativa** (als=voegwoord no
  voornaamwoord, «maar toch», gereisd por 't kofschip, distractor «kok»→«koken» dist-2, listening de
  «om…te» con distractores audibles, guard de colisión MC). **Verificado cliente real (`verify_b1_chain.py
  nl`):** determinista 96/96 + 96/96 distractores (42501); **CAMINA A1→B1 las 18 unidades** (U12→U13,
  30/30 lecciones B1); **0 lesson_items cruzan los 6 cursos**; default(en) sin fuga; audio 42/42.
- **B2 es→nl ✅ LIVE (mig 116, 2026-07-05):** 6 unidades (order 19-24, encadenan B1→B2; U18 desbloquea
  U19), **114 ítems (R36/W36/L24/S18 → L=67% S=50%)**, audio TTS tl=nl **42/42**. Currículo B2 REAL:
  **indirecte rede** (tijdsverschuiving was/had/zou, dat/of), **lijdende vorm gevorderd** (met modalen,
  onpersoonlijk «er wordt/werd», perfectum «is/zijn + deelwoord» sin «geworden», agente «door»),
  **deelwoord als bijvoeglijk naamwoord** (tegenwoordig -end/-ende vs voltooid ge-…-d/-t/-en + verbuiging
  -e/-Ø según de/het/een), **complexe voegwoorden** (niettemin/desondanks/daarentegen + inversie;
  zowel…als/noch…noch; hoewel/ofschoon werkwoord achteraan), **nominalisatie** (het+infinitief; werkwoord→
  zelfstandig naamwoord met -ing/-heid), **«zou hebben/zijn + deelwoord»** (irrealis del pasado) + register
  u/je. 6 profesores nativos IA + **rebalanceo/revisión adversarial nativa** (colisiones norm-exactas
  corregidas: «moest»/«moet» → «moest/wilde/kon»; «Hoewel het regende»→«hard regende»; listening casi-
  homófonos rediseñados «bleef zij»→«werd zij boos», «koken»/«koker»→«wonen»; 2 cloze sin hueco corregidos;
  verbuiging het/een verificada). **Verificado cliente real (`verify_b2_chain.py nl`):** determinista 96/96 +
  96/96 distractores (42501); **CAMINA A1→B2 las 24 unidades** (U18→U19, 30/30 lecciones B2); **0 lesson_items
  cruzan los 6 cursos**; default(en) sin fuga; audio HEAD 42/42. **neerlandés es→nl: A1→B2 completo.**
- **Diferido:** imágenes; onboarding de/nl-específico; C1+ de/nl.

## Stack / mecánica clave
- **Contenido es DB-driven**: los seeds/fixes son migraciones → quedan LIVE al aplicar,
  sin deploy de la app. Audio en Supabase Storage (`audio/items/<id>.mp3`), independiente de Vercel.
- **Migraciones**: `tools/content/apply_sql.py <archivo.sql>` (Management API, registra en
  `schema_migrations`). Secretos desde `../../.env` (gitignored) — **nunca** hardcodear
  `service_role`/`sbp_` (push protection de GitHub rechaza).
- **Deploy**: push a `main` → Vercel reconstruye (clona Flutter, `flutter build web`).
  Config en `vercel.json` (dart-defines SUPABASE_URL/ANON_KEY + JZ_BUILD=commit sha).

## Deploy de Vercel — RESUELTO ✅ (2026-06-23, fix `68266d3`)
- **El "bloqueo" NO era billing: era una regresión de `vercel.json`.** El commit
  `25f49c9` (19-jun) añadió `--dart-define=JZ_BUILD=$VERCEL_GIT_COMMIT_SHA` al
  `buildCommand`. Desde ahí TODOS los deploys daban **ERROR instantáneo pre-build, sin
  logs** (`buildingAt==ready`). **Confirmado por aislamiento:** revertir el
  `buildCommand` a la config **byte-idéntica a 7e26824** (sin ese `--dart-define`) →
  deploy **READY en ~152 s**. Cualquier variante con el flag JZ_BUILD (incluida
  `$(git rev-parse …)`) era rechazada pre-build → **no reintroducir el sello en el
  buildCommand**. Producción de nuevo LIVE con TODO el código nuevo (audio + seguridad).
- **Sello `JZ_BUILD` — lado-app LISTO, inyección BLOQUEADA en vercel.json (sigue `dev`).**
  ⚠️ **Re-confirmado 2026-06-24:** **CUALQUIER** edición del `buildCommand` de vercel.json (incluso
  añadir `&& bash ../scripts/stamp_build.sh`, SIN `$`) → deploy **ERROR instantáneo pre-build, 0 logs**
  (commit 0389b1a). El buildCommand debe quedar **byte-idéntico** al string vivo. No basta con evitar
  `$VAR`/`$()`: NO TOCAR el buildCommand, punto.
  - **Lo que SÍ está hecho y es CI-verde (commit 0389b1a):** `core/app_info.dart` `appBuild()` lee
    `window.JZ_BUILD` en runtime (`app_info_stamp_web.dart`, js_interop; stub `_io`), lo muestra en
    el pie de Ajustes y Sentry lo usa de `release`. `scripts/stamp_build.sh` inyecta
    `<script>window.JZ_BUILD="<sha7>"</script>` en `build/web/index.html` (idempotente; sin SHA cae a
    `dev`). index.html va no-store (sw v4) → reflejaría el bundle real. Falla con gracia: sin inyector,
    `appBuild()`='dev' (sin regresión).
  - **Para ACTIVARLO (única vía deploy-safe, requiere a Gian):** añadir el paso post-build en el
    **Build Command del DASHBOARD de Vercel** (Project Settings → Build & Development), NO en vercel.json:
    `… --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY && bash ../scripts/stamp_build.sh`. Si el
    dashboard también lo rechaza, el sello queda diferido (limitación de plataforma de este proyecto).
- Mecánica normal restaurada: push a `main` → Vercel reconstruye → deploy. Migraciones
  (Supabase) siguen teniendo efecto YA, independientes del deploy.
- **2 bugs de Android PWA arreglados (2026-06-24):** (1) **pantalla negra al volver de
  background** — no había manejo de resume; fix en `app/web/index.html` (visibilitychange/
  pageshow → `resize` sintético + webglcontextlost/restored), deploy-safe, NO toca buildCommand.
  (2) **checkpoint "se corta"** — safe-area inferior faltante; `MediaQuery.paddingOf().bottom` en
  checkpoint_intro/result + certificate. Verificación manual del dueño en FINDINGS.md.
- **Smoke post-deploy 2026-06-23 (prod `b34b568`) ✅ TODO VERDE** (cliente real, sin
  service_role): loop core (`correct_answer` 403/sin col, `grade_item` OK), seguridad
  mig 058 (ligas 403, gate admin, export 24 secc.), ligas/leaderboards mig 059 (32
  combinaciones sin UUID_LEAK, paginación, rollover idempotente), **audio 312/312**,
  PWA `sw v4`+no-store+aviso de update (sello `JZ_BUILD`=`dev`, conocido). Suites:
  analyze 0 · test 42/42 · verify_chain es→en · verify_pt_chain · e2e_audit PASS.
  Detalle + **checklist manual para Gian (iPhone/Android)** en FINDINGS.md.

## Estado por área
| Área | Estado |
|---|---|
| **i18n (idioma de la UI es/en/pt)** | ✅ **REAL y live (commits `c1654d0`+`3f8f7f8`).** Antes el selector era **cosmético** (no había infra l10n; nada consumía `localeProvider` → elegir English/Português no cambiaba nada = el "idioma raro" del feedback). Ahora: `flutter_localizations`+`intl`+**gen-l10n** (ARB `es`/`en`/`pt` en `app/lib/l10n`, salida a fuente, `l10n.yaml`); `MaterialApp` consume `Locale` de `localeProvider` (persistido) → cambiar idioma re-renderiza la UI **al instante**. Selector NUEVO en **Ajustes** ("Idioma de la app") + cambio en vivo en el paso de idioma del onboarding. **Traducido 100%** (es/en/pt, ~260 claves): **onboarding + auth** (superficie del feedback; copy "idioma de la app vs objetivo" aclarado) y **loop de lección completo** (player, complete, preview, checkpoint intro/player/result, no_hearts, error_review, 6 ejercicios). Fecha del plan localizada (`MaterialLocalizations.formatMediumDate`), duración (`duration_format.dart`) y nombres de habilidad (`skill_names.dart`) por idioma. **Distinción clave:** i18n = chrome de la UI; el **CURSO** (es→en/es→pt = lo que se aprende) es contenido de la DB, NO se toca. Test `i18n_test.dart` (el locale cambia el texto; plurales/placeholders). **Cobertura extendida (2026-07-02, ~200 claves más):** **home/mapa** (learn_map, top bar a11y, misión), **ligas + leaderboards** (segmentos, zonas, métricas/ventanas/alcance, división localizada vía `division_names.dart`), **tienda + racha** (tarjetas, hitos, congelador), **perfil** (4 habilidades, plan, stats, certificados, examen/gate de dominio, "Para ti", editar perfil) — fechas por `MaterialLocalizations.formatMediumDate/formatMonthYear`, plurales (racha/jugadores/días/habilidades), reutilización de `skillName()`/`planFocus*`. **Diferido (en español, punto de retome):** Ajustes (cuerpo), práctica (SRS/débil/timed), notificaciones/Matix, inmersión/historias, level_exam, premium, legal (texto sustantivo), reference, notebook. |
| **Test de ubicación + arranque** | ✅ **preciso y live (server-driven, mig 075/076/077).** Antes: test 100% cliente con 20 ítems hardcoded en Dart + nivel = **MEDIA** de las preguntas (subestimaba → un B2 salía A1/B1) **y** `create_plan` **ignoraba** el nivel (siempre Unidad 1). Ahora: **`placement_next`** (RPC stateless, **calificado en servidor** con `jz_grade`, `correct_answer` 42501) con selección **escalera 1-up/1-down** + estimador **TECHO** (ubica en el nivel más alto manejado consistentemente) + per-skill reading/writing. Banco real **48 ítems A1→C1** (5+5/nivel, validados adversarialmente), tag `placement` (excluido de pools). **Puente**: `create_plan` mapea `current_level`→**unidad de entrada** (A1=1·A2=7·B1=13·B2=19·C1=25), marca lo inferior `completed` (accesible, sin XP), entrada `available`. Avance del mapa es por cadena → seguro (examen/cert siguen gateados por dominio). **Verificado cliente real:** personas A1/A2/B1/B2/C1 → su nivel EXACTO (B2 incluso con hint malo); B2→arranca en U19, A1→U1. Cliente = **relay** (sin banco ni estimador local). **Robustez + resultado (mig 089):** el techo ingenuo SOBREESTIMABA (un acierto suelto en alto promovía); ahora **"techo con evidencia"** — un nivel se domina solo con `asked≥2 & correct≥2 & acc≥2/3`; el más alto dominado (no promueve por azar/suelto). +5 ítems C1 (banco C1 7R+6W), `placement_next` junta más evidencia (min 8/max 14, reversals≥4). **Fecha realista (estimation.dart):** el "2 semanas a C1" venía de la sobreestimación + `needed` negativo; ahora la **meta efectiva siempre > nivel actual** (si placement ≥ meta, apunta al siguiente nivel) y la duración se muestra humana (semanas/meses/**años**, no "789 semanas"); horas-guía reales (C1≈750h). **Pantalla de RESULTADO** (`PlacementResultView`, paso nuevo del onboarding): "Tu nivel: X" + desglose 4 habilidades + unidad de entrada + fecha realista (ubicación, no aprobar/reprobar). Verificado: `verify_estimator.py` 7/7 (incl. acierto-suelto NO salta), personas A1–C1 exacto, +6 tests Dart. **Banco es→pt ✅ (mig 093, 2026-07-02):** 42 ítems (A1/A2/B1 × 7R+7W) pt-BR, curso `…0002`, tag `placement`; validación adversarial (profesor pt-BR: 39/42 impecables, 1 fix de regência "assistir a", 2 distractores endurecidos) + guardas anti-colisión (cloze sin distractor a distancia-1 del correcto, ya que `jz_near_match` perdona insert/borrado; MC = exacto). **Verificado cliente real** (`verify_placement_pt.py`): determinista 42/42 (correctos aceptados, distractores rechazados sin near-match), personas A1→A1/A2→A2/B1→B1/avanzado→B1 (techo honesto: pt tope B1), **multicurso: todo curso pt, `placement_next(en)` sin fuga**. **Bancos fr/it/de/nl ✅ (mig 110, 2026-07-03):** 112 ítems (28/curso = A1+A2 × 7 reading MC + 7 writing cloze) — cubren SOLO los niveles que existen en esos cursos (A1-A2) → **techo honesto A2** (análogo al techo B1 de pt), no ofrecen ubicar donde no hay contenido. **Cableado = el propio banco** (placement_next(p_course) ya es course-scoped; NO se tocó el RPC). Autorados por profesores nativos IA (fr/it/de/nl) + **validación adversarial nativa por idioma** (fr 1 fix: «aussi…que»→«beaucoup»; nl 1 fix: «hebben» ambiguo por «zij»→«waren»; it 0, de 0) + **guarda anti-colisión AUTOMÁTICA** en `gen_placement_multi.py` (asevera que ningún distractor de cloze es perdonable por `jz_near_match` — indel dist-1 palabra única, cualquier edición dist-1 multi-palabra). **Verificado cliente real (`verify_placement_multi.py`, JWT):** determinista 28/28 correctos + 28/28 distractores por idioma (correct_answer 42501); personas **A1→A1, A2→A2, avanzado→A2** (techo honesto) en los 4; **aislamiento: placement_next(fr/it/de/nl) sirve SOLO su curso, placement_next(en) sin fuga** → 0 cruces entre los 6 cursos; en/pt INTACTOS. **Re-placement por-idioma CABLEADO ✅ (2026-07-03):** al cambiar de curso en **Ajustes**, un diálogo ofrece «¿Hacer el test de ubicación de <idioma>?» → corre `placement_next(<curso>)` con SU banco → `PlacementResultView` reutilizada (localizada) → aplica nivel→unidad de entrada con `create_plan` (course-scoped). Antes: cambiar de curso = caer en A1. `placementNext` ahora acepta `courseId` (null = onboarding en); `fetchPlan`/`userPlanProvider` course-aware (evita romperse con planes multi-curso). **Verificado end-to-end cliente real** (`verify_placement_wiring.py`): cambiar a de/nl/fr/it + responder A2 → ubica A2 + entra en **U7** (no A1); principiante → A1/U1; **EN intacto** (U13/B1) tras re-ubicar; aislamiento; 42501. `placement_flow_test` propaga courseId. **Idioma META en el ONBOARDING ✅ (2026-07-03):** paso nuevo «¿Qué idioma quieres aprender?» (los 6 cursos activos, distinto del "idioma de la app") → `set_active_course` al elegir → el placement del onboarding corre sobre el BANCO del curso elegido (`placement_next(courseId)`) → `create_plan` siembra ESE curso. Copy course-aware (motive/nivel-inicial dicen el idioma elegido vía `learnLangName`, i18n es/en/pt; la nota del idioma-de-app ya no afirma "aprenderás inglés"). Un usuario nuevo ya NO cae siempre en inglés. **Verificado end-to-end cliente real** (`verify_onboarding_target.py`): nuevo→alemán A2 → **A2 alemán/U7** (no inglés, SIN progreso en en); nuevo principiante→nl A1/U1; nuevo→inglés B1 sin cambio; aislamiento; 42501. +widget test del paso (`onboarding_target_test`). **Diferido:** L/S en placement (audio) + nombre real de la unidad de entrada por curso (rótulo es→en, la unidad real es correcta) + cap de la meta al tope del curso (fr/it/de/nl topan A2). |
| Loop lección + grading server-side | ✅ verde y live. **Grading apóstrofes/contracciones (mig 067):** `jz_normalize` equipara I'm↔I am, don't↔do not, '↔'↔'' y limpió 15 ítems con `''` corrupto del seed. **word_bank/reorder no revelan la respuesta (mig 068, 20 ítems):** enunciado en español. **Typo-tolerance "casi correcto" (mig 073):** `grade_item` perdona typo menor (distancia 1: inserción/borrado, o sustitución SOLO en multi-palabra) y artículo a/an/the faltante/sobrante → `correct=true` + **`near=true`** (no resta vida, muestra "La forma correcta es…"). Guard de homógrafos: live/life, house/horse, cat/cut, this/these NUNCA se perdonan. `jz_grade = jz_grade_exact OR jz_near_match` (loop, summary y examen coherentes). Espejo cliente en `grader.dart` (`nearMatch`) + tests (`grader_typo_tolerance_test.dart`, 17). **Repaso de errores (mig 074 + `ErrorReviewScreen`):** al terminar, si hubo fallos → pantalla "Repasa lo que fallaste" (cada errado + respuesta correcta + porqué) ANTES de la recompensa; "Practicar los fallados" opcional. Los fallados entran al SRS con prioridad (`srs_prioritize_failed` → `user_vocab_srs` due=now). **TTS de tile (Web Speech):** tocar una ficha en word_bank/reorder pronuncia la palabra (cero archivos, interrumpible, degradación con gracia; disparado por TAP → sin desbloqueo iOS). **Idioma del HABLA = curso activo (fix 2026-07-02b):** antes el TTS de tile (`word_tts_web`) y el reconocedor de speaking (`speaking_exercise`) estaban **hardcodeados a inglés** → en pt/fr/it la VOZ no correspondía al idioma (bug real del feedback). Ahora `SpeechLang` (estático, fijado en `HomeShell` desde `activeCourseTargetProvider`) los pone en en-US/pt-BR/fr-FR/it-IT según el curso. El audio pre-generado (MP3) ya era correcto (tl por idioma). `correct_answer` sigue revocado (42501). |
| **Música ambiente del mapa** | ✅ **es→en/pt (live).** Loop ambient **original (obra propia → CC0**, sin terceros, `gen_music_loop.py` síntesis procedural; ciclos enteros → sin clic; 12s/384KB en Storage `audio/ambient/map_loop.wav`, carga diferida → bundle +5.6KB solo código). **Default APAGADA (opt-in)** — pisar el audio del usuario = desinstalan. Toggle en **Ajustes** + **toggle rápido** en la top bar del mapa (persistido, `MusicController`/`music_enabled`). **Solo en el mapa**: `HomeShell` coordina por tab (==0) + lifecycle (pausa al backgroundear) + `setSuppressed` en lección/checkpoint/examen (nunca durante el ejercicio). **Ducking automático** en el `AudioEngine` (la música baja sola con cualquier SFX/TTS vía rampa de GainNode, se recupera después). **MediaSession NO reactivada**: el loop vive en el MISMO AudioContext (Web Audio API, sin `<audio>`) → sin reproductor en pantalla de bloqueo (riesgo conocido, mantenido a raya). Pendiente: variar/alargar el loop, presets de volumen. |
| Dinamismo/UX (loop) | ✅ 1ª tanda LIVE (deploy-pending): recompensa con contadores+entrada escalonada, feedback ✅/❌ animado, transiciones `jzRoute`, skeletons en Ligas. Pendiente: tokens de espaciado, mascota en más pantallas, radar animado. Ver UX_AUDIT.md |
| Capa "enseña" (tips/cuaderno/referencia/**inmersión**) | ✅ tip post-lección **relevante al tema real de la lección** (mig 069: `content_tips.topic` + match contra los tags de la lección; ya no sale el tip de EDAD en una lección de PAÍSES) + anti-repetición (no visto > menos reciente) + personalización por skill flojo + cuaderno + **Referencia/Repaso** (mig 060) + **Inmersión/Historias** (mig 065/066: 6 historias es→en A1/A2, audio 46/46). **Tips A1 multi-idioma (mig 102, 2026-07-03):** además de los 72 es→en, **24 tips A1 para es→fr/it/de/nl** (6/curso, 1 por unidad = punto gramatical clave: edad con avoir/avere/sein/zijn, partitivo/acusativo, hora/falsos-amigos «halb vier»/«midi et demi», contracciones/prep. articuladas, de-vs-het, mein/meine). Course-scoped por `get_lesson_tip` (WHERE course_id=jz_active_course) → **verificado cliente real: cada curso ve su tip, sin cruce** (en→inglés, fr→fr, it→it, de→de, nl→nl). **Completado a 6/6 cursos (mig 103, 2026-07-03):** +6 tips **es→pt A1** (keyed por unit_order: você+3ª pers., meu/minha por género, gostar DE, queria/Quanto custa, ficar, segunda-feira) + **12 tips A2 fr/it** (units 7-12: passé composé/passato prossimo, futurs, accord/concordanza con être/essere, comparativos, imparfait/imperfetto, avoir mal à/mal di). Verificado cliente real (pt U2→tip pt, fr U9→A2 fr, it U12→A2 it, en control). Total **54 tips** en 6 cursos; **+12 tips A2 de/nl (mig 106)** → tips A1+A2 completos en los 4 pilotos (fr/it/de/nl). **Tips B1/B2 de niveles altos ✅ (mig 124, 2026-07-05):** +54 tips = fr/it/de/nl B1+B2 (units 13-24) + pt B2 (19-24), 1 punto gramatical clave/unidad, autorados por profesores nativos; `gen_tips_multi.py` batch `hi` + cefr por unit_order extendido a B2. Verificado cliente real (set_active_course + get_lesson_tip por curso en lección B1/B2): cada curso su tip, 0 cruce. **Ahora tips A1-B2 en en/pt/fr/it/de/nl.** **+12 tips es→pt A2/B1 (mig 108, 2026-07-03):** units 7-12 (pretérito perfeito, futuro «vou»+inf, pegar o ônibus, a conta/garçom, ser/estar, «estou com dor») + units 13-18 (imperfeito «era/brincava», condicional «gostaria», subjuntivo «que venha», relativos que/quem/onde, «deu problema/tem jeito», comparativos maior/melhor) → **pt tips A1+A2+B1 completos** (18). `gen_tips_multi.py` ahora deriva cefr A1/A2/**B1** por unit_order. Verificado cliente real (pt U7-18→su tip; con fr activo **0 cruces**). `gen_tips_multi.py <batch>`. **Historias/inmersión multi-idioma (mig 107+109, 2026-07-03):** además de las 6 es→en, **1 historia A1 por piloto** — fr «Le café de Léa», it «Un caffè al bar», **pt «A padaria da Ana», de «Beim Bäcker», nl «De koffie van Sanne»** → **los 6 cursos con ≥1 historia**. Cada una 7 segmentos (texto meta + es + **audio tl correcto** — fr/it 14/14 + pt/de/nl 21/21 = 35/35 HEAD 200) + glosario + 5 preguntas MC. Autoradas por profesores nativos IA + **validación adversarial nativa** (pt/de/nl: 0 errores reales, 1 pulido pt «quentinho» aplicado). Pipeline `gen_stories.py` + `gen_story_audio_multi.py`. **Verificado cliente real (`verify_stories_multi.py`):** `get_stories`/`get_story`/`submit_story` course-scoped en los 6 cursos (**0 cruces** en/pt/fr/it/de/nl); get_story NO expone `correct_answer`; submit_story califica server-side (correctas 1.0 / erróneas 0.0, 42501); `stories.questions` revocada al cliente; audio HEAD 200. **Historias B1 ✅ (mig 125, 2026-07-05):** 2ª historia por idioma, nivel B1, para fr/it/de/nl/pt («L'appartement de Karim», «Il colloquio di Giulia», «Die Wohnungsbesichtigung», «De trein die niet reed», «A entrevista de Rafael») — 7 segmentos con gramática B1 real (passé composé/subjonctif/Konjunktiv II/conditionalis/subjuntivo, relativos, passiva), glosario + 5 MC + audio tl 35/35. `gen_story_audio_multi.py` con **chunking** (translate_tts limita ~200 chars; segmentos B1 largos se parten en trozos ≤190 y se concatenan). Verificado cliente real (`verify_stories_multi.py`): get_stories 2/curso course-scoped (0 cruces), get_story sin fuga, submit 5/5→1.0 y 0/5→0.0 (42501), audio HEAD 35/35. Pendiente: historias B2. |
| Contenido es→en A1–B2, **es→pt A1–B2** | ✅ sembrado y live (pt B1 = mig 053; **pt B2 = mig 20260705120121, 2026-07-05** — ver fila abajo). Cadena A1→B2 + certs verificada. |
| **B2 es→pt ✅ LIVE (mig 20260705120121)** | 6 unidades (order 19-24, encadenan B1→B2; U18 desbloquea U19), **114 ítems (R36/W36/L24/S18 → L=67% S=50%)**, audio TTS **tl=pt 42/42**. Currículo B2 pt-BR REAL: **presente do subjuntivo** (seja/tenha/faça + embora/para que/caso/a menos que), **futuro do subjuntivo** (quando eu tiver/for/fizer — rasgo clave pt, no presente) **+ imperfeito do subjuntivo** (se eu tivesse/fosse), **período hipotético** (3 tipos: se tiver→vou / se tivesse→…ria / se tivesse tido→teria+part) **+ futuro do pretérito**, **voz passiva** (ser+part+concordância; sintética «vendem-se casas»; estar vs ser; particípios duplos aceito/pago/entregue/ganho), **discurso indireto + colocação pronominal** (concordância dos tempos; próclise por atração/ênclise inicial), **conectores B2 + regência verbal** (embora/caso/contanto que+subj vs à medida que/porque+ind; assistir a/obedecer a/gostar de). **`gen_course.py` extendido a pt** (COURSES/STAMPS/UNIT_WORD='Unidade'; sin unique constraint en vocab/content_items → sin colisión con pt A1-B1). 6 professores nativos pt-BR IA + **revisión adversarial nativa** (fixes reales: «quiseria» inexistente→«gostaria», word_bank que revelaba respuesta, 4 colisiones near-match dist-1 en cloze de subjuntivo/regência/crase → reescritas a multi-palabra/single-word bloqueada). **Verificado cliente real (`verify_b2_chain.py pt`):** determinista 96/96 + 96/96 distractores (42501); **CAMINA A1→B2 las 24 unidades** (U18→U19, 30/30 lecciones B2); **0 lesson_items cruzan los 6 cursos**; default(en) sin fuga; audio HEAD 42/42. `get_courses.max_level` pt→B2 (cap de meta ofrece B2). **português es→pt: A1→B2 completo → los 6 cursos llegan a B2.** |
| **Audio** (listening/speaking TTS) | ✅ es→en + es→pt A1/A2 (312) + **es→pt B1 (68)** = 380 + **rebalanceo L/S es→en A1/A2 (96, mig 078/079)** en Storage = **476/476** + degradación/unlock iOS LIVE. Ver FINDINGS.md §2 |
| **Balance de 4 habilidades (L/S)** | ✅ **es→en A1–C1 rebalanceado (mig 078–082, live).** Audit EFICACIA halló sesgo **~3:1** (R/W vs L/S). Subido con criterio (NO 1:1): **listening ~65% de R/W**, **speaking ~50%** (proxy read-aloud, participación, no evalúa fluidez). **A1/A2** (mig 078/079): +5L/+3S por unidad (96 ítems). **B1/B2/C1** (mig 080/081/082): +4L/+2S por unidad → resultante B1 L/R=62% S/R=50%, B2 61%/49%, C1 69%/51% + **34 huecos** de cobertura de alto impacto rellenados (auditoría confirmó cobertura gramatical SÓLIDA en los 3; sin huecos estructurales). **+204 ítems** L/S totales (todos con audio TTS regenerable, `payload.say`/`text` guardado), autorados por panel IA + validación adversarial por unidad, cableados a lecciones 1–4 + tag `unidadN` (pool del examen → menos sesgo R/W). **es→pt A1/A2/B1** (mig 083/084/085): +4L/+2S por unidad → pt A1 L/R=61% S/R=49%, A2 62%/50%, B1 72%/57% + 34 huecos; audio **tl=pt** (108/108). **Verificado cliente real** por nivel (en+pt): L/S resueltos suben su dominio (listening precisión, speaking participación); verify_chain A1→B2 PASS; **verify_pt_chain A1→B1 PASS (multicurso: contenido pt→curso pt, 0 fuga)**. **Techo C1 honesto:** receptivas sí a C1; producción libre (W/S) requiere Fase 2 → sin cert C1 por diseño. **Sesgo L/S 3:1 resuelto en AMBOS cursos.** Pendiente: es→pt B2/C1 no existen aún (curso pt llega a B1). |
| **Imágenes referenciales (doble codificación)** | ✅ **es→en A1/A2 (mig 086/087, live).** Fuente **Twemoji (CC-BY 4.0)** alojado en Storage (`audio/vocab/<concept>.png`), carga **diferida** (`Image.network`, cero deps/assets nuevos → bundle igual). **39 iconos** de vocab concreto (comida, familia, lugares, tiempo, viaje, compras) + registro de **proveniencia/licencia** en `vocab_images` (RLS sin policy → no se filtra al cliente). **21 ítems** `multiple_choice` "¿Qué es esto?" (imagen=estímulo → NO revela por texto; opciones=palabras de la misma categoría; `correct_answer` 42501). UI: `ConceptImage` en `buildExerciseWidget` → se ve en las 4 superficies (lección/checkpoint/examen/práctica), altura fija (sin jank), **degradación con gracia** (si no carga, colapsa y el ejercicio sigue con texto). Verificado cliente real: HEAD 21/21, grading server-side, image_url por `content_items_public`. **"Describe la imagen" determinista (mig 088):** 16 ítems **word_bank/writing** que reusan las imágenes — el usuario ARMA con fichas la frase ("This is a house") → secuencia verificable (jz_grade word_bank), produce lenguaje (mueve **writing**), distractor de ficha enseña el artículo (a/an/the/incontable). Cero UI nueva (reusa ConceptImage+TileArrange). Degradación: 1 solo sustantivo/frase → resoluble desde fichas aunque la imagen no cargue. **Descripción ABIERTA evaluada = Fase 2** (techo determinista). **Carga (2026-06-27):** barrido HEAD de TODO (audio 759/759, imágenes 37+39, historias 46, música) = **0 recursos 404** (`sweep_resources.py`); el "no cargan bien" era lentitud percibida → **precarga de imágenes** en el lesson_player (como el audio) + failsafe en `ConceptImage` (colapsa a los 10s, no spinner eterno). **Copy onboarding** aclarado (idioma de la APP vs lo que aprende; sin anglicismos). Pendiente: match imagen↔palabra, es→pt, B1+. |
| **Seguridad** (4 hallazgos) | ✅ **cerrados** en DB (mig 058) + botón export en Ajustes **LIVE** (deploy 68266d3). Ver abajo |
| Ligas + Leaderboards | ✅ rollover real (mig 059): cierre semanal idempotente/lazy + ascensos (top 7)/descensos (fondo 5) Bronce↔Diamante + snapshots. `get_leaderboard` (XP/Racha/Lecciones/Certificados × Semanal/Mensual/Anual/Histórico × Global/División, SIN user_id). UI con segmentos (Mi liga / Tablas) **LIVE** (deploy-pending hasta push). Falta: **cron** que dispare el cierre (hoy es lazy-on-read; ver abajo) |
| **C1 es→en** | ✅ **sembrado y live** (mig 063): 6 unidades (25–30), **252 ítems** (192 lección + 60 checkpoint fresco), 4 habilidades, audio **67/67**. **Sin examen/cert C1** por diseño (techo determinista — writing/speaking a C1 no son evaluables sin IA; mig 064 tope el examen en B2 + blinda C1). Progresión intra-C1 por checkpoints (≥80%). Placement C1 ahora con banco real (8 ítems) + arranque en U25 (mig 075/076/077). Ver `docs/LEVELS_C1_DESIGN.md` y fila **Test de ubicación** |
| C2 | ❌ documentado, no sembrado (otra pasada) |
| Conversar | ✅ **VISIBLE + MULTI-IDIOMA los 6 cursos (fix 2026-07-02c + de/nl 2026-07-05)** (pestaña 2 del nav, GA7): práctica en solitario/asíncrona (tema → escribe/habla → respuesta modelo + autoevaluación) + captura de interés para la conversación EN VIVO (Fase 2). Antes los 6 topics tenían **model+tips hardcodeados en inglés**. Ahora `ConvTopic.models` es un **mapa por idioma META** con los **6 idiomas (en/pt/fr/it/de/nl)**; `ConversarScreen` resuelve el idioma con `activeCourseTargetProvider` y `modelFor(lang)` (fallback a en). **de/nl añadidos 2026-07-05** (los 2 cursos más nuevos que aún veían el fallback inglés): de con Sie formal + Perfekt, nl con V2 + «Mag ik…/alstublieft» + voltooid tegenwoordige tijd, autorados por profesores nativos. `SpeechLang` ya mapea de-DE/nl-NL (TTS + reconocedor). Verificado: unit test (6 topics × **6 idiomas** × 3 tips + fallback) + `flutter analyze 0 · test 94/94`. Conversación EN VIVO sigue siendo Fase 2. |

### Ligas — automatización del cierre (pendiente del dueño)
El rollover (`jz_close_weeks()`) es **idempotente + lazy**: se ejecuta al leer
(`get_league`/`get_leaderboard`), así que las semanas vencidas se cierran solas
cuando alguien abre Ligas — no se pierde nada aunque no haya cron. Para garantizar
el cierre puntual (lunes 00:00 UTC) aunque nadie entre, automatizar con UNA opción:
**(a)** `pg_cron` (Supabase Pro): `select cron.schedule('jz-rollover','5 0 * * 1','select jz_close_weeks();')`;
**(b)** Edge Function + cron externo (GitHub Actions/cron-job.org) que llame a un RPC.
Movimiento real solo en ligas ≥13 (top 7 suben / fondo 5 bajan); en beta (<13) nadie
se mueve, por diseño.

## Seguridad — 4 hallazgos (todos CERRADOS en DB, mig 058 · 2026-06-23)
1. ✅ `league_members`/`leagues` SELECT directo **revocado** (daba UUIDs de auth ajenos).
   El ranking se sirve SOLO por `get_league` (DEFINER, sin user_id). `get_metrics` etc. siguen.
2. ✅ Gate de admin en `get_metrics`/`get_engagement`/`get_onboarding_funnel`: tabla `admins`
   + `jz_is_admin()`. Dueño (Gian, `7b4a8e40-…`) sembrado. No-admin → `admin only`.
3. ✅ `log_event`: allowlist de 8 eventos (`app_open, client_error, conversar_attempt,
   lesson_complete, mission_started, onboarding_completed, onboarding_step, screen_view`),
   props truncadas (>2KB → `{_truncated}`), rate-limit 120/usuario/min. Evento desconocido = descarte silencioso.
4. ✅ `export_my_data()` (GDPR): RPC DEFINER acotada a `auth.uid()` (24 secciones). Botón
   "Exportar mis datos" en Ajustes (**LIVE** desde deploy 68266d3).
- Previo: `correct_answer` ya estaba cerrado (mig 055), `jz_*` helpers revocados (mig 049).
- Admin allowlist NO se gestiona por SQL roles → es la tabla `admins` (agregar/quitar user_id).

## Legal — PÁGINAS PÚBLICAS + in-app (Privacidad + Términos) · ⚠️ BORRADOR (falta abogado)
- **PÁGINAS PÚBLICAS ✅ LIVE (2026-07-07):** `app/web/privacy.html` + `app/web/terms.html` (HTML
  autocontenido, responsive, banner beta, tema claro/oscuro) → Flutter los copia a `build/web/` y
  **Vercel los sirve sin login**. `vercel.json` **rewrites** (buildCommand INTACTO): `/privacy`→
  `/privacy.html`, `/terms`→`/terms.html`, antes del catch-all SPA. **URLs estables para Google OAuth /
  Search Console:** `https://jezici.vercel.app/privacy` y `https://jezici.vercel.app/terms` (200 público,
  verificado). Contenido HONESTO derivado de introspección real: cuenta+Google OAuth (email/nombre/foto,
  scopes básicos), progreso/skills/stats, analítica (allowlist de eventos, ids opacos), feedback in-app,
  monitoreo de errores, Supabase+RLS+Vercel, retención, y **derechos que YA existen** (export_my_data /
  delete_account desde Ajustes). **Fuente única:** el HTML es canónico; la app **enlaza** (no duplica).
- **Enlace in-app:** `features/legal/legal_screen.dart` ahora es un módulo de enlaces (`kLegalVersion`
  = `'2026-07-draft'`, `kPrivacyPath`/`kTermsPath`, `openLegalPage()` con import condicional web
  `legal_open_web.dart`/`_io.dart` → `window.open('${Uri.base.origin}/privacy','_blank')`, no-op fuera de
  web, degrada con gracia). **Ajustes** (2 links) **y el registro** (checkbox + links) abren la página
  pública en pestaña nueva. Se eliminó el widget de texto in-app (evita duplicar el texto).
- **Aceptación (mig 062):** en "Crear cuenta", checkbox **requerido** "He leído y acepto
  Términos + Privacidad" (botón deshabilitado sin marcar). Tras el alta → `accept_legal(version)`
  persiste `legal_consents(user_id, doc_version, accepted_at)` (RLS self; escritura solo por RPC).
  `my_legal_version()` devuelve la última versión aceptada (base para re-consentir).
- **Versionar/re-consentir:** subir `kLegalVersion` cuando el texto cambie (revisión de abogado).
  La detección está lista (comparar `my_legal_version()` vs `kLegalVersion`); el **gate de
  re-consentimiento para usuarios existentes está DIFERIDO** (se añade al llegar la versión revisada).
- ⚠️ **Es un BORRADOR**: NO está revisado por abogado. No afirmar acreditación oficial.

## Analítica de la beta (KPIs sin SQL) — mig 061
- **Cómo lo ve Gian:** Ajustes → "Ver métricas (interno)" (admin-only; Gian ya en `admins`).
  Pantalla `MetricsScreen` lee `get_metrics`/`get_engagement`/`get_onboarding_funnel` (todas
  admin-gated). KPIs: usuarios, DAU/WAU/MAU + **stickiness DAU/MAU (CURR)**, retención
  D1/D7/D30, lecciones/día, % aprueba checkpoint/examen, % certifica, **embudo de onboarding**
  (paso a paso + dónde abandonan) y **embudo de lección 30d** (iniciadas/completadas/
  abandonadas/sin-vidas + tasa de finalización).
- **FEEDBACK DE USUARIOS — dónde lo ve Gian (mig 099, 2026-07-02):** el feedback in-app
  (`FeedbackFab` app-wide → `submit_feedback` → tabla `feedback`) se capturaba pero era
  **ILEGIBLE** (la tabla tiene RLS solo-INSERT y `get_engagement` daba solo el CONTEO por tipo,
  no el texto). Nuevo **`get_feedback(limit)`** (admin-gated, SIN PII: user_id recortado a 8
  chars) devuelve los MENSAJES reales; **MetricsScreen los muestra en la sección "Mensajes de
  usuarios"** (texto + tipo + pantalla + fecha). Gian: Ajustes → Ver métricas → baja a "Mensajes
  de usuarios". **Query directa (admin):** `select created_at, kind, screen, message from feedback
  order by created_at desc;`. Verificado cliente real (no-admin → "admin only"; admin → mensajes).
- **Eventos (allowlist `log_event`, mig 058+061):** `app_open, client_error, conversar_attempt,
  lesson_complete, mission_started, onboarding_completed, onboarding_step, screen_view` +
  **`lesson_start, lesson_quit, no_hearts`** (mig 061). ⚠️ Evento fuera del allowlist = descarte
  silencioso → si agregas uno, AGRÉGALO al allowlist o nunca entra. Sin PII (solo conteos + ids opacos).
- Nota: `lesson_funnel.completion_rate` solo es fiable para sesiones DESPUÉS de este deploy
  (antes había `lesson_complete` sin `lesson_start`). Diferido: retención por cohorte semanal
  visual, abandono por ítem específico, analítica de práctica.

## Monitoreo de errores (Sentry) — cableado, falta el DSN
- **Client-side LIVE-ready** (`core/monitoring/sentry_config.dart`): `runWithSentry`
  envuelve `runApp` (captura Flutter + nativo iOS/Android + zona; en web errores JS de la
  app). Sin DSN → **NO-OP** (la app arranca igual, sin coste). Config beta: env `beta`,
  release `jezici@<JZ_BUILD>` (fallback `dev`), `tracesSampleRate 0.1`, `sendDefaultPii=false`
  (GDPR), `beforeSend` filtra ruido (timeouts/cancelaciones), uid OPACO sin PII. Convive con
  `installCrashReporting` (analytics_events), sinks distintos.
- **Cómo lo activa Gian (el DSN NO es secreto):** pega el DSN como `--dart-define` con
  **VALOR LITERAL** (NO `$VAR` ni `$(...)` → eso rompe el deploy pre-build).
  - **Prod (Vercel):** en `vercel.json`, al final del `buildCommand`, añade literal:
    `... --dart-define=SENTRY_DSN=https://<key>@<org>.ingest.sentry.io/<project>` (y opcional
    `--dart-define=SENTRY_ENV=production`). Push → deploy. **Tras el push, confirmar deploy READY** (no instant-ERROR).
  - **Local:** `flutter run --dart-define=SENTRY_DSN=https://…`
- **Prueba de captura (con DSN):** temporal `Sentry.captureMessage('jezici test')` o un throw,
  ver que llega al dashboard, y quitarlo.
- **Diferido:** source maps/símbolos (stack traces legibles en web/nativo) y Sentry server-side
  (Edge Functions) — fuera de alcance de esta tanda.

## CI (GitHub Actions) — VERDE ✅ desde 2026-06-24 (run #57, commit 151062f)
- Pipeline completo en verde por primera vez: `Prepare .env` → analyze → **test 43/43** →
  **build web** (antes test/build quedaban *skipped* porque analyze abortaba). Deploy de Vercel
  de ese commit = **READY** (prod). Las rojas históricas #47–#56 son inmutables (corrieron con el
  workflow roto; re-correrlas reusaría ese workflow). Detalle del fix abajo.

## CI (GitHub Actions) = FUENTE DE VERDAD — no el local
- **El verde del CI manda, no `flutter analyze` local.** Workflow `.github/workflows/ci.yml`
  (job `flutter`: analyze → test → build web, Flutter **pinneado 3.44.3**). Verde real =
  `gh run list`/API muestran SUCCESS. Un verde local que el CI no refleje **no cuenta**.
- **Por qué el local daba falso verde (lección 2026-06-24, runs #47–#56 todas rojas):** `.env`
  es un asset DECLARADO en `pubspec.yaml` pero **gitignored**. En local existe → analyze pasa.
  En CI no existe → `flutter analyze` falla con `asset_does_not_exist` y aborta el job (test/build
  quedan *skipped*). El step de build creaba `.env` con `touch`, pero **corre DESPUÉS de analyze**.
  Fix de raíz: step **`Prepare .env`** (touch) **antes** de analyze + versión pinneada. El `.env`
  vacío basta (Supabase usa fallback público embebido en `supabase_config.dart`).
- **Reproducir el CI en local:** `mv app/.env app/.env.bak && cd app && flutter analyze` → debe dar
  el mismo `asset_does_not_exist`. Restaurar después. (Antes de declarar "verde", correr el comando
  EXACTO del workflow, no asumir.)

## Comandos de verificación
```bash
# Toolchain (desde app/) — el CI corre estos MISMOS con .env presente (touch) y Flutter 3.44.3
flutter analyze              # esperado: No issues found
flutter test                 # esperado: All tests passed (89/89)
flutter build web --release  # esperado: Built build/web (wasm dry-run warning de ua_client_hints es OK)

# Audio: cobertura real en Storage (HEAD a payload.audio_url) — es→en/pt = 692/692 (incl. 312 L/S mig 078–085)
#   + es→fr A1 41 + A2 43 + es→it A1 43 + A2 43 = 170/170 (pilotos A1+A2, mig 094/095/097/098, tl=fr/it)
#   + es→de A1 43 + A2 43 + es→nl A1 43 + A2 43 = 172/172 (pilotos A1+A2, mig 100/101/104/105, tl=de/nl)
#   query content_items_public?type=eq.listening|speaking_read_aloud, HEAD cada audio_url
# Curso nuevo A1 (fr/it): tools/content/verify_new_course.py <code> — determinista + aislamiento (4 cursos) + cadena + audio
# Nivel A2 (fr/it): tools/content/verify_a2_chain.py <code> — determinista A2 + aislamiento + CAMINATA 12 unidades (gating A1→A2) + audio

# Cliente REAL (NUNCA service_role para chequeos de seguridad):
#   anon key + JWT autenticado real (signup vía /auth/v1/signup, limpiar con delete_account).
#   Ejemplos verificados (mig 058): league_members directo → 403; get_league → 200 sin user_id;
#   get_metrics no-admin → "admin only"; export_my_data → 200; log_event bogus → 0 filas.

# DB (introspección/seed admin): tools/content/apply_sql.py vía Management API (.env).
```
- **Verificación de cliente desplegado**: `git show 7e26824:app/lib/...` para ver qué consulta
  el build que usan los usuarios HOY (no asumir que `main` == producción).

## Reportes de diagnóstico (raíz)
- **PRACTICAR_SRS_ANALISIS.md** (2026-07-16, solo lectura, cero código) — análisis técnico para llevar un
  **motor SRS serio (estilo Anki)** a Practicar en los 6 idiomas; responde la §5 de `PRACTICAR_SRS_SPEC.md`
  contra la BD real. **TITULAR: la premisa del spec ("reusar la infraestructura cloze que ya existe") es
  FALSA** — los cloze existentes enseñan GRAMÁTICA (`am`, `Thank`), no vocabulario: **tarjetas cloze de vocab
  listas HOY = en 58 · pt 54 · nl 39 · de 28 · it 17 · fr 8**, de ~480/curso (**1.7%–12.4%**; techo optimista
  "la palabra aparece en alguna oración" = 17.9%–54.9%). **El contenido del P0 no existe: faltan ~2.664
  oraciones nativas + su audio (~15-20 días) frente a ~3 días de motor.** PASO 0 (medido): (1) el "SRS" de hoy
  es **escalera fija** (1/2/4/8/16/30d) + **binario** (fallo → strength 0) servido como **opción múltiple**
  (el anti-feature que el propio spec prohíbe); `ease` existe pero **nunca se escribe**; la cola trata **las
  480 palabras del curso como vencidas** (`s.vocab_id is null`). (2) **`complete_lesson` NO alimenta el SRS**
  (confirmado: 0 menciones en sus 167 líneas) → **hoy el SRS solo contiene lo que FALLASTE** (`srs_prioritize_failed`);
  y **`vocabulary` es una ISLA** — no existe vínculo con lecciones/unidades (falta `lesson_vocab`). (3) `frequency_rank`
  **100% en los 6** (lo que el spec pide ya está). (4) TTS: pipeline probado en 6 idiomas pero **0 audio de
  vocabulario** (los 1.776 clips cuelgan de listening). (5) **Economía ya integrada y ya paga menos que una
  lección** (XP tope 20 + oro 2 vs oro 5-10) → riesgo bajo; los 4 botones deben alimentar **solo al scheduler**
  (pagar por tarjeta rompería la economía). **Recomendación: FSRS con parámetros por defecto en plpgsql, SIN
  optimizador** (0 usuarios = 0 historial; Anki mismo optimiza tras ~1.000 reviews) + **`srs_review_log`** desde
  el día 1 (es lo caro de retrofitear y sin ella no hay métrica de retención). **Discrepa del orden del spec:
  DESACOPLAR motor y contenido** — que la tarjeta degrade con gracia (cloze+audio si hay oración; **recuerdo
  activo escrito** si no) → SRS real en los 6 idiomas en **~5-6 días (F0+F1)**, y el banco de oraciones llega
  incremental por idioma. **Nota de oportunidad: con 0 usuarios es el mejor momento de la historia del proyecto
  para migrar el esquema del SRS** (después haría falta backfill). Techo nombrado: **480 palabras/curso se
  agotan en ~32 días** a 15 nuevas/día — el léxico actual es una semilla, no un léxico de B2/C1.
- **ARQUITECTURA_ANALISIS.md** (2026-07-16, solo lectura, cero código) — arquitectura del **cliente Flutter**
  (el servidor se analiza solo como frontera). Ground truth: repo real + introspección de `app/lib` + churn de
  `git log` + 2 agentes, con las afirmaciones clave re-verificadas a mano. **Veredicto: NO está mal
  arquitecturado** — solo 2 archivos fuera de `data/` tocan Supabase (patrón repositorio respetado), DI con un
  único punto de construcción, modelos inmutables, y **dominio puro ya extraído en 5 sitios** (`grader`,
  `estimation`, `text_match`, `traveler_level`, `division_theme` — y los 13 unit tests puros son exactamente
  esos). La deuda está **concentrada en 4 sitios**: (1) **god repository** `progress_repository.dart` (1019
  LOC, ~96 métodos, **14 dominios**) = **el archivo Dart más tocado del repo, 47 commits/3 meses**; (2) **los
  errores nunca se diseñaron** — 0 tipos, **82 `catch(_){}` vacíos**, i18n por *substring* de mensajes de
  Postgres (`friends.dart:27-37`) → hay fallos que **no producen ningún síntoma** (relevante ANTES de activar
  Sentry); (3) **no hay capa de aplicación** (35 widget tests vs 13 unit; `switchCourseFlow` declara un
  INVARIANTE pero necesita `BuildContext` → intestable); (4) **reglas en `build()`** (`_stateFor` del mapa,
  `reward_gold ?? 50` de co-op, umbral `0.8` del examen, regla de meta duplicada **4×** cuando ya existe en
  `estimation.dart:101`). **Rechaza explícitamente Clean Architecture de manual** (el dominio vive en el
  servidor por diseño; casos de uso para cada RPC = ceremonia sin retorno) y propone **feature-first
  pragmático**. Plan incremental de **~13.5 días en 6 fases independientes**, cada una verde y desplegable —
  piloto = **dominio del mapa** (derivación pura, red de tests ya existente), NO `friends.dart` (peor deuda
  pero peor piloto). **Lista explícita de qué NO tocar** (servidor, los 20 CustomPainter, pantallas grandes
  por layout verificadas una a una, interfaces de repo, freezed, go_router).
- **PRINCIPIANTE_ANALISIS.md** (2026-07-13, solo lectura, cero código) — recorrido del **usuario principiante
  ABSOLUTO** (llega sin saber nada del idioma). Ground truth: repo + BD real (contenido U1) + 2 agentes de
  exploración. **3 golpes duros, 2 casi gratis:** (P0 bug) el 2º tab **Practicar miente a cero** — el HERO SRS
  muestra "N palabras por repasar · antes de que se te olviden" con N = TODO el vocabulario del curso (novato
  tiene 0 agendado) y el CTA salta "¡Nada que reforzar!" (`progress_repository.dart:932-964`); (P0 UX) el paso
  "¿cuánto sabes?" tiene **default "Sé lo básico" → placement arranca en A2**, solo "Desde cero" salta el examen
  → el principiante cae por accidente en 16 preguntas MC/audio/mic en un idioma que no conoce; (P1 pedagógico)
  **se examina antes de enseñar** (sin tarjeta de concepto ni tip previo — el tip sale al final; producción
  —typing/hablar— desde el ítem ~6). Gap de contenido: **0 material de sonidos/pronunciación** (crítico de/nl/fr).
  Gaps priorizados P0→P2 con ayuda/costo + propuestas concretas (reusan audio+imágenes+historias ya existentes) +
  qué copiar de Duolingo ("¿eres nuevo?", sin examen, mano suave) / Busuu (present→practice). Cero código.
- **LAUNCH_AUDIT.md** (2026-07-11, solo lectura) — auditoría PRE-LANZAMIENTO ("¿listo para abrir al público?").
  Introspección real (BD/RLS por SQL + **cliente real JWT** + navegador). **Veredicto: se puede abrir HOY a
  público hispanohablante** — SEGURIDAD sólida y verificada (0 tablas sin RLS; **aislamiento AIRTIGHT**: B ve 0
  filas de A en 9 tablas; **RPCs admin RECHAZADOS** a usuario normal 400/404; Conversar 18+/bloqueo/rate/filtro
  intactos; grading 42501). Flujo de usuario nuevo sin dead-ends, app carga sin errores/404, 6 cursos OK,
  responsive OK, honesto. **P1 antes de abrir:** (1) age gate REDUNDANTE (onboarding pide checkbox adulto pero
  no el AÑO → CompleteProfileScreen aparece a todo registro nuevo); (2) consentimiento legal no persistido si
  confirm-email ON (`auth_screen.dart:104` retorna antes de `acceptLegal`); (3) dev-tool "Probar a Jezi"
  (MatixTestButtons) visible sin gate. **i18n P0 (solo bloquea pt/en):** Mi Plan/Cuaderno/Examen de nivel/
  Notificaciones 100% en español. **Cuentas (Gian):** Google OAuth sin configurar (P0 del botón; email funciona),
  Sentry sin DSN (P1), confirm-email (P1), cron ligas/JZ_BUILD (P2). Cero cambios de código.


- **CONVERSAR_FASE2.md** (2026-07-10, diseño — solo lectura) — investigación + PLAN a fondo de CONVERSAR
  (el gran diferencial, "ADN Tandem"). PASO 0 real: las 8 tablas sociales EXISTEN como stubs vacíos
  (RLS ON, solo SELECT, 0 filas, sin RPCs de escritura); Conversar hoy = práctica async en solitario +
  waitlist; edad = solo `is_adult` checkbox (sin año → **insuficiente para social**). Cataloga TODAS las
  formas (chat con amigos, corrección comunitaria verificada, salas de audio, retos por creatividad,
  tutores/marketplace + ideas propias: compañero IA, cápsulas, postales de voz…) con valor/esfuerzo/
  riesgo/async-RT. **Ordenadas en OLAS de riesgo creciente** (solo → amigos async → IA → correctores →
  audio con desconocidos 18+ → tutores). **Seguridad de menores como COMPUERTA** (verificación de edad
  real, moderación sin IA = block/report/mute/rate-limit/filtro, consentimiento de grabación, RLS de
  toda tabla, riesgos legales COPPA/GDPR-K/AADC/DSA + mitigaciones mínimas). Stack (Supabase Realtime
  para chat; **LiveKit** para audio; **Stripe Connect+Identity** para tutores; STT/LLM para IA), modelo
  de datos a añadir + RLS, plan por fases con lo BLOQUEADO en cuentas de Gian, y 5 decisiones abiertas.
- **EVAL_AUDIT.md** (2026-07-10, solo lectura) — auditoría del SISTEMA DE EVALUACIÓN por habilidad y por
  tipo (placement/checkpoint/examen), con números reales de BD + flujo corrido 2–3×. Hallazgos clave:
  (P0) el **nivel mostrado** (`user_skill_levels.cefr_level`, sube por puntos de grind 12/acierto·4/stub,
  100=+1 CEFR, **inflable**) **DIVERGE** del **certificable** (`jz_skill_mastery` = cobertura×precisión,
  riguroso); (P0) **certificado EN-ONLY tope B2** (`jz_resolve_exam_level` capa B2; solo `en` tiene exámenes
  `level`); (P0) **checkpoints C1 (en) casi vacíos por skill** (unidad25 = R1/W1 → 1 ítem fijo, cero
  aleatorización; 252/299 ítems C1 sin tag `unidadN`); (P1) **opciones NO se barajan al servir** (orden fijo
  BD; placement solapa 50% / checkpoint 40% en SELECCIÓN, ✅); (P1) **speaking del examen solo mide
  PARTICIPACIÓN** (no vacío), no destreza; placement L/S delgado (3L/2S por nivel). Lista P0/P1/P2 con
  esfuerzo al final. **Cero cambios de código.**
- **QA_AUDIT.md** (2026-06-27, solo lectura) — QA exhaustivo end-to-end + veredicto de flujo (cliente real).
  **P0 ✅ ARREGLADO (mig 090, 2026-07-02):** el congelador de racha ahora SÍ protege — `jz_register_activity`
  consume `freezes_available` al haber un hueco y preserva la racha (verify_streak_freeze.py 7/7, cliente real);
  antes solo se incrementaba. **P1 (idioma) ✅ ARREGLADO:** i18n real es/en/pt (ver fila **i18n**); el selector ya
  cambia la UI. **P1-3 misión ✅ ARREGLADO (mig 091):** bono de bienvenida one-time (25 XP+25 oro) + diálogo de
  confirmación. **P2 retención/sensación ✅ (2026-07-02):** meta diaria "X/Y XP" visible en el mapa (pastilla con
  número), combo "🔥 x{n}" en vivo en la lección, feedback de oro enriquecido (ganaste/gastaste, te quedan Y),
  race del cofre (guard), zonas de liga en beta (mig 092: promote/demote=0 hasta 13 jugadores == gate del
  rollover; UI con `movementActive` + nota beta). **Ver §0.1 de QA_AUDIT.md** para el estado ítem por ítem.
  **Diferido:** a11y amplia (device), precios hardcodeados, colores, infra bots, deuda leaderboards. **Verificado
  en vivo TODO lo core** (grading 42501, leaderboards sin fuga de user_id, placement/fecha, loop, 0 recursos 404,
  analyze 0/test 88/build OK).
- **EFICACIA_CONTENIDO.md** (2026-06-24) — auditoría de EFICACIA de currículo por nivel (¿lleva a CEFR-X?).
  Veredicto es→en A1/A2: "sí con reservas"; huecos de cobertura rellenados (mig 071, 29 ítems sin audio:
  presente continuo, 3ª persona -s, plurales, these/those, conectores, present perfect 'yet', adverbios -ly).
  **Hallazgo sistémico:** L/S subservidos ~3:1 vs R/W en TODOS los niveles + techo determinista de producción
  (speaking proxy). Destapó y arregló una **regresión P0** (mig 072): exámenes de pt rotos por mig 064 (mono-curso).
  **L/S YA equilibrado en AMBOS cursos**: es→en A1–C1 (mig 078–082) + es→pt A1–B1 (mig 083–085) = +312 ítems L/S +
  68 huecos + audio. **Auditoría de eficacia HECHA**: es→en A1–C1 y **es→pt A1–B1** (cobertura sólida; verify_pt_chain
  multicurso PASS). **es→pt B2 ✅ sembrado (mig 121, 2026-07-05):** L/S ya balanceado de origen (L=67% S=50%); pendiente
  auditoría pedagógica a fondo del B2 pt (perfil estructural hecho + doble revisión nativa aplicada). Pendiente: es→pt C1 (no sembrado).
- **CONTENT_QA.md** (2026-06-24) — auditoría pedagógica profesor-IA de **es→en A1/A2 (384 ítems)**:
  **0 P0**, clase sistémica = tolerancia insuficiente (corregida en mig 070, +20 ítems con variantes
  naturales en `accepted` + 2 pulidos). Rechazos/diferidos documentados. Pendiente: B1/B2/C1 + es→pt.
- **FINDINGS.md** — auditoría funcional/seguridad completa (audio, progresión, ligas, seguridad)
  + smoke post-deploy + checklist manual para Gian.
- **PERF_AUDIT.md** (2026-06-23, solo lectura) — rendimiento priorizado: renderer CanvasKit,
  caché de contenido estático, invalidaciones en cascada, rebuilds/cómputo en `build()`, jank del
  mapa, skeletons. Con método de perfilado en vivo (DevTools).
- **UX_AUDIT.md** (2026-06-23, solo lectura) — UX/estética/**dinamismo** por pantalla: deriva del
  sistema de diseño (212 colores hardcodeados, AppSpacing/Radius casi sin usar), motion faltante
  (feedback ✅/❌, háptica, transiciones, contadores de recompensa), + top-10 cambios por impacto.
- **MOCKUP_GAP.md** (2026-07-08, solo lectura) — fidelidad de los 15 mockups de Claude Design
  (`/mockups`, fuente de verdad del diseño) vs implementación, pantalla por pantalla con severidad
  P0/P1/P2 + esfuerzo + orden de implementación en 3 tandas. Veredicto: **tokens/Nunito FIELES**
  (paleta 1:1); los gaps sistémicos son **motion/celebración** (jzBob/jzCheer/jzFall… casi sin
  replicar), **labio 3D ausente en el CTA del loop** (`_BigButton`), y **mascota emoji vs SVG**.
  P0 de producto destacados: el certificado NO imprime el nombre del titular; Ligas muestra
  gradiente BRONCE hardcodeado sea cual sea la división; SinVidas promete cobrar oro que el código
  no cobra; Cofre/Simulacro/Practicar muy desviados. Fase 2 (no gaps): Conversar en vivo, planes
  del Paywall, correo del coach, informe de banda de simulacros.

## Memoria del proyecto
`~/.claude/projects/.../memory/` (cargada cada sesión vía MEMORY.md). Incluye: deploy mechanics,
método de verificación, pipeline de contenido, estado de producción, multi-curso, y la
auditoría 2026-06-22 (`jezici-audit-2026-06-22`).
```
