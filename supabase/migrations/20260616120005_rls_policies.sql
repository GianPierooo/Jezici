-- ============================================================================
-- Jezici · Migración 005 · Row-Level Security (RLS)
-- ----------------------------------------------------------------------------
-- Fuente: Arquitectura_Tecnica.md §4 y §7 — "RLS para que cada usuario solo
-- vea lo suyo" y "el cliente nunca decide scoring ni economía".
--
-- Modelo de seguridad:
--   · Contenido del curso (languages, courses, units, lessons, content_items,
--     lesson_items): es compartido y estático -> LECTURA pública (anon +
--     authenticated). Sin políticas de escritura: solo el rol `service_role`
--     (que ignora RLS) siembra/edita contenido.
--   · Datos del usuario: cada quien solo LEE lo suyo (auth.uid()).
--     NO se exponen políticas de escritura al cliente: las mutaciones de
--     progreso/skills/economía irán por funciones SECURITY DEFINER / RPC en
--     los pasos D–G (submit_exercise, complete_lesson, grade_checkpoint...),
--     tal como pide Arquitectura §4 ("lógica sensible en el servidor").
--     El alta inicial la hace handle_new_user() (migración 004, SECURITY DEFINER).
--   · users: el perfil propio se puede leer y actualizar, pero SOLO las
--     columnas de perfil (name, display_name, avatar_url, native_language_id).
--     email/auth_provider quedan bloqueadas (espejo de auth.users).
-- ============================================================================

-- ---------------------------------------------------------------------------
-- Contenido del curso: lectura pública, sin escritura desde el cliente
-- ---------------------------------------------------------------------------
alter table languages     enable row level security;
alter table courses       enable row level security;
alter table units         enable row level security;
alter table lessons       enable row level security;
alter table content_items enable row level security;
alter table lesson_items  enable row level security;

create policy "content_read_languages"
  on languages for select to anon, authenticated using (true);

create policy "content_read_courses"
  on courses for select to anon, authenticated using (true);

create policy "content_read_units"
  on units for select to anon, authenticated using (true);

create policy "content_read_lessons"
  on lessons for select to anon, authenticated using (true);

create policy "content_read_content_items"
  on content_items for select to anon, authenticated using (true);

create policy "content_read_lesson_items"
  on lesson_items for select to anon, authenticated using (true);

-- ---------------------------------------------------------------------------
-- users: leer/actualizar el propio perfil
-- ---------------------------------------------------------------------------
alter table users enable row level security;

create policy "users_select_own"
  on users for select to authenticated
  using (auth.uid() = id);

create policy "users_update_own"
  on users for update to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- `email` y `auth_provider` son ESPEJO de auth.users (la fuente de verdad del
-- login). RLS es a nivel de fila, no de columna, así que sin esto el cliente
-- podría reescribir esas columnas en su propia fila. Limitamos las columnas
-- escribibles a los campos de perfil de onboarding/ajustes; email/auth_provider
-- solo se sincronizan desde el servidor (trigger / RPC).
revoke update on users from authenticated;
grant  update (name, display_name, avatar_url, native_language_id)
  on users to authenticated;

-- ---------------------------------------------------------------------------
-- Datos por usuario: SOLO lectura de lo propio.
-- (Escrituras vía RPC SECURITY DEFINER en pasos posteriores.)
-- ---------------------------------------------------------------------------
alter table user_course_progress enable row level security;
alter table user_lesson_progress enable row level security;
alter table user_skill_levels    enable row level security;
alter table user_stats           enable row level security;
alter table streaks              enable row level security;

create policy "ucp_select_own"
  on user_course_progress for select to authenticated
  using (auth.uid() = user_id);

create policy "ulp_select_own"
  on user_lesson_progress for select to authenticated
  using (auth.uid() = user_id);

create policy "usl_select_own"
  on user_skill_levels for select to authenticated
  using (auth.uid() = user_id);

create policy "ustats_select_own"
  on user_stats for select to authenticated
  using (auth.uid() = user_id);

create policy "streaks_select_own"
  on streaks for select to authenticated
  using (auth.uid() = user_id);
