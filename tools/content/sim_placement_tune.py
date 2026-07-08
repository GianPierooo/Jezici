# -*- coding: utf-8 -*-
"""Simulador OFFLINE del placement (escalera 1-up/1-down + estimador) para TUNEAR
umbrales robustos al azar (MC = 1/3 por item). Modela: un 'random' que acierta 1/3
en TODO, y personas de nivel L que aciertan ~0.9 en items <= su nivel y ~1/3 (azar)
por encima. Objetivo: random -> A1 casi siempre, C1 ~0%; personas -> su nivel.
Miles de trials, sin tocar la BD. python sim_placement_tune.py"""
import random

RANKS = [0, 1, 2, 3, 4]  # A1..C1


def run_test(p_correct_at, start, maxrank, cfg, rng):
    """Simula una prueba. p_correct_at(rank)->prob de acierto. Devuelve nivel estimado."""
    band = start
    asked = [0] * 5
    corr = [0] * 5
    n = 0
    prevdir = 0
    rev = 0
    pin = 0
    while True:
        served = min(band, maxrank)  # el banco sirve el rank mas cercano (cap por curso)
        n += 1
        ok = rng.random() < p_correct_at(served)
        asked[served] += 1
        if ok:
            corr[served] += 1
        new = min(band + 1, 4) if ok else max(band - 1, 0)
        d = (new > band) - (new < band)
        if d != 0 and prevdir != 0 and d != prevdir:
            rev += 1
        if d != 0:
            prevdir = d
        pin = pin + 1 if new == band else 0
        band = new
        stop = (n >= cfg['maxn']) or (n >= cfg['minn'] and (rev >= cfg['rev'] or pin >= cfg['pin']))
        if stop:
            break
    # estimador guess-aware: nivel r "aprobado" si asked>=min_ask y corr>=ceil(acc*asked) y corr>=min_corr
    import math
    def passed(r):
        return (asked[r] >= cfg['min_ask'] and corr[r] >= math.ceil(cfg['pass_acc'] * asked[r])
                and corr[r] >= cfg['min_corr'])
    if cfg.get('monotonic'):
        # escalera monotona: nivel = mayor r tal que TODOS los niveles 1..r estan
        # aprobados (evidencia sostenida subiendo). A1 (0) es el piso siempre.
        res = 0
        for r in [1, 2, 3, 4]:
            if passed(r):
                res = r
            else:
                break
    else:
        best = -1
        for r in RANKS:
            if passed(r):
                best = r
        res = best if best >= 0 else 0
    # PISO de precisión global (anti-azar): si la precisión total no supera claramente
    # el azar (1/3), no se puede acreditar B1+ (tope A2). Random total ~0.35 -> tope A2
    # (y por per-nivel casi siempre A1); un B1+ real acierta lo suyo -> acc total alta.
    if cfg.get('overall_floor'):
        ta = sum(asked); tc = sum(corr)
        if ta > 0 and tc < cfg['overall_floor'] * ta:
            res = min(res, 1)
    return res, n


def persona(level):
    def f(rank):
        return 0.90 if rank <= level else 0.34  # acierta lo suyo; adivina lo superior
    return f


def dist(fn, start, maxrank, cfg, trials, rng):
    from collections import Counter
    c = Counter(); ns = []
    for _ in range(trials):
        lvl, n = run_test(fn, start, maxrank, cfg, rng)
        c[lvl] += 1; ns.append(n)
    tot = sum(c.values())
    return {r: round(100 * c.get(r, 0) / tot) for r in RANKS}, sum(ns) // len(ns)


def evaluate(cfg, trials=4000):
    rng = random.Random(7)
    print(f"\ncfg={cfg}")
    # RANDOM (1/3 en todo) desde A2 y B1, curso EN (maxrank 4) y no-EN (3)
    for start, sname in [(1, 'A2'), (2, 'B1')]:
        d, avn = dist(lambda r: 1/3, start, 4, cfg, trials, rng)
        c1b2 = d[3] + d[4]
        print(f"  RANDOM start={sname} EN : A1 {d[0]}% A2 {d[1]}% B1 {d[2]}% B2 {d[3]}% C1 {d[4]}%  (B2+C1={c1b2}%) n~{avn}")
    # PERSONAS reales (curso EN)
    for L, Lname in [(0, 'A1'), (1, 'A2'), (2, 'B1'), (3, 'B2'), (4, 'C1')]:
        d, avn = dist(persona(L), 1, 4, cfg, trials, rng)
        hit = d[L]
        print(f"  PERSONA {Lname} start=A2: A1 {d[0]}% A2 {d[1]}% B1 {d[2]}% B2 {d[3]}% C1 {d[4]}%  (acierta {Lname}={hit}%)")


if __name__ == '__main__':
    # actual (mig 089/124): fallback acc>=0.5, min_ask 2, dominacion acc 2/3
    print("### ACTUAL (leniente) ###")
    evaluate({'minn': 8, 'maxn': 14, 'rev': 4, 'pin': 3, 'min_ask': 2, 'pass_acc': 0.5, 'min_corr': 1})
    # candidatos endurecidos + prueba mas larga
    print("\n### CANDIDATO A (mas largo, acc 0.72, min_ask 3) ###")
    evaluate({'minn': 12, 'maxn': 22, 'rev': 6, 'pin': 4, 'min_ask': 3, 'pass_acc': 0.72, 'min_corr': 3})
    print("\n### FINAL = C (min_ask3/acc0.72) + piso 0.6, arranque CLAMPEADO a A2 ###")
    evaluate({'minn': 12, 'maxn': 22, 'rev': 6, 'pin': 4, 'min_ask': 3, 'pass_acc': 0.72, 'min_corr': 3, 'overall_floor': 0.6})
