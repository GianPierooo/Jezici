-- 20260703120101_seed_nl_a1.sql
-- Currículo A1 del curso es→nl (6 unidades). Molde es→pt.
-- Contenido scopeado a course_id=20000000-0000-0000-0000-000000000006 → aislamiento multicurso por
-- jz_active_course. Unidades order_index continúan la cadena → gating al nivel previo.
begin;
insert into languages (id, code, name) values
  ('10000000-0000-0000-0000-000000000007','nl',$p$Nederlands$p$) on conflict (id) do nothing;
insert into courses (id, source_language_id, target_language_id, is_active) values
  ('20000000-0000-0000-0000-000000000006','10000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000007',true) on conflict (id) do nothing;

-- ── Unidad 1 (A1·nl): Saludos y presentarte ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('41197d1a-b7ee-530c-953e-5ce7bd9257de','20000000-0000-0000-0000-000000000006','A1',1,$p$Saludos y presentarte$p$,'#C0392B','waving_hand')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('8bbcf0a6-7f99-53ad-b519-cca46347e785','41197d1a-b7ee-530c-953e-5ce7bd9257de',1,$p$Saludos y despedidas$p$,$p$Saludos y despedidas$p$,'lesson',15),
 ('923ccca5-df27-507b-8d6c-ef5693c1f0c5','41197d1a-b7ee-530c-953e-5ce7bd9257de',2,$p$Decir tu nombre$p$,$p$Decir tu nombre$p$,'lesson',15),
 ('9d421955-9f09-52db-beb8-df6ebe0dde7a','41197d1a-b7ee-530c-953e-5ce7bd9257de',3,$p$El verbo zijn (ser/estar)$p$,$p$El verbo zijn (ser/estar)$p$,'lesson',15),
 ('e7a76120-079d-51e6-88b2-8f71e958f96b','41197d1a-b7ee-530c-953e-5ce7bd9257de',4,$p$¿Cómo estás?$p$,$p$¿Cómo estás?$p$,'lesson',15),
 ('35726517-922d-5491-a751-16b786eaaeb1','41197d1a-b7ee-530c-953e-5ce7bd9257de',5,$p$🏁 Checkpoint Eenheid 1$p$,$p$Practica saludos, presentarte con Ik heet/Ik ben, el verbo zijn y preguntar cómo estás.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('9e79a934-5ecf-54d0-beac-f2a8a146478c','20000000-0000-0000-0000-000000000006','checkpoint','A1','41197d1a-b7ee-530c-953e-5ce7bd9257de',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('2522b4a3-37e5-54a3-a1e5-051ff48da501'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','reading','match',$p$Une cada saludo neerlandés con su significado.$p$,$j${"pairs": [{"en": "Hallo", "es": "Hola"}, {"en": "Goedemorgen", "es": "Buenos días"}, {"en": "Tot ziens", "es": "Hasta la vista"}]}$j$::jsonb,$j${"pairs": [["Hallo", "Hola"], ["Goedemorgen", "Buenos días"], ["Tot ziens", "Hasta la vista"]]}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$saludos$p$, $p$reading$p$]),
('c9208976-cb92-5b7b-b2a2-9e59d20814d5'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','reading','match',$p$Une cada palabra con su significado.$p$,$j${"pairs": [{"en": "Goedenavond", "es": "Buenas noches"}, {"en": "Doei", "es": "Chau"}, {"en": "Dag", "es": "Adiós"}]}$j$::jsonb,$j${"pairs": [["Goedenavond", "Buenas noches"], ["Doei", "Chau"], ["Dag", "Adiós"]]}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$saludos$p$, $p$reading$p$]),
('190778c6-897a-5862-8418-c3d5cf5a9861'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','reading','multiple_choice',$p$¿Cómo saludas por la mañana en neerlandés?$p$,$j${"options": ["Goedemorgen", "Goedenavond", "Tot ziens"]}$j$::jsonb,$j${"value": "Goedemorgen"}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$saludos$p$, $p$reading$p$]),
('8d5c3088-3d81-5b23-938c-ee6bf6f219fb'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','reading','multiple_choice',$p$¿Cuál de estas palabras es una despedida informal?$p$,$j${"options": ["Doei", "Hallo", "Goedemorgen"]}$j$::jsonb,$j${"value": "Doei"}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$despedidas$p$, $p$reading$p$]),
('6a7d3bee-04a4-5fb7-9f15-dbc68d696f45'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','reading','multiple_choice',$p$Elige la forma correcta de decir 'Me llamo Anna'.$p$,$j${"options": ["Ik heet Anna", "Ik heten Anna", "Jij heet Anna"]}$j$::jsonb,$j${"value": "Ik heet Anna"}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$presentarse$p$, $p$reading$p$]),
('2a277f2c-0ff4-5933-a7ef-b470cca296e6'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','reading','multiple_choice',$p$Alguien pregunta 'Hoe gaat het?'. ¿Qué significa?$p$,$j${"options": ["¿Cómo estás?", "¿Cómo te llamas?", "¿De dónde vienes?"]}$j$::jsonb,$j${"value": "¿Cómo estás?"}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$estado$p$, $p$reading$p$]),
('65d1d6f7-061b-522f-9c82-af767c06c3e9'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','writing','cloze',$p$Completa: 'Me llamo Peter.'$p$,$j${"text": "Ik ___ Peter."}$j$::jsonb,$j${"value": "heet", "accepted": ["heet"]}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$presentarse$p$, $p$writing$p$]),
('979fb2de-0926-56bf-af78-65fc3dee5aa3'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','writing','cloze',$p$Completa con el verbo zijn: 'Yo soy Anna.'$p$,$j${"text": "Ik ___ Anna."}$j$::jsonb,$j${"value": "ben", "accepted": ["ben"]}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$verbo_zijn$p$, $p$writing$p$]),
('32e3e163-2c6d-5748-a76a-22f161ac84e3'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','writing','translation',$p$Traduce: Me llamo Sara.$p$,$j${"source": "Me llamo Sara."}$j$::jsonb,$j${"value": "Ik heet Sara.", "accepted": ["Ik heet Sara.", "Ik heet Sara"]}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$presentarse$p$, $p$writing$p$]),
('5277453f-45b8-562b-a818-29be303f4ca9'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','writing','translation',$p$Traduce: Estoy bien, gracias.$p$,$j${"source": "Estoy bien, gracias."}$j$::jsonb,$j${"value": "Het gaat goed, dank je.", "accepted": ["Het gaat goed, dank je.", "Het gaat goed, dank je", "Het gaat goed dank je", "Goed, dank je.", "Goed, dank je", "Goed dank je"]}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$estado$p$, $p$writing$p$]),
('8d68ccc9-a90a-57a6-93ab-7d430805a8f4'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','writing','word_bank',$p$Ordena las fichas para decir 'Me llamo Tom'.$p$,$j${"tiles": ["Ik", "heet", "Tom", "ben", "jij"]}$j$::jsonb,$j${"value": "Ik heet Tom", "sequence": ["Ik", "heet", "Tom"]}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$presentarse$p$, $p$writing$p$]),
('793feb99-cb36-5684-92dc-40f46928e9b5'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','writing','reorder',$p$Ordena las palabras para formar '¿Cómo te llamas?'.$p$,$j${"tiles": ["heet", "Hoe", "je?"]}$j$::jsonb,$j${"value": "Hoe heet je?"}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$verbo_zijn$p$, $p$writing$p$]),
('22952ef5-55d1-5bef-b9f0-e2434f678618'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Hallo, goedemorgen!", "Dag, tot ziens!", "Doei, goedenavond!"], "say": "Hallo, goedemorgen!", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/22952ef5-55d1-5bef-b9f0-e2434f678618.mp3"}$j$::jsonb,$j${"value": "Hallo, goedemorgen!"}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$saludos$p$, $p$listening$p$]),
('fa871a95-fb2e-51f8-a35a-5f0ab1174750'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ik heet Anna.", "Ik ben Peter.", "Jij bent Sara."], "say": "Ik heet Anna.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/fa871a95-fb2e-51f8-a35a-5f0ab1174750.mp3"}$j$::jsonb,$j${"value": "Ik heet Anna."}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$presentarse$p$, $p$listening$p$]),
('b80ed6c9-b62e-56d7-a14f-75fd2b8f3818'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Jij bent Tom.", "Ik ben Tom.", "Hij is Tom."], "say": "Jij bent Tom.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/b80ed6c9-b62e-56d7-a14f-75fd2b8f3818.mp3"}$j$::jsonb,$j${"value": "Jij bent Tom."}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$verbo_zijn$p$, $p$listening$p$]),
('b1bfb333-15f4-5090-8166-2ccc5049965a'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Hoe gaat het?", "Hoe heet je?", "Waar kom je vandaan?"], "say": "Hoe gaat het?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/b1bfb333-15f4-5090-8166-2ccc5049965a.mp3"}$j$::jsonb,$j${"value": "Hoe gaat het?"}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$estado$p$, $p$listening$p$]),
('717eebbe-fb2c-51d9-acc6-981e93098f21'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Goed, dank je.", "Dag, tot ziens.", "Hallo, goedenavond."], "say": "Goed, dank je.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/717eebbe-fb2c-51d9-acc6-981e93098f21.mp3"}$j$::jsonb,$j${"value": "Goed, dank je."}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$estado$p$, $p$listening$p$]),
('69526bf7-4bb3-527f-ac49-f3f61848c984'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Hallo, goedemorgen!", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/69526bf7-4bb3-527f-ac49-f3f61848c984.mp3"}$j$::jsonb,$j${"expected": "Hallo, goedemorgen!"}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$saludos$p$, $p$speaking$p$]),
('4e8dcf0a-5fc7-50c7-8749-456c22873994'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Ik heet Anna.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/4e8dcf0a-5fc7-50c7-8749-456c22873994.mp3"}$j$::jsonb,$j${"expected": "Ik heet Anna."}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$presentarse$p$, $p$speaking$p$]),
('6e2843cd-196c-5886-81b7-18909a9d90de'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Hoe gaat het? Goed, dank je.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/6e2843cd-196c-5886-81b7-18909a9d90de.mp3"}$j$::jsonb,$j${"expected": "Hoe gaat het? Goed, dank je."}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$estado$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('8bbcf0a6-7f99-53ad-b519-cca46347e785','2522b4a3-37e5-54a3-a1e5-051ff48da501',1),
 ('8bbcf0a6-7f99-53ad-b519-cca46347e785','c9208976-cb92-5b7b-b2a2-9e59d20814d5',2),
 ('8bbcf0a6-7f99-53ad-b519-cca46347e785','190778c6-897a-5862-8418-c3d5cf5a9861',3),
 ('8bbcf0a6-7f99-53ad-b519-cca46347e785','8d5c3088-3d81-5b23-938c-ee6bf6f219fb',4),
 ('8bbcf0a6-7f99-53ad-b519-cca46347e785','22952ef5-55d1-5bef-b9f0-e2434f678618',5),
 ('8bbcf0a6-7f99-53ad-b519-cca46347e785','69526bf7-4bb3-527f-ac49-f3f61848c984',6),
 ('923ccca5-df27-507b-8d6c-ef5693c1f0c5','6a7d3bee-04a4-5fb7-9f15-dbc68d696f45',1),
 ('923ccca5-df27-507b-8d6c-ef5693c1f0c5','65d1d6f7-061b-522f-9c82-af767c06c3e9',2),
 ('923ccca5-df27-507b-8d6c-ef5693c1f0c5','32e3e163-2c6d-5748-a76a-22f161ac84e3',3),
 ('923ccca5-df27-507b-8d6c-ef5693c1f0c5','8d68ccc9-a90a-57a6-93ab-7d430805a8f4',4),
 ('923ccca5-df27-507b-8d6c-ef5693c1f0c5','fa871a95-fb2e-51f8-a35a-5f0ab1174750',5),
 ('923ccca5-df27-507b-8d6c-ef5693c1f0c5','4e8dcf0a-5fc7-50c7-8749-456c22873994',6),
 ('9d421955-9f09-52db-beb8-df6ebe0dde7a','979fb2de-0926-56bf-af78-65fc3dee5aa3',1),
 ('9d421955-9f09-52db-beb8-df6ebe0dde7a','793feb99-cb36-5684-92dc-40f46928e9b5',2),
 ('9d421955-9f09-52db-beb8-df6ebe0dde7a','b80ed6c9-b62e-56d7-a14f-75fd2b8f3818',3),
 ('e7a76120-079d-51e6-88b2-8f71e958f96b','2a277f2c-0ff4-5933-a7ef-b470cca296e6',1),
 ('e7a76120-079d-51e6-88b2-8f71e958f96b','5277453f-45b8-562b-a818-29be303f4ca9',2),
 ('e7a76120-079d-51e6-88b2-8f71e958f96b','b1bfb333-15f4-5090-8166-2ccc5049965a',3),
 ('e7a76120-079d-51e6-88b2-8f71e958f96b','717eebbe-fb2c-51d9-acc6-981e93098f21',4),
 ('e7a76120-079d-51e6-88b2-8f71e958f96b','6e2843cd-196c-5886-81b7-18909a9d90de',5),
 ('35726517-922d-5491-a751-16b786eaaeb1','2522b4a3-37e5-54a3-a1e5-051ff48da501',1),
 ('35726517-922d-5491-a751-16b786eaaeb1','c9208976-cb92-5b7b-b2a2-9e59d20814d5',2),
 ('35726517-922d-5491-a751-16b786eaaeb1','190778c6-897a-5862-8418-c3d5cf5a9861',3),
 ('35726517-922d-5491-a751-16b786eaaeb1','65d1d6f7-061b-522f-9c82-af767c06c3e9',4),
 ('35726517-922d-5491-a751-16b786eaaeb1','979fb2de-0926-56bf-af78-65fc3dee5aa3',5),
 ('35726517-922d-5491-a751-16b786eaaeb1','32e3e163-2c6d-5748-a76a-22f161ac84e3',6),
 ('35726517-922d-5491-a751-16b786eaaeb1','22952ef5-55d1-5bef-b9f0-e2434f678618',7),
 ('35726517-922d-5491-a751-16b786eaaeb1','fa871a95-fb2e-51f8-a35a-5f0ab1174750',8),
 ('35726517-922d-5491-a751-16b786eaaeb1','69526bf7-4bb3-527f-ac49-f3f61848c984',9),
 ('35726517-922d-5491-a751-16b786eaaeb1','4e8dcf0a-5fc7-50c7-8749-456c22873994',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('e0074218-92ad-5a4f-b9ce-eeb7cfaae9b9','20000000-0000-0000-0000-000000000006',$p$hallo$p$,$p$hola$p$,121,'interjeccion'),
 ('a3b6217c-a4f1-504d-a1c4-221d3419d050','20000000-0000-0000-0000-000000000006',$p$goedemorgen$p$,$p$buenos días$p$,122,'interjeccion'),
 ('27c4f06e-e2ab-57b8-9961-1b0e3d738c06','20000000-0000-0000-0000-000000000006',$p$goedenavond$p$,$p$buenas noches$p$,123,'interjeccion'),
 ('a623bd5c-ef49-5408-a771-6fd3df56ba12','20000000-0000-0000-0000-000000000006',$p$dag$p$,$p$hola / adiós$p$,124,'interjeccion'),
 ('5dd2a3b9-cc03-55cc-831d-61d0ffc12607','20000000-0000-0000-0000-000000000006',$p$doei$p$,$p$chau$p$,125,'interjeccion'),
 ('2d1c2e5d-58e6-5eb5-94f9-1f5f4266a26e','20000000-0000-0000-0000-000000000006',$p$tot ziens$p$,$p$hasta la vista$p$,126,'expresion'),
 ('2af15686-ec23-59c3-bf20-c22dd3a4fcbf','20000000-0000-0000-0000-000000000006',$p$ik$p$,$p$yo$p$,127,'pronombre'),
 ('a810a62c-a313-50c7-9987-cac4b58b317b','20000000-0000-0000-0000-000000000006',$p$jij$p$,$p$tú$p$,128,'pronombre'),
 ('7beaecc3-ce91-5c0c-be65-94607a7a9607','20000000-0000-0000-0000-000000000006',$p$heten$p$,$p$llamarse$p$,129,'verbo'),
 ('c414cce5-9fb7-5841-88dd-fbb36d41c1e3','20000000-0000-0000-0000-000000000006',$p$zijn$p$,$p$ser / estar$p$,130,'verbo'),
 ('bf4661a0-6973-561c-bee7-464be55f10d4','20000000-0000-0000-0000-000000000006',$p$ben$p$,$p$soy / estoy$p$,131,'verbo'),
 ('8f906663-76ff-50f2-b6b2-3988f63d0fe0','20000000-0000-0000-0000-000000000006',$p$bent$p$,$p$eres / estás$p$,132,'verbo'),
 ('17b49151-6c19-5ad7-b0b9-4c59eef29718','20000000-0000-0000-0000-000000000006',$p$is$p$,$p$es / está$p$,133,'verbo'),
 ('9977d5bd-cbca-56ac-940e-214c08509087','20000000-0000-0000-0000-000000000006',$p$hoe$p$,$p$cómo$p$,134,'adverbio'),
 ('7ed5cd21-cd81-517d-bbc1-5c1d6cc9b8e1','20000000-0000-0000-0000-000000000006',$p$goed$p$,$p$bien$p$,135,'adverbio'),
 ('8275297f-fb13-52e0-8ef8-72500867e8d5','20000000-0000-0000-0000-000000000006',$p$dank je$p$,$p$gracias$p$,136,'expresion')
on conflict (id) do nothing;

-- ── Unidad 2 (A1·nl): Números, edad y origen ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('7e9a3011-71c4-572c-90bb-10a63422f407','20000000-0000-0000-0000-000000000006','A1',2,$p$Números, edad y origen$p$,'#2C3E50','filter_9_plus')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('84dad2d4-60aa-5ba1-acb5-f0b6ee8f8a69','7e9a3011-71c4-572c-90bb-10a63422f407',1,$p$Números del 0 al 20$p$,$p$Números del 0 al 20$p$,'lesson',15),
 ('3ec17ec8-c871-547f-b243-90ce47c21a43','7e9a3011-71c4-572c-90bb-10a63422f407',2,$p$Decir tu edad$p$,$p$Decir tu edad$p$,'lesson',15),
 ('017cbd2a-17e0-58d3-8abc-fe4234f87a12','7e9a3011-71c4-572c-90bb-10a63422f407',3,$p$¿De dónde vienes?$p$,$p$¿De dónde vienes?$p$,'lesson',15),
 ('49ababb0-acdf-50f6-83f5-430e8584db2c','7e9a3011-71c4-572c-90bb-10a63422f407',4,$p$Nacionalidad y tener$p$,$p$Nacionalidad y tener$p$,'lesson',15),
 ('0987ce84-d901-56f7-ad59-24e1653573d4','7e9a3011-71c4-572c-90bb-10a63422f407',5,$p$🏁 Checkpoint Eenheid 2$p$,$p$Practica los números del 0 al 20, decir tu edad con zijn, tu origen y nacionalidad, y el verbo hebben.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('ebc7397a-6b0c-5752-a706-8e131763b8c1','20000000-0000-0000-0000-000000000006','checkpoint','A1','7e9a3011-71c4-572c-90bb-10a63422f407',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('3e0d7e0e-6cf2-52dc-a931-f4975a3a04b2'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','reading','match',$p$Une cada número neerlandés con su cifra.$p$,$j${"pairs": [{"en": "een", "es": "1"}, {"en": "drie", "es": "3"}, {"en": "vijf", "es": "5"}]}$j$::jsonb,$j${"pairs": [["een", "1"], ["drie", "3"], ["vijf", "5"]]}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$getallen$p$, $p$reading$p$]),
('e9723af0-dfee-5732-b3d0-c807f3eb1be6'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','reading','match',$p$Une cada número neerlandés con su cifra.$p$,$j${"pairs": [{"en": "nul", "es": "0"}, {"en": "tien", "es": "10"}, {"en": "twintig", "es": "20"}]}$j$::jsonb,$j${"pairs": [["nul", "0"], ["tien", "10"], ["twintig", "20"]]}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$getallen$p$, $p$reading$p$]),
('9f9fb616-e494-53a4-9016-529b2b05138e'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','reading','multiple_choice',$p$¿Cómo se escribe el número 4 en neerlandés?$p$,$j${"options": ["vier", "twee", "tien"]}$j$::jsonb,$j${"value": "vier"}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$getallen$p$, $p$reading$p$]),
('49c73039-5fae-56bf-9bf6-e316077ce7e5'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','reading','multiple_choice',$p$Elige la forma correcta de decir 'Tengo veinte años'.$p$,$j${"options": ["Ik ben twintig jaar oud", "Ik heb twintig jaar", "Ik ben twintig jaar heb"]}$j$::jsonb,$j${"value": "Ik ben twintig jaar oud"}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$leeftijd$p$, $p$reading$p$]),
('e44fae8b-4462-59f5-bcd2-57e29c09e71a'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','reading','multiple_choice',$p$'Waar kom je vandaan?' significa:$p$,$j${"options": ["¿De dónde vienes?", "¿Cuántos años tienes?", "¿Cómo te llamas?"]}$j$::jsonb,$j${"value": "¿De dónde vienes?"}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$herkomst$p$, $p$reading$p$]),
('9f8f3fdf-6db4-5b0e-96d2-3a30cf7b227d'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','reading','multiple_choice',$p$Elige la forma correcta de 'tener' para 'jij' (tú).$p$,$j${"options": ["jij hebt", "jij heb", "jij bent"]}$j$::jsonb,$j${"value": "jij hebt"}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$hebben$p$, $p$reading$p$]),
('69670138-9ef2-538d-a1da-ccad64271d95'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','writing','cloze',$p$Completa con el verbo correcto: 'Tengo diez años.'$p$,$j${"text": "Ik ___ tien jaar oud."}$j$::jsonb,$j${"value": "ben", "accepted": ["ben"]}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$leeftijd$p$, $p$writing$p$]),
('b54c2f77-def7-5d7c-b858-5707f1145f1a'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','writing','cloze',$p$Completa: 'Vengo de España.'$p$,$j${"text": "Ik kom ___ Spanje."}$j$::jsonb,$j${"value": "uit", "accepted": ["uit"]}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$herkomst$p$, $p$writing$p$]),
('2baf44d0-9514-5b1d-a4be-5ec4bc9b7d46'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','writing','translation',$p$Traduce: Tengo veinte años.$p$,$j${"source": "Tengo veinte años."}$j$::jsonb,$j${"value": "Ik ben twintig jaar oud.", "accepted": ["Ik ben twintig jaar oud.", "Ik ben twintig jaar oud", "Ik ben twintig jaar", "Ik ben twintig jaar."]}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$leeftijd$p$, $p$writing$p$]),
('604cea36-7e0b-5a1c-8160-d89a91d74381'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','writing','translation',$p$Traduce: Vengo de Perú.$p$,$j${"source": "Vengo de Perú."}$j$::jsonb,$j${"value": "Ik kom uit Peru.", "accepted": ["Ik kom uit Peru.", "Ik kom uit Peru", "Ik kom uit Perú.", "Ik kom uit Perú"]}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$herkomst$p$, $p$writing$p$]),
('83d07246-fa0d-50a3-82bf-db66c726381a'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','writing','word_bank',$p$Ordena las fichas para decir 'Soy española'.$p$,$j${"tiles": ["Ik", "ben", "Spaanse", "heb", "uit"]}$j$::jsonb,$j${"value": "Ik ben Spaanse", "sequence": ["Ik", "ben", "Spaanse"]}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$hebben$p$, $p$writing$p$]),
('55ea2e79-e32e-5663-9594-d644b7675495'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','writing','reorder',$p$Ordena las palabras para formar '¿De dónde vienes?'.$p$,$j${"tiles": ["kom", "Waar", "vandaan?", "je"]}$j$::jsonb,$j${"value": "Waar kom je vandaan?"}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$herkomst$p$, $p$writing$p$]),
('993d32d6-a9be-5848-b72a-70275d5efe0a'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["een, twee, drie", "vier, vijf, zes", "tien, elf, twaalf"], "say": "een, twee, drie", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/993d32d6-a9be-5848-b72a-70275d5efe0a.mp3"}$j$::jsonb,$j${"value": "een, twee, drie"}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$getallen$p$, $p$listening$p$]),
('057adb08-2b0e-5883-8f6f-2da63361aa09'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ik ben twintig jaar oud.", "Ik ben tien jaar oud.", "Ik heb twintig jaar."], "say": "Ik ben twintig jaar oud.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/057adb08-2b0e-5883-8f6f-2da63361aa09.mp3"}$j$::jsonb,$j${"value": "Ik ben twintig jaar oud."}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$leeftijd$p$, $p$listening$p$]),
('82349993-1e72-5d95-99e6-f2c1b306875a'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ik kom uit Spanje.", "Ik kom uit Peru.", "Ik ben Spaans."], "say": "Ik kom uit Spanje.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/82349993-1e72-5d95-99e6-f2c1b306875a.mp3"}$j$::jsonb,$j${"value": "Ik kom uit Spanje."}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$herkomst$p$, $p$listening$p$]),
('0054bb30-b2e7-506d-b56c-14b8f29dcba0'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Hoe oud ben je?", "Hoe heet je?", "Waar kom je vandaan?"], "say": "Hoe oud ben je?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/0054bb30-b2e7-506d-b56c-14b8f29dcba0.mp3"}$j$::jsonb,$j${"value": "Hoe oud ben je?"}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$leeftijd$p$, $p$listening$p$]),
('a663d6b2-2a47-5f7d-b220-54733eddb2b6'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Ik ben twintig jaar oud.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/a663d6b2-2a47-5f7d-b220-54733eddb2b6.mp3"}$j$::jsonb,$j${"expected": "Ik ben twintig jaar oud."}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$leeftijd$p$, $p$speaking$p$]),
('e62f927d-e3b2-502a-be7d-7b8c0ff1c1d4'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Ik kom uit Spanje.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/e62f927d-e3b2-502a-be7d-7b8c0ff1c1d4.mp3"}$j$::jsonb,$j${"expected": "Ik kom uit Spanje."}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$herkomst$p$, $p$speaking$p$]),
('29ddf9e9-274d-539f-9217-9372456733d8'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Ik ben Spaans.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/29ddf9e9-274d-539f-9217-9372456733d8.mp3"}$j$::jsonb,$j${"expected": "Ik ben Spaans."}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$hebben$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('84dad2d4-60aa-5ba1-acb5-f0b6ee8f8a69','3e0d7e0e-6cf2-52dc-a931-f4975a3a04b2',1),
 ('84dad2d4-60aa-5ba1-acb5-f0b6ee8f8a69','e9723af0-dfee-5732-b3d0-c807f3eb1be6',2),
 ('84dad2d4-60aa-5ba1-acb5-f0b6ee8f8a69','9f9fb616-e494-53a4-9016-529b2b05138e',3),
 ('84dad2d4-60aa-5ba1-acb5-f0b6ee8f8a69','993d32d6-a9be-5848-b72a-70275d5efe0a',4),
 ('3ec17ec8-c871-547f-b243-90ce47c21a43','49c73039-5fae-56bf-9bf6-e316077ce7e5',1),
 ('3ec17ec8-c871-547f-b243-90ce47c21a43','69670138-9ef2-538d-a1da-ccad64271d95',2),
 ('3ec17ec8-c871-547f-b243-90ce47c21a43','2baf44d0-9514-5b1d-a4be-5ec4bc9b7d46',3),
 ('3ec17ec8-c871-547f-b243-90ce47c21a43','057adb08-2b0e-5883-8f6f-2da63361aa09',4),
 ('3ec17ec8-c871-547f-b243-90ce47c21a43','0054bb30-b2e7-506d-b56c-14b8f29dcba0',5),
 ('3ec17ec8-c871-547f-b243-90ce47c21a43','a663d6b2-2a47-5f7d-b220-54733eddb2b6',6),
 ('017cbd2a-17e0-58d3-8abc-fe4234f87a12','e44fae8b-4462-59f5-bcd2-57e29c09e71a',1),
 ('017cbd2a-17e0-58d3-8abc-fe4234f87a12','b54c2f77-def7-5d7c-b858-5707f1145f1a',2),
 ('017cbd2a-17e0-58d3-8abc-fe4234f87a12','604cea36-7e0b-5a1c-8160-d89a91d74381',3),
 ('017cbd2a-17e0-58d3-8abc-fe4234f87a12','55ea2e79-e32e-5663-9594-d644b7675495',4),
 ('017cbd2a-17e0-58d3-8abc-fe4234f87a12','82349993-1e72-5d95-99e6-f2c1b306875a',5),
 ('017cbd2a-17e0-58d3-8abc-fe4234f87a12','e62f927d-e3b2-502a-be7d-7b8c0ff1c1d4',6),
 ('49ababb0-acdf-50f6-83f5-430e8584db2c','9f8f3fdf-6db4-5b0e-96d2-3a30cf7b227d',1),
 ('49ababb0-acdf-50f6-83f5-430e8584db2c','83d07246-fa0d-50a3-82bf-db66c726381a',2),
 ('49ababb0-acdf-50f6-83f5-430e8584db2c','29ddf9e9-274d-539f-9217-9372456733d8',3),
 ('0987ce84-d901-56f7-ad59-24e1653573d4','3e0d7e0e-6cf2-52dc-a931-f4975a3a04b2',1),
 ('0987ce84-d901-56f7-ad59-24e1653573d4','e9723af0-dfee-5732-b3d0-c807f3eb1be6',2),
 ('0987ce84-d901-56f7-ad59-24e1653573d4','9f9fb616-e494-53a4-9016-529b2b05138e',3),
 ('0987ce84-d901-56f7-ad59-24e1653573d4','69670138-9ef2-538d-a1da-ccad64271d95',4),
 ('0987ce84-d901-56f7-ad59-24e1653573d4','b54c2f77-def7-5d7c-b858-5707f1145f1a',5),
 ('0987ce84-d901-56f7-ad59-24e1653573d4','2baf44d0-9514-5b1d-a4be-5ec4bc9b7d46',6),
 ('0987ce84-d901-56f7-ad59-24e1653573d4','993d32d6-a9be-5848-b72a-70275d5efe0a',7),
 ('0987ce84-d901-56f7-ad59-24e1653573d4','057adb08-2b0e-5883-8f6f-2da63361aa09',8),
 ('0987ce84-d901-56f7-ad59-24e1653573d4','a663d6b2-2a47-5f7d-b220-54733eddb2b6',9),
 ('0987ce84-d901-56f7-ad59-24e1653573d4','e62f927d-e3b2-502a-be7d-7b8c0ff1c1d4',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('77e54ae5-d0a5-5c7e-89f1-8ad8a5685efc','20000000-0000-0000-0000-000000000006',$p$nul$p$,$p$cero$p$,141,'numero'),
 ('9ce90c91-0a6a-5d7b-b223-9a214252059d','20000000-0000-0000-0000-000000000006',$p$een$p$,$p$uno$p$,142,'numero'),
 ('928ca12b-182c-5866-baaa-b06a23952508','20000000-0000-0000-0000-000000000006',$p$twee$p$,$p$dos$p$,143,'numero'),
 ('3e01b936-2afd-55cf-bc7a-5a3dc850c5bf','20000000-0000-0000-0000-000000000006',$p$drie$p$,$p$tres$p$,144,'numero'),
 ('e7bc8176-34cc-5dd7-ab4b-4ffe5b946a50','20000000-0000-0000-0000-000000000006',$p$vier$p$,$p$cuatro$p$,145,'numero'),
 ('8be52942-359e-5dc5-96ab-e03a42d84b1b','20000000-0000-0000-0000-000000000006',$p$vijf$p$,$p$cinco$p$,146,'numero'),
 ('59a35d1d-4811-5f97-a203-86ad1cde7cd9','20000000-0000-0000-0000-000000000006',$p$tien$p$,$p$diez$p$,147,'numero'),
 ('16a592c6-756f-5290-8eb3-82cabaaaeea7','20000000-0000-0000-0000-000000000006',$p$twintig$p$,$p$veinte$p$,148,'numero'),
 ('367f8244-eecc-58b8-8584-bfc915c9028f','20000000-0000-0000-0000-000000000006',$p$jaar$p$,$p$año$p$,149,'sustantivo'),
 ('9f9b5f79-5e62-558c-afcb-7a18c71ce4d3','20000000-0000-0000-0000-000000000006',$p$oud$p$,$p$viejo / de edad$p$,150,'adjetivo'),
 ('736ee14a-585c-5d20-9474-4f976cc5d683','20000000-0000-0000-0000-000000000006',$p$hoe oud$p$,$p$qué edad$p$,151,'expresion'),
 ('ce7cd9b0-1818-5a6a-b2d7-4835f2ef942e','20000000-0000-0000-0000-000000000006',$p$komen$p$,$p$venir$p$,152,'verbo'),
 ('119bd299-26aa-556f-a18d-7c8ecf6bd1ca','20000000-0000-0000-0000-000000000006',$p$vandaan$p$,$p$de dónde (procedencia)$p$,153,'adverbio'),
 ('1304d2f2-97cd-5d54-8a5a-75e59fb0a1be','20000000-0000-0000-0000-000000000006',$p$uit$p$,$p$de / desde$p$,154,'preposicion'),
 ('c2c1bc9c-ae4c-5c5e-9492-e8710cc52a7e','20000000-0000-0000-0000-000000000006',$p$Spaans$p$,$p$español (nacionalidad)$p$,155,'adjetivo'),
 ('79cf4709-a0a1-5e83-be05-078ea4642991','20000000-0000-0000-0000-000000000006',$p$hebben$p$,$p$tener$p$,156,'verbo')
on conflict (id) do nothing;

-- ── Unidad 3 (A1·nl): La familia ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('283831fa-f4fd-50fa-954a-0bbde45cdcfd','20000000-0000-0000-0000-000000000006','A1',3,$p$La familia$p$,'#8E44AD','family_restroom')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('3f1c543e-bb04-5186-8b32-d52775cf2802','283831fa-f4fd-50fa-954a-0bbde45cdcfd',1,$p$Padres y hermanos$p$,$p$Padres y hermanos$p$,'lesson',15),
 ('b81efefb-1bba-5f42-9b1f-af130e688d6a','283831fa-f4fd-50fa-954a-0bbde45cdcfd',2,$p$Este es… / Estos son…$p$,$p$Este es… / Estos son…$p$,'lesson',15),
 ('fc9422ad-8ac8-50ad-8da5-f30d7a607052','283831fa-f4fd-50fa-954a-0bbde45cdcfd',3,$p$Mi familia, tu familia$p$,$p$Mi familia, tu familia$p$,'lesson',15),
 ('b91f4b51-302d-5766-a167-20e15c9346f2','283831fa-f4fd-50fa-954a-0bbde45cdcfd',4,$p$Hermanito y hermanita$p$,$p$Hermanito y hermanita$p$,'lesson',15),
 ('8f3e86db-1494-5ce6-bfa8-f1ab84408231','283831fa-f4fd-50fa-954a-0bbde45cdcfd',5,$p$🏁 Checkpoint Eenheid 3$p$,$p$Presenta a tu familia en neerlandés con de/het, los posesivos mijn/jouw y las frases Dit is… / Dat zijn….$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('2922c7c1-2427-5942-9e84-5cd1a8d8abfa','20000000-0000-0000-0000-000000000006','checkpoint','A1','283831fa-f4fd-50fa-954a-0bbde45cdcfd',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('d11cd517-c1ed-5587-9319-7fe2f62ba861'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','reading','match',$p$Une cada palabra neerlandesa con su traducción.$p$,$j${"pairs": [{"en": "de moeder", "es": "la madre"}, {"en": "de vader", "es": "el padre"}, {"en": "de broer", "es": "el hermano"}]}$j$::jsonb,$j${"pairs": [["de moeder", "la madre"], ["de vader", "el padre"], ["de broer", "el hermano"]]}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$familia_basica$p$, $p$reading$p$]),
('47276ed0-5058-53c6-b85d-c74cf74676be'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','reading','match',$p$Une cada palabra neerlandesa con su traducción.$p$,$j${"pairs": [{"en": "de zus", "es": "la hermana"}, {"en": "de oma", "es": "la abuela"}, {"en": "de opa", "es": "el abuelo"}]}$j$::jsonb,$j${"pairs": [["de zus", "la hermana"], ["de oma", "la abuela"], ["de opa", "el abuelo"]]}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$familia_grupo$p$, $p$reading$p$]),
('7ad9aa79-3a33-5009-9cee-124d2326afca'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','reading','multiple_choice',$p$¿Qué artículo lleva la palabra 'kind' (niño)?$p$,$j${"options": ["het kind", "de kind", "een de kind"]}$j$::jsonb,$j${"value": "het kind"}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$articulo_het$p$, $p$reading$p$]),
('8d649b4d-cc4e-5be9-af06-100efec117fd'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','reading','multiple_choice',$p$Completa: '___ mijn moeder' (Esta es mi madre).$p$,$j${"options": ["Dit is", "Dat zijn", "Dit zijn"]}$j$::jsonb,$j${"value": "Dit is"}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$dit_dat$p$, $p$reading$p$]),
('c93abbb3-553d-58cc-a295-9af608e347f7'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','reading','multiple_choice',$p$¿Cómo se dice 'mi padre' en neerlandés?$p$,$j${"options": ["mijn vader", "jouw vader", "mij vader"]}$j$::jsonb,$j${"value": "mijn vader"}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$posesivo_mijn$p$, $p$reading$p$]),
('38360eac-8d42-5223-b64a-6b6d8f13d63b'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','reading','multiple_choice',$p$¿Cómo se dice 'la hermanita' en neerlandés?$p$,$j${"options": ["het zusje", "de zusje", "het zus"]}$j$::jsonb,$j${"value": "het zusje"}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$diminutivo$p$, $p$reading$p$]),
('9f4777e1-be95-50f3-a8e3-2bdda3f4d17a'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','writing','cloze',$p$Completa: 'Mi madre' en neerlandés.$p$,$j${"text": "Mijn ___ ."}$j$::jsonb,$j${"value": "moeder", "accepted": ["moeder"]}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$familia_basica$p$, $p$writing$p$]),
('b19dcfff-e3f9-53e6-b4b1-54f73199f702'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','writing','cloze',$p$Completa con 'Estos son' (plural): '___ mijn ouders'.$p$,$j${"text": "___ mijn ouders."}$j$::jsonb,$j${"value": "Dat zijn", "accepted": ["Dat zijn", "dat zijn"]}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$dat_zijn$p$, $p$writing$p$]),
('7d77d17b-b7a3-5d36-bb4d-0ee4b3ac2498'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','writing','translation',$p$Traduce: Este es mi hermano.$p$,$j${"source": "Este es mi hermano."}$j$::jsonb,$j${"value": "Dit is mijn broer.", "accepted": ["Dit is mijn broer.", "Dit is mijn broer"]}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$dit_is$p$, $p$writing$p$]),
('d3fbabeb-89b6-52e2-b287-43fa7457c961'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','writing','translation',$p$Traduce: Tu abuela.$p$,$j${"source": "Tu abuela."}$j$::jsonb,$j${"value": "Jouw oma.", "accepted": ["Jouw oma.", "Jouw oma", "jouw oma"]}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$posesivo_jouw$p$, $p$writing$p$]),
('e8eeac86-fd92-5278-93f2-a238fbae4092'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','writing','word_bank',$p$Ordena las fichas para formar: 'Este es mi hermanito.'$p$,$j${"tiles": ["Dit", "is", "mijn", "broertje", "zusje"]}$j$::jsonb,$j${"value": "Dit is mijn broertje", "sequence": ["Dit", "is", "mijn", "broertje"]}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$diminutivo$p$, $p$writing$p$]),
('2e0be409-1ab6-54e4-b6e3-1996a4088c97'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','writing','reorder',$p$Ordena las palabras para formar: 'Estos son mis padres.'$p$,$j${"tiles": ["ouders", "Dat", "mijn", "zijn"]}$j$::jsonb,$j${"value": "Dat zijn mijn ouders"}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$dat_zijn$p$, $p$writing$p$]),
('21eed408-9097-5037-81c7-2125d77d5c8a'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Dit is mijn moeder.", "Dit is mijn vader.", "Dat zijn mijn ouders."], "say": "Dit is mijn moeder.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/21eed408-9097-5037-81c7-2125d77d5c8a.mp3"}$j$::jsonb,$j${"value": "Dit is mijn moeder."}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$familia_basica$p$, $p$listening$p$]),
('05901a5b-6065-55e2-8013-4a48fa350a3c'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Dat zijn mijn kinderen.", "Dit is mijn kind.", "Dit is mijn zus."], "say": "Dat zijn mijn kinderen.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/05901a5b-6065-55e2-8013-4a48fa350a3c.mp3"}$j$::jsonb,$j${"value": "Dat zijn mijn kinderen."}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$dit_dat$p$, $p$listening$p$]),
('c5537597-2d6d-5b12-b9ae-fb05d6d315e6'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Mijn opa en mijn oma.", "Mijn broer en mijn zus.", "Jouw vader en jouw moeder."], "say": "Mijn opa en mijn oma.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/c5537597-2d6d-5b12-b9ae-fb05d6d315e6.mp3"}$j$::jsonb,$j${"value": "Mijn opa en mijn oma."}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$abuelos$p$, $p$listening$p$]),
('28cb0ebf-857d-5b1a-aefd-7af165a61c23'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ik heb een broertje en een zusje.", "Ik heb een broer en een zus.", "Dit is mijn familie."], "say": "Ik heb een broertje en een zusje.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/28cb0ebf-857d-5b1a-aefd-7af165a61c23.mp3"}$j$::jsonb,$j${"value": "Ik heb een broertje en een zusje."}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$diminutivo$p$, $p$listening$p$]),
('eb1089bb-6282-5944-9ea7-b89baf572cc2'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Dit is mijn vader.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/eb1089bb-6282-5944-9ea7-b89baf572cc2.mp3"}$j$::jsonb,$j${"expected": "Dit is mijn vader."}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$familia_basica$p$, $p$speaking$p$]),
('75f9814b-d4b3-53cd-8950-fe7b5d7dffa2'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Dat zijn mijn ouders.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/75f9814b-d4b3-53cd-8950-fe7b5d7dffa2.mp3"}$j$::jsonb,$j${"expected": "Dat zijn mijn ouders."}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$posesivo$p$, $p$speaking$p$]),
('a91b7644-2f0f-5f09-b56f-229c50939112'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Dit is mijn familie.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/a91b7644-2f0f-5f09-b56f-229c50939112.mp3"}$j$::jsonb,$j${"expected": "Dit is mijn familie."}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$familia_completa$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('3f1c543e-bb04-5186-8b32-d52775cf2802','d11cd517-c1ed-5587-9319-7fe2f62ba861',1),
 ('3f1c543e-bb04-5186-8b32-d52775cf2802','7ad9aa79-3a33-5009-9cee-124d2326afca',2),
 ('3f1c543e-bb04-5186-8b32-d52775cf2802','9f4777e1-be95-50f3-a8e3-2bdda3f4d17a',3),
 ('3f1c543e-bb04-5186-8b32-d52775cf2802','21eed408-9097-5037-81c7-2125d77d5c8a',4),
 ('3f1c543e-bb04-5186-8b32-d52775cf2802','eb1089bb-6282-5944-9ea7-b89baf572cc2',5),
 ('b81efefb-1bba-5f42-9b1f-af130e688d6a','8d649b4d-cc4e-5be9-af06-100efec117fd',1),
 ('b81efefb-1bba-5f42-9b1f-af130e688d6a','b19dcfff-e3f9-53e6-b4b1-54f73199f702',2),
 ('b81efefb-1bba-5f42-9b1f-af130e688d6a','7d77d17b-b7a3-5d36-bb4d-0ee4b3ac2498',3),
 ('b81efefb-1bba-5f42-9b1f-af130e688d6a','2e0be409-1ab6-54e4-b6e3-1996a4088c97',4),
 ('b81efefb-1bba-5f42-9b1f-af130e688d6a','05901a5b-6065-55e2-8013-4a48fa350a3c',5),
 ('fc9422ad-8ac8-50ad-8da5-f30d7a607052','47276ed0-5058-53c6-b85d-c74cf74676be',1),
 ('fc9422ad-8ac8-50ad-8da5-f30d7a607052','c93abbb3-553d-58cc-a295-9af608e347f7',2),
 ('fc9422ad-8ac8-50ad-8da5-f30d7a607052','d3fbabeb-89b6-52e2-b287-43fa7457c961',3),
 ('fc9422ad-8ac8-50ad-8da5-f30d7a607052','c5537597-2d6d-5b12-b9ae-fb05d6d315e6',4),
 ('fc9422ad-8ac8-50ad-8da5-f30d7a607052','75f9814b-d4b3-53cd-8950-fe7b5d7dffa2',5),
 ('b91f4b51-302d-5766-a167-20e15c9346f2','38360eac-8d42-5223-b64a-6b6d8f13d63b',1),
 ('b91f4b51-302d-5766-a167-20e15c9346f2','e8eeac86-fd92-5278-93f2-a238fbae4092',2),
 ('b91f4b51-302d-5766-a167-20e15c9346f2','28cb0ebf-857d-5b1a-aefd-7af165a61c23',3),
 ('b91f4b51-302d-5766-a167-20e15c9346f2','a91b7644-2f0f-5f09-b56f-229c50939112',4),
 ('8f3e86db-1494-5ce6-bfa8-f1ab84408231','d11cd517-c1ed-5587-9319-7fe2f62ba861',1),
 ('8f3e86db-1494-5ce6-bfa8-f1ab84408231','47276ed0-5058-53c6-b85d-c74cf74676be',2),
 ('8f3e86db-1494-5ce6-bfa8-f1ab84408231','7ad9aa79-3a33-5009-9cee-124d2326afca',3),
 ('8f3e86db-1494-5ce6-bfa8-f1ab84408231','9f4777e1-be95-50f3-a8e3-2bdda3f4d17a',4),
 ('8f3e86db-1494-5ce6-bfa8-f1ab84408231','b19dcfff-e3f9-53e6-b4b1-54f73199f702',5),
 ('8f3e86db-1494-5ce6-bfa8-f1ab84408231','7d77d17b-b7a3-5d36-bb4d-0ee4b3ac2498',6),
 ('8f3e86db-1494-5ce6-bfa8-f1ab84408231','21eed408-9097-5037-81c7-2125d77d5c8a',7),
 ('8f3e86db-1494-5ce6-bfa8-f1ab84408231','05901a5b-6065-55e2-8013-4a48fa350a3c',8),
 ('8f3e86db-1494-5ce6-bfa8-f1ab84408231','eb1089bb-6282-5944-9ea7-b89baf572cc2',9),
 ('8f3e86db-1494-5ce6-bfa8-f1ab84408231','75f9814b-d4b3-53cd-8950-fe7b5d7dffa2',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('76ae9d3e-d297-5a40-af35-240b8808684b','20000000-0000-0000-0000-000000000006',$p$de moeder$p$,$p$la madre$p$,161,'sustantivo'),
 ('ee43cc12-725b-5354-81f8-787bf480fb7b','20000000-0000-0000-0000-000000000006',$p$de vader$p$,$p$el padre$p$,162,'sustantivo'),
 ('1112bd5e-e9d1-5f4b-9104-f5fb321d43e0','20000000-0000-0000-0000-000000000006',$p$de ouders$p$,$p$los padres$p$,163,'sustantivo'),
 ('44a9e8f9-f665-505f-835f-a5869f2cd4da','20000000-0000-0000-0000-000000000006',$p$de broer$p$,$p$el hermano$p$,164,'sustantivo'),
 ('d42f95de-2c84-50dc-9250-db7d14019f5a','20000000-0000-0000-0000-000000000006',$p$de zus$p$,$p$la hermana$p$,165,'sustantivo'),
 ('97bbd6d4-0aef-5d8b-bd02-6b7f171ed7fa','20000000-0000-0000-0000-000000000006',$p$het kind$p$,$p$el niño / la criatura$p$,166,'sustantivo'),
 ('97f4e460-d923-51b6-aa2e-e0d11493e13b','20000000-0000-0000-0000-000000000006',$p$de familie$p$,$p$la familia$p$,167,'sustantivo'),
 ('9d344f5e-47a5-55d4-8193-0599dade328f','20000000-0000-0000-0000-000000000006',$p$de oma$p$,$p$la abuela$p$,168,'sustantivo'),
 ('b51c940a-10db-50b3-91e4-3c52d357b14d','20000000-0000-0000-0000-000000000006',$p$de opa$p$,$p$el abuelo$p$,169,'sustantivo'),
 ('94cf202e-235a-5d03-accc-19945ba3be8d','20000000-0000-0000-0000-000000000006',$p$het broertje$p$,$p$el hermanito$p$,170,'sustantivo'),
 ('8275d26c-25ee-5939-8156-7eb68c8814e9','20000000-0000-0000-0000-000000000006',$p$het zusje$p$,$p$la hermanita$p$,171,'sustantivo'),
 ('28cca64f-220e-562d-b203-de5e74ca116c','20000000-0000-0000-0000-000000000006',$p$mijn$p$,$p$mi$p$,172,'pronombre'),
 ('a92e30dc-f8bd-500c-9d87-0841e2b79ee5','20000000-0000-0000-0000-000000000006',$p$jouw$p$,$p$tu$p$,173,'pronombre'),
 ('9d81cd81-924f-59eb-8336-c7483acd2ea6','20000000-0000-0000-0000-000000000006',$p$Dit is$p$,$p$Este/Esta es$p$,174,'expresion'),
 ('9e7243e5-8a07-52ba-a0a4-e800c09da901','20000000-0000-0000-0000-000000000006',$p$Dat zijn$p$,$p$Estos/Esas son$p$,175,'expresion'),
 ('4a6380df-9410-5199-9c10-c3df4cc322af','20000000-0000-0000-0000-000000000006',$p$de kinderen$p$,$p$los niños$p$,176,'sustantivo')
on conflict (id) do nothing;

-- ── Unidad 4 (A1·nl): Comida y en el café ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('e64ca99f-816f-5e57-8c9f-6e2195590a95','20000000-0000-0000-0000-000000000006','A1',4,$p$Comida y en el café$p$,'#E67E22','restaurant')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('1631a90b-eec4-5107-885a-f89c84bc04b9','e64ca99f-816f-5e57-8c9f-6e2195590a95',1,$p$Comida y bebida$p$,$p$Comida y bebida$p$,'lesson',15),
 ('10941fe9-7943-5a8b-a9a1-079afb1a4c3e','e64ca99f-816f-5e57-8c9f-6e2195590a95',2,$p$Pedir en el café$p$,$p$Pedir en el café$p$,'lesson',15),
 ('54f7a9cf-023f-5b61-b0be-5ae854c2205a','e64ca99f-816f-5e57-8c9f-6e2195590a95',3,$p$Por favor y gracias$p$,$p$Por favor y gracias$p$,'lesson',15),
 ('bb7ec32a-d3c9-5246-9931-e409a10eecfe','e64ca99f-816f-5e57-8c9f-6e2195590a95',4,$p$¿Cuánto cuesta?$p$,$p$¿Cuánto cuesta?$p$,'lesson',15),
 ('6362219d-6dc6-516a-95f1-3ef01b11be0a','e64ca99f-816f-5e57-8c9f-6e2195590a95',5,$p$🏁 Checkpoint Eenheid 4$p$,$p$Pide comida y bebida en un café con Ik wil graag…, usa de/het correcto y pregunta el precio con Wat kost het?.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('af23fa6e-a98c-51e5-b943-8d0471232e36','20000000-0000-0000-0000-000000000006','checkpoint','A1','e64ca99f-816f-5e57-8c9f-6e2195590a95',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('8c154c8d-53db-5269-b83a-c23233a235bc'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','reading','match',$p$Une cada palabra neerlandesa con su traducción.$p$,$j${"pairs": [{"en": "het brood", "es": "el pan"}, {"en": "de koffie", "es": "el café"}, {"en": "de melk", "es": "la leche"}]}$j$::jsonb,$j${"pairs": [["het brood", "el pan"], ["de koffie", "el café"], ["de melk", "la leche"]]}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$comida_bebida$p$, $p$reading$p$]),
('ae271040-456a-57bd-b70d-394634884f21'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','reading','match',$p$Une cada palabra neerlandesa con su traducción.$p$,$j${"pairs": [{"en": "de appel", "es": "la manzana"}, {"en": "het sap", "es": "el zumo"}, {"en": "de taart", "es": "la tarta"}]}$j$::jsonb,$j${"pairs": [["de appel", "la manzana"], ["het sap", "el zumo"], ["de taart", "la tarta"]]}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$comida_bebida$p$, $p$reading$p$]),
('f128bddf-13d5-5812-a971-d17db8c13f7b'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','reading','multiple_choice',$p$¿Qué artículo lleva la palabra 'water' (agua)?$p$,$j${"options": ["het water", "de water", "een de water"]}$j$::jsonb,$j${"value": "het water"}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$articulo_het$p$, $p$reading$p$]),
('bb7a94f1-8c95-53ae-b65d-108a7a903351'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','reading','multiple_choice',$p$¿Cómo pides un café educadamente en el café?$p$,$j${"options": ["Ik wil graag een koffie.", "Ik ben een koffie.", "Ik heb graag koffie euro."]}$j$::jsonb,$j${"value": "Ik wil graag een koffie."}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$pedir$p$, $p$reading$p$]),
('0879e2b7-70ad-551d-a4ff-0b842581bbc5'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','reading','multiple_choice',$p$¿Qué significa 'dank u wel'?$p$,$j${"options": ["muchas gracias", "por favor", "buenos días"]}$j$::jsonb,$j${"value": "muchas gracias"}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$cortesia$p$, $p$reading$p$]),
('c19c55d5-406c-56db-be28-217412d63d84'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','reading','multiple_choice',$p$¿Cómo preguntas '¿Cuánto cuesta?' en neerlandés?$p$,$j${"options": ["Wat kost het?", "Wat is het?", "Wat heb het?"]}$j$::jsonb,$j${"value": "Wat kost het?"}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$precio$p$, $p$reading$p$]),
('3214ab60-8d14-52d7-a980-cdc810ae2652'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','writing','cloze',$p$Completa con el artículo correcto: '___ appel' (la manzana).$p$,$j${"text": "___ appel"}$j$::jsonb,$j${"value": "de", "accepted": ["de"]}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$articulo_de$p$, $p$writing$p$]),
('61bd0f1d-64c8-5bcc-9162-8c8123851969'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','writing','cloze',$p$Completa: 'Son cinco euros' → 'Dat is vijf ___ .'$p$,$j${"text": "Dat is vijf ___ ."}$j$::jsonb,$j${"value": "euro", "accepted": ["euro"]}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$precio$p$, $p$writing$p$]),
('fbfa4280-f729-56f8-abc9-7658c2abdfb7'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','writing','translation',$p$Traduce: Quisiera un té.$p$,$j${"source": "Quisiera un té."}$j$::jsonb,$j${"value": "Ik wil graag een thee.", "accepted": ["Ik wil graag een thee.", "Ik wil graag een thee"]}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$pedir$p$, $p$writing$p$]),
('da64e636-efb8-563e-ba4a-800789dc9df1'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','writing','translation',$p$Traduce: Un agua, por favor.$p$,$j${"source": "Un agua, por favor."}$j$::jsonb,$j${"value": "Een water, alstublieft.", "accepted": ["Een water, alstublieft.", "Een water, alstublieft", "Een water alstublieft"]}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$cortesia$p$, $p$writing$p$]),
('b7ddf080-33b5-5b50-b5e6-f8728523d113'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','writing','word_bank',$p$Ordena las fichas para formar: 'Quisiera un pan.'$p$,$j${"tiles": ["Ik", "wil", "graag", "een", "brood", "koffie"]}$j$::jsonb,$j${"value": "Ik wil graag een brood", "sequence": ["Ik", "wil", "graag", "een", "brood"]}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$pedir$p$, $p$writing$p$]),
('603b2e0c-b9a2-5132-9daf-31aad4ece00d'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','writing','reorder',$p$Ordena las palabras para formar: '¿Cuánto cuesta la tarta?'$p$,$j${"tiles": ["kost", "Wat", "taart?", "de"]}$j$::jsonb,$j${"value": "Wat kost de taart?"}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$precio$p$, $p$writing$p$]),
('83a0ecf7-249f-514f-ad37-1430097a3ed2'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ik wil graag een koffie.", "Ik wil graag een thee.", "Ik wil graag water."], "say": "Ik wil graag een koffie.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/83a0ecf7-249f-514f-ad37-1430097a3ed2.mp3"}$j$::jsonb,$j${"value": "Ik wil graag een koffie."}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$comida_bebida$p$, $p$listening$p$]),
('1fc8eda0-f32a-5727-a6ae-898dfeefeb9f'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Een brood, alstublieft.", "Een taart, alstublieft.", "Een appel, alstublieft."], "say": "Een brood, alstublieft.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/1fc8eda0-f32a-5727-a6ae-898dfeefeb9f.mp3"}$j$::jsonb,$j${"value": "Een brood, alstublieft."}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$cortesia$p$, $p$listening$p$]),
('532985e3-5c1f-5d74-94b8-f8a0d1d7ee2e'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Dat is vijf euro.", "Dat is drie euro.", "Wat kost het?"], "say": "Dat is vijf euro.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/532985e3-5c1f-5d74-94b8-f8a0d1d7ee2e.mp3"}$j$::jsonb,$j${"value": "Dat is vijf euro."}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$precio$p$, $p$listening$p$]),
('5952f75b-e04a-5c3b-8d01-671d0146f085'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Hoeveel kost de thee?", "Hoeveel kost het brood?", "Wat wil je graag?"], "say": "Hoeveel kost de thee?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/5952f75b-e04a-5c3b-8d01-671d0146f085.mp3"}$j$::jsonb,$j${"value": "Hoeveel kost de thee?"}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$precio$p$, $p$listening$p$]),
('116cff9d-3a60-5724-b6de-cc6a268dda23'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Ik wil graag een koffie.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/116cff9d-3a60-5724-b6de-cc6a268dda23.mp3"}$j$::jsonb,$j${"expected": "Ik wil graag een koffie."}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$pedir$p$, $p$speaking$p$]),
('d22a34ef-af7f-5722-8bfb-d25981f1b0b3'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Een thee, alstublieft.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/d22a34ef-af7f-5722-8bfb-d25981f1b0b3.mp3"}$j$::jsonb,$j${"expected": "Een thee, alstublieft."}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$cortesia$p$, $p$speaking$p$]),
('c476c3a9-1c32-56e8-a5aa-0c655fd139cf'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Wat kost het?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/c476c3a9-1c32-56e8-a5aa-0c655fd139cf.mp3"}$j$::jsonb,$j${"expected": "Wat kost het?"}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$precio$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('1631a90b-eec4-5107-885a-f89c84bc04b9','8c154c8d-53db-5269-b83a-c23233a235bc',1),
 ('1631a90b-eec4-5107-885a-f89c84bc04b9','ae271040-456a-57bd-b70d-394634884f21',2),
 ('1631a90b-eec4-5107-885a-f89c84bc04b9','f128bddf-13d5-5812-a971-d17db8c13f7b',3),
 ('1631a90b-eec4-5107-885a-f89c84bc04b9','3214ab60-8d14-52d7-a980-cdc810ae2652',4),
 ('1631a90b-eec4-5107-885a-f89c84bc04b9','83a0ecf7-249f-514f-ad37-1430097a3ed2',5),
 ('10941fe9-7943-5a8b-a9a1-079afb1a4c3e','bb7a94f1-8c95-53ae-b65d-108a7a903351',1),
 ('10941fe9-7943-5a8b-a9a1-079afb1a4c3e','fbfa4280-f729-56f8-abc9-7658c2abdfb7',2),
 ('10941fe9-7943-5a8b-a9a1-079afb1a4c3e','b7ddf080-33b5-5b50-b5e6-f8728523d113',3),
 ('10941fe9-7943-5a8b-a9a1-079afb1a4c3e','116cff9d-3a60-5724-b6de-cc6a268dda23',4),
 ('54f7a9cf-023f-5b61-b0be-5ae854c2205a','0879e2b7-70ad-551d-a4ff-0b842581bbc5',1),
 ('54f7a9cf-023f-5b61-b0be-5ae854c2205a','da64e636-efb8-563e-ba4a-800789dc9df1',2),
 ('54f7a9cf-023f-5b61-b0be-5ae854c2205a','1fc8eda0-f32a-5727-a6ae-898dfeefeb9f',3),
 ('54f7a9cf-023f-5b61-b0be-5ae854c2205a','d22a34ef-af7f-5722-8bfb-d25981f1b0b3',4),
 ('bb7ec32a-d3c9-5246-9931-e409a10eecfe','c19c55d5-406c-56db-be28-217412d63d84',1),
 ('bb7ec32a-d3c9-5246-9931-e409a10eecfe','61bd0f1d-64c8-5bcc-9162-8c8123851969',2),
 ('bb7ec32a-d3c9-5246-9931-e409a10eecfe','603b2e0c-b9a2-5132-9daf-31aad4ece00d',3),
 ('bb7ec32a-d3c9-5246-9931-e409a10eecfe','532985e3-5c1f-5d74-94b8-f8a0d1d7ee2e',4),
 ('bb7ec32a-d3c9-5246-9931-e409a10eecfe','5952f75b-e04a-5c3b-8d01-671d0146f085',5),
 ('bb7ec32a-d3c9-5246-9931-e409a10eecfe','c476c3a9-1c32-56e8-a5aa-0c655fd139cf',6),
 ('6362219d-6dc6-516a-95f1-3ef01b11be0a','8c154c8d-53db-5269-b83a-c23233a235bc',1),
 ('6362219d-6dc6-516a-95f1-3ef01b11be0a','ae271040-456a-57bd-b70d-394634884f21',2),
 ('6362219d-6dc6-516a-95f1-3ef01b11be0a','f128bddf-13d5-5812-a971-d17db8c13f7b',3),
 ('6362219d-6dc6-516a-95f1-3ef01b11be0a','3214ab60-8d14-52d7-a980-cdc810ae2652',4),
 ('6362219d-6dc6-516a-95f1-3ef01b11be0a','61bd0f1d-64c8-5bcc-9162-8c8123851969',5),
 ('6362219d-6dc6-516a-95f1-3ef01b11be0a','fbfa4280-f729-56f8-abc9-7658c2abdfb7',6),
 ('6362219d-6dc6-516a-95f1-3ef01b11be0a','83a0ecf7-249f-514f-ad37-1430097a3ed2',7),
 ('6362219d-6dc6-516a-95f1-3ef01b11be0a','1fc8eda0-f32a-5727-a6ae-898dfeefeb9f',8),
 ('6362219d-6dc6-516a-95f1-3ef01b11be0a','116cff9d-3a60-5724-b6de-cc6a268dda23',9),
 ('6362219d-6dc6-516a-95f1-3ef01b11be0a','d22a34ef-af7f-5722-8bfb-d25981f1b0b3',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('f4cd0a28-f025-581f-8249-17dcadd9d164','20000000-0000-0000-0000-000000000006',$p$het brood$p$,$p$el pan$p$,181,'sustantivo'),
 ('b86ac67b-d4ac-50dd-9e55-0452bd551e7f','20000000-0000-0000-0000-000000000006',$p$het water$p$,$p$el agua$p$,182,'sustantivo'),
 ('25a06f69-d66d-5fe8-ae2a-154f0014c5c0','20000000-0000-0000-0000-000000000006',$p$de koffie$p$,$p$el café$p$,183,'sustantivo'),
 ('86173b5b-d2fc-5558-997f-41a5e0cfc4f4','20000000-0000-0000-0000-000000000006',$p$de thee$p$,$p$el té$p$,184,'sustantivo'),
 ('880f82aa-afc7-5d1f-8beb-af0a72c1f566','20000000-0000-0000-0000-000000000006',$p$de melk$p$,$p$la leche$p$,185,'sustantivo'),
 ('f81b92bd-076a-59ac-b51e-07b6d3865caf','20000000-0000-0000-0000-000000000006',$p$de appel$p$,$p$la manzana$p$,186,'sustantivo'),
 ('26c5cf12-9249-58f7-89f3-e0e0c0c7a044','20000000-0000-0000-0000-000000000006',$p$het sap$p$,$p$el zumo$p$,187,'sustantivo'),
 ('d113bb73-150d-5bc2-acd0-df321b01814a','20000000-0000-0000-0000-000000000006',$p$de taart$p$,$p$la tarta$p$,188,'sustantivo'),
 ('3d679228-f53f-5d0b-9780-483e4394e4fd','20000000-0000-0000-0000-000000000006',$p$Ik wil graag$p$,$p$Quisiera / Me gustaría$p$,189,'expresion'),
 ('7cf5fd0d-5574-54c0-81c5-88a8f427cd69','20000000-0000-0000-0000-000000000006',$p$alstublieft$p$,$p$por favor / aquí tiene$p$,190,'expresion'),
 ('2cb8c824-91cd-5958-9f81-d63f4168ad54','20000000-0000-0000-0000-000000000006',$p$dank u wel$p$,$p$muchas gracias$p$,191,'expresion'),
 ('e266de29-bb2a-590e-9019-e52b583d467c','20000000-0000-0000-0000-000000000006',$p$Wat kost het?$p$,$p$¿Cuánto cuesta?$p$,192,'expresion'),
 ('5cebb9f1-9cd6-5f90-a51c-c3e9ccffe21b','20000000-0000-0000-0000-000000000006',$p$Hoeveel kost het?$p$,$p$¿Cuánto cuesta?$p$,193,'expresion'),
 ('731941c5-b514-501b-be5b-64812b224a92','20000000-0000-0000-0000-000000000006',$p$de euro$p$,$p$el euro$p$,194,'sustantivo'),
 ('600a988f-a1be-5eac-a008-012a925555f1','20000000-0000-0000-0000-000000000006',$p$Dat is$p$,$p$Son / Eso es$p$,195,'expresion'),
 ('57eb9059-3afe-56a2-8cd1-9b534ba4e1e2','20000000-0000-0000-0000-000000000006',$p$een$p$,$p$un / una$p$,196,'articulo')
on conflict (id) do nothing;

-- ── Unidad 5 (A1·nl): El día y la hora ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('99a1a20d-a7c0-5cf0-bb52-62994d1ffad7','20000000-0000-0000-0000-000000000006','A1',5,$p$El día y la hora$p$,'#2980B9','schedule')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('89c09e18-ce40-5d71-beb3-c04bcdfff678','99a1a20d-a7c0-5cf0-bb52-62994d1ffad7',1,$p$¿Qué hora es?$p$,$p$¿Qué hora es?$p$,'lesson',15),
 ('511798c6-6c72-5ac1-bb4d-7339c26568d4','99a1a20d-a7c0-5cf0-bb52-62994d1ffad7',2,$p$Los cuartos de hora$p$,$p$Los cuartos de hora$p$,'lesson',15),
 ('a58bce69-fd9b-5e81-bbef-a20de7fb4ca2','99a1a20d-a7c0-5cf0-bb52-62994d1ffad7',3,$p$Los días de la semana$p$,$p$Los días de la semana$p$,'lesson',15),
 ('26c0afde-f40a-511d-94a0-2cd0402f3e96','99a1a20d-a7c0-5cf0-bb52-62994d1ffad7',4,$p$Mi rutina diaria$p$,$p$Mi rutina diaria$p$,'lesson',15),
 ('a49d0195-f467-5ec5-91dd-006010d08304','99a1a20d-a7c0-5cf0-bb52-62994d1ffad7',5,$p$🏁 Checkpoint Eenheid 5$p$,$p$Practica decir la hora, los días de la semana y verbos del día a día en presente.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('4ae8fd7a-b421-5691-8455-1f794f25d8c1','20000000-0000-0000-0000-000000000006','checkpoint','A1','99a1a20d-a7c0-5cf0-bb52-62994d1ffad7',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('38243c52-4e89-5230-9667-7867bd29c39d'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','reading','match',$p$Une cada palabra neerlandesa con su significado en español.$p$,$j${"pairs": [{"en": "hoe laat", "es": "qué hora"}, {"en": "het uur", "es": "la hora"}, {"en": "de dag", "es": "el día"}]}$j$::jsonb,$j${"pairs": [["hoe laat", "qué hora"], ["het uur", "la hora"], ["de dag", "el día"]]}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$hora$p$, $p$reading$p$]),
('336a0b45-0e25-5f55-bb4f-3d33faa322c2'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','reading','match',$p$Une cada día de la semana con su significado en español.$p$,$j${"pairs": [{"en": "maandag", "es": "lunes"}, {"en": "vrijdag", "es": "viernes"}, {"en": "zondag", "es": "domingo"}]}$j$::jsonb,$j${"pairs": [["maandag", "lunes"], ["vrijdag", "viernes"], ["zondag", "domingo"]]}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$dagen$p$, $p$reading$p$]),
('080bf6ae-b84b-571b-876d-b3a66904747e'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','reading','multiple_choice',$p$¿Cómo se pregunta '¿Qué hora es?' en neerlandés?$p$,$j${"options": ["Hoe laat is het?", "Hoe oud is het?", "Waar is het?"]}$j$::jsonb,$j${"value": "Hoe laat is het?"}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$hora$p$, $p$reading$p$]),
('db9feff2-3ea0-52cb-b342-16d84b1b7c5a'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','reading','multiple_choice',$p$'Het is drie uur' significa...$p$,$j${"options": ["Son las tres", "Son las cuatro", "Es la una"]}$j$::jsonb,$j${"value": "Son las tres"}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$hora$p$, $p$reading$p$]),
('2c71a66a-30e3-5f81-81e8-842d3ecfb376'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','reading','multiple_choice',$p$¿Cómo se dice 'las tres y cuarto'?$p$,$j${"options": ["kwart over drie", "kwart voor drie", "half drie"]}$j$::jsonb,$j${"value": "kwart over drie"}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$kwart$p$, $p$reading$p$]),
('7b478abe-58b6-5e59-98a4-2e6333cbfe9b'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','reading','multiple_choice',$p$'Ik werk' significa...$p$,$j${"options": ["Yo trabajo", "Yo vivo", "Yo juego"]}$j$::jsonb,$j${"value": "Yo trabajo"}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$verbos$p$, $p$reading$p$]),
('621aa4fa-dd9a-5e6e-9227-48408c2e983f'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','writing','cloze',$p$Completa: '¿Qué hora es?'$p$,$j${"text": "Hoe ___ is het?"}$j$::jsonb,$j${"value": "laat", "accepted": ["laat"]}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$hora$p$, $p$writing$p$]),
('6e3a1e15-f092-555d-92ab-2e69d54b727c'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','writing','cloze',$p$Completa: 'Yo vivo en Ámsterdam.'$p$,$j${"text": "Ik ___ in Amsterdam."}$j$::jsonb,$j${"value": "woon", "accepted": ["woon"]}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$verbos$p$, $p$writing$p$]),
('b565b183-94c1-5263-bfe4-ada5200214e6'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','writing','translation',$p$Traduce: Son las cuatro menos cuarto.$p$,$j${"source": "Son las cuatro menos cuarto."}$j$::jsonb,$j${"value": "Het is kwart voor vier.", "accepted": ["Het is kwart voor vier.", "Het is kwart voor vier"]}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$kwart$p$, $p$writing$p$]),
('92f11ea1-760c-5e56-b99d-2d9c03c9f262'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','writing','translation',$p$Traduce: Hoy es lunes.$p$,$j${"source": "Hoy es lunes."}$j$::jsonb,$j${"value": "Vandaag is het maandag.", "accepted": ["Vandaag is het maandag.", "Vandaag is het maandag", "Het is maandag.", "Het is maandag"]}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$dagen$p$, $p$writing$p$]),
('94e75fc6-779e-5688-8806-112bc47524ad'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','writing','word_bank',$p$Ordena las fichas: 'Son las tres y cuarto.'$p$,$j${"tiles": ["Het", "is", "kwart", "over", "drie", "uur"]}$j$::jsonb,$j${"value": "Het is kwart over drie", "sequence": ["Het", "is", "kwart", "over", "drie"]}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$kwart$p$, $p$writing$p$]),
('18a19b45-3ea0-5929-8cc0-8087efbea16a'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','writing','reorder',$p$Ordena las palabras para formar: 'Yo aprendo neerlandés.'$p$,$j${"tiles": ["leer", "Ik", "Nederlands"]}$j$::jsonb,$j${"value": "Ik leer Nederlands"}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$verbos$p$, $p$writing$p$]),
('c6311b2d-9561-51f8-b715-4d09c9388493'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Het is twee uur.", "Het is tien uur.", "Het is negen uur."], "say": "Het is twee uur.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/c6311b2d-9561-51f8-b715-4d09c9388493.mp3"}$j$::jsonb,$j${"value": "Het is twee uur."}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$hora$p$, $p$listening$p$]),
('6c686c08-dc45-5644-918d-f8dd40879300'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Het is kwart over zes.", "Het is kwart voor zes.", "Het is zes uur."], "say": "Het is kwart over zes.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/6c686c08-dc45-5644-918d-f8dd40879300.mp3"}$j$::jsonb,$j${"value": "Het is kwart over zes."}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$kwart$p$, $p$listening$p$]),
('541fe061-d93d-5bf2-beb7-e70b86ca80c1'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Vandaag is het woensdag.", "Vandaag is het zaterdag.", "Vandaag is het dinsdag."], "say": "Vandaag is het woensdag.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/541fe061-d93d-5bf2-beb7-e70b86ca80c1.mp3"}$j$::jsonb,$j${"value": "Vandaag is het woensdag."}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$dagen$p$, $p$listening$p$]),
('6e50517f-abe4-5aec-92b7-d579faa1f652'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ik werk op maandag.", "Ik speel op maandag.", "Ik woon op maandag."], "say": "Ik werk op maandag.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/6e50517f-abe4-5aec-92b7-d579faa1f652.mp3"}$j$::jsonb,$j${"value": "Ik werk op maandag."}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$verbos$p$, $p$listening$p$]),
('9f2d5fab-d01b-5f08-87ef-5a9c8473e836'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Hoe laat is het?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/9f2d5fab-d01b-5f08-87ef-5a9c8473e836.mp3"}$j$::jsonb,$j${"expected": "Hoe laat is het?"}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$hora$p$, $p$speaking$p$]),
('be7b03f7-05e7-5f9d-b38e-76c000e2e35d'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Vandaag is het vrijdag.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/be7b03f7-05e7-5f9d-b38e-76c000e2e35d.mp3"}$j$::jsonb,$j${"expected": "Vandaag is het vrijdag."}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$dagen$p$, $p$speaking$p$]),
('082edb00-f58a-5f34-9d0e-dfe233a59c5f'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Ik woon in Nederland.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/082edb00-f58a-5f34-9d0e-dfe233a59c5f.mp3"}$j$::jsonb,$j${"expected": "Ik woon in Nederland."}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$verbos$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('89c09e18-ce40-5d71-beb3-c04bcdfff678','38243c52-4e89-5230-9667-7867bd29c39d',1),
 ('89c09e18-ce40-5d71-beb3-c04bcdfff678','080bf6ae-b84b-571b-876d-b3a66904747e',2),
 ('89c09e18-ce40-5d71-beb3-c04bcdfff678','db9feff2-3ea0-52cb-b342-16d84b1b7c5a',3),
 ('89c09e18-ce40-5d71-beb3-c04bcdfff678','621aa4fa-dd9a-5e6e-9227-48408c2e983f',4),
 ('89c09e18-ce40-5d71-beb3-c04bcdfff678','c6311b2d-9561-51f8-b715-4d09c9388493',5),
 ('89c09e18-ce40-5d71-beb3-c04bcdfff678','9f2d5fab-d01b-5f08-87ef-5a9c8473e836',6),
 ('511798c6-6c72-5ac1-bb4d-7339c26568d4','2c71a66a-30e3-5f81-81e8-842d3ecfb376',1),
 ('511798c6-6c72-5ac1-bb4d-7339c26568d4','b565b183-94c1-5263-bfe4-ada5200214e6',2),
 ('511798c6-6c72-5ac1-bb4d-7339c26568d4','94e75fc6-779e-5688-8806-112bc47524ad',3),
 ('511798c6-6c72-5ac1-bb4d-7339c26568d4','6c686c08-dc45-5644-918d-f8dd40879300',4),
 ('a58bce69-fd9b-5e81-bbef-a20de7fb4ca2','336a0b45-0e25-5f55-bb4f-3d33faa322c2',1),
 ('a58bce69-fd9b-5e81-bbef-a20de7fb4ca2','92f11ea1-760c-5e56-b99d-2d9c03c9f262',2),
 ('a58bce69-fd9b-5e81-bbef-a20de7fb4ca2','541fe061-d93d-5bf2-beb7-e70b86ca80c1',3),
 ('a58bce69-fd9b-5e81-bbef-a20de7fb4ca2','be7b03f7-05e7-5f9d-b38e-76c000e2e35d',4),
 ('26c0afde-f40a-511d-94a0-2cd0402f3e96','7b478abe-58b6-5e59-98a4-2e6333cbfe9b',1),
 ('26c0afde-f40a-511d-94a0-2cd0402f3e96','6e3a1e15-f092-555d-92ab-2e69d54b727c',2),
 ('26c0afde-f40a-511d-94a0-2cd0402f3e96','18a19b45-3ea0-5929-8cc0-8087efbea16a',3),
 ('26c0afde-f40a-511d-94a0-2cd0402f3e96','6e50517f-abe4-5aec-92b7-d579faa1f652',4),
 ('26c0afde-f40a-511d-94a0-2cd0402f3e96','082edb00-f58a-5f34-9d0e-dfe233a59c5f',5),
 ('a49d0195-f467-5ec5-91dd-006010d08304','38243c52-4e89-5230-9667-7867bd29c39d',1),
 ('a49d0195-f467-5ec5-91dd-006010d08304','336a0b45-0e25-5f55-bb4f-3d33faa322c2',2),
 ('a49d0195-f467-5ec5-91dd-006010d08304','080bf6ae-b84b-571b-876d-b3a66904747e',3),
 ('a49d0195-f467-5ec5-91dd-006010d08304','621aa4fa-dd9a-5e6e-9227-48408c2e983f',4),
 ('a49d0195-f467-5ec5-91dd-006010d08304','6e3a1e15-f092-555d-92ab-2e69d54b727c',5),
 ('a49d0195-f467-5ec5-91dd-006010d08304','b565b183-94c1-5263-bfe4-ada5200214e6',6),
 ('a49d0195-f467-5ec5-91dd-006010d08304','c6311b2d-9561-51f8-b715-4d09c9388493',7),
 ('a49d0195-f467-5ec5-91dd-006010d08304','6c686c08-dc45-5644-918d-f8dd40879300',8),
 ('a49d0195-f467-5ec5-91dd-006010d08304','9f2d5fab-d01b-5f08-87ef-5a9c8473e836',9),
 ('a49d0195-f467-5ec5-91dd-006010d08304','be7b03f7-05e7-5f9d-b38e-76c000e2e35d',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('ffcc54e8-ab7b-5091-b8aa-7308afee4ae5','20000000-0000-0000-0000-000000000006',$p$hoe laat$p$,$p$a qué hora / qué hora$p$,201,'expresion'),
 ('fb4bb7da-04a6-5e23-b69d-8bfc717c52e7','20000000-0000-0000-0000-000000000006',$p$het uur$p$,$p$la hora$p$,202,'sustantivo'),
 ('c97bfb68-9957-54cf-a80d-f27fccf6976c','20000000-0000-0000-0000-000000000006',$p$kwart over$p$,$p$y cuarto$p$,203,'expresion'),
 ('479168e1-7f79-5d41-83e4-9c2b8c7319f1','20000000-0000-0000-0000-000000000006',$p$kwart voor$p$,$p$menos cuarto$p$,204,'expresion'),
 ('80f88d74-229b-58ff-a25d-345440207a69','20000000-0000-0000-0000-000000000006',$p$de dag$p$,$p$el día$p$,205,'sustantivo'),
 ('8c449625-805d-5a1a-920f-43eae63dbe6e','20000000-0000-0000-0000-000000000006',$p$maandag$p$,$p$lunes$p$,206,'sustantivo'),
 ('b969dd6a-5225-5b98-baac-a870e9d6089f','20000000-0000-0000-0000-000000000006',$p$dinsdag$p$,$p$martes$p$,207,'sustantivo'),
 ('c3b5a0bf-31cc-56cb-a536-f51fccff8caf','20000000-0000-0000-0000-000000000006',$p$woensdag$p$,$p$miércoles$p$,208,'sustantivo'),
 ('f2d7e93d-66c0-5c5c-a76b-b6e7be0adcef','20000000-0000-0000-0000-000000000006',$p$donderdag$p$,$p$jueves$p$,209,'sustantivo'),
 ('533abe2e-2781-5ac5-b8d1-12f447aca381','20000000-0000-0000-0000-000000000006',$p$vrijdag$p$,$p$viernes$p$,210,'sustantivo'),
 ('266582fe-a6c1-51fc-8e5c-20fc770527e3','20000000-0000-0000-0000-000000000006',$p$zaterdag$p$,$p$sábado$p$,211,'sustantivo'),
 ('8e6c8755-785a-590e-bc41-df3fb56c34cc','20000000-0000-0000-0000-000000000006',$p$zondag$p$,$p$domingo$p$,212,'sustantivo'),
 ('a0773b01-3ef3-5862-8422-8581d1a7707a','20000000-0000-0000-0000-000000000006',$p$wonen$p$,$p$vivir (residir)$p$,213,'verbo'),
 ('094b17c7-f942-5da1-88f4-87b1f6148bde','20000000-0000-0000-0000-000000000006',$p$werken$p$,$p$trabajar$p$,214,'verbo'),
 ('7c4ba241-0067-5f47-ab22-14c4939ade85','20000000-0000-0000-0000-000000000006',$p$leren$p$,$p$aprender$p$,215,'verbo'),
 ('1c45f5ef-79f3-5f68-9fc3-cac87cfcb0d5','20000000-0000-0000-0000-000000000006',$p$spelen$p$,$p$jugar$p$,216,'verbo')
on conflict (id) do nothing;

-- ── Unidad 6 (A1·nl): La ciudad y direcciones ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('d1906c00-59f4-532f-8c6f-3382495cb1c6','20000000-0000-0000-0000-000000000006','A1',6,$p$La ciudad y direcciones$p$,'#16A085','location_city')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('af1d61c2-f21a-5414-b951-9110f06ca5ae','d1906c00-59f4-532f-8c6f-3382495cb1c6',1,$p$Lugares de la ciudad$p$,$p$Lugares de la ciudad$p$,'lesson',15),
 ('7dc49255-6a8f-525f-8c7d-93bda740e82e','d1906c00-59f4-532f-8c6f-3382495cb1c6',2,$p$¿Dónde está?$p$,$p$¿Dónde está?$p$,'lesson',15),
 ('29648588-1516-5e79-9e7d-88039b86c14c','d1906c00-59f4-532f-8c6f-3382495cb1c6',3,$p$Hay un... / Hay unos...$p$,$p$Hay un... / Hay unos...$p$,'lesson',15),
 ('9af16371-f9c5-546e-ade2-02c48a2ee873','d1906c00-59f4-532f-8c6f-3382495cb1c6',4,$p$Izquierda y derecha$p$,$p$Izquierda y derecha$p$,'lesson',15),
 ('4f5e3b51-f188-5ad6-890c-1f55caff4a30','d1906c00-59f4-532f-8c6f-3382495cb1c6',5,$p$🏁 Checkpoint Eenheid 6$p$,$p$Practica lugares de la ciudad, preguntar dónde está algo y dar direcciones básicas.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('be636495-6fb3-5fbb-8e41-40375e978705','20000000-0000-0000-0000-000000000006','checkpoint','A1','d1906c00-59f4-532f-8c6f-3382495cb1c6',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('f5fe6f60-cd47-593f-aea9-9457f19da219'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','reading','match',$p$Une cada lugar neerlandés con su significado en español.$p$,$j${"pairs": [{"en": "het station", "es": "la estación"}, {"en": "de bank", "es": "el banco"}, {"en": "het museum", "es": "el museo"}]}$j$::jsonb,$j${"pairs": [["het station", "la estación"], ["de bank", "el banco"], ["het museum", "el museo"]]}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$lugares$p$, $p$reading$p$]),
('88e09295-b541-5747-ae1d-bf4db17372f6'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','reading','match',$p$Une cada dirección neerlandesa con su significado en español.$p$,$j${"pairs": [{"en": "links", "es": "a la izquierda"}, {"en": "rechts", "es": "a la derecha"}, {"en": "rechtdoor", "es": "todo recto"}]}$j$::jsonb,$j${"pairs": [["links", "a la izquierda"], ["rechts", "a la derecha"], ["rechtdoor", "todo recto"]]}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$direcciones$p$, $p$reading$p$]),
('0379e9aa-2578-5619-8a34-916c943eda93'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','reading','multiple_choice',$p$¿Cómo se pregunta '¿Dónde está la estación?'?$p$,$j${"options": ["Waar is het station?", "Wie is het station?", "Wat is het station?"]}$j$::jsonb,$j${"value": "Waar is het station?"}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$waar$p$, $p$reading$p$]),
('a5805591-9fce-526f-9e4e-b1ddfa4f3179'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','reading','multiple_choice',$p$¿Cuál es el artículo correcto: '___ museum'?$p$,$j${"options": ["het", "de", "een de"]}$j$::jsonb,$j${"value": "het"}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$lugares$p$, $p$reading$p$]),
('ea6238fe-4561-5985-b0a5-eca44df52a52'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','reading','multiple_choice',$p$'De bank is naast het hotel' significa...$p$,$j${"options": ["El banco está al lado del hotel", "El banco está enfrente del hotel", "El banco está lejos del hotel"]}$j$::jsonb,$j${"value": "El banco está al lado del hotel"}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$direcciones$p$, $p$reading$p$]),
('59681352-0d12-5e4e-aeb0-1bba602f48c8'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','reading','multiple_choice',$p$¿Cómo se dice 'Hay un restaurante aquí'?$p$,$j${"options": ["Er is hier een restaurant.", "Er zijn hier een restaurant.", "Het is hier een restaurant."]}$j$::jsonb,$j${"value": "Er is hier een restaurant."}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$er$p$, $p$reading$p$]),
('c5e845a4-8616-5d8b-883d-28f910b7ec14'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','writing','cloze',$p$Completa: '¿Dónde está la farmacia?'$p$,$j${"text": "___ is de apotheek?"}$j$::jsonb,$j${"value": "Waar", "accepted": ["Waar"]}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$waar$p$, $p$writing$p$]),
('0780ac8d-f41e-5852-88cb-104bc7313026'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','writing','cloze',$p$Completa con el artículo correcto: 'la estación'.$p$,$j${"text": "___ station"}$j$::jsonb,$j${"value": "het", "accepted": ["het"]}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$lugares$p$, $p$writing$p$]),
('fac7c695-df58-52b2-bede-4ef0811067a7'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','writing','translation',$p$Traduce: Hay un hotel al lado de la estación.$p$,$j${"source": "Hay un hotel al lado de la estación."}$j$::jsonb,$j${"value": "Er is een hotel naast het station.", "accepted": ["Er is een hotel naast het station.", "Er is een hotel naast het station"]}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$er$p$, $p$writing$p$]),
('5d94e101-1b13-54b5-a1c6-8b561ae98de7'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','writing','translation',$p$Traduce: El museo está enfrente de la plaza.$p$,$j${"source": "El museo está enfrente de la plaza."}$j$::jsonb,$j${"value": "Het museum is tegenover het plein.", "accepted": ["Het museum is tegenover het plein.", "Het museum is tegenover het plein"]}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$direcciones$p$, $p$writing$p$]),
('bec0c24e-d84a-5c34-b3d8-9565374f315d'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','writing','word_bank',$p$Ordena las fichas: '¿Dónde está el restaurante?'$p$,$j${"tiles": ["Waar", "is", "het", "restaurant", "de", "zijn"]}$j$::jsonb,$j${"value": "Waar is het restaurant", "sequence": ["Waar", "is", "het", "restaurant"]}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$waar$p$, $p$writing$p$]),
('e927331e-b519-533d-8e95-f1a5780a273c'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','writing','reorder',$p$Ordena las palabras para formar: 'La calle está a la derecha.'$p$,$j${"tiles": ["rechts", "De", "straat", "is"]}$j$::jsonb,$j${"value": "De straat is rechts"}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$direcciones$p$, $p$writing$p$]),
('a9345147-b558-5d3d-89f1-77940d2c2344'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Het museum is groot.", "Het hotel is groot.", "Het station is groot."], "say": "Het museum is groot.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/a9345147-b558-5d3d-89f1-77940d2c2344.mp3"}$j$::jsonb,$j${"value": "Het museum is groot."}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$lugares$p$, $p$listening$p$]),
('bfc58751-c779-56f0-aa0a-de858229781c'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Waar is de bank?", "Waar is de straat?", "Waar is de apotheek?"], "say": "Waar is de bank?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/bfc58751-c779-56f0-aa0a-de858229781c.mp3"}$j$::jsonb,$j${"value": "Waar is de bank?"}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$waar$p$, $p$listening$p$]),
('90f110e8-d1fc-5fe8-9cb6-28827dbf3d3c'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Er zijn hier twee hotels.", "Er is hier een hotel.", "Er zijn hier twee musea."], "say": "Er zijn hier twee hotels.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/90f110e8-d1fc-5fe8-9cb6-28827dbf3d3c.mp3"}$j$::jsonb,$j${"value": "Er zijn hier twee hotels."}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$er$p$, $p$listening$p$]),
('f106130e-9a39-57d1-835c-b0604089eda4'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ga rechtdoor en dan links.", "Ga rechtdoor en dan rechts.", "Ga links en dan rechtdoor."], "say": "Ga rechtdoor en dan links.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/f106130e-9a39-57d1-835c-b0604089eda4.mp3"}$j$::jsonb,$j${"value": "Ga rechtdoor en dan links."}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$direcciones$p$, $p$listening$p$]),
('09ea7b30-8406-5245-8a20-1624d63086ac'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Waar is het station?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/09ea7b30-8406-5245-8a20-1624d63086ac.mp3"}$j$::jsonb,$j${"expected": "Waar is het station?"}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$waar$p$, $p$speaking$p$]),
('897b0c50-97f7-5f88-a19e-f84d83cb8628'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Er is hier een restaurant.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/897b0c50-97f7-5f88-a19e-f84d83cb8628.mp3"}$j$::jsonb,$j${"expected": "Er is hier een restaurant."}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$er$p$, $p$speaking$p$]),
('802bd522-3143-5883-af02-9c2bbde9becd'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "De apotheek is rechts.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/802bd522-3143-5883-af02-9c2bbde9becd.mp3"}$j$::jsonb,$j${"expected": "De apotheek is rechts."}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$direcciones$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('af1d61c2-f21a-5414-b951-9110f06ca5ae','f5fe6f60-cd47-593f-aea9-9457f19da219',1),
 ('af1d61c2-f21a-5414-b951-9110f06ca5ae','a5805591-9fce-526f-9e4e-b1ddfa4f3179',2),
 ('af1d61c2-f21a-5414-b951-9110f06ca5ae','0780ac8d-f41e-5852-88cb-104bc7313026',3),
 ('af1d61c2-f21a-5414-b951-9110f06ca5ae','a9345147-b558-5d3d-89f1-77940d2c2344',4),
 ('7dc49255-6a8f-525f-8c7d-93bda740e82e','0379e9aa-2578-5619-8a34-916c943eda93',1),
 ('7dc49255-6a8f-525f-8c7d-93bda740e82e','c5e845a4-8616-5d8b-883d-28f910b7ec14',2),
 ('7dc49255-6a8f-525f-8c7d-93bda740e82e','bec0c24e-d84a-5c34-b3d8-9565374f315d',3),
 ('7dc49255-6a8f-525f-8c7d-93bda740e82e','bfc58751-c779-56f0-aa0a-de858229781c',4),
 ('7dc49255-6a8f-525f-8c7d-93bda740e82e','09ea7b30-8406-5245-8a20-1624d63086ac',5),
 ('29648588-1516-5e79-9e7d-88039b86c14c','59681352-0d12-5e4e-aeb0-1bba602f48c8',1),
 ('29648588-1516-5e79-9e7d-88039b86c14c','fac7c695-df58-52b2-bede-4ef0811067a7',2),
 ('29648588-1516-5e79-9e7d-88039b86c14c','90f110e8-d1fc-5fe8-9cb6-28827dbf3d3c',3),
 ('29648588-1516-5e79-9e7d-88039b86c14c','897b0c50-97f7-5f88-a19e-f84d83cb8628',4),
 ('9af16371-f9c5-546e-ade2-02c48a2ee873','88e09295-b541-5747-ae1d-bf4db17372f6',1),
 ('9af16371-f9c5-546e-ade2-02c48a2ee873','ea6238fe-4561-5985-b0a5-eca44df52a52',2),
 ('9af16371-f9c5-546e-ade2-02c48a2ee873','5d94e101-1b13-54b5-a1c6-8b561ae98de7',3),
 ('9af16371-f9c5-546e-ade2-02c48a2ee873','e927331e-b519-533d-8e95-f1a5780a273c',4),
 ('9af16371-f9c5-546e-ade2-02c48a2ee873','f106130e-9a39-57d1-835c-b0604089eda4',5),
 ('9af16371-f9c5-546e-ade2-02c48a2ee873','802bd522-3143-5883-af02-9c2bbde9becd',6),
 ('4f5e3b51-f188-5ad6-890c-1f55caff4a30','f5fe6f60-cd47-593f-aea9-9457f19da219',1),
 ('4f5e3b51-f188-5ad6-890c-1f55caff4a30','88e09295-b541-5747-ae1d-bf4db17372f6',2),
 ('4f5e3b51-f188-5ad6-890c-1f55caff4a30','0379e9aa-2578-5619-8a34-916c943eda93',3),
 ('4f5e3b51-f188-5ad6-890c-1f55caff4a30','c5e845a4-8616-5d8b-883d-28f910b7ec14',4),
 ('4f5e3b51-f188-5ad6-890c-1f55caff4a30','0780ac8d-f41e-5852-88cb-104bc7313026',5),
 ('4f5e3b51-f188-5ad6-890c-1f55caff4a30','fac7c695-df58-52b2-bede-4ef0811067a7',6),
 ('4f5e3b51-f188-5ad6-890c-1f55caff4a30','a9345147-b558-5d3d-89f1-77940d2c2344',7),
 ('4f5e3b51-f188-5ad6-890c-1f55caff4a30','bfc58751-c779-56f0-aa0a-de858229781c',8),
 ('4f5e3b51-f188-5ad6-890c-1f55caff4a30','09ea7b30-8406-5245-8a20-1624d63086ac',9),
 ('4f5e3b51-f188-5ad6-890c-1f55caff4a30','897b0c50-97f7-5f88-a19e-f84d83cb8628',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('e5bcdb79-998e-5988-a68d-fe2d41a9a20e','20000000-0000-0000-0000-000000000006',$p$het station$p$,$p$la estación$p$,221,'sustantivo'),
 ('26a997dc-cdd5-5ca7-8ef7-43272e32eabc','20000000-0000-0000-0000-000000000006',$p$de bank$p$,$p$el banco$p$,222,'sustantivo'),
 ('3739dde3-4248-54cc-a678-b6c5b665a54c','20000000-0000-0000-0000-000000000006',$p$het museum$p$,$p$el museo$p$,223,'sustantivo'),
 ('f503fd4d-3ee6-556e-ac53-6dbd3622bce2','20000000-0000-0000-0000-000000000006',$p$het restaurant$p$,$p$el restaurante$p$,224,'sustantivo'),
 ('db9e998e-3f33-5ad3-b93d-77251e53f025','20000000-0000-0000-0000-000000000006',$p$het hotel$p$,$p$el hotel$p$,225,'sustantivo'),
 ('d95139ed-d3a7-5d24-96f8-b04785a13f0a','20000000-0000-0000-0000-000000000006',$p$het plein$p$,$p$la plaza$p$,226,'sustantivo'),
 ('a443d259-b730-57c2-b1e2-af24be5b8eda','20000000-0000-0000-0000-000000000006',$p$de straat$p$,$p$la calle$p$,227,'sustantivo'),
 ('7878abbd-f318-5cf5-866b-6c37956325d4','20000000-0000-0000-0000-000000000006',$p$de apotheek$p$,$p$la farmacia$p$,228,'sustantivo'),
 ('9c9a927a-985f-54c4-8aca-fd537b7d753f','20000000-0000-0000-0000-000000000006',$p$waar$p$,$p$dónde$p$,229,'adverbio'),
 ('5fc542ff-b994-594a-98f9-58fab39bd738','20000000-0000-0000-0000-000000000006',$p$links$p$,$p$a la izquierda$p$,230,'adverbio'),
 ('8ddd3420-1ea8-5f54-90d8-64114f2a73bb','20000000-0000-0000-0000-000000000006',$p$rechts$p$,$p$a la derecha$p$,231,'adverbio'),
 ('3d99de25-00c9-5ec2-8a99-02288e846900','20000000-0000-0000-0000-000000000006',$p$rechtdoor$p$,$p$recto / todo recto$p$,232,'adverbio'),
 ('d6267840-948f-5f75-b737-5d0e5c3097bb','20000000-0000-0000-0000-000000000006',$p$naast$p$,$p$al lado de$p$,233,'preposicion'),
 ('3aee0765-8aca-5569-b522-109f50134a4a','20000000-0000-0000-0000-000000000006',$p$tegenover$p$,$p$enfrente de$p$,234,'preposicion'),
 ('4eb2090b-ed3d-581b-962c-d506addeb76a','20000000-0000-0000-0000-000000000006',$p$er is$p$,$p$hay (singular)$p$,235,'expresion'),
 ('14ae576f-3f0f-5757-bde1-9fe962361555','20000000-0000-0000-0000-000000000006',$p$er zijn$p$,$p$hay (plural)$p$,236,'expresion')
on conflict (id) do nothing;

commit;