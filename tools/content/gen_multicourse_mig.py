"""Genera (y aplica) la migración 047 · multi-curso backward-compatible.

Estrategia de bajo riesgo: la línea resolver del "curso activo" es BYTE-IDÉNTICA en
~28 sitios (`select id into v_course from courses where is_active order by created_at
limit 1;`). En vez de re-transcribir a mano 15+ cuerpos de función (propenso a error),
leemos las definiciones VIVAS con pg_get_functiondef, reemplazamos esa línea por
`select jz_active_course() into v_course;` y re-emitimos cada función con CREATE OR
REPLACE. jz_active_course() resuelve el curso del usuario (user_active_course) con
FALLBACK al curso is_active más antiguo (es→en) → CERO cambio de conducta para los
usuarios existentes hasta que elijan otro curso.

IMPORTANTE: capturamos las definiciones a convertir ANTES de crear jz_active_course
(cuyo fallback contiene la misma subcadena) para no convertirla en recursión infinita.

Uso: python gen_multicourse_mig.py dry   # genera/valida, NO aplica
     python gen_multicourse_mig.py        # genera + aplica + registra
"""
import json, re, sys, os
from apply_sql import run

MIG = 'C:/Users/gianp/Desktop/Jezici/supabase/migrations/20260620100047_multicourse_active.sql'
VERSION = '20260620100047'
PT_COURSE = '20000000-0000-0000-0000-000000000002'
ES = '10000000-0000-0000-0000-000000000001'
PT = '10000000-0000-0000-0000-000000000003'

RESOLVER_RE = re.compile(
    r"select\s+id\s+into\s+v_course\s+from\s+courses\s+where\s+is_active\s+order\s+by\s+created_at\s+limit\s+1\s*;",
    re.IGNORECASE)
REPLACEMENT = "select jz_active_course() into v_course;"

PREAMBLE = f"""-- ============================================================================
-- Jezici · Migración 047 · Multi-curso (curso activo por usuario) — backward-compat
-- ----------------------------------------------------------------------------
-- Añade es→pt como curso paralelo sin romper es→en. jz_active_course() resuelve el
-- curso del usuario con FALLBACK al primer curso is_active (es→en). Convierte las
-- RPCs que resolvían el "único curso activo" para que respeten el curso del usuario.
-- Re-emisión automática de cuerpos vivos (pg_get_functiondef) con la línea resolver
-- intercambiada (ver tools/content/gen_multicourse_mig.py).
-- ============================================================================
begin;

-- Curso es → pt (português do Brasil). is_active=true; el fallback ordena por
-- created_at, así es→en (creado antes) sigue siendo el predeterminado.
insert into courses (id, source_language_id, target_language_id, is_active) values
  ('{PT_COURSE}', '{ES}', '{PT}', true)
on conflict (id) do nothing;

-- Curso activo por usuario (multi-curso).
create table if not exists user_active_course (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  course_id  uuid not null references courses(id) on delete cascade,
  updated_at timestamptz not null default now()
);
alter table user_active_course enable row level security;
do $pol$ begin
  create policy uac_self on user_active_course for all
    using (user_id = auth.uid()) with check (user_id = auth.uid());
exception when duplicate_object then null; end $pol$;

-- Resolver del curso activo: elección del usuario, o fallback al curso por defecto.
create or replace function jz_active_course() returns uuid
language sql stable security definer set search_path = public as $fn$
  select coalesce(
    (select course_id from user_active_course where user_id = auth.uid()),
    (select id from courses where is_active order by created_at limit 1)
  );
$fn$;
grant execute on function jz_active_course() to authenticated;

-- Cambia (y asegura inscripción en) el curso activo del usuario.
create or replace function set_active_course(p_course_id uuid) returns jsonb
language plpgsql security definer set search_path = public as $fn$
declare uid uuid := auth.uid();
begin
  if uid is null then raise exception 'auth required'; end if;
  if not exists (select 1 from courses where id = p_course_id and is_active) then
    raise exception 'course not found or inactive';
  end if;
  insert into user_active_course(user_id, course_id) values (uid, p_course_id)
    on conflict (user_id) do update set course_id = excluded.course_id, updated_at = now();
  perform start_course();  -- idempotente; usa jz_active_course() = p_course_id
  return jsonb_build_object('course_id', p_course_id);
end $fn$;
grant execute on function set_active_course(uuid) to authenticated;

-- Lista de cursos disponibles + cuál es el activo del usuario (para el selector).
create or replace function get_courses() returns jsonb
language sql stable security definer set search_path = public as $fn$
  select coalesce(jsonb_agg(jsonb_build_object(
    'id', c.id, 'source', sl.code, 'target', tl.code, 'target_name', tl.name,
    'active', c.id = jz_active_course()) order by c.created_at), '[]'::jsonb)
  from courses c
  join languages sl on sl.id = c.source_language_id
  join languages tl on tl.id = c.target_language_id
  where c.is_active;
$fn$;
grant execute on function get_courses() to authenticated;

"""

def main():
    dry = len(sys.argv) > 1 and sys.argv[1] == 'dry'
    # 1) Capturar definiciones VIVAS a convertir ANTES de crear jz_active_course.
    code, out = run(
        "select p.proname, pg_get_functiondef(p.oid) as def "
        "from pg_proc p join pg_namespace n on n.oid=p.pronamespace "
        "where n.nspname='public' and p.prosrc like '%from courses where is_active%' "
        "and p.proname not in ('jz_active_course','set_active_course','get_courses') "
        "order by p.proname;")
    if code not in (200, 201):
        raise SystemExit(f"query pg_proc falló [{code}]: {out[:300]}")
    rows = json.loads(out)
    converted, skipped = [], []
    bodies = []
    for r in rows:
        name, dfn = r['proname'], r['def']
        n = len(RESOLVER_RE.findall(dfn))
        if n == 0:
            skipped.append((name, 'sin línea resolver (¿whitespace?)')); continue
        new = RESOLVER_RE.sub(REPLACEMENT, dfn)
        # pg_get_functiondef no termina en ';' → añadimos uno.
        bodies.append(f"-- convertida: {name} ({n}x)\n{new};\n")
        converted.append((name, n))

    sql = PREAMBLE + "\n".join(bodies) + "\ncommit;\n"
    os.makedirs(os.path.dirname(MIG), exist_ok=True)
    open(MIG, 'w', encoding='utf-8').write(sql)
    print(f"[OK] migración escrita: {MIG} ({len(sql)} bytes)")
    print(f"  funciones convertidas ({len(converted)}):")
    for name, n in converted:
        print(f"    {name}: {n}x")
    for name, why in skipped:
        print(f"  SALTADA {name}: {why}")
    if dry:
        print("DRY: no se aplica."); return
    c, o = run(sql)
    print(f"[{c}] aplicar -> {o[:300]}")
    if c not in (200, 201):
        raise SystemExit("FALLÓ la aplicación")
    rec = ("insert into supabase_migrations.schema_migrations(version,name) "
           f"values ('{VERSION}','multicourse_active') on conflict (version) do nothing;")
    run(rec)
    print("[OK] registrada en schema_migrations")

if __name__ == '__main__':
    main()
