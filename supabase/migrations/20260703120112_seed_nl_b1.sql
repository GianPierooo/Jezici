-- 20260703120112_seed_nl_b1.sql
-- Currículo B1 del curso es→nl (6 unidades). Molde es→pt.
-- Contenido scopeado a course_id=20000000-0000-0000-0000-000000000006 → aislamiento multicurso por
-- jz_active_course. Unidades order_index continúan la cadena → gating al nivel previo.
begin;
insert into languages (id, code, name) values
  ('10000000-0000-0000-0000-000000000007','nl',$p$Nederlands$p$) on conflict (id) do nothing;
insert into courses (id, source_language_id, target_language_id, is_active) values
  ('20000000-0000-0000-0000-000000000006','10000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000007',true) on conflict (id) do nothing;

-- ── Unidad 13 (B1·nl): Cortesía y deseos (zou + infinitivo) ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('a95f4d77-0460-55f4-a246-2398a3733ac7','20000000-0000-0000-0000-000000000006','B1',13,$p$Cortesía y deseos (zou + infinitivo)$p$,'#6C3483','auto_awesome')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('a272a77c-a609-54b5-8ba4-092cf2919b06','a95f4d77-0460-55f4-a246-2398a3733ac7',1,$p$Pedir con cortesía (zou je... kunnen?)$p$,$p$Pedir con cortesía (zou je... kunnen?)$p$,'lesson',15),
 ('edaa850f-6fb1-57e9-bd48-788d7f070e94','a95f4d77-0460-55f4-a246-2398a3733ac7',2,$p$Deseos con zou graag willen$p$,$p$Deseos con zou graag willen$p$,'lesson',15),
 ('1c6b1236-575c-54e5-8586-0a509c1f54f8','a95f4d77-0460-55f4-a246-2398a3733ac7',3,$p$Hipótesis y consejos (als ik jou was)$p$,$p$Hipótesis y consejos (als ik jou was)$p$,'lesson',15),
 ('f5de1d04-d301-5a8d-b242-2e5e7741c247','a95f4d77-0460-55f4-a246-2398a3733ac7',4,$p$¿Qué harías tú? (wat zou jij doen?)$p$,$p$¿Qué harías tú? (wat zou jij doen?)$p$,'lesson',15),
 ('155bb40e-c5bc-580a-9f35-db21f355d20e','a95f4d77-0460-55f4-a246-2398a3733ac7',5,$p$🏁 Checkpoint Eenheid 13$p$,$p$Expresa cortesía, deseos e hipótesis con «zou» + infinitivo, colocando el infinitivo al final.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('f209d68b-a437-535a-836c-f44b6c141ebc','20000000-0000-0000-0000-000000000006','checkpoint','B1','a95f4d77-0460-55f4-a246-2398a3733ac7',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('98ddaa2f-bd6c-57bf-9406-465a66f33afb'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','reading','match',$p$Une cada frase cortés en neerlandés con su significado en español.$p$,$j${"pairs": [{"en": "Zou je me kunnen helpen?", "es": "¿Podrías ayudarme?"}, {"en": "Zou u dat willen herhalen?", "es": "¿Querría usted repetir eso?"}, {"en": "Ik zou graag willen betalen.", "es": "Me gustaría pagar."}]}$j$::jsonb,$j${"pairs": [["Zou je me kunnen helpen?", "¿Podrías ayudarme?"], ["Zou u dat willen herhalen?", "¿Querría usted repetir eso?"], ["Ik zou graag willen betalen.", "Me gustaría pagar."]]}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$polite_request$p$, $p$reading$p$]),
('8430b024-75f3-5282-a846-93a075c11992'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','reading','multiple_choice',$p$¿Cuál es la forma más cortés para pedir ayuda a alguien?$p$,$j${"options": ["Zou je me kunnen helpen?", "Help mij nu meteen.", "Jij helpt mij toch?"]}$j$::jsonb,$j${"value": "Zou je me kunnen helpen?"}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$polite_request$p$, $p$reading$p$]),
('f93d289d-0063-5c07-a82e-fcd3ab4cf490'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','reading','multiple_choice',$p$Elige la frase donde el infinitivo está correctamente al final.$p$,$j${"options": ["Ik zou graag een koffie willen.", "Ik zou willen graag een koffie.", "Ik graag zou een koffie willen."]}$j$::jsonb,$j${"value": "Ik zou graag een koffie willen."}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$wish_zou_graag$p$, $p$reading$p$]),
('02798296-01da-5bfa-85be-07af0b891d5e'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','reading','match',$p$Une cada hipótesis o consejo en neerlandés con su traducción.$p$,$j${"pairs": [{"en": "Als ik jou was, zou ik gaan.", "es": "Si yo fuera tú, iría."}, {"en": "Als ik rijk was, zou ik reizen.", "es": "Si fuera rico, viajaría."}, {"en": "Zonder jou zou ik verdwalen.", "es": "Sin ti me perdería."}]}$j$::jsonb,$j${"pairs": [["Als ik jou was, zou ik gaan.", "Si yo fuera tú, iría."], ["Als ik rijk was, zou ik reizen.", "Si fuera rico, viajaría."], ["Zonder jou zou ik verdwalen.", "Sin ti me perdería."]]}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$hypothesis_advice$p$, $p$reading$p$]),
('24c9ac42-959c-55fa-976d-8167aef62e08'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','reading','multiple_choice',$p$¿Qué frase da un consejo con «si yo fuera tú»?$p$,$j${"options": ["Als ik jou was, zou ik het proberen.", "Ik was jou, dus ik probeer het.", "Jij bent ik, zou ik het proberen."]}$j$::jsonb,$j${"value": "Als ik jou was, zou ik het proberen."}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$hypothesis_advice$p$, $p$reading$p$]),
('8530c652-4aed-5084-abb2-bb1a34bdf70e'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','reading','multiple_choice',$p$¿Cómo se pregunta «¿Qué harías tú?» de forma correcta?$p$,$j${"options": ["Wat zou jij doen?", "Wat zal jij morgen doen?", "Wat deed jij toen?"]}$j$::jsonb,$j${"value": "Wat zou jij doen?"}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$what_would_you_do$p$, $p$reading$p$]),
('f2d7b4a0-fdf5-544a-b0cf-925545e13499'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','writing','cloze',$p$Completa: «¿Podrías ayudarme?» (cortés).$p$,$j${"text": "___ je me kunnen helpen?"}$j$::jsonb,$j${"value": "Zou", "accepted": ["Zou", "zou"]}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$polite_request$p$, $p$writing$p$]),
('d861a415-5e62-5afe-8903-43394148eb27'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','writing','cloze',$p$Completa el deseo: «Me gustaría un té.» El infinitivo va al final.$p$,$j${"text": "Ik zou graag een thee ___."}$j$::jsonb,$j${"value": "willen", "accepted": ["willen"]}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$wish_zou_graag$p$, $p$writing$p$]),
('515a6001-8d81-5f56-b002-4a99b0b9a083'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','writing','translation',$p$Traduce al neerlandés: «Me gustaría pagar.»$p$,$j${"source": "Me gustaría pagar."}$j$::jsonb,$j${"value": "Ik zou graag willen betalen.", "accepted": ["Ik zou graag willen betalen.", "Ik zou graag willen betalen", "Ik zou graag betalen.", "Ik zou graag betalen"]}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$wish_zou_graag$p$, $p$writing$p$]),
('af5d096c-d66e-59f1-9bf0-8532d7ea8a99'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','writing','translation',$p$Traduce al neerlandés: «Si yo fuera tú, iría.»$p$,$j${"source": "Si yo fuera tú, iría."}$j$::jsonb,$j${"value": "Als ik jou was, zou ik gaan.", "accepted": ["Als ik jou was, zou ik gaan.", "Als ik jou was, zou ik gaan", "Als ik jou was zou ik gaan."]}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$hypothesis_advice$p$, $p$writing$p$]),
('72a9acb3-4381-503c-84ad-1519bc2026aa'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','writing','word_bank',$p$Ordena las fichas para preguntar «¿Qué harías tú?».$p$,$j${"tiles": ["Wat", "zou", "jij", "doen", "zal", "deed"]}$j$::jsonb,$j${"value": "Wat zou jij doen", "sequence": ["Wat", "zou", "jij", "doen"]}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$what_would_you_do$p$, $p$writing$p$]),
('43c45eb7-4965-5818-9bec-4e1c455bc012'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','writing','reorder',$p$Ordena las palabras: «Si fuera rico, viajaría.»$p$,$j${"tiles": ["Als", "ik", "rijk", "was,", "zou", "ik", "reizen"]}$j$::jsonb,$j${"value": "Als ik rijk was, zou ik reizen"}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$hypothesis_advice$p$, $p$writing$p$]),
('ca74504c-11e3-5346-b3ab-9e69760f7708'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Zou u mij kunnen helpen?", "Zal u mij komen halen?", "Zei u mij dat gisteren?"], "say": "Zou u mij kunnen helpen?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/ca74504c-11e3-5346-b3ab-9e69760f7708.mp3"}$j$::jsonb,$j${"value": "Zou u mij kunnen helpen?"}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$polite_request$p$, $p$listening$p$]),
('9de98e2a-83e7-573b-b2c6-209358014b45'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','listening','listening',$p$Escucha y elige la frase correcta.$p$,$j${"options": ["Ik zou graag koffie willen.", "Ik zal graag koffie halen.", "Ik heb graag koffie gehad."], "say": "Ik zou graag koffie willen.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/9de98e2a-83e7-573b-b2c6-209358014b45.mp3"}$j$::jsonb,$j${"value": "Ik zou graag koffie willen."}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$wish_zou_graag$p$, $p$listening$p$]),
('f70ff000-d120-5f07-970e-7595e6fc51d4'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','listening','listening',$p$Escucha y elige lo que oíste.$p$,$j${"options": ["Wat zou jij in mijn plaats doen?", "Wat zal jij vanavond koken?", "Wat deed jij op je werk?"], "say": "Wat zou jij in mijn plaats doen?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/f70ff000-d120-5f07-970e-7595e6fc51d4.mp3"}$j$::jsonb,$j${"value": "Wat zou jij in mijn plaats doen?"}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$what_would_you_do$p$, $p$listening$p$]),
('67683176-bc07-5a38-9856-04dacece8a7d'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','listening','listening',$p$Escucha y elige la hipótesis correcta.$p$,$j${"options": ["Als ik tijd had, zou ik komen.", "Als ik tijd heb, zal ik koken.", "Als ik tijd zoek, mag ik komen."], "say": "Als ik tijd had, zou ik komen.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/67683176-bc07-5a38-9856-04dacece8a7d.mp3"}$j$::jsonb,$j${"value": "Als ik tijd had, zou ik komen."}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$hypothesis_advice$p$, $p$listening$p$]),
('eccd1400-b53f-5a14-80d4-483ab5ecd708'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta esta petición cortés.$p$,$j${"text": "Zou je me alsjeblieft kunnen helpen?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/eccd1400-b53f-5a14-80d4-483ab5ecd708.mp3"}$j$::jsonb,$j${"expected": "Zou je me alsjeblieft kunnen helpen?"}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$polite_request$p$, $p$speaking$p$]),
('04a62d23-46d9-52f0-bc79-a2bbb5d7a529'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta este deseo.$p$,$j${"text": "Ik zou graag een kopje thee willen.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/04a62d23-46d9-52f0-bc79-a2bbb5d7a529.mp3"}$j$::jsonb,$j${"expected": "Ik zou graag een kopje thee willen."}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$wish_zou_graag$p$, $p$speaking$p$]),
('442552ad-05ee-5231-b4c8-a9bcb36a1d8d'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta esta pregunta.$p$,$j${"text": "Wat zou jij doen als je mij was?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/442552ad-05ee-5231-b4c8-a9bcb36a1d8d.mp3"}$j$::jsonb,$j${"expected": "Wat zou jij doen als je mij was?"}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$what_would_you_do$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('a272a77c-a609-54b5-8ba4-092cf2919b06','98ddaa2f-bd6c-57bf-9406-465a66f33afb',1),
 ('a272a77c-a609-54b5-8ba4-092cf2919b06','8430b024-75f3-5282-a846-93a075c11992',2),
 ('a272a77c-a609-54b5-8ba4-092cf2919b06','f2d7b4a0-fdf5-544a-b0cf-925545e13499',3),
 ('a272a77c-a609-54b5-8ba4-092cf2919b06','ca74504c-11e3-5346-b3ab-9e69760f7708',4),
 ('a272a77c-a609-54b5-8ba4-092cf2919b06','eccd1400-b53f-5a14-80d4-483ab5ecd708',5),
 ('edaa850f-6fb1-57e9-bd48-788d7f070e94','f93d289d-0063-5c07-a82e-fcd3ab4cf490',1),
 ('edaa850f-6fb1-57e9-bd48-788d7f070e94','d861a415-5e62-5afe-8903-43394148eb27',2),
 ('edaa850f-6fb1-57e9-bd48-788d7f070e94','515a6001-8d81-5f56-b002-4a99b0b9a083',3),
 ('edaa850f-6fb1-57e9-bd48-788d7f070e94','9de98e2a-83e7-573b-b2c6-209358014b45',4),
 ('edaa850f-6fb1-57e9-bd48-788d7f070e94','04a62d23-46d9-52f0-bc79-a2bbb5d7a529',5),
 ('1c6b1236-575c-54e5-8586-0a509c1f54f8','02798296-01da-5bfa-85be-07af0b891d5e',1),
 ('1c6b1236-575c-54e5-8586-0a509c1f54f8','24c9ac42-959c-55fa-976d-8167aef62e08',2),
 ('1c6b1236-575c-54e5-8586-0a509c1f54f8','af5d096c-d66e-59f1-9bf0-8532d7ea8a99',3),
 ('1c6b1236-575c-54e5-8586-0a509c1f54f8','43c45eb7-4965-5818-9bec-4e1c455bc012',4),
 ('1c6b1236-575c-54e5-8586-0a509c1f54f8','67683176-bc07-5a38-9856-04dacece8a7d',5),
 ('f5de1d04-d301-5a8d-b242-2e5e7741c247','8530c652-4aed-5084-abb2-bb1a34bdf70e',1),
 ('f5de1d04-d301-5a8d-b242-2e5e7741c247','72a9acb3-4381-503c-84ad-1519bc2026aa',2),
 ('f5de1d04-d301-5a8d-b242-2e5e7741c247','f70ff000-d120-5f07-970e-7595e6fc51d4',3),
 ('f5de1d04-d301-5a8d-b242-2e5e7741c247','442552ad-05ee-5231-b4c8-a9bcb36a1d8d',4),
 ('155bb40e-c5bc-580a-9f35-db21f355d20e','98ddaa2f-bd6c-57bf-9406-465a66f33afb',1),
 ('155bb40e-c5bc-580a-9f35-db21f355d20e','8430b024-75f3-5282-a846-93a075c11992',2),
 ('155bb40e-c5bc-580a-9f35-db21f355d20e','f93d289d-0063-5c07-a82e-fcd3ab4cf490',3),
 ('155bb40e-c5bc-580a-9f35-db21f355d20e','f2d7b4a0-fdf5-544a-b0cf-925545e13499',4),
 ('155bb40e-c5bc-580a-9f35-db21f355d20e','d861a415-5e62-5afe-8903-43394148eb27',5),
 ('155bb40e-c5bc-580a-9f35-db21f355d20e','515a6001-8d81-5f56-b002-4a99b0b9a083',6),
 ('155bb40e-c5bc-580a-9f35-db21f355d20e','ca74504c-11e3-5346-b3ab-9e69760f7708',7),
 ('155bb40e-c5bc-580a-9f35-db21f355d20e','9de98e2a-83e7-573b-b2c6-209358014b45',8),
 ('155bb40e-c5bc-580a-9f35-db21f355d20e','eccd1400-b53f-5a14-80d4-483ab5ecd708',9),
 ('155bb40e-c5bc-580a-9f35-db21f355d20e','04a62d23-46d9-52f0-bc79-a2bbb5d7a529',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('b501a5d2-8823-550d-9dca-e4ae1ab18bb2','20000000-0000-0000-0000-000000000006',$p$zou$p$,$p$haría/-ía (condicional)$p$,361,'werkwoord'),
 ('66f6314f-004d-5994-a280-cecf03e29dbf','20000000-0000-0000-0000-000000000006',$p$zouden$p$,$p$harían/-ían (condicional plural)$p$,362,'werkwoord'),
 ('f150a931-8adc-5f69-92ec-1d3cf040ec52','20000000-0000-0000-0000-000000000006',$p$graag$p$,$p$con gusto / gustaría$p$,363,'bijwoord'),
 ('d77a4ab3-2a4b-5566-b62e-e227cf9e5b16','20000000-0000-0000-0000-000000000006',$p$willen$p$,$p$querer$p$,364,'werkwoord'),
 ('7b05c4f6-1be0-59e1-ab62-77664feefaef','20000000-0000-0000-0000-000000000006',$p$kunnen$p$,$p$poder$p$,365,'werkwoord'),
 ('68b70e4a-a1a5-5052-8da1-4e612da9e814','20000000-0000-0000-0000-000000000006',$p$helpen$p$,$p$ayudar$p$,366,'werkwoord'),
 ('a5cf3019-bbc1-532b-b350-5d44117976af','20000000-0000-0000-0000-000000000006',$p$misschien$p$,$p$quizás$p$,367,'bijwoord'),
 ('5fdc37ed-7783-58d6-90f8-03b97313dbfd','20000000-0000-0000-0000-000000000006',$p$liever$p$,$p$preferiblemente / más bien$p$,368,'bijwoord'),
 ('f6ea9e9e-f13c-5668-8b71-38b3a938956c','20000000-0000-0000-0000-000000000006',$p$het advies$p$,$p$el consejo$p$,369,'zelfstandig naamwoord'),
 ('ce88fdee-6696-59ce-93da-7d87a166cf4c','20000000-0000-0000-0000-000000000006',$p$de wens$p$,$p$el deseo$p$,370,'zelfstandig naamwoord'),
 ('74bc4a5c-a2dd-5347-b765-2308d2593eb7','20000000-0000-0000-0000-000000000006',$p$als$p$,$p$si (condicional)$p$,371,'voegwoord'),
 ('b1cfbb3c-14f5-5c68-aac5-93a11c4025a9','20000000-0000-0000-0000-000000000006',$p$beleefd$p$,$p$cortés / educado$p$,372,'bijvoeglijk naamwoord'),
 ('3a3737d8-1433-522a-9da6-baa267cc7664','20000000-0000-0000-0000-000000000006',$p$moeten$p$,$p$deber / tener que$p$,373,'werkwoord'),
 ('21398712-337f-5b14-9ae0-64c0971a00b9','20000000-0000-0000-0000-000000000006',$p$vragen$p$,$p$preguntar / pedir$p$,374,'werkwoord'),
 ('d3cb5a11-f09e-5d78-807a-f14a416a89ba','20000000-0000-0000-0000-000000000006',$p$de mogelijkheid$p$,$p$la posibilidad$p$,375,'zelfstandig naamwoord'),
 ('8ad570b3-cd7f-5e00-94e1-ad86dfab83c6','20000000-0000-0000-0000-000000000006',$p$Ik zou graag$p$,$p$me gustaría$p$,376,'uitdrukking')
on conflict (id) do nothing;

-- ── Unidad 14 (B1·nl): Unir ideas: porque, aunque, así que ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('78fef67a-08da-5770-9e6c-c6a25d83f428','20000000-0000-0000-0000-000000000006','B1',14,$p$Unir ideas: porque, aunque, así que$p$,'#1F618D','hub')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('b1347f1f-ac2b-54de-b841-44593e340ae9','78fef67a-08da-5770-9e6c-c6a25d83f428',1,$p$Omdat, want y dat: el verbo al final$p$,$p$Omdat, want y dat: el verbo al final$p$,'lesson',15),
 ('78a5ccb4-784e-5d5a-a5a3-f224d67d66a1','78fef67a-08da-5770-9e6c-c6a25d83f428',2,$p$Als, terwijl, voordat: tiempo y condición$p$,$p$Als, terwijl, voordat: tiempo y condición$p$,'lesson',15),
 ('d47e227b-06e3-5ca6-a7d1-c5003492427b','78fef67a-08da-5770-9e6c-c6a25d83f428',3,$p$Hoewel y zodat: contraste y consecuencia$p$,$p$Hoewel y zodat: contraste y consecuencia$p$,'lesson',15),
 ('9d8bc369-e317-5faa-9962-d41404dc87e8','78fef67a-08da-5770-9e6c-c6a25d83f428',4,$p$Daarom, dus, toch: inversión en posición 1$p$,$p$Daarom, dus, toch: inversión en posición 1$p$,'lesson',15),
 ('ccc892f5-86b2-5140-a119-c978121e4389','78fef67a-08da-5770-9e6c-c6a25d83f428',5,$p$🏁 Checkpoint Eenheid 14$p$,$p$Une frases con conjunciones subordinantes (omdat, dat, als, hoewel, terwijl, zodat, voordat) colocando el verbo al final, y con adverbios de posición inicial (daarom, dus, toch) usando la inversión.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('e248c29b-93b1-51ac-be21-57cc27e3e407','20000000-0000-0000-0000-000000000006','checkpoint','B1','78fef67a-08da-5770-9e6c-c6a25d83f428',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('15188c31-6f0f-5976-b4c2-056da3b90a3a'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','reading','match',$p$Une cada conjunción con su regla de orden de palabras.$p$,$j${"pairs": [{"en": "omdat", "es": "porque (verbo al final)"}, {"en": "want", "es": "porque (verbo en 2ª posición)"}, {"en": "dat", "es": "que"}]}$j$::jsonb,$j${"pairs": [["omdat", "porque (verbo al final)"], ["want", "porque (verbo en 2ª posición)"], ["dat", "que"]]}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$omdat_vs_want$p$, $p$reading$p$]),
('778724d2-7e05-534d-b06c-84aeec1b6888'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','reading','multiple_choice',$p$Elige la subordinada correcta con 'omdat' (verbo al final): «Me quedo en casa porque estoy enfermo».$p$,$j${"options": ["Ik blijf thuis omdat ik ziek ben.", "Ik blijf thuis omdat ik ben ziek.", "Ik blijf thuis omdat ben ik ziek."]}$j$::jsonb,$j${"value": "Ik blijf thuis omdat ik ziek ben."}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$omdat_verb_final$p$, $p$reading$p$]),
('f4011f7f-2ba5-56bc-807f-ed336d0970fa'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','reading','multiple_choice',$p$Elige la frase correcta con 'dat' (verbo al final): «Creo que ella viene mañana».$p$,$j${"options": ["Ik denk dat zij morgen komt.", "Ik denk dat zij komt morgen.", "Ik denk dat komt zij morgen."]}$j$::jsonb,$j${"value": "Ik denk dat zij morgen komt."}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$dat_clause_order$p$, $p$reading$p$]),
('d010b653-57bf-5dd7-b640-1b166eb56dfd'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','reading','multiple_choice',$p$Elige la frase correcta con 'voordat' (verbo al final): «Me lavo las manos antes de comer».$p$,$j${"options": ["Ik was mijn handen voordat ik eet.", "Ik was mijn handen voordat ik eten.", "Ik was mijn handen voordat eet ik."]}$j$::jsonb,$j${"value": "Ik was mijn handen voordat ik eet."}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$voordat_before$p$, $p$reading$p$]),
('a90e7913-74f9-5353-bec8-df3d4a4ada05'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','reading','multiple_choice',$p$Elige la frase correcta con 'terwijl' (verbo al final en la subordinada): «Ella lee mientras yo cocino».$p$,$j${"options": ["Zij leest terwijl ik kook.", "Zij leest terwijl kook ik.", "Zij leest terwijl ik koken."]}$j$::jsonb,$j${"value": "Zij leest terwijl ik kook."}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$terwijl_simultaneous$p$, $p$reading$p$]),
('a5940fe7-e505-5abe-8c7f-b70c1bc2c553'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','reading','match',$p$Une cada conjunción o adverbio con su significado en español.$p$,$j${"pairs": [{"en": "hoewel", "es": "aunque"}, {"en": "zodat", "es": "para que"}, {"en": "toch", "es": "aun así"}]}$j$::jsonb,$j${"pairs": [["hoewel", "aunque"], ["zodat", "para que"], ["toch", "aun así"]]}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$hoewel_contrast$p$, $p$reading$p$]),
('c2d221b5-f707-5f09-bf1f-13e4d617359f'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','writing','cloze',$p$Completa con la conjunción 'porque' que envía el verbo al final: «No voy porque no tengo tiempo».$p$,$j${"text": "Ik ga niet, ___ ik geen tijd heb."}$j$::jsonb,$j${"value": "omdat", "accepted": ["omdat"]}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$omdat_cloze$p$, $p$writing$p$]),
('b0ea6e7f-5b6c-53bd-806d-444024567e46'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','writing','cloze',$p$Completa con 'want' (el verbo queda en 2ª posición, no al final): «Estoy contento, porque tengo vacaciones».$p$,$j${"text": "Ik ben blij, ___ ik heb vakantie."}$j$::jsonb,$j${"value": "want", "accepted": ["want"]}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$want_coordinating$p$, $p$writing$p$]),
('1de1309a-e325-506e-b9c8-577ce7696720'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','writing','word_bank',$p$Ordena la subordinada con 'omdat' (verbo al final): «Ella aprende neerlandés porque vive en Ámsterdam».$p$,$j${"tiles": ["Zij", "leert", "Nederlands", "omdat", "zij", "in", "Amsterdam", "woont", "is", "heeft"]}$j$::jsonb,$j${"value": "Zij leert Nederlands omdat zij in Amsterdam woont", "sequence": ["Zij", "leert", "Nederlands", "omdat", "zij", "in", "Amsterdam", "woont"]}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$omdat_word_bank$p$, $p$writing$p$]),
('effb0f6f-665c-50da-863f-3be2b4f6a4ef'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','writing','translation',$p$Traduce al neerlandés: «Aunque está lloviendo, voy a caminar.»$p$,$j${"source": "Aunque está lloviendo, voy a caminar."}$j$::jsonb,$j${"value": "Hoewel het regent, ga ik wandelen.", "accepted": ["Hoewel het regent, ga ik wandelen.", "Hoewel het regent, ga ik wandelen", "Hoewel het regent ga ik wandelen."]}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$hoewel_clause$p$, $p$writing$p$]),
('1b213b96-2404-54c0-93a3-62fcde99cb68'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','writing','cloze',$p$Completa con la conjunción 'para que / de modo que': «Hablo despacio para que me entiendas».$p$,$j${"text": "Ik praat langzaam, ___ je mij begrijpt."}$j$::jsonb,$j${"value": "zodat", "accepted": ["zodat"]}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$zodat_purpose$p$, $p$writing$p$]),
('3c3ddaf1-eb13-50a2-93bc-7603b1dec630'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','writing','reorder',$p$Ordena con inversión tras 'dus' (posición 1 → verbo 2º): «La tienda está cerrada, así que compramos mañana».$p$,$j${"tiles": ["De", "winkel", "is", "dicht", "dus", "kopen", "we", "morgen"]}$j$::jsonb,$j${"value": "De winkel is dicht dus kopen we morgen"}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$dus_reorder$p$, $p$writing$p$]),
('0771d03f-ae4d-5852-94ca-4dc3d538ea08'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Als het regent, blijf ik thuis.", "Als het regent, ik blijf thuis.", "Als regent het, blijf ik thuis."], "say": "Als het regent, blijf ik thuis.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/0771d03f-ae4d-5852-94ca-4dc3d538ea08.mp3"}$j$::jsonb,$j${"value": "Als het regent, blijf ik thuis."}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$als_condition$p$, $p$listening$p$]),
('2dd6610e-2471-5bb0-9696-f7389c489d1f'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ik luister naar muziek terwijl ik werk.", "Ik luister naar muziek terwijl ik werken.", "Ik luister naar muziek terwijl werk ik."], "say": "Ik luister naar muziek terwijl ik werk.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/2dd6610e-2471-5bb0-9696-f7389c489d1f.mp3"}$j$::jsonb,$j${"value": "Ik luister naar muziek terwijl ik werk."}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$terwijl_listening$p$, $p$listening$p$]),
('7743cba7-c5c9-582a-865a-c3ec738d21e3'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Als je tijd hebt, help ik je.", "Als je tijd hebt, ik help je.", "Als je tijd hebt, helpen ik je."], "say": "Als je tijd hebt, help ik je.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/7743cba7-c5c9-582a-865a-c3ec738d21e3.mp3"}$j$::jsonb,$j${"value": "Als je tijd hebt, help ik je."}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$als_listening$p$, $p$listening$p$]),
('61a2e7f2-5fb2-5864-bae7-6781af4c56b7'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ik doe het licht aan zodat ik beter kan lezen.", "Ik doe het licht aan zodat ik kan beter lezen.", "Ik doe het licht aan zodat kan ik beter lezen."], "say": "Ik doe het licht aan zodat ik beter kan lezen.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/61a2e7f2-5fb2-5864-bae7-6781af4c56b7.mp3"}$j$::jsonb,$j${"value": "Ik doe het licht aan zodat ik beter kan lezen."}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$zodat_listening$p$, $p$listening$p$]),
('c8511644-d793-54a5-b3bb-9a1b07e87a31'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Voordat ik naar bed ga, lees ik een boek.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/c8511644-d793-54a5-b3bb-9a1b07e87a31.mp3"}$j$::jsonb,$j${"expected": "Voordat ik naar bed ga, lees ik een boek."}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$voordat_speaking$p$, $p$speaking$p$]),
('f13ddfaf-8e87-59a2-b981-b2e1c8856eb2'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Hoewel het laat is, wil ik nog even praten.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/f13ddfaf-8e87-59a2-b981-b2e1c8856eb2.mp3"}$j$::jsonb,$j${"expected": "Hoewel het laat is, wil ik nog even praten."}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$hoewel_speaking$p$, $p$speaking$p$]),
('2791f239-94d2-5b8c-98db-d06b31901b6e'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Het is duur, maar toch koop ik het.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/2791f239-94d2-5b8c-98db-d06b31901b6e.mp3"}$j$::jsonb,$j${"expected": "Het is duur, maar toch koop ik het."}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$toch_speaking$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('b1347f1f-ac2b-54de-b841-44593e340ae9','15188c31-6f0f-5976-b4c2-056da3b90a3a',1),
 ('b1347f1f-ac2b-54de-b841-44593e340ae9','778724d2-7e05-534d-b06c-84aeec1b6888',2),
 ('b1347f1f-ac2b-54de-b841-44593e340ae9','f4011f7f-2ba5-56bc-807f-ed336d0970fa',3),
 ('b1347f1f-ac2b-54de-b841-44593e340ae9','c2d221b5-f707-5f09-bf1f-13e4d617359f',4),
 ('b1347f1f-ac2b-54de-b841-44593e340ae9','b0ea6e7f-5b6c-53bd-806d-444024567e46',5),
 ('b1347f1f-ac2b-54de-b841-44593e340ae9','1de1309a-e325-506e-b9c8-577ce7696720',6),
 ('78a5ccb4-784e-5d5a-a5a3-f224d67d66a1','d010b653-57bf-5dd7-b640-1b166eb56dfd',1),
 ('78a5ccb4-784e-5d5a-a5a3-f224d67d66a1','a90e7913-74f9-5353-bec8-df3d4a4ada05',2),
 ('78a5ccb4-784e-5d5a-a5a3-f224d67d66a1','0771d03f-ae4d-5852-94ca-4dc3d538ea08',3),
 ('78a5ccb4-784e-5d5a-a5a3-f224d67d66a1','2dd6610e-2471-5bb0-9696-f7389c489d1f',4),
 ('78a5ccb4-784e-5d5a-a5a3-f224d67d66a1','7743cba7-c5c9-582a-865a-c3ec738d21e3',5),
 ('78a5ccb4-784e-5d5a-a5a3-f224d67d66a1','c8511644-d793-54a5-b3bb-9a1b07e87a31',6),
 ('d47e227b-06e3-5ca6-a7d1-c5003492427b','a5940fe7-e505-5abe-8c7f-b70c1bc2c553',1),
 ('d47e227b-06e3-5ca6-a7d1-c5003492427b','effb0f6f-665c-50da-863f-3be2b4f6a4ef',2),
 ('d47e227b-06e3-5ca6-a7d1-c5003492427b','1b213b96-2404-54c0-93a3-62fcde99cb68',3),
 ('d47e227b-06e3-5ca6-a7d1-c5003492427b','61a2e7f2-5fb2-5864-bae7-6781af4c56b7',4),
 ('d47e227b-06e3-5ca6-a7d1-c5003492427b','f13ddfaf-8e87-59a2-b981-b2e1c8856eb2',5),
 ('9d8bc369-e317-5faa-9962-d41404dc87e8','3c3ddaf1-eb13-50a2-93bc-7603b1dec630',1),
 ('9d8bc369-e317-5faa-9962-d41404dc87e8','2791f239-94d2-5b8c-98db-d06b31901b6e',2),
 ('ccc892f5-86b2-5140-a119-c978121e4389','15188c31-6f0f-5976-b4c2-056da3b90a3a',1),
 ('ccc892f5-86b2-5140-a119-c978121e4389','778724d2-7e05-534d-b06c-84aeec1b6888',2),
 ('ccc892f5-86b2-5140-a119-c978121e4389','f4011f7f-2ba5-56bc-807f-ed336d0970fa',3),
 ('ccc892f5-86b2-5140-a119-c978121e4389','c2d221b5-f707-5f09-bf1f-13e4d617359f',4),
 ('ccc892f5-86b2-5140-a119-c978121e4389','b0ea6e7f-5b6c-53bd-806d-444024567e46',5),
 ('ccc892f5-86b2-5140-a119-c978121e4389','1de1309a-e325-506e-b9c8-577ce7696720',6),
 ('ccc892f5-86b2-5140-a119-c978121e4389','0771d03f-ae4d-5852-94ca-4dc3d538ea08',7),
 ('ccc892f5-86b2-5140-a119-c978121e4389','2dd6610e-2471-5bb0-9696-f7389c489d1f',8),
 ('ccc892f5-86b2-5140-a119-c978121e4389','c8511644-d793-54a5-b3bb-9a1b07e87a31',9),
 ('ccc892f5-86b2-5140-a119-c978121e4389','f13ddfaf-8e87-59a2-b981-b2e1c8856eb2',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('71101fd1-52af-5163-839a-8bd67342b5a1','20000000-0000-0000-0000-000000000006',$p$omdat$p$,$p$porque (subordina)$p$,381,'conj'),
 ('38fea1b1-6a29-544c-a231-858a67231576','20000000-0000-0000-0000-000000000006',$p$want$p$,$p$porque (coordina)$p$,382,'conj'),
 ('577f7514-fa3f-5c72-a1d0-f6b598562f95','20000000-0000-0000-0000-000000000006',$p$dat$p$,$p$que$p$,383,'conj'),
 ('491faa36-b95b-50c4-9713-0ff0a8612439','20000000-0000-0000-0000-000000000006',$p$als$p$,$p$si / cuando$p$,384,'conj'),
 ('ea81584d-26ea-542a-964c-ae1c93ff0ed8','20000000-0000-0000-0000-000000000006',$p$terwijl$p$,$p$mientras$p$,385,'conj'),
 ('2baf4851-6ee2-59c3-9b99-45d3809ab2e2','20000000-0000-0000-0000-000000000006',$p$voordat$p$,$p$antes de que$p$,386,'conj'),
 ('319de8dd-fcef-5cde-934c-c0235fdead3a','20000000-0000-0000-0000-000000000006',$p$nadat$p$,$p$después de que$p$,387,'conj'),
 ('cf23acb5-a5ec-5605-9c8a-ae1a2ae5d39f','20000000-0000-0000-0000-000000000006',$p$hoewel$p$,$p$aunque$p$,388,'conj'),
 ('1fa4a15f-5464-58a9-b4f0-48ba6a1e93bb','20000000-0000-0000-0000-000000000006',$p$zodat$p$,$p$para que / de modo que$p$,389,'conj'),
 ('38993d94-d610-5222-a966-a153e6b32105','20000000-0000-0000-0000-000000000006',$p$daarom$p$,$p$por eso$p$,390,'adv'),
 ('0eead012-838c-5fe2-8a0f-67d232a29664','20000000-0000-0000-0000-000000000006',$p$dus$p$,$p$así que$p$,391,'adv'),
 ('19ad1c56-5c32-5956-b3b7-f8100939fe53','20000000-0000-0000-0000-000000000006',$p$toch$p$,$p$aun así / sin embargo$p$,392,'adv'),
 ('8100032b-341c-500f-88df-9f92f6ef0018','20000000-0000-0000-0000-000000000006',$p$de reden$p$,$p$la razón$p$,393,'noun'),
 ('988f5e9b-f85f-5165-af45-4d6e837f2b70','20000000-0000-0000-0000-000000000006',$p$het gevolg$p$,$p$la consecuencia$p$,394,'noun'),
 ('668759d8-ac6a-5782-8b1a-c7e29647d520','20000000-0000-0000-0000-000000000006',$p$de afspraak$p$,$p$la cita / el acuerdo$p$,395,'noun'),
 ('2689b412-6bb5-5aa2-a05a-0bffc0d5d871','20000000-0000-0000-0000-000000000006',$p$de mening$p$,$p$la opinión$p$,396,'noun')
on conflict (id) do nothing;

-- ── Unidad 15 (B1·nl): Frases de relativo (die, dat, wie) ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('d839fbc4-e2bd-50a1-9b99-6c39b699add8','20000000-0000-0000-0000-000000000006','B1',15,$p$Frases de relativo (die, dat, wie)$p$,'#117864','link')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('19ff24a3-94a2-5e00-a768-a6a4f29c1c77','d839fbc4-e2bd-50a1-9b99-6c39b699add8',1,$p$die y dat: de-woord o het-woord$p$,$p$die y dat: de-woord o het-woord$p$,'lesson',15),
 ('2dd3125e-518e-5a4d-997d-53003b867b41','d839fbc4-e2bd-50a1-9b99-6c39b699add8',2,$p$wie tras preposición (personas)$p$,$p$wie tras preposición (personas)$p$,'lesson',15),
 ('cdb2e559-4dc5-5e71-ae7a-5817779662f9','d839fbc4-e2bd-50a1-9b99-6c39b699add8',3,$p$wat y waar+preposición$p$,$p$wat y waar+preposición$p$,'lesson',15),
 ('1a39688a-09f2-5f9e-bbaf-c472ee1310fc','d839fbc4-e2bd-50a1-9b99-6c39b699add8',4,$p$Frases de relativo en contexto$p$,$p$Frases de relativo en contexto$p$,'lesson',15),
 ('9941b09a-5576-5788-86e4-0df1432f984e','d839fbc4-e2bd-50a1-9b99-6c39b699add8',5,$p$🏁 Checkpoint Eenheid 15$p$,$p$Demuestra que sabes unir frases con pronombres de relativo: die para palabras con de y plurales, dat para palabras con het, wie tras preposición para personas, y wat tras alles/iets/niets. Recuerda: el verbo va al final de la oración de relativo.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('97855c84-58ca-5fab-b79a-284210f97919','20000000-0000-0000-0000-000000000006','checkpoint','B1','d839fbc4-e2bd-50a1-9b99-6c39b699add8',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('e9c8531c-3aa9-53f3-9f26-5e970bbb0936'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','reading','match',$p$Une cada frase de relativo en neerlandés con su traducción.$p$,$j${"pairs": [{"en": "de man die daar woont", "es": "el hombre que vive ahí"}, {"en": "het huis dat ik koop", "es": "la casa que compro"}, {"en": "de boeken die ik lees", "es": "los libros que leo"}]}$j$::jsonb,$j${"pairs": [["de man die daar woont", "el hombre que vive ahí"], ["het huis dat ik koop", "la casa que compro"], ["de boeken die ik lees", "los libros que leo"]]}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$die_dat_basic$p$, $p$reading$p$]),
('afce9f0a-d4a4-53ba-9b1d-95a13bda97a3'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','reading','multiple_choice',$p$Elige el pronombre de relativo correcto: «de buurman ___ naast ons woont» (el vecino que vive al lado). Buurman es palabra con 'de'.$p$,$j${"options": ["die", "dat", "wie"]}$j$::jsonb,$j${"value": "die"}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$die_de_woord$p$, $p$reading$p$]),
('848e0527-a000-5cf8-b094-fe770a0b9fc7'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','reading','multiple_choice',$p$Elige el pronombre de relativo correcto: «het gebouw ___ we gisteren zagen» (el edificio que vimos ayer). Gebouw es palabra con 'het'.$p$,$j${"options": ["dat", "die", "wie"]}$j$::jsonb,$j${"value": "dat"}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$dat_het_woord$p$, $p$reading$p$]),
('36a6b797-f9c3-573d-85d3-aebea30dd9ab'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','reading','multiple_choice',$p$Elige el relativo correcto tras preposición y referido a persona: «de vrouw met ___ ik praat» (la mujer con quien hablo).$p$,$j${"options": ["wie", "die", "dat"]}$j$::jsonb,$j${"value": "wie"}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$wie_preposition$p$, $p$reading$p$]),
('7514915b-4039-55df-8240-0fffef3f79ec'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','reading','match',$p$Une cada expresión con 'wat' con su traducción.$p$,$j${"pairs": [{"en": "alles wat ik weet", "es": "todo lo que sé"}, {"en": "iets wat me verbaast", "es": "algo que me sorprende"}, {"en": "niets wat helpt", "es": "nada que ayude"}]}$j$::jsonb,$j${"pairs": [["alles wat ik weet", "todo lo que sé"], ["iets wat me verbaast", "algo que me sorprende"], ["niets wat helpt", "nada que ayude"]]}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$wat_alles$p$, $p$reading$p$]),
('7142c260-438f-55b7-bf00-3eb734a35887'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','reading','multiple_choice',$p$Elige el relativo que se refiere a toda la frase anterior: «Hij kwam te laat, ___ ik heel vervelend vond.» (Llegó tarde, lo cual me pareció muy molesto.)$p$,$j${"options": ["wat", "dat", "die"]}$j$::jsonb,$j${"value": "wat"}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$wat_whole_sentence$p$, $p$reading$p$]),
('b24b2e4e-9daf-5399-8f66-12fc19740ab2'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','writing','cloze',$p$Completa con el relativo correcto (het pakket → palabra con 'het'): «El paquete que espero aún no ha llegado.»$p$,$j${"text": "Het pakket ___ ik verwacht, is nog niet aangekomen."}$j$::jsonb,$j${"value": "dat", "accepted": ["dat"]}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$die_dat_choice$p$, $p$writing$p$]),
('bf7b60fe-1c00-547a-8d21-efc07d538874'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','writing','cloze',$p$Completa con el relativo correcto (plural → siempre 'die'): «Los colegas que trabajan aquí son muy amables.»$p$,$j${"text": "De collega's ___ hier werken, zijn heel aardig."}$j$::jsonb,$j${"value": "die", "accepted": ["die"]}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$die_plural$p$, $p$writing$p$]),
('0dc8ff66-73e2-5601-a70d-af0550095d65'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','writing','cloze',$p$Completa con el relativo para personas tras preposición: «El cliente para quien hago esto es muy importante.»$p$,$j${"text": "De klant voor ___ ik dit doe, is heel belangrijk."}$j$::jsonb,$j${"value": "wie", "accepted": ["wie"]}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$wie_preposition_voor$p$, $p$writing$p$]),
('113086ce-8f2b-59e1-984c-ba1a76025da9'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','writing','cloze',$p$Completa con waar+preposición (cosa, no persona): «Este es el problema del que siempre hablamos» ('praten over' → waarover).$p$,$j${"text": "Dit is het probleem ___ we het steeds hebben."}$j$::jsonb,$j${"value": "waarover", "accepted": ["waarover"]}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$waarover_preposition$p$, $p$writing$p$]),
('5d20db6f-2edd-5928-9026-a65ef2d556a1'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','writing','reorder',$p$Ordena las fichas para formar: «La llave con la que abro la puerta.» (waarmee = con la que, para cosas.)$p$,$j${"tiles": ["De", "sleutel", "waarmee", "ik", "de", "deur", "open"]}$j$::jsonb,$j${"value": "De sleutel waarmee ik de deur open"}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$waarmee_reorder$p$, $p$writing$p$]),
('a98bd99b-ba34-5117-bf37-dbca026269b2'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','writing','translation',$p$Traduce al neerlandés: «La solución que propusiste es demasiado complicada.»$p$,$j${"source": "La solución que propusiste es demasiado complicada."}$j$::jsonb,$j${"value": "De oplossing die je voorstelde, is te ingewikkeld.", "accepted": ["De oplossing die je voorstelde, is te ingewikkeld.", "De oplossing die je voorstelde is te ingewikkeld", "De oplossing die jij voorstelde, is te ingewikkeld."]}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$mixed_translation_context$p$, $p$writing$p$]),
('05249fad-8390-51d0-aa83-c467936b8680'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["De sleutel die op tafel ligt, is van mij.", "De sleutel dat op tafel ligt, is van mij.", "De sleutel wie op tafel ligt, is van mij."], "say": "De sleutel die op tafel ligt, is van mij.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/05249fad-8390-51d0-aa83-c467936b8680.mp3"}$j$::jsonb,$j${"value": "De sleutel die op tafel ligt, is van mij."}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$die_verb_final$p$, $p$listening$p$]),
('68d370f2-07c1-529f-88c0-bea29c29e1bd'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["De buurman bij wie ik logeer, is heel gastvrij.", "De buurman bij die ik logeer, is heel gastvrij.", "De buurman bij dat ik logeer, is heel gastvrij."], "say": "De buurman bij wie ik logeer, is heel gastvrij.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/68d370f2-07c1-529f-88c0-bea29c29e1bd.mp3"}$j$::jsonb,$j${"value": "De buurman bij wie ik logeer, is heel gastvrij."}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$wie_listening$p$, $p$listening$p$]),
('2fbb8b90-d4de-549d-8882-0c0c0442add7'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["De man met wie ik werk, is heel betrouwbaar.", "De man met die ik werk, is heel betrouwbaar.", "De man met dat ik werk, is heel betrouwbaar."], "say": "De man met wie ik werk, is heel betrouwbaar.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/2fbb8b90-d4de-549d-8882-0c0c0442add7.mp3"}$j$::jsonb,$j${"value": "De man met wie ik werk, is heel betrouwbaar."}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$wie_context_listening$p$, $p$listening$p$]),
('4eaabffd-2496-5345-b240-dcec2c607c38'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Het advies dat je me gaf, was heel nuttig.", "Het advies die je me gaf, was heel nuttig.", "Het advies wie je me gaf, was heel nuttig."], "say": "Het advies dat je me gaf, was heel nuttig.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/4eaabffd-2496-5345-b240-dcec2c607c38.mp3"}$j$::jsonb,$j${"value": "Het advies dat je me gaf, was heel nuttig."}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$mixed_die_dat_context$p$, $p$listening$p$]),
('8483ce83-0f4a-56b1-8552-19aadd1e816c'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "De klant die gisteren belde, had een ingewikkelde vraag.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/8483ce83-0f4a-56b1-8552-19aadd1e816c.mp3"}$j$::jsonb,$j${"expected": "De klant die gisteren belde, had een ingewikkelde vraag."}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$mixed_speaking_die$p$, $p$speaking$p$]),
('6b96665d-a47f-56b0-9137-05b5b5124097'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Het verhaal dat hij vertelde, was echt ongelooflijk.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/6b96665d-a47f-56b0-9137-05b5b5124097.mp3"}$j$::jsonb,$j${"expected": "Het verhaal dat hij vertelde, was echt ongelooflijk."}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$mixed_speaking_dat$p$, $p$speaking$p$]),
('ae9932f0-ab7b-5a23-bc60-098b1d236b96'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "De persoon met wie ik de afspraak heb, is er nog niet.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/ae9932f0-ab7b-5a23-bc60-098b1d236b96.mp3"}$j$::jsonb,$j${"expected": "De persoon met wie ik de afspraak heb, is er nog niet."}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$mixed_speaking_wie$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('19ff24a3-94a2-5e00-a768-a6a4f29c1c77','e9c8531c-3aa9-53f3-9f26-5e970bbb0936',1),
 ('19ff24a3-94a2-5e00-a768-a6a4f29c1c77','afce9f0a-d4a4-53ba-9b1d-95a13bda97a3',2),
 ('19ff24a3-94a2-5e00-a768-a6a4f29c1c77','848e0527-a000-5cf8-b094-fe770a0b9fc7',3),
 ('19ff24a3-94a2-5e00-a768-a6a4f29c1c77','b24b2e4e-9daf-5399-8f66-12fc19740ab2',4),
 ('19ff24a3-94a2-5e00-a768-a6a4f29c1c77','bf7b60fe-1c00-547a-8d21-efc07d538874',5),
 ('19ff24a3-94a2-5e00-a768-a6a4f29c1c77','05249fad-8390-51d0-aa83-c467936b8680',6),
 ('2dd3125e-518e-5a4d-997d-53003b867b41','36a6b797-f9c3-573d-85d3-aebea30dd9ab',1),
 ('2dd3125e-518e-5a4d-997d-53003b867b41','0dc8ff66-73e2-5601-a70d-af0550095d65',2),
 ('2dd3125e-518e-5a4d-997d-53003b867b41','68d370f2-07c1-529f-88c0-bea29c29e1bd',3),
 ('2dd3125e-518e-5a4d-997d-53003b867b41','2fbb8b90-d4de-549d-8882-0c0c0442add7',4),
 ('cdb2e559-4dc5-5e71-ae7a-5817779662f9','7514915b-4039-55df-8240-0fffef3f79ec',1),
 ('cdb2e559-4dc5-5e71-ae7a-5817779662f9','7142c260-438f-55b7-bf00-3eb734a35887',2),
 ('cdb2e559-4dc5-5e71-ae7a-5817779662f9','113086ce-8f2b-59e1-984c-ba1a76025da9',3),
 ('cdb2e559-4dc5-5e71-ae7a-5817779662f9','5d20db6f-2edd-5928-9026-a65ef2d556a1',4),
 ('1a39688a-09f2-5f9e-bbaf-c472ee1310fc','a98bd99b-ba34-5117-bf37-dbca026269b2',1),
 ('1a39688a-09f2-5f9e-bbaf-c472ee1310fc','4eaabffd-2496-5345-b240-dcec2c607c38',2),
 ('1a39688a-09f2-5f9e-bbaf-c472ee1310fc','8483ce83-0f4a-56b1-8552-19aadd1e816c',3),
 ('1a39688a-09f2-5f9e-bbaf-c472ee1310fc','6b96665d-a47f-56b0-9137-05b5b5124097',4),
 ('1a39688a-09f2-5f9e-bbaf-c472ee1310fc','ae9932f0-ab7b-5a23-bc60-098b1d236b96',5),
 ('9941b09a-5576-5788-86e4-0df1432f984e','e9c8531c-3aa9-53f3-9f26-5e970bbb0936',1),
 ('9941b09a-5576-5788-86e4-0df1432f984e','afce9f0a-d4a4-53ba-9b1d-95a13bda97a3',2),
 ('9941b09a-5576-5788-86e4-0df1432f984e','848e0527-a000-5cf8-b094-fe770a0b9fc7',3),
 ('9941b09a-5576-5788-86e4-0df1432f984e','b24b2e4e-9daf-5399-8f66-12fc19740ab2',4),
 ('9941b09a-5576-5788-86e4-0df1432f984e','bf7b60fe-1c00-547a-8d21-efc07d538874',5),
 ('9941b09a-5576-5788-86e4-0df1432f984e','0dc8ff66-73e2-5601-a70d-af0550095d65',6),
 ('9941b09a-5576-5788-86e4-0df1432f984e','05249fad-8390-51d0-aa83-c467936b8680',7),
 ('9941b09a-5576-5788-86e4-0df1432f984e','68d370f2-07c1-529f-88c0-bea29c29e1bd',8),
 ('9941b09a-5576-5788-86e4-0df1432f984e','8483ce83-0f4a-56b1-8552-19aadd1e816c',9),
 ('9941b09a-5576-5788-86e4-0df1432f984e','6b96665d-a47f-56b0-9137-05b5b5124097',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('36ace763-5036-5677-99fb-10a4e58aadee','20000000-0000-0000-0000-000000000006',$p$de buurman$p$,$p$el vecino$p$,401,'sustantivo'),
 ('3659012a-5429-5fe6-8dd5-2d4c60798b6c','20000000-0000-0000-0000-000000000006',$p$het gebouw$p$,$p$el edificio$p$,402,'sustantivo'),
 ('b937dc40-3865-5121-a45d-d113b72ad4c3','20000000-0000-0000-0000-000000000006',$p$de collega$p$,$p$el/la colega$p$,403,'sustantivo'),
 ('c46c88ca-f72a-5130-9988-4d3179913064','20000000-0000-0000-0000-000000000006',$p$het pakket$p$,$p$el paquete$p$,404,'sustantivo'),
 ('5375ac36-3a2f-5eb6-9b4f-8e801b72213d','20000000-0000-0000-0000-000000000006',$p$de sleutel$p$,$p$la llave$p$,405,'sustantivo'),
 ('36d199f9-1e89-58d4-892a-d0c31356ad9b','20000000-0000-0000-0000-000000000006',$p$het gesprek$p$,$p$la conversación$p$,406,'sustantivo'),
 ('663e6cba-41fe-57fd-b660-ea1ebdd068d7','20000000-0000-0000-0000-000000000006',$p$de klant$p$,$p$el/la cliente$p$,407,'sustantivo'),
 ('f70f897d-7a9b-5f34-878e-df0b280eef89','20000000-0000-0000-0000-000000000006',$p$het probleem$p$,$p$el problema$p$,408,'sustantivo'),
 ('0b12e40d-4cee-5940-b0c7-0d3b055fb929','20000000-0000-0000-0000-000000000006',$p$de afspraak$p$,$p$la cita/el acuerdo$p$,409,'sustantivo'),
 ('b91d0e9a-45dd-590d-a062-25afb7cdd85b','20000000-0000-0000-0000-000000000006',$p$het antwoord$p$,$p$la respuesta$p$,410,'sustantivo'),
 ('32be1ac3-f968-5f33-9bac-ed139fc29ebd','20000000-0000-0000-0000-000000000006',$p$de reden$p$,$p$la razón$p$,411,'sustantivo'),
 ('908d894c-1a53-56a6-84aa-ecd45bce6131','20000000-0000-0000-0000-000000000006',$p$het advies$p$,$p$el consejo$p$,412,'sustantivo'),
 ('d1dc1b77-421a-5fd8-aa61-cbf98502eaf5','20000000-0000-0000-0000-000000000006',$p$de oplossing$p$,$p$la solución$p$,413,'sustantivo'),
 ('d1f3d754-8cb0-5cf2-91d9-eb90a35b353c','20000000-0000-0000-0000-000000000006',$p$het verhaal$p$,$p$la historia$p$,414,'sustantivo'),
 ('79fb2878-e782-5e64-8b66-abec392837f9','20000000-0000-0000-0000-000000000006',$p$betrouwbaar$p$,$p$fiable$p$,415,'adjetivo'),
 ('45f6bdb1-7a11-575e-911a-d0a62e1584f7','20000000-0000-0000-0000-000000000006',$p$ingewikkeld$p$,$p$complicado$p$,416,'adjetivo')
on conflict (id) do nothing;

-- ── Unidad 16 (B1·nl): La voz pasiva (worden + deelwoord) ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('8a71afcf-6940-51fe-ba0f-d6e1a7ba792f','20000000-0000-0000-0000-000000000006','B1',16,$p$La voz pasiva (worden + deelwoord)$p$,'#B9770E','settings')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('c16a1e5f-fb67-5e8f-8e9f-dab2cbb31801','8a71afcf-6940-51fe-ba0f-d6e1a7ba792f',1,$p$Presente pasivo: wordt/worden + deelwoord$p$,$p$Presente pasivo: wordt/worden + deelwoord$p$,'lesson',15),
 ('5d435e7a-08c5-53da-8a00-7d1b375a70cb','8a71afcf-6940-51fe-ba0f-d6e1a7ba792f',2,$p$El agente con door$p$,$p$El agente con door$p$,'lesson',15),
 ('f0796a1b-72ce-5c79-8b9a-3f2a9efc2455','8a71afcf-6940-51fe-ba0f-d6e1a7ba792f',3,$p$Pasado pasivo: werd/werden + deelwoord$p$,$p$Pasado pasivo: werd/werden + deelwoord$p$,'lesson',15),
 ('bee744d2-23e5-5681-9d21-838c908047a2','8a71afcf-6940-51fe-ba0f-d6e1a7ba792f',4,$p$Perfecto pasivo (is/zijn) y activa frente a pasiva$p$,$p$Perfecto pasivo (is/zijn) y activa frente a pasiva$p$,'lesson',15),
 ('df3c0a54-b3cd-5d87-a335-3727f67f4899','8a71afcf-6940-51fe-ba0f-d6e1a7ba792f',5,$p$🏁 Checkpoint Eenheid 16$p$,$p$Forma la voz pasiva en presente con worden + participio, en pasado con werd/werden + participio y en perfecto con is/zijn + participio, e introduce el agente con door.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('f0cf7ced-08ad-5504-b115-378634cc00a4','20000000-0000-0000-0000-000000000006','checkpoint','B1','8a71afcf-6940-51fe-ba0f-d6e1a7ba792f',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('12e62c07-03de-5263-921e-3fa20b19affb'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','reading','match',$p$Une cada palabra neerlandesa con su significado en español.$p$,$j${"pairs": [{"en": "de fabriek", "es": "la fábrica"}, {"en": "het contract", "es": "el contrato"}, {"en": "repareren", "es": "reparar"}]}$j$::jsonb,$j${"pairs": [["de fabriek", "la fábrica"], ["het contract", "el contrato"], ["repareren", "reparar"]]}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$present_passive_intro$p$, $p$reading$p$]),
('470a8940-f5d0-5bb2-addd-7afafc92a315'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','reading','multiple_choice',$p$Elige la voz pasiva en presente: «La casa se construye».$p$,$j${"options": ["Het huis wordt gebouwd.", "Het huis wordt bouwen.", "Het huis is gebouwd."]}$j$::jsonb,$j${"value": "Het huis wordt gebouwd."}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$present_passive_wordt$p$, $p$reading$p$]),
('207ad4de-8264-56f8-b424-12d2cda3d13c'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','writing','cloze',$p$Completa con la forma correcta de 'worden' en presente (sujeto singular): «El puente se repara».$p$,$j${"text": "De brug ___ gerepareerd."}$j$::jsonb,$j${"value": "wordt", "accepted": ["wordt"]}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$present_passive_wordt_cloze$p$, $p$writing$p$]),
('761a0d49-08ed-5857-bf71-8f89736883d8'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','writing','word_bank',$p$Ordena las fichas para formar la frase pasiva en presente: «El contrato se firma».$p$,$j${"tiles": ["Het", "contract", "wordt", "getekend", "werd", "is"]}$j$::jsonb,$j${"value": "Het contract wordt getekend", "sequence": ["Het", "contract", "wordt", "getekend"]}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$present_passive_word_bank$p$, $p$writing$p$]),
('4fb59352-5b55-54b8-a7af-550eaf40fda0'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','reading','multiple_choice',$p$¿Qué preposición introduce al agente (quien hace la acción) en la voz pasiva neerlandesa?$p$,$j${"options": ["door", "van", "met"]}$j$::jsonb,$j${"value": "door"}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$agent_door_preposition$p$, $p$reading$p$]),
('07e4aa98-c70c-5a90-9cb8-29fe44b87620'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','writing','cloze',$p$Completa con la preposición del agente: «La factura es pagada por el cliente».$p$,$j${"text": "De rekening wordt ___ de klant betaald."}$j$::jsonb,$j${"value": "door", "accepted": ["door"]}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$agent_door_cloze$p$, $p$writing$p$]),
('55f11956-15b0-5599-89f7-a0e975ddaa1b'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','writing','translation',$p$Traduce al neerlandés (presente pasivo con agente): «El libro es leído por el escritor».$p$,$j${"source": "El libro es leído por el escritor."}$j$::jsonb,$j${"value": "Het boek wordt door de schrijver gelezen.", "accepted": ["Het boek wordt door de schrijver gelezen.", "Het boek wordt door de schrijver gelezen", "Het boek wordt gelezen door de schrijver.", "Het boek wordt gelezen door de schrijver"]}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$agent_door_translation$p$, $p$writing$p$]),
('97346778-1589-5b1a-bd9d-9694cad5e860'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','reading','multiple_choice',$p$Elige la voz pasiva en pasado (sujeto singular): «La casa fue construida».$p$,$j${"options": ["Het huis werd gebouwd.", "Het huis wordt gebouwd.", "Het huis was gebouwd."]}$j$::jsonb,$j${"value": "Het huis werd gebouwd."}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$past_passive_werd$p$, $p$reading$p$]),
('ff683926-09c2-5991-93ba-4b76a2f2bcea'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','writing','cloze',$p$El sujeto es plural (de huizen = las casas). Completa con la forma de 'worden' en pasado: «Las casas fueron construidas en 1990».$p$,$j${"text": "De huizen ___ in 1990 gebouwd."}$j$::jsonb,$j${"value": "werden", "accepted": ["werden"]}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$past_passive_werden_plural_cloze$p$, $p$writing$p$]),
('574d0721-f231-508b-ba2d-79013843fd84'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','writing','reorder',$p$Ordena las palabras para formar la frase pasiva en pasado: «La fábrica fue fundada por mi abuelo».$p$,$j${"tiles": ["De", "fabriek", "werd", "door", "mijn", "opa", "opgericht"]}$j$::jsonb,$j${"value": "De fabriek werd door mijn opa opgericht"}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$past_passive_reorder$p$, $p$writing$p$]),
('5cdae9e4-f8cb-5f87-ac7d-8dc7666c907a'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','reading','multiple_choice',$p$El perfecto pasivo usa 'is/zijn' + participio (sin 'geworden'). Elige la frase correcta: «El trabajo ya ha sido hecho».$p$,$j${"options": ["Het werk is al gedaan.", "Het werk wordt al gedaan.", "Het werk heeft al gedaan."]}$j$::jsonb,$j${"value": "Het werk is al gedaan."}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$perfect_passive_is$p$, $p$reading$p$]),
('7130a378-5086-55ee-892d-03845233cf60'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','reading','multiple_choice',$p$Una frase está en ACTIVA y otra en PASIVA. ¿Cuál es la PASIVA?$p$,$j${"options": ["Het huis wordt door de arbeider gebouwd.", "De arbeider bouwt het huis.", "De arbeider heeft het huis gebouwd."]}$j$::jsonb,$j${"value": "Het huis wordt door de arbeider gebouwd."}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$active_vs_passive$p$, $p$reading$p$]),
('acf02142-8c3f-5def-85b6-dff876ed03bd'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Het huis wordt gebouwd.", "Het huis werd gebouwd.", "Het huis is gebouwd."], "say": "Het huis wordt gebouwd.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/acf02142-8c3f-5def-85b6-dff876ed03bd.mp3"}$j$::jsonb,$j${"value": "Het huis wordt gebouwd."}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$present_passive_listening$p$, $p$listening$p$]),
('5e53bb7e-10d8-5216-aec3-7f4ce4017ff0'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["De brug werd gerepareerd.", "De brug wordt gerepareerd.", "De brug is gerepareerd."], "say": "De brug werd gerepareerd.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/5e53bb7e-10d8-5216-aec3-7f4ce4017ff0.mp3"}$j$::jsonb,$j${"value": "De brug werd gerepareerd."}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$past_passive_listening$p$, $p$listening$p$]),
('7abfb5ef-b5d6-51f4-89aa-e8ff4057d809'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','listening','listening',$p$Escucha la frase pasiva con agente y elige la que oíste.$p$,$j${"options": ["Het boek wordt door de schrijver geschreven.", "Het boek wordt door de schrijver gelezen.", "Het boek werd door de schrijver geschreven."], "say": "Het boek wordt door de schrijver geschreven.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/7abfb5ef-b5d6-51f4-89aa-e8ff4057d809.mp3"}$j$::jsonb,$j${"value": "Het boek wordt door de schrijver geschreven."}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$agent_door_listening$p$, $p$listening$p$]),
('ee09f541-61f0-5e18-8e9b-5c50410f0ec1'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["De brieven zijn verstuurd.", "De brieven worden verstuurd.", "De brieven zijn ontvangen."], "say": "De brieven zijn verstuurd.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/ee09f541-61f0-5e18-8e9b-5c50410f0ec1.mp3"}$j$::jsonb,$j${"value": "De brieven zijn verstuurd."}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$perfect_passive_listening$p$, $p$listening$p$]),
('47bebade-c25d-5fe0-91c1-730393d9d792'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta esta frase pasiva con agente.$p$,$j${"text": "Het huis wordt door de arbeider gebouwd.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/47bebade-c25d-5fe0-91c1-730393d9d792.mp3"}$j$::jsonb,$j${"expected": "Het huis wordt door de arbeider gebouwd."}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$agent_door_speaking$p$, $p$speaking$p$]),
('ac03e278-be58-539c-b224-468398bec62e'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta esta frase pasiva en pasado.$p$,$j${"text": "De rekening werd gisteren betaald.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/ac03e278-be58-539c-b224-468398bec62e.mp3"}$j$::jsonb,$j${"expected": "De rekening werd gisteren betaald."}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$past_passive_speaking$p$, $p$speaking$p$]),
('e55b0a5f-d218-578d-b28f-a794a8baf92e'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta esta frase pasiva en perfecto.$p$,$j${"text": "Het contract is door de directeur getekend.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/e55b0a5f-d218-578d-b28f-a794a8baf92e.mp3"}$j$::jsonb,$j${"expected": "Het contract is door de directeur getekend."}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$perfect_passive_speaking$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('c16a1e5f-fb67-5e8f-8e9f-dab2cbb31801','12e62c07-03de-5263-921e-3fa20b19affb',1),
 ('c16a1e5f-fb67-5e8f-8e9f-dab2cbb31801','470a8940-f5d0-5bb2-addd-7afafc92a315',2),
 ('c16a1e5f-fb67-5e8f-8e9f-dab2cbb31801','207ad4de-8264-56f8-b424-12d2cda3d13c',3),
 ('c16a1e5f-fb67-5e8f-8e9f-dab2cbb31801','761a0d49-08ed-5857-bf71-8f89736883d8',4),
 ('c16a1e5f-fb67-5e8f-8e9f-dab2cbb31801','acf02142-8c3f-5def-85b6-dff876ed03bd',5),
 ('5d435e7a-08c5-53da-8a00-7d1b375a70cb','4fb59352-5b55-54b8-a7af-550eaf40fda0',1),
 ('5d435e7a-08c5-53da-8a00-7d1b375a70cb','07e4aa98-c70c-5a90-9cb8-29fe44b87620',2),
 ('5d435e7a-08c5-53da-8a00-7d1b375a70cb','55f11956-15b0-5599-89f7-a0e975ddaa1b',3),
 ('5d435e7a-08c5-53da-8a00-7d1b375a70cb','7abfb5ef-b5d6-51f4-89aa-e8ff4057d809',4),
 ('5d435e7a-08c5-53da-8a00-7d1b375a70cb','47bebade-c25d-5fe0-91c1-730393d9d792',5),
 ('f0796a1b-72ce-5c79-8b9a-3f2a9efc2455','97346778-1589-5b1a-bd9d-9694cad5e860',1),
 ('f0796a1b-72ce-5c79-8b9a-3f2a9efc2455','ff683926-09c2-5991-93ba-4b76a2f2bcea',2),
 ('f0796a1b-72ce-5c79-8b9a-3f2a9efc2455','574d0721-f231-508b-ba2d-79013843fd84',3),
 ('f0796a1b-72ce-5c79-8b9a-3f2a9efc2455','5e53bb7e-10d8-5216-aec3-7f4ce4017ff0',4),
 ('f0796a1b-72ce-5c79-8b9a-3f2a9efc2455','ac03e278-be58-539c-b224-468398bec62e',5),
 ('bee744d2-23e5-5681-9d21-838c908047a2','5cdae9e4-f8cb-5f87-ac7d-8dc7666c907a',1),
 ('bee744d2-23e5-5681-9d21-838c908047a2','7130a378-5086-55ee-892d-03845233cf60',2),
 ('bee744d2-23e5-5681-9d21-838c908047a2','ee09f541-61f0-5e18-8e9b-5c50410f0ec1',3),
 ('bee744d2-23e5-5681-9d21-838c908047a2','e55b0a5f-d218-578d-b28f-a794a8baf92e',4),
 ('df3c0a54-b3cd-5d87-a335-3727f67f4899','12e62c07-03de-5263-921e-3fa20b19affb',1),
 ('df3c0a54-b3cd-5d87-a335-3727f67f4899','470a8940-f5d0-5bb2-addd-7afafc92a315',2),
 ('df3c0a54-b3cd-5d87-a335-3727f67f4899','4fb59352-5b55-54b8-a7af-550eaf40fda0',3),
 ('df3c0a54-b3cd-5d87-a335-3727f67f4899','207ad4de-8264-56f8-b424-12d2cda3d13c',4),
 ('df3c0a54-b3cd-5d87-a335-3727f67f4899','761a0d49-08ed-5857-bf71-8f89736883d8',5),
 ('df3c0a54-b3cd-5d87-a335-3727f67f4899','07e4aa98-c70c-5a90-9cb8-29fe44b87620',6),
 ('df3c0a54-b3cd-5d87-a335-3727f67f4899','acf02142-8c3f-5def-85b6-dff876ed03bd',7),
 ('df3c0a54-b3cd-5d87-a335-3727f67f4899','5e53bb7e-10d8-5216-aec3-7f4ce4017ff0',8),
 ('df3c0a54-b3cd-5d87-a335-3727f67f4899','47bebade-c25d-5fe0-91c1-730393d9d792',9),
 ('df3c0a54-b3cd-5d87-a335-3727f67f4899','ac03e278-be58-539c-b224-468398bec62e',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('658c3e16-4b9b-5780-8e2a-62901f107627','20000000-0000-0000-0000-000000000006',$p$worden$p$,$p$ser (auxiliar de pasiva)$p$,421,'werkwoord'),
 ('cb6d42d3-49d5-5ee0-90f2-b12ba475ec22','20000000-0000-0000-0000-000000000006',$p$de fabriek$p$,$p$la fábrica$p$,422,'noun'),
 ('19941292-baa6-59e4-a669-272b0fa9b677','20000000-0000-0000-0000-000000000006',$p$de brug$p$,$p$el puente$p$,423,'noun'),
 ('aa1dadda-023e-55e9-9a4d-960fabdaf6c6','20000000-0000-0000-0000-000000000006',$p$de brief$p$,$p$la carta$p$,424,'noun'),
 ('f5b91557-059e-53f8-9e18-0316b0896004','20000000-0000-0000-0000-000000000006',$p$het pakket$p$,$p$el paquete$p$,425,'noun'),
 ('90c7441b-ca00-5d21-84a5-03448585b059','20000000-0000-0000-0000-000000000006',$p$het contract$p$,$p$el contrato$p$,426,'noun'),
 ('d94ac8eb-0889-5056-8be6-4692047265af','20000000-0000-0000-0000-000000000006',$p$de rekening$p$,$p$la factura / la cuenta$p$,427,'noun'),
 ('8425b076-b0d1-5f2f-bda0-784f159a50f0','20000000-0000-0000-0000-000000000006',$p$de arbeider$p$,$p$el obrero$p$,428,'noun'),
 ('09528ec3-8622-5785-9a3b-975534c2e7c0','20000000-0000-0000-0000-000000000006',$p$de schrijver$p$,$p$el escritor$p$,429,'noun'),
 ('6c4ce325-58c2-5292-b467-aee4beb288de','20000000-0000-0000-0000-000000000006',$p$de machine$p$,$p$la máquina$p$,430,'noun'),
 ('ea0b2a34-e51c-5665-a4ca-c4ea8d6ca591','20000000-0000-0000-0000-000000000006',$p$het resultaat$p$,$p$el resultado$p$,431,'noun'),
 ('30f9d5db-6045-5269-848d-627caca760b4','20000000-0000-0000-0000-000000000006',$p$bouwen$p$,$p$construir$p$,432,'werkwoord'),
 ('632fe3a1-da80-5ed9-8dd2-a768fac8c0d9','20000000-0000-0000-0000-000000000006',$p$repareren$p$,$p$reparar$p$,433,'werkwoord'),
 ('b4cf084a-ae8e-5c8c-9d9d-eb492315bb19','20000000-0000-0000-0000-000000000006',$p$bezorgen$p$,$p$entregar / repartir$p$,434,'werkwoord'),
 ('d4ba291e-7620-5d41-88b6-bea127f173e2','20000000-0000-0000-0000-000000000006',$p$door$p$,$p$por (agente)$p$,435,'voorzetsel'),
 ('0b2a7e58-ea6a-55d0-8727-348dde68f2d2','20000000-0000-0000-0000-000000000006',$p$opgericht$p$,$p$fundado$p$,436,'voltooid deelwoord')
on conflict (id) do nothing;

-- ── Unidad 17 (B1·nl): Verbos con preposición y «om…te» ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('4630a4c2-9fe6-5a12-b093-95de991d811f','20000000-0000-0000-0000-000000000006','B1',17,$p$Verbos con preposición y «om…te»$p$,'#922B21','alternate_email')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('90eca715-aa91-5701-81ec-025348b2a5e4','4630a4c2-9fe6-5a12-b093-95de991d811f',1,$p$Esperar, pensar, mirar, escuchar (op/aan/naar)$p$,$p$Esperar, pensar, mirar, escuchar (op/aan/naar)$p$,'lesson',15),
 ('a0b1a8cc-e534-5aca-9c46-c642c2c5bd31','4630a4c2-9fe6-5a12-b093-95de991d811f',2,$p$Gustar, temer, buscar, hablar (van/voor/naar/over)$p$,$p$Gustar, temer, buscar, hablar (van/voor/naar/over)$p$,'lesson',15),
 ('1112bcd3-2eb4-5175-9cb3-db0ac6a2ec0a','4630a4c2-9fe6-5a12-b093-95de991d811f',3,$p$Finalidad: «om … te + infinitivo»$p$,$p$Finalidad: «om … te + infinitivo»$p$,'lesson',15),
 ('e4af0050-c334-53f1-8988-4a8e4553c35d','4630a4c2-9fe6-5a12-b093-95de991d811f',4,$p$Todo junto: preposición fija y om…te$p$,$p$Todo junto: preposición fija y om…te$p$,'lesson',15),
 ('051a41f0-f228-57b1-b093-81c3575f66f9','4630a4c2-9fe6-5a12-b093-95de991d811f',5,$p$🏁 Checkpoint Eenheid 17$p$,$p$Usa la preposición fija correcta de cada verbo (wachten op, denken aan, houden van, bang zijn voor, kijken/luisteren/zoeken naar, praten over) y expresa finalidad con «om … te + infinitivo».$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('26c9ad09-02ce-5f31-806e-e563ca77470e','20000000-0000-0000-0000-000000000006','checkpoint','B1','4630a4c2-9fe6-5a12-b093-95de991d811f',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('b3aa65f2-e484-5e23-b596-3d278d6bc65d'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','reading','match',$p$Une cada verbo con su preposición fija.$p$,$j${"pairs": [{"en": "wachten op", "es": "esperar (a)"}, {"en": "denken aan", "es": "pensar en"}, {"en": "luisteren naar", "es": "escuchar"}]}$j$::jsonb,$j${"pairs": [["wachten op", "esperar (a)"], ["denken aan", "pensar en"], ["luisteren naar", "escuchar"]]}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$vaste_voorzetsels_op_aan$p$, $p$reading$p$]),
('43805066-9ec5-5329-9c1a-ee9b654d384e'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','reading','multiple_choice',$p$Elige la preposición correcta: «Ik wacht ___ de bus.» (Espero el autobús.)$p$,$j${"options": ["op", "aan", "naar"]}$j$::jsonb,$j${"value": "op"}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$wachten_op$p$, $p$reading$p$]),
('15d31ba8-ae5d-5949-b4b7-cba66ee48484'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','writing','cloze',$p$Completa con la preposición fija de «mirar/ver»: «Vemos una película.»$p$,$j${"text": "Wij kijken ___ een film."}$j$::jsonb,$j${"value": "naar", "accepted": ["naar"]}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$kijken_naar$p$, $p$writing$p$]),
('3136e518-9f2f-5d06-9dcf-94d7fa98e5b6'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ik luister naar muziek.", "Ik luister op muziek.", "Ik luister aan muziek."], "say": "Ik luister naar muziek.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/3136e518-9f2f-5d06-9dcf-94d7fa98e5b6.mp3"}$j$::jsonb,$j${"value": "Ik luister naar muziek."}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$luisteren_naar$p$, $p$listening$p$]),
('46ce0c3c-eab5-5819-af07-799c24a259c4'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Ik wacht op de trein en denk aan jou.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/46ce0c3c-eab5-5819-af07-799c24a259c4.mp3"}$j$::jsonb,$j${"expected": "Ik wacht op de trein en denk aan jou."}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$wachten_op$p$, $p$speaking$p$]),
('25982d7d-fa06-5feb-810c-d687d486ece7'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','reading','multiple_choice',$p$Elige la preposición correcta: «Ik hou ___ muziek.» (Me gusta la música.)$p$,$j${"options": ["van", "voor", "naar"]}$j$::jsonb,$j${"value": "van"}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$houden_van$p$, $p$reading$p$]),
('4db64826-10c1-51d0-bfd3-f0e558989cca'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','reading','multiple_choice',$p$Elige la preposición correcta: «Ik ben bang ___ spinnen.» (Tengo miedo de las arañas.)$p$,$j${"options": ["voor", "van", "op"]}$j$::jsonb,$j${"value": "voor"}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$bang_zijn_voor$p$, $p$reading$p$]),
('b09c4bde-a960-5e34-ad4c-16d904e15f93'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','writing','cloze',$p$Completa con la preposición fija de «hablar de/sobre»: «Hablamos del problema.»$p$,$j${"text": "We praten ___ het probleem."}$j$::jsonb,$j${"value": "over", "accepted": ["over"]}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$praten_over$p$, $p$writing$p$]),
('46b0ef1b-5cd7-5169-8828-128240417f0f'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','writing','word_bank',$p$Ordena las fichas para formar: «Busco mis llaves.»$p$,$j${"tiles": ["Ik", "zoek", "naar", "mijn", "sleutels", "op", "over"]}$j$::jsonb,$j${"value": "Ik zoek naar mijn sleutels", "sequence": ["Ik", "zoek", "naar", "mijn", "sleutels"]}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$zoeken_naar$p$, $p$writing$p$]),
('6650f9b6-083d-5f90-a097-451002270b19'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Zij houdt van koffie.", "Zij houdt voor koffie.", "Zij houdt naar koffie."], "say": "Zij houdt van koffie.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/6650f9b6-083d-5f90-a097-451002270b19.mp3"}$j$::jsonb,$j${"value": "Zij houdt van koffie."}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$houden_van$p$, $p$listening$p$]),
('72321ceb-638e-5639-b6b0-ae3df346a39b'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Mijn zus is bang voor honden, maar ik hou van honden.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/72321ceb-638e-5639-b6b0-ae3df346a39b.mp3"}$j$::jsonb,$j${"expected": "Mijn zus is bang voor honden, maar ik hou van honden."}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$bang_zijn_voor$p$, $p$speaking$p$]),
('2ecb6432-236b-5eb5-b958-2c7610b9c1ea'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','reading','match',$p$Une cada frase de finalidad con su traducción.$p$,$j${"pairs": [{"en": "om brood te kopen", "es": "para comprar pan"}, {"en": "om Nederlands te leren", "es": "para aprender neerlandés"}, {"en": "om te rusten", "es": "para descansar"}]}$j$::jsonb,$j${"pairs": [["om brood te kopen", "para comprar pan"], ["om Nederlands te leren", "para aprender neerlandés"], ["om te rusten", "para descansar"]]}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$om_te_finaliteit$p$, $p$reading$p$]),
('8558851c-aeee-596e-94ea-1ddf36f883e8'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','reading','multiple_choice',$p$Elige la frase correcta con «om…te»: «Voy a la tienda para comprar pan.»$p$,$j${"options": ["Ik ga naar de winkel om brood te kopen.", "Ik ga naar de winkel om te brood kopen.", "Ik ga naar de winkel om brood kopen te."]}$j$::jsonb,$j${"value": "Ik ga naar de winkel om brood te kopen."}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$om_te_finaliteit$p$, $p$reading$p$]),
('1bc2edd7-739f-568b-87a1-e16f2e95f414'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','writing','cloze',$p$Completa con la partícula que va justo antes del infinitivo en «om … ___ + infinitivo»: «Estudio para aprender neerlandés.»$p$,$j${"text": "Ik studeer om Nederlands ___ leren."}$j$::jsonb,$j${"value": "te", "accepted": ["te"]}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$om_te_finaliteit$p$, $p$writing$p$]),
('bc1e8fb5-0799-5dda-9d71-4bb681bb0cda'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','writing','translation',$p$Traduce al neerlandés: «Trabajo para ganar dinero.»$p$,$j${"source": "Trabajo para ganar dinero."}$j$::jsonb,$j${"value": "Ik werk om geld te verdienen.", "accepted": ["Ik werk om geld te verdienen.", "Ik werk om geld te verdienen"]}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$om_te_finaliteit$p$, $p$writing$p$]),
('c0335ccb-e617-5805-88f6-c87983eb840e'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ik bel je om een afspraak te maken.", "Ik schrijf je om een cadeau te kopen.", "Ik zie je om een pauze te nemen."], "say": "Ik bel je om een afspraak te maken.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/c0335ccb-e617-5805-88f6-c87983eb840e.mp3"}$j$::jsonb,$j${"value": "Ik bel je om een afspraak te maken."}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$om_te_finaliteit$p$, $p$listening$p$]),
('921b3f8a-6609-5ee1-a0ad-957a9388a3e6'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','writing','reorder',$p$Ordena las palabras: «Espero a mi amigo para hablar.» (esperar + om…te)$p$,$j${"tiles": ["Ik", "wacht", "op", "mijn", "vriend", "om", "te", "praten", "naar", "aan"]}$j$::jsonb,$j${"value": "Ik wacht op mijn vriend om te praten"}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$vaste_voorzetsels_reorder$p$, $p$writing$p$]),
('d2e56731-d24d-5bb2-b2ff-dfdc99cd7afe'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ik wacht erop.", "Ik wacht eraan.", "Ik wacht ernaar."], "say": "Ik wacht erop.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/d2e56731-d24d-5bb2-b2ff-dfdc99cd7afe.mp3"}$j$::jsonb,$j${"value": "Ik wacht erop."}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$pronominaal_bijwoord$p$, $p$listening$p$]),
('cafefe1b-8ce2-565d-8f7d-2d6ebf884009'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Ik denk aan de toekomst en zoek naar een goede baan.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/cafefe1b-8ce2-565d-8f7d-2d6ebf884009.mp3"}$j$::jsonb,$j${"expected": "Ik denk aan de toekomst en zoek naar een goede baan."}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$vaste_voorzetsels_mix$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('90eca715-aa91-5701-81ec-025348b2a5e4','b3aa65f2-e484-5e23-b596-3d278d6bc65d',1),
 ('90eca715-aa91-5701-81ec-025348b2a5e4','43805066-9ec5-5329-9c1a-ee9b654d384e',2),
 ('90eca715-aa91-5701-81ec-025348b2a5e4','15d31ba8-ae5d-5949-b4b7-cba66ee48484',3),
 ('90eca715-aa91-5701-81ec-025348b2a5e4','3136e518-9f2f-5d06-9dcf-94d7fa98e5b6',4),
 ('90eca715-aa91-5701-81ec-025348b2a5e4','46ce0c3c-eab5-5819-af07-799c24a259c4',5),
 ('a0b1a8cc-e534-5aca-9c46-c642c2c5bd31','25982d7d-fa06-5feb-810c-d687d486ece7',1),
 ('a0b1a8cc-e534-5aca-9c46-c642c2c5bd31','4db64826-10c1-51d0-bfd3-f0e558989cca',2),
 ('a0b1a8cc-e534-5aca-9c46-c642c2c5bd31','b09c4bde-a960-5e34-ad4c-16d904e15f93',3),
 ('a0b1a8cc-e534-5aca-9c46-c642c2c5bd31','46b0ef1b-5cd7-5169-8828-128240417f0f',4),
 ('a0b1a8cc-e534-5aca-9c46-c642c2c5bd31','6650f9b6-083d-5f90-a097-451002270b19',5),
 ('a0b1a8cc-e534-5aca-9c46-c642c2c5bd31','72321ceb-638e-5639-b6b0-ae3df346a39b',6),
 ('1112bcd3-2eb4-5175-9cb3-db0ac6a2ec0a','2ecb6432-236b-5eb5-b958-2c7610b9c1ea',1),
 ('1112bcd3-2eb4-5175-9cb3-db0ac6a2ec0a','8558851c-aeee-596e-94ea-1ddf36f883e8',2),
 ('1112bcd3-2eb4-5175-9cb3-db0ac6a2ec0a','1bc2edd7-739f-568b-87a1-e16f2e95f414',3),
 ('1112bcd3-2eb4-5175-9cb3-db0ac6a2ec0a','bc1e8fb5-0799-5dda-9d71-4bb681bb0cda',4),
 ('1112bcd3-2eb4-5175-9cb3-db0ac6a2ec0a','c0335ccb-e617-5805-88f6-c87983eb840e',5),
 ('e4af0050-c334-53f1-8988-4a8e4553c35d','921b3f8a-6609-5ee1-a0ad-957a9388a3e6',1),
 ('e4af0050-c334-53f1-8988-4a8e4553c35d','d2e56731-d24d-5bb2-b2ff-dfdc99cd7afe',2),
 ('e4af0050-c334-53f1-8988-4a8e4553c35d','cafefe1b-8ce2-565d-8f7d-2d6ebf884009',3),
 ('051a41f0-f228-57b1-b093-81c3575f66f9','b3aa65f2-e484-5e23-b596-3d278d6bc65d',1),
 ('051a41f0-f228-57b1-b093-81c3575f66f9','43805066-9ec5-5329-9c1a-ee9b654d384e',2),
 ('051a41f0-f228-57b1-b093-81c3575f66f9','25982d7d-fa06-5feb-810c-d687d486ece7',3),
 ('051a41f0-f228-57b1-b093-81c3575f66f9','15d31ba8-ae5d-5949-b4b7-cba66ee48484',4),
 ('051a41f0-f228-57b1-b093-81c3575f66f9','b09c4bde-a960-5e34-ad4c-16d904e15f93',5),
 ('051a41f0-f228-57b1-b093-81c3575f66f9','46b0ef1b-5cd7-5169-8828-128240417f0f',6),
 ('051a41f0-f228-57b1-b093-81c3575f66f9','3136e518-9f2f-5d06-9dcf-94d7fa98e5b6',7),
 ('051a41f0-f228-57b1-b093-81c3575f66f9','6650f9b6-083d-5f90-a097-451002270b19',8),
 ('051a41f0-f228-57b1-b093-81c3575f66f9','46ce0c3c-eab5-5819-af07-799c24a259c4',9),
 ('051a41f0-f228-57b1-b093-81c3575f66f9','72321ceb-638e-5639-b6b0-ae3df346a39b',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('573933eb-9f25-53cf-8b9e-1a40889839ab','20000000-0000-0000-0000-000000000006',$p$wachten op$p$,$p$esperar (a)$p$,441,'werkwoord'),
 ('eb93ad09-aec4-58c9-a81d-85ec3b2904dd','20000000-0000-0000-0000-000000000006',$p$denken aan$p$,$p$pensar en$p$,442,'werkwoord'),
 ('c7ebef15-d819-59c8-9dc2-395e43017615','20000000-0000-0000-0000-000000000006',$p$kijken naar$p$,$p$mirar / ver$p$,443,'werkwoord'),
 ('cd7b93c3-d671-5974-8c79-62962f07d059','20000000-0000-0000-0000-000000000006',$p$luisteren naar$p$,$p$escuchar$p$,444,'werkwoord'),
 ('73286bab-9f01-5629-aabc-42f24b0a2461','20000000-0000-0000-0000-000000000006',$p$houden van$p$,$p$gustar / querer$p$,445,'werkwoord'),
 ('eed3990b-edbd-574a-b252-28289d6bf178','20000000-0000-0000-0000-000000000006',$p$bang zijn voor$p$,$p$tener miedo de$p$,446,'werkwoord'),
 ('ad83b46d-d42b-5417-9e1a-32dbc92bc0a6','20000000-0000-0000-0000-000000000006',$p$zoeken naar$p$,$p$buscar$p$,447,'werkwoord'),
 ('a7482cb1-efbd-5b7a-ae5a-15448ef61e50','20000000-0000-0000-0000-000000000006',$p$praten over$p$,$p$hablar de/sobre$p$,448,'werkwoord'),
 ('3effb528-0dec-5a50-84b3-56b494c8c35b','20000000-0000-0000-0000-000000000006',$p$de bus$p$,$p$el autobús$p$,449,'zelfstandig naamwoord'),
 ('108c2ab8-7650-54b1-9a8a-16139a91299f','20000000-0000-0000-0000-000000000006',$p$de trein$p$,$p$el tren$p$,450,'zelfstandig naamwoord'),
 ('2fa1ce36-06ff-5a9c-980f-c13215f527e7','20000000-0000-0000-0000-000000000006',$p$de toekomst$p$,$p$el futuro$p$,451,'zelfstandig naamwoord'),
 ('f3c2a6e3-dac5-59bc-bbdd-e5b98c1e379e','20000000-0000-0000-0000-000000000006',$p$de muziek$p$,$p$la música$p$,452,'zelfstandig naamwoord'),
 ('5cf76c9c-a112-5ced-bda3-f499032a7b58','20000000-0000-0000-0000-000000000006',$p$de spin$p$,$p$la araña$p$,453,'zelfstandig naamwoord'),
 ('6dd4aeec-b6c2-58a3-871e-c66082d6002b','20000000-0000-0000-0000-000000000006',$p$de sleutel$p$,$p$la llave$p$,454,'zelfstandig naamwoord'),
 ('054127e0-ed28-5281-a4fc-50327693292f','20000000-0000-0000-0000-000000000006',$p$het probleem$p$,$p$el problema$p$,455,'zelfstandig naamwoord'),
 ('f5c1c800-37cf-5e29-8b00-08c490140326','20000000-0000-0000-0000-000000000006',$p$om te$p$,$p$para (finalidad)$p$,456,'uitdrukking')
on conflict (id) do nothing;

-- ── Unidad 18 (B1·nl): Lo que había pasado (condicional irreal) ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('d25529d2-fa5b-5054-997c-a9e0f3eed192','20000000-0000-0000-0000-000000000006','B1',18,$p$Lo que había pasado (condicional irreal)$p$,'#4A235A','history_toggle_off')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('a2f8c606-64ce-54e2-a2fe-9dfc5a9f77c7','d25529d2-fa5b-5054-997c-a9e0f3eed192',1,$p$Toen ik aankwam, was hij al vertrokken (voltooid verleden tijd)$p$,$p$Toen ik aankwam, was hij al vertrokken (voltooid verleden tijd)$p$,'lesson',15),
 ('e4790c63-c703-51a5-a48f-7119560ce070','d25529d2-fa5b-5054-997c-a9e0f3eed192',2,$p$had gehad vs. was gegaan (elección hebben/zijn)$p$,$p$had gehad vs. was gegaan (elección hebben/zijn)$p$,'lesson',15),
 ('b6c5227b-ac5e-50b1-81d6-4e9503ff9edc','d25529d2-fa5b-5054-997c-a9e0f3eed192',3,$p$Als ik tijd had gehad, zou ik zijn gekomen (condicional irreal del pasado)$p$,$p$Als ik tijd had gehad, zou ik zijn gekomen (condicional irreal del pasado)$p$,'lesson',15),
 ('16c5a0a4-c8a0-5b94-9827-c9ff338159e2','d25529d2-fa5b-5054-997c-a9e0f3eed192',4,$p$Repaso B1: zou + subordinadas$p$,$p$Repaso B1: zou + subordinadas$p$,'lesson',15),
 ('058676d8-6978-5757-a1aa-6fde141a4a09','d25529d2-fa5b-5054-997c-a9e0f3eed192',5,$p$🏁 Checkpoint Eenheid 18$p$,$p$Expresa qué había pasado (voltooid verleden tijd: had/was + participio) e hipótesis y arrepentimientos sobre el pasado con el condicional irreal (zou + hebben/zijn + participio).$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('cdf682d7-ab75-5b64-878f-1fd7c756c04a','20000000-0000-0000-0000-000000000006','checkpoint','B1','d25529d2-fa5b-5054-997c-a9e0f3eed192',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('bff1dcc8-a672-5b49-9bf6-d00566043c05'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','reading','match',$p$Une cada frase neerlandesa con su significado en español.$p$,$j${"pairs": [{"en": "Toen ik aankwam, was hij al vertrokken", "es": "Cuando llegué, él ya se había ido"}, {"en": "Ik had het niet geweten", "es": "Yo no lo había sabido"}, {"en": "We hadden de trein gemist", "es": "Habíamos perdido el tren"}]}$j$::jsonb,$j${"pairs": [["Toen ik aankwam, was hij al vertrokken", "Cuando llegué, él ya se había ido"], ["Ik had het niet geweten", "Yo no lo había sabido"], ["We hadden de trein gemist", "Habíamos perdido el tren"]]}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$plusquamperfectum_intro$p$, $p$reading$p$]),
('856b384e-5e6e-5ba8-ae67-61be85d0d5b8'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','reading','multiple_choice',$p$¿Cuál frase dice correctamente 'Yo ya había comido' (voltooid verleden tijd)?$p$,$j${"options": ["Ik had al gegeten.", "Ik heb al gegeten.", "Ik was al gegeten."]}$j$::jsonb,$j${"value": "Ik had al gegeten."}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$plusquamperfectum_hebben$p$, $p$reading$p$]),
('c25d0982-4d22-5717-9360-3a734aeb1232'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["We hadden de film al gezien.", "We hebben de film al gezien.", "We waren de film al gezien."], "say": "We hadden de film al gezien.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/c25d0982-4d22-5717-9360-3a734aeb1232.mp3"}$j$::jsonb,$j${"value": "We hadden de film al gezien."}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$plusquamperfectum_hebben$p$, $p$listening$p$]),
('a764a310-85e4-5aa6-8167-b3a4be1835af'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Toen we op het station kwamen, was de trein al vertrokken.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/a764a310-85e4-5aa6-8167-b3a4be1835af.mp3"}$j$::jsonb,$j${"expected": "Toen we op het station kwamen, was de trein al vertrokken."}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$plusquamperfectum_zijn$p$, $p$speaking$p$]),
('c50e8937-a823-5e6f-a165-8909fa2c16d1'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','reading','multiple_choice',$p$¿Qué auxiliar necesita 'gaan' en el pluscuamperfecto? 'Ellos ya se habían ido a casa.'$p$,$j${"options": ["Ze waren al naar huis gegaan.", "Ze hadden al naar huis gegaan.", "Ze zouden al naar huis gegaan."]}$j$::jsonb,$j${"value": "Ze waren al naar huis gegaan."}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$aux_choice_zijn$p$, $p$reading$p$]),
('ffda48c4-d55a-5233-a9c9-ce9e6b1eb8c2'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','writing','cloze',$p$Completa con el auxiliar correcto (verbo 'doen', usa hebben): 'Ella ya lo había hecho.'$p$,$j${"text": "Ze ___ het al gedaan."}$j$::jsonb,$j${"value": "had", "accepted": ["had"]}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$aux_choice_hebben$p$, $p$writing$p$]),
('56604f3a-c2fa-5153-91f0-05b185dc1bb9'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ik was naar huis gegaan voordat het begon te regenen.", "Ik had naar huis gegaan voordat het begon te regenen.", "Ik ben naar huis gegaan voordat het begon te regenen."], "say": "Ik was naar huis gegaan voordat het begon te regenen.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/56604f3a-c2fa-5153-91f0-05b185dc1bb9.mp3"}$j$::jsonb,$j${"value": "Ik was naar huis gegaan voordat het begon te regenen."}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$aux_choice_contrast$p$, $p$listening$p$]),
('0be8176c-a31f-5808-8f7b-f6259fea3094'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','writing','word_bank',$p$Ordena las fichas para decir: 'Cuando ella llamó, yo ya me había ido.'$p$,$j${"tiles": ["Toen", "ze", "belde", "was", "ik", "al", "vertrokken", "had", "gegaan"]}$j$::jsonb,$j${"value": "Toen ze belde was ik al vertrokken", "sequence": ["Toen", "ze", "belde", "was", "ik", "al", "vertrokken"]}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$aux_choice_zijn$p$, $p$writing$p$]),
('a2dac981-b74c-5e09-8f0e-ba893082ee90'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ik had mijn sleutels thuis vergeten.", "Ik was mijn sleutels thuis vergeten.", "Ik heb mijn sleutels thuis vergeten."], "say": "Ik had mijn sleutels thuis vergeten.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/a2dac981-b74c-5e09-8f0e-ba893082ee90.mp3"}$j$::jsonb,$j${"value": "Ik had mijn sleutels thuis vergeten."}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$aux_choice_hebben$p$, $p$listening$p$]),
('1e10535e-d784-5435-a7f8-4b22944526c0'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Ik had het boek gelezen en zij was naar huis gegaan.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/1e10535e-d784-5435-a7f8-4b22944526c0.mp3"}$j$::jsonb,$j${"expected": "Ik had het boek gelezen en zij was naar huis gegaan."}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$aux_choice_contrast$p$, $p$speaking$p$]),
('d8a8f5f0-29de-54d9-902b-c2bc4e1c830c'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','reading','match',$p$Une cada frase neerlandesa con su significado en español.$p$,$j${"pairs": [{"en": "Als ik tijd had gehad, zou ik zijn gekomen", "es": "Si hubiera tenido tiempo, habría venido"}, {"en": "Dat zou beter zijn geweest", "es": "Eso habría sido mejor"}, {"en": "Ik zou het hebben geweten", "es": "Lo habría sabido"}]}$j$::jsonb,$j${"pairs": [["Als ik tijd had gehad, zou ik zijn gekomen", "Si hubiera tenido tiempo, habría venido"], ["Dat zou beter zijn geweest", "Eso habría sido mejor"], ["Ik zou het hebben geweten", "Lo habría sabido"]]}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$irreal_past_intro$p$, $p$reading$p$]),
('ea22c92f-47e7-5319-bf45-3fdef00e602a'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','reading','multiple_choice',$p$¿Cuál frase expresa 'Si hubiera tenido dinero, habría comprado el coche'?$p$,$j${"options": ["Als ik geld had gehad, zou ik de auto hebben gekocht.", "Als ik geld had gehad, zou ik de auto zijn gekocht.", "Als ik geld heb, zou ik de auto hebben gekocht."]}$j$::jsonb,$j${"value": "Als ik geld had gehad, zou ik de auto hebben gekocht."}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$irreal_past_zou_hebben$p$, $p$reading$p$]),
('e5034403-fbbb-51e3-8086-a7332c9e2383'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','writing','translation',$p$Traduce al neerlandés: 'Si hubiera tenido tiempo, habría ayudado.'$p$,$j${"source": "Si hubiera tenido tiempo, habría ayudado."}$j$::jsonb,$j${"value": "Als ik tijd had gehad, zou ik hebben geholpen.", "accepted": ["Als ik tijd had gehad, zou ik hebben geholpen", "Als ik tijd had gehad, zou ik hebben geholpen.", "Als ik tijd had gehad, zou ik geholpen hebben.", "Als ik tijd had gehad, zou ik geholpen hebben"]}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$irreal_past_zou_hebben$p$, $p$writing$p$]),
('704506a5-43a7-5651-9d70-80339a1f8f16'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','writing','cloze',$p$Completa el condicional irreal (verbo 'komen', usa zijn): 'Si me hubieras invitado, yo habría venido.'$p$,$j${"text": "Als je me had uitgenodigd, zou ik ___ gekomen."}$j$::jsonb,$j${"value": "zijn", "accepted": ["zijn"]}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$irreal_past_zou_zijn$p$, $p$writing$p$]),
('199dd036-a22f-59b0-bb40-2945f5bb7840'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Als het weer beter was geweest, zouden we naar buiten zijn gegaan.", "Als het weer beter is, gaan we naar buiten.", "Als het weer beter was geweest, zouden we naar buiten hebben gegaan."], "say": "Als het weer beter was geweest, zouden we naar buiten zijn gegaan.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/199dd036-a22f-59b0-bb40-2945f5bb7840.mp3"}$j$::jsonb,$j${"value": "Als het weer beter was geweest, zouden we naar buiten zijn gegaan."}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$irreal_past_zou_zijn$p$, $p$listening$p$]),
('8dc239e2-a8fe-5a41-9258-0bce4c2a1a4e'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Als ik het had geweten, zou ik eerder zijn vertrokken.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/8dc239e2-a8fe-5a41-9258-0bce4c2a1a4e.mp3"}$j$::jsonb,$j${"expected": "Als ik het had geweten, zou ik eerder zijn vertrokken."}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$irreal_past_zou_zijn$p$, $p$speaking$p$]),
('415087be-dbce-5170-9b63-8d304f52f1f8'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','reading','multiple_choice',$p$¿Cuál frase es condicional del PRESENTE (hipótesis actual), no del pasado?$p$,$j${"options": ["Als ik rijk was, zou ik reizen.", "Als ik rijk was geweest, zou ik hebben gereisd.", "Als ik rijk was geweest, zou ik zijn gereisd."]}$j$::jsonb,$j${"value": "Als ik rijk was, zou ik reizen."}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$review_zou_present_vs_past$p$, $p$reading$p$]),
('4dabebe4-9ed8-5f14-b678-80a6d9f476a6'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','writing','reorder',$p$Ordena las palabras para decir: 'Si me hubiera levantado antes, no habría llegado tarde.' (irreal del pasado)$p$,$j${"tiles": ["Als", "ik", "eerder", "was", "opgestaan", "zou", "ik", "niet", "te", "laat", "zijn", "gekomen", "had"]}$j$::jsonb,$j${"value": "Als ik eerder was opgestaan zou ik niet te laat zijn gekomen"}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$review_reorder$p$, $p$writing$p$]),
('1ddc8fdf-891f-5ad5-b6c1-decdb1b02ea5'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'B1','writing','translation',$p$Traduce al neerlandés: 'Si lo hubiera sabido, te lo habría dicho.'$p$,$j${"source": "Si lo hubiera sabido, te lo habría dicho."}$j$::jsonb,$j${"value": "Als ik het had geweten, zou ik het je hebben verteld.", "accepted": ["Als ik het had geweten, zou ik het je hebben verteld", "Als ik het had geweten, zou ik het je hebben verteld.", "Als ik het had geweten, zou ik het je verteld hebben.", "Als ik het had geweten, zou ik het je verteld hebben"]}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$review_translation$p$, $p$writing$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('a2f8c606-64ce-54e2-a2fe-9dfc5a9f77c7','bff1dcc8-a672-5b49-9bf6-d00566043c05',1),
 ('a2f8c606-64ce-54e2-a2fe-9dfc5a9f77c7','856b384e-5e6e-5ba8-ae67-61be85d0d5b8',2),
 ('a2f8c606-64ce-54e2-a2fe-9dfc5a9f77c7','c25d0982-4d22-5717-9360-3a734aeb1232',3),
 ('a2f8c606-64ce-54e2-a2fe-9dfc5a9f77c7','a764a310-85e4-5aa6-8167-b3a4be1835af',4),
 ('e4790c63-c703-51a5-a48f-7119560ce070','c50e8937-a823-5e6f-a165-8909fa2c16d1',1),
 ('e4790c63-c703-51a5-a48f-7119560ce070','ffda48c4-d55a-5233-a9c9-ce9e6b1eb8c2',2),
 ('e4790c63-c703-51a5-a48f-7119560ce070','56604f3a-c2fa-5153-91f0-05b185dc1bb9',3),
 ('e4790c63-c703-51a5-a48f-7119560ce070','0be8176c-a31f-5808-8f7b-f6259fea3094',4),
 ('e4790c63-c703-51a5-a48f-7119560ce070','a2dac981-b74c-5e09-8f0e-ba893082ee90',5),
 ('e4790c63-c703-51a5-a48f-7119560ce070','1e10535e-d784-5435-a7f8-4b22944526c0',6),
 ('b6c5227b-ac5e-50b1-81d6-4e9503ff9edc','d8a8f5f0-29de-54d9-902b-c2bc4e1c830c',1),
 ('b6c5227b-ac5e-50b1-81d6-4e9503ff9edc','ea22c92f-47e7-5319-bf45-3fdef00e602a',2),
 ('b6c5227b-ac5e-50b1-81d6-4e9503ff9edc','e5034403-fbbb-51e3-8086-a7332c9e2383',3),
 ('b6c5227b-ac5e-50b1-81d6-4e9503ff9edc','704506a5-43a7-5651-9d70-80339a1f8f16',4),
 ('b6c5227b-ac5e-50b1-81d6-4e9503ff9edc','199dd036-a22f-59b0-bb40-2945f5bb7840',5),
 ('b6c5227b-ac5e-50b1-81d6-4e9503ff9edc','8dc239e2-a8fe-5a41-9258-0bce4c2a1a4e',6),
 ('16c5a0a4-c8a0-5b94-9827-c9ff338159e2','415087be-dbce-5170-9b63-8d304f52f1f8',1),
 ('16c5a0a4-c8a0-5b94-9827-c9ff338159e2','4dabebe4-9ed8-5f14-b678-80a6d9f476a6',2),
 ('16c5a0a4-c8a0-5b94-9827-c9ff338159e2','1ddc8fdf-891f-5ad5-b6c1-decdb1b02ea5',3),
 ('058676d8-6978-5757-a1aa-6fde141a4a09','bff1dcc8-a672-5b49-9bf6-d00566043c05',1),
 ('058676d8-6978-5757-a1aa-6fde141a4a09','856b384e-5e6e-5ba8-ae67-61be85d0d5b8',2),
 ('058676d8-6978-5757-a1aa-6fde141a4a09','c50e8937-a823-5e6f-a165-8909fa2c16d1',3),
 ('058676d8-6978-5757-a1aa-6fde141a4a09','ffda48c4-d55a-5233-a9c9-ce9e6b1eb8c2',4),
 ('058676d8-6978-5757-a1aa-6fde141a4a09','0be8176c-a31f-5808-8f7b-f6259fea3094',5),
 ('058676d8-6978-5757-a1aa-6fde141a4a09','e5034403-fbbb-51e3-8086-a7332c9e2383',6),
 ('058676d8-6978-5757-a1aa-6fde141a4a09','c25d0982-4d22-5717-9360-3a734aeb1232',7),
 ('058676d8-6978-5757-a1aa-6fde141a4a09','56604f3a-c2fa-5153-91f0-05b185dc1bb9',8),
 ('058676d8-6978-5757-a1aa-6fde141a4a09','a764a310-85e4-5aa6-8167-b3a4be1835af',9),
 ('058676d8-6978-5757-a1aa-6fde141a4a09','1e10535e-d784-5435-a7f8-4b22944526c0',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('500de92c-6f1a-502a-bd99-47e7af6e93e7','20000000-0000-0000-0000-000000000006',$p$de fout$p$,$p$el error$p$,461,'sustantivo'),
 ('7094e97e-b71b-50e5-834b-239d647e1850','20000000-0000-0000-0000-000000000006',$p$het verleden$p$,$p$el pasado$p$,462,'sustantivo'),
 ('e3234c4b-9454-527f-b29a-bebbabfb6e46','20000000-0000-0000-0000-000000000006',$p$de mogelijkheid$p$,$p$la posibilidad$p$,463,'sustantivo'),
 ('196a6450-5e35-52bb-8508-1106e9831a0b','20000000-0000-0000-0000-000000000006',$p$de beslissing$p$,$p$la decisión$p$,464,'sustantivo'),
 ('0963f82d-9bc3-569a-b439-107a18a1e1c4','20000000-0000-0000-0000-000000000006',$p$de spijt$p$,$p$el arrepentimiento$p$,465,'sustantivo'),
 ('724b1162-561d-54a3-9e87-cebb9cf713b1','20000000-0000-0000-0000-000000000006',$p$het advies$p$,$p$el consejo$p$,466,'sustantivo'),
 ('27e75e0a-b2e5-5e5e-9eb0-31646f11a724','20000000-0000-0000-0000-000000000006',$p$de kans$p$,$p$la ocasión / oportunidad$p$,467,'sustantivo'),
 ('142d9a86-a294-5de8-b6e7-68d4d64b8e82','20000000-0000-0000-0000-000000000006',$p$het toeval$p$,$p$la casualidad$p$,468,'sustantivo'),
 ('7d171795-4231-50ff-992f-740d66c89c38','20000000-0000-0000-0000-000000000006',$p$de waarschuwing$p$,$p$la advertencia$p$,469,'sustantivo'),
 ('b13eaae1-708c-5c41-88cb-762252c62ee5','20000000-0000-0000-0000-000000000006',$p$het gevolg$p$,$p$la consecuencia$p$,470,'sustantivo'),
 ('963701fe-bb13-5308-823d-2599eef449d3','20000000-0000-0000-0000-000000000006',$p$het verwijt$p$,$p$el reproche$p$,471,'sustantivo'),
 ('10491679-a926-5c9c-9238-0573197ad03a','20000000-0000-0000-0000-000000000006',$p$de voorwaarde$p$,$p$la condición$p$,472,'sustantivo'),
 ('e5eaf496-a6a8-5be2-8fb7-ab8245325fce','20000000-0000-0000-0000-000000000006',$p$het resultaat$p$,$p$el resultado$p$,473,'sustantivo'),
 ('32505426-8100-5477-82ec-43880c243b2c','20000000-0000-0000-0000-000000000006',$p$de herinnering$p$,$p$el recuerdo$p$,474,'sustantivo'),
 ('6425e47a-0fc7-550d-ac05-e3760ba30c9b','20000000-0000-0000-0000-000000000006',$p$het ongeluk$p$,$p$el accidente$p$,475,'sustantivo'),
 ('58984b0a-39ed-5247-87af-fb5c2de629e2','20000000-0000-0000-0000-000000000006',$p$de bedoeling$p$,$p$la intención$p$,476,'sustantivo')
on conflict (id) do nothing;

commit;