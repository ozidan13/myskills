#!/usr/bin/env bash
# Universal AI Agent Skills Installer (macOS / Linux) with Auto-Discovery & OpenCode Support

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================================================="
echo "        UNIVERSAL AI AGENT SKILLS INSTALLER (AUTO-DISCOVERY .SH)          "
echo "=========================================================================="

# Auto-discover all directories containing SKILL.md recursively (excluding .git and node_modules)
SKILL_DIRS=()
SKILL_NAMES=()

while IFS= read -r -d '' skill_md; do
  dir="$(dirname "$skill_md")"
  name="$(basename "$dir")"
  SKILL_DIRS+=("$dir")
  SKILL_NAMES+=("$name")
done < <(find "$SCRIPT_DIR" -type f -name "SKILL.md" -not -path "*/.git/*" -not -path "*/node_modules/*" -print0 | sort -z)

COUNT=${#SKILL_NAMES[@]}
if [ "$COUNT" -eq 0 ]; then
  echo "[ERROR] No skills with SKILL.md found in $SCRIPT_DIR"
  exit 1
fi

echo "Auto-Found $COUNT skills ready to install:"
for i in "${!SKILL_NAMES[@]}"; do
  printf "  [%2d] %s\n" $((i+1)) "${SKILL_NAMES[$i]}"
done
echo ""

echo "Where do you want to install?"
echo "  1) Antigravity Global      (~/.gemini/config/skills)"
echo "  2) OpenCode Global         (~/.config/opencode/skills)"
echo "  3) OpenCode Project Folder (./.opencode/skills)"
echo "  4) Claude Code Global      (~/.claude/skills)"
echo "  5) Project Workspace       (./.agents/skills - Cursor/Windsurf/Antigravity)"
echo "  6) ALL Global Apps         (Antigravity + OpenCode + Claude Code at once!) [Default]"
echo "  7) Custom Directory Path"
echo "  q) Quit"
echo ""
read -p "Select target [1-7, default=6, q=Quit]: " CHOICE
CHOICE="${CHOICE:-6}"

DESTINATIONS=()

case "$CHOICE" in
  1) DESTINATIONS+=("$HOME/.gemini/config/skills") ;;
  2) DESTINATIONS+=("$HOME/.config/opencode/skills") ;;
  3) DESTINATIONS+=("./.opencode/skills") ;;
  4) DESTINATIONS+=("$HOME/.claude/skills") ;;
  5) DESTINATIONS+=("./.agents/skills") ;;
  6) DESTINATIONS+=("$HOME/.gemini/config/skills" "$HOME/.config/opencode/skills" "$HOME/.claude/skills") ;;
  7)
    read -p "Enter custom destination directory: " CUSTOM_DIR
    DESTINATIONS+=("$CUSTOM_DIR")
    ;;
  q|Q)
    echo "Cancelled."
    exit 0
    ;;
  *)
    echo "Invalid choice. Exiting."
    exit 1
    ;;
esac

for DEST in "${DESTINATIONS[@]}"; do
  echo -e "\n>>> Installing $COUNT skill(s) to: $DEST"
  mkdir -p "$DEST"
  for i in "${!SKILL_NAMES[@]}"; do
    TARGET="$DEST/${SKILL_NAMES[$i]}"
    mkdir -p "$TARGET"
    cp -R "${SKILL_DIRS[$i]}/"* "$TARGET/"
    echo "  [OK] ($((i+1))/$COUNT) ${SKILL_NAMES[$i]}"
  done
done

echo -e "\n=========================================================================="
echo "  SUCCESS! Installed $COUNT skill(s)."
echo "=========================================================================="
