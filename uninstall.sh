#!/usr/bin/env bash
# Uninstall iOS Care skills from a .claude/skills/ directory.
# Removes only skills that exist in this repo — leaves any unrelated skills
# in the target directory untouched.
#
# Usage:
#   bash uninstall.sh           # uninstalls from ./.claude/skills/ (project scope, default)
#   bash uninstall.sh global    # uninstalls from ~/.claude/skills/ (global scope)
#
# Or directly via curl-pipe:
#   bash <(curl -fsSL https://raw.githubusercontent.com/joquerod/acoding-iosCare-skills/main/uninstall.sh)
#   bash <(curl -fsSL https://raw.githubusercontent.com/joquerod/acoding-iosCare-skills/main/uninstall.sh) global

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

if [ ! -d "$TARGET" ]; then
  echo "No skills directory at $TARGET — nothing to uninstall."
  exit 0
fi

echo "Uninstalling iOS Care skills (scope: $SCOPE)"
echo "Target: $TARGET"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

echo "Fetching skill list from $REPO_URL..."
git clone --depth 1 --quiet "$REPO_URL" "$TMPDIR/repo"

removed=0
skipped=0
for skill_dir in "$TMPDIR/repo"/*/; do
  [ -f "$skill_dir/SKILL.md" ] || continue
  name=$(basename "$skill_dir")
  if [ -e "$TARGET/$name" ]; then
    rm -rf "$TARGET/$name"
    echo "  removed $name"
    removed=$((removed + 1))
  else
    skipped=$((skipped + 1))
  fi
done

echo ""
echo "Removed $removed skills from $TARGET ($skipped were already absent)."
echo "Run /clear in Claude Code or start a new session — skill registration only updates at session start."
