# ADR-0224: Runtime library bodies are defined once in IR, not per-backend or in source

- Status: Accepted
- Date: 2026-05-29

**Context.** With M frontends and N backends, each engine's standard-library functions could be reimplemented per backend (M×N reimplementations) or written in the source language. The pipeline needs runtime bodies that participate in inlining and overload selection.

**Decision.** Runtime library bodies are expressed in IR via `attach_runtime_body` in `runtime_bodies.rs`: each frontend defines its runtime library in IR once, and each backend emits it. Functions that genuinely cannot be expressed in IR (platform APIs) are backend primitives that each backend emits natively. Builtins (including arithmetic) are ordinary FuncIds in the runtime registry — no BuiltinOp enum, no namespace-prefix dispatch, no separate pipeline path.

**Alternatives rejected.**
- *Raw FunctionBuilder assembly for runtime bodies* — Wrong abstraction level.
- *Source-language implementations of runtime bodies* — No IR primitive access, and the IR is a moving target.
- *Reimplement each runtime library per backend* — The M-frontends × N-backends problem — reimplementing every engine library for every backend. Defining it once in IR lets each backend emit it, avoiding M×N reimplementations.

**Consequences.** Runtime registry functions participate in inlining, overload selection, and constraint solving like user functions; the backend recognizes them to avoid emitting their bodies as game code. Name collisions are resolved at registration time (rename the game function), not by reserving a namespace prefix. Mined from: /home/me/git/rhizone/reincarnate/CLAUDE.md (87).
