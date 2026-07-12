# -*- coding: utf-8 -*-
"""Verifica T4 (mig 150/151) con cliente REAL (JWT):
  - TRIGGER dispara notificación in-app: matix_fire('goal_met'/'hearts_out')
    → sent + fila en notifications con copy del estilo; locale en→copy inglés;
    behind_plan liga el MOTIVO ({motivo}); techo 1/evento/día (capped).
  - PUSH: save_push_subscription guarda; RLS = cada quien la suya (otro no la ve);
    la Edge Function matix-push responde y procesa pendientes.
  - VIDAS: get_hearts=5 lleno; lose_heart decrementa y arranca countdown;
    regen REAL (retrasar hearts_updated_at 31 min → +1 vida); buy_hearts recarga.
  - REVIVIR RACHA: cobra oro (config 300) con gold_transactions 'streak_revive';
    tope 1/30 días (limit_reached); ventana 7 días (expired); congelador intacto.
uso: python verify_t4.py
"""
import urllib.request, urllib.error, json, sys
import verify_placement_serious as V
from apply_sql import run, SUPABASE_URL
AK = V.AK


def rpc_raw(tok, name, body):
    try:
        return 200, V.rpc(tok, name, body)
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode()


def q(sql):
    return json.loads(run(sql)[1])


