-- ============================================================================
-- Jezici · Migración 004 · Funciones y triggers
-- ----------------------------------------------------------------------------
-- 1) set_updated_at(): mantiene updated_at al día en cada UPDATE.
-- 2) handle_new_user(): al crear una cuenta en Supabase Auth, siembra el perfil
--    de aplicación y los singletons de gamificación (stats + racha).
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1) updated_at automático
-- ---------------------------------------------------------------------------
create or replace function set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

-- Adjuntar a todas las tablas con columna updated_at.
create trigger trg_languages_updated_at
  before update on languages
  for each row execute function set_updated_at();

create trigger trg_courses_updated_at
  before update on courses
  for each row execute function set_updated_at();

create trigger trg_units_updated_at
  before update on units
  for each row execute function set_updated_at();

create trigger trg_lessons_updated_at
  before update on lessons
  for each row execute function set_updated_at();

create trigger trg_content_items_updated_at
  before update on content_items
  for each row execute function set_updated_at();

create trigger trg_users_updated_at
  before update on users
  for each row execute function set_updated_at();

create trigger trg_user_course_progress_updated_at
  before update on user_course_progress
  for each row execute function set_updated_at();

create trigger trg_user_lesson_progress_updated_at
  before update on user_lesson_progress
  for each row execute function set_updated_at();

create trigger trg_user_skill_levels_updated_at
  before update on user_skill_levels
  for each row execute function set_updated_at();

create trigger trg_user_stats_updated_at
  before update on user_stats
  for each row execute function set_updated_at();

create trigger trg_streaks_updated_at
  before update on streaks
  for each row execute function set_updated_at();

-- ---------------------------------------------------------------------------
-- 2) Alta de usuario: perfil + singletons de gamificación
--    SECURITY DEFINER para poder insertar saltándose RLS (corre como owner).
--    Las filas por curso (user_course_progress + las 4 user_skill_levels) se
--    crean al elegir curso en el onboarding (paso G), no aquí.
-- ---------------------------------------------------------------------------
create or replace function handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.users (id, email)
  values (new.id, new.email)
  on conflict (id) do nothing;

  insert into public.user_stats (user_id)
  values (new.id)
  on conflict (user_id) do nothing;

  insert into public.streaks (user_id)
  values (new.id)
  on conflict (user_id) do nothing;

  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function handle_new_user();
