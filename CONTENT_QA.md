# Jezici — Auditoría pedagógica del contenido (CONTENT_QA.md)

> Auditoría profesor-IA (12 agentes en paralelo, 1/unidad) de **es→en A1/A2 = 384 ítems**
> (lección + checkpoint). Cada ítem evaluado: correctitud, tolerancia, distractores,
> revelación de respuesta, naturalidad, alineación CEFR, claridad, redundancia, skill.
> Fecha 2026-06-24. **Resultado: 0 P0** (ninguna respuesta marcada es incorrecta).

## Resumen

- Severidad: **P0=0 · P1=23 · P2=5** (28 hallazgos).
- Clase dominante (sistémica): **tolerancia_insuficiente (22)** — translation/cloze a los que les
  faltaba una variante natural (sinónimo, artículo, número, have got, please, o'clock, get/grab…).
- Otras: distractor_ambiguo 1 · cefr_misalign 2 · instruccion_ambigua 1 · no_natural 1 · skill_mal 1.

## Disposición (con criterio de profesor)

**Arreglado (mig 070):** 20 ítems con tolerancia ampliada (additivo a `accepted`, no acepta lo
erróneo; el grader ya normaliza apóstrofes/contracciones/puntuación) + 2 pulidos: instrucción del
cloze `(cook)` (ahora pide la forma -ing) y match de partes del día (evening/tarde-noche ambiguo →
morning/mañana).

**Rechazado (reducirían tolerancia válida o juicio incorrecto):**
- `c2000068` cloze "I need a ___ to Madrid": el agente proponía quitar train/bus, pero son inglés
  natural → se mantienen.
- `c4400000` cloze "How ___ is it? (much)" etiquetado writing→reading: en esta app cloze=writing
  (el usuario PRODUCE la palabra escribiéndola). Correcto como está.

**Diferido (no es error; mejora mayor):**
- `c2000155`: MC metalingüístico sobre superlativos; la opción correcta no es incorrecta, solo imprecisa → reescritura diferida.
- `48000000`: Listening formato "elige el significado"; el inglés oído no se guarda en payload.say (24 ítems). El audio funciona (HEAD 200); vocab "phone number" fuera de la unidad to_be = P2 de alcance, no error.

## No auditado todavía (siguiente pasada)
- es→en **B1/B2/C1** y **es→pt** (todos los niveles). Prioricé A1/A2 por ser lo que los testers usan hoy.

## Tabla de hallazgos

| Sev | Clase | Unidad | id | Issue | Disposición |
|---|---|---|---|---|---|
| P1 | distractor_ambiguo | _audit\A1_u02 | `48000000` | Listening con value '¿Cuál es tu número de teléfono?' bajo el tag 'to_be'; introduce 'núme | ⏭️ diferido |
| P1 | tolerancia_insuficiente | _audit\A1_u01 | `43000000` | translation de "Mi nombre es Carlos" solo acepta "My name is Carlos". Un aprendiz escribir | ✅ arreglado (mig 070) |
| P1 | tolerancia_insuficiente | _audit\A1_u02 | `45000000` | Cloze 'I have ___ books.' solo acepta 'two', pero la pista del enunciado es la cifra '(2)' | ✅ arreglado (mig 070) |
| P1 | tolerancia_insuficiente | _audit\A1_u02 | `46000000` | Traducción de '¿Cuántos años tienes?' solo acepta 'how old are you'. Falta la variante nat | ✅ arreglado (mig 070) |
| P1 | tolerancia_insuficiente | _audit\A1_u03 | `c3400000` | Falta la forma natural y muy común con 'have got' para "Tengo una hermana". Un alumno la e | ✅ arreglado (mig 070) |
| P1 | tolerancia_insuficiente | _audit\A1_u03 | `c3100000` | Traducción de 'padre' acepta solo 'father'. 'dad' es una traducción legítima y frecuente e | ✅ arreglado (mig 070) |
| P1 | tolerancia_insuficiente | _audit\A1_u04 | `c4200000` | «Quiero agua.» en A1 admite naturalmente «I'd like water», muy común y enseñado en este mi | ✅ arreglado (mig 070) |
| P1 | tolerancia_insuficiente | _audit\A1_u04 | `c4300000` | «¿Me puede dar un té, por favor?» admite «May I have a tea» y «Can/Could I get a tea», igu | ✅ arreglado (mig 070) |
| P1 | tolerancia_insuficiente | _audit\A1_u04 | `c4400000` | «¿Cuánto cuesta?» también se dice «How much does it cost?» (ya está) y «What does it cost? | ✅ arreglado (mig 070) |
| P1 | tolerancia_insuficiente | _audit\A1_u05 | `c5200000` | «Hoy es lunes.» acepta «today is monday» y «it's monday today» pero no la traducción más n | ✅ arreglado (mig 070) |
| P1 | tolerancia_insuficiente | _audit\A1_u05 | `c5400000` | «Yo trabajo todos los días.» solo acepta «i work every day» y «i work everyday»; falta una | ✅ arreglado (mig 070) |
| P1 | tolerancia_insuficiente | _audit\A2_u07 | `c2000021` | "Comi pizza." en ingles natural admite el cuantificador "some"; el grader no lo agrega por | ✅ arreglado (mig 070) |
| P1 | tolerancia_insuficiente | _audit\A2_u07 | `c2000029` | "¿Viste la pelicula?" se traduce igual de bien con "film" (ingles general/britanico, valid | ✅ arreglado (mig 070) |
| P1 | tolerancia_insuficiente | _audit\A2_u08 | `c2000053` | "tomar un café" admite varios verbos naturales en inglés que un A2 LATAM produciría; falta | ✅ arreglado (mig 070) |
| P1 | tolerancia_insuficiente | _audit\A2_u08 | `c2000061` | Respuesta única; un alumno puede escribir la forma con sujeto explícito, igualmente correc | ✅ arreglado (mig 070) |
| P1 | tolerancia_insuficiente | _audit\A2_u09 | `c2000069` | Traducción natural y común de "a las ocho" como "at eight o'clock" no está aceptada; el gr | ✅ arreglado (mig 070) |
| P1 | tolerancia_insuficiente | _audit\A2_u09 | `c2000085` | "baggage" es sinónimo válido de "luggage" en inglés (común en aeropuertos LATAM: baggage c | ✅ arreglado (mig 070) |
| P1 | tolerancia_insuficiente | _audit\A2_u09 | `c2000093` | Variantes naturales con "please" no aceptadas para "¿Podrías ayudarme?". | ✅ arreglado (mig 070) |
| P1 | tolerancia_insuficiente | _audit\A2_u10 | `c2000101` | "La cuenta, por favor." — falta la forma sin articulo (Check/Bill please), muy frecuente y | ✅ arreglado (mig 070) |
| P1 | tolerancia_insuficiente | _audit\A2_u10 | `c2000117` | "¿Cuánto cuesta?" admite la forma con 'this/that', muy comun al senalar un articulo en una | ✅ arreglado (mig 070) |
| P1 | tolerancia_insuficiente | _audit\A2_u10 | `c2000109` | "Quiero una botella de agua." — 'I'll have...' es respuesta natural y comun al pedir; no e | ✅ arreglado (mig 070) |
| P1 | tolerancia_insuficiente | _audit\A2_u12 | `c2000180` | El hueco "I have ___ seen that movie." admite naturalmente 'never' ("I have never seen tha | ✅ arreglado (mig 070) |
| P1 | tolerancia_insuficiente | _audit\A2_u12 | `c2000172` | El hueco "You ___ rest and sleep more." acepta solo 'should', pero 'must' es una respuesta | ✅ arreglado (mig 070) |
| P2 | cefr_misalign | _audit\A1_u05 | `c5400000` | En A1 LATAM «tarde» cubre afternoon y evening; los glosses «afternoon=tarde» y «evening=ta | ✅ arreglado (mig 070) |
| P2 | cefr_misalign | _audit\A2_u11 | `c2000155` | Pregunta metalingüística confusa: la opción correcta 'muchas cosas' es imprecisa (el super | ⏭️ diferido |
| P2 | instruccion_ambigua | _audit\A2_u11 | `c2000148` | La pista '(cook)' está en inglés y no indica que se espera la forma -ing del present conti | ✅ arreglado (mig 070) |
| P2 | no_natural | _audit\A2_u09 | `c2000068` | El cloze acepta "train" y "bus" en "I need a ___ to Madrid", pero "I need a train/bus to M | ↩️ rechazado |
| P2 | skill_mal | _audit\A1_u04 | `c4400000` | Cloze «How ___ is it?» (much) etiquetado skill=writing, pero es reconocimiento de vocabula | ↩️ rechazado |

## Verificación
- Validador determinista (content_qa) = **0** en es→en y es→pt.
- Cliente real: `grade_item` acepta las nuevas variantes (I'm Carlos, what's your age, I'd like
  some water, Where's my baggage, never, Check please…) y sigue rechazando lo erróneo; `correct_answer` 42501.
- analyze 0 · tests verdes (+ del grader) · `gh run list` SUCCESS · deploy READY.
