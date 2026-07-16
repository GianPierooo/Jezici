# ARQUITECTURA_ANALISIS.md

> Análisis de arquitectura del cliente Flutter de Jezici. **Solo lectura — cero cambios de código.**
> Ground truth: repo real (no los docs) + introspección de `app/lib` + `git log` de churn + 2 agentes de
> exploración cuyas afirmaciones clave verifiqué a mano. Fecha: **2026-07-16**.
> Alcance: el **cliente**. El servidor (Supabase/RLS/RPCs) se analiza solo como frontera.

---

## 0. Veredicto en una página

**Esto no es un proyecto mal arquitecturado.** Antes de listar deuda, el dato que más importa:

> **Solo 2 archivos fuera de `data/` tocan Supabase** (`core/monitoring/crash_reporter.dart`, infra; y
> `features/auth/auth_screen.dart`, solo para el *tipo* `AuthException`). Más `main.dart` (3 usos, para
> escuchar `onAuthStateChange`). **Ninguna pantalla hace queries.** El patrón repositorio se respeta.

Eso es más disciplina de la que tiene la mayoría de apps Flutter de este tamaño. Y no es lo único que está
bien (§1.1). La deuda real existe, pero está **concentrada en 4 sitios**, no repartida por todas partes.

El diagnóstico en una frase: **una clase se comió la capa de datos, y nunca se diseñó una capa de aplicación
ni el manejo de errores.**

| # | Deuda | Dolor | Evidencia dura |
|---|---|---|---|
| 1 | **God repository**: `progress_repository.dart` = 1019 LOC, **~96 métodos públicos, 14 dominios** | **Alto y creciente** | **El archivo Dart más tocado del repo: 47 commits en 3 meses** |
| 2 | **Errores nunca diseñados**: 0 tipos de error, **82 `catch(_) {}` vacíos**, i18n por *substring* de mensajes de Postgres | **Alto** | `friends.dart:27-37` |
| 3 | **No hay capa de aplicación**: la lógica de flujo vive en `State<Widget>` | **Medio** | **35 widget tests vs 13 unit tests** |
| 4 | **Reglas de negocio dentro de `build()`** (mapa, economía co-op, umbral de examen) | **Medio-alto** (el mapa) | `learn_map_screen.dart:245`, `friends.dart:1864`, `profile_screen.dart:1476` |
| 5 | Higiene: widget compartido dentro de un feature; `ui/` mezcla design-system y feature | **Bajo** (arreglo de minutos) | 26 imports a `../learn/widgets/parrot_mascot.dart` |

**Métricas base** (`app/lib`, excluyendo `l10n/` generado = 15.049 LOC):

| Capa | Archivos | LOC | Lectura |
|---|---|---|---|
| `features/` | 84 | 29.866 | 80% del código. Muchos son grandes **por pintar**, no por lógica (§1.1) |
| `core/` | 49 | 3.216 | Infra + algo de dominio puro escondido (`plan/estimation.dart`, `speech/text_match.dart`) |
| `data/` | 17 | 2.862 | **1019 de esos LOC son un solo archivo** |
| `ui/` | 7 | 913 | Design system… y una pantalla de feature de 516 LOC infiltrada |

---

## 1. Diagnóstico de la arquitectura ACTUAL

### 1.1 Qué está BIEN (y no se debe tocar)

Esto no es cortesía: cada punto está verificado y **cambiarlo sería destruir valor**.

1. **La arquitectura de verdad está en el servidor, y es correcta.** Grading, economía, gating,
   certificación y las reglas anti-trampa viven en RPCs `SECURITY DEFINER` con RLS. `correct_answer` está
   revocado (42501). **El cliente no puede mentir aunque quiera.** Esta es la decisión arquitectónica más
   importante del proyecto y está bien tomada. Todo lo demás es secundario.
2. **Patrón repositorio respetado** (el dato de §0). El acceso a datos está contenido.
3. **Inyección de dependencias correcta.** `progressRepositoryProvider` (`data/providers.dart:92-94`) es el
   **único punto de construcción**, alimentado por `supabaseClientProvider` — y ambos son sobreescribibles.
   Es lo que hace que los tests puedan sustituir el repo sin tocar producción.
