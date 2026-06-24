-- ============================================================================
-- Jezici · Migración 068 · word_bank/reorder no revelan la respuesta (P1)
-- ----------------------------------------------------------------------------
-- BUG (feedback usuario): word_bank "Arma la frase: 'Nice to meet you'" MUESTRA
-- el target en INGLÉS → el usuario copia, no aprende. Misma clase en reorder
-- ("Ordena: '<inglés>'"). FIX: el enunciado da el SIGNIFICADO en ESPAÑOL; las
-- tiles siguen siendo las palabras en inglés (producción real). El grading NO
-- cambia (compara orden de tiles vs correct_answer). 20 ítems (es→en + es→pt).
-- ============================================================================
begin;

-- ── word_bank (es→en) ───────────────────────────────────────────────────────
update content_items set prompt = $p$Arma la frase en inglés: «Muchas gracias».$p$, updated_at = now() where id = '42000000-0000-0000-0000-000000000007';
update content_items set prompt = $p$Arma la pregunta en inglés: «¿Cómo te llamas?».$p$, updated_at = now() where id = '43000000-0000-0000-0000-000000000007';
update content_items set prompt = $p$Arma la frase en inglés: «Mucho gusto».$p$, updated_at = now() where id = '44000000-0000-0000-0000-000000000007';
update content_items set prompt = $p$Arma la frase formal en inglés: «El análisis reveló un marcado deterioro».$p$, updated_at = now() where id = 'c5000222-0000-0000-0000-000000000222';
update content_items set prompt = $p$Arma la frase formal en inglés: «Se asume en general que los mercados se autocorrigen».$p$, updated_at = now() where id = 'c5000229-0000-0000-0000-000000000229';
update content_items set prompt = $p$Arma la frase formal en inglés: «El argumento es válido en la medida en que se sostengan los supuestos».$p$, updated_at = now() where id = 'c5000239-0000-0000-0000-000000000239';

-- ── reorder (es→en) ─────────────────────────────────────────────────────────
update content_items set prompt = $p$Ordena las palabras para responder «Yo también» (acuerdo).$p$, updated_at = now() where id = 'c3000078-0000-0000-0000-000000000078';
update content_items set prompt = $p$Ordena las palabras para formar: «Dijo que no estaba de acuerdo».$p$, updated_at = now() where id = 'c3000094-0000-0000-0000-000000000094';
update content_items set prompt = $p$Ordena las palabras para formar: «La empresa sigue muy dependiente del capital extranjero».$p$, updated_at = now() where id = 'c5000014-0000-0000-0000-000000000014';
update content_items set prompt = $p$Ordena las palabras para formar: «Sería imprudente exagerar la importancia de estos resultados».$p$, updated_at = now() where id = 'c5000030-0000-0000-0000-000000000030';
update content_items set prompt = $p$Ordena las palabras para formar: «Podría decirse que este es el argumento más matizado hasta ahora».$p$, updated_at = now() where id = 'c5000039-0000-0000-0000-000000000039';
update content_items set prompt = $p$Ordena las palabras para formar: «Aquí los retrasos son lo habitual».$p$, updated_at = now() where id = 'c5000145-0000-0000-0000-000000000145';
update content_items set prompt = $p$Ordena las palabras para formar (eufemismo): «Puede que tengamos que despedirte».$p$, updated_at = now() where id = 'c5000157-0000-0000-0000-000000000157';
update content_items set prompt = $p$Ordena las palabras para formar: «Esto no es ni de lejos el final».$p$, updated_at = now() where id = 'c5000167-0000-0000-0000-000000000167';
update content_items set prompt = $p$Ordena las palabras para formar: «El autor da a entender que la política fracasó».$p$, updated_at = now() where id = 'c5000215-0000-0000-0000-000000000215';
update content_items set prompt = $p$Ordena las palabras para formar: «La evaluación del programa está en curso».$p$, updated_at = now() where id = 'c5000224-0000-0000-0000-000000000224';
update content_items set prompt = $p$Ordena las palabras para formar: «Se ha sostenido que el método no es fiable».$p$, updated_at = now() where id = 'c5000230-0000-0000-0000-000000000230';
update content_items set prompt = $p$Ordena las palabras para formar: «No obstante, los supuestos subyacentes siguen siendo cuestionables».$p$, updated_at = now() where id = 'c5000240-0000-0000-0000-000000000240';
update content_items set prompt = $p$Ordena las palabras para formar: «Se le considera ampliamente una contribución fundamental».$p$, updated_at = now() where id = 'c5000249-0000-0000-0000-000000000249';

-- ── reorder (es→pt) ─────────────────────────────────────────────────────────
update content_items set prompt = $p$Ordena las palabras para proponer un plan: «¿Vamos a tomar un café después?».$p$, updated_at = now() where id = 'd2000056-0000-0000-0000-000000000056';

commit;
