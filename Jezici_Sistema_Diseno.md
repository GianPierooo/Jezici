# Jezici — Sistema de Diseño / Dirección Visual (v1.0)

> Fuente de verdad del lenguaje visual, para construir en Flutter de forma consistente. Consolida lo definido y validado en los mockups de Claude Design. Los **tokens finales** (colores/medidas exactas) se afinan contra los mockups.

---

## 1. Identidad

- **Concepto:** "el viaje hacia la fluidez" — un **mapa ascendente** que se sube hacia la meta. Aventura, ascenso, logro.
- **Mascota:** **guacamayo escarlata** (esbelto, rojo, colorido, de los que repiten). Compañero de viaje que reacciona (acierto, error, racha, ánimo).
- **Personalidad de marca:** vibrante y motivadora, pero con un lado **serio y orgulloso** en el certificado.
- **Regla:** original, **NO Duolingo** (nada de camino vertical de círculos planos ni paleta verde).

---

## 2. Paleta

| Rol | Color | Uso |
|---|---|---|
| Primario | `#6C5CE7` violeta | Acciones, marca, énfasis |
| Acento | `#FF6B6B` coral | Destacados, secundarios |
| Oro / XP | `#FFC93C` dorado | Moneda (oro), XP, recompensas |
| Éxito | `#2ECC71` verde | Aciertos, completado |
| Racha | `#FF7A00` naranja | Fuego/racha |
| Vidas | `#FF4D6D` rojo | Corazones |
| Fondo | `#F5F6FB` gris claro | Fondo de app |
| Tarjeta | `#FFFFFF` | Superficies |
| Texto | `#1A1A2E` | Texto principal |

> Mantener semántica consistente: verde = correcto, rojo = error/vidas, dorado = oro/XP, naranja = racha.

---

## 3. Tipografía

- **Familia:** sans geométrica redondeada (Nunito o Poppins).
- **Escala:** Display (números grandes, XP) extrabold · H1 bold · H2 semibold · Body regular · Caption.
- Números y títulos de recompensa en peso fuerte.

---

## 4. Forma y espaciado

- **Esquinas redondeadas** (radius generoso: botones/cards ~16–20px).
- **Profundidad:** sombras suaves, sensación ilustrada y con relieve (no flat).
- **Escala de espaciado:** múltiplos de 4/8.
- **Iconografía:** redondeada, consistente; la **tab bar es solo de íconos** (sin texto).

---

## 5. Componentes

- **Botón primario:** violeta, grande, redondeado, con "profundidad" (estilo botón jugoso). Estados: normal/presionado/deshabilitado.
- **Botón secundario:** contorno o tono claro.
- **Cards:** blancas, sombra suave, esquinas redondeadas.
- **Nodos del mapa:** hitos con 4 estados — bloqueado (gris) / disponible (vivo, resaltado, anillo) / completado (color, check) / dorado (brillante).
- **Barras de progreso:** meta diaria, plan, avance de nivel — coloreadas por contexto.
- **Tab bar inferior:** 5 íconos (Aprender, Practicar, Conversar, Ligas, Perfil), sin texto.
- **Chips/badges:** etiqueta de habilidad, insignias de nivel, verificado.
- **Radar de 4 habilidades:** componente de Perfil/examen.
- **Inputs y modales:** redondeados, consistentes.
- **Mascota:** set de estados (feliz, ánimo, triste/empático, celebración).

---

## 6. Animaciones y microinteracciones

- Feedback inmediato: ✅ verde / ❌ rojo, sonido, **vibración háptica**.
- **Recompensa:** confeti, brillos, mascota festejando, cofres que se abren.
- Transiciones jugosas pero rápidas (no entorpecer el loop).

---

## 7. El certificado (contraste)

- Tono **formal, premium y orgulloso** — contrasta con lo lúdico para transmitir logro real. Sello/emblema, tipografía más sobria, folio visible.

---

## 8. Accesibilidad

- Contraste suficiente texto/fondo; tamaños tocables ≥ 44px; no depender solo del color (íconos + texto en estados clave).

---

## 9. Para el build (Flutter)

- Definir un **ThemeData** con esta paleta, tipografía y radios.
- Componentes reutilizables: `PrimaryButton`, `MapNode`, `ProgressBar`, `SkillRadar`, `RewardSheet`, `MascotView`.
- **Extraer los tokens exactos de los mockups** (`mockups/`) y fijarlos aquí como referencia única.
