-- 20260703120114_seed_it_b1.sql
-- Currículo B1 del curso es→it (6 unidades). Molde es→pt.
-- Contenido scopeado a course_id=20000000-0000-0000-0000-000000000004 → aislamiento multicurso por
-- jz_active_course. Unidades order_index continúan la cadena → gating al nivel previo.
begin;
insert into languages (id, code, name) values
  ('10000000-0000-0000-0000-000000000005','it',$p$Italiano$p$) on conflict (id) do nothing;
insert into courses (id, source_language_id, target_language_id, is_active) values
  ('20000000-0000-0000-0000-000000000004','10000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000005',true) on conflict (id) do nothing;

-- ── Unidad 13 (B1·it): Opinión y deseo (congiuntivo presente) ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('ec0e526c-186a-5af5-ac12-2182d3fc8f41','20000000-0000-0000-0000-000000000004','B1',13,$p$Opinión y deseo (congiuntivo presente)$p$,'#6C3483','auto_awesome')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('50b15848-5c72-5c49-8e1c-4039222b4b87','ec0e526c-186a-5af5-ac12-2182d3fc8f41',1,$p$Formación regular (parli, prenda, senta)$p$,$p$Formación regular (parli, prenda, senta)$p$,'lesson',15),
 ('f9f33284-0120-5dae-bf83-544b682e1687','ec0e526c-186a-5af5-ac12-2182d3fc8f41',2,$p$Irregulares frecuentes (sia, abbia, faccia, vada)$p$,$p$Irregulares frecuentes (sia, abbia, faccia, vada)$p$,'lesson',15),
 ('2b72007d-fe6f-5462-9a75-65e9ef389778','ec0e526c-186a-5af5-ac12-2182d3fc8f41',3,$p$Opinión, duda y voluntad (Penso che, Voglio che)$p$,$p$Opinión, duda y voluntad (Penso che, Voglio che)$p$,'lesson',15),
 ('bbc6e276-60f9-54a9-ae6b-896946375082','ec0e526c-186a-5af5-ac12-2182d3fc8f41',4,$p$Conjunciones e impersonales (benché, prima che, bisogna che)$p$,$p$Conjunciones e impersonales (benché, prima che, bisogna che)$p$,'lesson',15),
 ('1dd3700c-a714-57d3-bc36-5bf6ab229ad8','ec0e526c-186a-5af5-ac12-2182d3fc8f41',5,$p$🏁 Checkpoint Unità 13$p$,$p$Usa el congiuntivo presente para expresar opinión, duda, voluntad, necesidad y con conjunciones como benché y prima che.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('7903bce1-3529-59f7-835b-b7e70fd15b57','20000000-0000-0000-0000-000000000004','checkpoint','B1','ec0e526c-186a-5af5-ac12-2182d3fc8f41',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('7fbf8702-03f6-5e24-bc41-6dd8ca138c21'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','reading','match',$p$Une la frase italiana con su traducción.$p$,$j${"pairs": [{"en": "Penso che tu parli bene.", "es": "Pienso que tú hablas bien."}, {"en": "Credo che lei prenda il treno.", "es": "Creo que ella toma el tren."}, {"en": "Spero che loro sentano la musica.", "es": "Espero que ellos oigan la música."}]}$j$::jsonb,$j${"pairs": [["Penso che tu parli bene.", "Pienso que tú hablas bien."], ["Credo che lei prenda il treno.", "Creo que ella toma el tren."], ["Spero che loro sentano la musica.", "Espero que ellos oigan la música."]]}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$congiuntivo_presente$p$, $p$reading$p$]),
('54ee5e4a-9167-52af-842c-5650bbd497f2'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','writing','cloze',$p$Completa con el congiuntivo presente de « parlare ».$p$,$j${"text": "Penso che tu ___ troppo velocemente."}$j$::jsonb,$j${"value": "parli", "accepted": ["parli"]}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$congiuntivo_are$p$, $p$writing$p$]),
('912f201d-c359-5ac3-ba4c-1b99679c4665'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','reading','multiple_choice',$p$Elige la forma correcta del congiuntivo presente.$p$,$j${"options": ["Credo che lui prenda l'autobus.", "Credo che lui prende l'autobus.", "Credo che lui prenderà l'autobus."]}$j$::jsonb,$j${"value": "Credo che lui prenda l'autobus."}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$congiuntivo_ere$p$, $p$reading$p$]),
('4969d2f3-2229-5d96-a51a-d78aae2bfa9a'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Penso che lui finisca il lavoro oggi.", "So che lui finisce il lavoro oggi.", "Penso che lui finirà il lavoro domani."], "say": "Penso che lui finisca il lavoro oggi.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/4969d2f3-2229-5d96-a51a-d78aae2bfa9a.mp3"}$j$::jsonb,$j${"value": "Penso che lui finisca il lavoro oggi."}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$congiuntivo_isc$p$, $p$listening$p$]),
('bcea8065-773d-5dc7-afa0-c49a93d2f058'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Spero che voi partiate presto domani mattina.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/bcea8065-773d-5dc7-afa0-c49a93d2f058.mp3"}$j$::jsonb,$j${"expected": "Spero che voi partiate presto domani mattina."}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$congiuntivo_ire$p$, $p$speaking$p$]),
('9d0c952e-9056-5e1f-94dc-1a05e9fa68af'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','reading','multiple_choice',$p$Elige la forma correcta del congiuntivo presente.$p$,$j${"options": ["Penso che lei sia stanca.", "Penso che lei è stanca.", "Penso che lei sarà stanca."]}$j$::jsonb,$j${"value": "Penso che lei sia stanca."}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$congiuntivo_essere$p$, $p$reading$p$]),
('e58f4aa1-a9e6-546f-805b-2b60baec3e66'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','writing','cloze',$p$Completa con el congiuntivo presente de « avere ».$p$,$j${"text": "Credo che loro ___ ragione."}$j$::jsonb,$j${"value": "abbiano", "accepted": ["abbiano"]}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$congiuntivo_avere$p$, $p$writing$p$]),
('ad6e919e-264f-5216-bfdf-97d4afb97b7d'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','writing','word_bank',$p$Construye la frase: Quiero que tú hagas silencio.$p$,$j${"tiles": ["Voglio", "che", "tu", "faccia", "silenzio", "fai", "fare"]}$j$::jsonb,$j${"value": "Voglio che tu faccia silenzio", "sequence": ["Voglio", "che", "tu", "faccia", "silenzio"]}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$congiuntivo_fare$p$, $p$writing$p$]),
('ff0753d5-722b-537c-8e12-c2312627d8d0'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Bisogna che tu vada dal medico.", "Bisogna che tu vai dal medico.", "Bisogna che tu andrai dal medico."], "say": "Bisogna che tu vada dal medico.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/ff0753d5-722b-537c-8e12-c2312627d8d0.mp3"}$j$::jsonb,$j${"value": "Bisogna che tu vada dal medico."}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$congiuntivo_andare$p$, $p$listening$p$]),
('beb41e0b-0ca6-5aa9-b7e6-083c114d3901'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','reading','match',$p$Une la frase italiana con su traducción.$p$,$j${"pairs": [{"en": "Spero che tu possa venire.", "es": "Espero que puedas venir."}, {"en": "Voglio che lui venga con noi.", "es": "Quiero que él venga con nosotros."}, {"en": "Penso che lei sappia la verità.", "es": "Pienso que ella sabe la verdad."}]}$j$::jsonb,$j${"pairs": [["Spero che tu possa venire.", "Espero que puedas venir."], ["Voglio che lui venga con noi.", "Quiero que él venga con nosotros."], ["Penso che lei sappia la verità.", "Pienso que ella sabe la verdad."]]}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$congiuntivo_potere$p$, $p$reading$p$]),
('6a7117bc-0b2d-566d-93b6-cac56c0ec3cd'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Spero che tu stia bene e che abbia una buona giornata.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/6a7117bc-0b2d-566d-93b6-cac56c0ec3cd.mp3"}$j$::jsonb,$j${"expected": "Spero che tu stia bene e che abbia una buona giornata."}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$congiuntivo_irregolari$p$, $p$speaking$p$]),
('6bc46098-73dc-5085-89d1-62ef1458d571'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','reading','multiple_choice',$p$Elige la forma correcta después de « Credo che ».$p$,$j${"options": ["Credo che sia troppo tardi.", "Credo che è troppo tardi.", "Credo che sarà troppo tardi."]}$j$::jsonb,$j${"value": "Credo che sia troppo tardi."}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$opinione_dubbio$p$, $p$reading$p$]),
('1d5a23ec-8a21-5aec-8801-9c7d1c31074d'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','writing','cloze',$p$Completa con el congiuntivo presente de « venire ».$p$,$j${"text": "I miei genitori vogliono che io ___ a cena."}$j$::jsonb,$j${"value": "venga", "accepted": ["venga"]}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$volere_che$p$, $p$writing$p$]),
('ceda7b96-bc28-56ae-a0cf-a2fa06e1b8ca'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','writing','translation',$p$Traduce: Espero que tú tengas fortuna.$p$,$j${"source": "Espero que tú tengas fortuna."}$j$::jsonb,$j${"value": "Spero che tu abbia fortuna.", "accepted": ["Spero che tu abbia fortuna", "Spero che tu abbia fortuna."]}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$sperare_che$p$, $p$writing$p$]),
('3d56eccb-6adf-5111-97d7-9a1369a3d234'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Penso che lei dica sempre la verità.", "So che lei dice sempre la verità.", "Penso che lei dirà sempre la verità."], "say": "Penso che lei dica sempre la verità.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/3d56eccb-6adf-5111-97d7-9a1369a3d234.mp3"}$j$::jsonb,$j${"value": "Penso che lei dica sempre la verità."}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$indicativo_vs_congiuntivo$p$, $p$listening$p$]),
('5d5a01f9-d037-5d00-9ae9-886ad4dca710'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Credo che questa sia la scelta migliore per tutti noi.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/5d5a01f9-d037-5d00-9ae9-886ad4dca710.mp3"}$j$::jsonb,$j${"expected": "Credo che questa sia la scelta migliore per tutti noi."}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$opinione_speak$p$, $p$speaking$p$]),
('59da1e9d-431d-5e06-a42e-aac027dae0ce'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','reading','multiple_choice',$p$Elige la forma correcta después de « benché ».$p$,$j${"options": ["Benché sia stanco, lavoro ancora.", "Benché sono stanco, lavoro ancora.", "Benché sarò stanco, lavoro ancora."]}$j$::jsonb,$j${"value": "Benché sia stanco, lavoro ancora."}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$benche$p$, $p$reading$p$]),
('8b7fdc6f-00d3-5d9f-a4fb-e26f826d02b0'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','writing','cloze',$p$Completa con el congiuntivo presente de « fare ».$p$,$j${"text": "Usciamo prima che ___ buio."}$j$::jsonb,$j${"value": "faccia", "accepted": ["faccia"]}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$prima_che$p$, $p$writing$p$]),
('87f417db-306f-5cdc-9376-40e66db9f678'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Vengo con te a meno che tu non voglia andare da solo.", "Vengo con te a meno che tu non vuoi andare da solo.", "Vengo con te a meno che tu non vorrai andare da solo."], "say": "Vengo con te a meno che tu non voglia andare da solo.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/87f417db-306f-5cdc-9376-40e66db9f678.mp3"}$j$::jsonb,$j${"value": "Vengo con te a meno che tu non voglia andare da solo."}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$a_meno_che$p$, $p$listening$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('50b15848-5c72-5c49-8e1c-4039222b4b87','7fbf8702-03f6-5e24-bc41-6dd8ca138c21',1),
 ('50b15848-5c72-5c49-8e1c-4039222b4b87','54ee5e4a-9167-52af-842c-5650bbd497f2',2),
 ('50b15848-5c72-5c49-8e1c-4039222b4b87','912f201d-c359-5ac3-ba4c-1b99679c4665',3),
 ('50b15848-5c72-5c49-8e1c-4039222b4b87','4969d2f3-2229-5d96-a51a-d78aae2bfa9a',4),
 ('50b15848-5c72-5c49-8e1c-4039222b4b87','bcea8065-773d-5dc7-afa0-c49a93d2f058',5),
 ('f9f33284-0120-5dae-bf83-544b682e1687','9d0c952e-9056-5e1f-94dc-1a05e9fa68af',1),
 ('f9f33284-0120-5dae-bf83-544b682e1687','e58f4aa1-a9e6-546f-805b-2b60baec3e66',2),
 ('f9f33284-0120-5dae-bf83-544b682e1687','ad6e919e-264f-5216-bfdf-97d4afb97b7d',3),
 ('f9f33284-0120-5dae-bf83-544b682e1687','ff0753d5-722b-537c-8e12-c2312627d8d0',4),
 ('f9f33284-0120-5dae-bf83-544b682e1687','beb41e0b-0ca6-5aa9-b7e6-083c114d3901',5),
 ('f9f33284-0120-5dae-bf83-544b682e1687','6a7117bc-0b2d-566d-93b6-cac56c0ec3cd',6),
 ('2b72007d-fe6f-5462-9a75-65e9ef389778','6bc46098-73dc-5085-89d1-62ef1458d571',1),
 ('2b72007d-fe6f-5462-9a75-65e9ef389778','1d5a23ec-8a21-5aec-8801-9c7d1c31074d',2),
 ('2b72007d-fe6f-5462-9a75-65e9ef389778','ceda7b96-bc28-56ae-a0cf-a2fa06e1b8ca',3),
 ('2b72007d-fe6f-5462-9a75-65e9ef389778','3d56eccb-6adf-5111-97d7-9a1369a3d234',4),
 ('2b72007d-fe6f-5462-9a75-65e9ef389778','5d5a01f9-d037-5d00-9ae9-886ad4dca710',5),
 ('bbc6e276-60f9-54a9-ae6b-896946375082','59da1e9d-431d-5e06-a42e-aac027dae0ce',1),
 ('bbc6e276-60f9-54a9-ae6b-896946375082','8b7fdc6f-00d3-5d9f-a4fb-e26f826d02b0',2),
 ('bbc6e276-60f9-54a9-ae6b-896946375082','87f417db-306f-5cdc-9376-40e66db9f678',3),
 ('1dd3700c-a714-57d3-bc36-5bf6ab229ad8','7fbf8702-03f6-5e24-bc41-6dd8ca138c21',1),
 ('1dd3700c-a714-57d3-bc36-5bf6ab229ad8','912f201d-c359-5ac3-ba4c-1b99679c4665',2),
 ('1dd3700c-a714-57d3-bc36-5bf6ab229ad8','9d0c952e-9056-5e1f-94dc-1a05e9fa68af',3),
 ('1dd3700c-a714-57d3-bc36-5bf6ab229ad8','54ee5e4a-9167-52af-842c-5650bbd497f2',4),
 ('1dd3700c-a714-57d3-bc36-5bf6ab229ad8','e58f4aa1-a9e6-546f-805b-2b60baec3e66',5),
 ('1dd3700c-a714-57d3-bc36-5bf6ab229ad8','ad6e919e-264f-5216-bfdf-97d4afb97b7d',6),
 ('1dd3700c-a714-57d3-bc36-5bf6ab229ad8','4969d2f3-2229-5d96-a51a-d78aae2bfa9a',7),
 ('1dd3700c-a714-57d3-bc36-5bf6ab229ad8','ff0753d5-722b-537c-8e12-c2312627d8d0',8),
 ('1dd3700c-a714-57d3-bc36-5bf6ab229ad8','bcea8065-773d-5dc7-afa0-c49a93d2f058',9),
 ('1dd3700c-a714-57d3-bc36-5bf6ab229ad8','6a7117bc-0b2d-566d-93b6-cac56c0ec3cd',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('2e1af780-53d2-509b-952a-4481913cffc7','20000000-0000-0000-0000-000000000004',$p$il congiuntivo$p$,$p$el subjuntivo$p$,361,'sustantivo'),
 ('307bbe5c-6837-5aab-a8ad-c681ba16c439','20000000-0000-0000-0000-000000000004',$p$pensare che$p$,$p$pensar que$p$,362,'expresion'),
 ('7be0e5ee-508c-5636-bffa-72838157bf11','20000000-0000-0000-0000-000000000004',$p$credere che$p$,$p$creer que$p$,363,'expresion'),
 ('f358f07d-0a5c-5a5e-b367-a0d1154ea9f7','20000000-0000-0000-0000-000000000004',$p$volere che$p$,$p$querer que$p$,364,'expresion'),
 ('1e9aca48-4448-56bb-bb15-3eef93023f40','20000000-0000-0000-0000-000000000004',$p$sperare che$p$,$p$esperar que$p$,365,'expresion'),
 ('e98784fe-9fe4-5852-b77e-63838a2f4ffe','20000000-0000-0000-0000-000000000004',$p$bisogna che$p$,$p$es necesario que$p$,366,'expresion'),
 ('de7526d0-2ae6-5f4b-8552-fdc28c1b0f06','20000000-0000-0000-0000-000000000004',$p$è importante che$p$,$p$es importante que$p$,367,'expresion'),
 ('da5e4a28-1626-5b13-ae0a-d79c9d20c618','20000000-0000-0000-0000-000000000004',$p$è possibile che$p$,$p$es posible que$p$,368,'expresion'),
 ('f3e2caff-b724-5f18-b32d-208ff2bba9bd','20000000-0000-0000-0000-000000000004',$p$benché$p$,$p$aunque$p$,369,'expresion'),
 ('578848b3-6d48-52d6-ba74-a985be8225af','20000000-0000-0000-0000-000000000004',$p$sebbene$p$,$p$aunque$p$,370,'expresion'),
 ('f2bb224b-849d-5e8b-bed5-51dab397dfcc','20000000-0000-0000-0000-000000000004',$p$affinché$p$,$p$para que$p$,371,'expresion'),
 ('bc22eff0-6ad8-5a40-a6ae-8d0b94f01d95','20000000-0000-0000-0000-000000000004',$p$prima che$p$,$p$antes de que$p$,372,'expresion'),
 ('1c1639b6-10ba-539c-baab-1a2e51381890','20000000-0000-0000-0000-000000000004',$p$a meno che$p$,$p$a menos que$p$,373,'expresion'),
 ('06ff549e-ba37-567a-9b6c-563ab89c42e1','20000000-0000-0000-0000-000000000004',$p$il dubbio$p$,$p$la duda$p$,374,'sustantivo'),
 ('2ee56209-9f61-5598-868d-18bf85f4f8ae','20000000-0000-0000-0000-000000000004',$p$la volontà$p$,$p$la voluntad$p$,375,'sustantivo'),
 ('23e50822-ef6b-59f5-ac1d-59ba86f7e881','20000000-0000-0000-0000-000000000004',$p$l'opinione$p$,$p$la opinión$p$,376,'sustantivo')
on conflict (id) do nothing;

-- ── Unidad 14 (B1·it): Futuro, condicional e hipótesis ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('4d4bee9a-7dbf-5c89-99f1-b89d251d82fd','20000000-0000-0000-0000-000000000004','B1',14,$p$Futuro, condicional e hipótesis$p$,'#1F618D','schedule')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('10825efc-80f6-5106-b7a1-10280406e443','4d4bee9a-7dbf-5c89-99f1-b89d251d82fd',1,$p$El futuro simple regular$p$,$p$El futuro simple regular$p$,'lesson',15),
 ('6ac9cae5-c306-5a53-97de-d56f96d420b0','4d4bee9a-7dbf-5c89-99f1-b89d251d82fd',2,$p$Futuros irregulares y probabilidad$p$,$p$Futuros irregulares y probabilidad$p$,'lesson',15),
 ('80bee971-d711-5320-89f4-ecf725c21388','4d4bee9a-7dbf-5c89-99f1-b89d251d82fd',3,$p$El condicional: cortesía y consejos$p$,$p$El condicional: cortesía y consejos$p$,'lesson',15),
 ('db01be68-1b59-5a67-932b-154907305365','4d4bee9a-7dbf-5c89-99f1-b89d251d82fd',4,$p$Hipótesis con 'se' (tipo I)$p$,$p$Hipótesis con 'se' (tipo I)$p$,'lesson',15),
 ('9c995cd4-3b27-54a1-83bb-2ad04ed71d80','4d4bee9a-7dbf-5c89-99f1-b89d251d82fd',5,$p$🏁 Checkpoint Unità 14$p$,$p$Demuestra que dominas el futuro simple (parlerò, sarò, andrò), el condicional presente (vorrei, potrei, dovrei) y el período hipotético de la realidad (Se piove, resto a casa).$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('be2f2365-a3ac-5d26-98eb-68ab3008c3c8','20000000-0000-0000-0000-000000000004','checkpoint','B1','4d4bee9a-7dbf-5c89-99f1-b89d251d82fd',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('c10bf006-6cca-53d3-9f56-183fe95d4295'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','reading','match',$p$Une cada forma de futuro con su traducción.$p$,$j${"pairs": [{"en": "parlerò", "es": "hablaré"}, {"en": "prenderai", "es": "tomarás"}, {"en": "dormiremo", "es": "dormiremos"}]}$j$::jsonb,$j${"pairs": [["parlerò", "hablaré"], ["prenderai", "tomarás"], ["dormiremo", "dormiremos"]]}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$futuro_semplice$p$, $p$reading$p$]),
('c76d9e92-2b7a-578b-b68d-c6b884be46b3'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','reading','multiple_choice',$p$Completa: 'Domani io ___ con Marco.' (futuro de 'parlare')$p$,$j${"options": ["parlerò", "parlavo", "parlo"]}$j$::jsonb,$j${"value": "parlerò"}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$futuro_semplice$p$, $p$reading$p$]),
('7e361c27-c72b-5422-83b3-265e0ade9e0f'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','writing','cloze',$p$Escribe el futuro de 'finire' (noi): 'Domani ___ il lavoro presto.'$p$,$j${"text": "Domani ___ il lavoro presto."}$j$::jsonb,$j${"value": "finiremo", "accepted": ["finiremo"]}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$futuro_semplice$p$, $p$writing$p$]),
('12aad811-d367-53b1-b881-1a090467b4e7'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','writing','translation',$p$Traduce: 'Mañana llegaré a las ocho.'$p$,$j${"source": "Mañana llegaré a las ocho."}$j$::jsonb,$j${"value": "Domani arriverò alle otto.", "accepted": ["Domani arriverò alle otto.", "Domani arriverò alle otto", "domani arriverò alle otto", "Arriverò alle otto domani.", "Arriverò alle otto domani"]}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$futuro_semplice$p$, $p$writing$p$]),
('e021bf7c-12bc-5a66-89f9-6c82fd88acf9'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Un giorno partiremo per il Giappone.", "Un giorno siamo partiti per il Giappone.", "Un giorno partivamo per il Giappone."], "say": "Un giorno partiremo per il Giappone.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/e021bf7c-12bc-5a66-89f9-6c82fd88acf9.mp3"}$j$::jsonb,$j${"value": "Un giorno partiremo per il Giappone."}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$futuro_semplice$p$, $p$listening$p$]),
('13b2c808-bb3c-5b09-aaa6-f374602a7e48'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "La settimana prossima visiterò i miei nonni.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/13b2c808-bb3c-5b09-aaa6-f374602a7e48.mp3"}$j$::jsonb,$j${"expected": "La settimana prossima visiterò i miei nonni."}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$futuro_semplice$p$, $p$speaking$p$]),
('94bbf429-1257-514d-9945-22cb299b450d'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','reading','multiple_choice',$p$Completa: 'Sabato noi ___ al mare.' (futuro de 'andare')$p$,$j${"options": ["andremo", "andiamo", "andavamo"]}$j$::jsonb,$j${"value": "andremo"}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$futuro_irregolare$p$, $p$reading$p$]),
('1a14204e-64bc-50c9-a739-a316dbf75508'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','writing','cloze',$p$Futuro de probabilidad. '¿Qué hora es?' — 'No lo sé, ___ le tre.' (futuro de 'essere', loro)$p$,$j${"text": "Non lo so, ___ le tre."}$j$::jsonb,$j${"value": "saranno", "accepted": ["saranno"]}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$futuro_probabilita$p$, $p$writing$p$]),
('12e37712-5f1a-5faa-bbb3-6026d93eefb9'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','writing','word_bank',$p$Forma la frase: 'Mañana tendré mucho tiempo libre.'$p$,$j${"tiles": ["Domani", "avrò", "molto", "tempo", "libero", "avrei", "avevo"]}$j$::jsonb,$j${"value": "Domani avrò molto tempo libero", "sequence": ["Domani", "avrò", "molto", "tempo", "libero"]}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$futuro_irregolare$p$, $p$writing$p$]),
('34112d2d-f565-5b3f-96b9-d2ab14966c0f'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Marco non risponde, sarà occupato.", "Marco non risponde, era occupato.", "Marco non risponde, è occupato."], "say": "Marco non risponde, sarà occupato.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/34112d2d-f565-5b3f-96b9-d2ab14966c0f.mp3"}$j$::jsonb,$j${"value": "Marco non risponde, sarà occupato."}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$futuro_probabilita$p$, $p$listening$p$]),
('7701fe4a-0fa4-56cd-8ea1-ea59c57a4d75'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','reading','multiple_choice',$p$Pide algo con cortesía en un bar: '___ un caffè, per favore.'$p$,$j${"options": ["Vorrei", "Voglio", "Volevo"]}$j$::jsonb,$j${"value": "Vorrei"}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$condizionale_cortesia$p$, $p$reading$p$]),
('6aeb8825-72e4-536b-85ea-bfb42cfcb26a'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','reading','multiple_choice',$p$Da un consejo a un amigo cansado: 'Sei stanco, ___ riposare.'$p$,$j${"options": ["dovresti", "devi", "dovevi"]}$j$::jsonb,$j${"value": "dovresti"}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$condizionale_consiglio$p$, $p$reading$p$]),
('16f1a83b-986c-553a-9f67-b83d2acb5b35'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','writing','cloze',$p$Expresa un deseo con el condicional de 'piacere': 'Mi ___ vivere in Italia.'$p$,$j${"text": "Mi ___ vivere in Italia."}$j$::jsonb,$j${"value": "piacerebbe", "accepted": ["piacerebbe"]}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$condizionale_desiderio$p$, $p$writing$p$]),
('9eefa1b6-246e-58a9-9fcc-5404558f160a'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','writing','translation',$p$Traduce con cortesía: 'Querría reservar una mesa.'$p$,$j${"source": "Querría reservar una mesa."}$j$::jsonb,$j${"value": "Vorrei prenotare un tavolo.", "accepted": ["Vorrei prenotare un tavolo.", "Vorrei prenotare un tavolo", "vorrei prenotare un tavolo", "Vorrei riservare un tavolo.", "Vorrei riservare un tavolo"]}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$condizionale_cortesia$p$, $p$writing$p$]),
('d0d88fa8-9298-5ba9-ab1e-a87530023444'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Potresti aiutarmi con la valigia?", "Puoi aiutarmi con la valigia?", "Potevi aiutarmi con la valigia?"], "say": "Potresti aiutarmi con la valigia?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/d0d88fa8-9298-5ba9-ab1e-a87530023444.mp3"}$j$::jsonb,$j${"value": "Potresti aiutarmi con la valigia?"}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$condizionale_cortesia$p$, $p$listening$p$]),
('90bfa961-4043-5664-8a00-b2babb311abd'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Al posto tuo, prenderei il treno delle nove.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/90bfa961-4043-5664-8a00-b2babb311abd.mp3"}$j$::jsonb,$j${"expected": "Al posto tuo, prenderei il treno delle nove."}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$condizionale_consiglio$p$, $p$speaking$p$]),
('8d395c3e-5eb9-5721-a643-5f422716e2c6'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','reading','match',$p$Une cada frase con su traducción.$p$,$j${"pairs": [{"en": "Se piove, resto a casa", "es": "Si llueve, me quedo en casa"}, {"en": "Se avrò tempo, verrò", "es": "Si tengo tiempo, vendré"}, {"en": "Se vuoi, puoi venire", "es": "Si quieres, puedes venir"}]}$j$::jsonb,$j${"pairs": [["Se piove, resto a casa", "Si llueve, me quedo en casa"], ["Se avrò tempo, verrò", "Si tengo tiempo, vendré"], ["Se vuoi, puoi venire", "Si quieres, puedes venir"]]}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$periodo_ipotetico_reale$p$, $p$reading$p$]),
('e38efdd5-4b32-5e18-8821-f6d7ef82f1ba'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Se avrò tempo, ti chiamerò stasera.", "Se ho tempo, ti chiamo stasera.", "Se avevo tempo, ti chiamavo stasera."], "say": "Se avrò tempo, ti chiamerò stasera.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/e38efdd5-4b32-5e18-8821-f6d7ef82f1ba.mp3"}$j$::jsonb,$j${"value": "Se avrò tempo, ti chiamerò stasera."}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$periodo_ipotetico_reale$p$, $p$listening$p$]),
('515f1481-0be9-5ef8-86e5-cd02b16e6be5'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Se domani fa bel tempo, andremo al parco.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/515f1481-0be9-5ef8-86e5-cd02b16e6be5.mp3"}$j$::jsonb,$j${"expected": "Se domani fa bel tempo, andremo al parco."}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$periodo_ipotetico_reale$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('10825efc-80f6-5106-b7a1-10280406e443','c10bf006-6cca-53d3-9f56-183fe95d4295',1),
 ('10825efc-80f6-5106-b7a1-10280406e443','c76d9e92-2b7a-578b-b68d-c6b884be46b3',2),
 ('10825efc-80f6-5106-b7a1-10280406e443','7e361c27-c72b-5422-83b3-265e0ade9e0f',3),
 ('10825efc-80f6-5106-b7a1-10280406e443','12aad811-d367-53b1-b881-1a090467b4e7',4),
 ('10825efc-80f6-5106-b7a1-10280406e443','e021bf7c-12bc-5a66-89f9-6c82fd88acf9',5),
 ('10825efc-80f6-5106-b7a1-10280406e443','13b2c808-bb3c-5b09-aaa6-f374602a7e48',6),
 ('6ac9cae5-c306-5a53-97de-d56f96d420b0','94bbf429-1257-514d-9945-22cb299b450d',1),
 ('6ac9cae5-c306-5a53-97de-d56f96d420b0','1a14204e-64bc-50c9-a739-a316dbf75508',2),
 ('6ac9cae5-c306-5a53-97de-d56f96d420b0','12e37712-5f1a-5faa-bbb3-6026d93eefb9',3),
 ('6ac9cae5-c306-5a53-97de-d56f96d420b0','34112d2d-f565-5b3f-96b9-d2ab14966c0f',4),
 ('80bee971-d711-5320-89f4-ecf725c21388','7701fe4a-0fa4-56cd-8ea1-ea59c57a4d75',1),
 ('80bee971-d711-5320-89f4-ecf725c21388','6aeb8825-72e4-536b-85ea-bfb42cfcb26a',2),
 ('80bee971-d711-5320-89f4-ecf725c21388','16f1a83b-986c-553a-9f67-b83d2acb5b35',3),
 ('80bee971-d711-5320-89f4-ecf725c21388','9eefa1b6-246e-58a9-9fcc-5404558f160a',4),
 ('80bee971-d711-5320-89f4-ecf725c21388','d0d88fa8-9298-5ba9-ab1e-a87530023444',5),
 ('80bee971-d711-5320-89f4-ecf725c21388','90bfa961-4043-5664-8a00-b2babb311abd',6),
 ('db01be68-1b59-5a67-932b-154907305365','8d395c3e-5eb9-5721-a643-5f422716e2c6',1),
 ('db01be68-1b59-5a67-932b-154907305365','e38efdd5-4b32-5e18-8821-f6d7ef82f1ba',2),
 ('db01be68-1b59-5a67-932b-154907305365','515f1481-0be9-5ef8-86e5-cd02b16e6be5',3),
 ('9c995cd4-3b27-54a1-83bb-2ad04ed71d80','c10bf006-6cca-53d3-9f56-183fe95d4295',1),
 ('9c995cd4-3b27-54a1-83bb-2ad04ed71d80','c76d9e92-2b7a-578b-b68d-c6b884be46b3',2),
 ('9c995cd4-3b27-54a1-83bb-2ad04ed71d80','94bbf429-1257-514d-9945-22cb299b450d',3),
 ('9c995cd4-3b27-54a1-83bb-2ad04ed71d80','7e361c27-c72b-5422-83b3-265e0ade9e0f',4),
 ('9c995cd4-3b27-54a1-83bb-2ad04ed71d80','12aad811-d367-53b1-b881-1a090467b4e7',5),
 ('9c995cd4-3b27-54a1-83bb-2ad04ed71d80','1a14204e-64bc-50c9-a739-a316dbf75508',6),
 ('9c995cd4-3b27-54a1-83bb-2ad04ed71d80','e021bf7c-12bc-5a66-89f9-6c82fd88acf9',7),
 ('9c995cd4-3b27-54a1-83bb-2ad04ed71d80','34112d2d-f565-5b3f-96b9-d2ab14966c0f',8),
 ('9c995cd4-3b27-54a1-83bb-2ad04ed71d80','13b2c808-bb3c-5b09-aaa6-f374602a7e48',9),
 ('9c995cd4-3b27-54a1-83bb-2ad04ed71d80','90bfa961-4043-5664-8a00-b2babb311abd',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('d328e4be-c258-5f81-8aef-0db16cbe726d','20000000-0000-0000-0000-000000000004',$p$il futuro$p$,$p$el futuro$p$,381,'sustantivo'),
 ('0334c6d0-7d4d-5fac-ac03-706b43d2f465','20000000-0000-0000-0000-000000000004',$p$il progetto$p$,$p$el proyecto$p$,382,'sustantivo'),
 ('31f8393a-d2b2-5685-9110-b8e2c05f63a0','20000000-0000-0000-0000-000000000004',$p$il sogno$p$,$p$el sueño$p$,383,'sustantivo'),
 ('5d7238cd-191c-5eab-911d-a88b5461dae0','20000000-0000-0000-0000-000000000004',$p$la speranza$p$,$p$la esperanza$p$,384,'sustantivo'),
 ('588cfbda-d8da-5cb9-b873-3dc140c7fb43','20000000-0000-0000-0000-000000000004',$p$il consiglio$p$,$p$el consejo$p$,385,'sustantivo'),
 ('31863bf0-8b4e-5ab1-95ff-a96c9d9054f3','20000000-0000-0000-0000-000000000004',$p$la possibilità$p$,$p$la posibilidad$p$,386,'sustantivo'),
 ('eb9b37b8-1137-5fbe-9cc1-255f954ff9cc','20000000-0000-0000-0000-000000000004',$p$il tempo$p$,$p$el tiempo$p$,387,'sustantivo'),
 ('f2eb245e-c053-5590-bd75-de7e7af2b85e','20000000-0000-0000-0000-000000000004',$p$il viaggio$p$,$p$el viaje$p$,388,'sustantivo'),
 ('a43765ff-1e3b-588c-89b4-455877d690ee','20000000-0000-0000-0000-000000000004',$p$forse$p$,$p$quizás$p$,389,'adverbio'),
 ('8453befa-e514-57a7-b07f-081b421351ec','20000000-0000-0000-0000-000000000004',$p$presto$p$,$p$pronto$p$,390,'adverbio'),
 ('a4f7a325-4cc4-5321-9c4c-0c90027d5e96','20000000-0000-0000-0000-000000000004',$p$domani$p$,$p$mañana$p$,391,'adverbio'),
 ('7cfa093b-b888-538e-a5cb-a5aa4ef8f25d','20000000-0000-0000-0000-000000000004',$p$se$p$,$p$si$p$,392,'conjuncion'),
 ('fa9313bc-c24b-50bf-b1e2-0a2b7b81a1ed','20000000-0000-0000-0000-000000000004',$p$parlerò$p$,$p$hablaré$p$,393,'verbo'),
 ('cb5961a2-e965-599d-ac58-a75ac91d6d86','20000000-0000-0000-0000-000000000004',$p$vorrei$p$,$p$querría/quisiera$p$,394,'verbo'),
 ('4b40710c-d66f-51ad-993a-04bd6c79063a','20000000-0000-0000-0000-000000000004',$p$dovrei$p$,$p$debería$p$,395,'verbo'),
 ('688797bf-cbec-50e2-b482-f5eb3f8e619e','20000000-0000-0000-0000-000000000004',$p$mi piacerebbe$p$,$p$me gustaría$p$,396,'verbo')
on conflict (id) do nothing;

-- ── Unidad 15 (B1·it): Pronombres relativos (che, cui, il quale, chi, dove) ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('3149fb2a-0fca-577c-b1d1-bf4bcf1871c1','20000000-0000-0000-0000-000000000004','B1',15,$p$Pronombres relativos (che, cui, il quale, chi, dove)$p$,'#117864','link')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('7d441e17-c2e1-537b-9148-3d5f85425ed6','3149fb2a-0fca-577c-b1d1-bf4bcf1871c1',1,$p$che: sujeto y objeto directo$p$,$p$che: sujeto y objeto directo$p$,'lesson',15),
 ('27482328-ec37-5f75-8d18-157252ee829e','3149fb2a-0fca-577c-b1d1-bf4bcf1871c1',2,$p$cui: con preposiciones (a, di, in, con, per)$p$,$p$cui: con preposiciones (a, di, in, con, per)$p$,'lesson',15),
 ('fbcc4e91-39e9-5d33-8d2f-13d37861433c','3149fb2a-0fca-577c-b1d1-bf4bcf1871c1',3,$p$il quale y il cui: alternativa formal y posesivo$p$,$p$il quale y il cui: alternativa formal y posesivo$p$,'lesson',15),
 ('1ab2c10e-6d80-5c24-9a7d-5da28e63367e','3149fb2a-0fca-577c-b1d1-bf4bcf1871c1',4,$p$chi y dove: todo junto$p$,$p$chi y dove: todo junto$p$,'lesson',15),
 ('aebc9297-d230-54dc-a726-23d3ea3084e9','3149fb2a-0fca-577c-b1d1-bf4bcf1871c1',5,$p$🏁 Checkpoint Unità 15$p$,$p$Une frases con che, cui, il/la quale, chi y dove. Elige el relativo según su función: che (sujeto/objeto directo, invariable), cui (tras preposición: a cui, di cui, in cui, con cui), il quale (alternativa formal), il cui (posesivo) y chi/dove.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('18b2c7e5-c6ad-52d1-b04e-68e8265f1b4b','20000000-0000-0000-0000-000000000004','checkpoint','B1','3149fb2a-0fca-577c-b1d1-bf4bcf1871c1',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('a5e90a68-647b-519e-a153-5a24adbb0eaa'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','reading','match',$p$Une cada frase en italiano con su traducción.$p$,$j${"pairs": [{"en": "il libro che leggo", "es": "el libro que leo"}, {"en": "la donna che parla", "es": "la mujer que habla"}, {"en": "l'amico che arriva", "es": "el amigo que llega"}]}$j$::jsonb,$j${"pairs": [["il libro che leggo", "el libro que leo"], ["la donna che parla", "la mujer que habla"], ["l'amico che arriva", "el amigo que llega"]]}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$che_match$p$, $p$reading$p$]),
('852a51cb-82ce-5bec-bc39-32a870ea96d3'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','reading','multiple_choice',$p$Completa: «È il collega ___ lavora con me» (el colega es el sujeto del verbo). Elige el relativo correcto.$p$,$j${"options": ["che", "cui", "dove"]}$j$::jsonb,$j${"value": "che"}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$che_soggetto$p$, $p$reading$p$]),
('242b9f4d-9a03-5797-8456-e77ccf0fd407'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','writing','cloze',$p$Escribe el relativo (sujeto del verbo abita): «Ho un'amica ___ abita a Roma.» Usa el relativo invariable de sujeto/objeto.$p$,$j${"text": "Ho un'amica ___ abita a Roma."}$j$::jsonb,$j${"value": "che", "accepted": ["che"]}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$che_soggetto_cloze$p$, $p$writing$p$]),
('92cb0c23-1e40-5893-a244-505342141805'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','reading','multiple_choice',$p$Completa: «È la città in ___ vivo» (tras la preposición «in»). Elige el relativo correcto.$p$,$j${"options": ["cui", "che", "dove"]}$j$::jsonb,$j${"value": "cui"}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$cui_in_luogo$p$, $p$reading$p$]),
('5db1cc37-e814-52a2-84b1-b1d4ddb57713'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','reading','multiple_choice',$p$Completa: «L'amico a ___ scrivo è simpatico» (tras la preposición «a»). Elige el relativo correcto.$p$,$j${"options": ["cui", "che", "quale"]}$j$::jsonb,$j${"value": "cui"}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$cui_a_scrivere$p$, $p$reading$p$]),
('9c03c674-3527-5b71-89af-74ef46340c0a'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','writing','cloze',$p$Escribe el relativo que va tras la preposición «per»: «Non capisco il motivo per ___ è partito.» (recuerda: tras preposición NO se usa «che»).$p$,$j${"text": "Non capisco il motivo per ___ è partito."}$j$::jsonb,$j${"value": "cui", "accepted": ["cui"]}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$cui_per_motivo_cloze$p$, $p$writing$p$]),
('c90c7fbf-ea14-513d-9a4a-9bbeef62bde4'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','writing','translation',$p$Traduce: «Es el libro del que hablo.» (parlare DI → di cui)$p$,$j${"source": "Es el libro del que hablo."}$j$::jsonb,$j${"value": "È il libro di cui parlo.", "accepted": ["È il libro di cui parlo", "È il libro di cui parlo.", "e il libro di cui parlo", "e il libro di cui parlo."]}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$cui_parlare_di$p$, $p$writing$p$]),
('1ce8478c-a83d-56cc-85be-ea827490d35b'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','reading','multiple_choice',$p$Completa la forma FORMAL: «La ragazza della ___ parlo è francese» (alternativa formal a «di cui», concuerda en género/número). Elige la opción correcta.$p$,$j${"options": ["quale", "cui", "dove"]}$j$::jsonb,$j${"value": "quale"}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$il_quale_formale$p$, $p$reading$p$]),
('f6864e84-2e47-54ec-ad69-76ab16cca338'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','writing','cloze',$p$Escribe el relativo posesivo (= «cuyos», delante del sustantivo poseído): «Lo scrittore i ___ libri amo è italiano.»$p$,$j${"text": "Lo scrittore i ___ libri amo è italiano."}$j$::jsonb,$j${"value": "cui", "accepted": ["cui"]}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$il_cui_possessivo_cloze$p$, $p$writing$p$]),
('33c4820c-286f-52ba-868a-cdc773f49261'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','writing','translation',$p$Traduce: «Es el escritor cuyos libros leo.» (posesivo: i cui libri)$p$,$j${"source": "Es el escritor cuyos libros leo."}$j$::jsonb,$j${"value": "È lo scrittore i cui libri leggo.", "accepted": ["È lo scrittore i cui libri leggo", "È lo scrittore i cui libri leggo.", "e lo scrittore i cui libri leggo", "e lo scrittore i cui libri leggo."]}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$il_cui_translation$p$, $p$writing$p$]),
('ee705ef3-4478-5b2b-af5c-c971d7c5822b'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','reading','multiple_choice',$p$Completa el proverbio (= «colui che», quien, referido a personas indefinidas): «___ dorme non piglia pesci.» Elige la opción correcta.$p$,$j${"options": ["Chi", "Quale", "Dove"]}$j$::jsonb,$j${"value": "Chi"}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$chi_proverbio$p$, $p$reading$p$]),
('dbdcdb93-349b-5190-8e5f-a703cf796e1d'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','writing','cloze',$p$Escribe el relativo de LUGAR (= «en la que», forma simple): «È la casa ___ abito da bambino.» Usa el adverbio relativo de lugar.$p$,$j${"text": "È la casa ___ abito da bambino."}$j$::jsonb,$j${"value": "dove", "accepted": ["dove"]}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$dove_luogo_cloze$p$, $p$writing$p$]),
('11060531-3f0c-5ae8-be7d-1368bbe330ec'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["La persona che parla è mia madre.", "La persona cui parla è mia madre.", "La persona dove parla è mia madre."], "say": "La persona che parla è mia madre.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/11060531-3f0c-5ae8-be7d-1368bbe330ec.mp3"}$j$::jsonb,$j${"value": "La persona che parla è mia madre."}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$che_listening$p$, $p$listening$p$]),
('f8cc9bfe-d5cf-5676-89a3-e646c51b132f'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["È il paese in cui sono nato.", "È il paese in quale sono nato.", "È il paese in dove sono nato."], "say": "È il paese in cui sono nato.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/f8cc9bfe-d5cf-5676-89a3-e646c51b132f.mp3"}$j$::jsonb,$j${"value": "È il paese in cui sono nato."}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$cui_listening$p$, $p$listening$p$]),
('1e628993-e494-5d35-84a2-f307f8ac11ca'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ecco il ristorante dove ceniamo spesso.", "Ecco il ristorante cui ceniamo spesso.", "Ecco il ristorante quale ceniamo spesso."], "say": "Ecco il ristorante dove ceniamo spesso.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/1e628993-e494-5d35-84a2-f307f8ac11ca.mp3"}$j$::jsonb,$j${"value": "Ecco il ristorante dove ceniamo spesso."}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$dove_listening$p$, $p$listening$p$]),
('454cfc93-593b-5463-8de2-ee523ffc4f3b'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["È un amico di cui mi fido molto.", "È un amico di che mi fido molto.", "È un amico di dove mi fido molto."], "say": "È un amico di cui mi fido molto.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/454cfc93-593b-5463-8de2-ee523ffc4f3b.mp3"}$j$::jsonb,$j${"value": "È un amico di cui mi fido molto."}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$cui_listening_di$p$, $p$listening$p$]),
('022a9181-44c2-5d32-9380-4f2021b3a6dc'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Il ragazzo che vive qui è il mio vicino.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/022a9181-44c2-5d32-9380-4f2021b3a6dc.mp3"}$j$::jsonb,$j${"expected": "Il ragazzo che vive qui è il mio vicino."}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$che_speaking$p$, $p$speaking$p$]),
('c1b72b67-467d-55f9-9c0a-f4a40b3fb0d5'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "È la ragione per cui sono venuto oggi.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/c1b72b67-467d-55f9-9c0a-f4a40b3fb0d5.mp3"}$j$::jsonb,$j${"expected": "È la ragione per cui sono venuto oggi."}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$cui_speaking$p$, $p$speaking$p$]),
('4df6a229-f417-570d-9671-ff55a3b2768b'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Chi cerca un amico sincero trova un tesoro.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/4df6a229-f417-570d-9671-ff55a3b2768b.mp3"}$j$::jsonb,$j${"expected": "Chi cerca un amico sincero trova un tesoro."}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$chi_speaking$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('7d441e17-c2e1-537b-9148-3d5f85425ed6','a5e90a68-647b-519e-a153-5a24adbb0eaa',1),
 ('7d441e17-c2e1-537b-9148-3d5f85425ed6','852a51cb-82ce-5bec-bc39-32a870ea96d3',2),
 ('7d441e17-c2e1-537b-9148-3d5f85425ed6','242b9f4d-9a03-5797-8456-e77ccf0fd407',3),
 ('27482328-ec37-5f75-8d18-157252ee829e','92cb0c23-1e40-5893-a244-505342141805',1),
 ('27482328-ec37-5f75-8d18-157252ee829e','5db1cc37-e814-52a2-84b1-b1d4ddb57713',2),
 ('27482328-ec37-5f75-8d18-157252ee829e','9c03c674-3527-5b71-89af-74ef46340c0a',3),
 ('27482328-ec37-5f75-8d18-157252ee829e','c90c7fbf-ea14-513d-9a4a-9bbeef62bde4',4),
 ('fbcc4e91-39e9-5d33-8d2f-13d37861433c','1ce8478c-a83d-56cc-85be-ea827490d35b',1),
 ('fbcc4e91-39e9-5d33-8d2f-13d37861433c','f6864e84-2e47-54ec-ad69-76ab16cca338',2),
 ('fbcc4e91-39e9-5d33-8d2f-13d37861433c','33c4820c-286f-52ba-868a-cdc773f49261',3),
 ('1ab2c10e-6d80-5c24-9a7d-5da28e63367e','ee705ef3-4478-5b2b-af5c-c971d7c5822b',1),
 ('1ab2c10e-6d80-5c24-9a7d-5da28e63367e','dbdcdb93-349b-5190-8e5f-a703cf796e1d',2),
 ('1ab2c10e-6d80-5c24-9a7d-5da28e63367e','11060531-3f0c-5ae8-be7d-1368bbe330ec',3),
 ('1ab2c10e-6d80-5c24-9a7d-5da28e63367e','f8cc9bfe-d5cf-5676-89a3-e646c51b132f',4),
 ('1ab2c10e-6d80-5c24-9a7d-5da28e63367e','1e628993-e494-5d35-84a2-f307f8ac11ca',5),
 ('1ab2c10e-6d80-5c24-9a7d-5da28e63367e','454cfc93-593b-5463-8de2-ee523ffc4f3b',6),
 ('1ab2c10e-6d80-5c24-9a7d-5da28e63367e','022a9181-44c2-5d32-9380-4f2021b3a6dc',7),
 ('1ab2c10e-6d80-5c24-9a7d-5da28e63367e','c1b72b67-467d-55f9-9c0a-f4a40b3fb0d5',8),
 ('1ab2c10e-6d80-5c24-9a7d-5da28e63367e','4df6a229-f417-570d-9671-ff55a3b2768b',9),
 ('aebc9297-d230-54dc-a726-23d3ea3084e9','a5e90a68-647b-519e-a153-5a24adbb0eaa',1),
 ('aebc9297-d230-54dc-a726-23d3ea3084e9','852a51cb-82ce-5bec-bc39-32a870ea96d3',2),
 ('aebc9297-d230-54dc-a726-23d3ea3084e9','92cb0c23-1e40-5893-a244-505342141805',3),
 ('aebc9297-d230-54dc-a726-23d3ea3084e9','242b9f4d-9a03-5797-8456-e77ccf0fd407',4),
 ('aebc9297-d230-54dc-a726-23d3ea3084e9','9c03c674-3527-5b71-89af-74ef46340c0a',5),
 ('aebc9297-d230-54dc-a726-23d3ea3084e9','c90c7fbf-ea14-513d-9a4a-9bbeef62bde4',6),
 ('aebc9297-d230-54dc-a726-23d3ea3084e9','11060531-3f0c-5ae8-be7d-1368bbe330ec',7),
 ('aebc9297-d230-54dc-a726-23d3ea3084e9','f8cc9bfe-d5cf-5676-89a3-e646c51b132f',8),
 ('aebc9297-d230-54dc-a726-23d3ea3084e9','022a9181-44c2-5d32-9380-4f2021b3a6dc',9),
 ('aebc9297-d230-54dc-a726-23d3ea3084e9','c1b72b67-467d-55f9-9c0a-f4a40b3fb0d5',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('c92fcf73-e82c-59c7-a695-af4f7e692a62','20000000-0000-0000-0000-000000000004',$p$il libro$p$,$p$el libro$p$,401,'n'),
 ('3bce8572-f798-5df3-9e5a-8a4e62d45cac','20000000-0000-0000-0000-000000000004',$p$la persona$p$,$p$la persona$p$,402,'n'),
 ('0c6f1319-5b90-5eac-b698-afe3039647b4','20000000-0000-0000-0000-000000000004',$p$l'amico$p$,$p$el amigo$p$,403,'n'),
 ('d0dace94-77ae-5c61-a89f-d2323f3cd45a','20000000-0000-0000-0000-000000000004',$p$la città$p$,$p$la ciudad$p$,404,'n'),
 ('b73e1aa3-f6f8-58f5-8802-b49e41fcf978','20000000-0000-0000-0000-000000000004',$p$il motivo$p$,$p$el motivo$p$,405,'n'),
 ('aa5c52d1-e317-5678-b241-7d65b72dcd39','20000000-0000-0000-0000-000000000004',$p$lo scrittore$p$,$p$el escritor$p$,406,'n'),
 ('731c1f61-ed5d-58d7-8e6b-6cf9ded473b0','20000000-0000-0000-0000-000000000004',$p$la ragazza$p$,$p$la chica$p$,407,'n'),
 ('0a1f18df-ce57-5f15-b6cf-0f2167233c8c','20000000-0000-0000-0000-000000000004',$p$il collega$p$,$p$el colega$p$,408,'n'),
 ('03d0de00-db72-506b-96f6-09bdd02c101d','20000000-0000-0000-0000-000000000004',$p$la casa$p$,$p$la casa$p$,409,'n'),
 ('8c0453f9-bbc0-5785-a574-ceff64f1109a','20000000-0000-0000-0000-000000000004',$p$il paese$p$,$p$el pueblo$p$,410,'n'),
 ('c005bb1e-34ba-5a1d-908d-c8f51ffa6dd7','20000000-0000-0000-0000-000000000004',$p$la ragione$p$,$p$la razón$p$,411,'n'),
 ('0ae9f676-d219-5c1c-b4ff-e18de61e15e7','20000000-0000-0000-0000-000000000004',$p$il quadro$p$,$p$el cuadro$p$,412,'n'),
 ('81a5994c-57fa-50d7-918f-f91089f53d96','20000000-0000-0000-0000-000000000004',$p$parlare di$p$,$p$hablar de$p$,413,'v'),
 ('bc522d39-9343-5fab-97bb-22e3def27601','20000000-0000-0000-0000-000000000004',$p$pensare a$p$,$p$pensar en$p$,414,'v'),
 ('f87ff1db-91c4-54d2-b6e9-8959a308d392','20000000-0000-0000-0000-000000000004',$p$contare su$p$,$p$contar con$p$,415,'v'),
 ('448ce960-c67e-563c-9ff1-f206ad134c70','20000000-0000-0000-0000-000000000004',$p$fidarsi di$p$,$p$fiarse de$p$,416,'v')
on conflict (id) do nothing;

-- ── Unidad 16 (B1·it): Concordancia del participio pasado ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('7eaa2c29-7bdd-578d-83dd-add377bbafdc','20000000-0000-0000-0000-000000000004','B1',16,$p$Concordancia del participio pasado$p$,'#8E44AD','spellcheck')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('cc228acf-4abe-508c-99b0-b43677164841','7eaa2c29-7bdd-578d-83dd-add377bbafdc',1,$p$Essere: el participio concuerda con el sujeto$p$,$p$Essere: el participio concuerda con el sujeto$p$,'lesson',15),
 ('5841baf9-311f-5311-ae37-451e580c2b1a','7eaa2c29-7bdd-578d-83dd-add377bbafdc',2,$p$Verbos pronominales (mi sono svegliato/a)$p$,$p$Verbos pronominales (mi sono svegliato/a)$p$,'lesson',15),
 ('5995e092-fcd5-5ded-aff8-4dbf16606881','7eaa2c29-7bdd-578d-83dd-add377bbafdc',3,$p$Avere + lo/la/li/le antepuesto$p$,$p$Avere + lo/la/li/le antepuesto$p$,'lesson',15),
 ('ebcf2978-fe44-5e4f-82ed-61fde2f4031b','7eaa2c29-7bdd-578d-83dd-add377bbafdc',4,$p$Elegir el auxiliar: essere o avere$p$,$p$Elegir el auxiliar: essere o avere$p$,'lesson',15),
 ('0c546d34-b892-5c83-b4c2-b202a8e2c13c','7eaa2c29-7bdd-578d-83dd-add377bbafdc',5,$p$🏁 Checkpoint Unità 16$p$,$p$Concuerda el participio pasado con el sujeto (essere) y con el pronombre objeto directo antepuesto lo/la/li/le (avere), y elige el auxiliar correcto.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('2596c9e3-5327-5732-a89e-136ac4743e5f','20000000-0000-0000-0000-000000000004','checkpoint','B1','7eaa2c29-7bdd-578d-83dd-add377bbafdc',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('9216f4fe-d6cf-5a93-9914-4764e6d326ee'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','reading','match',$p$Relaciona cada forma italiana con su significado en español.$p$,$j${"pairs": [{"en": "Maria è andata", "es": "María ha ido"}, {"en": "i ragazzi sono partiti", "es": "los chicos han salido"}, {"en": "le ragazze sono uscite", "es": "las chicas han salido"}]}$j$::jsonb,$j${"pairs": [["Maria è andata", "María ha ido"], ["i ragazzi sono partiti", "los chicos han salido"], ["le ragazze sono uscite", "las chicas han salido"]]}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$essere_concordanza_soggetto$p$, $p$reading$p$]),
('2f26c480-2a2e-548a-844d-5bff3dec7b0c'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','reading','multiple_choice',$p$El sujeto es «le mie amiche» (femenino plural). ¿Cuál concuerda bien?$p$,$j${"options": ["Le mie amiche sono arrivate tardi.", "Le mie amiche hanno arrivato tardi.", "Le mie amiche è arrivata tardi."]}$j$::jsonb,$j${"value": "Le mie amiche sono arrivate tardi."}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$essere_concordanza_soggetto$p$, $p$reading$p$]),
('205a4a3e-693d-52a6-9c4d-287c89c443f0'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','reading','multiple_choice',$p$¿En cuál el participio concuerda correctamente con el sujeto masculino plural «i turisti»?$p$,$j${"options": ["I turisti sono partiti presto.", "I turisti hanno partito presto.", "I turisti è partita presto."]}$j$::jsonb,$j${"value": "I turisti sono partiti presto."}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$essere_concordanza_soggetto$p$, $p$reading$p$]),
('87b08528-6129-558f-a1b5-b33477283cef'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','writing','cloze',$p$Completa el participio de «tornare» que concuerda con «Giulia» (fem. singular).$p$,$j${"text": "Giulia è ___ a casa presto."}$j$::jsonb,$j${"value": "tornata", "accepted": ["tornata"]}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$essere_concordanza_soggetto$p$, $p$writing$p$]),
('13cac9f6-f43b-5282-b9b5-2723959e11e7'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','writing','word_bank',$p$Ordena las fichas para formar: «Los niños han nacido en Roma.»$p$,$j${"tiles": ["I", "bambini", "sono", "nati", "a", "Roma", "nate", "hanno"]}$j$::jsonb,$j${"value": "I bambini sono nati a Roma", "sequence": ["I", "bambini", "sono", "nati", "a", "Roma"]}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$essere_concordanza_soggetto$p$, $p$writing$p$]),
('898a22d5-005d-5cae-886e-a76b684b095e'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','writing','cloze',$p$Sujeto «noi» (nosotros, masc.). Completa el participio de «alzarsi».$p$,$j${"text": "Ci siamo ___ presto stamattina."}$j$::jsonb,$j${"value": "alzati", "accepted": ["alzati"]}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$verbi_pronominali$p$, $p$writing$p$]),
('f55ad48e-7731-5914-90b3-67b577156a39'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','writing','translation',$p$Traduce al italiano (habla un hombre): «Me he vestido rápidamente.»$p$,$j${"source": "Me he vestido rápidamente."}$j$::jsonb,$j${"value": "Mi sono vestito velocemente.", "accepted": ["Mi sono vestito velocemente.", "mi sono vestito velocemente", "Mi sono vestito velocemente"]}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$verbi_pronominali$p$, $p$writing$p$]),
('d44485f0-c226-5ce6-95ee-c92b3b8f8911'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','reading','multiple_choice',$p$Se habla de «la macchina» (aparece como «l'»). ¿Cuál concuerda bien con avere?$p$,$j${"options": ["L'ho vista ieri.", "L'ho comprato ieri.", "Li ho viste ieri."]}$j$::jsonb,$j${"value": "L'ho vista ieri."}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$avere_pronome_diretto$p$, $p$reading$p$]),
('5c727930-8650-5baf-bf47-0a246de176b8'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','reading','multiple_choice',$p$Se habla de «i libri». ¿Con qué pronombre antepuesto y participio concuerda?$p$,$j${"options": ["Li ho comprati online.", "Le ho comprato online.", "Li ho conosciuti online."]}$j$::jsonb,$j${"value": "Li ho comprati online."}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$avere_pronome_diretto$p$, $p$reading$p$]),
('0834c8db-2112-5f43-adef-5db8753340d3'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','writing','cloze',$p$El objeto es «le tue sorelle» (fem. plural). Completa el participio de «conoscere».$p$,$j${"text": "Le ho ___ alla festa."}$j$::jsonb,$j${"value": "conosciute", "accepted": ["conosciute"]}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$avere_pronome_diretto$p$, $p$writing$p$]),
('8f04f2ff-35f3-5fda-81d9-ab78495999f1'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','reading','multiple_choice',$p$«Ayer ___ una buena idea.» ¿Qué auxiliar corresponde con «avere»?$p$,$j${"options": ["Ieri ho avuto una buona idea.", "Ieri sono stato una buona idea.", "Ieri ho andato una buona idea."]}$j$::jsonb,$j${"value": "Ieri ho avuto una buona idea."}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$scelta_ausiliare$p$, $p$reading$p$]),
('e4abc2dc-0589-5cd6-8acc-afa03b8f321d'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','writing','cloze',$p$Elige el auxiliar correcto para «stare» (fem. singular): «Ella ___ stata gentile.»$p$,$j${"text": "Lei ___ stata molto gentile."}$j$::jsonb,$j${"value": "è", "accepted": ["è", "e'"]}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$scelta_ausiliare$p$, $p$writing$p$]),
('330f17dd-9a1b-50ec-8322-00e67cb3f45d'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Le ragazze sono uscite insieme.", "I ragazzi hanno finito insieme.", "Le donne sono tornate insieme."], "say": "Le ragazze sono uscite insieme.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/330f17dd-9a1b-50ec-8322-00e67cb3f45d.mp3"}$j$::jsonb,$j${"value": "Le ragazze sono uscite insieme."}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$essere_concordanza_soggetto$p$, $p$listening$p$]),
('3c4004d3-c183-502d-8866-6263712a18eb'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Mi sono svegliata alle sette.", "Ci siamo alzati alle sette.", "Si è vestita alle sette."], "say": "Mi sono svegliata alle sette.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/3c4004d3-c183-502d-8866-6263712a18eb.mp3"}$j$::jsonb,$j${"value": "Mi sono svegliata alle sette."}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$verbi_pronominali$p$, $p$listening$p$]),
('40ab7bbd-aaeb-573e-98c9-8fb195dc3bff'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','listening','listening',$p$Escucha la frase con pronombre antepuesto y elige la que oíste.$p$,$j${"options": ["Li ho comprati questa mattina.", "Le ho conosciute questa mattina.", "Li ho venduti questa mattina."], "say": "Li ho comprati questa mattina.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/40ab7bbd-aaeb-573e-98c9-8fb195dc3bff.mp3"}$j$::jsonb,$j${"value": "Li ho comprati questa mattina."}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$avere_pronome_diretto$p$, $p$listening$p$]),
('673f7559-deac-5321-b0c1-696464a2b584'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ieri ho avuto molto lavoro.", "Ieri sono andato al lavoro.", "Oggi ho finito il lavoro."], "say": "Ieri ho avuto molto lavoro.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/673f7559-deac-5321-b0c1-696464a2b584.mp3"}$j$::jsonb,$j${"value": "Ieri ho avuto molto lavoro."}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$scelta_ausiliare$p$, $p$listening$p$]),
('69841d67-b91a-5217-a52e-976efc99ded9'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Le mie amiche sono arrivate insieme alla stazione.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/69841d67-b91a-5217-a52e-976efc99ded9.mp3"}$j$::jsonb,$j${"expected": "Le mie amiche sono arrivate insieme alla stazione."}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$essere_concordanza_soggetto$p$, $p$speaking$p$]),
('eb1d859c-ddf7-5719-b920-4ca03bfeb170'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Ho visto le foto e le ho trovate bellissime.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/eb1d859c-ddf7-5719-b920-4ca03bfeb170.mp3"}$j$::jsonb,$j${"expected": "Ho visto le foto e le ho trovate bellissime."}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$avere_pronome_diretto$p$, $p$speaking$p$]),
('0fb1f7fb-0c48-525e-a42d-e2b688b8592d'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "È stata una giornata lunga, ma ho avuto molta fortuna.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/0fb1f7fb-0c48-525e-a42d-e2b688b8592d.mp3"}$j$::jsonb,$j${"expected": "È stata una giornata lunga, ma ho avuto molta fortuna."}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$scelta_ausiliare$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('cc228acf-4abe-508c-99b0-b43677164841','9216f4fe-d6cf-5a93-9914-4764e6d326ee',1),
 ('cc228acf-4abe-508c-99b0-b43677164841','2f26c480-2a2e-548a-844d-5bff3dec7b0c',2),
 ('cc228acf-4abe-508c-99b0-b43677164841','205a4a3e-693d-52a6-9c4d-287c89c443f0',3),
 ('cc228acf-4abe-508c-99b0-b43677164841','87b08528-6129-558f-a1b5-b33477283cef',4),
 ('cc228acf-4abe-508c-99b0-b43677164841','13cac9f6-f43b-5282-b9b5-2723959e11e7',5),
 ('cc228acf-4abe-508c-99b0-b43677164841','330f17dd-9a1b-50ec-8322-00e67cb3f45d',6),
 ('cc228acf-4abe-508c-99b0-b43677164841','69841d67-b91a-5217-a52e-976efc99ded9',7),
 ('5841baf9-311f-5311-ae37-451e580c2b1a','898a22d5-005d-5cae-886e-a76b684b095e',1),
 ('5841baf9-311f-5311-ae37-451e580c2b1a','f55ad48e-7731-5914-90b3-67b577156a39',2),
 ('5841baf9-311f-5311-ae37-451e580c2b1a','3c4004d3-c183-502d-8866-6263712a18eb',3),
 ('5995e092-fcd5-5ded-aff8-4dbf16606881','d44485f0-c226-5ce6-95ee-c92b3b8f8911',1),
 ('5995e092-fcd5-5ded-aff8-4dbf16606881','5c727930-8650-5baf-bf47-0a246de176b8',2),
 ('5995e092-fcd5-5ded-aff8-4dbf16606881','0834c8db-2112-5f43-adef-5db8753340d3',3),
 ('5995e092-fcd5-5ded-aff8-4dbf16606881','40ab7bbd-aaeb-573e-98c9-8fb195dc3bff',4),
 ('5995e092-fcd5-5ded-aff8-4dbf16606881','eb1d859c-ddf7-5719-b920-4ca03bfeb170',5),
 ('ebcf2978-fe44-5e4f-82ed-61fde2f4031b','8f04f2ff-35f3-5fda-81d9-ab78495999f1',1),
 ('ebcf2978-fe44-5e4f-82ed-61fde2f4031b','e4abc2dc-0589-5cd6-8acc-afa03b8f321d',2),
 ('ebcf2978-fe44-5e4f-82ed-61fde2f4031b','673f7559-deac-5321-b0c1-696464a2b584',3),
 ('ebcf2978-fe44-5e4f-82ed-61fde2f4031b','0fb1f7fb-0c48-525e-a42d-e2b688b8592d',4),
 ('0c546d34-b892-5c83-b4c2-b202a8e2c13c','9216f4fe-d6cf-5a93-9914-4764e6d326ee',1),
 ('0c546d34-b892-5c83-b4c2-b202a8e2c13c','2f26c480-2a2e-548a-844d-5bff3dec7b0c',2),
 ('0c546d34-b892-5c83-b4c2-b202a8e2c13c','205a4a3e-693d-52a6-9c4d-287c89c443f0',3),
 ('0c546d34-b892-5c83-b4c2-b202a8e2c13c','87b08528-6129-558f-a1b5-b33477283cef',4),
 ('0c546d34-b892-5c83-b4c2-b202a8e2c13c','13cac9f6-f43b-5282-b9b5-2723959e11e7',5),
 ('0c546d34-b892-5c83-b4c2-b202a8e2c13c','898a22d5-005d-5cae-886e-a76b684b095e',6),
 ('0c546d34-b892-5c83-b4c2-b202a8e2c13c','330f17dd-9a1b-50ec-8322-00e67cb3f45d',7),
 ('0c546d34-b892-5c83-b4c2-b202a8e2c13c','3c4004d3-c183-502d-8866-6263712a18eb',8),
 ('0c546d34-b892-5c83-b4c2-b202a8e2c13c','69841d67-b91a-5217-a52e-976efc99ded9',9),
 ('0c546d34-b892-5c83-b4c2-b202a8e2c13c','eb1d859c-ddf7-5719-b920-4ca03bfeb170',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('def1d9e8-778b-58bf-b68e-5a2ba764e542','20000000-0000-0000-0000-000000000004',$p$andare$p$,$p$ir$p$,421,'verbo'),
 ('3a4cc3b0-16c8-500a-9310-1160e50619eb','20000000-0000-0000-0000-000000000004',$p$partire$p$,$p$salir/partir$p$,422,'verbo'),
 ('8e990575-c3d3-5052-9fc4-1efd05c40bbd','20000000-0000-0000-0000-000000000004',$p$uscire$p$,$p$salir$p$,423,'verbo'),
 ('326e778e-44d0-500f-8815-85fa8c3de439','20000000-0000-0000-0000-000000000004',$p$arrivare$p$,$p$llegar$p$,424,'verbo'),
 ('b02edd28-79a9-564f-b8b7-8b457a4f8a3b','20000000-0000-0000-0000-000000000004',$p$tornare$p$,$p$volver$p$,425,'verbo'),
 ('5a13d497-1da3-53df-87d3-0dd5f4f0d18a','20000000-0000-0000-0000-000000000004',$p$nascere$p$,$p$nacer$p$,426,'verbo'),
 ('f960ac0e-4158-5111-a7da-3a9c63db4edf','20000000-0000-0000-0000-000000000004',$p$svegliarsi$p$,$p$despertarse$p$,427,'verbo pronominal'),
 ('96b605fc-7d23-51c4-995b-326a4ae0d4e1','20000000-0000-0000-0000-000000000004',$p$alzarsi$p$,$p$levantarse$p$,428,'verbo pronominal'),
 ('07f6345b-34b7-50dc-8c63-ca9adf847a54','20000000-0000-0000-0000-000000000004',$p$vestirsi$p$,$p$vestirse$p$,429,'verbo pronominal'),
 ('a4a1a00f-ecec-5209-aff7-1e1c94156ab9','20000000-0000-0000-0000-000000000004',$p$comprare$p$,$p$comprar$p$,430,'verbo'),
 ('cfe6ccd5-08db-5c7b-bf6d-643eb7a20823','20000000-0000-0000-0000-000000000004',$p$vedere$p$,$p$ver$p$,431,'verbo'),
 ('748389c7-adcb-5021-9648-1ae11f0068d4','20000000-0000-0000-0000-000000000004',$p$conoscere$p$,$p$conocer$p$,432,'verbo'),
 ('34e6196c-357a-5e60-bc14-41eea5126cad','20000000-0000-0000-0000-000000000004',$p$il participio$p$,$p$el participio$p$,433,'sustantivo'),
 ('fb35512e-64a5-535e-b30e-f93742e38b78','20000000-0000-0000-0000-000000000004',$p$l'ausiliare$p$,$p$el auxiliar$p$,434,'sustantivo'),
 ('576615ee-6555-569d-be64-43cf126fddaf','20000000-0000-0000-0000-000000000004',$p$il soggetto$p$,$p$el sujeto$p$,435,'sustantivo'),
 ('c3d6b07a-8b73-5b15-8547-e9074755af17','20000000-0000-0000-0000-000000000004',$p$insieme$p$,$p$juntos$p$,436,'adverbio')
on conflict (id) do nothing;

-- ── Unidad 17 (B1·it): El discurso indirecto ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('1dfb712e-57a3-55f8-8d96-82c4718baa1a','20000000-0000-0000-0000-000000000004','B1',17,$p$El discurso indirecto$p$,'#6C3483','record_voice_over')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('fc40ebb7-ae97-5513-933a-432ae0cbc83c','1dfb712e-57a3-55f8-8d96-82c4718baa1a',1,$p$Dice che... (verbo principal en presente)$p$,$p$Dice che... (verbo principal en presente)$p$,'lesson',15),
 ('393673c9-6695-548b-a1ed-95daf2b467bb','1dfb712e-57a3-55f8-8d96-82c4718baa1a',2,$p$Ha detto che... (concordancia de tiempos)$p$,$p$Ha detto che... (concordancia de tiempos)$p$,'lesson',15),
 ('77474617-27b3-54fa-8be8-40a75dcc5abd','1dfb712e-57a3-55f8-8d96-82c4718baa1a',3,$p$Preguntas indirectas: chiede se / dove / quando$p$,$p$Preguntas indirectas: chiede se / dove / quando$p$,'lesson',15),
 ('a184daf7-3090-53ed-9e9b-d72561b130f8','1dfb712e-57a3-55f8-8d96-82c4718baa1a',4,$p$Órdenes indirectas y deícticos$p$,$p$Órdenes indirectas y deícticos$p$,'lesson',15),
 ('fd3c8495-30f7-5b60-9506-6fb509d9aab3','1dfb712e-57a3-55f8-8d96-82c4718baa1a',5,$p$🏁 Checkpoint Unità 17$p$,$p$Demuestra que sabes referir lo que otros dicen, preguntan y ordenan con el discurso indirecto (dice che, ha detto che + concordanza, chiede se, dire di + infinito).$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('bc6ebc25-4669-55b9-908e-00e5f6fa9c9d','20000000-0000-0000-0000-000000000004','checkpoint','B1','1dfb712e-57a3-55f8-8d96-82c4718baa1a',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('ee5bffe2-e49b-53fd-ab34-fb06c610bcad'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','reading','match',$p$Une cada frase directa con su versión en discurso indirecto (verbo principal en presente).$p$,$j${"pairs": [{"en": "«Sono stanco» → Dice che è stanco", "es": "Dice que está cansado"}, {"en": "«Ho fame» → Dice che ha fame", "es": "Dice que tiene hambre"}, {"en": "«Arrivo subito» → Dice che arriva subito", "es": "Dice que llega enseguida"}]}$j$::jsonb,$j${"pairs": [["«Sono stanco» → Dice che è stanco", "Dice que está cansado"], ["«Ho fame» → Dice che ha fame", "Dice que tiene hambre"], ["«Arrivo subito» → Dice che arriva subito", "Dice que llega enseguida"]]}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$dice_che_presente$p$, $p$reading$p$]),
('1e285116-ecbf-55fe-99ba-0f86c4eb0d3a'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','reading','multiple_choice',$p$«Marco: Ho sonno.» Pásalo a discurso indirecto: Marco dice che ___.$p$,$j${"options": ["ha sonno", "ho sonno", "avere sonno"]}$j$::jsonb,$j${"value": "ha sonno"}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$dice_che_presente$p$, $p$reading$p$]),
('9e85e40c-7950-5aec-8835-fbfa0545c950'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','writing','cloze',$p$Completa con el verbo en 3ª persona: «Lucia: Sono felice.» → Lucia dice che ___ felice.$p$,$j${"text": "Lucia dice che ___ felice."}$j$::jsonb,$j${"value": "è", "accepted": ["è"]}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$dice_che_presente$p$, $p$writing$p$]),
('6d99166b-9005-5d52-b0a3-66c71b573b80'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','writing','translation',$p$Traduce al italiano: Anna dice que tiene razón.$p$,$j${"source": "Anna dice que tiene razón."}$j$::jsonb,$j${"value": "Anna dice che ha ragione.", "accepted": ["Anna dice che ha ragione", "Anna dice che ha ragione.", "anna dice che ha ragione"]}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$dice_che_presente$p$, $p$writing$p$]),
('80353c67-bd92-5c18-8796-d0d60740d8a2'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Dice che non può venire stasera.", "Dice che non vuole venire stasera.", "Dice che non deve venire stasera."], "say": "Dice che non può venire stasera.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/80353c67-bd92-5c18-8796-d0d60740d8a2.mp3"}$j$::jsonb,$j${"value": "Dice che non può venire stasera."}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$dice_che_presente$p$, $p$listening$p$]),
('48a7cf3e-1830-522f-b5b0-abc97f64c4e2'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Paolo dice che è contento e che arriva subito.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/48a7cf3e-1830-522f-b5b0-abc97f64c4e2.mp3"}$j$::jsonb,$j${"expected": "Paolo dice che è contento e che arriva subito."}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$dice_che_presente$p$, $p$speaking$p$]),
('28091002-eb0b-5022-82a2-1156cefa5410'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','reading','match',$p$Une la frase directa pasada con su discurso indirecto (concordancia de tiempos).$p$,$j${"pairs": [{"en": "«Sono stanco» → Ha detto che era stanco", "es": "presente → imperfetto"}, {"en": "«Ho finito» → Ha detto che aveva finito", "es": "passato prossimo → trapassato"}, {"en": "«Verrò» → Ha detto che sarebbe venuto", "es": "futuro → condizionale composto"}]}$j$::jsonb,$j${"pairs": [["«Sono stanco» → Ha detto che era stanco", "presente → imperfetto"], ["«Ho finito» → Ha detto che aveva finito", "passato prossimo → trapassato"], ["«Verrò» → Ha detto che sarebbe venuto", "futuro → condizionale composto"]]}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$ha_detto_concordanza$p$, $p$reading$p$]),
('e166fbf2-4e10-56a0-aad7-961dc895164c'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','reading','multiple_choice',$p$«Giulia: Sono a casa.» En pasado: Giulia ha detto che ___ a casa.$p$,$j${"options": ["era", "è", "sarà"]}$j$::jsonb,$j${"value": "era"}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$ha_detto_concordanza$p$, $p$reading$p$]),
('b08522fb-a99e-5e46-947b-6807bd5657eb'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','writing','translation',$p$Traduce al italiano (passato prossimo → trapassato): Dijo que había terminado el trabajo.$p$,$j${"source": "Dijo que había terminado el trabajo."}$j$::jsonb,$j${"value": "Ha detto che aveva finito il lavoro.", "accepted": ["Ha detto che aveva finito il lavoro", "Ha detto che aveva finito il lavoro.", "ha detto che aveva finito il lavoro"]}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$ha_detto_concordanza$p$, $p$writing$p$]),
('ee33a40f-376a-5c0e-95b1-2b1a3eaadabe'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ha detto che era molto stanco quel giorno.", "Ha detto che sarà molto stanco quel giorno.", "Ha detto che è molto stanco quel giorno."], "say": "Ha detto che era molto stanco quel giorno.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/ee33a40f-376a-5c0e-95b1-2b1a3eaadabe.mp3"}$j$::jsonb,$j${"value": "Ha detto che era molto stanco quel giorno."}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$ha_detto_concordanza$p$, $p$listening$p$]),
('6d39da25-5be5-5788-abea-c1af6f6ef68a'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','reading','multiple_choice',$p$Pásalo a pregunta indirecta: «Hai tempo?» → Mi chiede ___ ho tempo.$p$,$j${"options": ["se", "che", "come"]}$j$::jsonb,$j${"value": "se"}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$domande_indirette$p$, $p$reading$p$]),
('ec0e0931-7c82-56e2-a9a0-276dad0b3b60'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','writing','cloze',$p$Completa la pregunta indirecta: «Dove abiti?» → Mi ha chiesto ___ abitavo.$p$,$j${"text": "Mi ha chiesto ___ abitavo."}$j$::jsonb,$j${"value": "dove", "accepted": ["dove"]}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$domande_indirette$p$, $p$writing$p$]),
('ec3f08ef-cb7e-5227-b7a0-371196f3609c'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','writing','word_bank',$p$Forma la frase: «Me pregunta si estoy libre esta noche.»$p$,$j${"tiles": ["Mi", "chiede", "se", "sono", "libero", "stasera", "che", "quando"]}$j$::jsonb,$j${"value": "Mi chiede se sono libero stasera", "sequence": ["Mi", "chiede", "se", "sono", "libero", "stasera"]}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$domande_indirette$p$, $p$writing$p$]),
('9e0b8a6c-fcf0-55a7-b80d-9797fe9d61f9'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Mi ha chiesto quando sarei tornato.", "Mi ha chiesto perché sarei tornato.", "Mi ha chiesto dove sarei tornato."], "say": "Mi ha chiesto quando sarei tornato.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/9e0b8a6c-fcf0-55a7-b80d-9797fe9d61f9.mp3"}$j$::jsonb,$j${"value": "Mi ha chiesto quando sarei tornato."}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$domande_indirette$p$, $p$listening$p$]),
('e9d46888-5a3b-50ba-a515-d6a98de6f622'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Mi ha chiesto se avevo tempo e dove volevo andare.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/e9d46888-5a3b-50ba-a515-d6a98de6f622.mp3"}$j$::jsonb,$j${"expected": "Mi ha chiesto se avevo tempo e dove volevo andare."}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$domande_indirette$p$, $p$speaking$p$]),
('688c5a1f-5e69-59d1-9fd5-7034559ce944'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','reading','multiple_choice',$p$Pásalo a orden indirecta: «Aspetta!» → Mi dice ___ aspettare.$p$,$j${"options": ["di", "che", "se"]}$j$::jsonb,$j${"value": "di"}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$ordini_indiretti_deittici$p$, $p$reading$p$]),
('eda2afc3-f5e2-5217-a565-f1a4652c7017'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','writing','cloze',$p$Completa la orden indirecta negativa (di + infinito): «Non partire!» → Mi ha detto ___ non partire.$p$,$j${"text": "Mi ha detto ___ non partire."}$j$::jsonb,$j${"value": "di", "accepted": ["di"]}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$ordini_indiretti_deittici$p$, $p$writing$p$]),
('9378044a-1c42-53d1-a500-f8e7f6f8bd5f'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Mi ha detto di chiamare più tardi.", "Mi ha detto di tornare più tardi.", "Mi ha detto di studiare più tardi."], "say": "Mi ha detto di chiamare più tardi.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/9378044a-1c42-53d1-a500-f8e7f6f8bd5f.mp3"}$j$::jsonb,$j${"value": "Mi ha detto di chiamare più tardi."}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$ordini_indiretti_deittici$p$, $p$listening$p$]),
('fb0139d7-5d1a-5e8d-af89-49a2f8982ae9'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Mi ha detto di aspettare lì e di tornare il giorno dopo.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/fb0139d7-5d1a-5e8d-af89-49a2f8982ae9.mp3"}$j$::jsonb,$j${"expected": "Mi ha detto di aspettare lì e di tornare il giorno dopo."}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$ordini_indiretti_deittici$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('fc40ebb7-ae97-5513-933a-432ae0cbc83c','ee5bffe2-e49b-53fd-ab34-fb06c610bcad',1),
 ('fc40ebb7-ae97-5513-933a-432ae0cbc83c','1e285116-ecbf-55fe-99ba-0f86c4eb0d3a',2),
 ('fc40ebb7-ae97-5513-933a-432ae0cbc83c','9e85e40c-7950-5aec-8835-fbfa0545c950',3),
 ('fc40ebb7-ae97-5513-933a-432ae0cbc83c','6d99166b-9005-5d52-b0a3-66c71b573b80',4),
 ('fc40ebb7-ae97-5513-933a-432ae0cbc83c','80353c67-bd92-5c18-8796-d0d60740d8a2',5),
 ('fc40ebb7-ae97-5513-933a-432ae0cbc83c','48a7cf3e-1830-522f-b5b0-abc97f64c4e2',6),
 ('393673c9-6695-548b-a1ed-95daf2b467bb','28091002-eb0b-5022-82a2-1156cefa5410',1),
 ('393673c9-6695-548b-a1ed-95daf2b467bb','e166fbf2-4e10-56a0-aad7-961dc895164c',2),
 ('393673c9-6695-548b-a1ed-95daf2b467bb','b08522fb-a99e-5e46-947b-6807bd5657eb',3),
 ('393673c9-6695-548b-a1ed-95daf2b467bb','ee33a40f-376a-5c0e-95b1-2b1a3eaadabe',4),
 ('77474617-27b3-54fa-8be8-40a75dcc5abd','6d39da25-5be5-5788-abea-c1af6f6ef68a',1),
 ('77474617-27b3-54fa-8be8-40a75dcc5abd','ec0e0931-7c82-56e2-a9a0-276dad0b3b60',2),
 ('77474617-27b3-54fa-8be8-40a75dcc5abd','ec3f08ef-cb7e-5227-b7a0-371196f3609c',3),
 ('77474617-27b3-54fa-8be8-40a75dcc5abd','9e0b8a6c-fcf0-55a7-b80d-9797fe9d61f9',4),
 ('77474617-27b3-54fa-8be8-40a75dcc5abd','e9d46888-5a3b-50ba-a515-d6a98de6f622',5),
 ('a184daf7-3090-53ed-9e9b-d72561b130f8','688c5a1f-5e69-59d1-9fd5-7034559ce944',1),
 ('a184daf7-3090-53ed-9e9b-d72561b130f8','eda2afc3-f5e2-5217-a565-f1a4652c7017',2),
 ('a184daf7-3090-53ed-9e9b-d72561b130f8','9378044a-1c42-53d1-a500-f8e7f6f8bd5f',3),
 ('a184daf7-3090-53ed-9e9b-d72561b130f8','fb0139d7-5d1a-5e8d-af89-49a2f8982ae9',4),
 ('fd3c8495-30f7-5b60-9506-6fb509d9aab3','ee5bffe2-e49b-53fd-ab34-fb06c610bcad',1),
 ('fd3c8495-30f7-5b60-9506-6fb509d9aab3','1e285116-ecbf-55fe-99ba-0f86c4eb0d3a',2),
 ('fd3c8495-30f7-5b60-9506-6fb509d9aab3','28091002-eb0b-5022-82a2-1156cefa5410',3),
 ('fd3c8495-30f7-5b60-9506-6fb509d9aab3','9e85e40c-7950-5aec-8835-fbfa0545c950',4),
 ('fd3c8495-30f7-5b60-9506-6fb509d9aab3','6d99166b-9005-5d52-b0a3-66c71b573b80',5),
 ('fd3c8495-30f7-5b60-9506-6fb509d9aab3','b08522fb-a99e-5e46-947b-6807bd5657eb',6),
 ('fd3c8495-30f7-5b60-9506-6fb509d9aab3','80353c67-bd92-5c18-8796-d0d60740d8a2',7),
 ('fd3c8495-30f7-5b60-9506-6fb509d9aab3','ee33a40f-376a-5c0e-95b1-2b1a3eaadabe',8),
 ('fd3c8495-30f7-5b60-9506-6fb509d9aab3','48a7cf3e-1830-522f-b5b0-abc97f64c4e2',9),
 ('fd3c8495-30f7-5b60-9506-6fb509d9aab3','e9d46888-5a3b-50ba-a515-d6a98de6f622',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('4a1d7098-0e98-5050-9b42-7fc82f00c763','20000000-0000-0000-0000-000000000004',$p$dire$p$,$p$decir$p$,441,'verbo'),
 ('a5007a2f-328d-51d5-8e3a-f1ffa52fb7ec','20000000-0000-0000-0000-000000000004',$p$chiedere$p$,$p$preguntar / pedir$p$,442,'verbo'),
 ('0ddeaeab-8933-5e9c-877a-35197b596f4e','20000000-0000-0000-0000-000000000004',$p$rispondere$p$,$p$responder$p$,443,'verbo'),
 ('1a8e57ea-4718-5e01-a9ed-241e49da71f1','20000000-0000-0000-0000-000000000004',$p$raccontare$p$,$p$contar$p$,444,'verbo'),
 ('b3c18401-83ff-593a-8368-c4ede955ad58','20000000-0000-0000-0000-000000000004',$p$spiegare$p$,$p$explicar$p$,445,'verbo'),
 ('4c6e1b86-8134-5e96-85d3-d3a5fb0af178','20000000-0000-0000-0000-000000000004',$p$il discorso indiretto$p$,$p$el discurso indirecto$p$,446,'gramática'),
 ('b9139d2f-04d9-5fbf-be0a-82bd8e5de0bb','20000000-0000-0000-0000-000000000004',$p$se$p$,$p$si (interrogativo)$p$,447,'conjunción'),
 ('253cb495-e09d-51ae-ad0e-2623eb3a8b62','20000000-0000-0000-0000-000000000004',$p$che$p$,$p$que$p$,448,'conjunción'),
 ('f8b95e9b-ce6d-5135-be58-d193f1bd4068','20000000-0000-0000-0000-000000000004',$p$dove$p$,$p$dónde$p$,449,'interrogativo'),
 ('df2c615e-fd6d-5ea5-8cb5-ad0321f52d8b','20000000-0000-0000-0000-000000000004',$p$quando$p$,$p$cuándo$p$,450,'interrogativo'),
 ('3690d21f-40f5-5671-bafb-dbcd141167e2','20000000-0000-0000-0000-000000000004',$p$perché$p$,$p$por qué / porque$p$,451,'interrogativo'),
 ('43a9bde3-69db-5d74-8e73-7c10e81e5719','20000000-0000-0000-0000-000000000004',$p$quel giorno$p$,$p$aquel día$p$,452,'expresión'),
 ('41bcc098-f771-5852-a2f1-8055d55a3112','20000000-0000-0000-0000-000000000004',$p$il giorno prima$p$,$p$el día anterior$p$,453,'expresión'),
 ('9281209d-16d2-5123-b3a0-5f282fba2f62','20000000-0000-0000-0000-000000000004',$p$stanco$p$,$p$cansado$p$,454,'adjetivo'),
 ('ea3a8ba5-9b85-5160-a280-46c817454413','20000000-0000-0000-0000-000000000004',$p$subito$p$,$p$enseguida$p$,455,'adverbio'),
 ('bb962005-7894-5d50-b2c7-58f17670934e','20000000-0000-0000-0000-000000000004',$p$più tardi$p$,$p$más tarde$p$,456,'expresión')
on conflict (id) do nothing;

-- ── Unidad 18 (B1·it): Pronombres combinados, ci y ne ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('2e744270-3a55-574d-9a65-2dd42cf25722','20000000-0000-0000-0000-000000000004','B1',18,$p$Pronombres combinados, ci y ne$p$,'#117A65','sync_alt')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('86ff4027-882a-5192-a312-90bea6c9382e','2e744270-3a55-574d-9a65-2dd42cf25722',1,$p$El pronombre ci (Ci vado, Ci penso, Ci vuole)$p$,$p$El pronombre ci (Ci vado, Ci penso, Ci vuole)$p$,'lesson',15),
 ('a2b6c45a-349f-5fc6-81ad-ec75341ea2a8','2e744270-3a55-574d-9a65-2dd42cf25722',2,$p$El pronombre ne (Ne voglio due, Ne ho parlato)$p$,$p$El pronombre ne (Ne voglio due, Ne ho parlato)$p$,'lesson',15),
 ('6d3ed32e-f27e-5090-ad5f-84df1172efa7','2e744270-3a55-574d-9a65-2dd42cf25722',3,$p$Pronombres combinados (me lo, te lo, ce lo)$p$,$p$Pronombres combinados (me lo, te lo, ce lo)$p$,'lesson',15),
 ('1c3762b2-941c-5452-a4fe-6ab373fbbe83','2e744270-3a55-574d-9a65-2dd42cf25722',4,$p$Glielo, gliene y ce n'è$p$,$p$Glielo, gliene y ce n'è$p$,'lesson',15),
 ('502b6f4e-6be1-54cb-837c-04a02c48c4bb','2e744270-3a55-574d-9a65-2dd42cf25722',5,$p$🏁 Checkpoint Unità 18$p$,$p$Usa ci (locativo e idiomático) y ne (partitivo), y combina pronombres indirecto+directo (me lo, te lo, ce lo, glielo, gliene) incluyendo ce n'è / ce ne sono y la posición con infinitivo e imperativo.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('eda8e350-9f47-5c97-ab47-da375535c9c0','20000000-0000-0000-0000-000000000004','checkpoint','B1','2e744270-3a55-574d-9a65-2dd42cf25722',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('eb29d8e2-ea96-5457-8a48-aab897c1bcf9'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','reading','match',$p$Une la frase italiana con su traducción.$p$,$j${"pairs": [{"en": "Vai a Roma? Sì, ci vado domani.", "es": "¿Vas a Roma? Sí, voy allí mañana."}, {"en": "Pensi al lavoro? Ci penso sempre.", "es": "¿Piensas en el trabajo? Pienso en ello siempre."}, {"en": "Non ci credo affatto.", "es": "No me lo creo en absoluto."}]}$j$::jsonb,$j${"pairs": [["Vai a Roma? Sì, ci vado domani.", "¿Vas a Roma? Sí, voy allí mañana."], ["Pensi al lavoro? Ci penso sempre.", "¿Piensas en el trabajo? Pienso en ello siempre."], ["Non ci credo affatto.", "No me lo creo en absoluto."]]}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$ci_locativo$p$, $p$reading$p$]),
('2a3421a0-f152-552b-9fa2-868ac1eaa5cf'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','reading','multiple_choice',$p$Elige la respuesta correcta a « Vai al mare quest'estate? ».$p$,$j${"options": ["Sì, ci vado ad agosto.", "Sì, lo vado ad agosto.", "Sì, ne vado ad agosto."]}$j$::jsonb,$j${"value": "Sì, ci vado ad agosto."}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$ci_locativo$p$, $p$reading$p$]),
('49c3d777-34fc-5629-8ed5-90ce9d751113'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','writing','cloze',$p$Completa con el pronombre correcto (« pensar en ello »).$p$,$j${"text": "Non preoccuparti per la cena: ___ penso io."}$j$::jsonb,$j${"value": "ci", "accepted": ["ci"]}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$ci_pensare$p$, $p$writing$p$]),
('56d66b9d-e335-570a-86c5-3e20fc3cdb07'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Per imparare bene ci vuole tempo.", "Per imparare bene ne vuole tempo.", "Per imparare bene serve molto tempo."], "say": "Per imparare bene ci vuole tempo.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/56d66b9d-e335-570a-86c5-3e20fc3cdb07.mp3"}$j$::jsonb,$j${"value": "Per imparare bene ci vuole tempo."}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$ci_volere$p$, $p$listening$p$]),
('90e274d2-5f95-5e01-a13e-15ef17fd2213'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Ci vado spesso, ma stavolta non ci credo davvero.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/90e274d2-5f95-5e01-a13e-15ef17fd2213.mp3"}$j$::jsonb,$j${"expected": "Ci vado spesso, ma stavolta non ci credo davvero."}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$ci_idiomatico$p$, $p$speaking$p$]),
('1ee7ce1f-8703-5cf0-88e5-3eec253f00da'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','reading','multiple_choice',$p$Elige la respuesta correcta a « Quante mele vuoi? ».$p$,$j${"options": ["Ne voglio due.", "Le voglio due.", "Ci voglio due."]}$j$::jsonb,$j${"value": "Ne voglio due."}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$ne_partitivo$p$, $p$reading$p$]),
('a1daad1c-9568-50eb-92e9-8fcca804373c'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','writing','cloze',$p$Completa con el pronombre partitivo (« de eso »).$p$,$j${"text": "Hai dei fratelli? Sì, ___ ho tre."}$j$::jsonb,$j${"value": "ne", "accepted": ["ne"]}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$ne_quantita$p$, $p$writing$p$]),
('fbeccbe4-c500-5282-8ea2-d08f673c66a5'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Ne ho parlato con il capo, ma lui non ne sa nulla.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/fbeccbe4-c500-5282-8ea2-d08f673c66a5.mp3"}$j$::jsonb,$j${"expected": "Ne ho parlato con il capo, ma lui non ne sa nulla."}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$ne_di_cio$p$, $p$speaking$p$]),
('76fd6507-f1f0-5a65-9259-217d43a38183'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Quanti libri hai letto? Ne ho letti cinque.", "Quanti libri hai letto? Li ho comprati tutti.", "Quanti libri hai letto? Ne ho parlato ieri."], "say": "Quanti libri hai letto? Ne ho letti cinque.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/76fd6507-f1f0-5a65-9259-217d43a38183.mp3"}$j$::jsonb,$j${"value": "Quanti libri hai letto? Ne ho letti cinque."}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$ne_partitivo$p$, $p$listening$p$]),
('53e95384-8e2a-5263-8738-1d38b35589e9'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','writing','translation',$p$Traduce: ¿Qué opinas de mi idea?$p$,$j${"source": "¿Qué opinas de mi idea?"}$j$::jsonb,$j${"value": "Cosa ne pensi della mia idea?", "accepted": ["Cosa ne pensi della mia idea", "Cosa ne pensi della mia idea?", "Che ne pensi della mia idea?", "Che ne pensi della mia idea"]}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$ne_opinione$p$, $p$writing$p$]),
('481698c6-8b68-5eca-9aea-f4dc144b750b'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','reading','multiple_choice',$p$Elige la respuesta correcta a « Mi presti il libro? » (te lo presto = yo te lo presto).$p$,$j${"options": ["Sì, te lo presto volentieri.", "Sì, ti lo presto volentieri.", "Sì, te li presto volentieri."]}$j$::jsonb,$j${"value": "Sì, te lo presto volentieri."}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$combinati_te_lo$p$, $p$reading$p$]),
('33895a1a-c72a-5817-aba8-9246697f059c'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','writing','cloze',$p$Completa combinando « ti » + « lo » (te lo).$p$,$j${"text": "Non ti preoccupare, ___ lo dico domani."}$j$::jsonb,$j${"value": "te", "accepted": ["te"]}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$combinati_te_lo$p$, $p$writing$p$]),
('beb993f0-4172-5d72-961b-01057faa0b04'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','writing','word_bank',$p$Construye la frase: El camarero nos lo trae subito.$p$,$j${"tiles": ["Il", "cameriere", "ce", "lo", "porta", "subito", "ci", "ne"]}$j$::jsonb,$j${"value": "Il cameriere ce lo porta subito", "sequence": ["Il", "cameriere", "ce", "lo", "porta", "subito"]}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$combinati_ce_lo$p$, $p$writing$p$]),
('d8b46171-3800-5035-9193-359a9a4f984f'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Se hai bisogno, me lo puoi chiedere.", "Se vuoi, glielo posso spiegare.", "Se preferisci, te ne posso parlare."], "say": "Se hai bisogno, me lo puoi chiedere.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/d8b46171-3800-5035-9193-359a9a4f984f.mp3"}$j$::jsonb,$j${"value": "Se hai bisogno, me lo puoi chiedere."}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$combinati_me_lo$p$, $p$listening$p$]),
('7119d4fb-6e45-53ba-accb-56d8eaa2feed'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Se me lo chiedi con gentilezza, te lo spiego subito.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/7119d4fb-6e45-53ba-accb-56d8eaa2feed.mp3"}$j$::jsonb,$j${"expected": "Se me lo chiedi con gentilezza, te lo spiego subito."}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$combinati_speak$p$, $p$speaking$p$]),
('d3b88077-c18c-548e-9462-43bee412f1be'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','reading','match',$p$Une la frase italiana con su traducción.$p$,$j${"pairs": [{"en": "Do il regalo a Marco. Glielo do.", "es": "Le doy el regalo a Marco. Se lo doy."}, {"en": "Parlo del progetto a Lucia. Gliene parlo.", "es": "Le hablo del proyecto a Lucía. Le hablo de ello."}, {"en": "Compro i fiori a mia madre. Glieli compro.", "es": "Le compro las flores a mi madre. Se las compro."}]}$j$::jsonb,$j${"pairs": [["Do il regalo a Marco. Glielo do.", "Le doy el regalo a Marco. Se lo doy."], ["Parlo del progetto a Lucia. Gliene parlo.", "Le hablo del proyecto a Lucía. Le hablo de ello."], ["Compro i fiori a mia madre. Glieli compro.", "Le compro las flores a mi madre. Se las compro."]]}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$combinati_glielo$p$, $p$reading$p$]),
('fa13172c-934c-5f94-bea2-ee7ce4ab2c25'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','reading','multiple_choice',$p$Elige la forma correcta para « Le doy el libro (a él) ».$p$,$j${"options": ["Glielo do subito.", "Gli lo do subito.", "Lo gli do subito."]}$j$::jsonb,$j${"value": "Glielo do subito."}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$combinati_glielo$p$, $p$reading$p$]),
('bc70bdec-34eb-5299-89d8-e8b244839ebc'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','writing','reorder',$p$Ordena las palabras para formar la frase.$p$,$j${"tiles": ["Puoi", "darmelo", "per", "favore"]}$j$::jsonb,$j${"value": "Puoi darmelo per favore"}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$combinati_imperativo$p$, $p$writing$p$]),
('98cceb71-117f-58c9-9918-f2d0f5a657ba'::uuid,'20000000-0000-0000-0000-000000000004'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ci sono ancora dei biglietti? Sì, ce ne sono due.", "Ci sono ancora dei biglietti? Sì, ce ne resta due.", "Ci sono ancora dei biglietti? Sì, ce li sono due."], "say": "Ci sono ancora dei biglietti? Sì, ce ne sono due.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/98cceb71-117f-58c9-9918-f2d0f5a657ba.mp3"}$j$::jsonb,$j${"value": "Ci sono ancora dei biglietti? Sì, ce ne sono due."}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$ce_ne_sono$p$, $p$listening$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('86ff4027-882a-5192-a312-90bea6c9382e','eb29d8e2-ea96-5457-8a48-aab897c1bcf9',1),
 ('86ff4027-882a-5192-a312-90bea6c9382e','2a3421a0-f152-552b-9fa2-868ac1eaa5cf',2),
 ('86ff4027-882a-5192-a312-90bea6c9382e','49c3d777-34fc-5629-8ed5-90ce9d751113',3),
 ('86ff4027-882a-5192-a312-90bea6c9382e','56d66b9d-e335-570a-86c5-3e20fc3cdb07',4),
 ('86ff4027-882a-5192-a312-90bea6c9382e','90e274d2-5f95-5e01-a13e-15ef17fd2213',5),
 ('a2b6c45a-349f-5fc6-81ad-ec75341ea2a8','1ee7ce1f-8703-5cf0-88e5-3eec253f00da',1),
 ('a2b6c45a-349f-5fc6-81ad-ec75341ea2a8','a1daad1c-9568-50eb-92e9-8fcca804373c',2),
 ('a2b6c45a-349f-5fc6-81ad-ec75341ea2a8','fbeccbe4-c500-5282-8ea2-d08f673c66a5',3),
 ('a2b6c45a-349f-5fc6-81ad-ec75341ea2a8','76fd6507-f1f0-5a65-9259-217d43a38183',4),
 ('a2b6c45a-349f-5fc6-81ad-ec75341ea2a8','53e95384-8e2a-5263-8738-1d38b35589e9',5),
 ('6d3ed32e-f27e-5090-ad5f-84df1172efa7','481698c6-8b68-5eca-9aea-f4dc144b750b',1),
 ('6d3ed32e-f27e-5090-ad5f-84df1172efa7','33895a1a-c72a-5817-aba8-9246697f059c',2),
 ('6d3ed32e-f27e-5090-ad5f-84df1172efa7','beb993f0-4172-5d72-961b-01057faa0b04',3),
 ('6d3ed32e-f27e-5090-ad5f-84df1172efa7','d8b46171-3800-5035-9193-359a9a4f984f',4),
 ('6d3ed32e-f27e-5090-ad5f-84df1172efa7','7119d4fb-6e45-53ba-accb-56d8eaa2feed',5),
 ('1c3762b2-941c-5452-a4fe-6ab373fbbe83','d3b88077-c18c-548e-9462-43bee412f1be',1),
 ('1c3762b2-941c-5452-a4fe-6ab373fbbe83','fa13172c-934c-5f94-bea2-ee7ce4ab2c25',2),
 ('1c3762b2-941c-5452-a4fe-6ab373fbbe83','bc70bdec-34eb-5299-89d8-e8b244839ebc',3),
 ('1c3762b2-941c-5452-a4fe-6ab373fbbe83','98cceb71-117f-58c9-9918-f2d0f5a657ba',4),
 ('502b6f4e-6be1-54cb-837c-04a02c48c4bb','eb29d8e2-ea96-5457-8a48-aab897c1bcf9',1),
 ('502b6f4e-6be1-54cb-837c-04a02c48c4bb','2a3421a0-f152-552b-9fa2-868ac1eaa5cf',2),
 ('502b6f4e-6be1-54cb-837c-04a02c48c4bb','1ee7ce1f-8703-5cf0-88e5-3eec253f00da',3),
 ('502b6f4e-6be1-54cb-837c-04a02c48c4bb','49c3d777-34fc-5629-8ed5-90ce9d751113',4),
 ('502b6f4e-6be1-54cb-837c-04a02c48c4bb','a1daad1c-9568-50eb-92e9-8fcca804373c',5),
 ('502b6f4e-6be1-54cb-837c-04a02c48c4bb','53e95384-8e2a-5263-8738-1d38b35589e9',6),
 ('502b6f4e-6be1-54cb-837c-04a02c48c4bb','56d66b9d-e335-570a-86c5-3e20fc3cdb07',7),
 ('502b6f4e-6be1-54cb-837c-04a02c48c4bb','76fd6507-f1f0-5a65-9259-217d43a38183',8),
 ('502b6f4e-6be1-54cb-837c-04a02c48c4bb','90e274d2-5f95-5e01-a13e-15ef17fd2213',9),
 ('502b6f4e-6be1-54cb-837c-04a02c48c4bb','fbeccbe4-c500-5282-8ea2-d08f673c66a5',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('cc85df31-216f-5346-87a7-cd1240c06a53','20000000-0000-0000-0000-000000000004',$p$ci$p$,$p$allí / en ello$p$,461,'pronombre'),
 ('fa411989-6e98-53ee-ab1f-f1356d6f6e92','20000000-0000-0000-0000-000000000004',$p$ne$p$,$p$de ello / de eso$p$,462,'pronombre'),
 ('ae992d6c-301c-5392-9ba7-311da72c14b5','20000000-0000-0000-0000-000000000004',$p$Ci vado$p$,$p$Voy allí$p$,463,'expresion'),
 ('0ade4aea-c269-57ff-9c8c-b6a17675b70d','20000000-0000-0000-0000-000000000004',$p$Ci penso io$p$,$p$Yo me encargo$p$,464,'expresion'),
 ('83b22a54-4606-5ef5-b824-a3a273bba3dc','20000000-0000-0000-0000-000000000004',$p$Non ci credo$p$,$p$No me lo creo$p$,465,'expresion'),
 ('7067bca7-1292-592a-a27c-3283ff15749b','20000000-0000-0000-0000-000000000004',$p$Ci vuole tempo$p$,$p$Hace falta tiempo$p$,466,'expresion'),
 ('965c5813-4ae0-598d-bb59-9addc9316753','20000000-0000-0000-0000-000000000004',$p$Ne voglio due$p$,$p$Quiero dos (de eso)$p$,467,'expresion'),
 ('1f59d8da-e235-54e1-a9f6-b79418ffd186','20000000-0000-0000-0000-000000000004',$p$Ne ho parlato$p$,$p$He hablado de ello$p$,468,'expresion'),
 ('7788d18a-515e-5307-93e5-d758f2dad212','20000000-0000-0000-0000-000000000004',$p$Cosa ne pensi?$p$,$p$¿Qué opinas de eso?$p$,469,'expresion'),
 ('d91f82d8-ed41-5c96-b6f7-f010dec01e94','20000000-0000-0000-0000-000000000004',$p$me lo dai$p$,$p$me lo das$p$,470,'expresion'),
 ('cd03208a-7950-5c7b-b322-bebdf6d458f6','20000000-0000-0000-0000-000000000004',$p$te lo dico$p$,$p$te lo digo$p$,471,'expresion'),
 ('21584aa1-7c32-5c0e-b5ff-e1b5413f31fa','20000000-0000-0000-0000-000000000004',$p$ce lo porta$p$,$p$nos lo trae$p$,472,'expresion'),
 ('fbe7e7be-c535-5b5e-b380-1e1ba533b02c','20000000-0000-0000-0000-000000000004',$p$glielo do$p$,$p$se lo doy$p$,473,'expresion'),
 ('58f1e602-fda0-5891-8b2f-dfb113288f3f','20000000-0000-0000-0000-000000000004',$p$gliene parlo$p$,$p$le hablo de ello$p$,474,'expresion'),
 ('b0c8bef2-de90-5d6e-96a1-81790e695fe6','20000000-0000-0000-0000-000000000004',$p$ce n'è$p$,$p$hay (de eso)$p$,475,'expresion'),
 ('985a7c77-1002-5ccc-bde7-784bab497d3a','20000000-0000-0000-0000-000000000004',$p$ce ne sono$p$,$p$hay (varios)$p$,476,'expresion')
on conflict (id) do nothing;

commit;