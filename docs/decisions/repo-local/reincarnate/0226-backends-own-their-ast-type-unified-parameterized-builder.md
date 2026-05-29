# ADR-0226: Backends own their AST type; no unified, parameterized, or builder-based core AST

- Status: Accepted
- Date: 2026-05-29

**Context.** The backend lowers IR to a tree it can pattern-match and normalize before printing. There were several ways to relate the core AST to backend-specific ASTs (one unified AST, a generic AST parameterized over an extension, or a builder trait that emits backend AST directly), each trading off engine neutrality against copy cost.

**Decision.** Each backend defines its own AST types (e.g. `JsStmt`/`JsExpr`) separate from the core `Stmt`/`Expr`. The flow is IR → core AST → normalization passes → mechanical lowering → backend AST → engine-specific rewrites → printer, accepting a boring O(n) tree copy in `lower.rs` as the cost of two type hierarchies.

**Alternatives rejected.**
- *Single unified AST for all backends* — Backends need language-specific constructs (`new`, `typeof`, `in`, `delete`, `throw`, `super.*`) that don't belong in core; polluting core with JS-isms violates engine neutrality.
- *Generic AST parameterized over an extension type (`Expr<Ext>`)* — Converting between `Expr<CoreExt>` and `Expr<JsExt>` still requires a deep copy since every `Box` child changes type — no zero-copy win.
- *Builder trait (`AstSink`) producing backend AST directly with no core AST* — AST normalization passes must pattern-match and transform a concrete tree, but a builder is write-only; since the core AST is needed for the passes anyway, the builder can't eliminate it.

**Consequences.** Engine-specific rewrites operate on backend AST (`JsExpr` → `JsExpr`), keeping them decoupled from core types and the printer. The two-type design imposes a mechanical lowering copy as accepted cost. Mined from: /home/me/git/rhizone/reincarnate/docs/architecture.md (957), /home/me/git/rhizone/reincarnate/docs/architecture.md (962).
