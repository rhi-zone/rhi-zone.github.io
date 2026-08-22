#!/bin/sh
# propagate-harness.sh [--check] <target-repo-path>
#
# Brings a target repo to FULL current harness state in one idempotent operation:
#
#   1. Sync CLAUDE.md ecosystem region (between <!-- BEGIN/END ECOSYSTEM RULES -->).
#   2. Install / update ALL behavioral hook files with portable ${CLAUDE_PROJECT_DIR}
#      paths, including post-history.sh (fixing its historical absolute-path bug).
#   3. Wire all matching .claude/settings.json entries idempotently via jq —
#      strips any stale/absolute entries (matched by script basename) and
#      re-adds them pointing at ${CLAUDE_PROJECT_DIR}.
#   4. Verify the installed hooks EXECUTE (claude-hooks/verify-hooks.sh:
#      static dep check + smoke payloads; deny is success, crash is failure).
#      Apply mode: verification failure is a hard error. --check mode: a
#      receiver whose current hooks crash at runtime is reported as drift.
#      The verifier itself ships with the hooks so receivers can self-check.
#
# Hook set managed:
#   UserPromptSubmit ("")   inject-orchestrator-rules.sh
#       deps: lib/agent-id.sh, orchestrator-rules.md, orchestrator-workflows.md
#   UserPromptSubmit ("")   inject-style-rules.sh
#       deps: style-rules.md
#   UserPromptSubmit ("")   post-history.sh
#       (self-contained; was historically wired with an absolute path — fixed here)
#   PreToolUse ("Bash")     block-blocking-bash.sh
#   PreToolUse ("Bash")     block-runaway-find.sh
#   PreToolUse ("")         block-mainsession-exploration.sh
#       deps: lib/extract-command.awk, lib/extract-field.awk, lib/tokenize-bash.awk
#   PreToolUse ("Agent")    require-explicit-agent-type.sh
#
# --check  Dry run: report what would change, write nothing, exit 1 if drift.
#
# Supersedes: propagate-claude-md.sh, propagate-post-history.sh,
#             propagate-orchestrator-hooks.sh

set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CANONICAL_CLAUDE_MD="$SCRIPT_DIR/../CLAUDE.md"
CANONICAL_HOOKS="$SCRIPT_DIR/claude-hooks"

# All hook files to copy (relative to claude-hooks/).
HOOK_FILES="
inject-orchestrator-rules.sh
inject-style-rules.sh
block-blocking-bash.sh
block-runaway-find.sh
block-mainsession-exploration.sh
post-history.sh
subagent-decomposition-check.sh
plan-envelope-antibody.sh
require-explicit-agent-type.sh
orchestrator-rules.md
orchestrator-workflows.md
style-rules.md
verify-hooks.sh
lib/agent-id.sh
lib/extract-command.awk
lib/extract-field.awk
lib/tokenize-bash.awk
lib/smoke/inject-orchestrator-rules.payload
lib/smoke/inject-style-rules.payload
lib/smoke/block-blocking-bash.payload
lib/smoke/block-runaway-find.payload
lib/smoke/block-mainsession-exploration.payload
lib/smoke/post-history.payload
lib/smoke/require-explicit-agent-type.payload
"

# Subset that needs the executable bit.
EXEC_FILES="
inject-orchestrator-rules.sh
inject-style-rules.sh
block-blocking-bash.sh
block-runaway-find.sh
block-mainsession-exploration.sh
post-history.sh
subagent-decomposition-check.sh
plan-envelope-antibody.sh
require-explicit-agent-type.sh
verify-hooks.sh
lib/agent-id.sh
"

# ── Argument parsing ──────────────────────────────────────────────────────────
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
    printf '[harness-propagator] ERROR: jq is required (not on PATH).\n' >&2
    exit 1
fi

TARGET="$(cd "$TARGET_ARG" && pwd)"
TARGET_HOOKS="$TARGET/tooling/claude-hooks"
TARGET_SETTINGS="$TARGET/.claude/settings.json"
TARGET_CLAUDE_MD="$TARGET/CLAUDE.md"

drift=0   # tracks whether anything is out of date

# ── Step 1: CLAUDE.md ecosystem region ───────────────────────────────────────
if [ ! -f "$CANONICAL_CLAUDE_MD" ]; then
    printf '[harness-propagator] ERROR: canonical CLAUDE.md not found at %s\n' "$CANONICAL_CLAUDE_MD" >&2
    exit 1
