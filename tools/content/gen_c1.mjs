// Genera la migración SQL del currículo C1 (es→en, Unidades 25–30) a partir de los
// 6 ficheros c1_uNN.json (autorados por profesor-IA, uno por unidad), normalizando al
// formato del grader y VALIDANDO antes de emitir. Clon de gen_pt.mjs con dos diferencias
// de diseño clave (ver docs/LEVELS_C1_DESIGN.md · TECHO DETERMINISTA):
//   1. Curso es→en (…001), cefr 'C1', ids propios (31…/41…/51…/c5…/b5b…) sin colisión.
//   2. Los ítems de LECCIÓN se taguean 'c1_unidadN' (NO 'unidadN') → quedan FUERA del pool
//      del examen de nivel (start_level_exam filtra tags like 'unidad%'). Así NO se puede
//      formar/aprobar un examen C1 ni emitir cert JZC-C1: C1 es "en progreso" hasta Fase 2.
//      Los checkpoints FRESCOS van con 'cp_unidadN' (también fuera del pool). La progresión
//      intra-C1 la gatean los checkpoints (≥80%, autocalificados).
import fs from 'node:fs';

const DIR = 'C:/Users/gianp/Desktop/Jezici/tools/content';
const OUT = process.argv[2] || 'C:/Users/gianp/Desktop/Jezici/supabase/migrations/20260623240063_seed_c1.sql';
const COURSE = '20000000-0000-0000-0000-000000000001';
const AUDIO_BASE = 'https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/';
const LO = 0.62, HI = 0.92, DEF = 0.72;

const units = [25, 26, 27, 28, 29, 30]
  .map((U) => JSON.parse(fs.readFileSync(`${DIR}/c1_u${U}.json`, 'utf8')))
  .sort((a, b) => a.U - b.U);

const pad = (n, l) => String(n).padStart(l, '0');
const unitId = (U) => `31000000-0000-0000-0000-${pad(U, 12)}`;
const examId = (U) => `51000000-0000-0000-0000-${pad(U, 12)}`;
const lessonId = (U, L) => `41000000-0000-0000-0000-${pad(U * 100 + L, 12)}`;
let _iseq = 0, _vseq = 0;
const nextItemId = () => { _iseq += 1; return `c5${pad(_iseq, 6)}-0000-0000-0000-${pad(_iseq, 12)}`; };
const nextVocabId = () => { _vseq += 1; return `b5b${pad(_vseq, 5)}-0000-0000-0000-${pad(_vseq, 12)}`; };

