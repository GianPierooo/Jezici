-- 20260722120191_seed_ro_a1.sql
-- Currículo A1 del curso es→ro (6 unidades). Molde es→pt.
-- Contenido scopeado a course_id=20000000-0000-0000-0000-000000000007 → aislamiento multicurso por
-- jz_active_course. Unidades order_index continúan la cadena → gating al nivel previo.
begin;
insert into languages (id, code, name) values
  ('10000000-0000-0000-0000-000000000008','ro',$p$Română$p$) on conflict (id) do nothing;
insert into courses (id, source_language_id, target_language_id, is_active) values
  ('20000000-0000-0000-0000-000000000007','10000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000008',true) on conflict (id) do nothing;

-- ── Unidad 1 (A1·ro): Saludos y presentarte ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('8916d248-148c-58bc-ad7e-52592ced9763','20000000-0000-0000-0000-000000000007','A1',1,$p$Saludos y presentarte$p$,'#27AE60','waving_hand')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('a65f338e-5c7c-5416-b5c5-a19d6b124aaf','8916d248-148c-58bc-ad7e-52592ced9763',1,$p$Bună! Saludar y despedirte$p$,$p$Bună! Saludar y despedirte$p$,'lesson',15),
 ('62e4b1f7-8846-5a9d-938f-9c37eb54f75a','8916d248-148c-58bc-ad7e-52592ced9763',2,$p$Mă numesc… decir tu nombre$p$,$p$Mă numesc… decir tu nombre$p$,'lesson',15),
 ('e48bb8db-e994-5dbf-aebc-fce74fbcde79','8916d248-148c-58bc-ad7e-52592ced9763',3,$p$El verbo a fi (ser/estar)$p$,$p$El verbo a fi (ser/estar)$p$,'lesson',15),
 ('391c885a-d39b-595c-8217-31fff879ef94','8916d248-148c-58bc-ad7e-52592ced9763',4,$p$¿De dónde eres? Tú y usted$p$,$p$¿De dónde eres? Tú y usted$p$,'lesson',15),
 ('085e9bf3-2346-5855-9f12-33002c395784','8916d248-148c-58bc-ad7e-52592ced9763',5,$p$🏁 Checkpoint Unitatea 1$p$,$p$Repasa los saludos formales e informales, decir tu nombre, el verbo a fi y de dónde eres.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('80caae74-ef5f-5b7e-bab1-9fb879b1b781','20000000-0000-0000-0000-000000000007','checkpoint','A1','8916d248-148c-58bc-ad7e-52592ced9763',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('dd6ec3ed-512a-54cb-89a2-d5dda051c8b2'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','reading','match',$p$Empareja cada saludo rumano con su significado.$p$,$j${"pairs": [{"en": "bună dimineața", "es": "buenos días (por la mañana)"}, {"en": "bună seara", "es": "buenas tardes (al llegar)"}, {"en": "la revedere", "es": "adiós (formal)"}]}$j$::jsonb,$j${"pairs": [["bună dimineața", "buenos días (por la mañana)"], ["bună seara", "buenas tardes (al llegar)"], ["la revedere", "adiós (formal)"]]}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$saludos$p$, $p$reading$p$]),
('499b03b3-85ce-5f1f-8d42-587c8df92947'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','reading','multiple_choice',$p$Entras a una farmacia a las cuatro de la tarde y saludas de forma FORMAL. ¿Qué dices?$p$,$j${"options": ["Bună ziua!", "Bună dimineața!", "Noapte bună!"]}$j$::jsonb,$j${"value": "Bună ziua!"}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$saludos$p$, $p$reading$p$]),
('56e45292-c0a9-5629-8f64-2fd56d744217'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','reading','multiple_choice',$p$Te despides de tu jefa al salir de la oficina. ¿Cuál es la despedida FORMAL?$p$,$j${"options": ["La revedere!", "Pa!", "Salut!"]}$j$::jsonb,$j${"value": "La revedere!"}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$saludos$p$, $p$reading$p$]),
('0a2a79a7-a6d8-5cc4-8f3e-884b70cd713a'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Bună dimineața!", "Bună seara!", "Noapte bună!"], "say": "Bună dimineața!", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/0a2a79a7-a6d8-5cc4-8f3e-884b70cd713a.mp3"}$j$::jsonb,$j${"value": "Bună dimineața!"}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$saludos$p$, $p$listening$p$]),
('a9156c4c-9184-5d67-bb7f-ea54877d5a45'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Noapte bună!", "Bună ziua!", "Bună seara!"], "say": "Noapte bună!", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/a9156c4c-9184-5d67-bb7f-ea54877d5a45.mp3"}$j$::jsonb,$j${"value": "Noapte bună!"}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$saludos$p$, $p$listening$p$]),
('1fe3921d-2464-5a5f-8d97-ca84cceb9214'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','reading','multiple_choice',$p$Le preguntas el nombre a una señora a la que tratas de usted. ¿Cuál es la forma correcta?$p$,$j${"options": ["Cum vă numiți?", "Cum te numești?", "Cum se numește?"]}$j$::jsonb,$j${"value": "Cum vă numiți?"}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$presentarse$p$, $p$reading$p$]),
('4e2d9535-d10f-5a2c-9ae5-f2e55e91898a'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','writing','cloze',$p$Completa con el verbo: «Me llamo Maria».$p$,$j${"text": "Mă ___ Maria."}$j$::jsonb,$j${"value": "numesc", "accepted": ["numesc"]}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$presentarse$p$, $p$writing$p$]),
('f09444bb-e16e-5ce5-bc44-8f74b2e3dabd'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','writing','translation',$p$Traduce al rumano:$p$,$j${"source": "Me llamo Ana."}$j$::jsonb,$j${"value": "Mă numesc Ana.", "accepted": ["Mă numesc Ana.", "Mă numesc Ana", "Ma numesc Ana.", "Ma numesc Ana", "Numele meu este Ana.", "Numele meu este Ana", "Mă cheamă Ana.", "Mă cheamă Ana", "Ma cheama Ana", "Ma cheama Ana.", "Eu mă numesc Ana.", "Eu mă numesc Ana", "Numele meu e Ana.", "Numele meu e Ana", "Eu ma numesc Ana", "Eu ma numesc Ana."]}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$presentarse$p$, $p$writing$p$]),
('cb25b113-1019-5ac3-8850-2b4bfc5a17a5'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','writing','reorder',$p$Ordena las palabras para decir «Encantado de conocerte».$p$,$j${"tiles": ["bine", "Îmi", "pare"]}$j$::jsonb,$j${"value": "Îmi pare bine"}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$presentarse$p$, $p$writing$p$]),
('2664dc28-7411-56b8-a400-a03982c45f13'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Bună! Mă numesc Ion. Îmi pare bine.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/2664dc28-7411-56b8-a400-a03982c45f13.mp3"}$j$::jsonb,$j${"expected": "Bună! Mă numesc Ion. Îmi pare bine."}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$presentarse$p$, $p$speaking$p$]),
('3d02e251-5581-5af6-a261-f748b6ed48c2'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','reading','match',$p$Empareja cada forma del verbo a fi con su significado.$p$,$j${"pairs": [{"en": "tu ești", "es": "tú eres"}, {"en": "noi suntem", "es": "nosotros somos"}, {"en": "voi sunteți", "es": "vosotros sois"}]}$j$::jsonb,$j${"pairs": [["tu ești", "tú eres"], ["noi suntem", "nosotros somos"], ["voi sunteți", "vosotros sois"]]}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$verbo_a_fi$p$, $p$reading$p$]),
('388cebc5-b49e-5974-863c-91f42e632acd'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','reading','multiple_choice',$p$Completa con el verbo a fi: «Tu ___ din România.» (tú, informal)$p$,$j${"options": ["ești", "este", "sunteți"]}$j$::jsonb,$j${"value": "ești"}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$verbo_a_fi$p$, $p$reading$p$]),
('752370b6-14c6-5ed2-a02f-27072844c72b'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','writing','cloze',$p$Completa con el verbo a fi: «Nosotros somos estudiantes.»$p$,$j${"text": "Noi ___ studenți."}$j$::jsonb,$j${"value": "suntem", "accepted": ["suntem"]}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$verbo_a_fi$p$, $p$writing$p$]),
('2c1b56aa-8cf1-519a-aca0-aa4fc261ac9e'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ea este profesoară.", "Ea este studentă.", "Ea este din România."], "say": "Ea este profesoară.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/2c1b56aa-8cf1-519a-aca0-aa4fc261ac9e.mp3"}$j$::jsonb,$j${"value": "Ea este profesoară."}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$verbo_a_fi$p$, $p$listening$p$]),
('326125d4-002c-5775-8e06-021c4272c1ec'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Eu sunt Ana. El este Andrei.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/326125d4-002c-5775-8e06-021c4272c1ec.mp3"}$j$::jsonb,$j${"expected": "Eu sunt Ana. El este Andrei."}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$verbo_a_fi$p$, $p$speaking$p$]),
('bf2d4758-aff6-531a-8c21-f7c56d7369e1'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','writing','translation',$p$Traduce al rumano:$p$,$j${"source": "Soy de España."}$j$::jsonb,$j${"value": "Sunt din Spania.", "accepted": ["Sunt din Spania.", "Sunt din Spania", "Eu sunt din Spania.", "Eu sunt din Spania"]}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$origen$p$, $p$writing$p$]),
('ef733b0c-0536-556a-a851-c7918e306705'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','writing','word_bank',$p$Ordena para decir «¿De qué país eres?».$p$,$j${"tiles": ["ce", "sunteți", "Din", "ești", "este", "țară"]}$j$::jsonb,$j${"value": "Din ce țară ești", "sequence": ["Din", "ce", "țară", "ești"]}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$origen$p$, $p$writing$p$]),
('1745fa80-3880-57c2-9f83-ad43e95f7e94'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Sunt din Spania.", "Sunt din Italia.", "Sunt din România."], "say": "Sunt din Spania.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/1745fa80-3880-57c2-9f83-ad43e95f7e94.mp3"}$j$::jsonb,$j${"value": "Sunt din Spania."}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$origen$p$, $p$listening$p$]),
('bbf407b5-81e5-5bca-9de2-c66d2a9fb4cb'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Din ce țară ești?", "Din ce țară sunteți?", "Cum te numești?"], "say": "Din ce țară ești?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/bbf407b5-81e5-5bca-9de2-c66d2a9fb4cb.mp3"}$j$::jsonb,$j${"value": "Din ce țară ești?"}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$origen$p$, $p$listening$p$]),
('35f1064a-4dfd-5dab-9040-70171f76cb87'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Sunt din Spania. Tu din ce țară ești?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/35f1064a-4dfd-5dab-9040-70171f76cb87.mp3"}$j$::jsonb,$j${"expected": "Sunt din Spania. Tu din ce țară ești?"}$j$::jsonb,0.16,ARRAY[$p$unidad1$p$, $p$origen$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('a65f338e-5c7c-5416-b5c5-a19d6b124aaf','dd6ec3ed-512a-54cb-89a2-d5dda051c8b2',1),
 ('a65f338e-5c7c-5416-b5c5-a19d6b124aaf','499b03b3-85ce-5f1f-8d42-587c8df92947',2),
 ('a65f338e-5c7c-5416-b5c5-a19d6b124aaf','56e45292-c0a9-5629-8f64-2fd56d744217',3),
 ('a65f338e-5c7c-5416-b5c5-a19d6b124aaf','0a2a79a7-a6d8-5cc4-8f3e-884b70cd713a',4),
 ('a65f338e-5c7c-5416-b5c5-a19d6b124aaf','a9156c4c-9184-5d67-bb7f-ea54877d5a45',5),
 ('62e4b1f7-8846-5a9d-938f-9c37eb54f75a','1fe3921d-2464-5a5f-8d97-ca84cceb9214',1),
 ('62e4b1f7-8846-5a9d-938f-9c37eb54f75a','4e2d9535-d10f-5a2c-9ae5-f2e55e91898a',2),
 ('62e4b1f7-8846-5a9d-938f-9c37eb54f75a','f09444bb-e16e-5ce5-bc44-8f74b2e3dabd',3),
 ('62e4b1f7-8846-5a9d-938f-9c37eb54f75a','cb25b113-1019-5ac3-8850-2b4bfc5a17a5',4),
 ('62e4b1f7-8846-5a9d-938f-9c37eb54f75a','2664dc28-7411-56b8-a400-a03982c45f13',5),
 ('e48bb8db-e994-5dbf-aebc-fce74fbcde79','3d02e251-5581-5af6-a261-f748b6ed48c2',1),
 ('e48bb8db-e994-5dbf-aebc-fce74fbcde79','388cebc5-b49e-5974-863c-91f42e632acd',2),
 ('e48bb8db-e994-5dbf-aebc-fce74fbcde79','752370b6-14c6-5ed2-a02f-27072844c72b',3),
 ('e48bb8db-e994-5dbf-aebc-fce74fbcde79','2c1b56aa-8cf1-519a-aca0-aa4fc261ac9e',4),
 ('e48bb8db-e994-5dbf-aebc-fce74fbcde79','326125d4-002c-5775-8e06-021c4272c1ec',5),
 ('391c885a-d39b-595c-8217-31fff879ef94','bf2d4758-aff6-531a-8c21-f7c56d7369e1',1),
 ('391c885a-d39b-595c-8217-31fff879ef94','ef733b0c-0536-556a-a851-c7918e306705',2),
 ('391c885a-d39b-595c-8217-31fff879ef94','1745fa80-3880-57c2-9f83-ad43e95f7e94',3),
 ('391c885a-d39b-595c-8217-31fff879ef94','bbf407b5-81e5-5bca-9de2-c66d2a9fb4cb',4),
 ('391c885a-d39b-595c-8217-31fff879ef94','35f1064a-4dfd-5dab-9040-70171f76cb87',5),
 ('085e9bf3-2346-5855-9f12-33002c395784','dd6ec3ed-512a-54cb-89a2-d5dda051c8b2',1),
 ('085e9bf3-2346-5855-9f12-33002c395784','499b03b3-85ce-5f1f-8d42-587c8df92947',2),
 ('085e9bf3-2346-5855-9f12-33002c395784','56e45292-c0a9-5629-8f64-2fd56d744217',3),
 ('085e9bf3-2346-5855-9f12-33002c395784','4e2d9535-d10f-5a2c-9ae5-f2e55e91898a',4),
 ('085e9bf3-2346-5855-9f12-33002c395784','f09444bb-e16e-5ce5-bc44-8f74b2e3dabd',5),
 ('085e9bf3-2346-5855-9f12-33002c395784','cb25b113-1019-5ac3-8850-2b4bfc5a17a5',6),
 ('085e9bf3-2346-5855-9f12-33002c395784','0a2a79a7-a6d8-5cc4-8f3e-884b70cd713a',7),
 ('085e9bf3-2346-5855-9f12-33002c395784','a9156c4c-9184-5d67-bb7f-ea54877d5a45',8),
 ('085e9bf3-2346-5855-9f12-33002c395784','2664dc28-7411-56b8-a400-a03982c45f13',9),
 ('085e9bf3-2346-5855-9f12-33002c395784','326125d4-002c-5775-8e06-021c4272c1ec',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('cdae5b16-cf61-56e6-9719-f6057dfc84a1','20000000-0000-0000-0000-000000000007',$p$bună$p$,$p$hola (informal)$p$,121,'interjeccion'),
 ('fa67b429-695c-538d-8f63-bf1772dcec4a','20000000-0000-0000-0000-000000000007',$p$bună ziua$p$,$p$buenos días / buenas tardes (hasta el anochecer)$p$,122,'interjeccion'),
 ('05b10dc2-4977-577d-8513-3f8b7916be73','20000000-0000-0000-0000-000000000007',$p$bună dimineața$p$,$p$buenos días (por la mañana)$p$,123,'interjeccion'),
 ('bd51d5d0-f698-5e96-9ed4-d4c1d7b23ba5','20000000-0000-0000-0000-000000000007',$p$bună seara$p$,$p$buenas tardes-noches (desde el anochecer)$p$,124,'interjeccion'),
 ('1656974f-5322-5840-bdb9-6b93821c7b71','20000000-0000-0000-0000-000000000007',$p$noapte bună$p$,$p$buenas noches (al despedirse)$p$,125,'interjeccion'),
 ('fea01ed0-ce80-589e-9cb0-6d566db29aa3','20000000-0000-0000-0000-000000000007',$p$salut$p$,$p$hola (entre amigos)$p$,126,'interjeccion'),
 ('1fb657cd-fdda-5f80-843a-02367b5a95ca','20000000-0000-0000-0000-000000000007',$p$la revedere$p$,$p$adiós (formal)$p$,127,'interjeccion'),
 ('c9f96cdb-f952-58d7-9bef-7e208aed811a','20000000-0000-0000-0000-000000000007',$p$îmi pare bine$p$,$p$encantado / mucho gusto$p$,128,'expresion'),
 ('ac349f7b-cfbf-50f8-9132-06f8f70cb819','20000000-0000-0000-0000-000000000007',$p$a fi$p$,$p$ser / estar$p$,129,'verbo'),
 ('77a701c7-c1cc-5eed-a5ce-60bd833e8976','20000000-0000-0000-0000-000000000007',$p$a se numi$p$,$p$llamarse$p$,130,'verbo'),
 ('aa5298dd-c37e-54f1-9d20-250172a42b5a','20000000-0000-0000-0000-000000000007',$p$nume$p$,$p$nombre$p$,131,'sustantivo'),
 ('81ed454c-6cc2-5f35-a6f4-5d142d0d4ee6','20000000-0000-0000-0000-000000000007',$p$eu$p$,$p$yo$p$,132,'pronombre'),
 ('5afcb34e-1f76-5d2e-95ff-996450bf5797','20000000-0000-0000-0000-000000000007',$p$tu$p$,$p$tú$p$,133,'pronombre'),
 ('7aeb9f0e-fe48-5351-b838-e75eb489cb4b','20000000-0000-0000-0000-000000000007',$p$el$p$,$p$él$p$,134,'pronombre'),
 ('0fadcda6-9dff-5e1a-ac32-faf9694f8549','20000000-0000-0000-0000-000000000007',$p$ea$p$,$p$ella$p$,135,'pronombre'),
 ('2723b780-d09e-571e-bb6e-40ae0e22cd36','20000000-0000-0000-0000-000000000007',$p$dumneavoastră$p$,$p$usted$p$,136,'pronombre'),
 ('4c947b34-e6ed-506e-a412-40c73f6e6346','20000000-0000-0000-0000-000000000007',$p$țară$p$,$p$país$p$,137,'sustantivo'),
 ('24312cae-1e3e-5225-92b7-e6308560f512','20000000-0000-0000-0000-000000000007',$p$din$p$,$p$de / desde (procedencia)$p$,138,'preposicion')
on conflict (id) do nothing;

-- ── Unidad 2 (A1·ro): Números, edad y de dónde vienes ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('61dc5c58-48af-5e1f-8454-443ea13c6218','20000000-0000-0000-0000-000000000007','A1',2,$p$Números, edad y de dónde vienes$p$,'#2D9CDB','pin')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('ad91fa09-703a-5c67-aee3-fa3d697b6246','61dc5c58-48af-5e1f-8454-443ea13c6218',1,$p$Los números del 0 al 20$p$,$p$Los números del 0 al 20$p$,'lesson',15),
 ('c40fc569-9647-5943-8b32-fffc6c4bc493','61dc5c58-48af-5e1f-8454-443ea13c6218',2,$p$Las decenas y la regla del «de»$p$,$p$Las decenas y la regla del «de»$p$,'lesson',15),
 ('637afcb2-32cf-56b9-bfe4-eceff6c8b058','61dc5c58-48af-5e1f-8454-443ea13c6218',3,$p$La edad con «a avea»$p$,$p$La edad con «a avea»$p$,'lesson',15),
 ('a9fae565-6ee5-57a2-afec-a7f33af1083d','61dc5c58-48af-5e1f-8454-443ea13c6218',4,$p$Países y nacionalidades$p$,$p$Países y nacionalidades$p$,'lesson',15),
 ('c4100d8f-bf61-5671-a813-b7396d4a4bd0','61dc5c58-48af-5e1f-8454-443ea13c6218',5,$p$🏁 Checkpoint Unitatea 2$p$,$p$Repasa los números 0-20 y las decenas, la regla del «de» a partir de 20, la edad con «a avea» y decir de dónde eres y dónde vives.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('e86f3b59-474e-539c-8fad-d419a28d5c0b','20000000-0000-0000-0000-000000000007','checkpoint','A1','61dc5c58-48af-5e1f-8454-443ea13c6218',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('f4a94e51-17a5-5cab-b69b-aa0e2a99352f'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','reading','match',$p$Empareja cada número rumano con su traducción.$p$,$j${"pairs": [{"en": "patru", "es": "cuatro"}, {"en": "nouă", "es": "nueve"}, {"en": "cincisprezece", "es": "quince"}]}$j$::jsonb,$j${"pairs": [["patru", "cuatro"], ["nouă", "nueve"], ["cincisprezece", "quince"]]}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$numere_0_20$p$, $p$reading$p$]),
('2cfc3062-d54c-5804-8bba-0ea9e141ba00'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','reading','multiple_choice',$p$¿Qué número es «șaisprezece»?$p$,$j${"options": ["16", "6", "60"]}$j$::jsonb,$j${"value": "16"}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$numere_0_20$p$, $p$reading$p$]),
('a509cdb4-b5e3-552a-8402-026c881129ab'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','listening','listening',$p$Escucha y elige el número que oíste.$p$,$j${"options": ["nouăsprezece", "nouă", "nouăzeci"], "say": "nouăsprezece", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/a509cdb4-b5e3-552a-8402-026c881129ab.mp3"}$j$::jsonb,$j${"value": "nouăsprezece"}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$numere_0_20$p$, $p$listening$p$]),
('103cf677-4b51-50c2-bdcc-859d317e5bd6'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','writing','cloze',$p$Escribe en letras el número 15 en rumano.$p$,$j${"text": "15 = ___"}$j$::jsonb,$j${"value": "cincisprezece", "accepted": ["cincisprezece"]}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$numere_0_20$p$, $p$writing$p$]),
('d1eed449-da57-582b-a741-891efad770d1'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "unu, doi, trei, patru, cinci, șase, șapte, opt, nouă, zece", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/d1eed449-da57-582b-a741-891efad770d1.mp3"}$j$::jsonb,$j${"expected": "unu, doi, trei, patru, cinci, șase, șapte, opt, nouă, zece"}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$numere_0_20$p$, $p$speaking$p$]),
('9a02e902-48b5-5d9a-a017-76308f551049'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','reading','multiple_choice',$p$Elige la forma correcta para «Tengo veinte años».$p$,$j${"options": ["Am douăzeci de ani.", "Am douăzeci ani.", "Am douăzeci de an."]}$j$::jsonb,$j${"value": "Am douăzeci de ani."}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$zeci_regula_de$p$, $p$reading$p$]),
('ab201468-ceb1-5679-868f-8b68f62d0814'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','reading','multiple_choice',$p$Elige la forma correcta para «Tengo cinco años».$p$,$j${"options": ["Am cinci ani.", "Am cinci de ani.", "Am cinci de an."]}$j$::jsonb,$j${"value": "Am cinci ani."}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$zeci_regula_de$p$, $p$reading$p$]),
('25299ca0-2690-5342-9154-19ec6fb3686e'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Costă o sută de lei.", "Costă zece lei.", "Costă cincizeci de lei."], "say": "Costă o sută de lei.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/25299ca0-2690-5342-9154-19ec6fb3686e.mp3"}$j$::jsonb,$j${"value": "Costă o sută de lei."}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$zeci_regula_de$p$, $p$listening$p$]),
('1ebb635c-94b3-509b-8623-ffb2e320c360'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','writing','cloze',$p$Completa con el número 40 escrito en letras: «Ella tiene cuarenta años».$p$,$j${"text": "Ea are ___ de ani."}$j$::jsonb,$j${"value": "patruzeci", "accepted": ["patruzeci"]}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$zeci_regula_de$p$, $p$writing$p$]),
('2aaac2e1-20e4-59dc-9f73-1ea159438595'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','writing','word_bank',$p$Ordena para decir «Ella tiene treinta años».$p$,$j${"tiles": ["ani", "este", "treizeci", "Ea", "de", "an", "are"]}$j$::jsonb,$j${"value": "Ea are treizeci de ani", "sequence": ["Ea", "are", "treizeci", "de", "ani"]}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$zeci_regula_de$p$, $p$writing$p$]),
('8815a3c7-7328-52c4-a80f-429a8d5d135e'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','reading','multiple_choice',$p$Elige la forma correcta para «¿Cuántos años tienes?».$p$,$j${"options": ["Câți ani ai?", "Câți ani ești?", "Cât ani ai?"]}$j$::jsonb,$j${"value": "Câți ani ai?"}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$varsta_a_avea$p$, $p$reading$p$]),
('ccd7510f-1b7a-5e0e-8ecc-8345144def13'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Câți ani ai?", "Câți ani are ea?", "De unde ești?"], "say": "Câți ani ai?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/ccd7510f-1b7a-5e0e-8ecc-8345144def13.mp3"}$j$::jsonb,$j${"value": "Câți ani ai?"}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$varsta_a_avea$p$, $p$listening$p$]),
('db2c50bd-94d8-59e4-867b-534cf8e28596'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','writing','translation',$p$Traduce al rumano:$p$,$j${"source": "Tengo treinta años."}$j$::jsonb,$j${"value": "Am treizeci de ani.", "accepted": ["Am treizeci de ani.", "Am treizeci de ani", "Eu am treizeci de ani.", "Eu am treizeci de ani"]}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$varsta_a_avea$p$, $p$writing$p$]),
('21975222-44e5-5671-b0bb-b6942caba59c'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','writing','reorder',$p$Ordena las palabras: «Él tiene cincuenta años».$p$,$j${"tiles": ["de", "cincizeci", "El", "ani", "are"]}$j$::jsonb,$j${"value": "El are cincizeci de ani"}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$varsta_a_avea$p$, $p$writing$p$]),
('d9496b36-6875-5aae-89a5-bba11f3ee7ba'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Câți ani ai? Am douăzeci și cinci de ani.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/d9496b36-6875-5aae-89a5-bba11f3ee7ba.mp3"}$j$::jsonb,$j${"expected": "Câți ani ai? Am douăzeci și cinci de ani."}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$varsta_a_avea$p$, $p$speaking$p$]),
('6761e815-0640-5dcf-952b-5cbc1d5d95e2'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','reading','match',$p$Empareja cada nacionalidad rumana con su traducción.$p$,$j${"pairs": [{"en": "spaniol", "es": "español"}, {"en": "româncă", "es": "rumana"}, {"en": "mexican", "es": "mexicano"}]}$j$::jsonb,$j${"pairs": [["spaniol", "español"], ["româncă", "rumana"], ["mexican", "mexicano"]]}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$tari_nationalitati$p$, $p$reading$p$]),
('97d2dfc9-2bc1-5b5f-a546-3d9d35dc88d3'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Sunt din Mexic.", "Sunt din Spania.", "Sunt din România."], "say": "Sunt din Mexic.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/97d2dfc9-2bc1-5b5f-a546-3d9d35dc88d3.mp3"}$j$::jsonb,$j${"value": "Sunt din Mexic."}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$tari_nationalitati$p$, $p$listening$p$]),
('b0827f93-0be6-5ac1-a4b5-c7e0d4e1c729'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Unde locuiești?", "De unde ești?", "Câți ani ai?"], "say": "Unde locuiești?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/b0827f93-0be6-5ac1-a4b5-c7e0d4e1c729.mp3"}$j$::jsonb,$j${"value": "Unde locuiești?"}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$tari_nationalitati$p$, $p$listening$p$]),
('a89130e0-ac66-5e04-a8d7-b3be5bbb814b'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','writing','translation',$p$Traduce al rumano:$p$,$j${"source": "Vivo en Madrid."}$j$::jsonb,$j${"value": "Locuiesc în Madrid.", "accepted": ["Locuiesc în Madrid.", "Locuiesc în Madrid", "Eu locuiesc în Madrid.", "Eu locuiesc în Madrid", "Eu locuiesc in Madrid", "Eu locuiesc in Madrid.", "Locuiesc in Madrid", "Locuiesc in Madrid."]}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$tari_nationalitati$p$, $p$writing$p$]),
('be92ee50-aa27-5564-a4db-b4d004d904e8'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Sunt din Spania. Sunt spaniol. Locuiesc în Madrid.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/be92ee50-aa27-5564-a4db-b4d004d904e8.mp3"}$j$::jsonb,$j${"expected": "Sunt din Spania. Sunt spaniol. Locuiesc în Madrid."}$j$::jsonb,0.16,ARRAY[$p$unidad2$p$, $p$tari_nationalitati$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('ad91fa09-703a-5c67-aee3-fa3d697b6246','f4a94e51-17a5-5cab-b69b-aa0e2a99352f',1),
 ('ad91fa09-703a-5c67-aee3-fa3d697b6246','2cfc3062-d54c-5804-8bba-0ea9e141ba00',2),
 ('ad91fa09-703a-5c67-aee3-fa3d697b6246','a509cdb4-b5e3-552a-8402-026c881129ab',3),
 ('ad91fa09-703a-5c67-aee3-fa3d697b6246','103cf677-4b51-50c2-bdcc-859d317e5bd6',4),
 ('ad91fa09-703a-5c67-aee3-fa3d697b6246','d1eed449-da57-582b-a741-891efad770d1',5),
 ('c40fc569-9647-5943-8b32-fffc6c4bc493','9a02e902-48b5-5d9a-a017-76308f551049',1),
 ('c40fc569-9647-5943-8b32-fffc6c4bc493','ab201468-ceb1-5679-868f-8b68f62d0814',2),
 ('c40fc569-9647-5943-8b32-fffc6c4bc493','25299ca0-2690-5342-9154-19ec6fb3686e',3),
 ('c40fc569-9647-5943-8b32-fffc6c4bc493','1ebb635c-94b3-509b-8623-ffb2e320c360',4),
 ('c40fc569-9647-5943-8b32-fffc6c4bc493','2aaac2e1-20e4-59dc-9f73-1ea159438595',5),
 ('637afcb2-32cf-56b9-bfe4-eceff6c8b058','8815a3c7-7328-52c4-a80f-429a8d5d135e',1),
 ('637afcb2-32cf-56b9-bfe4-eceff6c8b058','ccd7510f-1b7a-5e0e-8ecc-8345144def13',2),
 ('637afcb2-32cf-56b9-bfe4-eceff6c8b058','db2c50bd-94d8-59e4-867b-534cf8e28596',3),
 ('637afcb2-32cf-56b9-bfe4-eceff6c8b058','21975222-44e5-5671-b0bb-b6942caba59c',4),
 ('637afcb2-32cf-56b9-bfe4-eceff6c8b058','d9496b36-6875-5aae-89a5-bba11f3ee7ba',5),
 ('a9fae565-6ee5-57a2-afec-a7f33af1083d','6761e815-0640-5dcf-952b-5cbc1d5d95e2',1),
 ('a9fae565-6ee5-57a2-afec-a7f33af1083d','97d2dfc9-2bc1-5b5f-a546-3d9d35dc88d3',2),
 ('a9fae565-6ee5-57a2-afec-a7f33af1083d','b0827f93-0be6-5ac1-a4b5-c7e0d4e1c729',3),
 ('a9fae565-6ee5-57a2-afec-a7f33af1083d','a89130e0-ac66-5e04-a8d7-b3be5bbb814b',4),
 ('a9fae565-6ee5-57a2-afec-a7f33af1083d','be92ee50-aa27-5564-a4db-b4d004d904e8',5),
 ('c4100d8f-bf61-5671-a813-b7396d4a4bd0','f4a94e51-17a5-5cab-b69b-aa0e2a99352f',1),
 ('c4100d8f-bf61-5671-a813-b7396d4a4bd0','2cfc3062-d54c-5804-8bba-0ea9e141ba00',2),
 ('c4100d8f-bf61-5671-a813-b7396d4a4bd0','9a02e902-48b5-5d9a-a017-76308f551049',3),
 ('c4100d8f-bf61-5671-a813-b7396d4a4bd0','103cf677-4b51-50c2-bdcc-859d317e5bd6',4),
 ('c4100d8f-bf61-5671-a813-b7396d4a4bd0','1ebb635c-94b3-509b-8623-ffb2e320c360',5),
 ('c4100d8f-bf61-5671-a813-b7396d4a4bd0','2aaac2e1-20e4-59dc-9f73-1ea159438595',6),
 ('c4100d8f-bf61-5671-a813-b7396d4a4bd0','a509cdb4-b5e3-552a-8402-026c881129ab',7),
 ('c4100d8f-bf61-5671-a813-b7396d4a4bd0','25299ca0-2690-5342-9154-19ec6fb3686e',8),
 ('c4100d8f-bf61-5671-a813-b7396d4a4bd0','d1eed449-da57-582b-a741-891efad770d1',9),
 ('c4100d8f-bf61-5671-a813-b7396d4a4bd0','d9496b36-6875-5aae-89a5-bba11f3ee7ba',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('1d371515-7567-5c0b-8454-06fe511ed3c1','20000000-0000-0000-0000-000000000007',$p$zero$p$,$p$cero$p$,141,'numeral'),
 ('4a94790f-5299-54fb-838e-d89af4de09bc','20000000-0000-0000-0000-000000000007',$p$cinci$p$,$p$cinco$p$,142,'numeral'),
 ('d3c985eb-7f2f-5d0a-a7a3-5a9364c063c7','20000000-0000-0000-0000-000000000007',$p$zece$p$,$p$diez$p$,143,'numeral'),
 ('91cc773a-d702-5d9c-95b5-031387e82eb1','20000000-0000-0000-0000-000000000007',$p$cincisprezece$p$,$p$quince$p$,144,'numeral'),
 ('9f400e56-e445-51e7-985a-541a9fce81ab','20000000-0000-0000-0000-000000000007',$p$douăzeci$p$,$p$veinte$p$,145,'numeral'),
 ('8efb7cc3-3e24-539e-afd3-ea97deb99182','20000000-0000-0000-0000-000000000007',$p$treizeci$p$,$p$treinta$p$,146,'numeral'),
 ('7d7ee42e-5882-597b-83ad-6e982b86aff5','20000000-0000-0000-0000-000000000007',$p$patruzeci$p$,$p$cuarenta$p$,147,'numeral'),
 ('cec9011f-5be7-51bf-a9c2-d008195beb30','20000000-0000-0000-0000-000000000007',$p$o sută$p$,$p$cien$p$,148,'numeral'),
 ('82a13bd7-3b44-5abb-a4f8-2b5a9fc49950','20000000-0000-0000-0000-000000000007',$p$an$p$,$p$año$p$,149,'sustantivo'),
 ('855b8aca-05eb-50d8-911a-b6081cd4c357','20000000-0000-0000-0000-000000000007',$p$leu$p$,$p$leu (la moneda de Rumanía)$p$,150,'sustantivo'),
 ('92be367f-da87-5ecd-8a11-023248c6a497','20000000-0000-0000-0000-000000000007',$p$a avea$p$,$p$tener$p$,151,'verbo'),
 ('f68abebb-b7f7-526f-99ca-b22f620d5a54','20000000-0000-0000-0000-000000000007',$p$am$p$,$p$(yo) tengo$p$,152,'verbo'),
 ('e9b03d8b-6ab6-553c-a09a-372b4c023035','20000000-0000-0000-0000-000000000007',$p$ai$p$,$p$(tú) tienes$p$,153,'verbo'),
 ('fd5f4233-023a-5e07-b537-4f6ca19dd52c','20000000-0000-0000-0000-000000000007',$p$are$p$,$p$(él/ella) tiene$p$,154,'verbo'),
 ('75d1fbc7-e9cf-52d6-bb1a-8be9e9ef711f','20000000-0000-0000-0000-000000000007',$p$de$p$,$p$de (obligatorio tras los números desde 20)$p$,155,'preposicion'),
 ('6aac200d-c260-537a-b167-88ee2d67b22e','20000000-0000-0000-0000-000000000007',$p$român$p$,$p$rumano$p$,156,'adjetivo'),
 ('93bbefda-6e86-5c1f-8c47-190257d6f864','20000000-0000-0000-0000-000000000007',$p$româncă$p$,$p$rumana (mujer)$p$,157,'sustantivo'),
 ('d8373a06-da37-50f5-813e-e5c6ce202ffa','20000000-0000-0000-0000-000000000007',$p$a locui$p$,$p$vivir (residir)$p$,158,'verbo')
on conflict (id) do nothing;

-- ── Unidad 3 (A1·ro): La familia ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('179684bc-9b74-54be-99f2-0da7df05849e','20000000-0000-0000-0000-000000000007','A1',3,$p$La familia$p$,'#F2994A','family_restroom')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('719539f7-bbba-5dda-b481-79ce0b8f40d2','179684bc-9b74-54be-99f2-0da7df05849e',1,$p$La familia (familia mea)$p$,$p$La familia (familia mea)$p$,'lesson',15),
 ('129b8a3d-a109-5a7a-aec3-304d2c01c163','179684bc-9b74-54be-99f2-0da7df05849e',2,$p$El artículo se pega al final: băiatul$p$,$p$El artículo se pega al final: băiatul$p$,'lesson',15),
 ('9efb83b8-5403-5156-a204-81d9d016b5dd','179684bc-9b74-54be-99f2-0da7df05849e',3,$p$Un frate, o soră: el género en las personas$p$,$p$Un frate, o soră: el género en las personas$p$,'lesson',15),
 ('663c3c91-23a7-5330-9c89-c4a7bfbc452b','179684bc-9b74-54be-99f2-0da7df05849e',4,$p$Fratele meu, sora mea (posesivos)$p$,$p$Fratele meu, sora mea (posesivos)$p$,'lesson',15),
 ('7c9a5c42-bf58-5c74-9b0d-64399ce0bfaf','179684bc-9b74-54be-99f2-0da7df05849e',5,$p$🏁 Checkpoint Unitatea 3$p$,$p$Repasa el vocabulario de la familia, el artículo pegado al final (băiatul, bunica), un frate / o soră y los posesivos meu y mea.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('483386cd-793a-510d-92b3-431bfd99e7f1','20000000-0000-0000-0000-000000000007','checkpoint','A1','179684bc-9b74-54be-99f2-0da7df05849e',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('e823e31e-5687-5557-ad49-ff631cb07397'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','reading','match',$p$Empareja cada palabra rumana con su traducción.$p$,$j${"pairs": [{"en": "părinți", "es": "padres"}, {"en": "soț", "es": "esposo"}, {"en": "bunică", "es": "abuela"}]}$j$::jsonb,$j${"pairs": [["părinți", "padres"], ["soț", "esposo"], ["bunică", "abuela"]]}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$familia$p$, $p$reading$p$]),
('4b041d06-4e8b-5d76-958c-ded8923286e6'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','reading','multiple_choice',$p$En rumano, «copil» significa:$p$,$j${"options": ["niño", "copia", "hermano"]}$j$::jsonb,$j${"value": "niño"}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$familia$p$, $p$reading$p$]),
('00cd38e7-50a6-5abe-94e4-aabb0e2edc39'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Tata și mama sunt acasă.", "Bunicul și bunica sunt acasă.", "Fratele și sora sunt acasă."], "say": "Tata și mama sunt acasă.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/00cd38e7-50a6-5abe-94e4-aabb0e2edc39.mp3"}$j$::jsonb,$j${"value": "Tata și mama sunt acasă."}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$familia$p$, $p$listening$p$]),
('dd143bfa-0cf8-56d4-8559-a1d71fb40b25'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','writing','translation',$p$Traduce al rumano:$p$,$j${"source": "Tengo un hermano."}$j$::jsonb,$j${"value": "Am un frate", "accepted": ["Am un frate", "Eu am un frate"]}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$familia$p$, $p$writing$p$]),
('ed2b0f01-ffd2-518d-b4cf-136950385e38'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Aceasta este familia mea.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/ed2b0f01-ffd2-518d-b4cf-136950385e38.mp3"}$j$::jsonb,$j${"expected": "Aceasta este familia mea."}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$familia$p$, $p$speaking$p$]),
('c0157cee-ed41-5c28-92de-4d7f0f6232d9'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','reading','multiple_choice',$p$«El niño» en rumano se dice:$p$,$j${"options": ["copilul", "el copil", "copila"]}$j$::jsonb,$j${"value": "copilul"}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$articol-hotarat$p$, $p$reading$p$]),
('f0d81ba4-bf2f-5caf-831e-8599ecb3c639'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','writing','cloze',$p$«El chico está en casa». Escribe la palabra que falta con el artículo pegado al final.$p$,$j${"text": "___ este acasă."}$j$::jsonb,$j${"value": "băiatul", "accepted": ["băiatul", "baiatul"]}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$articol-hotarat$p$, $p$writing$p$]),
('5683395b-e91e-5c8a-8810-d41cdd560705'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Bunicul este acasă.", "Soția este acasă.", "Copilul este acasă."], "say": "Bunicul este acasă.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/5683395b-e91e-5c8a-8810-d41cdd560705.mp3"}$j$::jsonb,$j${"value": "Bunicul este acasă."}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$articol-hotarat$p$, $p$listening$p$]),
('8229dced-1c10-522f-a6a4-001188c2b2f8'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','writing','word_bank',$p$Ordena para decir «El abuelo y el niño están en casa».$p$,$j${"tiles": ["acasă", "Bunic", "Bunicul", "copil", "copilul", "sunt", "și"]}$j$::jsonb,$j${"value": "Bunicul și copilul sunt acasă", "sequence": ["Bunicul", "și", "copilul", "sunt", "acasă"]}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$articol-hotarat$p$, $p$writing$p$]),
('37550f81-c0a0-5d5e-9140-ea92cafb1ff9'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Băiatul și fata sunt acasă.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/37550f81-c0a0-5d5e-9140-ea92cafb1ff9.mp3"}$j$::jsonb,$j${"expected": "Băiatul și fata sunt acasă."}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$articol-hotarat$p$, $p$speaking$p$]),
('ba154c2c-8be9-5fe8-9337-9b6f50a6f381'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','reading','match',$p$Empareja cada grupo rumano con su traducción.$p$,$j${"pairs": [{"en": "un bunic", "es": "un abuelo"}, {"en": "o bunică", "es": "una abuela"}, {"en": "o fată", "es": "una chica"}]}$j$::jsonb,$j${"pairs": [["un bunic", "un abuelo"], ["o bunică", "una abuela"], ["o fată", "una chica"]]}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$un-o$p$, $p$reading$p$]),
('69028c5b-c184-568a-8bb0-08e61f3a7e3d'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','reading','multiple_choice',$p$«Una hermana» en rumano es:$p$,$j${"options": ["o soră", "un soră", "una soră"]}$j$::jsonb,$j${"value": "o soră"}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$un-o$p$, $p$reading$p$]),
('ce9dff56-1126-587d-bb5b-00c4292a8ae0'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Am o fiică și un fiu.", "Am o soră și un frate.", "Am un frate și o bunică."], "say": "Am o fiică și un fiu.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/ce9dff56-1126-587d-bb5b-00c4292a8ae0.mp3"}$j$::jsonb,$j${"value": "Am o fiică și un fiu."}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$un-o$p$, $p$listening$p$]),
('3ce13693-787d-595a-9ed7-54ea99d3ec76'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ea are un frate.", "El are o soră.", "Ea are o fiică."], "say": "Ea are un frate.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/3ce13693-787d-595a-9ed7-54ea99d3ec76.mp3"}$j$::jsonb,$j${"value": "Ea are un frate."}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$un-o$p$, $p$listening$p$]),
('774efa5d-3ae2-52f8-86a8-166e1c30fc73'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Ea are un frate și o soră.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/774efa5d-3ae2-52f8-86a8-166e1c30fc73.mp3"}$j$::jsonb,$j${"expected": "Ea are un frate și o soră."}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$un-o$p$, $p$speaking$p$]),
('8ae2ee8f-b818-51f1-91c5-c8075daaf4ba'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','reading','multiple_choice',$p$«Mi hermana» en rumano es:$p$,$j${"options": ["sora mea", "mea soră", "sora meu"]}$j$::jsonb,$j${"value": "sora mea"}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$posesive$p$, $p$reading$p$]),
('8a70888d-b1f6-5729-9399-f4f8be860132'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','writing','translation',$p$Traduce al rumano:$p$,$j${"source": "Mi hermano y mi hermana."}$j$::jsonb,$j${"value": "Fratele meu și sora mea", "accepted": ["Fratele meu și sora mea", "Fratele meu si sora mea"]}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$posesive$p$, $p$writing$p$]),
('a598c43f-31dd-550f-a87a-b25399ecf7cc'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','writing','cloze',$p$«Mi hermano tiene un niño». Escribe la palabra que falta: el sustantivo lleva el artículo pegado al final.$p$,$j${"text": "___ meu are un copil."}$j$::jsonb,$j${"value": "fratele", "accepted": ["fratele"]}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$posesive$p$, $p$writing$p$]),
('e0e11ce3-c17d-5645-ad38-8396f5729b14'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','writing','reorder',$p$Ordena las palabras: «Mi hermana tiene un hijo».$p$,$j${"tiles": ["are", "copil", "mea", "Sora", "un"]}$j$::jsonb,$j${"value": "Sora mea are un copil"}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$posesive$p$, $p$writing$p$]),
('bc692e13-cf19-5698-8ab8-04d67aa176f6'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Fratele meu are o fiică.", "Sora mea are un fiu.", "Bunica mea este acasă."], "say": "Fratele meu are o fiică.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/bc692e13-cf19-5698-8ab8-04d67aa176f6.mp3"}$j$::jsonb,$j${"value": "Fratele meu are o fiică."}$j$::jsonb,0.16,ARRAY[$p$unidad3$p$, $p$posesive$p$, $p$listening$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('719539f7-bbba-5dda-b481-79ce0b8f40d2','e823e31e-5687-5557-ad49-ff631cb07397',1),
 ('719539f7-bbba-5dda-b481-79ce0b8f40d2','4b041d06-4e8b-5d76-958c-ded8923286e6',2),
 ('719539f7-bbba-5dda-b481-79ce0b8f40d2','00cd38e7-50a6-5abe-94e4-aabb0e2edc39',3),
 ('719539f7-bbba-5dda-b481-79ce0b8f40d2','dd143bfa-0cf8-56d4-8559-a1d71fb40b25',4),
 ('719539f7-bbba-5dda-b481-79ce0b8f40d2','ed2b0f01-ffd2-518d-b4cf-136950385e38',5),
 ('129b8a3d-a109-5a7a-aec3-304d2c01c163','c0157cee-ed41-5c28-92de-4d7f0f6232d9',1),
 ('129b8a3d-a109-5a7a-aec3-304d2c01c163','f0d81ba4-bf2f-5caf-831e-8599ecb3c639',2),
 ('129b8a3d-a109-5a7a-aec3-304d2c01c163','5683395b-e91e-5c8a-8810-d41cdd560705',3),
 ('129b8a3d-a109-5a7a-aec3-304d2c01c163','8229dced-1c10-522f-a6a4-001188c2b2f8',4),
 ('129b8a3d-a109-5a7a-aec3-304d2c01c163','37550f81-c0a0-5d5e-9140-ea92cafb1ff9',5),
 ('9efb83b8-5403-5156-a204-81d9d016b5dd','ba154c2c-8be9-5fe8-9337-9b6f50a6f381',1),
 ('9efb83b8-5403-5156-a204-81d9d016b5dd','69028c5b-c184-568a-8bb0-08e61f3a7e3d',2),
 ('9efb83b8-5403-5156-a204-81d9d016b5dd','ce9dff56-1126-587d-bb5b-00c4292a8ae0',3),
 ('9efb83b8-5403-5156-a204-81d9d016b5dd','3ce13693-787d-595a-9ed7-54ea99d3ec76',4),
 ('9efb83b8-5403-5156-a204-81d9d016b5dd','774efa5d-3ae2-52f8-86a8-166e1c30fc73',5),
 ('663c3c91-23a7-5330-9c89-c4a7bfbc452b','8ae2ee8f-b818-51f1-91c5-c8075daaf4ba',1),
 ('663c3c91-23a7-5330-9c89-c4a7bfbc452b','8a70888d-b1f6-5729-9399-f4f8be860132',2),
 ('663c3c91-23a7-5330-9c89-c4a7bfbc452b','a598c43f-31dd-550f-a87a-b25399ecf7cc',3),
 ('663c3c91-23a7-5330-9c89-c4a7bfbc452b','e0e11ce3-c17d-5645-ad38-8396f5729b14',4),
 ('663c3c91-23a7-5330-9c89-c4a7bfbc452b','bc692e13-cf19-5698-8ab8-04d67aa176f6',5),
 ('7c9a5c42-bf58-5c74-9b0d-64399ce0bfaf','e823e31e-5687-5557-ad49-ff631cb07397',1),
 ('7c9a5c42-bf58-5c74-9b0d-64399ce0bfaf','4b041d06-4e8b-5d76-958c-ded8923286e6',2),
 ('7c9a5c42-bf58-5c74-9b0d-64399ce0bfaf','c0157cee-ed41-5c28-92de-4d7f0f6232d9',3),
 ('7c9a5c42-bf58-5c74-9b0d-64399ce0bfaf','dd143bfa-0cf8-56d4-8559-a1d71fb40b25',4),
 ('7c9a5c42-bf58-5c74-9b0d-64399ce0bfaf','f0d81ba4-bf2f-5caf-831e-8599ecb3c639',5),
 ('7c9a5c42-bf58-5c74-9b0d-64399ce0bfaf','8229dced-1c10-522f-a6a4-001188c2b2f8',6),
 ('7c9a5c42-bf58-5c74-9b0d-64399ce0bfaf','00cd38e7-50a6-5abe-94e4-aabb0e2edc39',7),
 ('7c9a5c42-bf58-5c74-9b0d-64399ce0bfaf','5683395b-e91e-5c8a-8810-d41cdd560705',8),
 ('7c9a5c42-bf58-5c74-9b0d-64399ce0bfaf','ed2b0f01-ffd2-518d-b4cf-136950385e38',9),
 ('7c9a5c42-bf58-5c74-9b0d-64399ce0bfaf','37550f81-c0a0-5d5e-9140-ea92cafb1ff9',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('f974eb72-cd91-52d3-9a1d-2c85def649b5','20000000-0000-0000-0000-000000000007',$p$familie$p$,$p$familia$p$,161,'sustantivo'),
 ('01c6ab48-0960-5099-b504-1d2e7e8324c6','20000000-0000-0000-0000-000000000007',$p$tată$p$,$p$padre$p$,162,'sustantivo'),
 ('a2e4200f-1361-548d-a014-6c54aa7883f9','20000000-0000-0000-0000-000000000007',$p$mamă$p$,$p$madre$p$,163,'sustantivo'),
 ('9e421a9f-2725-5711-90e6-c85b7713d824','20000000-0000-0000-0000-000000000007',$p$părinți$p$,$p$padres (progenitores)$p$,164,'sustantivo'),
 ('c359fff3-cbfd-5deb-963d-a55d4192dcc0','20000000-0000-0000-0000-000000000007',$p$frate$p$,$p$hermano$p$,165,'sustantivo'),
 ('b270c7cf-1a5c-5a45-991e-be2f3f5c4507','20000000-0000-0000-0000-000000000007',$p$soră$p$,$p$hermana$p$,166,'sustantivo'),
 ('6f145099-013d-5ebd-8a7b-54119f9b9ebe','20000000-0000-0000-0000-000000000007',$p$fiu$p$,$p$hijo$p$,167,'sustantivo'),
 ('4fe796fe-e2f0-5177-9c02-d928367807c4','20000000-0000-0000-0000-000000000007',$p$fiică$p$,$p$hija$p$,168,'sustantivo'),
 ('7ff994ab-3c7c-5e3e-b33b-8cb47c73041d','20000000-0000-0000-0000-000000000007',$p$copil$p$,$p$niño / hijo$p$,169,'sustantivo'),
 ('3b504840-1f25-5363-80ec-0c7ddbb005a8','20000000-0000-0000-0000-000000000007',$p$bunic$p$,$p$abuelo$p$,170,'sustantivo'),
 ('be32c47a-a788-598a-81d7-a3c75d2aa199','20000000-0000-0000-0000-000000000007',$p$bunică$p$,$p$abuela$p$,171,'sustantivo'),
 ('d9ff83a5-5c73-5130-923a-fd0a899847f1','20000000-0000-0000-0000-000000000007',$p$soț$p$,$p$esposo$p$,172,'sustantivo'),
 ('09af1eab-8958-5e01-a990-157305618b91','20000000-0000-0000-0000-000000000007',$p$soție$p$,$p$esposa$p$,173,'sustantivo'),
 ('ed4b4f50-349b-5370-9936-2cd8699b05e7','20000000-0000-0000-0000-000000000007',$p$băiat$p$,$p$chico$p$,174,'sustantivo'),
 ('f9a5f1c2-3a20-53d1-a02a-dc01d0153708','20000000-0000-0000-0000-000000000007',$p$fată$p$,$p$chica$p$,175,'sustantivo'),
 ('523098da-3f2b-58ad-bd1a-47a2bb796193','20000000-0000-0000-0000-000000000007',$p$meu$p$,$p$mi (con palabra masculina)$p$,176,'adjetivo'),
 ('9cf86275-233c-5044-8b6c-b0927d9e2fb0','20000000-0000-0000-0000-000000000007',$p$mea$p$,$p$mi (con palabra femenina)$p$,177,'adjetivo'),
 ('e028aa03-2760-5706-8048-f18bbe7a0352','20000000-0000-0000-0000-000000000007',$p$acasă$p$,$p$en casa$p$,178,'adverbio')
on conflict (id) do nothing;

-- ── Unidad 4 (A1·ro): Comida y en el café ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('5a4e271f-e79d-57d5-85a3-0b39da6622b4','20000000-0000-0000-0000-000000000007','A1',4,$p$Comida y en el café$p$,'#EB5757','restaurant')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('af20614c-14b0-5589-91be-a5a2fcfeebed','5a4e271f-e79d-57d5-85a3-0b39da6622b4',1,$p$La comida y la bebida$p$,$p$La comida y la bebida$p$,'lesson',15),
 ('1134f2ce-fc16-5e25-ada6-08bdcd78c68a','5a4e271f-e79d-57d5-85a3-0b39da6622b4',2,$p$En el café: Aș vrea…, vă rog$p$,$p$En el café: Aș vrea…, vă rog$p$,'lesson',15),
 ('103fd3b5-67ef-5f05-9e91-92503057059d','5a4e271f-e79d-57d5-85a3-0b39da6622b4',3,$p$El verbo «a vrea» y el neutro$p$,$p$El verbo «a vrea» y el neutro$p$,'lesson',15),
 ('4fc34ca5-795c-58c5-b1cf-61be72e3e983','5a4e271f-e79d-57d5-85a3-0b39da6622b4',4,$p$Falsos amigos y la cuenta$p$,$p$Falsos amigos y la cuenta$p$,'lesson',15),
 ('68f0d2fb-e0a4-5def-b9e6-ea0e190e31c7','5a4e271f-e79d-57d5-85a3-0b39da6622b4',5,$p$🏁 Checkpoint Unitatea 4$p$,$p$Repasa pedir comida y bebida con «Aș vrea…, vă rog», el género de los alimentos, el verbo «a vrea» y el plural neutro (un pahar / două pahare).$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('ac4d2de0-9976-5ef9-b2e0-4175c822302f','20000000-0000-0000-0000-000000000007','checkpoint','A1','5a4e271f-e79d-57d5-85a3-0b39da6622b4',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('3714c9d9-2f5d-55a4-85f8-03fcf8954167'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','reading','match',$p$Empareja cada palabra rumana con su traducción.$p$,$j${"pairs": [{"en": "pâine", "es": "el pan"}, {"en": "brânză", "es": "el queso"}, {"en": "carne", "es": "la carne"}]}$j$::jsonb,$j${"pairs": [["pâine", "el pan"], ["brânză", "el queso"], ["carne", "la carne"]]}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$mancare$p$, $p$reading$p$]),
('a45cceb7-53d7-5892-8250-3b8967fa70d6'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','reading','multiple_choice',$p$¿Cómo se dice «un café» (la bebida) en rumano?$p$,$j${"options": ["o cafea", "un cafea", "cafeaua"]}$j$::jsonb,$j${"value": "o cafea"}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$mancare$p$, $p$reading$p$]),
('a1cb85ff-365d-5916-a6f1-07a5cab8d485'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["O cafea și o bere, vă rog.", "O cafea și un ceai, vă rog.", "O supă și pâine, vă rog."], "say": "O cafea și o bere, vă rog.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/a1cb85ff-365d-5916-a6f1-07a5cab8d485.mp3"}$j$::jsonb,$j${"value": "O cafea și o bere, vă rog."}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$mancare$p$, $p$listening$p$]),
('a6d40430-6965-5f1a-a3d5-f3c284de9bc2'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','writing','cloze',$p$Completa con la palabra que significa «queso».$p$,$j${"text": "Pâine cu ___, vă rog."}$j$::jsonb,$j${"value": "brânză", "accepted": ["brânză", "brânza", "branza"]}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$mancare$p$, $p$writing$p$]),
('f52562e3-8241-51d1-9b8b-c95cfe61f623'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "O cafea și un ceai, vă rog.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/f52562e3-8241-51d1-9b8b-c95cfe61f623.mp3"}$j$::jsonb,$j${"expected": "O cafea și un ceai, vă rog."}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$mancare$p$, $p$speaking$p$]),
('19494eff-fe31-59f5-9ad0-20ee351e0b71'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','reading','match',$p$Empareja cada palabra rumana con su traducción.$p$,$j${"pairs": [{"en": "un pahar", "es": "un vaso"}, {"en": "o sticlă", "es": "una botella"}, {"en": "o masă", "es": "una mesa"}]}$j$::jsonb,$j${"pairs": [["un pahar", "un vaso"], ["o sticlă", "una botella"], ["o masă", "una mesa"]]}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$cafenea$p$, $p$reading$p$]),
('7f600e0e-c1f7-56ac-9a1c-7ba66f1a739f'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','reading','multiple_choice',$p$¿Cuál de estas fórmulas significa «por favor»?$p$,$j${"options": ["vă rog", "mulțumesc", "cu plăcere"]}$j$::jsonb,$j${"value": "vă rog"}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$cafenea$p$, $p$reading$p$]),
('6279ad6a-1968-503c-a33c-c24356a7c7d1'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Aș vrea o supă, vă rog.", "Aș vrea o ciorbă, vă rog.", "Aș vrea o bere, vă rog."], "say": "Aș vrea o supă, vă rog.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/6279ad6a-1968-503c-a33c-c24356a7c7d1.mp3"}$j$::jsonb,$j${"value": "Aș vrea o supă, vă rog."}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$cafenea$p$, $p$listening$p$]),
('243a9eff-7731-5f07-96c3-f353c0b9085e'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','writing','translation',$p$Traduce al rumano:$p$,$j${"source": "Quisiera un té, por favor."}$j$::jsonb,$j${"value": "Aș vrea un ceai, vă rog.", "accepted": ["Aș vrea un ceai, vă rog.", "Aș vrea un ceai, vă rog", "As vrea un ceai, va rog", "As vrea un ceai, va rog."]}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$cafenea$p$, $p$writing$p$]),
('85e5c2fe-cf6b-5fc8-95ee-ba0ca2fb8112'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Aș vrea o bere, vă rog.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/85e5c2fe-cf6b-5fc8-95ee-ba0ca2fb8112.mp3"}$j$::jsonb,$j${"expected": "Aș vrea o bere, vă rog."}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$cafenea$p$, $p$speaking$p$]),
('dd34438f-7918-5132-abf5-cb85a0a2f27a'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','reading','multiple_choice',$p$Le preguntas a un amigo «¿Quieres un té?». ¿Cuál es la forma correcta?$p$,$j${"options": ["Vrei un ceai?", "Vrea un ceai?", "Vreau un ceai?"]}$j$::jsonb,$j${"value": "Vrei un ceai?"}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$avrea$p$, $p$reading$p$]),
('8a962a83-553e-5074-8e0e-f3cfbfd82422'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Vreau un pahar cu apă.", "Vreau o sticlă cu apă.", "Vreau o supă cu pâine."], "say": "Vreau un pahar cu apă.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/8a962a83-553e-5074-8e0e-f3cfbfd82422.mp3"}$j$::jsonb,$j${"value": "Vreau un pahar cu apă."}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$avrea$p$, $p$listening$p$]),
('382ef291-e703-5ce2-88e2-c0264382cf37'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Vrei o ciorbă sau o supă?", "Vrei o cafea sau un ceai?", "Vrea o bere sau o cafea?"], "say": "Vrei o ciorbă sau o supă?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/382ef291-e703-5ce2-88e2-c0264382cf37.mp3"}$j$::jsonb,$j${"value": "Vrei o ciorbă sau o supă?"}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$avrea$p$, $p$listening$p$]),
('8d7f8b54-a2b4-5cad-b419-d9078080d3cc'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','writing','word_bank',$p$Ordena para decir «Quisiera una sopa y pan, por favor».$p$,$j${"tiles": ["Aș", "o", "pâine", "rog", "supă", "un", "vrea", "vreau", "vă", "și"]}$j$::jsonb,$j${"value": "Aș vrea o supă și pâine vă rog", "sequence": ["Aș", "vrea", "o", "supă", "și", "pâine", "vă", "rog"]}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$avrea$p$, $p$writing$p$]),
('2f2176a9-1d75-5636-b4e5-d30e8a854783'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','writing','reorder',$p$Ordena las palabras.$p$,$j${"tiles": ["apă", "cu", "două", "pahare", "Vrei"]}$j$::jsonb,$j${"value": "Vrei două pahare cu apă"}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$avrea$p$, $p$writing$p$]),
('1295baea-3452-5d90-a4c5-fac4f797a346'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','reading','multiple_choice',$p$¿Qué significa «Ceaiul este cald»?$p$,$j${"options": ["El té está caliente.", "El té es un caldo.", "El té está frío."]}$j$::jsonb,$j${"value": "El té está caliente."}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$nota$p$, $p$reading$p$]),
('560ff8c2-0d85-5213-b16b-35e60cd3c330'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Nota, vă rog. Mulțumesc!", "Apa, vă rog. Mulțumesc!", "O cafea, vă rog. Mulțumesc!"], "say": "Nota, vă rog. Mulțumesc!", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/560ff8c2-0d85-5213-b16b-35e60cd3c330.mp3"}$j$::jsonb,$j${"value": "Nota, vă rog. Mulțumesc!"}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$nota$p$, $p$listening$p$]),
('c87d2389-caa7-5998-950a-8e2b23e5205c'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','writing','cloze',$p$Al final de la comida pides la cuenta al camarero. Completa:$p$,$j${"text": "___, vă rog!"}$j$::jsonb,$j${"value": "Nota", "accepted": ["Nota", "nota", "Plata", "plata", "Nota de plată", "Nota de plata"]}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$nota$p$, $p$writing$p$]),
('f5e7f566-fb4d-5a8f-be0c-2451cd003bbc'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','writing','translation',$p$Traduce al rumano:$p$,$j${"source": "El vaso está en la mesa."}$j$::jsonb,$j${"value": "Paharul este pe masă.", "accepted": ["Paharul este pe masă.", "Paharul e pe masă.", "Paharul este pe masa", "Paharul e pe masa.", "Paharul este pe masa."]}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$nota$p$, $p$writing$p$]),
('3856b880-1d70-52df-863a-eaaab8b53a2f'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Nota, vă rog. Mulțumesc!", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/3856b880-1d70-52df-863a-eaaab8b53a2f.mp3"}$j$::jsonb,$j${"expected": "Nota, vă rog. Mulțumesc!"}$j$::jsonb,0.16,ARRAY[$p$unidad4$p$, $p$nota$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('af20614c-14b0-5589-91be-a5a2fcfeebed','3714c9d9-2f5d-55a4-85f8-03fcf8954167',1),
 ('af20614c-14b0-5589-91be-a5a2fcfeebed','a45cceb7-53d7-5892-8250-3b8967fa70d6',2),
 ('af20614c-14b0-5589-91be-a5a2fcfeebed','a1cb85ff-365d-5916-a6f1-07a5cab8d485',3),
 ('af20614c-14b0-5589-91be-a5a2fcfeebed','a6d40430-6965-5f1a-a3d5-f3c284de9bc2',4),
 ('af20614c-14b0-5589-91be-a5a2fcfeebed','f52562e3-8241-51d1-9b8b-c95cfe61f623',5),
 ('1134f2ce-fc16-5e25-ada6-08bdcd78c68a','19494eff-fe31-59f5-9ad0-20ee351e0b71',1),
 ('1134f2ce-fc16-5e25-ada6-08bdcd78c68a','7f600e0e-c1f7-56ac-9a1c-7ba66f1a739f',2),
 ('1134f2ce-fc16-5e25-ada6-08bdcd78c68a','6279ad6a-1968-503c-a33c-c24356a7c7d1',3),
 ('1134f2ce-fc16-5e25-ada6-08bdcd78c68a','243a9eff-7731-5f07-96c3-f353c0b9085e',4),
 ('1134f2ce-fc16-5e25-ada6-08bdcd78c68a','85e5c2fe-cf6b-5fc8-95ee-ba0ca2fb8112',5),
 ('103fd3b5-67ef-5f05-9e91-92503057059d','dd34438f-7918-5132-abf5-cb85a0a2f27a',1),
 ('103fd3b5-67ef-5f05-9e91-92503057059d','8a962a83-553e-5074-8e0e-f3cfbfd82422',2),
 ('103fd3b5-67ef-5f05-9e91-92503057059d','382ef291-e703-5ce2-88e2-c0264382cf37',3),
 ('103fd3b5-67ef-5f05-9e91-92503057059d','8d7f8b54-a2b4-5cad-b419-d9078080d3cc',4),
 ('103fd3b5-67ef-5f05-9e91-92503057059d','2f2176a9-1d75-5636-b4e5-d30e8a854783',5),
 ('4fc34ca5-795c-58c5-b1cf-61be72e3e983','1295baea-3452-5d90-a4c5-fac4f797a346',1),
 ('4fc34ca5-795c-58c5-b1cf-61be72e3e983','560ff8c2-0d85-5213-b16b-35e60cd3c330',2),
 ('4fc34ca5-795c-58c5-b1cf-61be72e3e983','c87d2389-caa7-5998-950a-8e2b23e5205c',3),
 ('4fc34ca5-795c-58c5-b1cf-61be72e3e983','f5e7f566-fb4d-5a8f-be0c-2451cd003bbc',4),
 ('4fc34ca5-795c-58c5-b1cf-61be72e3e983','3856b880-1d70-52df-863a-eaaab8b53a2f',5),
 ('68f0d2fb-e0a4-5def-b9e6-ea0e190e31c7','3714c9d9-2f5d-55a4-85f8-03fcf8954167',1),
 ('68f0d2fb-e0a4-5def-b9e6-ea0e190e31c7','a45cceb7-53d7-5892-8250-3b8967fa70d6',2),
 ('68f0d2fb-e0a4-5def-b9e6-ea0e190e31c7','19494eff-fe31-59f5-9ad0-20ee351e0b71',3),
 ('68f0d2fb-e0a4-5def-b9e6-ea0e190e31c7','a6d40430-6965-5f1a-a3d5-f3c284de9bc2',4),
 ('68f0d2fb-e0a4-5def-b9e6-ea0e190e31c7','243a9eff-7731-5f07-96c3-f353c0b9085e',5),
 ('68f0d2fb-e0a4-5def-b9e6-ea0e190e31c7','8d7f8b54-a2b4-5cad-b419-d9078080d3cc',6),
 ('68f0d2fb-e0a4-5def-b9e6-ea0e190e31c7','a1cb85ff-365d-5916-a6f1-07a5cab8d485',7),
 ('68f0d2fb-e0a4-5def-b9e6-ea0e190e31c7','6279ad6a-1968-503c-a33c-c24356a7c7d1',8),
 ('68f0d2fb-e0a4-5def-b9e6-ea0e190e31c7','f52562e3-8241-51d1-9b8b-c95cfe61f623',9),
 ('68f0d2fb-e0a4-5def-b9e6-ea0e190e31c7','85e5c2fe-cf6b-5fc8-95ee-ba0ca2fb8112',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('4ee0e906-0e4b-5900-82b7-6ce545f3a973','20000000-0000-0000-0000-000000000007',$p$o cafea$p$,$p$un café$p$,181,'sustantivo'),
 ('2529eb2d-c4fc-57e4-b643-3c1dd5d6606f','20000000-0000-0000-0000-000000000007',$p$un ceai$p$,$p$un té$p$,182,'sustantivo'),
 ('2af5938a-3fc4-5b99-b54e-715a45a162ad','20000000-0000-0000-0000-000000000007',$p$o bere$p$,$p$una cerveza$p$,183,'sustantivo'),
 ('9e8135df-a336-5cc9-93ec-d7e391a25553','20000000-0000-0000-0000-000000000007',$p$o apă$p$,$p$agua$p$,184,'sustantivo'),
 ('87ca598e-860b-5a93-a20a-2b9662a8c693','20000000-0000-0000-0000-000000000007',$p$o pâine$p$,$p$pan$p$,185,'sustantivo'),
 ('a8151e73-a5fa-5b67-8490-84e80e91e527','20000000-0000-0000-0000-000000000007',$p$o brânză$p$,$p$queso$p$,186,'sustantivo'),
 ('dcfb0cb8-144c-543b-ad2e-eaac7ff1ea0d','20000000-0000-0000-0000-000000000007',$p$carne$p$,$p$carne$p$,187,'sustantivo'),
 ('9e9329d1-98d6-5e52-bbc3-11d40f1ec472','20000000-0000-0000-0000-000000000007',$p$o supă$p$,$p$una sopa$p$,188,'sustantivo'),
 ('a5e64a88-4608-5dca-a58f-54284c49a6e7','20000000-0000-0000-0000-000000000007',$p$o ciorbă$p$,$p$una sopa agria rumana$p$,189,'sustantivo'),
 ('4b3a7215-7a5b-576e-ace6-7f544f5a93ac','20000000-0000-0000-0000-000000000007',$p$un pahar$p$,$p$un vaso$p$,190,'sustantivo'),
 ('8a985bfc-be55-524b-8cda-995b297c509e','20000000-0000-0000-0000-000000000007',$p$o sticlă$p$,$p$una botella$p$,191,'sustantivo'),
 ('52d759cc-fa8f-5bf4-8ca5-94cac24f3a01','20000000-0000-0000-0000-000000000007',$p$o masă$p$,$p$mesa; comida$p$,192,'sustantivo'),
 ('40cc8fa7-8886-5dda-aecf-2b4450257987','20000000-0000-0000-0000-000000000007',$p$o plată$p$,$p$pago$p$,193,'sustantivo'),
 ('a50490c0-32ca-5259-ba8f-d4abb2465b1a','20000000-0000-0000-0000-000000000007',$p$o notă$p$,$p$la nota; la cuenta (nota de plată)$p$,194,'sustantivo'),
 ('e0c610e7-d4ca-538a-9d83-4ad32fffc7f4','20000000-0000-0000-0000-000000000007',$p$cald$p$,$p$caliente$p$,195,'adjetivo'),
 ('3cfe8b2b-58db-5671-99d8-36adbf1262fc','20000000-0000-0000-0000-000000000007',$p$a vrea$p$,$p$querer$p$,196,'verbo'),
 ('b421dd9b-8bd8-5f7f-abe2-4b518e1cc14b','20000000-0000-0000-0000-000000000007',$p$vă rog$p$,$p$por favor$p$,197,'interjeccion'),
 ('af74bd92-a9b6-50f0-a522-c82a10ccc12c','20000000-0000-0000-0000-000000000007',$p$mulțumesc$p$,$p$gracias$p$,198,'interjeccion')
on conflict (id) do nothing;

-- ── Unidad 5 (A1·ro): El día y la hora ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('52b25a80-0bba-53a8-8815-6cdd4bf3a00a','20000000-0000-0000-0000-000000000007','A1',5,$p$El día y la hora$p$,'#9B51E0','schedule')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('14a6f8b1-97ba-5250-a81c-3c9e0973e042','52b25a80-0bba-53a8-8815-6cdd4bf3a00a',1,$p$¿Qué hora es?$p$,$p$¿Qué hora es?$p$,'lesson',15),
 ('e638e9e3-873d-5e81-9c41-0c5f2db76283','52b25a80-0bba-53a8-8815-6cdd4bf3a00a',2,$p$Y cuarto, y media, menos cuarto$p$,$p$Y cuarto, y media, menos cuarto$p$,'lesson',15),
 ('af49bb42-732b-5c4f-8587-3bf0b21d6efb','52b25a80-0bba-53a8-8815-6cdd4bf3a00a',3,$p$Los días de la semana$p$,$p$Los días de la semana$p$,'lesson',15),
 ('73d2839d-74fd-5f55-8116-4d9d328f6de8','52b25a80-0bba-53a8-8815-6cdd4bf3a00a',4,$p$Mi rutina: me despierto y me acuesto$p$,$p$Mi rutina: me despierto y me acuesto$p$,'lesson',15),
 ('6385751a-1ceb-5a04-ad08-68cd6d8c69d6','52b25a80-0bba-53a8-8815-6cdd4bf3a00a',5,$p$🏁 Checkpoint Unitatea 5$p$,$p$Repasa preguntar y decir la hora (y cuarto, y media, menos cuarto), los días de la semana, las partes del día y la rutina diaria en presente.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('69901bd4-5ab2-5203-b83a-d935298b86c3','20000000-0000-0000-0000-000000000007','checkpoint','A1','52b25a80-0bba-53a8-8815-6cdd4bf3a00a',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('74dae5c9-d6e2-530a-86a8-69cb4460f92a'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','reading','match',$p$Empareja cada palabra rumana con su significado.$p$,$j${"pairs": [{"en": "ceas", "es": "el reloj"}, {"en": "oră", "es": "la hora"}, {"en": "dimineață", "es": "la mañana"}]}$j$::jsonb,$j${"pairs": [["ceas", "el reloj"], ["oră", "la hora"], ["dimineață", "la mañana"]]}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$cat_e_ceasul$p$, $p$reading$p$]),
('fb433c48-d2f9-586f-b9ce-e8e32db80d30'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','reading','multiple_choice',$p$Completa: «___ ora trei.» = «Son las tres.»$p$,$j${"options": ["Este", "Sunt", "Are"]}$j$::jsonb,$j${"value": "Este"}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$cat_e_ceasul$p$, $p$reading$p$]),
('d2a16b0f-27db-5c7a-90b3-604acda1f940'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','writing','cloze',$p$Completa la pregunta «¿Qué hora es?». Recuerda: el rumano pega el artículo al final de la palabra.$p$,$j${"text": "Cât e ___?"}$j$::jsonb,$j${"value": "ceasul", "accepted": ["ceasul", "ora"]}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$cat_e_ceasul$p$, $p$writing$p$]),
('4fa49277-883c-5517-92da-4d7594ede003'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Este ora șapte.", "Este ora zece.", "Este ora unu."], "say": "Este ora șapte.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/4fa49277-883c-5517-92da-4d7594ede003.mp3"}$j$::jsonb,$j${"value": "Este ora șapte."}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$cat_e_ceasul$p$, $p$listening$p$]),
('eebdcc35-52e3-53ec-a177-2acb0ac8ee9c'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Cât e ceasul? Este ora trei.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/eebdcc35-52e3-53ec-a177-2acb0ac8ee9c.mp3"}$j$::jsonb,$j${"expected": "Cât e ceasul? Este ora trei."}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$cat_e_ceasul$p$, $p$speaking$p$]),
('5f1703af-9de5-5e58-9385-5ae20d863e99'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','reading','multiple_choice',$p$¿Cómo se dice «Son las tres y media»? (el rumano cuenta como el español)$p$,$j${"options": ["Este trei și jumătate.", "Este trei și un sfert.", "Este patru fără un sfert."]}$j$::jsonb,$j${"value": "Este trei și jumătate."}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$sfert_si_jumatate$p$, $p$reading$p$]),
('16eab516-27ac-553d-ac0e-4525dff61a93'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Este două și jumătate.", "Este două și un sfert.", "Este două fără un sfert."], "say": "Este două și jumătate.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/16eab516-27ac-553d-ac0e-4525dff61a93.mp3"}$j$::jsonb,$j${"value": "Este două și jumătate."}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$sfert_si_jumatate$p$, $p$listening$p$]),
('0ab73b57-7c4e-59a6-9193-71b7a7e4b0e9'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Este cinci fără un sfert.", "Este cinci și un sfert.", "Este cinci și jumătate."], "say": "Este cinci fără un sfert.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/0ab73b57-7c4e-59a6-9193-71b7a7e4b0e9.mp3"}$j$::jsonb,$j${"value": "Este cinci fără un sfert."}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$sfert_si_jumatate$p$, $p$listening$p$]),
('bcb58e26-e34a-5e5e-ac6b-c93073df1af3'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','writing','word_bank',$p$Ordena para decir «Son las ocho y cuarto».$p$,$j${"tiles": ["Este", "fără", "jumătate", "opt", "sfert", "un", "și"]}$j$::jsonb,$j${"value": "Este opt și un sfert", "sequence": ["Este", "opt", "și", "un", "sfert"]}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$sfert_si_jumatate$p$, $p$writing$p$]),
('a31c9e5f-915d-587b-a1c2-254fe8707b6f'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','writing','translation',$p$Traduce al rumano:$p$,$j${"source": "Son las siete menos cuarto."}$j$::jsonb,$j${"value": "Este șapte fără un sfert.", "accepted": ["Este șapte fără un sfert.", "E șapte fără un sfert.", "Este ora șapte fără un sfert.", "E sapte fara un sfert.", "Este ora sapte fara un sfert.", "Este sapte fara un sfert."]}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$sfert_si_jumatate$p$, $p$writing$p$]),
('5627f4f7-902a-5a31-8132-f6d0a5c47897'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','reading','match',$p$Empareja cada día de la semana con su significado.$p$,$j${"pairs": [{"en": "luni", "es": "lunes"}, {"en": "miercuri", "es": "miércoles"}, {"en": "sâmbătă", "es": "sábado"}]}$j$::jsonb,$j${"pairs": [["luni", "lunes"], ["miercuri", "miércoles"], ["sâmbătă", "sábado"]]}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$zilele_saptamanii$p$, $p$reading$p$]),
('86c660f3-96bd-58ea-b8da-6aa811eb0ccd'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','reading','multiple_choice',$p$¿Qué día viene después de «joi» (jueves)?$p$,$j${"options": ["vineri", "miercuri", "duminică"]}$j$::jsonb,$j${"value": "vineri"}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$zilele_saptamanii$p$, $p$reading$p$]),
('307e1382-5e50-5635-9ea7-66ee31925dac'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Astăzi este marți.", "Astăzi este joi.", "Astăzi este duminică."], "say": "Astăzi este marți.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/307e1382-5e50-5635-9ea7-66ee31925dac.mp3"}$j$::jsonb,$j${"value": "Astăzi este marți."}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$zilele_saptamanii$p$, $p$listening$p$]),
('dbfcd116-b7b8-5928-b8b7-eea56be948e9'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','writing','translation',$p$Traduce al rumano (los días se escriben en minúscula):$p$,$j${"source": "Hoy es miércoles."}$j$::jsonb,$j${"value": "Astăzi este miercuri.", "accepted": ["Astăzi este miercuri.", "Astăzi e miercuri.", "Azi este miercuri.", "Azi e miercuri.", "Astazi e miercuri.", "Astazi este miercuri."]}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$zilele_saptamanii$p$, $p$writing$p$]),
('5fa93048-a2ba-525d-92f3-ab6f25f5dde2'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Sâmbătă după-amiaza nu lucrez.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/5fa93048-a2ba-525d-92f3-ab6f25f5dde2.mp3"}$j$::jsonb,$j${"expected": "Sâmbătă după-amiaza nu lucrez."}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$zilele_saptamanii$p$, $p$speaking$p$]),
('1cb919ea-a644-5d84-8a0e-6f5f2bc175d3'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','reading','multiple_choice',$p$«Mă culc la ora unsprezece» significa…$p$,$j${"options": ["Me acuesto a las once.", "Me despierto a las once.", "Me lavo a las once."]}$j$::jsonb,$j${"value": "Me acuesto a las once."}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$rutina_zilnica$p$, $p$reading$p$]),
('a00c243d-61eb-54c1-9500-ccac72838b8d'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','writing','cloze',$p$Completa: «Por la mañana me despierto a las siete.» No olvides el pronombre.$p$,$j${"text": "Dimineața ___ la ora șapte."}$j$::jsonb,$j${"value": "mă trezesc", "accepted": ["mă trezesc", "ma trezesc"]}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$rutina_zilnica$p$, $p$writing$p$]),
('410a0444-1922-5e9e-b39e-852f0e85f4a4'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["La ce oră te culci seara?", "La ce oră te trezești dimineața?", "La ce oră mănânci seara?"], "say": "La ce oră te culci seara?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/410a0444-1922-5e9e-b39e-852f0e85f4a4.mp3"}$j$::jsonb,$j${"value": "La ce oră te culci seara?"}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$rutina_zilnica$p$, $p$listening$p$]),
('faca01e7-bf0f-575a-9e47-2b8784094de5'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','writing','reorder',$p$Ordena empezando por «La»: «¿A qué hora trabajas el lunes?».$p$,$j${"tiles": ["ce", "La", "lucrezi", "luni", "oră"]}$j$::jsonb,$j${"value": "La ce oră lucrezi luni"}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$rutina_zilnica$p$, $p$writing$p$]),
('8c96d95c-7730-50f2-bd83-5af254b71aaa'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Dimineața mă trezesc la șapte, mănânc și lucrez.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/8c96d95c-7730-50f2-bd83-5af254b71aaa.mp3"}$j$::jsonb,$j${"expected": "Dimineața mă trezesc la șapte, mănânc și lucrez."}$j$::jsonb,0.16,ARRAY[$p$unidad5$p$, $p$rutina_zilnica$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('14a6f8b1-97ba-5250-a81c-3c9e0973e042','74dae5c9-d6e2-530a-86a8-69cb4460f92a',1),
 ('14a6f8b1-97ba-5250-a81c-3c9e0973e042','fb433c48-d2f9-586f-b9ce-e8e32db80d30',2),
 ('14a6f8b1-97ba-5250-a81c-3c9e0973e042','d2a16b0f-27db-5c7a-90b3-604acda1f940',3),
 ('14a6f8b1-97ba-5250-a81c-3c9e0973e042','4fa49277-883c-5517-92da-4d7594ede003',4),
 ('14a6f8b1-97ba-5250-a81c-3c9e0973e042','eebdcc35-52e3-53ec-a177-2acb0ac8ee9c',5),
 ('e638e9e3-873d-5e81-9c41-0c5f2db76283','5f1703af-9de5-5e58-9385-5ae20d863e99',1),
 ('e638e9e3-873d-5e81-9c41-0c5f2db76283','16eab516-27ac-553d-ac0e-4525dff61a93',2),
 ('e638e9e3-873d-5e81-9c41-0c5f2db76283','0ab73b57-7c4e-59a6-9193-71b7a7e4b0e9',3),
 ('e638e9e3-873d-5e81-9c41-0c5f2db76283','bcb58e26-e34a-5e5e-ac6b-c93073df1af3',4),
 ('e638e9e3-873d-5e81-9c41-0c5f2db76283','a31c9e5f-915d-587b-a1c2-254fe8707b6f',5),
 ('af49bb42-732b-5c4f-8587-3bf0b21d6efb','5627f4f7-902a-5a31-8132-f6d0a5c47897',1),
 ('af49bb42-732b-5c4f-8587-3bf0b21d6efb','86c660f3-96bd-58ea-b8da-6aa811eb0ccd',2),
 ('af49bb42-732b-5c4f-8587-3bf0b21d6efb','307e1382-5e50-5635-9ea7-66ee31925dac',3),
 ('af49bb42-732b-5c4f-8587-3bf0b21d6efb','dbfcd116-b7b8-5928-b8b7-eea56be948e9',4),
 ('af49bb42-732b-5c4f-8587-3bf0b21d6efb','5fa93048-a2ba-525d-92f3-ab6f25f5dde2',5),
 ('73d2839d-74fd-5f55-8116-4d9d328f6de8','1cb919ea-a644-5d84-8a0e-6f5f2bc175d3',1),
 ('73d2839d-74fd-5f55-8116-4d9d328f6de8','a00c243d-61eb-54c1-9500-ccac72838b8d',2),
 ('73d2839d-74fd-5f55-8116-4d9d328f6de8','410a0444-1922-5e9e-b39e-852f0e85f4a4',3),
 ('73d2839d-74fd-5f55-8116-4d9d328f6de8','faca01e7-bf0f-575a-9e47-2b8784094de5',4),
 ('73d2839d-74fd-5f55-8116-4d9d328f6de8','8c96d95c-7730-50f2-bd83-5af254b71aaa',5),
 ('6385751a-1ceb-5a04-ad08-68cd6d8c69d6','74dae5c9-d6e2-530a-86a8-69cb4460f92a',1),
 ('6385751a-1ceb-5a04-ad08-68cd6d8c69d6','fb433c48-d2f9-586f-b9ce-e8e32db80d30',2),
 ('6385751a-1ceb-5a04-ad08-68cd6d8c69d6','5f1703af-9de5-5e58-9385-5ae20d863e99',3),
 ('6385751a-1ceb-5a04-ad08-68cd6d8c69d6','d2a16b0f-27db-5c7a-90b3-604acda1f940',4),
 ('6385751a-1ceb-5a04-ad08-68cd6d8c69d6','bcb58e26-e34a-5e5e-ac6b-c93073df1af3',5),
 ('6385751a-1ceb-5a04-ad08-68cd6d8c69d6','a31c9e5f-915d-587b-a1c2-254fe8707b6f',6),
 ('6385751a-1ceb-5a04-ad08-68cd6d8c69d6','4fa49277-883c-5517-92da-4d7594ede003',7),
 ('6385751a-1ceb-5a04-ad08-68cd6d8c69d6','16eab516-27ac-553d-ac0e-4525dff61a93',8),
 ('6385751a-1ceb-5a04-ad08-68cd6d8c69d6','eebdcc35-52e3-53ec-a177-2acb0ac8ee9c',9),
 ('6385751a-1ceb-5a04-ad08-68cd6d8c69d6','5fa93048-a2ba-525d-92f3-ab6f25f5dde2',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('32c1dbb3-1d1b-5ea2-b388-82f65ea24624','20000000-0000-0000-0000-000000000007',$p$ceas$p$,$p$el reloj$p$,201,'sustantivo'),
 ('e6f9987c-0e40-5f92-a160-adc377d1ba2c','20000000-0000-0000-0000-000000000007',$p$oră$p$,$p$la hora$p$,202,'sustantivo'),
 ('7c200b05-e4e6-5bcb-87ea-65b5bac73a3b','20000000-0000-0000-0000-000000000007',$p$sfert$p$,$p$el cuarto (de hora)$p$,203,'sustantivo'),
 ('cc7da4d0-ee63-5b9f-98f7-b69148a7dd57','20000000-0000-0000-0000-000000000007',$p$jumătate$p$,$p$la mitad, la media$p$,204,'sustantivo'),
 ('7bfd58bb-2757-56e4-bd91-b4ce92121a3d','20000000-0000-0000-0000-000000000007',$p$luni$p$,$p$lunes$p$,205,'sustantivo'),
 ('0bdb85b6-83eb-566a-ba99-02a6ee0576a1','20000000-0000-0000-0000-000000000007',$p$marți$p$,$p$martes$p$,206,'sustantivo'),
 ('c5aefa7d-5f8f-5b66-b14c-3301cbacfc80','20000000-0000-0000-0000-000000000007',$p$miercuri$p$,$p$miércoles$p$,207,'sustantivo'),
 ('254d4cbe-ea30-5660-821e-513867531838','20000000-0000-0000-0000-000000000007',$p$joi$p$,$p$jueves$p$,208,'sustantivo'),
 ('9f93aea7-734d-52e1-817b-636cb0b5dac4','20000000-0000-0000-0000-000000000007',$p$vineri$p$,$p$viernes$p$,209,'sustantivo'),
 ('4d315bb1-b68d-512c-a30b-0c598196b708','20000000-0000-0000-0000-000000000007',$p$sâmbătă$p$,$p$sábado$p$,210,'sustantivo'),
 ('8869f38c-0b14-5ca5-8c10-9511ed85f7eb','20000000-0000-0000-0000-000000000007',$p$duminică$p$,$p$domingo$p$,211,'sustantivo'),
 ('95a033a3-39f9-5e34-a537-e7049a04bd9d','20000000-0000-0000-0000-000000000007',$p$dimineață$p$,$p$la mañana$p$,212,'sustantivo'),
 ('938f78c8-7515-56bf-b861-a0d4ba792995','20000000-0000-0000-0000-000000000007',$p$după-amiază$p$,$p$la tarde$p$,213,'sustantivo'),
 ('a858aa61-7afe-5701-9713-fb9ab37b23f1','20000000-0000-0000-0000-000000000007',$p$seară$p$,$p$la tarde-noche$p$,214,'sustantivo'),
 ('e18e99b7-26d3-56b9-8147-0dfa5e2e4280','20000000-0000-0000-0000-000000000007',$p$a se trezi$p$,$p$despertarse$p$,215,'verbo'),
 ('9f0fa030-0503-5133-ae57-b634f9422ec2','20000000-0000-0000-0000-000000000007',$p$a se culca$p$,$p$acostarse$p$,216,'verbo'),
 ('7b9f9e9b-2054-57de-b6ff-fc7ae04b4cda','20000000-0000-0000-0000-000000000007',$p$a mânca$p$,$p$comer$p$,217,'verbo'),
 ('f6943d7f-d942-5330-a21d-925a5a11938a','20000000-0000-0000-0000-000000000007',$p$a lucra$p$,$p$trabajar$p$,218,'verbo')
on conflict (id) do nothing;

-- ── Unidad 6 (A1·ro): La ciudad y direcciones ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('c62b5247-65ef-5eef-a72f-c9aad79dfd1e','20000000-0000-0000-0000-000000000007','A1',6,$p$La ciudad y direcciones$p$,'#56CCF2','map')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('f74b5fe9-429f-5f16-889b-65da856e1a74','c62b5247-65ef-5eef-a72f-c9aad79dfd1e',1,$p$Lugares de la ciudad$p$,$p$Lugares de la ciudad$p$,'lesson',15),
 ('8a8bd0a4-9efa-593c-a41f-21be4be18598','c62b5247-65ef-5eef-a72f-c9aad79dfd1e',2,$p$¿Dónde está? este y sunt$p$,$p$¿Dónde está? este y sunt$p$,'lesson',15),
 ('f241131f-419d-5323-870d-67e96efa91ca','c62b5247-65ef-5eef-a72f-c9aad79dfd1e',3,$p$Pedir y dar direcciones$p$,$p$Pedir y dar direcciones$p$,'lesson',15),
 ('590bcca0-b72c-56b8-a434-c635b34dfba1','c62b5247-65ef-5eef-a72f-c9aad79dfd1e',4,$p$Merg la, sunt în, pe strada$p$,$p$Merg la, sunt în, pe strada$p$,'lesson',15),
 ('32c3e3a8-1468-5d90-97b0-0aafe4f00787','c62b5247-65ef-5eef-a72f-c9aad79dfd1e',5,$p$🏁 Checkpoint Unitatea 6$p$,$p$Repasa los lugares de la ciudad con su género, decir dónde están con «este/sunt» y «se află», pedir y dar direcciones y usar «la», «în» y «pe».$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('86a97538-b9b0-5055-a631-0f2742b1486c','20000000-0000-0000-0000-000000000007','checkpoint','A1','c62b5247-65ef-5eef-a72f-c9aad79dfd1e',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('a4a5d5d2-4dc7-5959-86aa-3d85c525f4c7'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','reading','match',$p$Empareja cada lugar con su traducción. Fíjate en «un» o «o»: te dice el género.$p$,$j${"pairs": [{"en": "o gară", "es": "una estación"}, {"en": "un muzeu", "es": "un museo"}, {"en": "o piață", "es": "una plaza / un mercado"}]}$j$::jsonb,$j${"pairs": [["o gară", "una estación"], ["un muzeu", "un museo"], ["o piață", "una plaza / un mercado"]]}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$locuri_oras$p$, $p$reading$p$]),
('3b598f84-42a4-5add-840e-4a685a2d8d77'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','reading','multiple_choice',$p$¿Cuál es la forma correcta de «una tienda»?$p$,$j${"options": ["un magazin", "o magazin", "un magazine"]}$j$::jsonb,$j${"value": "un magazin"}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$locuri_oras$p$, $p$reading$p$]),
('5fd5cdcc-653f-55e1-8ba9-489c35322634'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["În oraș sunt două muzee.", "În oraș sunt două hoteluri.", "În oraș este un muzeu."], "say": "În oraș sunt două muzee.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/5fd5cdcc-653f-55e1-8ba9-489c35322634.mp3"}$j$::jsonb,$j${"value": "În oraș sunt două muzee."}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$locuri_oras$p$, $p$listening$p$]),
('5b840afc-e909-5329-b1b6-a90dddd0fab9'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','writing','translation',$p$Traduce al rumano:$p$,$j${"source": "En la ciudad hay un parque."}$j$::jsonb,$j${"value": "În oraș este un parc.", "accepted": ["În oraș este un parc.", "În oraș este un parc", "În oraș e un parc.", "În oraș se află un parc.", "In oras e un parc.", "In oras este un parc", "In oras este un parc.", "In oras se afla un parc."]}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$locuri_oras$p$, $p$writing$p$]),
('3bedddc3-8366-55dc-980f-63cc4fd513d0'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "În oraș sunt un parc și un muzeu.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/3bedddc3-8366-55dc-980f-63cc4fd513d0.mp3"}$j$::jsonb,$j${"expected": "În oraș sunt un parc și un muzeu."}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$locuri_oras$p$, $p$speaking$p$]),
('d0f568b4-2513-5337-9876-aa3a64b33a7d'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','reading','match',$p$Empareja cada frase con su traducción.$p$,$j${"pairs": [{"en": "Unde este gara?", "es": "¿Dónde está la estación?"}, {"en": "Unde sunt magazinele?", "es": "¿Dónde están las tiendas?"}, {"en": "Hotelul este lângă gară.", "es": "El hotel está delante de la estación."}]}$j$::jsonb,$j${"pairs": [["Unde este gara?", "¿Dónde está la estación?"], ["Unde sunt magazinele?", "¿Dónde están las tiendas?"], ["Hotelul este lângă gară.", "El hotel está delante de la estación."]]}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$unde_este$p$, $p$reading$p$]),
('462386bf-7fd6-56ae-b139-0ee572192f4f'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','reading','multiple_choice',$p$¿Cómo se dice «el museo» en rumano? Recuerda: el artículo determinado se pega al final de la palabra.$p$,$j${"options": ["muzeul", "muzeu", "un muzeu"]}$j$::jsonb,$j${"value": "muzeul"}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$unde_este$p$, $p$reading$p$]),
('2f9028f4-fb81-5db0-8720-f7c8e07420c7'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Farmacia este lângă gară.", "Farmacia este lângă parc.", "Hotelul este lângă gară."], "say": "Farmacia este lângă gară.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/2f9028f4-fb81-5db0-8720-f7c8e07420c7.mp3"}$j$::jsonb,$j${"value": "Farmacia este lângă gară."}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$unde_este$p$, $p$listening$p$]),
('ed485653-0b3c-51d2-b56f-f1d18be1587e'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','writing','cloze',$p$Completa: «En la ciudad hay tres farmacias.»$p$,$j${"text": "În oraș ___ trei farmacii."}$j$::jsonb,$j${"value": "sunt", "accepted": ["sunt", "se află", "se afla"]}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$unde_este$p$, $p$writing$p$]),
('97d5221d-a9c7-5d87-a54d-bbfc1ef7238e'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Unde se află gara, vă rog?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/97d5221d-a9c7-5d87-a54d-bbfc1ef7238e.mp3"}$j$::jsonb,$j${"expected": "Unde se află gara, vă rog?"}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$unde_este$p$, $p$speaking$p$]),
('3bd08455-ee90-59dc-ad6f-4549cd9b7101'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Mergeți drept înainte.", "Mergeți la dreapta.", "Mergeți la stânga."], "say": "Mergeți drept înainte.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/3bd08455-ee90-59dc-ad6f-4549cd9b7101.mp3"}$j$::jsonb,$j${"value": "Mergeți drept înainte."}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$indicatii$p$, $p$listening$p$]),
('539e7bdd-29c7-53ac-8941-a38413ed9e67'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Luați prima stradă la stânga.", "Luați prima stradă la dreapta.", "Luați a doua stradă la stânga."], "say": "Luați prima stradă la stânga.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/539e7bdd-29c7-53ac-8941-a38413ed9e67.mp3"}$j$::jsonb,$j${"value": "Luați prima stradă la stânga."}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$indicatii$p$, $p$listening$p$]),
('82c89594-bc68-5b07-9b1f-ff1457f31965'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','writing','word_bank',$p$Ordena para decir «La farmacia está a la derecha».$p$,$j${"tiles": ["dreapta", "este", "Farmacia", "la", "stânga"]}$j$::jsonb,$j${"value": "Farmacia este la dreapta", "sequence": ["Farmacia", "este", "la", "dreapta"]}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$indicatii$p$, $p$writing$p$]),
('d949aa75-07d9-580f-8e69-6376fa4f1b21'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','writing','translation',$p$Traduce al rumano:$p$,$j${"source": "El museo está enfrente del parque."}$j$::jsonb,$j${"value": "Muzeul este vizavi de parc.", "accepted": ["Muzeul este vizavi de parc.", "Muzeul este vizavi de parc", "Muzeul se află vizavi de parc.", "Muzeul se afla vizavi de parc."]}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$indicatii$p$, $p$writing$p$]),
('80173f94-c415-52bb-8de4-b07fae083d59'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Mergeți pe strada Mare, apoi la stânga.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/80173f94-c415-52bb-8de4-b07fae083d59.mp3"}$j$::jsonb,$j${"expected": "Mergeți pe strada Mare, apoi la stânga."}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$indicatii$p$, $p$speaking$p$]),
('13784c56-03a7-547d-b42f-55265cdc51be'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','reading','multiple_choice',$p$«Voy a la tienda». ¿Cuál es la forma correcta?$p$,$j${"options": ["Merg la magazin.", "Merg la magazinul.", "Mergem la magazin."]}$j$::jsonb,$j${"value": "Merg la magazin."}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$la_in_pe$p$, $p$reading$p$]),
('b7704050-7c3e-55d7-a2bf-eeae294d363a'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','writing','cloze',$p$Completa con el artículo pegado al final: «El museo está cerca».$p$,$j${"text": "___ este aproape."}$j$::jsonb,$j${"value": "Muzeul", "accepted": ["Muzeul", "muzeul"]}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$la_in_pe$p$, $p$writing$p$]),
('555026e7-0661-514e-9199-a4afd6535c03'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Sunt în parc.", "Merg la bancă.", "Sunt în piață."], "say": "Sunt în parc.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/555026e7-0661-514e-9199-a4afd6535c03.mp3"}$j$::jsonb,$j${"value": "Sunt în parc."}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$la_in_pe$p$, $p$listening$p$]),
('9c0228fe-a678-5edd-84b4-d0a1c2d378f2'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','reading','multiple_choice',$p$«Los niños juegan DENTRO del parque». ¿Cuál es la forma correcta?$p$,$j${"options": ["Copiii se joacă în parc.", "Copiii se joacă la parc.", "Copiii se joacă pe parc."]}$j$::jsonb,$j${"value": "Copiii se joacă în parc."}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$la_in_pe$p$, $p$reading$p$]),
('75a44113-c769-5b66-b6be-9cac705108b3'::uuid,'20000000-0000-0000-0000-000000000007'::uuid,'A1','writing','reorder',$p$Ordena las palabras para decir «El hotel está en la calle Mare».$p$,$j${"tiles": ["este", "Hotelul", "Mare", "pe", "strada"]}$j$::jsonb,$j${"value": "Hotelul este pe strada Mare"}$j$::jsonb,0.16,ARRAY[$p$unidad6$p$, $p$la_in_pe$p$, $p$writing$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('f74b5fe9-429f-5f16-889b-65da856e1a74','a4a5d5d2-4dc7-5959-86aa-3d85c525f4c7',1),
 ('f74b5fe9-429f-5f16-889b-65da856e1a74','3b598f84-42a4-5add-840e-4a685a2d8d77',2),
 ('f74b5fe9-429f-5f16-889b-65da856e1a74','5fd5cdcc-653f-55e1-8ba9-489c35322634',3),
 ('f74b5fe9-429f-5f16-889b-65da856e1a74','5b840afc-e909-5329-b1b6-a90dddd0fab9',4),
 ('f74b5fe9-429f-5f16-889b-65da856e1a74','3bedddc3-8366-55dc-980f-63cc4fd513d0',5),
 ('8a8bd0a4-9efa-593c-a41f-21be4be18598','d0f568b4-2513-5337-9876-aa3a64b33a7d',1),
 ('8a8bd0a4-9efa-593c-a41f-21be4be18598','462386bf-7fd6-56ae-b139-0ee572192f4f',2),
 ('8a8bd0a4-9efa-593c-a41f-21be4be18598','2f9028f4-fb81-5db0-8720-f7c8e07420c7',3),
 ('8a8bd0a4-9efa-593c-a41f-21be4be18598','ed485653-0b3c-51d2-b56f-f1d18be1587e',4),
 ('8a8bd0a4-9efa-593c-a41f-21be4be18598','97d5221d-a9c7-5d87-a54d-bbfc1ef7238e',5),
 ('f241131f-419d-5323-870d-67e96efa91ca','3bd08455-ee90-59dc-ad6f-4549cd9b7101',1),
 ('f241131f-419d-5323-870d-67e96efa91ca','539e7bdd-29c7-53ac-8941-a38413ed9e67',2),
 ('f241131f-419d-5323-870d-67e96efa91ca','82c89594-bc68-5b07-9b1f-ff1457f31965',3),
 ('f241131f-419d-5323-870d-67e96efa91ca','d949aa75-07d9-580f-8e69-6376fa4f1b21',4),
 ('f241131f-419d-5323-870d-67e96efa91ca','80173f94-c415-52bb-8de4-b07fae083d59',5),
 ('590bcca0-b72c-56b8-a434-c635b34dfba1','13784c56-03a7-547d-b42f-55265cdc51be',1),
 ('590bcca0-b72c-56b8-a434-c635b34dfba1','b7704050-7c3e-55d7-a2bf-eeae294d363a',2),
 ('590bcca0-b72c-56b8-a434-c635b34dfba1','555026e7-0661-514e-9199-a4afd6535c03',3),
 ('590bcca0-b72c-56b8-a434-c635b34dfba1','9c0228fe-a678-5edd-84b4-d0a1c2d378f2',4),
 ('590bcca0-b72c-56b8-a434-c635b34dfba1','75a44113-c769-5b66-b6be-9cac705108b3',5),
 ('32c3e3a8-1468-5d90-97b0-0aafe4f00787','a4a5d5d2-4dc7-5959-86aa-3d85c525f4c7',1),
 ('32c3e3a8-1468-5d90-97b0-0aafe4f00787','3b598f84-42a4-5add-840e-4a685a2d8d77',2),
 ('32c3e3a8-1468-5d90-97b0-0aafe4f00787','d0f568b4-2513-5337-9876-aa3a64b33a7d',3),
 ('32c3e3a8-1468-5d90-97b0-0aafe4f00787','5b840afc-e909-5329-b1b6-a90dddd0fab9',4),
 ('32c3e3a8-1468-5d90-97b0-0aafe4f00787','ed485653-0b3c-51d2-b56f-f1d18be1587e',5),
 ('32c3e3a8-1468-5d90-97b0-0aafe4f00787','82c89594-bc68-5b07-9b1f-ff1457f31965',6),
 ('32c3e3a8-1468-5d90-97b0-0aafe4f00787','5fd5cdcc-653f-55e1-8ba9-489c35322634',7),
 ('32c3e3a8-1468-5d90-97b0-0aafe4f00787','2f9028f4-fb81-5db0-8720-f7c8e07420c7',8),
 ('32c3e3a8-1468-5d90-97b0-0aafe4f00787','3bedddc3-8366-55dc-980f-63cc4fd513d0',9),
 ('32c3e3a8-1468-5d90-97b0-0aafe4f00787','97d5221d-a9c7-5d87-a54d-bbfc1ef7238e',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('764e45a2-9326-591a-b074-d794c09e3184','20000000-0000-0000-0000-000000000007',$p$o gară$p$,$p$la estación$p$,221,'sustantivo'),
 ('6c7b0483-0cb2-5649-905a-55e394bd51d4','20000000-0000-0000-0000-000000000007',$p$un muzeu$p$,$p$el museo$p$,222,'sustantivo'),
 ('efc3b3a9-5dbd-5bcc-b6cf-fccf6b978107','20000000-0000-0000-0000-000000000007',$p$o farmacie$p$,$p$la farmacia$p$,223,'sustantivo'),
 ('da427eff-e0af-5c2c-bfde-e56925506130','20000000-0000-0000-0000-000000000007',$p$un magazin$p$,$p$la tienda$p$,224,'sustantivo'),
 ('f5bfccfb-7534-5385-a113-b9d8a7d9ea06','20000000-0000-0000-0000-000000000007',$p$o piață$p$,$p$la plaza; el mercado$p$,225,'sustantivo'),
 ('907f94fb-e1ec-55fa-a2ab-db4c5f46578e','20000000-0000-0000-0000-000000000007',$p$un parc$p$,$p$el parque$p$,226,'sustantivo'),
 ('8f42deb0-cca4-5d1f-bcf3-051586f5db9f','20000000-0000-0000-0000-000000000007',$p$o stradă$p$,$p$la calle$p$,227,'sustantivo'),
 ('60205050-b50a-5546-939b-a31abbc57d15','20000000-0000-0000-0000-000000000007',$p$un hotel$p$,$p$el hotel$p$,228,'sustantivo'),
 ('f7db18cb-c4f1-58fc-9852-bc367d62184d','20000000-0000-0000-0000-000000000007',$p$un oraș$p$,$p$la ciudad$p$,229,'sustantivo'),
 ('84d6cc91-3829-5db1-bbc7-230864a996ac','20000000-0000-0000-0000-000000000007',$p$unde$p$,$p$dónde$p$,230,'adverbio'),
 ('b5adc6b2-8fb6-54d9-b030-66dd2ceb4462','20000000-0000-0000-0000-000000000007',$p$a merge$p$,$p$ir$p$,231,'verbo'),
 ('41f8fa52-fdc0-5490-80e2-8bf7c0b2af3b','20000000-0000-0000-0000-000000000007',$p$a pleca$p$,$p$irse, marcharse$p$,232,'verbo'),
 ('03fc3ef5-37bb-57a7-8b1e-6a292e2972f5','20000000-0000-0000-0000-000000000007',$p$a se afla$p$,$p$estar situado, encontrarse$p$,233,'verbo'),
 ('96c0288f-a238-59be-83cc-6e6a20a0f9ae','20000000-0000-0000-0000-000000000007',$p$drept înainte$p$,$p$todo recto$p$,234,'adverbio'),
 ('ee623c67-7074-5838-9694-62256b13c9e3','20000000-0000-0000-0000-000000000007',$p$la stânga$p$,$p$a la izquierda$p$,235,'adverbio'),
 ('daadfff2-33ab-5dc1-879e-32435bb24530','20000000-0000-0000-0000-000000000007',$p$la dreapta$p$,$p$a la derecha$p$,236,'adverbio'),
 ('3b4c9030-c8ce-5550-9006-b177b8ae46ce','20000000-0000-0000-0000-000000000007',$p$lângă$p$,$p$al lado de, junto a$p$,237,'preposicion'),
 ('1325d213-edb7-5d9b-99b7-cdb6ac1d3dde','20000000-0000-0000-0000-000000000007',$p$vizavi de$p$,$p$enfrente de$p$,238,'preposicion')
on conflict (id) do nothing;

commit;