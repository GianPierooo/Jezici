-- ============================================================================
-- Jezici · Seed (paso B) · Curso es→en + Unidad 1 + placement + Matix
-- ----------------------------------------------------------------------------
-- Fuentes: Jezici_Curriculo_A1_es-en.md, Jezici_Contenido_Unidad1.md,
--          Jezici_Test_Ubicacion_Items.md, Jezici_Matix_Plantillas.md.
-- Idempotente: UUIDs fijos + ON CONFLICT. Re-ejecutable sin duplicar.
-- Mapeo de habilidad para placement: cloze (producción) -> writing;
--   multiple_choice (reconocimiento) -> reading; vocab/grammar van en tags.
-- Audios = placeholders (grabar/TTS después).
-- ============================================================================

begin;

-- ── Idiomas ─────────────────────────────────────────────────────────────────
insert into languages (id, code, name) values
  ('10000000-0000-0000-0000-000000000001', 'es', 'Español'),
  ('10000000-0000-0000-0000-000000000002', 'en', 'English'),
  ('10000000-0000-0000-0000-000000000003', 'pt', 'Português')
on conflict (code) do nothing;

-- ── Curso es → en ───────────────────────────────────────────────────────────
insert into courses (id, source_language_id, target_language_id, is_active) values
  ('20000000-0000-0000-0000-000000000001',
   '10000000-0000-0000-0000-000000000001',
   '10000000-0000-0000-0000-000000000002', true)
on conflict (source_language_id, target_language_id) do nothing;

-- ── Unidad 1 ────────────────────────────────────────────────────────────────
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
  ('30000000-0000-0000-0000-000000000001',
   '20000000-0000-0000-0000-000000000001',
   'A1', 1, 'Saludos y presentarte', '#6C5CE7', 'wave')
on conflict (course_id, order_index) do nothing;

-- ── Lecciones (nodos del mapa) ──────────────────────────────────────────────
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
  ('40000000-0000-0000-0000-000000000010','30000000-0000-0000-0000-000000000001', 0, 'Misión: 100 esenciales', 'Colecciona las 100 palabras y frases de mayor utilidad.', 'mission', 0),
  ('40000000-0000-0000-0000-000000000011','30000000-0000-0000-0000-000000000001', 1, 'Saludos básicos', 'hello, hi, good morning, good night, goodbye, bye', 'lesson', 15),
  ('40000000-0000-0000-0000-000000000012','30000000-0000-0000-0000-000000000001', 2, 'Cortesía', 'please, thank you, sorry, excuse me, yes, no', 'lesson', 15),
  ('40000000-0000-0000-0000-000000000013','30000000-0000-0000-0000-000000000001', 3, 'Tu nombre', 'name, my, your, what · "My name is…"', 'lesson', 15),
  ('40000000-0000-0000-0000-000000000014','30000000-0000-0000-0000-000000000001', 4, 'Presentarte (to be)', 'I am, you are, I''m, fine · "Nice to meet you"', 'lesson', 15),
  ('40000000-0000-0000-0000-000000000015','30000000-0000-0000-0000-000000000001', 5, '🏁 Checkpoint Unidad 1', 'Cronometrado · mezcla las 4 habilidades · umbral 80%.', 'checkpoint', 40)
on conflict (unit_id, order_index) do nothing;

-- ── Examen de checkpoint (definición) ───────────────────────────────────────
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
  ('50000000-0000-0000-0000-000000000001',
   '20000000-0000-0000-0000-000000000001', 'checkpoint', 'A1',
   '30000000-0000-0000-0000-000000000001', 300, 0.80,
   $j${"skills":["reading","listening","writing","speaking"],"item_count":10,"randomize":true}$j$::jsonb)
on conflict (id) do nothing;

