# IDIOMA_NUEVO_PLAYBOOK.md — añadir un idioma a Jezici

> Receta medida en la tanda REAL del **rumano (es→ro)**, 2026-07-22. No es teoría:
> cada paso trae el comando que se ejecutó y lo que costó. Si el próximo idioma es
> **latino** (alfabeto latino, romance o germánico occidental), seguir esto de arriba
> abajo debería bastar. Para un idioma con **otro alfabeto** (ruso, japonés, árabe)
> hay un apartado aparte al final: **no es la misma factura**.

---

## 0 · La lista completa: qué necesita un idioma para estar "al nivel de los 6"

Esto es el PASO 0 hecho contra la BD real, y es lo que convierte "añadir un idioma"
en una lista cerrada en vez de un agujero. Cada fila es una pieza que existe en los
6 cursos vivos; la columna **ro hoy** es lo que se construyó en esta tanda.

| # | Pieza | Dónde vive | Cómo se crea | ro hoy |
|---|---|---|---|---|
| 1 | Fila de idioma | `languages` | la emite `gen_course.py` | ✅ |
| 2 | Fila de curso | `courses` (source es → target) | la emite `gen_course.py` | ✅ |
| 3 | Unidades | `units` (6 por nivel CEFR) | `gen_course.py` desde los JSON | ✅ 6 (A1) |
| 4 | Lecciones + checkpoint | `lessons` (4 `lesson` + 1 `checkpoint` por unidad) | íd. | ✅ 30 |
| 5 | Ítems de ejercicio | `content_items` (9 tipos) + `lesson_items` | íd. | ✅ 134 |
| 6 | Exámenes de checkpoint | `exams` type=`checkpoint` (1 por unidad) | íd. | ✅ 6 |
| 7 | Vocabulario | `vocabulary` (word, translation, `frequency_rank`, pos) | íd., desde el bloque `vocab` | ✅ 108 |
| 8 | **Vínculo léxico** | `lesson_vocab` | migración que re-deriva la lógica de mig 165 | ✅ 198 filas / 74 palabras |
| 9 | Audio TTS | Supabase Storage `audio/items/<id>.mp3` | `gen_audio_missing.py <code>-<lvl>` | ✅ 48/48 |
| 10 | Banco de placement | `content_items` tag `placement` | `gen_placement_multi.py <code>` | ✅ 14 (A1) |
| 11 | Bandera | `course_models.dart` `flag` | 1 línea | ✅ 🇷🇴 |
| 12 | TTS/reconocedor | `speech_lang.dart` | 1 `case` (tts + stt) | ✅ ro-RO |
| 13 | Nombre del idioma en la UI | `learn_lang_names.dart` + 3 `.arb` | 1 clave ×3 | ✅ |
| 14 | Modelos de Conversar | `conversar_screen.dart` | 6 modelos + tips | ✅ |
| 15 | Tips (teoría E-1) | `content_tips` | autoría, 1 por unidad | ⛔ pendiente |
| 16 | Teoría de sesión (E-2) | `study_theory` | pipeline E-2 | ⛔ pendiente |
| 17 | Historias (inmersión) | `stories` | `gen_stories.py` | ⛔ pendiente |
| 18 | Exámenes de nivel + certificado | `exams` type=`level` | requiere el nivel COMPLETO | ⛔ (necesita B2) |

**Lo que NO hay que tocar y por qué:** el gating, la economía, el scheduler FSRS, la
certificación y las RPC son **course-agnósticos por construcción** (derivan el curso de
`jz_active_course()` o de `units.course_id`). Añadir un idioma es **sembrar datos**, no
cambiar lógica. Esa es la razón de que la factura sea de contenido, no de ingeniería.

---

## 1 · El orden, con los comandos reales

```bash
# ── (a) cablear el código: 3 diccionarios + 3 líneas de cliente ──
#   tools/content/gen_course.py       → COURSES / STAMPS / UNIT_WORD
#   tools/content/gen_placement_multi.py → COURSES + banco + modo
#   tools/content/gen_audio_missing.py   → GROUPS
#   app/lib/data/models/course_models.dart   → bandera
#   app/lib/core/speech/speech_lang.dart     → tts/stt
#   app/lib/core/i18n/learn_lang_names.dart  → + clave en app_{es,en,pt}.arb

# ── (b) ANTES de briefear: probar la voz TTS del idioma. Si no hay, cambia el plan ──
#   (verifica que translate_tts devuelve audio/mpeg real, no un error)

# ── (c) autorar: 6 agentes profesores NATIVOS, uno por unidad, con el brief ──
#   entregan tools/content/<code>_a1_u<N>.json

# ── (d) GUARDA determinista (normaliza + valida) — paso OBLIGATORIO ──
python guard_course.py ro a1

# ── (e) revisión adversarial: 2 agentes nativos, 3 unidades cada uno ──
#   aplicar hallazgos → volver a (d)

# ── (f) generar y aplicar ──
python gen_course.py ro a1
python apply_sql.py ../../supabase/migrations/<stamp>_seed_ro_a1.sql
python gen_placement_multi.py ro
python apply_sql.py ../../supabase/migrations/<stamp>_placement_bank_ro.sql
python gen_audio_missing.py ro-a1
python apply_sql.py ../../supabase/migrations/<stamp>_lesson_vocab_ro.sql

# ── (g) verificar con CLIENTE REAL ──
python verify_new_course.py ro     # determinista + aislamiento + cadena + audio
python verify_ro_chain.py          # recorrido completo del usuario nuevo
python verify_chain.py             # guardarraíl: el inglés intacto
python verify_pt_chain.py          # guardarraíl: multicurso intacto
```

