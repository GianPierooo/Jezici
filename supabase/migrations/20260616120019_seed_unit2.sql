-- ============================================================================
-- Jezici · Migración 019 · Siembra Unidad 2 (A1) "Números, edad y de dónde eres"
-- ----------------------------------------------------------------------------
-- Fuente: Jezici_Contenido_Unidad2.md. Mismo formato que la Unidad 1 (seed.sql).
-- Va DESPUÉS de la Unidad 1 (order_index 2). El gating del paso F la desbloquea
-- al aprobar el checkpoint de la Unidad 1. Idempotente (UUIDs fijos + ON CONFLICT).
-- Audios = placeholders.
-- ============================================================================

begin;

-- ── Unidad 2 ────────────────────────────────────────────────────────────────
insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values
  ('30000000-0000-0000-0000-000000000002',
   '20000000-0000-0000-0000-000000000001',
   'A1', 2, 'Números, edad y de dónde eres', '#00B894', 'public')
on conflict (course_id, order_index) do nothing;

-- ── Lecciones 2.1–2.5 (nodos del mapa) ──────────────────────────────────────
insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values
  ('40000000-0000-0000-0000-000000000021','30000000-0000-0000-0000-000000000002', 1, 'Números 1–10', 'one, two, three … ten', 'lesson', 15),
  ('40000000-0000-0000-0000-000000000022','30000000-0000-0000-0000-000000000002', 2, 'Números 11–20 y la edad', 'eleven … twenty · "How old are you?"', 'lesson', 15),
  ('40000000-0000-0000-0000-000000000023','30000000-0000-0000-0000-000000000002', 3, 'Países y nacionalidades', 'Peru/Peruvian, England/English · "Where are you from?"', 'lesson', 15),
  ('40000000-0000-0000-0000-000000000024','30000000-0000-0000-0000-000000000002', 4, 'Preguntas con to be', 'Are you…? · "Yes, I am" / "No, I''m not"', 'lesson', 15),
  ('40000000-0000-0000-0000-000000000025','30000000-0000-0000-0000-000000000002', 5, '🏁 Checkpoint Unidad 2', 'Cronometrado · mezcla las 4 habilidades · umbral 80%.', 'checkpoint', 40)
on conflict (unit_id, order_index) do nothing;

-- ── Examen de checkpoint (definición) ───────────────────────────────────────
insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values
  ('50000000-0000-0000-0000-000000000002',
   '20000000-0000-0000-0000-000000000001', 'checkpoint', 'A1',
   '30000000-0000-0000-0000-000000000002', 300, 0.80,
   $j${"skills":["reading","listening","writing","speaking"],"item_count":10,"randomize":true}$j$::jsonb)
on conflict (id) do nothing;

