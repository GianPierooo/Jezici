// Genera la migración SQL del currículo A1 de PORTUGUÉS (es→pt, Unidades 1–6) a
// partir del JSON autorado (pt_a1_units.json, workflow pt-a1-author-content),
// normalizando al formato del grader y validando ANTES de emitir.
//  · course_id = curso es→pt (20000000-…-0002); cefr_level='A1', order 1..6.
//  · Namespace de ids SEPARADO del curso es→en para no colisionar:
//    units 32…, lessons 42…, exams 52…, items d1…, vocab d1b… (todo hex válido).
//  · dificultad A1 en [0.05, 0.35]. content_items idempotente (DO UPDATE).
import fs from 'node:fs';

const IN = process.argv[2] || 'C:/Users/gianp/Desktop/Jezici/tools/content/pt_a1_units.json';
const OUT = process.argv[3] || 'C:/Users/gianp/Desktop/Jezici/supabase/migrations/20260620110048_seed_pt_a1.sql';
const COURSE = '20000000-0000-0000-0000-000000000002'; // es→pt
const AUDIO_BASE = 'https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/';

const raw = JSON.parse(fs.readFileSync(IN, 'utf8'));
const units = (raw.data || raw).slice().sort((a, b) => a.U - b.U);

const pad = (n, l) => String(n).padStart(l, '0');
const unitId = (U) => `32000000-0000-0000-0000-${pad(U, 12)}`;
const examId = (U) => `52000000-0000-0000-0000-${pad(U, 12)}`;
const lessonId = (U, L) => `42000000-0000-0000-0000-${pad(U * 100 + L, 12)}`;
let _iseq = 0, _vseq = 0;
const nextItemId = () => { _iseq += 1; return `d1${pad(_iseq, 6)}-0000-0000-0000-${pad(_iseq, 12)}`; };
const nextVocabId = () => { _vseq += 1; return `d1b${pad(_vseq, 5)}-0000-0000-0000-${pad(_vseq, 12)}`; };

