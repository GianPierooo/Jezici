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

# Estimador guess-aware (mig 131): nivel ACREDITADO = mayor r con asked>=3,
# corr>=ceil(0.72*asked) y corr>=3; sin fallback laxo; piso global acc<0.5 -> tope A2.
CASES = [
    # Evidencia SOSTENIDA -> acredita el nivel.
    ('B1 sostenido (3/3 en A1,A2,B1)', [0, 0, 0, 1, 1, 1, 2, 2, 2], [1] * 9, 2),
    ('B2 solido (3/3 hasta B2)', [0, 0, 0, 1, 1, 1, 2, 2, 2, 3, 3, 3], [1] * 12, 3),
    ('C1 real (3/3 hasta C1)', [0, 0, 0, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4], [1] * 15, 4),
    # AZAR / fluke -> A1 (lo que rompia antes).
    ('aciertos altos SUELTOS (asked<3 por nivel) -> A1', [2, 3, 4, 3, 2, 4], [1, 1, 1, 1, 1, 1], 0),
    ('B1 al 50% (3/6) NO acredita (azar) -> A1', [2, 2, 2, 2, 2, 2], [1, 1, 1, 0, 0, 0], 0),
    ('azar disperso 1/3 (12 items) -> A1', [0, 0, 1, 1, 2, 2, 0, 1, 2, 0, 1, 2],
     [1, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0], 0),
    # PISO global: B1 acreditado pero acc total <0.5 -> tope A2.
    ('piso: B1 ok pero acc total <0.5 -> tope A2',
     [0, 0, 0, 1, 1, 1, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3],
     [1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 1),
    # A1 real (solo domina A1).
    ('A1 consistente (4/4 A1, falla A2)', [0, 0, 0, 0, 1, 1, 1], [1, 1, 1, 1, 0, 0, 0], 0),
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
