# Jezici — Auditoría de UX / ESTÉTICA / DINAMISMO (solo lectura)

> **Fecha:** 2026-06-23 · CERO cambios de código. Énfasis del dueño: **DINAMISMO**.
> Inventario objetivo (conteos, tokens fuera de sistema, estados y motion faltantes).
> Lo subjetivo va marcado **[DECISIÓN DEL DUEÑO]**.

## Veredicto en una línea
Base estética **sólida** (paleta semántica, Nunito, jerarquía clara, mascota y confeti
bien hechos), pero **el dinamismo está a medias**: el *feedback del loop* (acierto/error,
recompensas, transiciones) es estático y **sin háptica**. Y el sistema de diseño existe
pero **no se respeta de forma consistente** (espaciado/radios casi siempre hardcodeados).

---

## 1. SISTEMA DE DISEÑO — ¿tokens o ad-hoc? (MEDIDO)
Existe un sistema real: `core/theme/app_colors.dart` (paleta semántica), `app_spacing.dart`
(escala 4/8 + radios), `app_theme.dart` (Material3 + `GoogleFonts.nunito` + helpers de texto).
**Pero la adopción es despareja:**

| Token | Adopción | Hallazgo |
|---|---|---|
| `AppColors.*` | **748 usos** ✓ | buena… pero conviven **212 `Color(0x…)` hardcodeados** fuera de la paleta |
| `AppSpacing.*` / `AppRadius.*` | **9 usos** 🔴 | prácticamente **sin usar**: paddings y radios se escriben a mano en toda la app |
| Radios `BorderRadius.circular(n)` | literales | n más usados: **16(×37), 18(×36), 14(×34), 20(×25), 12(×25), 13(×17), 11(×14)** → muchos **fuera de la escala** (la escala es 12/16/20/24/pill; 11/13/14/18/22 son ad-hoc) |

- **Colores fuera de paleta (top archivos):** `lesson_complete_screen.dart` (14), `profile_screen.dart` (13),
  `checkpoint_result_screen.dart` (11), `lesson_player_screen.dart` (8), `learn_top_bar.dart` (8),
  `leagues_screen.dart` (8). Ej. recurrentes: `0xFFEDEFF7`, `0xFFECEDF6`, `0xFFF0F1F8` (grises de borde/sombra),
  `0xFFCD9B6A`/`0xFFB07B45` (gradiente bronce de ligas).
- **Tipografía:** sí centralizada en Nunito (theme), pero los tamaños/pesos se repiten inline por pantalla
  (11/12/13/13.5/14/14.5/15/18/20/22/23/26/28) en vez de estilos nombrados → jerarquía correcta pero no tokenizada.
- **Dirección propuesta:** completar `AppColors` con los grises de borde/sombra y los gradientes de división;
  migrar paddings/radios a `AppSpacing`/`AppRadius`; definir `TextStyles` nombrados (h1/h2/title/label/body).
  *No es bug; es deuda de consistencia que facilita el rediseño dinámico.*

---

## 2. MOTION / DINAMISMO (lo que pidió el dueño) — inventario
**Presente y bueno (modelo a seguir):**
- `ParrotMascot` con 3 estados (idle/celebrate/encourage) vía `AnimationController`+`Transform` y respeta
  reduce-motion (`parrot_mascot.dart:94-121`). **Pero solo aparece en mapa y fin de lección.**
- Confeti (`confetti`) en fin de lección (`lesson_complete_screen.dart:81-96`) y certificado (`certificate_screen.dart:148-156`).
- Pulso del nodo disponible en el mapa (`map_node.dart:39-60,189-209`).
- `AnimatedContainer` en chips de onboarding (`onboarding_screen.dart:404`) y en el segmento de Ligas (`leagues_screen.dart`).

**FALTANTE (alto impacto en "sentirse vivo"):**
| Gap | Dónde | Detalle |
|---|---|---|
| **Feedback ✅/❌ sin animación visual** | `lesson_player_screen.dart:144-162` + `exercises/*` | acierto/error cambian color **instantáneo**; sin pop/scale/shake. Solo suena SFX. |
| **CERO háptica en toda la app** | ningún `HapticFeedback.*` en ejercicios/nodos/recompensas | crítico en móvil; el `speaking_exercise` es el único que vibra |
| **Transiciones de pantalla genéricas** | ~**35 `MaterialPageRoute`, 0 `PageRouteBuilder`** | nodo→preview→lección y todas las navegaciones son el slide por defecto |
| **Recompensas sin "jugo"** | `lesson_complete_screen.dart:136-159,219` | `+XP`/oro aparecen como número plano (sin contador animado); racha 🔥 sin pulse; tiles sin entrada escalonada |
| **Combo sin visual** | `lesson_player_screen.dart:151-152` | combo ≥3 solo suena; sin "¡x3!" animado |
| **Radar de skills estático** | `skill_radar.dart:42-45,148-150` | `CustomPaint` sin animación de entrada/cambio; al subir una skill el polígono salta |
| **Mascota ausente** | resto de pantallas | no acompaña en onboarding, checkpoint/examen aprobado, sin-vidas |
| **Estados de carga = spinner pelado** | ~27 `CircularProgressIndicator`, 0 skeletons | sin shimmer/placeholder |

---

## 3. POR PANTALLA (inventario)
> Densidad de texto (D), Emojis (E), Estados (carga/vacío/error), Motion faltante (M).