fi

# Check if target IS the canonical file — skip CLAUDE.md sync for github-io itself.
CANONICAL_REAL="$(realpath "$CANONICAL_CLAUDE_MD")"
TARGET_CLAUDE_MD_REAL="$(realpath "$TARGET_CLAUDE_MD" 2>/dev/null || printf 'NONEXISTENT')"

if [ "$CANONICAL_REAL" = "$TARGET_CLAUDE_MD_REAL" ]; then
    # github-io is its own canonical source; no CLAUDE.md sync needed.
    :
elif [ ! -f "$TARGET_CLAUDE_MD" ]; then
    printf '[harness-propagator] WARNING: %s has no CLAUDE.md — skipping CLAUDE.md sync\n' "$TARGET" >&2
else
    CANONICAL_REGION="$(awk '/^<!-- BEGIN ECOSYSTEM RULES -->/{found=1} found{print} /^<!-- END ECOSYSTEM RULES -->/{if(found){exit}}' "$CANONICAL_CLAUDE_MD")"

    if [ -z "$CANONICAL_REGION" ]; then
        printf '[harness-propagator] ERROR: canonical CLAUDE.md has no ecosystem rules region\n' >&2
        exit 1
    fi

    HAS_BEGIN=0
    HAS_END=0
    grep -qF '<!-- BEGIN ECOSYSTEM RULES -->' "$TARGET_CLAUDE_MD" && HAS_BEGIN=1 || true
    grep -qF '<!-- END ECOSYSTEM RULES -->' "$TARGET_CLAUDE_MD" && HAS_END=1 || true

    if [ "$HAS_BEGIN" -eq 1 ] && [ "$HAS_END" -eq 0 ]; then
        printf '[harness-propagator] ERROR: %s has BEGIN marker but no END marker\n' "$TARGET_CLAUDE_MD" >&2
        exit 1
    fi
    if [ "$HAS_BEGIN" -eq 0 ] && [ "$HAS_END" -eq 1 ]; then
        printf '[harness-propagator] ERROR: %s has END marker but no BEGIN marker\n' "$TARGET_CLAUDE_MD" >&2
        exit 1
    fi

    if [ "$HAS_BEGIN" -eq 0 ]; then
        # No markers yet — append.
        drift=1
        if [ "$CHECK" -eq 1 ]; then
            printf '[check] would APPEND ecosystem rules region to %s\n' "$TARGET_CLAUDE_MD"
        else
            printf '\n%s\n' "$CANONICAL_REGION" >> "$TARGET_CLAUDE_MD"
            printf '[harness-propagator] appended ecosystem rules region to %s\n' "$TARGET_CLAUDE_MD"
        fi
    else
        # Both markers present — check whether region is current.
        CURRENT_REGION="$(awk '/^<!-- BEGIN ECOSYSTEM RULES -->/{found=1} found{print} /^<!-- END ECOSYSTEM RULES -->/{if(found){exit}}' "$TARGET_CLAUDE_MD")"
        if [ "$CURRENT_REGION" != "$CANONICAL_REGION" ]; then
            drift=1
            if [ "$CHECK" -eq 1 ]; then
                printf '[check] would REPLACE ecosystem rules region in %s\n' "$TARGET_CLAUDE_MD"
            else
                TMP="$(mktemp)"
                awk -v region="$CANONICAL_REGION" '
                    /^<!-- BEGIN ECOSYSTEM RULES -->/ { in_region=1; print region; next }
                    /^<!-- END ECOSYSTEM RULES -->/  { in_region=0; next }
                    !in_region { print }
                ' "$TARGET_CLAUDE_MD" > "$TMP"
                mv "$TMP" "$TARGET_CLAUDE_MD"
                printf '[harness-propagator] replaced ecosystem rules region in %s\n' "$TARGET_CLAUDE_MD"
            fi
        fi
    fi
fi

# ── Step 2: hook file copies ──────────────────────────────────────────────────
for rel in $HOOK_FILES; do
    src="$CANONICAL_HOOKS/$rel"
    dst="$TARGET_HOOKS/$rel"
    if [ ! -f "$src" ]; then
        printf '[harness-propagator] ERROR: canonical file missing: %s\n' "$src" >&2
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

