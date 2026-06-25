"""Verificación con CLIENTE REAL (authenticated, JWT) del test de ubicación preciso
+ puente nivel→arranque. Simula PERSONAS (A1..C1) que responden bien hasta su nivel y
mal por encima, conduce el adaptativo placement_next (server-graded) y comprueba que:
  · el nivel devuelto = el nivel real de la persona (falla A resuelta),
  · create_plan coloca al usuario en la UNIDAD de su nivel (falla B resuelta),
  · correct_answer nunca se expone (42501) y placement_next no lo incluye.
NUNCA usa service_role para calificar; solo introspección (saber la respuesta = simular
que la persona la conoce) y limpieza.

Uso: python verify_placement.py
"""
import urllib.request, urllib.error, json, sys
from apply_sql import env, SUPABASE_URL, run
from verify_chain import admin

AK = env('SUPABASE_ANON_KEY')
RANK = {'A1': 0, 'A2': 1, 'B1': 2, 'B2': 3, 'C1': 4}
CEFR = ['A1', 'A2', 'B1', 'B2', 'C1']
ES_EN = '20000000-0000-0000-0000-000000000001'
fails = []

def req(path, token, method='GET', body=None):
    data = json.dumps(body).encode() if body is not None else None
    r = urllib.request.Request(SUPABASE_URL + path, data=data, method=method)
    r.add_header('apikey', AK); r.add_header('Authorization', 'Bearer ' + token)
    if body is not None: r.add_header('Content-Type', 'application/json')
    try:
        with urllib.request.urlopen(r, timeout=30) as resp:
            return resp.status, resp.read().decode()
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode()

def check(label, cond, detail=''):
    print(('  OK   ' if cond else '  FAIL ') + label + ('' if cond else f'  -> {detail}'))
    if not cond: fails.append(label)

def answer_for(item, persona_rank):
    """La persona acierta sii el ítem es de su nivel o inferior."""
    iid = item['id']
    row = json.loads(run(
        "select correct_answer->>'value' v, payload->'options' opts from content_items where id='%s';" % iid)[1])[0]
    correct_val = row['v']; opts = row['opts'] or []
    item_rank = RANK.get(item['cefr_level'], 0)
    if item_rank <= persona_rank:
        return correct_val               # la sabe
    # por encima de su nivel: elige una opción incorrecta
    for o in opts:
        if o != correct_val:
            return o
    return ''  # sin distractor (no debería pasar)

def run_persona(tok, persona_level, hint):
    persona_rank = RANK[persona_level]
    history = []
    leaked = False
    for _ in range(20):
        c, o = req('/rest/v1/rpc/placement_next', tok, 'POST',
                   {'p_course': ES_EN, 'p_start_level': hint, 'p_history': history})
        if c != 200:
            return None, c, o, leaked
        j = json.loads(o)
        if j.get('done'):
            return j, c, o, leaked
        it = j['item']
        if 'correct_answer' in it or 'correct_answer' in (it.get('payload') or {}):
            leaked = True
        history.append({'item_id': it['id'], 'answer': answer_for(it, persona_rank)})
    return None, 0, 'no convergió en 20', leaked

def new_user(email):
    admin('POST', '/auth/v1/admin/users', {'email': email, 'password': 'Test12345!', 'email_confirm': True})
    r = urllib.request.Request(SUPABASE_URL + '/auth/v1/token?grant_type=password',
                               data=json.dumps({'email': email, 'password': 'Test12345!'}).encode(), method='POST')
    r.add_header('apikey', AK); r.add_header('Content-Type', 'application/json')
    tok = json.loads(urllib.request.urlopen(r).read())['access_token']
    uid = json.loads(run("select id from auth.users where email='%s';" % email)[1])[0]['id']
    run("insert into public.users(id,email) values ('%s','%s') on conflict do nothing;" % (uid, email))
    return tok, uid

