-- ═══════════════════════════════════════════════════════════════════════════
-- T4 (2/2) — notificaciones completas + push + vidas con REGENERACIÓN real +
-- oro con más usos (revivir racha).  (mig 151, 2026-07-12)
--
-- Decisiones de Gian (firmes): CONGELADOR preventivo SE QUEDA como está;
-- se AÑADE revivir racha perdida — CARO y LIMITADO (rescate excepcional).
-- PASO 0 honesto: las vidas HOY no se regeneran (hearts_updated_at nunca se
-- leía para sumar; la lección usa vidas locales) → aquí la regeneración se
-- CONSTRUYE de verdad server-side (el timer del cliente ya no es una promesa).
-- Economía SIEMPRE server-side y auditable (gold_transactions); precios en
-- CONFIG, no hardcode disperso.
-- ═══════════════════════════════════════════════════════════════════════════

-- ─────────────────────────────────────────────────────────────────────────────
-- 0) CONFIG de economía (una sola fuente de precios/parámetros)
-- ─────────────────────────────────────────────────────────────────────────────
create table if not exists public.jz_config (
  key text primary key,
  value_int integer not null,
  updated_at timestamptz not null default now()
);
alter table public.jz_config enable row level security;
revoke all on public.jz_config from anon, authenticated;
-- (sin políticas: solo la leen las funciones DEFINER)

insert into public.jz_config (key, value_int) values
  ('heart_refill_cost', 50),     -- recargar todas las vidas (precio actual, sin cambio)
  ('freeze_cost', 50),           -- congelador preventivo (precio actual, sin cambio)
  ('hearts_max', 5),
  ('heart_regen_minutes', 30),   -- 1 vida cada 30 min
  ('revive_cost', 300),          -- revivir racha: CARO (6× una recarga)
  ('revive_cap_days', 30),       -- LIMITADO: 1 vez por 30 días
  ('revive_window_days', 7),     -- solo rachas perdidas hace ≤7 días
  ('revive_min_streak', 3)       -- no vale la pena revivir rachas de 1-2 días
on conflict (key) do nothing;

create or replace function public.jz_cfg(p_key text, p_default int)
returns int language sql stable security definer set search_path to 'public' as $$
  select coalesce((select value_int from jz_config where key = p_key), p_default);
$$;
revoke execute on function public.jz_cfg(text, int) from public, anon, authenticated;

-- ─────────────────────────────────────────────────────────────────────────────
-- 1) VIDAS con regeneración REAL (lazy tick: 1 vida / regen_minutes hasta max)
-- ─────────────────────────────────────────────────────────────────────────────
create or replace function public.jz_hearts_tick(p_uid uuid)
returns void language plpgsql security definer set search_path to 'public' as $$
declare v_h int; v_at timestamptz; v_max int; v_regen int; v_gain int;
begin
  v_max := jz_cfg('hearts_max', 5);
  v_regen := jz_cfg('heart_regen_minutes', 30);
  select hearts, hearts_updated_at into v_h, v_at
    from user_stats where user_id = p_uid for update;
  if v_h is null then return; end if;
  if v_h >= v_max then return; end if;
  v_gain := floor(extract(epoch from (now() - coalesce(v_at, now()))) / (v_regen * 60))::int;
  if v_gain <= 0 then return; end if;
  update user_stats set
    hearts = least(v_max, v_h + v_gain),
    -- ancla exacta: avanza por los intervalos consumidos (no "ahora"), para que
    -- la cuenta regresiva de la siguiente vida sea precisa; al llenarse, ancla now().
    hearts_updated_at = case when v_h + v_gain >= v_max then now()
                             else coalesce(v_at, now()) + (v_gain * v_regen || ' minutes')::interval end,
    updated_at = now()
  where user_id = p_uid;
end $$;
revoke execute on function public.jz_hearts_tick(uuid) from public, anon, authenticated;

-- Estado de vidas: {hearts, max, seconds_to_next, refill_cost}.
create or replace function public.get_hearts()
returns jsonb language plpgsql security definer set search_path to 'public' as $$
declare uid uuid := auth.uid(); v_h int; v_at timestamptz; v_max int; v_regen int; v_next int;
begin
  if uid is null then raise exception 'auth required'; end if;
  insert into user_stats (user_id) values (uid) on conflict (user_id) do nothing;
  perform jz_hearts_tick(uid);
  v_max := jz_cfg('hearts_max', 5);
  v_regen := jz_cfg('heart_regen_minutes', 30);
  select hearts, hearts_updated_at into v_h, v_at from user_stats where user_id = uid;
  if v_h >= v_max then v_next := null;
  else v_next := greatest(0, (v_regen * 60) -
         floor(extract(epoch from (now() - coalesce(v_at, now()))))::int);
  end if;
  return jsonb_build_object('hearts', v_h, 'max', v_max,
    'seconds_to_next', v_next, 'refill_cost', jz_cfg('heart_refill_cost', 50));
