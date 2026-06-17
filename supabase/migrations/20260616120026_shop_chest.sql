-- ============================================================================
-- Jezici · Migración 026 · Tienda + cofre diario (Diseno_Gamificacion §economía)
-- ----------------------------------------------------------------------------
-- Gasto/recompensa de oro, server-side (el cliente nunca mueve el saldo):
--   · open_daily_chest: recompensa variable de oro, una vez al día.
--   · buy_hearts: recargar vidas a 5 (cuesta oro).
--   · shop_status: estado para la pantalla de Tienda.
-- (use_streak_freeze ya existe en la migración 018.)
-- ============================================================================

create or replace function shop_status()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare uid uuid := auth.uid(); v_gold int; v_hearts int; v_freezes int; v_chest boolean;
begin
  if uid is null then raise exception 'auth required'; end if;
  select gold, hearts into v_gold, v_hearts from user_stats where user_id = uid;
  select coalesce(freezes_available, 0) into v_freezes from streaks where user_id = uid;
  select not exists(select 1 from chest_openings where user_id = uid and opened_at::date = current_date)
    into v_chest;
  return jsonb_build_object('gold', coalesce(v_gold,0), 'hearts', coalesce(v_hearts,5),
    'freezes', coalesce(v_freezes,0), 'chest_available', coalesce(v_chest,true));
end $$;

create or replace function open_daily_chest()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare uid uuid := auth.uid(); v_reward int; v_gold int;
begin
  if uid is null then raise exception 'auth required'; end if;
  if exists(select 1 from chest_openings where user_id = uid and opened_at::date = current_date) then
    return jsonb_build_object('ok', false, 'reason', 'already_opened');
  end if;
  -- Recompensa variable: 10..100 oro en pasos de 5.
  v_reward := (2 + floor(random() * 19))::int * 5;
  insert into user_stats (user_id) values (uid) on conflict (user_id) do nothing;
  update user_stats set gold = gold + v_reward, updated_at = now() where user_id = uid returning gold into v_gold;
  insert into gold_transactions (user_id, amount, reason) values (uid, v_reward, 'challenge');
  insert into chest_openings (user_id, reward_type, reward_amount) values (uid, 'gold', v_reward);
  return jsonb_build_object('ok', true, 'reward', v_reward, 'gold', v_gold);
end $$;

create or replace function buy_hearts()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare uid uuid := auth.uid(); v_gold int; v_cost int := 50;
begin
  if uid is null then raise exception 'auth required'; end if;
  select gold into v_gold from user_stats where user_id = uid for update;
  if coalesce(v_gold,0) < v_cost then
    return jsonb_build_object('ok', false, 'reason', 'insufficient_gold', 'gold', coalesce(v_gold,0));
  end if;
  update user_stats set gold = gold - v_cost, hearts = 5, hearts_updated_at = now(), updated_at = now()
   where user_id = uid returning gold into v_gold;
  insert into gold_transactions (user_id, amount, reason) values (uid, -v_cost, 'heart_refill');
  return jsonb_build_object('ok', true, 'gold', v_gold, 'hearts', 5);
end $$;

grant execute on function shop_status() to authenticated;
grant execute on function open_daily_chest() to authenticated;
grant execute on function buy_hearts() to authenticated;
