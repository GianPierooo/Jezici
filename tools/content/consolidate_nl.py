# -*- coding: utf-8 -*-
"""LÉXICO Fase 1 · NEERLANDÉS — consolida candidates.json + los 5 review_out_*.json
(veredictos POR ÍNDICE i) → final.json. Aplica fixes (es/word/sentence), quita drops,
RE-RESUELVE el cloze tras cada fix de oración/palabra y re-valida las guardas duras
(término≠traducción, cloze exacto). Reporta fixes/drops y la muestra ≥5%.
"""
import json, re, unicodedata, os, random

ARTS = ['de ', 'het ', 'een ', "'t ",
        'el ', 'los ', 'las ', 'la ', 'un ', 'una ', 'unos ', 'unas ']
POS_ES = {'noun': 'sustantivo', 'verb': 'verbo', 'adjective': 'adjetivo',
          'adverb': 'adverbio', 'phrase': 'frase'}


def norm(t):
    t = (t or '').lower()
    t = unicodedata.normalize('NFD', t)
    t = ''.join(c for c in t if unicodedata.category(c) != 'Mn')
    t = re.sub(r"[.!?¿¡,;:'\"’‘´`“”()]", '', t)
    return re.sub(r'\s+', ' ', t).strip()


def strip_art(w):
    w = (w or '').strip(); low = w.lower()
    for a in ARTS:
        if low.startswith(a):
            return w[len(a):].strip()
    return w


def has_exact(sub, sent):
    if not sub:
        return False
    return re.search(r'(?<![A-Za-zÀ-ÿ])' + re.escape(sub) + r'(?![A-Za-zÀ-ÿ])', sent) is not None


def resolve_cloze(word, sent):
    if has_exact(word, sent):
        return word
    bare = strip_art(word)
    if bare != word and has_exact(bare, sent):
        return bare
    return None


def main():
    cands = json.load(open('_lexnl/candidates.json', encoding='utf-8'))
    verd = {}
    for k in range(5):
        fp = '_lexnl/review_out_%d.json' % k
        if not os.path.exists(fp):
            print('FALTA', fp); continue
        for v in json.load(open(fp, encoding='utf-8')):
            verd[int(v['i'])] = v  # por índice, robusto a duplicados de palabra

    final, drops, fixes = [], [], []
    seen = set()
    for i, c in enumerate(cands):
        v = verd.get(i, {'verdict': 'ok'})
        if v.get('verdict') == 'drop':
            drops.append((c['word'], v.get('reason', ''))); continue
        word, es, sent = c['word'], c['es'], c['sentence']
        if v.get('verdict') == 'fix':
            if v.get('word_fix'):
                word = v['word_fix'].strip()
            if v.get('es_fix'):
                es = v['es_fix'].strip()
            if v.get('sentence_fix'):
                sent = v['sentence_fix'].strip()
            fixes.append((c['word'] + ('→' + word if word != c['word'] else ''),
                          v.get('reason', '')))
        # re-validar guardas duras tras fix
        root, root_es = norm(strip_art(word)), norm(strip_art(es))
        if root == root_es:
            drops.append((word, 'post-fix term=trad')); continue
        if root in seen:
            drops.append((word, 'post-fix dup')); continue
        cloze = resolve_cloze(word, sent)
        # si la palabra ya no aparece en la oración tras el fix, degradar a match+word
        seen.add(root)
        pos = POS_ES.get(c.get('pos', 'noun'), 'sustantivo')
        final.append({'word': word, 'pos': pos, 'es': es, 'sentence': sent,
                      'theme': c['theme'], 'cloze': cloze})

    json.dump(final, open('_lexnl/final.json', 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
    n_cloze = sum(1 for w in final if w['cloze'])
    print('FINAL:', len(final), '| cloze+audio:', n_cloze, '| match+word:', len(final) - n_cloze)
    print('FIXES aplicados:', len(fixes))
    for f in fixes:
        print('   ', f)
    print('DROPS:', len(drops))
    for d in drops:
        print('   ', d)

    # muestra >=5% (aleatoria estable) con foco falsos amigos + género
    random.seed(42)
    k = max(12, int(len(final) * 0.05) + 1)
    sample = random.sample(final, min(k, len(final)))
    print('\n=== MUESTRA 5pct (%d) para Gian ===' % len(sample))
    for s in sample:
        print('   %-20s | %-22s | %s' % (s['word'], s['es'], s['sentence']))


if __name__ == '__main__':
    main()
