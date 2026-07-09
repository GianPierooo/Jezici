-- ============================================================================
-- Jezici · Migración 133 · El certificado guarda y expone el NOMBRE del titular
-- ----------------------------------------------------------------------------
-- P0 de producto (MOCKUP_GAP.md §5, Examen.dc "Se certifica que <NOMBRE>"): el
-- certificado no decía de quién era. El nombre YA se calculaba al emitir (v_name
-- → jz_cert_svg, embebido en el SVG), pero NO se guardaba en columna ni lo
-- devolvía get_certificates → el cliente no podía imprimirlo.
--
-- Fix (sin tocar el gran submit_level_exam): (1) columna holder_name; (2) backfill
-- desde users para los certificados ya emitidos; (3) trigger BEFORE INSERT que la
-- rellena desde users (misma fuente que get_profile: display_name/name) para los
-- NUEVOS — así submit_level_exam la puebla sin reescribirse; (4) get_certificates
-- la devuelve. Idempotente. 0 impacto en la economía/loop.
-- ============================================================================
begin;

alter table certificates add column if not exists holder_name text;

-- Backfill: certificados ya emitidos → nombre actual del usuario (o 'Aprendiz').
update certificates c
   set holder_name = coalesce(nullif(u.display_name, ''), nullif(u.name, ''), 'Aprendiz')
  from users u
 where u.id = c.user_id and (c.holder_name is null or c.holder_name = '');

-- Trigger: al INSERTAR un certificado, congela el nombre del titular desde users
-- (fuente idéntica a get_profile). Si ya viene holder_name, se respeta.
create or replace function jz_cert_set_holder()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.holder_name is null or new.holder_name = '' then
    select coalesce(nullif(display_name, ''), nullif(name, ''), 'Aprendiz')
      into new.holder_name
      from users where id = new.user_id;
    new.holder_name := coalesce(new.holder_name, 'Aprendiz');
  end if;
  return new;
end $$;

drop trigger if exists trg_cert_holder on certificates;
create trigger trg_cert_holder
  before insert on certificates
  for each row execute function jz_cert_set_holder();

-- get_certificates: incluye holder_name.
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
           'holder_name', holder_name,
           'issued_at', issued_at, 'pdf_url', pdf_url) order by issued_at desc), '[]'::jsonb)
    into v
  from certificates where user_id = uid;
  return v;
end $$;

grant execute on function get_certificates() to authenticated;

commit;