4. **Modelos inmutables de verdad.** 14 modelos, `const` + campos `final`, **cero campos mutables**.
   `fromJson` defensivos con defaults. Constantes `empty`/`fallback` idiomáticas.
5. **`content_repository.dart` (52 LOC) está impecable** y es el contraejemplo del god object: dominio
   único, solo lectura, sin sesión. Prueba que el equipo **sabe** acotar un repositorio.
6. **Dominio puro YA extraído en 5 sitios** — el proyecto ya descubrió el patrón:
   `features/lesson/grading/grader.dart` (223 LOC), `core/plan/estimation.dart`, `core/speech/text_match.dart`,
   `features/profile/traveler_level.dart`, `features/leagues/division_theme.dart`. **Ninguno importa Flutter.**
   Y los 13 unit tests puros son *exactamente* los de estos archivos. La correlación no es casual: **donde la
   lógica está extraída, el test es puro y barato. Donde no, hay que montar un widget.**
7. **`features/lesson/` ya es feature-first maduro**: `exercises/`, `grading/`, `widgets/`. Es el molde.
8. **`your_plan_view.dart` delega en `estimatePlan()` en vez de recalcular** — es el ejemplo de cómo debería
   verse el resto del onboarding.
9. **Inyección de reloj para determinismo** (`estimation_test.dart:7-12` pasa `now: fixedNow`). Eso es
   madurez de testing, no accidente.
10. **Los archivos grandes que NO son deuda** (verificado uno por uno, no asumido): `leagues_screen.dart`
    (1061 LOC — zonas de color y medallas; `promote`/`demote` vienen decididos del servidor),
    `level_exam_result_screen.dart` (897 — celebración; `passed`/`scorePct` del servidor),
    `chest_reveal_screen.dart` (727 — casi todo `CustomPainter`; el premio lo da el RPC),
    `no_hearts_sheet.dart` (el precio viene de `get_hearts.refill_cost`; el cobro es server-side),
    `practice_screen.dart` (942 — catálogo de tarjetas), `settings_screen.dart` (1092 — sheets y filas).
    **Hay 20 `CustomPainter` en `features/`: son LOC de pintura y no cuentan como deuda.**

### 1.2 Deuda #1 — El god repository (dolor: **alto y creciente**)

`data/repositories/progress_repository.dart`: **1019 LOC, ~96 métodos públicos, 0 privados** (toda la clase
es superficie pública), **77 llamadas a Supabase**, y **14 dominios** mezclados que el propio archivo delata
con sus separadores de sección:

> auth/sesión · perfil/age-gate · cursos · onboarding/plan · lecciones/grading · pedagogía (tips/cuaderno) ·
> inmersión/historias · economía (oro/vidas/tienda/cofre) · legal/GDPR · analítica/admin · **social
> (~25 métodos)** · notificaciones/Matix · práctica/SRS · logros/exámenes/ligas

Mezcla además **tres transportes**: `rpc()` (mayoría), `from().select()` directo y `storage`/`functions.invoke`.

**Por qué duele — la métrica que lo prueba** (`git log`, últimos 3 meses, excluyendo `l10n` generado):

```
47 commits  app/lib/data/repositories/progress_repository.dart   ← #1 absoluto
27 commits  app/lib/data/providers.dart                          ← #2
22 commits  app/lib/features/settings/settings_screen.dart
19 commits  app/lib/features/lesson/lesson_player_screen.dart
```

**Casi toda misión, sea de social, economía, perfil o notificaciones, aterriza en el mismo archivo.** Es un
punto de conflicto permanente y el sitio donde es imposible razonar sobre "qué toca el dominio social" sin
leer 1019 líneas.

**Matiz honesto:** el acoplamiento se canaliza por el *provider*, no por el tipo (`ProgressRepository` solo
se nombra en 2 archivos de `lib/`). Por eso **la ausencia de interfaz duele menos de lo que el manual dice**
(§4). El problema es el tamaño y la mezcla, no la falta de `abstract class`.

**Fuga adicional:** hay lógica de negocio *dentro* del repositorio, no solo I/O — `fetchPracticeStatus`
(`:946-989`) calcula palabras vencidas y elige la skill más débil iterando `reinforce_score`, con un
`catch (_)` que anula el resultado. Eso no es acceso a datos.

