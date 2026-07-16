-- MINUTO 4 · F1 — RACHA ALCANZABLE EL DÍA 1 (rampa de meta diaria).
-- Viene de USO REAL, no de una cola: @eugenio (primer usuario que no es Gian)
-- completó 1 lección (17 XP) contra una meta de 45 XP (eligió 45 min/día) ->
-- racha imposible el día 1 -> no volvió a aprender.
-- Recreada 1:1 desde la definición viva + SOLO el cálculo de v_goal.
-- NO toca: XP/oro, el resto de la racha, congelador, hitos, ni daily_minutes
-- (=> estimation.dart y la fecha del plan quedan igual).

CREATE OR REPLACE FUNCTION public.jz_register_activity(p_uid uuid, p_course uuid, p_xp integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_min int;
  v_goal int;
  v_earned int;
  v_met boolean;
  v_streak int; v_longest int; v_last date;
  v_freezes int; v_missed int; v_freeze_used int := 0;
  v_adv boolean := false;
  v_milestone int := 0;
  v_bonus int := 0;
  v_lost int := null;                 -- T4: racha que se pierde en este reset
  v_full int;                         -- meta comprometida (min/día)
  v_prev_days int;                    -- días activos ANTERIORES a hoy
  v_dayn int;                         -- 1 = primer día activo
begin
  select daily_minutes into v_min
  from user_plans where user_id = p_uid and course_id = p_course;
  -- Meta COMPROMETIDA por el usuario en el onboarding (min/día -> XP).
  v_full := greatest(10, coalesce(v_min, 30));

  -- ── RAMPA DE ARRANQUE (evidencia de uso real: @eugenio, 2026-07-16) ────────
  -- El primer usuario real eligió 45 min/día -> meta 45 XP. Una lección da
  -- ~10-31 XP (xp_reward 15 * accuracy + combo) -> su lección al 75% dio 17 ->
  -- necesitaba ~3 lecciones SEGUIDAS para su primera racha. Hizo 1. Racha 0, y
  -- no volvió a aprender. La primera victoria es la que retiene.
  -- Ahora la meta ARRANCA SUAVE y sube a la comprometida en unos días:
  --   día 1 = goal_ramp_first_xp (15 = una lección) -> 1 lección decente YA cuenta
  --   +goal_ramp_step_xp por día activo, hasta la meta real (nunca la supera).
  -- La meta del usuario NO se toca (sigue siendo la suya): solo se escalona el
  -- arranque. `user_plans.daily_minutes` queda intacto -> estimation.dart y la
  -- fecha del plan NO cambian.
  select count(*) into v_prev_days
  from daily_goals where user_id = p_uid and goal_date < current_date;
  v_dayn := coalesce(v_prev_days, 0) + 1;            -- 1 = primer día activo

  if v_dayn <= jz_cfg('goal_ramp_days', 3) then
    v_goal := least(v_full,
      jz_cfg('goal_ramp_first_xp', 15) + (v_dayn - 1) * jz_cfg('goal_ramp_step_xp', 10));
  else
    v_goal := v_full;
  end if;

  insert into daily_goals (user_id, goal_date, goal_xp, xp_earned)
  values (p_uid, current_date, v_goal, p_xp)
  on conflict (user_id, goal_date) do update
    set xp_earned = daily_goals.xp_earned + excluded.xp_earned, updated_at = now()
  returning xp_earned, goal_xp into v_earned, v_goal;

  v_met := v_earned >= v_goal;

  select current_streak, longest_streak, last_active_date, freezes_available
    into v_streak, v_longest, v_last, v_freezes
  from streaks where user_id = p_uid for update;

  if v_met and (v_last is null or v_last < current_date) then
    if v_last = current_date - 1 then
      v_streak := coalesce(v_streak, 0) + 1;
    elsif v_last is null then
      v_streak := 1;
    else
      v_missed := (current_date - v_last) - 1;
      if coalesce(v_freezes, 0) >= v_missed then
        v_freeze_used := v_missed;
        v_streak := coalesce(v_streak, 0) + 1;
      else
        -- Reset SIN congeladores suficientes → registra la pérdida (revivible).
        if coalesce(v_streak, 0) >= 2 then v_lost := v_streak; end if;
        v_streak := 1;
      end if;
    end if;
    v_longest := greatest(coalesce(v_longest, 0), v_streak);
    update streaks set current_streak = v_streak, longest_streak = v_longest,
                       last_active_date = current_date,
                       freezes_available = greatest(0, coalesce(freezes_available, 0) - v_freeze_used),
                       lost_streak = case when v_lost is not null then v_lost else lost_streak end,
                       lost_at = case when v_lost is not null then now() else lost_at end,
                       updated_at = now()
     where user_id = p_uid;
    v_adv := true;

    if v_streak in (7, 30, 100, 365) then
      v_milestone := v_streak;
      v_bonus := case v_streak when 7 then 50 when 30 then 100
                               when 100 then 250 else 500 end;
      update user_stats set gold = gold + v_bonus, updated_at = now()
       where user_id = p_uid;
      insert into gold_transactions (user_id, amount, reason)
      values (p_uid, v_bonus, 'challenge');
    end if;
  end if;

  return jsonb_build_object(
    'goal_xp', v_goal,
    'xp_earned_today', v_earned,
    'goal_met', v_met,
    'streak', coalesce(v_streak, 0),
    'longest_streak', coalesce(v_longest, 0),
    'streak_advanced', v_adv,
    'freeze_used', v_freeze_used,
    'freezes_available', coalesce(v_freezes, 0) - v_freeze_used,
    'milestone', v_milestone,
    'milestone_bonus', v_bonus);
end $function$
;

-- Parámetros de la rampa en jz_config (key + value_int) — NO hardcodeados.
--   goal_ramp_first_xp = 15  -> exactamente el xp_reward de UNA lección: una
--                              lección decente (17-31 XP) gana la racha el día 1.
--   goal_ramp_step_xp  = 10  -> día2 +10, día3 +20… hasta la meta comprometida.
--   goal_ramp_days     = 3   -> a partir del 4º día activo rige su meta real.
-- Ej. 45 min/día: 15 -> 25 -> 35 -> 45.   20 min/día: 15 -> 20 -> 20.
insert into public.jz_config(key, value_int) values
  ('goal_ramp_first_xp', 15),
  ('goal_ramp_step_xp', 10),
  ('goal_ramp_days', 3)
on conflict (key) do nothing;
