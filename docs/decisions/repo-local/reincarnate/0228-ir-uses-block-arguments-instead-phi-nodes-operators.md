# ADR-0228: IR uses block arguments instead of phi nodes; operators are calls, not enum variants

- Status: Accepted
- Date: 2026-05-29

**Context.** The IR is the sole channel between pipeline stages and must support an arbitrary set of source engines and target backends. Two design choices recur: how SSA merge points are represented, and how arithmetic/bitwise operators are modeled given that operator semantics differ across target languages (Lua `//`, Rust `>>`, TypeScript `>>>`).

**Decision.** Following Cranelift and MLIR, the IR uses block arguments rather than phi nodes for SSA merge points. Operators carry no dedicated enum: `BinOp`/`UnaryOp` must not exist in core — arithmetic and bitwise operations are `Op::Call` to builtin FuncIds, and each backend dispatches on the function name to emit its native operator syntax.

**Alternatives rejected.**
- *Phi nodes for SSA merges* — Block arguments are simpler to construct from frontends and easier to reason about.
- *`BinOp`/`UnaryOp` enums in core IR* — Operator semantics differ per backend (Lua `//`, Rust `>>`, TypeScript `>>>`); putting them in core would bake target-language assumptions into the engine-neutral IR, violating engine specificity at boundaries.

**Consequences.** Frontends emit branches that pass arguments explicitly. Builtins (including arithmetic) are ordinary FuncIds with no special-casing — no BuiltinOp enum, no prefix dispatch. Holds the IR neutral so every IR decision must work for all planned frontends and backends, not just the active pair. Mined from: /home/me/git/rhizone/reincarnate/docs/architecture.md (915), /home/me/git/rhizone/reincarnate/CLAUDE.md (37).
