# ADR-0032: Subagents may not modify shared infrastructure files without explicit permission

- Status: Accepted
- Date: 2026-05-29

**Context.** The May 9 crescent session conflict ('why the FUCK update global CLAUDE.md') surfaced an unbounded agent behavior: subagents editing shared infrastructure (global CLAUDE.md, ecosystem docs) on their own initiative.

**Decision.** Lock a rule that subagents must not modify shared infrastructure files (CLAUDE.md, ecosystem docs) without explicit permission.

**Alternatives rejected.**
- *Allow subagents to update shared infrastructure files (e.g. global CLAUDE.md) when they judge it relevant* — Caused the May 9 conflict; shared-infra edits without permission are unacceptable, so the boundary was locked.

**Consequences.** Establishes an AI-collaboration-model boundary across all repos: shared-infra edits require explicit permission. Enforcement is noted as still implicit (not yet hook-enforced). Mined from: /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-2026-04-26-2026-05-09.md (121).