-- ── Ejercicios: Lección 1.1 — Saludos básicos ───────────────────────────────
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
 ('41000000-0000-0000-0000-000000000001','20000000-0000-0000-0000-000000000001','A1','reading','match',
   'Empareja cada palabra con su traducción.',
   $j${"pairs":[{"en":"hello","es":"hola"},{"en":"goodbye","es":"adiós"},{"en":"good morning","es":"buenos días"}]}$j$::jsonb,
   $j${"pairs":[["hello","hola"],["goodbye","adiós"],["good morning","buenos días"]]}$j$::jsonb,
   0.10, ARRAY['unidad1','saludos','reading']),
 ('41000000-0000-0000-0000-000000000002','20000000-0000-0000-0000-000000000001','A1','reading','multiple_choice',
   '¿Cómo se dice "hola"?',
   $j${"options":["hello","goodbye","please"]}$j$::jsonb, $j${"value":"hello"}$j$::jsonb,
   0.10, ARRAY['unidad1','saludos','reading']),
 ('41000000-0000-0000-0000-000000000003','20000000-0000-0000-0000-000000000001','A1','reading','multiple_choice',
   '"Good morning" significa…',
   $j${"options":["buenas noches","buenos días","adiós"]}$j$::jsonb, $j${"value":"buenos días"}$j$::jsonb,
   0.10, ARRAY['unidad1','saludos','reading']),
 ('41000000-0000-0000-0000-000000000004','20000000-0000-0000-0000-000000000001','A1','listening','listening',
   'Escucha y elige la palabra correcta.',
   $j${"audio_url":"audio/a1/goodbye.mp3","options":["Hello","Goodbye","Good night"]}$j$::jsonb, $j${"value":"Goodbye"}$j$::jsonb,
   0.15, ARRAY['unidad1','saludos','listening']),
 ('41000000-0000-0000-0000-000000000005','20000000-0000-0000-0000-000000000001','A1','writing','word_bank',
   'Arma la frase: "Buenos días".',
   $j${"tiles":["Good","morning","night","evening"]}$j$::jsonb, $j${"value":"Good morning","sequence":["Good","morning"]}$j$::jsonb,
   0.15, ARRAY['unidad1','saludos','writing']),
 ('41000000-0000-0000-0000-000000000006','20000000-0000-0000-0000-000000000001','A1','writing','translation',
   'Traduce: "Adiós".',
   $j${"source":"Adiós"}$j$::jsonb, $j${"value":"Goodbye","accepted":["goodbye","bye","Bye"]}$j$::jsonb,
   0.15, ARRAY['unidad1','saludos','writing']),
 ('41000000-0000-0000-0000-000000000007','20000000-0000-0000-0000-000000000001','A1','reading','multiple_choice',
   'Para despedirte de noche dices…',
   $j${"options":["Good morning","Good night","Hello"]}$j$::jsonb, $j${"value":"Good night"}$j$::jsonb,
   0.10, ARRAY['unidad1','saludos','reading']),
 ('41000000-0000-0000-0000-000000000008','20000000-0000-0000-0000-000000000001','A1','speaking','speaking_read_aloud',
   'Lee en voz alta:',
   $j${"text":"Hello! Good morning!"}$j$::jsonb, $j${"expected":"Hello! Good morning!"}$j$::jsonb,
   0.10, ARRAY['unidad1','saludos','speaking'])
on conflict (id) do nothing;

-- ── Ejercicios: Lección 1.2 — Cortesía ──────────────────────────────────────
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
 ('42000000-0000-0000-0000-000000000001','20000000-0000-0000-0000-000000000001','A1','reading','match',
   'Empareja cada palabra con su traducción.',
   $j${"pairs":[{"en":"please","es":"por favor"},{"en":"thank you","es":"gracias"},{"en":"sorry","es":"perdón"}]}$j$::jsonb,
   $j${"pairs":[["please","por favor"],["thank you","gracias"],["sorry","perdón"]]}$j$::jsonb,
   0.10, ARRAY['unidad1','cortesia','reading']),
 ('42000000-0000-0000-0000-000000000002','20000000-0000-0000-0000-000000000001','A1','reading','multiple_choice',
   '"Thank you" significa…',
   $j${"options":["perdón","gracias","hola"]}$j$::jsonb, $j${"value":"gracias"}$j$::jsonb,
   0.10, ARRAY['unidad1','cortesia','reading']),
 ('42000000-0000-0000-0000-000000000003','20000000-0000-0000-0000-000000000001','A1','writing','cloze',
   'Completa: "___ you!"',
   $j${"text":"___ you!"}$j$::jsonb, $j${"value":"Thank","accepted":["thank"]}$j$::jsonb,
   0.15, ARRAY['unidad1','cortesia','writing']),
 ('42000000-0000-0000-0000-000000000004','20000000-0000-0000-0000-000000000001','A1','reading','multiple_choice',
   'Para pedir algo con educación usas…',
   $j${"options":["sorry","please","yes"]}$j$::jsonb, $j${"value":"please"}$j$::jsonb,
   0.10, ARRAY['unidad1','cortesia','reading']),
 ('42000000-0000-0000-0000-000000000005','20000000-0000-0000-0000-000000000001','A1','listening','listening',
   'Escucha y elige la palabra correcta.',
   $j${"audio_url":"audio/a1/excuse_me.mp3","options":["Thank you","Excuse me","Sorry"]}$j$::jsonb, $j${"value":"Excuse me"}$j$::jsonb,
   0.15, ARRAY['unidad1','cortesia','listening']),
 ('42000000-0000-0000-0000-000000000006','20000000-0000-0000-0000-000000000001','A1','writing','translation',
   'Traduce: "Sí".',
   $j${"source":"Sí"}$j$::jsonb, $j${"value":"Yes","accepted":["yes"]}$j$::jsonb,
   0.15, ARRAY['unidad1','cortesia','writing']),
 ('42000000-0000-0000-0000-000000000007','20000000-0000-0000-0000-000000000001','A1','writing','word_bank',
   'Arma la frase: "Thank you very much".',
   $j${"tiles":["Thank","you","very","much","please"]}$j$::jsonb, $j${"value":"Thank you very much","sequence":["Thank","you","very","much"]}$j$::jsonb,
   0.20, ARRAY['unidad1','cortesia','writing']),
 ('42000000-0000-0000-0000-000000000008','20000000-0000-0000-0000-000000000001','A1','speaking','speaking_read_aloud',
   'Lee en voz alta:',
   $j${"text":"Thank you very much!"}$j$::jsonb, $j${"expected":"Thank you very much!"}$j$::jsonb,
   0.10, ARRAY['unidad1','cortesia','speaking'])
