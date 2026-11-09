# ✦ My AI Agent Skills Vault (`myskills`)

> **144 Curated AI Agent Superpowers** — Custom Core + Anthropic Official + Matt Pocock Engineering & Productivity + Claude-BugHunter (83 Skills + 15 Slash Commands + `cbh` CLI + Deterministic Scope Engine).  
> **١٤٤ مهارة احترافية للذكاء الاصطناعي** جاهزة للتثبيت بضغطة واحدة شاملة أوامر السلاش `/` على **Antigravity** و **OpenCode** و **Claude Code** و **Cursor** و **OpenAI Codex** و **Windsurf** و **Hermes Agent**.

---

## 🎨 Interactive Bilingual Field Manual (`index.html`)

Open **[`index.html`](./index.html)** in any browser (or enable GitHub Pages on this repo) to explore all **144 skills** in a unified **English + Egyptian Arabic (بالمصري)** Architectural Blueprint Field Manual featuring:
- **Live Command Workbench** with instant search across English and Egyptian Arabic keywords (`/tdd`, `/hunt-idor`, `باج`, `إكسيل`, `باونتي`).
- **5-Stage Project Stepper** & **10 Real-World Situational Recipes** (including Web/API Bug Bounty Hunting & Enterprise/Cloud Red-Team workflows).
- **Mental Models (Feynman Analogies)**, **Without-vs-With Comparisons**, **Blueprint Schematics**, **Scenario Practice Drills**, and one-click `/command` + prompt copying.

---

## ⚡ Universal 1-Click Auto-Discovery Installer (`install.bat`)