### 1.3 Deuda #2 — El manejo de errores nunca se diseñó (dolor: **alto**)

Es la deuda más grave del informe y la menos visible.

- **Cero tipos de error propios.** `grep "Result<|Either<|sealed class|class .*Failure"` en todo `lib/` → **0**.
- **Las excepciones crudas de Supabase llegan al widget.** Un solo `on AuthException` en toda la app
  (`auth_screen.dart:124`). **Cero** `on PostgrestException`. Los ~75 `rpc()` lanzan sin envolver.
- **El error se traduce por *substring del mensaje de Postgres*** — `friends.dart:27-37`:
  `e.toString().toLowerCase().contains('already friends' / 'rate_limited' / 'social unavailable' …)`.
  **La i18n de la app está acoplada al wording literal de una migración SQL.** Si mañana alguien reescribe
  el `raise exception` en un `.sql`, el mensaje al usuario cae al genérico **en silencio**. El equipo *sabe*
  que es frágil (hay un test que lo protege: `friend_error_mapping_test.dart`), pero el test protege el
  mapeo, no el contrato con el servidor.
- **151 `catch (_)` en `lib/`, de los cuales 82 son `catch (_) {}` completamente vacíos**, y **72 están en
  `features/`** (flujos de negocio, no infra).

Buena parte son *deliberados y bien argumentados* (`prioritizeFailedSrs`, `logEvent`, `heartbeat`,
`amIAdmin` fail-closed) — eso es fire-and-forget razonado y **está bien**. Pero otros ocultan fallos que
importan:

| Sitio | Qué se traga |
|---|---|
| `lesson_player_screen.dart:177-179` | `catch (_) { res = GradeResult.stub; }` — un fallo de red al calificar se vuelve un no-evento |
| `progress_repository.dart:987` | Un fallo de `get_skill_mastery` es **indistinguible de "no tiene datos"** → la tarjeta de Practicar miente sin avisar |
| `friends.dart:582,589,983`, `lesson_complete_screen.dart:58` | `catch (_) {}` pelado, sin comentario |

**Consecuencia real:** hay clases enteras de fallo (RPC caído, RLS rechazando, rate limit) que **no producen
ningún síntoma observable** — ni en la UI ni en Sentry. Con Sentry a punto de activarse, esto es lo que hará
que Sentry no vea nada.

### 1.4 Deuda #3 — No hay capa de aplicación (dolor: **medio**)

La prueba está en la forma del suite de tests: **35 widget tests vs 13 unit tests puros**. No es que falte
capacidad de test unitario; es que **no hay una capa donde poner el test unitario**.

El síntoma más claro es `course_switcher.dart:22-135`. `switchCourseFlow(BuildContext, WidgetRef, CourseInfo)`
es un **caso de uso de verdad**: lee el curso previo → consulta si hay plan → diálogo → `setActiveCourse` →
invalida el scope → navega al placement → **re-consulta y REVIERTE al curso anterior si el usuario abandonó
el test** (una *compensating transaction*) → o rama "desde cero" con `estimatePlan` + `createPlan`.

Su propio doc-comment lo declara **"INVARIANTE (fix dashboard vacío)"** — o sea: es una garantía de negocio
**con historia de bugs**, y su único punto de verificación es una función que **necesita `BuildContext`, un
`Navigator` y `showDialog`**. Es intestable sin montar la app entera.

Además invalida **9 providers a mano** (`_invalidateCourseScope`, `:147-156`). Esa lista es un *smell*: el
concepto "scope del curso activo" existe en la cabeza del equipo pero **no está modelado**; si alguien añade
un provider course-scoped y olvida esa lista, aparece un bug de datos rancios sin error.

### 1.5 Deuda #4 — Reglas de negocio dentro de `build()` (dolor: medio-alto en el mapa)

Verificado a mano:

