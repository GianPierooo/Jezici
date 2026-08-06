# -*- coding: utf-8 -*-
"""GENERADOR DE TEMARIO — PDF profesional del currículo real de un curso/nivel.

Lee ÚNICAMENTE la BD en vivo (units, lessons, content_items, vocabulary,
lesson_vocab, study_theory, content_tips, exams) y arma un documento
"syllabus" — qué se enseña en cada lección, con vocabulario y punto de
gramática reales. CERO contenido inventado: lo que no existe en BD se omite
o se marca honestamente ("teoría en camino"), nunca se rellena a mano.

Cero IA en runtime — es extracción de datos + maquetación (reportlab).
Solo LECTURA: usa el mismo canal de introspección de solo-lectura que el
resto de `tools/content/` (Management API vía `_introspect.run`), sin tocar
producción ni migraciones.

Uso:
    python gen_syllabus_pdf.py --course en --level A1
    python gen_syllabus_pdf.py --course pt --level B1 --out outputs/temario_pt_b1.pdf
    python gen_syllabus_pdf.py --course en                # los 5 niveles del curso, un PDF

Requiere: pip install reportlab
"""
import argparse
import os
import re
from datetime import date

import _introspect as I

HERE = os.path.dirname(os.path.abspath(__file__))

# ── Paleta de marca (core/theme/app_colors.dart — la MISMA que usa la app) ──
from reportlab.lib.colors import HexColor

C_PRIMARY = HexColor('#6C5CE7')
C_PRIMARY_DARK = HexColor('#4B3FC9')
C_PRIMARY_LIGHT = HexColor('#8A7BF6')
C_CORAL = HexColor('#FF6B6B')
C_CORAL_DARK = HexColor('#D94545')
C_GOLD = HexColor('#FFC93C')
C_SUCCESS = HexColor('#2ECC71')
C_BG = HexColor('#F5F6FB')
C_TEXT = HexColor('#1A1A2E')
C_MUTED = HexColor('#7A809B')
C_WHITE = HexColor('#FFFFFF')
C_TABLE_ALT = HexColor('#F0F1F8')

# ── Nombre del idioma en ESPAÑOL — mismo texto que usa la app para el
# hispanohablante (app_es.arb: learnLangEn/Pt/Fr/It/De/Nl/Ro). No es curriculo,
# es el rótulo de idioma que el propio cliente ya muestra.
LANG_ES = {
    'en': 'Inglés', 'pt': 'Portugués', 'fr': 'Francés', 'it': 'Italiano',
    'de': 'Alemán', 'nl': 'Neerlandés', 'ro': 'Rumano',
}

# ── Etiquetas ESTRUCTURALES (traducción del enum, no contenido de curso) ────
SKILL_ES = {'reading': 'Lectura', 'listening': 'Audición',
            'writing': 'Escritura', 'speaking': 'Producción oral'}
SKILL_ORDER = ['reading', 'listening', 'writing', 'speaking']

TYPE_ES = {
    'multiple_choice': 'opción múltiple', 'cloze': 'completar (cloze)',
    'word_bank': 'construir la frase', 'reorder': 'reordenar',
    'match': 'emparejar', 'translation': 'traducir',
    'listening': 'escuchar y elegir', 'dictation': 'dictado',
    'speaking_read_aloud': 'lectura en voz alta',
    'guided_writing': 'redacción guiada', 'true_false': 'verdadero/falso',
}

POS_ES = {
    'noun': 'sustantivo', 'n': 'sustantivo', 'sustantivo': 'sustantivo',
    'verb': 'verbo', 'v': 'verbo', 'verbo': 'verbo', 'verbo_sustantivo': 'verbo/sustantivo',
    'adjective': 'adjetivo', 'adj': 'adjetivo',
    'adverb': 'adverbio', 'adv': 'adverbio', 'adverbio': 'adverbio',
    'preposition': 'preposición', 'prep': 'preposición', 'preposicion': 'preposición',
    'pronoun': 'pronombre', 'pronombre': 'pronombre',
    'conjunction': 'conjunción', 'conj': 'conjunción', 'conjuncion': 'conjunción',
    'determiner': 'determinante', 'interjection': 'interjección',
    'phrase': 'frase', 'expr': 'expresión', 'expresion': 'expresión',
    'idiom': 'modismo', 'numeral': 'numeral', 'phrasal': 'verbo compuesto',
}

TIP_TYPE_ES = {
    'tip_idioma': 'Regla', 'error_comun': 'Error común',
    'pronunciacion': 'Pronunciación', 'mnemotecnia': 'Truco para recordarlo',
    'nota_cultural': 'Nota cultural',
}

