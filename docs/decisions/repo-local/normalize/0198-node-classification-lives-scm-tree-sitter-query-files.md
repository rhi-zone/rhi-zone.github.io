# ADR-0198: Node classification lives in .scm tree-sitter query files, not in Rust node-kind lists on the Language trait

- Status: Accepted
- Date: 2026-05-29

**Context.** Classifying AST nodes by concept (functions, calls, complexity contributors, scopes) could be done with Rust methods returning &'static [&'static str] node-kind lists on the Language trait, or with tree-sitter .scm query files loaded via GrammarLoader.

**Decision.** When the task is node identification answerable by a tree-sitter query + capture name, write a .scm file (e.g. *.complexity.scm, *.calls.scm), not a Rust list. Rust is reserved for structured extraction (names, params, fields) that requires logic. Language-specific branches like `if grammar_name == "rust"` or RUST_FOO_QUERY constants in language-agnostic crates are forbidden; the query goes in queries/<lang>.<purpose>.scm.

**Alternatives rejected.**
- *Rust methods returning &'static [&'static str] node-kind lists (complexity_nodes(), nesting_nodes(), etc.)* — Node-kind lists are a subset of tree-sitter queries that loses structural information (parent-child relationships, field names, anonymous nodes like &&/||); they aren't user-customizable via NORMALIZE_GRAMMAR_PATH without recompiling; and they force N language-specific manual tree-walkers instead of one generic query walker.

**Consequences.** *.complexity.scm and *.calls.scm files exist for many languages; the generic query walker is the only path for calls. Old trait methods are preserved only for backward-compat for languages lacking .scm files; scope_creating_kinds()/control_flow_kinds() are future migration candidates. The rule extends to all language-agnostic crates (no language-specific branches). Mined from: /home/me/git/rhizone/normalize/docs/architecture-decisions.md (92), /home/me/git/rhizone/normalize/docs/architecture-decisions.md (422), /home/me/git/rhizone/normalize/ARCHITECTURE.md (215-216).