end $$;
grant execute on function public.get_hearts() to authenticated;

-- Perder una vida (fallo en lección). El cliente lo reporta best-effort — las
-- vidas gatean solo la UX; XP/dominio siguen 100% server-side por grade_item.
create or replace function public.lose_heart()
returns jsonb language plpgsql security definer set search_path to 'public' as $$
declare uid uuid := auth.uid(); v_h int; v_max int;
begin
  if uid is null then raise exception 'auth required'; end if;
  insert into user_stats (user_id) values (uid) on conflict (user_id) do nothing;
  perform jz_hearts_tick(uid);
  v_max := jz_cfg('hearts_max', 5);
  select hearts into v_h from user_stats where user_id = uid for update;
  if v_h > 0 then
    update user_stats set hearts = v_h - 1,
      -- al bajar DESDE lleno arranca el reloj de regeneración
      hearts_updated_at = case when v_h >= v_max then now() else hearts_updated_at end,
      updated_at = now()
    where user_id = uid;
  end if;
  return get_hearts();
end $$;
grant execute on function public.lose_heart() to authenticated;

-- buy_hearts: mismo comportamiento, precio desde CONFIG (sigue 50).
create or replace function public.buy_hearts()
returns jsonb language plpgsql security definer set search_path to 'public' as $$
declare uid uuid := auth.uid(); v_gold int; v_cost int; v_max int;
begin
  if uid is null then raise exception 'auth required'; end if;
  v_cost := jz_cfg('heart_refill_cost', 50);
  v_max := jz_cfg('hearts_max', 5);
  select gold into v_gold from user_stats where user_id = uid for update;
  if coalesce(v_gold,0) < v_cost then
    return jsonb_build_object('ok', false, 'reason', 'insufficient_gold', 'gold', coalesce(v_gold,0));
  end if;
  update user_stats set gold = gold - v_cost, hearts = v_max, hearts_updated_at = now(), updated_at = now()
   where user_id = uid returning gold into v_gold;
  insert into gold_transactions (user_id, amount, reason) values (uid, -v_cost, 'heart_refill');
  return jsonb_build_object('ok', true, 'gold', v_gold, 'hearts', v_max);
end $$;

-- use_streak_freeze: mismo comportamiento, precio desde CONFIG (sigue 50).
create or replace function public.use_streak_freeze()
returns jsonb language plpgsql security definer set search_path to 'public' as $$
declare uid uuid := auth.uid(); v_gold int; v_freezes int; v_cost int;
begin
  if uid is null then raise exception 'auth required'; end if;
  v_cost := jz_cfg('freeze_cost', 50);
  select gold into v_gold from user_stats where user_id = uid for update;
  if coalesce(v_gold, 0) < v_cost then
    return jsonb_build_object('ok', false, 'reason', 'insufficient_gold',
                              'gold', coalesce(v_gold, 0), 'cost', v_cost);
  end if;
  update user_stats set gold = gold - v_cost, updated_at = now()
   where user_id = uid returning gold into v_gold;
  insert into gold_transactions (user_id, amount, reason) values (uid, -v_cost, 'freeze');
  update streaks set freezes_available = freezes_available + 1, updated_at = now()
   where user_id = uid returning freezes_available into v_freezes;
  return jsonb_build_object('ok', true, 'gold', v_gold,
                            'freezes_available', coalesce(v_freezes, 0));
end $$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 2) REVIVIR RACHA perdida (caro + limitado; el congelador preventivo intacto)
-- ─────────────────────────────────────────────────────────────────────────────
alter table public.streaks add column if not exists lost_streak integer;
alter table public.streaks add column if not exists lost_at timestamptz;

-- jz_register_activity: MISMO comportamiento + al RESETEAR por hueco graba la
-- racha perdida (lost_streak/lost_at) para poder revivirla. Congelador intacto.
create or replace function public.jz_register_activity(p_uid uuid, p_course uuid, p_xp integer)
returns jsonb language plpgsql security definer set search_path to 'public' as $$
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
begin
  select daily_minutes into v_min
  from user_plans where user_id = p_uid and course_id = p_course;
  v_goal := greatest(10, coalesce(v_min, 30));

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
end $$;

