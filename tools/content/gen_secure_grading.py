"""Migración 055 · Cierra el vector correct_answer (grading server-side).
- grade_item(item_id, answer): califica con el matcher tolerante existente (jz_grade)
  y devuelve {correct, graded, expected} — la respuesta canónica SOLO tras responder.
  Soporta content_items y el id sintético de SRS (vocabulary).
- Revoca SELECT de la columna correct_answer al cliente (grant de todas las demás).
- start_practice deja de DEVOLVER correct_answer (el cliente califica vía grade_item).
  (start_checkpoint ya no lo devolvía; start_level_exam tampoco.)
Uso: python gen_secure_grading.py dry|apply
"""
import sys, json, re
from apply_sql import run

MIG = 'C:/Users/gianp/Desktop/Jezici/supabase/migrations/20260620170055_secure_grading.sql'
VERSION = '20260620170055'

def main():
    apply = len(sys.argv) > 1 and sys.argv[1] == 'apply'
    # 1) columnas de content_items (para el grant de todas menos correct_answer)
    c, o = run("select column_name from information_schema.columns where table_name='content_items' and table_schema='public' order by ordinal_position;")
    cols = [r['column_name'] for r in json.loads(o)]
    keep = [c for c in cols if c != 'correct_answer']
    assert 'correct_answer' in cols, 'no existe la columna correct_answer'

    # 2) def viva de start_practice, sin los campos correct_answer del retorno
    c, o = run("select pg_get_functiondef(p.oid) d from pg_proc p join pg_namespace n on n.oid=p.pronamespace where n.nspname='public' and p.proname='start_practice';")
    sp = json.loads(o)[0]['d']
    before = sp.count("'correct_answer'")
    for pat in [r",\s*'correct_answer',\s*jsonb_build_object\('value',\s*d\.word\)",
                r",\s*'correct_answer',\s*x\.correct_answer",
                r",\s*'correct_answer',\s*correct_answer"]:
        sp = re.sub(pat, '', sp)
    # quedan referencias internas (ci.correct_answer en selects) sin usar → inocuas;
    # pero ya NO se construye el campo en el jsonb devuelto al cliente.
    remaining_built = sp.count("'correct_answer'")
    assert remaining_built == 0, f"aún se construye correct_answer en el retorno: {remaining_built}"

    grade_item = """
create or replace function grade_item(p_item_id uuid, p_answer jsonb)
returns jsonb language plpgsql security definer set search_path = public as $fn$
declare uid uuid := auth.uid(); v_type content_item_type; v_correct jsonb; v_word text;
begin
  if uid is null then raise exception 'auth required'; end if;
  select type, correct_answer into v_type, v_correct from content_items where id = p_item_id;
  if found then
    return jsonb_build_object('correct', jz_grade(v_type, v_correct, p_answer),
      'graded', not jz_is_stub(v_type), 'expected', v_correct);
  end if;
  -- Fallback: ítem sintético de SRS (el id es de vocabulary).
  select word into v_word from vocabulary where id = p_item_id;
  if found then
    return jsonb_build_object('correct', jz_normalize(p_answer #>> '{}') = jz_normalize(v_word),
      'graded', true, 'expected', jsonb_build_object('value', v_word));
  end if;
  return jsonb_build_object('correct', false, 'graded', false, 'expected', null);
end $fn$;
grant execute on function grade_item(uuid, jsonb) to authenticated;
"""

    revoke = (f"revoke select on content_items from anon, authenticated;\n"
              f"grant select ({', '.join(keep)}) on content_items to anon, authenticated;\n")

    sql = (f"-- ============================================================================\n"
           f"-- Jezici · Migración 055 · Grading server-side (cierra el vector correct_answer)\n"
           f"-- El cliente ya no puede leer content_items.correct_answer; califica vía\n"
           f"-- grade_item (RPC SECURITY DEFINER) que revela la respuesta SOLO tras responder.\n"
           f"-- ============================================================================\n"
           f"begin;\n{grade_item}\n-- start_practice sin devolver correct_answer:\n{sp};\n\n"
           f"-- Revoca la columna correct_answer al cliente (grant del resto):\n{revoke}\ncommit;\n")
    open(MIG, 'w', encoding='utf-8').write(sql)
    print(f"[OK] migración escrita: {MIG} ({len(sql)} bytes)")
    print(f"   start_practice: correct_answer en retorno {before}->0 · columnas cliente: {len(keep)} (sin correct_answer)")
    if not apply:
        print("DRY: no se aplica."); return
    c, o = run(sql)
    print(f"[{c}] aplicar -> {o[:300]}")
    if c not in (200, 201):
        raise SystemExit("FALLÓ")
    run(f"insert into supabase_migrations.schema_migrations(version,name) values ('{VERSION}','secure_grading') on conflict (version) do nothing;")
    print("[OK] registrada")

if __name__ == '__main__':
    main()
