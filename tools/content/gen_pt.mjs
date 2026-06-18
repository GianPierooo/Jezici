// Generador de niveles de PORTUGUÉS (es→pt) A2/B1/B2 con CHECKPOINTS FRESCOS.
//   node gen_pt.mjs <A2|B1|B2> [in.json] [out.sql]
// · course_id = es→pt (20000000-…-0002). order_index = U (de las unidades).
// · Namespace de ids separado del es→en: units 32…, lessons 42…, exams 52…,
//   items dX…, vocab dXb… (X=2/3/4 según nivel). Todo hex válido.
// · CHECKPOINT FRESCO: cada unidad trae 'checkpoint' (≈10 ítems propios). Se emiten
//   como content_items con tag 'cp_unidadN' (NO 'unidadN') para que NO entren al
//   pool del examen de nivel (start_level_exam filtra tags like 'unidad%'), y se
//   cablean al lesson_items de la lección checkpoint. Mide transferencia, no memoria.
import fs from 'node:fs';

const LEVEL = (process.argv[2] || 'A2').toUpperCase();
const CFG = {
  A2: { p: 'd2', vb: 'd2b', vbase: 300, lo: 0.18, hi: 0.60, def: 0.35, mig: '052' },
  B1: { p: 'd3', vb: 'd3b', vbase: 500, lo: 0.35, hi: 0.65, def: 0.50, mig: '053' },
  B2: { p: 'd4', vb: 'd4b', vbase: 900, lo: 0.45, hi: 0.80, def: 0.62, mig: '054' },
}[LEVEL];
if (!CFG) throw new Error('nivel inválido: ' + LEVEL);

const IN = process.argv[3] || `C:/Users/gianp/Desktop/Jezici/tools/content/pt_${LEVEL.toLowerCase()}_units.json`;
const migDate = { A2: '20260620140052', B1: '20260620150053', B2: '20260620160054' }[LEVEL];
const OUT = process.argv[4] || `C:/Users/gianp/Desktop/Jezici/supabase/migrations/${migDate}_seed_pt_${LEVEL.toLowerCase()}.sql`;
const COURSE = '20000000-0000-0000-0000-000000000002';
const AUDIO_BASE = 'https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/';

const raw = JSON.parse(fs.readFileSync(IN, 'utf8'));
const units = (raw.data || raw).slice().sort((a, b) => a.U - b.U);

