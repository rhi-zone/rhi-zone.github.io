# ADR-0094: EventLog is the canonical source of truth; state is reconstructed by deterministic replay

- Status: Accepted
- Date: 2026-05-29

**Context.** A simulation substrate must support persistence, debugging, and branching. One option is to treat the current in-memory world state as canonical and snapshot/restore it. defocus instead needed forks and replay to be deterministic.

**Decision.** The append-only EventLog is the canonical source of truth for world state, not just a record. State is reconstructed by deterministically re-dispatching the EventLog against a fresh world (Replay always yields the same world from the same log). Fork creates a branching world by replaying the log up to a chosen index and truncating — Fork goes through replay, not a state snapshot.

**Alternatives rejected.**
- *Treat current in-memory state as canonical; fork by cloning/snapshotting state* — Cloning current state is not the chosen mechanism: forking through replay guarantees the branch is derived from the same deterministic causal record, making replay/fork/persistence consistent. A snapshot clone would diverge from the causal log model.

**Consequences.** Replay must be deterministic — anything nondeterministic (notably LLM calls) must be logged so it can be replayed (LLM outputs are logged for deterministic replay). Fork is implemented as replay-then-truncate rather than state copy. WorldDiff (structural snapshot comparison) is kept deliberately distinct from the EventLog (causal record). Mined from: /home/me/git/rhizone/defocus/CONTEXT.md (87-88), /home/me/git/rhizone/defocus/CONTEXT.md (97-98).
