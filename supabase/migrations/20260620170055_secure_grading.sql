-- ============================================================================
-- Jezici · Migración 055 · Grading server-side (cierra el vector correct_answer)
-- El cliente ya no puede leer content_items.correct_answer; califica vía
-- grade_item (RPC SECURITY DEFINER) que revela la respuesta SOLO tras responder.
-- ============================================================================
begin;

create or replace function grade_item(p_item_id uuid, p_answer jsonb)
returns jsonb language plpgsql security definer set search_path = public as $fn$
declare uid uuid := auth.uid(); v_type content_item_type; v_correct jsonb; v_word text;
begin
  if uid is null then raise exception 'auth required'; end if;
  select type, correct_answer into v_type, v_correct from content_items where id = p_item_id;
  if found then
    return jsonb_build_object('correct', jz_grade(v_type, v_correct, p_answer),
      'graded', not jz_is_stub(v_type), 'expected', v_correct);
  end if;
  -- Fallback: ítem sintético de SRS (el id es de vocabulary).
  select word into v_word from vocabulary where id = p_item_id;
  if found then
    return jsonb_build_object('correct', jz_normalize(p_answer #>> '{}') = jz_normalize(v_word),
      'graded', true, 'expected', jsonb_build_object('value', v_word));
  end if;
  return jsonb_build_object('correct', false, 'graded', false, 'expected', null);
end $fn$;
grant execute on function grade_item(uuid, jsonb) to authenticated;

-- start_practice sin devolver correct_answer:
CREATE OR REPLACE FUNCTION public.start_practice(p_mode text, p_skill text DEFAULT NULL::text, p_unit uuid DEFAULT NULL::uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare uid uuid := auth.uid(); v_course uuid; v_weak skill; v_items jsonb; v_due int := 0;
begin
  if uid is null then raise exception 'auth required'; end if;
  select jz_active_course() into v_course;

  if p_mode = 'srs' then
    with due as (
      select v.id, v.word, v.translation, (s.vocab_id is null) as isnew, s.due_at
      from vocabulary v left join user_vocab_srs s on s.vocab_id = v.id and s.user_id = uid
      where v.course_id = v_course and (s.vocab_id is null or s.due_at is null or s.due_at <= now())
      order by (s.vocab_id is not null), coalesce(s.due_at, to_timestamp(0)), v.frequency_rank limit 12)
    select jsonb_agg(jsonb_build_object('id', d.id, 'type', 'multiple_choice', 'skill', 'reading', 'cefr_level', 'A1',
             'prompt', '¿Cómo se dice «' || d.translation || '»?', 'payload', jsonb_build_object('options', o.options))) into v_items
    from due d cross join lateral (select jsonb_agg(w order by random()) as options from
      ((select d.word as w) union all (select v2.word from vocabulary v2 where v2.course_id = v_course and v2.word <> d.word order by random() limit 3)) q) o;
    select count(*) into v_due from vocabulary v left join user_vocab_srs s on s.vocab_id = v.id and s.user_id = uid
      where v.course_id = v_course and (s.vocab_id is null or s.due_at is null or s.due_at <= now());

  elsif p_mode in ('reinforce', 'reinforce_unit') then
    -- Ítems calificables de MAYOR necesidad de refuerzo (intentados, no stub), del
    -- curso (y unidad/skill si se piden). Re-evalúa lo que más lo necesita.
    select jsonb_agg(jsonb_build_object('id', x.id, 'type', x.type, 'skill', x.skill, 'cefr_level', x.cefr_level,
             'prompt', x.prompt, 'payload', x.payload)) into v_items
    from (
      select ci.id, ci.type, ci.skill, ci.cefr_level, ci.prompt, ci.payload, ci.correct_answer,
             jz_item_reinforce(uid, ci.id) score
      from content_items ci join user_item_attempts ua on ua.item_id = ci.id and ua.user_id = uid
      where ci.course_id = v_course and not jz_is_stub(ci.type)
        and (p_skill is null or ci.skill = p_skill::skill)
        and (p_unit is null or exists (select 1 from lesson_items li join lessons l on l.id = li.lesson_id
                                       where li.item_id = ci.id and l.unit_id = p_unit))
      order by jz_item_reinforce(uid, ci.id) desc nulls last, random() limit 12) x;

  else
    if p_mode = 'weakness' then
      select s.skill::skill into v_weak from unnest(array['reading','listening','writing','speaking']) s(skill)
      order by jz_reinforce_score(uid, v_course, s.skill::skill) desc,
               array_position(array['reading','listening','writing','speaking'], s.skill) limit 1;
    end if;
    select jsonb_agg(jsonb_build_object('id', id, 'type', type, 'skill', skill, 'cefr_level', cefr_level,
             'prompt', prompt, 'payload', payload)) into v_items
    from (select id, type, skill, cefr_level, prompt, payload, correct_answer from content_items
          where course_id = v_course and not ('placement' = any(tags))
            and case when p_mode = 'weakness' then skill = v_weak
                     when p_mode = 'skill' then skill = p_skill::skill
                     when p_mode = 'timed' then type not in ('listening','speaking_read_aloud','dictation','guided_writing')
                     else true end
          order by random() limit case when p_mode = 'timed' then 20 else 10 end) x;
  end if;

  return jsonb_build_object('mode', p_mode, 'weakest_skill', v_weak, 'due_count', v_due,
    'item_count', coalesce(jsonb_array_length(v_items), 0), 'items', coalesce(v_items, '[]'::jsonb));
end $function$
;

-- Revoca la columna correct_answer al cliente (grant del resto):
revoke select on content_items from anon, authenticated;
grant select (id, course_id, cefr_level, skill, type, prompt, payload, difficulty, irt_a, irt_b, tags, created_at, updated_at) on content_items to anon, authenticated;

commit;
