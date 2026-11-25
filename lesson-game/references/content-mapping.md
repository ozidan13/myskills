# Harmonized Content Mapping (Teaching Docs + Game)

Every source lesson element maps into **BOTH** the section's structured teaching view (`docs[]`) **AND** its hands-on game arena (`stages[]`) so explanation and practice reinforce each other (`يتناغمو سوا`).

---

## 1. Dual Mapping Matrix (Docs + Game)

| Source Lesson Element | Goes Into `docs[]` («📖 افهم الشرح») | Goes Into `stages[]` («🎮 العب وطبّق») |
| :--- | :--- | :--- |
| Concept explanation paragraphs | Crisp `body[]` paragraphs (2–3 sentences per sub-topic tab) | Tested via `choice`, `match`, or `buckets` |
| Analogy box (`.egyptian-expl`) | Highlighted amber `callout` (`kind: "analogy"`) verbatim-first | Reinforced in `coach` bubble or `buckets`/`match` |
| Code block (`.code-block`) | Interactive macOS code window (`code` + clickable `spots[]`) | Hands-on `slot` (code forge) or `patch` (Mini-IDE) |
| Browser preview (`.browser-preview`) | Live white `preview` browser frame right beside the code | Turned into a `choice` **predict** challenge (1 right render + 1–2 wrong renders) |
| Warning / Common Mistakes | Rose `warning` callout or 4-card Mistakes grid (`cards[]`) | `bughunt` (snipe the exact bug beside `[[ok\|...]]` valid lines) |
| Pro tip (`.tip-expl`) | Emerald `tip` callout | Hands-on `patch` task applying the tip (e.g. `rel="noopener"`, `loading="lazy"`) |
| Comparison table (`.custom-table`) | Clean `table` (`headers` + `rows`) in the left visual lab pane | `match` (3–4 pairs) or `buckets` (sort 6 items) |
| Do ✅ / Don't ❌ list | Structured `cards[]` or callout | `buckets` (`أعمل ده ✅` vs `متعملش كده ❌`) |
| Pipeline / hierarchy / steps | Numbered `cards[]` | `order` (drag / `▲▼` into exact sequence) |
| Page layout / schema diagram | Interactive semantic code + spots | `buckets` (`layout: "wireframe"`) 2D blueprint builder |
| End-of-lecture quiz (`quizData`) | — | Final **Boss** section (`boss: true`, 3 hearts) + **Recall Deck** (`recall[]`) |

---

## 2. Section Structure & Diversity Rules

1. **Open navigation**: Never lock sections. Students jump freely between sections using the persistent Right Rail (desktop) or horizontal top tab strip (mobile/tablet).
2. **Sub-topic tabs (`docs[]`)**: Split any section with > 1 major concept into 2–3 focused sub-topic tabs so every tab stays scannable, well-proportioned, and readable without endless scrolling.
3. **Challenge pacing (`stages[]`)**: 2–4 challenges per teaching section, directly reinforcing that section's `docs[]`.
   - Zero identical consecutive mechanic types inside non-boss sections.
   - ≥ 2 distinct mechanic types per teaching section.
   - ≥ 6 distinct mechanic types across a multi-section lesson.
4. **Summary bridge**: Populate `LESSON.summary[]` with 3–5 concrete bullets for CodeHub's TaskViewer submission box below the iframe.

---

## 3. Multi-Domain Portability (Beyond HTML)

| Platform / Subject | `docs[]` Visual Lab | `stages[]` Best Mechanics |
| :--- | :--- | :--- |
| **CSS** | Interactive rule code + live rendered box `preview` | `choice` w/ `preview` (predict Flexbox/Grid), `patch` (fix layout live), `slot`, `buckets` |
| **JavaScript** | X-ray code `spots[]` + step `cards[]` | `choice` (predict output), `order` (Event Loop order), `bughunt` (bugs/async), `slot` |
| **Databases / SQL** | Syntax-highlighted query + sample result `table` | `order` (SQL execution order), `buckets` (DDL/DML/DQL), `slot` (`JOIN ON`), `bughunt` |
| **Algorithms & DS** | Complexity `table` + trace `cards[]` | `match` (algo ↔ Big-O), `order` (trace steps), `buckets` (Stack vs Queue), `bughunt` |
| **OOP & SOLID** | Principle `cards[]` + Egyptian `callout` analogies | `match` (principle ↔ analogy), `bughunt` (spot violation), `buckets`, `choice` |
| **Networking** | Protocol/port `table` + handshake `cards[]` | `order` (TCP 3-way handshake / DNS), `match` (port ↔ protocol), `buckets` (TCP vs UDP) |
