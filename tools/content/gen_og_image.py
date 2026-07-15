# -*- coding: utf-8 -*-
"""Genera la LINK PREVIEW (og:image) 1200x630 de Jezici: gradiente violeta de
marca + el guacamayo escarlata "Jezi" (portado 1:1 de ParrotArt / _ParrotPainter,
viewBox 84x90) + wordmark + tagline + chips. Se renderiza a 2x y se reduce con
LANCZOS (antialias). Salida: app/web/og-image.png (servido en /og-image.png).
Solo se corre una vez; el PNG resultante se commitea (CI no lo regenera).
uso: python gen_og_image.py
"""
import os
from PIL import Image, ImageDraw, ImageFont

SCALE = 2                      # supersampling
W, H = 1200 * SCALE, 630 * SCALE
OUT = os.path.normpath(os.path.join(os.path.dirname(__file__), '..', '..',
                                    'app', 'web', 'og-image.png'))

# ── Paleta de marca (guacamayo escarlata del mockup) ─────────────────────────
BG_TOP    = (138, 123, 246)    # #8A7BF6
BG_MID    = (108, 92, 231)     # #6C5CE7
BG_BOT    = (91, 78, 207)      # #5B4ECF
TAIL_ORNG = (255, 122, 0)      # #FF7A00
TAIL_YELL = (255, 201, 60)     # #FFC93C
BODY_RED  = (255, 77, 109)     # #FF4D6D
BELLY     = (255, 227, 232)    # #FFE3E8
WING      = (255, 201, 60)
HEAD_RED  = (255, 107, 107)    # #FF6B6B
FACE      = (255, 244, 232)    # #FFF4E8
CREST1    = (255, 107, 107)
CREST2    = (255, 133, 133)    # #FF8585
PUPIL     = (26, 26, 46)       # #1A1A2E


def lerp(a, b, t):
    return tuple(int(round(a[i] + (b[i] - a[i]) * t)) for i in range(3))


def vertical_gradient(draw):
    """Gradiente violeta diagonal-ish (top->mid->bot) por filas."""
    for y in range(H):
        t = y / (H - 1)
        c = lerp(BG_TOP, BG_MID, t * 2) if t < 0.5 else lerp(BG_MID, BG_BOT, (t - 0.5) * 2)
        draw.line([(0, y), (W, y)], fill=c)


def quad(p0, c, p1, n=24):
    """Muestrea una bezier cuadrática en n+1 puntos (incluye p0, excluye p1 salvo el final)."""
    pts = []
    for i in range(n + 1):
        t = i / n
        u = 1 - t
        x = u * u * p0[0] + 2 * u * t * c[0] + t * t * p1[0]
        y = u * u * p0[1] + 2 * u * t * c[1] + t * t * p1[1]
        pts.append((x, y))
    return pts


def draw_parrot(img, ox, oy, s):
    """Dibuja el guacamayo (unidades del viewBox 84x90) transformadas a (ox+ x*s, oy+ y*s).
    Orden atrás->adelante EXACTO al _ParrotPainter de la app."""
    d = ImageDraw.Draw(img)

    def T(x, y):
        return (ox + x * s, oy + y * s)

    def poly(color, segs):
        # segs = lista de (p0, c, p1) en unidades; se concatenan en un polígono.
        pts = []
        for p0, c, p1 in segs:
            pts += [T(*p) for p in quad(p0, c, p1)]
        d.polygon(pts, fill=color)

    def ellipse(color, cx, cy, rx, ry):
        d.ellipse([T(cx - rx, cy - ry), T(cx + rx, cy + ry)], fill=color)

    # 1) colas
    poly(TAIL_ORNG, [((28, 58), (21, 76), (25, 84)), ((25, 84), (32, 79), (37, 66))])
    poly(TAIL_YELL, [((40, 60), (39, 79), (44, 86)), ((44, 86), (51, 79), (51, 66))])
    # 2) cuerpo + vientre
    ellipse(BODY_RED, 46, 52, 23, 25)
    ellipse(BELLY, 50, 56, 13, 17)
    # 3) ala
    poly(WING, [((30, 46), (21, 54), (25, 70)), ((25, 70), (38, 73), (43, 60)),
                ((43, 60), (39, 48), (30, 46))])
    # 4) cabeza + cara
    ellipse(HEAD_RED, 40, 28, 20, 20)
    ellipse(FACE, 45, 30, 13, 12)
    # 5) cresta
    poly(CREST1, [((33, 11), (30, 2), (37, 2)), ((37, 2), (40, 6), (38, 11))])
    poly(CREST2, [((41, 8), (42, 0), (48, 2)), ((48, 2), (48, 7), (45, 11))])
    # 6) ojo
    ellipse((255, 255, 255), 43, 27, 6.2, 6.2)
    ellipse(PUPIL, 44.5, 28, 3.3, 3.3)
    ellipse((255, 255, 255), 46, 26.6, 1.1, 1.1)
    # 7) pico
    poly(TAIL_YELL, [((57, 30), (68, 31), (67, 38)), ((67, 38), (61, 42), (56, 37))])