-- ── Ejercicios: Lección 2.1 — Números 1–10 ──────────────────────────────────
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
 ('45000000-0000-0000-0000-000000000001','20000000-0000-0000-0000-000000000001','A1','reading','match',
   'Empareja cada número con su cifra.',
   $j${"pairs":[{"en":"three","es":"3"},{"en":"seven","es":"7"},{"en":"ten","es":"10"}]}$j$::jsonb,
   $j${"pairs":[["three","3"],["seven","7"],["ten","10"]]}$j$::jsonb,
   0.10, ARRAY['unidad2','numeros','reading']),
 ('45000000-0000-0000-0000-000000000002','20000000-0000-0000-0000-000000000001','A1','reading','multiple_choice',
   '¿Cómo se dice «5»?',
   $j${"options":["four","five","nine"]}$j$::jsonb, $j${"value":"five"}$j$::jsonb,
   0.10, ARRAY['unidad2','numeros','reading']),
 ('45000000-0000-0000-0000-000000000003','20000000-0000-0000-0000-000000000001','A1','listening','listening',
   'Escucha y elige el número.',
   $j${"audio_url":"audio/a1/eight.mp3","options":["six","eight","ten"]}$j$::jsonb, $j${"value":"eight"}$j$::jsonb,
   0.15, ARRAY['unidad2','numeros','listening']),
 ('45000000-0000-0000-0000-000000000004','20000000-0000-0000-0000-000000000001','A1','writing','cloze',
   'Completa: "I have ___ books." (2)',
   $j${"text":"I have ___ books."}$j$::jsonb, $j${"value":"two","accepted":["two"]}$j$::jsonb,
   0.15, ARRAY['unidad2','numeros','writing']),
 ('45000000-0000-0000-0000-000000000005','20000000-0000-0000-0000-000000000001','A1','reading','multiple_choice',
   '«Seven» significa…',
   $j${"options":["6","7","8"]}$j$::jsonb, $j${"value":"7"}$j$::jsonb,
   0.10, ARRAY['unidad2','numeros','reading']),
 ('45000000-0000-0000-0000-000000000006','20000000-0000-0000-0000-000000000001','A1','writing','translation',
   'Traduce: "cuatro".',
   $j${"source":"cuatro"}$j$::jsonb, $j${"value":"four","accepted":["four"]}$j$::jsonb,
   0.15, ARRAY['unidad2','numeros','writing']),
 ('45000000-0000-0000-0000-000000000007','20000000-0000-0000-0000-000000000001','A1','writing','word_bank',
   'Arma la frase: "Tengo tres gatos".',
   $j${"tiles":["I","have","three","cats","two"]}$j$::jsonb, $j${"value":"I have three cats","sequence":["I","have","three","cats"]}$j$::jsonb,
   0.20, ARRAY['unidad2','numeros','writing']),
 ('45000000-0000-0000-0000-000000000008','20000000-0000-0000-0000-000000000001','A1','speaking','speaking_read_aloud',
   'Lee en voz alta:',
   $j${"text":"One, two, three, four, five!"}$j$::jsonb, $j${"expected":"One, two, three, four, five!"}$j$::jsonb,
   0.10, ARRAY['unidad2','numeros','speaking'])
on conflict (id) do nothing;

-- ── Ejercicios: Lección 2.2 — Números 11–20 y la edad ───────────────────────
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
 ('46000000-0000-0000-0000-000000000001','20000000-0000-0000-0000-000000000001','A1','reading','multiple_choice',
   '«Twelve» significa…',
   $j${"options":["2","12","20"]}$j$::jsonb, $j${"value":"12"}$j$::jsonb,
   0.10, ARRAY['unidad2','edad','reading']),
 ('46000000-0000-0000-0000-000000000002','20000000-0000-0000-0000-000000000001','A1','reading','multiple_choice',
   'Responde a «How old are you?»',
   $j${"options":["I''m fine","I''m twenty years old","My name is Tom"]}$j$::jsonb, $j${"value":"I''m twenty years old"}$j$::jsonb,
   0.15, ARRAY['unidad2','edad','reading']),
 ('46000000-0000-0000-0000-000000000003','20000000-0000-0000-0000-000000000001','A1','reading','cloze',
   'Completa: "How ___ are you?"',
   $j${"text":"How ___ are you?"}$j$::jsonb, $j${"value":"old","accepted":["old"]}$j$::jsonb,
   0.15, ARRAY['unidad2','edad','reading']),
 ('46000000-0000-0000-0000-000000000004','20000000-0000-0000-0000-000000000001','A1','listening','listening',
   'Escucha y elige el número.',
   $j${"audio_url":"audio/a1/fifteen.mp3","options":["thirteen","fifteen","fifty"]}$j$::jsonb, $j${"value":"fifteen"}$j$::jsonb,
   0.15, ARRAY['unidad2','edad','listening']),
 ('46000000-0000-0000-0000-000000000005','20000000-0000-0000-0000-000000000001','A1','writing','reorder',
   'Ordena las palabras para formar la oración.',
   $j${"tiles":["old","I''m","years","twenty"]}$j$::jsonb, $j${"value":"I''m twenty years old"}$j$::jsonb,
   0.20, ARRAY['unidad2','edad','writing']),
 ('46000000-0000-0000-0000-000000000006','20000000-0000-0000-0000-000000000001','A1','writing','translation',
   'Traduce: "¿Cuántos años tienes?"',
   $j${"source":"¿Cuántos años tienes?"}$j$::jsonb, $j${"value":"How old are you?","accepted":["how old are you","how old are you?"]}$j$::jsonb,
   0.20, ARRAY['unidad2','edad','writing']),
 ('46000000-0000-0000-0000-000000000007','20000000-0000-0000-0000-000000000001','A1','reading','multiple_choice',
   '«Twenty» significa…',
   $j${"options":["2","12","20"]}$j$::jsonb, $j${"value":"20"}$j$::jsonb,
   0.10, ARRAY['unidad2','edad','reading']),
 ('46000000-0000-0000-0000-000000000008','20000000-0000-0000-0000-000000000001','A1','speaking','speaking_read_aloud',
   'Lee en voz alta:',
   $j${"text":"I''m twenty years old."}$j$::jsonb, $j${"expected":"I''m twenty years old."}$j$::jsonb,
   0.10, ARRAY['unidad2','edad','speaking'])
