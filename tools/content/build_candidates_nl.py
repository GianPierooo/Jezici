# -*- coding: utf-8 -*-
"""LÉXICO Fase 1 · NEERLANDÉS — guardas deterministas sobre los 10 theme_*.json.
Produce _lexnl/candidates.json (palabras que pasan) + 5 review_in_*.json para los
revisores adversariales. Guardas:
  1) la palabra/cloze aparece EXACTA en la oración (resuelve cloze; None si no)
  2) dedup vs lo que it ya enseña (taught_nl.json, raíz sin artículo)
  3) término != traducción (raíz normalizada) → caza cognados IDÉNTICOS
  4) cognado de raíz idéntica de bajo valor: edit-distance <=1 entre raíces → EXCLUYE
  5) dedup entre temas (raíz)
"""
import json, re, unicodedata, glob, os

THEMES = ['food', 'work', 'health', 'travel', 'city', 'time', 'shopping', 'home', 'nature', 'emotions']
ARTS = ['de ', 'het ', 'een ', "'t ",
        'el ', 'los ', 'las ', 'la ', 'un ', 'una ', 'unos ', 'unas ']


def norm(t):
    t = (t or '').lower()
    t = unicodedata.normalize('NFD', t)
    t = ''.join(c for c in t if unicodedata.category(c) != 'Mn')
    t = re.sub(r"[.!?¿¡,;:'\"’‘´`“”()]", '', t)
    return re.sub(r'\s+', ' ', t).strip()


def strip_art(w):
    w = (w or '').strip()
    low = w.lower()
    for a in ARTS:
        if low.startswith(a):
            return w[len(a):].strip()
    return w


def has_exact(sub, sent):
    # substring con frontera de palabra (permite apóstrofe interno como en l'albero)
    if not sub:
        return False
    return re.search(r'(?<![A-Za-zÀ-ÿ])' + re.escape(sub) + r'(?![A-Za-zÀ-ÿ])', sent) is not None


def lev(a, b):
    if a == b:
        return 0
    if abs(len(a) - len(b)) > 1:
        return 2
    prev = list(range(len(b) + 1))
    for i, ca in enumerate(a, 1):
        cur = [i]
        for j, cb in enumerate(b, 1):
            cur.append(min(prev[j] + 1, cur[-1] + 1, prev[j - 1] + (ca != cb)))
        prev = cur
    return prev[-1]


def main():
    taught = set(json.load(open('_lexnl/taught_nl.json', encoding='utf-8')))
    cands, seen = [], set()
    stats = {'raw': 0, 'no_sentence': 0, 'dup_taught': 0, 'term_eq_tr': 0,
             'cognate': 0, 'dup_cross': 0, 'kept': 0, 'cloze': 0, 'nocloze': 0}
    dropped = []

    for th in THEMES:
        fp = '_lexnl/theme_%s.json' % th
        if not os.path.exists(fp):
            print('FALTA', fp); continue
        for w in json.load(open(fp, encoding='utf-8')):
            stats['raw'] += 1
            word = (w.get('word') or '').strip()
            es = (w.get('es') or '').strip()
            sent = (w.get('sentence') or '').strip()
            cloze_in = (w.get('cloze') or '').strip()
            pos = w.get('pos') or 'noun'
            root = norm(strip_art(word))
            root_es = norm(strip_art(es))
            if not word or not es or not sent:
                dropped.append((th, word, 'vacio')); continue
            # 2) dedup vs taught
            if root in taught:
                stats['dup_taught'] += 1; dropped.append((th, word, 'ya_enseñada')); continue
            # 3) término == traducción (raíz)
            if root == root_es:
                stats['term_eq_tr'] += 1; dropped.append((th, word, 'term=trad')); continue
            # 4) cognado casi idéntico (edit-distance <=1 raíz)
            if lev(root, root_es) <= 1:
                stats['cognate'] += 1; dropped.append((th, word, 'cognado~%s' % es)); continue
            # 5) dedup entre temas
            if root in seen:
                stats['dup_cross'] += 1; dropped.append((th, word, 'dup_tema')); continue
            # 1) resolver cloze: author cloze exacto > bare noun > None
            cloze = None
            if has_exact(cloze_in, sent):
                cloze = cloze_in
            elif has_exact(word, sent):
                cloze = word
            else:
                bare = strip_art(word)
                if bare != word and has_exact(bare, sent):
                    cloze = bare
            seen.add(root)
            stats['kept'] += 1
            stats['cloze' if cloze else 'nocloze'] += 1
            cands.append({'word': word, 'pos': pos, 'es': es, 'sentence': sent,
                          'theme': th, 'cloze': cloze})

    json.dump(cands, open('_lexnl/candidates.json', 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
    # split en 5 chunks para revisores (solo campos que el revisor evalúa)
    n = 5
    chunks = [[] for _ in range(n)]
    for i, c in enumerate(cands):
        chunks[i % n].append({'i': i, 'word': c['word'], 'es': c['es'],
                              'sentence': c['sentence'], 'theme': c['theme']})
    for k in range(n):
        json.dump(chunks[k], open('_lexnl/review_in_%d.json' % k, 'w', encoding='utf-8'),
                  ensure_ascii=False, indent=1)
    print('STATS:', json.dumps(stats, ensure_ascii=False))
    print('candidatos:', len(cands), '| cloze+audio:', stats['cloze'], '| match+word:', stats['nocloze'])
    print('EXCLUIDOS (%d) muestra:' % len(dropped))
    for d in dropped[:40]:
        print('   ', d)


if __name__ == '__main__':
    main()
