"""Barrido de RECURSOS: HEAD a todas las URLs de audio (listening/speaking) e imágenes
(vocab/describe + vocab_images) + el loop de música. Reporta TODO lo que no dé 200
(404 = objeto faltante → "no carga"). Diagnóstico de "algunas no cargan bien".
"""
import json, urllib.request, urllib.error, sys
from collections import Counter
from apply_sql import run

def head(url):
    try:
        with urllib.request.urlopen(urllib.request.Request(url, method='HEAD'), timeout=20) as x:
            return x.status
    except urllib.error.HTTPError as e:
        return e.code
    except Exception as e:
        return 'ERR:' + type(e).__name__

def sweep(label, rows, key):
    urls = [(r['id'], r[key]) for r in rows if r.get(key)]
    bad = []
    codes = Counter()
    for iid, u in urls:
        c = head(u)
        codes[c] += 1
        if c != 200:
            bad.append((iid, u, c))
    print(f'== {label}: {len(urls)} recursos · {dict(codes)} ==')
    for iid, u, c in bad[:40]:
        print(f'  [{c}] {iid}  {u}')
    return bad

def main():
    total_bad = []
    # 1) Audio de listening/speaking (ambos cursos)
    rows = json.loads(run("select id, payload->>'audio_url' audio_url from content_items "
                          "where type in ('listening','speaking_read_aloud') order by id;")[1])
    total_bad += sweep('AUDIO listening/speaking', rows, 'audio_url')
    # 2) Imágenes en content_items (imgvocab + imgdescribe)
    rows = json.loads(run("select id, payload->>'image_url' image_url from content_items "
                          "where payload ? 'image_url' order by id;")[1])
    total_bad += sweep('IMÁGENES en ítems', rows, 'image_url')
    # 3) Registro vocab_images
    rows = json.loads(run("select concept id, image_url from vocab_images order by concept;")[1])
    total_bad += sweep('vocab_images (registro)', rows, 'image_url')
    # 4) Audio de historias (inmersión), si existe la tabla
    try:
        rows = json.loads(run("select id::text id, audio_url from (select id, jsonb_array_elements(segments)->>'audio_url' audio_url from stories) s where audio_url is not null;")[1])
        if isinstance(rows, list):
            total_bad += sweep('AUDIO historias', rows, 'audio_url')
    except Exception:
        pass
    # 5) Loop de música
    loop = 'https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/ambient/map_loop.wav'
    c = head(loop)
    print(f'== MÚSICA map_loop.wav: [{c}] ==')
    if c != 200:
        total_bad.append(('map_loop', loop, c))

    print('\n' + ('[OK] 0 recursos 404 en lo barrido' if not total_bad
                  else f'[ATENCIÓN] {len(total_bad)} recursos NO-200'))
    if total_bad:
        print('IDS A REGENERAR:')
        for iid, u, c in total_bad:
            print(f'  {iid}  [{c}]')

if __name__ == '__main__':
    main()
