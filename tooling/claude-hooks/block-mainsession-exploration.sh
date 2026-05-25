#!/usr/bin/env bash
# PreToolUse hook. Main session is a pure orchestrator: it delegates all
# content-ingestion and implementation to subagents. Allowing Read/Grep/Glob
# or unrestricted Bash in the main session defeats that model — once raw file
# content or command output enters the main context window, it lingers for the
# entire session lifetime and shapes every downstream token.
#
# Subagents (detected via `agent_id` present in hook input) are the execution
# sandbox and pass unconditionally — the sandbox imposes its own constraints.
#
# Main session allowlist (everything else is denied):
#   - Agent, Task*, AskUserQuestion, EnterPlanMode, ExitPlanMode,
#     ToolSearch, ScheduleWakeup — orchestration primitives.
#   - Edit, Write, NotebookEdit — NEVER allowed in main, no exceptions.
#     Plan files under ~/.claude/plans/ must be written by subagents.
#   - Bash — only git commit/push/status/log --oneline; all other commands
#     are denied (exploration and builds belong in subagents).
#
# Jq-free — the harness doesn't always have jq on PATH outside the project
# devshell.

set -euo pipefail

input=$(cat)
flat=$(printf '%s' "$input" | tr '\n' ' ')

state_dir="${CLAUDE_HOOK_STATE_DIR:-/tmp/claude-state}"
mkdir -p "$state_dir"

# Debug log: every hook invocation appended with timestamp + full input.
# Lets us inspect what fields the harness actually provides for main vs
# subagent calls so we can fix detection. Bounded growth: trim to last
# 2000 lines on each invocation.
debug_log="$state_dir/hook-input.debug.log"
{
  printf '\n=== %s ===\n' "$(date -Iseconds 2>/dev/null || date)"
  printf '%s\n' "$input"
} >> "$debug_log" 2>/dev/null || true
if [ -f "$debug_log" ] && [ "$(wc -l < "$debug_log" 2>/dev/null || echo 0)" -gt 2000 ]; then
  tail -1500 "$debug_log" > "$debug_log.tmp" && mv "$debug_log.tmp" "$debug_log"
fi

tool_name=$(printf '%s' "$flat" | sed -nE 's/.*"tool_name"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/p' | head -1)

# Fail open on malformed input.
if [ -z "$tool_name" ]; then
  exit 0
fi

# Subagents are the execution sandbox; let them through unconditionally.
if printf '%s' "$flat" | grep -qE '"agent_id"[[:space:]]*:[[:space:]]*"'; then
  exit 0
fi

deny() {
  local reason="$1"
  # Escape any embedded double-quotes for valid JSON.
  reason="${reason//\"/\\\"}"
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' "$reason"
  exit 0
}

DENY_PREFIX='Main session is read-only orchestrator. Denied tool:'
DENY_SUFFIX='Delegate to a subagent via Agent (sonnet for mechanical/exploration, opus for architectural). Allowed in main: Agent/Task*/AskUserQuestion/EnterPlanMode/ExitPlanMode/ToolSearch/ScheduleWakeup; Bash limited to git commit/push/status/log --oneline.'

case "$tool_name" in
  # Pure orchestration — always allowed.
  Agent|Task|TaskCreate|TaskUpdate|TaskList|TaskGet|TaskOutput|TaskStop|\
  AskUserQuestion|EnterPlanMode|ExitPlanMode|ToolSearch|ScheduleWakeup)
    exit 0
    ;;

  # Mutation tools — never allowed in main session, no exceptions.
  Edit|Write|NotebookEdit)
    deny "$DENY_PREFIX $tool_name. $DENY_SUFFIX"
    ;;

  # Bash — allowed only for specific git subcommands.
  Bash)
    command=$(printf '%s' "$flat" | sed -nE 's/.*"command"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/p' | head -1)

    # Strip quoted strings and heredoc bodies so embedded text can't smuggle
    # a git keyword past the check (same approach as the git-commit detection
    # in the original script).
    # 1. Remove double-quoted strings.
    # 2. Remove single-quoted strings.
    # 3. Remove heredoc bodies: <<'EOF'...EOF and <<EOF...EOF blocks.
    stripped=$(printf '%s' "$command" \
      | sed -E "s/\"[^\"]*\"//g" \
      | sed -E "s/'[^']*'//g" \
      | sed -E 's/<<['\''"]?[A-Z_a-z0-9]+['\''"]?.*//g')

    # Check each command segment (start-of-string, or after ; && || |).
    # A segment starts with optional whitespace then the verb.
    allowed=0
    # We test each allowed pattern against the stripped command.
    # git commit — any flags/args after
    if printf '%s' "$stripped" | grep -qE '(^|;|&&|\|\||\|)[[:space:]]*git[[:space:]]+commit([[:space:]]|$)'; then
      allowed=1
    fi
    # git push — any flags/args after
    if printf '%s' "$stripped" | grep -qE '(^|;|&&|\|\||\|)[[:space:]]*git[[:space:]]+push([[:space:]]|$)'; then
      allowed=1
    fi
    # git status — any flags/args after
    if printf '%s' "$stripped" | grep -qE '(^|;|&&|\|\||\|)[[:space:]]*git[[:space:]]+status([[:space:]]|$)'; then
      allowed=1
    fi
    # git log --oneline — must include --oneline; bare git log is denied
    if printf '%s' "$stripped" | grep -qE '(^|;|&&|\|\||\|)[[:space:]]*git[[:space:]]+log[[:space:]].*--oneline'; then
      allowed=1
    fi

    if [ "$allowed" -eq 1 ]; then
      exit 0
    fi

    # Include first 200 chars of the rejected command in the denial message
    # so the user can see why it was blocked.
    short_cmd="${command:0:200}"
    deny "$DENY_PREFIX Bash (rejected command: $short_cmd). $DENY_SUFFIX"
    ;;

  # Everything else (Read, Grep, Glob, NotebookRead, unrecognized tools) — deny.
  *)
    deny "$DENY_PREFIX $tool_name. $DENY_SUFFIX"
    ;;
esac
