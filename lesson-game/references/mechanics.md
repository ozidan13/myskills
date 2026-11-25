# Teaching Docs + Game Mechanics JSON Contract

The studio engine (`assets/lesson-shell.html`) reads one JSON payload from `<script id="lesson-data" type="application/json">`. Every non-boss section harmonizes **rich teaching docs (`docs[]`)** with **hands-on game challenges (`stages[]`)**.

---

## Top-Level `LESSON` Schema

```json
{
  "id": "basics-lect02",
  "title": "HTML من الألف للياء",
  "subtitle": "المحاضرة التانية — شرح تفاعلي + لعبة تطبيق بالعامية المصرية",
  "accent": "#0E7C90",
  "lang": "html",
  "readUrl": "draft/lect02.html",
  "summary": ["نقطة ١ للملخص", "نقطة ٢ للملخص"],
  "levels": [ /* Section[] — ALL unlocked in the persistent right rail */ ],
  "recall": [ { "q": "سؤال مراجعة؟", "a": "الإجابة الواضحة." } ]
}
```

### Section (`levels[i]`) Schema

```json
{
  "id": "lvl-3",
  "num": 3,
  "title": "العناصر والتاجات",
  "en": "Elements, Block vs Inline & Void Tags",
  "boss": false,
  "docs": [ /* DocTab[] — required on every non-boss section */ ],
  "stages": [ /* Stage[] — interactive challenges for this exact section */ ]
}
```
- Set `"boss": true` on the final exam section (enables 3-heart mode; `docs[]` optional).

---

## Part 1: Teaching Docs (`docs[]` — «افهم الشرح»)

Each item in `docs[]` renders as an underline sub-topic tab inside a balanced **2-column Editorial Studio grid**:
- **Right (`62ch` Editorial Reading Column)**: Unboxed Egyptian-Arabic explanation paragraphs (with LTR-isolated `<bdi>` technical terms), subtle left-bordered contextual callouts (`analogy` amber, `tip` emerald, `warn` crimson), concept `cards[]`, and comparison `table`.
- **Left (Unified `.coding-lab`)**: Filename tab + line-numbered BiDi-safe single-pass syntax highlighter (`html` | `css` | `js` | `sql` | `plain`) + subtle clickable `[[0|...]]` token underlines + docked Amber explanation inspector (`#docSpotBox`) + realistic light browser preview (`preview` + `previewUrl`) or Console Output pane (`console`).

```json
{
  "tab": "يعني إيه Element؟",
  "heading": "تشريح الـ HTML Element",
  "body": [
    "فقرة شرح واضحة بالعامية المصرية (يمكن استخدام <strong> و <code> و <bdi>)."
  ],
  "callout": {
    "kind": "analogy",
    "title": "فكّر فيها زي الساندويتش 🥪",
    "text": "العيشة الفوقانية opening tag، الحشو content، والتحتانية closing tag."
  },
  "tip": "نصيحة إضافية اختيارية (بطاقة خضراء).",
  "warning": "تحذير شائع اختياري (بطاقة حمراء).",
  "cards": [
    { "title": "Block", "code": "div, p, h1", "desc": "بياخد السطر كله." }
  ],
  "table": {
    "headers": ["Element", "الوظيفة", "مثال"],
    "rows": [["<code>&lt;img&gt;</code>", "صورة", "<code>&lt;img src=\"a.jpg\" alt=\"وصف\"&gt;</code>"]]
  },
  "filename": "element.html",
  "code": "[[0|<p]] [[1|class=\"intro\"]]>Hello World</p>",
  "spots": [
    { "title": "Opening Tag", "say": "بيفتح العنصر ويحدد نوعه." },
    { "title": "Attribute", "say": "معلومة إضافية جوا تاج الفتح." }
  ],
  "preview": "<p style='margin:0'>Hello World</p>",
  "previewUrl": "file:///element.html"
}
```
- `callout.kind`: `"analogy"` (burnished amber), `"tip"` (forest emerald), or `"warn"` (muted crimson).
- `code` + `spots[]`: uses unified `[[0|snippet]]` X-ray markers rendered with subtle underlines (never heavy dashed boxes); clicking any highlighted token switches it to active Amber and explains it in the docked inspector directly beneath the code.
- `preview`: renders inside the unified Coding Lab's light browser preview frame (`#FDFCF9`) with a clean address bar (`previewUrl`) and live status indicator — or use `console` for JavaScript output lines.

---

## Part 2: The 8 Game Mechanics (`stages[]` — «🎮 العب وطبّق»)

Common `Stage` fields: `id` (unique), `type`, `prompt` (≤ 240 chars), optional `coach` (≤ 240 chars), `hint`, optional `lang` (`html` | `css` | `js` | `sql` | `plain`).

Unified `[[...]]` code markers:
- `explore`: `[[0|snippet]]` → clickable hotspot #0.
- `slot`: `[[0]]` → drag/tap drop blank #0.
- `bughunt`: `[[0|buggy]]` → bug #0; `[[ok|valid]]` → clickable valid distractor.

### 1. `explore` — Code X-Ray
`{ "type": "explore", "code": "[[0|...]]", "spots": [{ "title": "...", "say": "..." }] }` — tapping all glowing spots unlocks Next (+5 XP).

### 2. `choice` — Decision & Live Browser Predict
`{ "type": "choice", "code"?: "...", "options": [{ "t": "...", "preview"?: "<div>...</div>", "why": "..." }], "answer": 0 }` — supports text cards OR live rendered mini-browser `preview` cards so learners predict output before reveal.

### 3. `slot` — Drag-and-Drop / Tap Code Forge
`{ "type": "slot", "code": "[[0]] [[1]]=\"x\">Hi[[2]]", "tokens": ["<p","class","</p>","<div>"], "answer": ["<p","class","</p>"], "why": "..." }` — include 1–2 plausible distractor tokens.

### 4. `buckets` — Sorter (`columns`) & 2D Wireframe Builder (`wireframe`)
- **Columns**: `{ "type": "buckets", "layout": "columns", "buckets": [{ "id": "a", "label": "..." }], "items": [{ "t": "...", "b": "a", "why": "..." }] }` (max 6–8 items).
- **Wireframe**: set `"layout": "wireframe"` and `"area"` on each bucket:
  - Page blueprint: `"header" | "nav" | "main" | "aside" | "footer"`
  - Table blueprint: `"caption" | "thead" | "tbody" | "tfoot"`

### 5. `order` — Sequence Arranger
`{ "type": "order", "items": ["step 1", "step 2", "step 3", "step 4"], "why": "..." }` — supply 3–6 items in **correct order** without leading numbers; engine shuffles automatically and provides drag + `▲`/`▼` buttons.

### 6. `bughunt` — Bug Sniper
`{ "type": "bughunt", "code": "[[ok|valid]]\n[[0|buggy]]", "bugs": [{ "why": "..." }] }` — tapping all bugs solves; tapping `[[ok|...]]` gives reassuring Egyptian feedback.

### 7. `match` — Concept Linker
`{ "type": "match", "pairs": [["term", "meaning"], ...] }` — 2–5 pairs; right column auto-shuffles.

### 8. `patch` — Live Mini-IDE
`{ "type": "patch", "start": "<a href=\"#\">x</a>", "chips": ["target=\"_blank\"", "rel=\"noopener\""], "checks": [{ "selector": "a[target='_blank']", "fail": "..." }], "solution": "..." }` — supports `selector`, `notSelector`, `regex`, `notRegex`, tappable mobile `chips[]`, Reset button, and live debounced sandboxed `srcdoc` preview.