on conflict (id) do nothing;

-- ── Ejercicios: Lección 2.3 — Países y nacionalidades ───────────────────────
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
 ('47000000-0000-0000-0000-000000000001','20000000-0000-0000-0000-000000000001','A1','reading','match',
   'Empareja país con nacionalidad.',
   $j${"pairs":[{"en":"Peru","es":"Peruvian"},{"en":"Brazil","es":"Brazilian"},{"en":"England","es":"English"}]}$j$::jsonb,
   $j${"pairs":[["Peru","Peruvian"],["Brazil","Brazilian"],["England","English"]]}$j$::jsonb,
   0.15, ARRAY['unidad2','paises','reading']),
 ('47000000-0000-0000-0000-000000000002','20000000-0000-0000-0000-000000000001','A1','reading','multiple_choice',
   'Responde a «Where are you from?»',
   $j${"options":["I''m fine","I''m from Peru","I''m twenty"]}$j$::jsonb, $j${"value":"I''m from Peru"}$j$::jsonb,
   0.15, ARRAY['unidad2','paises','reading']),
 ('47000000-0000-0000-0000-000000000003','20000000-0000-0000-0000-000000000001','A1','reading','cloze',
   'Completa: "Where are you ___?"',
   $j${"text":"Where are you ___?"}$j$::jsonb, $j${"value":"from","accepted":["from"]}$j$::jsonb,
   0.15, ARRAY['unidad2','paises','reading']),
 ('47000000-0000-0000-0000-000000000004','20000000-0000-0000-0000-000000000001','A1','reading','multiple_choice',
   '«I''m American» significa…',
   $j${"options":["Soy de Inglaterra","Soy estadounidense","Soy brasileño"]}$j$::jsonb, $j${"value":"Soy estadounidense"}$j$::jsonb,
   0.15, ARRAY['unidad2','paises','reading']),
 ('47000000-0000-0000-0000-000000000005','20000000-0000-0000-0000-000000000001','A1','writing','translation',
   'Traduce: "Soy de Perú."',
   $j${"source":"Soy de Perú."}$j$::jsonb, $j${"value":"I''m from Peru","accepted":["i''m from peru","i am from peru","im from peru"]}$j$::jsonb,
   0.20, ARRAY['unidad2','paises','writing']),
 ('47000000-0000-0000-0000-000000000006','20000000-0000-0000-0000-000000000001','A1','listening','listening',
   'Escucha la pregunta y elige la respuesta correcta.',
   $j${"audio_url":"audio/a1/where_are_you_from.mp3","options":["I''m from Brazil","I''m fine","Thank you"]}$j$::jsonb, $j${"value":"I''m from Brazil"}$j$::jsonb,
   0.20, ARRAY['unidad2','paises','listening']),
 ('47000000-0000-0000-0000-000000000007','20000000-0000-0000-0000-000000000001','A1','writing','word_bank',
   'Arma la pregunta: "¿De dónde eres?"',
   $j${"tiles":["Where","are","you","from","is"]}$j$::jsonb, $j${"value":"Where are you from","sequence":["Where","are","you","from"]}$j$::jsonb,
   0.20, ARRAY['unidad2','paises','writing']),
 ('47000000-0000-0000-0000-000000000008','20000000-0000-0000-0000-000000000001','A1','speaking','speaking_read_aloud',
   'Lee en voz alta:',
   $j${"text":"I''m from Peru. Where are you from?"}$j$::jsonb, $j${"expected":"I''m from Peru. Where are you from?"}$j$::jsonb,
   0.10, ARRAY['unidad2','paises','speaking'])
