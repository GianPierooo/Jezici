-- 20260703120095_seed_it_a1.sql
-- Alta del curso es→it + currículo A1 (6 unidades). Molde es→pt
-- (mig 047+048). Contenido scopeado a course_id=20000000-0000-0000-0000-000000000004 → aislamiento
-- multicurso por jz_active_course (RPCs ya course-aware). ids uuid5 idempotentes.
begin;
insert into languages (id, code, name) values
  ('10000000-0000-0000-0000-000000000005','it',$p$Italiano$p$) on conflict (id) do nothing;
insert into courses (id, source_language_id, target_language_id, is_active) values
  ('20000000-0000-0000-0000-000000000004','10000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000005',true) on conflict (id) do nothing;

-- ── Unidad 1 (A1·it): Ciao y piacere (saludos y presentarte) ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('a3897a7a-817c-540c-b91a-8a0000e44830','20000000-0000-0000-0000-000000000004','A1',1,$p$Ciao y piacere (saludos y presentarte)$p$,'#27AE60','waving_hand')
on conflict (course_id, order_index) do update set title=excluded.title, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('45dc9d2b-8802-5a8f-906b-3a427017329e','a3897a7a-817c-540c-b91a-8a0000e44830',1,$p$Saludos y despedidas$p$,$p$Saludos y despedidas$p$,'lesson',15),
 ('fe936dac-87a2-5872-b1b0-e34d7f8c62b4','a3897a7a-817c-540c-b91a-8a0000e44830',2,$p$Presentarte: mi chiamo$p$,$p$Presentarte: mi chiamo$p$,'lesson',15),
 ('b723dccb-e14c-57d9-89d8-ab7554827519','a3897a7a-817c-540c-b91a-8a0000e44830',3,$p$Tú o usted + el verbo essere$p$,$p$Tú o usted + el verbo essere$p$,'lesson',15),
 ('9f58bd64-32a9-5086-9757-db5d36d5f4f8','a3897a7a-817c-540c-b91a-8a0000e44830',4,$p$¿Cómo estás? come stai?$p$,$p$¿Cómo estás? come stai?$p$,'lesson',15),
 ('75bb5211-6c0f-5b6e-a8e3-e6d2bcaf0701','a3897a7a-817c-540c-b91a-8a0000e44830',5,$p$🏁 Checkpoint Unité 1$p$,$p$Practica saludar, despedirte, presentarte con «mi chiamo» y usar el verbo essere junto a la distinción tú/usted (tu/Lei).$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('b6efdfba-a4ca-522b-bc55-6e11a956325d','20000000-0000-0000-0000-000000000004','checkpoint','A1','a3897a7a-817c-540c-b91a-8a0000e44830',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('815545bd-34f1-53cd-9b44-714c9ebecd23'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','reading','match',$p$Empareja cada saludo con su traducción.$p$,$j${"pairs": [{"en": "buongiorno", "es": "buenos días"}, {"en": "ciao", "es": "hola (informal)"}, {"en": "arrivederci", "es": "adiós"}]}$j$::jsonb,$j${"pairs": [["buongiorno", "buenos días"], ["ciao", "hola (informal)"], ["arrivederci", "adiós"]]}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$saludos_despedidas$p$, $p$reading$p$]),
('b5ebac70-81b3-5d9a-a870-48775f3ffc8f'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','reading','multiple_choice',$p$¿Qué dices por la noche, antes de irte a dormir?$p$,$j${"options": ["buonanotte", "buongiorno", "ciao"]}$j$::jsonb,$j${"value": "buonanotte"}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$saludos_despedidas$p$, $p$reading$p$]),
('9c45dac9-4db8-581a-89ee-b4fe698cca86'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Buonasera, come sta?", "Buongiorno, come stai?", "Buonanotte, grazie."], "say": "Buonasera, come sta?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/9c45dac9-4db8-581a-89ee-b4fe698cca86.mp3"}$j$::jsonb,$j${"value": "Buonasera, come sta?"}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$saludos_despedidas$p$, $p$listening$p$]),
('6702192d-d541-5a7a-8494-26d839013863'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Arrivederci, a presto!", "Buongiorno, come stai?", "Buonanotte, grazie."], "say": "Arrivederci, a presto!", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/6702192d-d541-5a7a-8494-26d839013863.mp3"}$j$::jsonb,$j${"value": "Arrivederci, a presto!"}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$saludos_despedidas$p$, $p$listening$p$]),
('fd064942-040e-5e00-aafd-58523d23e8cc'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Ciao! Buongiorno! Arrivederci!", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/fd064942-040e-5e00-aafd-58523d23e8cc.mp3"}$j$::jsonb,$j${"expected": "Ciao! Buongiorno! Arrivederci!"}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$saludos_despedidas$p$, $p$speaking$p$]),
('e9fd4d9e-2176-5635-a16a-c042df259ef5'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','reading','multiple_choice',$p$¿Cómo dices «me llamo Maria»?$p$,$j${"options": ["Mi chiamo Maria.", "Ti chiami Maria.", "Si chiama Maria."]}$j$::jsonb,$j${"value": "Mi chiamo Maria."}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$presentarse$p$, $p$reading$p$]),
('cb1dd2af-2f2f-5e49-963e-fd0d83f6dc2f'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','writing','cloze',$p$Completa: «Me llamo Paolo».$p$,$j${"text": "Mi ___ Paolo."}$j$::jsonb,$j${"value": "chiamo", "accepted": ["chiamo"]}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$presentarse$p$, $p$writing$p$]),
('a494285f-0549-55ca-9680-d66e99d71fa3'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','writing','word_bank',$p$Arma la frase: «Me llamo Anna».$p$,$j${"tiles": ["Mi", "chiamo", "Anna", "sono", "ti"]}$j$::jsonb,$j${"value": "Mi chiamo Anna", "sequence": ["Mi", "chiamo", "Anna"]}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$presentarse$p$, $p$writing$p$]),
('17337cdb-fcd1-59f3-9545-7c6d7d421ce9'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Ciao! Mi chiamo Maria. Piacere!", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/17337cdb-fcd1-59f3-9545-7c6d7d421ce9.mp3"}$j$::jsonb,$j${"expected": "Ciao! Mi chiamo Maria. Piacere!"}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$presentarse$p$, $p$speaking$p$]),
('a4f12e76-f665-58ad-a34c-c6b8d63eff37'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Buongiorno! Mi chiamo Paolo. Piacere di conoscerti!", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/a4f12e76-f665-58ad-a34c-c6b8d63eff37.mp3"}$j$::jsonb,$j${"expected": "Buongiorno! Mi chiamo Paolo. Piacere di conoscerti!"}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$presentarse$p$, $p$speaking$p$]),
('17a4e8fc-50c5-557b-ae65-cbdb133aab7b'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','reading','match',$p$Empareja cada forma del verbo essere con su pronombre.$p$,$j${"pairs": [{"en": "io sono", "es": "yo soy"}, {"en": "tu sei", "es": "tú eres"}, {"en": "lui è", "es": "él es"}]}$j$::jsonb,$j${"pairs": [["io sono", "yo soy"], ["tu sei", "tú eres"], ["lui è", "él es"]]}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$tu_lei_essere$p$, $p$reading$p$]),
('9172912b-2eef-5591-8758-c2a65c2f9c97'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','reading','multiple_choice',$p$Hablas con tu jefe (usted, forma de cortesía Lei). ¿Cómo le preguntas su nombre?$p$,$j${"options": ["Come si chiama?", "Come ti chiami?", "Come mi chiamo?"]}$j$::jsonb,$j${"value": "Come si chiama?"}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$tu_lei_essere$p$, $p$reading$p$]),
('36f6638a-7ba4-5c15-b24f-fa574e0b2d25'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','writing','cloze',$p$Completa con el verbo essere: «Tú eres spagnolo».$p$,$j${"text": "Tu ___ spagnolo."}$j$::jsonb,$j${"value": "sei", "accepted": ["sei"]}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$tu_lei_essere$p$, $p$writing$p$]),
('4108a0b2-329f-5603-aae9-679b06bd32f3'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','writing','reorder',$p$Ordena: «¿Cómo te llamas?» (tú).$p$,$j${"tiles": ["chiami", "Come", "ti"]}$j$::jsonb,$j${"value": "Come ti chiami"}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$tu_lei_essere$p$, $p$writing$p$]),
('8644dd2d-da45-588b-8552-ead53254db2a'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Io sono Marco.", "Tu sei spagnolo.", "Lei è Maria."], "say": "Io sono Marco.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/8644dd2d-da45-588b-8552-ead53254db2a.mp3"}$j$::jsonb,$j${"value": "Io sono Marco."}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$tu_lei_essere$p$, $p$listening$p$]),
('b67356ee-d1bf-5b76-bd59-332129809a58'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','reading','multiple_choice',$p$Un amigo te pregunta «Come stai?». ¿Cómo respondes que estás muy bien y das las gracias?$p$,$j${"options": ["Molto bene, grazie!", "Arrivederci!", "Buonanotte!"]}$j$::jsonb,$j${"value": "Molto bene, grazie!"}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$come_stai$p$, $p$reading$p$]),
('43214526-b4bc-533e-9b5f-c4b029a22112'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','writing','translation',$p$Traduce: «¿Cómo estás? Muy bien, gracias».$p$,$j${"source": "¿Cómo estás? Muy bien, gracias."}$j$::jsonb,$j${"value": "Come stai? Molto bene, grazie.", "accepted": ["Come stai? Molto bene, grazie.", "Come stai? Molto bene, grazie", "Come stai Molto bene grazie", "come stai? molto bene, grazie.", "Come stai molto bene grazie"]}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$come_stai$p$, $p$writing$p$]),
('b5af01f7-65c2-5f92-9ced-ac088e7834e1'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','writing','translation',$p$Traduce: «¿Y tú?» (informal).$p$,$j${"source": "¿Y tú?"}$j$::jsonb,$j${"value": "E tu?", "accepted": ["E tu?", "E tu", "e tu?", "e tu"]}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$come_stai$p$, $p$writing$p$]),
('0f57df83-182e-517e-8724-78dde6ff5348'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Come stai?", "Come si chiama?", "Buonasera, a presto."], "say": "Come stai?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/0f57df83-182e-517e-8724-78dde6ff5348.mp3"}$j$::jsonb,$j${"value": "Come stai?"}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$come_stai$p$, $p$listening$p$]),
('be1c27df-9535-5c6c-9613-202ad473cce8'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Molto bene, e tu?", "Ciao, piacere.", "Grazie, arrivederci."], "say": "Molto bene, e tu?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/be1c27df-9535-5c6c-9613-202ad473cce8.mp3"}$j$::jsonb,$j${"value": "Molto bene, e tu?"}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$come_stai$p$, $p$listening$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('45dc9d2b-8802-5a8f-906b-3a427017329e','815545bd-34f1-53cd-9b44-714c9ebecd23',1),
 ('45dc9d2b-8802-5a8f-906b-3a427017329e','b5ebac70-81b3-5d9a-a870-48775f3ffc8f',2),
 ('45dc9d2b-8802-5a8f-906b-3a427017329e','9c45dac9-4db8-581a-89ee-b4fe698cca86',3),
 ('45dc9d2b-8802-5a8f-906b-3a427017329e','6702192d-d541-5a7a-8494-26d839013863',4),
 ('45dc9d2b-8802-5a8f-906b-3a427017329e','fd064942-040e-5e00-aafd-58523d23e8cc',5),
 ('fe936dac-87a2-5872-b1b0-e34d7f8c62b4','e9fd4d9e-2176-5635-a16a-c042df259ef5',1),
 ('fe936dac-87a2-5872-b1b0-e34d7f8c62b4','cb1dd2af-2f2f-5e49-963e-fd0d83f6dc2f',2),
 ('fe936dac-87a2-5872-b1b0-e34d7f8c62b4','a494285f-0549-55ca-9680-d66e99d71fa3',3),
 ('fe936dac-87a2-5872-b1b0-e34d7f8c62b4','17337cdb-fcd1-59f3-9545-7c6d7d421ce9',4),
 ('fe936dac-87a2-5872-b1b0-e34d7f8c62b4','a4f12e76-f665-58ad-a34c-c6b8d63eff37',5),
 ('b723dccb-e14c-57d9-89d8-ab7554827519','17a4e8fc-50c5-557b-ae65-cbdb133aab7b',1),
 ('b723dccb-e14c-57d9-89d8-ab7554827519','9172912b-2eef-5591-8758-c2a65c2f9c97',2),
 ('b723dccb-e14c-57d9-89d8-ab7554827519','36f6638a-7ba4-5c15-b24f-fa574e0b2d25',3),
 ('b723dccb-e14c-57d9-89d8-ab7554827519','4108a0b2-329f-5603-aae9-679b06bd32f3',4),
 ('b723dccb-e14c-57d9-89d8-ab7554827519','8644dd2d-da45-588b-8552-ead53254db2a',5),
 ('9f58bd64-32a9-5086-9757-db5d36d5f4f8','b67356ee-d1bf-5b76-bd59-332129809a58',1),
 ('9f58bd64-32a9-5086-9757-db5d36d5f4f8','43214526-b4bc-533e-9b5f-c4b029a22112',2),
 ('9f58bd64-32a9-5086-9757-db5d36d5f4f8','b5af01f7-65c2-5f92-9ced-ac088e7834e1',3),
 ('9f58bd64-32a9-5086-9757-db5d36d5f4f8','0f57df83-182e-517e-8724-78dde6ff5348',4),
 ('9f58bd64-32a9-5086-9757-db5d36d5f4f8','be1c27df-9535-5c6c-9613-202ad473cce8',5),
 ('75bb5211-6c0f-5b6e-a8e3-e6d2bcaf0701','815545bd-34f1-53cd-9b44-714c9ebecd23',1),
 ('75bb5211-6c0f-5b6e-a8e3-e6d2bcaf0701','b5ebac70-81b3-5d9a-a870-48775f3ffc8f',2),
 ('75bb5211-6c0f-5b6e-a8e3-e6d2bcaf0701','e9fd4d9e-2176-5635-a16a-c042df259ef5',3),
 ('75bb5211-6c0f-5b6e-a8e3-e6d2bcaf0701','cb1dd2af-2f2f-5e49-963e-fd0d83f6dc2f',4),
 ('75bb5211-6c0f-5b6e-a8e3-e6d2bcaf0701','a494285f-0549-55ca-9680-d66e99d71fa3',5),
 ('75bb5211-6c0f-5b6e-a8e3-e6d2bcaf0701','36f6638a-7ba4-5c15-b24f-fa574e0b2d25',6),
 ('75bb5211-6c0f-5b6e-a8e3-e6d2bcaf0701','9c45dac9-4db8-581a-89ee-b4fe698cca86',7),
 ('75bb5211-6c0f-5b6e-a8e3-e6d2bcaf0701','6702192d-d541-5a7a-8494-26d839013863',8),
 ('75bb5211-6c0f-5b6e-a8e3-e6d2bcaf0701','fd064942-040e-5e00-aafd-58523d23e8cc',9),
 ('75bb5211-6c0f-5b6e-a8e3-e6d2bcaf0701','17337cdb-fcd1-59f3-9545-7c6d7d421ce9',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('1c1874a9-6ac5-584f-8594-31fe762b9b8c','20000000-0000-0000-0000-000000000004',$p$ciao$p$,$p$hola/chao (informal)$p$,121,'interjeccion'),
 ('9fb756d7-599c-557f-aba3-e5539499e1b9','20000000-0000-0000-0000-000000000004',$p$buongiorno$p$,$p$buenos días$p$,122,'interjeccion'),
 ('44f5725c-2a5b-57c2-97f9-c227f370d603','20000000-0000-0000-0000-000000000004',$p$buonasera$p$,$p$buenas tardes/noches$p$,123,'interjeccion'),
 ('c1a31d93-1385-530b-8102-5ce91d0398df','20000000-0000-0000-0000-000000000004',$p$buonanotte$p$,$p$buenas noches (al dormir)$p$,124,'interjeccion'),
 ('a2d0ff73-56c3-503f-b747-c6b8da8baa8d','20000000-0000-0000-0000-000000000004',$p$arrivederci$p$,$p$adiós/hasta la vista$p$,125,'interjeccion'),
 ('1605c7b4-6e61-5b12-8cf3-b536d91a1571','20000000-0000-0000-0000-000000000004',$p$a presto$p$,$p$hasta pronto$p$,126,'expresion'),
 ('b89c050e-3d85-537f-907b-28904e2de60e','20000000-0000-0000-0000-000000000004',$p$salve$p$,$p$hola (neutro/cortés)$p$,127,'interjeccion'),
 ('e09a7d3e-b99e-58d7-ab04-6ceb13a85fcd','20000000-0000-0000-0000-000000000004',$p$mi chiamo$p$,$p$me llamo$p$,128,'expresion'),
 ('f147ef3b-e0cd-5713-95bd-5be544d3d035','20000000-0000-0000-0000-000000000004',$p$piacere$p$,$p$encantado/mucho gusto$p$,129,'expresion'),
 ('88d0d145-de67-5781-9a56-9ee40ab35d89','20000000-0000-0000-0000-000000000004',$p$io sono$p$,$p$yo soy/estoy$p$,130,'verbo'),
 ('76827f0e-e565-5c70-93f1-94b48252bead','20000000-0000-0000-0000-000000000004',$p$tu sei$p$,$p$tú eres/estás$p$,131,'verbo'),
 ('8605a109-1701-5436-b7a6-fceb673137e2','20000000-0000-0000-0000-000000000004',$p$lui è$p$,$p$él es/está$p$,132,'verbo'),
 ('94094896-eb74-56fa-894e-33d772fa9e3a','20000000-0000-0000-0000-000000000004',$p$lei è$p$,$p$ella es/está$p$,133,'verbo'),
 ('2b138f81-2e00-5f78-9336-469eac38c013','20000000-0000-0000-0000-000000000004',$p$come stai$p$,$p$¿cómo estás? (tú)$p$,134,'expresion'),
 ('5f881ed5-00ef-5533-8342-f061d0bfdfef','20000000-0000-0000-0000-000000000004',$p$bene$p$,$p$bien$p$,135,'adverbio'),
 ('0e9e0340-d3d6-589c-817a-035beee3d6b5','20000000-0000-0000-0000-000000000004',$p$grazie$p$,$p$gracias$p$,136,'interjeccion')
on conflict (id) do nothing;

-- ── Unidad 2 (A1·it): I numeri, l'età e da dove vieni (números, edad y origen) ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('db2d2ef3-7be4-5022-bc30-68b6c2252fc4','20000000-0000-0000-0000-000000000004','A1',2,$p$I numeri, l'età e da dove vieni (números, edad y origen)$p$,'#2980B9','public')
on conflict (course_id, order_index) do update set title=excluded.title, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('63d885b0-c68e-5a51-b929-efe327eb5f8a','db2d2ef3-7be4-5022-bc30-68b6c2252fc4',1,$p$Los números 0 a 20$p$,$p$Los números 0 a 20$p$,'lesson',15),
 ('d1ee3c14-ff37-5dfe-b9d6-2000adc2afe4','db2d2ef3-7be4-5022-bc30-68b6c2252fc4',2,$p$La edad con avere$p$,$p$La edad con avere$p$,'lesson',15),
 ('99af5055-d51f-5a0e-b7b2-f300b7874b0a','db2d2ef3-7be4-5022-bc30-68b6c2252fc4',3,$p$¿De dónde vienes?$p$,$p$¿De dónde vienes?$p$,'lesson',15),
 ('6b0e8be4-c579-5857-97e2-206ccf7971ac','db2d2ef3-7be4-5022-bc30-68b6c2252fc4',4,$p$Nacionalidades$p$,$p$Nacionalidades$p$,'lesson',15),
 ('c6962442-0fbb-5117-8879-9193959f8ef4','db2d2ef3-7be4-5022-bc30-68b6c2252fc4',5,$p$🏁 Checkpoint Unité 2$p$,$p$Practica los números 0-20, decir tu edad con «avere», de dónde vienes con «venire da» y tu nacionalidad con su género.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('7d5c3059-153d-560e-b91e-f764a4ffd2af','20000000-0000-0000-0000-000000000004','checkpoint','A1','db2d2ef3-7be4-5022-bc30-68b6c2252fc4',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('341a48f7-5f94-51c5-bcb7-9f9532f85632'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','reading','match',$p$Empareja cada número en italiano con su cifra.$p$,$j${"pairs": [{"en": "cinque", "es": "5"}, {"en": "dieci", "es": "10"}, {"en": "venti", "es": "20"}]}$j$::jsonb,$j${"pairs": [["cinque", "5"], ["dieci", "10"], ["venti", "20"]]}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$numeros_0_20$p$, $p$reading$p$]),
('67d464a0-d752-5356-8484-9c748a0b974c'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','reading','multiple_choice',$p$¿Cómo se escribe el número 15 en italiano?$p$,$j${"options": ["quindici", "cinque", "sedici"]}$j$::jsonb,$j${"value": "quindici"}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$numeros_0_20$p$, $p$reading$p$]),
('e949a969-fa65-5b3d-8fef-22b4d205c0bd'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','writing','cloze',$p$Escribe en letras el número 12 en italiano.$p$,$j${"text": "12 = ___"}$j$::jsonb,$j${"value": "dodici", "accepted": ["dodici"]}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$numeros_0_20$p$, $p$writing$p$]),
('61ea61da-1c4f-5e15-adf8-02aa793a4df5'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','listening','listening',$p$Escucha y elige el número que oíste.$p$,$j${"options": ["diciassette", "sette", "dieci"], "say": "diciassette", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/61ea61da-1c4f-5e15-adf8-02aa793a4df5.mp3"}$j$::jsonb,$j${"value": "diciassette"}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$numeros_0_20$p$, $p$listening$p$]),
('0f7c13b4-0755-533f-9373-49ad562f0778'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "zero, cinque, dieci, quindici, venti", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/0f7c13b4-0755-533f-9373-49ad562f0778.mp3"}$j$::jsonb,$j${"expected": "zero, cinque, dieci, quindici, venti"}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$numeros_0_20$p$, $p$speaking$p$]),
('7b2abacc-decd-530a-a2ba-b96fb8278c6a'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','reading','multiple_choice',$p$En italiano la edad se dice con el verbo «avere». ¿Cuál es correcto para «tengo veinte años»?$p$,$j${"options": ["Ho vent'anni.", "Sono vent'anni.", "Ho vent'anno."]}$j$::jsonb,$j${"value": "Ho vent'anni."}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$edad_avere$p$, $p$reading$p$]),
('99b82fb7-f56e-5042-97d3-1d55246e62c1'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','writing','cloze',$p$Completa con el verbo avere: «Yo tengo diez años».$p$,$j${"text": "Io ___ dieci anni."}$j$::jsonb,$j${"value": "ho", "accepted": ["ho"]}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$edad_avere$p$, $p$writing$p$]),
('f261ea80-0256-554b-808b-98744dd2e124'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','writing','word_bank',$p$Arma la frase: «¿Cuántos años tienes?».$p$,$j${"tiles": ["Quanti", "anni", "hai", "sei", "anno"]}$j$::jsonb,$j${"value": "Quanti anni hai", "sequence": ["Quanti", "anni", "hai"]}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$edad_avere$p$, $p$writing$p$]),
('9ac15aef-e8cb-5719-9316-c9934686c167'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ho quindici anni.", "Ho cinque anni.", "Hai vent'anni."], "say": "Ho quindici anni.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/9ac15aef-e8cb-5719-9316-c9934686c167.mp3"}$j$::jsonb,$j${"value": "Ho quindici anni."}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$edad_avere$p$, $p$listening$p$]),
('9102d2a1-9661-5f7e-9421-5c4d2938e4cd'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Quanti anni hai? Ho vent'anni.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/9102d2a1-9661-5f7e-9421-5c4d2938e4cd.mp3"}$j$::jsonb,$j${"expected": "Quanti anni hai? Ho vent'anni."}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$edad_avere$p$, $p$speaking$p$]),
('63b86032-3b5f-568f-93af-c0129fa63c6f'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','reading','multiple_choice',$p$«la Spagna» es femenino: da + la = dalla. ¿Cuál es correcto para «vengo de España»?$p$,$j${"options": ["Vengo dalla Spagna.", "Vengo dal Spagna.", "Vengo da la Spagna."]}$j$::jsonb,$j${"value": "Vengo dalla Spagna."}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$origen_venire$p$, $p$reading$p$]),
('e80db1de-2459-50df-a316-85aeeb2da9b5'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','writing','translation',$p$Traduce: «¿De dónde eres?» (informal).$p$,$j${"source": "¿De dónde eres?"}$j$::jsonb,$j${"value": "Di dove sei?", "accepted": ["Di dove sei?", "Di dove sei", "di dove sei?", "di dove sei"]}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$origen_venire$p$, $p$writing$p$]),
('6dddc586-7a25-5d82-8ab9-9eba55e92a6a'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','writing','reorder',$p$Ordena: «Vengo de Italia».$p$,$j${"tiles": ["Italia", "Vengo", "dall'"]}$j$::jsonb,$j${"value": "Vengo dall' Italia"}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$origen_venire$p$, $p$writing$p$]),
('2bbb625f-b2fb-56ab-aba9-2060fdf5fef3'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Vengo dalla Spagna.", "Vengo dal Messico.", "Di dove sei?"], "say": "Vengo dalla Spagna.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/2bbb625f-b2fb-56ab-aba9-2060fdf5fef3.mp3"}$j$::jsonb,$j${"value": "Vengo dalla Spagna."}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$origen_venire$p$, $p$listening$p$]),
('9043c9a8-b80a-5eef-aa05-bb69d3858714'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','reading','match',$p$Empareja cada nacionalidad en italiano (masculino) con su traducción.$p$,$j${"pairs": [{"en": "italiano", "es": "italiano"}, {"en": "spagnolo", "es": "español"}, {"en": "messicano", "es": "mexicano"}]}$j$::jsonb,$j${"pairs": [["italiano", "italiano"], ["spagnolo", "español"], ["messicano", "mexicano"]]}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$nacionalidades$p$, $p$reading$p$]),
('12210893-a340-5767-9c32-38823d90b4bf'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','reading','multiple_choice',$p$Anna es de España. En femenino, ¿cómo dice su nacionalidad?$p$,$j${"options": ["Sono spagnola.", "Sono spagnolo.", "Sono italiana."]}$j$::jsonb,$j${"value": "Sono spagnola."}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$nacionalidades$p$, $p$reading$p$]),
('e8975183-5b92-5ca3-8040-9c1532b88f9f'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','writing','translation',$p$Traduce (habla un hombre): «Soy italiano».$p$,$j${"source": "Soy italiano."}$j$::jsonb,$j${"value": "Sono italiano.", "accepted": ["Sono italiano.", "Sono italiano", "sono italiano.", "sono italiano", "Io sono italiano."]}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$nacionalidades$p$, $p$writing$p$]),
('09da7264-4dc3-59f8-8c86-0c55e96331f2'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Vengo dal Messico.", "Vengo dalla Spagna.", "Vengo dall'Italia."], "say": "Vengo dal Messico.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/09da7264-4dc3-59f8-8c86-0c55e96331f2.mp3"}$j$::jsonb,$j${"value": "Vengo dal Messico."}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$nacionalidades$p$, $p$listening$p$]),
('6ae9f647-7321-5501-85d8-d528975ce3aa'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Vengo dal Messico. Sono messicano.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/6ae9f647-7321-5501-85d8-d528975ce3aa.mp3"}$j$::jsonb,$j${"expected": "Vengo dal Messico. Sono messicano."}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$nacionalidades$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('63d885b0-c68e-5a51-b929-efe327eb5f8a','341a48f7-5f94-51c5-bcb7-9f9532f85632',1),
 ('63d885b0-c68e-5a51-b929-efe327eb5f8a','67d464a0-d752-5356-8484-9c748a0b974c',2),
 ('63d885b0-c68e-5a51-b929-efe327eb5f8a','e949a969-fa65-5b3d-8fef-22b4d205c0bd',3),
 ('63d885b0-c68e-5a51-b929-efe327eb5f8a','61ea61da-1c4f-5e15-adf8-02aa793a4df5',4),
 ('63d885b0-c68e-5a51-b929-efe327eb5f8a','0f7c13b4-0755-533f-9373-49ad562f0778',5),
 ('d1ee3c14-ff37-5dfe-b9d6-2000adc2afe4','7b2abacc-decd-530a-a2ba-b96fb8278c6a',1),
 ('d1ee3c14-ff37-5dfe-b9d6-2000adc2afe4','99b82fb7-f56e-5042-97d3-1d55246e62c1',2),
 ('d1ee3c14-ff37-5dfe-b9d6-2000adc2afe4','f261ea80-0256-554b-808b-98744dd2e124',3),
 ('d1ee3c14-ff37-5dfe-b9d6-2000adc2afe4','9ac15aef-e8cb-5719-9316-c9934686c167',4),
 ('d1ee3c14-ff37-5dfe-b9d6-2000adc2afe4','9102d2a1-9661-5f7e-9421-5c4d2938e4cd',5),
 ('99af5055-d51f-5a0e-b7b2-f300b7874b0a','63b86032-3b5f-568f-93af-c0129fa63c6f',1),
 ('99af5055-d51f-5a0e-b7b2-f300b7874b0a','e80db1de-2459-50df-a316-85aeeb2da9b5',2),
 ('99af5055-d51f-5a0e-b7b2-f300b7874b0a','6dddc586-7a25-5d82-8ab9-9eba55e92a6a',3),
 ('99af5055-d51f-5a0e-b7b2-f300b7874b0a','2bbb625f-b2fb-56ab-aba9-2060fdf5fef3',4),
 ('6b0e8be4-c579-5857-97e2-206ccf7971ac','9043c9a8-b80a-5eef-aa05-bb69d3858714',1),
 ('6b0e8be4-c579-5857-97e2-206ccf7971ac','12210893-a340-5767-9c32-38823d90b4bf',2),
 ('6b0e8be4-c579-5857-97e2-206ccf7971ac','e8975183-5b92-5ca3-8040-9c1532b88f9f',3),
 ('6b0e8be4-c579-5857-97e2-206ccf7971ac','09da7264-4dc3-59f8-8c86-0c55e96331f2',4),
 ('6b0e8be4-c579-5857-97e2-206ccf7971ac','6ae9f647-7321-5501-85d8-d528975ce3aa',5),
 ('c6962442-0fbb-5117-8879-9193959f8ef4','341a48f7-5f94-51c5-bcb7-9f9532f85632',1),
 ('c6962442-0fbb-5117-8879-9193959f8ef4','67d464a0-d752-5356-8484-9c748a0b974c',2),
 ('c6962442-0fbb-5117-8879-9193959f8ef4','7b2abacc-decd-530a-a2ba-b96fb8278c6a',3),
 ('c6962442-0fbb-5117-8879-9193959f8ef4','e949a969-fa65-5b3d-8fef-22b4d205c0bd',4),
 ('c6962442-0fbb-5117-8879-9193959f8ef4','99b82fb7-f56e-5042-97d3-1d55246e62c1',5),
 ('c6962442-0fbb-5117-8879-9193959f8ef4','f261ea80-0256-554b-808b-98744dd2e124',6),
 ('c6962442-0fbb-5117-8879-9193959f8ef4','61ea61da-1c4f-5e15-adf8-02aa793a4df5',7),
 ('c6962442-0fbb-5117-8879-9193959f8ef4','9ac15aef-e8cb-5719-9316-c9934686c167',8),
 ('c6962442-0fbb-5117-8879-9193959f8ef4','0f7c13b4-0755-533f-9373-49ad562f0778',9),
 ('c6962442-0fbb-5117-8879-9193959f8ef4','9102d2a1-9661-5f7e-9421-5c4d2938e4cd',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('919f5ced-742c-5379-b065-fa7ef897f0bd','20000000-0000-0000-0000-000000000004',$p$zero$p$,$p$cero$p$,141,'numero'),
 ('ee0c3533-960b-53a3-a744-e1609e5217b6','20000000-0000-0000-0000-000000000004',$p$cinque$p$,$p$cinco$p$,142,'numero'),
 ('b2dd9651-72be-51e9-a10c-8183479ae243','20000000-0000-0000-0000-000000000004',$p$dieci$p$,$p$diez$p$,143,'numero'),
 ('02a288f9-2896-5dd0-aa45-205f4946a13c','20000000-0000-0000-0000-000000000004',$p$quindici$p$,$p$quince$p$,144,'numero'),
 ('f8d510b8-4a06-5531-b2c6-8620e07c042c','20000000-0000-0000-0000-000000000004',$p$venti$p$,$p$veinte$p$,145,'numero'),
 ('6546e7d5-c3fc-526b-aeca-4e5b0585c262','20000000-0000-0000-0000-000000000004',$p$avere$p$,$p$tener$p$,146,'verbo'),
 ('80b1a31b-f145-52d5-88ac-b2d16b68c906','20000000-0000-0000-0000-000000000004',$p$io ho$p$,$p$yo tengo$p$,147,'verbo'),
 ('a16bdb03-6672-5089-bc72-b3a5aa8fcab9','20000000-0000-0000-0000-000000000004',$p$tu hai$p$,$p$tú tienes$p$,148,'verbo'),
 ('d796b79d-f260-5afc-9df5-ccb93d3d41c6','20000000-0000-0000-0000-000000000004',$p$quanti anni$p$,$p$cuántos años$p$,149,'expresion'),
 ('fadc7456-e227-5395-9d7b-451bd3830f32','20000000-0000-0000-0000-000000000004',$p$anni$p$,$p$años$p$,150,'sustantivo'),
 ('90761af9-810b-54ce-b893-e22901079fe3','20000000-0000-0000-0000-000000000004',$p$vengo da$p$,$p$vengo de$p$,151,'expresion'),
 ('b316aedb-af92-5ceb-93ed-2990fdafed9e','20000000-0000-0000-0000-000000000004',$p$di dove$p$,$p$de dónde$p$,152,'expresion'),
 ('2602d973-d12c-5af2-8798-16cab8125f66','20000000-0000-0000-0000-000000000004',$p$paese$p$,$p$país$p$,153,'sustantivo'),
 ('003df9de-097d-5a2f-b9eb-e39043c342d4','20000000-0000-0000-0000-000000000004',$p$italiano$p$,$p$italiano$p$,154,'adjetivo'),
 ('6cb47b24-5a5c-5fed-819b-b37170bcb48c','20000000-0000-0000-0000-000000000004',$p$spagnola$p$,$p$española$p$,155,'adjetivo'),
 ('6dad747c-0402-5bae-8b2e-03d4d0f71254','20000000-0000-0000-0000-000000000004',$p$messicano$p$,$p$mexicano$p$,156,'adjetivo')
on conflict (id) do nothing;

-- ── Unidad 3 (A1·it): La familia ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('da9a3bd5-7b48-5486-852e-9dc4413f1114','20000000-0000-0000-0000-000000000004','A1',3,$p$La familia$p$,'#8E44AD','family_restroom')
on conflict (course_id, order_index) do update set title=excluded.title, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('ffbe2828-7d3b-5c21-bfb6-41d7355d2b33','da9a3bd5-7b48-5486-852e-9dc4413f1114',1,$p$La familia (la famiglia)$p$,$p$La familia (la famiglia)$p$,'lesson',15),
 ('2a84b5a5-1a55-5d1b-a3d1-72c3bf1e125c','da9a3bd5-7b48-5486-852e-9dc4413f1114',2,$p$Los posesivos (mio, mia, i miei)$p$,$p$Los posesivos (mio, mia, i miei)$p$,'lesson',15),
 ('4010a3fa-4344-5caa-963c-3bcde945d5bd','da9a3bd5-7b48-5486-852e-9dc4413f1114',3,$p$Presentar personas (questo è, chi è?)$p$,$p$Presentar personas (questo è, chi è?)$p$,'lesson',15),
 ('80b8897c-b511-565b-b56b-39308ccaa8e5','da9a3bd5-7b48-5486-852e-9dc4413f1114',4,$p$Describir personas (alto, simpatico...)$p$,$p$Describir personas (alto, simpatico...)$p$,'lesson',15),
 ('4fcae98b-e9c5-5b6d-a1d8-88d9a00d2cf6','da9a3bd5-7b48-5486-852e-9dc4413f1114',5,$p$🏁 Checkpoint Unité 3$p$,$p$Demuestra que sabes nombrar a la familia, usar posesivos de parentesco, presentar personas con questo/questa y describirlas.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('5c6d3228-e05a-551a-8453-6dbcfd8ebd1a','20000000-0000-0000-0000-000000000004','checkpoint','A1','da9a3bd5-7b48-5486-852e-9dc4413f1114',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('2c452331-6225-5fdd-902c-b494dfcdd538'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','reading','match',$p$Empareja cada palabra italiana con su traducción.$p$,$j${"pairs": [{"en": "la madre", "es": "la madre"}, {"en": "il padre", "es": "el padre"}, {"en": "la sorella", "es": "la hermana"}]}$j$::jsonb,$j${"pairs": [["la madre", "la madre"], ["il padre", "el padre"], ["la sorella", "la hermana"]]}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$familia$p$, $p$reading$p$]),
('75f52e9d-d488-5db2-b925-e59af27d0ad6'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','reading','multiple_choice',$p$¿Cuál es «el hijo» en italiano?$p$,$j${"options": ["il figlio", "la figlia", "il padre"]}$j$::jsonb,$j${"value": "il figlio"}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$familia$p$, $p$reading$p$]),
('8e760240-e3ab-50e1-afd3-17ebfc07dabf'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Questa è la mia famiglia.", "Questo è mio fratello.", "Questa è mia madre."], "say": "Questa è la mia famiglia.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/8e760240-e3ab-50e1-afd3-17ebfc07dabf.mp3"}$j$::jsonb,$j${"value": "Questa è la mia famiglia."}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$familia$p$, $p$listening$p$]),
('45f58745-b136-5263-a09c-ece66d256ff4'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','writing','translation',$p$Traduce: «El padre y la madre».$p$,$j${"source": "El padre y la madre"}$j$::jsonb,$j${"value": "Il padre e la madre", "accepted": ["Il padre e la madre", "il padre e la madre", "Il padre e la madre."]}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$familia$p$, $p$writing$p$]),
('2156bcc1-cbce-5b8c-ad7b-dcfa43645d01'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Ho una famiglia grande.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/2156bcc1-cbce-5b8c-ad7b-dcfa43645d01.mp3"}$j$::jsonb,$j${"expected": "Ho una famiglia grande."}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$familia$p$, $p$speaking$p$]),
('5851d157-e907-580a-98b2-338a31b87c2a'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','reading','match',$p$Empareja cada palabra italiana con su traducción.$p$,$j${"pairs": [{"en": "il fratello", "es": "el hermano"}, {"en": "i genitori", "es": "los padres"}, {"en": "la nonna", "es": "la abuela"}]}$j$::jsonb,$j${"pairs": [["il fratello", "el hermano"], ["i genitori", "los padres"], ["la nonna", "la abuela"]]}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$posesivos$p$, $p$reading$p$]),
('6557ea66-633c-5666-976e-d64c5c52f026'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','reading','multiple_choice',$p$«Mi hermana» en italiano (parentesco singular, sin artículo) es:$p$,$j${"options": ["mia sorella", "la mia sorella", "mio sorella"]}$j$::jsonb,$j${"value": "mia sorella"}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$posesivos$p$, $p$reading$p$]),
('01810383-3eab-57a0-89cd-fe1ae4d07455'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','writing','cloze',$p$Completa: «mis padres» lleva artículo en plural. ___ miei genitori.$p$,$j${"text": "___ miei genitori"}$j$::jsonb,$j${"value": "i", "accepted": ["i", "I"]}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$posesivos$p$, $p$writing$p$]),
('9095cfbd-4271-5045-a555-596f8ddeb477'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','writing','word_bank',$p$Arma: «Mi madre es simpática».$p$,$j${"tiles": ["Mia", "madre", "è", "simpatica", "Mio", "simpatico"]}$j$::jsonb,$j${"value": "Mia madre è simpatica", "sequence": ["Mia", "madre", "è", "simpatica"]}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$posesivos$p$, $p$writing$p$]),
('63619a45-5770-5712-a913-dd1b4c2095ac'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Questo è mio fratello.", "Questa è mia sorella.", "Questo è mio padre."], "say": "Questo è mio fratello.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/63619a45-5770-5712-a913-dd1b4c2095ac.mp3"}$j$::jsonb,$j${"value": "Questo è mio fratello."}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$posesivos$p$, $p$listening$p$]),
('82477456-7d77-5805-a98e-5212540d9bd2'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Mia sorella è piccola.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/82477456-7d77-5805-a98e-5212540d9bd2.mp3"}$j$::jsonb,$j${"expected": "Mia sorella è piccola."}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$posesivos$p$, $p$speaking$p$]),
('3525796f-f74b-500b-aac9-63c8f5835260'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','reading','multiple_choice',$p$Para presentar a una MUJER («Esta es mi madre») usamos:$p$,$j${"options": ["Questa è mia madre.", "Questo è mia madre.", "Questi è mia madre."]}$j$::jsonb,$j${"value": "Questa è mia madre."}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$presentar$p$, $p$reading$p$]),
('ccdf003e-51dc-5764-aecb-4aa8dcc54451'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','writing','cloze',$p$Completa la pregunta «¿Quién es?»: ___ è?$p$,$j${"text": "___ è?"}$j$::jsonb,$j${"value": "Chi", "accepted": ["Chi", "chi"]}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$presentar$p$, $p$writing$p$]),
('03d78480-c738-5c87-b3a9-dd247714b9c9'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','writing','reorder',$p$Ordena: «Este es mi padre».$p$,$j${"tiles": ["Questo", "è", "mio", "padre"]}$j$::jsonb,$j${"value": "Questo è mio padre"}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$presentar$p$, $p$writing$p$]),
('da27c479-2ace-51fd-950d-518c6c2e1a38'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Questo è mio nonno.", "Questa è mia nonna.", "Questo è mio figlio."], "say": "Questo è mio nonno.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/da27c479-2ace-51fd-950d-518c6c2e1a38.mp3"}$j$::jsonb,$j${"value": "Questo è mio nonno."}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$presentar$p$, $p$listening$p$]),
('29e06ddd-27b8-5a44-92b4-e6a7ca4262f3'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Chi è? È mia sorella.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/29e06ddd-27b8-5a44-92b4-e6a7ca4262f3.mp3"}$j$::jsonb,$j${"expected": "Chi è? È mia sorella."}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$presentar$p$, $p$speaking$p$]),
('cd7ee161-d86d-5625-8396-2c9b91b05708'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','reading','multiple_choice',$p$«Mia madre è ___» (mi madre es alta). Elige la forma femenina correcta.$p$,$j${"options": ["alta", "alto", "alti"]}$j$::jsonb,$j${"value": "alta"}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$describir$p$, $p$reading$p$]),
('29ac1547-1a27-540e-bf33-4bee97a77619'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','writing','translation',$p$Traduce: «Mi hermano es simpático».$p$,$j${"source": "Mi hermano es simpático"}$j$::jsonb,$j${"value": "Mio fratello è simpatico", "accepted": ["Mio fratello è simpatico", "mio fratello è simpatico", "Mio fratello e simpatico", "Mio fratello è simpatico."]}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$describir$p$, $p$writing$p$]),
('d4a05cde-fc5c-5d67-80ff-17b4c9595ebc'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Mio padre è alto e simpatico.", "Mia madre è piccola e simpatica.", "Mio fratello è grande."], "say": "Mio padre è alto e simpatico.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/d4a05cde-fc5c-5d67-80ff-17b4c9595ebc.mp3"}$j$::jsonb,$j${"value": "Mio padre è alto e simpatico."}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$describir$p$, $p$listening$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('ffbe2828-7d3b-5c21-bfb6-41d7355d2b33','2c452331-6225-5fdd-902c-b494dfcdd538',1),
 ('ffbe2828-7d3b-5c21-bfb6-41d7355d2b33','75f52e9d-d488-5db2-b925-e59af27d0ad6',2),
 ('ffbe2828-7d3b-5c21-bfb6-41d7355d2b33','8e760240-e3ab-50e1-afd3-17ebfc07dabf',3),
 ('ffbe2828-7d3b-5c21-bfb6-41d7355d2b33','45f58745-b136-5263-a09c-ece66d256ff4',4),
 ('ffbe2828-7d3b-5c21-bfb6-41d7355d2b33','2156bcc1-cbce-5b8c-ad7b-dcfa43645d01',5),
 ('2a84b5a5-1a55-5d1b-a3d1-72c3bf1e125c','5851d157-e907-580a-98b2-338a31b87c2a',1),
 ('2a84b5a5-1a55-5d1b-a3d1-72c3bf1e125c','6557ea66-633c-5666-976e-d64c5c52f026',2),
 ('2a84b5a5-1a55-5d1b-a3d1-72c3bf1e125c','01810383-3eab-57a0-89cd-fe1ae4d07455',3),
 ('2a84b5a5-1a55-5d1b-a3d1-72c3bf1e125c','9095cfbd-4271-5045-a555-596f8ddeb477',4),
 ('2a84b5a5-1a55-5d1b-a3d1-72c3bf1e125c','63619a45-5770-5712-a913-dd1b4c2095ac',5),
 ('2a84b5a5-1a55-5d1b-a3d1-72c3bf1e125c','82477456-7d77-5805-a98e-5212540d9bd2',6),
 ('4010a3fa-4344-5caa-963c-3bcde945d5bd','3525796f-f74b-500b-aac9-63c8f5835260',1),
 ('4010a3fa-4344-5caa-963c-3bcde945d5bd','ccdf003e-51dc-5764-aecb-4aa8dcc54451',2),
 ('4010a3fa-4344-5caa-963c-3bcde945d5bd','03d78480-c738-5c87-b3a9-dd247714b9c9',3),
 ('4010a3fa-4344-5caa-963c-3bcde945d5bd','da27c479-2ace-51fd-950d-518c6c2e1a38',4),
 ('4010a3fa-4344-5caa-963c-3bcde945d5bd','29e06ddd-27b8-5a44-92b4-e6a7ca4262f3',5),
 ('80b8897c-b511-565b-b56b-39308ccaa8e5','cd7ee161-d86d-5625-8396-2c9b91b05708',1),
 ('80b8897c-b511-565b-b56b-39308ccaa8e5','29ac1547-1a27-540e-bf33-4bee97a77619',2),
 ('80b8897c-b511-565b-b56b-39308ccaa8e5','d4a05cde-fc5c-5d67-80ff-17b4c9595ebc',3),
 ('4fcae98b-e9c5-5b6d-a1d8-88d9a00d2cf6','2c452331-6225-5fdd-902c-b494dfcdd538',1),
 ('4fcae98b-e9c5-5b6d-a1d8-88d9a00d2cf6','75f52e9d-d488-5db2-b925-e59af27d0ad6',2),
 ('4fcae98b-e9c5-5b6d-a1d8-88d9a00d2cf6','5851d157-e907-580a-98b2-338a31b87c2a',3),
 ('4fcae98b-e9c5-5b6d-a1d8-88d9a00d2cf6','45f58745-b136-5263-a09c-ece66d256ff4',4),
 ('4fcae98b-e9c5-5b6d-a1d8-88d9a00d2cf6','01810383-3eab-57a0-89cd-fe1ae4d07455',5),
 ('4fcae98b-e9c5-5b6d-a1d8-88d9a00d2cf6','9095cfbd-4271-5045-a555-596f8ddeb477',6),
 ('4fcae98b-e9c5-5b6d-a1d8-88d9a00d2cf6','8e760240-e3ab-50e1-afd3-17ebfc07dabf',7),
 ('4fcae98b-e9c5-5b6d-a1d8-88d9a00d2cf6','63619a45-5770-5712-a913-dd1b4c2095ac',8),
 ('4fcae98b-e9c5-5b6d-a1d8-88d9a00d2cf6','2156bcc1-cbce-5b8c-ad7b-dcfa43645d01',9),
 ('4fcae98b-e9c5-5b6d-a1d8-88d9a00d2cf6','82477456-7d77-5805-a98e-5212540d9bd2',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('2bf5cf2e-1486-5331-b10c-b28fd0e4f034','20000000-0000-0000-0000-000000000004',$p$la madre$p$,$p$la madre$p$,161,'sustantivo'),
 ('a9389832-d89f-586d-942a-465b37bd3493','20000000-0000-0000-0000-000000000004',$p$il padre$p$,$p$el padre$p$,162,'sustantivo'),
 ('bd8ae5e4-d42b-526c-a46b-4def82b83c52','20000000-0000-0000-0000-000000000004',$p$i genitori$p$,$p$los padres$p$,163,'sustantivo'),
 ('9b7755ef-1526-5cc1-8ecb-2f8d89400f6b','20000000-0000-0000-0000-000000000004',$p$il fratello$p$,$p$el hermano$p$,164,'sustantivo'),
 ('f0f400e4-40a3-5c47-88bd-28af1601e2b1','20000000-0000-0000-0000-000000000004',$p$la sorella$p$,$p$la hermana$p$,165,'sustantivo'),
 ('2bbfd63f-c9ae-56bf-a2e6-229732cf7632','20000000-0000-0000-0000-000000000004',$p$il figlio$p$,$p$el hijo$p$,166,'sustantivo'),
 ('23065ec3-e5bc-5bfe-b6ce-e7ec8688c690','20000000-0000-0000-0000-000000000004',$p$la figlia$p$,$p$la hija$p$,167,'sustantivo'),
 ('74f60d50-e114-5fdd-96c1-c27605edf415','20000000-0000-0000-0000-000000000004',$p$il nonno$p$,$p$el abuelo$p$,168,'sustantivo'),
 ('3eef691a-182e-5246-80ba-647ed40adb1e','20000000-0000-0000-0000-000000000004',$p$la nonna$p$,$p$la abuela$p$,169,'sustantivo'),
 ('e0f6c766-c2a6-5669-8dbb-f91405f2e3c7','20000000-0000-0000-0000-000000000004',$p$la famiglia$p$,$p$la familia$p$,170,'sustantivo'),
 ('c96d9338-af88-58b6-ae79-e211c564bd10','20000000-0000-0000-0000-000000000004',$p$mio$p$,$p$mi (masculino)$p$,171,'articulo'),
 ('e1b35bb7-1550-500e-a5f2-aca0a3edadd9','20000000-0000-0000-0000-000000000004',$p$mia$p$,$p$mi (femenino)$p$,172,'articulo'),
 ('b24fe396-f1bd-5c01-bb6a-9a22b6d075c1','20000000-0000-0000-0000-000000000004',$p$alto$p$,$p$alto$p$,173,'adjetivo'),
 ('2be76988-55cd-58bd-8b17-1f6825bde95a','20000000-0000-0000-0000-000000000004',$p$simpatico$p$,$p$simpático$p$,174,'adjetivo'),
 ('a1d2e1a3-d26b-5cc0-932e-318fe17e7f0e','20000000-0000-0000-0000-000000000004',$p$piccolo$p$,$p$pequeño$p$,175,'adjetivo'),
 ('94ad096b-5afc-5cd4-acec-b95a68ccc7f0','20000000-0000-0000-0000-000000000004',$p$grande$p$,$p$grande$p$,176,'adjetivo')
on conflict (id) do nothing;

-- ── Unidad 4 (A1·it): Comida y el bar ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('efcf97bb-28fc-56cb-8fb8-a9a8f1d79509','20000000-0000-0000-0000-000000000004','A1',4,$p$Comida y el bar$p$,'#E67E22','restaurant')
on conflict (course_id, order_index) do update set title=excluded.title, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('87747a7d-095d-5d65-929e-b4dea3e98535','efcf97bb-28fc-56cb-8fb8-a9a8f1d79509',1,$p$La comida (il cibo)$p$,$p$La comida (il cibo)$p$,'lesson',15),
 ('b555d1cf-3449-5e9e-808b-9e34d519afbe','efcf97bb-28fc-56cb-8fb8-a9a8f1d79509',2,$p$Al bar (vorrei un caffè)$p$,$p$Al bar (vorrei un caffè)$p$,'lesson',15),
 ('b454a0cb-dbaa-5827-bf9b-eaf83e927431','efcf97bb-28fc-56cb-8fb8-a9a8f1d79509',3,$p$El partitivo (del, della, dell')$p$,$p$El partitivo (del, della, dell')$p$,'lesson',15),
 ('7dda92f6-abc3-5081-9e5f-463d0a12e837','efcf97bb-28fc-56cb-8fb8-a9a8f1d79509',4,$p$Precios y la cuenta (quanto costa?)$p$,$p$Precios y la cuenta (quanto costa?)$p$,'lesson',15),
 ('a6691153-d423-5a45-883d-aba046f5d776','efcf97bb-28fc-56cb-8fb8-a9a8f1d79509',5,$p$🏁 Checkpoint Unité 4$p$,$p$Demuestra que sabes nombrar comida y bebida, pedir con cortesía en el bar, usar el partitivo y hablar de precios.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('afc7b6f7-7e7f-5398-8253-8cf50ccdb989','20000000-0000-0000-0000-000000000004','checkpoint','A1','efcf97bb-28fc-56cb-8fb8-a9a8f1d79509',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('11c8d6fa-c3ca-5044-8899-e171ee564a62'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','reading','match',$p$Empareja cada palabra italiana con su traducción.$p$,$j${"pairs": [{"en": "il pane", "es": "el pan"}, {"en": "l'acqua", "es": "el agua"}, {"en": "la mela", "es": "la manzana"}]}$j$::jsonb,$j${"pairs": [["il pane", "el pan"], ["l'acqua", "el agua"], ["la mela", "la manzana"]]}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$comida$p$, $p$reading$p$]),
('f2fc71be-fbbd-5806-9f35-67dec3737d3d'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','reading','multiple_choice',$p$¿Cuál es «el café» (la bebida) en italiano?$p$,$j${"options": ["il caffè", "il latte", "il vino"]}$j$::jsonb,$j${"value": "il caffè"}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$comida$p$, $p$reading$p$]),
('76e0da36-6eb7-5687-b961-4cee9f9d5984'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Mi piace la pizza.", "Mi piace la pasta.", "Mi piace il pane."], "say": "Mi piace la pizza.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/76e0da36-6eb7-5687-b961-4cee9f9d5984.mp3"}$j$::jsonb,$j${"value": "Mi piace la pizza."}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$comida$p$, $p$listening$p$]),
('9bf067dd-6f86-5d83-8b45-2daa0c13d295'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','writing','translation',$p$Traduce: «El pan y el agua».$p$,$j${"source": "El pan y el agua"}$j$::jsonb,$j${"value": "Il pane e l'acqua", "accepted": ["Il pane e l'acqua", "il pane e l'acqua", "Il pane e l'acqua.", "Il pane e l’acqua"]}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$comida$p$, $p$writing$p$]),
('58a7697c-8ecf-5547-97f4-6d7adfde7370'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Mi piace il caffè.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/58a7697c-8ecf-5547-97f4-6d7adfde7370.mp3"}$j$::jsonb,$j${"expected": "Mi piace il caffè."}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$comida$p$, $p$speaking$p$]),
('45fe4e9f-bb16-5c06-9d6f-f9a4583b120b'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','reading','match',$p$Empareja cada expresión italiana con su traducción.$p$,$j${"pairs": [{"en": "il conto", "es": "la cuenta"}, {"en": "la birra", "es": "la cerveza"}, {"en": "per favore", "es": "por favor"}]}$j$::jsonb,$j${"pairs": [["il conto", "la cuenta"], ["la birra", "la cerveza"], ["per favore", "por favor"]]}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$bar$p$, $p$reading$p$]),
('90e4cf53-bd1c-51ed-bea8-aef7dc0e6931'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','reading','multiple_choice',$p$¿Cómo pides con cortesía «Quisiera un café»?$p$,$j${"options": ["Vorrei un caffè.", "Voglio un caffè.", "Dammi un caffè."]}$j$::jsonb,$j${"value": "Vorrei un caffè."}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$bar$p$, $p$reading$p$]),
('f3dd41cf-7381-57d6-adc8-e43093170db8'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','writing','cloze',$p$Completa para pedir con cortesía «un café, por favor»: Un caffè, ___ favore.$p$,$j${"text": "Un caffè, ___ favore"}$j$::jsonb,$j${"value": "per", "accepted": ["per", "Per"]}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$bar$p$, $p$writing$p$]),
('41c3026a-5c85-5097-ba20-87527c6544d1'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','writing','word_bank',$p$Arma: «Quisiera una cerveza, por favor».$p$,$j${"tiles": ["Vorrei", "una", "birra", "per", "favore", "un", "vino"]}$j$::jsonb,$j${"value": "Vorrei una birra per favore", "sequence": ["Vorrei", "una", "birra", "per", "favore"]}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$bar$p$, $p$writing$p$]),
('879743f7-2d12-5eb0-963a-3af1246decf9'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Un cappuccino, per favore.", "Una birra, per favore.", "Il conto, per favore."], "say": "Un cappuccino, per favore.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/879743f7-2d12-5eb0-963a-3af1246decf9.mp3"}$j$::jsonb,$j${"value": "Un cappuccino, per favore."}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$bar$p$, $p$listening$p$]),
('f6b334f1-afec-5271-a89e-fa4c6d012926'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Vorrei un caffè, per favore.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/f6b334f1-afec-5271-a89e-fa4c6d012926.mp3"}$j$::jsonb,$j${"expected": "Vorrei un caffè, per favore."}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$bar$p$, $p$speaking$p$]),
('fcff1538-c407-572d-9e28-b76a9609639a'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','reading','multiple_choice',$p$Elige el partitivo correcto: «Vorrei ___ pane» (quisiera pan).$p$,$j${"options": ["del", "della", "dei"]}$j$::jsonb,$j${"value": "del"}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$partitivo$p$, $p$reading$p$]),
('66859f9c-2494-515c-a647-dae408c11d55'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','writing','cloze',$p$Completa con el partitivo femenino: «Vorrei ___ pizza» (quisiera pizza).$p$,$j${"text": "Vorrei ___ pizza"}$j$::jsonb,$j${"value": "della", "accepted": ["della", "Della"]}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$partitivo$p$, $p$writing$p$]),
('b5701f97-bdcb-5214-b975-a8207351788b'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','writing','reorder',$p$Ordena: «Quisiera algo de agua» (partitivo ante vocal).$p$,$j${"tiles": ["Vorrei", "dell'acqua"]}$j$::jsonb,$j${"value": "Vorrei dell'acqua"}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$partitivo$p$, $p$writing$p$]),
('986fb4fc-d75e-5aac-8e80-97acf5bf8635'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Vorrei del pane.", "Vorrei della pizza.", "Vorrei dell'acqua."], "say": "Vorrei del pane.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/986fb4fc-d75e-5aac-8e80-97acf5bf8635.mp3"}$j$::jsonb,$j${"value": "Vorrei del pane."}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$partitivo$p$, $p$listening$p$]),
('4b972ae4-8b70-58b7-a2c5-b0c1b7adbebb'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Vorrei del pane e dell'acqua.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/4b972ae4-8b70-58b7-a2c5-b0c1b7adbebb.mp3"}$j$::jsonb,$j${"expected": "Vorrei del pane e dell'acqua."}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$partitivo$p$, $p$speaking$p$]),
('87dac567-d0bf-5087-a20c-d4237635ebda'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','reading','multiple_choice',$p$¿Cómo preguntas «¿Cuánto cuesta?»?$p$,$j${"options": ["Quanto costa?", "Dove costa?", "Quando costa?"]}$j$::jsonb,$j${"value": "Quanto costa?"}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$precios$p$, $p$reading$p$]),
('d17fb88e-7a53-5db6-93aa-bed37d49963e'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','writing','translation',$p$Traduce: «Son cinco euros».$p$,$j${"source": "Son cinco euros"}$j$::jsonb,$j${"value": "Fa cinque euro", "accepted": ["Fa cinque euro", "fa cinque euro", "Fa cinque euro.", "Sono cinque euro", "Sono cinque euro."]}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$precios$p$, $p$writing$p$]),
('c79db8f1-f1e5-5b6d-b801-0e74d123b5b2'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Il conto, per favore.", "Quanto costa?", "Fa due euro."], "say": "Il conto, per favore.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/c79db8f1-f1e5-5b6d-b801-0e74d123b5b2.mp3"}$j$::jsonb,$j${"value": "Il conto, per favore."}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$precios$p$, $p$listening$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('87747a7d-095d-5d65-929e-b4dea3e98535','11c8d6fa-c3ca-5044-8899-e171ee564a62',1),
 ('87747a7d-095d-5d65-929e-b4dea3e98535','f2fc71be-fbbd-5806-9f35-67dec3737d3d',2),
 ('87747a7d-095d-5d65-929e-b4dea3e98535','76e0da36-6eb7-5687-b961-4cee9f9d5984',3),
 ('87747a7d-095d-5d65-929e-b4dea3e98535','9bf067dd-6f86-5d83-8b45-2daa0c13d295',4),
 ('87747a7d-095d-5d65-929e-b4dea3e98535','58a7697c-8ecf-5547-97f4-6d7adfde7370',5),
 ('b555d1cf-3449-5e9e-808b-9e34d519afbe','45fe4e9f-bb16-5c06-9d6f-f9a4583b120b',1),
 ('b555d1cf-3449-5e9e-808b-9e34d519afbe','90e4cf53-bd1c-51ed-bea8-aef7dc0e6931',2),
 ('b555d1cf-3449-5e9e-808b-9e34d519afbe','f3dd41cf-7381-57d6-adc8-e43093170db8',3),
 ('b555d1cf-3449-5e9e-808b-9e34d519afbe','41c3026a-5c85-5097-ba20-87527c6544d1',4),
 ('b555d1cf-3449-5e9e-808b-9e34d519afbe','879743f7-2d12-5eb0-963a-3af1246decf9',5),
 ('b555d1cf-3449-5e9e-808b-9e34d519afbe','f6b334f1-afec-5271-a89e-fa4c6d012926',6),
 ('b454a0cb-dbaa-5827-bf9b-eaf83e927431','fcff1538-c407-572d-9e28-b76a9609639a',1),
 ('b454a0cb-dbaa-5827-bf9b-eaf83e927431','66859f9c-2494-515c-a647-dae408c11d55',2),
 ('b454a0cb-dbaa-5827-bf9b-eaf83e927431','b5701f97-bdcb-5214-b975-a8207351788b',3),
 ('b454a0cb-dbaa-5827-bf9b-eaf83e927431','986fb4fc-d75e-5aac-8e80-97acf5bf8635',4),
 ('b454a0cb-dbaa-5827-bf9b-eaf83e927431','4b972ae4-8b70-58b7-a2c5-b0c1b7adbebb',5),
 ('7dda92f6-abc3-5081-9e5f-463d0a12e837','87dac567-d0bf-5087-a20c-d4237635ebda',1),
 ('7dda92f6-abc3-5081-9e5f-463d0a12e837','d17fb88e-7a53-5db6-93aa-bed37d49963e',2),
 ('7dda92f6-abc3-5081-9e5f-463d0a12e837','c79db8f1-f1e5-5b6d-b801-0e74d123b5b2',3),
 ('a6691153-d423-5a45-883d-aba046f5d776','11c8d6fa-c3ca-5044-8899-e171ee564a62',1),
 ('a6691153-d423-5a45-883d-aba046f5d776','f2fc71be-fbbd-5806-9f35-67dec3737d3d',2),
 ('a6691153-d423-5a45-883d-aba046f5d776','45fe4e9f-bb16-5c06-9d6f-f9a4583b120b',3),
 ('a6691153-d423-5a45-883d-aba046f5d776','9bf067dd-6f86-5d83-8b45-2daa0c13d295',4),
 ('a6691153-d423-5a45-883d-aba046f5d776','f3dd41cf-7381-57d6-adc8-e43093170db8',5),
 ('a6691153-d423-5a45-883d-aba046f5d776','41c3026a-5c85-5097-ba20-87527c6544d1',6),
 ('a6691153-d423-5a45-883d-aba046f5d776','76e0da36-6eb7-5687-b961-4cee9f9d5984',7),
 ('a6691153-d423-5a45-883d-aba046f5d776','879743f7-2d12-5eb0-963a-3af1246decf9',8),
 ('a6691153-d423-5a45-883d-aba046f5d776','58a7697c-8ecf-5547-97f4-6d7adfde7370',9),
 ('a6691153-d423-5a45-883d-aba046f5d776','f6b334f1-afec-5271-a89e-fa4c6d012926',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('0103b8ec-5625-5252-a187-ba73fd3a1478','20000000-0000-0000-0000-000000000004',$p$il pane$p$,$p$el pan$p$,181,'sustantivo'),
 ('e442e5fa-5134-53f3-bfde-ca49c8ea63b2','20000000-0000-0000-0000-000000000004',$p$l'acqua$p$,$p$el agua$p$,182,'sustantivo'),
 ('a1f42711-7b58-5375-b3dd-99c70e06002a','20000000-0000-0000-0000-000000000004',$p$il caffè$p$,$p$el café$p$,183,'sustantivo'),
 ('a48b4cb7-67d9-5305-9a7e-3570d64bc4f9','20000000-0000-0000-0000-000000000004',$p$il latte$p$,$p$la leche$p$,184,'sustantivo'),
 ('653c5aa9-e19f-59d0-b826-49ca07ca392c','20000000-0000-0000-0000-000000000004',$p$la pizza$p$,$p$la pizza$p$,185,'sustantivo'),
 ('39fbd9df-4255-5f82-9066-cb4b1eb9ef52','20000000-0000-0000-0000-000000000004',$p$la mela$p$,$p$la manzana$p$,186,'sustantivo'),
 ('3cc8307f-8ecb-5ec6-bf59-d91e172626d3','20000000-0000-0000-0000-000000000004',$p$il vino$p$,$p$el vino$p$,187,'sustantivo'),
 ('65af41dd-dfd3-5321-9770-1ffa8449e42b','20000000-0000-0000-0000-000000000004',$p$la birra$p$,$p$la cerveza$p$,188,'sustantivo'),
 ('e7c4a16a-2df1-5cde-b379-a84413615de8','20000000-0000-0000-0000-000000000004',$p$la pasta$p$,$p$la pasta$p$,189,'sustantivo'),
 ('8ee08d3a-0f74-5a03-8738-e6138d29b592','20000000-0000-0000-0000-000000000004',$p$il conto$p$,$p$la cuenta$p$,190,'sustantivo'),
 ('be81c339-d104-5828-af73-484c683d87e5','20000000-0000-0000-0000-000000000004',$p$vorrei$p$,$p$quisiera / querría$p$,191,'verbo'),
 ('500f4aee-df25-57a5-b919-9ef6f7cf0ebc','20000000-0000-0000-0000-000000000004',$p$per favore$p$,$p$por favor$p$,192,'expresion'),
 ('a591d4c8-4e74-525e-a456-ad6f2e1f566b','20000000-0000-0000-0000-000000000004',$p$del$p$,$p$algo de (partitivo masc.)$p$,193,'articulo'),
 ('650c23c1-8549-57ab-a706-873ffc2d0537','20000000-0000-0000-0000-000000000004',$p$della$p$,$p$algo de (partitivo fem.)$p$,194,'articulo'),
 ('8eddc32d-56b6-5df9-b63b-ce707311ba50','20000000-0000-0000-0000-000000000004',$p$dell'$p$,$p$algo de (partitivo ante vocal)$p$,195,'articulo'),
 ('d171d552-de66-5e6d-9b14-9826cfa8605b','20000000-0000-0000-0000-000000000004',$p$quanto$p$,$p$cuánto$p$,196,'adverbio')
on conflict (id) do nothing;

-- ── Unidad 5 (A1·it): El día y la hora ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('ca7c984b-adce-5315-943e-e032d26b5e63','20000000-0000-0000-0000-000000000004','A1',5,$p$El día y la hora$p$,'#2980B9','schedule')
on conflict (course_id, order_index) do update set title=excluded.title, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('5084f5a0-2de2-5e9d-81c2-0cf0679c88a9','ca7c984b-adce-5315-943e-e032d26b5e63',1,$p$¿Qué hora es?$p$,$p$¿Qué hora es?$p$,'lesson',15),
 ('0743ddc6-e689-53a6-ac6a-52d53b62a37b','ca7c984b-adce-5315-943e-e032d26b5e63',2,$p$Los días de la semana$p$,$p$Los días de la semana$p$,'lesson',15),
 ('6c6e6d08-dbb4-5fc1-a5be-14894d6a8ab8','ca7c984b-adce-5315-943e-e032d26b5e63',3,$p$Verbos en -are$p$,$p$Verbos en -are$p$,'lesson',15),
 ('9e714314-51b5-5931-9d2a-64723467831f','ca7c984b-adce-5315-943e-e032d26b5e63',4,$p$Mi rutina diaria$p$,$p$Mi rutina diaria$p$,'lesson',15),
 ('620c6efb-dcca-582f-be01-158ee31e0a41','ca7c984b-adce-5315-943e-e032d26b5e63',5,$p$🏁 Checkpoint Unité 5$p$,$p$Aprende a decir la hora, los días de la semana y a hablar de tu rutina con verbos en -are.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('17eda30b-6c2a-5188-a77c-caa3ed2ac622','20000000-0000-0000-0000-000000000004','checkpoint','A1','ca7c984b-adce-5315-943e-e032d26b5e63',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('d77de14d-1b57-5d68-b856-af8c0a7e0a5d'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','reading','match',$p$Une cada hora en italiano con su traducción.$p$,$j${"pairs": [{"en": "Sono le tre", "es": "Son las tres"}, {"en": "È l'una", "es": "Es la una"}, {"en": "È mezzogiorno", "es": "Es mediodía"}]}$j$::jsonb,$j${"pairs": [["Sono le tre", "Son las tres"], ["È l'una", "Es la una"], ["È mezzogiorno", "Es mediodía"]]}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$la_hora$p$, $p$reading$p$]),
('dfae192c-3352-5a5e-bbe0-4cdcc79a7e3b'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','reading','multiple_choice',$p$¿Cómo se dice 'Es la una' en italiano?$p$,$j${"options": ["È l'una", "Sono l'una", "Sono le una"]}$j$::jsonb,$j${"value": "È l'una"}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$la_hora$p$, $p$reading$p$]),
('ac904470-0a9f-53a0-aaf5-d1e8d2785bb6'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','reading','multiple_choice',$p$¿Cómo se dice 'Son las tres y media'?$p$,$j${"options": ["Sono le tre e mezza", "È le tre e mezza", "Sono la tre e mezza"]}$j$::jsonb,$j${"value": "Sono le tre e mezza"}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$la_hora$p$, $p$reading$p$]),
('4382443f-b856-515e-873b-bae0c3f2d75e'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','writing','cloze',$p$Completa: 'Es la una' (fíjate en el singular).$p$,$j${"text": "___ l'una."}$j$::jsonb,$j${"value": "È", "accepted": ["È", "E'", "è"]}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$la_hora$p$, $p$writing$p$]),
('601884b2-ec05-525d-b491-156f7737be67'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Sono le tre e un quarto.", "Sono le due e un quarto.", "Sono le tre e mezza."], "say": "Sono le tre e un quarto.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/601884b2-ec05-525d-b491-156f7737be67.mp3"}$j$::jsonb,$j${"value": "Sono le tre e un quarto."}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$la_hora$p$, $p$listening$p$]),
('5a48515d-3af1-58e4-8bd1-b27598189b52'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Che ore sono?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/5a48515d-3af1-58e4-8bd1-b27598189b52.mp3"}$j$::jsonb,$j${"expected": "Che ore sono?"}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$la_hora$p$, $p$speaking$p$]),
('5bb48f63-0d6f-5ac8-9b31-0f25c1fbc3ba'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','reading','match',$p$Une cada día en italiano con su traducción.$p$,$j${"pairs": [{"en": "lunedì", "es": "lunes"}, {"en": "mercoledì", "es": "miércoles"}, {"en": "domenica", "es": "domingo"}]}$j$::jsonb,$j${"pairs": [["lunedì", "lunes"], ["mercoledì", "miércoles"], ["domenica", "domingo"]]}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$dias_semana$p$, $p$reading$p$]),
('01a2d914-e6f6-5a1a-ae50-01cc6b6e33e8'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','reading','multiple_choice',$p$¿Cómo se dice 'sábado' en italiano?$p$,$j${"options": ["sabato", "domenica", "venerdì"]}$j$::jsonb,$j${"value": "sabato"}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$dias_semana$p$, $p$reading$p$]),
('8272f770-031a-593a-b695-72a1de6ac92a'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','writing','translation',$p$Traduce: 'Hoy es lunes.'$p$,$j${"source": "Hoy es lunes."}$j$::jsonb,$j${"value": "Oggi è lunedì.", "accepted": ["Oggi è lunedì.", "Oggi è lunedì", "Oggi e lunedi.", "Oggi e lunedi", "oggi è lunedì", "oggi e lunedi"]}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$dias_semana$p$, $p$writing$p$]),
('b7387768-078f-5a43-9601-b8be5efc6945'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','writing','word_bank',$p$Ordena las fichas: 'El domingo no trabajo.'$p$,$j${"tiles": ["La", "domenica", "non", "lavoro", "mangio"]}$j$::jsonb,$j${"value": "La domenica non lavoro", "sequence": ["La", "domenica", "non", "lavoro"]}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$dias_semana$p$, $p$writing$p$]),
('767eb6a7-284e-5a98-89d8-bfe0582add76'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Oggi è venerdì.", "Oggi è giovedì.", "Oggi è martedì."], "say": "Oggi è venerdì.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/767eb6a7-284e-5a98-89d8-bfe0582add76.mp3"}$j$::jsonb,$j${"value": "Oggi è venerdì."}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$dias_semana$p$, $p$listening$p$]),
('a683076d-612b-5343-a588-02a4a95d6d0e'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Oggi è domenica.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/a683076d-612b-5343-a588-02a4a95d6d0e.mp3"}$j$::jsonb,$j${"expected": "Oggi è domenica."}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$dias_semana$p$, $p$speaking$p$]),
('82da6cb5-c6f9-5630-b972-05034046b199'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','reading','multiple_choice',$p$Completa: 'Io ___ italiano.' (parlare)$p$,$j${"options": ["parlo", "parli", "parla"]}$j$::jsonb,$j${"value": "parlo"}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$verbos_are$p$, $p$reading$p$]),
('779db3c0-a0f4-553a-96dd-33f2b1c7480a'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','writing','cloze',$p$Completa con 'mangiare' en la forma 'io': 'Io ___ una pizza.'$p$,$j${"text": "Io ___ una pizza."}$j$::jsonb,$j${"value": "mangio", "accepted": ["mangio"]}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$verbos_are$p$, $p$writing$p$]),
('b26b2ed7-a36e-5f34-99e1-1f064694148a'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','writing','translation',$p$Traduce: 'Tú hablas italiano.'$p$,$j${"source": "Tú hablas italiano."}$j$::jsonb,$j${"value": "Tu parli italiano.", "accepted": ["Tu parli italiano.", "Tu parli italiano", "tu parli italiano", "Parli italiano.", "Parli italiano", "parli italiano"]}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$verbos_are$p$, $p$writing$p$]),
('71d75c97-7db9-5ca6-a86f-84cc2a2f9ee0'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Lui lavora in ufficio.", "Lui parla in ufficio.", "Io lavoro in ufficio."], "say": "Lui lavora in ufficio.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/71d75c97-7db9-5ca6-a86f-84cc2a2f9ee0.mp3"}$j$::jsonb,$j${"value": "Lui lavora in ufficio."}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$verbos_are$p$, $p$listening$p$]),
('4ec5bc61-1207-590d-8afc-10f2572ae896'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','writing','reorder',$p$Ordena las palabras: 'Por la mañana trabajo.'$p$,$j${"tiles": ["lavoro", "La", "mattina"]}$j$::jsonb,$j${"value": "La mattina lavoro"}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$rutina$p$, $p$writing$p$]),
('2da4a58a-3df4-515e-afcd-9aeccf1006f9'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["A che ora mangi?", "A che ora lavori?", "Che ore sono?"], "say": "A che ora mangi?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/2da4a58a-3df4-515e-afcd-9aeccf1006f9.mp3"}$j$::jsonb,$j${"value": "A che ora mangi?"}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$rutina$p$, $p$listening$p$]),
('40e3a9c2-41a5-5194-87d4-9d2e02341f54'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Mi alzo alle sette.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/40e3a9c2-41a5-5194-87d4-9d2e02341f54.mp3"}$j$::jsonb,$j${"expected": "Mi alzo alle sette."}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$rutina$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('5084f5a0-2de2-5e9d-81c2-0cf0679c88a9','d77de14d-1b57-5d68-b856-af8c0a7e0a5d',1),
 ('5084f5a0-2de2-5e9d-81c2-0cf0679c88a9','dfae192c-3352-5a5e-bbe0-4cdcc79a7e3b',2),
 ('5084f5a0-2de2-5e9d-81c2-0cf0679c88a9','ac904470-0a9f-53a0-aaf5-d1e8d2785bb6',3),
 ('5084f5a0-2de2-5e9d-81c2-0cf0679c88a9','4382443f-b856-515e-873b-bae0c3f2d75e',4),
 ('5084f5a0-2de2-5e9d-81c2-0cf0679c88a9','601884b2-ec05-525d-b491-156f7737be67',5),
 ('5084f5a0-2de2-5e9d-81c2-0cf0679c88a9','5a48515d-3af1-58e4-8bd1-b27598189b52',6),
 ('0743ddc6-e689-53a6-ac6a-52d53b62a37b','5bb48f63-0d6f-5ac8-9b31-0f25c1fbc3ba',1),
 ('0743ddc6-e689-53a6-ac6a-52d53b62a37b','01a2d914-e6f6-5a1a-ae50-01cc6b6e33e8',2),
 ('0743ddc6-e689-53a6-ac6a-52d53b62a37b','8272f770-031a-593a-b695-72a1de6ac92a',3),
 ('0743ddc6-e689-53a6-ac6a-52d53b62a37b','b7387768-078f-5a43-9601-b8be5efc6945',4),
 ('0743ddc6-e689-53a6-ac6a-52d53b62a37b','767eb6a7-284e-5a98-89d8-bfe0582add76',5),
 ('0743ddc6-e689-53a6-ac6a-52d53b62a37b','a683076d-612b-5343-a588-02a4a95d6d0e',6),
 ('6c6e6d08-dbb4-5fc1-a5be-14894d6a8ab8','82da6cb5-c6f9-5630-b972-05034046b199',1),
 ('6c6e6d08-dbb4-5fc1-a5be-14894d6a8ab8','779db3c0-a0f4-553a-96dd-33f2b1c7480a',2),
 ('6c6e6d08-dbb4-5fc1-a5be-14894d6a8ab8','b26b2ed7-a36e-5f34-99e1-1f064694148a',3),
 ('6c6e6d08-dbb4-5fc1-a5be-14894d6a8ab8','71d75c97-7db9-5ca6-a86f-84cc2a2f9ee0',4),
 ('9e714314-51b5-5931-9d2a-64723467831f','4ec5bc61-1207-590d-8afc-10f2572ae896',1),
 ('9e714314-51b5-5931-9d2a-64723467831f','2da4a58a-3df4-515e-afcd-9aeccf1006f9',2),
 ('9e714314-51b5-5931-9d2a-64723467831f','40e3a9c2-41a5-5194-87d4-9d2e02341f54',3),
 ('620c6efb-dcca-582f-be01-158ee31e0a41','d77de14d-1b57-5d68-b856-af8c0a7e0a5d',1),
 ('620c6efb-dcca-582f-be01-158ee31e0a41','dfae192c-3352-5a5e-bbe0-4cdcc79a7e3b',2),
 ('620c6efb-dcca-582f-be01-158ee31e0a41','ac904470-0a9f-53a0-aaf5-d1e8d2785bb6',3),
 ('620c6efb-dcca-582f-be01-158ee31e0a41','4382443f-b856-515e-873b-bae0c3f2d75e',4),
 ('620c6efb-dcca-582f-be01-158ee31e0a41','8272f770-031a-593a-b695-72a1de6ac92a',5),
 ('620c6efb-dcca-582f-be01-158ee31e0a41','b7387768-078f-5a43-9601-b8be5efc6945',6),
 ('620c6efb-dcca-582f-be01-158ee31e0a41','601884b2-ec05-525d-b491-156f7737be67',7),
 ('620c6efb-dcca-582f-be01-158ee31e0a41','767eb6a7-284e-5a98-89d8-bfe0582add76',8),
 ('620c6efb-dcca-582f-be01-158ee31e0a41','5a48515d-3af1-58e4-8bd1-b27598189b52',9),
 ('620c6efb-dcca-582f-be01-158ee31e0a41','a683076d-612b-5343-a588-02a4a95d6d0e',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('682eaa33-5692-5730-b5dd-5d396f0299d8','20000000-0000-0000-0000-000000000004',$p$l'ora$p$,$p$la hora$p$,201,'sustantivo'),
 ('397cfea2-9d70-5a13-9a74-1b49bda1d6f4','20000000-0000-0000-0000-000000000004',$p$mezzogiorno$p$,$p$mediodía$p$,202,'sustantivo'),
 ('1391e82a-b9be-555e-ad8a-8d0ec9cb218e','20000000-0000-0000-0000-000000000004',$p$mezzanotte$p$,$p$medianoche$p$,203,'sustantivo'),
 ('358b2fe8-02ad-55cc-ac30-fa945be7e275','20000000-0000-0000-0000-000000000004',$p$il quarto$p$,$p$el cuarto$p$,204,'sustantivo'),
 ('85386f15-aefd-5f40-a097-a9d1427696d1','20000000-0000-0000-0000-000000000004',$p$mezza$p$,$p$media$p$,205,'adjetivo'),
 ('785cbf59-4aa0-58c6-b4dc-ce7eb6ea536c','20000000-0000-0000-0000-000000000004',$p$il giorno$p$,$p$el día$p$,206,'sustantivo'),
 ('a2cd5d2d-34b2-569f-8925-88dbe88c592b','20000000-0000-0000-0000-000000000004',$p$la settimana$p$,$p$la semana$p$,207,'sustantivo'),
 ('f37ac901-7509-5a10-b5d2-15c34be34625','20000000-0000-0000-0000-000000000004',$p$lunedì$p$,$p$lunes$p$,208,'sustantivo'),
 ('8dff0e4b-3ce0-50b5-a7e5-14f947e80ef8','20000000-0000-0000-0000-000000000004',$p$mercoledì$p$,$p$miércoles$p$,209,'sustantivo'),
 ('eb3b5656-9346-5b51-937f-2e13c45812b7','20000000-0000-0000-0000-000000000004',$p$sabato$p$,$p$sábado$p$,210,'sustantivo'),
 ('0d5c8e00-9183-5ec9-8d5a-dc09b0a3bd13','20000000-0000-0000-0000-000000000004',$p$domenica$p$,$p$domingo$p$,211,'sustantivo'),
 ('bbb15a74-7187-5d97-88e2-77393e300a97','20000000-0000-0000-0000-000000000004',$p$la mattina$p$,$p$la mañana$p$,212,'sustantivo'),
 ('3a795fe0-18ef-5e7b-8fe6-b74dda14537c','20000000-0000-0000-0000-000000000004',$p$parlare$p$,$p$hablar$p$,213,'verbo'),
 ('05ae53b9-a922-5bd7-9de2-6e19fdb382ff','20000000-0000-0000-0000-000000000004',$p$lavorare$p$,$p$trabajar$p$,214,'verbo'),
 ('b5f27e26-8e39-5d7d-bc3f-749ea0072bb7','20000000-0000-0000-0000-000000000004',$p$mangiare$p$,$p$comer$p$,215,'verbo'),
 ('40662156-1d5a-5c64-bc17-6934b22f1bfe','20000000-0000-0000-0000-000000000004',$p$abitare$p$,$p$vivir (residir)$p$,216,'verbo')
on conflict (id) do nothing;

-- ── Unidad 6 (A1·it): La ciudad y direcciones ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('9a48ae51-7880-56c6-9c17-b6a1cbb3e0f3','20000000-0000-0000-0000-000000000004','A1',6,$p$La ciudad y direcciones$p$,'#16A085','location_city')
on conflict (course_id, order_index) do update set title=excluded.title, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('6095a5de-e9f7-57dd-a2db-a61a59823282','9a48ae51-7880-56c6-9c17-b6a1cbb3e0f3',1,$p$Lugares de la ciudad$p$,$p$Lugares de la ciudad$p$,'lesson',15),
 ('f0f254e1-828d-50c1-9458-f819fb26bb62','9a48ae51-7880-56c6-9c17-b6a1cbb3e0f3',2,$p$¿Dónde está?$p$,$p$¿Dónde está?$p$,'lesson',15),
 ('4bb64ed6-8d98-532a-b4c5-a57fdfdc4f78','9a48ae51-7880-56c6-9c17-b6a1cbb3e0f3',3,$p$Dar direcciones$p$,$p$Dar direcciones$p$,'lesson',15),
 ('91ea4b1b-50c2-5ee3-a51d-c7dd4b9c2cf1','9a48ae51-7880-56c6-9c17-b6a1cbb3e0f3',4,$p$Al, alla, nel$p$,$p$Al, alla, nel$p$,'lesson',15),
 ('ed981da4-5da1-5be1-aa14-7d4ad6fa7c6f','9a48ae51-7880-56c6-9c17-b6a1cbb3e0f3',5,$p$🏁 Checkpoint Unité 6$p$,$p$Aprende los lugares de la ciudad, a preguntar dónde están y a dar direcciones con preposiciones articuladas.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('779132ba-5327-5ff1-b5f4-4832a6d83c4b','20000000-0000-0000-0000-000000000004','checkpoint','A1','9a48ae51-7880-56c6-9c17-b6a1cbb3e0f3',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('e0fbb50d-82c9-5568-94f8-2858c563e339'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','reading','match',$p$Une cada lugar en italiano con su traducción.$p$,$j${"pairs": [{"en": "la stazione", "es": "la estación"}, {"en": "il museo", "es": "el museo"}, {"en": "l'ospedale", "es": "el hospital"}]}$j$::jsonb,$j${"pairs": [["la stazione", "la estación"], ["il museo", "el museo"], ["l'ospedale", "el hospital"]]}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$lugares$p$, $p$reading$p$]),
('3cbb0381-2e23-5cd2-aa50-08f6c30280b3'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','reading','multiple_choice',$p$¿Cómo se dice 'el restaurante' en italiano?$p$,$j${"options": ["il ristorante", "l'albergo", "la banca"]}$j$::jsonb,$j${"value": "il ristorante"}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$lugares$p$, $p$reading$p$]),
('49b0e443-6b53-5a6b-af0d-7f994c0d1ec4'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','reading','multiple_choice',$p$¿Cómo se dice 'la plaza' en italiano?$p$,$j${"options": ["la piazza", "la strada", "la stazione"]}$j$::jsonb,$j${"value": "la piazza"}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$lugares$p$, $p$reading$p$]),
('631f377f-d42a-5d4f-90fd-bd80226d00e4'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["La banca è in piazza.", "Il museo è in piazza.", "La banca è in strada."], "say": "La banca è in piazza.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/631f377f-d42a-5d4f-90fd-bd80226d00e4.mp3"}$j$::jsonb,$j${"value": "La banca è in piazza."}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$lugares$p$, $p$listening$p$]),
('37935b0e-97d6-5b30-90d0-f6e3a0065960'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "C'è un museo qui?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/37935b0e-97d6-5b30-90d0-f6e3a0065960.mp3"}$j$::jsonb,$j${"expected": "C'è un museo qui?"}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$lugares$p$, $p$speaking$p$]),
('1af7d70f-399c-5675-9c29-616c1dfaf246'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','reading','match',$p$Une cada pregunta con su traducción.$p$,$j${"pairs": [{"en": "Dov'è la banca?", "es": "¿Dónde está el banco?"}, {"en": "C'è un hotel?", "es": "¿Hay un hotel?"}, {"en": "Ci sono ristoranti?", "es": "¿Hay restaurantes?"}]}$j$::jsonb,$j${"pairs": [["Dov'è la banca?", "¿Dónde está el banco?"], ["C'è un hotel?", "¿Hay un hotel?"], ["Ci sono ristoranti?", "¿Hay restaurantes?"]]}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$dov_e$p$, $p$reading$p$]),
('9f351d7f-f4e6-523f-8b3a-b3fdee7225d1'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','writing','cloze',$p$Completa: 'Hay un museo aquí.'$p$,$j${"text": "___ un museo qui."}$j$::jsonb,$j${"value": "C'è", "accepted": ["C'è", "c'è", "C'e"]}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$dov_e$p$, $p$writing$p$]),
('2a1e2f81-d6b6-53df-8563-a0c04c763465'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','writing','translation',$p$Traduce: '¿Dónde está el hospital?'$p$,$j${"source": "¿Dónde está el hospital?"}$j$::jsonb,$j${"value": "Dov'è l'ospedale?", "accepted": ["Dov'è l'ospedale?", "Dov'è l'ospedale", "Dove l'ospedale?", "Dov'e l'ospedale?", "dov'è l'ospedale", "dove l'ospedale"]}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$dov_e$p$, $p$writing$p$]),
('f8060df8-86ff-55cc-82c2-a6fb5ca84ff0'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Dov'è la stazione?", "Dov'è la banca?", "C'è una stazione?"], "say": "Dov'è la stazione?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/f8060df8-86ff-55cc-82c2-a6fb5ca84ff0.mp3"}$j$::jsonb,$j${"value": "Dov'è la stazione?"}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$dov_e$p$, $p$listening$p$]),
('0eddcbb9-b7bb-5b0b-9d0a-c4cf5c44e680'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Dov'è l'albergo?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/0eddcbb9-b7bb-5b0b-9d0a-c4cf5c44e680.mp3"}$j$::jsonb,$j${"expected": "Dov'è l'albergo?"}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$dov_e$p$, $p$speaking$p$]),
('8c10b921-ad0d-5edc-af4b-e470b1df1f42'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','reading','multiple_choice',$p$¿Cómo se dice 'todo recto' en italiano?$p$,$j${"options": ["sempre dritto", "a destra", "a sinistra"]}$j$::jsonb,$j${"value": "sempre dritto"}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$direcciones$p$, $p$reading$p$]),
('a7d24316-010b-5aaf-818f-ec72c71b07a5'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','writing','word_bank',$p$Ordena las fichas: 'La banca está a la derecha.'$p$,$j${"tiles": ["La", "banca", "è", "a", "destra", "sinistra"]}$j$::jsonb,$j${"value": "La banca è a destra", "sequence": ["La", "banca", "è", "a", "destra"]}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$direcciones$p$, $p$writing$p$]),
('9dc8843b-d1fa-5c6c-8a85-001e21f788e8'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Vai sempre dritto.", "Vai a destra.", "Vai a sinistra."], "say": "Vai sempre dritto.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/9dc8843b-d1fa-5c6c-8a85-001e21f788e8.mp3"}$j$::jsonb,$j${"value": "Vai sempre dritto."}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$direcciones$p$, $p$listening$p$]),
('65361bb1-18b3-5091-a8a6-b838d65c3992'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Gira a destra.", "Gira a sinistra.", "Vai sempre dritto."], "say": "Gira a destra.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/65361bb1-18b3-5091-a8a6-b838d65c3992.mp3"}$j$::jsonb,$j${"value": "Gira a destra."}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$direcciones$p$, $p$listening$p$]),
('0796637f-9cfa-532f-b088-a4255dd1ef17'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Gira a sinistra.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/0796637f-9cfa-532f-b088-a4255dd1ef17.mp3"}$j$::jsonb,$j${"expected": "Gira a sinistra."}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$direcciones$p$, $p$speaking$p$]),
('cd1ef046-03cd-59c8-b720-e3bb34a6cd0d'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','reading','multiple_choice',$p$Completa: 'Sono ___ ristorante.' (a + il)$p$,$j${"options": ["al", "alla", "nel"]}$j$::jsonb,$j${"value": "al"}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$prep_articuladas$p$, $p$reading$p$]),
('d7deebd3-693a-556c-ac4b-1f8faa47f5a2'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','writing','cloze',$p$Completa: 'Vado ___ stazione.' (a + la)$p$,$j${"text": "Vado ___ stazione."}$j$::jsonb,$j${"value": "alla", "accepted": ["alla"]}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$prep_articuladas$p$, $p$writing$p$]),
('7d72ab4a-2f67-57bf-a3e8-cc0a777c53f1'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','writing','translation',$p$Traduce: 'El museo está enfrente del banco.'$p$,$j${"source": "El museo está enfrente del banco."}$j$::jsonb,$j${"value": "Il museo è di fronte alla banca.", "accepted": ["Il museo è di fronte alla banca.", "Il museo è di fronte alla banca", "Il museo e di fronte alla banca.", "Il museo e di fronte alla banca", "il museo è di fronte alla banca", "il museo e di fronte alla banca"]}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$prep_articuladas$p$, $p$writing$p$]),
('aefb41a3-b533-5af5-9fdd-320b02e7aec7'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A1','writing','reorder',$p$Ordena las palabras: 'La casa está cerca del museo.'$p$,$j${"tiles": ["museo", "La", "casa", "è", "vicino", "al"]}$j$::jsonb,$j${"value": "La casa è vicino al museo"}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$prep_articuladas$p$, $p$writing$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('6095a5de-e9f7-57dd-a2db-a61a59823282','e0fbb50d-82c9-5568-94f8-2858c563e339',1),
 ('6095a5de-e9f7-57dd-a2db-a61a59823282','3cbb0381-2e23-5cd2-aa50-08f6c30280b3',2),
 ('6095a5de-e9f7-57dd-a2db-a61a59823282','49b0e443-6b53-5a6b-af0d-7f994c0d1ec4',3),
 ('6095a5de-e9f7-57dd-a2db-a61a59823282','631f377f-d42a-5d4f-90fd-bd80226d00e4',4),
 ('6095a5de-e9f7-57dd-a2db-a61a59823282','37935b0e-97d6-5b30-90d0-f6e3a0065960',5),
 ('f0f254e1-828d-50c1-9458-f819fb26bb62','1af7d70f-399c-5675-9c29-616c1dfaf246',1),
 ('f0f254e1-828d-50c1-9458-f819fb26bb62','9f351d7f-f4e6-523f-8b3a-b3fdee7225d1',2),
 ('f0f254e1-828d-50c1-9458-f819fb26bb62','2a1e2f81-d6b6-53df-8563-a0c04c763465',3),
 ('f0f254e1-828d-50c1-9458-f819fb26bb62','f8060df8-86ff-55cc-82c2-a6fb5ca84ff0',4),
 ('f0f254e1-828d-50c1-9458-f819fb26bb62','0eddcbb9-b7bb-5b0b-9d0a-c4cf5c44e680',5),
 ('4bb64ed6-8d98-532a-b4c5-a57fdfdc4f78','8c10b921-ad0d-5edc-af4b-e470b1df1f42',1),
 ('4bb64ed6-8d98-532a-b4c5-a57fdfdc4f78','a7d24316-010b-5aaf-818f-ec72c71b07a5',2),
 ('4bb64ed6-8d98-532a-b4c5-a57fdfdc4f78','9dc8843b-d1fa-5c6c-8a85-001e21f788e8',3),
 ('4bb64ed6-8d98-532a-b4c5-a57fdfdc4f78','65361bb1-18b3-5091-a8a6-b838d65c3992',4),
 ('4bb64ed6-8d98-532a-b4c5-a57fdfdc4f78','0796637f-9cfa-532f-b088-a4255dd1ef17',5),
 ('91ea4b1b-50c2-5ee3-a51d-c7dd4b9c2cf1','cd1ef046-03cd-59c8-b720-e3bb34a6cd0d',1),
 ('91ea4b1b-50c2-5ee3-a51d-c7dd4b9c2cf1','d7deebd3-693a-556c-ac4b-1f8faa47f5a2',2),
 ('91ea4b1b-50c2-5ee3-a51d-c7dd4b9c2cf1','7d72ab4a-2f67-57bf-a3e8-cc0a777c53f1',3),
 ('91ea4b1b-50c2-5ee3-a51d-c7dd4b9c2cf1','aefb41a3-b533-5af5-9fdd-320b02e7aec7',4),
 ('ed981da4-5da1-5be1-aa14-7d4ad6fa7c6f','e0fbb50d-82c9-5568-94f8-2858c563e339',1),
 ('ed981da4-5da1-5be1-aa14-7d4ad6fa7c6f','3cbb0381-2e23-5cd2-aa50-08f6c30280b3',2),
 ('ed981da4-5da1-5be1-aa14-7d4ad6fa7c6f','49b0e443-6b53-5a6b-af0d-7f994c0d1ec4',3),
 ('ed981da4-5da1-5be1-aa14-7d4ad6fa7c6f','9f351d7f-f4e6-523f-8b3a-b3fdee7225d1',4),
 ('ed981da4-5da1-5be1-aa14-7d4ad6fa7c6f','2a1e2f81-d6b6-53df-8563-a0c04c763465',5),
 ('ed981da4-5da1-5be1-aa14-7d4ad6fa7c6f','a7d24316-010b-5aaf-818f-ec72c71b07a5',6),
 ('ed981da4-5da1-5be1-aa14-7d4ad6fa7c6f','631f377f-d42a-5d4f-90fd-bd80226d00e4',7),
 ('ed981da4-5da1-5be1-aa14-7d4ad6fa7c6f','f8060df8-86ff-55cc-82c2-a6fb5ca84ff0',8),
 ('ed981da4-5da1-5be1-aa14-7d4ad6fa7c6f','37935b0e-97d6-5b30-90d0-f6e3a0065960',9),
 ('ed981da4-5da1-5be1-aa14-7d4ad6fa7c6f','0eddcbb9-b7bb-5b0b-9d0a-c4cf5c44e680',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('6a1bb345-e94c-5493-b239-3265716a89fb','20000000-0000-0000-0000-000000000004',$p$la stazione$p$,$p$la estación$p$,221,'sustantivo'),
 ('bb88ae31-df06-5bbc-a755-6745331eaa19','20000000-0000-0000-0000-000000000004',$p$la banca$p$,$p$el banco$p$,222,'sustantivo'),
 ('612fc4bb-590d-5a67-934e-900150f3374d','20000000-0000-0000-0000-000000000004',$p$il museo$p$,$p$el museo$p$,223,'sustantivo'),
 ('c26a0da1-ecf1-5d9a-b6fb-c60843abb3cc','20000000-0000-0000-0000-000000000004',$p$il ristorante$p$,$p$el restaurante$p$,224,'sustantivo'),
 ('d840f6b5-113c-5de1-a238-728aae99fb91','20000000-0000-0000-0000-000000000004',$p$l'ospedale$p$,$p$el hospital$p$,225,'sustantivo'),
 ('0af904c8-26ee-5be4-bbb6-31aeae24a63f','20000000-0000-0000-0000-000000000004',$p$l'albergo$p$,$p$el hotel$p$,226,'sustantivo'),
 ('956bbb3e-496f-5c8e-9e84-0c7a45da12af','20000000-0000-0000-0000-000000000004',$p$la piazza$p$,$p$la plaza$p$,227,'sustantivo'),
 ('8e435358-10a3-518f-acb5-b29ce5b886dd','20000000-0000-0000-0000-000000000004',$p$la strada$p$,$p$la calle$p$,228,'sustantivo'),
 ('7d799721-109f-5f5b-81b5-b2826ca5ba16','20000000-0000-0000-0000-000000000004',$p$a destra$p$,$p$a la derecha$p$,229,'expresion'),
 ('5a17f5b9-d8d7-5d4c-a82c-35be0bfa05cf','20000000-0000-0000-0000-000000000004',$p$a sinistra$p$,$p$a la izquierda$p$,230,'expresion'),
 ('ef7b2dfa-7dfd-5ba5-8931-624ccc2d9f55','20000000-0000-0000-0000-000000000004',$p$sempre dritto$p$,$p$todo recto$p$,231,'expresion'),
 ('26bbafae-3c4e-573a-8e54-9e7b7b4e3deb','20000000-0000-0000-0000-000000000004',$p$vicino a$p$,$p$cerca de$p$,232,'expresion'),
 ('aa1106c3-cfa0-5a59-aa75-d7e1b7ae73d3','20000000-0000-0000-0000-000000000004',$p$accanto a$p$,$p$al lado de$p$,233,'expresion'),
 ('85194094-ed6e-5532-8dd2-1df6421c2b92','20000000-0000-0000-0000-000000000004',$p$di fronte a$p$,$p$enfrente de$p$,234,'expresion'),
 ('8374cce7-0ec6-584f-939b-babf9bf670c3','20000000-0000-0000-0000-000000000004',$p$dov'è$p$,$p$dónde está$p$,235,'expresion'),
 ('1faf4215-c35b-57a2-9437-67524555be83','20000000-0000-0000-0000-000000000004',$p$c'è$p$,$p$hay$p$,236,'expresion')
on conflict (id) do nothing;

commit;