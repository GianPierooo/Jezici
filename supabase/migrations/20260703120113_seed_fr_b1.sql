-- 20260703120113_seed_fr_b1.sql
-- Currículo B1 del curso es→fr (6 unidades). Molde es→pt.
-- Contenido scopeado a course_id=20000000-0000-0000-0000-000000000003 → aislamiento multicurso por
-- jz_active_course. Unidades order_index continúan la cadena → gating al nivel previo.
begin;
insert into languages (id, code, name) values
  ('10000000-0000-0000-0000-000000000004','fr',$p$Français$p$) on conflict (id) do nothing;
insert into courses (id, source_language_id, target_language_id, is_active) values
  ('20000000-0000-0000-0000-000000000003','10000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000004',true) on conflict (id) do nothing;

-- ── Unidad 13 (B1·fr): Deseos y necesidad (subjonctif) ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('380d58c2-2cea-50e2-b4dc-60f477f516f2','20000000-0000-0000-0000-000000000003','B1',13,$p$Deseos y necesidad (subjonctif)$p$,'#6C3483','auto_awesome')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('0d3f6a58-199c-525b-9263-97a5189ed5dc','380d58c2-2cea-50e2-b4dc-60f477f516f2',1,$p$Il faut que… (necesidad)$p$,$p$Il faut que… (necesidad)$p$,'lesson',15),
 ('0d199356-da90-571f-8430-544868b3613b','380d58c2-2cea-50e2-b4dc-60f477f516f2',2,$p$Je veux que… (deseo)$p$,$p$Je veux que… (deseo)$p$,'lesson',15),
 ('9eff6c82-ae54-5a4d-b0df-3a6b5b088224','380d58c2-2cea-50e2-b4dc-60f477f516f2',3,$p$Emoción y duda (content que, ne pas croire que)$p$,$p$Emoción y duda (content que, ne pas croire que)$p$,'lesson',15),
 ('02cf1cea-42b0-5a48-a3f2-ab7cd188db25','380d58c2-2cea-50e2-b4dc-60f477f516f2',4,$p$bien que, pour que (conjunciones)$p$,$p$bien que, pour que (conjunciones)$p$,'lesson',15),
 ('a5f86d3d-b9f6-57cf-a390-90585fb23812','380d58c2-2cea-50e2-b4dc-60f477f516f2',5,$p$🏁 Checkpoint Unité 13$p$,$p$Usa el subjonctif présent para expresar necesidad, deseo, emoción y duda.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('677240a7-fb40-5605-854d-9f2eb1d90bf4','20000000-0000-0000-0000-000000000003','checkpoint','B1','380d58c2-2cea-50e2-b4dc-60f477f516f2',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('7037349a-3ab6-57ff-9466-37c695e67fa6'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','reading','match',$p$Une la frase francesa con su traducción.$p$,$j${"pairs": [{"en": "Il faut que tu fasses tes devoirs.", "es": "Es necesario que hagas tus deberes."}, {"en": "Il faut que je sois à l'heure.", "es": "Es necesario que yo esté a tiempo."}, {"en": "Il faut qu'elle aille chez le médecin.", "es": "Es necesario que ella vaya al médico."}]}$j$::jsonb,$j${"pairs": [["Il faut que tu fasses tes devoirs.", "Es necesario que hagas tus deberes."], ["Il faut que je sois à l'heure.", "Es necesario que yo esté a tiempo."], ["Il faut qu'elle aille chez le médecin.", "Es necesario que ella vaya al médico."]]}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$il_faut_que$p$, $p$reading$p$]),
('87bf5c94-fc9f-5533-ba23-a9131beac995'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','writing','cloze',$p$Completa con el subjonctif de « faire ».$p$,$j${"text": "Il faut que tu ___ attention."}$j$::jsonb,$j${"value": "fasses", "accepted": ["fasses"]}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$faire_subj$p$, $p$writing$p$]),
('1f60eb11-ce67-5cfd-9be0-e39e9ee95b91'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Il faut que je sois patient.", "Il faut que je suis patient.", "Il faut que je serai patient."], "say": "Il faut que je sois patient.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/1f60eb11-ce67-5cfd-9be0-e39e9ee95b91.mp3"}$j$::jsonb,$j${"value": "Il faut que je sois patient."}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$etre_subj$p$, $p$listening$p$]),
('1675c671-6d5c-51df-a3f7-499794846748'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Il faut que nous allions à la gare avant midi.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/1675c671-6d5c-51df-a3f7-499794846748.mp3"}$j$::jsonb,$j${"expected": "Il faut que nous allions à la gare avant midi."}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$aller_subj$p$, $p$speaking$p$]),
('587a7d2e-d60c-54ac-9ad2-aad1d629c199'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','reading','multiple_choice',$p$Elige la forma correcta del subjonctif.$p$,$j${"options": ["Je veux que tu viennes avec moi.", "Je veux que tu viens avec moi.", "Je veux que tu venir avec moi."]}$j$::jsonb,$j${"value": "Je veux que tu viennes avec moi."}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$vouloir_que$p$, $p$reading$p$]),
('28f9c5fd-c49b-58a5-b3be-156b3147e2a6'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','writing','word_bank',$p$Construye la frase: Quiero que vengas mañana.$p$,$j${"tiles": ["Je", "veux", "que", "tu", "viennes", "demain", "viens", "venir"]}$j$::jsonb,$j${"value": "Je veux que tu viennes demain", "sequence": ["Je", "veux", "que", "tu", "viennes", "demain"]}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$venir_subj$p$, $p$writing$p$]),
('398f3b67-6305-535c-82ce-920cef86b758'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','writing','translation',$p$Traduce: Deseo que tengas suerte.$p$,$j${"source": "Deseo que tengas suerte."}$j$::jsonb,$j${"value": "Je souhaite que tu aies de la chance.", "accepted": ["Je souhaite que tu aies de la chance", "Je souhaite que tu aies de la chance."]}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$souhaiter_que$p$, $p$writing$p$]),
('b6457c8a-142c-5a4c-9b94-4ab50df2f57e'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','reading','multiple_choice',$p$Elige la forma correcta del subjonctif.$p$,$j${"options": ["Je souhaite que vous soyez contents.", "Je souhaite que vous êtes contents.", "Je souhaite que vous serez contents."]}$j$::jsonb,$j${"value": "Je souhaite que vous soyez contents."}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$souhaiter_subj_mc$p$, $p$reading$p$]),
('eff854a6-edb4-5ea9-a7e9-afb800087974'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Je veux que tu puisses venir.", "Je veux que tu peux venir.", "Je veux que tu pourras venir."], "say": "Je veux que tu puisses venir.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/eff854a6-edb4-5ea9-a7e9-afb800087974.mp3"}$j$::jsonb,$j${"value": "Je veux que tu puisses venir."}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$pouvoir_subj$p$, $p$listening$p$]),
('a0a79cd5-d44e-537f-ba80-d61ebcf89857'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Mes parents veulent que je sois heureux.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/a0a79cd5-d44e-537f-ba80-d61ebcf89857.mp3"}$j$::jsonb,$j${"expected": "Mes parents veulent que je sois heureux."}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$vouloir_que_speak$p$, $p$speaking$p$]),
('234c357b-b6e6-5d9c-a6b7-e007f8fe6881'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','reading','match',$p$Une la frase francesa con su traducción.$p$,$j${"pairs": [{"en": "Je suis content que tu sois là.", "es": "Estoy contento de que estés aquí."}, {"en": "Je suis désolé que tu aies mal.", "es": "Lamento que te duela."}, {"en": "Je doute qu'il puisse venir.", "es": "Dudo que él pueda venir."}]}$j$::jsonb,$j${"pairs": [["Je suis content que tu sois là.", "Estoy contento de que estés aquí."], ["Je suis désolé que tu aies mal.", "Lamento que te duela."], ["Je doute qu'il puisse venir.", "Dudo que él pueda venir."]]}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$content_que$p$, $p$reading$p$]),
('233de582-0f35-5e0d-a207-7a1917916c72'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','writing','cloze',$p$Completa con el subjonctif de « être ».$p$,$j${"text": "Je suis heureux que tu ___ là."}$j$::jsonb,$j${"value": "sois", "accepted": ["sois"]}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$etre_subj_emotion$p$, $p$writing$p$]),
('8fa74e48-6342-5f79-8733-1da0015ec1f7'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','reading','multiple_choice',$p$Elige la forma correcta del subjonctif.$p$,$j${"options": ["J'ai peur qu'il ait un problème.", "J'ai peur qu'il a un problème.", "J'ai peur qu'il aura un problème."]}$j$::jsonb,$j${"value": "J'ai peur qu'il ait un problème."}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$avoir_subj$p$, $p$reading$p$]),
('746333b9-5fb2-596e-99e6-84375b7db5c5'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Je doute qu'elle sache la réponse.", "Je doute qu'elle sait la réponse.", "Je doute qu'elle saura la réponse."], "say": "Je doute qu'elle sache la réponse.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/746333b9-5fb2-596e-99e6-84375b7db5c5.mp3"}$j$::jsonb,$j${"value": "Je doute qu'elle sache la réponse."}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$douter_que$p$, $p$listening$p$]),
('45fde160-949f-59bf-ba70-dc9b13538069'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Je suis désolé que vous ne puissiez pas rester.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/45fde160-949f-59bf-ba70-dc9b13538069.mp3"}$j$::jsonb,$j${"expected": "Je suis désolé que vous ne puissiez pas rester."}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$emotion_speak$p$, $p$speaking$p$]),
('8ce10986-a13c-5b82-be4d-e66c685526ca'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','reading','multiple_choice',$p$Elige la forma correcta del subjonctif.$p$,$j${"options": ["Bien que ce soit difficile, je continue.", "Bien que c'est difficile, je continue.", "Bien que ce sera difficile, je continue."]}$j$::jsonb,$j${"value": "Bien que ce soit difficile, je continue."}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$bien_que$p$, $p$reading$p$]),
('70952957-316a-52d3-90e6-a844f20a1c6d'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','writing','cloze',$p$Completa con el subjonctif de « avoir ».$p$,$j${"text": "Je t'explique pour que tu ___ moins de doutes."}$j$::jsonb,$j${"value": "aies", "accepted": ["aies"]}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$pour_que$p$, $p$writing$p$]),
('d888685c-7bbb-545f-8064-6ee5707a1dc3'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','writing','reorder',$p$Ordena las palabras para formar la frase.$p$,$j${"tiles": ["qu'elle", "vienne", "Je", "pour", "l'appelle"]}$j$::jsonb,$j${"value": "Je l'appelle pour qu'elle vienne"}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$pour_que_reorder$p$, $p$writing$p$]),
('8559fa78-20ba-5ea1-acfe-6b6b9ec4da92'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Bien que tu sois fatigué, tu travailles.", "Bien que tu es fatigué, tu travailles.", "Bien que tu seras fatigué, tu travailles."], "say": "Bien que tu sois fatigué, tu travailles.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/8559fa78-20ba-5ea1-acfe-6b6b9ec4da92.mp3"}$j$::jsonb,$j${"value": "Bien que tu sois fatigué, tu travailles."}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$bien_que_listen$p$, $p$listening$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('0d3f6a58-199c-525b-9263-97a5189ed5dc','7037349a-3ab6-57ff-9466-37c695e67fa6',1),
 ('0d3f6a58-199c-525b-9263-97a5189ed5dc','87bf5c94-fc9f-5533-ba23-a9131beac995',2),
 ('0d3f6a58-199c-525b-9263-97a5189ed5dc','1f60eb11-ce67-5cfd-9be0-e39e9ee95b91',3),
 ('0d3f6a58-199c-525b-9263-97a5189ed5dc','1675c671-6d5c-51df-a3f7-499794846748',4),
 ('0d199356-da90-571f-8430-544868b3613b','587a7d2e-d60c-54ac-9ad2-aad1d629c199',1),
 ('0d199356-da90-571f-8430-544868b3613b','28f9c5fd-c49b-58a5-b3be-156b3147e2a6',2),
 ('0d199356-da90-571f-8430-544868b3613b','398f3b67-6305-535c-82ce-920cef86b758',3),
 ('0d199356-da90-571f-8430-544868b3613b','b6457c8a-142c-5a4c-9b94-4ab50df2f57e',4),
 ('0d199356-da90-571f-8430-544868b3613b','eff854a6-edb4-5ea9-a7e9-afb800087974',5),
 ('0d199356-da90-571f-8430-544868b3613b','a0a79cd5-d44e-537f-ba80-d61ebcf89857',6),
 ('9eff6c82-ae54-5a4d-b0df-3a6b5b088224','234c357b-b6e6-5d9c-a6b7-e007f8fe6881',1),
 ('9eff6c82-ae54-5a4d-b0df-3a6b5b088224','233de582-0f35-5e0d-a207-7a1917916c72',2),
 ('9eff6c82-ae54-5a4d-b0df-3a6b5b088224','8fa74e48-6342-5f79-8733-1da0015ec1f7',3),
 ('9eff6c82-ae54-5a4d-b0df-3a6b5b088224','746333b9-5fb2-596e-99e6-84375b7db5c5',4),
 ('9eff6c82-ae54-5a4d-b0df-3a6b5b088224','45fde160-949f-59bf-ba70-dc9b13538069',5),
 ('02cf1cea-42b0-5a48-a3f2-ab7cd188db25','8ce10986-a13c-5b82-be4d-e66c685526ca',1),
 ('02cf1cea-42b0-5a48-a3f2-ab7cd188db25','70952957-316a-52d3-90e6-a844f20a1c6d',2),
 ('02cf1cea-42b0-5a48-a3f2-ab7cd188db25','d888685c-7bbb-545f-8064-6ee5707a1dc3',3),
 ('02cf1cea-42b0-5a48-a3f2-ab7cd188db25','8559fa78-20ba-5ea1-acfe-6b6b9ec4da92',4),
 ('a5f86d3d-b9f6-57cf-a390-90585fb23812','7037349a-3ab6-57ff-9466-37c695e67fa6',1),
 ('a5f86d3d-b9f6-57cf-a390-90585fb23812','587a7d2e-d60c-54ac-9ad2-aad1d629c199',2),
 ('a5f86d3d-b9f6-57cf-a390-90585fb23812','b6457c8a-142c-5a4c-9b94-4ab50df2f57e',3),
 ('a5f86d3d-b9f6-57cf-a390-90585fb23812','87bf5c94-fc9f-5533-ba23-a9131beac995',4),
 ('a5f86d3d-b9f6-57cf-a390-90585fb23812','28f9c5fd-c49b-58a5-b3be-156b3147e2a6',5),
 ('a5f86d3d-b9f6-57cf-a390-90585fb23812','398f3b67-6305-535c-82ce-920cef86b758',6),
 ('a5f86d3d-b9f6-57cf-a390-90585fb23812','1f60eb11-ce67-5cfd-9be0-e39e9ee95b91',7),
 ('a5f86d3d-b9f6-57cf-a390-90585fb23812','eff854a6-edb4-5ea9-a7e9-afb800087974',8),
 ('a5f86d3d-b9f6-57cf-a390-90585fb23812','1675c671-6d5c-51df-a3f7-499794846748',9),
 ('a5f86d3d-b9f6-57cf-a390-90585fb23812','a0a79cd5-d44e-537f-ba80-d61ebcf89857',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('2efb9ea4-ad9b-526f-830b-b73895b39a93','20000000-0000-0000-0000-000000000003',$p$il faut que$p$,$p$es necesario que$p$,361,'expresion'),
 ('8fe6415f-63eb-5e6b-814e-45c56c2e01d8','20000000-0000-0000-0000-000000000003',$p$vouloir$p$,$p$querer$p$,362,'verbo'),
 ('760965e1-632c-588f-9b82-19b2528ff631','20000000-0000-0000-0000-000000000003',$p$souhaiter$p$,$p$desear$p$,363,'verbo'),
 ('e33046c8-b8d0-5ac9-a20a-259d623d96a4','20000000-0000-0000-0000-000000000003',$p$falloir$p$,$p$hacer falta$p$,364,'verbo'),
 ('097a5149-b3d5-5c8e-ad6f-bfa8e29d69c7','20000000-0000-0000-0000-000000000003',$p$le subjonctif$p$,$p$el subjuntivo$p$,365,'sustantivo'),
 ('3bda47d6-cf77-543d-a8e5-31228384f6a2','20000000-0000-0000-0000-000000000003',$p$bien que$p$,$p$aunque$p$,366,'expresion'),
 ('e5f2e5cc-9710-5cde-8bf9-512b847cfd3c','20000000-0000-0000-0000-000000000003',$p$pour que$p$,$p$para que$p$,367,'expresion'),
 ('2d0da27a-8f26-503e-bc00-1ecdba7b4d7c','20000000-0000-0000-0000-000000000003',$p$le doute$p$,$p$la duda$p$,368,'sustantivo'),
 ('11974db6-8b6f-5e91-bfe6-a933c68bb410','20000000-0000-0000-0000-000000000003',$p$l'émotion$p$,$p$la emoción$p$,369,'sustantivo'),
 ('6a388786-6900-562a-b06b-12d60cdf073a','20000000-0000-0000-0000-000000000003',$p$content$p$,$p$contento$p$,370,'adjetivo'),
 ('101b2bc6-7fb0-5504-96a6-9aea608b9861','20000000-0000-0000-0000-000000000003',$p$désolé$p$,$p$apenado$p$,371,'adjetivo'),
 ('0098eff5-9826-5cf5-a6b2-bc3331427529','20000000-0000-0000-0000-000000000003',$p$nécessaire$p$,$p$necesario$p$,372,'adjetivo'),
 ('e18b69c6-43f9-54f9-9e89-d5f92b42ad8f','20000000-0000-0000-0000-000000000003',$p$la peur$p$,$p$el miedo$p$,373,'sustantivo'),
 ('ef53280d-e02b-5fb0-b329-5aaf37bfc98b','20000000-0000-0000-0000-000000000003',$p$avant que$p$,$p$antes de que$p$,374,'expresion'),
 ('cc07fa31-93ab-5dfa-a373-bab9a0a3e975','20000000-0000-0000-0000-000000000003',$p$à condition que$p$,$p$con la condición de que$p$,375,'expresion'),
 ('b6eb1a02-23dd-579f-ac30-520da757b777','20000000-0000-0000-0000-000000000003',$p$heureux$p$,$p$feliz$p$,376,'adjetivo')
on conflict (id) do nothing;

-- ── Unidad 14 (B1·fr): El futuro y el condicional ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('e9dbc2e0-9b82-5a42-a5bb-70e1638d0740','20000000-0000-0000-0000-000000000003','B1',14,$p$El futuro y el condicional$p$,'#1F618D','schedule')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('75631a4d-39bd-52c9-86ea-81664a4546ad','e9dbc2e0-9b82-5a42-a5bb-70e1638d0740',1,$p$El futur simple$p$,$p$El futur simple$p$,'lesson',15),
 ('2a27e76a-004c-53c2-affd-8047cd0bc32e','e9dbc2e0-9b82-5a42-a5bb-70e1638d0740',2,$p$El conditionnel présent$p$,$p$El conditionnel présent$p$,'lesson',15),
 ('945dd2b5-543b-5121-8ede-b0080fb922e5','e9dbc2e0-9b82-5a42-a5bb-70e1638d0740',3,$p$Cortesía y peticiones$p$,$p$Cortesía y peticiones$p$,'lesson',15),
 ('990c2c05-cea9-57de-91e3-af457b8ab22b','e9dbc2e0-9b82-5a42-a5bb-70e1638d0740',4,$p$Hipótesis con «si»$p$,$p$Hipótesis con «si»$p$,'lesson',15),
 ('1c3a59a6-a2b5-51d7-877c-1fa3b62f31b8','e9dbc2e0-9b82-5a42-a5bb-70e1638d0740',5,$p$🏁 Checkpoint Unité 14$p$,$p$Demuestra que dominas el futur simple (je ferai, nous serons), el conditionnel présent (je ferais, je voudrais) y las hipótesis con «si» (Si j'avais le temps, je voyagerais).$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('0193e2c5-c9c3-5e30-ac9b-fd33295033ed','20000000-0000-0000-0000-000000000003','checkpoint','B1','e9dbc2e0-9b82-5a42-a5bb-70e1638d0740',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('e9399aba-0c3d-5338-af21-54f3c6eee51a'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','reading','match',$p$Une cada forma en francés con su traducción.$p$,$j${"pairs": [{"en": "je ferai", "es": "yo haré"}, {"en": "tu iras", "es": "tú irás"}, {"en": "nous serons", "es": "nosotros seremos"}]}$j$::jsonb,$j${"pairs": [["je ferai", "yo haré"], ["tu iras", "tú irás"], ["nous serons", "nosotros seremos"]]}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$futur_endings$p$, $p$reading$p$]),
('bb93c0d1-e847-5e9b-b627-e9e67051d8f0'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','reading','multiple_choice',$p$Demain, il ___ vingt ans. (futuro de «avoir»)$p$,$j${"options": ["aura", "avait", "a eu"]}$j$::jsonb,$j${"value": "aura"}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$futur_avoir$p$, $p$reading$p$]),
('8a1e84f7-5077-508a-9d43-bb965fa3a55b'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','writing','cloze',$p$Completa en futur simple: «Nous ___ (partir) à Paris la semaine prochaine.»$p$,$j${"text": "Nous ___ à Paris la semaine prochaine."}$j$::jsonb,$j${"value": "partirons", "accepted": ["partirons"]}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$futur_cloze$p$, $p$writing$p$]),
('7f544309-36ac-5842-b581-fe3fcc493be1'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','writing','translation',$p$Traduce: «Mañana iré al mercado.»$p$,$j${"source": "Mañana iré al mercado."}$j$::jsonb,$j${"value": "Demain, j'irai au marché.", "accepted": ["Demain, j'irai au marché.", "Demain j'irai au marché.", "Demain, j'irai au marché", "Demain j'irai au marché", "Demain, j’irai au marché.", "Demain j’irai au marché.", "J'irai au marché demain.", "J'irai au marché demain"]}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$futur_translation$p$, $p$writing$p$]),
('d8307860-abcf-54b9-a8ef-f68970d6d182'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Un jour, je serai professeur.", "Un jour, je serais professeur.", "Un jour, j'étais professeur."], "say": "Un jour, je serai professeur.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/d8307860-abcf-54b9-a8ef-f68970d6d182.mp3"}$j$::jsonb,$j${"value": "Un jour, je serai professeur."}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$futur_listening$p$, $p$listening$p$]),
('5379e9fa-7d93-5f63-917d-018d80887ded'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','reading','match',$p$Une cada forma en francés con su traducción.$p$,$j${"pairs": [{"en": "je ferais", "es": "yo haría"}, {"en": "tu irais", "es": "tú irías"}, {"en": "nous serions", "es": "nosotros seríamos"}]}$j$::jsonb,$j${"pairs": [["je ferais", "yo haría"], ["tu irais", "tú irías"], ["nous serions", "nosotros seríamos"]]}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$conditionnel_endings$p$, $p$reading$p$]),
('9e3997f4-5a0b-531c-8938-5c2125286608'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','reading','multiple_choice',$p$«À ta place, je ___ plus prudent.» (condicional de «être»)$p$,$j${"options": ["serais", "serai", "suis"]}$j$::jsonb,$j${"value": "serais"}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$conditionnel_form$p$, $p$reading$p$]),
('96fd6e5d-b51b-5aa0-845c-e9e7ae440e0c'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','writing','cloze',$p$Completa en conditionnel présent: «Avec plus d'argent, nous ___ (voyager) davantage.»$p$,$j${"text": "Avec plus d'argent, nous ___ davantage."}$j$::jsonb,$j${"value": "voyagerions", "accepted": ["voyagerions"]}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$conditionnel_cloze$p$, $p$writing$p$]),
('5461ced3-f3cc-5909-9873-67b278ae0cdf'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Je ferais un voyage si je pouvais.", "Je ferai un voyage si je peux.", "Je faisais un voyage si je pouvais."], "say": "Je ferais un voyage si je pouvais.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/5461ced3-f3cc-5909-9873-67b278ae0cdf.mp3"}$j$::jsonb,$j${"value": "Je ferais un voyage si je pouvais."}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$futur_vs_conditionnel$p$, $p$listening$p$]),
('1b1bc399-3938-50d6-a2a3-64fe3d0f5124'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "À ta place, je prendrais le train.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/1b1bc399-3938-50d6-a2a3-64fe3d0f5124.mp3"}$j$::jsonb,$j${"expected": "À ta place, je prendrais le train."}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$conditionnel_speaking$p$, $p$speaking$p$]),
('4323cb32-4a8d-5a1d-a99e-dfae24379427'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','reading','multiple_choice',$p$Pide algo con cortesía en un café: «___ un café, s'il vous plaît.»$p$,$j${"options": ["Je voudrais", "Je veux", "J'ai voulu"]}$j$::jsonb,$j${"value": "Je voudrais"}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$politeness_vouloir$p$, $p$reading$p$]),
('e1bee9c4-ccd0-58fd-b8ec-cea263fe1fe3'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','writing','word_bank',$p$Ordena una petición cortés con «pouvoir» en condicional: «¿Podría usted repetir, por favor?»$p$,$j${"tiles": ["Pourriez-vous", "répéter", "s'il vous plaît", "Pouvez", "voudrais"]}$j$::jsonb,$j${"value": "Pourriez-vous répéter s'il vous plaît", "sequence": ["Pourriez-vous", "répéter", "s'il vous plaît"]}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$politeness_pourriez$p$, $p$writing$p$]),
('1ff6f1f1-cf9d-586b-bf85-77b20a45ec1b'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','writing','translation',$p$Traduce con cortesía: «Me gustaría reservar una mesa.»$p$,$j${"source": "Me gustaría reservar una mesa."}$j$::jsonb,$j${"value": "Je voudrais réserver une table.", "accepted": ["Je voudrais réserver une table.", "Je voudrais réserver une table", "J'aimerais réserver une table.", "J'aimerais réserver une table", "J’aimerais réserver une table.", "Je voudrais réserver une table."]}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$politeness_translation$p$, $p$writing$p$]),
('7731d0b8-ffe2-55f8-9f7d-945862b8221d'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Est-ce que tu pourrais m'aider ?", "Est-ce que tu pourras m'aider ?", "Est-ce que tu peux m'aider ?"], "say": "Est-ce que tu pourrais m'aider ?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/7731d0b8-ffe2-55f8-9f7d-945862b8221d.mp3"}$j$::jsonb,$j${"value": "Est-ce que tu pourrais m'aider ?"}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$politeness_listening$p$, $p$listening$p$]),
('41d61cc2-c77b-57a6-a9cf-8eec6aedbbad'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Pourriez-vous m'indiquer la gare, s'il vous plaît ?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/41d61cc2-c77b-57a6-a9cf-8eec6aedbbad.mp3"}$j$::jsonb,$j${"expected": "Pourriez-vous m'indiquer la gare, s'il vous plaît ?"}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$politeness_speaking$p$, $p$speaking$p$]),
('50079e18-89c2-58e0-92b9-28bc07b2cebb'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','reading','match',$p$Une cada frase en francés con su traducción.$p$,$j${"pairs": [{"en": "Si j'avais le temps", "es": "Si tuviera tiempo"}, {"en": "je voyagerais", "es": "yo viajaría"}, {"en": "Si tu veux, tu peux", "es": "Si quieres, puedes"}]}$j$::jsonb,$j${"pairs": [["Si j'avais le temps", "Si tuviera tiempo"], ["je voyagerais", "yo viajaría"], ["Si tu veux, tu peux", "Si quieres, puedes"]]}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$si_hypothesis_match$p$, $p$reading$p$]),
('2cdeaeff-a124-59e8-9af9-c0b82911138e'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Si j'avais le temps, je voyagerais plus.", "Si j'aurais le temps, je voyagerais plus.", "Si j'avais le temps, je voyagerai plus."], "say": "Si j'avais le temps, je voyagerais plus.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/2cdeaeff-a124-59e8-9af9-c0b82911138e.mp3"}$j$::jsonb,$j${"value": "Si j'avais le temps, je voyagerais plus."}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$si_listening$p$, $p$listening$p$]),
('922b792c-80ed-5ffc-8992-094505488880'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','writing','reorder',$p$Ordena la frase: «Si fuera rico, compraría una casa.»$p$,$j${"tiles": ["Si", "j'étais", "riche,", "j'achèterais", "une maison", "j'acheterai"]}$j$::jsonb,$j${"value": "Si j'étais riche, j'achèterais une maison"}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$si_reorder$p$, $p$writing$p$]),
('265ab3cf-0ba0-52dd-b49d-e673d02e4734'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Si tu veux, tu peux venir avec nous.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/265ab3cf-0ba0-52dd-b49d-e673d02e4734.mp3"}$j$::jsonb,$j${"expected": "Si tu veux, tu peux venir avec nous."}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$si_real_condition$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('75631a4d-39bd-52c9-86ea-81664a4546ad','e9399aba-0c3d-5338-af21-54f3c6eee51a',1),
 ('75631a4d-39bd-52c9-86ea-81664a4546ad','bb93c0d1-e847-5e9b-b627-e9e67051d8f0',2),
 ('75631a4d-39bd-52c9-86ea-81664a4546ad','8a1e84f7-5077-508a-9d43-bb965fa3a55b',3),
 ('75631a4d-39bd-52c9-86ea-81664a4546ad','7f544309-36ac-5842-b581-fe3fcc493be1',4),
 ('75631a4d-39bd-52c9-86ea-81664a4546ad','d8307860-abcf-54b9-a8ef-f68970d6d182',5),
 ('2a27e76a-004c-53c2-affd-8047cd0bc32e','5379e9fa-7d93-5f63-917d-018d80887ded',1),
 ('2a27e76a-004c-53c2-affd-8047cd0bc32e','9e3997f4-5a0b-531c-8938-5c2125286608',2),
 ('2a27e76a-004c-53c2-affd-8047cd0bc32e','96fd6e5d-b51b-5aa0-845c-e9e7ae440e0c',3),
 ('2a27e76a-004c-53c2-affd-8047cd0bc32e','5461ced3-f3cc-5909-9873-67b278ae0cdf',4),
 ('2a27e76a-004c-53c2-affd-8047cd0bc32e','1b1bc399-3938-50d6-a2a3-64fe3d0f5124',5),
 ('945dd2b5-543b-5121-8ede-b0080fb922e5','4323cb32-4a8d-5a1d-a99e-dfae24379427',1),
 ('945dd2b5-543b-5121-8ede-b0080fb922e5','e1bee9c4-ccd0-58fd-b8ec-cea263fe1fe3',2),
 ('945dd2b5-543b-5121-8ede-b0080fb922e5','1ff6f1f1-cf9d-586b-bf85-77b20a45ec1b',3),
 ('945dd2b5-543b-5121-8ede-b0080fb922e5','7731d0b8-ffe2-55f8-9f7d-945862b8221d',4),
 ('945dd2b5-543b-5121-8ede-b0080fb922e5','41d61cc2-c77b-57a6-a9cf-8eec6aedbbad',5),
 ('990c2c05-cea9-57de-91e3-af457b8ab22b','50079e18-89c2-58e0-92b9-28bc07b2cebb',1),
 ('990c2c05-cea9-57de-91e3-af457b8ab22b','2cdeaeff-a124-59e8-9af9-c0b82911138e',2),
 ('990c2c05-cea9-57de-91e3-af457b8ab22b','922b792c-80ed-5ffc-8992-094505488880',3),
 ('990c2c05-cea9-57de-91e3-af457b8ab22b','265ab3cf-0ba0-52dd-b49d-e673d02e4734',4),
 ('1c3a59a6-a2b5-51d7-877c-1fa3b62f31b8','e9399aba-0c3d-5338-af21-54f3c6eee51a',1),
 ('1c3a59a6-a2b5-51d7-877c-1fa3b62f31b8','bb93c0d1-e847-5e9b-b627-e9e67051d8f0',2),
 ('1c3a59a6-a2b5-51d7-877c-1fa3b62f31b8','5379e9fa-7d93-5f63-917d-018d80887ded',3),
 ('1c3a59a6-a2b5-51d7-877c-1fa3b62f31b8','8a1e84f7-5077-508a-9d43-bb965fa3a55b',4),
 ('1c3a59a6-a2b5-51d7-877c-1fa3b62f31b8','7f544309-36ac-5842-b581-fe3fcc493be1',5),
 ('1c3a59a6-a2b5-51d7-877c-1fa3b62f31b8','96fd6e5d-b51b-5aa0-845c-e9e7ae440e0c',6),
 ('1c3a59a6-a2b5-51d7-877c-1fa3b62f31b8','d8307860-abcf-54b9-a8ef-f68970d6d182',7),
 ('1c3a59a6-a2b5-51d7-877c-1fa3b62f31b8','5461ced3-f3cc-5909-9873-67b278ae0cdf',8),
 ('1c3a59a6-a2b5-51d7-877c-1fa3b62f31b8','1b1bc399-3938-50d6-a2a3-64fe3d0f5124',9),
 ('1c3a59a6-a2b5-51d7-877c-1fa3b62f31b8','41d61cc2-c77b-57a6-a9cf-8eec6aedbbad',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('a612d38a-578e-5bff-81bd-a925e1ef02cd','20000000-0000-0000-0000-000000000003',$p$le futur$p$,$p$el futuro$p$,381,'n'),
 ('367544cb-84fb-5fa3-a401-c6bde6336d8e','20000000-0000-0000-0000-000000000003',$p$le projet$p$,$p$el proyecto$p$,382,'n'),
 ('bc4a8f87-6db4-5ddc-89d3-3879896b1a3a','20000000-0000-0000-0000-000000000003',$p$le rêve$p$,$p$el sueño$p$,383,'n'),
 ('c7ca8949-421a-5fab-9b2e-c02cb202d7ca','20000000-0000-0000-0000-000000000003',$p$l'avenir$p$,$p$el porvenir$p$,384,'n'),
 ('b894902b-cc78-557e-a615-863da47ad61a','20000000-0000-0000-0000-000000000003',$p$le voyage$p$,$p$el viaje$p$,385,'n'),
 ('e972d106-421b-5328-9106-9294e76d2dc7','20000000-0000-0000-0000-000000000003',$p$la chance$p$,$p$la suerte$p$,386,'n'),
 ('8095973c-2fea-573e-94c6-848d1602bf32','20000000-0000-0000-0000-000000000003',$p$le temps$p$,$p$el tiempo$p$,387,'n'),
 ('bbcb53b0-3caf-50eb-8267-9e550ed8bff6','20000000-0000-0000-0000-000000000003',$p$l'argent$p$,$p$el dinero$p$,388,'n'),
 ('493941a7-4298-5df3-9dcc-1303d6db8949','20000000-0000-0000-0000-000000000003',$p$la possibilité$p$,$p$la posibilidad$p$,389,'n'),
 ('8ea61e9b-af8f-5ad4-992f-166e2ceed499','20000000-0000-0000-0000-000000000003',$p$le conseil$p$,$p$el consejo$p$,390,'n'),
 ('c803e62a-ab45-56e3-91d8-d75146966c3a','20000000-0000-0000-0000-000000000003',$p$peut-être$p$,$p$quizás$p$,391,'adv'),
 ('654062ae-16b1-592b-8549-690c309f232e','20000000-0000-0000-0000-000000000003',$p$bientôt$p$,$p$pronto$p$,392,'adv'),
 ('6b7a38d2-afda-52b3-b273-ad49cdac801f','20000000-0000-0000-0000-000000000003',$p$demain$p$,$p$mañana$p$,393,'adv'),
 ('052314d3-2330-5e1a-adb2-83185fbd580a','20000000-0000-0000-0000-000000000003',$p$si$p$,$p$si$p$,394,'conj'),
 ('d1667223-f4cd-53fd-8216-68607b3ae1de','20000000-0000-0000-0000-000000000003',$p$voyager$p$,$p$viajar$p$,395,'v'),
 ('c1a875c0-d6f9-570b-8f7b-5211f57cecc0','20000000-0000-0000-0000-000000000003',$p$souhaiter$p$,$p$desear$p$,396,'v')
on conflict (id) do nothing;

-- ── Unidad 15 (B1·fr): Pronombres relativos (dont, où) ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('ac407d8e-c685-5d76-b975-40aca6d423d8','20000000-0000-0000-0000-000000000003','B1',15,$p$Pronombres relativos (dont, où)$p$,'#117864','link')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('dada36b2-7185-5aab-b3c3-6b81853943d1','ac407d8e-c685-5d76-b975-40aca6d423d8',1,$p$qui y que: sujeto o complemento$p$,$p$qui y que: sujeto o complemento$p$,'lesson',15),
 ('b7193bc1-8398-5101-8875-c6b8dde811dd','ac407d8e-c685-5d76-b975-40aca6d423d8',2,$p$dont: los verbos y nombres con «de»$p$,$p$dont: los verbos y nombres con «de»$p$,'lesson',15),
 ('561d7cc1-738e-5fe8-87f4-69f4a03660e5','ac407d8e-c685-5d76-b975-40aca6d423d8',3,$p$où: lugar y tiempo$p$,$p$où: lugar y tiempo$p$,'lesson',15),
 ('eececa2a-9451-5c30-a5f0-bd9a2b363d89','ac407d8e-c685-5d76-b975-40aca6d423d8',4,$p$Todo junto: elige el relativo$p$,$p$Todo junto: elige el relativo$p$,'lesson',15),
 ('1b010889-b836-5025-b816-f4db14fe16f8','ac407d8e-c685-5d76-b975-40aca6d423d8',5,$p$🏁 Checkpoint Unité 15$p$,$p$Une frases con qui, que, dont y où. Elige el pronombre según su función: qui (sujeto), que (complemento directo), dont (con «de»: hablar de, el… cuyo…) y où (lugar y tiempo).$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('cd0291f0-b9a3-523e-b052-7bccc37069de','20000000-0000-0000-0000-000000000003','checkpoint','B1','ac407d8e-c685-5d76-b975-40aca6d423d8',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('c417ba84-1c87-5aba-b682-f3a80d39f966'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','reading','match',$p$Une cada frase en francés con su traducción.$p$,$j${"pairs": [{"en": "la femme qui parle", "es": "la mujer que habla"}, {"en": "le livre que je lis", "es": "el libro que leo"}, {"en": "l'ami qui arrive", "es": "el amigo que llega"}]}$j$::jsonb,$j${"pairs": [["la femme qui parle", "la mujer que habla"], ["le livre que je lis", "el libro que leo"], ["l'ami qui arrive", "el amigo que llega"]]}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$qui_que_match$p$, $p$reading$p$]),
('fd8a67ba-7be8-5b96-a306-458af3a07fb6'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','reading','multiple_choice',$p$Completa: «C'est le voisin ___ habite à côté» (el vecino es el sujeto del verbo). Elige el relativo correcto.$p$,$j${"options": ["qui", "que", "dont"]}$j$::jsonb,$j${"value": "qui"}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$qui_sujeto$p$, $p$reading$p$]),
('3c8debb7-f4fd-5b3b-87cb-ab842e6070d7'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','reading','multiple_choice',$p$Completa: «Voici le roman ___ j'ai lu» (le roman es el complemento directo de lire). Elige el relativo correcto.$p$,$j${"options": ["qui", "que", "où"]}$j$::jsonb,$j${"value": "que"}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$que_cod$p$, $p$reading$p$]),
('9dcca35f-5e76-5765-97ee-611610a1bc8b'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','writing','cloze',$p$Escribe el relativo (sujeto del verbo travaille): «J'ai une collègue ___ travaille avec moi.»$p$,$j${"text": "J'ai une collègue ___ travaille avec moi."}$j$::jsonb,$j${"value": "qui", "accepted": ["qui"]}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$qui_sujeto_cloze$p$, $p$writing$p$]),
('2b073e65-5887-552d-bf55-8bc7300e778c'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','reading','multiple_choice',$p$Completa: «C'est le livre ___ je parle souvent» (se dice parler DE quelque chose). Elige el relativo correcto.$p$,$j${"options": ["dont", "que", "qui"]}$j$::jsonb,$j${"value": "dont"}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$dont_parler_de$p$, $p$reading$p$]),
('0f1bfac7-5b8a-5287-9126-cb54c9b8123e'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','reading','multiple_choice',$p$Completa: «La fille ___ le père est médecin est mon amie» (el padre DE la chica → le père de la fille). Elige el relativo correcto.$p$,$j${"options": ["dont", "qui", "où"]}$j$::jsonb,$j${"value": "dont"}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$dont_pere$p$, $p$reading$p$]),
('9fc10cb4-778a-5e3b-9994-01a95546b8d9'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','writing','cloze',$p$Escribe el relativo (avoir besoin DE): «Voici l'outil ___ j'ai besoin.»$p$,$j${"text": "Voici l'outil ___ j'ai besoin."}$j$::jsonb,$j${"value": "dont", "accepted": ["dont"]}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$dont_besoin$p$, $p$writing$p$]),
('7b462bcb-aee3-5057-93ef-c3aab1509967'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','writing','translation',$p$Traduce: «Es un momento del que me acuerdo.» (se souvenir DE)$p$,$j${"source": "Es un momento del que me acuerdo."}$j$::jsonb,$j${"value": "C'est un moment dont je me souviens.", "accepted": ["C'est un moment dont je me souviens", "C'est un moment dont je me souviens.", "C’est un moment dont je me souviens.", "C’est un moment dont je me souviens"]}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$dont_souvenir$p$, $p$writing$p$]),
('d1262b6b-db12-59dd-bc6a-730f78f6a7a7'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','writing','word_bank',$p$Ordena las fichas: «El autor del que hablamos es famoso.»$p$,$j${"tiles": ["L'auteur", "dont", "nous", "parlons", "est", "célèbre", "que", "qui"]}$j$::jsonb,$j${"value": "L'auteur dont nous parlons est célèbre", "sequence": ["L'auteur", "dont", "nous", "parlons", "est", "célèbre"]}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$dont_word_bank$p$, $p$writing$p$]),
('6a3e00fc-9a52-5c78-83ae-b7711ceaaeb7'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','reading','multiple_choice',$p$Completa: «C'est la ville ___ j'habite» (indica el lugar). Elige el relativo correcto.$p$,$j${"options": ["où", "que", "qui"]}$j$::jsonb,$j${"value": "où"}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$ou_lugar$p$, $p$reading$p$]),
('cc016474-37b5-5d40-9b93-966f3b7e137c'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','writing','cloze',$p$Escribe el relativo (indica el momento/día): «Je me rappelle le jour ___ nous sommes partis.»$p$,$j${"text": "Je me rappelle le jour ___ nous sommes partis."}$j$::jsonb,$j${"value": "où", "accepted": ["où"]}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$ou_tiempo$p$, $p$writing$p$]),
('dc79f9ce-aca3-5d28-ae21-f7eae463283a'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','writing','translation',$p$Traduce: «Es el lugar donde trabajo.»$p$,$j${"source": "Es el lugar donde trabajo."}$j$::jsonb,$j${"value": "C'est l'endroit où je travaille.", "accepted": ["C'est l'endroit où je travaille", "C'est l'endroit où je travaille.", "C’est l’endroit où je travaille.", "C’est l’endroit où je travaille"]}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$ou_endroit$p$, $p$writing$p$]),
('fdfeee0f-a2f0-533f-95c1-d81451a67672'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["La personne qui parle est ma voisine.", "La personne que parle est ma voisine.", "La personne dont parle est ma voisine."], "say": "La personne qui parle est ma voisine.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/fdfeee0f-a2f0-533f-95c1-d81451a67672.mp3"}$j$::jsonb,$j${"value": "La personne qui parle est ma voisine."}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$eleccion_listening_qui$p$, $p$listening$p$]),
('64ba0f05-1c8e-5a74-8a59-b86433f5fd25'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["C'est le projet dont je suis fier.", "C'est le projet que je suis fier.", "C'est le projet où je suis fier."], "say": "C'est le projet dont je suis fier.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/64ba0f05-1c8e-5a74-8a59-b86433f5fd25.mp3"}$j$::jsonb,$j${"value": "C'est le projet dont je suis fier."}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$eleccion_listening_dont$p$, $p$listening$p$]),
('c8c91188-95c8-5328-abd1-bf94523d93cb'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Voici l'entreprise où je travaille.", "Voici l'entreprise qui je travaille.", "Voici l'entreprise dont je travaille."], "say": "Voici l'entreprise où je travaille.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/c8c91188-95c8-5328-abd1-bf94523d93cb.mp3"}$j$::jsonb,$j${"value": "Voici l'entreprise où je travaille."}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$eleccion_listening_ou$p$, $p$listening$p$]),
('d0179075-f06f-5282-b3da-850895d59ca3'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Le résultat que nous attendons est bon.", "Le résultat qui nous attendons est bon.", "Le résultat dont nous attendons est bon."], "say": "Le résultat que nous attendons est bon.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/d0179075-f06f-5282-b3da-850895d59ca3.mp3"}$j$::jsonb,$j${"value": "Le résultat que nous attendons est bon."}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$eleccion_listening_que$p$, $p$listening$p$]),
('8658a1a5-8842-584c-a25e-e8040d3e558d'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "La collègue qui s'occupe de la réunion arrive bientôt.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/8658a1a5-8842-584c-a25e-e8040d3e558d.mp3"}$j$::jsonb,$j${"expected": "La collègue qui s'occupe de la réunion arrive bientôt."}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$eleccion_speaking_qui$p$, $p$speaking$p$]),
('ccbcb973-2a04-5334-80a6-13d035b2ba31'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "C'est le souvenir dont je parle le plus souvent.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/ccbcb973-2a04-5334-80a6-13d035b2ba31.mp3"}$j$::jsonb,$j${"expected": "C'est le souvenir dont je parle le plus souvent."}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$eleccion_speaking_dont$p$, $p$speaking$p$]),
('19991c1b-f66f-5d07-85f1-3256da91daf9'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Le quartier où nous habitons est très calme.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/19991c1b-f66f-5d07-85f1-3256da91daf9.mp3"}$j$::jsonb,$j${"expected": "Le quartier où nous habitons est très calme."}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$eleccion_speaking_ou$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('dada36b2-7185-5aab-b3c3-6b81853943d1','c417ba84-1c87-5aba-b682-f3a80d39f966',1),
 ('dada36b2-7185-5aab-b3c3-6b81853943d1','fd8a67ba-7be8-5b96-a306-458af3a07fb6',2),
 ('dada36b2-7185-5aab-b3c3-6b81853943d1','3c8debb7-f4fd-5b3b-87cb-ab842e6070d7',3),
 ('dada36b2-7185-5aab-b3c3-6b81853943d1','9dcca35f-5e76-5765-97ee-611610a1bc8b',4),
 ('b7193bc1-8398-5101-8875-c6b8dde811dd','2b073e65-5887-552d-bf55-8bc7300e778c',1),
 ('b7193bc1-8398-5101-8875-c6b8dde811dd','0f1bfac7-5b8a-5287-9126-cb54c9b8123e',2),
 ('b7193bc1-8398-5101-8875-c6b8dde811dd','9fc10cb4-778a-5e3b-9994-01a95546b8d9',3),
 ('b7193bc1-8398-5101-8875-c6b8dde811dd','7b462bcb-aee3-5057-93ef-c3aab1509967',4),
 ('b7193bc1-8398-5101-8875-c6b8dde811dd','d1262b6b-db12-59dd-bc6a-730f78f6a7a7',5),
 ('561d7cc1-738e-5fe8-87f4-69f4a03660e5','6a3e00fc-9a52-5c78-83ae-b7711ceaaeb7',1),
 ('561d7cc1-738e-5fe8-87f4-69f4a03660e5','cc016474-37b5-5d40-9b93-966f3b7e137c',2),
 ('561d7cc1-738e-5fe8-87f4-69f4a03660e5','dc79f9ce-aca3-5d28-ae21-f7eae463283a',3),
 ('eececa2a-9451-5c30-a5f0-bd9a2b363d89','fdfeee0f-a2f0-533f-95c1-d81451a67672',1),
 ('eececa2a-9451-5c30-a5f0-bd9a2b363d89','64ba0f05-1c8e-5a74-8a59-b86433f5fd25',2),
 ('eececa2a-9451-5c30-a5f0-bd9a2b363d89','c8c91188-95c8-5328-abd1-bf94523d93cb',3),
 ('eececa2a-9451-5c30-a5f0-bd9a2b363d89','d0179075-f06f-5282-b3da-850895d59ca3',4),
 ('eececa2a-9451-5c30-a5f0-bd9a2b363d89','8658a1a5-8842-584c-a25e-e8040d3e558d',5),
 ('eececa2a-9451-5c30-a5f0-bd9a2b363d89','ccbcb973-2a04-5334-80a6-13d035b2ba31',6),
 ('eececa2a-9451-5c30-a5f0-bd9a2b363d89','19991c1b-f66f-5d07-85f1-3256da91daf9',7),
 ('1b010889-b836-5025-b816-f4db14fe16f8','c417ba84-1c87-5aba-b682-f3a80d39f966',1),
 ('1b010889-b836-5025-b816-f4db14fe16f8','fd8a67ba-7be8-5b96-a306-458af3a07fb6',2),
 ('1b010889-b836-5025-b816-f4db14fe16f8','3c8debb7-f4fd-5b3b-87cb-ab842e6070d7',3),
 ('1b010889-b836-5025-b816-f4db14fe16f8','9dcca35f-5e76-5765-97ee-611610a1bc8b',4),
 ('1b010889-b836-5025-b816-f4db14fe16f8','9fc10cb4-778a-5e3b-9994-01a95546b8d9',5),
 ('1b010889-b836-5025-b816-f4db14fe16f8','7b462bcb-aee3-5057-93ef-c3aab1509967',6),
 ('1b010889-b836-5025-b816-f4db14fe16f8','fdfeee0f-a2f0-533f-95c1-d81451a67672',7),
 ('1b010889-b836-5025-b816-f4db14fe16f8','64ba0f05-1c8e-5a74-8a59-b86433f5fd25',8),
 ('1b010889-b836-5025-b816-f4db14fe16f8','8658a1a5-8842-584c-a25e-e8040d3e558d',9),
 ('1b010889-b836-5025-b816-f4db14fe16f8','ccbcb973-2a04-5334-80a6-13d035b2ba31',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('bdf4e196-9983-5c78-b6b6-dccdb2bc4d22','20000000-0000-0000-0000-000000000003',$p$le voisin$p$,$p$el vecino$p$,401,'n'),
 ('7672658d-5054-50cb-9087-59fcc4e1de59','20000000-0000-0000-0000-000000000003',$p$la collègue$p$,$p$la colega$p$,402,'n'),
 ('e9cc5282-c5d5-52d8-b22b-663459d83906','20000000-0000-0000-0000-000000000003',$p$le quartier$p$,$p$el barrio$p$,403,'n'),
 ('bd4541c2-6da0-5bd4-9305-856070d7cbef','20000000-0000-0000-0000-000000000003',$p$l'histoire$p$,$p$la historia$p$,404,'n'),
 ('5ab70fa0-5291-58d9-8aa0-37dffab6f191','20000000-0000-0000-0000-000000000003',$p$le roman$p$,$p$la novela$p$,405,'n'),
 ('8305f82d-39d9-52f7-b09a-d6025339b64d','20000000-0000-0000-0000-000000000003',$p$l'auteur$p$,$p$el autor$p$,406,'n'),
 ('6b5eb22d-761a-523e-b7e2-339df9e9cab5','20000000-0000-0000-0000-000000000003',$p$le moment$p$,$p$el momento$p$,407,'n'),
 ('544efe39-190f-5839-b7d8-ec3a304bbfdb','20000000-0000-0000-0000-000000000003',$p$l'endroit$p$,$p$el lugar$p$,408,'n'),
 ('317f3ef6-6c4f-5393-ace9-4029c8a055ec','20000000-0000-0000-0000-000000000003',$p$le souvenir$p$,$p$el recuerdo$p$,409,'n'),
 ('bb585d9c-2280-565c-94e3-38267ed6cd2d','20000000-0000-0000-0000-000000000003',$p$la réunion$p$,$p$la reunión$p$,410,'n'),
 ('6a76d9e6-3510-5a57-9876-676657661f0f','20000000-0000-0000-0000-000000000003',$p$le résultat$p$,$p$el resultado$p$,411,'n'),
 ('9ee00bc0-a984-51f3-82db-e4042f923180','20000000-0000-0000-0000-000000000003',$p$l'entreprise$p$,$p$la empresa$p$,412,'n'),
 ('0a6c0ba5-2d60-5f2b-bd8a-adc38d9be89d','20000000-0000-0000-0000-000000000003',$p$se souvenir de$p$,$p$acordarse de$p$,413,'v'),
 ('3fb1469f-9561-5ab0-b373-2338ce91188e','20000000-0000-0000-0000-000000000003',$p$avoir besoin de$p$,$p$necesitar$p$,414,'v'),
 ('7137c82c-bf88-5057-9ad1-f6a2111ce2a4','20000000-0000-0000-0000-000000000003',$p$parler de$p$,$p$hablar de$p$,415,'v'),
 ('ad8ce2a6-4849-58ef-9fea-72ad1401d7ac','20000000-0000-0000-0000-000000000003',$p$s'occuper de$p$,$p$encargarse de$p$,416,'v')
on conflict (id) do nothing;

-- ── Unidad 16 (B1·fr): Concordancia del participio ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('8e0c4b37-c36c-5275-bc8c-82d286770118','20000000-0000-0000-0000-000000000003','B1',16,$p$Concordancia del participio$p$,'#B9770E','spellcheck')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('37e6759d-812f-561a-a79d-15e820eb6116','8e0c4b37-c36c-5275-bc8c-82d286770118',1,$p$Con être: concuerda con el sujeto$p$,$p$Con être: concuerda con el sujeto$p$,'lesson',15),
 ('2d71acb4-a8ef-5aa8-8983-59258406a198','8e0c4b37-c36c-5275-bc8c-82d286770118',2,$p$Con avoir: solo si el COD va delante$p$,$p$Con avoir: solo si el COD va delante$p$,'lesson',15),
 ('8e84c3a6-292d-5e01-9b56-ad98c856c62c','8e0c4b37-c36c-5275-bc8c-82d286770118',3,$p$Verbos pronominales$p$,$p$Verbos pronominales$p$,'lesson',15),
 ('f433c38b-bac5-5bd1-9ade-e8db1df36521','8e0c4b37-c36c-5275-bc8c-82d286770118',4,$p$Repaso: elegir la forma correcta$p$,$p$Repaso: elegir la forma correcta$p$,'lesson',15),
 ('4e37868a-79fe-5cbe-bc38-c0f934b6e8bf','8e0c4b37-c36c-5275-bc8c-82d286770118',5,$p$🏁 Checkpoint Unité 16$p$,$p$Demuestra que dominas la concordancia del participio pasado: con être concuerda con el sujeto, con avoir solo con el COD antepuesto, y en los verbos pronominales.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('f8a3030b-8f3d-5648-8d69-921717bd7dfb','20000000-0000-0000-0000-000000000003','checkpoint','B1','8e0c4b37-c36c-5275-bc8c-82d286770118',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('c5a826f0-3897-56aa-bcc4-78b987737104'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','reading','match',$p$Une cada frase con su traducción.$p$,$j${"pairs": [{"en": "Elle est partie tôt.", "es": "Ella se fue temprano."}, {"en": "Ils sont arrivés hier.", "es": "Ellos llegaron ayer."}, {"en": "Nous sommes montés en haut.", "es": "Subimos arriba."}]}$j$::jsonb,$j${"pairs": [["Elle est partie tôt.", "Ella se fue temprano."], ["Ils sont arrivés hier.", "Ellos llegaron ayer."], ["Nous sommes montés en haut.", "Subimos arriba."]]}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$etre_accord_sujet$p$, $p$reading$p$]),
('7c721ec5-4f11-5b05-9a47-ea86adff4424'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','reading','multiple_choice',$p$Con être, el participio concuerda con el sujeto. Elige la forma correcta: «Marie ___ à Paris.»$p$,$j${"options": ["est allée", "est allé", "est allés"]}$j$::jsonb,$j${"value": "est allée"}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$etre_accord_feminin$p$, $p$reading$p$]),
('5c0259ce-6b60-5fa8-b588-67c872e506ae'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','writing','cloze',$p$Completa con el participio concordado (sujeto femenino plural): «Les filles sont ___ (rester) à la maison.»$p$,$j${"text": "Les filles sont ___ à la maison."}$j$::jsonb,$j${"value": "restées", "accepted": ["restées"]}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$etre_accord_pluriel$p$, $p$writing$p$]),
('85a5da62-cb22-5057-be22-085bae47a2db'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','writing','translation',$p$Traduce: «Ellas llegaron tarde.»$p$,$j${"source": "Ellas llegaron tarde."}$j$::jsonb,$j${"value": "Elles sont arrivées tard.", "accepted": ["Elles sont arrivées tard", "Elles sont arrivées tard.", "Elles sont arrivees tard.", "Elles sont arrivees tard"]}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$etre_accord_translation$p$, $p$writing$p$]),
('71d84b1d-2db8-5761-bb17-bcd888715ee4'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','reading','multiple_choice',$p$Con avoir y el COD DETRÁS, el participio no cambia. Elige: «J'ai ___ des fleurs.»$p$,$j${"options": ["acheté", "achetées", "achetés"]}$j$::jsonb,$j${"value": "acheté"}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$avoir_pas_daccord$p$, $p$reading$p$]),
('fa2984cb-2963-5439-a645-5244b994e561'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','reading','match',$p$Une cada frase con su traducción.$p$,$j${"pairs": [{"en": "Je les ai vues.", "es": "Las vi (a ellas)."}, {"en": "Il l'a prise.", "es": "Él la cogió."}, {"en": "Nous les avons finies.", "es": "Las terminamos."}]}$j$::jsonb,$j${"pairs": [["Je les ai vues.", "Las vi (a ellas)."], ["Il l'a prise.", "Él la cogió."], ["Nous les avons finies.", "Las terminamos."]]}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$avoir_pronom_les$p$, $p$reading$p$]),
('72e56b40-1520-5786-8696-44a1be013740'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','writing','translation',$p$Traduce: «La carta que escribí.» (fem. antepuesto → concordancia)$p$,$j${"source": "La carta que escribí."}$j$::jsonb,$j${"value": "La lettre que j'ai écrite.", "accepted": ["La lettre que j'ai écrite", "La lettre que j'ai écrite.", "La lettre que j’ai écrite.", "La lettre que j'ai ecrite.", "La lettre que j'ai ecrite"]}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$avoir_cod_antepose_translation$p$, $p$writing$p$]),
('e549ead1-7f1e-5c73-9c7c-7823d3a493e1'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','writing','word_bank',$p$Ordena para formar: «Las cogí.» (COD femenino plural antepuesto).$p$,$j${"tiles": ["Je", "les", "ai", "prises", "pris", "prise"]}$j$::jsonb,$j${"value": "Je les ai prises", "sequence": ["Je", "les", "ai", "prises"]}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$avoir_choix_ordre$p$, $p$writing$p$]),
('0475828c-4ff7-5ab4-b7c4-7667398ba086'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','writing','reorder',$p$Ordena para formar: «Nos levantamos temprano.» (sujeto nous, masc.)$p$,$j${"tiles": ["Nous", "nous", "sommes", "levés", "tôt"]}$j$::jsonb,$j${"value": "Nous nous sommes levés tôt"}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$pronominal_reorder$p$, $p$writing$p$]),
('36f06017-a75a-5264-8cff-5ac5af280ba9'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','writing','translation',$p$Traduce: «Ella se lavó.»$p$,$j${"source": "Ella se lavó."}$j$::jsonb,$j${"value": "Elle s'est lavée.", "accepted": ["Elle s'est lavée", "Elle s'est lavée.", "Elle s’est lavée.", "Elle s’est lavée", "Elle s'est lavee.", "Elle s'est lavee"]}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$pronominal_translation$p$, $p$writing$p$]),
('032c145b-1526-5ebc-b680-cf3243b480d4'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','reading','match',$p$Une cada frase con su traducción.$p$,$j${"pairs": [{"en": "Il a acheté un livre.", "es": "Compró un libro."}, {"en": "Les livres qu'il a lus.", "es": "Los libros que leyó."}, {"en": "Elle est descendue.", "es": "Ella bajó."}]}$j$::jsonb,$j${"pairs": [["Il a acheté un livre.", "Compró un libro."], ["Les livres qu'il a lus.", "Los libros que leyó."], ["Elle est descendue.", "Ella bajó."]]}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$revision_reading$p$, $p$reading$p$]),
('bf11705b-7bd7-58e9-9f6b-e75f5f9b1836'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','reading','multiple_choice',$p$COD «la valise» antepuesto → concordancia. Elige: «La valise que j'ai ___.»$p$,$j${"options": ["prise", "pris", "prises"]}$j$::jsonb,$j${"value": "prise"}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$revision_choix$p$, $p$reading$p$]),
('ec67bb1f-025d-5b4c-b201-14be3b124a30'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Je l'ai prise.", "Je l'ai mise.", "Je l'ai finie."], "say": "Je l'ai prise.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/ec67bb1f-025d-5b4c-b201-14be3b124a30.mp3"}$j$::jsonb,$j${"value": "Je l'ai prise."}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$listening_prise$p$, $p$listening$p$]),
('e6eae1d6-8a40-5775-bcc2-5e7d3e9d6325'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["La lettre que j'ai écrite.", "La lettre que j'ai lue.", "La lettre que j'ai reçue."], "say": "La lettre que j'ai écrite.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/e6eae1d6-8a40-5775-bcc2-5e7d3e9d6325.mp3"}$j$::jsonb,$j${"value": "La lettre que j'ai écrite."}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$listening_ecrite$p$, $p$listening$p$]),
('0a87bcba-4389-51f3-8737-2fd3a2b25d7e'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Elle est partie hier.", "Elle est arrivée hier.", "Elle est rentrée hier."], "say": "Elle est partie hier.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/0a87bcba-4389-51f3-8737-2fd3a2b25d7e.mp3"}$j$::jsonb,$j${"value": "Elle est partie hier."}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$listening_partie$p$, $p$listening$p$]),
('7b898c63-9ad5-56cb-a73c-ab7d41a0906f'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Elle est descendue vite.", "Elle est montée vite.", "Elle est tombée vite."], "say": "Elle est descendue vite.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/7b898c63-9ad5-56cb-a73c-ab7d41a0906f.mp3"}$j$::jsonb,$j${"value": "Elle est descendue vite."}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$listening_descendue$p$, $p$listening$p$]),
('d31e876b-99ff-54f3-a60b-19dcc7fd62ea'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Mes sœurs sont arrivées ce matin.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/d31e876b-99ff-54f3-a60b-19dcc7fd62ea.mp3"}$j$::jsonb,$j${"expected": "Mes sœurs sont arrivées ce matin."}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$speaking_etre$p$, $p$speaking$p$]),
('21870441-226e-504d-8ea5-7a59ee35adab'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Les photos que j'ai prises sont belles.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/21870441-226e-504d-8ea5-7a59ee35adab.mp3"}$j$::jsonb,$j${"expected": "Les photos que j'ai prises sont belles."}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$speaking_avoir$p$, $p$speaking$p$]),
('8e79c467-ddf8-5db7-8d33-19a83be459a2'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Elles se sont levées très tôt.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/8e79c467-ddf8-5db7-8d33-19a83be459a2.mp3"}$j$::jsonb,$j${"expected": "Elles se sont levées très tôt."}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$speaking_pronominal$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('37e6759d-812f-561a-a79d-15e820eb6116','c5a826f0-3897-56aa-bcc4-78b987737104',1),
 ('37e6759d-812f-561a-a79d-15e820eb6116','7c721ec5-4f11-5b05-9a47-ea86adff4424',2),
 ('37e6759d-812f-561a-a79d-15e820eb6116','5c0259ce-6b60-5fa8-b588-67c872e506ae',3),
 ('37e6759d-812f-561a-a79d-15e820eb6116','85a5da62-cb22-5057-be22-085bae47a2db',4),
 ('37e6759d-812f-561a-a79d-15e820eb6116','ec67bb1f-025d-5b4c-b201-14be3b124a30',5),
 ('37e6759d-812f-561a-a79d-15e820eb6116','d31e876b-99ff-54f3-a60b-19dcc7fd62ea',6),
 ('2d71acb4-a8ef-5aa8-8983-59258406a198','71d84b1d-2db8-5761-bb17-bcd888715ee4',1),
 ('2d71acb4-a8ef-5aa8-8983-59258406a198','fa2984cb-2963-5439-a645-5244b994e561',2),
 ('2d71acb4-a8ef-5aa8-8983-59258406a198','72e56b40-1520-5786-8696-44a1be013740',3),
 ('2d71acb4-a8ef-5aa8-8983-59258406a198','e549ead1-7f1e-5c73-9c7c-7823d3a493e1',4),
 ('2d71acb4-a8ef-5aa8-8983-59258406a198','e6eae1d6-8a40-5775-bcc2-5e7d3e9d6325',5),
 ('2d71acb4-a8ef-5aa8-8983-59258406a198','21870441-226e-504d-8ea5-7a59ee35adab',6),
 ('8e84c3a6-292d-5e01-9b56-ad98c856c62c','0475828c-4ff7-5ab4-b7c4-7667398ba086',1),
 ('8e84c3a6-292d-5e01-9b56-ad98c856c62c','36f06017-a75a-5264-8cff-5ac5af280ba9',2),
 ('8e84c3a6-292d-5e01-9b56-ad98c856c62c','0a87bcba-4389-51f3-8737-2fd3a2b25d7e',3),
 ('8e84c3a6-292d-5e01-9b56-ad98c856c62c','8e79c467-ddf8-5db7-8d33-19a83be459a2',4),
 ('f433c38b-bac5-5bd1-9ade-e8db1df36521','032c145b-1526-5ebc-b680-cf3243b480d4',1),
 ('f433c38b-bac5-5bd1-9ade-e8db1df36521','bf11705b-7bd7-58e9-9f6b-e75f5f9b1836',2),
 ('f433c38b-bac5-5bd1-9ade-e8db1df36521','7b898c63-9ad5-56cb-a73c-ab7d41a0906f',3),
 ('4e37868a-79fe-5cbe-bc38-c0f934b6e8bf','c5a826f0-3897-56aa-bcc4-78b987737104',1),
 ('4e37868a-79fe-5cbe-bc38-c0f934b6e8bf','7c721ec5-4f11-5b05-9a47-ea86adff4424',2),
 ('4e37868a-79fe-5cbe-bc38-c0f934b6e8bf','71d84b1d-2db8-5761-bb17-bcd888715ee4',3),
 ('4e37868a-79fe-5cbe-bc38-c0f934b6e8bf','5c0259ce-6b60-5fa8-b588-67c872e506ae',4),
 ('4e37868a-79fe-5cbe-bc38-c0f934b6e8bf','85a5da62-cb22-5057-be22-085bae47a2db',5),
 ('4e37868a-79fe-5cbe-bc38-c0f934b6e8bf','72e56b40-1520-5786-8696-44a1be013740',6),
 ('4e37868a-79fe-5cbe-bc38-c0f934b6e8bf','ec67bb1f-025d-5b4c-b201-14be3b124a30',7),
 ('4e37868a-79fe-5cbe-bc38-c0f934b6e8bf','e6eae1d6-8a40-5775-bcc2-5e7d3e9d6325',8),
 ('4e37868a-79fe-5cbe-bc38-c0f934b6e8bf','d31e876b-99ff-54f3-a60b-19dcc7fd62ea',9),
 ('4e37868a-79fe-5cbe-bc38-c0f934b6e8bf','21870441-226e-504d-8ea5-7a59ee35adab',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('37b199ff-0acd-544d-9ad8-cfb953d7cad9','20000000-0000-0000-0000-000000000003',$p$la fleur$p$,$p$la flor$p$,421,'sustantivo'),
 ('4a9af9e8-631b-50d5-bba9-1152d9dba004','20000000-0000-0000-0000-000000000003',$p$la lettre$p$,$p$la carta$p$,422,'sustantivo'),
 ('524026e8-626b-54db-b8f4-718b3f2747f6','20000000-0000-0000-0000-000000000003',$p$la valise$p$,$p$la maleta$p$,423,'sustantivo'),
 ('1451efa5-6728-5b9a-bdbd-aef8eb406c38','20000000-0000-0000-0000-000000000003',$p$la robe$p$,$p$el vestido$p$,424,'sustantivo'),
 ('876f921e-f2ca-533c-afe3-d27bb085699a','20000000-0000-0000-0000-000000000003',$p$la clé$p$,$p$la llave$p$,425,'sustantivo'),
 ('e50cc246-4044-5ea8-b8dd-5087c8b50003','20000000-0000-0000-0000-000000000003',$p$arriver$p$,$p$llegar$p$,426,'verbo'),
 ('ea654b61-1a37-560f-bc9c-a9427acce026','20000000-0000-0000-0000-000000000003',$p$partir$p$,$p$irse, partir$p$,427,'verbo'),
 ('3faf983a-5e37-5a60-a2f5-fb42245485e9','20000000-0000-0000-0000-000000000003',$p$monter$p$,$p$subir$p$,428,'verbo'),
 ('b4e916d9-0c54-543f-ba5c-376d0fd6c864','20000000-0000-0000-0000-000000000003',$p$descendre$p$,$p$bajar$p$,429,'verbo'),
 ('26ce48d8-122a-5def-9a97-4f1836d0148b','20000000-0000-0000-0000-000000000003',$p$acheter$p$,$p$comprar$p$,430,'verbo'),
 ('3c3e3690-9954-550a-b20c-5c68ce8ab8da','20000000-0000-0000-0000-000000000003',$p$prendre$p$,$p$tomar, coger$p$,431,'verbo'),
 ('fa9b3031-436b-55c9-896b-0d04b795d1ba','20000000-0000-0000-0000-000000000003',$p$mettre$p$,$p$poner$p$,432,'verbo'),
 ('efa8d4ea-c66d-55e9-9680-240d05740a0f','20000000-0000-0000-0000-000000000003',$p$se laver$p$,$p$lavarse$p$,433,'verbo'),
 ('e478e2fc-3d69-5a11-8112-b3ebd552174d','20000000-0000-0000-0000-000000000003',$p$se lever$p$,$p$levantarse$p$,434,'verbo'),
 ('74eccf15-22f7-50d2-a40b-c0a181b6119e','20000000-0000-0000-0000-000000000003',$p$hier$p$,$p$ayer$p$,435,'adverbio'),
 ('71a6077c-1e74-55fd-8e81-0ba9babba6cb','20000000-0000-0000-0000-000000000003',$p$déjà$p$,$p$ya$p$,436,'adverbio')
on conflict (id) do nothing;

-- ── Unidad 17 (B1·fr): Estilo indirecto (contar lo que dicen) ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('4398e34a-ddd3-55e2-b8e2-97f3d7625c80','20000000-0000-0000-0000-000000000003','B1',17,$p$Estilo indirecto (contar lo que dicen)$p$,'#922B21','forum')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('90232a4d-bf24-52b9-b725-ae15cc1adf3f','4398e34a-ddd3-55e2-b8e2-97f3d7625c80',1,$p$Decir que… (dire que / affirmations)$p$,$p$Decir que… (dire que / affirmations)$p$,'lesson',15),
 ('49a47ab3-1578-55db-9041-dcb7e3a163ea','4398e34a-ddd3-55e2-b8e2-97f3d7625c80',2,$p$Preguntar si… y qué… (demander si / ce que)$p$,$p$Preguntar si… y qué… (demander si / ce que)$p$,'lesson',15),
 ('4a985ac7-082c-5207-85d7-c0160ea483dc','4398e34a-ddd3-55e2-b8e2-97f3d7625c80',3,$p$Pedir que… (dire/demander de + infinitivo)$p$,$p$Pedir que… (dire/demander de + infinitivo)$p$,'lesson',15),
 ('618b9f65-d78f-5ad9-8550-6822ac6ac0e3','4398e34a-ddd3-55e2-b8e2-97f3d7625c80',4,$p$Contar en pasado (concordancia de tiempos)$p$,$p$Contar en pasado (concordancia de tiempos)$p$,'lesson',15),
 ('b7d65a3f-7f6d-591b-aa7d-69a27e1b6f85','4398e34a-ddd3-55e2-b8e2-97f3d7625c80',5,$p$🏁 Checkpoint Unité 17$p$,$p$Cuenta lo que otros dicen, preguntan o piden usando el estilo indirecto: los conectores que/si/ce que/de y la concordancia de tiempos cuando el verbo introductor va en pasado.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('6626214f-dbf0-5e53-bc92-dbab48fa79e5','20000000-0000-0000-0000-000000000003','checkpoint','B1','4398e34a-ddd3-55e2-b8e2-97f3d7625c80',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('20afb817-413c-5b90-9148-f174b6c43cc7'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','reading','match',$p$Une las frases en estilo indirecto con su significado.$p$,$j${"pairs": [{"en": "Il dit qu'il est fatigué.", "es": "Dice que está cansado."}, {"en": "Elle dit qu'elle arrive bientôt.", "es": "Dice que llega pronto."}, {"en": "Ils disent qu'ils sont prêts.", "es": "Dicen que están listos."}]}$j$::jsonb,$j${"pairs": [["Il dit qu'il est fatigué.", "Dice que está cansado."], ["Elle dit qu'elle arrive bientôt.", "Dice que llega pronto."], ["Ils disent qu'ils sont prêts.", "Dicen que están listos."]]}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$dire_que_affirmation$p$, $p$reading$p$]),
('5002f634-155f-55c4-8d97-9bf038f374fa'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','reading','multiple_choice',$p$Para contar una afirmación tras «Il dit…», ¿qué frase es correcta?$p$,$j${"options": ["Il dit qu'il travaille demain.", "Il dit s'il travaille demain.", "Il dit ce qu'il travaille demain."]}$j$::jsonb,$j${"value": "Il dit qu'il travaille demain."}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$dire_que_connecteur$p$, $p$reading$p$]),
('f0a8af19-67ae-596f-8af7-b80af841b382'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','writing','cloze',$p$Completa (afirmación): «Ella dice ___ tiene hambre».$p$,$j${"text": "Elle dit ___ elle a faim."}$j$::jsonb,$j${"value": "qu'", "accepted": ["qu'", "qu’"]}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$dire_que_cloze$p$, $p$writing$p$]),
('799186e9-6852-5f42-b8c7-e346cc2f244e'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','writing','translation',$p$Traduce: «Él dice que vive en París».$p$,$j${"source": "Él dice que vive en París."}$j$::jsonb,$j${"value": "Il dit qu'il habite à Paris.", "accepted": ["Il dit qu'il habite à Paris", "Il dit qu'il habite à Paris.", "Il dit qu’il habite à Paris.", "Il dit qu'il vit à Paris.", "Il dit qu'il vit à Paris"]}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$dire_que_translation$p$, $p$writing$p$]),
('e2355ea0-f62f-5632-a32d-4938d60ee235'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Elle dit qu'elle est contente.", "Elle dit si elle est contente.", "Elle demande si elle est contente."], "say": "Elle dit qu'elle est contente.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/e2355ea0-f62f-5632-a32d-4938d60ee235.mp3"}$j$::jsonb,$j${"value": "Elle dit qu'elle est contente."}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$dire_que_listening$p$, $p$listening$p$]),
('6a3bb0fc-de43-54cc-8b30-6bc88bf40d8e'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','reading','multiple_choice',$p$Pregunta cerrada (sí/no) en estilo indirecto: «Il me demande… je viens».$p$,$j${"options": ["Il me demande si je viens.", "Il me demande que je viens.", "Il me demande ce que je viens."]}$j$::jsonb,$j${"value": "Il me demande si je viens."}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$demander_si_reading$p$, $p$reading$p$]),
('29d55aa4-0205-5a11-bead-58e392d13401'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','reading','match',$p$Une la pregunta indirecta con su tipo.$p$,$j${"pairs": [{"en": "Il demande si tu es là.", "es": "pregunta sí/no → si"}, {"en": "Il demande ce que tu fais.", "es": "pregunta sobre qué → ce que"}, {"en": "Il demande où tu vas.", "es": "pregunta sobre lugar → où"}]}$j$::jsonb,$j${"pairs": [["Il demande si tu es là.", "pregunta sí/no → si"], ["Il demande ce que tu fais.", "pregunta sobre qué → ce que"], ["Il demande où tu vas.", "pregunta sobre lugar → où"]]}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$demander_ce_que_reading$p$, $p$reading$p$]),
('b7e1b6c7-7f11-5475-b1e2-0171015866d3'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','writing','cloze',$p$Completa (pregunta sobre «qué»): «Él pregunta ___ quieres».$p$,$j${"text": "Il demande ___ tu veux."}$j$::jsonb,$j${"value": "ce que", "accepted": ["ce que", "ce qu'", "ce qu’"]}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$demander_ce_que_cloze$p$, $p$writing$p$]),
('5dc37f53-bbad-50ba-87af-79b2401d4377'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','writing','word_bank',$p$Ordena: «Ella pregunta si tú estás cansado».$p$,$j${"tiles": ["Elle", "demande", "si", "tu", "es", "fatigué", "que", "ce que"]}$j$::jsonb,$j${"value": "Elle demande si tu es fatigué", "sequence": ["Elle", "demande", "si", "tu", "es", "fatigué"]}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$demander_si_word_bank$p$, $p$writing$p$]),
('9c5c211e-1a60-5ba3-a837-a7bb09aafa7c'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Il demande ce que tu fais.", "Il demande si tu viens.", "Il dit ce qu'il fait."], "say": "Il demande ce que tu fais.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/9c5c211e-1a60-5ba3-a837-a7bb09aafa7c.mp3"}$j$::jsonb,$j${"value": "Il demande ce que tu fais."}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$demander_ce_que_listening$p$, $p$listening$p$]),
('c68015dd-94bd-5459-b4f7-47df79323dcf'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','reading','multiple_choice',$p$Convertir una orden («¡Ven!») al estilo indirecto:$p$,$j${"options": ["Il me dit de venir.", "Il me dit que venir.", "Il me dit si venir."]}$j$::jsonb,$j${"value": "Il me dit de venir."}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$dire_de_reading$p$, $p$reading$p$]),
('9475ab70-f7ce-5683-b6ce-8a8c5a4aa5db'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','writing','reorder',$p$Ordena: «Él nos pide cerrar la puerta».$p$,$j${"tiles": ["Il", "nous", "demande", "de", "fermer", "la", "porte", "que"]}$j$::jsonb,$j${"value": "Il nous demande de fermer la porte"}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$dire_de_reorder$p$, $p$writing$p$]),
('b3f69f6a-9fe5-50ae-b7c2-c55829de649e'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Elle me demande d'attendre.", "Elle me demande d'entrer.", "Elle me dit de partir."], "say": "Elle me demande d'attendre.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/b3f69f6a-9fe5-50ae-b7c2-c55829de649e.mp3"}$j$::jsonb,$j${"value": "Elle me demande d'attendre."}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$dire_de_listening$p$, $p$listening$p$]),
('3d2fd4d0-bf42-5ebe-a966-1f1686b632ee'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Elle me dit de faire attention.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/3d2fd4d0-bf42-5ebe-a966-1f1686b632ee.mp3"}$j$::jsonb,$j${"expected": "Elle me dit de faire attention."}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$dire_de_speaking$p$, $p$speaking$p$]),
('b8d23825-0851-5624-857f-98a35fdd4028'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','reading','multiple_choice',$p$«Il a dit…» (pasado). El presente «je suis fatigué» pasa a:$p$,$j${"options": ["Il a dit qu'il était fatigué.", "Il a dit qu'il est fatigué.", "Il a dit qu'il sera fatigué."]}$j$::jsonb,$j${"value": "Il a dit qu'il était fatigué."}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$concordance_present_imparfait$p$, $p$reading$p$]),
('f20d6654-188f-572e-9462-01bd7defb613'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','writing','cloze',$p$«Elle a dit…» (pasado). El futuro «je viendrai» pasa al condicional: «Elle a dit qu'elle ___ le lendemain».$p$,$j${"text": "Elle a dit qu'elle ___ le lendemain."}$j$::jsonb,$j${"value": "viendrait", "accepted": ["viendrait"]}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$concordance_futur_conditionnel$p$, $p$writing$p$]),
('5539f141-d299-548c-be2e-c1ddac4821c0'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Il a expliqué qu'il avait oublié la veille.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/5539f141-d299-548c-be2e-c1ddac4821c0.mp3"}$j$::jsonb,$j${"expected": "Il a expliqué qu'il avait oublié la veille."}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$concordance_speaking$p$, $p$speaking$p$]),
('d2c53a7a-0b23-5060-b61b-2285b95b6970'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Elle a dit qu'elle était prête.", "Elle a dit qu'elle est prête.", "Elle dit qu'elle était prête."], "say": "Elle a dit qu'elle était prête.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/d2c53a7a-0b23-5060-b61b-2285b95b6970.mp3"}$j$::jsonb,$j${"value": "Elle a dit qu'elle était prête."}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$concordance_listening$p$, $p$listening$p$]),
('836c73b1-c881-5eef-85bc-149f1fac60fe'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Elle a demandé si nous avions compris.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/836c73b1-c881-5eef-85bc-149f1fac60fe.mp3"}$j$::jsonb,$j${"expected": "Elle a demandé si nous avions compris."}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$concordance_speaking_bis$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('90232a4d-bf24-52b9-b725-ae15cc1adf3f','20afb817-413c-5b90-9148-f174b6c43cc7',1),
 ('90232a4d-bf24-52b9-b725-ae15cc1adf3f','5002f634-155f-55c4-8d97-9bf038f374fa',2),
 ('90232a4d-bf24-52b9-b725-ae15cc1adf3f','f0a8af19-67ae-596f-8af7-b80af841b382',3),
 ('90232a4d-bf24-52b9-b725-ae15cc1adf3f','799186e9-6852-5f42-b8c7-e346cc2f244e',4),
 ('90232a4d-bf24-52b9-b725-ae15cc1adf3f','e2355ea0-f62f-5632-a32d-4938d60ee235',5),
 ('49a47ab3-1578-55db-9041-dcb7e3a163ea','6a3bb0fc-de43-54cc-8b30-6bc88bf40d8e',1),
 ('49a47ab3-1578-55db-9041-dcb7e3a163ea','29d55aa4-0205-5a11-bead-58e392d13401',2),
 ('49a47ab3-1578-55db-9041-dcb7e3a163ea','b7e1b6c7-7f11-5475-b1e2-0171015866d3',3),
 ('49a47ab3-1578-55db-9041-dcb7e3a163ea','5dc37f53-bbad-50ba-87af-79b2401d4377',4),
 ('49a47ab3-1578-55db-9041-dcb7e3a163ea','9c5c211e-1a60-5ba3-a837-a7bb09aafa7c',5),
 ('4a985ac7-082c-5207-85d7-c0160ea483dc','c68015dd-94bd-5459-b4f7-47df79323dcf',1),
 ('4a985ac7-082c-5207-85d7-c0160ea483dc','9475ab70-f7ce-5683-b6ce-8a8c5a4aa5db',2),
 ('4a985ac7-082c-5207-85d7-c0160ea483dc','b3f69f6a-9fe5-50ae-b7c2-c55829de649e',3),
 ('4a985ac7-082c-5207-85d7-c0160ea483dc','3d2fd4d0-bf42-5ebe-a966-1f1686b632ee',4),
 ('618b9f65-d78f-5ad9-8550-6822ac6ac0e3','b8d23825-0851-5624-857f-98a35fdd4028',1),
 ('618b9f65-d78f-5ad9-8550-6822ac6ac0e3','f20d6654-188f-572e-9462-01bd7defb613',2),
 ('618b9f65-d78f-5ad9-8550-6822ac6ac0e3','5539f141-d299-548c-be2e-c1ddac4821c0',3),
 ('618b9f65-d78f-5ad9-8550-6822ac6ac0e3','d2c53a7a-0b23-5060-b61b-2285b95b6970',4),
 ('618b9f65-d78f-5ad9-8550-6822ac6ac0e3','836c73b1-c881-5eef-85bc-149f1fac60fe',5),
 ('b7d65a3f-7f6d-591b-aa7d-69a27e1b6f85','20afb817-413c-5b90-9148-f174b6c43cc7',1),
 ('b7d65a3f-7f6d-591b-aa7d-69a27e1b6f85','5002f634-155f-55c4-8d97-9bf038f374fa',2),
 ('b7d65a3f-7f6d-591b-aa7d-69a27e1b6f85','6a3bb0fc-de43-54cc-8b30-6bc88bf40d8e',3),
 ('b7d65a3f-7f6d-591b-aa7d-69a27e1b6f85','f0a8af19-67ae-596f-8af7-b80af841b382',4),
 ('b7d65a3f-7f6d-591b-aa7d-69a27e1b6f85','799186e9-6852-5f42-b8c7-e346cc2f244e',5),
 ('b7d65a3f-7f6d-591b-aa7d-69a27e1b6f85','b7e1b6c7-7f11-5475-b1e2-0171015866d3',6),
 ('b7d65a3f-7f6d-591b-aa7d-69a27e1b6f85','e2355ea0-f62f-5632-a32d-4938d60ee235',7),
 ('b7d65a3f-7f6d-591b-aa7d-69a27e1b6f85','9c5c211e-1a60-5ba3-a837-a7bb09aafa7c',8),
 ('b7d65a3f-7f6d-591b-aa7d-69a27e1b6f85','3d2fd4d0-bf42-5ebe-a966-1f1686b632ee',9),
 ('b7d65a3f-7f6d-591b-aa7d-69a27e1b6f85','5539f141-d299-548c-be2e-c1ddac4821c0',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('a9f2750e-d070-5937-879e-00c24876e8ac','20000000-0000-0000-0000-000000000003',$p$le discours indirect$p$,$p$el estilo indirecto$p$,441,'n'),
 ('7a2d3d3c-2d2d-5190-bdbf-e94d4c9b6c73','20000000-0000-0000-0000-000000000003',$p$une affirmation$p$,$p$una afirmación$p$,442,'n'),
 ('d8c633ef-c54a-5301-ac38-d03f77e0655a','20000000-0000-0000-0000-000000000003',$p$une question$p$,$p$una pregunta$p$,443,'n'),
 ('3ea1b4db-b55d-5e52-8c70-74200520b943','20000000-0000-0000-0000-000000000003',$p$une demande$p$,$p$una petición$p$,444,'n'),
 ('de6640c8-de5c-53c6-878b-cfa5f935db0a','20000000-0000-0000-0000-000000000003',$p$répéter$p$,$p$repetir$p$,445,'v'),
 ('cbaeb08a-9b3a-5e83-9ed2-18c7d6e53b89','20000000-0000-0000-0000-000000000003',$p$raconter$p$,$p$contar, relatar$p$,446,'v'),
 ('e7b98ea7-ba9a-5e73-8890-faf21e56ced8','20000000-0000-0000-0000-000000000003',$p$expliquer$p$,$p$explicar$p$,447,'v'),
 ('369de6b0-937b-56e8-b7bb-5ae1ffc5ea41','20000000-0000-0000-0000-000000000003',$p$ajouter$p$,$p$añadir$p$,448,'v'),
 ('4ce9e869-7877-5777-bd04-0e2f45043063','20000000-0000-0000-0000-000000000003',$p$avouer$p$,$p$confesar, admitir$p$,449,'v'),
 ('96b4b90a-f7a0-5e91-8ee6-1d51dc22bcc6','20000000-0000-0000-0000-000000000003',$p$préciser$p$,$p$precisar$p$,450,'v'),
 ('ea628320-d599-5db6-be2f-a33d44b8f77d','20000000-0000-0000-0000-000000000003',$p$la veille$p$,$p$la víspera, el día anterior$p$,451,'n'),
 ('fc82548d-d6e8-535e-8b4c-4a83f7e452e5','20000000-0000-0000-0000-000000000003',$p$le lendemain$p$,$p$el día siguiente$p$,452,'n'),
 ('d2fb96ba-1421-5e8d-8f4a-4a690bba2280','20000000-0000-0000-0000-000000000003',$p$à ce moment-là$p$,$p$en ese momento$p$,453,'adv'),
 ('54666cfd-e229-5789-ab21-5e1c63d5f754','20000000-0000-0000-0000-000000000003',$p$ce jour-là$p$,$p$aquel día$p$,454,'adv'),
 ('f9e4fd64-aef2-5dc7-bfa8-5c52398d7dab','20000000-0000-0000-0000-000000000003',$p$autrefois$p$,$p$antaño, antes$p$,455,'adv'),
 ('1612e4f1-000e-5f76-bc49-0f656e682fdc','20000000-0000-0000-0000-000000000003',$p$par la suite$p$,$p$más tarde, después$p$,456,'adv')
on conflict (id) do nothing;

-- ── Unidad 18 (B1·fr): Pronombres (le, lui, y, en) y repaso ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('f0749180-8fff-594a-bc3d-affb6f5c6863','20000000-0000-0000-0000-000000000003','B1',18,$p$Pronombres (le, lui, y, en) y repaso$p$,'#4A235A','swap_horiz')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('dd26ed3a-8870-5fa7-a8aa-f6edef139aed','f0749180-8fff-594a-bc3d-affb6f5c6863',1,$p$COD y COI: le, la, les, lui, leur$p$,$p$COD y COI: le, la, les, lui, leur$p$,'lesson',15),
 ('27aa181a-76b7-5c40-b299-e4fd19044b96','f0749180-8fff-594a-bc3d-affb6f5c6863',2,$p$Los pronombres y & en$p$,$p$Los pronombres y & en$p$,'lesson',15),
 ('69c8a46a-3ee5-5f6e-bed4-f4ac73d5ee8a','f0749180-8fff-594a-bc3d-affb6f5c6863',3,$p$Doble pronombre: el orden correcto$p$,$p$Doble pronombre: el orden correcto$p$,'lesson',15),
 ('59cd1ff5-b816-554c-bd7c-b17c5db87af9','f0749180-8fff-594a-bc3d-affb6f5c6863',4,$p$Repaso B1: subjuntivo y relativos$p$,$p$Repaso B1: subjuntivo y relativos$p$,'lesson',15),
 ('193b07ac-99f9-5a1b-92d3-1e77234586ff','f0749180-8fff-594a-bc3d-affb6f5c6863',5,$p$🏁 Checkpoint Unité 18$p$,$p$Demuestra que dominas los pronombres complemento (COD le/la/les, COI lui/leur, y, en) y su orden al combinarlos, consolidando el subjuntivo y los relativos de B1.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('691549e0-233f-524c-95f6-6c588ae8ffeb','20000000-0000-0000-0000-000000000003','checkpoint','B1','f0749180-8fff-594a-bc3d-affb6f5c6863',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('b52abf87-709e-5da8-8d6a-5ad0db8b608e'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','reading','match',$p$Relaciona cada frase con pronombre con su significado en español.$p$,$j${"pairs": [{"en": "Je la connais.", "es": "La conozco."}, {"en": "Je lui parle.", "es": "Le hablo (a él/ella)."}, {"en": "Je les vois.", "es": "Los veo."}]}$j$::jsonb,$j${"pairs": [["Je la connais.", "La conozco."], ["Je lui parle.", "Le hablo (a él/ella)."], ["Je les vois.", "Los veo."]]}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$cod_coi_match$p$, $p$reading$p$]),
('1a6321c7-dea5-58a3-9786-3da03fd87985'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','reading','multiple_choice',$p$«Tu prends le dossier ?» — Completa: «Oui, je ___.» (le dossier = COD)$p$,$j${"options": ["le prends", "lui prends", "y prends"]}$j$::jsonb,$j${"value": "le prends"}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$cod_direct_object$p$, $p$reading$p$]),
('b35bbc72-6e5b-5cdd-93d9-f4df4c9379f1'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','writing','cloze',$p$Sustituye «à ma sœur» por el COI: «Je ___ explique le problème.»$p$,$j${"text": "Je ___ explique le problème."}$j$::jsonb,$j${"value": "lui", "accepted": ["lui"]}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$coi_lui_singular$p$, $p$writing$p$]),
('b7a7efd4-ee9a-576d-b259-078516f2e54e'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','writing','translation',$p$Traduce (sustituyendo el objeto por un pronombre): «La veo cada día.» (a ella)$p$,$j${"source": "La veo cada día."}$j$::jsonb,$j${"value": "Je la vois chaque jour.", "accepted": ["Je la vois chaque jour", "Je la vois chaque jour.", "Je la vois tous les jours.", "Je la vois tous les jours"]}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$cod_la_translation$p$, $p$writing$p$]),
('982b47d7-fd31-5f84-86fc-414661b1152a'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','reading','multiple_choice',$p$«Tu vas à Paris ?» — Completa con el pronombre de lugar: «Oui, j'___ vais demain.»$p$,$j${"options": ["y vais", "en vais", "lui vais"]}$j$::jsonb,$j${"value": "y vais"}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$y_pronoun_place$p$, $p$reading$p$]),
('32002ffa-2bdd-5fcb-867a-3a437d218f38'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','reading','multiple_choice',$p$«Tu as des frères ?» — Completa: «Oui, j'___ ai deux.» (de+cantidad)$p$,$j${"options": ["en ai deux", "y ai deux", "les ai deux"]}$j$::jsonb,$j${"value": "en ai deux"}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$en_pronoun_quantity$p$, $p$reading$p$]),
('5b15f7fe-2c66-5268-862a-05011723723f'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','writing','word_bank',$p$Ordena para decir «Necesito uno.» (respondiendo a «Tu as besoin d'un stylo ?»).$p$,$j${"tiles": ["J'", "en", "ai", "besoin", "y", "le"]}$j$::jsonb,$j${"value": "J' en ai besoin", "sequence": ["J'", "en", "ai", "besoin"]}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$en_besoin_de_wordbank$p$, $p$writing$p$]),
('e794454a-af6d-5226-9c88-4578a68c9a32'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','reading','multiple_choice',$p$«Tu donnes le cadeau à Marie ?» — Elige el orden correcto del doble pronombre: «Oui, je ___ donne.»$p$,$j${"options": ["le lui donne", "lui le donne", "lui en donne"]}$j$::jsonb,$j${"value": "le lui donne"}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$double_pronoun_le_lui$p$, $p$reading$p$]),
('96011e41-538a-5ece-9291-41b7a67fb26f'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','writing','cloze',$p$«Tu rends la lettre à ton collègue ?» Completa el doble pronombre en orden: «Oui, je ___ ___ rends.»$p$,$j${"text": "Oui, je ___ ___ rends."}$j$::jsonb,$j${"value": "la lui", "accepted": ["la lui"]}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$double_pronoun_la_lui_cloze$p$, $p$writing$p$]),
('18a458f2-b782-5771-b1c0-7ddd3c4a482d'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','writing','reorder',$p$Ordena la frase: «Se los presto.» (les livres à eux → COD + COI).$p$,$j${"tiles": ["Je", "les", "leur", "prête", "lui", "en"]}$j$::jsonb,$j${"value": "Je les leur prête"}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$double_pronoun_reorder$p$, $p$writing$p$]),
('94a9e2b7-70fb-501f-9782-1786873e33c4'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','reading','multiple_choice',$p$Repaso subjuntivo: «Il faut que tu ___ avec moi.» (venir)$p$,$j${"options": ["viennes", "viens", "venir"]}$j$::jsonb,$j${"value": "viennes"}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$subjonctif_review$p$, $p$reading$p$]),
('ef1e2d0e-603f-57ae-85d7-b38fa4c882e6'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','writing','cloze',$p$Repaso relativos: «C'est le collègue ___ je t'ai parlé.» (parler DE quelqu'un)$p$,$j${"text": "C'est le collègue ___ je t'ai parlé."}$j$::jsonb,$j${"value": "dont", "accepted": ["dont"]}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$relatif_dont_review$p$, $p$writing$p$]),
('dabdae6a-35a4-5735-ab7e-bbe56a88a001'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Je leur donne un conseil.", "Je lui donne un conseil.", "Je les vois un moment."], "say": "Je leur donne un conseil.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/dabdae6a-35a4-5735-ab7e-bbe56a88a001.mp3"}$j$::jsonb,$j${"value": "Je leur donne un conseil."}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$coi_leur_listening$p$, $p$listening$p$]),
('d924dab1-d67c-5727-90d9-6afd83630205'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["J'y vais et j'en reviens vite.", "J'en vais et j'y reviens vite.", "J'y pense et j'en parle vite."], "say": "J'y vais et j'en reviens vite.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/d924dab1-d67c-5727-90d9-6afd83630205.mp3"}$j$::jsonb,$j${"value": "J'y vais et j'en reviens vite."}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$y_en_listening$p$, $p$listening$p$]),
('0567040e-5456-561e-b723-da23a7513b91'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Je le lui explique demain.", "Je le leur explique demain.", "Je la lui explique demain."], "say": "Je le lui explique demain.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/0567040e-5456-561e-b723-da23a7513b91.mp3"}$j$::jsonb,$j${"value": "Je le lui explique demain."}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$double_pronoun_listening$p$, $p$listening$p$]),
('95cf0405-b134-551d-995a-64140b6e43bf'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Elle m'en parle souvent.", "Elle m'y pense souvent.", "Elle lui en parle souvent."], "say": "Elle m'en parle souvent.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/95cf0405-b134-551d-995a-64140b6e43bf.mp3"}$j$::jsonb,$j${"value": "Elle m'en parle souvent."}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$double_pronoun_men_listening$p$, $p$listening$p$]),
('629a8875-28bd-5b1c-be99-e665648298fe'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Je le connais bien et je lui téléphone souvent.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/629a8875-28bd-5b1c-be99-e665648298fe.mp3"}$j$::jsonb,$j${"expected": "Je le connais bien et je lui téléphone souvent."}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$cod_coi_speaking$p$, $p$speaking$p$]),
('a288c8b6-6f45-5ae0-8f56-1e062ff9b8ef'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "J'y pense beaucoup et j'en ai besoin.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/a288c8b6-6f45-5ae0-8f56-1e062ff9b8ef.mp3"}$j$::jsonb,$j${"expected": "J'y pense beaucoup et j'en ai besoin."}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$y_en_speaking$p$, $p$speaking$p$]),
('e7211020-2c7d-5b51-be9c-b512e588a983'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Je le lui donne et il m'en remercie.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/e7211020-2c7d-5b51-be9c-b512e588a983.mp3"}$j$::jsonb,$j${"expected": "Je le lui donne et il m'en remercie."}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$double_pronoun_speaking$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('dd26ed3a-8870-5fa7-a8aa-f6edef139aed','b52abf87-709e-5da8-8d6a-5ad0db8b608e',1),
 ('dd26ed3a-8870-5fa7-a8aa-f6edef139aed','1a6321c7-dea5-58a3-9786-3da03fd87985',2),
 ('dd26ed3a-8870-5fa7-a8aa-f6edef139aed','b35bbc72-6e5b-5cdd-93d9-f4df4c9379f1',3),
 ('dd26ed3a-8870-5fa7-a8aa-f6edef139aed','b7a7efd4-ee9a-576d-b259-078516f2e54e',4),
 ('dd26ed3a-8870-5fa7-a8aa-f6edef139aed','dabdae6a-35a4-5735-ab7e-bbe56a88a001',5),
 ('dd26ed3a-8870-5fa7-a8aa-f6edef139aed','629a8875-28bd-5b1c-be99-e665648298fe',6),
 ('27aa181a-76b7-5c40-b299-e4fd19044b96','982b47d7-fd31-5f84-86fc-414661b1152a',1),
 ('27aa181a-76b7-5c40-b299-e4fd19044b96','32002ffa-2bdd-5fcb-867a-3a437d218f38',2),
 ('27aa181a-76b7-5c40-b299-e4fd19044b96','5b15f7fe-2c66-5268-862a-05011723723f',3),
 ('27aa181a-76b7-5c40-b299-e4fd19044b96','d924dab1-d67c-5727-90d9-6afd83630205',4),
 ('27aa181a-76b7-5c40-b299-e4fd19044b96','a288c8b6-6f45-5ae0-8f56-1e062ff9b8ef',5),
 ('69c8a46a-3ee5-5f6e-bed4-f4ac73d5ee8a','e794454a-af6d-5226-9c88-4578a68c9a32',1),
 ('69c8a46a-3ee5-5f6e-bed4-f4ac73d5ee8a','96011e41-538a-5ece-9291-41b7a67fb26f',2),
 ('69c8a46a-3ee5-5f6e-bed4-f4ac73d5ee8a','18a458f2-b782-5771-b1c0-7ddd3c4a482d',3),
 ('69c8a46a-3ee5-5f6e-bed4-f4ac73d5ee8a','0567040e-5456-561e-b723-da23a7513b91',4),
 ('69c8a46a-3ee5-5f6e-bed4-f4ac73d5ee8a','95cf0405-b134-551d-995a-64140b6e43bf',5),
 ('69c8a46a-3ee5-5f6e-bed4-f4ac73d5ee8a','e7211020-2c7d-5b51-be9c-b512e588a983',6),
 ('59cd1ff5-b816-554c-bd7c-b17c5db87af9','94a9e2b7-70fb-501f-9782-1786873e33c4',1),
 ('59cd1ff5-b816-554c-bd7c-b17c5db87af9','ef1e2d0e-603f-57ae-85d7-b38fa4c882e6',2),
 ('193b07ac-99f9-5a1b-92d3-1e77234586ff','b52abf87-709e-5da8-8d6a-5ad0db8b608e',1),
 ('193b07ac-99f9-5a1b-92d3-1e77234586ff','1a6321c7-dea5-58a3-9786-3da03fd87985',2),
 ('193b07ac-99f9-5a1b-92d3-1e77234586ff','982b47d7-fd31-5f84-86fc-414661b1152a',3),
 ('193b07ac-99f9-5a1b-92d3-1e77234586ff','b35bbc72-6e5b-5cdd-93d9-f4df4c9379f1',4),
 ('193b07ac-99f9-5a1b-92d3-1e77234586ff','b7a7efd4-ee9a-576d-b259-078516f2e54e',5),
 ('193b07ac-99f9-5a1b-92d3-1e77234586ff','5b15f7fe-2c66-5268-862a-05011723723f',6),
 ('193b07ac-99f9-5a1b-92d3-1e77234586ff','dabdae6a-35a4-5735-ab7e-bbe56a88a001',7),
 ('193b07ac-99f9-5a1b-92d3-1e77234586ff','d924dab1-d67c-5727-90d9-6afd83630205',8),
 ('193b07ac-99f9-5a1b-92d3-1e77234586ff','629a8875-28bd-5b1c-be99-e665648298fe',9),
 ('193b07ac-99f9-5a1b-92d3-1e77234586ff','a288c8b6-6f45-5ae0-8f56-1e062ff9b8ef',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('a42e11db-6f0f-53f9-a47f-cf64c3c17a25','20000000-0000-0000-0000-000000000003',$p$le cadeau$p$,$p$el regalo$p$,461,'n'),
 ('4a3e95f8-7f7d-5316-a692-d7c743963911','20000000-0000-0000-0000-000000000003',$p$la lettre$p$,$p$la carta$p$,462,'n'),
 ('0dd51fc4-b1ce-560c-a5f7-328cc86b4f61','20000000-0000-0000-0000-000000000003',$p$les clés$p$,$p$las llaves$p$,463,'n'),
 ('7da6e1a1-bb95-58ef-891b-9ae7c1c9d923','20000000-0000-0000-0000-000000000003',$p$le collègue$p$,$p$el colega$p$,464,'n'),
 ('590b784c-2822-516f-951a-d4ac34c60e58','20000000-0000-0000-0000-000000000003',$p$la réunion$p$,$p$la reunión$p$,465,'n'),
 ('f9f908fc-1641-5586-b368-d4e64c256a02','20000000-0000-0000-0000-000000000003',$p$le dossier$p$,$p$el expediente$p$,466,'n'),
 ('e64b19b7-83bd-5db3-aa40-2749a7844703','20000000-0000-0000-0000-000000000003',$p$prêter$p$,$p$prestar$p$,467,'v'),
 ('44147a00-61dd-5ba1-8aa4-670cec3e4e8f','20000000-0000-0000-0000-000000000003',$p$expliquer$p$,$p$explicar$p$,468,'v'),
 ('e8339668-e5b1-5be9-8eff-7fbe7fc8d249','20000000-0000-0000-0000-000000000003',$p$rendre$p$,$p$devolver$p$,469,'v'),
 ('644ef626-8834-59e9-994c-7655231c1aeb','20000000-0000-0000-0000-000000000003',$p$s'occuper de$p$,$p$ocuparse de$p$,470,'v'),
 ('883a2398-8ea9-53c9-b8a3-3a1355c347a2','20000000-0000-0000-0000-000000000003',$p$penser à$p$,$p$pensar en$p$,471,'v'),
 ('6de08fbc-fc6b-5629-99e7-ca126f92a040','20000000-0000-0000-0000-000000000003',$p$avoir besoin de$p$,$p$necesitar$p$,472,'v'),
 ('b56bc939-bda7-5b8c-a509-0d6ab1ee8909','20000000-0000-0000-0000-000000000003',$p$le conseil$p$,$p$el consejo$p$,473,'n'),
 ('f71adcf1-362f-593e-9f5e-72521097b36c','20000000-0000-0000-0000-000000000003',$p$la question$p$,$p$la pregunta$p$,474,'n'),
 ('3b6545a3-5140-5d08-8960-305a48144260','20000000-0000-0000-0000-000000000003',$p$le rendez-vous$p$,$p$la cita$p$,475,'n'),
 ('bb7f0ae2-92b2-5857-a52c-efe56a98bad9','20000000-0000-0000-0000-000000000003',$p$la boulangerie$p$,$p$la panadería$p$,476,'n')
on conflict (id) do nothing;

commit;