- **`learn_map_screen.dart:245-266` — el motor de progresión del curso vive en un `State`.** `_stateFor()`
  mapea strings crudos (`'completed'`/`'golden'`/`'available'`) a `NodeState` **y aplica la regla real**:
  completado + unidad bajo el nivel de entrada → **dorado**. Es una función pura
  `(lesson, index, progress, entryLevel) → NodeState` atrapada en un widget. Peor: **cuatro derivaciones
  distintas la re-recorren en bucle** (`_unitProgress:275`, `_frontierIndex:309`, `unitLocked` inline en
  `build():425`, `_targetScroll:183`). **La regla más crítica del producto solo se puede probar montando
  `_MapBody` con un `ScrollController`.**
- **`friends.dart:1864` — economía en un widget de tarjeta:** `reward_gold … ?? 50`. **Un número de economía
  con default mágico, dentro de un `build()`.** (Verificado.) Junto a la máquina de estados
  `invited`/`completed`/`expired`.
- **`profile_screen.dart:1476` — `final toGate = (maxPct / 0.8).clamp(0.0, 1.0);`** El umbral 80% de la
  compuerta del examen, **hardcodeado en un `build()`**. `examUnlocked` viene del servidor pero la barra lo
  **re-deriva client-side con su propia constante** → dos fuentes de verdad. Si el servidor cambia el
  umbral, la barra miente y nadie se entera.
- **Regla "capar la meta al tope del curso" duplicada 4 veces… y ya existe en dominio.** Verificado:
  `onboarding_screen.dart:596`, `onboarding_screen.dart:621-638`, `course_placement_screen.dart:65`,
  `course_switcher.dart:105` — **y `core/plan/estimation.dart:101-103` ya la implementa**. Divergen: el
  dominio capa después del bump, la UI antes.
- **"¿Cuál es tu skill más débil?" contestada con 3 criterios distintos en 3 pantallas**
  (`lesson_complete_screen.dart:381-388`, `profile_screen.dart:600-667`, `practice_screen`).
- **`friends.dart` (2940 LOC): `Map<String,dynamic>` crudo en ~22 sitios de UI.** 4 providers devuelven mapas
  sin pasar por modelos → cada widget indexa `s['handle']`, `s['needs_handle'] == true`… **Es el feature más
  nuevo y el único que abandonó el patrón de modelos** que el resto sí respeta. No es casualidad: se
  construyó rápido bajo presión de producto.

### 1.6 Deuda #5 — Higiene (dolor: **bajo**; arreglo de minutos)

- **`ParrotMascot` vive en `features/learn/widgets/parrot_mascot.dart` y lo importan 26 archivos de otros
  features.** El grafo de acoplamiento dice "casi todo depende de `learn`" — **es mentira**: de los imports
  cruzados a `learn`, **26 son la mascota y solo 1 es real** (`learn_map_screen`). No es acoplamiento de
  dominio; es **un archivo mal ubicado**.
- **`ui/` mezcla design system con feature**: `primary_button`, `jz_card`, `progress_bar` (correcto) conviven
  con `edit_profile_sheet.dart` (**516 LOC**, una pantalla de perfil).
- **`data/providers.dart`: 33 providers globales en un archivo plano**, mezclando dominios y hasta un
  controlador de UI (`HomeTabRequest`). Además 8 providers viven fuera (`friends.dart`, `matix_*`, `core/`).
  Inconsistencia de convención, no de arquitectura.
- **Modelos sin `==`/`hashCode`** (cero en los 14) → Riverpod rebuildea en cada refresh aunque el dato sea
  idéntico, y los tests comparan campo a campo. Y solo 2 `copyWith` en 14 modelos.
- **`main.dart`: el AppGate es una cadena de 5 gates anidados en un `build()`** (sin sesión → onboarding →
  perfil incompleto → @handle → HomeShell). Hoy son ~30 líneas y funciona; lo anoto porque **crece con cada
  regla de entrada nueva** (yo mismo le añadí el 4º gate esta semana).

---

## 2. Arquitectura OBJETIVO (para ESTE proyecto)

### 2.1 La decisión de fondo: **Clean Architecture completa sería un error aquí**

Antes de proponer capas, hay que entender qué es este cliente. En Jezici:

> **El dominio ya vive en el servidor.** Grading, economía, gating, certificación, ligas y anti-trampa son
> RPCs con RLS. El cliente **no puede** ser la autoridad de negocio — por diseño y por seguridad.

