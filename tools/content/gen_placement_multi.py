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
DIFF = {'A1': 0.12, 'A2': 0.34, 'B1': 0.52, 'B2': 0.68}
COURSES = {
    'fr': '20000000-0000-0000-0000-000000000003',
    'it': '20000000-0000-0000-0000-000000000004',
    'de': '20000000-0000-0000-0000-000000000005',
    'nl': '20000000-0000-0000-0000-000000000006',
    'ro': '20000000-0000-0000-0000-000000000007',
}

# (kind, prompt, options, answer). kind: 'w'=cloze(writing), 'r'=mc(reading).
# reading MC: contenido en idioma meta; algunas comprensión con marco ES.
BANKS = {
# ============================== ROMÂNĂ ==============================
# Solo A1: es el unico nivel sembrado del curso es->ro, asi que el placement
# NO debe ofrecer ubicar mas arriba (techo honesto, como pt en su dia con B1).
# NINGUN contraste se juega solo en un diacritico: la guarda los normaliza.
'ro': {
'A1': [
 ('w', 'Eu ___ student.', ['sunt', 'este', 'suntem'], 'sunt'),
 ('w', 'Tu ___ din Spania?', ['ești', 'sunt', 'suntem'], 'ești'),
 ('w', 'Noi ___ prieteni.', ['suntem', 'sunt', 'este'], 'suntem'),
 ('w', 'Eu ___ douăzeci de ani.', ['am', 'sunt', 'are'], 'am'),
 ('w', 'Ea ___ o soră.', ['are', 'am', 'aveți'], 'are'),
 ('w', 'Merg ___ magazin.', ['la', 'în', 'pe'], 'la'),
 ('w', 'Am treizeci ___ ani.', ['de', 'la', 'cu'], 'de'),
 ('r', '«Mulțumesc» significa:', ['Gracias', 'Adiós', 'Por favor'], 'Gracias'),
 ('r', '«La revedere» se dice al:', ['Despedirte', 'Saludar', 'Dar las gracias'], 'Despedirte'),
 ('r', '¿Cuál es «el niño» en rumano?', ['copilul', 'copil', 'copiii'], 'copilul'),
 ('r', '«Bunica mea» significa:', ['Mi abuela', 'Mi hermana', 'Mi madre'], 'Mi abuela'),
 ('r', '«A pleca» significa:', ['Irse', 'Plegar', 'Llegar'], 'Irse'),
 ('r', 'Pides un café en un bar. Dices:', ['Aș vrea o cafea, vă rog.', 'Am o cafea, vă rog.', 'Sunt o cafea, vă rog.'], 'Aș vrea o cafea, vă rog.'),
 ('r', '«Cât e ceasul?» pregunta por:', ['La hora', 'El precio', 'La edad'], 'La hora'),
],
},
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

# ── B1/B2 (los cursos fr/it/de/nl ya llegan a B2). Autorado nativo + guard near_match. ──
BANKS['fr']['B1'] = [
 ('w', 'Il faut que tu ___ à la banque avant midi.', ['ailles', 'vas', 'allé'], 'ailles'),
 ('w', "Bien qu'il ___ malade, il est venu travailler.", ['soit', 'est', 'sera'], 'soit'),
 ('w', "Si j'avais plus de temps, je ___ du piano tous les jours.", ['jouerais', 'joue', 'jouais'], 'jouerais'),
 ('w', "La femme ___ je t'ai parlé hier est ma voisine.", ['dont', 'que', 'qui'], 'dont'),
 ('w', 'Les lettres que nous avons ___ sont arrivées ce matin.', ['écrites', 'écrit', 'écrivant'], 'écrites'),
 ('w', "Elle m'a dit qu'elle ___ fatiguée ce jour-là.", ['était', 'est', 'sera'], 'était'),
 ('w', "Tu as pensé à ton rendez-vous ? Oui, j'___ pense.", ['y', 'en', 'le'], 'y'),
 ('r', 'Choisissez la phrase correcte :', ["Je veux que tu viennes.", 'Je veux que tu viens.', 'Je veux que tu venir.'], "Je veux que tu viennes."),
 ('r', "Complétez : « Le village ___ nous passons nos vacances est magnifique. »", ['où', 'que', 'dont'], 'où'),
 ('r', 'Quelle phrase exprime une hypothèse correcte ?', ["Si j'étais riche, je voyagerais.", "Si je serais riche, je voyagerais.", "Si j'étais riche, je voyagerai."], "Si j'étais riche, je voyagerais."),
 ('r', "Discours indirect. « Je pars demain », a-t-il dit. Il a dit qu'il ___ le lendemain.", ['partait', 'part', 'partira'], 'partait'),
 ('r', "Choisissez l'accord correct :", ["Les fleurs qu'il a offertes sont belles.", "Les fleurs qu'il a offert sont belles.", "Les fleurs qu'il a offerts sont belles."], "Les fleurs qu'il a offertes sont belles."),
 ('r', "Remplacez : « J'ai donné le livre à Paul. »", ['Je le lui ai donné.', 'Je lui le ai donné.', 'Je le leur ai donné.'], 'Je le lui ai donné.'),
 ('r', "Complétez : « Il faut absolument que nous ___ ce travail aujourd'hui. »", ['fassions', 'faisons', 'ferons'], 'fassions'),
]
BANKS['fr']['B2'] = [
 ('w', "Je suis content que tu ___ venu à la fête hier.", ['sois', 'es', 'étais'], 'sois'),
 ('w', "Si tu m'avais prévenu, je serais ___ te chercher.", ['venu', 'venir', 'venais'], 'venu'),
 ('w', "Tu es tombé malade ? Tu ___ te reposer davantage.", ['aurais dû', 'devrais', 'as dû'], 'aurais dû'),
 ('w', "Il m'a assuré qu'il ___ tout terminé avant la fin du mois.", ['aurait', 'aura', 'avait'], 'aurait'),
 ('w', "___ en marchant dans le parc, elle a eu une idée brillante.", ['Tout', 'Bien', 'Alors'], 'Tout'),
 ('w', "Je te prêterai la voiture à condition que tu ___ prudent.", ['sois', 'es', 'seras'], 'sois'),
 ('w', "C'est le courage ___ nous avons tous besoin en ce moment.", ['dont', 'que', 'qui'], 'dont'),
 ('r', 'Choisissez la phrase correcte (subjonctif passé) :', ["Bien qu'elle ait fini, elle continue.", "Bien qu'elle a fini, elle continue.", "Bien qu'elle finit, elle continue."], "Bien qu'elle ait fini, elle continue."),
 ('r', "Irréel du passé : « Si nous avions su, nous ___ autrement. »", ['aurions agi', 'aurions agit', 'avions agi'], 'aurions agi'),
 ('r', "Discours indirect. « Je le ferai », dit-elle. Elle a dit qu'elle ___.", ['le ferait', 'le fera', 'le faisait'], 'le ferait'),
 ('r', "Choisissez la forme correcte :", ["C'est une histoire fascinante.", "C'est une histoire fascinant.", "C'est une histoire en fascinant."], "C'est une histoire fascinante."),
 ('r', "Mise en relief sur « Marie » : « Marie a résolu le problème. »", ["C'est Marie qui a résolu le problème.", "C'est Marie qu'a résolu le problème.", "C'est Marie que a résolu le problème."], "C'est Marie qui a résolu le problème."),
 ('r', 'Quelle phrase est grammaticalement correcte ?', ["Il travaille alors que les autres se reposent.", "Il travaille alors que les autres se reposeront.", "Il travaille bien que les autres se reposent."], "Il travaille alors que les autres se reposent."),
 ('r', "Discours indirect. « Que veux-tu ? » Il m'a demandé ___ je voulais.", ['ce que', 'ce qui', 'que'], 'ce que'),
]
BANKS['it']['B1'] = [
 ('w', 'Penso che Marco ___ stanco oggi.', ['sia', 'era', 'fosse'], 'sia'),
 ('w', 'È importante che tu ___ pazienza con i bambini.', ['abbia', 'ha', 'avesse'], 'abbia'),
 ('w', 'Se domani piove, ___ a casa a studiare.', ['resto', 'resterei', 'restassi'], 'resto'),
 ('w', 'Scusi, ___ un caffè, per favore.', ['vorrei', 'voglio', 'volevo'], 'vorrei'),
 ('w', "L'amica di ___ ti ho parlato arriva stasera.", ['cui', 'che', 'quale'], 'cui'),
 ('w', 'Le mie amiche ___ già partite per Roma.', ['sono', 'è', 'ho'], 'sono'),
 ('w', 'Marta voleva il libro e io ___ ho prestato subito.', ['glielo', 'gli', 'lo'], 'glielo'),
 ('r', 'Scegli la frase corretta:', ['Ho comprato le mele e le ho mangiate.', 'Ho comprato le mele e le ho mangiato.', 'Ho comprato le mele e le ho mangiati.'], 'Ho comprato le mele e le ho mangiate.'),
 ('r', 'Anna dice: « Ho finito il lavoro. » Anna dice che ___', ['ha finito il lavoro.', 'ho finito il lavoro.', 'aveva finito il lavoro.'], 'ha finito il lavoro.'),
 ('r', 'Completa: « Non conosco nessuno ___ possa aiutarmi. »', ['che', 'cui', 'chi'], 'che'),
 ('r', 'Scegli la frase corretta:', ['Bevo troppo caffè, ma non ne posso fare a meno.', 'Bevo troppo caffè, ma non lo posso fare a meno.', 'Bevo troppo caffè, ma non ci posso fare a meno.'], 'Bevo troppo caffè, ma non ne posso fare a meno.'),
 ('r', 'Leggi: « Se avessi tempo, ti aiuterei. » Chi parla:', ['non ha tempo ora', 'ha molto tempo', 'ha finito di aiutare'], 'non ha tempo ora'),
 ('r', 'Scegli la frase corretta:', ['Credo che loro abbiano ragione.', 'Credo che loro hanno ragione.', 'Credo che loro avranno ragione.'], 'Credo che loro abbiano ragione.'),
 ('r', "Completa: « Ecco la ragazza ___ abito è vicino al mio. »", ['il cui', 'di cui', 'che'], 'il cui'),
]
BANKS['it']['B2'] = [
 ('w', 'Pensavo che lui ___ più simpatico, invece è stato scortese.', ['fosse', 'era', 'sarebbe'], 'fosse'),
 ('w', 'Non sapevo che tu ___ già mangiato prima di uscire.', ['avesse', 'aveva', 'abbia'], 'avesse'),
 ('w', 'Se avessi più tempo libero, ___ volentieri con voi.', ['verrei', 'vengo', 'venni'], 'verrei'),
 ('w', "Se tu avessi studiato di più, ___ superato l'esame.", ['avrei', 'ho', 'avevo'], 'avrei'),
 ('w', 'Il ponte ___ costruito dai Romani molti secoli fa.', ['venne', 'fu', 'sarà'], 'fu'),
 ('w', 'Benché ___ molto stanco, ha continuato a lavorare.', ['sia', 'è', 'era'], 'sia'),
 ('w', 'In questo negozio ___ prodotti biologici di ottima qualità.', ['vendono', 'vende', 'venderanno'], 'vendono'),
 ('r', 'Scegli la frase corretta (discorso indiretto):', ['Disse che sarebbe partito il giorno dopo.', 'Disse che partirebbe il giorno dopo.', 'Disse che partirà il giorno dopo.'], 'Disse che sarebbe partito il giorno dopo.'),
 ('r', 'Scegli la frase corretta:', ['Sebbene fosse ricco, non era felice.', 'Sebbene era ricco, non era felice.', 'Sebbene sarebbe ricco, non era felice.'], 'Sebbene fosse ricco, non era felice.'),
 ('r', 'Trasforma in passiva: « Il direttore ha firmato il contratto. »', ['Il contratto è stato firmato dal direttore.', 'Il contratto ha firmato il direttore.', 'Il contratto si firma dal direttore.'], 'Il contratto è stato firmato dal direttore.'),
 ('r', "Completa (frase scissa): « ___ Marco a rompere il vaso, non io. »", ['È stato', 'Ha stato', 'Era stato di'], 'È stato'),
 ('r', "Leggi: « Se me l'avessi detto, sarei venuto. » Che cosa è successo?", ["Non gliel'hanno detto e non è venuto.", "Gliel'hanno detto ed è venuto.", 'Verrà se glielo dicono.'], "Non gliel'hanno detto e non è venuto."),
 ('r', 'Scegli la frase corretta:', ['Temevo che non ci avesse capito.', 'Temevo che non ci ha capito.', 'Temevo che non ci capisce.'], 'Temevo che non ci avesse capito.'),
 ('r', 'Completa: « Una volta ___ i risultati, ti chiamerò. »', ['ottenuti', 'ottenuto', 'ottenendo'], 'ottenuti'),
]
BANKS['de']['B1'] = [
 ('w', 'Wenn ich reich ___, würde ich um die Welt reisen.', ['wäre', 'bin', 'sei'], 'wäre'),
 ('w', 'An deiner Stelle ___ ich mehr schlafen.', ['würde', 'sollte', 'kann'], 'würde'),
 ('w', 'Ich bleibe heute zu Hause, ___ ich krank bin.', ['weil', 'denn', 'aber'], 'weil'),
 ('w', 'Das ist der Film, ___ ich dir empfohlen habe.', ['den', 'das', 'wer'], 'den'),
 ('w', 'Das Haus ___ letztes Jahr renoviert.', ['wurde', 'hat', 'ist'], 'wurde'),
 ('w', 'Viele Kinder warten ___ den Bus.', ['auf', 'für', 'an'], 'auf'),
 ('w', 'Das ist das Auto ___ Vaters.', ['meines', 'mein', 'unser'], 'meines'),
 ('r', 'Wähle den richtigen Satz:', ['Ich weiß, dass er morgen kommt.', 'Ich weiß, dass er kommt morgen.', 'Ich weiß, dass kommt er morgen.'], 'Ich weiß, dass er morgen kommt.'),
 ('r', 'Lies: „Hätte ich mehr Zeit gehabt, wäre ich gekommen." Was stimmt?', ['Er ist nicht gekommen.', 'Er ist gekommen.', 'Er hatte viel Zeit.'], 'Er ist nicht gekommen.'),
 ('r', 'Welcher Satz drückt einen höflichen Wunsch aus?', ['Könnten Sie mir bitte helfen?', 'Können Sie helfen!', 'Sie helfen mir.'], 'Könnten Sie mir bitte helfen?'),
 ('r', 'Ergänze: „Es regnet, ___ nehme ich einen Schirm mit."', ['deshalb', 'obwohl', 'weil'], 'deshalb'),
 ('r', 'Welcher Satz steht korrekt im Passiv?', ['Der Brief wird geschrieben.', 'Der Brief schreibt.', 'Man schreibt der Brief.'], 'Der Brief wird geschrieben.'),
 ('r', 'Lies: „Obwohl es kalt war, ging sie schwimmen." Was bedeutet das?', ['Sie ging trotz der Kälte schwimmen.', 'Sie ging nicht schwimmen.', 'Es war warm.'], 'Sie ging trotz der Kälte schwimmen.'),
 ('r', 'Welches Relativpronomen passt? „Die Frau, ___ ich das Buch gegeben habe, ist meine Lehrerin."', ['der', 'die', 'wer'], 'der'),
]
BANKS['de']['B2'] = [
 ('w', 'Er sagte, er ___ keine Zeit für das Projekt.', ['habe', 'hat', 'wird'], 'habe'),
 ('w', 'Der Minister erklärte, er ___ am Freitag zurücktreten.', ['werde', 'wollte', 'kann'], 'werde'),
 ('w', 'Der Vertrag muss bis morgen unterschrieben ___.', ['werden', 'sein', 'haben'], 'werden'),
 ('w', 'Das Problem lässt ___ leicht lösen.', ['sich', 'es', 'ihn'], 'sich'),
 ('w', 'Je mehr er übte, ___ besser wurde er.', ['desto', 'als', 'wie'], 'desto'),
 ('w', 'Wir müssen heute noch eine wichtige Entscheidung ___.', ['treffen', 'machen', 'nehmen'], 'treffen'),
 ('w', '___ des schlechten Wetters fand das Spiel statt.', ['Trotz', 'Wegen', 'Während'], 'Trotz'),
 ('r', 'Wähle den korrekten Satz mit Partizip als Adjektiv:', ['Das reparierte Auto steht draußen.', 'Das reparierende Auto steht draußen.', 'Das repariert Auto steht draußen.'], 'Das reparierte Auto steht draußen.'),
 ('r', 'Indirekte Rede korrekt: Direkt „Ich bin müde."', ['Er sagte, er sei müde.', 'Er sagte, er ist müde.', 'Er sagte, er wäre gewesen müde.'], 'Er sagte, er sei müde.'),
 ('r', 'Welcher Satz nutzt „sowohl als auch" korrekt?', ['Sie spricht sowohl Deutsch als auch Spanisch.', 'Sie spricht sowohl Deutsch als Spanisch auch.', 'Sie spricht weder Deutsch als auch Spanisch.'], 'Sie spricht sowohl Deutsch als auch Spanisch.'),
 ('r', 'Ergänze: „Worüber habt ihr gesprochen?" „___ die Prüfung."', ['Über', 'Darüber', 'Worüber'], 'Über'),
 ('r', 'Welcher Satz steht im Zustandspassiv?', ['Die Tür ist geöffnet.', 'Die Tür wird geöffnet.', 'Die Tür öffnet sich.'], 'Die Tür ist geöffnet.'),
 ('r', 'Lies: „Nicht nur die Studenten, sondern auch die Lehrer waren begeistert." Wer war begeistert?', ['Studenten und Lehrer.', 'Nur die Studenten.', 'Nur die Lehrer.'], 'Studenten und Lehrer.'),
 ('r', 'Welcher Satz ist grammatisch korrekt (Genitiv-Präposition)?', ['Während des Films schlief er ein.', 'Während dem Film schlief er ein.', 'Während der Film schlief er ein.'], 'Während des Films schlief er ein.'),
]
BANKS['nl']['B1'] = [
 ('w', 'Als ik rijk was, ___ ik een groot huis kopen.', ['zou', 'zal', 'wil'], 'zou'),
 ('w', 'Ik blijf thuis ___ het regent.', ['omdat', 'daarom', 'hoewel'], 'omdat'),
 ('w', 'De man ___ daar loopt, is mijn buurman.', ['die', 'dat', 'wat'], 'die'),
 ('w', 'Het brood ___ gisteren door de bakker gebakken.', ['werd', 'was', 'is'], 'werd'),
 ('w', 'Ik wacht al een uur ___ de bus.', ['op', 'aan', 'voor'], 'op'),
 ('w', 'Als ik het geweten had, ___ ik je gebeld hebben.', ['zou', 'zal', 'wil'], 'zou'),
 ('w', 'Wij gingen naar buiten ___ te spelen.', ['om', 'te', 'voor'], 'om'),
 ('r', 'Kies de juiste zin:', ['Ik weet niet of hij komt.', 'Ik weet niet of komt hij.', 'Ik weet niet of hij komen.'], 'Ik weet niet of hij komt.'),
 ('r', 'Lees: „Hoewel het koud was, ging hij zwemmen." Wat betekent dit?', ['Hij ging zwemmen ondanks de kou.', 'Hij ging niet zwemmen door de kou.', 'Hij ging zwemmen omdat het koud was.'], 'Hij ging zwemmen ondanks de kou.'),
 ('r', 'Kies de juiste bijzin:', ['Ik denk dat hij morgen komt.', 'Ik denk dat hij komt morgen.', 'Ik denk dat komt hij morgen.'], 'Ik denk dat hij morgen komt.'),
 ('r', 'Welke zin staat in de lijdende vorm?', ['De brief wordt geschreven.', 'Hij schrijft de brief.', 'Hij gaat de brief schrijven.'], 'De brief wordt geschreven.'),
 ('r', 'Kies de juiste zin met een betrekkelijk voornaamwoord:', ['Dit is het boek dat ik las.', 'Dit is het boek die ik las.', 'Dit is het boek wie ik las.'], 'Dit is het boek dat ik las.'),
 ('r', 'Lees: „Ik zou graag een kopje koffie willen." Wat drukt de spreker uit?', ['een beleefde wens', 'een bevel', 'een verbod'], 'een beleefde wens'),
 ('r', 'Kies de juiste zin:', ['Ze bleef thuis omdat ze ziek was.', 'Ze bleef thuis omdat ze was ziek.', 'Ze bleef thuis omdat was ze ziek.'], 'Ze bleef thuis omdat ze ziek was.'),
]
BANKS['nl']['B2'] = [
 ('w', 'Hij zei dat hij de volgende dag ___ komen.', ['zou', 'zal', 'wil'], 'zou'),
 ('w', 'In dit restaurant ___ er veel gerookt.', ['wordt', 'heeft', 'gaat'], 'wordt'),
 ('w', 'De ___ bloemen op tafel roken heerlijk.', ['bloeiende', 'bloeien', 'gebloeid'], 'bloeiende'),
 ('w', 'Het was koud; ___ gingen we toch wandelen.', ['niettemin', 'omdat', 'terwijl'], 'niettemin'),
 ('w', 'Als hij harder had gewerkt, ___ hij geslaagd zijn.', ['zou', 'zal', 'wil'], 'zou'),
 ('w', '___ lezen van boeken maakt je slimmer.', ['Het', 'De', 'Een'], 'Het'),
 ('w', 'De brief is gisteren ___ verstuurd.', ['al', 'nog', 'pas'], 'al'),
 ('r', 'Kies de correcte indirecte rede: „Ik heb honger", zei ze.', ['Ze zei dat ze honger had.', 'Ze zei dat ze honger heeft.', 'Ze zei dat ze had honger.'], 'Ze zei dat ze honger had.'),
 ('r', 'Welke zin is correct (voltooid, lijdende vorm)?', ['De auto is gemaakt.', 'De auto is gemaakt geworden.', 'De auto heeft gemaakt.'], 'De auto is gemaakt.'),
 ('r', 'Kies de juiste zin met inversie na „desondanks":', ['Desondanks bleef hij kalm.', 'Desondanks hij bleef kalm.', 'Desondanks hij kalm bleef.'], 'Desondanks bleef hij kalm.'),
 ('r', 'Kies het juiste voltooid deelwoord als bijvoeglijk naamwoord:', ['de gesloten deur', 'de sluiten deur', 'de sloot deur'], 'de gesloten deur'),
 ('r', 'Lees: „Was ik maar eerder vertrokken, dan had ik de trein gehaald." Wat drukt dit uit?', ['spijt over het verleden', 'een plan voor morgen', 'een gewoonte'], 'spijt over het verleden'),
 ('r', 'Kies de juiste zin:', ['Zowel Jan als Piet komt.', 'Zowel Jan en Piet komt.', 'Zowel Jan of Piet komt.'], 'Zowel Jan als Piet komt.'),
 ('r', 'Welke zin gebruikt „noch noch" correct?', ['Noch hij noch zij was aanwezig.', 'Noch hij en zij was aanwezig.', 'Noch hij of zij was aanwezig.'], 'Noch hij noch zij was aanwezig.'),
]


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
    # Modo: sin arg = A1/A2 → mig 110 (histórico, ya aplicado). 'hi' = B1/B2 → mig nueva
    # (los cursos fr/it/de/nl ya llegan a B2; ampliar el techo del placement a su nivel real).
    mode = sys.argv[1] if len(sys.argv) > 1 else 'a1a2'
    if mode == 'ro':
        EMIT = {'A1'}
        OUT_NAME = '20260722120192_placement_bank_ro.sql'
        HEADER = [
            "-- 20260722120192_placement_bank_ro.sql",
            "-- Banco de PLACEMENT del curso es->ro (...0007), SOLO A1: es el unico nivel",
            "-- sembrado, asi que el estimador no puede ubicar donde no hay contenido",
            "-- (techo honesto, igual que pt en su dia). reading=MC (exacto), writing=cloze",
            "-- con la guarda anti-colision (que ademas normaliza los diacriticos romanos).",
            "-- placement_next(p_course) ya es course-scoped -> sembrar el banco ES el cableado.",
            "",
        ]
    elif mode == 'hi':
        EMIT = {'B1', 'B2'}
        OUT_NAME = '20260705120122_placement_bank_fritdenl_hi.sql'
        HEADER = [
            "-- 20260705120122_placement_bank_fritdenl_hi.sql",
            "-- Amplía el banco de PLACEMENT fr/it/de/nl a B1+B2 (esos cursos ya llegan a B2).",
            "-- reading=MC (exacto), writing=cloze (guarda automática near_match). Tag 'placement'.",
            "-- placement_next(p_course) es course-scoped → sembrar el banco ES el cableado; con B1/B2",
            "-- el techo del estimador sube a B2. Calificación server-side (jz_grade, 42501). uuid5 idempotente.",
            "",
        ]
    else:
        EMIT = {'A1', 'A2'}
        OUT_NAME = '20260703120110_placement_bank_fritdenl.sql'
        HEADER = [
            "-- 20260703120110_placement_bank_fritdenl.sql",
            "-- Banco de PLACEMENT fr/it/de/nl (cursos ...0003/0004/0005/0006), A1+A2",
            "-- (los niveles que EXISTEN en esos cursos). reading=MC (exacto), writing=cloze",
            "-- (sin distractores a distancia Levenshtein <=1 del correcto → guarda automática).",
            "-- Tag 'placement' (excluido de pools). Calificación server-side (placement_next/",
            "-- jz_grade, correct_answer 42501). placement_next(p_course) ya es course-scoped →",
            "-- sembrar el banco ES el cableado; techo capado en A2 por la evidencia. uuid5 idempotente.",
            "",
        ]
    errors = []
    rows = []
    counts = {}
    for lang, levels in BANKS.items():
        if (mode == 'ro') != (lang == 'ro'):
            continue          # cada migracion siembra SOLO su(s) curso(s)
        cid = COURSES[lang]
        for lvl, items in levels.items():
            if lvl not in EMIT:
                continue
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
    lines = HEADER + [
        "insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values",
        ",\n".join(rows),
        "on conflict (id) do nothing;",
        "",
    ]
    out = os.path.join(os.path.dirname(__file__), '..', '..', 'supabase', 'migrations', OUT_NAME)
    with io.open(out, 'w', encoding='utf-8') as f:
        f.write("\n".join(lines))
    print(f"escrito: {out} ({len(rows)} items)")
    for k in sorted(counts):
        print(" ", k, counts[k])


if __name__ == '__main__':
    main()
