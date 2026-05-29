# ADR-0144: Existence prose generated offline, no LLM calls during gameplay

- Status: Accepted
- Date: 2026-05-29

**Context.** Designing the sensory-prose system for the existence game, the question arose of how to construct rich, context-sensitive prose at scale rather than hard-coding it. The natural temptations were either hard-coded prose strings or invoking an LLM at runtime for generalization.

**Decision.** Build a deterministic, offline probabilistic compositor (observation sources -> realization engine -> lexical sets -> sentence architectures) as the prose generation mechanism, with offline generation as a hard constraint: no LLM calls during gameplay.

**Alternatives rejected.**
- *Hard-coding prose strings* — Cannot express the contextual variability required (state-, identity-, and sensory-dependent prose); doesn't scale to the content breadth.
- *Calling an LLM at runtime for generalization* — Ruled out by the offline-generation hard constraint (no LLM calls during gameplay); the project deliberately aims to do this without runtime model dependence.

**Consequences.** All sensory/dialogue prose must be producible by a deterministic compositor shipped with the game; observation sources, realization engine, and lexical sets become the build targets. Forecloses runtime LLM dependence for prose. Remaining work (observation sources, multi-observation architectures) was still open at the time. Mined from: /home/me/git/rhizone/github-io/docs/introspection/log/daily/2026-02-20.md (37), /home/me/git/rhizone/github-io/docs/introspection/log/daily/2026-02-20.md (31-33).
