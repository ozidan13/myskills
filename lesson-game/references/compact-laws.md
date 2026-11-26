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
| **L6** | **One primary action per dock.** | Exactly one high-contrast Mediterranean Teal CTA (`#15808D`, hover `#0F6873`, warm cream text `#F8F2E4`, weight 600–700) in the bottom dock. Secondary actions stay quiet warm-cream bordered buttons. | Competing bright buttons or loud neon gradients causing visual noise. |
| **L7** | **Contained internal scroll with editorial typography.** | Never crush fonts below `14px–15.5px` (`13px–13.5px` monospace) to avoid internal scroll. Use `overflow: auto; overscroll-behavior: contain; scrollbar-gutter: stable; scrollbar-width: thin;` on scrolling columns while keeping root document at `0` scroll. | Microscopic 11px text or scroll-chaining moving the outer page. |
| **L8** | **Responsive tiers: Desktop → Medium Drawer → Mobile.** | `≥ 1120px`: persistent collapsible 308px sidebar; `768–1119px`: full-width workspace + slide-over RTL drawer; `< 960px`: vertical single-column stack (Editorial Content → Unified Coding Lab); `< 768px`: compact `46px` header, `≥ 44px` tap targets, and `env(safe-area-inset-bottom)`. | Squished sidebars, clipped prose, or unreachable CTAs on 390px phones. |
| **L9** | **One overlay at a time.** | Maintain a single modal overlay slot (`Esc` closes, restores focus). Feedback lives in the non-blocking dock toast and docked code-inspector bar. | Stacked popup collisions. |
| **L10** | **Tactile, restrained, reducible motion.** | Purposeful micro-interactions (≤ 220 ms hover/selection transitions, subtle state shifts), zero infinite bouncing/glowing animations, all disabled under `prefers-reduced-motion`. No AOS/GSAP/Three.js. | Heavy libraries or distracting AI-template animations. |
| **L11** | **Egyptian microcopy, BiDi-safe English technical terms.** | Natural Egyptian Arabic UI and teaching voice; inline technical terms stay English wrapped in `<bdi>` (`الـ attribute`, `الـ browser`); code lines use single-pass syntax tokenizers and isolate Arabic text segments in `<bdi class="syn-ar">`. | Stiff formal Arabic, flipped punctuation in code, or broken syntax spans. |
| **L12** | **CodeHub Warm Café Latte & Cheerful Daylight visual system.** | Never use pure `#FFFFFF` or blinding white backgrounds. Layer warm café latte `#E7DEC8` (main canvas), toasted biscotti `#DDD2B8` (chrome/sidebar/bars), warm cream `#F1E9D7` (cards/reading surfaces), cappuccino code well `#E3D8C2`, soft vanilla preview/inputs `#F5EFE0`, crisp 1px roast borders `#CCBEA2` / `#B6A484`, warm espresso ink `#2A211B` / `#3E3229`, `IBM Plex Sans Arabic` + `JetBrains Mono`, and cheerful eye-resting accents (`#15808D` Mediterranean teal, `#C47112` warm honey-caramel, `#1F855E` botanical sage emerald, `#C84B45` terracotta coral). | White-screen eye fatigue, generic purple-blue AI cards, glassmorphism blur, or dark-theme leakage. |

---

## Warm Café Latte & Cheerful Daylight Design Tokens

```css
:root {
  --bg: #E7DEC8;           /* Main warm café latte canvas (zero white glare) */
  --bg-2: #DDD2B8;         /* Toasted biscotti chrome: topbar, sidebar, docks */
  --surface: #F1E9D7;      /* Warm steamed-cream cards & reading panels */
  --surface-hi: #E4D8BE;   /* Warm almond hover / elevated active states */
  --code-bg: #E3D8C2;      /* Shaded cappuccino code well (#2A211B ink) */
  --preview-bg: #F5EFE0;   /* Soft vanilla cream for browser preview & inputs */
  --border: #CCBEA2;       /* Consistent 1px warm roast border */
  --border-hi: #B6A484;    /* Stronger café border for controls & inputs */
  --text: #2A211B;         /* Warm espresso headings & high-emphasis ink */
  --text-body: #3E3229;    /* Rich mocha reading ink */
  --text-soft: #5F5043;    /* Warm cocoa secondary labels */
  --muted: #746353;        /* Soft latte metadata */
  --accent: #15808D;       /* Mediterranean Teal — cheerful interactive primary */
  --amber: #C47112;        /* Warm Honey-Caramel — XP, progress, active inspect */
  --ok: #1F855E;           /* Botanical Sage Emerald — completion & success */
  --bad: #C84B45;          /* Warm Terracotta Coral — errors only */
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

1. Apply the Warm Café Latte & Cheerful Daylight token palette (`#E7DEC8` / `#DDD2B8` / `#F1E9D7` / `#E3D8C2` / `#F5EFE0` / `#CCBEA2` / `#2A211B`) consistently across every page, header, card, form input, code sample, and dialog — zero dark leftovers and zero glaring white backgrounds (L12).
2. For app-shell studios, lock root shell to `100dvh; overflow: hidden;` with `min-height: 0; min-width: 0;` on nested grid/flex containers, and add `flex-shrink: 0; min-height: auto;` on mobile stacked panes (L1–L2).
3. For documentation/brief pages containing `<pre>` code blocks inside CSS Grid layouts, always set `grid-template-columns: minmax(0, 1fr)` and `min-width: 0; max-width: 100%;` on grid items so code scrolls cleanly inside its box without causing horizontal page overflow (L2).
4. Replace vertical section stacks in studios with a collapsible Right Chapter Sidebar (`308px`) + Left Workspace (`minmax(0, 1fr)`), switching to an accessible RTL slide-over drawer below `1120px` (L3, L4, L8).
5. Group sub-views under restrained underline tabs (L5), keep one clear primary CTA per dock (L6), and verify `0` horizontal overflow and visual polish across desktop (`1440×900`), tablet (`1024×768`), and phone (`390×736`).
