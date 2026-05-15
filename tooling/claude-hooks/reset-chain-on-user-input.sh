#!/usr/bin/env bash
# UserPromptSubmit hook. Resets the main-session tool-chain counter at
# every new user turn. Each prompt is a fresh task with its own budget;
# carrying chain count across user inputs would penalize the model for
# work the user already approved.
#
# Companion to block-mainsession-exploration.sh.

set -euo pipefail

input=$(cat)
flat=$(printf '%s' "$input" | tr '\n' ' ')

session_id=$(printf '%s' "$flat" | sed -nE 's/.*"session_id"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/p' | head -1)
[ -z "$session_id" ] && exit 0

state_dir="${CLAUDE_HOOK_STATE_DIR:-/tmp/claude-state}"
mkdir -p "$state_dir"
echo 0 > "$state_dir/$session_id.counter"
# Mark this session as "main" — UserPromptSubmit fires only for main
# sessions, so the marker's existence is the signal the PreToolUse hook
# uses to distinguish main from subagent.
touch "$state_dir/$session_id.main"
