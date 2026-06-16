-- ============================================================================
-- Jezici · Migración 014 · Row-Level Security de los dominios nuevos
-- ----------------------------------------------------------------------------
-- Mismo modelo que 005:
--   · Catálogo/contenido compartido -> lectura pública (anon + authenticated).
--   · Datos del usuario -> cada quien lee lo suyo.
--   · Escrituras (progreso, economía, scoring, scheduler Matix) -> por RPC
--     SECURITY DEFINER / service_role en pasos posteriores; sin políticas de
--     escritura para el cliente.
-- Nota: las políticas de SELECT propias usan claves directas (user_id) y evitan
--   subconsultas auto-referenciales para no provocar recursión de RLS.
-- ============================================================================

-- Habilitar RLS en todas las tablas nuevas -----------------------------------
alter table user_plans              enable row level security;
alter table exams                   enable row level security;
alter table exam_attempts           enable row level security;
alter table certificates            enable row level security;
alter table vocabulary              enable row level security;
alter table user_vocab_srs          enable row level security;
alter table gold_transactions       enable row level security;
alter table daily_goals             enable row level security;
alter table leagues                 enable row level security;
alter table league_members          enable row level security;
alter table achievements            enable row level security;
alter table user_achievements       enable row level security;
alter table chest_openings          enable row level security;
alter table wagers                  enable row level security;
alter table user_personality        enable row level security;
alter table notification_templates  enable row level security;
alter table notifications           enable row level security;
alter table social_profiles         enable row level security;
alter table connections             enable row level security;
alter table conversation_rooms      enable row level security;
alter table room_participants       enable row level security;
alter table coop_challenges         enable row level security;
alter table conversation_challenges enable row level security;
alter table reports                 enable row level security;
alter table subscriptions           enable row level security;

-- Catálogo / contenido compartido: lectura pública ---------------------------
create policy "content_read_exams"        on exams        for select to anon, authenticated using (true);
create policy "content_read_vocabulary"   on vocabulary   for select to anon, authenticated using (true);
create policy "content_read_achievements" on achievements for select to anon, authenticated using (true);
create policy "content_read_leagues"      on leagues      for select to anon, authenticated using (true);

-- Salas de conversación: descubribles por usuarios autenticados --------------
create policy "rooms_read" on conversation_rooms for select to authenticated using (true);

-- Datos del usuario: SELECT de lo propio -------------------------------------
create policy "uplans_select_own"   on user_plans              for select to authenticated using (auth.uid() = user_id);
create policy "eattempt_select_own" on exam_attempts           for select to authenticated using (auth.uid() = user_id);
create policy "certs_select_own"    on certificates            for select to authenticated using (auth.uid() = user_id);
create policy "uvsrs_select_own"    on user_vocab_srs          for select to authenticated using (auth.uid() = user_id);
create policy "gold_select_own"     on gold_transactions       for select to authenticated using (auth.uid() = user_id);
create policy "dgoals_select_own"   on daily_goals             for select to authenticated using (auth.uid() = user_id);
create policy "lmember_select_own"  on league_members          for select to authenticated using (auth.uid() = user_id);
create policy "uach_select_own"     on user_achievements       for select to authenticated using (auth.uid() = user_id);
create policy "chest_select_own"    on chest_openings          for select to authenticated using (auth.uid() = user_id);
create policy "wagers_select_own"   on wagers                  for select to authenticated using (auth.uid() = user_id);
create policy "person_select_own"   on user_personality        for select to authenticated using (auth.uid() = user_id);
create policy "notif_select_own"    on notifications           for select to authenticated using (auth.uid() = user_id);
create policy "social_select_own"   on social_profiles         for select to authenticated using (auth.uid() = user_id);
create policy "convch_select_own"   on conversation_challenges for select to authenticated using (auth.uid() = user_id);
create policy "subs_select_own"     on subscriptions           for select to authenticated using (auth.uid() = user_id);
create policy "rpart_select_own"    on room_participants       for select to authenticated using (auth.uid() = user_id);
create policy "reports_select_own"  on reports                 for select to authenticated using (auth.uid() = reporter_id);

-- Relaciones de dos usuarios: visible para cualquiera de los dos -------------
create policy "conn_select_member" on connections
  for select to authenticated using (auth.uid() = user_a_id or auth.uid() = user_b_id);
create policy "coop_select_member" on coop_challenges
  for select to authenticated using (auth.uid() = user_a_id or auth.uid() = user_b_id);

-- notification_templates: sin política de cliente -> solo service_role
-- (el scheduler de Matix corre en el servidor). RLS queda activo sin SELECT.