Eso cambia todo. La Clean Architecture de manual (entidades + casos de uso para *cada* operación +
interfaces de repositorio + mappers DTO↔entidad en cada capa) asume que **tu app es dueña del dominio**.
Aquí no lo es. Copiar ese molde te daría, para `fetchNotifications`, esta cadena:

```
Widget → Controller → GetNotificationsUseCase → INotificationsRepository
       → NotificationsRepositoryImpl → NotificationDto → NotificationEntity → NotificationUiModel
```

…seis archivos de ceremonia para envolver **una llamada RPC que ya funciona**. Para un dev en solo con un
agente, eso no es profesionalismo: es *coste sin retorno*, y hace que cada feature nuevo sea más lento sin
prevenir ningún bug real. **Rechazo esa opción explícitamente.**

### 2.2 La forma objetivo: **feature-first pragmático, con capas donde se ganan el sueldo**

El objetivo no es "tener capas", es que **cada regla tenga un sitio obvio y testeable sin montar UI**.

```
lib/
  core/            # infra transversal SIN dominio: audio, speech, prefs, theme, monitoring, config
  ui/              # SOLO design system: primary_button, jz_card, chips, mascota, sheen…  (nada de features)
  shared/
    errors/        # ← NUEVO: JzError tipado (la pieza de mayor ROI)
    models/        # modelos compartidos entre features
  features/
    <feature>/
      domain/      # funciones PURAS + modelos del feature. CERO import de Flutter. ← aquí van los tests
      data/        # repositorio ACOTADO del feature (RPCs de su dominio) + mapeo de errores
      application/ # SOLO para flujos multi-paso con invariantes (no para CRUD)
      presentation/# widgets + controllers (Notifier). Sin reglas de negocio.
```

**Reglas de la casa (las 5 que importan):**

1. **`domain/` no importa Flutter.** Es el test de compilación de si una regla está bien colocada. El
   proyecto ya lo cumple en 5 archivos; se generaliza.
2. **Un repositorio por dominio**, no uno por app. Tamaño diana: como `content_repository` (52 LOC), no como
   `progress_repository` (1019).
3. **`application/` solo si hay ≥2 pasos con estado o compensación.** `switchCourseFlow` sí (revierte si
   abandonas). `fetchNotifications` no — el widget llama al repo y ya. **No inventar casos de uso.**
4. **La UI no ve `Map<String,dynamic>` jamás.** Si un provider devuelve un mapa crudo, falta un modelo.
5. **Los errores cruzan la frontera tipados.** El repositorio traduce `PostgrestException` → `JzError` una
   vez; nadie más hace `contains('rate_limited')`.

**Sobre interfaces de repositorio (`abstract class`): NO, salvo que aparezca un 2º implementador.** Los
tests ya sustituyen el repo con `implements` + `noSuchMethod` + `overrideWithValue`, y funciona. Añadir 14
interfaces solo para "cumplir Clean" es ceremonia. **Si algún día hay un modo offline o un backend distinto,
entonces sí.** Lo digo explícitamente para que nadie "complete" la arquitectura por estética.

### 2.3 Qué se gana, en concreto

| Hoy | Después |
|---|---|
| El mapa solo se prueba montando `_MapBody` con un `ScrollController` | `mapProgression()` es una función pura → 20 tests en milisegundos |
| Cambiar el umbral 0.8 → tocar `profile_screen` y rezar | Una constante en `domain/` (o mejor: viene del servidor) |
| Todo aterriza en un archivo de 1019 LOC (**47 commits/3 meses**) | Cada feature toca su repo de ~80 LOC |
| Un `raise exception` en SQL rompe la i18n en silencio | Contrato tipado; el compilador y un test lo cazan |
| Un RPC caído = no pasa nada visible | `JzError` decide: reintentar, avisar, o reportar a Sentry |

---

## 3. Plan de migración INCREMENTAL

**Principios innegociables:**
- **Nunca una reescritura.** Una rebanada por misión, cada una verde de punta a punta.
- **Nunca se toca el contrato del servidor** durante un refactor. Los RPCs y sus firmas quedan igual → los
  scripts `verify_*.py` de cliente real siguen siendo la red de regresión.
