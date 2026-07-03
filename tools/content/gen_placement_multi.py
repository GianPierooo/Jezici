# -*- coding: utf-8 -*-
"""Genera el banco de PLACEMENT para fr/it/de/nl (cursos ...0003/0004/0005/0006),
niveles A1+A2 (los que EXISTEN en esos cursos), reading(MC)+writing(cloze).
Espeja el molde es->pt (mig 093) / es->en (mig 075). Calificación server-side
(placement_next / jz_grade, correct_answer 42501). Cableado = el propio banco:
placement_next(p_course) ya selecciona ítems WHERE course_id=p_course AND
'placement'=any(tags) y estima el "techo con evidencia" sobre ese curso → con un
banco A1-A2 el techo se capa en A2 (igual que pt se capa en B1). NO se toca el RPC.

MEJORA vs el molde pt: guarda anti-colisión AUTOMÁTICA. Para cada cloze se ASEVERA
que ningún distractor está a distancia Levenshtein <= 1 del correcto (lo que
jz_near_match perdonaría → aceptaría un distractor). Se comprueba sobre el texto
crudo en minúsculas Y sin diacríticos (conservador). Reading = MC (exacto, sin
near-match). Emite 20260703120110_placement_bank_fritdenl.sql (uuid5, idempotente).
"""
import uuid, json, io, os, sys, unicodedata

NS = uuid.UUID('20000000-0000-0000-0000-0000000000aa')
DIFF = {'A1': 0.12, 'A2': 0.34}
COURSES = {
    'fr': '20000000-0000-0000-0000-000000000003',
    'it': '20000000-0000-0000-0000-000000000004',
    'de': '20000000-0000-0000-0000-000000000005',
    'nl': '20000000-0000-0000-0000-000000000006',
}

