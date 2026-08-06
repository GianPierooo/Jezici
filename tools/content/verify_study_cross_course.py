# -*- coding: utf-8 -*-
"""Verificacion cliente real del bug/fix de Estudiar (cruce de idioma).

La causa raiz era 100% de CLIENTE (Riverpod: `referenceProvider` no se
invalidaba al cambiar de curso activo) -- el SERVIDOR (get_reference /
get_study_theory) SIEMPRE fue correcto (deriva el curso del unit_id o de
jz_active_course()). Este script re-confirma ese contrato servidor con
CLIENTE REAL (JWT), que es la premisa sobre la que se apoya el fix de
cliente (si el servidor mintiera, invalidar la cache no arreglaria nada).
"""
import verify_placement_serious as V
import _introspect as I

EN = '20000000-0000-0000-0000-000000000001'
PT = '20000000-0000-0000-0000-000000000002'
RO = '20000000-0000-0000-0000-000000000007'


def main():
    ok = True
    def check(cond, label, extra=''):
        nonlocal ok
        ok = ok and cond
        print(('  OK ' if cond else '  XX ') + label + (('  ' + str(extra)) if extra else ''))

    tok, uid = V.mk_user('verify_estudiar@jezici.test')
    V.rpc(tok, 'submit_age_gate', {'p_birth_year': 1990})

    u1_en = I.run("select id from units where course_id='%s' and order_index=1;" % EN)[0]['id']
    u1_pt = I.run("select id from units where course_id='%s' and order_index=1;" % PT)[0]['id']
    u1_ro = I.run("select id from units where course_id='%s' and order_index=1;" % RO)[0]['id']

    # 1 · get_study_theory: el curso se deriva del UNIT_ID (no de jz_active_course),
    #     asi que es correcto SIN IMPORTAR cual sea el curso activo del usuario.
    V.rpc(tok, 'set_active_course', {'p_course_id': EN})
    t_en = V.rpc(tok, 'get_study_theory', {'p_unit_id': u1_en})
    t_pt = V.rpc(tok, 'get_study_theory', {'p_unit_id': u1_pt})  # activo=EN, pide unidad de PT
    check(t_en is not None and t_en.get('title'), 'get_study_theory(unidad EN) -> teoria EN', t_en.get('title') if t_en else None)
    check(t_pt is not None and t_pt.get('title'), 'get_study_theory(unidad PT) -> teoria PT AUNQUE el activo sea EN', t_pt.get('title') if t_pt else None)
    check(t_en.get('title') != t_pt.get('title'), 'los titulos DIFIEREN (no hay fuga de un idioma al otro)')

    # 2 · ro (aun sin E-2 ni E-1 -- confirmado abajo): get_study_theory -> null,
    #     estado honesto "teoria en camino", NUNCA el contenido de otro curso.
    t_ro = V.rpc(tok, 'get_study_theory', {'p_unit_id': u1_ro})
    check(t_ro is None, 'get_study_theory(unidad RO) -> null (aun sin E-2): estado honesto, no fallback a otro idioma')

    # 3 · get_reference: SIEMPRE deriva del curso ACTIVO (jz_active_course()) --
    #     cambiar el activo cambia lo que devuelve, sin necesidad de pasar curso.
    V.rpc(tok, 'set_active_course', {'p_course_id': EN})
    ref_en = V.rpc(tok, 'get_reference', {})
    V.rpc(tok, 'set_active_course', {'p_course_id': PT})
    ref_pt = V.rpc(tok, 'get_reference', {})
    tips_en = {x['id'] for x in (ref_en.get('tips') or [])}
    tips_pt = {x['id'] for x in (ref_pt.get('tips') or [])}
    check(len(tips_en) > 0 and len(tips_pt) > 0, 'get_reference sirve tips para EN y para PT', (len(tips_en), len(tips_pt)))
    check(tips_en.isdisjoint(tips_pt), '0 CRUCES: ningun tip se comparte entre EN y PT', len(tips_en & tips_pt))

    V.rpc(tok, 'set_active_course', {'p_course_id': RO})
    ref_ro = V.rpc(tok, 'get_reference', {})
    check((ref_ro.get('tips') or []) == [], 'get_reference(activo=RO) -> 0 tips (RO sin E-1 todavia): honesto, no arrastra EN/PT')

    # 4 · cobertura E-2 real (para el reporte): que cursos tienen teoria rica.
    cov = I.run("""select l.code target, count(distinct st.unit_order) n
                     from courses c join languages l on l.id=c.target_language_id
                     left join study_theory st on st.course_id=c.id
                    group by l.code order by l.code;""")
    print('\n  Cobertura E-2 (unidades con teoria rica por curso):')
    for r in cov:
        print('    %-4s %s' % (r['target'], r['n']))

    print('\n' + ('TODO VERDE' if ok else 'HAY FALLOS'))
    return 0 if ok else 1


if __name__ == '__main__':
    raise SystemExit(main())
