"""Descarga iconos Twemoji (CC-BY 4.0) de vocabulario CONCRETO A1/A2 y los sube a
Supabase Storage (bucket audio, path vocab/<concept>.png), registrando proveniencia +
licencia en vocab_images. Idempotente (x-upsert + on conflict). Verifica HTTP 200 de la
fuente; si un icono 404, lo OMITE y reporta (nunca aloja imagen rota).

Fuente: https://cdn.jsdelivr.net/gh/jdecked/twemoji@latest/assets/72x72/<cp>.png
Licencia de los graficos: CC-BY 4.0. Codigo Twemoji: MIT.

Uso: python gen_vocab_images.py
"""
import json, time, urllib.request, urllib.error, sys
from apply_sql import run, SERVICE, SUPABASE_URL

SRC = 'Twemoji 15.1 (jdecked fork)'
LIC = 'CC-BY 4.0'
ATTR = 'Twemoji © Twitter, Inc. and other contributors; mantenido por el fork jdecked/twemoji; licencia CC-BY 4.0'
PUB = 'https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/vocab/'
CDN = 'https://cdn.jsdelivr.net/gh/jdecked/twemoji@latest/assets/72x72/'
UA = 'Mozilla/5.0'

# concepto -> (codepoint twemoji sin fe0f, categoria). Solo vocab CONCRETO donde la
# imagen AYUDA (no gramatica abstracta). Categorias agrupan distractores del mismo campo.
CONCEPTS = {
    # comida y bebida (A1 U4)
    'coffee': ('2615', 'food'), 'tea': ('1f375', 'food'), 'water': ('1f4a7', 'food'),
    'bread': ('1f35e', 'food'), 'milk': ('1f95b', 'food'), 'apple': ('1f34e', 'food'),
    'banana': ('1f34c', 'food'), 'egg': ('1f95a', 'food'), 'rice': ('1f35a', 'food'),
    'cheese': ('1f9c0', 'food'),
    # familia y mascotas (A1 U3)
    'mother': ('1f469', 'family'), 'father': ('1f468', 'family'), 'brother': ('1f466', 'family'),
    'sister': ('1f467', 'family'), 'baby': ('1f476', 'family'), 'family': ('1f46a', 'family'),
    'dog': ('1f415', 'family'), 'cat': ('1f408', 'family'),
    # lugares (A1 U6)
    'house': ('1f3e0', 'place'), 'school': ('1f3eb', 'place'), 'bank': ('1f3e6', 'place'),
    'hospital': ('1f3e5', 'place'), 'restaurant': ('1f374', 'place'), 'store': ('1f3ec', 'place'),
    'car': ('1f697', 'place'),
    # tiempo (A1 U5)
    'clock': ('1f550', 'time'), 'sun': ('1f31e', 'time'), 'moon': ('1f319', 'time'),
    # viaje (A2 U9)
    'bus': ('1f68c', 'travel'), 'train': ('1f686', 'travel'), 'plane': ('2708', 'travel'),
    'ticket': ('1f3ab', 'travel'), 'hotel': ('1f3e8', 'travel'), 'suitcase': ('1f9f3', 'travel'),
    'taxi': ('1f695', 'travel'),
    # compras (A2 U10)
    'money': ('1f4b5', 'shop'), 'shirt': ('1f455', 'shop'), 'shoes': ('1f45f', 'shop'),
    'bag': ('1f45c', 'shop'),
}

def fetch(cp):
    req = urllib.request.Request(CDN + cp + '.png'); req.add_header('User-Agent', UA)
    with urllib.request.urlopen(req, timeout=30) as r:
        return r.read()

def upload(concept, png):
    path = f'/storage/v1/object/audio/vocab/{concept}.png'
    req = urllib.request.Request(SUPABASE_URL + path, data=png, method='POST')
    req.add_header('Authorization', 'Bearer ' + SERVICE); req.add_header('apikey', SERVICE)
    req.add_header('Content-Type', 'image/png'); req.add_header('x-upsert', 'true')
    try:
        with urllib.request.urlopen(req, timeout=60) as r:
            return r.status
    except urllib.error.HTTPError as e:
        return f'{e.code}:{e.read().decode()[:100]}'

def main():
    ok = 0; rows = []
    for concept, (cp, cat) in CONCEPTS.items():
        try:
            png = fetch(cp)
        except Exception as e:
            print('  FETCH FALLÓ (omito)', concept, cp, e); continue
        st = upload(concept, png)
        if st not in (200, 201):
            print('  upload FALLÓ', concept, st); continue
        url = PUB + concept + '.png'
        rows.append((concept, cat, cp, url))
        ok += 1
        time.sleep(0.25)
    # registro en vocab_images (service_role)
    if rows:
        vals = ',\n'.join(
            "('{c}','{cat}','{cp}','{u}','{s}','{l}','{a}')".format(
                c=c, cat=cat, cp=cp, u=u, s=SRC, l=LIC, a=ATTR.replace("'", "''"))
            for (c, cat, cp, u) in rows)
        q = ("insert into vocab_images (concept, category, codepoint, image_url, source, license, attribution) values "
             + vals + " on conflict (concept) do update set category=excluded.category, codepoint=excluded.codepoint, "
             "image_url=excluded.image_url, source=excluded.source, license=excluded.license, attribution=excluded.attribution;")
        code, out = run(q)
        print('registro vocab_images:', code, out[:80])
    print(f'OK subidos + registrados: {ok}/{len(CONCEPTS)}')

if __name__ == '__main__':
    main()
