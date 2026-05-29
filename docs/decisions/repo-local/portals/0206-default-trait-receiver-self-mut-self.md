# ADR-0206: Default trait receiver is &self, not &mut self

- Status: Accepted
- Date: 2026-05-29

**Context.** Trait methods can take &self or &mut self; &mut self limits callers (no shared access) but some implementations genuinely need mutable state.

**Decision.** Default to &self unless an implementation would definitely need mutable state; most impls can use interior mutability (RwLock, etc.). When &mut self is used, an ADR must document why.

**Alternatives rejected.**
- *Use &mut self by default for trait methods* — Most implementations can use interior mutability, so &mut self would unnecessarily constrain callers; &mut self is reserved for cases that definitely need mutation (e.g. PRNGs).

**Consequences.** Trait signatures favor &self; implementations carry the burden of interior mutability. Each &mut self exception requires an accompanying ADR. Mined from: /home/me/git/rhizone/portals/DESIGN.md (183), /home/me/git/rhizone/portals/DESIGN.md (195).
