# -*- coding: utf-8 -*-
"""Genera y sube el audio TTS por SEGMENTO de las historias de los cursos indicados,
en el idioma del curso (tl=fr/it/de/nl/pt). Lee los segmentos de la tabla `stories`
(ya sembrada) y sube a audio/stories/<story_id>-<i>.mp3 — MISMA convención (guion) que
la herramienta es→en. Reusa tts() de gen_audio_missing. Idempotente (x-upsert).

Uso: python gen_story_audio_multi.py fr it   (procesa las historias de esos cursos)
"""
import io, json, sys, time, urllib.request, urllib.error
from apply_sql import run, SERVICE, SUPABASE_URL
from gen_audio_missing import tts

COURSE_IDS = {
    'pt': '20000000-0000-0000-0000-000000000002', 'fr': '20000000-0000-0000-0000-000000000003',
    'it': '20000000-0000-0000-0000-000000000004', 'de': '20000000-0000-0000-0000-000000000005',
    'nl': '20000000-0000-0000-0000-000000000006',
}


def upload(path_id, mp3):
    path = "/storage/v1/object/audio/stories/%s.mp3" % path_id
    req = urllib.request.Request(SUPABASE_URL + path, data=mp3, method="POST")
    req.add_header("Authorization", "Bearer " + SERVICE)
    req.add_header("apikey", SERVICE)
    req.add_header("Content-Type", "audio/mpeg")
    req.add_header("x-upsert", "true")
    try:
        with urllib.request.urlopen(req, timeout=60) as r:
            return r.status
    except urllib.error.HTTPError as e:
        return "%d:%s" % (e.code, e.read().decode()[:120])


def main(codes):
    tot_ok = tot = 0
    for code in codes:
        cid = COURSE_IDS[code]
        rows = json.loads(run("select id, segments from stories where course_id='%s' order by cefr_level, order_index;" % cid)[1])
        for s in rows:
            sid = s["id"]
            segs = s["segments"] if isinstance(s["segments"], list) else json.loads(s["segments"])
            print("[%s] story %s: %d segmentos (tl=%s)" % (code, sid[:8], len(segs), code))
            for i, seg in enumerate(segs):
                text = (seg.get("en") or "").strip()
                if not text:
                    continue
                try:
                    mp3 = tts(text, code)
                except Exception as e:
                    print("  TTS FALLÓ", i, e); time.sleep(2); continue
                st = upload("%s-%d" % (sid, i), mp3)
                tot += 1
                if st in (200, 201):
                    tot_ok += 1
                else:
                    print("  upload FALLÓ", i, st)
                time.sleep(0.4)
    print("TOTAL audio historias: %d/%d" % (tot_ok, tot))


if __name__ == '__main__':
    main(sys.argv[1:] or ['fr', 'it'])
