# Jezici — QA exhaustivo end-to-end + evaluación de flujo (SOLO LECTURA)

> **Fecha:** 2026-06-27 · **Modo:** diagnóstico, **CERO cambios de código** (los fixes salen en
> misiones posteriores). **Método:** cliente REAL (anon + JWT autenticado, nunca service_role),
> lectura de código (~4 clusters en paralelo) y verificación en vivo con sondas. Toolchain:
> `flutter analyze` **0** · `flutter test` **82/82** · `build web` **OK** (2026-06-27).
> Distingue **verificado en vivo** vs **requiere dispositivo (Gian)**, y **CORRECTITUD** vs **FLUJO/UX**.

---

## 0. Resumen ejecutivo

La app está **sólida en el núcleo**: grading 100% server-side (`correct_answer` 42501 confirmado por
todas las vías), leaderboards sin fuga de `user_id`, placement preciso con fecha honesta, loop de
lección con degradación con gracia, 0 recursos 404. La mayoría de lo verificado en vivo **PASA**.

**Hay 1 P0 real de correctitud** (el congelador de racha no protege nada) y **2 P1 de flujo** (el
selector de idioma no traduce nada; misiones sin recompensa poco claras). El resto son pulidos (P2).

| Sev | # | Titular |
|---|---|---|
| **P0** | 1 | Congelador de racha se compra (50 oro) pero NUNCA protege la racha |
| **P1** | 4 | Selector de idioma cosmético (no hay i18n) · misión sin recompensa/aclaración · a11y escasa · strings es hardcodeados |
| **P2** | ~10 | Feedback de transacciones de oro · celebración de hito · combo en vivo · race de cofre · precios hardcodeados · `weak_skill` sin usar · infra de bots · colores sueltos · zonas de liga mal escaladas (beta) · deuda técnica de leaderboards |

---

## 0.1 Estado de resolución (actualizado 2026-07-02)

Fixes aplicados en misiones posteriores (todos live, cliente real, CI verde):

| Ítem | Estado | Cómo |
|---|---|---|
| **P0-1** Congelador de racha | ✅ **CERRADO** | `mig 090`: `jz_register_activity` consume freeze y preserva la racha (verify_streak_freeze.py 7/7). |
| **P1-1/P1-2** Idioma cosmético + strings ES | ✅ **CERRADO** | i18n real es/en/pt (flutter_localizations+gen-l10n); onboarding+auth+loop 100% traducidos; selector en Ajustes cambia la UI al instante. |
| **P1-3** Misión sin recompensa/aclaración | ✅ **CERRADO** | `mig 091`: bono de bienvenida one-time (25 XP + 25 oro) + diálogo de confirmación "¡Tu viaje ha comenzado!" (no toca racha/meta). verify_mission_reward.py 4/4. |
| **P1-4** Accesibilidad (Semantics) | ⏸️ **DIFERIDO** | Requiere pruebas con lector de pantalla en device (Gian). Añadido Semantics a la meta diaria; barrido amplio pendiente. |
| **P2-1** Feedback de oro | ✅ **CERRADO** | Toasts enriquecidos "ganaste/gastaste X, te quedan Y" (cofre/vidas/freeze), localizados; las RPC ya devuelven `gold`. |
| **P2-2** Celebración de hito | ✅ **YA PRESENTE** | `lesson_complete_screen` ya muestra un cartel de hito (gradiente dorado + 🏆) con confeti; verificado. |
| **P2-3** Combo en vivo | ✅ **CERRADO** | Chip "🔥 x{n}" animado en la top bar de la lección desde 3 aciertos seguidos (el contador ya existía server+cliente). |
| **P2-4** Race del cofre | ✅ **CERRADO** | Guard `if (_busy != null) return;` + el botón ya se deshabilitaba con `busy`. |
| **P2-9** Zonas de liga en beta | ✅ **CERRADO** | `mig 092`: `get_league` devuelve promote/demote=0 hasta el umbral de movimiento (13, == gate del rollover); la UI solo pinta zonas con `movementActive` y muestra nota de beta. Sin fuga de user_id (verificado). |
| **P2-5** Precios hardcodeados | ⏸️ **DIFERIDO** | Fuera de alcance (mantenibilidad; sin impacto de usuario). |
| **P2-6** `weak_skill` sin resaltar | ✅ **HECHO (i18n)** | El tip personalizado ya usa la skill floja localizada ("tu {skill} necesita un empujón"). |
| **P2-7** Infra de bots | ⏸️ **DIFERIDO** | Solo verificación de dato en prod; en vivo `is_bot:false`. |
| **P2-8** Colores hardcodeados | ⏸️ **DIFERIDO** | Cosmético (sombras/bordes, no marca). Ver UX_AUDIT.md. |
| **P2-10** Deuda técnica leaderboards | ⏸️ **DIFERIDO** | Impacto actual nulo (paginación futura). |

