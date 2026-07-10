-- 20260710120138_cert_lang.sql
-- get_certificates expone el IDIOMA del certificado ('lang' = código del idioma
-- meta del curso del cert). El dato YA existe (certificates.course_id → courses
-- → languages); solo se agrega al jsonb (clave nueva → clientes viejos la
-- ignoran). Arregla el "Certificado de Inglés" hardcodeado del cliente.
begin;

create or replace function get_certificates()
returns jsonb language plpgsql security definer set search_path = public as $$
declare uid uuid := auth.uid(); v jsonb;
begin
  if uid is null then raise exception 'auth required'; end if;
  select coalesce(jsonb_agg(jsonb_build_object(
           'cefr_level', ct.cefr_level, 'folio', ct.folio,
           'verification_code', ct.verification_code,
           'holder_name', ct.holder_name,
           'issued_at', ct.issued_at, 'pdf_url', ct.pdf_url,
           'lang', l.code) order by ct.issued_at desc), '[]'::jsonb)
    into v
  from certificates ct
  join courses c on c.id = ct.course_id
  join languages l on l.id = c.target_language_id
  where ct.user_id = uid;
  return v;
end $$;

grant execute on function get_certificates() to authenticated;

commit;
