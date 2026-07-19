# -*- coding: utf-8 -*-
"""Sube el TTS neerlandés (tl=nl) de los cloze de la mig 174, desde _lexnl/audio_targets.json."""
import json, time
from gen_audio_missing import tts, upload

def main():
    tgts = json.load(open('_lexnl/audio_targets.json', encoding='utf-8'))
    ok = fail = 0
    for i, t in enumerate(tgts):
        try:
            mp3 = tts(t['text'], 'nl')
            st = upload(t['id'], mp3)
            if st in (200, 201):
                ok += 1
            else:
                fail += 1; print('  FAIL', t['id'], st)
        except Exception as e:
            fail += 1; print('  ERR', t['id'], str(e)[:100])
        if (i + 1) % 40 == 0:
            print('  ...%d/%d' % (i + 1, len(tgts))); time.sleep(1)
    print('AUDIO nl: ok=%d fail=%d / %d' % (ok, fail, len(tgts)))

if __name__ == '__main__':
    main()
