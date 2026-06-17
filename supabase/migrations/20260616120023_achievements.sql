-- ============================================================================
-- Jezici · Migración 023 · Logros/badges + lectura de certificados (paso Perfil)
-- ----------------------------------------------------------------------------
-- Diseno_Gamificacion §badges. Catálogo de logros + evaluación server-side
-- (el cliente nunca decide qué se desbloquea). get_achievements/get_certificates
-- alimentan el Perfil.
-- ============================================================================

-- ── Catálogo de logros ──────────────────────────────────────────────────────
insert into achievements (id, code, name, description, criteria) values
 ('a0000000-0000-0000-0000-000000000001','primeros_pasos','Primeros pasos','Completa tu primera lección.', '{"icon":"🐣","hint":"Completa 1 lección"}'),
 ('a0000000-0000-0000-0000-000000000002','impecable','Impecable','Termina una lección sin errores.', '{"icon":"🌟","hint":"1 lección perfecta"}'),
 ('a0000000-0000-0000-0000-000000000003','constante','Constante','Alcanza 7 días de racha.', '{"icon":"🔥","hint":"Racha de 7 días"}'),
 ('a0000000-0000-0000-0000-000000000004','imparable','Imparable','Alcanza 30 días de racha.', '{"icon":"🚀","hint":"Racha de 30 días"}'),
 ('a0000000-0000-0000-0000-000000000005','centurion','Centurión','Acumula 100 XP.', '{"icon":"💯","hint":"100 XP"}'),
 ('a0000000-0000-0000-0000-000000000006','maratonista','Maratonista','Acumula 500 XP.', '{"icon":"🏃","hint":"500 XP"}'),
 ('a0000000-0000-0000-0000-000000000007','fundamentos','Fundamentos','Aprueba el checkpoint de la Unidad 1.', '{"icon":"🏁","hint":"Checkpoint U1"}'),
 ('a0000000-0000-0000-0000-000000000008','medio_camino','A mitad de A1','Aprueba el checkpoint de la Unidad 3.', '{"icon":"⛰️","hint":"Checkpoint U3"}'),
 ('a0000000-0000-0000-0000-000000000009','a1_completo','A1 completo','Aprueba el checkpoint de la Unidad 6.', '{"icon":"🎓","hint":"Checkpoint U6"}'),
 ('a0000000-0000-0000-0000-00000000000a','equilibrado','Equilibrado','Lleva tus 4 habilidades a A2.', '{"icon":"⚖️","hint":"Las 4 skills en A2"}'),
 ('a0000000-0000-0000-0000-00000000000b','vocabulista','Vocabulista','Domina 20 palabras en tu repaso.', '{"icon":"📚","hint":"20 palabras (SRS)"}'),
 ('a0000000-0000-0000-0000-00000000000c','certificado_a1','Certificado A1','Obtén tu certificado de nivel A1.', '{"icon":"📜","hint":"Certifica A1"}')
on conflict (code) do update set name = excluded.name, description = excluded.description, criteria = excluded.criteria;

-- RLS: catálogo de lectura pública para autenticados (las RPC son DEFINER igual).
alter table achievements enable row level security;
drop policy if exists "ach_read" on achievements;
create policy "ach_read" on achievements for select to authenticated using (true);

-- ── evaluate_achievements: desbloquea los recién cumplidos (server-side) ──────
create or replace function evaluate_achievements()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  v_course uuid;
  v_completed int; v_golden int; v_streak int; v_xp int;
  v_units int[]; v_four_a2 boolean; v_srs int; v_cert_a1 boolean;
  v_new jsonb;
begin
  if uid is null then raise exception 'auth required'; end if;
  select id into v_course from courses where is_active order by created_at limit 1;

  select count(*) filter (where status in ('completed','golden')),
         count(*) filter (where status = 'golden')
    into v_completed, v_golden
  from user_lesson_progress where user_id = uid;

  select coalesce(longest_streak, 0) into v_streak from streaks where user_id = uid;
  select coalesce(xp_total, 0) into v_xp from user_stats where user_id = uid;

  select coalesce(array_agg(u.order_index), '{}') into v_units
  from user_lesson_progress ulp
  join lessons l on l.id = ulp.lesson_id
  join units u on u.id = l.unit_id
  where ulp.user_id = uid and l.type = 'checkpoint' and ulp.status in ('completed','golden');

  select (count(*) filter (where array_position(array['A1','A2','B1','B2','C1','C2']::text[], cefr_level::text) >= 2) >= 4)
    into v_four_a2
  from user_skill_levels where user_id = uid and course_id = v_course;

  select count(*) into v_srs from user_vocab_srs where user_id = uid and strength >= 2;
  select exists(select 1 from certificates where user_id = uid and cefr_level = 'A1') into v_cert_a1;

  create temp table _ach on commit drop as
  select * from (values
    ('primeros_pasos', v_completed >= 1),
    ('impecable',      v_golden >= 1),
    ('constante',      v_streak >= 7),
    ('imparable',      v_streak >= 30),
    ('centurion',      v_xp >= 100),
    ('maratonista',    v_xp >= 500),
    ('fundamentos',    1 = any(v_units)),
    ('medio_camino',   3 = any(v_units)),
    ('a1_completo',    6 = any(v_units)),
    ('equilibrado',    coalesce(v_four_a2, false)),
    ('vocabulista',    v_srs >= 20),
    ('certificado_a1', coalesce(v_cert_a1, false))
  ) as t(code, met);

  with ins as (
    insert into user_achievements (user_id, achievement_id)
    select uid, a.id from _ach x join achievements a on a.code = x.code
    where x.met
    on conflict (user_id, achievement_id) do nothing
    returning achievement_id
  )
  select coalesce(jsonb_agg(jsonb_build_object('code', a.code, 'name', a.name, 'icon', a.criteria->>'icon')), '[]'::jsonb)
    into v_new
  from ins join achievements a on a.id = ins.achievement_id;

  return jsonb_build_object('newly_unlocked', v_new);
end $$;

-- ── get_achievements: catálogo + estado del usuario (para el Perfil) ─────────
create or replace function get_achievements()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare uid uuid := auth.uid(); v jsonb;
begin
  if uid is null then raise exception 'auth required'; end if;
  perform evaluate_achievements(); -- mantener al día al abrir el Perfil
  select coalesce(jsonb_agg(jsonb_build_object(
           'code', a.code, 'name', a.name, 'description', a.description,
           'icon', a.criteria->>'icon', 'hint', a.criteria->>'hint',
           'unlocked', ua.user_id is not null,
           'unlocked_at', ua.unlocked_at) order by (ua.user_id is null), a.created_at), '[]'::jsonb)
    into v
  from achievements a
  left join user_achievements ua on ua.achievement_id = a.id and ua.user_id = uid;
  return v;
end $$;

-- ── get_certificates: certificados emitidos del usuario ──────────────────────
create or replace function get_certificates()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare uid uuid := auth.uid(); v jsonb;
begin
  if uid is null then raise exception 'auth required'; end if;
  select coalesce(jsonb_agg(jsonb_build_object(
           'cefr_level', cefr_level, 'folio', folio, 'verification_code', verification_code,
           'issued_at', issued_at, 'pdf_url', pdf_url) order by issued_at desc), '[]'::jsonb)
    into v
  from certificates where user_id = uid;
  return v;
end $$;

grant execute on function evaluate_achievements() to authenticated;
grant execute on function get_achievements() to authenticated;
grant execute on function get_certificates() to authenticated;
