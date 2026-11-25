#!/usr/bin/env node
/**
 * lesson-tool.mjs — Zero-dependency pack & lint CLI for CodeHub /lesson-game
 * Usage:
 *   node lesson-tool.mjs pack <lesson.json> <out.html> [--shell <shell.html>]
 *   node lesson-tool.mjs lint <file.html|file.json>
 */
import fs from 'node:fs';
import path from 'node:path';
import zlib from 'node:zlib';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const DEFAULT_SHELL = path.resolve(__dirname, '..', 'assets', 'lesson-shell.html');

const VALID_TYPES = new Set(['explore', 'choice', 'slot', 'buckets', 'order', 'bughunt', 'match', 'patch']);
const ALLOWED_HOSTS = new Set(['fonts.googleapis.com', 'fonts.gstatic.com']);
const BANNED_MSA = ['قم ب', 'يُرجى', 'يرجى ', 'حاول مرة أخرى', 'إجابة خاطئة'];

function escapeHtmlAttr(s) {
  return String(s).replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
}

function lintLessonData(data) {
  const errors = [];
  const warnings = [];
  if (!data || typeof data !== 'object') {
    return { errors: ['LESSON must be a JSON object'], warnings, stats: {} };
  }
  if (!data.id || typeof data.id !== 'string') errors.push('Missing string LESSON.id');
  if (!data.title || typeof data.title !== 'string') errors.push('Missing string LESSON.title');
  if (!Array.isArray(data.levels) || data.levels.length === 0) errors.push('LESSON.levels must be a non-empty array');
  if (!Array.isArray(data.summary) || data.summary.length === 0) warnings.push('LESSON.summary is empty (recommended for CodeHub TaskViewer submission bridge)');

  const levelIds = new Set();
  const stageIds = new Set();
  const usedTypes = new Set();
  const typeCounts = {};
  let totalStages = 0;

  for (const [li, L] of (data.levels || []).entries()) {
    const lp = `levels[${li}] (${L?.id || '?'})`;
    if (!L.id) errors.push(`${lp}: missing id`);
    else if (levelIds.has(L.id)) errors.push(`${lp}: duplicate level id`);
    else levelIds.add(L.id);

    if (!L.title) errors.push(`${lp}: missing title`);
    if (!Array.isArray(L.stages) || L.stages.length === 0) {
      errors.push(`${lp}: must contain at least 1 stage`);
      continue;
    }
    if (!L.boss && (!Array.isArray(L.docs) || L.docs.length === 0)) {
      errors.push(`${lp}: non-boss section must include teaching docs[] (Explain + Game harmony)`);
    }
    for (const [di, doc] of (L.docs || []).entries()) {
      const dp = `${lp}.docs[${di}]`;
      if (!doc.tab || !doc.heading) errors.push(`${dp}: doc requires tab and heading`);
      if (!Array.isArray(doc.body) || doc.body.length === 0) warnings.push(`${dp}: doc has empty body[]`);
      if (doc.code && Array.isArray(doc.spots) && doc.spots.length) {
        for (let i = 0; i < doc.spots.length; i++) {
          if (!new RegExp(`\\[\\[${i}\\|[^\\]]+\\]\\]`).test(doc.code)) {
            errors.push(`${dp}: doc code missing spot marker [[${i}|...]]`);
          }
        }
      }
      if (doc.code && String(doc.code).split('\n').length > 22) {
        warnings.push(`${dp}: doc code has > 22 lines — consider splitting into two sub-topic tabs`);
      }
    }

    const levelTypes = new Set();
    let prevType = null;

    for (const [si, st] of L.stages.entries()) {
      totalStages++;
      const sp = `${lp}.stages[${si}] (${st?.id || '?'})`;
      if (!st.id) errors.push(`${sp}: missing id`);
      else if (stageIds.has(st.id)) errors.push(`${sp}: duplicate stage id "${st.id}"`);
      else stageIds.add(st.id);

      if (!VALID_TYPES.has(st.type)) {
        errors.push(`${sp}: invalid type "${st.type}"`);
        continue;
      }
      usedTypes.add(st.type);
      levelTypes.add(st.type);
      typeCounts[st.type] = (typeCounts[st.type] || 0) + 1;

      if (!L.boss && prevType === st.type) {
        errors.push(`${sp}: consecutive identical mechanic "${st.type}" (mix mechanics inside a level)`);
      }
      prevType = st.type;

      // Copy budgets & Egyptian voice check
      if (!st.prompt || typeof st.prompt !== 'string') errors.push(`${sp}: missing prompt`);
      else if (st.prompt.length > 240) errors.push(`${sp}: prompt too long (${st.prompt.length} > 240 chars)`);

      if (st.coach && st.coach.length > 240) errors.push(`${sp}: coach bubble too long (${st.coach.length} > 240 chars)`);

      if (st.code) {
        const lines = String(st.code).split('\n').length;
        if (lines > 14) errors.push(`${sp}: code block has ${lines} lines (max 14 — split stage)`);
      }

      const copyFields = [st.prompt, st.coach, st.hint, st.why].filter(Boolean).join(' ');
      for (const bad of BANNED_MSA) {
        if (copyFields.includes(bad)) warnings.push(`${sp}: formal MSA phrase "${bad}" detected — rewrite in Egyptian Arabic`);
      }

      // Per-mechanic contracts
      if (st.type === 'explore') {
        if (!st.code || !Array.isArray(st.spots) || st.spots.length === 0) {
          errors.push(`${sp}: explore requires code and non-empty spots[]`);
        } else {
          for (let i = 0; i < st.spots.length; i++) {
            if (!new RegExp(`\\[\\[${i}\\|[^\\]]+\\]\\]`).test(st.code)) {
              errors.push(`${sp}: explore code missing marker [[${i}|...]]`);
            }
            if (!st.spots[i]?.title || !st.spots[i]?.say) errors.push(`${sp}: spots[${i}] needs title & say`);
          }
        }
      } else if (st.type === 'choice') {
        if (!Array.isArray(st.options) || st.options.length < 2) errors.push(`${sp}: choice needs >= 2 options`);
        if (typeof st.answer !== 'number' || st.answer < 0 || st.answer >= (st.options?.length || 0)) {
          errors.push(`${sp}: invalid choice answer index`);
        }
        (st.options || []).forEach((o, oi) => {
          if (!o.t && !o.preview) errors.push(`${sp}: options[${oi}] needs t or preview`);
          if (!o.why) errors.push(`${sp}: options[${oi}] missing diagnostic "why" feedback`);
        });
      } else if (st.type === 'slot') {
        if (!st.code || !Array.isArray(st.tokens) || !Array.isArray(st.answer) || st.answer.length === 0) {
          errors.push(`${sp}: slot requires code, tokens[], answer[]`);
        } else {
          for (let i = 0; i < st.answer.length; i++) {
            if (!st.code.includes(`[[${i}]]`)) errors.push(`${sp}: slot code missing placeholder [[${i}]]`);
            if (!st.tokens.includes(st.answer[i])) errors.push(`${sp}: answer[${i}] ("${st.answer[i]}") not found in tokens[]`);
          }
          if (st.tokens.length <= st.answer.length) warnings.push(`${sp}: add at least 1 distractor token to slot.tokens[]`);
        }
      } else if (st.type === 'buckets') {
        if (!Array.isArray(st.buckets) || st.buckets.length < 2) errors.push(`${sp}: buckets needs >= 2 buckets`);
        if (!Array.isArray(st.items) || st.items.length < 2) errors.push(`${sp}: buckets needs >= 2 items`);
        const bIds = new Set((st.buckets || []).map(b => b.id));
        (st.items || []).forEach((it, ii) => {
          if (!bIds.has(it.b)) errors.push(`${sp}: items[${ii}].b ("${it.b}") not in buckets`);
          if (!it.why) errors.push(`${sp}: items[${ii}] missing "why" feedback`);
        });
        if ((st.items?.length || 0) > 8) errors.push(`${sp}: buckets has ${st.items.length} items (max 8 — split stage)`);
      } else if (st.type === 'order') {
        if (!Array.isArray(st.items) || st.items.length < 3 || st.items.length > 6) {
          errors.push(`${sp}: order needs 3–6 items`);
        }
        if ((st.items || []).some(x => /^[١٢٣٤٥٦1-6][.)\s]/.test(String(x).trim()))) {
          warnings.push(`${sp}: order item starts with a number — remove numbers so the answer isn't leaked`);
        }
      } else if (st.type === 'bughunt') {
        if (!st.code || !Array.isArray(st.bugs) || st.bugs.length === 0) {
          errors.push(`${sp}: bughunt needs code and non-empty bugs[]`);
        } else {
          for (let i = 0; i < st.bugs.length; i++) {
            if (!new RegExp(`\\[\\[${i}\\|[^\\]]+\\]\\]`).test(st.code)) {
              errors.push(`${sp}: bughunt code missing bug marker [[${i}|...]]`);
            }
            if (!st.bugs[i]?.why) errors.push(`${sp}: bugs[${i}] missing "why"`);
          }
          if (!/\[\[ok\|[^\]]+\]\]/.test(st.code)) warnings.push(`${sp}: add [[ok|...]] valid distractor tokens so students scan real code`);
        }
      } else if (st.type === 'match') {
        if (!Array.isArray(st.pairs) || st.pairs.length < 2 || st.pairs.length > 5) {
          errors.push(`${sp}: match needs 2–5 pairs`);
        }
      } else if (st.type === 'patch') {
        if (typeof st.start !== 'string') errors.push(`${sp}: patch needs start code string`);
        if (!Array.isArray(st.checks) || st.checks.length === 0) errors.push(`${sp}: patch needs non-empty checks[]`);
        (st.checks || []).forEach((c, ci) => {
          if (!c.fail) errors.push(`${sp}: checks[${ci}] missing fail message`);
          if (!c.selector && !c.notSelector && !c.regex && !c.notRegex) {
            errors.push(`${sp}: checks[${ci}] needs selector/notSelector/regex/notRegex`);
          }
        });
        if (!st.solution) warnings.push(`${sp}: patch missing solution (needed for 3-miss reveal)`);
        if (!Array.isArray(st.chips) || st.chips.length === 0) warnings.push(`${sp}: patch missing mobile quick-insert chips[]`);
      }
    }

    if (!L.boss && L.stages.length >= 2 && levelTypes.size < 2) {
      errors.push(`${lp}: non-boss level must use >= 2 distinct mechanics`);
    }
  }

  if ((data.levels?.length || 0) >= 4 && usedTypes.size < 6) {
    errors.push(`Multi-level lesson uses only ${usedTypes.size} mechanic types (minimum 6 required)`);
  }

  return {
    errors,
    warnings,
    stats: {
      levels: data.levels?.length || 0,
      stages: totalStages,
      recall: data.recall?.length || 0,
      uniqueTypes: usedTypes.size,
      typeCounts
    }
  };
}