_EMOJI_RE = re.compile(
    '[\U0001F000-\U0001FFFF\U00002600-\U000027BF\U0001F1E6-\U0001F1FF]+')


def clean(txt):
    """Quita emoji (Helvetica no los renderiza) sin tocar el TEXTO real."""
    if not txt:
        return txt
    return _EMOJI_RE.sub('', txt).strip()


def pos_es(raw):
    if not raw:
        return None
    return POS_ES.get(raw.strip().lower(), raw.strip().lower())


# ── EXTRACCIÓN (solo lectura) ────────────────────────────────────────────

def get_course(code):
    rows = I.run("""select c.id, l.code, l.name from courses c
                     join languages l on l.id=c.target_language_id
                    where l.code='%s';""" % code)
    if not rows:
        raise SystemExit('curso desconocido: %r (usa en/pt/fr/it/de/nl/ro)' % code)
    return rows[0]['id'], code, LANG_ES.get(code, rows[0]['name'])


def fetch_units(course_id, level=None):
    where = "course_id='%s'" % course_id
    if level:
        where += " and cefr_level='%s'" % level
    return I.run("""select id, order_index, cefr_level, title, theme_color
                     from units where %s order by order_index;""" % where)


def fetch_theory(course_id, unit_order):
    """Teoría de la unidad: E-2 rica si existe, si no E-1 (tips), si no nada
    (honesto — 'teoría en camino', el MISMO estado que ve el usuario real).
    """
    rich = I.run("""select summary, sections, examples, pitfalls
                      from study_theory
                     where course_id='%s' and unit_order=%s;"""
                 % (course_id, unit_order))
    if rich:
        r = rich[0]
        return {'kind': 'rich', 'summary': r['summary'],
                'sections': r['sections'] or [], 'examples': r['examples'] or [],
                'pitfalls': r['pitfalls'] or []}
    tips = I.run("""select type, title, body, example from content_tips
                      where course_id='%s' and unit_order=%s order by type;"""
                 % (course_id, unit_order))
    if tips:
        return {'kind': 'tips', 'tips': tips}
    return {'kind': 'none'}


def fetch_lessons(unit_id):
    return I.run("""select id, order_index, title, description, type, xp_reward
                      from lessons where unit_id='%s' order by order_index;""" % unit_id)


def fetch_vocab(lesson_id):
    rows = I.run("""select v.word, v.translation, v.part_of_speech, lv.position
                      from lesson_vocab lv join vocabulary v on v.id=lv.vocab_id
                     where lv.lesson_id='%s' order by lv.position, v.word;""" % lesson_id)
    seen, out = set(), []
    for r in rows:
        if r['word'] in seen:
            continue
        seen.add(r['word'])
        out.append(r)
    return out


def fetch_exercise_summary(lesson_id):
    """Ejercicios de la lección: tipo + habilidad + CUÁNTOS — nunca el prompt
    ni la respuesta (el temario dice QUÉ se practica, no es un banco).
    """
    rows = I.run("""select ci.skill, ci.type, count(*) n
                      from lesson_items li join content_items ci on ci.id=li.item_id
                     where li.lesson_id='%s' group by ci.skill, ci.type;""" % lesson_id)
    by_skill = {}
    total = 0
    for r in rows:
        by_skill.setdefault(r['skill'], []).append((r['type'], r['n']))
        total += r['n']
    return total, by_skill


def fetch_checkpoint(course_id, cefr_level, order_index):
    """El checkpoint NO usa `lesson_items` (esa fila queda vieja/sin usar) —
    `start_checkpoint` sortea de un POOL por curso+nivel+etiqueta de unidad
    (ver mig 20260616120020). Replicamos EXACTAMENTE esa consulta.
    """
    tag = 'unidad%d' % order_index
    rows = I.run("""select skill, count(*) n from content_items
                      where course_id='%s' and cefr_level='%s'
                        and tags @> array['%s'] group by skill;"""
                 % (course_id, cefr_level, tag))
    pool = {r['skill']: r['n'] for r in rows}
    exam = I.run("""select time_limit_sec, pass_threshold from exams e
                      join units u on u.id=e.unit_id
                     where e.course_id='%s' and e.type='checkpoint'
                       and u.order_index=%d;""" % (course_id, order_index))
    meta = exam[0] if exam else None
    return pool, meta


