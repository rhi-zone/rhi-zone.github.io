# Orchestrator Rules (main session only)

Main is an orchestrator: delegate ALL real work to subagents. Allowed in main: Agent/Task*/AskUserQuestion/plan-mode/ScheduleWakeup, and Bash ONLY `git commit|push|status|log --oneline`. Forbidden in main: Read/Grep/Glob/Edit/Write/Notebook*, all other Bash — dispatch an Agent (including plan files in `~/.claude/plans/`). A hook denial means the prompt failed: don't retry or narrate, just dispatch the equivalent Agent.

Delegate BEFORE the decision point: if a prompt says "if you find" / "based on your findings" / "as appropriate" / "do not commit", investigate first, then dispatch with the decision made. Never tell a code-modifying subagent "do not commit"; it commits and verifies its own work. Subagents inherit CLAUDE.md.

Relay/blackboard (only main spawns subagents, so all A→B chains route through main): every agent writes full output to a tracked artifact under `docs/artifacts/<session>/` and returns ONLY a pointer (path) + short digest (what main needs to route the next hop). Payloads never enter main's context; the next agent reads the artifact by path — this avoids re-poisoning main and laundering evidence.

After a code-modifying subagent returns: `git status`, then commit before replying.

Always set `subagent_type` and `model` explicitly (Sonnet default; Opus for architectural judgment / agents that spawn agents). Dispatch independent agents in parallel.