on conflict (id) do nothing;

-- ── Ejercicios: Lección 1.3 — Tu nombre ─────────────────────────────────────
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
 ('43000000-0000-0000-0000-000000000001','20000000-0000-0000-0000-000000000001','A1','reading','multiple_choice',
   '"My name is Ana" significa…',
   $j${"options":["Mi nombre es Ana","Soy de Ana","Mi amiga Ana"]}$j$::jsonb, $j${"value":"Mi nombre es Ana"}$j$::jsonb,
   0.15, ARRAY['unidad1','nombre','reading']),
 ('43000000-0000-0000-0000-000000000002','20000000-0000-0000-0000-000000000001','A1','writing','reorder',
   'Ordena las palabras para formar la oración.',
   $j${"tiles":["name","My","is","Ana"]}$j$::jsonb, $j${"value":"My name is Ana"}$j$::jsonb,
   0.20, ARRAY['unidad1','nombre','writing']),
 ('43000000-0000-0000-0000-000000000003','20000000-0000-0000-0000-000000000001','A1','writing','translation',
   'Traduce: "Mi nombre es Carlos".',
   $j${"source":"Mi nombre es Carlos"}$j$::jsonb, $j${"value":"My name is Carlos"}$j$::jsonb,
   0.20, ARRAY['unidad1','nombre','writing']),
 ('43000000-0000-0000-0000-000000000004','20000000-0000-0000-0000-000000000001','A1','reading','multiple_choice',
   'Responde a "What''s your name?"',
   $j${"options":["I''m fine","My name is Tom","Goodbye"]}$j$::jsonb, $j${"value":"My name is Tom"}$j$::jsonb,
   0.15, ARRAY['unidad1','nombre','reading']),
 ('43000000-0000-0000-0000-000000000005','20000000-0000-0000-0000-000000000001','A1','reading','cloze',
   'Completa: "What''s ___ name?"',
   $j${"text":"What''s ___ name?"}$j$::jsonb, $j${"value":"your","accepted":["your"]}$j$::jsonb,
   0.15, ARRAY['unidad1','nombre','reading']),
 ('43000000-0000-0000-0000-000000000006','20000000-0000-0000-0000-000000000001','A1','listening','listening',
   'Escucha la pregunta y elige la respuesta correcta.',
   $j${"audio_url":"audio/a1/whats_your_name.mp3","options":["My name is Sara","I''m from Peru","Thank you"]}$j$::jsonb, $j${"value":"My name is Sara"}$j$::jsonb,
   0.20, ARRAY['unidad1','nombre','listening']),
 ('43000000-0000-0000-0000-000000000007','20000000-0000-0000-0000-000000000001','A1','writing','word_bank',
   'Arma la pregunta: "What is your name".',
   $j${"tiles":["What","is","your","name","my"]}$j$::jsonb, $j${"value":"What is your name","sequence":["What","is","your","name"]}$j$::jsonb,
   0.20, ARRAY['unidad1','nombre','writing']),
 ('43000000-0000-0000-0000-000000000008','20000000-0000-0000-0000-000000000001','A1','speaking','speaking_read_aloud',
   'Lee en voz alta:',
   $j${"text":"My name is Ana."}$j$::jsonb, $j${"expected":"My name is Ana."}$j$::jsonb,
   0.10, ARRAY['unidad1','nombre','speaking'])
on conflict (id) do nothing;