def main():
    ok = True
    def ck(n, c, d=''):
        nonlocal ok
        print(('  OK  ' if c else '  XX  ') + n + (('  ' + str(d)) if d != '' else ''))
        ok = ok and c

    users = []
    try:
        tokA, uidA = V.mk_user('t4_a@test.jezici.dev'); users.append(uidA)
        V.rpc(tokA, 'submit_age_gate', {'p_birth_year': 1990})

        # ---------- 1) TRIGGERS in-app ----------
        r = V.rpc(tokA, 'matix_fire', {'p_trigger': 'goal_met', 'p_locale': 'es'})
        ck('goal_met dispara (sent) con copy', r.get('status') == 'sent' and bool(r.get('copy')), r.get('copy'))
        n = q(f"select count(*) c from notifications where user_id='{uidA}' and trigger_type='goal_met' and status='sent'")[0]['c']
        ck('la notificación queda en el centro in-app', n == 1, n)
        r2 = V.rpc(tokA, 'matix_fire', {'p_trigger': 'goal_met', 'p_locale': 'es'})
        ck('techo 1/evento/día (capped)', r2.get('status') == 'suppressed' and r2.get('reason') == 'capped', r2.get('reason'))
        # locale EN → copy inglés
        r = V.rpc(tokA, 'matix_fire', {'p_trigger': 'hearts_out', 'p_locale': 'en'})
        ck('hearts_out en INGLÉS usa plantilla en', 'heart' in (r.get('copy') or '').lower(), r.get('copy'))
        # behind_plan ligado al MOTIVO (plan con motive=Examen)
        run(f"""insert into user_plans (user_id, course_id, current_level, goal_level, daily_minutes, days_per_week, motive)
                values ('{uidA}', '20000000-0000-0000-0000-000000000001', 'A1', 'B1', 30, 5, 'Examen')
                on conflict (user_id, course_id) do update set motive='Examen';""")
        r = V.rpc(tokA, 'matix_fire', {'p_trigger': 'behind_plan', 'p_locale': 'es'})
        ck('behind_plan liga el MOTIVO (tu examen)', 'tu examen' in (r.get('copy') or ''), r.get('copy'))

        # ---------- 2) PUSH ----------
        try:
            V.rpc(tokA, 'save_push_subscription', {
                'p_endpoint': 'https://example.com/push/t4-test-endpoint',
                'p_p256dh': 'test_p256dh', 'p_auth': 'test_auth'})
        except json.JSONDecodeError:
            pass  # devuelve void (204 sin cuerpo)
        n = q(f"select count(*) c from push_subscriptions where user_id='{uidA}'")[0]['c']
        ck('save_push_subscription guarda la suscripción', n == 1, n)
        tokB, uidB = V.mk_user('t4_b@test.jezici.dev'); users.append(uidB)
        V.rpc(tokB, 'submit_age_gate', {'p_birth_year': 1990})
        # RLS: B no ve la suscripción de A
        rq = urllib.request.Request(SUPABASE_URL + '/rest/v1/push_subscriptions?select=endpoint', method='GET')
        rq.add_header('apikey', AK); rq.add_header('Authorization', 'Bearer ' + tokB)
        with urllib.request.urlopen(rq) as x:
            rows = json.loads(x.read().decode())
        ck('RLS: otro usuario NO ve la suscripción ajena', rows == [], rows)
        # Edge Function responde y procesa
        rq = urllib.request.Request(SUPABASE_URL + '/functions/v1/matix-push', data=b'{}', method='POST')
        rq.add_header('Authorization', 'Bearer ' + AK); rq.add_header('Content-Type', 'application/json')
        with urllib.request.urlopen(rq, timeout=90) as x:
            fx = json.loads(x.read().decode())
        ck('Edge Function matix-push corre y procesa pendientes', fx.get('ok') is True, fx)

        # ---------- 3) VIDAS con regen REAL ----------
        h = V.rpc(tokA, 'get_hearts', {})
        ck('get_hearts: lleno 5/5 sin countdown', h.get('hearts') == 5 and h.get('seconds_to_next') is None, h)
        h = V.rpc(tokA, 'lose_heart', {})
        ck('lose_heart: 4/5 y arranca countdown (~30 min)', h.get('hearts') == 4 and 0 < (h.get('seconds_to_next') or 0) <= 1800, h)
        # retrasa el ancla 31 min → la regen lazy debe devolver 1 vida
        run(f"update user_stats set hearts_updated_at = now() - interval '31 minutes' where user_id='{uidA}';")
        h = V.rpc(tokA, 'get_hearts', {})
        ck('REGEN real: tras 31 min vuelve a 5/5', h.get('hearts') == 5, h)
        # dos pérdidas + compra
        V.rpc(tokA, 'lose_heart', {}); V.rpc(tokA, 'lose_heart', {})
        run(f"update user_stats set gold = 500 where user_id='{uidA}';")
        b = V.rpc(tokA, 'buy_hearts', {})
        ck('buy_hearts recarga a 5 y cobra 50 (config)', b.get('ok') is True and b.get('hearts') == 5 and b.get('gold') == 450, b)

        # ---------- 4) REVIVIR RACHA (caro + limitado) ----------
        run(f"""insert into streaks (user_id, current_streak, longest_streak, last_active_date, freezes_available, lost_streak, lost_at)
                values ('{uidA}', 1, 12, current_date, 0, 12, now() - interval '1 day')
                on conflict (user_id) do update set current_streak=1, longest_streak=12,
                  lost_streak=12, lost_at=now() - interval '1 day', freezes_available=0;""")
        st = V.rpc(tokA, 'streak_revive_status', {})
        ck('streak_revive_status: disponible (12 días, ventana ok)', st.get('available') is True and st.get('lost_streak') == 12, st)
        r = V.rpc(tokA, 'revive_streak', {})
        ck('revive_streak COBRA (450→150) y suma la racha (1+12=13)', r.get('ok') is True and r.get('streak') == 13 and r.get('gold') == 150, r)
        tx = q(f"select count(*) c from gold_transactions where user_id='{uidA}' and reason='streak_revive' and amount=-300")[0]['c']
        ck('movimiento auditable en gold_transactions (streak_revive -300)', tx == 1, tx)
        # tope: 2ª vez en el periodo → limit_reached
        run(f"update streaks set lost_streak=5, lost_at=now() where user_id='{uidA}';")
        r = V.rpc(tokA, 'revive_streak', {})
        ck('TOPE: segundo rescate del periodo → limit_reached', r.get('ok') is False and r.get('reason') == 'limit_reached', r)
        # ventana: pérdida vieja (8 días) → expired (en un usuario sin tope)
        run(f"""insert into streaks (user_id, current_streak, longest_streak, last_active_date, freezes_available, lost_streak, lost_at)
                values ('{uidB}', 1, 9, current_date, 0, 9, now() - interval '8 days')
                on conflict (user_id) do update set lost_streak=9, lost_at=now() - interval '8 days';""")
        run(f"update user_stats set gold=500 where user_id='{uidB}';")
        r = V.rpc(tokB, 'revive_streak', {})
        ck('VENTANA: pérdida de hace 8 días → expired', r.get('ok') is False and r.get('reason') == 'expired', r)
        # sin oro → insufficient_gold (usuario B con pérdida fresca y sin oro)
        run(f"update streaks set lost_at=now() where user_id='{uidB}';")
        run(f"update user_stats set gold=10 where user_id='{uidB}';")
        r = V.rpc(tokB, 'revive_streak', {})
        ck('sin oro suficiente → insufficient_gold (no cobra)', r.get('ok') is False and r.get('reason') == 'insufficient_gold', r)
        # congelador intacto (use_streak_freeze sigue cobrando 50 y sumando)
        run(f"update user_stats set gold=100 where user_id='{uidB}';")
        f = V.rpc(tokB, 'use_streak_freeze', {})
        ck('CONGELADOR intacto: cobra 50 y suma freeze', f.get('ok') is True and f.get('gold') == 50 and f.get('freezes_available') == 1, f)

        print('\nRESULTADO:', 'VERDE ✅' if ok else 'ROJO ❌')
    finally:
        for u in users:
            run(f"delete from auth.users where id='{u}';")

    sys.exit(0 if ok else 1)


if __name__ == '__main__':
    main()