def build_data(course_code, level=None):
    course_id, code, lang_name = get_course(course_code)
    units = fetch_units(course_id, level)
    if not units:
        raise SystemExit('sin unidades para curso=%s nivel=%r' % (course_code, level))
    out = []
    for u in units:
        theory = fetch_theory(course_id, u['order_index'])
        lessons = []
        for les in fetch_lessons(u['id']):
            entry = dict(les)
            if les['type'] == 'lesson':
                entry['vocab'] = fetch_vocab(les['id'])
                entry['total_ex'], entry['by_skill'] = fetch_exercise_summary(les['id'])
            elif les['type'] == 'checkpoint':
                pool, meta = fetch_checkpoint(course_id, u['cefr_level'], u['order_index'])
                entry['pool'] = pool
                entry['exam_meta'] = meta
            lessons.append(entry)
        out.append({'unit': u, 'theory': theory, 'lessons': lessons})
    return course_id, code, lang_name, out


# ══════════════════════════════════════════════════════════════════════════
# ── MAQUETACIÓN (reportlab) ──────────────────────────────────────────────
# ══════════════════════════════════════════════════════════════════════════
from reportlab.lib.pagesizes import LETTER
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.units import mm
from reportlab.lib.enums import TA_CENTER
from reportlab.platypus import (
    BaseDocTemplate, PageTemplate, Frame, Paragraph, Spacer, Table,
    TableStyle, NextPageTemplate, PageBreak, HRFlowable,
)
from reportlab.platypus.tableofcontents import TableOfContents

PAGE_W, PAGE_H = LETTER
MARGIN = 20 * mm

STYLES = {
    'CoverKicker': ParagraphStyle('CoverKicker', fontName='Helvetica-Bold', fontSize=13,
                                   leading=16, textColor=C_WHITE, alignment=TA_CENTER,
                                   spaceAfter=6),
    'CoverTitle': ParagraphStyle('CoverTitle', fontName='Helvetica-Bold', fontSize=40,
                                  leading=44, textColor=C_WHITE, alignment=TA_CENTER),
    'CoverSubtitle': ParagraphStyle('CoverSubtitle', fontName='Helvetica-Bold', fontSize=19,
                                     leading=24, textColor=C_WHITE, alignment=TA_CENTER,
                                     spaceBefore=10),
    'CoverTag': ParagraphStyle('CoverTag', fontName='Helvetica', fontSize=11.5,
                                leading=16, textColor=HexColor('#DAD5FF'),
                                alignment=TA_CENTER, spaceBefore=26),
    'CoverFoot': ParagraphStyle('CoverFoot', fontName='Helvetica', fontSize=9,
                                 leading=12, textColor=HexColor('#C7BFFA'),
                                 alignment=TA_CENTER),
    'TOCTitle': ParagraphStyle('TOCTitle', fontName='Helvetica-Bold', fontSize=24,
                                leading=28, textColor=C_TEXT, spaceAfter=18),
    'UnitHeading': ParagraphStyle('UnitHeading', fontName='Helvetica-Bold', fontSize=19,
                                   leading=23, textColor=C_WHITE),
    'UnitKicker': ParagraphStyle('UnitKicker', fontName='Helvetica-Bold', fontSize=10.5,
                                  leading=13, textColor=HexColor('#EDEBFF'),
                                  spaceAfter=2),
    'TheoryHead': ParagraphStyle('TheoryHead', fontName='Helvetica-Bold', fontSize=12.5,
                                  leading=15, textColor=C_PRIMARY_DARK, spaceBefore=10,
                                  spaceAfter=4),
    'Summary': ParagraphStyle('Summary', fontName='Helvetica-Oblique', fontSize=10.5,
                               leading=15, textColor=C_TEXT, spaceAfter=8),
    'SectionHead': ParagraphStyle('SectionHead', fontName='Helvetica-Bold', fontSize=10.5,
                                   leading=13, textColor=C_TEXT, spaceBefore=6, spaceAfter=2),
    'Body': ParagraphStyle('Body', fontName='Helvetica', fontSize=9.7, leading=13.5,
                            textColor=C_TEXT, spaceAfter=3),
    'Bullet': ParagraphStyle('Bullet', fontName='Helvetica', fontSize=9.5, leading=13,
                              textColor=C_TEXT, leftIndent=12, bulletIndent=0,
                              spaceAfter=2),
    'PitfallTitle': ParagraphStyle('PitfallTitle', fontName='Helvetica-Bold', fontSize=9.7,
                                    leading=12, textColor=HexColor('#8A4B00')),
    'PitfallBody': ParagraphStyle('PitfallBody', fontName='Helvetica', fontSize=9.3,
                                   leading=12.5, textColor=HexColor('#6B4415')),
    'LessonHeading': ParagraphStyle('LessonHeading', fontName='Helvetica-Bold', fontSize=13,
                                     leading=16, textColor=C_TEXT, spaceBefore=14,
                                     spaceAfter=1),
    'LessonMeta': ParagraphStyle('LessonMeta', fontName='Helvetica', fontSize=9,
                                  leading=12, textColor=C_MUTED, spaceAfter=5),
    'LessonDesc': ParagraphStyle('LessonDesc', fontName='Helvetica-Oblique', fontSize=9.5,
                                  leading=13, textColor=C_TEXT, spaceAfter=6),
    'TableHead': ParagraphStyle('TableHead', fontName='Helvetica-Bold', fontSize=9,
                                 leading=11, textColor=C_WHITE),
    'TableCell': ParagraphStyle('TableCell', fontName='Helvetica', fontSize=9,
                                 leading=12, textColor=C_TEXT),
    'ExerciseHead': ParagraphStyle('ExerciseHead', fontName='Helvetica-Bold', fontSize=9.7,
                                    leading=12, textColor=C_PRIMARY_DARK, spaceBefore=6,
                                    spaceAfter=2),
    'ExerciseLine': ParagraphStyle('ExerciseLine', fontName='Helvetica', fontSize=9,
                                    leading=12.5, textColor=C_TEXT, leftIndent=10),
    'CheckpointTitle': ParagraphStyle('CheckpointTitle', fontName='Helvetica-Bold', fontSize=12.5,
                                       leading=15, textColor=C_WHITE),
    'CheckpointLine': ParagraphStyle('CheckpointLine', fontName='Helvetica', fontSize=9.5,
                                      leading=13, textColor=HexColor('#F3EFFF')),
    'MissionTitle': ParagraphStyle('MissionTitle', fontName='Helvetica-Bold', fontSize=11.5,
                                    leading=14, textColor=HexColor('#8A4B00')),
    'MissionBody': ParagraphStyle('MissionBody', fontName='Helvetica', fontSize=9.5,
                                   leading=13, textColor=HexColor('#6B4415')),
    'FootNote': ParagraphStyle('FootNote', fontName='Helvetica-Oblique', fontSize=8,
                                leading=10, textColor=C_MUTED),
}


