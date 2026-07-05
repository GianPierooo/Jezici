"""Genera y sube el audio TTS FALTANTE (auditoría 2026-06-22): es→en B1/B2 y
es→pt A1/A2. Mismo patrón determinista que gen_audio.py (Google translate_tts,
audio pregenerado, no IA en runtime) → Storage bucket `audio` en items/<id>.mp3.

NO toca es→en A1/A2 (ya tienen audio y funcionan). Idempotente (x-upsert).

Uso:
  python gen_audio_missing.py            # todos los grupos faltantes
  python gen_audio_missing.py en-b1      # un grupo (en-b1|en-b2|pt-a1|pt-a2)
  LIMIT=2 python gen_audio_missing.py en-b1   # dry-run corto
"""
import json, os, time, urllib.request, urllib.parse, urllib.error, sys
from apply_sql import run, SERVICE, SUPABASE_URL  # secretos desde .env/entorno

UA = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124 Safari/537.36"

COURSE_EN = "20000000-0000-0000-0000-000000000001"
COURSE_PT = "20000000-0000-0000-0000-000000000002"
COURSE_FR = "20000000-0000-0000-0000-000000000003"
COURSE_IT = "20000000-0000-0000-0000-000000000004"
COURSE_DE = "20000000-0000-0000-0000-000000000005"
COURSE_NL = "20000000-0000-0000-0000-000000000006"

# grupo -> (course_id, cefr_level, idioma TTS)
GROUPS = {
    "en-b1": (COURSE_EN, "B1", "en"),
    "en-b2": (COURSE_EN, "B2", "en"),
    "en-c1": (COURSE_EN, "C1", "en"),
    "pt-a1": (COURSE_PT, "A1", "pt"),
    "pt-a2": (COURSE_PT, "A2", "pt"),
    "pt-b1": (COURSE_PT, "B1", "pt"),
    "fr-a1": (COURSE_FR, "A1", "fr"),
    "it-a1": (COURSE_IT, "A1", "it"),
    "fr-a2": (COURSE_FR, "A2", "fr"),
    "it-a2": (COURSE_IT, "A2", "it"),
    "de-a1": (COURSE_DE, "A1", "de"),
    "nl-a1": (COURSE_NL, "A1", "nl"),
    "de-a2": (COURSE_DE, "A2", "de"),
    "nl-a2": (COURSE_NL, "A2", "nl"),
    "de-b1": (COURSE_DE, "B1", "de"),
    "nl-b1": (COURSE_NL, "B1", "nl"),
    "fr-b1": (COURSE_FR, "B1", "fr"),
    "it-b1": (COURSE_IT, "B1", "it"),
    "de-b2": (COURSE_DE, "B2", "de"),
    "nl-b2": (COURSE_NL, "B2", "nl"),
    "fr-b2": (COURSE_FR, "B2", "fr"),
    "it-b2": (COURSE_IT, "B2", "it"),
    "pt-b2": (COURSE_PT, "B2", "pt"),
}

def tts(text, tl):
    url = ("https://translate.google.com/translate_tts?ie=UTF-8&client=tw-ob&tl="
           + tl + "&q=" + urllib.parse.quote(text))
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

def do_group(key):
    course, level, tl = GROUPS[key]
    limit = os.environ.get("LIMIT")
    lim_sql = f" limit {int(limit)}" if limit else ""
    code, out = run(f"""select id, payload->>'say' as say, payload->>'text' as txt
                        from content_items
                        where course_id='{course}' and cefr_level='{level}'
                          and type in ('listening','speaking_read_aloud')
                        order by id{lim_sql};""")
    if code not in (200, 201):
        print(f"[{key}] SELECT FALLÓ [{code}] {out[:200]}"); return (0, 0)
    rows = json.loads(out)
    print(f"[{key}] items: {len(rows)} (tl={tl})")
    ok = 0
    for i, r in enumerate(rows):
        text = (r.get("say") or r.get("txt") or "").strip()
        if not text:
            print("  (sin texto)", r["id"]); continue
        try:
            mp3 = tts(text, tl)
        except Exception as e:
            print("  TTS FALLÓ", r["id"], e); time.sleep(2); continue
        st = upload(r["id"], mp3)
        if st in (200, 201):
            ok += 1
        else:
            print("  upload FALLÓ", r["id"], st)
        if (i + 1) % 12 == 0:
            print(f"  {i+1}/{len(rows)}…")
        time.sleep(0.4)
    print(f"[{key}] OK subidos: {ok}/{len(rows)}")
    return (ok, len(rows))

def main():
    keys = [a for a in sys.argv[1:] if a in GROUPS] or list(GROUPS.keys())
    tot_ok = tot = 0
    for k in keys:
        o, n = do_group(k)
        tot_ok += o; tot += n
    print(f"TOTAL OK: {tot_ok}/{tot}")

if __name__ == "__main__":
    main()
