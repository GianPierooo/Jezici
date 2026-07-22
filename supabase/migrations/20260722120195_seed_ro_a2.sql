-- 20260722120195_seed_ro_a2.sql
-- Currículo A2 del curso es→ro (6 unidades). Molde es→pt.
-- Contenido scopeado a course_id=20000000-0000-0000-0000-000000000007 → aislamiento multicurso por
-- jz_active_course. Unidades order_index continúan la cadena → gating al nivel previo.
begin;
insert into languages (id, code, name) values
  ('10000000-0000-0000-0000-000000000008','ro',$p$Română$p$) on conflict (id) do nothing;
insert into courses (id, source_language_id, target_language_id, is_active) values
  ('20000000-0000-0000-0000-000000000007','10000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000008',true) on conflict (id) do nothing;

-- ── Unidad 7 (A2·ro): El pasado: lo que hice ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('fa1a7a70-5b71-547f-af4d-ad40a1666aec','20000000-0000-0000-0000-000000000007','A2',7,$p$El pasado: lo que hice$p$,'#8E7CF0','history')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('62a896c5-2e5c-5050-a9fa-468feff1ce11','fa1a7a70-5b71-547f-af4d-ad40a1666aec',1,$p$Perfectul compus: un solo auxiliar$p$,$p$Perfectul compus: un solo auxiliar$p$,'lesson',15),
 ('4598ebca-82d4-5352-a1e1-0d1954328c25','fa1a7a70-5b71-547f-af4d-ad40a1666aec',2,$p$Los participios: -at, -ut, -s, -it$p$,$p$Los participios: -at, -ut, -s, -it$p$,'lesson',15),
 ('b3a1a5a0-85fd-5d30-a3c3-d95ac1d98191','fa1a7a70-5b71-547f-af4d-ad40a1666aec',3,$p$Ieri, alaltăieri, săptămâna trecută$p$,$p$Ieri, alaltăieri, săptămâna trecută$p$,'lesson',15),
 ('ccde37dc-d1fa-5671-aa1d-86d0cd6bf1b4','fa1a7a70-5b71-547f-af4d-ad40a1666aec',4,$p$La negación: nu am / n-am mâncat$p$,$p$La negación: nu am / n-am mâncat$p$,'lesson',15),
 ('cbd2339a-7dcc-5647-a2d0-30f01775b71b','fa1a7a70-5b71-547f-af4d-ad40a1666aec',5,$p$🏁 Checkpoint Unitatea 7$p$,$p$Repasa el perfectul compus con un único auxiliar («a avea»: am, ai, a, am, ați, au), la formación del participio (-at, -ut, -s, -it), los marcadores de tiempo pasado y la negación «n-am / nu am».$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('86612675-c70a-5139-b9ad-002124dd8c27','20000000-0000-0000-0000-000000000007','checkpoint','A2','fa1a7a70-5b71-547f-af4d-ad40a1666aec',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('d8c01390-68be-5be5-aa84-39ab4741c192'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','reading','match',$p$Empareja cada forma del pasado con su traducción.$p$,$j${"pairs": [{"en": "am fost", "es": "(yo) estuve, he estado"}, {"en": "ai plecat", "es": "(tú) te fuiste"}, {"en": "au venit", "es": "(ellos) vinieron"}]}$j$::jsonb,$j${"pairs": [["am fost", "(yo) estuve, he estado"], ["ai plecat", "(tú) te fuiste"], ["au venit", "(ellos) vinieron"]]}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$perfect_compus$p$, $p$reading$p$]),
('7f51d600-b9c2-590a-9f6f-6f7fb884ac97'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','reading','multiple_choice',$p$«Nosotros hemos visto la película.» ¿Cuál es la forma correcta?$p$,$j${"options": ["Noi am văzut filmul.", "Noi ai văzut filmul.", "Noi a văzut filmul."]}$j$::jsonb,$j${"value": "Noi am văzut filmul."}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$perfect_compus$p$, $p$reading$p$]),
('af46d2ec-ca82-5809-9e69-365ea0ea00a8'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Am venit acasă târziu.", "Am venit acasă devreme.", "Am plecat de acasă târziu."], "say": "Am venit acasă târziu.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/af46d2ec-ca82-5809-9e69-365ea0ea00a8.mp3"}$j$::jsonb,$j${"value": "Am venit acasă târziu."}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$perfect_compus$p$, $p$listening$p$]),
('ec567c34-4f5e-5a33-82b8-dbffbb420706'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','writing','translation',$p$Traduce al rumano:$p$,$j${"source": "Ayer trabajé en casa."}$j$::jsonb,$j${"value": "Ieri am lucrat acasă.", "accepted": ["Ieri am lucrat acasă.", "Ieri am lucrat acasă", "Ieri am lucrat acasa.", "Ieri am lucrat acasa", "Am lucrat acasă ieri.", "Am lucrat acasă ieri", "Am lucrat acasa ieri.", "Am lucrat acasa ieri", "Am lucrat ieri acasă.", "Am lucrat ieri acasa", "Eu am lucrat acasă ieri.", "Eu ieri am lucrat acasă.", "Am lucrat ieri acasa.", "Eu am lucrat acasa ieri.", "Eu ieri am lucrat acasa."]}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$perfect_compus$p$, $p$writing$p$]),
('a1e55887-a236-50b2-a963-b05b63c836b0'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Ieri am fost la magazin și am mâncat acasă.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/a1e55887-a236-50b2-a963-b05b63c836b0.mp3"}$j$::jsonb,$j${"expected": "Ieri am fost la magazin și am mâncat acasă."}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$perfect_compus$p$, $p$speaking$p$]),
('7039e3f7-7fb4-55d7-8849-0a2a24ce666e'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','reading','multiple_choice',$p$¿Cuál es el participio del verbo «a scrie» (escribir)?$p$,$j${"options": ["scris", "scriit", "scrisut"]}$j$::jsonb,$j${"value": "scris"}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$participiu$p$, $p$reading$p$]),
('7984d4cf-f27b-52f7-92e0-9ad169bbf2f4'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','reading','multiple_choice',$p$¿Cuál es el participio del verbo «a vedea» (ver)?$p$,$j${"options": ["văzut", "vedut", "vezut"]}$j$::jsonb,$j${"value": "văzut"}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$participiu$p$, $p$reading$p$]),
('af5964f7-784b-5215-a3ef-526beaa4acc9'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','writing','cloze',$p$Completa con el participio de «a bea»: «Ayer bebí un té.»$p$,$j${"text": "Ieri am ___ un ceai."}$j$::jsonb,$j${"value": "băut", "accepted": ["băut", "baut"]}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$participiu$p$, $p$writing$p$]),
('8a931b78-f97e-5f62-8ad2-e561609db430'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Copiii au dormit bine.", "Copiii au mâncat bine.", "Copiii au dormit acasă."], "say": "Copiii au dormit bine.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/8a931b78-f97e-5f62-8ad2-e561609db430.mp3"}$j$::jsonb,$j${"value": "Copiii au dormit bine."}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$participiu$p$, $p$listening$p$]),
('99fb8681-cfe8-581a-bfe9-f2c6cad56746'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Am scris o scrisoare și am citit o carte.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/99fb8681-cfe8-581a-bfe9-f2c6cad56746.mp3"}$j$::jsonb,$j${"expected": "Am scris o scrisoare și am citit o carte."}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$participiu$p$, $p$speaking$p$]),
('c443aa3c-9f2d-53e5-94f8-9bdf709df488'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','reading','match',$p$Empareja cada marcador de tiempo con su traducción.$p$,$j${"pairs": [{"en": "ieri", "es": "ayer"}, {"en": "săptămâna trecută", "es": "la semana pasada"}, {"en": "acum două zile", "es": "hace dos días"}]}$j$::jsonb,$j${"pairs": [["ieri", "ayer"], ["săptămâna trecută", "la semana pasada"], ["acum două zile", "hace dos días"]]}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$marcatori_timp$p$, $p$reading$p$]),
('f91940c8-1b75-587f-b3d9-f0483a508645'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Azi-dimineață am băut o cafea.", "Azi-dimineață am băut un ceai.", "Ieri am băut o cafea."], "say": "Azi-dimineață am băut o cafea.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/f91940c8-1b75-587f-b3d9-f0483a508645.mp3"}$j$::jsonb,$j${"value": "Azi-dimineață am băut o cafea."}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$marcatori_timp$p$, $p$listening$p$]),
('2630d09f-e151-531b-bb61-5df6699bfb17'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','writing','cloze',$p$Completa con el participio de «a merge»: «Hace dos días fui al mercado.»$p$,$j${"text": "Acum două zile am ___ la piață."}$j$::jsonb,$j${"value": "mers", "accepted": ["mers"]}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$marcatori_timp$p$, $p$writing$p$]),
('bbbcf17a-bf8f-5180-9b70-651afaaf0c8e'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','writing','translation',$p$Traduce al rumano:$p$,$j${"source": "Anteayer vi una película."}$j$::jsonb,$j${"value": "Alaltăieri am văzut un film.", "accepted": ["Alaltăieri am văzut un film.", "Alaltăieri am văzut un film", "Alaltaieri am vazut un film.", "Alaltaieri am vazut un film", "Am văzut un film alaltăieri.", "Am văzut un film alaltăieri", "Am vazut un film alaltaieri.", "Am vazut un film alaltaieri", "Eu am văzut un film alaltăieri.", "Am văzut alaltăieri un film.", "Am vazut alaltaieri un film.", "Eu am vazut un film alaltaieri."]}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$marcatori_timp$p$, $p$writing$p$]),
('8dfceb69-e864-54af-bb61-12f88a1a76b4'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','writing','word_bank',$p$Ordena para decir «La semana pasada fuimos a Bucarest». Empieza por «Săptămâna».$p$,$j${"tiles": ["am", "București", "fost", "ieri", "la", "sunt", "Săptămâna", "trecută"]}$j$::jsonb,$j${"value": "Săptămâna trecută am fost la București", "sequence": ["Săptămâna", "trecută", "am", "fost", "la", "București"]}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$marcatori_timp$p$, $p$writing$p$]),
('6b110370-9446-5a86-936f-e265622e7b37'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','reading','multiple_choice',$p$«No he dormido bien.» ¿Cuál es la forma correcta?$p$,$j${"options": ["N-am dormit bine.", "Am nu dormit bine.", "Am dormit nu bine."]}$j$::jsonb,$j${"value": "N-am dormit bine."}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$negatie_trecut$p$, $p$reading$p$]),
('c5dbc636-b062-55ea-83a8-173e4284a80d'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Nu am lucrat ieri.", "Am lucrat ieri.", "Nu am lucrat azi."], "say": "Nu am lucrat ieri.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/c5dbc636-b062-55ea-83a8-173e4284a80d.mp3"}$j$::jsonb,$j${"value": "Nu am lucrat ieri."}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$negatie_trecut$p$, $p$listening$p$]),
('7284ed6f-18d5-5a30-9b16-07efdd15b97c'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ei n-au plecat cu trenul.", "Ei au plecat cu trenul.", "Ei n-au plecat la gară."], "say": "Ei n-au plecat cu trenul.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/7284ed6f-18d5-5a30-9b16-07efdd15b97c.mp3"}$j$::jsonb,$j${"value": "Ei n-au plecat cu trenul."}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$negatie_trecut$p$, $p$listening$p$]),
('d7aac206-e04f-5c58-b331-5c7b71bd0ae3'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','writing','reorder',$p$Ordena las palabras: «No he leído el libro».$p$,$j${"tiles": ["am", "cartea", "citit", "Nu"]}$j$::jsonb,$j${"value": "Nu am citit cartea"}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$negatie_trecut$p$, $p$writing$p$]),
('07f55b64-ee0f-5eb7-a60f-2fc745332d80'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Ce ai făcut ieri? Eu n-am lucrat.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/07f55b64-ee0f-5eb7-a60f-2fc745332d80.mp3"}$j$::jsonb,$j${"expected": "Ce ai făcut ieri? Eu n-am lucrat."}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$negatie_trecut$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('62a896c5-2e5c-5050-a9fa-468feff1ce11','d8c01390-68be-5be5-aa84-39ab4741c192',1),
 ('62a896c5-2e5c-5050-a9fa-468feff1ce11','7f51d600-b9c2-590a-9f6f-6f7fb884ac97',2),
 ('62a896c5-2e5c-5050-a9fa-468feff1ce11','af46d2ec-ca82-5809-9e69-365ea0ea00a8',3),
 ('62a896c5-2e5c-5050-a9fa-468feff1ce11','ec567c34-4f5e-5a33-82b8-dbffbb420706',4),
 ('62a896c5-2e5c-5050-a9fa-468feff1ce11','a1e55887-a236-50b2-a963-b05b63c836b0',5),
 ('4598ebca-82d4-5352-a1e1-0d1954328c25','7039e3f7-7fb4-55d7-8849-0a2a24ce666e',1),
 ('4598ebca-82d4-5352-a1e1-0d1954328c25','7984d4cf-f27b-52f7-92e0-9ad169bbf2f4',2),
 ('4598ebca-82d4-5352-a1e1-0d1954328c25','af5964f7-784b-5215-a3ef-526beaa4acc9',3),
 ('4598ebca-82d4-5352-a1e1-0d1954328c25','8a931b78-f97e-5f62-8ad2-e561609db430',4),
 ('4598ebca-82d4-5352-a1e1-0d1954328c25','99fb8681-cfe8-581a-bfe9-f2c6cad56746',5),
 ('b3a1a5a0-85fd-5d30-a3c3-d95ac1d98191','c443aa3c-9f2d-53e5-94f8-9bdf709df488',1),
 ('b3a1a5a0-85fd-5d30-a3c3-d95ac1d98191','f91940c8-1b75-587f-b3d9-f0483a508645',2),
 ('b3a1a5a0-85fd-5d30-a3c3-d95ac1d98191','2630d09f-e151-531b-bb61-5df6699bfb17',3),
 ('b3a1a5a0-85fd-5d30-a3c3-d95ac1d98191','bbbcf17a-bf8f-5180-9b70-651afaaf0c8e',4),
 ('b3a1a5a0-85fd-5d30-a3c3-d95ac1d98191','8dfceb69-e864-54af-bb61-12f88a1a76b4',5),
 ('ccde37dc-d1fa-5671-aa1d-86d0cd6bf1b4','6b110370-9446-5a86-936f-e265622e7b37',1),
 ('ccde37dc-d1fa-5671-aa1d-86d0cd6bf1b4','c5dbc636-b062-55ea-83a8-173e4284a80d',2),
 ('ccde37dc-d1fa-5671-aa1d-86d0cd6bf1b4','7284ed6f-18d5-5a30-9b16-07efdd15b97c',3),
 ('ccde37dc-d1fa-5671-aa1d-86d0cd6bf1b4','d7aac206-e04f-5c58-b331-5c7b71bd0ae3',4),
 ('ccde37dc-d1fa-5671-aa1d-86d0cd6bf1b4','07f55b64-ee0f-5eb7-a60f-2fc745332d80',5),
 ('cbd2339a-7dcc-5647-a2d0-30f01775b71b','d8c01390-68be-5be5-aa84-39ab4741c192',1),
 ('cbd2339a-7dcc-5647-a2d0-30f01775b71b','7f51d600-b9c2-590a-9f6f-6f7fb884ac97',2),
 ('cbd2339a-7dcc-5647-a2d0-30f01775b71b','7039e3f7-7fb4-55d7-8849-0a2a24ce666e',3),
 ('cbd2339a-7dcc-5647-a2d0-30f01775b71b','ec567c34-4f5e-5a33-82b8-dbffbb420706',4),
 ('cbd2339a-7dcc-5647-a2d0-30f01775b71b','af5964f7-784b-5215-a3ef-526beaa4acc9',5),
 ('cbd2339a-7dcc-5647-a2d0-30f01775b71b','2630d09f-e151-531b-bb61-5df6699bfb17',6),
 ('cbd2339a-7dcc-5647-a2d0-30f01775b71b','af46d2ec-ca82-5809-9e69-365ea0ea00a8',7),
 ('cbd2339a-7dcc-5647-a2d0-30f01775b71b','8a931b78-f97e-5f62-8ad2-e561609db430',8),
 ('cbd2339a-7dcc-5647-a2d0-30f01775b71b','a1e55887-a236-50b2-a963-b05b63c836b0',9),
 ('cbd2339a-7dcc-5647-a2d0-30f01775b71b','99fb8681-cfe8-581a-bfe9-f2c6cad56746',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('c7eddb9f-b047-55b9-ae52-04979b6a9f39','20000000-0000-0000-0000-000000000007',$p$ieri$p$,$p$ayer$p$,241,'adverbio'),
 ('de9e2b74-3467-56ed-83a5-d809f1b9cdf0','20000000-0000-0000-0000-000000000007',$p$alaltăieri$p$,$p$anteayer$p$,242,'adverbio'),
 ('fbf5e014-a518-5ce0-b4bf-157948e74668','20000000-0000-0000-0000-000000000007',$p$azi-dimineață$p$,$p$esta mañana$p$,243,'adverbio'),
 ('bbbe0259-46be-5636-8628-ea30dce47695','20000000-0000-0000-0000-000000000007',$p$săptămâna trecută$p$,$p$la semana pasada$p$,244,'adverbio'),
 ('fb9ae439-2b4b-553c-8e4e-4287dc4a41ab','20000000-0000-0000-0000-000000000007',$p$acum două zile$p$,$p$hace dos días$p$,245,'adverbio'),
 ('389bec00-6234-5ce4-b147-ec0e0dc275c0','20000000-0000-0000-0000-000000000007',$p$devreme$p$,$p$temprano$p$,246,'adverbio'),
 ('08484f83-4f39-5cf1-9ee4-3ffb06620916','20000000-0000-0000-0000-000000000007',$p$târziu$p$,$p$tarde$p$,247,'adverbio'),
 ('619cfbdb-9f13-5ad5-8862-71d8c35dcac4','20000000-0000-0000-0000-000000000007',$p$a citi$p$,$p$leer$p$,248,'verbo'),
 ('66cb7d7d-5bb6-5d17-92c5-88dfafe6b9f0','20000000-0000-0000-0000-000000000007',$p$a scrie$p$,$p$escribir$p$,249,'verbo'),
 ('0f32fede-876f-54ae-a38e-e48f05819b5a','20000000-0000-0000-0000-000000000007',$p$a bea$p$,$p$beber$p$,250,'verbo'),
 ('31e0ff5a-bae3-5e9d-bdc5-b0d758e03f3f','20000000-0000-0000-0000-000000000007',$p$a vedea$p$,$p$ver$p$,251,'verbo'),
 ('e55913e6-adc9-5fb0-b41a-d1de489ba920','20000000-0000-0000-0000-000000000007',$p$a veni$p$,$p$venir$p$,252,'verbo'),
 ('b684fb17-cc10-5534-a2f4-c5738eb89e33','20000000-0000-0000-0000-000000000007',$p$a dormi$p$,$p$dormir$p$,253,'verbo'),
 ('5f7d5d18-de9f-517a-9f56-4a436cd8d0d4','20000000-0000-0000-0000-000000000007',$p$a face$p$,$p$hacer$p$,254,'verbo'),
 ('c962d281-8121-5b4e-92f6-ebab328c4b31','20000000-0000-0000-0000-000000000007',$p$o carte$p$,$p$el libro$p$,255,'sustantivo'),
 ('ca46b993-0b0c-5ab6-ab6c-4607b823b8cf','20000000-0000-0000-0000-000000000007',$p$un film$p$,$p$la película$p$,256,'sustantivo'),
 ('5496bde6-4ff8-5f77-a50e-aa2411dcba5b','20000000-0000-0000-0000-000000000007',$p$aseară$p$,$p$anoche$p$,257,'adverbio'),
 ('f438da62-3498-5bd0-9a90-960f67bcfd1d','20000000-0000-0000-0000-000000000007',$p$o scrisoare$p$,$p$la carta$p$,258,'sustantivo')
on conflict (id) do nothing;

-- ── Unidad 8 (A2·ro): Planes y futuro ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('91f5e62a-f962-518e-a28a-f61540c3809a','20000000-0000-0000-0000-000000000007','A2',8,$p$Planes y futuro$p$,'#2D9CDB','event')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('b117001e-0973-51f8-aacf-9e27e9a820c2','91f5e62a-f962-518e-a28a-f61540c3809a',1,$p$Vreau să merg: el «să» obligatorio$p$,$p$Vreau să merg: el «să» obligatorio$p$,'lesson',15),
 ('22d4f598-397f-5e88-b5d6-5f1bfe475170','91f5e62a-f962-518e-a28a-f61540c3809a',2,$p$Mâine, poimâine: planes con «o să»$p$,$p$Mâine, poimâine: planes con «o să»$p$,'lesson',15),
 ('6e3a85d9-f789-5651-88e7-8571ed0f3c2c','91f5e62a-f962-518e-a28a-f61540c3809a',3,$p$«Voi merge»: el futuro formal$p$,$p$«Voi merge»: el futuro formal$p$,'lesson',15),
 ('cada18c9-6f46-5450-9528-f7a2247f47e0','91f5e62a-f962-518e-a28a-f61540c3809a',4,$p$La semana y el año que viene$p$,$p$La semana y el año que viene$p$,'lesson',15),
 ('a8df547c-a5c2-5b46-afe7-3f2e4075655d','91f5e62a-f962-518e-a28a-f61540c3809a',5,$p$🏁 Checkpoint Unitatea 8$p$,$p$Repasa el conjunctiv con «să» después de a vrea, a putea, a trebui y a spera, y las tres formas del futuro (o să merg, voi merge, am să merg) con mâine, poimâine, săptămâna viitoare y anul viitor.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('21c5db2e-5fd7-5223-b587-5ce09724bc4e','20000000-0000-0000-0000-000000000007','checkpoint','A2','91f5e62a-f962-518e-a28a-f61540c3809a',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('07986a71-36ae-50e4-98e3-7e2ee456ece1'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','reading','match',$p$Empareja cada verbo rumano con su significado.$p$,$j${"pairs": [{"en": "a vrea", "es": "querer"}, {"en": "a putea", "es": "poder"}, {"en": "a spera", "es": "esperar (tener esperanza)"}]}$j$::jsonb,$j${"pairs": [["a vrea", "querer"], ["a putea", "poder"], ["a spera", "esperar (tener esperanza)"]]}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$conjunctiv_cu_sa$p$, $p$reading$p$]),
('e2e55a9f-195d-5252-a22f-4331f5ba7541'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','writing','cloze',$p$Completa para decir «Quiero ir a Cluj mañana».$p$,$j${"text": "Vreau ___ merg la Cluj mâine."}$j$::jsonb,$j${"value": "să", "accepted": ["să", "sa"]}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$conjunctiv_cu_sa$p$, $p$writing$p$]),
('2a72090c-8d92-5d37-9685-cf9352ea3738'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','writing','translation',$p$Traduce al rumano:$p$,$j${"source": "Tengo que irme ahora."}$j$::jsonb,$j${"value": "Trebuie să plec acum.", "accepted": ["Trebuie să plec acum.", "Trebuie sa plec acum.", "Acum trebuie să plec.", "Acum trebuie sa plec.", "Eu trebuie să plec acum.", "Eu trebuie sa plec acum."]}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$conjunctiv_cu_sa$p$, $p$writing$p$]),
('b93b9ec1-3af3-5b4d-8f34-81df30946bba'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Pot să te ajut?", "Vreau să te ajut.", "Trebuie să te ajut."], "say": "Pot să te ajut?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/b93b9ec1-3af3-5b4d-8f34-81df30946bba.mp3"}$j$::jsonb,$j${"value": "Pot să te ajut?"}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$conjunctiv_cu_sa$p$, $p$listening$p$]),
('8d7f1b21-adb1-5d23-9ecf-5f008b82e1e5'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Vreau să învăț limba română.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/8d7f1b21-adb1-5d23-9ecf-5f008b82e1e5.mp3"}$j$::jsonb,$j${"expected": "Vreau să învăț limba română."}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$conjunctiv_cu_sa$p$, $p$speaking$p$]),
('349b7669-acc6-551d-b287-8308a3429445'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','reading','multiple_choice',$p$¿Cómo se dice «Mañana voy a salir a las ocho»?$p$,$j${"options": ["Mâine o să plec la ora opt.", "Mâine o plec la ora opt.", "Mâine să plec la ora opt."]}$j$::jsonb,$j${"value": "Mâine o să plec la ora opt."}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$o_sa_maine$p$, $p$reading$p$]),
('860bd620-064d-5ad1-9c0f-231345bf6243'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Poimâine o să vină Ana.", "Poimâine o să plece Ana.", "Poimâine o să lucreze Ana."], "say": "Poimâine o să vină Ana.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/860bd620-064d-5ad1-9c0f-231345bf6243.mp3"}$j$::jsonb,$j${"value": "Poimâine o să vină Ana."}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$o_sa_maine$p$, $p$listening$p$]),
('e6470ad6-7a82-552d-a960-4a3a4d9d4dbc'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Diseară o să stau acasă.", "Diseară o să merg la cinema.", "Diseară o să mănânc la restaurant."], "say": "Diseară o să stau acasă.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/e6470ad6-7a82-552d-a960-4a3a4d9d4dbc.mp3"}$j$::jsonb,$j${"value": "Diseară o să stau acasă."}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$o_sa_maine$p$, $p$listening$p$]),
('df81e6b1-25db-5501-a64a-36264a0b784f'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','writing','word_bank',$p$Ordena empezando por «Poimâine» para decir «Pasado mañana vamos a comer en casa».$p$,$j${"tiles": ["acasă", "mâine", "mâncăm", "o", "Poimâine", "să", "voi"]}$j$::jsonb,$j${"value": "Poimâine o să mâncăm acasă", "sequence": ["Poimâine", "o", "să", "mâncăm", "acasă"]}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$o_sa_maine$p$, $p$writing$p$]),
('546b6063-b647-53a2-89ab-59a7c6c810e4'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','writing','translation',$p$Traduce al rumano:$p$,$j${"source": "Mañana voy a ir al mercado."}$j$::jsonb,$j${"value": "Mâine o să merg la piață.", "accepted": ["Mâine o să merg la piață.", "Maine o sa merg la piata.", "Mâine voi merge la piață.", "Maine voi merge la piata.", "Mâine am să merg la piață.", "Maine am sa merg la piata.", "O să merg mâine la piață.", "O sa merg maine la piata.", "Voi merge mâine la piață.", "Am să merg mâine la piață.", "Am sa merg maine la piata.", "Voi merge maine la piata."]}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$o_sa_maine$p$, $p$writing$p$]),
('bca7004b-2267-531f-a2f6-ad5025347e9e'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','reading','match',$p$Empareja cada forma rumana con su traducción.$p$,$j${"pairs": [{"en": "voi lucra", "es": "trabajaré"}, {"en": "vei veni", "es": "vendrás"}, {"en": "va pleca", "es": "se irá"}]}$j$::jsonb,$j${"pairs": [["voi lucra", "trabajaré"], ["vei veni", "vendrás"], ["va pleca", "se irá"]]}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$viitor_voi_merge$p$, $p$reading$p$]),
('00515b2f-08ea-5df7-a809-718e89ffd9e2'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','reading','multiple_choice',$p$«O să mergem la teatru» escrito en registro formal es…$p$,$j${"options": ["Vom merge la teatru.", "Vor merge la teatru.", "Va merge la teatru."]}$j$::jsonb,$j${"value": "Vom merge la teatru."}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$viitor_voi_merge$p$, $p$reading$p$]),
('7de6703b-ca61-59a7-bab1-8a9b9eab79df'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','reading','multiple_choice',$p$«Am să scriu un mesaj» significa…$p$,$j${"options": ["Voy a escribir un mensaje.", "He escrito un mensaje.", "Tengo que escribir un mensaje."]}$j$::jsonb,$j${"value": "Voy a escribir un mensaje."}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$viitor_voi_merge$p$, $p$reading$p$]),
('27a20a55-8a46-5260-9d53-019951867051'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Vom pleca la ora nouă.", "Vom pleca la ora zece.", "Vom mânca la ora nouă."], "say": "Vom pleca la ora nouă.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/27a20a55-8a46-5260-9d53-019951867051.mp3"}$j$::jsonb,$j${"value": "Vom pleca la ora nouă."}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$viitor_voi_merge$p$, $p$listening$p$]),
('0441eb7b-8314-584a-b512-0696048b97c3'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Mâine voi lucra, dar diseară voi fi acasă.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/0441eb7b-8314-584a-b512-0696048b97c3.mp3"}$j$::jsonb,$j${"expected": "Mâine voi lucra, dar diseară voi fi acasă."}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$viitor_voi_merge$p$, $p$speaking$p$]),
('b9adca50-10c4-5f1b-be6b-2f88dcac9a2b'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','reading','multiple_choice',$p$«Săptămâna viitoare» significa…$p$,$j${"options": ["la semana que viene", "la semana pasada", "toda la semana"]}$j$::jsonb,$j${"value": "la semana que viene"}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$planuri_saptamana_viitoare$p$, $p$reading$p$]),
('7f05c84d-527d-5887-b2e7-bcf46702cb36'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','writing','cloze',$p$Completa para decir «El año que viene voy a trabajar en Bucarest».$p$,$j${"text": "Anul viitor ___ la București."}$j$::jsonb,$j${"value": "o să lucrez", "accepted": ["o să lucrez", "o sa lucrez", "voi lucra", "am să lucrez", "am sa lucrez"]}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$planuri_saptamana_viitoare$p$, $p$writing$p$]),
('5dc411e8-f9fc-5361-b263-9ded176d3010'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Anul viitor o să învăț limba română.", "Anul viitor o să vizitez România.", "Anul viitor o să lucrez în România."], "say": "Anul viitor o să învăț limba română.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/5dc411e8-f9fc-5361-b263-9ded176d3010.mp3"}$j$::jsonb,$j${"value": "Anul viitor o să învăț limba română."}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$planuri_saptamana_viitoare$p$, $p$listening$p$]),
('29293cf4-0beb-50a5-980a-6a420b917559'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','writing','reorder',$p$Ordena empezando por «Sper» y terminando en «România»: «Espero ir a Rumanía la semana que viene».$p$,$j${"tiles": ["în", "merg", "România", "să", "săptămâna", "Sper", "viitoare"]}$j$::jsonb,$j${"value": "Sper să merg în România săptămâna viitoare"}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$planuri_saptamana_viitoare$p$, $p$writing$p$]),
('0d122988-2b2a-58ff-8377-82c79f2a78dc'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Anul viitor o să merg în România cu prietenii.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/0d122988-2b2a-58ff-8377-82c79f2a78dc.mp3"}$j$::jsonb,$j${"expected": "Anul viitor o să merg în România cu prietenii."}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$planuri_saptamana_viitoare$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('b117001e-0973-51f8-aacf-9e27e9a820c2','07986a71-36ae-50e4-98e3-7e2ee456ece1',1),
 ('b117001e-0973-51f8-aacf-9e27e9a820c2','e2e55a9f-195d-5252-a22f-4331f5ba7541',2),
 ('b117001e-0973-51f8-aacf-9e27e9a820c2','2a72090c-8d92-5d37-9685-cf9352ea3738',3),
 ('b117001e-0973-51f8-aacf-9e27e9a820c2','b93b9ec1-3af3-5b4d-8f34-81df30946bba',4),
 ('b117001e-0973-51f8-aacf-9e27e9a820c2','8d7f1b21-adb1-5d23-9ecf-5f008b82e1e5',5),
 ('22d4f598-397f-5e88-b5d6-5f1bfe475170','349b7669-acc6-551d-b287-8308a3429445',1),
 ('22d4f598-397f-5e88-b5d6-5f1bfe475170','860bd620-064d-5ad1-9c0f-231345bf6243',2),
 ('22d4f598-397f-5e88-b5d6-5f1bfe475170','e6470ad6-7a82-552d-a960-4a3a4d9d4dbc',3),
 ('22d4f598-397f-5e88-b5d6-5f1bfe475170','df81e6b1-25db-5501-a64a-36264a0b784f',4),
 ('22d4f598-397f-5e88-b5d6-5f1bfe475170','546b6063-b647-53a2-89ab-59a7c6c810e4',5),
 ('6e3a85d9-f789-5651-88e7-8571ed0f3c2c','bca7004b-2267-531f-a2f6-ad5025347e9e',1),
 ('6e3a85d9-f789-5651-88e7-8571ed0f3c2c','00515b2f-08ea-5df7-a809-718e89ffd9e2',2),
 ('6e3a85d9-f789-5651-88e7-8571ed0f3c2c','7de6703b-ca61-59a7-bab1-8a9b9eab79df',3),
 ('6e3a85d9-f789-5651-88e7-8571ed0f3c2c','27a20a55-8a46-5260-9d53-019951867051',4),
 ('6e3a85d9-f789-5651-88e7-8571ed0f3c2c','0441eb7b-8314-584a-b512-0696048b97c3',5),
 ('cada18c9-6f46-5450-9528-f7a2247f47e0','b9adca50-10c4-5f1b-be6b-2f88dcac9a2b',1),
 ('cada18c9-6f46-5450-9528-f7a2247f47e0','7f05c84d-527d-5887-b2e7-bcf46702cb36',2),
 ('cada18c9-6f46-5450-9528-f7a2247f47e0','5dc411e8-f9fc-5361-b263-9ded176d3010',3),
 ('cada18c9-6f46-5450-9528-f7a2247f47e0','29293cf4-0beb-50a5-980a-6a420b917559',4),
 ('cada18c9-6f46-5450-9528-f7a2247f47e0','0d122988-2b2a-58ff-8377-82c79f2a78dc',5),
 ('a8df547c-a5c2-5b46-afe7-3f2e4075655d','07986a71-36ae-50e4-98e3-7e2ee456ece1',1),
 ('a8df547c-a5c2-5b46-afe7-3f2e4075655d','349b7669-acc6-551d-b287-8308a3429445',2),
 ('a8df547c-a5c2-5b46-afe7-3f2e4075655d','bca7004b-2267-531f-a2f6-ad5025347e9e',3),
 ('a8df547c-a5c2-5b46-afe7-3f2e4075655d','e2e55a9f-195d-5252-a22f-4331f5ba7541',4),
 ('a8df547c-a5c2-5b46-afe7-3f2e4075655d','2a72090c-8d92-5d37-9685-cf9352ea3738',5),
 ('a8df547c-a5c2-5b46-afe7-3f2e4075655d','df81e6b1-25db-5501-a64a-36264a0b784f',6),
 ('a8df547c-a5c2-5b46-afe7-3f2e4075655d','b93b9ec1-3af3-5b4d-8f34-81df30946bba',7),
 ('a8df547c-a5c2-5b46-afe7-3f2e4075655d','860bd620-064d-5ad1-9c0f-231345bf6243',8),
 ('a8df547c-a5c2-5b46-afe7-3f2e4075655d','8d7f1b21-adb1-5d23-9ecf-5f008b82e1e5',9),
 ('a8df547c-a5c2-5b46-afe7-3f2e4075655d','0441eb7b-8314-584a-b512-0696048b97c3',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('a507bf37-7def-5540-a811-b93356dddb72','20000000-0000-0000-0000-000000000007',$p$mâine$p$,$p$mañana$p$,261,'adverbio'),
 ('258699f0-966f-596d-bd13-b32c97f7099a','20000000-0000-0000-0000-000000000007',$p$poimâine$p$,$p$pasado mañana$p$,262,'adverbio'),
 ('0b6e1a45-b1c4-543c-8af3-6da55152855a','20000000-0000-0000-0000-000000000007',$p$diseară$p$,$p$esta noche$p$,263,'adverbio'),
 ('c4d6b340-8fff-5260-a5eb-f373165f3050','20000000-0000-0000-0000-000000000007',$p$acasă$p$,$p$en casa, a casa$p$,264,'adverbio'),
 ('ab583390-225a-5aba-af2d-fa15e9e17b47','20000000-0000-0000-0000-000000000007',$p$viitor / viitoare$p$,$p$próximo, que viene (m./f.)$p$,265,'adjetivo'),
 ('5269b895-e685-5254-956a-22f2afde5366','20000000-0000-0000-0000-000000000007',$p$o săptămână$p$,$p$una semana$p$,266,'sustantivo'),
 ('917781e0-7026-52ad-bb32-239da23e791c','20000000-0000-0000-0000-000000000007',$p$un an$p$,$p$un año$p$,267,'sustantivo'),
 ('5c642c8d-2ad9-5abb-a098-9c651f987287','20000000-0000-0000-0000-000000000007',$p$un plan$p$,$p$un plan$p$,268,'sustantivo'),
 ('d7996be6-d7b5-5317-b358-78955a4b2a25','20000000-0000-0000-0000-000000000007',$p$o piață$p$,$p$un mercado; una plaza$p$,269,'sustantivo'),
 ('2b548628-0884-56ea-b20a-ccea9a1fd56f','20000000-0000-0000-0000-000000000007',$p$a vrea$p$,$p$querer$p$,270,'verbo'),
 ('552e412e-9025-5da3-a51f-7dc3559a3084','20000000-0000-0000-0000-000000000007',$p$a putea$p$,$p$poder$p$,271,'verbo'),
 ('84a67b08-2016-596c-9bd9-a22e28cf99fc','20000000-0000-0000-0000-000000000007',$p$a trebui$p$,$p$tener que, deber$p$,272,'verbo'),
 ('ab441c09-8d21-5b6e-8c81-c359fe34b2fa','20000000-0000-0000-0000-000000000007',$p$a spera$p$,$p$esperar (tener esperanza)$p$,273,'verbo'),
 ('a1d78f01-2e6e-5881-bf65-45257e24025e','20000000-0000-0000-0000-000000000007',$p$a pleca$p$,$p$irse, marcharse$p$,274,'verbo'),
 ('61da2b6b-07ff-5de2-8ac8-67bed089509b','20000000-0000-0000-0000-000000000007',$p$a învăța$p$,$p$aprender$p$,275,'verbo'),
 ('fbcb9330-f4f3-5f36-9774-870d34d9da5d','20000000-0000-0000-0000-000000000007',$p$a vizita$p$,$p$visitar$p$,276,'verbo'),
 ('19168d03-1e10-5c2e-8e91-f535f86e8353','20000000-0000-0000-0000-000000000007',$p$a ajuta$p$,$p$ayudar$p$,277,'verbo'),
 ('5ebe312f-163f-5643-94a1-da8c3b313fb6','20000000-0000-0000-0000-000000000007',$p$a sta$p$,$p$quedarse, estar$p$,278,'verbo')
on conflict (id) do nothing;

-- ── Unidad 9 (A2·ro): De viaje: trenes, aviones y billetes ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('b4c32fe4-5471-5e90-bb17-711edd112f41','20000000-0000-0000-0000-000000000007','A2',9,$p$De viaje: trenes, aviones y billetes$p$,'#56CCF2','train')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('5e87d0ef-c9f0-5276-b3db-fb8f473b5ec0','b4c32fe4-5471-5e90-bb17-711edd112f41',1,$p$En la estación: tren, billete y maleta$p$,$p$En la estación: tren, billete y maleta$p$,'lesson',15),
 ('fb63c9eb-e8e2-5103-aed1-ad35eb338120','b4c32fe4-5471-5e90-bb17-711edd112f41',2,$p$Voy en tren: «cu trenul», «cu mașina»$p$,$p$Voy en tren: «cu trenul», «cu mașina»$p$,'lesson',15),
 ('89baf4f1-e44b-5040-a311-188ab19fa10f','b4c32fe4-5471-5e90-bb17-711edd112f41',3,$p$Comprar el billete y preguntar$p$,$p$Comprar el billete y preguntar$p$,'lesson',15),
 ('ee3459cd-c619-509c-9ded-7787a9f6e0df','b4c32fe4-5471-5e90-bb17-711edd112f41',4,$p$Salir y llegar: ayer y mañana$p$,$p$Salir y llegar: ayer y mañana$p$,'lesson',15),
 ('754c37a4-4626-5ea7-a877-72fe968a756b','b4c32fe4-5471-5e90-bb17-711edd112f41',5,$p$🏁 Checkpoint Unitatea 9$p$,$p$Repasa el vocabulario de viaje con su género, «cu» + el medio de transporte con el artículo pegado (cu trenul, cu avionul), comprar un billete y preguntar la hora y el andén, y la diferencia entre a pleca (salir) y a sosi/a ajunge (llegar) en pasado y en futuro.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('d4a3cafb-f299-5a99-bb77-b36a822a5e0b','20000000-0000-0000-0000-000000000007','checkpoint','A2','b4c32fe4-5471-5e90-bb17-711edd112f41',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('bd8dc13a-66a0-504a-a10a-d9db4d622fac'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','reading','match',$p$Empareja cada palabra rumana con su significado.$p$,$j${"pairs": [{"en": "gară", "es": "la estación (de tren)"}, {"en": "bilet", "es": "el billete"}, {"en": "valiză", "es": "la maleta"}]}$j$::jsonb,$j${"pairs": [["gară", "la estación (de tren)"], ["bilet", "el billete"], ["valiză", "la maleta"]]}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$la_gara$p$, $p$reading$p$]),
('f431636f-c64f-5a6e-8bd7-7891da72b1fb'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','reading','multiple_choice',$p$¿Qué significa «Valiza mea este în tren»?$p$,$j${"options": ["Mi maleta está en el tren.", "Mi billete está en el tren.", "Mi maleta está en el avión."]}$j$::jsonb,$j${"value": "Mi maleta está en el tren."}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$la_gara$p$, $p$reading$p$]),
('601a922f-7f97-5c07-ad2b-465e0234465c'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Biletul este în valiză.", "Biletul este în gară.", "Valiza este în tren."], "say": "Biletul este în valiză.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/601a922f-7f97-5c07-ad2b-465e0234465c.mp3"}$j$::jsonb,$j${"value": "Biletul este în valiză."}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$la_gara$p$, $p$listening$p$]),
('6a32cf4d-cb41-5c5b-91e0-f220ac8724f7'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','writing','cloze',$p$Completa con el artículo pegado al final: «Mi maleta está aquí».$p$,$j${"text": "___ mea este aici."}$j$::jsonb,$j${"value": "Valiza", "accepted": ["Valiza", "valiza"]}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$la_gara$p$, $p$writing$p$]),
('93c7d37a-79e7-5049-a856-97e3ec4dfd33'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Am un bilet și o valiză mare.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/93c7d37a-79e7-5049-a856-97e3ec4dfd33.mp3"}$j$::jsonb,$j${"expected": "Am un bilet și o valiză mare."}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$la_gara$p$, $p$speaking$p$]),
('70c0c826-d634-5c76-a4a6-63fa2f276dbc'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','reading','multiple_choice',$p$Completa: «Merg la Brașov ___.» = «Voy a Brașov en tren.»$p$,$j${"options": ["cu trenul", "cu tren", "în trenul"]}$j$::jsonb,$j${"value": "cu trenul"}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$cu_trenul$p$, $p$reading$p$]),
('6ad2ae5b-bc16-51d2-90dd-a053683f19f4'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Merg la muncă cu autobuzul.", "Merg la muncă cu mașina.", "Merg la muncă cu trenul."], "say": "Merg la muncă cu autobuzul.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/6ad2ae5b-bc16-51d2-90dd-a053683f19f4.mp3"}$j$::jsonb,$j${"value": "Merg la muncă cu autobuzul."}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$cu_trenul$p$, $p$listening$p$]),
('6e0bea5e-517d-5280-881d-426b6a1b8c6e'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Am călătorit cu avionul.", "Am călătorit cu trenul.", "Am călătorit cu mașina."], "say": "Am călătorit cu avionul.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/6e0bea5e-517d-5280-881d-426b6a1b8c6e.mp3"}$j$::jsonb,$j${"value": "Am călătorit cu avionul."}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$cu_trenul$p$, $p$listening$p$]),
('cd8b601a-1f65-5a5e-86a8-5eb171196de0'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','writing','word_bank',$p$Ordena empezando por «Ana» para decir «Ana va en autobús».$p$,$j${"tiles": ["Ana", "autobuz", "autobuzul", "cu", "merge", "trenul"]}$j$::jsonb,$j${"value": "Ana merge cu autobuzul", "sequence": ["Ana", "merge", "cu", "autobuzul"]}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$cu_trenul$p$, $p$writing$p$]),
('e9da51d2-dbd3-5b72-bfb3-6466bd41771a'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','writing','translation',$p$Traduce al rumano:$p$,$j${"source": "Viajo en tren."}$j$::jsonb,$j${"value": "Călătoresc cu trenul.", "accepted": ["Călătoresc cu trenul.", "Calatoresc cu trenul.", "Eu călătoresc cu trenul.", "Eu calatoresc cu trenul.", "Merg cu trenul.", "Eu merg cu trenul."]}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$cu_trenul$p$, $p$writing$p$]),
('d4f9da62-77e8-5ce2-8003-21a0bca81356'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','reading','match',$p$Empareja cada frase de la estación con su significado.$p$,$j${"pairs": [{"en": "Un bilet până la Cluj, vă rog.", "es": "Un billete hasta Cluj, por favor."}, {"en": "La ce oră pleacă trenul?", "es": "¿A qué hora sale el tren?"}, {"en": "De la ce peron?", "es": "¿De qué andén?"}]}$j$::jsonb,$j${"pairs": [["Un bilet până la Cluj, vă rog.", "Un billete hasta Cluj, por favor."], ["La ce oră pleacă trenul?", "¿A qué hora sale el tren?"], ["De la ce peron?", "¿De qué andén?"]]}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$cumpar_bilet$p$, $p$reading$p$]),
('1e4c2d43-28b1-52ae-917e-3fcea15bb71e'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','reading','multiple_choice',$p$Estás en la taquilla y quieres viajar hasta Iași. ¿Qué dices?$p$,$j${"options": ["Un bilet până la Iași, vă rog.", "Un bilet de la Iași, vă rog.", "Un tren până la Iași, vă rog."]}$j$::jsonb,$j${"value": "Un bilet până la Iași, vă rog."}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$cumpar_bilet$p$, $p$reading$p$]),
('a2d154e3-06de-52d1-b42b-5a7019da39a5'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["De la ce peron pleacă trenul?", "La ce oră pleacă trenul?", "De la ce peron pleacă autobuzul?"], "say": "De la ce peron pleacă trenul?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/a2d154e3-06de-52d1-b42b-5a7019da39a5.mp3"}$j$::jsonb,$j${"value": "De la ce peron pleacă trenul?"}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$cumpar_bilet$p$, $p$listening$p$]),
('9d32108a-d87e-5bb3-bf73-a8c71cf95202'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','writing','translation',$p$Traduce al rumano:$p$,$j${"source": "Ayer el tren llegó con retraso."}$j$::jsonb,$j${"value": "Ieri trenul a sosit cu întârziere.", "accepted": ["Ieri trenul a sosit cu întârziere.", "Trenul a sosit ieri cu întârziere.", "Ieri trenul a ajuns cu întârziere.", "Trenul a ajuns ieri cu întârziere.", "Ieri trenul a ajuns cu intarziere.", "Ieri trenul a sosit cu intarziere.", "Trenul a ajuns ieri cu intarziere.", "Trenul a sosit ieri cu intarziere."]}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$cumpar_bilet$p$, $p$writing$p$]),
('f75d51da-1929-5f92-8b7a-f3d7c9abaeaf'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Un bilet până la Cluj, vă rog.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/f75d51da-1929-5f92-8b7a-f3d7c9abaeaf.mp3"}$j$::jsonb,$j${"expected": "Un bilet până la Cluj, vă rog."}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$cumpar_bilet$p$, $p$speaking$p$]),
('d694368c-5cd6-5db3-a7f2-6e0cdc939597'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','reading','multiple_choice',$p$¿Qué significa «Trenul pleacă la ora opt»?$p$,$j${"options": ["El tren sale a las ocho.", "El tren llega a las ocho.", "El tren para a las ocho."]}$j$::jsonb,$j${"value": "El tren sale a las ocho."}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$plecare_sosire$p$, $p$reading$p$]),
('c50a4775-74ff-5f58-9922-c92227d52cac'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Trenul sosește la ora zece.", "Trenul pleacă la ora zece.", "Trenul sosește la ora nouă."], "say": "Trenul sosește la ora zece.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/c50a4775-74ff-5f58-9922-c92227d52cac.mp3"}$j$::jsonb,$j${"value": "Trenul sosește la ora zece."}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$plecare_sosire$p$, $p$listening$p$]),
('5c4e6740-9c92-507d-81ba-02f19effa77f'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','writing','cloze',$p$Completa hablando del futuro: «Mañana iré a Cluj en tren.»$p$,$j${"text": "Mâine ___ la Cluj cu trenul."}$j$::jsonb,$j${"value": "o să merg", "accepted": ["o să merg", "am să merg", "voi merge", "o să plec", "am să plec", "voi pleca", "o sa merg", "am sa merg", "o sa plec", "am sa plec"]}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$plecare_sosire$p$, $p$writing$p$]),
('45bda85f-3838-5aed-9b89-a34590c4f99d'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','writing','reorder',$p$Ordena empezando por «Vreau»: «Quiero ir en tren».$p$,$j${"tiles": ["cu", "merg", "să", "trenul", "Vreau"]}$j$::jsonb,$j${"value": "Vreau să merg cu trenul"}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$plecare_sosire$p$, $p$writing$p$]),
('8e74e43f-8f59-5001-badb-8ec6fc3f9ccf'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Trenul pleacă la ora opt și ajunge la zece.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/8e74e43f-8f59-5001-badb-8ec6fc3f9ccf.mp3"}$j$::jsonb,$j${"expected": "Trenul pleacă la ora opt și ajunge la zece."}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$plecare_sosire$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('5e87d0ef-c9f0-5276-b3db-fb8f473b5ec0','bd8dc13a-66a0-504a-a10a-d9db4d622fac',1),
 ('5e87d0ef-c9f0-5276-b3db-fb8f473b5ec0','f431636f-c64f-5a6e-8bd7-7891da72b1fb',2),
 ('5e87d0ef-c9f0-5276-b3db-fb8f473b5ec0','601a922f-7f97-5c07-ad2b-465e0234465c',3),
 ('5e87d0ef-c9f0-5276-b3db-fb8f473b5ec0','6a32cf4d-cb41-5c5b-91e0-f220ac8724f7',4),
 ('5e87d0ef-c9f0-5276-b3db-fb8f473b5ec0','93c7d37a-79e7-5049-a856-97e3ec4dfd33',5),
 ('fb63c9eb-e8e2-5103-aed1-ad35eb338120','70c0c826-d634-5c76-a4a6-63fa2f276dbc',1),
 ('fb63c9eb-e8e2-5103-aed1-ad35eb338120','6ad2ae5b-bc16-51d2-90dd-a053683f19f4',2),
 ('fb63c9eb-e8e2-5103-aed1-ad35eb338120','6e0bea5e-517d-5280-881d-426b6a1b8c6e',3),
 ('fb63c9eb-e8e2-5103-aed1-ad35eb338120','cd8b601a-1f65-5a5e-86a8-5eb171196de0',4),
 ('fb63c9eb-e8e2-5103-aed1-ad35eb338120','e9da51d2-dbd3-5b72-bfb3-6466bd41771a',5),
 ('89baf4f1-e44b-5040-a311-188ab19fa10f','d4f9da62-77e8-5ce2-8003-21a0bca81356',1),
 ('89baf4f1-e44b-5040-a311-188ab19fa10f','1e4c2d43-28b1-52ae-917e-3fcea15bb71e',2),
 ('89baf4f1-e44b-5040-a311-188ab19fa10f','a2d154e3-06de-52d1-b42b-5a7019da39a5',3),
 ('89baf4f1-e44b-5040-a311-188ab19fa10f','f75d51da-1929-5f92-8b7a-f3d7c9abaeaf',4),
 ('ee3459cd-c619-509c-9ded-7787a9f6e0df','9d32108a-d87e-5bb3-bf73-a8c71cf95202',1),
 ('ee3459cd-c619-509c-9ded-7787a9f6e0df','d694368c-5cd6-5db3-a7f2-6e0cdc939597',2),
 ('ee3459cd-c619-509c-9ded-7787a9f6e0df','c50a4775-74ff-5f58-9922-c92227d52cac',3),
 ('ee3459cd-c619-509c-9ded-7787a9f6e0df','5c4e6740-9c92-507d-81ba-02f19effa77f',4),
 ('ee3459cd-c619-509c-9ded-7787a9f6e0df','45bda85f-3838-5aed-9b89-a34590c4f99d',5),
 ('ee3459cd-c619-509c-9ded-7787a9f6e0df','8e74e43f-8f59-5001-badb-8ec6fc3f9ccf',6),
 ('754c37a4-4626-5ea7-a877-72fe968a756b','bd8dc13a-66a0-504a-a10a-d9db4d622fac',1),
 ('754c37a4-4626-5ea7-a877-72fe968a756b','f431636f-c64f-5a6e-8bd7-7891da72b1fb',2),
 ('754c37a4-4626-5ea7-a877-72fe968a756b','70c0c826-d634-5c76-a4a6-63fa2f276dbc',3),
 ('754c37a4-4626-5ea7-a877-72fe968a756b','6a32cf4d-cb41-5c5b-91e0-f220ac8724f7',4),
 ('754c37a4-4626-5ea7-a877-72fe968a756b','cd8b601a-1f65-5a5e-86a8-5eb171196de0',5),
 ('754c37a4-4626-5ea7-a877-72fe968a756b','e9da51d2-dbd3-5b72-bfb3-6466bd41771a',6),
 ('754c37a4-4626-5ea7-a877-72fe968a756b','601a922f-7f97-5c07-ad2b-465e0234465c',7),
 ('754c37a4-4626-5ea7-a877-72fe968a756b','6ad2ae5b-bc16-51d2-90dd-a053683f19f4',8),
 ('754c37a4-4626-5ea7-a877-72fe968a756b','93c7d37a-79e7-5049-a856-97e3ec4dfd33',9),
 ('754c37a4-4626-5ea7-a877-72fe968a756b','f75d51da-1929-5f92-8b7a-f3d7c9abaeaf',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('72e0554b-0a96-52d1-af32-2444ee2917e2','20000000-0000-0000-0000-000000000007',$p$un tren$p$,$p$el tren$p$,281,'sustantivo'),
 ('9acd56ee-da3f-5908-a3d8-075572298633','20000000-0000-0000-0000-000000000007',$p$o gară$p$,$p$la estación (de tren)$p$,282,'sustantivo'),
 ('db457179-2cab-509b-8702-8acd82192165','20000000-0000-0000-0000-000000000007',$p$un peron$p$,$p$el andén$p$,283,'sustantivo'),
 ('163e96f1-64d9-55d8-9afd-16b78a0802bd','20000000-0000-0000-0000-000000000007',$p$un bilet$p$,$p$el billete$p$,284,'sustantivo'),
 ('82fdadbc-5930-5b5c-a940-f5007a023ffd','20000000-0000-0000-0000-000000000007',$p$un loc$p$,$p$el asiento, la plaza$p$,285,'sustantivo'),
 ('2794b34f-8402-5a3c-887b-75a9c264ac2c','20000000-0000-0000-0000-000000000007',$p$un avion$p$,$p$el avión$p$,286,'sustantivo'),
 ('71d4b29a-24a4-50f0-aa8b-f9f94b8ecb02','20000000-0000-0000-0000-000000000007',$p$un aeroport$p$,$p$el aeropuerto$p$,287,'sustantivo'),
 ('605b02a9-1bb5-5951-8d6d-aafb56f38387','20000000-0000-0000-0000-000000000007',$p$un autobuz$p$,$p$el autobús$p$,288,'sustantivo'),
 ('d29fcf26-f823-5bdf-bb10-f57b339d7de7','20000000-0000-0000-0000-000000000007',$p$o mașină$p$,$p$el coche$p$,289,'sustantivo'),
 ('8c5d80c9-6060-561c-81e0-99377022df62','20000000-0000-0000-0000-000000000007',$p$o valiză$p$,$p$la maleta$p$,290,'sustantivo'),
 ('8ffb05b0-12c3-55af-bda4-66174873c70f','20000000-0000-0000-0000-000000000007',$p$un hotel$p$,$p$el hotel$p$,291,'sustantivo'),
 ('46a736de-16c9-5ff3-b321-38cdc8d513d3','20000000-0000-0000-0000-000000000007',$p$o rezervare$p$,$p$la reserva$p$,292,'sustantivo'),
 ('7f7f24a8-f6b9-5119-9dcd-2f5d94f2aa5e','20000000-0000-0000-0000-000000000007',$p$o călătorie$p$,$p$el viaje$p$,293,'sustantivo'),
 ('ac610035-ef29-5691-9d2a-0cbb362cf377','20000000-0000-0000-0000-000000000007',$p$o întârziere$p$,$p$el retraso$p$,294,'sustantivo'),
 ('6ae25ead-253f-5ad7-9059-986a7da7ab64','20000000-0000-0000-0000-000000000007',$p$a pleca$p$,$p$irse, salir (un tren, un avión)$p$,295,'verbo'),
 ('7bc50b49-2682-5ea2-9ab2-350e08c24603','20000000-0000-0000-0000-000000000007',$p$a sosi$p$,$p$llegar$p$,296,'verbo'),
 ('4ad6ef4b-2a1f-5008-839f-46ce209645a4','20000000-0000-0000-0000-000000000007',$p$a ajunge$p$,$p$llegar (a un sitio)$p$,297,'verbo'),
 ('7962aaac-fb9d-5d36-8d21-3145a6e82fef','20000000-0000-0000-0000-000000000007',$p$a călători$p$,$p$viajar$p$,298,'verbo')
on conflict (id) do nothing;

-- ── Unidad 10 (A2·ro): Comer fuera y comprar ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('d12bbdc9-067e-54cc-b160-4c62f55f5454','20000000-0000-0000-0000-000000000007','A2',10,$p$Comer fuera y comprar$p$,'#EB5757','shopping_bag')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('243a834a-3f5d-5e26-adb5-7b19545edb09','d12bbdc9-067e-54cc-b160-4c62f55f5454',1,$p$En el restaurante: qué nos recomienda$p$,$p$En el restaurante: qué nos recomienda$p$,'lesson',15),
 ('4efb8a62-dc79-55dc-b746-a9b8a7f3d11d','d12bbdc9-067e-54cc-b160-4c62f55f5454',2,$p$Comparar: mai … decât$p$,$p$Comparar: mai … decât$p$,'lesson',15),
 ('d02636d0-a408-58b8-99cf-c5bbd483c017','d12bbdc9-067e-54cc-b160-4c62f55f5454',3,$p$El superlativo: cel mai / cea mai$p$,$p$El superlativo: cel mai / cea mai$p$,'lesson',15),
 ('408492da-ca26-5544-b756-62525797ee40','d12bbdc9-067e-54cc-b160-4c62f55f5454',4,$p$De compras: Cât costă? y a proba$p$,$p$De compras: Cât costă? y a proba$p$,'lesson',15),
 ('d5ee0c4a-5d15-5aaa-a851-256d66c90642','d12bbdc9-067e-54cc-b160-4c62f55f5454',5,$p$🏁 Checkpoint Unitatea 10$p$,$p$Repasa el comparativo «mai … decât», el superlativo «cel mai / cea mai» con su concordancia, el vocabulario del restaurante y de las compras (Cât costă?, a proba, o mărime) y las cantidades mult / puțin / destul / prea.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('e6f4d959-6922-550b-b89e-faf5ebf90272','20000000-0000-0000-0000-000000000007','checkpoint','A2','d12bbdc9-067e-54cc-b160-4c62f55f5454',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('1a52b550-b66a-5291-b6ac-fe4bb33ef099'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','reading','match',$p$Empareja cada expresión rumana con su traducción.$p$,$j${"pairs": [{"en": "o gustare", "es": "un entrante"}, {"en": "un fel principal", "es": "un plato principal"}, {"en": "a plăti", "es": "pagar"}]}$j$::jsonb,$j${"pairs": [["o gustare", "un entrante"], ["un fel principal", "un plato principal"], ["a plăti", "pagar"]]}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$la_restaurant$p$, $p$reading$p$]),
('aa7e5c59-cd9a-5a52-9099-98006abb5c25'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','reading','multiple_choice',$p$Estás en un restaurante con un amigo y le preguntas al camarero, tratándolo de usted: «¿Qué nos recomienda?». ¿Cuál es la forma correcta?$p$,$j${"options": ["Ce ne recomandați?", "Ce ne recomanzi?", "Ce vă recomandați?"]}$j$::jsonb,$j${"value": "Ce ne recomandați?"}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$la_restaurant$p$, $p$reading$p$]),
('4ab47ec2-2c46-5891-8092-9a5b93f7a32b'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ca fel principal, aș vrea pește.", "Ca fel principal, aș vrea pui.", "Ca gustare, aș vrea o salată."], "say": "Ca fel principal, aș vrea pește.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/4ab47ec2-2c46-5891-8092-9a5b93f7a32b.mp3"}$j$::jsonb,$j${"value": "Ca fel principal, aș vrea pește."}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$la_restaurant$p$, $p$listening$p$]),
('28e86424-df32-53a2-8bb6-32b01145cdb2'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','writing','translation',$p$Traduce al rumano:$p$,$j${"source": "He comido bastante, gracias."}$j$::jsonb,$j${"value": "Am mâncat destul, mulțumesc.", "accepted": ["Am mâncat destul, mulțumesc.", "Am mâncat destul, mulțumesc", "Am mancat destul, multumesc.", "Am mancat destul, multumesc", "Am mâncat destul. Mulțumesc.", "Am mancat destul. Multumesc.", "Am mâncat suficient, mulțumesc.", "Am mancat suficient, multumesc.", "Am mâncat suficient, mulțumesc", "Am mancat suficient, multumesc", "Am mâncat destul, eu mulțumesc.", "Am mancat destul, eu multumesc."]}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$la_restaurant$p$, $p$writing$p$]),
('4185439f-05be-5bbc-b6bd-0c8bf9b4db66'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Ca desert, aș vrea o înghețată.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/4185439f-05be-5bbc-b6bd-0c8bf9b4db66.mp3"}$j$::jsonb,$j${"expected": "Ca desert, aș vrea o înghețată."}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$la_restaurant$p$, $p$speaking$p$]),
('3f377a00-790f-53a7-8f1f-65297462bc7b'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','reading','multiple_choice',$p$Quieres decir «El restaurante nuevo es más barato que este». ¿Cuál es la forma correcta?$p$,$j${"options": ["Restaurantul nou este mai ieftin decât acesta.", "Restaurantul nou este mai ieftină decât acesta.", "Restaurantul nou este ieftin mai decât acesta."]}$j$::jsonb,$j${"value": "Restaurantul nou este mai ieftin decât acesta."}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$comparativ$p$, $p$reading$p$]),
('3655414a-f534-51cd-92ce-4767987a7a9b'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Cafeaua este mai ieftină decât berea.", "Cafeaua este mai scumpă decât berea.", "Cafeaua este mai ieftină decât vinul."], "say": "Cafeaua este mai ieftină decât berea.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/3655414a-f534-51cd-92ce-4767987a7a9b.mp3"}$j$::jsonb,$j${"value": "Cafeaua este mai ieftină decât berea."}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$comparativ$p$, $p$listening$p$]),
('77a2bab4-2b3d-5e01-a0e9-75eaadf0f1fc'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Andrei mănâncă mai mult decât mine.", "Andrei mănâncă mai puțin decât mine.", "Maria mănâncă mai mult decât mine."], "say": "Andrei mănâncă mai mult decât mine.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/77a2bab4-2b3d-5e01-a0e9-75eaadf0f1fc.mp3"}$j$::jsonb,$j${"value": "Andrei mănâncă mai mult decât mine."}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$comparativ$p$, $p$listening$p$]),
('7c171ce4-95fe-5e2b-9f87-3c94c1ed172a'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','writing','cloze',$p$Completa: «El vino es más caro que la cerveza».$p$,$j${"text": "Vinul este ___ scump decât berea."}$j$::jsonb,$j${"value": "mai", "accepted": ["mai"]}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$comparativ$p$, $p$writing$p$]),
('443a1801-c53b-5c84-a4fb-34428ee13753'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','writing','word_bank',$p$Ordena para decir «El té es más barato que el café».$p$,$j${"tiles": ["cafeaua", "Ceaiul", "decât", "este", "ieftin", "ieftină", "mai", "scump"]}$j$::jsonb,$j${"value": "Ceaiul este mai ieftin decât cafeaua", "sequence": ["Ceaiul", "este", "mai", "ieftin", "decât", "cafeaua"]}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$comparativ$p$, $p$writing$p$]),
('99d4d9b0-c76d-5d13-9cd5-4adb0151cac7'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','reading','match',$p$Empareja cada superlativo rumano con su traducción.$p$,$j${"pairs": [{"en": "cel mai bun", "es": "el mejor"}, {"en": "cea mai bună", "es": "la mejor"}, {"en": "cel mai ieftin", "es": "el más barato"}]}$j$::jsonb,$j${"pairs": [["cel mai bun", "el mejor"], ["cea mai bună", "la mejor"], ["cel mai ieftin", "el más barato"]]}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$superlativ$p$, $p$reading$p$]),
('864e4d90-9a17-5141-95ec-524663b6e739'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','reading','multiple_choice',$p$Quieres decir «Es la mejor sopa de la ciudad». ¿Cuál es la forma correcta?$p$,$j${"options": ["Este cea mai bună supă din oraș.", "Este cel mai bună supă din oraș.", "Este cea mai bun supă din oraș."]}$j$::jsonb,$j${"value": "Este cea mai bună supă din oraș."}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$superlativ$p$, $p$reading$p$]),
('d0d86844-93f8-5ea6-82a2-83b7965081bb'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Acesta este cel mai bun restaurant din oraș.", "Acesta este cel mai scump restaurant din oraș.", "Aceasta este cea mai bună cafenea din oraș."], "say": "Acesta este cel mai bun restaurant din oraș.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/d0d86844-93f8-5ea6-82a2-83b7965081bb.mp3"}$j$::jsonb,$j${"value": "Acesta este cel mai bun restaurant din oraș."}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$superlativ$p$, $p$listening$p$]),
('9f121b66-5018-50ed-8e7d-4b272afbb752'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','writing','cloze',$p$Completa el superlativo: «Aquí está el mejor café de la ciudad».$p$,$j${"text": "Aici este ___ mai bună cafea din oraș."}$j$::jsonb,$j${"value": "cea", "accepted": ["cea"]}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$superlativ$p$, $p$writing$p$]),
('6b0c0b6a-72ba-5033-8233-9573dfa2de46'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Care este cel mai bun desert?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/6b0c0b6a-72ba-5033-8233-9573dfa2de46.mp3"}$j$::jsonb,$j${"expected": "Care este cel mai bun desert?"}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$superlativ$p$, $p$speaking$p$]),
('365bedd8-147c-5904-a9bc-cc30f05d7a0a'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','reading','multiple_choice',$p$En una tienda oyes «Plata cu cardul, vă rog». ¿Qué significa aquí «plata»?$p$,$j${"options": ["el pago", "la plata (el metal)", "el plato"]}$j$::jsonb,$j${"value": "el pago"}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$cumparaturi$p$, $p$reading$p$]),
('89c647df-14c5-53b3-b1d7-a2862f13eaec'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Cât costă rochia aceasta?", "Cât costă pantofii aceștia?", "Aveți și o mărime mai mare?"], "say": "Cât costă rochia aceasta?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/89c647df-14c5-53b3-b1d7-a2862f13eaec.mp3"}$j$::jsonb,$j${"value": "Cât costă rochia aceasta?"}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$cumparaturi$p$, $p$listening$p$]),
('5d8f83e2-119e-561c-8089-209933fd16dc'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','writing','translation',$p$Traduce al rumano:$p$,$j${"source": "Es demasiado caro."}$j$::jsonb,$j${"value": "Este prea scump.", "accepted": ["Este prea scump.", "Este prea scump", "E prea scump.", "E prea scump", "Este prea scump!", "E prea scump!"]}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$cumparaturi$p$, $p$writing$p$]),
('a1ac832b-8b6a-50c2-849a-4664c7f7abb8'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','writing','reorder',$p$Ordena las palabras empezando por «Aveți»: «¿Tienen también una talla más grande?».$p$,$j${"tiles": ["Aveți", "mai", "mare", "mărime", "o", "și"]}$j$::jsonb,$j${"value": "Aveți și o mărime mai mare"}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$cumparaturi$p$, $p$writing$p$]),
('4d90044b-629d-5c2d-82dc-50ce5933ea19'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Pot să probez rochia aceasta, vă rog?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/4d90044b-629d-5c2d-82dc-50ce5933ea19.mp3"}$j$::jsonb,$j${"expected": "Pot să probez rochia aceasta, vă rog?"}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$cumparaturi$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('243a834a-3f5d-5e26-adb5-7b19545edb09','1a52b550-b66a-5291-b6ac-fe4bb33ef099',1),
 ('243a834a-3f5d-5e26-adb5-7b19545edb09','aa7e5c59-cd9a-5a52-9099-98006abb5c25',2),
 ('243a834a-3f5d-5e26-adb5-7b19545edb09','4ab47ec2-2c46-5891-8092-9a5b93f7a32b',3),
 ('243a834a-3f5d-5e26-adb5-7b19545edb09','28e86424-df32-53a2-8bb6-32b01145cdb2',4),
 ('243a834a-3f5d-5e26-adb5-7b19545edb09','4185439f-05be-5bbc-b6bd-0c8bf9b4db66',5),
 ('4efb8a62-dc79-55dc-b746-a9b8a7f3d11d','3f377a00-790f-53a7-8f1f-65297462bc7b',1),
 ('4efb8a62-dc79-55dc-b746-a9b8a7f3d11d','3655414a-f534-51cd-92ce-4767987a7a9b',2),
 ('4efb8a62-dc79-55dc-b746-a9b8a7f3d11d','77a2bab4-2b3d-5e01-a0e9-75eaadf0f1fc',3),
 ('4efb8a62-dc79-55dc-b746-a9b8a7f3d11d','7c171ce4-95fe-5e2b-9f87-3c94c1ed172a',4),
 ('4efb8a62-dc79-55dc-b746-a9b8a7f3d11d','443a1801-c53b-5c84-a4fb-34428ee13753',5),
 ('d02636d0-a408-58b8-99cf-c5bbd483c017','99d4d9b0-c76d-5d13-9cd5-4adb0151cac7',1),
 ('d02636d0-a408-58b8-99cf-c5bbd483c017','864e4d90-9a17-5141-95ec-524663b6e739',2),
 ('d02636d0-a408-58b8-99cf-c5bbd483c017','d0d86844-93f8-5ea6-82a2-83b7965081bb',3),
 ('d02636d0-a408-58b8-99cf-c5bbd483c017','9f121b66-5018-50ed-8e7d-4b272afbb752',4),
 ('d02636d0-a408-58b8-99cf-c5bbd483c017','6b0c0b6a-72ba-5033-8233-9573dfa2de46',5),
 ('408492da-ca26-5544-b756-62525797ee40','365bedd8-147c-5904-a9bc-cc30f05d7a0a',1),
 ('408492da-ca26-5544-b756-62525797ee40','89c647df-14c5-53b3-b1d7-a2862f13eaec',2),
 ('408492da-ca26-5544-b756-62525797ee40','5d8f83e2-119e-561c-8089-209933fd16dc',3),
 ('408492da-ca26-5544-b756-62525797ee40','a1ac832b-8b6a-50c2-849a-4664c7f7abb8',4),
 ('408492da-ca26-5544-b756-62525797ee40','4d90044b-629d-5c2d-82dc-50ce5933ea19',5),
 ('d5ee0c4a-5d15-5aaa-a851-256d66c90642','1a52b550-b66a-5291-b6ac-fe4bb33ef099',1),
 ('d5ee0c4a-5d15-5aaa-a851-256d66c90642','aa7e5c59-cd9a-5a52-9099-98006abb5c25',2),
 ('d5ee0c4a-5d15-5aaa-a851-256d66c90642','3f377a00-790f-53a7-8f1f-65297462bc7b',3),
 ('d5ee0c4a-5d15-5aaa-a851-256d66c90642','28e86424-df32-53a2-8bb6-32b01145cdb2',4),
 ('d5ee0c4a-5d15-5aaa-a851-256d66c90642','7c171ce4-95fe-5e2b-9f87-3c94c1ed172a',5),
 ('d5ee0c4a-5d15-5aaa-a851-256d66c90642','443a1801-c53b-5c84-a4fb-34428ee13753',6),
 ('d5ee0c4a-5d15-5aaa-a851-256d66c90642','4ab47ec2-2c46-5891-8092-9a5b93f7a32b',7),
 ('d5ee0c4a-5d15-5aaa-a851-256d66c90642','3655414a-f534-51cd-92ce-4767987a7a9b',8),
 ('d5ee0c4a-5d15-5aaa-a851-256d66c90642','4185439f-05be-5bbc-b6bd-0c8bf9b4db66',9),
 ('d5ee0c4a-5d15-5aaa-a851-256d66c90642','6b0c0b6a-72ba-5033-8233-9573dfa2de46',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('062cd175-6fa1-504a-968d-9b3844519820','20000000-0000-0000-0000-000000000007',$p$o gustare$p$,$p$un entrante$p$,301,'sustantivo'),
 ('2e0da211-1727-5f87-8279-ad9f55a6f55c','20000000-0000-0000-0000-000000000007',$p$un fel principal$p$,$p$un plato principal$p$,302,'sustantivo'),
 ('3c83a9f7-450d-58c9-a34c-d668a43d652a','20000000-0000-0000-0000-000000000007',$p$un desert$p$,$p$un postre$p$,303,'sustantivo'),
 ('c03243c2-e3fb-5ac9-8478-7113b101eff0','20000000-0000-0000-0000-000000000007',$p$o rochie$p$,$p$un vestido$p$,304,'sustantivo'),
 ('b0fa3189-e071-520f-b464-3aab40ef65c7','20000000-0000-0000-0000-000000000007',$p$o mărime$p$,$p$una talla$p$,305,'sustantivo'),
 ('ba124825-c466-5aa5-9ee4-8da146352cb1','20000000-0000-0000-0000-000000000007',$p$a recomanda$p$,$p$recomendar$p$,306,'verbo'),
 ('212f1d68-fe40-59dd-94a9-e2bd03eece4e','20000000-0000-0000-0000-000000000007',$p$a costa$p$,$p$costar$p$,307,'verbo'),
 ('0e3975b6-c66f-5b98-8a18-6a60be66d21a','20000000-0000-0000-0000-000000000007',$p$a plăti$p$,$p$pagar$p$,308,'verbo'),
 ('b56e156f-58e3-5bfa-8eba-020ce9c6215c','20000000-0000-0000-0000-000000000007',$p$a proba$p$,$p$probarse (una prenda)$p$,309,'verbo'),
 ('fd078835-50c5-56a4-b081-1470d0da3d03','20000000-0000-0000-0000-000000000007',$p$scump$p$,$p$caro$p$,310,'adjetivo'),
 ('14e8b893-4049-5732-bb3f-1916385bddd6','20000000-0000-0000-0000-000000000007',$p$ieftin$p$,$p$barato$p$,311,'adjetivo'),
 ('20dedc14-390b-5eb1-aa9d-89b731e635ab','20000000-0000-0000-0000-000000000007',$p$mai$p$,$p$más (marca el comparativo)$p$,312,'adverbio'),
 ('5f16a5e3-5142-5f9e-9cd5-c682b4d5c68a','20000000-0000-0000-0000-000000000007',$p$decât$p$,$p$que (en la comparación)$p$,313,'conjuncion'),
 ('fb215535-d4c2-5a73-ad70-9750790c7de6','20000000-0000-0000-0000-000000000007',$p$cel mai / cea mai$p$,$p$el/la más$p$,314,'articulo'),
 ('751cfe63-2b31-52eb-acb1-335d65a5487e','20000000-0000-0000-0000-000000000007',$p$prea$p$,$p$demasiado$p$,315,'adverbio'),
 ('e0d04fcc-0649-51ce-a8c5-acd7b1839067','20000000-0000-0000-0000-000000000007',$p$destul$p$,$p$bastante, suficiente$p$,316,'adverbio'),
 ('0514296d-429c-5a10-96a5-1626c4cf83bc','20000000-0000-0000-0000-000000000007',$p$mult, multă$p$,$p$mucho/-a$p$,317,'adjetivo'),
 ('ad0886bf-45c1-5ca1-a2a7-abd374517508','20000000-0000-0000-0000-000000000007',$p$puțin$p$,$p$poco$p$,318,'adverbio')
on conflict (id) do nothing;

-- ── Unidad 11 (A2·ro): Personas y descripciones ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('740e41f2-2388-57e4-809f-b6723d528853','20000000-0000-0000-0000-000000000007','A2',11,$p$Personas y descripciones$p$,'#F2994A','person')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('72f37708-0259-5b7b-9360-dea9a8f086f5','740e41f2-2388-57e4-809f-b6723d528853',1,$p$Cómo era: el imperfecto$p$,$p$Cómo era: el imperfecto$p$,'lesson',15),
 ('66b0c35f-e584-5d54-89be-466345479b38','740e41f2-2388-57e4-809f-b6723d528853',2,$p$Antes y ayer: dos pasados$p$,$p$Antes y ayer: dos pasados$p$,'lesson',15),
 ('d624f545-e246-54e4-b001-bcdb2055f1d0','740e41f2-2388-57e4-809f-b6723d528853',3,$p$Alto, bajo, simpático$p$,$p$Alto, bajo, simpático$p$,'lesson',15),
 ('3ca40bc3-ac94-59be-99a1-fa6410d26253','740e41f2-2388-57e4-809f-b6723d528853',4,$p$Cum era? Describir a alguien$p$,$p$Cum era? Describir a alguien$p$,'lesson',15),
 ('ba34acc9-4a3b-5f01-a382-0d13ae97e47c','740e41f2-2388-57e4-809f-b6723d528853',5,$p$🏁 Checkpoint Unitatea 11$p$,$p$Repasa el imperfecto (eram, aveam, mergeam), cuándo usarlo en lugar del perfecto compuesto y los adjetivos de carácter y de físico con su concordancia.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('bfd73961-fa82-5a4b-91b7-b755060a691a','20000000-0000-0000-0000-000000000007','checkpoint','A2','740e41f2-2388-57e4-809f-b6723d528853',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('3dc5e963-a0ef-5359-9b70-1f0266a8d38d'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','reading','multiple_choice',$p$«Când ___ mic, mă jucam în parc.» Elige la forma correcta:$p$,$j${"options": ["eram", "sunt", "am fost"]}$j$::jsonb,$j${"value": "eram"}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$imperfect-forme$p$, $p$reading$p$]),
('a80f1cf7-2b22-561a-812b-9c69536cb03a'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','reading','multiple_choice',$p$«Noi ___ la mare în fiecare vară, când eram copii.» Elige la forma correcta:$p$,$j${"options": ["mergeam", "mergeați", "mergeau"]}$j$::jsonb,$j${"value": "mergeam"}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$imperfect-persoana$p$, $p$reading$p$]),
('2b320793-9f02-5769-a28d-2bf4f3cd4104'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','reading','match',$p$Empareja cada verbo con su traducción.$p$,$j${"pairs": [{"en": "aveam", "es": "(yo) tenía"}, {"en": "mergeam", "es": "iba / íbamos"}, {"en": "făceam", "es": "(yo) hacía"}]}$j$::jsonb,$j${"pairs": [["aveam", "(yo) tenía"], ["mergeam", "iba / íbamos"], ["făceam", "(yo) hacía"]]}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$imperfect-verbe$p$, $p$reading$p$]),
('cd5c4304-7ccc-5e97-8d07-b5a633ade0fb'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Bunicul meu era foarte harnic.", "Bunicul meu era foarte leneș.", "Bunicul meu era foarte timid."], "say": "Bunicul meu era foarte harnic.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/cd5c4304-7ccc-5e97-8d07-b5a633ade0fb.mp3"}$j$::jsonb,$j${"value": "Bunicul meu era foarte harnic."}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$descriere-caracter$p$, $p$listening$p$]),
('74c93b21-8ca9-5d74-aeca-bc8cedc36b1b'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Când eram copil, locuiam la țară.", "Când eram copil, locuiam la oraș.", "Când eram student, locuiam la țară."], "say": "Când eram copil, locuiam la țară.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/74c93b21-8ca9-5d74-aeca-bc8cedc36b1b.mp3"}$j$::jsonb,$j${"value": "Când eram copil, locuiam la țară."}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$imperfect-obisnuinta$p$, $p$listening$p$]),
('3c234941-1b60-5c8a-8fa4-c93a1413b411'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','reading','multiple_choice',$p$¿Cuál de estas frases habla de una costumbre del pasado?$p$,$j${"options": ["În fiecare vară mergeam la munte.", "Vara trecută am mers o dată la munte.", "Mâine o să merg la munte."]}$j$::jsonb,$j${"value": "În fiecare vară mergeam la munte."}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$imperfect-vs-perfect$p$, $p$reading$p$]),
('629500a1-824f-5577-a86e-c36338a88a15'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','writing','cloze',$p$Completa con la forma correcta del verbo «a merge»:$p$,$j${"text": "Când eram mic, ___ des la bunici."}$j$::jsonb,$j${"value": "mergeam", "accepted": ["mergeam"]}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$imperfect-obisnuinta$p$, $p$writing$p$]),
('969bb26f-cf70-58cf-ae76-59b448832294'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','writing','cloze',$p$Completa con la forma correcta del verbo «a vedea»:$p$,$j${"text": "Aseară ___ un film foarte bun la televizor."}$j$::jsonb,$j${"value": "am văzut", "accepted": ["am văzut", "am vazut"]}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$perfect-punctual$p$, $p$writing$p$]),
('ff03aba3-679c-5f4b-aefb-0838eba2f720'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ieri am mers la piață cu mama.", "Ieri am mers la piață cu tata.", "Ieri am mers la spital cu mama."], "say": "Ieri am mers la piață cu mama.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/ff03aba3-679c-5f4b-aefb-0838eba2f720.mp3"}$j$::jsonb,$j${"value": "Ieri am mers la piață cu mama."}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$perfect-punctual$p$, $p$listening$p$]),
('27e2e5d7-d1b1-5aaa-8251-108b8032891d'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','writing','translation',$p$Traduce al rumano:$p$,$j${"source": "Cuando era niño, vivía en un pueblo."}$j$::jsonb,$j${"value": "Când eram copil, locuiam într-un sat.", "accepted": ["Când eram copil, locuiam într-un sat.", "Când eram copil locuiam într-un sat", "Locuiam într-un sat când eram copil.", "Când eram mic, locuiam într-un sat.", "Cand eram copil locuiam intr-un sat", "Cand eram copil, locuiam intr-un sat.", "Cand eram mic, locuiam intr-un sat.", "Locuiam intr-un sat cand eram copil.", "Când eram copil, locuiam la sat.", "Cand eram copil, locuiam la sat.", "Când eram copil, eu locuiam într-un sat.", "Cand eram copil, eu locuiam intr-un sat."]}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$imperfect-descriere$p$, $p$writing$p$]),
('0cf22c4d-791b-57b8-bfdf-7170719c1b38'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','reading','multiple_choice',$p$«Sora mea era foarte ___.» Elige la forma correcta:$p$,$j${"options": ["înaltă", "înalt", "înalți"]}$j$::jsonb,$j${"value": "înaltă"}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$adjective-fizic$p$, $p$reading$p$]),
('eb73ed0c-5450-55f3-9930-217159495072'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','reading','match',$p$Empareja cada adjetivo con su significado.$p$,$j${"pairs": [{"en": "harnic", "es": "trabajador"}, {"en": "prietenos", "es": "amable, sociable"}, {"en": "leneș", "es": "perezoso"}]}$j$::jsonb,$j${"pairs": [["harnic", "trabajador"], ["prietenos", "amable, sociable"], ["leneș", "perezoso"]]}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$adjective-caracter$p$, $p$reading$p$]),
('b04e1290-694d-5824-ba74-98bbbb6466d8'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','writing','word_bank',$p$Ordena para decir «Mi hermano era alto y delgado» (empieza por «Fratele»).$p$,$j${"tiles": ["era", "erau", "Fratele", "meu", "slab.", "înalt", "înaltă", "și"]}$j$::jsonb,$j${"value": "Fratele meu era înalt și slab.", "sequence": ["Fratele", "meu", "era", "înalt", "și", "slab."]}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$descriere-fizic$p$, $p$writing$p$]),
('b2dd56cc-f1e8-56e0-a26f-38812cf6e205'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','writing','reorder',$p$Ordena las palabras (empieza por «Când»): «Cuando era pequeña, vivía en Bucarest».$p$,$j${"tiles": ["București.", "Când", "eram", "locuiam", "mică,", "în"]}$j$::jsonb,$j${"value": "Când eram mică, locuiam în București."}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$imperfect-descriere$p$, $p$writing$p$]),
('8529b371-0915-5891-a974-3e9a7272c6e4'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ea are ochii verzi și părul lung.", "Ea are ochii albaștri și părul lung.", "Ea are ochii verzi și părul scurt."], "say": "Ea are ochii verzi și părul lung.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/8529b371-0915-5891-a974-3e9a7272c6e4.mp3"}$j$::jsonb,$j${"value": "Ea are ochii verzi și părul lung."}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$descriere-fizic$p$, $p$listening$p$]),
('21b77a8a-af86-5d8a-8a78-96fb51b70545'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','writing','translation',$p$Traduce al rumano:$p$,$j${"source": "Mi profesora era alta y muy simpática."}$j$::jsonb,$j${"value": "Profesoara mea era înaltă și foarte simpatică.", "accepted": ["Profesoara mea era înaltă și foarte simpatică.", "Profesoara mea era înaltă și foarte drăguță.", "Profesoara mea era foarte inalta si simpatica.", "Profesoara mea era inalta si foarte draguta.", "Profesoara mea era inalta si foarte simpatica."]}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$descriere-persoane$p$, $p$writing$p$]),
('8615f41f-37d0-5018-838b-d2270cf0b202'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Cum arăta prietenul tău?", "Cum arăta vecinul tău?", "Cum arăta fratele tău?"], "say": "Cum arăta prietenul tău?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/8615f41f-37d0-5018-838b-d2270cf0b202.mp3"}$j$::jsonb,$j${"value": "Cum arăta prietenul tău?"}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$cum-arata$p$, $p$listening$p$]),
('ab46a042-5b87-56ad-a7e8-7ad186ecbd66'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Când eram mic, mergeam la bunici în fiecare vară.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/ab46a042-5b87-56ad-a7e8-7ad186ecbd66.mp3"}$j$::jsonb,$j${"expected": "Când eram mic, mergeam la bunici în fiecare vară."}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$imperfect-obisnuinta$p$, $p$speaking$p$]),
('6446f94e-3e23-5934-90bd-4dcc51740ca1'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Bunica mea era înaltă, blondă și foarte prietenoasă.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/6446f94e-3e23-5934-90bd-4dcc51740ca1.mp3"}$j$::jsonb,$j${"expected": "Bunica mea era înaltă, blondă și foarte prietenoasă."}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$descriere-persoane$p$, $p$speaking$p$]),
('a91b54e1-4cd0-510b-836a-e826f4bbd890'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Cum era profesorul tău preferat?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/a91b54e1-4cd0-510b-836a-e826f4bbd890.mp3"}$j$::jsonb,$j${"expected": "Cum era profesorul tău preferat?"}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$cum-era$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('72f37708-0259-5b7b-9360-dea9a8f086f5','3dc5e963-a0ef-5359-9b70-1f0266a8d38d',1),
 ('72f37708-0259-5b7b-9360-dea9a8f086f5','a80f1cf7-2b22-561a-812b-9c69536cb03a',2),
 ('72f37708-0259-5b7b-9360-dea9a8f086f5','2b320793-9f02-5769-a28d-2bf4f3cd4104',3),
 ('72f37708-0259-5b7b-9360-dea9a8f086f5','cd5c4304-7ccc-5e97-8d07-b5a633ade0fb',4),
 ('72f37708-0259-5b7b-9360-dea9a8f086f5','74c93b21-8ca9-5d74-aeca-bc8cedc36b1b',5),
 ('66b0c35f-e584-5d54-89be-466345479b38','3c234941-1b60-5c8a-8fa4-c93a1413b411',1),
 ('66b0c35f-e584-5d54-89be-466345479b38','629500a1-824f-5577-a86e-c36338a88a15',2),
 ('66b0c35f-e584-5d54-89be-466345479b38','969bb26f-cf70-58cf-ae76-59b448832294',3),
 ('66b0c35f-e584-5d54-89be-466345479b38','ff03aba3-679c-5f4b-aefb-0838eba2f720',4),
 ('66b0c35f-e584-5d54-89be-466345479b38','27e2e5d7-d1b1-5aaa-8251-108b8032891d',5),
 ('d624f545-e246-54e4-b001-bcdb2055f1d0','0cf22c4d-791b-57b8-bfdf-7170719c1b38',1),
 ('d624f545-e246-54e4-b001-bcdb2055f1d0','eb73ed0c-5450-55f3-9930-217159495072',2),
 ('d624f545-e246-54e4-b001-bcdb2055f1d0','b04e1290-694d-5824-ba74-98bbbb6466d8',3),
 ('d624f545-e246-54e4-b001-bcdb2055f1d0','b2dd56cc-f1e8-56e0-a26f-38812cf6e205',4),
 ('d624f545-e246-54e4-b001-bcdb2055f1d0','8529b371-0915-5891-a974-3e9a7272c6e4',5),
 ('3ca40bc3-ac94-59be-99a1-fa6410d26253','21b77a8a-af86-5d8a-8a78-96fb51b70545',1),
 ('3ca40bc3-ac94-59be-99a1-fa6410d26253','8615f41f-37d0-5018-838b-d2270cf0b202',2),
 ('3ca40bc3-ac94-59be-99a1-fa6410d26253','ab46a042-5b87-56ad-a7e8-7ad186ecbd66',3),
 ('3ca40bc3-ac94-59be-99a1-fa6410d26253','6446f94e-3e23-5934-90bd-4dcc51740ca1',4),
 ('3ca40bc3-ac94-59be-99a1-fa6410d26253','a91b54e1-4cd0-510b-836a-e826f4bbd890',5),
 ('ba34acc9-4a3b-5f01-a382-0d13ae97e47c','3dc5e963-a0ef-5359-9b70-1f0266a8d38d',1),
 ('ba34acc9-4a3b-5f01-a382-0d13ae97e47c','a80f1cf7-2b22-561a-812b-9c69536cb03a',2),
 ('ba34acc9-4a3b-5f01-a382-0d13ae97e47c','2b320793-9f02-5769-a28d-2bf4f3cd4104',3),
 ('ba34acc9-4a3b-5f01-a382-0d13ae97e47c','629500a1-824f-5577-a86e-c36338a88a15',4),
 ('ba34acc9-4a3b-5f01-a382-0d13ae97e47c','969bb26f-cf70-58cf-ae76-59b448832294',5),
 ('ba34acc9-4a3b-5f01-a382-0d13ae97e47c','27e2e5d7-d1b1-5aaa-8251-108b8032891d',6),
 ('ba34acc9-4a3b-5f01-a382-0d13ae97e47c','cd5c4304-7ccc-5e97-8d07-b5a633ade0fb',7),
 ('ba34acc9-4a3b-5f01-a382-0d13ae97e47c','74c93b21-8ca9-5d74-aeca-bc8cedc36b1b',8),
 ('ba34acc9-4a3b-5f01-a382-0d13ae97e47c','ab46a042-5b87-56ad-a7e8-7ad186ecbd66',9),
 ('ba34acc9-4a3b-5f01-a382-0d13ae97e47c','6446f94e-3e23-5934-90bd-4dcc51740ca1',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('00abddf4-d0b6-5c5c-8f4b-889148856ed2','20000000-0000-0000-0000-000000000007',$p$înalt$p$,$p$alto (de estatura)$p$,321,'adjetivo'),
 ('94afd3ba-84cb-514a-bca9-1b7700c236b3','20000000-0000-0000-0000-000000000007',$p$scund$p$,$p$bajo (de estatura)$p$,322,'adjetivo'),
 ('fd76e761-eb79-547f-b24f-5f8c4aa1dfa4','20000000-0000-0000-0000-000000000007',$p$slab$p$,$p$delgado$p$,323,'adjetivo'),
 ('9cac8e28-8d0d-5dd2-96b4-262ebbdd5223','20000000-0000-0000-0000-000000000007',$p$harnic$p$,$p$trabajador$p$,324,'adjetivo'),
 ('c2d447e2-f30b-5573-bbc5-556220b1b14e','20000000-0000-0000-0000-000000000007',$p$leneș$p$,$p$perezoso$p$,325,'adjetivo'),
 ('5a85732b-29b0-528d-8a8b-65930203eeff','20000000-0000-0000-0000-000000000007',$p$prietenos$p$,$p$amable, sociable$p$,326,'adjetivo'),
 ('a058a929-89ad-5e79-85e4-fc3e5d0a15d1','20000000-0000-0000-0000-000000000007',$p$timid$p$,$p$tímido$p$,327,'adjetivo'),
 ('94a512c2-2012-50da-84e0-8a7c0c375805','20000000-0000-0000-0000-000000000007',$p$blond$p$,$p$rubio$p$,328,'adjetivo'),
 ('5a5ac5de-0169-5569-b974-3989c19b73a6','20000000-0000-0000-0000-000000000007',$p$o barbă$p$,$p$una barba$p$,329,'sustantivo'),
 ('b27018a0-8716-523e-bd71-ae4ad1b96334','20000000-0000-0000-0000-000000000007',$p$un păr$p$,$p$el pelo$p$,330,'sustantivo'),
 ('ce94f95d-d638-5b53-b332-644c88e34282','20000000-0000-0000-0000-000000000007',$p$un copil$p$,$p$un niño, un hijo$p$,331,'sustantivo'),
 ('de945bf5-a516-5a44-9d1d-5a3a3a71721e','20000000-0000-0000-0000-000000000007',$p$o bunică$p$,$p$una abuela$p$,332,'sustantivo'),
 ('2a4f9565-1921-5c0e-857e-bdf260d4c880','20000000-0000-0000-0000-000000000007',$p$un vecin$p$,$p$un vecino$p$,333,'sustantivo'),
 ('b835bb3d-8b6a-5766-b376-4c476af917a0','20000000-0000-0000-0000-000000000007',$p$un sat$p$,$p$un pueblo$p$,334,'sustantivo'),
 ('2af358c3-b9ce-5cbc-b46f-69a159d34286','20000000-0000-0000-0000-000000000007',$p$a arăta$p$,$p$tener aspecto, verse$p$,335,'verbo'),
 ('2e381731-dfdd-5018-b1aa-ba85bdf3b00b','20000000-0000-0000-0000-000000000007',$p$a locui$p$,$p$vivir, residir$p$,336,'verbo'),
 ('3fe25749-fdf5-5ed6-a7a2-aa7296a1933b','20000000-0000-0000-0000-000000000007',$p$mereu$p$,$p$siempre$p$,337,'adverbio'),
 ('153f011d-27d2-55a4-aac4-c03944fea486','20000000-0000-0000-0000-000000000007',$p$des$p$,$p$a menudo$p$,338,'adverbio')
on conflict (id) do nothing;

-- ── Unidad 12 (A2·ro): Salud, cuerpo y consejos ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('dde0fe5a-aa95-528c-8139-f36547b49482','20000000-0000-0000-0000-000000000007','A2',12,$p$Salud, cuerpo y consejos$p$,'#27AE60','healing')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('90e305de-2067-5e40-898a-615663bc838c','dde0fe5a-aa95-528c-8139-f36547b49482',1,$p$Partes del cuerpo$p$,$p$Partes del cuerpo$p$,'lesson',15),
 ('8c7cd824-5715-507d-88ae-06ac1c7ee044','dde0fe5a-aa95-528c-8139-f36547b49482',2,$p$Mă doare, mă dor$p$,$p$Mă doare, mă dor$p$,'lesson',15),
 ('f5f1d685-dc9a-5343-b54b-60640fe191e8','dde0fe5a-aa95-528c-8139-f36547b49482',3,$p$Síntomas: febră, gripă, răcit$p$,$p$Síntomas: febră, gripă, răcit$p$,'lesson',15),
 ('af60ca00-e29f-5f4f-81e4-46ca48d50997','dde0fe5a-aa95-528c-8139-f36547b49482',4,$p$Consejos y consejos del médico$p$,$p$Consejos y consejos del médico$p$,'lesson',15),
 ('409cc2d0-a979-585f-8dd4-aba09f7a46e5','dde0fe5a-aa95-528c-8139-f36547b49482',5,$p$🏁 Checkpoint Unitatea 12$p$,$p$Repasa las partes del cuerpo con su género, decir qué te duele con «mă doare» y «mă dor» + el artículo pegado, contar los síntomas y dar consejos con «trebuie să» y «ar trebui să».$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('68ab6870-d7d9-52ca-8fcf-cd86bf0ba37f','20000000-0000-0000-0000-000000000007','checkpoint','A2','dde0fe5a-aa95-528c-8139-f36547b49482',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('74e97877-7742-57b5-8e03-616dbad0cde8'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','reading','match',$p$Empareja cada parte del cuerpo con su traducción.$p$,$j${"pairs": [{"en": "un cap", "es": "una cabeza"}, {"en": "o mână", "es": "una mano"}, {"en": "un picior", "es": "una pierna, un pie"}]}$j$::jsonb,$j${"pairs": [["un cap", "una cabeza"], ["o mână", "una mano"], ["un picior", "una pierna, un pie"]]}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$parti_corp$p$, $p$reading$p$]),
('74db2e74-5b53-5029-a80c-5cdda6e4535c'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','reading','multiple_choice',$p$¿Cuál es la forma correcta de «un diente»?$p$,$j${"options": ["un dinte", "o dinte", "un dinți"]}$j$::jsonb,$j${"value": "un dinte"}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$parti_corp$p$, $p$reading$p$]),
('2a92288b-3dc7-5a09-a57f-4cdd0b77c1c2'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Mă spăl pe mâini.", "Mă spăl pe dinți.", "Mă spăl pe față."], "say": "Mă spăl pe mâini.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/2a92288b-3dc7-5a09-a57f-4cdd0b77c1c2.mp3"}$j$::jsonb,$j${"value": "Mă spăl pe mâini."}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$parti_corp$p$, $p$listening$p$]),
('5f3f989b-ef81-500f-b5c0-90da9cd9d123'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','writing','translation',$p$Traduce al rumano:$p$,$j${"source": "Tengo dos ojos y dos manos."}$j$::jsonb,$j${"value": "Am doi ochi și două mâini.", "accepted": ["Am doi ochi și două mâini.", "Am doi ochi și două mâini", "Am doi ochi si doua maini.", "Am doi ochi si doua maini", "Eu am doi ochi și două mâini.", "Eu am doi ochi si doua maini."]}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$parti_corp$p$, $p$writing$p$]),
('7629816f-f6ce-5a9f-908a-b9a1655f6447'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Mă spăl pe dinți dimineața și seara.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/7629816f-f6ce-5a9f-908a-b9a1655f6447.mp3"}$j$::jsonb,$j${"expected": "Mă spăl pe dinți dimineața și seara."}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$parti_corp$p$, $p$speaking$p$]),
('8024aca3-340b-57fc-96fe-c087233ce976'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','reading','match',$p$Empareja cada frase con su traducción.$p$,$j${"pairs": [{"en": "Mă doare gâtul.", "es": "Me duele la garganta."}, {"en": "Mă doare spatele.", "es": "Me duele la espalda."}, {"en": "Mă dor ochii.", "es": "Me duelen los ojos."}]}$j$::jsonb,$j${"pairs": [["Mă doare gâtul.", "Me duele la garganta."], ["Mă doare spatele.", "Me duele la espalda."], ["Mă dor ochii.", "Me duelen los ojos."]]}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$ma_doare$p$, $p$reading$p$]),
('effc762d-b612-565c-8817-64733c68fd57'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','reading','multiple_choice',$p$«Me duelen las manos». ¿Cuál es la forma correcta?$p$,$j${"options": ["Mă dor mâinile.", "Mă doare mâinile.", "Mă dor mâna."]}$j$::jsonb,$j${"value": "Mă dor mâinile."}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$ma_doare$p$, $p$reading$p$]),
('109c10b0-a81d-5c7b-8987-a9e949927707'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Mă doare stomacul.", "Mă doare spatele.", "Mă dor picioarele."], "say": "Mă doare stomacul.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/109c10b0-a81d-5c7b-8987-a9e949927707.mp3"}$j$::jsonb,$j${"value": "Mă doare stomacul."}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$ma_doare$p$, $p$listening$p$]),
('743628d1-dc7e-5df6-a90d-18b68e33eb9f'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','writing','cloze',$p$Completa: «Me duele la cabeza.»$p$,$j${"text": "Mă doare ___."}$j$::jsonb,$j${"value": "capul", "accepted": ["capul"]}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$ma_doare$p$, $p$writing$p$]),
('2ab57532-79ed-5e94-9eba-09a0d6ba9a56'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Mă doare gâtul și mă dor picioarele.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/2ab57532-79ed-5e94-9eba-09a0d6ba9a56.mp3"}$j$::jsonb,$j${"expected": "Mă doare gâtul și mă dor picioarele."}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$ma_doare$p$, $p$speaking$p$]),
('1db0f6d5-8883-5909-bf8d-d9242135a9eb'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','reading','multiple_choice',$p$Una mujer dice «Estoy resfriada». ¿Cuál es la forma correcta?$p$,$j${"options": ["Sunt răcită.", "Sunt răcit.", "Sunt răceală."]}$j$::jsonb,$j${"value": "Sunt răcită."}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$simptome$p$, $p$reading$p$]),
('22f462aa-e3d1-5520-ad5a-210265bc4327'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Am gripă și mă doare capul.", "Am gripă și mă doare gâtul.", "Am febră și mă doare capul."], "say": "Am gripă și mă doare capul.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/22f462aa-e3d1-5520-ad5a-210265bc4327.mp3"}$j$::jsonb,$j${"value": "Am gripă și mă doare capul."}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$simptome$p$, $p$listening$p$]),
('e3986aca-889a-5657-a2a0-a5cbd53d6d4d'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Sunt răcită de trei zile.", "Sunt răcit de o săptămână.", "Am gripă de trei zile."], "say": "Sunt răcită de trei zile.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/e3986aca-889a-5657-a2a0-a5cbd53d6d4d.mp3"}$j$::jsonb,$j${"value": "Sunt răcită de trei zile."}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$simptome$p$, $p$listening$p$]),
('50f67313-e74d-5429-9004-f7f1a0d8bfd4'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','writing','word_bank',$p$Ordena para decir «Tengo fiebre y toso». Empieza por «Am».$p$,$j${"tiles": ["Am", "febră", "gripă", "tușesc", "tușești", "și"]}$j$::jsonb,$j${"value": "Am febră și tușesc", "sequence": ["Am", "febră", "și", "tușesc"]}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$simptome$p$, $p$writing$p$]),
('0acac5eb-f82f-561c-b72b-f1089d093d4c'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','writing','translation',$p$Traduce al rumano:$p$,$j${"source": "Toso y me duele la garganta."}$j$::jsonb,$j${"value": "Tușesc și mă doare gâtul.", "accepted": ["Tușesc și mă doare gâtul.", "Tușesc și mă doare gâtul", "Tusesc si ma doare gatul.", "Tusesc si ma doare gatul", "Tușesc și mă doare în gât.", "Tușesc și am durere în gât.", "Eu tușesc și mă doare în gât.", "Eu tușesc și mă doare gâtul.", "Eu tusesc si ma doare gatul.", "Eu tusesc si ma doare in gat.", "Tusesc si am durere in gat.", "Tusesc si ma doare in gat."]}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$simptome$p$, $p$writing$p$]),
('77001941-5f84-5029-ace2-f79ccb30645d'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','reading','multiple_choice',$p$«Tienes que descansar». ¿Cuál es la forma correcta?$p$,$j${"options": ["Trebuie să te odihnești.", "Trebuie te odihnești.", "Trebuie să te odihnesc."]}$j$::jsonb,$j${"value": "Trebuie să te odihnești."}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$sfaturi_doctor$p$, $p$reading$p$]),
('6d937712-1794-5b5d-8fe7-e8aa0a57a339'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Trebuie să iei un medicament.", "Trebuie să bei un ceai.", "Ar trebui să mergi la farmacie."], "say": "Trebuie să iei un medicament.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/6d937712-1794-5b5d-8fe7-e8aa0a57a339.mp3"}$j$::jsonb,$j${"value": "Trebuie să iei un medicament."}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$sfaturi_doctor$p$, $p$listening$p$]),
('94bab030-8674-53d7-8d26-ea14b2d82077'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','writing','cloze',$p$Completa: «El médico escribe una receta.»$p$,$j${"text": "Doctorul scrie o ___."}$j$::jsonb,$j${"value": "rețetă", "accepted": ["rețetă", "reteta"]}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$sfaturi_doctor$p$, $p$writing$p$]),
('f0a5864a-d03c-5251-960e-580d6d2c2b64'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','writing','reorder',$p$Ordena las palabras: «Deberías ir al médico». Empieza por «Ar».$p$,$j${"tiles": ["Ar", "doctor", "la", "mergi", "să", "trebui"]}$j$::jsonb,$j${"value": "Ar trebui să mergi la doctor"}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$sfaturi_doctor$p$, $p$writing$p$]),
('18ba63b7-9400-571a-ad4c-426c67c1ecbf'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Ar trebui să bei ceai cald și să te odihnești.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/18ba63b7-9400-571a-ad4c-426c67c1ecbf.mp3"}$j$::jsonb,$j${"expected": "Ar trebui să bei ceai cald și să te odihnești."}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$sfaturi_doctor$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('90e305de-2067-5e40-898a-615663bc838c','74e97877-7742-57b5-8e03-616dbad0cde8',1),
 ('90e305de-2067-5e40-898a-615663bc838c','74db2e74-5b53-5029-a80c-5cdda6e4535c',2),
 ('90e305de-2067-5e40-898a-615663bc838c','2a92288b-3dc7-5a09-a57f-4cdd0b77c1c2',3),
 ('90e305de-2067-5e40-898a-615663bc838c','5f3f989b-ef81-500f-b5c0-90da9cd9d123',4),
 ('90e305de-2067-5e40-898a-615663bc838c','7629816f-f6ce-5a9f-908a-b9a1655f6447',5),
 ('8c7cd824-5715-507d-88ae-06ac1c7ee044','8024aca3-340b-57fc-96fe-c087233ce976',1),
 ('8c7cd824-5715-507d-88ae-06ac1c7ee044','effc762d-b612-565c-8817-64733c68fd57',2),
 ('8c7cd824-5715-507d-88ae-06ac1c7ee044','109c10b0-a81d-5c7b-8987-a9e949927707',3),
 ('8c7cd824-5715-507d-88ae-06ac1c7ee044','743628d1-dc7e-5df6-a90d-18b68e33eb9f',4),
 ('8c7cd824-5715-507d-88ae-06ac1c7ee044','2ab57532-79ed-5e94-9eba-09a0d6ba9a56',5),
 ('f5f1d685-dc9a-5343-b54b-60640fe191e8','1db0f6d5-8883-5909-bf8d-d9242135a9eb',1),
 ('f5f1d685-dc9a-5343-b54b-60640fe191e8','22f462aa-e3d1-5520-ad5a-210265bc4327',2),
 ('f5f1d685-dc9a-5343-b54b-60640fe191e8','e3986aca-889a-5657-a2a0-a5cbd53d6d4d',3),
 ('f5f1d685-dc9a-5343-b54b-60640fe191e8','50f67313-e74d-5429-9004-f7f1a0d8bfd4',4),
 ('f5f1d685-dc9a-5343-b54b-60640fe191e8','0acac5eb-f82f-561c-b72b-f1089d093d4c',5),
 ('af60ca00-e29f-5f4f-81e4-46ca48d50997','77001941-5f84-5029-ace2-f79ccb30645d',1),
 ('af60ca00-e29f-5f4f-81e4-46ca48d50997','6d937712-1794-5b5d-8fe7-e8aa0a57a339',2),
 ('af60ca00-e29f-5f4f-81e4-46ca48d50997','94bab030-8674-53d7-8d26-ea14b2d82077',3),
 ('af60ca00-e29f-5f4f-81e4-46ca48d50997','f0a5864a-d03c-5251-960e-580d6d2c2b64',4),
 ('af60ca00-e29f-5f4f-81e4-46ca48d50997','18ba63b7-9400-571a-ad4c-426c67c1ecbf',5),
 ('409cc2d0-a979-585f-8dd4-aba09f7a46e5','74e97877-7742-57b5-8e03-616dbad0cde8',1),
 ('409cc2d0-a979-585f-8dd4-aba09f7a46e5','74db2e74-5b53-5029-a80c-5cdda6e4535c',2),
 ('409cc2d0-a979-585f-8dd4-aba09f7a46e5','8024aca3-340b-57fc-96fe-c087233ce976',3),
 ('409cc2d0-a979-585f-8dd4-aba09f7a46e5','5f3f989b-ef81-500f-b5c0-90da9cd9d123',4),
 ('409cc2d0-a979-585f-8dd4-aba09f7a46e5','743628d1-dc7e-5df6-a90d-18b68e33eb9f',5),
 ('409cc2d0-a979-585f-8dd4-aba09f7a46e5','50f67313-e74d-5429-9004-f7f1a0d8bfd4',6),
 ('409cc2d0-a979-585f-8dd4-aba09f7a46e5','2a92288b-3dc7-5a09-a57f-4cdd0b77c1c2',7),
 ('409cc2d0-a979-585f-8dd4-aba09f7a46e5','109c10b0-a81d-5c7b-8987-a9e949927707',8),
 ('409cc2d0-a979-585f-8dd4-aba09f7a46e5','7629816f-f6ce-5a9f-908a-b9a1655f6447',9),
 ('409cc2d0-a979-585f-8dd4-aba09f7a46e5','2ab57532-79ed-5e94-9eba-09a0d6ba9a56',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('b60fc00c-8eaa-520b-b1f4-02025cb7359d','20000000-0000-0000-0000-000000000007',$p$un cap$p$,$p$la cabeza$p$,341,'sustantivo'),
 ('3d9156e3-52dd-560d-bef6-b33cc992289a','20000000-0000-0000-0000-000000000007',$p$un gât$p$,$p$la garganta; el cuello$p$,342,'sustantivo'),
 ('dee67426-67ad-5b68-b5ef-285583381150','20000000-0000-0000-0000-000000000007',$p$o mână (pl. mâinile)$p$,$p$la mano$p$,343,'sustantivo'),
 ('0a02a038-368d-558d-b86b-1ea5218f667f','20000000-0000-0000-0000-000000000007',$p$un picior (pl. picioarele)$p$,$p$la pierna, el pie$p$,344,'sustantivo'),
 ('af4b0141-28e3-591c-8496-1ef16ebd5d9d','20000000-0000-0000-0000-000000000007',$p$un spate$p$,$p$la espalda$p$,345,'sustantivo'),
 ('36ce81ae-ea8c-59d2-b098-742e8b36f97c','20000000-0000-0000-0000-000000000007',$p$un stomac$p$,$p$el estómago$p$,346,'sustantivo'),
 ('e860216b-6e54-584f-97ae-74a9159465e8','20000000-0000-0000-0000-000000000007',$p$un dinte (pl. dinții)$p$,$p$el diente$p$,347,'sustantivo'),
 ('85d2dfc6-763a-53fc-8f13-76df59510920','20000000-0000-0000-0000-000000000007',$p$un ochi (pl. ochii)$p$,$p$el ojo$p$,348,'sustantivo'),
 ('bd0e65c5-404f-5484-95d8-03bf16c9172d','20000000-0000-0000-0000-000000000007',$p$a durea$p$,$p$doler$p$,349,'verbo'),
 ('ebef178a-ae9e-5db0-acfc-af1675c89183','20000000-0000-0000-0000-000000000007',$p$o febră$p$,$p$la fiebre$p$,350,'sustantivo'),
 ('761d9b97-a5a6-5fa8-b24b-73991e838cea','20000000-0000-0000-0000-000000000007',$p$o gripă$p$,$p$la gripe$p$,351,'sustantivo'),
 ('f9e23c35-4964-5bb9-8ae8-ec5ba7adc81b','20000000-0000-0000-0000-000000000007',$p$răcit, răcită$p$,$p$resfriado, acatarrado$p$,352,'adjetivo'),
 ('5234f31a-5160-5871-951c-d7ab0c7f6d3f','20000000-0000-0000-0000-000000000007',$p$a tuși$p$,$p$toser$p$,353,'verbo'),
 ('e32b5db8-c2b4-5224-9868-7f6783dca9fa','20000000-0000-0000-0000-000000000007',$p$a trebui$p$,$p$tener que, deber$p$,354,'verbo'),
 ('0612817b-30aa-5df6-8358-2bfe481d9130','20000000-0000-0000-0000-000000000007',$p$a se odihni$p$,$p$descansar$p$,355,'verbo'),
 ('38ffe7e4-b481-5d01-90c3-6141e3c06866','20000000-0000-0000-0000-000000000007',$p$un doctor$p$,$p$el médico, el doctor$p$,356,'sustantivo'),
 ('21b6b9c2-2ba4-5bf6-a800-099b03675f71','20000000-0000-0000-0000-000000000007',$p$o rețetă$p$,$p$la receta médica$p$,357,'sustantivo'),
 ('fcb0cb04-281f-57d0-ba67-0fd02e86665d','20000000-0000-0000-0000-000000000007',$p$un medicament$p$,$p$el medicamento$p$,358,'sustantivo')
on conflict (id) do nothing;

commit;