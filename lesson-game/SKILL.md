---
name: lesson-game
description: >-
  Turn any lesson or lecture into a compact, zero-scroll, single-file Egyptian-Arabic learning studio with CodeHub's Editorial Warm Pearl Light Theme (collapsible RTL sidebar + drawer, unified coding lab with live preview, and 8 tactile game mechanics) — or refactor any web UI using CodeHub's 12 Compact Viewport Laws.
---

# Lesson Game Studio & CodeHub Compact UI/UX

Turn long, scroll-heavy lessons into a **CodeHub Editorial Learning Studio** in Egyptian Arabic where **structured editorial teaching docs** and **tactile interactive games** harmonize side-by-side (`يتناغمو سوا`) with **open section navigation**, **zero page scroll**, and an **eye-friendly Editorial Warm Pearl Light Theme** — or refactor any web interface using CodeHub's 12 Compact Viewport Laws.

## Choose Mode First

1. **Mode A — Lesson → Interactive Studio Game (Default)**: Input is a lesson/lecture HTML file, Markdown doc, or topic outline. Author a pure JSON payload (`docs[]` + `stages[]`) and pack it deterministically into `assets/lesson-shell.html` via `scripts/lesson-tool.mjs`.
2. **Mode B — Compact UI/UX Refactor**: Input is an existing app page, portal, project stylesheet, or component (HTML/CSS/Tailwind/React/Next.js). Read [`references/compact-laws.md`](references/compact-laws.md) and apply Laws L1–L12 directly (and [`references/egyptian-voice.md`](references/egyptian-voice.md) for Arabic microcopy).

Stop reading Mode A steps if running Mode B.

---

## Mode A Architecture & Visual Principles (Non-Negotiable)

- **Editorial Warm Pearl Light Aesthetic (Never Pure `#FFFFFF` Dominant Background)**:
  - Layered warm surfaces: main canvas `#F2F0EA`, chrome/bars/sidebar `#EAE7DF`, reading cards `#F9F8F4`, elevated hover `#EDEAE2`, light editorial code well `#F0EEE8`, soft paper preview `#FDFCF9`, and crisp 1px borders `#DBD7CC` / `#C4BEB0`.
  - High-contrast dark ink (`#182230` headings, `#2B3748` body, `#4E5D73` / `#69768C` muted) paired with restrained semantic accents: **Petrol Teal** (`#0E7C90`) for primary interactions, **Burnished Amber** (`#B3700B`) for XP/rewards/active code inspection, **Forest Emerald** (`#167E5C`) for completion/success, and **Muted Crimson** (`#C03943`) strictly for errors.
  - Zero glassmorphism, zero neon borders/glows, zero heavy drop shadows, zero decorative rating stars, and zero purple-and-blue AI clichés.
  - Typography: `IBM Plex Sans Arabic` for Arabic UI/editorial prose + `JetBrains Mono` for code, counters, and badges.
- **Open Navigation — Zero Locks**:
  - **Compact `50px` Global Header**: Course identity, clean linear `التقدّم` progress meter, Amber XP pill, Review (`مراجعة`), and Submission Summary (`ملخص التسليم`).
  - **Collapsible `308px` Right Chapter Sidebar (`≥ 1120px`)**: Clear 3-state indicators (completed emerald check, active subtle ivory surface + petrol rail bar, upcoming muted), persisted collapse toggle (`lg2:ui:railCollapsed`), and **no decorative stars**. Below `1120px`, seamlessly becomes an accessible RTL slide-over drawer (`Esc` & backdrop dismiss + focus restoration).
  - Learners jump freely to ANY section, sub-topic, challenge, boss test, or recall deck in 1 tap.
