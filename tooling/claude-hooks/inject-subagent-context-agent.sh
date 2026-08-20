#!/usr/bin/env bash
# PreToolUse hook for Agent (spawn only). Appends subagent-only context
# (style-rules.md + subagent-role-note.md, in that order) to the end of the
# outgoing prompt field, so a newly spawned subagent gets that context
# alongside its actual task.
#
# Agent-only, not Agent+SendMessage: SendMessage talks to an ALREADY-RUNNING
# agent, which already got this block once at spawn (via this same hook, or
# via UserPromptSubmit for a top-level session). Splicing it onto every
# SendMessage call as well means a long-lived agent re-accumulates a fresh
# copy of both notes in its context on every single turn someone messages
# it — pure stacking waste, not "safety" (there is no missed-injection risk
# to guard against: an agent that exists already received its copy). So the
# injection surface is deliberately narrowed to the spawn point only, both
# here in the case statement and in settings.json's matcher (belt and
# suspenders — the matcher keeps the hook from even running on SendMessage,
# the case statement keeps it inert if some caller ever widens the matcher
# again).
#
# Why this mechanism, not SubagentStart (history/rationale):
# subagent-role-note.sh used to be wired as a SubagentStart hook that just
# `cat`'d plain prose to stdout. That never worked: SubagentStart does NOT
# support additionalContext at all (confirmed against Claude Code docs/hooks
# reference — "Hooks are guards, not context providers" for this event; its
# only honored outputs are systemMessage [user-facing UI only], terminalSequence,
# continue, stopReason). Plain stdout on SubagentStart is silently discarded —
# the note never reached any subagent's model context.
#
# UserPromptSubmit (used by inject-style-rules.sh / inject-orchestrator-rules.sh
# for the MAIN session) was considered and rejected here: whether it even fires
# for a subagent's own initial prompt is undocumented, and — more importantly —
# it's the wrong differentiator anyway, since it fires from *inside* the
# subagent's own hook execution and can't distinguish "this subagent" from "the
# top-level session" without relying on undocumented agent_id behavior at a
# point docs don't cover.
#
# What DOES work, and is already proven by this file's original style-rules-only
# version: PreToolUse on the Agent tool call fires in the CALLER's context,
# before the subagent starts, and can rewrite tool_input via
#   {"hookSpecificOutput":{"hookEventName":"PreToolUse","updatedInput":{...}}}
# This is documented, supported PreToolUse behavior (not "additionalContext" —
# PreToolUse doesn't support that — but a literal rewrite of the tool call's
# own arguments). Since the Agent tool's `prompt` field IS the literal text
# the new subagent receives, splicing onto it delivers real content into
# exactly the subagent being spawned, and by construction NEVER fires for the
# top-level session's own prompts (those arrive via UserPromptSubmit, a
# different event this hook isn't wired to) — the differentiator we actually
# need falls out of which tool is being called, not out of parsing agent_id
# at all.
#
# Both pieces of subagent-only context are appended in ONE hook, in ONE splice
# pass, rather than as two separate PreToolUse hooks on the same matcher:
# Claude Code runs same-matcher hooks in PARALLEL, not sequentially, and there
# is no documented merging of multiple hooks' updatedInput results for the
# same field — two independent splice hooks here would race/clobber each
# other instead of both landing. One hook, one combined inject string, is the
# only safe way to append more than one piece of content this way.
#
# We always emit the FULL tool_input object (unmodified fields included, only
# the target field changed) rather than a partial object — current docs don't
# state whether updatedInput merges or replaces, so emitting the complete
# object is correct either way.
#
# Jq-free (matches this dir's convention: the harness doesn't always have jq
# on PATH). Unlike the read-only hooks here — which extract a field with
# extract-field.awk to make an allow/deny call, where a parse miss just fails
# open — this one WRITES a new value back into the call. So instead of
# parsing tool_input into pieces and re-serializing it (real risk: mis-escape
# something and corrupt/truncate the payload), we splice: find the exact
# byte offset right before the CLOSING '"' of the target field's value inside
# the ORIGINAL raw tool_input text, and insert the (separately, carefully
# escaped) style-guide text there. Every other byte of tool_input — every
# other field, all original escaping — passes through untouched, because it
# is never parsed or reconstructed, just echoed. See lib/splice-field.awk for
# the splice itself and why its raw-text key matching is safe here.
#
# Inject-once-at-spawn, not inject-on-every-message: this hook used to also
# match SendMessage, on the theory that redundant injection was harmless.
# It isn't — SendMessage targets an ALREADY-RUNNING agent that got this
# block once at spawn, so re-splicing it on every subsequent message stacks
# a fresh copy of both notes into that agent's context on every turn anyone
# talks to it. There's no missed-injection risk to guard against by keeping
# SendMessage in scope (an already-spawned agent already has its copy), so
# the fix is to narrow the injection surface to the spawn point only, not to
# add dedup/tracking state.

set -euo pipefail

dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
style_file="$dir/style-rules.md"
role_note_file="$dir/subagent-role-note.md"

# At least one context file must exist, or there's nothing to inject.
if [ ! -f "$style_file" ] && [ ! -f "$role_note_file" ]; then
  exit 0
fi

input=$(cat)

# ── tool_name (same split + extraction block-mainsession-exploration.sh
# uses: everything before the first "tool_input" occurrence, tool_name read
# only from that prefix) ─────────────────────────────────────────────────────
prefix="${input%%\"tool_input\"*}"

# No "tool_input" key anywhere in the payload — nothing to splice into.
if [ "$prefix" = "$input" ]; then
  exit 0
fi

tool_name=$(printf '%s' "$prefix" | grep -oE '"tool_name"\s*:\s*"[^"]*"' | head -1 | grep -oE '"[^"]*"$' | tr -d '"' || true)

case "$tool_name" in
  Agent) field=prompt ;;
  *) exit 0 ;;
esac

rest="${input#*\"tool_input\":}"

# ── escape a context file's content for splicing into a JSON string ────────
# Same escaper block-mainsession-exploration.sh's deny() uses: backslash,
# quote, tab, CR handled explicitly; source lines joined with a literal \n
# (JSON's own newline escape), trailing \n trimmed.
escape_file() {
    awk '
        {
            gsub(/\\/, "\\\\")
            gsub(/"/, "\\\"")
            gsub(/\t/, "\\t")
            gsub(/\r/, "\\r")
            printf "%s\\n", $0
        }
    ' "$1" | sed '$ s/\\n$//'
}

inject=""
if [ -f "$style_file" ]; then
  inject="${inject}\\n\\n$(escape_file "$style_file")"
fi
if [ -f "$role_note_file" ]; then
  inject="${inject}\\n\\n$(escape_file "$role_note_file")"
fi

# ── splice: insert right before the closing quote of the field's value
# (i.e. append after the original content, separated by a blank line), leave
# every other byte of tool_input untouched. Empty output means the field
# wasn't found as a top-level string value — no-op. ─────────────────────────
spliced=$(FIELD="$field" INJECT="$inject" awk -f "$dir/lib/splice-field.awk" <<< "$rest")

if [ -z "$spliced" ]; then
  exit 0
fi

printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","updatedInput":%s}}\n' "$spliced"