-- Estado del rescate (para la tarjeta del cliente): NO cobra nada.
create or replace function public.streak_revive_status()
returns jsonb language plpgsql security definer set search_path to 'public' as $$
declare uid uuid := auth.uid(); v streaks%rowtype; v_cost int; v_win int; v_cap int; v_min int;
        v_used boolean; v_gold int; v_left int;
begin
  if uid is null then raise exception 'auth required'; end if;
  v_cost := jz_cfg('revive_cost', 300);
  v_win := jz_cfg('revive_window_days', 7);
  v_cap := jz_cfg('revive_cap_days', 30);
  v_min := jz_cfg('revive_min_streak', 3);
  select * into v from streaks where user_id = uid;
  select gold into v_gold from user_stats where user_id = uid;
  v_used := exists (select 1 from gold_transactions
    where user_id = uid and reason = 'streak_revive'
      and created_at > now() - (v_cap || ' days')::interval);
  v_left := case when v.lost_at is null then 0
    else greatest(0, floor(extract(epoch from (v.lost_at + (v_win || ' days')::interval - now())) / 86400)::int) end;
  return jsonb_build_object(
    'available', (coalesce(v.lost_streak, 0) >= v_min
                  and v.lost_at is not null
                  and v.lost_at > now() - (v_win || ' days')::interval
                  and not v_used),
    'lost_streak', coalesce(v.lost_streak, 0),
    'cost', v_cost,
    'days_left', v_left,
    'used_this_period', v_used,
    'gold', coalesce(v_gold, 0));
end $$;
grant execute on function public.streak_revive_status() to authenticated;

-- REVIVIR: cobra oro (config), tope 1/periodo, ventana limitada, mínimo de días.
-- Framing de rescate excepcional: que perder la racha siga doliendo.
create or replace function public.revive_streak()
returns jsonb language plpgsql security definer set search_path to 'public' as $$
declare uid uuid := auth.uid(); v streaks%rowtype; v_cost int; v_win int; v_cap int; v_min int;
        v_gold int; v_new int;
begin
  if uid is null then raise exception 'auth required'; end if;
  v_cost := jz_cfg('revive_cost', 300);
  v_win := jz_cfg('revive_window_days', 7);
  v_cap := jz_cfg('revive_cap_days', 30);
  v_min := jz_cfg('revive_min_streak', 3);
  select * into v from streaks where user_id = uid for update;
  if coalesce(v.lost_streak, 0) < v_min or v.lost_at is null then
    return jsonb_build_object('ok', false, 'reason', 'nothing_to_revive');
  end if;
  if v.lost_at <= now() - (v_win || ' days')::interval then
    return jsonb_build_object('ok', false, 'reason', 'expired');
  end if;
  if exists (select 1 from gold_transactions
             where user_id = uid and reason = 'streak_revive'
               and created_at > now() - (v_cap || ' days')::interval) then
    return jsonb_build_object('ok', false, 'reason', 'limit_reached');
  end if;
  select gold into v_gold from user_stats where user_id = uid for update;
  if coalesce(v_gold, 0) < v_cost then
    return jsonb_build_object('ok', false, 'reason', 'insufficient_gold',
                              'gold', coalesce(v_gold, 0), 'cost', v_cost);
  end if;
  update user_stats set gold = gold - v_cost, updated_at = now()
   where user_id = uid returning gold into v_gold;
  insert into gold_transactions (user_id, amount, reason) values (uid, -v_cost, 'streak_revive');
  -- La racha revivida SE SUMA a la racha actual (los días de la nueva corrida
  -- tras la pérdida cuentan) y se limpia el registro de pérdida.
  v_new := coalesce(v.current_streak, 0) + v.lost_streak;
  update streaks set current_streak = v_new,
                     longest_streak = greatest(coalesce(longest_streak, 0), v_new),
                     lost_streak = null, lost_at = null, updated_at = now()
   where user_id = uid;
  return jsonb_build_object('ok', true, 'streak', v_new, 'gold', v_gold, 'cost', v_cost);
end $$;
grant execute on function public.revive_streak() to authenticated;

