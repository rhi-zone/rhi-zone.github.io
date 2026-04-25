#!/usr/bin/env bash
# Propagate a .claude/commands/<skill>.md to all ecosystem repos that have it,
# run normalize init, commit, and push where clean.
#
# Usage:
#   propagate-skill.sh <skill-file> "<commit message>"
#
# Examples:
#   propagate-skill.sh polish.md "chore(polish): add completeness lens"
#   propagate-skill.sh handoff.md "chore(handoff): fix EnterPlanMode reference"
#
# Source of truth: ~/.claude/commands/<skill-file>
# Pushed IFF repo is clean after staging only the skill + normalize files.

set -euo pipefail

SKILL_FILE="${1:?Usage: propagate-skill.sh <skill-file> \"<commit message>\"}"
COMMIT_MSG="${2:?Usage: propagate-skill.sh <skill-file> \"<commit message>\"}"

SOURCE=~/.claude/commands/"$SKILL_FILE"
NORMALIZE=~/git/rhizone/normalize/target/debug/normalize

if [ ! -f "$SOURCE" ]; then
  echo "error: $SOURCE not found" >&2
  exit 1
fi

REPOS=$(find ~/git -name "$SKILL_FILE" -path "*/.claude/commands/*" 2>/dev/null \
  | awk -F'/.claude/' '{print $1}' | sort -u)

if [ -z "$REPOS" ]; then
  echo "No repos found with .claude/commands/$SKILL_FILE" >&2
  exit 1
fi

echo "Propagating $SKILL_FILE to $(echo "$REPOS" | wc -l) repos..."

for repo in $REPOS; do
  echo
  echo "=== $repo ==="
  cd "$repo" || { echo "  cd failed"; continue; }

  cp "$SOURCE" ".claude/commands/$SKILL_FILE"

  direnv allow . 2>/dev/null || true
  "$NORMALIZE" init >/dev/null 2>&1 || true

  git add ".claude/commands/$SKILL_FILE" .gitignore .normalize/ 2>/dev/null || true

  if git diff --cached --quiet; then
    echo "  nothing staged"
    remaining=$(git status --porcelain)
    if [ -z "$remaining" ]; then
      git push 2>&1 | tail -2 | sed 's/^/    /'
    fi
    continue
  fi

  if direnv exec . bash -c "git commit -m $(printf '%q' "$COMMIT_MSG")" 2>&1 \
      | grep -E "master|failed|Pre-commit" | sed 's/^/  /'; then
    :
  else
    echo "  commit FAILED"
    continue
  fi

  remaining=$(git status --porcelain)
  if [ -z "$remaining" ]; then
    echo "  clean — pushing"
    git push 2>&1 | tail -2 | sed 's/^/    /'
  else
    echo "  dirty, skipping push:"
    echo "$remaining" | sed 's/^/    /'
  fi
done