- **Refactor y feature nunca en el mismo commit.**
- **Verificación por paso (idéntica a las reglas del agente):** `flutter analyze` 0 (CI-exact, `.env` vacío)
  · suite completa verde · `build web` OK · **el `verify_*.py` del dominio tocado** · CI SUCCESS · deploy READY.

Estimaciones = **jornadas de trabajo enfocado** (Gian + agente). Son órdenes de magnitud, no compromisos.

### Fase 0 — Higiene y una duplicación real (**0.5 día · riesgo CERO**)

Movimientos puros y un dedupe. Sin cambio de comportamiento.

1. `features/learn/widgets/parrot_mascot.dart` → `ui/parrot_mascot.dart` (arregla 26 imports falsos; el grafo
   de dependencias deja de mentir).
2. `ui/edit_profile_sheet.dart` (516 LOC) → `features/profile/`.
3. **Dedupe de la regla "capar meta a `maxLevel`"**: los 4 sitios pasan a usar la que **ya existe** en
   `core/plan/estimation.dart:101`.

*Verificación:* analyze + tests + build. Si pasa, es correcto por construcción (solo se movieron símbolos).
*Por qué primero:* valor inmediato, riesgo nulo, y limpia el mapa mental antes de lo serio.

### Fase 1 — PILOTO: el mapa (**1 día · riesgo bajo-medio · máximo aprendizaje**)

**Por qué el mapa es el piloto correcto** (y no `friends.dart`, que es la peor deuda):
- Es **derivación pura**: `(lesson, index, progress, entryLevel) → NodeState`. **No hace I/O.** Extraerlo no
  puede romper la red ni el servidor.
- Es la regla **más crítica** del producto → el aprendizaje se paga solo.
- **Ya hay red de seguridad**: `map_window_test`, `map_visuals_test`, `map_culling_test`.
- Es una extracción **cerrada**: nadie fuera del mapa llama a `_stateFor`.
- `friends.dart` es la peor deuda **pero el peor piloto**: 2940 LOC, seguridad social 18+ recién estabilizada
  y sin modelos. Migrarlo primero es pedir un incidente.

**Pasos:** crear `features/learn/domain/map_progression.dart` (puro) → mover `_stateFor`, `_belowEntry`,
`_unitProgress`, `_frontierIndex`, `unitLocked` **sin cambiar una línea de su lógica** → el widget solo llama
→ escribir los unit tests que hoy son imposibles (dorado bajo nivel de entrada, fallback GA10, unidad
bloqueada, frontera).

*Verificación:* los tests de mapa existentes deben pasar **sin tocarlos** (esa es la prueba de que no cambió
el comportamiento) + los nuevos unit tests + golden visual del mapa.
*Entregable extra:* este es el **molde** que copian las fases siguientes.

### Fase 2 — Errores tipados (**2 días · riesgo bajo · ROI más alto**)

La deuda más dolorosa y la más independiente (no requiere haber partido el repo).

1. `shared/errors/jz_error.dart`: jerarquía **pequeña y honesta** — `Network`, `Auth`, `Denied` (RLS/42501),
   `RateLimited`, `Conflict` (`handle_taken`, `already friends`), `Server`, `Unknown`. Nada más.
2. El repositorio traduce `PostgrestException`/`code` **una vez** → `JzError`. **Se usa el `code` de Postgres,
   no el texto del mensaje** — ahí muere el `contains('rate_limited')`.
3. Empezar por el dominio **social** (ya tiene `friend_error_mapping_test.dart` como red).
4. **Barrido de los 82 `catch (_) {}` vacíos**: cada uno se decide explícitamente → (a) fire-and-forget
   *documentado* (se quedan: `logEvent`, `heartbeat`, `prioritizeFailedSrs`), o (b) se propaga como `JzError`
   y **se reporta a Sentry**. Prioridad: `lesson_player_screen.dart:177` y `progress_repository.dart:987`.

*Verificación:* `verify_friends.py` + `verify_conversar_*.py` (los motivos tipados ya se prueban ahí) + tests.
*Nota de oportunidad:* hacerlo **antes** de activar Sentry en producción; si no, Sentry no verá los fallos
que hoy se tragan.

