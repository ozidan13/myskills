# CodeHub Compact Viewport Laws (L1–L12)

Distilled from CodeHub's production compact learning studio and `TaskViewer.tsx` iframe constraints. Compact means **zero document scroll, calm editorial hierarchy, full-screen fluid proportions, and instant switching** — NEVER cramped tiny boxes, pure `#FFFFFF` glare, or skinny centered strips surrounded by dead space.

---

## The 12 Laws

| ID | Law | Exact Implementation Rule | Failure Symptom |
| :- | :--- | :--- | :--- |
| **L1** | **Document never scrolls; bounded panes do.** | Lock root shell: `html, body { height: 100%; overflow: hidden; }` and root grid `height: 100dvh; grid-template-rows: auto minmax(0, 1fr);`. | Page-level scrollbar, scroll progress bars. |
| **L2** | **`min-height: 0` & `min-width: 0` on every grid/flex child (with mobile stack override).** | Apply `min-height: 0; min-width: 0;` to nested wrappers inside a `100dvh` grid so inner panes scroll cleanly; on single-column mobile (`< 960px`), set `flex-shrink: 0; min-height: auto;` on stacked prose/lab panes so they never clip, and use `minmax(0, 1fr)` on grids holding `<pre>` blocks. | Bottom dock pushed off-screen, clipped mobile sections, or `<pre>` causing horizontal overflow. |
| **L3** | **Full-bleed 2-pane Studio with collapsible sidebar.** | Large desktop (`≥ 1120px`): persistent collapsible Right Chapter Sidebar (`308px`, zero decorative stars, 3-state status) + full Left Workspace (`minmax(0, 1fr)`). Inside workspace, balance a comfortable `62ch` editorial reading column + unified `.coding-lab` (`1fr 1.05fr`) and focused playfields (`max-width: 1040px`). | Tiny centered box wasting 50% of desktop, OR stretched 1800px unreadable lines. |
| **L4** | **Open navigation, mount active pane only.** | Keep every section 100% unlocked and 1 click away (collapsible desktop rail → accessible RTL slide-over drawer `< 1120px` with backdrop & `Esc` dismiss). Render only the active view so hidden controls never trap Tab focus. | Forced linear locks; stacked walls of all sections. |
| **L5** | **Harmonized workspace tabs & consolidated header.** | Pair **Explain (`افهم الشرح`)** and **Practice/Game (`العب وطبّق`)** inside one clean Lesson Header with restrained Petrol underline sub-topic/challenge tabs — avoid stacking competing horizontal bars or repeating headings. | Teaching docs hidden in modals, or cluttered multi-bar chrome. |
| **L6** | **One primary action per dock.** | Exactly one high-contrast Petrol Teal CTA (`#0E7C90`, hover `#0A6576`, warm ivory text `#F9F8F4`, weight 700) in the bottom dock. Secondary actions stay quiet warm-ivory bordered buttons. | Competing bright buttons or loud neon gradients causing visual noise. |
| **L7** | **Contained internal scroll with editorial typography.** | Never crush fonts below `14px–15.5px` (`13px–13.5px` monospace) to avoid internal scroll. Use `overflow: auto; overscroll-behavior: contain; scrollbar-gutter: stable; scrollbar-width: thin;` on scrolling columns while keeping root document at `0` scroll. | Microscopic 11px text or scroll-chaining moving the outer page. |
| **L8** | **Responsive tiers: Desktop → Medium Drawer → Mobile.** | `≥ 1120px`: persistent collapsible 308px sidebar; `768–1119px`: full-width workspace + slide-over RTL drawer; `< 960px`: vertical single-column stack (Editorial Content → Unified Coding Lab); `< 768px`: compact `46px` header, `≥ 44px` tap targets, and `env(safe-area-inset-bottom)`. | Squished sidebars, clipped prose, or unreachable CTAs on 390px phones. |
| **L9** | **One overlay at a time.** | Maintain a single modal overlay slot (`Esc` closes, restores focus). Feedback lives in the non-blocking dock toast and docked code-inspector bar. | Stacked popup collisions. |
| **L10** | **Tactile, restrained, reducible motion.** | Purposeful micro-interactions (≤ 220 ms hover/selection transitions, subtle state shifts), zero infinite bouncing/glowing animations, all disabled under `prefers-reduced-motion`. No AOS/GSAP/Three.js. | Heavy libraries or distracting AI-template animations. |
| **L11** | **Egyptian microcopy, BiDi-safe English technical terms.** | Natural Egyptian Arabic UI and teaching voice; inline technical terms stay English wrapped in `<bdi>` (`الـ attribute`, `الـ browser`); code lines use single-pass syntax tokenizers and isolate Arabic text segments in `<bdi class="syn-ar">`. | Stiff formal Arabic, flipped punctuation in code, or broken syntax spans. |
| **L12** | **CodeHub Editorial Warm Pearl Light visual system.** | Never use pure `#FFFFFF` as the dominant background. Layer warm linen `#F2F0EA` (main bg), warm pearl `#EAE7DF` (chrome/sidebar/bars), warm ivory `#F9F8F4` (cards/surfaces), soft code well `#F0EEE8`, paper preview `#FDFCF9`, crisp 1px borders `#DBD7CC` / `#C4BEB0`, dark charcoal ink `#182230` / `#2B3748`, `IBM Plex Sans Arabic` + `JetBrains Mono`, and restrained semantic accents (`#0E7C90` petrol, `#B3700B` amber, `#167E5C` emerald, `#C03943` crimson). | Pure-white eye strain, generic purple-blue AI cards, glassmorphism blur, or dark-theme leakage. |

