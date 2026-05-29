# ADR-0201: Executor abstraction: resource management as pluggable policy, core stays pure

- Status: Accepted
- Date: 2026-05-29

**Context.** Execution was hardcoded sequential in the CLI. Adding parallelism, streaming, and memory budgets risked polluting the pure core (converters + planner). Concrete failure cases: 100 large images × 8 threads = OOM; 1-hour audio = 635MB; batch dirs run sequentially.

**Decision.** Extract execution behind an Executor trait with an ExecutionContext (memory_limit, parallelism). Core (Registry, Converters, Planner) stays pure; execution policy is pluggable via SimpleExecutor, BoundedExecutor, ParallelExecutor (rayon + memory semaphore/backpressure), and a future StreamingExecutor.

**Alternatives rejected.**
- *Keep execution (parallelism/memory/streaming) in the CLI / baked into core* — These resource concerns would pollute the pure core and the Converter trait; the abstraction keeps the core unchanged and lets different contexts (CLI vs server vs embedded) pick a policy

**Consequences.** Converter trait stays simple, CLI selects an executor by flags, and a memory budget prevents OOM in batch processing with a path to streaming without redesigning converters. Cost: an extra abstraction layer and heuristic size estimation; true streaming still needs per-converter changes (deferred to a future ADR). Mined from: /home/me/git/rhizone/paraphase/docs/architecture-decisions.md (740), /home/me/git/rhizone/paraphase/docs/architecture-decisions.md (737).
