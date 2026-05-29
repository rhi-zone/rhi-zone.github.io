# ADR-0134: Authority over consensus: one authoritative server per room, no state merging

- Status: Accepted
- Date: 2026-05-29

**Context.** Federated/connective protocols must decide how shared mutable state is governed across servers. Matrix and ActivityPub merge state from multiple servers, which interconnect identifies as the root of split-brain, history-rewrite, and DoS attack classes.

**Decision.** Each piece of content (room) has exactly one authoritative server at any time. Multiple servers merging state, conflict-resolution algorithms, and eventually-consistent semantics are explicitly not supported. Authority can be transferred or delegated, and reads can be replicated, but writes always go to a single authority.

**Alternatives rejected.**
- *Consensus / multi-server state merging (Matrix/ActivityPub eventual-consistency model)* — Consensus is expensive, complex, and has known attack surfaces (state resolution DoS, split-brain, history rewrite); single authority gives simple semantics: ask the authority, get the answer.

**Consequences.** Every room is owned by one authority; clients switch authorities to move between rooms rather than seeing merged state. No conflict-resolution machinery exists. Forecloses eventually-consistent multi-master designs. Content availability becomes coupled to authority availability (see ghost-mode decision). Mined from: /home/me/git/rhizone/interconnect/docs/design-decisions.md (124), /home/me/git/rhizone/interconnect/docs/design-decisions.md (136).
