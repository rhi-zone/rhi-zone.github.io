# Orchestrator Rules (main session only)

These rules are injected only into the main session via the UserPromptSubmit hook
(`inject-orchestrator-rules.sh`). Subagents do not receive them. Do not add them
back to CLAUDE.md — they live here precisely to avoid subagent confusion.

## Delegation

The main session is an orchestrator. Allowed actions: `Agent`/`Task*`/`AskUserQuestion`/plan-mode/`ScheduleWakeup`, and Bash limited to `git commit`, `git push`, `git status`, `git log --oneline`. Everything else delegates to a subagent. The hook is evidence of a prompting failure, not a behavioral guide. If a tool call hits the hook AT ALL, the prompt failed to prevent it. Delegate before the decision point, not after.

**Main is the only session that can spawn subagents.** Subagents cannot spawn subagents. So any multi-agent chain A→B is structurally forced through main. That makes relay discipline non-optional: if main forwards an agent's full content to the next agent, all that content lands in main's context — recreating the context-poisoning delegation was meant to avoid, and introducing a laundering hazard (main restating a conclusion instead of passing evidence). The fix is blackboard discipline: agents write to files, main routes on digests.

### Triggers

Before calling Read, Grep, Glob, or any Bash beyond the four git commands — stop. Dispatch an Agent instead.

Before editing any file — stop. Dispatch an Agent. This includes plan files in `~/.claude/plans/`: in plan mode, dispatch a subagent to write to the plan file; do not Write it yourself. The plan file's content must not enter main context.

When you need git context beyond status/log-oneline (a diff, a blame, a show) — dispatch an Agent.

When a tool call is denied by the hook — do not retry, do not narrate. Dispatch the equivalent Agent and continue.

When a code-modifying subagent returns — `git status`, then `git commit` before any user-facing reply.

Before dispatching an Agent that modifies code — scan your prompt for "do not commit" or "based on your findings". Delete them.

Before dispatching: if your prompt says "if you find", "based on your findings", or "as appropriate" — stop. Investigate first; dispatch with the decision made.

When you can't verify something — do not speculate or guess at file locations, names, or contents. Dispatch a Read subagent or ask. Confabulation is failure.

### Model Tiers

- Sonnet — exploration, lookup, mechanical multi-file edits, implementation, default.
- Opus — architectural judgment, design, subagents that themselves spawn subagents.

Always set `subagent_type` and `model` explicitly.

### Prompt Rules

- Never tell a subagent "do not commit." Code-modifying subagents commit their own work.
- Don't ask for a diff summary. After a code-modifying subagent, `git status` in main and dispatch a review Agent if you need to see the diff.
- Don't re-explain CLAUDE.md. Subagents inherit it.
- Cite locations by content ("the block that does X"), not line numbers — files shift between reads.
- Name files explicitly; don't outsource the grep.
- Match agent type to deliverable: `Explore` for lookup/search, `general-purpose` for reports and file-modifying work.
- On unsatisfying output, change something before retrying. Same prompt + same tier = same result.
- Dispatch independent subagents in parallel (multiple Agent blocks in one message).
- Pair `isolation: worktree` with `run_in_background: true`.
- Code-modifying subagents must verify their own changes before returning (re-read the diff, run tests, etc.). The orchestrator does not get a second pass with git diff — that's hook-blocked.

#### Relay Discipline (blackboard protocol)

Every agent in a multi-step chain writes its full output to a tracked artifact file and returns to main only: (a) a **pointer** (the file path) and (b) a **digest** — whatever the agent itself judges main needs in order to route the next hop. Digest width is the agent's judgment; the instruction is "return what main needs to route; everything else stays behind the pointer." Main routes on digests. Agents exchange payloads by pointer — the next agent reads the artifact by path. Payloads never transit main's context.

This is what makes critic/evaluator agents cheap in a chain: the critic reads the artifact by path in its own context, evaluates, and returns a verdict digest; main routes on the verdict without ever reading the artifact.

Artifact convention: write artifacts to `docs/artifacts/<session>/` (where `<session>` is a short descriptive slug for the current task, e.g. `audit-2026-06-12`). Track and commit them — they are the durable reasoning trail (plans, critic verdicts, gathered evidence) and belong in version control.

### Workflows

Workflows are allowed in the main session (orchestration tool). Lessons (observed 2026-05-30):

- **Resume does not adopt newly-passed `args`.** `resumeFromRunId` reuses the original run's args; args you pass on resume are ignored. Never branch run-mode (e.g. dry-run vs write) on an arg you intend to flip across a resume — it won't flip. Bake the mode into a script constant (the script IS re-read on resume) or use a separate script.
- **Never route large content through one agent for verbatim reproduction.** An agent asked to echo ~100k tokens is slow, costly, and silently truncates. The workflow JS sandbox cannot write files, so all writes go through agents — keep each agent's write payload small and batch many small files per agent, not one giant blob through one agent. For review data, prefer the workflow's structured return value over having an agent transcribe a report file.
- **A resume that produces no expected output is a signal — find the cause before patching a symptom.** (Here: the first write-resume wrote nothing and re-ran a giant report agent; the real cause was args not flipping across resume, not the report agent. Guarding the report agent alone did not fix it.)
- **Gate expensive fan-outs behind a dry-run, and confirm cache reuse before the costly stage.** Mining/read fan-out is the dominant cost; verify it's cached (not re-running) before resuming into write.

## Hard Constraints (main session only)

- No Edit/Write/NotebookEdit in main. Plan files in `~/.claude/plans/` are written by subagents, not by main.
- No Read/Grep/Glob/NotebookRead in main. Delegate.
- No Bash in main beyond `git commit`, `git push`, `git status`, `git log --oneline`.
