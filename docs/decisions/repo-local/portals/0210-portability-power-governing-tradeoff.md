# ADR-0210: Portability over power as the governing tradeoff

- Status: Accepted
- Date: 2026-05-29

**Context.** When designing interfaces there is a recurring fork between simpler interfaces that work everywhere and more powerful interfaces that only work on some platforms.

**Decision.** Prefer simpler interfaces that work across all platforms over powerful interfaces that only work on some. When in doubt, leave it out, because it is easier to add than remove.

**Alternatives rejected.**
- *Powerful interfaces that expose platform-specific capability but only work on some platforms* — Sacrifices cross-platform portability, which is the project's core value; and surface added cannot easily be removed later, whereas additions are cheap.

**Consequences.** Feature inclusion is biased toward omission; platform-specific power is excluded from interfaces and pushed to backends. Sets the default tie-breaker for all future interface scoping decisions. Mined from: /home/me/git/rhizone/portals/DESIGN.md (7).
