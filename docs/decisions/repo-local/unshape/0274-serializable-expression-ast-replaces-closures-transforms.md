# ADR-0274: Serializable expression AST replaces closures for transforms

- Status: Accepted
- Date: 2026-05-29

**Context.** Transforms like map_vertices(|v| v * 2.0 + offset) are naturally expressed as closures, but closures cannot be serialized, so graphs/pipelines containing them cannot be saved, loaded, or sent to GPU/JIT backends.

**Decision.** Represent computations as a serializable expression AST (provided by the external dew library, bridged via rhi-unshape-expr-field) rather than closures. The AST scope is math plus function calls; all functions are ScalarFn plugins; expressions compile to multiple backends (interpreter, WGSL, Cranelift, Lua).

**Alternatives rejected.**
- *Rust closures for transforms* — Closures work at runtime but cannot be serialized, so they cannot be saved/loaded or compiled to GPU/JIT backends

**Consequences.** Expressions are data: serializable to JSON/MessagePack, parseable at runtime, compilable to GPU/CPU-JIT. Pure (no mutable state, no side effects). Notably excludes loops (use graph recurrence) and texture sampling (separate ops). Backends added without core changes via extension traits + decompose() fallback. Mined from: /home/me/git/rhizone/unshape/docs/design/expression-language.md (2), /home/me/git/rhizone/unshape/docs/design/expression-language.md (9), /home/me/git/rhizone/unshape/docs/design/expression-language.md (24).
