-- 20260703120117_fix_mc_collision_en_b2.sql
-- Barrido de colisiones MC/listening (regla del agente): jz_normalize quita la puntuación,
-- así que un distractor que solo difiere por una COMA colisiona con el correcto y se acepta.
-- Único caso en toda la BD (1/1611): en B2, MC de "explicativa entre comas" (id ccf4b370…):
--   correcto  «Diego, who runs the bakery downstairs, always saves me a loaf.»
--   distractor «Diego who runs the bakery downstairs, always saves me a loaf.» (sin la 1ª coma)
-- Ambos normalizan igual → distractor aceptado. Como el punto (comas) NO es calificable con el
-- grader que quita puntuación, se REENMARCA el ítem al PRONOMBRE RELATIVO en cláusula explicativa
-- sobre persona (who correcto; that/which incorrectos), que difieren por PALABRA (sí calificable).
begin;
update content_items
set prompt = 'En una frase explicativa (un dato extra, entre comas) sobre una PERSONA, ¿qué pronombre relativo es correcto? Elige la frase correcta.',
    payload = jsonb_build_object('options', jsonb_build_array(
      'Diego, who runs the bakery downstairs, always saves me a loaf.',
      'Diego, that runs the bakery downstairs, always saves me a loaf.',
      'Diego, which runs the bakery downstairs, always saves me a loaf.'
    )),
    correct_answer = jsonb_build_object('value', 'Diego, who runs the bakery downstairs, always saves me a loaf.'),
    updated_at = now()
where id = 'ccf4b370-1555-5fe8-a0f3-d3b89add0907';
commit;