on conflict (id) do nothing;

-- ── Ejercicios: Lección 2.4 — Preguntas con to be ───────────────────────────
insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values
 ('48000000-0000-0000-0000-000000000001','20000000-0000-0000-0000-000000000001','A1','reading','cloze',
   'Completa: "___ you a student?"',
   $j${"text":"___ you a student?"}$j$::jsonb, $j${"value":"Are","accepted":["are"]}$j$::jsonb,
   0.15, ARRAY['unidad2','to_be','reading']),
 ('48000000-0000-0000-0000-000000000002','20000000-0000-0000-0000-000000000001','A1','reading','multiple_choice',
   'Respuesta corta (sí) a «Are you from Peru?»',
   $j${"options":["Yes, I do","Yes, I am","I''m fine"]}$j$::jsonb, $j${"value":"Yes, I am"}$j$::jsonb,
   0.15, ARRAY['unidad2','to_be','reading']),
 ('48000000-0000-0000-0000-000000000003','20000000-0000-0000-0000-000000000001','A1','writing','cloze',
   'Completa: "No, I''m ___."',
   $j${"text":"No, I''m ___."}$j$::jsonb, $j${"value":"not","accepted":["not"]}$j$::jsonb,
   0.15, ARRAY['unidad2','to_be','writing']),
 ('48000000-0000-0000-0000-000000000004','20000000-0000-0000-0000-000000000001','A1','reading','multiple_choice',
   '«Is she your friend?» pregunta sobre…',
   $j${"options":["él","ella","tú"]}$j$::jsonb, $j${"value":"ella"}$j$::jsonb,
   0.15, ARRAY['unidad2','to_be','reading']),
 ('48000000-0000-0000-0000-000000000005','20000000-0000-0000-0000-000000000001','A1','writing','reorder',
   'Ordena las palabras para formar la pregunta.',
   $j${"tiles":["you","Are","a","teacher"]}$j$::jsonb, $j${"value":"Are you a teacher"}$j$::jsonb,
   0.20, ARRAY['unidad2','to_be','writing']),
 ('48000000-0000-0000-0000-000000000006','20000000-0000-0000-0000-000000000001','A1','writing','translation',
   'Traduce: "¿Eres de Brasil?"',
   $j${"source":"¿Eres de Brasil?"}$j$::jsonb, $j${"value":"Are you from Brazil?","accepted":["are you from brazil","are you from brazil?"]}$j$::jsonb,
   0.20, ARRAY['unidad2','to_be','writing']),
 ('48000000-0000-0000-0000-000000000007','20000000-0000-0000-0000-000000000001','A1','listening','listening',
   'Escucha y elige el significado correcto.',
   $j${"audio_url":"audio/a1/whats_your_phone_number.mp3","options":["¿Cuál es tu número de teléfono?","¿De dónde eres?","¿Cuántos años tienes?"]}$j$::jsonb, $j${"value":"¿Cuál es tu número de teléfono?"}$j$::jsonb,
   0.20, ARRAY['unidad2','to_be','listening']),
 ('48000000-0000-0000-0000-000000000008','20000000-0000-0000-0000-000000000001','A1','speaking','speaking_read_aloud',
   'Lee en voz alta:',
   $j${"text":"Are you from Peru? Yes, I am."}$j$::jsonb, $j${"expected":"Are you from Peru? Yes, I am."}$j$::jsonb,
   0.10, ARRAY['unidad2','to_be','speaking'])
on conflict (id) do nothing;