-- ─────────────────────────────────────────────────────────────────────────────
-- 3) MATIX — locale + {motivo} + nuevos triggers + tracking de push
-- ─────────────────────────────────────────────────────────────────────────────
alter table public.notifications add column if not exists pushed_at timestamptz;
alter table public.notification_templates add column if not exists locale text not null default 'es';

-- matix_fire ahora recibe el locale de la app del usuario (default es).
-- DROP de la firma vieja para evitar overload ambiguo en PostgREST.
drop function if exists public.matix_fire(notification_trigger);
create or replace function public.matix_fire(p_trigger notification_trigger, p_locale text default 'es')
returns jsonb language plpgsql security definer set search_path to 'public' as $$
declare
  uid uuid := auth.uid();
  v_style coach_style;
  v_push boolean;
  v_qs time; v_qe time;
  v_max int; v_total int; v_today int; v_step int;
  v_tid uuid; v_copy text;
  v_status notification_status;
  v_reason text;
  v_streak int := 0; v_earned int := 0; v_goal int := 0; v_now time;
  v_loc text; v_motive text; v_motive_txt text;
begin
  if uid is null then raise exception 'auth required'; end if;
  v_loc := case when p_locale in ('es','en','pt') then p_locale else 'es' end;

  select coach_style, push_enabled, quiet_hours_start, quiet_hours_end
    into v_style, v_push, v_qs, v_qe
  from user_personality where user_id = uid;
  if v_style is null then v_style := 'suave'; v_push := true; end if;

  select coalesce(max(escalation_step), 1) into v_max
  from notification_templates
  where coach_style = v_style and trigger_type = p_trigger and channel = 'push';
  select count(*) into v_total
  from notifications where user_id = uid and trigger_type = p_trigger;
  select count(*) into v_today
  from notifications
  where user_id = uid and trigger_type = p_trigger and created_at::date = current_date;
  v_step := least(v_total + 1, greatest(v_max, 1));

  -- Plantilla: preferir el locale del usuario; fallback a es.
  select id, copy into v_tid, v_copy
  from notification_templates
  where coach_style = v_style and trigger_type = p_trigger
        and escalation_step = v_step and channel = 'push'
        and locale in (v_loc, 'es')
  order by (locale = v_loc) desc
  limit 1;
  if v_copy is null then
    select id, copy, escalation_step into v_tid, v_copy, v_step
    from notification_templates
    where coach_style = v_style and trigger_type = p_trigger and channel = 'push'
          and locale in (v_loc, 'es')
    order by (locale = v_loc) desc, escalation_step limit 1;
  end if;

  -- Variables del copy.
  select current_streak into v_streak from streaks where user_id = uid;
  select xp_earned, goal_xp into v_earned, v_goal
  from daily_goals where user_id = uid and goal_date = current_date;
  -- {motivo}: el MOTIVO real del plan del curso activo (atraso ligado al porqué).
  -- jz_active_course() no recibe args (usa auth.uid() internamente).
  select motive into v_motive from user_plans
   where user_id = uid and course_id = jz_active_course();
  v_motive_txt := case v_loc
    when 'en' then case coalesce(v_motive, '')
      when 'Examen' then 'your exam' when 'Estudios' then 'your studies'
      when 'Trabajo' then 'your work' else 'your goal' end
    when 'pt' then case coalesce(v_motive, '')
      when 'Examen' then 'sua prova' when 'Estudios' then 'seus estudos'
      when 'Trabajo' then 'seu trabalho' else 'sua meta' end
    else case coalesce(v_motive, '')
      when 'Examen' then 'tu examen' when 'Estudios' then 'tus estudios'
      when 'Trabajo' then 'tu trabajo' else 'tu meta' end
    end;
  if v_copy is not null then
    v_copy := replace(v_copy, '{dias}', coalesce(v_streak, 0)::text);
    v_copy := replace(v_copy, '{x}', coalesce(v_earned, 0)::text);
    v_copy := replace(v_copy, '{meta}', coalesce(v_goal, 0)::text);
    v_copy := replace(v_copy, '{motivo}', v_motive_txt);
    v_copy := replace(v_copy, '{logro}',
      case v_loc when 'en' then 'an achievement' when 'pt' then 'uma conquista' else 'un logro' end);
  end if;

  v_now := current_time::time;
  if not coalesce(v_push, true) then
    v_status := 'suppressed'; v_reason := 'push_off';
  elsif v_today >= 1 then
    v_status := 'suppressed'; v_reason := 'capped';
  elsif v_qs is not null and v_qe is not null and
        ((v_qs <= v_qe and v_now >= v_qs and v_now < v_qe) or
         (v_qs >  v_qe and (v_now >= v_qs or v_now < v_qe))) then
    v_status := 'suppressed'; v_reason := 'quiet_hours';
  else
    v_status := 'sent'; v_reason := 'ok';
  end if;

  insert into notifications (user_id, channel, trigger_type, template_id, escalation_step,
                             scheduled_at, sent_at, status, body)
  values (uid, 'push', p_trigger, v_tid, v_step, now(),
          case when v_status = 'sent' then now() else null end, v_status, v_copy);

  return jsonb_build_object(
    'status', v_status,
    'reason', v_reason,
    'copy', v_copy,
    'coach_style', v_style,
    'escalation_step', v_step,
    'trigger', p_trigger,
    'channel', 'push');
