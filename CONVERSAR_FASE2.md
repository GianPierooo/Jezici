# Jezici — CONVERSAR (Fase 2): investigación + plan de diseño

> **Documento de diseño, NO código.** Define uno de los pilares del producto: la capa de
> conversación humana (el "ADN Tandem", el hito de la app). Escrito tras censar la BD/código
> reales (2026-07-10). Fuente: `Jezici_Especificacion.md §7/§9`, `Jezici_Analisis_Competencia.md`,
> `Jezici_Arquitectura_Tecnica.md §9`, `Jezici_Modelo_Datos.md §11`, `Jezici_Modelo_Negocio.md`,
> `docs/SECURITY.md`, `conversar_screen.dart`, e introspección directa de Postgres.
>
> **Tesis:** Conversar es el diferenciador, pero también el mayor riesgo legal/operativo de la app.
> La única forma responsable de construirlo es **por OLAS de riesgo creciente**, con la **seguridad
> de menores como compuerta** de cada una — no como parche posterior. Empezamos por lo **asíncrono y
> cerrado** (sin desconocidos, sin audio), y el audio en vivo con desconocidos + el marketplace de
> tutores llegan al final, detrás de verificación de edad fuerte y moderación real.

---

## 0. PASO 0 — Estado REAL (censo, no supuestos)

### 0.1 Qué existe en la BD (introspección directa)
Las 8 tablas del modelo social **ya existen** — pero son **stubs de esquema vacíos**: RLS ON,
mayormente **solo política SELECT** (sin ruta de escritura), **0 filas**, sin RPCs que las operen.

| Tabla | Filas | RLS | Políticas | Estado real |
|---|---|---|---|---|
| `social_profiles` | 0 | ON | 1 (SELECT own) | stub — `interests[]`, `is_verified`, `online_status`, `last_seen_at` |
| `connections` | 0 | ON | 1 (SELECT member) | stub — `user_a_id`, `user_b_id`, `status`(pending/accepted/blocked) |
| `conversation_rooms` | 0 | ON | 1 (SELECT) | stub — `topic`, `cefr_level`, `host_user_id`, `status`(open/live/closed) |
| `room_participants` | 0 | ON | 1 (SELECT own) | stub — `room_id`, `user_id`, `joined_at`, `left_at` |
| `coop_challenges` | 0 | ON | 1 (SELECT member) | stub — `user_a/b`, `goal` jsonb, `progress`, `status` |
| `conversation_challenges` | 0 | ON | 1 (SELECT own) | stub — `topic`, `prompt`, `recording_url`, `transcript`, `score`, `creativity_points` |
| `reports` | 0 | ON | 1 (SELECT own) | stub mínimo — `reporter_id`, `reported_id`, `reason` (sin estado/contexto/resolución) |
| `conversation_attempts` | 1 | ON | 1 (ALL own) | **VIVO** — práctica en solitario (`topic`, `mode`, `content`, `self_score`) |
| `subscriptions` | — | ON | — | existe; pagos **inactivos** (beta) |

**No existen:** `blocks`, `mutes`, `moderation_actions`, `messages`, `corrections`, `tutor_*`,
`age_verifications`, `consents`, `room_bans`, `friend_codes`.

**RPCs sociales que existen:** solo `log_conversar_interest` (waitlist) y `save_conversation_attempt`
(guarda la práctica en solitario). **No hay** lógica de amistad, chat, salas, moderación ni tutores.

### 0.2 Qué hace el cliente HOY (`conversar_screen.dart`, 813 líneas)
- **Práctica en solitario asíncrona**: 6 situaciones (café/intro/aeropuerto/finde/entrevista/
  direcciones) → el usuario escribe o habla → ve una **respuesta modelo** + frases clave + se
  **autoevalúa**. Contenido por idioma del curso (`ConvModel`), chrome i18n es/en/pt.
- **Banner honesto "en vivo · próximamente"** (Fase 2) — sin contador falso de gente en línea.
- **Captura de interés** (waitlist) → `log_conversar_interest`.
- **NO existe** ningún flujo social real (ni amigos, ni chat, ni salas).

### 0.3 Realidad de edad / verificación (crítico para todo lo social)
- Solo hay `users.is_adult` (**checkbox** autodeclarado) + `birthday_day`/`birthday_month`
  (**sin año** → por diseño de minimización de datos **no se puede calcular ni verificar la edad**).
- Legal (`privacy.html`/`terms.html`) = **borrador**, no revisado por abogado, sin cláusulas de
  contenido social/menores/UGC.
- Seguridad general sólida para el loop actual (RLS en todo, RPCs con `auth.uid()`, admin gate),
  pero **cero infraestructura de moderación** (reportes es un stub, no hay block/mute/suspend/cola).

### 0.4 Conclusión del censo
El esquema social fue **previsto** pero nunca construido. La app tiene los cimientos correctos
(Postgres+RLS+Realtime+Storage) pero le falta **todo**: rutas de escritura, lógica, moderación,
verificación de edad real, stack de audio, marketplace y — sobre todo — el **marco de seguridad de
menores** sin el cual **nada social debe abrirse**.

---

## 1. Principios de diseño (las reglas que ordenan todo)

1. **Seguridad de menores primero, y como COMPUERTA.** Ninguna ola se abre sin su capa de seguridad
   correspondiente lista y verificada. No se "añade moderación después".
