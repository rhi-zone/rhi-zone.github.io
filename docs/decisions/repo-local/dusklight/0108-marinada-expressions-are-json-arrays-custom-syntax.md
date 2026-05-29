# ADR-0108: Marinada expressions are JSON arrays, not a custom syntax

- Status: Accepted
- Date: 2026-05-29

**Context.** Dusklight needs an expression language at its core for data manipulation, actions, and reactive bindings. A language needs a representation: either a bespoke surface syntax (requiring a parser) or an existing data format.

**Decision.** Marinada expressions are JSON arrays — s-expressions as a data structure. No custom parser is required; implementations evaluate JSON directly. The JSON array is the canonical runtime format, and typed constructors in TS/Rust are a dev-time authoring layer that compiles down to the same JSON arrays.

**Alternatives rejected.**
- *A custom surface syntax with its own parser* — Would require a custom parser; JSON-as-AST lets programs be loaded from anywhere (config files, API responses, user input) and evaluated dynamically without one

**Consequences.** Programs are universally serializable and loadable from any JSON source. Symbols (op names) are plain JSON strings only in array head position; a bare string elsewhere is a string literal. There are no comments — JSON structure carries clarity. The runtime does not know which authoring path produced an expression. Mined from: /home/me/git/rhizone/dusklight/docs/marinada.md (7), /home/me/git/rhizone/dusklight/docs/marinada.md (9).
