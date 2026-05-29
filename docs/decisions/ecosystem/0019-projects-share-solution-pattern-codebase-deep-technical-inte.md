# ADR-0019: Projects share a solution pattern, not a codebase; no deep technical integration

- Status: Accepted
- Date: 2026-05-29

**Context.** The ecosystem comprises many tools across different domains. A foundational architectural choice was whether to build a deeply integrated, mutually-dependent platform or independent tools that merely share an approach.

**Decision.** Projects are independent tools that unify their own domains and compose only when useful; they share a solution pattern (find the abstraction, unify the domain), not a codebase. No vendor lock-in, no required adoption of the whole stack.

**Alternatives rejected.**
- *Build a deeply integrated technical ecosystem where projects depend on each other* — Each project unifies its own domain and needs no deep coupling; integration is opt-in, and a tightly-coupled platform would create both exit and entry friction (lock-in).

**Consequences.** Cross-project dependencies are minimal and opt-in (a few library/runtime integrations); each tool must be usable standalone. Reinforced by the no-path-dependencies rule. Mined from: /home/me/git/rhizone/github-io/docs/about.md (47), /home/me/git/rhizone/github-io/docs/about.md (169).
