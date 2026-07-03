-- 20260703120098_seed_it_a2.sql
-- Currículo A2 del curso es→it (6 unidades). Molde es→pt.
-- Contenido scopeado a course_id=20000000-0000-0000-0000-000000000004 → aislamiento multicurso por
-- jz_active_course. Unidades order_index continúan la cadena → gating al nivel previo.
begin;
insert into languages (id, code, name) values
  ('10000000-0000-0000-0000-000000000005','it',$p$Italiano$p$) on conflict (id) do nothing;
insert into courses (id, source_language_id, target_language_id, is_active) values
  ('20000000-0000-0000-0000-000000000004','10000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000005',true) on conflict (id) do nothing;

-- ── Unidad 7 (A2·it): El pasado: lo que hice ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('b2c4824c-fa7e-5e47-b728-6f384b6deb92','20000000-0000-0000-0000-000000000004','A2',7,$p$El pasado: lo que hice$p$,'#C0392B','history_edu')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('6d49c197-8307-5182-b05f-396ee95c7d6e','b2c4824c-fa7e-5e47-b728-6f384b6deb92',1,$p$Ayer comí: participios regulares$p$,$p$Ayer comí: participios regulares$p$,'lesson',15),
 ('a783c7c5-b9d2-5799-8540-ba7ba7604885','b2c4824c-fa7e-5e47-b728-6f384b6deb92',2,$p$Participios irregulares frecuentes$p$,$p$Participios irregulares frecuentes$p$,'lesson',15),
 ('d545d901-af98-593f-922b-c81c62a3c2b0','b2c4824c-fa7e-5e47-b728-6f384b6deb92',3,$p$Negar y preguntar sobre el pasado$p$,$p$Negar y preguntar sobre el pasado$p$,'lesson',15),
 ('c7846cad-c452-51d0-b9ec-ff0e682ea28d','b2c4824c-fa7e-5e47-b728-6f384b6deb92',4,$p$Cuándo pasó: ayer, la semana pasada$p$,$p$Cuándo pasó: ayer, la semana pasada$p$,'lesson',15),
 ('9719d3f9-a989-5b4b-9dc9-3c4efa39a81b','b2c4824c-fa7e-5e47-b728-6f384b6deb92',5,$p$🏁 Checkpoint Unità 7$p$,$p$Demuestra que sabes hablar del pasado con el passato prossimo y el auxiliar avere.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('45726f8c-8401-54a5-b6af-84e4f5a26166','20000000-0000-0000-0000-000000000004','checkpoint','A2','b2c4824c-fa7e-5e47-b728-6f384b6deb92',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('36d7fb50-b4f2-5ae7-bb23-dbc57ec2fd59'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','reading','match',$p$Une cada participio italiano con su traducción.$p$,$j${"pairs": [{"en": "mangiato", "es": "comido"}, {"en": "parlato", "es": "hablado"}, {"en": "dormito", "es": "dormido"}]}$j$::jsonb,$j${"pairs": [["mangiato", "comido"], ["parlato", "hablado"], ["dormito", "dormido"]]}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$participi_regolari$p$, $p$reading$p$]),
('0e267772-d820-5dcd-9ccc-7bdeac919638'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','reading','match',$p$Une cada participio irregular con su traducción.$p$,$j${"pairs": [{"en": "fatto", "es": "hecho"}, {"en": "preso", "es": "tomado"}, {"en": "visto", "es": "visto"}]}$j$::jsonb,$j${"pairs": [["fatto", "hecho"], ["preso", "tomado"], ["visto", "visto"]]}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$participi_irregolari$p$, $p$reading$p$]),
('b9e7dacf-a8f1-557a-943f-dd7b44c64274'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','reading','multiple_choice',$p$¿Cuál es el participio pasado correcto del verbo 'finire' (terminar)?$p$,$j${"options": ["finito", "finuto", "finato"]}$j$::jsonb,$j${"value": "finito"}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$participi_regolari$p$, $p$reading$p$]),
('f017a903-37e3-5341-b101-94b08db0ac00'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','reading','multiple_choice',$p$Completa: 'Ieri io ___ parlato con Marco.' ¿Qué auxiliar es correcto?$p$,$j${"options": ["ho", "sono", "hai"]}$j$::jsonb,$j${"value": "ho"}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$passato_avere$p$, $p$reading$p$]),
('20de72fa-e918-5f33-8a11-fe84aa39ab69'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','reading','multiple_choice',$p$¿Cuál es el participio pasado correcto del verbo 'prendere' (tomar)?$p$,$j${"options": ["preso", "prenduto", "presato"]}$j$::jsonb,$j${"value": "preso"}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$participi_irregolari$p$, $p$reading$p$]),
('b49e452f-1660-54cf-8fcf-a48a6a7579b6'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','reading','multiple_choice',$p$Elige la frase correcta para decir 'No he hecho nada'.$p$,$j${"options": ["Non ho fatto niente.", "Non ho fatto qualcosa.", "Ho fatto niente."]}$j$::jsonb,$j${"value": "Non ho fatto niente."}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$negazione_passato$p$, $p$reading$p$]),
('6f75847e-ceb7-5590-9937-9b8f6ac7c3ed'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','writing','cloze',$p$Completa con el auxiliar: 'Ieri (io) ___ mangiato la pizza.'$p$,$j${"text": "Ieri ___ mangiato la pizza."}$j$::jsonb,$j${"value": "ho", "accepted": ["ho"]}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$passato_avere$p$, $p$writing$p$]),
('a0f37c93-964e-5f82-a213-5beb5d83e1e9'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','writing','cloze',$p$Completa la pregunta: 'Che cosa ___ fatto ieri?' (tú).$p$,$j${"text": "Che cosa ___ fatto ieri?"}$j$::jsonb,$j${"value": "hai", "accepted": ["hai"]}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$domande_passato$p$, $p$writing$p$]),
('7122c32b-6054-517b-a649-4873bf4b76e1'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','writing','translation',$p$Traduce: 'He comido la pizza.'$p$,$j${"source": "He comido la pizza."}$j$::jsonb,$j${"value": "Ho mangiato la pizza.", "accepted": ["Ho mangiato la pizza.", "Ho mangiato la pizza", "ho mangiato la pizza", "ho mangiato la pizza."]}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$passato_avere$p$, $p$writing$p$]),
('f6bd4181-4ed7-5f39-bd31-cd57e5c05c1a'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','writing','translation',$p$Traduce: 'Ayer he visto un film.'$p$,$j${"source": "Ayer he visto un film."}$j$::jsonb,$j${"value": "Ieri ho visto un film.", "accepted": ["Ieri ho visto un film.", "Ieri ho visto un film", "ieri ho visto un film", "ieri ho visto un film.", "Ieri ho visto un film.", "Ieri ho visto un film", "ieri ho visto un film"]}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$participi_irregolari$p$, $p$writing$p$]),
('00601f78-4431-51f8-9f9d-b7da620a46bf'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','writing','word_bank',$p$Ordena las fichas para decir 'La semana pasada trabajé mucho'.$p$,$j${"tiles": ["La", "settimana", "scorsa", "ho", "lavorato", "molto", "lavoro"]}$j$::jsonb,$j${"value": "La settimana scorsa ho lavorato molto", "sequence": ["La", "settimana", "scorsa", "ho", "lavorato", "molto"]}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$espressioni_tempo$p$, $p$writing$p$]),
('90bd5749-4008-518f-b151-f63786e869a9'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','writing','reorder',$p$Ordena las palabras para formar una frase correcta.$p$,$j${"tiles": ["letto", "un", "Ho", "libro", "bello"]}$j$::jsonb,$j${"value": "Ho letto un libro bello"}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$participi_irregolari$p$, $p$writing$p$]),
('4bb56b11-83d4-5ca7-8fa4-66c8e413c3ba'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ieri ho mangiato al ristorante.", "Ieri mangio al ristorante.", "Domani mangio al ristorante."], "say": "Ieri ho mangiato al ristorante.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/4bb56b11-83d4-5ca7-8fa4-66c8e413c3ba.mp3"}$j$::jsonb,$j${"value": "Ieri ho mangiato al ristorante."}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$passato_avere$p$, $p$listening$p$]),
('1ba1a211-de14-5f0c-958c-de31407094be'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ho fatto i compiti stamattina.", "Ho fatto i compiti stasera.", "Faccio i compiti stamattina."], "say": "Ho fatto i compiti stamattina.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/1ba1a211-de14-5f0c-958c-de31407094be.mp3"}$j$::jsonb,$j${"value": "Ho fatto i compiti stamattina."}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$participi_irregolari$p$, $p$listening$p$]),
('967ae3e5-160d-56e8-acf5-e8606bc6ed5f'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Abbiamo bevuto un caffè insieme.", "Abbiamo bevuto un tè insieme.", "Beviamo un caffè insieme."], "say": "Abbiamo bevuto un caffè insieme.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/967ae3e5-160d-56e8-acf5-e8606bc6ed5f.mp3"}$j$::jsonb,$j${"value": "Abbiamo bevuto un caffè insieme."}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$participi_irregolari$p$, $p$listening$p$]),
('8f552627-91b5-579f-a6f8-8ef02ea9c65e'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Hai finito i compiti?", "Hai iniziato i compiti?", "Finisci i compiti?"], "say": "Hai finito i compiti?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/8f552627-91b5-579f-a6f8-8ef02ea9c65e.mp3"}$j$::jsonb,$j${"value": "Hai finito i compiti?"}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$domande_passato$p$, $p$listening$p$]),
('6659a416-bfa9-5fcc-b6cf-d82003b9b86e'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Due giorni fa ho visto Maria.", "Due giorni fa vedo Maria.", "Ieri ho visto Maria."], "say": "Due giorni fa ho visto Maria.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/6659a416-bfa9-5fcc-b6cf-d82003b9b86e.mp3"}$j$::jsonb,$j${"value": "Due giorni fa ho visto Maria."}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$espressioni_tempo$p$, $p$listening$p$]),
('f800626c-9066-5f04-af3c-ae81ca0b4aee'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Ieri ho parlato con mia madre.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/f800626c-9066-5f04-af3c-ae81ca0b4aee.mp3"}$j$::jsonb,$j${"expected": "Ieri ho parlato con mia madre."}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$passato_avere$p$, $p$speaking$p$]),
('6d4ed2dc-94e9-5969-855a-2daaaebee80f'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Ho scritto una lettera a Luca.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/6d4ed2dc-94e9-5969-855a-2daaaebee80f.mp3"}$j$::jsonb,$j${"expected": "Ho scritto una lettera a Luca."}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$participi_irregolari$p$, $p$speaking$p$]),
('ab2f8635-bd5e-5d41-a9c7-0416c91e81ec'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Non ho ancora finito il lavoro.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/ab2f8635-bd5e-5d41-a9c7-0416c91e81ec.mp3"}$j$::jsonb,$j${"expected": "Non ho ancora finito il lavoro."}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$negazione_passato$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('6d49c197-8307-5182-b05f-396ee95c7d6e','36d7fb50-b4f2-5ae7-bb23-dbc57ec2fd59',1),
 ('6d49c197-8307-5182-b05f-396ee95c7d6e','b9e7dacf-a8f1-557a-943f-dd7b44c64274',2),
 ('6d49c197-8307-5182-b05f-396ee95c7d6e','f017a903-37e3-5341-b101-94b08db0ac00',3),
 ('6d49c197-8307-5182-b05f-396ee95c7d6e','6f75847e-ceb7-5590-9937-9b8f6ac7c3ed',4),
 ('6d49c197-8307-5182-b05f-396ee95c7d6e','7122c32b-6054-517b-a649-4873bf4b76e1',5),
 ('6d49c197-8307-5182-b05f-396ee95c7d6e','4bb56b11-83d4-5ca7-8fa4-66c8e413c3ba',6),
 ('6d49c197-8307-5182-b05f-396ee95c7d6e','f800626c-9066-5f04-af3c-ae81ca0b4aee',7),
 ('a783c7c5-b9d2-5799-8540-ba7ba7604885','0e267772-d820-5dcd-9ccc-7bdeac919638',1),
 ('a783c7c5-b9d2-5799-8540-ba7ba7604885','20de72fa-e918-5f33-8a11-fe84aa39ab69',2),
 ('a783c7c5-b9d2-5799-8540-ba7ba7604885','f6bd4181-4ed7-5f39-bd31-cd57e5c05c1a',3),
 ('a783c7c5-b9d2-5799-8540-ba7ba7604885','90bd5749-4008-518f-b151-f63786e869a9',4),
 ('a783c7c5-b9d2-5799-8540-ba7ba7604885','1ba1a211-de14-5f0c-958c-de31407094be',5),
 ('a783c7c5-b9d2-5799-8540-ba7ba7604885','967ae3e5-160d-56e8-acf5-e8606bc6ed5f',6),
 ('a783c7c5-b9d2-5799-8540-ba7ba7604885','6d4ed2dc-94e9-5969-855a-2daaaebee80f',7),
 ('d545d901-af98-593f-922b-c81c62a3c2b0','b49e452f-1660-54cf-8fcf-a48a6a7579b6',1),
 ('d545d901-af98-593f-922b-c81c62a3c2b0','a0f37c93-964e-5f82-a213-5beb5d83e1e9',2),
 ('d545d901-af98-593f-922b-c81c62a3c2b0','8f552627-91b5-579f-a6f8-8ef02ea9c65e',3),
 ('d545d901-af98-593f-922b-c81c62a3c2b0','ab2f8635-bd5e-5d41-a9c7-0416c91e81ec',4),
 ('c7846cad-c452-51d0-b9ec-ff0e682ea28d','00601f78-4431-51f8-9f9d-b7da620a46bf',1),
 ('c7846cad-c452-51d0-b9ec-ff0e682ea28d','6659a416-bfa9-5fcc-b6cf-d82003b9b86e',2),
 ('9719d3f9-a989-5b4b-9dc9-3c4efa39a81b','36d7fb50-b4f2-5ae7-bb23-dbc57ec2fd59',1),
 ('9719d3f9-a989-5b4b-9dc9-3c4efa39a81b','0e267772-d820-5dcd-9ccc-7bdeac919638',2),
 ('9719d3f9-a989-5b4b-9dc9-3c4efa39a81b','b9e7dacf-a8f1-557a-943f-dd7b44c64274',3),
 ('9719d3f9-a989-5b4b-9dc9-3c4efa39a81b','6f75847e-ceb7-5590-9937-9b8f6ac7c3ed',4),
 ('9719d3f9-a989-5b4b-9dc9-3c4efa39a81b','a0f37c93-964e-5f82-a213-5beb5d83e1e9',5),
 ('9719d3f9-a989-5b4b-9dc9-3c4efa39a81b','7122c32b-6054-517b-a649-4873bf4b76e1',6),
 ('9719d3f9-a989-5b4b-9dc9-3c4efa39a81b','4bb56b11-83d4-5ca7-8fa4-66c8e413c3ba',7),
 ('9719d3f9-a989-5b4b-9dc9-3c4efa39a81b','1ba1a211-de14-5f0c-958c-de31407094be',8),
 ('9719d3f9-a989-5b4b-9dc9-3c4efa39a81b','f800626c-9066-5f04-af3c-ae81ca0b4aee',9),
 ('9719d3f9-a989-5b4b-9dc9-3c4efa39a81b','6d4ed2dc-94e9-5969-855a-2daaaebee80f',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('f178a441-40ca-5385-a9ab-14c83b8c537a','20000000-0000-0000-0000-000000000004',$p$ieri$p$,$p$ayer$p$,241,'adverbio'),
 ('050ca65f-028b-586e-acc6-1917a223b066','20000000-0000-0000-0000-000000000004',$p$mangiato$p$,$p$comido$p$,242,'verbo'),
 ('2fa15c6e-70c0-5574-bc4b-9f309016a8e3','20000000-0000-0000-0000-000000000004',$p$parlato$p$,$p$hablado$p$,243,'verbo'),
 ('5238cc7b-508e-5267-83d3-ce97c09a949a','20000000-0000-0000-0000-000000000004',$p$finito$p$,$p$terminado$p$,244,'verbo'),
 ('0e5073da-7cf9-5b38-93cc-2a1f9164e6c7','20000000-0000-0000-0000-000000000004',$p$dormito$p$,$p$dormido$p$,245,'verbo'),
 ('6dc29ea7-1542-5275-a0d3-98805b57267e','20000000-0000-0000-0000-000000000004',$p$fatto$p$,$p$hecho$p$,246,'verbo'),
 ('f567d989-8230-57f3-9044-bbdf58050133','20000000-0000-0000-0000-000000000004',$p$preso$p$,$p$tomado / cogido$p$,247,'verbo'),
 ('79a1e97c-7378-5c46-af01-cca646f2fee2','20000000-0000-0000-0000-000000000004',$p$visto$p$,$p$visto$p$,248,'verbo'),
 ('1404b337-abc8-55b3-a5d3-63f52912576f','20000000-0000-0000-0000-000000000004',$p$letto$p$,$p$leído$p$,249,'verbo'),
 ('f7e68ce4-9cd4-5a08-8b00-d488e44b6224','20000000-0000-0000-0000-000000000004',$p$scritto$p$,$p$escrito$p$,250,'verbo'),
 ('ede9bc33-d7af-5f41-8bcb-b3920a363e2c','20000000-0000-0000-0000-000000000004',$p$bevuto$p$,$p$bebido$p$,251,'verbo'),
 ('00955b1a-b7e7-5d96-bcc6-e1f2716ffe52','20000000-0000-0000-0000-000000000004',$p$detto$p$,$p$dicho$p$,252,'verbo'),
 ('92d8fb96-5d64-53e5-94d4-3c816ad74dc6','20000000-0000-0000-0000-000000000004',$p$la settimana scorsa$p$,$p$la semana pasada$p$,253,'expresion'),
 ('b8a23b03-5d0b-5be9-9085-b3d920cc4e78','20000000-0000-0000-0000-000000000004',$p$il weekend scorso$p$,$p$el fin de semana pasado$p$,254,'expresion'),
 ('5e5ea65c-c024-561b-82cc-fb327b8b63e6','20000000-0000-0000-0000-000000000004',$p$due giorni fa$p$,$p$hace dos días$p$,255,'expresion'),
 ('b86d2eeb-288b-59bc-ac28-e9a4f8a58a01','20000000-0000-0000-0000-000000000004',$p$niente$p$,$p$nada$p$,256,'pronombre')
on conflict (id) do nothing;

-- ── Unidad 8 (A2·it): Planes y futuro ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('47c916d2-4241-5161-b3fb-29790cee2fed','20000000-0000-0000-0000-000000000004','A2',8,$p$Planes y futuro$p$,'#2C3E50','event_available')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('adc1fe9c-4c30-51cc-9d17-c1058495d0f6','47c916d2-4241-5161-b3fb-29790cee2fed',1,$p$El futuro semplice regular$p$,$p$El futuro semplice regular$p$,'lesson',15),
 ('aad89d7d-434c-56ed-b25c-f60cb5cafe0a','47c916d2-4241-5161-b3fb-29790cee2fed',2,$p$Futuros irregulares: sarò, avrò, andrò$p$,$p$Futuros irregulares: sarò, avrò, andrò$p$,'lesson',15),
 ('6e235fee-7191-5378-9524-a10c7b862285','47c916d2-4241-5161-b3fb-29790cee2fed',3,$p$Estar a punto de: stare per$p$,$p$Estar a punto de: stare per$p$,'lesson',15),
 ('2fc7d070-d756-52d4-b99e-45468f4bad9b','47c916d2-4241-5161-b3fb-29790cee2fed',4,$p$Mañana, la próxima semana: cuándo$p$,$p$Mañana, la próxima semana: cuándo$p$,'lesson',15),
 ('9aa33ce3-b524-5a00-bc7b-19d91d1175e2','47c916d2-4241-5161-b3fb-29790cee2fed',5,$p$🏁 Checkpoint Unità 8$p$,$p$Demuestra que sabes hablar de planes y del futuro con el futuro semplice y 'stare per'.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('d0908c42-664f-5d35-ab22-54f539cdb98e','20000000-0000-0000-0000-000000000004','checkpoint','A2','47c916d2-4241-5161-b3fb-29790cee2fed',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('9acea81b-586d-553f-8aa4-6c7765d2525c'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','reading','match',$p$Une cada verbo en futuro con su traducción.$p$,$j${"pairs": [{"en": "parlerò", "es": "hablaré"}, {"en": "finirò", "es": "terminaré"}, {"en": "partirò", "es": "partiré"}]}$j$::jsonb,$j${"pairs": [["parlerò", "hablaré"], ["finirò", "terminaré"], ["partirò", "partiré"]]}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$futuro_regolare$p$, $p$reading$p$]),
('2076e5f9-6ce1-5d5f-a680-32170d1fae31'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','reading','match',$p$Une cada futuro irregular con su traducción.$p$,$j${"pairs": [{"en": "sarò", "es": "seré"}, {"en": "avrò", "es": "tendré"}, {"en": "andrò", "es": "iré"}]}$j$::jsonb,$j${"pairs": [["sarò", "seré"], ["avrò", "tendré"], ["andrò", "iré"]]}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$futuro_irregolare$p$, $p$reading$p$]),
('d64c28fb-49d9-50f8-9ae1-7be380dae30f'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','reading','multiple_choice',$p$¿Cuál es el futuro correcto de 'mangiare' (comer) en primera persona? Ojo con la ortografía.$p$,$j${"options": ["mangerò", "mangierò", "mangiarò"]}$j$::jsonb,$j${"value": "mangerò"}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$futuro_regolare$p$, $p$reading$p$]),
('84596a61-331f-545e-9d55-a14344f944fa'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','reading','multiple_choice',$p$Completa: 'Domani ___ al mare con gli amici.' (io, andare)$p$,$j${"options": ["andrò", "anderò", "andarò"]}$j$::jsonb,$j${"value": "andrò"}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$futuro_irregolare$p$, $p$reading$p$]),
('f53324c3-b276-5fd7-bf9d-533683527885'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','reading','multiple_choice',$p$¿Cuál es el futuro correcto de 'venire' (venir) en primera persona?$p$,$j${"options": ["verrò", "venirò", "venerò"]}$j$::jsonb,$j${"value": "verrò"}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$futuro_irregolare$p$, $p$reading$p$]),
('41caac01-7cda-5754-8d24-0ab93501ea54'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','reading','multiple_choice',$p$Elige la frase correcta para decir 'Estoy a punto de salir'.$p$,$j${"options": ["Sto per uscire.", "Sto per uscito.", "Sto uscire."]}$j$::jsonb,$j${"value": "Sto per uscire."}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$stare_per$p$, $p$reading$p$]),
('fd02777a-2137-5c3f-8492-35a72b73788f'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','writing','cloze',$p$Completa con el futuro de 'comprare': 'Domani (io) ___ una macchina nuova.'$p$,$j${"text": "Domani ___ una macchina nuova."}$j$::jsonb,$j${"value": "comprerò", "accepted": ["comprerò", "comprero"]}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$futuro_regolare$p$, $p$writing$p$]),
('f9777395-5f04-5578-be1f-871374662c3e'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','writing','cloze',$p$Completa con el futuro de 'avere': 'Quando ___ tempo, ti chiamerò.' (io)$p$,$j${"text": "Quando ___ tempo, ti chiamerò."}$j$::jsonb,$j${"value": "avrò", "accepted": ["avrò", "avro"]}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$futuro_irregolare$p$, $p$writing$p$]),
('45b62ebe-05b9-520c-85f5-9ba23fa2d67f'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','writing','translation',$p$Traduce: 'Mañana hablaré con el profesor.'$p$,$j${"source": "Mañana hablaré con el profesor."}$j$::jsonb,$j${"value": "Domani parlerò con il professore.", "accepted": ["Domani parlerò con il professore.", "Domani parlerò con il professore", "domani parlerò con il professore", "domani parlero con il professore", "Domani parlero con il professore", "domani parlerò con il professore."]}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$futuro_regolare$p$, $p$writing$p$]),
('72ee0c49-4ace-5942-b793-0e90750e7142'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','writing','translation',$p$Traduce: 'La próxima semana iré a Roma.'$p$,$j${"source": "La próxima semana iré a Roma."}$j$::jsonb,$j${"value": "La prossima settimana andrò a Roma.", "accepted": ["La prossima settimana andrò a Roma.", "La prossima settimana andrò a Roma", "la prossima settimana andrò a Roma", "la prossima settimana andro a Roma", "La prossima settimana andro a Roma", "la prossima settimana andrò a Roma."]}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$espressioni_futuro$p$, $p$writing$p$]),
('ec33b1e4-f80c-5b82-9b48-a735cdfc36da'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','writing','word_bank',$p$Ordena las fichas para formar: 'El tren está a punto de salir.'$p$,$j${"tiles": ["Il", "treno", "sta", "per", "partire", "parte", "partito"]}$j$::jsonb,$j${"value": "Il treno sta per partire", "sequence": ["Il", "treno", "sta", "per", "partire"]}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$stare_per$p$, $p$writing$p$]),
('051e1b40-dfcc-549d-b2c0-8a79f9559f00'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','writing','reorder',$p$Ordena las palabras para formar una frase correcta.$p$,$j${"tiles": ["farò", "cosa", "Che", "domani", "?"]}$j$::jsonb,$j${"value": "Che cosa farò domani ?"}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$futuro_irregolare$p$, $p$writing$p$]),
('4f1a92bf-9cce-516d-8bfd-7f36a6c87b1e'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Domani finirò questo lavoro.", "Domani finisco questo lavoro.", "Ieri ho finito questo lavoro."], "say": "Domani finirò questo lavoro.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/4f1a92bf-9cce-516d-8bfd-7f36a6c87b1e.mp3"}$j$::jsonb,$j${"value": "Domani finirò questo lavoro."}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$futuro_regolare$p$, $p$listening$p$]),
('6b858712-9b2a-5e1c-977f-d0d6ee0051b8'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["L'anno prossimo sarò a Milano.", "L'anno prossimo sono a Milano.", "L'anno scorso ero a Milano."], "say": "L'anno prossimo sarò a Milano.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/6b858712-9b2a-5e1c-977f-d0d6ee0051b8.mp3"}$j$::jsonb,$j${"value": "L'anno prossimo sarò a Milano."}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$futuro_irregolare$p$, $p$listening$p$]),
('4918f34b-708e-5813-8174-b94a8202c3a1'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Sto per uscire di casa.", "Sono uscito di casa.", "Esco di casa adesso."], "say": "Sto per uscire di casa.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/4918f34b-708e-5813-8174-b94a8202c3a1.mp3"}$j$::jsonb,$j${"value": "Sto per uscire di casa."}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$stare_per$p$, $p$listening$p$]),
('5b7aaa93-207d-5904-a0c3-b382dbe9d2d7'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Dopodomani verrò a trovarti.", "Dopodomani vengo a trovarti.", "Domani verrò a trovarti."], "say": "Dopodomani verrò a trovarti.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/5b7aaa93-207d-5904-a0c3-b382dbe9d2d7.mp3"}$j$::jsonb,$j${"value": "Dopodomani verrò a trovarti."}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$espressioni_futuro$p$, $p$listening$p$]),
('6dd41191-d0e8-5493-a0b9-9b7469b77267'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Domani mangerò a casa dei miei.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/6dd41191-d0e8-5493-a0b9-9b7469b77267.mp3"}$j$::jsonb,$j${"expected": "Domani mangerò a casa dei miei."}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$futuro_regolare$p$, $p$speaking$p$]),
('6f5e30a0-8a6f-5a3e-a0f5-406a61ca1a88'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Quando avrò tempo, farò un viaggio.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/6f5e30a0-8a6f-5a3e-a0f5-406a61ca1a88.mp3"}$j$::jsonb,$j${"expected": "Quando avrò tempo, farò un viaggio."}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$futuro_irregolare$p$, $p$speaking$p$]),
('80ddbb28-84c2-520f-84fc-d0ed0e0b47c3'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Sto per finire i compiti.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/80ddbb28-84c2-520f-84fc-d0ed0e0b47c3.mp3"}$j$::jsonb,$j${"expected": "Sto per finire i compiti."}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$stare_per$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('adc1fe9c-4c30-51cc-9d17-c1058495d0f6','9acea81b-586d-553f-8aa4-6c7765d2525c',1),
 ('adc1fe9c-4c30-51cc-9d17-c1058495d0f6','d64c28fb-49d9-50f8-9ae1-7be380dae30f',2),
 ('adc1fe9c-4c30-51cc-9d17-c1058495d0f6','fd02777a-2137-5c3f-8492-35a72b73788f',3),
 ('adc1fe9c-4c30-51cc-9d17-c1058495d0f6','45b62ebe-05b9-520c-85f5-9ba23fa2d67f',4),
 ('adc1fe9c-4c30-51cc-9d17-c1058495d0f6','4f1a92bf-9cce-516d-8bfd-7f36a6c87b1e',5),
 ('adc1fe9c-4c30-51cc-9d17-c1058495d0f6','6dd41191-d0e8-5493-a0b9-9b7469b77267',6),
 ('aad89d7d-434c-56ed-b25c-f60cb5cafe0a','2076e5f9-6ce1-5d5f-a680-32170d1fae31',1),
 ('aad89d7d-434c-56ed-b25c-f60cb5cafe0a','84596a61-331f-545e-9d55-a14344f944fa',2),
 ('aad89d7d-434c-56ed-b25c-f60cb5cafe0a','f53324c3-b276-5fd7-bf9d-533683527885',3),
 ('aad89d7d-434c-56ed-b25c-f60cb5cafe0a','f9777395-5f04-5578-be1f-871374662c3e',4),
 ('aad89d7d-434c-56ed-b25c-f60cb5cafe0a','051e1b40-dfcc-549d-b2c0-8a79f9559f00',5),
 ('aad89d7d-434c-56ed-b25c-f60cb5cafe0a','6b858712-9b2a-5e1c-977f-d0d6ee0051b8',6),
 ('aad89d7d-434c-56ed-b25c-f60cb5cafe0a','6f5e30a0-8a6f-5a3e-a0f5-406a61ca1a88',7),
 ('6e235fee-7191-5378-9524-a10c7b862285','41caac01-7cda-5754-8d24-0ab93501ea54',1),
 ('6e235fee-7191-5378-9524-a10c7b862285','ec33b1e4-f80c-5b82-9b48-a735cdfc36da',2),
 ('6e235fee-7191-5378-9524-a10c7b862285','4918f34b-708e-5813-8174-b94a8202c3a1',3),
 ('6e235fee-7191-5378-9524-a10c7b862285','80ddbb28-84c2-520f-84fc-d0ed0e0b47c3',4),
 ('2fc7d070-d756-52d4-b99e-45468f4bad9b','72ee0c49-4ace-5942-b793-0e90750e7142',1),
 ('2fc7d070-d756-52d4-b99e-45468f4bad9b','5b7aaa93-207d-5904-a0c3-b382dbe9d2d7',2),
 ('9aa33ce3-b524-5a00-bc7b-19d91d1175e2','9acea81b-586d-553f-8aa4-6c7765d2525c',1),
 ('9aa33ce3-b524-5a00-bc7b-19d91d1175e2','2076e5f9-6ce1-5d5f-a680-32170d1fae31',2),
 ('9aa33ce3-b524-5a00-bc7b-19d91d1175e2','d64c28fb-49d9-50f8-9ae1-7be380dae30f',3),
 ('9aa33ce3-b524-5a00-bc7b-19d91d1175e2','fd02777a-2137-5c3f-8492-35a72b73788f',4),
 ('9aa33ce3-b524-5a00-bc7b-19d91d1175e2','f9777395-5f04-5578-be1f-871374662c3e',5),
 ('9aa33ce3-b524-5a00-bc7b-19d91d1175e2','45b62ebe-05b9-520c-85f5-9ba23fa2d67f',6),
 ('9aa33ce3-b524-5a00-bc7b-19d91d1175e2','4f1a92bf-9cce-516d-8bfd-7f36a6c87b1e',7),
 ('9aa33ce3-b524-5a00-bc7b-19d91d1175e2','6b858712-9b2a-5e1c-977f-d0d6ee0051b8',8),
 ('9aa33ce3-b524-5a00-bc7b-19d91d1175e2','6dd41191-d0e8-5493-a0b9-9b7469b77267',9),
 ('9aa33ce3-b524-5a00-bc7b-19d91d1175e2','6f5e30a0-8a6f-5a3e-a0f5-406a61ca1a88',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('fcfefb8c-a3e6-5e7d-a65a-86e464a3a8a6','20000000-0000-0000-0000-000000000004',$p$domani$p$,$p$mañana$p$,261,'adverbio'),
 ('21414bd8-90d2-5f01-9f59-5f0cfd36ecdc','20000000-0000-0000-0000-000000000004',$p$dopodomani$p$,$p$pasado mañana$p$,262,'adverbio'),
 ('767fff56-f4ee-5b1d-8b66-cd15a71bd83e','20000000-0000-0000-0000-000000000004',$p$presto$p$,$p$pronto$p$,263,'adverbio'),
 ('02f423b4-0f7e-5ee6-8029-aa18548e46bc','20000000-0000-0000-0000-000000000004',$p$la prossima settimana$p$,$p$la próxima semana$p$,264,'expresion'),
 ('982265af-54a0-5997-b8b2-c4ccdbc24a69','20000000-0000-0000-0000-000000000004',$p$l'anno prossimo$p$,$p$el año que viene$p$,265,'expresion'),
 ('c2de7dbd-899b-5e39-8ad1-3ea83dc3afc1','20000000-0000-0000-0000-000000000004',$p$parlerò$p$,$p$hablaré$p$,266,'verbo'),
 ('361d3350-7a32-5dea-933c-6d11eb62892d','20000000-0000-0000-0000-000000000004',$p$finirò$p$,$p$terminaré$p$,267,'verbo'),
 ('e0e9ae2b-df60-5555-9872-17689fe1ead3','20000000-0000-0000-0000-000000000004',$p$mangerò$p$,$p$comeré$p$,268,'verbo'),
 ('e925d765-fdfe-5527-a4f1-d68981efd67d','20000000-0000-0000-0000-000000000004',$p$comprerò$p$,$p$compraré$p$,269,'verbo'),
 ('facc8529-a182-578f-958e-d271d730e0e5','20000000-0000-0000-0000-000000000004',$p$sarò$p$,$p$seré / estaré$p$,270,'verbo'),
 ('50ab0106-85fd-50db-afbd-6307676ade48','20000000-0000-0000-0000-000000000004',$p$avrò$p$,$p$tendré$p$,271,'verbo'),
 ('70909b54-5da5-5e3f-944b-2f7673e6c022','20000000-0000-0000-0000-000000000004',$p$andrò$p$,$p$iré$p$,272,'verbo'),
 ('89ffd346-35a1-51da-b84b-07f05185512b','20000000-0000-0000-0000-000000000004',$p$farò$p$,$p$haré$p$,273,'verbo'),
 ('7e31a169-ee0d-5874-88ea-bc2d93b2bf6a','20000000-0000-0000-0000-000000000004',$p$verrò$p$,$p$vendré$p$,274,'verbo'),
 ('7696d9f9-6f6f-51f0-a8c9-1b04886c98da','20000000-0000-0000-0000-000000000004',$p$potrò$p$,$p$podré$p$,275,'verbo'),
 ('e7018333-07f6-5455-ba4c-ef12ed2ea983','20000000-0000-0000-0000-000000000004',$p$stare per$p$,$p$estar a punto de$p$,276,'expresion')
on conflict (id) do nothing;

-- ── Unidad 9 (A2·it): De viaje ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('c7681d3d-fe85-5a77-8d2e-9a13db1c55cf','20000000-0000-0000-0000-000000000004','A2',9,$p$De viaje$p$,'#16A085','flight_takeoff')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('3d9e4a91-3970-591c-b11a-f801bd7b2eab','c7681d3d-fe85-5a77-8d2e-9a13db1c55cf',1,$p$Passato prossimo con essere$p$,$p$Passato prossimo con essere$p$,'lesson',15),
 ('e8ff1971-618d-5688-a323-38d22f086bf5','c7681d3d-fe85-5a77-8d2e-9a13db1c55cf',2,$p$La concordancia del participio$p$,$p$La concordancia del participio$p$,'lesson',15),
 ('76f9732c-6f81-5469-add1-dc89ea078069','c7681d3d-fe85-5a77-8d2e-9a13db1c55cf',3,$p$En la estación y el aeropuerto$p$,$p$En la estación y el aeropuerto$p$,'lesson',15),
 ('1d1ff562-a95b-5745-a9d8-733834dc4c71','c7681d3d-fe85-5a77-8d2e-9a13db1c55cf',4,$p$¡Buen viaje!$p$,$p$¡Buen viaje!$p$,'lesson',15),
 ('f2184b16-0616-5931-8e54-d5cae7950c36','c7681d3d-fe85-5a77-8d2e-9a13db1c55cf',5,$p$🏁 Checkpoint Unità 9$p$,$p$Cuenta un viaje en pasado con essere y la concordancia del participio.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('b80fc4f9-0792-5a54-9a4d-4df20c6fe6ca','20000000-0000-0000-0000-000000000004','checkpoint','A2','c7681d3d-fe85-5a77-8d2e-9a13db1c55cf',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('09cb9a6f-a9d5-5603-ae7b-e7f1d2752931'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','reading','match',$p$Une cada palabra italiana con su traducción.$p$,$j${"pairs": [{"en": "il treno", "es": "el tren"}, {"en": "l'albergo", "es": "el hotel"}, {"en": "la valigia", "es": "la maleta"}]}$j$::jsonb,$j${"pairs": [["il treno", "el tren"], ["l'albergo", "el hotel"], ["la valigia", "la maleta"]]}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$vocab_viaggio$p$, $p$reading$p$]),
('9679a0e2-b6bf-5ce7-8938-19b85932bd35'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','reading','match',$p$Une cada palabra italiana con su traducción.$p$,$j${"pairs": [{"en": "la stazione", "es": "la estación"}, {"en": "il biglietto", "es": "el billete"}, {"en": "l'aereo", "es": "el avión"}]}$j$::jsonb,$j${"pairs": [["la stazione", "la estación"], ["il biglietto", "el billete"], ["l'aereo", "el avión"]]}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$vocab_viaggio$p$, $p$reading$p$]),
('b62cd557-2a1e-5730-8c94-ea84c777cea8'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','reading','multiple_choice',$p$¿Cuál es el auxiliar correcto? 'Ieri io ___ andato a Roma.'$p$,$j${"options": ["sono", "ho", "sto"]}$j$::jsonb,$j${"value": "sono"}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$essere_aux$p$, $p$reading$p$]),
('cc9da4ba-b6d3-586d-a25d-6ef8b92459c7'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','reading','multiple_choice',$p$Maria habla de sí misma. Elige la forma correcta:$p$,$j${"options": ["Sono partita alle otto.", "Sono partito alle otto.", "Ho partita alle otto."]}$j$::jsonb,$j${"value": "Sono partita alle otto."}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$concordanza$p$, $p$reading$p$]),
('b98c892c-240c-5eda-b5e8-bba7d1791d26'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','reading','multiple_choice',$p$Las chicas (le ragazze) hablan. Elige la forma correcta:$p$,$j${"options": ["Siamo arrivate ieri.", "Siamo arrivati ieri.", "Siamo arrivato ieri."]}$j$::jsonb,$j${"value": "Siamo arrivate ieri."}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$concordanza$p$, $p$reading$p$]),
('3987d8f9-caaa-567d-b6f6-56ddf23bcdd6'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','reading','multiple_choice',$p$¿Qué se dice a alguien que se va de viaje?$p$,$j${"options": ["Buon viaggio!", "Buon appetito!", "Buona notte!"]}$j$::jsonb,$j${"value": "Buon viaggio!"}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$vocab_viaggio$p$, $p$reading$p$]),
('3f1d8f64-8967-5fc2-a5de-687afb2cb3be'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','writing','cloze',$p$Completa con el auxiliar de 'andare' (io, masculino): 'Ieri ___ andato in centro.'$p$,$j${"text": "Ieri ___ andato in centro."}$j$::jsonb,$j${"value": "sono", "accepted": ["sono"]}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$essere_aux$p$, $p$writing$p$]),
('90cf04ae-e15d-5655-bdfe-613d5ece9de2'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','writing','cloze',$p$Concuerda el participio. Lucia dice: 'Ieri sono andat___ a Firenze.'$p$,$j${"text": "Ieri sono andat___ a Firenze."}$j$::jsonb,$j${"value": "a", "accepted": ["a"]}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$concordanza$p$, $p$writing$p$]),
('e3e88843-b196-5140-93d3-d35478b538a7'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','writing','translation',$p$Traduce: 'Ella ha ido a Roma.'$p$,$j${"source": "Ella ha ido a Roma."}$j$::jsonb,$j${"value": "Lei è andata a Roma.", "accepted": ["Lei è andata a Roma.", "Lei è andata a Roma", "Lei e andata a Roma", "È andata a Roma.", "È andata a Roma", "E andata a Roma"]}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$concordanza$p$, $p$writing$p$]),
('3d54506f-96e4-5c09-815d-6253992d0502'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','writing','translation',$p$Traduce: 'El tren ha llegado con retraso.'$p$,$j${"source": "El tren ha llegado con retraso."}$j$::jsonb,$j${"value": "Il treno è arrivato in ritardo.", "accepted": ["Il treno è arrivato in ritardo.", "Il treno è arrivato in ritardo", "Il treno e arrivato in ritardo"]}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$vocab_viaggio$p$, $p$writing$p$]),
('a27e69bb-53aa-5404-9698-d8c24e73f823'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','writing','word_bank',$p$Ordena las fichas: 'Hemos reservado el hotel.'$p$,$j${"tiles": ["Abbiamo", "prenotato", "l'albergo", "prenotata", "partito"]}$j$::jsonb,$j${"value": "Abbiamo prenotato l'albergo", "sequence": ["Abbiamo", "prenotato", "l'albergo"]}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$vocab_viaggio$p$, $p$writing$p$]),
('0c3e0fb7-a80a-5ae3-9fb6-234116b6a61e'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','writing','reorder',$p$Ordena la frase: 'Ellos han salido temprano.'$p$,$j${"tiles": ["presto", "partiti", "Loro", "sono"]}$j$::jsonb,$j${"value": "Loro sono partiti presto"}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$concordanza$p$, $p$writing$p$]),
('8b18ce86-75c2-5cfa-a8b1-894094bfbc06'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Sono tornato a casa tardi.", "Sono tornato a scuola tardi.", "Sono andato a casa tardi."], "say": "Sono tornato a casa tardi.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/8b18ce86-75c2-5cfa-a8b1-894094bfbc06.mp3"}$j$::jsonb,$j${"value": "Sono tornato a casa tardi."}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$essere_aux$p$, $p$listening$p$]),
('d44272ec-59a9-51b6-bf78-3c96f916c368'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Le ragazze sono venute in treno.", "Le ragazze sono venute in aereo.", "I ragazzi sono venuti in treno."], "say": "Le ragazze sono venute in treno.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/d44272ec-59a9-51b6-bf78-3c96f916c368.mp3"}$j$::jsonb,$j${"value": "Le ragazze sono venute in treno."}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$concordanza$p$, $p$listening$p$]),
('2d9ea70a-50a3-5132-b565-e7f7f87272dd'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["L'aereo è partito in orario.", "L'aereo è partito in ritardo.", "Il treno è partito in orario."], "say": "L'aereo è partito in orario.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/2d9ea70a-50a3-5132-b565-e7f7f87272dd.mp3"}$j$::jsonb,$j${"value": "L'aereo è partito in orario."}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$vocab_viaggio$p$, $p$listening$p$]),
('30a56ec5-6d5d-5375-8917-f173d2d37bcc'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Siamo rimasti tre giorni a Venezia.", "Siamo rimasti tre giorni a Roma.", "Siamo rimaste tre giorni a Venezia."], "say": "Siamo rimasti tre giorni a Venezia.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/30a56ec5-6d5d-5375-8917-f173d2d37bcc.mp3"}$j$::jsonb,$j${"value": "Siamo rimasti tre giorni a Venezia."}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$vocab_viaggio$p$, $p$listening$p$]),
('59e987e4-861f-50b6-928a-efd0ac448bce'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Sono andato in stazione.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/59e987e4-861f-50b6-928a-efd0ac448bce.mp3"}$j$::jsonb,$j${"expected": "Sono andato in stazione."}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$essere_aux$p$, $p$speaking$p$]),
('7a6e6724-7b94-51ef-8b6e-c5ba7f7c12aa'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Lei è partita per Milano.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/7a6e6724-7b94-51ef-8b6e-c5ba7f7c12aa.mp3"}$j$::jsonb,$j${"expected": "Lei è partita per Milano."}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$concordanza$p$, $p$speaking$p$]),
('f29b4f06-bc5f-5a1d-b3e6-6b8f907cf28a'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Buon viaggio! A presto!", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/f29b4f06-bc5f-5a1d-b3e6-6b8f907cf28a.mp3"}$j$::jsonb,$j${"expected": "Buon viaggio! A presto!"}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$vocab_viaggio$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('3d9e4a91-3970-591c-b11a-f801bd7b2eab','09cb9a6f-a9d5-5603-ae7b-e7f1d2752931',1),
 ('3d9e4a91-3970-591c-b11a-f801bd7b2eab','b62cd557-2a1e-5730-8c94-ea84c777cea8',2),
 ('3d9e4a91-3970-591c-b11a-f801bd7b2eab','3f1d8f64-8967-5fc2-a5de-687afb2cb3be',3),
 ('3d9e4a91-3970-591c-b11a-f801bd7b2eab','8b18ce86-75c2-5cfa-a8b1-894094bfbc06',4),
 ('3d9e4a91-3970-591c-b11a-f801bd7b2eab','59e987e4-861f-50b6-928a-efd0ac448bce',5),
 ('e8ff1971-618d-5688-a323-38d22f086bf5','cc9da4ba-b6d3-586d-a25d-6ef8b92459c7',1),
 ('e8ff1971-618d-5688-a323-38d22f086bf5','b98c892c-240c-5eda-b5e8-bba7d1791d26',2),
 ('e8ff1971-618d-5688-a323-38d22f086bf5','90cf04ae-e15d-5655-bdfe-613d5ece9de2',3),
 ('e8ff1971-618d-5688-a323-38d22f086bf5','e3e88843-b196-5140-93d3-d35478b538a7',4),
 ('e8ff1971-618d-5688-a323-38d22f086bf5','0c3e0fb7-a80a-5ae3-9fb6-234116b6a61e',5),
 ('e8ff1971-618d-5688-a323-38d22f086bf5','d44272ec-59a9-51b6-bf78-3c96f916c368',6),
 ('e8ff1971-618d-5688-a323-38d22f086bf5','7a6e6724-7b94-51ef-8b6e-c5ba7f7c12aa',7),
 ('76f9732c-6f81-5469-add1-dc89ea078069','9679a0e2-b6bf-5ce7-8938-19b85932bd35',1),
 ('76f9732c-6f81-5469-add1-dc89ea078069','3d54506f-96e4-5c09-815d-6253992d0502',2),
 ('76f9732c-6f81-5469-add1-dc89ea078069','a27e69bb-53aa-5404-9698-d8c24e73f823',3),
 ('76f9732c-6f81-5469-add1-dc89ea078069','2d9ea70a-50a3-5132-b565-e7f7f87272dd',4),
 ('1d1ff562-a95b-5745-a9d8-733834dc4c71','3987d8f9-caaa-567d-b6f6-56ddf23bcdd6',1),
 ('1d1ff562-a95b-5745-a9d8-733834dc4c71','30a56ec5-6d5d-5375-8917-f173d2d37bcc',2),
 ('1d1ff562-a95b-5745-a9d8-733834dc4c71','f29b4f06-bc5f-5a1d-b3e6-6b8f907cf28a',3),
 ('f2184b16-0616-5931-8e54-d5cae7950c36','09cb9a6f-a9d5-5603-ae7b-e7f1d2752931',1),
 ('f2184b16-0616-5931-8e54-d5cae7950c36','9679a0e2-b6bf-5ce7-8938-19b85932bd35',2),
 ('f2184b16-0616-5931-8e54-d5cae7950c36','b62cd557-2a1e-5730-8c94-ea84c777cea8',3),
 ('f2184b16-0616-5931-8e54-d5cae7950c36','3f1d8f64-8967-5fc2-a5de-687afb2cb3be',4),
 ('f2184b16-0616-5931-8e54-d5cae7950c36','90cf04ae-e15d-5655-bdfe-613d5ece9de2',5),
 ('f2184b16-0616-5931-8e54-d5cae7950c36','e3e88843-b196-5140-93d3-d35478b538a7',6),
 ('f2184b16-0616-5931-8e54-d5cae7950c36','8b18ce86-75c2-5cfa-a8b1-894094bfbc06',7),
 ('f2184b16-0616-5931-8e54-d5cae7950c36','d44272ec-59a9-51b6-bf78-3c96f916c368',8),
 ('f2184b16-0616-5931-8e54-d5cae7950c36','59e987e4-861f-50b6-928a-efd0ac448bce',9),
 ('f2184b16-0616-5931-8e54-d5cae7950c36','7a6e6724-7b94-51ef-8b6e-c5ba7f7c12aa',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('3bceefe1-6f1d-57db-977a-1b783e9eb496','20000000-0000-0000-0000-000000000004',$p$il treno$p$,$p$el tren$p$,281,'sustantivo'),
 ('6bd9acee-04c1-5311-9556-4ae280429dfb','20000000-0000-0000-0000-000000000004',$p$l'aereo$p$,$p$el avión$p$,282,'sustantivo'),
 ('82303e96-6924-5827-9e25-b956b9fd6220','20000000-0000-0000-0000-000000000004',$p$la stazione$p$,$p$la estación$p$,283,'sustantivo'),
 ('076c5980-9dee-5a89-9de3-83412c7efbab','20000000-0000-0000-0000-000000000004',$p$l'aeroporto$p$,$p$el aeropuerto$p$,284,'sustantivo'),
 ('6afef02f-3b76-5a95-83d7-8e40fd243f6c','20000000-0000-0000-0000-000000000004',$p$l'albergo$p$,$p$el hotel$p$,285,'sustantivo'),
 ('69fd122f-c78a-5a02-9270-9eb8fcd0f5e3','20000000-0000-0000-0000-000000000004',$p$il biglietto$p$,$p$el billete$p$,286,'sustantivo'),
 ('fd73f766-0a9e-54ed-ac65-6f965c28cb37','20000000-0000-0000-0000-000000000004',$p$la valigia$p$,$p$la maleta$p$,287,'sustantivo'),
 ('fbe68036-c1f6-5a9b-9547-e483a6deb7a9','20000000-0000-0000-0000-000000000004',$p$partire$p$,$p$salir/partir$p$,288,'verbo'),
 ('f30c93d5-02e7-5c05-ab1c-88edfa02bf33','20000000-0000-0000-0000-000000000004',$p$arrivare$p$,$p$llegar$p$,289,'verbo'),
 ('edfc7ef4-8bbe-5f56-ab00-35f2497af858','20000000-0000-0000-0000-000000000004',$p$tornare$p$,$p$volver$p$,290,'verbo'),
 ('9dc1c741-df82-5960-950d-7bd775302805','20000000-0000-0000-0000-000000000004',$p$rimanere$p$,$p$quedarse$p$,291,'verbo'),
 ('b4802eb0-c0ca-5d37-a452-d33320064daf','20000000-0000-0000-0000-000000000004',$p$prenotare$p$,$p$reservar$p$,292,'verbo'),
 ('0586af3c-47e7-5315-b05f-6bc39f1cb2f8','20000000-0000-0000-0000-000000000004',$p$salire$p$,$p$subir$p$,293,'verbo'),
 ('166b99cf-5b88-55f9-a7cd-6ebbcbb60fab','20000000-0000-0000-0000-000000000004',$p$scendere$p$,$p$bajar$p$,294,'verbo'),
 ('db87173d-3d4e-50bb-ab3f-62456f37a55d','20000000-0000-0000-0000-000000000004',$p$in ritardo$p$,$p$con retraso$p$,295,'expresion'),
 ('6f9733f7-e0a1-5295-8594-478fde9e27a3','20000000-0000-0000-0000-000000000004',$p$Buon viaggio!$p$,$p$¡Buen viaje!$p$,296,'expresion')
on conflict (id) do nothing;

-- ── Unidad 10 (A2·it): Comer fuera y comprar ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('7b69043e-92d5-5924-9078-4fbc34430bc1','20000000-0000-0000-0000-000000000004','A2',10,$p$Comer fuera y comprar$p$,'#E67E22','shopping_cart')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('5b080da3-8a86-52a2-a036-d37f32ef944a','7b69043e-92d5-5924-9078-4fbc34430bc1',1,$p$Comparar: più, meno, come$p$,$p$Comparar: più, meno, come$p$,'lesson',15),
 ('5ec27b26-fc9f-5cd9-924d-9879b4c0ac51','7b69043e-92d5-5924-9078-4fbc34430bc1',2,$p$Cantidades: un chilo di...$p$,$p$Cantidades: un chilo di...$p$,'lesson',15),
 ('243c08a2-5585-57cf-87cf-49cbdee97f1c','7b69043e-92d5-5924-9078-4fbc34430bc1',3,$p$El pronombre ne$p$,$p$El pronombre ne$p$,'lesson',15),
 ('9b6ad3f4-2a24-5f20-a9d2-b647f1b70d91','7b69043e-92d5-5924-9078-4fbc34430bc1',4,$p$En el restaurante$p$,$p$En el restaurante$p$,'lesson',15),
 ('1cab18ab-fa77-537b-95d8-d4fea9c691e4','7b69043e-92d5-5924-9078-4fbc34430bc1',5,$p$🏁 Checkpoint Unità 10$p$,$p$Compara, pide cantidades y usa 'ne' en la tienda y el restaurante.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('7fb4e641-8d9a-574d-aa26-90fbe34becfb','20000000-0000-0000-0000-000000000004','checkpoint','A2','7b69043e-92d5-5924-9078-4fbc34430bc1',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('1698bba7-3d5c-55d1-83bd-a9941e29ecca'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','reading','match',$p$Une cada palabra italiana con su traducción.$p$,$j${"pairs": [{"en": "il conto", "es": "la cuenta"}, {"en": "il menù", "es": "el menú"}, {"en": "il pane", "es": "el pan"}]}$j$::jsonb,$j${"pairs": [["il conto", "la cuenta"], ["il menù", "el menú"], ["il pane", "el pan"]]}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$vocab_spesa$p$, $p$reading$p$]),
('f1321533-fef8-5562-a480-974f4b7525fa'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','reading','match',$p$Une cada palabra italiana con su traducción.$p$,$j${"pairs": [{"en": "più", "es": "más"}, {"en": "meno", "es": "menos"}, {"en": "migliore", "es": "mejor"}]}$j$::jsonb,$j${"pairs": [["più", "más"], ["meno", "menos"], ["migliore", "mejor"]]}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$vocab_spesa$p$, $p$reading$p$]),
('cdb28eb1-2bdb-5c3b-819f-fbc5060574f3'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','reading','multiple_choice',$p$Completa: 'Milano è più grande ___ Firenze.'$p$,$j${"options": ["di", "che", "come"]}$j$::jsonb,$j${"value": "di"}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$comparativo$p$, $p$reading$p$]),
('49fb4f5b-606b-5c7f-a019-39b967ddb008'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','reading','multiple_choice',$p$¿Cómo se dice 'mejor' (adjetivo) en italiano correcto?$p$,$j${"options": ["migliore", "più buono", "più bene"]}$j$::jsonb,$j${"value": "migliore"}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$comparativo$p$, $p$reading$p$]),
('4fe20ac6-e5d7-5451-818b-bf707786b386'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','reading','multiple_choice',$p$Completa la cantidad: 'Vorrei un chilo ___ mele.'$p$,$j${"options": ["di", "delle", "le"]}$j$::jsonb,$j${"value": "di"}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$quantita$p$, $p$reading$p$]),
('c9677ef7-ebc6-5960-8a6f-e061e6a7af82'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','reading','multiple_choice',$p$'Vuoi del pane?' Responde con 'ne':$p$,$j${"options": ["Sì, ne voglio.", "Sì, lo voglio ne.", "Sì, voglio ne."]}$j$::jsonb,$j${"value": "Sì, ne voglio."}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$ne$p$, $p$reading$p$]),
('0089d4f0-bff7-58a6-8b35-fbda5d56ba3e'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','writing','cloze',$p$Comparación con dos adjetivos: usa 'che'. 'È più simpatico ___ intelligente.'$p$,$j${"text": "È più simpatico ___ intelligente."}$j$::jsonb,$j${"value": "che", "accepted": ["che"]}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$comparativo$p$, $p$writing$p$]),
('3f870a32-373d-574c-aff2-6a448d471a98'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','writing','cloze',$p$Responde con el pronombre de cantidad: 'Quante mele hai? — ___ ho due.'$p$,$j${"text": "___ ho due."}$j$::jsonb,$j${"value": "Ne", "accepted": ["Ne", "ne"]}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$ne$p$, $p$writing$p$]),
('d3749e0f-4867-51b2-8a01-7f5090eb66f3'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','writing','translation',$p$Traduce: 'Este vino es menos caro que ese.'$p$,$j${"source": "Este vino es menos caro que ese."}$j$::jsonb,$j${"value": "Questo vino è meno caro di quello.", "accepted": ["Questo vino è meno caro di quello.", "Questo vino è meno caro di quello", "Questo vino e meno caro di quello"]}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$comparativo$p$, $p$writing$p$]),
('8a7c639b-7423-5d43-816d-334da863da5d'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','writing','translation',$p$Traduce: 'La cuenta, por favor.'$p$,$j${"source": "La cuenta, por favor."}$j$::jsonb,$j${"value": "Il conto, per favore.", "accepted": ["Il conto, per favore.", "Il conto, per favore", "Il conto per favore"]}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$ristorante$p$, $p$writing$p$]),
('088532db-bace-5a04-bd30-b3bff609ff54'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','writing','word_bank',$p$Ordena las fichas: 'Querría una botella de agua.'$p$,$j${"tiles": ["Vorrei", "una bottiglia", "di", "acqua", "delle", "un chilo"]}$j$::jsonb,$j${"value": "Vorrei una bottiglia di acqua", "sequence": ["Vorrei", "una bottiglia", "di", "acqua"]}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$quantita$p$, $p$writing$p$]),
('8f8562fb-010d-5bdc-9501-12ec501ec194'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','writing','reorder',$p$Ordena la frase: '¿Cuánto cuesta el menú?'$p$,$j${"tiles": ["il", "costa", "Quanto", "menù"]}$j$::jsonb,$j${"value": "Quanto costa il menù"}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$ristorante$p$, $p$writing$p$]),
('d0ba66f2-4962-5275-a7b3-fa859b7058ac'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Questa pizza è migliore di quella.", "Questa pizza è peggiore di quella.", "Questa pasta è migliore di quella."], "say": "Questa pizza è migliore di quella.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/d0ba66f2-4962-5275-a7b3-fa859b7058ac.mp3"}$j$::jsonb,$j${"value": "Questa pizza è migliore di quella."}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$comparativo$p$, $p$listening$p$]),
('37c58244-dd02-5916-9abd-b870be2f8cc3'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Prendo un pacco di pasta.", "Prendo un chilo di pasta.", "Prendo un pacco di riso."], "say": "Prendo un pacco di pasta.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/37c58244-dd02-5916-9abd-b870be2f8cc3.mp3"}$j$::jsonb,$j${"value": "Prendo un pacco di pasta."}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$quantita$p$, $p$listening$p$]),
('45f18e7a-1f76-5882-8e95-c1b865667d7f'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Sì, ne voglio un po'.", "Sì, ne voglio due.", "No, non ne voglio."], "say": "Sì, ne voglio un po'.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/45f18e7a-1f76-5882-8e95-c1b865667d7f.mp3"}$j$::jsonb,$j${"value": "Sì, ne voglio un po'."}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$ne$p$, $p$listening$p$]),
('cab4e02a-ace5-5dcb-a0ae-e3377e167ac6'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Vorrei ordinare, per favore.", "Vorrei pagare, per favore.", "Vorrei il conto, per favore."], "say": "Vorrei ordinare, per favore.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/cab4e02a-ace5-5dcb-a0ae-e3377e167ac6.mp3"}$j$::jsonb,$j${"value": "Vorrei ordinare, per favore."}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$ristorante$p$, $p$listening$p$]),
('3b3fea75-7c2d-52af-8fcd-81490570eb12'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Roma è più grande di Firenze.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/3b3fea75-7c2d-52af-8fcd-81490570eb12.mp3"}$j$::jsonb,$j${"expected": "Roma è più grande di Firenze."}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$comparativo$p$, $p$speaking$p$]),
('e830b050-d948-5899-9110-2a4aa1562ae2'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Vorrei un po' di pane.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/e830b050-d948-5899-9110-2a4aa1562ae2.mp3"}$j$::jsonb,$j${"expected": "Vorrei un po' di pane."}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$quantita$p$, $p$speaking$p$]),
('60b44e3d-10f9-5b13-bc1a-f154c065500d'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Quanto costa il conto?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/60b44e3d-10f9-5b13-bc1a-f154c065500d.mp3"}$j$::jsonb,$j${"expected": "Quanto costa il conto?"}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$ristorante$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('5b080da3-8a86-52a2-a036-d37f32ef944a','f1321533-fef8-5562-a480-974f4b7525fa',1),
 ('5b080da3-8a86-52a2-a036-d37f32ef944a','cdb28eb1-2bdb-5c3b-819f-fbc5060574f3',2),
 ('5b080da3-8a86-52a2-a036-d37f32ef944a','49fb4f5b-606b-5c7f-a019-39b967ddb008',3),
 ('5b080da3-8a86-52a2-a036-d37f32ef944a','0089d4f0-bff7-58a6-8b35-fbda5d56ba3e',4),
 ('5b080da3-8a86-52a2-a036-d37f32ef944a','d3749e0f-4867-51b2-8a01-7f5090eb66f3',5),
 ('5b080da3-8a86-52a2-a036-d37f32ef944a','d0ba66f2-4962-5275-a7b3-fa859b7058ac',6),
 ('5b080da3-8a86-52a2-a036-d37f32ef944a','3b3fea75-7c2d-52af-8fcd-81490570eb12',7),
 ('5ec27b26-fc9f-5cd9-924d-9879b4c0ac51','1698bba7-3d5c-55d1-83bd-a9941e29ecca',1),
 ('5ec27b26-fc9f-5cd9-924d-9879b4c0ac51','4fe20ac6-e5d7-5451-818b-bf707786b386',2),
 ('5ec27b26-fc9f-5cd9-924d-9879b4c0ac51','088532db-bace-5a04-bd30-b3bff609ff54',3),
 ('5ec27b26-fc9f-5cd9-924d-9879b4c0ac51','37c58244-dd02-5916-9abd-b870be2f8cc3',4),
 ('5ec27b26-fc9f-5cd9-924d-9879b4c0ac51','e830b050-d948-5899-9110-2a4aa1562ae2',5),
 ('243c08a2-5585-57cf-87cf-49cbdee97f1c','c9677ef7-ebc6-5960-8a6f-e061e6a7af82',1),
 ('243c08a2-5585-57cf-87cf-49cbdee97f1c','3f870a32-373d-574c-aff2-6a448d471a98',2),
 ('243c08a2-5585-57cf-87cf-49cbdee97f1c','45f18e7a-1f76-5882-8e95-c1b865667d7f',3),
 ('9b6ad3f4-2a24-5f20-a9d2-b647f1b70d91','8a7c639b-7423-5d43-816d-334da863da5d',1),
 ('9b6ad3f4-2a24-5f20-a9d2-b647f1b70d91','8f8562fb-010d-5bdc-9501-12ec501ec194',2),
 ('9b6ad3f4-2a24-5f20-a9d2-b647f1b70d91','cab4e02a-ace5-5dcb-a0ae-e3377e167ac6',3),
 ('9b6ad3f4-2a24-5f20-a9d2-b647f1b70d91','60b44e3d-10f9-5b13-bc1a-f154c065500d',4),
 ('1cab18ab-fa77-537b-95d8-d4fea9c691e4','1698bba7-3d5c-55d1-83bd-a9941e29ecca',1),
 ('1cab18ab-fa77-537b-95d8-d4fea9c691e4','f1321533-fef8-5562-a480-974f4b7525fa',2),
 ('1cab18ab-fa77-537b-95d8-d4fea9c691e4','cdb28eb1-2bdb-5c3b-819f-fbc5060574f3',3),
 ('1cab18ab-fa77-537b-95d8-d4fea9c691e4','0089d4f0-bff7-58a6-8b35-fbda5d56ba3e',4),
 ('1cab18ab-fa77-537b-95d8-d4fea9c691e4','3f870a32-373d-574c-aff2-6a448d471a98',5),
 ('1cab18ab-fa77-537b-95d8-d4fea9c691e4','d3749e0f-4867-51b2-8a01-7f5090eb66f3',6),
 ('1cab18ab-fa77-537b-95d8-d4fea9c691e4','d0ba66f2-4962-5275-a7b3-fa859b7058ac',7),
 ('1cab18ab-fa77-537b-95d8-d4fea9c691e4','37c58244-dd02-5916-9abd-b870be2f8cc3',8),
 ('1cab18ab-fa77-537b-95d8-d4fea9c691e4','3b3fea75-7c2d-52af-8fcd-81490570eb12',9),
 ('1cab18ab-fa77-537b-95d8-d4fea9c691e4','e830b050-d948-5899-9110-2a4aa1562ae2',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('6cc4b557-8367-5cd2-92ec-3f859e0f9c07','20000000-0000-0000-0000-000000000004',$p$più$p$,$p$más$p$,301,'adverbio'),
 ('ad72dd2b-388f-5aeb-b9cb-e2fe4e2c3fe9','20000000-0000-0000-0000-000000000004',$p$meno$p$,$p$menos$p$,302,'adverbio'),
 ('21ca8d62-57dc-5704-8830-493de143f229','20000000-0000-0000-0000-000000000004',$p$migliore$p$,$p$mejor$p$,303,'adjetivo'),
 ('666fb64d-78cf-5de6-ace5-374df9c4747f','20000000-0000-0000-0000-000000000004',$p$caro$p$,$p$caro$p$,304,'adjetivo'),
 ('f8cc92e9-c6f9-5f81-a927-e0adfc1f179b','20000000-0000-0000-0000-000000000004',$p$un chilo di$p$,$p$un kilo de$p$,305,'expresion'),
 ('1b698b17-fa0c-5b63-9591-86b469eb5377','20000000-0000-0000-0000-000000000004',$p$una bottiglia di$p$,$p$una botella de$p$,306,'expresion'),
 ('67195f6f-a3e8-56a1-8af8-c5dd8f7479cd','20000000-0000-0000-0000-000000000004',$p$un pacco di$p$,$p$un paquete de$p$,307,'expresion'),
 ('7c4e7193-f2a4-51c2-b457-db4067b0d6b8','20000000-0000-0000-0000-000000000004',$p$un po' di$p$,$p$un poco de$p$,308,'expresion'),
 ('5178ee55-c8da-559e-8deb-a4e2b7d02935','20000000-0000-0000-0000-000000000004',$p$ne$p$,$p$de eso/de ello$p$,309,'pronombre'),
 ('9531377a-6e83-509f-bb94-33bee6705e51','20000000-0000-0000-0000-000000000004',$p$il conto$p$,$p$la cuenta$p$,310,'sustantivo'),
 ('dd486863-eb39-5496-98c5-5ebce5b1391d','20000000-0000-0000-0000-000000000004',$p$il menù$p$,$p$el menú$p$,311,'sustantivo'),
 ('43559048-6e29-5f6f-b948-9e3861f2b850','20000000-0000-0000-0000-000000000004',$p$ordinare$p$,$p$pedir/ordenar$p$,312,'verbo'),
 ('984992a0-ae3d-5740-8d8a-40da9def4557','20000000-0000-0000-0000-000000000004',$p$Vorrei$p$,$p$querría/quisiera$p$,313,'expresion'),
 ('19fce474-cbaf-597d-9d23-7c8f569a8fa6','20000000-0000-0000-0000-000000000004',$p$Quanto costa?$p$,$p$¿Cuánto cuesta?$p$,314,'expresion'),
 ('0a72d36a-8257-5e60-ab67-304db3a64857','20000000-0000-0000-0000-000000000004',$p$la mela$p$,$p$la manzana$p$,315,'sustantivo'),
 ('333e23e3-8528-54b5-b190-ed348580d74f','20000000-0000-0000-0000-000000000004',$p$il pane$p$,$p$el pan$p$,316,'sustantivo')
on conflict (id) do nothing;

-- ── Unidad 11 (A2·it): Personas y descripciones ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('17694645-73f5-5568-bf8e-9cb08bf0c72f','20000000-0000-0000-0000-000000000004','A2',11,$p$Personas y descripciones$p$,'#8E44AD','people')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('23ec7172-ef15-510c-9896-a71e7a21981b','17694645-73f5-5568-bf8e-9cb08bf0c72f',1,$p$El imperfetto: describir el pasado$p$,$p$El imperfetto: describir el pasado$p$,'lesson',15),
 ('53c82c8f-fb69-543b-8747-0c173ebf26aa','17694645-73f5-5568-bf8e-9cb08bf0c72f',2,$p$Cómo era: aspecto físico$p$,$p$Cómo era: aspecto físico$p$,'lesson',15),
 ('8bed91d4-fb7d-55bc-a992-82dffc523460','17694645-73f5-5568-bf8e-9cb08bf0c72f',3,$p$El carácter de las personas$p$,$p$El carácter de las personas$p$,'lesson',15),
 ('6d314193-9646-59aa-9b92-25f99e552986','17694645-73f5-5568-bf8e-9cb08bf0c72f',4,$p$Pronombres directos: lo, la, li, le$p$,$p$Pronombres directos: lo, la, li, le$p$,'lesson',15),
 ('8676638a-3551-5d32-b9c9-df5e61491c5c','17694645-73f5-5568-bf8e-9cb08bf0c72f',5,$p$🏁 Checkpoint Unità 11$p$,$p$Describe a personas en el pasado con el imperfetto y usa los pronombres directos lo/la/li/le.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('d3c85eca-abb0-5caa-bb17-4e942f19e710','20000000-0000-0000-0000-000000000004','checkpoint','A2','17694645-73f5-5568-bf8e-9cb08bf0c72f',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('1fda933e-b4a2-5762-a30b-3ef84a55bcc7'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','reading','match',$p$Une cada forma del imperfetto con su traducción.$p$,$j${"pairs": [{"en": "ero", "es": "yo era"}, {"en": "eri", "es": "tú eras"}, {"en": "era", "es": "él/ella era"}]}$j$::jsonb,$j${"pairs": [["ero", "yo era"], ["eri", "tú eras"], ["era", "él/ella era"]]}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$imperfetto$p$, $p$reading$p$]),
('3646a36c-64cb-5226-9878-ec91351833fe'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','reading','match',$p$Une cada palabra italiana con su traducción.$p$,$j${"pairs": [{"en": "i capelli", "es": "el cabello"}, {"en": "gli occhi", "es": "los ojos"}, {"en": "alto", "es": "alto"}]}$j$::jsonb,$j${"pairs": [["i capelli", "el cabello"], ["gli occhi", "los ojos"], ["alto", "alto"]]}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$aspetto_fisico$p$, $p$reading$p$]),
('892afb28-491f-5eed-b864-024b20e24426'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','reading','multiple_choice',$p$Elige la forma correcta: 'Da bambino ___ in campagna.' (yo vivía)$p$,$j${"options": ["abitavo", "abito", "abiterò"]}$j$::jsonb,$j${"value": "abitavo"}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$imperfetto$p$, $p$reading$p$]),
('67581bb7-e00b-59cf-97f0-72bb5c6fa577'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','reading','multiple_choice',$p$Completa: 'Mia nonna ___ i capelli lunghi.' (tenía)$p$,$j${"options": ["aveva", "ha avuto", "avrà"]}$j$::jsonb,$j${"value": "aveva"}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$aspetto_fisico$p$, $p$reading$p$]),
('e5163f7d-b39f-5699-bf5f-6755d8515789'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','reading','multiple_choice',$p$'Marco fa sempre ridere tutti.' ¿Cómo es Marco?$p$,$j${"options": ["divertente", "timido", "serio"]}$j$::jsonb,$j${"value": "divertente"}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$carattere$p$, $p$reading$p$]),
('c22cc3ed-42d4-5455-aba2-ba692024be24'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','reading','multiple_choice',$p$'Vedi Maria? — Sì, ___ vedo.' Elige el pronombre correcto.$p$,$j${"options": ["la", "le", "gli"]}$j$::jsonb,$j${"value": "la"}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$pronomi_diretti$p$, $p$reading$p$]),
('4c75b608-12ac-53df-ad63-e64ed0199075'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','writing','cloze',$p$Imperfetto de 'essere' (él/ella). Completa: 'Ieri il cielo ___ grigio.'$p$,$j${"text": "Ieri il cielo ___ grigio."}$j$::jsonb,$j${"value": "era", "accepted": ["era"]}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$imperfetto$p$, $p$writing$p$]),
('33de7b70-deb6-53d4-a346-84fdda8bc33c'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','writing','cloze',$p$Imperfetto de 'avere' (él/ella). Completa: 'Mio nonno ___ gli occhi azzurri.'$p$,$j${"text": "Mio nonno ___ gli occhi azzurri."}$j$::jsonb,$j${"value": "aveva", "accepted": ["aveva"]}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$aspetto_fisico$p$, $p$writing$p$]),
('ea0eaa50-520b-5e93-bc64-b121baf80e94'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','writing','translation',$p$Traduce: 'Ella es muy amable.'$p$,$j${"source": "Ella es muy amable."}$j$::jsonb,$j${"value": "Lei è molto gentile.", "accepted": ["Lei è molto gentile.", "Lei è molto gentile", "Lei e molto gentile", "È molto gentile", "e molto gentile"]}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$carattere$p$, $p$writing$p$]),
('46ebc5d5-ccee-54ba-83ef-0c1e7463e918'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','writing','translation',$p$Traduce: 'Lo conozco bien.'$p$,$j${"source": "Lo conozco bien."}$j$::jsonb,$j${"value": "Lo conosco bene.", "accepted": ["Lo conosco bene.", "Lo conosco bene", "lo conosco bene"]}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$pronomi_diretti$p$, $p$writing$p$]),
('b0f6a7a9-0214-570a-a673-79cd583d95cc'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','writing','word_bank',$p$Ordena las fichas: '¿Ves a los niños? — Sí, los veo.' (segunda parte)$p$,$j${"tiles": ["Sì", "li", "vedo", "le"]}$j$::jsonb,$j${"value": "Sì li vedo", "sequence": ["Sì", "li", "vedo"]}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$pronomi_diretti$p$, $p$writing$p$]),
('4ed1d9bb-9772-59d6-807f-e147958c892e'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','writing','reorder',$p$Ordena las palabras: 'De niño jugaba en el parque.'$p$,$j${"tiles": ["giocavo", "Da", "al", "bambino", "parco"]}$j$::jsonb,$j${"value": "Da bambino giocavo al parco"}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$imperfetto$p$, $p$writing$p$]),
('45d31281-bba9-5e8c-9f11-5ae1dea06267'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Da piccola ero molto timida.", "Da piccola sono molto timida.", "Da piccolo eri molto timido."], "say": "Da piccola ero molto timida.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/45d31281-bba9-5e8c-9f11-5ae1dea06267.mp3"}$j$::jsonb,$j${"value": "Da piccola ero molto timida."}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$imperfetto$p$, $p$listening$p$]),
('9391f258-a4c8-52bc-babd-905b204e29d4'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Aveva i capelli biondi e gli occhi verdi.", "Aveva i capelli castani e gli occhi neri.", "Aveva i capelli lunghi e gli occhi azzurri."], "say": "Aveva i capelli biondi e gli occhi verdi.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/9391f258-a4c8-52bc-babd-905b204e29d4.mp3"}$j$::jsonb,$j${"value": "Aveva i capelli biondi e gli occhi verdi."}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$aspetto_fisico$p$, $p$listening$p$]),
('775266a2-2d79-5966-a20e-0499105ae78f'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Il mio professore era molto serio.", "Il mio professore era molto simpatico.", "Il mio professore è molto serio."], "say": "Il mio professore era molto serio.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/775266a2-2d79-5966-a20e-0499105ae78f.mp3"}$j$::jsonb,$j${"value": "Il mio professore era molto serio."}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$carattere$p$, $p$listening$p$]),
('d63886fe-e1ec-5d64-91e0-7c1406604c56'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Conosci Luca? Sì, lo conosco bene.", "Conosci Luca? Sì, la conosco bene.", "Conosci Luca? No, non lo conosco."], "say": "Conosci Luca? Sì, lo conosco bene.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/d63886fe-e1ec-5d64-91e0-7c1406604c56.mp3"}$j$::jsonb,$j${"value": "Conosci Luca? Sì, lo conosco bene."}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$pronomi_diretti$p$, $p$listening$p$]),
('c4ed25b8-6b60-5afb-beb0-1703bfa33fad'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Era alto e aveva i capelli neri.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/c4ed25b8-6b60-5afb-beb0-1703bfa33fad.mp3"}$j$::jsonb,$j${"expected": "Era alto e aveva i capelli neri."}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$aspetto_fisico$p$, $p$speaking$p$]),
('b85d2de6-7bda-5cb0-b1f1-08f8b3fedbca'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Mia sorella è simpatica e divertente.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/b85d2de6-7bda-5cb0-b1f1-08f8b3fedbca.mp3"}$j$::jsonb,$j${"expected": "Mia sorella è simpatica e divertente."}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$carattere$p$, $p$speaking$p$]),
('5a419889-875e-53af-bd5b-2f476249d526'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Vedi le ragazze? Sì, le vedo.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/5a419889-875e-53af-bd5b-2f476249d526.mp3"}$j$::jsonb,$j${"expected": "Vedi le ragazze? Sì, le vedo."}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$pronomi_diretti$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('23ec7172-ef15-510c-9896-a71e7a21981b','1fda933e-b4a2-5762-a30b-3ef84a55bcc7',1),
 ('23ec7172-ef15-510c-9896-a71e7a21981b','892afb28-491f-5eed-b864-024b20e24426',2),
 ('23ec7172-ef15-510c-9896-a71e7a21981b','4c75b608-12ac-53df-ad63-e64ed0199075',3),
 ('23ec7172-ef15-510c-9896-a71e7a21981b','4ed1d9bb-9772-59d6-807f-e147958c892e',4),
 ('23ec7172-ef15-510c-9896-a71e7a21981b','45d31281-bba9-5e8c-9f11-5ae1dea06267',5),
 ('53c82c8f-fb69-543b-8747-0c173ebf26aa','3646a36c-64cb-5226-9878-ec91351833fe',1),
 ('53c82c8f-fb69-543b-8747-0c173ebf26aa','67581bb7-e00b-59cf-97f0-72bb5c6fa577',2),
 ('53c82c8f-fb69-543b-8747-0c173ebf26aa','33de7b70-deb6-53d4-a346-84fdda8bc33c',3),
 ('53c82c8f-fb69-543b-8747-0c173ebf26aa','9391f258-a4c8-52bc-babd-905b204e29d4',4),
 ('53c82c8f-fb69-543b-8747-0c173ebf26aa','c4ed25b8-6b60-5afb-beb0-1703bfa33fad',5),
 ('8bed91d4-fb7d-55bc-a992-82dffc523460','e5163f7d-b39f-5699-bf5f-6755d8515789',1),
 ('8bed91d4-fb7d-55bc-a992-82dffc523460','ea0eaa50-520b-5e93-bc64-b121baf80e94',2),
 ('8bed91d4-fb7d-55bc-a992-82dffc523460','775266a2-2d79-5966-a20e-0499105ae78f',3),
 ('8bed91d4-fb7d-55bc-a992-82dffc523460','b85d2de6-7bda-5cb0-b1f1-08f8b3fedbca',4),
 ('6d314193-9646-59aa-9b92-25f99e552986','c22cc3ed-42d4-5455-aba2-ba692024be24',1),
 ('6d314193-9646-59aa-9b92-25f99e552986','46ebc5d5-ccee-54ba-83ef-0c1e7463e918',2),
 ('6d314193-9646-59aa-9b92-25f99e552986','b0f6a7a9-0214-570a-a673-79cd583d95cc',3),
 ('6d314193-9646-59aa-9b92-25f99e552986','d63886fe-e1ec-5d64-91e0-7c1406604c56',4),
 ('6d314193-9646-59aa-9b92-25f99e552986','5a419889-875e-53af-bd5b-2f476249d526',5),
 ('8676638a-3551-5d32-b9c9-df5e61491c5c','1fda933e-b4a2-5762-a30b-3ef84a55bcc7',1),
 ('8676638a-3551-5d32-b9c9-df5e61491c5c','3646a36c-64cb-5226-9878-ec91351833fe',2),
 ('8676638a-3551-5d32-b9c9-df5e61491c5c','892afb28-491f-5eed-b864-024b20e24426',3),
 ('8676638a-3551-5d32-b9c9-df5e61491c5c','4c75b608-12ac-53df-ad63-e64ed0199075',4),
 ('8676638a-3551-5d32-b9c9-df5e61491c5c','33de7b70-deb6-53d4-a346-84fdda8bc33c',5),
 ('8676638a-3551-5d32-b9c9-df5e61491c5c','ea0eaa50-520b-5e93-bc64-b121baf80e94',6),
 ('8676638a-3551-5d32-b9c9-df5e61491c5c','45d31281-bba9-5e8c-9f11-5ae1dea06267',7),
 ('8676638a-3551-5d32-b9c9-df5e61491c5c','9391f258-a4c8-52bc-babd-905b204e29d4',8),
 ('8676638a-3551-5d32-b9c9-df5e61491c5c','c4ed25b8-6b60-5afb-beb0-1703bfa33fad',9),
 ('8676638a-3551-5d32-b9c9-df5e61491c5c','b85d2de6-7bda-5cb0-b1f1-08f8b3fedbca',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('14cdd840-1e0f-51b2-96ac-a81247a84c05','20000000-0000-0000-0000-000000000004',$p$alto$p$,$p$alto$p$,321,'adjetivo'),
 ('e260101d-7364-5bb5-84d5-991bacb74759','20000000-0000-0000-0000-000000000004',$p$basso$p$,$p$bajo$p$,322,'adjetivo'),
 ('f650bb6a-1954-537f-92d4-57a17ef3d122','20000000-0000-0000-0000-000000000004',$p$i capelli$p$,$p$el cabello$p$,323,'sustantivo'),
 ('48d41df2-5b41-5b25-ac29-572427ffdc6e','20000000-0000-0000-0000-000000000004',$p$gli occhi$p$,$p$los ojos$p$,324,'sustantivo'),
 ('f2746010-46a2-5cf4-8031-254e2cd466f9','20000000-0000-0000-0000-000000000004',$p$biondo$p$,$p$rubio$p$,325,'adjetivo'),
 ('68ab90cf-83eb-5e0f-b362-8c51a5c6792b','20000000-0000-0000-0000-000000000004',$p$castano$p$,$p$castaño$p$,326,'adjetivo'),
 ('03429397-7005-5447-97a6-b7eba086432b','20000000-0000-0000-0000-000000000004',$p$gentile$p$,$p$amable$p$,327,'adjetivo'),
 ('63febd9b-8239-58ca-bf8e-6b663e3cb613','20000000-0000-0000-0000-000000000004',$p$timido$p$,$p$tímido$p$,328,'adjetivo'),
 ('ba1f1416-99e7-50a7-bb6d-1f84f52d7023','20000000-0000-0000-0000-000000000004',$p$simpatico$p$,$p$simpático$p$,329,'adjetivo'),
 ('7650830b-fc73-5fa1-b2df-1537842d5e57','20000000-0000-0000-0000-000000000004',$p$divertente$p$,$p$divertido$p$,330,'adjetivo'),
 ('9831934a-ca66-5159-a381-ef114388c160','20000000-0000-0000-0000-000000000004',$p$serio$p$,$p$serio$p$,331,'adjetivo'),
 ('0770cc70-7385-56da-9f12-f2ad57952d00','20000000-0000-0000-0000-000000000004',$p$da bambino$p$,$p$de niño$p$,332,'expresion'),
 ('0b132805-dd7f-5a8a-9943-fe4faad3b570','20000000-0000-0000-0000-000000000004',$p$era$p$,$p$era$p$,333,'verbo'),
 ('b82e7e1c-aaaf-5baa-acd7-bc59e3d60a1c','20000000-0000-0000-0000-000000000004',$p$c'era$p$,$p$había$p$,334,'expresion'),
 ('6288d176-d121-5bd9-a8b6-58188892578a','20000000-0000-0000-0000-000000000004',$p$lo conosco$p$,$p$lo conozco$p$,335,'expresion'),
 ('c2488547-9166-50b9-9be2-35baca3d2315','20000000-0000-0000-0000-000000000004',$p$la vedo$p$,$p$la veo$p$,336,'expresion')
on conflict (id) do nothing;

-- ── Unidad 12 (A2·it): Salud, cuerpo y consejos ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('f44303ca-00f1-5f93-b587-865feb65c8a4','20000000-0000-0000-0000-000000000004','A2',12,$p$Salud, cuerpo y consejos$p$,'#D35400','healing')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('71bd7895-23fe-5e3b-9456-fc4a7a77f818','f44303ca-00f1-5f93-b587-865feb65c8a4',1,$p$Las partes del cuerpo$p$,$p$Las partes del cuerpo$p$,'lesson',15),
 ('0b802d7f-4a82-53f9-82f3-eab43aeb1366','f44303ca-00f1-5f93-b587-865feb65c8a4',2,$p$Me duele: avere mal di$p$,$p$Me duele: avere mal di$p$,'lesson',15),
 ('e8325d87-89a4-5816-a7b4-d79480270fcd','f44303ca-00f1-5f93-b587-865feb65c8a4',3,$p$Consejos: bisogna y dovresti$p$,$p$Consejos: bisogna y dovresti$p$,'lesson',15),
 ('7e1a883a-75f7-5029-b948-94b73d44346c','f44303ca-00f1-5f93-b587-865feb65c8a4',4,$p$En el médico$p$,$p$En el médico$p$,'lesson',15),
 ('f95c25d7-c41a-526e-adda-2033ada022b3','f44303ca-00f1-5f93-b587-865feb65c8a4',5,$p$🏁 Checkpoint Unità 12$p$,$p$Habla del cuerpo, di qué te duele con 'avere mal di' y da consejos con 'bisogna' y 'dovresti'.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('ae0eb497-8249-57ab-8dd6-4c2267c3dc38','20000000-0000-0000-0000-000000000004','checkpoint','A2','f44303ca-00f1-5f93-b587-865feb65c8a4',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('044164fa-6821-59ea-a1ad-32e6ec65c114'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','reading','match',$p$Une cada parte del cuerpo con su traducción.$p$,$j${"pairs": [{"en": "la testa", "es": "la cabeza"}, {"en": "la gamba", "es": "la pierna"}, {"en": "la mano", "es": "la mano"}]}$j$::jsonb,$j${"pairs": [["la testa", "la cabeza"], ["la gamba", "la pierna"], ["la mano", "la mano"]]}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$corpo$p$, $p$reading$p$]),
('52feab51-5178-5222-80cb-2df3ce94b5fb'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','reading','match',$p$Une cada molestia con su traducción.$p$,$j${"pairs": [{"en": "ho mal di gola", "es": "me duele la garganta"}, {"en": "ho mal di schiena", "es": "me duele la espalda"}, {"en": "ho mal di denti", "es": "me duelen los dientes"}]}$j$::jsonb,$j${"pairs": [["ho mal di gola", "me duele la garganta"], ["ho mal di schiena", "me duele la espalda"], ["ho mal di denti", "me duelen los dientes"]]}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$mal_di$p$, $p$reading$p$]),
('f5dc68cd-9707-5be6-a020-84cfaf10830b'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','reading','multiple_choice',$p$'Me duele la cabeza.' Elige la forma correcta en italiano.$p$,$j${"options": ["Ho mal di testa.", "Ho mal della testa.", "Ho male di testa."]}$j$::jsonb,$j${"value": "Ho mal di testa."}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$mal_di$p$, $p$reading$p$]),
('45fe5408-1be9-506d-96e7-dbab1e08ad26'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','reading','multiple_choice',$p$Consejo impersonal: 'Para estar bien ___ riposare.' (hay que)$p$,$j${"options": ["bisogna", "devi", "dovresti"]}$j$::jsonb,$j${"value": "bisogna"}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$consigli$p$, $p$reading$p$]),
('8b419930-bf37-5a3d-8a22-853c74a65000'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','reading','multiple_choice',$p$'Sei stanco: ___ dormire di più.' (deberías)$p$,$j${"options": ["dovresti", "bisogna", "vuoi"]}$j$::jsonb,$j${"value": "dovresti"}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$consigli$p$, $p$reading$p$]),
('8952a4eb-f7b0-53c7-882f-b5a52e1887b6'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','reading','multiple_choice',$p$El médico pregunta cómo estás. ¿Qué dice?$p$,$j${"options": ["Cosa c'è che non va?", "Quanto costa?", "Dove abiti?"]}$j$::jsonb,$j${"value": "Cosa c'è che non va?"}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$dal_medico$p$, $p$reading$p$]),
('16c5e2d5-1630-5e1f-bd3f-f8d506fc14b0'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','writing','cloze',$p$Otra manera de decir 'me duele la cabeza': 'Mi fa ___ la testa.'$p$,$j${"text": "Mi fa ___ la testa."}$j$::jsonb,$j${"value": "male", "accepted": ["male"]}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$mal_di$p$, $p$writing$p$]),
('bed0b961-3527-5022-93bf-a4c3658d88c0'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','writing','cloze',$p$Completa la expresión '___ ancora' (todavía no).$p$,$j${"text": "No, ___ ancora."}$j$::jsonb,$j${"value": "non", "accepted": ["non"]}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$dal_medico$p$, $p$writing$p$]),
('99c8baf2-4535-5701-93d8-0ba60f9bd3f6'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','writing','translation',$p$Traduce: 'Me duele la garganta desde ayer.'$p$,$j${"source": "Me duele la garganta desde ayer."}$j$::jsonb,$j${"value": "Ho mal di gola da ieri.", "accepted": ["Ho mal di gola da ieri.", "Ho mal di gola da ieri", "ho mal di gola da ieri"]}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$mal_di$p$, $p$writing$p$]),
('06a54180-4bbe-537b-8114-7120947b3fe8'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','writing','translation',$p$Traduce: 'Tienes fiebre, deberías descansar.'$p$,$j${"source": "Tienes fiebre, deberías descansar."}$j$::jsonb,$j${"value": "Hai la febbre, dovresti riposare.", "accepted": ["Hai la febbre, dovresti riposare.", "Hai la febbre, dovresti riposare", "Hai la febbre dovresti riposare", "hai la febbre dovresti riposare"]}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$consigli$p$, $p$writing$p$]),
('877b4c05-8921-5010-8c13-ab48e9ec4339'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','writing','word_bank',$p$Ordena las fichas: 'Me duele el estómago.'$p$,$j${"tiles": ["Mi", "fa", "male", "lo", "stomaco", "la"]}$j$::jsonb,$j${"value": "Mi fa male lo stomaco", "sequence": ["Mi", "fa", "male", "lo", "stomaco"]}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$corpo$p$, $p$writing$p$]),
('5dc2d22e-8426-578b-aa90-fb3fd0efad3e'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','writing','reorder',$p$Ordena las palabras: 'Tengo dolor de barriga.'$p$,$j${"tiles": ["di", "Ho", "pancia", "mal"]}$j$::jsonb,$j${"value": "Ho mal di pancia"}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$mal_di$p$, $p$writing$p$]),
('a4543238-bd40-50cf-8631-d65400cd3e78'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Mi fa male la schiena.", "Mi fa male la gamba.", "Mi fanno male i denti."], "say": "Mi fa male la schiena.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/a4543238-bd40-50cf-8631-d65400cd3e78.mp3"}$j$::jsonb,$j${"value": "Mi fa male la schiena."}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$corpo$p$, $p$listening$p$]),
('d1ffc85b-7825-59f7-a5fc-3fd8652b7a16'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ho mal di gola e un po' di febbre.", "Ho mal di testa e un po' di febbre.", "Ho mal di pancia e molta febbre."], "say": "Ho mal di gola e un po' di febbre.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/d1ffc85b-7825-59f7-a5fc-3fd8652b7a16.mp3"}$j$::jsonb,$j${"value": "Ho mal di gola e un po' di febbre."}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$mal_di$p$, $p$listening$p$]),
('629ff323-9317-5b92-a677-f03e24be87d1'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Bisogna bere molta acqua.", "Bisogna mangiare molta frutta.", "Dovresti bere molta acqua."], "say": "Bisogna bere molta acqua.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/629ff323-9317-5b92-a677-f03e24be87d1.mp3"}$j$::jsonb,$j${"value": "Bisogna bere molta acqua."}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$consigli$p$, $p$listening$p$]),
('b6dc62e4-aafa-5449-b0ef-f503e388e0ee'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Sono malato da ieri.", "Sono malato da una settimana.", "Sono stanco da ieri."], "say": "Sono malato da ieri.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/b6dc62e4-aafa-5449-b0ef-f503e388e0ee.mp3"}$j$::jsonb,$j${"value": "Sono malato da ieri."}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$dal_medico$p$, $p$listening$p$]),
('13974c2b-d8f1-510e-83bb-b6f8d298de11'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Ho mal di testa da stamattina.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/13974c2b-d8f1-510e-83bb-b6f8d298de11.mp3"}$j$::jsonb,$j${"expected": "Ho mal di testa da stamattina."}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$mal_di$p$, $p$speaking$p$]),
('babebdd0-4303-5ba2-8165-817bb938fb16'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Dovresti dormire e riposare.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/babebdd0-4303-5ba2-8165-817bb938fb16.mp3"}$j$::jsonb,$j${"expected": "Dovresti dormire e riposare."}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$consigli$p$, $p$speaking$p$]),
('97d7e8b2-6957-50c9-8e1b-6e14c2be5fde'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Ho la febbre e mi fa male la gola.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/97d7e8b2-6957-50c9-8e1b-6e14c2be5fde.mp3"}$j$::jsonb,$j${"expected": "Ho la febbre e mi fa male la gola."}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$dal_medico$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('71bd7895-23fe-5e3b-9456-fc4a7a77f818','044164fa-6821-59ea-a1ad-32e6ec65c114',1),
 ('71bd7895-23fe-5e3b-9456-fc4a7a77f818','877b4c05-8921-5010-8c13-ab48e9ec4339',2),
 ('71bd7895-23fe-5e3b-9456-fc4a7a77f818','a4543238-bd40-50cf-8631-d65400cd3e78',3),
 ('0b802d7f-4a82-53f9-82f3-eab43aeb1366','52feab51-5178-5222-80cb-2df3ce94b5fb',1),
 ('0b802d7f-4a82-53f9-82f3-eab43aeb1366','f5dc68cd-9707-5be6-a020-84cfaf10830b',2),
 ('0b802d7f-4a82-53f9-82f3-eab43aeb1366','16c5e2d5-1630-5e1f-bd3f-f8d506fc14b0',3),
 ('0b802d7f-4a82-53f9-82f3-eab43aeb1366','99c8baf2-4535-5701-93d8-0ba60f9bd3f6',4),
 ('0b802d7f-4a82-53f9-82f3-eab43aeb1366','5dc2d22e-8426-578b-aa90-fb3fd0efad3e',5),
 ('0b802d7f-4a82-53f9-82f3-eab43aeb1366','d1ffc85b-7825-59f7-a5fc-3fd8652b7a16',6),
 ('0b802d7f-4a82-53f9-82f3-eab43aeb1366','13974c2b-d8f1-510e-83bb-b6f8d298de11',7),
 ('e8325d87-89a4-5816-a7b4-d79480270fcd','45fe5408-1be9-506d-96e7-dbab1e08ad26',1),
 ('e8325d87-89a4-5816-a7b4-d79480270fcd','8b419930-bf37-5a3d-8a22-853c74a65000',2),
 ('e8325d87-89a4-5816-a7b4-d79480270fcd','06a54180-4bbe-537b-8114-7120947b3fe8',3),
 ('e8325d87-89a4-5816-a7b4-d79480270fcd','629ff323-9317-5b92-a677-f03e24be87d1',4),
 ('e8325d87-89a4-5816-a7b4-d79480270fcd','babebdd0-4303-5ba2-8165-817bb938fb16',5),
 ('7e1a883a-75f7-5029-b948-94b73d44346c','8952a4eb-f7b0-53c7-882f-b5a52e1887b6',1),
 ('7e1a883a-75f7-5029-b948-94b73d44346c','bed0b961-3527-5022-93bf-a4c3658d88c0',2),
 ('7e1a883a-75f7-5029-b948-94b73d44346c','b6dc62e4-aafa-5449-b0ef-f503e388e0ee',3),
 ('7e1a883a-75f7-5029-b948-94b73d44346c','97d7e8b2-6957-50c9-8e1b-6e14c2be5fde',4),
 ('f95c25d7-c41a-526e-adda-2033ada022b3','044164fa-6821-59ea-a1ad-32e6ec65c114',1),
 ('f95c25d7-c41a-526e-adda-2033ada022b3','52feab51-5178-5222-80cb-2df3ce94b5fb',2),
 ('f95c25d7-c41a-526e-adda-2033ada022b3','f5dc68cd-9707-5be6-a020-84cfaf10830b',3),
 ('f95c25d7-c41a-526e-adda-2033ada022b3','16c5e2d5-1630-5e1f-bd3f-f8d506fc14b0',4),
 ('f95c25d7-c41a-526e-adda-2033ada022b3','bed0b961-3527-5022-93bf-a4c3658d88c0',5),
 ('f95c25d7-c41a-526e-adda-2033ada022b3','99c8baf2-4535-5701-93d8-0ba60f9bd3f6',6),
 ('f95c25d7-c41a-526e-adda-2033ada022b3','a4543238-bd40-50cf-8631-d65400cd3e78',7),
 ('f95c25d7-c41a-526e-adda-2033ada022b3','d1ffc85b-7825-59f7-a5fc-3fd8652b7a16',8),
 ('f95c25d7-c41a-526e-adda-2033ada022b3','13974c2b-d8f1-510e-83bb-b6f8d298de11',9),
 ('f95c25d7-c41a-526e-adda-2033ada022b3','babebdd0-4303-5ba2-8165-817bb938fb16',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('f9cb5153-c8b8-53be-bad3-46072761d920','20000000-0000-0000-0000-000000000004',$p$la testa$p$,$p$la cabeza$p$,341,'sustantivo'),
 ('259e4023-6d1f-5bfd-9b34-f9eb723bff5c','20000000-0000-0000-0000-000000000004',$p$il braccio$p$,$p$el brazo$p$,342,'sustantivo'),
 ('cf397e4b-1d73-523a-956b-9a48b4d800ea','20000000-0000-0000-0000-000000000004',$p$la gamba$p$,$p$la pierna$p$,343,'sustantivo'),
 ('091a61d1-4c12-56d7-9ec1-1b54f5e48cf4','20000000-0000-0000-0000-000000000004',$p$la schiena$p$,$p$la espalda$p$,344,'sustantivo'),
 ('f6457ce3-2169-5225-9c57-81d06d9a72ac','20000000-0000-0000-0000-000000000004',$p$la pancia$p$,$p$la barriga$p$,345,'sustantivo'),
 ('9857f228-2aef-5ab7-88aa-30cb1c280840','20000000-0000-0000-0000-000000000004',$p$la gola$p$,$p$la garganta$p$,346,'sustantivo'),
 ('d9316213-ca68-5e51-b6de-e58d2b5f199a','20000000-0000-0000-0000-000000000004',$p$i denti$p$,$p$los dientes$p$,347,'sustantivo'),
 ('fd9f8131-218d-5414-8fec-a90b826547ff','20000000-0000-0000-0000-000000000004',$p$il piede$p$,$p$el pie$p$,348,'sustantivo'),
 ('5150e2ba-2f6a-5683-87de-be4a50a4657f','20000000-0000-0000-0000-000000000004',$p$la mano$p$,$p$la mano$p$,349,'sustantivo'),
 ('9ec2a13d-2f43-59d9-a714-ac5721eb2e0f','20000000-0000-0000-0000-000000000004',$p$lo stomaco$p$,$p$el estómago$p$,350,'sustantivo'),
 ('e7547408-beda-53dd-9205-f7e4d0f5cab1','20000000-0000-0000-0000-000000000004',$p$la febbre$p$,$p$la fiebre$p$,351,'sustantivo'),
 ('81fbe172-9f50-5d3a-8a54-bb66ee9d7ebb','20000000-0000-0000-0000-000000000004',$p$malato$p$,$p$enfermo$p$,352,'adjetivo'),
 ('3f8b6cce-fdc3-5a2b-935b-774850021365','20000000-0000-0000-0000-000000000004',$p$ho mal di testa$p$,$p$me duele la cabeza$p$,353,'expresion'),
 ('6661e04d-ef7a-5804-b03d-ad47c4f8e995','20000000-0000-0000-0000-000000000004',$p$mi fa male$p$,$p$me duele$p$,354,'expresion'),
 ('f7c5eacd-e0cc-585d-ada0-b4e8c8442730','20000000-0000-0000-0000-000000000004',$p$bisogna$p$,$p$hay que$p$,355,'verbo'),
 ('39c1ef4e-fcb7-57b1-80b8-572115db8558','20000000-0000-0000-0000-000000000004',$p$dovresti$p$,$p$deberías$p$,356,'verbo')
on conflict (id) do nothing;

commit;