- **Explanation + Unified Coding Lab + Game Harmonized (`يتناغمو سوا`)**: Never strip teaching content to fake a quiz. Every non-boss section MUST include BOTH:
  - **`افهم الشرح` (`docs[]`)**: Consolidated Lesson Header + Petrol underline sub-topic tabs over a two-column workspace:
    - *Right (`62ch` unboxed editorial column)*: Readable Arabic paragraphs, LTR-isolated `<bdi>` inline technical terms, subtle contextual insight callouts, concept cards, and comparison tables.
    - *Left (Unified `.coding-lab`)*: Single cohesive developer lab combining filename tab, line-numbered BiDi-safe single-pass HTML/CSS/JS/SQL syntax highlighter, subtle clickable `[[0|...]]` token underlines, docked Amber explanation inspector, and realistic light browser preview or Console Output pane.
  - **`العب وطبّق` (`stages[]`)**: Tactile game challenges (drag-and-drop, 2D wireframe building, bug sniping, concept matching, ordering, split Mini-IDE live patching, browser-render prediction) with underline challenge tabs and a 1-tap `راجع الشرح` button in the bottom dock.
- **Course-Wide Consistency**: When a course includes a portal (`index.html`), project briefs, or practical project simulations alongside studio lectures, apply the same warm pearl surface/border/ink hierarchy across every page (allowing restrained per-project semantic accents) and protect `<pre>` code blocks inside responsive grids with `grid-template-columns: minmax(0, 1fr)` and `min-width: 0`.

---

## Mode A Workflow (6 Steps)

Never rewrite the engine HTML by hand. Author clean JSON, pack, lint, and visually inspect.

### Step 1 — Complete Content Inventory
Read the entire source lesson. Extract every section, sub-topic, analogy, warning, tip, table, code snippet, live browser/console preview, and quiz question.
- **Done when**: Every distinct concept and quiz item is accounted for.

### Step 2 — Author Harmonized Sections (`docs[]` + `stages[]`)
Read [`references/mechanics.md`](references/mechanics.md) and [`references/content-mapping.md`](references/content-mapping.md).
For every teaching section:
1. Build **`docs[]`** (1–3 crisp sub-topic tabs): preserve every explanation, Egyptian analogy (`callout`), tip, warning, comparison `table`, concept `cards[]`, interactive `code` + `spots[]`, and `preview` (HTML mockup or console output) so the student genuinely learns in depth right inside the studio.
2. Build **`stages[]`** (2–4 hands-on challenges directly testing the `docs[]` you just taught): mix mechanics (**≥ 2 distinct types per section**, **≥ 6 types per full lesson**, **zero consecutive identical mechanics** inside non-boss sections).
3. Add a final **Boss** section (`boss: true`, 3 hearts) from the source quiz questions + **`recall[]`** flashcards + **`summary[]`** bullets pointing to CodeHub's TaskViewer submission panel.

### Step 3 — Polish Pure Egyptian Arabic Voice («كابتن كود»)
Read [`references/egyptian-voice.md`](references/egyptian-voice.md).
- Natural Egyptian Arabic for all explanations, prompts, hints, and feedback; English technical nouns stay English with «الـ» (`الـ attribute`, `الـ browser`).
- Every wrong choice/item/check diagnoses the *exact* misconception — never bare «غلط».
- Zero formal MSA boilerplate (`قم بـ`, `يُرجى`, `حاول مرة أخرى`).

### Step 4 — Pack & Lint Deterministically
```bash
node scripts/lesson-tool.mjs pack <path/to/name.lesson.json> <path/to/name.game.html>
```
Validates `docs[]` + `stages[]`, budgets, forbidden APIs, and injects JSON safely into `assets/lesson-shell.html`.
- Standalone check: `node scripts/lesson-tool.mjs lint <file>`.
- **Done when**: Exit code `0`, `0` errors.

### Step 5 — Real Viewport & Visual QA
Open `<name>.game.html?qa=1` (or run Playwright calling `window.__LG_QA()`) across all **8 mandatory viewports**:
- Desktop & Laptop: `1440×900`, `1366×660`
- TaskViewer Default Panel-Open: `1366×374`, `1280×347`
- Medium Drawer & Tablet: `1024×768`, `768×916`
- Phone: `390×736`, `390×417`