end $$;
grant execute on function public.matix_fire(notification_trigger, text) to authenticated;

-- El copy hardcodeaba "inglés" (la app es multi-curso) → neutro.
update notification_templates
  set copy = '{dias} días fuera. Tu idioma no avanza solo. Vuelve.'
  where trigger_type = 'winback' and coach_style = 'mano_dura'
    and escalation_step = 1 and channel = 'push' and locale = 'es'
    and copy like '%inglés%';

-- behind_plan (es) ligado al MOTIVO del usuario.
update notification_templates set copy = 'Vas atrás de tu plan y {motivo} no espera. Sube el ritmo.'
  where trigger_type='behind_plan' and coach_style='mano_dura' and channel='push' and locale='es';
update notification_templates set copy = 'Un empujón y vuelves a tu ritmo — {motivo} lo vale 💪'
  where trigger_type='behind_plan' and coach_style='positivo' and channel='push' and locale='es';
update notification_templates set copy = 'Vas atrás de tu plan, y {motivo} se acerca.'
  where trigger_type='behind_plan' and coach_style='rezago' and channel='push' and locale='es';
update notification_templates set copy = 'Si subes un poco el ritmo, llegas a tiempo para {motivo} 🙂'
  where trigger_type='behind_plan' and coach_style='suave' and channel='push' and locale='es';

-- ─────────────────────────────────────────────────────────────────────────────
-- 4) PLANTILLAS: goal_met + hearts_out (es) y TODO el banco push en en/pt
-- ─────────────────────────────────────────────────────────────────────────────
-- La unicidad vieja no conocía locale → se amplía (mismo copy por locale).
alter table public.notification_templates
  drop constraint if exists notification_templates_coach_style_trigger_type_escalation__key;
create unique index if not exists notification_templates_style_trig_step_chan_loc_uk
  on public.notification_templates (coach_style, trigger_type, escalation_step, channel, locale);

-- Idempotente: inserta solo si no existe (style, trigger, step, channel, locale).
create or replace function pg_temp.jz_tpl(p_style coach_style, p_trig notification_trigger,
    p_step int, p_loc text, p_copy text)
returns void language plpgsql as $$
begin
  insert into notification_templates (coach_style, trigger_type, escalation_step, channel, copy, locale)
  select p_style, p_trig, p_step, 'push', p_copy, p_loc
  where not exists (select 1 from notification_templates
    where coach_style = p_style and trigger_type = p_trig and escalation_step = p_step
      and channel = 'push' and locale = p_loc);
end $$;

-- goal_met (positivo por diseño; el estilo solo matiza el tono)
select pg_temp.jz_tpl('mano_dura','goal_met',1,'es','Meta de hoy cumplida. Así se hace. Mañana, igual.');
select pg_temp.jz_tpl('positivo','goal_met',1,'es','🎉 ¡Meta del día cumplida! Eres imparable.');
select pg_temp.jz_tpl('rezago','goal_met',1,'es','Meta de hoy: cumplida. Sigues en ritmo.');
select pg_temp.jz_tpl('suave','goal_met',1,'es','Meta de hoy lista 🙂 Buen trabajo.');
select pg_temp.jz_tpl('mano_dura','goal_met',1,'en','Today''s goal: done. That''s how it''s done. Same tomorrow.');
select pg_temp.jz_tpl('positivo','goal_met',1,'en','🎉 Daily goal complete! You''re unstoppable.');
select pg_temp.jz_tpl('rezago','goal_met',1,'en','Goal met. You''re keeping pace.');
select pg_temp.jz_tpl('suave','goal_met',1,'en','Today''s goal done 🙂 Nice work.');
select pg_temp.jz_tpl('mano_dura','goal_met',1,'pt','Meta de hoje cumprida. É assim que se faz. Amanhã, de novo.');
select pg_temp.jz_tpl('positivo','goal_met',1,'pt','🎉 Meta do dia cumprida! Você é imparável.');
select pg_temp.jz_tpl('rezago','goal_met',1,'pt','Meta cumprida. Você segue no ritmo.');
select pg_temp.jz_tpl('suave','goal_met',1,'pt','Meta de hoje pronta 🙂 Bom trabalho.');

