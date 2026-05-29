# ADR-0219: No file-based routing or codegen; route tree is nested data with TypeScript inference

- Status: Accepted
- Date: 2026-05-29

**Context.** TanStack Router offers file-based routing with a Vite plugin. Rainbow-router had to choose between codegen-based routing and a runtime data structure, and how to achieve type safety for params.

**Decision.** Routes are a nested data object (mirroring the prior-art Lua trie router); dynamic segments use `_name` keys. TypeScript infers param types by traversing the route tree object structure, not string patterns. No codegen, no build plugins, no opinions about file structure.

**Alternatives rejected.**
- *File-based routing + Vite plugin (TanStack-style codegen)* — Codegen complexity for zero runtime benefit; params can be inferred by traversing the route tree object at the type level with no generation step.

**Consequences.** `navigate()` and loaders receive correctly typed params with no generation step. Matching is segment-by-segment trie traversal (exact key first, then `_*` dynamic slot), no regex/backtracking. `params` in a route node is `Record<string, ParamParser<unknown>>`. Mined from: /home/me/git/rhizone/rainbow/docs/design/router.md (6-7), /home/me/git/rhizone/rainbow/docs/design/router.md (59).
