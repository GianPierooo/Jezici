"""Genera un LOOP AMBIENT ORIGINAL (obra propia → dedicada CC0, licencia 100% limpia,
sin terceros) por síntesis procedural y lo sube a Storage (audio/ambient/map_loop.wav).
Pad suave para el MAPA. SIN CLIC al repetir: cada parcial y cada LFO tienen un número
ENTERO de ciclos sobre la duración T → la onda es periódica en T → loop perfecto. Pure
Python (struct+math), sin numpy/ffmpeg. WAV mono 16-bit (Web Audio decodifica WAV sin
padding → loop sample-exacto).

Uso: python gen_music_loop.py
"""
import math, struct, sys, urllib.request, urllib.error
from apply_sql import SERVICE, SUPABASE_URL

SR = 16000          # pad sin agudos → 16 kHz sobra (Nyquist 8 kHz)
T = 12.0            # 12 s: corto, cacheable; repetición discreta por ser ambient
N = int(SR * T)     # 192000 muestras → ~384 KB
PEAK = 0.16        # sutil (el GainNode del motor reduce aún más)

# Acorde cálido y abierto (A add9): calmo, no "alegre". Cada freq se ajusta a ciclos
# enteros sobre T. Cada parcial respira con un LFO lento (ciclos enteros distintos) →
# las voces entran/salen, el loop no se siente estático ni obvio.
#   (freq objetivo, ganancia base, ciclos LFO en T, fase LFO)
VOICES = [
    (110.00, 0.55, 1, 0.0),    # A2 raíz
    (164.81, 0.42, 2, 1.7),    # E3 quinta
    (220.00, 0.40, 1, 3.0),    # A3 octava
    (246.94, 0.26, 3, 0.6),    # B3 (la novena → color abierto)
    (329.63, 0.16, 2, 4.2),    # E4 brillo tenue
]
DETUNE_CENTS = 4.0  # capa levemente detunada por voz → calidez (chorus sutil)

def cyc(freq):
    return max(1, round(freq * T)) / T   # freq ajustada a ciclos enteros sobre T

def main():
    voices = []
    for f, g, lfo_cyc, lfo_ph in VOICES:
        f0 = cyc(f)
        f1 = cyc(f * (2 ** (DETUNE_CENTS / 1200.0)))   # capa detunada (también ciclos enteros)
        flfo = lfo_cyc / T                              # LFO con ciclos enteros → periódico
        voices.append((f0, f1, g, flfo, lfo_ph))

    raw = [0.0] * N
    for i in range(N):
        t = i / SR
        s = 0.0
        for f0, f1, g, flfo, lfo_ph in voices:
            amp = g * (0.62 + 0.38 * (0.5 + 0.5 * math.sin(2 * math.pi * flfo * t + lfo_ph)))
            s += amp * (math.sin(2 * math.pi * f0 * t) + 0.6 * math.sin(2 * math.pi * f1 * t))
        raw[i] = s

    peak = max(abs(x) for x in raw) or 1.0
    scale = PEAK / peak
    data = bytearray()
    for x in raw:
        v = int(max(-1.0, min(1.0, x * scale)) * 32767)
        data += struct.pack('<h', v)

    # cabecera WAV PCM mono 16-bit
    byte_rate = SR * 2
    header = b'RIFF' + struct.pack('<I', 36 + len(data)) + b'WAVE'
    header += b'fmt ' + struct.pack('<IHHIIHH', 16, 1, 1, SR, byte_rate, 2, 16)
    header += b'data' + struct.pack('<I', len(data))
    wav = header + bytes(data)
    print(f'WAV generado: {len(wav)} bytes ({T}s @ {SR}Hz, peak {PEAK})')

    path = '/storage/v1/object/audio/ambient/map_loop.wav'
    req = urllib.request.Request(SUPABASE_URL + path, data=wav, method='POST')
    req.add_header('Authorization', 'Bearer ' + SERVICE); req.add_header('apikey', SERVICE)
    req.add_header('Content-Type', 'audio/wav'); req.add_header('x-upsert', 'true')
    try:
        with urllib.request.urlopen(req, timeout=60) as r:
            print('upload:', r.status)
    except urllib.error.HTTPError as e:
        print('upload FALLÓ', e.code, e.read().decode()[:120]); sys.exit(1)
    print('URL pública: https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/ambient/map_loop.wav')

if __name__ == '__main__':
    main()