-- hearts_out (vidas agotadas)
select pg_temp.jz_tpl('mano_dura','hearts_out',1,'es','Sin vidas. Respira, vuelve y hazlo mejor.');
select pg_temp.jz_tpl('positivo','hearts_out',1,'es','¡Sin vidas por ahora! Se recargan solas — vuelve en un rato 💜');
select pg_temp.jz_tpl('rezago','hearts_out',1,'es','Te quedaste sin vidas a mitad de lección. Recarga y termina.');
select pg_temp.jz_tpl('suave','hearts_out',1,'es','Sin vidas por ahora 🙂 Se recargan con el tiempo.');
select pg_temp.jz_tpl('mano_dura','hearts_out',1,'en','Out of hearts. Breathe, come back, do better.');
select pg_temp.jz_tpl('positivo','hearts_out',1,'en','Out of hearts for now! They refill on their own — come back soon 💜');
select pg_temp.jz_tpl('rezago','hearts_out',1,'en','You ran out of hearts mid-lesson. Refill and finish it.');
select pg_temp.jz_tpl('suave','hearts_out',1,'en','No hearts right now 🙂 They refill over time.');
select pg_temp.jz_tpl('mano_dura','hearts_out',1,'pt','Sem vidas. Respire, volte e faça melhor.');
select pg_temp.jz_tpl('positivo','hearts_out',1,'pt','Sem vidas por agora! Elas recarregam sozinhas — volte já já 💜');
select pg_temp.jz_tpl('rezago','hearts_out',1,'pt','Você ficou sem vidas no meio da lição. Recarregue e termine.');
select pg_temp.jz_tpl('suave','hearts_out',1,'pt','Sem vidas por agora 🙂 Elas recarregam com o tempo.');

-- streak_risk en
select pg_temp.jz_tpl('mano_dura','streak_risk',1,'en','Your streak is on the line. One lesson, now.');
select pg_temp.jz_tpl('positivo','streak_risk',1,'en','Don''t lose your streak! One quick lesson and you''re safe 🔥');
select pg_temp.jz_tpl('rezago','streak_risk',1,'en','Careful: your {dias}-day streak is at risk.');
select pg_temp.jz_tpl('suave','streak_risk',1,'en','When you can, a short lesson keeps your streak alive 🙂');
select pg_temp.jz_tpl('mano_dura','streak_risk',2,'en','{dias} days of streak. Don''t throw them away today. Get in.');
select pg_temp.jz_tpl('positivo','streak_risk',2,'en','{dias} days unstoppable! Don''t break the magic, you''re doing great 💪');
select pg_temp.jz_tpl('rezago','streak_risk',2,'en','Hours left to save your {dias}-day streak.');
select pg_temp.jz_tpl('suave','streak_risk',2,'en','Your {dias}-day streak is still alive — one lesson and done.');
select pg_temp.jz_tpl('mano_dura','streak_risk',3,'en','Last call. You lose your streak if you don''t come in now.');
select pg_temp.jz_tpl('positivo','streak_risk',3,'en','Just in time! Save your streak and celebrate 🎉');
select pg_temp.jz_tpl('rezago','streak_risk',3,'en','If you don''t come in today, your streak goes back to zero.');
select pg_temp.jz_tpl('suave','streak_risk',3,'en','If today''s not possible, no worries — we''ll pick it up tomorrow 🙂');
-- streak_risk pt
select pg_temp.jz_tpl('mano_dura','streak_risk',1,'pt','Sua sequência está em jogo. Uma lição, agora.');
select pg_temp.jz_tpl('positivo','streak_risk',1,'pt','Não perca sua sequência! Uma lição rápida e pronto 🔥');
select pg_temp.jz_tpl('rezago','streak_risk',1,'pt','Cuidado: sua sequência de {dias} dias está em risco.');
select pg_temp.jz_tpl('suave','streak_risk',1,'pt','Quando puder, uma lição curta mantém sua sequência 🙂');
select pg_temp.jz_tpl('mano_dura','streak_risk',2,'pt','{dias} dias de sequência. Não jogue fora hoje. Entre já.');
select pg_temp.jz_tpl('positivo','streak_risk',2,'pt','{dias} dias imparável! Não quebre a magia, você está indo muito bem 💪');
select pg_temp.jz_tpl('rezago','streak_risk',2,'pt','Faltam horas para salvar sua sequência de {dias} dias.');
select pg_temp.jz_tpl('suave','streak_risk',2,'pt','Sua sequência de {dias} dias segue viva — uma lição e pronto.');
select pg_temp.jz_tpl('mano_dura','streak_risk',3,'pt','Última chamada. Você perde a sequência se não entrar agora.');
select pg_temp.jz_tpl('positivo','streak_risk',3,'pt','Bem a tempo! Salve sua sequência e comemore 🎉');
select pg_temp.jz_tpl('rezago','streak_risk',3,'pt','Se não entrar hoje, sua sequência volta a zero.');
select pg_temp.jz_tpl('suave','streak_risk',3,'pt','Se hoje não der, tudo bem — amanhã retomamos 🙂');

