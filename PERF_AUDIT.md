# Jezici — Auditoría de RENDIMIENTO (solo lectura)

> **Fecha:** 2026-06-23 · **Build vivo:** `b34b568` (jezici.vercel.app) · CERO cambios de código.
> **Método:** medición de artefactos (`build/web`), del bundle servido (prod), e
> inventario estático de RPC-por-pantalla y patrones de jank. Lo que requiere perfilado
> interactivo se marca **[MÉTODO]** para que el dueño lo corra con DevTools.

## Mediciones base (hechas)
| Métrica | Valor | Nota |
|---|---|---|
| `main.dart.js` | **3.45 MB** sin comprimir | servido con **brotli** (`Content-Encoding: br`) → ~0.8–1.1 MB en red |
| Renderer | **CanvasKit** (`buildConfig: dart2js + canvaskit`) | NO hay HTML renderer (removido en Flutter moderno); en runtime baja CanvasKit |
| CanvasKit wasm | de `gstatic.com/flutter-canvaskit/<rev>` | ~variante `chromium` en Blink (más liviana); **`full` en Safari/iOS** (más pesada) |
| Tree-shaking iconos | **ACTIVO** | MaterialIcons 1.6MB→21KB (98.7%), Cupertino 257KB→1.5KB (build log) |
| `assets/` (bundle) | 1.6 MB | incluye 7 SFX `.wav` = **157 KB** (sin comprimir; WAV, no mp3) |
| canvaskit local en `build/web/canvaskit` | 37 MB en disco | NO se sirve entero; el loader baja solo la variante elegida desde gstatic |

---

## TOP OFFENDERS (rankeados)

### 🔴 P0-1 — Contenido estático del curso se re-pide en cada arranque (sin caché en disco)
- **Evidencia:** `mapUnitsProvider`→`fetchUnits(courseId)`, `lessonItemsProvider`→`fetchLessonItems`,
  `getLessonTip` son **FutureProviders en memoria** (Riverpod) — se pierden al cerrar la PWA.
  No se usa `shared_preferences` (ya es dependencia) para cachear contenido. (`data/providers.dart:52,58`; `content_repository.dart:16,32`).
- **Causa:** el contenido del curso (unidades, lecciones, ítems, tips) es **inmutable entre
  releases** pero se trae por red en cada cold-start y al navegar al mapa.
- **Impacto:** cada apertura del mapa = 3 RPC (`get_courses`+`fetch_units`+`lesson_progress`);
  cada lección = `fetchLessonItems`. En 3G/wifi débil esto es el lag de "abrir y esperar".
- **Fix propuesto:** caché en disco (`shared_preferences`) de `units`/`items`/`tips` con clave
  `courseId` + invalidación por versión de contenido (un `content_version` en DB o el commit sha).
  Patrón Duolingo: contenido local, solo refresca progreso/dinámico por red.
- **Ganancia estimada:** mapa y lección **~instantáneos** en aperturas repetidas; corta 3–4 RPC del cold path.

### 🔴 P0-2 — Invalidaciones de Riverpod en cascada (ráfagas de RPC)
- **Evidencia (verificada):** `settings_screen.dart:516-525` **cambiar curso = 10 `invalidate`**,
  incluido `mapUnitsProvider` que **ya depende** de `activeCourseIdProvider` (redundante: al invalidar
  el courseId, el de units se recalcula solo). También 5 al borrar/cambiar cuenta, 4 en logout.
- **Causa:** invalidar providers derivados además del padre → doble recálculo + RPC repetidos.
- **Impacto:** cambiar de curso dispara ~10 RPC casi simultáneos → spinner largo y posible jank.
- **Fix propuesto:** invalidar solo las **raíces** (`activeCourseIdProvider`, `lessonProgressProvider`,
  los dinámicos por usuario) y dejar que los derivados (`mapUnitsProvider`, `skillMasteryProvider`)
  se recomputen por dependencia. Reduce de ~10 a ~4–5 RPC.
- **Ganancia estimada:** ~50% menos RPC en cambio de curso; menos rebuilds.

### 🟠 P1-3 — Arranque dominado por CanvasKit (peor en iOS)
- **Evidencia:** renderer canvaskit; el loader baja `canvaskit.wasm` desde gstatic en el primer paint.
  En Blink usa variante `chromium` (más chica); en **Safari/iOS usa `full`** (varios MB).
- **Causa:** Flutter web con CanvasKit; el SW propio (`web/sw.js`) cachea el shell pero **no** el
  canvaskit cross-origin de gstatic → cada dispositivo lo baja al menos una vez.
- **Impacto:** TTI (time-to-interactive) del primer arranque, sobre todo iOS/gama baja.
- **[MÉTODO] confirmar:** DevTools → Network, recarga sin caché: medir tamaño y tiempo de
  `canvaskit.wasm`/`skwasm*.wasm` y el gap hasta el primer frame. Repetir en iOS Safari real.
- **Fix posible (acotado):** gstatic ya es CDN compartido (cacheado entre sitios); margen real =
  precargar/`<link rel=preload>` canvaskit o cachearlo en el SW. No hay "HTML renderer" alternativo.
- **Ganancia estimada:** media en primer load; nula en cargas ya cacheadas.

### 🟠 P1-4 — `ProfileScreen`: rebuild ancho + cómputo en `build()`
- **Evidencia (verificada):** `profile_screen.dart:69-99` hace **9 `ref.watch`** (stats, profile,
  skills, skillMastery, userPlan, achievements, certs, levelExamStatus, planTracking) y **ordena**
  (`[...mastery.skills]..sort(...)`) y hace `reduce()` min/max dentro del `build`.
