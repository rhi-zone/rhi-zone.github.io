# ADR-0045: Handoff plans contain only next tasks, pending items, and relevant session results

- Status: Accepted
- Date: 2026-05-29

**Context.** The handoff plan convention introduced ecosystem-wide days earlier was already causing harm: cross-project session analysis showed striking pushback in crescent and problematic behavior in reincarnate. Plans had grown too comprehensive, carrying context summaries, build steps, and commands that belonged in CLAUDE.md or TODO.md rather than ephemeral handoff documents.

**Decision.** Tighten the handoff plan convention so plans contain only next tasks, pending items, and what-was-done-this-session when directly relevant; everything else lives in versioned files (CLAUDE.md, TODO.md). Applied across 12 repos simultaneously.

**Alternatives rejected.**
- *Keep the original comprehensive handoff plan convention (context summaries, build steps, commands in the plan)* — It was too comprehensive and observed to cause dysfunction within days; that content belonged in versioned files (CLAUDE.md/TODO.md), not in ephemeral handoff documents

**Consequences.** Handoff plans are now minimal and scoped to transient continuity; durable context must live in versioned files. Applied across 12 repos. Establishes that conventions need the same freshness checks as code. Mined from: /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-mar17-mar19.md (11), /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-mar17-mar19.md (27).