-- ── Ejercicios: Lección 1.4 — Presentarte (to be) ───────────────────────────
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
 ('44000000-0000-0000-0000-000000000001','20000000-0000-0000-0000-000000000001','A1','writing','cloze',
   'Completa: "I ___ Ana."',
   $j${"text":"I ___ Ana."}$j$::jsonb, $j${"value":"am","accepted":["am"]}$j$::jsonb,
   0.15, ARRAY['unidad1','to_be','writing']),
 ('44000000-0000-0000-0000-000000000002','20000000-0000-0000-0000-000000000001','A1','reading','match',
   'Empareja el pronombre con su forma de "to be".',
   $j${"pairs":[{"en":"I","es":"am"},{"en":"you","es":"are"}]}$j$::jsonb,
   $j${"pairs":[["I","am"],["you","are"]]}$j$::jsonb,
   0.15, ARRAY['unidad1','to_be','reading']),
 ('44000000-0000-0000-0000-000000000003','20000000-0000-0000-0000-000000000001','A1','reading','multiple_choice',
   '"Nice to meet you" significa…',
   $j${"options":["Buenas noches","Mucho gusto","Hasta luego"]}$j$::jsonb, $j${"value":"Mucho gusto"}$j$::jsonb,
   0.15, ARRAY['unidad1','to_be','reading']),
 ('44000000-0000-0000-0000-000000000004','20000000-0000-0000-0000-000000000001','A1','reading','cloze',
   'Completa: "You ___ my friend."',
   $j${"text":"You ___ my friend."}$j$::jsonb, $j${"value":"are","accepted":["are"]}$j$::jsonb,
   0.15, ARRAY['unidad1','to_be','reading']),
 ('44000000-0000-0000-0000-000000000005','20000000-0000-0000-0000-000000000001','A1','reading','multiple_choice',
   'Responde a "How are you?"',
   $j${"options":["I''m fine, thanks","My name is Ana","Goodbye"]}$j$::jsonb, $j${"value":"I''m fine, thanks"}$j$::jsonb,
   0.15, ARRAY['unidad1','to_be','reading']),
 ('44000000-0000-0000-0000-000000000006','20000000-0000-0000-0000-000000000001','A1','listening','listening',
   'Escucha y elige el significado correcto.',
   $j${"audio_url":"audio/a1/nice_to_meet_you.mp3","options":["Mucho gusto","Gracias","Adiós"]}$j$::jsonb, $j${"value":"Mucho gusto"}$j$::jsonb,
   0.20, ARRAY['unidad1','to_be','listening']),
 ('44000000-0000-0000-0000-000000000007','20000000-0000-0000-0000-000000000001','A1','writing','word_bank',
   'Arma la frase: "Nice to meet you".',
   $j${"tiles":["Nice","to","meet","you","see"]}$j$::jsonb, $j${"value":"Nice to meet you","sequence":["Nice","to","meet","you"]}$j$::jsonb,
   0.20, ARRAY['unidad1','to_be','writing']),
 ('44000000-0000-0000-0000-000000000008','20000000-0000-0000-0000-000000000001','A1','speaking','speaking_read_aloud',
   'Lee en voz alta:',
   $j${"text":"Hi, I''m Ana. Nice to meet you!"}$j$::jsonb, $j${"expected":"Hi, I''m Ana. Nice to meet you!"}$j$::jsonb,
   0.10, ARRAY['unidad1','to_be','speaking'])
on conflict (id) do nothing;

-- ── lesson_items: composición de cada lección (orden) ───────────────────────
-- Lección 1.1
insert into lesson_items (lesson_id, item_id, order_index) values
 ('40000000-0000-0000-0000-000000000011','41000000-0000-0000-0000-000000000001',1),
 ('40000000-0000-0000-0000-000000000011','41000000-0000-0000-0000-000000000002',2),
 ('40000000-0000-0000-0000-000000000011','41000000-0000-0000-0000-000000000003',3),
 ('40000000-0000-0000-0000-000000000011','41000000-0000-0000-0000-000000000004',4),
 ('40000000-0000-0000-0000-000000000011','41000000-0000-0000-0000-000000000005',5),
 ('40000000-0000-0000-0000-000000000011','41000000-0000-0000-0000-000000000006',6),
 ('40000000-0000-0000-0000-000000000011','41000000-0000-0000-0000-000000000007',7),
 ('40000000-0000-0000-0000-000000000011','41000000-0000-0000-0000-000000000008',8),
-- Lección 1.2
 ('40000000-0000-0000-0000-000000000012','42000000-0000-0000-0000-000000000001',1),
 ('40000000-0000-0000-0000-000000000012','42000000-0000-0000-0000-000000000002',2),
 ('40000000-0000-0000-0000-000000000012','42000000-0000-0000-0000-000000000003',3),
 ('40000000-0000-0000-0000-000000000012','42000000-0000-0000-0000-000000000004',4),
 ('40000000-0000-0000-0000-000000000012','42000000-0000-0000-0000-000000000005',5),
 ('40000000-0000-0000-0000-000000000012','42000000-0000-0000-0000-000000000006',6),
 ('40000000-0000-0000-0000-000000000012','42000000-0000-0000-0000-000000000007',7),
 ('40000000-0000-0000-0000-000000000012','42000000-0000-0000-0000-000000000008',8),
