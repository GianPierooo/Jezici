-- ============================================================================
-- Jezici · Migración 060 · Referencia navegable ("enseña, no solo evalúa")
-- ----------------------------------------------------------------------------
-- Repaso estilo Busuu "Grammar Review": navega los conceptos curados
-- (content_tips, mig 057) por habilidad/nivel del CURSO ACTIVO, marca cuáles ya
-- viste (cuaderno) y sugiere tu habilidad más floja. SOLO LECTURA sobre datos
-- existentes (content_tips + user_tip_progress + jz_reinforce_score); no marca
-- como visto (eso es solo del tip post-lección). DEFINER acotado a auth.uid().
-- ============================================================================
begin;

create or replace function get_reference()
returns jsonb
language plpgsql
security definer
set search_path = public
as $fn$
declare
  uid uuid := auth.uid();
  v_course uuid;
  v_weak text;
begin
  if uid is null then raise exception 'auth required'; end if;
  v_course := jz_active_course();
  -- Habilidad más floja (misma lógica que el tip post-lección).
  select s into v_weak from unnest(array['reading','listening','writing','speaking']) s
    order by jz_reinforce_score(uid, v_course, s::skill) desc,
             array_position(array['reading','listening','writing','speaking'], s)
    limit 1;

  return jsonb_build_object(
    'weakest', v_weak,
    'tips', coalesce((
      select jsonb_agg(jsonb_build_object(
          'id', t.id, 'type', t.type, 'skill', t.skill, 'cefr_level', t.cefr_level,
          'unit_order', t.unit_order, 'title', t.title, 'body', t.body, 'example', t.example,
          'seen', exists (select 1 from user_tip_progress up
                          where up.user_id = uid and up.tip_id = t.id))
        order by array_position(array['reading','listening','writing','speaking'], t.skill),
                 t.cefr_level, t.unit_order)
      from content_tips t where t.course_id = v_course), '[]'::jsonb));
end $fn$;
grant execute on function get_reference() to authenticated;

commit;