-- goal_unmet en/pt
select pg_temp.jz_tpl('mano_dura','goal_unmet',1,'en','You''re missing today''s goal. No excuses.');
select pg_temp.jz_tpl('positivo','goal_unmet',1,'en','Almost! Just a little more for today''s goal 💪');
select pg_temp.jz_tpl('rezago','goal_unmet',1,'en','You''re at {x}/{meta} XP. Don''t fall short today.');
select pg_temp.jz_tpl('suave','goal_unmet',1,'en','When you have a moment, finish today''s goal 🙂');
select pg_temp.jz_tpl('mano_dura','goal_unmet',1,'pt','Falta sua meta de hoje. Sem desculpas.');
select pg_temp.jz_tpl('positivo','goal_unmet',1,'pt','Quase! Falta pouquinho para sua meta de hoje 💪');
select pg_temp.jz_tpl('rezago','goal_unmet',1,'pt','Você está em {x}/{meta} XP. Não fique aquém hoje.');
select pg_temp.jz_tpl('suave','goal_unmet',1,'pt','Quando tiver um tempinho, complete sua meta de hoje 🙂');

-- winback en/pt
select pg_temp.jz_tpl('mano_dura','winback',1,'en','{dias} days away. Your language won''t learn itself. Come back.');
select pg_temp.jz_tpl('positivo','winback',1,'en','We miss you! Pick up right where you left off 💜');
select pg_temp.jz_tpl('rezago','winback',1,'en','{dias} days without practice = your goal drifts away.');
select pg_temp.jz_tpl('suave','winback',1,'en','We''re here whenever you want. One short lesson is enough 🙂');
select pg_temp.jz_tpl('mano_dura','winback',2,'en','It''s been {dias} days. Decide today: move forward or let it go?');
select pg_temp.jz_tpl('positivo','winback',2,'en','Come back today and get your rhythm back — you''ve got this! 🔥');
select pg_temp.jz_tpl('rezago','winback',2,'en','Your plan slipped {dias} days. Get it back.');
select pg_temp.jz_tpl('suave','winback',2,'en','No pressure: a 2-minute lesson and you''re back in the game 🙂');
select pg_temp.jz_tpl('mano_dura','winback',1,'pt','{dias} dias fora. Seu idioma não avança sozinho. Volte.');
select pg_temp.jz_tpl('positivo','winback',1,'pt','Sentimos sua falta! Retome de onde parou 💜');
select pg_temp.jz_tpl('rezago','winback',1,'pt','{dias} dias sem praticar = sua meta se afasta.');
select pg_temp.jz_tpl('suave','winback',1,'pt','Estamos aqui quando quiser. Uma lição curta basta 🙂');
select pg_temp.jz_tpl('mano_dura','winback',2,'pt','Já são {dias} dias. Decida hoje: avança ou desiste?');
select pg_temp.jz_tpl('positivo','winback',2,'pt','Volte hoje e recupere seu ritmo — você consegue! 🔥');
select pg_temp.jz_tpl('rezago','winback',2,'pt','Seu plano atrasou {dias} dias. Recupere-o.');
select pg_temp.jz_tpl('suave','winback',2,'pt','Sem pressão: uma lição de 2 minutos e você volta ao jogo 🙂');

