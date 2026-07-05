# Jezici — Auditoría exhaustiva (solo lectura)

---

## B2 nl + B1 it + B2 fr + B2 it (vaciado de la Cola) — 2026-07-05 ✅ LIVE + VERIFICADO
> 4 frentes de contenido, cada uno impecable y verificado ANTES del siguiente (profundidad>amplitud).
> Estado resultante: **en A1–C1 · pt A1–B1 · fr A1–B2 · it A1–B2 · de A1–B2 · nl A1–B2** (5/6 hasta B2).
- **Pipeline (idéntico, probado 9×):** 6 profesores nativos IA (1/unidad, spec estricto R6/W6/L4/S3, ítems
  planos, guard de colisión) → validación estática (balance + prompts + colisión norm-exacta + say==value +
  sequence⊆tiles + cloze con hueco) → 2 revisores adversariales nativos (por mitades U19-21/U22-24) → re-
  validación → `gen_course.py <code> <lvl>` → `apply_sql.py` → `gen_audio_missing.py <code>-<lvl>` (TTS tl) →
  `verify_b{1,2}_chain.py <code>` (cliente real) → commit → CI → deploy READY.
- **B2 es→nl (mig 116, commit b853aed):** indirecte rede, lijdende vorm gevorderd, deelwoord als bijvoeglijk,
  complexe voegwoorden (niettemin/desondanks/zowel…als/noch…noch), nominalisatie, «zou hebben/zijn+deelwoord».
  Fixes reales: colisiones norm-exactas «moest»/«moet»→«moest/wilde/kon», listening casi-homófonos rediseñados,
  2 cloze sin hueco. verify_b2_chain nl TODO VERDE (96/96 + 96/96 @42501, camina A1→B2 24u, 0 cruces, audio 42/42).
- **B1 es→it (mig 114, commit fcdc13a):** congiuntivo presente, futuro/condizionale+periodo ipotetico I, pronomi
  relativi (che/cui/il quale/chi/dove), concordanza del participio (essere→sogg./avere+lo-la-li-le antepuesto),
  discorso indiretto, pronomi combinati/ci/ne. Fixes reales: listening casi-homófono finisca/finisce, «il giorno
  prima»→«dopo», «me lo presto»→«te lo presto» (lógico). verify_b1_chain it TODO VERDE (96/96, camina A1→B1 18u).
- **B2 es→fr (mig 119, commit 6acbaae):** subjonctif passé, conditionnel passé+irréel du passé+concordance des
  temps, discours indirect avancé, participe présent/gérondif/adjectif verbal, connecteurs B2, voix passive+mise
  en relief. Fixes reales: subjonctif sujeto idéntico→infinitivo, élision «ce qu'» ante je, 2 word_bank/reorder
  triviales barajados. verify_b2_chain fr TODO VERDE (96/96, camina A1→B2 24u).
- **B2 es→it (mig 120, commit 98e6a98):** congiuntivo imperfetto/trapassato, periodo ipotetico II/III+condizionale
  passato, forma passiva (essere/venire/andare/si passivante), discorso indiretto avanzado, connettivi B2,
  nominalizzazione+relativi avanzati+frasi scisse. Fixes reales: reorder run-on reescrito, **colisión cloze «i cui»/
  «il cui» dist-1 (jz_near_match perdona insert-1 en cloze) → convertido a word_bank**, 2 accepted femeninos. verify
  it TODO VERDE (96/96, camina A1→B2 24u).
