-- 20260703120105_seed_nl_a2.sql
-- Currículo A2 del curso es→nl (6 unidades). Molde es→pt.
-- Contenido scopeado a course_id=20000000-0000-0000-0000-000000000006 → aislamiento multicurso por
-- jz_active_course. Unidades order_index continúan la cadena → gating al nivel previo.
begin;
insert into languages (id, code, name) values
  ('10000000-0000-0000-0000-000000000007','nl',$p$Nederlands$p$) on conflict (id) do nothing;
insert into courses (id, source_language_id, target_language_id, is_active) values
  ('20000000-0000-0000-0000-000000000006','10000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000007',true) on conflict (id) do nothing;

-- ── Unidad 7 (A2·nl): El pasado: lo que hice ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('45da1448-7f18-53d6-a4a8-89f5c04b95c3','20000000-0000-0000-0000-000000000006','A2',7,$p$El pasado: lo que hice$p$,'#C0392B','history_edu')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('3a2965bf-52a0-5b4d-a1da-fa0e13fe568a','45da1448-7f18-53d6-a4a8-89f5c04b95c3',1,$p$El perfectum: hebben + participio$p$,$p$El perfectum: hebben + participio$p$,'lesson',15),
 ('dc332fe0-ce95-5abc-a2c6-dcdc8ab331c8','45da1448-7f18-53d6-a4a8-89f5c04b95c3',2,$p$Participios regulares (ge-...-t/-d)$p$,$p$Participios regulares (ge-...-t/-d)$p$,'lesson',15),
 ('696dd5a7-3eca-5724-a8f4-7f651561d0fb','45da1448-7f18-53d6-a4a8-89f5c04b95c3',3,$p$Participios irregulares (ge-...-en)$p$,$p$Participios irregulares (ge-...-en)$p$,'lesson',15),
 ('7a5414c1-1da2-54d9-9d1d-050209ec39a4','45da1448-7f18-53d6-a4a8-89f5c04b95c3',4,$p$¿Qué hiciste? Preguntas y negación$p$,$p$¿Qué hiciste? Preguntas y negación$p$,'lesson',15),
 ('e4a1d3c2-af76-5202-a034-7587da0ab9f2','45da1448-7f18-53d6-a4a8-89f5c04b95c3',5,$p$🏁 Checkpoint Eenheid 7$p$,$p$Demuestra que puedes contar lo que hiciste con el perfectum: hebben + participio al final.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('9c7b7179-9ebd-57a4-b949-b4beab40e248','20000000-0000-0000-0000-000000000006','checkpoint','A2','45da1448-7f18-53d6-a4a8-89f5c04b95c3',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('e178a376-3b99-58a5-a6b2-e4d8fbe00e28'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','reading','match',$p$Une cada expresión de tiempo con su traducción.$p$,$j${"pairs": [{"en": "gisteren", "es": "ayer"}, {"en": "vorige week", "es": "la semana pasada"}, {"en": "in het weekend", "es": "el fin de semana"}]}$j$::jsonb,$j${"pairs": [["gisteren", "ayer"], ["vorige week", "la semana pasada"], ["in het weekend", "el fin de semana"]]}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$expresiones_tiempo_pasado$p$, $p$reading$p$]),
('a1be9f77-91d0-52bd-bf61-6b303ffc0085'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','reading','multiple_choice',$p$Elige la frase con el orden de palabras correcto.$p$,$j${"options": ["Ik heb gisteren gewerkt.", "Ik heb gewerkt gisteren.", "Ik gewerkt heb gisteren."]}$j$::jsonb,$j${"value": "Ik heb gisteren gewerkt."}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$perfectum_hebben$p$, $p$reading$p$]),
('5de1d16e-6fe6-558c-96a6-94c3e98b6c73'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','writing','cloze',$p$Completa con la forma correcta de 'hebben'.$p$,$j${"text": "Hij ___ gisteren brood gekocht."}$j$::jsonb,$j${"value": "heeft", "accepted": ["heeft"]}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$perfectum_hebben$p$, $p$writing$p$]),
('102dde80-75db-54fd-820e-19775846514d'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ik heb gisteren gewerkt.", "Ik heb gisteren gespeeld.", "Ik heb vandaag gewerkt."], "say": "Ik heb gisteren gewerkt.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/102dde80-75db-54fd-820e-19775846514d.mp3"}$j$::jsonb,$j${"value": "Ik heb gisteren gewerkt."}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$perfectum_hebben$p$, $p$listening$p$]),
('ab6f0974-ec04-5ca6-a9c8-a202a56cea27'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Ik heb gisteren thuis gewerkt.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/ab6f0974-ec04-5ca6-a9c8-a202a56cea27.mp3"}$j$::jsonb,$j${"expected": "Ik heb gisteren thuis gewerkt."}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$perfectum_hebben$p$, $p$speaking$p$]),
('8e3f82d5-5b77-5bac-a3e3-b4ae1ca24d84'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','reading','multiple_choice',$p$¿Cuál es el participio de 'kopen' (comprar)?$p$,$j${"options": ["gekocht", "gekoopt", "koopte"]}$j$::jsonb,$j${"value": "gekocht"}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$participios_regulares$p$, $p$reading$p$]),
('433a5235-4bdd-5eb8-906c-f51f36c04861'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','writing','translation',$p$Traduce: Ayer compré pan.$p$,$j${"source": "Ayer compré pan."}$j$::jsonb,$j${"value": "Ik heb gisteren brood gekocht.", "accepted": ["Ik heb gisteren brood gekocht.", "Ik heb gisteren brood gekocht", "Gisteren heb ik brood gekocht.", "Gisteren heb ik brood gekocht", "Ik kocht gisteren brood.", "Ik kocht gisteren brood", "Gisteren kocht ik brood.", "Gisteren kocht ik brood"]}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$participios_regulares$p$, $p$writing$p$]),
('bb3ed26a-1129-5cc8-8ac4-edfc6e4996aa'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','writing','cloze',$p$Completa con el participio de 'maken'.$p$,$j${"text": "Zij heeft gisteren een foto ___."}$j$::jsonb,$j${"value": "gemaakt", "accepted": ["gemaakt"]}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$participios_regulares$p$, $p$writing$p$]),
('9a7b753b-71db-55a0-acd1-a212694be85f'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Hij heeft een nieuwe fiets gekocht.", "Hij heeft een nieuw boek gekocht.", "Hij heeft een oude fiets gemaakt."], "say": "Hij heeft een nieuwe fiets gekocht.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/9a7b753b-71db-55a0-acd1-a212694be85f.mp3"}$j$::jsonb,$j${"value": "Hij heeft een nieuwe fiets gekocht."}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$participios_regulares$p$, $p$listening$p$]),
('ec19326d-4af6-5543-8d2b-f87e6b54d96e'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Zij heeft een mooie foto gemaakt.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/ec19326d-4af6-5543-8d2b-f87e6b54d96e.mp3"}$j$::jsonb,$j${"expected": "Zij heeft een mooie foto gemaakt."}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$participios_regulares$p$, $p$speaking$p$]),
('52e3e706-0608-5a05-9301-945124c47dd8'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','reading','match',$p$Une cada participio con su significado.$p$,$j${"pairs": [{"en": "gegeten", "es": "comido"}, {"en": "gezien", "es": "visto"}, {"en": "geschreven", "es": "escrito"}]}$j$::jsonb,$j${"pairs": [["gegeten", "comido"], ["gezien", "visto"], ["geschreven", "escrito"]]}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$participios_irregulares$p$, $p$reading$p$]),
('4d8d4e2c-1e22-530c-9de1-27120b17fa82'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','reading','multiple_choice',$p$¿Cuál es el participio de 'drinken' (beber)?$p$,$j${"options": ["gedronken", "gedrinkt", "gedrinken"]}$j$::jsonb,$j${"value": "gedronken"}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$participios_irregulares$p$, $p$reading$p$]),
('73801e16-0e41-5621-9955-e943d31859e1'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','writing','word_bank',$p$Forma la frase en neerlandés: 'He leído un libro'.$p$,$j${"tiles": ["Ik", "heb", "een", "boek", "gelezen", "leest"]}$j$::jsonb,$j${"value": "Ik heb een boek gelezen", "sequence": ["Ik", "heb", "een", "boek", "gelezen"]}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$participios_irregulares$p$, $p$writing$p$]),
('865293df-aee0-5c70-9f0f-74cf7401b45d'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Wij hebben pizza gegeten en cola gedronken.", "Wij hebben brood gegeten en melk gedronken.", "Wij hebben pizza gemaakt en koffie gedronken."], "say": "Wij hebben pizza gegeten en cola gedronken.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/865293df-aee0-5c70-9f0f-74cf7401b45d.mp3"}$j$::jsonb,$j${"value": "Wij hebben pizza gegeten en cola gedronken."}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$participios_irregulares$p$, $p$listening$p$]),
('7f085755-09e3-5708-9b63-95c7364fecc6'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ik heb dat boek al gelezen.", "Ik heb die brief al geschreven.", "Ik heb dat boek niet gelezen."], "say": "Ik heb dat boek al gelezen.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/7f085755-09e3-5708-9b63-95c7364fecc6.mp3"}$j$::jsonb,$j${"value": "Ik heb dat boek al gelezen."}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$participios_irregulares$p$, $p$listening$p$]),
('7c413b5b-3ab8-5610-9aa9-37f61d2a305e'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','reading','multiple_choice',$p$Elige la frase correcta.$p$,$j${"options": ["Ik heb niets gedaan.", "Ik ben niets gedaan.", "Ik heb niets doen."]}$j$::jsonb,$j${"value": "Ik heb niets gedaan."}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$pasado_preguntas_negacion$p$, $p$reading$p$]),
('e689e00a-dcc8-5d5c-a9f2-cb3f4a6c4433'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','writing','translation',$p$Traduce: No hice nada ayer.$p$,$j${"source": "No hice nada ayer."}$j$::jsonb,$j${"value": "Ik heb gisteren niets gedaan.", "accepted": ["Ik heb gisteren niets gedaan.", "Ik heb gisteren niets gedaan", "Gisteren heb ik niets gedaan.", "Gisteren heb ik niets gedaan", "Ik heb gisteren niks gedaan.", "Ik heb gisteren niks gedaan", "Gisteren heb ik niks gedaan.", "Gisteren heb ik niks gedaan", "Ik deed gisteren niets.", "Ik deed gisteren niets", "Gisteren deed ik niets.", "Gisteren deed ik niets"]}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$pasado_preguntas_negacion$p$, $p$writing$p$]),
('cac4cebc-4362-57b3-abaa-51982e5721da'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','writing','reorder',$p$Ordena las palabras para formar una pregunta.$p$,$j${"tiles": ["gisteren", "Wat", "gedaan?", "je", "heb"]}$j$::jsonb,$j${"value": "Wat heb je gisteren gedaan?"}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$pasado_preguntas_negacion$p$, $p$writing$p$]),
('abc3d0bc-4d2a-5fd9-b5cc-89e95c8f3696'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Wat heb je eergisteren gedaan?", "Wat heb je gisteren gedaan?", "Wat heb je vorige week gedaan?"], "say": "Wat heb je eergisteren gedaan?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/abc3d0bc-4d2a-5fd9-b5cc-89e95c8f3696.mp3"}$j$::jsonb,$j${"value": "Wat heb je eergisteren gedaan?"}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$pasado_preguntas_negacion$p$, $p$listening$p$]),
('20fa974e-b066-5b6b-87a3-4c78642fbdd2'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Wat heb je in het weekend gedaan?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/20fa974e-b066-5b6b-87a3-4c78642fbdd2.mp3"}$j$::jsonb,$j${"expected": "Wat heb je in het weekend gedaan?"}$j$::jsonb,0.34,ARRAY[$p$unidad7$p$, $p$pasado_preguntas_negacion$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('3a2965bf-52a0-5b4d-a1da-fa0e13fe568a','e178a376-3b99-58a5-a6b2-e4d8fbe00e28',1),
 ('3a2965bf-52a0-5b4d-a1da-fa0e13fe568a','a1be9f77-91d0-52bd-bf61-6b303ffc0085',2),
 ('3a2965bf-52a0-5b4d-a1da-fa0e13fe568a','5de1d16e-6fe6-558c-96a6-94c3e98b6c73',3),
 ('3a2965bf-52a0-5b4d-a1da-fa0e13fe568a','102dde80-75db-54fd-820e-19775846514d',4),
 ('3a2965bf-52a0-5b4d-a1da-fa0e13fe568a','ab6f0974-ec04-5ca6-a9c8-a202a56cea27',5),
 ('dc332fe0-ce95-5abc-a2c6-dcdc8ab331c8','8e3f82d5-5b77-5bac-a3e3-b4ae1ca24d84',1),
 ('dc332fe0-ce95-5abc-a2c6-dcdc8ab331c8','433a5235-4bdd-5eb8-906c-f51f36c04861',2),
 ('dc332fe0-ce95-5abc-a2c6-dcdc8ab331c8','bb3ed26a-1129-5cc8-8ac4-edfc6e4996aa',3),
 ('dc332fe0-ce95-5abc-a2c6-dcdc8ab331c8','9a7b753b-71db-55a0-acd1-a212694be85f',4),
 ('dc332fe0-ce95-5abc-a2c6-dcdc8ab331c8','ec19326d-4af6-5543-8d2b-f87e6b54d96e',5),
 ('696dd5a7-3eca-5724-a8f4-7f651561d0fb','52e3e706-0608-5a05-9301-945124c47dd8',1),
 ('696dd5a7-3eca-5724-a8f4-7f651561d0fb','4d8d4e2c-1e22-530c-9de1-27120b17fa82',2),
 ('696dd5a7-3eca-5724-a8f4-7f651561d0fb','73801e16-0e41-5621-9955-e943d31859e1',3),
 ('696dd5a7-3eca-5724-a8f4-7f651561d0fb','865293df-aee0-5c70-9f0f-74cf7401b45d',4),
 ('696dd5a7-3eca-5724-a8f4-7f651561d0fb','7f085755-09e3-5708-9b63-95c7364fecc6',5),
 ('7a5414c1-1da2-54d9-9d1d-050209ec39a4','7c413b5b-3ab8-5610-9aa9-37f61d2a305e',1),
 ('7a5414c1-1da2-54d9-9d1d-050209ec39a4','e689e00a-dcc8-5d5c-a9f2-cb3f4a6c4433',2),
 ('7a5414c1-1da2-54d9-9d1d-050209ec39a4','cac4cebc-4362-57b3-abaa-51982e5721da',3),
 ('7a5414c1-1da2-54d9-9d1d-050209ec39a4','abc3d0bc-4d2a-5fd9-b5cc-89e95c8f3696',4),
 ('7a5414c1-1da2-54d9-9d1d-050209ec39a4','20fa974e-b066-5b6b-87a3-4c78642fbdd2',5),
 ('e4a1d3c2-af76-5202-a034-7587da0ab9f2','e178a376-3b99-58a5-a6b2-e4d8fbe00e28',1),
 ('e4a1d3c2-af76-5202-a034-7587da0ab9f2','a1be9f77-91d0-52bd-bf61-6b303ffc0085',2),
 ('e4a1d3c2-af76-5202-a034-7587da0ab9f2','8e3f82d5-5b77-5bac-a3e3-b4ae1ca24d84',3),
 ('e4a1d3c2-af76-5202-a034-7587da0ab9f2','5de1d16e-6fe6-558c-96a6-94c3e98b6c73',4),
 ('e4a1d3c2-af76-5202-a034-7587da0ab9f2','433a5235-4bdd-5eb8-906c-f51f36c04861',5),
 ('e4a1d3c2-af76-5202-a034-7587da0ab9f2','bb3ed26a-1129-5cc8-8ac4-edfc6e4996aa',6),
 ('e4a1d3c2-af76-5202-a034-7587da0ab9f2','102dde80-75db-54fd-820e-19775846514d',7),
 ('e4a1d3c2-af76-5202-a034-7587da0ab9f2','9a7b753b-71db-55a0-acd1-a212694be85f',8),
 ('e4a1d3c2-af76-5202-a034-7587da0ab9f2','ab6f0974-ec04-5ca6-a9c8-a202a56cea27',9),
 ('e4a1d3c2-af76-5202-a034-7587da0ab9f2','ec19326d-4af6-5543-8d2b-f87e6b54d96e',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('c981a796-a881-5887-8800-48ae4121af8c','20000000-0000-0000-0000-000000000006',$p$gisteren$p$,$p$ayer$p$,241,'adverbio'),
 ('06a1b28e-a1a2-533f-a804-63713b0c769d','20000000-0000-0000-0000-000000000006',$p$eergisteren$p$,$p$anteayer$p$,242,'adverbio'),
 ('380f41a7-9831-5885-b33d-72be248de6e3','20000000-0000-0000-0000-000000000006',$p$vorige week$p$,$p$la semana pasada$p$,243,'expresion'),
 ('0c93fdb3-335e-5815-9025-b7490e4e72e9','20000000-0000-0000-0000-000000000006',$p$in het weekend$p$,$p$el fin de semana$p$,244,'expresion'),
 ('5101c1f5-621f-523f-8a14-a521d6ce3069','20000000-0000-0000-0000-000000000006',$p$gewerkt$p$,$p$trabajado$p$,245,'verbo'),
 ('0dd2d407-b0c7-5bb8-986e-de29e22e38db','20000000-0000-0000-0000-000000000006',$p$gemaakt$p$,$p$hecho (de maken)$p$,246,'verbo'),
 ('fd97fc4c-6df6-5749-b1b2-b89fa81d2e70','20000000-0000-0000-0000-000000000006',$p$gekocht$p$,$p$comprado$p$,247,'verbo'),
 ('a6695ac4-378b-59ca-8be9-44944f22fd3d','20000000-0000-0000-0000-000000000006',$p$gespeeld$p$,$p$jugado$p$,248,'verbo'),
 ('51ddb279-3b8c-54f9-9a05-5b7a7eb1e44b','20000000-0000-0000-0000-000000000006',$p$gegeten$p$,$p$comido$p$,249,'verbo'),
 ('956b8dc7-241a-570f-a39a-903498a71508','20000000-0000-0000-0000-000000000006',$p$gedronken$p$,$p$bebido$p$,250,'verbo'),
 ('9926d36c-06d3-5d50-9630-991d962fd2d8','20000000-0000-0000-0000-000000000006',$p$gezien$p$,$p$visto$p$,251,'verbo'),
 ('f60b945b-886a-5fa7-98cc-ac2e5c3174d6','20000000-0000-0000-0000-000000000006',$p$gelezen$p$,$p$leído$p$,252,'verbo'),
 ('1f771be0-99d9-58cd-ab46-052b6ee6527e','20000000-0000-0000-0000-000000000006',$p$geschreven$p$,$p$escrito$p$,253,'verbo'),
 ('b499fbb2-d58c-5bf4-b526-72baee6e06d9','20000000-0000-0000-0000-000000000006',$p$genomen$p$,$p$tomado$p$,254,'verbo'),
 ('7b1b29f5-a5c2-54a3-bc74-59b5590146d3','20000000-0000-0000-0000-000000000006',$p$gedaan$p$,$p$hecho (de doen)$p$,255,'verbo'),
 ('16144b81-403e-551a-bef1-1fabb012d855','20000000-0000-0000-0000-000000000006',$p$niets$p$,$p$nada$p$,256,'pronombre')
on conflict (id) do nothing;

-- ── Unidad 8 (A2·nl): Planes y futuro ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('4e984929-e2e1-5c1b-a64a-d99357c76300','20000000-0000-0000-0000-000000000006','A2',8,$p$Planes y futuro$p$,'#2C3E50','event_available')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('7d504b9a-b44f-508f-bb52-44119d32e2c6','4e984929-e2e1-5c1b-a64a-d99357c76300',1,$p$Futuro con gaan + infinitivo$p$,$p$Futuro con gaan + infinitivo$p$,'lesson',15),
 ('e4bd3750-05fb-583c-99b1-76d553c040b6','4e984929-e2e1-5c1b-a64a-d99357c76300',2,$p$Morgen werk ik: presente con inversión$p$,$p$Morgen werk ik: presente con inversión$p$,'lesson',15),
 ('442b046a-5516-5af9-9d0f-bd7b1ce5bb10','4e984929-e2e1-5c1b-a64a-d99357c76300',3,$p$Zullen: promesas y ofertas$p$,$p$Zullen: promesas y ofertas$p$,'lesson',15),
 ('6baf1d1a-6646-5a09-90e6-c0f2f5343875','4e984929-e2e1-5c1b-a64a-d99357c76300',4,$p$Ik wil graag: deseos y planes$p$,$p$Ik wil graag: deseos y planes$p$,'lesson',15),
 ('7ddcc333-cb6b-5b41-a7f0-1c514ec9b255','4e984929-e2e1-5c1b-a64a-d99357c76300',5,$p$🏁 Checkpoint Eenheid 8$p$,$p$Demuestra que puedes hablar de planes y futuro con gaan, zullen, inversión y 'ik wil graag'.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('951a0101-2011-56ef-9655-23a4e27307dc','20000000-0000-0000-0000-000000000006','checkpoint','A2','4e984929-e2e1-5c1b-a64a-d99357c76300',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('56b25e1a-2833-5203-bd41-8892f7531ec9'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','reading','match',$p$Une cada expresión de tiempo con su traducción.$p$,$j${"pairs": [{"en": "morgen", "es": "mañana"}, {"en": "overmorgen", "es": "pasado mañana"}, {"en": "volgende week", "es": "la semana que viene"}]}$j$::jsonb,$j${"pairs": [["morgen", "mañana"], ["overmorgen", "pasado mañana"], ["volgende week", "la semana que viene"]]}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$expresiones_tiempo_futuro$p$, $p$reading$p$]),
('6d834574-4e1f-50bd-81a0-894b82fb2f3e'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','reading','multiple_choice',$p$Elige la frase con el orden de palabras correcto.$p$,$j${"options": ["Wij gaan een film kijken.", "Wij gaan kijken een film.", "Wij kijken gaan een film."]}$j$::jsonb,$j${"value": "Wij gaan een film kijken."}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$futuro_gaan$p$, $p$reading$p$]),
('0a2b4915-0720-56f0-9522-bd74ad502aae'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','writing','cloze',$p$Completa con la forma correcta de 'gaan'.$p$,$j${"text": "Wij ___ morgen een film kijken."}$j$::jsonb,$j${"value": "gaan", "accepted": ["gaan"]}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$futuro_gaan$p$, $p$writing$p$]),
('a0c99d45-1326-5829-9735-1b7d96d1cfde'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ik ga morgen een film kijken.", "Ik ga morgen een boek lezen.", "Ik ga straks een film kijken."], "say": "Ik ga morgen een film kijken.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/a0c99d45-1326-5829-9735-1b7d96d1cfde.mp3"}$j$::jsonb,$j${"value": "Ik ga morgen een film kijken."}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$futuro_gaan$p$, $p$listening$p$]),
('d632c3a6-a26f-546e-9c60-3fdc1bf1cd7f'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Ik ga overmorgen een boek lezen.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/d632c3a6-a26f-546e-9c60-3fdc1bf1cd7f.mp3"}$j$::jsonb,$j${"expected": "Ik ga overmorgen een boek lezen."}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$futuro_gaan$p$, $p$speaking$p$]),
('2389e2ee-334f-5cd8-8dec-8e75352f3f9f'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','reading','multiple_choice',$p$Elige la frase correcta.$p$,$j${"options": ["Morgen werk ik thuis.", "Morgen ik werk thuis.", "Morgen werken ik thuis."]}$j$::jsonb,$j${"value": "Morgen werk ik thuis."}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$presente_inversion$p$, $p$reading$p$]),
('e491cc53-6f8c-58fb-ae00-cb49582c79c5'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','writing','word_bank',$p$Forma la frase en neerlandés: 'Pasado mañana no trabajo'.$p$,$j${"tiles": ["Overmorgen", "werk", "ik", "niet", "werkt"]}$j$::jsonb,$j${"value": "Overmorgen werk ik niet", "sequence": ["Overmorgen", "werk", "ik", "niet"]}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$presente_inversion$p$, $p$writing$p$]),
('f797a125-dcde-514b-8447-2c238c610050'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','writing','translation',$p$Traduce: Mañana no trabajo.$p$,$j${"source": "Mañana no trabajo."}$j$::jsonb,$j${"value": "Morgen werk ik niet.", "accepted": ["Morgen werk ik niet.", "Morgen werk ik niet", "Ik werk morgen niet.", "Ik werk morgen niet", "Ik ga morgen niet werken.", "Ik ga morgen niet werken", "Morgen ga ik niet werken.", "Morgen ga ik niet werken"]}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$presente_inversion$p$, $p$writing$p$]),
('c12a51ce-4ed1-5ed3-ba20-9718b9877d1c'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Morgen kijk ik een film.", "Straks kijk ik een film.", "Morgen lees ik een boek."], "say": "Morgen kijk ik een film.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/c12a51ce-4ed1-5ed3-ba20-9718b9877d1c.mp3"}$j$::jsonb,$j${"value": "Morgen kijk ik een film."}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$presente_inversion$p$, $p$listening$p$]),
('39ef0ac5-79e0-51e6-bdb6-5d422e6b6a47'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Volgende week werk ik niet.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/39ef0ac5-79e0-51e6-bdb6-5d422e6b6a47.mp3"}$j$::jsonb,$j${"expected": "Volgende week werk ik niet."}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$presente_inversion$p$, $p$speaking$p$]),
('f836331d-791f-5d27-a58e-7b4a48fae58a'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','reading','multiple_choice',$p$Elige la frase con el orden de palabras correcto.$p$,$j${"options": ["Ik zal morgen komen.", "Ik zal komen morgen.", "Ik morgen zal komen."]}$j$::jsonb,$j${"value": "Ik zal morgen komen."}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$futuro_zullen$p$, $p$reading$p$]),
('986b0b0e-a2df-5f0a-a5f9-9e085f532890'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','writing','cloze',$p$Completa con la forma correcta de 'zullen'.$p$,$j${"text": "Hij ___ volgende week komen."}$j$::jsonb,$j${"value": "zal", "accepted": ["zal"]}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$futuro_zullen$p$, $p$writing$p$]),
('26d4147f-5294-512f-a97a-0832736e0423'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','writing','reorder',$p$Ordena las palabras para formar una promesa.$p$,$j${"tiles": ["morgen", "Ik", "helpen.", "zal", "je"]}$j$::jsonb,$j${"value": "Ik zal je morgen helpen."}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$futuro_zullen$p$, $p$writing$p$]),
('756ec1a7-f248-5071-a5cf-9c42af188199'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','reading','match',$p$Une cada expresión de tiempo con su traducción.$p$,$j${"pairs": [{"en": "straks", "es": "dentro de un rato"}, {"en": "binnenkort", "es": "pronto"}, {"en": "volgend jaar", "es": "el año que viene"}]}$j$::jsonb,$j${"pairs": [["straks", "dentro de un rato"], ["binnenkort", "pronto"], ["volgend jaar", "el año que viene"]]}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$expresiones_tiempo_futuro$p$, $p$reading$p$]),
('7b32b1c7-a18f-503c-be4b-166bb1183ae2'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Wij zullen binnenkort komen.", "Wij zullen morgen komen.", "Wij gaan binnenkort reizen."], "say": "Wij zullen binnenkort komen.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/7b32b1c7-a18f-503c-be4b-166bb1183ae2.mp3"}$j$::jsonb,$j${"value": "Wij zullen binnenkort komen."}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$futuro_zullen$p$, $p$listening$p$]),
('74cf7f65-728b-52f8-9493-06a8f211d00a'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','reading','multiple_choice',$p$Elige la frase correcta para expresar un deseo.$p$,$j${"options": ["Ik wil graag naar Spanje reizen.", "Ik wil graag naar Spanje reist.", "Ik graag wil naar Spanje reizen."]}$j$::jsonb,$j${"value": "Ik wil graag naar Spanje reizen."}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$deseos_wil_graag$p$, $p$reading$p$]),
('d7b09f19-7199-5db9-9ca5-fc5a72f88078'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','writing','translation',$p$Traduce: Me gustaría viajar el año que viene.$p$,$j${"source": "Me gustaría viajar el año que viene."}$j$::jsonb,$j${"value": "Ik wil graag volgend jaar reizen.", "accepted": ["Ik wil graag volgend jaar reizen.", "Ik wil graag volgend jaar reizen", "Ik wil volgend jaar graag reizen.", "Ik wil volgend jaar graag reizen", "Volgend jaar wil ik graag reizen.", "Volgend jaar wil ik graag reizen", "Ik zou graag volgend jaar reizen.", "Ik zou graag volgend jaar reizen", "Ik zou volgend jaar graag reizen.", "Ik zou volgend jaar graag reizen", "Volgend jaar zou ik graag reizen.", "Volgend jaar zou ik graag reizen", "Ik zou graag volgend jaar willen reizen.", "Ik zou graag volgend jaar willen reizen"]}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$deseos_wil_graag$p$, $p$writing$p$]),
('33d00f61-4b27-5821-a8db-60cb2b8a14d4'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ik wil graag volgend jaar naar Nederland reizen.", "Ik wil graag volgende week naar Nederland reizen.", "Ik ga volgend jaar naar Nederland reizen."], "say": "Ik wil graag volgend jaar naar Nederland reizen.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/33d00f61-4b27-5821-a8db-60cb2b8a14d4.mp3"}$j$::jsonb,$j${"value": "Ik wil graag volgend jaar naar Nederland reizen."}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$deseos_wil_graag$p$, $p$listening$p$]),
('2aa70b0e-d4de-5b81-ae20-3e370f5cf128'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Ik wil graag binnenkort op vakantie gaan.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/2aa70b0e-d4de-5b81-ae20-3e370f5cf128.mp3"}$j$::jsonb,$j${"expected": "Ik wil graag binnenkort op vakantie gaan."}$j$::jsonb,0.34,ARRAY[$p$unidad8$p$, $p$deseos_wil_graag$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('7d504b9a-b44f-508f-bb52-44119d32e2c6','56b25e1a-2833-5203-bd41-8892f7531ec9',1),
 ('7d504b9a-b44f-508f-bb52-44119d32e2c6','6d834574-4e1f-50bd-81a0-894b82fb2f3e',2),
 ('7d504b9a-b44f-508f-bb52-44119d32e2c6','0a2b4915-0720-56f0-9522-bd74ad502aae',3),
 ('7d504b9a-b44f-508f-bb52-44119d32e2c6','a0c99d45-1326-5829-9735-1b7d96d1cfde',4),
 ('7d504b9a-b44f-508f-bb52-44119d32e2c6','d632c3a6-a26f-546e-9c60-3fdc1bf1cd7f',5),
 ('e4bd3750-05fb-583c-99b1-76d553c040b6','2389e2ee-334f-5cd8-8dec-8e75352f3f9f',1),
 ('e4bd3750-05fb-583c-99b1-76d553c040b6','e491cc53-6f8c-58fb-ae00-cb49582c79c5',2),
 ('e4bd3750-05fb-583c-99b1-76d553c040b6','f797a125-dcde-514b-8447-2c238c610050',3),
 ('e4bd3750-05fb-583c-99b1-76d553c040b6','c12a51ce-4ed1-5ed3-ba20-9718b9877d1c',4),
 ('e4bd3750-05fb-583c-99b1-76d553c040b6','39ef0ac5-79e0-51e6-bdb6-5d422e6b6a47',5),
 ('442b046a-5516-5af9-9d0f-bd7b1ce5bb10','f836331d-791f-5d27-a58e-7b4a48fae58a',1),
 ('442b046a-5516-5af9-9d0f-bd7b1ce5bb10','986b0b0e-a2df-5f0a-a5f9-9e085f532890',2),
 ('442b046a-5516-5af9-9d0f-bd7b1ce5bb10','26d4147f-5294-512f-a97a-0832736e0423',3),
 ('442b046a-5516-5af9-9d0f-bd7b1ce5bb10','756ec1a7-f248-5071-a5cf-9c42af188199',4),
 ('442b046a-5516-5af9-9d0f-bd7b1ce5bb10','7b32b1c7-a18f-503c-be4b-166bb1183ae2',5),
 ('6baf1d1a-6646-5a09-90e6-c0f2f5343875','74cf7f65-728b-52f8-9493-06a8f211d00a',1),
 ('6baf1d1a-6646-5a09-90e6-c0f2f5343875','d7b09f19-7199-5db9-9ca5-fc5a72f88078',2),
 ('6baf1d1a-6646-5a09-90e6-c0f2f5343875','33d00f61-4b27-5821-a8db-60cb2b8a14d4',3),
 ('6baf1d1a-6646-5a09-90e6-c0f2f5343875','2aa70b0e-d4de-5b81-ae20-3e370f5cf128',4),
 ('7ddcc333-cb6b-5b41-a7f0-1c514ec9b255','56b25e1a-2833-5203-bd41-8892f7531ec9',1),
 ('7ddcc333-cb6b-5b41-a7f0-1c514ec9b255','6d834574-4e1f-50bd-81a0-894b82fb2f3e',2),
 ('7ddcc333-cb6b-5b41-a7f0-1c514ec9b255','2389e2ee-334f-5cd8-8dec-8e75352f3f9f',3),
 ('7ddcc333-cb6b-5b41-a7f0-1c514ec9b255','0a2b4915-0720-56f0-9522-bd74ad502aae',4),
 ('7ddcc333-cb6b-5b41-a7f0-1c514ec9b255','e491cc53-6f8c-58fb-ae00-cb49582c79c5',5),
 ('7ddcc333-cb6b-5b41-a7f0-1c514ec9b255','f797a125-dcde-514b-8447-2c238c610050',6),
 ('7ddcc333-cb6b-5b41-a7f0-1c514ec9b255','a0c99d45-1326-5829-9735-1b7d96d1cfde',7),
 ('7ddcc333-cb6b-5b41-a7f0-1c514ec9b255','c12a51ce-4ed1-5ed3-ba20-9718b9877d1c',8),
 ('7ddcc333-cb6b-5b41-a7f0-1c514ec9b255','d632c3a6-a26f-546e-9c60-3fdc1bf1cd7f',9),
 ('7ddcc333-cb6b-5b41-a7f0-1c514ec9b255','39ef0ac5-79e0-51e6-bdb6-5d422e6b6a47',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('5e7f329e-4f66-5431-b5b2-4cfdb83632f4','20000000-0000-0000-0000-000000000006',$p$morgen$p$,$p$mañana$p$,261,'adverbio'),
 ('a68238ad-66b5-5d4c-a8ef-78c664d6dd2a','20000000-0000-0000-0000-000000000006',$p$overmorgen$p$,$p$pasado mañana$p$,262,'adverbio'),
 ('acfc577a-e600-5410-8320-99683ac58046','20000000-0000-0000-0000-000000000006',$p$volgende week$p$,$p$la semana que viene$p$,263,'expresion'),
 ('abeadb38-8ea5-5684-ad8d-2504088c0612','20000000-0000-0000-0000-000000000006',$p$volgend jaar$p$,$p$el año que viene$p$,264,'expresion'),
 ('dff0f829-676e-5850-a052-47aeabe14b73','20000000-0000-0000-0000-000000000006',$p$straks$p$,$p$dentro de un rato$p$,265,'adverbio'),
 ('bb765597-8e2d-5326-b2ac-ec923ff78524','20000000-0000-0000-0000-000000000006',$p$binnenkort$p$,$p$pronto, dentro de poco$p$,266,'adverbio'),
 ('6cef3718-5600-5b48-ae2f-3846d8ecdc75','20000000-0000-0000-0000-000000000006',$p$gaan$p$,$p$ir (a hacer algo)$p$,267,'verbo'),
 ('0cc145b0-0e9b-53a1-a192-056ad7635e1f','20000000-0000-0000-0000-000000000006',$p$zullen$p$,$p$auxiliar de futuro (promesa)$p$,268,'verbo'),
 ('134aef5f-fe68-565e-b696-1b0e17efd1e4','20000000-0000-0000-0000-000000000006',$p$reizen$p$,$p$viajar$p$,269,'verbo'),
 ('878ead13-53e9-50d6-9d48-290ced3db096','20000000-0000-0000-0000-000000000006',$p$kijken$p$,$p$mirar, ver$p$,270,'verbo'),
 ('62cc9711-26f9-5807-96af-946e77e9299a','20000000-0000-0000-0000-000000000006',$p$komen$p$,$p$venir$p$,271,'verbo'),
 ('890b823e-d8a4-55a2-a87d-639c699a6c9e','20000000-0000-0000-0000-000000000006',$p$willen$p$,$p$querer$p$,272,'verbo'),
 ('bd1f8455-11ac-5caf-a340-63bb431b6dcc','20000000-0000-0000-0000-000000000006',$p$graag$p$,$p$con gusto$p$,273,'adverbio'),
 ('8a81a144-4c6f-510e-b80d-29103dbd5a92','20000000-0000-0000-0000-000000000006',$p$de film$p$,$p$la película$p$,274,'sustantivo'),
 ('072c9a6a-16c5-5908-961d-2ce56e1152a4','20000000-0000-0000-0000-000000000006',$p$het plan$p$,$p$el plan$p$,275,'sustantivo'),
 ('79c7d58c-1621-5e70-8e91-044481db6364','20000000-0000-0000-0000-000000000006',$p$de vakantie$p$,$p$las vacaciones$p$,276,'sustantivo')
on conflict (id) do nothing;

-- ── Unidad 9 (A2·nl): De viaje ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('277b3b93-622a-50fe-b1dd-54540ca11630','20000000-0000-0000-0000-000000000006','A2',9,$p$De viaje$p$,'#16A085','flight_takeoff')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('ceb027c0-ab16-519d-8b3a-950c590ec0a9','277b3b93-622a-50fe-b1dd-54540ca11630',1,$p$En la estación$p$,$p$En la estación$p$,'lesson',15),
 ('21f66dcf-cb67-564e-bfdc-d854d9d61405','277b3b93-622a-50fe-b1dd-54540ca11630',2,$p$He ido: perfectum con zijn$p$,$p$He ido: perfectum con zijn$p$,'lesson',15),
 ('099df98a-0295-57a7-acac-5bd175c7ce00','277b3b93-622a-50fe-b1dd-54540ca11630',3,$p$¿Hebben o zijn?$p$,$p$¿Hebben o zijn?$p$,'lesson',15),
 ('f15fd737-581d-556d-82b5-758a80969b19','277b3b93-622a-50fe-b1dd-54540ca11630',4,$p$Hotel y buen viaje$p$,$p$Hotel y buen viaje$p$,'lesson',15),
 ('a87224dd-8bbb-54df-a2e7-357e5cc4291f','277b3b93-622a-50fe-b1dd-54540ca11630',5,$p$🏁 Checkpoint Eenheid 9$p$,$p$Demuestra que dominas el perfectum con zijn (gegaan, gekomen, gebleven) y el vocabulario del viaje.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('0ae17472-e59d-5a5d-9561-c1c47c6a4638','20000000-0000-0000-0000-000000000006','checkpoint','A2','277b3b93-622a-50fe-b1dd-54540ca11630',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('9c5e6bbb-51ed-5f55-bedb-42e496372fd4'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','reading','match',$p$Une cada palabra con su traducción.$p$,$j${"pairs": [{"en": "de trein", "es": "el tren"}, {"en": "het vliegtuig", "es": "el avión"}, {"en": "de koffer", "es": "la maleta"}]}$j$::jsonb,$j${"pairs": [["de trein", "el tren"], ["het vliegtuig", "el avión"], ["de koffer", "la maleta"]]}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$transporte_tren$p$, $p$reading$p$]),
('73469071-bd84-59f6-bb2e-918dee28c687'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','reading','multiple_choice',$p$¿Cómo viajas si vas caminando?$p$,$j${"options": ["te voet", "met de trein", "met het vliegtuig"]}$j$::jsonb,$j${"value": "te voet"}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$transporte_tren$p$, $p$reading$p$]),
('d0d68a45-fc57-5e39-bbd8-e22149f5ece4'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["De trein vertrekt om negen uur.", "De trein vertrekt om twee uur.", "Het vliegtuig vertrekt om negen uur."], "say": "De trein vertrekt om negen uur.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/d0d68a45-fc57-5e39-bbd8-e22149f5ece4.mp3"}$j$::jsonb,$j${"value": "De trein vertrekt om negen uur."}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$transporte_tren$p$, $p$listening$p$]),
('353fcc9c-ee2c-5efb-b4c4-b40b07821d20'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Ik reis met de trein.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/353fcc9c-ee2c-5efb-b4c4-b40b07821d20.mp3"}$j$::jsonb,$j${"expected": "Ik reis met de trein."}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$transporte_tren$p$, $p$speaking$p$]),
('ca51cda0-dff6-5c15-a2de-2f0a0abba151'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','reading','multiple_choice',$p$Elige la frase correcta.$p$,$j${"options": ["Ik ben naar Amsterdam gegaan.", "Ik heb naar Amsterdam gegaan.", "Ik ben naar Amsterdam gaan."]}$j$::jsonb,$j${"value": "Ik ben naar Amsterdam gegaan."}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$perfectum_zijn$p$, $p$reading$p$]),
('2aa9562b-3904-5f76-b024-609ddd0f875d'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','writing','cloze',$p$Completa con el auxiliar correcto.$p$,$j${"text": "Zij ___ gisteren naar Utrecht gegaan."}$j$::jsonb,$j${"value": "is", "accepted": ["is"]}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$perfectum_zijn$p$, $p$writing$p$]),
('444e023a-d8c4-51f5-b1c3-64e50bee49a8'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','writing','translation',$p$Traduce: He ido a Ámsterdam.$p$,$j${"source": "He ido a Ámsterdam."}$j$::jsonb,$j${"value": "Ik ben naar Amsterdam gegaan.", "accepted": ["Ik ben naar Amsterdam gegaan.", "Ik ben naar Amsterdam gegaan", "Ik ben naar Amsterdam geweest.", "Ik ben naar Amsterdam geweest"]}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$perfectum_zijn$p$, $p$writing$p$]),
('4c2fd005-ed21-58c1-bb5f-dfec052417eb'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','writing','word_bank',$p$Forma la frase: «Ella ha venido en tren.»$p$,$j${"tiles": ["Zij", "is", "met", "de", "trein", "gekomen", "heeft", "ben"]}$j$::jsonb,$j${"value": "Zij is met de trein gekomen", "sequence": ["Zij", "is", "met", "de", "trein", "gekomen"]}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$perfectum_zijn$p$, $p$writing$p$]),
('e66c3c9d-1670-5baa-9fa5-96dd22715b3f'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ik ben naar Amsterdam gegaan.", "Ik ben naar Rotterdam gegaan.", "Ik heb een kaartje gekocht."], "say": "Ik ben naar Amsterdam gegaan.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/e66c3c9d-1670-5baa-9fa5-96dd22715b3f.mp3"}$j$::jsonb,$j${"value": "Ik ben naar Amsterdam gegaan."}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$perfectum_zijn$p$, $p$listening$p$]),
('f4f5c9fd-7da8-5f48-9c00-59543cd57352'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Zij is gisteren gekomen.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/f4f5c9fd-7da8-5f48-9c00-59543cd57352.mp3"}$j$::jsonb,$j${"expected": "Zij is gisteren gekomen."}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$perfectum_zijn$p$, $p$speaking$p$]),
('8bddad29-048c-5636-9d2e-eaacc9388c21'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','reading','multiple_choice',$p$Elige el auxiliar correcto: «Wij ___ in het hotel gebleven.»$p$,$j${"options": ["zijn", "hebben", "hebt"]}$j$::jsonb,$j${"value": "zijn"}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$hebben_vs_zijn$p$, $p$reading$p$]),
('0d8ce537-3af1-5bea-98d7-5dc6560c1236'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','reading','multiple_choice',$p$Elige la frase correcta.$p$,$j${"options": ["Ik heb een kaartje gekocht.", "Ik ben een kaartje gekocht.", "Ik heb een kaartje kopen."]}$j$::jsonb,$j${"value": "Ik heb een kaartje gekocht."}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$hebben_vs_zijn$p$, $p$reading$p$]),
('1b03702d-5d9d-5eee-8b52-1d4fcf655991'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','writing','cloze',$p$Completa con el auxiliar correcto.$p$,$j${"text": "Wij ___ twee kaartjes gekocht."}$j$::jsonb,$j${"value": "hebben", "accepted": ["hebben"]}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$hebben_vs_zijn$p$, $p$writing$p$]),
('5e0574c4-fe40-5554-9cee-ae33d273f500'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','writing','reorder',$p$Ordena las palabras para formar una frase correcta.$p$,$j${"tiles": ["gereisd", "naar", "Hij", "Rotterdam", "is"]}$j$::jsonb,$j${"value": "Hij is naar Rotterdam gereisd"}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$hebben_vs_zijn$p$, $p$writing$p$]),
('bfcddb2d-64ed-5e46-91a3-2df47b496f98'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["We zijn drie dagen gebleven.", "We zijn drie weken gebleven.", "We hebben drie koffers."], "say": "We zijn drie dagen gebleven.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/bfcddb2d-64ed-5e46-91a3-2df47b496f98.mp3"}$j$::jsonb,$j${"value": "We zijn drie dagen gebleven."}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$hebben_vs_zijn$p$, $p$listening$p$]),
('c3b0a54c-7ff3-5f34-94c0-3470c674d755'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','reading','match',$p$Une cada palabra con su traducción.$p$,$j${"pairs": [{"en": "het hotel", "es": "el hotel"}, {"en": "het kaartje", "es": "el billete"}, {"en": "de luchthaven", "es": "el aeropuerto"}]}$j$::jsonb,$j${"pairs": [["het hotel", "el hotel"], ["het kaartje", "el billete"], ["de luchthaven", "el aeropuerto"]]}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$hotel_buen_viaje$p$, $p$reading$p$]),
('064497d4-7989-5a8a-8cab-61c6d282c1bf'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','writing','translation',$p$Traduce: Nos hemos quedado en el hotel.$p$,$j${"source": "Nos hemos quedado en el hotel."}$j$::jsonb,$j${"value": "We zijn in het hotel gebleven.", "accepted": ["We zijn in het hotel gebleven.", "We zijn in het hotel gebleven", "Wij zijn in het hotel gebleven.", "Wij zijn in het hotel gebleven"]}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$hotel_buen_viaje$p$, $p$writing$p$]),
('8cb611be-bcb1-5b0a-95a7-e3d79da00473'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Waar is het station?", "Waar is het hotel?", "Waar is de koffer?"], "say": "Waar is het station?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/8cb611be-bcb1-5b0a-95a7-e3d79da00473.mp3"}$j$::jsonb,$j${"value": "Waar is het station?"}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$hotel_buen_viaje$p$, $p$listening$p$]),
('f5d71ef5-a91e-56e6-84ba-9d39d102ddfd'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Goede reis!", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/f5d71ef5-a91e-56e6-84ba-9d39d102ddfd.mp3"}$j$::jsonb,$j${"expected": "Goede reis!"}$j$::jsonb,0.34,ARRAY[$p$unidad9$p$, $p$hotel_buen_viaje$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('ceb027c0-ab16-519d-8b3a-950c590ec0a9','9c5e6bbb-51ed-5f55-bedb-42e496372fd4',1),
 ('ceb027c0-ab16-519d-8b3a-950c590ec0a9','73469071-bd84-59f6-bb2e-918dee28c687',2),
 ('ceb027c0-ab16-519d-8b3a-950c590ec0a9','d0d68a45-fc57-5e39-bbd8-e22149f5ece4',3),
 ('ceb027c0-ab16-519d-8b3a-950c590ec0a9','353fcc9c-ee2c-5efb-b4c4-b40b07821d20',4),
 ('21f66dcf-cb67-564e-bfdc-d854d9d61405','ca51cda0-dff6-5c15-a2de-2f0a0abba151',1),
 ('21f66dcf-cb67-564e-bfdc-d854d9d61405','2aa9562b-3904-5f76-b024-609ddd0f875d',2),
 ('21f66dcf-cb67-564e-bfdc-d854d9d61405','444e023a-d8c4-51f5-b1c3-64e50bee49a8',3),
 ('21f66dcf-cb67-564e-bfdc-d854d9d61405','4c2fd005-ed21-58c1-bb5f-dfec052417eb',4),
 ('21f66dcf-cb67-564e-bfdc-d854d9d61405','e66c3c9d-1670-5baa-9fa5-96dd22715b3f',5),
 ('21f66dcf-cb67-564e-bfdc-d854d9d61405','f4f5c9fd-7da8-5f48-9c00-59543cd57352',6),
 ('099df98a-0295-57a7-acac-5bd175c7ce00','8bddad29-048c-5636-9d2e-eaacc9388c21',1),
 ('099df98a-0295-57a7-acac-5bd175c7ce00','0d8ce537-3af1-5bea-98d7-5dc6560c1236',2),
 ('099df98a-0295-57a7-acac-5bd175c7ce00','1b03702d-5d9d-5eee-8b52-1d4fcf655991',3),
 ('099df98a-0295-57a7-acac-5bd175c7ce00','5e0574c4-fe40-5554-9cee-ae33d273f500',4),
 ('099df98a-0295-57a7-acac-5bd175c7ce00','bfcddb2d-64ed-5e46-91a3-2df47b496f98',5),
 ('f15fd737-581d-556d-82b5-758a80969b19','c3b0a54c-7ff3-5f34-94c0-3470c674d755',1),
 ('f15fd737-581d-556d-82b5-758a80969b19','064497d4-7989-5a8a-8cab-61c6d282c1bf',2),
 ('f15fd737-581d-556d-82b5-758a80969b19','8cb611be-bcb1-5b0a-95a7-e3d79da00473',3),
 ('f15fd737-581d-556d-82b5-758a80969b19','f5d71ef5-a91e-56e6-84ba-9d39d102ddfd',4),
 ('a87224dd-8bbb-54df-a2e7-357e5cc4291f','9c5e6bbb-51ed-5f55-bedb-42e496372fd4',1),
 ('a87224dd-8bbb-54df-a2e7-357e5cc4291f','73469071-bd84-59f6-bb2e-918dee28c687',2),
 ('a87224dd-8bbb-54df-a2e7-357e5cc4291f','ca51cda0-dff6-5c15-a2de-2f0a0abba151',3),
 ('a87224dd-8bbb-54df-a2e7-357e5cc4291f','2aa9562b-3904-5f76-b024-609ddd0f875d',4),
 ('a87224dd-8bbb-54df-a2e7-357e5cc4291f','444e023a-d8c4-51f5-b1c3-64e50bee49a8',5),
 ('a87224dd-8bbb-54df-a2e7-357e5cc4291f','4c2fd005-ed21-58c1-bb5f-dfec052417eb',6),
 ('a87224dd-8bbb-54df-a2e7-357e5cc4291f','d0d68a45-fc57-5e39-bbd8-e22149f5ece4',7),
 ('a87224dd-8bbb-54df-a2e7-357e5cc4291f','e66c3c9d-1670-5baa-9fa5-96dd22715b3f',8),
 ('a87224dd-8bbb-54df-a2e7-357e5cc4291f','353fcc9c-ee2c-5efb-b4c4-b40b07821d20',9),
 ('a87224dd-8bbb-54df-a2e7-357e5cc4291f','f4f5c9fd-7da8-5f48-9c00-59543cd57352',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('99fa308d-4479-58c7-9dd1-eae20c1cd745','20000000-0000-0000-0000-000000000006',$p$de trein$p$,$p$el tren$p$,281,'sustantivo'),
 ('cbc47d22-0339-5c93-8443-3fc4ac1e0d8a','20000000-0000-0000-0000-000000000006',$p$het vliegtuig$p$,$p$el avión$p$,282,'sustantivo'),
 ('0157bc0f-4584-5266-b804-b4dcca13ca41','20000000-0000-0000-0000-000000000006',$p$het station$p$,$p$la estación$p$,283,'sustantivo'),
 ('860b75cc-b4d6-560f-8aa7-4fddb6010454','20000000-0000-0000-0000-000000000006',$p$de luchthaven$p$,$p$el aeropuerto$p$,284,'sustantivo'),
 ('6d8f9091-8c22-5837-82cd-1c1637100070','20000000-0000-0000-0000-000000000006',$p$het hotel$p$,$p$el hotel$p$,285,'sustantivo'),
 ('d0076720-bbdb-58c6-bbeb-d2fe55943daf','20000000-0000-0000-0000-000000000006',$p$het kaartje$p$,$p$el billete$p$,286,'sustantivo'),
 ('9b8ab5e1-3f65-505e-9130-53076e019f9a','20000000-0000-0000-0000-000000000006',$p$de koffer$p$,$p$la maleta$p$,287,'sustantivo'),
 ('5c1002ef-3904-5839-b63c-ff2fe4ff343e','20000000-0000-0000-0000-000000000006',$p$de reis$p$,$p$el viaje$p$,288,'sustantivo'),
 ('0e0ee378-33c9-5c60-ad2c-303fc4aac764','20000000-0000-0000-0000-000000000006',$p$reizen$p$,$p$viajar$p$,289,'verbo'),
 ('09b2221b-c90c-5af1-8d9d-6186d3e7304a','20000000-0000-0000-0000-000000000006',$p$gaan$p$,$p$ir$p$,290,'verbo'),
 ('0244d822-f184-553c-8ccb-411d46b13f16','20000000-0000-0000-0000-000000000006',$p$komen$p$,$p$venir$p$,291,'verbo'),
 ('46d32b8f-e125-5244-915e-231ad1318684','20000000-0000-0000-0000-000000000006',$p$blijven$p$,$p$quedarse$p$,292,'verbo'),
 ('2df497b7-78f9-5c90-a0d6-182389b6aa00','20000000-0000-0000-0000-000000000006',$p$vertrekken$p$,$p$salir, partir$p$,293,'verbo'),
 ('24ffa747-4e6c-5c3e-ae81-62161c66a497','20000000-0000-0000-0000-000000000006',$p$met de trein$p$,$p$en tren$p$,294,'expresion'),
 ('45b823b7-7686-5188-9b64-fa5c53989c4a','20000000-0000-0000-0000-000000000006',$p$te voet$p$,$p$a pie$p$,295,'expresion'),
 ('e2029d37-6644-53f0-96a0-ecb5368db3f5','20000000-0000-0000-0000-000000000006',$p$Goede reis!$p$,$p$¡Buen viaje!$p$,296,'expresion')
on conflict (id) do nothing;

-- ── Unidad 10 (A2·nl): Comer fuera y comprar ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('8434ef3e-add4-57a3-9d8d-5507b62e8590','20000000-0000-0000-0000-000000000006','A2',10,$p$Comer fuera y comprar$p$,'#E67E22','shopping_cart')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('8302b263-0783-58f7-90f9-91ef24909c58','8434ef3e-add4-57a3-9d8d-5507b62e8590',1,$p$En el restaurante$p$,$p$En el restaurante$p$,'lesson',15),
 ('29a25542-a3e8-515a-bbb9-3105450aba81','8434ef3e-add4-57a3-9d8d-5507b62e8590',2,$p$Más barato que…$p$,$p$Más barato que…$p$,'lesson',15),
 ('6536d5e2-f86d-5a4b-af29-a6a82f543400','8434ef3e-add4-57a3-9d8d-5507b62e8590',3,$p$Mejor y preferido$p$,$p$Mejor y preferido$p$,'lesson',15),
 ('2f282906-1493-50b1-b4bb-82919403b89b','8434ef3e-add4-57a3-9d8d-5507b62e8590',4,$p$En el mercado$p$,$p$En el mercado$p$,'lesson',15),
 ('af5e7bf6-97d8-5978-a8e2-e430f3f808f8','8434ef3e-add4-57a3-9d8d-5507b62e8590',5,$p$🏁 Checkpoint Eenheid 10$p$,$p$Demuestra que dominas el comparativo con dan (goedkoper, beter, liever) y el lenguaje del restaurante y el mercado.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('bb7861bd-58f4-52a7-8e49-6ad0f02af0af','20000000-0000-0000-0000-000000000006','checkpoint','A2','8434ef3e-add4-57a3-9d8d-5507b62e8590',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('8325d02b-2bfb-5c09-81a5-840c86261bf1'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','reading','match',$p$Une cada palabra con su traducción.$p$,$j${"pairs": [{"en": "de menukaart", "es": "la carta"}, {"en": "de rekening", "es": "la cuenta"}, {"en": "bestellen", "es": "pedir"}]}$j$::jsonb,$j${"pairs": [["de menukaart", "la carta"], ["de rekening", "la cuenta"], ["bestellen", "pedir"]]}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$restaurante_pedir$p$, $p$reading$p$]),
('ba96ed39-f6b8-556e-ab26-325878f73b29'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','reading','multiple_choice',$p$¿Qué dices para pedir la cuenta?$p$,$j${"options": ["De rekening, alstublieft.", "De menukaart is groot.", "Het smaakt goed."]}$j$::jsonb,$j${"value": "De rekening, alstublieft."}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$restaurante_pedir$p$, $p$reading$p$]),
('d04b731d-3ff8-53a6-9a0d-8afbd7e3ee6a'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','writing','translation',$p$Traduce: Me gustaría pedir.$p$,$j${"source": "Me gustaría pedir."}$j$::jsonb,$j${"value": "Ik wil graag bestellen.", "accepted": ["Ik wil graag bestellen.", "Ik wil graag bestellen", "Ik zou graag willen bestellen.", "Ik zou graag willen bestellen"]}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$restaurante_pedir$p$, $p$writing$p$]),
('375373e3-e6cd-5c3d-bcf1-e4e1240eabbf'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Het eten smaakt heel goed.", "Het eten smaakt niet goed.", "De rekening is heel hoog."], "say": "Het eten smaakt heel goed.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/375373e3-e6cd-5c3d-bcf1-e4e1240eabbf.mp3"}$j$::jsonb,$j${"value": "Het eten smaakt heel goed."}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$restaurante_pedir$p$, $p$listening$p$]),
('9c95a7d6-bf84-596e-95aa-b8c5305cdbe4'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "De rekening, alstublieft.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/9c95a7d6-bf84-596e-95aa-b8c5305cdbe4.mp3"}$j$::jsonb,$j${"expected": "De rekening, alstublieft."}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$restaurante_pedir$p$, $p$speaking$p$]),
('12849b79-763b-5c83-ab63-b862a9f52c95'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','reading','multiple_choice',$p$Elige la frase correcta.$p$,$j${"options": ["De trein is goedkoper dan het vliegtuig.", "De trein is goedkoper als het vliegtuig.", "De trein is goedkoop dan het vliegtuig."]}$j$::jsonb,$j${"value": "De trein is goedkoper dan het vliegtuig."}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$comparativo_dan$p$, $p$reading$p$]),
('792180b6-4128-5894-8c1a-d2c6a373f4eb'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','writing','cloze',$p$Completa con el comparativo de «goedkoop».$p$,$j${"text": "Deze appels zijn ___ dan die peren."}$j$::jsonb,$j${"value": "goedkoper", "accepted": ["goedkoper"]}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$comparativo_dan$p$, $p$writing$p$]),
('f585a013-2082-551c-8b3d-5071be80dff7'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','writing','translation',$p$Traduce: Esta maleta es más grande que esa maleta.$p$,$j${"source": "Esta maleta es más grande que esa maleta."}$j$::jsonb,$j${"value": "Deze koffer is groter dan die koffer.", "accepted": ["Deze koffer is groter dan die koffer.", "Deze koffer is groter dan die koffer", "Deze koffer is groter dan die.", "Deze koffer is groter dan die"]}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$comparativo_dan$p$, $p$writing$p$]),
('feed8919-5ced-5e0b-a2db-7c853569ef69'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["De kaas is duurder dan het brood.", "De kaas is goedkoper dan het brood.", "Het brood is duurder dan de vis."], "say": "De kaas is duurder dan het brood.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/feed8919-5ced-5e0b-a2db-7c853569ef69.mp3"}$j$::jsonb,$j${"value": "De kaas is duurder dan het brood."}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$comparativo_dan$p$, $p$listening$p$]),
('6bb5b6cb-9588-5ef6-ab3d-4777b81e5304'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Melk is goedkoper dan koffie.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/6bb5b6cb-9588-5ef6-ab3d-4777b81e5304.mp3"}$j$::jsonb,$j${"expected": "Melk is goedkoper dan koffie."}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$comparativo_dan$p$, $p$speaking$p$]),
('ac6a971a-64fe-5b0f-b92d-51bc27568538'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','reading','multiple_choice',$p$Elige la palabra que completa la frase: «Deze koffie is ___ dan die thee.»$p$,$j${"options": ["beter", "goeder", "best"]}$j$::jsonb,$j${"value": "beter"}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$comparativo_irregular$p$, $p$reading$p$]),
('a5957ce8-329c-53bf-873b-c6dbbbf748bf'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','reading','multiple_choice',$p$Elige la frase correcta.$p$,$j${"options": ["Dit brood is het goedkoopste.", "Dit brood is de goedkoopst.", "Dit brood is meer goedkoop."]}$j$::jsonb,$j${"value": "Dit brood is het goedkoopste."}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$comparativo_irregular$p$, $p$reading$p$]),
('08060664-6edd-54c8-b94b-adb49814402a'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','writing','cloze',$p$Completa con el comparativo de «graag».$p$,$j${"text": "Ik drink ___ thee dan koffie."}$j$::jsonb,$j${"value": "liever", "accepted": ["liever"]}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$comparativo_irregular$p$, $p$writing$p$]),
('2a1c2285-06ca-53f8-b034-d6036c0e3b8f'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','writing','word_bank',$p$Forma la frase: «Prefiero comer pescado que carne.»$p$,$j${"tiles": ["Ik", "eet", "liever", "vis", "dan", "vlees", "als", "graag"]}$j$::jsonb,$j${"value": "Ik eet liever vis dan vlees", "sequence": ["Ik", "eet", "liever", "vis", "dan", "vlees"]}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$comparativo_irregular$p$, $p$writing$p$]),
('84511732-14c4-5da7-a12d-ab893749e5cd'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ik drink liever water.", "Ik drink liever melk.", "Ik eet liever brood."], "say": "Ik drink liever water.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/84511732-14c4-5da7-a12d-ab893749e5cd.mp3"}$j$::jsonb,$j${"value": "Ik drink liever water."}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$comparativo_irregular$p$, $p$listening$p$]),
('13c4e190-18bf-5528-9c37-cf422e44e649'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','reading','match',$p$Une cada expresión con su traducción.$p$,$j${"pairs": [{"en": "de fles", "es": "la botella"}, {"en": "een kilo", "es": "un kilo"}, {"en": "een beetje", "es": "un poco"}]}$j$::jsonb,$j${"pairs": [["de fles", "la botella"], ["een kilo", "un kilo"], ["een beetje", "un poco"]]}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$mercado_cantidades$p$, $p$reading$p$]),
('76ed633c-662d-5568-92a2-799e2a0f30c8'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','writing','reorder',$p$Ordena las palabras para formar una pregunta correcta.$p$,$j${"tiles": ["kilo", "Wat", "kaas?", "een", "kost"]}$j$::jsonb,$j${"value": "Wat kost een kilo kaas?"}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$mercado_cantidades$p$, $p$writing$p$]),
('cd1d0090-5151-58a9-948d-79077878c131'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Een kilo appels, alstublieft.", "Een fles water, alstublieft.", "Een beetje kaas, alstublieft."], "say": "Een kilo appels, alstublieft.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/cd1d0090-5151-58a9-948d-79077878c131.mp3"}$j$::jsonb,$j${"value": "Een kilo appels, alstublieft."}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$mercado_cantidades$p$, $p$listening$p$]),
('5a94fc55-0399-53c6-9c39-cab91e6bd050'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Wat kost een fles melk?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/5a94fc55-0399-53c6-9c39-cab91e6bd050.mp3"}$j$::jsonb,$j${"expected": "Wat kost een fles melk?"}$j$::jsonb,0.34,ARRAY[$p$unidad10$p$, $p$mercado_cantidades$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('8302b263-0783-58f7-90f9-91ef24909c58','8325d02b-2bfb-5c09-81a5-840c86261bf1',1),
 ('8302b263-0783-58f7-90f9-91ef24909c58','ba96ed39-f6b8-556e-ab26-325878f73b29',2),
 ('8302b263-0783-58f7-90f9-91ef24909c58','d04b731d-3ff8-53a6-9a0d-8afbd7e3ee6a',3),
 ('8302b263-0783-58f7-90f9-91ef24909c58','375373e3-e6cd-5c3d-bcf1-e4e1240eabbf',4),
 ('8302b263-0783-58f7-90f9-91ef24909c58','9c95a7d6-bf84-596e-95aa-b8c5305cdbe4',5),
 ('29a25542-a3e8-515a-bbb9-3105450aba81','12849b79-763b-5c83-ab63-b862a9f52c95',1),
 ('29a25542-a3e8-515a-bbb9-3105450aba81','792180b6-4128-5894-8c1a-d2c6a373f4eb',2),
 ('29a25542-a3e8-515a-bbb9-3105450aba81','f585a013-2082-551c-8b3d-5071be80dff7',3),
 ('29a25542-a3e8-515a-bbb9-3105450aba81','feed8919-5ced-5e0b-a2db-7c853569ef69',4),
 ('29a25542-a3e8-515a-bbb9-3105450aba81','6bb5b6cb-9588-5ef6-ab3d-4777b81e5304',5),
 ('6536d5e2-f86d-5a4b-af29-a6a82f543400','ac6a971a-64fe-5b0f-b92d-51bc27568538',1),
 ('6536d5e2-f86d-5a4b-af29-a6a82f543400','a5957ce8-329c-53bf-873b-c6dbbbf748bf',2),
 ('6536d5e2-f86d-5a4b-af29-a6a82f543400','08060664-6edd-54c8-b94b-adb49814402a',3),
 ('6536d5e2-f86d-5a4b-af29-a6a82f543400','2a1c2285-06ca-53f8-b034-d6036c0e3b8f',4),
 ('6536d5e2-f86d-5a4b-af29-a6a82f543400','84511732-14c4-5da7-a12d-ab893749e5cd',5),
 ('2f282906-1493-50b1-b4bb-82919403b89b','13c4e190-18bf-5528-9c37-cf422e44e649',1),
 ('2f282906-1493-50b1-b4bb-82919403b89b','76ed633c-662d-5568-92a2-799e2a0f30c8',2),
 ('2f282906-1493-50b1-b4bb-82919403b89b','cd1d0090-5151-58a9-948d-79077878c131',3),
 ('2f282906-1493-50b1-b4bb-82919403b89b','5a94fc55-0399-53c6-9c39-cab91e6bd050',4),
 ('af5e7bf6-97d8-5978-a8e2-e430f3f808f8','8325d02b-2bfb-5c09-81a5-840c86261bf1',1),
 ('af5e7bf6-97d8-5978-a8e2-e430f3f808f8','ba96ed39-f6b8-556e-ab26-325878f73b29',2),
 ('af5e7bf6-97d8-5978-a8e2-e430f3f808f8','12849b79-763b-5c83-ab63-b862a9f52c95',3),
 ('af5e7bf6-97d8-5978-a8e2-e430f3f808f8','d04b731d-3ff8-53a6-9a0d-8afbd7e3ee6a',4),
 ('af5e7bf6-97d8-5978-a8e2-e430f3f808f8','792180b6-4128-5894-8c1a-d2c6a373f4eb',5),
 ('af5e7bf6-97d8-5978-a8e2-e430f3f808f8','f585a013-2082-551c-8b3d-5071be80dff7',6),
 ('af5e7bf6-97d8-5978-a8e2-e430f3f808f8','375373e3-e6cd-5c3d-bcf1-e4e1240eabbf',7),
 ('af5e7bf6-97d8-5978-a8e2-e430f3f808f8','feed8919-5ced-5e0b-a2db-7c853569ef69',8),
 ('af5e7bf6-97d8-5978-a8e2-e430f3f808f8','9c95a7d6-bf84-596e-95aa-b8c5305cdbe4',9),
 ('af5e7bf6-97d8-5978-a8e2-e430f3f808f8','6bb5b6cb-9588-5ef6-ab3d-4777b81e5304',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('1d248d01-2b9f-5445-9ae9-b7702ea35c4c','20000000-0000-0000-0000-000000000006',$p$de menukaart$p$,$p$la carta (del restaurante)$p$,301,'sustantivo'),
 ('9bc669f0-0ee0-59f5-8ae9-1e0e5493725f','20000000-0000-0000-0000-000000000006',$p$de rekening$p$,$p$la cuenta$p$,302,'sustantivo'),
 ('7e42a5af-05a0-52d3-a584-40ae0e8de4eb','20000000-0000-0000-0000-000000000006',$p$bestellen$p$,$p$pedir (comida)$p$,303,'verbo'),
 ('446d0ede-11fb-5018-b6c3-1b8fd60fd246','20000000-0000-0000-0000-000000000006',$p$betalen$p$,$p$pagar$p$,304,'verbo'),
 ('03cff272-1948-5a53-b0be-50a0a4715d3b','20000000-0000-0000-0000-000000000006',$p$kosten$p$,$p$costar$p$,305,'verbo'),
 ('b67f5f5c-849f-5227-a2fd-7fb3d6e96642','20000000-0000-0000-0000-000000000006',$p$de markt$p$,$p$el mercado$p$,306,'sustantivo'),
 ('05019552-4220-56cc-b63c-ad2cf89bdddf','20000000-0000-0000-0000-000000000006',$p$de fles$p$,$p$la botella$p$,307,'sustantivo'),
 ('ad1a009a-c0f3-5eef-9aec-d1e92b888b35','20000000-0000-0000-0000-000000000006',$p$een kilo$p$,$p$un kilo$p$,308,'expresion'),
 ('ba62a19a-318b-54fc-853a-8224d6d0406e','20000000-0000-0000-0000-000000000006',$p$veel$p$,$p$mucho$p$,309,'adverbio'),
 ('678600ae-6352-5f4e-99ce-979bd80fc319','20000000-0000-0000-0000-000000000006',$p$een beetje$p$,$p$un poco$p$,310,'expresion'),
 ('08de41fa-b436-5dd8-8b5a-11ee4367aefb','20000000-0000-0000-0000-000000000006',$p$goedkoop$p$,$p$barato$p$,311,'adjetivo'),
 ('37bdfcb3-607c-557b-9ac7-6e88ff33369f','20000000-0000-0000-0000-000000000006',$p$duur$p$,$p$caro$p$,312,'adjetivo'),
 ('23e167b9-e94b-521c-a75b-ba9bb15b318c','20000000-0000-0000-0000-000000000006',$p$beter$p$,$p$mejor$p$,313,'adjetivo'),
 ('ba4181b4-c2ff-50a4-9d1e-4a1d3dc5b9b5','20000000-0000-0000-0000-000000000006',$p$liever$p$,$p$preferiblemente (comparativo de graag)$p$,314,'adverbio'),
 ('2ba5f425-bb47-5f7f-9cc2-59b991c320fc','20000000-0000-0000-0000-000000000006',$p$meer$p$,$p$más$p$,315,'adverbio'),
 ('e5a1d9fc-2a73-5b9f-b13c-abbdb8d6a915','20000000-0000-0000-0000-000000000006',$p$Het smaakt goed.$p$,$p$Está rico.$p$,316,'expresion')
on conflict (id) do nothing;

-- ── Unidad 11 (A2·nl): Personas y descripciones ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('41e99a2f-2b0f-5b1b-9f5d-ea831585d52b','20000000-0000-0000-0000-000000000006','A2',11,$p$Personas y descripciones$p$,'#8E44AD','people')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('1038d257-7baf-5e64-a4d8-c81fc85e89e2','41e99a2f-2b0f-5b1b-9f5d-ea831585d52b',1,$p$Era y estaba: el pasado de zijn$p$,$p$Era y estaba: el pasado de zijn$p$,'lesson',15),
 ('f4c9522e-90e1-55c1-8d74-6fb930018369','41e99a2f-2b0f-5b1b-9f5d-ea831585d52b',2,$p$Tenía: el pasado de hebben$p$,$p$Tenía: el pasado de hebben$p$,'lesson',15),
 ('04853590-ca22-558a-b4d3-583052d933be','41e99a2f-2b0f-5b1b-9f5d-ea831585d52b',3,$p$¿Cómo es físicamente?$p$,$p$¿Cómo es físicamente?$p$,'lesson',15),
 ('7bbb3612-6586-5d5f-8c20-23a0b8c2f4c9','41e99a2f-2b0f-5b1b-9f5d-ea831585d52b',4,$p$Carácter y personalidad$p$,$p$Carácter y personalidad$p$,'lesson',15),
 ('2a1578fe-ac77-5c8b-ac90-70c9b0f33bb8','41e99a2f-2b0f-5b1b-9f5d-ea831585d52b',5,$p$🏁 Checkpoint Eenheid 11$p$,$p$Describe el aspecto y el carácter de las personas y habla del pasado con was/waren y had/hadden.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('0e12d426-e9d1-5253-9c8e-75a23c7c898a','20000000-0000-0000-0000-000000000006','checkpoint','A2','41e99a2f-2b0f-5b1b-9f5d-ea831585d52b',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('a176aa2e-6fd1-5d14-81f7-ff084b9334fe'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','reading','match',$p$Une cada forma del pasado con su traducción.$p$,$j${"pairs": [{"en": "ik was", "es": "yo era"}, {"en": "wij waren", "es": "nosotros éramos"}, {"en": "jij was", "es": "tú eras"}]}$j$::jsonb,$j${"pairs": [["ik was", "yo era"], ["wij waren", "nosotros éramos"], ["jij was", "tú eras"]]}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$imperfectum_zijn$p$, $p$reading$p$]),
('e465faa8-7787-5403-bd4a-c15c240c3f8b'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','reading','multiple_choice',$p$Elige la forma correcta: «Het ___ gisteren leuk.»$p$,$j${"options": ["was", "waren", "ben"]}$j$::jsonb,$j${"value": "was"}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$imperfectum_zijn$p$, $p$reading$p$]),
('644d1e45-0216-5736-9973-18333ce8bada'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','writing','cloze',$p$Completa con la forma correcta de «zijn» en pasado.$p$,$j${"text": "We ___ gisteren thuis."}$j$::jsonb,$j${"value": "waren", "accepted": ["waren"]}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$imperfectum_zijn$p$, $p$writing$p$]),
('a0c65246-302a-5391-b3f7-2cb8a2134207'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ik was gisteren erg moe.", "Ik was gisteren erg boos.", "Ik ben vandaag erg moe."], "say": "Ik was gisteren erg moe.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/a0c65246-302a-5391-b3f7-2cb8a2134207.mp3"}$j$::jsonb,$j${"value": "Ik was gisteren erg moe."}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$imperfectum_zijn$p$, $p$listening$p$]),
('d5c97533-2ed1-592c-9498-83024ac8a5d3'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Het was een leuke dag.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/d5c97533-2ed1-592c-9498-83024ac8a5d3.mp3"}$j$::jsonb,$j${"expected": "Het was een leuke dag."}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$imperfectum_zijn$p$, $p$speaking$p$]),
('a8bf741f-641d-51b7-aa81-93b41980b809'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','reading','multiple_choice',$p$Elige la forma correcta: «Mijn oma ___ vroeger lang haar.»$p$,$j${"options": ["had", "hadden", "heb"]}$j$::jsonb,$j${"value": "had"}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$imperfectum_hebben$p$, $p$reading$p$]),
('3049609e-77ba-54ad-b2c8-3fe3f6dad225'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','writing','cloze',$p$Completa con la forma correcta de «hebben» en pasado.$p$,$j${"text": "De kinderen ___ geen tijd."}$j$::jsonb,$j${"value": "hadden", "accepted": ["hadden"]}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$imperfectum_hebben$p$, $p$writing$p$]),
('d2ebfef9-8506-5b67-b2ab-c80c7e847a73'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','writing','translation',$p$Traduce: Yo tenía un perro.$p$,$j${"source": "Yo tenía un perro."}$j$::jsonb,$j${"value": "Ik had een hond.", "accepted": ["Ik had een hond.", "Ik had een hond"]}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$imperfectum_hebben$p$, $p$writing$p$]),
('12ce52e0-7590-5509-9402-bbb349db23f4'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Wij hadden vroeger een kleine auto.", "Wij hebben nu een kleine auto.", "Wij hadden vroeger een groot huis."], "say": "Wij hadden vroeger een kleine auto.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/12ce52e0-7590-5509-9402-bbb349db23f4.mp3"}$j$::jsonb,$j${"value": "Wij hadden vroeger een kleine auto."}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$imperfectum_hebben$p$, $p$listening$p$]),
('b4798feb-0b75-570c-b375-cc11e5fce5da'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Zij had blauwe ogen en blond haar.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/b4798feb-0b75-570c-b375-cc11e5fce5da.mp3"}$j$::jsonb,$j${"expected": "Zij had blauwe ogen en blond haar."}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$imperfectum_hebben$p$, $p$speaking$p$]),
('d6248bee-03fc-5974-b060-90a9712e3151'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','reading','match',$p$Une cada palabra con su traducción.$p$,$j${"pairs": [{"en": "het haar", "es": "el pelo"}, {"en": "de ogen", "es": "los ojos"}, {"en": "kort", "es": "corto"}]}$j$::jsonb,$j${"pairs": [["het haar", "el pelo"], ["de ogen", "los ojos"], ["kort", "corto"]]}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$uiterlijk_beschrijven$p$, $p$reading$p$]),
('7deb0552-05c9-51ce-8e0f-0225a993e67c'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','reading','multiple_choice',$p$¿Qué pregunta usas para el aspecto FÍSICO de una persona?$p$,$j${"options": ["Hoe ziet zij eruit?", "Hoe is zij?", "Hoe oud is zij?"]}$j$::jsonb,$j${"value": "Hoe ziet zij eruit?"}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$uiterlijk_beschrijven$p$, $p$reading$p$]),
('375e55bf-5822-549f-8454-7d986ca628ff'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','writing','word_bank',$p$Forma la frase: Mi hermana tiene el pelo largo.$p$,$j${"tiles": ["Mijn", "zus", "heeft", "lang", "haar", "ogen", "de"]}$j$::jsonb,$j${"value": "Mijn zus heeft lang haar", "sequence": ["Mijn", "zus", "heeft", "lang", "haar"]}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$uiterlijk_beschrijven$p$, $p$writing$p$]),
('0389cb8b-e8bb-5af8-89df-7e7fdb945fa1'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Hij heeft groene ogen en kort haar.", "Hij heeft blauwe ogen en lang haar.", "Hij heeft bruine ogen en blond haar."], "say": "Hij heeft groene ogen en kort haar.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/0389cb8b-e8bb-5af8-89df-7e7fdb945fa1.mp3"}$j$::jsonb,$j${"value": "Hij heeft groene ogen en kort haar."}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$uiterlijk_beschrijven$p$, $p$listening$p$]),
('ed68591a-c35c-56bf-9553-ab2bf08708cf'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Hoe ziet jouw broer eruit?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/ed68591a-c35c-56bf-9553-ab2bf08708cf.mp3"}$j$::jsonb,$j${"expected": "Hoe ziet jouw broer eruit?"}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$uiterlijk_beschrijven$p$, $p$speaking$p$]),
('7eb14beb-b217-5a22-ae79-a5f599d9dcf2'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','reading','multiple_choice',$p$Elige la forma correcta del adjetivo: «de ___ man».$p$,$j${"options": ["aardige", "aardig", "aardiger"]}$j$::jsonb,$j${"value": "aardige"}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$karakter_adjectief$p$, $p$reading$p$]),
('60d0ee01-b94b-548e-9cba-539f8fdfaa89'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','writing','translation',$p$Traduce: Él era muy gracioso.$p$,$j${"source": "Él era muy gracioso."}$j$::jsonb,$j${"value": "Hij was erg grappig.", "accepted": ["Hij was erg grappig.", "Hij was erg grappig", "Hij was heel grappig.", "Hij was heel grappig", "Hij was zeer grappig.", "Hij was zeer grappig"]}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$karakter_adjectief$p$, $p$writing$p$]),
('90ddef2c-c866-5812-8572-838ca820e3f6'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','writing','reorder',$p$Ordena las palabras: Ella es una mujer graciosa.$p$,$j${"tiles": ["grappige", "Zij", "vrouw", "is", "een"]}$j$::jsonb,$j${"value": "Zij is een grappige vrouw"}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$karakter_adjectief$p$, $p$writing$p$]),
('a8d10835-ca57-540c-88f3-53018636dccb'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Mijn opa was een serieuze man.", "Mijn opa is een serieuze man.", "Mijn oma was een grappige vrouw."], "say": "Mijn opa was een serieuze man.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/a8d10835-ca57-540c-88f3-53018636dccb.mp3"}$j$::jsonb,$j${"value": "Mijn opa was een serieuze man."}$j$::jsonb,0.34,ARRAY[$p$unidad11$p$, $p$karakter_adjectief$p$, $p$listening$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('1038d257-7baf-5e64-a4d8-c81fc85e89e2','a176aa2e-6fd1-5d14-81f7-ff084b9334fe',1),
 ('1038d257-7baf-5e64-a4d8-c81fc85e89e2','e465faa8-7787-5403-bd4a-c15c240c3f8b',2),
 ('1038d257-7baf-5e64-a4d8-c81fc85e89e2','644d1e45-0216-5736-9973-18333ce8bada',3),
 ('1038d257-7baf-5e64-a4d8-c81fc85e89e2','a0c65246-302a-5391-b3f7-2cb8a2134207',4),
 ('1038d257-7baf-5e64-a4d8-c81fc85e89e2','d5c97533-2ed1-592c-9498-83024ac8a5d3',5),
 ('f4c9522e-90e1-55c1-8d74-6fb930018369','a8bf741f-641d-51b7-aa81-93b41980b809',1),
 ('f4c9522e-90e1-55c1-8d74-6fb930018369','3049609e-77ba-54ad-b2c8-3fe3f6dad225',2),
 ('f4c9522e-90e1-55c1-8d74-6fb930018369','d2ebfef9-8506-5b67-b2ab-c80c7e847a73',3),
 ('f4c9522e-90e1-55c1-8d74-6fb930018369','12ce52e0-7590-5509-9402-bbb349db23f4',4),
 ('f4c9522e-90e1-55c1-8d74-6fb930018369','b4798feb-0b75-570c-b375-cc11e5fce5da',5),
 ('04853590-ca22-558a-b4d3-583052d933be','d6248bee-03fc-5974-b060-90a9712e3151',1),
 ('04853590-ca22-558a-b4d3-583052d933be','7deb0552-05c9-51ce-8e0f-0225a993e67c',2),
 ('04853590-ca22-558a-b4d3-583052d933be','375e55bf-5822-549f-8454-7d986ca628ff',3),
 ('04853590-ca22-558a-b4d3-583052d933be','0389cb8b-e8bb-5af8-89df-7e7fdb945fa1',4),
 ('04853590-ca22-558a-b4d3-583052d933be','ed68591a-c35c-56bf-9553-ab2bf08708cf',5),
 ('7bbb3612-6586-5d5f-8c20-23a0b8c2f4c9','7eb14beb-b217-5a22-ae79-a5f599d9dcf2',1),
 ('7bbb3612-6586-5d5f-8c20-23a0b8c2f4c9','60d0ee01-b94b-548e-9cba-539f8fdfaa89',2),
 ('7bbb3612-6586-5d5f-8c20-23a0b8c2f4c9','90ddef2c-c866-5812-8572-838ca820e3f6',3),
 ('7bbb3612-6586-5d5f-8c20-23a0b8c2f4c9','a8d10835-ca57-540c-88f3-53018636dccb',4),
 ('2a1578fe-ac77-5c8b-ac90-70c9b0f33bb8','a176aa2e-6fd1-5d14-81f7-ff084b9334fe',1),
 ('2a1578fe-ac77-5c8b-ac90-70c9b0f33bb8','e465faa8-7787-5403-bd4a-c15c240c3f8b',2),
 ('2a1578fe-ac77-5c8b-ac90-70c9b0f33bb8','a8bf741f-641d-51b7-aa81-93b41980b809',3),
 ('2a1578fe-ac77-5c8b-ac90-70c9b0f33bb8','644d1e45-0216-5736-9973-18333ce8bada',4),
 ('2a1578fe-ac77-5c8b-ac90-70c9b0f33bb8','3049609e-77ba-54ad-b2c8-3fe3f6dad225',5),
 ('2a1578fe-ac77-5c8b-ac90-70c9b0f33bb8','d2ebfef9-8506-5b67-b2ab-c80c7e847a73',6),
 ('2a1578fe-ac77-5c8b-ac90-70c9b0f33bb8','a0c65246-302a-5391-b3f7-2cb8a2134207',7),
 ('2a1578fe-ac77-5c8b-ac90-70c9b0f33bb8','12ce52e0-7590-5509-9402-bbb349db23f4',8),
 ('2a1578fe-ac77-5c8b-ac90-70c9b0f33bb8','d5c97533-2ed1-592c-9498-83024ac8a5d3',9),
 ('2a1578fe-ac77-5c8b-ac90-70c9b0f33bb8','b4798feb-0b75-570c-b375-cc11e5fce5da',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('9840339f-b155-5608-857f-d85a5535a939','20000000-0000-0000-0000-000000000006',$p$was$p$,$p$era / estaba (zijn)$p$,321,'verbo'),
 ('b3583604-4f83-5559-a27a-c133675c42ca','20000000-0000-0000-0000-000000000006',$p$waren$p$,$p$éramos / eran (zijn)$p$,322,'verbo'),
 ('720781f8-c3ea-5490-832a-597e443d3b08','20000000-0000-0000-0000-000000000006',$p$had$p$,$p$tenía (hebben)$p$,323,'verbo'),
 ('7025b43c-1626-5c1a-bfbc-ab9d8cad9ca9','20000000-0000-0000-0000-000000000006',$p$hadden$p$,$p$teníamos / tenían (hebben)$p$,324,'verbo'),
 ('f5630838-a252-54ee-b45e-3f53183110b6','20000000-0000-0000-0000-000000000006',$p$groot$p$,$p$grande / alto$p$,325,'adjetivo'),
 ('a818d7a6-05d0-5df7-912f-e06d55cb663e','20000000-0000-0000-0000-000000000006',$p$klein$p$,$p$pequeño / bajo$p$,326,'adjetivo'),
 ('5c407c28-0844-5fd4-b77a-7976c79ed1b7','20000000-0000-0000-0000-000000000006',$p$aardig$p$,$p$amable$p$,327,'adjetivo'),
 ('b8ad7df4-2d8d-5f5c-8036-e7a4e71d0477','20000000-0000-0000-0000-000000000006',$p$vriendelijk$p$,$p$simpático$p$,328,'adjetivo'),
 ('8a65e1dd-0157-5b37-a6b3-ebb35caf8fb3','20000000-0000-0000-0000-000000000006',$p$grappig$p$,$p$gracioso$p$,329,'adjetivo'),
 ('65aa6592-1073-5cba-9ba1-9395d6c09578','20000000-0000-0000-0000-000000000006',$p$serieus$p$,$p$serio$p$,330,'adjetivo'),
 ('8744f12d-c1df-56eb-9c51-1bc6714f4c1c','20000000-0000-0000-0000-000000000006',$p$het haar$p$,$p$el pelo$p$,331,'sustantivo'),
 ('909e1565-91c2-5579-a248-edf87db213df','20000000-0000-0000-0000-000000000006',$p$de ogen$p$,$p$los ojos$p$,332,'sustantivo'),
 ('244a2218-4bb1-5d5f-9306-22c0bc5847af','20000000-0000-0000-0000-000000000006',$p$blond$p$,$p$rubio$p$,333,'adjetivo'),
 ('47614853-32a5-572b-82eb-f6407a599fd8','20000000-0000-0000-0000-000000000006',$p$bruin$p$,$p$castaño$p$,334,'adjetivo'),
 ('19d9fab3-f9a5-5d65-b534-613260f36467','20000000-0000-0000-0000-000000000006',$p$kort$p$,$p$corto$p$,335,'adjetivo'),
 ('a04496e3-5890-5b34-90a4-a79ed0b9d97a','20000000-0000-0000-0000-000000000006',$p$eruitzien$p$,$p$tener aspecto (de)$p$,336,'verbo')
on conflict (id) do nothing;

-- ── Unidad 12 (A2·nl): Salud, cuerpo y consejos ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('d21e5867-eaeb-57f5-afb0-c2f27602b887','20000000-0000-0000-0000-000000000006','A2',12,$p$Salud, cuerpo y consejos$p$,'#D35400','healing')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('08e8785d-0431-5808-865d-b380915c404e','d21e5867-eaeb-57f5-afb0-c2f27602b887',1,$p$El cuerpo, de la cabeza a los pies$p$,$p$El cuerpo, de la cabeza a los pies$p$,'lesson',15),
 ('5f8013dc-63ef-5fd9-a968-30b9bbbf7e33','d21e5867-eaeb-57f5-afb0-c2f27602b887',2,$p$Me duele: hoofdpijn y doet pijn$p$,$p$Me duele: hoofdpijn y doet pijn$p$,'lesson',15),
 ('abb7dfc5-d8e2-555a-8ce4-c0f1ee5572a0','d21e5867-eaeb-57f5-afb0-c2f27602b887',3,$p$Consejos: je moet, je zou moeten$p$,$p$Consejos: je moet, je zou moeten$p$,'lesson',15),
 ('8d3ff712-6224-5284-8f19-0ddab56cc7a5','d21e5867-eaeb-57f5-afb0-c2f27602b887',4,$p$En la consulta del médico$p$,$p$En la consulta del médico$p$,'lesson',15),
 ('e4bc4657-d412-5aee-b728-fb4bcc0bac4b','d21e5867-eaeb-57f5-afb0-c2f27602b887',5,$p$🏁 Checkpoint Eenheid 12$p$,$p$Nombra las partes del cuerpo, di qué te duele y da consejos con moeten y zou moeten.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('b27a7c5d-856c-581d-8c1f-6d01e20098de','20000000-0000-0000-0000-000000000006','checkpoint','A2','d21e5867-eaeb-57f5-afb0-c2f27602b887',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('21701620-0f0b-5232-afee-b1f59aff2b7e'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','reading','match',$p$Une cada parte del cuerpo con su traducción.$p$,$j${"pairs": [{"en": "het hoofd", "es": "la cabeza"}, {"en": "de rug", "es": "la espalda"}, {"en": "de voet", "es": "el pie"}]}$j$::jsonb,$j${"pairs": [["het hoofd", "la cabeza"], ["de rug", "la espalda"], ["de voet", "el pie"]]}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$lichaamsdelen$p$, $p$reading$p$]),
('5087da81-5ce2-5658-8669-681f4eb7360f'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','reading','multiple_choice',$p$Elige el artículo definido correcto: «___ been».$p$,$j${"options": ["het", "de", "den"]}$j$::jsonb,$j${"value": "het"}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$lichaamsdelen$p$, $p$reading$p$]),
('455b38f3-36a7-54cd-86b0-902e7b89c2dc'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ik heb twee armen en twee benen.", "Ik heb twee handen en twee voeten.", "Ik heb een arm en een been."], "say": "Ik heb twee armen en twee benen.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/455b38f3-36a7-54cd-86b0-902e7b89c2dc.mp3"}$j$::jsonb,$j${"value": "Ik heb twee armen en twee benen."}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$lichaamsdelen$p$, $p$listening$p$]),
('62378384-def9-5fbf-99e4-4c4e915d39dd'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Mijn handen en mijn voeten zijn koud.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/62378384-def9-5fbf-99e4-4c4e915d39dd.mp3"}$j$::jsonb,$j${"expected": "Mijn handen en mijn voeten zijn koud."}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$lichaamsdelen$p$, $p$speaking$p$]),
('19932f02-9899-5950-b70b-7b271a26afed'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','reading','multiple_choice',$p$Elige la frase correcta para decir que te duele la cabeza.$p$,$j${"options": ["Ik heb hoofdpijn.", "Ik heb pijn hoofd.", "Ik heb een hoofd pijn."]}$j$::jsonb,$j${"value": "Ik heb hoofdpijn."}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$pijn_klachten$p$, $p$reading$p$]),
('214d4bc6-4f7d-53f4-9f09-0c74860899af'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','reading','multiple_choice',$p$Elige la forma correcta: «Mijn voeten ___ pijn.»$p$,$j${"options": ["doen", "doet", "is"]}$j$::jsonb,$j${"value": "doen"}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$pijn_klachten$p$, $p$reading$p$]),
('15b5c69d-b334-5c38-b806-0e39fb49015c'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','writing','cloze',$p$Completa: te duele la garganta (una sola palabra).$p$,$j${"text": "Ik heb ___ en ik ga naar bed."}$j$::jsonb,$j${"value": "keelpijn", "accepted": ["keelpijn"]}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$pijn_klachten$p$, $p$writing$p$]),
('442ebd2f-3675-5983-be08-5af7a297d823'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','writing','translation',$p$Traduce: Me duele la espalda.$p$,$j${"source": "Me duele la espalda."}$j$::jsonb,$j${"value": "Mijn rug doet pijn.", "accepted": ["Mijn rug doet pijn.", "Mijn rug doet pijn", "Ik heb rugpijn.", "Ik heb rugpijn", "Ik heb pijn in mijn rug.", "Ik heb pijn in mijn rug"]}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$pijn_klachten$p$, $p$writing$p$]),
('2aaf669d-b3a5-54ff-9762-c7b0407bc949'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ik heb buikpijn en hoofdpijn.", "Ik heb keelpijn en koorts.", "Ik heb rugpijn en hoofdpijn."], "say": "Ik heb buikpijn en hoofdpijn.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/2aaf669d-b3a5-54ff-9762-c7b0407bc949.mp3"}$j$::jsonb,$j${"value": "Ik heb buikpijn en hoofdpijn."}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$pijn_klachten$p$, $p$listening$p$]),
('115121db-4406-5a61-8e55-00a263885a0a'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Mijn tanden doen pijn.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/115121db-4406-5a61-8e55-00a263885a0a.mp3"}$j$::jsonb,$j${"expected": "Mijn tanden doen pijn."}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$pijn_klachten$p$, $p$speaking$p$]),
('f35c4ddd-a74d-5ec3-a3c2-7c497dbf5136'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','reading','match',$p$Une cada expresión con su significado.$p$,$j${"pairs": [{"en": "je moet", "es": "debes"}, {"en": "je zou moeten", "es": "deberías"}, {"en": "rusten", "es": "descansar"}]}$j$::jsonb,$j${"pairs": [["je moet", "debes"], ["je zou moeten", "deberías"], ["rusten", "descansar"]]}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$advies_moeten$p$, $p$reading$p$]),
('1d2b6ca8-6b37-5765-ae4f-f953db960678'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','writing','cloze',$p$Completa el consejo en condicional (deberías…).$p$,$j${"text": "Je ___ naar de dokter moeten gaan."}$j$::jsonb,$j${"value": "zou", "accepted": ["zou"]}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$advies_moeten$p$, $p$writing$p$]),
('40b6ecb4-ad69-528c-acc6-c915da169d61'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','writing','word_bank',$p$Forma la frase: Debes descansar hoy.$p$,$j${"tiles": ["Je", "moet", "vandaag", "rusten", "rust", "pijn"]}$j$::jsonb,$j${"value": "Je moet vandaag rusten", "sequence": ["Je", "moet", "vandaag", "rusten"]}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$advies_moeten$p$, $p$writing$p$]),
('8dd46978-3ce2-557b-bb63-6ee0fc93fae3'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Je zou naar de dokter moeten gaan.", "Je moet nu naar de dokter gaan.", "Ik ga morgen naar de dokter."], "say": "Je zou naar de dokter moeten gaan.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/8dd46978-3ce2-557b-bb63-6ee0fc93fae3.mp3"}$j$::jsonb,$j${"value": "Je zou naar de dokter moeten gaan."}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$advies_moeten$p$, $p$listening$p$]),
('f7494145-cca7-5289-bd3f-4e97b36e38ce'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Je moet veel water drinken.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/f7494145-cca7-5289-bd3f-4e97b36e38ce.mp3"}$j$::jsonb,$j${"expected": "Je moet veel water drinken."}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$advies_moeten$p$, $p$speaking$p$]),
('3545eee9-f92c-5b29-8c7a-3d009273e9bd'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','reading','multiple_choice',$p$¿Qué te pregunta el médico para saber qué te pasa?$p$,$j${"options": ["Wat is er aan de hand?", "Hoe laat is het?", "Waar woon je?"]}$j$::jsonb,$j${"value": "Wat is er aan de hand?"}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$bij_de_dokter$p$, $p$reading$p$]),
('0e799da7-a4b9-5570-a399-4b658a70d1a0'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','writing','translation',$p$Traduce: Estoy enfermo y tengo fiebre.$p$,$j${"source": "Estoy enfermo y tengo fiebre."}$j$::jsonb,$j${"value": "Ik ben ziek en ik heb koorts.", "accepted": ["Ik ben ziek en ik heb koorts.", "Ik ben ziek en ik heb koorts", "Ik ben ziek en heb koorts.", "Ik ben ziek en heb koorts"]}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$bij_de_dokter$p$, $p$writing$p$]),
('00843832-e95b-5459-8508-76eb89a597fe'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','writing','reorder',$p$Ordena las palabras: Hoy debo ir al médico.$p$,$j${"tiles": ["naar", "Ik", "dokter", "gaan", "moet", "de", "vandaag"]}$j$::jsonb,$j${"value": "Ik moet vandaag naar de dokter gaan"}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$bij_de_dokter$p$, $p$writing$p$]),
('1c10739c-95d7-588b-8ffb-25a0ff66fcdf'::uuid,'20000000-0000-0000-0000-000000000006'::uuid,'A2','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ik heb koorts en ik ga naar de dokter.", "Ik heb keelpijn en ik ga naar bed.", "Ik heb koorts en ik blijf thuis."], "say": "Ik heb koorts en ik ga naar de dokter.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/1c10739c-95d7-588b-8ffb-25a0ff66fcdf.mp3"}$j$::jsonb,$j${"value": "Ik heb koorts en ik ga naar de dokter."}$j$::jsonb,0.34,ARRAY[$p$unidad12$p$, $p$bij_de_dokter$p$, $p$listening$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('08e8785d-0431-5808-865d-b380915c404e','21701620-0f0b-5232-afee-b1f59aff2b7e',1),
 ('08e8785d-0431-5808-865d-b380915c404e','5087da81-5ce2-5658-8669-681f4eb7360f',2),
 ('08e8785d-0431-5808-865d-b380915c404e','455b38f3-36a7-54cd-86b0-902e7b89c2dc',3),
 ('08e8785d-0431-5808-865d-b380915c404e','62378384-def9-5fbf-99e4-4c4e915d39dd',4),
 ('5f8013dc-63ef-5fd9-a968-30b9bbbf7e33','19932f02-9899-5950-b70b-7b271a26afed',1),
 ('5f8013dc-63ef-5fd9-a968-30b9bbbf7e33','214d4bc6-4f7d-53f4-9f09-0c74860899af',2),
 ('5f8013dc-63ef-5fd9-a968-30b9bbbf7e33','15b5c69d-b334-5c38-b806-0e39fb49015c',3),
 ('5f8013dc-63ef-5fd9-a968-30b9bbbf7e33','442ebd2f-3675-5983-be08-5af7a297d823',4),
 ('5f8013dc-63ef-5fd9-a968-30b9bbbf7e33','2aaf669d-b3a5-54ff-9762-c7b0407bc949',5),
 ('5f8013dc-63ef-5fd9-a968-30b9bbbf7e33','115121db-4406-5a61-8e55-00a263885a0a',6),
 ('abb7dfc5-d8e2-555a-8ce4-c0f1ee5572a0','f35c4ddd-a74d-5ec3-a3c2-7c497dbf5136',1),
 ('abb7dfc5-d8e2-555a-8ce4-c0f1ee5572a0','1d2b6ca8-6b37-5765-ae4f-f953db960678',2),
 ('abb7dfc5-d8e2-555a-8ce4-c0f1ee5572a0','40b6ecb4-ad69-528c-acc6-c915da169d61',3),
 ('abb7dfc5-d8e2-555a-8ce4-c0f1ee5572a0','8dd46978-3ce2-557b-bb63-6ee0fc93fae3',4),
 ('abb7dfc5-d8e2-555a-8ce4-c0f1ee5572a0','f7494145-cca7-5289-bd3f-4e97b36e38ce',5),
 ('8d3ff712-6224-5284-8f19-0ddab56cc7a5','3545eee9-f92c-5b29-8c7a-3d009273e9bd',1),
 ('8d3ff712-6224-5284-8f19-0ddab56cc7a5','0e799da7-a4b9-5570-a399-4b658a70d1a0',2),
 ('8d3ff712-6224-5284-8f19-0ddab56cc7a5','00843832-e95b-5459-8508-76eb89a597fe',3),
 ('8d3ff712-6224-5284-8f19-0ddab56cc7a5','1c10739c-95d7-588b-8ffb-25a0ff66fcdf',4),
 ('e4bc4657-d412-5aee-b728-fb4bcc0bac4b','21701620-0f0b-5232-afee-b1f59aff2b7e',1),
 ('e4bc4657-d412-5aee-b728-fb4bcc0bac4b','5087da81-5ce2-5658-8669-681f4eb7360f',2),
 ('e4bc4657-d412-5aee-b728-fb4bcc0bac4b','19932f02-9899-5950-b70b-7b271a26afed',3),
 ('e4bc4657-d412-5aee-b728-fb4bcc0bac4b','15b5c69d-b334-5c38-b806-0e39fb49015c',4),
 ('e4bc4657-d412-5aee-b728-fb4bcc0bac4b','442ebd2f-3675-5983-be08-5af7a297d823',5),
 ('e4bc4657-d412-5aee-b728-fb4bcc0bac4b','1d2b6ca8-6b37-5765-ae4f-f953db960678',6),
 ('e4bc4657-d412-5aee-b728-fb4bcc0bac4b','455b38f3-36a7-54cd-86b0-902e7b89c2dc',7),
 ('e4bc4657-d412-5aee-b728-fb4bcc0bac4b','2aaf669d-b3a5-54ff-9762-c7b0407bc949',8),
 ('e4bc4657-d412-5aee-b728-fb4bcc0bac4b','62378384-def9-5fbf-99e4-4c4e915d39dd',9),
 ('e4bc4657-d412-5aee-b728-fb4bcc0bac4b','115121db-4406-5a61-8e55-00a263885a0a',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('1519ebdd-3c79-5c9e-b5ec-789f2629244d','20000000-0000-0000-0000-000000000006',$p$het hoofd$p$,$p$la cabeza$p$,341,'sustantivo'),
 ('357ca415-b6b8-5860-9cf9-6f11f116fec9','20000000-0000-0000-0000-000000000006',$p$de buik$p$,$p$la barriga$p$,342,'sustantivo'),
 ('ae2b42e4-1029-5564-a5d1-ba7e4d60682f','20000000-0000-0000-0000-000000000006',$p$de rug$p$,$p$la espalda$p$,343,'sustantivo'),
 ('7dbad3e6-11b3-536a-b65e-5cae70c4729d','20000000-0000-0000-0000-000000000006',$p$de keel$p$,$p$la garganta$p$,344,'sustantivo'),
 ('e15cff97-e24a-521e-beb9-ccdb85923262','20000000-0000-0000-0000-000000000006',$p$het been$p$,$p$la pierna$p$,345,'sustantivo'),
 ('84834517-091e-5fdd-8c2e-ff5d383dec12','20000000-0000-0000-0000-000000000006',$p$de arm$p$,$p$el brazo$p$,346,'sustantivo'),
 ('36a57574-0bd9-5564-92c8-ffe9a94e0c07','20000000-0000-0000-0000-000000000006',$p$de hand$p$,$p$la mano$p$,347,'sustantivo'),
 ('834303bd-0289-5235-9026-f6a5eae90f16','20000000-0000-0000-0000-000000000006',$p$de voet$p$,$p$el pie$p$,348,'sustantivo'),
 ('5a47bf62-10c1-5ef6-8702-915eedbb550b','20000000-0000-0000-0000-000000000006',$p$de tanden$p$,$p$los dientes$p$,349,'sustantivo'),
 ('ab4e26ad-57b9-5e5f-8221-9821e1b3eaef','20000000-0000-0000-0000-000000000006',$p$de hoofdpijn$p$,$p$el dolor de cabeza$p$,350,'sustantivo'),
 ('c337b06c-d055-5f5d-aa03-c390f8506fc9','20000000-0000-0000-0000-000000000006',$p$de koorts$p$,$p$la fiebre$p$,351,'sustantivo'),
 ('96b37046-a359-5257-ae25-a134490670eb','20000000-0000-0000-0000-000000000006',$p$ziek$p$,$p$enfermo$p$,352,'adjetivo'),
 ('7ad7675e-fcb4-5a40-8e75-6c2c60c1707e','20000000-0000-0000-0000-000000000006',$p$de dokter$p$,$p$el médico$p$,353,'sustantivo'),
 ('4931d339-083c-5096-b6cf-039febbc5f4d','20000000-0000-0000-0000-000000000006',$p$rusten$p$,$p$descansar$p$,354,'verbo'),
 ('94d6b9d9-0f87-5a98-857e-9d57ef30b25c','20000000-0000-0000-0000-000000000006',$p$pijn doen$p$,$p$doler$p$,355,'expresion'),
 ('95ba72e5-1abc-55f4-88da-ed0c4d92725d','20000000-0000-0000-0000-000000000006',$p$moeten$p$,$p$deber, tener que$p$,356,'verbo')
on conflict (id) do nothing;

commit;