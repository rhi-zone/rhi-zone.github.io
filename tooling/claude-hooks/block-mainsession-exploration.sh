#!/usr/bin/env bash
# PreToolUse hook — main session is a pure orchestrator.
#
# Architecture: bash parameter-expansion split on "tool_input" separates
# harness-controlled fields (tool_name, agent_id) from model-controlled
# content (tool_input.command). No JSON depth-walker; no brace counters.
#
# Subagent detection: top-level agent_id present in prefix → bypass.
# tool_name / agent_id are extracted only from $prefix (before "tool_input").
#
# Bash allowlist: every semicolon/&&/||/pipe/newline-separated segment must
# start with an allowed (verb, subverb, ...) tuple.  Forbidden constructs
# ($( ` ${ eval source dot-source) are rejected before tokenizing.
#
# Awk scripts live in lib/ next to this file for independent testability.
# No python, jq, node, perl, ruby, nix-shell, or compiled binaries.

set -euo pipefail

dir="$(cd "$(dirname "$0")" && pwd)"
input=$(head -c $((1024 * 1024)))

# ── debug log ────────────────────────────────────────────────────────────────
if [[ "${CLAUDE_HOOK_DEBUG:-}" == "1" ]]; then
    state_dir="${CLAUDE_HOOK_STATE_DIR:-/tmp/claude-state}"
    mkdir -p "$state_dir"
    debug_log="$state_dir/hook-input.debug.log"
    touch "$debug_log"
    chmod 600 "$debug_log"
    printf '\n=== %s ===\n' "$(date -Iseconds)" >> "$debug_log"
    printf '%s\n' "$input" >> "$debug_log"
    # Trim to 2000 lines
    tmp_log=$(mktemp)
    tail -n 2000 "$debug_log" > "$tmp_log" && mv "$tmp_log" "$debug_log"
    chmod 600 "$debug_log"
fi

# ── denial helper ─────────────────────────────────────────────────────────────
DENY_MSG="Main session is read-only orchestrator. Allowed: Agent/Task*/AskUserQuestion/EnterPlanMode/ExitPlanMode/ToolSearch/ScheduleWakeup; Bash limited to git commit, git push, git status, git log --oneline (no chaining, no command substitution, no eval/source). Delegate everything else to a subagent."

deny() {
    local tool_name="$1"
    local extra="${2:-}"
    local reason="$DENY_MSG Denied tool: $tool_name."
    if [[ -n "$extra" ]]; then
        reason="$reason $extra"
    fi
    # JSON-escape the reason: \, then ", then tab/CR/LF via tr placeholders
    # Use awk to handle all control-char substitutions safely
    local escaped
    escaped=$(printf '%s' "$reason" | awk '
        {
            gsub(/\\/, "\\\\")
            gsub(/"/, "\\\"")
            gsub(/\t/, "\\t")
            gsub(/\r/, "\\r")
            # awk RS splits on \n; print adds \n between records but not in ORS
            printf "%s\\n", $0
        }
    ' | sed '$ s/\\n$//')
    printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' "$escaped"
    exit 0
}

# ── split on "tool_input" ─────────────────────────────────────────────────────
# prefix  = everything before the first occurrence of "tool_input"
# rest    = everything after  "tool_input":
prefix="${input%%\"tool_input\"*}"
rest="${input#*\"tool_input\":}"

# ── extract tool_name (only from prefix) ─────────────────────────────────────
tool_name=$(printf '%s' "$prefix" | grep -oE '"tool_name"\s*:\s*"[^"]*"' | head -1 | grep -oE '"[^"]*"$' | tr -d '"' || true)
if [[ -z "$tool_name" ]]; then
    exit 0  # no tool_name — fail open
fi

# ── extract agent_id (only from prefix) ──────────────────────────────────────
agent_id=$(printf '%s' "$prefix" | grep -oE '"agent_id"\s*:\s*"[^"]*"' | head -1 | grep -oE '"[^"]*"$' | tr -d '"' || true)
if [[ -n "$agent_id" ]]; then
    exit 0  # subagent — pass unconditionally
fi

# ── orchestration tools (always allowed) ─────────────────────────────────────
case "$tool_name" in
    Agent|Task|TaskCreate|TaskUpdate|TaskList|TaskGet|TaskOutput|TaskStop|\
    AskUserQuestion|EnterPlanMode|ExitPlanMode|ToolSearch|ScheduleWakeup)
        exit 0
        ;;