---

## 2 · Las guardas (lo que impide enviar contenido roto)

**La regla de oro, consolidada en 7 idiomas:** *si un contraste se juega en algo que el
corrector perdona, el ítem tiene que ser de PULSAR (multiple_choice / listening), no de
escribir.* Un cloze que no puede distinguir el error del acierto **no mide su propio tema**.

Lo que `jz_grade` perdona (verificado contra la BD, no supuesto):

| Perdona | Consecuencia por idioma |
|---|---|
| mayúsculas | la mayúscula de los sustantivos **alemanes** es inevaluable |
| **diacríticos** (los añade una guarda) | **ro**: ă â î ș ț · **fr/pt/it**: tildes · `één`/`een` en **nl** |
| **añadir o quitar UNA letra** (respuesta de 1 palabra) | **it**: dobles consonantes (`anno`/`ano`) · **nl**: la ‑t de `werkt` y el *dt-fout* · **de**: infinitivo vs 1ª persona |
| **una sustitución** si hay varias palabras | cualquier contraste de una letra en respuesta multi-palabra |
| *no* perdona sustituir una letra en 1 palabra | ahí SÍ se puede medir: `dat`≠`dit`, `este`≠`esti` |

`guard_course.py <code> <nivel>` hace las dos cosas: **normaliza** al formato del
generador (así el brief de los autores puede ser legible) y **valida** el molde (20 ítems
con reparto exacto), que ningún distractor colisione al normalizar, que el enunciado no
contenga la respuesta y que `accepted` incluya su `value`. Lo que solo empeora la medición
sale como **AVISO**, no como bloqueo: el fallo produce un falso *acierto*, nunca castiga.

---

## 3 · Esfuerzo REAL medido en el rumano

| Fase | Coste |
|---|---|
| PASO 0 (mapear la anatomía en BD) | ~15 min |
| Cableado de código (6 archivos, ~20 líneas) | ~20 min |
| 6 agentes autores en paralelo | ~7 min de reloj |
| Guarda + normalización | 1 pasada, 11 arreglos automáticos |
| Revisión adversarial (2 agentes) | ~6 min de reloj |
| Generar + aplicar + audio (48 clips) | ~5 min |
| Verificación de cliente real | ~4 min |

**Un nivel (A1, 6 unidades, 120 ítems, 48 audios) cabe holgadamente en una tanda.**
Extrapolación honesta: **A1→B2 son 4 tandas** (una por nivel) y **C1 una quinta**; la
teoría E-2 (24 temas) es **otra tanda entera** por idioma, medida en las 6 anteriores.

---

## 4 · Los tres errores que costaron tiempo (y cómo evitarlos)

1. **El formato del brief ≠ el formato del generador.** `gen_course.py` espera `source`
   (translation) y `tiles` (word_bank/reorder); el brief pedía `text` y `sequence`. Un
   autor lo detectó solo, los otros no. **Solución permanente:** `guard_course.py`
   normaliza — el brief no tiene que conocer el esquema interno.
2. **`active` en `get_courses` no significa "habilitado"**, sino "es el curso activo de
   este usuario". Un verificador que lo asuma da un rojo falso en un curso recién creado.
3. **`lesson_vocab` no lo crea el generador.** Sin esa migración las palabras quedan
   **inertes**: existen en `vocabulary` pero `complete_lesson` no las inscribe en el SRS,
   así que el usuario nunca las repasa. Es la pieza que más fácil se olvida.

---

## 5 · Idiomas con OTRO alfabeto: no es la misma receta

Rumano encajó casi sin tocar nada **porque escribe en alfabeto latino**. Lo que rompería
con ruso / japonés / árabe, y que habría que resolver ANTES de prometer nada:

- **El corrector.** `jz_normalize` está pensado para latino. Con japonés no existe "una
  letra de distancia" en el sentido útil (kanji vs kana), y el hiragana/katakana/kanji de
  la misma palabra son cadenas distintas: **haría falta una noción de equivalencia nueva**.
- **La entrada de texto.** Cloze y translation asumen que el usuario puede teclear la
  respuesta. Sin teclado cirílico/japonés eso no se sostiene → habría que apoyarse mucho
  más en `word_bank` y opción múltiple, o añadir romanización.
- **El reconocedor de voz.** `SpeechLang` mapea a códigos BCP-47; ru-RU y ja-JP existen,
  pero la tolerancia del matching (0.6 sobre palabras) no se traslada a una lengua sin
  espacios entre palabras.
- **Escritura como destreza propia.** En japonés aprender el sistema de escritura ES una
  habilidad; el modelo de 4 habilidades actual no la tiene.

**Recomendación honesta:** los idiomas latinos (rumano, catalán, polaco, checo, sueco…)
son "seguir esta receta". Los de otro alfabeto son **un proyecto de plataforma**, no una
tanda de contenido, y deberían tener su propio análisis antes de empezar.
