# ADR-0077: World pack action language is declarative when/do, not Turing-complete scripting

- Status: Accepted
- Date: 2026-05-29

**Context.** Actions (verbs like move, take, wear) need to be expressed in world packs. A scripting approach would let pack authors write arbitrary behavior, but world packs must be serializable, diffable, replayable, and safe to load from untrusted sources.

**Decision.** Actions are defined in a constrained declarative language: pure-predicate preconditions ('when', JSONLogic, no side effects) and a constrained patch language for effects ('do': addEdge, removeEdge, set, emit). No arbitrary computation, no loops, conditionals, or variable binding beyond the action's parameters. Actions are compressed graph mutations, not arbitrary behavior.

**Alternatives rejected.**
- *Turing-complete scripting for actions/behavior* — The design constraints explicitly forbid it ('World packs are declarative. No Turing-complete scripting.'); scripting would break serializability/diffability/replayability and the property that actions are just named bundles of graph ops

**Consequences.** Pack authors can only express graph mutations, not programs. World packs stay pure data (serializable, transmittable, diffable, replayable). Effects are limited to the four ops. Rules/fields remain unimplemented but must follow the same declarative discipline. Mined from: /home/me/git/exoplace/aspect/docs/design/world-packs.md (71), /home/me/git/exoplace/aspect/docs/design/architecture.md (88).
