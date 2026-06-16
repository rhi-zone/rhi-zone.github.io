#!/bin/sh
# propagate-orchestrator-hooks.sh [--check] <target-repo-path>
#
# Installs the FULL orchestrator hook set into a target repo, self-contained and
# versioned in-repo (per github-io CLAUDE.md: behavioral control stays in-repo,
# never machine-local). Companion to propagate-post-history.sh, which installs the
# post-history hook only; this script does NOT touch that hook's entry.
#
# Hook set (event → script → dependency closure):
#   UserPromptSubmit (matcher "")   inject-orchestrator-rules.sh
#       └ lib/agent-id.sh, orchestrator-rules.md, orchestrator-workflows.md
#   PreToolUse (matcher "Bash")     block-blocking-bash.sh
#       └ (self-contained)
#   PreToolUse (matcher "")         block-mainsession-exploration.sh
#       └ lib/extract-command.awk, lib/tokenize-bash.awk
#       (inlines agent-id logic; lib/agent-id.sh shipped anyway for inject-rules)
#
# All scripts resolve their dir via readlink -f "$BASH_SOURCE" and reference
# siblings (lib/, *.md) relatively, so copying the whole claude-hooks/ tree keeps
# them self-contained at the target path.
#
# Idempotent / convergent: re-running is a no-op when already current. Existing
# orchestrator entries (matched by command basename) are removed and re-appended
# pointing at the correct target-local absolute path, so a moved repo re-homes
# cleanly. jq-based settings injection (jq is required; matches the ecosystem).
#
# --check  Dry run. Reports what WOULD change (file copies + settings edits) and
#          exits non-zero if anything is out of date; writes nothing.

set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CANONICAL_HOOKS="$SCRIPT_DIR/claude-hooks"

# Files that make up the orchestrator set (relative to claude-hooks/).
# post-history.sh is deliberately excluded — separate propagator owns it.
HOOK_FILES="
inject-orchestrator-rules.sh
block-blocking-bash.sh
block-mainsession-exploration.sh
orchestrator-rules.md
orchestrator-workflows.md
lib/agent-id.sh
lib/extract-command.awk
lib/tokenize-bash.awk
"

# Executable bit applies to the .sh scripts only.
EXEC_FILES="
inject-orchestrator-rules.sh
block-blocking-bash.sh
block-mainsession-exploration.sh
lib/agent-id.sh
"

CHECK=0
TARGET_ARG=""
for arg in "$@"; do
    case "$arg" in
        --check) CHECK=1 ;;
        -*) printf 'Unknown flag: %s\n' "$arg" >&2; exit 2 ;;
        *) TARGET_ARG="$arg" ;;
    esac
done

if [ -z "$TARGET_ARG" ]; then
    printf 'Usage: %s [--check] <target-repo-path>\n' "$0" >&2
    exit 2
fi

if ! command -v jq >/dev/null 2>&1; then
    printf '[orchestrator-propagator] ERROR: jq is required (not on PATH).\n' >&2
    exit 1
fi

TARGET="$(cd "$TARGET_ARG" && pwd)"
TARGET_HOOKS="$TARGET/tooling/claude-hooks"
TARGET_SETTINGS="$TARGET/.claude/settings.json"

drift=0   # tracks whether anything is out of date (for --check exit code)

# ── Step 1: file copies ──────────────────────────────────────────────────────
for rel in $HOOK_FILES; do
    src="$CANONICAL_HOOKS/$rel"
    dst="$TARGET_HOOKS/$rel"
    if [ ! -f "$src" ]; then
        printf '[orchestrator-propagator] ERROR: canonical file missing: %s\n' "$src" >&2
        exit 1
    fi
    if [ -f "$dst" ] && cmp -s "$src" "$dst"; then
        continue   # up to date
    fi
    drift=1
    if [ "$CHECK" -eq 1 ]; then
        if [ -f "$dst" ]; then
            printf '[check] would UPDATE %s\n' "$dst"
        else
            printf '[check] would CREATE %s\n' "$dst"
        fi
    else
        mkdir -p "$(dirname "$dst")"
        cp "$src" "$dst"
    fi
done

