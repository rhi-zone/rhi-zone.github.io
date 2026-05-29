# ADR-0183: Control flow is the graph — no explicit Graph construction API

- Status: Accepted
- Date: 2026-05-29

**Context.** Most graph frameworks expect an upfront graph built via add_node/connect, but real task decomposition is discovered dynamically as work proceeds.

**Decision.** There is no explicit `Graph` struct with `add_node`/`connect`. The task graph is constructed dynamically via `ctx.spawn`; parent-child relationships are recorded automatically.

**Alternatives rejected.**
- *Explicit graph-construction framework (add_node/connect)* — Graphs known upfront are either trivial or fictional; explicit construction forces you to lie about what you know upfront. Real decomposition is dynamic.

**Consequences.** Consumers express decomposition imperatively through ctx.spawn; the lineage graph is a byproduct of execution rather than a declared structure. 'Not a graph framework' becomes a defining non-goal. Mined from: /home/me/git/rhizone/nanites/docs/design/decisions.md (27), /home/me/git/rhizone/nanites/docs/design/decisions.md (29).
