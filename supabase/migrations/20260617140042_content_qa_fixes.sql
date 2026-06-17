-- ============================================================================
-- Jezici · Migración 042 · Fixes de QA de contenido (A1 u3-6 + A2)
-- Verificados adversarialmente (pedagogical-qa workflow). UPDATE por id.
-- ============================================================================
begin;
update content_items set correct_answer = $j${"value": "He is my father", "accepted": ["he is my father", "he is my father.", "he's my father", "he's my father.", "he is my dad", "he is my dad.", "he's my dad", "he's my dad."]}$j$::jsonb, updated_at = now() where id = 'c3300000-0000-0000-0000-000000000006';
update content_items set correct_answer = $j${"value": "mother", "accepted": ["mother", "mom", "mum"]}$j$::jsonb, updated_at = now() where id = 'c3100000-0000-0000-0000-000000000004';
update content_items set correct_answer = $j${"value": "How much is it?", "accepted": ["how much is it", "how much is it?", "how much does it cost", "how much does it cost?"]}$j$::jsonb, updated_at = now() where id = 'c4400000-0000-0000-0000-000000000005';
update content_items set correct_answer = $j${"value": "Can I have a tea, please?", "accepted": ["can i have a tea please", "can i have a tea, please?", "can i have tea please", "could i have a tea please", "could i have a tea, please?", "could i have tea please"]}$j$::jsonb, updated_at = now() where id = 'c4300000-0000-0000-0000-000000000004';
update content_items set correct_answer = $j${"value": "Today is Monday", "accepted": ["today is monday", "it's monday today", "it is monday today"]}$j$::jsonb, updated_at = now() where id = 'c5200000-0000-0000-0000-000000000005';
update content_items set correct_answer = $j${"value": "It's five o'clock", "accepted": ["it's five o'clock", "its five o'clock", "it is five o'clock", "it's 5 o'clock", "it is 5 o'clock"]}$j$::jsonb, updated_at = now() where id = 'c5100000-0000-0000-0000-000000000005';
update content_items set correct_answer = $j${"value": "I worked yesterday.", "accepted": ["I worked yesterday", "Yesterday I worked", "Yesterday I worked."]}$j$::jsonb, updated_at = now() where id = 'c2000013-0000-0000-0000-000000000013';
update content_items set correct_answer = $j${"value": "I ate pizza.", "accepted": ["I ate pizza", "I had pizza", "I had pizza."]}$j$::jsonb, updated_at = now() where id = 'c2000021-0000-0000-0000-000000000021';
update content_items set correct_answer = $j${"value": "ticket", "accepted": ["ticket", "train", "flight", "bus"]}$j$::jsonb, updated_at = now() where id = 'c2000068-0000-0000-0000-000000000068';
update content_items set payload = $j${"options": ["educada", "grosera", "informal"]}$j$::jsonb, updated_at = now() where id = 'c2000091-0000-0000-0000-000000000091';
update content_items set correct_answer = $j${"value": "The train arrives at eight.", "accepted": ["The train arrives at 8", "The train arrives at eight", "The train comes at eight", "The train comes at 8"]}$j$::jsonb, updated_at = now() where id = 'c2000069-0000-0000-0000-000000000069';
update content_items set correct_answer = $j${"value": "She has long hair.", "accepted": ["She has long hair", "She has got long hair", "She has got long hair.", "She's got long hair", "She's got long hair."]}$j$::jsonb, updated_at = now() where id = 'c2000133-0000-0000-0000-000000000133';
update content_items set correct_answer = $j${"value": "sick", "accepted": ["sick", "ill", "unwell"]}$j$::jsonb, updated_at = now() where id = 'c2000164-0000-0000-0000-000000000164';
update content_items set correct_answer = $j${"value": "already", "accepted": ["already", "just"]}$j$::jsonb, updated_at = now() where id = 'c2000180-0000-0000-0000-000000000180';
update content_items set correct_answer = $j${"value": "My stomach hurts.", "accepted": ["My stomach hurts", "I have a stomachache", "I have a stomach ache", "I have stomachache"]}$j$::jsonb, updated_at = now() where id = 'c2000165-0000-0000-0000-000000000165';
update content_items set payload = $j${"options": ["Let's", "Let", "Go"]}$j$::jsonb, updated_at = now() where id = 'c2000049-0000-0000-0000-000000000049';
commit;
