"""Genera y sube el audio TTS de los ítems NUEVOS de listening/speaking del
rebalanceo L/S (tag 'lsbal'). Mismo pipeline determinista que gen_audio_missing.py
(Google translate_tts → Storage audio/items/<id>.mp3, x-upsert idempotente). El
texto = payload.say (listening) o payload.text (speaking). Idioma en.

Uso:
  python gen_audio_ls.py            # todos los 'lsbal' sin audio aún
  python gen_audio_ls.py A1         # solo cierto nivel
  LIMIT=3 python gen_audio_ls.py    # corto
"""
import json, os, time, sys
from apply_sql import run
from gen_audio_missing import tts, upload  # reutiliza TTS + upload (service_role)

TAG = 'lsbal'

def main():
    lvl = next((a for a in sys.argv[1:] if a in ('A1', 'A2', 'B1', 'B2', 'C1')), None)
    lvl_sql = f" and cefr_level='{lvl}'" if lvl else ''
    limit = os.environ.get('LIMIT')
    lim_sql = f' limit {int(limit)}' if limit else ''
    code, out = run(f"""select id, payload->>'say' say, payload->>'text' txt, cefr_level
                        from content_items
                        where '{TAG}'=any(tags) and type in ('listening','speaking_read_aloud')
                        {lvl_sql} order by id{lim_sql};""")
    if code not in (200, 201):
        print(f'SELECT FALLÓ [{code}] {out[:200]}'); sys.exit(1)
    rows = json.loads(out)
    print(f'ítems lsbal: {len(rows)}')
    ok = 0
    for i, r in enumerate(rows):
        text = (r.get('say') or r.get('txt') or '').strip()
        if not text:
            print('  (sin texto)', r['id']); continue
        try:
            mp3 = tts(text, 'en')
        except Exception as e:
            print('  TTS FALLÓ', r['id'], e); time.sleep(2); continue
        st = upload(r['id'], mp3)
        if st in (200, 201):
            ok += 1
        else:
            print('  upload FALLÓ', r['id'], st)
        if (i + 1) % 12 == 0:
            print(f'  {i+1}/{len(rows)}…')
        time.sleep(0.4)
    print(f'OK subidos: {ok}/{len(rows)}')

if __name__ == '__main__':
    main()