---

## 1. P0 — CORRECTITUD (rompe)

### P0-1 · Congelador de racha (streak freeze) no protege la racha — **VERIFICADO EN CÓDIGO + VIVO**
- **Superficie:** racha / tienda. `use_streak_freeze()` y `jz_register_activity()` (mig 018).
- **Qué probé:** leí `jz_register_activity` (mig `20260616120018_rpc_streak_matix.sql:34-45`) + grep de
  `freezes_available` en TODAS las migraciones + sonda en vivo (`use_streak_freeze` → `{ok, freezes_available:1}`).
- **Qué está mal:** `use_streak_freeze()` **solo hace `freezes_available += 1`** (y cobra 50 oro). El
  avance de racha (`jz_register_activity`) al detectar un hueco (`v_last <> current_date - 1`) **resetea
  `current_streak := 1` sin leer ni consumir `freezes_available`**. No existe ninguna RPC ni rama que
  aplique el congelador. `grep freezes_available` → solo se incrementa, nunca se decrementa/usa.
- **Impacto:** el usuario gasta 50 oro en un ítem que **no hace nada**; pierde la racha igual tras un día
  sin practicar. Rompe la mecánica y la confianza (economía + retención).
- **Tipo:** CORRECTITUD · **Sev:** P0.
- **Propuesta:** en `jz_register_activity`, cuando hay hueco de 1 día y `freezes_available > 0`, consumir
  1 freeze y **preservar** `current_streak` (marcar `last_active_date`); si no hay freeze, resetear. (Y/o
  ocultar el botón de compra hasta implementarlo, para no cobrar por nada.)

---

## 2. P1 — FLUJO/UX o correctitud media (confunde o incompleto)

### P1-1 · El selector de idioma de la app NO traduce nada — **VERIFICADO EN CÓDIGO**
- **Superficie:** onboarding paso 1 "¿En qué idioma prefieres la app?" + Ajustes.
- **Qué probé:** grep `flutter_localizations|AppLocalizations|intl|.arb|l10n` → **nada**; no existe
  `lib/l10n`; `MaterialApp` no fija `locale`/`localizationsDelegates`; `localeProvider` solo **guarda**
  'es/en/pt' pero **ningún widget lo consume** para traducir. Todo el copy es español hardcodeado.
- **Qué está mal:** elegir "English"/"Português" **no cambia ni un texto** de la interfaz. La app pregunta
  algo que no cumple → esto es exactamente lo que hacía sentir el paso "raro" (además del copy ya pulido).
- **Impacto:** promesa incumplida; un usuario que elige en/pt ve todo en español. (Mitigado porque el
  público objetivo es hispanohablante — pero el selector engaña.)
- **Tipo:** FLUJO · **Sev:** P1 (P0 para un usuario real no-hispanohablante).
- **Propuesta:** o (a) implementar i18n de verdad (flutter_localizations + .arb/mapa central, empezando
  por onboarding + navegación), o (b) por ahora **quitar/deshabilitar** en/pt del selector (dejar es) o
  relabelarlo honestamente hasta que exista traducción. Decidir con Gian; NO dejar el selector engañoso.

