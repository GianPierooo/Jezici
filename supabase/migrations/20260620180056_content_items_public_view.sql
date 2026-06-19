-- ============================================================================
-- Jezici · Migración 056 · Vista content_items_public (robustez P0)
-- ----------------------------------------------------------------------------
-- Defensa en profundidad para el cierre de correct_answer (mig 055): el cliente
-- lee de una VISTA que NO incluye la columna de respuestas. Así, ni un select=*
-- accidental ni una lectura futura pueden exponer correct_answer. La columna
-- sigue revocada también en la tabla base (mig 055); grade_item (SECURITY
-- DEFINER) la lee de la base para calificar.
-- security_invoker = true → respeta la RLS de content_items (lectura pública).
-- ============================================================================
begin;

create or replace view content_items_public
  with (security_invoker = true) as
  select id, course_id, cefr_level, skill, type, prompt, payload,
         difficulty, irt_a, irt_b, tags, created_at, updated_at
  from content_items;

grant select on content_items_public to anon, authenticated;

commit;
