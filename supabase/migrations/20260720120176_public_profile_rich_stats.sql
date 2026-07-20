-- Perfil público más rico: añade STATS DE JUEGO no sensibles a get_public_profile
-- (XP total, lecciones completadas, racha máxima, nº de logros) para que la
-- pantalla deje de verse pobre. Cuerpo VERBATIM de la definición viva (mig 149 +
-- 163): TODOS los guardarraíles de privacidad/seguridad intactos (auth, 18+,
-- bloqueo, descubribilidad) — SOLO se AÑADEN campos NO sensibles al jsonb.
-- NO se expone nada nuevo privado: sin email, sin birth_year/cumpleaños, sin
-- género, sin bio, sin edad. Todo lo añadido es progreso de juego (ya público en
-- los leaderboards). Idempotente.

create or replace function public.get_public_profile(p_user_id uuid)
returns jsonb
language plpgsql
security definer
set search_path to 'public'
as $function$
declare uid uuid := auth.uid(); u users%rowtype; v_rel text; v_disc boolean;
begin
  if uid is null then raise exception 'auth required'; end if;
  if not jz_social_access(uid) then raise exception 'social unavailable'; end if;
  if p_user_id is null then raise exception 'not found'; end if;
  select * into u from users where id = p_user_id;
  if u.id is null then raise exception 'not found'; end if;
  if not jz_is_adult_user(u.id) then raise exception 'not found'; end if;
  if jz_blocked_between(uid, u.id) then raise exception 'not found'; end if;
  v_rel := jz_relationship(uid, u.id);
  v_disc := coalesce(u.discoverable, true);
  -- privado (no descubrible) y sin vínculo → no se revela
  if uid <> u.id and not v_disc
     and v_rel not in ('friends', 'pending_out', 'pending_in') then
    raise exception 'not found';
  end if;
  return jsonb_build_object(
    'user_id', u.id,
    'handle', u.handle,
    'name', coalesce(nullif(u.display_name, ''), nullif(u.name, ''), 'Aprendiz'),
    'avatar_color', coalesce(u.avatar_color, '#6C5CE7'),
    'avatar_url', u.avatar_url,
    'country', u.country,
    'member_since', to_char(u.created_at, 'YYYY'),
    'relationship', v_rel,
    -- id de la conexión entre ambos (si existe) → aceptar/chatear desde el perfil.
    -- Es la fila que el propio RLS conn_select_member ya permite a un miembro.
    'connection_id', (select c.id from connections c
      where c.user_a_id = least(uid, u.id) and c.user_b_id = greatest(uid, u.id)),
    'streak', coalesce((select current_streak from streaks where user_id = u.id), 0),
    -- ── STATS DE JUEGO no sensibles (NUEVO) ──────────────────────────────────
    'longest_streak', coalesce((select longest_streak from streaks where user_id = u.id), 0),
    'xp_total', coalesce((select sum(xp_earned) from daily_goals where user_id = u.id), 0),
    'lessons_completed', coalesce((
      select count(*) from user_lesson_progress
      where user_id = u.id and status = 'completed'), 0),
    'achievements_count', coalesce((
      select count(*) from user_achievements where user_id = u.id), 0),
    -- ─────────────────────────────────────────────────────────────────────────
    'levels', jz_public_levels(u.id),
    'badges', coalesce((
      select jsonb_agg(jsonb_build_object('code', a.code, 'name', a.name)
             order by ua.unlocked_at desc)
      from user_achievements ua join achievements a on a.id = ua.achievement_id
      where ua.user_id = u.id limit 12), '[]'::jsonb)
  );
end $function$;
