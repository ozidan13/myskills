#!/usr/bin/env bash
# Universal AI Agent Skills Installer (macOS / Linux / WSL / Git Bash)
# Supports Antigravity, OpenCode (Skills + /Slash Commands), Claude Code (+ /hunt commands), Cursor, Codex, Windsurf, Hermes, and Universal .agents

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BH_SUITE="$SCRIPT_DIR/_bughunter-suite"

echo "=============================================================================="
echo "      UNIVERSAL AI AGENT SKILLS INSTALLER (ALL APPS + SLASH COMMANDS)         "
echo "=============================================================================="

SKILL_DIRS=()
SKILL_NAMES=()
SKILL_DESCS=()

extract_desc() {
  local md="$1"
  local fallback="$2"
  local desc=""
  if [ -f "$md" ]; then
    desc="$(awk '
      BEGIN { fm=0; indesc=0; out="" }
      NR==1 && /^---[[:space:]]*$/ { fm=1; next }
      fm==1 && /^---[[:space:]]*$/ { exit }
      fm==1 {
        if (!indesc && $0 ~ /^description:[[:space:]]*/) {
          val=$0
          sub(/^description:[[:space:]]*/, "", val)
          gsub(/\r$/, "", val)
          if (val == "" || val ~ /^[>|][-+]?$/) {
            indesc=1
          } else {
            gsub(/^["\047]|["\047]$/, "", val)
            out=val
            indesc=1
          }
        } else if (indesc) {
          if ($0 ~ /^[[:space:]]+[^[:space:]]/) {
            line=$0
            sub(/^[[:space:]]+/, "", line)
            gsub(/\r$/, "", line)
            out = (out == "" ? line : out " " line)
          } else if ($0 ~ /^[[:space:]]*$/) {
            next
          } else {
            exit
          }
        }
      }
      END { print out }
    ' "$md")"
  fi
  if [ -z "$desc" ]; then
    desc="Load and follow the $fallback skill instructions"
  fi
  if [ "${#desc}" -gt 220 ]; then
    desc="${desc:0:217}..."
  fi
  printf "%s" "$desc"
}

while IFS= read -r -d '' skill_md; do
  dir="$(dirname "$skill_md")"
  name="$(basename "$dir")"
  desc="$(extract_desc "$skill_md" "$name")"
  SKILL_DIRS+=("$dir")
  SKILL_NAMES+=("$name")
  SKILL_DESCS+=("$desc")
done < <(find "$SCRIPT_DIR" -type f -name "SKILL.md" -not -path "*/.git/*" -not -path "*/node_modules/*" -not -path "*/_bughunter-suite/*" -print0 | sort -z)

