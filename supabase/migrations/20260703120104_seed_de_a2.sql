-- 20260703120104_seed_de_a2.sql
-- Currículo A2 del curso es→de (6 unidades). Molde es→pt.
-- Contenido scopeado a course_id=20000000-0000-0000-0000-000000000005 → aislamiento multicurso por
-- jz_active_course. Unidades order_index continúan la cadena → gating al nivel previo.
begin;
insert into languages (id, code, name) values
  ('10000000-0000-0000-0000-000000000006','de',$p$Deutsch$p$) on conflict (id) do nothing;
insert into courses (id, source_language_id, target_language_id, is_active) values
  ('20000000-0000-0000-0000-000000000005','10000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000006',true) on conflict (id) do nothing;

-- ── Unidad 7 (A2·de): El pasado: lo que hice ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('ecfca662-cbcf-503f-ad83-9e6a28000d73','20000000-0000-0000-0000-000000000005','A2',7,$p$El pasado: lo que hice$p$,'#C0392B','history_edu')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('4d3ac6bd-4d03-5692-86ca-94c9d0ffaec3','ecfca662-cbcf-503f-ad83-9e6a28000d73',1,$p$Ayer hice… (Perfekt con haben)$p$,$p$Ayer hice… (Perfekt con haben)$p$,'lesson',15),
 ('74dc3444-07e5-5f1e-98b8-a09714e999c7','ecfca662-cbcf-503f-ad83-9e6a28000d73',2,$p$Participios irregulares$p$,$p$Participios irregulares$p$,'lesson',15),
 ('2ad70b1c-4bdb-5312-884f-c66c7249c91c','ecfca662-cbcf-503f-ad83-9e6a28000d73',3,$p$Preguntas y negación en pasado$p$,$p$Preguntas y negación en pasado$p$,'lesson',15),
 ('ef3389b8-6303-5731-aa4f-02b037fd3d3f','ecfca662-cbcf-503f-ad83-9e6a28000d73',4,$p$La semana pasada$p$,$p$La semana pasada$p$,'lesson',15),
 ('4f9f0586-c001-57ea-8886-e716c031225a','ecfca662-cbcf-503f-ad83-9e6a28000d73',5,$p$🏁 Checkpoint Einheit 7$p$,$p$Demuestra que dominas el pasado (Perfekt) con haben y los participios.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('09521ba9-8680-58f3-a15a-40323de82daa','20000000-0000-0000-0000-000000000005','checkpoint','A2','ecfca662-cbcf-503f-ad83-9e6a28000d73',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('75526444-713c-59ea-b815-17b71c8f9720'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','reading','match',$p$Une cada participio con su significado.$p$,$j${"pairs": [{"en": "gemacht", "es": "hecho"}, {"en": "gekauft", "es": "comprado"}, {"en": "gespielt", "es": "jugado"}]}$j$::jsonb,$j${"pairs": [["gemacht", "hecho"], ["gekauft", "comprado"], ["gespielt", "jugado"]]}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$partizip_regular$p$, $p$reading$p$]),
('d1fe8978-47bd-55ab-b99f-9a98a542e1ae'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','reading','multiple_choice',$p$Elige la frase correcta en pasado (Perfekt).$p$,$j${"options": ["Ich habe gestern gearbeitet.", "Ich habe gestern arbeiten.", "Ich gearbeitet gestern habe."]}$j$::jsonb,$j${"value": "Ich habe gestern gearbeitet."}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$perfekt_haben$p$, $p$reading$p$]),
('00144609-e66a-53c5-830b-c7b7bb3e566b'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','writing','cloze',$p$Completa la frase (ayer jugué al fútbol).$p$,$j${"text": "Ich ___ gestern Fußball gespielt."}$j$::jsonb,$j${"value": "habe", "accepted": ["habe"]}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$perfekt_haben$p$, $p$writing$p$]),
('8ad5b11a-fad0-53ae-903b-474c63279acf'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ich habe eine Pizza gekauft.", "Ich habe eine Pizza gekocht.", "Ich habe einen Kuchen gekauft."], "say": "Ich habe eine Pizza gekauft.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/8ad5b11a-fad0-53ae-903b-474c63279acf.mp3"}$j$::jsonb,$j${"value": "Ich habe eine Pizza gekauft."}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$perfekt_haben$p$, $p$listening$p$]),
('58e7997f-8796-51d9-91d4-94bb6afdcdb6'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Ich habe gestern viel gearbeitet.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/58e7997f-8796-51d9-91d4-94bb6afdcdb6.mp3"}$j$::jsonb,$j${"expected": "Ich habe gestern viel gearbeitet."}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$perfekt_haben$p$, $p$speaking$p$]),
('1bf0e368-d1d6-5080-bc59-11482e19c897'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','reading','match',$p$Une cada participio irregular con su significado.$p$,$j${"pairs": [{"en": "gegessen", "es": "comido"}, {"en": "getrunken", "es": "bebido"}, {"en": "gelesen", "es": "leído"}]}$j$::jsonb,$j${"pairs": [["gegessen", "comido"], ["getrunken", "bebido"], ["gelesen", "leído"]]}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$partizip_irregular$p$, $p$reading$p$]),
('c942f55b-4062-5094-b846-2f548d8445e7'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','reading','multiple_choice',$p$Elige el participio correcto de 'essen' (comer).$p$,$j${"options": ["gegessen", "gegesst", "geesst"]}$j$::jsonb,$j${"value": "gegessen"}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$partizip_irregular$p$, $p$reading$p$]),
('153e1e79-0f63-5aab-9ddc-fc24a319650e'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','writing','translation',$p$Traduce: He bebido un café.$p$,$j${"source": "He bebido un café."}$j$::jsonb,$j${"value": "Ich habe einen Kaffee getrunken.", "accepted": ["Ich habe einen Kaffee getrunken.", "Ich habe einen Kaffee getrunken"]}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$partizip_irregular$p$, $p$writing$p$]),
('40fc647d-6f98-50a0-a31c-1545495532ac'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ich habe ein Buch gelesen.", "Ich habe ein Buch genommen.", "Ich habe einen Brief geschrieben."], "say": "Ich habe ein Buch gelesen.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/40fc647d-6f98-50a0-a31c-1545495532ac.mp3"}$j$::jsonb,$j${"value": "Ich habe ein Buch gelesen."}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$partizip_irregular$p$, $p$listening$p$]),
('6c161650-9ef6-5ce5-97ba-edec56d5f465'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Wir haben Pizza gegessen und Cola getrunken.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/6c161650-9ef6-5ce5-97ba-edec56d5f465.mp3"}$j$::jsonb,$j${"expected": "Wir haben Pizza gegessen und Cola getrunken."}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$partizip_irregular$p$, $p$speaking$p$]),
('16da8344-7867-54df-8937-1eaefae94d6b'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','reading','multiple_choice',$p$Elige la pregunta correcta en pasado.$p$,$j${"options": ["Was hast du gestern gemacht?", "Was du hast gestern gemacht?", "Was hast du gestern machen?"]}$j$::jsonb,$j${"value": "Was hast du gestern gemacht?"}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$fragen_negation_perfekt$p$, $p$reading$p$]),
('a2411838-69d0-5683-a8bb-fdf128ee59c2'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','writing','cloze',$p$Completa la respuesta (no hice nada).$p$,$j${"text": "Ich habe ___ gemacht."}$j$::jsonb,$j${"value": "nichts", "accepted": ["nichts"]}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$fragen_negation_perfekt$p$, $p$writing$p$]),
('5f2fb25e-722f-5381-a895-48a897de75d9'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','writing','word_bank',$p$Construye la frase: Ayer compré un libro.$p$,$j${"tiles": ["Buch", "habe", "gestern", "Ich", "kaufen", "ein", "gekauft", "hat"]}$j$::jsonb,$j${"value": "Ich habe gestern ein Buch gekauft", "sequence": ["Ich", "habe", "gestern", "ein", "Buch", "gekauft"]}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$fragen_negation_perfekt$p$, $p$writing$p$]),
('8c666aba-f137-553d-9d86-6e305b2efe55'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Was hast du am Wochenende gemacht?", "Was hast du am Wochenende gekauft?", "Wo hast du am Wochenende gespielt?"], "say": "Was hast du am Wochenende gemacht?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/8c666aba-f137-553d-9d86-6e305b2efe55.mp3"}$j$::jsonb,$j${"value": "Was hast du am Wochenende gemacht?"}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$fragen_negation_perfekt$p$, $p$listening$p$]),
('e705af85-89c5-5182-86b7-7c5bae05e333'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ich habe nichts gegessen.", "Ich habe nichts getrunken.", "Ich habe alles gegessen."], "say": "Ich habe nichts gegessen.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/e705af85-89c5-5182-86b7-7c5bae05e333.mp3"}$j$::jsonb,$j${"value": "Ich habe nichts gegessen."}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$fragen_negation_perfekt$p$, $p$listening$p$]),
('481a28c6-87f2-55e1-a3b5-587f6d612d0b'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','reading','multiple_choice',$p$¿Qué significa 'vorgestern'?$p$,$j${"options": ["anteayer", "mañana", "la semana pasada"]}$j$::jsonb,$j${"value": "anteayer"}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$zeitausdruecke_vergangenheit$p$, $p$reading$p$]),
('b1021460-5ca9-516a-ba6e-484b4af6c2ae'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','writing','translation',$p$Traduce: La semana pasada escribí un email.$p$,$j${"source": "La semana pasada escribí un email."}$j$::jsonb,$j${"value": "Letzte Woche habe ich eine E-Mail geschrieben.", "accepted": ["Letzte Woche habe ich eine E-Mail geschrieben.", "Letzte Woche habe ich eine E-Mail geschrieben", "Letzte Woche habe ich eine Email geschrieben.", "Letzte Woche habe ich eine Email geschrieben", "Ich habe letzte Woche eine E-Mail geschrieben.", "Ich habe letzte Woche eine E-Mail geschrieben", "Ich habe letzte Woche eine Email geschrieben.", "Ich habe letzte Woche eine Email geschrieben"]}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$zeitausdruecke_vergangenheit$p$, $p$writing$p$]),
('3415a514-1a7a-54d9-912a-83ae94287c27'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','writing','reorder',$p$Ordena las palabras para formar la pregunta (¿qué hiciste anteayer?).$p$,$j${"tiles": ["gemacht?", "du", "Was", "vorgestern", "hast"]}$j$::jsonb,$j${"value": "Was hast du vorgestern gemacht?"}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$zeitausdruecke_vergangenheit$p$, $p$writing$p$]),
('1c2bf1ae-281b-5228-9f8a-af262bf4a9b3'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Letzte Woche habe ich viel gearbeitet.", "Letzte Woche habe ich viel gespielt.", "Letztes Jahr habe ich viel gearbeitet."], "say": "Letzte Woche habe ich viel gearbeitet.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/1c2bf1ae-281b-5228-9f8a-af262bf4a9b3.mp3"}$j$::jsonb,$j${"value": "Letzte Woche habe ich viel gearbeitet."}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$zeitausdruecke_vergangenheit$p$, $p$listening$p$]),
('6b85c7dc-6adb-5cb7-9812-631048955a95'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Was hast du gestern gemacht?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/6b85c7dc-6adb-5cb7-9812-631048955a95.mp3"}$j$::jsonb,$j${"expected": "Was hast du gestern gemacht?"}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$zeitausdruecke_vergangenheit$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('4d3ac6bd-4d03-5692-86ca-94c9d0ffaec3','75526444-713c-59ea-b815-17b71c8f9720',1),
 ('4d3ac6bd-4d03-5692-86ca-94c9d0ffaec3','d1fe8978-47bd-55ab-b99f-9a98a542e1ae',2),
 ('4d3ac6bd-4d03-5692-86ca-94c9d0ffaec3','00144609-e66a-53c5-830b-c7b7bb3e566b',3),
 ('4d3ac6bd-4d03-5692-86ca-94c9d0ffaec3','8ad5b11a-fad0-53ae-903b-474c63279acf',4),
 ('4d3ac6bd-4d03-5692-86ca-94c9d0ffaec3','58e7997f-8796-51d9-91d4-94bb6afdcdb6',5),
 ('74dc3444-07e5-5f1e-98b8-a09714e999c7','1bf0e368-d1d6-5080-bc59-11482e19c897',1),
 ('74dc3444-07e5-5f1e-98b8-a09714e999c7','c942f55b-4062-5094-b846-2f548d8445e7',2),
 ('74dc3444-07e5-5f1e-98b8-a09714e999c7','153e1e79-0f63-5aab-9ddc-fc24a319650e',3),
 ('74dc3444-07e5-5f1e-98b8-a09714e999c7','40fc647d-6f98-50a0-a31c-1545495532ac',4),
 ('74dc3444-07e5-5f1e-98b8-a09714e999c7','6c161650-9ef6-5ce5-97ba-edec56d5f465',5),
 ('2ad70b1c-4bdb-5312-884f-c66c7249c91c','16da8344-7867-54df-8937-1eaefae94d6b',1),
 ('2ad70b1c-4bdb-5312-884f-c66c7249c91c','a2411838-69d0-5683-a8bb-fdf128ee59c2',2),
 ('2ad70b1c-4bdb-5312-884f-c66c7249c91c','5f2fb25e-722f-5381-a895-48a897de75d9',3),
 ('2ad70b1c-4bdb-5312-884f-c66c7249c91c','8c666aba-f137-553d-9d86-6e305b2efe55',4),
 ('2ad70b1c-4bdb-5312-884f-c66c7249c91c','e705af85-89c5-5182-86b7-7c5bae05e333',5),
 ('ef3389b8-6303-5731-aa4f-02b037fd3d3f','481a28c6-87f2-55e1-a3b5-587f6d612d0b',1),
 ('ef3389b8-6303-5731-aa4f-02b037fd3d3f','b1021460-5ca9-516a-ba6e-484b4af6c2ae',2),
 ('ef3389b8-6303-5731-aa4f-02b037fd3d3f','3415a514-1a7a-54d9-912a-83ae94287c27',3),
 ('ef3389b8-6303-5731-aa4f-02b037fd3d3f','1c2bf1ae-281b-5228-9f8a-af262bf4a9b3',4),
 ('ef3389b8-6303-5731-aa4f-02b037fd3d3f','6b85c7dc-6adb-5cb7-9812-631048955a95',5),
 ('4f9f0586-c001-57ea-8886-e716c031225a','75526444-713c-59ea-b815-17b71c8f9720',1),
 ('4f9f0586-c001-57ea-8886-e716c031225a','d1fe8978-47bd-55ab-b99f-9a98a542e1ae',2),
 ('4f9f0586-c001-57ea-8886-e716c031225a','1bf0e368-d1d6-5080-bc59-11482e19c897',3),
 ('4f9f0586-c001-57ea-8886-e716c031225a','00144609-e66a-53c5-830b-c7b7bb3e566b',4),
 ('4f9f0586-c001-57ea-8886-e716c031225a','153e1e79-0f63-5aab-9ddc-fc24a319650e',5),
 ('4f9f0586-c001-57ea-8886-e716c031225a','a2411838-69d0-5683-a8bb-fdf128ee59c2',6),
 ('4f9f0586-c001-57ea-8886-e716c031225a','8ad5b11a-fad0-53ae-903b-474c63279acf',7),
 ('4f9f0586-c001-57ea-8886-e716c031225a','40fc647d-6f98-50a0-a31c-1545495532ac',8),
 ('4f9f0586-c001-57ea-8886-e716c031225a','58e7997f-8796-51d9-91d4-94bb6afdcdb6',9),
 ('4f9f0586-c001-57ea-8886-e716c031225a','6c161650-9ef6-5ce5-97ba-edec56d5f465',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('05d6b1e9-be20-58c7-8171-0fa16f2f52f5','20000000-0000-0000-0000-000000000005',$p$gestern$p$,$p$ayer$p$,241,'adverbio'),
 ('a590b64d-7c29-5b6f-88a7-48baa3f849c5','20000000-0000-0000-0000-000000000005',$p$vorgestern$p$,$p$anteayer$p$,242,'adverbio'),
 ('7a565d3b-9b2e-575d-ac4c-8cc35134ae58','20000000-0000-0000-0000-000000000005',$p$letzte Woche$p$,$p$la semana pasada$p$,243,'expresion'),
 ('266d85b4-0925-5a5b-86ec-1fc902a9796a','20000000-0000-0000-0000-000000000005',$p$am Wochenende$p$,$p$el fin de semana$p$,244,'expresion'),
 ('7c1e0508-1331-56b9-9787-f7da86a64f72','20000000-0000-0000-0000-000000000005',$p$gemacht$p$,$p$hecho$p$,245,'verbo'),
 ('db791ed7-cc6b-5ed5-bb67-992613f3b116','20000000-0000-0000-0000-000000000005',$p$gekauft$p$,$p$comprado$p$,246,'verbo'),
 ('619c5e4b-dd15-5cc8-8091-8d4c9ca03689','20000000-0000-0000-0000-000000000005',$p$gearbeitet$p$,$p$trabajado$p$,247,'verbo'),
 ('8c49bcf4-dcaf-5327-ad3c-a1870b7f52f2','20000000-0000-0000-0000-000000000005',$p$gespielt$p$,$p$jugado$p$,248,'verbo'),
 ('e60bcdde-55d8-5f26-b4a9-5b4db7910926','20000000-0000-0000-0000-000000000005',$p$gegessen$p$,$p$comido$p$,249,'verbo'),
 ('c28b6b4f-bc9f-59cd-8355-1cce371c70a3','20000000-0000-0000-0000-000000000005',$p$getrunken$p$,$p$bebido$p$,250,'verbo'),
 ('4790d3b8-5a6d-5b4e-bb23-4b97ac21ee84','20000000-0000-0000-0000-000000000005',$p$gesehen$p$,$p$visto$p$,251,'verbo'),
 ('7b7cb3d7-bb31-5c7d-a3d4-f752c5080d84','20000000-0000-0000-0000-000000000005',$p$gelesen$p$,$p$leído$p$,252,'verbo'),
 ('87af3ac2-a57c-5513-9427-46b30b0d13a1','20000000-0000-0000-0000-000000000005',$p$geschrieben$p$,$p$escrito$p$,253,'verbo'),
 ('7c62c5e1-3a02-53e2-94c4-733a9e610fe5','20000000-0000-0000-0000-000000000005',$p$genommen$p$,$p$tomado$p$,254,'verbo'),
 ('a3aad2b1-51bb-5655-bc8e-62e7c0163b52','20000000-0000-0000-0000-000000000005',$p$nichts$p$,$p$nada$p$,255,'pronombre'),
 ('f712aad3-6413-5de3-b1e0-8ddb6cdb726d','20000000-0000-0000-0000-000000000005',$p$die E-Mail$p$,$p$el correo electrónico$p$,256,'sustantivo')
on conflict (id) do nothing;

-- ── Unidad 8 (A2·de): Planes y futuro ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('11d53dbc-c495-5a5e-b64c-70761509e7e8','20000000-0000-0000-0000-000000000005','A2',8,$p$Planes y futuro$p$,'#2C3E50','event_available')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('4c21fd2b-db29-53f4-b203-fdc16c65c069','11d53dbc-c495-5a5e-b64c-70761509e7e8',1,$p$Mañana… (presente con valor de futuro)$p$,$p$Mañana… (presente con valor de futuro)$p$,'lesson',15),
 ('10201569-3a6b-5eeb-a0cb-9cf021609f56','11d53dbc-c495-5a5e-b64c-70761509e7e8',2,$p$Futuro con werden$p$,$p$Futuro con werden$p$,'lesson',15),
 ('7711a6ea-867a-546f-a201-b60bf0d99351','11d53dbc-c495-5a5e-b64c-70761509e7e8',3,$p$Quiero: möchte y will$p$,$p$Quiero: möchte y will$p$,'lesson',15),
 ('4b666e05-595b-5fbd-a1f1-1a906a97c86a','11d53dbc-c495-5a5e-b64c-70761509e7e8',4,$p$Pronto: expresiones de tiempo$p$,$p$Pronto: expresiones de tiempo$p$,'lesson',15),
 ('a1786ed9-03f0-575a-8b39-f0218d931168','11d53dbc-c495-5a5e-b64c-70761509e7e8',5,$p$🏁 Checkpoint Einheit 8$p$,$p$Demuestra que puedes hablar de tus planes con presente, werden y möchte/will.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('76e76434-2204-5c4a-9314-8e2803bbbf97','20000000-0000-0000-0000-000000000005','checkpoint','A2','11d53dbc-c495-5a5e-b64c-70761509e7e8',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('54145b61-5be0-5376-94ed-6d8e2482b1a1'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','reading','match',$p$Une cada expresión de tiempo con su significado.$p$,$j${"pairs": [{"en": "morgen", "es": "mañana"}, {"en": "übermorgen", "es": "pasado mañana"}, {"en": "bald", "es": "pronto"}]}$j$::jsonb,$j${"pairs": [["morgen", "mañana"], ["übermorgen", "pasado mañana"], ["bald", "pronto"]]}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$zeitausdruecke_zukunft$p$, $p$reading$p$]),
('8ae721e0-11ad-581e-9418-20098cc32e2d'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','reading','multiple_choice',$p$Elige la frase correcta (mañana voy a Berlín).$p$,$j${"options": ["Morgen fahre ich nach Berlin.", "Morgen ich fahre nach Berlin.", "Morgen fahren ich nach Berlin."]}$j$::jsonb,$j${"value": "Morgen fahre ich nach Berlin."}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$futur_praesens_inversion$p$, $p$reading$p$]),
('7a59e212-6dff-50ef-a92d-ebd41c95ed2e'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','writing','cloze',$p$Completa la frase (pasado mañana visito a mi abuela).$p$,$j${"text": "Übermorgen ___ ich meine Oma."}$j$::jsonb,$j${"value": "besuche", "accepted": ["besuche"]}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$futur_praesens_inversion$p$, $p$writing$p$]),
('6bab6dae-f55c-5932-adef-d7ebbbcf0e26'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Morgen arbeite ich nicht.", "Morgen arbeite ich viel.", "Heute arbeite ich nicht."], "say": "Morgen arbeite ich nicht.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/6bab6dae-f55c-5932-adef-d7ebbbcf0e26.mp3"}$j$::jsonb,$j${"value": "Morgen arbeite ich nicht."}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$futur_praesens_inversion$p$, $p$listening$p$]),
('f2a795b8-7fcb-5347-bb99-b6d08d6bdadd'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Morgen fahre ich nach Berlin.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/f2a795b8-7fcb-5347-bb99-b6d08d6bdadd.mp3"}$j$::jsonb,$j${"expected": "Morgen fahre ich nach Berlin."}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$futur_praesens_inversion$p$, $p$speaking$p$]),
('10d2ad54-8627-5f43-8f21-4e01a88e769f'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','reading','multiple_choice',$p$Elige la frase correcta con 'werden' (futuro).$p$,$j${"options": ["Ich werde nächstes Jahr Deutsch lernen.", "Ich werde nächstes Jahr lerne Deutsch.", "Ich lernen werde nächstes Jahr Deutsch."]}$j$::jsonb,$j${"value": "Ich werde nächstes Jahr Deutsch lernen."}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$futur_werden$p$, $p$reading$p$]),
('4a2fa490-2e18-5150-8b3c-43a6759bbbcb'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','writing','translation',$p$Traduce: Voy a viajar pronto.$p$,$j${"source": "Voy a viajar pronto."}$j$::jsonb,$j${"value": "Ich werde bald reisen.", "accepted": ["Ich werde bald reisen.", "Ich werde bald reisen", "Bald werde ich reisen.", "Bald werde ich reisen"]}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$futur_werden$p$, $p$writing$p$]),
('63fb5522-317c-5321-930e-f1901a8d6ae0'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','writing','reorder',$p$Ordena las palabras (pasado mañana visitaré a mis padres).$p$,$j${"tiles": ["besuchen", "werde", "Übermorgen", "meine", "ich", "Eltern"]}$j$::jsonb,$j${"value": "Übermorgen werde ich meine Eltern besuchen"}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$futur_werden$p$, $p$writing$p$]),
('7ba61726-5336-5ef1-b0f3-cfc19dd71397'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ich werde nächstes Jahr nach Deutschland reisen.", "Ich werde nächste Woche nach Deutschland reisen.", "Ich werde nächstes Jahr in Deutschland arbeiten."], "say": "Ich werde nächstes Jahr nach Deutschland reisen.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/7ba61726-5336-5ef1-b0f3-cfc19dd71397.mp3"}$j$::jsonb,$j${"value": "Ich werde nächstes Jahr nach Deutschland reisen."}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$futur_werden$p$, $p$listening$p$]),
('b2769355-e8c1-5146-8378-b6d2a7ed0f08'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Ich werde bald Deutsch lernen.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/b2769355-e8c1-5146-8378-b6d2a7ed0f08.mp3"}$j$::jsonb,$j${"expected": "Ich werde bald Deutsch lernen."}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$futur_werden$p$, $p$speaking$p$]),
('4b542f13-2776-5071-97ee-e4a3e75ffc32'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','reading','match',$p$Une cada palabra con su significado.$p$,$j${"pairs": [{"en": "reisen", "es": "viajar"}, {"en": "besuchen", "es": "visitar"}, {"en": "der Urlaub", "es": "las vacaciones"}]}$j$::jsonb,$j${"pairs": [["reisen", "viajar"], ["besuchen", "visitar"], ["der Urlaub", "las vacaciones"]]}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$modalverben_plaene$p$, $p$reading$p$]),
('0e0ff4fb-bd7b-5fac-abb3-6d41f4864f90'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','reading','multiple_choice',$p$Elige la frase correcta (me gustaría beber un café).$p$,$j${"options": ["Ich möchte einen Kaffee trinken.", "Ich möchte trinken einen Kaffee.", "Ich möchte einen Kaffee trinke."]}$j$::jsonb,$j${"value": "Ich möchte einen Kaffee trinken."}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$modalverben_plaene$p$, $p$reading$p$]),
('3a4222e5-3e29-5e43-9a68-070610a19f35'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','writing','cloze',$p$Completa la frase (queremos hacer un viaje el próximo año).$p$,$j${"text": "Wir ___ nächstes Jahr eine Reise machen."}$j$::jsonb,$j${"value": "wollen", "accepted": ["wollen", "möchten", "moechten"]}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$modalverben_plaene$p$, $p$writing$p$]),
('05f514a1-43ba-55af-9e4b-a297a9aebdee'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','writing','word_bank',$p$Construye la frase: Quiero ver una película.$p$,$j${"tiles": ["Film", "will", "sehen", "Ich", "einen", "sieht", "wollen"]}$j$::jsonb,$j${"value": "Ich will einen Film sehen", "sequence": ["Ich", "will", "einen", "Film", "sehen"]}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$modalverben_plaene$p$, $p$writing$p$]),
('ec21a65d-75d3-5f35-a049-db4bfff27686'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ich möchte nach Spanien fahren.", "Ich möchte in Spanien wohnen.", "Ich will nach Spanien fahren."], "say": "Ich möchte nach Spanien fahren.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/ec21a65d-75d3-5f35-a049-db4bfff27686.mp3"}$j$::jsonb,$j${"value": "Ich möchte nach Spanien fahren."}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$modalverben_plaene$p$, $p$listening$p$]),
('f80bffe9-58b9-5290-a9b1-c4f0e01a5108'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','reading','multiple_choice',$p$¿Qué significa 'nächstes Jahr'?$p$,$j${"options": ["el próximo año", "el año pasado", "la próxima semana"]}$j$::jsonb,$j${"value": "el próximo año"}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$zeitausdruecke_zukunft$p$, $p$reading$p$]),
('5ffe2542-c8b7-591f-9347-20e2e5a83157'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','writing','translation',$p$Traduce: La próxima semana voy a trabajar mucho.$p$,$j${"source": "La próxima semana voy a trabajar mucho."}$j$::jsonb,$j${"value": "Nächste Woche werde ich viel arbeiten.", "accepted": ["Nächste Woche werde ich viel arbeiten.", "Nächste Woche werde ich viel arbeiten", "Naechste Woche werde ich viel arbeiten.", "Naechste Woche werde ich viel arbeiten", "Ich werde nächste Woche viel arbeiten.", "Ich werde nächste Woche viel arbeiten", "Ich werde naechste Woche viel arbeiten.", "Ich werde naechste Woche viel arbeiten", "Nächste Woche arbeite ich viel.", "Nächste Woche arbeite ich viel", "Naechste Woche arbeite ich viel.", "Naechste Woche arbeite ich viel"]}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$zeitausdruecke_zukunft$p$, $p$writing$p$]),
('bc7824f0-e8d1-556b-8708-c80d1f68e631'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Bald beginnt mein Urlaub.", "Bald endet mein Urlaub.", "Morgen beginnt mein Urlaub."], "say": "Bald beginnt mein Urlaub.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/bc7824f0-e8d1-556b-8708-c80d1f68e631.mp3"}$j$::jsonb,$j${"value": "Bald beginnt mein Urlaub."}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$zeitausdruecke_zukunft$p$, $p$listening$p$]),
('79503551-3d90-5def-aafd-9b9203fea61a'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Nächste Woche werde ich meine Freunde besuchen.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/79503551-3d90-5def-aafd-9b9203fea61a.mp3"}$j$::jsonb,$j${"expected": "Nächste Woche werde ich meine Freunde besuchen."}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$zeitausdruecke_zukunft$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('4c21fd2b-db29-53f4-b203-fdc16c65c069','54145b61-5be0-5376-94ed-6d8e2482b1a1',1),
 ('4c21fd2b-db29-53f4-b203-fdc16c65c069','8ae721e0-11ad-581e-9418-20098cc32e2d',2),
 ('4c21fd2b-db29-53f4-b203-fdc16c65c069','7a59e212-6dff-50ef-a92d-ebd41c95ed2e',3),
 ('4c21fd2b-db29-53f4-b203-fdc16c65c069','6bab6dae-f55c-5932-adef-d7ebbbcf0e26',4),
 ('4c21fd2b-db29-53f4-b203-fdc16c65c069','f2a795b8-7fcb-5347-bb99-b6d08d6bdadd',5),
 ('10201569-3a6b-5eeb-a0cb-9cf021609f56','10d2ad54-8627-5f43-8f21-4e01a88e769f',1),
 ('10201569-3a6b-5eeb-a0cb-9cf021609f56','4a2fa490-2e18-5150-8b3c-43a6759bbbcb',2),
 ('10201569-3a6b-5eeb-a0cb-9cf021609f56','63fb5522-317c-5321-930e-f1901a8d6ae0',3),
 ('10201569-3a6b-5eeb-a0cb-9cf021609f56','7ba61726-5336-5ef1-b0f3-cfc19dd71397',4),
 ('10201569-3a6b-5eeb-a0cb-9cf021609f56','b2769355-e8c1-5146-8378-b6d2a7ed0f08',5),
 ('7711a6ea-867a-546f-a201-b60bf0d99351','4b542f13-2776-5071-97ee-e4a3e75ffc32',1),
 ('7711a6ea-867a-546f-a201-b60bf0d99351','0e0ff4fb-bd7b-5fac-abb3-6d41f4864f90',2),
 ('7711a6ea-867a-546f-a201-b60bf0d99351','3a4222e5-3e29-5e43-9a68-070610a19f35',3),
 ('7711a6ea-867a-546f-a201-b60bf0d99351','05f514a1-43ba-55af-9e4b-a297a9aebdee',4),
 ('7711a6ea-867a-546f-a201-b60bf0d99351','ec21a65d-75d3-5f35-a049-db4bfff27686',5),
 ('4b666e05-595b-5fbd-a1f1-1a906a97c86a','f80bffe9-58b9-5290-a9b1-c4f0e01a5108',1),
 ('4b666e05-595b-5fbd-a1f1-1a906a97c86a','5ffe2542-c8b7-591f-9347-20e2e5a83157',2),
 ('4b666e05-595b-5fbd-a1f1-1a906a97c86a','bc7824f0-e8d1-556b-8708-c80d1f68e631',3),
 ('4b666e05-595b-5fbd-a1f1-1a906a97c86a','79503551-3d90-5def-aafd-9b9203fea61a',4),
 ('a1786ed9-03f0-575a-8b39-f0218d931168','54145b61-5be0-5376-94ed-6d8e2482b1a1',1),
 ('a1786ed9-03f0-575a-8b39-f0218d931168','8ae721e0-11ad-581e-9418-20098cc32e2d',2),
 ('a1786ed9-03f0-575a-8b39-f0218d931168','10d2ad54-8627-5f43-8f21-4e01a88e769f',3),
 ('a1786ed9-03f0-575a-8b39-f0218d931168','7a59e212-6dff-50ef-a92d-ebd41c95ed2e',4),
 ('a1786ed9-03f0-575a-8b39-f0218d931168','4a2fa490-2e18-5150-8b3c-43a6759bbbcb',5),
 ('a1786ed9-03f0-575a-8b39-f0218d931168','63fb5522-317c-5321-930e-f1901a8d6ae0',6),
 ('a1786ed9-03f0-575a-8b39-f0218d931168','6bab6dae-f55c-5932-adef-d7ebbbcf0e26',7),
 ('a1786ed9-03f0-575a-8b39-f0218d931168','7ba61726-5336-5ef1-b0f3-cfc19dd71397',8),
 ('a1786ed9-03f0-575a-8b39-f0218d931168','f2a795b8-7fcb-5347-bb99-b6d08d6bdadd',9),
 ('a1786ed9-03f0-575a-8b39-f0218d931168','b2769355-e8c1-5146-8378-b6d2a7ed0f08',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('6f98b2ec-9370-56c5-8b61-5211fa6b87d2','20000000-0000-0000-0000-000000000005',$p$morgen$p$,$p$mañana$p$,261,'adverbio'),
 ('779c4744-d1a5-5d9d-a25b-03d1325e28a3','20000000-0000-0000-0000-000000000005',$p$übermorgen$p$,$p$pasado mañana$p$,262,'adverbio'),
 ('efdcae2d-55b3-5d4d-ae2e-2c382640d26b','20000000-0000-0000-0000-000000000005',$p$nächste Woche$p$,$p$la próxima semana$p$,263,'expresion'),
 ('59a8be9c-3091-5cc1-bfd8-e5a9463d8e98','20000000-0000-0000-0000-000000000005',$p$nächstes Jahr$p$,$p$el próximo año$p$,264,'expresion'),
 ('d7183560-5f73-5af2-a6d7-51d1c72a2f84','20000000-0000-0000-0000-000000000005',$p$bald$p$,$p$pronto$p$,265,'adverbio'),
 ('ca1484fd-dcfb-503b-bc43-c80569bd1b71','20000000-0000-0000-0000-000000000005',$p$werden$p$,$p$ir a (auxiliar de futuro)$p$,266,'verbo'),
 ('073d92c0-32ef-506a-8b1b-b74ce0d096bd','20000000-0000-0000-0000-000000000005',$p$möchten$p$,$p$querer (cortés)$p$,267,'verbo'),
 ('1397fd85-c2eb-5ef2-89f1-7a718565d8d0','20000000-0000-0000-0000-000000000005',$p$wollen$p$,$p$querer$p$,268,'verbo'),
 ('cbe190de-44b4-548c-b12d-499e23783875','20000000-0000-0000-0000-000000000005',$p$reisen$p$,$p$viajar$p$,269,'verbo'),
 ('8dc3f85b-f036-5ff9-8aaa-3c46e1f5f882','20000000-0000-0000-0000-000000000005',$p$besuchen$p$,$p$visitar$p$,270,'verbo'),
 ('e3b42860-7c63-5f88-9077-0d5ff16e0969','20000000-0000-0000-0000-000000000005',$p$lernen$p$,$p$aprender$p$,271,'verbo'),
 ('9c82452a-87ba-559c-b003-c45fb545ff5d','20000000-0000-0000-0000-000000000005',$p$fahren$p$,$p$ir (en vehículo)$p$,272,'verbo'),
 ('2e139050-f6e4-51d6-8a1a-176dd3687063','20000000-0000-0000-0000-000000000005',$p$der Plan$p$,$p$el plan$p$,273,'sustantivo'),
 ('f53acc85-f239-597f-8200-f0432fec1195','20000000-0000-0000-0000-000000000005',$p$die Reise$p$,$p$el viaje$p$,274,'sustantivo'),
 ('d6d0ba09-a11b-5484-a984-4198aa5fb001','20000000-0000-0000-0000-000000000005',$p$der Urlaub$p$,$p$las vacaciones$p$,275,'sustantivo'),
 ('98b20663-25af-5c3b-9cb6-4dfab95233e3','20000000-0000-0000-0000-000000000005',$p$vielleicht$p$,$p$quizás$p$,276,'adverbio')
on conflict (id) do nothing;

-- ── Unidad 9 (A2·de): De viaje ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('4778bbaf-98e8-53a2-b545-7b77d74c9f9d','20000000-0000-0000-0000-000000000005','A2',9,$p$De viaje$p$,'#16A085','flight_takeoff')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('1e26fcc1-f857-5ab6-8a46-56b7ded91ddf','4778bbaf-98e8-53a2-b545-7b77d74c9f9d',1,$p$He viajado: el Perfekt con sein$p$,$p$He viajado: el Perfekt con sein$p$,'lesson',15),
 ('ed61df0a-db3b-5189-8b07-7d8c105e6d3a','4778bbaf-98e8-53a2-b545-7b77d74c9f9d',2,$p$En la estación y el aeropuerto$p$,$p$En la estación y el aeropuerto$p$,'lesson',15),
 ('e79ed9db-2754-5ba2-981b-d17b7823e5ec','4778bbaf-98e8-53a2-b545-7b77d74c9f9d',3,$p$¿Haben o sein?$p$,$p$¿Haben o sein?$p$,'lesson',15),
 ('6d568902-99ab-5166-abfa-f932b715659a','4778bbaf-98e8-53a2-b545-7b77d74c9f9d',4,$p$Contando el viaje$p$,$p$Contando el viaje$p$,'lesson',15),
 ('24789a99-ddfa-5f2c-beb2-0cb196004762','4778bbaf-98e8-53a2-b545-7b77d74c9f9d',5,$p$🏁 Checkpoint Einheit 9$p$,$p$Demuestra que sabes contar un viaje usando el Perfekt con sein y el vocabulario de transporte.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('719ce693-ea41-5231-8460-a68086057a3e','20000000-0000-0000-0000-000000000005','checkpoint','A2','4778bbaf-98e8-53a2-b545-7b77d74c9f9d',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('9e095111-7aba-5fe2-8a7c-c458a06aed91'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','reading','multiple_choice',$p$Elige la frase correcta.$p$,$j${"options": ["Ich bin nach Berlin gefahren.", "Ich habe nach Berlin gefahren.", "Ich bin nach Berlin fahren."]}$j$::jsonb,$j${"value": "Ich bin nach Berlin gefahren."}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$perfekt_sein$p$, $p$reading$p$]),
('dea5cb57-5d78-548e-b2f4-4f2245525e37'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','writing','cloze',$p$Completa con el auxiliar correcto.$p$,$j${"text": "Wir ___ gestern nach München gefahren."}$j$::jsonb,$j${"value": "sind", "accepted": ["sind"]}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$perfekt_sein$p$, $p$writing$p$]),
('19e44ebc-0baa-5dbb-a7a2-f75bca0fa2b6'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Sie ist nach Hamburg geflogen.", "Sie ist nach Hamburg gefahren.", "Sie hat in Hamburg gewohnt."], "say": "Sie ist nach Hamburg geflogen.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/19e44ebc-0baa-5dbb-a7a2-f75bca0fa2b6.mp3"}$j$::jsonb,$j${"value": "Sie ist nach Hamburg geflogen."}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$perfekt_sein$p$, $p$listening$p$]),
('b937a9ce-9ea2-5f05-bfc4-69f9f5cdad53'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Ich bin mit dem Zug gefahren.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/b937a9ce-9ea2-5f05-bfc4-69f9f5cdad53.mp3"}$j$::jsonb,$j${"expected": "Ich bin mit dem Zug gefahren."}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$perfekt_sein$p$, $p$speaking$p$]),
('6a1f6030-19e6-517e-9ca9-f4dabbd19286'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','reading','multiple_choice',$p$¿Qué frase está bien construida?$p$,$j${"options": ["Wir sind im Hotel geblieben.", "Wir haben im Hotel geblieben.", "Wir sind im Hotel bleiben."]}$j$::jsonb,$j${"value": "Wir sind im Hotel geblieben."}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$perfekt_sein$p$, $p$reading$p$]),
('9a6d2635-abbf-51cc-bdbc-b9e5bf51e139'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','reading','match',$p$Une cada palabra con su significado.$p$,$j${"pairs": [{"en": "der Bahnhof", "es": "la estación de tren"}, {"en": "der Flughafen", "es": "el aeropuerto"}, {"en": "das Flugzeug", "es": "el avión"}]}$j$::jsonb,$j${"pairs": [["der Bahnhof", "la estación de tren"], ["der Flughafen", "el aeropuerto"], ["das Flugzeug", "el avión"]]}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$transporte$p$, $p$reading$p$]),
('f7f7c85e-b141-5d80-a273-e6f137a3bd41'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','reading','multiple_choice',$p$¿Dónde esperas el tren?$p$,$j${"options": ["am Bahnhof", "am Flughafen", "im Hotel"]}$j$::jsonb,$j${"value": "am Bahnhof"}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$transporte$p$, $p$reading$p$]),
('90a14772-db90-5a7f-bc2b-8f63948c118a'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Der Zug kommt um acht Uhr an.", "Das Flugzeug kommt um acht Uhr an.", "Der Zug kommt um neun Uhr an."], "say": "Der Zug kommt um acht Uhr an.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/90a14772-db90-5a7f-bc2b-8f63948c118a.mp3"}$j$::jsonb,$j${"value": "Der Zug kommt um acht Uhr an."}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$transporte$p$, $p$listening$p$]),
('a9d7601f-e39e-507e-b171-1bcbe58912c3'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Wo ist der Bahnhof, bitte?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/a9d7601f-e39e-507e-b171-1bcbe58912c3.mp3"}$j$::jsonb,$j${"expected": "Wo ist der Bahnhof, bitte?"}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$transporte$p$, $p$speaking$p$]),
('d2069291-7025-5833-ac2d-ac8316a28aca'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','reading','multiple_choice',$p$Elige la frase correcta.$p$,$j${"options": ["Ich habe ein Ticket gekauft.", "Ich bin ein Ticket gekauft.", "Ich habe ein Ticket gekaufen."]}$j$::jsonb,$j${"value": "Ich habe ein Ticket gekauft."}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$haben_vs_sein$p$, $p$reading$p$]),
('123cd1f5-fa9b-5ad9-b5e9-6a91f4bccd9f'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','writing','cloze',$p$Completa con el auxiliar correcto.$p$,$j${"text": "Ich ___ am Wochenende zu Hause geblieben."}$j$::jsonb,$j${"value": "bin", "accepted": ["bin"]}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$haben_vs_sein$p$, $p$writing$p$]),
('15945714-935c-506c-8834-961e50fcf360'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','writing','translation',$p$Traduce: Hemos ido a pie.$p$,$j${"source": "Hemos ido a pie."}$j$::jsonb,$j${"value": "Wir sind zu Fuß gegangen.", "accepted": ["Wir sind zu Fuß gegangen.", "Wir sind zu Fuß gegangen", "Wir sind zu Fuss gegangen.", "Wir sind zu Fuss gegangen"]}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$haben_vs_sein$p$, $p$writing$p$]),
('2355a19f-7d6d-50e0-b82c-40062a50bedd'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','writing','word_bank',$p$Forma la frase: «Ella ha volado a Berlín.»$p$,$j${"tiles": ["nach", "hat", "Sie", "geflogen", "Berlin", "ist"]}$j$::jsonb,$j${"value": "Sie ist nach Berlin geflogen", "sequence": ["Sie", "ist", "nach", "Berlin", "geflogen"]}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$haben_vs_sein$p$, $p$writing$p$]),
('85029453-47fb-583e-85ff-274778596e9a'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ich habe meinen Koffer gepackt.", "Ich habe mein Ticket vergessen.", "Ich bin zu Fuß gegangen."], "say": "Ich habe meinen Koffer gepackt.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/85029453-47fb-583e-85ff-274778596e9a.mp3"}$j$::jsonb,$j${"value": "Ich habe meinen Koffer gepackt."}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$haben_vs_sein$p$, $p$listening$p$]),
('cfb62619-e8af-5819-9edc-b60bfce2c2dd'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','reading','match',$p$Une cada palabra con su significado.$p$,$j${"pairs": [{"en": "der Koffer", "es": "la maleta"}, {"en": "die Reise", "es": "el viaje"}, {"en": "das Ticket", "es": "el billete"}]}$j$::jsonb,$j${"pairs": [["der Koffer", "la maleta"], ["die Reise", "el viaje"], ["das Ticket", "el billete"]]}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$relato_de_viaje$p$, $p$reading$p$]),
('a84f7acc-229b-577b-9177-2dfdb544402e'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','writing','translation',$p$Traduce: He ido a Berlín en tren.$p$,$j${"source": "He ido a Berlín en tren."}$j$::jsonb,$j${"value": "Ich bin mit dem Zug nach Berlin gefahren.", "accepted": ["Ich bin mit dem Zug nach Berlin gefahren.", "Ich bin mit dem Zug nach Berlin gefahren"]}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$relato_de_viaje$p$, $p$writing$p$]),
('a317b3f2-b9a4-5d3e-93b6-f84ae94aa758'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','writing','reorder',$p$Ordena las palabras para formar una frase correcta.$p$,$j${"tiles": ["Tage", "im", "sind", "geblieben", "Wir", "Hotel", "drei"]}$j$::jsonb,$j${"value": "Wir sind drei Tage im Hotel geblieben"}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$relato_de_viaje$p$, $p$writing$p$]),
('7972dcea-b33b-5bcc-b349-31248be91a8d'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Wir sind am Flughafen angekommen.", "Wir sind am Bahnhof angekommen.", "Wir haben den Zug genommen."], "say": "Wir sind am Flughafen angekommen.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/7972dcea-b33b-5bcc-b349-31248be91a8d.mp3"}$j$::jsonb,$j${"value": "Wir sind am Flughafen angekommen."}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$relato_de_viaje$p$, $p$listening$p$]),
('b134a19c-bad5-5402-ada4-0a8c9c18552f'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Gute Reise und bis bald!", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/b134a19c-bad5-5402-ada4-0a8c9c18552f.mp3"}$j$::jsonb,$j${"expected": "Gute Reise und bis bald!"}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$relato_de_viaje$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('1e26fcc1-f857-5ab6-8a46-56b7ded91ddf','9e095111-7aba-5fe2-8a7c-c458a06aed91',1),
 ('1e26fcc1-f857-5ab6-8a46-56b7ded91ddf','dea5cb57-5d78-548e-b2f4-4f2245525e37',2),
 ('1e26fcc1-f857-5ab6-8a46-56b7ded91ddf','19e44ebc-0baa-5dbb-a7a2-f75bca0fa2b6',3),
 ('1e26fcc1-f857-5ab6-8a46-56b7ded91ddf','b937a9ce-9ea2-5f05-bfc4-69f9f5cdad53',4),
 ('1e26fcc1-f857-5ab6-8a46-56b7ded91ddf','6a1f6030-19e6-517e-9ca9-f4dabbd19286',5),
 ('ed61df0a-db3b-5189-8b07-7d8c105e6d3a','9a6d2635-abbf-51cc-bdbc-b9e5bf51e139',1),
 ('ed61df0a-db3b-5189-8b07-7d8c105e6d3a','f7f7c85e-b141-5d80-a273-e6f137a3bd41',2),
 ('ed61df0a-db3b-5189-8b07-7d8c105e6d3a','90a14772-db90-5a7f-bc2b-8f63948c118a',3),
 ('ed61df0a-db3b-5189-8b07-7d8c105e6d3a','a9d7601f-e39e-507e-b171-1bcbe58912c3',4),
 ('e79ed9db-2754-5ba2-981b-d17b7823e5ec','d2069291-7025-5833-ac2d-ac8316a28aca',1),
 ('e79ed9db-2754-5ba2-981b-d17b7823e5ec','123cd1f5-fa9b-5ad9-b5e9-6a91f4bccd9f',2),
 ('e79ed9db-2754-5ba2-981b-d17b7823e5ec','15945714-935c-506c-8834-961e50fcf360',3),
 ('e79ed9db-2754-5ba2-981b-d17b7823e5ec','2355a19f-7d6d-50e0-b82c-40062a50bedd',4),
 ('e79ed9db-2754-5ba2-981b-d17b7823e5ec','85029453-47fb-583e-85ff-274778596e9a',5),
 ('6d568902-99ab-5166-abfa-f932b715659a','cfb62619-e8af-5819-9edc-b60bfce2c2dd',1),
 ('6d568902-99ab-5166-abfa-f932b715659a','a84f7acc-229b-577b-9177-2dfdb544402e',2),
 ('6d568902-99ab-5166-abfa-f932b715659a','a317b3f2-b9a4-5d3e-93b6-f84ae94aa758',3),
 ('6d568902-99ab-5166-abfa-f932b715659a','7972dcea-b33b-5bcc-b349-31248be91a8d',4),
 ('6d568902-99ab-5166-abfa-f932b715659a','b134a19c-bad5-5402-ada4-0a8c9c18552f',5),
 ('24789a99-ddfa-5f2c-beb2-0cb196004762','9e095111-7aba-5fe2-8a7c-c458a06aed91',1),
 ('24789a99-ddfa-5f2c-beb2-0cb196004762','6a1f6030-19e6-517e-9ca9-f4dabbd19286',2),
 ('24789a99-ddfa-5f2c-beb2-0cb196004762','9a6d2635-abbf-51cc-bdbc-b9e5bf51e139',3),
 ('24789a99-ddfa-5f2c-beb2-0cb196004762','dea5cb57-5d78-548e-b2f4-4f2245525e37',4),
 ('24789a99-ddfa-5f2c-beb2-0cb196004762','123cd1f5-fa9b-5ad9-b5e9-6a91f4bccd9f',5),
 ('24789a99-ddfa-5f2c-beb2-0cb196004762','15945714-935c-506c-8834-961e50fcf360',6),
 ('24789a99-ddfa-5f2c-beb2-0cb196004762','19e44ebc-0baa-5dbb-a7a2-f75bca0fa2b6',7),
 ('24789a99-ddfa-5f2c-beb2-0cb196004762','90a14772-db90-5a7f-bc2b-8f63948c118a',8),
 ('24789a99-ddfa-5f2c-beb2-0cb196004762','b937a9ce-9ea2-5f05-bfc4-69f9f5cdad53',9),
 ('24789a99-ddfa-5f2c-beb2-0cb196004762','a9d7601f-e39e-507e-b171-1bcbe58912c3',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('f9b95808-bff3-56ce-8939-88b5eb66bad7','20000000-0000-0000-0000-000000000005',$p$der Zug$p$,$p$el tren$p$,281,'sustantivo'),
 ('6bae28a2-3001-5f6b-9c0c-f59bd68a7e20','20000000-0000-0000-0000-000000000005',$p$das Flugzeug$p$,$p$el avión$p$,282,'sustantivo'),
 ('62d3d8a0-bf60-593b-b5dc-c70184ab57ae','20000000-0000-0000-0000-000000000005',$p$der Bahnhof$p$,$p$la estación de tren$p$,283,'sustantivo'),
 ('910e4ba4-6672-5bac-9ef6-f40850dbda46','20000000-0000-0000-0000-000000000005',$p$der Flughafen$p$,$p$el aeropuerto$p$,284,'sustantivo'),
 ('532b9bcb-e74e-5050-97cd-2b31fde89ce4','20000000-0000-0000-0000-000000000005',$p$das Hotel$p$,$p$el hotel$p$,285,'sustantivo'),
 ('0db081f2-b459-5b93-9315-3454e190e1a2','20000000-0000-0000-0000-000000000005',$p$das Ticket$p$,$p$el billete$p$,286,'sustantivo'),
 ('8b77fbc4-5e7e-5aab-a180-6e7a862946d6','20000000-0000-0000-0000-000000000005',$p$der Koffer$p$,$p$la maleta$p$,287,'sustantivo'),
 ('f97c18b4-a6c6-5518-a2df-f9f5c1cee55d','20000000-0000-0000-0000-000000000005',$p$die Reise$p$,$p$el viaje$p$,288,'sustantivo'),
 ('e7df0a1d-32bc-54ba-a415-925c9ac97883','20000000-0000-0000-0000-000000000005',$p$fahren$p$,$p$ir (en vehículo)$p$,289,'verbo'),
 ('f40ad505-c99a-5f08-8ea2-07279b1e5544','20000000-0000-0000-0000-000000000005',$p$fliegen$p$,$p$volar$p$,290,'verbo'),
 ('ac3bfe9d-7573-5d6d-af85-33b562d122d6','20000000-0000-0000-0000-000000000005',$p$bleiben$p$,$p$quedarse$p$,291,'verbo'),
 ('d9e7a236-000b-5ca6-a876-26ce08668308','20000000-0000-0000-0000-000000000005',$p$ankommen$p$,$p$llegar$p$,292,'verbo'),
 ('b523039a-bdfb-59f3-9b32-4c1b127ecb7e','20000000-0000-0000-0000-000000000005',$p$packen$p$,$p$hacer la maleta$p$,293,'verbo'),
 ('a6913626-b52c-5632-9389-383dfd3069d0','20000000-0000-0000-0000-000000000005',$p$mit dem Zug$p$,$p$en tren$p$,294,'expresion'),
 ('445ae672-d5a0-5c61-9b9c-88ef5d1312f4','20000000-0000-0000-0000-000000000005',$p$zu Fuß$p$,$p$a pie$p$,295,'expresion'),
 ('285e97f9-78c2-54dd-b53e-1cdcf05965c7','20000000-0000-0000-0000-000000000005',$p$Gute Reise!$p$,$p$¡Buen viaje!$p$,296,'expresion')
on conflict (id) do nothing;

-- ── Unidad 10 (A2·de): Comer fuera y comprar ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('5a46ae43-7bb4-52e0-a978-0209111be14f','20000000-0000-0000-0000-000000000005','A2',10,$p$Comer fuera y comprar$p$,'#E67E22','shopping_cart')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('cdde07a7-5aea-5662-92f2-208154ed8857','5a46ae43-7bb4-52e0-a978-0209111be14f',1,$p$En el restaurante$p$,$p$En el restaurante$p$,'lesson',15),
 ('3d8f25bd-4197-546b-a162-1e40955cb744','5a46ae43-7bb4-52e0-a978-0209111be14f',2,$p$Comparar precios$p$,$p$Comparar precios$p$,'lesson',15),
 ('05eaa6ed-eea2-551e-8efb-091c981d290a','5a46ae43-7bb4-52e0-a978-0209111be14f',3,$p$Mejor y preferido$p$,$p$Mejor y preferido$p$,'lesson',15),
 ('cf7670d5-156b-5c80-ba6a-ab7cc9d26fb6','5a46ae43-7bb4-52e0-a978-0209111be14f',4,$p$En el mercado$p$,$p$En el mercado$p$,'lesson',15),
 ('57315eed-d7a2-522a-8e7f-4c76ce544b88','5a46ae43-7bb4-52e0-a978-0209111be14f',5,$p$🏁 Checkpoint Einheit 10$p$,$p$Demuestra que puedes comparar precios y cosas (billiger als, besser) y pedir en un restaurante con cortesía.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('0695ee23-d3f6-5058-9a1c-c8ddec6fbc20','20000000-0000-0000-0000-000000000005','checkpoint','A2','5a46ae43-7bb4-52e0-a978-0209111be14f',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('8bd7cbf4-7e27-5d50-9d2f-34d3964952d7'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','reading','match',$p$Une cada palabra con su significado.$p$,$j${"pairs": [{"en": "die Speisekarte", "es": "la carta"}, {"en": "die Rechnung", "es": "la cuenta"}, {"en": "bestellen", "es": "pedir (comida)"}]}$j$::jsonb,$j${"pairs": [["die Speisekarte", "la carta"], ["die Rechnung", "la cuenta"], ["bestellen", "pedir (comida)"]]}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$restaurante$p$, $p$reading$p$]),
('cf43b735-a644-5c10-9b35-b35d6c7f2e1d'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','reading','multiple_choice',$p$Elige la frase correcta.$p$,$j${"options": ["Ich hätte gern die Speisekarte.", "Ich hätte gern die Speisekarte haben.", "Ich gern hätte die Speisekarte."]}$j$::jsonb,$j${"value": "Ich hätte gern die Speisekarte."}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$restaurante$p$, $p$reading$p$]),
('83312d90-a445-5a00-8fb8-0ed99b4a2bec'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','writing','translation',$p$Traduce: La cuenta, por favor.$p$,$j${"source": "La cuenta, por favor."}$j$::jsonb,$j${"value": "Die Rechnung, bitte.", "accepted": ["Die Rechnung, bitte.", "Die Rechnung, bitte", "Die Rechnung bitte.", "Die Rechnung bitte"]}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$restaurante$p$, $p$writing$p$]),
('a1fb446d-303a-571a-93bd-0a5fe376c68d'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Das schmeckt wirklich gut!", "Das kostet sehr viel.", "Das ist mir zu teuer."], "say": "Das schmeckt wirklich gut!", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/a1fb446d-303a-571a-93bd-0a5fe376c68d.mp3"}$j$::jsonb,$j${"value": "Das schmeckt wirklich gut!"}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$restaurante$p$, $p$listening$p$]),
('a6a332b6-6c04-5780-a174-674f14539bea'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Ich hätte gern einen Kaffee, bitte.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/a6a332b6-6c04-5780-a174-674f14539bea.mp3"}$j$::jsonb,$j${"expected": "Ich hätte gern einen Kaffee, bitte."}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$restaurante$p$, $p$speaking$p$]),
('cb8d0ff4-82c9-5f5d-a26f-b7fb4abf35b0'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','reading','multiple_choice',$p$Elige la frase correcta.$p$,$j${"options": ["Der Apfel ist billiger als die Banane.", "Der Apfel ist billiger wie die Banane.", "Der Apfel ist mehr billig als die Banane."]}$j$::jsonb,$j${"value": "Der Apfel ist billiger als die Banane."}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$comparativo$p$, $p$reading$p$]),
('058bc3ea-19d1-52e7-974d-f30723e5c6b7'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','writing','cloze',$p$Completa con el comparativo de «groß».$p$,$j${"text": "Berlin ist ___ als Bonn."}$j$::jsonb,$j${"value": "größer", "accepted": ["größer", "grösser", "groesser", "groeßer"]}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$comparativo$p$, $p$writing$p$]),
('3f562895-2360-512d-8c11-cc245368043c'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','reading','multiple_choice',$p$¿Cómo preguntas el precio del pan?$p$,$j${"options": ["Was kostet das Brot?", "Was schmeckt das Brot?", "Wo ist das Brot?"]}$j$::jsonb,$j${"value": "Was kostet das Brot?"}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$comparativo$p$, $p$reading$p$]),
('fe8a9ae8-4b77-561a-b11b-1ee6d4d91c44'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Das Hemd ist teurer als die Hose.", "Das Hemd ist billiger als die Hose.", "Die Hose ist mir zu groß."], "say": "Das Hemd ist teurer als die Hose.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/fe8a9ae8-4b77-561a-b11b-1ee6d4d91c44.mp3"}$j$::jsonb,$j${"value": "Das Hemd ist teurer als die Hose."}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$comparativo$p$, $p$listening$p$]),
('4fb70c90-fb3a-5de4-aba6-6c38241519cd'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Was kostet ein Kilo Äpfel?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/4fb70c90-fb3a-5de4-aba6-6c38241519cd.mp3"}$j$::jsonb,$j${"expected": "Was kostet ein Kilo Äpfel?"}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$comparativo$p$, $p$speaking$p$]),
('8357dfd5-7f7a-53a9-b600-c758882fa03d'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','reading','multiple_choice',$p$Elige la frase correcta.$p$,$j${"options": ["Ich trinke lieber Tee als Kaffee.", "Ich trinke gerner Tee als Kaffee.", "Ich trinke mehr gern Tee als Kaffee."]}$j$::jsonb,$j${"value": "Ich trinke lieber Tee als Kaffee."}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$comparativo_irregular$p$, $p$reading$p$]),
('4330f765-4813-58de-8f1f-cc5d6fcb33f0'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','writing','cloze',$p$Completa con el comparativo de «gut».$p$,$j${"text": "Die Pizza hier ist ___ als die Pasta."}$j$::jsonb,$j${"value": "besser", "accepted": ["besser"]}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$comparativo_irregular$p$, $p$writing$p$]),
('7dfb1930-9899-5705-a114-387efbd058a3'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','writing','translation',$p$Traduce: El té es más barato que el café.$p$,$j${"source": "El té es más barato que el café."}$j$::jsonb,$j${"value": "Der Tee ist billiger als der Kaffee.", "accepted": ["Der Tee ist billiger als der Kaffee.", "Der Tee ist billiger als der Kaffee", "Tee ist billiger als Kaffee.", "Tee ist billiger als Kaffee"]}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$comparativo_irregular$p$, $p$writing$p$]),
('53c04705-cdef-551b-bb81-084d5a0194cc'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','writing','word_bank',$p$Forma la frase: «Este queso es el que mejor sabe.»$p$,$j${"tiles": ["schmeckt", "am", "Dieser", "als", "besten", "Käse"]}$j$::jsonb,$j${"value": "Dieser Käse schmeckt am besten", "sequence": ["Dieser", "Käse", "schmeckt", "am", "besten"]}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$comparativo_irregular$p$, $p$writing$p$]),
('8d3f69d0-733d-5957-9733-08f38fcb512e'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ich esse lieber Fisch als Fleisch.", "Ich esse mehr Fisch als Fleisch.", "Ich esse heute kein Fleisch."], "say": "Ich esse lieber Fisch als Fleisch.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/8d3f69d0-733d-5957-9733-08f38fcb512e.mp3"}$j$::jsonb,$j${"value": "Ich esse lieber Fisch als Fleisch."}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$comparativo_irregular$p$, $p$listening$p$]),
('4787c2de-3dee-52f9-9b31-c12b65ab7f71'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','reading','match',$p$Une cada expresión con su significado.$p$,$j${"pairs": [{"en": "ein Kilo", "es": "un kilo"}, {"en": "eine Flasche", "es": "una botella"}, {"en": "ein bisschen", "es": "un poco"}]}$j$::jsonb,$j${"pairs": [["ein Kilo", "un kilo"], ["eine Flasche", "una botella"], ["ein bisschen", "un poco"]]}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$cantidades$p$, $p$reading$p$]),
('e54b56af-5389-5fe4-82d8-72a6901ab64f'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','writing','reorder',$p$Ordena las palabras para formar una frase correcta.$p$,$j${"tiles": ["Kilo", "gern", "Ich", "Tomaten", "hätte", "ein"]}$j$::jsonb,$j${"value": "Ich hätte gern ein Kilo Tomaten"}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$cantidades$p$, $p$writing$p$]),
('fce0bd5e-5d90-53c6-973e-991bfc0dc4b5'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Eine Flasche Wasser, bitte.", "Eine Tasse Kaffee, bitte.", "Ein Kilo Äpfel, bitte."], "say": "Eine Flasche Wasser, bitte.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/fce0bd5e-5d90-53c6-973e-991bfc0dc4b5.mp3"}$j$::jsonb,$j${"value": "Eine Flasche Wasser, bitte."}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$cantidades$p$, $p$listening$p$]),
('f59fae40-f30b-5454-bc51-021b4c7fe9b0'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Ich möchte bitte bezahlen.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/f59fae40-f30b-5454-bc51-021b4c7fe9b0.mp3"}$j$::jsonb,$j${"expected": "Ich möchte bitte bezahlen."}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$cantidades$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('cdde07a7-5aea-5662-92f2-208154ed8857','8bd7cbf4-7e27-5d50-9d2f-34d3964952d7',1),
 ('cdde07a7-5aea-5662-92f2-208154ed8857','cf43b735-a644-5c10-9b35-b35d6c7f2e1d',2),
 ('cdde07a7-5aea-5662-92f2-208154ed8857','83312d90-a445-5a00-8fb8-0ed99b4a2bec',3),
 ('cdde07a7-5aea-5662-92f2-208154ed8857','a1fb446d-303a-571a-93bd-0a5fe376c68d',4),
 ('cdde07a7-5aea-5662-92f2-208154ed8857','a6a332b6-6c04-5780-a174-674f14539bea',5),
 ('3d8f25bd-4197-546b-a162-1e40955cb744','cb8d0ff4-82c9-5f5d-a26f-b7fb4abf35b0',1),
 ('3d8f25bd-4197-546b-a162-1e40955cb744','058bc3ea-19d1-52e7-974d-f30723e5c6b7',2),
 ('3d8f25bd-4197-546b-a162-1e40955cb744','3f562895-2360-512d-8c11-cc245368043c',3),
 ('3d8f25bd-4197-546b-a162-1e40955cb744','fe8a9ae8-4b77-561a-b11b-1ee6d4d91c44',4),
 ('3d8f25bd-4197-546b-a162-1e40955cb744','4fb70c90-fb3a-5de4-aba6-6c38241519cd',5),
 ('05eaa6ed-eea2-551e-8efb-091c981d290a','8357dfd5-7f7a-53a9-b600-c758882fa03d',1),
 ('05eaa6ed-eea2-551e-8efb-091c981d290a','4330f765-4813-58de-8f1f-cc5d6fcb33f0',2),
 ('05eaa6ed-eea2-551e-8efb-091c981d290a','7dfb1930-9899-5705-a114-387efbd058a3',3),
 ('05eaa6ed-eea2-551e-8efb-091c981d290a','53c04705-cdef-551b-bb81-084d5a0194cc',4),
 ('05eaa6ed-eea2-551e-8efb-091c981d290a','8d3f69d0-733d-5957-9733-08f38fcb512e',5),
 ('cf7670d5-156b-5c80-ba6a-ab7cc9d26fb6','4787c2de-3dee-52f9-9b31-c12b65ab7f71',1),
 ('cf7670d5-156b-5c80-ba6a-ab7cc9d26fb6','e54b56af-5389-5fe4-82d8-72a6901ab64f',2),
 ('cf7670d5-156b-5c80-ba6a-ab7cc9d26fb6','fce0bd5e-5d90-53c6-973e-991bfc0dc4b5',3),
 ('cf7670d5-156b-5c80-ba6a-ab7cc9d26fb6','f59fae40-f30b-5454-bc51-021b4c7fe9b0',4),
 ('57315eed-d7a2-522a-8e7f-4c76ce544b88','8bd7cbf4-7e27-5d50-9d2f-34d3964952d7',1),
 ('57315eed-d7a2-522a-8e7f-4c76ce544b88','cf43b735-a644-5c10-9b35-b35d6c7f2e1d',2),
 ('57315eed-d7a2-522a-8e7f-4c76ce544b88','cb8d0ff4-82c9-5f5d-a26f-b7fb4abf35b0',3),
 ('57315eed-d7a2-522a-8e7f-4c76ce544b88','83312d90-a445-5a00-8fb8-0ed99b4a2bec',4),
 ('57315eed-d7a2-522a-8e7f-4c76ce544b88','058bc3ea-19d1-52e7-974d-f30723e5c6b7',5),
 ('57315eed-d7a2-522a-8e7f-4c76ce544b88','4330f765-4813-58de-8f1f-cc5d6fcb33f0',6),
 ('57315eed-d7a2-522a-8e7f-4c76ce544b88','a1fb446d-303a-571a-93bd-0a5fe376c68d',7),
 ('57315eed-d7a2-522a-8e7f-4c76ce544b88','fe8a9ae8-4b77-561a-b11b-1ee6d4d91c44',8),
 ('57315eed-d7a2-522a-8e7f-4c76ce544b88','a6a332b6-6c04-5780-a174-674f14539bea',9),
 ('57315eed-d7a2-522a-8e7f-4c76ce544b88','4fb70c90-fb3a-5de4-aba6-6c38241519cd',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('01c7fdc8-a34a-55f9-8039-0d5426452dad','20000000-0000-0000-0000-000000000005',$p$die Speisekarte$p$,$p$la carta (del restaurante)$p$,301,'sustantivo'),
 ('c0451738-470d-5ef4-ab97-3445a6693f8a','20000000-0000-0000-0000-000000000005',$p$die Rechnung$p$,$p$la cuenta$p$,302,'sustantivo'),
 ('8cbfd4ea-e555-5c0c-be59-b6361ed0e0ec','20000000-0000-0000-0000-000000000005',$p$bestellen$p$,$p$pedir (comida)$p$,303,'verbo'),
 ('20bbd9b9-93bd-58a4-867f-a8e460ce1ab2','20000000-0000-0000-0000-000000000005',$p$bezahlen$p$,$p$pagar$p$,304,'verbo'),
 ('9d64a5bb-2969-56f4-aeb9-6c2429e72a3e','20000000-0000-0000-0000-000000000005',$p$schmecken$p$,$p$saber (tener sabor)$p$,305,'verbo'),
 ('108df424-a8fc-5372-a05e-f7125a9f4be5','20000000-0000-0000-0000-000000000005',$p$kosten$p$,$p$costar$p$,306,'verbo'),
 ('5440d51f-c9e8-5cbb-9d21-04f243d26e79','20000000-0000-0000-0000-000000000005',$p$billig$p$,$p$barato$p$,307,'adjetivo'),
 ('2513a1a2-dfea-5a73-afd9-a2833beefc2d','20000000-0000-0000-0000-000000000005',$p$teuer$p$,$p$caro$p$,308,'adjetivo'),
 ('d56005f0-f686-550e-a0ab-d19e586f6fc6','20000000-0000-0000-0000-000000000005',$p$besser$p$,$p$mejor$p$,309,'adjetivo'),
 ('d5bf2255-9cd3-5616-84c8-95dacfdb1799','20000000-0000-0000-0000-000000000005',$p$lieber$p$,$p$con preferencia$p$,310,'adverbio'),
 ('18a7c785-8110-5269-b7da-a00dbe4f5781','20000000-0000-0000-0000-000000000005',$p$mehr$p$,$p$más$p$,311,'adverbio'),
 ('ada464c3-1b07-5d35-b59e-f1e36d1c517c','20000000-0000-0000-0000-000000000005',$p$am besten$p$,$p$lo mejor (superlativo)$p$,312,'expresion'),
 ('777ca35b-ecc5-55bc-9f26-1ec352c80521','20000000-0000-0000-0000-000000000005',$p$billiger als$p$,$p$más barato que$p$,313,'expresion'),
 ('62e61c79-7474-5237-a204-4106218ce2c6','20000000-0000-0000-0000-000000000005',$p$ein Kilo$p$,$p$un kilo$p$,314,'expresion'),
 ('1edea66e-ea71-54b8-b170-a3d0a44781ca','20000000-0000-0000-0000-000000000005',$p$eine Flasche$p$,$p$una botella$p$,315,'expresion'),
 ('e07c5074-e85f-5c70-83d1-26937697ebf0','20000000-0000-0000-0000-000000000005',$p$ein bisschen$p$,$p$un poco$p$,316,'expresion'),
 ('b5fb056d-d7cd-5572-b6b3-c77a91d431ee','20000000-0000-0000-0000-000000000005',$p$Ich hätte gern ...$p$,$p$quisiera ...$p$,317,'expresion')
on conflict (id) do nothing;

-- ── Unidad 11 (A2·de): Personas y descripciones ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('34ae7f11-2731-5a8a-8341-d7ea2f436c01','20000000-0000-0000-0000-000000000005','A2',11,$p$Personas y descripciones$p$,'#8E44AD','people')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('dc218e0d-bde0-56db-82e0-ea6778795d48','34ae7f11-2731-5a8a-8341-d7ea2f436c01',1,$p$Ayer: war y hatte$p$,$p$Ayer: war y hatte$p$,'lesson',15),
 ('13ea72c5-82f8-51e8-8c21-47f3dda9e4fd','34ae7f11-2731-5a8a-8341-d7ea2f436c01',2,$p$¿Cómo es? El carácter$p$,$p$¿Cómo es? El carácter$p$,'lesson',15),
 ('3a125c51-cd0e-596b-a764-213433203a3a','34ae7f11-2731-5a8a-8341-d7ea2f436c01',3,$p$¿Cómo se ve? El aspecto$p$,$p$¿Cómo se ve? El aspecto$p$,'lesson',15),
 ('59ce59e4-d66e-51e7-aa6b-7f4992b80543','34ae7f11-2731-5a8a-8341-d7ea2f436c01',4,$p$Describir el pasado$p$,$p$Describir el pasado$p$,'lesson',15),
 ('584c42f6-cb5d-58ab-b9aa-c2473f6f1d6c','34ae7f11-2731-5a8a-8341-d7ea2f436c01',5,$p$🏁 Checkpoint Einheit 11$p$,$p$Demuestra que puedes describir el aspecto y el carácter de una persona y hablar del pasado con war y hatte.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('5e0703c8-e638-5d5f-b141-cda683d4a284','20000000-0000-0000-0000-000000000005','checkpoint','A2','34ae7f11-2731-5a8a-8341-d7ea2f436c01',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('d8af9342-ea96-5f5f-9a49-be15b9cefb74'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','reading','match',$p$Une cada forma del pasado con su significado.$p$,$j${"pairs": [{"en": "war", "es": "era / estaba"}, {"en": "hatte", "es": "tenía"}, {"en": "waren", "es": "éramos / estaban"}]}$j$::jsonb,$j${"pairs": [["war", "era / estaba"], ["hatte", "tenía"], ["waren", "éramos / estaban"]]}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$praeteritum_sein_haben$p$, $p$reading$p$]),
('5ca26b73-71e2-57e5-8009-64cfed0a8590'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','reading','multiple_choice',$p$Elige la forma correcta: «Gestern ___ ich sehr müde.»$p$,$j${"options": ["war", "bin", "habe"]}$j$::jsonb,$j${"value": "war"}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$praeteritum_sein_haben$p$, $p$reading$p$]),
('089a0d50-6e4d-5f85-a89f-3440505aa002'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','writing','cloze',$p$Completa con el pasado de «sein».$p$,$j${"text": "Wir ___ gestern zu Hause."}$j$::jsonb,$j${"value": "waren", "accepted": ["waren"]}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$praeteritum_sein_haben$p$, $p$writing$p$]),
('f7d54c8a-d3ae-5013-88c9-a3e4468773c2'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ich war gestern sehr müde.", "Ich hatte gestern viel Arbeit.", "Wir waren gestern zu Hause."], "say": "Ich war gestern sehr müde.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/f7d54c8a-d3ae-5013-88c9-a3e4468773c2.mp3"}$j$::jsonb,$j${"value": "Ich war gestern sehr müde."}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$praeteritum_sein_haben$p$, $p$listening$p$]),
('2685ce2e-2580-563c-b8ec-dddc5b5328a4'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Ich war gestern müde.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/2685ce2e-2580-563c-b8ec-dddc5b5328a4.mp3"}$j$::jsonb,$j${"expected": "Ich war gestern müde."}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$praeteritum_sein_haben$p$, $p$speaking$p$]),
('5eb84939-6f1d-564a-a8a2-a55d12d040fd'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','reading','match',$p$Une cada adjetivo de carácter con su traducción.$p$,$j${"pairs": [{"en": "lustig", "es": "divertido"}, {"en": "ernst", "es": "serio"}, {"en": "freundlich", "es": "simpático"}]}$j$::jsonb,$j${"pairs": [["lustig", "divertido"], ["ernst", "serio"], ["freundlich", "simpático"]]}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$caracter$p$, $p$reading$p$]),
('5625d2fc-92a7-5d69-950e-07549d4bf325'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','reading','multiple_choice',$p$¿Cómo preguntas por el CARÁCTER de una persona?$p$,$j${"options": ["Wie ist sie?", "Wie sieht sie aus?", "Woher kommt sie?"]}$j$::jsonb,$j${"value": "Wie ist sie?"}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$caracter$p$, $p$reading$p$]),
('71d8984a-246e-5ecf-ada6-4bc919b69486'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','writing','translation',$p$Traduce: Mi hermano es muy divertido.$p$,$j${"source": "Mi hermano es muy divertido."}$j$::jsonb,$j${"value": "Mein Bruder ist sehr lustig.", "accepted": ["Mein Bruder ist sehr lustig.", "Mein Bruder ist sehr lustig", "Mein Bruder ist sehr witzig.", "Mein Bruder ist sehr witzig"]}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$caracter$p$, $p$writing$p$]),
('289612e7-80a2-5ea1-9d01-4869909d2315'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Meine Lehrerin ist sehr nett.", "Meine Lehrerin ist sehr ernst.", "Mein Lehrer war sehr nett."], "say": "Meine Lehrerin ist sehr nett.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/289612e7-80a2-5ea1-9d01-4869909d2315.mp3"}$j$::jsonb,$j${"value": "Meine Lehrerin ist sehr nett."}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$caracter$p$, $p$listening$p$]),
('6b76edf3-19c6-5992-b9dc-009564a590b6'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Meine Freundin ist freundlich und lustig.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/6b76edf3-19c6-5992-b9dc-009564a590b6.mp3"}$j$::jsonb,$j${"expected": "Meine Freundin ist freundlich und lustig."}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$caracter$p$, $p$speaking$p$]),
('29b8d37b-fd31-5651-8cc4-13d9138a61bf'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','reading','multiple_choice',$p$«Wie sieht er aus?» — Elige la respuesta correcta.$p$,$j${"options": ["Er ist groß und hat kurze Haare.", "Er ist nett und freundlich.", "Er kommt aus Spanien."]}$j$::jsonb,$j${"value": "Er ist groß und hat kurze Haare."}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$aspecto_fisico$p$, $p$reading$p$]),
('face37e1-ef2c-5e4f-a473-fde8ea0ea8c0'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','reading','multiple_choice',$p$Elige la frase correcta.$p$,$j${"options": ["Er hat kurze blonde Haare.", "Er habt kurze blonde Haare.", "Er hat kurze blonde Haare ist."]}$j$::jsonb,$j${"value": "Er hat kurze blonde Haare."}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$aspecto_fisico$p$, $p$reading$p$]),
('3861e5fa-a217-5dab-838b-81f76daca823'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','writing','cloze',$p$Completa con la palabra alemana para «pelo».$p$,$j${"text": "Meine Schwester hat lange ___."}$j$::jsonb,$j${"value": "Haare", "accepted": ["Haare"]}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$aspecto_fisico$p$, $p$writing$p$]),
('21d51a25-0d5b-55a1-815e-c995e4ee219a'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Er hat kurze braune Haare.", "Er hat lange blonde Haare.", "Sie hat grüne Augen."], "say": "Er hat kurze braune Haare.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/21d51a25-0d5b-55a1-815e-c995e4ee219a.mp3"}$j$::jsonb,$j${"value": "Er hat kurze braune Haare."}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$aspecto_fisico$p$, $p$listening$p$]),
('1ab06fee-4a25-5550-9b40-ed8ec85735c3'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','writing','word_bank',$p$Forma la frase: «Ella tiene los ojos azules.»$p$,$j${"tiles": ["Sie", "hat", "blaue", "Augen", "ist"]}$j$::jsonb,$j${"value": "Sie hat blaue Augen", "sequence": ["Sie", "hat", "blaue", "Augen"]}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$aspecto_fisico$p$, $p$writing$p$]),
('4c624d8b-6ec4-5afb-850c-176ec3ad98d8'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','writing','translation',$p$Traduce: Ella tenía el pelo largo.$p$,$j${"source": "Ella tenía el pelo largo."}$j$::jsonb,$j${"value": "Sie hatte lange Haare.", "accepted": ["Sie hatte lange Haare.", "Sie hatte lange Haare", "Sie hatte langes Haar.", "Sie hatte langes Haar"]}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$descripcion_pasado$p$, $p$writing$p$]),
('eb39e2cd-4e06-52a6-8365-b3639a28a4a6'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','writing','reorder',$p$Ordena las palabras: «Ayer estábamos en casa.»$p$,$j${"tiles": ["gestern", "waren", "Wir", "Hause", "zu"]}$j$::jsonb,$j${"value": "Wir waren gestern zu Hause"}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$descripcion_pasado$p$, $p$writing$p$]),
('e0989ff1-7db4-5085-9837-2782ad3ed620'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Sie hatte lange blonde Haare.", "Sie hat kurze blonde Haare.", "Sie hatte kurze braune Haare."], "say": "Sie hatte lange blonde Haare.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/e0989ff1-7db4-5085-9837-2782ad3ed620.mp3"}$j$::jsonb,$j${"value": "Sie hatte lange blonde Haare."}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$descripcion_pasado$p$, $p$listening$p$]),
('78462c6b-cc0a-5733-8c81-558201b98648'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Wir waren gestern zu Hause.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/78462c6b-cc0a-5733-8c81-558201b98648.mp3"}$j$::jsonb,$j${"expected": "Wir waren gestern zu Hause."}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$descripcion_pasado$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('dc218e0d-bde0-56db-82e0-ea6778795d48','d8af9342-ea96-5f5f-9a49-be15b9cefb74',1),
 ('dc218e0d-bde0-56db-82e0-ea6778795d48','5ca26b73-71e2-57e5-8009-64cfed0a8590',2),
 ('dc218e0d-bde0-56db-82e0-ea6778795d48','089a0d50-6e4d-5f85-a89f-3440505aa002',3),
 ('dc218e0d-bde0-56db-82e0-ea6778795d48','f7d54c8a-d3ae-5013-88c9-a3e4468773c2',4),
 ('dc218e0d-bde0-56db-82e0-ea6778795d48','2685ce2e-2580-563c-b8ec-dddc5b5328a4',5),
 ('13ea72c5-82f8-51e8-8c21-47f3dda9e4fd','5eb84939-6f1d-564a-a8a2-a55d12d040fd',1),
 ('13ea72c5-82f8-51e8-8c21-47f3dda9e4fd','5625d2fc-92a7-5d69-950e-07549d4bf325',2),
 ('13ea72c5-82f8-51e8-8c21-47f3dda9e4fd','71d8984a-246e-5ecf-ada6-4bc919b69486',3),
 ('13ea72c5-82f8-51e8-8c21-47f3dda9e4fd','289612e7-80a2-5ea1-9d01-4869909d2315',4),
 ('13ea72c5-82f8-51e8-8c21-47f3dda9e4fd','6b76edf3-19c6-5992-b9dc-009564a590b6',5),
 ('3a125c51-cd0e-596b-a764-213433203a3a','29b8d37b-fd31-5651-8cc4-13d9138a61bf',1),
 ('3a125c51-cd0e-596b-a764-213433203a3a','face37e1-ef2c-5e4f-a473-fde8ea0ea8c0',2),
 ('3a125c51-cd0e-596b-a764-213433203a3a','3861e5fa-a217-5dab-838b-81f76daca823',3),
 ('3a125c51-cd0e-596b-a764-213433203a3a','21d51a25-0d5b-55a1-815e-c995e4ee219a',4),
 ('3a125c51-cd0e-596b-a764-213433203a3a','1ab06fee-4a25-5550-9b40-ed8ec85735c3',5),
 ('59ce59e4-d66e-51e7-aa6b-7f4992b80543','4c624d8b-6ec4-5afb-850c-176ec3ad98d8',1),
 ('59ce59e4-d66e-51e7-aa6b-7f4992b80543','eb39e2cd-4e06-52a6-8365-b3639a28a4a6',2),
 ('59ce59e4-d66e-51e7-aa6b-7f4992b80543','e0989ff1-7db4-5085-9837-2782ad3ed620',3),
 ('59ce59e4-d66e-51e7-aa6b-7f4992b80543','78462c6b-cc0a-5733-8c81-558201b98648',4),
 ('584c42f6-cb5d-58ab-b9aa-c2473f6f1d6c','d8af9342-ea96-5f5f-9a49-be15b9cefb74',1),
 ('584c42f6-cb5d-58ab-b9aa-c2473f6f1d6c','5ca26b73-71e2-57e5-8009-64cfed0a8590',2),
 ('584c42f6-cb5d-58ab-b9aa-c2473f6f1d6c','5eb84939-6f1d-564a-a8a2-a55d12d040fd',3),
 ('584c42f6-cb5d-58ab-b9aa-c2473f6f1d6c','089a0d50-6e4d-5f85-a89f-3440505aa002',4),
 ('584c42f6-cb5d-58ab-b9aa-c2473f6f1d6c','71d8984a-246e-5ecf-ada6-4bc919b69486',5),
 ('584c42f6-cb5d-58ab-b9aa-c2473f6f1d6c','3861e5fa-a217-5dab-838b-81f76daca823',6),
 ('584c42f6-cb5d-58ab-b9aa-c2473f6f1d6c','f7d54c8a-d3ae-5013-88c9-a3e4468773c2',7),
 ('584c42f6-cb5d-58ab-b9aa-c2473f6f1d6c','289612e7-80a2-5ea1-9d01-4869909d2315',8),
 ('584c42f6-cb5d-58ab-b9aa-c2473f6f1d6c','2685ce2e-2580-563c-b8ec-dddc5b5328a4',9),
 ('584c42f6-cb5d-58ab-b9aa-c2473f6f1d6c','6b76edf3-19c6-5992-b9dc-009564a590b6',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('cf5c0de6-9c62-52b7-a125-5bcb43708c26','20000000-0000-0000-0000-000000000005',$p$war$p$,$p$era / estaba$p$,321,'verbo'),
 ('a214524d-0a8a-5d53-9389-f7c5c4472b39','20000000-0000-0000-0000-000000000005',$p$waren$p$,$p$éramos / estaban$p$,322,'verbo'),
 ('dc34424c-f6d6-5417-8ead-3ec67c0f9e2e','20000000-0000-0000-0000-000000000005',$p$hatte$p$,$p$tenía$p$,323,'verbo'),
 ('5a04597c-e6f7-532e-bd49-f1706f072cb5','20000000-0000-0000-0000-000000000005',$p$hatten$p$,$p$teníamos / tenían$p$,324,'verbo'),
 ('0a81b93c-a1c0-54f3-9d43-914337f80d56','20000000-0000-0000-0000-000000000005',$p$groß$p$,$p$alto / grande$p$,325,'adjetivo'),
 ('8048a5c0-862a-589d-9a44-9ad249d8dc66','20000000-0000-0000-0000-000000000005',$p$klein$p$,$p$bajo / pequeño$p$,326,'adjetivo'),
 ('67a0e193-00e1-5d38-b289-3c899d7c96a0','20000000-0000-0000-0000-000000000005',$p$nett$p$,$p$amable$p$,327,'adjetivo'),
 ('b7bc9944-60df-54eb-b953-7fcbcfbadb56','20000000-0000-0000-0000-000000000005',$p$freundlich$p$,$p$simpático$p$,328,'adjetivo'),
 ('265f71a6-5b10-551a-a19c-9fe10790253c','20000000-0000-0000-0000-000000000005',$p$lustig$p$,$p$divertido$p$,329,'adjetivo'),
 ('e73bef8f-3314-5f8d-8672-0908f51d29a9','20000000-0000-0000-0000-000000000005',$p$ernst$p$,$p$serio$p$,330,'adjetivo'),
 ('bbf410ba-9ef4-5355-aa0d-9001336a9cc1','20000000-0000-0000-0000-000000000005',$p$die Haare$p$,$p$el pelo$p$,331,'sustantivo'),
 ('9a9458dd-b4d5-5026-bdf4-3a11854b37bd','20000000-0000-0000-0000-000000000005',$p$die Augen$p$,$p$los ojos$p$,332,'sustantivo'),
 ('f1496d83-46f4-5de6-9b6d-284f2e130377','20000000-0000-0000-0000-000000000005',$p$blond$p$,$p$rubio$p$,333,'adjetivo'),
 ('4b59383e-0b3d-56ab-be97-0601270c07c0','20000000-0000-0000-0000-000000000005',$p$braun$p$,$p$castaño / marrón$p$,334,'adjetivo'),
 ('d7de330d-6127-56ed-98ea-05418e21f7e6','20000000-0000-0000-0000-000000000005',$p$lang$p$,$p$largo$p$,335,'adjetivo'),
 ('b0bd1540-a344-517f-a53c-a551b914199d','20000000-0000-0000-0000-000000000005',$p$kurz$p$,$p$corto$p$,336,'adjetivo')
on conflict (id) do nothing;

-- ── Unidad 12 (A2·de): Salud, cuerpo y consejos ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('77463cb0-e0cb-581c-94ed-9abf685d18ea','20000000-0000-0000-0000-000000000005','A2',12,$p$Salud, cuerpo y consejos$p$,'#D35400','healing')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('94bd6793-8fcf-55b7-a001-25f04aee5e14','77463cb0-e0cb-581c-94ed-9abf685d18ea',1,$p$El cuerpo$p$,$p$El cuerpo$p$,'lesson',15),
 ('e42a8711-c1fa-5812-a498-4bd2e6513e29','77463cb0-e0cb-581c-94ed-9abf685d18ea',2,$p$Me duele: wehtun$p$,$p$Me duele: wehtun$p$,'lesson',15),
 ('ce30344d-af82-5d66-aee2-493eeb775b5e','77463cb0-e0cb-581c-94ed-9abf685d18ea',3,$p$En el médico$p$,$p$En el médico$p$,'lesson',15),
 ('f9cae3e4-402d-5f21-9c1b-5b892ffbfd7b','77463cb0-e0cb-581c-94ed-9abf685d18ea',4,$p$Consejos: solltest y muss$p$,$p$Consejos: solltest y muss$p$,'lesson',15),
 ('81beec8d-8c2b-5f93-a0d9-7073ee9400e9','77463cb0-e0cb-581c-94ed-9abf685d18ea',5,$p$🏁 Checkpoint Einheit 12$p$,$p$Demuestra que puedes nombrar las partes del cuerpo, decir qué te duele y dar consejos con solltest y muss.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('51a9c7c0-66cf-5dcd-a52f-4cec08c01179','20000000-0000-0000-0000-000000000005','checkpoint','A2','77463cb0-e0cb-581c-94ed-9abf685d18ea',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('88b38693-652e-5b7d-a490-028946570079'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','reading','match',$p$Une cada parte del cuerpo con su traducción.$p$,$j${"pairs": [{"en": "der Kopf", "es": "la cabeza"}, {"en": "der Bauch", "es": "la barriga"}, {"en": "das Bein", "es": "la pierna"}]}$j$::jsonb,$j${"pairs": [["der Kopf", "la cabeza"], ["der Bauch", "la barriga"], ["das Bein", "la pierna"]]}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$el_cuerpo$p$, $p$reading$p$]),
('3afc731e-9631-5896-a111-d2555b793230'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','reading','match',$p$Une cada parte del cuerpo con su traducción.$p$,$j${"pairs": [{"en": "die Hand", "es": "la mano"}, {"en": "der Fuß", "es": "el pie"}, {"en": "die Zähne", "es": "los dientes"}]}$j$::jsonb,$j${"pairs": [["die Hand", "la mano"], ["der Fuß", "el pie"], ["die Zähne", "los dientes"]]}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$el_cuerpo$p$, $p$reading$p$]),
('8a34dc2a-3dd0-502c-95d8-47c962f4fbd0'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','reading','multiple_choice',$p$Elige la palabra correcta para «la espalda».$p$,$j${"options": ["der Rücken", "die Rücken", "das Rücken"]}$j$::jsonb,$j${"value": "der Rücken"}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$el_cuerpo$p$, $p$reading$p$]),
('977f758a-cff4-57ea-97f2-465c17820ef1'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Das sind meine Zähne.", "Das ist meine Hand.", "Das sind meine Füße."], "say": "Das sind meine Zähne.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/977f758a-cff4-57ea-97f2-465c17820ef1.mp3"}$j$::jsonb,$j${"value": "Das sind meine Zähne."}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$el_cuerpo$p$, $p$listening$p$]),
('0c5fe8e0-1a81-55dc-aa71-df34b262d553'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Meine Hände und meine Füße sind kalt.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/0c5fe8e0-1a81-55dc-aa71-df34b262d553.mp3"}$j$::jsonb,$j${"expected": "Meine Hände und meine Füße sind kalt."}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$el_cuerpo$p$, $p$speaking$p$]),
('a30bb729-f666-5d5a-aef9-ff3b34c766cd'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','reading','multiple_choice',$p$Elige la forma correcta: «Mir ___ die Zähne weh.»$p$,$j${"options": ["tun", "tut", "tust"]}$j$::jsonb,$j${"value": "tun"}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$dolor_wehtun$p$, $p$reading$p$]),
('c05b3c20-4b58-5b6a-89c4-d9dc26e13b42'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','writing','cloze',$p$Completa con la forma correcta de «wehtun».$p$,$j${"text": "Mir ___ der Kopf weh."}$j$::jsonb,$j${"value": "tut", "accepted": ["tut"]}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$dolor_wehtun$p$, $p$writing$p$]),
('d7331034-678b-5161-8e87-81fe62c8bd65'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','writing','translation',$p$Traduce: Me duelen los pies.$p$,$j${"source": "Me duelen los pies."}$j$::jsonb,$j${"value": "Mir tun die Füße weh.", "accepted": ["Mir tun die Füße weh.", "Mir tun die Füße weh", "Mir tun die Füsse weh.", "Mir tun die Füsse weh", "Mir tun die Fuesse weh.", "Mir tun die Fuesse weh", "Die Füße tun mir weh.", "Die Füße tun mir weh", "Die Füsse tun mir weh.", "Die Füsse tun mir weh", "Die Fuesse tun mir weh.", "Die Fuesse tun mir weh"]}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$dolor_wehtun$p$, $p$writing$p$]),
('d21ac930-ee55-5b72-bd5d-cd450142321a'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','writing','word_bank',$p$Forma la frase (empieza con «Mir»): «Me duele la barriga.»$p$,$j${"tiles": ["Mir", "tut", "der", "Bauch", "weh", "tun"]}$j$::jsonb,$j${"value": "Mir tut der Bauch weh", "sequence": ["Mir", "tut", "der", "Bauch", "weh"]}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$dolor_wehtun$p$, $p$writing$p$]),
('5db5b7e6-b549-5537-81f0-799d0764b477'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Mir tut der Hals weh.", "Mir tut der Kopf weh.", "Mir tun die Füße weh."], "say": "Mir tut der Hals weh.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/5db5b7e6-b549-5537-81f0-799d0764b477.mp3"}$j$::jsonb,$j${"value": "Mir tut der Hals weh."}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$dolor_wehtun$p$, $p$listening$p$]),
('6e987c77-0afa-55ce-bd37-74cc757db3be'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','reading','multiple_choice',$p$El médico pregunta: «Was fehlt Ihnen?» ¿Qué significa?$p$,$j${"options": ["¿Qué le pasa?", "¿Cómo se llama usted?", "¿Cuántos años tiene usted?"]}$j$::jsonb,$j${"value": "¿Qué le pasa?"}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$beim_arzt$p$, $p$reading$p$]),
('0596eb99-a402-5742-867a-3f15e6ff7ffb'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','writing','cloze',$p$Completa con la palabra alemana para «fiebre».$p$,$j${"text": "Ich bin krank und habe ___."}$j$::jsonb,$j${"value": "Fieber", "accepted": ["Fieber"]}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$beim_arzt$p$, $p$writing$p$]),
('04a6fcee-08a6-5100-b878-b3f310b9ecca'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ich bin krank und habe Fieber.", "Ich bin müde und habe Hunger.", "Ich war krank und hatte Fieber."], "say": "Ich bin krank und habe Fieber.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/04a6fcee-08a6-5100-b878-b3f310b9ecca.mp3"}$j$::jsonb,$j${"value": "Ich bin krank und habe Fieber."}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$beim_arzt$p$, $p$listening$p$]),
('6a8d460e-733f-5637-ba7b-8ef33f7e65ca'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Ich bin krank und habe Fieber.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/6a8d460e-733f-5637-ba7b-8ef33f7e65ca.mp3"}$j$::jsonb,$j${"expected": "Ich bin krank und habe Fieber."}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$beim_arzt$p$, $p$speaking$p$]),
('5ebb9ce5-ff5c-50cb-b7b6-fa1e851e05c9'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','reading','multiple_choice',$p$Tu amigo dice: «Ich bin sehr müde.» Elige el consejo correcto.$p$,$j${"options": ["Du solltest schlafen.", "Du solltest geschlafen.", "Du schlafen solltest."]}$j$::jsonb,$j${"value": "Du solltest schlafen."}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$consejos_sollen$p$, $p$reading$p$]),
('40e23241-d1bb-591d-a475-c808d0f4abcc'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','writing','translation',$p$Traduce: Debo quedarme en casa.$p$,$j${"source": "Debo quedarme en casa."}$j$::jsonb,$j${"value": "Ich muss zu Hause bleiben.", "accepted": ["Ich muss zu Hause bleiben.", "Ich muss zu Hause bleiben", "Ich muss zuhause bleiben.", "Ich muss zuhause bleiben"]}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$consejos_sollen$p$, $p$writing$p$]),
('cc410fc9-0f63-5056-b30a-a044ba67767c'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','writing','reorder',$p$Ordena las palabras: «Deberías ir al médico.»$p$,$j${"tiles": ["zum", "solltest", "Du", "gehen", "Arzt"]}$j$::jsonb,$j${"value": "Du solltest zum Arzt gehen"}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$consejos_sollen$p$, $p$writing$p$]),
('dd641c61-6cd5-55e3-8d7e-d3119a0ec173'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Du solltest mehr Wasser trinken.", "Du solltest mehr Kaffee trinken.", "Du musst mehr Wasser trinken."], "say": "Du solltest mehr Wasser trinken.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/dd641c61-6cd5-55e3-8d7e-d3119a0ec173.mp3"}$j$::jsonb,$j${"value": "Du solltest mehr Wasser trinken."}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$consejos_sollen$p$, $p$listening$p$]),
('a03389ca-83b6-5939-92fa-43a1458ea652'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Ich muss heute zum Arzt gehen.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/a03389ca-83b6-5939-92fa-43a1458ea652.mp3"}$j$::jsonb,$j${"expected": "Ich muss heute zum Arzt gehen."}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$consejos_sollen$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('94bd6793-8fcf-55b7-a001-25f04aee5e14','88b38693-652e-5b7d-a490-028946570079',1),
 ('94bd6793-8fcf-55b7-a001-25f04aee5e14','3afc731e-9631-5896-a111-d2555b793230',2),
 ('94bd6793-8fcf-55b7-a001-25f04aee5e14','8a34dc2a-3dd0-502c-95d8-47c962f4fbd0',3),
 ('94bd6793-8fcf-55b7-a001-25f04aee5e14','977f758a-cff4-57ea-97f2-465c17820ef1',4),
 ('94bd6793-8fcf-55b7-a001-25f04aee5e14','0c5fe8e0-1a81-55dc-aa71-df34b262d553',5),
 ('e42a8711-c1fa-5812-a498-4bd2e6513e29','a30bb729-f666-5d5a-aef9-ff3b34c766cd',1),
 ('e42a8711-c1fa-5812-a498-4bd2e6513e29','c05b3c20-4b58-5b6a-89c4-d9dc26e13b42',2),
 ('e42a8711-c1fa-5812-a498-4bd2e6513e29','d7331034-678b-5161-8e87-81fe62c8bd65',3),
 ('e42a8711-c1fa-5812-a498-4bd2e6513e29','d21ac930-ee55-5b72-bd5d-cd450142321a',4),
 ('e42a8711-c1fa-5812-a498-4bd2e6513e29','5db5b7e6-b549-5537-81f0-799d0764b477',5),
 ('ce30344d-af82-5d66-aee2-493eeb775b5e','6e987c77-0afa-55ce-bd37-74cc757db3be',1),
 ('ce30344d-af82-5d66-aee2-493eeb775b5e','0596eb99-a402-5742-867a-3f15e6ff7ffb',2),
 ('ce30344d-af82-5d66-aee2-493eeb775b5e','04a6fcee-08a6-5100-b878-b3f310b9ecca',3),
 ('ce30344d-af82-5d66-aee2-493eeb775b5e','6a8d460e-733f-5637-ba7b-8ef33f7e65ca',4),
 ('f9cae3e4-402d-5f21-9c1b-5b892ffbfd7b','5ebb9ce5-ff5c-50cb-b7b6-fa1e851e05c9',1),
 ('f9cae3e4-402d-5f21-9c1b-5b892ffbfd7b','40e23241-d1bb-591d-a475-c808d0f4abcc',2),
 ('f9cae3e4-402d-5f21-9c1b-5b892ffbfd7b','cc410fc9-0f63-5056-b30a-a044ba67767c',3),
 ('f9cae3e4-402d-5f21-9c1b-5b892ffbfd7b','dd641c61-6cd5-55e3-8d7e-d3119a0ec173',4),
 ('f9cae3e4-402d-5f21-9c1b-5b892ffbfd7b','a03389ca-83b6-5939-92fa-43a1458ea652',5),
 ('81beec8d-8c2b-5f93-a0d9-7073ee9400e9','88b38693-652e-5b7d-a490-028946570079',1),
 ('81beec8d-8c2b-5f93-a0d9-7073ee9400e9','3afc731e-9631-5896-a111-d2555b793230',2),
 ('81beec8d-8c2b-5f93-a0d9-7073ee9400e9','8a34dc2a-3dd0-502c-95d8-47c962f4fbd0',3),
 ('81beec8d-8c2b-5f93-a0d9-7073ee9400e9','c05b3c20-4b58-5b6a-89c4-d9dc26e13b42',4),
 ('81beec8d-8c2b-5f93-a0d9-7073ee9400e9','d7331034-678b-5161-8e87-81fe62c8bd65',5),
 ('81beec8d-8c2b-5f93-a0d9-7073ee9400e9','d21ac930-ee55-5b72-bd5d-cd450142321a',6),
 ('81beec8d-8c2b-5f93-a0d9-7073ee9400e9','977f758a-cff4-57ea-97f2-465c17820ef1',7),
 ('81beec8d-8c2b-5f93-a0d9-7073ee9400e9','5db5b7e6-b549-5537-81f0-799d0764b477',8),
 ('81beec8d-8c2b-5f93-a0d9-7073ee9400e9','0c5fe8e0-1a81-55dc-aa71-df34b262d553',9),
 ('81beec8d-8c2b-5f93-a0d9-7073ee9400e9','6a8d460e-733f-5637-ba7b-8ef33f7e65ca',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('f9362b7b-ba10-56dd-a64d-c9cb6bb7622c','20000000-0000-0000-0000-000000000005',$p$der Kopf$p$,$p$la cabeza$p$,341,'sustantivo'),
 ('56a2ae38-48ee-5808-9e7f-30d1a856b10f','20000000-0000-0000-0000-000000000005',$p$der Bauch$p$,$p$la barriga$p$,342,'sustantivo'),
 ('8f9376a0-3d33-5fbf-9bd9-dfcbd483ba64','20000000-0000-0000-0000-000000000005',$p$der Rücken$p$,$p$la espalda$p$,343,'sustantivo'),
 ('f843c011-aae6-51ee-8634-bf02d4fe463e','20000000-0000-0000-0000-000000000005',$p$der Hals$p$,$p$la garganta / el cuello$p$,344,'sustantivo'),
 ('0a748e04-3ff2-5b56-9481-ab6234ea4401','20000000-0000-0000-0000-000000000005',$p$das Bein$p$,$p$la pierna$p$,345,'sustantivo'),
 ('2e9d67eb-e0f1-5203-bc2a-5a00b8ea711c','20000000-0000-0000-0000-000000000005',$p$der Arm$p$,$p$el brazo$p$,346,'sustantivo'),
 ('e96613ea-86c2-5855-9e68-bb26597d5606','20000000-0000-0000-0000-000000000005',$p$die Hand$p$,$p$la mano$p$,347,'sustantivo'),
 ('73ddd08b-e569-5693-9131-f38dfa13f301','20000000-0000-0000-0000-000000000005',$p$der Fuß$p$,$p$el pie$p$,348,'sustantivo'),
 ('3c6e7dad-6b76-5734-a3ac-8535e75f74f4','20000000-0000-0000-0000-000000000005',$p$die Zähne$p$,$p$los dientes$p$,349,'sustantivo'),
 ('4ea4af4a-26c2-523b-a2e1-f9860b1b3c3d','20000000-0000-0000-0000-000000000005',$p$wehtun$p$,$p$doler$p$,350,'verbo'),
 ('22908cec-0046-517c-a882-90b058345f1a','20000000-0000-0000-0000-000000000005',$p$krank$p$,$p$enfermo$p$,351,'adjetivo'),
 ('2db64da8-aae6-5f5d-83f4-2db8cdb73db7','20000000-0000-0000-0000-000000000005',$p$das Fieber$p$,$p$la fiebre$p$,352,'sustantivo'),
 ('ee35ddf5-2326-58af-aa07-82b2a7d06093','20000000-0000-0000-0000-000000000005',$p$die Kopfschmerzen$p$,$p$el dolor de cabeza$p$,353,'sustantivo'),
 ('919f2f18-31bc-5ca6-9574-39cd95bac57b','20000000-0000-0000-0000-000000000005',$p$der Arzt$p$,$p$el médico$p$,354,'sustantivo'),
 ('0b9d6045-09a8-5b29-b7c1-97d73f1deba3','20000000-0000-0000-0000-000000000005',$p$du solltest$p$,$p$deberías$p$,355,'expresion'),
 ('534ee3bf-9dff-5b66-829f-1588822814ba','20000000-0000-0000-0000-000000000005',$p$müssen$p$,$p$tener que / deber$p$,356,'verbo')
on conflict (id) do nothing;

commit;