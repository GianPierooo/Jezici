"""Aplica los fixes de QA de contenido (verificados adversarialmente) a la BD viva.
Lee _content_fixes.json (lista de {item_id, fix_field, fix_value, severity}) y emite
una migración UPDATE content_items idempotente; la aplica vía Management API.

fix_field → columna:  correct→correct_answer (jsonb), payload→payload (jsonb),
prompt→prompt (text), difficulty→difficulty (numeric).

Uso: python apply_content_fixes.py            # genera migración, la aplica
     python apply_content_fixes.py dry         # solo genera/valida, NO aplica
"""
import json, sys, os, re
from apply_sql import run

MIG = 'C:/Users/gianp/Desktop/Jezici/supabase/migrations/20260618140044_content_qa_fixes_b1.sql'

def dq(s, tag):
    s = str(s)
    if f'${tag}$' in s:
        raise SystemExit(f"delimitador colisiona en: {s[:80]}")
    return f'${tag}${s}${tag}$'

def main():
    dry = len(sys.argv) > 1 and sys.argv[1] == 'dry'
    fixes = json.load(open('_content_fixes.json', encoding='utf-8'))
    rows = []
    skipped = []
    for fx in fixes:
        iid = fx['item_id']; field = fx['fix_field']; val = fx['fix_value']
        if not re.fullmatch(r'[0-9a-fA-F-]{8,40}', iid):
            skipped.append((iid, 'id inválido')); continue
        if field in ('correct', 'payload'):
            try:
                obj = json.loads(val)  # validar JSON
            except Exception as e:
                skipped.append((iid, f'JSON inválido en {field}: {e}')); continue
            col = 'correct_answer' if field == 'correct' else 'payload'
            rows.append(f"update content_items set {col} = {dq(json.dumps(obj, ensure_ascii=False),'j')}::jsonb, updated_at = now() where id = '{iid}';")
        elif field == 'prompt':
            rows.append(f"update content_items set prompt = {dq(val,'p')}, updated_at = now() where id = '{iid}';")
        elif field == 'difficulty':
            try:
                d = float(val)
            except Exception:
                skipped.append((iid, f'difficulty no numérica: {val}')); continue
            rows.append(f"update content_items set difficulty = {d:.2f}, updated_at = now() where id = '{iid}';")
        else:
            skipped.append((iid, f'field desconocido {field}')); continue

    sql = ("-- ============================================================================\n"
           "-- Jezici · Migración 042 · Fixes de QA de contenido (A1 u3-6 + A2)\n"
           "-- Verificados adversarialmente (pedagogical-qa workflow). UPDATE por id.\n"
           "-- ============================================================================\nbegin;\n"
           + "\n".join(rows) + "\ncommit;\n")
    os.makedirs(os.path.dirname(MIG), exist_ok=True)
    open(MIG, 'w', encoding='utf-8').write(sql)
    print(f"[OK] migración escrita: {MIG}  ({len(rows)} updates, {len(skipped)} saltados)")
    for iid, why in skipped:
        print(f"   SALTADO {iid}: {why}")
    if dry:
        print("DRY: no se aplica."); return
    c, o = run(sql)
    print(f"[{c}] aplicar -> {o[:300]}")
    if c not in (200, 201):
        raise SystemExit("FALLÓ la aplicación")
    ver = ("insert into supabase_migrations.schema_migrations(version,name) "
           "values ('20260618140044','content_qa_fixes_b1') on conflict (version) do nothing;")
    run(ver)
    print("[OK] registrada en schema_migrations")

if __name__ == '__main__':
    main()
