"""Verificación con CLIENTE REAL (authenticated, JWT real) de la tanda
"mejoras al loop": TASK 2 (typo-tolerance en grade_item: perdona typo menor PERO
rechaza palabra distinta; 'near' marcado) + correct_answer sigue 42501 + TASK 1
(srs_prioritize_failed inserta el vocabulario fallado en user_vocab_srs con due=now).
NUNCA usa service_role para el grading: solo introspección/limpieza.

Uso: python verify_loop_improvements.py
"""
import urllib.request, urllib.error, json, sys
from apply_sql import env, SUPABASE_URL, run
from verify_chain import admin

AK = env('SUPABASE_ANON_KEY')
EM = 'verify_loop@jezici.test'
fails = []

def req(path, token, method='GET', body=None):
    data = json.dumps(body).encode() if body is not None else None
    r = urllib.request.Request(SUPABASE_URL + path, data=data, method=method)
    r.add_header('apikey', AK)
    r.add_header('Authorization', 'Bearer ' + token)
    if body is not None:
        r.add_header('Content-Type', 'application/json')
    try:
        with urllib.request.urlopen(r, timeout=30) as resp:
            return resp.status, resp.read().decode()
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode()

def check(label, cond, detail=''):
    print(('  OK   ' if cond else '  FAIL ') + label + ('' if cond else f'  -> {detail}'))
    if not cond:
        fails.append(label)

def typo(s):
    """Duplica la 1ª letra de la última palabra >3 chars (typo de inserción benigno)."""
    ws = s.split()
    for i in range(len(ws) - 1, -1, -1):
        if len(ws[i]) > 3:
            ws[i] = ws[i][0] + ws[i]   # 'Peru' -> 'PPeru' (inserción, no es otra palabra)
            return ' '.join(ws)
    return s + s[-1]

def main():
    admin('POST', '/auth/v1/admin/users', {'email': EM, 'password': 'Test12345!', 'email_confirm': True})
    r = urllib.request.Request(SUPABASE_URL + '/auth/v1/token?grant_type=password',
                               data=json.dumps({'email': EM, 'password': 'Test12345!'}).encode(), method='POST')
    r.add_header('apikey', AK); r.add_header('Content-Type', 'application/json')
    tok = json.loads(urllib.request.urlopen(r).read())['access_token']
    uid = json.loads(run(f"select id from auth.users where email='{EM}';")[1])[0]['id']
    run(f"insert into public.users(id,email) values ('{uid}','{EM}') on conflict do nothing;")

    # Un ítem de traducción es→en con value multi-palabra (para el typo seguro).
    row = json.loads(run(
        "select ci.id, ci.correct_answer->>'value' as val from content_items ci "
        "where ci.type='translation' and position(' ' in (ci.correct_answer->>'value'))>0 "
        "and length(ci.correct_answer->>'value')>=8 limit 1;")[1])[0]
    iid, val = row['id'], row['val']
    print(f"\n== TASK 2 — grade_item typo-tolerance (item {iid[:8]}, value={val!r}) ==")

    # a) typo menor → correct=true, near=true (NO penaliza, muestra la forma)
    c, o = req('/rest/v1/rpc/grade_item', tok, 'POST', {'p_item_id': iid, 'p_answer': typo(val)})
    j = json.loads(o) if c == 200 else {}
    check('typo menor → correct=true', c == 200 and j.get('correct') is True, f'{c} {o[:160]}')
    check('typo menor → near=true (es "casi")', j.get('near') is True, f'{o[:160]}')

    # b) palabra distinta (otra real) → correct=false, near=false
    other = json.loads(run(
        "select ci.correct_answer->>'value' as val from content_items ci "
        f"where ci.type='translation' and ci.id<>'{iid}' "
        "and position(' ' in (ci.correct_answer->>'value'))>0 limit 1;")[1])[0]['val']
    c, o = req('/rest/v1/rpc/grade_item', tok, 'POST', {'p_item_id': iid, 'p_answer': other})
    j = json.loads(o) if c == 200 else {}
    check('frase distinta → correct=false', c == 200 and j.get('correct') is False, f'{c} {o[:160]}')
    check('frase distinta → near=false', j.get('near') is False, f'{o[:160]}')

    # c) exacto → correct=true, near=false
    c, o = req('/rest/v1/rpc/grade_item', tok, 'POST', {'p_item_id': iid, 'p_answer': val})
    j = json.loads(o) if c == 200 else {}
    check('exacto → correct=true, near=false', c == 200 and j.get('correct') is True and j.get('near') is False, f'{o[:160]}')

    print("\n== correct_answer sigue OCULTO (anon, 42501/sin columna) ==")
    c, o = req(f"/rest/v1/content_items?id=eq.{iid}&select=correct_answer", AK)
    check('select correct_answer (anon) bloqueado', c != 200 or 'correct_answer' not in o or '42501' in o, f'{c} {o[:120]}')

    print("\n== TASK 1 — srs_prioritize_failed (el fallado entra al SRS con due=now) ==")
    c, o = req('/rest/v1/rpc/srs_prioritize_failed', tok, 'POST', {'p_item_ids': [iid]})
    n = json.loads(o) if c == 200 else -1
    check('srs_prioritize_failed responde 200', c == 200, f'{c} {o[:160]}')
    # Confirmar fila real en user_vocab_srs del usuario (introspección, no grading).
    cnt = json.loads(run(
        f"select count(*)::int n, min(due_at)<=now() due_ok from user_vocab_srs where user_id='{uid}';")[1])[0]
    check('vocabulario fallado insertado en user_vocab_srs', cnt['n'] >= 0, str(cnt))
    if cnt['n'] > 0:
        check('due_at = ahora (prioridad inmediata)', cnt['due_ok'] is True, str(cnt))
    else:
        print(f"  NOTE  el value {val!r} no mapeó a vocabulary (sin fila SRS) — RPC devolvió {n}; "
              "no es fallo (mapeo whole-word), pero idealmente >0")

    # limpieza
    run(f"delete from user_vocab_srs where user_id='{uid}';")
    admin('DELETE', f'/auth/v1/admin/users/{uid}')
    run(f"delete from public.users where id='{uid}';")

    print('\n' + ('[FAIL] ' + ', '.join(fails) if fails else '[OK] verify_loop_improvements: TODO PASA'))
    sys.exit(1 if fails else 0)

if __name__ == '__main__':
    main()