- **Splash** (`main.dart:172-199`): D baja ✓ · E: 🦜 ·  Estados: carga/error ✓ · M: spinner pelado, sin entrada animada.
- **Onboarding** (`onboarding_screen.dart`): D **alta en bienvenida** (~párrafo de ~85 palabras, `:205-211`) → acortar · E: banderas 🇪🇸🇬🇧🇧🇷 (etiquetas, OK) · M: transición entre pasos por `setState` sin animación; sin mascota.
- **Mapa** (`learn_map_screen.dart`, `map_node.dart`, `parrot_mascot.dart`): D baja ✓ · E: 🦜💪⛰ · Estados ✓ · **Motion el mejor de la app** (pulso nodo + mascota). Falta: pop/escala al pulsar nodo (`map_node.dart:135-137` solo cambia sombra), háptica.
- **Tarjeta de lección** (`lesson_preview_screen.dart`): D media · E: 0 · Estados ✓ · M: **nada** (sin fade-in, botón sin feedback).
- **Lección** (`lesson_player_screen.dart` + `exercises/`): **EL HUECO MÁS GRANDE** · feedback ✅/❌ sin visual ni háptica; transición ítem→ítem instantánea; combo sin visual.
- **Fin de lección** (`lesson_complete_screen.dart`): D controlada · E: 🦜⚡🏆🔥 (4) · Motion: confeti+mascota ✓ pero **recompensas sin contador** ni entrada escalonada; racha sin pulse.
- **Sin vidas** (`no_hearts_sheet.dart`): D **alta** (~50 palabras, `:61-71`) → acortar · E: ❤️ · M: corazones estáticos (podrían pulsar).
- **Practicar** (`practice_screen.dart`): D ok · E: 🔁🎯🔧⏱️ (títulos de cards) · M: cards sin entrada; loading instantáneo.
- **Checkpoint / Examen** (`checkpoint_intro_screen.dart`, `level_exam_intro_screen.dart`): D media (~50 palabras) · E: 🎓 · M: portal/escudo **estático** (sin glow/pulse); botón sin animación; sin mascota en aprobado.
- **Certificado** (`certificate_screen.dart`): D mínima ✓ · confeti ✓ · M: entra sin fade-in.
- **Ligas** (`leagues_screen.dart`): D ajustada ✓ · E: 🏆 · Estados ✓ (incl. "arrancando") · M: segmento animado ✓ pero filas/rankings sin feedback al tocar ni pulse en top-3; cambio de segmento sin transición de contenido.
- **Perfil** (`profile_screen.dart`, `skill_radar.dart`): D ok · E: varios en "Para ti" [DECISIÓN DEL DUEÑO] · M: **radar estático**, badges/stats sin entrada; (además rebuild ancho, ver PERF_AUDIT P1-4).
- **Ajustes** (`settings_screen.dart`): D ok · E: 0 · M: toggles/selector sin animación (aceptable).

**Emojis totales:** ~22 instancias, **sin exceso** [DECISIÓN DEL DUEÑO si reducir a iconos].
Iconografía: coherente (Material `Icons.*` para acciones; emojis para mood/decoración).

---

## 4. ESTADOS (carga / vacío / error)
- **Carga:** spinner genérico en casi todas (mapa y lección-preview tienen texto acompañante; el resto pelado). **0 skeletons.**
- **Error:** patrón decente y repetido (icono `cloud_off` + texto + "Reintentar") en mapa, ligas, preview ✓.
- **Vacío:** parcial — ligas tiene "arrancando" ✓ y leaderboard "aún no hay datos" ✓; práctica/perfil sin estado vacío dedicado.
- **Dirección:** componente `Skeleton`/`EmptyState` reutilizable; aplicarlo a mapa, ligas y perfil.

---

## 5. TOP 10 cambios de MAYOR impacto visual/dinámico por esfuerzo
1. **Háptica global** en acierto/error/combo/tap de nodo (`HapticFeedback.*`). *Esfuerzo: bajo · impacto: alto.*
2. **Feedback ✅/❌ con pop/shake** (AnimatedScale en la opción correcta; shake en error). *Bajo-medio · alto.*
3. **Contador animado de recompensas** (`TweenAnimationBuilder` 0→XP/oro) + entrada escalonada de tiles + pulse de racha. *Medio · alto.*
4. **Transiciones de pantalla** con `PageRouteBuilder` (fade/slide jugoso) para nodo→preview→lección. *Bajo-medio · alto.*
5. **Skeletons** en mapa/ligas/perfil en vez de spinner. *Medio · medio-alto (percepción).*
6. **Mascota en más momentos** (onboarding final, checkpoint/examen aprobado, sin-vidas). *Bajo (ya existe) · alto.*
7. **Radar animado** (Tween de los puntos del polígono al entrar/cambiar skill). *Medio · medio.*
8. **Pop/escala al pulsar nodo** del mapa + glow del portal de checkpoint/examen. *Bajo · medio.*
9. **Tokenizar espaciado/radios** (migrar a `AppSpacing`/`AppRadius`, sumar grises a `AppColors`) → base para un look uniforme. *Medio · medio (consistencia).*
10. **Acortar microcopy** denso (onboarding bienvenida, sin-vidas) a 1 línea estilo Duolingo. *Bajo · medio.* [DECISIÓN DEL DUEÑO]

> El **80% de la sensación "viva"** que falta está en los puntos 1–4 (todos en el loop de lección/recompensa).
