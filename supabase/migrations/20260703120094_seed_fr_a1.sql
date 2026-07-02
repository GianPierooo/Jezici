-- 20260703120094_seed_fr_a1.sql
-- Alta del curso es→fr + currículo A1 (6 unidades). Molde es→pt
-- (mig 047+048). Contenido scopeado a course_id=20000000-0000-0000-0000-000000000003 → aislamiento
-- multicurso por jz_active_course (RPCs ya course-aware). ids uuid5 idempotentes.
begin;
insert into languages (id, code, name) values
  ('10000000-0000-0000-0000-000000000004','fr',$p$Français$p$) on conflict (id) do nothing;
insert into courses (id, source_language_id, target_language_id, is_active) values
  ('20000000-0000-0000-0000-000000000003','10000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000004',true) on conflict (id) do nothing;

-- ── Unidad 1 (A1·fr): Bonjour y enchanté (saludos y presentarte) ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('1c475ac4-3626-5f34-a40c-61488e1bd6b3','20000000-0000-0000-0000-000000000003','A1',1,$p$Bonjour y enchanté (saludos y presentarte)$p$,'#27AE60','waving_hand')
on conflict (course_id, order_index) do update set title=excluded.title, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('510e839b-cf3a-5ba5-95d8-41f09aec0509','1c475ac4-3626-5f34-a40c-61488e1bd6b3',1,$p$Saludos y despedidas$p$,$p$Saludos y despedidas$p$,'lesson',15),
 ('f75684be-0fc5-5de7-a670-df0e6e0775c3','1c475ac4-3626-5f34-a40c-61488e1bd6b3',2,$p$Presentarte: je m'appelle$p$,$p$Presentarte: je m'appelle$p$,'lesson',15),
 ('16db4bd5-72fb-50ff-ae31-0880ee4caa41','1c475ac4-3626-5f34-a40c-61488e1bd6b3',3,$p$Tú o usted + el verbo être$p$,$p$Tú o usted + el verbo être$p$,'lesson',15),
 ('353813c0-538b-59c1-8cf8-090ba0ff3208','1c475ac4-3626-5f34-a40c-61488e1bd6b3',4,$p$¿Qué tal? ça va ?$p$,$p$¿Qué tal? ça va ?$p$,'lesson',15),
 ('8e115952-c454-5ed7-a69a-4bfd228bbc10','1c475ac4-3626-5f34-a40c-61488e1bd6b3',5,$p$🏁 Checkpoint Unité 1$p$,$p$Practica saludar, despedirte, presentarte con «je m'appelle» y usar el verbo être junto a la distinción tú/usted (tu/vous).$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('93bf2b57-31f9-5a5e-af5d-29b195fca228','20000000-0000-0000-0000-000000000003','checkpoint','A1','1c475ac4-3626-5f34-a40c-61488e1bd6b3',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('1b5cefb9-68d8-5eac-a458-45f4dcbb0d22'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','reading','match',$p$Empareja cada saludo con su traducción.$p$,$j${"pairs": [{"en": "bonjour", "es": "buenos días"}, {"en": "salut", "es": "hola (informal)"}, {"en": "au revoir", "es": "adiós"}]}$j$::jsonb,$j${"pairs": [["bonjour", "buenos días"], ["salut", "hola (informal)"], ["au revoir", "adiós"]]}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$saludos_despedidas$p$, $p$reading$p$]),
