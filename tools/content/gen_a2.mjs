// Genera la migración SQL del currículo A2 (Unidades 7–12) a partir de
// ./a2_units.mjs, validando compatibilidad con el grader determinista
// (jz_grade) ANTES de emitir nada. Mismo formato que las Unidades A1.
//
// Diferencias con gen_units.mjs (A1):
//  · cefr_level = 'A2', order_index = U (7..12).
//  · UUIDs con prefijos propios y contadores globales (seguros para U de 2
//    dígitos; el esquema "cULI" de A1 desbordaba 8 hex con U≥10).
//  · audio_url de listening/speaking se inyecta automáticamente al MP3 público
//    determinista (igual que la migración 027), y se conserva payload.say con
//    el texto a sintetizar por TTS (post-seed).
//  · dificultad A2 en [0.20, 0.55].
import fs from 'node:fs';
import { UNITS } from './a2_units.mjs';

const OUT = process.argv[2] ||
  'C:/Users/gianp/Desktop/Jezici/supabase/migrations/20260616120030_seed_a2.sql';
const COURSE = '20000000-0000-0000-0000-000000000001';
const AUDIO_BASE =
  'https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/items/';

const units = [...UNITS].sort((a, b) => a.U - b.U);

const pad = (n, l) => String(n).padStart(l, '0');
const unitId = (U) => `30000000-0000-0000-0000-${pad(U, 12)}`;
const examId = (U) => `50000000-0000-0000-0000-${pad(U, 12)}`;
const lessonId = (U, L) => `40000000-0000-0000-0000-${pad(U * 100 + L, 12)}`;
// Contadores globales deterministas (orden fijo de recorrido → UUIDs estables).
let _iseq = 0;
let _vseq = 0;
const nextItemId = () => { _iseq += 1; return `c2${pad(_iseq, 6)}-0000-0000-0000-${pad(_iseq, 12)}`; };
const nextVocabId = () => { _vseq += 1; return `a2b${pad(_vseq, 5)}-0000-0000-0000-${pad(_vseq, 12)}`; };

const slug = (s) => (s || '').toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, '')
  .replace(/[^a-z0-9]+/g, '_').replace(/^_|_$/g, '') || 'x';
const norm = (t) => (t || '').toLowerCase().replace(/[.!?¿¡,;:]/g, '').replace(/\s+/g, ' ').trim();
const dq = (s, tag) => { if (('' + s).includes(`$${tag}$`)) throw new Error(`delimitador $${tag}$ dentro del contenido: ${s}`); return `$${tag}$${s}$${tag}$`; };
const jq = (o) => dq(JSON.stringify(o), 'j') + '::jsonb';

const issues = [];
function validateItem(U, L, I, it) {
  const at = `U${U} L${L} item${I} (${it.type}/${it.skill})`;
  const p = it.payload || {}, c = it.correct || {};
  if (!it.prompt) issues.push(`${at}: falta prompt`);
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
    if (!Array.isArray(p.options) || p.options.length < 2 || !c.value) issues.push(`${at}: listening mal formado (options/value)`);
    else if (!p.options.some((o) => norm(o) === norm(c.value))) issues.push(`${at}: listening correct.value no está en options`);
    if (!p.say && !c.value) issues.push(`${at}: listening sin texto para TTS`);
  } else if (it.type === 'speaking_read_aloud') {
    if (!p.text || !c.expected) issues.push(`${at}: speaking mal formado`);
  } else issues.push(`${at}: tipo desconocido ${it.type}`);
}

function skillCounts(items) {
  const c = { reading: 0, writing: 0, listening: 0, speaking: 0 };
  items.forEach((it) => { c[it.skill] = (c[it.skill] || 0) + 1; });
  return c;
}

let sql = `-- ============================================================================
-- Jezici · Migración 030 · Siembra del currículo A2 (Unidades 7–12) — generado
-- ----------------------------------------------------------------------------
-- Mismo formato que A1. Regiones consecutivas (order_index 7..12), cefr 'A2'.
-- El gating del paso F desbloquea cada unidad al aprobar el checkpoint previo;
-- la Unidad 7 se desbloquea al aprobar el checkpoint de la Unidad 6 (A1).
-- Listening/speaking llevan audio_url determinista (Storage); el TTS se sube
-- aparte (mismo patrón que la 027). Idempotente (UUIDs fijos + ON CONFLICT).
-- ============================================================================
begin;
`;

