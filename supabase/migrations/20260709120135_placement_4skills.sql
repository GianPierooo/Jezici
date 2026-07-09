-- ============================================================================
-- Jezici · Migración 135 · PLACEMENT 4 HABILIDADES (Fase 1: banco L/S en+pt)
-- ----------------------------------------------------------------------------
-- El placement solo medía reading/writing y copiaba el global ×4 → perfil de
-- skills FALSO. Ahora: banco LISTENING (type=listening: MC exacto + audio TTS)
-- y SPEAKING (read-aloud verificado: type=translation, transcripción STT con
-- tolerancia typo, SIN options=sin colisión) para en+pt (cursos de verificación;
-- fr/it/de/nl en ## Cola con este mismo generador gen_placement_ls.py).
-- RPC v3: intercala las skills DISPONIBLES del banco (R→L→W→S), acepta
-- p_exclude_skills (mic no disponible → speaking fuera, honesto), y estima
-- nivel POR HABILIDAD con rigor anti-azar: global v2 intacto como ancla +
-- DEMOTE-only por skill (una skill con >=3 ítems y acc<=0.4 baja 1 nivel;
-- NUNCA se promueve por skill → el azar no puede inflar ninguna habilidad).
-- Cursos sin banco L/S: rotación sirve R/W y L/S caen al global (igual que hoy).
-- Mantiene min10/max16, rev>=4|pin>=3, clamp A2, estimador mig 134. 42501 OK.
-- ============================================================================
begin;

insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
('e6514a27-c9bc-537f-b885-8078ac0e5356', '20000000-0000-0000-0000-000000000001', 'A1', 'listening', 'listening', 'Escucha el audio y elige exactamente lo que oíste.', '{"say": "She has two brothers.", "options": ["She has two brothers.", "She has two sisters.", "He has two brothers."], "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/e6514a27-c9bc-537f-b885-8078ac0e5356.mp3"}'::jsonb, '{"value": "She has two brothers."}'::jsonb, 0.15, ARRAY['placement', 'a1', 'listening']),
('0bdd08bd-5d06-556d-b3bf-73f5989fa21c', '20000000-0000-0000-0000-000000000001', 'A1', 'listening', 'listening', 'Escucha el audio y elige exactamente lo que oíste.', '{"say": "The book is on the table.", "options": ["The book is under the table.", "The cup is on the table.", "The book is on the table."], "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/0bdd08bd-5d06-556d-b3bf-73f5989fa21c.mp3"}'::jsonb, '{"value": "The book is on the table."}'::jsonb, 0.15, ARRAY['placement', 'a1', 'listening']),
('4b3d2301-84c7-5d29-928a-f4a275372375', '20000000-0000-0000-0000-000000000001', 'A1', 'listening', 'listening', 'Escucha el audio y elige exactamente lo que oíste.', '{"say": "I get up at seven o''clock.", "options": ["I go out at seven o''clock.", "I get up at seven o''clock.", "I get up at eleven o''clock."], "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/4b3d2301-84c7-5d29-928a-f4a275372375.mp3"}'::jsonb, '{"value": "I get up at seven o''clock."}'::jsonb, 0.15, ARRAY['placement', 'a1', 'listening']),
('e547e7b1-d18f-50f5-8af4-28040375cbcc', '20000000-0000-0000-0000-000000000001', 'A2', 'listening', 'listening', 'Escucha el audio y elige exactamente lo que oíste.', '{"say": "Yesterday I went to the beach.", "options": ["Yesterday I went to the beach.", "Yesterday I want to the beach.", "Yesterday I went to the bridge."], "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/e547e7b1-d18f-50f5-8af4-28040375cbcc.mp3"}'::jsonb, '{"value": "Yesterday I went to the beach."}'::jsonb, 0.35, ARRAY['placement', 'a2', 'listening']),
('a8a17830-311c-58b0-b1ed-726aacc773eb', '20000000-0000-0000-0000-000000000001', 'A2', 'listening', 'listening', 'Escucha el audio y elige exactamente lo que oíste.', '{"say": "She is taller than her brother.", "options": ["She is older than her brother.", "She is taller than her mother.", "She is taller than her brother."], "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/a8a17830-311c-58b0-b1ed-726aacc773eb.mp3"}'::jsonb, '{"value": "She is taller than her brother."}'::jsonb, 0.35, ARRAY['placement', 'a2', 'listening']),
('67ea7de6-eef0-53ca-82b4-170c9ce56b23', '20000000-0000-0000-0000-000000000001', 'A2', 'listening', 'listening', 'Escucha el audio y elige exactamente lo que oíste.', '{"say": "We didn''t have time to eat.", "options": ["We don''t have time to eat.", "We didn''t have time to eat.", "We didn''t have time to sleep."], "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/67ea7de6-eef0-53ca-82b4-170c9ce56b23.mp3"}'::jsonb, '{"value": "We didn''t have time to eat."}'::jsonb, 0.35, ARRAY['placement', 'a2', 'listening']),
('9eb75486-774d-5292-8e55-7b6914185fcd', '20000000-0000-0000-0000-000000000001', 'B1', 'listening', 'listening', 'Escucha el audio y elige exactamente lo que oíste.', '{"say": "I have never seen that movie.", "options": ["I have never seen that movie.", "I have never seen that mountain.", "I had never seen that movie."], "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/9eb75486-774d-5292-8e55-7b6914185fcd.mp3"}'::jsonb, '{"value": "I have never seen that movie."}'::jsonb, 0.55, ARRAY['placement', 'b1', 'listening']),
('25bd9558-01e9-551b-82ac-baaed12fa62e', '20000000-0000-0000-0000-000000000001', 'B1', 'listening', 'listening', 'Escucha el audio y elige exactamente lo que oíste.', '{"say": "If it rains, we will stay at home.", "options": ["If it rained, we would stay at home.", "If it rains, we will stay at work.", "If it rains, we will stay at home."], "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/25bd9558-01e9-551b-82ac-baaed12fa62e.mp3"}'::jsonb, '{"value": "If it rains, we will stay at home."}'::jsonb, 0.55, ARRAY['placement', 'b1', 'listening']),
('3816e63c-fdfd-5daa-8e41-dfc9a1083467', '20000000-0000-0000-0000-000000000001', 'B1', 'listening', 'listening', 'Escucha el audio y elige exactamente lo que oíste.', '{"say": "She has been living here since March.", "options": ["She had been living here since March.", "She has been living here since March.", "She has been living here since May."], "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/3816e63c-fdfd-5daa-8e41-dfc9a1083467.mp3"}'::jsonb, '{"value": "She has been living here since March."}'::jsonb, 0.55, ARRAY['placement', 'b1', 'listening']),
('7ca7ba27-a1e2-55e7-ab61-b83b197499b7', '20000000-0000-0000-0000-000000000001', 'B2', 'listening', 'listening', 'Escucha el audio y elige exactamente lo que oíste.', '{"say": "The results will be announced tomorrow.", "options": ["The results will be announced tomorrow.", "The results were announced yesterday.", "The results will be announced on Monday."], "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/7ca7ba27-a1e2-55e7-ab61-b83b197499b7.mp3"}'::jsonb, '{"value": "The results will be announced tomorrow."}'::jsonb, 0.72, ARRAY['placement', 'b2', 'listening']),
('47e49815-d2d0-5d0d-9507-0419b35fc90f', '20000000-0000-0000-0000-000000000001', 'B2', 'listening', 'listening', 'Escucha el audio y elige exactamente lo que oíste.', '{"say": "He said he had already finished the report.", "options": ["He said he would finish the report soon.", "He says he has already finished the report.", "He said he had already finished the report."], "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/47e49815-d2d0-5d0d-9507-0419b35fc90f.mp3"}'::jsonb, '{"value": "He said he had already finished the report."}'::jsonb, 0.72, ARRAY['placement', 'b2', 'listening']),
('a9b9ecf3-33c5-5369-a9dc-8065b7bcff6b', '20000000-0000-0000-0000-000000000001', 'B2', 'listening', 'listening', 'Escucha el audio y elige exactamente lo que oíste.', '{"say": "Had I known, I would have called you.", "options": ["If I know, I will call you.", "Had I known, I would have called you.", "Had I gone, I would have called you."], "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/a9b9ecf3-33c5-5369-a9dc-8065b7bcff6b.mp3"}'::jsonb, '{"value": "Had I known, I would have called you."}'::jsonb, 0.72, ARRAY['placement', 'b2', 'listening']),
('a1200cc4-508f-50af-af13-ffdeb41e8b8a', '20000000-0000-0000-0000-000000000001', 'C1', 'listening', 'listening', 'Escucha el audio y elige exactamente lo que oíste.', '{"say": "Seldom have I encountered such a compelling argument.", "options": ["Seldom have I encountered such a compelling argument.", "Rarely have I encountered such a compelling argument.", "Seldom had I encountered such a compelling argument."], "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/a1200cc4-508f-50af-af13-ffdeb41e8b8a.mp3"}'::jsonb, '{"value": "Seldom have I encountered such a compelling argument."}'::jsonb, 0.84, ARRAY['placement', 'c1', 'listening']),
('c0a1448c-30d0-59fe-a032-fe931822b5f1', '20000000-0000-0000-0000-000000000001', 'C1', 'listening', 'listening', 'Escucha el audio y elige exactamente lo que oíste.', '{"say": "The proposal was met with considerable skepticism.", "options": ["The proposal was met with considerable enthusiasm.", "The proposal was made with considerable skepticism.", "The proposal was met with considerable skepticism."], "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/c0a1448c-30d0-59fe-a032-fe931822b5f1.mp3"}'::jsonb, '{"value": "The proposal was met with considerable skepticism."}'::jsonb, 0.84, ARRAY['placement', 'c1', 'listening']),
('17321cb1-7cdb-5c70-92d4-9c1785798fbf', '20000000-0000-0000-0000-000000000001', 'C1', 'listening', 'listening', 'Escucha el audio y elige exactamente lo que oíste.', '{"say": "Notwithstanding the delays, the project succeeded.", "options": ["Despite the delays, the project succeeded.", "Notwithstanding the delays, the project succeeded.", "Notwithstanding the delays, the project collapsed."], "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/17321cb1-7cdb-5c70-92d4-9c1785798fbf.mp3"}'::jsonb, '{"value": "Notwithstanding the delays, the project succeeded."}'::jsonb, 0.84, ARRAY['placement', 'c1', 'listening']),
('e4981d99-2cc2-54b8-9129-2dbb81446596', '20000000-0000-0000-0000-000000000002', 'A1', 'listening', 'listening', 'Escucha el audio y elige exactamente lo que oíste.', '{"say": "Eu tenho dois irmãos.", "options": ["Eu tenho dois irmãos.", "Eu tenho duas irmãs.", "Ele tem dois irmãos."], "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/e4981d99-2cc2-54b8-9129-2dbb81446596.mp3"}'::jsonb, '{"value": "Eu tenho dois irmãos."}'::jsonb, 0.15, ARRAY['placement', 'a1', 'listening']),
('8eed9c46-88bb-5067-bcf2-5b6e72a74889', '20000000-0000-0000-0000-000000000002', 'A1', 'listening', 'listening', 'Escucha el audio y elige exactamente lo que oíste.', '{"say": "O livro está na mesa.", "options": ["O livro está na mala.", "O copo está na mesa.", "O livro está na mesa."], "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/8eed9c46-88bb-5067-bcf2-5b6e72a74889.mp3"}'::jsonb, '{"value": "O livro está na mesa."}'::jsonb, 0.15, ARRAY['placement', 'a1', 'listening']),
('8b58912d-43f1-52d4-9fb5-5b24bf47d269', '20000000-0000-0000-0000-000000000002', 'A1', 'listening', 'listening', 'Escucha el audio y elige exactamente lo que oíste.', '{"say": "Eu acordo às sete horas.", "options": ["Eu janto às sete horas.", "Eu acordo às sete horas.", "Eu acordo às seis horas."], "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/8b58912d-43f1-52d4-9fb5-5b24bf47d269.mp3"}'::jsonb, '{"value": "Eu acordo às sete horas."}'::jsonb, 0.15, ARRAY['placement', 'a1', 'listening']),
('d86a1aa4-4756-58c0-a4b6-f1026f59d372', '20000000-0000-0000-0000-000000000002', 'A2', 'listening', 'listening', 'Escucha el audio y elige exactamente lo que oíste.', '{"say": "Ontem eu fui à praia.", "options": ["Ontem eu fui à praia.", "Ontem eu vou à praia.", "Ontem eu fui à prova."], "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/d86a1aa4-4756-58c0-a4b6-f1026f59d372.mp3"}'::jsonb, '{"value": "Ontem eu fui à praia."}'::jsonb, 0.35, ARRAY['placement', 'a2', 'listening']),
('1fd835e7-4922-56f7-82c2-54d7c74e9345', '20000000-0000-0000-0000-000000000002', 'A2', 'listening', 'listening', 'Escucha el audio y elige exactamente lo que oíste.', '{"say": "Ela é mais alta que o irmão.", "options": ["Ela é mais velha que o irmão.", "Ela é mais alta que a irmã.", "Ela é mais alta que o irmão."], "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/1fd835e7-4922-56f7-82c2-54d7c74e9345.mp3"}'::jsonb, '{"value": "Ela é mais alta que o irmão."}'::jsonb, 0.35, ARRAY['placement', 'a2', 'listening']),
('835d40a0-a04a-5f99-a6be-940e162c8cf4', '20000000-0000-0000-0000-000000000002', 'A2', 'listening', 'listening', 'Escucha el audio y elige exactamente lo que oíste.', '{"say": "Nós não tivemos tempo de comer.", "options": ["Nós não tivemos tempo de correr.", "Nós não tivemos tempo de comer.", "Nós não temos tempo de comer."], "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/835d40a0-a04a-5f99-a6be-940e162c8cf4.mp3"}'::jsonb, '{"value": "Nós não tivemos tempo de comer."}'::jsonb, 0.35, ARRAY['placement', 'a2', 'listening']),
('c6a7839a-0672-5cb0-9a14-64bfc0370c78', '20000000-0000-0000-0000-000000000002', 'B1', 'listening', 'listening', 'Escucha el audio y elige exactamente lo que oíste.', '{"say": "Eu nunca vi esse filme.", "options": ["Eu nunca vi esse filme.", "Eu nunca vejo esse filme.", "Eu nunca vi esse prédio."], "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/c6a7839a-0672-5cb0-9a14-64bfc0370c78.mp3"}'::jsonb, '{"value": "Eu nunca vi esse filme."}'::jsonb, 0.55, ARRAY['placement', 'b1', 'listening']),
('f83368ab-45ce-530a-8bf7-a94f26645c20', '20000000-0000-0000-0000-000000000002', 'B1', 'listening', 'listening', 'Escucha el audio y elige exactamente lo que oíste.', '{"say": "Se chover, vamos ficar em casa.", "options": ["Se chovesse, ficaríamos em casa.", "Se chover, vamos ficar na rua.", "Se chover, vamos ficar em casa."], "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/f83368ab-45ce-530a-8bf7-a94f26645c20.mp3"}'::jsonb, '{"value": "Se chover, vamos ficar em casa."}'::jsonb, 0.55, ARRAY['placement', 'b1', 'listening']),
('5a6e8e83-4002-5ef2-9c97-7f458224715e', '20000000-0000-0000-0000-000000000002', 'B1', 'listening', 'listening', 'Escucha el audio y elige exactamente lo que oíste.', '{"say": "Ela mora aqui desde março.", "options": ["Ela morava aqui desde março.", "Ela mora aqui desde março.", "Ela mora aqui desde maio."], "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/5a6e8e83-4002-5ef2-9c97-7f458224715e.mp3"}'::jsonb, '{"value": "Ela mora aqui desde março."}'::jsonb, 0.55, ARRAY['placement', 'b1', 'listening']),
('7076b7b0-d5af-56b4-ad76-eba591a8b7a8', '20000000-0000-0000-0000-000000000002', 'B2', 'listening', 'listening', 'Escucha el audio y elige exactamente lo que oíste.', '{"say": "Os resultados serão anunciados amanhã.", "options": ["Os resultados serão anunciados amanhã.", "Os resultados foram anunciados ontem.", "Os resultados serão anunciados na segunda."], "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/7076b7b0-d5af-56b4-ad76-eba591a8b7a8.mp3"}'::jsonb, '{"value": "Os resultados serão anunciados amanhã."}'::jsonb, 0.72, ARRAY['placement', 'b2', 'listening']),
('99e858cd-6807-5ccb-a58a-962f7d8b000b', '20000000-0000-0000-0000-000000000002', 'B2', 'listening', 'listening', 'Escucha el audio y elige exactamente lo que oíste.', '{"say": "Ele disse que já tinha terminado o relatório.", "options": ["Ele disse que ainda ia terminar o relatório.", "Ele diz que já terminou o relatório.", "Ele disse que já tinha terminado o relatório."], "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/99e858cd-6807-5ccb-a58a-962f7d8b000b.mp3"}'::jsonb, '{"value": "Ele disse que já tinha terminado o relatório."}'::jsonb, 0.72, ARRAY['placement', 'b2', 'listening']),
('fd092ba6-bb5d-5125-9864-0823b95ff55c', '20000000-0000-0000-0000-000000000002', 'B2', 'listening', 'listening', 'Escucha el audio y elige exactamente lo que oíste.', '{"say": "Quando eu tiver tempo, farei o curso.", "options": ["Quando eu tiver tempo, faria o curso.", "Quando eu tiver tempo, farei o curso.", "Quando eu tinha tempo, fazia o curso."], "audio_url": "https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/fd092ba6-bb5d-5125-9864-0823b95ff55c.mp3"}'::jsonb, '{"value": "Quando eu tiver tempo, farei o curso."}'::jsonb, 0.72, ARRAY['placement', 'b2', 'listening']),
('bcea00b9-df81-54d8-8fba-97236870c7e5', '20000000-0000-0000-0000-000000000001', 'A1', 'speaking', 'translation', 'Lee esta frase EN VOZ ALTA con tu micrófono:', '{"text": "I have two cats.", "speaking": true}'::jsonb, '{"value": "I have two cats"}'::jsonb, 0.15, ARRAY['placement', 'a1', 'speaking']),
('743c3235-c898-5ef3-b047-d5b73ef165c5', '20000000-0000-0000-0000-000000000001', 'A1', 'speaking', 'translation', 'Lee esta frase EN VOZ ALTA con tu micrófono:', '{"text": "The coffee is very good.", "speaking": true}'::jsonb, '{"value": "The coffee is very good"}'::jsonb, 0.15, ARRAY['placement', 'a1', 'speaking']),
('694c35d5-1da0-5ee9-b888-dd677b157d82', '20000000-0000-0000-0000-000000000001', 'A2', 'speaking', 'translation', 'Lee esta frase EN VOZ ALTA con tu micrófono:', '{"text": "Last weekend I visited my grandmother.", "speaking": true}'::jsonb, '{"value": "Last weekend I visited my grandmother"}'::jsonb, 0.35, ARRAY['placement', 'a2', 'speaking']),
('14b3b235-cdc1-5cda-9068-d2ee47c515d7', '20000000-0000-0000-0000-000000000001', 'A2', 'speaking', 'translation', 'Lee esta frase EN VOZ ALTA con tu micrófono:', '{"text": "I am going to travel next month.", "speaking": true}'::jsonb, '{"value": "I am going to travel next month"}'::jsonb, 0.35, ARRAY['placement', 'a2', 'speaking']),
('e94547ab-3e61-5851-95e4-86c72f9662b0', '20000000-0000-0000-0000-000000000001', 'B1', 'speaking', 'translation', 'Lee esta frase EN VOZ ALTA con tu micrófono:', '{"text": "I have been studying English for two years.", "speaking": true}'::jsonb, '{"value": "I have been studying English for two years"}'::jsonb, 0.55, ARRAY['placement', 'b1', 'speaking']),
('e9c0b106-ca84-51bf-841e-a7bb1a240a56', '20000000-0000-0000-0000-000000000001', 'B1', 'speaking', 'translation', 'Lee esta frase EN VOZ ALTA con tu micrófono:', '{"text": "If I had more time, I would read more books.", "speaking": true}'::jsonb, '{"value": "If I had more time, I would read more books"}'::jsonb, 0.55, ARRAY['placement', 'b1', 'speaking']),
('4d705dbf-d4f8-58fd-b766-5da51bac9aff', '20000000-0000-0000-0000-000000000001', 'B2', 'speaking', 'translation', 'Lee esta frase EN VOZ ALTA con tu micrófono:', '{"text": "The meeting had already started when I arrived.", "speaking": true}'::jsonb, '{"value": "The meeting had already started when I arrived"}'::jsonb, 0.72, ARRAY['placement', 'b2', 'speaking']),
('77a43e33-c3b1-5562-be2a-741c1c3d6a23', '20000000-0000-0000-0000-000000000001', 'B2', 'speaking', 'translation', 'Lee esta frase EN VOZ ALTA con tu micrófono:', '{"text": "This document must be signed by the manager.", "speaking": true}'::jsonb, '{"value": "This document must be signed by the manager"}'::jsonb, 0.72, ARRAY['placement', 'b2', 'speaking']),
('3d356585-44df-552c-8275-abf8f959fca3', '20000000-0000-0000-0000-000000000001', 'C1', 'speaking', 'translation', 'Lee esta frase EN VOZ ALTA con tu micrófono:', '{"text": "Had it not been for her advice, I would have failed.", "speaking": true}'::jsonb, '{"value": "Had it not been for her advice, I would have failed"}'::jsonb, 0.84, ARRAY['placement', 'c1', 'speaking']),
('92e7eb46-c907-5d4a-9d8b-bd06909dc971', '20000000-0000-0000-0000-000000000001', 'C1', 'speaking', 'translation', 'Lee esta frase EN VOZ ALTA con tu micrófono:', '{"text": "The findings ought to be interpreted with caution.", "speaking": true}'::jsonb, '{"value": "The findings ought to be interpreted with caution"}'::jsonb, 0.84, ARRAY['placement', 'c1', 'speaking']),
('fb41046d-fd77-5f8a-bc6b-9dc02af5b86b', '20000000-0000-0000-0000-000000000002', 'A1', 'speaking', 'translation', 'Lee esta frase EN VOZ ALTA con tu micrófono:', '{"text": "Eu moro em uma casa pequena.", "speaking": true}'::jsonb, '{"value": "Eu moro em uma casa pequena"}'::jsonb, 0.15, ARRAY['placement', 'a1', 'speaking']),
('e278f5d3-2642-527e-8171-2ebd5933129a', '20000000-0000-0000-0000-000000000002', 'A1', 'speaking', 'translation', 'Lee esta frase EN VOZ ALTA con tu micrófono:', '{"text": "O café está muito bom.", "speaking": true}'::jsonb, '{"value": "O café está muito bom"}'::jsonb, 0.15, ARRAY['placement', 'a1', 'speaking']),
('0869561b-fc1d-5161-a458-3c37fd70e55a', '20000000-0000-0000-0000-000000000002', 'A2', 'speaking', 'translation', 'Lee esta frase EN VOZ ALTA con tu micrófono:', '{"text": "No fim de semana passado eu visitei minha avó.", "speaking": true}'::jsonb, '{"value": "No fim de semana passado eu visitei minha avó"}'::jsonb, 0.35, ARRAY['placement', 'a2', 'speaking']),
('fab1fd52-0147-585f-8954-dc1d76e97158', '20000000-0000-0000-0000-000000000002', 'A2', 'speaking', 'translation', 'Lee esta frase EN VOZ ALTA con tu micrófono:', '{"text": "Eu vou viajar no mês que vem.", "speaking": true}'::jsonb, '{"value": "Eu vou viajar no mês que vem"}'::jsonb, 0.35, ARRAY['placement', 'a2', 'speaking']),
('e35e9c16-1c15-5bf5-b6db-da3ae46f83df', '20000000-0000-0000-0000-000000000002', 'B1', 'speaking', 'translation', 'Lee esta frase EN VOZ ALTA con tu micrófono:', '{"text": "Estou estudando português há dois anos.", "speaking": true}'::jsonb, '{"value": "Estou estudando português há dois anos"}'::jsonb, 0.55, ARRAY['placement', 'b1', 'speaking']),
('997f6490-ad73-59cc-aca7-c2c42bb5b9c2', '20000000-0000-0000-0000-000000000002', 'B1', 'speaking', 'translation', 'Lee esta frase EN VOZ ALTA con tu micrófono:', '{"text": "Se eu tivesse mais tempo, leria mais livros.", "speaking": true}'::jsonb, '{"value": "Se eu tivesse mais tempo, leria mais livros"}'::jsonb, 0.55, ARRAY['placement', 'b1', 'speaking']),
('42009df8-75b8-58db-9989-76f989ee3aec', '20000000-0000-0000-0000-000000000002', 'B2', 'speaking', 'translation', 'Lee esta frase EN VOZ ALTA con tu micrófono:', '{"text": "A reunião já tinha começado quando eu cheguei.", "speaking": true}'::jsonb, '{"value": "A reunião já tinha começado quando eu cheguei"}'::jsonb, 0.72, ARRAY['placement', 'b2', 'speaking']),
('66ab5a16-b778-5351-af09-ddfd20f48147', '20000000-0000-0000-0000-000000000002', 'B2', 'speaking', 'translation', 'Lee esta frase EN VOZ ALTA con tu micrófono:', '{"text": "Este documento deve ser assinado pelo gerente.", "speaking": true}'::jsonb, '{"value": "Este documento deve ser assinado pelo gerente"}'::jsonb, 0.72, ARRAY['placement', 'b2', 'speaking'])
on conflict (id) do nothing;


-- ── RPC v3: 4 habilidades intercaladas + nivel POR HABILIDAD (demote-only) ────
-- La firma cambia (nuevo p_exclude_skills) → DROP para no dejar overload ambiguo
-- en PostgREST. Llamadas viejas (3 args con nombre) siguen resolviendo (default).
drop function if exists placement_next(uuid, text, jsonb);

create or replace function placement_next(
  p_course uuid default null, p_start_level text default null,
  p_history jsonb default '[]'::jsonb, p_exclude_skills text[] default null)
returns jsonb language plpgsql security definer set search_path = public as $$
declare
  uid uuid := auth.uid(); v_course uuid;
  v_band int; v_new int; v_dir int; v_prevdir int := 0; v_rev int := 0; v_n int := 0;
  v_pin int := 0;
  v_max_items int := 16; v_min_items int := 10; v_stop boolean;
  v_skill text; v_item jsonb;
  v_ranks int[]; v_correct boolean[]; v_overall int;
  v_order text[]; v_avail text[];
  v_sk text; v_sk_n int; v_sk_c int; v_lvls jsonb := '{}'::jsonb;
  rec record;
begin
  if uid is null then raise exception 'auth required'; end if;
  v_course := coalesce(p_course, (select id from courses where is_active order by created_at limit 1));
  if v_course is null then raise exception 'no active course'; end if;

  create temp table _h on commit drop as
  select (e.elem ->> 'item_id')::uuid as item_id, ci.cefr_level, ci.skill,
         jz_rank(ci.cefr_level::text) as rnk,
         jz_grade(ci.type, ci.correct_answer, e.elem -> 'answer') as correct, e.ord
  from jsonb_array_elements(coalesce(p_history, '[]'::jsonb)) with ordinality e(elem, ord)
  join content_items ci on ci.id = (e.elem ->> 'item_id')::uuid
   and ci.course_id = v_course and 'placement' = any(ci.tags);

  -- Arranque CLAMPEADO a A2 máx (anti-azar, mig 131/134 — sin cambios).
  v_band := greatest(0, least(1, jz_rank(coalesce(p_start_level, 'A2'))));
  for rec in select correct from _h order by ord loop
    v_n := v_n + 1;
    v_new := case when rec.correct then least(v_band + 1, 4) else greatest(v_band - 1, 0) end;
    v_dir := sign(v_new - v_band);
    if v_dir <> 0 and v_prevdir <> 0 and v_dir <> v_prevdir then v_rev := v_rev + 1; end if;
    if v_dir <> 0 then v_prevdir := v_dir; end if;
    if v_new = v_band then v_pin := v_pin + 1; else v_pin := 0; end if;
    v_band := v_new;
  end loop;

  v_stop := (v_n >= v_max_items)
         or (v_n >= v_min_items and (v_rev >= 4 or v_pin >= 3));

  if not v_stop then
    -- Rotación R→L→W→S sobre las skills DISPONIBLES en el banco del curso y no
    -- excluidas (mic no disponible → cliente excluye 'speaking', honesto).
    select array_agg(s order by pos) into v_avail
    from (
      select x.s, x.pos from (values ('reading',1),('listening',2),('writing',3),('speaking',4)) x(s,pos)
      where exists (select 1 from content_items ci where ci.course_id = v_course
                      and 'placement' = any(ci.tags) and ci.skill::text = x.s
                      and not jz_is_stub(ci.type))
        and (p_exclude_skills is null or x.s <> all(p_exclude_skills))
    ) q;
    if v_avail is null or array_length(v_avail, 1) is null then
      v_avail := array['reading','writing'];
    end if;
    v_skill := v_avail[(v_n % array_length(v_avail, 1)) + 1];

    select jsonb_build_object('id', x.id, 'type', x.type, 'skill', x.skill,
             'cefr_level', x.cefr_level, 'prompt', x.prompt, 'payload', x.payload)
      into v_item
    from (
      select ci.id, ci.type, ci.skill, ci.cefr_level, ci.prompt, ci.payload,
             abs(jz_rank(ci.cefr_level::text) - v_band) bdist,
             case when ci.skill::text = v_skill then 0 else 1 end sdist
      from content_items ci
      where ci.course_id = v_course and 'placement' = any(ci.tags) and not jz_is_stub(ci.type)
        and (p_exclude_skills is null or ci.skill::text <> all(p_exclude_skills))
        and ci.id not in (select item_id from _h)
      order by bdist asc, sdist asc, random()
      limit 1) x;
    if v_item is not null then
      return jsonb_build_object('done', false, 'asked', v_n, 'max', v_max_items, 'item', v_item);
    end if;
  end if;

  select array_agg(rnk order by ord), array_agg(correct order by ord) into v_ranks, v_correct from _h;
  v_overall := jz_placement_level(v_ranks, v_correct);

  -- POR HABILIDAD, con el rigor anti-azar del v2: el GLOBAL (guess-aware, pisos)
  -- es el ancla; una skill solo se DIFERENCIA hacia ABAJO con evidencia sostenida
  -- (>=3 ítems calificados de esa skill y precisión <=0.4 → global-1). NUNCA se
  -- promueve por skill (el azar no puede inflar ninguna). Sin evidencia (p.ej.
  -- speaking excluido, o curso sin banco L/S) → global (honesto, como hoy).
  for v_sk in select unnest(array['reading','listening','writing','speaking']) loop
    select count(*), count(*) filter (where correct) into v_sk_n, v_sk_c
    from _h where skill::text = v_sk;
    if v_sk_n >= 3 and v_sk_c::numeric / v_sk_n <= 0.4 then
      v_lvls := v_lvls || jsonb_build_object(v_sk, jz_cefr(greatest(v_overall - 1, 0)));
    else
      v_lvls := v_lvls || jsonb_build_object(v_sk, jz_cefr(v_overall));
    end if;
  end loop;

  return jsonb_build_object(
    'done', true, 'asked', v_n, 'level', jz_cefr(v_overall), 'skill_levels', v_lvls);
end $$;

grant execute on function placement_next(uuid, text, jsonb, text[]) to authenticated;

commit;