-- ── lesson_items: composición de cada lección (orden) ───────────────────────
insert into lesson_items (lesson_id, item_id, order_index) values
-- Lección 2.1
 ('40000000-0000-0000-0000-000000000021','45000000-0000-0000-0000-000000000001',1),
 ('40000000-0000-0000-0000-000000000021','45000000-0000-0000-0000-000000000002',2),
 ('40000000-0000-0000-0000-000000000021','45000000-0000-0000-0000-000000000003',3),
 ('40000000-0000-0000-0000-000000000021','45000000-0000-0000-0000-000000000004',4),
 ('40000000-0000-0000-0000-000000000021','45000000-0000-0000-0000-000000000005',5),
 ('40000000-0000-0000-0000-000000000021','45000000-0000-0000-0000-000000000006',6),
 ('40000000-0000-0000-0000-000000000021','45000000-0000-0000-0000-000000000007',7),
 ('40000000-0000-0000-0000-000000000021','45000000-0000-0000-0000-000000000008',8),
-- Lección 2.2
 ('40000000-0000-0000-0000-000000000022','46000000-0000-0000-0000-000000000001',1),
 ('40000000-0000-0000-0000-000000000022','46000000-0000-0000-0000-000000000002',2),
 ('40000000-0000-0000-0000-000000000022','46000000-0000-0000-0000-000000000003',3),
 ('40000000-0000-0000-0000-000000000022','46000000-0000-0000-0000-000000000004',4),
 ('40000000-0000-0000-0000-000000000022','46000000-0000-0000-0000-000000000005',5),
 ('40000000-0000-0000-0000-000000000022','46000000-0000-0000-0000-000000000006',6),
 ('40000000-0000-0000-0000-000000000022','46000000-0000-0000-0000-000000000007',7),
 ('40000000-0000-0000-0000-000000000022','46000000-0000-0000-0000-000000000008',8),
-- Lección 2.3
 ('40000000-0000-0000-0000-000000000023','47000000-0000-0000-0000-000000000001',1),
 ('40000000-0000-0000-0000-000000000023','47000000-0000-0000-0000-000000000002',2),
 ('40000000-0000-0000-0000-000000000023','47000000-0000-0000-0000-000000000003',3),
 ('40000000-0000-0000-0000-000000000023','47000000-0000-0000-0000-000000000004',4),
 ('40000000-0000-0000-0000-000000000023','47000000-0000-0000-0000-000000000005',5),
 ('40000000-0000-0000-0000-000000000023','47000000-0000-0000-0000-000000000006',6),
 ('40000000-0000-0000-0000-000000000023','47000000-0000-0000-0000-000000000007',7),
 ('40000000-0000-0000-0000-000000000023','47000000-0000-0000-0000-000000000008',8),
-- Lección 2.4
 ('40000000-0000-0000-0000-000000000024','48000000-0000-0000-0000-000000000001',1),
 ('40000000-0000-0000-0000-000000000024','48000000-0000-0000-0000-000000000002',2),
 ('40000000-0000-0000-0000-000000000024','48000000-0000-0000-0000-000000000003',3),
 ('40000000-0000-0000-0000-000000000024','48000000-0000-0000-0000-000000000004',4),
 ('40000000-0000-0000-0000-000000000024','48000000-0000-0000-0000-000000000005',5),
 ('40000000-0000-0000-0000-000000000024','48000000-0000-0000-0000-000000000006',6),
 ('40000000-0000-0000-0000-000000000024','48000000-0000-0000-0000-000000000007',7),
 ('40000000-0000-0000-0000-000000000024','48000000-0000-0000-0000-000000000008',8),