('4d3470b0-3a1b-50e0-b3f6-7c68c6888cdf'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','reading','multiple_choice',$p$¿Qué dices al despedirte por la noche antes de dormir?$p$,$j${"options": ["bonne nuit", "bonjour", "salut"]}$j$::jsonb,$j${"value": "bonne nuit"}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$saludos_despedidas$p$, $p$reading$p$]),
('d219e621-72a3-5521-b090-cd06b13af4e2'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','reading','multiple_choice',$p$Es de tarde y saludas a un vecino. ¿Qué le dices?$p$,$j${"options": ["bonsoir", "bonne nuit", "à bientôt"]}$j$::jsonb,$j${"value": "bonsoir"}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$saludos_despedidas$p$, $p$reading$p$]),
('a8d6ea80-26b6-5dac-a3d7-815a1399be93'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Au revoir, à bientôt !", "Bonjour, ça va ?", "Bonne nuit, merci."], "say": "Au revoir, à bientôt !", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/a8d6ea80-26b6-5dac-a3d7-815a1399be93.mp3"}$j$::jsonb,$j${"value": "Au revoir, à bientôt !"}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$saludos_despedidas$p$, $p$listening$p$]),
('4706e618-ab01-55eb-ba61-e31ab081ac96'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Bonjour ! Salut ! Au revoir !", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/4706e618-ab01-55eb-ba61-e31ab081ac96.mp3"}$j$::jsonb,$j${"expected": "Bonjour ! Salut ! Au revoir !"}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$saludos_despedidas$p$, $p$speaking$p$]),
('909ff5d3-596a-542f-ab9c-51fb2c45f2ab'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','reading','multiple_choice',$p$¿Cómo dices «me llamo Marie»?$p$,$j${"options": ["Je m'appelle Marie.", "Tu t'appelles Marie.", "Il s'appelle Marie."]}$j$::jsonb,$j${"value": "Je m'appelle Marie."}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$presentarse$p$, $p$reading$p$]),
('911ee707-8a86-5e94-9ac8-70442ec648e5'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','writing','cloze',$p$Completa: «Me llamo Paul».$p$,$j${"text": "Je ___ Paul."}$j$::jsonb,$j${"value": "m'appelle", "accepted": ["m'appelle", "mappelle", "m appelle"]}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$presentarse$p$, $p$writing$p$]),
('79236f7a-ed67-52dc-8b0e-3bc1650eb73c'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','writing','word_bank',$p$Arma la frase: «Me llamo Ana».$p$,$j${"tiles": ["Je", "m'appelle", "Ana", "suis", "tu"]}$j$::jsonb,$j${"value": "Je m'appelle Ana", "sequence": ["Je", "m'appelle", "Ana"]}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$presentarse$p$, $p$writing$p$]),
('c132ce76-c2a9-5504-b9ad-4eb1a374ec89'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Bonjour ! Je m'appelle Marie. Enchantée !", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/c132ce76-c2a9-5504-b9ad-4eb1a374ec89.mp3"}$j$::jsonb,$j${"expected": "Bonjour ! Je m'appelle Marie. Enchantée !"}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$presentarse$p$, $p$speaking$p$]),
('960116d2-d514-5821-90fd-668c817ee3ce'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','reading','match',$p$Empareja cada forma del verbo être con su pronombre.$p$,$j${"pairs": [{"en": "je suis", "es": "yo soy"}, {"en": "tu es", "es": "tú eres"}, {"en": "vous êtes", "es": "usted es"}]}$j$::jsonb,$j${"pairs": [["je suis", "yo soy"], ["tu es", "tú eres"], ["vous êtes", "usted es"]]}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$tu_vous_etre$p$, $p$reading$p$]),
('eed17437-62f2-5a0f-9fbd-d59e2091b6c5'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','reading','multiple_choice',$p$Hablas con tu jefe (usted). ¿Cómo le preguntas su nombre?$p$,$j${"options": ["Comment vous appelez-vous ?", "Comment tu t'appelles ?", "Comment il s'appelle ?"]}$j$::jsonb,$j${"value": "Comment vous appelez-vous ?"}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$tu_vous_etre$p$, $p$reading$p$]),
('d28523a9-bc11-5bad-8e38-1ba789ead6eb'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','writing','cloze',$p$Completa con el verbo être: «Tú eres español».$p$,$j${"text": "Tu ___ espagnol."}$j$::jsonb,$j${"value": "es", "accepted": ["es"]}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$tu_vous_etre$p$, $p$writing$p$]),
('52983912-e719-5130-aa46-cc885fe788ac'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','writing','reorder',$p$Ordena: «¿Cómo te llamas?».$p$,$j${"tiles": ["appelles", "Comment", "tu", "t'"]}$j$::jsonb,$j${"value": "Comment tu t' appelles"}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$tu_vous_etre$p$, $p$writing$p$]),
('53cf99d6-c20c-5ba7-a2bc-aff3bfc5492d'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Je suis enchanté.", "Tu es espagnol.", "Vous êtes Marie."], "say": "Je suis enchanté.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/53cf99d6-c20c-5ba7-a2bc-aff3bfc5492d.mp3"}$j$::jsonb,$j${"value": "Je suis enchanté."}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$tu_vous_etre$p$, $p$listening$p$]),
('3cb025d4-e340-5667-afa7-9106b9f02b19'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','reading','multiple_choice',$p$Un amigo te pregunta «ça va ?». ¿Cómo respondes que estás muy bien?$p$,$j${"options": ["Très bien, merci !", "Au revoir !", "Bonne nuit !"]}$j$::jsonb,$j${"value": "Très bien, merci !"}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$que_tal$p$, $p$reading$p$]),
('62106240-b406-51da-ad6d-3a8f897963e6'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','writing','translation',$p$Traduce: «¿Qué tal? Muy bien, gracias».$p$,$j${"source": "¿Qué tal? Muy bien, gracias."}$j$::jsonb,$j${"value": "Ça va ? Très bien, merci.", "accepted": ["Ça va ? Très bien, merci.", "Ça va ? Très bien, merci", "Ca va ? Tres bien, merci.", "Ca va ? Tres bien merci", "Ça va? Très bien, merci."]}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$que_tal$p$, $p$writing$p$]),
('0b773ccc-49df-5a00-89d6-837db7bad62c'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','writing','translation',$p$Traduce: «¿Y tú?».$p$,$j${"source": "¿Y tú?"}$j$::jsonb,$j${"value": "Et toi ?", "accepted": ["Et toi ?", "Et toi?", "Et toi", "et toi ?"]}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$que_tal$p$, $p$writing$p$]),
('6b111a52-644e-527a-a66e-38794b91baa5'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Comment ça va ?", "Comment vous appelez-vous ?", "Bonsoir, à bientôt."], "say": "Comment ça va ?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/6b111a52-644e-527a-a66e-38794b91baa5.mp3"}$j$::jsonb,$j${"value": "Comment ça va ?"}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$que_tal$p$, $p$listening$p$]),
('74f042dd-895e-5f87-9455-6157a29d8cb7'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Très bien, et toi ?", "Bonjour, enchanté.", "Merci, au revoir."], "say": "Très bien, et toi ?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/74f042dd-895e-5f87-9455-6157a29d8cb7.mp3"}$j$::jsonb,$j${"value": "Très bien, et toi ?"}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$que_tal$p$, $p$listening$p$]),
('a0be936b-3110-503a-825f-cc4882ff8ef1'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Salut ! Ça va ? Très bien, merci. Et toi ?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/a0be936b-3110-503a-825f-cc4882ff8ef1.mp3"}$j$::jsonb,$j${"expected": "Salut ! Ça va ? Très bien, merci. Et toi ?"}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$que_tal$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('510e839b-cf3a-5ba5-95d8-41f09aec0509','1b5cefb9-68d8-5eac-a458-45f4dcbb0d22',1),
 ('510e839b-cf3a-5ba5-95d8-41f09aec0509','4d3470b0-3a1b-50e0-b3f6-7c68c6888cdf',2),
 ('510e839b-cf3a-5ba5-95d8-41f09aec0509','d219e621-72a3-5521-b090-cd06b13af4e2',3),
 ('510e839b-cf3a-5ba5-95d8-41f09aec0509','a8d6ea80-26b6-5dac-a3d7-815a1399be93',4),
 ('510e839b-cf3a-5ba5-95d8-41f09aec0509','4706e618-ab01-55eb-ba61-e31ab081ac96',5),
 ('f75684be-0fc5-5de7-a670-df0e6e0775c3','909ff5d3-596a-542f-ab9c-51fb2c45f2ab',1),
 ('f75684be-0fc5-5de7-a670-df0e6e0775c3','911ee707-8a86-5e94-9ac8-70442ec648e5',2),
 ('f75684be-0fc5-5de7-a670-df0e6e0775c3','79236f7a-ed67-52dc-8b0e-3bc1650eb73c',3),
 ('f75684be-0fc5-5de7-a670-df0e6e0775c3','c132ce76-c2a9-5504-b9ad-4eb1a374ec89',4),
 ('16db4bd5-72fb-50ff-ae31-0880ee4caa41','960116d2-d514-5821-90fd-668c817ee3ce',1),
 ('16db4bd5-72fb-50ff-ae31-0880ee4caa41','eed17437-62f2-5a0f-9fbd-d59e2091b6c5',2),
 ('16db4bd5-72fb-50ff-ae31-0880ee4caa41','d28523a9-bc11-5bad-8e38-1ba789ead6eb',3),
 ('16db4bd5-72fb-50ff-ae31-0880ee4caa41','52983912-e719-5130-aa46-cc885fe788ac',4),
 ('16db4bd5-72fb-50ff-ae31-0880ee4caa41','53cf99d6-c20c-5ba7-a2bc-aff3bfc5492d',5),
 ('353813c0-538b-59c1-8cf8-090ba0ff3208','3cb025d4-e340-5667-afa7-9106b9f02b19',1),
 ('353813c0-538b-59c1-8cf8-090ba0ff3208','62106240-b406-51da-ad6d-3a8f897963e6',2),
 ('353813c0-538b-59c1-8cf8-090ba0ff3208','0b773ccc-49df-5a00-89d6-837db7bad62c',3),
 ('353813c0-538b-59c1-8cf8-090ba0ff3208','6b111a52-644e-527a-a66e-38794b91baa5',4),
 ('353813c0-538b-59c1-8cf8-090ba0ff3208','74f042dd-895e-5f87-9455-6157a29d8cb7',5),
 ('353813c0-538b-59c1-8cf8-090ba0ff3208','a0be936b-3110-503a-825f-cc4882ff8ef1',6),
 ('8e115952-c454-5ed7-a69a-4bfd228bbc10','1b5cefb9-68d8-5eac-a458-45f4dcbb0d22',1),
 ('8e115952-c454-5ed7-a69a-4bfd228bbc10','4d3470b0-3a1b-50e0-b3f6-7c68c6888cdf',2),
 ('8e115952-c454-5ed7-a69a-4bfd228bbc10','d219e621-72a3-5521-b090-cd06b13af4e2',3),
 ('8e115952-c454-5ed7-a69a-4bfd228bbc10','911ee707-8a86-5e94-9ac8-70442ec648e5',4),
 ('8e115952-c454-5ed7-a69a-4bfd228bbc10','79236f7a-ed67-52dc-8b0e-3bc1650eb73c',5),
 ('8e115952-c454-5ed7-a69a-4bfd228bbc10','d28523a9-bc11-5bad-8e38-1ba789ead6eb',6),
 ('8e115952-c454-5ed7-a69a-4bfd228bbc10','a8d6ea80-26b6-5dac-a3d7-815a1399be93',7),
 ('8e115952-c454-5ed7-a69a-4bfd228bbc10','53cf99d6-c20c-5ba7-a2bc-aff3bfc5492d',8),
 ('8e115952-c454-5ed7-a69a-4bfd228bbc10','4706e618-ab01-55eb-ba61-e31ab081ac96',9),
 ('8e115952-c454-5ed7-a69a-4bfd228bbc10','c132ce76-c2a9-5504-b9ad-4eb1a374ec89',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('4c54d8c7-6726-5b8f-8a0b-0abcebfad83b','20000000-0000-0000-0000-000000000003',$p$bonjour$p$,$p$hola/buenos días$p$,121,'interjeccion'),
 ('80582e3e-022a-58a9-a99a-4cbb4dfcf8df','20000000-0000-0000-0000-000000000003',$p$salut$p$,$p$hola/chao (informal)$p$,122,'interjeccion'),
 ('78853f3f-0d28-5c61-8bfc-b4a5de3fb0a3','20000000-0000-0000-0000-000000000003',$p$bonsoir$p$,$p$buenas tardes/noches$p$,123,'interjeccion'),
 ('85f16832-9095-54d4-907f-7180ba207787','20000000-0000-0000-0000-000000000003',$p$au revoir$p$,$p$adiós$p$,124,'interjeccion'),
 ('2943202a-710a-5d36-8cff-7b9ad7119e05','20000000-0000-0000-0000-000000000003',$p$à bientôt$p$,$p$hasta pronto$p$,125,'interjeccion'),
 ('4501f85b-f636-535b-a500-67aca633d458','20000000-0000-0000-0000-000000000003',$p$bonne nuit$p$,$p$buenas noches (al dormir)$p$,126,'interjeccion'),
 ('0c797e30-6bf4-5146-9db0-81efefcb5fab','20000000-0000-0000-0000-000000000003',$p$je m'appelle$p$,$p$me llamo$p$,127,'expresion'),
 ('a6afa5a2-c757-5f03-abdf-7cb7e92450d1','20000000-0000-0000-0000-000000000003',$p$enchanté$p$,$p$encantado$p$,128,'adjetivo'),
 ('5c435210-536a-552a-97bd-729f9b3645b4','20000000-0000-0000-0000-000000000003',$p$je suis$p$,$p$yo soy/estoy$p$,129,'verbo'),
 ('67c32e2f-6220-5531-8d77-9717b3d2edf0','20000000-0000-0000-0000-000000000003',$p$tu es$p$,$p$tú eres/estás$p$,130,'verbo'),
 ('a39baae7-43ce-5a9c-adc8-2bafbc9ce9ea','20000000-0000-0000-0000-000000000003',$p$vous êtes$p$,$p$usted es/está$p$,131,'verbo'),
 ('f54d8b8f-53c4-5a3f-a38c-40d4f44259e3','20000000-0000-0000-0000-000000000003',$p$il est$p$,$p$él es/está$p$,132,'verbo'),
 ('9871f73e-d08c-54eb-a45b-2d83d2e1a9d7','20000000-0000-0000-0000-000000000003',$p$ça va$p$,$p$¿qué tal?/va bien$p$,133,'expresion'),
 ('df0a9488-acb2-5911-b7a3-e34917de244c','20000000-0000-0000-0000-000000000003',$p$très bien$p$,$p$muy bien$p$,134,'expresion'),
 ('8e39ba1a-6d09-51f3-a372-197e23142df0','20000000-0000-0000-0000-000000000003',$p$merci$p$,$p$gracias$p$,135,'interjeccion'),
 ('52b26fb6-7fb2-511b-81c6-5d85accec1ac','20000000-0000-0000-0000-000000000003',$p$et toi$p$,$p$¿y tú?$p$,136,'expresion')
on conflict (id) do nothing;

-- ── Unidad 2 (A1·fr): Les nombres, l'âge et d'où tu viens (números, edad y origen) ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('c785d619-7e08-585d-b808-b8b1c93f7997','20000000-0000-0000-0000-000000000003','A1',2,$p$Les nombres, l'âge et d'où tu viens (números, edad y origen)$p$,'#2980B9','public')
on conflict (course_id, order_index) do update set title=excluded.title, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('f1fda38c-68d5-5397-8d9a-af8b44fb71ab','c785d619-7e08-585d-b808-b8b1c93f7997',1,$p$Los números 0 a 20$p$,$p$Los números 0 a 20$p$,'lesson',15),
 ('0a9e4d8f-0f51-5d3f-93f5-5cf0b5955b26','c785d619-7e08-585d-b808-b8b1c93f7997',2,$p$La edad con avoir$p$,$p$La edad con avoir$p$,'lesson',15),
 ('5a8a2434-c6f1-5c76-ac09-ba2f9a06f0f6','c785d619-7e08-585d-b808-b8b1c93f7997',3,$p$¿De dónde vienes?$p$,$p$¿De dónde vienes?$p$,'lesson',15),
 ('0a1b4619-a020-5a43-a374-4b4ad83f2ce7','c785d619-7e08-585d-b808-b8b1c93f7997',4,$p$Nacionalidades$p$,$p$Nacionalidades$p$,'lesson',15),
 ('7ad19b95-6a2c-5bd6-acb8-aaebe552a380','c785d619-7e08-585d-b808-b8b1c93f7997',5,$p$🏁 Checkpoint Unité 2$p$,$p$Practica los números 0-20, decir tu edad con «avoir», de dónde vienes y tu nacionalidad con su género.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('c983832a-63d6-59cb-b6c7-71ca68f58a64','20000000-0000-0000-0000-000000000003','checkpoint','A1','c785d619-7e08-585d-b808-b8b1c93f7997',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('ddcdf0ba-d6ae-5426-b1d0-39f4adffa602'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','reading','match',$p$Empareja cada número en francés con su cifra.$p$,$j${"pairs": [{"en": "cinq", "es": "5"}, {"en": "dix", "es": "10"}, {"en": "vingt", "es": "20"}]}$j$::jsonb,$j${"pairs": [["cinq", "5"], ["dix", "10"], ["vingt", "20"]]}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$numeros_0_20$p$, $p$reading$p$]),
('1ea56b4e-3d6c-51cb-8339-c8db3f9591af'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','reading','multiple_choice',$p$¿Cómo se escribe el número 15 en francés?$p$,$j${"options": ["quinze", "cinq", "seize"]}$j$::jsonb,$j${"value": "quinze"}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$numeros_0_20$p$, $p$reading$p$]),
('0d71a43e-d433-53b5-ab01-f53cce5f6669'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','writing','cloze',$p$Escribe en letras el número 12 en francés.$p$,$j${"text": "12 = ___"}$j$::jsonb,$j${"value": "douze", "accepted": ["douze"]}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$numeros_0_20$p$, $p$writing$p$]),
('f239d38d-d6bc-5c56-9dc0-00d546730a4a'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','listening','listening',$p$Escucha y elige el número que oíste.$p$,$j${"options": ["dix-sept", "sept", "dix"], "say": "dix-sept", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/f239d38d-d6bc-5c56-9dc0-00d546730a4a.mp3"}$j$::jsonb,$j${"value": "dix-sept"}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$numeros_0_20$p$, $p$listening$p$]),
('288d4f00-ba7c-5bdf-b2d3-97b67622d545'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "zéro, cinq, dix, quinze, vingt", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/288d4f00-ba7c-5bdf-b2d3-97b67622d545.mp3"}$j$::jsonb,$j${"expected": "zéro, cinq, dix, quinze, vingt"}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$numeros_0_20$p$, $p$speaking$p$]),
('ce8f9005-23f1-518a-9948-5a25ababd7e2'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','reading','multiple_choice',$p$En francés la edad se dice con el verbo «avoir». ¿Cuál es correcto para «tengo veinte años»?$p$,$j${"options": ["J'ai vingt ans.", "Je suis vingt ans.", "J'ai vingt."]}$j$::jsonb,$j${"value": "J'ai vingt ans."}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$edad_avoir$p$, $p$reading$p$]),
('7d731078-c56a-57ef-83cc-e38171ed74b9'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','writing','cloze',$p$Completa con el verbo avoir: «Yo tengo diez años».$p$,$j${"text": "J'___ dix ans."}$j$::jsonb,$j${"value": "ai", "accepted": ["ai"]}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$edad_avoir$p$, $p$writing$p$]),
('e01be39d-a21b-5315-ab6d-ec7b55e202c9'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','writing','word_bank',$p$Arma la frase: «¿Cuántos años tienes?».$p$,$j${"tiles": ["Quel", "âge", "as-tu", "es-tu", "ans"]}$j$::jsonb,$j${"value": "Quel âge as-tu", "sequence": ["Quel", "âge", "as-tu"]}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$edad_avoir$p$, $p$writing$p$]),
('403ddf6c-95a3-5ec2-a0f2-480539824ac1'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["J'ai quinze ans.", "J'ai cinq ans.", "Tu as vingt ans."], "say": "J'ai quinze ans.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/403ddf6c-95a3-5ec2-a0f2-480539824ac1.mp3"}$j$::jsonb,$j${"value": "J'ai quinze ans."}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$edad_avoir$p$, $p$listening$p$]),
('8c577e7f-5c57-5287-9ecc-cd0e52a563a4'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Quel âge as-tu ? J'ai vingt ans.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/8c577e7f-5c57-5287-9ecc-cd0e52a563a4.mp3"}$j$::jsonb,$j${"expected": "Quel âge as-tu ? J'ai vingt ans."}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$edad_avoir$p$, $p$speaking$p$]),
('8a1f57bf-95fb-5746-badc-ec4a75bbcf8c'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','reading','multiple_choice',$p$Ante un país que empieza por vocal se usa «d'». ¿Cuál es correcto para «vengo de España»?$p$,$j${"options": ["Je viens d'Espagne.", "Je viens de Espagne.", "Je viens du Espagne."]}$j$::jsonb,$j${"value": "Je viens d'Espagne."}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$origen_venir$p$, $p$reading$p$]),
('82da31c0-9662-56a8-9c7d-80f2d99ac02e'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','reading','multiple_choice',$p$«Le Mexique» es masculino: de + le = du. ¿Cuál es correcto para «vengo de México»?$p$,$j${"options": ["Je viens du Mexique.", "Je viens de Mexique.", "Je viens d'Mexique."]}$j$::jsonb,$j${"value": "Je viens du Mexique."}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$origen_venir$p$, $p$reading$p$]),
('e6f0e166-7749-501e-853d-ff3f54021000'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','writing','translation',$p$Traduce: «Vengo de Francia».$p$,$j${"source": "Vengo de Francia."}$j$::jsonb,$j${"value": "Je viens de France.", "accepted": ["Je viens de France.", "Je viens de France", "Je viens de france.", "je viens de france"]}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$origen_venir$p$, $p$writing$p$]),
('c75d1c3e-8d49-59d4-8603-2fb6978e8012'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','writing','reorder',$p$Ordena: «¿De dónde vienes?».$p$,$j${"tiles": ["viens-tu", "D'", "où"]}$j$::jsonb,$j${"value": "D' où viens-tu"}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$origen_venir$p$, $p$writing$p$]),
('790cc2ab-b59e-532a-b72e-ef025ad937b0'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Je viens d'Espagne.", "Je viens du Mexique.", "Je viens de France."], "say": "Je viens d'Espagne.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/790cc2ab-b59e-532a-b72e-ef025ad937b0.mp3"}$j$::jsonb,$j${"value": "Je viens d'Espagne."}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$origen_venir$p$, $p$listening$p$]),
('70877ab5-d2da-5167-829b-5f299a875b52'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','reading','match',$p$Empareja cada nacionalidad en francés con su traducción.$p$,$j${"pairs": [{"en": "français", "es": "francés"}, {"en": "espagnol", "es": "español"}, {"en": "mexicain", "es": "mexicano"}]}$j$::jsonb,$j${"pairs": [["français", "francés"], ["espagnol", "español"], ["mexicain", "mexicano"]]}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$nacionalidades$p$, $p$reading$p$]),
('399e9ef8-2670-5bc3-9a5e-e7805dba68f3'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','reading','multiple_choice',$p$Marie es de España. En femenino, ¿cómo dice su nacionalidad?$p$,$j${"options": ["Je suis espagnole.", "Je suis espagnol.", "Je suis française."]}$j$::jsonb,$j${"value": "Je suis espagnole."}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$nacionalidades$p$, $p$reading$p$]),
('572839f7-cc2c-5dc9-a7ed-10369fb95fcd'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','writing','translation',$p$Traduce (habla un hombre): «Soy francés».$p$,$j${"source": "Soy francés."}$j$::jsonb,$j${"value": "Je suis français.", "accepted": ["Je suis français.", "Je suis français", "Je suis francais.", "je suis francais"]}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$nacionalidades$p$, $p$writing$p$]),
('a91c7935-0107-5e9f-93ef-73d19e9648ab'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Je viens du Mexique. Je suis mexicaine.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/a91c7935-0107-5e9f-93ef-73d19e9648ab.mp3"}$j$::jsonb,$j${"expected": "Je viens du Mexique. Je suis mexicaine."}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$nacionalidades$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('f1fda38c-68d5-5397-8d9a-af8b44fb71ab','ddcdf0ba-d6ae-5426-b1d0-39f4adffa602',1),
 ('f1fda38c-68d5-5397-8d9a-af8b44fb71ab','1ea56b4e-3d6c-51cb-8339-c8db3f9591af',2),
 ('f1fda38c-68d5-5397-8d9a-af8b44fb71ab','0d71a43e-d433-53b5-ab01-f53cce5f6669',3),
 ('f1fda38c-68d5-5397-8d9a-af8b44fb71ab','f239d38d-d6bc-5c56-9dc0-00d546730a4a',4),
 ('f1fda38c-68d5-5397-8d9a-af8b44fb71ab','288d4f00-ba7c-5bdf-b2d3-97b67622d545',5),
 ('0a9e4d8f-0f51-5d3f-93f5-5cf0b5955b26','ce8f9005-23f1-518a-9948-5a25ababd7e2',1),
 ('0a9e4d8f-0f51-5d3f-93f5-5cf0b5955b26','7d731078-c56a-57ef-83cc-e38171ed74b9',2),
 ('0a9e4d8f-0f51-5d3f-93f5-5cf0b5955b26','e01be39d-a21b-5315-ab6d-ec7b55e202c9',3),
 ('0a9e4d8f-0f51-5d3f-93f5-5cf0b5955b26','403ddf6c-95a3-5ec2-a0f2-480539824ac1',4),
 ('0a9e4d8f-0f51-5d3f-93f5-5cf0b5955b26','8c577e7f-5c57-5287-9ecc-cd0e52a563a4',5),
 ('5a8a2434-c6f1-5c76-ac09-ba2f9a06f0f6','8a1f57bf-95fb-5746-badc-ec4a75bbcf8c',1),
 ('5a8a2434-c6f1-5c76-ac09-ba2f9a06f0f6','82da31c0-9662-56a8-9c7d-80f2d99ac02e',2),
 ('5a8a2434-c6f1-5c76-ac09-ba2f9a06f0f6','e6f0e166-7749-501e-853d-ff3f54021000',3),
 ('5a8a2434-c6f1-5c76-ac09-ba2f9a06f0f6','c75d1c3e-8d49-59d4-8603-2fb6978e8012',4),
 ('5a8a2434-c6f1-5c76-ac09-ba2f9a06f0f6','790cc2ab-b59e-532a-b72e-ef025ad937b0',5),
 ('0a1b4619-a020-5a43-a374-4b4ad83f2ce7','70877ab5-d2da-5167-829b-5f299a875b52',1),
 ('0a1b4619-a020-5a43-a374-4b4ad83f2ce7','399e9ef8-2670-5bc3-9a5e-e7805dba68f3',2),
 ('0a1b4619-a020-5a43-a374-4b4ad83f2ce7','572839f7-cc2c-5dc9-a7ed-10369fb95fcd',3),
 ('0a1b4619-a020-5a43-a374-4b4ad83f2ce7','a91c7935-0107-5e9f-93ef-73d19e9648ab',4),
 ('7ad19b95-6a2c-5bd6-acb8-aaebe552a380','ddcdf0ba-d6ae-5426-b1d0-39f4adffa602',1),
 ('7ad19b95-6a2c-5bd6-acb8-aaebe552a380','1ea56b4e-3d6c-51cb-8339-c8db3f9591af',2),
 ('7ad19b95-6a2c-5bd6-acb8-aaebe552a380','ce8f9005-23f1-518a-9948-5a25ababd7e2',3),
 ('7ad19b95-6a2c-5bd6-acb8-aaebe552a380','0d71a43e-d433-53b5-ab01-f53cce5f6669',4),
 ('7ad19b95-6a2c-5bd6-acb8-aaebe552a380','7d731078-c56a-57ef-83cc-e38171ed74b9',5),
 ('7ad19b95-6a2c-5bd6-acb8-aaebe552a380','e01be39d-a21b-5315-ab6d-ec7b55e202c9',6),
 ('7ad19b95-6a2c-5bd6-acb8-aaebe552a380','f239d38d-d6bc-5c56-9dc0-00d546730a4a',7),
 ('7ad19b95-6a2c-5bd6-acb8-aaebe552a380','403ddf6c-95a3-5ec2-a0f2-480539824ac1',8),
 ('7ad19b95-6a2c-5bd6-acb8-aaebe552a380','288d4f00-ba7c-5bdf-b2d3-97b67622d545',9),
 ('7ad19b95-6a2c-5bd6-acb8-aaebe552a380','8c577e7f-5c57-5287-9ecc-cd0e52a563a4',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('e57d661f-6fd1-5f96-a763-3d59657bf289','20000000-0000-0000-0000-000000000003',$p$zéro$p$,$p$cero$p$,141,'numeral'),
 ('c43944ab-2e21-5435-aa98-692942eaf1b1','20000000-0000-0000-0000-000000000003',$p$cinq$p$,$p$cinco$p$,142,'numeral'),
 ('14ae0394-47f6-52b0-839b-53d1e29c6a09','20000000-0000-0000-0000-000000000003',$p$dix$p$,$p$diez$p$,143,'numeral'),
 ('76433e52-5b73-5975-b627-75b957ee63fc','20000000-0000-0000-0000-000000000003',$p$quinze$p$,$p$quince$p$,144,'numeral'),
 ('3943b32d-0811-5360-a59d-8395c2c889be','20000000-0000-0000-0000-000000000003',$p$vingt$p$,$p$veinte$p$,145,'numeral'),
 ('ef11ae0f-933e-57bb-9b0f-4c6a6280e614','20000000-0000-0000-0000-000000000003',$p$avoir$p$,$p$tener$p$,146,'verbo'),
 ('d56d5996-eebf-5191-9476-f5ba2f5fbe23','20000000-0000-0000-0000-000000000003',$p$j'ai$p$,$p$yo tengo$p$,147,'verbo'),
 ('87c9114e-4436-5b2f-a002-3ae64e6bf981','20000000-0000-0000-0000-000000000003',$p$tu as$p$,$p$tú tienes$p$,148,'verbo'),
 ('ca35bf01-950d-5cec-8abe-f701b17e6d07','20000000-0000-0000-0000-000000000003',$p$quel âge$p$,$p$qué edad$p$,149,'expresion'),
 ('3778b634-504b-509b-81a5-8f4cc2e9a520','20000000-0000-0000-0000-000000000003',$p$ans$p$,$p$años$p$,150,'sustantivo'),
 ('2a6ca3db-da11-59e3-9f27-2d722cba9aef','20000000-0000-0000-0000-000000000003',$p$je viens de$p$,$p$vengo de$p$,151,'expresion'),
 ('723f7f3f-918c-5bc3-a951-9c1745355487','20000000-0000-0000-0000-000000000003',$p$d'où$p$,$p$de dónde$p$,152,'expresion'),
 ('2ec65022-b2dc-5820-ae0a-90cde9b5b316','20000000-0000-0000-0000-000000000003',$p$pays$p$,$p$país$p$,153,'sustantivo'),
 ('2a88fd48-8033-536a-a417-626ec235cf3c','20000000-0000-0000-0000-000000000003',$p$français$p$,$p$francés$p$,154,'adjetivo'),
 ('9ab3c965-bf55-5dce-bcc6-097a07d5d52a','20000000-0000-0000-0000-000000000003',$p$espagnole$p$,$p$española$p$,155,'adjetivo'),
 ('283f74a4-4128-57ac-a3e5-d8ebe04533d6','20000000-0000-0000-0000-000000000003',$p$mexicain$p$,$p$mexicano$p$,156,'adjetivo')
on conflict (id) do nothing;

-- ── Unidad 3 (A1·fr): La familia y las personas ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('e71f34eb-820b-5f77-ae4c-a20b53d51c23','20000000-0000-0000-0000-000000000003','A1',3,$p$La familia y las personas$p$,'#8E44AD','family_restroom')
on conflict (course_id, order_index) do update set title=excluded.title, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('8da633af-e841-5e04-b9c2-1762aebdf1f7','e71f34eb-820b-5f77-ae4c-a20b53d51c23',1,$p$La familia (la famille)$p$,$p$La familia (la famille)$p$,'lesson',15),
 ('f56d9715-8280-5aa0-a013-d80f4e4c1e44','e71f34eb-820b-5f77-ae4c-a20b53d51c23',2,$p$Los posesivos (mon, ma, mes)$p$,$p$Los posesivos (mon, ma, mes)$p$,'lesson',15),
 ('4f966bea-29fe-5181-949d-d921b0afa3e6','e71f34eb-820b-5f77-ae4c-a20b53d51c23',3,$p$Presentar personas (c'est, il/elle est)$p$,$p$Presentar personas (c'est, il/elle est)$p$,'lesson',15),
 ('85aa505b-762d-5dd3-9bdf-9f543217292c','e71f34eb-820b-5f77-ae4c-a20b53d51c23',4,$p$Describir personas (adjetivos y avoir)$p$,$p$Describir personas (adjetivos y avoir)$p$,'lesson',15),
 ('8c6ffed7-f3cd-59d1-b4c9-f3514d62d314','e71f34eb-820b-5f77-ae4c-a20b53d51c23',5,$p$🏁 Checkpoint Unité 3$p$,$p$Demuestra que sabes hablar de tu familia, usar posesivos, presentar personas y describirlas.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('05d2db0f-501c-586b-94d9-3ceff6f6024e','20000000-0000-0000-0000-000000000003','checkpoint','A1','e71f34eb-820b-5f77-ae4c-a20b53d51c23',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('91793a96-ca9f-59a9-a63b-d86b831baa2a'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','reading','match',$p$Empareja cada palabra francesa con su traducción.$p$,$j${"pairs": [{"en": "la mère", "es": "la madre"}, {"en": "le père", "es": "el padre"}, {"en": "la sœur", "es": "la hermana"}]}$j$::jsonb,$j${"pairs": [["la mère", "la madre"], ["le père", "el padre"], ["la sœur", "la hermana"]]}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$familia$p$, $p$reading$p$]),
('c85a9df3-8159-5bda-a1d9-13de79e6ca08'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','reading','multiple_choice',$p$¿Cuál es «el hijo» en francés?$p$,$j${"options": ["le fils", "la fille", "le père"]}$j$::jsonb,$j${"value": "le fils"}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$familia$p$, $p$reading$p$]),
('aa3b8fed-8f2f-520c-a436-50223f347b86'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Voici ma famille.", "Voici mon frère.", "Voici ma mère."], "say": "Voici ma famille.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/aa3b8fed-8f2f-520c-a436-50223f347b86.mp3"}$j$::jsonb,$j${"value": "Voici ma famille."}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$familia$p$, $p$listening$p$]),
('f0e6c679-29c9-53e9-a80a-7959462c20d0'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','writing','translation',$p$Traduce: «El padre y la madre».$p$,$j${"source": "El padre y la madre"}$j$::jsonb,$j${"value": "Le père et la mère", "accepted": ["Le père et la mère", "le père et la mère", "Le pere et la mere", "le pere et la mere"]}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$familia$p$, $p$writing$p$]),
('882753e0-7354-5d46-a7ea-31069894c4a3'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "J'ai une grande famille.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/882753e0-7354-5d46-a7ea-31069894c4a3.mp3"}$j$::jsonb,$j${"expected": "J'ai une grande famille."}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$familia$p$, $p$speaking$p$]),
('1455bf94-854f-560c-b7aa-f7c28f055438'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','reading','match',$p$Empareja cada palabra francesa con su traducción.$p$,$j${"pairs": [{"en": "le frère", "es": "el hermano"}, {"en": "les parents", "es": "los padres"}, {"en": "la grand-mère", "es": "la abuela"}]}$j$::jsonb,$j${"pairs": [["le frère", "el hermano"], ["les parents", "los padres"], ["la grand-mère", "la abuela"]]}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$posesivos$p$, $p$reading$p$]),
('d986b1e7-9593-54f8-8b00-2d3ba94f6b29'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','reading','multiple_choice',$p$Completa con el posesivo correcto: «___ sœur» (mi hermana).$p$,$j${"options": ["ma", "mon", "mes"]}$j$::jsonb,$j${"value": "ma"}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$posesivos$p$, $p$reading$p$]),
('bce49095-1883-59ac-9832-2510f35a635d'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','writing','cloze',$p$Completa con el posesivo correcto para «mis padres»: ___ parents.$p$,$j${"text": "___ parents"}$j$::jsonb,$j${"value": "mes", "accepted": ["mes"]}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$posesivos$p$, $p$writing$p$]),
('4584303c-cb27-5bdb-9d78-d4f2abcde2b1'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','writing','word_bank',$p$Arma: «Mi madre es simpática».$p$,$j${"tiles": ["Ma", "mère", "est", "sympa", "Mon", "sympas"]}$j$::jsonb,$j${"value": "Ma mère est sympa", "sequence": ["Ma", "mère", "est", "sympa"]}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$posesivos$p$, $p$writing$p$]),
('42fac068-e4f8-5099-848e-07f86466fb33'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["C'est mon frère.", "C'est ma sœur.", "C'est mon père."], "say": "C'est mon frère.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/42fac068-e4f8-5099-848e-07f86466fb33.mp3"}$j$::jsonb,$j${"value": "C'est mon frère."}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$posesivos$p$, $p$listening$p$]),
('7d69b97a-00a6-517c-8223-672c3125bf9d'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Ma sœur est petite.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/7d69b97a-00a6-517c-8223-672c3125bf9d.mp3"}$j$::jsonb,$j${"expected": "Ma sœur est petite."}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$posesivos$p$, $p$speaking$p$]),
('4ee5a41a-08ea-546c-bbaa-fc1fb9d0f9f1'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','reading','multiple_choice',$p$Para presentar a UNA persona («Es mi madre») usamos:$p$,$j${"options": ["C'est ma mère.", "Ce sont ma mère.", "Il est ma mère."]}$j$::jsonb,$j${"value": "C'est ma mère."}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$presentar$p$, $p$reading$p$]),
('4bf75620-64f4-50f6-8107-5814978bfa35'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','writing','cloze',$p$Completa para presentar a varias personas: «___ mes parents» (Son mis padres).$p$,$j${"text": "___ mes parents"}$j$::jsonb,$j${"value": "Ce sont", "accepted": ["Ce sont", "ce sont"]}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$presentar$p$, $p$writing$p$]),
('e5b1606e-a48e-5e9e-a312-ebf23bdeba34'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','writing','reorder',$p$Ordena: «Es mi padre».$p$,$j${"tiles": ["C'est", "mon", "père"]}$j$::jsonb,$j${"value": "C'est mon père"}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$presentar$p$, $p$writing$p$]),
('215037d6-c8d9-5168-a10b-494d80d96de4'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Elle est ma sœur.", "Il est mon frère.", "C'est ma mère."], "say": "Elle est ma sœur.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/215037d6-c8d9-5168-a10b-494d80d96de4.mp3"}$j$::jsonb,$j${"value": "Elle est ma sœur."}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$presentar$p$, $p$listening$p$]),
('fe10c3dc-3dab-5c28-9cbb-606749b127ab'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "C'est mon grand-père.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/fe10c3dc-3dab-5c28-9cbb-606749b127ab.mp3"}$j$::jsonb,$j${"expected": "C'est mon grand-père."}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$presentar$p$, $p$speaking$p$]),
('fb4f2297-7826-5464-bedc-5782261d25d4'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','reading','multiple_choice',$p$«Ma mère est ___» (mi madre es alta). Elige la forma femenina correcta.$p$,$j${"options": ["grande", "grand", "grands"]}$j$::jsonb,$j${"value": "grande"}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$describir$p$, $p$reading$p$]),
('24408253-36e5-5086-831d-704d0ab143d1'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','writing','translation',$p$Traduce: «Mi hermano es simpático».$p$,$j${"source": "Mi hermano es simpático"}$j$::jsonb,$j${"value": "Mon frère est sympa", "accepted": ["Mon frère est sympa", "mon frère est sympa", "Mon frere est sympa", "Mon frère est sympa.", "Mon frère est sympathique"]}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$describir$p$, $p$writing$p$]),
('88eb1f76-edd9-5d5d-bf56-4ed3d5a5cb00'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Il est grand et sympa.", "Elle est petite et sympa.", "Il a deux enfants."], "say": "Il est grand et sympa.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/88eb1f76-edd9-5d5d-bf56-4ed3d5a5cb00.mp3"}$j$::jsonb,$j${"value": "Il est grand et sympa."}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$describir$p$, $p$listening$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('8da633af-e841-5e04-b9c2-1762aebdf1f7','91793a96-ca9f-59a9-a63b-d86b831baa2a',1),
 ('8da633af-e841-5e04-b9c2-1762aebdf1f7','c85a9df3-8159-5bda-a1d9-13de79e6ca08',2),
 ('8da633af-e841-5e04-b9c2-1762aebdf1f7','aa3b8fed-8f2f-520c-a436-50223f347b86',3),
 ('8da633af-e841-5e04-b9c2-1762aebdf1f7','f0e6c679-29c9-53e9-a80a-7959462c20d0',4),
 ('8da633af-e841-5e04-b9c2-1762aebdf1f7','882753e0-7354-5d46-a7ea-31069894c4a3',5),
 ('f56d9715-8280-5aa0-a013-d80f4e4c1e44','1455bf94-854f-560c-b7aa-f7c28f055438',1),
 ('f56d9715-8280-5aa0-a013-d80f4e4c1e44','d986b1e7-9593-54f8-8b00-2d3ba94f6b29',2),
 ('f56d9715-8280-5aa0-a013-d80f4e4c1e44','bce49095-1883-59ac-9832-2510f35a635d',3),
 ('f56d9715-8280-5aa0-a013-d80f4e4c1e44','4584303c-cb27-5bdb-9d78-d4f2abcde2b1',4),
 ('f56d9715-8280-5aa0-a013-d80f4e4c1e44','42fac068-e4f8-5099-848e-07f86466fb33',5),
 ('f56d9715-8280-5aa0-a013-d80f4e4c1e44','7d69b97a-00a6-517c-8223-672c3125bf9d',6),
 ('4f966bea-29fe-5181-949d-d921b0afa3e6','4ee5a41a-08ea-546c-bbaa-fc1fb9d0f9f1',1),
 ('4f966bea-29fe-5181-949d-d921b0afa3e6','4bf75620-64f4-50f6-8107-5814978bfa35',2),
 ('4f966bea-29fe-5181-949d-d921b0afa3e6','e5b1606e-a48e-5e9e-a312-ebf23bdeba34',3),
 ('4f966bea-29fe-5181-949d-d921b0afa3e6','215037d6-c8d9-5168-a10b-494d80d96de4',4),
 ('4f966bea-29fe-5181-949d-d921b0afa3e6','fe10c3dc-3dab-5c28-9cbb-606749b127ab',5),
 ('85aa505b-762d-5dd3-9bdf-9f543217292c','fb4f2297-7826-5464-bedc-5782261d25d4',1),
 ('85aa505b-762d-5dd3-9bdf-9f543217292c','24408253-36e5-5086-831d-704d0ab143d1',2),
 ('85aa505b-762d-5dd3-9bdf-9f543217292c','88eb1f76-edd9-5d5d-bf56-4ed3d5a5cb00',3),
 ('8c6ffed7-f3cd-59d1-b4c9-f3514d62d314','91793a96-ca9f-59a9-a63b-d86b831baa2a',1),
 ('8c6ffed7-f3cd-59d1-b4c9-f3514d62d314','c85a9df3-8159-5bda-a1d9-13de79e6ca08',2),
 ('8c6ffed7-f3cd-59d1-b4c9-f3514d62d314','1455bf94-854f-560c-b7aa-f7c28f055438',3),
 ('8c6ffed7-f3cd-59d1-b4c9-f3514d62d314','f0e6c679-29c9-53e9-a80a-7959462c20d0',4),
 ('8c6ffed7-f3cd-59d1-b4c9-f3514d62d314','bce49095-1883-59ac-9832-2510f35a635d',5),
 ('8c6ffed7-f3cd-59d1-b4c9-f3514d62d314','4584303c-cb27-5bdb-9d78-d4f2abcde2b1',6),
 ('8c6ffed7-f3cd-59d1-b4c9-f3514d62d314','aa3b8fed-8f2f-520c-a436-50223f347b86',7),
 ('8c6ffed7-f3cd-59d1-b4c9-f3514d62d314','42fac068-e4f8-5099-848e-07f86466fb33',8),
 ('8c6ffed7-f3cd-59d1-b4c9-f3514d62d314','882753e0-7354-5d46-a7ea-31069894c4a3',9),
 ('8c6ffed7-f3cd-59d1-b4c9-f3514d62d314','7d69b97a-00a6-517c-8223-672c3125bf9d',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('66a18522-1435-59f7-a998-877436df6183','20000000-0000-0000-0000-000000000003',$p$la mère$p$,$p$la madre$p$,161,'sustantivo'),
 ('6cf16fc0-50dd-5467-82f4-e5b029443650','20000000-0000-0000-0000-000000000003',$p$le père$p$,$p$el padre$p$,162,'sustantivo'),
 ('6d3563f7-f1fb-576d-8458-78bec4f27a4e','20000000-0000-0000-0000-000000000003',$p$le frère$p$,$p$el hermano$p$,163,'sustantivo'),
 ('2968cefa-5012-5cc2-8d75-fdf247819895','20000000-0000-0000-0000-000000000003',$p$la sœur$p$,$p$la hermana$p$,164,'sustantivo'),
 ('ae1d4752-d569-55d0-bfe5-4cd7d9e1a894','20000000-0000-0000-0000-000000000003',$p$le fils$p$,$p$el hijo$p$,165,'sustantivo'),
 ('fbe1e4ea-7e2b-5637-a1d5-9c6269f8eb6d','20000000-0000-0000-0000-000000000003',$p$la fille$p$,$p$la hija$p$,166,'sustantivo'),
 ('c8cd1bb2-e5d8-56a7-933c-966ecf31539c','20000000-0000-0000-0000-000000000003',$p$les parents$p$,$p$los padres$p$,167,'sustantivo'),
 ('9b1e2c6d-a150-5072-bf0d-da90299dc080','20000000-0000-0000-0000-000000000003',$p$la grand-mère$p$,$p$la abuela$p$,168,'sustantivo'),
 ('b4f6eff3-b75b-5e91-97f1-2ad37827fa64','20000000-0000-0000-0000-000000000003',$p$le grand-père$p$,$p$el abuelo$p$,169,'sustantivo'),
 ('f2cf254e-8e0b-52a0-84aa-b148f10bd6c7','20000000-0000-0000-0000-000000000003',$p$l'enfant$p$,$p$el niño / la niña$p$,170,'sustantivo'),
 ('8ac6df7f-6ff6-5880-ba82-eb1cade1d53d','20000000-0000-0000-0000-000000000003',$p$grand$p$,$p$grande / alto$p$,171,'adjetivo'),
 ('4b32ea7d-87d8-5058-bcfa-78016591a46f','20000000-0000-0000-0000-000000000003',$p$petit$p$,$p$pequeño / bajo$p$,172,'adjetivo'),
 ('cb9d9966-a98b-5c82-93fd-a4d75e69e4f2','20000000-0000-0000-0000-000000000003',$p$sympa$p$,$p$simpático/a$p$,173,'adjetivo'),
 ('43a3cd0a-d829-50d7-9520-015113903145','20000000-0000-0000-0000-000000000003',$p$avoir$p$,$p$tener$p$,174,'verbo'),
 ('71dab4bc-f520-5f35-aa60-74196bf5b9a4','20000000-0000-0000-0000-000000000003',$p$mon$p$,$p$mi (masculino)$p$,175,'posesivo'),
 ('515ffc7e-4ce2-57e3-8846-672ed6f9648b','20000000-0000-0000-0000-000000000003',$p$ma$p$,$p$mi (femenino)$p$,176,'posesivo')
on conflict (id) do nothing;

-- ── Unidad 4 (A1·fr): Comida y bebida / en el café ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('1c3201e4-b0fd-5852-bf03-e00c044cf454','20000000-0000-0000-0000-000000000003','A1',4,$p$Comida y bebida / en el café$p$,'#E67E22','restaurant')
on conflict (course_id, order_index) do update set title=excluded.title, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('f57da679-5e7c-58bf-86dd-1259ac2f6b1e','1c3201e4-b0fd-5852-bf03-e00c044cf454',1,$p$La comida (la nourriture)$p$,$p$La comida (la nourriture)$p$,'lesson',15),
 ('4028d002-b9a5-55d6-b926-93b21c72d692','1c3201e4-b0fd-5852-bf03-e00c044cf454',2,$p$En el café (je voudrais...)$p$,$p$En el café (je voudrais...)$p$,'lesson',15),
 ('51a00da1-3a7b-54f4-b76e-13c74dc65273','1c3201e4-b0fd-5852-bf03-e00c044cf454',3,$p$El partitivo (du, de la, des)$p$,$p$El partitivo (du, de la, des)$p$,'lesson',15),
 ('76464d00-094f-549c-b15a-a0397de2a0cb','1c3201e4-b0fd-5852-bf03-e00c044cf454',4,$p$Precios y cantidad (combien ça coûte ?)$p$,$p$Precios y cantidad (combien ça coûte ?)$p$,'lesson',15),
 ('22440fa7-3162-59ed-8be6-df44dcd667ab','1c3201e4-b0fd-5852-bf03-e00c044cf454',5,$p$🏁 Checkpoint Unité 4$p$,$p$Demuestra que sabes nombrar comida, pedir en el café con cortesía, usar el partitivo y hablar de precios.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('79b7282c-37b0-524c-a39e-6b66263083f0','20000000-0000-0000-0000-000000000003','checkpoint','A1','1c3201e4-b0fd-5852-bf03-e00c044cf454',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('604c7f47-052f-5d91-8f43-8db29d2b0d63'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','reading','match',$p$Empareja cada palabra francesa con su traducción.$p$,$j${"pairs": [{"en": "le pain", "es": "el pan"}, {"en": "l'eau", "es": "el agua"}, {"en": "le fromage", "es": "el queso"}]}$j$::jsonb,$j${"pairs": [["le pain", "el pan"], ["l'eau", "el agua"], ["le fromage", "el queso"]]}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$comida$p$, $p$reading$p$]),
('403f864b-a739-540d-a87b-1cca0724495b'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','reading','multiple_choice',$p$¿Cuál es «el café» (la bebida) en francés?$p$,$j${"options": ["le café", "le lait", "l'eau"]}$j$::jsonb,$j${"value": "le café"}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$comida$p$, $p$reading$p$]),
('6512f6f3-630c-57d6-aec9-85652a8e14f5'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["J'aime le fromage.", "J'aime le poulet.", "J'aime le pain."], "say": "J'aime le fromage.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/6512f6f3-630c-57d6-aec9-85652a8e14f5.mp3"}$j$::jsonb,$j${"value": "J'aime le fromage."}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$comida$p$, $p$listening$p$]),
('8a4921e6-ba5b-532f-8c9d-a40797d14bd8'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','writing','translation',$p$Traduce: «El pan y el queso».$p$,$j${"source": "El pan y el queso"}$j$::jsonb,$j${"value": "Le pain et le fromage", "accepted": ["Le pain et le fromage", "le pain et le fromage", "Le pain et le fromage."]}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$comida$p$, $p$writing$p$]),
('3bb80277-996b-51b8-9f3d-b1d91e09dd24'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "J'aime le café et le pain.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/3bb80277-996b-51b8-9f3d-b1d91e09dd24.mp3"}$j$::jsonb,$j${"expected": "J'aime le café et le pain."}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$comida$p$, $p$speaking$p$]),
('430b411c-f780-5c94-9065-6026d4ca5d72'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','reading','match',$p$Empareja cada expresión francesa con su traducción.$p$,$j${"pairs": [{"en": "l'addition", "es": "la cuenta"}, {"en": "la bière", "es": "la cerveza"}, {"en": "s'il vous plaît", "es": "por favor"}]}$j$::jsonb,$j${"pairs": [["l'addition", "la cuenta"], ["la bière", "la cerveza"], ["s'il vous plaît", "por favor"]]}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$cafe$p$, $p$reading$p$]),
('ad373e1d-d691-5924-b9e4-9cfbb17be912'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','reading','multiple_choice',$p$¿Cómo pides con cortesía «Quisiera un café»?$p$,$j${"options": ["Je voudrais un café.", "Je veux un café.", "Donne un café."]}$j$::jsonb,$j${"value": "Je voudrais un café."}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$cafe$p$, $p$reading$p$]),
('1162b13f-5474-5f20-95d5-d341d1fd7ec0'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','writing','cloze',$p$Completa la fórmula de cortesía «por favor»: s'il vous ___.$p$,$j${"text": "s'il vous ___"}$j$::jsonb,$j${"value": "plaît", "accepted": ["plaît", "plait"]}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$cafe$p$, $p$writing$p$]),
('abcce57d-003d-5517-8d82-780e7f9c6ada'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','writing','word_bank',$p$Arma: «Quisiera una cerveza, por favor».$p$,$j${"tiles": ["Je", "voudrais", "une", "bière", "s'il", "vous", "plaît", "un"]}$j$::jsonb,$j${"value": "Je voudrais une bière s'il vous plaît", "sequence": ["Je", "voudrais", "une", "bière", "s'il", "vous", "plaît"]}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$cafe$p$, $p$writing$p$]),
('abbb8f6a-13e4-5783-9e14-cc49018ede55'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Un café, s'il vous plaît.", "Une bière, s'il vous plaît.", "L'addition, s'il vous plaît."], "say": "Un café, s'il vous plaît.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/abbb8f6a-13e4-5783-9e14-cc49018ede55.mp3"}$j$::jsonb,$j${"value": "Un café, s'il vous plaît."}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$cafe$p$, $p$listening$p$]),
('1cfa71c7-cfe7-5ed0-93de-65a4dcd2e66c'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Je voudrais un café, s'il vous plaît.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/1cfa71c7-cfe7-5ed0-93de-65a4dcd2e66c.mp3"}$j$::jsonb,$j${"expected": "Je voudrais un café, s'il vous plaît."}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$cafe$p$, $p$speaking$p$]),
('55a9e547-257e-58c5-b69f-608c9823cb1c'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','reading','multiple_choice',$p$Elige el partitivo correcto: «Je voudrais ___ pain» (quisiera pan).$p$,$j${"options": ["du", "de la", "des"]}$j$::jsonb,$j${"value": "du"}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$partitivo$p$, $p$reading$p$]),
('7834726d-85db-5a02-b8ce-0f76a0a6e56f'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','writing','cloze',$p$Completa con el partitivo ante vocal: «Je voudrais ___ eau» (quisiera agua).$p$,$j${"text": "Je voudrais ___ eau"}$j$::jsonb,$j${"value": "de l'", "accepted": ["de l'", "de l’"]}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$partitivo$p$, $p$writing$p$]),
('471644b2-18f8-5489-82ff-053797b46a56'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','writing','reorder',$p$Ordena: «Quisiera algo de queso».$p$,$j${"tiles": ["Je", "voudrais", "du", "fromage"]}$j$::jsonb,$j${"value": "Je voudrais du fromage"}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$partitivo$p$, $p$writing$p$]),
('7e21ae34-b69e-57c1-8289-e67afd46b14c'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Je voudrais de la soupe.", "Je voudrais du pain.", "Je voudrais des pommes."], "say": "Je voudrais de la soupe.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/7e21ae34-b69e-57c1-8289-e67afd46b14c.mp3"}$j$::jsonb,$j${"value": "Je voudrais de la soupe."}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$partitivo$p$, $p$listening$p$]),
('cd15b914-5bba-5a8c-862a-e43b6efb8eec'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Je voudrais du fromage et de l'eau.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/cd15b914-5bba-5a8c-862a-e43b6efb8eec.mp3"}$j$::jsonb,$j${"expected": "Je voudrais du fromage et de l'eau."}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$partitivo$p$, $p$speaking$p$]),
('120fe075-1850-5e57-8eba-8763c2256846'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','reading','multiple_choice',$p$¿Cómo preguntas «¿Cuánto cuesta?»?$p$,$j${"options": ["Combien ça coûte ?", "Où ça coûte ?", "Quand ça coûte ?"]}$j$::jsonb,$j${"value": "Combien ça coûte ?"}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$precios$p$, $p$reading$p$]),
('11359f61-7ae2-50e2-beec-9639f2c165d1'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','writing','translation',$p$Traduce: «Son cinco euros».$p$,$j${"source": "Son cinco euros"}$j$::jsonb,$j${"value": "Ça fait cinq euros", "accepted": ["Ça fait cinq euros", "ça fait cinq euros", "Ca fait cinq euros", "Ça fait cinq euros."]}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$precios$p$, $p$writing$p$]),
('498c2dc9-c35e-5403-b853-296e9fa20177'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ça fait dix euros.", "Ça fait cinq euros.", "Combien ça coûte ?"], "say": "Ça fait dix euros.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/498c2dc9-c35e-5403-b853-296e9fa20177.mp3"}$j$::jsonb,$j${"value": "Ça fait dix euros."}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$precios$p$, $p$listening$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('f57da679-5e7c-58bf-86dd-1259ac2f6b1e','604c7f47-052f-5d91-8f43-8db29d2b0d63',1),
 ('f57da679-5e7c-58bf-86dd-1259ac2f6b1e','403f864b-a739-540d-a87b-1cca0724495b',2),
 ('f57da679-5e7c-58bf-86dd-1259ac2f6b1e','6512f6f3-630c-57d6-aec9-85652a8e14f5',3),
 ('f57da679-5e7c-58bf-86dd-1259ac2f6b1e','8a4921e6-ba5b-532f-8c9d-a40797d14bd8',4),
 ('f57da679-5e7c-58bf-86dd-1259ac2f6b1e','3bb80277-996b-51b8-9f3d-b1d91e09dd24',5),
 ('4028d002-b9a5-55d6-b926-93b21c72d692','430b411c-f780-5c94-9065-6026d4ca5d72',1),
 ('4028d002-b9a5-55d6-b926-93b21c72d692','ad373e1d-d691-5924-b9e4-9cfbb17be912',2),
 ('4028d002-b9a5-55d6-b926-93b21c72d692','1162b13f-5474-5f20-95d5-d341d1fd7ec0',3),
 ('4028d002-b9a5-55d6-b926-93b21c72d692','abcce57d-003d-5517-8d82-780e7f9c6ada',4),
 ('4028d002-b9a5-55d6-b926-93b21c72d692','abbb8f6a-13e4-5783-9e14-cc49018ede55',5),
 ('4028d002-b9a5-55d6-b926-93b21c72d692','1cfa71c7-cfe7-5ed0-93de-65a4dcd2e66c',6),
 ('51a00da1-3a7b-54f4-b76e-13c74dc65273','55a9e547-257e-58c5-b69f-608c9823cb1c',1),
 ('51a00da1-3a7b-54f4-b76e-13c74dc65273','7834726d-85db-5a02-b8ce-0f76a0a6e56f',2),
 ('51a00da1-3a7b-54f4-b76e-13c74dc65273','471644b2-18f8-5489-82ff-053797b46a56',3),
 ('51a00da1-3a7b-54f4-b76e-13c74dc65273','7e21ae34-b69e-57c1-8289-e67afd46b14c',4),
 ('51a00da1-3a7b-54f4-b76e-13c74dc65273','cd15b914-5bba-5a8c-862a-e43b6efb8eec',5),
 ('76464d00-094f-549c-b15a-a0397de2a0cb','120fe075-1850-5e57-8eba-8763c2256846',1),
 ('76464d00-094f-549c-b15a-a0397de2a0cb','11359f61-7ae2-50e2-beec-9639f2c165d1',2),
 ('76464d00-094f-549c-b15a-a0397de2a0cb','498c2dc9-c35e-5403-b853-296e9fa20177',3),
 ('22440fa7-3162-59ed-8be6-df44dcd667ab','604c7f47-052f-5d91-8f43-8db29d2b0d63',1),
 ('22440fa7-3162-59ed-8be6-df44dcd667ab','403f864b-a739-540d-a87b-1cca0724495b',2),
 ('22440fa7-3162-59ed-8be6-df44dcd667ab','430b411c-f780-5c94-9065-6026d4ca5d72',3),
 ('22440fa7-3162-59ed-8be6-df44dcd667ab','8a4921e6-ba5b-532f-8c9d-a40797d14bd8',4),
 ('22440fa7-3162-59ed-8be6-df44dcd667ab','1162b13f-5474-5f20-95d5-d341d1fd7ec0',5),
 ('22440fa7-3162-59ed-8be6-df44dcd667ab','abcce57d-003d-5517-8d82-780e7f9c6ada',6),
 ('22440fa7-3162-59ed-8be6-df44dcd667ab','6512f6f3-630c-57d6-aec9-85652a8e14f5',7),
 ('22440fa7-3162-59ed-8be6-df44dcd667ab','abbb8f6a-13e4-5783-9e14-cc49018ede55',8),
 ('22440fa7-3162-59ed-8be6-df44dcd667ab','3bb80277-996b-51b8-9f3d-b1d91e09dd24',9),
 ('22440fa7-3162-59ed-8be6-df44dcd667ab','1cfa71c7-cfe7-5ed0-93de-65a4dcd2e66c',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('c9f64442-0b91-5bf5-ba27-496dd997fb1c','20000000-0000-0000-0000-000000000003',$p$le pain$p$,$p$el pan$p$,181,'sustantivo'),
 ('fb39b153-1d34-56f8-9afc-d1cd2b4442c5','20000000-0000-0000-0000-000000000003',$p$l'eau$p$,$p$el agua$p$,182,'sustantivo'),
 ('a44d53ee-d96a-5d2a-adbb-f0bd7cf95bf1','20000000-0000-0000-0000-000000000003',$p$le café$p$,$p$el café$p$,183,'sustantivo'),
 ('3ea49cb8-ab17-5852-8834-123cadd92f29','20000000-0000-0000-0000-000000000003',$p$le fromage$p$,$p$el queso$p$,184,'sustantivo'),
 ('2a40d4d6-ce5e-5b85-be8f-626831e69bc0','20000000-0000-0000-0000-000000000003',$p$la pomme$p$,$p$la manzana$p$,185,'sustantivo'),
 ('3fa4d983-6985-5506-be55-da8133fb5e60','20000000-0000-0000-0000-000000000003',$p$le poulet$p$,$p$el pollo$p$,186,'sustantivo'),
 ('bd8a2f92-e56d-594c-87ad-2878b46597de','20000000-0000-0000-0000-000000000003',$p$le lait$p$,$p$la leche$p$,187,'sustantivo'),
 ('b2578f32-2558-57c3-a162-83c4d54412d7','20000000-0000-0000-0000-000000000003',$p$la bière$p$,$p$la cerveza$p$,188,'sustantivo'),
 ('3693db08-316f-5320-88b2-4c3a2ccee35e','20000000-0000-0000-0000-000000000003',$p$l'addition$p$,$p$la cuenta$p$,189,'sustantivo'),
 ('4d907735-215e-5ad0-ab1f-398aee2ad1e6','20000000-0000-0000-0000-000000000003',$p$je voudrais$p$,$p$quisiera / querría$p$,190,'expresión'),
 ('4c3c7e20-c086-57b9-9df3-5f6b378616eb','20000000-0000-0000-0000-000000000003',$p$s'il vous plaît$p$,$p$por favor$p$,191,'expresión'),
 ('0b0dded1-9dd1-565d-b489-31d7f3da2e89','20000000-0000-0000-0000-000000000003',$p$du$p$,$p$algo de (partitivo masc.)$p$,192,'partitivo'),
 ('9b3b588f-01db-5eb4-bb98-ae969b681c4f','20000000-0000-0000-0000-000000000003',$p$de la$p$,$p$algo de (partitivo fem.)$p$,193,'partitivo'),
 ('1076ee59-c033-5805-97c8-bda492647d4c','20000000-0000-0000-0000-000000000003',$p$des$p$,$p$algunos/as (partitivo plural)$p$,194,'partitivo'),
 ('888354ab-e5eb-572d-b765-0b9f2f6dd40f','20000000-0000-0000-0000-000000000003',$p$combien$p$,$p$cuánto$p$,195,'adverbio'),
 ('f3517b71-2b83-5eb7-8865-5afde83cfc1a','20000000-0000-0000-0000-000000000003',$p$prendre$p$,$p$tomar$p$,196,'verbo')
on conflict (id) do nothing;

-- ── Unidad 5 (A1·fr): El día y la hora ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('af663647-ddbe-55c5-ad6e-10e2a020259c','20000000-0000-0000-0000-000000000003','A1',5,$p$El día y la hora$p$,'#16A085','schedule')
on conflict (course_id, order_index) do update set title=excluded.title, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('2514156f-e1d3-5e43-ada2-846288bed8bf','af663647-ddbe-55c5-ad6e-10e2a020259c',1,$p$¿Qué hora es?$p$,$p$¿Qué hora es?$p$,'lesson',15),
 ('cf70d298-f21f-55d1-bfcd-fddecfb08666','af663647-ddbe-55c5-ad6e-10e2a020259c',2,$p$Los días de la semana$p$,$p$Los días de la semana$p$,'lesson',15),
 ('560f0bbc-39d4-5531-8c8a-c83ee03ea2f0','af663647-ddbe-55c5-ad6e-10e2a020259c',3,$p$Verbos en -ER (presente)$p$,$p$Verbos en -ER (presente)$p$,'lesson',15),
 ('d26fd61b-c649-53c3-b877-aa3bd3b4b0bc','af663647-ddbe-55c5-ad6e-10e2a020259c',4,$p$Mi rutina diaria$p$,$p$Mi rutina diaria$p$,'lesson',15),
 ('5be44929-0595-55fb-92cb-6864aa036cbf','af663647-ddbe-55c5-ad6e-10e2a020259c',5,$p$🏁 Checkpoint Unité 5$p$,$p$Demuestra que sabes decir la hora, los días de la semana y conjugar verbos regulares en -ER para hablar de tu rutina.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('64a74bfc-2fb4-5907-8f7f-af844b8fe9b8','20000000-0000-0000-0000-000000000003','checkpoint','A1','af663647-ddbe-55c5-ad6e-10e2a020259c',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('6e4d04ab-fff9-576f-9c02-8d56abe81cbf'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','reading','match',$p$Empareja cada hora en francés con su equivalente en español.$p$,$j${"pairs": [{"en": "une heure", "es": "la una"}, {"en": "trois heures", "es": "las tres"}, {"en": "midi", "es": "el mediodía"}]}$j$::jsonb,$j${"pairs": [["une heure", "la una"], ["trois heures", "las tres"], ["midi", "el mediodía"]]}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$la_hora$p$, $p$reading$p$]),
('4d810eb3-bb28-5a79-9317-db9bfb780fc3'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','reading','match',$p$Empareja cada día en francés con su equivalente en español.$p$,$j${"pairs": [{"en": "lundi", "es": "lunes"}, {"en": "mercredi", "es": "miércoles"}, {"en": "dimanche", "es": "domingo"}]}$j$::jsonb,$j${"pairs": [["lundi", "lunes"], ["mercredi", "miércoles"], ["dimanche", "domingo"]]}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$dias_semana$p$, $p$reading$p$]),
('c3cdbc8b-ad70-5167-857e-c557065f8505'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','reading','multiple_choice',$p$¿Cómo se pregunta '¿Qué hora es?' en francés?$p$,$j${"options": ["Quelle heure est-il ?", "Quel jour est-il ?", "Comment ça va ?"]}$j$::jsonb,$j${"value": "Quelle heure est-il ?"}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$la_hora$p$, $p$reading$p$]),
('198a7d19-44ce-5817-baa8-94830f0cac0f'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','reading','multiple_choice',$p$Son las tres y media. ¿Cuál es la forma correcta?$p$,$j${"options": ["Il est trois heures et demie.", "Il est trois heures et quart.", "Il est trois heures et midi."]}$j$::jsonb,$j${"value": "Il est trois heures et demie."}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$la_hora$p$, $p$reading$p$]),
('714d8480-e23c-568e-b6f8-7d8cad5af706'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','reading','multiple_choice',$p$Elige la conjugación correcta: 'Nous ___ français.' (parler)$p$,$j${"options": ["parlons", "parlez", "parlent"]}$j$::jsonb,$j${"value": "parlons"}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$verbos_er$p$, $p$reading$p$]),
('814313c1-1f37-5edf-b6a3-194e0094bcb9'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','reading','multiple_choice',$p$¿Qué significa 'le soir'?$p$,$j${"options": ["la tarde/noche", "la mañana", "el mediodía"]}$j$::jsonb,$j${"value": "la tarde/noche"}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$mi_rutina$p$, $p$reading$p$]),
('a4943ef4-aaa0-597b-8c46-13e886ec3e98'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','writing','cloze',$p$Completa con el verbo correcto: 'Il ___ deux heures.' (Son las dos.)$p$,$j${"text": "Il ___ deux heures."}$j$::jsonb,$j${"value": "est", "accepted": ["est"]}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$la_hora$p$, $p$writing$p$]),
('78f4d0d2-eb97-5a5d-98fd-37fb434e92a5'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','writing','cloze',$p$Completa la conjugación de 'manger': 'Je ___ une pomme.'$p$,$j${"text": "Je ___ une pomme."}$j$::jsonb,$j${"value": "mange", "accepted": ["mange"]}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$verbos_er$p$, $p$writing$p$]),
('65498569-52aa-5666-b59d-f7394a3be071'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','writing','translation',$p$Traduce al francés: 'Hoy es lunes.'$p$,$j${"source": "Hoy es lunes."}$j$::jsonb,$j${"value": "Aujourd'hui, c'est lundi.", "accepted": ["Aujourd'hui, c'est lundi.", "Aujourd'hui c'est lundi", "Aujourd'hui, c'est lundi", "C'est lundi aujourd'hui.", "Aujourd'hui c'est lundi."]}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$dias_semana$p$, $p$writing$p$]),
('d082f74e-fecd-5b54-8cb7-e2cff6030ae4'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','writing','translation',$p$Traduce al francés: 'Yo trabajo por la mañana.'$p$,$j${"source": "Yo trabajo por la mañana."}$j$::jsonb,$j${"value": "Je travaille le matin.", "accepted": ["Je travaille le matin.", "Je travaille le matin", "Le matin, je travaille."]}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$mi_rutina$p$, $p$writing$p$]),
('290fdc94-4c8b-5980-9054-b92eb45d0294'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','writing','word_bank',$p$Ordena las fichas para formar: 'Ella habla francés.'$p$,$j${"tiles": ["Elle", "parle", "français", "mange", "français."]}$j$::jsonb,$j${"value": "Elle parle français.", "sequence": ["Elle", "parle", "français."]}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$verbos_er$p$, $p$writing$p$]),
('ee6762d4-6974-5645-9581-de652c186dc8'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','writing','reorder',$p$Ordena las palabras para formar una frase correcta.$p$,$j${"tiles": ["Je", "mange", "à", "midi."]}$j$::jsonb,$j${"value": "Je mange à midi."}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$mi_rutina$p$, $p$writing$p$]),
('db0ecd86-0adc-571c-be01-06310b1123c4'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Il est une heure et quart.", "Il est une heure et demie.", "Il est deux heures et quart."], "say": "Il est une heure et quart.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/db0ecd86-0adc-571c-be01-06310b1123c4.mp3"}$j$::jsonb,$j${"value": "Il est une heure et quart."}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$la_hora$p$, $p$listening$p$]),
('3cef983d-151f-5e98-b252-963694045612'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Demain, c'est samedi.", "Demain, c'est mardi.", "Aujourd'hui, c'est samedi."], "say": "Demain, c'est samedi.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/3cef983d-151f-5e98-b252-963694045612.mp3"}$j$::jsonb,$j${"value": "Demain, c'est samedi."}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$dias_semana$p$, $p$listening$p$]),
('e31d4795-2397-51a7-b984-52deaf60d410'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Vous travaillez beaucoup.", "Nous travaillons beaucoup.", "Vous parlez beaucoup."], "say": "Vous travaillez beaucoup.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/e31d4795-2397-51a7-b984-52deaf60d410.mp3"}$j$::jsonb,$j${"value": "Vous travaillez beaucoup."}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$verbos_er$p$, $p$listening$p$]),
('2be43ec4-b547-5e1a-907c-bc8e50955660'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Je me lève à sept heures.", "Je me lève à six heures.", "Je mange à sept heures."], "say": "Je me lève à sept heures.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/2be43ec4-b547-5e1a-907c-bc8e50955660.mp3"}$j$::jsonb,$j${"value": "Je me lève à sept heures."}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$mi_rutina$p$, $p$listening$p$]),
('873372e1-fa87-581b-a799-a9c0ae0f1d56'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Il est midi et demi.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/873372e1-fa87-581b-a799-a9c0ae0f1d56.mp3"}$j$::jsonb,$j${"expected": "Il est midi et demi."}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$la_hora$p$, $p$speaking$p$]),
('6f8bb681-0e50-5587-88d1-e09b2405a932'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Nous aimons parler français.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/6f8bb681-0e50-5587-88d1-e09b2405a932.mp3"}$j$::jsonb,$j${"expected": "Nous aimons parler français."}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$verbos_er$p$, $p$speaking$p$]),
('928b7235-7ddc-5f41-85ae-705447b649da'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Le matin, je mange et je travaille.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/928b7235-7ddc-5f41-85ae-705447b649da.mp3"}$j$::jsonb,$j${"expected": "Le matin, je mange et je travaille."}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$mi_rutina$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('2514156f-e1d3-5e43-ada2-846288bed8bf','6e4d04ab-fff9-576f-9c02-8d56abe81cbf',1),
 ('2514156f-e1d3-5e43-ada2-846288bed8bf','c3cdbc8b-ad70-5167-857e-c557065f8505',2),
 ('2514156f-e1d3-5e43-ada2-846288bed8bf','198a7d19-44ce-5817-baa8-94830f0cac0f',3),
 ('2514156f-e1d3-5e43-ada2-846288bed8bf','a4943ef4-aaa0-597b-8c46-13e886ec3e98',4),
 ('2514156f-e1d3-5e43-ada2-846288bed8bf','db0ecd86-0adc-571c-be01-06310b1123c4',5),
 ('2514156f-e1d3-5e43-ada2-846288bed8bf','873372e1-fa87-581b-a799-a9c0ae0f1d56',6),
 ('cf70d298-f21f-55d1-bfcd-fddecfb08666','4d810eb3-bb28-5a79-9317-db9bfb780fc3',1),
 ('cf70d298-f21f-55d1-bfcd-fddecfb08666','65498569-52aa-5666-b59d-f7394a3be071',2),
 ('cf70d298-f21f-55d1-bfcd-fddecfb08666','3cef983d-151f-5e98-b252-963694045612',3),
 ('560f0bbc-39d4-5531-8c8a-c83ee03ea2f0','714d8480-e23c-568e-b6f8-7d8cad5af706',1),
 ('560f0bbc-39d4-5531-8c8a-c83ee03ea2f0','78f4d0d2-eb97-5a5d-98fd-37fb434e92a5',2),
 ('560f0bbc-39d4-5531-8c8a-c83ee03ea2f0','290fdc94-4c8b-5980-9054-b92eb45d0294',3),
 ('560f0bbc-39d4-5531-8c8a-c83ee03ea2f0','e31d4795-2397-51a7-b984-52deaf60d410',4),
 ('560f0bbc-39d4-5531-8c8a-c83ee03ea2f0','6f8bb681-0e50-5587-88d1-e09b2405a932',5),
 ('d26fd61b-c649-53c3-b877-aa3bd3b4b0bc','814313c1-1f37-5edf-b6a3-194e0094bcb9',1),
 ('d26fd61b-c649-53c3-b877-aa3bd3b4b0bc','d082f74e-fecd-5b54-8cb7-e2cff6030ae4',2),
 ('d26fd61b-c649-53c3-b877-aa3bd3b4b0bc','ee6762d4-6974-5645-9581-de652c186dc8',3),
 ('d26fd61b-c649-53c3-b877-aa3bd3b4b0bc','2be43ec4-b547-5e1a-907c-bc8e50955660',4),
 ('d26fd61b-c649-53c3-b877-aa3bd3b4b0bc','928b7235-7ddc-5f41-85ae-705447b649da',5),
 ('5be44929-0595-55fb-92cb-6864aa036cbf','6e4d04ab-fff9-576f-9c02-8d56abe81cbf',1),
 ('5be44929-0595-55fb-92cb-6864aa036cbf','4d810eb3-bb28-5a79-9317-db9bfb780fc3',2),
 ('5be44929-0595-55fb-92cb-6864aa036cbf','c3cdbc8b-ad70-5167-857e-c557065f8505',3),
 ('5be44929-0595-55fb-92cb-6864aa036cbf','a4943ef4-aaa0-597b-8c46-13e886ec3e98',4),
 ('5be44929-0595-55fb-92cb-6864aa036cbf','78f4d0d2-eb97-5a5d-98fd-37fb434e92a5',5),
 ('5be44929-0595-55fb-92cb-6864aa036cbf','65498569-52aa-5666-b59d-f7394a3be071',6),
 ('5be44929-0595-55fb-92cb-6864aa036cbf','db0ecd86-0adc-571c-be01-06310b1123c4',7),
 ('5be44929-0595-55fb-92cb-6864aa036cbf','3cef983d-151f-5e98-b252-963694045612',8),
 ('5be44929-0595-55fb-92cb-6864aa036cbf','873372e1-fa87-581b-a799-a9c0ae0f1d56',9),
 ('5be44929-0595-55fb-92cb-6864aa036cbf','6f8bb681-0e50-5587-88d1-e09b2405a932',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('155f122b-6f49-501f-8fed-40dfaa0a0369','20000000-0000-0000-0000-000000000003',$p$l'heure$p$,$p$la hora$p$,201,'sustantivo'),
 ('a3d36b9f-6f10-5ffe-b574-db1895f3b661','20000000-0000-0000-0000-000000000003',$p$midi$p$,$p$mediodía$p$,202,'sustantivo'),
 ('8e0c2d6d-f8b2-5642-b07d-d850f4e5c4a5','20000000-0000-0000-0000-000000000003',$p$minuit$p$,$p$medianoche$p$,203,'sustantivo'),
 ('6e7c0eb9-fdc3-51ae-8799-e0325185c972','20000000-0000-0000-0000-000000000003',$p$et demie$p$,$p$y media$p$,204,'expresión'),
 ('f0b08bff-dbdf-5425-aed6-67eec37f715a','20000000-0000-0000-0000-000000000003',$p$et quart$p$,$p$y cuarto$p$,205,'expresión'),
 ('2b22b1f6-f897-5dd2-ad72-bdd56c7117d4','20000000-0000-0000-0000-000000000003',$p$lundi$p$,$p$lunes$p$,206,'sustantivo'),
 ('8cc1191d-8765-5d00-8ed5-e8bac864b452','20000000-0000-0000-0000-000000000003',$p$mardi$p$,$p$martes$p$,207,'sustantivo'),
 ('7d2cca31-be51-56ef-b22d-b4d382570a6c','20000000-0000-0000-0000-000000000003',$p$mercredi$p$,$p$miércoles$p$,208,'sustantivo'),
 ('30b33579-3e69-54c8-97df-024dd98897be','20000000-0000-0000-0000-000000000003',$p$samedi$p$,$p$sábado$p$,209,'sustantivo'),
 ('1251c2ab-3082-59dc-8339-4db26610bf1f','20000000-0000-0000-0000-000000000003',$p$dimanche$p$,$p$domingo$p$,210,'sustantivo'),
 ('c40d9d0e-f8b4-55e4-a64c-ff247b2d9f30','20000000-0000-0000-0000-000000000003',$p$aujourd'hui$p$,$p$hoy$p$,211,'adverbio'),
 ('c733e2b0-cef6-55a0-ad36-18c93c9d9898','20000000-0000-0000-0000-000000000003',$p$demain$p$,$p$mañana$p$,212,'adverbio'),
 ('1a775ebb-2701-5907-a655-4b643fb03d36','20000000-0000-0000-0000-000000000003',$p$parler$p$,$p$hablar$p$,213,'verbo'),
 ('fb511260-a2b9-57d7-a186-536c47ef0684','20000000-0000-0000-0000-000000000003',$p$manger$p$,$p$comer$p$,214,'verbo'),
 ('cfad9cac-6239-5931-9bec-5d1d89c6c04e','20000000-0000-0000-0000-000000000003',$p$travailler$p$,$p$trabajar$p$,215,'verbo'),
 ('4bafa8d2-7b84-5f15-b4aa-5c7e6d04516e','20000000-0000-0000-0000-000000000003',$p$le matin$p$,$p$la mañana$p$,216,'sustantivo')
on conflict (id) do nothing;

-- ── Unidad 6 (A1·fr): Lugares y direcciones ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('d235015a-84e9-5cb7-bcee-921a11519626','20000000-0000-0000-0000-000000000003','A1',6,$p$Lugares y direcciones$p$,'#2980B9','place')
on conflict (course_id, order_index) do update set title=excluded.title, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('b8b89e56-6ded-5acd-8a0e-40c47f6db4c7','d235015a-84e9-5cb7-bcee-921a11519626',1,$p$Lugares de la ciudad$p$,$p$Lugares de la ciudad$p$,'lesson',15),
 ('6df20637-4cd0-5f5e-97de-d8823f7b462b','d235015a-84e9-5cb7-bcee-921a11519626',2,$p$¿Dónde está? / Hay...$p$,$p$¿Dónde está? / Hay...$p$,'lesson',15),
 ('0ec70b87-56ba-5824-b31c-00a2d8cc0545','d235015a-84e9-5cb7-bcee-921a11519626',3,$p$Dar direcciones$p$,$p$Dar direcciones$p$,'lesson',15),
 ('af26cbc6-e9b8-516d-8552-aa92fa4a55df','d235015a-84e9-5cb7-bcee-921a11519626',4,$p$Las contracciones (au, du, des)$p$,$p$Las contracciones (au, du, des)$p$,'lesson',15),
 ('2937a453-263f-5e22-ab76-e91f51a00ae9','d235015a-84e9-5cb7-bcee-921a11519626',5,$p$🏁 Checkpoint Unité 6$p$,$p$Demuestra que sabes nombrar lugares de la ciudad, preguntar dónde están, dar direcciones y usar las contracciones (au, du, des).$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('9c43d8a5-5e06-5723-91b1-5ae4cf33b795','20000000-0000-0000-0000-000000000003','checkpoint','A1','d235015a-84e9-5cb7-bcee-921a11519626',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('847d91e4-5325-5c5c-b6a0-65b7883d2f15'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','reading','match',$p$Empareja cada lugar en francés con su equivalente en español.$p$,$j${"pairs": [{"en": "la gare", "es": "la estación"}, {"en": "la banque", "es": "el banco"}, {"en": "le musée", "es": "el museo"}]}$j$::jsonb,$j${"pairs": [["la gare", "la estación"], ["la banque", "el banco"], ["le musée", "el museo"]]}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$lugares_ciudad$p$, $p$reading$p$]),
('f173057b-abec-5c35-8420-56969aa8e3a0'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','reading','match',$p$Empareja cada indicación en francés con su equivalente en español.$p$,$j${"pairs": [{"en": "à gauche", "es": "a la izquierda"}, {"en": "à droite", "es": "a la derecha"}, {"en": "tout droit", "es": "todo recto"}]}$j$::jsonb,$j${"pairs": [["à gauche", "a la izquierda"], ["à droite", "a la derecha"], ["tout droit", "todo recto"]]}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$direcciones$p$, $p$reading$p$]),
('f0433014-2186-54ec-88f7-25ba99a936ac'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','reading','multiple_choice',$p$¿Qué significa 'la pharmacie'?$p$,$j${"options": ["la farmacia", "la estación", "el restaurante"]}$j$::jsonb,$j${"value": "la farmacia"}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$lugares_ciudad$p$, $p$reading$p$]),
('372b6cb9-58eb-5f8d-ad18-58f50fb382e3'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','reading','multiple_choice',$p$¿Cómo se dice 'Hay un banco aquí'?$p$,$j${"options": ["Il y a une banque ici.", "Où est la banque ?", "C'est une banque ici."]}$j$::jsonb,$j${"value": "Il y a une banque ici."}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$donde_esta$p$, $p$reading$p$]),
('40a9241b-8bc0-536f-970d-1dc55de4b8f2'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','reading','multiple_choice',$p$¿Qué significa 'en face de la gare'?$p$,$j${"options": ["enfrente de la estación", "al lado de la estación", "lejos de la estación"]}$j$::jsonb,$j${"value": "enfrente de la estación"}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$direcciones$p$, $p$reading$p$]),
('2d8df257-e703-506f-8ba6-eebe01b35a10'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','reading','multiple_choice',$p$Elige la contracción correcta: 'Je vais ___ restaurant.' (à + le)$p$,$j${"options": ["au", "à le", "du"]}$j$::jsonb,$j${"value": "au"}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$contracciones$p$, $p$reading$p$]),
('3b2af7d1-28e3-5a34-80dd-8f82cd9ee01f'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','writing','cloze',$p$Completa para preguntar 'dónde': '___ est la pharmacie ?'$p$,$j${"text": "___ est la pharmacie ?"}$j$::jsonb,$j${"value": "Où", "accepted": ["Où", "où"]}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$donde_esta$p$, $p$writing$p$]),
('009c1a44-d356-5261-b4b4-2b2c6a8955d1'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','writing','cloze',$p$Completa con la contracción (à + le): 'Le café est à côté ___ musée.'$p$,$j${"text": "Le café est à côté ___ musée."}$j$::jsonb,$j${"value": "du", "accepted": ["du"]}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$contracciones$p$, $p$writing$p$]),
('d8792535-19ff-56c8-8e29-ea5b2fe49106'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','writing','translation',$p$Traduce al francés: 'El hotel está cerca de la estación.'$p$,$j${"source": "El hotel está cerca de la estación."}$j$::jsonb,$j${"value": "L'hôtel est près de la gare.", "accepted": ["L'hôtel est près de la gare.", "L'hôtel est près de la gare", "L'hotel est près de la gare."]}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$lugares_ciudad$p$, $p$writing$p$]),
('a4707299-5934-5471-9aea-89256d1a2a51'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','writing','translation',$p$Traduce al francés: 'El banco está a la derecha.'$p$,$j${"source": "El banco está a la derecha."}$j$::jsonb,$j${"value": "La banque est à droite.", "accepted": ["La banque est à droite.", "La banque est à droite"]}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$direcciones$p$, $p$writing$p$]),
('d058945a-fa6a-572c-9dc4-5d68a1169034'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','writing','word_bank',$p$Ordena las fichas para formar: 'Voy al restaurante.'$p$,$j${"tiles": ["Je", "vais", "au", "restaurant.", "du", "à"]}$j$::jsonb,$j${"value": "Je vais au restaurant.", "sequence": ["Je", "vais", "au", "restaurant."]}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$contracciones$p$, $p$writing$p$]),
('e1adb7f2-93bc-5c17-9da5-b176c74a2712'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','writing','reorder',$p$Ordena las palabras para formar una frase correcta.$p$,$j${"tiles": ["La", "pharmacie", "est", "à", "gauche."]}$j$::jsonb,$j${"value": "La pharmacie est à gauche."}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$direcciones$p$, $p$writing$p$]),
('96b689a6-1949-5842-933f-45c919a62193'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Le musée est dans la rue.", "Le musée est dans la gare.", "La banque est dans la rue."], "say": "Le musée est dans la rue.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/96b689a6-1949-5842-933f-45c919a62193.mp3"}$j$::jsonb,$j${"value": "Le musée est dans la rue."}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$lugares_ciudad$p$, $p$listening$p$]),
('ffcc2aa7-a293-5052-a90a-10b7761b595f'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Où est l'hôtel ?", "Où est la gare ?", "Où sont les hôtels ?"], "say": "Où est l'hôtel ?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/ffcc2aa7-a293-5052-a90a-10b7761b595f.mp3"}$j$::jsonb,$j${"value": "Où est l'hôtel ?"}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$donde_esta$p$, $p$listening$p$]),
('d508b955-8bdd-5a2e-900c-49da44377746'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Continuez tout droit.", "Continuez à droite.", "Continuez à gauche."], "say": "Continuez tout droit.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/d508b955-8bdd-5a2e-900c-49da44377746.mp3"}$j$::jsonb,$j${"value": "Continuez tout droit."}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$direcciones$p$, $p$listening$p$]),
('a6d8972e-3349-5249-9437-0ef7bca6ed91'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Le restaurant est en face du musée.", "Le restaurant est à côté du musée.", "Le restaurant est en face de la gare."], "say": "Le restaurant est en face du musée.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/a6d8972e-3349-5249-9437-0ef7bca6ed91.mp3"}$j$::jsonb,$j${"value": "Le restaurant est en face du musée."}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$contracciones$p$, $p$listening$p$]),
('e3142784-351d-5a99-831f-551e57a6ae83'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "La gare est loin de l'hôtel.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/e3142784-351d-5a99-831f-551e57a6ae83.mp3"}$j$::jsonb,$j${"expected": "La gare est loin de l'hôtel."}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$lugares_ciudad$p$, $p$speaking$p$]),
('846732b0-ec88-5e37-92eb-502b3849daa4'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Il y a une pharmacie près d'ici.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/846732b0-ec88-5e37-92eb-502b3849daa4.mp3"}$j$::jsonb,$j${"expected": "Il y a une pharmacie près d'ici."}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$donde_esta$p$, $p$speaking$p$]),
('f85ebda3-6d6e-5821-a39b-86fb5e4be470'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Je vais au restaurant à côté du musée.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/f85ebda3-6d6e-5821-a39b-86fb5e4be470.mp3"}$j$::jsonb,$j${"expected": "Je vais au restaurant à côté du musée."}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$contracciones$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('b8b89e56-6ded-5acd-8a0e-40c47f6db4c7','847d91e4-5325-5c5c-b6a0-65b7883d2f15',1),
 ('b8b89e56-6ded-5acd-8a0e-40c47f6db4c7','f0433014-2186-54ec-88f7-25ba99a936ac',2),
 ('b8b89e56-6ded-5acd-8a0e-40c47f6db4c7','d8792535-19ff-56c8-8e29-ea5b2fe49106',3),
 ('b8b89e56-6ded-5acd-8a0e-40c47f6db4c7','96b689a6-1949-5842-933f-45c919a62193',4),
 ('b8b89e56-6ded-5acd-8a0e-40c47f6db4c7','e3142784-351d-5a99-831f-551e57a6ae83',5),
 ('6df20637-4cd0-5f5e-97de-d8823f7b462b','372b6cb9-58eb-5f8d-ad18-58f50fb382e3',1),
 ('6df20637-4cd0-5f5e-97de-d8823f7b462b','3b2af7d1-28e3-5a34-80dd-8f82cd9ee01f',2),
 ('6df20637-4cd0-5f5e-97de-d8823f7b462b','ffcc2aa7-a293-5052-a90a-10b7761b595f',3),
 ('6df20637-4cd0-5f5e-97de-d8823f7b462b','846732b0-ec88-5e37-92eb-502b3849daa4',4),
 ('0ec70b87-56ba-5824-b31c-00a2d8cc0545','f173057b-abec-5c35-8420-56969aa8e3a0',1),
 ('0ec70b87-56ba-5824-b31c-00a2d8cc0545','40a9241b-8bc0-536f-970d-1dc55de4b8f2',2),
 ('0ec70b87-56ba-5824-b31c-00a2d8cc0545','a4707299-5934-5471-9aea-89256d1a2a51',3),
 ('0ec70b87-56ba-5824-b31c-00a2d8cc0545','e1adb7f2-93bc-5c17-9da5-b176c74a2712',4),
 ('0ec70b87-56ba-5824-b31c-00a2d8cc0545','d508b955-8bdd-5a2e-900c-49da44377746',5),
 ('af26cbc6-e9b8-516d-8552-aa92fa4a55df','2d8df257-e703-506f-8ba6-eebe01b35a10',1),
 ('af26cbc6-e9b8-516d-8552-aa92fa4a55df','009c1a44-d356-5261-b4b4-2b2c6a8955d1',2),
 ('af26cbc6-e9b8-516d-8552-aa92fa4a55df','d058945a-fa6a-572c-9dc4-5d68a1169034',3),
 ('af26cbc6-e9b8-516d-8552-aa92fa4a55df','a6d8972e-3349-5249-9437-0ef7bca6ed91',4),
 ('af26cbc6-e9b8-516d-8552-aa92fa4a55df','f85ebda3-6d6e-5821-a39b-86fb5e4be470',5),
 ('2937a453-263f-5e22-ab76-e91f51a00ae9','847d91e4-5325-5c5c-b6a0-65b7883d2f15',1),
 ('2937a453-263f-5e22-ab76-e91f51a00ae9','f173057b-abec-5c35-8420-56969aa8e3a0',2),
 ('2937a453-263f-5e22-ab76-e91f51a00ae9','f0433014-2186-54ec-88f7-25ba99a936ac',3),
 ('2937a453-263f-5e22-ab76-e91f51a00ae9','3b2af7d1-28e3-5a34-80dd-8f82cd9ee01f',4),
 ('2937a453-263f-5e22-ab76-e91f51a00ae9','009c1a44-d356-5261-b4b4-2b2c6a8955d1',5),
 ('2937a453-263f-5e22-ab76-e91f51a00ae9','d8792535-19ff-56c8-8e29-ea5b2fe49106',6),
 ('2937a453-263f-5e22-ab76-e91f51a00ae9','96b689a6-1949-5842-933f-45c919a62193',7),
 ('2937a453-263f-5e22-ab76-e91f51a00ae9','ffcc2aa7-a293-5052-a90a-10b7761b595f',8),
 ('2937a453-263f-5e22-ab76-e91f51a00ae9','e3142784-351d-5a99-831f-551e57a6ae83',9),
 ('2937a453-263f-5e22-ab76-e91f51a00ae9','846732b0-ec88-5e37-92eb-502b3849daa4',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('504f2046-538b-5bed-9138-0113a589aa81','20000000-0000-0000-0000-000000000003',$p$la gare$p$,$p$la estación$p$,221,'sustantivo'),
 ('b321acd9-eb08-5542-a878-bee6a2fdcf3e','20000000-0000-0000-0000-000000000003',$p$l'hôtel$p$,$p$el hotel$p$,222,'sustantivo'),
 ('0d0925a1-bd51-569e-97cd-835ea3df0cac','20000000-0000-0000-0000-000000000003',$p$la banque$p$,$p$el banco$p$,223,'sustantivo'),
 ('5d17760f-ad2b-5e52-b1c9-273d600d6d16','20000000-0000-0000-0000-000000000003',$p$la rue$p$,$p$la calle$p$,224,'sustantivo'),
 ('ecc024cc-c918-5b12-ace0-dcc6fd9eb154','20000000-0000-0000-0000-000000000003',$p$le restaurant$p$,$p$el restaurante$p$,225,'sustantivo'),
 ('bd6d1236-e149-5264-adb9-a4c9b79d3c05','20000000-0000-0000-0000-000000000003',$p$le musée$p$,$p$el museo$p$,226,'sustantivo'),
 ('adb889e4-27e2-5534-8af8-d0df26dc0e46','20000000-0000-0000-0000-000000000003',$p$la pharmacie$p$,$p$la farmacia$p$,227,'sustantivo'),
 ('eb4e13fc-f9d2-51ee-9848-34a730ca1fb3','20000000-0000-0000-0000-000000000003',$p$à gauche$p$,$p$a la izquierda$p$,228,'expresión'),
 ('d33c2599-4113-5cf7-8f8a-1d45f3ea57d7','20000000-0000-0000-0000-000000000003',$p$à droite$p$,$p$a la derecha$p$,229,'expresión'),
 ('bbb412a9-35a8-528e-a598-af91fd18ff19','20000000-0000-0000-0000-000000000003',$p$tout droit$p$,$p$todo recto$p$,230,'expresión'),
 ('fb256560-e093-5845-8b57-0d3185c3007a','20000000-0000-0000-0000-000000000003',$p$à côté de$p$,$p$al lado de$p$,231,'expresión'),
 ('35d71d8d-c316-5a12-9656-4c1552ebe2fe','20000000-0000-0000-0000-000000000003',$p$en face de$p$,$p$enfrente de$p$,232,'expresión'),
 ('3c640a42-2f54-57d7-a353-d5cf39326b32','20000000-0000-0000-0000-000000000003',$p$près de$p$,$p$cerca de$p$,233,'expresión'),
 ('e51be4d8-f147-553c-967a-4ac1a73d21a0','20000000-0000-0000-0000-000000000003',$p$loin de$p$,$p$lejos de$p$,234,'expresión'),
 ('869526b5-94cd-5c99-8936-3979070078a7','20000000-0000-0000-0000-000000000003',$p$il y a$p$,$p$hay$p$,235,'expresión'),
 ('7a577f0b-3bbf-5ddc-98c3-52cdb374b9df','20000000-0000-0000-0000-000000000003',$p$où$p$,$p$dónde$p$,236,'adverbio')
on conflict (id) do nothing;

commit;