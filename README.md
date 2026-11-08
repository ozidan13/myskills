# ✦ My AI Agent Skills Vault (`myskills`)

> **61 Curated AI Agent Superpowers** — Custom Core + Anthropic Official + Matt Pocock Engineering & Productivity Suites.  
> **٦١ مهارة احترافية للذكاء الاصطناعي** جاهزة للتثبيت بضغطة واحدة شاملة أوامر السلاش `/` على **Antigravity** و **OpenCode** و **Claude Code** و **Cursor** و **OpenAI Codex** و **Windsurf**.

---

## 🎨 Interactive Bilingual Masterclass (`index.html`)

Open **[`index.html`](./index.html)** in any browser (or enable GitHub Pages on this repo!) to master all **61 skills** in a unified **English + Egyptian Arabic (بالمصري)** interactive academy featuring Feynman analogies, Pain-vs-Gain comparisons, 5-stage project roadmaps, situational recipes, interactive quizzes, 3D holographic cards, and one-click `/command` copying.

---

## ⚡ Universal 1-Click Auto-Discovery Installer (`install.bat`)

`install.bat` is a **self-contained Windows `.bat` installer** that:
- **Automatically discovers** all skill folders (`SKILL.md`) inside this repository every time you run it — drop any new skill folder in the future and run `install.bat`, and it appears automatically!
- **Auto-detects installed AI apps** on your PC (`[DETECTED]`) and installs both **skill folders** and **native `/` slash commands** (including generating BOM-free `~/.config/opencode/commands/<name>.md` wrappers and triggering live `opencode reload` so all 61 `/slash` commands appear immediately in OpenCode!).

### Interactive Mode (Double-Click or Terminal)
Double-click **`install.bat`** in File Explorer (just press `Enter` to install to all global AI apps at once!), or run:
```bat
git clone https://github.com/ozidan13/myskills.git
cd myskills
.\install.bat
```

### Supported Targets in `install.bat`
1. **`AllGlobal` [Default]** — Installs to **ALL Global AI Apps** simultaneously!
2. **`Antigravity` (`Global`)** — `%USERPROFILE%\.gemini\config\skills`
3. **`OpenCode`** — `%USERPROFILE%\.config\opencode\skills` **+** `%USERPROFILE%\.config\opencode\commands\*.md` (with automatic `opencode reload`)
4. **`ClaudeCode`** — `%USERPROFILE%\.claude\skills`
5. **`Cursor`** — `%USERPROFILE%\.cursor\skills`
6. **`Codex`** — `%USERPROFILE%\.codex\skills`
7. **`Windsurf`** — `%USERPROFILE%\.codeium\windsurf\skills` **+** `%USERPROFILE%\.agents\skills`
8. **`OpenCodeWorkspace`** — `<project>\.opencode\skills` **+** `<project>\.opencode\commands\*.md`
9. **`AllWorkspace` (`Workspace`)** — `<project>\.agents`, `.opencode` (+ `commands`), `.claude`, `.cursor`, `.codex`
10. **`Custom`** — Any custom destination folder path

### Direct CLI Shortcuts (Non-Interactive)
```bat
:: Install all skills + /slash commands to ALL global AI apps at once
.\install.bat AllGlobal

:: Install to OpenCode Global (skills + /slash commands + live server reload)
.\install.bat OpenCode

:: Install to Antigravity Global
.\install.bat Antigravity

:: Install to Cursor, Codex, Claude Code, or Windsurf
.\install.bat Cursor
.\install.bat Codex
.\install.bat ClaudeCode
.\install.bat Windsurf

:: Install to a Project Workspace for OpenCode or All Apps
.\install.bat OpenCodeWorkspace "C:\path\to\your\project"
.\install.bat AllWorkspace "C:\path\to\your\project"
```

### macOS / Linux / WSL (`install.sh`)
```bash
chmod +x install.sh
./install.sh
```

---

## 📦 What's Inside (61 Skills)

### 1. Custom Core Suite (3 Skills)
- `initialize-project-task` — Evidence-based phased task planning under `docs/` before modifying code.
- `install-skill` — Instant multi-app skill installer from any GitHub URL, tree link, ZIP, or local path (`/install-skill <url>`).
- `security-audit` — Six-phase Cloudflare defensive vulnerability discovery & adversarial verification harness.

### 2. Anthropic Official Suite (19 Skills)
`academy-guide`, `algorithmic-art`, `brand-guidelines`, `canvas-design`, `claude-api`, `discernment-nudge`, `doc-coauthoring`, `docx`, `frontend-design`, `internal-comms`, `mcp-builder`, `pdf`, `pptx`, `skill-creator`, `slack-gif-creator`, `theme-factory`, `web-artifacts-builder`, `webapp-testing`, `xlsx`

### 3. Matt Pocock Engineering & Productivity Suite (39 Skills)
`ask-matt`, `chief-of-staff`, `claude-handoff`, `code-review`, `codebase-design`, `diagnosing-bugs`, `domain-modeling`, `git-guardrails-claude-code`, `grill-me`, `grill-with-docs`, `grilling`, `handoff`, `implement`, `implement-spec`, `improve-codebase-architecture`, `loop-me`, `migrate-to-shoehorn`, `pr`, `prototype`, `research`, `retro`, `scaffold-exercises`, `setup-matt-pocock-skills`, `setup-pre-commit`, `setup-ts-deep-modules`, `software-factory`, `tdd`, `teach`, `to-questionnaire`, `to-spec`, `to-tickets`, `triage`, `wait-what`, `wayfinder`, `wizard`, `writing-beats`, `writing-for-agents`, `writing-fragments`, `writing-shape`