### P1-2 · Strings hardcodeados en español (p.ej. errores) — **VERIFICADO EN CÓDIGO**
- **Superficie:** `onboarding_screen.dart:92` `'No se pudo guardar tu plan. Reinténtalo.'` y muchos más.
- Subcaso concreto del P1-1; se lista aparte porque incluso con i18n mínimo, los SnackBars/errores deben
  entrar primero. **Sev:** P1 (dependiente de la decisión de P1-1).

### P1-3 · La MISIÓN inicial no da recompensa y no lo explica — **VERIFICADO EN CÓDIGO**
- **Superficie:** nodo "misión" (100 esenciales) `mission_screen.dart` + `complete_mission()` (mig 039).
- **Qué probé:** `complete_mission` (mig `20260616120039_mission_gating.sql:98-127`) marca `completed` y
  desbloquea el siguiente nodo, **sin XP/oro/racha** (intencional, así lo dice el comentario).
- **Qué está mal (FLUJO):** el usuario toca "empezar" esperando recompensa como en una lección y recibe
  solo "completado". Confunde en el PRIMER nodo del viaje (mal momento para una expectativa fallida).
- **Tipo:** FLUJO · **Sev:** P1. **Propuesta:** cartel claro ("Esto inicia tu viaje — desbloquea el mapa,
  no suma XP") o dar un XP simbólico para consistencia.

### P1-4 · Accesibilidad: uso escaso de `Semantics` en onboarding/lección — **VERIFICADO EN CÓDIGO (parcial)**
- **Qué probé:** grep `Semantics` en `features/onboarding` y `features/lesson` → casi nulo (sí existe en
  la top bar del mapa y algún botón). Botones/tarjetas táctiles sin etiqueta semántica.
- **Impacto:** VoiceOver/TalkBack no narran bien; usable pero no accesible. **Sev:** P1→P2 (device).
- **Propuesta:** envolver botones/campos clave con `Semantics(button:true, label:…)`. **Requiere prueba
  con lector de pantalla en el Android de Gian.**

---

## 3. P2 — Pulido (mejorable, no rompe)

- **P2-1 · Feedback de transacciones de oro (FLUJO).** Cofre/freeze/vidas: el toast dice el resultado
  pero no anima el saldo ni dice "pagaste 50, te quedan X". (`tienda_screen.dart`, `streak_screen.dart`.)
  Verificado en vivo que las RPC funcionan (`open_daily_chest`→+55 oro; `buy_hearts`→`insufficient_gold`
  con gracia). **Device** para el detalle visual.
- **P2-2 · Celebración de hito de racha (FLUJO).** `complete_lesson` devuelve `milestone`/`milestone_bonus`
  (7/30/100/365 → 50/100/250/500 oro) pero la pantalla de recompensa no lo destaca con un cartel especial.
- **P2-3 · Contador de combo en vivo (FLUJO).** El servidor calcula combo y la recompensa muestra
  `max_combo` (sonda: `combo_max=8`), pero no hay contador visible DURANTE la lección. **Device.**
- **P2-4 · Race del cofre diario (FLUJO).** El botón "Abrir" no se deshabilita al instante; doble-tap
  rápido en red lenta → 2ª llamada rechazada (RPC lo bloquea bien; UX confusa). **Device.**
- **P2-5 · Precios hardcodeados en cliente y servidor (CORRECTITUD/mantenibilidad).** 50 oro (vidas/freeze)
  y cofre repartidos entre `tienda_screen.dart` y las RPC; cambiar el balance toca 2 sitios. Sugerencia:
  `shop_status` ya devuelve estado → devolver también precios.
- **P2-6 · `weak_skill` no se usa en la UI del tip (FLUJO).** `get_lesson_tip` devuelve la skill floja y
  el tip trae su `skill`, pero `lesson_complete_screen` no resalta "este te ayuda con tu punto flojo".
- **P2-7 · Infra de "bots" en ligas (CORRECTITUD, revisar).** `get_league` devuelve `is_bot`; GA6 dice
  "ligas reales sin bots". Verificado en vivo: en beta aparecen usuarios reales (`is_bot:false`). Confirmar
  que NO haya bots sembrados en prod (la columna/infra existe). **Sev:** P2 (verificar dato en prod).
- **P2-8 · Colores hardcodeados (`Color(0xFF…)`) (VISUAL).** ~decenas, casi todos sombras/bordes (no marca).
  Impacto nulo; solo consistencia. (Ya señalado en UX_AUDIT.md.)
- **P2-9 · Zonas de ascenso/descenso mal escaladas en ligas pequeñas (FLUJO).** `get_league` devuelve
  `promote:7/demote:5` (pensado para 30 jugadores) y la UI (`leagues_screen.dart:94,173-177`) filtra bots
  y calcula zonas sobre los N reales → en una liga beta de 6–12, la zona de descenso puede cubrir casi
  toda la tabla. El **rollover server-side es correcto** (solo mueve con `grp>=13`); es un desajuste de
  DISPLAY. **Device.** Propuesta: escalar zonas según N o que el servidor devuelva `promote_count/demote_count`.
- **P2-10 · Deuda técnica de ligas (CORRECTITUD menor).** (a) `LeaderboardResult.fromJson` no captura
  `limit`/`offset` que la RPC devuelve (sin impacto hoy; romperá paginación futura). (b) `jz_close_weeks()`
  sin lock explícito bajo concurrencia — idempotente (ON CONFLICT) → resultado correcto, solo recálculo
  duplicado en picos. (c) comparaciones `date` vs `timestamptz` mezcladas en `get_leaderboard` (Postgres lo
  resuelve; normalizar por prolijidad). Todo **verificable en código**, impacto actual nulo.

---

## 4. Lo verificado EN VIVO que está BIEN (con evidencia, cliente real)

- **Grading 100% server-side + `correct_answer` 42501:** vista pública sin la columna; tabla base 403;
  `grade_item` correcto/tolerante. (`smoke_client_queries.py` TODO PASA.)
- **Placement v2:** personas A1–C1 → su nivel EXACTO; estimador "techo con evidencia" (acierto suelto NO
  promueve, `verify_estimator.py` 7/7); puente nivel→unidad de entrada; fecha realista/humana y coherente
  con el nivel (agente de onboarding lo confirma: entry unit ↔ CefrTable ↔ fecha alineados).
- **Loop de lección:** 7 tipos jugables (mc, cloze, translation, word_bank/reorder, match, listening,
  speaking read-aloud) funcionales; near-match espejo del servidor (perdona typo menor/artículo, bloquea
  homógrafos); vidas; repaso de errores ANTES de la recompensa; audio/imagen con failsafe + colapso con
  gracia; `_audioUnavailable` no penaliza; estados de carga/error/vacío decentes.
- **Ligas/leaderboards:** `get_league` + `get_leaderboard` en las 4 ventanas (semanal/mensual/anual/
  histórico) **sin fuga de `user_id`** (verificado en vivo); rollover idempotente/lazy (mig 059).
- **Perfil/dominio:** `get_profile`, `get_skill_mastery` (per-skill, working_level), `get_certificates`
  responden y cuadran; el radar refleja las 4 habilidades reales.
- **Gamificación (RPC):** XP/oro/combo en `complete_lesson` (sonda: XP27/oro10/golden/combo8); logros
  (`primeros_pasos` se desbloquea al completar 1 lección); cofre diario; tienda; buy_hearts con guardas.
- **Práctica:** SRS (SM-2 lite, intervalos 1→2→4→8→16→30), weakness por `jz_reinforce_score`, timed
  excluye audio/speaking, pools excluyen `placement`; `start_practice` 4 modos responden (srs due=468).
- **Inmersión:** `get_stories` (6), preguntas server-side, XP solo 1ª vez.
- **Matix/tips:** `get_lesson_tip` relevante al tema real (sonda U1→tip de sujeto/to be), anti-repetición.
- **Recursos:** **0 archivos 404** (759 audios + 76 imágenes + 46 historias + música), sweep 2026-06-27.
- **Multicurso:** contenido pt→curso pt (verify_pt_ls/pt_chain), 0 fuga al curso en.
- **Toolchain:** analyze 0 · test 82/82 · build web OK.

---

## 5. Para probar en el DISPOSITIVO de Gian (no verificable en runtime headless)
1. **Congelador (P0):** compra un freeze, sáltate un día, completa al día siguiente → ¿la racha se
   preserva? (Hoy NO — confirmar el bug en device.)
2. **Idioma (P1):** cambia el idioma de la app a English → ¿cambia algún texto? (Hoy NO.)
3. **Misión (P1):** toca el primer nodo (misión) → ¿esperabas XP? ¿el mensaje lo aclara?
4. **Audio/imagen lenta:** en red lenta, ¿el listening/ imagen degradan con gracia (no spinner eterno)?
5. **Música del mapa (misión previa):** on → suena sutil; entra a lección → se calla; iPhone bloqueado
   → NO debe aparecer reproductor en la pantalla de bloqueo.
6. **A11y:** con TalkBack/VoiceOver, ¿se narran los botones del onboarding y la lección?
7. **Combo/hito:** completa una lección con muchos aciertos / llega a racha 7 → ¿hay feedback visible?

---

## 6. VEREDICTO DE FLUJO (recorrido del usuario nuevo)

El recorrido **onboarding → primer aprendizaje engancha** y está por encima del promedio de apps de su
tipo: el onboarding es lineal y cada paso aporta; el **placement + pantalla de resultado + "tu plan" con
fecha honesta** es un momento motivacional fuerte y ahora CREÍBLE (no "2 semanas a C1"); el loop tiene
feedback inmediato, repaso de errores pedagógico y recompensa. La degradación con gracia (audio/imagen)
evita pantallas rotas.

**Dónde se confundiría / se frustraría un usuario nuevo:**
1. **Idioma (fricción temprana):** elige "English" y todo sigue en español → desconcierto en el paso 1.
2. **Misión inicial sin recompensa:** primer nodo del viaje sin XP y sin explicación.
3. **Congelador inútil:** paga 50 oro por proteger su racha y la pierde igual → sensación de estafa.
4. **Sin celebración de hitos/combo en vivo:** el esfuerzo no siempre se "siente" recompensado en el momento.
5. **Racha basada en meta de XP diaria:** con 10 min/día la meta es baja y se cumple; pero si sube su meta,
   la relación esfuerzo↔racha puede no ser evidente (falta comunicar "vas 27/30 XP hoy").

**Top 5 mejoras de mayor impacto (para misiones futuras):**
1. **Arreglar el congelador (P0)** — que consuma freeze y proteje la racha (o quitar la compra).
2. **Decidir el idioma (P1)** — implementar i18n real o dejar el selector honesto (solo es por ahora).
3. **Aclarar/recompensar la misión inicial (P1)** — cartel o XP simbólico.
4. **Momentos de celebración** — cartel de hito de racha + contador de combo en vivo + animar el saldo de oro.
5. **Comunicar la meta diaria** — barra "X/Y XP hoy" visible para que la racha se entienda.

**Conclusión:** GO para seguir en beta. Ningún P0 bloquea el aprendizaje (el loop y la progresión
funcionan y son seguros); el P0 del congelador afecta economía/retención y debe ir primero, seguido de la
decisión de idioma. El resto es pulido que elevaría notablemente la sensación de calidad.

---

## 7. Notas de método / limitaciones
- Verificación en vivo con usuario JWT real creado y borrado (`verify_qa_probe.py`, `smoke_client_queries.py`,
  `verify_estimator.py`, `sweep_resources.py`), nunca `service_role` para chequeos de cliente.
- Lo visual/animaciones/STT/lectores de pantalla **requieren device** (marcado arriba).
- Claims de agentes descartados por no verificarse: "reinforce_unit no cableado" (SÍ pasa `p_unit`),
  "racha 0 el día 1" (artefacto de la sonda con `start_course`; un usuario onboarded con 10 min/día sí
  inicia racha), "bug en el ORDER BY de tips" (el propio agente lo desmintió). No se incluyen.
