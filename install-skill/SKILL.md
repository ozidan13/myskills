---
name: install-skill
description: >-
  Install and configure agent skills into Antigravity from a Git repository URL, GitHub link, web URL, ZIP archive, or local file. Use when the user asks to install, add, or import a skill, or uses /install-skill with a link or file path.
---

# Install Skill

Automatically install, register, and verify skills in Antigravity from any source: GitHub repos, Git URLs, direct file links, ZIP archives, or local directories.

Installed skills immediately become accessible via slash commands (`/<skill-name>`) and natural language prompts.

## Operating Workflow

When the user provides a repository link, file path, or URL to install a skill:

### 1. Identify the Source & Options
Determine:
- **Source**: Git repository URL (e.g. `https://github.com/org/repo.git`), GitHub subdirectory link (`https://github.com/org/repo/tree/main/skills/xyz`), direct `SKILL.md` web link, or local path (`C:\path\to\...` or `.zip`).
- **Scope**:
  - `Both` (default): Installs globally (`~/.gemini/config/skills/`) and in the current workspace (`.agents/skills/`).
  - `Global`: Installs globally so all projects have access.
  - `Workspace`: Installs only in `.agents/skills/` for the current project.

### 2. Run the Installer Helper Script

Execute the bundled installation script:

```powershell
powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\.gemini\config\skills\install-skill\scripts\install-skill.ps1" -Source "<SOURCE_URL_OR_PATH>" -Scope "Both"
```
*(Or use `./scripts/install-skill.ps1` when running directly from the skill folder)*

The script will automatically:
1. Clone the repository or download the files into a temporary directory.
2. Locate `SKILL.md` (or discover all skills if the repo contains a `skills/` directory).
3. Validate frontmatter (`name` and `description`). If missing, generate standard frontmatter.
4. Copy the complete skill package (including references, scripts, templates, and schemas) to the target skills directory:
   - Global: `~/.gemini/config/skills/<skill-name>/`
   - Workspace: `<workspace-root>/.agents/skills/<skill-name>/`
5. Query Antigravity's Language Server (`GetAllSkills`) to confirm live indexing.

### 3. Verification & Live Confirmation

If running manually without the helper script, verify that:
1. `<target_dir>/SKILL.md` exists and begins with:
   ```yaml
   ---
   name: <skill-name>
   description: <Clear description of what it does and when to use it>
   ---
   ```
2. Check discovery via the Language Server endpoint:
   ```powershell
   $headers = @{ "Content-Type" = "application/json"; "x-codeium-csrf-token" = $env:ANTIGRAVITY_CSRF_TOKEN }
   $body = '{"workspaceUris":["file:///' + (Get-Location).Path.Replace('\','/') + '"]}'
   Invoke-RestMethod -Uri "http://$($env:ANTIGRAVITY_LS_ADDRESS)/exa.language_server_pb.LanguageServerService/GetAllSkills" -Method Post -Headers $headers -Body $body
   ```

### 4. Report to User
Provide:
- The resolved skill name(s).
- Clickable markdown links to the installed `SKILL.md` files.
- Instructions on how to trigger it using `/<skill-name>`.