Verify:
- `0` document scroll (`docY == 0`), `0` horizontal overflow (`docX == 0`), `0` console/page errors across every view × viewport.
- Functional smoke checks: desktop sidebar collapse/expand, `< 1120px` RTL drawer open + `Esc` close, code-token docked inspector click, and clean syntax highlighting (verify zero raw `class="syn-` span leaks in JS/CSS/HTML code blocks).
- Visually inspect rendered screenshots of both `افهم الشرح` and `العب وطبّق` (desktop, collapsed rail, TaskViewer, tablet drawer, and mobile) to confirm readability, contrast, BiDi alignment, and zero clipping.

### Step 6 — Handoff
Deliver `<name>.game.html` + `<name>.lesson.json` (never overwrite archived original reading drafts; publish by replacement at the existing URL so CodeHub `Task.link` stays intact).

---

## Hard Rules (Enforced by `lesson-tool.mjs` & Studio Engine)

1. **Single self-contained HTML**: Inline `<style>`, inline `<script>`, and `<script id="lesson-data" type="application/json">`. External hosts limited strictly to `fonts.googleapis.com` and `fonts.gstatic.com`.
2. **Budgets**: Packed lesson ≤ 260 KB raw (engine ≤ 30 KB gzip, currently ~27.1 KB); stage prompt ≤ 240 chars; stage code ≤ 14 lines; doc code ≤ 22 lines.
3. **Sandbox-safe**: Inline overlays and dock toasts only — never `alert()`, `confirm()`, `prompt()`, `navigator.clipboard`, `window.top`, `parent.location`, Tailwind CDN, AOS, Font Awesome CDN, or `window` scroll listeners.
4. **RTL + BiDi-safe Single-Pass Highlighting**: `<html lang="ar" dir="rtl">`; all code surfaces `dir="ltr"` with `unicode-bidi: isolate`, Arabic text inside code wrapped in `<bdi class="syn-ar">`, and single-pass regex tokenizers for HTML/CSS/JS so keywords never corrupt emitted `<span class="...">` markup.
5. **Universal input**: Pointer Events drag-and-drop (`touch-action: none`, pointer capture only after > 7 px move so nested buttons stay clickable) + tap-to-pick/tap-to-place + input-safe keyboard shortcuts (`Enter`, `H`, `1–4`, `Esc`).
6. **Zero dead ends**: Miss 1 shows `why`; miss 2 auto-opens hint; miss 3 reveals answer + explanation and unlocks Next. Boss 0 hearts restarts with free hints. Progress persists under `lg2:<lesson.id>:v1` (keep UI state like rail collapse in a separate key).
7. **Accessibility & Mobile Stability**: Tap targets ≥ 40–44 px, visible petrol focus ring, `aria-live="polite"` feedback, glyph + text (never color-only), `prefers-reduced-motion` respected, and stacked mobile flex panes set `flex-shrink: 0; min-height: auto;` so content never clips.

---

## Bundled References & Assets

- [`references/compact-laws.md`](references/compact-laws.md) — CodeHub's 12 Compact Viewport Laws (L1–L12), Editorial Warm Pearl Light design tokens, TaskViewer iframe math, and Mode B refactor checklist.
- [`references/mechanics.md`](references/mechanics.md) — Exact JSON schemas for `docs[]` teaching tabs + unified Coding Lab + all 8 game mechanics.
- [`references/content-mapping.md`](references/content-mapping.md) — Source-to-docs + mechanic mapping matrix and multi-subject guide.
- [`references/egyptian-voice.md`](references/egyptian-voice.md) — «كابتن كود» persona, phrase bank, and MSA→Egyptian rewrites.
- [`assets/lesson-shell.html`](assets/lesson-shell.html) — Pre-built zero-dependency Editorial Warm Pearl Light 2-pane Interactive Studio engine (`~27.1 KB` gzipped).
- [`scripts/lesson-tool.mjs`](scripts/lesson-tool.mjs) — Deterministic `pack` and `lint` CLI.
- [`examples/lect02.game.html`](examples/lect02.game.html) & [`examples/lect02.lesson.json`](examples/lect02.lesson.json) — Reference pilot studio lesson packed with the latest light studio shell.
