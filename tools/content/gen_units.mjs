// Genera la migración SQL de las Unidades 3–6 a partir del JSON del workflow,
// validando compatibilidad con el grader determinista antes de emitir nada.
import fs from 'node:fs';

const IN = process.argv[2] || 'C:/Users/gianp/AppData/Local/Temp/jezici_shot/units.json';
const OUT = process.argv[3] || 'C:/Users/gianp/Desktop/Jezici/supabase/migrations/20260616120021_seed_units_3_6.sql';
const COURSE = '20000000-0000-0000-0000-000000000001';

const raw = JSON.parse(fs.readFileSync(IN, 'utf8'));
const units = (raw.units || raw).sort((a, b) => a.U - b.U);

const pad = (n, l) => String(n).padStart(l, '0');
const unitId = (U) => `30000000-0000-0000-0000-${pad(U, 12)}`;
const examId = (U) => `50000000-0000-0000-0000-${pad(U, 12)}`;
const lessonId = (U, L) => `40000000-0000-0000-0000-${pad('' + U + L, 12)}`;
const itemId = (U, L, I) => `c${U}${L}00000-0000-0000-0000-${pad(I, 12)}`;
const vocabId = (U, k) => `6${U}000000-0000-0000-0000-${pad(k, 12)}`;

const slug = (s) => (s || '').toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, '').replace(/[^a-z0-9]+/g, '_').replace(/^_|_$/g, '') || 'x';
const norm = (t) => (t || '').toLowerCase().replace(/[.!?¿¡,;:]/g, '').replace(/\s+/g, ' ').trim();
const dq = (s, tag) => { if (('' + s).includes(`$${tag}$`)) throw new Error(`delimitador $${tag}$ dentro del contenido: ${s}`); return `$${tag}$${s}$${tag}$`; };
const jq = (o) => dq(JSON.stringify(o), 'j') + '::jsonb';

const issues = [];
function validateItem(U, L, I, it) {
  const at = `U${U} L${L} item${I} (${it.type}/${it.skill})`;
  const p = it.payload || {}, c = it.correct || {};
  if (it.type === 'multiple_choice' || it.type === 'true_false') {
    if (!Array.isArray(p.options) || p.options.length < 2) issues.push(`${at}: faltan options`);
    else if (!p.options.some((o) => norm(o) === norm(c.value))) issues.push(`${at}: correct.value "${c.value}" no está en options ${JSON.stringify(p.options)}`);
  } else if (it.type === 'match') {
    if (!Array.isArray(p.pairs) || !Array.isArray(c.pairs) || p.pairs.length !== c.pairs.length || p.pairs.length < 2) issues.push(`${at}: pairs mal formados`);
    else c.pairs.forEach((cp, i) => { if (!Array.isArray(cp) || cp.length !== 2) issues.push(`${at}: correct.pairs[${i}] no es [en,es]`); });
  } else if (it.type === 'cloze' || it.type === 'translation') {
    if (!c.value) issues.push(`${at}: falta correct.value`);
    if (it.type === 'cloze' && !p.text) issues.push(`${at}: falta payload.text`);
    if (it.type === 'translation' && !p.source) issues.push(`${at}: falta payload.source`);
  } else if (it.type === 'word_bank') {
    if (!Array.isArray(p.tiles) || !Array.isArray(c.sequence)) issues.push(`${at}: faltan tiles/sequence`);
    else if (!c.sequence.every((t) => p.tiles.includes(t))) issues.push(`${at}: sequence tiene fichas que no están en tiles`);
  } else if (it.type === 'reorder') {
    if (!Array.isArray(p.tiles) || !c.value) issues.push(`${at}: faltan tiles/value`);
    else { const vw = norm(c.value).split(' ').sort().join(' '); const tw = p.tiles.map(norm).sort().join(' '); if (vw !== tw) issues.push(`${at}: value no usa exactamente las tiles`); }
  } else if (it.type === 'listening') {
    if (!p.audio_url || !Array.isArray(p.options) || !c.value) issues.push(`${at}: listening mal formado`);
  } else if (it.type === 'speaking_read_aloud') {
    if (!p.text || !c.expected) issues.push(`${at}: speaking mal formado`);
  } else issues.push(`${at}: tipo desconocido`);
}

function skillCounts(items) {
  const c = { reading: 0, writing: 0, listening: 0, speaking: 0 };
  items.forEach((it) => { c[it.skill] = (c[it.skill] || 0) + 1; });
  return c;
}

let sql = `-- ============================================================================
-- Jezici · Migración 021 · Siembra Unidades 3–6 (A1) — generado del workflow
-- ----------------------------------------------------------------------------
-- Mismo formato que Unidades 1/2. Regiones consecutivas (order_index 3..6).
-- El gating del paso F desbloquea cada unidad al aprobar el checkpoint previo.
-- Idempotente (UUIDs fijos + ON CONFLICT).
-- ============================================================================
begin;
`;

