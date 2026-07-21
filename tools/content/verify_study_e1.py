# -*- coding: utf-8 -*-
"""ESTUDIAR · Fase E-1 — verificación con CLIENTE REAL (JWT) de que la estructura
del nuevo tab y su DESBLOQUEO salen de datos reales, no inventados:
  · get_reference (RPC real) devuelve la teoría del curso con unit_order/cefr_level
    y esos unit_order casan con units.order_index → la teoría se ata a su tema.
  · user_lesson_progress (REST con RLS, la MISMA fuente que lee el cliente) manda
    el desbloqueo: replicamos aquí la derivación de buildStudyPlan y comprobamos
    que un usuario nuevo solo tiene abierto el tema que YA alcanzó en el mapa, y
    que al avanzar se abre el siguiente. Sin gating paralelo.
uso: python verify_study_e1.py
"""
import json
import urllib.request
import verify_placement_serious as V
from apply_sql import SUPABASE_URL
import _introspect as I

EN = '20000000-0000-0000-0000-000000000001'


def rest(tok, path):
    r = urllib.request.Request(SUPABASE_URL + '/rest/v1/' + path, method='GET')
    r.add_header('apikey', V.AK)
    r.add_header('Authorization', 'Bearer ' + tok)
    with urllib.request.urlopen(r, timeout=60) as x:
        return json.loads(x.read().decode())


def build_plan(units, progress, tips):
    """Réplica EXACTA de buildStudyPlan (features/study/study_model.dart)."""
    by_unit = {}
    for t in tips:
        u = t.get('unit_order')
        if u is not None:
            by_unit.setdefault(u, []).append(t)
    out = []
    for u in sorted(units, key=lambda x: x['order_index']):
        done = reached = 0
        for l in u['lessons']:
            s = progress.get(l['id'])
            is_done = s in ('completed', 'golden')
            is_open = s in ('available', 'in_progress')
            if is_done:
                done += 1
            if is_done or is_open:
                reached += 1
        out.append({
            'order': u['order_index'], 'level': u['cefr_level'], 'title': u['title'],
            'unlocked': reached > 0, 'done': done, 'total': len(u['lessons']),
            'tips': len(by_unit.get(u['order_index'], [])),
        })
    return out


def main():
    ok = True

    def check(cond, label):
        nonlocal ok
        ok = ok and cond
        print(('  OK ' if cond else '  XX ') + label)

    # Unidades + lecciones REALES del curso en (lo que el cliente pinta en el mapa).
    units = I.run("""
      select u.id, u.order_index, u.cefr_level, u.title,
             coalesce((select jsonb_agg(jsonb_build_object('id', l.id) order by l.order_index)
                       from lessons l where l.unit_id = u.id), '[]'::jsonb) lessons
      from units u where u.course_id = '%s' order by u.order_index;""" % EN)
    for u in units:
        u['lessons'] = u['lessons'] if isinstance(u['lessons'], list) else json.loads(u['lessons'])
    check(len(units) > 0, 'unidades reales del curso (%d)' % len(units))

    tok, uid = V.mk_user('studye1@test.jezici.dev')
    V.rpc(tok, 'submit_age_gate', {'p_birth_year': 1990})
    V.rpc(tok, 'set_active_course', {'p_course_id': EN})
    V.rpc(tok, 'create_plan', {
        'p_coach_style': 'suave', 'p_intensity': 3, 'p_current_level': 'A1',
        'p_goal_level': 'B2', 'p_daily_minutes': 20, 'p_days_per_week': 5,
        'p_motive': 'viaje', 'p_deadline': None, 'p_estimated_hours': 300,
        'p_estimated_completion': None, 'p_skill_levels': None})

    # ── La TEORÍA que el tab muestra viene de get_reference (RPC real) ──
    ref = V.rpc(tok, 'get_reference', {})
    tips = ref.get('tips') or []
    check(len(tips) > 0, 'get_reference devuelve teoría existente (%d conceptos)' % len(tips))
    with_unit = [t for t in tips if t.get('unit_order') is not None]
    check(len(with_unit) == len(tips), 'todos los conceptos traen unit_order (se atan a un tema)')
    unit_orders = {u['order_index'] for u in units}
    orphan = [t for t in with_unit if t['unit_order'] not in unit_orders]
    check(not orphan, 'ningún concepto queda huérfano (unit_order casa con una unidad real)')
    lvls = {t.get('cefr_level') for t in tips}
    check(lvls, 'la teoría trae nivel CEFR para agrupar (%s)' % ','.join(sorted(x for x in lvls if x)))

    # ── El DESBLOQUEO sale del progreso REAL (misma tabla que lee el cliente) ──
    prog = {r['lesson_id']: r['status']
            for r in rest(tok, 'user_lesson_progress?select=lesson_id,status')}
    plan = build_plan(units, prog, tips)
    unlocked = [t for t in plan if t['unlocked']]
    print('  [plan inicial] abiertos=%d de %d · primero=%s'
          % (len(unlocked), len(plan), unlocked[0]['title'] if unlocked else '—'))
    check(len(unlocked) >= 1, 'el usuario nuevo tiene al menos el PRIMER tema abierto')
    check(unlocked[0]['order'] == 1, 'el tema abierto es la unidad 1 (donde está en el mapa)')
    check(all(not t['unlocked'] for t in plan if t['order'] > 2),
          'las unidades lejanas siguen BLOQUEADAS (candado real, no decorativo)')
    # el tema abierto ya tiene teoría que mostrar
    check(unlocked[0]['tips'] > 0,
          'el tema abierto YA tiene teoría que mostrar (%d conceptos)' % unlocked[0]['tips'])
    # los temas sin teoría existen y son honestos (C1 aún no tiene tips)
    sin = [t for t in plan if t['tips'] == 0]
    print('  [huecos honestos] %d temas sin teoría todavía (estado "teoría en camino")' % len(sin))

    # ── Avanzar en el mapa ABRE el siguiente tema (conexión con el home) ──
    u1 = [u for u in units if u['order_index'] == 1][0]
    for l in u1['lessons']:
        items = I.run("select item_id from lesson_items where lesson_id='%s';" % l['id'])
        V.rpc(tok, 'complete_lesson', {
            'p_lesson_id': l['id'],
            'p_answers': [{'item_id': it['item_id'], 'answer': 'x'} for it in items]})
    prog2 = {r['lesson_id']: r['status']
             for r in rest(tok, 'user_lesson_progress?select=lesson_id,status')}
    plan2 = build_plan(units, prog2, tips)
    open2 = [t for t in plan2 if t['unlocked']]
    print('  [tras completar la unidad 1] abiertos=%d' % len(open2))
    check(len(open2) > len(unlocked),
          'completar la unidad 1 ABRE más temas (Estudiar sigue al progreso del home)')
    t1 = [t for t in plan2 if t['order'] == 1][0]
    check(t1['done'] == t1['total'],
          'el avance del tema refleja las lecciones completadas reales (%d/%d)' % (t1['done'], t1['total']))

    try:
        V.rpc(tok, 'delete_account', {})
    except Exception:
        pass
    print('\n' + ('TODO VERDE' if ok else 'HAY FALLOS'))
    return 0 if ok else 1


if __name__ == '__main__':
    raise SystemExit(main())
