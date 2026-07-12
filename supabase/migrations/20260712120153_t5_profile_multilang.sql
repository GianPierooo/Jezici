-- ═══════════════════════════════════════════════════════════════════════════
-- T5 — editar perfil dinámico (género + cumpleaños OBLIGATORIOS) + multi-idioma
--       (mig 153, 2026-07-12)
--
-- Decisiones de Gian (firmes): género OBLIGATORIO sin omitir · cumpleaños día Y
-- mes OBLIGATORIOS (el AÑO ya lo captura el age gate; NO se re-pide) · avatar =
-- selector de COLORES. PASO 0: hoy set_profile es LENIENTE (género fuera de
-- whitelist se ignora; día/mes se validan 1-31/1-12 pero son opcionales), lo cual
-- es correcto para el paso de NOMBRE del onboarding y CompleteProfileScreen (solo
-- envían nombre). Por eso NO se endurece set_profile (rompería esos flujos): se
-- añade una RPC ESTRICTA para el formulario de "editar perfil".
-- get_courses no distinguía qué cursos EMPEZÓ el usuario (solo el activo) → el
-- switch del home mostraba los 6; aquí se añade `started`.
-- ═══════════════════════════════════════════════════════════════════════════

-- ─────────────────────────────────────────────────────────────────────────────
-- 1) get_courses v2: + `started` (¿el usuario tiene plan en ese curso?)
--    El home muestra SOLO los `started`; Ajustes "añadir idioma" los NO started.
-- ─────────────────────────────────────────────────────────────────────────────
create or replace function public.get_courses()
returns jsonb language sql stable security definer set search_path to 'public' as $$
  select coalesce(jsonb_agg(jsonb_build_object(
    'id', c.id, 'source', sl.code, 'target', tl.code, 'target_name', tl.name,
    'active', c.id = jz_active_course(),
    'started', exists (select 1 from user_plans up
                       where up.user_id = auth.uid() and up.course_id = c.id),
    'max_level', (select max(u.cefr_level::text) from units u where u.course_id = c.id)
  ) order by c.created_at), '[]'::jsonb)
  from courses c
  join languages sl on sl.id = c.source_language_id
  join languages tl on tl.id = c.target_language_id
  where c.is_active;
$$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 2) set_profile_required — guardado ESTRICTO del formulario editar perfil.
--    Valida SERVER-SIDE los obligatorios (no solo el cliente):
--      · name   no vacío           → 'name_required'
--      · gender ∈ whitelist        → 'gender_required'
--      · birthday_day 1-31 Y month 1-12 (ambos) → 'birthday_required'
--    El AÑO NO se toca (viene del age gate). Reusa la misma columna/semántica que
--    set_profile; el nombre visible sigue LIBRE (no toca certificados).
-- ─────────────────────────────────────────────────────────────────────────────
create or replace function public.set_profile_required(
  p_name text,
  p_gender text,
  p_birthday_day integer,
  p_birthday_month integer,
  p_country text default null,
  p_bio text default null,
  p_avatar_color text default null,
  p_timezone text default null)
returns jsonb language plpgsql security definer set search_path to 'public' as $$
declare uid uuid := auth.uid(); v_name text; v_color text;
begin
  if uid is null then raise exception 'auth required'; end if;
  insert into users (id) values (uid) on conflict (id) do nothing;

  v_name := nullif(btrim(coalesce(p_name, '')), '');
  if v_name is null then raise exception 'name_required'; end if;
  v_name := left(v_name, 40);

  if coalesce(p_gender, '') not in ('male','female','other','prefer_not_to_say') then
    raise exception 'gender_required';
  end if;

  if p_birthday_day is null or p_birthday_month is null
     or p_birthday_day not between 1 and 31
     or p_birthday_month not between 1 and 12 then
    raise exception 'birthday_required';
  end if;

  -- avatar_color: hex #RRGGBB; inválido → se conserva el actual (no rompe).
  v_color := case when p_avatar_color ~* '^#?[0-9a-f]{6}$'
                  then '#' || upper(right(replace(p_avatar_color, '#', ''), 6))
                  else null end;

  update users set
    name = v_name,
    display_name = v_name,
    country = case when p_country is null then country
                   else nullif(btrim(p_country), '') end,
    bio = case when p_bio is null then bio else left(btrim(p_bio), 160) end,
    avatar_color = coalesce(v_color, avatar_color),
    birthday_day = p_birthday_day,
    birthday_month = p_birthday_month,
    gender = p_gender,
    timezone = coalesce(nullif(btrim(coalesce(p_timezone, '')), ''), timezone),
    updated_at = now()
  where id = uid;

  return get_profile();
end $$;

revoke execute on function public.set_profile_required(text, text, integer, integer, text, text, text, text)
  from public, anon;
grant execute on function public.set_profile_required(text, text, integer, integer, text, text, text, text)
  to authenticated;