-- Lección 1.3
 ('40000000-0000-0000-0000-000000000013','43000000-0000-0000-0000-000000000001',1),
 ('40000000-0000-0000-0000-000000000013','43000000-0000-0000-0000-000000000002',2),
 ('40000000-0000-0000-0000-000000000013','43000000-0000-0000-0000-000000000003',3),
 ('40000000-0000-0000-0000-000000000013','43000000-0000-0000-0000-000000000004',4),
 ('40000000-0000-0000-0000-000000000013','43000000-0000-0000-0000-000000000005',5),
 ('40000000-0000-0000-0000-000000000013','43000000-0000-0000-0000-000000000006',6),
 ('40000000-0000-0000-0000-000000000013','43000000-0000-0000-0000-000000000007',7),
 ('40000000-0000-0000-0000-000000000013','43000000-0000-0000-0000-000000000008',8),
-- Lección 1.4
 ('40000000-0000-0000-0000-000000000014','44000000-0000-0000-0000-000000000001',1),
 ('40000000-0000-0000-0000-000000000014','44000000-0000-0000-0000-000000000002',2),
 ('40000000-0000-0000-0000-000000000014','44000000-0000-0000-0000-000000000003',3),
 ('40000000-0000-0000-0000-000000000014','44000000-0000-0000-0000-000000000004',4),
 ('40000000-0000-0000-0000-000000000014','44000000-0000-0000-0000-000000000005',5),
 ('40000000-0000-0000-0000-000000000014','44000000-0000-0000-0000-000000000006',6),
 ('40000000-0000-0000-0000-000000000014','44000000-0000-0000-0000-000000000007',7),
 ('40000000-0000-0000-0000-000000000014','44000000-0000-0000-0000-000000000008',8),
-- Checkpoint 1.5: 10 ítems del banco de la unidad, cubriendo las 4 habilidades
 ('40000000-0000-0000-0000-000000000015','41000000-0000-0000-0000-000000000002',1),  -- mc reading
 ('40000000-0000-0000-0000-000000000015','42000000-0000-0000-0000-000000000003',2),  -- cloze writing
 ('40000000-0000-0000-0000-000000000015','41000000-0000-0000-0000-000000000004',3),  -- listening
 ('40000000-0000-0000-0000-000000000015','43000000-0000-0000-0000-000000000002',4),  -- reorder writing
 ('40000000-0000-0000-0000-000000000015','43000000-0000-0000-0000-000000000004',5),  -- mc reading
 ('40000000-0000-0000-0000-000000000015','44000000-0000-0000-0000-000000000001',6),  -- cloze writing
 ('40000000-0000-0000-0000-000000000015','42000000-0000-0000-0000-000000000006',7),  -- translation writing
 ('40000000-0000-0000-0000-000000000015','42000000-0000-0000-0000-000000000001',8),  -- match reading
 ('40000000-0000-0000-0000-000000000015','44000000-0000-0000-0000-000000000008',9),  -- speaking
 ('40000000-0000-0000-0000-000000000015','44000000-0000-0000-0000-000000000003',10)  -- mc reading
on conflict (lesson_id, item_id) do nothing;