const slug = (s) => (s || '').toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, '').replace(/[^a-z0-9]+/g, '_').replace(/^_|_$/g, '') || 'x';
const norm = (t) => (t || '').toLowerCase().replace(/[.!?¿¡,;:']/g, '').replace(/\s+/g, ' ').trim();
const dq = (s, tag) => { if (('' + s).includes(`$${tag}$`)) throw new Error(`delimitador $${tag}$ dentro del contenido: ${s}`); return `$${tag}$${s}$${tag}$`; };
const jq = (o) => dq(JSON.stringify(o), 'j') + '::jsonb';

function normalizeItem(it) {
  const t = it.type, skill = it.skill;
  if (t === 'multiple_choice' || t === 'true_false') return { type: t, skill, prompt: it.prompt, payload: { options: it.options }, correct: { value: it.value } };
  if (t === 'match') { const pairs = it.pairs || []; return { type: 'match', skill, prompt: it.prompt, payload: { pairs: pairs.map(([en, es]) => ({ en, es })) }, correct: { pairs } }; }
  if (t === 'cloze') return { type: 'cloze', skill, prompt: it.prompt, payload: { text: it.text }, correct: { value: it.value, accepted: it.accepted && it.accepted.length ? it.accepted : [it.value] } };
  if (t === 'translation') return { type: 'translation', skill, prompt: it.prompt || `Traduce: "${it.source}".`, payload: { source: it.source }, correct: { value: it.value, accepted: it.accepted && it.accepted.length ? it.accepted : [it.value] } };
  if (t === 'word_bank') { const seq = it.sequence || []; return { type: 'word_bank', skill, prompt: it.prompt, payload: { tiles: it.tiles }, correct: { value: seq.join(' '), sequence: seq } }; }
  if (t === 'reorder') return { type: 'reorder', skill, prompt: it.prompt, payload: { tiles: it.tiles }, correct: { value: it.value } };
  if (t === 'listening') return { type: 'listening', skill, prompt: it.prompt || 'Escucha y elige lo que oíste.', payload: { options: it.options, say: it.value }, correct: { value: it.value } };
  if (t === 'speaking_read_aloud') return { type: 'speaking_read_aloud', skill, prompt: it.prompt || 'Lee en voz alta:', payload: { text: it.text }, correct: { expected: it.text } };
  return { type: t, skill, prompt: it.prompt, payload: {}, correct: {}, _bad: true };
}

const issues = [];
function validateItem(U, L, I, it) {
  const at = `U${U} L${L} item${I} (${it.type}/${it.skill})`;
  const p = it.payload || {}, c = it.correct || {};
  if (it._bad) { issues.push(`${at}: tipo desconocido`); return; }
  if (!it.prompt) issues.push(`${at}: falta prompt`);
  if (it.type === 'multiple_choice' || it.type === 'true_false') {
    if (!Array.isArray(p.options) || p.options.length < 2) issues.push(`${at}: faltan options`);
    else if (!p.options.some((o) => norm(o) === norm(c.value))) issues.push(`${at}: correct.value "${c.value}" no está en options ${JSON.stringify(p.options)}`);
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
    else if (!c.sequence.every((t) => p.tiles.includes(t))) issues.push(`${at}: sequence tiene fichas que no están en tiles`);
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

function skillCounts(items) { const c = { reading: 0, writing: 0, listening: 0, speaking: 0 }; items.forEach((it) => { c[it.skill] = (c[it.skill] || 0) + 1; }); return c; }

let sql = `-- ============================================================================
-- Jezici · Migración 048 · Siembra del currículo A1 de PORTUGUÉS (es→pt, U1–6)
-- ----------------------------------------------------------------------------
-- Curso es→pt (português do Brasil). Autorado + QA adversarial (workflow
-- pt-a1-author-content) + validado contra el grader. cefr 'A1', order 1..6.
-- Namespace de ids separado (32/42/52/d1) para no colisionar con es→en.
-- Listening A1 por COMPRENSIÓN (frases cortas). content_items idempotente.
-- ============================================================================
begin;
`;

for (const u of units) {
  const U = u.U;
  u.lessons.forEach((les, li) => les.items.forEach((rawIt, ii) => { const it = normalizeItem(rawIt); les.items[ii] = it; validateItem(U, li + 1, ii + 1, it); }));
  const tot = { reading: 0, writing: 0, listening: 0, speaking: 0 };
  u.lessons.forEach((les) => { const c = skillCounts(les.items); ['reading', 'writing', 'listening', 'speaking'].forEach((s) => tot[s] += c[s]); });
  if (tot.reading < 3 || tot.writing < 3 || tot.listening < 2 || tot.speaking < 2) issues.push(`U${U}: distribución insuficiente ${JSON.stringify(tot)}`);
  if (u.lessons.length < 4) issues.push(`U${U}: se esperan >=4 lecciones, hay ${u.lessons.length}`);
  u.lessons.forEach((les, li) => { if (les.items.length < 8) issues.push(`U${U} L${li + 1}: se esperan >=8 ítems, hay ${les.items.length}`); });

  const utitle = (u.title || '').trim();
  sql += `\n-- ── Unidad ${U} (A1·pt): ${utitle} ───────────────────────────────────────\n`;
  sql += `insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values\n`;
  sql += ` ('${unitId(U)}','${COURSE}','A1',${U},${dq(utitle, 'p')},'${(u.theme_color || '#27AE60').replace(/'/g, '')}','${slug(u.icon)}')\non conflict (course_id, order_index) do update set title=excluded.title, theme_color=excluded.theme_color, icon=excluded.icon;\n`;

  sql += `insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values\n`;
  const lessonRows = u.lessons.map((les, li) => ` ('${lessonId(U, li + 1)}','${unitId(U)}',${li + 1},${dq(les.title, 'p')},${dq(les.description || les.title, 'p')},'lesson',15)`);
  lessonRows.push(` ('${lessonId(U, u.lessons.length + 1)}','${unitId(U)}',${u.lessons.length + 1},${dq('🏁 Checkpoint Unidade ' + U, 'p')},${dq(u.checkpoint_description || 'Cronometrado · 4 habilidades · 80%.', 'p')},'checkpoint',40)`);
  sql += lessonRows.join(',\n') + `\non conflict (unit_id, order_index) do update set title=excluded.title, description=excluded.description;\n`;

  sql += `insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values\n`;
  sql += ` ('${examId(U)}','${COURSE}','checkpoint','A1','${unitId(U)}',300,0.80,${jq({ skills: ['reading', 'listening', 'writing', 'speaking'], item_count: 10, randomize: true })})\non conflict (id) do nothing;\n`;

  const rows = [];
  const refs = [];
  u.lessons.forEach((les, li) => {
    const L = li + 1, topic = slug(les.topic || les.title);
    les.items.forEach((it) => {
      const id = nextItemId(); it._id = id; refs.push({ id, skill: it.skill, L });
      const payload = { ...it.payload };
      if (it.type === 'listening' || it.type === 'speaking_read_aloud') payload.audio_url = AUDIO_BASE + id + '.mp3';
      const diff = Math.min(0.35, Math.max(0.05, Number(it.difficulty) || 0.18));
      rows.push(` ('${id}','${COURSE}','A1','${it.skill}','${it.type}',\n   ${dq(it.prompt, 'p')},\n   ${jq(payload)}, ${jq(it.correct)},\n   ${diff.toFixed(2)}, ARRAY['unidad${U}','${topic}','${it.skill}'])`);
    });
  });
  sql += `insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values\n`;
  sql += rows.join(',\n') + `\non conflict (id) do update set prompt=excluded.prompt, payload=excluded.payload, correct_answer=excluded.correct_answer, difficulty=excluded.difficulty, tags=excluded.tags, updated_at=now();\n`;

  const li_rows = [];
  u.lessons.forEach((les, li) => { const L = li + 1; les.items.forEach((it, ii) => li_rows.push(` ('${lessonId(U, L)}','${it._id}',${ii + 1})`)); });
  const pick = (skill, n) => refs.filter((r) => r.skill === skill).slice(0, n);
  const ck = [...pick('reading', 3), ...pick('writing', 3), ...pick('listening', 2), ...pick('speaking', 2)];
  ck.forEach((r, k) => li_rows.push(` ('${lessonId(U, u.lessons.length + 1)}','${r.id}',${k + 1})`));
  sql += `insert into lesson_items (lesson_id, item_id, order_index) values\n` + li_rows.join(',\n') + `\non conflict (lesson_id, item_id) do nothing;\n`;

  if (u.vocab && u.vocab.length) {
    const vr = u.vocab.slice(0, 16).map((v, k) => ` ('${nextVocabId()}','${COURSE}',${dq(v.word, 'p')},${dq(v.translation, 'p')},${100 + U * 20 + k},'${slug(v.pos || 'word')}')`);
    sql += `insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values\n` + vr.join(',\n') + `\non conflict (id) do nothing;\n`;
  }
}

sql += `\ncommit;\n`;

if (issues.length) { console.log(`=== ${issues.length} PROBLEMAS DE VALIDACIÓN ===`); issues.forEach((i) => console.log(' - ' + i)); console.log('NO se escribió la migración.'); process.exit(2); }
fs.writeFileSync(OUT, sql);
const totalItems = units.reduce((a, u) => a + u.lessons.reduce((b, l) => b + l.items.length, 0), 0);
console.log(`OK ✓ migración escrita: ${OUT}`);
console.log(`unidades: ${units.map((u) => u.U).join(', ')} · content_items: ${totalItems} · bytes: ${sql.length}`);
