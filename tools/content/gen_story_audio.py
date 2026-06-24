"""Genera+sube el TTS de los SEGMENTOS de historias (es->en) a Storage:
audio/stories/<story_id>-<idx>.mp3. Reusa tts() de gen_audio_missing (Google
translate_tts, sin claves). Lee los segmentos de la tabla stories (curso es->en).
Idempotente (x-upsert). Uso: python gen_story_audio.py"""
import json, time, urllib.request, urllib.error
from apply_sql import run, SERVICE, SUPABASE_URL
from gen_audio_missing import tts

COURSE = "20000000-0000-0000-0000-000000000001"

def upload(path_id, mp3):
    path = f"/storage/v1/object/audio/stories/{path_id}.mp3"
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
    rows = json.loads(run(f"select id, segments from stories where course_id='{COURSE}' order by cefr_level, order_index;")[1])
    ok = tot = 0
    for s in rows:
        sid = s["id"]
        segs = s["segments"] if isinstance(s["segments"], list) else json.loads(s["segments"])
        for i, seg in enumerate(segs):
            text = (seg.get("en") or "").strip()
            if not text:
                continue
            tot += 1
            try:
                mp3 = tts(text, "en")
            except Exception as e:
                print("  TTS FALLO", sid, i, e); time.sleep(2); continue
            st = upload(f"{sid}-{i}", mp3)
            if st in (200, 201):
                ok += 1
            else:
                print("  upload FALLO", sid, i, st)
            time.sleep(0.4)
    print(f"[stories] audio subido: {ok}/{tot}")

if __name__ == "__main__":
    main()