- **Aislamiento (riesgo #1):** los 4 verificadores confirmaron con cliente real (JWT) **0 lesson_items cruzan los
  6 cursos** y default(en) sin fuga en cada tanda. Todos 114 ítems/nivel, audio TTS 42/42 HEAD 200, gating
  encadenado (U12→U13 para B1, U18→U19 para B2). CI SUCCESS + deploy READY por frente. STAMPS fr/it b2 reservados
  en gen_course.py; grupos fr-b2/it-b2 en gen_audio_missing.py.

---

## Barrido de colisiones MC + cap de meta — 2026-07-03 ✅ LIVE + VERIFICADO
> Correctitud antes que más contenido: 2 frentes de la Cola priorizados.
- **[1] Barrido de colisiones MC/listening (mig 117):** para MC/listening el único vector de colisión es
  `jz_normalize(distractor) == jz_normalize(correcto)` (jz_near_match retorna false salvo cloze/translation;
  jz_normalize hace lowercase + quita puntuación/apóstrofes, NO pliega tildes/umlaut). Barrido con la
  `jz_normalize` REAL de la BD sobre los **1611 ítems** MC/listening de los 6 cursos → **1 colisión**: en B2,
  MC de comas explicativas, correcto «Diego, who runs…» vs distractor «Diego who runs…» (difieren solo por
  una coma, que jz_normalize quita → distractor aceptado). **Fix:** reenmarcado al PRONOMBRE RELATIVO en
  cláusula explicativa sobre persona (who correcto; that/which incorrectos — difieren por PALABRA, sí
  calificable). Re-barrido = **0 colisiones**; verificado cliente real (correcto True, ambos distractores
  False, 42501). El guard de autoría (generador + prompts de agentes) ya prevenía el resto (1/1611).
- **[2] Cap de meta al tope del curso (mig 118 + código):** `get_courses` expone **max_level** (nivel CEFR
  más alto CON contenido, derivado de units → auto-actualiza). `CourseInfo.maxLevel`; el onboarding **filtra
  las metas** a ≤ max del curso elegido (it ya no ofrece B1/B2/C1) y **clampa** la meta en `_pickTarget`;
  `estimatePlan(maxLevel)` capa la meta efectiva (incluido el "bump") para no prometer un nivel sin contenido;
  el re-placement de Ajustes (`CoursePlacementScreen`) también capa la meta reusada (venir de en/C1 a it/A2).
  Verificado: get_courses max_level real (en→C1, pt→B1, fr→B1, it→A2, de→B2, nl→B1); test unitario del cap
  (estimation_test); analyze 0 · test 94/94.
- **Diferido (Cola):** nombre real de la unidad de entrada por curso en PlacementResultView; L/S en placement;
  B2 nl / B1 it / B2 fr+it; imágenes; etc.

---

## B1 es→nl (escalera A2→B1) — 2026-07-03 ✅ LIVE + VERIFICADO
> nl era el único piloto sin B1 (solo A2). Ahora **neerlandés A1→B1**; B2 nl queda desbloqueado en la Cola.
- **Contenido (mig 112):** 6 unidades (order 13-18), **114 ítems R36/W36/L24/S18** (L=67% S=50%), audio TTS
  tl=nl **42/42**. Currículo B1 real: conditionalis (zou+inf), bijzinnen & voegwoorden (werkwoord achteraan),
  relatieve bijzinnen (die/dat/wie/waar), lijdende vorm (worden + deelwoord), vaste voorzetsels + «om…te»,
  voltooid verleden/conditionalis verleden (had/was + deelwoord; zou hebben/zijn + deelwoord).
- **Autoría:** 6 profesores nativos IA + revisores/rebalanceadores nativos (fixes reales: als=voegwoord no
  voornaamwoord, «maar toch» natural, gereisd verificado por 't kofschip, distractor «kok»→«koken» dist-2,
  listening de «om…te» con distractores léxicos audibles [antes eran variantes de orden inaudibles],
  guard de colisión MC). `lesson`/`topic`/`prompt` conservados.
- **Verificado END-TO-END cliente real** (`verify_b1_chain.py nl`, JWT): determinista B1 96/96 correctos +
  96/96 distractores (42501); **CAMINA A1→B1 las 18 unidades** (U12→U13 gating; 30/30 lecciones B1); **0
  lesson_items cruzan los 6 cursos**; default(en) sin fuga; audio HEAD 42/42. analyze 0.
- **Nota (guard MC, regla del agente):** el grader NO aplica near-match a MC/listening (solo exacto tras
  lowercase); die/dat/wie son palabras distintas (no colisión) — elegir el pronombre correcto ES el objetivo.
  0 colisiones norm-exactas confirmadas estáticamente + 96/96 distractores rechazados en vivo.
- **Retome B2 es→nl (Cola ítem 1):** YA DESBLOQUEADO. `gen_course.py nl b2` (STAMP 116) → `nl-b2` →
  `verify_b2_chain.py nl`, mismo pipeline (6 agentes nativos nl B2 + rebalanceo/revisión).

---

## B2 es→de (escalera B1→B2) — 2026-07-03 ✅ LIVE + VERIFICADO
> **alemán completa A1→B2.** nl B2 BLOQUEADO por nl B1 (nl solo llega a A2) → retome en orden.
- **Contenido (mig 115):** 6 unidades (order 19-24), **114 ítems R36/W36/L24/S18** (L=67% S=50%), audio TTS
  tl=de **42/42**. Currículo B2 real: Konjunktiv I (indirekte Rede), Passiv erweitert (Modalverben/
  Zustandspassiv/sich lassen), Partizip als Adjektiv, Konnektoren B2 (je…desto/weder…noch), Nominalisierung
  + Funktionsverbgefüge, Genitiv-Präpositionen + Präpositionaladverbien. Progresión desde B1.
- **Autoría:** 6 profesores nativos IA + **2 revisores/rebalanceadores nativos** (fixes reales: Konjunktiv I
  con distractores audibles, «Ein reparierter Auto»→«repariertes» [Auto neutro] en accepted, verbo funcional
  treffen≠machen, Genitiv -s, vocab «invitado convocado»). `gen_course.py` robusto ante `prompt`/`topic` faltante.
- **HALLAZGO (fix de grading):** un MC de nominalización tenía distractor «Das lesen ist gesund.» que difería
  del correcto «Das Lesen…» SOLO en la mayúscula; `jz_grade` normaliza a minúsculas (near-match NO aplica a MC,
  pero el lowercase SÍ) → **aceptaba el distractor** (95/96 en el primer verify). Corregido (distractores
  Lesen/Lesung/Leser que difieren >1 char) + **guard norm-exacto en TODOS los B2** (0 colisiones) + prueba
  con cliente real de **los 92 distractores de MC/listening (0 aceptados)**. Lección: para MC, un distractor
  que solo cambia mayúscula/umlaut colisiona con el correcto bajo jz_normalize.
- **Verificado END-TO-END cliente real** (`verify_b2_chain.py de`, JWT): determinista B2 96/96 correctos +
  96/96 distractores (42501); **CAMINA A1→B2 las 24 unidades** (U18→U19 gating; 30/30 lecciones B2); **0
  lesson_items cruzan los 6 cursos**; default(en) sin fuga; audio HEAD 42/42. analyze 0.
- **Retome B2 es→nl (BLOQUEADO):** nl solo llega a A2 (B1 nl fue diferido) → hacer PRIMERO **B1 es→nl** (STAMP
  20260703120112) y LUEGO **B2 es→nl** (STAMP 20260703120116). Pipeline probado 3× (de B1, fr B1, de B2):
  6 agentes nativos nl (prompts s/de/nl + gramática nl del nivel) → rebalanceo/revisión → `gen_course.py nl
  <b1|b2>` → `gen_audio_missing.py nl-<b1|b2>` → `verify_<b1|b2>_chain.py nl`. Andamiaje completo listo.

---

## B1 es→fr (escalera A2→B1) — 2026-07-03 ✅ LIVE + VERIFICADO
> Tras alemán, **francés tiene B1 completo** (units 13-18). it/nl B1 diferidos con retome exacto.
- **Contenido (mig 113):** 6 unidades, **114 ítems R36/W36/L24/S18** (L=67% S=50%), audio TTS tl=fr **42/42**.
  Currículo B1 real: subjonctif présent, futur & conditionnel, pronoms relatifs (qui/que/dont/où), accord du
  participe passé, discours indirect, pronoms compléments (le/lui/y/en). Progresión desde A2.
- **Autoría:** 6 profesores nativos IA (spec estricta R6/W6/L4/S3) + **2 revisores/rebalanceadores nativos**
  (fixes reales: prompt español agramatical «tengas de la suerte», élision «pour qu'elle»/«s'il», un
  `accepted` que aceptaba «ou» [conjunción] por «où» [relativo] → removido, distractores audibles para el
  accord [prise/mise], «si j'aurais» usado como distractor incorrecto). `lesson`/`topic` preservados.
- **Verificado END-TO-END cliente real** (`verify_b1_chain.py fr`, JWT): determinista B1 96/96 correctos +
  96/96 distractores (42501); **CAMINA A1→B1 las 18 unidades** (U12→U13 gating; 30/30 lecciones B1); **0
  lesson_items cruzan los 6 cursos**; default(en) sin fuga; audio HEAD 42/42. analyze 0.
- **Retome EXACTO B1 es→it (diferido):** 6 agentes nativos it (mismos prompts que fr, s/francés/italiano)
  con gramática it: U13 congiuntivo presente (che io sia/faccia…), U14 futuro & condizionale (-ò vs -ei,
  periodo ipotetico), U15 pronomi relativi (che/cui/il quale), U16 concordanza del participio (essere→sogg.,
  avere+lo/la/li/le antepuesto), U17 discorso indiretto (che/se + concordanza), U18 pronomi (ci/ne/combinati
  glielo) → validar R6/W6/L4/S3 → `python gen_course.py it b1` (STAMP 20260703120114 reservado) →
  `python gen_audio_missing.py it-b1` → `python verify_b1_chain.py it`. Andamiaje completo listo.

---

## B1 es→de (escalera A2→B1) — 2026-07-03 ✅ LIVE + VERIFICADO
> de/nl llegaban a A2; ahora **alemán tiene B1 completo** (units 13-18, encadena A2→B1). nl B1 diferido con retome.
- **Contenido (mig 111):** 6 unidades, **114 ítems R36/W36/L24/S18** (L=67%, S=50% → objetivo cumplido),
  audio TTS tl=de **42/42**. Currículo B1 real: Konjunktiv II, Nebensätze/Konnektoren, Relativsätze, Passiv,
  Verben+Präposition/Genitiv, Konjunktiv II der Vergangenheit. Progresión coherente desde A2.
- **Autoría:** 6 profesores nativos IA (1 por unidad) + **2 revisores/rebalanceadores nativos** (una pasada
  que rebalanceó a R6/W6/L4/S3 y corrigió: distractores de listening que delataban la respuesta [«Glas Kuchen»→
  «Glas Wasser»], tolerancia ue↔ü faltante, verbo-final en Nebensatz/Relativsatz, Genitiv -s, elección
  haben/sein en Konjunktiv II, campos `lesson`/`topic` que un agente había omitido). `gen_course.py` ahora
  es robusto ante `topic` faltante (fallback).
- **Verificado END-TO-END cliente real** (`verify_b1_chain.py de`, JWT): determinista B1 96/96 correctos +
  96/96 distractores rechazados sin near-match (42501); **CAMINA A1→B1 las 18 unidades EN ORDEN** (U12
  desbloquea U13 → gating A2→B1 end-to-end; 30/30 lecciones B1 completadas); **0 lesson_items cruzan los 6
  cursos**; default(en) NO recibe B1 de; audio B1 HEAD 42/42. analyze 0.
- **Retome EXACTO de B1 es→nl (diferido):** 6 agentes nativos nl (mismos prompts que de, s/alemán/neerlandés)
  con gramática nl: U13 conditionalis (zou + inf), U14 bijzinnen & voegwoorden (omdat/hoewel/als/dat +
  daarom, werkwoord achteraan), U15 relatieve bijzinnen (die/dat/wie/waar), U16 lijdende vorm (worden +
  voltooid deelwoord), U17 vaste voorzetsels + «om…te» (wachten op, denken aan, houden van), U18 voltooid
  verleden/conditionalis verleden (zou hebben + deelwoord) → validar estructura R6/W6/L4/S3 → `python
  gen_course.py nl b1` (STAMP 20260703120112 YA reservado en STAMPS/DIFF) → `python gen_audio_missing.py
  nl-b1` → `python verify_b1_chain.py nl`. Todo el andamiaje (generador, audio, verificador) ya soporta nl b1.

---

## Idioma META en el onboarding (la puerta principal) — 2026-07-03 ✅ LIVE + VERIFICADO
> El onboarding era en-first: un usuario NUEVO siempre arrancaba en inglés (el "idioma" del onboarding
> era el de la APP, no el curso meta) → para aprender otro idioma había que terminar en inglés y cambiar
> en Ajustes. Ahora la puerta principal abre a los 6 idiomas.
- **Flujo real (Paso 0):** 10 pasos; paso "idioma"(1) = UI de la app; placement(7) con `p_course:null`→en;
  `create_plan`→jz_active_course=en (usuario nuevo sin `user_active_course`). Copy en-first
  (onbMotiveTitle/onbStartLevelTitle "…inglés…", onbLanguageInfoEn "aprenderás inglés").
- **Paso nuevo (2) «¿Qué idioma quieres aprender?»:** lista los 6 cursos activos (bandera + nombre en el
  idioma de la app vía `learnLangName`), **distinto e inequívoco** del idioma de la app. Al elegir →
  `set_active_course(<curso>)` (seguro en onboarding: `user_active_course` no FK-a public.users + trigger
  `on_auth_user_created` crea la fila). El placement (paso 8) corre con `courseId:<curso>` y `create_plan`
  (paso final) siembra ESE curso (jz_active_course ya = meta). Reusa `PlacementTest(courseId)` +
  `PlacementResultView` + `create_plan` (cableados en 15ebf20); NO duplica el motor.
- **Copy course-aware:** motive/nivel-inicial dicen el idioma elegido («¿Por qué aprendes alemán?»,
  «¿Cuánto alemán sabes ya?») con placeholder {course}; la nota del idioma-de-app ya no afirma inglés.
  6 nombres localizados × 3 locales (es/en/pt).
- **Degradación:** usuarios existentes no ven el onboarding (isOnboardingComplete). Default = elegir
  inglés → comportamiento idéntico al previo. `create_plan` sigue con fallback en si nunca se eligió.
- **Verificado END-TO-END cliente real** (`verify_onboarding_target.py`, JWT, usuarios NUEVOS): nuevo cuya
  1ª elección es alemán + responder A2 → **A2 alemán, entra en U7** (no inglés, no A1); **SIN progreso en
  inglés** (no lo eligió); placement usó SOLO el banco alemán; nuevo principiante→nl A1/U1; nuevo→inglés
  B1 sin cambio; 42501. +widget test del paso meta (`onboarding_target_test`). analyze 0 · test 93/93.
- **Diferido:** L/S en placement (audio) + nombre real de la unidad de entrada por curso (rótulo es→en) +
  cap de la meta al tope del curso (fr/it/de/nl topan A2) + copy en-first fuera del onboarding
  (missionMainDescription "100 palabras del inglés", errorReviewWhy*).

---

## Re-placement no-inglés cableado al flujo real — 2026-07-03 ✅ LIVE + VERIFICADO
> Los bancos fr/it/de/nl (mig 110) existían pero NINGÚN flujo de UI los disparaba: onboarding en-only +
> cambio de curso sin re-ubicar → un aprendiz de alemán SIEMPRE caía en A1. Cerrado el grifo.
- **Flujo real (Paso 0):** onboarding en-first (su paso "idioma" es el de la APP, no el curso meta; placement
  con `p_course:null`→en). Un no-inglés llega SOLO por el selector de Ajustes, que hacía `setActiveCourse`
  sin placement → A1.
- **Decisión de UX:** cablear el **cambio de curso en Ajustes** (donde se elige un curso no-en), no el
  onboarding (en-first en todo su copy → rediseñarlo = amplitud/riesgo). Al tocar otro curso, diálogo
  «¿Hacer el test de ubicación?» → [Hacer el test] corre el placement de ESE idioma; [Empezar desde el
  principio] = comportamiento previo.
- **Reuso, sin duplicar el motor:** `placementNext(courseId)` (null=en); `CoursePlacementScreen` orquesta
  `PlacementTest(courseId)` + `PlacementResultView` (reutilizadas, localizadas es/en/pt) → aplica nivel con
  `create_plan` (course-scoped a jz_active_course, ya activado). `fetchPlan`/`userPlanProvider` course-aware
  (el re-placement crea 1 fila de plan por curso → sin course-scope, `single` fallaría: regresión evitada).
- **Verificado END-TO-END cliente real** (`verify_placement_wiring.py`, JWT): cambiar a de/nl/fr/it +
  responder A2 → ubica **A2** + entra en **U7** (primera A2, no A1); principiante → **A1/U1**; el placement
  usa SOLO el banco de ese curso; **EN INTACTO** (progreso U13/B1 + plan) tras re-ubicar los otros; 42501
  (grade_item correcto/​distractor). `placement_flow_test` verifica la propagación de courseId. analyze 0 ·
  test 92/92.
- **Diferido:** selector de curso meta en el onboarding (hoy en-first) + L/S en placement (audio) + nombre
  real de la unidad de entrada por curso en la pantalla de resultado (la unidad real ya es correcta; solo el
  rótulo mostrado usa el nombre es→en).

---

## Bancos de placement fr/it/de/nl — 2026-07-03 ✅ LIVE + VERIFICADO
> El test de ubicación ubicaba bien en en (A1-C1) y pt (A1-B1); fr/it/de/nl no tenían banco → todo
> aprendiz caía a A1. Cerrado: ahora ubican en su nivel real DENTRO de los niveles sembrados (A1-A2).
- **Banco (mig 110):** 112 ítems = 28/curso (A1+A2 × 7 reading MC + 7 writing cloze), cubren SOLO A1-A2
  (los niveles que existen) → **techo honesto A2** (análogo al techo B1 de pt): no ofrecen ubicar donde
  no hay contenido. Autorados por profesores nativos IA + gramática real por idioma (avoir/avere edad,
  passé composé/passato prossimo/Perfekt/Perfectum sein/zijn, imparfait/imperfetto/Präteritum,
  comparativo als/dan, acusativo einen, de/het). `correct_answer` oculto (42501).
- **Cableado = el propio banco:** `placement_next(p_course)` ya es course-scoped (selecciona ítems
  WHERE course_id=p_course AND 'placement'=any(tags) y estima el techo con evidencia sobre ese curso).
  **NO se tocó el RPC** — sembrar el banco basta.
- **Validación adversarial nativa por idioma:** fr 1 fix («aussi…que» = comparativo de igualdad, 2ª
  respuesta válida → «beaucoup»); nl 1 fix («hebben» defendible porque «zij»=ella/ellas → «waren»);
  it 0, de 0. **Mejora:** `gen_placement_multi.py` incluye una **guarda anti-colisión AUTOMÁTICA** que
  asevera que ningún distractor de cloze sería perdonado por `jz_near_match` (indel dist-1 en palabra
  única; cualquier edición dist-1 en multi-palabra) — atrapó colisiones reales (nl ben/bent) en la 1ª pasada.
- **Verificado cliente real (`verify_placement_multi.py`, JWT, nunca service_role):** determinista
  28/28 correctos + 28/28 distractores rechazados sin near-match por idioma; personas **A1→A1, A2→A2,
  avanzado→A2** (techo honesto, no promueve por azar) en los 4; **aislamiento: placement_next(fr/it/de/nl)
  sirve SOLO su curso; placement_next(en) sin fuga → 0 cruces entre los 6 cursos**; en/pt INTACTOS
  (verify_placement + verify_placement_pt PASS). analyze **0** · test **91/91**.
- **Diferido (retome):** cablear el placement por-idioma a un onboarding/re-placement (hoy en-only Fase 1;
  el curso se cambia en Ajustes) + L/S en placement (audio). B1+ fr/it/de/nl no existe → banco tope A2 correcto.

---

## Inmersión pt/de/nl + tips pt A2/B1 — 2026-07-03 ✅ LIVE + VERIFICADO
> Cierre de la capa "enseña" en los 6 cursos: inmersión completa (los 6 con historia) + tips pt hasta B1.
- **Historias A1 pt/de/nl (mig 109):** +3 historias — pt «A padaria da Ana» (Rio, pão de queijo,
  café com leite, «queria» de cortesía), de «Beim Bäcker» (Bäckerei, acusativo einen↔ein, Sie,
  mayúsculas), nl «De koffie van Sanne» (fiets, de/het, V2, «Ik wil graag») → **los 6 cursos con ≥1
  historia**. Cada una 7 segmentos + audio tl correcto (21/21 HEAD 200) + glosario + 5 preguntas MC.
  **Validación adversarial nativa (pt-BR/de/nl): 0 errores reales**, 1 pulido pt («quentinho» al glosario) aplicado.
- **Tips es→pt A2/B1 (mig 108):** +12 tips (units 7-18) → **pt tips A1+A2+B1 completos** (18). A2:
  pretérito perfeito, futuro «vou»+inf, pegar o ônibus, a conta/garçom, ser/estar, «estou com dor».
  B1: imperfeito, condicional «gostaria», subjuntivo, relativos, «deu problema/tem jeito», comparativos.
  `gen_tips_multi.py` ahora deriva cefr A1/A2/**B1** por unit_order.
- **Verificado cliente real:** `verify_stories_multi.py` — 6 cursos, cada uno ve SOLO sus historias
  (en=6, pt/fr/it/de/nl=1, **0 cruces**); get_story no expone `correct_answer`; submit_story server-side
  (correctas 1.0/erróneas 0.0, 42501); `stories.questions` revocada; audio 21/21. Tips pt: cada
  lección pt U7-18 devuelve su tip; con fr activo **0 cruces**. analyze **0** · test **91/91**.
- **Diferido (retome):** 2ª historia por idioma + historias B1+; **B1 de/nl** (hoy A1+A2).

---

## Capa "enseña" — tips A2 de/nl + historias fr/it — 2026-07-03 ✅ LIVE + VERIFICADO
> Dos frentes de la capa "enseña", ambos course-scoped y verificados con cliente real.
- **Tips A2 de/nl (mig 106):** +12 tips (6 de + 6 nl, units 7-12) → tips A1+A2 completos en los 4
  pilotos (fr/it/de/nl). Perfekt/Perfectum, futuro, comparativo als/dan, Präteritum/imperfectum,
  wehtun/hoofdpijn. Verificado cliente real: de U9(A2)→tip de, nl U9(A2)→tip nl, en control intacto.
- **Historias / inmersión multi-idioma (mig 107):** 1ª historia por idioma para fr y it (antes solo
  es→en tenía 6): **«Le café de Léa»** (fr, café parisino) y **«Un caffè al bar»** (it, bar romano),
  A1, 7 segmentos (texto meta + traducción es + **audio TTS tl=fr/it, 14/14 HEAD 200**) + 6 glosario
  + 5 preguntas MC. Autoradas por profesores nativos IA. Pipeline reutilizable `gen_stories.py` +
  `gen_story_audio_multi.py` (audio por segmento, misma convención `-<i>.mp3` que es→en).
  - **Verificado cliente real (multicurso + seguridad):** `get_stories` course-scoped (fr ve solo su
    historia, it la suya, en solo las 6 en — **sin cruce entre los 6 cursos**); `get_story` **NO
    expone `correct_answer`** (igual que el loop); `submit_story` califica **server-side** (respuestas
    correctas → score 1.0, erróneas → 0.0; `correct_answer` 42501 vía jz_grade). Audio HEAD 200.
  - **Nota de verificación:** el `answer` de submit_story es el valor BARE del MC (así lo manda el
    cliente `story_reader_screen.dart:79`), no `{value:…}` — jz_grade lo confirma.
- analyze 0 · test 91/91. Cursos/loop/seguridad previos INTACTOS (aditivo, solo tablas content_tips/stories).
- **Diferido:** historias pt/de/nl + más historias por idioma; tips es→pt A2/B1.

---

## A2 es→de + es→nl — 2026-07-03 ✅ LIVE + VERIFICADO (cliente real, 6 cursos aislados)
> Continúa la escalera A1→A2 de los pilotos alemán/neerlandés. Autoría por workflow ultracode
> (6 profesores nativos, 2 unidades c/u) + revisión adversarial nativa por idioma.
- **Sembrado (mig 104 de / 105 nl):** 6 unidades A2 (order 7-12) por idioma, encadenadas con A1.
  **115 ítems/idioma** (R36/W36/L25/S18 → L=69%, S=50%). Audio TTS tl=de/nl **43/43 cada uno**.
  Temas: Perfekt/Perfectum (haben/hebben U7 → sein/zijn+concordancia U9), futuro (Präsens+werden /
  gaan+zullen U8), viaje, comer fuera/comparativo (als/dan, größer/groter, meilleur→besser/beter U10),
  Präteritum war-hatte / imperfectum was-had + descripción U11, cuerpo+salud (wehtun con dativo /
  hoofdpijn compuesto, consejos sollen/moeten U12).
- **Calidad — revisión adversarial nativa:** de **0 ❌** + 1 pulido (podadas 2 variantes de orden
  marcado TeKaMoLo en el `accepted` de U9); nl **0 ❌ + 0 ⚠️** (impecable). El revisor de estresó
  auxiliar haben/sein, participios (gegessen no gegesst), orden V2/verbo-final, comparativo con als
  (no wie) + Umlaut, wehtun con dativo — todo correcto. nl: hebben/zijn, participios, de/het, dan (no
  als), compuestos de dolor en una palabra — todo correcto.
- **Aislamiento 6 cursos — VERIFICADO cliente real** (`verify_a2_chain.py de|nl`, JWT): **0 cruces**;
  determinista A2 de 97/97 + nl 97/97 correctos + 97/97 distractores (42501); **CAMINATA de las 12
  unidades EN ORDEN** (U6 desbloquea U7, gating A1→A2 end-to-end, 30/30 lecciones A2 completadas);
  default(en) sin fuga; audio HEAD 43/43. Cursos previos INTACTOS (verify_chain en · verify_pt_chain pt).
  `analyze` 0 · `test` 91/91. **Nota:** el límite de sesión cortó la fase de revisión del workflow,
  PERO los 12 JSON ya estaban escritos → se completó con revisores adversariales por separado + el gate
  determinista/aislamiento (objetivo) que pasó en verde.
- **Diferido:** B1+ de/nl; tips A2 de/nl; placement de/nl; historias.

---

## Capa "enseña": tips A1 para fr/it/de/nl — 2026-07-03 ✅ LIVE + VERIFICADO (course-scoped)
> Hueco: el tip post-lección (aparece tras CADA lección) existía **solo para es→en** (72 tips);
> los otros 5 cursos caían a null (sin consejo). Frente de alta frecuencia/impacto.
- **Sembrado (mig 102, aditiva):** **24 tips A1** (6/curso × fr/it/de/nl), uno por unidad = el
  punto gramatical CLAVE: edad (avoir/avere/sein/zijn — con el contraste ser/tener explicado),
  partitivo (du/del) / acusativo (einen), la hora + falsos amigos («halb vier»/«half vier»=3:30;
  «midi et demi»), contracciones (au/du) / preposizioni articolate (al/alla/dalla), de-vs-het,
  mein/meine por género. title+body en español (didáctico), example en el idioma meta. Autorados
  por 4 profesores nativos IA; revisión propia halló y corrigió 1 error (título nl U2 contradictorio
  «se TIENE con zijn» → «va con zijn»); el resto (de/fr/it) impecable.
- **Aislamiento multicurso — VERIFICADO cliente real:** `get_lesson_tip` filtra por
  `course_id=jz_active_course()`. Con un usuario JWT por curso y una lección de la unidad 2:
  **en→tip inglés · fr→fr · it→it · de→de · nl→nl** (cada uno recibe SU tip, ninguno cruza).
  El match usa topic (tag del ítem) O unit_order → toda lección de la unidad recibe su tip.
  Cursos existentes intactos (en sigue devolviendo sus 72 tips). analyze 0 · test 91/91.
- **Diferido (retome exacto):** (1) **tips es→pt** — los topics de pt son auto-generados/largos del
  pipeline L/S (p.ej. `decir_tu_nombre_y_dar_tu_identidad_con_ser`) y su currículo A1 tiene otra
  estructura temática → requiere su propia pasada (autorar 6 tips pt keyed por `unit_order`). (2)
  **tips A2 fr/it** (units 7-12). (3) **historias/inmersión** para pt/fr/it/de/nl (hoy solo es→en, 6).

---

## Pilotos es→de + es→nl (A1) — 2026-07-03 ✅ LIVE + VERIFICADO (cliente real, 6 cursos aislados)
> 5º y 6º curso. Objetivo: A1 completo e impecable en alemán y neerlandés, con **aislamiento
> multicurso** blindado (ahora **6 cursos** — el riesgo #1). Fuente de verdad = repo+BD (de/nl NO existían).

**Sembrado (mig 100 de / 101 nl):** cada curso = alta de idioma + curso `is_active` + A1 completo
(6 unidades × [4 lecciones + checkpoint + examen], molde es→fr/it). **115 ítems/curso** (R36/W36/L25/S18
→ L=69%, S=50%). Audio TTS tl=de/nl **43/43 cada uno**. Autorado por **workflow ultracode**: 6 profesores
nativos IA (3 de + 3 nl, 2 unidades c/u) + 2 revisores adversariales nativos estructurados.

**Gramática real:** de — der/die/das, **edad con SEIN** (Ich bin 20 Jahre alt, NO haben), sustantivos con
mayúscula, acusativo ein→einen, du/Sie, ß/ä/ö/ü con tolerancia ss/ae/oe/ue en `accepted`. nl — **de/het**
(het water/brood/station/museum/restaurant/hotel/kind), **edad con ZIJN** (Ik ben 20 jaar oud), diminutivos
-je, orden V2. **Revisión adversarial:** de 2 ❌ menores (distractores word_bank: `ist`→`bist`, quitar `nach`),
nl 3 reales (calco «Ik ben goed»→«Het gaat goed»; «Ik hou van…» no enseñado→«Dit is mijn familie»; quitar
distractor `voor` ambiguo) — **todos aplicados**. Los 2 "listening con doble correcta" que el revisor marcó
fueron **retirados por él mismo** (verificados: una sola respuesta).

**Aislamiento de los 6 cursos — VERIFICADO cliente real** (`verify_new_course.py de|nl`, JWT):
- **0 `lesson_items` cruzan los 6 cursos** (en/pt/fr/it/de/nl).
- Determinista de 97/97 + nl 97/97 correctos; 97/97 + 97/97 distractores (grading server-side, `correct_answer` 42501).
- `set_active_course(de|nl)` → `create_plan`/`start_practice`/`user_course_progress` sirven SOLO ese curso;
  usuario default(en) NO recibe de/nl; cadena lección(100%)+checkpoint(≥80%) por curso; audio HEAD 200.
- **Cursos existentes INTACTOS:** `verify_chain` (en A1→B2 + certs) y `verify_pt_chain` (pt A1→B1) verdes.
  `flutter analyze` 0 · `flutter test` 91/91. Banderas 🇩🇪/🇳🇱 + `SpeechLang` de-DE/nl-NL cableados.

**Diferido:** A2+ de/nl; placement de/nl (default→A1); tips/historias/imágenes; onboarding de/nl-específico.

---

## Multi-idioma del cliente (VOZ + Conversar) — 2026-07-02 ✅ REPARADO
> Dos bugs de la misma clase: **el cliente asumía inglés** aunque el curso fuera pt/fr/it.
- **VOZ (TTS de tile + reconocedor de speaking)** estaba hardcodeada a inglés (`word_tts_web`
  `lang='en-US'`, `speaking_exercise` `localeId='en_US'`) → en pt/fr/it la voz no correspondía
  al idioma (feedback real "voz correspondiente al idioma"). **Fix:** `SpeechLang` (estático,
  fijado en `HomeShell` desde `activeCourseTargetProvider`) → en-US/pt-BR/fr-FR/it-IT.
- **Conversar** tenía los 6 topics con model+tips **solo en inglés** → pt/fr/it veían inglés
  (roto para 3 de 4 cursos, feature visible en la pestaña 2). **Fix:** `ConvTopic.models` = mapa
  por idioma META (en/pt/fr/it); `ConversarScreen` resuelve con `activeCourseTargetProvider` +
  `modelFor(lang)` (fallback en). Model+tips autorados por **profesores nativos** (pt-BR/fr/it,
  `gen_conversar.py`); títulos/escenarios ES compartidos. Su reconocedor de voz → `SpeechLang.stt`.
- **Verificación:** unit tests (`speech_lang_test`, `conversar_topics_test` = 6 topics × 4 idiomas ×
  3 tips + fallback) + **cliente real** (`get_courses` da el `target` correcto por curso activo:
  en/pt/fr/it) + analyze 0 + test 91/91. Multicurso intacto (client-side, no toca BD/contenido).
- **Diferido:** capa "enseña" (tips/historias/imágenes/placement) sigue casi solo es→en (contenido
  por idioma); conversación EN VIVO = Fase 2.

---

## Pilotos es→fr + es→it — NIVEL A2 — 2026-07-02 ✅ LIVE + VERIFICADO (cliente real)
> Continuación del piloto: **A2 completo** para AMBOS idiomas (fr/it), encadenado sobre el A1.
> Fuente de verdad = repo+BD (los docs estaban al día; A2 NO existía → construido desde cero).

**Estado real al arrancar (Paso 0, verificado con BD):** último commit `1f10f3e`, última mig `096`;
**A2 fr/it NO existía** (fr/it solo A1). `create_plan` en vivo YA usa `jz_active_course` (mig 096 efectivo);
ninguna RPC hardcodea el curso. Desbloqueo de unidad = por `order_index > actual` del MISMO curso
(course-scoped) → sembrar A2 en order 7-12 encadena tras A1.

**Sembrado (mig 097 fr / 098 it):** 6 unidades A2 por idioma (order 7-12), 4 lecciones + checkpoint +
examen por unidad. **115 ítems/idioma** (R36/W36/L25/S18 → L=69%, S=50%). Currículo A2 real por idioma:
- **fr:** passé composé (avoir U7 → être+accord U9), futur proche/simple (U8), comparatifs + «en» (U10),
  imparfait + pronoms COD (U11), «avoir mal à»+contraction + conseils (U12).
- **it:** passato prossimo (avere U7 → essere+accordo U9), futuro semplice (U8), comparativi di/che +
  «ne» (U10), imperfetto + pronomi diretti (U11), «avere mal di» (sin artículo) + consigli (U12).
Autorado por profesores nativos IA + generador PARAMETRIZADO POR NIVEL `gen_course.py <code> <a1|a2>`.

**Calidad (validación adversarial nativa A2):** **fr 0 ❌ + 2 ⚠️** (quitado `d'` indebido en «un kilo de
pommes»; gloss) — aplicados. **it 0 ❌ + 2 ⚠️** (enunciado del cloze «non ancora» afinado) — aplicado.
Gramática crítica impecable en ambos (participios, auxiliar+concordancia, raíces de futuro, comparativos,
imperfecto, pronombres objeto, «mal di»/«mal à»). Además corregido el título it A1 «Unité»→«Unità».

**Verificación A2 — cliente real** (`verify_a2_chain.py fr|it`, JWT real):
- **0 `lesson_items` cruzan los 4 cursos**; determinista A2 fr 97/97 + it 97/97 correctos y 97/97 distractores.
- **CAMINATA de las 12 unidades EN ORDEN con cliente real** (complete_lesson + submit_checkpoint): llega a
  U12, **checkpoint U6 (última A1) DESBLOQUEA U7 (primera A2)** → gating A1→A2 end-to-end; **30/30 lecciones
  A2 completadas**. Audio A2 HEAD **43/43** (fr y it). Usuario default(en) NO recibe A2 de fr/it.
- **Cursos existentes INTACTOS:** `verify_chain` (en A1→B2 + certs) y `verify_pt_chain` (pt A1→B1) verdes.
  `flutter analyze` 0 · `flutter test` 89/89.

**Diferido:** B1+ fr/it; placement fr/it; cert de nivel; onboarding fr/it-específico.

---

## Pilotos es→fr + es→it (A1) — 2026-07-02 ✅ LIVE + VERIFICADO (cliente real)
> 2 cursos NUEVOS. Objetivo: A1 completo e impecable en francés e italiano, con **aislamiento
> multicurso** blindado (el riesgo #1 — ya se rompió una vez con pt, mig 064→072).

**Sembrado (mig 094 fr / 095 it):** cada curso = alta de idioma + curso `is_active` + **A1 completo**
(6 unidades temáticas × [4 lecciones `lesson` + 1 `checkpoint` + examen de checkpoint], molde es→pt).
**115 ítems/curso**, 4 habilidades balanceadas desde A1:
- **fr** (`…0003`, Français): R38 · W36 · L23 · S18 → **L=62%, S=49%** de (R+W)/2. Audio tl=fr **41/41**.
- **it** (`…0004`, Italiano): R36 · W36 · L25 · S18 → **L=69%, S=50%**. Audio tl=it **43/43**.
Autorado por **profesores nativos IA** (fr/it, no traducción mecánica), generador reutilizable
`tools/content/gen_course_a1.py <code>` (JSON por unidad → migración; ids uuid5 idempotentes).

**Calidad (validación adversarial nativa):**
- **fr:** 1 ❌ real → `midi et demie` corregido a **`midi et demi`** (demi es masc. con *midi/minuit*)
  + 2 ⚠️ menores (match de nacionalidades a género consistente; `banca`→`banco` en enunciado ES). Todo aplicado.
- **it:** **0 ❌**, 5 ⚠️ de tolerancia/distractores → 4 aplicados (distractor `Ho venti`→`Ho vent'anno`;
  `accepted` de precios/`È`/`C'è` depurados). Gramática crítica impecable: **avere para la edad**, partitivo
  concordado (del/della/dell'), preposizioni articolate (al/alla/dalla), posesivos de parentesco (mio fratello
  / i miei genitori), hora singular/plural (È l'una vs Sono le…). Ningún MC/listening ambiguo.

**Aislamiento multicurso — VERIFICADO con cliente real** (`verify_new_course.py fr|it`, JWT real, jamás
service_role):
- **0 `lesson_items` cruzan los 4 cursos** (en/pt/fr/it).
- Determinista: fr 97/97 + it 97/97 correctos aceptados; 97/97 + 97/97 distractores rechazados
  (grading server-side, `correct_answer` **42501**; el admin solo lee respuestas como andamiaje del test).
- `set_active_course(nuevo)` → `create_plan`/`start_practice`/`user_course_progress` sirven **SOLO** ese curso;
  usuario default(en) NO recibe ítems fr/it; cadena lección(100%)+checkpoint(≥80%) por curso; audio HEAD 200.
- **Cursos existentes INTACTOS:** `verify_chain` (es→en A1→B2 + certs + per-skill) y `verify_pt_chain`
  (es→pt A1→B1 multicurso + certs) **verdes tras el fix compartido**.

**Fix de fondo `create_plan` (mig 096):** ignoraba el curso activo (hardcodeaba el más-antiguo-activo=en) →
sembraba plan/progreso en el curso equivocado con >1 curso. Ahora `jz_active_course()`. **Cero regresión en
es→en** (usuario nuevo sin `user_active_course` → mismo fallback=en). No afloraba en la app (el onboarding usa
en por defecto; el cambio de curso va por `start_course` en Ajustes), pero el fix es correcto y future-proof.

**CI/deploy:** `flutter analyze` 0 issues (añadidas banderas 🇫🇷/🇮🇹 al selector), `flutter test` 89/89.
Contenido DB-driven → LIVE al aplicar migración (sin depender del deploy). **Retome del piloto:** A2+ fr/it,
banco de placement fr/it (hoy default→A1), onboarding fr/it-específico, tips/historias/imágenes, cert de nivel A1.

---

## i18n — COBERTURA EXTENDIDA (home/mapa · ligas · tienda/racha · perfil) — 2026-07-02 ✅ LIVE
> La infra i18n ya existía (onboarding+auth+loop). Esta tanda EXTIENDE la cobertura a las
> superficies más visibles que quedaban en español. ~200 claves nuevas es/en/pt.

**Superficies traducidas al 100% (es/en/pt):**
- **Home/mapa:** `learn_map_screen` (carga/error/vacío, nodos bloqueados, banners de unidad,
  cima/certificado, mascota), `learn_top_bar` (a11y de música + notificaciones; la barra de plan
  es solo niveles/%, técnica → no se traduce), `mission_screen` (appbar, título, descripción,
  categorías, botón). La barra de navegación inferior es **solo íconos** (nada que traducir);
  `_sections` queda como clave de analítica (no visible).
- **Ligas + leaderboards:** `leagues_screen` completo — segmentos (Mi liga/Tablas), cabecera de
  liga, "arrancando", zonas de ascenso/descenso, "clasificación de la semana"; leaderboards
  (métricas XP/Lecciones/Racha/Certificados + unidades, ventanas Semanal/Mensual/Anual/Histórico,
  alcance Global/División, tu posición, estados vacíos/error). **División localizada** con helper
  `division_names.dart` (como `skill_names.dart`); `_metrics`/`_windows` pasan a claves técnicas +
  resolución i18n en build.
- **Tienda + racha:** `tienda_screen` (appbar + tarjetas cofre/vidas/congelador con contadores),
  `streak_screen` (título, contador con plural, récord, hitos estado/próximo/bloqueado, sección
  congelador, "Comprar"). Los toasts ya estaban migrados.
- **Perfil:** `profile_screen` (4 habilidades, alerta de desbalance, stats, plan con fecha/estado,
  certificados, examen + gate de dominio, "Para ti", cuaderno) y `edit_profile_sheet` (formulario).
  **Fechas** con `MaterialLocalizations.formatMediumDate/formatMonthYear` (adiós arrays de meses
  hardcodeados); **plurales** (racha, jugadores, días, habilidades); reutiliza `skillName()` y
  `planFocus*` (sin duplicar claves).

**Verificación:** `i18n_test.dart` extendido (las superficies nuevas cambian por idioma; plurales/
placeholders/división por idioma). analyze 0 · test verde · build web OK.

**Diferido (sigue en español, punto de retome — mismo patrón: inventariar → claves ARB es/en/pt →
migrar → analyze):** Ajustes (cuerpo, salvo el selector de idioma ya migrado), práctica (SRS/débil/
timed), notificaciones/Matix, inmersión/historias, level_exam, premium, legal (texto sustantivo —
además requiere abogado), reference, notebook. Distinción intacta: i18n = chrome de la app; el
CONTENIDO del curso (lecciones/ejercicios en la DB) NO se toca.

---

## BANCO DE PLACEMENT es→pt (a la par de es→en) — 2026-07-02 ✅ LIVE
> El placement PRECISO era solo inglés; portugués quedaba sin banco de ubicación. Cerrado.
> (L/S balance + auditoría de eficacia + audio de es→pt A1–B1 YA estaban hechos, mig 083–085;
> verificados de nuevo esta sesión con verify_pt_chain. El hueco real era el banco de placement.)

- **Banco (mig 093):** 42 ítems de ubicación es→pt, A1/A2/B1 × **7 reading (MC) + 7 writing (cloze)**,
  curso `…0002`, tag `placement` (excluido de pools de lección/examen). Generados por
  `tools/content/gen_placement_pt.py` (uuid5 estable, idempotente). Portugués de Brasil.
- **Calidad:** revisión adversarial por profesor pt-BR nativo → **39/42 impecables**; 1 fix
  obligatorio (regência "assistir **a** um filme"); 2 distractores endurecidos. **Guardas
  anti-colisión** para `jz_near_match` (que perdona inserción/borrado a distancia-1 incluso en
  palabra única, y NO quita acentos): los cloze no tienen ningún distractor a distancia-1 del
  correcto (p.ej. se evitó `livro`/`livros`, `que`/`quem`, `esquece`/`esqueceu`, `dormi`/`dormia`);
  reading = multiple_choice (selección exacta, `jz_near_match` no aplica).
- **Verificado cliente real (`tools/content/verify_placement_pt.py`):**
  - Determinista **42/42** en ambos sentidos: cada correcto → `correct=true`; cada distractor →
    `correct=false` (sin near-match espurio). `correct_answer` 42501 (leído solo por admin de test).
  - **Personas:** A1→A1, A2→A2, B1→B1, "avanzado"→**B1** (techo honesto: el curso pt tope es B1).
  - **Multicurso:** todos los ítems que `placement_next(pt)` devuelve son del curso pt;
    `placement_next(en)` **nunca** devuelve un ítem pt (0 fuga). El estimador v2 "techo con
    evidencia" (jz_placement_level) es agnóstico y funciona para pt.
- **verify_pt_chain PASS** (re-verificado): cadena es→pt A1→A2→B1 (exámenes + certificados +
  per-skill) con `set_active_course(pt)`, sin cruce con inglés.
- **Diferido (reportado):** (1) **cablear** el placement pt a un flujo de usuario — hoy el
  onboarding es **en-only (Fase 1)** y `create_plan`/`placement_next` por defecto usan el curso
  activo más antiguo (en); el banco pt queda **listo a nivel RPC** (`placement_next(p_course=pt)`),
  pendiente de un onboarding/re-placement pt (requiere hacer `create_plan` consciente del curso —
  riesgo multicurso, fuera de alcance de esta tanda). (2) **L/S en placement** (audio) en ambos
  cursos. (3) es→pt B2/C1 no existen (el curso pt llega a B1).
- **Verificación toolchain:** analyze 0 · test 88/88 (sin cambio Dart) · el placement es
  reading+writing → **sin audio que generar**.

---

## P1/P2 DE RETENCIÓN Y SENSACIÓN — 2026-07-02 ✅ LIVE
> Cierra P1-3 y varios P2 de QA_AUDIT.md (ver §0.1 ahí). Todo verificado con cliente real.

- **Meta diaria visible (P1/top-5):** la top bar del mapa ahora muestra una **pastilla "X/Y"**
  (mini-anillo + número), antes era un anillo mudo. Distinta del progreso del PLAN. i18n es/en/pt.
- **Combo en vivo (P2-3):** chip **"🔥 x{n}"** animado (elasticOut) en la top bar de la lección
  desde 3 aciertos seguidos; el contador (`_comboCorrect`) ya existía, faltaba mostrarlo.
- **Feedback de oro (P2-1):** cofre/vidas/congelador ahora dicen **"ganaste/gastaste X, te quedan Y"**
  (las RPC ya devolvían `gold`). Localizado. `streak_screen` alineado.
- **Misión inicial (P1-3, `mig 091`):** bono de **bienvenida one-time (25 XP + 25 oro)** — NO alimenta
  racha/meta (esas empiezan con la 1ª lección) — + **diálogo de confirmación** "¡Tu viaje ha comenzado!".
  Idempotente (relee estado; 2ª vez otorga 0). verify_mission_reward.py 4/4.
- **Race del cofre (P2-4):** guard `if (_busy != null) return;` en tienda + freeze (el botón ya se
  deshabilitaba con `busy`; esto blinda el doble-tap en el mismo frame).
- **Zonas de liga en beta (P2-9, `mig 092`):** `get_league` devuelve **promote/demote=0 hasta 13
  jugadores** (== gate real de `jz_close_weeks`); la UI solo pinta zonas de ascenso/descenso con
  `movementActive` y muestra una **nota de beta** cuando aún no hay movimiento. Copia verbatim de
  get_league salvo esa condición → **sin fuga de user_id** (verificado en vivo).
- **Hito de racha (P2-2):** ya estaba presente (cartel dorado + 🏆 + confeti en lesson_complete); verificado.

**Verificación:** analyze 0 · test 88/88 (incl. `retention_test`, `i18n_test`) · build web OK ·
verify_streak_freeze 7/7 · verify_mission_reward 4/4 · get_league promote/demote=0 sin leak.

**Prueba manual (Gian, Android):**
1. **Meta diaria:** en el mapa, arriba a la derecha, ves "X/Y" (p.ej. 0/10). Completa una lección → sube.
2. **Combo:** en una lección, acierta 3+ seguidas → aparece "🔥 x3, x4…"; falla → desaparece.
3. **Oro:** abre el cofre / recarga vidas / compra congelador → el toast dice cuánto ganaste/gastaste y el saldo.
4. **Misión:** toca el primer nodo (misión) → "¡EMPEZAR MI VIAJE!" → sale el diálogo con +25 XP/+25 oro (solo la 1ª vez).
5. **Ligas:** con pocos jugadores (beta) NO debe haber "zona de descenso" cubriendo casi toda la tabla;
   en su lugar, una nota de que aún no hay ascensos/descensos.

**Diferido (reportado):** a11y amplia (device), precios hardcodeados, colores sueltos, infra de bots,
deuda técnica de leaderboards, i18n de superficies fuera de onboarding/loop (ligas/tienda/mapa siguen
en español salvo los strings nuevos añadidos aquí).

---

## FIX P0 CONGELADOR DE RACHA + i18n REAL (es/en/pt) — 2026-07-02 ✅ LIVE
> Cierra el P0 y el P1-idioma de QA_AUDIT.md. Dos commits separados.

### Tarea 1 — Congelador de racha (P0, `mig 090`, server-side)
- **Bug:** `use_streak_freeze()` cobraba 50 oro y sumaba `streaks.freezes_available`, pero
  `jz_register_activity` **nunca lo consumía** → tras saltarse un día la racha se reseteaba igual.
- **Fix:** al registrar actividad tras un HUECO, si hay freezes SUFICIENTES para cubrir todos los días
  perdidos, se consumen y la racha CONTINÚA (hoy incrementa; los días perdidos no suman, pero no
  resetean). Sin freezes suficientes → resetea como antes. Un freeze = un día. Idempotente el mismo día.
  `complete_lesson`/`submit_checkpoint` propagan `streak_freeze_used`; la pantalla de fin muestra
  "🧊 Tu congelador salvó tu racha".
- **Verificado (cliente real, JWT):** `tools/content/verify_streak_freeze.py` 7/7 — hueco=1 con freeze
  (racha 10→11, freeze consumido), hueco=1 sin freeze (reset a 1), hueco=2 con 1 freeze insuf. (reset sin
  malgastar), hueco=2 con 2 freezes (continúa, consume 2), consecutivo con freeze (no consume),
  idempotencia mismo día, compra (−50 oro/+1 freeze). Test Dart del contrato en `streak_meta_test`.
- **Prueba manual (Gian, Android):** compra un congelador (Ajustes/tienda, −50 oro), salta un día,
  completa una lección al día siguiente cumpliendo la meta → la racha se mantiene (+1) y aparece el aviso
  🧊; el contador de congeladores baja en 1. Sin congelador, la racha vuelve a 1.

### Tarea 2 — i18n real (P1-idioma, es/en/pt)
- **Bug:** el selector de idioma era cosmético (sin infra l10n; nada consumía `localeProvider`).
- **Fix:** `flutter_localizations`+`intl`+gen-l10n; `MaterialApp` consume el `Locale` (persistido) →
  cambio instantáneo. Selector NUEVO en **Ajustes** ("Idioma de la app") + cambio en vivo en el onboarding.
  Traducido 100% es/en/pt: **onboarding+auth** y **loop de lección completo** (ver fila i18n en CLAUDE.md).
  Distinción respetada: i18n = chrome de la UI; el CURSO (es→en/es→pt) es contenido de la DB, intacto.
- **Verificado:** `i18n_test.dart` (el locale cambia el texto; plurales/placeholders/duración/skills por
  idioma). analyze 0 · test 86/86 · build web OK · 0 strings hardcodeados en lo migrado.
- **Prueba manual (Gian, Android):** Ajustes → "Idioma de la app" → English/Português → toda la UI de
  onboarding y del loop cambia al instante; volver a Español la restaura. El "Idioma del curso" (lo que se
  aprende) es un ajuste SEPARADO y no cambia con esto.
- **Diferido (sigue en español):** resto de Ajustes, home/mapa, ligas, perfil, tienda, práctica, Matix,
  inmersión, textos legales sustantivos. Retome: extraer sus strings a nuevas claves l10n con el mismo patrón.

---

## COPY DE ONBOARDING + BARRIDO "NO CARGAN BIEN" — 2026-06-27 ✅ LIVE
> Feedback real: (1) la pregunta de idioma "está medio rara"; (2) "algunas no cargan bien".

### Tarea 1 — Copy del onboarding (solo i18n, sin tocar lógica)
La confusión raíz del paso de idioma: mezclaba "idioma de la app" con "aprenderás inglés". Reescrito
para separar claramente **interfaz** vs **lo que se aprende**. Antes → después:
- **Idioma** · título `¿En qué idioma quieres la app?` → `¿En qué idioma prefieres la app?` · subtítulo
  `Aprenderás inglés; este es el idioma de la interfaz.` → `El idioma de los menús y textos. No es lo
  que vas a aprender.` · nota `Idioma objetivo del curso: Inglés (Fase 1).` → `Vas a aprender inglés 🇬🇧.
  Esto solo cambia el idioma de la app.`
- **Motivo** · `…los escenarios y el coaching.` → `…los escenarios y los mensajes de tu coach.` (sin anglicismo)
- **Micro-arranque** · `¿Cómo arrancas en inglés?` → `¿Cuánto inglés sabes ya?` (más claro; `test de
  ubicación` → `test de nivel`)
- **Meta** · `A2 · Superviviente` → `A2 · Me defiendo` (español más natural)
Resto del flujo (bienvenida, compromiso, personalidad, resultado, plan) revisado: se lee natural, sin cambios.

### Tarea 2 — "Algunas no cargan bien" (diagnóstico + fix)
**Diagnóstico:** barrido HEAD de TODOS los recursos (`sweep_resources.py`) → **0 recursos 404**:
- AUDIO listening/speaking: **759/759 = 200** · IMÁGENES en ítems: **37/37** · vocab_images: **39/39**
  · AUDIO historias: **46/46** · música map_loop.wav: **200**. **No hay recursos faltantes.**
- Conclusión honesta: el síntoma era **lentitud percibida** — las imágenes (Twemoji) se descargaban por
  red **en el momento** en que aparecía el ítem → spinner breve en redes lentas. El audio ya tenía probe
  + failsafe (12 s) decentes; `ConceptImage` ya degradaba (colapsa en error).
**Fix a nivel de clase:**
- **Precarga de imágenes** en el `lesson_player` (igual que ya se precargaba el audio): `precacheImage`
  del ítem actual + el siguiente (post-frame, best-effort) → la imagen aparece **instantánea**, sin spinner.
- **Failsafe en `ConceptImage`:** si a los 10 s no cargó (red colgada), colapsa con gracia (el ejercicio
  sigue con texto) en vez de spinner eterno. La precarga normalmente hace que ni se vea el spinner.

### Verificación
- **0 recursos 404** en lo barrido (lista exacta para regenerar: ninguna). `analyze` 0 · `flutter test`
  82/82 · `build web` OK (`main.dart.js` +1.5 KB) · smoke P0 intacto · cliente real intacto.
- **Manual para Gian:** (1) registra una cuenta y lee el paso de idioma → debe quedar claro que elige el
  idioma de la APP y que igual aprende inglés. (2) En una lección con imagen (¿Qué es esto? / Describe la
  imagen) la imagen debe verse **al instante** (sin spinner) gracias a la precarga; si tu red está MUY
  lenta, tras 10 s el ejercicio sigue con las palabras. (3) Un listening sin audio (no debería haber)
  muestra "Audio no disponible", no un botón colgado.

### Qué difiero
No hay 404s que regenerar. Si en el futuro un recurso falta, `sweep_resources.py` lo lista exacto.

---

## PLACEMENT ROBUSTO + ESTIMACIÓN REAL + RESULTADO VISIBLE — 2026-06-27 ✅ LIVE
> Tres fallas CONECTADAS del feedback real: (A) el placement sobreestima; (B) la fecha es irreal
> ("C1 en 2 semanas"); (C) no hay resultado visible del test. Las tres resueltas. Cliente real
> verificado; `correct_answer` 42501; loop/seguridad/ligas intactos.

### A — Sobreestimación (causa raíz + fix)
**Causa:** `jz_placement_level` (mig 076) "superaba" un nivel con `acc≥0.5` (cerca del azar con 3
opciones) **Y `corr≥1`** → **un solo acierto suelto en un nivel alto lo promovía**, sin evidencia
mínima ni umbral de consistencia. (Reproducido con arrays: `[B1,B2,C1]` todos ✓ una vez → v1 daba
**C1**.)
**Criterio elegido — "techo con evidencia + consistencia"** (mig 089): un nivel cuenta como DOMINADO
solo si `asked≥2 AND correct≥2 AND acc≥2/3`; se ubica en el nivel **MÁS ALTO dominado** (la escalera
1-up/1-down garantiza haber pasado por los inferiores). Exigir **≥2 aciertos** mata la promoción por
azar/suelto. Fallback laxo (`acc≥0.5` con evidencia) solo si nada domina; si no, A1 (conservador,
nunca sobreestima). *Descarté:* media (subestima), techo ingenuo (sobreestima), IRT pleno (sin
parámetros calibrados con 3-opciones/~12 ítems es más ruidoso que esto). Determinista y testeable.
- `placement_next` junta **más evidencia** antes de cerrar: min 8 / max 14 ítems, `reversals≥4`.
- **Banco:** +5 ítems C1 (era 5R+3W; ahora **7R+6W**) — inversión, subjuntivo, léxico avanzado.
- **Evidencia:** `verify_estimator.py` 7/7 — incl. *"B1 + aciertos sueltos en B2/C1 → B1"* (v1 daba C1)
  y *"3 aciertos sueltos sin evidencia → A1"*. Personas A1–C1 → su nivel EXACTO (cliente real).

### B — Estimación de tiempo irreal (causa raíz + fix)
**Causa:** las horas-guía YA eran reales (C1≈750h). El "2 semanas a C1" venía de **A**: con el nivel
sobreestimado a ~C1 y meta ≤ C1, `needed = horas(meta) − horas(actual)` salía **negativo → `clamp(1)`
= 1 h → días**.
**Fix (estimation.dart):** (1) A fija el nivel real; (2) la **meta efectiva nunca queda ≤ el nivel
actual** — si el placement alcanza/supera la meta elegida, se apunta al **siguiente nivel** (siempre
hay objetivo hacia adelante, sin fecha fantasma); (3) **duración humana**: semanas → meses → **años**
(no "≈ 789 semanas"). **Antes/después:** C1-placed con meta B1 → antes "≈ días"; ahora bumped a C2,
`needed=350h`, p.ej. 30min×5 → ~años. A1→C1 a 10min×5 → "≈ X años" (honesto, no "2 semanas"). +6 tests.

### C — Resultado visible del test (nuevo)
**`PlacementResultView`** (paso nuevo del onboarding, tras el test): hero **"Tu nivel: X"** + **desglose
por las 4 habilidades** (lista con nivel + barra) + **a qué unidad entra** (`entryUnitFor`: A1=U1…C1=U25)
+ **fecha realista**. Redactado como **ubicación, no aprobar/reprobar** ("este no es un examen que se
aprueba… es tu punto de partida"). Cohesivo con el sistema de diseño. Además se corrigió `YourPlanView`:
ya no hardcodea "Unidad 1 (A1)" (usa la unidad de entrada real) y muestra la duración humana + la meta
efectiva.

### Evidencia (cliente real + tests)
- **Personas** (`verify_placement.py`): A1→A1, A2→A2, B1→B1, B2→B2 (incluso con hint malo), C1→C1; el
  puente coloca B2 en U19 / A1 en U1; `correct_answer` 42501.
- **Estimador determinista** (`verify_estimator.py`): 7/7 (acierto suelto NO salta).
- `analyze` 0 · `flutter test` **82/82** (incl. 6 del estimador de tiempo + la pantalla) · `build web` OK
  (`main.dart.js` +3.6 KB) · smoke P0 intacto.

### Qué difiero
Listening/speaking en el placement (requiere audio en onboarding → fricción de desbloqueo iOS) y banco
de placement es→pt. El estimador per-skill cubre reading/writing; L/S heredan el global.

---

## MÚSICA AMBIENTE DEL MAPA (sutil, opt-in, con ducking) — 2026-06-25 ✅ LIVE
> Loop musical sutil que da alma al "viaje hacia la fluidez" en el mapa (Aprender), sin estorbar
> ni pisar el audio funcional ni el del usuario. El listón: "se siente bien y nunca estorba".

### Fuente + LICENCIA (innegociable)
**Loop ORIGINAL generado por mí** (síntesis procedural, `tools/content/gen_music_loop.py`) → **obra
propia dedicada CC0** (dominio público). **Cero terceros, cero copyright.** Justificación de elegir
generarlo vs cazar un archivo: (1) **licencia 100% limpia** garantizada (no dependo de los términos de
un tercero); (2) **loop perfectamente SIN CLIC** — todas las parciales y los LFO tienen un número
**entero de ciclos** sobre la duración T=12s → la onda es periódica en T → el `loop=true` empalma
sample-exacto; (3) control total de la **sutileza** (pad suave, sin percusión, pico 0.16). WAV mono
16 kHz, **384 KB**, en Storage `audio/ambient/map_loop.wav` (CDN, carga diferida).

### Default elegido + por qué
**APAGADA (opt-in).** Muchos aprenden con su propia música/podcast; auto-reproducir encima = riesgo de
desinstalación. El opt-in respeta al usuario por completo; al activarla, el volumen es **sutil (0.16)**.

### Cómo resolví ducking y MediaSession
- **Ducking automático en el `AudioEngine`** (no duplica lógica): el loop vive en su **propio GainNode**;
  `playAsset` (SFX) y `playUrl` (TTS/listening) bajan ese gain con `setTargetAtTime` (~0.15s) y lo
  recuperan tras una ventana (SFX ~0.65s; TTS al `onended`). Nunca compite con el audio funcional.
- **MediaSession NO reactivada:** el loop reproduce en el **MISMO AudioContext** (Web Audio API,
  `BufferSource` con `loop=true`) que el resto — **sin elementos `<audio>`** → no crea MediaSession →
  **sin reproductor en la pantalla de bloqueo** (iOS). Se mantiene la defensa `_clearMediaSession`. No
  añadí metadata ni handlers de `navigator.mediaSession`. (Riesgo conocido del proyecto: respetado.)

### Reglas de producto implementadas
- **SOLO en el mapa:** `HomeShell` (coordinador) enciende/apaga por tab (`_index==0`), por lifecycle
  (`didChangeAppLifecycleState` → pausa al backgroundear) y `MusicService.setSuppressed(true)` en
  **lección/checkpoint/examen** (se montan sobre el mapa vía push) → **nunca durante el ejercicio**.
- **Pausa al salir/background** y respeto al autoplay: arranca solo tras gesto (`unlock`); si el
  AudioContext está suspendido (sin gesto), no fuerza nada.
- **Toggle fácil:** `SwitchListTile` en **Ajustes** ("Música del mapa") + **toggle rápido** (nota
  musical) en la top bar del mapa. Persistido (`MusicController`, `music_enabled`, default false).

### Perf (medido)
`main.dart.js` **3.604 MB** vs 3.598 MB previo = **+5.6 KB** (solo el código Dart de música). El WAV
(384 KB) va en **Storage/CDN, NO en el bundle**, y se descarga **diferido** solo al activar la música
en el mapa → **sin regresión de arranque** (default OFF → cero fetch al inicio). `analyze` 0 ·
`flutter test` 76/76 · build web OK · HEAD loop 200. **Cero cambios de servidor** → loop/seguridad/ligas
intactos por construcción.

### Verificación MANUAL para Gian (Android + iPhone, tras deploy READY)
1. **Default + activar:** cuenta/usuario normal → en el mapa NO suena nada (default OFF). Activa "Música
   del mapa" (Ajustes o el icono de nota en la top bar) → debe sonar un loop **suave** y agradable.
2. **Solo mapa:** entra a una lección/checkpoint/examen → la música **se calla**; al volver al mapa →
   vuelve. Cambia a otra pestaña (Practicar/Perfil) → se calla; vuelve a Aprender → vuelve.
3. **Ducking:** con la música on, provoca un sonido de la app (acierto/error en una lección no aplica
   porque ahí está callada; en el mapa, cualquier SFX) → la música **baja y se recupera**.
4. **No pisar tu audio:** pon tu propia música/Spotify, abre Jezici con la música del mapa ON → decide
   si te molesta; lo correcto es que el default OFF ya te respetó. Apágala fácil si no la quieres.
5. **iPhone (crítico):** con la música on, bloquea el teléfono → **NO** debe aparecer un reproductor
   "now playing" en la pantalla de bloqueo / centro de control. Backgroundea la app → la música para.
6. **Loop limpio:** escucha ~30-60s → el empalme del loop (cada 12s) no debe tener clic/salto audible.

### Qué difiero
- Variar/alargar el loop (varias pistas, transición entre regiones del mapa), presets de volumen, y
  fundido cruzado entre loops. El loop nativo (io/audioplayers) es best-effort; el foco es la PWA web.

---

## "DESCRIBE LA IMAGEN" determinista (es→en A1/A2) — 2026-06-25 ✅ LIVE
> A partir de una imagen, el usuario PRODUCE lenguaje de forma VERIFICABLE y autocalificable.
> Reusa las imágenes licenciadas (Twemoji CC-BY, `vocab_images`). Cliente real verificado.

### Mecánica elegida + por qué
**word_bank sobre la imagen** (skill=**writing**, producción guiada): el usuario ARMA con fichas la frase
que describe la imagen ("This is a house") → **secuencia verificable** (`jz_grade` word_bank), 100%
server-side. Es la mecánica que mejor cumple "PRODUCE lenguaje verificable" (vs el image→word **MC**
anterior, que era reconocimiento/reading). Considerados y descartados como primarios: MC "¿qué pasa?"
(comprensión, no producción) y cloze-con-imagen (1 palabra; el image→word MC ya cubre ese ángulo).
- **Reusa tipo existente** (word_bank) → **cero type nuevo, cero UI nueva**: `ConceptImage` ya renderiza
  cualquier ítem con `payload.image_url` en las 4 superficies (mig 087), y `TileArrangeExercise` arma las
  fichas. Solo se autoró contenido.
- **Frases ancladas al emoji** (objeto único): A1 "This is a/an/the X"; A2 "There is a X" / "I can see a X".
  El **distractor de ficha enseña el artículo** (a/an/the/incontable: "This is coffee" sin artículo).

### Techo (honesto, no violado)
NO es texto libre. La **descripción ABIERTA evaluada** (fluidez/coherencia/creatividad) **es Fase 2** —
sin IA no se autocalifica, igual que writing/speaking libres. Esto es producción **guiada** y determinista.

### Set sembrado (mig 088): 16 ítems word_bank/writing
A1 (10, units 3–6): house, dog, cat, apple, coffee, bread, car, school, sun, family. A2 (6, units 9–10):
bus, train, plane, hotel, money, shirt. Cableados a la lección de su unidad + tag `unidadN` (pool examen).
`correct_answer` (value+sequence) OCULTO (42501). Instrucción en español ("Describe la imagen: arma la
frase en inglés.") → NO revela la respuesta (la imagen + las fichas son el estímulo).

### Degradación + perf
- **Degradación fuerte:** cada frase tiene **un solo sustantivo** → las fichas hacen el ejercicio
  **resoluble aunque la imagen no cargue** (la imagen refuerza, no es imprescindible). `ConceptImage` ya
  colapsa con gracia si falla.
- **Perf:** **cero código Dart nuevo** → bundle sin cambios; imágenes reusadas (ya en CDN, lazy).

### Evidencia (cliente real — `verify_describe_image.py`, TODO PASA)
- **Validador determinista 0:** cada uno de los 16 ítems califica su **propia secuencia como correcta** y
  la **invertida como incorrecta** (server-side). **Grading 100% server-side**, `correct_answer` 42501.
- **Mueve la skill correcta:** tras `complete_lesson` con los describe-items A1, `get_skill_mastery` →
  **writing 0 → 0.157**. Imágenes HEAD **16/16 = 200**. `analyze` 0 · `flutter test` **76/76** ·
  `verify_chain es→en` PASS (los nuevos word_bank/imagen entran a exámenes) · smoke P0 intacto.

### Qué difiero
- **Descripción abierta evaluada por IA** (Fase 2). **match imagen↔palabra**; describe-image en **es→pt**
  y **B1+**; escenas con acciones (requeriría imágenes de escena, no emoji de objeto único).

---

## IMÁGENES REFERENCIALES EN LECCIONES (es→en A1/A2) — 2026-06-25 ✅ LIVE
> Doble codificación (imagen + palabra) para reforzar vocab CONCRETO → mejor retención + variedad.
> Solo donde la imagen AYUDA (vocab concreto, no gramática abstracta). Cliente real verificado.

### Fuente elegida + LICENCIA (PASO 0)
**Twemoji (CC-BY 4.0)**, alojado en Supabase Storage, carga diferida. **Justificación** (criterios:
licencia / consistencia / peso / curación):
- **Licencia limpia y permisiva:** CC-BY 4.0 — solo atribución, **sin** share-alike (más limpio que
  CC-BY-SA de OpenMoji para uso comercial). Cero scraping, cero copyright. Proveniencia registrada por
  imagen en `vocab_images` (source=`Twemoji 15.1 (jdecked)`, license=`CC-BY 4.0`, attribution completa).
- **Consistencia:** un único estilo plano coherente (cohesivo con la mascota emoji 🦜 y el sistema de diseño).
- **Peso/perf:** PNG 72px (~1KB c/u) en **Storage/CDN**, `Image.network` con `cacheWidth` → **cero impacto
  de bundle** (sin deps ni assets nuevos; `main.dart.js` 3.60MB, igual) y carga **on-demand** (sin lag de arranque).
- **Curación:** mapeo determinista concepto→codepoint→asset; descargo + re-alojo solo los que uso.
- *Descartado:* stock-photos (inconsistentes, pesadas, términos de hotlink/atribución por foto) e
  ilustración generada (consistencia difícil a escala A1/A2).
- Fetch: `cdn.jsdelivr.net/gh/jdecked/twemoji@latest/assets/72x72/<cp>.png` (fork mantenido del set original).

### Esquema (aditivo)
- **`vocab_images`** (mig 086): registro reutilizable + proveniencia/licencia (concept, category, codepoint,
  image_url, source, license, attribution). **RLS habilitado sin policy** → el cliente NO lee la tabla.
- **`content_items.payload.image_url`** (denormalizado, render): el cliente lo recibe vía
  `content_items_public` (payload sí pasa; `correct_answer` no). 39 conceptos alojados; 21 usados en ítems.

### Contenido (mig 087): 21 ítems "imagen→palabra"
`multiple_choice` con `payload.image_url`: la **imagen es el estímulo** y el enunciado es genérico
("¿Qué es esto?") → **no revela la respuesta por texto** (respeta la regla de no-revelar + `correct_answer`
42501). Opciones = palabra inglesa correcta + 2 distractores de la **misma categoría** (elección real).
Cableados a la lección de su unidad por tema + tag `unidadN` (food→U4, family→U3, time→U5, place→U6,
travel→U9, shop→U10). Pedagógicamente limpio: reconocimiento imagen→palabra = doble codificación.

### UI + perf + degradación
- `ConceptImage` (nuevo widget) insertado en **`buildExerciseWidget`** → aparece en las **4 superficies**
  (lección/checkpoint/examen/práctica) automáticamente (DRY). Crucial: el image-MC necesita la imagen en
  TODA superficie (sin ella sería irresoluble) → por eso va en el host común, no solo en la lección.
- **Carga diferida** (`Image.network`, `cacheWidth: 176`), tarjeta de **altura fija** (132px) → **sin jank**
  de scroll ni reflow durante la carga. **Cero deps nuevas** → bundle sin cambios; arranque sin regresión.
- **Degradación con gracia:** si la imagen no carga, `ConceptImage` **colapsa** (post-frame) y el ejercicio
  sigue con texto (no se rompe). Test `image_vocab_test.dart` cubre wiring + degradación.

### Evidencia (cliente real — `verify_image_vocab.py`, TODO PASA)
- **Imágenes cargan:** HEAD **21/21 = 200** (anon). `image_url` presente en `content_items_public.payload`.
- **`correct_answer` del image-MC 42501** (anon). **Grading server-side:** palabra correcta→true, otra→false.
- **`vocab_images` NO expuesta** al cliente (RLS). **Perf:** `main.dart.js` 3.60MB (sin deps/assets nuevos;
  imágenes network desde CDN → fuera del bundle). `analyze` 0 · `flutter test` **76/76** · smoke P0 intacto.

### Qué difiero
- **match imagen↔palabra** (columna izq. de imágenes): mayor cambio al widget de match → diferido.
- Imágenes en **es→pt** y niveles **B1+**; augmentar ítems existentes con imagen (riesgo de revelar → se evitó).

---

## EFICACIA + BALANCE L/S — es→pt (A1·A2·B1) + MULTICURSO — 2026-06-25 ✅ LIVE
> Lleva el segundo curso (es→pt, português do Brasil) a la par de es→en. Mismo criterio de balance.
> **Multicurso verificado:** el contenido pt va al curso pt (0 fuga al curso en). Grading server-side
> (`correct_answer` 42501).

### Balance aplicado (+4 listening +2 speaking por unidad) — resultado real
| Nivel pt | R | W | **L** | **S** | L/R | S/R |
|---|---|---|---|---|---|---|
| A1 | 98 | 94 | **60** | **48** | 61% | 49% |
| A2 | 96 | 95 | **60** | **48** | 62% | 50% |
| B1 | 81 | 114 | **58** | **46** | 72% | 57% |

**+108 ítems L/S** (3×24L+3×12S) en portugués de Brasil con audio **tl=pt** (108/108) + **34 huecos**
(mc/cloze). `payload.say`/`text` guardado → audio regenerable y text-matched. Tags propios `lsbalpt`/
`eficgappt` (aíslan del curso en) + `unidadN` (pool del examen pt, scope por course_id).

### Auditoría de eficacia pt — veredictos honestos
- **pt A1 — SÍ con reservas.** Temario y gramática A1 suficientes y bien secuenciados para llevar a un
  hispanohablante a A1 funcional en PB (saludos/ser, ter/posesivos, rutina/gostar/regulares, comida/querer/
  precios, direcciones/ficar, tiempo libre/poder). 12 huecos (contraste momento del día, concordancia
  posesivos no-familiares, ele/ela por género).
- **pt A2 — sí con reservas.** Sílabo A2 sólido (pretérito perfeito regular/irregular, ir+infinitivo,
  viaje/hotel, restaurante/comparativos, descripciones, salud/present perfect/conselhos). 11 huecos
  (irregulares tive/vimos en producción, futuro perifrástico, reproponer planes).
- **pt B1 — sí con reservas** (receptiva + producción guiada; no B1 productivo pleno autónomo). Espinazo
  B1 correcto (imperfeito vs perfeito, futuro/cortesía gostaria-poderia, **presente do subjuntivo**
  tomara que/espero que, relativos, se-passive/obligación, comparativos/discurso indirecto/voz pasiva).
  11 huecos (futuro perifrástico ir+inf, contraste antes/agora).
- Aprovechamiento del portugués: contracciones (no/na/do/da), próclise (me chamo), artículo ante nombre
  (o Pedro) — el validador adversarial corrigió tildes (são) y ambigüedades de sentido.

### Evidencia (cliente real — `verify_pt_ls.py <nivel>`, TODO PASA por nivel)
- **Multicurso:** `set_active_course(pt)` por JWT real → curso activo pt; tras resolver L/S pt vía
  `complete_lesson`, `get_skill_mastery` (jz_active_course=pt) sube dominio **listening/speaking EN EL
  CURSO PT**: A1 0→0.28/0.27 · A2 0→0.22/0.21 · B1 0→0.23/0.21. **Ruteo: 0 intentos fuera del curso pt.**
- **Audio pt:** HEAD **108/108 = 200** (tl=pt). **`correct_answer` pt 42501** (anon).
- **`verify_pt_chain` PASS** (cadena pt A1→A2→B1, exámenes con los nuevos L/S pt, certs JZC-*, per-skill;
  ítems del examen TODOS del curso pt — corregida una aserción obsoleta que asumía namespace 'd…').
- **`verify_chain es→en` PASS** (curso en intacto). `analyze` 0 · `flutter test` 74/74 · smoke P0 intacto.

### Punto de retome
es→pt **B2/C1 no existen** (el curso pt llega a B1). Si se siembran esos niveles, aplicar la misma
maquinaria (`gen_high_levels.py pt B2 ...`, `gen_audio_ls.py pt B2`, workflow `efic-ls-pt`).

---

## EFICACIA + BALANCE L/S — NIVELES ALTOS es→en (B1·B2·C1) — 2026-06-25 ✅ LIVE
> Extiende la auditoría de eficacia y el rebalanceo L/S a B1/B2/C1 (antes solo perfil estructural).
> Mismo criterio de balance que A1/A2 (NO 1:1). Verificado con **cliente real** por nivel. Grading
> server-side (`correct_answer` 42501).

### Balance aplicado (consistente con A1/A2)
**+4 listening +2 speaking por unidad** (6 unidades/nivel). Resultado real cableado:
| Nivel | R | W | L | S | L/R | S/R |
|---|---|---|---|---|---|---|
| B1 | 96 | 95 | **60** | **48** | 62% | 50% |
| B2 | 98 | 94 | **60** | **48** | 61% | 49% |
| C1 | 86 | 110 | **59** | **44** | 69% | 51% |

Objetivo (listening ~65% de R/W, speaking ~50%) alcanzado. **+108 ítems L/S** (3×24L+3×12S) con audio TTS
(`payload.say`/`text` guardado → regenerable y text-matched). Listening gradable (precisión), speaking
read-aloud (participación). Cableado a lecciones 1–4 + tag `unidadN` (pool del examen).

### Auditoría de eficacia — veredictos honestos (panel CEFR por unidad)
- **B1 — SÍ con reservas** (como A1/A2). Cobertura gramatical/funcional B1 SÓLIDA y bien secuenciada (present
  perfect/for-since/used to, going to/will, opinión+reported, relativos+past continuous, condicionales+modales,
  pasiva+2º condicional). Sin huecos estructurales; **11 huecos de alto impacto** rellenados (p.ej. present
  perfect negativo+yet en producción, preguntas indirectas de registro).
- **B2 — SÍ con reservas** (receptiva + producción guiada). Sílabo B2 íntegro (PPC/past perfect, reported speech
  a fondo, causativo+pasivas, condicionales mixtos/3º+wish, relativas defining/non-defining, deducción
  must/might have+phrasal). **12 huecos** rellenados (p.ej. perfect simple-resultado vs continuous-proceso,
  patrones de reporting verbs promise/warn + to-infinitive).
- **C1 — NO lleva a C1 PLENO (y no debe fingirlo); sí es andamiaje C1 sólido para lo RECEPTIVO.** Temario C1
  genuino (near-synonyms/connotación, hedging, cleft/inversión, modismos/registro, modalidad avanzada,
  lenguaje académico). **11 huecos** rellenados. **Techo determinista REAL:** reading/listening/vocab/gramática
  a C1 SÍ se autocalifican (opción única, cloze con accepted, inferencia); la **producción libre** (writing
  redacción/argumentación, speaking fluidez) **NO** se evalúa sin IA → **Fase 2**. Por eso **no hay cert C1 de
  4 skills** (por diseño, mig 064 tope B2). Honesto: el read-aloud entrena pronunciación, no certifica fluidez.

### Evidencia (cliente real — `verify_ls_balance.py <nivel>`, TODO PASA por nivel)
- **Mecánica:** placing al usuario en el nivel (create_plan) → tras resolver L/S nuevos, `get_skill_mastery`
  sube dominio **listening** (precisión) y **speaking** (participación): B1 0→0.28/0.27 · B2 0→0.28/0.27 ·
  C1 0→0.22/0.22.
- **Audio:** HEAD **204/204 = 200** (todos los `lsbal` A1–C1). **`correct_answer` 42501** (anon).
- **`verify_chain es→en` PASS** (cadena A1→B2 con los nuevos L/S/huecos B1/B2 en el pool del examen → exámenes
  pasan, certs emitidos, per-skill). `analyze` 0 · `flutter test` 74/74 · smoke P0 intacto. Validador
  determinista: 0 listening inválidos (answer∈options, transcription answer==say) en los 108.

### Punto de retome
Eficacia + L/S de **es→pt** (A1/A2/B1) — misma maquinaria (`gen_high_levels.py` + `gen_audio_ls.py`;
`gen_audio_missing.py` ya tiene grupos pt-*). No iniciado (alcance: es→en niveles altos primero).

---

## EQUILIBRAR LISTENING/SPEAKING (es→en A1/A2) — 2026-06-25 ✅ LIVE (server/DB + audio)
> La auditoría EFICACIA halló sesgo **~3:1** (R/W vs L/S). Esta tanda sube L/S de A1/A2 para que
> las 4 habilidades nivelen proporcionalmente. Server/DB + audio aplicados y verificados con
> **cliente real**. Grading server-side (`correct_answer` 42501).

### Balance objetivo elegido (con criterio, NO 1:1) y por qué
Conteo real previo (cableado a lecciones): R/W **~95–105/nivel** por skill vs **L ~34–36 · S ~34–36**.
- **Listening → ~65% de R/W** (+5/unidad: 5–6 → 10–11; ~64/nivel). Es la receptiva **genuinamente
  calificada** (jz_grade como MC) y la más subservida → prioridad máxima.
- **Speaking → ~50% de R/W** (+3/unidad: 5–6 → 8–9; ~52/nivel). Es un **proxy** read-aloud
  (participación, NO evalúa fluidez — eso es Fase 2). Subida moderada: suficiente para que la skill
  nivele proporcional (su dominio sube por cobertura/participación) sin sobre-invertir en una
  dimensión no evaluada. **No 1:1** porque R/W están inflados por autoría/evaluación baratas y reading
  sostiene todas las skills.

### Lo hecho (mig 078 A1 · mig 079 A2)
- **96 ítems nuevos** (60 listening + 36 speaking; 30L+18S por nivel), autorados por **panel de
  profesores IA + validación adversarial por unidad** (descartó/corrigió dudosos — p.ej. un homófono
  *tea/tee* en transcripción). Cableados a las **4 lecciones** de cada unidad + tag `unidadN` (entran
  al **pool del examen** → corrige el sesgo R/W de los exámenes que notó la auditoría).
- **Listening:** `type='listening'` (gradable), `payload.say` = audio EN, 3 opciones, `correct_answer.
  value`. Estilos: "elige lo que oíste" (transcripción, distractores minimal-pair) y "elige la
  respuesta" (comprensión funcional). **`say` guardado** → audio **regenerable y text-matched** (los
  A1 viejos NO lo tenían).
- **Speaking:** `type='speaking_read_aloud'` (stub/participación), `payload.text`, `correct_answer.
  expected`. Frases naturales de la unidad, relevancia LATAM.
- **Audio:** **96/96** TTS (Google translate_tts `tl=en`) generados y subidos a Storage
  (`audio/items/<id>.mp3`, `gen_audio_ls.py`). Pipeline idéntico a los 216 previos.

### Honestidad sobre el techo del speaking (proxy)
El read-aloud entrena **pronunciación y producción guiada** y da señal de dominio por participación,
pero **NO certifica producción oral libre** (fluidez/coherencia). Eso requiere evaluación por IA/humano
(**Fase 2**). Por eso speaking se sube a ~50%, no a paridad: invertir más en una skill no evaluada da
rendimiento decreciente.

### Evidencia (cliente real — `verify_ls_balance.py` TODO PASA)
- **Audio:** HEAD **96/96 = 200**.
- **Mecánica (lo crítico):** tras resolver listening+speaking nuevos vía `complete_lesson`,
  `get_skill_mastery` → **dominio listening 0 → 0.24** (por precisión) y **speaking 0 → 0.23** (por
  participación). Los ítems L/S nuevos **mueven de verdad** su habilidad.
- **`correct_answer` de listening nuevo OCULTO** (anon → 42501).
- **`verify_chain es→en` PASS** (cadena A1→B2, certs, per-skill; los nuevos L/S entran a exámenes y
  `raised_skills` incluye listening/speaking). `analyze` 0 · `flutter test` 74/74 · smoke P0 intacto.

### Punto de retome (siguiente tanda)
- **B1/B2/C1 es→en** y **es→pt A1/A2/B1**: mismo rebalanceo L/S (autorar + audio). Misma mecánica
  (`gen_ls_bank.py` + `gen_audio_ls.py`, tag `lsbal`; `gen_audio_missing.py` ya tiene grupos
  en-b1/b2/c1 y pt-*). No iniciado en esta sesión por alcance (A1/A2 primero, como pidió la misión).

---

## TEST DE UBICACIÓN PRECISO + ARRANQUE EN EL NIVEL — 2026-06-25 ✅ server LIVE + en deploy (cliente)
> Reporte: "respondí bien preguntas de nivel alto y la app me arrancó en la Unidad 1 (A1)".
> Eran DOS fallas independientes. Ambas resueltas y verificadas con **cliente real autenticado**
> (`verify_placement.py`: TODO PASA). Grading 100% server-side (`correct_answer` 42501).

### ANÁLISIS — causa raíz (reproducida leyendo el código vivo)
**Falla A — el placement no clasificaba con precisión.** Tres causas combinadas:
- **A1 (banco muerto/insuficiente).** El test era **100% cliente**: `placement_test.dart` usaba **20
  ítems HARDCODED en Dart** (4/nivel) y **calificaba en el cliente**. El banco de la BD (16 ítems,
  solo A1–B2, solo reading/writing, desbalanceado) **ni se consultaba**. Con 4 ítems/nivel y ±1 por
  respuesta, no había de dónde converger.
- **A2 (estimador sesgado a la baja) — la causa directa del síntoma.** El nivel final se calculaba
  como la **MEDIA de los niveles de las preguntas presentadas** (`placement_test.dart:123`). Un B2 que
  acierta arriba arrastra el promedio hacia el centro → sale B1/A2. **Subestima por diseño.**
- **A3 (sin las 4 habilidades).** Solo reading/writing; las 4 skills se fijaban al mismo nivel. Real,
  pero secundario al síntoma.

**Falla B — el árbol no arrancaba en el nivel obtenido (la causa de "terminé en A1").**
`create_plan` (mig 039) **guardaba** `current_level`/`skill_levels` pero elegía el nodo inicial como
`select id from lessons … order by order_index limit 1` → **SIEMPRE la Unidad 1, nodo 1**, ignorando
`p_current_level`. El mapa muestra el primer nodo `available` → A1. Aunque el placement diera B2, el
puente nivel→arranque **no existía**.

### ENFOQUE ELEGIDO (y alternativas descartadas)
**Server-driven, data-driven, adaptativo + puente en `create_plan`.** Razón: es la única forma de que
el placement sea (a) **verificable con cliente real** (la misión exige "B2→~B2" con JWT real), (b)
**server-graded** (principio de la plataforma; `correct_answer` oculto) y (c) data-driven (banco en
la BD, autorable). Descartado:
- *Solo arreglar el estimador en el cliente (media→techo) + ampliar banco Dart.* Deja el grading en el
  bundle y **no verificable** con cliente real; mantiene banco duplicado/muerto.
- *IRT completo (2PL/3PL, EAP/MLE).* Sobredimensionado para 5 bandas y un banco modesto; exige
  parámetros calibrados que no tenemos. Mi **escalera + techo** es un "paso hacia IRT" determinista,
  explicable y testeable (usa `cefr_level`/`difficulty` + estimación de habilidad con convergencia).
- *Mapa con ramas por skill.* El mapa es un camino lineal; el nivel de entrada lo fija el nivel global,
  y per-skill alimenta dominio/examen. No aporta al arranque.

### LO CONSTRUIDO
- **mig 075 — banco de placement** (48 ítems es→en A1→C1, 5+5/nivel; C1 5R+3W). Autorados por panel de
  examinadores IA + **validación adversarial por nivel** (descartó los dudosos). `correct_answer` oculto.
- **mig 076 — `placement_next(course, start_level, history)`**: RPC stateless. Califica TODO el historial
  con `jz_grade` (servidor), selección **escalera 1-up/1-down** (acierto→+1, error→−1: concentra las
  preguntas en el nivel real), **estimador TECHO** (nivel más alto superado consistentemente, contiguo
  desde abajo; corrige el sesgo de la media), per-skill reading/writing (listening/speaking=global).
  Devuelve el siguiente ítem **sin respuesta** o `{done, level, skill_levels}`.
- **mig 077 — puente en `create_plan`**: `current_level`→primera unidad de ese nivel; lo inferior queda
  `completed` (accesible, sin XP falso); entrada `available`; punteros al nodo de entrada. **Seguro**: el
  avance del mapa es por cadena (`complete_lesson`); el examen/cert siguen gateados por **dominio**
  (`jz_skill_mastery≥0.80` sobre intentos reales) → marcar lo inferior no regala nivel ni certificado.
  Idempotente y **backward-compatible** (A1 ⇒ entrada=U1 ⇒ idéntico al actual).
- **Cliente** (`placement_test.dart`): ahora **relay** de `placement_next` (sin banco hardcoded ni
  estimador de media); el hint del onboarding va como `p_start_level`. `repo.placementNext`.

### EVIDENCIA (cliente real autenticado, `verify_placement.py` — TODO PASA)
- **Precisión:** persona A1→**A1** (6 preg.), A2→**A2**, B1→**B1**, **B2→B2** (incluso con hint
  equivocado A2), C1→**C1** (12 preg.). El estimador techo **clava el nivel** (antes la media lo bajaba).
- **`placement_next` no filtra `correct_answer`** (el ítem servido no trae la respuesta).
- **Puente:** `create_plan(B2)` → unidad actual **nivel B2**, 1er nodo disponible **B2** (U19), contenido
  inferior marcado completado. `create_plan(A1)` → U1, nada por debajo (sin regresión).
- **`correct_answer` de placement oculto** (anon → 42501/sin columna).
- Suites: `analyze` 0 · `flutter test` 74/74 (incl. 2 nuevos del relay) · `build web` OK · smoke P0 intacto.

### Verificación MANUAL para Gian (Android — tras deploy READY)
1. **Crea una cuenta nueva** y en "¿Cómo arrancas?" elige **"Tengo buen nivel"**. En el test, **acierta**
   las preguntas (gramática alta). Al terminar, tu plan debe decir un nivel **alto (B1/B2/C1)**, no A1.
2. **Entra al mapa:** debes aparecer en una unidad **de tu nivel** (p.ej. B2 = zona avanzada), con el
   contenido anterior marcado como **hecho** (accesible si quieres repasar), **sin** "buenos días" como
   nodo activo.
3. **Contraprueba:** otra cuenta nueva, "Desde cero" y **falla** a propósito → debe ubicarte en **A1** y
   arrancar en la **Unidad 1**.
4. (Opcional) Un nivel intermedio: acierta lo básico y falla lo difícil → debe ubicarte en medio
   (A2/B1) y arrancar ahí.

---

## MEJORAS AL LOOP DE LECCIÓN — 2026-06-24 ✅ LIVE (server) + en deploy (cliente)
> Tres mejoras pedagógicas al loop. Server-side aplicado y verificado con **cliente real
> autenticado** (`verify_loop_improvements.py`, TODO PASA). Cliente (Flutter) en el push;
> efecto visible tras deploy READY. Grading sigue 100% server-side (`correct_answer` 42501).

**TASK 1 — Repaso de errores + conexión SRS** (mig 074 `srs_prioritize_failed` + `ErrorReviewScreen`)
- Al terminar, si hubo ≥1 fallo → pantalla **"Repasa lo que fallaste"** ANTES de la recompensa:
  cada ejercicio errado + **respuesta correcta** + un porqué corto (voz del coach). Si no falló
  nada, se salta. Corrección SIEMPRE visible; **"Practicar los fallados"** es OPCIONAL (re-juega
  solo esos ítems en `reviewMode`, sin recompensa ni doble conteo).
- Los ítems fallados se persisten en el cliente (`_failed`) y al completar se llama
  `srs_prioritize_failed(item_ids)`: mapea cada ítem → vocabulario del curso (whole-word sobre
  `correct_answer.value`) y hace upsert en `user_vocab_srs` con `strength=0, interval=1, due_at=now`
  → **el error se repasa en días**. Aditivo: NO toca `complete_lesson` (loop intacto).
- Verificado real: `srs_prioritize_failed([item])` → 200; fila en `user_vocab_srs` del usuario con
  `due_at<=now`.

**TASK 2 — Tolerancia "casi correcto" (typo-tolerance)** (mig 073)
- En cloze/translation, si la respuesta está MUY cerca → `correct=true` **+ `near=true`**: no resta
  vida y muestra **"La forma correcta es: …"** (feedback dorado "¡Casi! 🦜").
- Reglas (en `jz_near_match`, server): **A)** artículo a/an/the faltante/sobrante (`jz_strip_articles`);
  **B)** distancia Levenshtein **1**, pero la sustitución de 1 char SOLO en frases multi-palabra
  (inserción/borrado siempre). **Guard de homógrafos:** live/life, house/horse, cat/cut, this/these
  NUNCA pasan (verificado). `jz_grade = jz_grade_exact OR jz_near_match` → loop, summary y examen
  coherentes; `grade_item` expone `near` para el feedback. Espejo cliente `nearMatch` en `grader.dart`.
- Verificado real: typo menor multi-palabra → `correct=true, near=true`; frase distinta →
  `correct=false, near=false`; exacto → `near=false`. Tests `grader_typo_tolerance_test.dart` (17).

**TASK 3 — Botón que pronuncia la palabra** (`core/speech/word_tts.dart`, Web Speech API)
- Tocar una ficha en word_bank/reorder pronuncia esa palabra (en-US, ritmo 0.9, interrumpible).
  Cero archivos, cero peso. Disparado por el TAP (gesto real) → sin el desbloqueo de audio de iOS.
  Conditional import (web real / no-op fuera de web) + try/catch → degradación con gracia.

### Verificación MANUAL para Gian (Android — PWA instalada, tras deploy READY)
1. **Casi correcto:** lección con traducción; escribe la respuesta con UN typo (p.ej. "Helllo" por
   "Hello") o sin el artículo ("I have sister") → debe contar **CORRECTO** con banda dorada
   "¡Casi! 🦜" y "La forma correcta es: …", **sin perder vida**. Luego prueba un homógrafo real
   (escribe "life" donde va "live") → debe contar **INCORRECTO** y restar vida.
2. **Repaso de errores:** falla ≥1 ejercicio a propósito y termina la lección → antes de la
   recompensa aparece **"Repasa lo que fallaste"** con la corrección de cada uno. Pulsa
   **CONTINUAR** → recompensa normal. (Opcional: "Practicar los fallados" repite solo esos.)
3. **SRS:** tras eso, entra a **Práctica → Repaso (SRS)**: los ítems fallados deben aparecer pronto
   (su vocabulario quedó con prioridad inmediata).
4. **TTS de tile:** en un ejercicio de **ordenar/banco de palabras**, toca cada ficha → debe
   pronunciar la palabra en inglés. Si el dispositivo no soporta síntesis, simplemente no suena
   (no rompe el armado). Verifica también en **iPhone/Safari** que el primer toque ya pronuncia.

---

> **Fecha:** 2026-06-22 · **Alcance:** diagnóstico, CERO cambios de código.
> **Método:** lectura de repo + 56 migraciones, ejecución real de toolchain,
> y verificación contra la BD de producción con cliente REST (anon + JWT
> autenticado real, creado y borrado con `delete_account`). **No** se usó
> `service_role` para los chequeos de seguridad.
> **Foco:** (1) audio · (2) progresión · (3) ligas · (4) seguridad.

---

## SMOKE POST-DEPLOY — producción `b34b568` LIVE · 2026-06-23 ✅ TODO VERDE
> Verificación de solo lectura del build vivo (cliente real anon + JWT; usuario de
> prueba creado y borrado con `delete_account`; sin `service_role` en los chequeos
> de cliente). Tras desbloquear el deploy aterrizó de golpe: audio P0/P1, seguridad
> mig 058, PWA v4, tips mig 057, ligas/leaderboards mig 059.

| Superficie | Estado | Evidencia (cliente real) |
|---|---|---|
| **Loop core** | 🟢 | `content_items.correct_answer` base → **403/42501**; vista pública → col inexistente (400/42703); lección real = 8 ítems sin `correct_answer`; `grade_item` → 200 `{correct,graded,expected}` |
| **Seguridad (mig 058)** | 🟢 | `league_members`/`leagues` → **403**; `log_event` válido **204**, bogus descartado; `export_my_data` → **200 (24 secc.)**; `get_metrics` no-admin → **admin only**, admin (JWT real) → **200** (`total_users=10`) |
| **Ligas / Leaderboards (mig 059)** | 🟢 | `get_league` sin `user_id`; **32 combinaciones** Métrica×Ventana×Alcance → **0 errores, 0 UUID_LEAK**; paginación ranks `[1,2]`/`[3,4]`; `jz_close_weeks()` idempotente (2× → 0, snapshots 6=6) |
| **Audio** | 🟢 | HEAD a las **312 URLs → 312/312 = 200** (1 timeout transitorio confirmado 200 al reintentar); bundle vivo contiene "Audio no disponible" (degradación) |
| **PWA cache-busting (P0.5)** | 🟢 | `sw.js` = `jezici-v4` + `no-store` en el shell; `index.html` con `updatefound`/"Recargar"; `Last-Modified` de hoy, `Age` bajo. Sello **`JZ_BUILD` sigue en `dev`** (regresión conocida del fix de deploy; NO se toca aquí) |
| **Suites** | 🟢 | `flutter analyze` **0** · `flutter test` **42/42** · `verify_chain` es→en (certs A1→B2) · `verify_pt_chain` (A1→A2) · `e2e_audit` **todas PASS** |

> Nota: `iOS unlock` por gesto (`_AudioUnlockGate`) es lógica (sin string greppable);
> está en el commit desplegado `b34b568` y el bundle vivo trae las cadenas de
> degradación/export/leaderboards. La conducta real en dispositivo va en el checklist
> manual de abajo (§Checklist).

---

## LEGAL IN-APP — publicado 2026-06-23 (mig 062) · ⚠️ BORRADOR
Privacidad + Términos (ya redactados en `legal_screen.dart`) ahora **visibles** (Ajustes +
registro, con banner de beta + versión `2026-06-draft`) y **aceptados**: checkbox requerido
en el alta → `accept_legal` persiste `legal_consents` (versión + timestamp; RLS self, escritura
solo por RPC; cascada en delete_account). `my_legal_version` permite re-consentir al cambiar el
texto. Verificado con JWT real. **Es BORRADOR** (revisión de abogado pendiente; sin acreditación
oficial). Diferido: gate de re-consentimiento para usuarios existentes (infra lista).

## ANALÍTICA DE LA BETA — completa 2026-06-23 (mig 061)
KPIs medibles sin SQL desde la pantalla interna (Ajustes → Ver métricas, admin-only):
retención D1/D7/D30, **stickiness DAU/MAU (CURR)**, embudo de onboarding, lecciones/día,
% aprueba checkpoint/examen, % certifica, y **embudo dentro de la lección** (iniciadas/
completadas/abandonadas/sin-vidas + tasa de finalización). Tapado el único hueco (abandono
intra-lección) con 3 eventos nuevos (`lesson_start`/`lesson_quit`/`no_hearts`, añadidos al
allowlist). Sin PII. Verificado con JWT real (eventos entran/bogus descartado, gate admin,
league_members 403). Diferido: cohorte semanal visual, abandono por ítem, analítica de práctica.

## MONITOREO (Sentry) — cableado 2026-06-23, pendiente DSN
Sentry client-side integrado (`runWithSentry` envuelve `runApp`: Flutter + nativo + zona;
web errores JS). Sin DSN = NO-OP (app intacta, deploy intacto — buildCommand NO tocado para
evitar el gotcha de `$VAR`). Para activarlo, Gian pega el DSN como `--dart-define` **literal**
en `vercel.json` (ver CLAUDE.md §Monitoreo). Diferido: source maps + Sentry server-side.

---

## CONTENIDO C1 (es→en) — sembrado 2026-06-23 (mig 063 + 064) · ✅ LIVE, sin cert por diseño
**Qué se construyó.** 6 unidades C1 (25–30) con foco real de C1 (no "más gramática"):
matiz/colocación/hedging (U25), argumentación/concesión (U26), inversión enfática + cleft +
inferencia (U27), idiom/phrasal/registro/eufemismo (U28), condicionales con inversión + modalidad
avanzada (U29), lenguaje académico: nominalización/pasiva formal/reporting verbs (U30). **252 ítems**
(192 de lección + **60 de checkpoint FRESCO**), 4 habilidades, dificultad 0.62–0.92. Autorado por
profesor-IA (1 agente/unidad) → validado contra el grader (gen_c1.mjs, 0 problemas) → validador
determinista (`content_qa.py c1`) **0 hallazgos**. Audio TTS **67/67** en Storage (HEAD 200).

**Techo determinista (la tensión, resuelta honestamente).** reading/listening/vocab/gramática a C1
se autocalifican bien; **writing/speaking a C1 NO** sin IA (solo proxies: traducción tolerante +
leer en voz alta). Decisión: C1 se siembra como **contenido aprendible** pero **sin examen ni
certificado C1** hasta Fase 2. Cierre en DB (defensa en profundidad, todo live):
- Ítems de lección tag `c1_unidadN` / checkpoint `cp_unidadN` → **fuera del pool** del examen de nivel.
- **mig 064**: `jz_resolve_exam_level` topa en B2 (nunca apunta a C1/C2); `jz_level_status` →
  `unlocked=false` para C1/C2 → `start_level_exam` y `submit_level_exam` rechazan C1 con
  `level exam locked`. Verificado con cliente real (`verify_c1_cap.py`): un usuario **plenamente
  elegible** (6/6 checkpoints C1, 4 skills al tope) NO puede acuñar JZC-C1; ni flujo normal ni
  atajo RPC crafteado con respuestas correctas. La progresión intra-C1 la gatean los checkpoints (≥80%).
- ⚠️ **Para Gian (decisión Fase 2):** C1 hoy es **"en progreso sin certificado"**. Cuando exista
  evaluación real de writing/speaking (IA/humano), habilitar examen+cert C1 (retaguear a `unidad%`,
  ampliar el rango de las 2 RPC a C1, crear exam id `…0000c1`). Detalle: `docs/LEVELS_C1_DESIGN.md`.

**Verificación.** `content_qa.py c1` = 0 · `verify_chain.py` A1→B2 PASS (certs topan en B2) ·
`verify_c1_cap.py` PASS · `grade_item` califica C1 server-side · B2 (u.19–24)→C1 (u.25–30) ·
analyze 0 · test 43/43 · build web OK.

**Placement C1 — LIVE.** 4 ítems C1 (inversión/cleft/concesión) añadidos a `placement_test.dart`
con clamp 0..4 → ubica usuarios avanzados en C1. (Nota 2026-06-24: los deploys de Vercel vienen
READY desde el fix 68266d3 — el commit 151062f que incluye esta placement desplegó READY, así que
ya NO es "deploy-pending".) El contenido, tope de examen y audio están LIVE vía migraciones/Storage.

---

## SELLO DE BUILD JZ_BUILD — 2026-06-24 · ⚠️ lado-app LISTO, inyección BLOQUEADA (sigue `dev`)
**Objetivo:** mostrar el SHA real del build en el pie de Ajustes (diagnóstico de la beta).

**Hallazgo duro (re-confirmado empíricamente):** **CUALQUIER edición del `buildCommand` de
vercel.json rompe el deploy** — no solo `$VAR`/`$()` del SHA. Probé añadir un paso post-build
deploy-safe: `&& bash ../scripts/stamp_build.sh` (sin `$` del SHA en la cadena; el SHA se lee dentro
del script desde `$VERCEL_GIT_COMMIT_SHA`). Resultado: deploy **ERROR instantáneo, 0 logs de build**
(commit 0389b1a, dpl_318NmLN…). Producción NO se cayó (el alias se quedó en el deploy READY previo
bcb844a). **Revertí vercel.json a su string byte-idéntico vivo** → deploy se recupera.
→ La única superficie de inyección build-time es el buildCommand, y es intocable. Sin inyección
build-time, el runtime (hosting estático) no puede conocer el SHA. Conclusión: **no hay vía
deploy-safe vía vercel.json**; el sello queda **diferido**.

**Lo construido y CI-verde (se mantiene, inofensivo — cae a `dev`, sin regresión; commit 0389b1a):**
- `core/app_info.dart` `appBuild()`: lee `window.JZ_BUILD` en runtime (`dart:js_interop`,
  `app_info_stamp_web.dart`; stub `_io` para móvil/VM/tests). Pie de Ajustes y Sentry `release` lo usan.
- `scripts/stamp_build.sh`: inyecta `<script>window.JZ_BUILD="<sha7>"</script>` en
  `build/web/index.html` (idempotente; sin `$VERCEL_GIT_COMMIT_SHA` no inyecta → `dev`). Probado local:
  inyección + idempotencia + fallback OK. index.html va no-store (sw v4) → reflejaría el bundle real.

**Activación (requiere a Gian, dashboard):** añadir `… && bash ../scripts/stamp_build.sh` al **Build
Command del DASHBOARD de Vercel** (Project Settings → Build & Development), NO en vercel.json. Es la
única vía no probada que podría aceptarse (el rechazo parece específico de editar el buildCommand de
vercel.json). Si el dashboard también lo rechaza → limitación de plataforma; el sello queda en `dev`.

**Estado:** analyze 0 · test 52/52 · CI SUCCESS (0389b1a) · prod READY (alias en build previo);
buildCommand restaurado. El aviso de "nueva versión" del sw intacto.

---

## 2 BUGS DE DISPOSITIVO (Android PWA) — 2026-06-24 · ✅ arreglados (verificación manual pendiente del dueño)

### BUG 1 (ALTA) — pantalla NEGRA al volver de segundo plano
**Causa raíz (diagnóstico, no adivinación):** **no existía NINGÚN** manejo de visibility/resume/
lifecycle en toda la app (`grep` de visibilitychange/AppLifecycleState/webglcontextlost = 0). Renderer
= **CanvasKit** (default Flutter 3.44; el renderer HTML ya NO existe en 3.44, así que cambiarlo no es
opción). Al backgroundear en Android, el proceso GPU recicla/pausa el contexto WebGL; al volver, Flutter
no repinta solo → negro.
**Fix (deploy-safe, solo `app/web/index.html`, NO toca el buildCommand):** al recuperar visibilidad
(`visibilitychange`→visible, y `pageshow` persisted de bfcache) se fuerza a Flutter a re-medir y repintar
con un `resize` sintético (doble rAF); y se manejan `webglcontextlost` (preventDefault → permite
restaurar) / `webglcontextrestored` (repaint). Inofensivo donde no aplica (un frame extra, sin parpadeo).
Es la mitigación estándar para este patrón; **confirmación final = prueba del dueño en el dispositivo real**
(no reproducible aquí). Si persistiera tras minutos en background, el siguiente paso sería evaluar skwasm
(--wasm) midiendo arranque/bundle.

### BUG 2 — el checkpoint "se corta levemente"
**Causa raíz:** varias pantallas de examen no respetaban el **safe-area inferior** → la barra de
navegación de Android tapaba el último tramo (botón/línea). Confirmado: `checkpoint_intro` (hoja de info
inferior sin SafeArea), `checkpoint_result` (`body: Column` sin SafeArea, botón al final del scroll),
`certificate` (ListView sin inset). `level_exam_intro/result` ya usan `body: SafeArea` → OK.
**Fix:** añadido `MediaQuery.paddingOf(context).bottom` al padding inferior de esas 3 pantallas (0 en
pantallas sin inset → no rompe desktop/pantallas grandes). El checkpoint_player ya scrolleaba bien.

### Verificación MANUAL para Gian (Android, PWA instalada)
1. **Negro al volver:** abre Jezici → cambia a otra app (o bloquea/desbloquea) → vuelve: **no** debe
   quedar negro (repinta). Repite **tras varios minutos** en segundo plano (para que Android recicle el
   GPU) → debe repintar igual. Si quedara negro, repórtalo (evaluaríamos skwasm).
2. **Checkpoint completo:** abre un checkpoint ("El portal de la unidad") → el botón **EMPEZAR
   CHECKPOINT** y el texto inferior se ven completos, sin que la barra del sistema los tape. Tras
   terminar, en el resultado el botón **CONTINUAR EL VIAJE/REINTENTAR** se alcanza sin quedar tapado.
   Repite en examen de nivel y certificado.

**Estado:** analyze 0 · test 55/55 · loop/seguridad mig 058/ligas intactos (solo UI + index.html, sin
DB/RPC). gh run list SUCCESS · deploy READY (sin tocar vercel.json).

---

## AUDITORÍA DE EFICACIA DEL CONTENIDO — 2026-06-24 (mig 071/072) · es→en A1/A2 + regresión pt
**Pregunta:** ¿el contenido de cada nivel *construye la competencia CEFR* de ese nivel? (no solo "sin
errores"). Auditoría por nivel: cobertura, progresión, retención, balance de 4 habilidades, evaluación.
Detalle en **EFICACIA_CONTENIDO.md**.

**Hallazgo sistémico (todos los niveles, ambos cursos):** balance de habilidades **~3:1** — R~74/W~74 vs
**L24/S24** por nivel (4/unidad). Listening/Speaking **subservidos**. Además **techo determinista de
producción**: speaking es proxy read-aloud (no califica producción oral) y writing se evalúa con
translation/cloze tolerantes (no redacción libre) → la competencia productiva real de cada nivel depende
de **Fase 2** (IA/humano). Honesto: el contenido entrena reconocimiento + producción guiada, no certifica
producción libre.

**es→en A1 y A2 — veredicto "SÍ con reservas".** Cubren el núcleo CEFR con progresión sólida, pero faltaban
puntos. **Arreglado (mig 071, 29 ítems nuevos SIN audio, cableados a la lección de su tema → loop + examen):**
A1 presente continuo básico (am/is/are+-ing), 3ª persona -s como sistema (he works), plurales y a/an,
these/those, números altos; A2 conectores because/so/but, present perfect 'yet', a lot of / much-many,
adverbios -ly. 29/29 válidos contra el grader; grade_item acepta lo correcto y rechaza lo erróneo.

**Regresión P0 destapada y ARREGLADA (mig 072):** los exámenes de nivel de **pt** daban 'level exam locked'
— mig 064 (misión C1) había restaurado start/submit_level_exam a la versión **mono-curso** (`courses where
is_active`), perdiendo el multicurso de mig 047. mig 072 restaura `jz_active_course()` en ambas (desde la
def viva, solo esa línea), preservando per-skill + el tope C1 (jz_level_status/jz_resolve intactas).
**verify_pt_chain vuelve a PASS** (y verify_chain es→en sigue PASS).

**Diferido (con punto de retome):** equilibrar L/S en todos los niveles (requiere autorar L/S + **audio
TTS** → tanda dedicada); auditoría de eficacia es→en B1/B2/C1 y es→pt A1/A2/B1; más reciclaje de léxico;
checkpoints menos sesgados a reconocimiento.

**Verificación:** validador determinista **0** (es→en) · verify_chain es→en + verify_pt_chain **PASS** ·
analyze 0 · test 55/55 (+3 del grader) · correct_answer 42501 · loop/seguridad/ligas intactos.

---

## AUDITORÍA PEDAGÓGICA DEL CONTENIDO — 2026-06-24 (mig 070) · ✅ es→en A1/A2
**Alcance:** 12 profesores-IA en paralelo (1/unidad) auditaron los **384 ítems es→en A1/A2** (lección
+ checkpoint) por correctitud, tolerancia, distractores, revelación, naturalidad, CEFR, claridad,
redundancia y skill. Detalle completo en **CONTENT_QA.md**.

**Resultado: 0 P0** (ninguna respuesta marcada es incorrecta — el banco A1/A2 está sano). 23 P1 + 5 P2.
**Clase sistémica:** `tolerancia_insuficiente` (22) — translation/cloze sin alguna variante natural que
un aprendiz LATAM produce y es correcta (sinónimos film/baggage/dad, have got, please, o'clock, get/grab,
artículo/número, "It's Monday", dígito "2", "never", "must"…).

**Arreglado (mig 070, additivo — no acepta lo erróneo):** 20 ítems con variantes añadidas a `accepted`
+ 2 pulidos (cloze `(cook)` ahora pide la forma -ing; match de partes del día evening/tarde-noche →
morning/mañana, sin solape). El grader ya normaliza apóstrofes/contracciones/puntuación, así que las
variantes nuevas son las de léxico/estructura.

**Rechazado (con criterio):** no se quita train/bus de "I need a ___ to Madrid" (son inglés natural →
quitarlos reduciría tolerancia válida); no se recategoriza un cloze writing→reading (cloze = producción
escrita). **Diferido:** 1 MC metalingüístico sobre superlativos (impreciso, no incorrecto); formato de
los 24 listening "elige el significado" no guarda el inglés oído en `payload.say` (audio funciona,
HEAD 200; no regenerable desde DB) — nota de arquitectura, no error.

**Blindaje (CI):** +3 tests de grader (sinónimos vía `accepted`, have got↔have, dígito en cloze).
**Verificación:** validador determinista **0** en ambos cursos; cliente real acepta las variantes y
rechaza lo erróneo; `correct_answer` 42501; analyze 0 · test 52/52 · build OK; loop/seguridad/ligas intactos.
**Pendiente:** auditar es→en B1/B2/C1 y es→pt (siguiente pasada; prioricé A1/A2 = lo que los testers usan hoy).

---

## GRADING + TIPS + WORD_BANK (feedback real) — 2026-06-24 (mig 067/068/069) · ✅ LIVE
**P0 — grading marcaba CORRECTO como incorrecto** ("Soy de Perú." → "I'm from Peru" salía ROJO;
el usuario veía "I''m"). **Causa raíz DOBLE:** (a) DATA: 15 ítems es→en A1 sembrados con apóstrofe
PRE-escapado dentro de un literal dollar-quoted `$j$` → quedó `I''m` (doble) en payload y
correct_answer; (b) NORMALIZACIÓN: `jz_normalize` no tocaba apóstrofes ni equiparaba contracciones.
**Fix (mig 067, raíz, sin aflojar):** `jz_normalize` ahora normaliza apóstrofes (tipográfico→recto,
`''`→`'`), EXPANDE ~58 contracciones a forma completa bidireccional (I'm↔I am, don't↔do not, what's
↔what is, it's↔it is, can't↔cannot…) y quita apóstrofes residuales; + limpió los 15 ítems (`''`→`'`)
y regeneró 4 audios cuyo texto hablado estaba corrupto. Espejo client-side en `grader.dart` (mismos
casos) + **5 tests nuevos** que el CI blinda. Verificado cliente real: `grade_item` acepta "I'm from
Peru" Y "I am from Peru", rechaza "I am from Brazil"; `correct_answer` sigue 42501; feedback limpio.

**P1 — word_bank/reorder REGALAN la respuesta** (enunciado mostraba el target en inglés → copiar,
no aprender). **Fix (mig 068, 20 ítems):** el enunciado da el SIGNIFICADO en español; las tiles
siguen en inglés (producción real). Grading sin cambios. Barrido: es→pt word_bank ya estaba limpio.

**P1 — tip descontextualizado y repetido** (tip de EDAD en lección de PAÍSES; mismos tips repetidos).
**Causa:** `get_lesson_tip` filtraba por `unit_order`, pero los tips estaban mal alineados con dónde
vive el concepto en el contenido, y el desempate era random. **Fix (mig 069):** nueva columna
`content_tips.topic` (66/72 tips mapeados al vocabulario de tags del contenido). `get_lesson_tip`
ahora calcula los conceptos REALES de la lección (tags de sus content_items) y prioriza: relevancia
exacta > tip general del nivel > misma unidad > skill flojo > **no visto > menos reciente** (anti-
repetición). Un tip con topic SOLO aparece en lecciones que cubren ese concepto. Verificado cliente
real: edad→"Tu edad", numeros→plural, posesivos→posesivo, rutina→adverbios; países ya NO da "Tu
edad" (da un tip general); 6 lecciones seguidas rotan por 4 tips distintos sin repetir consecutivo.

**Barrido de calidad (profesor):** 0 match ambiguos (parejas con misma respuesta) en ambos cursos;
0 colisiones de opciones mc/listening bajo la nueva normalización; los 12 translations es→en con
contracción en el value quedan auto-cubiertos por `jz_normalize`. analyze 0 · test 49/49 · build OK ·
loop/seguridad mig 058/ligas intactos.

---

## HISTORIAS / INMERSIÓN — construido 2026-06-24 (mig 065 + 066) · ✅ LIVE
**Qué existía:** nada. La capa "enseña" previa era tips/cuaderno (mig 057) + Referencia (mig 060);
no había historias. La "Sesión de inmersión" de Metodologia.md estaba sin construir.

**Qué construí:** input comprensible real en **Practicar → Inmersión**. **6 historias es→en** (3 A1 +
3 A2), narrativas/diálogos cortos curados con relevancia LATAM (mañana en casa, mercado, amigo
nuevo; fin de semana, viaje en micro, cumpleaños), calibradas i+1, con **audio por segmento**
(TTS, **46/46** en Storage) y **30 preguntas de comprensión** (mc/cloze) auto-calificables.

**Diseño (aísla del loop y respeta el grading seguro):** las preguntas NO son `content_items`
(si lo fueran, los pools de `start_practice` las servirían sin contexto) → viven embebidas en
`stories.questions`, columna **REVOCADA al cliente** (como `correct_answer` en mig 055). Calificación
100% server-side (`submit_story` → `jz_grade`). RPCs: `get_stories`/`get_story` (sin respuestas) +
`submit_story` (XP modesto +12 solo en 1er completado, alimenta racha). Audio en `audio/stories/`
(Storage, no toca assets de Flutter → sin riesgo del gotcha de CI).

**Verificación (cliente real, `verify_stories.py`):** get_stories=6 · get_story sin respuestas ·
lectura directa de `stories.questions` → **denegada** · submit correctas → score 1.0 + XP 12 (1ra vez),
2do sin XP · submit incorrectas → score 0 + `expected` para review · **audio HEAD 46/46**. UI: widget
test "Inmersión lista historias" + analyze 0 · test 44/44 · build web OK. Loop/seguridad mig 058/
ligas intactos (`verify_chain` A1→B2 PASS; migraciones aditivas).

**Diferido:** historias B1/B2 y es→pt (empezar por los niveles que tocan los primeros usuarios);
preguntas de listening dedicadas (hoy la comprensión es lectura, el audio es el input); analítica
de inmersión (eventos no añadidos al allowlist de `log_event` → se difiere para no tocar mig 058).

---

## CI (GitHub Actions) — RESUELTO ✅ 2026-06-24 · regla: CI = fuente de verdad, no el local
**Síntoma:** todas las corridas del workflow "CI" (#47–#56) en ROJO, incluso commits triviales —
mientras el **deploy de Vercel de esos mismos commits estaba READY** (prod live). → el fallo NO era
build/deploy sino un step de Actions común a todos.

**Causa raíz (1 línea):** el step **Analyze** falla con
`warning • The asset file '.env' doesn't exist • pubspec.yaml:80:7 • asset_does_not_exist` →
`flutter analyze` sale con código ≠0 y **aborta el job** (Tests y Build quedan *skipped*). `.env`
es un asset DECLARADO en `pubspec.yaml` pero **gitignored** (sin secretos en repo). El step de Build
sí creaba `.env` con `touch`, pero **corre DESPUÉS de Analyze**.

**Por qué el local daba FALSO VERDE:** en la máquina de Gian `.env` existe (lo usan las tools, 353 B)
→ analyze local pasa. En CI el checkout no lo tiene → analyze rojo. Reproducido en local:
`mv app/.env app/.env.bak && flutter analyze` → mismo `asset_does_not_exist`.

**Fix de raíz (sin trampa — no se tocó ningún test/check):** en `ci.yml`, step **`Prepare .env`**
(`touch .env`) **antes** de Analyze (no solo en Build) + Flutter **pinneado a 3.44.3** (CI usaba
`stable` flotante = 3.44.3; local 3.44.1 → deriva). El `.env` vacío basta: `supabase_config.dart`
usa fallback público embebido y lee `.env` de forma segura (`dotenv.isInitialized`).

**Regla operativa (nueva):** el verde del **CI de GitHub Actions es la fuente de verdad, no el
`flutter analyze` local**. Antes de declarar verde, correr el comando EXACTO del workflow en las
mismas condiciones (sin `.env`, versión pinneada). Detalle en CLAUDE.md §CI.

---

## 0. Veredicto honesto del producto

Jezici es un MVP **sorprendentemente completo y bien construido en su núcleo**:
el loop de lección, la economía (XP/oro/vidas), checkpoints, exámenes de nivel
con certificados, práctica con SRS, logros, ligas, racha, onboarding con
placement, notificaciones Matix, y **dos cursos** (es→en, es→pt). El toolchain
está **verde** (analyze 0 issues, 38 tests pasan, build web OK). La postura de
seguridad del *core* es genuinamente buena: scoring server-side, RLS por
usuario, y el vector crítico `correct_answer` **está cerrado de verdad**
(verificado: `permission denied`).

Pero el producto **no está listo para un público amplio** por dos motivos
materiales y verificados:

1. **El audio está incompleto al 69%.** es→en A1/A2 tienen el 100% del audio;
   **es→en B1, es→en B2 y TODO el curso es→pt (A1+A2) tienen 0 archivos de
   audio** (216 de 312 ítems de listening/speaking apuntan a `.mp3` que
   devuelven HTTP 400). Como *listening ya es un ejercicio calificable*, un
   alumno de B1/B2/pt se topa con preguntas de listening **sin audio**.
2. **Las ligas son una fachada parcial.** Acumulan XP y muestran ranking, pero
   **no existe job de cierre semanal ni ascensos/descensos**: la UI promete
   "los primeros 5 ascienden" y eso **nunca ocurre**.

La seguridad tiene 4 hallazgos abiertos reales pero de impacto acotado (todos
confirmados en vivo). Ninguno es crítico ahora que `correct_answer` está cerrado.

**Listo para:** seguir con beta cerrada de es→en A1–A2.
**No listo para:** promocionar B1/B2, lanzar es→pt, o prometer ligas competitivas.

---

## 1. Estado general — documentado vs construido

### Toolchain (números reales, ejecutados hoy)

| Comando | Resultado |
|---|---|
| `flutter analyze` | **exit 0** — sin issues |
| `flutter test` | **38/38 PASA** ("All tests passed!") — 8 archivos de test |
| `flutter build web --release` | **OK** en 53,5 s (build JS). Aviso: wasm dry-run falla por `ua_client_hints`→`dart:html` (no bloquea el build JS actual) |

Tests existentes: `estimation`, `grader`, `lesson_complete_celebration`,
`lesson_flow`, `speech_match`, `streak_meta`, `text_match`, `widget`. Cubren el
grader y el flujo de lección; **no hay** tests de ligas, checkpoint-gating,
mastery por skill, ni de audio.

### Construido y funcionando
- Loop de lección + 9 tipos de ejercicio (`multiple_choice` 265, `cloze` 133,
  `translation` 122, `listening` 122, `speaking_read_aloud` 122, `match` 107,
  `word_bank` 68, `reorder` 61). **1.228 content_items** en BD.
- Grading server-side (`grade_item`, mig 055) + vista `content_items_public` sin
  `correct_answer` (mig 056).
- Checkpoints con gating ≥80%, exámenes de nivel multinivel + certificados SVG.
- Práctica + SRS, logros, tienda/cofre, racha, ligas semanales, Matix.
- Multi-curso (es→en A1–B2, es→pt A1–A2) con curso activo por usuario.
- Onboarding: placement + test de personalidad + "tu plan".

### Documentado-pero-NO-construido (o parcial)
- **C1/C2:** referidos en `docs/LEVELS_DESIGN*.md`; **no sembrados** (BD solo
  llega a B2 en es→en).
- **Conversar / Simulacros:** pantallas existen pero **ocultas** (decisión GA6,
  ver `jezici-production-state`). `conversation_attempts: 0` en métricas.
- **Ligas — ascensos/descensos + cierre semanal:** prometidos en la UI,
  **sin implementación** (§3).
- **Rankings mensual/anual/histórico:** **ausentes por completo** (§3).
- **`export_my_data()` (GDPR portabilidad):** en el plan de `SECURITY.md`,
  **no existe** (verificado: `PGRST202 function not found`) (§4).

### Construido-pero-poco-documentado
- Blindaje de grading (mig 055/056) y capa "enseña" / tips+cuaderno (mig 057):
  recientes, aún sin doc dedicado más allá del changelog de commits.

---

## 2. AUDIO (máxima prioridad)

### Mapa de superficies

| Superficie | API / motor | Archivo |
|---|---|---|
| **SFX** (correct/wrong/combo/…) | Web Audio API (web) · `audioplayers` (nativo) vía `AudioEngine` | `core/audio/sound_service.dart`, `core/audio/audio_engine_web.dart` |
| **Listening** (reproducción TTS) | `AudioEngine.playUrl` → `fetch` + `decodeAudioData` + `BufferSource` | `features/lesson/exercises/audio_play_button.dart`, `listening_exercise.dart` |
| **Speaking / micrófono (STT)** | `speech_to_text` (nativo) · Web Speech API crudo (web) | `core/speech/speech_recognizer_*.dart`, `features/lesson/exercises/speaking_exercise.dart` |

Decisión de diseño deliberada y **correcta**: en web NO se usan elementos
`<audio>` ni `MediaSession`, precisamente para que iOS Safari **no** muestre el
reproductor "now-playing" en la pantalla de bloqueo (`audio_engine.dart:3-6`,
`_clearMediaSession()` en `audio_engine_web.dart:76-89`). 7 SFX `.wav` reales
bundleados en `assets/sfx/`.

> **ACTUALIZACIÓN 2026-06-22 (misión audio P0+P1) — RESUELTO ✅**
> - **A1 (216 audios faltantes subidos):** se generó y subió el TTS de los 216
>   ítems (es→en B1/B2 + es→pt A1/A2) con `tools/content/gen_audio_missing.py`
>   (mismo pipeline Google translate_tts; `tl=en`/`tl=pt`). **Cobertura
>   96/312 → 312/312 (100%)**, verificado con HEAD (0 faltantes).
> - **A2 (degradación con gracia):** si el audio de un listening no resuelve, el
>   loop lo **salta sin penalización** (no pide respuesta a ciegas, no resta
>   vidas, se omite de `complete_lesson`) y `AudioPlayButton` muestra "Audio no
>   disponible" en vez de colgarse 12 s. Red de seguridad permanente.
> - **Desbloqueo iOS:** `Listener(onPointerDown)` global en `main.dart` (sobre el
>   Navigator) desbloquea el AudioContext en el primer gesto real, en cualquier
>   pantalla. analyze 0 · test 40/40 (+1 de skip) · build web OK.
>
> **DEPLOY DE VERCEL — RESUELTO ✅ (2026-06-23, fix `68266d3`):** NO era billing ni
> bloqueo de cuenta. Era una **regresión de `vercel.json`**: `25f49c9` (19-jun) añadió
> `--dart-define=JZ_BUILD=$VERCEL_GIT_COMMIT_SHA` al `buildCommand` → desde ahí TODOS
> los deploys daban **ERROR instantáneo pre-build, sin logs** (`buildingAt==ready`).
> **Confirmado por aislamiento (vía Vercel API):** revertir el `buildCommand` a la
> config **byte-idéntica a 7e26824** (sin ese flag) → deploy **READY en ~152 s** y
> aliased a `jezici.vercel.app`. Toda variante con el flag JZ_BUILD (incl. mi intento
> con `$(git rev-parse …)`, `1b5b818`) fue rechazada pre-build → **no reintroducir el
> sello en el buildCommand**. **Producción de nuevo LIVE** con TODO el código acumulado
> desde 7e26824 (audio P0/P1 + seguridad mig 058 frontend). Sello `JZ_BUILD` queda en
> `dev` (pendiente; recuperarlo necesita otro método, no `--dart-define` inline).
> El detalle original del hallazgo se conserva abajo.

### Hallazgos

#### 🟢 P0 — Audio de listening/speaking faltante (RESUELTO ✅ — 312/312)
- **Síntoma (original):** en es→en B1/B2 y en todo es→pt, el botón "Escuchar" no
  reproducía nada; el alumno respondía un *listening* (calificable) **sin oír**.
- **Repro (verificado en vivo, pre-fix):** HEAD a las 312 URLs de `payload.audio_url`:

  | Curso | Nivel | Con audio (200) | Sin audio (400) |
  |---|---|---:|---:|
  | es→en (…001) | A1 | 48 | 0 |
  | es→en (…001) | A2 | 48 | 0 |
  | es→en (…001) | **B1** | **0** | **48** |
  | es→en (…001) | **B2** | **0** | **48** |
  | es→pt (…002) | **A1** | **0** | **48** |
  | es→pt (…002) | **A2** | **0** | **72** |

  **Total: 96 reales / 216 faltantes (31% de cobertura).** Los que existen son
  `.mp3` reales (~9–14 KB, HTTP 200); los faltantes dan `400 Bad Request`
  (objeto inexistente en el bucket `audio/items/`).
- **Causa probable:** la generación/subida de TTS a Supabase Storage solo se
  corrió para es→en A1–A2. Los seeds B1 (mig 043), B2 (mig 045) y pt (mig 048,
  052) escribieron `audio_url` apuntando a `…/audio/items/<id>.mp3` pero **los
  archivos nunca se subieron**.
- **Ubicación:** datos en `content_items.payload.audio_url`; pipeline de subida
  en `tools/content/` (fuera del runtime). El cliente solo consume la URL en
  `audio_play_button.dart:39`.
- **Fix aplicado:** (a) `gen_audio_missing.py` regeneró y subió los 216 al bucket
  → **312/312**; (b) degradación con gracia permanente (skip sin penalización +
  `AudioPlayButton` "Audio no disponible") como red de seguridad ante futuros
  faltantes. `AudioEngine.isUrlAvailable` (HEAD en web) detecta el 400.

#### 🟢 P1 — Desbloqueo del AudioContext fuera de gesto (RESUELTO ✅)
- **Síntoma:** en iOS Safari/PWA, el primer SFX (p. ej. el "correcto" tras
  responder) puede salir mudo, y/o el primer listening requiere un segundo tap.
- **Causa probable:** `AudioEngine.instance.unlock()` se llama en
  `lesson_player_screen.dart:56` dentro de **`initState()`**, que corre tras la
  navegación, **no dentro de un gesto de usuario**. iOS exige que
  `AudioContext.resume()` se dispare **síncronamente** desde un gesto; llamarlo
  en `initState` es no-op en iOS. **No existe** un `Listener`/`onPointerDown`
  global en `main.dart` que desbloquee el contexto en el primer toque de la app
  (verificado: 0 coincidencias). Los SFX programáticos (tras un `await` del RPC
  de grading) caen fuera de la ventana del gesto → iOS los suprime hasta que un
  tap real reanude el contexto.
- **Ubicación:** `audio_engine_web.dart:100-107` (`unlock`),
  `sound_service.dart:27-31` (`warmUp` solo se llama al reproducir un SFX),
  `lesson_player_screen.dart:56`.
- **Fix aplicado:** `_AudioUnlockGate` en `main.dart` (vía `MaterialApp.builder`,
  sobre el Navigator → cubre rutas pusheadas) con `Listener(onPointerDown)` de un
  solo disparo que llama `AudioEngine.instance.unlock()` síncronamente en el
  primer gesto real. Se mantiene el `unlock()` de `initState` como refuerzo.

#### 🟢 OK — Listening ya es calificable; SFX sin solapamiento; TTS sin solapar
- `jz_is_stub` fue redefinido (mig 027): listening **dejó de ser stub**, hoy se
  califica como multiple-choice (`listening_exercise.dart`, `grader_test.dart`).
  Solo `speaking_read_aloud`, `dictation`, `guided_writing` siguen siendo stubs.
- `playUrl` corta el TTS previo antes de iniciar otro (`audio_engine_web.dart:
  163-176`) → no se solapan voces. SFX se cachean por buffer (sin recorte mutuo).
- Speaking degrada con gracia ("Ya lo leí ✓") si no hay micrófono/permiso
  (`speaking_exercise.dart:106-121`).

---

## 3. PROGRESIÓN

> Investigado a fondo; varias afirmaciones iniciales fueron **descartadas** al
> contrastarlas con el contenido real y la redefinición de `jz_is_stub`.

### Cómo funciona (verificado)
- **Persistencia** (`complete_lesson`, mig 015 / 040 / 041): escribe en
  `user_lesson_progress` → `status` (`completed`/`golden`), `best_accuracy`,
  `times_completed`, `completed_at`. Precisión = `correctos / calificables`.
- **Desbloqueo de lección:** al **completar** una lección (cualquier accuracy)
  se inserta la siguiente como `available` (mig 015:290-308 / mig 041:429-440).
- **Gating de checkpoint (≥80%):** server-side en `submit_checkpoint`
  (mig 016:130-131, `v_passed := v_graded>0 and v_acc>=0.80`). Solo entonces
  desbloquea la **primera lección de la siguiente unidad** (mig 016:215-227).
  El cliente NO valida el 80% — confía en el servidor (correcto).
- **Examen de nivel:** compuerta por **mastery por skill ≥0.80** revalidada al
  enviar (`submit_level_exam`, mig 041) — no se salta por atajo REST.
- **Derivación de nodo** (`learn_map_screen.dart:181-200`): `status` BD →
  `NodeState`. Fallback heurístico mientras carga el provider (`:196-199`).

### Hallazgos

#### 🟠 P1 — Listening sin audio degrada la jugabilidad (no bloquea el avance, pero baja accuracy)
- **Síntoma:** en B1/B2/pt, los ítems de *listening* (calificables) no tienen
  audio → el alumno responde a ciegas, falla, pierde vidas. La lección **igual
  se completa y desbloquea** la siguiente (el desbloqueo no depende de accuracy),
  pero la precisión baja y puede agotar vidas / frustrar.
- **Causa:** consecuencia directa del P0 de audio × listening-calificable.
- **Fix:** mismo que el P0 de audio (subir audio o degradar el ítem).

#### 🟡 P2 — Caso "lección/checkpoint solo-stub" es TEÓRICO (no ocurre en el contenido actual)
- Un análisis estático sugería que un checkpoint compuesto **solo** de stubs
  daría `v_graded=0` → `v_passed=false` → unidad siguiente nunca desbloquea.
- **Verificado contra la BD:** de 181 lessons (144 lesson, 36 checkpoint, 1
  mission), **0 tienen items 100% stub** (recordar: listening ya NO es stub).
  El riesgo es real a nivel de motor pero **no se materializa** con el seed
  actual. Conviene un guard defensivo (`if v_graded=0 then pasar/saltar`) por si
  contenido futuro introduce un checkpoint solo-speaking.

#### 🟡 P2 — Ramas muertas / inconsistencias menores de estado
- `learn_map_screen.dart:190` maneja `case 'in_progress'`, pero ese status
  **nunca se persiste** (rama muerta).
- Lección 100% stub (p. ej. solo speaking) se marca `completed` con
  `best_accuracy=0` → barra de progreso semánticamente rara (no bloquea).

#### ⚪ Sin evidencia — "race condition al invalidar antes del commit"
- Se planteó que `invalidate(lessonProgressProvider)` tras cerrar la lección
  podría leer antes de que el servidor escriba y revertir el nodo a `locked`.
  Es **plausible pero no reproducido**; `complete_lesson` es una transacción y
  el `invalidate` ocurre tras `await` del RPC. Lo dejo como hipótesis a vigilar,
  no como hallazgo confirmado.

**Condiciones exactas en que "no se avanza" (honesto):** no encontré un bloqueo
*duro* de avance en el contenido sembrado. Lo que el usuario percibe como "no
avanza bien" se explica mejor por: (a) **listening sin audio** en B1/B2/pt
bajando accuracy y agotando vidas (P1), y (b) la **compuerta de mastery por
skill ≥0.80** para el examen de nivel — que es *por diseño* pero puede sentirse
como un muro si una skill (p. ej. speaking, que es participación) no acumula
dominio como el alumno espera. Recomiendo instrumentar `log_event` con el
`item_id`/`lesson_id` en fallos para confirmar el caso real con datos.

---

## 4. LIGAS

> **ACTUALIZACIÓN 2026-06-23 (misión ligas+leaderboards) — L1/L2 RESUELTOS ✅ (mig 059):**
> - **Rollover real:** `jz_close_weeks()` cierra cada semana vencida — **idempotente**
>   (marca `league_periods_closed`; 2ª pasada → 0) y **lazy** (se llama dentro de
>   `get_league`/`get_leaderboard`, no depende de cron). Escribe **snapshots**
>   (`league_snapshots`) y aplica **ascensos (top 7) / descensos (fondo 5)** entre
>   Bronce↔Diamante vía `user_division` + `jz_ensure_league` divisional. Movimiento solo
>   en ligas ≥13 (sin solape); en beta (<13) nadie se mueve, por diseño.
>   Verificado en vivo: semana 2026-06-15 cerrada, 6 snapshots, idempotente; lógica
>   probada en escenario sintético de 15 (1-7 suben, 8-10 quedan, 11-15 bajan; extremos capados).
> - **Leaderboards:** `get_leaderboard(metric, window, scope, limit, offset)` SECURITY
>   DEFINER, **SIN user_id** (rank/name/value/is_me). Métricas XP/Lecciones/Racha/Certificados ×
>   ventanas Semanal/Mensual/Anual/Histórico × alcance Global/División, derivadas de las
>   fuentes vivas (daily_goals, user_lesson_progress, streaks, certificates). Top-N + paginación.
>   Verificado: league_members/leagues siguen **403**; ninguna combinación filtra UUIDs.
> - **UI:** pestaña Ligas con segmento **Mi liga | Tablas**; Tablas con selectores
>   Métrica × Ventana × Alcance. Conserva el board semanal por división (zonas reales).
> - **Cron pendiente del dueño** (no bloqueante; el lazy-close cubre): `pg_cron` (Pro) o
>   Edge Function + cron externo llamando a `jz_close_weeks()`. Detalle en CLAUDE.md.
> - analyze 0 · test 42/42 (+ parse de LeaderboardResult + render de Tablas) · build web OK.
> El detalle original (pre-fix) se conserva abajo.

### Estado real por componente (pre-fix)

| Componente | Estado | Ubicación |
|---|---|---|
| Esquema `leagues` / `league_members` | ✅ | mig 009:38-58 |
| Acumulación `weekly_xp` (`jz_add_league_xp`) | ✅ | mig 024:58-71; enganchado en complete_lesson/checkpoint/practice/exam (mig 040:206/356/448/556) |
| Alta automática a liga (`jz_ensure_league`) | ✅ crea ligas Bronce dinámicas (cupo <30) | mig 024:24-56 |
| Ranking en vivo + modo "warming_up" (<5) | ✅ `get_league` | mig 036:15-56; `leagues_screen.dart` |
| **Ascensos / descensos** | ❌ **no implementado** | UI promete "top 5 ascienden" (`leagues_screen.dart:~87,142`) — falso |
| **Job de cierre semanal / rollover** | ❌ **ausente** (sin pg_cron, sin Edge Function, sin trigger) | — |
| **Reset de `weekly_xp`** | ⚠️ no hay reset; cada semana es una **nueva** `league_id` (`date_trunc('week', current_date)`, lunes UTC) → filas viejas quedan huérfanas | mig 024:24-40 |
| **Histórico / mensual / anual** | ❌ **ausente** — los datos semanales se descartan | — |

- Verificado en vivo: hay ligas reales (`bronce`, `week_start` 2026-06-15 y
  2026-06-22) con miembros y `weekly_xp` reales (25, 260, 364…). Sin bots.
- La columna `league_members.rank` existe pero **nunca se rellena** (el ranking
  se calcula con `row_number()` en `get_league`).

### Gap para rankings mensual/anual/histórico (lo que pide el dueño)
**Hoy no hay nada que lo soporte.** Faltaría:
1. **Snapshots semanales** — tabla `league_snapshots(user_id, week_start,
   division, final_rank, final_xp)` poblada por un job de cierre.
2. **Job/cron de fin de semana** — Supabase no trae cron en plan estándar:
   Edge Function con disparador HTTP programado, o RPC `close_week()` invocada
   por un scheduler externo (o `pg_cron` en Pro).
3. **Vistas/RPC agregadas** — `user_monthly_stats`, `get_monthly_leaderboard`,
   etc., derivadas de los snapshots.
4. **Lógica de ascenso/descenso** — sin esto, ni el ranking semanal "compite".

> **P1 de producto (no de seguridad):** la UI promete ascensos que no existen.
> Antes del público, o se implementa el rollover, o se ajusta el copy para no
> prometer algo que no ocurre.

---

## 5. SEGURIDAD (contraste con `SECURITY.md`, verificado en vivo)

> Método: cliente REST con **JWT autenticado real** (usuario creado y luego
> borrado con `delete_account`, que respondió 204). Sin `service_role`.

### ✅ Confirmado CERRADO
- **`correct_answer` (el CRÍTICO):** `GET content_items?select=correct_answer`
  → **`42501 permission denied`** (anon y authenticated). La vista
  `content_items_public` no expone la columna. **Cierre real.**
- **Helpers `jz_*` (mig 049):** revocados a authenticated/anon/public (no
  reprobado en vivo por no tocar datos, pero la revocación está en el SQL).

### Estado de los 4 hallazgos — TODOS CERRADOS ✅ (mig 058 · 2026-06-23)

Aplicada `20260623100058_security_hardening.sql` (efecto YA en DB). Verificado con
**JWT autenticado real** (usuario creado y borrado con `delete_account`; sin `service_role`).

| # | Hallazgo | Estado | Evidencia (JWT real) |
|---|---|---|---|
| 1 | **`league_members`/`leagues` SELECT abierto** (filtraba UUIDs de auth) | ✅ **CERRADO** | SELECT directo → **HTTP 403** (revoke + drop policy). `get_league` (DEFINER) sigue **200** y sus `members` ya NO traen `user_id` (solo `name/rank/weekly_xp/is_me`). Build live 7e26824 usa solo `get_league` → intacto. |
| 2 | **Gate de admin en `get_metrics`/`get_engagement`/`get_onboarding_funnel`** | ✅ **CERRADO** | No-admin → **`admin only`** (P0001) en los 3. Admin (test uid añadido a `admins`, JWT real) → **200** (`total_users=8`). Dueño Gian (`7b4a8e40-…`) sembrado en `admins` → su panel sigue OK en el build live. |
| 3 | **`log_event` sin allowlist/truncado/rate-limit** | ✅ **CERRADO** | Evento válido `screen_view` → insertado; **`AUDIT_BOGUS_EVENT` → 0 filas** (descarte silencioso, 204); props de 5KB en evento válido → fila con `{"_truncated":true}`. Rate-limit 120/usuario/min. Los 8 eventos del cliente live siguen entrando. |
| 4 | **`export_my_data()` (GDPR)** | ✅ **CERRADO** | RPC DEFINER acotada a `auth.uid()` → **200** con 24 secciones (stats, progreso, skills, certs, …). Botón "Exportar mis datos" en Ajustes (frontend **deploy-pending**). |

**Mecanismo de admin nuevo:** tabla `admins(user_id)` + `jz_is_admin()` (no se gestiona
por roles SQL; agregar/quitar = `insert/delete` en `admins`). Dueño ya sembrado.

> Nota: `submit_level_exam` **no** se tocó (no es vector de farm ahora que 055 cerró
> `correct_answer`: solo re-otorga XP `if v_any`/subida real). Riesgo agregado de
> seguridad: **bajo** tras esta migración.

### Compatibilidad con el build LIVE (7e26824) — confirmado ✅
- Ligas: el cliente live llama **solo** `get_league` (verificado con `git grep` en 7e26824;
  0 lecturas directas a `leagues`/`league_members`) → cerrar el SELECT **no lo rompe**.
- Analytics: los 8 eventos que emite el cliente live están en la allowlist → siguen entrando.
- Métricas: el panel interno (live) llama `get_metrics`/`engagement`/`funnel` solo desde
  `MetricsScreen` (nav manual). Gian (admin) sigue viéndolas; un no-admin verá `admin only`
  en ese panel interno (aceptable; es interno).

---

## 6. Tabla maestra de hallazgos priorizados

| ID | Área | Prio | Hallazgo | Verificado |
|---|---|---|---|---|
| A1 | Audio | 🟢 P0 ✅ | 216 audios faltantes generados+subidos → **312/312 (100%)** | Sí (HEAD post-fix) |
| A2 | Audio | 🟢 P1 ✅ | Desbloqueo iOS por gesto global + degradación con gracia (skip sin penalizar) | Sí (test 40/40) |
| P1 | Progresión | 🟢 P1 ✅ | Listening sin audio ya no penaliza (se salta) y además el audio existe | Sí (deriva de A1/A2) |
| P2 | Progresión | 🟡 P2 | Guard faltante para checkpoint solo-stub (teórico; 0 casos en seed) | Sí (BD: 0 casos) |
| P3 | Progresión | 🟡 P2 | Rama muerta `in_progress`; accuracy=0 en lección solo-stub | Sí |
| L1 | Ligas | 🟢 P1 ✅ | Rollover real (mig 059): cierre idempotente/lazy + ascensos/descensos; UI ya no miente | Sí (live + sintético) |
| L2 | Ligas | 🟢 P2 ✅ | Snapshots + get_leaderboard (mensual/anual/histórico, global/división, sin UUIDs) | Sí (JWT real) |
| S1 | Seguridad | 🟢 P1 ✅ | `league_members`/`leagues` SELECT cerrado (403); `get_league` sin UUIDs (mig 058) | Sí (JWT real) |
| S2 | Seguridad | 🟢 P1 ✅ | Gate admin en get_metrics/engagement/funnel (`admins`+`jz_is_admin`); Gian sembrado | Sí (JWT real) |
| S3 | Seguridad | 🟢 P2 ✅ | `log_event` allowlist(8)+truncado(>2KB)+rate-limit(120/min) | Sí (bogus→0 filas) |
| S4 | Seguridad | 🟢 P2 ✅ | `export_my_data()` (24 secciones) + botón Ajustes (frontend deploy-pending) | Sí (200, 24 claves) |
| G1 | General | 🟡 P2 | C1/C2 y monthly leagues documentados, no construidos; Conversar/Simulacros ocultos | Sí |

---

*Auditoría sin cambios de código. Usuario de prueba creado para los chequeos
autenticados y eliminado con `delete_account` (HTTP 204). Los eventos
`AUDIT_PROBE_*` insertados en `analytics_events` (6) están ligados a ese usuario
borrado.*

---

## Checklist de verificación MANUAL para Gian (en dispositivo real)
> Lo de arriba se verificó con el cliente REST real. Esto requiere ojos+oídos en un
> teléfono real (audio, gestos, PWA). Marca cada uno. Si algo falla, anota modelo +
> navegador.

### iPhone (Safari → "Añadir a pantalla de inicio" → abrir como PWA)
- [ ] **1er tap desbloquea el audio:** abre la app, toca cualquier parte una vez;
      a partir de ahí los sonidos funcionan (no hace falta tocar dos veces).
- [ ] **SFX "correcto" suena tras calificar:** en una lección, responde bien y
      comprueba que suena el efecto al marcar correcto (no mudo el primero).
- [ ] **Listening con audio en B1/B2 y portugués:** entra a una lección de B1 o B2
      (es→en) y a una de es→pt; en un ejercicio de escucha, el botón reproduce voz.
- [ ] **Degradación con gracia:** (si algún audio faltara) el ejercicio muestra
      "Audio no disponible" y deja continuar **sin** restar vidas — no pide adivinar.
- [ ] **NO aparece reproductor en la pantalla de bloqueo** al sonar audio (Web Audio).
- [ ] **Ligas → "Mi liga":** carga tu división y tu posición de la semana.
- [ ] **Ligas → "Tablas":** cambia Métrica (XP/Lecciones/Racha/Certificados),
      Ventana (Semanal/Mensual/Anual/Histórico) y Alcance (Global/Mi división);
      la lista cambia y **"Tu posición: #N"** coincide contigo.
- [ ] **Ajustes → "Exportar mis datos":** abre el JSON y "Copiar" funciona.
- [ ] **Aviso de nueva versión:** tras un próximo deploy, con la PWA abierta aparece
      "Hay una versión nueva — Recargar" (no auto-recarga).

### Android (Chrome, e instalada como PWA)
- [ ] **1er tap desbloquea el audio** (igual que iOS).
- [ ] **SFX "correcto" suena tras calificar.**
- [ ] **Listening B1/B2/pt suena**; micrófono del speaking pide permiso y "Ya lo leí ✓"
      aparece si se deniega.
- [ ] **Ligas "Mi liga" y "Tablas" cargan**; "Tu posición" correcta.
- [ ] **Exportar mis datos** funciona.
- [ ] **Aviso de nueva versión** tras un deploy.

> Sello de build: en Ajustes se ve "Jezici 1.0.0 · **dev**" — es esperado (el sello
> `JZ_BUILD` quedó pendiente tras el fix de deploy; no afecta funcionalidad).
