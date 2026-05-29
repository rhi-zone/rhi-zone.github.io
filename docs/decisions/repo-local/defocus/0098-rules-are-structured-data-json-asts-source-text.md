# ADR-0098: Rules are structured data (JSON ASTs), not source text

- Status: Accepted
- Date: 2026-05-29

**Context.** Every IF/narrative tool reinvents ad-hoc state management, typically encoding rules as embedded source code or DSL text. defocus needed handler/rule definitions that could be diffed, serialized, transmitted across runtimes, and edited visually.

**Decision.** Handlers and rules are represented as JSON-value ASTs (Expr) — an array whose first string element is a function call — not as text source. An Expr is data that can be evaluated, not a Lua function or a string of source code. The same JSON world file (handlers included) runs unmodified on multiple runtimes (Rust, TypeScript).

**Alternatives rejected.**
- *Rules as source text / embedded scripting language source* — Text source is not diffable at the structural level, not directly serializable, not visually editable, and cannot run unchanged across heterogeneous runtimes (Rust/TS/WASM/Lua). It also reintroduces the ad-hoc state management defocus exists to replace.

**Consequences.** Handlers are diffable, serializable, and visually editable, and worlds round-trip through a versioned JSON format. The cost is an expression language (Marinada subset) must be implemented and kept in sync across every runtime. WASM and Lua (Crescent) runtimes remain planned. Mined from: /home/me/git/rhizone/defocus/README.md (7), /home/me/git/rhizone/defocus/README.md (76), /home/me/git/rhizone/defocus/CONTEXT.md (52-53).