# Apply executable bits (only when writing).
if [ "$CHECK" -eq 0 ]; then
    for rel in $EXEC_FILES; do
        dst="$TARGET_HOOKS/$rel"
        [ -f "$dst" ] && chmod +x "$dst" || true
    done
fi

# ── Step 2b: runtime hook verification ───────────────────────────────────────
# Static deps + smoke payloads via the canonical verifier (read-only), so a
# hook that would CRASH in the receiver (missing lib/ helper, awk fatal) is
# caught here instead of on the receiver's next tool call. A deliberate deny
# is success; only a crash fails. In --check mode this verifies the hooks as
# they currently sit on disk (runtime drift, not just file drift); in apply
# mode a failure after install is a hard error — never leave a receiver with
# crashing hooks.
VERIFIER="$CANONICAL_HOOKS/verify-hooks.sh"
if [ "$CHECK" -eq 1 ]; then
    if [ -d "$TARGET_HOOKS" ] && ! "$VERIFIER" "$TARGET_HOOKS" >/dev/null 2>&1; then
        drift=1
        printf '[check] hooks FAIL runtime verification in %s (detail: %s %s)\n' \
            "$TARGET_HOOKS" "$VERIFIER" "$TARGET_HOOKS"
    fi
else
    if ! "$VERIFIER" "$TARGET_HOOKS"; then
        printf '[harness-propagator] ERROR: hook runtime verification FAILED in %s — receiver hooks would crash; aborting\n' "$TARGET_HOOKS" >&2
        exit 1
    fi
fi

# ── Step 3: settings.json wiring ─────────────────────────────────────────────
# All hook commands use portable ${CLAUDE_PROJECT_DIR} paths.
INJECT_CMD='${CLAUDE_PROJECT_DIR}/tooling/claude-hooks/inject-orchestrator-rules.sh'
STYLE_CMD='${CLAUDE_PROJECT_DIR}/tooling/claude-hooks/inject-style-rules.sh'
HISTORY_CMD='${CLAUDE_PROJECT_DIR}/tooling/claude-hooks/post-history.sh'
BLOCKBASH_CMD='${CLAUDE_PROJECT_DIR}/tooling/claude-hooks/block-blocking-bash.sh'
RUNAWAYFIND_CMD='${CLAUDE_PROJECT_DIR}/tooling/claude-hooks/block-runaway-find.sh'
EXPLORE_CMD='${CLAUDE_PROJECT_DIR}/tooling/claude-hooks/block-mainsession-exploration.sh'
SUBAGENT_DECOMP_CMD='${CLAUDE_PROJECT_DIR}/tooling/claude-hooks/subagent-decomposition-check.sh'
PLAN_ENVELOPE_CMD='${CLAUDE_PROJECT_DIR}/tooling/claude-hooks/plan-envelope-antibody.sh'
REQUIRE_AGENT_TYPE_CMD='${CLAUDE_PROJECT_DIR}/tooling/claude-hooks/require-explicit-agent-type.sh'

if [ -f "$TARGET_SETTINGS" ]; then
    CURRENT="$(cat "$TARGET_SETTINGS")"
else
    CURRENT='{}'
fi