from xml.sax.saxutils import escape as _esc


def _p(text, style):
    return Paragraph(_esc(text or ''), STYLES[style])


def _rich(markup, style_name):
    """Paragraph con mini-markup reportlab (<b>/<br/>/<font>) ya construido a
    mano — los TROZOS DE DATO deben venir pre-escapados con `_esc()`."""
    return Paragraph(markup, STYLES[style_name])


def _colored_lines(items, back_hex, pad=13, top_pad=11, bottom_pad=11, gap_after=8):
    """Bloque de color de ancho completo hecho de VARIOS Paragraphs top-level
    (uno por línea), no un solo Paragraph con `<br/>` internos.

    reportlab 5.0 (verificado empíricamente, `outputs/_tmp_overlap*.pdf`):
    CUALQUIER Paragraph con `backColor`+`borderPadding` SUBESTIMA su propia
    altura en `wrap()` — exactamente por el valor del padding SUPERIOR — así
    que al dibujarse invade esa misma cantidad del flowable ANTERIOR. Pasa
    tanto con un Paragraph multilínea (`<br/>`) como con Paragraphs sueltos;
    solo no se nota cuando no hay nada crítico justo encima (p.ej. tras un
    PageBreak, como el encabezado de unidad). Fix reproducido y verificado:
    anteponer un `Spacer` del mismo alto que `top_pad` compensa el déficit
    exacto (overlap3_full_0.png, cero solape).

    `items`: lista de (markup_ya_escapado, kwargs_de_ParagraphStyle).
    """
    color = HexColor(back_hex)
    out = [Spacer(1, top_pad)]
    n = len(items)
    for i, (markup, kw) in enumerate(items):
        style = ParagraphStyle('BoxLine%d_%d' % (id(items), i),
                                backColor=color,
                                borderPadding=(top_pad if i == 0 else 0, pad,
                                               bottom_pad if i == n - 1 else 0, pad),
                                spaceAfter=(gap_after if i == n - 1 else 0),
                                **kw)
        out.append(Paragraph(markup, style))
    return out