for (const u of units) {
  const U = u.U, d = u.data;
  d.lessons.forEach((les, li) => les.items.forEach((it, ii) => validateItem(U, li + 1, ii + 1, it)));
  // distribución por unidad
  const tot = { reading: 0, writing: 0, listening: 0, speaking: 0 };
  d.lessons.forEach((les) => { const c = skillCounts(les.items); ['reading', 'writing', 'listening', 'speaking'].forEach((s) => tot[s] += c[s]); });
  if (tot.reading < 3 || tot.writing < 3 || tot.listening < 2 || tot.speaking < 2) issues.push(`U${U}: distribución insuficiente para el checkpoint ${JSON.stringify(tot)}`);

  const utitle = (d.title || '').replace(/^unidad\s*\d+\s*[—–-]\s*/i, '').trim() || `Unidad ${U}`;
  sql += `\n-- ── Unidad ${U}: ${utitle} ─────────────────────────────────────────────\n`;
  sql += `insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values\n`;
  sql += ` ('${unitId(U)}','${COURSE}','A1',${U},${dq(utitle, 'p')},'${(d.theme_color || '#6C5CE7').replace(/'/g, '')}','${slug(d.icon)}')\non conflict (course_id, order_index) do nothing;\n`;

  sql += `insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values\n`;
  const lessonRows = d.lessons.map((les, li) => ` ('${lessonId(U, li + 1)}','${unitId(U)}',${li + 1},${dq(les.title, 'p')},${dq(les.description, 'p')},'lesson',15)`);
  lessonRows.push(` ('${lessonId(U, 5)}','${unitId(U)}',5,${dq('🏁 Checkpoint Unidad ' + U, 'p')},${dq(d.checkpoint_description || 'Cronometrado · mezcla las 4 habilidades · umbral 80%.', 'p')},'checkpoint',40)`);
  sql += lessonRows.join(',\n') + `\non conflict (unit_id, order_index) do nothing;\n`;

  sql += `insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values\n`;
  sql += ` ('${examId(U)}','${COURSE}','checkpoint','A1','${unitId(U)}',300,0.80,${jq({ skills: ['reading', 'listening', 'writing', 'speaking'], item_count: 10, randomize: true })})\non conflict (id) do nothing;\n`;

  // content_items
  const rows = [];
  const refs = []; // {L,I,skill}
  d.lessons.forEach((les, li) => {
    const L = li + 1, topic = slug(les.topic);
    les.items.forEach((it, ii) => {
      const I = ii + 1;
      refs.push({ L, I, skill: it.skill });
      const diff = Math.min(0.30, Math.max(0.05, Number(it.difficulty) || 0.15));
      rows.push(` ('${itemId(U, L, I)}','${COURSE}','A1','${it.skill}','${it.type}',\n   ${dq(it.prompt, 'p')},\n   ${jq(it.payload)}, ${jq(it.correct)},\n   ${diff.toFixed(2)}, ARRAY['unidad${U}','${topic}','${it.skill}'])`);
    });
  });
  sql += `insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values\n`;
  sql += rows.join(',\n') + `\non conflict (id) do nothing;\n`;

  // lesson_items (8 por lección)
  const li_rows = [];
  d.lessons.forEach((les, li) => { const L = li + 1; les.items.forEach((_, ii) => li_rows.push(` ('${lessonId(U, L)}','${itemId(U, L, ii + 1)}',${ii + 1})`)); });
  // checkpoint: 3R + 3W + 2L + 2S
  const pick = (skill, n) => refs.filter((r) => r.skill === skill).slice(0, n);
  const ck = [...pick('reading', 3), ...pick('writing', 3), ...pick('listening', 2), ...pick('speaking', 2)];
  ck.forEach((r, k) => li_rows.push(` ('${lessonId(U, 5)}','${itemId(U, r.L, r.I)}',${k + 1})`));
  sql += `insert into lesson_items (lesson_id, item_id, order_index) values\n` + li_rows.join(',\n') + `\non conflict (lesson_id, item_id) do nothing;\n`;

  // vocabulary
  if (d.vocab && d.vocab.length) {
    const vr = d.vocab.slice(0, 14).map((v, k) => ` ('${vocabId(U, k + 1)}','${COURSE}',${dq(v.word, 'p')},${dq(v.translation, 'p')},${100 + U * 20 + k},'${slug(v.pos)}')`);
    sql += `insert into vocabulary (id, course_id, word, translation, frequency_rank, part_of_speech) values\n` + vr.join(',\n') + `\non conflict (id) do nothing;\n`;
  }
}

sql += `\ncommit;\n`;

if (issues.length) {
  console.log(`=== ${issues.length} PROBLEMAS DE VALIDACIÓN ===`);
  issues.forEach((i) => console.log(' - ' + i));
  console.log('NO se escribió la migración. Corrige el contenido y reintenta.');
  process.exit(2);
}
fs.writeFileSync(OUT, sql);
const totalItems = units.reduce((a, u) => a + u.data.lessons.reduce((b, l) => b + l.items.length, 0), 0);
console.log(`OK ✓ migración escrita: ${OUT}`);
console.log(`unidades: ${units.map((u) => u.U).join(', ')} · content_items: ${totalItems} · bytes: ${sql.length}`);
