# ADR-0220: Param validation via injectable ParamParser adapter; no validation library in router core

- Status: Accepted
- Date: 2026-05-29

**Context.** TanStack Router teardown identified param validation as a must-keep feature (corrupt params should 404, not crash). The router had to decide how to handle validation without coupling to a specific schema library.

**Decision.** The router's only internal contract for a param is `ParamParser<T> = (raw: string) => T | null` (null = no match -> 404). Validation libraries (Standard Schema, Zod, ArkType, regex, plain functions) are bridged via adapters. The router core has zero validation dependencies.

**Alternatives rejected.**
- *Bake a validation library / built-in param coercion into the router core* — Would couple the router to one validation library; the adapter model lets the imported adapter determine the validation library so 'the router doesn't care,' keeping core dependency-free.

**Consequences.** Same principle extends to search params via `searchParam(key, parser)`. Anyone can write an adapter for any validation library. Core stays free of validation dependencies. Standard Schema adapter depends only on `@standard-schema/spec` (types only, no runtime). Mined from: /home/me/git/rhizone/rainbow/docs/design/router.md (74), /home/me/git/rhizone/rainbow/docs/design/router.md (77-78).
