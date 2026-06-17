"""Genera y sube el audio (TTS FIJO) de los ítems A2 de listening/speaking a
Supabase Storage en items/<id>.mp3 (mismo patrón determinista que la 027).
Usa el endpoint TTS de Google Translate (audio pregenerado, no IA en runtime)."""
import json, time, urllib.request, urllib.parse, urllib.error, sys
from apply_sql import run, SERVICE, SUPABASE_URL  # secretos desde .env/entorno

UA = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124 Safari/537.36"

def tts(text):
    url = ("https://translate.google.com/translate_tts?ie=UTF-8&client=tw-ob&tl=en&q="
           + urllib.parse.quote(text))
    req = urllib.request.Request(url)
    req.add_header("User-Agent", UA)
    req.add_header("Referer", "https://translate.google.com/")
    with urllib.request.urlopen(req, timeout=60) as r:
        return r.read()

def upload(item_id, mp3):
    path = f"/storage/v1/object/audio/items/{item_id}.mp3"
    req = urllib.request.Request(SUPABASE_URL + path, data=mp3, method="POST")
    req.add_header("Authorization", "Bearer " + SERVICE)
    req.add_header("apikey", SERVICE)
    req.add_header("Content-Type", "audio/mpeg")
    req.add_header("x-upsert", "true")
    try:
        with urllib.request.urlopen(req, timeout=60) as r:
            return r.status
    except urllib.error.HTTPError as e:
        return f"{e.code}:{e.read().decode()[:120]}"

def main():
    code, out = run("""select id, type, payload->>'say' as say, payload->>'text' as txt
                       from content_items
                       where cefr_level='A2' and type in ('listening','speaking_read_aloud')
                       order by id;""")
    rows = json.loads(out)
    print(f"items A2 con audio: {len(rows)}")
    ok = 0
    for i, r in enumerate(rows):
        text = (r.get("say") or r.get("txt") or "").strip()
        if not text:
            print("  (sin texto)", r["id"]); continue
        try:
            mp3 = tts(text)
        except Exception as e:
            print("  TTS FALLÓ", r["id"], e); time.sleep(2); continue
        st = upload(r["id"], mp3)
        if st in (200, 201):
            ok += 1
        else:
            print("  upload FALLÓ", r["id"], st)
        if (i + 1) % 12 == 0:
            print(f"  {i+1}/{len(rows)}…")
        time.sleep(0.35)
    print(f"OK subidos: {ok}/{len(rows)}")

if __name__ == "__main__":
    main()