COUNT=${#SKILL_NAMES[@]}
if [ "$COUNT" -eq 0 ]; then
  echo "[ERROR] No skills with SKILL.md found in $SCRIPT_DIR"
  exit 1
fi

echo "Bundle Path : $SCRIPT_DIR"
echo "Auto-Found  : $COUNT skills ready to install!"
echo ""

CHOICE="${1:-}"
CUSTOM_DIR="${2:-}"

if [ -z "$CHOICE" ]; then
  echo "Where do you want to install?"
  echo "  [1] ALL Global AI Apps      (Antigravity + OpenCode + Claude + Cursor + Codex + Windsurf + Hermes) [DEFAULT]"
  echo "  [2] Antigravity Global      (~/.gemini/config/skills)"
  echo "  [3] OpenCode Global         (~/.config/opencode/skills + /slash commands)"
  echo "  [4] Claude Code Global      (~/.claude/skills + commands + hunt.sh)"
  echo "  [5] Cursor IDE Global       (~/.cursor/skills)"
  echo "  [6] OpenAI Codex Global     (~/.codex/skills)"
  echo "  [7] Windsurf & .agents      (~/.codeium/windsurf/skills + ~/.agents/skills)"
  echo "  [8] Hermes Agent Global     (~/.hermes/skills)"
  echo "  [9] OpenCode Project Folder (./.opencode/skills + /slash commands)"
  echo "  [W] Project Workspace (All) (./.agents + .opencode + .claude + .cursor + .codex)"
  echo "  [0] Custom Directory Path"
  echo "  [Q] Quit"
  echo ""
  read -r -p "Select target [1-9, W=Workspace, 0=Custom, Enter=1 (ALL Global), Q=Quit]: " CHOICE
  CHOICE="${CHOICE:-1}"
fi

truncate_codex_descriptions() {
  local root_dir="$1"
  if command -v python3 >/dev/null 2>&1; then
    python3 - "$root_dir" <<'PY'
import os, re, sys
root = sys.argv[1]
LIMIT = 1000
for name in sorted(os.listdir(root)):
    p = os.path.join(root, name, 'SKILL.md')
    if not os.path.isfile(p):
        continue
    lines = open(p, encoding='utf-8').read().split('\n')
    changed = False
    for i in range(min(14, len(lines))):
        m = re.match(r'^description:\s*(.+)$', lines[i].rstrip('\r'))
        if m and not re.match(r'^[>|][-+]?$', m.group(1).strip()):
            val = m.group(1).strip()
            inner = val[1:-1] if len(val) >= 2 and val[0] == val[-1] and val[0] in '"\'' else val
            if len(inner) > LIMIT:
                cut = inner[:LIMIT - 3].rsplit(' ', 1)[0].rstrip(' ,;:_-')
                escaped = cut.replace('\\', '\\\\').replace('"', '\\"')
                lines[i] = f'description: "{escaped}..."'
                changed = True
    if changed:
        open(p, 'w', encoding='utf-8').write('\n'.join(lines))
PY
  fi
}

install_skills_to() {
  local label="$1"
  local skills_dest="$2"
  local cmds_dest="$3"
  local mode="$4" # opencode | claude | codex | default

  echo ""
  echo ">>> [$label]"
  mkdir -p "$skills_dest"
  for i in "${!SKILL_NAMES[@]}"; do
    local sname="${SKILL_NAMES[$i]}"
    local sdir="${SKILL_DIRS[$i]}"
    local target="$skills_dest/$sname"
    if [ "$(cd "$sdir" && pwd)" != "$(mkdir -p "$target" && cd "$target" && pwd)" ]; then
      cp -R "$sdir/." "$target/"
      rm -rf "$target/.git"
    fi
  done
  if [ "$mode" = "codex" ]; then
    truncate_codex_descriptions "$skills_dest"
  fi
  echo "  [OK] Installed $COUNT skill folder(s)   -> $skills_dest"

  if [ "$mode" = "opencode" ] && [ -n "$cmds_dest" ]; then
    mkdir -p "$cmds_dest"
    local cmd_total=0
    for i in "${!SKILL_NAMES[@]}"; do
      local sname="${SKILL_NAMES[$i]}"
      local sdesc="${SKILL_DESCS[$i]}"
      local escaped_desc="${sdesc//\\/\\\\}"
      escaped_desc="${escaped_desc//\"/\\\"}"
      cat > "$cmds_dest/$sname.md" <<EOF
---
description: "$escaped_desc"
---

Use the \`skill\` tool to load the \`$sname\` skill, then follow its instructions.

\$ARGUMENTS
EOF
      cmd_total=$((cmd_total + 1))
    done
    if [ -d "$BH_SUITE/commands" ]; then
      for cf in "$BH_SUITE/commands/"*.md; do
        [ -f "$cf" ] || continue
        local base
        base="$(basename "$cf" .md)"
        local out_name="$base.md"
        if [ "$base" = "triage" ]; then out_name="bb-triage.md"; fi
        if [ "$base" = "web3-audit" ]; then continue; fi
        cp "$cf" "$cmds_dest/$out_name"
        if ! grep -q '\$ARGUMENTS' "$cmds_dest/$out_name"; then
          printf "\n\$ARGUMENTS\n" >> "$cmds_dest/$out_name"
        fi
        cmd_total=$((cmd_total + 1))
      done
    fi
    echo "  [OK] Generated $cmd_total /slash command(s) -> $cmds_dest"
  fi

  if [ "$mode" = "claude" ] && [ -n "$cmds_dest" ] && [ -d "$BH_SUITE/commands" ]; then
    mkdir -p "$cmds_dest"
    cp "$BH_SUITE/commands/"*.md "$cmds_dest/"
    [ -f "$BH_SUITE/commands/triage.md" ] && cp "$BH_SUITE/commands/triage.md" "$cmds_dest/bb-triage.md"
    echo "  [OK] Installed BugHunter /commands      -> $cmds_dest"
    if [ "$label" = "Claude Code Global" ] && [ -f "$BH_SUITE/scripts/hunt.sh" ]; then
      mkdir -p "$HOME/.claude/scripts"
      cp "$BH_SUITE/scripts/hunt.sh" "$HOME/.claude/scripts/hunt.sh"
      chmod +x "$HOME/.claude/scripts/hunt.sh"
      echo "  [OK] Installed hunt.sh scaffolder       -> $HOME/.claude/scripts/hunt.sh"
    fi
  fi
}

INSTALLED_OPENCODE=0
PROJ="${CUSTOM_DIR:-.}"

case "$CHOICE" in
  1|AllGlobal)
    install_skills_to "Antigravity Global" "$HOME/.gemini/config/skills" "" "default"
    install_skills_to "OpenCode Global" "$HOME/.config/opencode/skills" "$HOME/.config/opencode/commands" "opencode"
    install_skills_to "Claude Code Global" "$HOME/.claude/skills" "$HOME/.claude/commands" "claude"
    install_skills_to "Cursor IDE Global" "$HOME/.cursor/skills" "" "default"
    install_skills_to "OpenAI Codex Global" "$HOME/.codex/skills" "" "codex"
    install_skills_to "Windsurf Global" "$HOME/.codeium/windsurf/skills" "" "default"
    install_skills_to "Hermes Agent Global" "$HOME/.hermes/skills" "" "default"
    install_skills_to "Universal .agents Global" "$HOME/.agents/skills" "" "codex"
    INSTALLED_OPENCODE=1
    ;;
  2|Antigravity|Global)
    install_skills_to "Antigravity Global" "$HOME/.gemini/config/skills" "" "default"
    ;;
  3|OpenCode)
    install_skills_to "OpenCode Global" "$HOME/.config/opencode/skills" "$HOME/.config/opencode/commands" "opencode"
    INSTALLED_OPENCODE=1
    ;;
  4|ClaudeCode)
    install_skills_to "Claude Code Global" "$HOME/.claude/skills" "$HOME/.claude/commands" "claude"
    ;;
  5|Cursor)
    install_skills_to "Cursor IDE Global" "$HOME/.cursor/skills" "" "default"
    ;;
  6|Codex)
    install_skills_to "OpenAI Codex Global" "$HOME/.codex/skills" "" "codex"
    ;;
  7|Windsurf)
    install_skills_to "Windsurf Global" "$HOME/.codeium/windsurf/skills" "" "default"
    install_skills_to "Universal .agents Global" "$HOME/.agents/skills" "" "codex"
    ;;
  8|Hermes)
    install_skills_to "Hermes Agent Global" "$HOME/.hermes/skills" "" "default"
    ;;
  9|OpenCodeWorkspace)
    install_skills_to "OpenCode Project" "$PROJ/.opencode/skills" "$PROJ/.opencode/commands" "opencode"
    INSTALLED_OPENCODE=1
    ;;
  w|W|Workspace|AllWorkspace)
    install_skills_to "Project .agents" "$PROJ/.agents/skills" "" "codex"
    install_skills_to "Project OpenCode" "$PROJ/.opencode/skills" "$PROJ/.opencode/commands" "opencode"
    install_skills_to "Project Claude Code" "$PROJ/.claude/skills" "$PROJ/.claude/commands" "claude"
    install_skills_to "Project Cursor IDE" "$PROJ/.cursor/skills" "" "default"
    install_skills_to "Project OpenAI Codex" "$PROJ/.codex/skills" "" "codex"
    INSTALLED_OPENCODE=1
    ;;
  0|Custom)
    if [ -z "$CUSTOM_DIR" ]; then
      read -r -p "Enter custom destination directory: " CUSTOM_DIR
    fi
    install_skills_to "Custom Destination" "$CUSTOM_DIR" "" "default"
    ;;
  q|Q)
    echo "Cancelled."
    exit 0
    ;;
  *)
    echo "Invalid choice: $CHOICE"
    exit 1
    ;;
esac

if [ "$INSTALLED_OPENCODE" -eq 1 ]; then
  echo "  [READY] OpenCode watches ~/.config/opencode/commands live — type / in OpenCode!"
fi

echo ""
echo "=============================================================================="
echo "  SUCCESS! Installed $COUNT skill(s)."
echo "=============================================================================="