const slug = (s) => (s || '').toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, '').replace(/[^a-z0-9]+/g, '_').replace(/^_|_$/g, '') || 'x';
const norm = (t) => (t || '').toLowerCase().replace(/[.!?¿¡,;:']/g, '').replace(/\s+/g, ' ').trim();
const dq = (s, tag) => { if (('' + s).includes(`$${tag}$`)) throw new Error(`delimitador $${tag}$ en: ${s}`); return `$${tag}$${s}$${tag}$`; };
const jq = (o) => dq(JSON.stringify(o), 'j') + '::jsonb';

function normalizeItem(it) {
  const t = it.type, skill = it.skill;
  if (t === 'multiple_choice' || t === 'true_false') return { type: t, skill, prompt: it.prompt, payload: { options: it.options }, correct: { value: it.value } };
  if (t === 'match') { const pairs = it.pairs || []; return { type: 'match', skill, prompt: it.prompt, payload: { pairs: pairs.map(([en, es]) => ({ en, es })) }, correct: { pairs } }; }
  if (t === 'cloze') { const v = it.value ?? (it.accepted && it.accepted[0]); return { type: 'cloze', skill, prompt: it.prompt, payload: { text: it.text }, correct: { value: v, accepted: it.accepted && it.accepted.length ? it.accepted : [v] } }; }
  if (t === 'translation') { const v = it.value ?? (it.accepted && it.accepted[0]); return { type: 'translation', skill, prompt: it.prompt || `Traduce: "${it.source}".`, payload: { source: it.source }, correct: { value: v, accepted: it.accepted && it.accepted.length ? it.accepted : [v] } }; }
  if (t === 'word_bank') { const seq = it.sequence || []; return { type: 'word_bank', skill, prompt: it.prompt, payload: { tiles: it.tiles }, correct: { value: seq.join(' '), sequence: seq } }; }
  if (t === 'reorder') { const v = it.value ?? (Array.isArray(it.sequence) ? it.sequence.join(' ') : undefined); return { type: 'reorder', skill, prompt: it.prompt, payload: { tiles: it.tiles }, correct: { value: v } }; }
  if (t === 'listening') return { type: 'listening', skill, prompt: it.prompt || 'Escucha y elige lo que oíste.', payload: { options: it.options, say: it.value }, correct: { value: it.value } };
  if (t === 'speaking_read_aloud') return { type: 'speaking_read_aloud', skill, prompt: it.prompt || 'Lee en voz alta:', payload: { text: it.text }, correct: { expected: it.text } };
  return { type: t, skill, prompt: it.prompt, payload: {}, correct: {}, _bad: true };
}

const issues = [];
function validateItem(at, it) {
  const p = it.payload || {}, c = it.correct || {};
  if (it._bad) { issues.push(`${at}: tipo desconocido`); return; }
  if (!it.prompt) issues.push(`${at}: falta prompt`);
  if (it.type === 'multiple_choice' || it.type === 'true_false') {
    if (!Array.isArray(p.options) || p.options.length < 2) issues.push(`${at}: faltan options`);
    else if (!p.options.some((o) => norm(o) === norm(c.value))) issues.push(`${at}: correct.value "${c.value}" no está en options`);
    else if (p.options.filter((o) => norm(o) === norm(c.value)).length > 1) issues.push(`${at}: value normaliza igual que un distractor ${JSON.stringify(p.options)}`);
  } else if (it.type === 'match') {
    if (!Array.isArray(p.pairs) || !Array.isArray(c.pairs) || p.pairs.length !== c.pairs.length || p.pairs.length < 2) issues.push(`${at}: pairs mal formados`);
    else c.pairs.forEach((cp, i) => { if (!Array.isArray(cp) || cp.length !== 2) issues.push(`${at}: correct.pairs[${i}] no es [en,es]`); });
  } else if (it.type === 'cloze' || it.type === 'translation') {
    if (!c.value) issues.push(`${at}: falta correct.value`);
    if (it.type === 'cloze' && !p.text) issues.push(`${at}: falta payload.text`);
    if (it.type === 'cloze' && p.text && !p.text.includes('_')) issues.push(`${at}: el cloze no tiene hueco (___)`);
    if (it.type === 'translation' && !p.source) issues.push(`${at}: falta payload.source`);
  } else if (it.type === 'word_bank') {
    if (!Array.isArray(p.tiles) || !Array.isArray(c.sequence)) issues.push(`${at}: faltan tiles/sequence`);
    else if (!c.sequence.every((t) => p.tiles.includes(t))) issues.push(`${at}: sequence con fichas fuera de tiles`);
  } else if (it.type === 'reorder') {
    if (!Array.isArray(p.tiles) || !c.value) issues.push(`${at}: faltan tiles/value`);
    else { const vw = norm(c.value).split(' ').sort().join(' '); const tw = p.tiles.map(norm).sort().join(' '); if (vw !== tw) issues.push(`${at}: value no usa exactamente las tiles (value="${c.value}" tiles=${JSON.stringify(p.tiles)})`); }
  } else if (it.type === 'listening') {
    if (!Array.isArray(p.options) || p.options.length < 2 || !c.value) issues.push(`${at}: listening mal formado`);
    else if (!p.options.some((o) => norm(o) === norm(c.value))) issues.push(`${at}: listening value no está en options`);
  } else if (it.type === 'speaking_read_aloud') {
    if (!p.text || !c.expected) issues.push(`${at}: speaking mal formado`);
  } else issues.push(`${at}: tipo desconocido ${it.type}`);
}
const sk = (items) => { const c = { reading: 0, writing: 0, listening: 0, speaking: 0 }; items.forEach((it) => c[it.skill] = (c[it.skill] || 0) + 1); return c; };

let sql = `-- ============================================================================
-- Jezici · Migración 063 · Siembra del currículo C1 de INGLÉS (es→en, U25–U30)
-- ----------------------------------------------------------------------------
-- Autorado (profesor-IA por unidad) + validado contra el grader. cefr 'C1'.
-- TECHO DETERMINISTA (ver docs/LEVELS_C1_DESIGN.md): los ítems de LECCIÓN llevan
-- tag 'c1_unidadN' (NO 'unidad%') → FUERA del pool del examen de nivel: no se puede
-- formar/aprobar examen C1 ni emitir cert JZC-C1. C1 = "en progreso" hasta Fase 2
-- (evaluación real de writing/speaking). Checkpoints FRESCOS ('cp_unidadN'), también
-- fuera del pool, gatean la progresión intra-C1 (≥80%, autocalificados).
-- Namespace de ids separado (31…/41…/51…/c5…/b5b…). content_items idempotente.
-- ============================================================================
begin;
`;

for (const u of units) {
  const U = u.U;
  u.lessons.forEach((les, li) => les.items.forEach((rawIt, ii) => { const it = normalizeItem(rawIt); les.items[ii] = it; validateItem(`U${U} L${li + 1} i${ii + 1}`, it); }));
  const cp = (u.checkpoint || []).map((rawIt, ii) => { const it = normalizeItem(rawIt); validateItem(`U${U} CP i${ii + 1}`, it); return it; });
  const tot = { reading: 0, writing: 0, listening: 0, speaking: 0 };
  u.lessons.forEach((les) => { const c = sk(les.items); ['reading', 'writing', 'listening', 'speaking'].forEach((s) => tot[s] += c[s]); });
  if (tot.reading < 3 || tot.writing < 3 || tot.listening < 2 || tot.speaking < 2) issues.push(`U${U}: distribución insuficiente ${JSON.stringify(tot)}`);
  if (u.lessons.length < 4) issues.push(`U${U}: <4 lecciones`);
  u.lessons.forEach((les, li) => { if (les.items.length < 8) issues.push(`U${U} L${li + 1}: <8 ítems`); });
  if (cp.length < 8) issues.push(`U${U}: checkpoint fresco con ${cp.length} ítems (se esperan >=8)`);
  const cpc = sk(cp);
  if (cpc.reading < 2 || cpc.writing < 2 || cpc.listening < 1 || cpc.speaking < 1) issues.push(`U${U} CP: distribución ${JSON.stringify(cpc)}`);

  const utitle = (u.title || '').trim();
  sql += `\n-- ── Unidad ${U} (C1·en): ${utitle} ─────────────────────────────\n`;
  sql += `insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values\n`;
  sql += ` ('${unitId(U)}','${COURSE}','C1',${U},${dq(utitle, 'p')},'${(u.theme_color || '#6C5CE7').replace(/'/g, '')}','${slug(u.icon)}')\non conflict (course_id, order_index) do update set title=excluded.title, theme_color=excluded.theme_color, icon=excluded.icon;\n`;

  sql += `insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values\n`;
  const lr = u.lessons.map((les, li) => ` ('${lessonId(U, li + 1)}','${unitId(U)}',${li + 1},${dq(les.title, 'p')},${dq(les.description || les.title, 'p')},'lesson',15)`);
  lr.push(` ('${lessonId(U, u.lessons.length + 1)}','${unitId(U)}',${u.lessons.length + 1},${dq('🏁 Checkpoint Unidad ' + U, 'p')},${dq(u.checkpoint_description || 'Cronometrado · 4 habilidades · 80%.', 'p')},'checkpoint',40)`);
  sql += lr.join(',\n') + `\non conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;\n`;

  // Exam de CHECKPOINT por unidad (type 'checkpoint', NO 'level' → no emite cert).
  sql += `insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values\n`;
  sql += ` ('${examId(U)}','${COURSE}','checkpoint','C1','${unitId(U)}',300,0.80,${jq({ skills: ['reading', 'listening', 'writing', 'speaking'], item_count: 10, randomize: true })})\non conflict (id) do nothing;\n`;

  const rows = [], li_rows = [];
  const clamp = (d) => Math.min(HI, Math.max(LO, Number(d) || DEF)).toFixed(2);
  // Ítems de LECCIÓN → tag 'c1_unidadN' (FUERA del pool del examen de nivel).
  u.lessons.forEach((les, li) => {
    const L = li + 1, topic = slug(les.topic || les.title);
    les.items.forEach((it, ii) => {
      const id = nextItemId();
      const payload = { ...it.payload };
      if (it.type === 'listening' || it.type === 'speaking_read_aloud') payload.audio_url = AUDIO_BASE + id + '.mp3';
      rows.push(` ('${id}','${COURSE}','C1','${it.skill}','${it.type}',\n   ${dq(it.prompt, 'p')},\n   ${jq(payload)}, ${jq(it.correct)},\n   ${clamp(it.difficulty)}, ARRAY['c1_unidad${U}','${topic}','${it.skill}'])`);
      li_rows.push(` ('${lessonId(U, L)}','${id}',${ii + 1})`);
    });
  });
  // Ítems FRESCOS de checkpoint → tag 'cp_unidadN' (también fuera del pool).
  cp.forEach((it, ii) => {
    const id = nextItemId();
    const payload = { ...it.payload };
    if (it.type === 'listening' || it.type === 'speaking_read_aloud') payload.audio_url = AUDIO_BASE + id + '.mp3';
    rows.push(` ('${id}','${COURSE}','C1','${it.skill}','${it.type}',\n   ${dq(it.prompt, 'p')},\n   ${jq(payload)}, ${jq(it.correct)},\n   ${clamp(it.difficulty)}, ARRAY['cp_unidad${U}','checkpoint','${it.skill}'])`);
    li_rows.push(` ('${lessonId(U, u.lessons.length + 1)}','${id}',${ii + 1})`);
  });
  sql += `insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values\n`;
  sql += rows.join(',\n') + `\non conflict (id) do update set skill=excluded.skill, type=excluded.type, prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();\n`;
  sql += `insert into lesson_items (lesson_id, item_id, order_index) values\n` + li_rows.join(',\n') + `\non conflict (lesson_id, item_id) do nothing;\n`;

  if (u.vocab && u.vocab.length) {
    const vr = u.vocab.slice(0, 16).map((v, k) => ` ('${nextVocabId()}','${COURSE}',${dq(v.word, 'p')},${dq(v.translation, 'p')},${1100 + U * 20 + k},'${slug(v.pos || 'word')}')`);
    sql += `insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values\n` + vr.join(',\n') + `\non conflict (id) do nothing;\n`;
  }
}

sql += `\ncommit;\n`;

if (issues.length) { console.log(`=== ${issues.length} PROBLEMAS ===`); issues.forEach((i) => console.log(' - ' + i)); console.log('NO se escribió la migración.'); process.exit(2); }
fs.writeFileSync(OUT, sql);
const lessonItems = units.reduce((a, u) => a + u.lessons.reduce((b, l) => b + l.items.length, 0), 0);
const cpItems = units.reduce((a, u) => a + (u.checkpoint || []).length, 0);
console.log(`OK ✓ ${OUT}`);
console.log(`C1 · unidades: ${units.map((u) => u.U).join(', ')} · lección: ${lessonItems} · checkpoint fresco: ${cpItems} · total: ${lessonItems + cpItems}`);
