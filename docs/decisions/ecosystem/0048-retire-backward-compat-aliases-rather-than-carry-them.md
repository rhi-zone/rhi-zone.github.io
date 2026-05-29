# ADR-0048: Retire backward-compat aliases rather than carry them as adoption cost

- Status: Accepted
- Date: 2026-05-29

**Context.** On reaching relative stability (audit clean, version published, usage verified), multiple projects (hologram, unshape) faced whether to keep backward-compatibility aliases or remove them.

**Decision.** Across the ecosystem, backward-compatibility accumulation is treated as technical debt to be retired at stability; when a project stabilizes the posture is to tighten the API surface (remove backcompat aliases) rather than add features.

**Alternatives rejected.**
- *Keep backward-compat aliases to ease adoption* — Backcompat accumulation is treated as technical debt to be retired, not a cost of adoption; the user's stance ('no back compat please') generalized across the ecosystem.

**Consequences.** Projects remove backcompat aliases on stabilization; API surfaces stay narrow; downstream consumers must track current names rather than relying on long-lived aliases. Mined from: /home/me/git/rhizone/github-io/docs/introspection/log/synthesis-mar5-mar9.md (43).