2. **Asíncrono antes que tiempo real.** Lo async (chat, notas de voz, corrección) es **mucho** más
   seguro, barato y moderable que el audio en vivo. Se construye y madura primero.
3. **Cerrado antes que abierto.** Empezar por **amigos por consentimiento mutuo** (sin descubrir
   desconocidos). Los desconocidos + el audio en vivo son las **últimas** olas.
4. **Estructura primero — que NUNCA se sienta app de citas** (el error de Tandem). Conversar se
   ancla siempre a un **artefacto de aprendizaje**: tu nivel, tu curso, una **situación/escenario**
   de tus lecciones, una **meta compartida**. No "conoce gente"; "haz una tarea con alguien".
5. **Verificar a los correctores/tutores** (el error de Busuu). Quien corrige o enseña debe estar
   **verificado** (certificado del nivel, o KYC de identidad para tutores de pago).
6. **La IA arranca la conversación** (resuelve liquidez + seguridad): un compañero de práctica IA
   permite conversar sin humano y sin riesgo, y "calienta" la superficie antes de meter personas.
7. **Detrás del muro (premium) lo caro y lo social avanzado.** Lo determinista/gratis es Fase 1; voz,
   IA, tutores y salas son premium (sostenible: los costos altos van tras el paywall).
8. **Todo se registra para abuso e IA** (gancho de Fase 2): grabaciones, transcripciones y textos se
   guardan con consentimiento y retención acotada, para moderación e (después) evaluación con IA.

---

## 2. Catálogo de FORMAS de Conversar

Para cada forma: **qué es · valor · esfuerzo · riesgo · async/RT · requiere**. El esfuerzo es
S/M/L/XL. El riesgo es de seguridad (no técnico).

### A. Chat con amigos (asíncrono, cerrado) — *la base social más segura*
- **A1 · Amigos por código/QR (descubrimiento seguro).** Añades a alguien **solo** por un código
  corto o QR que esa persona te comparte (no hay buscador de desconocidos). Aceptar/rechazar/bloquear.
  *Valor:* red social sin exponerse a desconocidos. *Esfuerzo:* S. *Riesgo:* **bajo** (consentimiento
  mutuo). *Async.* *Requiere:* solo Supabase (`connections`, `friend_codes`).
- **A2 · Chat de texto 1:1 entre amigos.** Mensajería entre conexiones aceptadas. *Valor:* practicar
  el idioma escribiendo con un compañero real. *Esfuerzo:* M. *Riesgo:* bajo-medio (texto es
  moderable por filtros). *Async (Realtime).* *Requiere:* Supabase Realtime + tabla `messages`.
- **A3 · Notas de voz.** Enviar audio corto (≤30–60 s) grabado. *Valor:* speaking real sin presión de
  tiempo real; "postales de voz" diarias. *Esfuerzo:* M. *Riesgo:* medio (audio **no** es auto-
  moderable sin IA → limitar a **amigos aceptados**, retención para reporte). *Async.* *Requiere:*
  Storage + `messages(kind=voice)`.
- **A4 · Corrección entre pares (amigos).** Un amigo marca y corrige tu mensaje/nota/attempt; ves la
  versión corregida + nota. *Valor:* feedback humano gratis. *Esfuerzo:* M. *Riesgo:* bajo. *Async.*
- **A5 · Rachas con amigos + compañero de responsabilidad.** Racha compartida que se mantiene si
  **ambos** practican; "accountability partner" con recordatorios. *Valor:* retención (el gancho #1 de
  Duolingo Friends). *Esfuerzo:* M. *Riesgo:* bajo. *Async.* *Requiere:* `connections` + lógica de racha.
- **A6 · Retos en pareja (co-op).** Dos usuarios reman a una **meta compartida** (X lecciones/XP esta
  semana). Ya hay tabla `coop_challenges`. *Valor:* colaboración > competición (encaja mejor en
  idiomas). *Esfuerzo:* M. *Riesgo:* bajo. *Async.*

### B. Corrección comunitaria verificada (asíncrona) — *el "arreglo del error de Busuu"*
- **B1 · Mercado de correcciones.** Publicas un texto/nota; **correctores verificados** (usuarios con
  **certificado** de ese nivel o superior, o nativos verificados) lo corrigen; ganan **XP/oro/
  reputación**. *Valor:* feedback de calidad a escala, sin tutores de pago. *Esfuerzo:* L. *Riesgo:*
  medio (desconocidos, pero **async y sin audio/privado**; el contenido es una tarea, no un chat).
  *Async.* *Requiere:* `corrections` + gate de verificación + economía de reputación.
- **B2 · Reputación/confianza.** Puntaje que gobierna privilegios (quién puede corregir, hostear
  salas, etc.); palanca anti-abuso central. *Esfuerzo:* M. *Riesgo:* bajo (protege).

### C. Salas de conversación en vivo (tiempo real, audio) — *alto riesgo*
- **C1 · Salas grupales por tema/nivel** (audio, 3–8 personas, host). Ya hay `conversation_rooms`.
  *Valor:* el "hito" — hablar de verdad. *Esfuerzo:* XL. *Riesgo:* **alto** (desconocidos + audio en
  vivo). *RT.* *Requiere:* SFU de audio (LiveKit/Agora) + moderación + **adultos-verificados** + consentimiento
  de grabación.