-- Checkpoint 2.5: 10 ítems del banco de la unidad, cubriendo las 4 habilidades
 ('40000000-0000-0000-0000-000000000025','46000000-0000-0000-0000-000000000001',1),  -- mc reading (Twelve)
 ('40000000-0000-0000-0000-000000000025','45000000-0000-0000-0000-000000000003',2),  -- listening (eight)
 ('40000000-0000-0000-0000-000000000025','46000000-0000-0000-0000-000000000003',3),  -- cloze reading (How old)
 ('40000000-0000-0000-0000-000000000025','46000000-0000-0000-0000-000000000005',4),  -- reorder writing (I'm twenty)
 ('40000000-0000-0000-0000-000000000025','47000000-0000-0000-0000-000000000002',5),  -- mc reading (Where from)
 ('40000000-0000-0000-0000-000000000025','48000000-0000-0000-0000-000000000001',6),  -- cloze reading (Are you)
 ('40000000-0000-0000-0000-000000000025','45000000-0000-0000-0000-000000000006',7),  -- translation writing (four)
 ('40000000-0000-0000-0000-000000000025','47000000-0000-0000-0000-000000000001',8),  -- match reading (Peru)
 ('40000000-0000-0000-0000-000000000025','46000000-0000-0000-0000-000000000008',9),  -- speaking (I'm twenty)
 ('40000000-0000-0000-0000-000000000025','48000000-0000-0000-0000-000000000002',10)  -- mc reading (Yes, I am)
on conflict (lesson_id, item_id) do nothing;

-- ── Vocabulario de la Unidad 2 (alimenta el SRS) ────────────────────────────
insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values
 ('60000000-0000-0000-0000-000000000031','20000000-0000-0000-0000-000000000001','one','uno',31,'numeral'),
 ('60000000-0000-0000-0000-000000000032','20000000-0000-0000-0000-000000000001','two','dos',32,'numeral'),
 ('60000000-0000-0000-0000-000000000033','20000000-0000-0000-0000-000000000001','three','tres',33,'numeral'),
 ('60000000-0000-0000-0000-000000000034','20000000-0000-0000-0000-000000000001','four','cuatro',34,'numeral'),
 ('60000000-0000-0000-0000-000000000035','20000000-0000-0000-0000-000000000001','five','cinco',35,'numeral'),
 ('60000000-0000-0000-0000-000000000036','20000000-0000-0000-0000-000000000001','ten','diez',36,'numeral'),
 ('60000000-0000-0000-0000-000000000037','20000000-0000-0000-0000-000000000001','twelve','doce',37,'numeral'),
 ('60000000-0000-0000-0000-000000000038','20000000-0000-0000-0000-000000000001','fifteen','quince',38,'numeral'),
 ('60000000-0000-0000-0000-000000000039','20000000-0000-0000-0000-000000000001','twenty','veinte',39,'numeral'),
 ('60000000-0000-0000-0000-000000000040','20000000-0000-0000-0000-000000000001','how old are you','cuántos años tienes',40,'phrase'),
 ('60000000-0000-0000-0000-000000000041','20000000-0000-0000-0000-000000000001','years old','años (de edad)',41,'phrase'),
 ('60000000-0000-0000-0000-000000000042','20000000-0000-0000-0000-000000000001','country','país',42,'noun'),
 ('60000000-0000-0000-0000-000000000043','20000000-0000-0000-0000-000000000001','where are you from','de dónde eres',43,'phrase'),
 ('60000000-0000-0000-0000-000000000044','20000000-0000-0000-0000-000000000001','Peru','Perú',44,'noun'),
 ('60000000-0000-0000-0000-000000000045','20000000-0000-0000-0000-000000000001','American','estadounidense',45,'adjective'),
 ('60000000-0000-0000-0000-000000000046','20000000-0000-0000-0000-000000000001','English','inglés/inglesa',46,'adjective'),
 ('60000000-0000-0000-0000-000000000047','20000000-0000-0000-0000-000000000001','Brazilian','brasileño',47,'adjective'),
 ('60000000-0000-0000-0000-000000000048','20000000-0000-0000-0000-000000000001','are you','eres/estás (tú)',48,'phrase'),
 ('60000000-0000-0000-0000-000000000049','20000000-0000-0000-0000-000000000001','not','no (negación)',49,'adverb'),
 ('60000000-0000-0000-0000-000000000050','20000000-0000-0000-0000-000000000001','student','estudiante',50,'noun')
on conflict (id) do nothing;

commit;