def _draw_parrot(canv, cx, cy, s):
    """Emblema simplificado del guacamayo de marca (silueta, no el vector
    exacto de ParrotArt en cliente) — solo para reconocimiento de marca."""
    canv.saveState()
    canv.translate(cx, cy)
    canv.scale(s, s)
    # cuerpo
    canv.setFillColor(HexColor('#FF4D6D'))
    canv.circle(0, 0, 15, stroke=0, fill=1)
    # ala / cola dorada
    canv.setFillColor(C_GOLD)
    p = canv.beginPath()
    p.moveTo(-2, -4)
    p.curveTo(-16, -10, -26, -22, -30, -34)
    p.curveTo(-18, -28, -6, -16, 2, -6)
    p.close()
    canv.drawPath(p, stroke=0, fill=1)
    # pico
    canv.setFillColor(C_GOLD)
    p2 = canv.beginPath()
    p2.moveTo(11, 2)
    p2.curveTo(20, 1, 22, -3, 15, -6)
    p2.curveTo(18, -1, 16, 2, 11, 2)
    p2.close()
    canv.drawPath(p2, stroke=0, fill=1)
    # ojo
    canv.setFillColor(C_WHITE)
    canv.circle(6, 5, 3.4, stroke=0, fill=1)
    canv.setFillColor(HexColor('#2B1B10'))
    canv.circle(7, 5, 1.6, stroke=0, fill=1)
    canv.restoreState()


def _hex_darken(hexcolor, factor=0.72):
    from reportlab.lib.colors import Color
    c = HexColor(hexcolor)
    return Color(c.red * factor, c.green * factor, c.blue * factor)


class SyllabusDoc(BaseDocTemplate):
    """Documento con portada + índice auto-generado (TOC de 2 niveles:
    unidad y lección) + páginas de contenido, todo con footer de marca.
    """

    def __init__(self, filename, doc_title, **kw):
        super(SyllabusDoc, self).__init__(filename, pagesize=LETTER,
                                           title=doc_title, author='Jezici',
                                           **kw)
        self._doc_title = doc_title
        cover = Frame(0, 0, PAGE_W, PAGE_H, id='cover', leftPadding=0,
                      rightPadding=0, topPadding=0, bottomPadding=0)
        content = Frame(MARGIN, MARGIN, PAGE_W - 2 * MARGIN, PAGE_H - 2 * MARGIN - 10,
                         id='content')
        self.addPageTemplates([
            PageTemplate(id='Cover', frames=[cover], onPage=self._on_cover),
            PageTemplate(id='Content', frames=[content], onPage=self._on_content),
        ])

    # portada: ver `_on_cover` (función libre, definida más abajo y colgada
    # de la clase — TODO dibujado a canvas: fondo violeta + wordmark + emblema).
    def _on_cover(self, canv, doc):
        return _draw_cover(canv, self)

    def _on_content(self, canv, doc):
        canv.saveState()
        canv.setFont('Helvetica', 8)
        canv.setFillColor(C_MUTED)
        canv.drawString(MARGIN, 12 * mm - 6, 'Jezici · Documento generado automáticamente desde la base de datos')
        canv.drawRightString(PAGE_W - MARGIN, 12 * mm - 6, 'Página %d' % canv.getPageNumber())
        canv.setStrokeColor(C_TABLE_ALT)
        canv.setLineWidth(0.6)
        canv.line(MARGIN, 12 * mm, PAGE_W - MARGIN, 12 * mm)
        canv.restoreState()

    def afterFlowable(self, flowable):
        cls = flowable.__class__.__name__
        if cls != 'Paragraph':
            return
        style = flowable.style.name
        if style == 'UnitHeading':
            text = flowable.getPlainText()
            key = 'u-%s' % text
            self.canv.bookmarkPage(key)
            self.canv.addOutlineEntry(text, key, level=0)
            self.notify('TOCEntry', (0, text, self.page, key))
        elif style == 'LessonHeading':
            text = flowable.getPlainText()
            key = 'l-%s-%d' % (text, self.page)
            self.canv.bookmarkPage(key)
            self.notify('TOCEntry', (1, text, self.page, key))


def _gradient_rect(canv, x, y, w, h, top_hex, mid_hex, bottom_hex, steps=140):
    """Degradado vertical de 3 paradas (el MISMO que usan los headers de la
    app: #7A6BF0 → #6C5CE7 → #5B4ECF, ver CLAUDE.md)."""
    from reportlab.lib.colors import Color

    def lerp(c1, c2, t):
        return Color(c1.red + (c2.red - c1.red) * t,
                     c1.green + (c2.green - c1.green) * t,
                     c1.blue + (c2.blue - c1.blue) * t)

    top, mid, bot = HexColor(top_hex), HexColor(mid_hex), HexColor(bottom_hex)
    band = h / float(steps)
    for i in range(steps):
        t = i / float(steps - 1)
        col = lerp(top, mid, t * 2) if t < 0.5 else lerp(mid, bot, (t - 0.5) * 2)
        canv.setFillColor(col)
        # i=0 es la banda de ARRIBA (t=0=top_hex); dibuja de arriba hacia abajo.
        canv.rect(x, y + h - (i + 1) * band - 0.5, w, band + 1, stroke=0, fill=1)


