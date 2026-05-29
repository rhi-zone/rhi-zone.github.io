# ADR-0191: Sparse fetch via git's own mechanisms plus optional metadata filtering

- Status: Accepted
- Date: 2026-05-29

**Context.** A guiding principle is that you don't need the whole world locally, only what you're building on. The design had to decide how to implement sparseness, and whether metadata filtering should be limited to a fixed scheme like tags.

**Decision.** Expose git's sparse mechanisms plus optional metadata filtering (tags etc.), explicitly not limited to tags.

**Alternatives rejected.**
- *Restrict sparse/metadata filtering to a fixed tag-based scheme* — Limiting to tags would constrain how worlds partition content; the design keeps filtering open-ended (tags are one example, not the limit) and leans on git's existing sparse machinery rather than a bespoke one.

**Consequences.** Sparse fetch reuses git's sparse-checkout/partial-clone facilities; metadata filtering is an open category. Implementation lists 'metadata filtering for sparse fetch' as a task. Mined from: /home/me/git/exoplace/noncanon/TODO.md (9).
