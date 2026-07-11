# -*- coding: utf-8 -*-
"""P2 EVAL_AUDIT — profundiza la COMPRENSIÓN en it A1 (el censo mostró 29% de
MC reading = vocab-suelto "¿qué significa/cómo se dice"; listening = 100%
discriminación "elige la frase que oíste"). Añade ítems de COMPRENSIÓN REAL:
  - reading: mini-contexto/situación -> inferencia (no traducción de palabra suelta)
  - listening: un intercambio corto -> PREGUNTA de comprensión (no "¿cuál oíste?")
Ítems de POOL (tag unidadN + skill + 'comprension'), NO cableados a lecciones ->
entran a checkpoints/exámenes y densifican el banco SIN tocar lecciones ni el
denominador de jz_skill_mastery (mig 142) => 0 regresión a usuarios en curso.
Autoría nativa italiana + revisión adversarial (registro, concordancia,
respuesta única, distractores plausibles, 0 colisión bajo jz_normalize).

Emite: supabase/migrations/20260710120145_it_a1_comprehension.sql
Uso: python gen_it_a1_comprehension.py
"""
import json, uuid, io, os

COURSE_IT = "20000000-0000-0000-0000-000000000004"
NS = uuid.UUID("11111111-2222-3333-4444-555555555555")  # namespace estable p/ uuid5
STORAGE = "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/"

