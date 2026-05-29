# ADR-0148: reincarnate foundational invariants: semantic fidelity and multi-instance coexistence

- Status: Accepted
- Date: 2026-05-29

**Context.** After the bounty game rendered for the first time, debugging exposed architectural issues (globals in IR, derived-vs-stored metadata). Rather than accumulate emergent guidelines, the design paused to encode core laws into reincarnate's CLAUDE.md.

**Decision.** 'Semantic fidelity' and 'multiple game instances must coexist on one page' are elevated to foundational laws (invariants encoded in CLAUDE.md) for reincarnate, rather than emergent guidelines discovered case-by-case.

**Alternatives rejected.**
- *Leave these as emergent guidelines that surface ad hoc during debugging* — Treating them as emergent let architectural violations (globals in the IR, side-channel lookup tables, non-coexisting instances) accumulate; the session chose to reformulate them as foundational invariants so they constrain design up front.

**Consequences.** reincarnate backends must preserve semantic fidelity and support multiple coexisting game instances on one page by construction; this forecloses designs relying on global state in the IR or single-instance assumptions. Later (2026-03-13) reinforced toward 'arbitrary frontend, arbitrary backend, no coupling, best-of-class static analysis.' Mined from: /home/me/git/rhizone/github-io/docs/introspection/log/daily/2026-03-09.md (7).