const pad = (n, l) => String(n).padStart(l, '0');
const unitId = (U) => `32000000-0000-0000-0000-${pad(U, 12)}`;
const examId = (U) => `52000000-0000-0000-0000-${pad(U, 12)}`;
const lessonId = (U, L) => `42000000-0000-0000-0000-${pad(U * 100 + L, 12)}`;
let _iseq = 0, _vseq = 0;
const nextItemId = () => { _iseq += 1; return `${CFG.p}${pad(_iseq, 8 - CFG.p.length)}-0000-0000-0000-${pad(_iseq, 12)}`; };
const nextVocabId = () => { _vseq += 1; return `${CFG.vb}${pad(_vseq, 8 - CFG.vb.length)}-0000-0000-0000-${pad(_vseq, 12)}`; };

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
    else c.pairs.forEach((cp, i) => { if (!Array.isArray(cp) || cp.length !== 2) issues.push(`${at}: correct.pairs[${i}] no es [pt,es]`); });
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
-- Jezici · Migración ${CFG.mig} · Siembra del currículo ${LEVEL} de PORTUGUÉS (es→pt)
-- ----------------------------------------------------------------------------
-- Curso es→pt (português do Brasil). Autorado + QA adversarial + validado contra
-- el grader. cefr '${LEVEL}'. CHECKPOINTS FRESCOS (ítems propios, tag 'cp_unidadN',
-- fuera del pool del examen de nivel). Namespace de ids separado (${CFG.p}/${CFG.vb}).
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
  sql += `\n-- ── Unidad ${U} (${LEVEL}·pt): ${utitle} ─────────────────────────────\n`;
  sql += `insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values\n`;
  sql += ` ('${unitId(U)}','${COURSE}','${LEVEL}',${U},${dq(utitle, 'p')},'${(u.theme_color || '#6C5CE7').replace(/'/g, '')}','${slug(u.icon)}')\non conflict (course_id, order_index) do update set title=excluded.title, theme_color=excluded.theme_color, icon=excluded.icon;\n`;

  sql += `insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values\n`;
  const lr = u.lessons.map((les, li) => ` ('${lessonId(U, li + 1)}','${unitId(U)}',${li + 1},${dq(les.title, 'p')},${dq(les.description || les.title, 'p')},'lesson',15)`);
  lr.push(` ('${lessonId(U, u.lessons.length + 1)}','${unitId(U)}',${u.lessons.length + 1},${dq('🏁 Checkpoint Unidade ' + U, 'p')},${dq(u.checkpoint_description || 'Cronometrado · 4 habilidades · 80%.', 'p')},'checkpoint',40)`);
  sql += lr.join(',\n') + `\non conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;\n`;

  sql += `insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values\n`;
  sql += ` ('${examId(U)}','${COURSE}','checkpoint','${LEVEL}','${unitId(U)}',300,0.80,${jq({ skills: ['reading', 'listening', 'writing', 'speaking'], item_count: 10, randomize: true })})\non conflict (id) do nothing;\n`;

  const rows = [], li_rows = [];
  const clamp = (d) => Math.min(CFG.hi, Math.max(CFG.lo, Number(d) || CFG.def)).toFixed(2);
  // Ítems de lección (tag unidadN → entran al pool del examen de nivel).
  u.lessons.forEach((les, li) => {
    const L = li + 1, topic = slug(les.topic || les.title);
    les.items.forEach((it, ii) => {
      const id = nextItemId();
      const payload = { ...it.payload };
      if (it.type === 'listening' || it.type === 'speaking_read_aloud') payload.audio_url = AUDIO_BASE + id + '.mp3';
      rows.push(` ('${id}','${COURSE}','${LEVEL}','${it.skill}','${it.type}',\n   ${dq(it.prompt, 'p')},\n   ${jq(payload)}, ${jq(it.correct)},\n   ${clamp(it.difficulty)}, ARRAY['unidad${U}','${topic}','${it.skill}'])`);
      li_rows.push(` ('${lessonId(U, L)}','${id}',${ii + 1})`);
    });
  });
  // Ítems FRESCOS de checkpoint (tag cp_unidadN → NO entran al examen de nivel).
  cp.forEach((it, ii) => {
    const id = nextItemId();
    const payload = { ...it.payload };
    if (it.type === 'listening' || it.type === 'speaking_read_aloud') payload.audio_url = AUDIO_BASE + id + '.mp3';
    rows.push(` ('${id}','${COURSE}','${LEVEL}','${it.skill}','${it.type}',\n   ${dq(it.prompt, 'p')},\n   ${jq(payload)}, ${jq(it.correct)},\n   ${clamp(it.difficulty)}, ARRAY['cp_unidad${U}','checkpoint','${it.skill}'])`);
    li_rows.push(` ('${lessonId(U, u.lessons.length + 1)}','${id}',${ii + 1})`);
  });
  sql += `insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values\n`;
  sql += rows.join(',\n') + `\non conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();\n`;
  sql += `insert into lesson_items (lesson_id, item_id, order_index) values\n` + li_rows.join(',\n') + `\non conflict (lesson_id, item_id) do nothing;\n`;

  if (u.vocab && u.vocab.length) {
    const vr = u.vocab.slice(0, 16).map((v, k) => ` ('${nextVocabId()}','${COURSE}',${dq(v.word, 'p')},${dq(v.translation, 'p')},${CFG.vbase + U * 20 + k},'${slug(v.pos || 'word')}')`);
    sql += `insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values\n` + vr.join(',\n') + `\non conflict (id) do nothing;\n`;
  }
}

sql += `\ncommit;\n`;

if (issues.length) { console.log(`=== ${issues.length} PROBLEMAS ===`); issues.forEach((i) => console.log(' - ' + i)); console.log('NO se escribió la migración.'); process.exit(2); }
fs.writeFileSync(OUT, sql);
const lessonItems = units.reduce((a, u) => a + u.lessons.reduce((b, l) => b + l.items.length, 0), 0);
const cpItems = units.reduce((a, u) => a + (u.checkpoint || []).length, 0);
console.log(`OK ✓ ${OUT}`);
console.log(`${LEVEL} · unidades: ${units.map((u) => u.U).join(', ')} · lección: ${lessonItems} · checkpoint fresco: ${cpItems} · total: ${lessonItems + cpItems}`);