# executable bits (only when writing)
if [ "$CHECK" -eq 0 ]; then
    for rel in $EXEC_FILES; do
        chmod +x "$TARGET_HOOKS/$rel"
    done
fi

# ── Step 2: settings.json wiring ─────────────────────────────────────────────
# Use ${CLAUDE_PROJECT_DIR} placeholder so the installed command paths are
# portable — they resolve to the repo root at runtime, not to an absolute
# machine-local path baked in at install time. Claude Code expands
# ${CLAUDE_PROJECT_DIR} in hook command strings to the project root.
INJECT_CMD='${CLAUDE_PROJECT_DIR}/tooling/claude-hooks/inject-orchestrator-rules.sh'
BLOCKBASH_CMD='${CLAUDE_PROJECT_DIR}/tooling/claude-hooks/block-blocking-bash.sh'
EXPLORE_CMD='${CLAUDE_PROJECT_DIR}/tooling/claude-hooks/block-mainsession-exploration.sh'

# Desired settings, computed from current (or {}).
if [ -f "$TARGET_SETTINGS" ]; then
    CURRENT="$(cat "$TARGET_SETTINGS")"
else
    CURRENT='{}'
fi

# Remove any prior orchestrator entries (matched by command basename, any path),
# then append the canonical entries pointing at this target's portable paths.
# post-history.sh entries are left untouched (different basename).
DESIRED="$(printf '%s' "$CURRENT" | jq \
    --arg inject "$INJECT_CMD" \
    --arg blockbash "$BLOCKBASH_CMD" \
    --arg explore "$EXPLORE_CMD" '
    def strip($pat):
        map(select((.hooks // [] | map(.command | test($pat)) | any) | not));

    .hooks //= {} |
    .hooks.UserPromptSubmit //= [] |
    .hooks.PreToolUse //= [] |

    .hooks.UserPromptSubmit |= (
        strip("inject-orchestrator-rules\\.sh$")
        + [ { "matcher": "", "hooks": [ { "type": "command", "command": $inject } ] } ]
    ) |

    .hooks.PreToolUse |= (
        strip("block-blocking-bash\\.sh$")
        | strip("block-mainsession-exploration\\.sh$")
        + [ { "matcher": "Bash", "hooks": [ { "type": "command", "command": $blockbash } ] } ]
        + [ { "matcher": "",     "hooks": [ { "type": "command", "command": $explore } ] } ]
    )
')"

# Did settings actually change?
NORM_CURRENT="$(printf '%s' "$CURRENT" | jq -S .)"
NORM_DESIRED="$(printf '%s' "$DESIRED" | jq -S .)"

if [ "$NORM_CURRENT" != "$NORM_DESIRED" ]; then
    drift=1
    if [ "$CHECK" -eq 1 ]; then
        printf '[check] would WIRE settings: %s\n' "$TARGET_SETTINGS"
        printf '          UserPromptSubmit += inject-orchestrator-rules.sh\n'
        printf '          PreToolUse[Bash]  += block-blocking-bash.sh\n'
        printf '          PreToolUse[""]    += block-mainsession-exploration.sh\n'
    else
        if ! printf '%s' "$DESIRED" | jq . >/dev/null 2>&1; then
            printf '[orchestrator-propagator] ERROR: resulting JSON invalid\n' >&2
            exit 1
        fi
        mkdir -p "$(dirname "$TARGET_SETTINGS")"
        printf '%s\n' "$DESIRED" > "$TARGET_SETTINGS"
    fi
fi

# ── Summary ──────────────────────────────────────────────────────────────────
if [ "$CHECK" -eq 1 ]; then
    if [ "$drift" -eq 0 ]; then
        printf '[orchestrator-propagator] %s — up to date (no-op)\n' "$TARGET"
        exit 0
    fi
    printf '[orchestrator-propagator] %s — DRIFT (changes pending above)\n' "$TARGET"
    exit 1
fi

if [ "$drift" -eq 0 ]; then
    printf '[orchestrator-propagator] %s — already current (no-op)\n' "$TARGET"
else
    printf '[orchestrator-propagator] %s — orchestrator hooks installed\n' "$TARGET"
fi