### Fase 3 — Partir el god repository (**~4 días · 1 rebanada por misión · riesgo bajo**)

Mecánico y sorprendentemente seguro: **las firmas no cambian**, solo se mueven métodos a repos por dominio y
`providers.dart` expone un provider por repo. El compilador caza todo.

Orden por aislamiento (de más aislado a más entrelazado):
1. **Social** (~25 métodos) — el bloque más grande y el más autocontenido. Red: `verify_friends.py`, `verify_presence.py`.
2. **Economía** (oro/vidas/tienda/cofre, ~8) — red: los tests de tienda/cofre/SinVidas.
3. **Notificaciones/Matix** (~6) — red: `verify_t4.py`.
4. **Perfil/age-gate + legal/analítica** (~13) — red: `verify_t5.py`, `verify_handle_mandatory.py`.
5. **Se queda al final** el núcleo (lecciones/plan/placement/exámenes): es el loop y tiene la mejor cobertura,
   pero también el mayor coste si se rompe. Para entonces el patrón estará rodado.

*Verificación por rebanada:* analyze + suite + el `verify_*.py` del dominio + CI + deploy.
*Efecto medible:* el churn del archivo #1 se reparte; deja de ser el cuello de botella de toda misión.
*Aviso:* durante esta fase **no** añadir interfaces `abstract` (§2.2). Solo mover.

### Fase 4 — `conversar/friends.dart` (**3 días · riesgo medio · la peor deuda**)

Ya con molde (F1), errores tipados (F2) y repo social propio (F3), esto deja de dar miedo.

1. **Modelos** para lo que hoy son `Map<String,dynamic>` en ~22 sitios (`Friend`, `SocialStatus`, `CoopChallenge`,
   `ChatMessage`). La UI deja de indexar strings.
2. **`domain/`**: `presenceOf` (regla de presencia), estado de co-op y **`reward_gold ?? 50` sale del `build()`**
   (el default de economía se decide en dominio, o mejor: se exige del servidor).
3. **Partir el archivo** por pantalla (`friends_list`, `chat`, `coop`, `public_profile`) — 2940 LOC no es un archivo.
4. **`application/`**: la mutación optimista con reversión (`_sentTo`/`_responded`) es un caso de uso.

*Verificación:* `verify_friends.py` + `verify_presence.py` + `verify_conversar_t3.py` + `friends_ui_test`.
*Guardarraíl:* la seguridad social (18+, blocks bidireccionales, rate limits) es **server-side y no se toca**.

### Fase 5 — Casos de uso para flujos con invariantes (**2 días · riesgo medio**)

Solo para los que **realmente** lo son. Hoy son dos:
1. **`switchCourseFlow`** — el que declara "INVARIANTE (fix dashboard vacío)". Sacarle `BuildContext`/`WidgetRef`:
   el caso de uso decide y devuelve un resultado; la UI muestra diálogos y navega. **Entonces el invariante
   por fin se puede testear.** De paso, modelar el "scope del curso" para que la lista de 9 invalidaciones
   manuales deje de ser un campo de minas.
2. **Fin de lección** (`lesson_player_screen`: grading + SRS + vidas + navegación).

### Fase 6 — Opcional, solo si duele (**1 día**)

- `==`/`hashCode` en los modelos **donde se midan rebuilds** (no en los 14 por decreto). Empezar por
  `HomeStats`/`SkillLevel`. **Sin `freezed`/`build_runner`**: para 14 modelos el coste de la codegen (CI más
  lento, archivos generados, curva) supera el beneficio.
- Trocear `data/providers.dart` por dominio (sale casi gratis después de F3).
- Extraer la cadena de gates del `AppGate` **cuando llegue el 6º gate**, no antes.

### Resumen del plan

| Fase | Qué | Días | Riesgo | Se puede parar aquí |
|---|---|---:|---|---|
| 0 | Higiene + dedupe meta | 0.5 | Cero | ✅ |
| 1 | **Piloto: dominio del mapa** | 1 | Bajo-medio | ✅ |
| 2 | **Errores tipados + matar silencios** | 2 | Bajo | ✅ ← *si solo se hace una, que sea esta* |
| 3 | Partir el god repo (5 rebanadas) | ~4 | Bajo | ✅ tras cada rebanada |
| 4 | `friends.dart` | 3 | Medio | ✅ |
| 5 | Casos de uso con invariantes | 2 | Medio | ✅ |
| 6 | Pulido opcional | 1 | Bajo | — |

