-- 2ª PASADA de errores tipados — SQLSTATE CUSTOM en el servidor.
-- Los errores de NEGOCIO se levantaban con `raise exception '<texto>'` (SQLSTATE
-- P0001 genérico) → el cliente los mapeaba por un TOKEN del TEXTO (frágil ante
-- reescrituras del mensaje). Ahora un helper `jz_err(reason, kind)` levanta un
-- SQLSTATE de la clase 'JZ' que codifica el KIND → el cliente (JzError.from)
-- mapea por CÓDIGO (robusto), y el reason viaja como el MENSAJE = token estable
-- EXACTO (no substring).
--
-- Códigos (clase 'JZ', fuera de las clases estándar de Postgres; PostgREST expone
-- el `code` en el JSON de error → el cliente lo lee aunque el HTTP status varíe):
--   JZ401 auth · JZ403 denied · JZ404 not_found · JZ409 conflict · JZ429 rate · JZ422 validation
--
-- COMPATIBILIDAD (guardarraíl "no romper lo que ya funciona"): en esta pasada solo
-- se migra `claim_handle` (RPC de arranque, muy usada). Las RPC NO migradas siguen
-- con P0001 + texto y el cliente las entiende por su tabla de tokens (fallback).
-- Como el MENSAJE de jz_err es el MISMO token de siempre ('handle_taken', …), el
-- fallback por texto del cliente TAMBIÉN sigue mapeándolas si algún día el code se
-- perdiera → doble red.

create or replace function public.jz_err(p_reason text, p_kind text default 'validation')
returns void
language plpgsql
as $function$
begin
  raise exception using
    errcode = case p_kind
      when 'auth' then 'JZ401'
      when 'denied' then 'JZ403'
      when 'not_found' then 'JZ404'
      when 'conflict' then 'JZ409'
      when 'rate' then 'JZ429'
      else 'JZ422'  -- validation (por defecto)
    end,
    message = p_reason;
end $function$;

-- Helper interno: solo lo invocan las funciones DEFINER server-side. Revocado del
-- cliente (nunca se llama por REST), como el resto de helpers jz_*.
revoke all on function public.jz_err(text, text) from public, anon, authenticated;

-- claim_handle: MISMOS guardas y MISMA lógica (cuerpo verbatim de la mig 158);
-- solo los `raise exception '<token>'` pasan a `jz_err(<token>, <kind>)`. El texto
-- del mensaje (= el token) NO cambia → el fallback por texto del cliente sigue
-- válido y `verify_handle_mandatory.py` sigue verde.
create or replace function public.claim_handle(p_handle text)
returns jsonb
language plpgsql
security definer
set search_path to 'public'
as $function$
declare uid uuid := auth.uid(); v text; v_cur text; v_at timestamptz;
begin
  if uid is null then perform jz_err('auth required', 'auth'); end if;
  -- (Se quitó el gate jz_social_access: el @handle es identidad de arranque
  --  para TODOS. La descubribilidad social sigue 18+ en sus propias RPCs.)
  v := lower(btrim(coalesce(p_handle, '')));
  v := ltrim(v, '@');
  if not jz_valid_handle(v) then perform jz_err('invalid_handle', 'validation'); end if;
  if v in ('admin','jezici','jezi','matix','support','help','root','moderator',
           'mod','system','staff','official','about','settings','api','null',
           'undefined','me','you','user','users','search','friends') then
    perform jz_err('handle_reserved', 'conflict');
  end if;
  select handle, handle_set_at into v_cur, v_at from users where id = uid;
  if v_cur is not null and lower(v_cur) = v then
    return jsonb_build_object('handle', v_cur); -- no-op (mismo handle)
  end if;
  if v_cur is not null and v_at is not null and v_at > now() - interval '30 days' then
    perform jz_err('handle_change_rate', 'rate');
  end if;
  begin
    update users set handle = v, handle_set_at = now(), updated_at = now() where id = uid;
  exception when unique_violation then
    perform jz_err('handle_taken', 'conflict');
  end;
  return jsonb_build_object('handle', v);
end $function$;