esac

# ── mutation tools (never allowed in main) ───────────────────────────────────
case "$tool_name" in
    Edit|Write|NotebookEdit)
        deny "$tool_name"
        ;;
esac

# ── Bash (limited allowlist) ──────────────────────────────────────────────────
if [[ "$tool_name" == "Bash" ]]; then

    # Extract raw (JSON-encoded) command string from $rest via awk state machine
    cmd_raw=$(printf '%s' "$rest" | awk -f "$dir/lib/extract-command.awk")

    # Reject empty command
    if [[ -z "$cmd_raw" ]]; then
        deny "$tool_name" "Empty command."
    fi

    # JSON-decode the command string via awk.
    # Order of substitutions (to avoid double-decoding):
    # 1. \\ → placeholder (chr(1)) first
    # 2. \" → "
    # 3. \n → newline
    # 4. \t → tab
    # 5. \r → CR
    # 6. \b → backspace
    # 7. \f → form-feed
    # 8. \/ → /
    # 9. placeholder → \
    # If \uXXXX appears, deny conservatively (no Unicode support needed for git cmds).
    if printf '%s' "$cmd_raw" | grep -qE '\\u[0-9a-fA-F]{4}'; then
        deny "$tool_name" "Command contains \\uXXXX escape — denied conservatively."
    fi

    command=$(printf '%s' "$cmd_raw" | awk '
        BEGIN { RS = ""; ORS = "" }
        {
            gsub(/\\\\/, "\001")
            gsub(/\\"/, "\"")
            gsub(/\\n/, "\n")
            gsub(/\\t/, "\t")
            gsub(/\\r/, "\r")
            gsub(/\\b/, "\010")
            gsub(/\\f/, "\014")
            gsub(/\\\//, "/")
            gsub(/\001/, "\\")
            printf "%s", $0
        }
    ')

    # Forbidden constructs — check decoded command (conservative: includes inside quotes)
    if printf '%s' "$command" | grep -qF '$(' ; then
        deny "$tool_name" "Forbidden construct: \$( in command."
    fi
    if printf '%s' "$command" | grep -qF '`' ; then
        deny "$tool_name" "Forbidden construct: backtick in command."
    fi
    if printf '%s' "$command" | grep -qF '${' ; then
        deny "$tool_name" "Forbidden construct: \${ in command."
    fi
    if printf '%s' "$command" | grep -qE '(^|[[:space:];&|])eval([[:space:];&|]|$)' ; then
        deny "$tool_name" "Forbidden construct: eval in command."
    fi
    if printf '%s' "$command" | grep -qE '(^|[[:space:];&|])source([[:space:];&|]|$)' ; then
        deny "$tool_name" "Forbidden construct: source in command."
    fi
    if printf '%s' "$command" | grep -qE '(^|[[:space:];&|])\.([[:space:]/~]|$)' ; then
        deny "$tool_name" "Forbidden construct: dot-source in command."
    fi

    # Tokenize and allowlist-check each segment
    result=$(printf '%s' "$command" | awk -f "$dir/lib/tokenize-bash.awk")
    if [[ "$result" != "OK" ]]; then
        deny "$tool_name" "$result"
    fi

    exit 0
fi

# ── everything else (Read, Grep, Glob, NotebookRead, …) ──────────────────────
deny "$tool_name"
