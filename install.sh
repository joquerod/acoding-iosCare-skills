#!/usr/bin/env bash
# Install all iOS Care skills into a .claude/skills/ directory.
#
# Usage:
#   bash install.sh           # installs into ./.claude/skills/ (project scope, default)
#   bash install.sh global    # installs into ~/.claude/skills/ (global scope)
#
# Or directly via curl-pipe:
#   bash <(curl -fsSL https://raw.githubusercontent.com/joquerod/acoding-iosCare-skills/main/install.sh)
#   bash <(curl -fsSL https://raw.githubusercontent.com/joquerod/acoding-iosCare-skills/main/install.sh) global

set -euo pipefail

REPO_URL="https://github.com/joquerod/acoding-iosCare-skills.git"
SCOPE="${1:-project}"

case "$SCOPE" in
  project)
    TARGET="$PWD/.claude/skills"
    ;;
  global)
    TARGET="$HOME/.claude/skills"
    ;;
  *)
    echo "Usage: $0 [project|global]" >&2
    exit 1
    ;;
esac

echo "Installing iOS Care skills (scope: $SCOPE)"
echo "Target: $TARGET"
mkdir -p "$TARGET"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

echo "Cloning $REPO_URL..."
git clone --depth 1 --quiet "$REPO_URL" "$TMPDIR/repo"

count=0
for skill_dir in "$TMPDIR/repo"/*/; do
  [ -f "$skill_dir/SKILL.md" ] || continue
  name=$(basename "$skill_dir")
  rm -rf "$TARGET/$name"
  cp -R "$skill_dir" "$TARGET/$name"
  echo "  installed $name"
  count=$((count + 1))
done

echo ""
echo "Installed $count skills into $TARGET"
echo "Claude Code's live detection should pick them up without restart."