for (const u of units) {
  const U = u.U;
  // 1) Validación (incluye inyección de audio_url para listening/speaking).
  u.lessons.forEach((les, li) => les.items.forEach((it, ii) => {
    if (it.type === 'listening' && !it.payload.say) it.payload.say = it.correct.value;
    validateItem(U, li + 1, ii + 1, it);
  }));
  const tot = { reading: 0, writing: 0, listening: 0, speaking: 0 };
  u.lessons.forEach((les) => { const c = skillCounts(les.items); ['reading', 'writing', 'listening', 'speaking'].forEach((s) => tot[s] += c[s]); });
  if (tot.reading < 3 || tot.writing < 3 || tot.listening < 2 || tot.speaking < 2) issues.push(`U${U}: distribución insuficiente para el checkpoint ${JSON.stringify(tot)}`);
  if (u.lessons.length !== 4) issues.push(`U${U}: se esperan 4 lecciones, hay ${u.lessons.length}`);
  u.lessons.forEach((les, li) => { if (les.items.length !== 8) issues.push(`U${U} L${li + 1}: se esperan 8 ítems, hay ${les.items.length}`); });

  const utitle = u.title.trim();
  sql += `\n-- ── Unidad ${U} (A2): ${utitle} ───────────────────────────────────────\n`;
  sql += `insert into units (id, course_id, cefr_level, order_index, title, theme_color, icon) values\n`;
  sql += ` ('${unitId(U)}','${COURSE}','A2',${U},${dq(utitle, 'p')},'${(u.theme_color || '#6C5CE7').replace(/'/g, '')}','${slug(u.icon)}')\non conflict (course_id, order_index) do nothing;\n`;

  sql += `insert into lessons (id, unit_id, order_index, title, description, type, xp_reward) values\n`;
  const lessonRows = u.lessons.map((les, li) => ` ('${lessonId(U, li + 1)}','${unitId(U)}',${li + 1},${dq(les.title, 'p')},${dq(les.description, 'p')},'lesson',15)`);
  lessonRows.push(` ('${lessonId(U, 5)}','${unitId(U)}',5,${dq('🏁 Checkpoint Unidad ' + U, 'p')},${dq(u.checkpoint_description || 'Cronometrado · mezcla las 4 habilidades · umbral 80%.', 'p')},'checkpoint',40)`);
  sql += lessonRows.join(',\n') + `\non conflict (unit_id, order_index) do nothing;\n`;

  sql += `insert into exams (id, course_id, type, cefr_level, unit_id, time_limit_sec, pass_threshold, sections) values\n`;
  sql += ` ('${examId(U)}','${COURSE}','checkpoint','A2','${unitId(U)}',300,0.80,${jq({ skills: ['reading', 'listening', 'writing', 'speaking'], item_count: 10, randomize: true })})\non conflict (id) do nothing;\n`;

  // content_items (asigna ids por lección/ítem en orden).
  const rows = [];
  const refs = []; // {id, skill}
  u.lessons.forEach((les, li) => {
    const L = li + 1, topic = slug(les.topic || les.title);
    les.items.forEach((it) => {
      const id = nextItemId();
      it._id = id;
      refs.push({ id, skill: it.skill, L });
      const payload = { ...it.payload };
      if (it.type === 'listening' || it.type === 'speaking_read_aloud') {
        payload.audio_url = AUDIO_BASE + id + '.mp3';
      }
      const diff = Math.min(0.55, Math.max(0.20, Number(it.difficulty) || 0.32));
      rows.push(` ('${id}','${COURSE}','A2','${it.skill}','${it.type}',\n   ${dq(it.prompt, 'p')},\n   ${jq(payload)}, ${jq(it.correct)},\n   ${diff.toFixed(2)}, ARRAY['unidad${U}','${topic}','${it.skill}'])`);
    });
  });
  sql += `insert into content_items (id, course_id, cefr_level, skill, type, prompt, payload, correct_answer, difficulty, tags) values\n`;
  sql += rows.join(',\n') + `\non conflict (id) do nothing;\n`;

  // lesson_items (8 por lección).
  const li_rows = [];
  u.lessons.forEach((les, li) => { const L = li + 1; les.items.forEach((it, ii) => li_rows.push(` ('${lessonId(U, L)}','${it._id}',${ii + 1})`)); });
  // checkpoint: 3R + 3W + 2L + 2S (del banco de la unidad).
  const pick = (skill, n) => refs.filter((r) => r.skill === skill).slice(0, n);
  const ck = [...pick('reading', 3), ...pick('writing', 3), ...pick('listening', 2), ...pick('speaking', 2)];
  ck.forEach((r, k) => li_rows.push(` ('${lessonId(U, 5)}','${r.id}',${k + 1})`));
  sql += `insert into lesson_items (lesson_id, item_id, order_index) values\n` + li_rows.join(',\n') + `\non conflict (lesson_id, item_id) do nothing;\n`;

  // vocabulary (alta frecuencia de la unidad).
  if (u.vocab && u.vocab.length) {
    const vr = u.vocab.slice(0, 16).map((v, k) => ` ('${nextVocabId()}','${COURSE}',${dq(v.word, 'p')},${dq(v.translation, 'p')},${300 + U * 20 + k},'${slug(v.pos || 'word')}')`);
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
const totalItems = units.reduce((a, u) => a + u.lessons.reduce((b, l) => b + l.items.length, 0), 0);
console.log(`OK ✓ migración escrita: ${OUT}`);
console.log(`unidades: ${units.map((u) => u.U).join(', ')} · content_items: ${totalItems} · bytes: ${sql.length}`);
