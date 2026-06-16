# Jezici — Test de Personalidad (v0.1 borrador)

> Las preguntas del onboarding (paso 8) que clasifican al usuario en un **estilo de coach** para el motor Matix. Corto, rápido y divertido. Borrador para afinar. Se guarda en `user_personality` (y opcionalmente las respuestas en `personality_test_responses`).

---

## 1. Objetivo

Clasificar al usuario en uno de **4 estilos** (mano dura · positivo · rezago · suave) y una **intensidad** inicial. Cada respuesta suma puntos a uno o más estilos; gana el dominante. La intensidad sale de una pregunta aparte. Todo **recalibrable** en Ajustes.

**Leyenda de mapeo:** MD = mano dura · PO = positivo · RE = rezago · SU = suave.

---

## 2. Preguntas (6 de estilo + 1 de intensidad)

**P1. Cuando no cumples una meta, ¿qué te funciona más?**
- a) Que me lo digan sin rodeos → **MD**
- b) Que me animen a retomar con energía → **PO**
- c) Que me recuerden lo que me estoy perdiendo → **RE**
- d) Que me lo tomen con calma → **SU**

**P2. Tu racha está en riesgo. ¿Qué mensaje prefieres recibir?**
- a) "Eso no va. Vuelve ya." → **MD**
- b) "¡No rompas la magia, tú puedes! 💪" → **PO**
- c) "Vas quedando atrás de tu plan." → **RE**
- d) "Cuando puedas, una lección rápida 🙂" → **SU**

**P3. Cuando alguien de tu liga te pasa, sientes…**
- a) Ganas de que me exijan más → **MD**
- b) Motivación para subir → **PO**
- c) Que tengo que recuperar terreno ya → **RE**
- d) Nada, voy a mi ritmo → **SU**

**P4. ¿Qué frase te mueve más?**
- a) "No hay excusas." → **MD**
- b) "¡Vas increíble, sigue!" → **PO**
- c) "Estás quedando atrás." → **RE**
- d) "Paso a paso se llega." → **SU**

**P5. ¿Cómo prefieres que te empujemos a estudiar?**
- a) Firme y directo → **MD**
- b) Con energía y celebración → **PO**
- c) Recordándome mis metas y mi avance → **RE**
- d) Suave, sin presión → **SU**

**P6. Si fallas varios días seguidos, ¿qué prefieres?**
- a) Un llamado de atención claro → **MD**
- b) Un mensaje que me reanime → **PO**
- c) Ver cuánto me alejé de mi meta → **RE**
- d) Una invitación amable a volver → **SU**

**P7 (intensidad). ¿Qué tan seguido quieres que te insistamos?**
- a) Mucho, no me dejes aflojar → **intensidad alta**
- b) Lo justo → **intensidad media**
- c) Poco → **intensidad baja**

---

## 3. Scoring

- P1–P6: cada respuesta suma **1 punto** a su estilo (MD/PO/RE/SU).
- **Estilo asignado = el de mayor puntaje.** Empate → preferir el de la P1 (la más directa sobre motivación) o preguntar una de desempate.
- P7 define la **intensidad** (alta/media/baja), independiente del estilo.
- Guardar `coach_style` + `intensity` en `user_personality`. Mostrar al final: "Tu coach será [estilo]" con opción de cambiarlo.

---

## 4. Notas

- Mantenerlo **corto** (6–7 preguntas) y con copy ligero — es onboarding, no un test clínico.
- El estilo solo cambia el **tono** de Matix; la intensidad, la **frecuencia/escalado** (respetando el techo y los horarios).
- **Recalibrable** en Ajustes en cualquier momento.
- (Fase 2) se puede ajustar el estilo según comportamiento real (ej. si el mano dura genera abandono en alguien, suavizar).