**~13.5 días** repartibles en misiones independientes. **Cada fase deja el repo verde y desplegable**; ninguna
depende de terminar la siguiente. Si el proyecto se detiene en la Fase 2, **igual habrá ganado lo más valioso**.

---

## 4. Qué NO tocar

Lista explícita para que nadie "mejore" lo que ya está bien:

1. **El servidor.** RPCs, RLS, grading server-side, economía, certificación. Es la mejor decisión del
   proyecto. Un refactor de cliente **jamás** debe cambiar una firma de RPC.
2. **`content_repository.dart`** (52 LOC). Está bien. Es el modelo a imitar.
3. **Los 20 `CustomPainter`** (`scenery_painter`, `trail_painter`, `chest_reveal`, mascota…). Son grandes por
   **pintar**. Moverlos no arregla nada y arriesga regresiones visuales.
4. **`leagues_screen`, `level_exam_result_screen`, `chest_reveal_screen`, `no_hearts_sheet`, `practice_screen`,
   `settings_screen`, `your_plan_view`.** Verificados uno a uno: **grandes por layout, no por lógica**. Las
   reglas vienen del servidor. Su tamaño **no es deuda de arquitectura**.
5. **La inyección de dependencias.** Un único punto de construcción, sobreescribible. Ya es correcto.
6. **`grader.dart`, `estimation.dart`, `text_match.dart`, `traveler_level.dart`, `division_theme.dart`.** Ya
   son dominio puro y ya tienen tests puros. Son el destino, no el problema.
7. **NO añadir interfaces de repositorio** sin un 2º implementador real (§2.2).
8. **NO adoptar `freezed`/`build_runner`** para 14 modelos.
9. **NO meter `go_router`.** Solo 6 archivos usan `Navigator.push` y el `AppGate` funciona. Añadir un router
   ahora es coste sin problema que resolver.
10. **NO tocar `l10n/`** (15.049 LOC generados por `gen-l10n`).
11. **El patrón de fakes en tests.** `implements` + `noSuchMethod` + `overrideWithValue` funciona y es barato.
    Migrar a `mockito`/`mocktail` no compra nada hoy.

---

## 5. Honestidad sobre este análisis

- **Verificado a mano** (no delegado): el `?? 50` de la economía co-op (`friends.dart:1864`), el
  `(maxPct / 0.8)` (`profile_screen.dart:1476`), las 4 copias de la regla de meta, el churn de git, que solo
  2 archivos fuera de `data/` tocan Supabase, y que los 26 imports a `learn` son la mascota.
- **Lo que NO medí:** rendimiento real de los rebuilds por falta de `==` (afirmo el mecanismo, no el impacto
  — habría que perfilarlo antes de gastar un día en ello). Tampoco medí tiempo de build ni tamaño de bundle.
- **Sesgo declarado:** parte de la deuda descrita la escribí yo en misiones anteriores (el 4º gate del
  AppGate, el `HandleGateScreen` en `friends.dart`, métodos nuevos en el god repo). El análisis no es más
  benévolo por eso, pero conviene saberlo.
- **Lo que este análisis no cubre:** arquitectura del servidor (migraciones, diseño de RPCs), el pipeline de
  contenido (`tools/content/`) y CI/CD. Son sistemas aparte con su propia salud.

**Conclusión.** El instinto de "llevarlo a algo más profesional" es correcto, pero el diagnóstico popular
("está mal, hay que rehacerlo con Clean Architecture") **no aplica aquí**. Este cliente ya tiene lo caro
(seguridad server-side, repositorio, DI, inmutabilidad, dominio puro en 5 sitios). Lo que le falta es
**terminar de aplicar lo que ya descubrió**: sacar las reglas de los `build()`, partir la clase que se comió
la capa de datos, y **diseñar los errores** — que es la única parte que nunca se diseñó y la que hoy hace que
los fallos sean invisibles.
