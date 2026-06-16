# Jezici — Contenido Unidad 1 (Español → Inglés, A1) — "Saludos y presentarte"

> Ejercicios reales, listos para sembrar en `content_items`. Cada ejercicio indica `type` y `skill`. Borrador para revisar/mejorar o cargar directo. Audio = placeholder (grabar/TTS después). Formato de carga al final (§6).

**Unidad:** Saludos y presentarte · **Nivel:** A1 · **Gramática:** *to be* (afirmativo), pronombres I/you.

---

## Lección 1.1 — Saludos básicos
**Vocabulario nuevo:** hello, hi, good morning, good night, goodbye, bye.

- **E1** · `match` · reading — Empareja: hello–hola · goodbye–adiós · good morning–buenos días
- **E2** · `multiple_choice` · reading — "¿Cómo se dice *hola*?" → hello | goodbye | please → **hello**
- **E3** · `multiple_choice` · reading — "*Good morning* significa…" → buenas noches | buenos días | adiós → **buenos días**
- **E4** · `listening` · listening — Escucha y elige [audio: "Goodbye"] → Hello | Goodbye | Good night → **Goodbye**
- **E5** · `word_bank` · writing — Arma: "Good morning" (fichas: Good · morning · night · evening) → **Good morning**
- **E6** · `translation` · writing — Traduce: "Adiós" → **Goodbye** (acepta: bye)
- **E7** · `multiple_choice` · reading — "Para despedirte de noche dices…" → Good morning | Good night | Hello → **Good night**
- **E8** · `speaking_read_aloud` · speaking — Lee en voz alta: **"Hello! Good morning!"**

---

## Lección 1.2 — Cortesía
**Vocabulario nuevo:** please, thank you, sorry, excuse me, yes, no.

- **E1** · `match` · reading — Empareja: please–por favor · thank you–gracias · sorry–perdón
- **E2** · `multiple_choice` · reading — "*Thank you* significa…" → perdón | gracias | hola → **gracias**
- **E3** · `cloze` · writing — Completa: "___ you!" → **Thank**
- **E4** · `multiple_choice` · reading — "Para pedir algo con educación usas…" → sorry | please | yes → **please**
- **E5** · `listening` · listening — Escucha y elige [audio: "Excuse me"] → Thank you | Excuse me | Sorry → **Excuse me**
- **E6** · `translation` · writing — Traduce: "Sí" → **Yes**
- **E7** · `word_bank` · writing — Arma: "Thank you very much" (fichas: Thank · you · very · much · please) → **Thank you very much**
- **E8** · `speaking_read_aloud` · speaking — Lee en voz alta: **"Thank you very much!"**

---

## Lección 1.3 — Tu nombre
**Vocabulario/chunks:** name, my, your, what · "My name is…", "What's your name?"

- **E1** · `multiple_choice` · reading — "*My name is Ana* significa…" → Mi nombre es Ana | Soy de Ana | Mi amiga Ana → **Mi nombre es Ana**
- **E2** · `reorder` · writing — Ordena: name / My / is / Ana → **My name is Ana**
- **E3** · `translation` · writing — Traduce: "Mi nombre es Carlos" → **My name is Carlos**
- **E4** · `multiple_choice` · reading — Responde a "What's your name?" → I'm fine | My name is Tom | Goodbye → **My name is Tom**
- **E5** · `cloze` · reading — Completa: "What's ___ name?" → **your**
- **E6** · `listening` · listening — Escucha y elige la respuesta correcta [audio: "What's your name?"] → My name is Sara | I'm from Peru | Thank you → **My name is Sara**
- **E7** · `word_bank` · writing — Arma: "What is your name" (fichas: What · is · your · name · my) → **What is your name**
- **E8** · `speaking_read_aloud` · speaking — Lee en voz alta: **"My name is Ana."**

---

## Lección 1.4 — Presentarte (to be)
**Vocabulario/chunks:** I am, you are, I'm, fine · "Nice to meet you", "I'm fine".

- **E1** · `cloze` · writing — Completa: "I ___ Ana." → **am**
- **E2** · `match` · reading — Empareja: I–am · you–are
- **E3** · `multiple_choice` · reading — "*Nice to meet you* significa…" → Buenas noches | Mucho gusto | Hasta luego → **Mucho gusto**
- **E4** · `cloze` · reading — Completa: "You ___ my friend." → **are**
- **E5** · `multiple_choice` · reading — Responde a "How are you?" → I'm fine, thanks | My name is Ana | Goodbye → **I'm fine, thanks**
- **E6** · `listening` · listening — Escucha y elige el significado [audio: "Nice to meet you"] → Mucho gusto | Gracias | Adiós → **Mucho gusto**
- **E7** · `word_bank` · writing — Arma: "Nice to meet you" (fichas: Nice · to · meet · you · see) → **Nice to meet you**
- **E8** · `speaking_read_aloud` · speaking — Lee en voz alta: **"Hi, I'm Ana. Nice to meet you!"**

---

## Lección 1.5 — 🏁 Checkpoint Unidad 1
Cronometrado · mezcla de las 4 lecciones y las 4 habilidades · **umbral 80%**. ~10 ítems aleatorizados del banco de la unidad. Ejemplos:

1. `multiple_choice` · reading — "*Goodbye* significa…" → adiós ✔
2. `cloze` · writing — "Thank ___!" → you
3. `listening` · listening — [audio: "Good morning"] → elegir "Buenos días"
4. `reorder` · writing — name / is / My / Tom → My name is Tom
5. `multiple_choice` · reading — Responder "What's your name?" → My name is… ✔
6. `cloze` · reading — "I ___ fine, thanks." → am
7. `translation` · writing — "Por favor" → Please
8. `match` · reading — please–por favor · thank you–gracias · sorry–perdón
9. `speaking_read_aloud` · speaking — "Hello! Nice to meet you!"
10. `multiple_choice` · reading — "*Nice to meet you* significa…" → Mucho gusto ✔

> Al pasarlo, sube progreso en las 4 habilidades y desbloquea la Unidad 2. Si falla, refuerzo dirigido + reintento.

---

## 6. Formato de carga (para Claude Code)

Cada ejercicio → un `content_items` (campos del Modelo de Datos). Ejemplo en JSON de **E2 de la Lección 1.1**:

```json
{
  "course": "es-en",
  "cefr_level": "A1",
  "skill": "reading",
  "type": "multiple_choice",
  "prompt": "¿Cómo se dice 'hola'?",
  "payload": { "options": ["hello", "goodbye", "please"] },
  "correct_answer": { "value": "hello" },
  "difficulty": 0.1,
  "tags": ["unidad1", "saludos"]
}
```

Y un ejemplo de `listening` con audio (placeholder):

```json
{
  "course": "es-en", "cefr_level": "A1", "skill": "listening",
  "type": "listening",
  "prompt": "Escucha y elige la palabra correcta.",
  "payload": { "audio_url": "audio/a1/goodbye.mp3", "options": ["Hello", "Goodbye", "Good night"] },
  "correct_answer": { "value": "Goodbye" },
  "difficulty": 0.15, "tags": ["unidad1", "saludos"]
}
```

> Claude Code puede generar el **seed JSON completo** del resto de ejercicios a partir de este patrón + el contenido de arriba. Pendiente: grabar/TTS los audios de los ítems `listening` y `speaking`.
