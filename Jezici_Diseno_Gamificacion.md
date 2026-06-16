# Jezici — Diseño de Gamificación / Economía (v1.0)

> Valores y reglas concretas de la economía del juego. **Todos los números son valores por defecto, ajustables** (balancear con datos reales). Profundiza Estructura_App §10–11.

---

## 1. Principios de balance

- **Premiar el esfuerzo** (hacer lecciones), no "ser bueno".
- El **oro** debe ser ganable pero **escaso lo suficiente** para que premium/anuncios tengan valor.
- **Nunca castigar** al que batalla (las apuestas y vidas no deben hundir a nadie).
- La práctica da **menos** que una lección nueva (incentiva avanzar en el mapa).

---

## 2. XP

| Acción | XP |
|---|---|
| Lección nueva | 10–20 |
| Práctica / repaso | 5–10 |
| Combo (aciertos seguidos) | +1–5 bonus |
| Completar meta diaria | bonus pequeño |
| Checkpoint aprobado | 30–50 |

- **Meta diaria** configurable (ej. 30 XP).
- **Nivel de jugador:** curva creciente de XP acumulado (ej. nivel n requiere ~n×500 XP), con recompensa al subir (oro/cofre).

---

## 3. Oro 🪙 (moneda)

**Se gana:**
- Completar lección: 5–10 · Combo perfecto: +5 · Checkpoint/examen: 20–50 · Logros: variable · Cofres: 10–100 · Subir de nivel de jugador / liga.

**Se gasta:**
- Streak freeze: ~50 · Recargar vidas: ~30 · Reintento extra de examen: ~100 · Ítems cosméticos/potenciadores: variable.

> Todo movimiento pasa por `gold_transactions` (auditable).

---

## 4. Vidas ❤️

- **5** por defecto. Error en lección resta 1. A 0 → se interrumpe.
- **Regeneración:** 1 vida cada ~30 min (ajustable).
- **Recuperar:** esperar / oro (~30) / **anuncio con recompensa** (gratis, 1 vida).
- **Premium:** vidas ilimitadas.
- **Modo Intenso:** menos vidas (ej. 3).

---

## 5. Racha 🔥

- Días consecutivos cumpliendo la meta diaria.
- **Streak freeze** (cuesta oro ~50): protege 1 día sin actividad.
- **Hitos:** 7 / 30 / 100 / 365 días → recompensa creciente (oro + badge).
- Mensajería Matix refuerza la racha en riesgo.

---

## 6. Ligas 🏆

- Divisiones: **Bronce → Plata → Oro → Zafiro → Rubí → Diamante**.
- Grupos de **~30** por nivel de actividad. Ranking por **XP de la semana**.
- **Reset semanal:** top ~7 ascienden, fondo ~5 descienden.
- Recompensa por terminar en zona alta (oro/cofre) y por ascender de división.

---

## 7. Recompensa variable

- **Cofres** al completar hitos: premio aleatorio (oro, potenciador, freeze). Probabilidades ajustables (ej. 70% oro chico, 25% oro grande, 5% raro).
- **Logros/badges:** del día 1 (primera lección, primera racha) a raros (100 días, examen perfecto, certificar un nivel).

---

## 8. Retos y misiones

- **Reto diario:** "Completa 3 lecciones hoy" → oro.
- **Reto semanal:** "Gana 200 XP esta semana" → cofre.
- **Misiones:** objetivos encadenados con recompensa final (ej. "Domina la Unidad 1").

---

## 9. Dinámicas diferenciales

- **Equilibrar tus 4 skills:** bonus de oro/XP por subir la habilidad más débil ("Sube tu Speaking esta semana").
- **Retos en pareja (co-op):** meta compartida con otro usuario; ambos ganan al completarla (oro + badge). Reemplaza el duelo competitivo.
- **Apostar oro en tu meta (opcional, suave):** apuestas ej. 50 de oro a cumplir tu racha/meta semanal; si lo logras ganas el doble; si no, pierdes lo apostado. **Topes bajos**, opt-in, framing de impulso (no castigo).

---

## 10. Modo Intenso (opt-in)

- Más lecciones/día obligatorias, **menos vidas**, **sin freeze**, notificaciones más fuertes (estilo mano dura). Para quienes quieren presión real.

---

## 11. Para el build

- Centralizar la economía en config (valores como parámetros).
- `gold_transactions` para auditar; jobs semanales para ligas; resolución de `wagers` en su fecha.
- Medir con analítica: efecto de cada mecánica en retención (no asumir).
