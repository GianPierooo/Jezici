-- 20260703120111_seed_de_b1.sql
-- Currículo B1 del curso es→de (6 unidades). Molde es→pt.
-- Contenido scopeado a course_id=20000000-0000-0000-0000-000000000005 → aislamiento multicurso por
-- jz_active_course. Unidades order_index continúan la cadena → gating al nivel previo.
begin;
insert into languages (id, code, name) values
  ('10000000-0000-0000-0000-000000000006','de',$p$Deutsch$p$) on conflict (id) do nothing;
insert into courses (id, source_language_id, target_language_id, is_active) values
  ('20000000-0000-0000-0000-000000000005','10000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000006',true) on conflict (id) do nothing;

-- ── Unidad 13 (B1·de): Deseos y cortesía (Konjunktiv II) ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('ad84bf93-6530-5d0c-8694-8255467661b4','20000000-0000-0000-0000-000000000005','B1',13,$p$Deseos y cortesía (Konjunktiv II)$p$,'#6C3483','auto_awesome')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('427e6a94-96e9-5b3c-a056-53078eba4fee','ad84bf93-6530-5d0c-8694-8255467661b4',1,$p$Peticiones corteses (Könnten Sie…?, würde)$p$,$p$Peticiones corteses (Könnten Sie…?, würde)$p$,'lesson',15),
 ('c4c4a3a4-610c-5aa1-9f99-738fc8d64ff5','ad84bf93-6530-5d0c-8694-8255467661b4',2,$p$Deseos (Ich hätte gern…, Ich wünschte…)$p$,$p$Deseos (Ich hätte gern…, Ich wünschte…)$p$,'lesson',15),
 ('08c9beb2-8941-5f78-9729-9a275e969226','ad84bf93-6530-5d0c-8694-8255467661b4',3,$p$Consejos (An deiner Stelle…, sollte)$p$,$p$Consejos (An deiner Stelle…, sollte)$p$,'lesson',15),
 ('5cb5d61a-9db0-5e07-a451-c4263d764bf8','ad84bf93-6530-5d0c-8694-8255467661b4',4,$p$Situaciones hipotéticas (wäre, könnte)$p$,$p$Situaciones hipotéticas (wäre, könnte)$p$,'lesson',15),
 ('4b8b6ac4-ea58-53c8-9884-dd857b549b0f','ad84bf93-6530-5d0c-8694-8255467661b4',5,$p$🏁 Checkpoint Einheit 13$p$,$p$Demuestra que sabes pedir con cortesía, expresar deseos y dar consejos usando el Konjunktiv II (würde, hätte, wäre, könnte, sollte).$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('78a1fc4f-7be1-5e8e-8b84-a12dfac26368','20000000-0000-0000-0000-000000000005','checkpoint','B1','ad84bf93-6530-5d0c-8694-8255467661b4',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('4444c8a5-8ce7-5c6d-a0de-06cdf36904b8'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','reading','match',$p$Une cada expresión alemana con su significado.$p$,$j${"pairs": [{"en": "Könnten Sie mir helfen?", "es": "¿Podría usted ayudarme?"}, {"en": "Würden Sie bitte warten?", "es": "¿Esperaría usted, por favor?"}, {"en": "Ich hätte eine Frage.", "es": "Tendría una pregunta."}]}$j$::jsonb,$j${"pairs": [["Könnten Sie mir helfen?", "¿Podría usted ayudarme?"], ["Würden Sie bitte warten?", "¿Esperaría usted, por favor?"], ["Ich hätte eine Frage.", "Tendría una pregunta."]]}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$polite_requests$p$, $p$reading$p$]),
('2c302df1-4c81-5b52-a355-e16262be2605'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','reading','multiple_choice',$p$Elige la forma más cortés para pedir algo a un desconocido.$p$,$j${"options": ["Könnten Sie mir bitte helfen?", "Hilf mir!", "Du musst mir helfen."]}$j$::jsonb,$j${"value": "Könnten Sie mir bitte helfen?"}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$polite_requests$p$, $p$reading$p$]),
('41c07fa7-d8ec-590b-a3fa-8162d5af9748'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','writing','cloze',$p$Completa con el condicional (auxiliar) para «esperaría».$p$,$j${"text": "___ Sie bitte einen Moment warten?"}$j$::jsonb,$j${"value": "Würden", "accepted": ["Würden", "würden", "Wuerden", "wuerden"]}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$wuerde_infinitiv$p$, $p$writing$p$]),
('46e8d706-e278-56b9-8595-91f8130e20d8'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Könnten Sie mir das erklären?", "Können Sie mir das erklären?", "Könnten Sie mir das schenken?"], "say": "Könnten Sie mir das erklären?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/46e8d706-e278-56b9-8595-91f8130e20d8.mp3"}$j$::jsonb,$j${"value": "Könnten Sie mir das erklären?"}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$polite_requests$p$, $p$listening$p$]),
('f6c211fd-a68a-536b-8e0e-1a7c6b6083b0'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Würden Sie mir bitte helfen?", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/f6c211fd-a68a-536b-8e0e-1a7c6b6083b0.mp3"}$j$::jsonb,$j${"expected": "Würden Sie mir bitte helfen?"}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$polite_requests$p$, $p$speaking$p$]),
('686a895c-044f-5728-8921-a6e4bf93102a'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','reading','multiple_choice',$p$Elige la manera cortés de pedir un café en un restaurante.$p$,$j${"options": ["Ich hätte gern einen Kaffee.", "Ich will einen Kaffee.", "Gib mir einen Kaffee."]}$j$::jsonb,$j${"value": "Ich hätte gern einen Kaffee."}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$wishes_haette_gern$p$, $p$reading$p$]),
('3cee4233-5e2e-5a02-9000-45a3806a0f09'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','writing','translation',$p$Traduce: Quisiera un vaso de agua.$p$,$j${"source": "Quisiera un vaso de agua."}$j$::jsonb,$j${"value": "Ich hätte gern ein Glas Wasser.", "accepted": ["Ich hätte gern ein Glas Wasser.", "Ich hätte gern ein Glas Wasser", "Ich haette gern ein Glas Wasser.", "Ich haette gern ein Glas Wasser"]}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$wishes_haette_gern$p$, $p$writing$p$]),
('0767f7dc-d3e7-52e7-830c-a5a9e38c14a0'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','writing','cloze',$p$Completa: «Ojalá tuviera más tiempo».$p$,$j${"text": "Ich wünschte, ich ___ mehr Zeit."}$j$::jsonb,$j${"value": "hätte", "accepted": ["hätte", "haette"]}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$wishes_ich_wuenschte$p$, $p$writing$p$]),
('eb3512ef-fc60-5cb5-98ca-b8e99d8a3ca7'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','reading','multiple_choice',$p$Elige el orden correcto (verbo al final tras «Ich wünschte»): «Ojalá estuviera aquí».$p$,$j${"options": ["Ich wünschte, ich wäre hier.", "Ich wünschte, ich bin hier.", "Ich wünschte, ich hier wäre."]}$j$::jsonb,$j${"value": "Ich wünschte, ich wäre hier."}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$wishes_ich_wuenschte$p$, $p$reading$p$]),
('33486c30-dcad-5574-a12c-9f123a17b28c'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ich hätte gern ein Stück Kuchen.", "Ich habe ein Stück Kuchen.", "Ich hätte gern ein Glas Wasser."], "say": "Ich hätte gern ein Stück Kuchen.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/33486c30-dcad-5574-a12c-9f123a17b28c.mp3"}$j$::jsonb,$j${"value": "Ich hätte gern ein Stück Kuchen."}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$wishes_haette_gern$p$, $p$listening$p$]),
('5a99fbe8-6225-5574-8fca-71f83e5dffc3'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Ich wünschte, ich hätte mehr Urlaub.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/5a99fbe8-6225-5574-8fca-71f83e5dffc3.mp3"}$j$::jsonb,$j${"expected": "Ich wünschte, ich hätte mehr Urlaub."}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$wishes_ich_wuenschte$p$, $p$speaking$p$]),
('04126c66-d312-52f0-84a3-48966b5aa931'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','reading','match',$p$Une cada consejo con su significado.$p$,$j${"pairs": [{"en": "An deiner Stelle würde ich gehen.", "es": "En tu lugar yo me iría."}, {"en": "Du solltest mehr schlafen.", "es": "Deberías dormir más."}, {"en": "Es wäre besser zu warten.", "es": "Sería mejor esperar."}]}$j$::jsonb,$j${"pairs": [["An deiner Stelle würde ich gehen.", "En tu lugar yo me iría."], ["Du solltest mehr schlafen.", "Deberías dormir más."], ["Es wäre besser zu warten.", "Sería mejor esperar."]]}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$advice_an_deiner_stelle$p$, $p$reading$p$]),
('a7b77b69-9dc9-5a51-8dab-c4cf8ad8b671'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','writing','cloze',$p$Completa con «deberías»: aconsejar a un amigo enfermo.$p$,$j${"text": "Du ___ zum Arzt gehen."}$j$::jsonb,$j${"value": "solltest", "accepted": ["solltest"]}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$advice_sollte$p$, $p$writing$p$]),
('47f1f96b-d8c0-56da-91a8-6903a9152093'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','writing','reorder',$p$Ordena las palabras para formar el consejo «Deberías descansar más».$p$,$j${"tiles": ["dich", "solltest", "Du", "ausruhen", "mehr"]}$j$::jsonb,$j${"value": "Du solltest dich mehr ausruhen"}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$advice_sollte$p$, $p$writing$p$]),
('243ad6d6-bf72-534b-aa66-a7080f537a50'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Du solltest weniger arbeiten.", "Du solltest mehr arbeiten.", "Du willst weniger arbeiten."], "say": "Du solltest weniger arbeiten.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/243ad6d6-bf72-534b-aa66-a7080f537a50.mp3"}$j$::jsonb,$j${"value": "Du solltest weniger arbeiten."}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$advice_sollte$p$, $p$listening$p$]),
('727c6477-cd32-5b9d-8758-bdf4ff010b95'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','reading','multiple_choice',$p$Elige la frase correcta para «Sería estupendo».$p$,$j${"options": ["Das wäre toll.", "Das ist toll.", "Das würde toll."]}$j$::jsonb,$j${"value": "Das wäre toll."}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$hypothetical_waere$p$, $p$reading$p$]),
('8c01fe11-1fec-54f1-8698-4d259f2586d2'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','writing','translation',$p$Traduce: Con más dinero yo podría viajar.$p$,$j${"source": "Con más dinero yo podría viajar."}$j$::jsonb,$j${"value": "Mit mehr Geld könnte ich reisen.", "accepted": ["Mit mehr Geld könnte ich reisen.", "Mit mehr Geld könnte ich reisen", "Mit mehr Geld koennte ich reisen.", "Mit mehr Geld koennte ich reisen"]}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$hypothetical_koennte$p$, $p$writing$p$]),
('df2345f1-d898-5cb1-9b33-7d89a3ca8550'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Es wäre besser zu warten.", "Es ist besser zu warten.", "Es wäre besser zu starten."], "say": "Es wäre besser zu warten.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/df2345f1-d898-5cb1-9b33-7d89a3ca8550.mp3"}$j$::jsonb,$j${"value": "Es wäre besser zu warten."}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$hypothetical_waere$p$, $p$listening$p$]),
('cfcafe83-ce51-5797-810d-44e5be047cd8'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Mit mehr Zeit könnte ich mehr reisen.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/cfcafe83-ce51-5797-810d-44e5be047cd8.mp3"}$j$::jsonb,$j${"expected": "Mit mehr Zeit könnte ich mehr reisen."}$j$::jsonb,0.52,ARRAY[$p$unidad13$p$, $p$hypothetical_koennte$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('427e6a94-96e9-5b3c-a056-53078eba4fee','4444c8a5-8ce7-5c6d-a0de-06cdf36904b8',1),
 ('427e6a94-96e9-5b3c-a056-53078eba4fee','2c302df1-4c81-5b52-a355-e16262be2605',2),
 ('427e6a94-96e9-5b3c-a056-53078eba4fee','41c07fa7-d8ec-590b-a3fa-8162d5af9748',3),
 ('427e6a94-96e9-5b3c-a056-53078eba4fee','46e8d706-e278-56b9-8595-91f8130e20d8',4),
 ('427e6a94-96e9-5b3c-a056-53078eba4fee','f6c211fd-a68a-536b-8e0e-1a7c6b6083b0',5),
 ('c4c4a3a4-610c-5aa1-9f99-738fc8d64ff5','686a895c-044f-5728-8921-a6e4bf93102a',1),
 ('c4c4a3a4-610c-5aa1-9f99-738fc8d64ff5','3cee4233-5e2e-5a02-9000-45a3806a0f09',2),
 ('c4c4a3a4-610c-5aa1-9f99-738fc8d64ff5','0767f7dc-d3e7-52e7-830c-a5a9e38c14a0',3),
 ('c4c4a3a4-610c-5aa1-9f99-738fc8d64ff5','eb3512ef-fc60-5cb5-98ca-b8e99d8a3ca7',4),
 ('c4c4a3a4-610c-5aa1-9f99-738fc8d64ff5','33486c30-dcad-5574-a12c-9f123a17b28c',5),
 ('c4c4a3a4-610c-5aa1-9f99-738fc8d64ff5','5a99fbe8-6225-5574-8fca-71f83e5dffc3',6),
 ('08c9beb2-8941-5f78-9729-9a275e969226','04126c66-d312-52f0-84a3-48966b5aa931',1),
 ('08c9beb2-8941-5f78-9729-9a275e969226','a7b77b69-9dc9-5a51-8dab-c4cf8ad8b671',2),
 ('08c9beb2-8941-5f78-9729-9a275e969226','47f1f96b-d8c0-56da-91a8-6903a9152093',3),
 ('08c9beb2-8941-5f78-9729-9a275e969226','243ad6d6-bf72-534b-aa66-a7080f537a50',4),
 ('5cb5d61a-9db0-5e07-a451-c4263d764bf8','727c6477-cd32-5b9d-8758-bdf4ff010b95',1),
 ('5cb5d61a-9db0-5e07-a451-c4263d764bf8','8c01fe11-1fec-54f1-8698-4d259f2586d2',2),
 ('5cb5d61a-9db0-5e07-a451-c4263d764bf8','df2345f1-d898-5cb1-9b33-7d89a3ca8550',3),
 ('5cb5d61a-9db0-5e07-a451-c4263d764bf8','cfcafe83-ce51-5797-810d-44e5be047cd8',4),
 ('4b8b6ac4-ea58-53c8-9884-dd857b549b0f','4444c8a5-8ce7-5c6d-a0de-06cdf36904b8',1),
 ('4b8b6ac4-ea58-53c8-9884-dd857b549b0f','2c302df1-4c81-5b52-a355-e16262be2605',2),
 ('4b8b6ac4-ea58-53c8-9884-dd857b549b0f','686a895c-044f-5728-8921-a6e4bf93102a',3),
 ('4b8b6ac4-ea58-53c8-9884-dd857b549b0f','41c07fa7-d8ec-590b-a3fa-8162d5af9748',4),
 ('4b8b6ac4-ea58-53c8-9884-dd857b549b0f','3cee4233-5e2e-5a02-9000-45a3806a0f09',5),
 ('4b8b6ac4-ea58-53c8-9884-dd857b549b0f','0767f7dc-d3e7-52e7-830c-a5a9e38c14a0',6),
 ('4b8b6ac4-ea58-53c8-9884-dd857b549b0f','46e8d706-e278-56b9-8595-91f8130e20d8',7),
 ('4b8b6ac4-ea58-53c8-9884-dd857b549b0f','33486c30-dcad-5574-a12c-9f123a17b28c',8),
 ('4b8b6ac4-ea58-53c8-9884-dd857b549b0f','f6c211fd-a68a-536b-8e0e-1a7c6b6083b0',9),
 ('4b8b6ac4-ea58-53c8-9884-dd857b549b0f','5a99fbe8-6225-5574-8fca-71f83e5dffc3',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('e7dd262e-3407-5a70-92a0-b8586fd9aae6','20000000-0000-0000-0000-000000000005',$p$würde$p$,$p$condicional (auxiliar): -ría$p$,361,'verbo'),
 ('f1b79232-16a9-5973-af69-35480b33eb61','20000000-0000-0000-0000-000000000005',$p$hätte$p$,$p$tendría / tuviera$p$,362,'verbo'),
 ('36ba15f0-31d7-5fe1-8bcf-afac4c145ccd','20000000-0000-0000-0000-000000000005',$p$wäre$p$,$p$sería / fuera / estaría$p$,363,'verbo'),
 ('d13b2572-657a-5475-aa97-38823ffee70f','20000000-0000-0000-0000-000000000005',$p$könnte$p$,$p$podría$p$,364,'verbo'),
 ('ef7eebb1-b0f1-5694-9bd6-1af51c9ba7f2','20000000-0000-0000-0000-000000000005',$p$sollte$p$,$p$debería$p$,365,'verbo'),
 ('0f1a4c98-0d6d-5076-9669-e91959e19076','20000000-0000-0000-0000-000000000005',$p$der Rat$p$,$p$el consejo$p$,366,'sustantivo'),
 ('3921fe15-6cb3-5528-aec2-335f34ff6e32','20000000-0000-0000-0000-000000000005',$p$die Stelle$p$,$p$el lugar / puesto$p$,367,'sustantivo'),
 ('2605d168-31c1-5cc3-be8f-dbed6448102d','20000000-0000-0000-0000-000000000005',$p$der Wunsch$p$,$p$el deseo$p$,368,'sustantivo'),
 ('468778b3-3a49-5b31-bec1-320598178d78','20000000-0000-0000-0000-000000000005',$p$höflich$p$,$p$cortés / educado$p$,369,'adjetivo'),
 ('a0f96977-8a3f-5956-9aa4-657331f089c7','20000000-0000-0000-0000-000000000005',$p$gern$p$,$p$con gusto / me gustaría$p$,370,'adverbio'),
 ('338788c3-7bc1-5e1e-a114-9363f6203a71','20000000-0000-0000-0000-000000000005',$p$vielleicht$p$,$p$quizás$p$,371,'adverbio'),
 ('767dee27-3979-5704-8228-51c90c6c8c54','20000000-0000-0000-0000-000000000005',$p$An deiner Stelle$p$,$p$en tu lugar$p$,372,'expresion'),
 ('eeb637ab-9e3e-566c-89d8-22e1feea5b1b','20000000-0000-0000-0000-000000000005',$p$Ich hätte gern$p$,$p$quisiera / me gustaría (pedir)$p$,373,'expresion'),
 ('7e36fa5d-9e85-514d-a90f-bf25755ddff9','20000000-0000-0000-0000-000000000005',$p$Ich wünschte$p$,$p$ojalá / cómo desearía$p$,374,'expresion'),
 ('95acac9e-3852-54c0-8d97-d39f07fff92d','20000000-0000-0000-0000-000000000005',$p$Könnten Sie…?$p$,$p$¿Podría usted…?$p$,375,'expresion'),
 ('f194908a-5399-58de-990d-8c328bbee01f','20000000-0000-0000-0000-000000000005',$p$Es wäre besser$p$,$p$sería mejor$p$,376,'expresion')
on conflict (id) do nothing;

-- ── Unidad 14 (B1·de): Unir ideas: porque, aunque, así que ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('5ce8a888-927d-5eec-b705-8c0e7bd85fe9','20000000-0000-0000-0000-000000000005','B1',14,$p$Unir ideas: porque, aunque, así que$p$,'#1F618D','hub')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('a35e48df-9e62-53e7-bd52-8ce48b712bac','5ce8a888-927d-5eec-b705-8c0e7bd85fe9',1,$p$weil y dass: el verbo al final$p$,$p$weil y dass: el verbo al final$p$,'lesson',15),
 ('85ad21d8-6395-5df1-837c-8684516f5e38','5ce8a888-927d-5eec-b705-8c0e7bd85fe9',2,$p$wenn, als, obwohl, damit$p$,$p$wenn, als, obwohl, damit$p$,'lesson',15),
 ('69a07402-df2c-596e-aa06-051608f0bb61','5ce8a888-927d-5eec-b705-8c0e7bd85fe9',3,$p$deshalb, deswegen, trotzdem: la inversión$p$,$p$deshalb, deswegen, trotzdem: la inversión$p$,'lesson',15),
 ('ba1a16e9-d9f9-516e-8264-2f6cf19e47d0','5ce8a888-927d-5eec-b705-8c0e7bd85fe9',4,$p$Todo junto: contraste de orden$p$,$p$Todo junto: contraste de orden$p$,'lesson',15),
 ('ebed7014-510f-5b28-9308-86f46487fa09','5ce8a888-927d-5eec-b705-8c0e7bd85fe9',5,$p$🏁 Checkpoint Einheit 14$p$,$p$Une frases con weil, dass, wenn, obwohl, damit y als (verbo al final) y con deshalb, trotzdem, deswegen (inversión).$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('e008e716-b5bc-5cdf-abd1-9f788c97394d','20000000-0000-0000-0000-000000000005','checkpoint','B1','5ce8a888-927d-5eec-b705-8c0e7bd85fe9',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('c8777c3e-ce37-590c-90d0-2de6be31d186'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','reading','match',$p$Une el conector con su significado:$p$,$j${"pairs": [{"en": "weil", "es": "porque"}, {"en": "dass", "es": "que"}, {"en": "der Grund", "es": "el motivo"}]}$j$::jsonb,$j${"pairs": [["weil", "porque"], ["dass", "que"], ["der Grund", "el motivo"]]}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$weil$p$, $p$reading$p$]),
('d72b4c73-a245-5b2d-bb8b-0cd405f418de'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','reading','multiple_choice',$p$Elige la frase con el orden correcto (verbo al final tras «weil»):$p$,$j${"options": ["Ich bleibe zu Hause, weil ich krank bin.", "Ich bleibe zu Hause, weil ich bin krank.", "Ich bleibe zu Hause, weil bin ich krank."]}$j$::jsonb,$j${"value": "Ich bleibe zu Hause, weil ich krank bin."}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$weil-orden$p$, $p$reading$p$]),
('db6ee05e-cb0b-5765-b2be-6c2dd86c737a'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','writing','cloze',$p$Completa con el conector «porque»: Ich lerne Deutsch, ___ ich in Berlin wohne.$p$,$j${"text": "Ich lerne Deutsch, ___ ich in Berlin wohne."}$j$::jsonb,$j${"value": "weil", "accepted": ["weil"]}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$weil$p$, $p$writing$p$]),
('22e518a1-f869-5504-a3ff-72f47c5e5168'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ich weiß, dass du recht hast.", "Ich weiß, dass du recht hattest.", "Ich weiß, dass du Reis hast."], "say": "Ich weiß, dass du recht hast.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/22e518a1-f869-5504-a3ff-72f47c5e5168.mp3"}$j$::jsonb,$j${"value": "Ich weiß, dass du recht hast."}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$dass$p$, $p$listening$p$]),
('1178e3d1-e045-577f-882b-582e1a31f28b'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','reading','match',$p$Une el conector con su significado:$p$,$j${"pairs": [{"en": "obwohl", "es": "aunque"}, {"en": "wenn", "es": "cuando/si"}, {"en": "damit", "es": "para que"}]}$j$::jsonb,$j${"pairs": [["obwohl", "aunque"], ["wenn", "cuando/si"], ["damit", "para que"]]}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$obwohl$p$, $p$reading$p$]),
('222e4ed0-7363-52be-905d-da089b92fb0f'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','reading','multiple_choice',$p$Elige la frase con el orden correcto (verbo al final tras «obwohl»):$p$,$j${"options": ["Ich gehe spazieren, obwohl es regnet.", "Ich gehe spazieren, obwohl regnet es.", "Ich gehe spazieren, obwohl es regnet nicht."]}$j$::jsonb,$j${"value": "Ich gehe spazieren, obwohl es regnet."}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$obwohl-orden$p$, $p$reading$p$]),
('f0e0b949-c6a5-50a1-a758-751669000791'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','reading','multiple_choice',$p$Elige el conector correcto para un hecho único en el pasado: «Ich war glücklich, ___ ich sie sah.»$p$,$j${"options": ["als", "wenn", "dass"]}$j$::jsonb,$j${"value": "als"}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$als-vs-wenn$p$, $p$reading$p$]),
('24618788-aa91-5a93-acff-e678384ff4ed'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','writing','cloze',$p$Completa con «para que»: Ich spreche langsam, ___ du mich verstehst.$p$,$j${"text": "Ich spreche langsam, ___ du mich verstehst."}$j$::jsonb,$j${"value": "damit", "accepted": ["damit"]}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$damit$p$, $p$writing$p$]),
('3bec6065-b5e7-51e5-87d5-0029c275ad82'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Obwohl es kalt ist, gehe ich schwimmen.", "Obwohl es kalt ist, gehe ich schlafen.", "Obwohl es alt ist, gehe ich schwimmen."], "say": "Obwohl es kalt ist, gehe ich schwimmen.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/3bec6065-b5e7-51e5-87d5-0029c275ad82.mp3"}$j$::jsonb,$j${"value": "Obwohl es kalt ist, gehe ich schwimmen."}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$obwohl$p$, $p$listening$p$]),
('12bc6450-f245-5998-996c-e0b406418b99'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Ich lerne viel, damit ich die Prüfung bestehe.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/12bc6450-f245-5998-996c-e0b406418b99.mp3"}$j$::jsonb,$j${"expected": "Ich lerne viel, damit ich die Prüfung bestehe."}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$damit$p$, $p$speaking$p$]),
('0aaa7fdc-575e-5b30-9f9f-158e32172e0a'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','reading','multiple_choice',$p$Elige la frase con la inversión correcta tras «deshalb» (verbo en 2ª posición):$p$,$j${"options": ["Ich bin krank, deshalb bleibe ich zu Hause.", "Ich bin krank, deshalb ich bleibe zu Hause.", "Ich bin krank, deshalb zu Hause ich bleibe."]}$j$::jsonb,$j${"value": "Ich bin krank, deshalb bleibe ich zu Hause."}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$deshalb-inversion$p$, $p$reading$p$]),
('5b209cd6-a7a9-55da-81a5-ac0c2aceca4a'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','writing','cloze',$p$Completa con «por eso»: Es regnet, ___ nehme ich einen Regenschirm.$p$,$j${"text": "Es regnet, ___ nehme ich einen Regenschirm."}$j$::jsonb,$j${"value": "deswegen", "accepted": ["deswegen", "deshalb"]}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$deswegen$p$, $p$writing$p$]),
('e58c6fbd-8ccb-5b65-af5f-e579e4ddcc4e'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','writing','reorder',$p$Ordena para formar «A pesar de eso voy a la fiesta» (Es ist spät, ...):$p$,$j${"tiles": ["trotzdem", "gehe", "ich", "zur", "Party"]}$j$::jsonb,$j${"value": "trotzdem gehe ich zur Party"}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$trotzdem-inversion$p$, $p$writing$p$]),
('48ad0f7c-06c4-5de5-9709-acfab3db12b4'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Es ist spät, deshalb gehe ich nach Hause.", "Es ist spät, deshalb gehe ich nach Hamburg.", "Es ist spät, deshalb sehe ich nach Hause."], "say": "Es ist spät, deshalb gehe ich nach Hause.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/48ad0f7c-06c4-5de5-9709-acfab3db12b4.mp3"}$j$::jsonb,$j${"value": "Es ist spät, deshalb gehe ich nach Hause."}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$deshalb$p$, $p$listening$p$]),
('308666ec-5480-5565-8758-da2192d43bbe'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Ich bin müde, deshalb gehe ich früh ins Bett.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/308666ec-5480-5565-8758-da2192d43bbe.mp3"}$j$::jsonb,$j${"expected": "Ich bin müde, deshalb gehe ich früh ins Bett."}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$deshalb$p$, $p$speaking$p$]),
('82b23661-f68f-5f4e-b3d5-6fe5ae1b6307'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','writing','translation',$p$Traduce: No voy porque estoy cansado.$p$,$j${"source": "No voy porque estoy cansado."}$j$::jsonb,$j${"value": "Ich gehe nicht, weil ich müde bin.", "accepted": ["Ich gehe nicht, weil ich müde bin", "Ich gehe nicht, weil ich müde bin.", "Ich komme nicht, weil ich müde bin", "Ich komme nicht, weil ich müde bin."]}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$weil-produccion$p$, $p$writing$p$]),
('301bfbca-899f-5385-b2ba-2adfd6626797'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','writing','word_bank',$p$Construye: Aunque estoy cansado, trabajo.$p$,$j${"tiles": ["Obwohl", "ich", "müde", "bin,", "arbeite", "ich", "und", "ist"]}$j$::jsonb,$j${"value": "Obwohl ich müde bin, arbeite ich", "sequence": ["Obwohl", "ich", "müde", "bin,", "arbeite", "ich"]}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$obwohl-produccion$p$, $p$writing$p$]),
('72934d36-d6b9-5d5e-851d-27f5ce4fafa4'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Es tut mir leid, dass ich zu spät bin.", "Es tut mir leid, dass ich zu satt bin.", "Es tut mir leid, dass ich zu spät war."], "say": "Es tut mir leid, dass ich zu spät bin.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/72934d36-d6b9-5d5e-851d-27f5ce4fafa4.mp3"}$j$::jsonb,$j${"value": "Es tut mir leid, dass ich zu spät bin."}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$dass-produccion$p$, $p$listening$p$]),
('fc079046-b2ff-5bd7-ae2f-4dacbe4dd1b8'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Das Wetter ist schlecht, trotzdem machen wir einen Ausflug.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/fc079046-b2ff-5bd7-ae2f-4dacbe4dd1b8.mp3"}$j$::jsonb,$j${"expected": "Das Wetter ist schlecht, trotzdem machen wir einen Ausflug."}$j$::jsonb,0.52,ARRAY[$p$unidad14$p$, $p$trotzdem-produccion$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('a35e48df-9e62-53e7-bd52-8ce48b712bac','c8777c3e-ce37-590c-90d0-2de6be31d186',1),
 ('a35e48df-9e62-53e7-bd52-8ce48b712bac','d72b4c73-a245-5b2d-bb8b-0cd405f418de',2),
 ('a35e48df-9e62-53e7-bd52-8ce48b712bac','db6ee05e-cb0b-5765-b2be-6c2dd86c737a',3),
 ('a35e48df-9e62-53e7-bd52-8ce48b712bac','22e518a1-f869-5504-a3ff-72f47c5e5168',4),
 ('85ad21d8-6395-5df1-837c-8684516f5e38','1178e3d1-e045-577f-882b-582e1a31f28b',1),
 ('85ad21d8-6395-5df1-837c-8684516f5e38','222e4ed0-7363-52be-905d-da089b92fb0f',2),
 ('85ad21d8-6395-5df1-837c-8684516f5e38','f0e0b949-c6a5-50a1-a758-751669000791',3),
 ('85ad21d8-6395-5df1-837c-8684516f5e38','24618788-aa91-5a93-acff-e678384ff4ed',4),
 ('85ad21d8-6395-5df1-837c-8684516f5e38','3bec6065-b5e7-51e5-87d5-0029c275ad82',5),
 ('85ad21d8-6395-5df1-837c-8684516f5e38','12bc6450-f245-5998-996c-e0b406418b99',6),
 ('69a07402-df2c-596e-aa06-051608f0bb61','0aaa7fdc-575e-5b30-9f9f-158e32172e0a',1),
 ('69a07402-df2c-596e-aa06-051608f0bb61','5b209cd6-a7a9-55da-81a5-ac0c2aceca4a',2),
 ('69a07402-df2c-596e-aa06-051608f0bb61','e58c6fbd-8ccb-5b65-af5f-e579e4ddcc4e',3),
 ('69a07402-df2c-596e-aa06-051608f0bb61','48ad0f7c-06c4-5de5-9709-acfab3db12b4',4),
 ('69a07402-df2c-596e-aa06-051608f0bb61','308666ec-5480-5565-8758-da2192d43bbe',5),
 ('ba1a16e9-d9f9-516e-8264-2f6cf19e47d0','82b23661-f68f-5f4e-b3d5-6fe5ae1b6307',1),
 ('ba1a16e9-d9f9-516e-8264-2f6cf19e47d0','301bfbca-899f-5385-b2ba-2adfd6626797',2),
 ('ba1a16e9-d9f9-516e-8264-2f6cf19e47d0','72934d36-d6b9-5d5e-851d-27f5ce4fafa4',3),
 ('ba1a16e9-d9f9-516e-8264-2f6cf19e47d0','fc079046-b2ff-5bd7-ae2f-4dacbe4dd1b8',4),
 ('ebed7014-510f-5b28-9308-86f46487fa09','c8777c3e-ce37-590c-90d0-2de6be31d186',1),
 ('ebed7014-510f-5b28-9308-86f46487fa09','d72b4c73-a245-5b2d-bb8b-0cd405f418de',2),
 ('ebed7014-510f-5b28-9308-86f46487fa09','1178e3d1-e045-577f-882b-582e1a31f28b',3),
 ('ebed7014-510f-5b28-9308-86f46487fa09','db6ee05e-cb0b-5765-b2be-6c2dd86c737a',4),
 ('ebed7014-510f-5b28-9308-86f46487fa09','24618788-aa91-5a93-acff-e678384ff4ed',5),
 ('ebed7014-510f-5b28-9308-86f46487fa09','5b209cd6-a7a9-55da-81a5-ac0c2aceca4a',6),
 ('ebed7014-510f-5b28-9308-86f46487fa09','22e518a1-f869-5504-a3ff-72f47c5e5168',7),
 ('ebed7014-510f-5b28-9308-86f46487fa09','3bec6065-b5e7-51e5-87d5-0029c275ad82',8),
 ('ebed7014-510f-5b28-9308-86f46487fa09','12bc6450-f245-5998-996c-e0b406418b99',9),
 ('ebed7014-510f-5b28-9308-86f46487fa09','308666ec-5480-5565-8758-da2192d43bbe',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('636ca3ce-b2e5-5adf-8234-e3222bfc0bc5','20000000-0000-0000-0000-000000000005',$p$weil$p$,$p$porque (verbo al final)$p$,381,'conj'),
 ('632ebe4f-5853-5b8c-8668-c47f58c76c72','20000000-0000-0000-0000-000000000005',$p$dass$p$,$p$que (subordinante)$p$,382,'conj'),
 ('8cd66757-51d9-5842-a1b3-0148017c3522','20000000-0000-0000-0000-000000000005',$p$wenn$p$,$p$cuando / si$p$,383,'conj'),
 ('c3fd6e02-0a16-5d93-a9fa-61a936558d66','20000000-0000-0000-0000-000000000005',$p$als$p$,$p$cuando (pasado único)$p$,384,'conj'),
 ('2fa14ff5-e1f7-5eda-8040-e6e36d81eff4','20000000-0000-0000-0000-000000000005',$p$obwohl$p$,$p$aunque$p$,385,'conj'),
 ('00d0f00a-ad84-5ac7-b066-0965e4a223bb','20000000-0000-0000-0000-000000000005',$p$damit$p$,$p$para que$p$,386,'conj'),
 ('57509824-128e-54fc-9b94-72f8629b71bf','20000000-0000-0000-0000-000000000005',$p$deshalb$p$,$p$por eso$p$,387,'adv'),
 ('3c278dfc-141c-5543-bf16-46c3cdf74178','20000000-0000-0000-0000-000000000005',$p$deswegen$p$,$p$por eso$p$,388,'adv'),
 ('5043e1e8-894f-51cc-bfa7-523a3b68e1e9','20000000-0000-0000-0000-000000000005',$p$trotzdem$p$,$p$a pesar de eso$p$,389,'adv'),
 ('30630950-ef53-531a-86db-719c5dcf3155','20000000-0000-0000-0000-000000000005',$p$der Grund$p$,$p$el motivo$p$,390,'noun'),
 ('9dcc8374-8691-5300-b20d-8255e23adbb3','20000000-0000-0000-0000-000000000005',$p$die Idee$p$,$p$la idea$p$,391,'noun'),
 ('9e3643db-9e56-5bcc-80b4-c4ceb798422b','20000000-0000-0000-0000-000000000005',$p$die Erkältung$p$,$p$el resfriado$p$,392,'noun'),
 ('bca74750-6fcb-5e7a-942f-3aa8ee74cd2d','20000000-0000-0000-0000-000000000005',$p$das Wetter$p$,$p$el tiempo (clima)$p$,393,'noun'),
 ('65c97974-abad-5fc6-ba26-db6319148145','20000000-0000-0000-0000-000000000005',$p$die Prüfung$p$,$p$el examen$p$,394,'noun'),
 ('92083bc6-06e8-5314-9b61-00cf92edd165','20000000-0000-0000-0000-000000000005',$p$müde$p$,$p$cansado$p$,395,'adj'),
 ('6094daf7-15a0-5e6e-9ced-1703980e5ee8','20000000-0000-0000-0000-000000000005',$p$pünktlich$p$,$p$puntual$p$,396,'adj')
on conflict (id) do nothing;

-- ── Unidad 15 (B1·de): Frases de relativo (der/die/das) ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('6aa88ef3-fc02-5660-9361-af2af198d2c7','20000000-0000-0000-0000-000000000005','B1',15,$p$Frases de relativo (der/die/das)$p$,'#117864','link')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('0683cb0c-1498-5ea4-8a9f-7143cb50f025','6aa88ef3-fc02-5660-9361-af2af198d2c7',1,$p$Relativpronomen en Nominativ (der/die/das)$p$,$p$Relativpronomen en Nominativ (der/die/das)$p$,'lesson',15),
 ('0463e14b-3a1e-5c62-af86-78364b325cd9','6aa88ef3-fc02-5660-9361-af2af198d2c7',2,$p$Relativpronomen en Akkusativ (den/die/das)$p$,$p$Relativpronomen en Akkusativ (den/die/das)$p$,'lesson',15),
 ('fa5eb9c9-ead1-5498-89ac-cda059d27e7f','6aa88ef3-fc02-5660-9361-af2af198d2c7',3,$p$Relativpronomen en Dativ (dem/der/dem)$p$,$p$Relativpronomen en Dativ (dem/der/dem)$p$,'lesson',15),
 ('ec9b40d2-b213-5713-8284-6d01fd03e7bc','6aa88ef3-fc02-5660-9361-af2af198d2c7',4,$p$Preposición + relativo y repaso$p$,$p$Preposición + relativo y repaso$p$,'lesson',15),
 ('d8c36a40-a97b-5bd7-b7de-52e78a66a3f9','6aa88ef3-fc02-5660-9361-af2af198d2c7',5,$p$🏁 Checkpoint Einheit 15$p$,$p$Une frases con pronombres relativos (der/die/das) concordando género, número y caso, con el verbo al final.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('344a1952-3939-5088-82e1-629bb4203eb4','20000000-0000-0000-0000-000000000005','checkpoint','B1','6aa88ef3-fc02-5660-9361-af2af198d2c7',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('3c9615c6-2c45-55a6-8c90-5c419050ee17'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','reading','match',$p$Une cada frase de relativo con su traducción.$p$,$j${"pairs": [{"en": "Der Mann, der dort wohnt", "es": "El hombre que vive allí"}, {"en": "Das Buch, das ich lese", "es": "El libro que leo"}, {"en": "Die Frau, der ich helfe", "es": "La mujer a la que ayudo"}]}$j$::jsonb,$j${"pairs": [["Der Mann, der dort wohnt", "El hombre que vive allí"], ["Das Buch, das ich lese", "El libro que leo"], ["Die Frau, der ich helfe", "La mujer a la que ayudo"]]}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$relativ_nominativ$p$, $p$reading$p$]),
('7c351426-297f-5ebb-ab7b-bab7dbc29595'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','reading','multiple_choice',$p$Elige el pronombre relativo correcto (sujeto masculino): «Das ist der Freund, ___ in Berlin arbeitet.»$p$,$j${"options": ["der", "die", "das"]}$j$::jsonb,$j${"value": "der"}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$relativ_nominativ$p$, $p$reading$p$]),
('635a9c10-f6f4-5d98-a397-d0e826ddae07'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','reading','multiple_choice',$p$Elige el pronombre relativo correcto (sujeto femenino): «Das ist die Frau, ___ neben uns wohnt.»$p$,$j${"options": ["die", "der", "das"]}$j$::jsonb,$j${"value": "die"}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$relativ_nominativ$p$, $p$reading$p$]),
('5be7fb79-fb73-5c81-bf4a-3c2e8f800c17'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','writing','cloze',$p$Completa con el relativo en Nominativ (neutro sujeto): «Das ist das Kind, ___ dort spielt.»$p$,$j${"text": "Das ist das Kind, ___ dort spielt."}$j$::jsonb,$j${"value": "das", "accepted": ["das"]}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$relativ_nominativ$p$, $p$writing$p$]),
('13409c5e-74a2-5d00-ab3c-d87068bbe9b5'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','listening','listening',$p$Escucha y elige la frase correcta.$p$,$j${"options": ["Das ist die Wohnung, die mir gefällt.", "Das ist die Wohnung, der mir gefällt.", "Das ist die Wohnung, das mir gefällt."], "say": "Das ist die Wohnung, die mir gefällt.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/13409c5e-74a2-5d00-ab3c-d87068bbe9b5.mp3"}$j$::jsonb,$j${"value": "Das ist die Wohnung, die mir gefällt."}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$relativ_nominativ$p$, $p$listening$p$]),
('7f6d8282-db9b-530b-934f-0e01d8226091'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','reading','multiple_choice',$p$Elige el pronombre relativo correcto (objeto directo neutro): «Das ist das Auto, ___ ich kaufen möchte.»$p$,$j${"options": ["das", "den", "dem"]}$j$::jsonb,$j${"value": "das"}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$relativ_akkusativ$p$, $p$reading$p$]),
('446f6248-0a21-54d1-8e6d-5b0efef9fb5c'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','reading','multiple_choice',$p$Elige el pronombre relativo correcto (objeto directo masculino): «Der Film, ___ wir gestern gesehen haben, war gut.»$p$,$j${"options": ["den", "der", "das"]}$j$::jsonb,$j${"value": "den"}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$relativ_akkusativ$p$, $p$reading$p$]),
('4e1a84b6-00ca-5a94-8ac0-920173efcc20'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','writing','cloze',$p$Completa con el relativo en Akkusativ (masculino objeto): «Der Zug, ___ ich nehme, kommt um acht.»$p$,$j${"text": "Der Zug, ___ ich nehme, kommt um acht."}$j$::jsonb,$j${"value": "den", "accepted": ["den"]}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$relativ_akkusativ$p$, $p$writing$p$]),
('a20a7a86-8541-5b59-bdd1-b6dba655bf1e'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','writing','word_bank',$p$Ordena la frase de relativo (masculino, objeto directo): «El amigo al que veo.»$p$,$j${"tiles": ["Der", "Freund,", "den", "ich", "sehe", "die", "der"]}$j$::jsonb,$j${"value": "Der Freund, den ich sehe", "sequence": ["Der", "Freund,", "den", "ich", "sehe"]}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$relativ_akkusativ$p$, $p$writing$p$]),
('e5bcb3fd-b1e9-5dae-a0d8-0e3c18ca68ac'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','listening','listening',$p$Escucha y elige la frase correcta.$p$,$j${"options": ["Das Handy, das ich gekauft habe, war teuer.", "Das Handy, den ich gekauft habe, war teuer.", "Das Handy, dem ich gekauft habe, war teuer."], "say": "Das Handy, das ich gekauft habe, war teuer.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/e5bcb3fd-b1e9-5dae-a0d8-0e3c18ca68ac.mp3"}$j$::jsonb,$j${"value": "Das Handy, das ich gekauft habe, war teuer."}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$relativ_akkusativ$p$, $p$listening$p$]),
('d58f2300-43c4-5d9c-bbb5-8455b69db94c'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','reading','multiple_choice',$p$Elige el pronombre relativo correcto (dativo femenino): «Die Kollegin, ___ ich das Buch gebe, ist nett.»$p$,$j${"options": ["der", "die", "den"]}$j$::jsonb,$j${"value": "der"}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$relativ_dativ$p$, $p$reading$p$]),
('7b85b223-582b-5c91-8ab3-10e3fd53ccbe'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','writing','cloze',$p$Completa con el relativo en Dativ (masculino): «Der Lehrer, ___ ich danke, ist sehr geduldig.»$p$,$j${"text": "Der Lehrer, ___ ich danke, ist sehr geduldig."}$j$::jsonb,$j${"value": "dem", "accepted": ["dem"]}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$relativ_dativ$p$, $p$writing$p$]),
('50875547-4424-5ee5-89f2-5cbf010494b8'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','listening','listening',$p$Escucha y elige la frase correcta.$p$,$j${"options": ["Der Freund, dem ich helfe, ist krank.", "Der Freund, den ich helfe, ist krank.", "Der Freund, der ich helfe, ist krank."], "say": "Der Freund, dem ich helfe, ist krank.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/50875547-4424-5ee5-89f2-5cbf010494b8.mp3"}$j$::jsonb,$j${"value": "Der Freund, dem ich helfe, ist krank."}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$relativ_dativ$p$, $p$listening$p$]),
('932570c9-cf34-5e2d-a9d0-cc88e30bffff'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta esta frase de relativo.$p$,$j${"text": "Das ist der Mann, der neben uns wohnt.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/932570c9-cf34-5e2d-a9d0-cc88e30bffff.mp3"}$j$::jsonb,$j${"expected": "Das ist der Mann, der neben uns wohnt."}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$relativ_dativ$p$, $p$speaking$p$]),
('5e4783aa-8cb7-5b59-8bf8-42bebfa8cb77'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','writing','translation',$p$Traduce: «La mujer con la que hablo es simpática.»$p$,$j${"source": "La mujer con la que hablo es simpática."}$j$::jsonb,$j${"value": "Die Frau, mit der ich spreche, ist sympathisch.", "accepted": ["Die Frau, mit der ich spreche, ist sympathisch", "Die Frau, mit der ich spreche, ist sympathisch.", "Die Frau mit der ich spreche ist sympathisch", "Die Frau, mit der ich rede, ist sympathisch"]}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$relativ_praeposition$p$, $p$writing$p$]),
('cc09530c-7a26-53c0-8d51-ae0d9263cee4'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','writing','reorder',$p$Ordena la frase con el verbo al final: «La ciudad en la que vivo es bonita.»$p$,$j${"tiles": ["Die", "Stadt,", "in", "der", "ich", "wohne,", "ist", "schön", "das"]}$j$::jsonb,$j${"value": "Die Stadt, in der ich wohne, ist schön"}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$relativ_praeposition$p$, $p$writing$p$]),
('d6326970-5b71-5e77-9492-03f2707f4a8c'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','listening','listening',$p$Escucha y elige la frase correcta.$p$,$j${"options": ["Die Nachbarin, mit der ich rede, ist nett.", "Die Nachbarin, mit dem ich rede, ist nett.", "Die Nachbarin, mit die ich rede, ist nett."], "say": "Die Nachbarin, mit der ich rede, ist nett.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/d6326970-5b71-5e77-9492-03f2707f4a8c.mp3"}$j$::jsonb,$j${"value": "Die Nachbarin, mit der ich rede, ist nett."}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$relativ_praeposition$p$, $p$listening$p$]),
('274a2deb-86ce-5e0b-a1de-9ae9d1531619'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta esta frase de relativo.$p$,$j${"text": "Das Restaurant, das wir empfehlen, ist italienisch.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/274a2deb-86ce-5e0b-a1de-9ae9d1531619.mp3"}$j$::jsonb,$j${"expected": "Das Restaurant, das wir empfehlen, ist italienisch."}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$relativ_praeposition$p$, $p$speaking$p$]),
('05259e7a-8fd1-55f3-bbfa-ee317d524bfc'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta esta frase de relativo.$p$,$j${"text": "Die Geschichte, die du erzählst, ist sehr interessant.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/05259e7a-8fd1-55f3-bbfa-ee317d524bfc.mp3"}$j$::jsonb,$j${"expected": "Die Geschichte, die du erzählst, ist sehr interessant."}$j$::jsonb,0.52,ARRAY[$p$unidad15$p$, $p$relativ_praeposition$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('0683cb0c-1498-5ea4-8a9f-7143cb50f025','3c9615c6-2c45-55a6-8c90-5c419050ee17',1),
 ('0683cb0c-1498-5ea4-8a9f-7143cb50f025','7c351426-297f-5ebb-ab7b-bab7dbc29595',2),
 ('0683cb0c-1498-5ea4-8a9f-7143cb50f025','635a9c10-f6f4-5d98-a397-d0e826ddae07',3),
 ('0683cb0c-1498-5ea4-8a9f-7143cb50f025','5be7fb79-fb73-5c81-bf4a-3c2e8f800c17',4),
 ('0683cb0c-1498-5ea4-8a9f-7143cb50f025','13409c5e-74a2-5d00-ab3c-d87068bbe9b5',5),
 ('0463e14b-3a1e-5c62-af86-78364b325cd9','7f6d8282-db9b-530b-934f-0e01d8226091',1),
 ('0463e14b-3a1e-5c62-af86-78364b325cd9','446f6248-0a21-54d1-8e6d-5b0efef9fb5c',2),
 ('0463e14b-3a1e-5c62-af86-78364b325cd9','4e1a84b6-00ca-5a94-8ac0-920173efcc20',3),
 ('0463e14b-3a1e-5c62-af86-78364b325cd9','a20a7a86-8541-5b59-bdd1-b6dba655bf1e',4),
 ('0463e14b-3a1e-5c62-af86-78364b325cd9','e5bcb3fd-b1e9-5dae-a0d8-0e3c18ca68ac',5),
 ('fa5eb9c9-ead1-5498-89ac-cda059d27e7f','d58f2300-43c4-5d9c-bbb5-8455b69db94c',1),
 ('fa5eb9c9-ead1-5498-89ac-cda059d27e7f','7b85b223-582b-5c91-8ab3-10e3fd53ccbe',2),
 ('fa5eb9c9-ead1-5498-89ac-cda059d27e7f','50875547-4424-5ee5-89f2-5cbf010494b8',3),
 ('fa5eb9c9-ead1-5498-89ac-cda059d27e7f','932570c9-cf34-5e2d-a9d0-cc88e30bffff',4),
 ('ec9b40d2-b213-5713-8284-6d01fd03e7bc','5e4783aa-8cb7-5b59-8bf8-42bebfa8cb77',1),
 ('ec9b40d2-b213-5713-8284-6d01fd03e7bc','cc09530c-7a26-53c0-8d51-ae0d9263cee4',2),
 ('ec9b40d2-b213-5713-8284-6d01fd03e7bc','d6326970-5b71-5e77-9492-03f2707f4a8c',3),
 ('ec9b40d2-b213-5713-8284-6d01fd03e7bc','274a2deb-86ce-5e0b-a1de-9ae9d1531619',4),
 ('ec9b40d2-b213-5713-8284-6d01fd03e7bc','05259e7a-8fd1-55f3-bbfa-ee317d524bfc',5),
 ('d8c36a40-a97b-5bd7-b7de-52e78a66a3f9','3c9615c6-2c45-55a6-8c90-5c419050ee17',1),
 ('d8c36a40-a97b-5bd7-b7de-52e78a66a3f9','7c351426-297f-5ebb-ab7b-bab7dbc29595',2),
 ('d8c36a40-a97b-5bd7-b7de-52e78a66a3f9','635a9c10-f6f4-5d98-a397-d0e826ddae07',3),
 ('d8c36a40-a97b-5bd7-b7de-52e78a66a3f9','5be7fb79-fb73-5c81-bf4a-3c2e8f800c17',4),
 ('d8c36a40-a97b-5bd7-b7de-52e78a66a3f9','4e1a84b6-00ca-5a94-8ac0-920173efcc20',5),
 ('d8c36a40-a97b-5bd7-b7de-52e78a66a3f9','a20a7a86-8541-5b59-bdd1-b6dba655bf1e',6),
 ('d8c36a40-a97b-5bd7-b7de-52e78a66a3f9','13409c5e-74a2-5d00-ab3c-d87068bbe9b5',7),
 ('d8c36a40-a97b-5bd7-b7de-52e78a66a3f9','e5bcb3fd-b1e9-5dae-a0d8-0e3c18ca68ac',8),
 ('d8c36a40-a97b-5bd7-b7de-52e78a66a3f9','932570c9-cf34-5e2d-a9d0-cc88e30bffff',9),
 ('d8c36a40-a97b-5bd7-b7de-52e78a66a3f9','274a2deb-86ce-5e0b-a1de-9ae9d1531619',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('950663e2-00b3-5b81-85f4-edda1eeddb5e','20000000-0000-0000-0000-000000000005',$p$der Mann$p$,$p$el hombre$p$,401,'n'),
 ('43ccdad2-6e71-5cd0-a33f-52427190bd36','20000000-0000-0000-0000-000000000005',$p$die Frau$p$,$p$la mujer$p$,402,'n'),
 ('a7451953-18af-59fd-bfe7-918991d9a53f','20000000-0000-0000-0000-000000000005',$p$das Kind$p$,$p$el niño$p$,403,'n'),
 ('89381a95-6dd2-5ec8-9d60-8f0ae6249665','20000000-0000-0000-0000-000000000005',$p$das Buch$p$,$p$el libro$p$,404,'n'),
 ('776d8393-16ec-5554-ac49-1fcb70df1099','20000000-0000-0000-0000-000000000005',$p$der Freund$p$,$p$el amigo$p$,405,'n'),
 ('d0e45018-8c4b-589e-820f-048a2d80b5fc','20000000-0000-0000-0000-000000000005',$p$die Kollegin$p$,$p$la colega$p$,406,'n'),
 ('8a8787e0-d796-5445-a819-d9b17bc7e9ad','20000000-0000-0000-0000-000000000005',$p$das Auto$p$,$p$el coche$p$,407,'n'),
 ('6f7e0f99-7aab-5918-8bd6-0fa9b93a708f','20000000-0000-0000-0000-000000000005',$p$die Wohnung$p$,$p$el piso$p$,408,'n'),
 ('6ae481c5-90be-56a1-abc7-9a249c507c45','20000000-0000-0000-0000-000000000005',$p$der Film$p$,$p$la película$p$,409,'n'),
 ('337095a9-dfb4-5574-8571-231ce4a7b2ed','20000000-0000-0000-0000-000000000005',$p$die Stadt$p$,$p$la ciudad$p$,410,'n'),
 ('cad44ace-4ed5-5227-b2e7-4c1e15ae4974','20000000-0000-0000-0000-000000000005',$p$das Handy$p$,$p$el móvil$p$,411,'n'),
 ('0539ae7e-7e1a-5d20-9fc1-bf39f4d39e0d','20000000-0000-0000-0000-000000000005',$p$der Lehrer$p$,$p$el profesor$p$,412,'n'),
 ('1d44feec-2b58-5948-9480-b2d6b1df54ac','20000000-0000-0000-0000-000000000005',$p$die Nachbarin$p$,$p$la vecina$p$,413,'n'),
 ('c861a913-eac7-5133-94bc-a74d848d7f84','20000000-0000-0000-0000-000000000005',$p$das Restaurant$p$,$p$el restaurante$p$,414,'n'),
 ('7ba2443e-2c3d-580d-8638-67aed6927962','20000000-0000-0000-0000-000000000005',$p$der Zug$p$,$p$el tren$p$,415,'n'),
 ('8badef5a-991b-5f26-8448-7005a8f0a2a8','20000000-0000-0000-0000-000000000005',$p$die Geschichte$p$,$p$la historia$p$,416,'n')
on conflict (id) do nothing;

-- ── Unidad 16 (B1·de): La voz pasiva (werden + Partizip) ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('bdc8673f-fd72-54a5-8147-b909b43b6035','20000000-0000-0000-0000-000000000005','B1',16,$p$La voz pasiva (werden + Partizip)$p$,'#B9770E','settings')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('d1d918f6-8c77-5a07-a04c-8c2b540a361b','bdc8673f-fd72-54a5-8147-b909b43b6035',1,$p$Präsens Passiv: wird + Partizip II$p$,$p$Präsens Passiv: wird + Partizip II$p$,'lesson',15),
 ('5af02dd7-e193-5af0-b827-6774e1c9b056','bdc8673f-fd72-54a5-8147-b909b43b6035',2,$p$El agente con von + Dativ$p$,$p$El agente con von + Dativ$p$,'lesson',15),
 ('51fb1f9c-b1ea-5dd1-aeb4-b907c44187e1','bdc8673f-fd72-54a5-8147-b909b43b6035',3,$p$Präteritum Passiv: wurde + Partizip II$p$,$p$Präteritum Passiv: wurde + Partizip II$p$,'lesson',15),
 ('8d8068fa-d59f-5a41-a82f-bf60229f3353','bdc8673f-fd72-54a5-8147-b909b43b6035',4,$p$Activa frente a pasiva$p$,$p$Activa frente a pasiva$p$,'lesson',15),
 ('470b07b1-5f3a-51c8-8036-24d0a5bb165b','bdc8673f-fd72-54a5-8147-b909b43b6035',5,$p$🏁 Checkpoint Einheit 16$p$,$p$Forma la voz pasiva en presente y pasado con werden/wurde + Partizip II y el agente con von + dativo.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('3375883c-9f9b-5ecb-a77d-d4d608bdaf7c','20000000-0000-0000-0000-000000000005','checkpoint','B1','bdc8673f-fd72-54a5-8147-b909b43b6035',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('6a4b4c16-8ff4-5724-8cde-44a258477aef'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','reading','match',$p$Relaciona cada palabra alemana con su significado en español.$p$,$j${"pairs": [{"en": "die Fabrik", "es": "la fábrica"}, {"en": "der Vertrag", "es": "el contrato"}, {"en": "reparieren", "es": "reparar"}]}$j$::jsonb,$j${"pairs": [["die Fabrik", "la fábrica"], ["der Vertrag", "el contrato"], ["reparieren", "reparar"]]}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$unidad16_l1$p$, $p$reading$p$]),
('db329928-39cd-5f90-a62b-31669793bd0d'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','reading','multiple_choice',$p$¿Cuál es la forma correcta de la voz pasiva en presente? «La casa se construye.»$p$,$j${"options": ["Das Haus wird gebaut.", "Das Haus wird bauen.", "Das Haus ist gebaut."]}$j$::jsonb,$j${"value": "Das Haus wird gebaut."}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$unidad16_l1$p$, $p$reading$p$]),
('ee2350f4-d50f-5d48-baef-843b7ac6ec8f'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','reading','multiple_choice',$p$Elige la frase pasiva correcta. «Los coches se fabrican aquí.»$p$,$j${"options": ["Die Autos werden hier hergestellt.", "Die Autos wird hier hergestellt.", "Die Autos werden hier herstellen."]}$j$::jsonb,$j${"value": "Die Autos werden hier hergestellt."}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$unidad16_l1$p$, $p$reading$p$]),
('99904258-90f6-5eb9-95ff-d349afcae647'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','writing','cloze',$p$Completa con la forma correcta de werden (presente). «El puente ___ reparado.»$p$,$j${"text": "Die Brücke ___ repariert."}$j$::jsonb,$j${"value": "wird", "accepted": ["wird"]}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$unidad16_l1$p$, $p$writing$p$]),
('9fe70737-5a2a-5780-8e36-a6a4798f2a87'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','writing','cloze',$p$Completa con el participio II correcto de «schreiben». «La carta es escrita.»$p$,$j${"text": "Der Brief wird ___."}$j$::jsonb,$j${"value": "geschrieben", "accepted": ["geschrieben"]}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$unidad16_l1$p$, $p$writing$p$]),
('1c90ce99-a907-5fb6-8bfb-9341be6b9ef3'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','writing','word_bank',$p$Ordena las fichas para formar: «El contrato es firmado.» (presente pasivo)$p$,$j${"tiles": ["Der", "Vertrag", "wird", "unterschrieben", "wurde", "ist"]}$j$::jsonb,$j${"value": "Der Vertrag wird unterschrieben", "sequence": ["Der", "Vertrag", "wird", "unterschrieben"]}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$unidad16_l1$p$, $p$writing$p$]),
('cf12c8eb-8795-5522-a768-ce3de4acb2f8'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','reading','multiple_choice',$p$¿Qué caso rige «von» para introducir al agente en la pasiva?$p$,$j${"options": ["Dativ (von + dativo)", "Akkusativ (von + acusativo)", "Genitiv (von + genitivo)"]}$j$::jsonb,$j${"value": "Dativ (von + dativo)"}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$unidad16_l2$p$, $p$reading$p$]),
('da18088a-a34f-5fd6-af59-d6a8615045f4'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','writing','cloze',$p$Completa con von + el artículo dativo correcto. «La factura es pagada por el cliente (der Kunde).»$p$,$j${"text": "Die Rechnung wird ___ Kunden bezahlt."}$j$::jsonb,$j${"value": "von dem", "accepted": ["von dem", "vom"]}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$unidad16_l2$p$, $p$writing$p$]),
('6ef44045-2334-50a5-b686-7648381dcb10'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','writing','translation',$p$Traduce al alemán (presente pasivo con agente): «El libro es leído por el autor.»$p$,$j${"source": "El libro es leído por el autor."}$j$::jsonb,$j${"value": "Das Buch wird von dem Autor gelesen.", "accepted": ["Das Buch wird von dem Autor gelesen.", "Das Buch wird von dem Autor gelesen", "Das Buch wird vom Autor gelesen.", "Das Buch wird vom Autor gelesen"]}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$unidad16_l2$p$, $p$writing$p$]),
('db4bf981-d587-5003-9292-27abe313d864'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','reading','multiple_choice',$p$¿Cuál es la voz pasiva en pasado (Präteritum)? «La casa fue construida.»$p$,$j${"options": ["Das Haus wurde gebaut.", "Das Haus wird gebaut.", "Das Haus war gebaut."]}$j$::jsonb,$j${"value": "Das Haus wurde gebaut."}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$unidad16_l3$p$, $p$reading$p$]),
('02991946-99d2-5a95-beaf-329e8a3acf8d'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','writing','cloze',$p$Completa con la forma de werden en Präteritum. «La fábrica fue fundada en 1990.»$p$,$j${"text": "Die Fabrik ___ 1990 gegründet."}$j$::jsonb,$j${"value": "wurde", "accepted": ["wurde"]}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$unidad16_l3$p$, $p$writing$p$]),
('1f96cb07-828b-577e-8f14-2727215ed0b1'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','reading','multiple_choice',$p$Una frase está en ACTIVA y la otra en PASIVA. ¿Cuál es la PASIVA?$p$,$j${"options": ["Das Haus wird von dem Arbeiter gebaut.", "Der Arbeiter baut das Haus.", "Der Arbeiter hat das Haus gebaut."]}$j$::jsonb,$j${"value": "Das Haus wird von dem Arbeiter gebaut."}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$unidad16_l4$p$, $p$reading$p$]),
('6acebeba-172e-5d70-8469-8ede26b1baf1'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Das Haus wird gebaut.", "Das Haus wurde gebaut.", "Das Haus ist gebaut."], "say": "Das Haus wird gebaut.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/6acebeba-172e-5d70-8469-8ede26b1baf1.mp3"}$j$::jsonb,$j${"value": "Das Haus wird gebaut."}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$unidad16_l1$p$, $p$listening$p$]),
('0de38178-3ae3-53fd-a63e-fe65277a91b4'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Die Brücke wurde repariert.", "Die Brücke wird repariert.", "Die Brücke ist repariert."], "say": "Die Brücke wurde repariert.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/0de38178-3ae3-53fd-a63e-fe65277a91b4.mp3"}$j$::jsonb,$j${"value": "Die Brücke wurde repariert."}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$unidad16_l3$p$, $p$listening$p$]),
('33c2e2ed-96b6-573f-acfb-f4e29920a78b'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','listening','listening',$p$Escucha la frase pasiva con agente y elige la que oíste.$p$,$j${"options": ["Das Buch wird von dem Autor geschrieben.", "Das Buch wird von dem Autor gelesen.", "Das Buch wurde von dem Autor geschrieben."], "say": "Das Buch wird von dem Autor geschrieben.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/33c2e2ed-96b6-573f-acfb-f4e29920a78b.mp3"}$j$::jsonb,$j${"value": "Das Buch wird von dem Autor geschrieben."}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$unidad16_l2$p$, $p$listening$p$]),
('c9738e36-3150-5ab0-a54e-5b4b69b2b5ea'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Die Fabrik wurde 1990 gegründet.", "Die Fabrik wird 1990 gegründet.", "Die Fabrik ist 1990 gegründet."], "say": "Die Fabrik wurde 1990 gegründet.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/c9738e36-3150-5ab0-a54e-5b4b69b2b5ea.mp3"}$j$::jsonb,$j${"value": "Die Fabrik wurde 1990 gegründet."}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$unidad16_l3$p$, $p$listening$p$]),
('1e259102-2a08-50db-ab7b-857e113d5b95'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Das Haus wird von dem Arbeiter gebaut.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/1e259102-2a08-50db-ab7b-857e113d5b95.mp3"}$j$::jsonb,$j${"expected": "Das Haus wird von dem Arbeiter gebaut."}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$unidad16_l2$p$, $p$speaking$p$]),
('424d36f8-a1c6-52f1-8e85-5aca9133c138'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Die Rechnung wurde gestern bezahlt.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/424d36f8-a1c6-52f1-8e85-5aca9133c138.mp3"}$j$::jsonb,$j${"expected": "Die Rechnung wurde gestern bezahlt."}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$unidad16_l3$p$, $p$speaking$p$]),
('0382f326-f03c-5029-af55-2fcb2278cd42'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Der Vertrag wird von dem Chef unterschrieben.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/0382f326-f03c-5029-af55-2fcb2278cd42.mp3"}$j$::jsonb,$j${"expected": "Der Vertrag wird von dem Chef unterschrieben."}$j$::jsonb,0.52,ARRAY[$p$unidad16$p$, $p$unidad16_l4$p$, $p$speaking$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('d1d918f6-8c77-5a07-a04c-8c2b540a361b','6a4b4c16-8ff4-5724-8cde-44a258477aef',1),
 ('d1d918f6-8c77-5a07-a04c-8c2b540a361b','db329928-39cd-5f90-a62b-31669793bd0d',2),
 ('d1d918f6-8c77-5a07-a04c-8c2b540a361b','ee2350f4-d50f-5d48-baef-843b7ac6ec8f',3),
 ('d1d918f6-8c77-5a07-a04c-8c2b540a361b','99904258-90f6-5eb9-95ff-d349afcae647',4),
 ('d1d918f6-8c77-5a07-a04c-8c2b540a361b','9fe70737-5a2a-5780-8e36-a6a4798f2a87',5),
 ('d1d918f6-8c77-5a07-a04c-8c2b540a361b','1c90ce99-a907-5fb6-8bfb-9341be6b9ef3',6),
 ('d1d918f6-8c77-5a07-a04c-8c2b540a361b','6acebeba-172e-5d70-8469-8ede26b1baf1',7),
 ('5af02dd7-e193-5af0-b827-6774e1c9b056','cf12c8eb-8795-5522-a768-ce3de4acb2f8',1),
 ('5af02dd7-e193-5af0-b827-6774e1c9b056','da18088a-a34f-5fd6-af59-d6a8615045f4',2),
 ('5af02dd7-e193-5af0-b827-6774e1c9b056','6ef44045-2334-50a5-b686-7648381dcb10',3),
 ('5af02dd7-e193-5af0-b827-6774e1c9b056','33c2e2ed-96b6-573f-acfb-f4e29920a78b',4),
 ('5af02dd7-e193-5af0-b827-6774e1c9b056','1e259102-2a08-50db-ab7b-857e113d5b95',5),
 ('51fb1f9c-b1ea-5dd1-aeb4-b907c44187e1','db4bf981-d587-5003-9292-27abe313d864',1),
 ('51fb1f9c-b1ea-5dd1-aeb4-b907c44187e1','02991946-99d2-5a95-beaf-329e8a3acf8d',2),
 ('51fb1f9c-b1ea-5dd1-aeb4-b907c44187e1','0de38178-3ae3-53fd-a63e-fe65277a91b4',3),
 ('51fb1f9c-b1ea-5dd1-aeb4-b907c44187e1','c9738e36-3150-5ab0-a54e-5b4b69b2b5ea',4),
 ('51fb1f9c-b1ea-5dd1-aeb4-b907c44187e1','424d36f8-a1c6-52f1-8e85-5aca9133c138',5),
 ('8d8068fa-d59f-5a41-a82f-bf60229f3353','1f96cb07-828b-577e-8f14-2727215ed0b1',1),
 ('8d8068fa-d59f-5a41-a82f-bf60229f3353','0382f326-f03c-5029-af55-2fcb2278cd42',2),
 ('470b07b1-5f3a-51c8-8036-24d0a5bb165b','6a4b4c16-8ff4-5724-8cde-44a258477aef',1),
 ('470b07b1-5f3a-51c8-8036-24d0a5bb165b','db329928-39cd-5f90-a62b-31669793bd0d',2),
 ('470b07b1-5f3a-51c8-8036-24d0a5bb165b','ee2350f4-d50f-5d48-baef-843b7ac6ec8f',3),
 ('470b07b1-5f3a-51c8-8036-24d0a5bb165b','99904258-90f6-5eb9-95ff-d349afcae647',4),
 ('470b07b1-5f3a-51c8-8036-24d0a5bb165b','9fe70737-5a2a-5780-8e36-a6a4798f2a87',5),
 ('470b07b1-5f3a-51c8-8036-24d0a5bb165b','1c90ce99-a907-5fb6-8bfb-9341be6b9ef3',6),
 ('470b07b1-5f3a-51c8-8036-24d0a5bb165b','6acebeba-172e-5d70-8469-8ede26b1baf1',7),
 ('470b07b1-5f3a-51c8-8036-24d0a5bb165b','0de38178-3ae3-53fd-a63e-fe65277a91b4',8),
 ('470b07b1-5f3a-51c8-8036-24d0a5bb165b','1e259102-2a08-50db-ab7b-857e113d5b95',9),
 ('470b07b1-5f3a-51c8-8036-24d0a5bb165b','424d36f8-a1c6-52f1-8e85-5aca9133c138',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('e7848ad8-7bd7-5b9a-9dd7-c67f7fee433e','20000000-0000-0000-0000-000000000005',$p$die Fabrik$p$,$p$la fábrica$p$,421,'sustantivo'),
 ('860aba75-adce-56a9-86b7-94fac07bb02f','20000000-0000-0000-0000-000000000005',$p$die Brücke$p$,$p$el puente$p$,422,'sustantivo'),
 ('e66781c5-74ca-553e-b0e8-c4eda6d86d33','20000000-0000-0000-0000-000000000005',$p$der Brief$p$,$p$la carta$p$,423,'sustantivo'),
 ('947e3f94-4555-5d0b-961f-b4c77fd7c112','20000000-0000-0000-0000-000000000005',$p$das Paket$p$,$p$el paquete$p$,424,'sustantivo'),
 ('73ce5df8-badb-50a8-ac4d-32260a9d78a1','20000000-0000-0000-0000-000000000005',$p$der Vertrag$p$,$p$el contrato$p$,425,'sustantivo'),
 ('e0637792-5508-55f8-b23c-bff1d0e6c4a3','20000000-0000-0000-0000-000000000005',$p$die Rechnung$p$,$p$la factura$p$,426,'sustantivo'),
 ('5ec651bc-ddf9-5d68-92c5-01ee76472464','20000000-0000-0000-0000-000000000005',$p$der Arbeiter$p$,$p$el obrero$p$,427,'sustantivo'),
 ('c5e9d206-782b-50c4-8eea-093eba886c21','20000000-0000-0000-0000-000000000005',$p$der Autor$p$,$p$el autor$p$,428,'sustantivo'),
 ('cb6c54be-4602-5098-b4ca-6966771a434e','20000000-0000-0000-0000-000000000005',$p$die Maschine$p$,$p$la máquina$p$,429,'sustantivo'),
 ('4a214394-64b1-5ec9-bc47-d6e971e31ebc','20000000-0000-0000-0000-000000000005',$p$das Ergebnis$p$,$p$el resultado$p$,430,'sustantivo'),
 ('6c38eb21-656f-56b2-9df8-7c41d2904696','20000000-0000-0000-0000-000000000005',$p$bauen$p$,$p$construir$p$,431,'verbo'),
 ('886819cc-947c-5e01-b525-f923b4a44ff5','20000000-0000-0000-0000-000000000005',$p$reparieren$p$,$p$reparar$p$,432,'verbo'),
 ('bb65493c-28bf-5083-a9ee-86bf00499ca6','20000000-0000-0000-0000-000000000005',$p$liefern$p$,$p$entregar$p$,433,'verbo'),
 ('c32478fb-f7b0-5cfa-b8c0-44f7ff9b3a73','20000000-0000-0000-0000-000000000005',$p$unterschreiben$p$,$p$firmar$p$,434,'verbo'),
 ('dd435394-9d8d-561e-bb42-c665c22072c5','20000000-0000-0000-0000-000000000005',$p$herstellen$p$,$p$fabricar$p$,435,'verbo'),
 ('7ab53dea-47ab-538b-92ad-d4c9f8041d21','20000000-0000-0000-0000-000000000005',$p$gegründet$p$,$p$fundado$p$,436,'participio')
on conflict (id) do nothing;

-- ── Unidad 17 (B1·de): Verbos con preposición y el genitivo ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('9b40f0fd-f006-508a-b712-02e8aeaf2175','20000000-0000-0000-0000-000000000005','B1',17,$p$Verbos con preposición y el genitivo$p$,'#922B21','alternate_email')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('d8262b88-9354-59f9-a428-8bd44bcf0781','9b40f0fd-f006-508a-b712-02e8aeaf2175',1,$p$Esperar, pensar, alegrarse (auf/an)$p$,$p$Esperar, pensar, alegrarse (auf/an)$p$,'lesson',15),
 ('657bc5d7-128c-54b9-80e4-41a764a792a7','9b40f0fd-f006-508a-b712-02e8aeaf2175',2,$p$Interesarse, tener miedo, hablar (für/vor/über)$p$,$p$Interesarse, tener miedo, hablar (für/vor/über)$p$,'lesson',15),
 ('f9e38d57-2079-590c-a3cc-efbbc6bc7dfe','9b40f0fd-f006-508a-b712-02e8aeaf2175',3,$p$El genitivo de posesión (-s)$p$,$p$El genitivo de posesión (-s)$p$,'lesson',15),
 ('a6776b2f-b3d7-5866-b741-682db652036a','9b40f0fd-f006-508a-b712-02e8aeaf2175',4,$p$Todo junto: preposición, caso y genitivo$p$,$p$Todo junto: preposición, caso y genitivo$p$,'lesson',15),
 ('04e8fad2-b0d0-53b8-9bb4-fef940ce7d9c','9b40f0fd-f006-508a-b712-02e8aeaf2175',5,$p$🏁 Checkpoint Einheit 17$p$,$p$Demuestra que dominas los verbos con preposición fija (con su caso) y el genitivo de posesión.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('a1068979-8e95-5748-8c6f-98444b76a3c9','20000000-0000-0000-0000-000000000005','checkpoint','B1','9b40f0fd-f006-508a-b712-02e8aeaf2175',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('ae44969e-06b0-5269-9827-f8169bdebf93'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','reading','match',$p$Une cada verbo con su preposición fija.$p$,$j${"pairs": [{"en": "warten auf", "es": "esperar (algo/a alguien)"}, {"en": "denken an", "es": "pensar en"}, {"en": "sich freuen auf", "es": "alegrarse (por algo futuro)"}]}$j$::jsonb,$j${"pairs": [["warten auf", "esperar (algo/a alguien)"], ["denken an", "pensar en"], ["sich freuen auf", "alegrarse (por algo futuro)"]]}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$unidad17_l1$p$, $p$reading$p$]),
('95058b27-0f43-5782-b3f1-c17a24028a6e'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','reading','multiple_choice',$p$Elige la preposición correcta: «Ich warte ___ den Bus.» (Espero el autobús.)$p$,$j${"options": ["auf", "an", "für"]}$j$::jsonb,$j${"value": "auf"}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$unidad17_l1$p$, $p$reading$p$]),
('3345be28-2070-569d-ac0b-d31c2058e2d2'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','writing','cloze',$p$Completa con la preposición correcta: esperar el autobús.$p$,$j${"text": "Ich warte ___ den Bus."}$j$::jsonb,$j${"value": "auf", "accepted": ["auf"]}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$unidad17_l1$p$, $p$writing$p$]),
('701a00a4-ff1f-5ae6-bb79-bce87597a0aa'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','writing','cloze',$p$Completa con la preposición correcta: pensar en el examen.$p$,$j${"text": "Ich denke oft ___ die Prüfung."}$j$::jsonb,$j${"value": "an", "accepted": ["an"]}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$unidad17_l1$p$, $p$writing$p$]),
('8467761c-4337-5e13-b2ea-00114a48395a'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','writing','translation',$p$Traduce: Me alegro por el viaje.$p$,$j${"source": "Me alegro por el viaje."}$j$::jsonb,$j${"value": "Ich freue mich auf die Reise.", "accepted": ["Ich freue mich auf die Reise", "Ich freue mich auf die Reise.", "Ich freue mich auf die Reise!"]}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$unidad17_l1$p$, $p$writing$p$]),
('143b04d1-b1fd-5547-a039-22120a89c71e'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Wir warten auf den Zug.", "Wir warten an den Zug.", "Wir warten für den Zug."], "say": "Wir warten auf den Zug.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/143b04d1-b1fd-5547-a039-22120a89c71e.mp3"}$j$::jsonb,$j${"value": "Wir warten auf den Zug."}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$unidad17_l1$p$, $p$listening$p$]),
('4dcce452-e84f-5f26-a52a-f0d37c822e47'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Ich denke an dich und freue mich auf das Wochenende.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/4dcce452-e84f-5f26-a52a-f0d37c822e47.mp3"}$j$::jsonb,$j${"expected": "Ich denke an dich und freue mich auf das Wochenende."}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$unidad17_l1$p$, $p$speaking$p$]),
('68604eaa-7f34-59fd-b7df-6e2339dcb5f4'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','reading','multiple_choice',$p$Elige la preposición correcta: «Ich interessiere mich ___ Musik.» (Me intereso por la música.)$p$,$j${"options": ["für", "auf", "an"]}$j$::jsonb,$j${"value": "für"}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$unidad17_l2$p$, $p$reading$p$]),
('d976c0ae-c26c-555f-a721-8a1bf91c1f80'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','reading','multiple_choice',$p$Elige la preposición correcta: «Ich habe Angst ___ dem Gewitter.» (Tengo miedo a la tormenta.)$p$,$j${"options": ["vor", "für", "auf"]}$j$::jsonb,$j${"value": "vor"}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$unidad17_l2$p$, $p$reading$p$]),
('d6ea0dca-34d5-52b6-8f55-8dafebe20252'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','writing','word_bank',$p$Ordena para formar: «Me intereso por la política.»$p$,$j${"tiles": ["Ich", "interessiere", "mich", "für", "Politik", "auf", "an"]}$j$::jsonb,$j${"value": "Ich interessiere mich für Politik", "sequence": ["Ich", "interessiere", "mich", "für", "Politik"]}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$unidad17_l2$p$, $p$writing$p$]),
('81abee80-482a-5a5a-8248-eb0e9994caee'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Sie spricht über ihre Zukunft.", "Sie spricht für ihre Zukunft.", "Sie spricht auf ihre Zukunft."], "say": "Sie spricht über ihre Zukunft.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/81abee80-482a-5a5a-8248-eb0e9994caee.mp3"}$j$::jsonb,$j${"value": "Sie spricht über ihre Zukunft."}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$unidad17_l2$p$, $p$listening$p$]),
('8a81ff1c-8ffb-5e3b-a799-7fa786eb4a5c'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','reading','match',$p$Une cada genitivo con su traducción.$p$,$j${"pairs": [{"en": "der Titel des Buches", "es": "el título del libro"}, {"en": "das Auto meiner Schwester", "es": "el coche de mi hermana"}, {"en": "das Ende des Films", "es": "el final de la película"}]}$j$::jsonb,$j${"pairs": [["der Titel des Buches", "el título del libro"], ["das Auto meiner Schwester", "el coche de mi hermana"], ["das Ende des Films", "el final de la película"]]}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$unidad17_l3$p$, $p$reading$p$]),
('76dea73b-483f-5102-baf2-b15f96fc4dbc'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','reading','multiple_choice',$p$Elige el genitivo correcto: «Das ist das Auto ___.» (Es el coche de mi hermana.)$p$,$j${"options": ["meiner Schwester", "meine Schwester", "meinem Schwester"]}$j$::jsonb,$j${"value": "meiner Schwester"}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$unidad17_l3$p$, $p$reading$p$]),
('eebeb9b2-8900-5355-be4e-155918c16a6c'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','writing','cloze',$p$Completa el genitivo (masc./neutro lleva -s): el título del libro.$p$,$j${"text": "Ich mag den Titel des Buch___."}$j$::jsonb,$j${"value": "es", "accepted": ["es"]}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$unidad17_l3$p$, $p$writing$p$]),
('c87c2638-30fa-5f8e-899d-74c505e06b3e'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','writing','reorder',$p$Ordena para formar: «El coche de mi amigo es nuevo.»$p$,$j${"tiles": ["Das", "Auto", "meines", "Freundes", "ist", "neu", "meiner"]}$j$::jsonb,$j${"value": "Das Auto meines Freundes ist neu"}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$unidad17_l3$p$, $p$writing$p$]),
('1cedce80-e538-51ac-ac6a-d0b7e9075f8b'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Der Titel des Buches gefällt mir, aber das Ende ist traurig.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/1cedce80-e538-51ac-ac6a-d0b7e9075f8b.mp3"}$j$::jsonb,$j${"expected": "Der Titel des Buches gefällt mir, aber das Ende ist traurig."}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$unidad17_l3$p$, $p$speaking$p$]),
('9c968bb5-6064-5e71-8f26-2d0a1c112711'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Das ist das Haus meines Vaters.", "Das ist das Haus mein Vater.", "Das ist das Haus meinem Vater."], "say": "Das ist das Haus meines Vaters.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/9c968bb5-6064-5e71-8f26-2d0a1c112711.mp3"}$j$::jsonb,$j${"value": "Das ist das Haus meines Vaters."}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$unidad17_l4$p$, $p$listening$p$]),
('2eae3afd-0681-5436-973e-09316e062d31'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Ich interessiere mich für die Zukunft meiner Stadt.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/2eae3afd-0681-5436-973e-09316e062d31.mp3"}$j$::jsonb,$j${"expected": "Ich interessiere mich für die Zukunft meiner Stadt."}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$unidad17_l4$p$, $p$speaking$p$]),
('35df68bd-2d0a-57ef-8092-f878a2ee0f75'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','listening','listening',$p$Escucha y elige la frase que oíste.$p$,$j${"options": ["Ich freue mich auf das Ende der Prüfung.", "Ich freue mich über das Ende der Prüfung.", "Ich freue mich an das Ende der Prüfung."], "say": "Ich freue mich auf das Ende der Prüfung.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/35df68bd-2d0a-57ef-8092-f878a2ee0f75.mp3"}$j$::jsonb,$j${"value": "Ich freue mich auf das Ende der Prüfung."}$j$::jsonb,0.52,ARRAY[$p$unidad17$p$, $p$unidad17_l4$p$, $p$listening$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('d8262b88-9354-59f9-a428-8bd44bcf0781','ae44969e-06b0-5269-9827-f8169bdebf93',1),
 ('d8262b88-9354-59f9-a428-8bd44bcf0781','95058b27-0f43-5782-b3f1-c17a24028a6e',2),
 ('d8262b88-9354-59f9-a428-8bd44bcf0781','3345be28-2070-569d-ac0b-d31c2058e2d2',3),
 ('d8262b88-9354-59f9-a428-8bd44bcf0781','701a00a4-ff1f-5ae6-bb79-bce87597a0aa',4),
 ('d8262b88-9354-59f9-a428-8bd44bcf0781','8467761c-4337-5e13-b2ea-00114a48395a',5),
 ('d8262b88-9354-59f9-a428-8bd44bcf0781','143b04d1-b1fd-5547-a039-22120a89c71e',6),
 ('d8262b88-9354-59f9-a428-8bd44bcf0781','4dcce452-e84f-5f26-a52a-f0d37c822e47',7),
 ('657bc5d7-128c-54b9-80e4-41a764a792a7','68604eaa-7f34-59fd-b7df-6e2339dcb5f4',1),
 ('657bc5d7-128c-54b9-80e4-41a764a792a7','d976c0ae-c26c-555f-a721-8a1bf91c1f80',2),
 ('657bc5d7-128c-54b9-80e4-41a764a792a7','d6ea0dca-34d5-52b6-8f55-8dafebe20252',3),
 ('657bc5d7-128c-54b9-80e4-41a764a792a7','81abee80-482a-5a5a-8248-eb0e9994caee',4),
 ('f9e38d57-2079-590c-a3cc-efbbc6bc7dfe','8a81ff1c-8ffb-5e3b-a799-7fa786eb4a5c',1),
 ('f9e38d57-2079-590c-a3cc-efbbc6bc7dfe','76dea73b-483f-5102-baf2-b15f96fc4dbc',2),
 ('f9e38d57-2079-590c-a3cc-efbbc6bc7dfe','eebeb9b2-8900-5355-be4e-155918c16a6c',3),
 ('f9e38d57-2079-590c-a3cc-efbbc6bc7dfe','c87c2638-30fa-5f8e-899d-74c505e06b3e',4),
 ('f9e38d57-2079-590c-a3cc-efbbc6bc7dfe','1cedce80-e538-51ac-ac6a-d0b7e9075f8b',5),
 ('a6776b2f-b3d7-5866-b741-682db652036a','9c968bb5-6064-5e71-8f26-2d0a1c112711',1),
 ('a6776b2f-b3d7-5866-b741-682db652036a','2eae3afd-0681-5436-973e-09316e062d31',2),
 ('a6776b2f-b3d7-5866-b741-682db652036a','35df68bd-2d0a-57ef-8092-f878a2ee0f75',3),
 ('04e8fad2-b0d0-53b8-9bb4-fef940ce7d9c','ae44969e-06b0-5269-9827-f8169bdebf93',1),
 ('04e8fad2-b0d0-53b8-9bb4-fef940ce7d9c','95058b27-0f43-5782-b3f1-c17a24028a6e',2),
 ('04e8fad2-b0d0-53b8-9bb4-fef940ce7d9c','68604eaa-7f34-59fd-b7df-6e2339dcb5f4',3),
 ('04e8fad2-b0d0-53b8-9bb4-fef940ce7d9c','3345be28-2070-569d-ac0b-d31c2058e2d2',4),
 ('04e8fad2-b0d0-53b8-9bb4-fef940ce7d9c','701a00a4-ff1f-5ae6-bb79-bce87597a0aa',5),
 ('04e8fad2-b0d0-53b8-9bb4-fef940ce7d9c','8467761c-4337-5e13-b2ea-00114a48395a',6),
 ('04e8fad2-b0d0-53b8-9bb4-fef940ce7d9c','143b04d1-b1fd-5547-a039-22120a89c71e',7),
 ('04e8fad2-b0d0-53b8-9bb4-fef940ce7d9c','81abee80-482a-5a5a-8248-eb0e9994caee',8),
 ('04e8fad2-b0d0-53b8-9bb4-fef940ce7d9c','4dcce452-e84f-5f26-a52a-f0d37c822e47',9),
 ('04e8fad2-b0d0-53b8-9bb4-fef940ce7d9c','1cedce80-e538-51ac-ac6a-d0b7e9075f8b',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('1a49fee8-d141-5eff-ac68-6090b03d621d','20000000-0000-0000-0000-000000000005',$p$der Bus$p$,$p$el autobús$p$,441,'sustantivo'),
 ('878a7230-0e30-5b50-be26-92478ea99584','20000000-0000-0000-0000-000000000005',$p$die Prüfung$p$,$p$el examen$p$,442,'sustantivo'),
 ('cf592dd7-3a3a-596d-bb75-8a2382c1c848','20000000-0000-0000-0000-000000000005',$p$die Reise$p$,$p$el viaje$p$,443,'sustantivo'),
 ('509817ba-9df2-5a4f-9c32-c532276e8059','20000000-0000-0000-0000-000000000005',$p$die Zukunft$p$,$p$el futuro$p$,444,'sustantivo'),
 ('8ac0818a-af76-59d8-9d3f-bf76dd1f56e3','20000000-0000-0000-0000-000000000005',$p$die Musik$p$,$p$la música$p$,445,'sustantivo'),
 ('36d1df7d-b9c7-5d0d-a61c-128dadbf1bc1','20000000-0000-0000-0000-000000000005',$p$die Angst$p$,$p$el miedo$p$,446,'sustantivo'),
 ('b2d99214-c628-5f84-b6a4-16ec235868db','20000000-0000-0000-0000-000000000005',$p$das Gewitter$p$,$p$la tormenta$p$,447,'sustantivo'),
 ('d1331b69-71b3-59dc-bf95-d9e1f3f06822','20000000-0000-0000-0000-000000000005',$p$das Problem$p$,$p$el problema$p$,448,'sustantivo'),
 ('a994982e-cf4b-565c-999a-ac512c9dfb9f','20000000-0000-0000-0000-000000000005',$p$der Titel$p$,$p$el título$p$,449,'sustantivo'),
 ('7e2b68f1-21db-55ff-aea2-b4fbe69916f1','20000000-0000-0000-0000-000000000005',$p$das Buch$p$,$p$el libro$p$,450,'sustantivo'),
 ('e0df0ada-1ee5-5f50-8f8f-984111ba5510','20000000-0000-0000-0000-000000000005',$p$das Auto$p$,$p$el coche$p$,451,'sustantivo'),
 ('d7678bc8-1ae8-5368-a5a9-eaf61cd2a98a','20000000-0000-0000-0000-000000000005',$p$die Schwester$p$,$p$la hermana$p$,452,'sustantivo'),
 ('4e24899d-c7cc-592c-bcd4-b65d1642107f','20000000-0000-0000-0000-000000000005',$p$der Freund$p$,$p$el amigo$p$,453,'sustantivo'),
 ('4225d78c-63ab-552e-8584-5fcd6a742e3c','20000000-0000-0000-0000-000000000005',$p$das Ende$p$,$p$el final$p$,454,'sustantivo'),
 ('c3c64d23-5882-56a6-8efb-e2031567637d','20000000-0000-0000-0000-000000000005',$p$warten$p$,$p$esperar$p$,455,'verbo'),
 ('209e0d5a-1de6-598e-8275-921f492cd554','20000000-0000-0000-0000-000000000005',$p$sich freuen$p$,$p$alegrarse$p$,456,'verbo')
on conflict (id) do nothing;

-- ── Unidad 18 (B1·de): Lo que habría pasado (condicional irreal) ──
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
 ('db7a3f51-6453-540a-a2e7-fce034e07802','20000000-0000-0000-0000-000000000005','B1',18,$p$Lo que habría pasado (condicional irreal)$p$,'#4A235A','history_toggle_off')
on conflict (course_id, order_index) do update set title=excluded.title, cefr_level=excluded.cefr_level, theme_color=excluded.theme_color, icon=excluded.icon;
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
 ('96a90fa6-7fb0-512a-b946-428b273f9eb6','db7a3f51-6453-540a-a2e7-fce034e07802',1,$p$Wenn ich Zeit gehabt hätte … (condicional irreal del pasado)$p$,$p$Wenn ich Zeit gehabt hätte … (condicional irreal del pasado)$p$,'lesson',15),
 ('2c2e11b9-bfa1-51f5-bbe3-b0fcf2028da6','db7a3f51-6453-540a-a2e7-fce034e07802',2,$p$Ich wäre gekommen (hätte vs. wäre + Partizip II)$p$,$p$Ich wäre gekommen (hätte vs. wäre + Partizip II)$p$,'lesson',15),
 ('48004076-f89e-532f-afbe-74560934e70b','db7a3f51-6453-540a-a2e7-fce034e07802',3,$p$Ich hätte anrufen sollen (reproche: sollen/können)$p$,$p$Ich hätte anrufen sollen (reproche: sollen/können)$p$,'lesson',15),
 ('1a384401-1d1d-55d4-ab28-2340cb9f19a5','db7a3f51-6453-540a-a2e7-fce034e07802',4,$p$Repaso B1: presente irreal y frases subordinadas$p$,$p$Repaso B1: presente irreal y frases subordinadas$p$,'lesson',15),
 ('1e0b131c-1241-586e-8203-aa85bf26cb3c','db7a3f51-6453-540a-a2e7-fce034e07802',5,$p$🏁 Checkpoint Einheit 18$p$,$p$Expresa hipótesis y arrepentimientos sobre el pasado con Konjunktiv II (hätte/wäre + Partizip II) y condicionales irreales.$p$,'checkpoint',40)
on conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
 ('081daca8-1d0f-529c-8c57-c2081722c28f','20000000-0000-0000-0000-000000000005','checkpoint','B1','db7a3f51-6453-540a-a2e7-fce034e07802',300,0.80,$j${"skills": ["reading", "listening", "writing", "speaking"], "item_count": 10, "randomize": true}$j$::jsonb) on conflict (id) do nothing;
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('0fb81654-ec4f-5846-a536-dc2ec54f32b1'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','reading','match',$p$Une cada expresión alemana con su significado en español.$p$,$j${"pairs": [{"en": "Wenn ich Zeit gehabt hätte", "es": "Si hubiera tenido tiempo"}, {"en": "Das wäre besser gewesen", "es": "Eso habría sido mejor"}, {"en": "Ich hätte es gewusst", "es": "Lo habría sabido"}]}$j$::jsonb,$j${"pairs": [["Wenn ich Zeit gehabt hätte", "Si hubiera tenido tiempo"], ["Das wäre besser gewesen", "Eso habría sido mejor"], ["Ich hätte es gewusst", "Lo habría sabido"]]}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$unidad18_l1$p$, $p$reading$p$]),
('e8e305b1-eec7-53cc-ae2b-8ab7f804456f'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','reading','multiple_choice',$p$¿Cuál frase expresa correctamente 'Si hubiera tenido dinero, habría comprado el coche'?$p$,$j${"options": ["Wenn ich Geld gehabt hätte, hätte ich das Auto gekauft.", "Wenn ich Geld gehabt hätte, wäre ich das Auto gekauft.", "Wenn ich Geld hätte, hätte ich das Auto gekauft."]}$j$::jsonb,$j${"value": "Wenn ich Geld gehabt hätte, hätte ich das Auto gekauft."}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$unidad18_l1$p$, $p$reading$p$]),
('ba05868f-c369-5233-8435-77fc565c458e'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','writing','translation',$p$Traduce al alemán: 'Si hubiera tenido tiempo, habría ayudado.'$p$,$j${"source": "Si hubiera tenido tiempo, habría ayudado."}$j$::jsonb,$j${"value": "Wenn ich Zeit gehabt hätte, hätte ich geholfen.", "accepted": ["Wenn ich Zeit gehabt hätte, hätte ich geholfen", "Wenn ich Zeit gehabt hätte, hätte ich geholfen.", "Hätte ich Zeit gehabt, hätte ich geholfen.", "Hätte ich Zeit gehabt, hätte ich geholfen"]}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$unidad18_l1$p$, $p$writing$p$]),
('220ba7a3-f620-501d-85cf-86a79778e364'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','listening','listening',$p$Escucha y elige la frase correcta.$p$,$j${"options": ["Wenn das Wetter besser gewesen wäre, wären wir spazieren gegangen.", "Wenn das Wetter besser wäre, gehen wir spazieren.", "Wenn das Wetter besser gewesen wäre, hätten wir spazieren gegangen."], "say": "Wenn das Wetter besser gewesen wäre, wären wir spazieren gegangen.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/220ba7a3-f620-501d-85cf-86a79778e364.mp3"}$j$::jsonb,$j${"value": "Wenn das Wetter besser gewesen wäre, wären wir spazieren gegangen."}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$unidad18_l1$p$, $p$listening$p$]),
('96721918-729a-586e-a22f-b65235053972'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','reading','multiple_choice',$p$¿Qué auxiliar necesita 'kommen' en el condicional irreal del pasado? 'Yo habría venido.'$p$,$j${"options": ["Ich wäre gekommen.", "Ich hätte gekommen.", "Ich würde gekommen."]}$j$::jsonb,$j${"value": "Ich wäre gekommen."}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$unidad18_l2$p$, $p$reading$p$]),
('c4f1ccf8-b80f-5e05-bd28-2652aa6b9aa6'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','writing','cloze',$p$Completa con el auxiliar correcto (verbo de movimiento): 'Habríamos ido al cine.'$p$,$j${"text": "Wir ___ ins Kino gegangen."}$j$::jsonb,$j${"value": "wären", "accepted": ["wären"]}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$unidad18_l2$p$, $p$writing$p$]),
('47893a16-6853-5550-8943-f9575bbb71d9'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','writing','word_bank',$p$Ordena las fichas para decir: 'Si me hubiera levantado antes, no habría llegado tarde.'$p$,$j${"tiles": ["Wenn", "ich", "früher", "aufgestanden", "wäre", "hätte", "wäre", "ich", "nicht", "zu", "spät", "gekommen"]}$j$::jsonb,$j${"value": "Wenn ich früher aufgestanden wäre wäre ich nicht zu spät gekommen", "sequence": ["Wenn", "ich", "früher", "aufgestanden", "wäre", "wäre", "ich", "nicht", "zu", "spät", "gekommen"]}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$unidad18_l2$p$, $p$writing$p$]),
('ac9c32b2-9b30-569e-a198-c8ab7796b650'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','listening','listening',$p$Escucha y elige la frase correcta.$p$,$j${"options": ["Wir wären früher angekommen, aber der Zug hatte Verspätung.", "Wir hätten früher angekommen, aber der Zug hatte Verspätung.", "Wir wären früher ankommen, aber der Zug hatte Verspätung."], "say": "Wir wären früher angekommen, aber der Zug hatte Verspätung.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/ac9c32b2-9b30-569e-a198-c8ab7796b650.mp3"}$j$::jsonb,$j${"value": "Wir wären früher angekommen, aber der Zug hatte Verspätung."}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$unidad18_l2$p$, $p$listening$p$]),
('3f8f8b62-0c21-5ee9-b00c-2d17df031351'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Ich wäre gern mitgekommen, aber ich hatte keine Zeit.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/3f8f8b62-0c21-5ee9-b00c-2d17df031351.mp3"}$j$::jsonb,$j${"expected": "Ich wäre gern mitgekommen, aber ich hatte keine Zeit."}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$unidad18_l2$p$, $p$speaking$p$]),
('a3066f3f-d154-5cc9-bfe7-72cc4c76d91f'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','reading','match',$p$Une cada reproche alemán con su significado en español.$p$,$j${"pairs": [{"en": "Ich hätte anrufen sollen", "es": "Debería haber llamado"}, {"en": "Du hättest fragen können", "es": "Podrías haber preguntado"}, {"en": "Wir hätten aufpassen müssen", "es": "Deberíamos haber tenido cuidado"}]}$j$::jsonb,$j${"pairs": [["Ich hätte anrufen sollen", "Debería haber llamado"], ["Du hättest fragen können", "Podrías haber preguntado"], ["Wir hätten aufpassen müssen", "Deberíamos haber tenido cuidado"]]}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$unidad18_l3$p$, $p$reading$p$]),
('bd63f5b1-ca07-5262-a9c5-db0bb1654332'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','reading','multiple_choice',$p$¿Cuál expresa correctamente el reproche 'Deberías haber estudiado más'?$p$,$j${"options": ["Du hättest mehr lernen sollen.", "Du wärst mehr lernen sollen.", "Du hättest mehr gelernt sollen."]}$j$::jsonb,$j${"value": "Du hättest mehr lernen sollen."}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$unidad18_l3$p$, $p$reading$p$]),
('9542a54c-cea2-59e1-aba1-a1eea570c91d'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','writing','translation',$p$Traduce al alemán: 'Podrías haber ayudado.' (tú)$p$,$j${"source": "Podrías haber ayudado."}$j$::jsonb,$j${"value": "Du hättest helfen können.", "accepted": ["Du hättest helfen können", "Du hättest helfen können.", "Du haettest helfen koennen."]}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$unidad18_l3$p$, $p$writing$p$]),
('8e258e13-aa97-5808-8895-4c103e54fdf2'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','writing','reorder',$p$Ordena las palabras para decir: 'Deberíamos haber salido antes.'$p$,$j${"tiles": ["Wir", "hätten", "früher", "losfahren", "sollen", "wären"]}$j$::jsonb,$j${"value": "Wir hätten früher losfahren sollen"}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$unidad18_l3$p$, $p$writing$p$]),
('6f78f8fb-1bfa-5a4a-8dd7-0876080e046e'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Ich hätte dir früher Bescheid sagen sollen.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/6f78f8fb-1bfa-5a4a-8dd7-0876080e046e.mp3"}$j$::jsonb,$j${"expected": "Ich hätte dir früher Bescheid sagen sollen."}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$unidad18_l3$p$, $p$speaking$p$]),
('2a8ebd68-cb4e-5c4d-b66a-ce749a5f573c'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','reading','multiple_choice',$p$¿Cuál frase usa el Konjunktiv II del PRESENTE (hipótesis actual), no del pasado?$p$,$j${"options": ["Wenn ich reich wäre, würde ich reisen.", "Wenn ich reich gewesen wäre, wäre ich gereist.", "Wenn ich reich gewesen wäre, hätte ich gereist."]}$j$::jsonb,$j${"value": "Wenn ich reich wäre, würde ich reisen."}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$unidad18_l4$p$, $p$reading$p$]),
('c534d940-929e-5654-b031-7fadff78e5bd'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','speaking','speaking_read_aloud',$p$Lee en voz alta:$p$,$j${"text": "Wenn ich mehr Zeit gehabt hätte, wäre alles anders gewesen.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/c534d940-929e-5654-b031-7fadff78e5bd.mp3"}$j$::jsonb,$j${"expected": "Wenn ich mehr Zeit gehabt hätte, wäre alles anders gewesen."}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$unidad18_l4$p$, $p$speaking$p$]),
('e90ae8c7-8b01-5768-a872-55f4186a6bee'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','writing','translation',$p$Traduce al alemán: 'Si lo hubiera sabido, te lo habría dicho.'$p$,$j${"source": "Si lo hubiera sabido, te lo habría dicho."}$j$::jsonb,$j${"value": "Wenn ich es gewusst hätte, hätte ich es dir gesagt.", "accepted": ["Wenn ich es gewusst hätte, hätte ich es dir gesagt", "Wenn ich es gewusst hätte, hätte ich es dir gesagt.", "Hätte ich es gewusst, hätte ich es dir gesagt.", "Hätte ich es gewusst, hätte ich es dir gesagt"]}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$unidad18_l4$p$, $p$writing$p$]),
('26945bb2-d160-5cbc-b1e7-e5ce8e0d195a'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','listening','listening',$p$Escucha y elige la frase correcta.$p$,$j${"options": ["Wenn ich das gewusst hätte, wäre ich nicht gekommen.", "Wenn ich das wüsste, würde ich nicht kommen.", "Wenn ich das gewusst hätte, hätte ich nicht gekommen."], "say": "Wenn ich das gewusst hätte, wäre ich nicht gekommen.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/26945bb2-d160-5cbc-b1e7-e5ce8e0d195a.mp3"}$j$::jsonb,$j${"value": "Wenn ich das gewusst hätte, wäre ich nicht gekommen."}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$unidad18_l4$p$, $p$listening$p$]),
('b7535497-d298-5fab-a4ff-938cf0e69ca3'::uuid,'20000000-0000-0000-0000-000000000005'::uuid,'B1','listening','listening',$p$Escucha y elige la frase correcta.$p$,$j${"options": ["An deiner Stelle hätte ich das anders gemacht.", "An deiner Stelle wäre ich das anders gemacht.", "An deiner Stelle hätte ich das anders machen."], "say": "An deiner Stelle hätte ich das anders gemacht.", "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/b7535497-d298-5fab-a4ff-938cf0e69ca3.mp3"}$j$::jsonb,$j${"value": "An deiner Stelle hätte ich das anders gemacht."}$j$::jsonb,0.52,ARRAY[$p$unidad18$p$, $p$unidad18_l4$p$, $p$listening$p$])
on conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();
insert into lesson_items (lesson_id, item_id, order_index) values
 ('96a90fa6-7fb0-512a-b946-428b273f9eb6','0fb81654-ec4f-5846-a536-dc2ec54f32b1',1),
 ('96a90fa6-7fb0-512a-b946-428b273f9eb6','e8e305b1-eec7-53cc-ae2b-8ab7f804456f',2),
 ('96a90fa6-7fb0-512a-b946-428b273f9eb6','ba05868f-c369-5233-8435-77fc565c458e',3),
 ('96a90fa6-7fb0-512a-b946-428b273f9eb6','220ba7a3-f620-501d-85cf-86a79778e364',4),
 ('2c2e11b9-bfa1-51f5-bbe3-b0fcf2028da6','96721918-729a-586e-a22f-b65235053972',1),
 ('2c2e11b9-bfa1-51f5-bbe3-b0fcf2028da6','c4f1ccf8-b80f-5e05-bd28-2652aa6b9aa6',2),
 ('2c2e11b9-bfa1-51f5-bbe3-b0fcf2028da6','47893a16-6853-5550-8943-f9575bbb71d9',3),
 ('2c2e11b9-bfa1-51f5-bbe3-b0fcf2028da6','ac9c32b2-9b30-569e-a198-c8ab7796b650',4),
 ('2c2e11b9-bfa1-51f5-bbe3-b0fcf2028da6','3f8f8b62-0c21-5ee9-b00c-2d17df031351',5),
 ('48004076-f89e-532f-afbe-74560934e70b','a3066f3f-d154-5cc9-bfe7-72cc4c76d91f',1),
 ('48004076-f89e-532f-afbe-74560934e70b','bd63f5b1-ca07-5262-a9c5-db0bb1654332',2),
 ('48004076-f89e-532f-afbe-74560934e70b','9542a54c-cea2-59e1-aba1-a1eea570c91d',3),
 ('48004076-f89e-532f-afbe-74560934e70b','8e258e13-aa97-5808-8895-4c103e54fdf2',4),
 ('48004076-f89e-532f-afbe-74560934e70b','6f78f8fb-1bfa-5a4a-8dd7-0876080e046e',5),
 ('1a384401-1d1d-55d4-ab28-2340cb9f19a5','2a8ebd68-cb4e-5c4d-b66a-ce749a5f573c',1),
 ('1a384401-1d1d-55d4-ab28-2340cb9f19a5','c534d940-929e-5654-b031-7fadff78e5bd',2),
 ('1a384401-1d1d-55d4-ab28-2340cb9f19a5','e90ae8c7-8b01-5768-a872-55f4186a6bee',3),
 ('1a384401-1d1d-55d4-ab28-2340cb9f19a5','26945bb2-d160-5cbc-b1e7-e5ce8e0d195a',4),
 ('1a384401-1d1d-55d4-ab28-2340cb9f19a5','b7535497-d298-5fab-a4ff-938cf0e69ca3',5),
 ('1e0b131c-1241-586e-8203-aa85bf26cb3c','0fb81654-ec4f-5846-a536-dc2ec54f32b1',1),
 ('1e0b131c-1241-586e-8203-aa85bf26cb3c','e8e305b1-eec7-53cc-ae2b-8ab7f804456f',2),
 ('1e0b131c-1241-586e-8203-aa85bf26cb3c','96721918-729a-586e-a22f-b65235053972',3),
 ('1e0b131c-1241-586e-8203-aa85bf26cb3c','ba05868f-c369-5233-8435-77fc565c458e',4),
 ('1e0b131c-1241-586e-8203-aa85bf26cb3c','c4f1ccf8-b80f-5e05-bd28-2652aa6b9aa6',5),
 ('1e0b131c-1241-586e-8203-aa85bf26cb3c','47893a16-6853-5550-8943-f9575bbb71d9',6),
 ('1e0b131c-1241-586e-8203-aa85bf26cb3c','220ba7a3-f620-501d-85cf-86a79778e364',7),
 ('1e0b131c-1241-586e-8203-aa85bf26cb3c','ac9c32b2-9b30-569e-a198-c8ab7796b650',8),
 ('1e0b131c-1241-586e-8203-aa85bf26cb3c','3f8f8b62-0c21-5ee9-b00c-2d17df031351',9),
 ('1e0b131c-1241-586e-8203-aa85bf26cb3c','6f78f8fb-1bfa-5a4a-8dd7-0876080e046e',10)
on conflict (lesson_id, item_id) do nothing;
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('ad7c565f-53c4-50c1-b519-9fe5671a1e36','20000000-0000-0000-0000-000000000005',$p$der Fehler$p$,$p$el error$p$,461,'sustantivo'),
 ('7099447b-c1ee-54eb-bcb0-24d4c63ec98b','20000000-0000-0000-0000-000000000005',$p$die Vergangenheit$p$,$p$el pasado$p$,462,'sustantivo'),
 ('9b6d849d-95ae-5f8e-8c48-56aeec302957','20000000-0000-0000-0000-000000000005',$p$die Möglichkeit$p$,$p$la posibilidad$p$,463,'sustantivo'),
 ('7602059e-9b05-55e0-843d-e34842d2c7c8','20000000-0000-0000-0000-000000000005',$p$die Entscheidung$p$,$p$la decisión$p$,464,'sustantivo'),
 ('eaa81b75-9750-5bdd-9699-a6dd7872af2b','20000000-0000-0000-0000-000000000005',$p$das Bedauern$p$,$p$el arrepentimiento$p$,465,'sustantivo'),
 ('d4f86cb2-e49d-53a4-a3bf-79c628440341','20000000-0000-0000-0000-000000000005',$p$der Rat$p$,$p$el consejo$p$,466,'sustantivo'),
 ('4a48d3ed-2adc-5416-a9ae-825cbb769d43','20000000-0000-0000-0000-000000000005',$p$die Gelegenheit$p$,$p$la ocasión$p$,467,'sustantivo'),
 ('eb064340-5e48-5af9-9657-14fef584ecc2','20000000-0000-0000-0000-000000000005',$p$der Zufall$p$,$p$la casualidad$p$,468,'sustantivo'),
 ('2150c262-0114-5131-a57b-0126fb5a38fd','20000000-0000-0000-0000-000000000005',$p$die Warnung$p$,$p$la advertencia$p$,469,'sustantivo'),
 ('7081b425-aea3-57cc-805a-7f79f39fdd3b','20000000-0000-0000-0000-000000000005',$p$die Folge$p$,$p$la consecuencia$p$,470,'sustantivo'),
 ('3b7f418d-7002-518c-964c-9aab4c0ab39c','20000000-0000-0000-0000-000000000005',$p$der Vorwurf$p$,$p$el reproche$p$,471,'sustantivo'),
 ('949f36a5-5e96-5cb9-b445-8000afc7d7db','20000000-0000-0000-0000-000000000005',$p$die Bedingung$p$,$p$la condición$p$,472,'sustantivo'),
 ('0e749032-d3ec-5aa2-a34a-54dfbfe20724','20000000-0000-0000-0000-000000000005',$p$das Ergebnis$p$,$p$el resultado$p$,473,'sustantivo'),
 ('df6d8fe1-4bb5-5cde-9477-944880a87e02','20000000-0000-0000-0000-000000000005',$p$die Absicht$p$,$p$la intención$p$,474,'sustantivo'),
 ('12796495-d460-5576-8082-089b26dc24b4','20000000-0000-0000-0000-000000000005',$p$der Unfall$p$,$p$el accidente$p$,475,'sustantivo'),
 ('d80a9183-7d57-55be-8e62-7356e7785790','20000000-0000-0000-0000-000000000005',$p$die Erinnerung$p$,$p$el recuerdo$p$,476,'sustantivo')
on conflict (id) do nothing;

commit;