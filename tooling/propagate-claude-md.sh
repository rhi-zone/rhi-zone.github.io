#!/bin/sh
# propagate-claude-md.sh <target-CLAUDE.md>
#
# Replaces the region between <!-- BEGIN ECOSYSTEM RULES --> and
# <!-- END ECOSYSTEM RULES --> in the target file with the canonical
# region from the root CLAUDE.md of the github-io repo.
#
# If the target has no markers: appends the canonical region (with markers).
# If the target has one marker but not the other: exits 1 (malformed).
# Idempotent.

set -e

CANONICAL="$(dirname "$0")/../CLAUDE.md"
TARGET="$1"

if [ -z "$TARGET" ]; then
  echo "Usage: $0 <target-CLAUDE.md>" >&2
  exit 1
fi

if [ ! -f "$CANONICAL" ]; then
  echo "Error: canonical CLAUDE.md not found at $CANONICAL" >&2
  exit 1
fi

if [ ! -f "$TARGET" ]; then
  echo "Error: target file not found: $TARGET" >&2
  exit 1
fi

# Extract the canonical region (including the markers themselves)
CANONICAL_REGION="$(awk '/^<!-- BEGIN ECOSYSTEM RULES -->/{found=1} found{print} /^<!-- END ECOSYSTEM RULES -->/{if(found){exit}}' "$CANONICAL")"

if [ -z "$CANONICAL_REGION" ]; then
  echo "Error: canonical CLAUDE.md has no ecosystem rules region" >&2
  exit 1
fi

# Check target marker state
HAS_BEGIN=0
HAS_END=0

if grep -qF '<!-- BEGIN ECOSYSTEM RULES -->' "$TARGET"; then
  HAS_BEGIN=1
fi
if grep -qF '<!-- END ECOSYSTEM RULES -->' "$TARGET"; then
  HAS_END=1
fi

# Malformed: one marker but not the other
if [ "$HAS_BEGIN" -eq 1 ] && [ "$HAS_END" -eq 0 ]; then
  echo "Error: target has BEGIN marker but no END marker: $TARGET" >&2
  exit 1
fi
if [ "$HAS_BEGIN" -eq 0 ] && [ "$HAS_END" -eq 1 ]; then
  echo "Error: target has END marker but no BEGIN marker: $TARGET" >&2
  exit 1
fi

# Idempotent check: if target IS the canonical file, no-op
CANONICAL_REAL="$(realpath "$CANONICAL")"
TARGET_REAL="$(realpath "$TARGET")"
if [ "$CANONICAL_REAL" = "$TARGET_REAL" ]; then
  echo "Target is the canonical file — no-op."
  exit 0
fi

if [ "$HAS_BEGIN" -eq 0 ]; then
  # No markers — append the canonical region
  printf '\n%s\n' "$CANONICAL_REGION" >> "$TARGET"
  echo "Appended ecosystem rules region to $TARGET"
else
  # Both markers present — replace the region between them
  TMP="$(mktemp)"
  awk -v region="$CANONICAL_REGION" '
    /^<!-- BEGIN ECOSYSTEM RULES -->/ { in_region=1; print region; next }
    /^<!-- END ECOSYSTEM RULES -->/  { in_region=0; next }
    !in_region { print }
  ' "$TARGET" > "$TMP"
  mv "$TMP" "$TARGET"
  echo "Replaced ecosystem rules region in $TARGET"
fi
