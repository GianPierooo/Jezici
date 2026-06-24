// Genera la migración SQL del seed de HISTORIAS / INMERSIÓN (es→en) desde
// stories_en.json. Valida las preguntas de comprensión contra el grader determinista
// y emite filas `stories` idempotentes (on conflict do update). Las preguntas se
// guardan EMBEBIDAS en stories.questions (con correct_answer) — esa columna está
// REVOCADA al cliente (mig 065), la calificación es server-side (submit_story).
// El audio por segmento (TTS) se sube aparte a audio/stories/<storyId>-<idx>.mp3.
import fs from 'node:fs';

const IN = process.argv[2] || 'C:/Users/gianp/Desktop/Jezici/tools/content/stories_en.json';
const OUT = process.argv[3] || 'C:/Users/gianp/Desktop/Jezici/supabase/migrations/20260623270066_seed_stories.sql';
const COURSE = '20000000-0000-0000-0000-000000000001';
const AUDIO_BASE = 'https://wiauinufpbkmjlbqlkxo.supabase.co/storage/v1/object/public/audio/stories/';
const LEVEL_CODE = { A1: 1, A2: 2, B1: 3, B2: 4, C1: 5, C2: 6 };

const raw = JSON.parse(fs.readFileSync(IN, 'utf8'));
const stories = (raw.data || raw).slice();

const pad = (n, l) => String(n).padStart(l, '0');
const storyId = (lvl, order) => `55000000-0000-0000-0000-${pad(LEVEL_CODE[lvl] * 100 + order, 12)}`;
const norm = (t) => (t || '').toLowerCase().replace(/[.!?¿¡,;:']/g, '').replace(/\s+/g, ' ').trim();
const dq = (s, tag) => { if (('' + s).includes(`$${tag}$`)) throw new Error(`delimitador $${tag}$ en: ${s}`); return `$${tag}$${s}$${tag}$`; };
const jq = (o) => dq(JSON.stringify(o), 'j') + '::jsonb';

const issues = [];
function normalizeQuestion(at, it) {
  const t = it.type, skill = it.skill || 'reading';
  if (t === 'multiple_choice') {
    if (!Array.isArray(it.options) || it.options.length < 2) issues.push(`${at}: faltan options`);
    else if (!it.options.some((o) => norm(o) === norm(it.value))) issues.push(`${at}: value "${it.value}" no está en options`);
    else if (it.options.filter((o) => norm(o) === norm(it.value)).length > 1) issues.push(`${at}: value normaliza igual que un distractor ${JSON.stringify(it.options)}`);
    return { type: t, skill, prompt: it.prompt, payload: { options: it.options }, correct_answer: { value: it.value }, difficulty: it.difficulty };
  }
  if (t === 'cloze') {
    if (!it.text || !it.text.includes('_')) issues.push(`${at}: cloze sin hueco (___)`);
    const acc = it.accepted && it.accepted.length ? it.accepted : [it.value];
    if (!it.value) issues.push(`${at}: falta value`);
    return { type: t, skill, prompt: it.prompt, payload: { text: it.text }, correct_answer: { value: it.value, accepted: acc }, difficulty: it.difficulty };
  }
  issues.push(`${at}: tipo no soportado para historias (${t})`);
  return { type: t, skill, prompt: it.prompt, payload: {}, correct_answer: {}, _bad: true };
}

let sql = `-- ============================================================================
-- Jezici · Migración 066 · Seed de HISTORIAS / INMERSIÓN (es→en, A1 + A2) — generado
-- ----------------------------------------------------------------------------
-- Narrativas/diálogos cortos curados (calibrados al CEFR, relevancia LATAM) con
-- audio por segmento (Storage) y preguntas de comprensión auto-calificables. Las
-- preguntas embeben correct_answer (columna stories.questions REVOCADA al cliente,
-- mig 065). Idempotente (on conflict do update). Audio TTS aparte (gen_story_audio.py).
-- ============================================================================
begin;
`;

const rows = [];
let totalQ = 0, totalSeg = 0;
for (const s of stories) {
  const id = storyId(s.level, s.order);
  const segs = (s.segments || []).map((seg, i) => ({ en: seg.en, es: seg.es, audio_url: `${AUDIO_BASE}${id}-${i}.mp3` }));
  totalSeg += segs.length;
  const qs = (s.questions || []).map((q, i) => normalizeQuestion(`${s.level}#${s.order} q${i + 1}`, q));
  totalQ += qs.length;
  if (qs.length < 4) issues.push(`${s.level}#${s.order}: <4 preguntas`);
  if (qs.filter((q) => q.type === 'multiple_choice').length < 3) issues.push(`${s.level}#${s.order}: <3 multiple_choice`);
  if (qs.filter((q) => q.type === 'cloze').length < 1) issues.push(`${s.level}#${s.order}: <1 cloze`);
  rows.push(` ('${id}','${COURSE}','${s.level}',${s.order},${dq(s.title, 'p')},${dq(s.subtitle || '', 'p')},${dq(s.emoji || '📖', 'p')},${dq(s.intro || '', 'p')},${Number(s.est_seconds) || 60},\n   ${jq(segs)}, ${jq(s.glossary || [])}, ${jq(qs)})`);
}

sql += `insert into stories (id, course_id, cefr_level, order_index, title, subtitle, emoji, intro, est_seconds, segments, glossary, questions) values\n`;
sql += rows.join(',\n') + `\non conflict (course_id, cefr_level, order_index) do update set\n`;
sql += `  title=excluded.title, subtitle=excluded.subtitle, emoji=excluded.emoji, intro=excluded.intro,\n`;
sql += `  est_seconds=excluded.est_seconds, segments=excluded.segments, glossary=excluded.glossary, questions=excluded.questions;\n`;
sql += `\ncommit;\n`;

if (issues.length) { console.log(`=== ${issues.length} PROBLEMAS ===`); issues.forEach((i) => console.log(' - ' + i)); console.log('NO se escribió la migración.'); process.exit(2); }
fs.writeFileSync(OUT, sql);
console.log(`OK ✓ ${OUT}`);
console.log(`historias: ${stories.length} · segmentos: ${totalSeg} · preguntas: ${totalQ}`);