-- ── Banco del Test de Ubicación (placement) ─────────────────────────────────
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
 -- A1
 ('4f000000-0000-0000-0000-000000000001','20000000-0000-0000-0000-000000000001','A1','reading','multiple_choice',
   '"Hello" significa…', $j${"options":["hola","gracias","adiós"]}$j$::jsonb, $j${"value":"hola"}$j$::jsonb,
   0.10, ARRAY['placement','a1','vocab']),
 ('4f000000-0000-0000-0000-000000000002','20000000-0000-0000-0000-000000000001','A1','writing','cloze',
   'I ___ a student.', $j${"text":"I ___ a student.","options":["am","is","are"]}$j$::jsonb, $j${"value":"am"}$j$::jsonb,
   0.15, ARRAY['placement','a1','grammar','to_be']),
 ('4f000000-0000-0000-0000-000000000003','20000000-0000-0000-0000-000000000001','A1','reading','multiple_choice',
   'Lo contrario de "yes" es…', $j${"options":["no","please","hi"]}$j$::jsonb, $j${"value":"no"}$j$::jsonb,
   0.10, ARRAY['placement','a1','vocab']),
 ('4f000000-0000-0000-0000-000000000004','20000000-0000-0000-0000-000000000001','A1','reading','multiple_choice',
   '"Thank you" significa…', $j${"options":["perdón","gracias","hola"]}$j$::jsonb, $j${"value":"gracias"}$j$::jsonb,
   0.10, ARRAY['placement','a1','vocab']),
 -- A2
 ('4f000000-0000-0000-0000-000000000005','20000000-0000-0000-0000-000000000001','A2','writing','cloze',
   'She ___ to school every day.', $j${"text":"She ___ to school every day.","options":["go","goes","going"]}$j$::jsonb, $j${"value":"goes"}$j$::jsonb,
   0.40, ARRAY['placement','a2','grammar','present_simple']),
 ('4f000000-0000-0000-0000-000000000006','20000000-0000-0000-0000-000000000001','A2','writing','cloze',
   'I''m from Peru. I ___ in Lima.', $j${"text":"I''m from Peru. I ___ in Lima.","options":["live","lives","living"]}$j$::jsonb, $j${"value":"live"}$j$::jsonb,
   0.40, ARRAY['placement','a2','grammar','present_simple']),
 ('4f000000-0000-0000-0000-000000000007','20000000-0000-0000-0000-000000000001','A2','reading','multiple_choice',
   'Yesterday I ___ pizza.', $j${"options":["eat","ate","eaten"]}$j$::jsonb, $j${"value":"ate"}$j$::jsonb,
   0.45, ARRAY['placement','a2','grammar','past_simple']),
 ('4f000000-0000-0000-0000-000000000008','20000000-0000-0000-0000-000000000001','A2','writing','cloze',
   'There ___ two books on the table.', $j${"text":"There ___ two books on the table.","options":["is","are","be"]}$j$::jsonb, $j${"value":"are"}$j$::jsonb,
   0.40, ARRAY['placement','a2','grammar','there_be']),
 -- B1
 ('4f000000-0000-0000-0000-000000000009','20000000-0000-0000-0000-000000000001','B1','writing','cloze',
   'If it rains, I ___ at home.', $j${"text":"If it rains, I ___ at home.","options":["stay","will stay","stayed"]}$j$::jsonb, $j${"value":"will stay"}$j$::jsonb,
   0.60, ARRAY['placement','b1','grammar','first_conditional']),
 ('4f000000-0000-0000-0000-000000000010','20000000-0000-0000-0000-000000000001','B1','reading','multiple_choice',
   'She has worked here ___ 2020.', $j${"options":["since","for","from"]}$j$::jsonb, $j${"value":"since"}$j$::jsonb,
   0.60, ARRAY['placement','b1','grammar','since_for']),
 ('4f000000-0000-0000-0000-000000000011','20000000-0000-0000-0000-000000000001','B1','writing','cloze',
   'I have ___ been to Japan.', $j${"text":"I have ___ been to Japan.","options":["never","ever","already"]}$j$::jsonb, $j${"value":"never"}$j$::jsonb,
   0.60, ARRAY['placement','b1','grammar','present_perfect']),
 ('4f000000-0000-0000-0000-000000000012','20000000-0000-0000-0000-000000000001','B1','reading','multiple_choice',
   'I''m used to ___ up early.', $j${"options":["get","getting","got"]}$j$::jsonb, $j${"value":"getting"}$j$::jsonb,
   0.65, ARRAY['placement','b1','grammar','gerund']),
 -- B2
 ('4f000000-0000-0000-0000-000000000013','20000000-0000-0000-0000-000000000001','B2','writing','cloze',
   'I wish I ___ more time.', $j${"text":"I wish I ___ more time.","options":["have","had","will have"]}$j$::jsonb, $j${"value":"had"}$j$::jsonb,
   0.80, ARRAY['placement','b2','grammar','wish']),
 ('4f000000-0000-0000-0000-000000000014','20000000-0000-0000-0000-000000000001','B2','reading','multiple_choice',
   'He was ___ to finish on time.', $j${"options":["able","can","capable of"]}$j$::jsonb, $j${"value":"able"}$j$::jsonb,
   0.80, ARRAY['placement','b2','vocab','able_to']),
 ('4f000000-0000-0000-0000-000000000015','20000000-0000-0000-0000-000000000001','B2','writing','cloze',
   'If I ___ known, I would have told you.', $j${"text":"If I ___ known, I would have told you.","options":["have","had","did"]}$j$::jsonb, $j${"value":"had"}$j$::jsonb,
   0.85, ARRAY['placement','b2','grammar','third_conditional']),
 ('4f000000-0000-0000-0000-000000000016','20000000-0000-0000-0000-000000000001','B2','reading','multiple_choice',
   'She said she ___ tired.', $j${"options":["is","was","be"]}$j$::jsonb, $j${"value":"was"}$j$::jsonb,
   0.80, ARRAY['placement','b2','grammar','reported_speech'])
on conflict (id) do nothing;