# ---- AUTORÍA (por unidad). r = reading MC (inferencia), l = listening (dialogo->pregunta) ----
# Cada item: (prompt_es, options[it/es], correct). listening además say (audio it).
UNITS = {
 1: {  # Saludos / presentarte / essere / tú-usted
  "r": [
    ("Son las nueve de la noche y te encuentras a tu vecino. ¿Qué le dices?",
     ["Buonasera", "Buongiorno", "Buonanotte"], "Buonasera"),
    ("Tu jefe te pregunta «Come sta?». Respondes con cortesía (usted):",
     ["Bene, grazie. E Lei?", "Bene, e tu?", "Ciao, a presto!"], "Bene, grazie. E Lei?"),
    ("Alguien te dice «Piacere di conoscerti!». ¿En qué situación se dice?",
     ["Cuando conoces a alguien por primera vez", "Cuando te despides de un amigo", "Cuando pides la cuenta"],
     "Cuando conoces a alguien por primera vez"),
  ],
  "l": [
    ("Ciao! Come stai? Non c'è male, grazie.", "¿Cómo está la persona que responde?",
     ["Non c'è male", "Malissimo", "Benissimo"], "Non c'è male"),
    ("Buongiorno, io sono la signora Rossi. Piacere, sono Marco.", "¿Cómo se llama el hombre?",
     ["Marco", "Rossi", "Paolo"], "Marco"),
  ],
 },
 2: {  # Números / edad (avere) / origen (venire da)
  "r": [
    ("Marco dice: «Ho vent'anni.» ¿Cuántos años tiene Marco?",
     ["20", "12", "2"], "20"),
    ("Una persona dice: «Vengo dalla Francia.» ¿De dónde es?",
     ["È francese", "È spagnola", "È italiana"], "È francese"),
    ("Anna ha quindici anni. Suo fratello ha tre anni più di lei. ¿Cuántos años tiene el hermano?",
     ["18", "15", "12"], "18"),
  ],
  "l": [
    ("Quanti anni hai? Ho diciotto anni.", "¿Cuántos años tiene?",
     ["18", "8", "80"], "18"),
    ("Di dove sei? Vengo dal Messico.", "¿Qué nacionalidad tiene?",
     ["Messicano", "Spagnolo", "Italiano"], "Messicano"),
  ],
 },
 3: {  # Familia / posesivos / presentar / describir
  "r": [
    ("«Questa è mia sorella.» ¿A quién presenta esta persona?",
     ["Una donna della sua famiglia", "Un amico del lavoro", "Il suo capo"], "Una donna della sua famiglia"),
    ("Marco ha otto anni. Suo nonno ha ottant'anni. ¿Quién es mayor?",
     ["Il nonno", "Marco", "Hanno la stessa età"], "Il nonno"),
    ("«Mio fratello è alto e simpatico.» ¿Cómo describe a su hermano?",
     ["In modo positivo", "In modo negativo", "Non lo descrive"], "In modo positivo"),
  ],
  "l": [
    ("Chi è questo? È mio padre, è alto e simpatico.", "¿Quién es la persona de la foto?",
     ["Il padre", "La madre", "Il fratello"], "Il padre"),
    ("Hai fratelli? Sì, ho due sorelle.", "¿Cuántas hermanas tiene?",
     ["Due", "Una", "Tre"], "Due"),
  ],
 },
 4: {  # Comida / bar / partitivo / precios
  "r": [
    ("En el bar dices: «Vorrei un caffè, per favore.» ¿Qué estás haciendo?",
     ["Ordinando qualcosa da bere", "Pagando il conto", "Salutando il cameriere"], "Ordinando qualcosa da bere"),
    ("«Quant'è?» ¿En qué momento lo dices en el bar?",
     ["Quando vuoi pagare", "Quando entri", "Quando ti siedi"], "Quando vuoi pagare"),
    ("«Vorrei del pane.» ¿Qué cantidad de pan pide la persona?",
     ["Una quantità non precisa", "Tutto il pane", "Nessun pane"], "Una quantità non precisa"),
  ],
  "l": [
    ("Prende un caffè? No grazie, vorrei un tè.", "¿Qué quiere tomar?",
     ["Un tè", "Un caffè", "Un'acqua"], "Un tè"),
    ("Il conto, per favore. Sono dieci euro.", "¿Cuánto tiene que pagar?",
     ["Dieci euro", "Dodici euro", "Due euro"], "Dieci euro"),
  ],
 },
 5: {  # Día / hora / verbos -are / rutina
  "r": [
    ("«Sono le tre e mezza.» ¿Qué hora es?",
     ["3:30", "3:15", "2:30"], "3:30"),
    ("Oggi è venerdì e domani è sabato. ¿Qué día viene después del sábado?",
     ["Domenica", "Lunedì", "Venerdì"], "Domenica"),
    ("«La mattina lavoro e la sera studio.» ¿Cuándo estudia esta persona?",
     ["La sera", "La mattina", "La notte"], "La sera"),
  ],
  "l": [
    ("A che ora mangi? Mangio all'una.", "¿A qué hora come?",
     ["All'una", "Alle otto", "Alle due"], "All'una"),
    ("Che giorno è oggi? Oggi è mercoledì.", "¿Qué día será mañana?",
     ["Giovedì", "Martedì", "Mercoledì"], "Giovedì"),
  ],
 },
 6: {  # Ciudad / direcciones / al-alla-nel
  "r": [
    ("Preguntas: «Dov'è la stazione?» ¿Qué estás buscando?",
     ["Un luogo", "Una persona", "Un orario"], "Un luogo"),
    ("«Vai sempre dritto e poi gira a destra.» ¿Qué te está dando esta persona?",
     ["Delle indicazioni stradali", "Un prezzo", "Un saluto"], "Delle indicazioni stradali"),
    ("«La banca è a sinistra del bar.» ¿Dónde está la banca?",
     ["Vicino al bar, a sinistra", "Dentro il bar", "Molto lontano dal bar"], "Vicino al bar, a sinistra"),
  ],
  "l": [
    ("Scusi, dov'è la farmacia? È lì, a destra.", "¿Dónde está la farmacia?",
     ["A destra", "A sinistra", "Sempre dritto"], "A destra"),
    ("Il ristorante è vicino? No, è lontano.", "¿El restaurante está cerca?",
     ["È lontano", "È vicino", "È qui"], "È lontano"),
  ],
 },
}