# Build desired state:
#   - Strip ALL stale entries for each managed basename (any path, absolute or portable).
#   - Re-append canonical entries with ${CLAUDE_PROJECT_DIR} paths.
# Order: inject-orchestrator-rules, post-history, plan-envelope-antibody under UserPromptSubmit;
#        subagent-decomposition-check under SubagentStart;
#        block-blocking-bash (Bash matcher), block-mainsession-exploration ("" matcher),
#        require-explicit-agent-type (Agent matcher) under PreToolUse.
DESIRED="$(printf '%s' "$CURRENT" | jq \
    --arg inject  "$INJECT_CMD" \
    --arg style   "$STYLE_CMD" \
    --arg history "$HISTORY_CMD" \
    --arg blockbash "$BLOCKBASH_CMD" \
    --arg runawayfind "$RUNAWAYFIND_CMD" \
    --arg explore "$EXPLORE_CMD" \
    --arg subagent_decomp "$SUBAGENT_DECOMP_CMD" \
    --arg plan_envelope "$PLAN_ENVELOPE_CMD" \
    --arg require_agent_type "$REQUIRE_AGENT_TYPE_CMD" '
    def strip($pat):
        map(select((.hooks // [] | map(.command | test($pat)) | any) | not));

    .hooks //= {} |
    .hooks.UserPromptSubmit //= [] |
    .hooks.SubagentStart //= [] |
    .hooks.PreToolUse //= [] |

    .hooks.UserPromptSubmit |= (
        strip("inject-orchestrator-rules\\.sh$")
        | strip("inject-style-rules\\.sh$")
        | strip("post-history\\.sh$")
        | strip("plan-envelope-antibody\\.sh$")
        + [ { "matcher": "", "hooks": [ { "type": "command", "command": $inject  } ] } ]
        + [ { "matcher": "", "hooks": [ { "type": "command", "command": $style   } ] } ]
        + [ { "matcher": "", "hooks": [ { "type": "command", "command": $history } ] } ]
        + [ { "matcher": "", "hooks": [ { "type": "command", "command": $plan_envelope } ] } ]
    ) |

    .hooks.SubagentStart |= (
        strip("subagent-decomposition-check\\.sh$")
        + [ { "matcher": "", "hooks": [ { "type": "command", "command": $subagent_decomp } ] } ]
    ) |

    .hooks.PreToolUse |= (
        strip("block-blocking-bash\\.sh$")
        | strip("block-runaway-find\\.sh$")
        | strip("block-mainsession-exploration\\.sh$")
        | strip("require-explicit-agent-type\\.sh$")
        + [ { "matcher": "Bash", "hooks": [ { "type": "command", "command": $blockbash } ] } ]
        + [ { "matcher": "Bash", "hooks": [ { "type": "command", "command": $runawayfind } ] } ]
        + [ { "matcher": "",     "hooks": [ { "type": "command", "command": $explore  } ] } ]
        + [ { "matcher": "Agent", "hooks": [ { "type": "command", "command": $require_agent_type } ] } ]
    )
')"

NORM_CURRENT="$(printf '%s' "$CURRENT" | jq -S .)"
NORM_DESIRED="$(printf '%s' "$DESIRED" | jq -S .)"

if [ "$NORM_CURRENT" != "$NORM_DESIRED" ]; then
    drift=1
    if [ "$CHECK" -eq 1 ]; then
        printf '[check] would WIRE settings: %s\n' "$TARGET_SETTINGS"
        printf '          UserPromptSubmit += inject-orchestrator-rules.sh (%s)\n' "$INJECT_CMD"
        printf '          UserPromptSubmit += inject-style-rules.sh        (%s)\n' "$STYLE_CMD"
        printf '          UserPromptSubmit += post-history.sh              (%s)\n' "$HISTORY_CMD"
        printf '          UserPromptSubmit += plan-envelope-antibody.sh    (%s)\n' "$PLAN_ENVELOPE_CMD"
        printf '          SubagentStart[""] += subagent-decomposition-check.sh (%s)\n' "$SUBAGENT_DECOMP_CMD"
        printf '          PreToolUse[Bash]  += block-blocking-bash.sh      (%s)\n' "$BLOCKBASH_CMD"
        printf '          PreToolUse[Bash]  += block-runaway-find.sh      (%s)\n' "$RUNAWAYFIND_CMD"
        printf '          PreToolUse[""]    += block-mainsession-exploration.sh (%s)\n' "$EXPLORE_CMD"
        printf '          PreToolUse[Agent] += require-explicit-agent-type.sh (%s)\n' "$REQUIRE_AGENT_TYPE_CMD"
        printf '        resulting settings.json:\n'
        printf '%s\n' "$DESIRED" | jq .
    else
        if ! printf '%s' "$DESIRED" | jq . >/dev/null 2>&1; then
            printf '[harness-propagator] ERROR: resulting JSON invalid\n' >&2
            exit 1
        fi
        mkdir -p "$(dirname "$TARGET_SETTINGS")"
        printf '%s\n' "$DESIRED" > "$TARGET_SETTINGS"
    fi
fi

# ── Summary ───────────────────────────────────────────────────────────────────
if [ "$CHECK" -eq 1 ]; then
    if [ "$drift" -eq 0 ]; then
        printf '[harness-propagator] %s — up to date (no-op)\n' "$TARGET"
        exit 0
    fi
    printf '[harness-propagator] %s — DRIFT (changes pending above)\n' "$TARGET"
    exit 1
fi

if [ "$drift" -eq 0 ]; then
    printf '[harness-propagator] %s — already current (no-op)\n' "$TARGET"
else
    printf '[harness-propagator] %s — harness installed/updated\n' "$TARGET"
fi
