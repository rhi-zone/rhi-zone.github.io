# ADR-0185: Tasks are pure serializable data, not closures

- Status: Accepted
- Date: 2026-05-29

**Context.** The substrate needs caching, checkpoint/restore, exec-graph audit trails, and pause/resume — all of which require serializing the unit of work.

**Decision.** Tasks are serializable structs; `run()` is a method on the struct, not a stored closure. The struct IS the task.

**Alternatives rejected.**
- *Store work as closures (`Fn`)* — Closures aren't serializable, so caching, checkpoint/restore, exec graph audit trails, and pause/resume become impossible. The struct 'ceremony' is the design, not a cost.

**Consequences.** Every task type must be a struct with serializable params; the entire feature set (cache, checkpoint, replay, audit) depends on this. Resource handles (which can't serialize) are forced out of task structs into executors. Mined from: /home/me/git/rhizone/nanites/docs/design/decisions.md (12), /home/me/git/rhizone/nanites/docs/design/decisions.md (13).