def font(path, size):
    return ImageFont.truetype(path, size)


def tracked_text(draw, xy, text, fnt, fill, tracking=0):
    """Texto con letter-spacing manual (para el kicker)."""
    x, y = xy
    for ch in text:
        draw.text((x, y), ch, font=fnt, fill=fill)
        w = draw.textlength(ch, font=fnt)
        x += w + tracking


def main():
    base = Image.new('RGB', (W, H))
    d = ImageDraw.Draw(base)
    vertical_gradient(d)

    # ── Guacamayo (derecha), ENTERO con margen (bbox de unidades ~x[20,68] y[0,87]) ──
    UY0, UY1 = 0.0, 87.0          # alto en unidades del viewBox
    UX_C = 44.0                   # centro horizontal del loro en unidades
    target_h = 588 * SCALE        # alto deseado del loro (margen ~20 arriba/abajo)
    s = target_h / (UY1 - UY0)
    right_margin = 46 * SCALE
    ox = (W - right_margin) - 68 * s   # borde derecho del loro (unidad 68) al margen
    oy = 22 * SCALE - UY0 * s          # tope (unidad 0) a 22px del borde superior

    # Halo radial suave detrás del loro (círculo blanco muy translúcido).
    halo = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    hd = ImageDraw.Draw(halo)
    cx, cy, r = int(ox + UX_C * s), int(oy + 43 * s), int(H * 0.44)
    hd.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(255, 255, 255, 24))
    base = Image.alpha_composite(base.convert('RGBA'), halo).convert('RGB')
    d = ImageDraw.Draw(base)

    draw_parrot(base, ox, oy, s)
    d = ImageDraw.Draw(base)

    # ── Fuentes (Segoe UI: redonda, profesional; la marca usa Nunito en runtime) ──
    FB = 'C:/Windows/Fonts/segoeuib.ttf'   # bold
    FS = 'C:/Windows/Fonts/seguisb.ttf'    # semibold
    f_kick = font(FS, 26 * SCALE)
    f_word = font(FB, 132 * SCALE)
    f_tag  = font(FS, 33 * SCALE)
    f_chip = font(FB, 24 * SCALE)
    f_dom  = font(FB, 26 * SCALE)

    LX = 84 * SCALE
    white = (255, 255, 255)
    soft = (233, 228, 255)

    # Kicker
    tracked_text(d, (LX, 118 * SCALE), 'APRENDE IDIOMAS DE VERDAD', f_kick,
                 (214, 208, 255), tracking=3 * SCALE)
    # Wordmark
    d.text((LX - 4 * SCALE, 150 * SCALE), 'Jezici', font=f_word, fill=white)
    # Tagline (2 líneas)
    d.text((LX, 310 * SCALE), 'Un plan con fecha real y certificación', font=f_tag, fill=soft)
    d.text((LX, 352 * SCALE), 'por examen de las 4 habilidades.', font=f_tag, fill=soft)

    # Chips
    chips = ['6 idiomas', '4 habilidades', 'Certificación real']
    cx0 = LX
    cy0 = 424 * SCALE
    for label in chips:
        tw = d.textlength(label, font=f_chip)
        pad = 20 * SCALE
        cw = tw + pad * 2
        ch = 52 * SCALE
        d.rounded_rectangle([cx0, cy0, cx0 + cw, cy0 + ch], radius=26 * SCALE,
                            fill=(255, 255, 255, 255) if False else (124, 108, 240))
        d.rounded_rectangle([cx0, cy0, cx0 + cw, cy0 + ch], radius=26 * SCALE,
                            outline=(190, 182, 255), width=2 * SCALE)
        d.text((cx0 + pad, cy0 + 12 * SCALE), label, font=f_chip, fill=white)
        cx0 += cw + 16 * SCALE

    # Dominio (abajo izquierda)
    d.text((LX, 528 * SCALE), 'jezici.space', font=f_dom, fill=(255, 255, 255))

    # Reducir a 1200x630 con antialias.
    out = base.resize((1200, 630), Image.LANCZOS)
    out.save(OUT, 'PNG')
    print('[OK] og:image ->', OUT, out.size, os.path.getsize(OUT), 'bytes')


if __name__ == '__main__':
    main()
