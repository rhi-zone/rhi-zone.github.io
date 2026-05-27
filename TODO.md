# TODO

Captured at session end. Honest state of what was built, what's pending, what's untested.

## Shipped this session

- Hook rewritten: strict main-session allowlist (Agent/Task*/AskUserQuestion/EnterPlanMode/ExitPlanMode/ToolSearch/ScheduleWakeup/Skill + `git commit/push/status/log --oneline`). Pure shell/awk, no Python.
- CLAUDE.md trimmed; ecosystem-common region demarcated with markers; `propagate-claude-md.sh` propagator built.
- `scaffolding/CLAUDE.md` deleted.
- Canonical region propagated to all 49 rhizone-ecosystem repos.
- PHI hook (`post-history.sh`) installed in all 49 repos via `propagate-post-history.sh` propagator.
- Hook denial message corrected to "orchestrator only" (not "read-only").
- `docs/claude-code-hooks.md` created documenting hook input + output schemas (empirical).

## Pending — design discussed, not built

- **Both-sides adversarial dispatch.** Equal-role subagent pairing where neither side defaults to ship. Not implemented; current adversarial work is single-pass review (which carries asymmetric bias).
- **Strict-checklist verification mechanism.** The one allowed form of LLM decision-making (per session conclusion). No tooling exists for this yet.
- **Custom subagent types.** Discussed: `verifier`, `committer`, `researcher` with locked system prompts. Not built.
- **Filesystem-as-substrate orchestration.** Subagents communicate via work artifacts; main holds no task graph. Current sessions still hold task state in main context.
- **PHI dynamic content.** Current PHI is static; could be keyed off user prompt content, recent transcript patterns, repo type, etc.

## Pending — unknowns / untested

- **PHI effectiveness unknown.** Just shipped to all repos; no data on whether it actually shifts behavior. Should observe across multiple sessions and revise content if patterns recur.
- **Bans coverage unknown.** Mined from existing session corpus; new failure modes may surface that current bans don't catch.
- **Hook handles weird JSON edge cases unknown.** Audit found 4 criticals in earlier python version; current shell/awk version was written more carefully but no fuzz testing.

## Known imperfections

- Custom checklist mechanism not designed → "decisions only via strict checklist" principle is currently aspirational.
- Subagent prompts in main are composed ad-hoc each dispatch — no standardized template for the orchestrator-side prompt scaffolding.
- Adversarial audits worked well this session but were driven by the user, not the system. The friction is still user-maintained.

## Don't forget

- The PHI hook fires per-session; it doesn't replace CLAUDE.md, which still loads at session start.
- Hook script files in each repo are local copies; updating canonical content in github-io requires re-running the propagator across all 49 repos.
- `~/.claude/settings.json` (global) is outside this repo's git tree but holds the block-mainsession-exploration.sh hook reference. Don't lose track of it.
