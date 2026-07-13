"""PASO 0 del reseteo de usuarios: censo COMPLETO de datos de usuario.
Descubre TODAS las tablas de `public` con columna user_id (no se fía de una lista),
+ la tabla `users` (id = auth.users.id), + auth.users, y cuenta filas de cada una.
Uso: python reset_census.py [tag]   (tag = 'pre' | 'post', default 'pre')
Guarda a _reset_census_<tag>.json y lo imprime."""
import json, sys
from apply_sql import run

def q(s):
    c, o = run(s)
    if c not in (200, 201):
        sys.exit(f"query fallo [{c}]: {o[:400]}")
    return json.loads(o) if o and o.strip().startswith('[') else []

def main():
    tag = sys.argv[1] if len(sys.argv) > 1 else 'pre'

    # 1) Todas las tablas BASE de public con columna user_id.
    with_uid = q("""
      select distinct t.table_name
      from information_schema.columns c
      join information_schema.tables t
        on t.table_schema=c.table_schema and t.table_name=c.table_name
      where c.table_schema='public' and c.column_name='user_id'
        and t.table_type='BASE TABLE'
      order by t.table_name;
    """)
    uid_tables = [r['table_name'] for r in with_uid]

    # 2) users (id -> auth.users) + otras tablas de datos de usuario que NO usan
    #    la columna 'user_id' literal (las descubrimos por FK a users/auth.users).
    fk_tables = q("""
      select distinct tc.table_name, kcu.column_name
      from information_schema.table_constraints tc
      join information_schema.key_column_usage kcu
        on tc.constraint_name=kcu.constraint_name and tc.table_schema=kcu.table_schema
      join information_schema.constraint_column_usage ccu
        on tc.constraint_name=ccu.constraint_name and tc.table_schema=ccu.table_schema
      where tc.constraint_type='FOREIGN KEY' and tc.table_schema='public'
        and (ccu.table_name in ('users') or ccu.table_schema='auth')
      order by tc.table_name;
    """)

    # 3) auth.users count
    auth_n = q("select count(*)::int n from auth.users;")[0]['n']
    users_n = q("select count(*)::int n from public.users;")[0]['n']

    counts = {}
    for t in uid_tables:
        counts[t] = q(f"select count(*)::int n from public.{t};")[0]['n']
    # asegurar users contada
    counts['users'] = users_n

    census = {
        'tag': tag,
        'auth_users': auth_n,
        'public_users': users_n,
        'tables_with_user_id': uid_tables,
        'fk_to_users_or_auth': [f"{r['table_name']}.{r['column_name']}" for r in fk_tables],
        'row_counts': dict(sorted(counts.items())),
        'total_user_rows': sum(counts.values()),
    }
    path = f"_reset_census_{tag}.json"
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(census, f, indent=2, ensure_ascii=False)
    print(json.dumps(census, indent=2, ensure_ascii=False))
    print(f"\n[OK] censo '{tag}' -> {path}")

if __name__ == '__main__':
    main()