def _draw_cover(canv, doc):
    """Portada 100% a canvas (posiciones fijas → sin colisión con flowables).
    `doc.cover_lang` / `doc.cover_level` / `doc.cover_tag` los fija `build_pdf`
    antes de `multiBuild`."""
    canv.saveState()
    _gradient_rect(canv, 0, 0, PAGE_W, PAGE_H, '#7A6BF0', '#6C5CE7', '#5B4ECF')
    canv.setFillColor(C_CORAL)
    canv.rect(0, 0, PAGE_W, 9, stroke=0, fill=1)

    canv.setFillColor(C_WHITE)
    canv.setFont('Helvetica-Bold', 13)
    canv.drawCentredString(PAGE_W / 2, PAGE_H * 0.685, 'J E Z I C I')

    canv.setFont('Helvetica-Bold', 40)
    canv.drawCentredString(PAGE_W / 2, PAGE_H * 0.615, 'Temario')

    canv.setFont('Helvetica-Bold', 19)
    canv.drawCentredString(PAGE_W / 2, PAGE_H * 0.555,
                            '%s · %s' % (doc.cover_lang, doc.cover_level))

    _draw_parrot(canv, PAGE_W / 2, PAGE_H * 0.395, 2.5)

    canv.setFillColor(HexColor('#E4DFFF'))
    canv.setFont('Helvetica', 11.5)
    canv.drawCentredString(PAGE_W / 2, PAGE_H * 0.255, doc.cover_tag)

    canv.setFillColor(HexColor('#C7BFFA'))
    canv.setFont('Helvetica', 9)
    canv.drawCentredString(PAGE_W / 2, PAGE_H * 0.09,
                            'Documento oficial de currículo · generado el %s desde el contenido en vivo del curso'
                            % date.today().strftime('%d/%m/%Y'))
    canv.restoreState()


def _cover_story():
    return [NextPageTemplate('Cover'), Spacer(1, PAGE_H - 1), NextPageTemplate('Content'), PageBreak()]


def _toc_story():
    toc = TableOfContents()
    toc.levelStyles = [
        ParagraphStyle('TOCUnit', fontName='Helvetica-Bold', fontSize=11.5, leading=16,
                        textColor=C_PRIMARY_DARK, spaceBefore=8),
        ParagraphStyle('TOCLesson', fontName='Helvetica', fontSize=9.5, leading=13,
                        textColor=C_TEXT, leftIndent=14),
    ]
    story = [NextPageTemplate('Content'), _p('Índice', 'TOCTitle'), toc, PageBreak()]
    return story, toc


def _vocab_table(vocab):
    if not vocab:
        return None
    head = [Paragraph('Palabra / frase', STYLES['TableHead']),
            Paragraph('Traducción', STYLES['TableHead']),
            Paragraph('Categoría', STYLES['TableHead'])]
    rows = [head]
    for v in vocab:
        pos = pos_es(v['part_of_speech']) or '—'
        rows.append([Paragraph(v['word'], STYLES['TableCell']),
                     Paragraph(v['translation'] or '—', STYLES['TableCell']),
                     Paragraph(pos, STYLES['TableCell'])])
    tbl = Table(rows, colWidths=[62 * mm, 62 * mm, 32 * mm], repeatRows=1)
    style = [
        ('BACKGROUND', (0, 0), (-1, 0), C_PRIMARY),
        ('TOPPADDING', (0, 0), (-1, -1), 3.2),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 3.2),
        ('LEFTPADDING', (0, 0), (-1, -1), 6),
        ('LINEBELOW', (0, 0), (-1, 0), 0.6, C_PRIMARY_DARK),
        ('VALIGN', (0, 0), (-1, -1), 'TOP'),
    ]
    for i in range(1, len(rows)):
        if i % 2 == 0:
            style.append(('BACKGROUND', (0, i), (-1, i), C_TABLE_ALT))
    tbl.setStyle(TableStyle(style))
    return tbl


def _exercise_block(total, by_skill):
    if not total:
        return None
    noun = 'ejercicio' if total == 1 else 'ejercicios'
    lines = [_p('%d %s · las 4 habilidades' % (total, noun), 'ExerciseHead')]
    for sk in SKILL_ORDER:
        items = by_skill.get(sk)
        if not items:
            continue
        n = sum(c for _, c in items)
        parts = ', '.join('%s ×%d' % (TYPE_ES.get(t, t), c) for t, c in
                           sorted(items, key=lambda x: -x[1]))
        lines.append(_p('%s (%d): %s' % (SKILL_ES[sk], n, parts), 'ExerciseLine'))
    return lines


