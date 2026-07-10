# -*- coding: utf-8 -*-
"""Verificación REAL (flujo humano, cliente JWT) del placement de 4 HABILIDADES
(mig 135/136 en+pt · mig 139 fr/it/de/nl) en LOS 6 CURSOS:
  1. COBERTURA: el examen sirve las 4 skills (reading/listening/writing/speaking).
  2. AZAR → nivel bajo en las 4 (speaking sin opciones → transcripción basura).
  3. PERSONA fuerte-en-reading / floja-en-listening → skill_levels.reading >
     skill_levels.listening (perfil DIFERENCIADO, no global ×4).
  4. AISLAMIENTO: ítems solo del curso activo. 5. LARGO dentro de 10-16.
python verify_placement_4skills.py [códigos… p.ej. fr it de nl]"""
import json
import random
import sys
from collections import Counter

import verify_placement_serious as V

COURSES = {
    'en': '20000000-0000-0000-0000-000000000001',
    'pt': '20000000-0000-0000-0000-000000000002',
    'fr': '20000000-0000-0000-0000-000000000003',
    'it': '20000000-0000-0000-0000-000000000004',
    'de': '20000000-0000-0000-0000-000000000005',
    'nl': '20000000-0000-0000-0000-000000000006',
}

RANK = {'A1': 0, 'A2': 1, 'B1': 2, 'B2': 3, 'C1': 4}


def full_run(tok, C, answerer, rng):
    """Corre el examen completo; devuelve (result, skills_servidas, n, cursos_ok)."""
    hist = []
    skills = set()
    course_ok = True
    while True:
        r = V.rpc(tok, 'placement_next', {'p_course': C, 'p_start_level': 'B1', 'p_history': hist})
        if r.get('done'):
            return r, skills, r['asked'], course_ok
        it = r['item']
        skills.add(it['skill'])
        opts = (it.get('payload') or {}).get('options') or []
        hist.append({'item_id': it['id'], 'answer': answerer(it, opts, rng)})


def azar_ans(it, opts, rng):
    # Como un humano clicando sin leer; en speaking (sin opciones) balbucea.
    return rng.choice(opts) if opts else 'blah blah'


def persona_RW_fuerte_L_floja(it, opts, rng):
    """Persona DETERMINISTA caso-límite (aserción repetible, sin flakiness):
    PERFECTA en reading/writing/speaking a cualquier nivel, y no entiende NADA
    de audio (listening siempre mal). Prueba el MECANISMO por-skill limpio:
    global acredita B2 (solo los fallos de listening restan), listening (n>=3,
    acc 0) DEMOTE 1 nivel, reading (acc 1.0) queda en el global → reading >
    listening en TODAS las corridas, jamás al revés."""
    correct = V._CORRECT.get(it['id'])
    if it['skill'] == 'listening' or correct is None:
        wrong = [o for o in opts if o != correct]
        return wrong[0] if wrong else 'x'
    return correct


def main():
    rows = json.loads(V.run("select id, correct_answer->>'value' v from content_items where 'placement'=any(tags);")[1])
    for r in rows:
        V._CORRECT[r['id']] = r['v']

    passed = True
    def ck(name, cond, detail=''):
        nonlocal passed
        print(('  OK  ' if cond else '  XX  ') + name + ('  ' + detail if detail else ''))
        passed = passed and cond

    codes = sys.argv[1:] or ['en', 'pt', 'fr', 'it', 'de', 'nl']
    tok, uid = V.mk_user('verify4sk@test.jezici.dev')
    try:
        for code in codes:
            C = COURSES[code]
            V.rpc(tok, 'set_active_course', {'p_course_id': C})
            rng = random.Random(42)

            # 1+5) Cobertura de skills + largo (persona, 4 corridas).
            all_skills = set()
            ns = []
            diffs = []
            for _ in range(4):
                res, sk, n, _ = full_run(tok, C, persona_RW_fuerte_L_floja, rng)
                all_skills |= sk
                ns.append(n)
                lv = res['skill_levels']
                diffs.append((lv['reading'], lv['listening']))
            ck(f'{code}: sirve las 4 habilidades', all_skills == {'reading', 'listening', 'writing', 'speaking'},
               f'{sorted(all_skills)}')
            ck(f'{code}: largo 10-16', all(10 <= n <= 16 for n in ns), f'n={ns}')

            # 3) Perfil DIFERENCIADO: la persona es determinista → reading >
            # listening en TODAS las corridas (y jamás al revés).
            dif = sum(1 for r_, l_ in diffs if RANK[r_] > RANK[l_])
            inv = sum(1 for r_, l_ in diffs if RANK[l_] > RANK[r_])
            ck(f'{code}: fuerte-R/floja-L → reading>listening (4/4, 0 invertidas)',
               dif == 4 and inv == 0, f'{diffs}')

            # 2) AZAR → bajo en las 4 skills (ninguna B2/C1; a lo sumo 1 caso raro).
            high = 0
            for _ in range(8):
                res, _, _, _ = full_run(tok, C, azar_ans, rng)
                for s, lv in res['skill_levels'].items():
                    if RANK[lv] >= 3:
                        high += 1
            ck(f'{code}: AZAR sin skills B2/C1 (tolerancia 1)', high <= 1, f'altas={high}')

            # 4) Aislamiento: primer ítem pertenece al curso.
            r = V.rpc(tok, 'placement_next', {'p_course': C, 'p_start_level': 'B1', 'p_history': []})
            iid = r['item']['id']
            crs = json.loads(V.run(f"select course_id from content_items where id='{iid}';")[1])[0]['course_id']
            ck(f'{code}: ítems del curso activo', crs == C, crs)
    finally:
        V.admin('DELETE', f'/auth/v1/admin/users/{uid}', None)

    print('\n' + ('TODO VERDE' if passed else 'HAY FALLOS'))
    raise SystemExit(0 if passed else 1)


if __name__ == '__main__':
    main()
