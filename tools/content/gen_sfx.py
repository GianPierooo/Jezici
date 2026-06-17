"""Sintetiza el set de efectos de sonido (Sistema_Diseno) como WAV cortos —
pure-Python (wave + math), sin dependencias. Salida: app/assets/sfx/*.wav.
Tonos agradables (campana/sine con armónicos + decaimiento). GA8."""
import math, os, struct, wave

SR = 22050
OUT = os.path.join(os.path.dirname(__file__), '..', '..', 'app', 'assets', 'sfx')
os.makedirs(OUT, exist_ok=True)

# Notas (Hz)
N = {'C5': 523.25, 'D5': 587.33, 'E5': 659.25, 'G5': 783.99, 'A5': 880.0,
     'C6': 1046.5, 'E6': 1318.5, 'G6': 1568.0, 'G4': 392.0, 'E4': 329.63,
     'C4': 261.63, 'A4': 440.0}

def tone(freq, dur, vol=0.5, decay=6.0, harmonics=(1.0, 0.35, 0.12)):
    n = int(SR * dur)
    out = []
    for i in range(n):
        t = i / SR
        env = math.exp(-decay * t)  # decaimiento exponencial (campana)
        s = 0.0
        for k, amp in enumerate(harmonics, start=1):
            s += amp * math.sin(2 * math.pi * freq * k * t)
        out.append(vol * env * s)
    return out

def seq(notes, gap=0.0):
    """notes: lista de (freq, dur, vol). Concatena con solapamiento suave."""
    buf = []
    for f, d, v in notes:
        buf.extend(tone(f, d, v))
        if gap:
            buf.extend([0.0] * int(SR * gap))
    return buf

def mix(*layers):
    m = max(len(l) for l in layers)
    out = [0.0] * m
    for l in layers:
        for i, s in enumerate(l):
            out[i] += s
    return out

def save(name, samples):
    # normaliza + clip + 16-bit PCM
    peak = max((abs(s) for s in samples), default=1.0) or 1.0
    g = 0.9 / peak
    path = os.path.join(OUT, name + '.wav')
    with wave.open(path, 'w') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        frames = b''.join(struct.pack('<h', max(-32767, min(32767, int(s * g * 32767)))) for s in samples)
        w.writeframes(frames)
    print(f'  {name}.wav  ({len(samples)/SR:.2f}s, {os.path.getsize(path)//1024}KB)')

def main():
    print('Generando SFX en', os.path.normpath(OUT))
    # acierto: dos notas ascendentes, brillante y corto
    save('correct', seq([(N['E5'], 0.10, 0.5), (N['A5'], 0.22, 0.5)]))
    # error: descendente suave (no agresivo)
    save('wrong', seq([(N['G4'], 0.12, 0.45), (N['E4'], 0.22, 0.4)]))
    # combo: triada ascendente rápida
    save('combo', seq([(N['C5'], 0.07, 0.45), (N['E5'], 0.07, 0.45), (N['G5'], 0.18, 0.5)]))
    # completar lección: arpegio mayor C-E-G-C
    save('lesson_complete', seq([(N['C5'], 0.10, 0.45), (N['E5'], 0.10, 0.45), (N['G5'], 0.10, 0.45), (N['C6'], 0.30, 0.55)]))
    # subir de nivel: fanfarria
    save('level_up', seq([(N['C5'], 0.09, 0.45), (N['G5'], 0.09, 0.5), (N['C6'], 0.10, 0.5), (N['E6'], 0.34, 0.55)]))
    # celebración (checkpoint/certificado): triunfal y más larga
    save('celebrate', seq([(N['C5'], 0.10, 0.45), (N['E5'], 0.10, 0.45), (N['G5'], 0.10, 0.5),
                           (N['C6'], 0.12, 0.5), (N['E6'], 0.12, 0.5), (N['G6'], 0.40, 0.6)]))
    # hito de racha: destello brillante
    save('streak', seq([(N['A5'], 0.07, 0.45), (N['C6'], 0.07, 0.5), (N['E6'], 0.07, 0.5), (N['A5'], 0.22, 0.45)]))
    print('LISTO')

if __name__ == '__main__':
    main()