-- exam_countdown en/pt
select pg_temp.jz_tpl('mano_dura','exam_countdown',1,'en','Exam in {dias} days. Review today. No excuses.');
select pg_temp.jz_tpl('positivo','exam_countdown',1,'en','Exam in {dias} days! One review and you''ll shine 💪');
select pg_temp.jz_tpl('rezago','exam_countdown',1,'en','Exam in {dias} days and you''re behind. Don''t let it slip.');
select pg_temp.jz_tpl('suave','exam_countdown',1,'en','Your exam is in {dias} days; a calm review gets you ready.');
select pg_temp.jz_tpl('mano_dura','exam_countdown',1,'pt','Prova em {dias} dias. Revise hoje. Sem desculpas.');
select pg_temp.jz_tpl('positivo','exam_countdown',1,'pt','Prova em {dias} dias! Uma revisão e você vai brilhar 💪');
select pg_temp.jz_tpl('rezago','exam_countdown',1,'pt','Prova em {dias} dias e você está atrás. Não deixe passar.');
select pg_temp.jz_tpl('suave','exam_countdown',1,'pt','Sua prova é em {dias} dias; uma revisão tranquila te deixa pronto.');

-- behind_plan en/pt (ligado al MOTIVO)
select pg_temp.jz_tpl('mano_dura','behind_plan',1,'en','You''re behind your plan and {motivo} won''t wait. Pick up the pace.');
select pg_temp.jz_tpl('positivo','behind_plan',1,'en','One push and you''re back on track — {motivo} is worth it 💪');
select pg_temp.jz_tpl('rezago','behind_plan',1,'en','You''re behind your plan, and {motivo} is getting closer.');
select pg_temp.jz_tpl('suave','behind_plan',1,'en','A little more pace and you''ll be ready in time for {motivo} 🙂');
select pg_temp.jz_tpl('mano_dura','behind_plan',1,'pt','Você está atrás do seu plano e {motivo} não espera. Acelere.');
select pg_temp.jz_tpl('positivo','behind_plan',1,'pt','Um empurrão e você volta ao ritmo — {motivo} vale a pena 💪');
select pg_temp.jz_tpl('rezago','behind_plan',1,'pt','Você está atrás do seu plano, e {motivo} se aproxima.');
select pg_temp.jz_tpl('suave','behind_plan',1,'pt','Um pouco mais de ritmo e você chega a tempo para {motivo} 🙂');

-- achievement + league en/pt
select pg_temp.jz_tpl('mano_dura','achievement',1,'en','🏅 You unlocked {logro}! Keep it up.');
select pg_temp.jz_tpl('positivo','achievement',1,'en','🏅 You unlocked {logro}! Keep it up.');
select pg_temp.jz_tpl('rezago','achievement',1,'en','🏅 You unlocked {logro}! Keep it up.');
select pg_temp.jz_tpl('suave','achievement',1,'en','🏅 You unlocked {logro}! Keep it up.');
select pg_temp.jz_tpl('mano_dura','achievement',1,'pt','🏅 Você desbloqueou {logro}! Continue assim.');
select pg_temp.jz_tpl('positivo','achievement',1,'pt','🏅 Você desbloqueou {logro}! Continue assim.');
select pg_temp.jz_tpl('rezago','achievement',1,'pt','🏅 Você desbloqueou {logro}! Continue assim.');
select pg_temp.jz_tpl('suave','achievement',1,'pt','🏅 Você desbloqueou {logro}! Continue assim.');
select pg_temp.jz_tpl('mano_dura','league',1,'en','They passed you in the league. Are you letting that happen?');
select pg_temp.jz_tpl('positivo','league',1,'en','They passed you! Take your spot back, you''ve got this 💪');
select pg_temp.jz_tpl('rezago','league',1,'en','People in your league passed you this week.');
select pg_temp.jz_tpl('suave','league',1,'en','Someone passed you in the league — add some XP when you can 🙂');
select pg_temp.jz_tpl('mano_dura','league',1,'pt','Te passaram na liga. Vai deixar barato?');
select pg_temp.jz_tpl('positivo','league',1,'pt','Te passaram! Recupere seu lugar, você consegue 💪');
select pg_temp.jz_tpl('rezago','league',1,'pt','Gente da sua liga te passou esta semana.');
select pg_temp.jz_tpl('suave','league',1,'pt','Alguém te passou na liga — quando puder, some XP 🙂');

drop function pg_temp.jz_tpl(coach_style, notification_trigger, int, text, text);
