#!/usr/bin/env bash
# Propagate a CLAUDE.md section to all ecosystem repos that have named anchors.
#
# Usage:
#   propagate-claudemd-section.sh <section-file> <anchor-before-header> <anchor-after-header> "<commit-message-subject>"
#
# Examples:
#   propagate-claudemd-section.sh tooling/sections/subagent-prompts.md \
#     "## Context Is The Only Scarce Resource" \
#     "## Durability" \
#     "expand Subagent Prompts to 12 modes"
#
# The section is inserted between <anchor-before-header> and <anchor-after-header>.
# If the section header already exists in the file, the repo is skipped.
# If either anchor is missing, the repo is skipped.
# Clean repos: insert, commit, push.
# Dirty repos: append a TODO item to TODO.md (created if absent).

set -euo pipefail

SECTION_FILE="${1:?Usage: propagate-claudemd-section.sh <section-file> <anchor-before-header> <anchor-after-header> \"<commit-message-subject>\"}"
ANCHOR_BEFORE="${2:?Missing anchor-before-header}"
ANCHOR_AFTER="${3:?Missing anchor-after-header}"
COMMIT_SUBJECT="${4:?Missing commit-message-subject}"

if [ ! -f "$SECTION_FILE" ]; then
  echo "error: $SECTION_FILE not found" >&2
  exit 1
fi

SECTION_HEADER=$(head -1 "$SECTION_FILE")

COMMITTED=()
TODO_REPOS=()
SKIP_MISSING=()
SKIP_PRESENT=()

GLOBS=(
  ~/git/rhizone/*/CLAUDE.md
  ~/git/exoplace/*/CLAUDE.md
  ~/git/pterror/*/CLAUDE.md
  ~/git/paragarden/*/CLAUDE.md
)

for claudemd in "${GLOBS[@]}"; do
  # Skip glob patterns that didn't expand
  [ -f "$claudemd" ] || continue

  repo=$(dirname "$claudemd")

  # Skip github-io (canonical source)
  case "$repo" in
    */rhizone/github-io) continue ;;
  esac

  # Check for both anchors
  if ! grep -qF "$ANCHOR_BEFORE" "$claudemd" || ! grep -qF "$ANCHOR_AFTER" "$claudemd"; then
    echo "SKIP (missing anchors): $repo"
    SKIP_MISSING+=("$repo")
    continue
  fi

  # Check if section header already present
  if grep -qF "$SECTION_HEADER" "$claudemd"; then
    echo "SKIP (already present): $repo"
    SKIP_PRESENT+=("$repo")
    continue
  fi

  STATUS=$(git -C "$repo" status --porcelain)

  if [ -z "$STATUS" ]; then
    # Clean repo: insert section between anchors
    TMPFILE=$(mktemp)
    awk -v anchor="$ANCHOR_AFTER" -v section="$SECTION_FILE" '
      $0 == anchor {
        while ((getline line < section) > 0) print line
        print ""
      }
      { print }
    ' "$claudemd" > "$TMPFILE"
    mv "$TMPFILE" "$claudemd"

    git -C "$repo" add CLAUDE.md

    git -C "$repo" commit -m "$(cat <<EOF
docs(claude): $COMMIT_SUBJECT

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"

    git -C "$repo" push
    echo "COMMITTED: $repo"
    COMMITTED+=("$repo")
  else
    # Dirty repo: append TODO item
    TODO_FILE="$repo/TODO.md"
    if [ ! -f "$TODO_FILE" ]; then
      printf '# TODO\n\n' > "$TODO_FILE"
    fi
    printf '- [ ] %s — see github-io for canonical version\n' "$COMMIT_SUBJECT" >> "$TODO_FILE"
    echo "TODO: $repo"
    TODO_REPOS+=("$repo")
  fi
done

echo
echo "=== Summary ==="
echo "Committed (${#COMMITTED[@]}): ${COMMITTED[*]:-none}"
echo "TODO      (${#TODO_REPOS[@]}): ${TODO_REPOS[*]:-none}"
echo "Skipped / missing anchors (${#SKIP_MISSING[@]}): ${SKIP_MISSING[*]:-none}"
echo "Skipped / already present (${#SKIP_PRESENT[@]}): ${SKIP_PRESENT[*]:-none}"