- **Causa:** cualquier cambio en cualquiera de los 9 providers reconstruye TODA la pantalla y
  re-ordena listas.
- **Impacto:** jank al entrar a Perfil y en cada refresco (p. ej. tras una lección).
- **Fix propuesto:** `ref.watch(p.select((x)=>campo))` por campo; mover `sort`/`reduce` a un
  Provider derivado memoizado; partir en sub-`Consumer` (radar, badges, stats) para rebuilds locales.
- **Ganancia estimada:** rebuilds locales en vez de full-screen; menos cómputo por frame.

### 🟠 P1-5 — Mapa: O(n²) y recálculo en `build()` (escala mal al scroll)
- **Evidencia:** `learn_map_screen.dart:289-292` calcula `unitLocked` con `.every()` recorriendo
  TODOS los nodos **por cada banner de unidad** (O(n²)); `centers`/`_flatten` se recomputan en build
  (`:241-244`). El mapa es `SingleChildScrollView`+`Stack` con `for` de N nodos (no `ListView.builder`).
- **Causa:** estado de nodo y geometría recalculados en cada build; sin virtualización.
- **Impacto:** hoy el mapa es chico (OK), pero con 100+ lecciones → jank de scroll y memoria lineal.
- **Fix propuesto:** precalcular `Map<unitId, bool> unitLocked` y `centers` una vez (en `_flatten`
  o State) y solo recomputar cuando cambie el progreso. CustomPainters ya tienen `shouldRepaint` correcto.
- **Ganancia estimada:** scroll estable al crecer el contenido; menos trabajo por frame.

### 🟠 P1-6 — Spinners en vez de skeletons (percepción de lentitud)
- **Evidencia:** ~27 usos de `CircularProgressIndicator` pelado; 0 skeletons/shimmer (mapa, lección
  preview, ligas, perfil, ajustes). (Cruce con UX_AUDIT §estados).
- **Impacto:** la espera "se siente" más larga aunque el tiempo real no cambie.
- **Fix propuesto:** skeleton del layout (placeholders gris claro) en mapa, ligas y perfil.
- **Ganancia estimada:** percepción; sin cambio de tiempo real.

### 🟡 P2-7 — `getLessonTip` sin caché (RPC por lección completada)
- **Evidencia:** `lesson_complete_screen.dart:45` llama `getLessonTip(lessonId)` async en `initState`,
  fuera de Riverpod → no se cachea; el mismo tip se re-pide si repites la lección.
- **Fix:** `lessonTipProvider = FutureProvider.family` (cachea por `lessonId`) o incluir el tip en el
  payload de `complete_lesson`.
- **Ganancia:** 1 RPC menos por cierre de lección.

### 🟡 P2-8 — Listas sin builder (grids/columnas)
- **Evidencia:** `profile_screen.dart:328-335` `GridView`/`for` de badges sin `.builder`; columnas de
  ranking (`leagues_screen.dart`) y badges renderizan N de golpe. Hoy N es chico → OK; escala mal.
- **Fix:** `GridView.builder`/`ListView.builder` cuando N pueda superar ~30.

### 🟡 P2-9 — Peso del bundle / SFX en WAV
- **Evidencia:** `main.dart.js` 3.45MB (brotli mitiga); 7 SFX en **WAV** (157KB) que podrían ser
  mp3/ogg (~10–20KB c/u). Tree-shaking ya activo.
- **Fix:** convertir SFX a mp3 (ya hay `audioplayers`); diferir imports no críticos del arranque
  **[MÉTODO]** (analizar con `flutter build web --analyze-size`).

---

## RPC por pantalla al abrir (inventario)
| Pantalla | RPC al cargar | Observación |
|---|---|---|
| AppGate/Splash | `log_event` + `isOnboardingComplete` | OK |
| Mapa (Learn) | `get_courses` + `fetch_units` + `lesson_progress` (3) | units = estático → cachear (P0-1) |
| Lección | `fetchLessonItems` (+`grade_item` por ítem) | items = estático → cachear |
| Fin lección | `getLessonTip` + watch(settings) | tip sin caché (P2-7) |
| Práctica | `fetchPracticeStatus` (1) | OK |
| Ligas | `get_league` / `get_leaderboard` (1 por vista) | OK; family cachea por combinación |
| Perfil | **9 watch** (stats/profile/skills/mastery/plan/achievements/certs/exam/tracking) | rebuild ancho (P1-4) |
| Ajustes | watch(settings)+watch(plan) | invalidaciones de cascada al guardar/cambiar (P0-2) |

## [MÉTODO] Perfilado en vivo (para el dueño)
```bash
cd app
flutter run -d chrome --profile        # luego abrir DevTools → Performance
# 1) Cold start: Network sin caché → tamaño+tiempo de main.dart.js (br) y canvaskit.wasm
# 2) Scroll del mapa con muchos nodos → Frames > 16ms (jank)
# 3) Entrar a Perfil → Widget Rebuild Stats (rebuilds amplios)
# 4) Cambiar de curso en Ajustes → contar RPC en Network (debería bajar tras P0-2)
flutter build web --analyze-size       # desglose del bundle (qué pesa)
```

## Resumen accionable (orden de ataque)
1. **P0-2** quitar invalidaciones redundantes (rápido, alto impacto en cambio de curso).
2. **P0-1** caché en disco del contenido estático (mayor win de "se siente lento al abrir").
3. **P1-4 / P1-5** sacar cómputo de `build()` en Perfil y Mapa.
4. **P1-6** skeletons (percepción).
5. **P2** tips cache, builders, SFX mp3, análisis de bundle.
