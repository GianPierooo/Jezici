"""Snapshot del estado de los usuarios REALES (no de prueba) para la migración 041:
nivel por skill, certificados, XP, intentos por ítem. Sirve de baseline de
no-regresión (antes/después). Guarda a tools/content/_users_snapshot_<tag>.json."""
import json, sys
from apply_sql import run

def q(s):
    c, o = run(s)
    if c not in (200, 201):
        sys.exit(f"query falló [{c}]: {o[:300]}")
    return json.loads(o) if o and o.strip().startswith('[') else []

def main():
    tag = sys.argv[1] if len(sys.argv) > 1 else 'pre'
    # Usuarios REALES = no @jezici.test
    users = q("select id, email from public.users where email not like '%@jezici.test' order by email;")
    snap = {}
    for u in users:
        uid, email = u['id'], u['email']
        skills = q(f"select skill, cefr_level from user_skill_levels where user_id='{uid}' order by skill;")
        certs = q(f"select cefr_level, folio from certificates where user_id='{uid}' order by cefr_level;")
        stats = q(f"select xp_total, gold from user_stats where user_id='{uid}';")
        items = q(f"select count(*) n from user_item_attempts where user_id='{uid}';")
        snap[email] = {
            'skills': {s['skill']: s['cefr_level'] for s in skills},
            'certs': sorted(c['cefr_level'] for c in certs),
            'xp': (stats[0]['xp_total'] if stats else None),
            'item_attempts': (items[0]['n'] if items else 0),
        }
    path = f"_users_snapshot_{tag}.json"
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(snap, f, indent=2, ensure_ascii=False)
    print(f"[OK] snapshot '{tag}' de {len(snap)} usuarios reales -> {path}")
    print(json.dumps(snap, indent=2, ensure_ascii=False))

if __name__ == '__main__':
    main()