---

## Editorial Warm Pearl Light Design Tokens

```css
:root {
  --bg: #F2F0EA;           /* Main warm linen canvas (never pure #FFFFFF) */
  --bg-2: #EAE7DF;         /* Secondary pearl chrome: topbar, sidebar, docks */
  --surface: #F9F8F4;      /* Primary warm ivory cards & reading panels */
  --surface-hi: #EDEAE2;   /* Warm alabaster hover / elevated active states */
  --code-bg: #F0EEE8;      /* Light editorial code well (#1F2937 ink) */
  --preview-bg: #FDFCF9;   /* Soft paper canvas for rendered previews */
  --border: #DBD7CC;       /* Consistent 1px warm stone border */
  --border-hi: #C4BEB0;    /* Stronger border for controls & inputs */
  --text: #182230;         /* Primary headings & high-emphasis ink */
  --text-body: #2B3748;    /* Comfortable reading body ink */
  --text-soft: #4E5D73;    /* Secondary labels */
  --muted: #69768C;        /* Quiet metadata */
  --accent: #0E7C90;       /* Petrol Teal — interactive primary */
  --amber: #B3700B;        /* Burnished Amber — XP, progress, active inspect */
  --ok: #167E5C;           /* Forest Emerald — completion & success */
  --bad: #C03943;          /* Muted Crimson — errors only */
}
```

---

## CodeHub TaskViewer Iframe Math

Lessons render inside `src/components/student-dashboard/TaskViewer.tsx`:
- Top bar: `56px` (`h-14`).
- Bottom submission panel: **`panelOpen = true` by default** (`44vh`), collapsing to `52px`.
- Sandbox: `sandbox="allow-scripts allow-same-origin allow-forms allow-popups allow-popups-to-escape-sandbox"` + `allow="fullscreen"`.

### Mandatory QA Fit Viewports (8 Viewports)
- **Desktop & Laptop**: `1440×900`, `1366×660`
- **TaskViewer Default Panel-Open**: `1366×374`, `1280×347`
- **Medium Drawer & Tablet**: `1024×768`, `768×916`
- **Phone**: `390×736`, `390×417`

Every viewport MUST pass **`documentElement.scrollHeight <= innerHeight`** (`docY == 0`) AND **`documentElement.scrollWidth <= innerWidth`** (`docX == 0`) with readable typography and zero console/page errors.

---

## Mode B Checklist: Compacting & Restyling Any Existing Web UI / Component

1. Apply the Editorial Warm Pearl Light token palette (`#F2F0EA` / `#EAE7DF` / `#F9F8F4` / `#F0EEE8` / `#DBD7CC` / `#182230`) consistently across every page, header, card, form input, code sample, and dialog — zero dark leftovers and zero pure `#FFFFFF` dominant backgrounds (L12).
2. For app-shell studios, lock root shell to `100dvh; overflow: hidden;` with `min-height: 0; min-width: 0;` on nested grid/flex containers, and add `flex-shrink: 0; min-height: auto;` on mobile stacked panes (L1–L2).
3. For documentation/brief pages containing `<pre>` code blocks inside CSS Grid layouts, always set `grid-template-columns: minmax(0, 1fr)` and `min-width: 0; max-width: 100%;` on grid items so code scrolls cleanly inside its box without causing horizontal page overflow (L2).
4. Replace vertical section stacks in studios with a collapsible Right Chapter Sidebar (`308px`) + Left Workspace (`minmax(0, 1fr)`), switching to an accessible RTL slide-over drawer below `1120px` (L3, L4, L8).
5. Group sub-views under restrained underline tabs (L5), keep one clear primary CTA per dock (L6), and verify `0` horizontal overflow and visual polish across desktop (`1440×900`), tablet (`1024×768`), and phone (`390×736`).
