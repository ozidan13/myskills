---
name: install-skill
description: >-
  Install and configure agent skills across Antigravity, OpenCode, Claude Code, Cursor, Codex, and Windsurf from a Git repository URL, GitHub link, web URL, ZIP archive, or local file. Use when the user asks to install, add, or import a skill, or uses /install-skill with a link or file path.
---

# Install Skill

Automatically install, register, and verify skills across **Antigravity**, **OpenCode** (including `/slash` commands), **Claude Code**, **Cursor**, **OpenAI Codex**, and **Windsurf** from any source: GitHub repos, Git URLs, direct file links, ZIP archives, or local directories.

Installed skills immediately become accessible via slash commands (`/<skill-name>`) and natural language prompts.

## Operating Workflow

When the user provides a repository link, file path, or URL to install a skill:

### 1. Identify the Source & Options
Determine:
- **Source**: Git repository URL (e.g. `https://github.com/org/repo.git`), GitHub subdirectory link (`https://github.com/org/repo/tree/main/skills/xyz`), direct `SKILL.md` web link, or local path (`C:\path\to\...` or `.zip`).
- **Scope**:
  - `AllGlobal`: Installs globally to ALL AI apps at once (`Antigravity`, `OpenCode` skills + `/slash` commands, `Claude Code`, `Cursor`, `Codex`, `Windsurf`, and `~/.agents/skills/`).
  - `Both` (default): Installs globally (`~/.gemini/config/skills/`) and in the current workspace (`.agents/skills/`).
  - `OpenCode`: Installs to `~/.config/opencode/skills/` **and** generates `~/.config/opencode/commands/<name>.md` + triggers `opencode reload`.
  - `Global` / `ClaudeCode` / `Cursor` / `Codex` / `Windsurf` / `Workspace`: Installs to the respective target.

### 2. Run the Installer Helper Script

Execute the bundled installation script (look for `install-skill.ps1` relative to this `SKILL.md` file, or in `~/.gemini/config/skills/install-skill/scripts/install-skill.ps1`):

```powershell
powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\.gemini\config\skills\install-skill\scripts\install-skill.ps1" -Source "<SOURCE_URL_OR_PATH>" -Scope "AllGlobal"
```
*(Or use `./scripts/install-skill.ps1` relative to this skill's directory when running inside OpenCode, Cursor, or Claude Code)*

The script will automatically:
1. Clone the repository or download the files into a temporary directory.
2. Locate `SKILL.md` (or discover all skills recursively if the repo contains multiple skills).
3. Validate frontmatter (`name` and `description`). If missing, generate standard frontmatter.
4. Copy the complete skill package (including references, scripts, templates, and schemas) to the target app skills directories, and generate BOM-free `~/.config/opencode/commands/<skill-name>.md` wrappers when OpenCode is targeted.
5. Trigger live reload/verification on OpenCode (`opencode reload`) and Antigravity (`GetAllSkills`).

### 3. Report to User
Provide:
- The resolved skill name(s).
- Clickable markdown links to the installed `SKILL.md` files.
- Instructions on how to trigger it using `/<skill-name>`.