# (kind, prompt, options, answer). kind: 'w'=cloze(writing), 'r'=mc(reading).
# reading MC: contenido en idioma meta; algunas comprensión con marco ES.
BANKS = {
# ============================= FRANÇAIS =============================
'fr': {
'A1': [
 ('w', 'Je ___ étudiant.', ['suis', 'est', 'es'], 'suis'),
 ('w', 'Tu ___ français ?', ['es', 'sommes', 'suis'], 'es'),
 ('w', 'Nous ___ amis.', ['sommes', 'suis', 'est'], 'sommes'),
 ('w', "J'___ vingt ans.", ['ai', 'suis', 'fais'], 'ai'),
 ('w', 'Elle ___ un chat.', ['a', 'ont', 'sont'], 'a'),
 ('w', "J'aime ___ café.", ['le', 'du', 'la'], 'le'),
 ('w', 'Nous ___ français.', ['parlons', 'parle', 'parler'], 'parlons'),
 ('r', '« Merci » signifie :', ['Gracias', 'Adiós', 'Por favor'], 'Gracias'),
 ('r', '« Bonjour » se dit plutôt :', ['le matin', 'la nuit pour dormir', 'pour dire au revoir'], 'le matin'),
 ('r', 'Quel mot est un aliment ?', ['pain', 'table', 'bleu'], 'pain'),
 ('r', '« La sœur de ma mère » est votre :', ['tante', 'oncle', 'cousin'], 'tante'),
 ('r', 'De quelle couleur est le ciel par temps clair ?', ['bleu', 'rouge', 'vert'], 'bleu'),
 ('r', 'Choisissez la phrase correcte :', ["J'ai un chien.", 'Je a un chien.', "J'ai une chien."], "J'ai un chien."),
 ('r', '« Où habites-tu ? » demande :', ['un lieu', 'un âge', 'un aliment'], 'un lieu'),
],
'A2': [
 ('w', 'Hier, je ___ allé au cinéma.', ['suis', 'vais', 'vas'], 'suis'),
 ('w', 'Demain, elle ___ voyager.', ['va', 'est allée', 'aille'], 'va'),
 ('w', "Ce livre est ___ intéressant que l'autre.", ['plus', 'très', 'beaucoup'], 'plus'),
 ("w", "Je n'ai pas mangé ___ j'étais malade.", ['parce que', 'mais', 'et'], 'parce que'),
 ('w', 'Nous ___ un très bon film hier.', ['avons vu', 'voyons', 'voir'], 'avons vu'),
 ('w', 'Elle ___ ses clés à la maison la semaine dernière.', ['a oublié', 'oublie', 'oubliait'], 'a oublié'),
 ('w', "Quand j'étais petit, je ___ au foot.", ['jouais', 'joue', 'ai joué'], 'jouais'),
 ('r', 'Lisez : « Je vais visiter ma grand-mère le week-end prochain. » La phrase parle :', ["d'un projet futur", 'de maintenant', "d'hier"], "d'un projet futur"),
 ('r', 'Lisez : « Tom ne prend jamais de café le matin. » Tom prend du café :', ['jamais', 'tous les jours', 'parfois'], 'jamais'),
 ('r', 'Choisissez la phrase correcte :', ["Hier j'ai mangé une pizza.", 'Hier je mange une pizza.', 'Hier je manger une pizza.'], "Hier j'ai mangé une pizza."),
 ('r', '« J\'ai faim » signifie :', ['Tengo hambre', 'Tengo sueño', 'Tengo frío'], 'Tengo hambre'),
 ('r', 'Quel est un moyen de transport ?', ['autobus', 'fourchette', 'chemise'], 'autobus'),
 ('r', "Dans « Hier, j'ai beaucoup étudié », l'action s'est passée :", ['au passé', 'au futur', 'maintenant'], 'au passé'),
 ('r', 'Choisissez le comparatif correct :', ['plus rapide que', 'plus rapide de', 'plus vite de que'], 'plus rapide que'),
],
},
# ============================= ITALIANO =============================
'it': {
'A1': [
 ('w', 'Io ___ studente.', ['sono', 'è', 'sei'], 'sono'),
 ('w', 'Tu ___ italiano?', ['sei', 'sono', 'è'], 'sei'),
 ('w', 'Noi ___ amici.', ['siamo', 'sono', 'è'], 'siamo'),
 ('w', "Io ___ vent'anni.", ['ho', 'sono', 'faccio'], 'ho'),
 ('w', 'Lei ___ un gatto.', ['ha', 'hanno', 'avere'], 'ha'),
 ('w', 'Mi piace ___ caffè.', ['il', 'lo', 'la'], 'il'),
 ('w', 'Noi ___ italiano.', ['parliamo', 'parlo', 'parlare'], 'parliamo'),
 ('r', '« Grazie » significa:', ['Gracias', 'Adiós', 'Por favor'], 'Gracias'),
 ('r', '« Buongiorno » si dice:', ['la mattina', 'la notte per dormire', 'per salutare quando si parte'], 'la mattina'),
 ('r', 'Quale parola è un cibo?', ['pane', 'tavolo', 'blu'], 'pane'),
 ('r', '« La sorella di mia madre » è tua:', ['zia', 'zio', 'cugina'], 'zia'),
 ('r', 'Di che colore è il cielo in una giornata serena?', ['blu', 'rosso', 'verde'], 'blu'),
 ('r', 'Scegli la frase corretta:', ['Io ho un cane.', 'Io ha un cane.', 'Io avere un cane.'], 'Io ho un cane.'),
 ('r', '« Dove abiti? » chiede di:', ['un luogo', "un'età", 'un cibo'], 'un luogo'),
],
'A2': [
 ('w', 'Ieri ___ andato al cinema.', ['sono', 'vado', 'vai'], 'sono'),
 ('w', 'Domani ___ al mare.', ['andrò', 'vado', 'sono andato'], 'andrò'),
 ('w', "Questo libro è ___ interessante dell'altro.", ['più', 'molto', 'tanto'], 'più'),
 ('w', 'Non sono andato alla festa ___ ero malato.', ['perché', 'ma', 'e'], 'perché'),
 ('w', 'Ieri ___ un bellissimo film.', ['abbiamo visto', 'vediamo', 'vedere'], 'abbiamo visto'),
 ('w', 'La settimana scorsa lei ___ le chiavi a casa.', ['ha dimenticato', 'dimentica', 'dimenticava'], 'ha dimenticato'),
 ('w', 'Quando ero piccolo, ___ a calcio.', ['giocavo', 'gioco', 'ho giocato'], 'giocavo'),
 ('r', 'Leggi: « Visiterò mia nonna il prossimo fine settimana. » La frase parla di:', ['un progetto futuro', 'adesso', 'ieri'], 'un progetto futuro'),
 ('r', 'Leggi: « Tom non prende mai il caffè la mattina. » Tom prende il caffè:', ['mai', 'tutti i giorni', 'a volte'], 'mai'),
 ('r', 'Scegli la frase corretta:', ['Ieri ho mangiato una pizza.', 'Ieri mangio una pizza.', 'Ieri mangiare una pizza.'], 'Ieri ho mangiato una pizza.'),
 ('r', '« Ho fame » significa:', ['Tengo hambre', 'Tengo sueño', 'Tengo frío'], 'Tengo hambre'),
 ('r', 'Quale è un mezzo di trasporto?', ['autobus', 'forchetta', 'camicia'], 'autobus'),
 ('r', "In « Ieri ho studiato molto », l'azione è avvenuta:", ['nel passato', 'nel futuro', 'adesso'], 'nel passato'),
 ('r', 'Scegli il comparativo corretto:', ['più veloce di', 'più veloce che di', 'più veloce a'], 'più veloce di'),
],
},
# ============================= DEUTSCH =============================
'de': {
'A1': [
 ('w', 'Ich ___ Student.', ['bin', 'ist', 'bist'], 'bin'),
 ('w', 'Du ___ Deutscher?', ['bist', 'bin', 'seid'], 'bist'),
 ('w', 'Wir ___ Freunde.', ['sind', 'bin', 'ist'], 'sind'),
 ('w', 'Ich ___ zwanzig Jahre alt.', ['bin', 'habe', 'mache'], 'bin'),
 ('w', 'Sie ___ eine Katze.', ['hat', 'habe', 'haben'], 'hat'),
 ('w', 'Ich trinke ___ Kaffee.', ['einen', 'ein', 'kein'], 'einen'),
 ('w', 'Wir ___ Deutsch.', ['sprechen', 'spricht', 'sprich'], 'sprechen'),
 ('r', '„Danke" bedeutet:', ['Gracias', 'Adiós', 'Por favor'], 'Gracias'),
 ('r', '„Guten Morgen" sagt man:', ['am Morgen', 'in der Nacht zum Schlafen', 'zum Abschied'], 'am Morgen'),
 ('r', 'Welches Wort ist ein Lebensmittel?', ['Brot', 'Tisch', 'blau'], 'Brot'),
 ('r', '„Die Schwester meiner Mutter" ist deine:', ['Tante', 'Onkel', 'Cousin'], 'Tante'),
 ('r', 'Welche Farbe hat der Himmel bei klarem Wetter?', ['blau', 'rot', 'grün'], 'blau'),
 ('r', 'Wähle den richtigen Satz:', ['Ich habe einen Hund.', 'Ich habe ein Hund.', 'Ich haben einen Hund.'], 'Ich habe einen Hund.'),
 ('r', '„Wo wohnst du?" fragt nach:', ['einem Ort', 'einem Alter', 'einem Essen'], 'einem Ort'),
],
'A2': [
 ('w', 'Gestern ___ ich ins Kino gegangen.', ['bin', 'gehe', 'gehst'], 'bin'),
 ('w', 'Morgen ___ sie reisen.', ['wird', 'ist', 'werde'], 'wird'),
 ('w', 'Mein Bruder ist ___ als ich.', ['größer', 'groß', 'sehr groß'], 'größer'),
 ('w', 'Ich bin nicht zur Party gegangen, ___ ich krank war.', ['weil', 'aber', 'und'], 'weil'),
 ('w', 'Wir ___ gestern einen guten Film gesehen.', ['haben', 'sehen', 'sah'], 'haben'),
 ('w', 'Letzte Woche ___ sie ihre Schlüssel zu Hause vergessen.', ['hat', 'ist', 'haben'], 'hat'),
 ('w', 'Als ich klein war, ___ ich viel Fußball.', ['spielte', 'gespielt', 'spielen'], 'spielte'),
 ('r', 'Lies: „Ich werde nächstes Wochenende meine Oma besuchen." Der Satz spricht über:', ['die Zukunft', 'jetzt', 'gestern'], 'die Zukunft'),
 ('r', 'Lies: „Tom trinkt morgens nie Kaffee." Wie oft trinkt Tom Kaffee?', ['nie', 'jeden Tag', 'manchmal'], 'nie'),
 ('r', 'Wähle den richtigen Satz:', ['Gestern habe ich Pizza gegessen.', 'Gestern ich esse Pizza.', 'Gestern ich essen Pizza.'], 'Gestern habe ich Pizza gegessen.'),
 ('r', '„Ich habe Hunger" bedeutet:', ['Tengo hambre', 'Tengo sueño', 'Tengo frío'], 'Tengo hambre'),
 ('r', 'Was ist ein Verkehrsmittel?', ['Bus', 'Gabel', 'Hemd'], 'Bus'),
 ('r', 'In „Gestern habe ich viel gelernt" ist die Handlung:', ['in der Vergangenheit', 'in der Zukunft', 'jetzt'], 'in der Vergangenheit'),
 ('r', 'Wähle den richtigen Komparativ:', ['schneller als', 'schneller wie', 'mehr schnell als'], 'schneller als'),
],
},
# ============================= NEDERLANDS =============================
'nl': {
'A1': [
 ('w', 'Ik ___ student.', ['ben', 'is', 'zijn'], 'ben'),
 ('w', 'Jij ___ Nederlander?', ['bent', 'is', 'zijn'], 'bent'),
 ('w', 'Wij ___ vrienden.', ['zijn', 'ben', 'is'], 'zijn'),
 ('w', 'Ik ___ twintig jaar oud.', ['ben', 'heb', 'maak'], 'ben'),
 ('w', 'Zij ___ een kat.', ['heeft', 'heb', 'hebt'], 'heeft'),
 ('w', '___ water is koud.', ['Het', 'De', 'Een'], 'Het'),
 ('w', 'Wij ___ Nederlands.', ['spreken', 'spreek', 'spreekt'], 'spreken'),
 ('r', '„Dank je" betekent:', ['Gracias', 'Adiós', 'Por favor'], 'Gracias'),
 ('r', '„Goedemorgen" zeg je:', ["'s morgens", "'s nachts om te slapen", 'bij het afscheid'], "'s morgens"),
 ('r', 'Welk woord is voedsel?', ['brood', 'tafel', 'blauw'], 'brood'),
 ('r', '„De zus van mijn moeder" is jouw:', ['tante', 'oom', 'neef'], 'tante'),
 ('r', 'Welke kleur heeft de lucht op een heldere dag?', ['blauw', 'rood', 'groen'], 'blauw'),
 ('r', 'Kies de juiste zin:', ['Ik heb een hond.', 'Ik hebt een hond.', 'Ik hebben een hond.'], 'Ik heb een hond.'),
 ('r', '„Waar woon je?" vraagt naar:', ['een plaats', 'een leeftijd', 'een eten'], 'een plaats'),
],
'A2': [
 ('w', 'Gisteren ___ ik naar de bioscoop gegaan.', ['ben', 'ga', 'gaat'], 'ben'),
 ('w', 'Morgen ___ zij reizen.', ['gaat', 'is', 'ga'], 'gaat'),
 ('w', 'Mijn broer is ___ dan ik.', ['groter', 'groot', 'heel groot'], 'groter'),
 ('w', 'Ik ging niet naar het feest ___ ik ziek was.', ['omdat', 'maar', 'en'], 'omdat'),
 ('w', 'Wij ___ gisteren een goede film gezien.', ['hebben', 'zien', 'zag'], 'hebben'),
 ('w', 'Vorige week ___ zij haar sleutels thuis vergeten.', ['heeft', 'is', 'waren'], 'heeft'),
 ('w', 'Toen ik klein was, ___ ik veel voetbal.', ['speelde', 'speel', 'gespeeld'], 'speelde'),
 ('r', 'Lees: „Ik ga volgend weekend mijn oma bezoeken." De zin gaat over:', ['de toekomst', 'nu', 'gisteren'], 'de toekomst'),
 ('r', 'Lees: „Tom drinkt \'s ochtends nooit koffie." Hoe vaak drinkt Tom koffie?', ['nooit', 'elke dag', 'soms'], 'nooit'),
 ('r', 'Kies de juiste zin:', ['Gisteren heb ik pizza gegeten.', 'Gisteren ik eet pizza.', 'Gisteren ik eten pizza.'], 'Gisteren heb ik pizza gegeten.'),
 ('r', '„Ik heb honger" betekent:', ['Tengo hambre', 'Tengo sueño', 'Tengo frío'], 'Tengo hambre'),
 ('r', 'Wat is een vervoermiddel?', ['bus', 'vork', 'overhemd'], 'bus'),
 ('r', 'In „Gisteren heb ik veel geleerd" is de handeling:', ['in het verleden', 'in de toekomst', 'nu'], 'in het verleden'),
 ('r', 'Kies de juiste vergrotende trap:', ['sneller dan', 'sneller als', 'meer snel dan'], 'sneller dan'),
],
},
}