def _theory_flowables(theory):
    out = []
    if theory['kind'] == 'rich':
        out.append(_p('Punto de gramática / concepto de la unidad', 'TheoryHead'))
        if theory['summary']:
            out.append(_p(theory['summary'], 'Summary'))
        for sec in theory['sections']:
            if sec.get('heading'):
                out.append(_p(sec['heading'], 'SectionHead'))
            if sec.get('body'):
                out.append(_p(sec['body'], 'Body'))
            for b in sec.get('bullets') or []:
                out.append(_p('•  ' + b, 'Bullet'))
        if theory['examples']:
            out.append(_p('Ejemplos', 'SectionHead'))
            for ex in theory['examples']:
                tgt = ex.get('text') or ex.get('en') or ''
                es = ex.get('es') or ''
                if tgt:
                    out.append(_p('“%s” — %s' % (tgt, es), 'Bullet'))
        if theory['pitfalls']:
            out.append(_p('Errores comunes del hispanohablante', 'SectionHead'))
            items = []
            for p in theory['pitfalls']:
                items.append(('⚠ <b>%s</b>' % _esc(p.get('title') or ''),
                               dict(fontName='Helvetica-Bold', fontSize=9.7, leading=12,
                                    textColor=HexColor('#8A4B00'))))
                items.append((_esc(p.get('body') or ''),
                               dict(fontName='Helvetica', fontSize=9.3, leading=12.5,
                                    textColor=HexColor('#6B4415'))))
            out.append(Spacer(1, 2))
            out.extend(_colored_lines(items, '#FFF4E6'))
    elif theory['kind'] == 'tips':
        out.append(_p('Puntos de gramática / conceptos de la unidad', 'TheoryHead'))
        for t in theory['tips']:
            label = TIP_TYPE_ES.get(t['type'], t['type'])
            out.append(_p('%s — %s' % (label, t['title']), 'SectionHead'))
            out.append(_p(t['body'], 'Body'))
            if t.get('example'):
                out.append(_p('Ejemplo: “%s”' % t['example'], 'Bullet'))
    else:
        out.append(_p('Punto de gramática / concepto de la unidad', 'TheoryHead'))
        out.append(_p('Teoría en camino — esta unidad todavía no tiene ficha de teoría '
                       'curada en la base de datos (estado honesto: no se inventa contenido).',
                       'FootNote'))
    return out


def _lesson_flowables(les):
    out = []
    title = clean(les['title'])
    kicker = {'lesson': 'LECCIÓN', 'checkpoint': 'EXAMEN DE LA UNIDAD',
              'mission': 'ACTIVIDAD DE BIENVENIDA', 'exam': 'EXAMEN'}.get(les['type'], les['type'].upper())

    if les['type'] == 'checkpoint':
        pool = les.get('pool') or {}
        meta = les.get('exam_meta')
        total_pool = sum(pool.values())
        items = [(_esc(title), dict(fontName='Helvetica-Bold', fontSize=12.5, leading=15,
                                     textColor=C_WHITE))]
        line_kw = dict(fontName='Helvetica', fontSize=9.5, leading=13, textColor=HexColor('#F3EFFF'))
        if meta:
            mins = int(meta['time_limit_sec']) // 60
            pct = int(round(float(meta['pass_threshold']) * 100))
            items.append(('Cronometrado (%d min) · aprueba con ≥%d%% · mezcla las 4 habilidades'
                           % (mins, pct), line_kw))
        if total_pool:
            per_skill = ', '.join('%s: %d' % (SKILL_ES[k], v) for k, v in pool.items() if k in SKILL_ES)
            items.append(('Cada intento sortea 10 ejercicios (3 lectura + 3 escritura + '
                           '2 audición + 2 producción oral) de un banco de %d ítems de la unidad '
                           '(%s).' % (total_pool, _esc(per_skill)), line_kw))
        out.append(Spacer(1, 6))
        out.extend(_colored_lines(items, '#4B3FC9'))
        return out

    if les['type'] == 'mission':
        items = [(_esc(title), dict(fontName='Helvetica-Bold', fontSize=11.5, leading=14,
                                     textColor=HexColor('#8A4B00')))]
        if les.get('description'):
            items.append((_esc(les['description']), dict(fontName='Helvetica', fontSize=9.5,
                                                           leading=13, textColor=HexColor('#6B4415'))))
        out.append(Spacer(1, 6))
        out.extend(_colored_lines(items, '#FFF4E6'))
        return out

    # lección normal
    out.append(_p(title, 'LessonHeading'))
    xp = les.get('xp_reward') or 0
    out.append(_p('%s · %d XP' % (kicker, xp), 'LessonMeta'))
    if les.get('description'):
        out.append(_p(les['description'], 'LessonDesc'))
    vt = _vocab_table(les.get('vocab') or [])
    if vt:
        out.append(_p('Vocabulario nuevo (%d)' % len(les['vocab']), 'SectionHead'))
        out.append(vt)
    ex = _exercise_block(les.get('total_ex') or 0, les.get('by_skill') or {})
    if ex:
        out.extend(ex)
    return out


