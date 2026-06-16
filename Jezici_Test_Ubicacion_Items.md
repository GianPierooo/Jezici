# Jezici — Ítems del Test de Ubicación (Español → Inglés) v0.1

> Banco inicial para el **test de ubicación adaptativo** del onboarding. Ítems reales por nivel/habilidad/dificultad, listos para sembrar en `content_items` (o un banco específico de placement). Borrador para ampliar.

---

## Lógica adaptativa (recordatorio)

Empezar en dificultad media (~A2). **Acierto → sube** un escalón; **error → baja**. ~12–20 ítems. Converger: el nivel donde el usuario acierta consistentemente ≈ su CEFR. Guardar también estimación por habilidad. (Detalle en `Banco_Items_Examenes`.)

---

## Ítems A1

- `multiple_choice` · reading — "*Hello* significa…" → hola | gracias | adiós → **hola**
- `cloze` · writing — "I ___ a student." → am | is | are → **am**
- `multiple_choice` · vocab — "Lo contrario de *yes* es…" → no | please | hi → **no**
- `multiple_choice` · reading — "*Thank you* significa…" → perdón | gracias | hola → **gracias**

## Ítems A2

- `cloze` · grammar — "She ___ to school every day." → go | goes | going → **goes**
- `cloze` · grammar — "I'm from Peru. I ___ in Lima." → live | lives | living → **live**
- `multiple_choice` · grammar — "Yesterday I ___ pizza." → eat | ate | eaten → **ate**
- `cloze` · grammar — "There ___ two books on the table." → is | are | be → **are**

## Ítems B1

- `cloze` · grammar — "If it rains, I ___ at home." → stay | will stay | stayed → **will stay**
- `multiple_choice` · grammar — "She has worked here ___ 2020." → since | for | from → **since**
- `cloze` · grammar — "I have ___ been to Japan." → never | ever | already → **never**
- `multiple_choice` · vocab — "I'm used to ___ up early." → get | getting | got → **getting**

## Ítems B2

- `cloze` · grammar — "I wish I ___ more time." → have | had | will have → **had**
- `multiple_choice` · vocab — "He was ___ to finish on time." → able | can | capable of → **able**
- `cloze` · grammar — "If I ___ known, I would have told you." → have | had | did → **had**
- `multiple_choice` · grammar — "She said she ___ tired." → is | was | be → **was**

---

## Notas

- Para que la adaptación funcione, conviene **más ítems por nivel** (este es un set inicial). Ampliar con `listening` también.
- Etiquetar cada ítem con `cefr_level`, `skill`, `difficulty` y `tags` (función gramatical) para alimentar el diagnóstico de debilidades.
- Salida del test: `current_level` + estimación por habilidad → arranca el plan y el árbol en el punto justo.