def main():
    # ── A) PRECISIÓN: cada persona debe ubicarse en SU nivel ──────────────────
    print("== A) Placement adaptativo server-graded: persona → nivel devuelto ==")
    cases = [('A1', 'A1'), ('A2', 'A1'), ('B1', 'A2'), ('B2', 'B1'), ('B2', 'A2'), ('C1', 'B1')]
    for persona, hint in cases:
        em = f'plc_{persona.lower()}_{hint.lower()}@jezici.test'
        tok, uid = new_user(em)
        res, c, o, leaked = run_persona(tok, persona, hint)
        if res is None:
            check(f'persona {persona} (hint {hint}) converge', False, f'{c} {o[:140]}')
        else:
            got = res.get('level'); asked = res.get('asked')
            # tolerancia ±0: el estimador techo debe clavar el nivel de la persona.
            check(f'persona {persona} (hint {hint}) → {got} en {asked} preg.', got == persona,
                  f'esperado {persona}, dio {got}; skill_levels={res.get("skill_levels")}')
            check(f'persona {persona}: placement_next NO filtra correct_answer', not leaked)
        run("delete from public.users where id='%s';" % uid)
        admin('DELETE', f'/auth/v1/admin/users/{uid}')

    # ── B) PUENTE: create_plan coloca en la unidad del nivel ──────────────────
    print("\n== B) Puente nivel→arranque: create_plan ubica en contenido del nivel ==")
    for lvl, want_oi, want_skipped in [('B2', 19, True), ('A1', 1, False)]:
        em = f'plcbridge_{lvl.lower()}@jezici.test'
        tok, uid = new_user(em)
        sk = {s: lvl for s in ['reading', 'listening', 'writing', 'speaking']}
        c, o = req('/rest/v1/rpc/create_plan', tok, 'POST', {
            'p_coach_style': 'suave', 'p_intensity': 2, 'p_current_level': lvl, 'p_goal_level': 'C1',
            'p_daily_minutes': 10, 'p_days_per_week': 5, 'p_motive': 'viaje', 'p_deadline': None,
            'p_estimated_hours': 100, 'p_estimated_completion': None, 'p_skill_levels': sk})
        check(f'create_plan({lvl}) 200', c == 200, f'{c} {o[:140]}')
        # unidad actual = del nivel pedido
        cur = json.loads(run(
            "select u.order_index oi, u.cefr_level::text lvl from user_course_progress p "
            "join units u on u.id=p.current_unit_id where p.user_id='%s';" % uid)[1])
        check(f'{lvl}: unidad actual es de nivel {lvl}', cur and cur[0]['lvl'] == lvl,
              str(cur))
        # primer nodo disponible (orden de mapa) está en una unidad del nivel
        firstav = json.loads(run(
            "select u.cefr_level::text lvl, u.order_index uoi from user_lesson_progress ulp "
            "join lessons l on l.id=ulp.lesson_id join units u on u.id=l.unit_id "
            "where ulp.user_id='%s' and ulp.status='available' "
            "order by u.order_index, l.order_index limit 1;" % uid)[1])
        check(f'{lvl}: 1er nodo disponible es de nivel {lvl}', firstav and firstav[0]['lvl'] == lvl,
              str(firstav))
        # lecciones por debajo marcadas completadas (o ninguna si A1)
        skipped = json.loads(run(
            "select count(*) n from user_lesson_progress ulp join lessons l on l.id=ulp.lesson_id "
            "join units u on u.id=l.unit_id where ulp.user_id='%s' and ulp.status='completed' "
            "and u.order_index < %d;" % (uid, want_oi))[1])[0]['n']
        if want_skipped:
            check(f'{lvl}: contenido inferior marcado completado', skipped > 0, f'completed={skipped}')
        else:
            check(f'A1: nada por debajo que completar', skipped == 0, f'completed={skipped}')
        run("delete from user_lesson_progress where user_id='%s';" % uid)
        run("delete from public.users where id='%s';" % uid)
        admin('DELETE', f'/auth/v1/admin/users/{uid}')

    # ── C) correct_answer sigue OCULTO (anon) en ítems de placement ───────────
    print("\n== C) correct_answer de placement OCULTO (anon, 42501/sin columna) ==")
    pid = json.loads(run("select id from content_items where 'placement'=any(tags) "
                         "and course_id='%s' limit 1;" % ES_EN)[1])[0]['id']
    c, o = req(f"/rest/v1/content_items?id=eq.{pid}&select=correct_answer", AK)
    check('select correct_answer (anon) bloqueado', c != 200 or 'correct_answer' not in o or '42501' in o, f'{c} {o[:120]}')

    print('\n' + ('[FAIL] ' + ', '.join(fails) if fails else '[OK] verify_placement: TODO PASA'))
    sys.exit(1 if fails else 0)

if __name__ == '__main__':
    main()
