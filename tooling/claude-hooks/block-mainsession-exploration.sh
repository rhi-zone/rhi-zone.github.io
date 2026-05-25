#!/usr/bin/env bash
# PreToolUse hook. Main session is a pure orchestrator: it delegates all
# content-ingestion and implementation to subagents. Allowing Read/Grep/Glob
# or unrestricted Bash in the main session defeats that model — once raw file
# content or command output enters the main context window, it lingers for the
# entire session lifetime and shapes every downstream token.
#
# Architecture: Bash outer shell reads stdin (capped at 1 MiB), pipes to a
# Python heredoc for structural JSON parsing. All decisions are made in Python
# using json.loads(); no regex scanning of flattened JSON strings.
#
# Subagent detection: top-level "agent_id" field present and non-empty string.
# Substring grep on flattened JSON was bypassable by embedding "agent_id" in a
# command string; structural extraction is not.
#
# tool_name extraction: json["tool_name"] at top level. Greedy sed on flattened
# JSON would pick the last occurrence, which could be inside a Bash command.
#
# Bash allowlist: every semicolon/&&/||/pipe/newline-separated segment must
# start with an allowed (verb, subverb, ...) tuple. Setting allowed=1 on any
# match was bypassable by prefixing an allowed command before an arbitrary one.
#
# Forbidden substrings in Bash commands: $(...), backticks, ${, eval, source,
# dot-source — these embed arbitrary execution that can't be statically analyzed.
#
# Denial JSON: built with json.dumps() not string interpolation, so quotes,
# backslashes, control chars, and newlines in tool input cannot break the JSON.
#
# Debug log: gated behind CLAUDE_HOOK_DEBUG=1; chmod 600 on creation to prevent
# world-readable exposure of hook inputs (which may contain secrets).
#
# Large-input guard: stdin capped at 1 MiB via `head -c`. Claude tool inputs
# are never this large in practice; if they are, fail open — the hook is not
# the right defense for oversized payloads.

set -euo pipefail

input=$(head -c $((1024 * 1024)))

# Locate python3. On NixOS without a system python, fall back to nix-shell.
# We write the script to a temp file so the heredoc passes source code while
# stdin carries the hook input regardless of which Python invoker is used.
_py_script=$(mktemp /tmp/claude-hook-XXXXXX.py)
trap 'rm -f "$_py_script"' EXIT

cat > "$_py_script" <<'PYEOF'
import sys
import os
import json
import re

raw = sys.stdin.read()

# ── debug log ──────────────────────────────────────────────────────────────
if os.environ.get("CLAUDE_HOOK_DEBUG") == "1":
    state_dir = os.environ.get("CLAUDE_HOOK_STATE_DIR", "/tmp/claude-state")
    os.makedirs(state_dir, exist_ok=True)
    debug_log = os.path.join(state_dir, "hook-input.debug.log")
    import datetime
    with open(debug_log, "a") as f:
        f.write(f"\n=== {datetime.datetime.now().isoformat()} ===\n")
        f.write(raw)
        f.write("\n")
    os.chmod(debug_log, 0o600)

# ── denial helper ──────────────────────────────────────────────────────────
DENY_MSG = (
    "Main session is read-only orchestrator. Denied tool: {tool}. "
    "Allowed in main: Agent/Task*/AskUserQuestion/EnterPlanMode/ExitPlanMode/"
    "ToolSearch/ScheduleWakeup; Bash limited to `git commit`, `git push`, "
    "`git status`, `git log --oneline` (no chaining, no command substitution, "
    "no eval/source). Delegate everything else to a subagent via Agent "
    "(sonnet for mechanical/exploration, opus for architectural)."
)

def deny(tool_name, extra=""):
    reason = DENY_MSG.format(tool=tool_name)
    if extra:
        reason += "\n" + extra
    output = {
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": reason,
        }
    }
    print(json.dumps(output))
    sys.exit(0)

# ── parse input ────────────────────────────────────────────────────────────
try:
    data = json.loads(raw)
except (json.JSONDecodeError, ValueError):
    sys.exit(0)  # malformed — fail open

if not isinstance(data, dict):
    sys.exit(0)

tool_name = data.get("tool_name")
if not tool_name or not isinstance(tool_name, str):
    sys.exit(0)  # no tool_name — fail open

# ── subagent check (structural, not substring) ─────────────────────────────
agent_id = data.get("agent_id")
if agent_id and isinstance(agent_id, str):
    sys.exit(0)  # subagent — pass unconditionally

# ── orchestration tools (always allowed) ──────────────────────────────────
ALLOW_TOOLS = {
    "Agent", "Task", "TaskCreate", "TaskUpdate", "TaskList",
    "TaskGet", "TaskOutput", "TaskStop",
    "AskUserQuestion", "EnterPlanMode", "ExitPlanMode",
    "ToolSearch", "ScheduleWakeup",
}
if tool_name in ALLOW_TOOLS:
    sys.exit(0)

# ── mutation tools (never allowed in main) ─────────────────────────────────
if tool_name in ("Edit", "Write", "NotebookEdit"):
    deny(tool_name)

# ── Bash (limited allowlist) ───────────────────────────────────────────────
if tool_name == "Bash":
    tool_input = data.get("tool_input")
    if not isinstance(tool_input, dict):
        deny(tool_name)

    command = tool_input.get("command")
    if not isinstance(command, str):
        deny(tool_name)

    # Reject constructs that embed arbitrary execution and cannot be statically
    # analyzed by token inspection.
    FORBIDDEN_SUBSTRINGS = [
        "$(",    # command substitution
        "`",     # backtick command substitution
        "${",    # variable expansion that can embed subcommands
        " eval ", " source ", " . /", " . ~",
        "\teval", "\tsource",
    ]
    stripped_start = command.lstrip()
    if (
        stripped_start.startswith("eval ")
        or stripped_start.startswith("source ")
        or stripped_start.startswith(". ")
    ):
        deny(tool_name, f"Rejected command (first 200 chars): {command[:200]}")

    for forbidden in FORBIDDEN_SUBSTRINGS:
        if forbidden in command:
            deny(tool_name, f"Rejected command (first 200 chars): {command[:200]}")

    # Split on unquoted separators. We do a strict character-level split
    # (no quote-awareness) — any use of these operators in the command is
    # caught here; legitimate git invocations never need chaining.
    segments = re.split(r"(?:;|&&|\|\||\||\n)", command)

    # Allowed (verb, subverb, ...) tuples. Every non-empty segment must match.
    # git log requires --oneline as the first arg after "log".
    ALLOWED_VERBS = [
        ("git", "commit"),
        ("git", "push"),
        ("git", "status"),
        ("git", "log", "--oneline"),
    ]

    for seg in segments:
        tokens = seg.strip().split()
        if not tokens:
            continue  # empty segment (trailing ; etc.) — allowed
        matched = False
        for verbs in ALLOWED_VERBS:
            if tokens[:len(verbs)] == list(verbs):
                matched = True
                break
        if not matched:
            deny(tool_name, f"Rejected command (first 200 chars): {command[:200]}")

    sys.exit(0)  # all segments passed

# ── everything else (Read, Grep, Glob, NotebookRead, …) ───────────────────
deny(tool_name)
PYEOF

if command -v python3 >/dev/null 2>&1; then
  printf '%s' "$input" | python3 "$_py_script"
else
  printf '%s' "$input" | nix-shell -p python3 --run "python3 $_py_script"
fi
