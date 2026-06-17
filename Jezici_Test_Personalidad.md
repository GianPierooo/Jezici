# Jezici — Test de Personalidad (v0.2 · GA4)

> Las preguntas del onboarding que clasifican al usuario en un **estilo de coach** para el motor Matix. Corto, rápido y SIN redundancia: cada pregunta es una **situación distinta** (no variantes de la misma). Se guarda en `user_personality` (`coach_style` + `intensity`).

---

## 1. Objetivo

Clasificar al usuario en uno de **4 estilos** (mano dura · positivo · rezago · suave) y una **intensidad** inicial. Cada pregunta de estilo presenta la MISMA situación bajo los 4 estilos; el usuario elige el que le resuena. Gana el estilo dominante. La intensidad sale de una pregunta aparte. Todo **recalibrable** en Ajustes.

**Leyenda de mapeo:** MD = mano dura · PO = positivo · RE = rezago · SU = suave.

---

## 2. Preguntas (4 de estilo, situaciones DISTINTAS + 1 de intensidad)

Antes había 6 preguntas de estilo con solapamientos (P1≈P5 sobre el tipo de empujón; P2≈P6 sobre el fallo). Se reducen a **4 situaciones distintas**, cada una cubriendo las 4 dimensiones:

**P1 (FALLO). Si fallas tu meta del día, ¿qué prefieres oír?**
- a) "Sin excusas. Retómalo ya." → **MD**
- b) "¡Mañana lo das todo, tú puedes! 💪" → **PO**
- c) "Vas quedando atrás de tu plan, recupéralo." → **RE**
- d) "Tranqui, cuando puedas seguimos 🙂" → **SU**

**P2 (EMPUJÓN). ¿Cómo te gusta que te motivemos a practicar?**
- a) Firme y directo → **MD**
- b) Con energía y celebración → **PO**
- c) Recordándome mis metas y mi avance → **RE**
- d) Suave, sin presión → **SU**

**P3 (COMPETENCIA). En la liga alguien te supera. ¿Qué te activa?**
- a) Que me reten a recuperarme → **MD**
- b) Ánimo para subir posiciones → **PO**
- c) Ver cuánto me falta para alcanzarlo → **RE**
- d) Nada, voy a mi ritmo → **SU**

**P4 (LOGRO). Cuando logras algo, ¿qué mensaje disfrutas más?**
- a) "Bien. Ahora el siguiente reto." → **MD**
- b) "¡Increíble, eres imparable! 🎉" → **PO**
- c) "Vas adelantado a tu plan." → **RE**
- d) "Qué bien, sigue a tu ritmo 🙂" → **SU**

**P5 (intensidad — dimensión aparte). ¿Qué tan seguido quieres que te recordemos?**
- a) Mucho, no me dejes aflojar → **intensidad alta (3)**
- b) Lo justo → **intensidad media (2)**
- c) Poco → **intensidad baja (1)**

---

## 3. Scoring

- P1–P4: cada respuesta suma **1 punto** a su estilo (MD/PO/RE/SU).
- **Estilo asignado = el de mayor puntaje.** Empate → preferir **SU** (default seguro, menos agresivo).
- P5 define la **intensidad** (alta/media/baja), independiente del estilo.
- Guardar `coach_style` + `intensity` en `user_personality`. **Recalibrable** en Ajustes.

---

## 4. Notas

- **5 preguntas en total** (4 estilo + 1 intensidad) — más corto y sin repetición que la v0.1 (7).
- Cada pregunta proba una **situación distinta** (fallo, empujón, competencia, logro) → mejor discriminación con menos preguntas.
- El estilo solo cambia el **tono** de Matix; la intensidad, la **frecuencia/escalado** (respetando techo y `quiet_hours`).
- (Fase 2) se podrá ajustar el estilo según comportamiento real.
