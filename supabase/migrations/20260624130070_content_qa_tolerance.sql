-- ============================================================================
-- Jezici · Migración 070 · QA pedagógico es→en A1/A2: tolerancia + claridad
-- ----------------------------------------------------------------------------
-- Auditoría profesor-IA de los 384 ítems es→en A1/A2 (CONTENT_QA.md). 0 P0
-- (ninguna respuesta incorrecta). Clase sistémica: TOLERANCIA insuficiente en
-- translation/cloze — faltaban variantes naturales (sinónimos, artículos, número,
-- formas con get/grab/please/o'clock, have got…) que un aprendiz LATAM produce y
-- son correctas. Aquí se AÑADEN a `accepted` (additivo, no acepta lo erróneo; el
-- grader ya normaliza apóstrofes/contracciones/puntuación). + 2 pulidos.
-- Rechazados (reducirían tolerancia válida): no se quita train/bus de un cloze, ni
-- se recategoriza un cloze de writing→reading. Diferidos en CONTENT_QA.md.
-- ============================================================================
begin;

update content_items set correct_answer = jsonb_set(correct_answer, '{accepted}', coalesce(correct_answer->'accepted','[]'::jsonb) || $v$["I'm Carlos", "I am Carlos"]$v$::jsonb), updated_at=now() where id='43000000-0000-0000-0000-000000000003';
update content_items set correct_answer = jsonb_set(correct_answer, '{accepted}', coalesce(correct_answer->'accepted','[]'::jsonb) || $v$["2"]$v$::jsonb), updated_at=now() where id='45000000-0000-0000-0000-000000000004';
update content_items set correct_answer = jsonb_set(correct_answer, '{accepted}', coalesce(correct_answer->'accepted','[]'::jsonb) || $v$["what is your age", "what's your age"]$v$::jsonb), updated_at=now() where id='46000000-0000-0000-0000-000000000006';
update content_items set correct_answer = jsonb_set(correct_answer, '{accepted}', coalesce(correct_answer->'accepted','[]'::jsonb) || $v$["I have got a sister", "I've got a sister"]$v$::jsonb), updated_at=now() where id='c3400000-0000-0000-0000-000000000004';
update content_items set correct_answer = jsonb_set(correct_answer, '{accepted}', coalesce(correct_answer->'accepted','[]'::jsonb) || $v$["dad"]$v$::jsonb), updated_at=now() where id='c3100000-0000-0000-0000-000000000005';
update content_items set correct_answer = jsonb_set(correct_answer, '{accepted}', coalesce(correct_answer->'accepted','[]'::jsonb) || $v$["I'd like water", "I would like water", "I'd like some water", "I would like some water"]$v$::jsonb), updated_at=now() where id='c4200000-0000-0000-0000-000000000004';
update content_items set correct_answer = jsonb_set(correct_answer, '{accepted}', coalesce(correct_answer->'accepted','[]'::jsonb) || $v$["May I have a tea, please?", "Can I get a tea, please?", "Could I get a tea, please?", "Can I get a tea please"]$v$::jsonb), updated_at=now() where id='c4300000-0000-0000-0000-000000000004';
update content_items set correct_answer = jsonb_set(correct_answer, '{accepted}', coalesce(correct_answer->'accepted','[]'::jsonb) || $v$["How much is this?", "How much does this cost?"]$v$::jsonb), updated_at=now() where id='c4400000-0000-0000-0000-000000000005';
update content_items set correct_answer = jsonb_set(correct_answer, '{accepted}', coalesce(correct_answer->'accepted','[]'::jsonb) || $v$["It's Monday", "It is Monday"]$v$::jsonb), updated_at=now() where id='c5200000-0000-0000-0000-000000000005';
update content_items set correct_answer = jsonb_set(correct_answer, '{accepted}', coalesce(correct_answer->'accepted','[]'::jsonb) || $v$["I work each day"]$v$::jsonb), updated_at=now() where id='c5400000-0000-0000-0000-000000000005';
update content_items set correct_answer = jsonb_set(correct_answer, '{accepted}', coalesce(correct_answer->'accepted','[]'::jsonb) || $v$["I ate some pizza", "I had some pizza"]$v$::jsonb), updated_at=now() where id='c2000021-0000-0000-0000-000000000021';
update content_items set correct_answer = jsonb_set(correct_answer, '{accepted}', coalesce(correct_answer->'accepted','[]'::jsonb) || $v$["Did you see the film", "Did you watch the film"]$v$::jsonb), updated_at=now() where id='c2000029-0000-0000-0000-000000000029';
update content_items set correct_answer = jsonb_set(correct_answer, '{accepted}', coalesce(correct_answer->'accepted','[]'::jsonb) || $v$["Would you like to get a coffee", "Would you like to grab a coffee", "Would you like to drink a coffee"]$v$::jsonb), updated_at=now() where id='c2000053-0000-0000-0000-000000000053';
update content_items set correct_answer = jsonb_set(correct_answer, '{accepted}', coalesce(correct_answer->'accepted','[]'::jsonb) || $v$["I'll see you tomorrow", "I will see you tomorrow"]$v$::jsonb), updated_at=now() where id='c2000061-0000-0000-0000-000000000061';
update content_items set correct_answer = jsonb_set(correct_answer, '{accepted}', coalesce(correct_answer->'accepted','[]'::jsonb) || $v$["The train arrives at eight o'clock", "The train arrives at 8 o'clock", "The train gets in at eight"]$v$::jsonb), updated_at=now() where id='c2000069-0000-0000-0000-000000000069';
update content_items set correct_answer = jsonb_set(correct_answer, '{accepted}', coalesce(correct_answer->'accepted','[]'::jsonb) || $v$["Where is my baggage", "Where's my baggage"]$v$::jsonb), updated_at=now() where id='c2000085-0000-0000-0000-000000000085';
update content_items set correct_answer = jsonb_set(correct_answer, '{accepted}', coalesce(correct_answer->'accepted','[]'::jsonb) || $v$["Could you please help me", "Can you please help me", "Could you help me please", "Can you help me please"]$v$::jsonb), updated_at=now() where id='c2000093-0000-0000-0000-000000000093';
update content_items set correct_answer = jsonb_set(correct_answer, '{accepted}', coalesce(correct_answer->'accepted','[]'::jsonb) || $v$["Check please", "Bill please", "Can I have the bill please", "Can I have the check please"]$v$::jsonb), updated_at=now() where id='c2000101-0000-0000-0000-000000000101';
update content_items set correct_answer = jsonb_set(correct_answer, '{accepted}', coalesce(correct_answer->'accepted','[]'::jsonb) || $v$["How much is this", "How much is that", "How much does this cost"]$v$::jsonb), updated_at=now() where id='c2000117-0000-0000-0000-000000000117';
update content_items set correct_answer = jsonb_set(correct_answer, '{accepted}', coalesce(correct_answer->'accepted','[]'::jsonb) || $v$["I'll have a bottle of water"]$v$::jsonb), updated_at=now() where id='c2000109-0000-0000-0000-000000000109';
update content_items set correct_answer = jsonb_set(correct_answer, '{accepted}', coalesce(correct_answer->'accepted','[]'::jsonb) || $v$["never"]$v$::jsonb), updated_at=now() where id='c2000180-0000-0000-0000-000000000180';
update content_items set correct_answer = jsonb_set(correct_answer, '{accepted}', coalesce(correct_answer->'accepted','[]'::jsonb) || $v$["must"]$v$::jsonb), updated_at=now() where id='c2000172-0000-0000-0000-000000000172';

-- Pulido: instrucción clara (la pista '(cook)' no indicaba la forma -ing)
update content_items set prompt = $p$Completa con la forma -ing de "cook": "I am ___ dinner now."$p$, updated_at=now() where id='c2000148-0000-0000-0000-000000000148';

-- Pulido: match de partes del día sin solape (evening/tarde-noche -> morning/mañana)
update content_items set payload = jsonb_set(payload,'{pairs}', $v$[{"en":"afternoon","es":"tarde"},{"en":"morning","es":"mañana"},{"en":"night","es":"noche"}]$v$::jsonb), correct_answer = jsonb_set(correct_answer,'{pairs}', $v$[["afternoon","tarde"],["morning","mañana"],["night","noche"]]$v$::jsonb), updated_at=now() where id='c5400000-0000-0000-0000-000000000002';

commit;
