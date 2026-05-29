# ADR-0015: The main Claude session is an orchestrator; all exploration and implementation delegates to subagents

- Status: Accepted
- Date: 2026-05-29

**Context.** Working in a multi-repo docs/ecosystem context with Claude Code, a model was needed for how the main session operates: do the work directly in the main context, or restrict the main session and delegate. The risks were large context pollution and uncontrolled edits. Delegation had already become ambient, but during the Normalize CLI architecture session (Mar 14) it crystallized into an explicit philosophy: the user spawned 10+ subagent audits/rewrites and refused to do the work in the main session, articulating a cognitive-load / separation-of-concerns rationale rather than a speed one.

**Decision.** The main session is an orchestrator that identifies problems and designs solutions; implementation and exploration always belong to fresh subagents with a narrow brief. The orchestrator is restricted to Agent/Task/AskUserQuestion/plan-mode/ScheduleWakeup plus four git commands (commit, push, status, log --oneline). All Read/Grep/Glob/Edit/Write and other Bash must delegate to subagents, enforced by a hook. Inline implementation in the orchestrating session is forbidden because it pollutes the design context — delegation is justified by separation of concerns, not merely throughput.

**Alternatives rejected.**
- *Let the main session read, search, and edit files directly* — Pollutes main context and bypasses the controlled delegation model; the hook treats any direct tool call as a prompting failure rather than acceptable behavior.
- *Implement inline in the main/design session, dispatching only when it is faster* — "Doing it inline poisons context" — mixing implementation into the design session degrades the orchestrator's reasoning. The prior throughput-only rationale ("dispatch because it's faster") was superseded by separation of concerns ("dispatch because the architecture of work demands it").

**Consequences.** All exploration and file modification happens in subagents; the main session never holds file contents directly and is restricted to problem-identification and solution-design. A hook enforces the boundary. Subagents start fresh and commit their own work. This is encoded in the ecosystem's delegation model and propagated across repos (reincarnate, normalize, parents, ascent-interpreter). Open: managing the maintenance burden of dense delegation workflows. Mined from: /home/me/git/rhizone/github-io/CLAUDE.md (87), /home/me/git/rhizone/github-io/CLAUDE.md (130), /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-mar10-mar16.md (56), /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-mar10-mar16.md (59).