- **C2 · Emparejamiento 1:1 en vivo.** Match por idioma/nivel/intereses para una charla corta. *Valor:*
  intercambio Tandem clásico. *Esfuerzo:* L (sobre C1). *Riesgo:* **muy alto** (1:1 privado con
  desconocido). *RT.* — se abre **después** de las salas grupales (más seguras por ser públicas/moderadas).
- **C3 · Retos en pareja EN VIVO.** Co-op con una mini-tarea hablada cronometrada. *Esfuerzo:* M sobre
  C1. *Riesgo:* alto. *RT.*
- **C4 · "Office hours" / eventos moderados.** Sala en vivo **con un host responsable** (tutor o
  moderador). Más segura que la sala abierta (hay alguien a cargo). *Esfuerzo:* M sobre C1. *Riesgo:*
  medio-alto (mitigado por el host). *RT.*

### D. Retos de conversación por tema — *el diferenciador original (puntos por creatividad)*
- **D1 · Reto del día (async, guardado).** Tema asignado → grabas respuesta → se **guarda**
  (`conversation_challenges.recording_url`/`transcript`). *Valor:* hábito creativo. *Esfuerzo:* S
  (guardar) / la **puntuación** es lo caro. *Riesgo:* bajo (async, sin contacto). *Async.*
- **D2 · Puntuación por creatividad (IA).** STT → transcript → IA evalúa relevancia/gramática/vocab/
  **creatividad** → puntos. *Valor:* el diferenciador. *Esfuerzo:* L. *Riesgo:* bajo (sin humanos).
  *Requiere:* STT + LLM (**IA = detrás del muro**).
- **D3 · Puntuación por pares (puente sin IA).** Mientras no hay IA, los **correctores verificados**
  puntúan los retos (reusa B1). *Esfuerzo:* M. *Riesgo:* bajo.

### E. Tutores / profesores (marketplace) — *máximo riesgo y esfuerzo*
- **E1 · Tutores nativos VERIFICADOS de pago (marketplace tipo iTalki/Preply).** Perfil + video +
  disponibilidad; el alumno **reserva y paga** una sesión 1:1 (audio); la plataforma cobra
  **comisión** (~15–25%). *Valor:* ingreso + el mayor salto de aprendizaje. *Esfuerzo:* XL. *Riesgo:*
  **el más alto** (dinero + identidad + 1:1 + posible menor). *RT + pagos.* *Requiere:* Stripe Connect
  (pagos/comisión) + Stripe Identity/KYC (verificar al tutor) + LiveKit (audio) + agenda + legal de
  marketplace.
- **E2 · Tutores voluntarios/comunitarios (sin dinero).** Nativos verificados que enseñan por
  **reputación/insignias** (no dinero) → arranca liquidez sin fricción de pagos/impuestos. *Esfuerzo:*
  L. *Riesgo:* alto (1:1 con desconocido) — mismas mitigaciones que E1 salvo pagos.
- **E3 · Clases grupales / "office hours" de tutor.** Un tutor hostea una sala pequeña de pago o
  gratis (reusa C4). *Valor:* más barato para el alumno, más escalable para el tutor. *Esfuerzo:* M
  sobre E1+C1. *Riesgo:* medio-alto (grupo + host responsable).
- **Verificación del tutor (no repetir Busuu):** KYC de identidad (Stripe Identity/Persona) +
  prueba de nativo/nivel (autodeclarado + revisión + reseñas) + video de intro + reseñas verificadas
  post-sesión. Sin verificar = no puede cobrar ni aparecer.