-- ── Vocabulario de la Unidad 1 (alimenta el SRS) ────────────────────────────
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('60000000-0000-0000-0000-000000000001','20000000-0000-0000-0000-000000000001','hello','hola',1,'interjection'),
 ('60000000-0000-0000-0000-000000000002','20000000-0000-0000-0000-000000000001','hi','hola',2,'interjection'),
 ('60000000-0000-0000-0000-000000000003','20000000-0000-0000-0000-000000000001','good morning','buenos días',3,'phrase'),
 ('60000000-0000-0000-0000-000000000004','20000000-0000-0000-0000-000000000001','good night','buenas noches',4,'phrase'),
 ('60000000-0000-0000-0000-000000000005','20000000-0000-0000-0000-000000000001','goodbye','adiós',5,'interjection'),
 ('60000000-0000-0000-0000-000000000006','20000000-0000-0000-0000-000000000001','bye','chao',6,'interjection'),
 ('60000000-0000-0000-0000-000000000007','20000000-0000-0000-0000-000000000001','please','por favor',7,'adverb'),
 ('60000000-0000-0000-0000-000000000008','20000000-0000-0000-0000-000000000001','thank you','gracias',8,'phrase'),
 ('60000000-0000-0000-0000-000000000009','20000000-0000-0000-0000-000000000001','sorry','perdón',9,'interjection'),
 ('60000000-0000-0000-0000-000000000010','20000000-0000-0000-0000-000000000001','excuse me','disculpa',10,'phrase'),
 ('60000000-0000-0000-0000-000000000011','20000000-0000-0000-0000-000000000001','yes','sí',11,'adverb'),
 ('60000000-0000-0000-0000-000000000012','20000000-0000-0000-0000-000000000001','no','no',12,'adverb'),
 ('60000000-0000-0000-0000-000000000013','20000000-0000-0000-0000-000000000001','name','nombre',13,'noun'),
 ('60000000-0000-0000-0000-000000000014','20000000-0000-0000-0000-000000000001','my','mi',14,'determiner'),
 ('60000000-0000-0000-0000-000000000015','20000000-0000-0000-0000-000000000001','your','tu',15,'determiner'),
 ('60000000-0000-0000-0000-000000000016','20000000-0000-0000-0000-000000000001','what','qué',16,'pronoun'),
 ('60000000-0000-0000-0000-000000000017','20000000-0000-0000-0000-000000000001','I','yo',17,'pronoun'),
 ('60000000-0000-0000-0000-000000000018','20000000-0000-0000-0000-000000000001','you','tú',18,'pronoun'),
 ('60000000-0000-0000-0000-000000000019','20000000-0000-0000-0000-000000000001','am','soy/estoy',19,'verb'),
 ('60000000-0000-0000-0000-000000000020','20000000-0000-0000-0000-000000000001','are','eres/estás',20,'verb'),
 ('60000000-0000-0000-0000-000000000021','20000000-0000-0000-0000-000000000001','is','es/está',21,'verb'),
 ('60000000-0000-0000-0000-000000000022','20000000-0000-0000-0000-000000000001','fine','bien',22,'adjective'),
 ('60000000-0000-0000-0000-000000000023','20000000-0000-0000-0000-000000000001','nice to meet you','mucho gusto',23,'phrase'),
 ('60000000-0000-0000-0000-000000000024','20000000-0000-0000-0000-000000000001','friend','amigo',24,'noun'),
 ('60000000-0000-0000-0000-000000000025','20000000-0000-0000-0000-000000000001','how are you','cómo estás',25,'phrase'),
 ('60000000-0000-0000-0000-000000000026','20000000-0000-0000-0000-000000000001','my name is','mi nombre es',26,'phrase')
on conflict (id) do nothing;

