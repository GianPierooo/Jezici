-- 20260703120097_seed_fr_a2.sql
-- Currículo A2 del curso es→fr (6 unidades). Molde es→pt.
-- Contenido scopeado a course_id=20000000-0000-0000-0000-000000000003 → aislamiento multicurso por
-- jz_active_course. Unidades order_index continúan la cadena → gating al nivel previo.
begin;
insert into languages (id, code, name) values
  ('10000000-0000-0000-0000-000000000004','fr',$p$Français$p$) on conflict (id) do nothing;
insert into courses (id, source_language_id, target_language_id, is_active) values
  ('20000000-0000-0000-0000-000000000003','10000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000004',true) on conflict (id) do nothing;

-- ── Unidad 7 (A2·fr): El pasado: lo que hice ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('43cd7160-a37c-57f9-8a3f-92e88a231410','20000000-0000-0000-0000-000000000003','A2',7,$p$El pasado: lo que hice$p$,'#C0392B','history_edu')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('5b204d1f-37e7-5111-9b0e-dfd59d6fcd46','43cd7160-a37c-57f9-8a3f-92e88a231410',1,$p$Ayer comí y hablé$p$,$p$Ayer comí y hablé$p$,'lesson',15),
 ('85d2aae7-bb04-5643-a912-ca8063f769bf','43cd7160-a37c-57f9-8a3f-92e88a231410',2,$p$Participios irregulares$p$,$p$Participios irregulares$p$,'lesson',15),
 ('3d32489a-2910-516a-8229-f0fc4c98ae14','43cd7160-a37c-57f9-8a3f-92e88a231410',3,$p$No hice nada$p$,$p$No hice nada$p$,'lesson',15),
 ('2f24c55a-47f0-56d0-974e-8d294a236533','43cd7160-a37c-57f9-8a3f-92e88a231410',4,$p$¿Qué hiciste?$p$,$p$¿Qué hiciste?$p$,'lesson',15),
 ('4cb5c239-df16-57b1-9355-51c451a994a3','43cd7160-a37c-57f9-8a3f-92e88a231410',5,$p$🏁 Checkpoint Unité 7$p$,$p$Practica el passé composé con el auxiliar avoir para contar lo que hiciste ayer y la semana pasada.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('86653b4e-6946-5e90-97de-cf317437c5d6','20000000-0000-0000-0000-000000000003','checkpoint','A2','43cd7160-a37c-57f9-8a3f-92e88a231410',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('fcf84eda-e3af-5b8d-b9c6-5fb511a1167e'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','reading','match',$p$Une el verbo francés con su traducción.$p$,$j${"pairs": [{"en": "j'ai mangé", "es": "yo comí"}, {"en": "tu as parlé", "es": "tú hablaste"}, {"en": "il a regardé", "es": "él miró"}]}$j$::jsonb,$j${"pairs": [["j'ai mangé", "yo comí"], ["tu as parlé", "tú hablaste"], ["il a regardé", "él miró"]]}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$passe_compose_reguliers$p$, $p$reading$p$]),
('8973a4e9-a725-5a0f-97bc-6c537736300d'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','reading','match',$p$Une la expresión de tiempo con su traducción.$p$,$j${"pairs": [{"en": "hier", "es": "ayer"}, {"en": "avant-hier", "es": "anteayer"}, {"en": "la semaine dernière", "es": "la semana pasada"}]}$j$::jsonb,$j${"pairs": [["hier", "ayer"], ["avant-hier", "anteayer"], ["la semaine dernière", "la semana pasada"]]}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$expressions_temps$p$, $p$reading$p$]),
('21374e4b-c051-5526-bcd4-a6d996c0592c'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','reading','multiple_choice',$p$¿Cuál es la forma correcta de 'yo comí' en passé composé?$p$,$j${"options": ["j'ai mangé", "je suis mangé", "je mange"]}$j$::jsonb,$j${"value": "j'ai mangé"}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$passe_compose_reguliers$p$, $p$reading$p$]),
('f1da7e3a-d34a-5f60-be8c-f9519e6a015e'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','writing','cloze',$p$Completa: 'Ayer hablé con mi amigo.'$p$,$j${"text": "Hier, j'___ parlé avec mon ami."}$j$::jsonb,$j${"value": "ai", "accepted": ["ai"]}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$passe_compose_reguliers$p$, $p$writing$p$]),
('b19862ad-ed3f-5d51-9a8a-dd4c12c0dac4'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','writing','word_bank',$p$Ordena las fichas para decir 'Yo miré la televisión'.$p$,$j${"tiles": ["J'", "ai", "regardé", "la", "télévision", "regarde"]}$j$::jsonb,$j${"value": "J' ai regardé la télévision", "sequence": ["J'", "ai", "regardé", "la", "télévision"]}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$passe_compose_reguliers$p$, $p$writing$p$]),
('ad667955-0fe0-5f92-954b-f67606a41a1c'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Hier, j'ai mangé une pomme.", "Hier, je mange une pomme.", "Demain, je vais manger une pomme."], "say": "Hier, j'ai mangé une pomme.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/ad667955-0fe0-5f92-954b-f67606a41a1c.mp3"}$j$::jsonb,$j${"value": "Hier, j'ai mangé une pomme."}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$passe_compose_reguliers$p$, $p$listening$p$]),
('a07f4393-4b4e-53a7-be66-cc7e8d5305b6'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "J'ai parlé français hier.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/a07f4393-4b4e-53a7-be66-cc7e8d5305b6.mp3"}$j$::jsonb,$j${"expected": "J'ai parlé français hier."}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$passe_compose_reguliers$p$, $p$speaking$p$]),
('a8ea6fe0-49c2-514f-9183-7203890f3425'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','reading','multiple_choice',$p$¿Cuál es el participio pasado del verbo 'faire' (hacer)?$p$,$j${"options": ["fait", "faisé", "fais"]}$j$::jsonb,$j${"value": "fait"}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$participes_irreguliers$p$, $p$reading$p$]),
('49f2daa3-ac70-5977-a86b-3b02d277bd7a'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','reading','multiple_choice',$p$Elige la frase correcta para 'Vi una película'.$p$,$j${"options": ["J'ai vu un film.", "J'ai voir un film.", "Je suis vu un film."]}$j$::jsonb,$j${"value": "J'ai vu un film."}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$participes_irreguliers$p$, $p$reading$p$]),
('e91efb6e-ffad-5863-bf8d-695c182dfe15'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','writing','cloze',$p$Completa con el participio de 'prendre': 'Tomé el autobús.'$p$,$j${"text": "J'ai ___ le bus."}$j$::jsonb,$j${"value": "pris", "accepted": ["pris"]}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$participes_irreguliers$p$, $p$writing$p$]),
('7e99fd53-996b-5462-95b2-bf732b4b5032'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','writing','translation',$p$Traduce: 'Bebí un café.'$p$,$j${"source": "Bebí un café."}$j$::jsonb,$j${"value": "J'ai bu un café.", "accepted": ["J'ai bu un café.", "J'ai bu un café", "J'ai bu un cafe.", "J'ai bu un cafe", "Jai bu un cafe"]}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$participes_irreguliers$p$, $p$writing$p$]),
('06df7223-0df3-5972-b258-b58027e7b6f8'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["J'ai lu un livre intéressant.", "Je lis un livre intéressant.", "J'ai écrit un livre intéressant."], "say": "J'ai lu un livre intéressant.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/06df7223-0df3-5972-b258-b58027e7b6f8.mp3"}$j$::jsonb,$j${"value": "J'ai lu un livre intéressant."}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$participes_irreguliers$p$, $p$listening$p$]),
('d7d31c30-9e40-5506-a41f-d81adddbc9db'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "J'ai fait mes devoirs.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/d7d31c30-9e40-5506-a41f-d81adddbc9db.mp3"}$j$::jsonb,$j${"expected": "J'ai fait mes devoirs."}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$participes_irreguliers$p$, $p$speaking$p$]),
('b9fb0e45-159d-5c9e-a5d5-522954644c5b'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','reading','multiple_choice',$p$¿Cómo se dice 'No comí nada'?$p$,$j${"options": ["Je n'ai rien mangé.", "Je n'ai pas rien mangé.", "Je ne mange rien."]}$j$::jsonb,$j${"value": "Je n'ai rien mangé."}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$negation_passe$p$, $p$reading$p$]),
('ec271baf-b494-5a0c-ae36-d6f7c16e1264'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','writing','reorder',$p$Ordena las palabras para decir 'Él no hizo nada'.$p$,$j${"tiles": ["rien", "n'a", "Il", "fait"]}$j$::jsonb,$j${"value": "Il n'a rien fait"}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$negation_passe$p$, $p$writing$p$]),
('90f78950-7ce7-56fe-ba81-1be0c74585aa'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Je n'ai pas fini mon travail.", "J'ai fini mon travail.", "Je ne finis pas mon travail."], "say": "Je n'ai pas fini mon travail.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/90f78950-7ce7-56fe-ba81-1be0c74585aa.mp3"}$j$::jsonb,$j${"value": "Je n'ai pas fini mon travail."}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$negation_passe$p$, $p$listening$p$]),
('12a6bc05-0cfe-5571-829d-28de6f96d46b'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','writing','translation',$p$Traduce: '¿Qué hiciste ayer?'$p$,$j${"source": "¿Qué hiciste ayer?"}$j$::jsonb,$j${"value": "Qu'est-ce que tu as fait hier ?", "accepted": ["Qu'est-ce que tu as fait hier ?", "Qu'est-ce que tu as fait hier?", "Qu'est-ce que tu as fait hier", "Qu'est ce que tu as fait hier", "Quest-ce que tu as fait hier"]}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$questions_passe$p$, $p$writing$p$]),
('26a9c43b-bc63-5271-9b89-2503f5fa94d3'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Est-ce que vous avez mangé au restaurant ?", "Est-ce que vous mangez au restaurant ?", "Vous allez manger au restaurant ?"], "say": "Est-ce que vous avez mangé au restaurant ?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/26a9c43b-bc63-5271-9b89-2503f5fa94d3.mp3"}$j$::jsonb,$j${"value": "Est-ce que vous avez mangé au restaurant ?"}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$questions_passe$p$, $p$listening$p$]),
('df79df19-4c35-52f2-9be5-390f2012ad4d'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Qu'est-ce que tu as fait le week-end dernier ?", "Qu'est-ce que tu vas faire ce week-end ?", "Qu'est-ce que tu fais le week-end ?"], "say": "Qu'est-ce que tu as fait le week-end dernier ?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/df79df19-4c35-52f2-9be5-390f2012ad4d.mp3"}$j$::jsonb,$j${"value": "Qu'est-ce que tu as fait le week-end dernier ?"}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$questions_passe$p$, $p$listening$p$]),
('6b420632-5529-5f44-8d91-6bf53b2737f6'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "As-tu fini tes devoirs ?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/6b420632-5529-5f44-8d91-6bf53b2737f6.mp3"}$j$::jsonb,$j${"expected": "As-tu fini tes devoirs ?"}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$questions_passe$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('5b204d1f-37e7-5111-9b0e-dfd59d6fcd46','fcf84eda-e3af-5b8d-b9c6-5fb511a1167e',1),
 ('5b204d1f-37e7-5111-9b0e-dfd59d6fcd46','8973a4e9-a725-5a0f-97bc-6c537736300d',2),
 ('5b204d1f-37e7-5111-9b0e-dfd59d6fcd46','21374e4b-c051-5526-bcd4-a6d996c0592c',3),
 ('5b204d1f-37e7-5111-9b0e-dfd59d6fcd46','f1da7e3a-d34a-5f60-be8c-f9519e6a015e',4),
 ('5b204d1f-37e7-5111-9b0e-dfd59d6fcd46','b19862ad-ed3f-5d51-9a8a-dd4c12c0dac4',5),
 ('5b204d1f-37e7-5111-9b0e-dfd59d6fcd46','ad667955-0fe0-5f92-954b-f67606a41a1c',6),
 ('5b204d1f-37e7-5111-9b0e-dfd59d6fcd46','a07f4393-4b4e-53a7-be66-cc7e8d5305b6',7),
 ('85d2aae7-bb04-5643-a912-ca8063f769bf','a8ea6fe0-49c2-514f-9183-7203890f3425',1),
 ('85d2aae7-bb04-5643-a912-ca8063f769bf','49f2daa3-ac70-5977-a86b-3b02d277bd7a',2),
 ('85d2aae7-bb04-5643-a912-ca8063f769bf','e91efb6e-ffad-5863-bf8d-695c182dfe15',3),
 ('85d2aae7-bb04-5643-a912-ca8063f769bf','7e99fd53-996b-5462-95b2-bf732b4b5032',4),
 ('85d2aae7-bb04-5643-a912-ca8063f769bf','06df7223-0df3-5972-b258-b58027e7b6f8',5),
 ('85d2aae7-bb04-5643-a912-ca8063f769bf','d7d31c30-9e40-5506-a41f-d81adddbc9db',6),
 ('3d32489a-2910-516a-8229-f0fc4c98ae14','b9fb0e45-159d-5c9e-a5d5-522954644c5b',1),
 ('3d32489a-2910-516a-8229-f0fc4c98ae14','ec271baf-b494-5a0c-ae36-d6f7c16e1264',2),
 ('3d32489a-2910-516a-8229-f0fc4c98ae14','90f78950-7ce7-56fe-ba81-1be0c74585aa',3),
 ('2f24c55a-47f0-56d0-974e-8d294a236533','12a6bc05-0cfe-5571-829d-28de6f96d46b',1),
 ('2f24c55a-47f0-56d0-974e-8d294a236533','26a9c43b-bc63-5271-9b89-2503f5fa94d3',2),
 ('2f24c55a-47f0-56d0-974e-8d294a236533','df79df19-4c35-52f2-9be5-390f2012ad4d',3),
 ('2f24c55a-47f0-56d0-974e-8d294a236533','6b420632-5529-5f44-8d91-6bf53b2737f6',4),
 ('4cb5c239-df16-57b1-9355-51c451a994a3','fcf84eda-e3af-5b8d-b9c6-5fb511a1167e',1),
 ('4cb5c239-df16-57b1-9355-51c451a994a3','8973a4e9-a725-5a0f-97bc-6c537736300d',2),
 ('4cb5c239-df16-57b1-9355-51c451a994a3','21374e4b-c051-5526-bcd4-a6d996c0592c',3),
 ('4cb5c239-df16-57b1-9355-51c451a994a3','f1da7e3a-d34a-5f60-be8c-f9519e6a015e',4),
 ('4cb5c239-df16-57b1-9355-51c451a994a3','b19862ad-ed3f-5d51-9a8a-dd4c12c0dac4',5),
 ('4cb5c239-df16-57b1-9355-51c451a994a3','e91efb6e-ffad-5863-bf8d-695c182dfe15',6),
 ('4cb5c239-df16-57b1-9355-51c451a994a3','ad667955-0fe0-5f92-954b-f67606a41a1c',7),
 ('4cb5c239-df16-57b1-9355-51c451a994a3','06df7223-0df3-5972-b258-b58027e7b6f8',8),
 ('4cb5c239-df16-57b1-9355-51c451a994a3','a07f4393-4b4e-53a7-be66-cc7e8d5305b6',9),
 ('4cb5c239-df16-57b1-9355-51c451a994a3','d7d31c30-9e40-5506-a41f-d81adddbc9db',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('dc724c05-d667-5f18-9481-e0be2bda72c6','20000000-0000-0000-0000-000000000003',$p$hier$p$,$p$ayer$p$,241,'adverbio'),
 ('60172eef-58fd-5895-9cfd-3a77290f7561','20000000-0000-0000-0000-000000000003',$p$avant-hier$p$,$p$anteayer$p$,242,'adverbio'),
 ('6a8cb44c-8b07-5516-88d2-8dab0acaa691','20000000-0000-0000-0000-000000000003',$p$la semaine dernière$p$,$p$la semana pasada$p$,243,'expresion'),
 ('1a796a8e-5234-56f2-b277-294e34e1b7e9','20000000-0000-0000-0000-000000000003',$p$le week-end dernier$p$,$p$el fin de semana pasado$p$,244,'expresion'),
 ('99b4ed9a-f5f0-589b-9acb-d04489b45e87','20000000-0000-0000-0000-000000000003',$p$manger$p$,$p$comer$p$,245,'verbo'),
 ('382da2d8-dbc9-5354-9140-b2ef5d3be796','20000000-0000-0000-0000-000000000003',$p$parler$p$,$p$hablar$p$,246,'verbo'),
 ('dddda297-4cad-5fb0-9bed-4aad4b90c9fb','20000000-0000-0000-0000-000000000003',$p$regarder$p$,$p$mirar / ver$p$,247,'verbo'),
 ('6536f844-cfc5-5d2f-bdfb-0b40171c838d','20000000-0000-0000-0000-000000000003',$p$finir$p$,$p$terminar$p$,248,'verbo'),
 ('063fd7be-2a4f-51ff-8ed8-145677e111ac','20000000-0000-0000-0000-000000000003',$p$faire$p$,$p$hacer$p$,249,'verbo'),
 ('83d947d6-a9ed-5550-b33b-bb189348e43c','20000000-0000-0000-0000-000000000003',$p$prendre$p$,$p$tomar / coger$p$,250,'verbo'),
 ('b8c29513-e325-5c5b-8cb7-e918a06af398','20000000-0000-0000-0000-000000000003',$p$voir$p$,$p$ver$p$,251,'verbo'),
 ('a28c279e-2adf-53ab-b478-fe09f924a199','20000000-0000-0000-0000-000000000003',$p$boire$p$,$p$beber$p$,252,'verbo'),
 ('40b024cd-a44c-5f01-ab6d-75d98f01a8bf','20000000-0000-0000-0000-000000000003',$p$lire$p$,$p$leer$p$,253,'verbo'),
 ('614e40cb-4e31-5182-8966-1c2f0affe854','20000000-0000-0000-0000-000000000003',$p$écrire$p$,$p$escribir$p$,254,'verbo'),
 ('1c2c5ee2-05e7-5be6-b3e8-fd78b19a1984','20000000-0000-0000-0000-000000000003',$p$rien$p$,$p$nada$p$,255,'pronombre'),
 ('46810df6-0653-5484-8798-370bc6716000','20000000-0000-0000-0000-000000000003',$p$déjà$p$,$p$ya$p$,256,'adverbio')
on conflict (id) do nothing;

-- ── Unidad 8 (A2·fr): Planes y futuro ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('602cabea-14cf-5952-b4d4-8a6db36e62a4','20000000-0000-0000-0000-000000000003','A2',8,$p$Planes y futuro$p$,'#2C3E50','event_available')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('d74bcfc1-b8f8-54e8-940c-268f5447b6ff','602cabea-14cf-5952-b4d4-8a6db36e62a4',1,$p$Voy a hacer (futur proche)$p$,$p$Voy a hacer (futur proche)$p$,'lesson',15),
 ('43850764-ee78-5ec5-956a-c8dcd890818e','602cabea-14cf-5952-b4d4-8a6db36e62a4',2,$p$Hablaré, terminaré (futur simple)$p$,$p$Hablaré, terminaré (futur simple)$p$,'lesson',15),
 ('5196b717-c741-51e8-b181-0c9c857997f9','602cabea-14cf-5952-b4d4-8a6db36e62a4',3,$p$Futuros irregulares$p$,$p$Futuros irregulares$p$,'lesson',15),
 ('21f43a0b-ad65-5933-9d23-46462b6048a0','602cabea-14cf-5952-b4d4-8a6db36e62a4',4,$p$Mañana y la próxima semana$p$,$p$Mañana y la próxima semana$p$,'lesson',15),
 ('e4cde191-17c5-57c9-acd7-0e5a060df4ee','602cabea-14cf-5952-b4d4-8a6db36e62a4',5,$p$🏁 Checkpoint Unité 8$p$,$p$Practica el futur proche (je vais + infinitivo) y el futur simple para hablar de planes y predicciones.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('85524961-027b-5765-8928-7db28f4dc99c','20000000-0000-0000-0000-000000000003','checkpoint','A2','602cabea-14cf-5952-b4d4-8a6db36e62a4',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('e7c5c74b-8642-5618-a1c4-a0c9d87a292d'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','reading','match',$p$Une la frase francesa con su traducción.$p$,$j${"pairs": [{"en": "je vais partir", "es": "voy a salir"}, {"en": "on va manger", "es": "vamos a comer"}, {"en": "ils vont voyager", "es": "ellos van a viajar"}]}$j$::jsonb,$j${"pairs": [["je vais partir", "voy a salir"], ["on va manger", "vamos a comer"], ["ils vont voyager", "ellos van a viajar"]]}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$futur_proche$p$, $p$reading$p$]),
('74dec7e7-3fcb-5289-9103-64d0fdf005ae'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','reading','multiple_choice',$p$¿Cómo se dice 'Voy a viajar mañana' con futur proche?$p$,$j${"options": ["Je vais voyager demain.", "Je voyage demain.", "J'ai voyagé demain."]}$j$::jsonb,$j${"value": "Je vais voyager demain."}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$futur_proche$p$, $p$reading$p$]),
('385409b5-b96a-5637-8c93-d931e410e5b0'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','writing','cloze',$p$Completa con el auxiliar 'aller': 'Vamos a comer juntos.'$p$,$j${"text": "On ___ manger ensemble."}$j$::jsonb,$j${"value": "va", "accepted": ["va"]}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$futur_proche$p$, $p$writing$p$]),
('a5973b29-4afe-5b2f-8287-96101a9caed0'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','writing','word_bank',$p$Ordena las fichas para decir 'Voy a visitar París'.$p$,$j${"tiles": ["Je", "vais", "visiter", "Paris", "visite"]}$j$::jsonb,$j${"value": "Je vais visiter Paris", "sequence": ["Je", "vais", "visiter", "Paris"]}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$futur_proche$p$, $p$writing$p$]),
('edc8a928-6e76-5e9a-8046-98e2f0033830'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Je vais partir demain matin.", "Je suis parti hier matin.", "Je pars demain matin."], "say": "Je vais partir demain matin.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/edc8a928-6e76-5e9a-8046-98e2f0033830.mp3"}$j$::jsonb,$j${"value": "Je vais partir demain matin."}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$futur_proche$p$, $p$listening$p$]),
('fa435939-8d1e-5d40-a78d-a6209e883e86'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "On va voyager ensemble.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/fa435939-8d1e-5d40-a78d-a6209e883e86.mp3"}$j$::jsonb,$j${"expected": "On va voyager ensemble."}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$futur_proche$p$, $p$speaking$p$]),
('1fdd7466-11e9-581a-9396-79e28edbe4ea'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','reading','match',$p$Une el verbo en futur simple con su traducción.$p$,$j${"pairs": [{"en": "je parlerai", "es": "yo hablaré"}, {"en": "tu finiras", "es": "tú terminarás"}, {"en": "il visitera", "es": "él visitará"}]}$j$::jsonb,$j${"pairs": [["je parlerai", "yo hablaré"], ["tu finiras", "tú terminarás"], ["il visitera", "él visitará"]]}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$futur_simple_reguliers$p$, $p$reading$p$]),
('90e1aa94-2307-5066-805c-8c3214249ecf'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','writing','cloze',$p$Completa con el futur simple de 'finir': 'Terminaré mañana.'$p$,$j${"text": "Je ___ demain."}$j$::jsonb,$j${"value": "finirai", "accepted": ["finirai"]}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$futur_simple_reguliers$p$, $p$writing$p$]),
('a7e4fd96-5d2b-5015-b988-0aa56e4713a0'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','writing','translation',$p$Traduce: 'Visitaré el museo.'$p$,$j${"source": "Visitaré el museo."}$j$::jsonb,$j${"value": "Je visiterai le musée.", "accepted": ["Je visiterai le musée.", "Je visiterai le musée", "Je visiterai le musee.", "Je visiterai le musee", "Je visiterai le musee"]}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$futur_simple_reguliers$p$, $p$writing$p$]),
('7fac4e88-44be-5d38-b0c6-2324ed1741cb'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Tu finiras ton travail bientôt.", "Tu as fini ton travail.", "Tu vas finir ton travail."], "say": "Tu finiras ton travail bientôt.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/7fac4e88-44be-5d38-b0c6-2324ed1741cb.mp3"}$j$::jsonb,$j${"value": "Tu finiras ton travail bientôt."}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$futur_simple_reguliers$p$, $p$listening$p$]),
('028e7ad5-7a39-5091-ae47-343ba0917c23'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','reading','multiple_choice',$p$¿Cuál es el futur simple de 'être' en primera persona ('yo seré')?$p$,$j${"options": ["je serai", "je suis", "j'étais"]}$j$::jsonb,$j${"value": "je serai"}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$futur_simple_irreguliers$p$, $p$reading$p$]),
('09eb55b0-e1f6-5212-8615-75fbe6ac53c1'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','writing','cloze',$p$Completa con el futur simple de 'aller': 'Iré a Francia el año que viene.'$p$,$j${"text": "J'___ en France l'année prochaine."}$j$::jsonb,$j${"value": "irai", "accepted": ["irai"]}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$futur_simple_irreguliers$p$, $p$writing$p$]),
('d36264d8-ccca-5f71-a19e-5d2b72641d0c'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','writing','translation',$p$Traduce: 'Tendré tiempo mañana.'$p$,$j${"source": "Tendré tiempo mañana."}$j$::jsonb,$j${"value": "J'aurai le temps demain.", "accepted": ["J'aurai le temps demain.", "J'aurai le temps demain", "Jaurai le temps demain", "J'aurai le temps demain"]}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$futur_simple_irreguliers$p$, $p$writing$p$]),
('b0c09feb-2b8e-5834-8a8e-28cd81cb218c'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Je ferai un grand voyage l'année prochaine.", "J'ai fait un grand voyage l'année dernière.", "Je vais faire un grand voyage."], "say": "Je ferai un grand voyage l'année prochaine.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/b0c09feb-2b8e-5834-8a8e-28cd81cb218c.mp3"}$j$::jsonb,$j${"value": "Je ferai un grand voyage l'année prochaine."}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$futur_simple_irreguliers$p$, $p$listening$p$]),
('6015c065-543d-579d-bc35-64e1fd10318c'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Je viendrai chez toi ce soir.", "Je suis venu chez toi.", "Je viens chez toi ce soir."], "say": "Je viendrai chez toi ce soir.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/6015c065-543d-579d-bc35-64e1fd10318c.mp3"}$j$::jsonb,$j${"value": "Je viendrai chez toi ce soir."}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$futur_simple_irreguliers$p$, $p$listening$p$]),
('dded605b-0355-5bd2-9cca-870d66e89722'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Je ferai un grand voyage.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/dded605b-0355-5bd2-9cca-870d66e89722.mp3"}$j$::jsonb,$j${"expected": "Je ferai un grand voyage."}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$futur_simple_irreguliers$p$, $p$speaking$p$]),
('d8d44aee-1ad7-53d8-81d7-5406855b9b82'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','reading','multiple_choice',$p$¿Cuál es la forma correcta de 'Cuando tenga tiempo, viajaré'?$p$,$j${"options": ["Quand j'aurai le temps, je voyagerai.", "Quand j'ai le temps, je voyagerai.", "Quand j'aurai le temps, je voyage."]}$j$::jsonb,$j${"value": "Quand j'aurai le temps, je voyagerai."}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$futur_quand_temps$p$, $p$reading$p$]),
('fcac353b-2a13-55ef-88b6-15bdf4c696ce'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','reading','match',$p$Une la expresión de tiempo con su traducción.$p$,$j${"pairs": [{"en": "demain", "es": "mañana"}, {"en": "la semaine prochaine", "es": "la semana que viene"}, {"en": "bientôt", "es": "pronto"}]}$j$::jsonb,$j${"pairs": [["demain", "mañana"], ["la semaine prochaine", "la semana que viene"], ["bientôt", "pronto"]]}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$futur_quand_temps$p$, $p$reading$p$]),
('e0a14905-b7a6-55af-b98e-05038b164edf'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Quand j'aurai le temps, je viendrai.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/e0a14905-b7a6-55af-b98e-05038b164edf.mp3"}$j$::jsonb,$j${"expected": "Quand j'aurai le temps, je viendrai."}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$futur_quand_temps$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('d74bcfc1-b8f8-54e8-940c-268f5447b6ff','e7c5c74b-8642-5618-a1c4-a0c9d87a292d',1),
 ('d74bcfc1-b8f8-54e8-940c-268f5447b6ff','74dec7e7-3fcb-5289-9103-64d0fdf005ae',2),
 ('d74bcfc1-b8f8-54e8-940c-268f5447b6ff','385409b5-b96a-5637-8c93-d931e410e5b0',3),
 ('d74bcfc1-b8f8-54e8-940c-268f5447b6ff','a5973b29-4afe-5b2f-8287-96101a9caed0',4),
 ('d74bcfc1-b8f8-54e8-940c-268f5447b6ff','edc8a928-6e76-5e9a-8046-98e2f0033830',5),
 ('d74bcfc1-b8f8-54e8-940c-268f5447b6ff','fa435939-8d1e-5d40-a78d-a6209e883e86',6),
 ('43850764-ee78-5ec5-956a-c8dcd890818e','1fdd7466-11e9-581a-9396-79e28edbe4ea',1),
 ('43850764-ee78-5ec5-956a-c8dcd890818e','90e1aa94-2307-5066-805c-8c3214249ecf',2),
 ('43850764-ee78-5ec5-956a-c8dcd890818e','a7e4fd96-5d2b-5015-b988-0aa56e4713a0',3),
 ('43850764-ee78-5ec5-956a-c8dcd890818e','7fac4e88-44be-5d38-b0c6-2324ed1741cb',4),
 ('5196b717-c741-51e8-b181-0c9c857997f9','028e7ad5-7a39-5091-ae47-343ba0917c23',1),
 ('5196b717-c741-51e8-b181-0c9c857997f9','09eb55b0-e1f6-5212-8615-75fbe6ac53c1',2),
 ('5196b717-c741-51e8-b181-0c9c857997f9','d36264d8-ccca-5f71-a19e-5d2b72641d0c',3),
 ('5196b717-c741-51e8-b181-0c9c857997f9','b0c09feb-2b8e-5834-8a8e-28cd81cb218c',4),
 ('5196b717-c741-51e8-b181-0c9c857997f9','6015c065-543d-579d-bc35-64e1fd10318c',5),
 ('5196b717-c741-51e8-b181-0c9c857997f9','dded605b-0355-5bd2-9cca-870d66e89722',6),
 ('21f43a0b-ad65-5933-9d23-46462b6048a0','d8d44aee-1ad7-53d8-81d7-5406855b9b82',1),
 ('21f43a0b-ad65-5933-9d23-46462b6048a0','fcac353b-2a13-55ef-88b6-15bdf4c696ce',2),
 ('21f43a0b-ad65-5933-9d23-46462b6048a0','e0a14905-b7a6-55af-b98e-05038b164edf',3),
 ('e4cde191-17c5-57c9-acd7-0e5a060df4ee','e7c5c74b-8642-5618-a1c4-a0c9d87a292d',1),
 ('e4cde191-17c5-57c9-acd7-0e5a060df4ee','74dec7e7-3fcb-5289-9103-64d0fdf005ae',2),
 ('e4cde191-17c5-57c9-acd7-0e5a060df4ee','1fdd7466-11e9-581a-9396-79e28edbe4ea',3),
 ('e4cde191-17c5-57c9-acd7-0e5a060df4ee','385409b5-b96a-5637-8c93-d931e410e5b0',4),
 ('e4cde191-17c5-57c9-acd7-0e5a060df4ee','a5973b29-4afe-5b2f-8287-96101a9caed0',5),
 ('e4cde191-17c5-57c9-acd7-0e5a060df4ee','90e1aa94-2307-5066-805c-8c3214249ecf',6),
 ('e4cde191-17c5-57c9-acd7-0e5a060df4ee','edc8a928-6e76-5e9a-8046-98e2f0033830',7),
 ('e4cde191-17c5-57c9-acd7-0e5a060df4ee','7fac4e88-44be-5d38-b0c6-2324ed1741cb',8),
 ('e4cde191-17c5-57c9-acd7-0e5a060df4ee','fa435939-8d1e-5d40-a78d-a6209e883e86',9),
 ('e4cde191-17c5-57c9-acd7-0e5a060df4ee','dded605b-0355-5bd2-9cca-870d66e89722',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('8ca043b6-9774-55fc-8696-fec4d6a47061','20000000-0000-0000-0000-000000000003',$p$demain$p$,$p$mañana$p$,261,'adverbio'),
 ('b414a9a3-f70a-52c9-a941-657b236d1fa8','20000000-0000-0000-0000-000000000003',$p$après-demain$p$,$p$pasado mañana$p$,262,'adverbio'),
 ('1423b092-59a7-5ac7-99d5-051e9785bbbf','20000000-0000-0000-0000-000000000003',$p$la semaine prochaine$p$,$p$la semana que viene$p$,263,'expresion'),
 ('8e4b10d5-2acd-5900-9a20-8bc21cf90d46','20000000-0000-0000-0000-000000000003',$p$l'année prochaine$p$,$p$el año que viene$p$,264,'expresion'),
 ('72f45ff4-0bb9-5ecc-bff6-f25bd6870576','20000000-0000-0000-0000-000000000003',$p$bientôt$p$,$p$pronto$p$,265,'adverbio'),
 ('65432bd5-1e17-5d75-a081-f7eef276adad','20000000-0000-0000-0000-000000000003',$p$quand$p$,$p$cuando$p$,266,'adverbio'),
 ('d6db24b9-584c-56e1-b2e4-4a1805a07857','20000000-0000-0000-0000-000000000003',$p$partir$p$,$p$salir / marcharse$p$,267,'verbo'),
 ('5b0f8448-53c1-5426-8f66-7ec4dd07de9b','20000000-0000-0000-0000-000000000003',$p$voyager$p$,$p$viajar$p$,268,'verbo'),
 ('b4e3f092-2268-521d-a91a-9faff50f0121','20000000-0000-0000-0000-000000000003',$p$visiter$p$,$p$visitar$p$,269,'verbo'),
 ('d0799e9d-5f28-57c1-a045-07ca31f59ac2','20000000-0000-0000-0000-000000000003',$p$être$p$,$p$ser / estar$p$,270,'verbo'),
 ('59ceff00-614a-5bef-abd2-d4fb9fc12586','20000000-0000-0000-0000-000000000003',$p$avoir$p$,$p$tener$p$,271,'verbo'),
 ('0e1876b2-52d4-5ab4-bbf2-0dd1bc4dc46e','20000000-0000-0000-0000-000000000003',$p$aller$p$,$p$ir$p$,272,'verbo'),
 ('ed4078ea-abe8-5ea1-ac41-52f933debd17','20000000-0000-0000-0000-000000000003',$p$venir$p$,$p$venir$p$,273,'verbo'),
 ('97a22737-8ce8-5c6b-95f4-01d7f828eb3b','20000000-0000-0000-0000-000000000003',$p$le temps$p$,$p$el tiempo$p$,274,'sustantivo'),
 ('f9f3d044-c083-5f9e-b1f5-acc2018a4b90','20000000-0000-0000-0000-000000000003',$p$un projet$p$,$p$un plan / proyecto$p$,275,'sustantivo'),
 ('8982bead-a5fe-5510-943d-f5dd00f6b3fc','20000000-0000-0000-0000-000000000003',$p$ensemble$p$,$p$juntos$p$,276,'adverbio')
on conflict (id) do nothing;

-- ── Unidad 9 (A2·fr): De viaje ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('bd0cfed7-4d84-5895-ac9d-8019114db219','20000000-0000-0000-0000-000000000003','A2',9,$p$De viaje$p$,'#16A085','flight_takeoff')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('14ca990d-2e43-509c-8c8a-70f546e709b0','bd0cfed7-4d84-5895-ac9d-8019114db219',1,$p$Verbos de movimiento con être$p$,$p$Verbos de movimiento con être$p$,'lesson',15),
 ('c498e9a8-af5c-55c1-b950-8f68a1594a8c','bd0cfed7-4d84-5895-ac9d-8019114db219',2,$p$La concordancia del participio$p$,$p$La concordancia del participio$p$,'lesson',15),
 ('3b93a56e-01d4-52bf-b5e4-16b6d471125c','bd0cfed7-4d84-5895-ac9d-8019114db219',3,$p$En la estación y el aeropuerto$p$,$p$En la estación y el aeropuerto$p$,'lesson',15),
 ('7c2a8798-ee42-5fc9-a03c-47bbfde48f6f','bd0cfed7-4d84-5895-ac9d-8019114db219',4,$p$Contar un viaje$p$,$p$Contar un viaje$p$,'lesson',15),
 ('d48fc25e-d6f0-5610-8d71-ceb0ed5676ab','bd0cfed7-4d84-5895-ac9d-8019114db219',5,$p$🏁 Checkpoint Unité 9$p$,$p$Cuenta un viaje en pasado con el auxiliar être y su concordancia, usando vocabulario de transporte.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('2174dc59-4036-5369-aa2a-d525f27d04a0','20000000-0000-0000-0000-000000000003','checkpoint','A2','bd0cfed7-4d84-5895-ac9d-8019114db219',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('005c7359-8eb8-515b-b851-434025e79a1c'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','reading','match',$p$Une los verbos con su traducción.$p$,$j${"pairs": [{"en": "partir", "es": "salir"}, {"en": "arriver", "es": "llegar"}, {"en": "rester", "es": "quedarse"}]}$j$::jsonb,$j${"pairs": [["partir", "salir"], ["arriver", "llegar"], ["rester", "quedarse"]]}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$verbes_etre$p$, $p$reading$p$]),
('87899bfe-b3dc-5ccc-88f8-1c45c40677f1'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','reading','match',$p$Une la palabra francesa con su significado.$p$,$j${"pairs": [{"en": "la gare", "es": "la estación"}, {"en": "le billet", "es": "el billete"}, {"en": "la valise", "es": "la maleta"}]}$j$::jsonb,$j${"pairs": [["la gare", "la estación"], ["le billet", "el billete"], ["la valise", "la maleta"]]}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$voyage_lexique$p$, $p$reading$p$]),
('b360f838-3b95-5907-ad05-48f8b246eb5a'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','reading','multiple_choice',$p$¿Cuál es el auxiliar correcto? 'Je ___ allé à Lyon.'$p$,$j${"options": ["suis", "ai", "vais"]}$j$::jsonb,$j${"value": "suis"}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$verbes_etre$p$, $p$reading$p$]),
('f8d6b5c8-777f-5655-878e-1ef0ace105a0'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','reading','multiple_choice',$p$¿Por qué decimos 'je suis allé' y no 'j'ai allé'?$p$,$j${"options": ["porque 'aller' usa el auxiliar être", "porque 'aller' usa el auxiliar avoir", "porque es un verbo reflexivo"]}$j$::jsonb,$j${"value": "porque 'aller' usa el auxiliar être"}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$avoir_ou_etre$p$, $p$reading$p$]),
('71cedefb-316a-584b-b77c-dce6bfc5c90d'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','reading','multiple_choice',$p$Elige la frase correcta (concordancia con être).$p$,$j${"options": ["Elle est partie ce matin.", "Elle est parti ce matin.", "Elle a partie ce matin."]}$j$::jsonb,$j${"value": "Elle est partie ce matin."}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$accord_participe$p$, $p$reading$p$]),
('c86c9472-99cd-5ddc-95a6-f51277b80d3d'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','reading','multiple_choice',$p$¿Dónde se toma el avión?$p$,$j${"options": ["à l'aéroport", "à la gare", "à l'hôtel"]}$j$::jsonb,$j${"value": "à l'aéroport"}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$voyage_lexique$p$, $p$reading$p$]),
('efd44352-1627-51b1-890b-97456f91494f'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','writing','cloze',$p$Completa con el participio concordado (sujeto femenino singular).$p$,$j${"text": "Marie est ___ à la gare à huit heures."}$j$::jsonb,$j${"value": "arrivée", "accepted": ["arrivée", "arrivee"]}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$accord_participe$p$, $p$writing$p$]),
('6860980d-fa93-5723-823f-0b3e535c3074'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','writing','cloze',$p$Completa con el participio concordado (sujeto 'elles', plural femenino).$p$,$j${"text": "Elles sont ___ de Paris en train."}$j$::jsonb,$j${"value": "venues", "accepted": ["venues"]}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$accord_participe$p$, $p$writing$p$]),
('054224ce-63f3-5cc3-8c45-c628d5cf231d'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','writing','translation',$p$Traduce: 'Nosotros nos quedamos en el hotel.' (usa 'nous', masculino)$p$,$j${"source": "Nosotros nos quedamos en el hotel."}$j$::jsonb,$j${"value": "Nous sommes restés à l'hôtel.", "accepted": ["Nous sommes restés à l'hôtel.", "Nous sommes restés à l'hôtel", "Nous sommes restes a l'hotel"]}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$verbes_etre$p$, $p$writing$p$]),
('5cc1a3da-0088-582a-b37d-783ce91f9c96'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','writing','translation',$p$Traduce: 'Ellos llegaron ayer.' (usa 'ils')$p$,$j${"source": "Ellos llegaron ayer."}$j$::jsonb,$j${"value": "Ils sont arrivés hier.", "accepted": ["Ils sont arrivés hier.", "Ils sont arrivés hier", "Ils sont arrives hier"]}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$raconter_voyage$p$, $p$writing$p$]),
('57577876-762a-5c3a-b0e3-ad103c31ca0f'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','writing','word_bank',$p$Ordena las fichas para formar: 'Ella se fue a las diez.'$p$,$j${"tiles": ["Elle", "est", "partie", "à", "dix", "heures", "avons", "allé"]}$j$::jsonb,$j${"value": "Elle est partie à dix heures", "sequence": ["Elle", "est", "partie", "à", "dix", "heures"]}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$raconter_voyage$p$, $p$writing$p$]),
('e340e353-9e3f-5403-8792-2e61349827bf'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','writing','reorder',$p$Ordena las palabras: 'Reservé un billete de tren.'$p$,$j${"tiles": ["un", "J'ai", "de", "réservé", "train", "billet"]}$j$::jsonb,$j${"value": "J'ai réservé un billet de train"}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$voyage_lexique$p$, $p$writing$p$]),
('573b3f5a-b186-5d1d-a689-24da34db2904'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Je suis allé à l'aéroport en taxi.", "Je suis allé à la gare en bus.", "Je suis resté à l'hôtel ce soir."], "say": "Je suis allé à l'aéroport en taxi.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/573b3f5a-b186-5d1d-a689-24da34db2904.mp3"}$j$::jsonb,$j${"value": "Je suis allé à l'aéroport en taxi."}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$verbes_etre$p$, $p$listening$p$]),
('ad89b40d-1712-5e72-9369-7600c541bf94'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Elles sont parties très tôt ce matin.", "Ils sont partis très tard ce soir.", "Elle est arrivée très tôt ce matin."], "say": "Elles sont parties très tôt ce matin.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/ad89b40d-1712-5e72-9369-7600c541bf94.mp3"}$j$::jsonb,$j${"value": "Elles sont parties très tôt ce matin."}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$accord_participe$p$, $p$listening$p$]),
('2cc171f5-c572-5769-9bed-e6fd5603583b'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Le train part de la gare à midi.", "L'avion part de l'aéroport à midi.", "Le bus part de la ville à minuit."], "say": "Le train part de la gare à midi.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/2cc171f5-c572-5769-9bed-e6fd5603583b.mp3"}$j$::jsonb,$j${"value": "Le train part de la gare à midi."}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$voyage_lexique$p$, $p$listening$p$]),
('390fa764-4b76-5475-b4c8-55ecf181ff01'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Nous sommes arrivés à Nice avec nos valises.", "Nous sommes restés à Nice sans nos valises.", "Vous êtes arrivés à Nice avec vos billets."], "say": "Nous sommes arrivés à Nice avec nos valises.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/390fa764-4b76-5475-b4c8-55ecf181ff01.mp3"}$j$::jsonb,$j${"value": "Nous sommes arrivés à Nice avec nos valises."}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$raconter_voyage$p$, $p$listening$p$]),
('e0133df9-2c38-52dc-bce6-42e0ddb140d4'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Je suis allée à Paris en train.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/e0133df9-2c38-52dc-bce6-42e0ddb140d4.mp3"}$j$::jsonb,$j${"expected": "Je suis allée à Paris en train."}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$verbes_etre$p$, $p$speaking$p$]),
('c2098063-96a3-55e1-a8c7-e253812072cf'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Bon voyage ! N'oublie pas ton billet.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/c2098063-96a3-55e1-a8c7-e253812072cf.mp3"}$j$::jsonb,$j${"expected": "Bon voyage ! N'oublie pas ton billet."}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$voyage_lexique$p$, $p$speaking$p$]),
('10675779-1de7-53ba-a133-6dcf343f62a8'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Ils sont partis à l'aéroport ce matin.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/10675779-1de7-53ba-a133-6dcf343f62a8.mp3"}$j$::jsonb,$j${"expected": "Ils sont partis à l'aéroport ce matin."}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$raconter_voyage$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('14ca990d-2e43-509c-8c8a-70f546e709b0','005c7359-8eb8-515b-b851-434025e79a1c',1),
 ('14ca990d-2e43-509c-8c8a-70f546e709b0','b360f838-3b95-5907-ad05-48f8b246eb5a',2),
 ('14ca990d-2e43-509c-8c8a-70f546e709b0','f8d6b5c8-777f-5655-878e-1ef0ace105a0',3),
 ('14ca990d-2e43-509c-8c8a-70f546e709b0','054224ce-63f3-5cc3-8c45-c628d5cf231d',4),
 ('14ca990d-2e43-509c-8c8a-70f546e709b0','573b3f5a-b186-5d1d-a689-24da34db2904',5),
 ('14ca990d-2e43-509c-8c8a-70f546e709b0','e0133df9-2c38-52dc-bce6-42e0ddb140d4',6),
 ('c498e9a8-af5c-55c1-b950-8f68a1594a8c','71cedefb-316a-584b-b77c-dce6bfc5c90d',1),
 ('c498e9a8-af5c-55c1-b950-8f68a1594a8c','efd44352-1627-51b1-890b-97456f91494f',2),
 ('c498e9a8-af5c-55c1-b950-8f68a1594a8c','6860980d-fa93-5723-823f-0b3e535c3074',3),
 ('c498e9a8-af5c-55c1-b950-8f68a1594a8c','ad89b40d-1712-5e72-9369-7600c541bf94',4),
 ('3b93a56e-01d4-52bf-b5e4-16b6d471125c','87899bfe-b3dc-5ccc-88f8-1c45c40677f1',1),
 ('3b93a56e-01d4-52bf-b5e4-16b6d471125c','c86c9472-99cd-5ddc-95a6-f51277b80d3d',2),
 ('3b93a56e-01d4-52bf-b5e4-16b6d471125c','e340e353-9e3f-5403-8792-2e61349827bf',3),
 ('3b93a56e-01d4-52bf-b5e4-16b6d471125c','2cc171f5-c572-5769-9bed-e6fd5603583b',4),
 ('3b93a56e-01d4-52bf-b5e4-16b6d471125c','c2098063-96a3-55e1-a8c7-e253812072cf',5),
 ('7c2a8798-ee42-5fc9-a03c-47bbfde48f6f','5cc1a3da-0088-582a-b37d-783ce91f9c96',1),
 ('7c2a8798-ee42-5fc9-a03c-47bbfde48f6f','57577876-762a-5c3a-b0e3-ad103c31ca0f',2),
 ('7c2a8798-ee42-5fc9-a03c-47bbfde48f6f','390fa764-4b76-5475-b4c8-55ecf181ff01',3),
 ('7c2a8798-ee42-5fc9-a03c-47bbfde48f6f','10675779-1de7-53ba-a133-6dcf343f62a8',4),
 ('d48fc25e-d6f0-5610-8d71-ceb0ed5676ab','005c7359-8eb8-515b-b851-434025e79a1c',1),
 ('d48fc25e-d6f0-5610-8d71-ceb0ed5676ab','87899bfe-b3dc-5ccc-88f8-1c45c40677f1',2),
 ('d48fc25e-d6f0-5610-8d71-ceb0ed5676ab','b360f838-3b95-5907-ad05-48f8b246eb5a',3),
 ('d48fc25e-d6f0-5610-8d71-ceb0ed5676ab','efd44352-1627-51b1-890b-97456f91494f',4),
 ('d48fc25e-d6f0-5610-8d71-ceb0ed5676ab','6860980d-fa93-5723-823f-0b3e535c3074',5),
 ('d48fc25e-d6f0-5610-8d71-ceb0ed5676ab','054224ce-63f3-5cc3-8c45-c628d5cf231d',6),
 ('d48fc25e-d6f0-5610-8d71-ceb0ed5676ab','573b3f5a-b186-5d1d-a689-24da34db2904',7),
 ('d48fc25e-d6f0-5610-8d71-ceb0ed5676ab','ad89b40d-1712-5e72-9369-7600c541bf94',8),
 ('d48fc25e-d6f0-5610-8d71-ceb0ed5676ab','e0133df9-2c38-52dc-bce6-42e0ddb140d4',9),
 ('d48fc25e-d6f0-5610-8d71-ceb0ed5676ab','c2098063-96a3-55e1-a8c7-e253812072cf',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('43dbf478-c4bc-5009-845e-4237fe9e1cba','20000000-0000-0000-0000-000000000003',$p$le train$p$,$p$el tren$p$,281,'sustantivo'),
 ('8706c1d8-c343-503b-9526-132ad1315fbb','20000000-0000-0000-0000-000000000003',$p$l'avion$p$,$p$el avión$p$,282,'sustantivo'),
 ('281098e7-7e8d-5371-92b8-dc3242e2f3c6','20000000-0000-0000-0000-000000000003',$p$la gare$p$,$p$la estación$p$,283,'sustantivo'),
 ('569f9dc3-f1ce-555a-9a64-7d6e91f763f1','20000000-0000-0000-0000-000000000003',$p$l'aéroport$p$,$p$el aeropuerto$p$,284,'sustantivo'),
 ('1e9be774-1d0c-56bf-b3f5-033bea6e4b26','20000000-0000-0000-0000-000000000003',$p$l'hôtel$p$,$p$el hotel$p$,285,'sustantivo'),
 ('09cf3d40-a841-5fbc-bebc-c487b3730641','20000000-0000-0000-0000-000000000003',$p$le billet$p$,$p$el billete$p$,286,'sustantivo'),
 ('d40ee554-c49c-5e70-b2e0-70634ed327c2','20000000-0000-0000-0000-000000000003',$p$la valise$p$,$p$la maleta$p$,287,'sustantivo'),
 ('d4cdc4ba-f8f5-537c-b1ee-3dfd217990c0','20000000-0000-0000-0000-000000000003',$p$aller$p$,$p$ir$p$,288,'verbo'),
 ('7293fd41-be4c-53a8-a4c0-71f1a94ab4d1','20000000-0000-0000-0000-000000000003',$p$partir$p$,$p$salir/partir$p$,289,'verbo'),
 ('fb15a467-e2db-56bb-aeb7-0c79bee4b015','20000000-0000-0000-0000-000000000003',$p$arriver$p$,$p$llegar$p$,290,'verbo'),
 ('b29df9b9-3810-5a5a-86b5-c78e078cc336','20000000-0000-0000-0000-000000000003',$p$rester$p$,$p$quedarse$p$,291,'verbo'),
 ('4888dbc2-00c1-5c9d-a08c-573375088fdd','20000000-0000-0000-0000-000000000003',$p$venir$p$,$p$venir$p$,292,'verbo'),
 ('c7ab6d65-1333-500e-90ae-3f91f8e768e1','20000000-0000-0000-0000-000000000003',$p$réserver$p$,$p$reservar$p$,293,'verbo'),
 ('c76eb7d3-1baf-586d-a93e-500c1a77e631','20000000-0000-0000-0000-000000000003',$p$en train$p$,$p$en tren$p$,294,'expresion'),
 ('81876b08-ec62-5b62-8060-35d5de9b4fc7','20000000-0000-0000-0000-000000000003',$p$à pied$p$,$p$a pie$p$,295,'expresion'),
 ('63475d8a-3dea-5444-acdb-8d276e08937d','20000000-0000-0000-0000-000000000003',$p$Bon voyage !$p$,$p$¡Buen viaje!$p$,296,'expresion')
on conflict (id) do nothing;

-- ── Unidad 10 (A2·fr): Comer fuera y comprar ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('411b4a96-e792-5193-b98a-8e93d2933b60','20000000-0000-0000-0000-000000000003','A2',10,$p$Comer fuera y comprar$p$,'#E67E22','shopping_cart')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('2efccef7-4ac5-5237-aecd-76010f97266b','411b4a96-e792-5193-b98a-8e93d2933b60',1,$p$Comparar: más, menos, tan$p$,$p$Comparar: más, menos, tan$p$,'lesson',15),
 ('3d2d7d73-6e74-504e-b0ec-92d721067a3d','411b4a96-e792-5193-b98a-8e93d2933b60',2,$p$Cantidades con de$p$,$p$Cantidades con de$p$,'lesson',15),
 ('ea8e38ba-5515-5aa6-aa25-44d2035b6603','411b4a96-e792-5193-b98a-8e93d2933b60',3,$p$El pronombre en$p$,$p$El pronombre en$p$,'lesson',15),
 ('c13d300b-7ad1-5f4a-b8bf-7540aa389846','411b4a96-e792-5193-b98a-8e93d2933b60',4,$p$En el restaurante$p$,$p$En el restaurante$p$,'lesson',15),
 ('6c55daea-f26b-5fb3-95c6-06ba87b8b43b','411b4a96-e792-5193-b98a-8e93d2933b60',5,$p$🏁 Checkpoint Unité 10$p$,$p$Compara productos, pide cantidades y pide en un restaurante usando comparativos y el pronombre en.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('77cc791d-53d0-5835-bce6-fcdd4a2de363','20000000-0000-0000-0000-000000000003','checkpoint','A2','411b4a96-e792-5193-b98a-8e93d2933b60',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('5486bf99-a185-5586-9c60-2aa9f444ba45'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','reading','match',$p$Une la expresión con su significado.$p$,$j${"pairs": [{"en": "l'addition", "es": "la cuenta"}, {"en": "la carte", "es": "la carta"}, {"en": "commander", "es": "pedir"}]}$j$::jsonb,$j${"pairs": [["l'addition", "la cuenta"], ["la carte", "la carta"], ["commander", "pedir"]]}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$restaurant$p$, $p$reading$p$]),
('723f4d40-550c-5ad2-9241-6a0821fdfa33'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','reading','match',$p$Une la cantidad con su traducción.$p$,$j${"pairs": [{"en": "un kilo de", "es": "un kilo de"}, {"en": "une bouteille de", "es": "una botella de"}, {"en": "un peu de", "es": "un poco de"}]}$j$::jsonb,$j${"pairs": [["un kilo de", "un kilo de"], ["une bouteille de", "una botella de"], ["un peu de", "un poco de"]]}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$quantites$p$, $p$reading$p$]),
('a6281f7e-f36c-5cf5-bf1d-4a762372e71a'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','reading','multiple_choice',$p$Elige el comparativo correcto: 'Le TGV est ___ rapide que le bus.'$p$,$j${"options": ["plus", "beaucoup", "trop"]}$j$::jsonb,$j${"value": "plus"}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$comparatif$p$, $p$reading$p$]),
('a7a8a102-6477-563c-8704-036dba82afd5'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','reading','multiple_choice',$p$¿Cómo se dice 'mejor' (adjetivo) en francés? 'Ce restaurant est ___ que l'autre.'$p$,$j${"options": ["meilleur", "plus bon", "plus bien"]}$j$::jsonb,$j${"value": "meilleur"}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$comparatif$p$, $p$reading$p$]),
('1ba9f81b-091b-516b-98f8-c31006c960e2'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','reading','multiple_choice',$p$Elige la forma correcta (cantidad + de).$p$,$j${"options": ["beaucoup de pain", "beaucoup du pain", "beaucoup le pain"]}$j$::jsonb,$j${"value": "beaucoup de pain"}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$quantites$p$, $p$reading$p$]),
('17e39b5b-58b4-50bc-a3d1-f6132127ce7b'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','reading','multiple_choice',$p$Responde con 'en': 'Tu veux du café ? — Oui, ___.'$p$,$j${"options": ["j'en veux", "je veux en", "je le veux"]}$j$::jsonb,$j${"value": "j'en veux"}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$pronom_en$p$, $p$reading$p$]),
('7ff2c510-3e6e-5a25-aebb-9211758ccd44'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','writing','cloze',$p$Completa con el comparativo de igualdad ('tan... como').$p$,$j${"text": "Ce gâteau est ___ bon que l'autre."}$j$::jsonb,$j${"value": "aussi", "accepted": ["aussi"]}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$comparatif$p$, $p$writing$p$]),
('3c6bdc30-a70d-53ca-bb0d-a1683f42925b'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','writing','cloze',$p$Completa con la preposición correcta de cantidad.$p$,$j${"text": "Je voudrais un kilo ___ pommes."}$j$::jsonb,$j${"value": "de", "accepted": ["de"]}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$quantites$p$, $p$writing$p$]),
('c7160ff7-d15a-5704-b0f2-2c5515b70ea6'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','writing','translation',$p$Traduce: 'Quisiera la carta, por favor.'$p$,$j${"source": "Quisiera la carta, por favor."}$j$::jsonb,$j${"value": "Je voudrais la carte, s'il vous plaît.", "accepted": ["Je voudrais la carte, s'il vous plaît.", "Je voudrais la carte s'il vous plaît", "Je voudrais la carte, s'il vous plait", "Je voudrais la carte s'il vous plait"]}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$restaurant$p$, $p$writing$p$]),
('479735f2-ca7d-508f-8d17-3721b875a841'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','writing','translation',$p$Traduce: 'Este vino es menos caro que el otro.'$p$,$j${"source": "Este vino es menos caro que el otro."}$j$::jsonb,$j${"value": "Ce vin est moins cher que l'autre.", "accepted": ["Ce vin est moins cher que l'autre.", "Ce vin est moins cher que l'autre", "Ce vin est moins cher que l'autre."]}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$comparatif$p$, $p$writing$p$]),
('018b750c-042e-5b39-8903-b13f580b8f8c'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','writing','word_bank',$p$Ordena las fichas para formar: 'Sí, quiero dos.' (con 'en')$p$,$j${"tiles": ["Oui,", "j'en", "veux", "deux", "le", "beaucoup"]}$j$::jsonb,$j${"value": "Oui, j'en veux deux", "sequence": ["Oui,", "j'en", "veux", "deux"]}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$pronom_en$p$, $p$writing$p$]),
('7277a7c8-cf89-5454-baad-2211fac20bbe'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','writing','reorder',$p$Ordena las palabras: 'La cuenta, por favor.'$p$,$j${"tiles": ["s'il", "L'addition,", "plaît", "vous"]}$j$::jsonb,$j${"value": "L'addition, s'il vous plaît"}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$restaurant$p$, $p$writing$p$]),
('a6076c14-11c1-5da9-805f-2def31e72380'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ce restaurant est meilleur que l'autre.", "Ce restaurant est moins cher que l'autre.", "Ce restaurant est aussi grand que l'autre."], "say": "Ce restaurant est meilleur que l'autre.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/a6076c14-11c1-5da9-805f-2def31e72380.mp3"}$j$::jsonb,$j${"value": "Ce restaurant est meilleur que l'autre."}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$comparatif$p$, $p$listening$p$]),
('0fb2f8fd-768e-5bcf-a2eb-ccbb913b53f2'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Je voudrais une bouteille de vin rouge.", "Je voudrais un paquet de café noir.", "Je voudrais un peu de pain complet."], "say": "Je voudrais une bouteille de vin rouge.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/0fb2f8fd-768e-5bcf-a2eb-ccbb913b53f2.mp3"}$j$::jsonb,$j${"value": "Je voudrais une bouteille de vin rouge."}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$quantites$p$, $p$listening$p$]),
('2565fdd8-0287-517f-9504-dcad62afe47c'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Des pommes ? Oui, j'en ai deux.", "Du pain ? Non, je n'en ai pas.", "Des œufs ? Oui, j'en veux trois."], "say": "Des pommes ? Oui, j'en ai deux.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/2565fdd8-0287-517f-9504-dcad62afe47c.mp3"}$j$::jsonb,$j${"value": "Des pommes ? Oui, j'en ai deux."}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$pronom_en$p$, $p$listening$p$]),
('d3e53341-9e6b-5ff4-8f8a-d5c40527a3c2'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["L'addition, s'il vous plaît. Ça fait combien ?", "Le menu, s'il vous plaît. Ça coûte combien ?", "La carte, s'il vous plaît. C'est fermé ?"], "say": "L'addition, s'il vous plaît. Ça fait combien ?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/d3e53341-9e6b-5ff4-8f8a-d5c40527a3c2.mp3"}$j$::jsonb,$j${"value": "L'addition, s'il vous plaît. Ça fait combien ?"}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$restaurant$p$, $p$listening$p$]),
('bf598f2f-6ee6-5acd-ba6a-60bd2b07377f'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Je voudrais un kilo de tomates, s'il vous plaît.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/bf598f2f-6ee6-5acd-ba6a-60bd2b07377f.mp3"}$j$::jsonb,$j${"expected": "Je voudrais un kilo de tomates, s'il vous plaît."}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$quantites$p$, $p$speaking$p$]),
('2fba6ea5-893e-59e8-a379-f9699b3f23fe'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Ce plat est meilleur et moins cher.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/2fba6ea5-893e-59e8-a379-f9699b3f23fe.mp3"}$j$::jsonb,$j${"expected": "Ce plat est meilleur et moins cher."}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$comparatif$p$, $p$speaking$p$]),
('3f656a69-54eb-5dbe-b57f-c9b0e7c00e5c'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Bonjour, je voudrais commander, s'il vous plaît.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/3f656a69-54eb-5dbe-b57f-c9b0e7c00e5c.mp3"}$j$::jsonb,$j${"expected": "Bonjour, je voudrais commander, s'il vous plaît."}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$restaurant$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('2efccef7-4ac5-5237-aecd-76010f97266b','a6281f7e-f36c-5cf5-bf1d-4a762372e71a',1),
 ('2efccef7-4ac5-5237-aecd-76010f97266b','a7a8a102-6477-563c-8704-036dba82afd5',2),
 ('2efccef7-4ac5-5237-aecd-76010f97266b','7ff2c510-3e6e-5a25-aebb-9211758ccd44',3),
 ('2efccef7-4ac5-5237-aecd-76010f97266b','479735f2-ca7d-508f-8d17-3721b875a841',4),
 ('2efccef7-4ac5-5237-aecd-76010f97266b','a6076c14-11c1-5da9-805f-2def31e72380',5),
 ('2efccef7-4ac5-5237-aecd-76010f97266b','2fba6ea5-893e-59e8-a379-f9699b3f23fe',6),
 ('3d2d7d73-6e74-504e-b0ec-92d721067a3d','723f4d40-550c-5ad2-9241-6a0821fdfa33',1),
 ('3d2d7d73-6e74-504e-b0ec-92d721067a3d','1ba9f81b-091b-516b-98f8-c31006c960e2',2),
 ('3d2d7d73-6e74-504e-b0ec-92d721067a3d','3c6bdc30-a70d-53ca-bb0d-a1683f42925b',3),
 ('3d2d7d73-6e74-504e-b0ec-92d721067a3d','0fb2f8fd-768e-5bcf-a2eb-ccbb913b53f2',4),
 ('3d2d7d73-6e74-504e-b0ec-92d721067a3d','bf598f2f-6ee6-5acd-ba6a-60bd2b07377f',5),
 ('ea8e38ba-5515-5aa6-aa25-44d2035b6603','17e39b5b-58b4-50bc-a3d1-f6132127ce7b',1),
 ('ea8e38ba-5515-5aa6-aa25-44d2035b6603','018b750c-042e-5b39-8903-b13f580b8f8c',2),
 ('ea8e38ba-5515-5aa6-aa25-44d2035b6603','2565fdd8-0287-517f-9504-dcad62afe47c',3),
 ('c13d300b-7ad1-5f4a-b8bf-7540aa389846','5486bf99-a185-5586-9c60-2aa9f444ba45',1),
 ('c13d300b-7ad1-5f4a-b8bf-7540aa389846','c7160ff7-d15a-5704-b0f2-2c5515b70ea6',2),
 ('c13d300b-7ad1-5f4a-b8bf-7540aa389846','7277a7c8-cf89-5454-baad-2211fac20bbe',3),
 ('c13d300b-7ad1-5f4a-b8bf-7540aa389846','d3e53341-9e6b-5ff4-8f8a-d5c40527a3c2',4),
 ('c13d300b-7ad1-5f4a-b8bf-7540aa389846','3f656a69-54eb-5dbe-b57f-c9b0e7c00e5c',5),
 ('6c55daea-f26b-5fb3-95c6-06ba87b8b43b','5486bf99-a185-5586-9c60-2aa9f444ba45',1),
 ('6c55daea-f26b-5fb3-95c6-06ba87b8b43b','723f4d40-550c-5ad2-9241-6a0821fdfa33',2),
 ('6c55daea-f26b-5fb3-95c6-06ba87b8b43b','a6281f7e-f36c-5cf5-bf1d-4a762372e71a',3),
 ('6c55daea-f26b-5fb3-95c6-06ba87b8b43b','7ff2c510-3e6e-5a25-aebb-9211758ccd44',4),
 ('6c55daea-f26b-5fb3-95c6-06ba87b8b43b','3c6bdc30-a70d-53ca-bb0d-a1683f42925b',5),
 ('6c55daea-f26b-5fb3-95c6-06ba87b8b43b','c7160ff7-d15a-5704-b0f2-2c5515b70ea6',6),
 ('6c55daea-f26b-5fb3-95c6-06ba87b8b43b','a6076c14-11c1-5da9-805f-2def31e72380',7),
 ('6c55daea-f26b-5fb3-95c6-06ba87b8b43b','0fb2f8fd-768e-5bcf-a2eb-ccbb913b53f2',8),
 ('6c55daea-f26b-5fb3-95c6-06ba87b8b43b','bf598f2f-6ee6-5acd-ba6a-60bd2b07377f',9),
 ('6c55daea-f26b-5fb3-95c6-06ba87b8b43b','2fba6ea5-893e-59e8-a379-f9699b3f23fe',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('7514fd56-cc7f-5781-9dd3-4177497a3ee8','20000000-0000-0000-0000-000000000003',$p$le menu$p$,$p$el menú$p$,301,'sustantivo'),
 ('fbcaf905-2757-5ca9-a30e-782fe7534e04','20000000-0000-0000-0000-000000000003',$p$la carte$p$,$p$la carta$p$,302,'sustantivo'),
 ('1b968963-835b-5172-a6c1-cc2ce3121e5b','20000000-0000-0000-0000-000000000003',$p$l'addition$p$,$p$la cuenta$p$,303,'sustantivo'),
 ('cbce2a10-d94d-5500-9fd3-d87211ca43b9','20000000-0000-0000-0000-000000000003',$p$un kilo de$p$,$p$un kilo de$p$,304,'expresion'),
 ('af25822b-45bf-547a-9a96-833120f50495','20000000-0000-0000-0000-000000000003',$p$une bouteille de$p$,$p$una botella de$p$,305,'expresion'),
 ('898747e8-1f61-5cd2-bf57-1200894becbb','20000000-0000-0000-0000-000000000003',$p$un paquet de$p$,$p$un paquete de$p$,306,'expresion'),
 ('1bd54444-7b58-5e8b-9eda-649def523e22','20000000-0000-0000-0000-000000000003',$p$beaucoup de$p$,$p$mucho/a$p$,307,'expresion'),
 ('db45c361-1bf9-53bd-9def-15cd5dc0276a','20000000-0000-0000-0000-000000000003',$p$un peu de$p$,$p$un poco de$p$,308,'expresion'),
 ('5cf2a5f6-bdcc-559f-b24b-dc13cf1093f8','20000000-0000-0000-0000-000000000003',$p$trop de$p$,$p$demasiado de$p$,309,'expresion'),
 ('709993a8-9840-58ce-9007-4c6b6d1995e4','20000000-0000-0000-0000-000000000003',$p$commander$p$,$p$pedir/encargar$p$,310,'verbo'),
 ('ea22db13-bea9-5ad5-8c72-9c3f1bcd9275','20000000-0000-0000-0000-000000000003',$p$meilleur$p$,$p$mejor$p$,311,'adjetivo'),
 ('016d52b4-5455-5608-9f34-e1dc08b2915d','20000000-0000-0000-0000-000000000003',$p$cher$p$,$p$caro$p$,312,'adjetivo'),
 ('d4523c50-45ab-5259-911b-890253fca359','20000000-0000-0000-0000-000000000003',$p$Je voudrais$p$,$p$quisiera$p$,313,'expresion'),
 ('3fd850ca-7934-51a0-8b9b-a333ce334d28','20000000-0000-0000-0000-000000000003',$p$Ça fait combien ?$p$,$p$¿cuánto es?$p$,314,'expresion'),
 ('5bcdd28c-fa6d-57e9-921d-cad4f02bff4a','20000000-0000-0000-0000-000000000003',$p$plus$p$,$p$más$p$,315,'adverbio'),
 ('8d44f292-e9f4-59a8-bba3-b027c40918f7','20000000-0000-0000-0000-000000000003',$p$moins$p$,$p$menos$p$,316,'adverbio')
on conflict (id) do nothing;

-- ── Unidad 11 (A2·fr): Personas y descripciones ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('62cd0bef-29ca-5d41-91cc-e06128804f8c','20000000-0000-0000-0000-000000000003','A2',11,$p$Personas y descripciones$p$,'#8E44AD','people')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('b74a0303-5700-57f6-8046-26a1727b73ec','62cd0bef-29ca-5d41-91cc-e06128804f8c',1,$p$El imparfait: describir el pasado$p$,$p$El imparfait: describir el pasado$p$,'lesson',15),
 ('f5f02c41-4c90-532a-99ff-1c20844dc615','62cd0bef-29ca-5d41-91cc-e06128804f8c',2,$p$Descripción física$p$,$p$Descripción física$p$,'lesson',15),
 ('c3f8c797-c417-55d4-b2ca-7493643e2224','62cd0bef-29ca-5d41-91cc-e06128804f8c',3,$p$El carácter y los adjetivos$p$,$p$El carácter y los adjetivos$p$,'lesson',15),
 ('ecc10011-4f8e-59a2-9633-34637790ef57','62cd0bef-29ca-5d41-91cc-e06128804f8c',4,$p$Los pronombres COD (le, la, les)$p$,$p$Los pronombres COD (le, la, les)$p$,'lesson',15),
 ('d256369e-bb2a-5e91-a2d0-541b421b4e3f','62cd0bef-29ca-5d41-91cc-e06128804f8c',5,$p$🏁 Checkpoint Unité 11$p$,$p$Describe a las personas en pasado con el imparfait y usa los pronombres COD (le, la, les).$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('f4eb8578-345c-54db-9096-75903dd47dd5','20000000-0000-0000-0000-000000000003','checkpoint','A2','62cd0bef-29ca-5d41-91cc-e06128804f8c',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('a2fffe7b-8e0d-5340-b9e1-a46ffb387190'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','reading','match',$p$Une les frases en imparfait con su traducción.$p$,$j${"pairs": [{"en": "Quand j'étais petit", "es": "Cuando era pequeño"}, {"en": "Il y avait un jardin", "es": "Había un jardín"}, {"en": "Il faisait beau", "es": "Hacía buen tiempo"}]}$j$::jsonb,$j${"pairs": [["Quand j'étais petit", "Cuando era pequeño"], ["Il y avait un jardin", "Había un jardín"], ["Il faisait beau", "Hacía buen tiempo"]]}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$imparfait_intro$p$, $p$reading$p$]),
('9c548d0f-859e-5ef1-bd61-22e6124f8e48'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','reading','match',$p$Une la descripción física con su traducción.$p$,$j${"pairs": [{"en": "les cheveux longs", "es": "el pelo largo"}, {"en": "les yeux bleus", "es": "los ojos azules"}, {"en": "un grand homme", "es": "un hombre alto"}]}$j$::jsonb,$j${"pairs": [["les cheveux longs", "el pelo largo"], ["les yeux bleus", "los ojos azules"], ["un grand homme", "un hombre alto"]]}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$description_physique$p$, $p$reading$p$]),
('abffeeb6-87e9-594f-9c0d-e523e6670b33'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','reading','multiple_choice',$p$Completa: 'Quand j'___ petit, j'habitais à la campagne.'$p$,$j${"options": ["étais", "suis", "ai été"]}$j$::jsonb,$j${"value": "étais"}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$imparfait_intro$p$, $p$reading$p$]),
('19828b9f-4058-5487-a7db-d86233babd0a'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','reading','multiple_choice',$p$¿Cuál describe a alguien que habla poco y se pone nervioso con gente nueva?$p$,$j${"options": ["timide", "drôle", "sérieux"]}$j$::jsonb,$j${"value": "timide"}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$caractere$p$, $p$reading$p$]),
('e7c043f5-30e5-547a-8554-81d1983954a4'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','reading','multiple_choice',$p$Elige la frase correcta ('bonita casa'):$p$,$j${"options": ["une belle maison", "une maison belle", "un beau maison"]}$j$::jsonb,$j${"value": "une belle maison"}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$adjectif_position$p$, $p$reading$p$]),
('35dc6b7c-5dd5-57a8-8b3d-e2c2b3e4365a'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','reading','multiple_choice',$p$'Tu vois Marie ?' — Responde con el pronombre COD correcto:$p$,$j${"options": ["Oui, je la vois.", "Oui, je lui vois.", "Oui, je le vois."]}$j$::jsonb,$j${"value": "Oui, je la vois."}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$pronom_cod$p$, $p$reading$p$]),
('88c98ec4-d84b-5773-ab6b-fda76ad8526e'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','writing','cloze',$p$Imparfait de 'habiter' (je). Completa el hueco.$p$,$j${"text": "Quand j'étais petit, j'___ à la campagne."}$j$::jsonb,$j${"value": "habitais", "accepted": ["habitais"]}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$imparfait_intro$p$, $p$writing$p$]),
('41e64ebb-cafe-5693-a51e-c21aacc81d6d'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','writing','cloze',$p$Imparfait de 'avoir' (elle). Completa el hueco.$p$,$j${"text": "Elle ___ les cheveux longs."}$j$::jsonb,$j${"value": "avait", "accepted": ["avait"]}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$imparfait_avoir$p$, $p$writing$p$]),
('eb412c9d-f792-547e-ab18-4499c12e82ba'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','writing','translation',$p$Traduce: 'Ella es alta y tiene los ojos verdes.'$p$,$j${"source": "Ella es alta y tiene los ojos verdes."}$j$::jsonb,$j${"value": "Elle est grande et elle a les yeux verts.", "accepted": ["Elle est grande et elle a les yeux verts.", "Elle est grande et elle a les yeux verts", "Elle est grande et a les yeux verts.", "Elle est grande et a les yeux verts", "Elle est grande et elle a les yeux verts .", "elle est grande et elle a les yeux verts"]}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$description_physique$p$, $p$writing$p$]),
('ad281768-0733-5b93-b301-9e5f521b61a8'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','writing','translation',$p$Traduce: 'Lo conozco bien.' (a él)$p$,$j${"source": "Lo conozco bien."}$j$::jsonb,$j${"value": "Je le connais bien.", "accepted": ["Je le connais bien.", "Je le connais bien", "je le connais bien", "Je le connais bien ."]}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$pronom_cod$p$, $p$writing$p$]),
('d0e81f48-5368-5d7b-9728-8bd1323d5c2c'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','writing','word_bank',$p$Ordena: 'Mi vecino era muy amable.'$p$,$j${"tiles": ["Mon", "voisin", "était", "très", "gentil", "sympa", "avait"]}$j$::jsonb,$j${"value": "Mon voisin était très gentil", "sequence": ["Mon", "voisin", "était", "très", "gentil"]}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$caractere$p$, $p$writing$p$]),
('115e763e-dd6a-5f87-9e8d-7b39f35d63fb'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','writing','reorder',$p$Ordena la frase: 'Je les connais.'$p$,$j${"tiles": ["connais", "Je", "les"]}$j$::jsonb,$j${"value": "Je les connais"}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$pronom_cod$p$, $p$writing$p$]),
('68ed09b5-9c1a-590b-aa07-892eafe1c804'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Quand j'étais petit, il y avait un grand jardin.", "Quand je suis petit, il y a un grand jardin.", "Quand j'étais petit, il y avait un petit jardin."], "say": "Quand j'étais petit, il y avait un grand jardin.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/68ed09b5-9c1a-590b-aa07-892eafe1c804.mp3"}$j$::jsonb,$j${"value": "Quand j'étais petit, il y avait un grand jardin."}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$imparfait_intro$p$, $p$listening$p$]),
('07540042-9298-5481-80f5-be2d915fc607'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Elle avait les cheveux blonds et les yeux bleus.", "Elle avait les cheveux bruns et les yeux bleus.", "Il avait les cheveux blonds et les yeux verts."], "say": "Elle avait les cheveux blonds et les yeux bleus.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/07540042-9298-5481-80f5-be2d915fc607.mp3"}$j$::jsonb,$j${"value": "Elle avait les cheveux blonds et les yeux bleus."}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$description_physique$p$, $p$listening$p$]),
('50609dd4-cf26-5da6-a238-0f003e034962'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Tu vois ce film ? Oui, je le regarde ce soir.", "Tu vois ce film ? Oui, je la regarde ce soir.", "Tu vois ce film ? Non, je le regarde demain."], "say": "Tu vois ce film ? Oui, je le regarde ce soir.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/50609dd4-cf26-5da6-a238-0f003e034962.mp3"}$j$::jsonb,$j${"value": "Tu vois ce film ? Oui, je le regarde ce soir."}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$pronom_cod$p$, $p$listening$p$]),
('ca1633d0-b65c-51b3-8328-bda4ea39542a'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Mon frère est drôle et très sympa.", "Mon frère est sérieux et très timide.", "Ma sœur est drôle et très sympa."], "say": "Mon frère est drôle et très sympa.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/ca1633d0-b65c-51b3-8328-bda4ea39542a.mp3"}$j$::jsonb,$j${"value": "Mon frère est drôle et très sympa."}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$caractere$p$, $p$listening$p$]),
('9c5e1120-11c9-52ec-8a4c-cf525d79ebf4'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Il est grand et il a les cheveux bruns.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/9c5e1120-11c9-52ec-8a4c-cf525d79ebf4.mp3"}$j$::jsonb,$j${"expected": "Il est grand et il a les cheveux bruns."}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$description_physique$p$, $p$speaking$p$]),
('b2fdde7e-369c-5f1c-a47a-c6d7d25e0a3e'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Quand j'étais petit, il faisait beau.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/b2fdde7e-369c-5f1c-a47a-c6d7d25e0a3e.mp3"}$j$::jsonb,$j${"expected": "Quand j'étais petit, il faisait beau."}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$imparfait_intro$p$, $p$speaking$p$]),
('2e296791-8387-5fa9-a899-b316f7014a4e'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Tu connais Marie ? Oui, je la connais.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/2e296791-8387-5fa9-a899-b316f7014a4e.mp3"}$j$::jsonb,$j${"expected": "Tu connais Marie ? Oui, je la connais."}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$pronom_cod$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('b74a0303-5700-57f6-8046-26a1727b73ec','a2fffe7b-8e0d-5340-b9e1-a46ffb387190',1),
 ('b74a0303-5700-57f6-8046-26a1727b73ec','abffeeb6-87e9-594f-9c0d-e523e6670b33',2),
 ('b74a0303-5700-57f6-8046-26a1727b73ec','88c98ec4-d84b-5773-ab6b-fda76ad8526e',3),
 ('b74a0303-5700-57f6-8046-26a1727b73ec','41e64ebb-cafe-5693-a51e-c21aacc81d6d',4),
 ('b74a0303-5700-57f6-8046-26a1727b73ec','68ed09b5-9c1a-590b-aa07-892eafe1c804',5),
 ('b74a0303-5700-57f6-8046-26a1727b73ec','b2fdde7e-369c-5f1c-a47a-c6d7d25e0a3e',6),
 ('f5f02c41-4c90-532a-99ff-1c20844dc615','9c548d0f-859e-5ef1-bd61-22e6124f8e48',1),
 ('f5f02c41-4c90-532a-99ff-1c20844dc615','eb412c9d-f792-547e-ab18-4499c12e82ba',2),
 ('f5f02c41-4c90-532a-99ff-1c20844dc615','07540042-9298-5481-80f5-be2d915fc607',3),
 ('f5f02c41-4c90-532a-99ff-1c20844dc615','9c5e1120-11c9-52ec-8a4c-cf525d79ebf4',4),
 ('c3f8c797-c417-55d4-b2ca-7493643e2224','19828b9f-4058-5487-a7db-d86233babd0a',1),
 ('c3f8c797-c417-55d4-b2ca-7493643e2224','e7c043f5-30e5-547a-8554-81d1983954a4',2),
 ('c3f8c797-c417-55d4-b2ca-7493643e2224','d0e81f48-5368-5d7b-9728-8bd1323d5c2c',3),
 ('c3f8c797-c417-55d4-b2ca-7493643e2224','ca1633d0-b65c-51b3-8328-bda4ea39542a',4),
 ('ecc10011-4f8e-59a2-9633-34637790ef57','35dc6b7c-5dd5-57a8-8b3d-e2c2b3e4365a',1),
 ('ecc10011-4f8e-59a2-9633-34637790ef57','ad281768-0733-5b93-b301-9e5f521b61a8',2),
 ('ecc10011-4f8e-59a2-9633-34637790ef57','115e763e-dd6a-5f87-9e8d-7b39f35d63fb',3),
 ('ecc10011-4f8e-59a2-9633-34637790ef57','50609dd4-cf26-5da6-a238-0f003e034962',4),
 ('ecc10011-4f8e-59a2-9633-34637790ef57','2e296791-8387-5fa9-a899-b316f7014a4e',5),
 ('d256369e-bb2a-5e91-a2d0-541b421b4e3f','a2fffe7b-8e0d-5340-b9e1-a46ffb387190',1),
 ('d256369e-bb2a-5e91-a2d0-541b421b4e3f','9c548d0f-859e-5ef1-bd61-22e6124f8e48',2),
 ('d256369e-bb2a-5e91-a2d0-541b421b4e3f','abffeeb6-87e9-594f-9c0d-e523e6670b33',3),
 ('d256369e-bb2a-5e91-a2d0-541b421b4e3f','88c98ec4-d84b-5773-ab6b-fda76ad8526e',4),
 ('d256369e-bb2a-5e91-a2d0-541b421b4e3f','41e64ebb-cafe-5693-a51e-c21aacc81d6d',5),
 ('d256369e-bb2a-5e91-a2d0-541b421b4e3f','eb412c9d-f792-547e-ab18-4499c12e82ba',6),
 ('d256369e-bb2a-5e91-a2d0-541b421b4e3f','68ed09b5-9c1a-590b-aa07-892eafe1c804',7),
 ('d256369e-bb2a-5e91-a2d0-541b421b4e3f','07540042-9298-5481-80f5-be2d915fc607',8),
 ('d256369e-bb2a-5e91-a2d0-541b421b4e3f','9c5e1120-11c9-52ec-8a4c-cf525d79ebf4',9),
 ('d256369e-bb2a-5e91-a2d0-541b421b4e3f','b2fdde7e-369c-5f1c-a47a-c6d7d25e0a3e',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('2db8aae7-76ad-548b-9d8e-d085ac2f4a72','20000000-0000-0000-0000-000000000003',$p$les cheveux$p$,$p$el pelo$p$,321,'sustantivo'),
 ('074ae7fc-004b-511c-8d8a-4f75097d0b67','20000000-0000-0000-0000-000000000003',$p$les yeux$p$,$p$los ojos$p$,322,'sustantivo'),
 ('434425be-a255-5f3e-8766-071b31a0d2e7','20000000-0000-0000-0000-000000000003',$p$grand$p$,$p$alto / grande$p$,323,'adjetivo'),
 ('9dbf0244-f8b9-5588-bbc0-d0e2d9540b11','20000000-0000-0000-0000-000000000003',$p$petit$p$,$p$bajo / pequeño$p$,324,'adjetivo'),
 ('cd7877a2-58cc-5f4c-a219-838d1ab63ec4','20000000-0000-0000-0000-000000000003',$p$blond$p$,$p$rubio$p$,325,'adjetivo'),
 ('970513e9-21b6-5a92-a12c-dbaef90cdfa5','20000000-0000-0000-0000-000000000003',$p$brun$p$,$p$moreno / castaño$p$,326,'adjetivo'),
 ('3af3c2e7-6171-5f15-9955-f65eac2fa2d7','20000000-0000-0000-0000-000000000003',$p$gentil$p$,$p$amable$p$,327,'adjetivo'),
 ('d8f22929-0b56-5e60-b6aa-2e2373b994d8','20000000-0000-0000-0000-000000000003',$p$timide$p$,$p$tímido$p$,328,'adjetivo'),
 ('f92de3b7-53fa-5b4a-8793-bd080ed10644','20000000-0000-0000-0000-000000000003',$p$sympa$p$,$p$simpático$p$,329,'adjetivo'),
 ('f16c706a-7647-5e69-a57d-6a5ed788d74f','20000000-0000-0000-0000-000000000003',$p$drôle$p$,$p$gracioso$p$,330,'adjetivo'),
 ('83efb99f-e5f2-5c68-9ddb-779cf14f3bd1','20000000-0000-0000-0000-000000000003',$p$sérieux$p$,$p$serio$p$,331,'adjetivo'),
 ('20b90fe2-4156-53b7-8673-500773222e40','20000000-0000-0000-0000-000000000003',$p$beau$p$,$p$guapo / bonito$p$,332,'adjetivo'),
 ('cb52e674-c958-5775-9d7f-f068536e4467','20000000-0000-0000-0000-000000000003',$p$quand j'étais petit$p$,$p$cuando era pequeño$p$,333,'expresion'),
 ('9327878b-0423-572f-b424-623d90acfc08','20000000-0000-0000-0000-000000000003',$p$il y avait$p$,$p$había$p$,334,'expresion'),
 ('47f515b7-9aae-58c6-934f-9b0cacdfceca','20000000-0000-0000-0000-000000000003',$p$connaître$p$,$p$conocer$p$,335,'verbo'),
 ('981e61fb-9c1b-5b8e-9e63-f3b610d3ba92','20000000-0000-0000-0000-000000000003',$p$le voisin$p$,$p$el vecino$p$,336,'sustantivo')
on conflict (id) do nothing;

-- ── Unidad 12 (A2·fr): Salud, cuerpo y consejos ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('61d5f001-9692-5466-8a43-104c0401004b','20000000-0000-0000-0000-000000000003','A2',12,$p$Salud, cuerpo y consejos$p$,'#D35400','healing')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('cc5378de-9054-5b2a-a32f-0ba19ac40fc3','61d5f001-9692-5466-8a43-104c0401004b',1,$p$El cuerpo$p$,$p$El cuerpo$p$,'lesson',15),
 ('30d2fafa-807a-5760-ab67-67659e2495a1','61d5f001-9692-5466-8a43-104c0401004b',2,$p$Avoir mal à$p$,$p$Avoir mal à$p$,'lesson',15),
 ('28485300-a7a7-5d89-a0b5-2cb8904f9e8e','61d5f001-9692-5466-8a43-104c0401004b',3,$p$En el médico$p$,$p$En el médico$p$,'lesson',15),
 ('d10d1016-66b6-5876-bf65-bfb4d6fc4441','61d5f001-9692-5466-8a43-104c0401004b',4,$p$Dar consejos$p$,$p$Dar consejos$p$,'lesson',15),
 ('ed4948f3-cd88-51eb-bf4c-7208b607010f','61d5f001-9692-5466-8a43-104c0401004b',5,$p$🏁 Checkpoint Unité 12$p$,$p$Habla de tu salud con 'avoir mal à' y da consejos con 'il faut' y 'tu devrais'.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('570eff23-8225-5bb4-bf10-c81e8bb454c7','20000000-0000-0000-0000-000000000003','checkpoint','A2','61d5f001-9692-5466-8a43-104c0401004b',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('f4977162-dbf9-515a-a017-4454b4f9ac16'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','reading','match',$p$Une la parte del cuerpo con su traducción.$p$,$j${"pairs": [{"en": "la tête", "es": "la cabeza"}, {"en": "le dos", "es": "la espalda"}, {"en": "la gorge", "es": "la garganta"}]}$j$::jsonb,$j${"pairs": [["la tête", "la cabeza"], ["le dos", "la espalda"], ["la gorge", "la garganta"]]}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$le_corps$p$, $p$reading$p$]),
('a7d1990c-7d8c-5bd4-bdea-6abc27d7a84b'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','reading','match',$p$Une la frase del médico con su traducción.$p$,$j${"pairs": [{"en": "Je suis malade", "es": "Estoy enfermo"}, {"en": "J'ai de la fièvre", "es": "Tengo fiebre"}, {"en": "Qu'est-ce qui ne va pas ?", "es": "¿Qué le pasa?"}]}$j$::jsonb,$j${"pairs": [["Je suis malade", "Estoy enfermo"], ["J'ai de la fièvre", "Tengo fiebre"], ["Qu'est-ce qui ne va pas ?", "¿Qué le pasa?"]]}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$chez_le_medecin$p$, $p$reading$p$]),
('adc69db3-4712-56b6-bbc8-7501563ea657'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','reading','multiple_choice',$p$Completa: 'J'ai mal ___ tête.'$p$,$j${"options": ["à la", "au", "à l'"]}$j$::jsonb,$j${"value": "à la"}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$avoir_mal_a$p$, $p$reading$p$]),
('6bcd76c0-537c-508c-9ac1-4ad3b5e5d8d5'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','reading','multiple_choice',$p$Completa: 'Il a mal ___ dos.' (le dos)$p$,$j${"options": ["au", "à la", "aux"]}$j$::jsonb,$j${"value": "au"}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$avoir_mal_a$p$, $p$reading$p$]),
('dc35d097-5df8-5818-9823-266ad611cd69'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','reading','multiple_choice',$p$Completa: 'Elle a mal ___ dents.' (les dents)$p$,$j${"options": ["aux", "au", "à la"]}$j$::jsonb,$j${"value": "aux"}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$avoir_mal_a$p$, $p$reading$p$]),
('985134ae-52fe-5789-a1a1-394761b25af8'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','reading','multiple_choice',$p$Elige el consejo correcto: 'Deberías dormir.'$p$,$j${"options": ["Tu devrais dormir.", "Tu devrais dors.", "Tu dois dormir hier."]}$j$::jsonb,$j${"value": "Tu devrais dormir."}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$conseils$p$, $p$reading$p$]),
('8eeb9120-82c3-5c89-9db6-b738ed67fd3e'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','writing','cloze',$p$Contracción à + le = au. Completa (le ventre).$p$,$j${"text": "J'ai mal ___ ventre depuis hier."}$j$::jsonb,$j${"value": "au", "accepted": ["au"]}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$avoir_mal_a$p$, $p$writing$p$]),
('5cc20b3e-81e3-5d3a-8e41-250096df078b'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','writing','cloze',$p$Consejo con 'il faut' + infinitivo. Completa el hueco.$p$,$j${"text": "Tu es fatigué ? Il faut te ___."}$j$::jsonb,$j${"value": "reposer", "accepted": ["reposer"]}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$conseils$p$, $p$writing$p$]),
('09f536e1-d1b2-5e9c-ae4d-02e692ecff43'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','writing','translation',$p$Traduce: 'Me duele la garganta.'$p$,$j${"source": "Me duele la garganta."}$j$::jsonb,$j${"value": "J'ai mal à la gorge.", "accepted": ["J'ai mal à la gorge.", "J'ai mal à la gorge", "j'ai mal à la gorge", "J'ai mal a la gorge.", "J'ai mal a la gorge", "J'ai mal à la gorge ."]}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$avoir_mal_a$p$, $p$writing$p$]),
('679c1ffc-4691-54b0-80e6-8997c5a970b0'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','writing','translation',$p$Traduce: 'Deberías descansar.'$p$,$j${"source": "Deberías descansar."}$j$::jsonb,$j${"value": "Tu devrais te reposer.", "accepted": ["Tu devrais te reposer.", "Tu devrais te reposer", "tu devrais te reposer", "Tu devrais te reposer ."]}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$conseils$p$, $p$writing$p$]),
('1d760359-bd24-5dde-8a92-30f8c16c3e1d'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','writing','word_bank',$p$Ordena: 'Estoy enfermo y tengo fiebre.'$p$,$j${"tiles": ["Je", "suis", "malade", "et", "j'ai", "de la", "fièvre", "mal"]}$j$::jsonb,$j${"value": "Je suis malade et j'ai de la fièvre", "sequence": ["Je", "suis", "malade", "et", "j'ai", "de la", "fièvre"]}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$chez_le_medecin$p$, $p$writing$p$]),
('0e832f50-4cc8-5210-8f3b-22153cc024a8'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','writing','reorder',$p$Ordena la frase: 'Tu as déjà vu le médecin ?'$p$,$j${"tiles": ["vu", "Tu", "déjà", "le médecin", "as"]}$j$::jsonb,$j${"value": "Tu as déjà vu le médecin"}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$passe_compose_deja$p$, $p$writing$p$]),
('b458a027-af17-5136-94e5-82f57fe2428e'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["J'ai mal au ventre depuis ce matin.", "J'ai mal à la tête depuis ce matin.", "J'ai mal au dos depuis hier."], "say": "J'ai mal au ventre depuis ce matin.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/b458a027-af17-5136-94e5-82f57fe2428e.mp3"}$j$::jsonb,$j${"value": "J'ai mal au ventre depuis ce matin."}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$avoir_mal_a$p$, $p$listening$p$]),
('9650f312-a96f-5205-8855-1d2d5049a5c0'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Qu'est-ce qui ne va pas ? Je suis malade.", "Qu'est-ce qui ne va pas ? Je suis fatigué.", "Qu'est-ce que tu fais ? Je suis malade."], "say": "Qu'est-ce qui ne va pas ? Je suis malade.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/9650f312-a96f-5205-8855-1d2d5049a5c0.mp3"}$j$::jsonb,$j${"value": "Qu'est-ce qui ne va pas ? Je suis malade."}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$chez_le_medecin$p$, $p$listening$p$]),
('daf6e9f5-b3d6-567c-91bd-f2c51d93d665'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Tu devrais dormir et boire de l'eau.", "Tu dois dormir et boire du café.", "Il faut dormir et boire de l'eau."], "say": "Tu devrais dormir et boire de l'eau.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/daf6e9f5-b3d6-567c-91bd-f2c51d93d665.mp3"}$j$::jsonb,$j${"value": "Tu devrais dormir et boire de l'eau."}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$conseils$p$, $p$listening$p$]),
('a427ebf6-cf00-5da6-8d4b-b9875e529e57'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Tu as déjà vu le médecin ? Non, pas encore.", "Tu as déjà vu le médecin ? Oui, hier.", "Tu as déjà vu le dentiste ? Non, pas encore."], "say": "Tu as déjà vu le médecin ? Non, pas encore.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/a427ebf6-cf00-5da6-8d4b-b9875e529e57.mp3"}$j$::jsonb,$j${"value": "Tu as déjà vu le médecin ? Non, pas encore."}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$passe_compose_deja$p$, $p$listening$p$]),
('731ecec5-951b-5ce5-9daf-85d7f6e7ad9c'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "J'ai mal à la tête et à la gorge.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/731ecec5-951b-5ce5-9daf-85d7f6e7ad9c.mp3"}$j$::jsonb,$j${"expected": "J'ai mal à la tête et à la gorge."}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$avoir_mal_a$p$, $p$speaking$p$]),
('8428fe94-42ab-5f5b-9444-ac541bb4d51a'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Il faut te reposer et boire de l'eau.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/8428fe94-42ab-5f5b-9444-ac541bb4d51a.mp3"}$j$::jsonb,$j${"expected": "Il faut te reposer et boire de l'eau."}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$conseils$p$, $p$speaking$p$]),
('73badef3-0ff9-5974-ac2f-e09a3016772e'::uuid,'20000000-0000-0000-0000-000000000003'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Je suis malade, j'ai de la fièvre depuis hier.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/73badef3-0ff9-5974-ac2f-e09a3016772e.mp3"}$j$::jsonb,$j${"expected": "Je suis malade, j'ai de la fièvre depuis hier."}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$chez_le_medecin$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('cc5378de-9054-5b2a-a32f-0ba19ac40fc3','f4977162-dbf9-515a-a017-4454b4f9ac16',1),
 ('30d2fafa-807a-5760-ab67-67659e2495a1','adc69db3-4712-56b6-bbc8-7501563ea657',1),
 ('30d2fafa-807a-5760-ab67-67659e2495a1','6bcd76c0-537c-508c-9ac1-4ad3b5e5d8d5',2),
 ('30d2fafa-807a-5760-ab67-67659e2495a1','dc35d097-5df8-5818-9823-266ad611cd69',3),
 ('30d2fafa-807a-5760-ab67-67659e2495a1','8eeb9120-82c3-5c89-9db6-b738ed67fd3e',4),
 ('30d2fafa-807a-5760-ab67-67659e2495a1','09f536e1-d1b2-5e9c-ae4d-02e692ecff43',5),
 ('30d2fafa-807a-5760-ab67-67659e2495a1','b458a027-af17-5136-94e5-82f57fe2428e',6),
 ('30d2fafa-807a-5760-ab67-67659e2495a1','731ecec5-951b-5ce5-9daf-85d7f6e7ad9c',7),
 ('28485300-a7a7-5d89-a0b5-2cb8904f9e8e','a7d1990c-7d8c-5bd4-bdea-6abc27d7a84b',1),
 ('28485300-a7a7-5d89-a0b5-2cb8904f9e8e','1d760359-bd24-5dde-8a92-30f8c16c3e1d',2),
 ('28485300-a7a7-5d89-a0b5-2cb8904f9e8e','0e832f50-4cc8-5210-8f3b-22153cc024a8',3),
 ('28485300-a7a7-5d89-a0b5-2cb8904f9e8e','9650f312-a96f-5205-8855-1d2d5049a5c0',4),
 ('28485300-a7a7-5d89-a0b5-2cb8904f9e8e','a427ebf6-cf00-5da6-8d4b-b9875e529e57',5),
 ('28485300-a7a7-5d89-a0b5-2cb8904f9e8e','73badef3-0ff9-5974-ac2f-e09a3016772e',6),
 ('d10d1016-66b6-5876-bf65-bfb4d6fc4441','985134ae-52fe-5789-a1a1-394761b25af8',1),
 ('d10d1016-66b6-5876-bf65-bfb4d6fc4441','5cc20b3e-81e3-5d3a-8e41-250096df078b',2),
 ('d10d1016-66b6-5876-bf65-bfb4d6fc4441','679c1ffc-4691-54b0-80e6-8997c5a970b0',3),
 ('d10d1016-66b6-5876-bf65-bfb4d6fc4441','daf6e9f5-b3d6-567c-91bd-f2c51d93d665',4),
 ('d10d1016-66b6-5876-bf65-bfb4d6fc4441','8428fe94-42ab-5f5b-9444-ac541bb4d51a',5),
 ('ed4948f3-cd88-51eb-bf4c-7208b607010f','f4977162-dbf9-515a-a017-4454b4f9ac16',1),
 ('ed4948f3-cd88-51eb-bf4c-7208b607010f','a7d1990c-7d8c-5bd4-bdea-6abc27d7a84b',2),
 ('ed4948f3-cd88-51eb-bf4c-7208b607010f','adc69db3-4712-56b6-bbc8-7501563ea657',3),
 ('ed4948f3-cd88-51eb-bf4c-7208b607010f','8eeb9120-82c3-5c89-9db6-b738ed67fd3e',4),
 ('ed4948f3-cd88-51eb-bf4c-7208b607010f','5cc20b3e-81e3-5d3a-8e41-250096df078b',5),
 ('ed4948f3-cd88-51eb-bf4c-7208b607010f','09f536e1-d1b2-5e9c-ae4d-02e692ecff43',6),
 ('ed4948f3-cd88-51eb-bf4c-7208b607010f','b458a027-af17-5136-94e5-82f57fe2428e',7),
 ('ed4948f3-cd88-51eb-bf4c-7208b607010f','9650f312-a96f-5205-8855-1d2d5049a5c0',8),
 ('ed4948f3-cd88-51eb-bf4c-7208b607010f','731ecec5-951b-5ce5-9daf-85d7f6e7ad9c',9),
 ('ed4948f3-cd88-51eb-bf4c-7208b607010f','8428fe94-42ab-5f5b-9444-ac541bb4d51a',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('e5120ed0-1180-5b27-9cb3-d0a0c4420eff','20000000-0000-0000-0000-000000000003',$p$la tête$p$,$p$la cabeza$p$,341,'sustantivo'),
 ('99af1caa-8ce0-58d2-bf1e-bb5a519b32bc','20000000-0000-0000-0000-000000000003',$p$le bras$p$,$p$el brazo$p$,342,'sustantivo'),
 ('0acf4922-781f-5854-a6ac-a46af119b554','20000000-0000-0000-0000-000000000003',$p$la jambe$p$,$p$la pierna$p$,343,'sustantivo'),
 ('5ef6dab8-9fae-591f-b339-0c6df597d7b8','20000000-0000-0000-0000-000000000003',$p$le dos$p$,$p$la espalda$p$,344,'sustantivo'),
 ('1ce93e58-1a6a-5074-a8fe-0eac55914e1a','20000000-0000-0000-0000-000000000003',$p$le ventre$p$,$p$la barriga / el vientre$p$,345,'sustantivo'),
 ('64eea674-36a9-53d8-b57e-45db043390aa','20000000-0000-0000-0000-000000000003',$p$la gorge$p$,$p$la garganta$p$,346,'sustantivo'),
 ('9079cdeb-dd44-5087-8cde-6680cefeeb93','20000000-0000-0000-0000-000000000003',$p$les dents$p$,$p$los dientes$p$,347,'sustantivo'),
 ('d8eb0e03-46ac-5010-a0f9-fc9713f493c8','20000000-0000-0000-0000-000000000003',$p$le pied$p$,$p$el pie$p$,348,'sustantivo'),
 ('840dd2f5-283c-5275-891d-408fc63676ab','20000000-0000-0000-0000-000000000003',$p$la main$p$,$p$la mano$p$,349,'sustantivo'),
 ('084486aa-affc-565d-a4dc-47290b81b4fc','20000000-0000-0000-0000-000000000003',$p$malade$p$,$p$enfermo$p$,350,'adjetivo'),
 ('e509e51c-dd90-5809-9cf5-f27d99c0ce2d','20000000-0000-0000-0000-000000000003',$p$la fièvre$p$,$p$la fiebre$p$,351,'sustantivo'),
 ('4e7553d7-0c5e-5568-acc5-7c83a0dbf107','20000000-0000-0000-0000-000000000003',$p$le médecin$p$,$p$el médico$p$,352,'sustantivo'),
 ('d76c9d2f-ebea-541f-be00-43814dd0a93b','20000000-0000-0000-0000-000000000003',$p$se reposer$p$,$p$descansar$p$,353,'verbo'),
 ('a0ae5e80-c5fe-5a9c-b51f-91203d5db39a','20000000-0000-0000-0000-000000000003',$p$il faut$p$,$p$hay que$p$,354,'expresion'),
 ('7d26287b-f5c5-5508-90e1-4d6b55855ad2','20000000-0000-0000-0000-000000000003',$p$tu devrais$p$,$p$deberías$p$,355,'expresion'),
 ('029fc9a1-befb-58d3-9abe-968e470debd1','20000000-0000-0000-0000-000000000003',$p$avoir mal à$p$,$p$tener dolor de / doler$p$,356,'expresion')
on conflict (id) do nothing;

commit;