`install.bat` is a **self-contained Windows `.bat` installer** that:
- **Automatically discovers** all **144** skill folders (`SKILL.md`) inside this repository every time you run it — drop any new skill folder in the future and run `install.bat`, and it appears automatically!
- **Auto-detects installed AI apps** on your PC (`[DETECTED]`) and installs:
  - **All 144 skill folders** across **8 global AI harnesses** (`Antigravity`, `OpenCode`, `Claude Code`, `Cursor`, `OpenAI Codex`, `Windsurf`, `Hermes Agent`, and Universal `.agents`).
  - **OpenAI Codex 1024-Char YAML Normalization**: Automatically truncates YAML `description:` fields > 1000 chars (`bb-local-toolkit`, `bug-bounty`, `offensive-osint`, `osint-methodology`) inside `~/.codex/skills/` and `~/.agents/skills/` while keeping the full descriptions in Claude Code, Antigravity, OpenCode, and Cursor.
  - **158 Native OpenCode `/slash` Commands**: Generates BOM-free `~/.config/opencode/commands/<name>.md` wrappers for all 144 skills plus the 14 non-overlapping `Claude-BugHunter` workflow commands (`triage.md` mapped to `/bb-triage` to avoid colliding with Matt Pocock's `/triage`) and triggers live `opencode reload`.
  - **Claude Code Commands & Engagement Scaffolder**: Installs `Claude-BugHunter`'s 15 `/commands` into `~/.claude/commands/` and wires `~/.claude/scripts/hunt.ps1` + `~/.claude/scripts/hunt.cmd`.

### Interactive Mode (Double-Click or Terminal)
Double-click **`install.bat`** in File Explorer (just press `Enter` to install to all global AI apps at once), or run:
```bat
git clone https://github.com/ozidan13/myskills.git
cd myskills
.\install.bat
```

### Supported Targets in `install.bat`
1. **`AllGlobal` [Default]** — Installs to **ALL 8 Global AI Apps** simultaneously!
2. **`Antigravity` (`Global`)** — `%USERPROFILE%\.gemini\config\skills`
3. **`OpenCode`** — `%USERPROFILE%\.config\opencode\skills` **+** `%USERPROFILE%\.config\opencode\commands\*.md` (158 `/slash` commands + live `opencode reload`)
4. **`ClaudeCode`** — `%USERPROFILE%\.claude\skills` **+** `%USERPROFILE%\.claude\commands\*.md` **+** `%USERPROFILE%\.claude\scripts\hunt.ps1` & `hunt.cmd`
5. **`Cursor`** — `%USERPROFILE%\.cursor\skills`
6. **`Codex`** — `%USERPROFILE%\.codex\skills` (with automatic `<=1000`-char YAML description normalization)
7. **`Windsurf`** — `%USERPROFILE%\.codeium\windsurf\skills` **+** `%USERPROFILE%\.agents\skills`
8. **`Hermes`** — `%USERPROFILE%\.hermes\skills`
9. **`OpenCodeWorkspace`** — `<project>\.opencode\skills` **+** `<project>\.opencode\commands\*.md`
10. **`AllWorkspace` (`Workspace`)** — `<project>\.agents`, `.opencode` (+ `commands`), `.claude`, `.cursor`, `.codex`
11. **`Custom`** — Any custom destination folder path

### Direct CLI Shortcuts (Non-Interactive)
```bat
:: Install all 144 skills + /slash commands to ALL global AI apps at once
.\install.bat AllGlobal

:: Install to OpenCode Global (144 skills + 158 /slash commands + live server reload)
.\install.bat OpenCode

:: Install to Antigravity Global
.\install.bat Antigravity

:: Install to Claude Code, Cursor, Codex, Windsurf, or Hermes
.\install.bat ClaudeCode
.\install.bat Cursor
.\install.bat Codex
.\install.bat Windsurf
.\install.bat Hermes

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

## 📦 What's Inside (144 Skills Across 4 Suites)

### 1. Custom Core Suite (3 Skills)
- `initialize-project-task` — Evidence-based phased task planning under `docs/` before modifying code.
- `install-skill` — Instant multi-app skill installer from any GitHub URL, tree link, ZIP, or local path (`/install-skill <url>`).
- `security-audit` — Six-phase Cloudflare defensive vulnerability discovery & adversarial verification harness.

### 2. Anthropic Official Suite (19 Skills)
`academy-guide`, `algorithmic-art`, `brand-guidelines`, `canvas-design`, `claude-api`, `discernment-nudge`, `doc-coauthoring`, `docx`, `frontend-design`, `internal-comms`, `mcp-builder`, `pdf`, `pptx`, `skill-creator`, `slack-gif-creator`, `theme-factory`, `web-artifacts-builder`, `webapp-testing`, `xlsx`

### 3. Matt Pocock Engineering & Productivity Suite (39 Skills)
`ask-matt`, `chief-of-staff`, `claude-handoff`, `code-review`, `codebase-design`, `diagnosing-bugs`, `domain-modeling`, `git-guardrails-claude-code`, `grill-me`, `grill-with-docs`, `grilling`, `handoff`, `implement`, `implement-spec`, `improve-codebase-architecture`, `loop-me`, `migrate-to-shoehorn`, `pr`, `prototype`, `research`, `retro`, `scaffold-exercises`, `setup-matt-pocock-skills`, `setup-pre-commit`, `setup-ts-deep-modules`, `software-factory`, `tdd`, `teach`, `to-questionnaire`, `to-spec`, `to-tickets`, `triage`, `wait-what`, `wayfinder`, `wizard`, `writing-beats`, `writing-for-agents`, `writing-fragments`, `writing-shape`

### 4. Claude-BugHunter Suite (83 Skills + `_bughunter-suite/` Companion Toolkit)
> **Authorized Security Testing Only**: Built from **681 disclosed HackerOne report patterns** across 24 core vulnerability classes, enterprise identity/infrastructure matrices, and deterministic scope/ledger gates. Use exclusively on systems you own or have explicit written authorization to test.

- **Orchestrators & Methodology (4)**: `bb-methodology`, `bug-bounty`, `hunt-dispatch`, `redteam-mindset`
- **Phase 0–2 Recon, OSINT, Toolkit & Scope (7)**: `bb-local-toolkit`, `evidence-hygiene`, `mid-engagement-ir-detection`, `offensive-osint`, `osint-methodology`, `recon-scope-triage`, `web2-recon`
- **Phase 3 Web & API Vulnerability Hunting (53)**: `hunt-api-misconfig`, `hunt-aspnet`, `hunt-ato`, `hunt-auth-bypass`, `hunt-brute-force`, `hunt-business-logic`, `hunt-cache-poison`, `hunt-captcha-bypass`, `hunt-cicd`, `hunt-clickjacking`, `hunt-cloud-misconfig`, `hunt-cors`, `hunt-csrf`, `hunt-deserialization`, `hunt-dom`, `hunt-exceptional-conditions`, `hunt-file-upload`, `hunt-fintech-graphql`, `hunt-forgot-password`, `hunt-graphql`, `hunt-grpc`, `hunt-host-header`, `hunt-html-injection`, `hunt-http-smuggling`, `hunt-idor`, `hunt-jwt-crypto`, `hunt-k8s`, `hunt-laravel`, `hunt-ldap`, `hunt-lfi`, `hunt-llm-ai`, `hunt-mfa-bypass`, `hunt-misc`, `hunt-nextjs`, `hunt-nodejs`, `hunt-nosqli`, `hunt-ntlm-info`, `hunt-oauth`, `hunt-open-redirect`, `hunt-race-condition`, `hunt-rag-vector`, `hunt-rce`, `hunt-saml`, `hunt-session`, `hunt-shadow-api`, `hunt-sharepoint`, `hunt-source-leak`, `hunt-spa-api`, `hunt-springboot`, `hunt-sqli`, `hunt-ssrf`, `hunt-ssti`, `hunt-subdomain`, `hunt-tls-network`, `hunt-websocket`, `hunt-xss`, `hunt-xxe`
- **Enterprise Identity, Cloud, Mobile & Web3 Red-Team (9)**: `apk-redteam-pipeline`, `cloud-iam-deep`, `enterprise-vpn-attack`, `ios-redteam-pipeline`, `m365-entra-attack`, `meme-coin-audit`, `okta-attack`, `supply-chain-attack-recon`, `vmware-vcenter-attack`, `web3-audit`
- **Phase 4–6 Triage, Payloads & Reporting (7)**: `bugcrowd-reporting`, `redteam-report-template`, `report-writing`, `security-arsenal`, `triage-validation`
- **Companion Toolkit (`_bughunter-suite/`)**: Includes all 15 `/commands`, `cbh` CLI (`cbh/`), deterministic Python scope & ledger engine (`engine/`), engagement scaffolder (`scripts/hunt.ps1` & `hunt.sh`), disclosed report citations (`docs/disclosed-reports/`), and upstream attribution (`LICENSE`, `LICENSE-CONTENT`, `NOTICE` crediting [elementalsouls/Claude-BugHunter](https://github.com/elementalsouls/Claude-BugHunter) by Sachin Sharma and [shuvonsec/claude-bug-bounty](https://github.com/shuvonsec/claude-bug-bounty)).
