# ADR-0184: Streaming is an executor + UI concern, not a graph primitive

- Status: Accepted
- Date: 2026-05-29

**Context.** Progressive token rendering suggests adding a streaming abstraction to the substrate.

**Decision.** No `StreamingTask` trait and no stream output type in the substrate. Buffered streaming is just `T -> Vec<Chunk>`; per-chunk processing is `Map`; progressive UI rendering is a side channel (mpsc/watch) from executor to UI. The task stays the same `CompletionTask`.

**Alternatives rejected.**
- *Add a StreamingTask trait / stream output type to nanites-core* — Both consumer patterns are already expressible with existing substrate; progressive rendering is a UI side channel, not a graph concern. Adding stream types would put a UI detail into the core.

**Consequences.** Streaming requires no new core types; executors optionally attach a chunk sender configured by the caller, invisible to the task. Keeps nanites-core minimal. Mined from: /home/me/git/rhizone/nanites/docs/design/decisions.md (95), /home/me/git/rhizone/nanites/docs/design/decisions.md (101).
