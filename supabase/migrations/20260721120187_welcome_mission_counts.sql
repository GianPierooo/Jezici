-- MISIÓN DE BIENVENIDA: su XP ya CUENTA para la meta diaria y la racha.
-- Pendiente conocido del checklist: los +25 XP/oro se pagaban pero NO pasaban por
-- jz_register_activity, así que un usuario nuevo veía XP que no le movía nada
-- (Gian: 25 XP y 0 filas en daily_goals). Cuerpo VERBATIM de la definición viva;
-- el ÚNICO cambio es la llamada a jz_register_activity con el XP ya pagado.
-- NO duplica recompensas: esa función escribe daily_goals y avanza la racha, no
-- paga XP (cada RPC paga el suyo). Sigue siendo one-time (dentro de `if v_first`).
-- NO toca el scheduler FSRS, el gating ni la certificación.

CREATE OR REPLACE FUNCTION public.complete_mission(p_lesson_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  uid uuid := auth.uid(); v_course uuid; v_unit uuid; v_order int; v_next uuid;
  v_prev lesson_progress_status; v_first boolean;
  v_xp int := 0; v_gold int := 0; v_activity jsonb := null;
begin
  if uid is null then raise exception 'auth required'; end if;
  select u.course_id, l.unit_id, l.order_index into v_course, v_unit, v_order
  from lessons l join units u on u.id = l.unit_id where l.id = p_lesson_id;
  if v_course is null then raise exception 'lesson not found'; end if;

  -- ¿Primera vez? (para el bono de bienvenida one-time)
  select status into v_prev from user_lesson_progress
   where user_id = uid and lesson_id = p_lesson_id;
  v_first := v_prev is null or v_prev not in ('completed', 'golden');

  insert into user_lesson_progress (user_id, lesson_id, status, completed_at)
  values (uid, p_lesson_id, 'completed', now())
  on conflict (user_id, lesson_id) do update
    set status = case when user_lesson_progress.status in ('completed', 'golden') then user_lesson_progress.status else 'completed' end,
        completed_at = now();

  -- Bono de bienvenida (solo la 1ª vez): premia arrancar el viaje. NO toca
  -- daily_goals/racha (esas empiezan con la 1ª lección real).
  if v_first then
    v_xp := 25; v_gold := 25;
    update user_course_progress set xp_total = xp_total + v_xp, updated_at = now()
     where user_id = uid and course_id = v_course;
    update user_stats set xp_total = xp_total + v_xp, gold = gold + v_gold, updated_at = now()
     where user_id = uid;
    insert into gold_transactions (user_id, amount, reason) values (uid, v_gold, 'challenge');
    -- El XP de la misión CUENTA para la meta del día y la racha, igual que el de
    -- una lección. jz_register_activity NO paga XP (eso ya se hizo arriba): solo
    -- registra la actividad, así que no hay doble recompensa.
    v_activity := jz_register_activity(uid, v_course, v_xp);
  end if;

  select id into v_next from lessons where unit_id = v_unit and order_index > v_order order by order_index limit 1;
  if v_next is null then
    select l.id into v_next from lessons l join units u on u.id = l.unit_id
     where u.course_id = v_course and u.order_index > (select order_index from units where id = v_unit)
     order by u.order_index, l.order_index limit 1;
  end if;
  if v_next is not null then
    insert into user_lesson_progress (user_id, lesson_id, status) values (uid, v_next, 'available')
    on conflict (user_id, lesson_id) do update
      set status = case when user_lesson_progress.status in ('completed', 'golden') then user_lesson_progress.status else 'available' end;
    update user_course_progress set current_lesson_id = v_next where user_id = uid and course_id = v_course;
  end if;

  return jsonb_build_object(
    'ok', true,
    'next_lesson_id', v_next,
    'first_time', v_first,
    'xp_earned', v_xp,
    'gold_earned', v_gold,
    'gold_total', (select gold from user_stats where user_id = uid),
    'xp_total', (select xp_total from user_stats where user_id = uid),
    'activity', v_activity);
end $function$
;