### F. Ideas adicionales (no pedidas, pero encajan) — *propuestas propias*
- **F1 · Compañero IA de práctica (roleplay).** Chatbot que interpreta el escenario ("eres el
  camarero"). *Resuelve liquidez + seguridad de golpe* (sin humano). *Esfuerzo:* L. *Riesgo:* **muy
  bajo**. *Requiere:* LLM (IA, premium). **Recomendado como primer "en vivo" real** — cero riesgo social.
- **F2 · Cápsulas/cohortes cerradas** (5–8 al mismo nivel, progresan juntas con retos async
  semanales). Comunidad **sin exponerte a desconocidos a escala**; más segura que la sala abierta.
  *Esfuerzo:* L. *Riesgo:* medio-bajo.
- **F3 · Shadowing / pronunciación async.** Repites un clip nativo; par o IA da feedback de
  pronunciación. *Esfuerzo:* M. *Riesgo:* bajo. *Async.*
- **F4 · Co-escritura / diálogo colaborativo** (dos usuarios construyen una historia por turnos).
  *Creativo, async, bajo riesgo.* *Esfuerzo:* M.
- **F5 · "Postales de voz" del día** (nota de voz de 20 s sobre un prompt, a un amigo). Alta
  retención, bajo riesgo. *Esfuerzo:* S (sobre A3).
- **F6 · Eventos/"parties" temáticos moderados** (Tandem parties, pero programados + moderados +
  adultos). *Esfuerzo:* M sobre C1. *Riesgo:* alto (mitigado por programación + host).
- **F7 · Apuesta de compromiso con un amigo** (staking de oro sobre una racha compartida; reusa
  `wagers`). *Esfuerzo:* S. *Riesgo:* bajo.
- **F8 · Reputación/nivel de confianza que desbloquea privilegios** (hostear, corregir, 1:1). Palanca
  anti-abuso y de calidad. *Esfuerzo:* M. *Riesgo:* bajo (protege).

---

## 3. Tabla maestra de funciones

| # | Función | Valor | Esf. | Riesgo | Async/RT | Requiere (además de Supabase) |
|---|---|---|---|---|---|---|
| A1 | Amigos por código/QR | Alto | S | Bajo | Async | — |
| A2 | Chat de texto 1:1 | Alto | M | Bajo-Med | Async(RT) | Realtime |
| A3 | Notas de voz | Alto | M | Medio | Async | Storage |
| A4 | Corrección entre amigos | Alto | M | Bajo | Async | — |
| A5 | Rachas con amigos / accountability | **Muy alto** (retención) | M | Bajo | Async | — |
| A6 | Retos en pareja (co-op) | Alto | M | Bajo | Async | — |
| B1 | Corrección comunitaria verificada | Alto | L | Medio | Async | gate cert + reputación |
| B2 | Reputación/confianza | Medio (protege) | M | — | — | — |
| C1 | Salas de audio grupales | **El hito** | XL | **Alto** | RT | **LiveKit/Agora** + moderación + edad |
| C2 | Emparejamiento 1:1 en vivo | Alto | L | **Muy alto** | RT | idem C1 |
| C3 | Retos en pareja en vivo | Medio | M | Alto | RT | idem C1 |
| C4 | Office hours / sala con host | Alto | M | Med-Alto | RT | idem C1 |
| D1 | Reto del día (guardado) | Medio | S | Bajo | Async | Storage |
| D2 | Puntuación por creatividad (IA) | **Diferenciador** | L | Bajo | — | **STT + LLM** |
| D3 | Puntuación por pares | Medio | M | Bajo | Async | reusa B1 |
| E1 | Marketplace tutores de pago | **Ingreso** | XL | **Máximo** | RT+pagos | **Stripe Connect + Identity** + LiveKit + legal |
| E2 | Tutores voluntarios | Alto | L | Alto | RT | LiveKit + KYC |
| E3 | Clases grupales de tutor | Alto | M | Med-Alto | RT | E1+C1 |
| F1 | Compañero IA (roleplay) | Alto | L | **Muy bajo** | RT-lite | **LLM** |
| F2 | Cápsulas/cohortes | Alto | L | Med-Bajo | Async | — |
| F3 | Shadowing/pronunciación | Medio | M | Bajo | Async | (STT opcional) |
| F4 | Co-escritura | Medio | M | Bajo | Async | Realtime |
| F5 | Postales de voz | Alto | S | Bajo | Async | Storage |
| F6 | Eventos/parties moderados | Alto | M | Alto | RT | C1 |
| F7 | Apuesta con amigo | Medio | S | Bajo | Async | reusa wagers |
| F8 | Reputación/privilegios | Medio (protege) | M | — | — | — |

---

## 4. OLAS (orden por riesgo/esfuerzo creciente)

> Cada ola **exige** su capa de seguridad (§5) LISTA antes de abrir. Se lanza una ola, se estabiliza,
> se mide, y solo entonces la siguiente.

### Ola 0 — Práctica en solitario (✅ YA en producción)
Async, sin personas, cero riesgo. Base actual (topic → escribe/habla → modelo + autoevaluación).
**Mejora de puente sin coste social:** activar **D1** (guardar el reto del día en
`conversation_challenges`) para acumular el corpus que evaluará la IA después.

### Ola 1 — Social ASÍNCRONO CERRADO (bajo riesgo, sin desconocidos) — *primer lanzamiento social*
**A1 amigos por código + A2 chat texto + A3 notas de voz + A4 corrección + A5 rachas/accountability +
A6 co-op + F5 postales de voz + F7 apuesta con amigo.**
- **Por qué primero:** consentimiento mutuo (sin buscador de desconocidos), sin audio en vivo, todo
  moderable/retenible; entrega el gancho de **retención** (rachas con amigos) que es el mayor ROI.
- **Seguridad mínima:** edad real (año de nacimiento) + tiers; **block/report/mute** + rate limits +
  filtro de palabras + **stripping de datos de contacto** (teléfono/email/@ para menores) + **sin
  imágenes** + retención para reporte. Adultos y adolescentes permitidos **solo con amigos aceptados**.
- **Stack:** **solo Supabase** (Realtime + Storage). **Bloqueado en:** nada técnico externo; sí
  requiere **legal actualizado** (UGC/menores) antes de abrir a público.

### Ola 2 — Corrección comunitaria + Compañero IA (async/medio) — *diferenciador sin humanos-en-vivo*
**B1 corrección verificada + B2 reputación + F1 compañero IA (roleplay) + D3 puntuación por pares +
F2 cápsulas + F3 shadowing + F4 co-escritura.**
- **Por qué:** sube la calidad (feedback humano verificado) y mete el primer "conversar" real y
  seguro (IA, sin persona). F1 es el mejor riesgo/beneficio de todo el documento.
- **Seguridad:** correctores gated por **certificado** (verificación real); IA sin datos de menor a
  terceros sin consentimiento; cápsulas = grupos cerrados moderados.
- **Stack:** Supabase + **LLM** (para F1/D2) → **cuenta de proveedor IA** (premium). **Bloqueado en:**
  decisión de proveedor IA + presupuesto.

### Ola 3 — Salas de audio EN VIVO (alto riesgo, tiempo real) — *el hito, adultos-only al inicio*
**C1 salas grupales + C4 office hours + C3 retos en vivo + F6 parties**, y **después** C2 (1:1).
- **Por qué al final del bloque social:** audio en vivo con desconocidos es el riesgo máximo (grooming/
  abuso/CSAM no auto-moderable). Se abre **solo 18+ verificados**, salas **públicas + moderadas + con
  host + grabadas (con consentimiento) + cola de moderación**. 1:1 privado (C2) va **después** de las
  grupales.
- **Stack:** **LiveKit Cloud** (SFU de audio + egress/grabación) + Supabase (metadatos/señalización/
  moderación). **Bloqueado en:** cuenta LiveKit + **verificación de edad fuerte** + **staff de
  moderación** (humano) + legal reforzado.

### Ola 4 — Marketplace de tutores (máximo riesgo/esfuerzo) — *ingreso*
**E2 voluntarios (bootstrap) → E1 de pago → E3 clases grupales.**
- **Seguridad/legal:** KYC del tutor (Stripe Identity) + contrato de contratista + reseñas + poder de
  expulsión; **adultos-only tutor↔alumno-desconocido** al inicio (o menor solo con tutor verificado +
  consentimiento parental + grabado + sin contacto privado). Comisión de plataforma.
- **Stack:** **Stripe Connect** (pagos/payout/comisión) + **Stripe Identity** (KYC) + LiveKit (reusa) +
  agenda. **Bloqueado en:** cuenta Stripe + Connect + Identity + **legal de marketplace** (ToS tutor,
  impuestos/1099, responsabilidad) + moderación.

### Ola 5 — Puntuación por creatividad con IA (D2) — *cierra el diferenciador original*
STT + LLM puntúan los retos guardados desde la Ola 0/1. **Bloqueado en:** STT (Deepgram/Whisper) + LLM
+ presupuesto. Premium.

---

## 5. SEGURIDAD Y MENORES (transversal — la condición para lanzar CUALQUIER cosa social)

> Esta es la sección más importante. **Sin esto, no se abre nada social.** El riesgo dominante es
> **contacto adulto↔menor** (grooming/CSAM) en audio/privado: es responsabilidad legal y moral máxima.

### 5.1 Verificación de edad — el checkbox actual NO basta
**Realidad:** hoy solo `is_adult` (checkbox) + día/mes sin año → **no se puede saber la edad**. Es
insuficiente para chat/audio con desconocidos y para tutores.
- **Mínimo indispensable (Ola 1):** **age gate neutral** — pedir **fecha de nacimiento con año**
  (pantalla neutral, no "¿eres mayor?"). Derivar **tier**: `child` (<13), `teen` (13–17), `adult`
  (18+). (Tensión con minimización de datos: guardar solo el **año** o el tier, no la fecha completa,
  si el abogado lo permite; la seguridad de menores pesa más que la minimización aquí.)
- **<13 → excluido** de cuenta social (COPPA: no recolectar datos de <13 sin consentimiento parental
  verificable → lo simple y seguro es **no permitir <13** en features sociales, o exigir flujo parental).
- **13–17 (teen) → tier restringido:** SIN salas abiertas, SIN desconocidos, SIN audio con
  desconocidos, SIN tutores-con-desconocidos; **solo** amigos por consentimiento mutuo + compañero IA +
  cápsulas del **mismo tier**. Defaults de máxima privacidad (Children's Code): perfil no descubrible,
  sin geolocalización, sin datos de contacto.
- **18+ → completo**, pero para **audio en vivo con desconocidos + tutores** exigir **verificación de
  edad fuerte** (no solo autodeclarada): estimación/verificación por **Yoti / Persona / Veriff / Stripe
  Identity / k-ID**. Coste + fricción → solo en las olas de alto riesgo.
- **Contacto adulto↔menor:** **prohibido por defecto** en privado/audio. Un adulto no verificado no
  puede iniciar contacto con un teen; un teen no aparece en descubrimiento para adultos. En tutores
  con menores (si algún día): solo tutor **verificado** + **consentimiento parental** + **grabado** +
  **sin canal privado**.

### 5.2 Moderación — qué es automatizable SIN IA
- **Block / mute / report** (usuario→usuario) con efecto **server-side vía RLS** (un bloqueado no ve ni
  contacta al que lo bloqueó, en ninguna superficie).
- **Rate limits / throttles**: nº de mensajes/min, nº de solicitudes de amistad/día, nº de salas
  creadas/día, nº de reportes/día (anti-spam y anti-acoso). Todo en RPC/Postgres.
- **Filtro de palabras/patrones** (blocklist): auto-ocultar + marcar mensajes con términos prohibidos;
  **stripping de datos de contacto** (teléfono/email/@handles/URLs) — especialmente para menores (evita
  sacar la conversación de la plataforma).
- **Umbral de reportes → acción automática**: N reportes en T → **auto-shadow-suspend** pendiente de
  revisión humana (fail-safe, reversible).
- **Cola de moderación** (dashboard admin): reportes con **contexto** (mensaje/sala/sesión), estado
  (abierto/en revisión/resuelto), acciones (warn/suspend/ban temporal/permanente), auditoría.
- **Host de sala**: puede silenciar/expulsar; expulsión → **ban server-side** de esa sala.
- **Lo que NO es auto-moderable sin IA** (y por eso se limita/retrasa): **imágenes** (→ **no permitir
  fotos** al inicio) y **audio** (→ audio solo entre amigos aceptados en Ola 1; audio con desconocidos
  solo en Ola 3 con **grabación + retención + cola humana**). Moderación de imagen/audio con IA
  (Hive/Sightengine) = Fase 2+.

### 5.3 Grabación, consentimiento y retención
- **Consentimiento explícito** antes de cualquier sesión grabada (banner "esta sala se graba para
  seguridad"; guardar `consents`). Consideración de consentimiento de **dos partes** (jurisdicciones).
- **Retención acotada para abuso**: mensajes/notas/grabaciones se **retienen N días** (p.ej. 90) para
  investigación de reportes, luego se purgan. Documentado en privacidad. Balance con **minimización**.
- **Purga y derechos**: reusar `export_my_data` / `delete_account` ya existentes (extender a lo social).

### 5.4 RLS de toda tabla nueva (obligatorio)
Cada tabla nueva: **RLS ON**, políticas que escopen a **participantes/propietario**, **bloqueos
aplicados en la propia RLS** (no solo en cliente), y override de admin vía `jz_is_admin()`. Escrituras
**solo por RPC `SECURITY DEFINER`** con `auth.uid()` (patrón ya usado en toda la app). Nada de
`using(true)` en tablas sociales.

### 5.5 Anti-acoso / anti-spam
- Solicitudes de amistad solo por **código** (no masivas); límite diario.
- No descubrimiento de desconocidos hasta Ola 3 (y ahí, solo en salas públicas moderadas, no perfiles
  privados navegables).
- "Silenciar" y "salir" siempre a un toque; botón de pánico/reportar en toda sala.
- Reputación (F8) gobierna privilegios (hostear/corregir/1:1) → los abusadores pierden capacidades.

### 5.6 Riesgos LEGALES (menores + desconocidos + audio + tutores) y mitigación mínima
| Riesgo | Marco | Mitigación mínima ANTES de abrir |
|---|---|---|
| Datos de <13 | **COPPA** (US) | Excluir <13 del social (o flujo de consentimiento parental verificable) |
| Consentimiento digital de menores | **GDPR-K** (13–16 según país) | Age gate + defaults privados + sin perfilado de menores |
| Diseño para menores | **UK Children's Code (AADC)** | Máxima privacidad por defecto <18, no geolocalización, no descubrible |
| Contenido ilícito / notice-action | **EU DSA** | Reporte + retirada + registro de decisiones + protección de menores |
| Ads a menores | **DSA** | Prohibir ads dirigidos a menores |
| **Grooming/CSAM** en audio/privado adulto↔menor | Penal (global) | **Sin contacto privado adulto↔menor**; menores fuera de salas/1:1/tutores-desconocidos; grabación+retención+reporte a autoridades |
| Grabación sin consentimiento | Consentimiento de 2 partes | Banner + `consents` antes de grabar |
| Marketplace: tutor como contratista, impuestos, responsabilidad | Laboral/fiscal/civil | ToS de tutor + KYC + Stripe maneja 1099-K + poder de expulsión + seguro/limitación de responsabilidad |
| Retención vs minimización | GDPR | Ventana de retención definida y documentada + purga |

**Compuerta de lanzamiento (checklist mínimo para abrir la Ola 1):** (1) age gate real (año) + tiers;
(2) ToS/privacidad **revisados por abogado** para UGC/menores/social; (3) block/report/mute + cola de
moderación **vivos**; (4) rate limits + filtro de contacto; (5) sin imágenes; (6) adultos+teens **solo
con amigos aceptados**; (7) proceso de respuesta a incidentes; (8) export/delete extendidos a lo social.
**Para la Ola 3 (audio con desconocidos)** añadir: verificación de edad fuerte + **18+ only** + grabación/
retención + **staff de moderación humano** + reforzar legal. **Para la Ola 4 (tutores)**: KYC + legal de
marketplace + pagos.

---

## 6. STACK — tiempo real, chat, voz, pagos, verificación

### 6.1 Chat + presencia (async) → **Supabase Realtime** (ya lo tenemos)
- Texto, notas de voz (Storage), typing/online (Presence), cambios en `messages` por Postgres Changes/
  Broadcast. **Coste ≈ 0 marginal** (incluido en Supabase). RLS nativa. **Sin proveedor nuevo.** Ideal
  para Olas 1–2. **Recomendado.**

### 6.2 Audio en vivo (SFU/WebRTC) → comparación
| Proveedor | Pros | Contras | Coste (audio) | Flutter |
|---|---|---|---|---|
| **LiveKit** (Cloud u **open-source self-host**) | OSS (escape hatch), egress/grabación para moderación, tokens, buen SDK, tier dev gratis | operar self-host tiene curva | ~$ por participante-min, competitivo; self-host = solo tu VPS | **SDK oficial bueno** |
| **Agora** | maduro, escala, features | pricing por participante-min sube; origen que algunos evitan | pago por uso | SDK oficial |
| **Daily** | API simple, buenos docs | menos control | por minuto | SDK/community |
| **100ms** | producto de "rooms" listo | menos OSS | por minuto | SDK |
| **Twilio** | enterprise | caro | alto | SDK |
**Recomendación:** **LiveKit Cloud** para las salas (mejor combinación OSS + Flutter + **egress para
grabación/moderación** + salida a self-host si el coste crece). **Agora** como alternativa. Solo entra
en la **Ola 3** → **cuenta de Gian pendiente**.

### 6.3 STT (para D2/F3, scored) → **Deepgram** (barato, streaming) o **Whisper** (self/OpenAI) o AssemblyAI.
Solo en Ola 5. **Cuenta pendiente.**

### 6.4 IA conversacional (F1) y puntuación (D2) → **LLM** (proveedor a decidir).
Detrás del muro. **Cuenta/presupuesto pendiente.**

### 6.5 Pagos + KYC (tutores) → **Stripe Connect** (marketplace/payout/comisión) + **Stripe Identity** (KYC).
Solo Ola 4. **Cuenta Stripe + Connect + Identity pendientes.**

### 6.6 Verificación de edad fuerte (Ola 3/4) → **Yoti / Persona / Veriff / Stripe Identity / k-ID**.
Solo cuando entren desconocidos/audio/tutores. **Cuenta pendiente.**

### 6.7 Push (notificaciones de chat) → **FCM/APNs** (ya planeado en el motor Matix).

**Resumen de cuentas de pago que Gian debe crear (por ola):**
- Ola 1–2: **ninguna nueva** (salvo proveedor **LLM** para F1/IA). Legal (abogado) sí.
- Ola 3: **LiveKit Cloud** + verificación de edad + (moderación humana).
- Ola 4: **Stripe (Connect + Identity)** + legal de marketplace.
- Ola 5: **STT (Deepgram)** + **LLM**.

---

## 7. MODELO DE DATOS — qué añadir (sobre lo existente) + RLS

> Los stubs existentes se **completan** (columnas + RLS de escritura por RPC). Se añaden las tablas
> nuevas. **Toda** tabla: RLS ON, escritura solo por RPC `SECURITY DEFINER`, bloqueos aplicados en RLS.

### 7.1 Identidad / edad / consentimiento (transversal — primero)
- `users` += `birth_year` int (o `birth_date`) · `age_tier` enum(child/teen/adult) derivado ·
  `age_verified_at` · `age_verification_method`.
- **`age_verifications`** (nueva): `user_id`, `method`, `status`, `verified_at`, `provider_ref`
  (referencia opaca, **no** se guarda el documento). RLS: solo dueño + admin.
- **`consents`** (nueva): `user_id`, `kind`(recording/live_audio/social_tos), `granted_at`, `revoked_at`.

### 7.2 Amigos / chat (Ola 1)
- **`friend_codes`** (nueva) o `users.friend_code`: código corto único para añadir sin buscador.
- `connections` (completar): + `requested_by`, `accepted_at`, `blocked_at`; estados pending/accepted/
  blocked. RLS: solo los dos miembros; un `blocked` corta todo.
- **`messages`** (nueva): `id`, `thread_id`(=connection u otro), `sender_id`, `kind`(text/voice/
  correction/system), `body`, `audio_url`, `reply_to`, `created_at`, `edited_at`, `deleted_at`. RLS:
  solo miembros del thread **y** ninguno bloqueado. Escritura por RPC con rate limit + filtro.
- **`corrections`** (nueva): `id`, `target_message_id`/`target_attempt_id`, `corrector_id`, `original`,
  `corrected`, `note`, `created_at`. RLS: dueño del contenido + corrector; corrector gated por cert.
- **`blocks`** (nueva): `blocker_id`, `blocked_id`. **Se consulta en la RLS** de messages/connections/
  rooms/reports.
- **`mutes`** (nueva): `muter_id`, `muted_id` (soft).
- `coop_challenges` (completar): RPC de crear/aceptar/avanzar; RLS miembros.
- Rachas con amigos: derivar de actividad de ambos (sin tabla nueva o una `friend_streaks`).

### 7.3 Moderación (transversal — antes de cualquier apertura)
- `reports` (completar): + `context_type`(message/room/session/profile), `context_id`, `status`
  (open/reviewing/resolved), `resolution`, `handled_by`, `created_at`. RLS: reportante + admin.
- **`moderation_actions`** (nueva): `target_user_id`, `action`(warn/suspend/ban_temp/ban_perm),
  `reason`, `actor`(system/admin), `expires_at`, `created_at`. RLS: admin; el afectado ve su estado.
- **`room_bans`** (nueva): `room_id`(nullable=global), `user_id`, `by`, `reason`, `created_at`.

### 7.4 Salas de audio (Ola 3)
- `conversation_rooms` (completar): + `language_id`/`course_id`, `max_participants`, `min_age_tier`
  (default adult), `is_moderated`, `host_role`, `recording_url`, `scheduled_at`, `ended_at`.
- `room_participants` (completar): + `role`(host/speaker/listener), `muted_by_host`, `banned`.
- Emparejamiento 1:1: **`match_queue`** (nueva): `user_id`, `language`, `level`, `enqueued_at`,
  `matched_room_id`.

### 7.5 Retos de conversación (Ola 0/1/5)
- `conversation_challenges` (completar): ya tiene `recording_url`/`transcript`/`score`/
  `creativity_points`; + `scored_by`(ai/peer), `scorer_id`. RLS: dueño; correctores ven los que puntúan.

### 7.6 Tutores / marketplace (Ola 4)
- **`tutor_profiles`** (nueva): `user_id`, `bio`, `native_languages[]`, `teach_languages[]`,
  `hourly_rate`, `verified_status`, `stripe_account_id`, `intro_video_url`, `rating_avg`,
  `sessions_count`. RLS: público-lectura del verificado, escritura del dueño.
- **`tutor_availability`** (nueva): `tutor_id`, `slots` jsonb.
- **`tutor_sessions`** (nueva): `tutor_id`, `student_id`, `scheduled_at`, `status`, `price`,
  `stripe_payment_intent`, `room_id`, `recording_consent`, `min_age`(adult). RLS: las dos partes + admin.
- **`tutor_reviews`** (nueva): `session_id`, `rating`, `text`. RLS: autor + público del tutor.
- Pagos/payout: **Stripe Connect** (no tabla de dinero propia; referencias a Stripe).

### 7.7 Reputación (transversal)
- **`trust_scores`** (nueva) o columnas en `social_profiles`: `reputation`, `flags`, privilegios
  derivados (can_host, can_correct, can_1to1). Se recalcula por reportes/reseñas/actividad.

---

## 8. PLAN por fases (orden, esfuerzo, bloqueos)

| Fase | Contenido | Esfuerzo | Bloqueado en (Gian) |
|---|---|---|---|
| **P0 (ya)** | Práctica solo + activar D1 (guardar reto) | S | — |
| **P1 — Cimientos de seguridad** (pre-requisito de TODO) | age gate (año)+tiers · `blocks`/`mutes`/`moderation_actions`/`reports` completos · cola de moderación admin · rate limits · filtro de contacto · RLS de todas las tablas sociales · legal social/menores | L | **Abogado** (revisar ToS/privacidad social+menores) |
| **P2 — Ola 1 (social async cerrado)** | amigos por código · chat texto · notas de voz · corrección entre amigos · rachas/accountability · co-op · postales de voz | L | — (solo Supabase); depende de P1 |
| **P3 — Ola 2 (corrección + IA)** | correctores verificados + reputación · **compañero IA (F1)** · cápsulas · shadowing · co-escritura | L | **Proveedor LLM** + presupuesto |
| **P4 — Ola 3 (audio en vivo, 18+)** | salas grupales · office hours · retos en vivo · (luego 1:1) | XL | **LiveKit** + **verif. edad fuerte** + **moderación humana** + legal reforzado |
| **P5 — Ola 4 (tutores)** | voluntarios → de pago → clases grupales | XL | **Stripe Connect + Identity** + **legal de marketplace** |
| **P6 — Ola 5 (creatividad IA)** | D2 puntuación por creatividad | L | **STT + LLM** |

**Decisiones abiertas que necesita tomar Gian (definen el plan):**
1. **¿Se permiten menores (13–17) en la app social, o es 18+ global?** (Lo más simple/seguro para
   lanzar rápido: **18+ para todo lo social**; menores solo el loop de aprendizaje + IA. Si se
   permiten teens, hay que construir todo el tier restringido de §5.1.)
2. **Modelo de tutores:** ¿de pago (marketplace + comisión + Stripe + KYC + impuestos) o **voluntario/
   reputación** primero para bootstrapear? (Recomendado: voluntario primero.)
3. **Proveedor de tiempo real:** LiveKit (recomendado) vs Agora.
4. **¿Compañero IA (F1) antes que el audio humano?** (Recomendado **sí**: resuelve liquidez+seguridad
   y es el "conversar en vivo" de menor riesgo.)
5. **Presupuesto** para IA/STT/audio/verificación de edad (define qué olas son viables y cuándo).

---

## 9. Recomendación (síntesis)

1. **Construir P1 (cimientos de seguridad) sí o sí primero** — es el trabajo invisible que habilita
   todo y protege el negocio. Sin esto, no se abre nada.
2. **Lanzar la Ola 1 (social async cerrado)** — máximo retorno de retención (rachas con amigos) con el
   **menor riesgo** (sin desconocidos, sin audio). Solo Supabase.
3. **Meter el Compañero IA (F1) como primer "conversar en vivo"** — riesgo social casi nulo, resuelve
   liquidez, y es un gran gancho premium.
4. **El audio humano en vivo (Ola 3) y los tutores (Ola 4) son el hito, pero van al final**, detrás de
   verificación de edad fuerte, moderación humana y legal reforzado. **18+ al inicio.**
5. **El diferenciador original (puntos por creatividad, D2)** se habilita con IA (Ola 5), pero su
   **corpus se empieza a guardar desde ya** (D1 en Ola 0/1) — barato y sin riesgo.

> **Regla de oro:** en Conversar, *cada persona real que entra sube el riesgo un escalón*. Por eso el
> orden es: **solo → amigos → IA → correctores → desconocidos en audio → tutores.** Nunca al revés.
