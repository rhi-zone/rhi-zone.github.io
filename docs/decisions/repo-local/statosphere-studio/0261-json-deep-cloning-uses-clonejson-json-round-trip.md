# ADR-0261: JSON deep-cloning uses cloneJson() (JSON round-trip), never structuredClone on reactive data

- Status: Accepted
- Date: 2026-05-29

**Context.** structuredClone was used to clone data that includes Vue reactive proxies. toRaw() only unwraps one layer, so nested reactive objects reached structuredClone and threw, causing a page-level exception when adding any recipe.

**Decision.** All deep clones of config/instance data use cloneJson() (a JSON round-trip) instead of structuredClone, because the data may contain nested Vue reactive proxies that structuredClone cannot serialize and toRaw() cannot fully unwrap.

**Alternatives rejected.**
- *structuredClone (optionally with toRaw())* — toRaw() only unwraps one layer; nested reactive objects in extrasByPath, params, and template/arrays still reached structuredClone and caused a page-level exception when adding any recipe.

**Consequences.** materialize.ts, rewrite-refs.ts, and json-patch.ts all use cloneJson(); future clone sites handling reactive-derived data must use the JSON round-trip, accepting its limitation to JSON-serializable values. Mined from: /home/me/git/pterror/statosphere-studio/TODO.md (44).
