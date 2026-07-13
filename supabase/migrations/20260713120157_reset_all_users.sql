-- RESETEO TOTAL DE USUARIOS (beta) — IRREVERSIBLE. Coordinado con los testers.
-- Borra TODOS los usuarios y sus datos; NO toca contenido del curso ni config.
--
-- Mecánica verificada (PASO 0, introspección real):
--   public.users.id -> auth.users  es ON DELETE CASCADE
--   public.users     -> 44 tablas de datos de usuario, TODAS ON DELETE CASCADE
--   auth.users       -> auth.identities/sessions/oauth_*/one_time_tokens/...  CASCADE
-- => `delete from auth.users` limpia auth + public.users + las 44 tablas en cascada.
--
-- Excepción: 4 tablas de datos de usuario NO cascadan (user_id SET NULL o sin FK):
--   analytics_events (SET NULL), feedback (SET NULL), conversation_rooms (SET NULL),
--   social_search_log (sin FK). Se borran explícitamente para llegar a 0 filas.
--
-- Dry-run con ROLLBACK confirmó: tras el borrado TODO dato de usuario = 0 y
-- courses(6)/content_items(5182) intactos.
--
-- ADMIN: la fila de `admins` (Gian) se borra por cascada. Recuperación tras el
-- nuevo alta con Google:  insert into public.admins(user_id) values ('<nuevo_uid>');

begin;

-- Tablas de datos de usuario que la cascada de auth.users NO limpia:
delete from public.analytics_events;   -- user_id SET NULL
delete from public.feedback;           -- user_id SET NULL
delete from public.conversation_rooms; -- host_user_id SET NULL (0 filas)
delete from public.social_search_log;  -- user_id sin FK

-- Borra todos los usuarios de Auth -> cascada a public.users -> a TODAS las
-- tablas de datos de usuario (CASCADE) + auth.identities/sessions/oauth/etc.
delete from auth.users;

commit;
