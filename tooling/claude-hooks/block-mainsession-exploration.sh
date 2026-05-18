#!/usr/bin/env bash
# PreToolUse hook. In the main session, blocks tool chains beyond a threshold
# of consecutive calls without either a commit or a subagent delegation. The
# pattern this catches:
#   - Chain of singly-justified Reads/Greps (exploration in disguise)
#   - Chain of Edits/Writes to the same artifact (bandaiding)
#   - Chain of Bashes inspecting output (investigation)
#
# Every tool call increments the counter. Resets on:
#   - `git commit` (detected by parsing the Bash command) — durable work shipped
#   - `Agent` invocation — delegation; the orchestrator handed exploration off
#
# Subagents are exempt: they're the sandbox for chains and are detected via
# a registry populated by subagent-register.sh on SubagentStart.
#
# Threshold (consecutive uncommitted/undelegated tool calls allowed) is
# configurable via CLAUDE_MAINSESSION_CHAIN_THRESHOLD; default 2. A coherent
# unit of work — edit one file, optionally test, commit — fits in 2 calls
# before the commit resets. Anything longer is either a bandaid chain,
# investigation, or batch-edit work that should be delegated. Bump via env
# var when a legitimate multi-file batch genuinely needs the headroom.
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

session_id=$(printf '%s' "$flat" | sed -nE 's/.*"session_id"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/p' | head -1)
tool_name=$(printf '%s' "$flat" | sed -nE 's/.*"tool_name"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/p' | head -1)

# Fail open on malformed input.
if [ -z "$session_id" ] || [ -z "$tool_name" ]; then
  exit 0
fi

# Coordination/UI tools are exempt: they neither explore nor bandaid, so
# they should not burn the chain budget and must not be blocked by it.
case "$tool_name" in
  AskUserQuestion|EnterPlanMode|ExitPlanMode)
    exit 0
    ;;
esac

# Subagent detection: subagent tool calls carry an `agent_id` field;
# main-session calls do not. session_id is inherited from the parent, so
# session_id alone can't distinguish — but agent_id is unambiguous.
# Verified against the hook input debug log.
if printf '%s' "$flat" | grep -qE '"agent_id"[[:space:]]*:[[:space:]]*"'; then
  exit 0
fi

counter_file="$state_dir/$session_id.counter"

# Reset conditions: delegation-shape tools (Agent, Plan, Task, TaskCreate)
# or `git commit` (durable work). The Claude Code UI sometimes renders an
# Agent call with subagent_type="Plan" as `Plan(...)` — depending on the
# harness version the underlying tool name may be "Agent" or "Plan", so
# match both. Same for Task / TaskCreate variants.
case "$tool_name" in
  Agent|Plan|Task|TaskCreate)
    echo 0 > "$counter_file"
    exit 0
    ;;
esac

if [ "$tool_name" = "Bash" ]; then
  # Strip quoted strings from the command before pattern-checking, so
  # `echo "git commit"` inside a script doesn't count as a reset.
  cmd=$(printf '%s' "$flat" | sed -nE 's/.*"command"[[:space:]]*:[[:space:]]*"((\\\\|\\"|[^"])*)".*/\1/p' | head -1)
  scan=$(printf '%s' "$cmd" \
    | sed -E "s/<<-?[[:space:]]*'?[A-Za-z_][A-Za-z0-9_]*'?.*$//" \
    | sed -E 's/"[^"]*"//g' \
    | sed -E "s/'[^']*'//g")

  if printf '%s' "$scan" | grep -qE '(^|[[:space:];&|])git[[:space:]]+commit\b'; then
    echo 0 > "$counter_file"
    exit 0
  fi
fi

# All other tool calls increment the counter.
counter=$(cat "$counter_file" 2>/dev/null || echo 0)
counter=$((counter + 1))
echo "$counter" > "$counter_file"

threshold="${CLAUDE_MAINSESSION_CHAIN_THRESHOLD:-3}"
if [ "$counter" -gt "$threshold" ]; then
  reason=$(printf 'Refused: %d consecutive tool calls in the main session without a reset (threshold: %d). Long uncommitted chains are the failure pattern this hook catches — chained Reads/Greps are exploration in disguise, repeated Edits to the same file are bandaiding, repeated Bashes inspecting output are investigation. All three poison main-session context. The counter resets on any of: (1) a successful `git commit` (durable work shipped), (2) an `Agent` tool call (exploration delegated to a subagent whose context stays separate), (3) the next user prompt (new task, fresh budget). Pick one. If the work you are doing genuinely needs more than %d uncommitted calls, spawn a subagent to do it; the subagent has its own threshold-free context, returns a distilled summary, and you act on the summary in a single Edit/Write.' "$counter" "$threshold" "$threshold")
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' "$reason"
fi
exit 0
