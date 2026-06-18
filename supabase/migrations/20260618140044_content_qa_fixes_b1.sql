-- ============================================================================
-- Jezici · Migración 042 · Fixes de QA de contenido (A1 u3-6 + A2)
-- Verificados adversarialmente (pedagogical-qa workflow). UPDATE por id.
-- ============================================================================
begin;
update content_items set correct_answer = $j${"value": "I used to smoke, but I quit two years ago.", "accepted": ["I used to smoke, but I quit two years ago", "I used to smoke but I gave it up two years ago", "I used to smoke, but I stopped two years ago", "I used to smoke, but I gave up two years ago", "I used to smoke, but I quit smoking two years ago", "I used to smoke, but I stopped smoking two years ago", "I used to smoke, but I gave up smoking two years ago"]}$j$::jsonb, updated_at = now() where id = 'c3000029-0000-0000-0000-000000000029';
update content_items set correct_answer = $j${"value": "hand", "accepted": ["hand", "turn"]}$j$::jsonb, updated_at = now() where id = 'c3000044-0000-0000-0000-000000000044';
update content_items set prompt = $p$Completa con la forma -ing del verbo entre paréntesis para el pasado continuo: "When the storm started, we were still ___ (explore) the forest."$p$, updated_at = now() where id = 'c3000124-0000-0000-0000-000000000124';
update content_items set correct_answer = $j${"value": "will miss", "accepted": ["will miss", "'ll miss"]}$j$::jsonb, updated_at = now() where id = 'c3000140-0000-0000-0000-000000000140';
update content_items set correct_answer = $j${"value": "has", "accepted": ["has", "needs"]}$j$::jsonb, updated_at = now() where id = 'c3000148-0000-0000-0000-000000000148';
commit;
