# RESPONSIVE_AUDIT.md — estado responsive por pantalla (2026-07-11)

> Auditoría + fix de TODAS las pantallas antes del **lanzamiento público** (dominio propio +
> LinkedIn → entra gente de móvil, tablet y desktop ancho). **Patrón único:** `ResponsiveCenter`
> (`core/ui/responsive_center.dart`) — `Align(topCenter)` + `ConstrainedBox(maxWidth)`: en móvil
> (ancho ≤ maxWidth) **no hace nada** (layout móvil pixel-idéntico); en anchos grandes **centra y
> limita** el ancho para no estirar de borde a borde. Sin breakpoints mágicos. **Anchos por tipo:**
> **480** una-columna/formulario/celebración · **520** certificado · **560** listas/hubs · **640**
> lectura/contenido ancho (perfil, ligas, tienda, inmersión, story, chat). **Cero cambios de lógica.**

## Convención de anchos
| Tipo de pantalla | maxWidth |
|---|---|
| Formulario / celebración / una columna (lección fin, preview, misión, examen intro, mi plan, premium, simulacros) | **480** |
| Certificado ceremonial | **520** |
| Listas / hubs / players (checkpoint/examen player+result, error review, notebook, métricas, referencia, streak, notificaciones, conversar hub+práctica, amigos) | **560** |
| Contenido ancho / lectura (perfil, ligas, tienda, inmersión, story reader, chat) | **640** |
| Sheet SinVidas (bottom sheet) | **440** |
| Mapa (full-bleed por diseño) | fondo full-width + **columna de nodos** centrada a **430** (LayoutBuilder/dx0) |

## Matriz pantalla × comportamiento (después del fix)
| Pantalla | Antes | Ahora | maxWidth |
|---|---|---|---|
| Login/Auth | ✅ ya RC | ✅ | 460 |
| Onboarding (bienvenida/pasos/resultado) | ✅ ya RC (OnboardingScaffold) | ✅ | 480 |
| Course placement (test ubicación) | ✅ vía OnboardingScaffold | ✅ | 480 |
| Mapa (Aprender) | ✅ full-bleed + columna centrada | ✅ (verificado intacto) | fondo full / col 430 |
| Misión inicial | ❌ se estiraba | ✅ RC (ListView + botón) | 480 |
| Lección — player + 9 ejercicios | ✅ ya RC | ✅ | 560 |
| Lección — preview | ❌ se estiraba + Row de chips → **Wrap** | ✅ RC | 480 |
| Lección — fin (celebración) | ❌ se estiraba | ✅ RC (header full-bleed intacto) | 480 |
| Lección — repaso de errores | ❌ se estiraba (lista + barra) | ✅ RC (ambas) | 560 |
| Práctica (hub) | ✅ ya RC | ✅ | 480 |
| Práctica — player + summary | ✅ (dentro del loop RC) | ✅ | 560 |
| Conversar — hub (situaciones + amigos) | ❌ se estiraba | ✅ RC (**header full-bleed** intacto, grid 2col) | 560 |
| Conversar — práctica de situación | ❌ se estiraba | ✅ RC | 560 |
| Conversar — Amigos / Chat / Co-op | ✅ ya RC (rediseño 2026-07-11) | ✅ | 560 / 640 |
| Perfil | ✅ ya RC | ✅ | 640 |
| Ligas + leaderboards | ✅ ya RC | ✅ | 480/640 |
| Checkpoint — intro | ❌ se estiraba | ✅ RC (escena full-bleed intacta) | 480 |
| Checkpoint — player | ✅ ya RC | ✅ | 560 |
| Checkpoint — resultado | ❌ se estiraba | ✅ RC (header full-bleed intacto) | 560 |
| Examen — intro | ❌ se estiraba | ✅ RC | 480 |
| Examen — player | ❌ se estiraba | ✅ RC | 560 |
| Examen — resultado | ✅ ya RC | ✅ | 560 |
| Certificado | ❌ tarjeta gigante en desktop | ✅ RC (tarjeta acotada) | 520 |
| Ajustes | ✅ ya RC | ✅ | 480 |
| Tienda | ✅ ya RC | ✅ | 640 |
| Cofre (reveal) | ✅ ya RC | ✅ | 440 |
| SinVidas (sheet) | ❌ sheet full-width en desktop | ✅ RC (contenido centrado) | 440 |
| Notificaciones | ❌ se estiraba | ✅ RC | 560 |
| Notebook (cuaderno) | ❌ se estiraba | ✅ RC | 560 |
| Referencia / Repaso | ❌ se estiraba (2 estados) | ✅ RC (ambos) | 560 |
| Mi Plan (dashboard) | ❌ se estiraba | ✅ RC | 480 |
| Inmersión (hub historias) | ✅ ya RC | ✅ | 640 |
| Story reader (lectura/preguntas/resultado) | ❌ se estiraba (3 fases) | ✅ RC (body entero) | 640 |
| Premium / Paywall | ❌ se estiraba | ✅ RC | 480 |
| Simulacros | ❌ se estiraba | ✅ RC | 480 |
| Racha (streak) | ❌ hero full-width en desktop | ✅ RC | 560 |
| Métricas (admin) | ❌ se estiraba + `_row` sin Expanded | ✅ RC + `_row` Expanded | 560 |
| Placeholder | N/A (ya centrado, `Center`) | ✅ sin cambio | — |
| Legal | N/A (sin UI; abre página web pública) | — | — |

## Overflow horizontal en móvil (~390px) — arreglados
- **Lección preview:** el `Row` de 2 chips (nº de ejercicios + XP) sin `Wrap` podía desbordar con
  localizaciones largas → convertido a **`Wrap`** (spacing/runSpacing, center).
- **Métricas:** el helper `_row` (etiqueta + valor con `spaceBetween`) sin `Expanded` desbordaba con
  etiquetas largas → **`Expanded`** en la etiqueta + `SizedBox` de separación.
- El resto usa `Expanded`/`Wrap`/`Flexible` correctamente (auditado, sin overflow en 390px).

## Teclado móvil no tapa inputs
- Todos los `TextField` viven dentro de `ListView`/`SingleChildScrollView` scrollable → el teclado
  desplaza el contenido. Verificado: chat (composer), Conversar práctica (respuesta), Conversar
  interés (waitlist), login/onboarding, story cloze, agregar amigo por código.

## Verificación
- **analyze 0** (CI-exact, `.env` vacío) · **test 149/149** · **build web OK**.
- **Golden desktop 1400px** (verificado y borrado): Conversar hub → header full-bleed + contenido
  centrado ~560 (grid 2col); Conversar práctica → tarjetas centradas ~560. Sin estiramiento ni
  franjas vacías desbalanceadas.
- **Cómo probar (Gian):** abrir `jezici.vercel.app` en el **móvil** (todo pixel-idéntico a antes) y
  en **desktop**, y **redimensionar el navegador** de ancho: el contenido se centra con márgenes
  simétricos y ancho máximo sensato; el mapa y los headers de gradiente siguen llenando el ancho, y
  la columna de contenido queda centrada. En **tablet** (~768px) el contenido se centra sin estirarse.
