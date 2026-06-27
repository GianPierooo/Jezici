"""Validador DETERMINISTA del estimador de placement v2 (jz_placement_level, mig 089).
Llama a la función con arrays crafteados y comprueba el "techo con evidencia": un nivel
solo se domina con asked>=2, correct>=2 y acc>=2/3; un acierto SUELTO en alto NO promueve
(el bug del v1, que daba C1). Usa service_role (la función está revocada al cliente; esto es
introspección, no grading). Uso: python verify_estimator.py
"""
import json, sys
from apply_sql import run

def lvl(ranks, corr):
    rk = 'ARRAY[' + ','.join(str(x) for x in ranks) + ']'
    ck = 'ARRAY[' + ','.join('true' if x else 'false' for x in corr) + ']'
    return json.loads(run('select jz_placement_level(%s::int[], %s::boolean[]) v;' % (rk, ck))[1])[0]['v']

CASES = [
    ('B1 consistente + B2/C1 aciertos SUELTOS (v1 daba C1)', [1, 2, 2, 3, 4], [1, 1, 1, 1, 1], 2),
    ('3 aciertos sueltos en alto, sin evidencia (v1 daba C1)', [2, 3, 4], [1, 1, 1], 0),
    ('B1 solido + 1 fluke C1', [0, 1, 2, 2, 2, 3, 3, 4], [1, 1, 1, 1, 1, 0, 0, 1], 2),
    ('A1 consistente', [0, 0, 0, 1, 1], [1, 1, 1, 0, 0], 0),
    ('B2 consistente (asked2 corr2 c/u)', [2, 2, 3, 3, 4, 4], [1, 1, 1, 1, 0, 0], 3),
    ('C1 real (2 aciertos C1)', [2, 3, 3, 4, 4], [1, 1, 1, 1, 1], 4),
    ('B1: B2 al 50% NO promueve', [2, 2, 3, 3], [1, 1, 1, 0], 2),
]

def main():
    fails = 0
    for d, r, c, exp in CASES:
        got = lvl(r, c)
        ok = got == exp
        if not ok:
            fails += 1
        print(('  OK   ' if ok else '  FAIL ') + '%-46s esperado=%d got=%d' % (d, exp, got))
    print('\n' + ('[FAIL] %d casos' % fails if fails else '[OK] verify_estimator: TODO PASA (%d casos)' % len(CASES)))
    sys.exit(1 if fails else 0)

if __name__ == '__main__':
    main()
