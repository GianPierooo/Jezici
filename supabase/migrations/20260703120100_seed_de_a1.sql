-- 20260703120100_seed_de_a1.sql
-- Currículo A1 del curso es→de (6 unidades). Molde es→pt.
-- Contenido scopeado a course_id=20000000-0000-0000-0000-000000000005 → aislamiento multicurso por
-- jz_active_course. Unidades order_index continúan la cadena → gating al nivel previo.
begin;
insert into languages (id, code, name) values
  ('10000000-0000-0000-0000-000000000006','de',$p$Deutsch$p$) on conflict (id) do nothing;
insert into courses (id, source_language_id, target_language_id, is_active) values
  ('20000000-0000-0000-0000-000000000005','10000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000006',true) on conflict (id) do nothing;

-- ── Unidad 1 (A1·de): Saludos y presentarte ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('41a37787-ecba-538d-8b74-8fb8ff309a0f','20000000-0000-0000-0000-000000000005','A1',1,$p$Saludos y presentarte$p$,'#C0392B','waving_hand')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('1400aa25-5880-56b2-b4f7-b275b1f43ac7','41a37787-ecba-538d-8b74-8fb8ff309a0f',1,$p$Hola y adiós$p$,$p$Hola y adiós$p$,'lesson',15),
 ('9efd2401-14d2-52d7-8284-30520d150f81','41a37787-ecba-538d-8b74-8fb8ff309a0f',2,$p$Me llamo...$p$,$p$Me llamo...$p$,'lesson',15),
 ('58dcd3f4-5d9a-57b3-a58a-7d772c3404db','41a37787-ecba-538d-8b74-8fb8ff309a0f',3,$p$El verbo sein$p$,$p$El verbo sein$p$,'lesson',15),
 ('681e5883-83fe-5056-bdbc-8f7993d709f7','41a37787-ecba-538d-8b74-8fb8ff309a0f',4,$p$¿Cómo estás?$p$,$p$¿Cómo estás?$p$,'lesson',15),
 ('6d31ce4f-a1b5-59ce-abfb-326547a17749','41a37787-ecba-538d-8b74-8fb8ff309a0f',5,$p$🏁 Checkpoint Einheit 1$p$,$p$Saludar, despedirte, decir tu nombre y usar el verbo sein para presentarte.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('a1e9b570-5d2f-547b-b6ad-71d94e37f282','20000000-0000-0000-0000-000000000005','checkpoint','A1','41a37787-ecba-538d-8b74-8fb8ff309a0f',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('d418d31e-c13d-53ab-8e67-4b1e2f2733de'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','reading','match',$p$Une cada saludo o despedida con su significado.$p$,$j${"pairs": [{"en": "Hallo", "es": "hola"}, {"en": "Tschüss", "es": "adiós"}, {"en": "Guten Morgen", "es": "buenos días"}]}$j$::jsonb,$j${"pairs": [["Hallo", "hola"], ["Tschüss", "adiós"], ["Guten Morgen", "buenos días"]]}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$saludos$p$, $p$reading$p$]),
('71a01a23-4251-51fa-9f0d-24db087caeeb'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','reading','match',$p$Une cada palabra con su significado.$p$,$j${"pairs": [{"en": "danke", "es": "gracias"}, {"en": "gut", "es": "bien"}, {"en": "ja", "es": "sí"}]}$j$::jsonb,$j${"pairs": [["danke", "gracias"], ["gut", "bien"], ["ja", "sí"]]}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$cortesia$p$, $p$reading$p$]),
('cf4b1d02-7b51-51e7-adab-cfbc0913540d'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','reading','multiple_choice',$p$¿Cómo se dice 'buenas noches' al llegar por la tarde/noche?$p$,$j${"options": ["Guten Abend", "Guten Morgen", "Tschüss"]}$j$::jsonb,$j${"value": "Guten Abend"}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$saludos$p$, $p$reading$p$]),
('7e46a782-45af-5e56-9efe-9829d69e9dbb'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','reading','multiple_choice',$p$¿Qué usarías para despedirte de un amigo de forma informal?$p$,$j${"options": ["Tschüss", "Hallo", "Guten Tag"]}$j$::jsonb,$j${"value": "Tschüss"}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$saludos$p$, $p$reading$p$]),
('37616689-ef79-5eea-b89c-8213d4749b68'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','reading','multiple_choice',$p$¿Cuál es la pregunta FORMAL para preguntar el nombre (a un desconocido)?$p$,$j${"options": ["Wie heißen Sie?", "Wie heißt du?", "Wie geht es dir?"]}$j$::jsonb,$j${"value": "Wie heißen Sie?"}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$presentarse$p$, $p$reading$p$]),
('a1ca9f9f-1eab-5b22-b5de-350f8995e919'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','reading','multiple_choice',$p$Completa correctamente: 'Er ___ Max.' (él)$p$,$j${"options": ["ist", "bin", "bist"]}$j$::jsonb,$j${"value": "ist"}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$verbo_sein$p$, $p$reading$p$]),
('4c2ae8db-073f-5ca8-be5a-aafcfca5d313'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','writing','cloze',$p$Completa: 'Me llamo Anna.'$p$,$j${"text": "Ich ___ Anna."}$j$::jsonb,$j${"value": "heiße", "accepted": ["heiße", "heisse"]}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$presentarse$p$, $p$writing$p$]),
('3a45edf0-e973-5d85-8566-2f587c444cb4'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','writing','cloze',$p$Completa con el verbo sein: 'Yo soy Tom.'$p$,$j${"text": "Ich ___ Tom."}$j$::jsonb,$j${"value": "bin", "accepted": ["bin"]}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$verbo_sein$p$, $p$writing$p$]),
('12e5704c-e76e-5204-898b-a69149d9bed9'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','writing','translation',$p$Traduce: Me llamo Peter.$p$,$j${"source": "Me llamo Peter."}$j$::jsonb,$j${"value": "Ich heiße Peter.", "accepted": ["Ich heiße Peter.", "Ich heiße Peter", "Ich heisse Peter.", "Ich heisse Peter"]}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$presentarse$p$, $p$writing$p$]),
('5d88e697-b4f2-54f6-8e18-1c01dd5bc4a2'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','writing','translation',$p$Traduce: Bien, gracias.$p$,$j${"source": "Bien, gracias."}$j$::jsonb,$j${"value": "Gut, danke.", "accepted": ["Gut, danke.", "Gut, danke", "Gut danke", "Danke, gut.", "Danke, gut"]}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$estado$p$, $p$writing$p$]),
('19d88156-edbc-50c1-b03f-e0bdc0ac3ec5'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','writing','word_bank',$p$Ordena: '¿Cómo te llamas?' (informal)$p$,$j${"tiles": ["Wie", "heißt", "du", "Sie", "bist"]}$j$::jsonb,$j${"value": "Wie heißt du", "sequence": ["Wie", "heißt", "du"]}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$verbo_sein$p$, $p$writing$p$]),
('f422e69c-0d68-5684-b659-ccf44b3a38d9'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','writing','reorder',$p$Ordena la frase: '¿Cómo estás?' (informal)$p$,$j${"tiles": ["es", "Wie", "dir", "geht"]}$j$::jsonb,$j${"value": "Wie geht es dir"}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$estado$p$, $p$writing$p$]),
('4b5b20a5-0cfe-5b55-8317-466a823a7450'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Guten Tag!", "Guten Abend!", "Gute Nacht!"], "say": "Guten Tag!", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/4b5b20a5-0cfe-5b55-8317-466a823a7450.mp3"}$j$::jsonb,$j${"value": "Guten Tag!"}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$saludos$p$, $p$listening$p$]),
('071520b5-efa5-52ee-ae17-8a72cd84751f'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ich heiße Julia.", "Ich heiße Laura.", "Ich bin Julia."], "say": "Ich heiße Julia.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/071520b5-efa5-52ee-ae17-8a72cd84751f.mp3"}$j$::jsonb,$j${"value": "Ich heiße Julia."}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$presentarse$p$, $p$listening$p$]),
('f69166e1-6a9a-58dd-b98d-82fd21cae993'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Du bist nett.", "Ich bin nett.", "Er ist nett."], "say": "Du bist nett.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/f69166e1-6a9a-58dd-b98d-82fd21cae993.mp3"}$j$::jsonb,$j${"value": "Du bist nett."}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$verbo_sein$p$, $p$listening$p$]),
('c071d063-8d64-5a78-b1ad-005235da27ca'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Wie geht es dir?", "Wie heißt du?", "Wie geht es Ihnen?"], "say": "Wie geht es dir?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/c071d063-8d64-5a78-b1ad-005235da27ca.mp3"}$j$::jsonb,$j${"value": "Wie geht es dir?"}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$estado$p$, $p$listening$p$]),
('9c7286cb-77c9-5dad-9949-21dd620e8078'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Gut, danke.", "Gute Nacht.", "Guten Tag."], "say": "Gut, danke.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/9c7286cb-77c9-5dad-9949-21dd620e8078.mp3"}$j$::jsonb,$j${"value": "Gut, danke."}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$estado$p$, $p$listening$p$]),
('b98c69b9-76d0-55b0-8a01-d0ed8f0b4211'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Hallo, guten Morgen!", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/b98c69b9-76d0-55b0-8a01-d0ed8f0b4211.mp3"}$j$::jsonb,$j${"expected": "Hallo, guten Morgen!"}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$saludos$p$, $p$speaking$p$]),
('e8fc59fa-1622-5554-bc69-073be6cf1536'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Ich heiße Anna.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/e8fc59fa-1622-5554-bc69-073be6cf1536.mp3"}$j$::jsonb,$j${"expected": "Ich heiße Anna."}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$presentarse$p$, $p$speaking$p$]),
('0b263c94-6f95-55e8-8a6a-369145b11e51'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Mir geht es gut, danke.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/0b263c94-6f95-55e8-8a6a-369145b11e51.mp3"}$j$::jsonb,$j${"expected": "Mir geht es gut, danke."}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$estado$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('1400aa25-5880-56b2-b4f7-b275b1f43ac7','d418d31e-c13d-53ab-8e67-4b1e2f2733de',1),
 ('1400aa25-5880-56b2-b4f7-b275b1f43ac7','cf4b1d02-7b51-51e7-adab-cfbc0913540d',2),
 ('1400aa25-5880-56b2-b4f7-b275b1f43ac7','7e46a782-45af-5e56-9efe-9829d69e9dbb',3),
 ('1400aa25-5880-56b2-b4f7-b275b1f43ac7','4b5b20a5-0cfe-5b55-8317-466a823a7450',4),
 ('1400aa25-5880-56b2-b4f7-b275b1f43ac7','b98c69b9-76d0-55b0-8a01-d0ed8f0b4211',5),
 ('9efd2401-14d2-52d7-8284-30520d150f81','37616689-ef79-5eea-b89c-8213d4749b68',1),
 ('9efd2401-14d2-52d7-8284-30520d150f81','4c2ae8db-073f-5ca8-be5a-aafcfca5d313',2),
 ('9efd2401-14d2-52d7-8284-30520d150f81','12e5704c-e76e-5204-898b-a69149d9bed9',3),
 ('9efd2401-14d2-52d7-8284-30520d150f81','071520b5-efa5-52ee-ae17-8a72cd84751f',4),
 ('9efd2401-14d2-52d7-8284-30520d150f81','e8fc59fa-1622-5554-bc69-073be6cf1536',5),
 ('58dcd3f4-5d9a-57b3-a58a-7d772c3404db','a1ca9f9f-1eab-5b22-b5de-350f8995e919',1),
 ('58dcd3f4-5d9a-57b3-a58a-7d772c3404db','3a45edf0-e973-5d85-8566-2f587c444cb4',2),
 ('58dcd3f4-5d9a-57b3-a58a-7d772c3404db','19d88156-edbc-50c1-b03f-e0bdc0ac3ec5',3),
 ('58dcd3f4-5d9a-57b3-a58a-7d772c3404db','f69166e1-6a9a-58dd-b98d-82fd21cae993',4),
 ('681e5883-83fe-5056-bdbc-8f7993d709f7','71a01a23-4251-51fa-9f0d-24db087caeeb',1),
 ('681e5883-83fe-5056-bdbc-8f7993d709f7','5d88e697-b4f2-54f6-8e18-1c01dd5bc4a2',2),
 ('681e5883-83fe-5056-bdbc-8f7993d709f7','f422e69c-0d68-5684-b659-ccf44b3a38d9',3),
 ('681e5883-83fe-5056-bdbc-8f7993d709f7','c071d063-8d64-5a78-b1ad-005235da27ca',4),
 ('681e5883-83fe-5056-bdbc-8f7993d709f7','9c7286cb-77c9-5dad-9949-21dd620e8078',5),
 ('681e5883-83fe-5056-bdbc-8f7993d709f7','0b263c94-6f95-55e8-8a6a-369145b11e51',6),
 ('6d31ce4f-a1b5-59ce-abfb-326547a17749','d418d31e-c13d-53ab-8e67-4b1e2f2733de',1),
 ('6d31ce4f-a1b5-59ce-abfb-326547a17749','71a01a23-4251-51fa-9f0d-24db087caeeb',2),
 ('6d31ce4f-a1b5-59ce-abfb-326547a17749','cf4b1d02-7b51-51e7-adab-cfbc0913540d',3),
 ('6d31ce4f-a1b5-59ce-abfb-326547a17749','4c2ae8db-073f-5ca8-be5a-aafcfca5d313',4),
 ('6d31ce4f-a1b5-59ce-abfb-326547a17749','3a45edf0-e973-5d85-8566-2f587c444cb4',5),
 ('6d31ce4f-a1b5-59ce-abfb-326547a17749','12e5704c-e76e-5204-898b-a69149d9bed9',6),
 ('6d31ce4f-a1b5-59ce-abfb-326547a17749','4b5b20a5-0cfe-5b55-8317-466a823a7450',7),
 ('6d31ce4f-a1b5-59ce-abfb-326547a17749','071520b5-efa5-52ee-ae17-8a72cd84751f',8),
 ('6d31ce4f-a1b5-59ce-abfb-326547a17749','b98c69b9-76d0-55b0-8a01-d0ed8f0b4211',9),
 ('6d31ce4f-a1b5-59ce-abfb-326547a17749','e8fc59fa-1622-5554-bc69-073be6cf1536',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('8b1e4c2b-9dc9-5ce5-bcd4-b5e33ed42e83','20000000-0000-0000-0000-000000000005',$p$Hallo$p$,$p$hola$p$,121,'interjeccion'),
 ('9b431415-acb3-5069-a99d-3163410dc0fd','20000000-0000-0000-0000-000000000005',$p$Guten Morgen$p$,$p$buenos días (mañana)$p$,122,'expresion'),
 ('feead528-618b-54b9-88a3-cb7e297fcef6','20000000-0000-0000-0000-000000000005',$p$Guten Tag$p$,$p$buenos días / buenas tardes$p$,123,'expresion'),
 ('9a4304fc-da04-5c3a-b0cd-eb6adff63239','20000000-0000-0000-0000-000000000005',$p$Guten Abend$p$,$p$buenas noches (al llegar)$p$,124,'expresion'),
 ('0a8a7c68-a535-58f2-bf26-6871915cf5ae','20000000-0000-0000-0000-000000000005',$p$Tschüss$p$,$p$adiós (informal)$p$,125,'interjeccion'),
 ('9286c317-826e-570c-b7a7-3d7ddeabfc30','20000000-0000-0000-0000-000000000005',$p$Auf Wiedersehen$p$,$p$hasta la vista (formal)$p$,126,'expresion'),
 ('0c1cdb3a-e203-54bb-9da9-d98431e0c64f','20000000-0000-0000-0000-000000000005',$p$ich$p$,$p$yo$p$,127,'pronombre'),
 ('1b03a1cc-72a4-5f75-9b6f-d191fb51b457','20000000-0000-0000-0000-000000000005',$p$du$p$,$p$tú$p$,128,'pronombre'),
 ('d79a71a9-018d-5787-83ab-fd00bb6f27ce','20000000-0000-0000-0000-000000000005',$p$Sie$p$,$p$usted$p$,129,'pronombre'),
 ('ebc02eb5-c5c4-591e-93d4-07569e5c9efb','20000000-0000-0000-0000-000000000005',$p$heißen$p$,$p$llamarse$p$,130,'verbo'),
 ('a08b46db-86d6-592e-bf2d-0d5e7580b142','20000000-0000-0000-0000-000000000005',$p$sein$p$,$p$ser / estar$p$,131,'verbo'),
 ('ab8e5ed8-fdda-5736-a69a-7d51f38fc582','20000000-0000-0000-0000-000000000005',$p$der Name$p$,$p$el nombre$p$,132,'sustantivo'),
 ('ddb519c7-a8a2-5e44-9801-53c414554def','20000000-0000-0000-0000-000000000005',$p$gut$p$,$p$bien / bueno$p$,133,'adjetivo'),
 ('4bb28b41-dc63-5925-90a0-7ffc1c88362d','20000000-0000-0000-0000-000000000005',$p$danke$p$,$p$gracias$p$,134,'interjeccion'),
 ('a726f39a-594d-524e-a266-bda02953f91e','20000000-0000-0000-0000-000000000005',$p$ja$p$,$p$sí$p$,135,'adverbio'),
 ('18165ca1-71e7-525f-b03c-541f5bbf6702','20000000-0000-0000-0000-000000000005',$p$nein$p$,$p$no$p$,136,'adverbio')
on conflict (id) do nothing;

-- ── Unidad 2 (A1·de): Números, edad y origen ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('25e2b6f1-e76a-599e-853f-e3478ea4d675','20000000-0000-0000-0000-000000000005','A1',2,$p$Números, edad y origen$p$,'#2C3E50','filter_9_plus')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('4905aa48-73d0-577d-9b08-39f49e779a97','25e2b6f1-e76a-599e-853f-e3478ea4d675',1,$p$Números 0-20$p$,$p$Números 0-20$p$,'lesson',15),
 ('660fa1e9-9b08-5a36-9f51-4a2efd5616d5','25e2b6f1-e76a-599e-853f-e3478ea4d675',2,$p$Mi edad$p$,$p$Mi edad$p$,'lesson',15),
 ('014de674-3701-5b9a-8c5a-1f08f05f5ea6','25e2b6f1-e76a-599e-853f-e3478ea4d675',3,$p$¿De dónde eres?$p$,$p$¿De dónde eres?$p$,'lesson',15),
 ('18b2e483-2776-5f8d-b02b-bf7b5784c42b','25e2b6f1-e76a-599e-853f-e3478ea4d675',4,$p$Tener (haben)$p$,$p$Tener (haben)$p$,'lesson',15),
 ('d3bbb827-eab2-5fbe-97b2-121fe6ebae1a','25e2b6f1-e76a-599e-853f-e3478ea4d675',5,$p$🏁 Checkpoint Einheit 2$p$,$p$Contar del 0 al 20, decir tu edad con sein, tu origen con kommen aus y usar haben.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('fabda053-22d9-5170-bc84-ab6ef7590cb9','20000000-0000-0000-0000-000000000005','checkpoint','A1','25e2b6f1-e76a-599e-853f-e3478ea4d675',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('5c981028-77cf-5d10-a207-607ad4e022a1'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','reading','match',$p$Une cada número en alemán con su cifra.$p$,$j${"pairs": [{"en": "drei", "es": "3"}, {"en": "zehn", "es": "10"}, {"en": "zwanzig", "es": "20"}]}$j$::jsonb,$j${"pairs": [["drei", "3"], ["zehn", "10"], ["zwanzig", "20"]]}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$numeros$p$, $p$reading$p$]),
('24b4fdc5-0a73-5ab6-8d11-45e84de485e6'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','reading','match',$p$Une cada palabra con su significado.$p$,$j${"pairs": [{"en": "Spanien", "es": "España"}, {"en": "kommen", "es": "venir"}, {"en": "aus", "es": "de (procedencia)"}]}$j$::jsonb,$j${"pairs": [["Spanien", "España"], ["kommen", "venir"], ["aus", "de (procedencia)"]]}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$origen$p$, $p$reading$p$]),
('2fb6fba9-2dde-553a-bdd9-fb5549d6eb96'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','reading','multiple_choice',$p$¿Cómo se escribe el número 2 en alemán?$p$,$j${"options": ["zwei", "zwölf", "zehn"]}$j$::jsonb,$j${"value": "zwei"}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$numeros$p$, $p$reading$p$]),
('dfaaffd4-3d87-554c-9ffd-55c99a6ad4d6'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','reading','multiple_choice',$p$¿Cuál es la forma CORRECTA de decir 'Tengo 20 años' en alemán?$p$,$j${"options": ["Ich bin zwanzig Jahre alt.", "Ich habe zwanzig Jahre.", "Ich bin zwanzig Jahre."]}$j$::jsonb,$j${"value": "Ich bin zwanzig Jahre alt."}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$edad$p$, $p$reading$p$]),
('d4f74fb1-797a-5e25-ac8b-d08420465d53'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','reading','multiple_choice',$p$¿Cómo se pregunta '¿De dónde vienes?' (informal)?$p$,$j${"options": ["Woher kommst du?", "Wohin gehst du?", "Wie alt bist du?"]}$j$::jsonb,$j${"value": "Woher kommst du?"}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$origen$p$, $p$reading$p$]),
('5deaaf61-7ba9-5b2c-8b02-9abddf88b049'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','reading','multiple_choice',$p$Completa: 'Ich ___ einen Bruder.' (yo tengo)$p$,$j${"options": ["habe", "hast", "bin"]}$j$::jsonb,$j${"value": "habe"}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$haben$p$, $p$reading$p$]),
('f422c87d-97b9-5816-ae6f-d9bbb505ad79'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','writing','cloze',$p$Completa con el verbo sein: 'Yo tengo diez años.'$p$,$j${"text": "Ich ___ zehn Jahre alt."}$j$::jsonb,$j${"value": "bin", "accepted": ["bin"]}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$edad$p$, $p$writing$p$]),
('f41555ae-ab92-5db1-83c5-151131afd948'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','writing','cloze',$p$Completa: 'Vengo de España.'$p$,$j${"text": "Ich komme ___ Spanien."}$j$::jsonb,$j${"value": "aus", "accepted": ["aus"]}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$origen$p$, $p$writing$p$]),
('50ba5686-d022-554b-a7b5-07de90a3c699'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','writing','translation',$p$Traduce: Tengo veinte años.$p$,$j${"source": "Tengo veinte años."}$j$::jsonb,$j${"value": "Ich bin zwanzig Jahre alt.", "accepted": ["Ich bin zwanzig Jahre alt.", "Ich bin zwanzig Jahre alt"]}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$edad$p$, $p$writing$p$]),
('f1b3582f-22bd-50bf-a171-012f0a15015e'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','writing','translation',$p$Traduce: Tengo una hermana.$p$,$j${"source": "Tengo una hermana."}$j$::jsonb,$j${"value": "Ich habe eine Schwester.", "accepted": ["Ich habe eine Schwester.", "Ich habe eine Schwester"]}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$haben$p$, $p$writing$p$]),
('2abd58b8-c56c-59e5-8ac2-cef4e99d4f6e'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','writing','word_bank',$p$Ordena: 'Vengo de España.'$p$,$j${"tiles": ["Ich", "komme", "aus", "Spanien", "bin", "gehe"]}$j$::jsonb,$j${"value": "Ich komme aus Spanien", "sequence": ["Ich", "komme", "aus", "Spanien"]}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$origen$p$, $p$writing$p$]),
('fc8d1cc9-c9d8-5f41-9f75-74b51a4a9dd6'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','writing','reorder',$p$Ordena la frase: '¿Cuántos años tienes?' (informal)$p$,$j${"tiles": ["alt", "Wie", "du", "bist"]}$j$::jsonb,$j${"value": "Wie alt bist du"}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$edad$p$, $p$writing$p$]),
('31992c27-0617-5199-a4bf-c850d76cc13f'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ich habe zwei Brüder.", "Ich habe zwölf Brüder.", "Ich habe zehn Brüder."], "say": "Ich habe zwei Brüder.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/31992c27-0617-5199-a4bf-c850d76cc13f.mp3"}$j$::jsonb,$j${"value": "Ich habe zwei Brüder."}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$numeros$p$, $p$listening$p$]),
('bd062ba3-db0d-5d5a-b1d8-ea9301af5f55'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Wie alt bist du?", "Woher kommst du?", "Wie heißt du?"], "say": "Wie alt bist du?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/bd062ba3-db0d-5d5a-b1d8-ea9301af5f55.mp3"}$j$::jsonb,$j${"value": "Wie alt bist du?"}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$edad$p$, $p$listening$p$]),
('2eb6e6b8-953e-591f-890d-1347f886b730'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ich komme aus Peru.", "Ich komme aus Spanien.", "Ich komme aus Berlin."], "say": "Ich komme aus Peru.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/2eb6e6b8-953e-591f-890d-1347f886b730.mp3"}$j$::jsonb,$j${"value": "Ich komme aus Peru."}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$origen$p$, $p$listening$p$]),
('9ff6f6fb-7d1a-5727-b0b6-1645982f3a18'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ich habe einen Bruder.", "Ich habe eine Schwester.", "Ich bin ein Bruder."], "say": "Ich habe einen Bruder.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/9ff6f6fb-7d1a-5727-b0b6-1645982f3a18.mp3"}$j$::jsonb,$j${"value": "Ich habe einen Bruder."}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$haben$p$, $p$listening$p$]),
('e7a5fd2c-2eee-5155-b2cb-b9e4a4fc8e29'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Ich komme aus Spanien.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/e7a5fd2c-2eee-5155-b2cb-b9e4a4fc8e29.mp3"}$j$::jsonb,$j${"expected": "Ich komme aus Spanien."}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$origen$p$, $p$speaking$p$]),
('db0b2397-8d5c-5279-9e7d-cbdf2d7d09fc'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Ich bin zwanzig Jahre alt.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/db0b2397-8d5c-5279-9e7d-cbdf2d7d09fc.mp3"}$j$::jsonb,$j${"expected": "Ich bin zwanzig Jahre alt."}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$edad$p$, $p$speaking$p$]),
('07f41932-3033-5b6e-876f-061e56a6f817'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Ich habe einen Bruder.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/07f41932-3033-5b6e-876f-061e56a6f817.mp3"}$j$::jsonb,$j${"expected": "Ich habe einen Bruder."}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$haben$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('4905aa48-73d0-577d-9b08-39f49e779a97','5c981028-77cf-5d10-a207-607ad4e022a1',1),
 ('4905aa48-73d0-577d-9b08-39f49e779a97','2fb6fba9-2dde-553a-bdd9-fb5549d6eb96',2),
 ('4905aa48-73d0-577d-9b08-39f49e779a97','31992c27-0617-5199-a4bf-c850d76cc13f',3),
 ('660fa1e9-9b08-5a36-9f51-4a2efd5616d5','dfaaffd4-3d87-554c-9ffd-55c99a6ad4d6',1),
 ('660fa1e9-9b08-5a36-9f51-4a2efd5616d5','f422c87d-97b9-5816-ae6f-d9bbb505ad79',2),
 ('660fa1e9-9b08-5a36-9f51-4a2efd5616d5','50ba5686-d022-554b-a7b5-07de90a3c699',3),
 ('660fa1e9-9b08-5a36-9f51-4a2efd5616d5','fc8d1cc9-c9d8-5f41-9f75-74b51a4a9dd6',4),
 ('660fa1e9-9b08-5a36-9f51-4a2efd5616d5','bd062ba3-db0d-5d5a-b1d8-ea9301af5f55',5),
 ('660fa1e9-9b08-5a36-9f51-4a2efd5616d5','db0b2397-8d5c-5279-9e7d-cbdf2d7d09fc',6),
 ('014de674-3701-5b9a-8c5a-1f08f05f5ea6','24b4fdc5-0a73-5ab6-8d11-45e84de485e6',1),
 ('014de674-3701-5b9a-8c5a-1f08f05f5ea6','d4f74fb1-797a-5e25-ac8b-d08420465d53',2),
 ('014de674-3701-5b9a-8c5a-1f08f05f5ea6','f41555ae-ab92-5db1-83c5-151131afd948',3),
 ('014de674-3701-5b9a-8c5a-1f08f05f5ea6','2abd58b8-c56c-59e5-8ac2-cef4e99d4f6e',4),
 ('014de674-3701-5b9a-8c5a-1f08f05f5ea6','2eb6e6b8-953e-591f-890d-1347f886b730',5),
 ('014de674-3701-5b9a-8c5a-1f08f05f5ea6','e7a5fd2c-2eee-5155-b2cb-b9e4a4fc8e29',6),
 ('18b2e483-2776-5f8d-b02b-bf7b5784c42b','5deaaf61-7ba9-5b2c-8b02-9abddf88b049',1),
 ('18b2e483-2776-5f8d-b02b-bf7b5784c42b','f1b3582f-22bd-50bf-a171-012f0a15015e',2),
 ('18b2e483-2776-5f8d-b02b-bf7b5784c42b','9ff6f6fb-7d1a-5727-b0b6-1645982f3a18',3),
 ('18b2e483-2776-5f8d-b02b-bf7b5784c42b','07f41932-3033-5b6e-876f-061e56a6f817',4),
 ('d3bbb827-eab2-5fbe-97b2-121fe6ebae1a','5c981028-77cf-5d10-a207-607ad4e022a1',1),
 ('d3bbb827-eab2-5fbe-97b2-121fe6ebae1a','24b4fdc5-0a73-5ab6-8d11-45e84de485e6',2),
 ('d3bbb827-eab2-5fbe-97b2-121fe6ebae1a','2fb6fba9-2dde-553a-bdd9-fb5549d6eb96',3),
 ('d3bbb827-eab2-5fbe-97b2-121fe6ebae1a','f422c87d-97b9-5816-ae6f-d9bbb505ad79',4),
 ('d3bbb827-eab2-5fbe-97b2-121fe6ebae1a','f41555ae-ab92-5db1-83c5-151131afd948',5),
 ('d3bbb827-eab2-5fbe-97b2-121fe6ebae1a','50ba5686-d022-554b-a7b5-07de90a3c699',6),
 ('d3bbb827-eab2-5fbe-97b2-121fe6ebae1a','31992c27-0617-5199-a4bf-c850d76cc13f',7),
 ('d3bbb827-eab2-5fbe-97b2-121fe6ebae1a','bd062ba3-db0d-5d5a-b1d8-ea9301af5f55',8),
 ('d3bbb827-eab2-5fbe-97b2-121fe6ebae1a','e7a5fd2c-2eee-5155-b2cb-b9e4a4fc8e29',9),
 ('d3bbb827-eab2-5fbe-97b2-121fe6ebae1a','db0b2397-8d5c-5279-9e7d-cbdf2d7d09fc',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('ee33b2f2-5a85-53ab-8e93-18cddf843bd9','20000000-0000-0000-0000-000000000005',$p$null$p$,$p$cero$p$,141,'numero'),
 ('86e80dbd-f116-5635-afe1-4b20f6136e25','20000000-0000-0000-0000-000000000005',$p$eins$p$,$p$uno$p$,142,'numero'),
 ('797d1c25-7340-5462-b179-816142b76958','20000000-0000-0000-0000-000000000005',$p$zwei$p$,$p$dos$p$,143,'numero'),
 ('668c4649-9aea-526c-9251-4864e04edb8d','20000000-0000-0000-0000-000000000005',$p$drei$p$,$p$tres$p$,144,'numero'),
 ('b00a3f98-1cfb-57dc-b38c-666ab7d17ef5','20000000-0000-0000-0000-000000000005',$p$zehn$p$,$p$diez$p$,145,'numero'),
 ('e93e00c7-3ffe-51c0-98d9-4f4180d1db89','20000000-0000-0000-0000-000000000005',$p$zwanzig$p$,$p$veinte$p$,146,'numero'),
 ('cd3f4a02-63d6-5b42-a32e-6985dcfca0d1','20000000-0000-0000-0000-000000000005',$p$das Jahr$p$,$p$el año$p$,147,'sustantivo'),
 ('a04023d5-798c-56f9-b2df-f03dd3c790b5','20000000-0000-0000-0000-000000000005',$p$alt$p$,$p$viejo / de edad$p$,148,'adjetivo'),
 ('10c6f22b-cc8e-5e05-b78a-341601557ae5','20000000-0000-0000-0000-000000000005',$p$kommen$p$,$p$venir$p$,149,'verbo'),
 ('1892e067-1184-5947-9f2e-ecd036eb6414','20000000-0000-0000-0000-000000000005',$p$aus$p$,$p$de (procedencia)$p$,150,'preposicion'),
 ('22179015-630f-5b77-a0da-2e8d39848fa0','20000000-0000-0000-0000-000000000005',$p$haben$p$,$p$tener$p$,151,'verbo'),
 ('f06181a7-c6e2-5eab-a52f-b3ba82b8e1d6','20000000-0000-0000-0000-000000000005',$p$der Bruder$p$,$p$el hermano$p$,152,'sustantivo'),
 ('dab2605e-5abc-50e3-b079-5d305dd334b0','20000000-0000-0000-0000-000000000005',$p$die Schwester$p$,$p$la hermana$p$,153,'sustantivo'),
 ('b2d83712-4fa3-5f45-8457-a76d35f32d4b','20000000-0000-0000-0000-000000000005',$p$Spanien$p$,$p$España$p$,154,'sustantivo'),
 ('0d87c9e7-cbd8-5213-8602-6d9eee6d9a92','20000000-0000-0000-0000-000000000005',$p$der Spanier$p$,$p$el español$p$,155,'sustantivo'),
 ('dafe7c52-703f-5a29-9fe3-5bbf0b8aba6e','20000000-0000-0000-0000-000000000005',$p$die Spanierin$p$,$p$la española$p$,156,'sustantivo')
on conflict (id) do nothing;

-- ── Unidad 3 (A1·de): La familia ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('589d2fd0-c164-5660-a35d-a29f04b4b2bf','20000000-0000-0000-0000-000000000005','A1',3,$p$La familia$p$,'#8E44AD','family_restroom')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('e35e0272-a53e-5c65-bafb-398cf5a5b44c','589d2fd0-c164-5660-a35d-a29f04b4b2bf',1,$p$Padres e hijos$p$,$p$Padres e hijos$p$,'lesson',15),
 ('770d3403-fa19-5c28-8c30-386f8a84ee8a','589d2fd0-c164-5660-a35d-a29f04b4b2bf',2,$p$Hermanos y abuelos$p$,$p$Hermanos y abuelos$p$,'lesson',15),
 ('fd55303f-a39f-586b-8e20-d374bfafa293','589d2fd0-c164-5660-a35d-a29f04b4b2bf',3,$p$Mein o meine$p$,$p$Mein o meine$p$,'lesson',15),
 ('44c5a431-3df4-585b-8d5e-c0cb99158ed3','589d2fd0-c164-5660-a35d-a29f04b4b2bf',4,$p$¿Quién es este?$p$,$p$¿Quién es este?$p$,'lesson',15),
 ('5e5638af-2674-5f9d-a2dc-42dad78d50c7','589d2fd0-c164-5660-a35d-a29f04b4b2bf',5,$p$🏁 Checkpoint Einheit 3$p$,$p$Practica los miembros de la familia y los posesivos mein/meine según el género del sustantivo.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('0288a829-0d88-50d0-8a57-1d21b62c3dcc','20000000-0000-0000-0000-000000000005','checkpoint','A1','589d2fd0-c164-5660-a35d-a29f04b4b2bf',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('62921733-5e30-50ab-bf27-519361b47426'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','reading','match',$p$Une cada palabra alemana con su traducción.$p$,$j${"pairs": [{"en": "die Mutter", "es": "la madre"}, {"en": "der Vater", "es": "el padre"}, {"en": "das Kind", "es": "el niño"}]}$j$::jsonb,$j${"pairs": [["die Mutter", "la madre"], ["der Vater", "el padre"], ["das Kind", "el niño"]]}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$familie_grundwortschatz$p$, $p$reading$p$]),
('8579b91f-9c8e-5d28-86d1-ca0907afa03a'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','reading','match',$p$Une cada palabra alemana con su traducción.$p$,$j${"pairs": [{"en": "der Bruder", "es": "el hermano"}, {"en": "die Schwester", "es": "la hermana"}, {"en": "die Großmutter", "es": "la abuela"}]}$j$::jsonb,$j${"pairs": [["der Bruder", "el hermano"], ["die Schwester", "la hermana"], ["die Großmutter", "la abuela"]]}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$geschwister_grosseltern$p$, $p$reading$p$]),
('f1a52e63-8e85-51ce-bd5e-dd78f6be272e'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','reading','multiple_choice',$p$¿Cómo se dice "la familia" en alemán?$p$,$j${"options": ["die Familie", "die Freundin", "die Schule"]}$j$::jsonb,$j${"value": "die Familie"}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$familie_grundwortschatz$p$, $p$reading$p$]),
('1ba8cc23-0111-54ad-b2b1-7f4483516674'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','reading','multiple_choice',$p$¿Qué significa "die Eltern"?$p$,$j${"options": ["los padres", "los hijos", "los abuelos"]}$j$::jsonb,$j${"value": "los padres"}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$familie_grundwortschatz$p$, $p$reading$p$]),
('573ac83f-1ff6-5c6b-a976-e77f30f4afb9'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','reading','multiple_choice',$p$¿Cómo se dice "el abuelo" en alemán?$p$,$j${"options": ["der Großvater", "die Großmutter", "der Bruder"]}$j$::jsonb,$j${"value": "der Großvater"}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$geschwister_grosseltern$p$, $p$reading$p$]),
('0949e6c4-6816-58f1-8a42-8af4ae4b5688'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','reading','multiple_choice',$p$Elige la pregunta correcta para "¿Quién es este?".$p$,$j${"options": ["Wer ist das?", "Wie ist das?", "Wo ist das?"]}$j$::jsonb,$j${"value": "Wer ist das?"}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$das_ist_wer$p$, $p$reading$p$]),
('9b6f5f0a-d9b9-5b5b-9ae1-58af6bdaa0c5'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','writing','cloze',$p$Completa con el posesivo correcto (Bruder es masculino).$p$,$j${"text": "Das ist ___ Bruder."}$j$::jsonb,$j${"value": "mein", "accepted": ["mein"]}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$possessiv_mein_meine$p$, $p$writing$p$]),
('07b0b69e-5701-5066-b445-73bd237b3a0a'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','writing','cloze',$p$Completa con el posesivo correcto (Schwester es femenino).$p$,$j${"text": "Das ist ___ Schwester."}$j$::jsonb,$j${"value": "meine", "accepted": ["meine"]}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$possessiv_mein_meine$p$, $p$writing$p$]),
('5b0f84bf-acf0-545a-9349-9417e9243e33'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','writing','translation',$p$Traduce: Esta es mi madre.$p$,$j${"source": "Esta es mi madre."}$j$::jsonb,$j${"value": "Das ist meine Mutter.", "accepted": ["Das ist meine Mutter.", "Das ist meine Mutter"]}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$familie_grundwortschatz$p$, $p$writing$p$]),
('52459f19-9d96-5bad-9e66-a0aa29e9a507'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','writing','translation',$p$Traduce: Estos son mis padres.$p$,$j${"source": "Estos son mis padres."}$j$::jsonb,$j${"value": "Das sind meine Eltern.", "accepted": ["Das sind meine Eltern.", "Das sind meine Eltern"]}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$das_ist_wer$p$, $p$writing$p$]),
('1e0946b9-f1cd-5818-baba-26b87631c908'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','writing','word_bank',$p$Ordena las fichas: "Este es mi padre."$p$,$j${"tiles": ["Das", "ist", "mein", "Vater", "meine"]}$j$::jsonb,$j${"value": "Das ist mein Vater", "sequence": ["Das", "ist", "mein", "Vater"]}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$possessiv_mein_meine$p$, $p$writing$p$]),
('34e936e4-f080-50ab-a0da-6836983b6454'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','writing','reorder',$p$Ordena las palabras para formar: "¿Quién es este?"$p$,$j${"tiles": ["ist", "Wer", "das"]}$j$::jsonb,$j${"value": "Wer ist das"}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$das_ist_wer$p$, $p$writing$p$]),
('b69b4cc5-c84d-573b-bbf4-8d6130131af4'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Das ist meine Mutter.", "Das ist mein Vater.", "Das sind meine Eltern."], "say": "Das ist meine Mutter.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/b69b4cc5-c84d-573b-bbf4-8d6130131af4.mp3"}$j$::jsonb,$j${"value": "Das ist meine Mutter."}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$familie_grundwortschatz$p$, $p$listening$p$]),
('d65b14cf-15be-5d2b-a3a1-92e6046425a8'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ich habe einen Bruder.", "Ich habe eine Schwester.", "Ich habe zwei Kinder."], "say": "Ich habe einen Bruder.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/d65b14cf-15be-5d2b-a3a1-92e6046425a8.mp3"}$j$::jsonb,$j${"value": "Ich habe einen Bruder."}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$geschwister_grosseltern$p$, $p$listening$p$]),
('91651b8c-64d9-5342-9d6f-7f0a8ae9c94a'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Das ist mein Bruder.", "Das ist meine Schwester.", "Das ist meine Familie."], "say": "Das ist mein Bruder.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/91651b8c-64d9-5342-9d6f-7f0a8ae9c94a.mp3"}$j$::jsonb,$j${"value": "Das ist mein Bruder."}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$possessiv_mein_meine$p$, $p$listening$p$]),
('a40001e4-f1ef-506c-8d89-7dd2aa7e74d8'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Wer ist das?", "Wie geht es dir?", "Wo wohnst du?"], "say": "Wer ist das?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/a40001e4-f1ef-506c-8d89-7dd2aa7e74d8.mp3"}$j$::jsonb,$j${"value": "Wer ist das?"}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$das_ist_wer$p$, $p$listening$p$]),
('054da178-8c37-56fc-abfe-c3f663b94266'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Das ist meine Familie.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/054da178-8c37-56fc-abfe-c3f663b94266.mp3"}$j$::jsonb,$j${"expected": "Das ist meine Familie."}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$familie_grundwortschatz$p$, $p$speaking$p$]),
('63baa12f-a2ae-5362-b3a2-828b07550e31'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Ich habe einen Bruder und eine Schwester.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/63baa12f-a2ae-5362-b3a2-828b07550e31.mp3"}$j$::jsonb,$j${"expected": "Ich habe einen Bruder und eine Schwester."}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$geschwister_grosseltern$p$, $p$speaking$p$]),
('beeaa7a9-5f37-5d4e-a40b-24bf1e73d15d'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Das sind meine Großeltern.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/beeaa7a9-5f37-5d4e-a40b-24bf1e73d15d.mp3"}$j$::jsonb,$j${"expected": "Das sind meine Großeltern."}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$possessiv_mein_meine$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('e35e0272-a53e-5c65-bafb-398cf5a5b44c','62921733-5e30-50ab-bf27-519361b47426',1),
 ('e35e0272-a53e-5c65-bafb-398cf5a5b44c','f1a52e63-8e85-51ce-bd5e-dd78f6be272e',2),
 ('e35e0272-a53e-5c65-bafb-398cf5a5b44c','1ba8cc23-0111-54ad-b2b1-7f4483516674',3),
 ('e35e0272-a53e-5c65-bafb-398cf5a5b44c','5b0f84bf-acf0-545a-9349-9417e9243e33',4),
 ('e35e0272-a53e-5c65-bafb-398cf5a5b44c','b69b4cc5-c84d-573b-bbf4-8d6130131af4',5),
 ('e35e0272-a53e-5c65-bafb-398cf5a5b44c','054da178-8c37-56fc-abfe-c3f663b94266',6),
 ('770d3403-fa19-5c28-8c30-386f8a84ee8a','8579b91f-9c8e-5d28-86d1-ca0907afa03a',1),
 ('770d3403-fa19-5c28-8c30-386f8a84ee8a','573ac83f-1ff6-5c6b-a976-e77f30f4afb9',2),
 ('770d3403-fa19-5c28-8c30-386f8a84ee8a','d65b14cf-15be-5d2b-a3a1-92e6046425a8',3),
 ('770d3403-fa19-5c28-8c30-386f8a84ee8a','63baa12f-a2ae-5362-b3a2-828b07550e31',4),
 ('fd55303f-a39f-586b-8e20-d374bfafa293','9b6f5f0a-d9b9-5b5b-9ae1-58af6bdaa0c5',1),
 ('fd55303f-a39f-586b-8e20-d374bfafa293','07b0b69e-5701-5066-b445-73bd237b3a0a',2),
 ('fd55303f-a39f-586b-8e20-d374bfafa293','1e0946b9-f1cd-5818-baba-26b87631c908',3),
 ('fd55303f-a39f-586b-8e20-d374bfafa293','91651b8c-64d9-5342-9d6f-7f0a8ae9c94a',4),
 ('fd55303f-a39f-586b-8e20-d374bfafa293','beeaa7a9-5f37-5d4e-a40b-24bf1e73d15d',5),
 ('44c5a431-3df4-585b-8d5e-c0cb99158ed3','0949e6c4-6816-58f1-8a42-8af4ae4b5688',1),
 ('44c5a431-3df4-585b-8d5e-c0cb99158ed3','52459f19-9d96-5bad-9e66-a0aa29e9a507',2),
 ('44c5a431-3df4-585b-8d5e-c0cb99158ed3','34e936e4-f080-50ab-a0da-6836983b6454',3),
 ('44c5a431-3df4-585b-8d5e-c0cb99158ed3','a40001e4-f1ef-506c-8d89-7dd2aa7e74d8',4),
 ('5e5638af-2674-5f9d-a2dc-42dad78d50c7','62921733-5e30-50ab-bf27-519361b47426',1),
 ('5e5638af-2674-5f9d-a2dc-42dad78d50c7','8579b91f-9c8e-5d28-86d1-ca0907afa03a',2),
 ('5e5638af-2674-5f9d-a2dc-42dad78d50c7','f1a52e63-8e85-51ce-bd5e-dd78f6be272e',3),
 ('5e5638af-2674-5f9d-a2dc-42dad78d50c7','9b6f5f0a-d9b9-5b5b-9ae1-58af6bdaa0c5',4),
 ('5e5638af-2674-5f9d-a2dc-42dad78d50c7','07b0b69e-5701-5066-b445-73bd237b3a0a',5),
 ('5e5638af-2674-5f9d-a2dc-42dad78d50c7','5b0f84bf-acf0-545a-9349-9417e9243e33',6),
 ('5e5638af-2674-5f9d-a2dc-42dad78d50c7','b69b4cc5-c84d-573b-bbf4-8d6130131af4',7),
 ('5e5638af-2674-5f9d-a2dc-42dad78d50c7','d65b14cf-15be-5d2b-a3a1-92e6046425a8',8),
 ('5e5638af-2674-5f9d-a2dc-42dad78d50c7','054da178-8c37-56fc-abfe-c3f663b94266',9),
 ('5e5638af-2674-5f9d-a2dc-42dad78d50c7','63baa12f-a2ae-5362-b3a2-828b07550e31',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('79f79c83-60e2-503b-8604-ee72b26e4bf0','20000000-0000-0000-0000-000000000005',$p$die Familie$p$,$p$la familia$p$,161,'sustantivo'),
 ('32ad7b8f-3f69-54aa-8caf-2aa065c405df','20000000-0000-0000-0000-000000000005',$p$die Mutter$p$,$p$la madre$p$,162,'sustantivo'),
 ('d1bf1ab5-3865-5d91-a9f7-d22ba8a05077','20000000-0000-0000-0000-000000000005',$p$der Vater$p$,$p$el padre$p$,163,'sustantivo'),
 ('ccf4e771-a19d-5076-9505-6c04df61b9f4','20000000-0000-0000-0000-000000000005',$p$die Eltern$p$,$p$los padres$p$,164,'sustantivo'),
 ('ba3189c6-4cdf-5ff6-b186-db44560ab0c7','20000000-0000-0000-0000-000000000005',$p$der Bruder$p$,$p$el hermano$p$,165,'sustantivo'),
 ('790ea3d4-5cbe-505e-a245-ab03719106c8','20000000-0000-0000-0000-000000000005',$p$die Schwester$p$,$p$la hermana$p$,166,'sustantivo'),
 ('e7f135cd-3bf0-52b2-aa85-72a3510398fb','20000000-0000-0000-0000-000000000005',$p$das Kind$p$,$p$el niño / el hijo$p$,167,'sustantivo'),
 ('845d5088-b60d-5cbc-a5da-e332599ec40b','20000000-0000-0000-0000-000000000005',$p$die Großmutter$p$,$p$la abuela$p$,168,'sustantivo'),
 ('af5ab25b-8350-56a0-b2bc-7559c8210fbc','20000000-0000-0000-0000-000000000005',$p$der Großvater$p$,$p$el abuelo$p$,169,'sustantivo'),
 ('e1d26e8a-5812-58c9-b8a8-854a3c6a88c0','20000000-0000-0000-0000-000000000005',$p$die Großeltern$p$,$p$los abuelos$p$,170,'sustantivo'),
 ('92a26160-cdee-5ce0-922a-ae2bc9b814ce','20000000-0000-0000-0000-000000000005',$p$mein$p$,$p$mi (masc./neutro)$p$,171,'pronombre'),
 ('4815630a-ff8a-5ce0-9df5-771d7bed7031','20000000-0000-0000-0000-000000000005',$p$meine$p$,$p$mi (fem./plural)$p$,172,'pronombre'),
 ('b6e18775-a7f2-5059-b840-7bc77560564c','20000000-0000-0000-0000-000000000005',$p$Das ist$p$,$p$Este/Esta es$p$,173,'expresion'),
 ('37f74f01-eafe-532b-a3c5-9390b8fa6d9e','20000000-0000-0000-0000-000000000005',$p$Das sind$p$,$p$Estos/Estas son$p$,174,'expresion'),
 ('edeef841-869e-512c-9c0f-7dc13ea53ebe','20000000-0000-0000-0000-000000000005',$p$Wer$p$,$p$quién$p$,175,'pronombre'),
 ('64ca0348-8186-5dbb-9558-e604e4b1393f','20000000-0000-0000-0000-000000000005',$p$und$p$,$p$y$p$,176,'adverbio')
on conflict (id) do nothing;

-- ── Unidad 4 (A1·de): Comida y en el café ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('85b84681-a2b8-5b8f-8a56-f84a956c5fd2','20000000-0000-0000-0000-000000000005','A1',4,$p$Comida y en el café$p$,'#E67E22','restaurant')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('62e71dd3-92ce-59c2-9f46-49f75ceef60a','85b84681-a2b8-5b8f-8a56-f84a956c5fd2',1,$p$Comida y bebida$p$,$p$Comida y bebida$p$,'lesson',15),
 ('c90125ab-dd57-53cf-930b-2da48b27a446','85b84681-a2b8-5b8f-8a56-f84a956c5fd2',2,$p$Quiero, por favor$p$,$p$Quiero, por favor$p$,'lesson',15),
 ('e609a65f-9931-5190-8293-b7e5adb20faa','85b84681-a2b8-5b8f-8a56-f84a956c5fd2',3,$p$einen, eine o ein$p$,$p$einen, eine o ein$p$,'lesson',15),
 ('b559802d-741c-50ba-984a-18e438aedbb2','85b84681-a2b8-5b8f-8a56-f84a956c5fd2',4,$p$¿Cuánto cuesta?$p$,$p$¿Cuánto cuesta?$p$,'lesson',15),
 ('ea623190-9a96-5d2d-973c-ae02d4ef8836','85b84681-a2b8-5b8f-8a56-f84a956c5fd2',5,$p$🏁 Checkpoint Einheit 4$p$,$p$Practica alimentos y bebidas, la fórmula de cortesía Ich möchte y el acusativo del artículo indefinido.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('f1d69f3f-f54a-5444-894f-c43cdb956d68','20000000-0000-0000-0000-000000000005','checkpoint','A1','85b84681-a2b8-5b8f-8a56-f84a956c5fd2',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('e18e32e1-6d53-5cce-bee8-ff9ed4870383'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','reading','match',$p$Une cada palabra alemana con su traducción.$p$,$j${"pairs": [{"en": "das Brot", "es": "el pan"}, {"en": "der Kaffee", "es": "el café"}, {"en": "die Milch", "es": "la leche"}]}$j$::jsonb,$j${"pairs": [["das Brot", "el pan"], ["der Kaffee", "el café"], ["die Milch", "la leche"]]}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$essen_trinken$p$, $p$reading$p$]),
('305b5949-e7e7-5a19-ab6a-973860b21948'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','reading','match',$p$Une cada palabra alemana con su traducción.$p$,$j${"pairs": [{"en": "der Apfel", "es": "la manzana"}, {"en": "der Saft", "es": "el zumo"}, {"en": "der Kuchen", "es": "el pastel"}]}$j$::jsonb,$j${"pairs": [["der Apfel", "la manzana"], ["der Saft", "el zumo"], ["der Kuchen", "el pastel"]]}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$essen_trinken$p$, $p$reading$p$]),
('c7c0e7ee-aab9-5386-9242-27f13d2b2f3b'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','reading','multiple_choice',$p$¿Cómo se dice "el agua" en alemán?$p$,$j${"options": ["das Wasser", "der Wein", "die Milch"]}$j$::jsonb,$j${"value": "das Wasser"}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$essen_trinken$p$, $p$reading$p$]),
('47353cd9-ac38-5fff-a253-3dc0a1418d20'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','reading','multiple_choice',$p$¿Qué significa "Ich möchte einen Kaffee, bitte."?$p$,$j${"options": ["Quisiera un café, por favor.", "Tengo un café, gracias.", "El café está frío."]}$j$::jsonb,$j${"value": "Quisiera un café, por favor."}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$ich_moechte_hoeflich$p$, $p$reading$p$]),
('aa78a059-18de-5211-905d-1e87ac1caab0'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','reading','multiple_choice',$p$¿Cómo se pregunta "¿Cuánto cuesta?" en alemán?$p$,$j${"options": ["Was kostet das?", "Wer ist das?", "Wo ist das?"]}$j$::jsonb,$j${"value": "Was kostet das?"}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$preise_bezahlen$p$, $p$reading$p$]),
('cd01e5eb-fa70-591b-85fc-aba2787347a9'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','reading','multiple_choice',$p$Elige el artículo correcto: "Ich möchte ___ Kaffee." (Kaffee es masculino, en acusativo).$p$,$j${"options": ["einen", "eine", "ein"]}$j$::jsonb,$j${"value": "einen"}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$akkusativ_unbestimmt$p$, $p$reading$p$]),
('4ec8ae29-58fb-5f36-b9ec-52203844af7e'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','writing','cloze',$p$Completa con la fórmula de cortesía ("quisiera").$p$,$j${"text": "___ möchte einen Tee."}$j$::jsonb,$j${"value": "Ich", "accepted": ["Ich"]}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$ich_moechte_hoeflich$p$, $p$writing$p$]),
('12057f8d-88d1-591e-9433-fa7237d5de40'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','writing','cloze',$p$Completa con el artículo indefinido correcto (Milch es femenino).$p$,$j${"text": "Ich möchte ___ Milch, bitte."}$j$::jsonb,$j${"value": "eine", "accepted": ["eine"]}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$akkusativ_unbestimmt$p$, $p$writing$p$]),
('e314055a-81dc-5742-8514-f402523bd855'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','writing','translation',$p$Traduce: Quisiera un café, por favor.$p$,$j${"source": "Quisiera un café, por favor."}$j$::jsonb,$j${"value": "Ich möchte einen Kaffee, bitte.", "accepted": ["Ich möchte einen Kaffee, bitte.", "Ich möchte einen Kaffee, bitte", "Ich moechte einen Kaffee, bitte.", "Ich moechte einen Kaffee, bitte"]}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$ich_moechte_hoeflich$p$, $p$writing$p$]),
('42a7c59f-55c5-5ee2-afb9-d09b76829911'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','writing','translation',$p$Traduce: Son cinco euros.$p$,$j${"source": "Son cinco euros."}$j$::jsonb,$j${"value": "Das macht fünf Euro.", "accepted": ["Das macht fünf Euro.", "Das macht fünf Euro", "Das macht fuenf Euro.", "Das macht fuenf Euro"]}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$preise_bezahlen$p$, $p$writing$p$]),
('f5efdc72-bbb1-5dd5-bfe9-5fdc0c8e5cbd'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','writing','word_bank',$p$Ordena las fichas: "Quisiera un agua." (Wasser es neutro).$p$,$j${"tiles": ["Ich", "möchte", "ein", "Wasser", "einen"]}$j$::jsonb,$j${"value": "Ich möchte ein Wasser", "sequence": ["Ich", "möchte", "ein", "Wasser"]}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$akkusativ_unbestimmt$p$, $p$writing$p$]),
('617b40d4-8673-5a8f-adce-310300bc8bac'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','writing','reorder',$p$Ordena las palabras para formar: "Un café, por favor."$p$,$j${"tiles": ["Kaffee", "Einen", "bitte"]}$j$::jsonb,$j${"value": "Einen Kaffee bitte"}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$ich_moechte_hoeflich$p$, $p$writing$p$]),
('f74f38a6-1813-5a7c-b915-76d4b8fb81e4'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ich möchte ein Brot.", "Ich möchte einen Apfel.", "Ich möchte eine Milch."], "say": "Ich möchte ein Brot.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/f74f38a6-1813-5a7c-b915-76d4b8fb81e4.mp3"}$j$::jsonb,$j${"value": "Ich möchte ein Brot."}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$essen_trinken$p$, $p$listening$p$]),
('3dd8a83a-4b3d-54b9-936b-50051051ae92'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Einen Kaffee, bitte.", "Einen Tee, bitte.", "Ein Wasser, bitte."], "say": "Einen Kaffee, bitte.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/3dd8a83a-4b3d-54b9-936b-50051051ae92.mp3"}$j$::jsonb,$j${"value": "Einen Kaffee, bitte."}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$ich_moechte_hoeflich$p$, $p$listening$p$]),
('aa9b5c43-00ef-5078-a091-43a633a4adee'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Was kostet das?", "Wie geht es dir?", "Wer ist das?"], "say": "Was kostet das?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/aa9b5c43-00ef-5078-a091-43a633a4adee.mp3"}$j$::jsonb,$j${"value": "Was kostet das?"}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$preise_bezahlen$p$, $p$listening$p$]),
('36918ff7-207d-5f50-9c9c-8954cd641363'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Das macht fünf Euro.", "Das macht zwei Euro.", "Das macht zehn Euro."], "say": "Das macht fünf Euro.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/36918ff7-207d-5f50-9c9c-8954cd641363.mp3"}$j$::jsonb,$j${"value": "Das macht fünf Euro."}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$preise_bezahlen$p$, $p$listening$p$]),
('2c061e0c-e8f5-56c9-94e1-3f8ed19aefe7'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Ich möchte einen Apfel und ein Wasser.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/2c061e0c-e8f5-56c9-94e1-3f8ed19aefe7.mp3"}$j$::jsonb,$j${"expected": "Ich möchte einen Apfel und ein Wasser."}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$essen_trinken$p$, $p$speaking$p$]),
('18ad2302-3142-5142-bc45-7f35ea7d297a'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Einen Kaffee und einen Kuchen, bitte.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/18ad2302-3142-5142-bc45-7f35ea7d297a.mp3"}$j$::jsonb,$j${"expected": "Einen Kaffee und einen Kuchen, bitte."}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$ich_moechte_hoeflich$p$, $p$speaking$p$]),
('a7ad1945-75b5-5d3a-962a-ec9ad105dbb6'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Was kostet das, bitte?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/a7ad1945-75b5-5d3a-962a-ec9ad105dbb6.mp3"}$j$::jsonb,$j${"expected": "Was kostet das, bitte?"}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$preise_bezahlen$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('62e71dd3-92ce-59c2-9f46-49f75ceef60a','e18e32e1-6d53-5cce-bee8-ff9ed4870383',1),
 ('62e71dd3-92ce-59c2-9f46-49f75ceef60a','305b5949-e7e7-5a19-ab6a-973860b21948',2),
 ('62e71dd3-92ce-59c2-9f46-49f75ceef60a','c7c0e7ee-aab9-5386-9242-27f13d2b2f3b',3),
 ('62e71dd3-92ce-59c2-9f46-49f75ceef60a','f74f38a6-1813-5a7c-b915-76d4b8fb81e4',4),
 ('62e71dd3-92ce-59c2-9f46-49f75ceef60a','2c061e0c-e8f5-56c9-94e1-3f8ed19aefe7',5),
 ('c90125ab-dd57-53cf-930b-2da48b27a446','47353cd9-ac38-5fff-a253-3dc0a1418d20',1),
 ('c90125ab-dd57-53cf-930b-2da48b27a446','4ec8ae29-58fb-5f36-b9ec-52203844af7e',2),
 ('c90125ab-dd57-53cf-930b-2da48b27a446','e314055a-81dc-5742-8514-f402523bd855',3),
 ('c90125ab-dd57-53cf-930b-2da48b27a446','617b40d4-8673-5a8f-adce-310300bc8bac',4),
 ('c90125ab-dd57-53cf-930b-2da48b27a446','3dd8a83a-4b3d-54b9-936b-50051051ae92',5),
 ('c90125ab-dd57-53cf-930b-2da48b27a446','18ad2302-3142-5142-bc45-7f35ea7d297a',6),
 ('e609a65f-9931-5190-8293-b7e5adb20faa','cd01e5eb-fa70-591b-85fc-aba2787347a9',1),
 ('e609a65f-9931-5190-8293-b7e5adb20faa','12057f8d-88d1-591e-9433-fa7237d5de40',2),
 ('e609a65f-9931-5190-8293-b7e5adb20faa','f5efdc72-bbb1-5dd5-bfe9-5fdc0c8e5cbd',3),
 ('b559802d-741c-50ba-984a-18e438aedbb2','aa78a059-18de-5211-905d-1e87ac1caab0',1),
 ('b559802d-741c-50ba-984a-18e438aedbb2','42a7c59f-55c5-5ee2-afb9-d09b76829911',2),
 ('b559802d-741c-50ba-984a-18e438aedbb2','aa9b5c43-00ef-5078-a091-43a633a4adee',3),
 ('b559802d-741c-50ba-984a-18e438aedbb2','36918ff7-207d-5f50-9c9c-8954cd641363',4),
 ('b559802d-741c-50ba-984a-18e438aedbb2','a7ad1945-75b5-5d3a-962a-ec9ad105dbb6',5),
 ('ea623190-9a96-5d2d-973c-ae02d4ef8836','e18e32e1-6d53-5cce-bee8-ff9ed4870383',1),
 ('ea623190-9a96-5d2d-973c-ae02d4ef8836','305b5949-e7e7-5a19-ab6a-973860b21948',2),
 ('ea623190-9a96-5d2d-973c-ae02d4ef8836','c7c0e7ee-aab9-5386-9242-27f13d2b2f3b',3),
 ('ea623190-9a96-5d2d-973c-ae02d4ef8836','4ec8ae29-58fb-5f36-b9ec-52203844af7e',4),
 ('ea623190-9a96-5d2d-973c-ae02d4ef8836','12057f8d-88d1-591e-9433-fa7237d5de40',5),
 ('ea623190-9a96-5d2d-973c-ae02d4ef8836','e314055a-81dc-5742-8514-f402523bd855',6),
 ('ea623190-9a96-5d2d-973c-ae02d4ef8836','f74f38a6-1813-5a7c-b915-76d4b8fb81e4',7),
 ('ea623190-9a96-5d2d-973c-ae02d4ef8836','3dd8a83a-4b3d-54b9-936b-50051051ae92',8),
 ('ea623190-9a96-5d2d-973c-ae02d4ef8836','2c061e0c-e8f5-56c9-94e1-3f8ed19aefe7',9),
 ('ea623190-9a96-5d2d-973c-ae02d4ef8836','18ad2302-3142-5142-bc45-7f35ea7d297a',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('0fc51cb0-7e18-5ffb-9138-d76b76ce6f66','20000000-0000-0000-0000-000000000005',$p$das Brot$p$,$p$el pan$p$,181,'sustantivo'),
 ('31526893-7b62-5ef7-bc3f-dc6fa5a3cf74','20000000-0000-0000-0000-000000000005',$p$das Wasser$p$,$p$el agua$p$,182,'sustantivo'),
 ('8330694c-5407-5fd0-b70a-1478ea5981b7','20000000-0000-0000-0000-000000000005',$p$der Kaffee$p$,$p$el café$p$,183,'sustantivo'),
 ('3474cea7-fb70-51ac-84c2-4b53d5f308ea','20000000-0000-0000-0000-000000000005',$p$der Tee$p$,$p$el té$p$,184,'sustantivo'),
 ('3cc4403e-694f-51ea-9346-bd920af3ceda','20000000-0000-0000-0000-000000000005',$p$die Milch$p$,$p$la leche$p$,185,'sustantivo'),
 ('46617907-5f69-5bd6-ad02-e0abb1ac344e','20000000-0000-0000-0000-000000000005',$p$der Apfel$p$,$p$la manzana$p$,186,'sustantivo'),
 ('e5c9c23d-6c32-5751-9611-7eedf211035e','20000000-0000-0000-0000-000000000005',$p$der Saft$p$,$p$el zumo$p$,187,'sustantivo'),
 ('0adace7b-b36f-55a0-a265-c3663820cf87','20000000-0000-0000-0000-000000000005',$p$der Kuchen$p$,$p$el pastel$p$,188,'sustantivo'),
 ('8174e69d-7ab7-56c1-bc1c-b56cf4d97108','20000000-0000-0000-0000-000000000005',$p$Ich möchte$p$,$p$quisiera / quiero$p$,189,'expresion'),
 ('e385c5e2-4f12-59f4-ba4b-5cdc7c483ce4','20000000-0000-0000-0000-000000000005',$p$bitte$p$,$p$por favor$p$,190,'adverbio'),
 ('2e64d6dd-cbfb-5bc5-b877-aafd28f2d417','20000000-0000-0000-0000-000000000005',$p$einen$p$,$p$un (masc. acusativo)$p$,191,'articulo'),
 ('fdec4201-373e-5032-aa05-7c3b4da20d26','20000000-0000-0000-0000-000000000005',$p$eine$p$,$p$una (fem.)$p$,192,'articulo'),
 ('2e1c46a0-64e8-5932-92d1-6b5959fd1af0','20000000-0000-0000-0000-000000000005',$p$ein$p$,$p$un (neutro)$p$,193,'articulo'),
 ('d93dc7a2-da70-50ce-8dc0-23e63bc5a813','20000000-0000-0000-0000-000000000005',$p$Was kostet das?$p$,$p$¿Cuánto cuesta?$p$,194,'expresion'),
 ('722ae11b-4a81-5929-87ab-82344cfb5d9a','20000000-0000-0000-0000-000000000005',$p$Das macht$p$,$p$Son (el total es)$p$,195,'expresion'),
 ('ed5614d2-bb7e-5a91-a5c3-fd62ea5ab1db','20000000-0000-0000-0000-000000000005',$p$der Euro$p$,$p$el euro$p$,196,'sustantivo')
on conflict (id) do nothing;

-- ── Unidad 5 (A1·de): El día y la hora ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('7669d9b9-90cd-5a15-a90b-683f180165fc','20000000-0000-0000-0000-000000000005','A1',5,$p$El día y la hora$p$,'#2980B9','schedule')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('a373f2b9-6aa1-55c3-bf8c-cf5d156d35e4','7669d9b9-90cd-5a15-a90b-683f180165fc',1,$p$¿Qué hora es?$p$,$p$¿Qué hora es?$p$,'lesson',15),
 ('da0804e2-d240-5294-a029-360ba3d4fe61','7669d9b9-90cd-5a15-a90b-683f180165fc',2,$p$Y cuarto, y media, menos cuarto$p$,$p$Y cuarto, y media, menos cuarto$p$,'lesson',15),
 ('f6303ba5-78ea-5cfa-b57f-08af6239ae9a','7669d9b9-90cd-5a15-a90b-683f180165fc',3,$p$Los días de la semana$p$,$p$Los días de la semana$p$,'lesson',15),
 ('af49f5cc-5635-580c-97fe-c1d9e3007a5b','7669d9b9-90cd-5a15-a90b-683f180165fc',4,$p$Mi rutina: vivir, trabajar, aprender$p$,$p$Mi rutina: vivir, trabajar, aprender$p$,'lesson',15),
 ('684cb514-ad4e-5a91-9733-5d5f83d292e2','7669d9b9-90cd-5a15-a90b-683f180165fc',5,$p$🏁 Checkpoint Einheit 5$p$,$p$Preguntar y decir la hora, los días de la semana y hablar de la rutina con verbos regulares en presente.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('47fb2617-8207-5891-9515-5e218cf767ce','20000000-0000-0000-0000-000000000005','checkpoint','A1','7669d9b9-90cd-5a15-a90b-683f180165fc',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('9f8d04bc-bbcf-5ff7-ad33-af0792eba997'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','reading','match',$p$Une cada palabra alemana con su significado.$p$,$j${"pairs": [{"en": "die Uhr", "es": "la hora / el reloj"}, {"en": "die Stunde", "es": "la hora (duración)"}, {"en": "die Minute", "es": "el minuto"}]}$j$::jsonb,$j${"pairs": [["die Uhr", "la hora / el reloj"], ["die Stunde", "la hora (duración)"], ["die Minute", "el minuto"]]}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$die_uhrzeit$p$, $p$reading$p$]),
('74065adc-3921-557f-940a-638040999851'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','reading','multiple_choice',$p$¿Cómo se pregunta '¿Qué hora es?' en alemán?$p$,$j${"options": ["Wie spät ist es?", "Wie geht es dir?", "Wo ist es?"]}$j$::jsonb,$j${"value": "Wie spät ist es?"}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$die_uhrzeit$p$, $p$reading$p$]),
('7bbaf642-81c1-5d98-b973-0a3d3729c8c6'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','writing','cloze',$p$Completa: 'Son las cuatro en punto.'$p$,$j${"text": "Es ist vier ___."}$j$::jsonb,$j${"value": "Uhr", "accepted": ["Uhr"]}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$die_uhrzeit$p$, $p$writing$p$]),
('ca9b5107-9b22-5667-bb53-5b09f31bdfce'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Es ist zwei Uhr.", "Es ist zehn Uhr.", "Es ist neun Uhr."], "say": "Es ist zwei Uhr.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/ca9b5107-9b22-5667-bb53-5b09f31bdfce.mp3"}$j$::jsonb,$j${"value": "Es ist zwei Uhr."}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$die_uhrzeit$p$, $p$listening$p$]),
('277b7710-7f74-51e5-80e4-d9c569d3ca9f'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Wie spät ist es?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/277b7710-7f74-51e5-80e4-d9c569d3ca9f.mp3"}$j$::jsonb,$j${"expected": "Wie spät ist es?"}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$die_uhrzeit$p$, $p$speaking$p$]),
('04ddf897-a7ad-5e90-8084-e3b9fbb59588'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','reading','match',$p$Une cada hora en alemán con su hora en números.$p$,$j${"pairs": [{"en": "Viertel nach drei", "es": "3:15"}, {"en": "halb vier", "es": "3:30"}, {"en": "Viertel vor vier", "es": "3:45"}]}$j$::jsonb,$j${"pairs": [["Viertel nach drei", "3:15"], ["halb vier", "3:30"], ["Viertel vor vier", "3:45"]]}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$viertel_halb$p$, $p$reading$p$]),
('7540d832-e995-57a4-be8a-167d2a04d623'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','writing','cloze',$p$Completa: 3:15 = 'Es ist ___ nach drei.'$p$,$j${"text": "Es ist ___ nach drei."}$j$::jsonb,$j${"value": "Viertel", "accepted": ["Viertel"]}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$viertel_halb$p$, $p$writing$p$]),
('50e4692e-0baa-59be-a442-da412f18d4d0'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','writing','word_bank',$p$Ordena para decir '3:45' (menos cuarto para las cuatro).$p$,$j${"tiles": ["Es", "ist", "Viertel", "vor", "vier", "halb"]}$j$::jsonb,$j${"value": "Es ist Viertel vor vier", "sequence": ["Es", "ist", "Viertel", "vor", "vier"]}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$viertel_halb$p$, $p$writing$p$]),
('d6649784-fec1-5cbd-838a-3871796f0df1'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Es ist halb vier.", "Es ist Viertel vor vier.", "Es ist vier Uhr."], "say": "Es ist halb vier.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/d6649784-fec1-5cbd-838a-3871796f0df1.mp3"}$j$::jsonb,$j${"value": "Es ist halb vier."}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$viertel_halb$p$, $p$listening$p$]),
('7c6e74d3-acb5-5d79-b6c1-65a3391b8e0b'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Es ist Viertel nach drei.", "Es ist Viertel vor drei.", "Es ist halb drei."], "say": "Es ist Viertel nach drei.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/7c6e74d3-acb5-5d79-b6c1-65a3391b8e0b.mp3"}$j$::jsonb,$j${"value": "Es ist Viertel nach drei."}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$viertel_halb$p$, $p$listening$p$]),
('87702b3e-24ea-54d9-9af5-0271938459bd'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','reading','match',$p$Une cada día de la semana con su significado.$p$,$j${"pairs": [{"en": "Montag", "es": "lunes"}, {"en": "Mittwoch", "es": "miércoles"}, {"en": "Freitag", "es": "viernes"}]}$j$::jsonb,$j${"pairs": [["Montag", "lunes"], ["Mittwoch", "miércoles"], ["Freitag", "viernes"]]}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$die_wochentage$p$, $p$reading$p$]),
('a0d47dcd-9c20-589c-91ff-240cf83e6330'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','reading','multiple_choice',$p$¿Qué día viene después del 'Dienstag' (martes)?$p$,$j${"options": ["Mittwoch", "Montag", "Sonntag"]}$j$::jsonb,$j${"value": "Mittwoch"}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$die_wochentage$p$, $p$reading$p$]),
('4ac2eb29-1df2-5fe3-9951-796a00601031'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','writing','translation',$p$Traduce: Hoy es sábado.$p$,$j${"source": "Hoy es sábado."}$j$::jsonb,$j${"value": "Heute ist Samstag.", "accepted": ["Heute ist Samstag.", "Heute ist Samstag", "Heute ist Sonnabend.", "Heute ist Sonnabend"]}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$die_wochentage$p$, $p$writing$p$]),
('ca175311-df16-5f08-8cd2-754e2858db7f'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','writing','reorder',$p$Ordena la frase: 'El domingo yo juego fútbol.'$p$,$j${"tiles": ["spiele", "Am", "ich", "Sonntag", "Fußball"]}$j$::jsonb,$j${"value": "Am Sonntag spiele ich Fußball"}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$die_wochentage$p$, $p$writing$p$]),
('91ef6f53-1585-5f38-8fd5-bc831d77846d'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Heute ist Donnerstag.", "Heute ist Dienstag.", "Heute ist Montag."], "say": "Heute ist Donnerstag.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/91ef6f53-1585-5f38-8fd5-bc831d77846d.mp3"}$j$::jsonb,$j${"value": "Heute ist Donnerstag."}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$die_wochentage$p$, $p$listening$p$]),
('4d6c539d-379c-5117-9a75-356855358313'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Am Freitag arbeite ich nicht.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/4d6c539d-379c-5117-9a75-356855358313.mp3"}$j$::jsonb,$j${"expected": "Am Freitag arbeite ich nicht."}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$die_wochentage$p$, $p$speaking$p$]),
('01cafb48-72a8-5796-ac40-5e18a540d435'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','reading','multiple_choice',$p$Completa: 'Du ___ in Berlin.' (tú vives)$p$,$j${"options": ["wohnst", "wohne", "wohnen"]}$j$::jsonb,$j${"value": "wohnst"}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$regelmaessige_verben$p$, $p$reading$p$]),
('e3f0ab88-0fb4-5cf5-bdc7-b39cea6bdcb7'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','writing','translation',$p$Traduce: Yo trabajo en Múnich.$p$,$j${"source": "Yo trabajo en Múnich."}$j$::jsonb,$j${"value": "Ich arbeite in München.", "accepted": ["Ich arbeite in München.", "Ich arbeite in München", "Ich arbeite in Muenchen.", "Ich arbeite in Muenchen"]}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$regelmaessige_verben$p$, $p$writing$p$]),
('8445b50e-fbbe-5def-af56-91df3e7bdaef'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Ich wohne in Berlin und lerne Deutsch.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/8445b50e-fbbe-5def-af56-91df3e7bdaef.mp3"}$j$::jsonb,$j${"expected": "Ich wohne in Berlin und lerne Deutsch."}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$regelmaessige_verben$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('a373f2b9-6aa1-55c3-bf8c-cf5d156d35e4','9f8d04bc-bbcf-5ff7-ad33-af0792eba997',1),
 ('a373f2b9-6aa1-55c3-bf8c-cf5d156d35e4','74065adc-3921-557f-940a-638040999851',2),
 ('a373f2b9-6aa1-55c3-bf8c-cf5d156d35e4','7bbaf642-81c1-5d98-b973-0a3d3729c8c6',3),
 ('a373f2b9-6aa1-55c3-bf8c-cf5d156d35e4','ca9b5107-9b22-5667-bb53-5b09f31bdfce',4),
 ('a373f2b9-6aa1-55c3-bf8c-cf5d156d35e4','277b7710-7f74-51e5-80e4-d9c569d3ca9f',5),
 ('da0804e2-d240-5294-a029-360ba3d4fe61','04ddf897-a7ad-5e90-8084-e3b9fbb59588',1),
 ('da0804e2-d240-5294-a029-360ba3d4fe61','7540d832-e995-57a4-be8a-167d2a04d623',2),
 ('da0804e2-d240-5294-a029-360ba3d4fe61','50e4692e-0baa-59be-a442-da412f18d4d0',3),
 ('da0804e2-d240-5294-a029-360ba3d4fe61','d6649784-fec1-5cbd-838a-3871796f0df1',4),
 ('da0804e2-d240-5294-a029-360ba3d4fe61','7c6e74d3-acb5-5d79-b6c1-65a3391b8e0b',5),
 ('f6303ba5-78ea-5cfa-b57f-08af6239ae9a','87702b3e-24ea-54d9-9af5-0271938459bd',1),
 ('f6303ba5-78ea-5cfa-b57f-08af6239ae9a','a0d47dcd-9c20-589c-91ff-240cf83e6330',2),
 ('f6303ba5-78ea-5cfa-b57f-08af6239ae9a','4ac2eb29-1df2-5fe3-9951-796a00601031',3),
 ('f6303ba5-78ea-5cfa-b57f-08af6239ae9a','ca175311-df16-5f08-8cd2-754e2858db7f',4),
 ('f6303ba5-78ea-5cfa-b57f-08af6239ae9a','91ef6f53-1585-5f38-8fd5-bc831d77846d',5),
 ('f6303ba5-78ea-5cfa-b57f-08af6239ae9a','4d6c539d-379c-5117-9a75-356855358313',6),
 ('af49f5cc-5635-580c-97fe-c1d9e3007a5b','01cafb48-72a8-5796-ac40-5e18a540d435',1),
 ('af49f5cc-5635-580c-97fe-c1d9e3007a5b','e3f0ab88-0fb4-5cf5-bdc7-b39cea6bdcb7',2),
 ('af49f5cc-5635-580c-97fe-c1d9e3007a5b','8445b50e-fbbe-5def-af56-91df3e7bdaef',3),
 ('684cb514-ad4e-5a91-9733-5d5f83d292e2','9f8d04bc-bbcf-5ff7-ad33-af0792eba997',1),
 ('684cb514-ad4e-5a91-9733-5d5f83d292e2','74065adc-3921-557f-940a-638040999851',2),
 ('684cb514-ad4e-5a91-9733-5d5f83d292e2','04ddf897-a7ad-5e90-8084-e3b9fbb59588',3),
 ('684cb514-ad4e-5a91-9733-5d5f83d292e2','7bbaf642-81c1-5d98-b973-0a3d3729c8c6',4),
 ('684cb514-ad4e-5a91-9733-5d5f83d292e2','7540d832-e995-57a4-be8a-167d2a04d623',5),
 ('684cb514-ad4e-5a91-9733-5d5f83d292e2','50e4692e-0baa-59be-a442-da412f18d4d0',6),
 ('684cb514-ad4e-5a91-9733-5d5f83d292e2','ca9b5107-9b22-5667-bb53-5b09f31bdfce',7),
 ('684cb514-ad4e-5a91-9733-5d5f83d292e2','d6649784-fec1-5cbd-838a-3871796f0df1',8),
 ('684cb514-ad4e-5a91-9733-5d5f83d292e2','277b7710-7f74-51e5-80e4-d9c569d3ca9f',9),
 ('684cb514-ad4e-5a91-9733-5d5f83d292e2','4d6c539d-379c-5117-9a75-356855358313',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('8ec363a1-5c86-5437-82e8-e31ee5a841ad','20000000-0000-0000-0000-000000000005',$p$die Uhr$p$,$p$el reloj / la hora$p$,201,'sustantivo'),
 ('89338545-4aa9-5669-bdf9-b5f4fcc92b4e','20000000-0000-0000-0000-000000000005',$p$die Stunde$p$,$p$la hora (duración)$p$,202,'sustantivo'),
 ('d8e6bc8c-f4bb-5824-8301-a49abab15d70','20000000-0000-0000-0000-000000000005',$p$die Minute$p$,$p$el minuto$p$,203,'sustantivo'),
 ('7eea886a-817e-58bb-ad27-5eb3401668fa','20000000-0000-0000-0000-000000000005',$p$Viertel$p$,$p$cuarto$p$,204,'sustantivo'),
 ('845ef3d9-11cd-5253-995e-8e2708d196c0','20000000-0000-0000-0000-000000000005',$p$halb$p$,$p$medio/a$p$,205,'adjetivo'),
 ('dc3a89d1-b95b-5db0-860e-2b8e7b23a34f','20000000-0000-0000-0000-000000000005',$p$der Montag$p$,$p$el lunes$p$,206,'sustantivo'),
 ('69f3f98f-cbf8-5c3e-86cc-5aca84adf0b7','20000000-0000-0000-0000-000000000005',$p$der Dienstag$p$,$p$el martes$p$,207,'sustantivo'),
 ('84326fc6-2f1b-5eba-b445-5a5e2a7ab4fb','20000000-0000-0000-0000-000000000005',$p$der Mittwoch$p$,$p$el miércoles$p$,208,'sustantivo'),
 ('274d1fec-de30-5cf6-9cb1-c22641e40439','20000000-0000-0000-0000-000000000005',$p$der Donnerstag$p$,$p$el jueves$p$,209,'sustantivo'),
 ('3ed24e33-abc6-5234-b10e-6175f3837d28','20000000-0000-0000-0000-000000000005',$p$der Freitag$p$,$p$el viernes$p$,210,'sustantivo'),
 ('433f7782-d844-5b7c-a122-23c741d99ea1','20000000-0000-0000-0000-000000000005',$p$der Samstag$p$,$p$el sábado$p$,211,'sustantivo'),
 ('94da38ec-7a06-5b48-ba50-0e0eb85ef1f0','20000000-0000-0000-0000-000000000005',$p$der Sonntag$p$,$p$el domingo$p$,212,'sustantivo'),
 ('ebe4de34-e8f5-5e2f-96ca-094442f8415d','20000000-0000-0000-0000-000000000005',$p$wohnen$p$,$p$vivir/residir$p$,213,'verbo'),
 ('5042161b-d70e-56fe-863c-61f24eb5cce6','20000000-0000-0000-0000-000000000005',$p$arbeiten$p$,$p$trabajar$p$,214,'verbo'),
 ('d5e57b96-7a4e-5991-933a-707bf1458cec','20000000-0000-0000-0000-000000000005',$p$lernen$p$,$p$aprender/estudiar$p$,215,'verbo'),
 ('ef69ed15-db0b-5819-b456-9bada652ae5b','20000000-0000-0000-0000-000000000005',$p$spielen$p$,$p$jugar$p$,216,'verbo')
on conflict (id) do nothing;

-- ── Unidad 6 (A1·de): La ciudad y direcciones ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('732cd19e-da91-52bc-974c-97431fb3f0e7','20000000-0000-0000-0000-000000000005','A1',6,$p$La ciudad y direcciones$p$,'#16A085','location_city')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('37a33bad-46f4-55ed-8249-cc1d22304a6a','732cd19e-da91-52bc-974c-97431fb3f0e7',1,$p$Lugares de la ciudad$p$,$p$Lugares de la ciudad$p$,'lesson',15),
 ('78f71ffd-a6e0-598f-9e5f-738b50811559','732cd19e-da91-52bc-974c-97431fb3f0e7',2,$p$¿Dónde está...?$p$,$p$¿Dónde está...?$p$,'lesson',15),
 ('775feaa0-7924-5891-b509-b8bbb2380441','732cd19e-da91-52bc-974c-97431fb3f0e7',3,$p$¿Hay...? Es gibt...$p$,$p$¿Hay...? Es gibt...$p$,'lesson',15),
 ('761504b2-7d52-586e-a9fd-1f1d8d6fc7c3','732cd19e-da91-52bc-974c-97431fb3f0e7',4,$p$Izquierda, derecha, todo recto$p$,$p$Izquierda, derecha, todo recto$p$,'lesson',15),
 ('69b21cc8-ec2a-5db6-ba90-8a7eb3674dfe','732cd19e-da91-52bc-974c-97431fb3f0e7',5,$p$🏁 Checkpoint Einheit 6$p$,$p$Nombrar lugares de la ciudad, preguntar dónde están y dar direcciones con izquierda, derecha y todo recto.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('84c461c7-ead7-5889-b5e1-7cf22e08d5da','20000000-0000-0000-0000-000000000005','checkpoint','A1','732cd19e-da91-52bc-974c-97431fb3f0e7',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('3b323e8f-b90d-54e8-b2c4-659256be6e0c'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','reading','match',$p$Une cada lugar alemán con su significado.$p$,$j${"pairs": [{"en": "der Bahnhof", "es": "la estación de tren"}, {"en": "das Museum", "es": "el museo"}, {"en": "die Apotheke", "es": "la farmacia"}]}$j$::jsonb,$j${"pairs": [["der Bahnhof", "la estación de tren"], ["das Museum", "el museo"], ["die Apotheke", "la farmacia"]]}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$orte_in_der_stadt$p$, $p$reading$p$]),
('5f23c00c-eadb-51f2-9334-a822ee206752'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','reading','multiple_choice',$p$¿Cuál es el artículo correcto? '___ Restaurant'$p$,$j${"options": ["das", "der", "die"]}$j$::jsonb,$j${"value": "das"}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$orte_in_der_stadt$p$, $p$reading$p$]),
('7ec07449-4274-5284-b979-580d003d1b2d'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','writing','cloze',$p$Completa: 'el hotel' -> '___ Hotel'$p$,$j${"text": "___ Hotel"}$j$::jsonb,$j${"value": "das", "accepted": ["das"]}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$orte_in_der_stadt$p$, $p$writing$p$]),
('28c288d3-6f85-53f4-b1cf-4f9be199ef2f'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Das ist der Bahnhof.", "Das ist die Apotheke.", "Das ist das Hotel."], "say": "Das ist der Bahnhof.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/28c288d3-6f85-53f4-b1cf-4f9be199ef2f.mp3"}$j$::jsonb,$j${"value": "Das ist der Bahnhof."}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$orte_in_der_stadt$p$, $p$listening$p$]),
('dada1458-f7f7-571c-b333-e3f971a5871d'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Das Museum ist sehr schön.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/dada1458-f7f7-571c-b333-e3f971a5871d.mp3"}$j$::jsonb,$j${"expected": "Das Museum ist sehr schön."}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$orte_in_der_stadt$p$, $p$speaking$p$]),
('99671589-cac4-5325-9d12-dc216dbd46ea'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','reading','multiple_choice',$p$¿Cómo se pregunta '¿Dónde está la estación?'$p$,$j${"options": ["Wo ist der Bahnhof?", "Wer ist der Bahnhof?", "Was ist der Bahnhof?"]}$j$::jsonb,$j${"value": "Wo ist der Bahnhof?"}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$wo_ist$p$, $p$reading$p$]),
('99b9f4bc-b964-5b1b-a695-3e207b94afb0'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','writing','translation',$p$Traduce: ¿Dónde está el hotel?$p$,$j${"source": "¿Dónde está el hotel?"}$j$::jsonb,$j${"value": "Wo ist das Hotel?", "accepted": ["Wo ist das Hotel?", "Wo ist das Hotel"]}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$wo_ist$p$, $p$writing$p$]),
('a0eb953c-9c5e-594c-99d7-9da04c20f87e'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','writing','word_bank',$p$Ordena para decir 'El banco está al lado del museo.'$p$,$j${"tiles": ["Die", "Bank", "ist", "neben", "dem", "Museum", "gegenüber"]}$j$::jsonb,$j${"value": "Die Bank ist neben dem Museum", "sequence": ["Die", "Bank", "ist", "neben", "dem", "Museum"]}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$wo_ist$p$, $p$writing$p$]),
('7989e90e-0a5c-5a8b-bf89-aa49be26fd1c'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Wo ist die Apotheke?", "Wo ist der Bahnhof?", "Wo ist das Restaurant?"], "say": "Wo ist die Apotheke?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/7989e90e-0a5c-5a8b-bf89-aa49be26fd1c.mp3"}$j$::jsonb,$j${"value": "Wo ist die Apotheke?"}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$wo_ist$p$, $p$listening$p$]),
('8019c582-e47a-54dc-a1d6-f7d2860ece3f'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Das Restaurant ist gegenüber dem Hotel.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/8019c582-e47a-54dc-a1d6-f7d2860ece3f.mp3"}$j$::jsonb,$j${"expected": "Das Restaurant ist gegenüber dem Hotel."}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$wo_ist$p$, $p$speaking$p$]),
('17cab0be-24c5-5974-b06f-13b37afe9389'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','reading','multiple_choice',$p$Completa: 'Aquí hay un banco.' -> 'Hier gibt es ___ Bank.' (die Bank, femenino)$p$,$j${"options": ["eine", "einen", "ein"]}$j$::jsonb,$j${"value": "eine"}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$es_gibt$p$, $p$reading$p$]),
('f9e9585f-24a1-58bf-874c-24f82a5fd5b9'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','writing','cloze',$p$Completa: 'Hay un restaurante.' -> 'Es gibt ___ Restaurant.' (das Restaurant, neutro)$p$,$j${"text": "Es gibt ___ Restaurant."}$j$::jsonb,$j${"value": "ein", "accepted": ["ein"]}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$es_gibt$p$, $p$writing$p$]),
('67ab7ced-0024-5220-92fa-3811cdb67f32'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','reading','multiple_choice',$p$¿Cómo se pregunta '¿Hay una farmacia aquí?'$p$,$j${"options": ["Gibt es hier eine Apotheke?", "Ist es hier eine Apotheke?", "Hat es hier eine Apotheke?"]}$j$::jsonb,$j${"value": "Gibt es hier eine Apotheke?"}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$es_gibt$p$, $p$reading$p$]),
('d944a276-4133-5f2e-bca4-b5fe41b994f7'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Es gibt hier ein Hotel.", "Es gibt hier eine Bank.", "Es gibt hier ein Museum."], "say": "Es gibt hier ein Hotel.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/d944a276-4133-5f2e-bca4-b5fe41b994f7.mp3"}$j$::jsonb,$j${"value": "Es gibt hier ein Hotel."}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$es_gibt$p$, $p$listening$p$]),
('6d62c28d-e04d-5d89-bf52-75ce4db1117d'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','reading','match',$p$Une cada dirección con su significado.$p$,$j${"pairs": [{"en": "links", "es": "a la izquierda"}, {"en": "rechts", "es": "a la derecha"}, {"en": "geradeaus", "es": "todo recto"}]}$j$::jsonb,$j${"pairs": [["links", "a la izquierda"], ["rechts", "a la derecha"], ["geradeaus", "todo recto"]]}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$richtungen$p$, $p$reading$p$]),
('4415c286-b48c-5f7f-8e27-55d8598cddb3'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','writing','translation',$p$Traduce: El banco está a la derecha.$p$,$j${"source": "El banco está a la derecha."}$j$::jsonb,$j${"value": "Die Bank ist rechts.", "accepted": ["Die Bank ist rechts.", "Die Bank ist rechts"]}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$richtungen$p$, $p$writing$p$]),
('33ec9b5f-a3db-5839-b435-ad609600c841'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','writing','word_bank',$p$Ordena para decir 'Ve todo recto y después a la izquierda.'$p$,$j${"tiles": ["Gehen", "Sie", "geradeaus", "und", "dann", "links", "rechts"]}$j$::jsonb,$j${"value": "Gehen Sie geradeaus und dann links", "sequence": ["Gehen", "Sie", "geradeaus", "und", "dann", "links"]}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$richtungen$p$, $p$writing$p$]),
('51a15f9d-979a-5e84-bf68-eab22c1d18e4'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Der Bahnhof ist geradeaus.", "Der Bahnhof ist links.", "Der Bahnhof ist rechts."], "say": "Der Bahnhof ist geradeaus.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/51a15f9d-979a-5e84-bf68-eab22c1d18e4.mp3"}$j$::jsonb,$j${"value": "Der Bahnhof ist geradeaus."}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$richtungen$p$, $p$listening$p$]),
('560dcaf3-bd20-5695-9fdc-a62642cfcff3'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Gehen Sie geradeaus, dann links.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/560dcaf3-bd20-5695-9fdc-a62642cfcff3.mp3"}$j$::jsonb,$j${"expected": "Gehen Sie geradeaus, dann links."}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$richtungen$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('37a33bad-46f4-55ed-8249-cc1d22304a6a','3b323e8f-b90d-54e8-b2c4-659256be6e0c',1),
 ('37a33bad-46f4-55ed-8249-cc1d22304a6a','5f23c00c-eadb-51f2-9334-a822ee206752',2),
 ('37a33bad-46f4-55ed-8249-cc1d22304a6a','7ec07449-4274-5284-b979-580d003d1b2d',3),
 ('37a33bad-46f4-55ed-8249-cc1d22304a6a','28c288d3-6f85-53f4-b1cf-4f9be199ef2f',4),
 ('37a33bad-46f4-55ed-8249-cc1d22304a6a','dada1458-f7f7-571c-b333-e3f971a5871d',5),
 ('78f71ffd-a6e0-598f-9e5f-738b50811559','99671589-cac4-5325-9d12-dc216dbd46ea',1),
 ('78f71ffd-a6e0-598f-9e5f-738b50811559','99b9f4bc-b964-5b1b-a695-3e207b94afb0',2),
 ('78f71ffd-a6e0-598f-9e5f-738b50811559','a0eb953c-9c5e-594c-99d7-9da04c20f87e',3),
 ('78f71ffd-a6e0-598f-9e5f-738b50811559','7989e90e-0a5c-5a8b-bf89-aa49be26fd1c',4),
 ('78f71ffd-a6e0-598f-9e5f-738b50811559','8019c582-e47a-54dc-a1d6-f7d2860ece3f',5),
 ('775feaa0-7924-5891-b509-b8bbb2380441','17cab0be-24c5-5974-b06f-13b37afe9389',1),
 ('775feaa0-7924-5891-b509-b8bbb2380441','f9e9585f-24a1-58bf-874c-24f82a5fd5b9',2),
 ('775feaa0-7924-5891-b509-b8bbb2380441','67ab7ced-0024-5220-92fa-3811cdb67f32',3),
 ('775feaa0-7924-5891-b509-b8bbb2380441','d944a276-4133-5f2e-bca4-b5fe41b994f7',4),
 ('761504b2-7d52-586e-a9fd-1f1d8d6fc7c3','6d62c28d-e04d-5d89-bf52-75ce4db1117d',1),
 ('761504b2-7d52-586e-a9fd-1f1d8d6fc7c3','4415c286-b48c-5f7f-8e27-55d8598cddb3',2),
 ('761504b2-7d52-586e-a9fd-1f1d8d6fc7c3','33ec9b5f-a3db-5839-b435-ad609600c841',3),
 ('761504b2-7d52-586e-a9fd-1f1d8d6fc7c3','51a15f9d-979a-5e84-bf68-eab22c1d18e4',4),
 ('761504b2-7d52-586e-a9fd-1f1d8d6fc7c3','560dcaf3-bd20-5695-9fdc-a62642cfcff3',5),
 ('69b21cc8-ec2a-5db6-ba90-8a7eb3674dfe','3b323e8f-b90d-54e8-b2c4-659256be6e0c',1),
 ('69b21cc8-ec2a-5db6-ba90-8a7eb3674dfe','5f23c00c-eadb-51f2-9334-a822ee206752',2),
 ('69b21cc8-ec2a-5db6-ba90-8a7eb3674dfe','99671589-cac4-5325-9d12-dc216dbd46ea',3),
 ('69b21cc8-ec2a-5db6-ba90-8a7eb3674dfe','7ec07449-4274-5284-b979-580d003d1b2d',4),
 ('69b21cc8-ec2a-5db6-ba90-8a7eb3674dfe','99b9f4bc-b964-5b1b-a695-3e207b94afb0',5),
 ('69b21cc8-ec2a-5db6-ba90-8a7eb3674dfe','a0eb953c-9c5e-594c-99d7-9da04c20f87e',6),
 ('69b21cc8-ec2a-5db6-ba90-8a7eb3674dfe','28c288d3-6f85-53f4-b1cf-4f9be199ef2f',7),
 ('69b21cc8-ec2a-5db6-ba90-8a7eb3674dfe','7989e90e-0a5c-5a8b-bf89-aa49be26fd1c',8),
 ('69b21cc8-ec2a-5db6-ba90-8a7eb3674dfe','dada1458-f7f7-571c-b333-e3f971a5871d',9),
 ('69b21cc8-ec2a-5db6-ba90-8a7eb3674dfe','8019c582-e47a-54dc-a1d6-f7d2860ece3f',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('a73f6d0f-9496-5bcc-888a-c4b0d627f303','20000000-0000-0000-0000-000000000005',$p$der Bahnhof$p$,$p$la estación de tren$p$,221,'sustantivo'),
 ('e7625f33-e754-5372-b40e-72564a178ed5','20000000-0000-0000-0000-000000000005',$p$die Bank$p$,$p$el banco$p$,222,'sustantivo'),
 ('3b7def45-eaf6-50b9-926f-50356b32a985','20000000-0000-0000-0000-000000000005',$p$das Museum$p$,$p$el museo$p$,223,'sustantivo'),
 ('d18adc83-9cfb-57ab-9871-d2d851506d4f','20000000-0000-0000-0000-000000000005',$p$das Restaurant$p$,$p$el restaurante$p$,224,'sustantivo'),
 ('1030a000-e72e-5da7-84c5-b0c831759005','20000000-0000-0000-0000-000000000005',$p$das Hotel$p$,$p$el hotel$p$,225,'sustantivo'),
 ('41b2f501-d1dc-5386-bc04-3319d5acb908','20000000-0000-0000-0000-000000000005',$p$der Platz$p$,$p$la plaza$p$,226,'sustantivo'),
 ('ac289967-136d-553e-97a3-ac5b63b3655e','20000000-0000-0000-0000-000000000005',$p$die Straße$p$,$p$la calle$p$,227,'sustantivo'),
 ('366450d5-429a-5a2b-ae63-8abf36d38d39','20000000-0000-0000-0000-000000000005',$p$die Apotheke$p$,$p$la farmacia$p$,228,'sustantivo'),
 ('bcba311e-adcf-5983-b997-8d12c436e9f4','20000000-0000-0000-0000-000000000005',$p$die Stadt$p$,$p$la ciudad$p$,229,'sustantivo'),
 ('767c4209-6c93-5142-9276-781dc77d1b1d','20000000-0000-0000-0000-000000000005',$p$links$p$,$p$a la izquierda$p$,230,'adverbio'),
 ('9004e696-fc38-51c9-a374-c82b9006daa2','20000000-0000-0000-0000-000000000005',$p$rechts$p$,$p$a la derecha$p$,231,'adverbio'),
 ('08473fac-6abd-5184-86dc-44a63c23c5a6','20000000-0000-0000-0000-000000000005',$p$geradeaus$p$,$p$todo recto$p$,232,'adverbio'),
 ('463ede16-a9e6-5af0-8233-ff655d85c147','20000000-0000-0000-0000-000000000005',$p$neben$p$,$p$al lado de$p$,233,'preposicion'),
 ('1f35379e-a01e-5a0d-a423-77fccf6dd52e','20000000-0000-0000-0000-000000000005',$p$gegenüber$p$,$p$enfrente de$p$,234,'preposicion'),
 ('41dc0168-f32a-583a-a6ba-aaed31f60611','20000000-0000-0000-0000-000000000005',$p$wo$p$,$p$dónde$p$,235,'adverbio'),
 ('64004128-0c99-5925-9f7d-f42d3425edda','20000000-0000-0000-0000-000000000005',$p$es gibt$p$,$p$hay$p$,236,'expresion')
on conflict (id) do nothing;

commit;