def _unit_header(u_row):
    """UN solo bloque de color, pero en 2 Paragraphs top-level (kicker + título)
    con el MISMO backColor y cero espacio entre ellos — se ve como una sola
    banda, y el título (estilo 'UnitHeading') es el que dispara el TOC/
    bookmark en `afterFlowable` (con texto LIMPIO, sin el kicker mezclado)."""
    hexcolor = u_row['theme_color'] or '#6C5CE7'
    color = HexColor(hexcolor)
    kicker_style = ParagraphStyle('UnitKickerBox', parent=STYLES['UnitKicker'],
                                   backColor=color, borderPadding=(12, 14, 1, 14), spaceAfter=0)
    title_style = ParagraphStyle('UnitHeading', parent=STYLES['UnitHeading'],
                                  backColor=color, borderPadding=(1, 14, 12, 14), spaceAfter=0)
    kicker = Paragraph(_esc('UNIDAD %d · NIVEL %s' % (u_row['order_index'], u_row['cefr_level'])),
                        kicker_style)
    title = Paragraph(_esc(clean(u_row['title'])), title_style)
    depth = HRFlowable(width='100%', thickness=3, color=_hex_darken(hexcolor, 0.66),
                        spaceBefore=0, spaceAfter=8)
    # mismo déficit de altura de reportlab que `_colored_lines` (ver ahí) —
    # aquí no se nota (cae justo tras un PageBreak) pero se compensa igual.
    return [Spacer(1, 12), kicker, title, depth]


def build_pdf(out_path, course_code, lang_name, level_label, units_data):
    doc = SyllabusDoc(out_path, doc_title='Jezici — Temario %s %s' % (lang_name, level_label))
    doc.cover_lang = lang_name
    doc.cover_level = level_label
    doc.cover_tag = 'Currículo real del curso · %d unidad%s' % (
        len(units_data), '' if len(units_data) == 1 else 'es')

    story = []
    story.extend(_cover_story())
    toc_story, toc = _toc_story()
    story.extend(toc_story)

    for i, entry in enumerate(units_data):
        u = entry['unit']
        if i > 0:
            story.append(PageBreak())
        story.extend(_unit_header(u))
        story.extend(_theory_flowables(entry['theory']))
        story.append(Spacer(1, 4))
        story.append(HRFlowable(width='100%', thickness=0.6, color=C_TABLE_ALT,
                                 spaceBefore=4, spaceAfter=6))
        for les in entry['lessons']:
            story.extend(_lesson_flowables(les))

    doc.multiBuild(story)
    return out_path


LEVEL_ORDER = ['A1', 'A2', 'B1', 'B2', 'C1']


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument('--course', required=True, help='código del curso (en/pt/fr/it/de/nl/ro)')
    ap.add_argument('--level', default=None, help='CEFR (A1/A2/B1/B2/C1); si se omite, TODOS los niveles del curso')
    ap.add_argument('--out', default=None, help='ruta del PDF de salida')
    args = ap.parse_args()

    level = args.level.upper() if args.level else None
    course_id, code, lang_name = get_course(args.course)
    _, _, _, units_data = build_data(args.course, level)

    levels_present = sorted({e['unit']['cefr_level'] for e in units_data},
                             key=lambda x: LEVEL_ORDER.index(x) if x in LEVEL_ORDER else 99)
    level_label = level or ('%s–%s' % (levels_present[0], levels_present[-1])
                             if len(levels_present) > 1 else levels_present[0])

    out_dir = os.path.join(HERE, 'outputs')
    os.makedirs(out_dir, exist_ok=True)
    out_path = args.out or os.path.join(
        out_dir, 'temario_%s_%s.pdf' % (code, level.lower() if level else 'completo'))

    build_pdf(out_path, code, lang_name, level_label, units_data)

    n_lessons = sum(len(e['lessons']) for e in units_data)
    n_vocab = sum(len(les.get('vocab') or []) for e in units_data for les in e['lessons'])
    print('OK ->', out_path)
    print('  %d unidades (%s) · %d lecciones/actividades · %d palabras de vocabulario listadas'
          % (len(units_data), level_label, n_lessons, n_vocab))


if __name__ == '__main__':
    main()