def _strip(s):
    s = s.strip().lower()
    return ''.join(c for c in unicodedata.normalize('NFD', s) if unicodedata.category(c) != 'Mn')


def _lev(a, b):
    if a == b:
        return 0
    m, n = len(a), len(b)
    prev = list(range(n + 1))
    for i in range(1, m + 1):
        cur = [i] + [0] * n
        for j in range(1, n + 1):
            cost = 0 if a[i - 1] == b[j - 1] else 1
            cur[j] = min(prev[j] + 1, cur[j - 1] + 1, prev[j - 1] + cost)
        prev = cur
    return prev[n]


def sql_str(s):
    return "'" + s.replace("'", "''") + "'"


def main():
    errors = []
    rows = []
    counts = {}
    for lang, levels in BANKS.items():
        cid = COURSES[lang]
        for lvl, items in levels.items():
            r = w = 0
            for i, (kind, prompt, options, answer) in enumerate(items):
                assert answer in options, f"{lang} {lvl} #{i}: answer '{answer}' not in options {options}"
                # Guarda anti-colisión SOLO para cloze (writing); MC = exacto.
                # Modela jz_near_match: palabra única → perdona SOLO inserción/borrado a
                # distancia 1 (no sustitución); multi-palabra → perdona cualquier edición
                # a distancia 1. Un distractor que jz_near_match perdonaría = colisión.
                if kind == 'w':
                    multiword = ' ' in answer.strip()
                    for d in options:
                        if d == answer:
                            continue
                        for A, B in ((answer.lower(), d.lower()), (_strip(answer), _strip(d))):
                            if A == B:
                                forgiven = True
                            elif multiword:
                                forgiven = _lev(A, B) <= 1
                            else:  # palabra única: solo indel a distancia 1
                                forgiven = abs(len(A) - len(B)) == 1 and _lev(A, B) == 1
                            if forgiven:
                                errors.append(f"COLISIÓN {lang} {lvl} #{i}: distractor '{d}' perdonable por near_match de '{answer}' ({A} vs {B})")
                skill = 'writing' if kind == 'w' else 'reading'
                ctype = 'cloze' if kind == 'w' else 'multiple_choice'
                r += kind == 'r'; w += kind == 'w'
                iid = str(uuid.uuid5(NS, f"{lang}-plc-{lvl}-{skill}-{i}"))
                payload = {'text': prompt, 'options': options} if kind == 'w' else {'options': options}
                ca = {'value': answer}
                tags = ['placement', lvl.lower(), skill, 'use_of_english']
                tags_sql = 'ARRAY[' + ', '.join(sql_str(t) for t in tags) + ']'
                rows.append(
                    f"  ('{iid}'::uuid, '{cid}'::uuid, '{lvl}'::cefr_level, '{skill}'::skill, "
                    f"'{ctype}'::content_item_type, {sql_str(prompt)}, "
                    f"{sql_str(json.dumps(payload, ensure_ascii=False))}::jsonb, "
                    f"{sql_str(json.dumps(ca, ensure_ascii=False))}::jsonb, {DIFF[lvl]}, {tags_sql})")
            counts[f"{lang} {lvl}"] = f"{r}R+{w}W"
    if errors:
        print("*** GUARDA ANTI-COLISIÓN FALLÓ ***")
        for e in errors:
            print(" ", e)
        sys.exit(1)
    lines = [
        "-- 20260703120110_placement_bank_fritdenl.sql",
        "-- Banco de PLACEMENT fr/it/de/nl (cursos ...0003/0004/0005/0006), A1+A2",
        "-- (los niveles que EXISTEN en esos cursos). reading=MC (exacto), writing=cloze",
        "-- (sin distractores a distancia Levenshtein <=1 del correcto → guarda automática).",
        "-- Tag 'placement' (excluido de pools). Calificación server-side (placement_next/",
        "-- jz_grade, correct_answer 42501). placement_next(p_course) ya es course-scoped →",
        "-- sembrar el banco ES el cableado; techo capado en A2 por la evidencia. uuid5 idempotente.",
        "",
        "insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values",
        ",\n".join(rows),
        "on conflict (id) do nothing;",
        "",
    ]
    out = os.path.join(os.path.dirname(__file__), '..', '..', 'supabase', 'migrations',
                       '20260703120110_placement_bank_fritdenl.sql')
    with io.open(out, 'w', encoding='utf-8') as f:
        f.write("\n".join(lines))
    print(f"escrito: {out} ({len(rows)} items)")
    for k in sorted(counts):
        print(" ", k, counts[k])


if __name__ == '__main__':
    main()