-- ── Plantillas de Matix (copys por estilo × trigger × escalón × canal) ───────
insert into notification_templates (coach_style, trigger_type, escalation_step, channel, copy) values
 -- Racha en riesgo · push · escalón 1
 ('mano_dura','streak_risk',1,'push','Tu racha está en juego. Una lección, ahora.'),
 ('positivo', 'streak_risk',1,'push','¡No pierdas tu racha! Una lección rápida y sigues 🔥'),
 ('rezago',   'streak_risk',1,'push','Cuidado: tu racha de {dias} días está en riesgo.'),
 ('suave',    'streak_risk',1,'push','Cuando puedas, una lección corta mantiene tu racha 🙂'),
 -- Racha en riesgo · push · escalón 2
 ('mano_dura','streak_risk',2,'push','{dias} días de racha. No los tires hoy. Entra ya.'),
 ('positivo', 'streak_risk',2,'push','¡{dias} días imparable! No rompas la magia, vas genial 💪'),
 ('rezago',   'streak_risk',2,'push','Quedan horas para salvar tu racha de {dias} días.'),
 ('suave',    'streak_risk',2,'push','Tu racha de {dias} días sigue viva — una lección y listo.'),
 -- Racha en riesgo · push · escalón 3
 ('mano_dura','streak_risk',3,'push','Última llamada. Pierdes tu racha si no entras ahora.'),
 ('positivo', 'streak_risk',3,'push','¡Justo a tiempo! Salva tu racha y celébralo 🎉'),
 ('rezago',   'streak_risk',3,'push','Si no entras hoy, tu racha vuelve a cero.'),
 ('suave',    'streak_risk',3,'push','Si hoy no puedes, no pasa nada — mañana retomamos 🙂'),
 -- Meta diaria sin cumplir · push
 ('mano_dura','goal_unmet',1,'push','Te falta tu meta de hoy. Sin excusas.'),
 ('positivo', 'goal_unmet',1,'push','¡Casi! Te falta poquito para tu meta de hoy 💪'),
 ('rezago',   'goal_unmet',1,'push','Vas {x}/{meta} XP. No te quedes corto hoy.'),
 ('suave',    'goal_unmet',1,'push','Cuando tengas un rato, completa tu meta de hoy 🙂'),
 -- Win-back · push · escalón 1
 ('mano_dura','winback',1,'push','{dias} días fuera. Tu inglés no avanza solo. Vuelve.'),
 ('positivo', 'winback',1,'push','¡Te extrañamos! Retomas justo donde lo dejaste 💜'),
 ('rezago',   'winback',1,'push','{dias} días sin practicar = tu meta se aleja.'),
 ('suave',    'winback',1,'push','Aquí seguimos cuando quieras. Una lección corta basta 🙂'),
 -- Win-back · push · escalón 2
 ('mano_dura','winback',2,'push','Llevas {dias} días. Decide hoy: ¿avanzas o lo dejas?'),
 ('positivo', 'winback',2,'push','Vuelve hoy y recupera tu ritmo — ¡tú puedes! 🔥'),
 ('rezago',   'winback',2,'push','Tu plan a {meta} se atrasó {dias} días. Recupéralo.'),
 ('suave',    'winback',2,'push','Sin presión: una lección de 2 minutos y vuelves al ruedo 🙂'),
 -- Cuenta regresiva a examen · push
 ('mano_dura','exam_countdown',1,'push','Examen en {dias} días. Repasa hoy. Sin excusas.'),
 ('positivo', 'exam_countdown',1,'push','¡Examen en {dias} días! Un repaso y vas a brillar 💪'),
 ('rezago',   'exam_countdown',1,'push','Examen en {dias} días y vas flojo en {skill}. No lo dejes.'),
 ('suave',    'exam_countdown',1,'push','Tu examen es en {dias} días; un repaso tranquilo te deja listo.'),
 -- Atraso vs plan · push
 ('mano_dura','behind_plan',1,'push','Vas atrás de tu plan. Sube el ritmo o no llegas.'),
 ('positivo', 'behind_plan',1,'push','Un empujón y vuelves a tu ritmo hacia {meta} 💪'),
 ('rezago',   'behind_plan',1,'push','Vas {dias} días atrás de tu plan a {meta}.'),
 ('suave',    'behind_plan',1,'push','Si subes un poco el ritmo, llegas a tu meta a tiempo 🙂'),
 -- Resumen semanal · correo (asunto por estilo)
 ('mano_dura','behind_plan',1,'email','Tu semana: lo que hiciste y lo que falta'),
 ('positivo', 'behind_plan',1,'email','¡Mira tu progreso de la semana! 🎉'),
 ('rezago',   'behind_plan',1,'email','Tu avance vs tu meta esta semana'),
 ('suave',    'behind_plan',1,'email','Un resumen tranquilo de tu semana 🙂'),
 -- Logro desbloqueado · push (positivo para todos los estilos)
 ('mano_dura','achievement',1,'push','🏅 ¡Desbloqueaste {logro}! Sigue así.'),
 ('positivo', 'achievement',1,'push','🏅 ¡Desbloqueaste {logro}! Sigue así.'),
 ('rezago',   'achievement',1,'push','🏅 ¡Desbloqueaste {logro}! Sigue así.'),
 ('suave',    'achievement',1,'push','🏅 ¡Desbloqueaste {logro}! Sigue así.'),
 -- Liga (te pasaron) · push
 ('mano_dura','league',1,'push','Te pasaron en la liga. ¿Lo vas a permitir?'),
 ('positivo', 'league',1,'push','¡{n} te pasaron! Recupera tu lugar, tú puedes 💪'),
 ('rezago',   'league',1,'push','{n} de tu liga te pasaron esta semana.'),
 ('suave',    'league',1,'push','Alguien te pasó en la liga — cuando puedas, suma XP 🙂')
on conflict (coach_style, trigger_type, escalation_step, channel) do nothing;

commit;
