# ADR-0196: Load tree-sitter grammars from external shared libraries at runtime, not bundled at compile time

- Status: Accepted
- Date: 2026-05-29

**Context.** 98 tree-sitter grammars (~142MB uncompressed) could be statically bundled into the binary at compile time or loaded from external .so/.dylib/.dll files at runtime via libloading.

**Decision.** Load grammars from external shared-library files via normalize-grammars/GrammarLoader, with a defined search order: NORMALIZE_GRAMMAR_PATH env var, then ~/.config/normalize/grammars/, then built-in fallback (if compiled with grammar features). Grammars come from arborium's curated set or are hand-written (Jinja2 precedent); never pull random tree-sitter grammars from the ecosystem.

**Alternatives rejected.**
- *Bundle all 98 grammars statically into the binary* — Bundling bloats compile time and adds ~142MB uncompressed to binary size, and it prevents users from adding custom grammars.

**Consequences.** Grammars are loaded at runtime and are user-extensible; .scm query files share the same external-path override mechanism. Adding a language requires verifying the grammar is in arborium or writing it, never pulling an arbitrary ecosystem crate. Mined from: /home/me/git/rhizone/normalize/docs/architecture-decisions.md (76), /home/me/git/rhizone/normalize/docs/architecture-decisions.md (82), /home/me/git/rhizone/normalize/ARCHITECTURE.md (207-208).
