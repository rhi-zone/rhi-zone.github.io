# ADR-0037: Tiered model delegation: Haiku for mechanical work, main agent for architecture

- Status: Accepted
- Date: 2026-05-29

**Context.** By early February the developer was routinely running 10+ concurrent Claude Code sessions across projects, creating a question of how to allocate cognitive load across model tiers rather than running everything on one tier.

**Decision.** Establish a deliberate division of labor where mechanical work (batch comparisons, name mappings, documentation) is delegated to Haiku subagents while the main agent handles architecture and design.

**Alternatives rejected.**
- *Ad-hoc multitasking / single-tier execution* — The synthesis explicitly contrasts the chosen model against ad-hoc multitasking: it is 'a deliberate division of labor where different model tiers handle different cognitive loads,' and cost data confirmed this division is efficient.

**Consequences.** Model-tier selection by cognitive load is now a standing collaboration-model convention (mirrored in the current CLAUDE.md Model Tiers section: Sonnet for exploration/mechanical, Opus for architectural judgment). Cache-warming across parallel similar-codebase sessions becomes an emergent efficiency. Mined from: /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-jan28-mar2.md (33).
