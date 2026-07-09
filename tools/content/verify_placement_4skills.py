# -*- coding: utf-8 -*-
"""Verificación REAL (flujo humano, cliente JWT) del placement de 4 HABILIDADES
(mig 135) en 2 cursos (en, pt):
  1. COBERTURA: el examen sirve las 4 skills (reading/listening/writing/speaking).
  2. AZAR → nivel bajo en las 4 (speaking sin opciones → transcripción basura).
  3. PERSONA fuerte-en-reading / floja-en-listening → skill_levels.reading >
     skill_levels.listening (perfil DIFERENCIADO, no global ×4).
  4. AISLAMIENTO: ítems solo del curso activo. 5. LARGO dentro de 10-16.
python verify_placement_4skills.py"""
import json
import random
from collections import Counter

import verify_placement_serious as V

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
    """Sabe reading/writing/speaking hasta B1 (0.9); en LISTENING no entiende el
    audio → responde MAL (elige una opción incorrecta, como quien oye ruido)."""
    correct = V._CORRECT.get(it['id'])
    if it['skill'] == 'listening':
        wrong = [o for o in opts if o != correct]
        return rng.choice(wrong) if wrong else 'x'
    if RANK.get(it.get('cefr_level'), 0) <= 2 and correct is not None and rng.random() < 0.9:
        return correct
    return rng.choice(opts) if opts else 'x'


def main():
    rows = json.loads(V.run("select id, correct_answer->>'value' v from content_items where 'placement'=any(tags);")[1])
    for r in rows:
        V._CORRECT[r['id']] = r['v']

    passed = True
    def ck(name, cond, detail=''):
        nonlocal passed
        print(('  OK  ' if cond else '  XX  ') + name + ('  ' + detail if detail else ''))
        passed = passed and cond

    tok, uid = V.mk_user('verify4sk@test.jezici.dev')
    try:
        for code in ['en', 'pt']:
            C = V.COURSES[code]
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

            # 3) Perfil DIFERENCIADO: fuerte-R/floja-L → reading > listening en
            # >=3 de 4 corridas (demote-only exige >=3 ítems L fallados + global
            # >=A2; una corrida puede caer a global A1 por la brevedad del CAT).
            dif = sum(1 for r_, l_ in diffs if RANK[r_] > RANK[l_])
            ck(f'{code}: fuerte-R/floja-L → reading>listening (>=3/4)', dif >= 3,
               f'{diffs} (diferenciadas={dif}/4)')

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
