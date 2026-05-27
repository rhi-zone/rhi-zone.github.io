#!/bin/sh
# propagate-post-history.sh <target-repo-path>
# Copies the canonical post-history PHI hook into a target repo and wires it
# into .claude/settings.json. Idempotent.

set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CANONICAL_HOOK="$SCRIPT_DIR/claude-hooks/post-history.sh"

if [ $# -ne 1 ] || [ -z "$1" ]; then
    printf 'Usage: %s <target-repo-path>\n' "$0" >&2
    exit 1
fi

TARGET="$(cd "$1" && pwd)"
TARGET_HOOK="$TARGET/tooling/claude-hooks/post-history.sh"
TARGET_SETTINGS="$TARGET/.claude/settings.json"
LOCAL_CMD="$TARGET_HOOK"

# Step 1: copy the hook
mkdir -p "$(dirname "$TARGET_HOOK")"
cp "$CANONICAL_HOOK" "$TARGET_HOOK"
chmod +x "$TARGET_HOOK"

# Step 2 & 3: ensure settings.json exists and contains the hook entry
mkdir -p "$(dirname "$TARGET_SETTINGS")"

if [ ! -f "$TARGET_SETTINGS" ]; then
    printf '{}' > "$TARGET_SETTINGS"
fi

if command -v jq >/dev/null 2>&1; then
    # --- jq path ---
    CURRENT="$(cat "$TARGET_SETTINGS")"

    # Check if an entry with matcher "UserPromptSubmit" and command matching
    # *post-history.sh already exists pointing at the correct local path.
    EXISTING_MATCH=$(printf '%s' "$CURRENT" | jq -r '
        .hooks.UserPromptSubmit // [] |
        .[] |
        select(.hooks // [] | .[] | .command | test("post-history\\.sh$")) |
        .hooks[] | select(.command | test("post-history\\.sh$")) | .command
    ' 2>/dev/null | head -1 || true)

    if [ "$EXISTING_MATCH" = "$LOCAL_CMD" ]; then
        # Already correct — nothing to do
        printf '[propagator] %s — hook already installed (no-op)\n' "$TARGET"
        exit 0
    fi

    # Build the new hook entry
    NEW_ENTRY=$(jq -n --arg cmd "$LOCAL_CMD" '{
        "matcher": "",
        "hooks": [{"type": "command", "command": $cmd}]
    }')

    # Remove any existing UserPromptSubmit entries whose command matches
    # post-history.sh (regardless of path), then append the correct entry.
    UPDATED=$(printf '%s' "$CURRENT" | jq \
        --argjson entry "$NEW_ENTRY" \
        --arg pattern "post-history\\.sh$" '
        .hooks.UserPromptSubmit //= [] |
        .hooks.UserPromptSubmit |= (
            map(select(
                (.hooks // [] | map(.command | test($pattern)) | any) | not
            )) + [$entry]
        )
    ')

    # Validate
    if ! printf '%s' "$UPDATED" | jq . >/dev/null 2>&1; then
        printf '[propagator] ERROR: resulting JSON is invalid\n' >&2
        exit 1
    fi

    printf '%s\n' "$UPDATED" > "$TARGET_SETTINGS"

else
    # --- awk/sed fallback (no jq) ---
    # This path handles only the simple cases: missing hooks block or a flat
    # structure. For complex nesting without jq, we do a best-effort inject.

    # Check if the correct entry is already present
    if grep -qF "$LOCAL_CMD" "$TARGET_SETTINGS" 2>/dev/null; then
        printf '[propagator] %s — hook already installed (no-op)\n' "$TARGET"
        exit 0
    fi

    # If the file is just '{}', replace with minimal structure
    TRIMMED="$(tr -d '[:space:]' < "$TARGET_SETTINGS")"
    if [ "$TRIMMED" = "{}" ]; then
        cat > "$TARGET_SETTINGS" <<EOJSON
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "matcher": "",
        "hooks": [{"type": "command", "command": "$LOCAL_CMD"}]
      }
    ]
  }
}
EOJSON
    else
        printf '[propagator] ERROR: jq not available and settings.json is non-trivial; cannot safely edit\n' >&2
        printf '[propagator] Install jq and re-run.\n' >&2
        exit 1
    fi
fi

# Final validation
if command -v jq >/dev/null 2>&1; then
    if ! jq . "$TARGET_SETTINGS" >/dev/null 2>&1; then
        printf '[propagator] ERROR: %s is not valid JSON after update\n' "$TARGET_SETTINGS" >&2
        exit 1
    fi
fi

printf '[propagator] %s — hook installed\n' "$TARGET"
