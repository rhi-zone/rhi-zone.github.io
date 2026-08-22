# claude-hooks/

Behavioral hook scripts for the Claude Code harness, propagated to every
ecosystem repo by `tooling/propagate-harness.sh` and wired into
`.claude/settings.json`. They enforce the main-session-as-orchestrator model and
record session history. All shells are jq/python/node-free by design (the
harness does not always have those on PATH; on NixOS-from-flake setups they live
only in the project devshell).

- `inject-orchestrator-rules.sh` — UserPromptSubmit hook. In the main session it
  emits `orchestrator-rules.md` as additionalContext; in a subagent (detected via
  a top-level `agent_id` in the hook JSON) it exits silently.
- `post-history.sh` — UserPromptSubmit hook. Records session history;
  self-contained, with an inlined copy of the subagent detector.
- `block-blocking-bash.sh` — PreToolUse(Bash) hook. Denies commands that never
  return on their own (follow/stream/watch) and would hang the session until
  timeout; `run_in_background:true` is the sanctioned escape hatch.
- `block-runaway-find.sh` — PreToolUse(Bash) hook. Denies `find` invocations
  rooted at a handful of known-enormous or virtual paths (`/`, `/nix/store`,
  `/proc`, `/sys`, `/root`, `/usr`, bare `/home`/`$HOME`/`~`) that reproducibly
  hang a Bash call for the full timeout walking a tree with tens of thousands
  of entries — `-maxdepth` does not reliably save these roots, so it blocks on
  the root path itself rather than trusting bounding flags.
- `block-mainsession-exploration.sh` — PreToolUse hook. Enforces that the main
  session is a pure orchestrator: only an allow-listed set of git verbs
  (commit/push/status/log) may run as Bash; subagents (top-level `agent_id`)
  bypass. Parses the payload via bash parameter expansion and the `lib/` awk
  scripts.
- `subagent-decomposition-check.sh` — SubagentStart hook. Prompts the subagent
  to reason through whether its task can be produced correctly in one pass
  before acting, ensuring thoughtful decomposition of multi-step work.
- `inject-subagent-context-agent.sh` — PreToolUse(Agent|SendMessage) hook.
  Splices `style-rules.md` + `subagent-role-note.md` onto the end of the
  outgoing `prompt`/`message` field via `updatedInput`, so subagents (and
  anyone messaged via SendMessage) get that context. Replaces a prior
  SubagentStart-based approach for the role note that never worked —
  SubagentStart doesn't support additionalContext at all; see the header
  comment in this script for the full mechanism writeup.
- `orchestrator-rules.md` — the rules text injected into the main session by
  `inject-orchestrator-rules.sh`.
- `subagent-role-note.md` — short "you are a subagent" note spliced into
  subagent-bound prompts/messages by `inject-subagent-context-agent.sh`.
- `orchestrator-workflows.md` — lessons that apply when running a Workflow in the
  main session; read before running one.
- `lib/agent-id.sh` — canonical `is_subagent <json>` subagent detector (pure
  bash + sed/tr). Sourced by `inject-orchestrator-rules.sh`.
- `lib/extract-command.awk` — extracts the `tool_input.command` string from the
  harness JSON for `block-mainsession-exploration.sh`.
- `lib/tokenize-bash.awk` — splits a decoded bash command into quote-aware
  segments and checks each against the git-verb allowlist.
