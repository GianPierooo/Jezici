"""Genera (y aplica) la migración 057 · Capa "enseña": content_tips + cuaderno.
Lee tips_es_en.json (autorado por workflow tips-author) y emite:
- tabla content_tips (contenido público, RLS lectura) + 72 tips sembrados.
- tabla user_tip_progress (tips vistos = cuaderno) + RLS self.
- get_lesson_tip(p_unit_order): tip de la unidad personalizado a la skill MÁS DÉBIL
  del usuario, no visto recientemente; lo marca como visto; devuelve {tip}.
- get_notebook(): tips vistos del usuario (cuaderno).
Uso: python gen_tips.py dry | apply
"""
import sys, json
from apply_sql import run

MIG = 'C:/Users/gianp/Desktop/Jezici/supabase/migrations/20260620190057_content_tips.sql'
VERSION = '20260620190057'
COURSE = '20000000-0000-0000-0000-000000000001'  # es→en

def dq(s, tag='t'):
    s = '' if s is None else str(s)
    if f'${tag}$' in s:
        tag = 'tt'
    return f'${tag}${s}${tag}$'

def cefr(u):
    return 'A1' if u <= 6 else 'A2' if u <= 12 else 'B1' if u <= 18 else 'B2'

def main():
    apply = len(sys.argv) > 1 and sys.argv[1] == 'apply'
    tips = json.load(open('tips_es_en.json', encoding='utf-8'))['tips']
    rows = []
    for t in tips:
        u = int(t['unit'])
        rows.append(
            f" ('{COURSE}',{u},'{cefr(u)}','{t['skill']}','{t['type']}',"
            f"{dq(t['title'])},{dq(t['body'])},{dq(t.get('example'))})")

    preamble = """-- ============================================================================
-- Jezici · Migración 057 · Capa "enseña, no solo evalúa" (content_tips + cuaderno)
-- Tips curados (autores como profesores → QA → adversarial → validador). Contenido
-- público (sin respuestas): RLS de lectura. Personalización por skill débil en RPC.
-- ============================================================================
begin;

create table if not exists content_tips (
  id         uuid primary key default gen_random_uuid(),
  course_id  uuid not null references courses(id) on delete cascade,
  unit_order int  not null,
  cefr_level text not null,
  skill      text not null,
  type       text not null,  -- tip_idioma|nota_cultural|error_comun|pronunciacion|mnemotecnia
  title      text not null,
  body       text not null,
  example    text,
  created_at timestamptz not null default now()
);
create index if not exists content_tips_unit_idx on content_tips (course_id, unit_order, skill);
alter table content_tips enable row level security;
do $p$ begin
  create policy content_tips_read on content_tips for select to anon, authenticated using (true);
exception when duplicate_object then null; end $p$;
grant select on content_tips to anon, authenticated;

-- Cuaderno: tips vistos por el usuario.
create table if not exists user_tip_progress (
  user_id    uuid not null references auth.users(id) on delete cascade,
  tip_id     uuid not null references content_tips(id) on delete cascade,
  seen_at    timestamptz not null default now(),
  times_seen int not null default 1,
  primary key (user_id, tip_id)
);
alter table user_tip_progress enable row level security;
do $p$ begin
  create policy utp_self on user_tip_progress for all
    using (user_id = auth.uid()) with check (user_id = auth.uid());
exception when duplicate_object then null; end $p$;

-- Re-siembra idempotente: limpia y reinserta los tips del curso.
delete from content_tips where course_id = '%COURSE%';
insert into content_tips (course_id, unit_order, cefr_level, skill, type, title, body, example) values
""".replace('%COURSE%', COURSE)

    rpcs = """;

-- Tip post-lección: resuelve la unidad desde el lesson_id, elige un tip de esa
-- unidad PERSONALIZADO a la skill más débil del usuario, no visto recientemente;
-- lo marca como visto (cuaderno) y lo devuelve.
drop function if exists get_lesson_tip(int);
create or replace function get_lesson_tip(p_lesson_id uuid)
returns jsonb language plpgsql security definer set search_path = public as $fn$
declare uid uuid := auth.uid(); v_course uuid; v_unit int; v_weak text; v_tip content_tips%rowtype;
begin
  if uid is null then raise exception 'auth required'; end if;
  v_course := jz_active_course();
  select u.order_index into v_unit from lessons l join units u on u.id = l.unit_id where l.id = p_lesson_id;
  if v_unit is null then return null; end if;
  select s into v_weak from unnest(array['reading','listening','writing','speaking']) s
    order by jz_reinforce_score(uid, v_course, s::skill) desc,
             array_position(array['reading','listening','writing','speaking'], s) limit 1;
  select * into v_tip from content_tips t
   where t.course_id = v_course and t.unit_order = v_unit
   order by (t.skill = v_weak) desc,
            (not exists (select 1 from user_tip_progress up where up.user_id = uid and up.tip_id = t.id)) desc,
            random()
   limit 1;
  if v_tip.id is null then return null; end if;
  insert into user_tip_progress(user_id, tip_id) values (uid, v_tip.id)
    on conflict (user_id, tip_id) do update set seen_at = now(), times_seen = user_tip_progress.times_seen + 1;
  return jsonb_build_object('id', v_tip.id, 'type', v_tip.type, 'skill', v_tip.skill,
    'cefr_level', v_tip.cefr_level, 'title', v_tip.title, 'body', v_tip.body,
    'example', v_tip.example, 'weak_skill', v_weak);
end $fn$;
grant execute on function get_lesson_tip(uuid) to authenticated;

-- Cuaderno: tips vistos del usuario (navegable).
create or replace function get_notebook()
returns jsonb language plpgsql security definer set search_path = public as $fn$
declare uid uuid := auth.uid();
begin
  if uid is null then raise exception 'auth required'; end if;
  return coalesce((select jsonb_agg(jsonb_build_object('id', t.id, 'type', t.type, 'skill', t.skill,
      'cefr_level', t.cefr_level, 'unit_order', t.unit_order, 'title', t.title, 'body', t.body,
      'example', t.example, 'seen_at', up.seen_at) order by up.seen_at desc)
    from user_tip_progress up join content_tips t on t.id = up.tip_id where up.user_id = uid), '[]'::jsonb);
end $fn$;
grant execute on function get_notebook() to authenticated;

commit;
"""
    sql = preamble + ',\n'.join(rows) + rpcs
    open(MIG, 'w', encoding='utf-8').write(sql)
    print(f"[OK] migracion escrita: {MIG} ({len(rows)} tips, {len(sql)} bytes)")
    if not apply:
        print("DRY: no se aplica."); return
    c, o = run(sql)
    print(f"[{c}] aplicar -> {o[:300]}")
    if c not in (200, 201):
        raise SystemExit("FALLO")
    run(f"insert into supabase_migrations.schema_migrations(version,name) values ('{VERSION}','content_tips') on conflict (version) do nothing;")
    print("[OK] registrada")

if __name__ == '__main__':
    main()
