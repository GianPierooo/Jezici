-- LÉXICO Fase 0 — cosechar lo sembrado (LEXICO_PLAN §3). CERO IA.
-- Vincula a lecciones de repaso las palabras del seed con traducción revisada
-- que no se enseñaban (sin lesson_vocab). Ítems `match` por plantilla, tag
-- 'repaso_vocab' (NO unidadN → checkpoints/exámenes/placement intactos). Las
-- lecciones se anclan ANTES del checkpoint de una unidad de nivel coherente
-- (freq_rank/30). Idempotente (uuid5 + on conflict do nothing).

-- 1) content_items
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '8110c4a6-5d25-5cab-aeee-3917e7d0e2cc', c.id, 'A1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "bye", "es": "chao"}, {"en": "Brazilian", "es": "brasileño"}]}'::jsonb, '{"pairs": [["bye", "chao"], ["Brazilian", "brasileño"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='en' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'd064f7ef-916b-5fb4-b079-1b18cfa0d130', c.id, 'A1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "Anything else?", "es": "¿algo más?"}, {"en": "dish", "es": "plato"}]}'::jsonb, '{"pairs": [["Anything else?", "¿algo más?"], ["dish", "plato"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='en' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '6eb77625-807e-541e-9778-db411d2439c8', c.id, 'A2', 'reading', 'translation', 'Traduce al idioma que aprendes.', '{"source": "estadounidense"}'::jsonb, '{"value": "American"}'::jsonb, 0.2, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='en' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '1e4daa15-c27c-5c7d-a28e-61e8f5e7ed50', c.id, 'A2', 'reading', 'translation', 'Traduce al idioma que aprendes.', '{"source": "talla / tamaño"}'::jsonb, '{"value": "size"}'::jsonb, 0.2, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='en' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'f938bed3-a54d-59dd-a3aa-5d66fa95111c', c.id, 'A2', 'reading', 'translation', 'Traduce al idioma que aprendes.', '{"source": "definir"}'::jsonb, '{"value": "to define"}'::jsonb, 0.2, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='en' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '125fb1c0-99bd-5591-ad7f-fa1d94a34ea6', c.id, 'A2', 'reading', 'translation', 'Traduce al idioma que aprendes.', '{"source": "saludable"}'::jsonb, '{"value": "healthy"}'::jsonb, 0.2, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='en' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'c3e735dc-a235-5ad3-a762-fcf58c3b50ce', c.id, 'B1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "to travel", "es": "viajar"}, {"en": "to try", "es": "probar / intentar"}]}'::jsonb, '{"pairs": [["to travel", "viajar"], ["to try", "probar / intentar"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='en' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '3e72a278-055a-520a-a49b-ffaf97ac6042', c.id, 'B1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "overtime", "es": "horas extra"}, {"en": "to hand in", "es": "entregar"}, {"en": "to achieve", "es": "lograr/conseguir"}]}'::jsonb, '{"pairs": [["overtime", "horas extra"], ["to hand in", "entregar"], ["to achieve", "lograr/conseguir"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='en' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '3999ad75-7c28-5f01-9119-4ae86bb8d3e4', c.id, 'B1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "to agree", "es": "estar de acuerdo"}, {"en": "to disagree", "es": "no estar de acuerdo"}, {"en": "to believe", "es": "creer"}, {"en": "to think", "es": "pensar"}, {"en": "to be right", "es": "tener razón"}]}'::jsonb, '{"pairs": [["to agree", "estar de acuerdo"], ["to disagree", "no estar de acuerdo"], ["to believe", "creer"], ["to think", "pensar"], ["to be right", "tener razón"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='en' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '79355205-5669-558a-817c-937bf9249f2c', c.id, 'B1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "to be wrong", "es": "estar equivocado"}, {"en": "to suggest", "es": "sugerir"}, {"en": "reason", "es": "razón"}]}'::jsonb, '{"pairs": [["to be wrong", "estar equivocado"], ["to suggest", "sugerir"], ["reason", "razón"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='en' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '5dfcdbd0-c9cc-5cce-9fb8-8fd5fec8291e', c.id, 'B1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "to miss (a train)", "es": "perder (un tren)"}, {"en": "to explore", "es": "explorar"}]}'::jsonb, '{"pairs": [["to miss (a train)", "perder (un tren)"], ["to explore", "explorar"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='en' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '56d221ee-5982-53f9-ac9f-fc315194b5a4', c.id, 'B1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "hurt", "es": "doler / lastimar"}, {"en": "break down", "es": "averiarse"}, {"en": "deal with", "es": "lidiar con / gestionar"}, {"en": "that day", "es": "aquel día"}, {"en": "message", "es": "mensaje"}]}'::jsonb, '{"pairs": [["hurt", "doler / lastimar"], ["break down", "averiarse"], ["deal with", "lidiar con / gestionar"], ["that day", "aquel día"], ["message", "mensaje"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='en' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '6a1946eb-7ac9-511b-a75d-6ecbff933479', c.id, 'B1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "newspaper", "es": "periódico"}, {"en": "to be made of", "es": "estar hecho de"}, {"en": "to be built", "es": "ser construido"}, {"en": "broadcast", "es": "emitir / transmitir"}, {"en": "headline", "es": "titular"}]}'::jsonb, '{"pairs": [["newspaper", "periódico"], ["to be made of", "estar hecho de"], ["to be built", "ser construido"], ["broadcast", "emitir / transmitir"], ["headline", "titular"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='en' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '9eb38958-d44e-5fe9-83b0-833493d91165', c.id, 'B2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "progress", "es": "progreso/avance"}, {"en": "to struggle", "es": "tener dificultades/luchar"}]}'::jsonb, '{"pairs": [["progress", "progreso/avance"], ["to struggle", "tener dificultades/luchar"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='en' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '7bfdf5d8-d881-5172-b819-6c40fead63f6', c.id, 'B2', 'reading', 'translation', 'Traduce al idioma que aprendes.', '{"source": "prometer"}'::jsonb, '{"value": "promise"}'::jsonb, 0.2, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='en' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '4edf50cc-9a8f-5ce9-b9df-b10f17dc0a14', c.id, 'B2', 'reading', 'translation', 'Traduce al idioma que aprendes.', '{"source": "producir"}'::jsonb, '{"value": "produce"}'::jsonb, 0.2, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='en' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'ed404876-ea73-5da7-b3ce-71d3dcd8c195', c.id, 'B2', 'reading', 'translation', 'Traduce al idioma que aprendes.', '{"source": "suponer"}'::jsonb, '{"value": "to assume"}'::jsonb, 0.2, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='en' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'be338ba2-2b30-54ab-801b-f1ccfd0f485e', c.id, 'B2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "to come up with", "es": "idear, ocurrírsele"}, {"en": "mixed conditional", "es": "condicional mixto"}]}'::jsonb, '{"pairs": [["to come up with", "idear, ocurrírsele"], ["mixed conditional", "condicional mixto"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='en' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'e0cf6c18-0245-5b2c-9595-49a35881d3f0', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "conspicuous", "es": "llamativo, evidente"}, {"en": "to underpin", "es": "sustentar (servir de base)"}]}'::jsonb, '{"pairs": [["conspicuous", "llamativo, evidente"], ["to underpin", "sustentar (servir de base)"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='en' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'a1b3c83c-c740-5f05-9ed0-d49510e64a1c', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "emphasis", "es": "énfasis"}, {"en": "to imply", "es": "dar a entender, implicar"}, {"en": "inference", "es": "inferencia"}, {"en": "to underscore", "es": "recalcar, subrayar"}, {"en": "to concede", "es": "admitir, conceder"}]}'::jsonb, '{"pairs": [["emphasis", "énfasis"], ["to imply", "dar a entender, implicar"], ["inference", "inferencia"], ["to underscore", "recalcar, subrayar"], ["to concede", "admitir, conceder"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='en' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '7ceedf09-f13d-5fbd-898e-dbfe7641e1cd', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "undertone", "es": "trasfondo, matiz"}, {"en": "to allude", "es": "aludir"}, {"en": "forthcoming", "es": "comunicativo, dispuesto a hablar"}, {"en": "let go", "es": "despedir (eufemismo)"}]}'::jsonb, '{"pairs": [["undertone", "trasfondo, matiz"], ["to allude", "aludir"], ["forthcoming", "comunicativo, dispuesto a hablar"], ["let go", "despedir (eufemismo)"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='en' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '23a7cc81-b3c2-51e3-aad5-ce9f05a1533a', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "rule out", "es": "descartar"}, {"en": "water down", "es": "suavizar / diluir"}]}'::jsonb, '{"pairs": [["rule out", "descartar"], ["water down", "suavizar / diluir"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='en' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'a0708e60-5057-581f-bdc5-bf41248f2d74', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "hypothetical", "es": "hipotético"}, {"en": "to assert", "es": "afirmar (con seguridad)"}]}'::jsonb, '{"pairs": [["hypothetical", "hipotético"], ["to assert", "afirmar (con seguridad)"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='en' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'f1c5cd1e-7b33-5f06-b072-a592aba83638', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "to contend", "es": "sostener (un argumento)"}, {"en": "to acknowledge", "es": "reconocer (admitir)"}, {"en": "to concede", "es": "conceder (admitir a regañadientes)"}, {"en": "to imply", "es": "dar a entender"}, {"en": "to highlight", "es": "poner de relieve"}]}'::jsonb, '{"pairs": [["to contend", "sostener (un argumento)"], ["to acknowledge", "reconocer (admitir)"], ["to concede", "conceder (admitir a regañadientes)"], ["to imply", "dar a entender"], ["to highlight", "poner de relieve"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='en' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'f6b30046-54d7-599e-aa1a-147884fb52cb', c.id, 'A1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "depois que", "es": "después de que"}, {"en": "caso contrário", "es": "de lo contrario"}]}'::jsonb, '{"pairs": [["depois que", "después de que"], ["caso contrário", "de lo contrario"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='pt' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '58a89f2b-fdf6-5b47-aa06-22b763a65e59', c.id, 'A1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "sem que", "es": "sin que"}, {"en": "tomar uma decisão", "es": "tomar una decisión"}]}'::jsonb, '{"pairs": [["sem que", "sin que"], ["tomar uma decisão", "tomar una decisión"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='pt' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'f30fcc73-38fc-5f6f-a844-eed311d431b9', c.id, 'A1', 'reading', 'translation', 'Traduce al idioma que aprendes.', '{"source": "como te parezca mejor"}'::jsonb, '{"value": "como você achar melhor"}'::jsonb, 0.2, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='pt' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'ab623124-2595-5f91-b423-aebf137f379f', c.id, 'A1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "contanto que", "es": "con tal de que"}, {"en": "antes que", "es": "antes de que"}]}'::jsonb, '{"pairs": [["contanto que", "con tal de que"], ["antes que", "antes de que"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='pt' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'bced85ed-49e4-554a-a097-e1f7ecb51873', c.id, 'A1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "aceito", "es": "aceptado"}, {"en": "precisar de", "es": "necesitar"}]}'::jsonb, '{"pairs": [["aceito", "aceptado"], ["precisar de", "necesitar"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='pt' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'd8ef8f15-d173-542a-92a6-7bab1c8ca989', c.id, 'A2', 'reading', 'translation', 'Traduce al idioma que aprendes.', '{"source": "el fin de semana"}'::jsonb, '{"value": "o fim de semana"}'::jsonb, 0.2, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='pt' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'f3edabf3-4c60-56c0-85e3-aa3a075bf5c6', c.id, 'A2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "vontade", "es": "ganas"}, {"en": "ou seja", "es": "o sea, es decir"}, {"en": "a nuance", "es": "el matiz"}, {"en": "preferir", "es": "preferir (preferir X a Y)"}]}'::jsonb, '{"pairs": [["vontade", "ganas"], ["ou seja", "o sea, es decir"], ["a nuance", "el matiz"], ["preferir", "preferir (preferir X a Y)"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='pt' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'eb7f1981-8dad-54b1-95eb-6d15b5bb2d85', c.id, 'A2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "o subjuntivo", "es": "el subjuntivo (modo)"}, {"en": "duvidar que", "es": "dudar que"}, {"en": "a fim de que", "es": "a fin de que"}, {"en": "se fosse possível", "es": "si fuera posible"}]}'::jsonb, '{"pairs": [["o subjuntivo", "el subjuntivo (modo)"], ["duvidar que", "dudar que"], ["a fim de que", "a fin de que"], ["se fosse possível", "si fuera posible"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='pt' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '73f38158-e347-55cb-a8c2-5766b3ffcdcf', c.id, 'A2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "quando eu tiver tempo", "es": "cuando tenga tiempo"}, {"en": "enquanto ele puder", "es": "mientras él pueda"}, {"en": "logo que", "es": "en cuanto"}, {"en": "se eu tivesse tempo", "es": "si tuviera tiempo"}, {"en": "eu gostaria que", "es": "quisiera que / querría que"}]}'::jsonb, '{"pairs": [["quando eu tiver tempo", "cuando tenga tiempo"], ["enquanto ele puder", "mientras él pueda"], ["logo que", "en cuanto"], ["se eu tivesse tempo", "si tuviera tiempo"], ["eu gostaria que", "quisiera que / querría que"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='pt' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '68a8eefc-45f8-596e-90d8-c00002f8da3d', c.id, 'A2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "o futuro do pretérito", "es": "el futuro del pretérito (condicional)"}, {"en": "o período hipotético", "es": "el período hipotético"}, {"en": "a hipótese", "es": "la hipótesis"}, {"en": "o futuro do subjuntivo", "es": "el futuro del subjuntivo"}, {"en": "o imperfeito do subjuntivo", "es": "el imperfecto del subjuntivo"}]}'::jsonb, '{"pairs": [["o futuro do pretérito", "el futuro del pretérito (condicional)"], ["o período hipotético", "el período hipotético"], ["a hipótese", "la hipótesis"], ["o futuro do subjuntivo", "el futuro del subjuntivo"], ["o imperfeito do subjuntivo", "el imperfecto del subjuntivo"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='pt' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '6d900685-7c4d-5432-843c-e0a5a362b37e', c.id, 'A2', 'reading', 'translation', 'Traduce al idioma que aprendes.', '{"source": "si yo tuviera tiempo"}'::jsonb, '{"value": "se eu tivesse tempo"}'::jsonb, 0.2, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='pt' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'ac8027b1-ce33-56d6-89b3-0ed912ef39ac', c.id, 'A2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "se eu tiver dinheiro", "es": "si tengo (tuviere) dinero"}, {"en": "teria acontecido", "es": "habría ocurrido"}, {"en": "ele teria dito", "es": "él habría dicho"}, {"en": "do contrário", "es": "de lo contrario"}, {"en": "seria melhor", "es": "sería mejor"}]}'::jsonb, '{"pairs": [["se eu tiver dinheiro", "si tengo (tuviere) dinero"], ["teria acontecido", "habría ocurrido"], ["ele teria dito", "él habría dicho"], ["do contrário", "de lo contrario"], ["seria melhor", "sería mejor"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='pt' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'dacb23f2-4765-5987-bee5-245497228bda', c.id, 'A2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "o particípio", "es": "el participio"}, {"en": "o agente", "es": "el agente (de la pasiva)"}, {"en": "será entregue", "es": "será entregado"}, {"en": "a fatura", "es": "la factura"}]}'::jsonb, '{"pairs": [["o particípio", "el participio"], ["o agente", "el agente (de la pasiva)"], ["será entregue", "será entregado"], ["a fatura", "la factura"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='pt' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'f6fbed7d-4705-5122-a5aa-4e61694c387b', c.id, 'B1', 'reading', 'translation', 'Traduce al idioma que aprendes.', '{"source": "costumbre"}'::jsonb, '{"value": "costume"}'::jsonb, 0.2, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='pt' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '15089d95-869a-539b-9f4b-eecaaf909d18', c.id, 'B1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "é possível que", "es": "es posible que"}, {"en": "o desejo", "es": "el deseo"}, {"en": "a esperança", "es": "la esperanza"}, {"en": "a recomendação", "es": "la recomendación"}]}'::jsonb, '{"pairs": [["é possível que", "es posible que"], ["o desejo", "el deseo"], ["a esperança", "la esperanza"], ["a recomendação", "la recomendación"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='pt' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '757ac397-af88-5d38-a691-20179df50765', c.id, 'B1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "o discurso indireto", "es": "el discurso/estilo indirecto"}, {"en": "a colocação pronominal", "es": "la colocación del pronombre"}, {"en": "a próclise", "es": "la próclisis (pronombre antes)"}, {"en": "a ênclise", "es": "la énclisis (pronombre después)"}, {"en": "relatar", "es": "relatar, reportar"}]}'::jsonb, '{"pairs": [["o discurso indireto", "el discurso/estilo indirecto"], ["a colocação pronominal", "la colocación del pronombre"], ["a próclise", "la próclisis (pronombre antes)"], ["a ênclise", "la énclisis (pronombre después)"], ["relatar", "relatar, reportar"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='pt' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'bfb18d16-4139-568f-a8b0-a123995aba17', c.id, 'B1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "o qual", "es": "el cual"}, {"en": "nascer", "es": "nacer"}, {"en": "o cantor", "es": "el cantante"}]}'::jsonb, '{"pairs": [["o qual", "el cual"], ["nascer", "nacer"], ["o cantor", "el cantante"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='pt' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'c54ca22f-8347-5948-abe5-f39ae45ab518', c.id, 'B1', 'reading', 'translation', 'Traduce al idioma que aprendes.', '{"source": "firmar"}'::jsonb, '{"value": "assinar"}'::jsonb, 0.2, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='pt' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'd2834d58-7ce1-5a27-be83-6c3e16b99a5a', c.id, 'B1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "a não ser que", "es": "a menos que"}, {"en": "a saúde", "es": "la salud"}, {"en": "a voz passiva", "es": "la voz pasiva"}, {"en": "o corpo", "es": "el cuerpo"}, {"en": "a febre", "es": "la fiebre"}]}'::jsonb, '{"pairs": [["a não ser que", "a menos que"], ["a saúde", "la salud"], ["a voz passiva", "la voz pasiva"], ["o corpo", "el cuerpo"], ["a febre", "la fiebre"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='pt' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '0be70dec-e018-5999-b9da-85a9c7d3c7d8', c.id, 'B1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "a dor", "es": "el dolor"}, {"en": "foram vendidos", "es": "fueron vendidos"}, {"en": "no dia anterior", "es": "el día anterior"}]}'::jsonb, '{"pairs": [["a dor", "el dolor"], ["foram vendidos", "fueron vendidos"], ["no dia anterior", "el día anterior"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='pt' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '91a9466a-84cd-56e2-91ff-a400a4b3f3ab', c.id, 'B2', 'reading', 'translation', 'Traduce al idioma que aprendes.', '{"source": "con tal de que, siempre que"}'::jsonb, '{"value": "contanto que"}'::jsonb, 0.2, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='pt' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '7866c397-2c6b-5642-8e13-f1cf9cbc21fa', c.id, 'B2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "por mais que", "es": "por más que"}, {"en": "o real", "es": "el real (moneda)"}, {"en": "lembrar", "es": "recordar"}]}'::jsonb, '{"pairs": [["por mais que", "por más que"], ["o real", "el real (moneda)"], ["lembrar", "recordar"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='pt' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '5df5ab0d-92b0-5af7-ad3c-2c2da8fd41bf', c.id, 'B2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "o futuro do subjuntivo", "es": "el futuro de subjuntivo (tiver, for, fizer)"}, {"en": "o período hipotético", "es": "el período hipotético (condicional)"}, {"en": "o futuro do pretérito", "es": "el condicional (-ia)"}, {"en": "a modalização", "es": "la modalización"}, {"en": "a conjectura", "es": "la conjetura, la suposición"}]}'::jsonb, '{"pairs": [["o futuro do subjuntivo", "el futuro de subjuntivo (tiver, for, fizer)"], ["o período hipotético", "el período hipotético (condicional)"], ["o futuro do pretérito", "el condicional (-ia)"], ["a modalização", "la modalización"], ["a conjectura", "la conjetura, la suposición"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='pt' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '8990f417-382f-5a50-841f-b4310a969fc8', c.id, 'B2', 'reading', 'translation', 'Traduce al idioma que aprendes.', '{"source": "presumiblemente"}'::jsonb, '{"value": "presumivelmente"}'::jsonb, 0.2, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='pt' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '566c9271-72f0-502b-8179-f2ecfc220f89', c.id, 'B2', 'reading', 'translation', 'Traduce al idioma que aprendes.', '{"source": "la petición, la demanda"}'::jsonb, '{"value": "o pleito"}'::jsonb, 0.2, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='pt' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '5e0f50fd-8733-523e-ad70-90ce61a03f92', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "tecer críticas", "es": "hacer críticas"}, {"en": "adotar medidas", "es": "adoptar medidas"}, {"en": "o automóvel", "es": "el automóvil (formal)"}, {"en": "a regência", "es": "la regencia (verbal)"}, {"en": "a conotação", "es": "la connotación"}]}'::jsonb, '{"pairs": [["tecer críticas", "hacer críticas"], ["adotar medidas", "adoptar medidas"], ["o automóvel", "el automóvil (formal)"], ["a regência", "la regencia (verbal)"], ["a conotação", "la connotación"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='pt' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '74102013-35f7-583b-9a4f-94a158d98ed6', c.id, 'C1', 'reading', 'translation', 'Traduce al idioma que aprendes.', '{"source": "la suposición"}'::jsonb, '{"value": "a suposição"}'::jsonb, 0.2, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='pt' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'd14a0e6a-e68d-5178-9507-24cfef32504b', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "perguntar", "es": "preguntar"}, {"en": "malgrado", "es": "a pesar de (formal)"}, {"en": "ademais", "es": "además, por lo demás"}, {"en": "destarte", "es": "de este modo, así pues (formal)"}, {"en": "a ilação", "es": "la deducción, la inferencia"}]}'::jsonb, '{"pairs": [["perguntar", "preguntar"], ["malgrado", "a pesar de (formal)"], ["ademais", "además, por lo demás"], ["destarte", "de este modo, así pues (formal)"], ["a ilação", "la deducción, la inferencia"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='pt' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '78d77378-f589-59b1-9ea0-2a680f4ca97f', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "a colocação pronominal", "es": "la colocación pronominal"}, {"en": "o pronome átono", "es": "el pronombre átono (me, te, se, lhe)"}]}'::jsonb, '{"pairs": [["a colocação pronominal", "la colocación pronominal"], ["o pronome átono", "el pronombre átono (me, te, se, lhe)"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='pt' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '6d3d9156-eeae-5c66-a79e-9bbe2a812000', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "a atração", "es": "la atracción (que provoca próclise)"}, {"en": "divulgar", "es": "divulgar, dar a conocer"}, {"en": "a ênfase", "es": "el énfasis"}, {"en": "o advérbio", "es": "el adverbio"}, {"en": "indubitavelmente", "es": "sin duda"}]}'::jsonb, '{"pairs": [["a atração", "la atracción (que provoca próclise)"], ["divulgar", "divulgar, dar a conocer"], ["a ênfase", "el énfasis"], ["o advérbio", "el adverbio"], ["indubitavelmente", "sin duda"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='pt' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '79667c6f-5a00-5169-8ffa-0c8eca5a8ecb', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "o realce", "es": "el realce, la puesta de relieve"}, {"en": "a alegação", "es": "la alegación, la afirmación"}]}'::jsonb, '{"pairs": [["o realce", "el realce, la puesta de relieve"], ["a alegação", "la alegación, la afirmación"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='pt' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '071651ff-9343-57a7-8f49-57b4ca19cf52', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "a clivagem", "es": "la construcción hendida (cleft)"}, {"en": "realçar", "es": "resaltar, poner de relieve"}, {"en": "a próclise", "es": "la próclisis (pronombre antepuesto)"}, {"en": "a ênclise", "es": "la enclisis (pronombre pospuesto)"}, {"en": "a mesóclise", "es": "la mesóclisis (pronombre en el medio)"}]}'::jsonb, '{"pairs": [["a clivagem", "la construcción hendida (cleft)"], ["realçar", "resaltar, poner de relieve"], ["a próclise", "la próclisis (pronombre antepuesto)"], ["a ênclise", "la enclisis (pronombre pospuesto)"], ["a mesóclise", "la mesóclisis (pronombre en el medio)"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='pt' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'bc49bf28-0e1b-5937-8fb8-6804dddadde5', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "falecer", "es": "fallecer (formal)"}, {"en": "o patrimônio", "es": "el patrimonio, la fortuna (formal)"}, {"en": "a grana", "es": "la pasta, el dinero (coloquial)"}, {"en": "apressar-se", "es": "darse prisa"}, {"en": "a expressão idiomática", "es": "el modismo, la locución"}]}'::jsonb, '{"pairs": [["falecer", "fallecer (formal)"], ["o patrimônio", "el patrimonio, la fortuna (formal)"], ["a grana", "la pasta, el dinero (coloquial)"], ["apressar-se", "darse prisa"], ["a expressão idiomática", "el modismo, la locución"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='pt' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'e74bd648-90ac-5a82-82a3-ebaf76bb5b4c', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "certeiro", "es": "certero, acertado"}, {"en": "a mancada", "es": "la metedura de pata"}]}'::jsonb, '{"pairs": [["certeiro", "certero, acertado"], ["a mancada", "la metedura de pata"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='pt' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '4dae7869-4970-5ca2-9403-ab0b9cdbbf7d', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "a concordância", "es": "la concordancia (de tiempos)"}, {"en": "o discurso indireto", "es": "el estilo indirecto"}, {"en": "a condição", "es": "la condición"}, {"en": "refutar", "es": "refutar, desmentir"}]}'::jsonb, '{"pairs": [["a concordância", "la concordancia (de tiempos)"], ["o discurso indireto", "el estilo indirecto"], ["a condição", "la condición"], ["refutar", "refutar, desmentir"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='pt' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '1ff32531-bcb2-5e45-975e-0f1ea1450a48', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "a avaliação", "es": "la evaluación, el examen"}, {"en": "a voz passiva", "es": "la voz pasiva"}, {"en": "a oração reduzida", "es": "la oración reducida"}, {"en": "o gerúndio", "es": "el gerundio"}, {"en": "o particípio", "es": "el participio"}]}'::jsonb, '{"pairs": [["a avaliação", "la evaluación, el examen"], ["a voz passiva", "la voz pasiva"], ["a oração reduzida", "la oración reducida"], ["o gerúndio", "el gerundio"], ["o particípio", "el participio"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='pt' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '5364fdb4-d4f7-5156-8880-4bbee02a5944', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "consoante", "es": "según, conforme a"}, {"en": "a solicitação", "es": "la solicitud"}, {"en": "prezado", "es": "estimado (tratamiento formal)"}, {"en": "atenciosamente", "es": "atentamente (despedida formal)"}, {"en": "prorrogar", "es": "prorrogar, aplazar"}]}'::jsonb, '{"pairs": [["consoante", "según, conforme a"], ["a solicitação", "la solicitud"], ["prezado", "estimado (tratamiento formal)"], ["atenciosamente", "atentamente (despedida formal)"], ["prorrogar", "prorrogar, aplazar"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='pt' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'ac68b0c7-d274-5f28-b625-6d8fcb2c63f1', c.id, 'A1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "d''où", "es": "de dónde"}, {"en": "pays", "es": "país"}, {"en": "le conseil", "es": "el consejo"}, {"en": "peut-être", "es": "quizás"}]}'::jsonb, '{"pairs": [["d''où", "de dónde"], ["pays", "país"], ["le conseil", "el consejo"], ["peut-être", "quizás"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='fr' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '04d6cf6c-b180-5e00-a18a-4e231c2f40fc', c.id, 'A1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "le grand-père", "es": "el abuelo"}, {"en": "l''enfant", "es": "el niño / la niña"}]}'::jsonb, '{"pairs": [["le grand-père", "el abuelo"], ["l''enfant", "el niño / la niña"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='fr' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '61f3377d-ac47-5b94-9946-2c709535facf', c.id, 'A1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "la pomme", "es": "la manzana"}, {"en": "le poulet", "es": "el pollo"}, {"en": "le lait", "es": "la leche"}]}'::jsonb, '{"pairs": [["la pomme", "la manzana"], ["le poulet", "el pollo"], ["le lait", "la leche"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='fr' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'ddaa7a1a-64ff-53b9-80d6-9da57d059c2e', c.id, 'A1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "minuit", "es": "medianoche"}, {"en": "mardi", "es": "martes"}]}'::jsonb, '{"pairs": [["minuit", "medianoche"], ["mardi", "martes"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='fr' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '91822af2-23f2-5fbf-9fd1-37cdda9b6a73', c.id, 'A1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "à côté de", "es": "al lado de"}, {"en": "l''avion", "es": "el avión"}]}'::jsonb, '{"pairs": [["à côté de", "al lado de"], ["l''avion", "el avión"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='fr' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'b253e4a5-f324-5abd-ab24-4b18165fbcca', c.id, 'A2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "écrire", "es": "escribir"}, {"en": "acheter", "es": "comprar"}, {"en": "mettre", "es": "poner"}, {"en": "se laver", "es": "lavarse"}, {"en": "se lever", "es": "levantarse"}]}'::jsonb, '{"pairs": [["écrire", "escribir"], ["acheter", "comprar"], ["mettre", "poner"], ["se laver", "lavarse"], ["se lever", "levantarse"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='fr' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'fc5fec57-5460-5609-9bed-8387a31e89c4', c.id, 'A2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "après-demain", "es": "pasado mañana"}, {"en": "un projet", "es": "un plan / proyecto"}, {"en": "l''argent", "es": "el dinero"}, {"en": "la possibilité", "es": "la posibilidad"}, {"en": "souhaiter", "es": "desear"}]}'::jsonb, '{"pairs": [["après-demain", "pasado mañana"], ["un projet", "un plan / proyecto"], ["l''argent", "el dinero"], ["la possibilité", "la posibilidad"], ["souhaiter", "desear"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='fr' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '61853bf0-b3b6-5327-b626-a2cf0aa1aea7', c.id, 'A2', 'reading', 'translation', 'Traduce al idioma que aprendes.', '{"source": "la flor"}'::jsonb, '{"value": "la fleur"}'::jsonb, 0.2, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='fr' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '82e9f340-820e-5479-994a-b8f787924ce7', c.id, 'A2', 'reading', 'translation', 'Traduce al idioma que aprendes.', '{"source": "a pie"}'::jsonb, '{"value": "à pied"}'::jsonb, 0.2, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='fr' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '3eb33e2c-9e38-5ba5-ad1b-dd99e92146dc', c.id, 'A2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "le menu", "es": "el menú"}, {"en": "un paquet de", "es": "un paquete de"}, {"en": "trop de", "es": "demasiado de"}]}'::jsonb, '{"pairs": [["le menu", "el menú"], ["un paquet de", "un paquete de"], ["trop de", "demasiado de"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='fr' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'b6521805-4274-5b85-aa22-96ddcc9f42de', c.id, 'A2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "blond", "es": "rubio"}, {"en": "brun", "es": "moreno / castaño"}]}'::jsonb, '{"pairs": [["blond", "rubio"], ["brun", "moreno / castaño"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='fr' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '6b537c32-8d0d-5736-bc23-5d7b8483fb82', c.id, 'A2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "le bras", "es": "el brazo"}, {"en": "la jambe", "es": "la pierna"}, {"en": "le pied", "es": "el pie"}, {"en": "la main", "es": "la mano"}, {"en": "avoir mal à", "es": "tener dolor de / doler"}]}'::jsonb, '{"pairs": [["le bras", "el brazo"], ["la jambe", "la pierna"], ["le pied", "el pie"], ["la main", "la mano"], ["avoir mal à", "tener dolor de / doler"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='fr' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '3c49f3c9-09d1-5f70-b655-8aad42d7a877', c.id, 'A2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "vouloir", "es": "querer"}, {"en": "souhaiter", "es": "desear"}]}'::jsonb, '{"pairs": [["vouloir", "querer"], ["souhaiter", "desear"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='fr' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '4a2987ba-b91b-575d-9b11-5a93b754f11f', c.id, 'B1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "falloir", "es": "hacer falta"}, {"en": "le subjonctif", "es": "el subjuntivo"}, {"en": "le doute", "es": "la duda"}, {"en": "nécessaire", "es": "necesario"}, {"en": "à condition que", "es": "con la condición de que"}]}'::jsonb, '{"pairs": [["falloir", "hacer falta"], ["le subjonctif", "el subjuntivo"], ["le doute", "la duda"], ["nécessaire", "necesario"], ["à condition que", "con la condición de que"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='fr' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '01fc37ab-954f-5f49-991b-2d63fd8dead7', c.id, 'B1', 'reading', 'translation', 'Traduce al idioma que aprendes.', '{"source": "el porvenir"}'::jsonb, '{"value": "l''avenir"}'::jsonb, 0.2, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='fr' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '2119bf18-c78c-5cfd-8226-aadbd34275ff', c.id, 'B1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "le voyage", "es": "el viaje"}, {"en": "être content que", "es": "alegrarse de que"}, {"en": "il est possible que", "es": "es posible que"}, {"en": "c''est dommage que", "es": "es una lástima que"}, {"en": "craindre que", "es": "temer que"}]}'::jsonb, '{"pairs": [["le voyage", "el viaje"], ["être content que", "alegrarse de que"], ["il est possible que", "es posible que"], ["c''est dommage que", "es una lástima que"], ["craindre que", "temer que"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='fr' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '60c75d82-3a57-5584-ab6e-8ebf4b42cd5d', c.id, 'B1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "la robe", "es": "el vestido"}, {"en": "monter", "es": "subir"}, {"en": "descendre", "es": "bajar"}, {"en": "le discours indirect", "es": "el estilo indirecto"}, {"en": "une affirmation", "es": "una afirmación"}]}'::jsonb, '{"pairs": [["la robe", "el vestido"], ["monter", "subir"], ["descendre", "bajar"], ["le discours indirect", "el estilo indirecto"], ["une affirmation", "una afirmación"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='fr' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'faa18e4e-1e86-52d3-bcf7-074f04523829', c.id, 'B1', 'reading', 'translation', 'Traduce al idioma que aprendes.', '{"source": "una pregunta"}'::jsonb, '{"value": "une question"}'::jsonb, 0.2, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='fr' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '1d79184d-1ba4-5706-bab3-cc3b47283c45', c.id, 'B1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "une demande", "es": "una petición"}, {"en": "raconter", "es": "contar, relatar"}, {"en": "expliquer", "es": "explicar"}, {"en": "la bagnole", "es": "el coche (coloquial)"}, {"en": "une nuance", "es": "un matiz"}]}'::jsonb, '{"pairs": [["une demande", "una petición"], ["raconter", "contar, relatar"], ["expliquer", "explicar"], ["la bagnole", "el coche (coloquial)"], ["une nuance", "un matiz"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='fr' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '3e4456b1-036f-5ddc-9486-8383746f77ba', c.id, 'B1', 'reading', 'translation', 'Traduce al idioma que aprendes.', '{"source": "una connotación"}'::jsonb, '{"value": "une connotation"}'::jsonb, 0.2, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='fr' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'e80f2729-b370-519a-8c53-c2061d0c6b5b', c.id, 'B1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "connaître", "es": "conocer"}, {"en": "le futur", "es": "el futuro"}, {"en": "le rêve", "es": "el sueño"}, {"en": "l''histoire", "es": "la historia"}, {"en": "le moment", "es": "el momento"}]}'::jsonb, '{"pairs": [["connaître", "conocer"], ["le futur", "el futuro"], ["le rêve", "el sueño"], ["l''histoire", "la historia"], ["le moment", "el momento"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='fr' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '65c247ed-2cc6-58c5-99fc-6184ffabaaa7', c.id, 'B1', 'reading', 'translation', 'Traduce al idioma que aprendes.', '{"source": "encargarse de"}'::jsonb, '{"value": "s''occuper de"}'::jsonb, 0.2, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='fr' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'd73486fe-e1ff-59ea-ae9b-1782f9ad1fb5', c.id, 'B1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "le subjonctif passé", "es": "el subjuntivo pasado"}, {"en": "l''auxiliaire", "es": "el auxiliar"}, {"en": "le participe passé", "es": "el participio pasado"}, {"en": "l''antériorité", "es": "la anterioridad"}, {"en": "regretter", "es": "lamentar"}]}'::jsonb, '{"pairs": [["le subjonctif passé", "el subjuntivo pasado"], ["l''auxiliaire", "el auxiliar"], ["le participe passé", "el participio pasado"], ["l''antériorité", "la anterioridad"], ["regretter", "lamentar"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='fr' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '9611d306-f9ba-59c7-89d9-ee60fb591aef', c.id, 'B1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "à ce moment-là", "es": "en ese momento"}, {"en": "ce jour-là", "es": "aquel día"}, {"en": "autrefois", "es": "antaño, antes"}, {"en": "par la suite", "es": "más tarde, después"}, {"en": "le discours indirect", "es": "el discurso indirecto"}]}'::jsonb, '{"pairs": [["à ce moment-là", "en ese momento"], ["ce jour-là", "aquel día"], ["autrefois", "antaño, antes"], ["par la suite", "más tarde, después"], ["le discours indirect", "el discurso indirecto"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='fr' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '1968bf45-ab26-57af-93d5-38bcb5a75c9a', c.id, 'B1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "la concordance des temps", "es": "la concordancia de tiempos"}, {"en": "rapporter", "es": "reportar, referir"}, {"en": "déclarer", "es": "declarar"}]}'::jsonb, '{"pairs": [["la concordance des temps", "la concordancia de tiempos"], ["rapporter", "reportar, referir"], ["déclarer", "declarar"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='fr' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'd3a44e0b-b303-564a-b52e-313649837e55', c.id, 'B1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "annoncer", "es": "anunciar"}, {"en": "prétendre", "es": "pretender, afirmar"}, {"en": "l''interrogation indirecte", "es": "la interrogación indirecta"}, {"en": "l''ordre", "es": "la orden"}, {"en": "ce jour-là", "es": "aquel día"}]}'::jsonb, '{"pairs": [["annoncer", "anunciar"], ["prétendre", "pretender, afirmar"], ["l''interrogation indirecte", "la interrogación indirecta"], ["l''ordre", "la orden"], ["ce jour-là", "aquel día"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='fr' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'ddbad9fb-5568-5619-82da-12ddd1740c0d', c.id, 'B1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "à ce moment-là", "es": "en ese momento"}, {"en": "le participe présent", "es": "el participio presente"}, {"en": "le gérondif", "es": "el gerundio"}]}'::jsonb, '{"pairs": [["à ce moment-là", "en ese momento"], ["le participe présent", "el participio presente"], ["le gérondif", "el gerundio"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='fr' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '5a140da7-c73d-5da7-94d5-c657fe6d1fcf', c.id, 'B1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "les clés", "es": "las llaves"}, {"en": "prêter", "es": "prestar"}, {"en": "expliquer", "es": "explicar"}]}'::jsonb, '{"pairs": [["les clés", "las llaves"], ["prêter", "prestar"], ["expliquer", "explicar"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='fr' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '68009ad4-1436-5157-9f68-3358f82c5570', c.id, 'B2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "l''émotion", "es": "la emoción"}, {"en": "le conseil", "es": "el consejo"}, {"en": "la boulangerie", "es": "la panadería"}]}'::jsonb, '{"pairs": [["l''émotion", "la emoción"], ["le conseil", "el consejo"], ["la boulangerie", "la panadería"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='fr' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'dc73f938-3e4d-5538-bd9a-41ea8af4af89', c.id, 'B2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "le conditionnel passé", "es": "el condicional pasado"}, {"en": "le regret", "es": "el arrepentimiento / la pena"}, {"en": "le reproche", "es": "el reproche"}, {"en": "l''hypothèse", "es": "la hipótesis"}, {"en": "se rendre compte", "es": "darse cuenta"}]}'::jsonb, '{"pairs": [["le conditionnel passé", "el condicional pasado"], ["le regret", "el arrepentimiento / la pena"], ["le reproche", "el reproche"], ["l''hypothèse", "la hipótesis"], ["se rendre compte", "darse cuenta"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='fr' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'd5dac914-bb15-5104-b005-c190c140bedb', c.id, 'B2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "avoir dû", "es": "haber tenido que / haber debido"}, {"en": "avoir pu", "es": "haber podido"}]}'::jsonb, '{"pairs": [["avoir dû", "haber tenido que / haber debido"], ["avoir pu", "haber podido"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='fr' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '0bf7bad8-01e4-5947-acf4-43042b3f2959', c.id, 'B2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "l''avant-veille", "es": "dos días antes"}, {"en": "le surlendemain", "es": "dos días después"}]}'::jsonb, '{"pairs": [["l''avant-veille", "dos días antes"], ["le surlendemain", "dos días después"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='fr' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '972e47bc-8e08-501d-a42c-442a10e55128', c.id, 'B2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "en marchant", "es": "andando / al caminar"}, {"en": "ainsi", "es": "así"}, {"en": "la manière", "es": "la manera"}]}'::jsonb, '{"pairs": [["en marchant", "andando / al caminar"], ["ainsi", "así"], ["la manière", "la manera"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='fr' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '724fa884-29e1-58f8-a5a3-8a75a0e5ebb8', c.id, 'B2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "la peur", "es": "el miedo"}, {"en": "douter que", "es": "dudar que"}, {"en": "à condition que", "es": "a condición de que"}, {"en": "sans que", "es": "sin que"}, {"en": "en effet", "es": "en efecto, es que"}]}'::jsonb, '{"pairs": [["la peur", "el miedo"], ["douter que", "dudar que"], ["à condition que", "a condición de que"], ["sans que", "sin que"], ["en effet", "en efecto, es que"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='fr' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'ae59fa0e-f050-5094-95b1-ca9adb8dc3c4', c.id, 'B2', 'reading', 'translation', 'Traduce al idioma que aprendes.', '{"source": "por más que, por mucho que"}'::jsonb, '{"value": "avoir beau"}'::jsonb, 0.2, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='fr' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'b195d821-7a90-5689-989d-02f74eaffd68', c.id, 'B2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "la voix passive", "es": "la voz pasiva"}, {"en": "le complément d''agent", "es": "el complemento de agente"}, {"en": "être respecté de tous", "es": "ser respetado por todos"}, {"en": "se faire voler", "es": "que le roben a uno"}, {"en": "il paraît que", "es": "parece que (se dice que)"}]}'::jsonb, '{"pairs": [["la voix passive", "la voz pasiva"], ["le complément d''agent", "el complemento de agente"], ["être respecté de tous", "ser respetado por todos"], ["se faire voler", "que le roben a uno"], ["il paraît que", "parece que (se dice que)"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='fr' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '92e4a01d-736c-5209-8c7d-61bd1737597c', c.id, 'B2', 'reading', 'translation', 'Traduce al idioma que aprendes.', '{"source": "la bicicleta"}'::jsonb, '{"value": "le vélo"}'::jsonb, 0.2, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='fr' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'd798dbfe-bad2-5d6e-908c-6ed5d6385653', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "scruter", "es": "escrutar, escudriñar"}, {"en": "apprécier", "es": "apreciar, valorar"}, {"en": "nourrir un espoir", "es": "albergar una esperanza"}, {"en": "prendre une décision", "es": "tomar una decisión"}, {"en": "formuler une hypothèse", "es": "formular una hipótesis"}]}'::jsonb, '{"pairs": [["scruter", "escrutar, escudriñar"], ["apprécier", "apreciar, valorar"], ["nourrir un espoir", "albergar una esperanza"], ["prendre une décision", "tomar una decisión"], ["formuler une hypothèse", "formular una hipótesis"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='fr' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '7096236d-b28b-52a1-bb0d-e0ddd9f65aaa', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "le conditionnel journalistique", "es": "el condicional periodístico (info no confirmada)"}, {"en": "vraisemblable", "es": "verosímil, probable"}]}'::jsonb, '{"pairs": [["le conditionnel journalistique", "el condicional periodístico (info no confirmada)"], ["vraisemblable", "verosímil, probable"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='fr' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'bd52215a-8d02-518e-887a-62f017d5f68a', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "se passer", "es": "ocurrir / suceder"}, {"en": "éviter", "es": "evitar"}, {"en": "décevoir", "es": "decepcionar"}, {"en": "à ce moment-là", "es": "en aquel momento"}, {"en": "sinon", "es": "si no / de lo contrario"}]}'::jsonb, '{"pairs": [["se passer", "ocurrir / suceder"], ["éviter", "evitar"], ["décevoir", "decepcionar"], ["à ce moment-là", "en aquel momento"], ["sinon", "si no / de lo contrario"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='fr' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '4b52049b-4ec1-5138-8087-05a5d90f96b5', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "dès que", "es": "en cuanto"}, {"en": "à l''époque", "es": "en aquella época"}, {"en": "il ressort de", "es": "se desprende de"}]}'::jsonb, '{"pairs": [["dès que", "en cuanto"], ["à l''époque", "en aquella época"], ["il ressort de", "se desprende de"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='fr' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'caed8ca3-044e-5d19-b383-08e49f7e4d36', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "rendre", "es": "devolver"}, {"en": "s''occuper de", "es": "ocuparse de"}, {"en": "la mise en relief", "es": "la puesta de relieve"}, {"en": "la dislocation", "es": "la dislocación (topicalización)"}, {"en": "à peine… que", "es": "apenas… cuando"}]}'::jsonb, '{"pairs": [["rendre", "devolver"], ["s''occuper de", "ocuparse de"], ["la mise en relief", "la puesta de relieve"], ["la dislocation", "la dislocación (topicalización)"], ["à peine… que", "apenas… cuando"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='fr' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'cf0b6aeb-4c9c-5752-8aa8-508dbe7b133a', c.id, 'C1', 'reading', 'translation', 'Traduce al idioma que aprendes.', '{"source": "quizá, tal vez"}'::jsonb, '{"value": "peut-être"}'::jsonb, 0.2, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='fr' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'ceb5a116-bcdd-5e05-8e49-92868d7786d9', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "ainsi", "es": "así, de este modo"}, {"en": "l''euphémisme", "es": "el eufemismo"}, {"en": "le sous-entendu", "es": "el sobreentendido"}, {"en": "le présupposé", "es": "el presupuesto (implícito)"}, {"en": "ne… guère", "es": "apenas, casi nada"}]}'::jsonb, '{"pairs": [["ainsi", "así, de este modo"], ["l''euphémisme", "el eufemismo"], ["le sous-entendu", "el sobreentendido"], ["le présupposé", "el presupuesto (implícito)"], ["ne… guère", "apenas, casi nada"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='fr' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '6b2d5217-5ded-5b1b-a3ac-9abf55403d9a', c.id, 'C1', 'reading', 'translation', 'Traduce al idioma que aprendes.', '{"source": "en absoluto, para nada"}'::jsonb, '{"value": "ne… point"}'::jsonb, 0.2, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='fr' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '76bf583f-9904-511c-80bc-851713190f97', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "ne… nullement", "es": "de ningún modo"}, {"en": "tomber dans les pommes", "es": "desmayarse"}, {"en": "en avoir ras-le-bol", "es": "estar hasta las narices"}, {"en": "être épuisé", "es": "estar agotado"}, {"en": "être las", "es": "estar hastiado / cansado"}]}'::jsonb, '{"pairs": [["ne… nullement", "de ningún modo"], ["tomber dans les pommes", "desmayarse"], ["en avoir ras-le-bol", "estar hasta las narices"], ["être épuisé", "estar agotado"], ["être las", "estar hastiado / cansado"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='fr' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'ba81f038-755b-5afb-a202-a92a06570604', c.id, 'C1', 'reading', 'translation', 'Traduce al idioma que aprendes.', '{"source": "una locución / un giro fijo"}'::jsonb, '{"value": "une locution"}'::jsonb, 0.2, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='fr' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '24210bb7-6584-54a9-bad4-b07eb0dd4cf6', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "l''adjectif verbal", "es": "el adjetivo verbal"}, {"en": "simultané", "es": "simultáneo"}, {"en": "fatigant", "es": "cansado (que cansa)"}, {"en": "provocant", "es": "provocador"}, {"en": "précédent", "es": "precedente / anterior"}]}'::jsonb, '{"pairs": [["l''adjectif verbal", "el adjetivo verbal"], ["simultané", "simultáneo"], ["fatigant", "cansado (que cansa)"], ["provocant", "provocador"], ["précédent", "precedente / anterior"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='fr' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '6a1828f3-c1de-5a62-8e33-bc74c36c6058', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "différent", "es": "diferente"}, {"en": "en admettant que", "es": "admitiendo que, aun suponiendo que (+ subj)"}, {"en": "à moins d''un imprévu", "es": "salvo imprevisto"}, {"en": "à condition que", "es": "a condición de que (+ subj)"}, {"en": "une éventualité", "es": "una eventualidad, una posibilidad"}]}'::jsonb, '{"pairs": [["différent", "diferente"], ["en admettant que", "admitiendo que, aun suponiendo que (+ subj)"], ["à moins d''un imprévu", "salvo imprevisto"], ["à condition que", "a condición de que (+ subj)"], ["une éventualité", "una eventualidad, una posibilidad"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='fr' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '2a92d3a9-f734-512d-bfcd-81f6df9d3975', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "ajouter", "es": "añadir"}, {"en": "avouer", "es": "confesar, admitir"}, {"en": "la mise en relief", "es": "la puesta de relieve"}, {"en": "la démonstration", "es": "la demostración"}, {"en": "en outre", "es": "además"}]}'::jsonb, '{"pairs": [["ajouter", "añadir"], ["avouer", "confesar, admitir"], ["la mise en relief", "la puesta de relieve"], ["la démonstration", "la demostración"], ["en outre", "además"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='fr' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'ab3724f6-b5b0-5c0c-8e5d-0bb9d5d94f4b', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "partant", "es": "por lo tanto"}, {"en": "avoir pour objet", "es": "tener por objeto"}]}'::jsonb, '{"pairs": [["partant", "por lo tanto"], ["avoir pour objet", "tener por objeto"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='fr' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'fbe56176-d026-545f-94de-7d324fc73616', c.id, 'A1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "salve", "es": "hola (neutro/cortés)"}, {"en": "io ho", "es": "yo tengo"}, {"en": "tu hai", "es": "tú tienes"}, {"en": "forse", "es": "quizás"}, {"en": "spiegare", "es": "explicar"}]}'::jsonb, '{"pairs": [["salve", "hola (neutro/cortés)"], ["io ho", "yo tengo"], ["tu hai", "tú tienes"], ["forse", "quizás"], ["spiegare", "explicar"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='it' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '09205d1c-1e68-5623-bf85-bb7fcce6e154', c.id, 'A1', 'reading', 'translation', 'Traduce al idioma que aprendes.', '{"source": "el discurso indirecto"}'::jsonb, '{"value": "il discorso indiretto"}'::jsonb, 0.2, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='it' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '880717fb-d05c-5a04-8273-af0f2c703a54', c.id, 'A1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "la figlia", "es": "la hija"}, {"en": "il nonno", "es": "el abuelo"}, {"en": "la famiglia", "es": "la familia"}, {"en": "piccolo", "es": "pequeño"}]}'::jsonb, '{"pairs": [["la figlia", "la hija"], ["il nonno", "el abuelo"], ["la famiglia", "la familia"], ["piccolo", "pequeño"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='it' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '5f90ae1e-f817-5307-b30a-b8d8f90c6d40', c.id, 'A1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "il latte", "es": "la leche"}, {"en": "il vino", "es": "el vino"}, {"en": "dell''", "es": "algo de (partitivo ante vocal)"}, {"en": "dovrei", "es": "debería"}, {"en": "mi piacerebbe", "es": "me gustaría"}]}'::jsonb, '{"pairs": [["il latte", "la leche"], ["il vino", "el vino"], ["dell''", "algo de (partitivo ante vocal)"], ["dovrei", "debería"], ["mi piacerebbe", "me gustaría"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='it' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '9312704b-9584-5f3e-93d4-055b44c948bb', c.id, 'A1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "vengo da", "es": "vengo de"}, {"en": "il quarto", "es": "el cuarto"}, {"en": "lavorare", "es": "trabajar"}, {"en": "abitare", "es": "vivir (residir)"}]}'::jsonb, '{"pairs": [["vengo da", "vengo de"], ["il quarto", "el cuarto"], ["lavorare", "trabajar"], ["abitare", "vivir (residir)"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='it' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '1517d733-2e30-5aad-909a-325b2038f369', c.id, 'A1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "vicino a", "es": "cerca de"}, {"en": "accanto a", "es": "al lado de"}, {"en": "di fronte a", "es": "enfrente de"}, {"en": "l''aeroporto", "es": "el aeropuerto"}]}'::jsonb, '{"pairs": [["vicino a", "cerca de"], ["accanto a", "al lado de"], ["di fronte a", "enfrente de"], ["l''aeroporto", "el aeropuerto"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='it' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '9d2162c3-f04d-50db-9601-6af11fc8a5f6', c.id, 'A2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "il weekend scorso", "es": "el fin de semana pasado"}, {"en": "il participio", "es": "el participio"}, {"en": "l''ausiliare", "es": "el auxiliar"}, {"en": "il soggetto", "es": "el sujeto"}]}'::jsonb, '{"pairs": [["il weekend scorso", "el fin de semana pasado"], ["il participio", "el participio"], ["l''ausiliare", "el auxiliar"], ["il soggetto", "el sujeto"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='it' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '98b69a3c-e70f-537d-841c-7305cf4fdd65', c.id, 'A2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "potrò", "es": "podré"}, {"en": "stare per", "es": "estar a punto de"}, {"en": "alzarsi", "es": "levantarse"}, {"en": "vestirsi", "es": "vestirse"}, {"en": "vedere", "es": "ver"}]}'::jsonb, '{"pairs": [["potrò", "podré"], ["stare per", "estar a punto de"], ["alzarsi", "levantarse"], ["vestirsi", "vestirse"], ["vedere", "ver"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='it' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'dba10773-bfa1-55d2-81f9-359ffe020b86', c.id, 'A2', 'reading', 'translation', 'Traduce al idioma que aprendes.', '{"source": "conocer"}'::jsonb, '{"value": "conoscere"}'::jsonb, 0.2, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='it' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '04fab0ab-2c2a-5983-955b-b05569cc5b3d', c.id, 'A2', 'reading', 'translation', 'Traduce al idioma que aprendes.', '{"source": "bajar"}'::jsonb, '{"value": "scendere"}'::jsonb, 0.2, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='it' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '2a720ea3-e37a-5484-8f81-990400c9fd31', c.id, 'A2', 'reading', 'translation', 'Traduce al idioma que aprendes.', '{"source": "un kilo de"}'::jsonb, '{"value": "un chilo di"}'::jsonb, 0.2, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='it' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '2f60e170-a615-5467-b73f-fb0547962802', c.id, 'A2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "basso", "es": "bajo"}, {"en": "biondo", "es": "rubio"}, {"en": "c''era", "es": "había"}, {"en": "la vedo", "es": "la veo"}]}'::jsonb, '{"pairs": [["basso", "bajo"], ["biondo", "rubio"], ["c''era", "había"], ["la vedo", "la veo"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='it' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '46365abf-89ef-5b37-8893-7df65f7bf7b0', c.id, 'A2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "il braccio", "es": "el brazo"}, {"en": "la pancia", "es": "la barriga"}, {"en": "i denti", "es": "los dientes"}, {"en": "il piede", "es": "el pie"}, {"en": "il congiuntivo", "es": "el subjuntivo"}]}'::jsonb, '{"pairs": [["il braccio", "el brazo"], ["la pancia", "la barriga"], ["i denti", "los dientes"], ["il piede", "el pie"], ["il congiuntivo", "el subjuntivo"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='it' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '06e20f17-3b99-5e2e-b9a7-a9d3ea600897', c.id, 'A2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "pensare che", "es": "pensar que"}, {"en": "credere che", "es": "creer que"}, {"en": "volere che", "es": "querer que"}]}'::jsonb, '{"pairs": [["pensare che", "pensar que"], ["credere che", "creer que"], ["volere che", "querer que"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='it' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'a6a26339-3481-55db-9b3c-3bda0a4eaee0', c.id, 'B1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "sperare che", "es": "esperar que"}, {"en": "è importante che", "es": "es importante que"}, {"en": "è possibile che", "es": "es posible que"}, {"en": "il dubbio", "es": "la duda"}, {"en": "la volontà", "es": "la voluntad"}]}'::jsonb, '{"pairs": [["sperare che", "esperar que"], ["è importante che", "es importante que"], ["è possibile che", "es posible que"], ["il dubbio", "la duda"], ["la volontà", "la voluntad"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='it' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'f2f82f3a-0e7b-56e9-bf2c-af26d6d3b9cf', c.id, 'B1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "l''opinione", "es": "la opinión"}, {"en": "a patto che", "es": "a condición de que (+ subj.)"}]}'::jsonb, '{"pairs": [["l''opinione", "la opinión"], ["a patto che", "a condición de que (+ subj.)"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='it' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '1a0bf15e-0c2c-50e1-b455-821dc32cee1a', c.id, 'B1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "rimanere", "es": "quedarse"}, {"en": "salire", "es": "subir"}, {"en": "arrivare", "es": "llegar"}]}'::jsonb, '{"pairs": [["rimanere", "quedarse"], ["salire", "subir"], ["arrivare", "llegar"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='it' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'af2a938c-b5e1-506e-ba50-304122cfcbd1', c.id, 'B1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "l''amico", "es": "el amigo"}, {"en": "la ragazza", "es": "la chica"}, {"en": "il quadro", "es": "el cuadro"}, {"en": "pensare a", "es": "pensar en"}, {"en": "contare su", "es": "contar con"}]}'::jsonb, '{"pairs": [["l''amico", "el amigo"], ["la ragazza", "la chica"], ["il quadro", "el cuadro"], ["pensare a", "pensar en"], ["contare su", "contar con"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='it' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'a09517d8-9b90-505d-b8dd-ee2940e65c1a', c.id, 'B1', 'reading', 'translation', 'Traduce al idioma que aprendes.', '{"source": "fiarse de"}'::jsonb, '{"value": "fidarsi di"}'::jsonb, 0.2, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='it' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'c5e00f38-0b80-5747-ad40-c43f9c2c043c', c.id, 'B1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "arrivare", "es": "llegar"}, {"en": "nascere", "es": "nacer"}, {"en": "svegliarsi", "es": "despertarse"}, {"en": "il condizionale composto", "es": "el condicional compuesto"}, {"en": "la concordanza dei tempi", "es": "la correlación de tiempos"}]}'::jsonb, '{"pairs": [["arrivare", "llegar"], ["nascere", "nacer"], ["svegliarsi", "despertarse"], ["il condizionale composto", "el condicional compuesto"], ["la concordanza dei tempi", "la correlación de tiempos"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='it' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '829ba43a-3c64-5f90-bf6a-cf3a8528d24b', c.id, 'B1', 'reading', 'translation', 'Traduce al idioma que aprendes.', '{"source": "entonces (en aquel momento)"}'::jsonb, '{"value": "allora"}'::jsonb, 0.2, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='it' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '2d732d78-cce4-55a1-99f8-575f2b4dbb74', c.id, 'B1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "rispondere", "es": "responder"}, {"en": "raccontare", "es": "contar"}, {"en": "Ci penso io", "es": "Yo me encargo"}, {"en": "me lo dai", "es": "me lo das"}, {"en": "te lo dico", "es": "te lo digo"}]}'::jsonb, '{"pairs": [["rispondere", "responder"], ["raccontare", "contar"], ["Ci penso io", "Yo me encargo"], ["me lo dai", "me lo das"], ["te lo dico", "te lo digo"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='it' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '02b037ce-cd9e-58ee-aa66-575e1f980812', c.id, 'B1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "gliene parlo", "es": "le hablo de ello"}, {"en": "ce n''è", "es": "hay (de eso)"}, {"en": "il discorso indiretto", "es": "el discurso indirecto"}, {"en": "riferire", "es": "referir, transmitir"}]}'::jsonb, '{"pairs": [["gliene parlo", "le hablo de ello"], ["ce n''è", "hay (de eso)"], ["il discorso indiretto", "el discurso indirecto"], ["riferire", "referir, transmitir"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='it' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '7e39cb56-a694-5b47-9eaf-ab9e5056aebf', c.id, 'B2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "il congiuntivo imperfetto", "es": "el subjuntivo imperfecto"}, {"en": "il congiuntivo trapassato", "es": "el subjuntivo pluscuamperfecto"}, {"en": "che fossi", "es": "que fuera / estuviera"}, {"en": "che avessi", "es": "que hubiera / tuviera"}, {"en": "che facesse", "es": "que hiciera"}]}'::jsonb, '{"pairs": [["il congiuntivo imperfetto", "el subjuntivo imperfecto"], ["il congiuntivo trapassato", "el subjuntivo pluscuamperfecto"], ["che fossi", "que fuera / estuviera"], ["che avessi", "que hubiera / tuviera"], ["che facesse", "que hiciera"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='it' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '8ad3de2d-d32a-56e6-ba6a-066f048f1109', c.id, 'B2', 'reading', 'translation', 'Traduce al idioma que aprendes.', '{"source": "hubiera terminado"}'::jsonb, '{"value": "avesse finito"}'::jsonb, 0.2, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='it' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'a2d73d12-20ed-5ed0-89a1-c91a594261bc', c.id, 'B2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "fossero partiti", "es": "hubieran salido"}, {"en": "credevo che", "es": "creía que"}, {"en": "l''anteriorità", "es": "la anterioridad"}, {"en": "la concordanza dei tempi", "es": "la correlación de tiempos"}, {"en": "ciò che", "es": "lo que"}]}'::jsonb, '{"pairs": [["fossero partiti", "hubieran salido"], ["credevo che", "creía que"], ["l''anteriorità", "la anterioridad"], ["la concordanza dei tempi", "la correlación de tiempos"], ["ciò che", "lo que"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='it' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '6dd6d410-6d0f-5eda-9136-9e26354389af', c.id, 'B2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "Se potessi, ti aiuterei", "es": "Si pudiera, te ayudaría"}, {"en": "sarei venuto", "es": "habría venido"}, {"en": "sarei andata", "es": "habría ido (fem.)"}, {"en": "avrebbe detto", "es": "habría dicho (según dicen)"}, {"en": "altrimenti", "es": "de lo contrario"}]}'::jsonb, '{"pairs": [["Se potessi, ti aiuterei", "Si pudiera, te ayudaría"], ["sarei venuto", "habría venido"], ["sarei andata", "habría ido (fem.)"], ["avrebbe detto", "habría dicho (según dicen)"], ["altrimenti", "de lo contrario"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='it' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'a46529dc-5189-5572-a095-6cc67f39617b', c.id, 'B2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "il rimpianto", "es": "el arrepentimiento"}, {"en": "laureato", "es": "graduado / licenciado"}]}'::jsonb, '{"pairs": [["il rimpianto", "el arrepentimiento"], ["laureato", "graduado / licenciado"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='it' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '48527d52-94af-5c41-afe2-c9d06bcef696', c.id, 'B2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "la forma passiva", "es": "la voz pasiva"}, {"en": "il complemento d''agente", "es": "el complemento agente"}, {"en": "essere scritto", "es": "ser escrito"}, {"en": "venire consegnato", "es": "ser entregado"}, {"en": "andare rispettato", "es": "deber ser respetado"}]}'::jsonb, '{"pairs": [["la forma passiva", "la voz pasiva"], ["il complemento d''agente", "el complemento agente"], ["essere scritto", "ser escrito"], ["venire consegnato", "ser entregado"], ["andare rispettato", "deber ser respetado"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='it' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'a149dff0-7b5f-59cc-ba77-53b1fe9d5e49', c.id, 'B2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "il si passivante", "es": "el «se» pasivo"}, {"en": "si vendono case", "es": "se venden casas"}]}'::jsonb, '{"pairs": [["il si passivante", "el «se» pasivo"], ["si vendono case", "se venden casas"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='it' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '8e905574-4b72-564a-ab30-4490246e2898', c.id, 'B2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "mezzanotte", "es": "medianoche"}, {"en": "il futuro", "es": "el futuro"}, {"en": "si parla italiano", "es": "se habla italiano"}, {"en": "compilare", "es": "rellenar (un formulario)"}, {"en": "approvare", "es": "aprobar"}]}'::jsonb, '{"pairs": [["mezzanotte", "medianoche"], ["il futuro", "el futuro"], ["si parla italiano", "se habla italiano"], ["compilare", "rellenar (un formulario)"], ["approvare", "aprobar"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='it' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '9de9d366-5fd0-5456-96c3-05380ad25135', c.id, 'B2', 'reading', 'translation', 'Traduce al idioma que aprendes.', '{"source": "el ganador"}'::jsonb, '{"value": "il vincitore"}'::jsonb, 0.2, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='it' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '91b0a999-6bc0-5a43-a128-d3e3dff2a0dd', c.id, 'B2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "a patto che", "es": "a condición de que (+ subj)"}, {"en": "in riferimento a", "es": "con referencia a"}]}'::jsonb, '{"pairs": [["a patto che", "a condición de que (+ subj)"], ["in riferimento a", "con referencia a"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='it' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'da0d5876-fd61-5959-95c2-12999360aec3', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "il sogno", "es": "el sueño"}, {"en": "il consiglio", "es": "el consejo"}, {"en": "la possibilità", "es": "la posibilidad"}, {"en": "il viaggio", "es": "el viaje"}, {"en": "scrutare", "es": "escrutar, escudriñar"}]}'::jsonb, '{"pairs": [["il sogno", "el sueño"], ["il consiglio", "el consejo"], ["la possibilità", "la posibilidad"], ["il viaggio", "el viaje"], ["scrutare", "escrutar, escudriñar"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='it' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '76f2880c-5b07-5b83-9006-0349e75a8760', c.id, 'C1', 'reading', 'translation', 'Traduce al idioma que aprendes.', '{"source": "apreciar, valorar"}'::jsonb, '{"value": "apprezzare"}'::jsonb, 0.2, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='it' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '437ce450-a6b6-5035-b6df-f3193cdde8ad', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "gradire", "es": "gustar de, agradecer (formal)"}, {"en": "nutrire una speranza", "es": "albergar una esperanza"}, {"en": "prendere una decisione", "es": "tomar una decisión"}, {"en": "sollevare un dubbio", "es": "plantear una duda"}, {"en": "la sfumatura", "es": "el matiz"}]}'::jsonb, '{"pairs": [["gradire", "gustar de, agradecer (formal)"], ["nutrire una speranza", "albergar una esperanza"], ["prendere una decisione", "tomar una decisión"], ["sollevare un dubbio", "plantear una duda"], ["la sfumatura", "el matiz"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='it' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'b8ab89a6-3c9a-59e2-9699-ba401d1a9e80', c.id, 'C1', 'reading', 'translation', 'Traduce al idioma que aprendes.', '{"source": "la connotación"}'::jsonb, '{"value": "la connotazione"}'::jsonb, 0.2, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='it' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '7956f30f-65e0-5157-bb8a-eb4e6739621f', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "se pure", "es": "aun cuando, si bien"}, {"en": "la frase scissa", "es": "la oración escindida (perífrasis de relieve)"}, {"en": "mettere in rilievo", "es": "poner de relieve, destacar"}, {"en": "è proprio così", "es": "es exactamente así"}]}'::jsonb, '{"pairs": [["se pure", "aun cuando, si bien"], ["la frase scissa", "la oración escindida (perífrasis de relieve)"], ["mettere in rilievo", "poner de relieve, destacar"], ["è proprio così", "es exactamente así"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='it' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '8f108b92-ad40-5771-a899-21ac48ec0fa7', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "perfino, persino", "es": "incluso, hasta"}, {"en": "la dislocazione a sinistra", "es": "la dislocación a la izquierda"}, {"en": "riprendere con un pronome", "es": "retomar con un pronombre"}, {"en": "l''anteposizione", "es": "la anteposición (estilística)"}, {"en": "grande fu la sorpresa", "es": "grande fue la sorpresa"}]}'::jsonb, '{"pairs": [["perfino, persino", "incluso, hasta"], ["la dislocazione a sinistra", "la dislocación a la izquierda"], ["riprendere con un pronome", "retomar con un pronombre"], ["l''anteposizione", "la anteposición (estilística)"], ["grande fu la sorpresa", "grande fue la sorpresa"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='it' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '4fffae64-55af-5892-a9c8-fa8783d6bc99', c.id, 'C1', 'reading', 'translation', 'Traduce al idioma que aprendes.', '{"source": "hay una cosa que"}'::jsonb, '{"value": "c''è una cosa che"}'::jsonb, 0.2, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='it' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'aa3148ae-739c-52c0-9789-b3d74c8eb9ea', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "la litote", "es": "la lítote (atenuación)"}, {"en": "non è affatto male", "es": "no está nada mal"}, {"en": "non… mica", "es": "no… en absoluto (coloquial)"}, {"en": "il sottinteso", "es": "el sobreentendido"}, {"en": "sminuire, attenuare", "es": "atenuar, minimizar"}]}'::jsonb, '{"pairs": [["la litote", "la lítote (atenuación)"], ["non è affatto male", "no está nada mal"], ["non… mica", "no… en absoluto (coloquial)"], ["il sottinteso", "el sobreentendido"], ["sminuire, attenuare", "atenuar, minimizar"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='it' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '99b0dc46-631f-5ac0-a96f-cb64e69d442d', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "in bocca al lupo", "es": "buena suerte (mucha mierda)"}, {"en": "tirare a campare", "es": "ir tirando / sobrevivir a duras penas"}, {"en": "cadere dalle nuvole", "es": "caer de las nubes / quedar atónito"}, {"en": "fare orecchie da mercante", "es": "hacerse el sordo / oídos sordos"}, {"en": "essere distrutto", "es": "estar destrozado / agotado"}]}'::jsonb, '{"pairs": [["in bocca al lupo", "buena suerte (mucha mierda)"], ["tirare a campare", "ir tirando / sobrevivir a duras penas"], ["cadere dalle nuvole", "caer de las nubes / quedar atónito"], ["fare orecchie da mercante", "hacerse el sordo / oídos sordos"], ["essere distrutto", "estar destrozado / agotado"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='it' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '26cd9f27-5548-5c50-a963-e692d48e680d', c.id, 'C1', 'reading', 'translation', 'Traduce al idioma que aprendes.', '{"source": "estar exhausto / extenuado"}'::jsonb, '{"value": "essere spossato"}'::jsonb, 0.2, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='it' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '647d2d86-f8d2-5a8e-9662-213a01f2380c', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "senza che", "es": "sin que (+ subj.)"}, {"en": "a meno che… non", "es": "a menos que (+ subj)"}, {"en": "sempre che", "es": "siempre y cuando (+ subj)"}, {"en": "casomai", "es": "por si acaso, si acaso"}, {"en": "il condizionale giornalistico", "es": "el condicional periodístico (info no confirmada)"}]}'::jsonb, '{"pairs": [["senza che", "sin que (+ subj.)"], ["a meno che… non", "a menos que (+ subj)"], ["sempre che", "siempre y cuando (+ subj)"], ["casomai", "por si acaso, si acaso"], ["il condizionale giornalistico", "el condicional periodístico (info no confirmada)"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='it' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '984c778c-77ba-52df-8be2-f9a63e650319', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "potrebbe darsi che", "es": "podría ser que, puede que (+ subj)"}, {"en": "il periodo ipotetico", "es": "el periodo hipotético"}, {"en": "verosimile", "es": "verosímil, probable"}, {"en": "salvo imprevisti", "es": "salvo imprevistos"}, {"en": "un''eventualità", "es": "una eventualidad, una posibilidad"}]}'::jsonb, '{"pairs": [["potrebbe darsi che", "podría ser que, puede que (+ subj)"], ["il periodo ipotetico", "el periodo hipotético"], ["verosimile", "verosímil, probable"], ["salvo imprevisti", "salvo imprevistos"], ["un''eventualità", "una eventualidad, una posibilidad"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='it' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '790bfa8a-c349-51c5-9fa1-48b647a36b22', c.id, 'C1', 'reading', 'translation', 'Traduce al idioma que aprendes.', '{"source": "la demostración"}'::jsonb, '{"value": "la dimostrazione"}'::jsonb, 0.2, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='it' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '78b0df45-92f9-5d67-b12c-0aacaffcb99e', c.id, 'A1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "Auf Wiedersehen", "es": "hasta la vista (formal)"}, {"en": "der Name", "es": "el nombre"}, {"en": "nein", "es": "no"}, {"en": "null", "es": "cero"}]}'::jsonb, '{"pairs": [["Auf Wiedersehen", "hasta la vista (formal)"], ["der Name", "el nombre"], ["nein", "no"], ["null", "cero"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='de' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '17190cc8-7986-5c1a-94f9-d08f4dfad85a', c.id, 'A1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "eins", "es": "uno"}, {"en": "das Jahr", "es": "el año"}, {"en": "der Spanier", "es": "el español"}, {"en": "die Spanierin", "es": "la española"}]}'::jsonb, '{"pairs": [["eins", "uno"], ["das Jahr", "el año"], ["der Spanier", "el español"], ["die Spanierin", "la española"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='de' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '6dc156d2-58ed-5a9e-b4b8-1ce4f3546330', c.id, 'A1', 'reading', 'translation', 'Traduce al idioma que aprendes.', '{"source": "los abuelos"}'::jsonb, '{"value": "die Großeltern"}'::jsonb, 0.2, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='de' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '4f677ad5-83c6-5167-8625-65ebb5885fd5', c.id, 'A1', 'reading', 'translation', 'Traduce al idioma que aprendes.', '{"source": "el euro"}'::jsonb, '{"value": "der Euro"}'::jsonb, 0.2, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='de' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '0db67a37-626d-5e1b-98ef-dff363a3baf6', c.id, 'A1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "der Montag", "es": "el lunes"}, {"en": "der Dienstag", "es": "el martes"}, {"en": "der Mittwoch", "es": "el miércoles"}, {"en": "der Donnerstag", "es": "el jueves"}]}'::jsonb, '{"pairs": [["der Montag", "el lunes"], ["der Dienstag", "el martes"], ["der Mittwoch", "el miércoles"], ["der Donnerstag", "el jueves"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='de' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'dd397447-e84e-5ea2-a31d-7ef441b62412', c.id, 'A1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "der Platz", "es": "la plaza"}, {"en": "die Straße", "es": "la calle"}]}'::jsonb, '{"pairs": [["der Platz", "la plaza"], ["die Straße", "la calle"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='de' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '7f0cc1fa-4ed9-5044-8b33-437d32238582', c.id, 'A2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "genommen", "es": "tomado"}, {"en": "die E-Mail", "es": "el correo electrónico"}]}'::jsonb, '{"pairs": [["genommen", "tomado"], ["die E-Mail", "el correo electrónico"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='de' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '0d0d5a0e-e40e-579c-b5f1-82abe9edd119', c.id, 'A2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "der Freitag", "es": "el viernes"}, {"en": "der Samstag", "es": "el sábado"}, {"en": "der Sonntag", "es": "el domingo"}, {"en": "wohnen", "es": "vivir/residir"}, {"en": "spielen", "es": "jugar"}]}'::jsonb, '{"pairs": [["der Freitag", "el viernes"], ["der Samstag", "el sábado"], ["der Sonntag", "el domingo"], ["wohnen", "vivir/residir"], ["spielen", "jugar"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='de' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'fcef5c58-bd25-5520-9fc1-14848d5b6743', c.id, 'A2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "möchten", "es": "querer (cortés)"}, {"en": "vielleicht", "es": "quizás"}]}'::jsonb, '{"pairs": [["möchten", "querer (cortés)"], ["vielleicht", "quizás"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='de' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '95b8cdc0-c6b1-59bd-8e47-f35df61d855a', c.id, 'A2', 'reading', 'translation', 'Traduce al idioma que aprendes.', '{"source": "hacer la maleta"}'::jsonb, '{"value": "packen"}'::jsonb, 0.2, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='de' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '23351e33-c3e0-5c3d-91fa-23be38ec3165', c.id, 'A2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "die Stelle", "es": "el lugar / puesto"}, {"en": "der Wunsch", "es": "el deseo"}, {"en": "höflich", "es": "cortés / educado"}, {"en": "der Arbeiter", "es": "el obrero"}]}'::jsonb, '{"pairs": [["die Stelle", "el lugar / puesto"], ["der Wunsch", "el deseo"], ["höflich", "cortés / educado"], ["der Arbeiter", "el obrero"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='de' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '803acca9-a351-527e-9a59-b98f75f3d84b', c.id, 'A2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "hatten", "es": "teníamos / tenían"}, {"en": "die Haare", "es": "el pelo"}, {"en": "die Augen", "es": "los ojos"}, {"en": "blond", "es": "rubio"}, {"en": "braun", "es": "castaño / marrón"}]}'::jsonb, '{"pairs": [["hatten", "teníamos / tenían"], ["die Haare", "el pelo"], ["die Augen", "los ojos"], ["blond", "rubio"], ["braun", "castaño / marrón"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='de' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '0527da24-6983-5761-b614-c7dfbc1940c4', c.id, 'A2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "lang", "es": "largo"}, {"en": "pünktlich", "es": "puntual"}]}'::jsonb, '{"pairs": [["lang", "largo"], ["pünktlich", "puntual"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='de' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'c79d028b-281a-5e36-95b9-7d35d5bf0f8e', c.id, 'A2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "fliegen", "es": "volar"}, {"en": "ankommen", "es": "llegar"}, {"en": "kurz", "es": "corto"}, {"en": "der Arm", "es": "el brazo"}, {"en": "wehtun", "es": "doler"}]}'::jsonb, '{"pairs": [["fliegen", "volar"], ["ankommen", "llegar"], ["kurz", "corto"], ["der Arm", "el brazo"], ["wehtun", "doler"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='de' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'f658a81f-6bc0-5f3a-8594-a0cd23c3808d', c.id, 'A2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "das Fieber", "es": "la fiebre"}, {"en": "die Kopfschmerzen", "es": "el dolor de cabeza"}, {"en": "der Arzt", "es": "el médico"}]}'::jsonb, '{"pairs": [["das Fieber", "la fiebre"], ["die Kopfschmerzen", "el dolor de cabeza"], ["der Arzt", "el médico"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='de' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '87c56947-bb0d-5119-a830-ded203fd46cc', c.id, 'B1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "sollte", "es": "debería"}, {"en": "der Rat", "es": "el consejo"}, {"en": "Könnten Sie…?", "es": "¿Podría usted…?"}, {"en": "behaupten", "es": "afirmar, sostener"}, {"en": "betonen", "es": "subrayar, recalcar"}]}'::jsonb, '{"pairs": [["sollte", "debería"], ["der Rat", "el consejo"], ["Könnten Sie…?", "¿Podría usted…?"], ["behaupten", "afirmar, sostener"], ["betonen", "subrayar, recalcar"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='de' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'a07211de-f739-58ea-8360-d66ca86c56d0', c.id, 'B1', 'reading', 'translation', 'Traduce al idioma que aprendes.', '{"source": "comunicar, notificar"}'::jsonb, '{"value": "mitteilen"}'::jsonb, 0.2, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='de' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '4fb94b5a-ec78-50f5-846e-af61277ddb2f', c.id, 'B1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "die Idee", "es": "la idea"}, {"en": "die Erkältung", "es": "el resfriado"}, {"en": "der Bus", "es": "el autobús"}]}'::jsonb, '{"pairs": [["die Idee", "la idea"], ["die Erkältung", "el resfriado"], ["der Bus", "el autobús"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='de' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'f2628eac-0479-51d4-ab0b-ccd4659fa918', c.id, 'B1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "die Kollegin", "es": "la colega"}, {"en": "der Film", "es": "la película"}]}'::jsonb, '{"pairs": [["die Kollegin", "la colega"], ["der Film", "la película"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='de' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'cdd7b862-9376-548e-8ce7-d93e5aa51f1a', c.id, 'B1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "das Paket", "es": "el paquete"}, {"en": "bauen", "es": "construir"}, {"en": "liefern", "es": "entregar"}, {"en": "unterschreiben", "es": "firmar"}, {"en": "herstellen", "es": "fabricar"}]}'::jsonb, '{"pairs": [["das Paket", "el paquete"], ["bauen", "construir"], ["liefern", "entregar"], ["unterschreiben", "firmar"], ["herstellen", "fabricar"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='de' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'a199a67e-a627-5036-aed7-1f65ab959b87', c.id, 'B1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "die Musik", "es": "la música"}, {"en": "die Verantwortung", "es": "la responsabilidad"}]}'::jsonb, '{"pairs": [["die Musik", "la música"], ["die Verantwortung", "la responsabilidad"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='de' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '647d57b4-1b33-5931-b0bc-45665127ee8b', c.id, 'B1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "vielleicht", "es": "quizás"}, {"en": "wörtlich", "es": "literal"}, {"en": "übertragen", "es": "figurado"}, {"en": "treffend", "es": "acertado, certero"}]}'::jsonb, '{"pairs": [["vielleicht", "quizás"], ["wörtlich", "literal"], ["übertragen", "figurado"], ["treffend", "acertado, certero"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='de' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'fe995f67-758b-5502-af2d-edf05d388179', c.id, 'B2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "die Angst", "es": "el miedo"}, {"en": "das Gewitter", "es": "la tormenta"}, {"en": "die indirekte Rede", "es": "el estilo/discurso indirecto"}, {"en": "der Konjunktiv", "es": "el subjuntivo (modo)"}, {"en": "die Aussage", "es": "la declaración"}]}'::jsonb, '{"pairs": [["die Angst", "el miedo"], ["das Gewitter", "la tormenta"], ["die indirekte Rede", "el estilo/discurso indirecto"], ["der Konjunktiv", "el subjuntivo (modo)"], ["die Aussage", "la declaración"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='de' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '69ac8f26-56ad-5840-850d-ce3726feb7ef', c.id, 'B2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "bestreiten", "es": "negar, desmentir"}, {"en": "angeblich", "es": "supuestamente"}, {"en": "die Stellungnahme", "es": "la toma de posición"}]}'::jsonb, '{"pairs": [["bestreiten", "negar, desmentir"], ["angeblich", "supuestamente"], ["die Stellungnahme", "la toma de posición"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='de' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '1ba9dc0f-e325-51de-8c88-53a26ad5277e', c.id, 'B2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "die Vergangenheit", "es": "el pasado"}, {"en": "die Voraussetzung", "es": "el requisito"}, {"en": "ersetzen", "es": "sustituir / reemplazar"}, {"en": "umsetzen", "es": "poner en práctica / implementar"}]}'::jsonb, '{"pairs": [["die Vergangenheit", "el pasado"], ["die Voraussetzung", "el requisito"], ["ersetzen", "sustituir / reemplazar"], ["umsetzen", "poner en práctica / implementar"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='de' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'f75c75f8-9dea-5e5e-b494-66b8469ca00e', c.id, 'B2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "der weinende Junge", "es": "el niño que llora"}, {"en": "die gebratene Wurst", "es": "la salchicha frita"}, {"en": "die schlafende Katze", "es": "el gato que duerme"}, {"en": "die steigenden Preise", "es": "los precios crecientes"}, {"en": "der geladene Gast", "es": "el invitado convocado"}]}'::jsonb, '{"pairs": [["der weinende Junge", "el niño que llora"], ["die gebratene Wurst", "la salchicha frita"], ["die schlafende Katze", "el gato que duerme"], ["die steigenden Preise", "los precios crecientes"], ["der geladene Gast", "el invitado convocado"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='de' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '6a7896a8-a7db-5d94-a34c-39e8dbe34714', c.id, 'B2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "das geschriebene Wort", "es": "la palabra escrita"}, {"en": "der geschlossene Laden", "es": "la tienda cerrada"}, {"en": "das fahrende Auto", "es": "el coche en marcha"}, {"en": "die verlorene Zeit", "es": "el tiempo perdido"}]}'::jsonb, '{"pairs": [["das geschriebene Wort", "la palabra escrita"], ["der geschlossene Laden", "la tienda cerrada"], ["das fahrende Auto", "el coche en marcha"], ["die verlorene Zeit", "el tiempo perdido"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='de' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'e6276d56-d5ba-5d89-8f4f-1ed85ce660f9', c.id, 'B2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "der Vorgang", "es": "el proceso"}, {"en": "der Zustand", "es": "el estado"}, {"en": "zunehmen", "es": "aumentar, incrementarse"}, {"en": "verbessern", "es": "mejorar"}, {"en": "einschränken", "es": "restringir, limitar"}]}'::jsonb, '{"pairs": [["der Vorgang", "el proceso"], ["der Zustand", "el estado"], ["zunehmen", "aumentar, incrementarse"], ["verbessern", "mejorar"], ["einschränken", "restringir, limitar"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='de' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'e1d4d679-6e45-5730-a413-0045e8525d85', c.id, 'B2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "die Verfügung", "es": "la disposición"}, {"en": "die Rücksicht", "es": "la consideración"}, {"en": "das Schwimmen", "es": "la natación (el nadar)"}, {"en": "stellen", "es": "poner / plantear"}, {"en": "üben", "es": "ejercer (crítica)"}]}'::jsonb, '{"pairs": [["die Verfügung", "la disposición"], ["die Rücksicht", "la consideración"], ["das Schwimmen", "la natación (el nadar)"], ["stellen", "poner / plantear"], ["üben", "ejercer (crítica)"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='de' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '064cce93-267c-5b09-9897-a50c6860bbd7', c.id, 'B2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "berücksichtigen", "es": "tener en cuenta"}, {"en": "schätzen", "es": "apreciar, valorar"}]}'::jsonb, '{"pairs": [["berücksichtigen", "tener en cuenta"], ["schätzen", "apreciar, valorar"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='de' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '0318ce55-26e5-5db6-8a7a-d5bf5908e1bf', c.id, 'B2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "die Möglichkeit", "es": "la posibilidad"}, {"en": "das Bedauern", "es": "el arrepentimiento"}, {"en": "der Rat", "es": "el consejo"}, {"en": "die Gelegenheit", "es": "la ocasión"}, {"en": "der Zufall", "es": "la casualidad"}]}'::jsonb, '{"pairs": [["die Möglichkeit", "la posibilidad"], ["das Bedauern", "el arrepentimiento"], ["der Rat", "el consejo"], ["die Gelegenheit", "la ocasión"], ["der Zufall", "la casualidad"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='de' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '868c5592-551a-562c-ada3-4787545f5b38', c.id, 'B2', 'reading', 'translation', 'Traduce al idioma que aprendes.', '{"source": "la solución"}'::jsonb, '{"value": "die Lösung"}'::jsonb, 0.2, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='de' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '9a624fb0-2eef-52e7-a8a4-ebfdfe9ea17b', c.id, 'B2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "die Maßnahme", "es": "la medida"}, {"en": "die Genehmigung", "es": "la autorización"}, {"en": "die Kritik", "es": "la crítica"}, {"en": "der Betracht", "es": "la consideración (in Betracht)"}, {"en": "das Anliegen", "es": "la petición, el asunto"}]}'::jsonb, '{"pairs": [["die Maßnahme", "la medida"], ["die Genehmigung", "la autorización"], ["die Kritik", "la crítica"], ["der Betracht", "la consideración (in Betracht)"], ["das Anliegen", "la petición, el asunto"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='de' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'cb5b6a8c-dc19-54f7-baf5-dfdab1903fd8', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "Kritik üben", "es": "ejercer/hacer crítica"}, {"en": "Maßnahmen ergreifen", "es": "tomar medidas"}, {"en": "der Wagen", "es": "el coche (registro elevado)"}, {"en": "die Karre", "es": "el coche (coloquial, despectivo)"}, {"en": "gehoben", "es": "elevado, culto (registro)"}]}'::jsonb, '{"pairs": [["Kritik üben", "ejercer/hacer crítica"], ["Maßnahmen ergreifen", "tomar medidas"], ["der Wagen", "el coche (registro elevado)"], ["die Karre", "el coche (coloquial, despectivo)"], ["gehoben", "elevado, culto (registro)"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='de' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'f6d80a11-8de1-586d-bbe2-392d69c29054', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "umgangssprachlich", "es": "coloquial (registro)"}, {"en": "die Konnotation", "es": "la connotación"}]}'::jsonb, '{"pairs": [["umgangssprachlich", "coloquial (registro)"], ["die Konnotation", "la connotación"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='de' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '1132eb16-be59-52eb-9dea-e6e8423e22bf', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "der Konnektor", "es": "el conector"}, {"en": "der Zusammenhang", "es": "la conexión, el contexto"}, {"en": "die Voraussetzung", "es": "el requisito, la condición"}, {"en": "der Gegensatz", "es": "el contraste, la oposición"}, {"en": "die Einschränkung", "es": "la restricción, el matiz"}]}'::jsonb, '{"pairs": [["der Konnektor", "el conector"], ["der Zusammenhang", "la conexión, el contexto"], ["die Voraussetzung", "el requisito, la condición"], ["der Gegensatz", "el contraste, la oposición"], ["die Einschränkung", "la restricción, el matiz"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='de' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'ea7a45f7-7e97-5742-b4c6-af67ad86efe2', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "die Fähigkeit", "es": "la capacidad, la habilidad"}, {"en": "das Vorfeld", "es": "el campo inicial (antes del verbo)"}, {"en": "der Spaltsatz", "es": "la oración escindida (cleft)"}]}'::jsonb, '{"pairs": [["die Fähigkeit", "la capacidad, la habilidad"], ["das Vorfeld", "el campo inicial (antes del verbo)"], ["der Spaltsatz", "la oración escindida (cleft)"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='de' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '9268bcc2-6c49-597a-933e-6836969ccf71', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "zweifellos", "es": "sin duda"}, {"en": "die Nuance", "es": "el matiz"}, {"en": "auffallen", "es": "llamar la atención, destacar"}, {"en": "die Bedingung", "es": "la condición"}, {"en": "zurückweisen", "es": "rechazar, desmentir"}]}'::jsonb, '{"pairs": [["zweifellos", "sin duda"], ["die Nuance", "el matiz"], ["auffallen", "llamar la atención, destacar"], ["die Bedingung", "la condición"], ["zurückweisen", "rechazar, desmentir"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='de' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'ef1f537e-3bf1-5dca-86e8-ca3c2912f27b', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "beteuern", "es": "asegurar, jurar"}, {"en": "der Vorwurf", "es": "el reproche, la acusación"}]}'::jsonb, '{"pairs": [["beteuern", "asegurar, jurar"], ["der Vorwurf", "el reproche, la acusación"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='de' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'c2c4492b-57c0-5bc1-8c5e-2bf27fa3a632', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "der Autor", "es": "el autor"}, {"en": "die Maschine", "es": "la máquina"}, {"en": "die Warnung", "es": "la advertencia"}, {"en": "die Folge", "es": "la consecuencia"}, {"en": "der Vorwurf", "es": "el reproche"}]}'::jsonb, '{"pairs": [["der Autor", "el autor"], ["die Maschine", "la máquina"], ["die Warnung", "la advertencia"], ["die Folge", "la consecuencia"], ["der Vorwurf", "el reproche"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='de' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '7c859148-5b95-5790-b4c9-17de7a1a5663', c.id, 'C1', 'reading', 'translation', 'Traduce al idioma que aprendes.', '{"source": "la condición"}'::jsonb, '{"value": "die Bedingung"}'::jsonb, 0.2, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='de' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '75317beb-74c6-5a22-a492-2dd863d0b1d8', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "die Absicht", "es": "la intención"}, {"en": "der Unfall", "es": "el accidente"}, {"en": "die Erinnerung", "es": "el recuerdo"}, {"en": "hervorheben", "es": "resaltar, destacar"}, {"en": "betonen", "es": "enfatizar, subrayar"}]}'::jsonb, '{"pairs": [["die Absicht", "la intención"], ["der Unfall", "el accidente"], ["die Erinnerung", "el recuerdo"], ["hervorheben", "resaltar, destacar"], ["betonen", "enfatizar, subrayar"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='de' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'bcf835f2-52d5-50d6-90bf-cdcb15f0f0f2', c.id, 'C1', 'reading', 'translation', 'Traduce al idioma que aprendes.', '{"source": "la reordenación (de palabras)"}'::jsonb, '{"value": "die Umstellung"}'::jsonb, 0.2, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='de' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '475322d7-028d-5f8d-a7c3-2fddb44b28cf', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "versterben", "es": "fallecer (culto)"}, {"en": "sich beeilen", "es": "darse prisa (neutral)"}, {"en": "einen Zahn zulegen", "es": "acelerar, apretar (coloquial)"}, {"en": "die Kohle", "es": "la pasta, el dinero (coloquial)"}, {"en": "das Vermögen", "es": "el patrimonio, la fortuna (culto)"}]}'::jsonb, '{"pairs": [["versterben", "fallecer (culto)"], ["sich beeilen", "darse prisa (neutral)"], ["einen Zahn zulegen", "acelerar, apretar (coloquial)"], ["die Kohle", "la pasta, el dinero (coloquial)"], ["das Vermögen", "el patrimonio, la fortuna (culto)"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='de' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'd6d25cea-975d-5698-82ad-5bbb03f8700d', c.id, 'C1', 'reading', 'translation', 'Traduce al idioma que aprendes.', '{"source": "el modismo, la locución"}'::jsonb, '{"value": "die Redewendung"}'::jsonb, 0.2, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='de' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'c52a99cf-0775-51c3-9c00-b36ba19e1e1a', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "will (behaupten)", "es": "(modal) afirma (de sí mismo, dudoso)"}, {"en": "soll (Gerücht)", "es": "(modal) se dice que, dizque"}, {"en": "die Vermutung", "es": "la suposición, la conjetura"}, {"en": "die indirekte Rede", "es": "el estilo indirecto"}, {"en": "angeblich", "es": "supuestamente, según dicen"}]}'::jsonb, '{"pairs": [["will (behaupten)", "(modal) afirma (de sí mismo, dudoso)"], ["soll (Gerücht)", "(modal) se dice que, dizque"], ["die Vermutung", "la suposición, la conjetura"], ["die indirekte Rede", "el estilo indirecto"], ["angeblich", "supuestamente, según dicen"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='de' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '17549c30-3912-5bc8-b4c0-3645c0e47830', c.id, 'C1', 'reading', 'translation', 'Traduce al idioma que aprendes.', '{"source": "presumiblemente"}'::jsonb, '{"value": "vermutlich"}'::jsonb, 0.2, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='de' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '476ec341-39f3-5d95-bd5a-78ac6a28c058', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "schmecken", "es": "saber (tener sabor)"}, {"en": "die Pressekonferenz", "es": "la rueda de prensa"}, {"en": "die Behauptung", "es": "la afirmación"}, {"en": "das Vorgangspassiv", "es": "la pasiva de proceso"}, {"en": "das Zustandspassiv", "es": "la pasiva de estado"}]}'::jsonb, '{"pairs": [["schmecken", "saber (tener sabor)"], ["die Pressekonferenz", "la rueda de prensa"], ["die Behauptung", "la afirmación"], ["das Vorgangspassiv", "la pasiva de proceso"], ["das Zustandspassiv", "la pasiva de estado"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='de' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'b6ec100f-485d-51aa-a149-984cd754989a', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "verabschieden", "es": "aprobar (una ley); despedirse"}, {"en": "angesichts", "es": "ante, en vista de (+ genitivo)"}, {"en": "gemäß", "es": "conforme a, según (+ dativo)"}, {"en": "die Anfrage", "es": "la consulta, la solicitud"}, {"en": "mit freundlichen Grüßen", "es": "atentamente (despedida formal)"}]}'::jsonb, '{"pairs": [["verabschieden", "aprobar (una ley); despedirse"], ["angesichts", "ante, en vista de (+ genitivo)"], ["gemäß", "conforme a, según (+ dativo)"], ["die Anfrage", "la consulta, la solicitud"], ["mit freundlichen Grüßen", "atentamente (despedida formal)"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='de' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '7f656036-042b-5186-b7ae-56678e031a2e', c.id, 'A1', 'reading', 'translation', 'Traduce al idioma que aprendes.', '{"source": "llamarse"}'::jsonb, '{"value": "heten"}'::jsonb, 0.2, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='nl' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '77adf6c1-8178-5050-b5cb-0a551befcda3', c.id, 'A1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "de ouders", "es": "los padres"}, {"en": "de familie", "es": "la familia"}, {"en": "het broertje", "es": "el hermanito"}]}'::jsonb, '{"pairs": [["de ouders", "los padres"], ["de familie", "la familia"], ["het broertje", "el hermanito"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='nl' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '5c0def68-cd11-5057-944c-87874710f1cf', c.id, 'A1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "Hoeveel kost het?", "es": "¿Cuánto cuesta?"}, {"en": "de euro", "es": "el euro"}]}'::jsonb, '{"pairs": [["Hoeveel kost het?", "¿Cuánto cuesta?"], ["de euro", "el euro"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='nl' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '63930fcb-d3af-5b79-b7b2-bd34b92f6cc0', c.id, 'A1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "dinsdag", "es": "martes"}, {"en": "donderdag", "es": "jueves"}, {"en": "zaterdag", "es": "sábado"}]}'::jsonb, '{"pairs": [["dinsdag", "martes"], ["donderdag", "jueves"], ["zaterdag", "sábado"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='nl' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '45528652-317a-5477-a383-502e1fc61a68', c.id, 'A2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "gespeeld", "es": "jugado"}, {"en": "aannemen", "es": "aprobar (una ley); suponer"}]}'::jsonb, '{"pairs": [["gespeeld", "jugado"], ["aannemen", "aprobar (una ley); suponer"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='nl' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'd58df095-ebd0-5860-96bf-ca63980fb784', c.id, 'A2', 'reading', 'translation', 'Traduce al idioma que aprendes.', '{"source": "el viaje"}'::jsonb, '{"value": "de reis"}'::jsonb, 0.2, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='nl' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '2c0b7f03-81b4-50cd-904c-4866cf013f83', c.id, 'A2', 'reading', 'translation', 'Traduce al idioma que aprendes.', '{"source": "el autobús"}'::jsonb, '{"value": "de bus"}'::jsonb, 0.2, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='nl' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '59952c9f-7b14-5627-9e20-ab147b6cb7e3', c.id, 'A2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "de markt", "es": "el mercado"}, {"en": "misschien", "es": "quizás"}]}'::jsonb, '{"pairs": [["de markt", "el mercado"], ["misschien", "quizás"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='nl' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'ce9ce520-2057-54e4-b9be-5f5fa5d536e3', c.id, 'A2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "serieus", "es": "serio"}, {"en": "bruin", "es": "castaño"}, {"en": "eruitzien", "es": "tener aspecto (de)"}]}'::jsonb, '{"pairs": [["serieus", "serio"], ["bruin", "castaño"], ["eruitzien", "tener aspecto (de)"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='nl' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'ffa006d3-7e29-5f02-9f8c-0f9e3fd5c424', c.id, 'A2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "de buik", "es": "la barriga"}, {"en": "de keel", "es": "la garganta"}, {"en": "het been", "es": "la pierna"}, {"en": "de arm", "es": "el brazo"}, {"en": "de tanden", "es": "los dientes"}]}'::jsonb, '{"pairs": [["de buik", "la barriga"], ["de keel", "la garganta"], ["het been", "la pierna"], ["de arm", "el brazo"], ["de tanden", "los dientes"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='nl' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'a11f6897-4a2c-53b6-bd27-f853dd8eff00', c.id, 'A2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "de hoofdpijn", "es": "el dolor de cabeza"}, {"en": "de koorts", "es": "la fiebre"}, {"en": "pijn doen", "es": "doler"}, {"en": "beleefd", "es": "cortés / educado"}, {"en": "vragen", "es": "preguntar / pedir"}]}'::jsonb, '{"pairs": [["de hoofdpijn", "el dolor de cabeza"], ["de koorts", "la fiebre"], ["pijn doen", "doler"], ["beleefd", "cortés / educado"], ["vragen", "preguntar / pedir"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='nl' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '3a5d81d0-b78e-5f68-a6ac-05d24300f813', c.id, 'B1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "de wens", "es": "el deseo"}, {"en": "de mogelijkheid", "es": "la posibilidad"}]}'::jsonb, '{"pairs": [["de wens", "el deseo"], ["de mogelijkheid", "la posibilidad"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='nl' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'dab8f69c-0dc4-5101-b501-b4bd6696e186', c.id, 'B1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "goedkoop", "es": "barato"}, {"en": "nadat", "es": "después de que"}, {"en": "daarom", "es": "por eso"}]}'::jsonb, '{"pairs": [["goedkoop", "barato"], ["nadat", "después de que"], ["daarom", "por eso"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='nl' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '93560ad3-95b8-52cd-b676-7b4fe38cc157', c.id, 'B1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "wonen", "es": "vivir (residir)"}, {"en": "de mening", "es": "la opinión"}, {"en": "de collega", "es": "el/la colega"}, {"en": "het gesprek", "es": "la conversación"}, {"en": "het antwoord", "es": "la respuesta"}]}'::jsonb, '{"pairs": [["wonen", "vivir (residir)"], ["de mening", "la opinión"], ["de collega", "el/la colega"], ["het gesprek", "la conversación"], ["het antwoord", "la respuesta"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='nl' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '703c3d63-890e-502d-955a-71abc803533b', c.id, 'B1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "de reden", "es": "la razón"}, {"en": "bang zijn voor", "es": "tener miedo de"}]}'::jsonb, '{"pairs": [["de reden", "la razón"], ["bang zijn voor", "tener miedo de"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='nl' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'e5d94edb-c07e-5e52-a3b4-78b9ba40ae90', c.id, 'B1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "zoeken naar", "es": "buscar"}, {"en": "de muziek", "es": "la música"}, {"en": "de spin", "es": "la araña"}, {"en": "de spijt", "es": "el arrepentimiento"}, {"en": "de kans", "es": "la ocasión / oportunidad"}]}'::jsonb, '{"pairs": [["zoeken naar", "buscar"], ["de muziek", "la música"], ["de spin", "la araña"], ["de spijt", "el arrepentimiento"], ["de kans", "la ocasión / oportunidad"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='nl' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '0b7f720d-18df-5d47-a6ad-043520566bed', c.id, 'B1', 'reading', 'translation', 'Traduce al idioma que aprendes.', '{"source": "la bajada / el descenso"}'::jsonb, '{"value": "de daling"}'::jsonb, 0.2, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='nl' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '3ab74633-644f-579c-93c6-441a4c8fb9a9', c.id, 'B1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "bouwen", "es": "construir"}, {"en": "bezorgen", "es": "entregar / repartir"}]}'::jsonb, '{"pairs": [["bouwen", "construir"], ["bezorgen", "entregar / repartir"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='nl' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '8317202a-98e6-5459-ba82-56a07d289f13', c.id, 'B1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "spelen", "es": "jugar"}, {"en": "kijken naar", "es": "mirar / ver"}, {"en": "houden van", "es": "gustar / querer"}, {"en": "bespreken", "es": "discutir / tratar"}, {"en": "afmaken", "es": "terminar"}]}'::jsonb, '{"pairs": [["spelen", "jugar"], ["kijken naar", "mirar / ver"], ["houden van", "gustar / querer"], ["bespreken", "discutir / tratar"], ["afmaken", "terminar"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='nl' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '2ed5c198-c074-5a1a-9cbd-95f0940f3111', c.id, 'B2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "het verleden", "es": "el pasado"}, {"en": "beweren", "es": "afirmar / sostener"}, {"en": "de bewering", "es": "la afirmación"}, {"en": "de bron", "es": "la fuente"}, {"en": "onlangs", "es": "recientemente"}]}'::jsonb, '{"pairs": [["het verleden", "el pasado"], ["beweren", "afirmar / sostener"], ["de bewering", "la afirmación"], ["de bron", "la fuente"], ["onlangs", "recientemente"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='nl' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'b31d18e8-2e54-5926-9fc4-92f99d939dd1', c.id, 'B2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "de mening", "es": "la opinión"}, {"en": "de verandering", "es": "el cambio"}, {"en": "de behandeling", "es": "el tratamiento"}]}'::jsonb, '{"pairs": [["de mening", "la opinión"], ["de verandering", "el cambio"], ["de behandeling", "el tratamiento"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='nl' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'e3931d04-8574-5654-986e-1ed31f9546d9', c.id, 'B2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "de monteur", "es": "el mecánico"}, {"en": "de wet", "es": "la ley"}]}'::jsonb, '{"pairs": [["de monteur", "el mecánico"], ["de wet", "la ley"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='nl' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '498ed45c-c446-5fde-a129-25da62f2d744', c.id, 'B2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "de slapende hond", "es": "el perro dormido"}, {"en": "de gebakken vis", "es": "el pescado frito"}, {"en": "de stromende regen", "es": "la lluvia torrencial"}, {"en": "een spelend kind", "es": "un niño que juega"}]}'::jsonb, '{"pairs": [["de slapende hond", "el perro dormido"], ["de gebakken vis", "el pescado frito"], ["de stromende regen", "la lluvia torrencial"], ["een spelend kind", "un niño que juega"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='nl' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '50faee29-1ea7-527e-88b4-7f4e2b0b73a1', c.id, 'B2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "de machine", "es": "la máquina"}, {"en": "de voorwaarde", "es": "la condición"}, {"en": "de herinnering", "es": "el recuerdo"}, {"en": "het ongeluk", "es": "el accidente"}, {"en": "de bedoeling", "es": "la intención"}]}'::jsonb, '{"pairs": [["de machine", "la máquina"], ["de voorwaarde", "la condición"], ["de herinnering", "el recuerdo"], ["het ongeluk", "el accidente"], ["de bedoeling", "la intención"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='nl' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'b8fa9b6d-f0c4-54fc-bd31-4a21421f335c', c.id, 'B2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "bovendien", "es": "además"}, {"en": "treffend", "es": "acertado, certero"}]}'::jsonb, '{"pairs": [["bovendien", "además"], ["treffend", "acertado, certero"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='nl' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'a726e15d-b221-599f-8e14-3b12a27fc70c', c.id, 'B2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "de mogelijkheid", "es": "la posibilidad"}, {"en": "het bericht", "es": "la noticia / el mensaje"}, {"en": "benadrukken", "es": "recalcar / subrayar"}, {"en": "de omstandigheid", "es": "la circunstancia"}, {"en": "de aanpak", "es": "el enfoque, el planteamiento"}]}'::jsonb, '{"pairs": [["de mogelijkheid", "la posibilidad"], ["het bericht", "la noticia / el mensaje"], ["benadrukken", "recalcar / subrayar"], ["de omstandigheid", "la circunstancia"], ["de aanpak", "el enfoque, el planteamiento"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='nl' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '7e30850b-ec3d-5190-a825-2a5752f3e368', c.id, 'B2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "indien", "es": "en caso de que, si (formal)"}, {"en": "wellicht", "es": "quizás, posiblemente (formal)"}, {"en": "de gelegenheid", "es": "la ocasión, la oportunidad"}, {"en": "het gedrag", "es": "el comportamiento"}]}'::jsonb, '{"pairs": [["indien", "en caso de que, si (formal)"], ["wellicht", "quizás, posiblemente (formal)"], ["de gelegenheid", "la ocasión, la oportunidad"], ["het gedrag", "el comportamiento"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='nl' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'b1e3d1ca-8c82-56da-a2f6-260e7c8b16bd', c.id, 'B2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "Het smaakt goed.", "es": "Está rico."}, {"en": "de spijt", "es": "el arrepentimiento"}, {"en": "het register", "es": "el registro (de lengua)"}, {"en": "formeel", "es": "formal"}, {"en": "informeel", "es": "informal"}]}'::jsonb, '{"pairs": [["Het smaakt goed.", "Está rico."], ["de spijt", "el arrepentimiento"], ["het register", "el registro (de lengua)"], ["formeel", "formal"], ["informeel", "informal"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='nl' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '0e676440-0cd4-52f2-852d-149509cf8117', c.id, 'B2', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "beleefd", "es": "cortés, educado"}, {"en": "de hypothese", "es": "la hipótesis"}, {"en": "destijds", "es": "en aquel entonces"}]}'::jsonb, '{"pairs": [["beleefd", "cortés, educado"], ["de hypothese", "la hipótesis"], ["destijds", "en aquel entonces"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='nl' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '42e190cd-1e79-5459-913f-69b4f90c9678', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "kritiek uiten", "es": "expresar/hacer crítica"}, {"en": "maatregelen treffen", "es": "tomar medidas"}, {"en": "de wagen", "es": "el coche (registro elevado)"}, {"en": "de kar", "es": "el coche (coloquial)"}, {"en": "formeel", "es": "formal (registro)"}]}'::jsonb, '{"pairs": [["kritiek uiten", "expresar/hacer crítica"], ["maatregelen treffen", "tomar medidas"], ["de wagen", "el coche (registro elevado)"], ["de kar", "el coche (coloquial)"], ["formeel", "formal (registro)"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='nl' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '137eb95f-80d6-55f6-a33a-c8ac6935e257', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "informeel", "es": "informal (registro)"}, {"en": "de connotatie", "es": "la connotación"}, {"en": "de nuance", "es": "el matiz"}]}'::jsonb, '{"pairs": [["informeel", "informal (registro)"], ["de connotatie", "la connotación"], ["de nuance", "el matiz"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='nl' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '88db1473-3f2d-5fc3-b25d-79be49ae9a62', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "de vakantie", "es": "las vacaciones"}, {"en": "ontkennen", "es": "negar"}, {"en": "de tegenstelling", "es": "el contraste, la oposición"}, {"en": "de conclusie", "es": "la conclusión"}]}'::jsonb, '{"pairs": [["de vakantie", "las vacaciones"], ["ontkennen", "negar"], ["de tegenstelling", "el contraste, la oposición"], ["de conclusie", "la conclusión"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='nl' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'f200acaf-b26e-5daa-a58f-8cc6cbda2fc9', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "de reden", "es": "la razón"}, {"en": "het toeval", "es": "la casualidad"}, {"en": "de waarschuwing", "es": "la advertencia"}, {"en": "het verwijt", "es": "el reproche"}, {"en": "benadrukken", "es": "enfatizar, subrayar"}]}'::jsonb, '{"pairs": [["de reden", "la razón"], ["het toeval", "la casualidad"], ["de waarschuwing", "la advertencia"], ["het verwijt", "el reproche"], ["benadrukken", "enfatizar, subrayar"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='nl' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '66448ffa-04e8-593e-829e-f468f966ed98', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "de nadruk", "es": "el énfasis, el acento"}, {"en": "vooropplaatsen", "es": "anteponer (al inicio)"}, {"en": "de tangconstructie", "es": "la construcción de paréntesis verbal"}, {"en": "opvallen", "es": "llamar la atención, destacar"}]}'::jsonb, '{"pairs": [["de nadruk", "el énfasis, el acento"], ["vooropplaatsen", "anteponer (al inicio)"], ["de tangconstructie", "la construcción de paréntesis verbal"], ["opvallen", "llamar la atención, destacar"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='nl' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '2bc3d5f2-1259-581c-8ba3-f71ab2aa2e02', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "ongetwijfeld", "es": "sin duda"}, {"en": "treffend", "es": "acertado, certero"}, {"en": "de blunder", "es": "la metedura de pata"}, {"en": "de conditionalis", "es": "el condicional (zou + inf.)"}, {"en": "irreëel", "es": "irreal, hipotético"}]}'::jsonb, '{"pairs": [["ongetwijfeld", "sin duda"], ["treffend", "acertado, certero"], ["de blunder", "la metedura de pata"], ["de conditionalis", "el condicional (zou + inf.)"], ["irreëel", "irreal, hipotético"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='nl' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'b6e8e1d7-3a58-591f-ac38-89f53fa5071a', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "schijnen", "es": "parecer; al parecer (schijnt te)"}, {"en": "blijken", "es": "resultar (ser), constatarse"}, {"en": "in twijfel trekken", "es": "poner en duda"}, {"en": "de lijdende vorm", "es": "la voz pasiva"}]}'::jsonb, '{"pairs": [["schijnen", "parecer; al parecer (schijnt te)"], ["blijken", "resultar (ser), constatarse"], ["in twijfel trekken", "poner en duda"], ["de lijdende vorm", "la voz pasiva"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='nl' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select 'e6c0af5a-db5a-590a-bdf4-00c269465137', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "treffend", "es": "acertado, certero"}, {"en": "de klemtoon", "es": "el acento (de intensidad)"}, {"en": "overlijden", "es": "fallecer (formal)"}, {"en": "het vermogen", "es": "el patrimonio, la fortuna (formal)"}, {"en": "de centen", "es": "la pasta, el dinero (coloquial)"}]}'::jsonb, '{"pairs": [["treffend", "acertado, certero"], ["de klemtoon", "el acento (de intensidad)"], ["overlijden", "fallecer (formal)"], ["het vermogen", "el patrimonio, la fortuna (formal)"], ["de centen", "la pasta, el dinero (coloquial)"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='nl' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '0057758d-4c37-513c-aaf0-1190f20347d0', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "schransen", "es": "zampar, comer con ansia (coloquial)"}, {"en": "de uitdrukking", "es": "el modismo, la expresión"}, {"en": "letterlijk", "es": "literal"}, {"en": "figuurlijk", "es": "figurado"}]}'::jsonb, '{"pairs": [["schransen", "zampar, comer con ansia (coloquial)"], ["de uitdrukking", "el modismo, la expresión"], ["letterlijk", "literal"], ["figuurlijk", "figurado"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='nl' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '3f2e3e61-6f9d-5006-bf41-d1475ae861a0', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "bouwen", "es": "construir"}, {"en": "naar verluidt", "es": "según se dice"}, {"en": "het vermoeden", "es": "la suposición, la sospecha"}, {"en": "de indirecte rede", "es": "el estilo indirecto"}, {"en": "zogenaamd", "es": "supuestamente"}]}'::jsonb, '{"pairs": [["bouwen", "construir"], ["naar verluidt", "según se dice"], ["het vermoeden", "la suposición, la sospecha"], ["de indirecte rede", "el estilo indirecto"], ["zogenaamd", "supuestamente"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='nl' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '60b74fbc-e953-5537-b5f0-3b8099e48779', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "vermoedelijk", "es": "presumiblemente"}, {"en": "de voorwaarde", "es": "la condición"}, {"en": "ware", "es": "fuera/sería (optativo formal de zijn)"}, {"en": "het verwijt", "es": "el reproche, la acusación"}, {"en": "ontkennen", "es": "negar, desmentir"}]}'::jsonb, '{"pairs": [["vermoedelijk", "presumiblemente"], ["de voorwaarde", "la condición"], ["ware", "fuera/sería (optativo formal de zijn)"], ["het verwijt", "el reproche, la acusación"], ["ontkennen", "negar, desmentir"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='nl' on conflict (id) do nothing;
insert into content_items(id,course_id,cefr_level,skill,type,prompt,payload,correct_answer,difficulty,tags) select '24901189-e29c-5522-8b78-cd4f00a428ea', c.id, 'C1', 'reading', 'match', 'Empareja cada palabra con su traducción.', '{"pairs": [{"en": "overeenkomstig", "es": "conforme a, según"}, {"en": "de aanvraag", "es": "la solicitud, la consulta"}, {"en": "hoogachtend", "es": "atentamente (despedida muy formal)"}, {"en": "geacht", "es": "estimado (tratamiento formal)"}]}'::jsonb, '{"pairs": [["overeenkomstig", "conforme a, según"], ["de aanvraag", "la solicitud, la consulta"], ["hoogachtend", "atentamente (despedida muy formal)"], ["geacht", "estimado (tratamiento formal)"]]}'::jsonb, 0.15, array['repaso_vocab','reading'] from courses c join languages l on l.id=c.target_language_id where l.code='nl' on conflict (id) do nothing;

-- 2) lecciones de repaso + lesson_items (DO-block por unidad: desplaza el
--    checkpoint para insertar la lección en la ruta; el desbloqueo del
--    checkpoint es por type+unit, no por order_index → gating intacto).
do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='d83b1d76-3bbc-5771-98af-9e01c735a86f') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='en' and u.order_index=2;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('d83b1d76-3bbc-5771-98af-9e01c735a86f', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('d83b1d76-3bbc-5771-98af-9e01c735a86f', '8110c4a6-5d25-5cab-aeee-3917e7d0e2cc', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='9995df5e-c5ab-5c45-b00b-0e777439d109') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='en' and u.order_index=4;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('9995df5e-c5ab-5c45-b00b-0e777439d109', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('9995df5e-c5ab-5c45-b00b-0e777439d109', 'd064f7ef-916b-5fb4-b079-1b18cfa0d130', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='c3c4dabb-4256-5c86-aa84-e5adc600e627') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='en' and u.order_index=8;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('c3c4dabb-4256-5c86-aa84-e5adc600e627', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('c3c4dabb-4256-5c86-aa84-e5adc600e627', '6eb77625-807e-541e-9778-db411d2439c8', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='cbda61d1-1547-5767-ba32-812f73047d6f') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='en' and u.order_index=10;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('cbda61d1-1547-5767-ba32-812f73047d6f', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('cbda61d1-1547-5767-ba32-812f73047d6f', '1e4daa15-c27c-5c7d-a28e-61e8f5e7ed50', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='f5db41ab-d29c-5145-a2f8-c0b0941c330f') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='en' and u.order_index=11;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('f5db41ab-d29c-5145-a2f8-c0b0941c330f', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('f5db41ab-d29c-5145-a2f8-c0b0941c330f', 'f938bed3-a54d-59dd-a3aa-5d66fa95111c', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='a9f40954-6546-5f72-ad5f-612cf2ede00d') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='en' and u.order_index=12;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('a9f40954-6546-5f72-ad5f-612cf2ede00d', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('a9f40954-6546-5f72-ad5f-612cf2ede00d', '125fb1c0-99bd-5591-ad7f-fa1d94a34ea6', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='2607467c-3c04-51a8-9eaf-c2fc06b44e10') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='en' and u.order_index=13;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('2607467c-3c04-51a8-9eaf-c2fc06b44e10', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('2607467c-3c04-51a8-9eaf-c2fc06b44e10', 'c3e735dc-a235-5ad3-a762-fcf58c3b50ce', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='2cb11e75-8e1f-51ba-85ef-1762381b6085') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='en' and u.order_index=14;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('2cb11e75-8e1f-51ba-85ef-1762381b6085', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('2cb11e75-8e1f-51ba-85ef-1762381b6085', '3e72a278-055a-520a-a49b-ffaf97ac6042', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='ce219a2c-d012-5f3f-96f1-eea126b5e123') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='en' and u.order_index=15;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('ce219a2c-d012-5f3f-96f1-eea126b5e123', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('ce219a2c-d012-5f3f-96f1-eea126b5e123', '3999ad75-7c28-5f01-9119-4ae86bb8d3e4', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('ce219a2c-d012-5f3f-96f1-eea126b5e123', '79355205-5669-558a-817c-937bf9249f2c', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='2b7be85d-8f35-5113-916e-232a95170428') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='en' and u.order_index=16;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('2b7be85d-8f35-5113-916e-232a95170428', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('2b7be85d-8f35-5113-916e-232a95170428', '5dfcdbd0-c9cc-5cce-9fb8-8fd5fec8291e', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='60e16922-9859-504c-b848-ed3629fbe55c') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='en' and u.order_index=17;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('60e16922-9859-504c-b848-ed3629fbe55c', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('60e16922-9859-504c-b848-ed3629fbe55c', '56d221ee-5982-53f9-ac9f-fc315194b5a4', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='01d7c7a7-9321-5574-b0bf-88a344364ec6') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='en' and u.order_index=18;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('01d7c7a7-9321-5574-b0bf-88a344364ec6', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('01d7c7a7-9321-5574-b0bf-88a344364ec6', '6a1946eb-7ac9-511b-a75d-6ecbff933479', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='9bc662dc-ed68-5781-978a-caa6a2c0be0c') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='en' and u.order_index=19;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('9bc662dc-ed68-5781-978a-caa6a2c0be0c', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('9bc662dc-ed68-5781-978a-caa6a2c0be0c', '9eb38958-d44e-5fe9-83b0-833493d91165', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='5dfe6e53-4abf-5ed1-9918-d435c0b87e3d') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='en' and u.order_index=20;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('5dfe6e53-4abf-5ed1-9918-d435c0b87e3d', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('5dfe6e53-4abf-5ed1-9918-d435c0b87e3d', '7bfdf5d8-d881-5172-b819-6c40fead63f6', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='3854be7f-971b-5c57-a5ee-1c9bf11a78a9') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='en' and u.order_index=21;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('3854be7f-971b-5c57-a5ee-1c9bf11a78a9', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('3854be7f-971b-5c57-a5ee-1c9bf11a78a9', '4edf50cc-9a8f-5ce9-b9df-b10f17dc0a14', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='7d42c3a6-3204-51d2-9dce-42afd298469d') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='en' and u.order_index=22;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('7d42c3a6-3204-51d2-9dce-42afd298469d', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('7d42c3a6-3204-51d2-9dce-42afd298469d', 'ed404876-ea73-5da7-b3ce-71d3dcd8c195', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='e7f4a169-3c00-5b3e-b754-3c86d55212db') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='en' and u.order_index=24;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('e7f4a169-3c00-5b3e-b754-3c86d55212db', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('e7f4a169-3c00-5b3e-b754-3c86d55212db', 'be338ba2-2b30-54ab-801b-f1ccfd0f485e', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='8154fd59-7a68-576a-b96c-cc755479026d') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='en' and u.order_index=25;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('8154fd59-7a68-576a-b96c-cc755479026d', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('8154fd59-7a68-576a-b96c-cc755479026d', 'e0cf6c18-0245-5b2c-9595-49a35881d3f0', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='42ba1263-eb6d-5142-9b82-6a97bdcd2744') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='en' and u.order_index=27;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('42ba1263-eb6d-5142-9b82-6a97bdcd2744', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('42ba1263-eb6d-5142-9b82-6a97bdcd2744', 'a1b3c83c-c740-5f05-9ed0-d49510e64a1c', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('42ba1263-eb6d-5142-9b82-6a97bdcd2744', '7ceedf09-f13d-5fbd-898e-dbfe7641e1cd', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='4725bcb4-15c0-5070-b61c-14d164d4c4e5') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='en' and u.order_index=28;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('4725bcb4-15c0-5070-b61c-14d164d4c4e5', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('4725bcb4-15c0-5070-b61c-14d164d4c4e5', '23a7cc81-b3c2-51e3-aad5-ce9f05a1533a', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='64c1fea3-4e3a-5aaa-936e-5bbb4abc2fce') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='en' and u.order_index=29;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('64c1fea3-4e3a-5aaa-936e-5bbb4abc2fce', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('64c1fea3-4e3a-5aaa-936e-5bbb4abc2fce', 'a0708e60-5057-581f-bdc5-bf41248f2d74', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='03e60c4b-930e-5897-8c9d-bfe743ac6578') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='en' and u.order_index=30;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('03e60c4b-930e-5897-8c9d-bfe743ac6578', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('03e60c4b-930e-5897-8c9d-bfe743ac6578', 'f1c5cd1e-7b33-5f06-b072-a592aba83638', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='d4a111bd-1727-59e9-a2ea-6d886ec41526') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='pt' and u.order_index=2;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('d4a111bd-1727-59e9-a2ea-6d886ec41526', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('d4a111bd-1727-59e9-a2ea-6d886ec41526', 'f6b30046-54d7-599e-aa1a-147884fb52cb', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='55c52b7a-7ef4-53b3-ad69-2f7482343e5b') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='pt' and u.order_index=3;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('55c52b7a-7ef4-53b3-ad69-2f7482343e5b', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('55c52b7a-7ef4-53b3-ad69-2f7482343e5b', '58a89f2b-fdf6-5b47-aa06-22b763a65e59', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='c5a2221e-4b6d-54f9-b02b-6bb33696f0ad') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='pt' and u.order_index=4;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('c5a2221e-4b6d-54f9-b02b-6bb33696f0ad', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('c5a2221e-4b6d-54f9-b02b-6bb33696f0ad', 'f30fcc73-38fc-5f6f-a844-eed311d431b9', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='874b1b76-730e-50bb-b7fa-298c7c9ed9a5') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='pt' and u.order_index=5;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('874b1b76-730e-50bb-b7fa-298c7c9ed9a5', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('874b1b76-730e-50bb-b7fa-298c7c9ed9a5', 'ab623124-2595-5f91-b423-aebf137f379f', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='7555b639-94f5-5812-af8a-579aba92e56c') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='pt' and u.order_index=6;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('7555b639-94f5-5812-af8a-579aba92e56c', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('7555b639-94f5-5812-af8a-579aba92e56c', 'bced85ed-49e4-554a-a097-e1f7ecb51873', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='bd1e33c1-ff0e-5d04-beb4-300e7b03f5f3') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='pt' and u.order_index=7;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('bd1e33c1-ff0e-5d04-beb4-300e7b03f5f3', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('bd1e33c1-ff0e-5d04-beb4-300e7b03f5f3', 'd8ef8f15-d173-542a-92a6-7bab1c8ca989', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='3ae00801-4114-5ad0-964d-dadc21d560a1') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='pt' and u.order_index=8;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('3ae00801-4114-5ad0-964d-dadc21d560a1', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('3ae00801-4114-5ad0-964d-dadc21d560a1', 'f3edabf3-4c60-56c0-85e3-aa3a075bf5c6', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='6b8911a2-db44-5c9d-806a-3549eaef4ac1') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='pt' and u.order_index=9;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('6b8911a2-db44-5c9d-806a-3549eaef4ac1', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('6b8911a2-db44-5c9d-806a-3549eaef4ac1', 'eb7f1981-8dad-54b1-95eb-6d15b5bb2d85', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='11504ab3-adbe-52ad-a59d-a0292182247b') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='pt' and u.order_index=10;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('11504ab3-adbe-52ad-a59d-a0292182247b', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('11504ab3-adbe-52ad-a59d-a0292182247b', '73f38158-e347-55cb-a8c2-5766b3ffcdcf', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='60ea8d96-0c03-5c74-9ce2-09a4aac9f6d6') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='pt' and u.order_index=11;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('60ea8d96-0c03-5c74-9ce2-09a4aac9f6d6', v_unit, v_c+0, 'Repaso de vocabulario 1', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('60ea8d96-0c03-5c74-9ce2-09a4aac9f6d6', '68a8eefc-45f8-596e-90d8-c00002f8da3d', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('60ea8d96-0c03-5c74-9ce2-09a4aac9f6d6', '6d900685-7c4d-5432-843c-e0a5a362b37e', 1) on conflict do nothing;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('dcdc8707-eac0-57cd-b863-250dc0ab1811', v_unit, v_c+1, 'Repaso de vocabulario 2', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('dcdc8707-eac0-57cd-b863-250dc0ab1811', 'ac8027b1-ce33-56d6-89b3-0ed912ef39ac', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+2 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='40307b1e-5145-518b-9aeb-0fe1ed5035d5') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='pt' and u.order_index=12;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('40307b1e-5145-518b-9aeb-0fe1ed5035d5', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('40307b1e-5145-518b-9aeb-0fe1ed5035d5', 'dacb23f2-4765-5987-bee5-245497228bda', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='89d579d0-b40f-5a25-89b7-a68ee483f52f') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='pt' and u.order_index=13;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('89d579d0-b40f-5a25-89b7-a68ee483f52f', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('89d579d0-b40f-5a25-89b7-a68ee483f52f', 'f6fbed7d-4705-5122-a5aa-4e61694c387b', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='fc779feb-858d-5398-836f-76230a9a3456') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='pt' and u.order_index=15;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('fc779feb-858d-5398-836f-76230a9a3456', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('fc779feb-858d-5398-836f-76230a9a3456', '15089d95-869a-539b-9f4b-eecaaf909d18', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='77502efb-15ae-5f82-acb6-88b941ee0735') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='pt' and u.order_index=16;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('77502efb-15ae-5f82-acb6-88b941ee0735', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('77502efb-15ae-5f82-acb6-88b941ee0735', '757ac397-af88-5d38-a691-20179df50765', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('77502efb-15ae-5f82-acb6-88b941ee0735', 'bfb18d16-4139-568f-a8b0-a123995aba17', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='a54773c6-9efd-50ff-af50-5f7b53ecf172') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='pt' and u.order_index=17;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('a54773c6-9efd-50ff-af50-5f7b53ecf172', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('a54773c6-9efd-50ff-af50-5f7b53ecf172', 'c54ca22f-8347-5948-abe5-f39ae45ab518', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='65cbd1fe-dcb2-5cda-8d3d-46847041dd63') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='pt' and u.order_index=18;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('65cbd1fe-dcb2-5cda-8d3d-46847041dd63', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('65cbd1fe-dcb2-5cda-8d3d-46847041dd63', 'd2834d58-7ce1-5a27-be83-6c3e16b99a5a', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('65cbd1fe-dcb2-5cda-8d3d-46847041dd63', '0be70dec-e018-5999-b9da-85a9c7d3c7d8', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='dbab3f3c-e7d5-5d0c-99bf-d91104e2c25c') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='pt' and u.order_index=19;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('dbab3f3c-e7d5-5d0c-99bf-d91104e2c25c', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('dbab3f3c-e7d5-5d0c-99bf-d91104e2c25c', '91a9466a-84cd-56e2-91ff-a400a4b3f3ab', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='d7ad1b38-10a0-50ae-8eee-47ae5b6b3dcb') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='pt' and u.order_index=20;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('d7ad1b38-10a0-50ae-8eee-47ae5b6b3dcb', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('d7ad1b38-10a0-50ae-8eee-47ae5b6b3dcb', '7866c397-2c6b-5642-8e13-f1cf9cbc21fa', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='c4a1afac-18a5-5e48-8a07-f404d6c99d15') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='pt' and u.order_index=21;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('c4a1afac-18a5-5e48-8a07-f404d6c99d15', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('c4a1afac-18a5-5e48-8a07-f404d6c99d15', '5df5ab0d-92b0-5af7-ad3c-2c2da8fd41bf', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('c4a1afac-18a5-5e48-8a07-f404d6c99d15', '8990f417-382f-5a50-841f-b4310a969fc8', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='e15b7075-4ae7-5b7e-a572-f19ddfb3378b') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='pt' and u.order_index=24;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('e15b7075-4ae7-5b7e-a572-f19ddfb3378b', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('e15b7075-4ae7-5b7e-a572-f19ddfb3378b', '566c9271-72f0-502b-8179-f2ecfc220f89', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='c69058d9-8e73-5a5c-be33-c1946664c4e8') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='pt' and u.order_index=25;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('c69058d9-8e73-5a5c-be33-c1946664c4e8', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('c69058d9-8e73-5a5c-be33-c1946664c4e8', '5e0f50fd-8733-523e-ad70-90ce61a03f92', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('c69058d9-8e73-5a5c-be33-c1946664c4e8', '74102013-35f7-583b-9a4f-94a158d98ed6', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='706acfa0-b81b-5a07-9af5-4f2a155b07dd') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='pt' and u.order_index=26;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('706acfa0-b81b-5a07-9af5-4f2a155b07dd', v_unit, v_c+0, 'Repaso de vocabulario 1', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('706acfa0-b81b-5a07-9af5-4f2a155b07dd', 'd14a0e6a-e68d-5178-9507-24cfef32504b', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('706acfa0-b81b-5a07-9af5-4f2a155b07dd', '78d77378-f589-59b1-9ea0-2a680f4ca97f', 1) on conflict do nothing;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('56fd809b-2679-5985-b363-7657c57cf21f', v_unit, v_c+1, 'Repaso de vocabulario 2', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('56fd809b-2679-5985-b363-7657c57cf21f', '6d3d9156-eeae-5c66-a79e-9bbe2a812000', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('56fd809b-2679-5985-b363-7657c57cf21f', '79667c6f-5a00-5169-8ffa-0c8eca5a8ecb', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+2 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='0fd00af8-bf32-5414-8fb6-34375ba5d600') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='pt' and u.order_index=27;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('0fd00af8-bf32-5414-8fb6-34375ba5d600', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('0fd00af8-bf32-5414-8fb6-34375ba5d600', '071651ff-9343-57a7-8f49-57b4ca19cf52', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='fed6ab53-d55a-5348-a0cf-7129c089ec85') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='pt' and u.order_index=28;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('fed6ab53-d55a-5348-a0cf-7129c089ec85', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('fed6ab53-d55a-5348-a0cf-7129c089ec85', 'bc49bf28-0e1b-5937-8fb8-6804dddadde5', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('fed6ab53-d55a-5348-a0cf-7129c089ec85', 'e74bd648-90ac-5a82-82a3-ebaf76bb5b4c', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='70cb0d1b-b363-5cd0-af95-0b2756b5da12') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='pt' and u.order_index=29;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('70cb0d1b-b363-5cd0-af95-0b2756b5da12', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('70cb0d1b-b363-5cd0-af95-0b2756b5da12', '4dae7869-4970-5ca2-9403-ab0b9cdbbf7d', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='f708c807-b8b9-533f-a637-c8b70577e9dd') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='pt' and u.order_index=30;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('f708c807-b8b9-533f-a637-c8b70577e9dd', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('f708c807-b8b9-533f-a637-c8b70577e9dd', '1ff32531-bcb2-5e45-975e-0f1ea1450a48', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('f708c807-b8b9-533f-a637-c8b70577e9dd', '5364fdb4-d4f7-5156-8880-4bbee02a5944', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='9c4e5b18-7d63-5f03-980e-c2f8fafcbe89') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='fr' and u.order_index=2;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('9c4e5b18-7d63-5f03-980e-c2f8fafcbe89', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('9c4e5b18-7d63-5f03-980e-c2f8fafcbe89', 'ac68b0c7-d274-5f28-b625-6d8fcb2c63f1', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='fb72df11-6307-5760-8009-d675151bcdab') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='fr' and u.order_index=3;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('fb72df11-6307-5760-8009-d675151bcdab', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('fb72df11-6307-5760-8009-d675151bcdab', '04d6cf6c-b180-5e00-a18a-4e231c2f40fc', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='1be4b3b5-e532-5f12-9689-befa38b5eea4') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='fr' and u.order_index=4;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('1be4b3b5-e532-5f12-9689-befa38b5eea4', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('1be4b3b5-e532-5f12-9689-befa38b5eea4', '61f3377d-ac47-5b94-9946-2c709535facf', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='b3fb428d-a9c6-5e85-bda0-74385f4aceb5') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='fr' and u.order_index=5;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('b3fb428d-a9c6-5e85-bda0-74385f4aceb5', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('b3fb428d-a9c6-5e85-bda0-74385f4aceb5', 'ddaa7a1a-64ff-53b9-80d6-9da57d059c2e', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='40e163df-69f6-58ad-9982-ced801e91051') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='fr' and u.order_index=6;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('40e163df-69f6-58ad-9982-ced801e91051', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('40e163df-69f6-58ad-9982-ced801e91051', '91822af2-23f2-5fbf-9fd1-37cdda9b6a73', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='d45fc60d-bc44-546f-ba43-c9fde4bc82a9') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='fr' and u.order_index=7;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('d45fc60d-bc44-546f-ba43-c9fde4bc82a9', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('d45fc60d-bc44-546f-ba43-c9fde4bc82a9', 'b253e4a5-f324-5abd-ab24-4b18165fbcca', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='fb42a4bb-aab1-5dcd-8773-bb033d855d4d') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='fr' and u.order_index=8;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('fb42a4bb-aab1-5dcd-8773-bb033d855d4d', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('fb42a4bb-aab1-5dcd-8773-bb033d855d4d', 'fc5fec57-5460-5609-9bed-8387a31e89c4', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('fb42a4bb-aab1-5dcd-8773-bb033d855d4d', '61853bf0-b3b6-5327-b626-a2cf0aa1aea7', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='e96cd467-29a3-5564-a1df-3ed49a090eef') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='fr' and u.order_index=9;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('e96cd467-29a3-5564-a1df-3ed49a090eef', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('e96cd467-29a3-5564-a1df-3ed49a090eef', '82e9f340-820e-5479-994a-b8f787924ce7', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='5005fb8d-9128-54c0-a8f3-177316f477a1') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='fr' and u.order_index=10;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('5005fb8d-9128-54c0-a8f3-177316f477a1', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('5005fb8d-9128-54c0-a8f3-177316f477a1', '3eb33e2c-9e38-5ba5-ad1b-dd99e92146dc', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='adb1b69f-a6a9-5bd7-8200-bdd5dd715a08') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='fr' and u.order_index=11;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('adb1b69f-a6a9-5bd7-8200-bdd5dd715a08', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('adb1b69f-a6a9-5bd7-8200-bdd5dd715a08', 'b6521805-4274-5b85-aa22-96ddcc9f42de', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='6134440f-6f78-5ecb-8fdb-7ca8126930d0') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='fr' and u.order_index=12;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('6134440f-6f78-5ecb-8fdb-7ca8126930d0', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('6134440f-6f78-5ecb-8fdb-7ca8126930d0', '6b537c32-8d0d-5736-bc23-5d7b8483fb82', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('6134440f-6f78-5ecb-8fdb-7ca8126930d0', '3c49f3c9-09d1-5f70-b655-8aad42d7a877', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='1aa7a306-1d3d-55e7-8e49-162c0e4fd97f') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='fr' and u.order_index=13;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('1aa7a306-1d3d-55e7-8e49-162c0e4fd97f', v_unit, v_c+0, 'Repaso de vocabulario 1', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('1aa7a306-1d3d-55e7-8e49-162c0e4fd97f', '4a2987ba-b91b-575d-9b11-5a93b754f11f', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('1aa7a306-1d3d-55e7-8e49-162c0e4fd97f', '01fc37ab-954f-5f49-991b-2d63fd8dead7', 1) on conflict do nothing;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('fd478373-9b83-5972-aa36-d6955712ac0f', v_unit, v_c+1, 'Repaso de vocabulario 2', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('fd478373-9b83-5972-aa36-d6955712ac0f', '2119bf18-c78c-5cfd-8226-aadbd34275ff', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+2 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='faa85cc1-2a13-5a13-8cbc-56c680bd3aee') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='fr' and u.order_index=14;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('faa85cc1-2a13-5a13-8cbc-56c680bd3aee', v_unit, v_c+0, 'Repaso de vocabulario 1', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('faa85cc1-2a13-5a13-8cbc-56c680bd3aee', '60c75d82-3a57-5584-ab6e-8ebf4b42cd5d', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('faa85cc1-2a13-5a13-8cbc-56c680bd3aee', 'faa18e4e-1e86-52d3-bcf7-074f04523829', 1) on conflict do nothing;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('ea6c8b99-5030-52f8-9cf5-2e61d19880e1', v_unit, v_c+1, 'Repaso de vocabulario 2', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('ea6c8b99-5030-52f8-9cf5-2e61d19880e1', '1d79184d-1ba4-5706-bab3-cc3b47283c45', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('ea6c8b99-5030-52f8-9cf5-2e61d19880e1', '3e4456b1-036f-5ddc-9486-8383746f77ba', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+2 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='ac7c00ae-3be9-5dfe-bccb-af300d5d71a7') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='fr' and u.order_index=15;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('ac7c00ae-3be9-5dfe-bccb-af300d5d71a7', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('ac7c00ae-3be9-5dfe-bccb-af300d5d71a7', 'e80f2729-b370-519a-8c53-c2061d0c6b5b', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('ac7c00ae-3be9-5dfe-bccb-af300d5d71a7', '65c247ed-2cc6-58c5-99fc-6184ffabaaa7', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='d83e3c38-2c2c-5139-85f9-7f8ae80a8093') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='fr' and u.order_index=16;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('d83e3c38-2c2c-5139-85f9-7f8ae80a8093', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('d83e3c38-2c2c-5139-85f9-7f8ae80a8093', 'd73486fe-e1ff-59ea-ae9b-1782f9ad1fb5', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='e0c2b13a-80d0-5949-b2ad-b20817056ff0') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='fr' and u.order_index=17;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('e0c2b13a-80d0-5949-b2ad-b20817056ff0', v_unit, v_c+0, 'Repaso de vocabulario 1', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('e0c2b13a-80d0-5949-b2ad-b20817056ff0', '9611d306-f9ba-59c7-89d9-ee60fb591aef', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('e0c2b13a-80d0-5949-b2ad-b20817056ff0', '1968bf45-ab26-57af-93d5-38bcb5a75c9a', 1) on conflict do nothing;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('f13ad20e-e2aa-501f-859f-6950cfc63e7e', v_unit, v_c+1, 'Repaso de vocabulario 2', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('f13ad20e-e2aa-501f-859f-6950cfc63e7e', 'd3a44e0b-b303-564a-b52e-313649837e55', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('f13ad20e-e2aa-501f-859f-6950cfc63e7e', 'ddbad9fb-5568-5619-82da-12ddd1740c0d', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+2 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='4576d7d6-3a2c-5d85-a3c3-d71dfb48c792') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='fr' and u.order_index=18;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('4576d7d6-3a2c-5d85-a3c3-d71dfb48c792', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('4576d7d6-3a2c-5d85-a3c3-d71dfb48c792', '5a140da7-c73d-5da7-94d5-c657fe6d1fcf', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='4a6be355-0160-5167-8cb8-92b283bf7930') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='fr' and u.order_index=19;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('4a6be355-0160-5167-8cb8-92b283bf7930', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('4a6be355-0160-5167-8cb8-92b283bf7930', '68009ad4-1436-5157-9f68-3358f82c5570', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='251baa1e-bd21-5845-b0a9-ec31e8df531c') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='fr' and u.order_index=20;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('251baa1e-bd21-5845-b0a9-ec31e8df531c', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('251baa1e-bd21-5845-b0a9-ec31e8df531c', 'dc73f938-3e4d-5538-bd9a-41ea8af4af89', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('251baa1e-bd21-5845-b0a9-ec31e8df531c', 'd5dac914-bb15-5104-b005-c190c140bedb', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='ac368efa-b11b-51ba-830e-f5dfa203e9a7') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='fr' and u.order_index=21;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('ac368efa-b11b-51ba-830e-f5dfa203e9a7', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('ac368efa-b11b-51ba-830e-f5dfa203e9a7', '0bf7bad8-01e4-5947-acf4-43042b3f2959', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='e531eb90-d7e1-5ae4-b445-5903b5a6a38c') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='fr' and u.order_index=22;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('e531eb90-d7e1-5ae4-b445-5903b5a6a38c', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('e531eb90-d7e1-5ae4-b445-5903b5a6a38c', '972e47bc-8e08-501d-a42c-442a10e55128', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='8b31f903-0ac9-5255-aad3-ce9e121cc89c') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='fr' and u.order_index=23;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('8b31f903-0ac9-5255-aad3-ce9e121cc89c', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('8b31f903-0ac9-5255-aad3-ce9e121cc89c', '724fa884-29e1-58f8-a5a3-8a75a0e5ebb8', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('8b31f903-0ac9-5255-aad3-ce9e121cc89c', 'ae59fa0e-f050-5094-95b1-ca9adb8dc3c4', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='243015fc-3f7c-5e7e-af93-88055794d348') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='fr' and u.order_index=24;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('243015fc-3f7c-5e7e-af93-88055794d348', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('243015fc-3f7c-5e7e-af93-88055794d348', 'b195d821-7a90-5689-989d-02f74eaffd68', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('243015fc-3f7c-5e7e-af93-88055794d348', '92e4a01d-736c-5209-8c7d-61bd1737597c', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='94572bcd-970e-5826-a439-6676f049aca7') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='fr' and u.order_index=25;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('94572bcd-970e-5826-a439-6676f049aca7', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('94572bcd-970e-5826-a439-6676f049aca7', 'd798dbfe-bad2-5d6e-908c-6ed5d6385653', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('94572bcd-970e-5826-a439-6676f049aca7', '7096236d-b28b-52a1-bb0d-e0ddd9f65aaa', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='14fc63b7-7a72-5671-ab0f-3d0397c1b477') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='fr' and u.order_index=26;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('14fc63b7-7a72-5671-ab0f-3d0397c1b477', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('14fc63b7-7a72-5671-ab0f-3d0397c1b477', 'bd52215a-8d02-518e-887a-62f017d5f68a', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('14fc63b7-7a72-5671-ab0f-3d0397c1b477', '4b52049b-4ec1-5138-8087-05a5d90f96b5', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='ed7f160a-5b67-52dd-b90f-3187a6ad34c6') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='fr' and u.order_index=27;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('ed7f160a-5b67-52dd-b90f-3187a6ad34c6', v_unit, v_c+0, 'Repaso de vocabulario 1', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('ed7f160a-5b67-52dd-b90f-3187a6ad34c6', 'caed8ca3-044e-5d19-b383-08e49f7e4d36', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('ed7f160a-5b67-52dd-b90f-3187a6ad34c6', 'cf0b6aeb-4c9c-5752-8aa8-508dbe7b133a', 1) on conflict do nothing;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('58b5cef3-a469-593b-82ee-8b7a812e241a', v_unit, v_c+1, 'Repaso de vocabulario 2', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('58b5cef3-a469-593b-82ee-8b7a812e241a', 'ceb5a116-bcdd-5e05-8e49-92868d7786d9', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('58b5cef3-a469-593b-82ee-8b7a812e241a', '6b2d5217-5ded-5b1b-a3ac-9abf55403d9a', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+2 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='87b67394-c506-58d9-9816-16cb79f48e35') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='fr' and u.order_index=28;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('87b67394-c506-58d9-9816-16cb79f48e35', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('87b67394-c506-58d9-9816-16cb79f48e35', '76bf583f-9904-511c-80bc-851713190f97', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('87b67394-c506-58d9-9816-16cb79f48e35', 'ba81f038-755b-5afb-a202-a92a06570604', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='9b51f86f-2756-5e65-809d-877808b361bf') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='fr' and u.order_index=29;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('9b51f86f-2756-5e65-809d-877808b361bf', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('9b51f86f-2756-5e65-809d-877808b361bf', '24210bb7-6584-54a9-bad4-b07eb0dd4cf6', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('9b51f86f-2756-5e65-809d-877808b361bf', '6a1828f3-c1de-5a62-8e33-bc74c36c6058', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='389cfe2f-0ea9-578a-a3f6-98dfdd1dec0b') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='fr' and u.order_index=30;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('389cfe2f-0ea9-578a-a3f6-98dfdd1dec0b', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('389cfe2f-0ea9-578a-a3f6-98dfdd1dec0b', '2a92d3a9-f734-512d-bfcd-81f6df9d3975', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('389cfe2f-0ea9-578a-a3f6-98dfdd1dec0b', 'ab3724f6-b5b0-5c0c-8e5d-0bb9d5d94f4b', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='db048de3-a4e6-5227-b593-05e8338c9c54') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='it' and u.order_index=2;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('db048de3-a4e6-5227-b593-05e8338c9c54', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('db048de3-a4e6-5227-b593-05e8338c9c54', 'fbe56176-d026-545f-94de-7d324fc73616', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('db048de3-a4e6-5227-b593-05e8338c9c54', '09205d1c-1e68-5623-bf85-bb7fcce6e154', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='f96178f0-e9c1-5cee-9803-ac9fa3456b5b') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='it' and u.order_index=3;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('f96178f0-e9c1-5cee-9803-ac9fa3456b5b', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('f96178f0-e9c1-5cee-9803-ac9fa3456b5b', '880717fb-d05c-5a04-8273-af0f2c703a54', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='b772506e-16ed-5d7f-8197-f2be55b32f5e') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='it' and u.order_index=4;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('b772506e-16ed-5d7f-8197-f2be55b32f5e', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('b772506e-16ed-5d7f-8197-f2be55b32f5e', '5f90ae1e-f817-5307-b30a-b8d8f90c6d40', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='35b5da76-dc96-5887-8a5c-c37f20379b1d') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='it' and u.order_index=5;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('35b5da76-dc96-5887-8a5c-c37f20379b1d', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('35b5da76-dc96-5887-8a5c-c37f20379b1d', '9312704b-9584-5f3e-93d4-055b44c948bb', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='e706c4a5-e7d6-5b4c-9a89-16825a912d85') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='it' and u.order_index=6;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('e706c4a5-e7d6-5b4c-9a89-16825a912d85', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('e706c4a5-e7d6-5b4c-9a89-16825a912d85', '1517d733-2e30-5aad-909a-325b2038f369', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='3b2232e5-2005-579c-8fc1-7e965743fe47') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='it' and u.order_index=7;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('3b2232e5-2005-579c-8fc1-7e965743fe47', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('3b2232e5-2005-579c-8fc1-7e965743fe47', '9d2162c3-f04d-50db-9601-6af11fc8a5f6', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='def569a9-e4e6-56d0-b43a-20da81028022') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='it' and u.order_index=8;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('def569a9-e4e6-56d0-b43a-20da81028022', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('def569a9-e4e6-56d0-b43a-20da81028022', '98b69a3c-e70f-537d-841c-7305cf4fdd65', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('def569a9-e4e6-56d0-b43a-20da81028022', 'dba10773-bfa1-55d2-81f9-359ffe020b86', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='2cd88298-512d-5766-bbaa-ce32c46311fa') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='it' and u.order_index=9;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('2cd88298-512d-5766-bbaa-ce32c46311fa', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('2cd88298-512d-5766-bbaa-ce32c46311fa', '04fab0ab-2c2a-5983-955b-b05569cc5b3d', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='c27c05dd-cb63-5921-85e0-3827ddfd3b45') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='it' and u.order_index=10;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('c27c05dd-cb63-5921-85e0-3827ddfd3b45', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('c27c05dd-cb63-5921-85e0-3827ddfd3b45', '2a720ea3-e37a-5484-8f81-990400c9fd31', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='94024c2f-c6c0-56e0-a60e-59f0b609539d') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='it' and u.order_index=11;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('94024c2f-c6c0-56e0-a60e-59f0b609539d', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('94024c2f-c6c0-56e0-a60e-59f0b609539d', '2f60e170-a615-5467-b73f-fb0547962802', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='a047934a-ee88-571e-b3e8-0d5c3b78aa0c') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='it' and u.order_index=12;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('a047934a-ee88-571e-b3e8-0d5c3b78aa0c', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('a047934a-ee88-571e-b3e8-0d5c3b78aa0c', '46365abf-89ef-5b37-8893-7df65f7bf7b0', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('a047934a-ee88-571e-b3e8-0d5c3b78aa0c', '06e20f17-3b99-5e2e-b9a7-a9d3ea600897', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='de73bf11-6bd4-5e32-ac2d-c439a69fcb61') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='it' and u.order_index=13;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('de73bf11-6bd4-5e32-ac2d-c439a69fcb61', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('de73bf11-6bd4-5e32-ac2d-c439a69fcb61', 'a6a26339-3481-55db-9b3c-3bda0a4eaee0', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('de73bf11-6bd4-5e32-ac2d-c439a69fcb61', 'f2f82f3a-0e7b-56e9-bf2c-af26d6d3b9cf', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='591797aa-f95d-5698-9aae-bf9a82bdf151') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='it' and u.order_index=14;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('591797aa-f95d-5698-9aae-bf9a82bdf151', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('591797aa-f95d-5698-9aae-bf9a82bdf151', '1a0bf15e-0c2c-50e1-b455-821dc32cee1a', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='0a69a791-ebe9-5f0d-92e4-226714680147') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='it' and u.order_index=15;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('0a69a791-ebe9-5f0d-92e4-226714680147', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('0a69a791-ebe9-5f0d-92e4-226714680147', 'af2a938c-b5e1-506e-ba50-304122cfcbd1', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('0a69a791-ebe9-5f0d-92e4-226714680147', 'a09517d8-9b90-505d-b8dd-ee2940e65c1a', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='d03969a3-7c86-5c29-8ae8-f8aa7399b721') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='it' and u.order_index=17;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('d03969a3-7c86-5c29-8ae8-f8aa7399b721', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('d03969a3-7c86-5c29-8ae8-f8aa7399b721', 'c5e00f38-0b80-5747-ad40-c43f9c2c043c', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('d03969a3-7c86-5c29-8ae8-f8aa7399b721', '829ba43a-3c64-5f90-bf6a-cf3a8528d24b', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='b690ebf7-5df4-5069-842a-9259635611e6') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='it' and u.order_index=18;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('b690ebf7-5df4-5069-842a-9259635611e6', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('b690ebf7-5df4-5069-842a-9259635611e6', '2d732d78-cce4-55a1-99f8-575f2b4dbb74', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('b690ebf7-5df4-5069-842a-9259635611e6', '02b037ce-cd9e-58ee-aa66-575e1f980812', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='9fcf4629-1e69-573e-b587-646978f8e917') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='it' and u.order_index=19;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('9fcf4629-1e69-573e-b587-646978f8e917', v_unit, v_c+0, 'Repaso de vocabulario 1', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('9fcf4629-1e69-573e-b587-646978f8e917', '7e39cb56-a694-5b47-9eaf-ab9e5056aebf', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('9fcf4629-1e69-573e-b587-646978f8e917', '8ad3de2d-d32a-56e6-ba6a-066f048f1109', 1) on conflict do nothing;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('f4d4f1ca-0717-5077-bd58-43db89e52b09', v_unit, v_c+1, 'Repaso de vocabulario 2', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('f4d4f1ca-0717-5077-bd58-43db89e52b09', 'a2d73d12-20ed-5ed0-89a1-c91a594261bc', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+2 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='e4241f9a-0f1e-5859-a0c3-0ea643ff8999') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='it' and u.order_index=20;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('e4241f9a-0f1e-5859-a0c3-0ea643ff8999', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('e4241f9a-0f1e-5859-a0c3-0ea643ff8999', '6dd6d410-6d0f-5eda-9136-9e26354389af', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('e4241f9a-0f1e-5859-a0c3-0ea643ff8999', 'a46529dc-5189-5572-a095-6cc67f39617b', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='e6c6aa8a-6664-565a-a216-93a63623e74b') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='it' and u.order_index=21;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('e6c6aa8a-6664-565a-a216-93a63623e74b', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('e6c6aa8a-6664-565a-a216-93a63623e74b', '48527d52-94af-5c41-afe2-c9d06bcef696', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('e6c6aa8a-6664-565a-a216-93a63623e74b', 'a149dff0-7b5f-59cc-ba77-53b1fe9d5e49', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='e7023d39-44a4-5576-8e48-b6de5675b938') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='it' and u.order_index=22;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('e7023d39-44a4-5576-8e48-b6de5675b938', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('e7023d39-44a4-5576-8e48-b6de5675b938', '8e905574-4b72-564a-ab30-4490246e2898', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('e7023d39-44a4-5576-8e48-b6de5675b938', '9de9d366-5fd0-5456-96c3-05380ad25135', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='68b42ac6-c5d5-5e77-a048-4e08112fdd03') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='it' and u.order_index=23;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('68b42ac6-c5d5-5e77-a048-4e08112fdd03', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('68b42ac6-c5d5-5e77-a048-4e08112fdd03', '91b0a999-6bc0-5a43-a128-d3e3dff2a0dd', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='cf9559c3-910a-517a-8eb6-4205a276d3b3') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='it' and u.order_index=25;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('cf9559c3-910a-517a-8eb6-4205a276d3b3', v_unit, v_c+0, 'Repaso de vocabulario 1', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('cf9559c3-910a-517a-8eb6-4205a276d3b3', 'da0d5876-fd61-5959-95c2-12999360aec3', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('cf9559c3-910a-517a-8eb6-4205a276d3b3', '76f2880c-5b07-5b83-9006-0349e75a8760', 1) on conflict do nothing;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('78a5926c-92a9-51a2-8150-24a7fc20d34c', v_unit, v_c+1, 'Repaso de vocabulario 2', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('78a5926c-92a9-51a2-8150-24a7fc20d34c', '437ce450-a6b6-5035-b6df-f3193cdde8ad', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('78a5926c-92a9-51a2-8150-24a7fc20d34c', 'b8ab89a6-3c9a-59e2-9699-ba401d1a9e80', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+2 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='d4f44c9a-8683-5cc5-a84e-8a36cae6e168') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='it' and u.order_index=26;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('d4f44c9a-8683-5cc5-a84e-8a36cae6e168', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('d4f44c9a-8683-5cc5-a84e-8a36cae6e168', '7956f30f-65e0-5157-bb8a-eb4e6739621f', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='8f2dfd6d-4d75-51dd-97f3-36918dc819b8') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='it' and u.order_index=27;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('8f2dfd6d-4d75-51dd-97f3-36918dc819b8', v_unit, v_c+0, 'Repaso de vocabulario 1', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('8f2dfd6d-4d75-51dd-97f3-36918dc819b8', '8f108b92-ad40-5771-a899-21ac48ec0fa7', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('8f2dfd6d-4d75-51dd-97f3-36918dc819b8', '4fffae64-55af-5892-a9c8-fa8783d6bc99', 1) on conflict do nothing;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('37d6ed64-0062-5486-a7a7-c025ca2b2f9c', v_unit, v_c+1, 'Repaso de vocabulario 2', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('37d6ed64-0062-5486-a7a7-c025ca2b2f9c', 'aa3148ae-739c-52c0-9789-b3d74c8eb9ea', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+2 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='1705062d-97b1-59af-975a-43334ac71969') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='it' and u.order_index=28;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('1705062d-97b1-59af-975a-43334ac71969', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('1705062d-97b1-59af-975a-43334ac71969', '99b0dc46-631f-5ac0-a96f-cb64e69d442d', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('1705062d-97b1-59af-975a-43334ac71969', '26cd9f27-5548-5c50-a963-e692d48e680d', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='2fcdd996-91d5-53ff-ba16-b02cb1e5c835') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='it' and u.order_index=29;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('2fcdd996-91d5-53ff-ba16-b02cb1e5c835', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('2fcdd996-91d5-53ff-ba16-b02cb1e5c835', '647d2d86-f8d2-5a8e-9662-213a01f2380c', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('2fcdd996-91d5-53ff-ba16-b02cb1e5c835', '984c778c-77ba-52df-8be2-f9a63e650319', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='0990c0f9-abcb-5139-907c-fe1336fee76a') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='it' and u.order_index=30;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('0990c0f9-abcb-5139-907c-fe1336fee76a', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('0990c0f9-abcb-5139-907c-fe1336fee76a', '790bfa8a-c349-51c5-9fa1-48b647a36b22', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='8c7ea8e8-0709-56ca-95e6-57f64f047377') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='de' and u.order_index=2;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('8c7ea8e8-0709-56ca-95e6-57f64f047377', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('8c7ea8e8-0709-56ca-95e6-57f64f047377', '78b0df45-92f9-5d67-b12c-0aacaffcb99e', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('8c7ea8e8-0709-56ca-95e6-57f64f047377', '17190cc8-7986-5c1a-94f9-d08f4dfad85a', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='9265c33d-89b9-5dd8-804c-82455cef560c') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='de' and u.order_index=3;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('9265c33d-89b9-5dd8-804c-82455cef560c', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('9265c33d-89b9-5dd8-804c-82455cef560c', '6dc156d2-58ed-5a9e-b4b8-1ce4f3546330', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='321f34dd-e732-551e-9a98-e3d4bff9eed6') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='de' and u.order_index=4;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('321f34dd-e732-551e-9a98-e3d4bff9eed6', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('321f34dd-e732-551e-9a98-e3d4bff9eed6', '4f677ad5-83c6-5167-8625-65ebb5885fd5', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='044f7fee-a5c9-5a96-9b46-fc3dde292811') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='de' and u.order_index=5;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('044f7fee-a5c9-5a96-9b46-fc3dde292811', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('044f7fee-a5c9-5a96-9b46-fc3dde292811', '0db67a37-626d-5e1b-98ef-dff363a3baf6', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='70aa5692-e6f7-5d01-b4d5-3165d328070b') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='de' and u.order_index=6;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('70aa5692-e6f7-5d01-b4d5-3165d328070b', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('70aa5692-e6f7-5d01-b4d5-3165d328070b', 'dd397447-e84e-5ea2-a31d-7ef441b62412', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='90804cfb-28a9-567e-9905-6248f5da0065') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='de' and u.order_index=7;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('90804cfb-28a9-567e-9905-6248f5da0065', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('90804cfb-28a9-567e-9905-6248f5da0065', '7f0cc1fa-4ed9-5044-8b33-437d32238582', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='9c5071ec-7782-5cbd-95d4-c137d8ed35b2') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='de' and u.order_index=8;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('9c5071ec-7782-5cbd-95d4-c137d8ed35b2', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('9c5071ec-7782-5cbd-95d4-c137d8ed35b2', '0d0d5a0e-e40e-579c-b5f1-82abe9edd119', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('9c5071ec-7782-5cbd-95d4-c137d8ed35b2', 'fcef5c58-bd25-5520-9fc1-14848d5b6743', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='e8999693-cb37-5eee-8019-bfafe1b28b0d') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='de' and u.order_index=9;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('e8999693-cb37-5eee-8019-bfafe1b28b0d', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('e8999693-cb37-5eee-8019-bfafe1b28b0d', '95b8cdc0-c6b1-59bd-8e47-f35df61d855a', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='9a90f538-bc0c-5688-8d91-09bdcfbe53e4') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='de' and u.order_index=10;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('9a90f538-bc0c-5688-8d91-09bdcfbe53e4', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('9a90f538-bc0c-5688-8d91-09bdcfbe53e4', '23351e33-c3e0-5c3d-91fa-23be38ec3165', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='3ba33393-bc5f-5ebc-acc5-bea8964b8344') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='de' and u.order_index=11;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('3ba33393-bc5f-5ebc-acc5-bea8964b8344', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('3ba33393-bc5f-5ebc-acc5-bea8964b8344', '803acca9-a351-527e-9a59-b98f75f3d84b', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('3ba33393-bc5f-5ebc-acc5-bea8964b8344', '0527da24-6983-5761-b614-c7dfbc1940c4', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='5379d772-5661-53ca-92fe-9bc39a6df3c3') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='de' and u.order_index=12;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('5379d772-5661-53ca-92fe-9bc39a6df3c3', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('5379d772-5661-53ca-92fe-9bc39a6df3c3', 'c79d028b-281a-5e36-95b9-7d35d5bf0f8e', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('5379d772-5661-53ca-92fe-9bc39a6df3c3', 'f658a81f-6bc0-5f3a-8594-a0cd23c3808d', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='b7b90714-e37b-5663-ba69-5295f7a7f4aa') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='de' and u.order_index=13;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('b7b90714-e37b-5663-ba69-5295f7a7f4aa', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('b7b90714-e37b-5663-ba69-5295f7a7f4aa', '87c56947-bb0d-5119-a830-ded203fd46cc', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('b7b90714-e37b-5663-ba69-5295f7a7f4aa', 'a07211de-f739-58ea-8360-d66ca86c56d0', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='3043f6ef-3b82-5f57-a92a-0cb9ad632679') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='de' and u.order_index=14;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('3043f6ef-3b82-5f57-a92a-0cb9ad632679', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('3043f6ef-3b82-5f57-a92a-0cb9ad632679', '4fb94b5a-ec78-50f5-846e-af61277ddb2f', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='afb09ae1-cefb-55ee-b016-bbb474d4b969') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='de' and u.order_index=15;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('afb09ae1-cefb-55ee-b016-bbb474d4b969', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('afb09ae1-cefb-55ee-b016-bbb474d4b969', 'f2628eac-0479-51d4-ab0b-ccd4659fa918', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='554ff036-0d94-588f-891a-5ec4d8f3061e') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='de' and u.order_index=16;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('554ff036-0d94-588f-891a-5ec4d8f3061e', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('554ff036-0d94-588f-891a-5ec4d8f3061e', 'cdd7b862-9376-548e-8ce7-d93e5aa51f1a', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='4497b5a0-96da-5bf8-9b87-d9a141671e7d') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='de' and u.order_index=17;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('4497b5a0-96da-5bf8-9b87-d9a141671e7d', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('4497b5a0-96da-5bf8-9b87-d9a141671e7d', 'a199a67e-a627-5036-aed7-1f65ab959b87', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='2c954c48-b6aa-560b-944c-5664de663d59') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='de' and u.order_index=18;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('2c954c48-b6aa-560b-944c-5664de663d59', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('2c954c48-b6aa-560b-944c-5664de663d59', '647d57b4-1b33-5931-b0bc-45665127ee8b', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='269d4930-2fcb-5bbe-bc3e-eef5a7aa3247') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='de' and u.order_index=19;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('269d4930-2fcb-5bbe-bc3e-eef5a7aa3247', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('269d4930-2fcb-5bbe-bc3e-eef5a7aa3247', 'fe995f67-758b-5502-af2d-edf05d388179', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('269d4930-2fcb-5bbe-bc3e-eef5a7aa3247', '69ac8f26-56ad-5840-850d-ce3726feb7ef', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='35ba2607-f679-5740-b8cd-e454426ee10e') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='de' and u.order_index=20;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('35ba2607-f679-5740-b8cd-e454426ee10e', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('35ba2607-f679-5740-b8cd-e454426ee10e', '1ba9dc0f-e325-51de-8c88-53a26ad5277e', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='98ddfcad-3bbd-5d89-a0a1-61eb9b0ec8f8') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='de' and u.order_index=21;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('98ddfcad-3bbd-5d89-a0a1-61eb9b0ec8f8', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('98ddfcad-3bbd-5d89-a0a1-61eb9b0ec8f8', 'f75c75f8-9dea-5e5e-b494-66b8469ca00e', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('98ddfcad-3bbd-5d89-a0a1-61eb9b0ec8f8', '6a7896a8-a7db-5d94-a34c-39e8dbe34714', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='83a65d12-be3c-5b0d-9bdb-f747dd9408a4') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='de' and u.order_index=22;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('83a65d12-be3c-5b0d-9bdb-f747dd9408a4', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('83a65d12-be3c-5b0d-9bdb-f747dd9408a4', 'e6276d56-d5ba-5d89-8f4f-1ed85ce660f9', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='32e38284-0c90-50f6-a804-62c1d6790472') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='de' and u.order_index=23;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('32e38284-0c90-50f6-a804-62c1d6790472', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('32e38284-0c90-50f6-a804-62c1d6790472', 'e1d4d679-6e45-5730-a413-0045e8525d85', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('32e38284-0c90-50f6-a804-62c1d6790472', '064cce93-267c-5b09-9897-a50c6860bbd7', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='f8c843e9-e74d-5cf7-a810-b2957fdf9e43') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='de' and u.order_index=24;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('f8c843e9-e74d-5cf7-a810-b2957fdf9e43', v_unit, v_c+0, 'Repaso de vocabulario 1', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('f8c843e9-e74d-5cf7-a810-b2957fdf9e43', '0318ce55-26e5-5db6-8a7a-d5bf5908e1bf', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('f8c843e9-e74d-5cf7-a810-b2957fdf9e43', '868c5592-551a-562c-ada3-4787545f5b38', 1) on conflict do nothing;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('5c5454d5-4a35-50eb-91eb-420728dc663d', v_unit, v_c+1, 'Repaso de vocabulario 2', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('5c5454d5-4a35-50eb-91eb-420728dc663d', '9a624fb0-2eef-52e7-a8a4-ebfdfe9ea17b', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+2 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='cbcc0c98-59ae-539e-8767-c895f4d377e2') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='de' and u.order_index=25;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('cbcc0c98-59ae-539e-8767-c895f4d377e2', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('cbcc0c98-59ae-539e-8767-c895f4d377e2', 'cb5b6a8c-dc19-54f7-baf5-dfdab1903fd8', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('cbcc0c98-59ae-539e-8767-c895f4d377e2', 'f6d80a11-8de1-586d-bbe2-392d69c29054', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='ed5f1252-461b-5a5a-8664-864997a0e5ca') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='de' and u.order_index=26;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('ed5f1252-461b-5a5a-8664-864997a0e5ca', v_unit, v_c+0, 'Repaso de vocabulario 1', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('ed5f1252-461b-5a5a-8664-864997a0e5ca', '1132eb16-be59-52eb-9dea-e6e8423e22bf', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('ed5f1252-461b-5a5a-8664-864997a0e5ca', 'ea7a45f7-7e97-5742-b4c6-af67ad86efe2', 1) on conflict do nothing;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('008ed0a4-9a12-5507-8d31-ee3e6f0686b4', v_unit, v_c+1, 'Repaso de vocabulario 2', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('008ed0a4-9a12-5507-8d31-ee3e6f0686b4', '9268bcc2-6c49-597a-933e-6836969ccf71', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('008ed0a4-9a12-5507-8d31-ee3e6f0686b4', 'ef1f537e-3bf1-5dca-86e8-ca3c2912f27b', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+2 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='ae8cff74-b8ce-5737-8f7f-2cc705d5a80d') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='de' and u.order_index=27;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('ae8cff74-b8ce-5737-8f7f-2cc705d5a80d', v_unit, v_c+0, 'Repaso de vocabulario 1', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('ae8cff74-b8ce-5737-8f7f-2cc705d5a80d', 'c2c4492b-57c0-5bc1-8c5e-2bf27fa3a632', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('ae8cff74-b8ce-5737-8f7f-2cc705d5a80d', '7c859148-5b95-5790-b4c9-17de7a1a5663', 1) on conflict do nothing;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('241d1bf1-3658-5ecf-8d48-b7a1239cb1ef', v_unit, v_c+1, 'Repaso de vocabulario 2', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('241d1bf1-3658-5ecf-8d48-b7a1239cb1ef', '75317beb-74c6-5a22-a492-2dd863d0b1d8', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('241d1bf1-3658-5ecf-8d48-b7a1239cb1ef', 'bcf835f2-52d5-50d6-90bf-cdcb15f0f0f2', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+2 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='fbde6dc6-5274-5380-9ceb-95a9920560ca') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='de' and u.order_index=28;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('fbde6dc6-5274-5380-9ceb-95a9920560ca', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('fbde6dc6-5274-5380-9ceb-95a9920560ca', '475322d7-028d-5f8d-a7c3-2fddb44b28cf', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('fbde6dc6-5274-5380-9ceb-95a9920560ca', 'd6d25cea-975d-5698-82ad-5bbb03f8700d', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='15c6fe4b-5ce0-5673-865f-87786de9a666') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='de' and u.order_index=29;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('15c6fe4b-5ce0-5673-865f-87786de9a666', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('15c6fe4b-5ce0-5673-865f-87786de9a666', 'c52a99cf-0775-51c3-9c00-b36ba19e1e1a', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('15c6fe4b-5ce0-5673-865f-87786de9a666', '17549c30-3912-5bc8-b4c0-3645c0e47830', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='7df60dbd-4ba4-5b71-99f0-0287676ef233') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='de' and u.order_index=30;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('7df60dbd-4ba4-5b71-99f0-0287676ef233', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('7df60dbd-4ba4-5b71-99f0-0287676ef233', '476ec341-39f3-5d95-bd5a-78ac6a28c058', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('7df60dbd-4ba4-5b71-99f0-0287676ef233', 'b6ec100f-485d-51aa-a149-984cd754989a', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='622364fe-8956-5b63-8437-5b27ea26d208') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='nl' and u.order_index=2;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('622364fe-8956-5b63-8437-5b27ea26d208', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('622364fe-8956-5b63-8437-5b27ea26d208', '7f656036-042b-5186-b7ae-56678e031a2e', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='b731f07e-82dc-5cb9-9f0a-d9eb6e785387') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='nl' and u.order_index=3;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('b731f07e-82dc-5cb9-9f0a-d9eb6e785387', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('b731f07e-82dc-5cb9-9f0a-d9eb6e785387', '77adf6c1-8178-5050-b5cb-0a551befcda3', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='16cc5444-7d2e-57e2-a690-53f2b671feba') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='nl' and u.order_index=4;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('16cc5444-7d2e-57e2-a690-53f2b671feba', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('16cc5444-7d2e-57e2-a690-53f2b671feba', '5c0def68-cd11-5057-944c-87874710f1cf', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='b8136f46-90cb-5ef1-86f2-6ee000706b8b') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='nl' and u.order_index=5;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('b8136f46-90cb-5ef1-86f2-6ee000706b8b', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('b8136f46-90cb-5ef1-86f2-6ee000706b8b', '63930fcb-d3af-5b79-b7b2-bd34b92f6cc0', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='260751f6-2505-5188-8c8a-cad5620b55a5') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='nl' and u.order_index=7;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('260751f6-2505-5188-8c8a-cad5620b55a5', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('260751f6-2505-5188-8c8a-cad5620b55a5', '45528652-317a-5477-a383-502e1fc61a68', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='c06d648a-c457-5c95-8550-e4f5dc6b5e4c') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='nl' and u.order_index=8;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('c06d648a-c457-5c95-8550-e4f5dc6b5e4c', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('c06d648a-c457-5c95-8550-e4f5dc6b5e4c', 'd58df095-ebd0-5860-96bf-ca63980fb784', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='f6d7ec02-3b00-563d-b5f5-76f8f39fa8b4') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='nl' and u.order_index=9;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('f6d7ec02-3b00-563d-b5f5-76f8f39fa8b4', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('f6d7ec02-3b00-563d-b5f5-76f8f39fa8b4', '2c0b7f03-81b4-50cd-904c-4866cf013f83', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='05dbc356-f8cf-51b6-80b2-81e6aa85fcf5') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='nl' and u.order_index=10;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('05dbc356-f8cf-51b6-80b2-81e6aa85fcf5', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('05dbc356-f8cf-51b6-80b2-81e6aa85fcf5', '59952c9f-7b14-5627-9e20-ab147b6cb7e3', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='08c36c78-cbe9-5b8c-8d43-d204bb9cd99e') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='nl' and u.order_index=11;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('08c36c78-cbe9-5b8c-8d43-d204bb9cd99e', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('08c36c78-cbe9-5b8c-8d43-d204bb9cd99e', 'ce9ce520-2057-54e4-b9be-5f5fa5d536e3', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='36a423d1-a17c-5291-9a77-f285eae93f84') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='nl' and u.order_index=12;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('36a423d1-a17c-5291-9a77-f285eae93f84', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('36a423d1-a17c-5291-9a77-f285eae93f84', 'ffa006d3-7e29-5f02-9f8c-0f9e3fd5c424', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('36a423d1-a17c-5291-9a77-f285eae93f84', 'a11f6897-4a2c-53b6-bd27-f853dd8eff00', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='5efacdde-5b54-5699-98f5-059f0361ab5b') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='nl' and u.order_index=13;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('5efacdde-5b54-5699-98f5-059f0361ab5b', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('5efacdde-5b54-5699-98f5-059f0361ab5b', '3a5d81d0-b78e-5f68-a6ac-05d24300f813', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='45cdf063-cae5-5d8a-9cfd-f1aff6951fdf') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='nl' and u.order_index=14;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('45cdf063-cae5-5d8a-9cfd-f1aff6951fdf', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('45cdf063-cae5-5d8a-9cfd-f1aff6951fdf', 'dab8f69c-0dc4-5101-b501-b4bd6696e186', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='26ce9d24-32f8-5f04-8f37-0284b41917b1') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='nl' and u.order_index=15;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('26ce9d24-32f8-5f04-8f37-0284b41917b1', v_unit, v_c+0, 'Repaso de vocabulario 1', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('26ce9d24-32f8-5f04-8f37-0284b41917b1', '93560ad3-95b8-52cd-b676-7b4fe38cc157', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('26ce9d24-32f8-5f04-8f37-0284b41917b1', '703c3d63-890e-502d-955a-71abc803533b', 1) on conflict do nothing;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('9aceff4d-e532-5703-b567-2783fb9799a3', v_unit, v_c+1, 'Repaso de vocabulario 2', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('9aceff4d-e532-5703-b567-2783fb9799a3', 'e5d94edb-c07e-5e52-a3b4-78b9ba40ae90', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('9aceff4d-e532-5703-b567-2783fb9799a3', '0b7f720d-18df-5d47-a6ad-043520566bed', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+2 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='2866dc40-bbcd-5aef-acc2-98a2fc8fa087') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='nl' and u.order_index=16;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('2866dc40-bbcd-5aef-acc2-98a2fc8fa087', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('2866dc40-bbcd-5aef-acc2-98a2fc8fa087', '3ab74633-644f-579c-93c6-441a4c8fb9a9', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='9c8abe5c-58b1-5df0-9161-a1444f06e0b9') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='nl' and u.order_index=17;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('9c8abe5c-58b1-5df0-9161-a1444f06e0b9', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('9c8abe5c-58b1-5df0-9161-a1444f06e0b9', '8317202a-98e6-5459-ba82-56a07d289f13', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='fad5ff7e-9560-5041-93f9-b26f7bc64922') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='nl' and u.order_index=19;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('fad5ff7e-9560-5041-93f9-b26f7bc64922', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('fad5ff7e-9560-5041-93f9-b26f7bc64922', '2ed5c198-c074-5a1a-9cbd-95f0940f3111', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('fad5ff7e-9560-5041-93f9-b26f7bc64922', 'b31d18e8-2e54-5926-9fc4-92f99d939dd1', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='e55befb3-d6a8-55af-990a-cfd2a7e87bbd') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='nl' and u.order_index=20;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('e55befb3-d6a8-55af-990a-cfd2a7e87bbd', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('e55befb3-d6a8-55af-990a-cfd2a7e87bbd', 'e3931d04-8574-5654-986e-1ed31f9546d9', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='29f7ed63-bad6-5129-880b-f50e3a9dd6bb') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='nl' and u.order_index=21;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('29f7ed63-bad6-5129-880b-f50e3a9dd6bb', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('29f7ed63-bad6-5129-880b-f50e3a9dd6bb', '498ed45c-c446-5fde-a129-25da62f2d744', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='705e52e9-477b-5a7f-8c70-5cb183ba7edf') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='nl' and u.order_index=22;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('705e52e9-477b-5a7f-8c70-5cb183ba7edf', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('705e52e9-477b-5a7f-8c70-5cb183ba7edf', '50faee29-1ea7-527e-88b4-7f4e2b0b73a1', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('705e52e9-477b-5a7f-8c70-5cb183ba7edf', 'b8fa9b6d-f0c4-54fc-bd31-4a21421f335c', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='25bb6a30-dcf5-5ac8-aedb-a9bf470b29af') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='nl' and u.order_index=23;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('25bb6a30-dcf5-5ac8-aedb-a9bf470b29af', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('25bb6a30-dcf5-5ac8-aedb-a9bf470b29af', 'a726e15d-b221-599f-8e14-3b12a27fc70c', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('25bb6a30-dcf5-5ac8-aedb-a9bf470b29af', '7e30850b-ec3d-5190-a825-2a5752f3e368', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='3b193c09-7e90-5928-b336-03234ad8ae3a') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='nl' and u.order_index=24;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('3b193c09-7e90-5928-b336-03234ad8ae3a', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('3b193c09-7e90-5928-b336-03234ad8ae3a', 'b1e3d1ca-8c82-56da-a2f6-260e7c8b16bd', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('3b193c09-7e90-5928-b336-03234ad8ae3a', '0e676440-0cd4-52f2-852d-149509cf8117', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='da792dd7-2bfb-5502-887d-59940d511430') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='nl' and u.order_index=25;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('da792dd7-2bfb-5502-887d-59940d511430', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('da792dd7-2bfb-5502-887d-59940d511430', '42e190cd-1e79-5459-913f-69b4f90c9678', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('da792dd7-2bfb-5502-887d-59940d511430', '137eb95f-80d6-55f6-a33a-c8ac6935e257', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='c501dd16-fbc1-5819-81f1-d7c80d1f1099') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='nl' and u.order_index=26;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('c501dd16-fbc1-5819-81f1-d7c80d1f1099', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('c501dd16-fbc1-5819-81f1-d7c80d1f1099', '88db1473-3f2d-5fc3-b25d-79be49ae9a62', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='40d61e6f-5160-50c5-9c32-021ff08d35c1') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='nl' and u.order_index=27;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('40d61e6f-5160-50c5-9c32-021ff08d35c1', v_unit, v_c+0, 'Repaso de vocabulario 1', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('40d61e6f-5160-50c5-9c32-021ff08d35c1', 'f200acaf-b26e-5daa-a58f-8cc6cbda2fc9', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('40d61e6f-5160-50c5-9c32-021ff08d35c1', '66448ffa-04e8-593e-829e-f468f966ed98', 1) on conflict do nothing;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('820e7b51-46f1-5872-84bf-19bc7b318404', v_unit, v_c+1, 'Repaso de vocabulario 2', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('820e7b51-46f1-5872-84bf-19bc7b318404', '2bc3d5f2-1259-581c-8ba3-f71ab2aa2e02', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('820e7b51-46f1-5872-84bf-19bc7b318404', 'b6e8e1d7-3a58-591f-ac38-89f53fa5071a', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+2 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='5e9350c7-19a9-5163-adcd-dabe78f4c1a6') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='nl' and u.order_index=28;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('5e9350c7-19a9-5163-adcd-dabe78f4c1a6', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('5e9350c7-19a9-5163-adcd-dabe78f4c1a6', 'e6c0af5a-db5a-590a-bdf4-00c269465137', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('5e9350c7-19a9-5163-adcd-dabe78f4c1a6', '0057758d-4c37-513c-aaf0-1190f20347d0', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='f702950b-0c48-57f7-8c5b-4e7399d8ed83') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='nl' and u.order_index=29;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('f702950b-0c48-57f7-8c5b-4e7399d8ed83', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('f702950b-0c48-57f7-8c5b-4e7399d8ed83', '3f2e3e61-6f9d-5006-bf41-d1475ae861a0', 0) on conflict do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('f702950b-0c48-57f7-8c5b-4e7399d8ed83', '60b74fbc-e953-5537-b5f0-3b8099e48779', 1) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

do $$
declare v_unit uuid; v_c int;
begin
  -- idempotencia: si la 1ª lección de repaso ya existe, no re-desplazar el checkpoint.
  if exists (select 1 from lessons where id='469b711b-7a53-5dfb-81cb-55c52bc076ef') then return; end if;
  select u.id into v_unit from units u join courses c on c.id=u.course_id
    join languages l on l.id=c.target_language_id
    where l.code='nl' and u.order_index=30;
  if v_unit is null then return; end if;
  select min(order_index) into v_c from lessons where unit_id=v_unit and type='checkpoint';
  if v_c is null then select max(order_index)+1 into v_c from lessons where unit_id=v_unit; end if;
  update lessons set order_index=order_index+1000 where unit_id=v_unit and order_index>=v_c;
  insert into lessons(id,unit_id,order_index,title,description,type,xp_reward) values ('469b711b-7a53-5dfb-81cb-55c52bc076ef', v_unit, v_c+0, 'Repaso de vocabulario', 'Refuerza palabras clave de este nivel.', 'lesson', 15) on conflict (id) do nothing;
  insert into lesson_items(lesson_id,item_id,order_index) values ('469b711b-7a53-5dfb-81cb-55c52bc076ef', '24901189-e29c-5522-8b78-cd4f00a428ea', 0) on conflict do nothing;
  update lessons set order_index=order_index-1000+1 where unit_id=v_unit and order_index>=1000;
end $$;

-- 3) re-derivar lesson_vocab (idempotente, lógica mig 165/166) → las palabras
--    de los match nuevos quedan VINCULADAS → dejan de ser inertes.
insert into public.lesson_vocab (lesson_id, vocab_id, position)
with vn as (
  select id, course_id, jz_normalize(word) as nw,
         position(' ' in jz_normalize(word)) > 0 as is_multi
  from public.vocabulary
), item_text as (
  select li.lesson_id, u.course_id, li.order_index,
         translate(jz_normalize(t.txt), ',.;:!?¿¡"()[]{}', '               ') as ntxt
  from public.lesson_items li
  join public.content_items ci on ci.id = li.item_id
  join public.lessons l on l.id = li.lesson_id
  join public.units u on u.id = l.unit_id
  cross join lateral (values
    (ci.correct_answer ->> 'value'), (ci.payload ->> 'text'),
    (ci.payload ->> 'say'), (ci.prompt)
  ) as t(txt)
  where coalesce(t.txt, '') <> ''
), tok as (
  select it.lesson_id, it.course_id, it.order_index, w
  from item_text it
  cross join lateral regexp_split_to_table(it.ntxt, '\s+') as w
  where length(w) >= 2
), pair as (
  select li.lesson_id, u.course_id, li.order_index, jz_normalize(p ->> 'en') as w
  from public.lesson_items li
  join public.content_items ci on ci.id = li.item_id
  join public.lessons l on l.id = li.lesson_id
  join public.units u on u.id = l.unit_id
  cross join lateral jsonb_array_elements(ci.payload -> 'pairs') as p
  where ci.type = 'match' and coalesce(p ->> 'en', '') <> ''
), exact_m as (
  select c.lesson_id, v.id as vocab_id, c.order_index
  from (select lesson_id, course_id, order_index, w from tok
        union all
        select lesson_id, course_id, order_index, w from pair) c
  join vn v on v.course_id = c.course_id and v.nw = c.w
), multi_m as (
  select it.lesson_id, v.id as vocab_id, it.order_index
  from item_text it
  join vn v on v.course_id = it.course_id and v.is_multi
   and (' ' || it.ntxt || ' ') like ('%' || ' ' || v.nw || ' ' || '%')
), allm as (
  select * from exact_m union all select * from multi_m
)
select lesson_id, vocab_id, min(order_index) as position
from allm
group by lesson_id, vocab_id
on conflict (lesson_id, vocab_id) do nothing;