function lintHtmlFile(filePath) {
  const html = fs.readFileSync(filePath, 'utf8');
  const bytes = Buffer.byteLength(html, 'utf8');
  const errors = [];
  const warnings = [];

  if (bytes > 260 * 1024) errors.push(`File size ${(bytes / 1024).toFixed(1)} KB exceeds 260 KB budget`);

  const htmlTag = html.match(/<html\b[^>]*>/i)?.[0] || '';
  if (!/lang=["']ar["']/i.test(htmlTag) || !/dir=["']rtl["']/i.test(htmlTag)) {
    errors.push('Root <html> must include lang="ar" and dir="rtl"');
  }

  const dataMatch = html.match(/<script\s+id=["']lesson-data["']\s+type=["']application\/json["']\s*>([\s\S]*?)<\/script>/i);
  if (!dataMatch) {
    errors.push('Missing <script id="lesson-data" type="application/json"> payload');
  }

  const shellOnly = dataMatch ? html.replace(dataMatch[0], '') : html;
  const shellBytes = Buffer.byteLength(shellOnly, 'utf8');
  const shellGzip = zlib.gzipSync(shellOnly).length;
  if (shellGzip > 30 * 1024) warnings.push(`Engine shell gzip size ${(shellGzip / 1024).toFixed(1)} KB exceeds 30 KB target`);

  const forbiddenGlobal = [
    [/cdn\.tailwindcss\.com/i, 'Tailwind Play CDN forbidden'],
    [/unpkg\.com\/aos/i, 'AOS animation library forbidden'],
    [/font-awesome|fontawesome/i, 'Font Awesome CDN forbidden'],
    [/\bdata-aos=/i, 'Scroll-triggered data-aos forbidden']
  ];
  for (const [re, msg] of forbiddenGlobal) {
    if (re.test(html)) errors.push(msg);
  }

  const forbiddenShell = [
    [/\balert\s*\(/, 'alert() blocked by TaskViewer iframe sandbox'],
    [/\bconfirm\s*\(/, 'confirm() blocked by TaskViewer iframe sandbox'],
    [/\bprompt\s*\(/, 'prompt() blocked by TaskViewer iframe sandbox'],
    [/navigator\.clipboard/, 'navigator.clipboard blocked by iframe sandbox'],
    [/window\.top\b|parent\.location\b/, 'Cross-frame top/parent access forbidden'],
    [/addEventListener\s*\(\s*['"]scroll['"]|\bonscroll\s*=/i, 'Window scroll listeners forbidden (Law L1)']
  ];
  for (const [re, msg] of forbiddenShell) {
    if (re.test(shellOnly)) errors.push(msg);
  }

  // Allowlisted external hosts in shell (outside JSON data)
  for (const m of shellOnly.matchAll(/\b(?:src|href)=["'](https?:\/\/[^"']+)["']/gi)) {
    try {
      const host = new URL(m[1]).hostname;
      if (!ALLOWED_HOSTS.has(host)) errors.push(`External URL host not allowlisted: ${host} (${m[1]})`);
    } catch {
      errors.push(`Malformed URL: ${m[1]}`);
    }
  }

  let stats = { bytes, shellBytes };
  if (dataMatch) {
    try {
      const data = JSON.parse(dataMatch[1]);
      const res = lintLessonData(data);
      errors.push(...res.errors);
      warnings.push(...res.warnings);
      stats = { ...stats, ...res.stats };
    } catch (e) {
      errors.push(`Invalid JSON in #lesson-data: ${e.message}`);
    }
  }
  return { errors, warnings, stats };
}

function packLesson(jsonPath, outPath, shellPath) {
  const raw = fs.readFileSync(jsonPath, 'utf8');
  let data;
  try {
    data = JSON.parse(raw);
  } catch (e) {
    console.error(`❌ Invalid JSON in ${jsonPath}: ${e.message}`);
    process.exit(1);
  }
  const check = lintLessonData(data);
  if (check.errors.length) {
    printReport(jsonPath, check);
    process.exit(1);
  }

  let shell = fs.readFileSync(shellPath, 'utf8');
  const safeJson = JSON.stringify(data, null, 2).replace(/<\//g, '<\\/');
  shell = shell.replace(/<title>[\s\S]*?<\/title>/i, `<title>${escapeHtmlAttr(data.title)} — CodeHub Game</title>`);
  if (data.subtitle) {
    shell = shell.replace(
      /<meta\s+name="description"\s+content="[^"]*">/i,
      `<meta name="description" content="${escapeHtmlAttr(data.subtitle)}">`
    );
  }
  const dataRe = /<script\s+id=["']lesson-data["']\s+type=["']application\/json["']\s*>[\s\S]*?<\/script>/i;
  if (!dataRe.test(shell)) {
    console.error('❌ Shell template missing <script id="lesson-data" type="application/json">');
    process.exit(1);
  }
  shell = shell.replace(dataRe, `<script id="lesson-data" type="application/json">\n${safeJson}\n</script>`);

  fs.mkdirSync(path.dirname(path.resolve(outPath)), { recursive: true });
  fs.writeFileSync(outPath, shell, 'utf8');

  const outRes = lintHtmlFile(outPath);
  printReport(outPath, outRes);
  if (outRes.errors.length) process.exit(1);
}

function printReport(target, { errors, warnings, stats }) {
  console.log(`\n=== Lesson Tool Report: ${path.basename(target)} ===`);
  if (stats.bytes) console.log(`Size: ${(stats.bytes / 1024).toFixed(1)} KB (engine shell: ${(stats.shellBytes / 1024).toFixed(1)} KB)`);
  if (stats.levels !== undefined) {
    console.log(`Levels: ${stats.levels} | Stages: ${stats.stages} | Recall: ${stats.recall} | Mechanics: ${stats.uniqueTypes} (${JSON.stringify(stats.typeCounts)})`);
  }
  if (warnings.length) {
    console.log(`\nWarnings (${warnings.length}):`);
    warnings.forEach(w => console.log(`  ⚠ ${w}`));
  }
  if (errors.length) {
    console.log(`\nErrors (${errors.length}):`);
    errors.forEach(e => console.log(`  ❌ ${e}`));
  } else {
    console.log('\n✅ PASS — 0 errors');
  }
}

const [, , cmd, arg1, arg2, ...rest] = process.argv;
if (cmd === 'lint' && arg1) {
  const res = arg1.endsWith('.json')
    ? lintLessonData(JSON.parse(fs.readFileSync(arg1, 'utf8')))
    : lintHtmlFile(arg1);
  printReport(arg1, res);
  process.exit(res.errors.length ? 1 : 0);
} else if (cmd === 'pack' && arg1 && arg2) {
  const sIdx = rest.indexOf('--shell');
  const shellPath = sIdx !== -1 && rest[sIdx + 1] ? rest[sIdx + 1] : DEFAULT_SHELL;
  packLesson(arg1, arg2, shellPath);
} else {
  console.log('Usage:\n  node lesson-tool.mjs pack <lesson.json> <out.html> [--shell <shell.html>]\n  node lesson-tool.mjs lint <file.html|file.json>');
  process.exit(1);
}