def norm(s):
    import unicodedata
    s = unicodedata.normalize('NFKD', s.lower().strip())
    s = ''.join(c for c in s if not unicodedata.combining(c))
    return ' '.join(s.split())


def sql_str(s):
    return "'" + s.replace("'", "''") + "'"


def main():
    items = []
    seen_keys = set()
    for u, blk in UNITS.items():
        # reading comprehension MC
        for i, (prompt, opts, correct) in enumerate(blk["r"]):
            assert correct in opts, f"correct not in opts u{u} r{i}"
            no = [norm(o) for o in opts]
            assert len(set(no)) == len(no), f"COLISION opts u{u} r{i}: {opts}"
            assert no.count(norm(correct)) == 1
            iid = str(uuid.uuid5(NS, f"it-a1-u{u}-r{i}-comprension"))
            items.append({
                "id": iid, "type": "multiple_choice", "skill": "reading", "cefr": "A1",
                "difficulty": 0.28, "prompt": prompt,
                "payload": {"options": opts},
                "correct": {"value": correct},
                "tags": [f"unidad{u}", "comprension", "reading"],
            })
        # listening comprehension (dialogo -> pregunta)
        for i, (say, prompt, opts, correct) in enumerate(blk["l"]):
            assert correct in opts, f"correct not in opts u{u} l{i}"
            no = [norm(o) for o in opts]
            assert len(set(no)) == len(no), f"COLISION opts u{u} l{i}: {opts}"
            iid = str(uuid.uuid5(NS, f"it-a1-u{u}-l{i}-comprension"))
            items.append({
                "id": iid, "type": "listening", "skill": "listening", "cefr": "A1",
                "difficulty": 0.30, "prompt": prompt,
                "payload": {"say": say, "options": opts, "audio_url": STORAGE + iid + ".mp3"},
                "correct": {"value": correct},
                "tags": [f"unidad{u}", "comprension", "listening"],
            })

    # sanity totals
    nr = sum(1 for x in items if x["skill"] == "reading")
    nl = sum(1 for x in items if x["skill"] == "listening")
    assert nr == 18 and nl == 12, (nr, nl)
    assert len(set(x["id"] for x in items)) == len(items), "uuid colision"

    lines = [
        "-- 20260710120145_it_a1_comprehension.sql",
        "-- P2 EVAL_AUDIT: comprension real en it A1 (reading inferencia + listening",
        "-- dialogo->pregunta). 30 items de POOL (tag unidadN+comprension), NO cableados",
        "-- a lecciones -> densifican checkpoints/examenes SIN tocar lecciones ni el",
        "-- denominador de jz_skill_mastery => 0 regresion. Autoria nativa + adversarial.",
        "begin;",
    ]
    for x in items:
        tags = "array[" + ",".join(sql_str(t) for t in x["tags"]) + "]::text[]"
        lines.append(
            "insert into content_items (id, course_id, type, skill, cefr_level, difficulty, prompt, payload, correct_answer, tags) values ("
            + f"'{x['id']}', '{COURSE_IT}', '{x['type']}', '{x['skill']}', '{x['cefr']}', {x['difficulty']}, "
            + sql_str(x["prompt"]) + ", "
            + sql_str(json.dumps(x["payload"], ensure_ascii=False)) + "::jsonb, "
            + sql_str(json.dumps(x["correct"], ensure_ascii=False)) + "::jsonb, "
            + tags + ") on conflict (id) do nothing;")
    lines.append("commit;")
    out = "\n".join(lines) + "\n"
    path = os.path.join(os.path.dirname(__file__), "..", "..", "supabase", "migrations",
                        "20260710120145_it_a1_comprehension.sql")
    io.open(path, "w", encoding="utf-8").write(out)
    print(f"OK: {len(items)} items ({nr}R + {nl}L) -> mig 145")
    # imprime muestra
    for x in items[:4]:
        print(" ", x["skill"], "|", x["prompt"][:55], "|", x["payload"].get("options"))


if __name__ == "__main__":
    main()
